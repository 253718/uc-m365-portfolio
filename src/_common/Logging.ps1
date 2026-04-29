function Write-TenantLog {
    <#
    .SYNOPSIS
    Lightweight console logger with levels and colors.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'OK', 'DEBUG')]
        [string] $Level,

        [Parameter(Mandatory)]
        [string] $Message
    )

    $prefix = '[{0}] {1}' -f $Level, (Get-Date).ToString('s')

    switch ($Level) {
        'OK'    { Write-Host "$prefix $Message" -ForegroundColor Green }
        'WARN'  { Write-Host "$prefix $Message" -ForegroundColor Yellow }
        'ERROR' { Write-Host "$prefix $Message" -ForegroundColor Red }
        'DEBUG' { Write-Host "$prefix $Message" -ForegroundColor DarkGray }
        default { Write-Host "$prefix $Message" -ForegroundColor Cyan }
    }
}
