
function Invoke-BuildScript{
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet("compile", "test")]
        [string]
        $target
    )

	& "$PScriptRoot/../build.ps1" -target $target 
}

function Test-RelevantFileChanged {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $changedFile
    )
	# Git status returns files to be commited with a 'M' right at the start of the line, files
	# that have change BUT are not staged for commit are marked as ' M', notice the space at the
	# start of the line.
	$changedFile | Where-Object { ($_ -match ".*\.cs") -or ($_ -match ".*\.csproj") } | Select-Object -First 1
}

function Write-BrokenUnitTests {
    Write-Host "`nFollowing tests failed: " -ForegroundColor Red
    Get-ChildItem "$PSScriptRoot/../" -Include '*.trx' -Recurse | ForEach-Object {
        $testResult = [xml](Get-Content $_)
        $testResult.TestRun.Results.UnitTestResult | Where-Object { $_.outcome -eq "Failed" } | ForEach-Object {
            Write-Host "`t - $($_.testname)" -ForegroundColor Red
        }
    }
}