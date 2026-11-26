@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-village-landscape\LastLight.exe" (
  echo Village landscape preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-village-landscape
  pause
  exit /b 1
)
start "" "build\windows-village-landscape\LastLight.exe"
