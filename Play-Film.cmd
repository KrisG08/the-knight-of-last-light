@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-film\LastLight.exe" (
  echo Film preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-film
  pause
  exit /b 1
)
start "" "build\windows-film\LastLight.exe"
