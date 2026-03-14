@echo off
setlocal

echo [0/4] Verificando estrutura do projeto...
if not exist apps\backend\package.json goto err_struct
if not exist apps\frontend\package.json goto err_struct
goto ok_struct

:err_struct
echo [ERRO] Estrutura incompleta! Pastas apps\backend ou apps\frontend ausentes.
echo Certifique-se de baixar/clonar o repositorio por completo.
exit /b 1

:ok_struct
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
