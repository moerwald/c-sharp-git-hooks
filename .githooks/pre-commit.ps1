. $PSScriptRoot/helpers.ps1
. $PSScriptRoot/functionsToInterfaceAgainst.ps1

function Invoke-PreCommit {
	Invoke-InStashedEnvironment { 

		if (Test-RelevantFileChanged -changedFile @(git status -s)) {
			Invoke-BuildScript -target compile

			Write-LastExitCode
			if ($LASTEXITCODE -ne 0) {
				throw "It seems you code doesn't compile ... Fix compilation error(s) before commiting"
			}
		}
	}
}

Invoke-PreCommit 