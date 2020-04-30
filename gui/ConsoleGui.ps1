class ConsoleGui {

    [string]$Name
    [string]$Path
    [psobject[]]$Todos
    [Hashtable]$Screen
    <#
        TODO: Define commands in a dynamical way

        @{
            'write' = {
                $this.Todos | Export-Todo -Path $Path
            }

        }
        This way it will be more easy to extend existing commands. And the methods
        in this class can be reduced.
    #>
    [bool]_tryParseInteger([string]$Input) {

        $n=0
        $isInteger = [int]::TryParse($Input, [ref]$n)
        return $isInteger
    }
    ConsoleGui ([string]$Path) {
        
        $this.Name = "todo.ps1 simple gui"
        $this.Path = $Path
        $this.LoadScreens("$PSScriptRoot\console")
        $this.Screen['HeaderScreen'].SetPath($this.Path)
        $this.ImportTodos($this.Path)
    }
    [void]LoadScreens([string]$ScreenPath) {

        $screenTable = @{ }
        foreach ($screenFile in (Get-ChildItem $ScreenPath)) {
            . $screenFile.FullName
            $screenName = $screenFile | Select-Object -ExpandProperty BaseName
            $screenTable[$screenName] = Invoke-Expression "[$screenName]::new()"
        }
        $this.Screen = $screenTable
    }
    [void]ExportTodos() {

        $this.ExportTodos($this.Path)
    }
    [void]ExportTodos([string]$Path) {

        $this.Todos | Export-Todo -Path $Path
    }
    [psobject[]]ImportTodos() {

        return ($this.ImportTodos($this.Path))
    }
    [void]ImportTodos([string]$Path) {

        $this.Todos = Import-Todo -Path $Path
    }
    [psobject]GetGuiScreen($ScreenName) {
        #TODO Test if screen name exists.
        return $this.Screen[$ScreenName]
    }
    [string]GetTodoList() {

        return (($this.Todos | ConvertTo-TodoString -IncludeLineNumber) -join "`n")
    }
    [string]GetTodoList([psobject]$CustomTodoList) {
        #TODO allow multiple entries
        return (($CustomTodoList | ConvertTo-TodoString -IncludeLineNumber) -join "`n")
    }
    [void]WriteScreen([psobject]$Screen) {
        
        Clear-Host
        Write-Host $this.Screen['HeaderScreen']
        Write-Host $Screen
    }
    [void]WriteNotification([string]$Message) {
        
        Write-Host "`n    $Message`n"
    }
    [string]GetUserCommand() {

        return (Read-Host -Prompt "`nTODO>")
    }
    [int]GetUserSelection() {

        $selection = Read-Host -Prompt "SELECT>"
        $inputIsValid = $this._tryParseInteger($selection)
        if (-not $inputIsValid) {

            $this.WriteScreen($this.GetTodoList())
            $this.WriteNotification("Not a valid selection: $selection")
            return ($this.GetUserSelection())
        } else {
            #TODO implement "cancel operation"
            return [int]$selection
        }
    }
    [psobject]SelectTodo([int]$LineNumber) {

        #TODO allow selection of multiple items
        #TODO Handle index out of range
        $selectedTodo = $this.Todos[$LineNumber - 1]

        return $selectedTodo
    }
}
