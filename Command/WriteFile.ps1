class WriteFile {
    
    [string]$Pattern
    [string]$Description
    [ConsoleView]$View
    [string]$Name

    WriteFile([ConsoleView]$View) {
        
        $this.Name = 'WriteFile'
        $this.Pattern = '^(w|s|write|save).*$'
        $this.Description = 'Write all changes back to the todo.txt source file.'
        $this.View = $View
    }
    [ConsoleView]Invoke([string]$Command) {

        $outPath = $this.View.Gui.Path
        $this.View.Gui.Todo | Export-Todo -Path $outPath
        # TODO Use actual source from SessionData
        $this.View.Notification = "Wrote current todos to $outPath"
        return $this.View
    }
}