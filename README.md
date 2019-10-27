# Compile and unit test via GIT hooks

This repository shows the usage of GIT hooks to compile and run unit tests automatically before your code gets committed and/or pushed. For demonstration, we're using a simple C# net core project. Using GIT hooks for this purpose gives you the following advantages:

1. All code that is committed to GIT compiles.
2. All code that is pushed to the remote repository passes all unit tests.
3. Faster feedback than via CI, that might build the code in a time-triggered manner.

Disadvantages:

- Committing and pushing slows down

The idea for this scripts was based on the following issues:

- CI (e.g. Jenkins) doesn't check all temporary branches, e.g. short-living feature or bugfix branches that are going to be merged to the production branch.
- Developers don't check the CI outcome (which is very sad, but not uncommon at daily work ...)
- Increase feedback time. You'll "immediately" get feedback on commit/push if your code is ok, or if you messed something.

As the base for above-mentioned GIT behavior the following points need to be realized:

1. Your code has to be compilable via the cmd-line.
2. You need to add to create GIT hook scripts and update the hook directory of your local GIT repository (or tell GIT to point to a directory containing your hooks).

## Make your solution compilable via cmd-line

In this repository [Nuke](https://nuke.build) is used to define build the steps to build a .net core "HelloWorld" console app and a dummy "Helloworld" unit test project. [Nuke](https://nuke.build) defines several build steps in C#, the corresponding project is located in the build directory. The build project, `build.ps1` and `build.sh` were generated via the [Nuke](https://nuke.build) wizard, by calling ```nuke :setup``` on the command line. `build.ps1` acts more or less as a proxy to the cmd-line app, which is the output of ```_build.csproj```. Each target defined in [Build.cs](https://github.com/moerwald/how-to-use-git-hooks-for-csharp-projects/blob/master/build/Build.cs) is proxied by the ```-target``` parameter of ```build.ps1```. Based on that you're able to build your software via:

```
> .\build.ps1 -target compile
```

and you're also able to run the unit tests via:

```
> .\build.ps1 -target test
```

## Create GIT hooks and add their directory into your local GIT repository

Hooks used in this repository are located under ```.githooks```. I decided to write the scripts in PowerShell because I'm working the most time under Windows, additionally, I like the object-oriented idea of PowerShell. The directory contains two bash scripts (```pre-commit``` and ```pre-push```) that are used to fire up a PowerShell process executing the corresponding `ps1` files (because GIT under Windows uses an own port of Bash). Since ```pre-commit``` and ```pre-push``` are Bash scripts they can be extended to work under Linux too (you'll only need to install PowerShell Core). Because of GIT doesn't offer a post-clone hook we've the tell GIT to use our custom pre-commit and pre-push after the initial clone of this repository. This can be done by simply calling ```initGitHooks.ps1```. After that GIT invokes below scripts:

* ```pre-commit.ps1``` every time you perform a commit to the local GIT repository.
* ```pre-push.ps1``` every time you try to push the changes of your local GIT repo to the remote one.

Let's take a look a the hook scripts in detail.

```pre-commit.ps1```:

```PowerShell

. $PSScriptRoot/helpers.ps1
. $PSScriptRoot/functionsToInterfaceAgainst.ps1

function Invoke-PreCommit {
    Invoke-InStashedEnvironment { 
        $status = git status -s
        if (!$status -or $status.Count -eq 0){
            Write-Warning "git status -s didn't return any changes!"
            return
        }

        if (Test-RelevantFileChanged -changedFile $status) {
            Invoke-BuildScript -target compile

            Write-LastExitCode
            if ($LASTEXITCODE -ne 0) {
                throw "It seems you code doesn't compile ... Fix compilation error(s) before commiting"
            }
        }
    }
}

```

