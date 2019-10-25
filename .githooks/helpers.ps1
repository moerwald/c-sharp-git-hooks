function Invoke-InStashedEnvironment {
    param( 
        [Parameter (Mandatory, Position = 0)]
        [scriptblock] 
        $Callback
        )

    if (!$Callback) {
        return
    }

    git stash --include-untracked --keep-index # Ensure that we only compile against file marked for commit
    try {
        & $Callback
    }
    finally {
        git stash pop # restore "initial" state
    }
}

function Write-LastExitCode {
    Write-Host "####################################" -ForegroundColor Magenta
    Write-Host ("ExitCode: {0}" -f $LASTEXITCODE)
    Write-Host "####################################" -ForegroundColor Magenta
}
