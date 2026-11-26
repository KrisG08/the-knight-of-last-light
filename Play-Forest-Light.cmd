@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-forest-light\LastLight.exe" (
  echo Forest lighting preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-forest-light
  pause
  exit /b 1
)
start "" "build\windows-forest-light\LastLight.exe"
