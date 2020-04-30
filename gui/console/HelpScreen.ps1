class HelpScreen {

    HelpScreen() { 
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
    q, quit, exit      Quit
"@
    }
}