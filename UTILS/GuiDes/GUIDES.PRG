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
#include "Set.ch"

DECLARE WINDOW Prefer
DECLARE WINDOW Main

FUNCTION Main()

   PRIVATE oEnvir, oProps, oStyle
   PRIVATE oLayout
   PRIVATE GuiDesDir := GetCurrentFolder()

   oLayout := gLayout():New()
   oLayout:LoadFromIni()

   MainWindow()

   SET HELPFILE TO GuidesDir + '\GUIDES.HLP'

   OIWin( oLayout )
   PrefBar()
   ProgresWindow()

   oEnvir := gEnvir():New()
   oProps := gProps():New()
   oStyle := gStyle():New()

   IF File( GuiDesDir + "\SAMPLE.DBF" )
      USE SAMPLE.DBF ALIAS SAMPDB SHARED NEW
   ENDIF

   Main.Maximize

   ACTIVATE WINDOW Main, OIWin, Prefer, WinSelec, PropInspector, ProgresWin

RETURN NIL


FUNCTION MainWindow()

   DEFINE WINDOW Main AT 0, 0 WIDTH 1000 HEIGHT 600 ;
      TITLE "GuiDes - MiniGUI Visual Form Designer (Release " + G_RELEASE + ")" ;
      ICON "AGUIDES" ;
      MAIN ;
      ON INIT InitProc() ;
      ON RELEASE ExitProc()

   MainMenu()

   DEFINE STATUSBAR FONT "Arial" SIZE 10

   STATUSITEM "" WIDTH 100 ACTION TogglePrefBar( 1 )

   STATUSITEM "" WIDTH 40 ACTION ToggleWinSelec()  ICON "WINDOWS"       TOOLTIP "Window Selector"
   STATUSITEM "" WIDTH 40 ACTION ToggleOIWin()     ICON "WINDOW"        TOOLTIP "Control Selector"
   STATUSITEM "" WIDTH 40 ACTION ToggleOPWin()     ICON "ELEMENTS"      TOOLTIP "Properties Inspector"
   STATUSITEM "" WIDTH 40 ACTION TogglePrefBar()   ICON "PERSONAL"      TOOLTIP "Preferences"

   END STATUSBAR

   DEFINE SPLITBOX

   DEFINE TOOLBAR ToolBar1 BUTTONSIZE 80, 40 FONT "ARIAL" SIZE 8 FLAT

   BUTTON tbNewWin ;
      CAPTION 'New Window' ;
      PICTURE 'NEWWIN' ;
      ACTION gWindow():New()

   BUTTON tbLoadWin ;
      CAPTION 'Open Window' ;
      PICTURE 'LOADWIN' ;
      ACTION gWindow():Load()

   BUTTON tbSaveWin ;
      CAPTION 'Save Window' ;
      PICTURE 'SAVE' ;
      ACTION oEnvir:SaveWindow()

   BUTTON tbInspect ;
      CAPTION 'View File' ;
      PICTURE 'INSPECT' ;
      ACTION gTextEditor():New() ;

      BUTTON tbEdit ;
      CAPTION 'Edit file' ;
      PICTURE 'EDITOR' ;
      ACTION gTextEditor():New( , FALSE ) ;
      SEPARATOR

   BUTTON tbMove ;
      CAPTION 'Move Controls' ;
      PICTURE 'MOVE' ;
      CHECK

   BUTTON tbDelete ;
      CAPTION "Delete Control" ;
      PICTURE "DELETE" ;
      ACTION {|| IF( oEnvir:AnyWindow(), oEnvir:Act_Window():DelControl(), NIL )  }

   BUTTON tDuplicate ;
      CAPTION "Clone Control" ;
      PICTURE "DUPLICAT" ;
      ACTION oEnvir:DuplicateControl() ;
      SEPARATOR

   BUTTON tDatabase ;
      CAPTION "Database fields" ;
      PICTURE "DB" ;
      ACTION {|| IF( oEnvir:AnyWindow(), gDBFTool():New( oEnvir:Act_Window() ), NIL )  }

   END TOOLBAR

   ToolWin()

   END SPLITBOX

   END WINDOW

RETURN NIL


