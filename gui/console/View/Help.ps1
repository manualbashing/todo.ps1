class Help : ConsoleView {

    Help([ConsoleGui]$Gui) : base ([ConsoleGui]$Gui) {

    }

    #@Override
    [string]ToString() {
        
        $helpString = $this.Command.Keys | 
            ForEach-Object { $this.Command[$_] | Select-Object Name,Pattern,Description } |
            Format-Table -AutoSize | 
            Out-String

        return $helpString
    }
}