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

#include "minigui.ch"
#include "GUIDES.CH"
#include "hbclass.ch"

DECLARE WINDOW OIWin
DECLARE WINDOW Tools
DECLARE WINDOW WinProp
DECLARE WINDOW Prefer
DECLARE WINDOW WinSelec
DECLARE WINDOW Main

CREATE CLASS gWindow

   DATA Changed         INIT FALSE     // Has window changed since it was saved?
   DATA OK              INIT TRUE
   DATA Handler
   DATA Name            INIT ""
   DATA ID              INIT ""
   DATA Row             INIT 0
   DATA Col             INIT 0
   DATA Width           INIT 300
   DATA Height          INIT 300
   DATA Title           INIT ""

   DATA OnInit          INIT ""
   DATA OnRelease       INIT ""
   DATA OnMouseClick    INIT ""
   DATA OnMouseDrag     INIT ""
   DATA OnMouseMove     INIT ""
   DATA OnSize          INIT ""
   DATA OnPaint         INIT ""

   DATA OnNotifyClick   INIT ""
   DATA OnGotfocus      INIT ""
   DATA OnLostFocus     INIT ""
   DATA OnScrollup      INIT ""
   DATA OnScrolldown    INIT ""
   DATA OnScrollLeft    INIT ""
   DATA OnScrollRight   INIT ""
   DATA OnHScrollBox    INIT ""
   DATA OnVScrollBox    INIT ""

   DATA nMainMode       INIT 1

   DATA AllowResize     INIT TRUE
   DATA BackColor       INIT G_GREY
   DATA lIcon           INIT FALSE
   DATA IconName        INIT "(Icon Name)"
   DATA lSysMenu        INIT FALSE
   DATA lCaption        INIT FALSE
   DATA lNoShow         INIT FALSE
   DATA lTopMost        INIT FALSE
   DATA lAllowMaximize  INIT TRUE
   DATA lAllowMinimize  INIT TRUE

   DATA Controls        INIT {}
   DATA INDEX           INIT 0

   DATA WidNum          INIT 0

   DATA MainMenu        INIT NIL
   DATA ContextMenu     INIT NIL
   DATA NotifyMenu      INIT NIL

   DATA VirtualDim INIT FALSE
   DATA VWidth  INIT 0
   DATA VHeight  INIT 0
   DATA cSection  INIT ""

   DATA FileName   INIT ""
   DATA FilePath  INIT ""

   DATA Font            INIT G_FONT

   DATA PrintFontStyles  INIT {}
   DATA PrintResolution INIT 10

   CLASSDATA acModes  INIT { "MAIN", "CHILD", "MODAL", "SPLITCHILD", "PRINT_REPORT" }

   METHOD New()   CONSTRUCTOR
   METHOD Load( cFileName )  CONSTRUCTOR
   METHOD Define
   METHOD Kill
   METHOD CODE
   METHOD Output
   METHOD Properties
   METHOD EndProps
   METHOD BCSelec
   METHOD SAVE
   METHOD Click
   METHOD ToggleIconName
   METHOD ToggleOnModal
   METHOD ToggleVirtual
   METHOD AddControl
   METHOD DelControl
   METHOD RefreshProps()   INLINE       oProps:Subst( ::ActControl() )
   METHOD RefreshControlWin()
   METHOD ActControl()
   METHOD Activate()
   METHOD Resizing()
   METHOD SetChanged
   METHOD AddToList()
   METHOD UpdateHandle()      INLINE ( ::Handler := GetFormHandle( ::Name ) )
   METHOD SetFocus()          INLINE SetFocus( ::Handler )
   METHOD AnyControl()
   METHOD AddMainMenu
   METHOD AddContextMenu
   METHOD AddNotifyMenu
   METHOD SearchIndex( cControlName )
   METHOD LoadControl( TYPE )
   METHOD BecomeActiveWindow()

   METHOD UpdateWinSelec()
   METHOD ChangeToControl( xRefere )
   METHOD SetFontStyles()
   METHOD FontStylesCode( oCode )
   METHOD PrintableCode( oCode )
   METHOD UpdateStatusbar()

ENDCLASS


METHOD New() CLASS gWindow

   ::Name := oEnvir:NewWindowName()
   ::BackColor := oStyle:Win_BackColor
   ::Width     := oStyle:WinWidth()
   ::Height    := oStyle:WinHeight()
   ::FileName := ::Name
   ::FilePath := oStyle:ProjectDir

   IF oStyle:WinProps()
      ::Title := ::Name
      ::Id := ::Name
      ::Properties( TRUE )
   ENDIF

   IF ::Ok
      oEnvir:AddWindow( Self )

      IF Empty( ::Title )
         ::Title := ::Name
      ENDIF

      IF Empty( ::ID )
         ::ID        := ::Name
      ENDIF

      ::Define()
      ::AddToList()
      ::SetChanged( TRUE )
      ::Activate()
   ENDIF

RETURN Self


METHOD Load( cFileName ) CLASS gWindow

   LOCAL nControls := 0
   LOCAL cType := ""
   LOCAL nCount
   LOCAL aMainElems := {}
   LOCAL aContextElems := {}
   LOCAL aNotifyElems := {}
// LOCAL ErrBlock
   LOCAL acFilter := { { "Guides files (*.frm)", "*.FRM" }, ;
      { "ASCII files (*.txt)", "*.TXT" }, ;
      { "All files (*.*)", "*.*" } }
   LOCAL aAux
   LOCAL cVersion := ""
   LOCAL lProceed := TRUE

   IF Empty( cFileName )
      cFileName := GetFile( acFilter, , oStyle:ProjectDir() )
   ENDIF

   IF File( cFileName )

