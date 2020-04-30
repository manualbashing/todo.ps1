<#
    #TODO indicate unsaved changes in Gui
    #TODO Match by Hash not working
    #TODO Write pester tests
    #TODO Write documentation

    #TODO Implement different sources

    - Code files (Search in "#TODO" commentaries)
    - Github Gists
    - Git Repository (properly commit)

    #TODO Allow syncing with different sources (use Hashes)
    #TODO Implement a backup strategy
    #TODO Allow to create different views
#>
filter getHash {
    <#
        Hashing is used to find duplicate TODOs.

        - A duplicate TODO is the same task that might only defer in irrelevant ways:

            - Different Priority, CreationDate, CompletitionData
            - Difference in case or whitespaces
    #>
    $hasher = New-Object System.Security.Cryptography.SHA1Managed
    $InputString = $_ -replace '\s'
    $InputString = $InputString.toLower()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    $hash = $hasher.ComputeHash($bytes) -join ''
    return $hash
}

filter selectByPattern ($Pattern, $MatchGroup=0) {

    $_ | 
        Select-String -Pattern $Pattern -AllMatches | 
        Select-Object -ExpandProperty Matches |
        Select-Object -ExpandProperty Groups |
        Where-Object Name -eq $MatchGroup | 
        Select-Object -ExpandProperty Value
}

filter assumeUniqueKey ($Dictionary, $PostFix) {
    if ($Dictionary.Keys -contains $key  ) {

        $key = "${key}_$PostFix"
    }
    Write-Output $key
}

filter assumePathExists {

    if (-not (Test-Path $_)) {

        New-Item $_ -Force
    } else {

        Get-Item $_
    }
}
function Import-Todo {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [String]
        $Path
    )
    $Path = (Get-Item $Path).FullName
    Get-Content -Path $Path -Encoding UTF8 | ConvertTo-Todo -SessionData @{Source = $Path }
}

function Export-Todo {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject[]]
        $InputObject,

        [Parameter(Mandatory)]
        [String]
        $Path
    )
    Begin {
        #TODO make path not mandatory. Use DataSession Source if not provided.
        $Path = ($Path | assumePathExists).FullName
        $targetTodos = [System.Collections.ArrayList](Import-Todo -Path $Path)
        if ($null -eq $targetTodos) {

            # The target file does not contain any items yet.
            $targetTodos = [System.Collections.ArrayList]::new()
        }
        <#
        #TODO Implement Confirm if todo already exists
        #>
    }
    Process {

        foreach ($sessTodo in $InputObject) {

            if ($Path -in $sessTodo.SessionData.Source) {
                # Todo has its origin in this file and is on the same line.
                #TODO What if line doesnt exist
                $lineNumberIndex = $sessTodo.SessionData.LineNumber - 1
                $todoAtLineOfOrigin = $targetTodos.Item($lineNumberIndex)
                if ($todoAtLineOfOrigin.SessionData.Hash -eq $sessTodo.SessionData.Hash) {

                    $targetTodos.RemoveAt($lineNumberIndex)
                    $targetTodos.Insert($lineNumberIndex, $sessTodo)
                    continue # next session todo item.
                }
            }

            # Todo has a different origin or is not on the same line anymore.
            $firstTodoMatchedByHash = $targetTodos |
                Where-Object { $_.SessionData.Hash -eq $sessTodo.SessionData.Hash } |
                Select-Object -First 1
            if ($firstTodoMatchedByHash) {

                $lineNumberIndex = $targetTodos.IndexOf($firstTodoMatchedByHash)
                $targetTodos.RemoveAt($lineNumberIndex)
                $targetTodos.Insert($lineNumberIndex, $sessTodo)
                continue # next session todo item.
            }

            #Todo was not found in the file.
            $null = $targetTodos.Add($sessTodo)
        }
    }
    End {
        $targetTodos |
            ConvertTo-TodoString |
            Out-File -Encoding utf8 -FilePath $Path
    }
}

function ConvertTo-TodoString {
    param (
        [Parameter(ValueFromPipeline)]
        [psobject[]]
        $InputObject,

        [switch]
        $IncludeLineNumber
    )
    Begin {
        $ln = 1
    }
    Process {
        foreach ($todo in $InputObject) {
            $result = ''
            if ($IncludeLineNumber.IsPresent) {
                $result = "$ln. "
            }
            if ($todo.Done) {
                $result += 'x '
            }
            if ($todo.CompletitionDate) {
                $result += ($todo.CompletitionDate + " ")
            }
            if ($pri = $todo.Priority) {
                $result += "($pri) "
            }
            if ($todo.CreationDate) {
                $result += ($todo.CreationDate + " ")
            }
            if ($todo.Text) {
                $result += $todo.Text
            }
            Write-Output $result
            $ln = $ln + 1
        }

    }
}

