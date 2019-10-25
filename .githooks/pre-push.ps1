. $PSScriptRoot/helpers.ps1

function Write-BrokenUnitTests {
    Write-Host "`nFollowing tests failed: " -ForegroundColor Red
    Get-ChildItem "$PSScriptRoot/../" -Include '*.trx' -Recurse | ForEach-Object {
        $testResult = [xml](Get-Content $_)
        $testResult.TestRun.Results.UnitTestResult | Where-Object { $_.outcome -eq "Failed" } | ForEach-Object {
            Write-Host "`t - $($_.testname)" -ForegroundColor Red
        }
    }
}

function Test-RelevantFileChanged {
    $actGitBranch = git rev-parse --abbrev-ref HEAD
    $filesToBePushed = git diff --stat --cached "origin/$actGitBranch"
    $filesToBePushed | Where-Object { ($_ -match ".*.cs") -or ($_ -match ".*.csproj") }
}

function Start-CompileAndUnitTests{
    & "$PScriptRoot/../build.ps1" -target test 
}

function Main {

    <#
    # Perform cached diff to check either cs or csproj files have change. If so we:
    #    - compile the solution,
    #    - run unit tests,
    #    - and check unit test result files. In case of failure we abort the push process
    #      via an exception.
    #>

    if (Test-RelevantFileChanged) {
        Invoke-InStashedEnvironment { 
            Start-CompileAndUnitTests
        }
        Dump-LastExitCode
        if ($LASTEXITCODE -ne 0) {
            Write-BrokenUnitTests
            throw "Unit tests are broken, won't push changes to remote repository"
        }
    }
}

Main