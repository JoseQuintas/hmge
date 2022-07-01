/*

  REPAIR.PRG   Main Database Repair Function

*/
#include "cldbfix.ch"
#include "error.ch"

#define CRLF      chr(13)+chr(10)

#define MAX_64K   65500 // 65516 is the most I can get into a string w/o an overflow.
                        // 65520 is the max memo size as defined by Comix.
#define TYPE_FPT  1
#define TYPE_III  2
#define TYPE_IV   3

#define MEMO_HDR_SIZE   512 // Standard memo header size for all types

#define ERR_BLANK "B"
#define ERR_SIZE  "S"
#define ERR_EOF   "T"

STATIC lLog, hLog, nMemoType, nBlockSize, nMemoEOF, nMaxMemoSize


FUNCTION DBRepair( cDbf, cLog, cDonor, cRDD, cJunkChar, ;
      lPreload, lDeleted, lPartial, lTotal, lCharJunk, lMemoJunk )

   LOCAL cTitle := "Database Repair: " + FileParts( cDbf, FP_FILENAME )
   LOCAL lOk := .F., lRestore := .F., lRestMemo := .F., lRestIndex := .F.
   LOCAL hDBF, nEvery, nBytes, f, i, n, x
   LOCAL cTemp, cMsg, cRecord, cField, cBakDbf, cBakIndex, cIndex
   LOCAL cMemo, cBakMemo, cMemoDups, cMemoData, hMemo, lMemo := .F.
   LOCAL nDBFSize, nRecCount, nHdrLen, nRecLen, nFields
   LOCAL aStruct_ := {}, aTemp_ := Array( 4 ), cEOF := Chr( 26 )
   LOCAL nSaved := 0, nLost := 0, nDamaged := 0, nDeleted := 0
   LOCAL nDCount, nProcessed := 0, lDamage
   LOCAL cCont := "Correct this error and attempt to continue?"
   LOCAL lDonor := ! Empty( cDonor )
   LOCAL lLogDeleted := .F. // GetIni(INI_SECT, "LogDeleted", .F.)
   LOCAL lCopyBackup := .F. // GetIni(INI_SECT, "CopyBackup", .F.)
   LOCAL lSaveTemp := .F. // GetIni(INI_SECT, "SaveTemp",   .F.)
   LOCAL lEnd := .F.
   LOCAL nLastPercent := 0

   nMaxMemoSize := 60000 // min(GetIni(INI_SECT, "MaxMemoSize", MAX_64K), MAX_64K)

   nBlockSize := 0

   // Set these "undocumented" INI entries so they're easier to edit:

   // SetIni(INI_SECT, "LogDeleted",  lLogDeleted)
   // SetIni(INI_SECT, "CopyBackup",  lCopyBackup)
   // SetIni(INI_SECT, "SaveTemp",    lSaveTemp)
   // SetIni(INI_SECT, "MaxMemoSize", nMaxMemoSize)

   // Set default values for parameters:

   cDbf := AllTrim( cDbf )

   DEFAULT cLog := "", ;
      cRDD := rddSetDefault(), ;
      cJunkChar := "?", ;
      lCharJunk := .F., ;
      lMemoJunk := .F., ;
      lDeleted := .F., ;
      lPartial := .F., ;
      lTotal := .F.

   cLog := AllTrim( cLog )

   lLog := ! Empty( cLog )
   hLog := F_ERROR

   // Make sure required files exist & ask to overwrite those that do:

   IF ! File( cDbf )
      ? cDbf + " not found."
      Return( .F. )
   ENDIF

   cBakDbf := RevExt( cDBF )

   IF File( cBakDbf )
      IF ! GetYesNo( "The backup file " + cBakDbf + " exists.  Overwrite?", .F. )
         Return( .F. )
      ENDIF
   ENDIF

   // If this file is less than 66 bytes, it can't be a dbf!

   IF FSize( cDbf ) < 66
      ? cDbf + " is too small to be a DBF file (minimum size is 66 bytes)."
      Return( .F. )
   ENDIF

   BEGIN SEQUENCE

      // Start the log:

      IF lLog
         IF File( cLog )
            IF ! GetYesNo( "The log file " + cLog + " exists.  Overwrite?", .F. )
               lLog := .F.
               break
            ENDIF
         ENDIF
         hLog := FCreate( cLog, FC_NORMAL )
         IF hLog == F_ERROR
            FileErrMsg( cLog, "creating" )
            lLog := .F.
            break
         ENDIF
         LogText( "CLDBFix v" + DBFIX_VERSION )
         LogText( "Database Repair Log: " + cDbf )
         LogText( "Repair started " + DToC( Date() ) + " " + Time() )
         LogText( CRLF + "Repair Options:" )
         LogText( "Preload memo data................" + Transform( lPreload, "Y" ) )
         LogText( "Save deleted records............." + Transform( lDeleted, "Y" ) )
         LogText( "Save partially damaged records..." + Transform( lPartial, "Y" ) )
         LogText( "  Save totally damaged records..." + Transform( lTotal, "Y" ) )
         LogText( "Allow junk in character fields..." + Transform( lCharJunk, "Y" ) )
         LogText( "Allow junk in memo fields........" + Transform( lMemoJunk, "Y" ) )
         LogText( "Junk replacement character......." + cJunkChar )
         IF lDonor
            LogText( CRLF + "Header Donor database: " + cDonor )
         ENDIF
      ENDIF

      // Convert a three-digit ASCII code into a real replacement character:

      IF Len( cJunkChar ) > 1
         cJunkChar := Chr( Val( cJunkChar ) )
      ENDIF

      // See if we can determine what RDD this file was created with, first by
      // finding an index that would give it away, then by looking at the
      // version byte:

      ? "Determining RDD..."
      IF Inkey() = K_ESC
         break
      ENDIF

      cTemp := cRDD
      cIndex := FindIndex( cDbf, @cTemp )
      IF ! Empty( cIndex )
         cRDD := cTemp
      ENDIF

      cTemp := iif( lDonor, cDonor, cDbf )
      n := FOpen( cTemp, FO_READ + FO_SHARED )
      IF n == F_ERROR
         FileErrMsg( cTemp )
         break
      ENDIF
      cField := " "
      FRead( n, @cFIELD, 1 )
      FClose( n )
      n := Asc( cField )

      LogText( CRLF + "DBF version byte: " + Nstr( n ) )

      cMemo := NewExt( cDbf, ".DBT" )

      DO CASE
      CASE n == 2 .OR. n == 3 .OR. n == 4
         // Database without a memo - use the default RDD
      CASE n == 11
         // dBase IV without memo
         IF cRDD <> "DBFIV" .AND. cRDD <> "DBFMDX"
            cRDD := "DBFMDX"
         ENDIF
      CASE n == 131
         // dBase III with memo
         lMemo := .T.
         IF cRDD <> "DBF" .AND. cRDD <> "DBFNDX" .AND. cRDD <> "DBFNTX"
            cRDD := "DBFNTX"
         ENDIF
      CASE n == 139
         // dBase IV with memo
         lMemo := .T.
         IF cRDD <> "DBFIV" .AND. cRDD <> "DBFMDX"
            cRDD := "DBFMDX"
         ENDIF
      CASE n == 245
         // Comix/DBFCDX/FoxPro with memo
         lMemo := .T.
         cMemo := NewExt( cDbf, ".FPT" )
         IF cRDD <> "SIXCDX" .AND. cRDD <> "DBFCDX"
            cRDD := "SIXCDX"
         ENDIF
      CASE File( cMemo ) // *.DBT?
         lMemo := .T.
         cRDD := DBT_Type( cMemo, cRDD )
      CASE File( cMemo := NewExt( cDbf, ".FPT" ) )
         lMemo := .T.
         IF cRDD <> "SIXCDX" .AND. cRDD <> "DBFCDX"
            cRDD := "SIXCDX"
         ENDIF
      ENDCASE

      IF lMemo
         LogText( "Memo file: " + cMemo )
      ENDIF
      IF ! Empty( cIndex )
         LogText( "Index file: " + cIndex )
      ENDIF

      LogText( "Using " + cRDD + " RDD", .T. )
      LogText( "Maximum memo size: " + Nstr( nMaxMemoSize ) )
      rddSetDefault( cRDD )

      // Make sure the memo file is present if required...

      IF lMemo
         IF ! File( cMemo )
            cMsg := "Memo file not found.  "
            IF GetYesNo( cMsg + "Proceed without memo data?", .F. )
               LogText( cMsg + "Proceeding without memo." + CRLF )
               lMemo := .F.
            ELSE
               LogText( cMsg + "Repair cancelled." + CRLF, .T. )
               break
            ENDIF
         ENDIF
      ENDIF

      // Copy the original file to the backup name:

      // Copying is used rather than just renaming due to certain OS errors
      // involving misreported file sizes (such as the Novell Turbo-FAT bug).
      // This can be turned off by changing the "CopyBackup" INI entry.

      // I changed the default to renaming because copying takes so long...

      ? "Creating backup..."
      IF Inkey() = K_ESC
         break
      ENDIF

      cTemp := iif( lCopyBackup, " copied to ", " renamed to " )

      IF iif( lCopyBackup, CopyFile( cDbf, cBakDbf ), RenFile( cDbf, cBakDbf ) )
         LogText( CRLF + cDbf + cTemp + cBakDbf )
         FErase( cDbf )
         lRestore := .T.
         IF lMemo
            cBakMemo := RevExt( cMemo )
            IF iif( lCopyBackup, CopyFile( cMemo, cBakMemo ), RenFile( cMemo, cBakMemo ) )
               lRestMemo := .T.
               LogText( cMemo + cTemp + cBakMemo )
               FErase( cMemo )
            ELSE
               LogText( "Failed to create backup of memo.", .T. )
               break
            ENDIF
         ENDIF
         IF ! Empty( cIndex )
            cBakIndex := RevExt( cIndex )
            IF RenFile( cIndex, cBakIndex )
               lRestIndex := .T.
               LogText( cIndex + " renamed to " + cBakIndex )
            ELSE
               LogText( "Failed to create backup of index.", .T. )
               break
            ENDIF
         ENDIF
      ELSE
         LogText( CRLF + "Failed to create backup of DBF.", .T. )
         break
      ENDIF

      // Read the header from the corrupt file:

      ? "Reading header..."
      IF Inkey() = K_ESC
         break
      ENDIF

      lOk := .T.

      hDbf := FOpen( cBakDbf, FO_READ + FO_EXCLUSIVE )

      IF hDbf == F_ERROR
         FileErrMsg( cBakDbf )
         hDbf := NIL
         break
      ENDIF

      IF lMemo
         hMemo := FOpen( cBakMemo, FO_READ + FO_EXCLUSIVE )
         IF hMemo == F_ERROR
            FileErrMsg( cBakMemo )
            hMemo := NIL
            break
         ENDIF
      ENDIF

      nDBFSize := FSeek( hDbf, 0, FS_END )
      FSeek( hDbf, 0, FS_SET )

    /* Main Header Structure - first 32 bytes

    Pos     Data
    --------------------------
    1       Version byte
    2-4     Last update (ymd)
    5-8     Record count
    9-10    Header length
    11-12   Record length
    13-32   Reserved
    --------------------------
    */

      cRecord := Space( 32 )
      FRead( hDbf, @cRecord, 32 )

      cField := SubStr( cRecord, 5, 4 )
      nRecCount := CtoN( cField )

      cField := SubStr( cRecord, 9, 2 )
      nHdrLen := CtoN( cField )

      cField := SubStr( cRecord, 11, 2 )
      nRecLen := CtoN( cField )

      IF lDonor

         IF NetUse( cDonor + " alias Donor readonly", .F.,, .F. ) // Don't open index
            nRecLen := Donor->( RecSize() )
            nHdrLen := Donor->( Header() )
            nFields := Donor->( FCount() )
            aStruct_ := Donor->( dbStruct() )
            Donor->( dbCloseArea() )
         ELSE
            lOk := .F.
            break
         ENDIF

      ELSE

      /*

      Try to find the actual end of the header to see if it matches the
      header length read from the file.

      In a Clipper database where nHdrLen will always be an even number,
      we should find chr(13)+chr(0) at offset (nHdrLen - 2).  In any case
      it will always be on a 32-byte boundary at offset 64 or greater.

      For dBase databases, nHdrLen will be an odd number and the chr(13)
      should be found at (nHdrLen - 1).

      */

         lOk := .F.
         i := Chr( 13 )
         cTemp := Space( 32 )

         n := 64 // This is the earliest place it could be (main hdr + 1 field)
         FSeek( hDbf, n, FS_SET )

         DO WHILE FRead( hDbf, @cTemp, 32 ) == 32
            IF Left( cTemp, 1 ) == i // Found it!
               lOk := .T.
               n++
               IF SubStr( cTemp, 2, 1 ) == Chr( 0 )
                  n++
               ENDIF
               EXIT
            ENDIF
            n += 32
         ENDDO

         FSeek( hDbf, 32, FS_SET ) // Return to the end of the main file header

      /*

      If unable to find the terminator, that part of the file must have
      been damaged so we'll have to go by the value from the header.  If
      we did find it, make sure it matches:

      */

         IF lOk .AND. n <> nHdrLen
            // "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
            ? "The file header reports the header length as " + Nstr( nHdrLen ) + ", but the header terminator"
            x := GetYesNo( "was found at position " + Nstr( n ) + ".  Use the found value instead?" )
            IF x == NIL
               lOk := .F.
               break
            ELSEIF x
               LogText( CRLF + "Header length changed from " + Nstr( nHdrLen ) + ;
                  " to the location of the terminator found at " + Nstr( n ) + "." )
               nHdrLen := n
            ENDIF
         ENDIF

         lOk := .T.

         // Is the dbf big enough to hold the header?

         IF nHdrLen > nDBFSize
            LogText( "Database header truncated by eof.  Data is unrecoverable.", .T. )
            lOk := .F.
            break
         ENDIF

         // Retrieve the database structure:

         nFields := ( Int( nHdrLen / 32 ) - 1 ) // Calculate # of fields

         x := 1 // Count the record length.  Start with 1 for the deleted byte.

         FOR f := 1 TO nFields

        /* Field Header Structure

        Pos     Data
        -------------------------------
        1-11    Name (padded w/ chr(0))
        12      Type
        13-16   Reserved
        17      Length
        18      Decimals
        19-32   Reserved
        -------------------------------
        */

            IF FRead( hDbf, @cRecord, 32 ) <> 32
               FileErrMsg( cBakDbf, "reading" )
               lOk := .F.
               EXIT
            ENDIF

            // Name:
            cField := SubStr( cRecord, 1, 11 )
            cTemp := Left( cField, At( Chr( 0 ), cField ) - 1 )
            IF ! FieldValid( cTemp, .F. )
               lOk := .F.
               LogText( CRLF + "Field #" + Nstr( f ) + " has an invalid field name: " + cTemp )
               ? "Field #" + Nstr( f ) + " has an invalid field name."
               IF GetYesNo( "Would you like to try and correct it?", .F. )
                  DO while ! FieldValid( cTemp, .F. )
                     ACCEPT "Enter the corrected field name (blank to cancel): " TO cTemp
                     IF Empty( cTemp )
                        EXIT
                     ENDIF
                     cTemp := Upper( Left( AllTrim( cTemp ), 10 ) )
                  ENDDO
                  IF ! Empty( cTemp )
                     lOk := .T.
                     LogText( "Field #" + Nstr( f ) + " name corrected to " + cTemp )
                  ENDIF
               ENDIF
               IF ! lOk
                  EXIT
               ENDIF
            ENDIF
            aTemp_[ DBS_NAME ] := AllTrim( cTemp )

            // Type:
            cField := SubStr( cRecord, 12, 1 )
            IF .NOT. ( cField $ "CDLMN" )
               lOk := .F.
               IF ! IsAlpha( cField )
                  cField := "?"
               ENDIF
               LogText( CRLF + "Field " + aTemp_[ DBS_NAME ] + ;
                  " has an unsupported or invalid data type: " + cField )
               ? "Field " + aTemp_[ DBS_NAME ] + " has an unsupported or invalid data type (" + cField + ")."
               IF GetYesNo( "Would you like to try and correct it?", .F. )
                  DO WHILE At( cField, "CDLMN" ) == 0
                     ACCEPT "Enter the correct data type (C,D,L,M,N, blank to cancel): " TO cField
                     IF Empty( cField )
                        EXIT
                     ENDIF
                     cField := Upper( Left( cField, 1 ) )
                  ENDDO
                  IF ! Empty( cField )
                     lOk := .T.
                     LogText( "Field " + aTemp_[ DBS_NAME ] + ;
                        " data type corrected to " + cField )
                  ENDIF
               ENDIF
               IF ! lOk
                  EXIT
               ENDIF
            ENDIF
            aTemp_[ DBS_TYPE ] := cField

            // Assign type adjective and required length (0=any length)
            DO CASE
            CASE cField == "C"
               cTemp := "character"
               i := 0
            CASE cField == "D"
               cTemp := "date"
               i := 8
            CASE cField == "L"
               cTemp := "logical"
               i := 1
            CASE cField == "M"
               cTemp := "memo"
               i := 10
            CASE cField == "N"
               cTemp := "numeric"
               i := 0
            ENDCASE

            // Length:
            cField := SubStr( cRecord, 17, 1 )
            n := Asc( cField )
            IF i > 0 .AND. n <> i
               cMsg := "The " + cTemp + " field " + aTemp_[ DBS_NAME ] + ;
                  " should have a length of " + Nstr( i ) + ;
                  ", but is reporting a length of " + Nstr( n ) + "."
               ? cMsg
               IF GetYesNo( cCont, .F. )
                  LogText( CRLF + cMsg + " - Corrected" )
                  n := i
               ELSE
                  LogText( CRLF + cMsg )
                  lOk := .F.
                  EXIT
               ENDIF
            ENDIF
            aTemp_[ DBS_LEN ] := n

            // Decimals:
            cField := SubStr( cRecord, 18, 1 )
            n := Asc( cField )
            IF n > 0
               IF aTemp_[ DBS_TYPE ] == "C" // Char field > 255 length
                  aTemp_[ DBS_LEN ] += ( n * 256 )
                  n := 0
               ELSEIF aTemp_[ DBS_TYPE ] $ "DLM"
                  cMsg := "The " + cTemp + " field " + aTemp_[ DBS_NAME ] + ;
                     " should not have a decimal value but is reporting " + ;
                     Nstr( n ) + " decimal places."
                  ? cMsg
                  IF GetYesNo( cCont, .F. )
                     LogText( CRLF + cMsg + " - Corrected" )
                     n := 0
                  ELSE
                     LogText( CRLF + cMsg )
                     lOk := .F.
                     EXIT
                  ENDIF
               ENDIF
            ENDIF
            aTemp_[ DBS_DEC ] := n

            // Add this field to the structure
            AAdd( aStruct_, AClone( aTemp_ ) )

            // Add the field length to the record length tally:
            x += aTemp_[ DBS_LEN ]

            lEnd := Inkey() == K_ESC
            IF lEnd
               lOk := .F.
               break
            ENDIF

         NEXT

         // Check the record length:

         IF lOk .AND. x <> nRecLen
            cMsg := "The database header gives a record length of " + ;
               Nstr( nRecLen ) + ".  The database structure indicates a" + ;
               " record length of " + Nstr( x ) + "."
            ? cMsg
            IF GetYesNo( cCont, .F. )
               LogText( CRLF + cMsg + " - Corrected" )
               nRecLen := x
            ELSE
               LogText( CRLF + cMsg )
               lOk := .F.
            ENDIF
         ENDIF

         // Did any of the above fail?

         cTemp := cDbf + " can not be repaired due to "

         IF ! lOk .AND. ! lEnd
            cMsg := cTemp + "header damage."
            LogText( CRLF + cMsg, .T. )
            break
         ENDIF

      ENDIF // lDonor

      // See how often we need to update the meter (at least every 100 recs):

      nEvery := Crop( 1, Int( ( nDBFSize / nRecLen ) / 100 ), 100 )

      // Initialize the memo data:

      IF lMemo
         IF MemoInit( hMemo, cRDD ) > 0 // Returns nBlockSize
            // Create a database to detect duplicate memos:
            cMemoDups := Temp_Name( ".TMP", FileParts( cDbf, FP_PATH ) )
            dbCreate( cMemoDups, { { "POINTER", "C", 10, 0 }, ;
               { "RECORD", "N", 10, 0 }, ;
               { "FIELD", "C", 10, 0 } }, "SIXCDX" )
            IF ! NetUse( cMemoDups + " alias MemoDups via SIXCDX", .T. )
               lOk := .F.
               break
            ENDIF
            SELECT MemoDups
            INDEX on ( "POINTER" ) TAG POINTER
            // Preload all the memo data:
            IF lPreload
               cMemoData := Temp_Name( ".TMP", FileParts( cDbf, FP_PATH ) )
               dbCreate( cMemoData, { { "POINTER", "C", 10, 0 }, ;
                  { "ERROR", "C", 1, 0 }, ;
                  { "MEMOTEXT", "M", 10, 0 } }, "SIXCDX" )
               IF ! NetUse( cMemoData + " alias MemoData via SIXCDX", .T. )
                  lOk := .F.
                  break
               ENDIF
               SELECT MemoData
               INDEX on ( "POINTER" ) TAG POINTER
               IF ! MemoPreload( hMemo, @lEnd )
                  lOk := .F.
                  break
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      // Create a new copy of the database and open it up:

      ? "Creating new database..."

      dbCreate( cDbf, aStruct_ )
      IF ! NetUse( cDbf + " alias Target", .T. )
         lOk := .F.
         break
      ENDIF

      // Begin reading the data:

      ? "Evaluating data..."

      LogText( "" )

      FSeek( hDbf, nHdrLen, FS_SET ) // Position to start of data

      aTemp_ := Array( nFields )

      cRecord := Space( nRecLen )

      nBytes := nRecLen

      DO WHILE lOk .AND. nBytes == nRecLen

         nBytes := FRead( hDbf, @cRecord, nRecLen )

         IF nBytes == 0 .OR. ; // No more data?
            ( nBytes == 1 .AND. Left( cRecord, nBytes ) == cEOF )
            EXIT
         ENDIF

         nProcessed++

         IF nBytes < nRecLen // Was this record truncated by eof?
            LogText( "Record #" + Nstr( nProcessed ) + ;
               " truncated by eof after " + Nstr( nBytes ) + " bytes." )
            cRecord := Left( cRecord, nBytes )
         ENDIF

         IF ! lDeleted // Ignore deleted records?
            IF Left( cRecord, 1 ) == "*"
               IF lLogDeleted
                  LogText( "Deleted record #" + Nstr( nProcessed ) + " discarded." )
               ENDIF
               nDeleted++
               LOOP
            ENDIF
         ENDIF

         nDCount := 0 // Count the number of damaged fields

         x := 2
         FOR f := 1 TO nFields
            cMsg := "Record #" + Nstr( nProcessed ) + ;
               " field " + aStruct_[ f, DBS_NAME ] + " "
            cField := SubStr( cRecord, x, aStruct_[ f, DBS_LEN ] )
            x += aStruct_[ f, DBS_LEN ]
            DO CASE
            CASE Len( cField ) == 0 // -------------------------- Truncated by EOF
               nDCount++
               LogText( cMsg + "truncated by eof." )
               aTemp_[ f ] := NIL
            CASE aStruct_[ f, DBS_TYPE ] == "C" // --------------------- Character
               // Allow anything unless checking for junk
               IF ! lCharJunk
                  IF HasJunk( @cFIELD, .F., cJunkChar )
                     LogText( cMsg + "contains junk." )
                     nDCount++
                  ENDIF
               ENDIF
               aTemp_[ f ] := cField
            CASE aStruct_[ f, DBS_TYPE ] == "D" // -------------------------- Date
               // Dates must be valid or blank:
               aTemp_[ f ] := SToD( cField )
               IF DToS( aTemp_[ f ] ) <> cField
                  LogText( cMsg + "invalid date (" + cField + ")" )
                  nDCount++
               ENDIF
            CASE aStruct_[ f, DBS_TYPE ] == "L" // ----------------------- Logical
               // Logicals must be T or F.
               // Blank and ? are also valid for uninitialized data.
               aTemp_[ f ] := ( cField == "T" )
               IF !( cField $ "TF ?" )
                  LogText( cMsg + "invalid logical (" + cField + ")" )
                  nDCount++
               ENDIF
            CASE aStruct_[ f, DBS_TYPE ] == "M" // -------------------------- Memo
               aTemp_[ f ] := ""
               IF nBlockSize > 0 .AND. ! Empty( cField )
                  n := Val( cField )
                  IF n > 0 .AND. Str( n, 10, 0 ) == cField
                     IF ( n * nBlockSize ) > nMemoEOF
                        LogText( cMsg + "memo pointer * blocksize > eof: " + ;
                           AllTrim( cField ) )
                        nDCount++
                     ELSE
                        lDamage := MemoDupe( cField, cMsg, ;
                           aStruct_[ f, DBS_NAME ], nProcessed )
                        IF lPreLoad
                           cTemp := MemoSeek( cField, cMsg, @lDamage )
                        ELSE
                           cTemp := MemoRead( hMemo, cField, cMsg, @lDamage )
                        ENDIF
                        IF ! Empty( cTemp )
                           IF ! lMemoJunk
                              IF HasJunk( @cTemp, .T., cJunkChar )
                                 lDamage := .T.
                                 // If the whole thing is junk, don't bother saving it.
                                 IF AllJunk( cTemp, cJunkChar )
                                    cTemp := ""
                                    LogText( cMsg + "is 100% junk, memo discarded." )
                                 ELSE
                                    LogText( cMsg + "contains junk." )
                                 ENDIF
                              ENDIF
                           ENDIF
                           aTemp_[ f ] := cTemp
                        ENDIF
                        IF lDamage
                           nDCount++
                        ENDIF
                     ENDIF
                  ELSE
                     LogText( cMsg + "invalid memo pointer (" + cField + ")" )
                     nDCount++
                  ENDIF
               ENDIF
            CASE aStruct_[ f, DBS_TYPE ] == "N" // ----------------------- Numeric
               // Numbers must have the correct number of decimal places.
               // Blank numbers (including lone decimal points) are normal for
               // uninitialized data.
               n := Val( cField )
               cTemp := Str( n, aStruct_[ f, DBS_LEN ], aStruct_[ f, DBS_DEC ] )
               IF ! Empty( cField )
                  IF cTemp <> cField .AND. AllTrim( cField ) <> "."
                     LogText( cMsg + "invalid number (" + cField + ")" )
                     nDCount++
                  ENDIF
               ENDIF
               aTemp_[ f ] := Val( cTemp )
            ENDCASE
            IF ! lPartial .AND. nDCount > 0 // Not saving damaged records?
               nDCount := nFields // Pretend it's a total loss and move on.
               EXIT
            ENDIF
         NEXT

         IF nDCount == nFields .AND. ! lTotal // Was this record totalled?
            LogText( "Record #" + Nstr( nProcessed ) + " lost to corruption." )
            nLost++
            LOOP
         ENDIF

         Target->( dbAppend() ) // Add the record to the database
         FOR f := 1 TO nFields
            Target->( FieldPut( f, aTemp_[ f ] ) )
         NEXT

         IF Left( cRecord, 1 ) == "*" // Was this record deleted?  Preserve that.
            Target->( dbDelete() )
         ENDIF

         IF nDCount > 0 // Count the damaged/saved records
            // Log entry for easy lookup when the record numbers don't match:
            IF Target->( RecNo() ) <> nProcessed
               LogText( "Target record #" + Nstr( Target->( RecNo() ) ) + ;
                  " contains damaged data." )
            ENDIF
            nDamaged++
         ELSE
            nSaved++
         ENDIF

         IF nProcessed % nEvery == 0
            x := FSeek( hDbf, 0, FS_RELATIVE )
            x := Round( ( x / nDBFSize ) * 100, 0 )
            IF ( x % 10 == 0 ) .AND. ( x <> nLastPercent )
               ? "Repair " + Nstr( x ) + "% complete"
               nLastPercent := x
            ENDIF
            lEnd := Inkey() == K_ESC
            IF lEnd
               lOk := .F.
               break
            ENDIF
         ENDIF

      ENDDO

      Target->( dbCommit() )

   END SEQUENCE

   dbCloseAll()

   IF ! lSaveTemp
      IF ! Empty( cMemoDups )
         FErase( cMemoDups )
         FErase( NewExt( cMemoDups, "CDX" ) ) // IndexOf() uses the default RDD!
      ENDIF
      IF ! Empty( cMemoData )
         FErase( cMemoData )
         FErase( NewExt( cMemoData, "CDX" ) )
         FErase( NewExt( cMemoData, "FPT" ) )
      ENDIF
   ENDIF

   IF ValType( hDbf ) == "N"
      FClose( hDbf )
   ENDIF

   IF ValType( hMemo ) == "N"
      FClose( hMemo )
   ENDIF

   IF lOk

      n := Len( Nstr( Max( nRecCount, nProcessed ) ) ) // Length of longest number

      cMsg := Str( nRecCount, n ) + ;
         " records were reported in the original DBF header." + CRLF + ;
         Str( nProcessed, n ) + " records were processed."

      IF nDeleted > 0
         cMsg += CRLF + Str( nDeleted, n ) + " deleted records were discarded."
      ENDIF

      IF nLost > 0
         cMsg += CRLF + Str( nLost, n ) + " records were lost to corruption."
      ENDIF

      cMsg += CRLF + Str( nSaved + nDamaged, n ) + " records were saved." + ;
         CRLF + iif( nDamaged > 0, Str( nDamaged, n ), "None" ) + ;
         " of the saved records were damaged."

      IF lLog
         LogText( CRLF + "*** Repair Summary ***" + CRLF + cMsg, .T. )
         LogText( CRLF + "Repair ended " + DToC( Date() ) + " " + Time() )
      ENDIF

      ? "Repair Complete"
      ?

   ELSE

      LogText( "" )

      IF lEnd
         LogText( "Repair cancelled by user: " + ;
            DToC( Date() ) + " " + Time() + CRLF )
      ENDIF

      IF lRestore
         ? "Cancelled - Restoring original files..."
         IF RenFile( cBakDbf, cDbf )
            LogText( cBakDbf + " restored to " + cDbf )
            IF lRestMemo
               IF RenFile( cBakMemo, cMemo )
                  LogText( cBakMemo + " restored to " + cMemo )
               ELSE
                  cMsg := "Failed to restore " + cBakMemo + " to " + cMemo + "!"
                  LogText( CRLF + cMsg, .T. )
               ENDIF
            ENDIF
            IF lRestIndex
               IF RenFile( cBakIndex, cIndex )
                  LogText( cBakIndex + " restored to " + cIndex )
               ELSE
                  cMsg := "Failed to restore " + cBakIndex + " to " + cIndex + "!"
                  LogText( CRLF + cMsg, .T. )
               ENDIF
            ENDIF
         ELSE
            cMsg := "Failed to restore " + cBakDbf + " to " + cDbf + "!"
            LogText( CRLF + cMsg, .T. )
         ENDIF
      ENDIF

      IF lEnd
         ? "Repair Cancelled"
      ENDIF

   ENDIF

   IF hLog <> F_ERROR
      FClose( hLog )
   ENDIF

