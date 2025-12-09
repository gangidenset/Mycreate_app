@echo off
REM ===========================
REM Git 一括更新バッチファイル
REM ===========================

REM 作業ディレクトリに移動（必要に応じて変更）
cd /d "C:\work\delphi\Mycreate_app"

REM 変更をすべて追加
git add -A

REM コミット（メッセージは日付付き）
set commit_msg=Update on %date% %time%
git commit -m "%commit_msg%"

REM プッシュ
git push origin main

REM 完了メッセージ
echo.
echo ===========================
echo Git update completed!
echo ===========================
pause
