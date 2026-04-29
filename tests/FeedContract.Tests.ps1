Describe 'Feed contract' {
    BeforeAll {
        # Load the public feed contract helpers under test.
        . "$PSScriptRoot/../src/_common/FeedContract.ps1"
    }

    It 'accepts the bundled feed fixture' {
        # The bundled fixture must remain a valid reference feed for the public portfolio.
        $feed = Join-Path $PSScriptRoot 'Fixtures/feed-sample'
        $result = Test-PortfolioFeedContract -FeedPath $feed -PassThru

        $result.IsValid | Should -BeTrue
        $result.ContractVersion | Should -Be '1.0.0'
        $result.SourceRepo | Should -Be 'uc-m365-ops-feed'
        $result.ManifestIntegrityPassed | Should -BeTrue
    }

    It 'rejects a feed when feed-quality status is not OK' {
        # Copy the fixture to a temp location so we can safely tamper with validation metadata.
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('portfolio-feedquality-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

        try {
            $sourceFeed = Join-Path $PSScriptRoot 'Fixtures/feed-sample'
            Copy-Item -LiteralPath $sourceFeed -Destination $tempRoot -Recurse -Force
            $feed = Join-Path $tempRoot 'feed-sample'

            # Force the feed-quality status to ERROR and verify the consumer rejects it.
            $qualityPath = Join-Path $feed 'validation/feed-quality.json'
            $quality = Get-Content -LiteralPath $qualityPath -Raw | ConvertFrom-Json
            $quality.status = 'ERROR'
            $quality | ConvertTo-Json -Depth 6 | Out-File -FilePath $qualityPath -Encoding UTF8

            $result = Test-PortfolioFeedContract -FeedPath $feed -PassThru

            $result.IsValid | Should -BeFalse
            $result.FeedQualityStatus | Should -Be 'ERROR'
            $result.QualityGatePassed | Should -BeFalse
        }
        finally {
            if (Test-Path -LiteralPath $tempRoot) {
                Remove-Item -LiteralPath $tempRoot -Recurse -Force
            }
        }
    }

    It 'rejects a feed when a required file no longer matches the manifest hash' {
        # Copy the fixture to a temp location so we can safely tamper with a required file
        # without updating the manifest.
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('portfolio-manifest-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

        try {
            $sourceFeed = Join-Path $PSScriptRoot 'Fixtures/feed-sample'
            Copy-Item -LiteralPath $sourceFeed -Destination $tempRoot -Recurse -Force
            $feed = Join-Path $tempRoot 'feed-sample'

            # Alter a required inventory file and verify manifest integrity fails.
            $csvPath = Join-Path $feed 'inventory/teamsphone-inventory.csv'
            Add-Content -LiteralPath $csvPath -Value "`nTampered User,tampered@contoso.mc,+33123456789,True,SPE_E5,MCOEV"

            $result = Test-PortfolioFeedContract -FeedPath $feed -PassThru

            $result.IsValid | Should -BeFalse
            $result.ManifestIntegrityPassed | Should -BeFalse
            $result.ManifestHashMismatches | Should -Contain 'inventory/teamsphone-inventory.csv'
        }
        finally {
            if (Test-Path -LiteralPath $tempRoot) {
                Remove-Item -LiteralPath $tempRoot -Recurse -Force
            }
        }
    }
}