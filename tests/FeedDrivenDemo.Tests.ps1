Describe 'Feed-driven demo smoke test' {
    It 'runs the feed-driven demo end-to-end' {
        $repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $scriptPath = Join-Path $repoRoot 'tooling/Invoke-Demo.ps1'
        $feedPath = Join-Path $PSScriptRoot 'Fixtures/feed-sample'
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('portfolio-demo-' + [guid]::NewGuid().ToString('N'))
        $auditRoot = Join-Path $tempRoot 'audit'
        $evidenceRoot = Join-Path $tempRoot 'evidence'

        try {
            $result = & $scriptPath -FeedPath $feedPath -AuditOutRoot $auditRoot -EvidenceOutRoot $evidenceRoot -RunId 'demo-test' -PassThru

            Test-Path -LiteralPath $result.DatRun.DatSnippets | Should -BeTrue
            Test-Path -LiteralPath $result.Evidence.ManifestPath | Should -BeTrue
            Test-Path -LiteralPath $result.Evidence.SummaryPath | Should -BeTrue
            Test-Path -LiteralPath $result.Evidence.ZipPath | Should -BeTrue
        }
        finally {
            if (Test-Path -LiteralPath $tempRoot) {
                Remove-Item -LiteralPath $tempRoot -Recurse -Force
            }
        }
    }
}