FUNCTION ColorToCode( aColor )

   LOCAL cCode := "{ "

   cCode += AllTrim( Str( aColor[ 1 ] ) ) + " , "
   cCode += AllTrim( Str( aColor[ 2 ] ) ) + " , "
   cCode += AllTrim( Str( aCOlor[ 3 ] ) ) + " }"

RETURN cCode


FUNCTION TitleWindow()

   DEFINE WINDOW TitleWin AT 0, 0 ;
      WIDTH 445 HEIGHT 240 ;
      TITLE "GuiDes - MiniGUI Visual Form Designer" ;
      MODAL ;
      NOSIZE ;
      NOSYSMENU ;
      FONT "ARIAL" SIZE 10 ;
      BACKCOLOR WHITE

   @5, 5 IMAGE TitImage OF TitleWin PICTURE "GUIDES" ;
      WIDTH 435 HEIGHT 135;

      @155, 10 LABEL L1 ;
      VALUE "GuiDes release " + G_RELEASE ;
      WIDTH 435 HEIGHT 15;
      BACKCOLOR WHITE

   @170, 10 LABEL L2 ;
      VALUE "COPYRIGHT 2003,2004 Carlos Andrés <carlos.andres@navegalia.com>" ;
      WIDTH 435 HEIGHT 15;
      BACKCOLOR WHITE

   @185, 10 LABEL L3 ;
      VALUE "This software is released under the General Public License" ;
      WIDTH 435 HEIGHT 15;
      BACKCOLOR WHITE

   DEFINE TIMER Timer_1 INTERVAL 2000 ACTION _ReleaseWindow( "TitleWin" )

   END WINDOW

   CENTER WINDOW TitleWin
   ACTIVATE WINDOW TitleWin

RETURN NIL


FUNCTION TogglePrefBar( nShowGridTab )

   IF Main.ShowPrefer.Checked
      Main.ShowPrefer.Checked := FALSE
      HIDE WINDOW Prefer
   ELSE
      Main.ShowPrefer.Checked := TRUE
      IF !Empty( nShowGridTab )
         Prefer.PrefTab.Value := 3
      ENDIF
      SHOW WINDOW Prefer
   ENDIF

RETURN NIL


FUNCTION ToggleOIWin()

   IF Main.ShowOI.Checked
      Main.ShowOI.Checked := FALSE
      HIDE WINDOW OIWin
   ELSE
      Main.ShowOI.Checked := TRUE
      SHOW WINDOW OIWin
   ENDIF

RETURN NIL


FUNCTION ToggleOPWin()

   IF Main.ShowOP.Checked
      Main.ShowOP.Checked := FALSE
      HIDE WINDOW PropInspector
   ELSE
      Main.ShowOP.Checked := TRUE
      SHOW WINDOW PropInspector
   ENDIF

RETURN NIL



FUNCTION ToggleWinSelec()

   IF Main.ShowWS.Checked
      Main.ShowWS.Checked := FALSE
      HIDE WINDOW WinSelec
   ELSE
      Main.ShowWS.Checked := TRUE
      SHOW WINDOW WinSelec
   ENDIF

RETURN NIL


FUNCTION InitProc()

   TitleWindow()
   Main.ShowOI.Checked := TRUE
   Main.ShowOP.Checked := TRUE
   Main.ShowWS.Checked := TRUE

RETURN NIL


FUNCTION LeaveProgram()
   Main.Release

RETURN NIL


