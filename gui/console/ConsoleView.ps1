class ConsoleView {

    [ConsoleGui]$Gui
    [Hashtable]$Command
    [string]$Notification

    ConsoleView([ConsoleGui]$Gui) { 

        $this.Gui = $Gui
        $this.Notification = ''
        $this.Command = @{}

        $this.initCommand(@(
            'ListTodo',
            'ReloadFile',
            'WriteFile',
            'ExitGui',
            'ShowHelp',
            'ToggleTodo'
            
        ))
    }

    [void]InitCommand([string[]]$CommandNames) {

        # Loads all commands that are defined in /Command
        $commandFiles = Get-ChildItem "$PSScriptRoot/../../Command" | 
            Where-Object BaseName -in $CommandNames
        foreach ($file in $commandFiles) {
            . $file.FullName
            $commandName = $file | Select-Object -ExpandProperty BaseName
            $commandClass = Invoke-Expression "[$commandName]"
            $this.Command[$commandName] = $commandClass::new($this)
        }
    }

    [void]WriteView() {
        
        Clear-Host
        Write-Host @"
---------------------------------
$($this.Gui.Name)
$($this.Gui.Path)
---------------------------------

$this
        
    $($this.Notification)
"@
        $this.Notification = '' # Notifications should only show up once.
    }
    [string]GetUserInput() {

        $userInput = (Read-Host -Prompt "`nTODO>")
        while ($this.GetCommand($userInput) -eq '') {

            $this.Notification = "'$userInput' is not a valid command in this view."
            $this.WriteView()
            $userInput = (Read-Host -Prompt "`nTODO>")
        }
        $this.Notification = ''
        $this.WriteView()
        return $userInput

    }
    [psobject]GetCommand([string]$UserInput) {

        foreach ($cmdKey in  $this.Command.Keys) {
            if ($UserInput -match $this.Command[$cmdKey].Pattern) {
                return $this.Command[$cmdKey]
            }
        }
        return $null
    }
    [int]GetUserSelection() {

        $selection = Read-Host -Prompt "SELECT>"
        $inputIsValid = $this.Gui._tryParseInteger($selection)
        
        if ($inputIsValid -and [int]$selection -le $this.Gui.Todo.Count) {

            return [int]$selection

        } else {

            $this.Notification = "Not a valid selection: $selection"
            $this.WriteView()
            return $this.GetUserSelection()
            #TODO implement "cancel operation"
            #TODO allow range pattern
        }
    }
}