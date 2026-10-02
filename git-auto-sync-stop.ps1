$ProjectPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PidPath = Join-Path $ProjectPath ".git-auto-sync.pid"

if (-not (Test-Path -LiteralPath $PidPath)) {
  Write-Output "Git auto-sync is not running."
  exit 0
}

$processId = Get-Content -LiteralPath $PidPath -ErrorAction SilentlyContinue
$process = Get-Process -Id $processId -ErrorAction SilentlyContinue

if ($process) {
  Stop-Process -Id $process.Id
  Write-Output "Git auto-sync stopped."
} else {
  Write-Output "Git auto-sync process was not found."
}

Remove-Item -LiteralPath $PidPath -Force -ErrorAction SilentlyContinue