FUNCTION OIWin( oLayout )

   LOCAL nBarHeight := 30 + 2 * GetBorderHeight()
   LOCAL nMarginWidth := 2 * GetBorderWidth()

   DEFINE WINDOW OIWin AT oLayout:OSRow, oLayout:OSCol ;
      WIDTH oLayout:OSWidth HEIGHT oLayout:OSHeight ;
      TITLE "Control Selector" ;
      ICON "ELEMENTS" ;
      CHILD ;
      NOMINIMIZE ;
      NOMAXIMIZE ;
      NOSYSMENU ;
      FONT "ARIAL" SIZE 8

   DEFINE SPLITBOX

   GRID OIGrid WIDTH ( oLayout:OSWidth - nMarginWidth ) ;
      HEIGHT ( oLayout:OSHeight - nBarHeight ) ;
      HEADERS { 'Control', 'Type', 'Id' } ;
      WIDTHS { 100, 100, 100 } ITEMS {} ;
      ON CHANGE {|| oEnvir:ChangeToControl( This.Value ) }

   END SPLITBOX

   END WINDOW

   DEFINE WINDOW PropInspector AT oLayout:PIRow, oLayout:PICol ;
      WIDTH oLayout:PIWidth HEIGHT oLayout:PIHeight ;
      TITLE "Properties Inspector"  ;
      ICON "AGUIDES" ;
      CHILD ;
      NOMINIMIZE ;
      NOMAXIMIZE ;
      NOSYSMENU ;
      FONT "ARIAL" SIZE 8

   DEFINE SPLITBOX

   GRID PropGrid WIDTH ( oLayout:PIWidth - nMarginWidth ) ;
      HEIGHT ( oLayout:PIHeight - nBarHeight ) ;
      HEADERS { 'Property / Event', 'Value' } ;
      WIDTHS { 100, 100 } ITEMS {} ;
      ON DBLCLICK oProps:EditProperty()

   END SPLITBOX

   END WINDOW


   DEFINE WINDOW WinSelec AT oLayout:WSRow, oLayout:WSCol ;
      WIDTH oLayout:WSWidth HEIGHT oLayout:WSHeight ;
      TITLE "Window Selector"  ;
      ICON "WINDOW" ;
      CHILD ;
      NOMINIMIZE ;
      NOMAXIMIZE ;
      NOSYSMENU ;
      FONT "ARIAL" SIZE 8

   DEFINE SPLITBOX

   GRID WSGrid WIDTH ( oLayout:WSWidth - nMarginWidth ) ;
      HEIGHT ( oLayout:WSHeight - nBarHeight ) ;
      HEADERS { 'Window', 'Mode', 'Id' } ;
      WIDTHS { 80, 80, 80 } ITEMS {} ;
      ON CHANGE {|| iif( This.Value <> 0, oEnvir:ChangeToWindow( This.Value ), NIL ) }

   END SPLITBOX

   END WINDOW

RETURN NIL


