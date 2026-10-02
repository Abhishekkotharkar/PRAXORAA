$ProjectPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PidPath = Join-Path $ProjectPath ".git-auto-sync.pid"
$WatcherPath = Join-Path $ProjectPath "watch-git.ps1"

if (Test-Path -LiteralPath $PidPath) {
  $existingPid = Get-Content -LiteralPath $PidPath -ErrorAction SilentlyContinue
  if ($existingPid -and (Get-Process -Id $existingPid -ErrorAction SilentlyContinue)) {
    Write-Output "Git auto-sync is already running (PID $existingPid)."
    exit 0
  }
}

$process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList @(
  "-NoProfile",
  "-ExecutionPolicy", "Bypass",
  "-File", $WatcherPath
) -PassThru

Set-Content -LiteralPath $PidPath -Value $process.Id
Write-Output "Git auto-sync started (PID $($process.Id))."
