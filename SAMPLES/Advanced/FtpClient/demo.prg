/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Based upon program MINIGUI\SAMPLES\ADVANCED\FILEMAN
 * Copyright 2003-2007 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Used functions desencri() and encri() by Gustavo C. Asborno <gcasborno@yahoo.com.ar>
 *
 * Used functions of sample ftplite on group harbourminigui_es by Juan Castillo A. <juan_casarte@yahoo.es>
 *
 * Copyright 2007 Walter Formigoni <walter.formigoni@uol.com.br>
 *
 * Revision of Pierpaolo Martinello 2018
*/


#include <minigui.ch>
#include "Dbstruct.ch"
#include "tip.ch"

Static aDirectory, aSubDirectory, aOldPos
Static aNivel := { 1, 1 }, aBack := { .t., .t. }, aGridWidth, nGridFocus := 1, bBlock, lBlock := .f.
Static cRunCommand := "", aWinVer, aSortCol := { 2, 2 }

Memvar lfirst, oClient, oUrl
Memvar newRecord

function main()

   LOCAL nScrWidth := GetDesktopWidth(), nScrHeight := GetDesktopHeight(), nWidth, nHeight, nGridHeight, nGridWidth

   LOCAL nWnd := 1
   Public lfirst := .t.
   Public oClient, oUrl

   if !file("sites.dbf")
      CreateTable(.F.)
   endif

   use sites alias sites

   if Fcount() < 6
      copy to Osites
      dbcloseall()
      CreateTable(.T.)
      use sites alias sites
      append from Osites
      Ferase("Osites.dbf")
   Endif

   WHILE IsExeRunning( cFileNoPath( HB_ArgV( 0 ) ) + "_" + Ltrim(Str(nWnd)) )
      nWnd++
   END

   aWinVer := WindowsVersion()

   SET CENTURY ON
   SET DATE GERMAN
   SET BROWSESYNC ON
   SET NAVIGATION EXTENDED

   aDirectory := ARRAY( 2 )
   aSubDirectory := ARRAY( 2, 64 )
   aOldPos := ARRAY( 2, 64 )

   aSubDirectory[1][1] := 'C:'
   aSubDirectory[2][1] := 'C:'
   setcurrentfolder('c:\')

   nWidth := IF(nScrWidth >= 1024, 800, IF(nScrWidth >= 800, 700, 600))
   nHeight := IF(nScrHeight >= 768, 600, IF(nScrHeight >= 600, 540, 480))
   nGridHeight := IF(nHeight = 600, 360, IF(nHeight = 540, 299, 240))
   nGridWidth := IF(nWidth = 800, 380, IF(nWidth = 700, 330, 280))
   aGridWidth := IF(nHeight = 600, {0, 145, 80, 74, 70 }, IF(nHeight = 540, {0, 115, 80, 60, 64 }, {0, 85, 70, 60, 55 }))

   load window ftp

   ftp.combo_1.value := 1
   ftp.button_4.enabled := .f.
   ftp.button_5.enabled := .f.
   ftp.button_6.enabled := .f.
   ftp.button_7.enabled := .f.
   center window ftp
   activate window ftp
return nil

function sitemanager()
    IF IsWindowDefined("sitemanager")
       Domethod( 'sitemanager', 'SETFOCUS')
      RETURN NIL
    Endif

   load window sitemanager
   center window sitemanager
   activate window sitemanager
return nil

function sitemanagerexit()
   release window sitemanager
return nil

function editsite(param)
   public newRecord
   load window editsitemanager
   if param = NIL
      newRecord := .f.
      sites->(dbgoto(sitemanager.browse_1.value))
      editsitemanager.text_1.value  := sites->name
      editsitemanager.text_2.value  := sites->address
      editsitemanager.text_3.value  := sites->user
      editsitemanager.text_4.value  := desencri(sites->password)  && decript
      editsitemanager.text_5.value  := Sites->SPath
      editsitemanager.Check_2.value := Sites->Log
   else
      newRecord := .t.
   endif

   center window editsitemanager
   activate window editsitemanager
return nil

function ftppropcancel()
   release window editsitemanager
return nil

function ftpdelete()
   LOCAL nRec := sitemanager.browse_1.value

   if msgyesno('Are You Sure?','Delete Record') == .f.
      return nil
   Endif
   sites->(dbdelete(sitemanager.browse_1.value))
   sites->(__dbpack())
   if nRec < 2
      sitemanager.browse_1.value:=1
      Ftp.Combo_1.value := 1
   Else
      sitemanager.browse_1.value := nRec -1
   Endif
   sitemanager.browse_1.refresh
   fillcombo()
return nil

function ftppropsave()
   if newRecord = .t.
      sites->(dbappend())
   endif
   if left(editsitemanager.text_5.value,1)!= "/"
      editsitemanager.text_5.value := "/" + editsitemanager.text_5.value
   Endif
   sites->Name     := editsitemanager.text_1.value
   sites->Address  := editsitemanager.text_2.value
   sites->User     := editsitemanager.text_3.value
   sites->Password := encrip(editsitemanager.text_4.value) && encript
   sites->Spath    := editsitemanager.text_5.value
   sites->Log      := editsitemanager.Check_2.value
   sitemanager.browse_1.refresh
   fillcombo()
   release window editsitemanager
return nil

function fillcombo()
   ftp.combo_1.refresh
return nil


function ftpconn1()
   if sites->(reccount()) > 0
      sites->(dbgoto(ftp.combo_1.value))
      ftpconnect()
   else
      msgalert("No available sites", "Alert")
   endif
return nil

function ftpconn2()
   sites->(dbgoto(sitemanager.browse_1.value))
   ftp.combo_1.value := sitemanager.browse_1.value
   ftpconnect()
   release window sitemanager
return nil

function ftpConnect()

   LOCAL cUser     := sites->user
   LOCAL cPassWord := desencri(sites->password)
   LOCAL cServer   := sites->address

   LOCAL cProtocol := "ftp://"
   LOCAL cUrl

   cUrl := cProtocol + Alltrim( cUser )+":"+ Alltrim( cPassWord ) +"@"+  alltrim( cServer)

   oUrl := tURL():New( cUrl )
   IF Empty( oUrl )
      return nil
   endif
   oClient := TIpClientFtp():new( oUrl, Sites->Log ) && PARAM .T. TO LOG
   IF Empty( oClient )
      return nil
   endif
   oClient:nConnTimeout := 20000
   oClient:bUsePasv     := .T.


   // Comprobamos si el usuario contiene una @ para forzar el userid
   IF At( "@", cUser ) > 0
      oClient:oUrl:cServer   := cServer
      oClient:oUrl:cUserID   := cUser
      oClient:oUrl:cPassword := cPassword
   ENDIF

   IF oClient:Open()
      IF Empty( oClient:cReply )
         oClient:Pasv()
      ELSE
         oClient:Pasv()
      ENDIF
      ftp.button_4.enabled := .t.
      ftp.button_5.enabled := .t.
      ftp.button_6.enabled := .t.
      ftp.button_7.enabled := .t.
      ftp.button_3.enabled := .f.

      if !empty(Sites->SPath)
         oClient:CWD(alltrim(Sites->Spath))
         ftp.label_4.value := alltrim(Sites->Spath)
         FTPFILLGRID()
      Else
         ftp.label_4.value:= "/"
         FTPFILLGRID()
      Endif
   ELSE
      msgalert("Connection is not opened", "Alert")
   ENDIF

return nil

FUNCTION FTPFILLGRID()
   LOCAL ctext, cSepChar, nPos, acDir, cLine, x, avalues, xpesq, xpos, cvalue, cvalue1
   LOCAL nX, cFileName, nDirImg

   ctext := oClient:List()
   oClient:reset()
   cSepChar := CRLF
   nPos := At( cSepChar, ctext )
   If nPos == 0
      If ! Empty( ctext )  // single line, just one file, THEREFORE there won't be any CRLF's!
         ctext += CRLF
      Else
         cSepChar := Chr(10)
      Endif
      nPos := At( cSepChar, ctext )
   Endif
   acDir := {}
   Do While nPos > 0 &&.and. ! Eval( ::bAbort )
      cLine := AllTrim( Left( ctext, nPos - 1 ) )
      ctext := SubStr( ctext, nPos + Len( cSepChar ) )
      cLine := AllTrim( StrTran( cLine, Chr(0), "" ) )

      If( ! Empty( cLine ), AAdd( acDir, cLine ), Nil )

      nPos := At( cSepChar, ctext )
      DO EVENTS
   Enddo

   ftp.Grid_2.DisableUpdate
   ftp.Grid_2.DeleteAllItems

   nPos := If( len(acDir)> 0 .and. acDir[1]=="[..]", 2, 1 )

   // Pierpaolo 20/5/2018 add backward row for certain ftp server Ie Nas

   if empty(atail(acdir)) .and. len(left(ftp.label_4.value,2) ) > 1
      ftp.Grid_2.AddItem( {0,".","","","","drwxrwxrwx" })
      ftp.Grid_2.AddItem( {0,"..","","","","drwxrwxrwx" })
      ftp.Grid_2.EnableUpdate
      return nil
   Endif

   if right(acdir[1],1) != "." .and. len(left(ftp.label_4.value,2) ) > 1
      ftp.Grid_2.AddItem( {0,".","","","","drwxrwxrwx" })
      ftp.Grid_2.AddItem( {0,"..","","","","drwxrwxrwx" })
   Endif

   for x = nPos to len(acDir)
      avalues := {}
      xpesq := alltrim(acDir[x])
      do while .t.
         xpos := at(' ',xpesq)
         if xpos = 0
            aadd(avalues,xpesq)
            cFileName := ""
            for nX := 10 to len(avalues)
                cFileName += avalues[nX]+' '
            next
            cFileName := If( substr(avalues[1],1,1) = 'l', substr(cFileName, 1, at('->', cFileName) - 1), rtrim(cFileName) )
            nDirImg := If( substr(avalues[1],1,1) = 'd', 0, 1 )
            ftp.Grid_2.AddItem( {nDirImg,cFileName,avalues[5],StrZero(val(avalues[7]),2)+'.'+STRZero(nMONTH(avalues[6]),2)+'.'+avalues[8],avalues[9],avalues[1]} )
            exit
         endif
         cvalue := substr(xpesq,1,xpos-1)
         xpesq := Ltrim(substr(xpesq,xpos+1,len(xpesq)))
         if len(avalues) < 7 .or. len(avalues) > 8
            aadd(avalues,cvalue)
         else
            if at(':',cvalue) > 0
               cvalue1 := alltrim(str(year(date())))
               aadd(avalues,cvalue1) && year
               aadd(avalues,cvalue)  && time
            else
               aadd(avalues,cvalue) && year
               aadd(avalues,"")  && time
            endif
         endif
      enddo

   next x

   ftp.Grid_2.EnableUpdate
RETURN nil

FUNCTION LOCALMKDIR()
   LOCAL cfile := INPUTBOX('NEW DIR NAME ?')
   LOCAL cF    := GetcurrentFolder()

   IF DIRCHANGE( cF + '\'+cfile ) > 0
      if MAKEDIR  ( cF + '\'+cfile ) = 0
         GetDirectory(cF + '\*.*', 1)
      Else
         MsgStop("Permission Denied!")
      Endif
   ENDIF
return nil

FUNCTION LOCALREN()
   LOCAL cFileOld := CharRem("[]",getcurrentfolder()+'\'+getcolvalue("GRID_1","FTP",2) )
   LOCAL cFileNew , ctype := alltrim(getcolvalue("GRID_1","FTP",3))
   cFileNew := INPUTBOX('NEW FILE NAME ?',,CharRem("[]",getcolvalue("GRID_1","FTP",2) ) )
   cFileNew := getcurrentfolder()+'\'+cFileNew
   RENAME (cFileOld) TO (cFileNew)
   GetDirectory(getcurrentfolder() + '\*.*', 1)
   ftp.grid_1.refresh
return nil


FUNCTION LOCALDEL()
   LOCAL ctype := alltrim(getcolvalue("GRID_1","FTP",3))
   LOCAL cFile := getcurrentfolder() + '\'+getcolvalue("GRID_1","FTP",2)

   if msgyesno('Are You Sure?','You are deleting the '+ iif (ctype = '<DIR>','folder "','file "')+cFile+'"') == .f.
      return nil
   Endif

   IF .NOT. EMPTY(cFile)
      if ctype = '<DIR>'
         cfile := strtran(cfile,'[','')
         cfile := strtran(cfile,']','')
         if ! removefolder(cfile)
            MsgStop("Not Empty Folder","Permission Denied!")
         Endif
      ELSE
         ERASE (cFile)
      endif

      GetDirectory(getcurrentfolder() + '\*.*', 1)
   ENDIF
return nil

FUNCTION FTPCWD()
   LOCAL lresp, cpath, cfolder := "/", dg
   LOCAL ctype := substr(getcolvalue("GRID_2","FTP",6),1,1)
   if ctype = 'd'
      lresp :=  oClient:PWD
      cpath := oClient:cReply
      if cpath == '/'
         cfolder := '/'+getcolvalue("GRID_2","FTP",2)
      else
         dg  := getcolvalue("GRID_2","FTP",2)
         if ascan({".",".."},dg) > 0
            cfolder := substr(cpath,1,rat("/",cPath)-1)
            if empty(cFolder)
               cFolder:= "/"
            Endif
         Else
            cfolder := cpath+'/'+getcolvalue("GRID_2","FTP",2)
         Endif
      endif
      lresp := oClient:CWD(cfolder)
      ftp.label_4.value := cFolder
      FTPFILLGRID()
   endif
   if empty(cfolder).or. left(cFolder,2) ="/."
      ftp.label_4.value := "/"
   Else
      ftp.label_4.value := cFolder
   Endif
RETURN nil

FUNCTION FTPCLOSE()
   LOCAL lresp := oClient:CLOSE()

   ftp.Grid_2.DeleteAllItems
   ftp.button_4.enabled := .f.
   ftp.button_5.enabled := .f.
   ftp.button_6.enabled := .f.
   ftp.button_7.enabled := .f.
   ftp.button_3.enabled := .t.
   ftp.label_4.value    := ""

RETURN nil

FUNCTION FTPREN()
   LOCAL cFileOld := getcolvalue("GRID_2","FTP",2)
   LOCAL cFileNew := INPUTBOX('NEW FILE NAME ?',,getcolvalue("GRID_2","FTP",2) )
   LOCAL lresp := oClient:RENAME( cFileOld,cFileNew )
   FTPFILLGRID()
RETURN nil

FUNCTION FTPMKDIR()
   LOCAL cFile := INPUTBOX('NEW DIR NAME ?')
   LOCAL lresp := oClient:MKD( cFile )
   FTPFILLGRID()
RETURN nil

FUNCTION FTPDEL()
   LOCAL lresp
   LOCAL cFile := getcolvalue("GRID_2","FTP",2)
   LOCAL ctype := substr(getcolvalue("GRID_2","FTP",6),1,1)

   if msgyesno('Are You Sure?','You are deleting the '+ iif (ctype = 'd','folder "','file "')+cFile+'"') == .f.
      return nil
   Endif

   IF .NOT. EMPTY(cFile)
      //ctype := substr(getcolvalue("GRID_2","FTP",6),1,1)
      if ctype = 'd'
         lresp := oClient:RMD( cFile )
      ELSE
         lresp := oClient:Dele( cFile )
      endif
      ftpfillgrid()
   ENDIF
return nil

FUNCTION FTPDOWN()
   LOCAL lresp
   LOCAL cFile := getcolvalue("GRID_2","FTP",2)
   if ftp.grid_1.cell(1,2) # '[..]'
      setcurrentfolder('c:\')
   endif
   if ISOBJECT(oClient)
      lresp := oClient:DownloadFile( cFile )
      GetDirectory(getcurrentfolder() + '\*.*', 1)
      if valtype(lresp) = "L"
         if lresp != .t.
            MsgStop('Error was arised at downloading!')
         endif
      endif
   endif
return nil

FUNCTION FTPUP()
   LOCAL lresp
   LOCAL cFile := getcolvalue("GRID_1","FTP",2)
   LOCAL cFile1 := getcurrentfolder()+'\'+cFile

   if ftp.grid_1.cell(1,2) # '[..]'
      cFile1 := 'C:\'+cFile
   endif
   if file(cFile1)
      if ISOBJECT(oClient)
//       oClient:TypeA()
         oClient:bUsePasv := .T.

         lresp := oClient:UploadFile( cFile1 )
//       ftpfillgrid()

         if valtype(lresp) = "L"
            if lresp = .t.
               ftpfillgrid()
            else
               MsgStop('Error was arised at uploading!')
            endif
         endif
      endif
   endif
return nil

*------------------------------------------------------------*
Function GetColValue( xObj, xForm, nCol )
*------------------------------------------------------------*
   LOCAL nPos:= GetProperty(xForm, xObj, 'Value')
   LOCAL aRet:= GetProperty(xForm, xObj, 'Item', nPos)
return aRet[nCol]

*------------------------------------------------------------*
function initgrid()
*------------------------------------------------------------*
   GetDirectory(aSubDirectory[1][1] + '\*.*', 1)
   lfirst := .f.
return nil

*------------------------------------------------------------*
function nMonth(param)
*------------------------------------------------------------*
   LOCAL RETVAL := 0

   if upper(param) = 'JAN'
      RETVAL := 1
   elseif upper(param) = 'FEB'
      RETVAL := 2
   elseif upper(param) = 'MAR'
      RETVAL := 3
   elseif upper(param) = 'APR'
      RETVAL := 4
   elseif upper(param) = 'MAY'
      RETVAL := 5
   elseif upper(param) = 'JUN'
      RETVAL := 6
   elseif upper(param) = 'JUL'
      RETVAL := 7
   elseif upper(param) = 'AUG'
      RETVAL := 8
   elseif upper(param) = 'SEP'
      RETVAL := 9
   elseif upper(param) = 'OCT'
      RETVAL := 10
   elseif upper(param) = 'NOV'
      RETVAL := 11
   elseif upper(param) = 'DEC'
      RETVAL := 12
   endif
return(RETVAL)

*------------------------------------------------------------*
procedure Head_click( nCol )
*------------------------------------------------------------*
   LOCAL nPos := IF( nGridFocus = 1, ftp.Grid_1.Value, ftp.Grid_2.Value ),;
      nOldCol := aSortCol[nGridFocus]

   IF nCol = 2
      Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[3]) # "N" .AND. valtype(b[3]) # "N",;
         SUBSTR(a[2],2) < SUBSTR(b[2],2), if(valtype(a[3]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1],;
         if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[1] < b[1])))})
   ELSEIF nCol = 3
      Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N",;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1],;
         if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[2] < b[2])))})
   ELSEIF nCol = 4
      Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N",;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1],;
         if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[3] < b[3])))})
   ELSEIF nCol = 5
      Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N",;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1],;
         if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[4] < b[4])))})
   ENDIF

   IF nGridFocus = 1
      _SetGridCaption( "Grid_1", "FTP", nOldCol,;
         Substr( ftp.Grid_1.Header(nOldCol), 2, Len(ftp.Grid_1.Header(nOldCol)) - 2 ),;
         if(nOldCol=1, BROWSE_JTFY_LEFT, if(nOldCol=2, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER )))
   ENDIF

   aSortCol[nGridFocus] := nCol

   IF nGridFocus = 1
      ftp.Grid_1.DisableUpdate
      ftp.Grid_1.DeleteAllItems
      Aeval(aDirectory[nGridFocus], {|e| ftp.Grid_1.AddItem( {if(valtype(e[2])="N", 0,1), e[1], ;
        if(valtype(e[2])="N", STR(e[2]), e[2]), DTOC(e[3]), e[4] } )})
      _SetGridCaption( "Grid_1", "FTP", nCol, "[" + ftp.Grid_1.Header(nCol) + "]", if(nCol=2, BROWSE_JTFY_LEFT, if(nCol=3, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER )))
      ftp.Grid_1.Value := if(Empty(nPos), 1, nPos)
      ftp.Grid_1.EnableUpdate
   ENDIF

