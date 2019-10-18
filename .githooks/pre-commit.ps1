$status = git status

$status | Where-Object { ($_ -match ".*\.cs$") -or ($_ -match ".*.csproj") } | ForEach-Object {
	& "$PScriptRoot/../build.ps1" -target compile
	Write-Host "####################################"
	Write-Host ("make file returned: {0}" -f $LASTEXITCODE)
	Write-Host "####################################"
	if ($LASTEXITCODE -ne 0) {
		throw "It seems you code doesn't compile ... Fix compilation error(s) before commiting"
	}
}

