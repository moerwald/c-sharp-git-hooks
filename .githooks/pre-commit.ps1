. $PSScriptRoot/helpers.ps1

function Test-RelevantFileChanged {
	git status - | Where-Object { ($_ -match "^M.*\.cs$") -or ($_ -match ".*.csproj") }
}

Invoke-InStashedEnvironment { 

	# Git status returns files to be commited with a 'M' right at the start of the line, files
	# that have change BUT are not staged for commit are marked as ' M', notice the space at the
	# start of the line.
	if (Test-RelevantFileChanged) {

		& "$PScriptRoot/../build.ps1" -target compile 

		Write-LastExitCode
		if ($LASTEXITCODE -ne 0) {
			throw "It seems you code doesn't compile ... Fix compilation error(s) before commiting"
		}
	}
}

