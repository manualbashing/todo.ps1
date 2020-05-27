class Help : ConsoleView {
    [ConsoleGui]$Gui
    [psobject[]]$Todo

    Help([ConsoleGui]$Gui, [psobject[]]$Todo) : base ([ConsoleGui]$Gui, [psobject[]]$Todo) {

        $this.initCommand(@(
            'ListTodo',
            'WriteFile'
        ))
    }

    #@Override
    [string]ToString() {
        #TODO Build dynamically from available commands.
        return @"
    la, ls, listall    List all
    x[LineNumber]      Toggle Done
    s, w, save, write  Write todos back to source
    r, reload          Reload todos from source file
    h, ?, help         Help
    start              Show start View
    q, quit, exit      Quit
"@
    }
}