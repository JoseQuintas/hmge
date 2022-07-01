/*****************************
* Source : configCfgClass.prg
* System : MyProject
* Author : Phil Ide
* Created: 14-May-2004
*
* Purpose: Subclass of the ConfigClass
* ----------------------------
* History:
* ----------------------------
* 14-May-2004 14:48:13 idep - Created
*
* ----------------------------
* Last Revision:
*    $Rev: 17 $
*    $Date: 2004-05-14 16:05:19 +0100 (Fri, 14 May 2004) $
*    $Author: idep $
*
*****************************/

#include "common.ch"
#include "hbclass.ch"

#define CRLF Chr(13)+Chr(10)

CLASS ConfigCls
   EXPORTED:
   VAR imp
   VAR data

   METHOD init
   METHOD findHeader
   METHOD loadSection

ENDCLASS

METHOD ConfigCls:init( cFile )

   ::imp := MemoRead( cFile )

RETURN self

METHOD ConfigCls:findHeader()

   LOCAL i := At( '[header]', Lower( ::imp ) )
   LOCAL cHead := ''

   IF i > 0
      i += 10
      cHead := SubStr( ::imp, i )
   ENDIF

RETURN cHead

METHOD ConfigCls:loadSection( cSection )

   LOCAL cDef := ''
   LOCAL i
   LOCAL n
   LOCAL cTitle

   IF Empty( cSection )
      IF ( i := At( '[', ::imp ) ) > 0 .AND. ( n := At( ']', ::imp ) ) > 0
         cSection := SubStr( ::imp, i, n - i )
      ENDIF
   ENDIF

   if ! Empty( cSection )
      cSection := '[' + Lower( cSection ) + ']'
      cTitle := cSection + CRLF
      i := At( cSection, Lower( ::imp ) )

      IF i > 0
         i += Len( cTitle )
         cDef := SubStr( ::imp, i )

         IF ( i := At( CRLF + '[', cDef ) ) > 0
            cDef := Left( cDef, i - 1 )
         ENDIF
      ENDIF
   ENDIF

RETURN cDef
