[CmdletBinding()]
param(
    [string] $FeedPath,
    [string] $AuditOutRoot,
    [string] $EvidenceOutRoot,
    [string] $RunId = 'demo001',
    [switch] $PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $FeedPath) {
    $FeedPath = Join-Path $repoRoot 'tests/Fixtures/feed-sample'
}
if (-not $AuditOutRoot) {
    $AuditOutRoot = Join-Path $repoRoot 'out/audit'
}
if (-not $EvidenceOutRoot) {
    $EvidenceOutRoot = Join-Path $repoRoot 'out/evidence'
}

$result = & (Join-Path $PSScriptRoot 'Invoke-PortfolioFromFeed.ps1') `
    -FeedPath $FeedPath `
    -AuditOutRoot $AuditOutRoot `
    -EvidenceOutRoot $EvidenceOutRoot `
    -RunId $RunId `
    -PassThru

if ($PassThru) { return $result }
$result | ConvertTo-Json -Depth 6
