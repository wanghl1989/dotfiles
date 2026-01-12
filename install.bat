@echo off
setlocal enabledelayedexpansion

REM ========================================================================
REM Windows Configuration Update Script
REM ========================================================================
REM This script updates existing symbolic links for configuration files.
REM Similar to update.sh - only updates configs, doesn't install tools.
REM ========================================================================

echo ========================================================================
echo Windows Configuration Update
echo ========================================================================
echo This will re-create all configuration symlinks.
echo.
pause

echo.

REM Get the script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo [INFO] Script directory: %SCRIPT_DIR%
echo.

REM Define destination directory
set "DEST_DIR=%USERPROFILE%\.config"

REM Check if destination directory exists
if not exist "%DEST_DIR%" (
    echo [ERROR] Destination directory does not exist: %DEST_DIR%
    echo Please run install_config.bat first.
    pause
    exit /b 1
)

echo ========================================================================
echo Updating configurations to %%USERPROFILE%%\.config
echo ========================================================================
echo.

REM List of configurations to symlink
set "ITEMS=nvim zed wezterm uv starship.toml lazygit bat yazi btop lazydocker lsd zellij eza newsboat"

REM Process each item
for %%i in (%ITEMS%) do (
    set "source_path=%SCRIPT_DIR%\%%i"
    set "link_path=%DEST_DIR%\%%i"

    REM Check if source exists
    if exist "!source_path!" (
        REM Remove existing link/file/directory
        if exist "!link_path!\*" (
            echo [REMOVE] Removing: !link_path!
            rmdir /s /q "!link_path!" 2>nul
        ) else if exist "!link_path!" (
            echo [REMOVE] Removing: !link_path!
            del /q "!link_path!" 2>nul
        )

        REM Create symbolic link using PowerShell
        echo [LINK] Creating: !link_path!
        powershell -Command "if (Test-Path '!source_path!' -PathType Leaf) { New-Item -ItemType SymbolicLink -Path '!link_path!' -Target '!source_path!' -Force | Out-Null } else { New-Item -ItemType SymbolicLink -Path '!link_path!' -Target '!source_path!' -Force | Out-Null }"

        if errorlevel 1 (
            echo [ERROR] Failed to update %%i
        ) else (
            echo [OK] Updated: %%i
        )
    ) else (
        echo [SKIP] Source not found: %%i
    )
    echo.
)

REM ========================================================================
echo Updating home directory configurations
echo ========================================================================
echo.

REM Home directory items
set "HOME_ITEMS=.vimrc"

for %%i in (%HOME_ITEMS%) do (
    set "source_path=%SCRIPT_DIR%\%%i"
    set "link_path=%USERPROFILE%\%%i"

    if exist "!source_path!" (
        if exist "!link_path!" (
            echo [REMOVE] Removing: !link_path!
            del /q "!link_path!" 2>nul
        )

        echo [LINK] Creating: !link_path!
        powershell -Command "New-Item -ItemType SymbolicLink -Path '!link_path!' -Target '!source_path!' -Force | Out-Null"

        if errorlevel 1 (
            echo [ERROR] Failed to update %%i
        ) else (
            echo [OK] Updated: %%i
        )
    ) else (
        echo [SKIP] Source not found: %%i
    )
    echo.
)

REM ========================================================================
echo Updating Rime configuration (if applicable)
echo ========================================================================
echo.

REM Rime on Windows
set "RIME_PATH=%APPDATA%\Rime"
set "RIME_SOURCE=%SCRIPT_DIR%\Rime"

if exist "%RIME_SOURCE%" (
    if exist "%RIME_PATH%" (
        echo [REMOVE] Removing: %RIME_PATH%
        rmdir /s /q "%RIME_PATH%" 2>nul
    )

    echo [LINK] Creating: %RIME_PATH%
    powershell -Command "New-Item -ItemType SymbolicLink -Path '%RIME_PATH%' -Target '%RIME_SOURCE%' -Force | Out-Null"

    if errorlevel 1 (
        echo [ERROR] Failed to update Rime
    ) else (
        echo [OK] Updated: Rime
    )
) else (
    echo [SKIP] Rime source not found
)
echo.

REM ========================================================================
echo Rebuilding bat theme (if bat is installed)
echo ========================================================================
echo.

where bat >nul 2>&1
if %errorlevel% equ 0 (
    echo [BUILD] Rebuilding bat cache...
    bat cache --build
    if errorlevel 1 (
        echo [WARNING] Failed to rebuild bat cache
    ) else (
        echo [OK] Bat cache rebuilt successfully
    )
) else (
    echo [SKIP] bat not found, skipping cache build
)

echo.
echo ========================================================================
echo Update completed!
echo ========================================================================
echo.
echo Your configuration symlinks have been refreshed.
echo.
pause
