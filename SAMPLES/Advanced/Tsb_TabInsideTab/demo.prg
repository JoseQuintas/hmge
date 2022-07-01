/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Author: Igor Nazarov
*/

#include "minigui.ch"
#include "i_winuser.ch"
#include "tsbrowse.ch"

*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*
   LOCAL oWnd
   LOCAL cTitle
   LOCAL oBrw
   LOCAL aArray := {}
   LOCAL aFont := {}
   LOCAL i := 0

   SET OOP ON

   aArray := { { "Sheet 1", "Sheet 2", "Sheet 3", "Sheet 4" } }
   cTitle := "TBrowse TAB in TAB Test"

   DEFINE WINDOW Form_0 ;
         AT 0, 0 ;
         WIDTH 400 HEIGHT 300 ;
         TITLE cTitle ;
         MAIN ;
         ON INIT oBrw:SetFocus()

         oWnd := ThisWindow.Object

   END WINDOW


   DEFINE FONT Font_1 FONTNAME "Times New Roman" SIZE 11
   DEFINE FONT Font_2 FONTNAME "Times New Roman" SIZE 13 BOLD

   AAdd( aFont, GetFontHandle( "Font_1" ) )
   AAdd( aFont, GetFontHandle( "Font_2" ) )


   DEFINE TBROWSE oBrw AT 5, 2 OF Form_0 ;
         WIDTH oWnd:ClientWidth() ;
         HEIGHT 25 ;
         GRID

   END TSBROWSE

      WITH OBJECT oBrw

         :SetArray( aArray, .T. )

         :nWheelLines := 0.1
         :nClrLine := COLOR_GRID
         :lNoChangeOrd := TRUE
         :lCellBrw := TRUE
         :lNoKeyChar := TRUE

         :lNoVScroll := TRUE
         :lNoHScroll := TRUE

         :nHeightCell := 25
         :nHeightHead := 0
         :bChange := {|| nil }
         :bLDblClick := {|| nil }

         :SetColor( { 1 }, { {|| RGB( 0, 0, 0 ) } }, )
         :SetColor( { 5 }, { {|| RGB( 0, 0, 0 ) } }, )
         :SetColor( { 11 }, { {|| RGB( 0, 0, 0 ) } }, )


         :SetColor( { 6 }, { {| a, b, c | IF( c:nCell == b, { RGB( 255, 255, 255 ), RGB( 220, 220, 220 ) }, ;
            { RGB( 255, 255, 255 ), RGB( 220, 220, 220 ) } ) } } )


         :SetColor( { 12 }, { {| a, b, c | IF( c:nCell == b, { RGB( 255, 255, 255 ), RGB( 220, 220, 220 ) }, ;
            { RGB( 255, 255, 255 ), RGB( 220, 220, 220 ) } ) } } )


         :ChangeFont( {|| IF( oBrw:nCell == 1, aFont[ 2 ], aFont[ 1 ] ) }, 1, 1 )
         :ChangeFont( {|| IF( oBrw:nCell == 2, aFont[ 2 ], aFont[ 1 ] ) }, 2, 1 )
         :ChangeFont( {|| IF( oBrw:nCell == 3, aFont[ 2 ], aFont[ 1 ] ) }, 3, 1 )
         :ChangeFont( {|| IF( oBrw:nCell == 4, aFont[ 2 ], aFont[ 1 ] ) }, 4, 1 )

         :bTSDrawCell := {| a, b, c | if( b:nCell == oBrw:nCell, b:nClrLine := CLR_GRAY, b:nClrLine := COLOR_GRID ) }

         :bOnDraw := {|| DrawPage( oBrw, oBrw:nCell ) }

      END


      SetWindowLong( oBrw:hWnd, GWL_EXSTYLE, WS_EX_STATICEDGE )

      // define pages
      FOR i := 1 TO oBrw:nColCount()

         DEFINE WINDOW &( "P" + hb_ntoc( i ) ) AT 30, 2 ;
               PARENT Form_0 ;
               WIDTH oWnd:ClientWidth() ;
               HEIGHT oWnd:ClientHeight() - 30 ;
               PANEL ;
               BACKCOLOR { 220, 220, 220 } ;
               NOSHOW

         DEFINE TAB &( "T" + hb_ntoc( i ) ) ;
               AT 10,10 ;
               WIDTH oWnd:ClientWidth() - 20 - 4 ;
               HEIGHT oWnd:ClientHeight() - 50 ;
               VALUE 1 ;
               FONT 'Font_1' ;
               HOTTRACK ;
               HTINACTIVECOLOR GRAY ;
               HTFORECOLOR BLACK ;
               BACKCOLOR { 220, 220, 220 }

            PAGE 'Page &1'

               DEFINE LABEL &( "L" + hb_ntoc( i ) )
                  ROW 100
                  COL 10
                  WIDTH oWnd:ClientWidth() - 40
                  HEIGHT 30
                  FONTNAME 'Arial'
                  FONTSIZE 18
                  FONTBOLD .T.
                  VALUE "Page " + hb_ntoc( i )
                  BACKCOLOR { 220, 220, 220 }
                  CENTERALIGN .T.
               END LABEL

            END PAGE

         IF i > 1
            PAGE 'Page &2'

            END PAGE
         ENDIF

         IF i > 2
            PAGE 'Page &3'

            END PAGE
         ENDIF

         IF i > 3
            PAGE 'Page &4'

            END PAGE
         ENDIF

         END TAB

         END WINDOW

      NEXT

      drawPage( oBrw, 1 )

      Form_0.Center()
      Form_0.Activate()

RETURN


FUNCTION drawPage(oBrw, i)

   STATIC nPage := 0

   IF nPage <> 0
      DoMethod( "P" + hb_ntoc( nPage ), "hide" )
   END
   nPage := i
   DoMethod( "P" + hb_ntoc( nPage ), "show" )

RETURN NIL
