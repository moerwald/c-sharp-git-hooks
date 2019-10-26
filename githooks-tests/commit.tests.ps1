Describe "Test several commit scenarios" {
    Context "Test if compile target is called when tracked files are modified"{
        $guid = [System.Guid]::NewGuid()
        $tempRepo = "$env:TEMP/$guid"
        BeforeEach{
            Push-Location
            New-Item -ItemType Directory -Path $tempRepo

            Set-Location $tempRepo
            git init
            "test" >> README.md
            git add .\README.md
            git commit -m "Initial commit"

            $githookDirectory = "$PSScriptRoot/../.githooks/"
            $tmpRepoGitHookDirectory = "$tempRepo/.githooks"

            Copy-Item -Path $githookDirectory  -Destination $tmpRepoGitHookDirectory -Recurse -Verbose

@'
function Invoke-BuildScript {
    param($target)

    @{"Target" = $target} | ConvertTo-Json | Out-File invoke-buildscript.json
}

function Test-RelevantFileChanged {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $changedFile
    )

	$changedFile | Where-Object { ($_ -match ".*") }
}

'@ | Out-File "$tmpRepoGitHookDirectory/functionsToInterfaceAgainst.ps1"

            Set-PSBreakpoint -Script "$tmpRepoGitHookDirectory/functionsToInterfaceAgainst.ps1" -line 1

            git config core.hooksPath $tmpRepoGitHookDirectory
        }

        AfterEach {
            Pop-Location
            Remove-Item -Path $tempRepo -Recurse -Force
        }

        It "Source file changes" {
            "change" >> README.md
            git commit -a -m "some change"

            (Get-Content "./.git/hooks/invoke-buildscript.json" | ConvertFrom-Json).Target | Should -Be "compile"
        }
    }

}