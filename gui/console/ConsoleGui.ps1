class ConsoleGui {

    [string]$Name
    [string]$Path
    [Hashtable]$View
    [psobject[]]$Todo

    [bool]_tryParseInteger([string]$Input) {

        $n=0
        $isInteger = [int]::TryParse($Input, [ref]$n)
        return $isInteger
    }
    ConsoleGui ([string]$Path) {
        
        $this.Name = "todo.ps1 (simple gui)"
        $this.Path = $Path
        $this.TodoInit()
        $this.ViewInit()
    }
    [void]TodoInit() {
        $this.Todo = Import-Todo -Path $this.Path
    }
    [void]ViewInit() {

        # Loads all views that are defined in /gui/Console/View
        #TODO Make sure ConsoleView is available before instantiating ConsoleGui

        . $PSScriptRoot/ConsoleView.ps1
        $this.View = @{}
        $viewFiles = Get-ChildItem "$PSScriptRoot/View"
        foreach ($file in $viewFiles) {
            . $file.FullName
            $viewName = $file | Select-Object -ExpandProperty BaseName
            $viewClass = Invoke-Expression "[$viewName]"
            $this.View[$viewName] =  $viewClass::new($this)
        }
    }
    [void]Invoke([psobject]$View) {

        $View.WriteView()
        $userInput = $View.GetUserInput()
        $cmd = $View.GetCommand($userInput)
        if($cmd) {
            $nextView = $cmd.Invoke($userInput)
            $this.Invoke($nextView)
        }
        $View.Notification = "ERROR: Command not implemented '$userInput'"
        $this.Invoke($View)
    }
}
