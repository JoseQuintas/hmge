/*
 * GuiDes source code:
 *
 * Copyright 2002 Carlos Andr‚s <carlos.andres@navegalia.com>
 * www - http://www.geocities.com/harbour_links/guides
 *
 * GuiDes is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * GuiDes is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 */

#include "GUIDES.CH"
#include "minigui.ch"
#include "hbclass.ch"

DECLARE WINDOW StyleSelec
DECLARE WINDOW Prefer

CREATE CLASS gStyle
   CLASS VAR WidNum INIT 0

   DATA Font                  INIT G_FONT
   DATA BackColor             INIT G_GREY
   DATA FontColor             INIT G_BLACK
   DATA Win_BackColor         INIT G_GREY

   DATA LastLoaded            INIT ""

// DATA ProjectWindows  INIT {}

   METHOD NEW  CONSTRUCTOR

   METHOD Width()   INLINE GetProperty( "Prefer", "tbWidth", "Value" )
   METHOD Height()  INLINE GetProperty( "Prefer", "tbHeight", "Value" )
   METHOD BigWidth()  INLINE GetProperty( "Prefer", "tbBigWidth", "Value" )
   METHOD BigHeight()  INLINE GetProperty( "Prefer", "tbBigHeight", "Value" )
   METHOD WinWidth()  INLINE GetProperty( "Prefer", "tbWinWidth", "Value" )
   METHOD WinHeight()  INLINE GetProperty( "Prefer", "tbWinHeight", "Value" )
   METHOD Autosize()  INLINE GetProperty( "Prefer", "tbAutoSize", "Value" )
   METHOD CodeIncludeParent() INLINE GetProperty( "Prefer", "tbInclude", "Value" )
   METHOD FullCode()  INLINE GetProperty( "Prefer", "tbFullCode", "Value" )
   METHOD ProjectDir()  INLINE GetProperty( "Prefer", "tbFolder", "Value" )
   METHOD XSpac()    INLINE GetProperty( "Prefer", "tbX", "Value" )
   METHOD YSpac()   INLINE GetProperty( "Prefer", "tbY", "Value" )
   METHOD Grid_On()  INLINE GetProperty( "Prefer", "PrefGrid", "Value" )
   METHOD CodeTab()  INLINE GetProperty( "Prefer", "tbCodeTab", "Value" )
   METHOD WinProps()  INLINE GetProperty( "Prefer", "tbWinProps", "Value" )
   METHOD AutoInspect()  INLINE GetProperty( "Prefer", "tbAutoInspect", "Value" )
   METHOD ExportDBCode() INLINE GetProperty( "Prefer", "tbExportDBCode", "Value" )
   METHOD UseWindowFont() INLINE GetProperty( "Prefer", "tbUseWindowFont", "Value" )
   METHOD AddMoveButtons() INLINE GetProperty( "Prefer", "tbAddMoveButtons", "Value" )
   METHOD CompileFile()  INLINE GetProperty( "Prefer", "tbCompileFile", "Value" )
   METHOD CompileFlags() INLINE GetProperty( "Prefer", "tbCompileFlags", "Value" )



   METHOD RefreshPrefWindow()
   METHOD ChooseFont()
   METHOD ChooseBackColor()
   METHOD ChooseFontColor()
   METHOD ChooseWinBackColor()
   METHOD ChooseProjectDir()
   METHOD ChooseCompileFile()

   METHOD LoadStyle()
   METHOD SaveStyle()
   METHOD DoLoad( cStyle )
   METHOD ChooseFile( cMessage, lGet )

END CLASS


METHOD New() CLASS gStyle

   LOCAL cProjectFile := "DEFAULT.STY"

   IF !File( cProjectFile )
      MsgBox( "User Default style wasn't loaded." + CR_LF + "Embedded style will be used instead.", "GuiDes" )
   ENDIF
   ::DoLoad( cProjectFile )

   ::RefreshPrefWindow()

RETURN Self


METHOD RefreshPrefWindow() CLASS gStyle

   Prefer.tbBGCol.Value := CastToChar( ::BackColor )
   Prefer.tbFontCol.Value := CastToChar( ::FontColor )
   Prefer.tbFont.Value :=  CastToChar( ::Font )
   Prefer.tbLWBGColor.Value :=  CastToChar( ::Win_BackColor )

RETURN Self


METHOD ChooseFont() CLASS gStyle

   ::Font := ChangeFont( ::Font )
   ::RefreshPrefWindow()

RETURN NIL


METHOD ChooseBackColor() CLASS gStyle

   LOCAL aColor := ::BackColor                                      // GF

   ::BackColor := GetColor( IF( aColor[ 1 ] == NIL, NIL, aColor ) )   // GF
   ::RefreshPrefWindow()

