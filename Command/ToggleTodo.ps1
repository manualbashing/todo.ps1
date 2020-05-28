class ToggleTodo {
    
    [string]$Pattern
    [string]$Description
    [ConsoleView]$View
    [string]$Name

    ToggleTodo([ConsoleView]$View) {
        
        $this.Name = 'ToggleTodo'
        $this.Pattern = '^x *(?<lineNumberPattern>[0-9-,]*)$'
        $this.Description = 'Toggle the "done" state of one or more todos'
        $this.View = $View
    }
    [ConsoleView]Invoke([string]$Command) {

        $lineNumberPattern = '1'
        if(($Command -match $this.Pattern) -and $Matches['LineNumberPattern']) {
            
            $lineNumberPattern = $Matches['LineNumberPattern']
        }
        $this.View.Gui.Todo |
            Select-Todo -LineNumberPattern:$lineNumberPattern |
            ForEach-Object { $_.Done = -not $_.Done}

        return $this.View.Gui.View.TodoList
    }
}