// --------------------
// Simple app for creating backup of source files
//
// Created 2012 by Marek Olszewski "MOL" <mol@pro.onet.pl>
//
//
// It's free software! You can change everything!
//
// This software is provided AS IS
//
// --------------------
// Revised 20/03/12 by Bicahi Esgici <esgici@gmail.com>
//
// Adapted for Minigui Extended Edition by Grigory Filatov <gfilatov@gmail.com>
// --------------------

#include <minigui.ch>

STATIC cGlobalArchiveName
STATIC cAppFolder
STATIC aFileKinds
STATIC cDestinationFolder, nArchiveNameCreatingMethod, cArchiveName, nOverwriteArchive
// --------------------
FUNCTION MAIN

   LOCAL cFileKinds_FNam := "FilKinds.lst", ;   // File kinds file name
      cFileKinds := "" // File kinds string

   aFileKinds := {} // File kinds array
   cDestinationFolder := GetCurrentFolder() + "\_Backup"
   nArchiveNameCreatingMethod := 2
   cArchiveName := ""
   nOverwriteArchive := 0

   cAppFolder := GetStartUpFolder()

   cGlobalArchiveName := SubStr( cAppFolder, RAt( "\", cAppFolder ) + 1 )

   IF Empty( cGlobalArchiveName )
      cGlobalArchiveName := "BACKUP"
   ENDIF

   // You can realize getting previous saved settings
   BEGIN INI FILE cAppFolder+"\archiwizacja.ini"
      GET cDestinationFolder SECTION "GLOBALNE" ENTRY "FolderArchiwum" DEFAULT cDestinationFolder
      GET nArchiveNameCreatingMethod SECTION "GLOBALNE" ENTRY "Wybor" DEFAULT nArchiveNameCreatingMethod
      GET cGlobalArchiveName SECTION "GLOBALNE" ENTRY "Nazwa" DEFAULT cGlobalArchiveName
      GET nOverwriteArchive SECTION "GLOBALNE" ENTRY "NadpisujArchiwum" DEFAULT nOverwriteArchive
   END INI

   IF File( cFileKinds_FNam )
      cFileKinds := MemoRead( cFileKinds_FNam ) // File kinds string
      IF ! Empty( cFileKinds )
         aFileKinds := hb_ATokens( cFileKinds, CRLF )
      ENDIF
   ENDIF

   IF Empty( aFileKinds )
      aFileKinds := { "PRG", "FMG" }
   ENDIF

   AEval( aFileKinds, {| c1, i1 | aFileKinds[ i1 ] := "*." + c1 } )

   LOAD WINDOW BackUp

   ON KEY ESCAPE OF BackUp ACTION BackUp.Release()
   ON KEY F2 OF BackUp ACTION MakeBackup()

   BackUp.T_BackupName.VALUE := cArchiveName
   Backup.T_BackupFolder.VALUE := cDestinationFolder
   BackUp.R_ArchiveNameCreatingMethod.VALUE := nArchiveNameCreatingMethod
   BackUp.T_BackupName.READONLY := ( nArchiveNameCreatingMethod <> 3 )
   BackUp.CH_OverwriteBackupsWithoutWarning.VALUE := ( nOverwriteArchive > 0 )

   CENTER WINDOW BackUp
   ACTIVATE WINDOW BackUp

RETURN NIL
// -------------------
PROCEDURE SelectBackupHolder

   LOCAL cGetFolder

   cGetFolder := GetFolder( 'Select folder', ;
      iif( hb_DirExists( Backup.T_BackupFolder.Value ), Backup.T_BackupFolder.VALUE, GetCurrentFolder() ) )
   if ! Empty( cGetFolder )
      backup.T_BackupFolder.VALUE := cGetFolder
   ENDIF

RETURN
// -------------------
PROCEDURE CreateArchiveName

   LOCAL cArchiveName := cGlobalArchiveName

   SWITCH BackUp.R_ArchiveNameCreatingMethod.VALUE
   CASE 1
      // only name
      BackUp.T_BackupName.VALUE := cArchiveName
      BackUp.T_BackupName.READONLY := .T.
      EXIT
   CASE 2
      // name + date
      BackUp.T_BackupName.VALUE := cArchiveName + "_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" )
      BackUp.T_BackupName.READONLY := .T.
      EXIT
   CASE 3
      // user choice
      BackUp.T_BackupName.READONLY := .F.
   END SWITCH

RETURN
// -------------------
#command COMPRESS [ FILES ] <afiles> ;
      TO <zipfile> ;
      BLOCK <block> ;
      [ <ovr: OVERWRITE> ] ;
      [ <srp: STOREPATH> ] ;
      [ PASSWORD <password> ] ;
      = > ;
      COMPRESSFILES ( <zipfile>, <afiles>, <block>, <.ovr.>, <.srp.>, <password> )
// -------------------
PROCEDURE MakeBackup

   LOCAL aFilesToBackup := {}, cArchiveName := "", cFileKind, aTemp

   cArchiveName := AllTrim( backup.T_BackupFolder.Value )
   IF SubStr( cArchiveName, -1 ) <> "\"
      cArchiveName += "\"
   ENDIF

   if ! hb_DirExists( cArchiveName )
      if ! CreateFolder( cArchiveName )
         MsgStop( "Creating archive folder unsuccessful! Operation is stopped!" )
         RETURN
      ENDIF
   ENDIF

   cArchiveName += AllTrim( BackUp.T_BackupName.Value ) + ".ZIP"

   IF File( cArchiveName ) .AND. ! BackUp.CH_OverwriteBackupsWithoutWarning.VALUE
      if ! MsgYesNo( "Backup file: " + cArchiveName + CRLF + "already exists! Overwrite it?", "Confirmation", .T. )
         RETURN
      ENDIF
   ENDIF

   BackUp.ProgressIndicator.Visible := .T.

   FOR EACH cFileKind IN aFileKinds
      aTemp := Directory( cFileKind )
      AEval( aTemp, {| a1 | AAdd( aFilesToBackup, a1[ 1 ] ) } )
   NEXT

   IF Empty( aFilesToBackup )
      MsgStop( "No files found to backup !", " ERROR !" )
   ELSE
      BackUp.ProgressIndicator.RangeMax := Len( aFilesToBackup )
      BackUp.ProgressIndicator.VALUE := 0

      COMPRESS aFilesToBackup ;
         TO cArchiveName ;
         BLOCK {| cFile, nPos | BackUp.ProgressIndicator.VALUE := nPos } ;
         OVERWRITE

      // You can save backub settings here
      SaveBackupConfiguration()

      msgbox( "Backup was created successfully!", "Result" )
      BackUp.RELEASE
   ENDIF

RETURN
// -------------------
FUNCTION SaveBackupConfiguration

   BEGIN INI FILE cAppFolder+"\archiwizacja.ini"
      SET SECTION "GLOBALNE" ENTRY "FolderArchiwum" TO alltrim(backup.T_BackupFolder.Value)
      SET SECTION "GLOBALNE" ENTRY "Wybor" TO BackUp.R_ArchiveNameCreatingMethod.Value
      SET SECTION "GLOBALNE" ENTRY "Nazwa" TO BackUp.T_BackupName.Value
      SET SECTION "GLOBALNE" ENTRY "NadpisujArchiwum" TO if(BackUp.CH_OverwriteBackupsWithoutWarning.Value, 1, 0)
   END INI

RETURN NIL
// -------------------
PROCEDURE COMPRESSFILES ( cFileName, aDir, bBlock, lOvr, lStorePath, cPassword )

   LOCAL hZip, cZipFile, i

   IF ValType ( lOvr ) == 'L'
      IF lOvr == .T.
         IF File ( cFileName )
            DELETE FILE ( cFileName )
         ENDIF
      ENDIF
   ENDIF

   hZip := hb_ZipOpen ( cFileName )
   IF ! Empty( hZip )
      FOR i := 1 TO Len ( aDir )
         IF ValType ( bBlock ) == 'B'
            Eval ( bBlock, aDir[ i ], i )
         ENDIF
         cZipFile := iif( lStorePath, aDir[ i ], cFileNoPath( aDir[ i ] ) )
         hb_ZipStoreFile ( hZip, aDir[ i ], cZipFile, cPassword )
      NEXT
   ENDIF

   hb_ZipClose ( hZip )

RETURN
