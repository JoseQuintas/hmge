call ..\..\..\batch\compile.bat IDE      /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat miscfunc /nl %1 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\batch\compile.bat IDE      /lo /b miscfunc %1 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\batch\compile.bat IDE      /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat miscfunc /do %1 %2 %3 %4 %5 %6 %7 %8 %9