Return

*------------------------------------------------------------*
FUNCTION GetDirectory( cVar, nFocus )
*------------------------------------------------------------*
   LOCAL aDir:= {}, aAux := {}, nSortCol
   LOCAL cDir, i := 1, j := 1

   cDir := Alltrim( cVar )
   aDir := Directory( cDir, 'D' )

   IF ( i := Ascan( aDir, {|e| Alltrim( e[1] ) = "."} ) ) > 0
      Adel( aDir, i )
      Asize( aDir, Len( aDir ) - 1 )
   ENDIF
   IF Len( aDir ) = 0
      AADD( aDir,  { "..", 0, Date(), Time() }  )
   ENDIF

   aDirectory[nFocus] := aDir

   FOR i = 1 to Len( aDirectory[nFocus] )

      FOR j = 1 TO Len( aDirectory[nFocus] )

         IF Lower( aDirectory[nFocus][i][1] ) <= Lower( aDirectory[nFocus][j][1] )

            IF SubStr( aDirectory[nFocus][i][1], 2, 1) <> '.' .AND. SubStr( aDirectory[nFocus][j][1], 2, 1) <> '.'

               aAux				:= aDirectory[nFocus][i]
               aDirectory[nFocus][i]	:= aDirectory[nFocus][j]
               aDirectory[nFocus][j]	:= aAux
               aAux				:= {}
            ENDIF
         ENDIF

      NEXT
   NEXT

   Aeval(aDirectory[nFocus], {|e| if(e[2] = 0 .AND. AT(".SWP", e[1]) = 0, (e[1] := "[" + UPPER(e[1]) + "]", e[2] := "<DIR>"), e[1] := LOWER(e[1]))})

   nSortCol := aSortCol[nFocus]
   IF nSortCol = 1
      Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
      SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[1] < b[1])))})
   ELSEIF nSortCol = 2
      Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
      SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[2] < b[2])))})
   ELSEIF nSortCol = 3
      Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N",  ;
      SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[3] < b[3])))})
   ELSE
      Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
      SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[4] < b[4])))})
   ENDIF

   IF nFocus = 1
      ftp.Grid_1.DisableUpdate
      ftp.Grid_1.DeleteAllItems
      Aeval(aDirectory[nFocus], {|e| ftp.Grid_1.AddItem( {if(valtype(e[2])="N", 1,0), e[1], if(valtype(e[2])="N", STR(e[2]), e[2]), DTOC(e[3]), e[4] } )})
      ftp.Grid_1.Value := if(aBack[nFocus], aOldPos[nFocus][aNivel[nFocus]], 1)
      ftp.Grid_1.EnableUpdate

   ENDIF

