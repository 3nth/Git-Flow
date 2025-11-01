# CHANGELOG

## 0.4.1

- FIX: Feature-Start needs to call HasRemote
## 0.4.0

- FIX: don't exit shell on error
- improvements

## 0.3.1

- Better error messages

## 0.3.0

- make it work nicely as an imported function `Git-Flow`
- redo validation for cleaner messages
- add autocompleter for finish branch name

## 0.2.0

- Exit on first failed command
- don't pull if no remote
- don't edit on merges
- delete merged branches on successful finish

## 0.1.2

feature finish should do a `--no-ff` merge

## 0.1.1

make sure branches are fully up-to-date before merging

## 0.1.0

Just the basics for:
- `Git-Flow.ps1 feature start`
- `Git-Flow.ps1 feature finish`
- `Git-Flow.ps1 release start`
- `Git-Flow.ps1 release finish`
- `Git-Flow.ps1 hotfix start`
- `Git-Flow.ps1 hotfix finish`