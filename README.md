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

## DOESN'T

- It doesn't do `git flow publish`. `git push` it all you want.
- It doesn't do `git flow init` as there isn't any customization.
- It doesn't do `git flow delete`. `git branch -d` to your hearts content.
- It doesn't do `git flow bugfix`. Never really used that one.
- It doesn't do `git flow support`. Never really used that one either.
