/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

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

#include "minigui.ch"
#include "i_winuser.ch"

*-----------------------------------------------------------------------------*
FUNCTION _DefineImage ( ControlName, ParentFormName, x, y, FileName, w, h, ;
      ProcedureName, tooltip, HelpId, invisible, stretch, aBKColor, transparent, ;
      adjustimage, mouseover, mouseleave, nAlphaLevel, nId, bInit, dblclick, rclick )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , ControlHandle
   LOCAL blInit
   LOCAL mVar
   LOCAL k
   LOCAL Style
   LOCAL BackgroundColor
   LOCAL action := .F.
   LOCAL lDialogInMemory
   LOCAL lCheckAlpha := ISNUMBER( nAlphaLevel )
   LOCAL oc := NIL, ow := NIL

#ifdef _OBJECT_
   ow := oDlu2Pixel()
#endif

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   lDialogInMemory := _HMG_DialogInMemory

   IF .NOT. _IsWindowDefined ( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF ISCHAR ( ControlName ) .AND. ControlName == "0"
      ControlName := HMG_GetUniqueName()
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   hb_default( @w, 0 )
   hb_default( @h, 0 )
   w := IFEMPTY( w, -1, w )
   h := IFEMPTY( h, -1, h )

   hb_default( @stretch, .F. )
   __defaultNIL( @BackgroundColor, -1 )
   hb_default( @transparent, .F. )
   hb_default( @adjustimage, .F. )
   __defaultNIL( @rclick, "" )

   IF ProcedureName == NIL
      ProcedureName := ""
   ELSE
      action := .T.
   ENDIF

   IF IsArrayRGB( aBKColor )
      BackgroundColor := RGB ( aBKColor [1], aBKColor [2], aBKColor [3] )
   ENDIF

   IF ISNUMERIC ( nAlphaLevel ) .AND. ( nAlphaLevel < 0 .OR. nAlphaLevel > 255 )
      nAlphaLevel := 255
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := WS_CHILD + SS_BITMAP

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF action .OR. ISBLOCK( dblclick ) .OR. ISBLOCK( rclick )
         Style += SS_NOTIFY
      ENDIF

      IF lDialogInMemory         //Dialog Template
         //      {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogImage( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "static", style, 0, x, y, w, h, "", HelpId, "", "", , , , , , blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         SetWindowStyle ( ControlHandle, Style, .T. )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      ControlHandle := InitImage ( ParentFormHandle, 0, x, y, invisible, ( action .OR. ISBLOCK( dblclick ) .OR. ISBLOCK( rclick ) .OR. ISSTRING( tooltip ) ), ( ISBLOCK( mouseover ) .OR. ISBLOCK( mouseleave ) ) )

   ENDIF

   IF .NOT. lDialogInMemory

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
      ENDIF

      IF tooltip != NIL
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

   ENDIF

#ifdef _NAMES_LIST_
   _SetNameList( mVar , k )
#else
   Public &mVar. := k
#endif

   _HMG_aControlType  [k] :=  "IMAGE"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlHandles [k] :=  ControlHandle
   _HMG_aControlParentHandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures [k] :=  ProcedureName
   _HMG_aControlPageMap   [k] :=  {}
   _HMG_aControlValue  [k] :=  iif ( stretch, 1, 0 )
   _HMG_aControlInputMask  [k] :=  iif ( transparent, 1, 0 )
   _HMG_aControllostFocusProcedure  [k] :=  mouseleave
   _HMG_aControlGotFocusProcedure  [k] :=  mouseover
   _HMG_aControlChangeProcedure  [k] :=  rclick
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  Nil
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick  [k] :=  lCheckAlpha
   _HMG_aControlHeadClick  [k] :=  dblclick
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight  [k] :=  h
   _HMG_aControlSpacing  [k] :=  BackgroundColor
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  FileName
   _HMG_aControlContainerHandle [k] :=  0
   _HMG_aControlFontName  [k] :=  ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin  [k] :=  w
   _HMG_aControlRangeMax  [k] :=  h
   _HMG_aControlCaption  [k] :=  iif ( adjustimage, 1, 0 )
   _HMG_aControlVisible  [k] :=  iif( invisible, .F. , .T. )
   _HMG_aControlHelpId  [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=   0
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := nAlphaLevel
   _HMG_aControlMiscData2 [k] := ''

   IF .NOT. lDialogInMemory
      InitDialogImage( ParentFormName, ControlHandle, k )
   ENDIF

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
#ifdef _OBJECT_
      ow := _WindowObj ( ParentFormHandle )
      oc := _ControlObj( ControlHandle )
#endif
   ENDIF

   Do_ControlEventProcedure ( bInit, k, ow, oc )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogImage( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*

   IF ValType( ParentName ) <> 'U'

      _HMG_aControlBrushHandle [k] := C_SetPicture ( ControlHandle , _HMG_aControlPicture [k] , _HMG_aControlWidth [k] , ;
         _HMG_aControlHeight [k] , _HMG_aControlValue [k] , _HMG_aControlInputMask [k] , _HMG_aControlSpacing [k] , ;
         _HMG_aControlCaption [k] , _HMG_aControlDblClick [k] .AND. HasAlpha( _HMG_aControlPicture [k] ) , _HMG_aControlMiscData1 [k] )

      IF Empty( _HMG_aControlValue [k] )
         _HMG_aControlWidth [k] := GetWindowWidth  ( ControlHandle )
         _HMG_aControlHeight [k] := GetWindowHeight ( ControlHandle )
      ENDIF

   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]  // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION BmpSize( xBitmap )
*-----------------------------------------------------------------------------*
   LOCAL aRet := { 0, 0, 4 }

   DO CASE
   CASE ISSTRING( xBitmap )

      aRet := GetBitmapSize( xBitmap )

      IF Empty( aRet [1] ) .AND. Empty( aRet [2] )
         xBitmap := C_GetResPicture( xBitmap )
         aRet := GetBitmapSize( xBitmap )
         DeleteObject( xBitmap )
      ENDIF

   CASE ISNUMERIC( xBitmap )

      aRet := GetBitmapSize( xBitmap )

   ENDCASE

RETURN aRet

*-----------------------------------------------------------------------------*
FUNCTION HasAlpha( FileName )
*-----------------------------------------------------------------------------*
   LOCAL hBitmap
   LOCAL lResult := .F.

   hBitmap := C_GetResPicture( FileName )

   IF GetObjectType( hBitmap ) == OBJ_BITMAP .AND. BmpSize( FileName ) [3] == 32
      lResult := C_HasAlpha( hBitmap )
      DeleteObject( hBitmap )
   ENDIF

RETURN lResult

*-----------------------------------------------------------------------------*
FUNCTION HMG_SaveImage( FileName, cOutName, cEncoder, nJpgQuality, aOutSize )
*-----------------------------------------------------------------------------*
   LOCAL hBitmap
   LOCAL lResult := .F.

   hBitmap := iif( ISSTRING( FileName ), C_GetResPicture( FileName ), FileName )

   IF GetObjectType( hBitmap ) == OBJ_BITMAP
      hb_default( @cEncoder, "BMP" )
      hb_default( @nJpgQuality, 100 )
      __defaultNIL( @aOutSize, BmpSize( hBitmap ) )

      lResult := C_SaveHBitmapToFile( hBitmap, cOutName, aOutSize [1], aOutSize [2], "image/" + Lower( cEncoder ), nJpgQuality )

      IF ISSTRING( FileName )
         DeleteObject( hBitmap )
      ENDIF
   ENDIF

RETURN lResult
