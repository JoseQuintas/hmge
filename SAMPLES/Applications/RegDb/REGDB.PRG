*+--------------------------------------------------------------------
*+
*+    Copyright(C) 1983-2020 by Auge & Ohr
*+
*+    Functions: Procedure Main()
*+               Static Procedure LoadDetail()
*+               Static Procedure OnSave()
*+               Static Procedure OnAppend()
*+               Static Procedure GoToURL()
*+               Static Function SetStartNode()
*+               Static Function MYSHELLOPENFILE()
*+               Static Function Is64Bit()
*+               Static Procedure Cre_REG()
*+               Static Function RegArray()
*+               Static Function SP_cFontName()
*+               Static Function SP_nFontSize()
*+
*+       Tables: USE (cAppFolder+"HBREG.DBF") VIA "DBFCDX" NEW EXCLUSIVE
*+               USE (datei) ALIAS "HBREG" VIA "DBFCDX" NEW EXCLUSIVE
*+
*+--------------------------------------------------------------------

#include "HMG.CH"
#include "dll.CH"

#include "SHFILE.CH"

REQUEST DBFCDX

STATIC xVersion := " v0.02"

*************************
*
*  v0.01  15.02.2020  1st Release
*
*************************

*+--------------------------------------------------------------------
*+
*+    Procedure Main()
*+
*+    Main module
*+
*+--------------------------------------------------------------------
*+
PROCEDURE Main()

   LOCAL cAppFolder := GetStartUpFolder() + "\"

   STATIC cFontName AS GLOBAL VALUE "Arial", nFontSize AS GLOBAL VALUE 10

   SET MULTIPLE OFF

   SET BROWSESYNC ON

   IF !File( cAppFolder + "HBREG.DBF" )
      Cre_REG( cAppFolder + "HBREG.DBF" )
   ENDIF

   USE ( cAppFolder + "HBREG.DBF" ) VIA "DBFCDX" NEW EXCLUSIVE

   DEFINE WINDOW RegDbForm ;
         WIDTH 800 ;
         HEIGHT 600 ;
         MAIN ;
         TITLE "Registry Database" + xVersion ;
         ICON "ICOREG" ;
         NOMAXIMIZE ;
         NOMINIMIZE ;
         NOSIZE ;
         ON RELEASE dbCloseArea( "HBREG" )

      DEFINE BROWSE Browse_Reg
         ROW 10
         COL 10
         WIDTH 760
         HEIGHT 300 - 10
         VALUE 0
         WIDTHS { 560, 170 }
         HEADERS { 'HKLM', 'KEY' }
         WORKAREA HBREG
         FIELDS { 'HBREG->HKLM', 'HBREG->KEY' }
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         ONCHANGE LoadDetail()
         ONDBLCLICK SetStartNode()
         ALLOWEDIT .F.
         ALLOWAPPEND .F.
         ALLOWDELETE .F.
         LOCK .F.
         VSCROLLBAR .T.
      END BROWSE

      DEFINE BUTTON Button_New
         ROW 316
         COL 10
         WIDTH 100
         HEIGHT 50
         ACTION OnAppend()
         CAPTION "&New"
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         TABSTOP .T.
         VISIBLE .T.
      END BUTTON

      DEFINE BUTTON Button_Save
         ROW 316
         COL 120
         WIDTH 100
         HEIGHT 50
         ACTION OnSave()
         CAPTION "&Save"
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         TABSTOP .T.
         VISIBLE .T.
      END BUTTON

      DEFINE BUTTON Button_Exit
         ROW 316
         COL 670
         WIDTH 103
         HEIGHT 50
         ACTION RegDbForm.Release
         CAPTION "&Exit"
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         TABSTOP .T.
         VISIBLE .T.
      END BUTTON

      DEFINE TEXTBOX Text_HKLM
         ROW 380
         COL 70
         WIDTH 690
         HEIGHT 30
         FIELD HBREG->HKLM
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         CASECONVERT NONE
         VALUE ""
      END TEXTBOX

      DEFINE TEXTBOX Text_KEY
         ROW 412
         COL 70
         WIDTH 360
         HEIGHT 30
         FIELD HBREG->KEY
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         CASECONVERT NONE
         VALUE ""
      END TEXTBOX

      DEFINE TEXTBOX Text_URL
         ROW 444
         COL 70
         WIDTH 690
         HEIGHT 30
         FIELD HBREG->WHEREURL
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         CASECONVERT NONE
         VALUE ""
      END TEXTBOX

      DEFINE EDITBOX Edit_Memo
         ROW 476
         COL 70
         WIDTH 690
         HEIGHT 70
         FIELD HBREG->COMMENT
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         HSCROLLBAR .F.
         VSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL Label_1
         ROW 383
         COL 10
         WIDTH 50
         HEIGHT 24
         VALUE "HKLM"
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         VISIBLE .T.
         RIGHTALIGN .T.
      END LABEL

      DEFINE LABEL Label_2
         ROW 415
         COL 10
         WIDTH 50
         HEIGHT 24
         VALUE "Key"
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         VISIBLE .T.
         RIGHTALIGN .T.
      END LABEL

      DEFINE BUTTON Button_GoURL
         ROW 444
         COL 10
         WIDTH 50
         HEIGHT 28
         ACTION GoToURL()
         CAPTION "GO Url"
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         TABSTOP .T.
         VISIBLE .T.
      END BUTTON

      DEFINE LABEL Label_3
         ROW 477
         COL 10
         WIDTH 50
         HEIGHT 24
         VALUE "Note"
         FONTNAME SP_cFontName()
         FONTSIZE SP_nFontSize()
         VISIBLE .T.
         RIGHTALIGN .T.
      END LABEL

   END WINDOW

   ON KEY ESCAPE OF RegDbForm ACTION RegDbForm.Release

   RegDbForm.Browse_Reg.setfocus
   CENTER WINDOW RegDbForm
   ACTIVATE WINDOW RegDbForm

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure LoadDetail()
*+
*+    Called from ( regdb.prg )   1 - procedure main()
*+                                   1 - static procedure onappend()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE LoadDetail()

   RegDbForm.Text_HKLM.refresh
   RegDbForm.Text_KEY.refresh
   RegDbForm.Text_URL.refresh
   RegDbForm.Edit_Memo.refresh
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure OnSave()
*+
*+    Called from ( regdb.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE OnSave()

   LOCAL aArray := { RegDbForm.Text_HKLM.Value, ;
                     RegDbForm.Text_KEY.Value, ;
                     RegDbForm.Text_URL.Value, ;
                     RegDbForm.Edit_Memo.Value }

   AEval( aArray, {| x, i | FieldPut( i, x ) } )
   RegDbForm.Browse_Reg.Refresh
   DO EVENTS
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure OnAppend()
*+
*+    Called from ( regdb.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE OnAppend()

   APPEND BLANK
   LoadDetail()

   RegDbForm.Browse_Reg.Value := RecNo()
   RegDbForm.Browse_Reg.Refresh
   RegDbForm.Text_HKLM.setfocus

   DO EVENTS
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure GoToURL()
*+
*+    Called from ( regdb.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE GoToURL()

   LOCAL cURL := Trim( RegDbForm.Text_URL.Value )

   IF !Empty( cURL )
      MYSHELLOPENFILE( cURL, "" )
   ENDIF
   DO EVENTS
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Function SetStartNode()
*+
*+    Called from ( regdb.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION SetStartNode()

   LOCAL cPath     := "Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"
   LOCAL cKEY      := "LastKey"
   LOCAL cRet      := ""
   LOCAL xValue
   LOCAL cTitle    := "Registrierungs-Editor"
   LOCAL hWndDlg
   LOCAL cWin      := GetEnv( "windir" )

   IF hb_cdpSelect() = "UTF8"
      hWndDlg := HMG_CallDLL( "User32.dll", DLL_OSAPI, "FindWindowW", 0, cTitle )
   ELSE
      hWndDlg := HMG_CallDLL( "User32.dll", DLL_OSAPI, "FindWindowA", 0, cTitle )
   ENDIF

   IF !( hWndDlg == 0 )
      HMG_CallDLL( "User32.dll", DLL_OSAPI, "SetForegroundWindow", hWndDlg )
      HMG_CallDLL( "User32.dll", DLL_OSAPI, "BringWindowToTop", hWndDlg )
      HMG_CallDLL( "User32.dll", DLL_OSAPI, "ShowWindow", hWndDlg, 1 )
      HMG_CallDLL( "User32.dll", DLL_OSAPI, "UpdateWindow", hWndDlg )
      // now close it
      HMG_CallDLL( "User32.DLL", DLL_OSAPI, "SendMessage", hWndDlg, WM_SYSCOMMAND, SC_CLOSE, 0 )
      // SendMessage( hWndDlg, WM_SYSCOMMAND, SC_CLOSE, 0 )
   ENDIF

   IF Is64Bit()
      HMG_CallDLL( "Kernel32.DLL", DLL_OSAPI, "Wow64EnableWow64FsRedirection", FALSE )
   ENDIF

   IF Alias() = "HBREG"
      xValue := Trim( HBREG->HKLM )
      RegistryWrite( "HKEY_CURRENT_USER\" + cPath + "\" + cKEY, xValue )
      MYSHELLOPENFILE( cWin + "\", "REGEDIT.EXE" )
   ENDIF

   IF Is64Bit()
      HMG_CallDLL( "Kernel32.DLL", DLL_OSAPI, "Wow64EnableWow64FsRedirection", TRUE )
   ENDIF

   DO EVENTS
RETURN cRet

*+--------------------------------------------------------------------
*+
*+    Static Function MYSHELLOPENFILE()
*+
*+    Called from ( regdb.prg )   1 - static procedure gotourl()
*+                                   1 - static function setstartnode()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION MYSHELLOPENFILE( cPath, cFile, cPara )

   LOCAL lSuccess
   LOCAL Retvar   := .F.

   DEFAULT cPath TO ""
   DEFAULT cFile TO ""
   DEFAULT cPara TO ""

   lSuccess := ShellExecute( 0, ;
                             "open", ;
                             cPath + cFile, ;
                             cPara, ;
                             0, ;
                             SW_NORMAL )

   DO CASE

      CASE lSuccess > 32                                              // Aufruf erfolgreich
         Retvar := .T.

      CASE lSuccess = SE_ERR_NOASSOC                                  // Keine verknpfte Anwendung

         // Falls ShowOpenWithDialog = True, wird der Dialog
         // "™ffnen mit" fr diese Datei angezeigt:
         // Shell "RunDLL32 shell32.dll,OpenAs_RunDLL " & Filename

         HMG_CallDLL( "SHELL32.DLL", DLL_OSAPI, "OpenAs_RunDLL", ;
                      0, ;
                      0, ;
                      cPath + cFile, ;
                      0, ;
                      CURDIR(), ;
                      SW_NORMAL )                                     // SW_MAXIMIZE

         //  Die Auswahlm”glichkeit wird als Erfolg gewertet:
         //Retvar := .F.
      OTHERWISE
         // ShellExecute war erfolglos.
         // Boolean-Standardwert False zurckgeben
         DO CASE
            CASE lSuccess = SE_ERR_FNF
               MsgInfo( "File not found.", cPath + cFile )
            CASE lSuccess = SE_ERR_PNF
               MsgInfo( "Path not found.", cPath + cFile )
            CASE lSuccess = SE_ERR_ACCESSDENIED
               MsgInfo( "Access denied !", cPath + cFile )
            CASE lSuccess = SE_ERR_OOM
               MsgInfo( "Out of memory !", cPath + cFile )
            CASE lSuccess = SE_ERR_SHARE
               MsgInfo( "Cannot share an open file.", cPath + cFile )
            CASE lSuccess = SE_ERR_ASSOCINCOMPLETE
               MsgInfo( "File association information not complete.", cPath + cFile )
            CASE lSuccess = SE_ERR_DDETIMEOUT
               MsgInfo( "DDE operation timed out.", cPath + cFile )
            CASE lSuccess = SE_ERR_DDEFAIL
               MsgInfo( "DDE operation failed.", cPath + cFile )
            CASE lSuccess = SE_ERR_DDEBUSY
               MsgInfo( "DDE operation is busy.", cPath + cFile )
         ENDCASE
         //Retvar := .F.
   ENDCASE

   DO EVENTS
RETURN Retvar

*+--------------------------------------------------------------------
*+
*+    Static Function Is64Bit()
*+
*+    Called from ( regdb.prg )   2 - static function setstartnode()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION Is64Bit()

RETURN hb_osIs64bit()

*+--------------------------------------------------------------------
*+
*+    Static Procedure Cre_REG()
*+
*+    Called from ( regdb.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE Cre_REG( datei, aArray )

   LOCAL field_list := {}
   LOCAL bGather    := {| a | AEval( a, {| x, i | FieldPut( i, x ) } ) }

   DEFAULT aArray TO RegArray()

   IF !File( datei )
      AAdd( field_list, { "HKLM", "C", 128, 0 } )
      AAdd( field_list, { "KEY", "C", 64, 0 } )
      AAdd( field_list, { "WHEREURL", "C", 128, 0 } )
      AAdd( field_list, { "COMMENT", "C", 250, 0 } )

      dbCreate( datei, field_list, "DBFCDX" )

      USE (datei) ALIAS "HBREG" VIA "DBFCDX" NEW EXCLUSIVE
      AEval( aArray, {| x | dbAppend(), Eval( bGather, x ) } )
      CLOSE
   ENDIF

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Function RegArray()
*+
*+    Called from ( regdb.prg )   1 - static procedure cre_reg()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION RegArray()

   LOCAL aArray := {}

   AAdd( aArray, { "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers", ;
                   "0", ;
                   "", ;
                   "Windows Time Server" + CRLF + "Germany : ptbtime1.ptb.de" } )

   AAdd( aArray, { "HKEY_CURRENT_USER\Environment", ;
                   "LIB", ;
                   "", ;
                   "USER Environment" } )

   AAdd( aArray, { "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Environment", ;
                   "OS", ;
                   "", ;
                   "SYSTEM Environment" } )

   AAdd( aArray, { "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont", ;
                   "0", ;
                   "", ;
                   "Consolas TTF" } )

   AAdd( aArray, { "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", ;
                   "ProductId", ;
                   "", ;
                   "OEM Seriennummer" } )

   AAdd( aArray, { "HKEY_CURRENT_USER\Control Panel\Desktop", ;
                   "Wallpaper", ;
                   "", ;
                   "Wallpaper" } )

   AAdd( aArray, { "HKEY_CURRENT_USER\Software\Microsoft\Notepad", ;
                   "StatusBar", ;
                   "", ;
                   "enable = 1" } )

   AAdd( aArray, { "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", ;
                   "ShowSecondsInSystemClock", ;
                   "", ;
                   "Windows 10 : Uhrzeit im Try mit Sekunden" } )

   AAdd( aArray, { "HKEY_CURRENT_USER\Control Panel\Desktop", ;
                   "JPEGImportQuality", ;
                   "", ;
                   "Windows 10 : Wallpaper Qualit„t max 100" } )

   AAdd( aArray, { "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer", ;
                   "ShowDriveLettersFirst", ;
                   "http://support.microsoft.com/kb/330193", ;
                   "Laufwerksbuchstaben zuerst anzeigen; setzen Sie den Wert auf ï4ï.;Der Wert ï2ï unterdrckt die Anzeige der Laufwerksbuchstaben vollst„ndig." } )

   AAdd( aArray, { "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics", ;
                   "IconSpacing", ;
                   "", ;
                   "Horizontal Spacing Icons Desktop" } )

   AAdd( aArray, { "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics", ;
                   "IconVerticalSpacing", ;
                   "", ;
                   "Vertikal Spacing Icons Desktop" } )

   AAdd( aArray, { "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Lanmanworkstation\Parameters", ;
                   "DirectoryCacheLifetime", ;
                   "http://technet.microsoft.com/en-us/library/ff686200%28WS.10%29.aspx", ;
                   "for xBase set to 0 (zero)" } )

   AAdd( aArray, { "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Lanmanworkstation\Parameters", ;
                   "FileNotFoundCacheLifetime", ;
                   "http://technet.microsoft.com/en-us/library/ff686200%28WS.10%29.aspx", ;
                   "for xBase set to 0 (zero)" } )

   AAdd( aArray, { "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Lanmanworkstation\Parameters", ;
                   "FileInfoCacheLifetime", ;
                   "http://technet.microsoft.com/en-us/library/ff686200%28WS.10%29.aspx", ;
                   "for xBase set to 0 (zero)" } )

RETURN aArray

*+--------------------------------------------------------------------
*+
*+    Static Function SP_cFontName()
*+
*+    Called from ( regdb.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION SP_cFontName( xValue )

   IF PCount() > 0
      _SetGetGlobal( "cFontName", xValue )
   ENDIF
RETURN _SetGetGlobal( "cFontName" )

*+--------------------------------------------------------------------
*+
*+    Static Function SP_nFontSize()
*+
*+    Called from ( regdb.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION SP_nFontSize( xValue )

   IF PCount() > 0
      _SetGetGlobal( "nFontSize", xValue )
   ENDIF
RETURN _SetGetGlobal( "nFontSize" )


*+ EOF: REGDB.PRG