// ErrBlock := ERRORBLOCK( { |x| Load_Win_Error( x ) } )

      Progres( 0, "Loading window. Please wait..." )

      BEGIN INI FILE cFileName

      GET cVersion SECTION "GUIDES" ENTRY "VERSION"

      IF cVersion != G_RELEASE
         lProceed := MsgYesNo( cFileName + CR_LF + "was saved with a different version of GuiDes." + CR_LF ;
            + "If you continue to load it, GuiDes may crash." ;
            + CR_LF + "Are you sure you want to proceed?", "GuiDes" )
      ENDIF

      IF !lProceed
         RETURN NIL
      ENDIF

      oEnvir:AddWindow( Self )

      aAux := SplitPath( cFileName )
      ::FileName := aAux[ 1 ]
      ::FilePath := aAux[ 2 ]

      GET ::ID   SECTION "WINDOW" ENTRY "ID"

      GET ::Row SECTION "WINDOW" ENTRY "ROW"
      GET ::Col SECTION "WINDOW" ENTRY "COL"

      GET ::Width SECTION "WINDOW" ENTRY "WIDTH"
      GET ::Height SECTION "WINDOW" ENTRY "HEIGHT"
      GET ::Title SECTION "WINDOW" ENTRY "TITLE"
      GET ::lIcon SECTION "WINDOW" ENTRY "L_ICON"

      GET ::VirtualDim SECTION "WINDOW" ENTRY "VIRTUALDIM"
      GET ::VWidth SECTION "WINDOW" ENTRY "V_WIDTH"
      GET ::VHeight SECTION "WINDOW" ENTRY "V_HEIGHT"

      GET ::IconName SECTION "WINDOW" ENTRY "ICONNAME"
      GET ::nMainMode SECTION "WINDOW" ENTRY "MODE"
      GET ::lNoShow SECTION "WINDOW" ENTRY "NOSHOW"
      GET ::lTopMost SECTION "WINDOW" ENTRY "TOPMOST"
      GET ::lAllowMinimize SECTION "WINDOW" ENTRY "MINIMIZE"
      GET ::lAllowMaximize SECTION "WINDOW" ENTRY "MAXIMIZE"
      GET ::AllowResize SECTION "WINDOW" ENTRY "NOSIZE"
      GET ::lSysMenu SECTION "WINDOW" ENTRY "NOSYSMENU"
      GET ::lCaption SECTION "WINDOW" ENTRY "NOCAPTION"
      GET ::OnInit SECTION "WINDOW" ENTRY "ON INIT"

      GET ::OnRelease SECTION "WINDOW" ENTRY "ON RELEASE"
      GET ::OnMouseClick SECTION "WINDOW" ENTRY "ON MOUSECLICK"
      GET ::OnMouseDrag SECTION "WINDOW" ENTRY "ON MOUSEDRAG"
      GET ::OnInit SECTION "WINDOW" ENTRY "ON INIT"
      GET ::OnMouseMove   SECTION "WINDOW" ENTRY "ON MOUSEMOVE"
      GET ::OnSize SECTION "WINDOW" ENTRY "ON SIZE"
      GET ::OnPaint SECTION "WINDOW" ENTRY "ON PAINT"

      GET ::BackColor SECTION "WINDOW" ENTRY "BACKCOLOR"

      GET ::OnNotifyClick SECTION "WINDOW" ENTRY "ON NOTIFYCLICK"
      GET ::OnGotFocus SECTION "WINDOW" ENTRY "ON GOTFOCUS"
      GET ::OnLostFocus SECTION "WINDOW" ENTRY "ON LOSTFOCUS"
      GET ::OnScrollUp SECTION "WINDOW" ENTRY "ON SCROLLUP"
      GET ::OnScrollDown   SECTION "WINDOW" ENTRY "ON SCROLLDOWN"
      GET ::OnScrollLeft SECTION "WINDOW" ENTRY "ON SCROLLLEFT"
      GET ::OnScrollRight SECTION "WINDOW" ENTRY "ON SCROLLRIGHT"

      GET aMainElems SECTION "WINDOW" ENTRY "MAINMENU"
      IF !Empty( aMainElems )
         ::MainMenu := gMenu():New( G_MAINMENU )
         ::MainMenu:Elements := aMainElems
      ENDIF

      GET aNotifyElems SECTION "WINDOW" ENTRY "NOTIFYMENU"
      IF !Empty( aNotifyElems )
         ::NotifyMenu := gMenu():New( G_NOTIFYMENU )
         ::NotifyMenu:Elements := aNotifyElems
      ENDIF

      GET aContextElems SECTION "WINDOW" ENTRY "CONTEXTMENU"
      IF !Empty( aContextElems )
         ::ContextMenu := gMenu():New( G_CONTEXTMENU )
         ::ContextMenu:Elements := aContextElems
      ENDIF

      GET nControls SECTION "WINDOW" ENTRY "CONTROLS"

      Progres( 100 / ( nControls + 1 ) )

      ::Name := oEnvir:NewWindowName()
      ::Define()
      ::AddToList()
      ::BecomeActiveWindow()

      FOR nCount := 1 TO nControls
         ::cSection := "CONTROL_" + AllTrim( Str( nCount ) )
         GET cType SECTION ::cSection ENTRY "TYPE"
         ::LoadControl( cType )
         Progres( ( nCount + 1 ) * 100 / ( nControls + 1 ) )
      NEXT

      END INI
      Progres( 100 )

      ::Activate()

// ERRORBLOCK( ErrBlock )

   ENDIF

RETURN Self


METHOD Define() CLASS gWindow

   LOCAL aPos := oEnvir:NewWindowPos()
   LOCAL xx := aPos[ 1 ]
   LOCAL yy := aPos[ 2 ]

   DEFINE WINDOW &( ::Name ) AT xx, yy ;
      WIDTH ::Width HEIGHT ::Height ;
      TITLE ::Title ;
      ICON "GUIDES" ;
      CHILD ;
      ON RELEASE {|| ::Kill() } ;
      ON MOUSECLICK {|| ::Click() } ;
      ON MOUSEDRAG {|| ::Click() } ;
      ON SIZE {|| ::Resizing() };
      BACKCOLOR ::Backcolor ;
      ON GOTFOCUS {|| oEnvir:ChangeToWindow( ::Name ) }


   DEFINE STATUSBAR

   STATUSITEM "" WIDTH 100

   STATUSITEM "MainMenu" WIDTH 125 ACTION ::AddMainMenu()
   STATUSITEM "ContextMenu" WIDTH 125 ACTION ::AddContextMenu()
   STATUSITEM "NotifyMenu" WIDTH 125 ACTION ::AddNotifyMenu()

// STATUSITEM "StatusBar" WIDTH 100 ACTION ::AddMainMenu()

   END STATUSBAR


   DEFINE CONTEXT MENU
   ITEM "Window Properties" ACTION {|| ::Properties( .F. ), ::SetChanged( .T. ), ::UpdateWinSelec() }
   SEPARATOR
   ITEM "Database fields" ACTION gDBFTool():New( Self )
   SEPARATOR
   ITEM "Save Window" ACTION {|| ::Save( FALSE ) }
   ITEM "Generate MiniGui Code" ACTION {|| ::Save( TRUE ) }
   END MENU

   END WINDOW

   ::UpdateHandle()
   ::UpdateStatusbar()

RETURN NIL


METHOD Kill() CLASS gWindow

   IF ::Changed
      ::Save( FALSE )
   ENDIF
   ::BecomeActiveWindow()
   oEnvir:KillWindow()

RETURN NIL


METHOD AddControl( oControl ) CLASS gWindow

   WHILE _IsControlDefined( "CONTROL_" + AllTrim( Str( ++::WidNum ) ), ::Name )
   END
   AAdd( ::Controls, oControl )
   ::INDEX := Len( ::Controls )
   ::SetChanged( TRUE )

RETURN ( "CONTROL_" + AllTrim( Str( ::WidNum ) ) )


METHOD DelControl() CLASS gWindow

   LOCAL DelMsg

   IF ::AnyControl()

      DelMsg := "Are you sure you want to delete a " + ::ActControl():TYPE + " control " + CR_LF ;
         + "named " + ::ActControl():Name + CR_LF ;
         + "from window " + ::ActControl():oParen:Name + "?"

      IF MsgYesNo( DelMsg, "Warning!" )

         RELEASE CONTROL ( ::ActControl():Name ) OF ( ::ActControl():oParen:Name )

         ADel( ::Controls, ::INDEX )

         OIWin.OIGrid.DeleteItem( ::INDEX )

         IF Len( ::Controls ) > 0
            ASize( ::Controls, Len( ::Controls ) - 1 )
            OIWin.OiGrid.Value := 1
         ENDIF

         IF Len( ::Controls ) > 0
            ::ChangeToControl( 1 )
         ELSE
            oEnvir:ChangeToControl( 0 )
         ENDIF

         ::SetChanged( TRUE )

      ENDIF
   ENDIF

RETURN NIL


