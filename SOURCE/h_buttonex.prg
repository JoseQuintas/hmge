/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

BUTTONEX Control Source Code
Copyright 2005 Jacek Kubica <kubica@wssk.wroc.pl>

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2025, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2021 Alexander S.Kresin <alex@kresin.ru>

 ---------------------------------------------------------------------------*/

#include "i_winuser.ch"
#include "minigui.ch"

#define BP_PUSHBUTTON 1

#define PBS_NORMAL 1
#define PBS_HOT 2
#define PBS_PRESSED 3
#define PBS_DISABLED 4
#define PBS_DEFAULTED 5

#define DT_TOP 0
#define DT_LEFT 0
#define DT_CENTER 1
#define DT_RIGHT 2
#define DT_VCENTER 4
#define DT_BOTTOM 8
#define DT_SINGLELINE 32

/* Aspects for owner buttons */
#define OBT_HORIZONTAL    0
#define OBT_VERTICAL      1
#define OBT_LEFTTEXT      2
#define OBT_UPTEXT        4
#define OBT_HOTLIGHT      8
#define OBT_FLAT          16
#define OBT_NOTRANSPARENT 32
#define OBT_NOXPSTYLE     64
#define OBT_ADJUST       128

#if defined( __XHARBOUR__ ) .OR. ( __HARBOUR__ - 0 < 0x030200 )
  #xtranslate hb_UAt( <c>, <n> ) => At( <c>, <n> )
#endif

STATIC lXPThemeActive := .F.

*-----------------------------------------------------------------------------*
FUNCTION _DefineOwnerButton ( ControlName, ParentForm, x, y, Caption, ProcedureName, ;
      w, h, image, tooltip, gotfocus, lostfocus, flat, notrans, HelpId, invisible, ;
      notabstop, default, icon, fontname, fontsize, bold, italic, underline, strikeout, ;
      lvertical, lefttext, uptext, aRGB_bk, aRGB_font, lnohotlight, lnoxpstyle, ;
      ladjust, handcursor, imagewidth, imageheight, aGradInfo, lhorizontal, bInit, cKey )
*-----------------------------------------------------------------------------*
   LOCAL ControlHandle , FontHandle
   LOCAL aRet, aBmp
   LOCAL cParentForm
   LOCAL cPicture
   LOCAL mVar
   LOCAL k
   LOCAL oc := NIL, ow := NIL
#ifdef _OBJECT_
   ow := oDlu2Pixel()
#endif

   hb_default( @w, 100 )
   hb_default( @h, 28 )
   hb_default( @Caption, "" )
   hb_default( @flat, .F. )
   hb_default( @notrans, .F. )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @lvertical, .F. )
   hb_default( @lefttext, .F. )
   hb_default( @uptext, .F. )
   hb_default( @lnohotlight, .F. )
   hb_default( @lnoxpstyle, .F. )
   hb_default( @ladjust, .F. )
   hb_default( @imagewidth, -1 )
   hb_default( @imageheight, -1 )

   IF ladjust  // ignore CAPTION clause when ADJUST is defined
      Caption := ""
   ENDIF

   IF _HMG_ToolBarActive
      RETURN Nil
   ENDIF

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentForm := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentForm := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentForm )
      MsgMiniGuiError ( "Window: " + IFNIL( ParentForm, "Parent", ParentForm ) + " is not defined." )
   ENDIF

   IF ISCHAR ( ControlName ) .AND. ControlName == "0"
      ControlName := HMG_GetUniqueName()
   ENDIF

   IF _IsControlDefined ( ControlName, ParentForm )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   IF ! Empty( image ) .AND. ! Empty( icon )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + ". Either bitmap or icon must be specified." )
   ENDIF

   cPicture := IFEMPTY( icon, image, icon )
   IF ISARRAY( cPicture )
      image := cPicture [1]
   ENDIF

   IF aRGB_bk != NIL .AND. ! IsArrayRGB ( aRGB_bk )
      aRGB_bk := nRGB2Arr( aRGB_bk )
   ENDIF

   IF aRGB_font != NIL .AND. ! IsArrayRGB ( aRGB_font )
      aRGB_font := nRGB2Arr( aRGB_font )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm := GetFormHandle ( ParentForm )

   aRet := InitOwnerButton ( ParentForm, Caption, 0, x, y, w, h, image, flat, notrans, invisible, notabstop, default, icon, imagewidth, imageheight )

   ControlHandle := aRet [1]

   IF ! Empty( image ) .AND. Empty( aRet [2] )
      aRet [2] := iif( _HMG_IsThemed .AND. hb_UAt ( ".", image ) == 0 .AND. imagewidth < 0 .AND. imageheight < 0, ;
         C_GetResPicture ( image ), _SetBtnPicture ( ControlHandle, image, imagewidth, imageheight ) )
   ENDIF

   IF FontHandle != 0
      _SetFontHandle( ControlHandle, FontHandle )
   ELSE
      __defaultNIL( @FontName, _HMG_DefaultFontName )
      __defaultNIL( @FontSize, _HMG_DefaultFontSize )
      FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
   ENDIF

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
   ENDIF

   IF tooltip != NIL
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   k := _GetControlFree()

