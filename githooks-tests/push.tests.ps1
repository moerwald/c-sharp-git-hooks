. $PSScriptRoot/testRepoHelpers.ps1

Describe "Test several push scenarios" {

    $repositoryInfo = @{ }
    $clonedRepositoryPath = "$env:TEMP\$([System.Guid]::NewGuid())"
    BeforeEach {
        Push-Location
        $repositoryInfo = New-TestRepository 
        # Check out antoher branch in the orig repo, otherwise push will fail 
        # See the link https://stackoverflow.com/questions/2816369/git-push-error-remote-rejected-master-master-branch-is-currently-checked
        git checkout -b test_push
        ChangeAndCommit-AlreadyIndexedFile -file $repositoryInfo.TestFile1
        git checkout master
        Pop-Location

        New-Item -ItemType Directory -Path $clonedRepositoryPath
        
        Push-Location
        Set-Location $clonedRepositoryPath
        git clone $repositoryInfo.TempDirectory .
        git checkout test_push
        $tmpRepoGitHookDirectory = "$clonedRepositoryPath/.githooks"
        git config core.hooksPath $tmpRepoGitHookDirectory
    }

    AfterEach {
        Pop-Location
        Remove-Item -Path $repositoryInfo.TempDirectory -Recurse -Force
        Remove-Item -Path $clonedRepositoryPath -Recurse -Force
    }

    It "Change tracked file, commit and push it" {
        ChangeAndCommit-AlreadyIndexedFile -file $repositoryInfo.TestFile1

        git push -u origin test_push
        Assert-TargetWasCalled  -target "test"
    }

    It "Remove tracked file, commit and push it" {
        git rm $repositoryInfo.TestFile1
        git commit -m "Removed file"

        git push -u origin test_push
        Assert-TargetWasCalled  -target "test"
    }
}