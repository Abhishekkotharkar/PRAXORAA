$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectPath = Split-Path -Parent $ScriptDirectory
$FrontendPath = Join-Path $ProjectPath "frontend"

Set-Location -LiteralPath $FrontendPath
python -m http.server 4173
