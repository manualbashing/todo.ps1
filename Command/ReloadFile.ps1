class ReloadFile {
    
    [string]$Pattern
    [string]$Description
    [ConsoleView]$View
    [string]$Name

    ReloadFile([ConsoleView]$View) {
        
        $this.Name = 'ReloadFile'
        $this.Pattern = '^(r|reload).*$'
        $this.Description = 'Discard all changes and read todos again from source files.'
        $this.View = $View
    }
    [ConsoleView]Invoke([string]$Command) {

        $sourcePath = $this.View.Gui.Path
        $todos = Import-Todo -Path $sourcePath
        $this.View.Gui.Todo = $todos
        $this.View.Gui.View.TodoList.VisibleTodo = $todos
        $this.View.Notification = "Reloaded todos from $sourcePath"
        return $this.View
    }
}