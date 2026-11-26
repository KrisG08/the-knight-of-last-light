@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-kings-road\LastLight.exe" (
  echo King's Road preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-kings-road
  pause
  exit /b 1
)
start "" "build\windows-kings-road\LastLight.exe"