Return( lLog )



STATIC FUNCTION AllJunk( cMemo, cJunkChar )
/*
  Returns true if a memo consists entirely of cJunkChar and/or whitespace.
*/

   LOCAL lAllJunk := .T.
   LOCAL cJunk := cJunkChar + " " + Chr( 9 ) + Chr( 10 ) + Chr( 13 ) + Chr( 141 )
   LOCAL x, nLen := Len( cMemo )

   FOR x := 1 TO nLen
      IF .NOT. SubStr( cMemo, x, 1 ) $ cJunk
         lAllJunk := .F.
         EXIT
      ENDIF
   NEXT

Return( lAllJunk )



STATIC FUNCTION CopyFile( cSource, cTarget )

   COPY File ( cSource ) to ( cTarget )

Return( File( cTarget ) )



STATIC FUNCTION DBT_Type( cMemo, cDefault )

   LOCAL cRDD := cDefault
   LOCAL h, cTemp := ""

   IF ! File( cMemo ) // No memo?  Worry about it later...
      Return( cRDD )
   ENDIF

   FindIndex( cMemo, @cTemp ) // Got a good index to go by?  Use it.
   IF ! Empty( cTemp )
      Return( cTemp )
   ENDIF

   h := FOpen( cMemo, FO_READ + FO_SHARED )

   IF h == F_ERROR
      FileErrMsg( cMemo )
      Return( cRDD )
   ENDIF

   // Try to find something in the header to clue us in:

   cTemp := Space( MEMO_HDR_SIZE )
   FRead( h, cTemp, MEMO_HDR_SIZE )
   FClose( h )

   DO CASE
   CASE SubStr( cTemp, 32, 6 ) == "DBFNTX"
      cRDD := "DBFNTX"
   CASE SubStr( cTemp, 32, 6 ) == "DBFNDX"
      cRDD := "DBFNDX"
   CASE SubStr( cTemp, 32, 3 ) == "DBF"
      cRDD := "DBF"
   CASE ".NTX" $ cTemp
      cRDD := "DBFNTX"
   CASE ".NDX" $ cTemp
      cRDD := "DBFNDX"
   CASE ".MDX" $ cTemp
      cRDD := "DBFMDX"
   CASE cRDD == "SIXCDX" .OR. cRDD == "DBFCDX"
      // Unable to determine anything from the header.  If the default RDD
      // is set to the wrong type (FPT memos), change to DBFNTX since it's
      // the Clipper default.
      cRDD := "DBFNTX"
   ENDCASE

