class ConsoleView {

    [ConsoleGui]$Gui
    [Hashtable]$Command

    ConsoleView([ConsoleGui]$Gui) { 

        $this.Gui = $Gui
        $this.Command = @{}
    }

    [void]setCommand([string[]]$CommandNames) {

        foreach ($name in $CommandNames) {
            $this.Command[$name] = $this.Gui.Command[$name]
        }
    }
}