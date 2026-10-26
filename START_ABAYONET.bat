@echo off
title AbayoNet Enterprise Monitor v10.0
color 0A
cd /d "%~dp0"

:: ── Check Python ─────────────────────────────────────────────
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo  [ERROR] Python not found!
    echo.
    echo  1. Go to: https://python.org/downloads
    echo  2. Install Python 3.8 or newer
    echo  3. IMPORTANT: Check "Add Python to PATH"
    echo  4. Restart this computer, then run this file again
    echo.
    pause
    exit /b 1
)

:: ── Check key files exist ─────────────────────────────────────
if not exist "abayonet.py" (
    echo  [ERROR] abayonet.py not found in this folder.
    echo  Make sure all files are in the SAME folder as this .bat file.
    pause & exit /b 1
)
if not exist "static\index.html" (
    echo  [ERROR] static\index.html not found!
    echo  Create a folder named "static" here and put index.html inside it.
    pause & exit /b 1
)

:: ── Menu ──────────────────────────────────────────────────────
cls
echo.
echo  ============================================================
echo       AbayoNet Enterprise Monitor  v10.0
echo       NOC-Grade Network Monitoring
echo  ============================================================
echo.
echo  [1] Run directly  (stops when this window is closed)
echo  [2] Install as Windows Service  (recommended for servers)
echo  [3] Start installed service
echo  [4] Stop  installed service
echo  [5] Remove service
echo  [6] Reset admin password
echo.
set /p CHOICE="  Choose [1-6]: "

if "%CHOICE%"=="1" goto RUN_DIRECT
if "%CHOICE%"=="2" goto INSTALL_SVC
if "%CHOICE%"=="3" goto START_SVC
if "%CHOICE%"=="4" goto STOP_SVC
if "%CHOICE%"=="5" goto REMOVE_SVC
if "%CHOICE%"=="6" goto RESET_PW
echo Invalid choice & pause & goto :EOF

:: ── [1] Run directly ─────────────────────────────────────────
:RUN_DIRECT
cls
echo.
echo  Starting AbayoNet (direct mode) ...
echo  Keep this window open. Press Ctrl+C to stop.
echo.
echo  Dashboard: http://127.0.0.1:8780
echo.
python abayonet.py
echo.
echo  AbayoNet stopped.
pause
exit /b 0

:: ── [2] Install as service ────────────────────────────────────
:INSTALL_SVC
cls
echo.
:: Check admin
net session >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] This option needs Administrator rights.
    echo.
    echo  Right-click START_ABAYONET.bat and choose
    echo  "Run as administrator", then choose option 2 again.
    echo.
    pause & exit /b 1
)

echo  Step 1/4 - Installing pywin32 ...
python -m pip install --quiet --upgrade pywin32
if errorlevel 1 (
    echo  [ERROR] pip install failed. Check internet connection.
    pause & exit /b 1
)

echo  Step 2/4 - Registering Windows Service ...
python abayonet_service.py install
if errorlevel 1 (
    echo  [ERROR] Service install failed.
    echo  Make sure abayonet_service.py is in the same folder.
    pause & exit /b 1
)
sc config AbayoNet start= auto >nul
sc description AbayoNet "AbayoNet Enterprise NOC Monitor. Dashboard: http://localhost:8780" >nul

echo  Step 3/4 - Adding firewall rule ...
netsh advfirewall firewall delete rule name="AbayoNet" >nul 2>&1
netsh advfirewall firewall add rule name="AbayoNet" protocol=TCP dir=in localport=8780 action=allow >nul

echo  Step 4/4 - Starting service ...
sc start AbayoNet >nul

:: Poll for current_port.txt instead of a fixed sleep — on real hardware,
:: service startup (SCM handshake + spawning the wrapped python process +
:: DB init, possibly slowed by antivirus scanning a new python.exe) can
:: easily take longer than a few seconds, especially on first install.
set DASHPORT=
set WAITED=0
:WAIT_PORT_INSTALL
if exist "data\current_port.txt" set /p DASHPORT=<"data\current_port.txt"
if not "%DASHPORT%"=="" goto GOT_PORT_INSTALL
timeout /t 1 /nobreak >nul
set /a WAITED+=1
if %WAITED% lss 30 goto WAIT_PORT_INSTALL

:GOT_PORT_INSTALL
sc query AbayoNet | findstr "RUNNING" >nul
if errorlevel 1 (
    echo.
    echo  [!] Service did not start. Check: services.msc
    echo      or run option 1 to test directly first.
) else if "%DASHPORT%"=="" (
    echo.
    echo  [!] Service is RUNNING but AbayoNet hasn't reported its port yet
    echo      after %WAITED%s. It may still be starting up, or it may have
    echo      hit an error. Check data\abayonet.log and data\service.log,
    echo      then try: http://127.0.0.1:8780
) else (
    echo.
    echo  ============================================================
    echo   AbayoNet Service is RUNNING
    echo   Auto-starts with Windows - no login needed
    echo.
    echo   Dashboard: http://127.0.0.1:%DASHPORT%
    if not "%DASHPORT%"=="8780" (
        echo   [!] Note: port 8780 was already taken by something else,
        echo       so AbayoNet is using %DASHPORT% instead this time.
    )
    echo  ============================================================
    echo.
    start "" "http://127.0.0.1:%DASHPORT%"
)
echo.
pause
exit /b 0

:: ── [3] Start service ─────────────────────────────────────────
:START_SVC
sc start AbayoNet

set DASHPORT=
set WAITED=0
:WAIT_PORT_START
if exist "data\current_port.txt" set /p DASHPORT=<"data\current_port.txt"
if not "%DASHPORT%"=="" goto GOT_PORT_START
timeout /t 1 /nobreak >nul
set /a WAITED+=1
if %WAITED% lss 30 goto WAIT_PORT_START

:GOT_PORT_START
if "%DASHPORT%"=="" (
    echo.
    echo  [!] AbayoNet hasn't reported its port yet after %WAITED%s.
    echo      It may still be starting, or it may have hit an error.
    echo      Check data\abayonet.log and data\service.log,
    echo      then try: http://127.0.0.1:8780
    set DASHPORT=8780
) else if not "%DASHPORT%"=="8780" (
    echo.
    echo  [!] Note: port 8780 was already taken by something else,
    echo      so AbayoNet is actually running on port %DASHPORT% instead.
    echo      Opening http://127.0.0.1:%DASHPORT%
)
start "" "http://127.0.0.1:%DASHPORT%"
pause & exit /b 0

:: ── [4] Stop service ──────────────────────────────────────────
:STOP_SVC
sc stop AbayoNet
echo Service stopped.
pause & exit /b 0

:: ── [5] Remove service ────────────────────────────────────────
:REMOVE_SVC
net session >nul 2>&1
if errorlevel 1 (
    echo  Needs Administrator rights. Right-click > Run as administrator
    pause & exit /b 1
)
sc stop AbayoNet >nul 2>&1
timeout /t 2 /nobreak >nul
python abayonet_service.py remove
netsh advfirewall firewall delete rule name="AbayoNet" >nul 2>&1
echo Service removed.
pause & exit /b 0

:: ── [6] Reset admin password ─────────────────────────────────
:RESET_PW
python abayonet.py --reset-admin
pause & exit /b 0