METHOD Properties( lCreation  ) CLASS gWindow

   LOCAL cYesText, cNoText

   IF lCreation == NIL
      lCreation := .T.
   ENDIF

   cYesText := iif( lCreation, "CREATE WINDOW", "APPLY CHANGES" )
   cNoText := iif( lCreation, "CANCEL", "DISCARD CHANGES" )

   DEFINE WINDOW WinProp AT 0, 0 ;
      WIDTH 400 HEIGHT 400 ;
      TITLE "Window Properties ( " + ::Name + " )" ;
      ICON "GUIDES" ;
      MODAL NOSIZE ;
      FONT "ARIAL" SIZE 8

   DEFINE TAB WinTab OF WinProp AT 20, 10 WIDTH 380 HEIGHT 300

   PAGE "Main Options"

   @ 35, 10 LABEL WpL408  ;
      VALUE "TITLE:" ;
      WIDTH 90 HEIGHT 20

   @ 30, 100 TEXTBOX WpTitle  ;
      VALUE ::Title ;
      WIDTH 150 HEIGHT 20

   @ 65, 10 LABEL WpL412 ;
      VALUE "ID:" ;
      WIDTH 90 HEIGHT 20

   @ 60, 100 TEXTBOX WpID   ;
      VALUE ::ID ;
      WIDTH 150 HEIGHT 20

   @ 130, 10 CHECKBOX WpIcon OF WinProp ;
      CAPTION "ICON" ;
      WIDTH 100 HEIGHT 20 ;
      VALUE ::lIcon ;
      ON CHANGE {|| ::ToggleIconName }

   @ 130, 110 TEXTBOX WpIconName  OF WinProp ;
      VALUE ::IconName ;
      WIDTH 150 HEIGHT 20

   @ 150, 10 CHECKBOX WpSysMenu OF WinProp ;
      CAPTION "SYSMENU" ;
      WIDTH 100 HEIGHT 20 ;
      VALUE ::lSysMenu

   @ 170, 10 CHECKBOX WpCaption OF WinProp ;
      CAPTION "CAPTION" ;
      WIDTH 100 HEIGHT 20 ;
      VALUE ::lCaption

   @ 200, 10 LABEL WpL405 OF WinProp ;
      VALUE "BACKCOLOR:" ;
      WIDTH 80 HEIGHT 20

   @ 200, 90 LABEL WpBackColor OF WinProp ;
      VALUE CastToChar( ::BackColor ) ;
      ACTION ::BCSelec() ;
      WIDTH 150 HEIGHT 15 BACKCOLOR WHITE

   @ 230, 10 LABEL tbL9 VALUE "FONT:" WIDTH 35 HEIGHT 20 BOLD

   @ 230, 45 LABEL tbFont ;
      VALUE CastToChar( ::Font ) ;
      ACTION {|| ::Font := ChangeFont( ::Font ), SetProperty( "WinProp", "tbFont", "VALUE", CastToChar( ::Font ) ) } ;
      WIDTH 300 HEIGHT 15 BACKCOLOR WHITE ;
      TOOLTIP "Choose Window Default Font"

   END PAGE


   PAGE "Modes"

   @ 55, 10 LABEL WpL302 OF WinProp VALUE "MODE:" ;
      WIDTH 50 HEIGHT 20

   @ 50, 60 COMBOBOX WpMainMode OF WinProp ;
      WIDTH 100 HEIGHT 100 ;
      ITEMS { "MAIN", "CHILD", "MODAL", "SPLITCHILD", "PRINT REPORT" } ;
      VALUE ::nMainMode;
      TOOLTIP "Window Mode" ;
      ON CHANGE {|| ::ToggleOnModal() }

   @ 90, 10 CHECKBOX WpNoShow OF WinProp ;
      CAPTION "NO SHOW" ;
      WIDTH 100 HEIGHT 20 ;
      VALUE ::lNoShow

   @ 110, 10 CHECKBOX WpTopMost OF WinProp ;
      CAPTION "TOPMOST" ;
      WIDTH 100 HEIGHT 20 ;
      VALUE ::lTopMost

   @ 130, 10 CHECKBOX WpMaximize OF WinProp ;
      CAPTION "ALLOW MAXIMIZE" ;
      WIDTH 150 HEIGHT 20 ;
      VALUE ::lAllowMaximize

   @ 150, 10 CHECKBOX WpMinimize OF WinProp ;
      CAPTION "ALLOW MINIMIZE" ;
      WIDTH 150 HEIGHT 20 ;
      VALUE ::lAllowMinimize

   @ 100, 200 CHECKBOX WpResize OF WinProp ;
      CAPTION "ALLOW RESIZING" ;
      WIDTH 120 HEIGHT 20 ;
      VALUE ::AllowResize


   END PAGE

   PAGE "Size / Position"

   @ 38, 10 FRAME Frame_1 WIDTH 300 HEIGHT 40 OPAQUE
   @ 50, 25 LABEL WpL103 OF WinProp VALUE "ROW:" WIDTH 30 HEIGHT 20
   @ 50, 180 LABEL WpL104 OF WinProp VALUE "COL:" WIDTH 30 HEIGHT 20
   @ 45, 75  SPINNER WpRow OF WinProp RANGE 0, 2000 VALUE ::Row WIDTH 50 HEIGHT 20
   @ 45, 235 SPINNER WpCol OF WinProp RANGE 0, 2000 VALUE ::Col WIDTH 50 HEIGHT 20

   @ 86, 10 FRAME Frame_2 WIDTH 300 HEIGHT 40 OPAQUE
   @ 97, 25 LABEL WpL105 OF WinProp VALUE "WIDTH:" WIDTH 50 HEIGHT 20
   @ 97, 180 LABEL WpL106 OF WinProp VALUE "HEIGHT:" WIDTH 50 HEIGHT 20
   @ 95, 75 SPINNER WpWidth OF WinProp RANGE 0, 2000 VALUE ::Width WIDTH 50 HEIGHT 20
   @ 95, 235 SPINNER WpHeight OF WinProp RANGE 0, 2000 VALUE ::Height WIDTH 50 HEIGHT 20

   @ 150, 10 CHECKBOX WpVirtual ;
      CAPTION "Enable Virtual Dimensions" ;
      WIDTH 300 HEIGHT 20 ;
      VALUE ::VirtualDim ;
      ON CHANGE {|| ::ToggleVirtual() }


   @ 190, 10 FRAME Frame_21 WIDTH 300 HEIGHT 50 OPAQUE
   @ 203, 25 LABEL WpL1105      OF WinProp VALUE "VIRTUAL WIDTH:" WIDTH 50 HEIGHT 30
   @ 203, 180 LABEL WpL1106     OF WinProp VALUE "VIRTUAL HEIGHT:" WIDTH 50 HEIGHT 30
   @ 207, 75 SPINNER WpVWidth   OF WinProp RANGE 0, 2000 VALUE ::VWidth WIDTH 50 HEIGHT 20
   @ 207, 235 SPINNER WpVHeight OF WinProp RANGE 0, 2000 VALUE ::VHeight WIDTH 50 HEIGHT 20

   END PAGE


   PAGE "Events"

   @ 40, 10 LABEL WpL201 OF WinProp VALUE "ON MOUSECLICK:" WIDTH 100 HEIGHT 20
   @ 60, 10 LABEL WpL202 OF WinProp VALUE "ON MOUSEDRAG:" WIDTH 100 HEIGHT 20
   @ 80, 10 LABEL WpL203 OF WinProp VALUE "ON MOUSEMOVE:" WIDTH 100 HEIGHT 20
   @ 100, 10 LABEL WpL204 OF WinProp VALUE "ON INIT:" WIDTH 100 HEIGHT 20
   @ 120, 10 LABEL WpL205 OF WinProp VALUE "ON RELEASE:" WIDTH 100 HEIGHT 20
   @ 140, 10 LABEL WpL206 OF WinProp VALUE "ON SIZE:" WIDTH 100 HEIGHT 20
   @ 160, 10 LABEL WpL207 OF WinProp VALUE "ON PAINT:" WIDTH 100 HEIGHT 20
   @ 40, 110 TEXTBOX WpT101  OF WinProp VALUE ::OnMouseClick WIDTH 240 HEIGHT 20
   @ 60, 110 TEXTBOX WpT102  OF WinProp VALUE ::OnMouseDrag WIDTH 240 HEIGHT 20
   @ 80, 110 TEXTBOX WpT103  OF WinProp VALUE ::OnMouseMove WIDTH 240 HEIGHT 20
   @ 100, 110 TEXTBOX WpT104  OF WinProp VALUE ::OnInit WIDTH 240 HEIGHT 20
   @ 120, 110 TEXTBOX WpT105  OF WinProp VALUE ::OnRelease WIDTH 240 HEIGHT 20
   @ 140, 110 TEXTBOX WpT106  OF WinProp VALUE ::OnSize WIDTH 240 HEIGHT 20
   @ 160, 110 TEXTBOX WpT107  OF WinProp VALUE ::OnPaint WIDTH 240 HEIGHT 20

   @ 40, 350 BUTTON WpB101 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT101", "WinProp", "OnMouseClick" ) } ;
      WIDTH 20 HEIGHT 20

   @ 60, 350 BUTTON WpB102 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT102", "WinProp", "OnMouseDrag" ) } ;
      WIDTH 20 HEIGHT 20

   @ 80, 350 BUTTON WpB103 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT103", "WinProp", "OnMouseMove" ) } ;
      WIDTH 20 HEIGHT 20

   @ 100, 350 BUTTON WpB104 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT104", "WinProp", "OnInit" ) } ;
      WIDTH 20 HEIGHT 20

   @ 120, 350 BUTTON WpB105 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT105", "WinProp", "OnRelease" ) } ;
      WIDTH 20 HEIGHT 20

   @ 140, 350 BUTTON WpB106 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT106", "WinProp", "OnSize" ) } ;
      WIDTH 20 HEIGHT 20

   @ 160, 350 BUTTON WpB107 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT107", "WinProp", "OnPaint" ) } ;
      WIDTH 20 HEIGHT 20

   END PAGE


   PAGE "More Events"

   @ 40, 10 LABEL WpL1201 OF WinProp VALUE "ON NOTIFYCLICK:" WIDTH 100 HEIGHT 20
   @ 60, 10 LABEL WpL1202 OF WinProp VALUE "ON GOTFOCUS:" WIDTH 100 HEIGHT 20
   @ 80, 10 LABEL WpL1203 OF WinProp VALUE "ON LOSTFOCUS:" WIDTH 100 HEIGHT 20
   @ 100, 10 LABEL WpL1204 OF WinProp VALUE "ON SCROLLUP:" WIDTH 100 HEIGHT 20
   @ 120, 10 LABEL WpL1205 OF WinProp VALUE "ON SCROLLDOWN:" WIDTH 100 HEIGHT 20
   @ 140, 10 LABEL WpL1206 OF WinProp VALUE "ON SCROLLRIGHT:" WIDTH 100 HEIGHT 20
   @ 160, 10 LABEL WpL1207 OF WinProp VALUE "ON SCROLLLEFT:" WIDTH 100 HEIGHT 20

   @ 40, 110 TEXTBOX WpT1101  OF WinProp VALUE ::OnNotifyClick WIDTH 240 HEIGHT 20
   @ 60, 110 TEXTBOX WpT1102  OF WinProp VALUE ::OnGotfocus WIDTH 240 HEIGHT 20
   @ 80, 110 TEXTBOX WpT1103  OF WinProp VALUE ::OnLostfocus WIDTH 240 HEIGHT 20
   @ 100, 110 TEXTBOX WpT1104  OF WinProp VALUE ::OnScrollup WIDTH 240 HEIGHT 20
   @ 120, 110 TEXTBOX WpT1105  OF WinProp VALUE ::OnScrolldown WIDTH 240 HEIGHT 20
   @ 140, 110 TEXTBOX WpT1106  OF WinProp VALUE ::OnScrollRight WIDTH 240 HEIGHT 20
   @ 160, 110 TEXTBOX WpT1107  OF WinProp VALUE ::OnScrollLeft WIDTH 240 HEIGHT 20

   @ 40, 350 BUTTON WpB1101 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT1101", "WinProp", "OnNotifyClick" ) } ;
      WIDTH 20 HEIGHT 20

   @ 60, 350 BUTTON WpB1102 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT1102", "WinProp", "OnGotfocus" ) } ;
      WIDTH 20 HEIGHT 20

   @ 80, 350 BUTTON WpB1103 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT1103", "WinProp", "OnLostfocus" ) } ;
      WIDTH 20 HEIGHT 20

   @ 100, 350 BUTTON WpB1104 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT1104", "WinProp", "OnScrollup" ) } ;
      WIDTH 20 HEIGHT 20

   @ 120, 350 BUTTON WpB1105 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT1105", "WinProp", "OnScrolldown" ) } ;
      WIDTH 20 HEIGHT 20

   @ 140, 350 BUTTON WpB1106 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT1106", "WinProp", "OnScrollRight" ) } ;
      WIDTH 20 HEIGHT 20

   @ 160, 350 BUTTON WpB1107 OF WinProp CAPTION "...";
      ACTION {|| gCBEdit():New( "WpT1107", "WinProp", "OnScrollLeft" ) } ;
      WIDTH 20 HEIGHT 20

   END PAGE

   END TAB


   @ 330, 20 BUTTON WpCommit OF WinProp CAPTION cYesText ;
      ACTION ::EndProps( .T. ) WIDTH 120 HEIGHT 30

   @ 330, 170 BUTTON WpCancel OF WinProp CAPTION cNoText ;
      ACTION ::EndProps( .F. ) WIDTH 120 HEIGHT 30

   END WINDOW

   WinProp.WpBackColor.Enabled := TRUE

   WinProp.WpVWidth.Enabled := ::VirtualDim
   WinProp.WpVHeight.Enabled := ::VirtualDim

   WinProp.WpIconName.Enabled := ::lIcon

   WinProp.Center
   WinProp.Activate

