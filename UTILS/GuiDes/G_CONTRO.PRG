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
#include "error.ch"

DECLARE WINDOW OIWin
DECLARE WINDOW Main

CREATE CLASS gControl

   DATA oParen

   DATA TYPE                  INIT ""
   DATA Name                  INIT ""
   DATA Id                    INIT ""

   DATA Row                   INIT 0
   DATA Col                   INIT 0
   DATA Width                 INIT 100
   DATA Height                INIT 100

   DATA Font                  INIT G_FONT

   DATA Tooltip               INIT ""
   DATA HelpID                INIT ""
   DATA Invisible             INIT FALSE

   METHOD New()
   METHOD INIT
   METHOD Load( oWindow )
   METHOD UPDATE
   METHOD Move
   METHOD Size
   METHOD SetFont
   METHOD CODE
   METHOD Output
   METHOD OnFocussed
   METHOD SetFocus      INLINE DoMethod( ::oParen:Name, ::Name, "SETFOCUS" )
   METHOD RefreshProps  INLINE oProps:Subst( Self )
   METHOD AddToTree()
   METHOD BecomeActiveControl()
   METHOD AddFromDB( oWindow )
   METHOD FontCode( oCode )

END CLASS


METHOD New() CLASS gControl

   LOCAL cClass := ::ClassName()

   IF oEnvir:AnyWindow()
      ::oParen := oEnvir:Act_Window()
      ::Name := ::oParen:AddControl( Self )
      ::TYPE := Right( cClass, Len( cClass ) - 1 )
      ::Init()
      RETURN Self
   ENDIF

RETURN NIL


METHOD Init() CLASS gControl

   ::Id           := ::Name
   ::Font         := AClone( oStyle:Font )
   ::ToolTip      := ""

   IF ( ::TYPE == "ANIMATEBOX" )       .OR. ;
         ( ::TYPE == "COMBOBOX" )      .OR. ;
         ( ::TYPE == "BROWSE" )        .OR. ;
         ( ::TYPE == "EDITBOX" )       .OR. ;
         ( ::TYPE == "FRAME" )         .OR. ;
         ( ::TYPE == "LISTBOX" )       .OR. ;
         ( ::TYPE == "PLAYER" )        .OR. ;
         ( ::TYPE == "MONTHCALENDAR" ) .OR. ;
         ( ::TYPE == "TAB" )           .OR. ;
         ( ::TYPE == "TREE" )          .OR. ;
         ( ::TYPE == "GRID" )

      ::Width    := oStyle:BigWidth()
      ::Height   := oStyle:BigHeight()
   ELSEIF ( ::TYPE == "IMAGE" )
      ::Width    := 109
      ::Height   := 34
   ELSEIF ( ::TYPE == "TIMER" )
      ::Width    := 25
      ::Height   := 25
   ELSE
      ::Width    := oStyle:Width()
      ::Height   := oStyle:Height()
   ENDIF
   ::SetMainVars()
   ::Define()
   ::AddToTree()

RETURN Self


METHOD Load( oWindow ) CLASS gControl

   LOCAL cClass := ::ClassName()
   LOCAL aProps :=  __objGetValueList( Self )
   LOCAL nCount

   ::oParen := oWindow
   ::Name := ::oParen:AddControl( Self )

   FOR nCount := 1 TO Len( aProps )
      IF !( aProps[ nCount ][ 1 ] == "OPAREN" )
         IF !Empty( ::oParen:cSection )
            __objSendMsg( Self, "_" + aProps[ nCount ][ 1 ], _GetIni( ::oParen:cSection, aProps[ nCount ][ 1 ], , aProps[ nCount ][ 2 ] )  )
         ENDIF
      ENDIF
   NEXT

   ::TYPE := Right( cClass, Len( cClass ) - 1 )
   ::Define()
   ::AddToTree()
   ::RefreshProps()

RETURN Self


METHOD Update() CLASS gControl

   SetProperty( ::oParen:Name, ::Name, "ROW", ::Row )
   SetProperty( ::oParen:Name, ::Name, "COL", ::Col )
   SetProperty( ::oParen:Name, ::Name, "WIDTH", ::Width )
   SetProperty( ::oParen:Name, ::Name, "HEIGHT", ::Height )

   SetProperty( ::oParen:Name, ::Name, "FontName", ::Font[ 1 ] )
   SetProperty( ::oParen:Name, ::Name, "FontSize", ::Font[ 2 ] )