RETURN NIL


METHOD ChooseFontColor() CLASS gStyle

   LOCAL aColor := ::FontColor                                      // GF

   ::FontColor := GetColor( IF( aColor[ 1 ] == NIL, NIL, aColor ) )   // GF
   ::RefreshPrefWindow()

RETURN NIL


METHOD ChooseWinBackColor() CLASS gStyle

   LOCAL aColor := ::Win_BackColor                                      // GF

   ::Win_BackColor := GetColor( IF( aColor[ 1 ] == NIL, NIL, aColor ) )   // GF
   ::RefreshPrefWindow()

RETURN NIL


METHOD ChooseProjectDir() CLASS gStyle

   LOCAL cNewFolder := AllTrim( GetFolder() )

   IF !Empty( cNewFolder )
      Prefer.tbFolder.Value := cNewFolder
      ::RefreshPrefWindow()
   ENDIF

RETURN NIL


METHOD LoadStyle() CLASS gStyle

   LOCAL cFile := ::ChooseFile( "Do you really want to load a new style?", TRUE )

   IF !Empty( cFile )
      ::DoLoad( cFile )
      ::RefreshPrefWindow()
      Prefer.tbLastLoaded.Value := cFile

      PlayHand()
   ENDIF

RETURN NIL


METHOD SaveStyle() CLASS gStyle

   LOCAL cFile := ::ChooseFile( , FALSE )

   IF !Empty( cFile )

      BEGIN INI FILE cFile

      SET SECTION "Style" ENTRY "Font" TO ::Font
      SET SECTION "Style" ENTRY "BackColor" TO ::BackColor
      SET SECTION "Style" ENTRY "FontColor" TO ::FontColor
      SET SECTION "Style" ENTRY "XSpacing" TO ::XSpac()
      SET SECTION "Style" ENTRY "YSpacing" TO ::YSpac()
      SET SECTION "Style" ENTRY "Grid" TO ::Grid_On
      SET SECTION "Style" ENTRY "WinBackColor" TO ::Win_BackColor
      SET SECTION "Style" ENTRY "Width" TO ::Width()
      SET SECTION "Style" ENTRY "Height" TO ::Height()
      SET SECTION "Style" ENTRY "BigWidth" TO ::BigWidth()
      SET SECTION "Style" ENTRY "BigHeight" TO ::BigHeight()
      SET SECTION "Style" ENTRY "WinWidth" TO ::WinWidth()
      SET SECTION "Style" ENTRY "WinHeight" TO ::WinHeight()
      SET SECTION "Style" ENTRY "cIncParent" TO ::CodeIncludeParent()
      SET SECTION "Style" ENTRY "FullCode" TO ::FullCode()
      SET SECTION "Style" ENTRY "CodeTab" TO ::CodeTab()
      SET SECTION "Style" ENTRY "ProjectDir" TO ::ProjectDir()
      SET SECTION "Style" ENTRY "WinProps" TO ::WinProps()
      SET SECTION "Style" ENTRY "AutoInspect" TO ::AutoInspect()
      SET SECTION "Style" ENTRY "ExportDBCode" TO ::ExportDBCode()
      SET SECTION "Style" ENTRY "UseWindowFont" TO ::UseWindowFont()
      SET SECTION "Style" ENTRY "Autosize" TO ::AutoSize()
      SET SECTION "Style" ENTRY "AddMoveButtons" TO ::AddMoveButtons()
      SET SECTION "Style" ENTRY "CompileFile" TO ::CompileFile()
      SET SECTION "Style" ENTRY "CompileFlags" TO ::CompileFlags()


      MsgBox( "Style " + cFile + " saved!", "GuiDes" )

      END INI

   ENDIF

RETURN NIL