RETURN NIL

*------------------------------------------------------------*
FUNCTION Verify()
*------------------------------------------------------------*
   LOCAL nPos := IF( nGridFocus = 1, ftp.Grid_1.Value, ftp.Grid_2.Value )
   LOCAL cDirectory := aSubDirectory[nGridFocus][1], i, cPath, cFile, cExt, cExe
   IF !Empty( nPos )
      IF Len( aDirectory[nGridFocus] ) > 0
         IF Alltrim(aDirectory[nGridFocus][ nPos, 1 ] ) <> '[..]' .AND. Valtype(aDirectory[nGridFocus][ nPos, 2 ]) # "N"
            aOldPos[nGridFocus][aNivel[nGridFocus]] := nPos
            aNivel[nGridFocus] ++
            aSubDirectory[nGridFocus][ aNivel[nGridFocus] ] := '\' + Substr(aDirectory[nGridFocus][ nPos, 1 ], 2, Len(aDirectory[nGridFocus][ nPos, 1 ]) - 1)

            FOR i = 2 TO aNivel[nGridFocus]
               cDirectory += Substr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
            NEXT
            setcurrentfolder(cdirectory)
            aBack[nGridFocus] := .f.
            GetDirectory( cDirectory + '\*.*', nGridFocus )

         ELSEIF ALLTRIM(aDirectory[nGridFocus][ nPos, 1 ] ) = '[..]'
            aSubDirectory[nGridFocus][ aNivel[nGridFocus] ] := ""
            IF aNivel[nGridFocus] > 1
               aNivel[nGridFocus] --
            ENDIF
            FOR i = 2 TO aNivel[nGridFocus]
               cDirectory += Substr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
            NEXT
            setcurrentfolder(cdirectory)
            aBack[nGridFocus] := .t.
            GetDirectory( cDirectory + '\*.*', nGridFocus )
         ELSE
            cPath := GetFull()
            cFile := GetName()
            cExt := GetExt()
            IF cExt = 'EXE' .or. cExt = 'BAT' .or. cExt = 'COM'
               _Execute ( 0, , cFile, , cPath, 5 )
            ELSE
               cExe := GetOpenCommand(cExt)
               IF !Empty(cExe)
                  cFile := cPath+'\'+cFile
                  _Execute ( 0, , cExe, IF(At(" ", cFile) > 0, '"'+cFile+'"', cFile), cPath, 5 )
               ELSE
                  MsgAlert( 'Error executing program!', "Alert" )
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

