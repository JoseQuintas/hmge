#include "directry.ch"
#include "inkey.ch"

PROCEDURE Main

   SetMode(30,100)
   CLS
   Format( ".\" )

   RETURN


FUNCTION Format( cPath )

   LOCAL aList, aFile, cFileName, cText, cText2

   aList := Directory( cPath + "*.*", "D" )

   FOR EACH aFile IN aList
      cFileName := aFile[ F_NAME ]
      DO CASE
      CASE cFileName == "." .OR. cFileName  == ".."
      CASE aFile[ F_ATTR ] == "D"
         ? cPath
         Format( cPath + cFileName + "\" )
      OTHERWISE
         IF hb_AScan( { ".XML", ".LOG", ".HTML", ".URL", ".BAT", ".PRG", ".TXT", ".HBP", ".HBC", ".RC", ".C", ".H", ".CH", ".HBX", ".FMG", ".INI" }, { | e | e == Upper( Right( cFileName, Len( e ) ) ) } ) != 0
            cFileName := cPath + aFile[ F_NAME ]
            cText := MemoRead( cFileName )
            cText2 := cText
            cText := StrTran( cText, Chr(13), "" )
            cText := StrTran( cText, Chr(10), hb_Eol() )
            IF ! cText == cText2
               ? cFileName
               hb_MemoWrit( cFileName, cText )
            ENDIF
         ENDIF
      ENDCASE
   NEXT

   RETURN Nil
