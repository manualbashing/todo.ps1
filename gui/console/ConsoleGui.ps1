class ConsoleGui {

    [string]$Name
    [string]$Path
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

    }
    [void]ViewInit() {

        # Loads all views that are defined in /gui/Console
        # TODO move to subfolder
        
        . $PSScriptRoot/ConsoleView.ps1
        $todos = Import-Todo -Path $this.Path
        $this.View = @{}
        $viewFiles = Get-ChildItem "$PSScriptRoot/View"
        foreach ($file in $viewFiles) {
            . $file.FullName
            $viewName = $file | Select-Object -ExpandProperty BaseName
            $viewClass = Invoke-Expression "[$viewName]"
            $this.View[$viewName] =  $viewClass::new($this, $todos)
        }
    }
    [void]WriteView([psobject]$View) {
        
        Clear-Host
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