FUNCTION PrefBar()

   DEFINE WINDOW Prefer AT 40, 235 WIDTH 550 HEIGHT 300 ;
      TITLE "Preferences"  ;
      ICON "AGUIDES" ;
      CHILD ;
      NOSHOW ;
      NOAUTORELEASE ;
      NOMINIMIZE ;
      NOMAXIMIZE ;
      ON INIT SetGridState() ;
      FONT "ARIAL" SIZE 8

   DEFINE MAIN MENU OF Prefer
      POPUP "&Style"
      ITEM "&Load Style"  ACTION {|| oStyle:LoadStyle() }
      ITEM "&Save Style"  ACTION {|| oStyle:SaveStyle() }
      END POPUP
   END MENU

   @ 10, 20 LABEL tbL20 VALUE "Last loaded style:" WIDTH 100 HEIGHT 15

   @ 10, 120 LABEL tbLastLoaded WIDTH 330 HEIGHT 15 BACKCOLOR G_LIGHTGREY

   DEFINE TAB PrefTab OF Prefer AT 50, 10 WIDTH 520 HEIGHT 180

   PAGE "Controls Default Sizes"

   @ 40, 10 FRAME tbFr1 CAPTION "Smaller controls" WIDTH 300 HEIGHT 45

   @ 58, 20 LABEL tbL4 VALUE "WIDTH:" WIDTH 40 HEIGHT 20
   @ 55, 70 SPINNER tbWidth RANGE 0, 2000 WIDTH 60 HEIGHT 20
   @ 58, 150 LABEL tbL5 VALUE "HEIGHT:" WIDTH 50 HEIGHT 20
   @ 55, 200 SPINNER tbHeight RANGE 0, 2000 WIDTH 60 HEIGHT 20

   @ 95, 10 FRAME tbFr2 CAPTION "Bigger controls" WIDTH 300 HEIGHT 45

   @ 113, 20 LABEL tbL7 VALUE "WIDTH:" WIDTH 40 HEIGHT 20
   @ 110, 70 SPINNER tbBigWidth RANGE 0, 2000 WIDTH 60  HEIGHT 20
   @ 113, 150 LABEL tbL8 VALUE "HEIGHT:" WIDTH 50 HEIGHT 20
   @ 110, 200 SPINNER tbBigHeight RANGE 0, 2000 WIDTH 60  HEIGHT 20

   @ 50, 330 CHECKBOX tbAutoSize ;
      CAPTION "Use AUTOSIZE when available" ;
      WIDTH 180 HEIGHT 20 ;
      VALUE FALSE

   END PAGE

   PAGE "Controls Font And Color"

   @ 40, 10 LABEL tbL9 VALUE "FONT:" WIDTH 35 HEIGHT 20 BOLD
   @ 40, 45 LABEL tbFont ;
      ACTION {|| oStyle:ChooseFont() } ;
      WIDTH 400 HEIGHT 15 BACKCOLOR WHITE ;
      TOOLTIP "Choose Default Font Style"

   @ 70, 10 LABEL tbL10 VALUE "BACKCOLOR:" WIDTH 100 HEIGHT 20
   @ 70, 100 LABEL tbBGCol ;
      ACTION {|| oStyle:ChooseBackColor() } ;
      WIDTH 150 HEIGHT 15  BACKCOLOR WHITE ;
      TOOLTIP "Choose Default Back Color"

   @ 100, 10 LABEL tbL11 VALUE "FONTCOLOR:" WIDTH 100 HEIGHT 20
   @ 100, 100 LABEL tbFontCol ;
      ACTION {|| oStyle:ChooseFontColor() } ;
      WIDTH 150 HEIGHT 15 BACKCOLOR WHITE ;
      TOOLTIP "Choose Default Font Color"

   END PAGE

   PAGE "Grid"

   @ 40, 20 CHECKBOX PrefGrid ;
      CAPTION "COERCE TO GRID" ;
      WIDTH 120 HEIGHT 20 ;
      VALUE FALSE ;
      ON CHANGE SetGridState()

   @ 70, 10 FRAME tbFr40 CAPTION "Grid spacing" WIDTH 300 HEIGHT 45

   @ 88, 20 LABEL tbL1 VALUE "X SPACING:" WIDTH 60 HEIGHT 20
   @ 85, 90 SPINNER tbX RANGE 1, 1000 WIDTH 50 HEIGHT 20 ON CHANGE SetGridState()

   @ 88, 150 LABEL tbL2 VALUE "Y SPACING:" WIDTH 100 HEIGHT 20
   @ 85, 230 SPINNER tbY RANGE 1, 1000 WIDTH 50 HEIGHT 20 ON CHANGE SetGridState()

   END PAGE


   PAGE "Windows default"

   @ 50, 10 LABEL tbL30 VALUE "BACKCOLOR:";
      WIDTH 100 HEIGHT 20

   @ 50, 100 LABEL tbLWBGColor ;
      ACTION {|| oStyle:ChooseWinBackColor() } ;
      WIDTH 150 HEIGHT 15 BACKCOLOR WHITE ;
      TOOLTIP "Choose Default Window BackColor"

   @ 90, 10 FRAME tbFr3 CAPTION "Default size" WIDTH 300 HEIGHT 45

   @ 110, 20 LABEL tbL41 VALUE "WIDTH:" WIDTH 40 HEIGHT 20
   @ 105, 70 SPINNER tbWinWidth RANGE 0, 2000 WIDTH 60 HEIGHT 20
   @ 110, 150 LABEL tbL42 VALUE "HEIGHT:" WIDTH 50 HEIGHT 20
   @ 105, 200 SPINNER tbWinHeight RANGE 0, 2000 WIDTH 60 HEIGHT 20

   END PAGE


   PAGE "Code / Output"

   @ 35, 10 CHECKBOX tbInclude ;
      CAPTION "Add parent window 'OF' in control definition" ;
      WIDTH 300 HEIGHT 20 ;
      VALUE FALSE

   @ 65, 10 CHECKBOX tbFullCode ;
      CAPTION "Full code (Add #include, #define and FUNCTION)" ;
      WIDTH 300 HEIGHT 20 ;
      VALUE FALSE

   @ 95, 10 CHECKBOX tbExportDBCode ;
      CAPTION "Export Database Code (Refresh and Save functions)" ;
      WIDTH 300 HEIGHT 20 ;
      VALUE FALSE

   @ 125, 10 CHECKBOX tbUseWindowFont ;
      CAPTION "Omit Controls Font Clauses when same as Parent Window Font" ;
      WIDTH 350 HEIGHT 20 ;
      VALUE FALSE

   @ 35, 320 LABEL tbL540 VALUE "Tab Spaces:" WIDTH 70 HEIGHT 20

   @ 35, 400 SPINNER tbCodeTab RANGE 1, 100 WIDTH 60 HEIGHT 20

   END PAGE

   PAGE "GuiDes"

   @ 35, 10 LABEL tbL12 VALUE "Project folder:" ;
      WIDTH 100 HEIGHT 15

   @ 35, 90 LABEL tbFolder ;
      ACTION {|| oStyle:ChooseProjectDir() } ;
      WIDTH 320 HEIGHT 15 BACKCOLOR WHITE ;
      TOOLTIP "Choose Suggested Folder for file operations"

   @ 65, 10 CHECKBOX tbWinProps ;
      CAPTION "Open 'Window Properties' on Window Creation" ;
      WIDTH 300 HEIGHT 20 ;
      VALUE FALSE

   @ 95, 10 CHECKBOX tbAutoInspect ;
      CAPTION "Automatically show generated MiniGUI code" ;
      WIDTH 300 HEIGHT 20 ;
      VALUE FALSE

   @ 125, 10 CHECKBOX tbAddMoveButtons ;
      CAPTION "On 'Add DB fields' operation, create move-through-database buttons" ;
      WIDTH 350 HEIGHT 20 ;
      VALUE FALSE

   END PAGE


   PAGE "Compilation"

   @ 35, 10 LABEL tbLCompile VALUE "Compiler:" ;
      WIDTH 100 HEIGHT 15

   @ 35, 110 LABEL tbCompileFile ;
      ACTION {|| oStyle:ChooseCompileFile() } ;
      WIDTH 320 HEIGHT 15 BACKCOLOR WHITE ;
      TOOLTIP "Choose MiniGUI Compiler (e.g. COMPILE.BAT)"

   @ 95, 10 LABEL tbLCompFlags VALUE "Compilation flags:" ;
      WIDTH 100 HEIGHT 15

   @ 95, 110 TEXTBOX tbCompileFlags ;
      HEIGHT 20 WIDTH 100

   END PAGE


   END TAB

   END WINDOW

   CENTER WINDOW Prefer

