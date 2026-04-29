[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $FeedPath,
    [string] $OutRoot,
    [string] $RunId = (Get-Date).ToString('yyyyMMdd-HHmmss'),
    [string] $ExportsOrchestratorPath,
    [switch] $PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
if (-not $OutRoot) {
    $OutRoot = Join-Path $repoRoot 'out/evidence'
}
if (-not $ExportsOrchestratorPath) {
    $ExportsOrchestratorPath = Join-Path $repoRoot 'src/TeamsPhone/Exports/Invoke-TeamsPhoneDatExport.ps1'
}

$FeedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FeedPath)
$OutRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutRoot)
$ExportsOrchestratorPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ExportsOrchestratorPath)

function New-DirectoryIfMissing([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Get-FileManifest([string]$Folder) {
    $files = Get-ChildItem -Path $Folder -Recurse -File
    foreach ($f in $files) {
        $h = Get-FileHash -Path $f.FullName -Algorithm SHA256
        [pscustomobject]@{
            Path = $f.FullName.Substring($Folder.Length).TrimStart([char]92,[char]47)
            Size = $f.Length
            Sha256 = $h.Hash
        }
    }
}

if (-not (Test-Path -LiteralPath $ExportsOrchestratorPath)) {
    throw "Exports orchestrator not found: $ExportsOrchestratorPath"
}

$evidenceDir = Join-Path $OutRoot ("teamsphone-evidence-{0}" -f $RunId)
New-DirectoryIfMissing -Path $OutRoot
New-DirectoryIfMissing -Path $evidenceDir

$exportsOut = Join-Path $evidenceDir 'exports'
New-DirectoryIfMissing -Path $exportsOut

& $ExportsOrchestratorPath -FeedPath $FeedPath -OutRoot $exportsOut -RunId $RunId | Out-Null

$manifest = @(Get-FileManifest -Folder $evidenceDir)
$manifest | ConvertTo-Json -Depth 5 | Out-File -FilePath (Join-Path $evidenceDir 'manifest.json') -Encoding UTF8

$datRunDir = Join-Path $exportsOut ("teamsphone-{0}" -f $RunId)
$consumerRunPath = Join-Path $datRunDir 'consumer-run.json'

$inputKind = 'Unknown'
$feedQualityStatus = $null

if (Test-Path -LiteralPath $consumerRunPath) {
    $consumerRun = Get-Content -LiteralPath $consumerRunPath -Raw | ConvertFrom-Json

    if ($consumerRun.PSObject.Properties.Name -contains 'inputKind') {
        $inputKind = $consumerRun.inputKind
    }

    if ($consumerRun.PSObject.Properties.Name -contains 'feedQualityStatus') {
        $feedQualityStatus = $consumerRun.feedQualityStatus
    }
}

$summaryLines = @(
    '# Teams Phone Evidence Pack',
    ('RunId: **{0}**' -f $RunId),
    'Source mode: **FeedDriven**',
    ('Input kind: **{0}**' -f $inputKind)
)

if ($feedQualityStatus) {
    $summaryLines += ('Feed quality: **{0}**' -f $feedQualityStatus)
}

$summary = $summaryLines -join "`n"
$summary | Out-File -FilePath (Join-Path $evidenceDir 'SUMMARY.md') -Encoding UTF8

$zipPath = Join-Path $OutRoot ("teamsphone-evidence-{0}.zip" -f $RunId)
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($evidenceDir, $zipPath)

$result = [pscustomobject]@{
    EvidenceDir = $evidenceDir
    ZipPath = $zipPath
    ManifestPath = Join-Path $evidenceDir 'manifest.json'
    SummaryPath = Join-Path $evidenceDir 'SUMMARY.md'
}

if ($PassThru) { return $result }
$result | ConvertTo-Json -Depth 6
