@echo off
setlocal

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Installation failed with exit code %EXIT_CODE%.
) else (
    echo.
    echo Installation completed successfully.
)

pause
exit /b %EXIT_CODE%
