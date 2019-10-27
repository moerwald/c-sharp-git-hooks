. $PSScriptRoot/helpers.ps1
. $PSScriptRoot/functionsToInterfaceAgainst.ps1

function Invoke-PreCommit {
	Invoke-InStashedEnvironment { 
		$status = git status -s
		if (!$status -or $status.Count -eq 0){
			Write-Warning "git status -s didn't return any changes!"
			return
		}

		if (Test-RelevantFileChanged -changedFile $status) {
			Invoke-BuildScript -target compile

			Write-LastExitCode
			if ($LASTEXITCODE -ne 0) {
				throw "It seems you code doesn't compile ... Fix compilation error(s) before commiting"
			}
		}
	}
}
