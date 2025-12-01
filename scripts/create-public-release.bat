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
REM Go up one level to get repo root (%~dp0 always ends with backslash)
set "REPO_ROOT=%SCRIPT_DIR%.."

REM Change to repository root directory (resolve the .. path)
cd /d "%REPO_ROOT%"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to change to repository root directory
    echo Attempted path: %REPO_ROOT%
    pause
    exit /b 1
)

REM Store the absolute path of repo root for later use (needed when in release branch)
for %%I in ("%CD%") do set "REPO_ROOT_ABS=%%~fI"

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

REM Capture exit code immediately (ERRORLEVEL can be changed by any command)
set "EXIT_CODE=%ERRORLEVEL%"

if !EXIT_CODE! NEQ 0 (
    echo.
    echo Script exited with error code: !EXIT_CODE!
    pause
)

REM Change back to repo root before exit to prevent "path not found" errors
REM The release branch doesn't have the scripts folder, so we need to be in repo root
REM Use absolute path to ensure it works even if we're in release branch
REM Verify the path exists before trying to cd to it
if defined REPO_ROOT_ABS (
    if exist "%REPO_ROOT_ABS%" (
        cd /d "%REPO_ROOT_ABS%" >nul 2>&1
    ) else (
        REM If absolute path doesn't exist, try user profile as fallback
        cd /d "%USERPROFILE%" >nul 2>&1
    )
) else (
    REM Try relative path, but fallback to user profile if it fails
    cd /d "%REPO_ROOT%" >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        cd /d "%USERPROFILE%" >nul 2>&1
    )
)

REM Exit with the captured error code
REM Note: We don't use endlocal here because we're exiting anyway
REM and ERRORLEVEL persists, but we captured it in EXIT_CODE for the if statement above
exit /b !EXIT_CODE!