#ifdef _NAMES_LIST_
   _SetNameList( mVar , k )
#else
   Public &mVar. := k
#endif

   _HMG_aControlType [k] :=  "OBUTTON"
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlHandles [k] :=   ControlHandle
   _HMG_aControlParenthandles [k] :=   ParentForm
   _HMG_aControlIds [k] :=   0
   _HMG_aControlProcedures [k] :=   ProcedureName
   _HMG_aControlPageMap [k] :=   {}
   _HMG_aControlValue [k] :=   aGradInfo
   _HMG_aControlInputMask [k] :=   hb_defaultValue( handcursor, .F. )
   _HMG_aControllostFocusProcedure [k] :=   lostfocus
   _HMG_aControlGotFocusProcedure [k] :=   gotfocus
   _HMG_aControlChangeProcedure [k] :=   ""
   _HMG_aControlDeleted [k]   :=   FALSE
   _HMG_aControlBkColor  [k]  :=  aRGB_bk
   _HMG_aControlFontColor [k] :=  aRGB_font
   _HMG_aControlDblClick  [k] :=  default
   _HMG_aControlHeadClick [k] :=  { imagewidth, imageheight }
   _HMG_aControlRow [k]       :=  y
   _HMG_aControlCol [k]       :=  x
   _HMG_aControlWidth [k]     :=  w
   _HMG_aControlHeight [k]    :=  h
   _HMG_aControlSpacing [k]   :=  iif( lvertical, 1, 0 ) + iif( lefttext, OBT_LEFTTEXT, 0 ) + iif( uptext, OBT_UPTEXT, 0 ) + iif( !lnohotlight, OBT_HOTLIGHT, 0 ) + iif( flat, OBT_FLAT, 0 ) + iif( notrans, OBT_NOTRANSPARENT, 0 ) + iif( lnoxpstyle, OBT_NOXPSTYLE, 0 ) + iif( ladjust, OBT_ADJUST, 0 )
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture [k]   :=   cPicture
   _HMG_aControlContainerHandle [k] :=   0
   _HMG_aControlFontName [k]    := fontname
   _HMG_aControlFontSize [k]    := fontsize
   _HMG_aControlFontAttributes[k] := { bold, italic, underline, strikeout }
   _HMG_aControlToolTip [k]     :=  tooltip
   _HMG_aControlRangeMin [k]    :=  hb_defaultValue( lhorizontal, .F. )
   _HMG_aControlRangeMax [k]    :=  { iif( lnohotlight, 2, 0 ), .F. }  // used for mouse hot tracking !!
   _HMG_aControlCaption [k]     :=  Caption
   _HMG_aControlVisible [k]     :=  iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId [k]      :=  HelpId
   _HMG_aControlFontHandle [k]  :=  FontHandle
   _HMG_aControlBrushHandle [k] :=  aRet [2]  // handle to an Image (Icon or Bitmap)
   _HMG_aControlEnabled [k]     :=  .T.
   _HMG_aControlMiscData1 [k]   :=  IFEMPTY( icon, 0, 1 )  // 0 - bitmap  1 - icon
   _HMG_aControlMiscData2 [k]   :=  ''

   IF ! Empty( _HMG_aControlBrushHandle [k] ) .AND. imagewidth < 0 .AND. imageheight < 0

      SWITCH _HMG_aControlMiscData1 [k]
      CASE 0
         aBmp := GetBitmapSize ( _HMG_aControlBrushHandle [k] )
         EXIT
      CASE 1
         aBmp := GetIconSize ( _HMG_aControlBrushHandle [k] )
      ENDSWITCH

      _HMG_aControlHeadClick [k] := { aBmp[1], aBmp[2] }

   ENDIF

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
#ifdef _OBJECT_
      ow := _WindowObj ( ParentForm )
      oc := _ControlObj( ControlHandle )
