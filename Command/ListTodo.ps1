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

    [void]Invoke() {

        $this.Invoke('')
    }
    [void]Invoke([string]$Command) {

        if(($Command -match $this.Pattern) -and $Matches['LineNumberPattern']) {
            
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
            $selectedTodos = $this.View.Todo | 
                Where-Object { $_.SessionData.LineNumber -in $lineNumbers }
        }
        else {
            $selectedTodos = $this.View.Todo
        }
        $this.View.Todo = $selectedTodos
    }
}