Return( cRDD )



STATIC FUNCTION FieldValid( cName, lMsgs )
/*
  Returns a logical indicating if cName is a valid field name
*/
Return( GenValid( cName, "NE,<@,MCO@#_",,, lMsgs ) )



STATIC FUNCTION FileErrMsg( cFile, cVerb )

   LOCAL cMsg

DEFAULT cVerb := "opening"

   cMsg := "Error #" + Nstr( FError() ) + " " + cVerb + " " + cFile

   IF hLog <> F_ERROR
      LogText( cMsg )
   ENDIF

   ? cMsg

Return( NIL )



STATIC FUNCTION FindIndex( cDbf, cRDD )

   LOCAL aExt_ := { "CDX", "IDX", "MDX", "NDX", "NTX" }
   LOCAL aRDD_ := { "SIXCDX", "DBFCDX", "DBFMDX", "DBFNDX", "DBFNTX" }
   LOCAL cStub := StripExt( cDbf ) + "."
   LOCAL x, cIndex := ""

   FOR x := 1 TO Len( aExt_ )
      IF File( cStub + aExt_[ x ] )
         cIndex := cStub + aExt_[ x ]
         cRDD := aRDD_[ x ]
         EXIT
      ENDIF
   NEXT

Return( cIndex )



STATIC FUNCTION HasJunk( cText, lMemo, cJunkChar )
/*
  Checks a character var for low/high ASCII characters.  If cText is passed
  by reference, these occurences will be replaced with <cJunkChar>.
*/

   LOCAL nLen, n, x
   LOCAL lJunk := .F.

