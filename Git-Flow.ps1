param(
    [ValidateSet("feature","release", "hotfix")]
    [Parameter(Position = 0, Mandatory=$true)]
    [string]$Command,
    [ValidateSet("start","finish")]
    [Parameter(Position = 1, Mandatory=$true)]
    [string]$Action,
    [Parameter(Position = 2, Mandatory=$true)]
    [string]$Name
)

$DEVELOP = "develop"
$MAIN = "main"

$REMOTE = $null

function Has-Remote {
    $REMOTE ??= git remote
    return $null -ne $REMOTE | Out-Null
}

function ExitOnError {
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function Git-Flow {
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
            }
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
}

function Release-Start {
    param([version]$Name)

    # create release branch from develop

    git checkout $DEVELOP || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError
    git checkout -b release/$Name || ExitOnError
}

function Release-Finish {
    param([version]$Name)

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
}

function Hotfix-Start {
    param([version]$Name)

    # create hotfix branch from main

    git checkout $MAIN || ExitOnError
    Has-Remote || git pull --rebase || ExitOnError
    git checkout -b hotfix/$Name || ExitOnError
}

function Hotfix-Finish {
    param([version]$Name)

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
}

If ($MyInvocation.InvocationName -ne ".")
{
    Git-Flow
}