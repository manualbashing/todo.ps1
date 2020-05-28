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

        # Loads all views that are defined in /gui/Console/View
        #TODO Make sure ConsoleView is available before instantiating ConsoleGui

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
        Write-Host "
---------------------------------
$($this.Name)
$($this.Path)
---------------------------------

$View
        
    $($View.Notification)
"
    }

    [string]GetUserCommand([psobject]$View) {

        $userCommand = (Read-Host -Prompt "`nTODO>")

        foreach ($cmdKey in  $View.Command.Keys) {

            if ($userCommand -match $View.Command[$cmdKey].Pattern) {
                return $userCommand
            }
        }
        $View.Notification = "'$userCommand' is not a valid command in this view."
        $this.WriteView($View)
        return $this.GetUserCommand($View)
    }

    [int]GetUserSelection([psobject]$View) {

        $selection = Read-Host -Prompt "SELECT>"
        $inputIsValid = $this._tryParseInteger($selection)
        
        if ($inputIsValid -and [int]$selection -le $View.Todo.Count) {

            return [int]$selection

        } else {

            $View.Notification = "Not a valid selection: $selection"
            $this.WriteView($View)
            return $this.GetUserSelection($View)
            #TODO implement "cancel operation"
            #TODO allow range pattern
        }
    }
}