*------------------------------------------------------------*
FUNCTION CurrentDirectory(param)
*------------------------------------------------------------*
   LOCAL cPath := GetFull(), cName := GetName()
   LOCAL cText := cPath + '\' + cName
   if param # NIL
      nGridFocus := param
   endif
   IF nGridFocus = 1
      ftp.Label_3.Value := cText
   ENDIF

RETURN NIL

*------------------------------------------------------------*
FUNCTION GetExt()
*------------------------------------------------------------*
   LOCAL cExtension := "", cFile := GetName()
   LOCAL nPosition  := Rat( '.', Alltrim(cFile) )

   IF nPosition > 0
      cExtension := SubStr( cFile, nPosition + 1, Len( Alltrim(cFile) ) )
   ENDIF

RETURN Upper(cExtension)

*------------------------------------------------------------*
FUNCTION GetName()
*------------------------------------------------------------*
   LOCAL cText := "", nPos

   IF ( nPos := IF( nGridFocus = 1, ftp.Grid_1.Value, ftp.Grid_2.Value ) ) > 0
      cText:= IF( valtype(aDirectory[nGridFocus][ nPos, 2 ]) # "N",;
         Substr(aDirectory[nGridFocus][ nPos, 1], 2, Len(aDirectory[nGridFocus][ nPos, 1 ]) - 2),;
         aDirectory[nGridFocus][ nPos, 1] )
   ENDIF

