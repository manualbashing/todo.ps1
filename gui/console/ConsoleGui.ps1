class ConsoleGui {

    [string]$Name
    [string]$Path
    [psobject[]]$Todos
    [Hashtable]$View
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
        $this.LoadViews("$PSScriptRoot")
        $this.View['HeaderView'].SetPath($this.Path)
        $this.ImportTodos($this.Path)
    }
    [void]LoadViews([string]$ViewPath) {

        $ViewTable = @{ }
        $ViewFiles = (Get-ChildItem $ViewPath | Where-Object BaseName -like "*View")
        foreach ($file in $ViewFiles) {
            . $file.FullName
            $ViewName = $file | Select-Object -ExpandProperty BaseName
            $ViewTable[$ViewName] = Invoke-Expression "[$ViewName]::new()"
        }
        $this.View = $ViewTable
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
    [psobject]GetGuiView($ViewName) {
        #TODO Test if View name exists.
        return $this.View[$ViewName]
    }
    [string]GetTodoList() {

        return (($this.Todos | ConvertTo-TodoString -IncludeLineNumber) -join "`n")
    }
    [string]GetTodoList([psobject]$CustomTodoList) {
        #TODO allow multiple entries
        return (($CustomTodoList | ConvertTo-TodoString -IncludeLineNumber) -join "`n")
    }
    [void]WriteView([psobject]$View) {
        
        Clear-Host
        Write-Host $this.View['HeaderView']
        Write-Host $View
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

            $this.WriteView($this.GetTodoList())
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
