. $PSScriptRoot/helpers.ps1

function Test-RelevantFileChanged {
	# Git status returns files to be commited with a 'M' right at the start of the line, files
	# that have change BUT are not staged for commit are marked as ' M', notice the space at the
	# start of the line.
	git status -s | Where-Object { ($_ -match ".*\.cs$") -or ($_ -match ".*\.csproj") }
}

function Start-Compile {
	& "$PScriptRoot/../build.ps1" -target compile 
}

function Main {
	Invoke-InStashedEnvironment { 

		if (Test-RelevantFileChanged) {
			Start-Compile

			Write-LastExitCode
			if ($LASTEXITCODE -ne 0) {
				throw "It seems you code doesn't compile ... Fix compilation error(s) before commiting"
			}
		}
	}
}

Main