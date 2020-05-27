class TodoList : ConsoleView {

    [ConsoleGui]$Gui

    TodoList([ConsoleGui]$Gui) : base ([ConsoleGui]$Gui){

    }

    [string]ListTodo([psobject[]]$TodoList) {
        
        return (($TodoList | ConvertTo-TodoString -IncludeLineNumber) -join "`n")
    }
    #@Override
    [string]ToString() {
        
        return $this.ListTodo($this.Gui.Todos)
    }
}