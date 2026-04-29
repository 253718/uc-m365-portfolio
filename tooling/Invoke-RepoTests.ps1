<#
.SYNOPSIS
Run repository tests with Pester 5.
#>
[CmdletBinding()]
param(
    [string] $OutputFile,
    [switch] $NoCI
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$testsPath = Join-Path $repoRoot 'tests'
if (-not $OutputFile) {
    $OutputFile = Join-Path $repoRoot 'TestResults/pester.xml'
}
$OutputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputFile)

function Assert-Pester5 {
    $pester5 = Get-Module Pester -ListAvailable |
        Where-Object { $_.Version.Major -ge 5 } |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if (-not $pester5) {
        Write-Host 'Installing Pester >= 5.0.0 (CurrentUser)...' -ForegroundColor Cyan
        Install-Module Pester -Scope CurrentUser -Force -MinimumVersion 5.0.0
        $pester5 = Get-Module Pester -ListAvailable |
            Where-Object { $_.Version.Major -ge 5 } |
            Sort-Object Version -Descending |
            Select-Object -First 1
    }

    if (-not $pester5) {
        throw 'Pester 5 could not be located after installation.'
    }

    Remove-Module Pester -ErrorAction SilentlyContinue
    Import-Module Pester -RequiredVersion $pester5.Version -Force
}

$dir = Split-Path -Parent $OutputFile
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

Assert-Pester5

if ($NoCI) {
    Invoke-Pester -Path $testsPath
}
else {
    $config = New-PesterConfiguration
    $config.Run.Path = $testsPath
    $config.Run.Exit = $true
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputFormat = 'NUnitXml'
    $config.TestResult.OutputPath = $OutputFile
    $config.Output.Verbosity = 'Detailed'
    Invoke-Pester -Configuration $config
}
