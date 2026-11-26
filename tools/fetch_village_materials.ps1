$ErrorActionPreference='Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$catalog=Get-Content '.tools/polyhaven-textures.json' -Raw | ConvertFrom-Json
$records=@()
$ids=@('grey_plaster_02','grey_roof_tiles','dark_wooden_planks','cobblestone_floor_02')
foreach($assetId in $ids) {
    $files=Invoke-RestMethod "https://api.polyhaven.com/files/$assetId"
    $directory=Join-Path 'assets/vendor/polyhaven' $assetId
    New-Item -ItemType Directory -Force $directory | Out-Null
    $files | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $directory 'source-files.json')
    $downloaded=@()
    foreach($map in @('Diffuse','nor_gl','Rough')) {
        $entry=$files.$map.'2k'.jpg
        if(!$entry -or !$entry.url.StartsWith('https://dl.polyhaven.org/file/ph-assets/')) {throw "Missing trusted map $assetId/$map"}
        $destination=Join-Path $directory ($map+'.jpg')
        if(!(Test-Path -LiteralPath $destination)) {Invoke-WebRequest $entry.url -OutFile $destination}
        if((Get-FileHash -LiteralPath $destination -Algorithm MD5).Hash.ToLowerInvariant() -ne $entry.md5) {throw "Map checksum failed: $destination"}
        $downloaded+=@{path=($map+'.jpg');url=$entry.url;md5=$entry.md5;sha256=(Get-FileHash $destination).Hash;bytes=(Get-Item $destination).Length}
    }
    $records+=@{id=$assetId;resolution='2k';source="https://polyhaven.com/a/$assetId";license='CC0-1.0';license_url='https://polyhaven.com/license';authors=$catalog.$assetId.authors;files=$downloaded}
    Write-Output "Verified $assetId"
}
$manifest='assets/vendor/polyhaven/manifest.json'
$records+=@(Get-Content $manifest -Raw | ConvertFrom-Json | Where-Object {$_.id -notin $ids})
$records | ConvertTo-Json -Depth 20 | Set-Content $manifest