#ifdef SHOWJUNK
   LOCAL cJunk := ""

#endif

   nLen := Len( RTrim( cText ) )

   FOR x := 1 TO nLen
      n := Asc( SubStr( cText, x, 1 ) )
      IF n < 32 .OR. n > 126
         lJunk := iif( lMemo, ;
            .NOT. ( n == 9 .OR. n == 10 .OR. n == 13 .OR. n == 141 ), ;
            .T. )
         IF lJunk
            cText := InsDel( cText, x, 1, cJunkChar )

#ifdef SHOWJUNK
            cJunk += Nstr( n ) + " "

#endif
         ENDIF
      ENDIF
   NEXT

#ifdef SHOWJUNK
   IF lJunk
      LogText( cJunk )
   ENDIF

#endif

Return( lJunk )



STATIC FUNCTION LogText( cMsg, lShow )

DEFAULT lShow := .F.

   IF lLog
      FWriteLn( hLog, cMsg )
   ENDIF

   IF ! lLog .OR. lShow
      ? cMsg
   ENDIF

Return( NIL )



STATIC FUNCTION MemoDupe( cPointer, cMsg, cFieldName, nRecno )

   LOCAL lDupe := .F.

   IF MemoDups->( dbSeek( cPointer ) )
      lDupe := .T.
      LogText( cMsg + "duplicate memo pointer of record #" + ;
         Nstr( MemoDups->RECORD ) + " field " + ;
         AllTrim( MemoDups->FIELD ) + ": " + ;
         AllTrim( cPointer ) )
   ELSE
      MemoDups->( dbAppend() )
      MemoDups->POINTER := cPointer
      MemoDups->RECORD := nRecno
      MemoDups->FIELD := cFieldName
      MemoDups->( XCommit( .T. ) )
   ENDIF

