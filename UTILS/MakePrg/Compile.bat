call ..\..\Batch\Compile.Bat makeprg        %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat configClass    %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat configCfgClass %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\Batch\Compile.Bat makeprg %1 /c /lo /b configClass /b configCfgClass /xs sample.prg %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\Batch\Compile.Bat makeprg        %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat configClass    %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat configCfgClass %1 /do %2 %3 %4 %5 %6 %7 %8 %9