. $PSScriptRoot/testRepoHelpers.ps1

Describe "Test several commit scenarios" {

    $repositoryInfo = @{ }

    BeforeEach {
        Push-Location
        $repositoryInfo = New-TestRepository 
    }

    AfterEach {
        Pop-Location
        Remove-Item -Path $repositoryInfo.TempDirectory -Recurse -Force
    }

    It "Already indexed source file changes" {
        ChangeAndCommit-AlreadyIndexedFile -file $repositoryInfo.TestFile1
        Assert-TargetWasCalled  -target "compile"
    }

    It "New source file is added" {
        $newSourceFile = "new.cs"
        "change" >> $newSourceFile
        git add $newSourceFile
        git commit -m "new file added"

        Assert-TargetWasCalled  -target "compile"
    }

    It "Already indexed source file is removed" {
        git rm $repositoryInfo.TestFile1
        git commit -m "file removed"

        Assert-TargetWasCalled  -target "compile"
    }
}