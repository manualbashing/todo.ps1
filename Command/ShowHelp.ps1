class ShowHelp {
    
    [string]$Pattern
    [string]$Description
    [ConsoleView]$View
    [string]$Name

    ShowHelp([ConsoleView]$View) {
        
        $this.Name = 'ShowHelp'
        $this.Pattern = '^(h|[?]|help|man).*$'
        $this.Description = 'Show this help'
        $this.View = $View
    }
    [ConsoleView]Invoke([string]$Command) {

        return $this.View.Gui.View.Help
    }
}