Return( lDupe )



STATIC FUNCTION MemoInit( hMemo, cRDD )

   LOCAL cBuff, cTemp, n

   DO CASE
   CASE cRDD $ "DBF,DBFNDX,DBFNTX"
      nMemoType := TYPE_III
   CASE cRDD $ "DBFIV,DBFMDX"
      nMemoType := TYPE_IV
   CASE cRDD $ "SIXCDX,DBFCDX"
      nMemoType := TYPE_FPT
   ENDCASE

   nMemoEOF := FSeek( hMemo, 0, FS_END )

   cBuff := Space( MEMO_HDR_SIZE )
   FSeek( hMemo, 0, FS_SET )
   n := FRead( hMemo, @cBuff, MEMO_HDR_SIZE )

   DO CASE
   CASE nMemoEOF < MEMO_HDR_SIZE
      // The file is smaller than it's header should be!
      // If the next available block is 1, it means the memo is empty.
      // Otherwise, the file has been badly truncated.
      // In either case, set nBlockSize to zero to avoid any further reads.
      nBlockSize := 0
      cTemp := Left( cBuff, 4 )
      n := CtoN( cTemp )
      IF n == 1 .AND. nMemoType == TYPE_III // Empty DBT?
         LogText( "Memo file is empty (normal)." )
      ELSE
         LogText( "Memo file has been truncated and is not recoverable." )
      ENDIF
   CASE nMemoType == TYPE_III
      nBlockSize := 512 // Standard DBT memo blocks are 512 bytes.
   CASE nMemoType == TYPE_IV
      cTemp := SubStr( cBuff, 21, 2 )
      nBlockSize := CtoN( cTemp )
   CASE nMemoType == TYPE_FPT
      cTemp := SubStr( cBuff, 7, 2 )
      nBlockSize := CtoN( cTemp, .T. ) // Big-endian value
      IF nBlockSize < 32 .OR. nBlockSize > 16384
         LogText( "Invalid block size in memo header: " + ;
            Nstr( nBlockSize ) + ".  Assuming the default of 64." )
         nBlockSize := 64
      ENDIF
      sx_SetMemoBlock( nBlockSize )
   ENDCASE

   IF nBlockSize > 0
      LogText( CRLF + "Memo block size: " + Nstr( nBlockSize ) )
   ENDIF

