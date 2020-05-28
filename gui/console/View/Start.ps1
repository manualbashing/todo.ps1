class Start : ConsoleView {

    Start([ConsoleGui]$Gui) : base ([ConsoleGui]$Gui){ 

    }

    #@Override
    [string]ToString() {
        return @"

Welcome to todo.ps1

Press "h" for help
"@
    }
}