The script sources a `helper.ps1`-file ,which contains functions used by `pre-commit.ps1` and `pre-push.ps1`,  and a `functionsToInterfaceAgainst.ps1`-file, which function that the use might customize for her own needs. Based on that the base flow is decoupled from the user's needs. `Invoke-InStashedEnvironment` stashed ALL files (regardless if indexed or not) to ensure that the compile operation is only called with commit diff. `Invoke-InStashedEnvironment` takes a `scriptblock`-object as parameter, which is invoked after the stash operation. After the `scriptblock`-object was invoked the old workspace state is restored.
In the stashed environment ```git status``` is used to find the changed filenames, which are stored in the `$status` array. `Test-RelevantFileChanged` decides if one of the files has a `cs` or `csproj` suffix. If so the code has to be compiled before committing it. `Test-RelevantFileChanged` and `Invoke-BuildScript` are located in `functionsToInterfaceAgainst.ps1`. It is assumed that `Invoke-BuildScript` set the PowerShell automatic variable `$LASTEXITCODE` to a value unequal zero in case of failure. If so, the commit process is canceled by the `throw` statement. In the background, `Invoke-BuildScript` calls the ```build.ps1```-script (generated via Nuke) with the ```compile``` target. The target is defined in [Build.cs](https://github.com/moerwald/c-sharp-git-hooks/blob/feature/repo-description/build/Build.cs).

The same pattern is used during the GIT push process.

```pre-push.ps1```:

```PowerShell

. $PSScriptRoot/helpers.ps1
. $PSScriptRoot/functionsToInterfaceAgainst.ps1

function Invoke-PrePush {

    $actGitBranch = git rev-parse --abbrev-ref HEAD
    if (Test-RelevantFileChanged -changedFile @(git diff --stat --cached "origin/$actGitBranch")) {
        Invoke-InStashedEnvironment { 
            Invoke-BuildScript -target test
        }
        Write-LastExitCode
        if ($LASTEXITCODE -ne 0) {
            Write-BrokenUnitTests
            throw "Unit tests are broken, won't push changes to remote repository"
        }
    }
}

Invoke-PrePush

```

The main difference is the fetching of changed files (the ones to be pushed). Here the `diff` command is used via:

```
git diff --stat --cached "origin/$actGitBranch"
```

As done in `pre-commit.ps1`, we scan the list of files for changed `cs`- or `csproj`-files. If the check is `true` we call our buildscript with the `test`-target. In the case of unit tests fail `$LASTEXITCODE` shall be unequal to zero, which causes an exception to be thrown. To present the user which tests failed the user-specific `Write-BrokenUnitTests` function is called. In the case of the `HelloWorld` dummy projects, a `trx` test report is scanned and dumped to the user.

... Note: Creation of the trx files has to be done via MSBUILD, check the `VSTestLogger` XML entry in [HelloWorld.Tests.csproj](https://github.com/moerwald/how-to-use-git-hooks-for-csharp-projects/blob/84cbab0c960e04825ba4a8cd7507e66aa47d558e/src/project-cmd-line-app/HelloWorld/HelloWorld.Tests/HelloWorld.Tests.csproj#L15).

The `HelloWorld` playground projects are a good base to play around with the hooks, but testing the scripts by changing the several source is quite annoying. Therefore  `githooks-tests` folder contains some [Pester](https://github.com/pester/Pester) tests verifying correct behavior. The tests can be invoked on the cmd-line via `githooks-tests>Invoke-Pester`.

Here is the output of the hook scripts.

Commit, everything is ok:

![commit gif](docu/gifs/git-commit-hook.gif)

Push, everything is ok:

![push gif](docu/gifs/git-push-hook.gif)

Push, unit test(s) fail:

![push fail gif](docu/gifs/git-push-hook-failure.gif)


# GitPod "Playground"

If you want to try the hooks live just click on this [GitPod link](https://gitpod.io/#https://github.com/moerwald/how-to-use-git-hooks-for-csharp-projects) and type `pwsh -Command "& .\build.ps1 -target test` in the terminal. To play around with the hooks, just change a `cs`-file and commit it. If you want to check the pre-push hook just enter `git push --dry-run`.

![GitPod gif](docu/gifs/gitpod.gif)