#endif
   ENDIF

   Do_ControlEventProcedure ( bInit, k, ow, oc )

   _SetHotKeyByName ( cParentForm, ckey, ProcedureName )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION OBTNEVENTS( hWnd, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := AScan( _HMG_aControlHandles, hWnd ) ) > 0 .AND. _HMG_aControlType [i] == "OBUTTON"

      wParam := _HMG_aControlRangeMax [i][1]
      lParam := _HMG_aControlRangeMax [i][2]

      SWITCH nMsg

      CASE WM_MOUSEMOVE

         IF _HMG_aControlInputMask [i]
            RC_CURSOR( "MINIGUI_FINGER" )
         ENDIF

         IF ! lParam

            _HMG_aControlRangeMax [i][2] := .T.

            IF AND( _HMG_aControlSpacing [i], OBT_HOTLIGHT ) == OBT_HOTLIGHT .OR. _HMG_IsThemed

               _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )

               IF wParam == 0
                  InvalidateRect( hWnd, 0 )
                  _HMG_aControlRangeMax [i][1] := 1
               ENDIF

            ENDIF

         ENDIF
         EXIT

      CASE WM_MOUSELEAVE

         IF lParam

            _HMG_aControlRangeMax [i][2] := .F.

            _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )

            IF AND( _HMG_aControlSpacing [i], OBT_HOTLIGHT ) == OBT_HOTLIGHT .OR. lXPThemeActive

               IF wParam == 1
                  _HMG_aControlRangeMax [i][1] := 0
                  InvalidateRect( hWnd, 0 )
               ENDIF

            ENDIF

         ENDIF

      ENDSWITCH

   ENDIF

RETURN 0

