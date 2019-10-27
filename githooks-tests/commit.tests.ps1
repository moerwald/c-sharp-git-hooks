

Describe "Test several commit scenarios" {

    $defaultSourceFile = "Source.cs"
    $defaultSourceFile2 = "Source2.cs"

    function AssertCompileTargetWasCalled {
        $buildScriptResultFile = "$env:TEMP/invoke-buildscript.json"
        (Get-Content $buildScriptResultFile | ConvertFrom-Json).Target | Should -Be "compile"
        $null = Remove-Item $buildScriptResultFile
    }

    function GetChangedFiles {
        $changedFiles = "$env:TEMP/changedFiles.json"
        Get-Content $changedFiles | ConvertFrom-Json
        $null = Remove-Item $changedFiles
    }

    function ChangeAndCommitAlreadyIndexedFile {
        "change" >> $defaultSourceFile
        git add $defaultSourceFile
        git commit -m "some change"
    }

    $guid = [System.Guid]::NewGuid()
    $tempRepo = "$env:TEMP/$guid"
    BeforeEach {
        Push-Location
        New-Item -ItemType Directory -Path $tempRepo

        Set-Location $tempRepo

        $githookDirectory = "$PSScriptRoot/../.githooks/"
        $tmpRepoGitHookDirectory = "$tempRepo/.githooks"

        Copy-Item -Path $githookDirectory  -Destination $tmpRepoGitHookDirectory -Recurse

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

'@ | Out-File "$tmpRepoGitHookDirectory/functionsToInterfaceAgainst.ps1"

        git init
        "test" >> $defaultSourceFile
        git add $defaultSourceFile
        "test2" >> $defaultSourceFile2
        git add $defaultSourceFile2
        git add .githooks
        git commit -m "Initial commit"
        git config core.hooksPath $tmpRepoGitHookDirectory
    }

    AfterEach {
        Pop-Location
        Remove-Item -Path $tempRepo -Recurse -Force
    }


    Context "Test if compile target is called" {
        It "Already indexed source file changes" {
            ChangeAndCommitAlreadyIndexedFile
            AssertCompileTargetWasCalled
        }

        It "New source file is added" {
            $newSourceFile = "new.cs"
            "change" >> $newSourceFile
            git add $newSourceFile
            git commit -m "new file added"

            AssertCompileTargetWasCalled
        }

        It "Already indexed source file is removed" {
            git rm $defaultSourceFile
            git commit -m "file removed"

            AssertCompileTargetWasCalled
        }
    }

    Context "Stashing tests" {
        It "Stash and restore untracked file" {
            $someUntrackedFile = "untrackedFile"
            "test" >> $someUntrackedFile

            ChangeAndCommitAlreadyIndexedFile

            # Check if 
            $changedFiles = (GetChangedFiles).ChangedFile 
            $changedFiles | Should -Not -BeNullOrEmpty
            $changedFiles | ForEach-Object {$_ | Should -Not -BeLike "*$someUntrackedFile*" }
            Test-Path $someUntrackedFile | Should -BeTrue
        }

        It "Stash and restore changed but not staged file" {
            $someUntrackedFile = "untrackedFile"
            "test" >> $someUntrackedFile

            ChangeAndCommitAlreadyIndexedFile

            "change" >> $defaultSourceFile2

            # Check if 
            $changedFiles = (GetChangedFiles).ChangedFile 
            $changedFiles | Should -Not -BeNullOrEmpty
            $changedFiles | ForEach-Object {$_ | Should -Not -BeLike "*$defaultSourceFile2*" }
            Test-Path $defaultSourceFile2 | Should -BeTrue
        }
    }
}