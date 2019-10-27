function Invoke-InStashedEnvironment {
    param( 
        [Parameter (Mandatory, Position = 0)]
        [scriptblock] 
        $Callback
        )

    if (!$Callback) {
        return
    }

    $result = git stash --include-untracked --keep-index # Ensure that we only compile against file marked for commit
    $someThingStashed = $true
    if ($result -like "*No local changes to save*"){
        # Nothing to stash found
        $someThingStashed = $false
    }

    try {
        & $Callback
    }
    finally {
        # Restore the original workspace state
        if ($someThingStashed){
            git clean -fdx
            # Only pop if something was stashed before, otherwise $LASTEXITCODE will be !=  0, which will cause other steps to break
            git stash pop # restore "initial" state
        }
    }
}

function Write-LastExitCode {
    Write-Host "####################################" -ForegroundColor Magenta
    Write-Host ("ExitCode: {0}" -f $LASTEXITCODE)
    Write-Host "####################################" -ForegroundColor Magenta
}
