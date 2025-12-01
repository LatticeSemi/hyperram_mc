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

REM Note: We don't use setlocal to avoid directory restoration issues
REM when the bash script changes to an invalid directory

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
echo [DEBUG] About to run bash script...
"%BASH_PATH%" "%SCRIPT_DIR%create-public-release.sh" %*

REM Capture exit code immediately (ERRORLEVEL can be changed by any command)
echo [DEBUG] Bash script finished, capturing exit code...
set "EXIT_CODE=%ERRORLEVEL%"
echo [DEBUG] Exit code captured: %EXIT_CODE%

if %EXIT_CODE% NEQ 0 (
    echo.
    echo Script exited with error code: %EXIT_CODE%
    pause
)

REM Change back to repo root before exit to prevent "path not found" errors
REM The release branch doesn't have the scripts folder, so we need to be in repo root
REM Use absolute path to ensure it works even if we're in release branch
REM Verify the path exists before trying to cd to it
echo [DEBUG] About to change directory back to repo root...
echo [DEBUG] REPO_ROOT_ABS is: %REPO_ROOT_ABS%
echo [DEBUG] REPO_ROOT is: %REPO_ROOT%
echo [DEBUG] Current directory before cd: %CD%

if defined REPO_ROOT_ABS (
    echo [DEBUG] REPO_ROOT_ABS is defined, checking if path exists...
    if exist "%REPO_ROOT_ABS%" (
        echo [DEBUG] Path exists, attempting cd to: %REPO_ROOT_ABS%
        cd /d "%REPO_ROOT_ABS%" >nul 2>&1
        echo [DEBUG] After cd, ERRORLEVEL: %ERRORLEVEL%
        echo [DEBUG] Current directory after cd: %CD%
    ) else (
        echo [DEBUG] REPO_ROOT_ABS path does not exist, using USERPROFILE fallback
        REM If absolute path doesn't exist, try user profile as fallback
        cd /d "%USERPROFILE%" >nul 2>&1
        echo [DEBUG] After cd to USERPROFILE, ERRORLEVEL: %ERRORLEVEL%
    )
) else (
    echo [DEBUG] REPO_ROOT_ABS is NOT defined, using REPO_ROOT
    REM Try relative path, but fallback to user profile if it fails
    echo [DEBUG] Attempting cd to: %REPO_ROOT%
    cd /d "%REPO_ROOT%" >nul 2>&1
    echo [DEBUG] After cd, ERRORLEVEL: %ERRORLEVEL%
    if %ERRORLEVEL% NEQ 0 (
        echo [DEBUG] cd failed, using USERPROFILE fallback
        cd /d "%USERPROFILE%" >nul 2>&1
        echo [DEBUG] After cd to USERPROFILE, ERRORLEVEL: %ERRORLEVEL%
    )
)

echo [DEBUG] About to exit with code: %EXIT_CODE%
echo [DEBUG] Final current directory: %CD%
REM Exit with the captured error code
exit /b %EXIT_CODE%

