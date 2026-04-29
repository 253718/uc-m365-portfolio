<#
.SYNOPSIS
One-command public consumer run from a canonical feed.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $FeedPath,

    [string] $AuditOutRoot,
    [string] $EvidenceOutRoot,
    [string] $RunId = (Get-Date).ToString('yyyyMMdd-HHmmss'),
    [switch] $PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $AuditOutRoot) {
    $AuditOutRoot = Join-Path $repoRoot 'out/audit'
}
if (-not $EvidenceOutRoot) {
    $EvidenceOutRoot = Join-Path $repoRoot 'out/evidence'
}

$FeedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FeedPath)
$AuditOutRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($AuditOutRoot)
$EvidenceOutRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($EvidenceOutRoot)

& (Join-Path $PSScriptRoot 'Validate-FeedContract.ps1') -FeedPath $FeedPath | Out-Null

$datRun = & (Join-Path $PSScriptRoot '..\src\TeamsPhone\Exports\Invoke-TeamsPhoneDatExport.ps1') -FeedPath $FeedPath -OutRoot $AuditOutRoot -RunId $RunId -PassThru
$evidence = & (Join-Path $PSScriptRoot '..\src\Compliance\EvidencePacks\Invoke-TeamsPhoneEvidencePack.ps1') -FeedPath $FeedPath -OutRoot $EvidenceOutRoot -RunId $RunId -PassThru

$result = [pscustomobject]@{
    RunId = $RunId
    DatRun = $datRun
    Evidence = $evidence
}

if ($PassThru) {
    return $result
}

$result | ConvertTo-Json -Depth 6
