<#
.SYNOPSIS
Build DAT-ready markdown snippets from Teams Phone export JSON.

.DESCRIPTION
Offline conversion: reads export JSON files and creates DAT-snippets.md.
Works with committed sample exports and feed-consumed exports.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $ExportsDir,

    [string] $OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-Json {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [switch] $Optional
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($Optional) {
            return $null
        }

        throw "Missing JSON file: $Path"
    }

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Get-SafeProperty {
    [CmdletBinding()]
    param(
        [Parameter()]
        [object] $Object,

        [Parameter(Mandatory)]
        [string] $Name,

        $Default = $null
    )

    if (-not $Object) {
        return $Default
    }

    if ($Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }

    return $Default
}

function Join-Values {
    [CmdletBinding()]
    param(
        [Parameter()]
        [object[]] $Values,

        [string] $Separator = ', ',

        [string] $Default = 'n/a'
    )

    $items = @($Values | Where-Object { -not [string]::IsNullOrWhiteSpace([string] $_) })
    if ($items.Count -eq 0) {
        return $Default
    }

    return ($items -join $Separator)
}

function Get-ResourceAccountType {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object] $ResourceAccount,

        [Parameter(Mandatory)]
        [object[]] $AutoAttendants,

        [Parameter(Mandatory)]
        [object[]] $CallQueues
    )

    $name = [string](Get-SafeProperty -Object $ResourceAccount -Name 'DisplayName' -Default '')
    if ([string]::IsNullOrWhiteSpace($name)) {
        return 'Unknown'
    }

    $aaNames = @($AutoAttendants | ForEach-Object { Get-SafeProperty -Object $_ -Name 'Name' -Default $null })
    $cqNames = @($CallQueues | ForEach-Object { Get-SafeProperty -Object $_ -Name 'Name' -Default $null })

    if ($name -in $aaNames) {
        return 'Auto Attendant'
    }

    if ($name -in $cqNames) {
        return 'Call Queue'
    }

    return 'Unknown'
}

if (-not $OutFile) {
    $OutFile = Join-Path -Path $ExportsDir -ChildPath 'DAT-snippets.md'
}

$configPath = Join-Path -Path $ExportsDir -ChildPath 'tenant-teamsphone-config.json'
$flowsPath = Join-Path -Path $ExportsDir -ChildPath 'tenant-teamsphone-callflows.json'
$recordingPath = Join-Path -Path $ExportsDir -ChildPath 'tenant-teamsphone-recording.json'
$recordingUsagePath = Join-Path -Path $ExportsDir -ChildPath 'tenant-teamsphone-recording-usage.summary.json'

$config = Get-Json -Path $configPath
$flows = Get-Json -Path $flowsPath
$recording = Get-Json -Path $recordingPath -Optional
$recordingUsage = Get-Json -Path $recordingUsagePath -Optional

$md = [System.Collections.Generic.List[string]]::new()
$null = $md.Add('# DAT - Implementation details')
$null = $md.Add('')
$null = $md.Add(('Generated: **{0}**' -f ((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))))
$null = $md.Add('')

# Read configuration sections from the exported config JSON.
$dialPlans = @(Get-SafeProperty -Object $config -Name 'DialPlans' -Default @())
$dr = Get-SafeProperty -Object $config -Name 'DirectRouting' -Default ([pscustomobject]@{})
$gateways = @(Get-SafeProperty -Object $dr -Name 'Gateways' -Default @())
$routes = @(Get-SafeProperty -Object $dr -Name 'VoiceRoutes' -Default @())
$policies = @(Get-SafeProperty -Object $dr -Name 'VoiceRoutingPolicies' -Default @())
$pstnUsages = @(Get-SafeProperty -Object $dr -Name 'PstnUsages' -Default @())

# Read call flow sections from the exported call flow JSON.
$autoAttendants = @(Get-SafeProperty -Object $flows -Name 'AutoAttendants' -Default @())
$callQueues = @(Get-SafeProperty -Object $flows -Name 'CallQueues' -Default @())
$resourceAccounts = @(Get-SafeProperty -Object $flows -Name 'ResourceAccountsCompact' -Default @())

