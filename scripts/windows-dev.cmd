@echo off
setlocal

if not exist apps\backend\.env goto setup
if not exist apps\frontend\.env goto setup
goto run

:setup
echo Ambiente nao configurado. Executando setup...
call scripts\windows-setup.cmd
if errorlevel 1 exit /b 1

:run
echo Iniciando frontend + backend...
call npm run dev
endlocal
