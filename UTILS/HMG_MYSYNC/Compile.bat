call ..\..\batch\compile.bat KForm3 /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat HMG_MySync /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat HMG_MySync /lo /b KForm3 /z /l rddleto /l hbmemio /mt %1 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\batch\compile.bat KForm3 /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat HMG_MySync /do %1 %2 %3 %4 %5 %6 %7 %8 %9
