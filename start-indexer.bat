@echo off
set "WT=%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe"
if not exist "%WT%" set "WT=wt.exe"

"%WT%" new-tab --title MAINNET cmd /k "cd /d C:\code\indexer && call mediu\Scripts\activate.bat && python app.py mainnet" ^
; split-pane -H --title TESTNET cmd /k "cd /d C:\code\indexer && call mediu\Scripts\activate.bat && python app.py testnet"
