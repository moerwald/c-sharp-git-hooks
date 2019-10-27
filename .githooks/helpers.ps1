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
        $someThingStashed = $false
    }

    try {
        & $Callback
    }
    finally {
        git clean -fdx
        if ($someThingStashed){
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
