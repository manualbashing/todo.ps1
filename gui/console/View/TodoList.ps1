class TodoList : ConsoleView {

    [psobject[]]$VisibleTodo

    TodoList([ConsoleGui]$Gui) : base ([ConsoleGui]$Gui){

        $this.VisibleTodo = $Gui.Todo
    }

    #@Override
    [string]ToString() {

        return ($this.VisibleTodo | ConvertTo-TodoString -IncludeLineNumber) -join "`n"
    }
}