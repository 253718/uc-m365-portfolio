Describe 'Feed-driven Teams Phone DAT export' {
    It 'creates DAT snippets from the bundled feed fixture' {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('portfolio-dat-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

        try {
            # Use the bundled fixture and run the feed-driven DAT export end-to-end.
            $feed = Join-Path $PSScriptRoot 'Fixtures/feed-sample'
            $script = Join-Path $PSScriptRoot '..\src\TeamsPhone\Exports\Invoke-TeamsPhoneDatExport.ps1'
            $result = & $script -FeedPath $feed -OutRoot $tempRoot -RunId 'fixture-test' -PassThru

            # Core output files must exist.
            Test-Path -LiteralPath $result.DatSnippets | Should -BeTrue

            $consumerRunPath = Join-Path $result.RunDir 'consumer-run.json'
            Test-Path -LiteralPath $consumerRunPath | Should -BeTrue

            # Validate consumer metadata.
            $consumerRun = Get-Content -LiteralPath $consumerRunPath -Raw | ConvertFrom-Json
            $consumerRun.inputKind | Should -Be 'BundledFixture'
            $consumerRun.feedQualityStatus | Should -Be 'OK'

            # Validate the DAT snippet content produced from the enriched France / Monaco fixture.
            $content = Get-Content -LiteralPath $result.DatSnippets -Raw

            # Gateways / routing foundations.
            $content | Should -Match 'SBC-FR-01'
            $content | Should -Match 'sbc-fr01.contoso.lab'
            $content | Should -Match 'SBC-MC-01'
            $content | Should -Match 'sbc-mc01.contoso.lab'
            $content | Should -Match 'VR-FR-Default'
            $content | Should -Match 'VR-MC-Default'
            $content | Should -Match 'FR-Default'
            $content | Should -Match 'MC-Default'

            # Dial plans / normalization rules.
            $content | Should -Match '## Dial Plans / Normalization Rules'
            $content | Should -Match 'DP-FR-Users'
            $content | Should -Match 'DP-MC-Users'
            $content | Should -Match 'NR-FR-National'
            $content | Should -Match 'NR-MC-Local'
            $content | Should -Match 'NR-FR-Mobile'
            $content | Should -Match 'NR-Intl-00'

            # Voice routing policies.
            $content | Should -Match 'VRP-FR-Users'
            $content | Should -Match 'VRP-MC-Users'
            $content | Should -Match 'France population routing'
            $content | Should -Match 'Monaco population routing'

            # Service entry / queues.
            $content | Should -Match 'Phone - AA - France Offices'
            $content | Should -Match 'Phone - AA - France to Monaco Services'
            $content | Should -Match 'Phone - AA - Monaco Reception'
            $content | Should -Match 'Phone - CQ - France Desk'
            $content | Should -Match 'Phone - CQ - Monaco Service 1'
            $content | Should -Match 'Phone - CQ - Monaco Service 2'
            $content | Should -Match 'Phone - CQ - Monaco Service 3'

            # Resource account typing.
            $content | Should -Match 'Type: Auto Attendant'
            $content | Should -Match 'Type: Call Queue'

            # Inventory signal summary.
            $content | Should -Match '## Inventory signal'
            $content | Should -Match 'Auto attendants: 3'
            $content | Should -Match 'Call queues: 4'
            $content | Should -Match 'Resource accounts: 7'
            $content | Should -Match 'Voice routes: 2'
            $content | Should -Match 'Voice routing policies: 2'
        }
        finally {
            if (Test-Path -LiteralPath $tempRoot) {
                Remove-Item -LiteralPath $tempRoot -Recurse -Force
            }
        }
    }
}
