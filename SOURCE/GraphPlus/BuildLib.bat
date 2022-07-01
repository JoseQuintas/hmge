@echo off

SET HMGPATH=c:\minigui

SET PATH=%HMGPATH%\harbour\bin;c:\borland\bcc58\bin;%PATH%

hbmk2 gplus.hbp > build.log 2>&1
