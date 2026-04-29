function New-DirectoryIfMissing {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Export-AuditJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Object,

        [Parameter(Mandatory)]
        [string] $Path,

        [int] $Depth = 10
    )

    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-DirectoryIfMissing -Path $dir
    }

    $Object | ConvertTo-Json -Depth $Depth | Out-File -FilePath $Path -Encoding UTF8
}

function Export-AuditCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Object,

        [Parameter(Mandatory)]
        [string] $Path
    )

    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-DirectoryIfMissing -Path $dir
    }

    $Object | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
}
