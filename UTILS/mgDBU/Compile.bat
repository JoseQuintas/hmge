@if "%MG_ROOT%"=="" set MG_ROOT=c:\minigui

call %MG_ROOT%\batch\compile.bat MGDBU    /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call %MG_ROOT%\batch\compile.bat DBUEDIT  /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call %MG_ROOT%\batch\compile.bat DBUVIEW  /nl %1 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\batch\compile.bat MGDBU /lo /b DBUEDIT /b DBUVIEW /r MGDBU_ %1 %2 %3 %4 %5 %6 %7 %8 %9

call %MG_ROOT%\batch\compile.bat MGDBU    /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call %MG_ROOT%\batch\compile.bat DBUEDIT  /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call %MG_ROOT%\batch\compile.bat DBUVIEW  /do %1 %2 %3 %4 %5 %6 %7 %8 %9
