[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $FeedPath,
    [switch] $PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\src\_common\FeedContract.ps1')

function Join-ValidationValues {
    [CmdletBinding()]
    param(
        [Parameter()]
        [object[]] $Values,

        [string] $Default = 'none'
    )

    $items = @($Values | Where-Object { -not [string]::IsNullOrWhiteSpace([string] $_) })
    if ($items.Count -eq 0) {
        return $Default
    }

    return ($items -join ', ')
}

$result = Test-PortfolioFeedContract -FeedPath $FeedPath -PassThru

if (-not $PassThru) {
    if (-not $result.IsValid) {
        $feedQualityStatus = 'unknown'
        if ($null -ne $result.FeedQualityStatus) {
            $feedQualityStatus = $result.FeedQualityStatus
        }

        $qualityGatePassed = 'unknown'
        if ($null -ne $result.QualityGatePassed) {
            $qualityGatePassed = $result.QualityGatePassed
        }

        $manifestIntegrityPassed = 'unknown'
        if ($null -ne $result.ManifestIntegrityPassed) {
            $manifestIntegrityPassed = $result.ManifestIntegrityPassed
        }

        $details = @(
            ('missing files [{0}]' -f (Join-ValidationValues -Values $result.MissingFiles))
            ('missing columns [{0}]' -f (Join-ValidationValues -Values $result.MissingColumns))
            ('manifest missing entries [{0}]' -f (Join-ValidationValues -Values $result.ManifestMissingEntries))
            ('manifest hash mismatches [{0}]' -f (Join-ValidationValues -Values $result.ManifestHashMismatches))
            ('manifest size mismatches [{0}]' -f (Join-ValidationValues -Values $result.ManifestSizeMismatches))
            ('feed quality status [{0}]' -f $feedQualityStatus)
            ('quality gate passed [{0}]' -f $qualityGatePassed)
            ('manifest integrity passed [{0}]' -f $manifestIntegrityPassed)
        )

        Write-Error ("Feed contract validation failed for '{0}': {1}" -f $FeedPath, ($details -join '; '))
    }
    else {
        Write-Host ("Feed contract validation OK: {0}" -f $FeedPath) -ForegroundColor Green
    }
}

if ($PassThru) {
    return $result
}

$result | ConvertTo-Json -Depth 6