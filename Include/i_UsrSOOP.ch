#xcommand DECLARE CUSTOM COMPONENTS <w> ;
=> ;
#define SOOP_HMGBUTTON ;;
#xtranslate <w> . \<c\> . Disable => Domethod ( <"w">, \<(c)> , "Disable" ) ;;
#xtranslate <w> . \<c\> . Enable  => Domethod ( <"w">, \<(c)> , "Enable" )  ;;
#xtranslate <w> . \<c\> . Handle  := \<v> => SetProperty ( <"w">, \<(c)> , "Handle" , \<v> ) ;;
#undef SOOP_HMGBUTTON ;;
#define SOOP_CLBUTTON ;;
#xtranslate <w> . \<c\> . SetShield \[()] => Domethod ( <"w">, \<(c)> , "SetShield" ) ;;
#xtranslate <w> . \<c\> . NoteText => GetProperty ( <"w">, \<(c)> , "NoteText" )  ;;
#xtranslate <w> . \<c\> . NoteText := \<v> => SetProperty ( <"w">, \<(c)> , "NoteText" , \<v> ) ;;
#undef SOOP_CLBUTTON ;;
#define SOOP_PRINT ;;
#xtranslate <w> . \<c\> . Print \[()] => Domethod ( <"w">, \<"c"> , "Print" )  ;;
#undef SOOP_PRINT ;;
#define SOOP_ANIMATERES ;;
#xtranslate <w> . \<c\> . File  => GetProperty ( <"w">, \<"c"> , "File" )  ;;
#xtranslate <w> . \<c\> . File  := \<v> => SetProperty ( <"w">, \<"c"> , "File" , \<v> ) ;;
#xtranslate <w> . \<c\> . ResId => GetProperty ( <"w">, \<"c"> , "ResId" ) ;;
#xtranslate <w> . \<c\> . ResId := \<v> => SetProperty ( <"w">, \<"c"> , "ResId" , \<v> ) ;;
#undef SOOP_ANIMATERES ;;
#define SOOP_WEBCAM ;;
#xtranslate <w> . \<c\> . Start \[()] => Domethod ( <"w">, \<(c)> , "Start" ) ;;
#undef SOOP_WEBCAM ;;
#define SOOP_ACTIVEX ;;
#xtranslate <w> . \<c\> . XObject  := \<v> => SetProperty ( <"w">, \<(c)> , "XObject" , \<v> ) ;;
#undef SOOP_ACTIVEX