Describe 'Teams Tenant Dial Plan - Monaco normalization rules' {
    It 'keeps E.164 numbers unchanged' {
        $pattern = '^\+\d+$'
        '+33612345678' | Should -Match $pattern
    }

    It 'normalizes Monaco national 8-digit numbers to +377' {
        $pattern = '^(\d{8})$'
        $inputValue = '12345678'
        $inputValue | Should -Match $pattern
        $output = ($inputValue -replace $pattern, '+377$1')
        $output | Should -Be '+37712345678'
    }

    It 'normalizes FR mobiles 06/07XXXXXXXX to +33' {
        $pattern = '^0([67]\d{8})$'
        $inputValue = '0612345678'
        $inputValue | Should -Match $pattern
        $output = ($inputValue -replace $pattern, '+33$1')
        $output | Should -Be '+33612345678'
    }
}
