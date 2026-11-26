@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-realism\LastLight.exe" (
  echo Realistic asset preview missing.
  pause
  exit /b 1
)
start "" "build\windows-realism\LastLight.exe"
