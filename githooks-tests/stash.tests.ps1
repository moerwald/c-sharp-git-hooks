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

        $changedFiles = (Get-ChangedFiles).ChangedFile 
        $changedFiles | Should -Not -BeNullOrEmpty
        # Check if none added file was stashed
        $changedFiles | ForEach-Object { $_ | Should -Not -BeLike "*$someUntrackedFile*" }

        # Checkf if none added file was restored 
        Test-Path $someUntrackedFile | Should -BeTrue
    }

    It "Stash and restore changed but not staged file" {
        $someUntrackedFile = "untrackedFile"
        "test" >> $someUntrackedFile

        ChangeAndCommit-AlreadyIndexedFile -file $repositoryInfo.TestFile1

        $defaultSourceFile2 = $repositoryInfo.TestFile2
        "change" >> $defaultSourceFile2

        $changedFiles = (Get-ChangedFiles).ChangedFile 
        $changedFiles | Should -Not -BeNullOrEmpty

        # Check if none added file was stashed
        $changedFiles | ForEach-Object { $_ | Should -Not -BeLike "*$defaultSourceFile2*" }

        # Checkf if none added file was restored 
        Test-Path $defaultSourceFile2 | Should -BeTrue
    }
}