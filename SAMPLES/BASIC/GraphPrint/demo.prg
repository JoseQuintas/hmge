/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Data provided by gs.statcounter.com for January 2023
*/

#include "hmg.ch"
#include "GraphPlus.ch"

// define the static arrays for graph show and print routines
STATIC aSeries
STATIC aSerieNames
STATIC aColors
STATIC oObj

/////////////////////////////////////////////////////////////
FUNCTION Main

   // create graph object
   oObj := GraphPlus():New()

   // set the series data
   aSeries := { ;
      68.86, ;
      18.12, ;
      9.55, ;
      2.28, ;
      0.62, ;
      0.45, ;
      0.12  ;
      }

   // set the series names
   aSerieNames := { ;
      "Windows 10", ;
      "Windows 11", ;
      "Windows 7", ;
      "Windows 8.1", ;
      "Windows 8", ;
      "Windows XP", ;
      "Other" ;
      }

   // set the colors
   // using of Netscape 216 color's scheme (51 * n)
   aColors := { ;
      { 51, 102, 153 }, ;
      { 51, 153, 51 }, ;
      { 204, 51, 51 }, ;
      { 204, 153, 0 }, ;
      { 51, 153, 204 }, ;
      { 204, 102, 0 }, ;
      { 102, 102, 153 } ;
      }

   AEval( aSerieNames, {|x, i| aSerieNames[ i ] := x + " (" + hb_ntos( aSeries[ i ] ) + "%)" } )

   SET FONT TO GetDefaultFontName(), 10

   // initialise a default font name
   IF Empty( _HMG_DefaultFontName )
      _HMG_DefaultFontName := GetDefaultFontName()
   ENDIF

   // initialise a default font size
   IF Empty( _HMG_DefaultFontSize )
      _HMG_DefaultFontSize := GetDefaultFontSize()
   ENDIF

   DEFINE WINDOW m ;
      AT 0, 0 ;
      WIDTH 720 HEIGHT 660 ;
      MAIN ;
      TITLE "Print Pie Graph" ;
      BACKCOLOR { 216, 208, 200 }

   DEFINE IMAGE chart
      ROW 10
      COL 140
      WIDTH 540
      HEIGHT 600
      STRETCH .T.
   END IMAGE

   DEFINE BUTTON d
      ROW 10
      COL 10
      CAPTION "Draw"
      ACTION showpie()
   END BUTTON

   DEFINE BUTTON p
      ROW 40
      COL 10
      CAPTION "Save"
      ACTION ( showpie(), savepie() )
   END BUTTON

   END WINDOW

   m.Center()
   m.Activate()

RETURN NIL

/////////////////////////////////////////////////////////////
FUNCTION showpie

   Create_CONTEXT_Menu( ThisWindow.Name )

   IF ! Empty( oObj:hBitmap )
      DeleteObject( oObj:hBitmap )
      oObj:hBitmap := NIL
   ENDIF

   WITH OBJECT oObj
      :Width := m.chart.Width
      :Height := m.chart.Height
      :GraphData := aSeries
      :Legends := aSerieNames
      :GraphColors := aColors
      :Title := 'Desktop Windows Version Market Share Worldwide'
      :GraphType := GT_PIE
      :ShowLegends := .T.
      :LegendPos := LEGEND_ON_BOTTOM
      :LegendFont := CREATE ARRAY FONT (_HMG_DefaultFontName) SIZE (_HMG_DefaultFontSize + 2) BOLD .F.
      :TitleFont := CREATE ARRAY FONT (_HMG_DefaultFontName) SIZE (_HMG_DefaultFontSize + 6) BOLD .T.
      :aTitleColor := BLACK
      :nPieGap := 1
      :Draw()
      SetProperty( ThisWindow.Name, 'chart', 'HBITMAP', :Bitmap )
   ENDWITH

RETURN NIL

/////////////////////////////////////////////////////////////
FUNCTION savepie

   oObj:Save( 'graph.png' )

RETURN NIL

/////////////////////////////////////////////////////////////
PROCEDURE Create_CONTEXT_Menu ( cForm )

   IF IsContextMenuDefined ( cForm ) == .T.
      Release_CONTEXT_Menu ( cForm )
   ENDIF

   DEFINE CONTEXT MENU OF (cForm)

      ITEM 'Change Graph Font Name' ACTION ;
         ( _HMG_DefaultFontName := GetFont ( _HMG_DefaultFontName, _HMG_DefaultFontSize, .F., .F., { 0, 0, 0 }, .F., .F., 0 ) [ 1 ], showpie() )

      ITEM 'Change Graph Font Size' ACTION ;
         ( _HMG_DefaultFontSize := GetFont ( _HMG_DefaultFontName, _HMG_DefaultFontSize, .F., .F., { 0, 0, 0 }, .F., .F., 0 ) [ 2 ], showpie() )

   END MENU

RETURN

/////////////////////////////////////////////////////////////
PROCEDURE Release_CONTEXT_Menu ( cForm )

   IF IsContextMenuDefined ( cForm ) == .F.
      MsgInfo ( "Context Menu not defined" )
      RETURN
   ENDIF

   RELEASE CONTEXT MENU OF (cForm)

RETURN
