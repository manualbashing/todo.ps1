class WriteFile {
    
    [string]$Pattern
    [string]$Description
    [ConsoleGui]$Gui

    WriteFile([ConsoleGui]$Gui) {
        $this.Pattern = '^(w|s|write|save).*$'
        $this.Description = 'Write all changes back to the todo.txt source file.'
        $this.Gui = $Gui
    }
    [psobject]Invoke([string]$Command) {

        $this.Gui.Todos | Export-Todo -Path $this.Gui.Path
        # TODO return last view.
        # TODO Use actual source from SessionData
        # TOOD Add notification
        return $this.Gui.View.TodoList
    }
}