RETURN NIL


METHOD EndProps( lAccepted ) CLASS gWindow

   IF lAccepted
      ::col       := WinProp.WpCol.Value
      ::row       := WinProp.WpRow.Value
      ::width     := WinProp.WpWidth.Value
      ::height    := WinProp.WpHeight.Value

      ::Title     := WinProp.WpTitle.Value
      ::ID        := WinProp.WpID.Value

      ::OnMouseClick  := WinProp.WpT101.Value
      ::OnMouseDrag   := WinProp.WpT102.Value
      ::OnMouseMove   := WinProp.WpT103.Value
      ::OnInit        := WinProp.WpT104.Value
      ::OnRelease     := WinProp.WpT105.Value
      ::OnSize        := WinProp.WpT106.Value
      ::OnPaint       := WinProp.WpT107.Value

      ::OnNotifyClick := WinProp.WpT1101.Value
      ::OnGotfocus    := WinProp.WpT1102.Value
      ::OnLostfocus   := WinProp.WpT1103.Value
      ::OnScrollup    := WinProp.WpT1104.Value
      ::OnScrolldown  := WinProp.WpT1105.Value
      ::OnScrollRight := WinProp.WpT1106.Value
      ::OnScrollLeft  := WinProp.WpT1107.Value

      ::nMainMode    := WinProp.WpMainMode.Value

      ::AlloWResize  := WinProp.WpResize.Value
      ::lIcon        := WinProp.WpIcon.Value
      ::IconName     := WinProp.WpIconName.Value
      ::lSysMenu     := WinProp.WpSysMenu.Value
      ::lCaption     := WinProp.WpCaption.Value
      ::lNoShow      := WinProp.WpNoShow.Value
      ::lTopMost     := WinProp.WpTopMost.Value

      ::lAllowMaximize     := WinProp.WpMaximize.Value
      ::lAllowMinimize     := WinProp.WpMinimize.Value

      ::VirtualDim     := WinProp.WpVirtual.Value
      ::VWidth         := WinProp.WpVWidth.Value
      ::VHeight        := WinProp.WpVHeight.Value

