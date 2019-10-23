$sourceFileSuffix = "cs"

function AddCommitInteractive {
	param(
		[string]
		$files,
		[string]
		$sourceCodeSuffix
	)

	Write-Host "It seems that you've unversioned $sourceCodeSuffix files" -ForegroundColor Green

	$files | ForEach-Object {
		AskForYesNo -text "Want to add the files to the GIT index" `
				    -callBackAnswerIsYes { git add $_ } `
                    -callBackAnswerIsNo { 
						AskForYesNo -text "Want to mark the file as 'assume unchanged'" `
									-callBackAnswerIsYes { git update-index --assume-unchanged } 
					}
	}
	
	# Commit per default -> disable the pre-commit hook since we're already in it
	git commit --no-verify
}

# Interactive
function AskForYesNo {
	param (
		[string]
		$text,
		[scriptblock]
		$callBackAnswerIsYes,
		[scriptblock]
		$callBackAnswerIsNo
	)
	$yes = "y"
	$no = "n"

	# Keep asking until we've a valid user input
	do {
		$answer = Read-Host -Prompt "$text ($yes/$no)"
		Wait-Debugger
	} while ( ($null -eq $answer) -or (@($yes, $no) -notcontains $answer.ToLower()) )

	if ($answer -eq $yes) {
		if ($callBackAnswerIsYes) {
			$callBackAnswerIsYes.Invoke()
		}
	}
	if ($answer -eq $no) {
		if ($callBackAnswerIsNo) {
			$callBackAnswerIsNo.Invoke()
		}
	}
}

$status = git status -s

# Check if the user may forgot to add files
if ($status | Where-Object { $_ -match "^??\s(?<csFile>.*\.$sourceFileSuffix)" }) {
	AddCommitInteractive -files $Matches.csFile -sourceCodeSuffix $sourceFileSuffix
}

# Git status returns files to be commited with a 'M' right at the start of the line, files
# that have change BUT are not staged for commit are marked as ' M', notice the space at the
# start of the line.
if ($status | Where-Object { ($_ -match "^M.*\.$sourceFileSuffix$") -or ($_ -match ".*.csproj") }) {
	& "$PScriptRoot/../build.ps1" -target compile
	Write-Host "####################################" -ForegroundColor Magenta
	Write-Host ("make file returned: {0}" -f $LASTEXITCODE)
	Write-Host "####################################" -ForegroundColor Magenta
	if ($LASTEXITCODE -ne 0) {
		throw "It seems you code doesn't compile ... Fix compilation error(s) before commiting"
	}
}