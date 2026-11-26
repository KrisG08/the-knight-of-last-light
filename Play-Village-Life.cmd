@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-village-life\LastLight.exe" (
  echo Village life preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-village-life
  pause
  exit /b 1
)
start "" "build\windows-village-life\LastLight.exe"
