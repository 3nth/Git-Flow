param(
    [Parameter()]
    [string]$Command,
    [Parameter()]
    [string]$Action,
    [Parameter()]
    [string]$Name
)

$DEVELOP = "develop"
$MAIN = "main"

function GetBranches {
    param(
        [string]$Command
    )
    git branch --list "$Command/*" | ForEach-Object { $_ -replace "$Command/", "" -replace "\* ", "" }
}

Register-ArgumentCompleter -CommandName Git-Flow -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    if("finish" -eq $fakeBoundParameter.Action) {
        GetBranches $fakeBoundParameter.Command | Where-Object { $_ -like "${wordToComplete}*" }
    }
}

$REMOTE = $null

function Has-Remote {
    $REMOTE ??= git remote
    return $null -ne $REMOTE | Out-Null
}

function ExitOnError {
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function ExitIfNotVersionNumber {
    param(
        [string]$Name
    )

    $Version = $Name -as [version]

    if ($null -eq ($Name -as [version])) { 
        Write-Host "$Name is not a version number" -Fore Red
        exit 1
    }

    if(-1 -eq $Version.Revision) { 
        Write-Host "$Name is missing a revision number" -Fore Red
        exit 1
    }
}

function Git-Flow {
    param(
        [ArgumentCompletions('feature', 'release', 'hotfix')]
        [string]$Command,
        [ArgumentCompletions('start', 'finish')]
        [string]$Action,
        [string]$Name
    )

    switch ($Command)
    {
        "feature" {
            switch ($Action) {
                "start" {
                    Feature-Start $Name
                }
                "finish" {
                    Feature-Finish $Name
                }
                default {
                    Write-Host "Unknown Action:" $Action -Fore Red
                }
            }
        }
        "release" {
            switch ($Action) {
                "start" {
                    Release-Start $Name
                }
                "finish" {
                    Release-Finish $Name
                }
                default {
                    Write-Host "Unknown Action:" $Action -Fore Red
                }
            }
        }
        "hotfix" {
            switch ($Action) {
                "start" {
                    Hotfix-Start $Name
                }
                "finish" {
                    Hotfix-Finish $Name
                }
                default {
                    Write-Host "Unknown Action:" $Action -Fore Red
                }
            }
        }
        default {
            Write-Host "Unknown Command:" $Command -Fore Red
        }
    }
}

function Feature-Start {
    param([string]$Name)

    git checkout $DEVELOP || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError
    git checkout -b feature/$Name || ExitOnError
}

function Feature-Finish {
    param([string]$Name)

    git checkout feature/$Name || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError

    git checkout $DEVELOP || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError

    git merge --no-ff --no-edit feature/$Name || ExitOnError

    git branch -d feature/$Name || ExitOnError
}

function Release-Start {
    param([string]$Name)

    ExitIfNotVersionNumber $Name

    # create release branch from develop

    git checkout $DEVELOP || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError
    git checkout -b release/$Name || ExitOnError
}

function Release-Finish {
    param([string]$Name)

    ExitIfNotVersionNumber $Name

    # merge the release branch into main and tag it
    git checkout release/$Name || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError

    git checkout $MAIN || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError

    git merge --no-ff --no-edit release/$Name || ExitOnError
    git tag -a $Name || ExitOnError

    # merge the tag into develop

    git checkout $DEVELOP || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError
    git merge --no-ff --no-edit $Name || ExitOnError

    git branch -d release/$Name || ExitOnError
}

function Hotfix-Start {
    param([string]$Name)

    ExitIfNotVersionNumber $Name

    # create hotfix branch from main

    git checkout $MAIN || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError
    git checkout -b hotfix/$Name || ExitOnError
}

function Hotfix-Finish {
    param([string]$Name)

    ExitIfNotVersionNumber $Name

    # merge the hotfix branch into main and tag it
    git checkout hotfix/$Name || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError

    git checkout $MAIN || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError

    git merge --no-ff --no-edit hotfix/$Name || ExitOnError
    git tag -a $Name || ExitOnError

    # merge the tag into develop

    git checkout $DEVELOP || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError
    git merge --no-ff --no-edit $Name || ExitOnError

    git branch -d hotfix/$Name || ExitOnError
}

If ($MyInvocation.InvocationName -ne ".")
{
    Git-Flow $Command $Action $Name
}