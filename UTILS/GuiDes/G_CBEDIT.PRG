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

CREATE CLASS gCBEdit
   DATA Origin_Control
   DATA Origin_WindowName
   DATA Description

   METHOD NEW     CONSTRUCTOR
   METHOD Edit
   METHOD Retrieve

ENDCLASS


METHOD New( cControl, cWindow, cDescrip ) CLASS gCBEdit
   ::Origin_Control := cControl
   ::Origin_WindowName := cWindow
   ::Description := cDescrip

   ::Edit()

RETURN NIL


METHOD Edit() CLASS gCBEdit

   LOCAL cText := GetProperty( ::Origin_WindowName, ::Origin_Control, "Value" )

   DEFINE WINDOW CBEditor  AT 0, 0 WIDTH 400 ;
      HEIGHT 200 TITLE "GuiDes (CodeBlock Editor)" ;
      ICON "GUIDES" ;
      MODAL NOSIZE ;
      FONT "ARIAL" SIZE 8

   @ 15, 10 LABEL L100 OF CBEditor VALUE ::Description ;
      WIDTH 100 HEIGHT 20

   @ 40, 10 EDITBOX E100 OF CBEditor ;
      WIDTH 380 HEIGHT 100 ;
      VALUE cText ;
      FONT "Courier New" SIZE 10

   @ 150, 160 BUTTON WpCommit OF CBEditor CAPTION "OK";
      ACTION ::Retrieve() WIDTH 80 HEIGHT 20

   END WINDOW

   CENTER WINDOW CBEditor

   ACTIVATE WINDOW CBEditor

RETURN NIL


METHOD Retrieve() CLASS gCBEdit

   LOCAL cText := CBEditor .E100. Value

   SetProperty( ::Origin_WindowName, ::Origin_Control, "Value", cText )

   RELEASE WINDOW CBeditor

RETURN NIL
