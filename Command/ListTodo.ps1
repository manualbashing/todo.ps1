class ListTodo {
    
    [string]$Name
    [string]$Pattern
    [string]$Description
    [ConsoleView]$View

    ListTodo([ConsoleView]$View) {

        $this.Name = 'ListTodo'
        $this.Pattern = '^(l|ls|list) *(?<lineNumberPattern>[0-9-,]*)$'
        $this.Description = 'List all todos. Specify line number pattern to narrow down the list.'
        $this.View = $View
    }

    [ConsoleView]Invoke() {

        return $this.Invoke('')
    }
    [ConsoleView]Invoke([string]$Command) {

        
        $lineNumberPattern = "1-$($this.View.Gui.Todo.Count)"
        if(($Command -match $this.Pattern) -and $Matches['LineNumberPattern']) {
            
            $lineNumberPattern = $Matches['LineNumberPattern']
        }
        $this.View.Gui.View.TodoList.VisibleTodo = $this.View.Gui.Todo |
            Select-Todo -LineNumberPattern:$lineNumberPattern

        return $this.View.Gui.View.TodoList
    }
}