*-----------------------------------------------------------------------------*
FUNCTION OwnButtonPaint( pdis )
*-----------------------------------------------------------------------------*
   LOCAL hDC
   LOCAL itemState
   LOCAL itemAction
   LOCAL i
   LOCAL rgbTrans
   LOCAL hWnd
   LOCAL lFlat
   LOCAL lNotrans
   LOCAL oldBkMode
   LOCAL oldTextColor
   LOCAL hOldFont
   LOCAL hBrush
   LOCAL nFreeSpace
   LOCAL x1
   LOCAL y1
   LOCAL x2
   LOCAL y2
   LOCAL xp1
   LOCAL yp1
   LOCAL xp2
   LOCAL yp2
   LOCAL aBmp := {}
   LOCAL aMetr
   LOCAL aBtnRc
   LOCAL aBtnClipRc
   LOCAL aDarkColor
   LOCAL lDisabled
   LOCAL lSelected
   LOCAL lFocus
   LOCAL lDrawEntire
   LOCAL loFocus
   LOCAL loSelect
   LOCAL hTheme
   LOCAL nStyle
   LOCAL lnoxpstyle
   LOCAL lnoadjust
   LOCAL lXPThemeActive := .F.
   LOCAL pozYpic
   LOCAL pozYtext := 0
   LOCAL xPoz
   LOCAL nCRLF
   LOCAL lGradient
   LOCAL aGradient
   LOCAL lvertical

   hDC := GETOWNBTNDC( pdis )

   IF Empty( hDC ) .OR. GETOWNBTNCTLTYPE( pdis ) <> ODT_BUTTON
      RETURN ( 1 )
   ENDIF

   itemAction := GETOWNBTNITEMACTION ( pdis )
   lDrawEntire := ( AND( itemAction, ODA_DRAWENTIRE ) == ODA_DRAWENTIRE )
   loFocus := ( AND( itemAction, ODA_FOCUS ) == ODA_FOCUS )
   loSelect := ( AND( itemAction, ODA_SELECT ) == ODA_SELECT )

   IF ! lDrawEntire .AND. ! loFocus .AND. ! loSelect
      RETURN ( 1 )
   ENDIF

   hWnd := GETOWNBTNHANDLE( pdis )
   aBtnRc := GETOWNBTNRECT( pdis )
   itemState := GETOWNBTNSTATE( pdis )

   i := AScan ( _HMG_aControlHandles , hWnd )

   IF ( i <= 0 .OR. _HMG_aControlType[ i ] <> "OBUTTON" )
      RETURN ( 1 )
   ENDIF

   nCRLF := hb_tokenCount( _HMG_aControlCaption[ i ], CRLF )

   lDisabled := ( AND( itemState, ODS_DISABLED ) == ODS_DISABLED )
   lSelected := ( AND( itemState, ODS_SELECTED ) == ODS_SELECTED )
   lFocus := ( AND( itemState, ODS_FOCUS ) == ODS_FOCUS )
   lFlat := ( AND( _HMG_aControlSpacing [ i ], OBT_FLAT ) == OBT_FLAT )
   lNotrans := ( AND( _HMG_aControlSpacing [ i ], OBT_NOTRANSPARENT ) == OBT_NOTRANSPARENT )
   lnoxpstyle := ( AND( _HMG_aControlSpacing [ i ], OBT_NOXPSTYLE ) == OBT_NOXPSTYLE )
   lnoadjust := ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )

   IF ! lNotrans

      rgbTrans := NIL

   ELSE

      IF IsArrayRGB( _HMG_aControlBkColor [ i ] ) .AND. ! lXPThemeActive
         rgbTrans := RGB( _HMG_aControlBkColor [ i, 1 ], _HMG_aControlBkColor [ i, 2 ], _HMG_aControlBkColor [ i, 3 ] )
      ELSE
         rgbTrans := GetSysColor ( COLOR_BTNFACE )
      ENDIF

   ENDIF

   aGradient := _HMG_aControlValue [i]
   lGradient := ( ISARRAY( aGradient ) .AND. ! Empty( _HMG_aControlBkColor [i] ) )
   lvertical := ( _HMG_aControlRangeMin [i] == .F. )

   IF ! lnoxpstyle .AND. _HMG_IsThemed .AND. ! lGradient

      lXPThemeActive := .T.
      nStyle := PBS_NORMAL

      IF AND( itemState, ODS_HOTLIGHT ) == ODS_HOTLIGHT .OR. _HMG_aControlRangeMax [i][1] == 1
         nStyle := PBS_HOT
      ELSEIF lFocus
         nStyle := PBS_DEFAULTED
      ENDIF

      IF lDisabled
         nStyle := PBS_DISABLED
      ENDIF

      IF lSelected
         nStyle := PBS_PRESSED
      ENDIF

      aBtnClipRc := AClone( aBtnRc )
      aBtnClipRc[ 3 ] += 1
      aBtnClipRc[ 4 ] += 1

      hTheme := OpenThemeData( hWnd, ToUnicode( "BUTTON" ) )
      DrawThemeBackground( hTheme, hDC, BP_PUSHBUTTON, nStyle, aBtnRc, aBtnClipRc )
      CloseThemeData( hTheme )

   ELSE

      DrawButton( hDC, iif( lFocus .OR. _HMG_aControlRangeMax [ i ][ 1 ] == 1, 1, 0 ), ;
         DFCS_BUTTONPUSH + iif( lSelected, DFCS_PUSHED, 0 ) + iif( lDisabled, DFCS_INACTIVE, 0 ) + iif( lflat, DFCS_FLAT, 0 ), ;
         pdis, iif( AND( _HMG_aControlSpacing [ i ], OBT_HOTLIGHT ) == OBT_HOTLIGHT, _HMG_aControlRangeMax [ i ][ 1 ], 2 ), iif( lflat, 1, 0 ) )

   ENDIF

   hOldFont := SelectObject( hDC, _HMG_aControlFontHandle [ i ] )
   aMetr := GetTextMetric( hDC )
   oldBkMode := SetBkMode( hDC, TRANSPARENT )
   oldTextColor := SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ), GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ), GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )

   IF ! lDisabled

      IF Empty( _HMG_aControlFontColor [ i ] ) .OR. ! IsArrayRGB( _HMG_aControlFontColor [ i ] )
         SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ), GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ), GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )
      ELSE
         SetTextColor( hDC, _HMG_aControlFontColor [ i, 1 ], _HMG_aControlFontColor [ i, 2 ], _HMG_aControlFontColor [ i, 3 ] )
      ENDIF

      IF ! Empty( _HMG_aControlBkColor [ i ] ) .AND. ! lXPThemeActive

         xp1 := aBtnRc[ 1 ]
         xp2 := aBtnRc[ 2 ]
         yp1 := aBtnRc[ 3 ]
         yp2 := aBtnRc[ 4 ]

         // paint button background

         IF lGradient

            IF Len( aGradient [ 1 ] ) == 2
               ReplaceGradInfo( aGradient, 1, 1 )
               ReplaceGradInfo( aGradient, 1, 2 )
            ENDIF

            IF lSelected

               IF Len( aGradient [ 1 ] ) == 3
                  aDarkColor := _HMG_aControlBkColor [ i ]
                  IF IsArrayRGB( _HMG_aControlBkColor [ i ] ) .AND. ValType( _HMG_aControlBkColor [ i, 1 ] ) == "N"
                     _HMG_aControlBkColor [ i ] := { { 1, _HMG_aControlBkColor [ i ], Darker( _HMG_aControlBkColor [ i ], 82 ) } }
                  ENDIF
                  _GradientFill( hDC, xp2 + 2, xp1 + 2, yp2 - 2, yp1 - 2, _HMG_aControlBkColor [ i ], lvertical )
                  _HMG_aControlBkColor [ i ] := aDarkColor
               ELSE
                  hBrush := CreateButtonBrush( hDC, yp1 - 2, yp2 - 2, aGradient [ 1 ][ 2 ], aGradient [ 1 ][ 1 ] )
                  FillRect( hDC, xp1 + 2, xp2 + 2, yp1 - 2, yp2 - 2, hBrush )
                  DeleteObject( hBrush )
               ENDIF

            ELSEIF ! ( _HMG_aControlRangeMax [ i ][ 1 ] == 1 )

               IF Len( aGradient [ 1 ] ) == 3
                  _GradientFill( hDC, xp2 + 1, xp1 + 1, yp2 - 1, yp1 - 1, aGradient, lvertical )
               ELSE
                  hBrush := CreateButtonBrush( hDC, yp1 - 1, yp2 - 1, aGradient [ 1 ][ 1 ], aGradient [ 1 ][ 2 ] )
                  FillRect( hDC, xp1 + 1, xp2 + 1, yp1 - 1, yp2 - 1, hBrush )
                  DeleteObject( hBrush )
               ENDIF

            ELSE

               IF Len( aGradient [ 1 ] ) == 3
                  _GradientFill( hDC, xp2 + 1, xp1 + 1, yp2 - 1, yp1 - 1, ;
                     iif( Len( aGradient ) == 1, InvertGradInfo( aGradient ), ;
                     iif( ISARRAY( _HMG_aControlBkColor [ i, 1 ] ), _HMG_aControlBkColor [ i ], ModifGradInfo( aGradient ) ) ), lvertical )
               ELSE
                  hBrush := CreateButtonBrush( hDC, yp1 - 1, yp2 - 1, aGradient [ 1 ][ 2 ], aGradient [ 1 ][ 1 ] )
                  FillRect( hDC, xp1 + 1, xp2 + 1, yp1 - 1, yp2 - 1, hBrush )
                  DeleteObject( hBrush )
               ENDIF

            ENDIF

         ELSE

            IF lSelected
               aDarkColor := Darker( { _HMG_aControlBkColor [ i, 1 ], _HMG_aControlBkColor [ i, 2 ], _HMG_aControlBkColor [ i, 3 ] }, 97 )
            ELSE
               aDarkColor := { _HMG_aControlBkColor [ i, 1 ], _HMG_aControlBkColor [ i, 2 ], _HMG_aControlBkColor [ i, 3 ] }
            ENDIF

            hBrush := CreateSolidBrush( aDarkColor [1], aDarkColor [2], aDarkColor [3] )

            IF lflat

               IF ! lfocus .AND. ! lSelected .AND. ! ( _HMG_aControlRangeMax [ i ][ 1 ] == 1 )
                  FillRect( hDC, xp1 + 1, xp2 + 1, yp1 - 1, yp2 - 1, hBrush )
               ELSE
                  FillRect( hDC, xp1 + 2, xp2 + 2, yp1 - 2, yp2 - 2, hBrush )
               ENDIF

            ELSE

               FillRect( hDC, xp1 + 2, xp2 + 2, yp1 - 3, yp2 - 3, hBrush )

            ENDIF

            DeleteObject( hBrush )

         ENDIF

      ENDIF

   ENDIF

   IF ! Empty( _HMG_aControlBrushHandle [ i ] )

      SWITCH _HMG_aControlMiscData1 [ i ]
      CASE 0
         aBmp := GetBitmapSize( _HMG_aControlBrushHandle [ i ] )
         EXIT
      CASE 1
         aBmp := GetIconSize( _HMG_aControlBrushHandle [ i ] )
      ENDSWITCH

   ENDIF

   IF AND( _HMG_aControlSpacing [ i ], OBT_VERTICAL ) == OBT_VERTICAL  // vertical text/picture aspect

      y2 := aMetr[ 1 ] * nCRLF
      x2 := aBtnRc[ 3 ] - 2

      xp2 := iif( ! Empty( aBmp ), aBmp[ 1 ], 0 ) // picture width
      yp2 := iif( ! Empty( aBmp ), aBmp[ 2 ], 0 ) // picture height
      xp1 := Round( ( aBtnRc[ 3 ] / 2 ) - ( xp2 / 2 ), 0 )

      IF Empty( nCRLF )
         nFreeSpace := Round( ( aBtnRc[ 4 ] - 4 - ( aMetr[ 4 ] + yp2 ) ) / 3, 0 )
         nCRLF := 1
      ELSE
         nFreeSpace := Round( ( aBtnRc[ 4 ] - 4 - ( y2 + yp2 ) ) / 3, 0 )
      ENDIF

      IF ! Empty( _HMG_aControlCaption[ i ] )  // button has caption

         IF ! Empty( _HMG_aControlBrushHandle [ i ] )
            IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_UPTEXT ) == OBT_UPTEXT )  // upper text aspect not set
               pozYpic := Max( aBtnRc[ 2 ] + nFreeSpace, 5 )
               pozYtext := aBtnRc[ 2 ] + iif( ! Empty( aBmp ), nFreeSpace, 0 ) + yp2 + iif( ! Empty( aBmp ), nFreeSpace, 0 )
            ELSE
               pozYtext := Max( aBtnRc[ 2 ] + nFreeSpace, 5 )
               aBtnRc[ 4 ] := nFreeSpace + ( ( aMetr[ 1 ] ) * nCRLF ) + nFreeSpace
               pozYpic := aBtnRc[ 4 ]
            ENDIF
         ELSE
            pozYpic := 0
            pozYtext := Round( ( aBtnRc[ 4 ] - y2 ) / 2, 0 )
         ENDIF

      ELSE  // button without caption

         IF lnoadjust
            pozYpic := Round( ( ( aBtnRc[ 4 ] / 2 ) - ( yp2 / 2 ) ), 0 )
            pozYtext := 0
         ELSE  // strech image
            pozYpic := 1
         ENDIF

      ENDIF

      IF ! lDisabled

         IF lSelected  // vertical selected

            IF ! lXPThemeActive
               xp1 ++
               xPoz := 2
               pozYtext ++
               pozYpic ++
            ELSE
               xPoz := 0
            ENDIF

            IF lnoadjust
               DrawGlyph( hDC, xp1, pozYpic , xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], xPoz , pozYtext - 1 , x2, aBtnRc[ 4 ], DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .T. )
            ENDIF

         ELSE  // vertical non selected

            IF lnoadjust
               DrawGlyph( hDC, xp1, pozYpic, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ],  0 , pozYtext - 1 , x2, aBtnRc[ 4 ], DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .T. )
            ENDIF

         ENDIF

      ELSE  // vertical disabled

         IF lnoadjust
            DrawGlyph( hDC, xp1, pozYpic, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , , .T. , .F. )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetGreen ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetBlue ( GetSysColor ( COLOR_3DHILIGHT ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], 2, pozYtext + 1 , x2, aBtnRc[ 4 ] + 1, DT_CENTER )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DSHADOW ) ) , GetGreen ( GetSysColor ( COLOR_3DSHADOW ) ) , GetBlue ( GetSysColor ( COLOR_3DSHADOW ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], 0, pozYtext, x2, aBtnRc[ 4 ], DT_CENTER )
         ELSE
            DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , , .T. , .T. )
         ENDIF

      ENDIF

   ELSE

      y1 := Round( aBtnRc[ 4 ] / 2, 0 ) - ( aMetr[ 1 ] - 10 )
      y2 := y1 + aMetr[ 1 ]
      x2 := aBtnRc[ 3 ] - 2

      IF ! Empty( _HMG_aControlBrushHandle [ i ] ) // horizontal

         xp2 := iif( ! Empty( aBmp ), aBmp[ 1 ], 0 ) // picture width
         yp2 := iif( ! Empty( aBmp ), aBmp[ 2 ], 0 ) // picture height
         yp1 := Round( aBtnRc[ 4 ] / 2 - yp2 / 2, 0 )

         IF ! Empty( _HMG_aControlCaption[ i ] )

            lDrawEntire := ( aBtnRc[ 3 ] > 109 ) .AND. ( aBtnRc[ 4 ] - yp2 > 16 )
            nStyle := xp2 / 2 - iif( xp2 > 24, 8, 0 )

            IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_LEFTTEXT ) == OBT_LEFTTEXT )

               xp1 := 5 + iif( lDrawEntire, nStyle, 0 )
               x1 := aBtnRc[ 1 ] + xp1 + xp2

            ELSE

               xp1 := aBtnRc[ 3 ] - xp2 - 5 - iif( lDrawEntire, nStyle, 0 )
               x1 := 3
               x2 := aBtnRc[ 3 ] - xp2 - iif( lDrawEntire, xp2 / 2 + 5, 0 )

            ENDIF

         ELSE

            xp1 := Round( aBtnRc[ 3 ] / 2 - xp2 / 2, 0 )
            x1 := aBtnRc[ 1 ]

         ENDIF

      ELSE

         xp1 := 2
         xp2 := 0
         yp1 := 0
         yp2 := 0

         x1 := aBtnRc[ 1 ] + xp1

      ENDIF

      IF lnoadjust
         y1 := Max( ( ( aBtnRc[ 4 ] / 2 ) - ( nCRLF * aMetr[ 1 ] ) / 2 ) - 1, 1 )
         y2 := ( aMetr[ 1 ] + aMetr[ 7 ] ) * nCRLF
      ENDIF

      IF ! lDisabled

         IF lSelected

            IF ! lXPThemeActive
               x1 += 2
               xp1 ++
               yp1 ++
            ENDIF

            IF lnoadjust
               DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans, .F. , .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1 + 1, x2, y1 + y2, DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .T. )
            ENDIF

         ELSE

            IF lnoadjust
               DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1, x2, y1 + y2, DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .T. )
            ENDIF

         ENDIF

      ELSE  // disabled horizontal

         IF lnoadjust
            DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , , .T. , .F. )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetGreen ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetBlue ( GetSysColor ( COLOR_3DHILIGHT ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], x1 + 1, y1 + 1, x2 + 1, y1 + y2 + 1, DT_CENTER )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DSHADOW ) ) , GetGreen ( GetSysColor ( COLOR_3DSHADOW ) ) , GetBlue ( GetSysColor ( COLOR_3DSHADOW ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1, x2, y1 + y2, DT_CENTER )
         ELSE
            DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , , .T. , .T. )
         ENDIF

      ENDIF

   ENDIF

   IF ( lSelected .OR. lFocus ) .AND. ! lDisabled .AND. ! lXPThemeActive
      SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ) , GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ) , GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )
      DrawFocusRect( pdis )
   ENDIF

   SelectObject( hDC, hOldFont )
   SetBkMode( hDC, oldBkMode )
   SetTextColor( hDC, oldTextColor )

