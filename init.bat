@echo off

:: Set to > 0 for verbose output to aid in debugging.
if not defined verbose-output ( set verbose-output=0 )

:: HyperTweak Environment Variable
set HyperTweakPath="C:\Users\kerol\Desktop\HyperTweak"

:: Pick right version of clink
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
) else (
    set architecture=64
)

:: Run Clink
"%HyperTweakPath%\clink\clink_x%architecture%.exe" inject --quiet --profile "%HyperTweakPath%\profile""

set PLINK_PROTOCOL=ssh
if not defined TERM set TERM=cygwin

:: check if git is in path...
setlocal enabledelayedexpansion
for /F "delims=" %%F in ('where git.exe 2^>nul') do @(
    pushd %%~dpF
    cd ..
    set "test_dir=!CD!"
    popd
    if exist "!test_dir!\cmd\git.exe" (
        set "GIT_INSTALL_ROOT=!test_dir!"
        set test_dir=
        goto :FOUND_GIT
    ) else (
        echo Found old git version in "!test_dir!", but not using...
        set test_dir=
    )
)

:: our last hope: our own git...
:VENDORED_GIT
if exist "%HyperTweakPath%\git-for-windows" (
    set "GIT_INSTALL_ROOT=%CMDER_ROOT%\vendor\git-for-windows"
    call :verbose-output Add the minimal git commands to the front of the path
    set "PATH=!GIT_INSTALL_ROOT!\cmd;%PATH%"
) else (
    goto :NO_GIT
)

:FOUND_GIT
:: Add git to the path
if defined GIT_INSTALL_ROOT (
    rem add the unix commands at the end to not shadow windows commands like more
    call :verbose-output Enhancing PATH with unix commands from git in "%GIT_INSTALL_ROOT%\usr\bin"
    set "PATH=%PATH%;%GIT_INSTALL_ROOT%\usr\bin;%GIT_INSTALL_ROOT%\usr\share\vim\vim74"
    :: define SVN_SSH so we can use git svn with ssh svn repositories
    if not defined SVN_SSH set "SVN_SSH=%GIT_INSTALL_ROOT:\=\\%\\bin\\ssh.exe"
)

:NO_GIT
endlocal & set "PATH=%PATH%" & set "SVN_SSH=%SVN_SSH%" & set "GIT_INSTALL_ROOT=%GIT_INSTALL_ROOT%"


:: Additional config
:verbose-output
    if %verbose-output% gtr 0 echo %*
    exit /b
