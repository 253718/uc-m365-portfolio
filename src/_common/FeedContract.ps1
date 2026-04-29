function Get-PortfolioFeedRequiredFiles {
    [CmdletBinding()]
    param()

    return @(
        'meta/run.json',
        'meta/manifest.json',
        'exports/tenant-teamsphone-config.json',
        'exports/tenant-teamsphone-callflows.json',
        'inventory/teamsphone-inventory.csv',
        'inventory/teamsphone-inventory.json',
        'validation/feed-quality.json'
    )
}

function Get-PortfolioFeedRequiredInventoryColumns {
    [CmdletBinding()]
    param()

    return @(
        'DisplayName',
        'UserPrincipalName',
        'PhoneNumber',
        'VoiceEnabled',
        'VoiceLicenseSku',
        'VoiceServicePlan'
    )
}

function Test-PortfolioFeedContract {
    <#
    .SYNOPSIS
    Validate the public feed-to-portfolio contract.

    .DESCRIPTION
    Ensures that the feed contains the required files, the minimum
    inventory schema, the minimum run metadata, and a manifest that
    declares the required entries.

    Also enforces two consumer-side trust gates:
    - feed-quality.json must report status = OK
    - required files must still match the manifest size/hash metadata

    Notes:
    - meta/manifest.json is required as an entry in the manifest,
      but its own file hash is not revalidated here because the
      manifest references itself in the bundled fixture.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $FeedPath,

        [switch] $PassThru
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    $requiredFiles = Get-PortfolioFeedRequiredFiles
    $requiredColumns = Get-PortfolioFeedRequiredInventoryColumns

    # Check that all required files exist on disk.
    $missingFiles = [System.Collections.Generic.List[string]]::new()
    foreach ($rel in $requiredFiles) {
        $path = Join-Path $FeedPath $rel
        if (-not (Test-Path -LiteralPath $path)) {
            $missingFiles.Add($rel) | Out-Null
        }
    }

    $runJsonPath = Join-Path $FeedPath 'meta/run.json'
    $manifestPath = Join-Path $FeedPath 'meta/manifest.json'
    $inventoryCsvPath = Join-Path $FeedPath 'inventory/teamsphone-inventory.csv'
    $qualityPath = Join-Path $FeedPath 'validation/feed-quality.json'

    # Load optional feed metadata documents when present.
    $run = $null
    if (Test-Path -LiteralPath $runJsonPath) {
        $run = Get-Content -LiteralPath $runJsonPath -Raw | ConvertFrom-Json
    }

    $manifest = $null
    if (Test-Path -LiteralPath $manifestPath) {
        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    }

    $quality = $null
    if (Test-Path -LiteralPath $qualityPath) {
        $quality = Get-Content -LiteralPath $qualityPath -Raw | ConvertFrom-Json
    }

    # Consumer-side quality gate:
    # only a feed explicitly marked OK is considered valid.
    $qualityOk = $false
    if ($quality -and ($quality.PSObject.Properties.Name -contains 'status')) {
        $qualityOk = ([string]$quality.status -eq 'OK')
    }

    # Validate the minimum inventory schema.
    $rows = @()
    $missingColumns = @()
    if (Test-Path -LiteralPath $inventoryCsvPath) {
        $rows = @(Import-Csv -LiteralPath $inventoryCsvPath)
        if ($rows.Count -gt 0) {
            $headers = $rows[0].PSObject.Properties.Name
            $missingColumns = @($requiredColumns | Where-Object { $_ -notin $headers })
        }
    }

    # Validate minimum run metadata required by the public consumer.
    $runHasMinimumFields = $false
    if ($run) {
        $runHasMinimumFields = (
            $run.PSObject.Properties.Name -contains 'contractVersion' -and
            $run.PSObject.Properties.Name -contains 'domain' -and
            $run.PSObject.Properties.Name -contains 'runId' -and
            $run.PSObject.Properties.Name -contains 'sourceRepo' -and
            $run.PSObject.Properties.Name -contains 'mode' -and
            $run.PSObject.Properties.Name -contains 'generatedAtUtc' -and
            $run.PSObject.Properties.Name -contains 'producer'
        )
    }

    # Validate that the manifest exposes a files collection and contains
    # entries for every required contract file.
    $manifestHasFiles = $false
    $manifestPaths = @()
    if ($manifest -and ($manifest.PSObject.Properties.Name -contains 'files')) {
        $manifestHasFiles = $true
        $manifestPaths = @($manifest.files | ForEach-Object { $_.path })
    }

    $manifestMissingEntries = @()
    if ($manifestHasFiles) {
        $manifestMissingEntries = @($requiredFiles | Where-Object { $_ -notin $manifestPaths })
    }

    # Build a quick manifest lookup by relative path.
    $manifestIndex = @{}
    if ($manifestHasFiles) {
        foreach ($entry in @($manifest.files)) {
            if ($entry.path) {
                $manifestIndex[[string]$entry.path] = $entry
            }
        }
    }

    # Revalidate integrity of required files against manifest metadata.
    # We intentionally skip meta/manifest.json itself because the bundled
    # fixture includes the manifest as one of its own entries.
    $manifestHashMismatches = [System.Collections.Generic.List[string]]::new()
    $manifestSizeMismatches = [System.Collections.Generic.List[string]]::new()

    $manifestIntegrityTargets = @(
        $requiredFiles | Where-Object { $_ -ne 'meta/manifest.json' }
    )

    foreach ($rel in $manifestIntegrityTargets) {
        $fullPath = Join-Path $FeedPath $rel

        if (-not (Test-Path -LiteralPath $fullPath)) {
            continue
        }

        if (-not $manifestIndex.ContainsKey($rel)) {
            continue
        }

        $entry = $manifestIndex[$rel]
        $actualHash = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash
        $actualSize = (Get-Item -LiteralPath $fullPath).Length

        if (($entry.PSObject.Properties.Name -contains 'sha256') -and ([string]$entry.sha256 -ne $actualHash)) {
            $manifestHashMismatches.Add($rel) | Out-Null
        }

        if (($entry.PSObject.Properties.Name -contains 'size') -and ([int64]$entry.size -ne [int64]$actualSize)) {
            $manifestSizeMismatches.Add($rel) | Out-Null
        }
    }

    $result = [pscustomobject]@{
        IsValid = (
            ($missingFiles.Count -eq 0) -and
            ($missingColumns.Count -eq 0) -and
            $runHasMinimumFields -and
            $manifestHasFiles -and
            ($manifestMissingEntries.Count -eq 0) -and
            ($manifestHashMismatches.Count -eq 0) -and
            ($manifestSizeMismatches.Count -eq 0) -and
            $qualityOk
        )
        FeedPath = (Resolve-Path -LiteralPath $FeedPath).Path
        ContractVersion = if ($run) { $run.contractVersion } else { $null }
        Domain = if ($run) { $run.domain } else { $null }
        RunId = if ($run) { $run.runId } else { $null }
        SourceRepo = if ($run) { $run.sourceRepo } else { $null }
        Mode = if ($run) { $run.mode } else { $null }
        MissingFiles = @($missingFiles)
        MissingColumns = @($missingColumns)
        ManifestMissingEntries = @($manifestMissingEntries)
        ManifestHashMismatches = @($manifestHashMismatches)
        ManifestSizeMismatches = @($manifestSizeMismatches)
        ManifestIntegrityPassed = (
            ($manifestHashMismatches.Count -eq 0) -and
            ($manifestSizeMismatches.Count -eq 0)
        )
        InventoryRowCount = @($rows).Count
        FeedQualityStatus = if ($quality) { $quality.status } else { $null }
        QualityGatePassed = $qualityOk
    }

    if ($PassThru) {
        return $result
    }

    $result | ConvertTo-Json -Depth 6
}