#!/usr/bin/env bash

echo 'start script'
chmod +x /workspace/how-to-use-git-hooks-for-csharp-projects/.githooks/*
chmod +x /workspace/how-to-use-git-hooks-for-csharp-projects/initGitHooks.ps1
chmod +x /workspace/how-to-use-git-hooks-for-csharp-projects/build.ps1
pwsh -Command "& /workspace/how-to-use-git-hooks-for-csharp-projects/initGitHooks.ps1"