# ---------------------------------------------------------------------------
# Dial plans and normalization rules
# ---------------------------------------------------------------------------
$null = $md.Add('## Dial Plans / Normalization Rules')
if ($dialPlans.Count -gt 0) {
    foreach ($dp in $dialPlans) {
        $identity = Get-SafeProperty -Object $dp -Name 'Identity' -Default 'unknown'
        $description = Get-SafeProperty -Object $dp -Name 'Description' -Default ''
        $rules = @(Get-SafeProperty -Object $dp -Name 'NormalizationRules' -Default @())

        if ([string]::IsNullOrWhiteSpace([string] $description)) {
            $null = $md.Add(('- {0}' -f $identity))
        }
        else {
            $null = $md.Add(('- {0} - {1}' -f $identity, $description))
        }

        if ($rules.Count -gt 0) {
            foreach ($rule in $rules) {
                $ruleIdentity = Get-SafeProperty -Object $rule -Name 'Identity' -Default 'unknown'
                $pattern = Get-SafeProperty -Object $rule -Name 'Pattern' -Default 'n/a'
                $translation = Get-SafeProperty -Object $rule -Name 'Translation' -Default 'n/a'
                $null = $md.Add(('  - Rule {0}: {1} -> {2}' -f $ruleIdentity, $pattern, $translation))
            }
        }
        else {
            $null = $md.Add('  - No normalization rules')
        }
    }
}
else {
    $null = $md.Add('- None')
}
$null = $md.Add('')

# ---------------------------------------------------------------------------
# Direct Routing
# ---------------------------------------------------------------------------
$null = $md.Add('## Direct Routing - Gateways / Routes / Policies')

$null = $md.Add('### Gateways')
if ($gateways.Count -gt 0) {
    foreach ($g in $gateways) {
        $identity = Get-SafeProperty -Object $g -Name 'Identity' -Default 'unknown'
        $fqdn = Get-SafeProperty -Object $g -Name 'Fqdn' -Default 'unknown'
        $port = Get-SafeProperty -Object $g -Name 'SipSignalingPort' -Default 'n/a'
        $enabled = Get-SafeProperty -Object $g -Name 'Enabled' -Default 'n/a'
        $null = $md.Add(('- {0} / {1} (port {2}) Enabled: {3}' -f $identity, $fqdn, $port, $enabled))
    }
}
else {
    $null = $md.Add('- None')
}
$null = $md.Add('')

$null = $md.Add('### PSTN Usages')
if ($pstnUsages.Count -gt 0) {
    foreach ($usage in $pstnUsages) {
        $null = $md.Add(('- {0}' -f $usage))
    }
}
else {
    $null = $md.Add('- None')
}
$null = $md.Add('')

$null = $md.Add('### Voice Routes')
if ($routes.Count -gt 0) {
    foreach ($r in $routes) {
        $identity = Get-SafeProperty -Object $r -Name 'Identity' -Default 'unknown'
        $pattern = Get-SafeProperty -Object $r -Name 'NumberPattern' -Default 'n/a'
        $usages = @(Get-SafeProperty -Object $r -Name 'OnlinePstnUsages' -Default @())
        $gatewayList = @(Get-SafeProperty -Object $r -Name 'OnlinePstnGatewayList' -Default @())
        $priority = Get-SafeProperty -Object $r -Name 'Priority' -Default 'n/a'

        $null = $md.Add(('- {0}' -f $identity))
        $null = $md.Add(('  - Pattern: {0}' -f $pattern))
        $null = $md.Add(('  - Usages: {0}' -f (Join-Values -Values $usages)))
        $null = $md.Add(('  - Gateways: {0}' -f (Join-Values -Values $gatewayList)))
        $null = $md.Add(('  - Priority: {0}' -f $priority))
    }
}
else {
    $null = $md.Add('- None')
}
$null = $md.Add('')

$null = $md.Add('### Voice Routing Policies')
if ($policies.Count -gt 0) {
    foreach ($p in $policies) {
        $identity = Get-SafeProperty -Object $p -Name 'Identity' -Default 'unknown'
        $usages = @(Get-SafeProperty -Object $p -Name 'OnlinePstnUsages' -Default @())
        $description = Get-SafeProperty -Object $p -Name 'Description' -Default ''

        $null = $md.Add(('- {0}' -f $identity))
        $null = $md.Add(('  - Usages: {0}' -f (Join-Values -Values $usages)))

        if (-not [string]::IsNullOrWhiteSpace([string] $description)) {
            $null = $md.Add(('  - Description: {0}' -f $description))
        }
    }
}
else {
    $null = $md.Add('- None')
}
$null = $md.Add('')

