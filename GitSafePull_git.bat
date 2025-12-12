@echo off
REM ===========================
REM Git 安全一括取得（Pull）バッチ
REM ===========================

REM 作業ディレクトリに移動（必要に応じて変更）
cd /d "C:\work\delphi\Mycreate_app"

REM ローカルの変更を一時退避
git stash push -m "Auto-stash before pull"

REM リモートの最新を取得してマージ
git pull origin main

REM 退避させた変更を元に戻す
git stash pop

REM 完了メッセージ
echo.
echo ===========================
echo Git safe pull completed!
echo ===========================
pause

