. $PSScriptRoot/helpers.ps1
. $PSScriptRoot/functionsToInterfaceAgainst.ps1

function Main {

    <#
    # Perform cached diff to check either cs or csproj files have change. If so we:
    #    - compile the solution,
    #    - run unit tests,
    #    - and check unit test result files. In case of failure we abort the push process
    #      via an exception.
    #>

    $actGitBranch = git rev-parse --abbrev-ref HEAD
    if (Test-RelevantFileChanged -changedFile @(git diff --stat --cached "origin/$actGitBranch")) {
        Invoke-InStashedEnvironment { 
			Invoke-BuildScript -target test
        }
        Write-LastExitCode
        if ($LASTEXITCODE -ne 0) {
            Write-BrokenUnitTests
            throw "Unit tests are broken, won't push changes to remote repository"
        }
    }
}

Main