RETURN ALLTRIM( cText )

*------------------------------------------------------------*
FUNCTION GetFull()
*------------------------------------------------------------*
   LOCAL cText := aSubDirectory[nGridFocus][1], i

   FOR i = 2 TO aNivel[nGridFocus]
      cText += SubStr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
   NEXT

RETURN cText

*------------------------------------------------------------*
Static Function GetOpenCommand( cExt )
*------------------------------------------------------------*
   LOCAL oReg, cVar1 := "", cVar2 := "", nPos

   If ! ValType( cExt ) == "C"
      Return ""
   Endif

   If ! Left( cExt, 1 ) == "."
      cExt := "." + cExt
   Endif

   oReg := TReg32():New( HKEY_CLASSES_ROOT, cExt, .f. )
   cVar1 := RTrim( StrTran( oReg:Get( Nil, "" ), Chr(0), " " ) ) // i.e look for (Default) key
   oReg:close()

   If ! Empty( cVar1 )
      oReg := TReg32():New( HKEY_CLASSES_ROOT, cVar1 + "\shell\open\command", .f. )
      cVar2 := RTrim( StrTran( oReg:Get( Nil, "" ), Chr(0), " " ) )  // i.e look for (Default) key
      oReg:close()

      If ( nPos := RAt( " %1", cVar2 ) ) > 0        // look for param placeholder without the quotes (ie notepad)
         cVar2 := SubStr( cVar2, 1, nPos )
      Elseif ( nPos := RAt( '"%', cVar2 ) ) > 0     // look for stuff like "%1", "%L", and so forth (ie, with quotes)
         cVar2 := SubStr( cVar2, 1, nPos - 1 )
      Elseif ( nPos := RAt( '%', cVar2 ) ) > 0      // look for stuff like "%1", "%L", and so forth (ie, without quotes)
         cVar2 := SubStr( cVar2, 1, nPos - 1 )
      Elseif ( nPos := RAt( ' /', cVar2 ) ) > 0     // look for stuff like "/"
         cVar2 := SubStr( cVar2, 1, nPos - 1 )
      Endif
   Endif

