class Start {

    [ConsoleGui]$Gui

    Start([ConsoleGui]$Gui) { 

        $this.Gui = $Gui
    }

    #@Override
    [string]ToString() {
        return @"
    Press "h" for help
"@
    }
}