class ConsoleView {

    [ConsoleGui]$Gui
    [Hashtable]$Command
    [psobject[]]$Todo
    [string]$Notification

    ConsoleView([ConsoleGui]$Gui, [psobject[]]$Todo) { 

        $this.Gui = $Gui
        $this.Command = @{ }
        $this.Todo = $Todo
        $this.Notification = ''
    }

    [void]initCommand([string[]]$CommandNames) {

        # Loads all commands that are defined in /Command
        $commandFiles = Get-ChildItem "$PSScriptRoot/../../Command" | 
            Where-Object BaseName -in $CommandNames
        foreach ($file in $commandFiles) {
            . $file.FullName
            $commandName = $file | Select-Object -ExpandProperty BaseName
            $commandClass = Invoke-Expression "[$commandName]"
            $this.Command[$commandName] = $commandClass::new($this)
        }
    }

}