function ConvertTo-Todo {

    [CmdletBinding()]
    param (
        # This parameter cannot be mandatory to deal with blank lines.
        [Parameter(Mandatory = $false, ValueFromPipeline, Position = 0)]
        [String[]]
        $InputObject,

        # Optional attributes, that will be added to all entries in the pipeline
        [Parameter(Mandatory = $false, Position = 1)]
        [System.Collections.IDictionary]
        $Attributes,

        # Optional addional attributes, that will be added to the SessianData property of all entries in the pipeline
        [Parameter(Mandatory = $false, Position = 2)]
        [System.Collections.IDictionary]
        $SessionData

    )
    Begin {
        $i = 1
    }
    Process {

        foreach ($line in $InputObject) {
            <#
                Syntactically incorrect todo items will be matched by <text>. Only if the
                <text> group is empty (that includes blank lines), will the item be skipped.

                # x marks completition with optional date
                # or priority (A) - (Z) (mutually exclusive)

            #>
            $isValidTodoItem = $line -cmatch (
                '^(((?<done>x)( (?<completition>[0-9-]{10}))? )|(\((?<priority>[A-Z])\) ))?' +
                '((?<creation>[0-9-]{10}) )?' +
                '(?<text>.+)$' # All the rest remains unparsed at this stage
            )
            $text = $Matches['text']
            if (-not $isValidTodoItem) {

                $i = $i + 1
                continue
            }

            $todoObjProperties = [ordered]@{
                Priority         = $Matches['priority']
                Text             = $Matches['text']
                Context          = $text | selectByPattern -Pattern ' (@[a-zA-z0-9-_]+)' -MatchGroup 1
                Project          = $text | selectByPattern -Pattern ' (\+[a-zA-z0-9-_]+)' -MatchGroup 1
                Done             = [bool]($Matches['done'])
                CompletitionDate = $Matches['completition']
                CreationDate     = $Matches['creation']
                SessionData      = @{

                    Hash       = $text | getHash
                    LineNumber = $i++
                }
                SpecialKeyValue = @{}
            }
            
            foreach ($key in $Attributes.Keys) {

                $key = $key | assumeUniqueKey -Dictionary $todoObjProperties -PostFix 'attr'
                $todoObjProperties[$key] = $Attributes[$key]
            }

            $specialKeyValuePairs = $text |
                selectByPattern -Pattern '[a-zA-z0-9-_]+:[a-zA-z0-9-_]+'
            if($specialKeyValuePairs) {

                [array]::Reverse($specialKeyValuePairs)
            }
            <#
                The first occurance of a key:value pair should be used,
                if the same key is used more than once.
                Example: due:today due:tomorrow => preserved valie: today
            #>
            foreach ($kvPair in $specialKeyValuePairs) {

                $key, $value = $kvPair -split ':'
                $todoObjProperties.SpecialKeyValue[$key] = $value
            }

            foreach ($key in $SessionData.Keys) {

                $key = $key | assumeUniqueKey -Dictionary $todoObjProperties.SessionData -PostFix 'sd'
                $todoObjProperties.SessionData[$key] = $SessionData[$key]
            }

            [pscustomobject]$todoObjProperties
        }
    }
}

function Add-TodoProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject[]]
        $InputObject,

        [Parameter(Mandatory, Position = 0)]
        [String[]]
        $Project
    )
    Begin {

        $normalizedProjectNames = foreach ($projectName in $Project) {

            if ($projectName -notmatch '^\+') {
                "+$projectName"
            } else {
                $projectName
            }
        }
    }
    Process {

        foreach ($todo in $InputObject) {

            $removableProjects = $normalizedProjectNames |
                Where-Object { $_ -NotIn $todo.Project }
            $todo.Project = @($todo.Project) + @($removableProjects)
            foreach ($removableProjectName in $removableProjects) {

                $todo.Text += " $removableProjectName"
            }
        }
    }
}

function Remove-TodoProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject[]]
        $InputObject,

        [Parameter(Mandatory, Position = 0)]
        [String[]]
        $Project
    )
    Begin {

        $normalizedProjectNames = foreach ($projectName in $Project) {

            if ($projectName -notmatch '^\+') {
                "+$projectName"
            } else {
                $projectName
            }
        }
    }
    Process {

        foreach ($todo in $InputObject) {

            $removableProjects = $normalizedProjectNames |
                Where-Object { $_ -In $todo.Project }
            $todo.Project = $todo.Project | Where-Object { $_ -notin $removableProjects }
            foreach ($removableProjectName in $removableProjects) {

                $todo.Text = $todo.Text -replace [regex]::Escape(" $removableProjectName")
            }
        }
    }
}

