# c-sharp-git-hooks

This repo shall show the usage of GIT hooks for C# net core projects. The main idea was to keep code quality at a high or at least at the same level as it is.

We all know the problem where we've to perform bugfixes shortly before a deadline ends. You do some minor changes in the code, sync them up to the remote repository and tell your colleague/boss that the code can be shipped. You leave the office, and receive an email some minutes or hours later, complaining that the code doesn't even compile. And even worse, your commit was the one that broke the code. Wouldn't it be great if your version control system (in our case GIT) compiles your before commiting it, and even better run the unit tests before pushing your changes to remote repo (and of course declining the push)?
