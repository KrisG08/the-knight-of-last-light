@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-burial-art\LastLight.exe" (
  echo Burial chamber preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-burial-art
  pause
  exit /b 1
)
start "" "build\windows-burial-art\LastLight.exe"
