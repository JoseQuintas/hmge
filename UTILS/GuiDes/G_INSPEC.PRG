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
#include "Fileio.ch"

CREATE CLASS gTextEditor

   DATA FileName  INIT ""
   DATA READONLY  INIT FALSE
   DATA TEXT  INIT ""

   METHOD New( cFileName, lReadOnly )   CONSTRUCTOR
   METHOD Save( lForce )
   METHOD Compile()
   METHOD HasChanged()
   METHOD GetFileName()
   METHOD GetFileText()
   METHOD Open()

END CLASS


METHOD New( cFileName, lReadOnly ) CLASS gTextEditor

   ::FileName := cFileName
   ::READONLY := lReadOnly

   IF Empty( ::FileName )
      ::FileName := ::GetFileName()
   ENDIF

   IF ::READONLY == NIL
      ::READONLY := TRUE
   ENDIF

   ::TEXT := ::GetFileText()

   DEFINE WINDOW TextFileWin ;
      AT 50, 200 ;
      WIDTH 600 + 2 * GetBorderWidth() ;
      HEIGHT 545 ;
      TITLE ::FileName  ;
      ICON "AGUIDES" ;
      MODAL ;
      ON RELEASE ::Save( FALSE )

   IF ::ReadOnly
      @ 0, 0 EDITBOX Texto ;
         WIDTH 600 HEIGHT 500 ;
         VALUE ::TEXT ;
         READONLY  ;
         FONT 'Courier New' SIZE 10 ;
         BACKCOLOR G_LIGHTGREY
   ELSE

      DEFINE MAIN MENU

      POPUP 'File'

      ITEM 'Open' ;
         ACTION ::Open()

      ITEM 'Save' ;
         ACTION ::Save( TRUE )

      ITEM 'Compile' ;
         ACTION ::Compile()

      SEPARATOR

      ITEM 'Exit' ;
         ACTION ThisWindow.Release

      END POPUP

      END MENU

      DEFINE SPLITBOX

      DEFINE TOOLBAR ToolBar1 BUTTONSIZE 24, 32 FONT "ARIAL" SIZE 8 FLAT

      BUTTON tbOpen ;
         TOOLTIP 'Open' ;       // GF
         PICTURE 'LOADWIN' ;
         ACTION ::Open()

      BUTTON tbSave ;
         TOOLTIP 'Save' ;       // GF
         PICTURE 'SAVE' ;
         ACTION ::Save( TRUE )

      BUTTON tbcOMPILE ;
         TOOLTIP 'Compile' ;    // GF
         PICTURE 'COMPILE' ;
         ACTION ::Compile()

      END TOOLBAR

      EDITBOX Texto ;
         WIDTH 1000 HEIGHT 428 ;
         VALUE ::TEXT ;
         FONT 'Courier New' SIZE 10

      END SPLITBOX

   ENDIF

   DEFINE STATUSBAR

      STATUSITEM iif( ::READONLY, "READONLY", "EDITABLE" ) WIDTH 100

   END STATUSBAR

   END WINDOW

   IF ::ReadOnly
      TextFileWin.Height := GetTitleHeight() + TextFileWin.Texto.Height + TextFileWin.StatusBar.Height + 2 * GetBorderHeight()
   ELSE
      TextFileWin.Height := GetMenuBarHeight() + GetToolBarHeight() + GetTitleHeight() + TextFileWin.Texto.Height + TextFileWin.StatusBar.Height + 2 * GetBorderHeight()
   ENDIF

   CENTER WINDOW TextFileWin
   ACTIVATE WINDOW TextFileWin

RETURN NIL


METHOD Save( lForce ) CLASS gTextEditor

   LOCAL cFinalText

   IF !lForce .AND. ::HasChanged()
      lForce := MsgYesNo( ::FileName + " has changed" + CR_LF + "Do you want to save changes now?", "GuiDes" )
   ENDIF

   IF lForce
      cFinalText := TextFileWin .Texto. Value
      MemoWrit( ::FileName, cFinalText )
      MsgBox( ::FileName + " has been saved", "GuiDes" )
   ENDIF

RETURN NIL


METHOD Compile() CLASS gTextEditor

   LOCAL cCompiler := oStyle:CompileFile()
   LOCAL cFlags   := oStyle:CompileFlags()
   LOCAL cNoExtensionFileName
   LOCAL cCompilation

   IF Empty( AllTrim( cCompiler ) )
      MsgBox( "No compiler selected!", "GuiDes" )
   ELSE
      IF !File( cCompiler )
         MsgBox( "Cannot find compiler executable", "GuiDes" )
      ELSE
         IF ::HasChanged()
            IF MsgYesNo( ::FileName + " has changed" + CR_LF + "Do you want to save changes before compilation?" ;
                  + CR_LF + CR_LF + "(Compilation is done on the last saved version of the file)", "GuiDes" )
               ::Save( TRUE )
            ENDIF
         ENDIF
         cNoExtensionFileName := RemoveExtension( ::FileName )
         cCompilation := cCompiler + " " + cNoExtensionFileName + " " + AllTrim( cFlags )
         EXECUTE FILE cCompilation WAIT
         MsgBox( "Compilation finished", "GuiDes" )
      ENDIF
   ENDIF

RETURN NIL


METHOD HasChanged() CLASS gTextEditor

   LOCAL FinalText := TextFileWin .Texto. Value

RETURN !( FinalText == ::TEXT )


METHOD GetFileName() CLASS gTextEditor

   LOCAL acFilter := { { "Harbour source files (*.prg)", "*.PRG" }, ;
      { "Guides files (*.frm)", "*.FRM" }, ;
      { "ASCII files (*.txt)", "*.TXT" }, ;
      { "All files (*.*)", "*.*" } }

   LOCAL cFileName

   cFileName := GetFile( acFilter, , oStyle:ProjectDir() )

RETURN cFileName


METHOD GetFileText() CLASS gTextEditor

   LOCAL cText := ""

   IF !Empty( ::FileName )
      IF File( ::FileName )
         cText := MemoRead( ::FileName )
      ELSE
         MsgBox( "ERROR! File " + CR_LF + ::FileName + CR_LF + "not found!", "GuiDes" )
      ENDIF
   ENDIF

RETURN cText


METHOD Open() CLASS gTextEditor

   LOCAL cFileName := ::GetFileName()

   IF !Empty( cFileName )
      ::Save( FALSE )
      ::FileName := cFileName
      ::TEXT := ::GetFileText()
      TextFileWin.Title := "GuiDes Text Editor: " + cFileName
      TextFileWin .Texto. Value := ::Text
   ENDIF

RETURN NIL


STATIC FUNCTION GetToolBarHeight()

   LOCAL h := TextFileWin.ToolBar1.Handle

RETURN ( LoWord( GetSizeToolBar( h ) ) + 2 * GetBorderHeight() )
