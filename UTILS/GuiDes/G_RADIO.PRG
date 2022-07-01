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

CREATE CLASS gRadioGroup INHERIT gControl

   DATA Options               INIT ''
   DATA Value                 INIT 0
   DATA Spacing               INIT 0
   DATA Horizontal            INIT FALSE
   DATA Transparent           INIT FALSE
   DATA OnChange              INIT ""

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD SetMainVars() CLASS gRadiogroup

   ::Options := '{ "' + ::Name + '_A" , "' + ::Name + '_B" }'

RETURN Self


METHOD Define() CLASS gRadioGroup

   IF oStyle:AutoSize()
      IF ::Horizontal
         @ ::Row, ::Col RADIOGROUP &( ::Name ) OF &( ::oParen:Name ) ;
            OPTIONS &( ::Options ) ;
            SPACING ::Spacing ;
            AUTOSIZE ;
            FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
            TOOLTIP ::ToolTip ;
            HORIZONTAL
      ELSE
         @ ::Row, ::Col RADIOGROUP &( ::Name ) OF &( ::oParen:Name ) ;
            OPTIONS &( ::Options ) ;
            SPACING Max( ::Height, ::Spacing ) ;
            AUTOSIZE ;
            FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
            TOOLTIP ::ToolTip
      ENDIF

      ::Width  := GetProperty( ::oParen:Name, ::Name, "Width" )
      ::Height := GetProperty( ::oParen:Name, ::Name, "Height" )

   ELSE
      IF ::Horizontal
         @ ::Row, ::Col RADIOGROUP &( ::Name ) OF &( ::oParen:Name ) ;
            OPTIONS &( ::Options ) ;
            SPACING ::Spacing ;
            FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
            TOOLTIP ::ToolTip ;
            ON CHANGE {|| ::OnFocussed() } ;
            HORIZONTAL
      ELSE
         @ ::Row, ::Col RADIOGROUP &( ::Name ) OF &( ::oParen:Name ) ;
            OPTIONS &( ::Options ) ;
            SPACING Max( ::Height, ::Spacing ) ;
            FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
            TOOLTIP ::ToolTip ;
            ON CHANGE {|| ::OnFocussed() }
      ENDIF
   ENDIF

RETURN Self


METHOD Code( oCode ) CLASS gRadioGroup

   ::Super:Code( oCode )

   oCode:AddTag( "OPTIONS", ::Options )
   oCode:AddNotEmpty( "VALUE", ::Value )
   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddNotEmpty( "SPACING", ::Spacing )
   ::Super:FontCode( oCode )
   oCode:AddNotEmpty( "HORIZONTAL", ::Horizontal )
   oCode:AddNotEmpty( "TRANSPARENT", ::Transparent )
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   oCode:AddNotEmpty( "ON CHANGE",  ::OnChange )
   oCode:AddNotEmpty( "HELPID",  ::HelpID )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gRadioGroup

   DoMethod( ::oParen:Name, ::Name, "RELEASE" )
   ::Define()

   ::Super:Update()

RETURN NIL
