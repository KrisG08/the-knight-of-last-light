@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-blackwood-art\LastLight.exe" (
  echo Blackwood preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-blackwood-art
  pause
  exit /b 1
)
start "" "build\windows-blackwood-art\LastLight.exe"