// ::BackColor is set inmediately when selected

   ENDIF

   ::OK := lAccepted
   RELEASE WINDOW WinProp

RETURN NIL


METHOD BCSelec() CLASS gWindow

   LOCAL aColor := ::BackColor                                        // GF
   LOCAL oColor := GetColor( IF( aColor[ 1 ] == NIL, NIL, aColor ) )  // GF

   WinProp.WpBackColor.Value := CastToChar( oColor )
   ::BackColor := oColor

RETURN NIL


METHOD Output( cFileName ) CLASS gWindow

   LOCAL nCount
   LOCAL cSection
   LOCAL nItems := Len( ::Controls ) + 1
   LOCAL aMainElems
   LOCAL aContextElems
   LOCAL aNotifyElems

   Progres( 0, "Saving window. Please wait..." )

   BEGIN INI FILE cFileName

   SET SECTION "GUIDES" ENTRY "VERSION" TO G_RELEASE

   SET SECTION "WINDOW" ENTRY "ID" TO   ::ID
   SET SECTION "WINDOW" ENTRY "ROW" TO ::Row
   SET SECTION "WINDOW" ENTRY "COL" TO ::Col
   SET SECTION "WINDOW" ENTRY "WIDTH" TO ::Width
   SET SECTION "WINDOW" ENTRY "HEIGHT" TO ::Height
   SET SECTION "WINDOW" ENTRY "TITLE" TO ::Title

   SET SECTION "WINDOW" ENTRY "VIRTUALDIM" TO ::VirtualDim
   SET SECTION "WINDOW" ENTRY "V_WIDTH"   TO ::VWidth
   SET SECTION "WINDOW" ENTRY "V_HEIGHT"  TO ::VHeight

   SET SECTION "WINDOW" ENTRY "L_ICON" TO ::lIcon
   SET SECTION "WINDOW" ENTRY "ICONNAME" TO ::IconName
   SET SECTION "WINDOW" ENTRY "MODE" TO ::nMainMode
   SET SECTION "WINDOW" ENTRY "NOSHOW" TO ::lNoShow
   SET SECTION "WINDOW" ENTRY "TOPMOST" TO ::lTopMost
   SET SECTION "WINDOW" ENTRY "MINIMIZE" TO ::lAllowMinimize
   SET SECTION "WINDOW" ENTRY "MAXIMIZE" TO ::lAllowMaximize
   SET SECTION "WINDOW" ENTRY "NOSIZE" TO ::AllowResize
   SET SECTION "WINDOW" ENTRY "NOSYSMENU" TO ::lSysMenu
   SET SECTION "WINDOW" ENTRY "NOCAPTION" TO ::lCaption
   SET SECTION "WINDOW" ENTRY "ON INIT" TO ::OnInit
   SET SECTION "WINDOW" ENTRY "ON RELEASE" TO ::OnRelease
   SET SECTION "WINDOW" ENTRY "ON MOUSECLICK" TO ::OnMouseClick
   SET SECTION "WINDOW" ENTRY "ON MOUSEDRAG" TO ::OnMouseDrag
   SET SECTION "WINDOW" ENTRY "ON INIT" TO ::OnInit
   SET SECTION "WINDOW" ENTRY "ON MOUSEMOVE"  TO ::OnMouseMove
   SET SECTION "WINDOW" ENTRY "ON SIZE"       TO ::OnSize
   SET SECTION "WINDOW" ENTRY "ON PAINT"      TO ::OnPaint

   SET SECTION "WINDOW" ENTRY "ON NOTIFYCLICK" TO ::OnNotifyClick
   SET SECTION "WINDOW" ENTRY "ON GOTFOCUS" TO ::OnGotFocus
   SET SECTION "WINDOW" ENTRY "ON LOSTFOCUS" TO ::OnLostFocus
   SET SECTION "WINDOW" ENTRY "ON SCROLLUP" TO ::OnScrollUp
   SET SECTION "WINDOW" ENTRY "ON SCROLLDOWN" TO ::OnScrollDown
   SET SECTION "WINDOW" ENTRY "ON SCROLLRIGHT"  TO ::OnScrollRight
   SET SECTION "WINDOW" ENTRY "ON SCROLLLEFT"   TO ::OnScrollLeft

   SET SECTION "WINDOW" ENTRY "BACKCOLOR"     TO ::BackColor

   aMainElems := iif( Empty( ::MainMenu ), {}, ::MainMenu:Elements )
   SET SECTION "WINDOW" ENTRY "MAINMENU"      TO aMainElems

   aContextElems := iif( Empty( ::ContextMenu ), {}, ::ContextMenu:Elements )
   SET SECTION "WINDOW" ENTRY "CONTEXTMENU"   TO aContextElems

   aNotifyElems := iif( Empty( ::NotifyMenu ), {}, ::NotifyMenu:Elements )
   SET SECTION "WINDOW" ENTRY "NOTIFYMENU"    TO aNotifyElems

   SET SECTION "WINDOW" ENTRY "CONTROLS"    TO Len( ::Controls )

   Progres( 100 / nItems )

   FOR nCount := 1 TO Len( ::Controls )
      cSection := "CONTROL_" + AllTrim( Str( nCount ) )
      ::Controls[ nCount ]:Output( cSection )
      Progres( ( nCount * 100 ) / nItems )
   NEXT

   END INI

   Progres( 100 )

RETURN NIL