Return RTrim( cVar2 )

*------------------------------------------------------------*
Function _SetGridCaption ( ControlName, ParentForm , Column , Value , nJustify )
*------------------------------------------------------------*
   LOCAL i , h , t

   i := GetControlIndex ( ControlName, ParentForm )

   h := _HMG_aControlhandles [i]

   t := GetControlType ( ControlName, ParentForm )

   _HMG_aControlCaption [i] [Column] := Value

   If t == 'GRID'
      SETGRIDCOLUMNHEADER ( h , Column , Value , nJustify )
   EndIf

Return Nil

*------------------------------------------------------------*
Procedure CreateTable ( Upg )
*------------------------------------------------------------*
   LOCAL aDbf[6][4]
   FIELD NAME, ADDRESS, USER, PASSWORD
   if upg
      FIELD LOG
      FIELD SPATH
   Endif

   aDbf[1][ DBS_NAME ] := "Name"
   aDbf[1][ DBS_TYPE ] := "Character"
   aDbf[1][ DBS_LEN ]  := 60
   aDbf[1][ DBS_DEC ]  := 0
   //
   aDbf[2][ DBS_NAME ] := "Address"
   aDbf[2][ DBS_TYPE ] := "Character"
   aDbf[2][ DBS_LEN ]  := 100
   aDbf[2][ DBS_DEC ]  := 0
   //
   aDbf[3][ DBS_NAME ] := "User"
   aDbf[3][ DBS_TYPE ] := "Character"
   aDbf[3][ DBS_LEN ]  := 60
   aDbf[3][ DBS_DEC ]  := 0
   //
   aDbf[4][ DBS_NAME ] := "Password"
   aDbf[4][ DBS_TYPE ] := "Character"
   aDbf[4][ DBS_LEN ]  := 20
   aDbf[4][ DBS_DEC ]  := 0

   aDbf[5][ DBS_NAME ] := "SPATH"
   aDbf[5][ DBS_TYPE ] := "Character"
   aDbf[5][ DBS_LEN ]  := 60
   aDbf[5][ DBS_DEC ]  := 0
   //
   aDbf[6][ DBS_NAME ] := "Log"
   aDbf[6][ DBS_TYPE ] := "Logical"
   aDbf[6][ DBS_LEN ]  := 1
   aDbf[6][ DBS_DEC ]  := 0
   //

   DBCREATE("Sites", aDbf)

