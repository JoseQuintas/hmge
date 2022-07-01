@echo off
if not defined MG_ROOT set MG_ROOT=c:\minigui
if not defined MG_BCC  set MG_BCC=c:\borland\bcc58

set PATH=%MG_BCC%\bin;%MG_ROOT%\harbour\bin;%PATH%

hbmk2 os -L${HB_DYN} minigui.hbc > build.log