@echo off
cd /d %~dp0
if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)
md C:\SpotifyAddBlock
xcopy /v C:\Windows\System32\drivers\etc\hosts C:\SpotifyAddBlock\hosts_original
type hosts.txt>C:\Windows\System32\drivers\etc\hosts
echo Service installed
pause