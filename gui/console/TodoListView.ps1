class TodoListView {

    [ConsoleGui]$Gui

    TodoListView([ConsoleGui]$Gui) {

        $this.Gui = $Gui
    }

    [string]ListTodo([psobject[]]$TodoList) {
        
        return (($TodoList | ConvertTo-TodoString -IncludeLineNumber) -join "`n")
    }
    #@Override
    [string]ToString() {
        
        return $this.ListTodo($this.Gui.Todos)
    }
}