@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-v0566\LastLight.exe" (
  echo Version 0.5.66 missing. Run Build-Windows.ps1 -OutputDirectory build/windows-v0566 -SkipArchive
  pause
  exit /b 1
)
start "" "build\windows-v0566\LastLight.exe"