RETURN NIL


FUNCTION CastToChar( xValue )

   LOCAL cType := ValType( xValue )

   IF ( xValue == NIL )
      RETURN ""
   ELSEIF ( cType == "C" )
      RETURN AllTrim( xValue )
   ELSEIF ( cType == "N" )
      RETURN AllTrim( Str( xValue ) )
   ELSEIF ( cType == "L" )
      RETURN iif( xValue, "TRUE", "FALSE" )
   ELSEIF ( cType == "D" )
      RETURN DToC( xValue )
   ELSEIF ( cType == "A" )
      RETURN ArrayToChar( xValue )
   ENDIF

RETURN ( "DATATYPE = " + ValType( xValue ) )


FUNCTION ArrayToChar( aArray )

   LOCAL nCount
   LOCAL cString := "{ "

   FOR nCount := 1 TO Len( aArray )
// cString += "'" + CastToChar( aArray[ nCount ] ) + "'"
      cString += CastToChar( aArray[ nCount ] )

      IF !( nCount == Len( aArray ) )
         cString += " , "
      ENDIF
   NEXT

   cString += " }"

RETURN cString


FUNCTION ChangeFont( aOldFont )         // This is an interface for GetFont()

   LOCAL aFont := GetFont( aOldFont[ 1 ], aOldFont[ 2 ], aOldFont[ 3 ], aOldFont[ 4 ], aOldFont[ 5 ], aOldFont[ 6 ], aOldFont[ 7 ], aOldFont[ 8 ] )  // GF

   IF !Empty( aFont[ 1 ] )
      aOldFont[ 1 ]  := aFont[ 1 ]
   ENDIF

   IF !Empty( aFont[ 2 ] )
      aOldFont[ 2 ]  := aFont[ 2 ]
   ENDIF

   IF !Empty( aFont[ 1 ] ) .AND. !Empty( aFont[ 2 ] )
      aOldFont[ 3 ]  := aFont[ 3 ]
      aOldFont[ 4 ]  := aFont[ 4 ]
      aOldFont[ 5 ]  := aFont[ 5 ]
      aOldFont[ 6 ]  := aFont[ 6 ]
      aOldFont[ 7 ]  := aFont[ 7 ]
      aOldFont[ 8 ]  := aFont[ 8 ]
   ENDIF

