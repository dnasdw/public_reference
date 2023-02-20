PUSHD "%~dp0"

7z && SET szExe="7z"
IF NOT DEFINED szExe (
  FOR /F "tokens=1,2*" %%I IN ('REG QUERY HKLM\SOFTWARE\7-Zip /v Path') DO SET szExe="%%~K7z"
)
IF NOT DEFINED szExe (
  ECHO Can not find 7-Zip installed!
  GOTO ERROR
)
%szExe%>NUL || GOTO ERROR

IF NOT "%~1"=="" (
  SET iExe="%~1"
)
IF EXIST iTunesSetup.exe (
  SET iExe32="iTunesSetup.exe"
)
IF EXIST iTunes64Setup.exe (
  SET iExe64="iTunes64Setup.exe"
)
IF NOT DEFINED iExe (
  IF NOT DEFINED iExe32 (
    IF NOT DEFINED iExe64 (
        GOTO ERROR
    )
  )
)

RD /S /Q temp
MD temp\32
%szExe% x -otemp\32 %iExe32% iTunes.msi -y
%szExe% x -otemp\32 %iExe% iTunes.msi -y
MD temp\64
%szExe% x -otemp\64 %iExe64% iTunes64.msi -y
%szExe% x -otemp\64 %iExe% iTunes64.msi -y

RD /S /Q bin
MD bin\32bit
IF EXIST temp\32\iTunes.msi (
  CALL :extract bin\32bit temp\32\iTunes.msi
)
RD /Q bin\32bit
MD bin\64bit
IF EXIST temp\64\iTunes64.msi (
  CALL :extract bin\64bit temp\64\iTunes64.msi
)
RD /Q bin\64bit
RD /Q bin

RD /S /Q temp

POPD
GOTO :EOF

:extract
RD /S /Q temp\extract
msiexec /a "%~2" /qn TARGETDIR="%CD%\temp\extract"
REM System
XCOPY temp\extract\System\*.dll "%~1" /Y
XCOPY temp\extract\System64\*.dll "%~1" /Y
REM update
XCOPY temp\extract\iTunes\api-ms-win-*.dll "%~1" /Y
XCOPY temp\extract\iTunes\ucrtbase.dll "%~1" /Y
REM ntldd
XCOPY temp\extract\iTunes\CoreAudioToolbox.dll "%~1" /Y
XCOPY temp\extract\iTunes\CoreFoundation.dll "%~1" /Y
XCOPY temp\extract\iTunes\libdispatch.dll "%~1" /Y
XCOPY temp\extract\iTunes\objc.dll "%~1" /Y
XCOPY temp\extract\iTunes\ASL.dll "%~1" /Y
XCOPY temp\extract\iTunes\libicuin.dll "%~1" /Y
XCOPY temp\extract\iTunes\libicuuc.dll "%~1" /Y
XCOPY temp\extract\iTunes\icudt*.dll "%~1" /Y
RD /S /Q temp\extract
GOTO :EOF

:ERROR
POPD
PAUSE
