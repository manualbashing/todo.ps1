class HeaderView {

    [string]$Name
    [string]$Path
    [ConsoleGui]$Gui
    
    HeaderView([ConsoleGui]$Gui) {

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