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

DECLARE WINDOW Prefer

CREATE CLASS gCode
   DATA String                INIT ""
   DATA TabNum                INIT 0
   DATA FileHandler
   DATA LineCount             INIT 0
   DATA ClassName
   DATA vTab   INIT 0

   METHOD NEW
   METHOD AddLine
   METHOD MoreTab
   METHOD LessTab
   METHOD AddTag
   METHOD AddNotEmpty
   METHOD AddQuoted
   METHOD AddNotEmptyQuoted
   METHOD WriteToFile

END CLASS


METHOD New( fHandler ) CLASS gCode

   LOCAL nTabSpaces := Prefer.tbCodeTab.Value

   ::FileHandler := fHandler
   ::vTab := Space( nTabSpaces )

RETURN Self


METHOD AddLine( cCode, lFirstLine, lStandAlone ) CLASS gCode

   IF ( lFirstLine == NIL )
      lFirstLine := FALSE
   ENDIF

   IF ( lStandAlone == NIL )
      lStandAlone := FALSE
   ENDIF

   IF ( lFirstLine )
      ::String += CR_LF + CR_LF
      ::String += Replicate( ::vTAB, ::TabNum - 1 )
   ELSEIF ( lStandAlone )
      ::String += CR_LF
      ::String += Replicate( ::vTAB, ::TabNum )
   ELSE
      ::String += " ; " + CR_LF
      ::String += Replicate( ::vTAB, ::TabNum )
   ENDIF

   ::String += cCode

RETURN Self


METHOD MoreTab() CLASS gCode
   ::TabNum++

RETURN Self


METHOD LessTab() CLASS gCode
   ::TabNum := Max( 0, ::TabNum - 1 )

RETURN Self


METHOD AddTag( cString, Value, lFirstLine, lQuoted, lStandAlone ) CLASS gCode

   IF ( lQuoted == NIL )
      lQuoted := .F.
   ENDIF

   IF !lQuoted
      cString := cString + " " + CastToChar( Value )
   ELSE
      cString := cString + " '" + CastToChar( Value ) + "'"
   ENDIF

RETURN ::AddLine( cString, lFirstLine, lStandAlone )


METHOD AddNotEmpty( cString, Value, lFirstLine, lStandAlone ) CLASS gCode
   IF !Empty( Value )
      IF ValType( Value ) == "L"
         RETURN ::AddTag( cString, "", lFirstLine, , lStandAlone )
      ELSE
         RETURN ::AddTag( cString, Value, lFirstLine, , lStandAlone )
      ENDIF
   ENDIF

RETURN NIL


METHOD AddQuoted( cString, Value, lFirstLine, lStandAlone ) CLASS gCode
RETURN ::AddTag( cString, Value, lFirstLine, .T., lStandAlone )


METHOD AddNotEmptyQuoted( cString, cValue, lFirstLine, lStandAlone ) CLASS gCode

   IF !Empty( cValue )
      RETURN ::AddQuoted( cString, cValue, lFirstLine, lStandAlone )
   ENDIF

RETURN NIL


METHOD WriteToFile() CLASS gCode

   LOCAL lSuccess := .F.

   IF !Empty( ::FileHandler )
      FWrite( ::FileHandler, ::String )
      IF ( FError() == 0 )
         lSuccess := .T.
         ::String := ""
      ENDIF
   ENDIF

RETURN lSuccess