METHOD DoLoad( cStyle ) CLASS gStyle

   BEGIN INI FILE cStyle

   GET ::Font         SECTION "Style" ENTRY "Font"     DEFAULT G_FONT
   GET ::BackColor    SECTION "Style" ENTRY "BackColor"  DEFAULT G_WHITE
   GET ::FontColor    SECTION "Style" ENTRY "FontColor"  DEFAULT G_BLACK
   GET ::Win_BackColor   SECTION "Style" ENTRY "WinBackColor" DEFAULT G_GREY

   Prefer.tbWidth.Value := _GetIni( "Style", "Width", 100, GetProperty( "Prefer", "tbWidth", "Value" ) )
   Prefer.tbHeight.Value := _GetIni( "Style", "Height", 30, GetProperty( "Prefer", "tbHeight", "Value" ) )
   Prefer.tbBigWidth.Value := _GetIni( "Style", "BigWidth", 150, GetProperty( "Prefer", "tbBigWidth", "Value" ) )
   Prefer.tbBigHeight.Value := _GetIni( "Style", "BigHeight", 150, GetProperty( "Prefer", "tbBigHeight", "Value" ) )
   Prefer.tbWinWidth.Value := _GetIni( "Style", "WinWidth", 500, GetProperty( "Prefer", "tbWinWidth", "Value" ) )
   Prefer.tbWinHeight.Value := _GetIni( "Style", "WinHeight", 500, GetProperty( "Prefer", "tbWinHeight", "Value" ) )
   Prefer.tbInclude.Value := _GetIni( "Style", "cIncParent", TRUE, GetProperty( "Prefer", "tbInclude", "Value" ) )
   Prefer.tbFullCode.Value := _GetIni( "Style", "FullCode", TRUE, GetProperty( "Prefer", "tbFullCode", "Value" ) )
   Prefer.tbFolder.Value := _GetIni( "Style", "ProjectDir", "C:\GUIDES", GetProperty( "Prefer", "tbFolder", "Value" ) )
   Prefer.tbX.Value := _GetIni( "Style", "XSpacing", 10, GetProperty( "Prefer", "tbX", "Value" ) )
   Prefer.tbY.Value := _GetIni( "Style", "YSpacing", 10, GetProperty( "Prefer", "tbY", "Value" ) )
   Prefer.PrefGrid.Value := _GetIni( "Style", "Grid", FALSE, GetProperty( "Prefer", "PrefGrid", "Value" ) )
   Prefer.tbCodeTab.Value := _GetIni( "Style", "CodeTab", 4, GetProperty( "Prefer", "tbCodeTab", "Value" ) )
   Prefer.tbWinProps.Value := _GetIni( "Style", "WinProps", TRUE, GetProperty( "Prefer", "tbWinProps", "Value" ) )
   Prefer.tbAutoInspect.Value := _GetIni( "Style", "AutoInspect", TRUE, GetProperty( "Prefer", "tbAutoInspect", "Value" ) )
   Prefer.tbExportDBCode.Value := _GetIni( "Style", "ExportDBCode", TRUE, GetProperty( "Prefer", "tbExportDBCode", "Value" ) )
   Prefer.tbUseWindowFont.Value := _GetIni( "Style", "UseWindowFont", TRUE, GetProperty( "Prefer", "tbUseWindowFont", "Value" ) )
   Prefer.tbAutosize.Value := _GetIni( "Style", "Autosize", TRUE, GetProperty( "Prefer", "tbAutosize", "Value" ) )
   Prefer.tbAddMoveButtons.Value := _GetIni( "Style", "AddMoveButtons", TRUE, GetProperty( "Prefer", "tbAddMoveButtons", "Value" ) )
   Prefer.tbCompileFile.Value := _GetIni( "Style", "CompileFile", "C:\MINIGUI\BATCH\COMPILE.BAT", GetProperty( "Prefer", "tbCompileFile", "Value" ) )
   Prefer.tbCompileFlags.Value := _GetIni( "Style", "CompileFlags", "", GetProperty( "Prefer", "tbCompileFlags", "Value" ) )

   ::RefreshPrefWindow()

// When ProjectWindows is set, make windows to be loaded

   END INI

RETURN NIL



METHOD ChooseFile( cMessage, lGet ) CLASS gStyle

   LOCAL cFileExt := ".STY"
   LOCAL cFile := ""
   LOCAL cTitle := "GuiDes - Choose Style File"
   LOCAL acFilter

   acFilter := { { "Style files (*.sty)", "*.STY" }, ;
      { "All files (*.*)", "*.*" } }

   IF Empty( cMessage ) .OR. MsgYesNo( cMessage, "GuiDes" )

      cFile := iif( lGet, GetFile( acFilter, cTitle, GuiDesDir ), PutFile( acFilter, cTitle, GuiDesDir ) )

      IF !Empty( cFile )
         cFile := ForceExt( cFile, cFileExt )
         IF File( cFile ) .AND. !lGet
            IF( MsgOKCancel( "File " + cFile + " already exists!" + CR_LF + "Do you want to overwrite it?", "Warning!" ) )
               RETURN cFile
            ELSE
               RETURN ""
            ENDIF
         ENDIF
      ENDIF
   ENDIF

RETURN cFile


METHOD ChooseCompileFile() CLASS gStyle

   LOCAL cNewFile := AllTrim( GetFile() )

   IF !Empty( cNewFile )
      Prefer.tbCompileFile.Value := cNewFile
      ::RefreshPrefWindow()
   ENDIF

RETURN NIL