Return( nBlockSize )



STATIC FUNCTION MemoPreload( hMemo, lEnd )

   LOCAL cError, cBuffer, cData
   LOCAL nMemoLen, n, x
   LOCAL nEOM, cEOM := Chr( 26 ) // Memo terminator character
   LOCAL nEvery, nNext, nPos := MEMO_HDR_SIZE
   LOCAL nLastPercent := 0

   ? "Preloading memo data..."

   // Refresh 100 times or every megabyte, whichever comes more often:
   nEvery := Crop( nBlockSize, nMemoEOF / 100, 1024 * 1024 )
   nEvery -= nEvery % nBlockSize
   nNext := nEvery

   DO WHILE nPos < nMemoEOF .AND. ! lEnd

      FSeek( hMemo, nPos, FS_SET )

      cError := ""
      cData := ""

      IF nMemoType == TYPE_III

         n := nBlockSize
         cBuffer := Space( n )
         nMemoLen := 0
         nEOM := 0

         DO WHILE nEOM == 0 .AND. n == nBlockSize
            n := FRead( hMemo, @cBuffer, nBlockSize )
            nEOM := At( cEOM, Left( cBuffer, n ) )
            IF nEOM > 0
               x := nEOM - 1
            ELSE
               x := n
            ENDIF
            IF nMemoLen + x > nMaxMemoSize
               cError := ERR_SIZE // Memo size > max, truncated.
               x := nMaxMemoSize - nMemoLen
               nEOM := 1 // No need for another loop
            ELSEIF n < nBlockSize .AND. nEOM == 0
               cError := ERR_EOF // Truncated by EOF
            ENDIF
            cData += Left( cBuffer, x )
            nMemoLen += x
         ENDDO

      ELSE

         nMemoLen := 8 // The first 8 bytes contain memo type & size info
         cBuffer := Space( nMemoLen )
         n := FRead( hMemo, @cBuffer, nMemoLen )

         IF n == nMemoLen
            IF nMemoType == TYPE_FPT
               nMemoLen := CtoN( SubStr( cBuffer, 7, 2 ), .T. )
            ELSE // TYPE_IV
               nMemoLen := CtoN( SubStr( cBuffer, 5, 2 ) ) - 8
            ENDIF
            IF nMemoLen > 0
               IF nMemoLen > nMaxMemoSize
                  cError := ERR_SIZE
                  nMemoLen := nMaxMemoSize
               ENDIF
               // Read the entire memo in one gulp:
               cBuffer := Space( nMemoLen )
               n := FRead( hMemo, @cBuffer, nMemoLen )
               cData := Left( cBuffer, n )
               IF n < nMemoLen
                  cError := ERR_EOF
               ENDIF
               nMemoLen += 8 // Add the 8-byte header back in
            ENDIF
         ELSE
            cError := ERR_EOF
            nMemoLen := 0
         ENDIF

      ENDIF // nMemoType

      IF nMemoLen == 0
         IF Empty( cError )
            cError := ERR_BLANK // Blank memo but otherwise no error
         ENDIF
         nMemoLen := nBlockSize // Advance the pointer to the next block
      ENDIF

      MemoData->( dbAppend() )
      MemoData->POINTER := Str( Int( nPos / nBlockSize ), 10, 0 )
      MemoData->ERROR := cError
      MemoData->MEMOTEXT := cData

      nPos += nMemoLen
      n := nPos % nBlockSize
      IF n > 0
         nPos += nBlockSize - n // Jump to the start of the next block
      ENDIF

      IF nPos >= nNext
         x := Round( ( nPos / nMemoEOF ) * 100, 0 )
         IF ( x % 10 == 0 ) .AND. ( x <> nLastPercent )
            ? "Memo " + Nstr( x ) + "% preloaded"
            nLastPercent := x
         ENDIF
         lEnd := Inkey() == K_ESC
         DO WHILE nNext < nPos
            nNext += nEvery
         ENDDO
      ENDIF

   ENDDO

   MemoData->( dbCommit() )

