@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
start "" "build\windows-v05\LastLight.exe"
