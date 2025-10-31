param(
    [Parameter(Position = 0)]
    [string]$Command,
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

}

function Feature-Finish {
    param([string]$Name)

}

function Release-Start {
    param([string]$Name)

}

function Release-Finish {
    param([string]$Name)

}

function Hotfix-Start {
    param([string]$Name)

}

function Hotfix-Finish {
    param([string]$Name)

}

If ($MyInvocation.InvocationName -ne ".")
{
    Git-Flow
}