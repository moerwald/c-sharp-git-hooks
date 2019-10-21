$gitHooksDirectory = ".githooks"

Write-Host "Telling GIT to use hooks from $gitHooksDirectory "

git config core.hooksPath $gitHooksDirectory