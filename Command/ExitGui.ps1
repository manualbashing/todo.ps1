class ExitGui {
    
    [string]$Pattern
    [string]$Description
    [ConsoleView]$View
    [string]$Name

    ExitGui([ConsoleView]$View) {
        
        $this.Name = 'ExitGui'
        $this.Pattern = '^(exit|q|quit).*$'
        $this.Description = 'Exit todo gui and return to prompt.'
        $this.View = $View
    }
    [ConsoleView]Invoke([string]$Command) {

        break    
    }
}