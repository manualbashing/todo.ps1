class ConsoleGui {

    [string]$Name
    [string]$Path
    [psobject[]]$Todos
    [Hashtable]$View
    [Hashtable]$Command

    [bool]_tryParseInteger([string]$Input) {

        $n=0
        $isInteger = [int]::TryParse($Input, [ref]$n)
        return $isInteger
    }
    ConsoleGui ([string]$Path) {
        
        $this.Name = "todo.ps1 simple gui"
        $this.Path = $Path
        $this.ViewInit()
        $this.View.Header.SetPath($this.Path)
        $this.CommandInit()
    }
    [void]ViewInit() {

        # Loads all views that are defined in /gui/Console
        # TODO move to subfolder
        $this.View = @{}
        $viewFiles = Get-ChildItem "$PSScriptRoot/View"
        foreach ($file in $viewFiles) {
            . $file.FullName
            $viewName = $file | Select-Object -ExpandProperty BaseName
            $viewClass = Invoke-Expression "[$viewName]"
            $this.View[$viewName] =  $viewClass::new($this)
        }
    }
    [void]CommandInit() {

        #TODO Deduplicate code with ViewInit
        # Loads all commands that are defined in /Command
        $this.Command = @{}
        $commandFiles = Get-ChildItem "$PSScriptRoot/../../Command"
        foreach ($file in $commandFiles) {
            . $file.FullName
            $commandName = $file | Select-Object -ExpandProperty BaseName
            $commandClass = Invoke-Expression "[$commandName]"
            $this.Command[$commandName] =  $commandClass::new($this)
        }
    }
    [void]SetTodos([psobject[]]$Todos) {

        $this.Todos = $Todos
    }
    [void]WriteView([psobject]$View) {
        
        Clear-Host
        Write-Host $this.View['Header']
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

            $this.WriteView($this.View.TodoList)
            $this.WriteNotification("Not a valid selection: $selection")
            return ($this.GetUserSelection())
        } else {
            #TODO implement "cancel operation"
            return [int]$selection
        }
    }
}
