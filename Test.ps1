$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$env:APPDATA = Join-Path $PSScriptRoot '.tools/userdata'
New-Item -ItemType Directory -Force $env:APPDATA | Out-Null
$engine = Join-Path $PSScriptRoot '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
$importOutput = & $engine --headless --path . --editor --import --quit 2>&1
$importExit = $LASTEXITCODE
$importOutput | Write-Output
if ($importExit -ne 0 -or ($importOutput | Select-String -Pattern 'SCRIPT ERROR:|^ERROR:')) { exit 1 }
$testOutput = & $engine --headless --path . --script res://tests/run_tests.gd 2>&1
$testExit = $LASTEXITCODE
$testOutput | Write-Output
if ($testExit -ne 0 -or ($testOutput | Select-String -Pattern 'SCRIPT ERROR:|^ERROR:')) { exit 1 }
exit 0
