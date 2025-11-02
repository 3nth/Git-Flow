# Git-Flow

git flow reimplemented as a PowerShell script.

## Installation

Requires PowerShell 7+

Download [Git-Flow.ps1](Git-Flow.ps1) and put it somewhere nice.

## git Integration

To use it as `git flow` add an alias

    # Windows
    git config --global alias.flow "!pwsh -NoProfile -File ~/Git-Flow.ps1"

    # Linux
    git config --global alias.flow '!pwsh -NoProfile -File ~/Git-Flow.ps1'

## PowerShell Integration

You can also import the `Git-Flow` function into PowerShell and get tab completion when calling.

    . ~/Git-Flow.ps1

Add that line to your `$PROFILE` to make it permanent.


## DOES

- It does `git flow feature NAME`
- It does `git flow release MAJOR.MINOR.PATCH` and expects `PATCH` to be `0` for a release
- It does `git flow hotfix MAJOR.MINOR.PATCH` and expects `PATCH` to be greater than`0` for a hotfix
- It does expect your production branch is named `main` 
- It does expect your development branch is named `develop`

## New Tricks

Version can be calculated for release/hotfix branches based off last tagged version (version order, not tag date)

Calculate the next minor release version

    git flow release version

Calculate the next major release version

    git flow release version --major

Calculate the next hotfix version

    git flow hotfix version

Bump the MINOR version (PATCH set to 0)

    git flow release start

Bump the PATCH version

    git flow hotfix start

Bump the MAJOR version (MINOR/PATCH set to 0)

    git flow release start --major

Adds commands to powershell

    GetLastVersion
    GetNextReleaseVersion
    GetNextReleaseVersion --BumpMajor
    GetNextHotfixVersion

## DOESN'T

- It doesn't do `git flow publish`. `git push` it all you want.
- It doesn't do `git flow init` as there isn't any customization.
- It doesn't do `git flow delete`. `git branch -d` to your hearts content.
- It doesn't do `git flow bugfix`. Never really used that one.
- It doesn't do `git flow support`. Never really used that one either.
