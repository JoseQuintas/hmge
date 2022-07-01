
#include <hmg.ch>

*------------------------------------------------------------------------------*
PROCEDURE MAIN
*------------------------------------------------------------------------------*

   IF File( "BACKUP.ZIP" )
      DELETE FILE BACKUP.ZIP
   ENDIF

   LOAD WINDOW DEMO AS Form_1

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN

*------------------------------------------------------------------------------*
FUNCTION CreateZip()
*------------------------------------------------------------------------------*
   LOCAL aDir := Directory( "*.*", "D" ), aFiles := {}, nLen
   LOCAL cPath := CurDrive() + ":\" + CurDir() + "\"

   FillFiles( aFiles, aDir, cPath )

   IF ( nLen := Len( aFiles ) ) > 0
      Form_1.ProgressBar_1.RangeMin := 1
      Form_1.ProgressBar_1.RangeMax := nLen
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 0 }

      COMPRESS aFiles ;
         TO 'Backup.Zip' ;
         BLOCK {| cFile, nPos | ProgressUpdate( nPos, cFile, .T. ) } ;
         LEVEL 9 ;
         OVERWRITE ;
         STOREPATH

      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 255 }
      Form_1.Label_1.VALUE := 'Backup is finished'
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION ProgressUpdate( nPos, cFile, lShowFileName )
*------------------------------------------------------------------------------*

DEFAULT lShowFileName := .F.

   Form_1.ProgressBar_1.VALUE := nPos
   Form_1.Label_1.VALUE := cFileNoPath( cFile )

   IF lShowFileName
      Inkey( .1 )
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION UnZip()
*------------------------------------------------------------------------------*
   LOCAL cCurDir := GetCurrentFolder(), cArchive

   cArchive := Getfile ( { { 'Zip Files', '*.ZIP' } }, 'Open File', cCurDir, .F., .T. )

   IF ! Empty( cArchive )
      Form_1.ProgressBar_1.RangeMin := 1
      Form_1.ProgressBar_1.RangeMax := Len( HB_GetFilesInZip( cArchive ) ) - 1
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 0 }

      UNCOMPRESS cArchive ;
         EXTRACTPATH cCurDir + "\BackUp" ;
         BLOCK {| cFile, nPos | ProgressUpdate( nPos, cFile, .T. ) } ;
         CREATEDIR

      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 255 }
      Form_1.Label_1.VALUE := 'Restoration of Backup is finished'
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION FillFiles( aFiles, cDir, cPath )
*------------------------------------------------------------------------------*
   LOCAL aSubDir, cItem

   FOR cItem := 1 TO Len( cDir )
      IF cDir[ cItem ][ 5 ] <> "D"
         AAdd( aFiles, cPath + cDir[ cItem ][ 1 ] )
      ELSEIF cDir[ cItem ][ 1 ] <> "." .AND. cDir[ cItem ][ 1 ] <> ".."
         aSubDir := Directory( cPath + cDir[ cItem ][ 1 ] + "\*.*", "D" )
         aFiles := FillFiles( aFiles, aSubdir, cPath + cDir[ cItem ][ 1 ] + "\" )
      ENDIF
   NEXT

RETURN aFiles