return

*------------------------------------------------------------*
Function Encrip(pepe)
*------------------------------------------------------------*
   LOCAL pala:='', let, a, conv
   LOCAL enc:=len(pepe)
   for a=1 to enc
      let:=substr(pepe,a,1)
      conv:=asc(let)+100+a
      pala+=chr(conv)
   next
return(pala)

*------------------------------------------------------------*
Function Desencri(pepe)
*------------------------------------------------------------*
   LOCAL pala:='', let, a, conv
   LOCAL enc:=len(alltrim(pepe))
   for a=1 to enc
      let:=substr(pepe,a,1)
      conv:=asc(let)-100-a
      pala+=chr(conv)
   next
return(pala)
/*
*/

#define EM_SETPASSWORDCHAR      0x00CC
*------------------------------------------------------------*
Procedure ShowPassword()
*------------------------------------------------------------*
  LOCAL cPass := editsitemanager.Text_4.VALUE
  LOCAL lShowPass := !editsitemanager.Check_1.VALUE

  If lShowPass
     SendMessage(editsitemanager.Text_4.HANDLE, EM_SETPASSWORDCHAR, 0, 0)
     editsitemanager.Text_4.REFRESH
  Else
     editsitemanager.Text_4.RELEASE
     DoEvents()
     DEFINE TEXTBOX Text_4
       PARENT editsitemanager
       ROW    150
       COL    110
       WIDTH  180
       HEIGHT 24
       VALUE     cPass
       PASSWORD  .T.
     END TEXTBOX
  EndIf

RETURN
