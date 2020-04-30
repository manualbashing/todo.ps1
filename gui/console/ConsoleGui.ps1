class ConsoleGui {

    [string]$Name
    [string]$Path
    [psobject[]]$Todos
    [Hashtable]$ViewMap
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
        $this.LoadViewMap()
        $this.ViewMap['HeaderView'].SetPath($this.Path)
        $this.ImportTodos($this.Path)
    }
    [void]LoadViewMap() {

        # Loads all views that are defined in /gui/Console
        $this.ViewMap = @{}
        $viewFiles = (Get-ChildItem $PSScriptRoot | Where-Object BaseName -match 'View$')
        foreach ($file in $viewFiles) {
            . $file.FullName
            $viewName = $file | Select-Object -ExpandProperty BaseName
            $view = Invoke-Expression "[$viewName]"
            $this.ViewMap[$viewName] =  $view::new($this)
        }
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
    [psobject]GetView($ViewName) {
        #TODO Test if View name exists.
        return $this.ViewMap[$ViewName]
    }
    [void]WriteView([psobject]$View) {
        
        Clear-Host
        Write-Host $this.ViewMap['HeaderView']
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

            $this.WriteView($this.GetView('TodoListView'))
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