RETURN NIL


METHOD Move( xPos, yPos ) CLASS gControl
   ::Row := xpos
   ::Col := ypos

   SetProperty( ::oParen:Name, ::Name, "ROW", ::Row )
   SetProperty( ::oParen:Name, ::Name, "COL", ::Col )

   RedrawWindow( ::oParen:Handler )

   oProps:ChangeProp( "ROW", xPos )
   oProps:ChangeProp( "COL", yPos )

// DoMethod( ::oParen:Name, ::Name, )    should invoke Paint method when available

RETURN NIL


METHOD Size( nWidth, nHeight ) CLASS gControl
   ::Width  := nWidth
   ::Height := nHeight

   SetProperty( ::oParen:Name, ::Name, "WIDTH", ::Width )
   SetProperty( ::oParen:Name, ::Name, "HEIGHT", ::Height )

   oProps:ChangeProp( "WIDTH", nWidth )
   oProps:ChangeProp( "HEIGHT", nHeight )

RETURN NIL


METHOD SetFont() CLASS gControl
   ::Font := ChangeFont( ::Font )
   SetProperty( ::oParen:Name, ::Name, "FontName", ::Font[ 1 ] )
   SetProperty( ::oParen:Name, ::Name, "FontSize", ::Font[ 2 ] )

RETURN NIL


METHOD OnFocussed() CLASS gControl
// oEnvir:LookFor( ::oParen:Name, ::Name )

RETURN NIL


METHOD Code( oCode ) CLASS gControl

   LOCAL cCode

   cCode := "@ " + AllTrim( Str( ::Row ) ) + "," ;
      + AllTrim( Str( ::Col ) ) + " " ;
      + ::TYPE + " " + ::Id

   oCode:AddLine( cCode, TRUE )

   IF oStyle:CodeIncludeParent()
      oCode:AddLine( "OF " + ::oParen:Id )
   ENDIF

   oCode:WriteToFile()

RETURN NIL


METHOD Output( cSection ) CLASS gControl

   LOCAL aProps := __objGetValueList( Self )
   LOCAL nCount

   FOR nCount := 1 TO Len( aProps )
      SET SECTION cSection ENTRY aProps[ nCount ][ 1 ] TO aProps[ nCount ][ 2 ]
   NEXT

RETURN NIL


METHOD AddToTree() CLASS gControl
   OIWin .OIGrid. AddItem( { ::Name, ::Type, ::Id } )
   OIWin .OIGrid. Value := OIWin .OIGrid. ItemCount

RETURN Self



METHOD BecomeActiveControl() CLASS gControl

   ::oParen:INDEX := ::oParen:SearchIndex( ::Name )
   ::RefreshProps()
   ::SetFocus()

RETURN NIL


METHOD AddFromDB( oWindow ) CLASS gControl

   LOCAL cClass := ::ClassName()

   ::oParen := oWindow
   ::Name := ::oParen:AddControl( Self )
   ::TYPE := Right( cClass, Len( cClass ) - 1 )
   ::Init()

RETURN Self


METHOD FontCode( oCode ) CLASS gControl

   IF !( oStyle:UseWindowFont() )
      oCode:AddQuoted( "FONT", ::Font[ 1 ] )
      oCode:AddTag( "SIZE",    ::Font[ 2 ] )
      oCode:AddTag( "BOLD",    ::Font[ 3 ] )
      oCode:AddTag( "ITALIC",  ::Font[ 4 ] )
   ELSE
      IF !( ::Font[ 1 ] == ::oParen:Font[ 1 ] ) .OR. !( ::Font[ 2 ] == ::oParen:Font[ 2 ] )
         oCode:AddQuoted( "FONT", ::Font[ 1 ] )
         oCode:AddTag( "SIZE",    ::Font[ 2 ] )
      ENDIF
      oCode:AddNotEmpty( "BOLD", ::Font[ 3 ] )
      oCode:AddNotEmpty( "ITALIC", ::Font[ 4 ] )
   ENDIF
   oCode:WriteToFile()

RETURN NIL
