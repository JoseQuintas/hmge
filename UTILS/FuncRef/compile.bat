call ..\..\Batch\Compile.Bat main     %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat ic_func  %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat mainfunc %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\Batch\Compile.Bat main     %1 /lo /b ic_func /b mainfunc %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\Batch\Compile.Bat main     %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat ic_func  %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat mainfunc %1 /do %2 %3 %4 %5 %6 %7 %8 %9