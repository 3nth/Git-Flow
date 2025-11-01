# Git-Flow

git flow reimplemented as a PowerShell script.

## Installation

Download [Git-Flow.ps1](Git-Flow.ps1) and put it somewhere nice.

## git Integration

To use it as `git flow` add an alias

    # Windows
    git config --global alias.flow "!pwsh -NoProfile -File D:/Git-Flow/Git-Flow.ps1"

    # Linux
    git config --global alias.flow '!pwsh -NoProfile -File ~/Git-Flow/Git-Flow.ps1'

## PowerShell Integration

You can also import the `Git-Flow` function into PowerShell:

    . ~/Git-Flow/Git-Flow.ps1

add that line to `$PROFILE` to make it permanent.

and get tab completion when calling.