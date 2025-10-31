param(
    [ValidateSet("feature","release", "hotfix")]
    [Parameter(Position = 0)]
    [string]$Command,
    [ValidateSet("start","finish")]
    [Parameter(Position = 1)]
    [string]$Action,
    [Parameter(Position = 2)]
    [string]$Name
)

$DEVELOP = "develop"
$MAIN = "main"

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

    git checkout $DEVELOP
    git pull --rebase
    git checkout -b feature/$Name
}

function Feature-Finish {
    param([string]$Name)

    git checkout feature/$Name
    git pull --rebase

    git checkout $DEVELOP
    git pull --rebase

    git merge --no-ff feature/$Name
}

function Release-Start {
    param([version]$Name)

    # create release branch from develop

    git checkout $DEVELOP
    git pull --rebase
    git checkout -b release/$Name
}

function Release-Finish {
    param([version]$Name)

    # merge the release branch into main and tag it
    git checkout release/$Name
    git pull --rebase

    git checkout $MAIN
    git pull --rebase

    git merge --no-ff release/$Name
    git tag -a $Name

    # merge the tag into develop

    git checkout $DEVELOP
    git pull --rebase
    git merge --no-ff $Name
}

function Hotfix-Start {
    param([version]$Name)

    # create hotfix branch from main

    git checkout $MAIN
    git pull --rebase
    git checkout -b hotfix/$Name
}

function Hotfix-Finish {
    param([version]$Name)

    # merge the hotfix branch into main and tag it
    git checkout hotfix/$Name
    git pull --rebase

    git checkout $MAIN
    git pull --rebase

    git merge --no-ff hotfix/$Name
    git tag -a $Name

    # merge the tag into develop

    git checkout $DEVELOP
    git pull --rebase
    git merge --no-ff $Name
}

If ($MyInvocation.InvocationName -ne ".")
{
    Git-Flow
}