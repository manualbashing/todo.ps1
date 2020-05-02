class SelectCommand {
    
    [string]$Pattern
    [string]$Description = 'Narrow down the list of todo items.'
    [ConsoleGui]$Gui

    SelectCommand([ConsoleGui]$Gui) {

        $this.Pattern = '^s(elect)? *(?<lineNumberPattern>[0-9-,]*)$'
        $this.Description = 'Narrow down the list of todo items.'
        $this.Gui = $Gui
    }

    [psobject]Invoke([string]$Command) {

        $null = $Command -match $this.Pattern
        $lineNumberPattern = $Matches['LineNumberPattern']
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
        
        return $this.Gui.View.TodoListView.ListTodo($selectedTodos)
    }
}