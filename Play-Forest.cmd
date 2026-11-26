@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-forest\LastLight.exe" (
  echo Forest preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-forest
  pause
  exit /b 1
)
start "" "build\windows-forest\LastLight.exe"
