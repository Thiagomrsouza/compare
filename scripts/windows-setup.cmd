@echo off
setlocal

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
