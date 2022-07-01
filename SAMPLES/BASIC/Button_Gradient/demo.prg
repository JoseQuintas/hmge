/*
 * MINIGUI - Harbour Win32 GUI library Demo
 */

#include "minigui.ch"

FUNCTION Main()

   LOCAL aButtonBackColor1, aButtonBackColor2, aButtonBackColor3, aButtonBackColor4, aButtonBackColor5
   LOCAL aGradientFill1, aGradientFill2, aGradientFill3, aGradientFill4, aGradientFill5, nProcenatGrad
   LOCAL aButtonBackColor := {}, aGradientFill := {}, aButtonNames := {}

   aButtonBackColor1 := { 21, 10, 245 }
   nProcenatGrad := 10
   aGradientFill1 := GetGradient( aButtonBackColor1, .T., nProcenatGrad, , , 2, .F. )
   AAdd( aButtonBackColor, aButtonBackColor1 )
   AAdd( aGradientFill, aGradientFill1 )

   aButtonBackColor2 := { 222, 180, 250 }
   nProcenatGrad := 15
   aGradientFill2 := GetGradient( aButtonBackColor2, .T., nProcenatGrad, , , 2, .F. )
   AAdd( aButtonBackColor, aButtonBackColor2 )
   AAdd( aGradientFill, aGradientFill2 )

   aButtonBackColor3 := { 68, 146, 208 }
   nProcenatGrad := 20
   aGradientFill3 := GetGradient( aButtonBackColor3, .T., nProcenatGrad, , , 2, .F. )
   AAdd( aButtonBackColor, aButtonBackColor3 )
   AAdd( aGradientFill, aGradientFill3 )

   aButtonBackColor4 := { 22, 91, 194 }
   nProcenatGrad := 25
   aGradientFill4 := GetGradient( aButtonBackColor4, .T., nProcenatGrad, , , 2, .F. )
   AAdd( aButtonBackColor, aButtonBackColor4 )
   AAdd( aGradientFill, aGradientFill4 )

   aButtonBackColor5 := { 22, 91, 194 }
   nProcenatGrad := 30
   aGradientFill5 := GetGradient( aButtonBackColor5, .T., nProcenatGrad, , , 2, .T. )
   AAdd( aButtonBackColor, aButtonBackColor5 )
   AAdd( aGradientFill, aGradientFill5 )

   AEval( Array( 5 ), {|x, i| AAdd( aButtonNames, 'Button_' + hb_ntos( i ) ), x := NIL } )

   DEFINE WINDOW Test ;
      WIDTH 610 ;
      HEIGHT 300 ;
      TITLE 'Button Gradient Test' ;
      MAIN

      // Button Bar with gradient color
      CreateButtonBar( 50, 50, aButtonNames, aButtonBackColor, aGradientFill, 80, 50, 20 )

      // Button Bar with solid color
      CreateButtonBar( 170, 180, { "OK", "Cancel", "Exit" }, ;
         {{ 190, 210, 240 }, { 190, 210, 240 }, { 190, 210, 240 }}, NIL, 70, 24, 10, BLACK, BLUE, ;
         {{ 200, 245, 220 }, { 200, 245, 220 }, { 200, 245, 220 }}, { NIL, NIL, "DoMethod( 'Test', 'Release' )" } )

      ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   CENTER WINDOW Test
   ACTIVATE WINDOW Test

RETURN NIL


FUNCTION CreateButtonBar( nRow, nCol, aButtonName, aBackColor, aGradient, nWidth, nHeight, nGap, ;
      aFontColor, aFocusedColor, aHoverColor, aButtonAction )

   LOCAL cButtonName, i, aHColor, aBColor, cAction
   LOCAL cParentName := ThisWindow.Name

   DEFAULT aFontColor TO WHITE
   DEFAULT aFocusedColor TO YELLOW

   FOR i := 1 TO Len( aButtonName )

      cButtonName := aButtonName[ i ]

      DEFINE BUTTONEX ( cButtonName )
           ROW nRow
           COL nCol
           WIDTH nWidth
           HEIGHT nHeight
           CAPTION cButtonName
           BACKCOLOR aBackColor[ i ]
           FONTCOLOR aFontColor
           IF aGradient <> NIL
              GRADIENTFILL aGradient[ i ]
           ENDIF
           NOTRANSPARENT .F.
           HORIZONTAL .F.
           NOHOTLIGHT .F.
           NOXPSTYLE .T.
           IF aGradient <> NIL
              ONMOUSEHOVER this.FontColor := aFocusedColor
              ONMOUSELEAVE iif( ThisWindow.FocusedControl == this.Name, , this.FontColor := aFontColor )
           ELSE
              HANDCURSOR .T.
              aHColor := aHoverColor[ i ]
              aBColor := aBackColor[ i ]
              ONMOUSEHOVER ( this.FontColor := aFocusedColor, this.BackColor := aHColor )
              ONMOUSELEAVE ( iif( ThisWindow.FocusedControl == this.Name, , this.FontColor := aFontColor ), this.BackColor := aBColor )
           ENDIF
      END BUTTONEX

      IF aButtonAction <> NIL .AND. aButtonAction[ i ] <> NIL
         cAction := aButtonAction[ i ]
         SetProperty( cParentName, cButtonName, "Action", hb_macroBlock( cAction ) )
      ELSE
         SetProperty( cParentName, cButtonName, "Action", hb_macroBlock( "AlertInfo( '" + cButtonName + " pressed' )" ) )
      ENDIF

      nCol += GetWindowWidth( GetControlHandle( cButtonName, cParentName ) ) + nGap

   NEXT

RETURN NIL


/*
 * Function GetGradient() returns gradient info for input color depending on number of gradients (1 or 2),
 * percentage of color change (to lighter and darker color from input color).
*/
FUNCTION GetGradient( aBackColor, lAutoGradient, nGradPercent, aGradFrom, aGradTo, nGradPreliv, lInvert )

   LOCAL aColorFrom, aColorTo, nGradientFrom, nGradientTo, nTmp, aGradientFill

   DEFAULT nGradPreliv TO 2
   DEFAULT lInvert TO .T.

   IF lAutoGradient
      aColorFrom := Lighter( aBackColor, 100 - nGradPercent )
      aColorTo := Darker( aBackColor, 100 - nGradPercent )
   ELSE
      aColorFrom := aGradFrom
      aColorTo := aGradTo
   ENDIF

   nGradientFrom := RGB( aColorFrom[ 1 ], aColorFrom[ 2 ], aColorFrom[ 3 ] )
   nGradientTo := RGB( aColorTo[ 1 ], aColorTo[ 2 ], aColorTo[ 3 ] )

   IF lInvert
      nTmp := nGradientTo
      nGradientTo := nGradientFrom
      nGradientFrom := nTmp
   ENDIF

   aGradientFill := iif( nGradPreliv == 1, ;
      { { 1, nGradientFrom, nGradientTo } }, ;
      { { 0.5, nGradientFrom, nGradientTo }, { 0.5, nGradientTo, nGradientFrom } } )

RETURN aGradientFill
