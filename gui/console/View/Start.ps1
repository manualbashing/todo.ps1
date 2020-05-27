class Start : ConsoleView {

    [ConsoleGui]$Gui
    [Hashtable]$Command
    [psobject[]]$Todo

    Start([ConsoleGui]$Gui, [psobject[]]$Todo) : base ([ConsoleGui]$Gui, [psobject[]]$Todo){ 

        $this.initCommand(@(
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