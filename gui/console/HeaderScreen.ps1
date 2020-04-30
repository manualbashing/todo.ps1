class HeaderScreen {

    [string]$Name
    [string]$Path
    
    HeaderScreen() {
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