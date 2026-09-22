@echo off
setlocal

set "PROJECT_DIR=%~dp0"

where godot.exe >nul 2>&1
if %errorlevel%==0 (
    start "Kataklysma" godot.exe --editor --path "%PROJECT_DIR%"
    exit /b 0
)

where godot4.exe >nul 2>&1
if %errorlevel%==0 (
    start "Kataklysma" godot4.exe --editor --path "%PROJECT_DIR%"
    exit /b 0
)

echo Godot nao foi encontrado no PATH do Windows.
echo Abra o Godot manualmente e selecione esta pasta:
echo %PROJECT_DIR%
pause