RETURN aOldFont


FUNCTION ToolWin()

   DEFINE TOOLBAR Tools BUTTONSIZE 24, 25 FONT "ARIAL" SIZE 8 FLAT

   BUTTON tbButton ;
      TOOLTIP "Button" ;
      PICTURE "BOTON" ;
      ACTION gButton():New() ;

   BUTTON tbCheckButton ;
      TOOLTIP "Checkbutton" ;
      PICTURE "CHECKBUT" ;
      ACTION gCheckButton():New() ;

      BUTTON tbLabel ;
      TOOLTIP "Label" ;
      PICTURE "LABEL" ;
      ACTION gLabel():New()

   BUTTON tbTextBox ;
      TOOLTIP "Textbox" ;
      PICTURE "TEXTBOX" ;
      ACTION gTextbox():New()

   BUTTON tbCheckBox ;
      TOOLTIP "Checkbox" ;
      PICTURE "CHECKBOX" ;
      ACTION gCheckbox():New()

   BUTTON tbComboBox ;
      TOOLTIP "Combobox" ;
      PICTURE "COMBOBOX" ;
      ACTION gCombobox():New()

   BUTTON tbDatePicker ;
      TOOLTIP "Datepicker" ;
      PICTURE "DATEPICK" ;
      ACTION gDatePicker():New()

   BUTTON tbEditBox ;
      TOOLTIP "Editbox" ;
      PICTURE "EDITBOX" ;
      ACTION gEditBox():New()

   BUTTON tbSpinner ;
      TOOLTIP "Spinner" ;
      PICTURE "SPINNER" ;
      ACTION gSpinner():New()

   BUTTON tb1 ;
      TOOLTIP "Listbox" ;
      PICTURE "LISTBOX" ;
      ACTION gListBox():New()

   BUTTON tb2 ;
      TOOLTIP "Progressbar" ;
      PICTURE "PROGRESS" ;
      ACTION gProgressBar():New()

   BUTTON tb3 ;
      TOOLTIP "Player" ;
      PICTURE "PLAYER" ;
      ACTION gPlayer():New()

   BUTTON tb4 ;
      TOOLTIP "Radiogroup" ;
      PICTURE "RADIO" ;
      ACTION gRadioGroup():New()

   BUTTON tb5 ;
      TOOLTIP "Slider" ;
      PICTURE "SLIDER" ;
      ACTION gSlider():New()

   BUTTON tb6 ;
      TOOLTIP "Tab" ;
      PICTURE "TAB" ;
      ACTION gTab():New()

   BUTTON tbPanel ;
      TOOLTIP "Animatebox" ;
      PICTURE "ANIMATE" ;
      ACTION gAnimateBox():New()

   BUTTON tbGrid ;
      TOOLTIP "Grid" ;
      PICTURE "GRID" ;
      ACTION gGrid():New()

   BUTTON tbBrowse ;
      TOOLTIP "Browse" ;
      PICTURE "BROWSE" ;
      ACTION gBrowse():New()

   BUTTON tbFrame ;
      TOOLTIP "Frame" ;
      PICTURE "FRAME" ;
      ACTION gFrame():New()

   BUTTON tbiMAGE ;
      TOOLTIP "Image" ;
      PICTURE "IMAGE" ;
      ACTION gImage():New()

   BUTTON tbMonthC ;
      TOOLTIP "MonthCalendar" ;
      PICTURE "MONTHCAL" ;
      ACTION gMonthCalendar():New()

   BUTTON tbIpAddress ;
      TOOLTIP "IpAddress" ;
      PICTURE "IPADDR" ;
      ACTION gIpAddress():New()

   BUTTON tbTree ;
      TOOLTIP "Tree" ;
      PICTURE "TREE" ;
      ACTION gTree():New()

   BUTTON tbHyper ;
      TOOLTIP "Hyperlink" ;
      PICTURE "HYPER" ;
      ACTION gHyperLink():New()

   BUTTON tbTimer ;
      TOOLTIP "Timer" ;
      PICTURE "CLOCK" ;
      ACTION gTimer():New() ;
      SEPARATOR

   BUTTON tbPrintLabel ;
      TOOLTIP "PrintLabel" ;
      PICTURE "PRINT" ;
      ACTION gPrint():New()

   END TOOLBAR

