@echo off
setlocal enabledelayedexpansion

REM ========================================================================
REM Windows Configuration Installation Script
REM ========================================================================
REM This script creates symbolic links for configuration files on Windows.
REM Please run this script as Administrator to create symbolic links.
REM ========================================================================

echo ========================================================================
echo Windows Configuration Installation
echo ========================================================================
echo.

REM Get the script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo [INFO] Script directory: %SCRIPT_DIR%
echo.

REM Define destination directory
set "DEST_DIR=%USERPROFILE%\.config"

REM Create destination directory if it doesn't exist
if not exist "%DEST_DIR%" (
    echo [CREATE] Creating directory: %DEST_DIR%
    mkdir "%DEST_DIR%"
) else (
    echo [OK] Destination directory exists: %DEST_DIR%
)

echo.
echo ========================================================================
echo Installing configurations to %%USERPROFILE%%\.config
echo ========================================================================
echo.

REM List of configurations to symlink
REM Only include tools that are available or relevant on Windows
set "ITEMS=nvim zed wezterm uv starship.toml lazygit bat yazi btop lazydocker lsd zellij eza newsboat"

REM Process each item
for %%i in (%ITEMS%) do (
    set "source_path=%SCRIPT_DIR%\%%i"
    set "link_path=%DEST_DIR%\%%i"

    REM Check if source exists
    if exist "!source_path!" (
        REM Remove existing link/file/directory
        if exist "!link_path!\*" (
            echo [REMOVE] Removing existing directory: !link_path!
            rmdir /s /q "!link_path!" 2>nul
        ) else if exist "!link_path!" (
            REM Check if it's a symlink
            (
                goto :tryfile
              ) 2>nul (
                echo [REMOVE] Removing existing symlink: !link_path!
                del /q "!link_path!" 2>nul
              ) || (
                echo [REMOVE] Removing existing file: !link_path!
                del /q "!link_path!" 2>nul
              )
        )
        :tryfile

        REM Create symbolic link using PowerShell
        echo [LINK] Creating symlink: !link_path! -^> !source_path!
        powershell -Command "if (Test-Path '!source_path!' -PathType Leaf) { New-Item -ItemType SymbolicLink -Path '!link_path!' -Target '!source_path!' -Force | Out-Null } else { New-Item -ItemType SymbolicLink -Path '!link_path!' -Target '!source_path!' -Force | Out-Null }"

        if errorlevel 1 (
            echo [ERROR] Failed to create symlink for %%i
        ) else (
            echo [OK] Created symlink: %%i
        )
    ) else (
        echo [SKIP] Source not found: %%i
    )
    echo.
)

REM ========================================================================
echo Installing home directory configurations
echo ========================================================================
echo.

REM Home directory items
set "HOME_ITEMS=.vimrc"

for %%i in (%HOME_ITEMS%) do (
    set "source_path=%SCRIPT_DIR%\%%i"
    set "link_path=%USERPROFILE%\%%i"

    if exist "!source_path!" (
        if exist "!link_path!" (
            echo [REMOVE] Removing existing file: !link_path!
            del /q "!link_path!" 2>nul
        )

        echo [LINK] Creating symlink: !link_path! -^> !source_path!
        powershell -Command "New-Item -ItemType SymbolicLink -Path '!link_path!' -Target '!source_path!' -Force | Out-Null"

        if errorlevel 1 (
            echo [ERROR] Failed to create symlink for %%i
        ) else (
            echo [OK] Created symlink: %%i
        )
    ) else (
        echo [SKIP] Source not found: %%i
    )
    echo.
)

REM ========================================================================
echo Installing Rime configuration (if applicable)
echo ========================================================================
echo.

REM Rime on Windows - typically in %APPDATA%\Rime
set "RIME_PATH=%APPDATA%\Rime"
set "RIME_SOURCE=%SCRIPT_DIR%\Rime"

if exist "%RIME_SOURCE%" (
    if exist "%RIME_PATH%" (
        echo [REMOVE] Removing existing Rime directory: %RIME_PATH%
        rmdir /s /q "%RIME_PATH%" 2>nul
    )

    echo [LINK] Creating symlink: %RIME_PATH% -^> %RIME_SOURCE%
    powershell -Command "New-Item -ItemType SymbolicLink -Path '%RIME_PATH%' -Target '%RIME_SOURCE%' -Force | Out-Null"

    if errorlevel 1 (
        echo [ERROR] Failed to create symlink for Rime
    ) else (
        echo [OK] Created symlink for Rime
    )
) else (
    echo [SKIP] Rime source not found
)
echo.

REM ========================================================================
echo Building bat theme (if bat is installed)
echo ========================================================================
echo.

where bat >nul 2>&1
if %errorlevel% equ 0 (
    echo [BUILD] Building bat cache...
    bat cache --build
    if errorlevel 1 (
        echo [WARNING] Failed to build bat cache
    ) else (
        echo [OK] Bat cache built successfully
    )
) else (
    echo [SKIP] bat not found, skipping cache build
)

echo.
echo ========================================================================
echo Installation completed!
echo ========================================================================
echo.
echo Note: Some tools may not be available on Windows. The following were
echo excluded from this installation:
echo   - kitty, ghostty (terminal emulators - use wezterm instead)
echo   - tmux (terminal multiplexer - not available on Windows)
echo   - aerospace (macOS-only tiling window manager)
echo.
echo Please run this script as Administrator if you encounter permission errors.
echo.
pause
