class Header {

    [string]$Name
    [string]$Path
    [ConsoleGui]$Gui
    
    Header([ConsoleGui]$Gui) {

        $this.Path = ''
        $this.Name = 'todo.ps1 simple gui'
        $this.Gui = $Gui
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