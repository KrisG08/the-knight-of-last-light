@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-mausoleum\LastLight.exe" (
  echo Mausoleum preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-mausoleum
  pause
  exit /b 1
)
start "" "build\windows-mausoleum\LastLight.exe"
