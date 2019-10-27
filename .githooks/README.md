# Hooks

This folder contains GIT hooks taking care about:

- Compiling your code when you commit a source file (*.cs, *.csproj)
- Running the unit test when you try to push your code to the remote repository, in case source files changed.

You can customize the script by changing the functions located in `functionsToInterfaceAgainst.ps1`. The basic implementation is CSharp related and fires the build script in case of `*.cs` and `*.csproj` files have changed.

The bash like `pre-commit` and `pre-push` scripts act as proxy to fire up the PowerShell equivalent `*.ps1` files.