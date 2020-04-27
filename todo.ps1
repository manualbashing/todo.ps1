<#
    #TODO Implement different sources

    - Code files (Search in "#TODO" commentaries)
    - Github Gists
    - Git Repository (properly commit)

    #TODO Allow syncing with different sources (use Hashes)
    #TODO Implement a backup strategy
    #TODO Allow to create different views
#>
filter getHash {
    <#
        Hashing is used to find duplicate TODOs.
        
        - A duplicate TODO is the same task that might only defer in irrelevant ways:
            
            - Different Priority, CreationDate, CompletitionData
            - Difference in case or whitespaces
    #>
    $hasher = New-Object System.Security.Cryptography.SHA1Managed
    $InputString = $_ -replace '\s'
    $InputString = $InputString.toLower()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString) 
    $hash = $hasher.ComputeHash($bytes) -join '' 
    return $hash
}

filter selectByPattern ($Pattern) {
    $_ | Select-String -Pattern $Pattern -AllMatches | 
    ForEach-Object { $_.Matches.Value }
}

filter assumeUniqueKey ($Dictionary, $PostFix) {
    if ($Dictionary.Keys -contains $key  ) {

        $key = "${key}_$PostFix"
    }
    Write-Output $key
} 

function Import-Todo {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [String]
        $Path
    )
    $Path = (Get-Item $Path).FullName
    Get-Content -Path $Path -Encoding UTF8 | ConvertTo-Todo -SessionData @{Source = $Path }
}

function Export-Todo {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject[]]
        $InputObject,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [String]
        $Path
    )
    <#
    #TODO Implement Confirm if todo already exists
    #>

    $sessionTodos = $InputObject
    $existingTodos = Import-Todo -Path $Path
    $existingHashes = $existingTodos.SessionData.Hash
    foreach ($sessTodo in $sessionTodos) {

        if ($sessTodo.SessionData.Hash -in $existingHashes) {
            #TODO Test for line number too.
            Write-Verbose "Todo $($sessTodo.Text) already exists in target file. Will update. "
        }

    }

    <#
    [X] Read all todos from source
    [ ] If target equals source, check if the item on the same line matches.
        If not, check if the hash is found elsewhere in the file and update there
        If not then merely append
    [ ] If target is different from source, look straight for the hash and update there.
    [ ] Anytime an update happens, the updated entry should be moved to some backup file

    #>
}

function ConvertTo-Todo {

    [CmdletBinding()]
    param (
        # This parameter cannot be mandatory to deal with blank lines.
        [Parameter(Mandatory=$false, ValueFromPipeline, Position = 0)]
        [String[]]
        $InputObject,

        # Optional attributes, that will be added to all entries in the pipeline
        [Parameter(Mandatory = $false, Position = 1)]
        [System.Collections.IDictionary]
        $Attributes,

        # Optional addional attributes, that will be added to the SessianData property of all entries in the pipeline
        [Parameter(Mandatory = $false, Position = 2)]
        [System.Collections.IDictionary]
        $SessionData

    )
    Begin {
        $i = 1
    }
    Process {

        foreach ($line in $InputObject) {
            <#
                Syntactically incorrect todo items will be matched by <text>. Only if the
                <text> group is empty (that includes blank lines), will the item be skipped.

                # x marks completition with optional date
                # or priority (A) - (Z) (mutually exclusive)

            #>
            $isValidTodoItem = $line -match (
                '^(((?<done>x)( (?<completition>[0-9-]{10}))? )|(\((?<priority>[A-Z])\) ))?' + 
                '(?<creation>[0-9-]{10})?' + 
                '(?<text>.+)$' # All the rest remains unparsed at this stage
            )
            $text = $Matches['text']
            if (-not $isValidTodoItem) {

                $i = $i+1
                continue
            }

            $todoObjProperties = [ordered]@{
                Priority         = $Matches['priority']
                Text             = $Matches['text']
                Context          = $text | selectByPattern -Pattern '@[a-zA-z0-9-_]+'
                Project          = $text | selectByPattern -Pattern '\+[a-zA-z0-9-_]+'
                Done             = [bool]($Matches['done'])
                CompletitionDate = $Matches['completition']
                CreationDate     = $Matches['creation']
                SessionData      = @{

                    Hash       = $text | getHash
                    LineNumber = $i++
                }
            }

            foreach ($key in $Attributes.Keys) {

                $key = $key | assumeUniqueKey -Dictionary $todoObjProperties -PostFix 'attr'
                $todoObjProperties[$key] = $Attributes[$key]
            }

            $specialKeyValuePairs = $text | 
                selectByPattern -Pattern '[a-zA-z0-9-_]+:[a-zA-z0-9-_]+'
            foreach ($kvPair in $specialKeyValuePairs) {

                $key, $value = $kvPair -split ':'
                $key = $key | assumeUniqueKey -Dictionary $todoObjProperties -PostFix 'kv'
                $todoObjProperties[$key] = $value
            }

            foreach ($key in $SessionData.Keys) {

                $key = $key | assumeUniqueKey -Dictionary $todoObjProperties.SessionData -PostFix 'sd'
                $todoObjProperties.SessionData[$key] = $SessionData[$key]
            }

            [pscustomobject]$todoObjProperties 
        }
    }
}