param([string]$OutputDirectory = 'build/windows', [switch]$SkipArchive)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$outputPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot $OutputDirectory))
$buildRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'build')) + [IO.Path]::DirectorySeparatorChar
if (-not $outputPath.StartsWith($buildRoot, [StringComparison]::OrdinalIgnoreCase)) { throw 'Export output must stay inside this workspace build directory' }
$env:APPDATA = Join-Path $PSScriptRoot '.tools/userdata'
$engine = Join-Path $PSScriptRoot '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
New-Item -ItemType Directory -Force $outputPath | Out-Null
& $engine --headless --path . --editor --import --quit
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $engine --headless --path . --export-release 'Windows Desktop' (Join-Path $outputPath 'LastLight.exe')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $engine --headless --path . --script res://tools/write_licenses.gd -- $outputPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Copy-Item -LiteralPath 'docs/BUILD_README.txt' -Destination (Join-Path $outputPath 'README.txt') -Force
if (Test-Path -LiteralPath 'docs/ASSET_CREDITS.txt') { Copy-Item -LiteralPath 'docs/ASSET_CREDITS.txt' -Destination (Join-Path $outputPath 'ASSET_CREDITS.txt') -Force }
$manifest = Get-ChildItem -LiteralPath $outputPath -File | Where-Object Name -ne 'build_manifest.json' | ForEach-Object {
    @{ name = $_.Name; bytes = $_.Length; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
}
$manifest | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $outputPath 'build_manifest.json')
$zipPath = if ($OutputDirectory -eq 'build/windows') { 'build/Last-Light-Windows-Slice.zip' } else { Join-Path 'build' ('Last-Light-' + (Split-Path $outputPath -Leaf) + '.zip') }
if (-not $SkipArchive) {
    Compress-Archive -Path (Join-Path $outputPath '*') -DestinationPath $zipPath -Force
}
