param([string]$SdkPath = "$PSScriptRoot/.tools/android/sdk", [string]$JavaPath = 'C:/Program Files/Microsoft/jdk-17.0.19.10-hotspot')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$engine = Join-Path $PSScriptRoot '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
foreach ($file in @("$SdkPath/platform-tools/adb.exe", "$SdkPath/build-tools/35.0.1/apksigner.bat", "$JavaPath/bin/java.exe", '.tools/templates/android_debug.apk')) {
    if (-not (Test-Path -LiteralPath $file)) { throw "Missing Android tool: $file. See docs/MOBILE.md" }
}
$env:JAVA_HOME = $JavaPath
$env:APPDATA = Join-Path $PSScriptRoot '.tools/userdata'
# The pinned portable editor is self-contained. Configure only its workspace settings.
$configPath = Join-Path $PSScriptRoot '.tools/godot/editor_data/editor_settings-4.7.tres'
$config = Get-Content -LiteralPath $configPath -Raw
foreach ($entry in @{ 'export/android/java_sdk_path' = $JavaPath; 'export/android/android_sdk_path' = $SdkPath }.GetEnumerator()) {
    $line = $entry.Key + ' = "' + $entry.Value.Replace('\','/') + '"'
    if ($config -match ('(?m)^' + [regex]::Escape($entry.Key) + ' = .*')) {
        $config = [regex]::Replace($config, '(?m)^' + [regex]::Escape($entry.Key) + ' = .*', $line)
    } else { $config += "`n$line`n" }
}
[IO.File]::WriteAllText($configPath, $config)
New-Item -ItemType Directory -Force build/android | Out-Null
& $engine --headless --path . --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Android import failed' }
& $engine --headless --path . --export-debug Android build/android/LastLight.apk
if ($LASTEXITCODE -ne 0) { throw 'Android export failed' }
& "$SdkPath/build-tools/35.0.1/apksigner.bat" verify --verbose build/android/LastLight.apk
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed' }
Copy-Item docs/ASSET_CREDITS.txt build/android/ASSET_CREDITS.txt -Force
Copy-Item docs/MOBILE.md build/android/README.md -Force
& $engine --headless --path . --script res://tools/write_licenses.gd -- build/android
if ($LASTEXITCODE -ne 0) { throw 'License bundle failed' }
Get-ChildItem build/android -File | Where-Object Name -ne 'build_manifest.json' | ForEach-Object {
    @{ name = $_.Name; bytes = $_.Length; sha256 = (Get-FileHash -LiteralPath $_.FullName).Hash }
} | ConvertTo-Json | Set-Content build/android/build_manifest.json
Get-FileHash build/android/LastLight.apk -Algorithm SHA256 | Format-List