METHOD Code( fHandler ) CLASS gWindow

   LOCAL cCode
   LOCAL RetVal := ""
   LOCAL nCount
   LOCAL oControl
   LOCAL oCode
   LOCAL nItems := Len( ::Controls ) + 1
   LOCAL lAnyDBCode := FALSE

   IF !Empty( ::MainMenu )
      nItems++
   ENDIF

   IF !Empty( ::ContextMenu )
      nItems++
   ENDIF

   IF !Empty( ::NotifyMenu )
      nItems++
   ENDIF

   Progres( 0, "Saving code. Please wait..." )

   oCode := gCode():New( fHandler )

   IF !( ::nMainMode == 5 )
      IF oStyle:FullCode()
         oCode:AddLine( "/*", , TRUE )
         oCode:AddLine( " * This program is generated by GUIDES", , TRUE )
         oCode:AddLine( " * developed by Carlos Andres <carlos.andres@navegalia.com>", , TRUE )
         oCode:AddLine( " */", , TRUE )
         oCode:AddLine( "", TRUE )
         oCode:AddLine( "#include 'minigui.ch'", , TRUE )
         oCode:AddLine( "", TRUE )
         oCode:AddLine( "FUNCTION Form_" + ::Id + "()", , TRUE )
         oCode:MoreTab()
      ENDIF

      oCode:MoreTab()
      oCode:AddTag( "DEFINE WINDOW", ::ID, TRUE,  )

      cCode := "AT " + AllTrim( Str( ::Row ) ) + "," + AllTrim( Str( ::Col ) )
      oCode:AddLine( cCode )

      oCode:AddTag( "WIDTH", ::Width )
      oCode:AddTag( "HEIGHT", ::Height )

      IF ::VirtualDim
         oCode:AddNotEmpty( "VIRTUAL WIDTH", ::VWidth )
         oCode:AddNotEmpty( "VIRTUAL HEIGHT", ::VHeight )
      ENDIF

      oCode:AddQuoted( "TITLE", ::Title )

      IF ::lIcon
         oCode:AddQuoted( "ICON", ::IconName )
      ENDIF

      IF ::nMainMode == 3
         oCode:AddLine( "MODAL" )
      ELSE
         IF ( ::nMainMode == 1 )
            oCode:AddLine( "MAIN" )
         ELSEIF ( ::nMainMode == 2 )
            oCode:AddLine( "CHILD" )
         ENDIF

         oCode:AddNotEmpty( "NOSHOW", ::lNoShow )
         oCode:AddNotEmpty( "TOPMOST", ::lTopMost )
         oCode:AddNotEmpty( "NOMINIMIZE", !::lAllowMinimize )
         oCode:AddNotEmpty( "NOMAXIMIZE", !::lAllowMaximize )
      ENDIF

      oCode:AddNotEmpty( "NOSIZE",    !( ::AllowResize ) )
      oCode:AddNotEmpty( "NOSYSMENU", ::lSysMenu )
      oCode:AddNotEmpty( "NOCAPTION", ::lCaption )

      oCode:AddNotEmpty( "ON INIT", ::OnInit  )
      oCode:AddNotEmpty( "ON RELEASE", ::OnRelease  )
      oCode:AddNotEmpty( "ON MOUSECLICK", ::OnMouseClick  )
      oCode:AddNotEmpty( "ON MOUSEDRAG", ::OnMouseDrag  )
      oCode:AddNotEmpty( "ON MOUSEMOVE", ::OnMouseMove  )
      oCode:AddNotEmpty( "ON SIZE", ::OnSize  )
      oCode:AddNotEmpty( "ON PAINT", ::OnPaint  )

      oCode:AddNotEmpty( "BACKCOLOR", ColorToCode( ::BackColor ) )
      oCode:AddQuoted( "FONT", ::Font[ 1 ] )
      oCode:AddTag( "SIZE",    ::Font[ 2 ] )
      oCode:AddNotEmpty( "ON NOTIFYCLICK", ::OnNotifyClick  )
      oCode:AddNotEmpty( "ON GOTFOCUS", ::OnGotFocus  )
      oCode:AddNotEmpty( "ON LOSTFOCUS",   ::OnLostFocus  )
      oCode:AddNotEmpty( "ON SCROLLUP", ::OnScrollUp  )
      oCode:AddNotEmpty( "ON SCROLLDOWN", ::OnScrollDown  )
      oCode:AddNotEmpty( "ON SCROLLLEFT", ::OnScrollLeft  )
      oCode:AddNotEmpty( "ON SCROLLRIGHT", ::OnScrollRight  )

      Progres( 100 / nItems )

      IF oCode:WriteToFile()
         oCode:MoreTab()
         FOR nCount := 1 TO Len( ::Controls )
            oControl := ::Controls[ nCount ]
            oControl:Code( oCode )
            Progres( ( nCount * 100 ) / nItems )
         NEXT
         oCode:LessTab()
      ENDIF

      IF !Empty( ::MainMenu )
         ::MainMenu:Code( oCode )
      ENDIF

      IF !Empty( ::ContextMenu )
         ::ContextMenu:Code( oCode )
      ENDIF

      IF !Empty( ::NotifyMenu )
         ::NotifyMenu:Code( oCode )
      ENDIF

      oCode:AddLine( "END WINDOW", TRUE )
      oCode:LessTab()

      IF oStyle:FullCode()
         oCode:MoreTab()
         oCode:AddTag( "CENTER WINDOW", ::ID, TRUE,  )
         oCode:AddTag( "ACTIVATE WINDOW", ::ID, TRUE,  )
         oCode:LessTab()
         oCode:AddLine( "RETURN NIL", TRUE )
      ENDIF

      oCode:WriteToFile()

      IF oStyle:ExportDBCode()
         FOR nCount := 1 TO Len( ::Controls )
            oControl := ::Controls[ nCount ]
            IF ( oControl:TYPE == "TEXTBOX" ) .OR. ( oControl:TYPE == "EDITBOX" ) .OR. ( oControl:TYPE == "CHECKBOX" ) .OR. ( oControl:TYPE == "DATEPICKER" )
               IF !Empty( oControl:FieldName )
                  lAnyDBCode := TRUE
               ENDIF
            ENDIF
         NEXT

         IF lAnyDBCode
            oCode:AddLine( "" )
            oCode:AddLine( "FUNCTION Refresh_" + ::Id, TRUE  )
            oCode:MoreTab()
            FOR nCount := 1 TO Len( ::Controls )
               oControl := ::Controls[ nCount ]
               IF ( oControl:TYPE == "TEXTBOX" ) .OR. ( oControl:TYPE == "EDITBOX" ) .OR. ( oControl:TYPE == "CHECKBOX" ) .OR. ( oControl:TYPE == "DATEPICKER" )
                  IF !Empty( oControl:FieldName )
                     oCode:AddLine( ::Id + "." + oCOntrol:Id + ".Refresh", , TRUE )
                  ENDIF
               ENDIF
            NEXT
            oCode:LessTab()
            oCode:AddLine( "RETURN NIL", TRUE, TRUE )
            oCode:WriteToFile()
            oCode:AddLine( "" )
            oCode:AddLine( "FUNCTION Save_" + ::Id, TRUE )
            oCode:MoreTab()
            FOR nCount := 1 TO Len( ::Controls )
               oControl := ::Controls[ nCount ]
               IF ( oControl:TYPE == "TEXTBOX" ) .OR. ( oControl:TYPE == "EDITBOX" ) .OR. ( oControl:TYPE == "CHECKBOX" ) .OR. ( oControl:TYPE == "DATEPICKER" )
                  IF !Empty( oControl:FieldName )
                     oCode:AddLine( ::Id + "." + oCOntrol:Id + ".Save", , TRUE )
                  ENDIF
               ENDIF
            NEXT
            oCode:LessTab()
            oCode:AddLine( "RETURN NIL", TRUE, TRUE )
            oCode:WriteToFile()
         ENDIF
      ENDIF
   ELSE

      ::PrintableCode( oCode )

   ENDIF

   Progres( 100 )

RETURN RetVal


