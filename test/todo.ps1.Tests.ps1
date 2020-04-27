$ModuleManifestPath = "$PSScriptRoot\..\todo.ps1.psd1"

Import-Module "$PSScriptRoot\..\todo.ps1.psm1"
Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

Describe 'ConvertTo-Todo' {
    It 'sets an entry starting with x as "done"' {
        'x this work is done' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Done | 
            Should Be $true
    }
    It 'sets an entry not starting with x as "not done"' {
        'this work is not done' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Done | 
            Should Be $false
    }
    It 'sets an entry starting with capial X as "not done"' {
        'X this work is not done' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Done | 
            Should Be $false
    }
    It 'sets an entry not starting with x as "not done" if the first word starts with x' {
        'x-Files rewatch' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Done | 
            Should Be $false
    }
    It 'sets an entry starting with (A) as "priority A"' {
        '(A) Call customer' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Priority | 
            Should Be 'A'
    }
    It 'does not set the priority of an entry starting with (a)' {
        '(a) Call customer' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Priority | 
            Should BeNullOrEmpty
    }
}

