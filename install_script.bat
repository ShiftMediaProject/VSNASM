@ECHO OFF

REM Defined cript variables
set NASMDL=http://www.nasm.us/pub/nasm/releasebuilds
set NASMVERSION=2.12.02

REM Check what architecture we are installing on
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo Detected 64 bit system...
    set SYSARCH=x64
) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    if "%PROCESSOR_ARCHITEW6432%"=="AMD64" (
        echo Detected 64 bit system running 32 bit shell...
        set SYSARCH=x64
    ) else (
        echo Detected 32 bit system...
        set SYSARCH=x32
    )
) else (
    echo Error: Could not detect current platform architecture!"
    goto Terminate
)

REM First check for a environment variable to help locate the VS installation
if defined VS140COMNTOOLS (
    if exist "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" (
        echo Visual Studio 2015 environment detected...
        call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" 1>NUL 2>NUL
        set MSVC_VER=14
        goto MSVCVarsDone
    )
)
if defined VS120COMNTOOLS (
    if exist "%VS120COMNTOOLS%\..\..\VC\vcvarsall.bat" (
        echo Visual Studio 2013 environment detected...
        call "%VS120COMNTOOLS%\..\..\VC\vcvarsall.bat" 1>NUL 2>NUL
        set MSVC_VER=12
        goto MSVCVarsDone
    )
)

REM Check for default install locations based on current system architecture
if "%SYSARCH%"=="x32" (
    goto MSVCVARSX86
) else if "%SYSARCH%"=="x64" (
    goto MSVCVARSX64
) else (
    goto Terminate
)

:MSVCVARSX86
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" (
    echo Visual Studio 2017 installation detected...
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" 1>NUL 2>NUL
    set MSVC_VER=15
    goto MSVCVarsDone
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\vcvars32.bat" (
    echo Visual Studio 2015 installation detected...
    call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\vcvars32.bat" 1>NUL 2>NUL
    set MSVC_VER=14
    goto MSVCVarsDone
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\vcvars32.bat" (
    echo Visual Studio 2013 installation detected...
    call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\vcvars32.bat" 1>NUL 2>NUL
    set MSVC_VER=12
    goto MSVCVarsDone
) else (
    echo Error: Could not find valid 64 bit x86 Visual Studio installation!
    goto Terminate
)

:MSVCVARSX64
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" (
    echo Visual Studio 2017 installation detected...
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" 1>NUL 2>NUL
    set MSVC_VER=15
    goto MSVCVarsDone
) else if exist C:\"Program Files (x86)\Microsoft Visual Studio 14.0"\VC\bin\amd64\vcvars64.bat (
    echo Visual Studio 2015 installation detected...
    call C:\"Program Files (x86)\Microsoft Visual Studio 14.0"\VC\bin\amd64\vcvars64.bat 1>NUL 2>NUL
    set MSVC_VER=14
    goto MSVCVarsDone
) else if exist C:\"Program Files (x86)\Microsoft Visual Studio 12.0"\VC\bin\amd64\vcvars64.bat (
    echo Visual Studio 2013 installation detected...
    call C:\"Program Files (x86)\Microsoft Visual Studio 12.0"\VC\bin\amd64\vcvars64.bat 1>NUL 2>NUL
    set MSVC_VER=12
    goto MSVCVarsDone
) else (
    echo Error: Could not find valid 64 bit x86 Visual Studio installation!
    goto Terminate
)

:MSVCVarsDone

REM Get the location of the current msbuild
powershell.exe -Command ((Get-Command msbuild.exe).Path ^| Split-Path -parent) > msbuild.txt
set /p MSBUILDDIR=<msbuild.txt
del /F /Q msbuild.txt 1>NUL 2>NUL
if "%MSBUILDDIR%"=="" (
    echo Error: Failed to get location of msbuild!
    goto Terminate
)
if "%MSVC_VER%"=="15" (
    set VCTargetsPath="..\..\..\Common7\IDE\VC\VCTargets"
) else (
    set VCTargetsPath="..\..\..\Microsoft.Cpp\v4.0\V%MSVC_VER%0"
)

REM Convert the relative targets path to an absolute one
set CURRDIR=%CD%
pushd %MSBUILDDIR%
pushd %VCTargetsPath%
set VCTargetsPath=%CD%
popd
popd
if not "%CURRDIR%"=="%CD%" (
    echo Error: Failed to resolve VCTargetsPath!
    goto Terminate
)

REM copy the BuildCustomizations to VCTargets folder
echo Installing build customisations...
copy /B /Y /V "./nasm.*" "%VCTargetsPath%\BuildCustomizations\" 1>NUL 2>NUL
if not exist "%VCTargetsPath%\BuildCustomizations\nasm.props" (
    echo Error: Failed to copy build customisations!
    echo    Ensure that this script is run in a shell with the necessary write privileges
    goto Terminate
)

REM Download the latest nasm binary for windows
if "%SYSARCH%"=="x32" (
    set NASMDOWNLOAD=%NASMDL%/%NASMVERSION%/win64/nasm-%NASMVERSION%-win64.zip
) else if "%SYSARCH%"=="x64" (
    set NASMDOWNLOAD=%NASMDL%/%NASMVERSION%/win32/nasm-%NASMVERSION%-win32.zip
) else (
    goto Terminate
)
echo Downloading required NASM release binary...
powershell.exe -Command (New-Object Net.WebClient).DownloadFile('%NASMDOWNLOAD%', './nasm.zip') 1>NUL 2>NUL
if not exist "./nasm.zip" (
    echo Error: Failed to download required NASM binary!
    echo    The following link could not be resolved "%NASMDOWNLOAD%"
    goto Terminate
)
powershell.exe -Command Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('"./nasm.zip"', '"./TempNASMUnpack"') 1>NUL 2>NUL
if not exist "./TempNASMUnpack" (
    echo Error: Failed to unpack NASM download!
    del /F /Q "./nasm.zip" 1>NUL 2>NUL
    goto Terminate
)
del /F /Q "./nasm.zip" 1>NUL 2>NUL

REM copy nasm executable to VC installation folder
echo Installing required NASM release binary...
copy /B /Y /V "./TempNASMUnpack\nasm-%NASMVERSION%\*.exe" "%VCINSTALLDIR%\" 1>NUL 2>NUL
if not exist "%VCINSTALLDIR%\nasm.exe" (
    echo Error: Failed to install NASM binary!
    echo    Ensure that this script is run in a shell with the necessary write privileges
    rd /S /Q "./TempNASMUnpack" 1>NUL 2>NUL
    goto Terminate
)
rd /S /Q "./TempNASMUnpack"
echo Finished Successfully

:Terminate
pause