METHOD Save( lCode ) CLASS gWindow

   LOCAL cMessage, cKeyWord
   LOCAL cFile
   LOCAL acFilter
   LOCAL fHandler
   LOCAL lProceed := TRUE
   LOCAL cTitle := "Choose target filename"
   LOCAL cFileExt
   LOCAL aFileName

   cKeyWord := iif( lCode, "export", "save" )
   cMessage := "Do you want to " + cKeyWord + " window " + ::Name + " to a file?"

   IF lCode
      acFilter := { { "Harbour source files (*.prg)", "*.PRG" }, ;
         { "All files (*.*)", "*.*" } }

      cFileExt := ".PRG"
   ELSE
      acFilter := { { "Guides files (*.frm)", "*.FRM" }, ;
         { "All files (*.*)", "*.*" } }

      cFileExt := ".FRM"
   ENDIF

   IF MsgYesNo( cMessage, "GuiDes" )
      cFile := PutFile( acFilter, cTitle, iif( Empty( ::FilePath ), oStyle:ProjectDir(), ::FilePath ) )
      IF Empty( cFile )
         lProceed := FALSE
      ELSE
         cFile := ForceExt( cFile, cFileExt )
         IF File( cFile )
            IF( lProceed := MsgOKCancel( "File " + cFile + " already exists!" + CR_LF + "Do you want to overwrite it?", "Warning!" ) )
               FErase( cFile )
            ENDIF
         ENDIF
      ENDIF

      IF lProceed
         aFileName := SplitPath( cFile )
         ::FileName := aFileName[ 1 ]
         ::FilePath := aFileName[ 2 ]

         IF lCode
            fHandler := FCreate( cFile )
            IF ( FError() == 0 )
               ::Code( fHandler )
               FClose( fHandler )
               IF ( FError() == 0 )
                  MsgInfo( cFile + " has been saved", "GuiDes" )
                  ::SetChanged( FALSE )
                  IF oStyle:AutoInspect()
                     gTextEditor():New( cFile, FALSE )
                  ENDIF
               ELSE
                  MsgBox( "Unrecoverable error creating file!", "GuiDes" )
               ENDIF
            ELSE
               MsgBox( "Error Creating File", "GuiDes" )
            ENDIF
         ELSE
            ::OutPut( cFile )
            ::SetChanged( FALSE )
            oLayout:AddRecentWindow( cFile )
            MsgBox( cFile + " has been properly saved", "GuiDes" )
         ENDIF
      ENDIF
   ENDIF

   DirChange( oEnvir:CurDir )

RETURN NIL


METHOD Click() CLASS gWindow

   LOCAL aPos
   LOCAL xPos, yPos
   LOCAL xSpacing := oStyle:XSpac()
   LOCAL ySpacing := oStyle:YSpac()

   IF ( Main.tbMove.Value ) .AND. !( Empty( ::ActControl() ) )
      aPos := GetClientPos( ::Handler )

      xPos := aPos[ 1 ]
      yPos := aPos[ 2 ]

      IF Prefer.PrefGrid.Value .AND. ;
         ( xSpacing != 0 ) .AND. ( ySpacing != 0 )

         xPos := xSpacing * Int( xPos / xSpacing )
         yPos := ySpacing * Int( yPos / ySpacing )
      ENDIF

      ::ActControl():Move( xPos, yPos )
      ::SetChanged( TRUE )
   ENDIF

RETURN NIL


METHOD ToggleIconName() CLASS gWindow
   WinProp.WpIconName.Enabled := WinProp.WpIcon.Value

RETURN NIL


METHOD ToggleOnModal() CLASS gWindow

   LOCAL lModal := ( WinProp.WpMainMode.Value == 3 )

   WinProp.WpNoShow.Enabled  := !( lModal )
   WinProp.WpTopMost.Enabled := !( lModal )

RETURN NIL


METHOD ToggleVirtual() CLASS gWindow

   LOCAL lVirtual := WinProp.WpVirtual.Value

   WinProp.WpVWidth.Enabled  := lVirtual
   WinProp.WpVHeight.Enabled := lVirtual

RETURN NIL


METHOD ActControl() CLASS gWindow
   IF Empty( ::Controls ) .OR. ( ::INDEX > Len( ::Controls ) )
      RETURN NIL
   ENDIF

RETURN ( ::Controls[ ::Index ] )


METHOD Activate() CLASS gWindow
   ACTIVATE WINDOW &( ::Name )

RETURN NIL


METHOD Resizing() CLASS gWindow

   LOCAL cName := ::Name

   ::Width  := GetProperty( cName, "Width" )
   ::Height := GetProperty( cName, "Height" )

   ::SetChanged( TRUE )

RETURN NIL


METHOD SetChanged( lValue ) CLASS gWindow

   LOCAL TempTitle := ::Name + " - (" + ::Title + ")"

   ::Changed := lValue
   SetProperty(  ::Name, "Title",  iif( lValue, TempTitle + "*", TempTitle ) )

RETURN Self


METHOD AddToList() CLASS gWindow

   WinSelec.WSGrid.AddItem( { ::Name, ::acModes[ ::nMainMode ], ::Id }, 0 )

RETURN Self


METHOD AnyControl() CLASS gWindow
   IF ( ::ActControl() == NIL )
      MsgBox( "No control selected!", "GuiDes" )
      RETURN FALSE
   ENDIF

RETURN TRUE


METHOD AddMainMenu CLASS gWindow

   IF ::MainMenu == NIL
      ::MainMenu := gMenu():New( G_MAINMENU )
   ENDIF

   ::MainMenu:Edit()

   IF ::MainMenu:ExitStatus == G_EXIT_DESTROY
      ::MainMenu := NIL
   ENDIF
   ::SetChanged( TRUE )
   ::UpdateStatusbar()

RETURN Self


METHOD AddContextMenu CLASS gWindow

   IF ::ContextMenu == NIL
      ::ContextMenu := gMenu():New( G_CONTEXTMENU )
   ENDIF

   ::ContextMenu:Edit()

   IF ::ContextMenu:ExitStatus == G_EXIT_DESTROY
      ::ContextMenu := NIL
   ENDIF
   ::SetChanged( TRUE )
   ::UpdateStatusbar()

RETURN Self



METHOD AddNotifyMenu CLASS gWindow

   IF ::NotifyMenu == NIL
      ::NotifyMenu := gMenu():New( G_NOTIFYMENU )
   ENDIF

   ::NotifyMenu:Edit()

   IF ::NotifyMenu:ExitStatus == G_EXIT_DESTROY
      ::NotifyMenu := NIL
   ENDIF
   ::SetChanged( TRUE )
   ::UpdateStatusbar()

RETURN Self


METHOD SearchIndex( cControlName ) CLASS gWindow
RETURN AScan( ::Controls, {| x | x:Name == cControlName } )


METHOD LoadControl( TYPE )  CLASS gWindow

   LOCAL oControl

   DO CASE
   CASE ( TYPE == "ANIMATEBOX" )
      oControl := gAnimateBox():Load(  Self )
   CASE ( TYPE == "BROWSE" )
      oControl := gBrowse():Load(  Self )
   CASE ( TYPE == "BUTTON" )
      oControl := gButton():Load(  Self )
   CASE ( TYPE == "CHECKBOX" )
      oControl := gCheckBox():Load(  Self )
   CASE ( TYPE == "CHECKBUTTON" )
      oControl := gCheckButton():Load(  Self )
   CASE ( TYPE == "COMBOBOX" )
      oControl := gComboBox():Load(  Self )
   CASE ( TYPE == "DATEPICKER" )
      oControl := gDatePicker():Load(  Self )
   CASE ( TYPE == "EDITBOX" )
      oControl := gEditBox():Load(  Self )
   CASE ( TYPE == "FRAME" )
      oControl := gFrame():Load(  Self )
   CASE ( TYPE == "GRID" )
      oControl := gGrid():Load(  Self )
   CASE ( TYPE == "IMAGE" )
      oControl := gImage():Load(  Self )
   CASE ( TYPE == "IPADDRESS" )
      oControl := gIpAddress():Load(  Self )
   CASE ( TYPE == "LABEL" )
      oControl := gLabel():Load(  Self )
   CASE ( TYPE == "LISTBOX" )
      oControl := gListBox():Load(  Self )
   CASE ( TYPE == "MONTHCALENDAR" )
      oControl := gMonthCalendar():Load(  Self )
   CASE ( TYPE == "PLAYER" )
      oControl := gPlayer():Load(  Self )
   CASE ( TYPE == "PROGRESSBAR" )
      oControl := gProgressBar():Load(  Self )
   CASE ( TYPE == "RADIOGROUP" )
      oControl := gRadioGroup():Load(  Self )
   CASE ( TYPE == "SLIDER" )
      oControl := gSlider():Load(  Self )
   CASE ( TYPE == "SPINNER" )
      oControl := gSpinner():Load(  Self )
   CASE ( TYPE == "TEXTBOX" )
      oControl := gTextBox():Load(  Self )
   CASE ( TYPE == "TAB" )
      oControl := gTab():Load(  Self )
   CASE ( TYPE == "TREE" )
      oControl := gTree():Load(  Self )
   CASE ( TYPE == "PRINT" )
      oControl := gPrint():Load(  Self )
   CASE ( TYPE == "HYPERLINK" )
      oControl := gHyperLink():Load(  Self )
   ENDCASE

