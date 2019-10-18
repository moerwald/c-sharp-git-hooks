
<#
 # Perform cached diff to check either cs or csproj files have change. If so we:
 #    - compile the solution,
 #    - run unit tests,
 #    - and check unit test result files. In case of failure we abort the push process
 #      via an exception.
 #>
$actGitBranch = git rev-parse --abbrev-ref HEAD
$filesToBePushed = git diff --stat --cached "origin/$actGitBranch"

$filesToBePushed | Where-Object { ($_ -match ".*.cs") -or ($_ -match ".*.csproj") } | ForEach-Object {

	# Call build script and check result code
	& "$PScriptRoot/../build.ps1" -target test
	Write-Host "####################################" -ForegroundColor Magenta
	Write-Host ("make file returned: {0}" -f $LASTEXITCODE)
	Write-Host "####################################" -ForegroundColor Magenta
	if ($LASTEXITCODE -ne 0) {
		# Get broken unit tests
		Write-Host "`nFollowing tests failed: " -ForegroundColor Red
		Get-ChildItem "$PSScriptRoot/../" -Include '*.trx' -Recurse | ForEach-Object {
			$testResult = [xml](Get-Content $_)
			$testResult.TestRun.Results.UnitTestResult | Where-Object { $_.outcome -eq "Failed" } | ForEach-Object {
				Write-Host "`t - $($_.testname)" -ForegroundColor Red
			}
		}

		Write-Host ""
		throw "Unit tests are broken, won't push changes to remote repository"
	}
}