RETURN ( 1 )

*-----------------------------------------------------------------------------*
STATIC FUNCTION ToUnicode( cString )
*-----------------------------------------------------------------------------*
   LOCAL cOutString As String
   LOCAL Char

   FOR EACH Char IN cString
      cOutString += Char + Chr( 0 )
   NEXT

RETURN ( cOutString + Chr( 0 ) )

*-----------------------------------------------------------------------------*
FUNCTION _SetBtnPictureMask( hWnd, i )
*-----------------------------------------------------------------------------*
   LOCAL hDC := GetDC( hWnd )
   LOCAL aBtnRc := Array( 4 )
   LOCAL aBMP
   LOCAL x
   LOCAL y

   IF Empty( hDC ) .OR. Empty( _HMG_aControlBrushHandle [i] )
      RETURN NIL
   ENDIF

   aBtnRc [1] := _HMG_aControlRow    [i]
   aBtnRc [2] := _HMG_aControlCol    [i]
   aBtnRc [3] := _HMG_aControlWidth  [i]
   aBtnRc [4] := _HMG_aControlHeight [i]

   aBmp := GetBitmapSize( _HMG_aControlBrushHandle [i] )
   x := aBtnRc [3] / 2 - aBmp [1] / 2
   y := aBtnRc [4] / 2 - aBmp [2] / 2

   DrawGlyphMask( hDC, x, y, aBmp [1], aBmp [2], _HMG_aControlBrushHandle [i], , .T. , .F. , hWnd )

   ReleaseDC( hWnd, hDC )

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _DestroyBtnPictureMask( hWnd, i )
*-----------------------------------------------------------------------------*
   LOCAL MaskHwnd := _GetBtnPictureHandle( hWnd )

   IF ! Empty( MaskHwnd ) .AND. MaskHwnd <> _HMG_aControlBrushHandle [i]
      DeleteObject( MaskHwnd )
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _DestroyBtnPicture( hWnd, i )
*-----------------------------------------------------------------------------*
   LOCAL BtnPicHwnd := _GetBtnPictureHandle( hWnd )

   IF ! Empty( BtnPicHwnd ) .AND. BtnPicHwnd == _HMG_aControlBrushHandle [i]
      DeleteObject( BtnPicHwnd )
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION Darker( aColor, Percent )
*-----------------------------------------------------------------------------*
   LOCAL aDark := Array( 3 )

   Percent /= 100

   aDark [1] := Round( aColor [1] * Percent, 0 )
   aDark [2] := Round( aColor [2] * Percent, 0 )
   aDark [3] := Round( aColor [3] * Percent, 0 )