RETURN NIL


FUNCTION ProgresWindow()

   DEFINE WINDOW ProgresWin ;
      AT 50, 250 ;
      WIDTH 330 ;
      HEIGHT 90 ;
      TITLE 'Progress' ;
      ICON 'AGUIDES' ;
      CHILD ;
      NOSHOW ;
      TOPMOST ;
      NOSIZE ;
      NOSYSMENU

   @ 10, 10 PROGRESSBAR PBar ;
      OF Win_2 ;
      RANGE 0, 100 ;
      WIDTH 300 ;
      HEIGHT 20

   END WINDOW

   CENTER WINDOW ProgresWin

RETURN NIL


FUNCTION Progres( nPercent, cLabelText )

   LOCAL nIntPercent := Int( nPercent )

   IF !Empty( cLabelText )
      ProgresWin.Title := cLabelText
   ENDIF

   IF ( nIntPercent == 0 )
      SHOW WINDOW ProgresWin
   ELSEIF ( nIntPercent == 100 )
      HIDE WINDOW ProgresWin
   ELSE
      ProgresWin.PBar.Value := nIntPercent
   ENDIF

RETURN NIL


FUNCTION ForceExt( cFileName, cFileExt )
   cFileExt := AllTrim( Upper( cFileExt ) )

   IF Right( AllTrim( Upper( cFileName ) ), Len( cFileExt )  ) != cFileExt
      cFileName += cFileExt
   ENDIF

RETURN cFileName


FUNCTION PropEditWin( xValue, cPropName, cControlName, cWindowName )

   LOCAL cValtype := ValType( xValue )

   DEFINE WINDOW EditBar ;
      AT 50, 250 ;
      WIDTH 360 ;
      HEIGHT 280 ;
      TITLE 'Property Edition: '  + cPropName ;
      MODAL ;
      NOSYSMENU ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 10, 20 LABEL l1 ;
      VALUE 'Window: ' + cWindowName;
      WIDTH 200 ;
      HEIGHT 20.00

      @ 30, 20 LABEL l2 ;
      VALUE 'Control: ' + cControlName ;
      WIDTH 200 ;
      HEIGHT 20.00

      DO CASE
      CASE ( cValtype == "N" )

      @ 60, 20 SPINNER NSpinner ;
         RANGE 0, 10000 ;
         VALUE xValue ;
         WIDTH 80 HEIGHT 20;
         FONT 'Courier New' ;
         SIZE 10

      CASE ( cValtype == "C" )

      @ 60, 10 EDITBOX cEditBox ;
         WIDTH 320 ;
         HEIGHT 100 ;
         VALUE xValue ;
         FONT 'Courier New' ;
         SIZE 10

      ENDCASE

   @ 200, 40 BUTTON ApplyButton ;
      CAPTION 'Apply' ;
      ACTION {|| oProps:ApplyProperty( TRUE ) } ;
      WIDTH 100 ;
      HEIGHT 30

   @ 200, 160 BUTTON DiscardButton ;
      CAPTION 'Discard' ;
      ACTION {|| oProps:ApplyProperty( FALSE ) } ;
      WIDTH 100 ;
      HEIGHT 30

   END WINDOW

   CENTER WINDOW EditBar
   ACTIVATE WINDOW EditBar

RETURN NIL

/*
FUNCTION Load_Win_Error( x )
   MsgBox( "Error happened while loading window.", "Guides" )

RETURN FALSE
*/


FUNCTION ExitProc()

   dbCloseAll()
   oLayout:SaveToIni()

RETURN NIL


FUNCTION Inspecciona()

   LOCAL cMessage := ""
   LOCAL nCount

   FOR nCount := 1 TO 10
      cMessage += ProcName( nCount ) + " - " + Str( ProcLine( nCOunt ) ) + CR_LF
   NEXT
   MsgBox( cMessage )

RETURN NIL


FUNCTION SetGridState()

   LOCAL lGrid, nXSpac, nYSpac, cText

   IF IsWindowActive( Prefer )
      lGrid := Prefer.PrefGrid.Value

      nXSpac := Prefer.tbX.Value
      nYSpac := Prefer.tbY.Value

      IF lGrid
         cText := "GRID: (" + AllTrim( Str( nXSpac ) ) + " , " + AllTrim( Str( nYSpac ) ) + ")"
      ELSE
         cText := "NO GRID"
      ENDIF

      Main.Statusbar. Item( 1 ) := cText

   ENDIF

