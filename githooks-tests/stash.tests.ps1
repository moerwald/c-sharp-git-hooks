. $PSScriptRoot/testRepoHelpers.ps1

Describe "Tests to verfiy stashing operations of git hooks" {

    $repositoryInfo = @{ }

    BeforeEach {
        Push-Location
        $repositoryInfo = New-TestRepository 
    }

    AfterEach {
        Pop-Location
        Remove-Item -Path $repositoryInfo.TempDirectory -Recurse -Force
    }

    It "Stash and restore untracked file" {
        $someUntrackedFile = "untrackedFile"
        "test" >> $someUntrackedFile

        ChangeAndCommit-AlreadyIndexedFile -file $repositoryInfo.TestFile1

        # Check if 
        $changedFiles = (Get-ChangedFiles).ChangedFile 
        $changedFiles | Should -Not -BeNullOrEmpty
        $changedFiles | ForEach-Object { $_ | Should -Not -BeLike "*$someUntrackedFile*" }
        Test-Path $someUntrackedFile | Should -BeTrue
    }

    It "Stash and restore changed but not staged file" {
        $someUntrackedFile = "untrackedFile"
        "test" >> $someUntrackedFile

        ChangeAndCommit-AlreadyIndexedFile -file $repositoryInfo.TestFile1

        "change" >> $repositoryInfo.TestFile1
        $defaultSourceFile2 = $repositoryInfo.TestFile2
        # Check if 
        $changedFiles = (Get-ChangedFiles).ChangedFile 
        $changedFiles | Should -Not -BeNullOrEmpty
        $changedFiles | ForEach-Object { $_ | Should -Not -BeLike "*$defaultSourceFile2*" }
        Test-Path $defaultSourceFile2 | Should -BeTrue
    }
}