RETURN aDark

*-----------------------------------------------------------------------------*
FUNCTION Lighter( aColor, Percent )
*-----------------------------------------------------------------------------*
   LOCAL aLight := Array( 3 )
   LOCAL Light

   Percent /= 100
   Light := Round( 255 - Percent * 255, 0 )

   aLight [1] := Round( aColor [1] * Percent, 0 ) + Light
   aLight [2] := Round( aColor [2] * Percent, 0 ) + Light
   aLight [3] := Round( aColor [3] * Percent, 0 ) + Light

RETURN aLight

*-----------------------------------------------------------------------------*
STATIC FUNCTION InvertGradInfo( aGradInfo )
*-----------------------------------------------------------------------------*
   LOCAL aGradInvert := {}

   IF ! Empty( aGradInfo ) .AND. ISARRAY( aGradInfo )

      AEval( aGradInfo, { |x| AAdd( aGradInvert, { x[ 1 ], x[ 3 ], x[ 2 ] } ) } )

   ENDIF

RETURN aGradInvert

*-----------------------------------------------------------------------------*
STATIC FUNCTION ModifGradInfo( aGradInfo )
*-----------------------------------------------------------------------------*
   LOCAL aReturn := {}
   LOCAL nClr

   IF ! Empty( aGradInfo ) .AND. ISARRAY( aGradInfo )

      FOR nClr := 1 TO Len( aGradInfo )
         ReplaceGradInfo( aGradInfo, nClr, 2 )
         ReplaceGradInfo( aGradInfo, nClr, 3 )
      NEXT

      AEval( aGradInfo, { |x| AAdd( aReturn, { x[ 1 ], x[ 3 ], x[ 2 ] } ) } )

   ENDIF

