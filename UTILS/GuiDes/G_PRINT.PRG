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

CREATE CLASS gPrint INHERIT gControl

   DATA Value        INIT ""
   DATA FontColor    INIT G_BLACK
   DATA InnerFont    INIT 0
   DATA Angle        INIT 0
   DATA InnerWidth   INIT 0
   DATA IsVariable   INIT FALSE

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD SetMainVars() CLASS gPrint

   ::Value := ::Name
   ::FontColor    := oStyle:FontColor

RETURN Self


METHOD Define() CLASS gPrint

   @ ::Row, ::Col LABEL &( ::Name ) OF &( ::oParen:Name ) ;
      VALUE ::Value ;
      AUTOSIZE ;
      FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
      FONTCOLOR ::FontColor

   ::Width  := GetProperty( ::oParen:Name, ::Name, "Width" )
   ::Height := GetProperty( ::oParen:Name, ::Name, "Height" )

RETURN Self


METHOD Code( oCode ) CLASS gPrint

   LOCAL cCode := ""
   LOCAL xPos := Int( ::Col / ::oParen:PrintResolution )
   LOCAL yPos := Int( ::Row / ::oParen:PrintResolution )

   cCode := "@ " + AllTrim( Str( yPos ) ) + "," + AllTrim( Str( xPos ) ) + ' SAY '

   IF ::IsVariable
      cCode += ::Value + ' FONT "F' + AllTrim( Str( ::InnerFont ) ) + '" TO PRINT '
   ELSE
      cCode += '"' + ::Value + '" FONT "F' + AllTrim( Str( ::InnerFont ) ) + '" TO PRINT '
   ENDIF

   oCode:AddLine( cCode, , TRUE )
   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gPrint

   SetProperty( ::oParen:Name, ::Name, "Value", ::Value )
   SetProperty( ::oParen:Name, ::Name, "FontColor", ::FontColor )

   ::Super:Update()

RETURN NIL
