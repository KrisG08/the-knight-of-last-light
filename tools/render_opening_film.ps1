param([switch]$Preview)
$ErrorActionPreference='Stop'
$workspacePath=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Set-Location $workspacePath
$projectPath=Join-Path $workspacePath 'project.godot'
$originalBytes=[IO.File]::ReadAllBytes($projectPath)
$sourceText=[Text.Encoding]::UTF8.GetString($originalBytes)
$renderText=[regex]::Replace($sourceText,'(?m)^window/size/viewport_width=1280\r?$','window/size/viewport_width=2560')
$renderText=[regex]::Replace($renderText,'(?m)^window/size/viewport_height=720\r?$','window/size/viewport_height=1440')
if($renderText -eq $sourceText){throw 'Expected original viewport configuration was not found'}
[IO.File]::WriteAllBytes((Join-Path $workspacePath '.tools/movie-render/project-before-v5-render.godot'),$originalBytes)
$env:APPDATA=Join-Path $workspacePath '.tools/qa-voice-render'
try {
    [IO.File]::WriteAllText($projectPath,$renderText,[Text.UTF8Encoding]::new($false))
    $enginePath=Join-Path $workspacePath '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
    if($Preview){
        & $enginePath --path . --script res://tools/render_opening_film.gd -- --preview
    } else {
        & $enginePath --path . --resolution 2560x1440 --script res://tools/render_opening_film.gd --fixed-fps 60 --write-movie .tools/movie-render/opening-v5-qhd-master.avi --quit-after 2402
    }
    if($LASTEXITCODE -ne 0){throw 'Opening render did not complete'}
} finally {
    [IO.File]::WriteAllBytes($projectPath,$originalBytes)
}
