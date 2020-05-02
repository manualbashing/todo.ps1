class StartView {

    [ConsoleGui]$Gui

    StartView([ConsoleGui]$Gui) { 

        $this.Gui = $Gui
    }

    #@Override
    [string]ToString() {
        return @"
    Press "h" for help
"@
    }
}