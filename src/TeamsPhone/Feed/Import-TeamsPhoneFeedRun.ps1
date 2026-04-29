function Import-TeamsPhoneFeedRun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $FeedPath,
        [string] $StagingRoot,
        [switch] $PassThru
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    . (Join-Path $PSScriptRoot '..\..\_common\FeedContract.ps1')
    . (Join-Path $PSScriptRoot '..\..\_common\Logging.ps1')
    . (Join-Path $PSScriptRoot '..\Exports\_common\AuditHelpers.ps1')

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

    $validation = Test-PortfolioFeedContract -FeedPath $FeedPath -PassThru
    if (-not $validation.IsValid) {
        $feedQualityStatus = 'unknown'
        if ($null -ne $validation.FeedQualityStatus) {
            $feedQualityStatus = $validation.FeedQualityStatus
        }

        $qualityGatePassed = 'unknown'
        if ($null -ne $validation.QualityGatePassed) {
            $qualityGatePassed = $validation.QualityGatePassed
        }

        $manifestIntegrityPassed = 'unknown'
        if ($null -ne $validation.ManifestIntegrityPassed) {
            $manifestIntegrityPassed = $validation.ManifestIntegrityPassed
        }

        $details = @(
            ('missing files [{0}]' -f (Join-ValidationValues -Values $validation.MissingFiles))
            ('missing columns [{0}]' -f (Join-ValidationValues -Values $validation.MissingColumns))
            ('manifest missing entries [{0}]' -f (Join-ValidationValues -Values $validation.ManifestMissingEntries))
            ('manifest hash mismatches [{0}]' -f (Join-ValidationValues -Values $validation.ManifestHashMismatches))
            ('manifest size mismatches [{0}]' -f (Join-ValidationValues -Values $validation.ManifestSizeMismatches))
            ('feed quality status [{0}]' -f $feedQualityStatus)
            ('quality gate passed [{0}]' -f $qualityGatePassed)
            ('manifest integrity passed [{0}]' -f $manifestIntegrityPassed)
        )

        throw ("Feed contract validation failed for '{0}': {1}" -f $FeedPath, ($details -join '; '))
    }

    $resolvedFeed = (Resolve-Path -LiteralPath $FeedPath).Path
    $run = Get-Content -LiteralPath (Join-Path $resolvedFeed 'meta/run.json') -Raw | ConvertFrom-Json
    $manifest = Get-Content -LiteralPath (Join-Path $resolvedFeed 'meta/manifest.json') -Raw | ConvertFrom-Json
    $quality = Get-Content -LiteralPath (Join-Path $resolvedFeed 'validation/feed-quality.json') -Raw | ConvertFrom-Json
    $inventory = @(Import-Csv -LiteralPath (Join-Path $resolvedFeed 'inventory/teamsphone-inventory.csv'))

    $stagedFeedPath = $null
    if ($StagingRoot) {
        New-DirectoryIfMissing -Path $StagingRoot
        $stagedFeedPath = Join-Path $StagingRoot 'feed-input'
        if (Test-Path -LiteralPath $stagedFeedPath) {
            Remove-Item -LiteralPath $stagedFeedPath -Recurse -Force
        }
        Copy-Item -LiteralPath $resolvedFeed -Destination $stagedFeedPath -Recurse -Force
        Write-TenantLog -Level OK -Message ("Feed staged under: {0}" -f $stagedFeedPath)
    }

    $result = [pscustomobject]@{
        FeedPath       = $resolvedFeed
        StagedFeedPath = $stagedFeedPath
        Validation     = $validation
        Run            = $run
        Manifest       = $manifest
        Quality        = $quality
        Inventory      = $inventory
        ExportPaths    = [pscustomobject]@{
            Config        = Join-Path $resolvedFeed 'exports/tenant-teamsphone-config.json'
            CallFlows     = Join-Path $resolvedFeed 'exports/tenant-teamsphone-callflows.json'
            InventoryCsv  = Join-Path $resolvedFeed 'inventory/teamsphone-inventory.csv'
            InventoryJson = Join-Path $resolvedFeed 'inventory/teamsphone-inventory.json'
            FeedQuality   = Join-Path $resolvedFeed 'validation/feed-quality.json'
        }
    }

    if ($PassThru) { return $result }
    $result | ConvertTo-Json -Depth 8
}