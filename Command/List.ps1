class List {
    
    [string]$Pattern
    [string]$Description
    [ConsoleGui]$Gui

    List([ConsoleGui]$Gui) {

        $this.Pattern = '^(l|ls|list) *(?<lineNumberPattern>[0-9-,]*)$'
        $this.Description = 'List all todos. Specify line number pattern to narrow down the list.'
        $this.Gui = $Gui
    }

    [psobject]Invoke([string]$Command) {

        $null = $Command -match $this.Pattern
        $lineNumberPattern = $Matches['LineNumberPattern']
        if($lineNumberPattern) {

            [int[]]$lineNumbers = @()
            # We ignore whitespaces in the pattern.
            $lineNumberPattern = $lineNumberPattern -replace ' '
            foreach ($pattern in ($lineNumberPattern -split ',')) {

                switch ($pattern) {

                    { $_ -match '^[1-9][0-9]*$' } { 

                        # Individual Number >0
                        $lineNumbers += $pattern

                    }
                    { $_ -match '^[1-9][0-9]*-[1-9][0-9]*$' } {

                        # Range expression 1-5 => 1,2,3,4,5
                        $start,$end = $pattern -split '-'
                        $lineNumbers += $start..$end

                    }
                    Default {
                        # If pattern is invalid, nothing is returned.
                    }
                }
            }
            $selectedTodos = $this.Gui.Todos | 
                Where-Object { $_.SessionData.LineNumber -in $lineNumbers }
        }
        else {
            $selectedTodos = $this.Gui.Todos
        }
        return $this.Gui.View.TodoList.ListTodo($selectedTodos)
    }
}