RETURN aReturn

*-----------------------------------------------------------------------------*
STATIC PROCEDURE ReplaceGradInfo( aGradInfo, nClr, nItem )
*-----------------------------------------------------------------------------*
   LOCAL aColor

   IF IsArrayRGB( aColor := aGradInfo[ nClr ][ nItem ] )
      aGradInfo[ nClr ][ nItem ] := RGB( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION _GradientFill( hDC, nTop, nLeft, nBottom, nRight, aGradInfo, lVertical )
*-----------------------------------------------------------------------------*
   LOCAL nClr
   LOCAL nClrs
   LOCAL nSize
   LOCAL nSlice

   IF ! Empty( aGradInfo ) .AND. ISARRAY( aGradInfo )

      nClrs := Len( aGradInfo )

      IF lVertical

         nSize := nBottom - nTop + 1

         FOR nClr := 1 TO nClrs

            nSlice = iif( nClr == nClrs, nBottom, ;
               Min( nBottom, nTop + nSize * aGradInfo[ nClr ][ 1 ] - 1 ) )

            ReplaceGradInfo( aGradInfo, nClr, 2 )
            ReplaceGradInfo( aGradInfo, nClr, 3 )

            FillGradient( hDC, nTop, nLeft, nSlice, nRight, .T., aGradInfo[ nClr ][ 2 ], aGradInfo[ nClr ][ 3 ] )

            nTop := nSlice - 1

            IF nTop > nBottom
               EXIT
            ENDIF

         NEXT

      ELSE

         nSize := nRight - nLeft + 1

         FOR nClr := 1 TO nClrs

            nSlice := iif( nClr == nClrs, nRight, ;
               Min( nRight, nLeft + nSize * aGradInfo[ nClr ][ 1 ] - 1 ) )

            ReplaceGradInfo( aGradInfo, nClr, 2 )
            ReplaceGradInfo( aGradInfo, nClr, 3 )

            FillGradient( hDC, nTop, nLeft, nBottom, nSlice, .F., aGradInfo[ nClr ][ 2 ], aGradInfo[ nClr ][ 3 ] )

            nLeft := nSlice - 1

            IF nLeft > nRight
               EXIT
            ENDIF

         NEXT

      ENDIF

   ENDIF

RETURN NIL
