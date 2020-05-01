class ConsoleGui {

    [string]$Name
    [string]$Path
    [psobject[]]$Todos
    [Hashtable]$ViewMap
    [Hashtable]$CommandMap
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
        $this.LoadCommandMap()
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
    [void]LoadCommandMap() {

        #TODO Deduplicate code with LoadViewMap
        # Loads all commands that are defined in /command
        $this.CommandMap = @{}
        $commandFiles = (Get-ChildItem "$PSScriptRoot/../../command" | Where-Object BaseName -match 'Command$')
        foreach ($file in $commandFiles) {
            . $file.FullName
            $commandName = $file | Select-Object -ExpandProperty BaseName
            $command = Invoke-Expression "[$commandName]"
            $this.CommandMap[$commandName] =  $command::new($this)
        }
    }
    [void]SetTodos([psobject[]]$Todos) {

        $this.Todos = $Todos
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
    [psobject]GetCommand($CommandName) {
        #TODO Test if Command name exists.
        return $this.CommandMap[$CommandName]
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
}
