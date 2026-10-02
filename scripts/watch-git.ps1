$ErrorActionPreference = "Continue"

$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectPath = Split-Path -Parent $ScriptDirectory
$ProjectPath = [IO.Path]::GetFullPath($ProjectPath)
$GitLogPath = Join-Path $ProjectPath ".git-auto-sync.log"
$DebounceSeconds = 8

$state = [hashtable]::Synchronized(@{
  Dirty = $false
  LastEvent = Get-Date 0
})
$lastObservedStatus = ""

function Write-Log {
  param([string]$Message)
  $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
  Add-Content -LiteralPath $GitLogPath -Value $line
}

function Should-Ignore {
  param([string]$Path)
  $gitPath = Join-Path $ProjectPath ".git"
  return $Path.StartsWith($gitPath, [StringComparison]::OrdinalIgnoreCase) -or $Path -eq $GitLogPath
}

$watcher = New-Object IO.FileSystemWatcher
$watcher.Path = $ProjectPath
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [IO.NotifyFilters]::FileName -bor [IO.NotifyFilters]::DirectoryName -bor [IO.NotifyFilters]::LastWrite -bor [IO.NotifyFilters]::Size
$watcher.EnableRaisingEvents = $true

$eventAction = {
  param($Sender, $EventArgs)
  if (-not (Should-Ignore $EventArgs.FullPath)) {
    $state.Dirty = $true
    $state.LastEvent = Get-Date
  }
}

$subscriptions = @(
  (Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $eventAction),
  (Register-ObjectEvent -InputObject $watcher -EventName Created -Action $eventAction),
  (Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $eventAction),
  (Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $eventAction)
)

Write-Log "Git auto-sync started for $ProjectPath"

try {
  while ($true) {
    Start-Sleep -Seconds 2

    # Poll Git as a fallback for new folders or atomic editor saves that do not emit a watcher event.
    $currentStatus = @(git status --porcelain) -join "`n"
    if ($currentStatus -ne $lastObservedStatus) {
      $lastObservedStatus = $currentStatus
      if ($currentStatus) {
        $state.Dirty = $true
        $state.LastEvent = Get-Date
      }
    }

    if (-not $state.Dirty -or ((Get-Date) - $state.LastEvent).TotalSeconds -lt $DebounceSeconds) {
      continue
    }

    $state.Dirty = $false
    Set-Location -LiteralPath $ProjectPath
    $status = git status --porcelain

    if (-not $status) {
      continue
    }

    $message = "Auto-sync: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm")
    git add -A
    git commit -m $message

    if ($LASTEXITCODE -eq 0) {
      $branch = (git branch --show-current).Trim()
      if ($branch) {
        git push origin $branch
        Write-Log "Committed and pushed changes to $branch."
      } else {
        Write-Log "Commit succeeded, but no current branch was found for push."
      }
    } else {
      Write-Log "Commit failed; changes were left in the working tree."
    }
  }
} finally {
  $subscriptions | ForEach-Object { Unregister-Event -SubscriptionId $_.Id -ErrorAction SilentlyContinue }
  $watcher.Dispose()
  Write-Log "Git auto-sync stopped."
}