Return( ! lEnd )



STATIC FUNCTION MemoRead( hMemo, cPointer, cMsg, lDamage )

   LOCAL cBuffer, cData := ""
   LOCAL nMemoLen, n, x
   LOCAL nEOM, cEOM

   // We already know at this point if we don't have a memo to read or that
   // the pointer is empty or invalid, so don't check for any of that again.

   // All memo files have a header of 512 bytes (bytes 0-511).
   // The first actual memo data starts at byte 512.

   n := ( Val( cPointer ) * nBlockSize )

   IF n < MEMO_HDR_SIZE
      LogText( cMsg + "memo pointer * blocksize < header size: " + ;
         AllTrim( cPointer ) )
      lDamage := .T.
      Return( cData )
   ENDIF

   // Read the data:

   FSeek( hMemo, n, FS_SET )

   IF nMemoType == TYPE_III

      cBuffer := Space( nBlockSize )
      cEOM := Chr( 26 ) // Memo terminator character
      nEOM := 0
      n := nBlockSize
      nMemoLen := 0

      DO WHILE nEOM == 0 .AND. n == nBlockSize
         n := FRead( hMemo, @cBuffer, nBlockSize )
         nEOM := At( cEOM, Left( cBuffer, n ) )
         IF nEOM > 0
            x := nEOM - 1
         ELSE
            x := n
         ENDIF
         IF nMemoLen + x > nMaxMemoSize
            LogText( cMsg + "memo size > max.  Truncating." )
            lDamage := .T.
            x := nMaxMemoSize - nMemoLen
            nEOM := 1 // No need for another loop
         ELSEIF n < nBlockSize .AND. nEOM == 0
            LogText( "memo truncated by eof.  " + ;
               Nstr( nMemoLen + x ) + " bytes saved." )
            lDamage := .T.
         ENDIF
         cData += Left( cBuffer, x )
         nMemoLen += x
      ENDDO

   ELSE

      nMemoLen := 8 // The first 8 bytes contain memo type & size info
      cBuffer := Space( nMemoLen )
      n := FRead( hMemo, @cBuffer, nMemoLen )

      IF n == nMemoLen
         IF nMemoType == TYPE_FPT
            // Bytes 0-3 are the FPT "record type".  Usage?  Who knows...
            // Bytes 4-7 are the memo length (big-endian).
            // Since I can't use more than 64K, just take the last two bytes.
            // This allows bytes 4-5 to be corrupted without consequence.
            nMemoLen := CtoN( SubStr( cBuffer, 7, 2 ), .T. )
         ELSE // TYPE_IV
            // Bytes 4-7 are the memo length (little-endian) including this
            // 8-byte "header".
            // Since I can't use more than 64K, just take the first two bytes.
            // This allows bytes 6-7 to be corrupted without consequence.
            nMemoLen := CtoN( SubStr( cBuffer, 5, 2 ) ) - 8
         ENDIF
         IF nMemoLen > 0
            IF nMemoLen > nMaxMemoSize
               LogText( cMsg + "reports a memo size > max.  Truncating." )
               lDamage := .T.
               nMemoLen := nMaxMemoSize
            ENDIF
            // Read the entire memo in one gulp:
            cBuffer := Space( nMemoLen )
            n := FRead( hMemo, @cBuffer, nMemoLen )
            cData := Left( cBuffer, n )
            IF n < nMemoLen
               LogText( cMsg + "memo truncated by eof.  " + Nstr( n ) + ;
                  " of " + Nstr( nMemoLen ) + " bytes saved." )
               lDamage := .T.
            ENDIF
         ENDIF
      ELSE
         LogText( cMsg + "memo truncated by eof.  Entire memo lost." )
         lDamage := .T.
      ENDIF

   ENDIF // nMemoType

