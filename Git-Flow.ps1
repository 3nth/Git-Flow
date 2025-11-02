param(
    [Parameter()]
    [string]$Command,
    [Parameter()]
    [string]$Action,
    [Parameter()]
    [string]$Name,
    [Parameter()]
    [switch]$Major
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

function HasRemote {
    $output = git remote
    return $null -ne $output | Out-Null
}

function GetLastVersion {
    if(HasRemote) { git fetch --tags || { return } }
    $last = git tag | Sort-Object { $_ -as [version]  } | Select-Object -Last 1
    $last ??= "0.0.0" -as [version]
    return $last
}

function GetNextReleaseVersion {
    param(
        [switch]$BumpMajor
    )

    [version]$last = GetLastVersion
    $next = $BumpMajor -or $Major ? ([version]::new($last.Major + 1, 0, 0)) : ([version]::new($last.Major, $last.Minor + 1, 0))
    return $next.ToString()
}

function GetNextHotfixVersion {
    [version]$last = GetLastVersion
    $next = [version]::new($last.Major, $last.Minor, $last.Build + 1)
    return $next.ToString()
}

function VersionNumberIsValid {
    param(
        [string]$Command,
        [string]$Name
    )

    $Version = $Name -as [version]

    if ($null -eq ($Version)) { 
        Write-Host "$Name is not a version number" -Fore Red
        Write-Host "Version Format: MAJOR.MINOR.PATCH (ex. 3.2.1)" -Fore Cyan
        return $false
    }

    if(-1 -eq $Version.Build) { 
        Write-Host "$Name is missing a PATCH number" -Fore Red
        Write-Host "Version Format: MAJOR.MINOR.PATCH (ex. 3.2.1)" -Fore Cyan
        return $false
    }

    if("release" -eq $Command -and 0 -ne $Version.Build){
        Write-Host "Patch number should be 0 for a release" -Fore Red
        Write-Host "Version Format: MAJOR.MINOR.PATCH (ex. 3.2.0)" -Fore Cyan
        return $false
    }

    if("hotfix" -eq $Command -and 0 -eq $Version.Build){
        Write-Host "Patch number should NOT be 0 for a hotfix" -Fore Red
        Write-Host "Version Format: MAJOR.MINOR.PATCH (ex. 3.2.1)" -Fore Cyan
        return $false
    }

    return $true
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
                    Feature-Start $Name | Out-Null
                }
                "finish" {
                    Feature-Finish $Name | Out-Null
                }
                default {
                    Write-Host "Unknown Action:" $Action -Fore Red
                    Write-Host "Valid actions are: start, finish" $Command -Fore Cyan
                }
            }
        }
        "release" {
            switch ($Action) {
                "start" {
                    Release-Start $Name | Out-Null
                }
                "finish" {
                    Release-Finish $Name | Out-Null
                }
                default {
                    Write-Host "Unknown Action:" $Action -Fore Red
                    Write-Host "Valid actions are: start, finish" $Command -Fore Cyan
                }
            }
        }
        "hotfix" {
            switch ($Action) {
                "start" {
                    Hotfix-Start $Name | Out-Null
                }
                "finish" {
                    Hotfix-Finish $Name | Out-Null
                }
                default {
                    Write-Host "Unknown Action:" $Action -Fore Red
                    Write-Host "Valid actions are: start, finish" $Command -Fore Cyan
                }
            }
        }
        default {
            Write-Host "Unknown Command:" $Command -Fore Red
            Write-Host "Valid commands are: feature, release, hotfix" $Command -Fore Cyan
        }
    }
}

function Feature-Start {
    param([string]$Name)

    $Remote = HasRemote

    git checkout $DEVELOP || { return }
    if($Remote) { git pull --rebase || { return } }
    git checkout -b feature/$Name || { return }
}

function Feature-Finish {
    param([string]$Name)

    $Remote = HasRemote

    git checkout feature/$Name || { return }
    if($Remote) { git pull --rebase || { return } }

    git checkout $DEVELOP || { return }
    if($Remote) { git pull --rebase || { return } }

    git merge --no-ff --no-edit feature/$Name || { return }

    git branch -d feature/$Name || { return }
}

function Release-Start {
    param([string]$Name)
    $Name = $Name ? $Name : (GetNextReleaseVersion)
    if(!(VersionNumberIsValid "release" $Name)) { return }

    $Remote = HasRemote

    # create release branch from develop

    git checkout $DEVELOP || { return }
    if($Remote) { git pull --rebase || { return } }
    git checkout -b release/$Name || { return }
}

function Release-Finish {
    param([string]$Name)

    if(!(VersionNumberIsValid "release" $Name)) { return }

    $Remote = HasRemote

    # merge the release branch into main and tag it
    git checkout release/$Name || { return }
    if($Remote) { git pull --rebase || { return } }

    git checkout $MAIN || { return }
    if($Remote) { git pull --rebase || { return } }

    git merge --no-ff --no-edit release/$Name || { return }
    git tag -a $Name || { return }

    # merge the tag into develop

    git checkout $DEVELOP || { return }
    if($Remote) { git pull --rebase || { return } }
    git merge --no-ff --no-edit $Name || { return }

    git branch -d release/$Name || { return }
}

function Hotfix-Start {
    param([string]$Name)

    $Name = $Name ? $Name : (GetNextHotfixVersion)
    if(!(VersionNumberIsValid "hotfix" $Name)) { return }

    $Remote = HasRemote

    # create hotfix branch from main

    git checkout $MAIN || { return }
    if($Remote) { git pull --rebase || { return } }
    git checkout -b hotfix/$Name || { return }
}

function Hotfix-Finish {
    param([string]$Name)

    if(!(VersionNumberIsValid "hotfix" $Name)) { return }

    $Remote = HasRemote

    # merge the hotfix branch into main and tag it
    git checkout hotfix/$Name || { return }
    if($Remote) { git pull --rebase || { return } }

    git checkout $MAIN || { return }
    if($Remote) { git pull --rebase || { return } }

    git merge --no-ff --no-edit hotfix/$Name || { return }
    git tag -a $Name || { return }

    # merge the tag into develop

    git checkout $DEVELOP || { return }
    if($Remote) { git pull --rebase || { return } }
    git merge --no-ff --no-edit $Name || { return }

    git branch -d hotfix/$Name || { return }
}

If ($MyInvocation.InvocationName -ne ".")
{
    Git-Flow $Command $Action $Name
    exit $LASTEXITCODE
}