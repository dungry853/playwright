@echo off
setlocal

set "ROOT_DIR=%~dp0.."

docker compose --project-directory "%ROOT_DIR%" -f "%ROOT_DIR%\docker\docker-compose.yml" run --rm playwright %*

exit /b %ERRORLEVEL%