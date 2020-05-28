class TodoList : ConsoleView {

    [ConsoleGui]$Gui
    [psobject[]]$Todo

    TodoList([ConsoleGui]$Gui, [psobject[]]$Todo) : base ([ConsoleGui]$Gui, [psobject[]]$Todo){

        $this.initCommand(@(
            'ListTodo',
            'WriteFile'
        ))
    }

    #@Override
    [string]ToString() {

        return ($this.Todo | ConvertTo-TodoString -IncludeLineNumber) -join "`n"
    }
}