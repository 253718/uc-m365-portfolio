<#
.SYNOPSIS
Read-only guardrail (static scan).
#>
[CmdletBinding()]
param(
    [string] $Root = '.',
    [switch] $FailOnMatch,
    [switch] $PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$readOnlyPaths = @(
    'src/TeamsPhone/Exports',
    'src/TeamsPhone/Feed',
    'src/Compliance/EvidencePacks'
)

$forbidden = @(
    'Set-Cs', 'New-Cs', 'Remove-Cs', 'Grant-Cs',
    'Set-Mg', 'New-Mg', 'Remove-Mg', 'Update-Mg',
    'Set-Admin', 'New-Admin', 'Remove-Admin'
)

$tokenMatches = @()

foreach ($rel in $readOnlyPaths) {
    $path = Join-Path $Root $rel
    if (-not (Test-Path -LiteralPath $path)) {
        continue
    }

    foreach ($file in Get-ChildItem -LiteralPath $path -Recurse -File -Filter *.ps1) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        foreach ($token in $forbidden) {
            if ($text -match [regex]::Escape($token)) {
                $tokenMatches += [pscustomobject]@{
                    File = $file.FullName
                    Token = $token
                }
            }
        }
    }
}

if ($tokenMatches.Count -gt 0) {
    Write-Host 'Forbidden tokens detected in read-only domains:' -ForegroundColor Red
    $tokenMatches | Sort-Object File, Token | Format-Table -AutoSize
    if ($FailOnMatch) {
        exit 3
    }
}
else {
    Write-Host 'Read-only guard: OK.' -ForegroundColor Green
}

if ($PassThru) {
    return $tokenMatches
}
