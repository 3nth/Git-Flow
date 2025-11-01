# Git-Flow

git flow reimplemented as a PowerShell script.

## Installation

Requires PowerShell 7+

Download [Git-Flow.ps1](Git-Flow.ps1) and put it somewhere nice.

## git Integration

To use it as `git flow` add an alias

    # Windows
    git config --global alias.flow "!pwsh -NoProfile -File D:/Git-Flow/Git-Flow.ps1"

    # Linux
    git config --global alias.flow '!pwsh -NoProfile -File ~/Git-Flow/Git-Flow.ps1'

## PowerShell Integration

You can also import the `Git-Flow` function into PowerShell and get tab completion when calling.

    . ~/Git-Flow/Git-Flow.ps1

Add that line to your `$PROFILE` to make it permanent.
