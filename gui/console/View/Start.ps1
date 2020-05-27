class Start : ConsoleView {

    [ConsoleGui]$Gui
    [Hashtable]$Command

    Start([ConsoleGui]$Gui) : base ([ConsoleGui]$Gui){ 

        $this.setCommand(@(
            'ListTodo',
            'WriteFile'
        ))
    }

    #@Override
    [string]ToString() {
        return @"
    Press "h" for help
"@
    }
}