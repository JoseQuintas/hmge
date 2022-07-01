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

CREATE CLASS gOutput

   DATA String                INIT ""
   DATA FileHandler
   DATA LineCount             INIT 0
   DATA ClassName
   DATA TabNum                INIT 0

   METHOD NEW
   METHOD AddLine
   METHOD AddTag
   METHOD END
   METHOD WriteToFile

END CLASS


METHOD New( fHandler ) CLASS gOutput

   ::FileHandler := fHandler

RETURN Self


METHOD AddLine( cCode, lItemName ) CLASS gOutput

   IF ( lItemName == NIL )
      lItemName := .F.
   ENDIF

   IF ( lItemName )
      ::String += CR_LF + "[" + cCode + "]" + CR_LF
   ELSE
      ::String += cCode + CR_LF
   ENDIF

   IF ::LineCount > 50
      ::WriteToFile()
      ::LineCount := 0
   ELSE
      ::LineCount++
   ENDIF

RETURN Self


METHOD AddTag( cString, xValue, lItemName ) CLASS gOutput

   LOCAL cValString := CastToChar( xValue )

   cString += " = " + cValString

RETURN ::AddLine( cString, lItemName )


METHOD End() CLASS gOutput
   IF !Empty( ::String )
      ::WriteToFile()
   ENDIF

RETURN NIL


METHOD WriteToFile() CLASS gOutput

   LOCAL lSuccess := .F.

   IF !Empty( ::FileHandler )
      FWrite( ::FileHandler, ::String )
      IF ( FError() == 0 )
         lSuccess := .T.
         ::String := ""
      ENDIF
   ENDIF

RETURN lSuccess
