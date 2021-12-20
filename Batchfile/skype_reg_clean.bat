%1 mshta vbscript:CreateObject^("Shell.Application"^).ShellExecute^("cmd.exe","/C "^&chr^(34^)^&chr^(34^)^&"%~f0"^&chr^(34^)^&" REM"^&chr^(34^),"","runas",1^)^(window.close^) & GOTO :EOF
PUSHD "%~dp0"
REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" && ((REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" | FINDSTR REG_) || REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /f)
REG QUERY "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" && ((REG QUERY "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" | FINDSTR REG_) || REG DELETE "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /f)
POPD
