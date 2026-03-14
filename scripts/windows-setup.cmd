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
echo [1/4] Instalando dependencias...
call npm install
if errorlevel 1 exit /b 1

echo [2/4] Garantindo apps\backend\.env...
if not exist apps\backend\.env (
  copy /Y apps\backend\.env.example apps\backend\.env >nul
  echo Criado apps\backend\.env
) else (
  echo apps\backend\.env ja existe
)

echo [3/4] Garantindo apps\frontend\.env...
if not exist apps\frontend\.env (
  copy /Y apps\frontend\.env.example apps\frontend\.env >nul
  echo Criado apps\frontend\.env
) else (
  echo apps\frontend\.env ja existe
)

echo [4/4] Pronto. Execute: npm run dev
endlocal
