/*
 * MiniGUI Show of icons from the dll library
 *
 * Copyright 2013 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Copyright 2013-2015 Grigory Filatov <gfilatov@gmail.com>
 *
 * Based upon the Minigui\Samples\Basic\ExtractIcon\demo2.prg sample
 * rewritten for HMG by Auge & Ohr, Jimmy
*/

#include "hmg.ch"

#define WM_VSCROLL         277 // 0x0115
#define SB_LINEUP          0
#define SB_LINEDOWN        1
#define SB_PAGEUP          2
#define SB_PAGEDOWN        3

#define IMAGE_BITMAP       0
#define IMAGE_ICON         1
#define IMAGE_CURSOR       2
#define IMAGE_ENHMETAFILE  3

#define BM_SETIMAGE        0x00F7

#xtranslate LTRIM( STR( <i> ) ) => hb_ntos( <i> )

*+--------------------------------------------------------------------
*+
*+    Procedure MAIN()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE Main()

   LOCAL cFolder := System.SystemFolder
   LOCAL aFolder := {}
   LOCAL aWidth := { 100, 350 }
   LOCAL aHead := { "Dll", "Comment" }
   LOCAL i, cDll

   AAdd( aFolder, { "imageres.dll", "Windows Image Resource" } )
   AAdd( aFolder, { "shell32.dll", "Windows Shell Common" } )
   AAdd( aFolder, { "netshell.dll", "Network Connections Shell" } )
   AAdd( aFolder, { "wmploc.dll", "Windows Media Player Resources" } )
   AAdd( aFolder, { "DDORes.dll", "Device Category Information and Resources" } )
   AAdd( aFolder, { "mmcndmgr.dll", "Microsoft Management Console Node Manager" } )
   AAdd( aFolder, { "moricons.dll", "Windows NT Setup Icon Resources" } )
   AAdd( aFolder, { "ieframe.dll", "Internet Explorer" } )
   AAdd( aFolder, { "compstui.dll", "Common Property Sheet User Interface" } )
   AAdd( aFolder, { "setupapi.dll", "Windows Setup API" } )
   AAdd( aFolder, { "bootux.dll", "Boot UI" } )
   AAdd( aFolder, { "SyncCenter.dll", "Sync Center" } )
   AAdd( aFolder, { "pnidui.dll", "Network System Icons" } )
   AAdd( aFolder, { "FXSRESM.dll", "Fax Resource" } )
   AAdd( aFolder, { "pifmgr.dll", "Windows NT PIF Manager Icon Resource Library" } )
   AAdd( aFolder, { "dsuiext.dll", "Directory Service Common UI" } )
   AAdd( aFolder, { "wwanmm.dll", "WWAN Media Control" } )
   AAdd( aFolder, { "msihnd.dll", "Windows Installer" } )
   AAdd( aFolder, { "rasgcw.dll", "RAS Assistent" } )
   AAdd( aFolder, { "stobject.dll", "Systray Shell Service Object" } )
   AAdd( aFolder, { "msctf.dll", "MSCTF Server DLL" } )
   AAdd( aFolder, { "mshtml.dll", "HTML Display" } )
   AAdd( aFolder, { "cryptui.dll", "Secures UI Provider" } )
   AAdd( aFolder, { "msutb.dll", "MSUTB Server DLL" } )
   AAdd( aFolder, { "accessibilitycpl.dll", "Erleichterte Bedienung" } )
   AAdd( aFolder, { "rasdlg.dll", "RAS Dialog" } )
   AAdd( aFolder, { "SensorsCpl.dll", "Position and Sensor" } )
   AAdd( aFolder, { "twinui.dll", "TWIN UI" } )
   AAdd( aFolder, { "wiashext.dll", "Imaging Devices Shell Folder UI" } )
   AAdd( aFolder, { "WlanMM.dll", "Ad-Hoc Manager" } )
   AAdd( aFolder, { "wpdshext.dll", "Portable Devices Shell Extension" } )
   AAdd( aFolder, { "dmdskres.dll", "Disk Management Support SnapIn" } )
   AAdd( aFolder, { "comres.dll", "COM+ Resources" } )
   AAdd( aFolder, { "ipsmsnap.dll", "IP Security Monitor" } )
   AAdd( aFolder, { "networkexplorer.dll", "Network Explorer" } )
   AAdd( aFolder, { "comdlg32.dll", "Common Dialog" } )
   AAdd( aFolder, { "PortableDeviceStatus.dll", "" } )
   AAdd( aFolder, { "localsec.dll", "MMC Snap-in" } )
   AAdd( aFolder, { "mmres.dll", "General Audio Resources" } )
   AAdd( aFolder, { "urlmon.dll", "OLE32 Extension for Win32" } )
   AAdd( aFolder, { "certmgr.dll", "Zertificate Snap-in" } )
   AAdd( aFolder, { "azroleui.dll", "Automation Manager" } )
   AAdd( aFolder, { "WFSR.dll", "Resource for FAX / Scan" } )
   AAdd( aFolder, { "mssvp.dll", "MS Search" } )
   AAdd( aFolder, { "taskbarcpl.dll", "Taskbar" } )
   AAdd( aFolder, { "wiadefui.dll", "WIA Scanner" } )
   AAdd( aFolder, { "connect.dll", "Connection Assistant" } )
   AAdd( aFolder, { "mstscax.dll", "Remote Desktop Services ActiveX Client" } )
   AAdd( aFolder, { "netcenter.dll", "Network Center" } )
   AAdd( aFolder, { "prnfldr.dll", "Printer" } )
   AAdd( aFolder, { "objsel.dll", "Dialog Object" } )
   AAdd( aFolder, { "SecurityHealthSSO.dll", "Secority SSO" } )
   AAdd( aFolder, { "SndVolSSO.dll", "SCA Loudness" } )
   AAdd( aFolder, { "FXSST.dll", "FAX Servive" } )
   AAdd( aFolder, { "DxpTaskSync.dll", "DXP Sync" } )
   AAdd( aFolder, { "fontext.dll", "Font Folder" } )
   AAdd( aFolder, { "mmcbase.dll", "MMC Basic DLL" } )
   AAdd( aFolder, { "RASMM.dll", "RAS Media" } )
   AAdd( aFolder, { "quartz.dll", "Directshow DLL" } )
   AAdd( aFolder, { "wmp.dll", "" } )
   AAdd( aFolder, { "colorui.dll", "" } )
   AAdd( aFolder, { "DiagCpl.dll", "" } )
   AAdd( aFolder, { "fdprint.dll", "" } )
   AAdd( aFolder, { "hnetcfg.dll", "" } )
   AAdd( aFolder, { "imagesp1.dll", "" } )
   AAdd( aFolder, { "printui.dll", "" } )
   AAdd( aFolder, { "WorkfoldersControl.dll", "" } )
   AAdd( aFolder, { "ntshrui.dll", "" } )
   AAdd( aFolder, { "scrptadm.dll", "" } )
   AAdd( aFolder, { "webcheck.dll", "" } )
   AAdd( aFolder, { "wininetlui.dll", "" } )
   AAdd( aFolder, { "wlangpui.dll", "" } )
   AAdd( aFolder, { "wlanpref.dll", "" } )
   AAdd( aFolder, { "ActionCenterCPL.dll", "" } )
   AAdd( aFolder, { "devmgr.dll", "" } )
   AAdd( aFolder, { "els.dll", "" } )
   AAdd( aFolder, { "netplwiz.dll", "" } )
   AAdd( aFolder, { "newdev.dll", "" } )
   AAdd( aFolder, { "sud.dll", "" } )
   AAdd( aFolder, { "user32.dll", "" } )
   AAdd( aFolder, { "wdc.dll", "" } )
   AAdd( aFolder, { "aclui.dll", "" } )
   AAdd( aFolder, { "cscui.dll", "" } )
   AAdd( aFolder, { "ExplorerFrame.dll", "" } )
   AAdd( aFolder, { "mscandui.dll", "" } )
   AAdd( aFolder, { "shdocvw.dll", "Shell Doc Object and Control Library" } )

   FOR i := Len( aFolder ) TO 1 STEP -1
      cDll := cFolder + "\" + aFolder[ i ][ 1 ]
      IF ! File( cDll )
         ADel( aFolder, i )
         ASize( aFolder, Len( aFolder ) - 1 )
      ENDIF
   NEXT

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 600 ;
         TITLE "Extract Icon" ;
         ICON "A1MAIN" ;
         MAIN ;
         NOMAXIMIZE ;
         NOMINIMIZE ;
         NOSIZE ;
         BACKCOLOR NIL

      DEFINE GRID Grid_1
         ROW 10
         COL 10
         WIDTH 464
         HEIGHT 550
         ITEMS aFolder
         VALUE 1
         WIDTHS aWidth
         HEADERS aHead
         FONTNAME "Arial"
         FONTSIZE 12
         ONDBLCLICK DoUseThis( ThisWindow.NAME, This.NAME, aFolder )
         SHOWHEADERS .T.
      END GRID

   END WINDOW

   CENTER WINDOW Form_1
   Form_1.Activate()

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure DoUseThis()
*+
*+    Called from ( dllicons.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE DoUseThis( cForm, cControl, aFolder )

   LOCAL cFolder := System.SystemFolder
   LOCAL nValue := GetProperty( cForm, cControl, "Value" )
   LOCAL cDll

   IF ! Empty( nValue )
      cDll := cFolder + "\" + aFolder[ nValue ][ 1 ]
      ShowDLL( cDll )

      DoMethod( cForm, "Show" )
      DoMethod( cForm, cControl, "Setfocus" )
   ENDIF

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure ShowDLL()
*+
*+    Called from ( dllicons.prg )   1 - procedure dousethis()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE ShowDLL( cWhich )

   LOCAL nDesktopHeight := GetDesktopRealHeight() - 30
   LOCAL nDesktopWidth := GetDesktopRealWidth() - 20
   LOCAL cIconSrc := cWhich
   LOCAL nCount := ExtractIcon( cIconSrc, -1 ) - 1
   LOCAL nMaxWidth := Round( Sqrt( nCount ) * 80, 0 )
   LOCAL nOptimize, i

   IF nMaxWidth > nDesktopWidth
      nMaxWidth := nDesktopWidth
   ENDIF
   nOptimize := Round( nMaxWidth / 60, 0 )
   FOR i := nOptimize TO 1 STEP -11
      IF nMaxWidth < nOptimize * 60
         nMaxWidth := ( nOptimize * 60 ) + 20
         EXIT
      ENDIF
   NEXT

   IF nDesktopHeight > ( nMaxWidth )
      nDesktopHeight := ( nMaxWidth )
   ENDIF

   DEFINE WINDOW Form_2 ;
         WIDTH nMaxWidth ;
         HEIGHT nDesktopHeight ;
         VIRTUAL HEIGHT nDesktopHeight * 1.4 ;
         TITLE "Icons from " + cWhich ;
         ICON "A1MAIN" ;
         NOSIZE ;
         NOMINIMIZE ;
         NOMAXIMIZE ;
         ON INIT MyDrawIcons( cWhich )

      ON KEY ESCAPE ACTION ThisWindow.Release()
      ON KEY PRIOR ACTION SendMessage( ThisWindow.Handle, WM_VSCROLL, SB_PAGEUP, 0 )
      ON KEY NEXT ACTION SendMessage( ThisWindow.Handle, WM_VSCROLL, SB_PAGEDOWN, 0 )
      ON KEY UP ACTION SendMessage( ThisWindow.Handle, WM_VSCROLL, SB_LINEUP, 0 )
      ON KEY DOWN ACTION SendMessage( ThisWindow.Handle, WM_VSCROLL, SB_LINEDOWN, 0 )
   END WINDOW

   Form_2.VISIBLE := .F.
   CENTER WINDOW Form_2
   Form_2.Activate()

RETURN

*+--------------------------------------------------------------------
*+
*+    Function MyDrawIcons()
*+
*+    Called from ( dllicons.prg )   1 - procedure showdll()
*+
*+--------------------------------------------------------------------
*+
FUNCTION MyDrawIcons( cWhich )

   LOCAL nJ := 0, nI, cStr, cObj, nRow := 10, nCol
   LOCAL nWidth := Form_2.WIDTH
   LOCAL cIconSrc := cWhich
   LOCAL nCount := ExtractIcon( cIconSrc, -1 ) - 1
   LOCAL hGrid := GetControlHandle( "Grid_1", "Form_1" )
   LOCAL hIcon, nHWnd

   this.Title := ( this.Title ) + " (" + hb_ntos( nCount + 1 ) + " icons)"

   DoMethod( "Form_1", "Setfocus" )
   SetWindowCursor( hGrid, IDC_WAIT )

   DoMethod( "Form_2", "hide" )
   FOR nI := 0 TO nCount

      nCol := 10 + 60 * ( ++nJ - 1 )
      IF nCol > nWidth - 60
         nRow += 60
         nJ := 1
         nCol := 10
      ENDIF

      cObj := "Btn_" + LTrim( Str( nI ) )
      @ nROW, nCol BUTTON &cObj ;
         OF Form_2 ;
         PICTURE NIL ;
         WIDTH 38 HEIGHT 38 ;
         ACTION SaveThisIcon( cIconSrc, Val( SubStr( This.NAME, At( "_", This.Name ) + 1 ) ) )

      // Workaround for HMG
      //
      hIcon := ExtractIcon( cIconSrc, nI )
      IF IsHIcon( hIcon )
         nHWnd := GetControlHandle( cObj, "Form_2" )
         SendMessage( nHWnd, BM_SETIMAGE, IMAGE_ICON, hIcon )
         DestroyIcon( hIcon )
      ENDIF

      cObj := "Lbl_" + LTrim( Str( nI ) )
      cStr := "nI= " + LTrim( Str( nI ) )
      @ nROW + 40, nCol LABEL &cObj ;
         OF Form_2 ;
         VALUE cStr ;
         WIDTH 60 HEIGHT 12 ;
         TRANSPARENT FONTCOLOR BLUE ;
         ACTION SaveThisIcon( cIconSrc, Val( SubStr( This.NAME, At( "_", This.Name ) + 1 ) ) )

      IF nI % 18 == 0
         DO EVENTS
      ENDIF
   NEXT

   SetWindowCursor( hGrid, IDC_ARROW )
   DoMethod( "Form_1", "hide" )

   DoMethod( "Form_2", "show" )
   DoMethod( "Form_2", "Setfocus" )

RETURN NIL

*+--------------------------------------------------------------------
*+
*+    Function SaveThisIcon()
*+
*+    Called from ( dllicons.prg )   2 - function mydrawicons()
*+
*+--------------------------------------------------------------------
*+
FUNCTION SaveThisIcon( cSrcName, nI )

   LOCAL cFileName := PutFile( { { "Icon Files (*.ico)", "*.ico" } }, "Save Icon",, .T. )

   IF ! Empty( cFileName ) .AND. SaveIcon( cFileName, cSrcName, nI )
      MsgInfo( "Icon was saved successfully", "Result" )
   ENDIF

RETURN NIL

*+--------------------------------------------------------------------
*+
*+    Function SaveIcon()
*+
*+    Called from ( dllicons.prg )   1 - function savethisicon()
*+
*+--------------------------------------------------------------------
*+
FUNCTION SaveIcon( cIconName, cIconSrc, nItem )

   LOCAL aIcons := ExtractIconEx( cIconSrc, nItem )

   IF ".ICO" $ Upper( cIconName )
   ELSE
      cIconName := Trim( cIconName ) + ".ICO"
   ENDIF

RETURN C_SaveHIconToFile( cIconName, aIcons )

*+ EOF: DLLICONS.PRG