Return( cData )



STATIC FUNCTION MemoSeek( cPointer, cMsg, lDamage )

   LOCAL cData := ""

   IF MemoData->( dbSeek( cPointer ) )
      IF MemoData->ERROR <> ERR_BLANK
         cData := MemoData->MEMOTEXT
         IF ! Empty( MemoData->ERROR )
            lDamage := .T.
            DO CASE
            CASE MemoData->ERROR == ERR_SIZE
               LogText( cMsg + "reports a memo size > max.  Truncated." )
            CASE MemoData->ERROR == ERR_EOF
               LogText( cMsg + "memo partially truncated by eof." )
            ENDCASE
         ENDIF
      ENDIF
   ELSE
      lDamage := .T.
      LogText( cMsg + "incorrect memo pointer (" + cPointer + ")" )
   ENDIF

Return( cData )


STATIC FUNCTION GetYesNo( cMsg, lEsc )

   LOCAL i

   ? cMsg + " (Y/N/Esc) "

   DO WHILE .T.
      i := Inkey( 0 )
      IF i == K_ESC
         Return( lEsc )
      ELSEIF i == Asc( "Y" ) .OR. i == Asc( "y" )
         ?? "Y"
         Return( .T. )
      ELSEIF i == Asc( "N" ) .OR. i == Asc( "n" )
         ?? "N"
         Return( .F. )
      ENDIF
   ENDDO

Return( NIL )