RETURN NIL


FUNCTION CreateSampDB()

   LOCAL aStruc := {}

   AAdd( aStruc, { "FIRST_NAME", "C", 20, 0 } )
   AAdd( aStruc, { "FAMILY_NAM", "C", 20, 0 } )

   dbCreate( GuiDesDir + "\SAMPLE.DBF", aStruc )

   USE ( GuidesDir + "\SAMPLE.DBF" )
   dbAppend()
   FIELD->FIRST_NAME := "John"
   FIELD->FAMILY_NAM := "Lennon"
   dbAppend()
   FIELD->FIRST_NAME := "Paul"
   FIELD->FAMILY_NAM := "McCartney"
   dbAppend()
   FIELD->FIRST_NAME := "George"
   FIELD->FAMILY_NAM := "Harrison"
   dbAppend()
   FIELD->FIRST_NAME := "Ringo"
   FIELD->FAMILY_NAM := "Starr"
   dbCloseAll()

RETURN NIL


FUNCTION SplitPath( cFullPath )

   LOCAL nPos
   LOCAL cFileName := ""
   LOCAL cDirectory := ""

   IF ( nPos := RAt( "\", cFullPath ) ) != 0
      cFileName  := Right( cFullPath, Len( cFullPath ) - nPos  )
      cDirectory := SubStr( cFullPath, 1, nPos - 1 )
   ENDIF

RETURN { cFileName, cDirectory }


FUNCTION RemoveExtension( cFullFileName )

   LOCAL nPos
   LOCAL cFileName := ""

   IF ( nPos := RAt( ".", cFullFileName ) ) != 0
      cFileName := SubStr( cFullFileName, 1, nPos - 1 )
   ENDIF

RETURN cFileName


FUNCTION MainMenu()

   LOCAL nCount
   LOCAL cFileName
   LOCAL cName

   IF IsWindowDefined( Main )

      DEFINE MAIN MENU OF Main
      POPUP "&File"
      ITEM "&New Window"  ACTION {|| gWindow():New() }
      ITEM "&Open Window" ACTION {|| gWindow():Load() }
      ITEM "&Save Window" ACTION {|| oEnvir:SaveWindow() }
      SEPARATOR
      ITEM "&View file" ACTION {|| gTextEditor():New() }
      ITEM "&Edit file"    ACTION {|| gTextEditor():New( , FALSE ) }
      SEPARATOR

      IF Empty( oLayout:RecentWindows )
         ITEM "(No recently saved windows)"
      ELSE
         FOR nCount := 1 TO Len( oLayout:RecentWindows )
            cFileName := oLayout:RecentWindows[ nCount ]
            cName := AllTrim( Str( nCount ) )
            ITEM cFileName ACTION LoadRecent() NAME &( cName )
         NEXT

      ENDIF

      SEPARATOR
      ITEM "E&xit" ACTION {|| LeaveProgram() }
      END POPUP

      POPUP "&View"
      ITEM "&Control Selector" ACTION ToggleOIWin() NAME ShowOI
      ITEM "&Window Selector" ACTION ToggleWinSelec() NAME ShowWS
      ITEM "&Properties Inspector" ACTION ToggleOPWin() NAME ShowOP
      ITEM "Pr&eferences" ACTION TogglePrefBar() NAME ShowPrefer
      SEPARATOR
      ITEM "&Minimize All Windows" ACTION oEnvir:MinimizeWindows()
      ITEM "&Restore All Windows" ACTION oEnvir:RestoreWindows()
      ITEM "&Release All Windows" ACTION oEnvir:CloseAllWindows()
      END POPUP

      POPUP "&Help"
      ITEM "&Show Help"  ACTION DISPLAY HELP MAIN
      ITEM "&About" ACTION TitleWindow() NAME ShowAbout
      END POPUP

      END MENU

   ENDIF

RETURN NIL


FUNCTION LoadRecent()

   LOCAL cName := This.Name
   LOCAL nPos := Val( cName )

   gWindow():Load( oLayout:RecentWindows[ nPos ] )

RETURN NIL
