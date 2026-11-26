@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-burial-sound\LastLight.exe" (
  echo Burial sound preview missing. Run Build-Windows.ps1 -OutputDirectory build/windows-burial-sound
  pause
  exit /b 1
)
start "" "build\windows-burial-sound\LastLight.exe"
