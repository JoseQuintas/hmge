@echo off
rem Builds Harbour library winprocess.lib.

:SET
  set MG_BCC=C:\Borland\BCC58
  set MG_ROOT=C:\MiniGui
  set MG_HRB=%MG_ROOT%\Harbour
  set MV_HRB=%MG_HRB%

:BUILD
  if exist winprocess.lib del winprocess.lib

  %MV_HRB%\bin\harbour winprocess.prg -n -w -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -w -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib winprocess.c
  %MG_BCC%\bin\tlib winprocess.lib +winprocess.obj

:CLEANUP
  if exist winprocess.c   del winprocess.c
  if exist winprocess.obj del winprocess.obj
  goto :end

:COPYLIB
  if exist winprocess.lib move winprocess.lib %MG_ROOT%\lib\winprocess.lib

:END