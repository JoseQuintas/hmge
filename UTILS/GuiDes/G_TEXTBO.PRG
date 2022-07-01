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

CREATE CLASS gTextBox INHERIT gControl

   DATA UpperCase      INIT FALSE
   DATA LowerCase      INIT FALSE
   DATA Value          INIT 0
   DATA DATE           INIT FALSE
   DATA Numeric        INIT FALSE
   DATA InputMask      INIT ""
   DATA FORMAT         INIT ""
   DATA FieldName      INIT ""
   DATA Password       INIT FALSE
   DATA OnGotFocus     INIT ""
   DATA OnChange       INIT ""
   DATA OnLostFocus    INIT ""
   DATA OnEnter        INIT ""
   DATA RightAlign     INIT FALSE
   DATA BackColor      INIT G_WHITE
   DATA FontColor      INIT G_BLACK

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD SetMainVars() CLASS gTextBox

   ::Value := ::Name
   ::BackColor    := G_WHITE
   ::FontColor    := oStyle:FontColor

RETURN Self


METHOD Define() CLASS gTextBox

   IF ::Numeric
      @ ::Row, ::Col TEXTBOX &( ::Name ) OF &( ::oParen:Name ) ;
         HEIGHT ::Height ;
         WIDTH ::Width ;
         FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
         TOOLTIP ::ToolTip ;
         BACKCOLOR ::BackColor ;
         FONTCOLOR ::FontColor ;
         ON GOTFOCUS {|| ::OnFocussed() } ;
         NUMERIC
   ELSE
      @ ::Row, ::Col TEXTBOX &( ::Name ) OF &( ::oParen:Name ) ;
         HEIGHT ::Height ;
         WIDTH ::Width ;
         FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
         TOOLTIP ::ToolTip ;
         BACKCOLOR ::BackColor ;
         FONTCOLOR ::FontColor ;
         ON GOTFOCUS {|| ::OnFocussed() }
   ENDIF

   IF ::RightAlign
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Right" )
   ELSE
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Left" )
   ENDIF

RETURN Self


METHOD Code( oCode ) CLASS gTextBox

   ::Super:Code( oCode )

   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddNotEmpty( "FIELD",  ::FieldName )
   IF ::Numeric
      oCode:AddNotEmpty( "VALUE",  ::Value )
   ELSE
      oCode:AddNotEmptyQuoted( "VALUE",  ::Value )
   ENDIF

   ::Super:FontCode( oCode )

   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   oCode:AddTag( "BACKCOLOR", ColorToCode( ::BackColor ) )
   oCode:AddTag( "FONTCOLOR", ColorToCode( ::FontColor ) )

   oCode:AddNotEmpty( "NUMERIC",  ::Numeric )
   oCode:AddNotEmptyQuoted( "INPUTMASK",  ::InputMask )
   oCode:AddNotEmpty( "RIGHTALIGN", ::RightAlign )

   IF ::Password
      oCode:AddNotEmpty( "PASSWORD", ::Password )
   ELSE
      oCode:AddNotEmpty( "FORMAT", ::FORMAT )
   ENDIF

   oCode:AddNotEmpty( "DATE",  ::DATE )

   oCode:AddNotEmpty( "ON GOTFOCUS",  ::OnGotFocus )
   oCode:AddNotEmpty( "ON CHANGE",  ::OnChange )
   oCode:AddNotEmpty( "ON LOSTFOCUS",    ::OnLostFocus )
   oCode:AddNotEmpty( "ON ENTER", ::OnEnter )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gTextbox

   SetProperty( ::oParen:Name, ::Name, "Value", ::Value )
   SetProperty( ::oParen:Name, ::Name, "Backcolor", ::BackColor )
   SetProperty( ::oParen:Name, ::Name, "FontColor", ::FontColor )

   IF ::RightAlign
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Right" )
   ELSE
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Left" )
   ENDIF

   ::Super:Update()

RETURN NIL
