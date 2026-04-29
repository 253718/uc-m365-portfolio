[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $FeedPath,
    [string] $OutRoot,
    [string] $RunId = (Get-Date).ToString('yyyyMMdd-HHmmss'),
    [switch] $PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_common\AuditHelpers.ps1')
. (Join-Path $PSScriptRoot '..\..\_common\Logging.ps1')
. (Join-Path $PSScriptRoot '..\Feed\Import-TeamsPhoneFeedRun.ps1')

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
if (-not $OutRoot) {
    $OutRoot = Join-Path $repoRoot 'out/audit'
}

$FeedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FeedPath)
$OutRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutRoot)

$runDir = Join-Path $OutRoot ("teamsphone-{0}" -f $RunId)
New-DirectoryIfMissing -Path $runDir

$feedImport = Import-TeamsPhoneFeedRun -FeedPath $FeedPath -StagingRoot $runDir -PassThru
$sourceMode = 'FeedDriven'
$feedMetadata = $feedImport.Run

Copy-Item -LiteralPath $feedImport.ExportPaths.Config -Destination (Join-Path $runDir 'tenant-teamsphone-config.json') -Force
Copy-Item -LiteralPath $feedImport.ExportPaths.CallFlows -Destination (Join-Path $runDir 'tenant-teamsphone-callflows.json') -Force
Copy-Item -LiteralPath $feedImport.ExportPaths.InventoryCsv -Destination (Join-Path $runDir 'teamsphone-inventory.csv') -Force
Copy-Item -LiteralPath $feedImport.ExportPaths.InventoryJson -Destination (Join-Path $runDir 'teamsphone-inventory.json') -Force
Copy-Item -LiteralPath $feedImport.ExportPaths.FeedQuality -Destination (Join-Path $runDir 'feed-quality.json') -Force

$inputKind = 'CanonicalFeed'
if ($FeedPath.Replace('\', '/').ToLowerInvariant() -match '/tests/fixtures/') {
    $inputKind = 'BundledFixture'
}

$consumerMeta = [pscustomobject]@{
    sourceMode = $sourceMode
    inputKind = $inputKind
    consumedAtUtc = (Get-Date).ToUniversalTime().ToString('s') + 'Z'
    consumedFeed = $feedImport.Run
    feedQualityStatus = $feedImport.Quality.status
}
Export-AuditJson -Object $consumerMeta -Path (Join-Path $runDir 'consumer-run.json') -Depth 8

& (Join-Path $PSScriptRoot 'Build-TeamsPhoneDatSnippets.ps1') -ExportsDir $runDir -OutFile (Join-Path $runDir 'DAT-snippets.md') | Out-Null
Write-TenantLog -Level OK -Message ("Feed-driven Teams Phone export run prepared: {0}" -f $runDir)

$result = [pscustomobject]@{
    RunDir = $runDir
    RunId = $RunId
    SourceMode = $sourceMode
    Feed = $feedMetadata
    DatSnippets = Join-Path $runDir 'DAT-snippets.md'
    Config = Join-Path $runDir 'tenant-teamsphone-config.json'
    CallFlows = Join-Path $runDir 'tenant-teamsphone-callflows.json'
}

if ($PassThru) { return $result }
$result | ConvertTo-Json -Depth 6
