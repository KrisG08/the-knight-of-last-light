$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$headers = @{ 'User-Agent' = 'LastLight-LocalAssetIntegration/1.0' }
$specs = @{ modular_fort_01='2k'; rock_moss_set_01='2k'; dead_tree_trunk='1k'; large_castle_door='2k'; pine_sapling_small='1k'; fern_02='1k' }
$catalog = if (Test-Path '.tools/polyhaven-models.json') { Get-Content '.tools/polyhaven-models.json' -Raw | ConvertFrom-Json } else { Invoke-RestMethod 'https://api.polyhaven.com/assets?t=models' -Headers $headers }
$records = @()
foreach ($assetId in $specs.Keys) {
    $resolution = $specs[$assetId]
    $files = if (Test-Path ".tools/$assetId-files.json") { Get-Content ".tools/$assetId-files.json" -Raw | ConvertFrom-Json } else { Invoke-RestMethod "https://api.polyhaven.com/files/$assetId" -Headers $headers }
    $model = $files.gltf.$resolution.gltf
    if (-not $model) { throw "Missing glTF variant for $assetId" }
    $directory = Join-Path 'assets/vendor/polyhaven' $assetId
    New-Item -ItemType Directory -Force $directory | Out-Null
    $entries = @(@{name="$assetId.gltf"; data=$model})
    foreach ($entry in $model.include.PSObject.Properties) { $entries += @{name=$entry.Name; data=$entry.Value} }
    $downloaded = @()
    foreach ($entry in $entries) {
        if (-not $entry.data.url.StartsWith('https://dl.polyhaven.org/file/ph-assets/')) { throw 'Unexpected asset host' }
        if ($entry.name.Contains('..') -or [IO.Path]::IsPathRooted($entry.name)) { throw 'Invalid asset-relative path' }
        $destination = Join-Path $directory $entry.name
        New-Item -ItemType Directory -Force (Split-Path $destination -Parent) | Out-Null
        if (-not (Test-Path -LiteralPath $destination)) { Invoke-WebRequest $entry.data.url -Headers $headers -OutFile $destination }
        if ((Get-FileHash -LiteralPath $destination -Algorithm MD5).Hash.ToLowerInvariant() -ne $entry.data.md5) { throw "Asset checksum failed: $destination" }
        $downloaded += @{ path=$entry.name; url=$entry.data.url; md5=$entry.data.md5; sha256=(Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash; bytes=(Get-Item -LiteralPath $destination).Length }
    }
    $records += @{id=$assetId; resolution=$resolution; source="https://polyhaven.com/a/$assetId"; license='CC0-1.0'; license_url='https://polyhaven.com/license'; authors=$catalog.$assetId.authors; files=$downloaded}
    Write-Output "Verified $assetId ($resolution)"
}
$manifestPath = 'assets/vendor/polyhaven/manifest.json'
if (Test-Path -LiteralPath $manifestPath) {
    $records += @(Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json | Where-Object { -not $specs.ContainsKey($_.id) })
}
$records | ConvertTo-Json -Depth 15 | Set-Content -Encoding utf8 $manifestPath
