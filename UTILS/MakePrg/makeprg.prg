/*****************************
* Source : makeprg.prg
* System : Tools/MakePrg
* Author : Phil Ide
* Created: 13/05/2004
*
* Purpose:
* ----------------------------
* History:
* ----------------------------
*    13/05/2004 19:38 PPI - Created
*
* Last Revision:
*    $Rev: 18 $
*    $Date: 2004-05-14 16:05:52 +0100 (Fri, 14 May 2004) $
*    $Author: idep $
*
*****************************/

#include "common.ch"

ANNOUNCE RDDSYS

PROCEDURE Main( cFile, cMsg, cMode )

   LOCAL oCfg

   IF PCount() == 0 .OR. Left( Lower( cFile ), 2 ) $ '/?:-?:/h:-h'
      Help()
   ELSE
      hb_cdpSelect( "UTF8" ) 
      oCfg := Config():new()
      oCfg:write( cFile, cMode, cMsg )
   ENDIF

RETURN

PROCEDURE Help()
   ? '   <file> <purpose> [/c|/g]'
   ? '   /c = console mode'
   ? '   /g = graphics mode'
   ? '   (default from config file)'
   ?

RETURN