RETURN oControl


METHOD BecomeActiveWindow() CLASS gWindow

   LOCAL lAnyChange := FALSE

   IF ( oEnvir:Act_Window():Handler <> ::Handler )
      oEnvir:INDEX := oEnvir:WindowIndex( ::Name )
      lAnyChange := TRUE
   ENDIF

   IF ( oEnvir:INDEX <> WinSelec.WSGrid.Value )
      WinSelec.WSGrid.Value := oEnvir:Index
      lAnyChange := TRUE
   ENDIF

   IF !( GetFocus() == ::Handler )
      SetFocus( ::Handler )
      lAnyChange := TRUE
   ENDIF

   IF lAnyChange
      ::RefreshControlWin()
   ENDIF

RETURN FALSE


METHOD RefreshControlWin() CLASS gWindow

   LOCAL nCount

   OIWin.OIGrid.DeleteAllItems
   FOR nCount := 1 TO Len( ::Controls )
      ::Controls[ nCount ]:AddToTree()
   NEXT
   OIWin.OIGrid.Value := ::Index
   ::RefreshProps()

RETURN NIL


METHOD UpdateWinSelec() CLASS gWindow

   LOCAL nValue := WinSelec.WSGrid.Value
   LOCAL cName  := WinSelec.WSGrid.Item ( nValue )[ 1 ]

   IF cName <> ::Name
      WinSelec.WSGrid.Item ( nValue ) := { ::Name, ::acModes[ ::nMainMode ], ::Id }
   ENDIF

RETURN NIL


METHOD ChangeToControl( xRefere ) CLASS gWindow

   LOCAL nIndex := IIF ( ValType( xRefere ) == "N", xRefere, ::SearchIndex( xRefere ) )

   IF  !( nIndex == ::INDEX )
      ::INDEX := nIndex
   ENDIF
   ::ActControl:BecomeActiveControl()

RETURN NIL


METHOD SetFontStyles() CLASS gWindow

   LOCAL nCount, mCount, lCount
   LOCAL aStyles := {}
   LOCAL oControl
   LOCAL aFontStyle
   LOCAL lExists
   LOCAL lSame

   FOR nCount := 1 TO Len( ::Controls )
      oControl := ::Controls[ nCount ]
      IF oControl:TYPE == "PRINT"
         aFontStyle := oControl:Font
         lExists := FALSE
         FOR mCount := 1 TO Len( aStyles )
            lSame := TRUE
            FOR lCount := 1 TO 4
               IF aFontStyle[ lCount ] != aStyles[ mCount ][ lCount ]
                  lSame := FALSE
                  EXIT
               ENDIF
            NEXT
            IF lSame
               lExists := TRUE
            ENDIF
            IF lExists
               oControl:InnerFont := mCount
               EXIT
            ENDIF
         NEXT
         IF !lExists
            AAdd( aStyles, aFontStyle )
            oControl:InnerFont := Len( aStyles )
         ENDIF
      ENDIF
   NEXT
   ::PrintFontStyles := aStyles

RETURN NIL


METHOD FontStylesCode( oCode ) CLASS gWindow

   LOCAL nCount
   LOCAL cCode := ""

   FOR nCount := 1 TO Len( ::PrintFontStyles )
      cCode := 'DEFINE FONT "F' + AllTrim( Str( nCount ) ) + '"'
      cCode += ' NAME "' + ::PrintFontStyles[ nCount ][ 1 ] + '"'
      cCode += ' SIZE ' + AllTrim( Str( ::PrintFontStyles[ nCount ][ 2 ] ) )
      oCode:AddLine( cCode,  , TRUE )
   NEXT
   oCode:WriteToFile()

RETURN NIL


METHOD PrintableCode( oCode ) CLASS gWindow

   LOCAL oControl
   LOCAL nCount

   IF oStyle:FullCode()
      oCode:AddLine( "#include 'minigui.ch'", , TRUE )
      oCode:AddLine( "#include 'winprint.ch'", , TRUE )
      oCode:AddLine( "#define        TRUE       .T.", , TRUE )
      oCode:AddLine( "#define        FALSE      .F.", , TRUE )
      oCode:AddLine( "", TRUE )
      oCode:AddLine( "FUNCTION Print_" + ::Id + "()", , TRUE )
      oCode:MoreTab()
   ENDIF
   oCode:AddLine( "", , TRUE )
   oCode:AddLine( "INIT PRINTSYS", , TRUE )
   oCode:AddLine( "SELECT DEFAULT PREVIEW", , TRUE  )
   oCode:AddLine( "START DOC", , TRUE )
   ::SetFontStyles()
   ::FontStylesCode( oCode )
   oCode:AddLine( "SET ORIENTATION PORTRAIT", , TRUE )
   oCode:AddLine( "SET PAPERSIZE DMPAPER_A4", , TRUE )
   oCode:AddLine( "SET UNITS MM", , TRUE )
   oCode:AddLine( "START PAGE", , TRUE )

   IF oCode:WriteToFile()
      oCode:AddLine( "", , TRUE )
      oCode:MoreTab()
      FOR nCount := 1 TO Len( ::Controls )
         oControl := ::Controls[ nCount ]
         IF oControl:TYPE == "PRINT"
            oControl:Code( oCode )
         ENDIF
      NEXT
      oCode:LessTab()
      oCode:AddLine( "", , TRUE )
   ENDIF
   oCode:AddLine( "END PAGE", , TRUE )
   oCode:AddLine( "END DOC", , TRUE )
   oCode:AddLine( "RELEASE PRINTSYS", , TRUE )
   oCode:WriteToFile()

   IF oStyle:FullCode()
      oCode:LessTab()
      oCode:AddLine( "RETURN NIL", TRUE )
      oCode:WriteToFile()
   ENDIF

RETURN NIL


METHOD UpdateStatusbar() CLASS gWindow

   SetProperty( ::Name, "Statusbar", "Item", 2, iif( ::MainMenu == NIL, "NO MainMenu", "Mainmenu" ) )
   SetProperty( ::Name, "Statusbar", "Item", 3, iif( ::ContextMenu == NIL, "NO ContextMenu", "ContextMenu" ) )
   SetProperty( ::Name, "Statusbar", "Item", 4, iif( ::NotifyMenu == NIL, "NO NotifyMenu", "NotifyMenu" ) )

RETURN NIL
