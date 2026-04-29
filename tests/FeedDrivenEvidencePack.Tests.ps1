Describe 'Feed-driven evidence pack' {
    It 'creates a manifest and zip from the bundled feed fixture' {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('portfolio-evidence-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

        try {
            $feed = Join-Path $PSScriptRoot 'Fixtures/feed-sample'
            $script = Join-Path $PSScriptRoot '..\src\Compliance\EvidencePacks\Invoke-TeamsPhoneEvidencePack.ps1'
            $result = & $script -FeedPath $feed -OutRoot $tempRoot -RunId 'fixture-test' -PassThru

            Test-Path -LiteralPath $result.ManifestPath | Should -BeTrue
            Test-Path -LiteralPath $result.SummaryPath | Should -BeTrue
            Test-Path -LiteralPath $result.ZipPath | Should -BeTrue
        }
        finally {
            if (Test-Path -LiteralPath $tempRoot) {
                Remove-Item -LiteralPath $tempRoot -Recurse -Force
            }
        }
    }
}
