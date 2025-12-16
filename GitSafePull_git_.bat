@echo off
echo ===== Git Pull Start =====

cd /d %~dp0

git status
echo.
git pull

echo.
echo ===== Git Pull End =====
pause