function New-ConsoleGui {

    [Cmdletbinding()]
    param(
        $Path = $env:TODOPS1_MASTERFILE,
        $GuiName = 'Console'
    )

    #TODO make sure, Gui class exists.
    . $PSScriptRoot/gui/$GuiName/${GuiName}Gui.ps1
    $gui = Invoke-Expression "[$($GuiName)Gui]::New('$Path')"
    $gui.SetTodos((Import-Todo -Path $Path))
    return $gui
}
function Invoke-ConsoleGuiCommand {

    [Cmdletbinding()]
    param(

        [Parameter(Mandatory=$false,Position=0)]
        [string]
        $Command = 'start',

        [Parameter(Mandatory=$false)]
        [psobject]
        $ConsoleGui = (New-ConsoleGui)
    )
    
    $gui = $ConsoleGui

    switch ($Command) {
        'start' {
            $gui.WriteView($gui.GetView('StartView'))
            $command = $gui.GetUserCommand()
            Invoke-ConsoleGuiCommand -Command $command -ConsoleGui $gui
        }
        { $gui._tryParseInteger($_) } {

            $lineNumber = [int]$_
            $selectedTodo = $gui.Todos[$lineNumber - 1]
            $todoListView = $gui.GetView('TodoListView')
            $gui.WriteView($todoListView.ListTodo($selectedTodo))
            $command = $gui.GetUserCommand()
            Invoke-ConsoleGuiCommand -Command $command -ConsoleGui $gui

        }
        { $_ -in 'la', 'ls', 'listall' } {

            $gui.WriteView($gui.GetView('TodoListView'))
            $command = $gui.GetUserCommand()
            Invoke-ConsoleGuiCommand -Command $command -ConsoleGui $gui
        }
        { $_ -in 'q', 'quit', 'exit' } {

            break
        }
        { $_ -match '^x' } {
            
            $userChoiceQualifier = $Command -replace '^x'
            $lineNumber = 0
            if ([int]::TryParse($userChoiceQualifier, [ref]$lineNumber)) {

                $selectedTodo = $gui.Todos | Where-Object { $_.SessionData.LineNumber -in $LineNumber }

            } else {

                $gui.WriteView($gui.GetView('TodoListView'))
                $gui.WriteNotification("Select the item by its line number")
                $lineNumber = $gui.GetUserSelection()
                $selectedTodo = $gui.Todos | Where-Object { $_.SessionData.LineNumber -in $LineNumber }
            }
            #TODO Keep track of user commands for undo option.
            $selectedTodo.Done = -not $selectedTodo.Done
            $gui.WriteView($gui.GetView('TodoListView'))
            $command = $gui.GetUserCommand()
            Invoke-ConsoleGuiCommand -Command $command -ConsoleGui $gui
        }
        { $_ -in 'h', '?', 'help' } {

            $gui.WriteView($gui.GetView('HelpView'))
            $command = $gui.GetUserCommand()
            Invoke-ConsoleGuiCommand -Command $command -ConsoleGui $gui
        }
        { $_ -in 's', 'save', 'w', 'write' } {

            #TODO Track Views (LastView)
            $gui.Todos | Export-Todo -Path $gui.Path
            $gui.WriteView($gui.GetView('TodoListView'))
            $gui.WriteNotification("Todos written to: $($gui.Path)")
            $command = $gui.GetUserCommand()
            Invoke-ConsoleGuiCommand -Command $command -ConsoleGui $gui
        }
        { $_ -in 'r', 'reload' } {

            $gui.SetTodos((Import-Todo -Path $gui.Path))
            $gui.WriteView($gui.GetView('TodoListView'))
            $gui.WriteNotification("Todos reloaded from: $($gui.Path)")
            $command = $gui.GetUserCommand()
            Invoke-ConsoleGuiCommand -Command $command -ConsoleGui $gui
        }
        Default {

            $gui.WriteView($gui.GetView('TodoListView'))
            $gui.WriteNotification("Invalid choice: $Command. Press 'h' for help")
            $command = $gui.GetUserCommand()
            Invoke-ConsoleGuiCommand -Command $command -ConsoleGui $gui
        }
    }
}

Export-ModuleMember -Function *-*