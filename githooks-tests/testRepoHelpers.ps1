function New-TestRepository {

    # Create temp repo url
    $guid = [System.Guid]::NewGuid()
    $tempRepo = "$env:TEMP/$guid"

    # Create repo dir and cd to it
    $null = New-Item -ItemType Directory -Path $tempRepo
    Set-Location $tempRepo

    # Copy git hooks
    $githookDirectory = "$PSScriptRoot/../.githooks/"
    $tmpRepoGitHookDirectory = "$tempRepo/.githooks"
    Copy-Item -Path $githookDirectory  -Destination $tmpRepoGitHookDirectory -Recurse

    # Replcae interface functions with test one

    @'
function Invoke-BuildScript {
    param($target)

    Write-Host "Invoke-BuildScript with target $target called" -ForegroundColor Magenta
    @{"Target" = $target} | ConvertTo-Json | Out-File "$env:TEMP/invoke-buildscript.json"

}

function Test-RelevantFileChanged {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $changedFile
    )

    Write-Host "Test-RelevantFileChanged called. Change files: $($changedFile -join ',')" -ForegroundColor Magenta
	$changedFile | Where-Object { ($_ -match ".*\.cs") } 
    @{"ChangedFile" = $changedFile} | ConvertTo-Json | Out-File "$env:TEMP/changedFiles.json"
}


function Write-BrokenUnitTests {
}

'@ | Out-File "$tmpRepoGitHookDirectory/functionsToInterfaceAgainst.ps1"

    # Setup the GIT repository
    $defaultSourceFile = "Source.cs"
    $defaultSourceFile2 = "Source2.cs"
    $null = git init
    "test" >> $defaultSourceFile
    $null = git add $defaultSourceFile
    "test2" >> $defaultSourceFile2
    $null = git add $defaultSourceFile2
    $null = git add .githooks
    $null = git commit -m "Initial commit"
    $null = git config core.hooksPath $tmpRepoGitHookDirectory

    @{
        "TempDirectory"            = $tempRepo
        "TestFile1"                = $defaultSourceFile
        "TestFile2"                = $defaultSourceFile2
        "ChangedFiles"             = "$env:TEMP/changedFiles.json"
        "InvokedBuildScriptTarget" = "$env:TEMP/invoke-buildscript.json"
    }
}

function Get-ChangedFiles {
    $changedFiles = "$env:TEMP/changedFiles.json"
    Get-Content $changedFiles | ConvertFrom-Json
    $null = Remove-Item $changedFiles
}


function ChangeAndCommit-AlreadyIndexedFile {
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $file
    )
    "change" >> $file
    git add $file
    git commit -m "some change"
}