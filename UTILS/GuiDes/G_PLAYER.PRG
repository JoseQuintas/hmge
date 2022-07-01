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

CREATE CLASS gPlayer INHERIT gControl

   DATA Filename           INIT ""
   DATA NoAutoSizeWindow   INIT FALSE
   DATA NoAutoSizeMove     INIT FALSE
   DATA NoErrorDlg         INIT FALSE
   DATA NoMenu             INIT FALSE
   DATA NoOpen             INIT FALSE
   DATA NoPlayBar          INIT FALSE
   DATA ShowAll            INIT FALSE
   DATA ShowMode           INIT FALSE
   DATA ShowName           INIT FALSE
   DATA ShowPosition       INIT FALSE

   METHOD SetMainVars()  VIRTUAL
   METHOD Define()
   METHOD Code( oCode )

END CLASS


METHOD Define() CLASS gPlayer

   @ ::Row, ::Col PLAYER &( ::Name ) OF &( ::oParen:Name ) ;
      WIDTH ::Width ;
      HEIGHT ::Height ;
      FILE ::Filename

RETURN Self


METHOD Code( oCode ) CLASS gPlayer

   ::Super:Code( oCode )

   oCode:AddTag( "WIDTH",   ::Width )
   oCode:AddTag( "HEIGHT",  ::Height )
   oCode:AddQuoted( "FILE", ::Filename )

   oCode:AddNotEmpty( "NOAUTOSIZEWINDOW", ::NoAutoSizeWindow )
   oCode:AddNotEmpty( "NOAUTOSIZEMOVE",   ::NoAutoSizeMove   )
   oCode:AddNotEmpty( "NOERRORDLG",       ::NoErrorDlg       )
   oCode:AddNotEmpty( "NOMENU",           ::NoMenu           )
   oCode:AddNotEmpty( "NOOPEN",           ::NoOpen           )
   oCode:AddNotEmpty( "NOPLAYBAR",        ::NoPlayBar        )
   oCode:AddNotEmpty( "SHOWALL",          ::ShowAll          )
   oCode:AddNotEmpty( "SHOWMODE",         ::ShowMode         )
   oCode:AddNotEmpty( "SHOWNAME",         ::ShowName         )
   oCode:AddNotEmpty( "SHOWPOSITION",     ::ShowPosition     )
   oCode:AddNotEmpty( "HELPID",     ::HelpID     )

   oCode:WriteToFile()

RETURN NIL
