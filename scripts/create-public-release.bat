@echo off
REM =============================================================================
REM Windows Batch Wrapper for create-public-release.sh
REM =============================================================================
REM This wrapper allows running the bash release script from Windows Command
REM Prompt or PowerShell without needing to manually specify the bash path.
REM
REM Usage:
REM   create-public-release.bat <type> "<message>" "<revision_description>" "<software_version>"
REM
REM Examples:
REM   create-public-release.bat major "Initial release" "Initial release of HyperRAM Memory Controller IP" "2025.2"
REM   create-public-release.bat minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices" "2025.2"
REM   create-public-release.bat bugfix "Fixed timing issue" "Fixed read timing violation" "2025.1.1"
REM =============================================================================

setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%.."

REM Change to repository root directory
cd /d "%REPO_ROOT%"

REM Try to find bash.exe in common Git installation locations
set "BASH_PATH="

REM Check Git installation in user's AppData
if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" (
    set "BASH_PATH=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
    goto :found_bash
)

REM Check Git installation in Program Files
if exist "C:\Program Files\Git\bin\bash.exe" (
    set "BASH_PATH=C:\Program Files\Git\bin\bash.exe"
    goto :found_bash
)

REM Check Git installation in Program Files (x86)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    set "BASH_PATH=C:\Program Files (x86)\Git\bin\bash.exe"
    goto :found_bash
)

REM Check if bash is in PATH
where bash >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "BASH_PATH=bash"
    goto :found_bash
)

REM Bash not found
echo ERROR: Git Bash not found!
echo.
echo Please install Git for Windows from: https://git-scm.com/download/win
echo Or ensure Git Bash is in your system PATH.
echo.
pause
exit /b 1

:found_bash
REM Check if the script exists
if not exist "%SCRIPT_DIR%create-public-release.sh" (
    echo ERROR: create-public-release.sh not found in %SCRIPT_DIR%
    pause
    exit /b 1
)

REM Run the bash script with all arguments passed through
"%BASH_PATH%" "%SCRIPT_DIR%create-public-release.sh" %*

REM Preserve the exit code from the bash script
set "EXIT_CODE=%ERRORLEVEL%"
if %EXIT_CODE% NEQ 0 (
    echo.
    echo Script exited with error code: %EXIT_CODE%
    pause
)

exit /b %EXIT_CODE%