# ---------------------------------------------------------------------------
# Auto attendants, call queues, and resource accounts
# ---------------------------------------------------------------------------
$null = $md.Add('## Auto Attendants / Call Queues / Resource Accounts')

$null = $md.Add('### Auto Attendants')
if ($autoAttendants.Count -gt 0) {
    foreach ($aa in $autoAttendants) {
        $name = Get-SafeProperty -Object $aa -Name 'Name' -Default 'unknown'
        $identity = Get-SafeProperty -Object $aa -Name 'Identity' -Default 'unknown'
        $null = $md.Add(('- {0} ({1})' -f $name, $identity))
    }
}
else {
    $null = $md.Add('- None')
}
$null = $md.Add('')

$null = $md.Add('### Call Queues')
if ($callQueues.Count -gt 0) {
    foreach ($cq in $callQueues) {
        $name = Get-SafeProperty -Object $cq -Name 'Name' -Default 'unknown'
        $identity = Get-SafeProperty -Object $cq -Name 'Identity' -Default 'unknown'
        $null = $md.Add(('- {0} ({1})' -f $name, $identity))
    }
}
else {
    $null = $md.Add('- None')
}
$null = $md.Add('')

$null = $md.Add('### Resource Accounts')
if ($resourceAccounts.Count -gt 0) {
    foreach ($ra in $resourceAccounts) {
        $name = Get-SafeProperty -Object $ra -Name 'DisplayName' -Default 'unknown'
        $number = Get-SafeProperty -Object $ra -Name 'PhoneNumber' -Default ''
        $upn = Get-SafeProperty -Object $ra -Name 'UserPrincipalName' -Default 'n/a'
        $appId = Get-SafeProperty -Object $ra -Name 'ApplicationId' -Default 'n/a'
        $type = Get-ResourceAccountType -ResourceAccount $ra -AutoAttendants $autoAttendants -CallQueues $callQueues

        $null = $md.Add(('- {0}' -f $name))
        $null = $md.Add(('  - Type: {0}' -f $type))
        $null = $md.Add(('  - UPN: {0}' -f $upn))
        $null = $md.Add(('  - ApplicationId: {0}' -f $appId))

        if ([string]::IsNullOrWhiteSpace([string] $number)) {
            $null = $md.Add('  - Number: none')
        }
        else {
            $null = $md.Add(('  - Number: {0}' -f $number))
        }
    }
}
else {
    $null = $md.Add('- None')
}
$null = $md.Add('')

# ---------------------------------------------------------------------------
# Compliance recording
# ---------------------------------------------------------------------------
$null = $md.Add('## Legal recording - Policies (Teams)')
$recordingPolicies = @()
if ($recording) {
    $recordingPolicies = @(Get-SafeProperty -Object $recording -Name 'ComplianceRecordingPolicies' -Default @())
}

if ($recordingPolicies.Count -gt 0) {
    foreach ($policy in $recordingPolicies) {
        $null = $md.Add(('- {0}' -f (Get-SafeProperty -Object $policy -Name 'Identity' -Default 'unknown')))
    }
}
else {
    $null = $md.Add('- Out of scope for this sample fixture')
}
$null = $md.Add('')

# ---------------------------------------------------------------------------
# Inventory signal
# ---------------------------------------------------------------------------
$null = $md.Add('## Inventory signal')
$null = $md.Add(('- Auto attendants: {0}' -f $autoAttendants.Count))
$null = $md.Add(('- Call queues: {0}' -f $callQueues.Count))
$null = $md.Add(('- Resource accounts: {0}' -f $resourceAccounts.Count))
$null = $md.Add(('- Voice routes: {0}' -f $routes.Count))
$null = $md.Add(('- Voice routing policies: {0}' -f $policies.Count))

if ($recordingUsage) {
    $null = $md.Add(('- Recording assignments scanned: {0}' -f (Get-SafeProperty -Object $recordingUsage -Name 'TotalUsersScanned' -Default 0)))
    $null = $md.Add(('- Recording assignments unassigned: {0}' -f (Get-SafeProperty -Object $recordingUsage -Name 'UnassignedCount' -Default 0)))
}
else {
    $null = $md.Add('- Recording assignment details are out of scope for this sample fixture')
}

$content = $md -join [Environment]::NewLine
$content | Out-File -FilePath $OutFile -Encoding UTF8