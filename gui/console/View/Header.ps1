class Header : ConsoleView {

    [string]$Name
    [string]$Path
    [ConsoleGui]$Gui
    
    Header([ConsoleGui]$Gui) : base ([ConsoleGui]$Gui) {

        $this.Path = ''
        $this.Name = 'todo.ps1 simple gui'
    }
    #@Override
    [string]ToString() {
        
        return @"
    `n
    Gui: $($this.Name)
    Source: $($this.Path)
    `n
"@
    }
    [void]SetPath($Path) {
        
        $this.Path = $Path
    }
}