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

#include "hbclass.ch"
#include "GUIDES.CH"
#include "minigui.ch"

DECLARE WINDOW Main
DECLARE WINDOW OIWin
DECLARE WINDOW EditBar
DECLARE WINDOW PropInspector

CREATE CLASS gProps

   DATA gObject
   DATA nItem

   METHOD NEW
   METHOD Subst
   METHOD Refresh_Properties_Window
   METHOD EditProperty
   METHOD Properties

   METHOD PropName
   METHOD ChangeProp

   METHOD ApplyProperty
   METHOD EditColor
   METHOD SetFont
   METHOD EditTree

ENDCLASS


METHOD New( newObject ) CLASS gProps

   ::Subst( newObject )

RETURN Self


METHOD Subst( newObject ) CLASS gProps
   ::gObject := newObject
   ::Refresh_Properties_Window()

RETURN NIL


METHOD Refresh_Properties_Window() CLASS gProps

   LOCAL nCount
   LOCAL ObjArray := ::Properties()
   LOCAL cPropValue

   PropInspector .PropGrid. DeleteAllItems

   FOR nCount := 1 TO Len( ObjArray )
      cPropValue := CastToChar( ObjArray[ nCount, 2 ] )
      PropInspector .PropGrid. AddItem( { ObjArray[ nCount, 1 ], cPropValue } )
   NEXT

RETURN NIL


METHOD EditProperty() CLASS gProps

   LOCAL wIndex := PropInspector .PropGrid. Value
   LOCAL ObjArray := ::Properties()
   LOCAL aPropLine, cPropName, xValue

   IF ( wIndex == 0 ) .OR. ( wIndex > Len( ObjArray ) )
      PlayHand()
   ELSE
      ::nItem   := wIndex
      aPropLine := ObjArray[ wIndex ]
      cPropName := AllTrim( Upper( aPropLine[ 1 ] ) )
      xValue    := aPropLine[ 2 ]

      IF ( cPropName == "NAME" ) ;
            .OR. ( cPropName == "OPAREN" ) ;
            .OR. ( cPropName == "TYPE" )
         MsgInfo( cPropName + " property cannot be modified.", "GuiDes" )

      ELSEIF ( cPropName == "FONT" )
         ::SetFont()

      ELSEIF ( "COLOR" $ cPropName )
         ::EditColor( Left( cPropName, 4 ) )   // GF

      ELSEIF ( "ELEMENTS" $ cPropName )
         ::EditTree()

      ELSEIF ( ValType( xValue ) == "L" )
         ::ApplyProperty( TRUE )

      ELSE
         PropEditWin( xValue, cPropName, ::gObject:Id, ::gObject:oParen:Id )

      ENDIF
   ENDIF

RETURN NIL


METHOD Properties() CLASS gProps
   IF ::gObject == NIL
      RETURN {}
   ENDIF

RETURN ( __objGetValueList( ::gObject ) )


METHOD PropName() CLASS gProps
RETURN ::Properties()[ ::nItem ][ 1 ]


METHOD ChangeProp( xRef, xValue )     // xRef can be either array index

   LOCAL cPropName              // (number) or property name (character)
   LOCAL aProps

   IF ValType( xRef ) == "N"
      ::nItem := xRef
      cPropName := ::PropName()
   ELSE
      aProps := ::Properties()
      cPropName := AllTrim( Upper( xRef ) )
      ::nItem := AScan( aProps, {| aRow | aRow[ 1 ] == cPropName } )
   ENDIF

   __objSendMsg( ::gObject, "_" + cPropName, xValue )
   PropInspector .PropGrid. Item( ::nItem ) :=  { cPropName, CastToChar( xValue ) }

RETURN Self


METHOD ApplyProperty( lApply ) CLASS gProps

   LOCAL OldValue
   LOCAL xValue

   IF lApply
      OldValue := ::Properties()[ ::nItem ][ 2 ]

      IF ValType( OldValue ) == "C"
         xValue := EditBar .cEditBox. Value
         EditBar.Release

      ELSEIF ValType( OldValue ) == "N"
         xValue := EditBar .NSpinner. Value
         EditBar.Release

      ELSEIF ValType( OldValue ) == "L"
         xValue := !( OldValue )
         MsgInfo( ::PropName +  " property will be set to" + CR_LF + CR_LF + iif( xValue, "TRUE", "FALSE" ), "GuiDes" )
      ELSE
         MsgBox( "Unknown value type!", "GuiDes" )
      ENDIF


      ::ChangeProp( ::nItem, xValue )
      ::gObject:Update()
      ::gObject:oParen:SetChanged( TRUE )
   ELSE
      IF !( ValType( OldValue ) $ "L" )
         EditBar.Release
      ENDIF
   ENDIF

RETURN NIL


METHOD EditColor( cColor ) CLASS gProps

   LOCAL aColor  := IF( cColor == 'FONT', ::gObject:FontColor, ::gObject:BackColor )  // GF
   LOCAL oColor  := GetColor( IF( aColor[ 1 ] == NIL, NIL, aColor ) )                   // GF

   ::ChangeProp( ::nItem, oColor )
   ::gObject:Update()
   ::gObject:oParen:SetChanged( TRUE )

RETURN NIL


METHOD SetFont() CLASS gProps

   LOCAL aFont := ChangeFont( ::gObject:Font )

   ::ChangeProp( ::nItem, aFont )
   ::gObject:Update()
   ::gObject:oParen:SetChanged( TRUE )

RETURN NIL


METHOD EditTree() CLASS gProps

   LOCAL aElements := ::Properties()[ ::nItem ][ 2 ]
   LOCAL oMenu := gMenu():New( G_TREE )

   oMenu:Elements := aElements
   oMenu:Edit()

   IF oMenu:ExitStatus == G_EXIT_DESTROY
      oMenu:Elements := {}
   ENDIF

   ::ChangeProp( ::nItem, oMenu:Elements )
   ::gObject:Update()
   ::gObject:oParen:SetChanged( TRUE )

RETURN NIL
