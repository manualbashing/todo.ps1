class WriteFile {
    
    [string]$Pattern
    [string]$Description
    [ConsoleView]$View

    WriteFile([ConsoleView]$View) {
        $this.Pattern = '^(w|s|write|save).*$'
        $this.Description = 'Write all changes back to the todo.txt source file.'
        $this.View = $View
    }
    [psobject]Invoke([string]$Command) {

        $this.View.Todo | Export-Todo -Path $this.View.Gui.Path
        # TODO return last view.
        # TODO Use actual source from SessionData
        # TOOD Add notification
        return $this.View
    }
}