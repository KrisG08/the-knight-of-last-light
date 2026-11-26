param(
    [Parameter(Mandatory=$true)][string]$BuildDirectory,
    [Parameter(Mandatory=$true)][string]$OutputStem,
    [switch]$PackedEditor,
    [int]$SecondsPerStage=10
)
# Own one isolated release process; never changes the owner's settings or power plan.
$ErrorActionPreference='Stop'
$workspacePath=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
Set-Location $workspacePath
$releaseExe=Join-Path $workspacePath ($BuildDirectory+'/LastLight.exe')
$reportStem=Join-Path $workspacePath $OutputStem
$runner=Join-Path $workspacePath 'tools/debug/graphics_benchmark.gd'
$fixture=Join-Path $workspacePath '.tools/wizard-defeat-fixture.json'
$savedAppData=$env:APPDATA
$env:APPDATA=Join-Path $workspacePath '.tools/qa-performance'
$powerScheme=(& powercfg /getactivescheme | Out-String).Trim()
$samples=[Collections.Generic.List[object]]::new()
$clock=[Diagnostics.Stopwatch]::StartNew()
$profileStartedUtc=[DateTime]::UtcNow
try {
    # Standard release templates disable external --script path overrides.
    # Use their built-in workload; packed-editor mode is explicitly a different engine.
    $arguments=@('--','--benchmark')
    if($PackedEditor){
        $releaseExe=Join-Path $workspacePath '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
        $pack=Join-Path $workspacePath ($BuildDirectory+'/LastLight.pck')
        $arguments=@('--main-pack',$pack,'--script',$runner,'--',$fixture,($reportStem+'.json'),'high',0,$SecondsPerStage)
    }
    $profileProcess=Start-Process -FilePath $releaseExe -ArgumentList $arguments -PassThru -WindowStyle Hidden -RedirectStandardOutput ($reportStem+'.log') -RedirectStandardError ($reportStem+'-errors.log')
    while(-not $profileProcess.HasExited){
        $profileProcess.Refresh()
        $samples.Add(@{seconds=$clock.Elapsed.TotalSeconds;working_set=$profileProcess.WorkingSet64;private_bytes=$profileProcess.PrivateMemorySize64;peak_working_set=$profileProcess.PeakWorkingSet64})
        if($clock.Elapsed.TotalSeconds -gt 300){$profileProcess.Kill(); throw 'Own profiling process exceeded 300 seconds'}
        Start-Sleep -Milliseconds 500
    }
    $profileProcess.WaitForExit()
    @{process_id=$profileProcess.Id;exit_code=$profileProcess.ExitCode;power_scheme=$powerScheme;elapsed_seconds=$clock.Elapsed.TotalSeconds;samples=$samples} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ($reportStem+'-process.json')
    if($profileProcess.ExitCode -ne 0){throw 'Release workload failed; inspect its logs'}
    if(-not $PackedEditor){
        $nativeReport=Join-Path $env:APPDATA 'Godot/app_userdata/The Knight of Last Light/benchmarks/slice.json'
        if((Get-Item -LiteralPath $nativeReport).LastWriteTimeUtc -lt $profileStartedUtc.AddSeconds(-1)){throw 'Refusing a stale native benchmark report'}
        Copy-Item -LiteralPath $nativeReport -Destination ($reportStem+'.json')
    }
    if(-not (Test-Path -LiteralPath ($reportStem+'.json'))){throw 'Release workload did not produce its report'}
    'Release profiling complete: '+$reportStem
} finally {$env:APPDATA=$savedAppData}
