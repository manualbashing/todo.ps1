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
    It 'sets an entry starting with (Z) as "priority Z"' {
        '(Z) Call customer' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Priority | 
            Should Be 'Z'
    }
    It 'does not set the priority of an entry starting with (a)' {
        '(a) Call customer' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Priority | 
            Should BeNullOrEmpty
    }
    It 'sets a datestamp after leading x as the completition date' {
        'x 2020-01-01 Call customer' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty CompletitionDate | 
            Should Be '2020-01-01'
    }
    It 'sets a datestamp after completition date as the creation date' {
        'x 2020-01-02 2020-01-01 Call customer' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty CreationDate | 
            Should Be '2020-01-01'
    }
    It 'does not allow a creation or completition date anywhere else' {
        $result = '(A) Some random date 2020-01-01 that should not be parsed' | 
            ConvertTo-Todo
            $result.CreationDate + $result.CompletitionDate | 
            Should BeNullOrEmpty
    }
    It 'parses a +Project as project' {
        'Start the important +Project' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Project | 
            Should Be '+Project'
    }
    It 'does not parse 1+1 as project' {
        'Figure out the result of 1+1' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Project | 
            Should BeNullOrEmpty
    }
    It 'parses a multiple projects in a string' {
        'Start the important +Project and +Project2 ' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Project | 
            Should Be @('+Project','+Project2')
    }
    It 'parses a @Context as context' {
        'Do something in this @Context' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Context | 
            Should Be '@Context'
    }
    It 'does not me@mail.com as context' {
        'Write a mail to me@mail.com' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Context | 
            Should BeNullOrEmpty
    }
    It 'parses a multiple contexts in a string' {
        'Start the important things @Home @Computer' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty Context | 
            Should Be @('@Home','@Computer')
    }
    It 'adds an additonal attribute for a single key:value expression in the string' {
        $result = 'Start the important things due:today' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty SpecialKeyValue
        $result['due'] |
            Should Be 'today'
    }
    It 'adds additonal attributes for multiple key:value expressions in the string' {
        $result = 'Start the important things due:tomorrow start:today' | 
            ConvertTo-Todo |
            Select-Object -ExpandProperty SpecialKeyValue
        $result['due'],$result['start']  | 
            Should Be @('tomorrow','today')
    }
    It 'should add key:value only once, if it appears multiple times' {
        $result ='Start the important things due:today due:tomorrow' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty SpecialKeyValue
            $result['due'] |
                Should Be 'today'
    }
    It 'does not add a attribute for every colon' {
        $result = 'Start the important things: buy beer' | 
            ConvertTo-Todo | 
            Select-Object -ExpandProperty SpecialKeyValue
        $result.Keys -contains 'things' | 
            Should Be $false
    }
    It 'does not accept key::value expressions with double colons' {
        $result = 'Start the important things due::today' | 
            ConvertTo-Todo |
            Select-Object -ExpandProperty SpecialKeyValue
        $result.Keys -contains 'due' | 
            Should Be $false
    }
}

