/*****************************
* Source : configClass.prg
* System : Tools/MakePrg
* Author : Phil Ide
* Created: 14-May-2004
*
* Purpose: Configuration class for MakePrg.exe
* ----------------------------
* History:
* ----------------------------
* 14-May-2004 12:34:53 idep - Created
*
* ----------------------------
* Last Revision:
*    $Rev: 17 $
*    $Date: 2004-05-14 16:05:19 +0100 (Fri, 14 May 2004) $
*    $Author: idep $
*
*****************************/

#include "minigui.ch"
#include "hbclass.ch"

CLASS Config
   EXPORTED:
   VAR aimp
   VAR data

   METHOD init
   METHOD write
   METHOD findHeader
   METHOD findDefault
   METHOD loadSection
   METHOD convertToInclude
   METHOD loadVars
   METHOD insertVars
   METHOD envVars

ENDCLASS

METHOD Config:init()

   LOCAL cFile := GetExeFileName()
   LOCAL cPath

   ::aimp := Array( 3 )
   ::data = ''

   cPath := ChangeFileExt( cFile, 'cfg' )

   ::aImp[ 1 ] := ConfigCls():new( 'makeprg.cfg' )
   ::aImp[ 2 ] := ConfigCls():new( GetEnv( 'USERPROFILE' ) + '\Application Data\MakePrg\MakePrg.cfg' )
   ::aImp[ 3 ] := ConfigCls():new( cPath )

RETURN self

METHOD Config:write( cFile, cMode, cMsg )

   LOCAL cHead
   LOCAL cSection
   LOCAL nH
   LOCAL aVars
   LOCAL cFData

   cHead := ::findHeader()

   if ! Empty( cMode )
      IF Lower( cMode ) == '/c'
         cSection := 'console'
      ELSEIF Lower( cmode ) == '/g'
         cSection := 'graphics'
      ENDIF
   ENDIF

   DEFAULT cSection TO ::findDefault()

   cSection := ::loadSection( cSection )

   cSection := ::convertToInclude( cSection )

   aVars := ::loadVars( 'vars' )
   cHead := ::insertVars( cHead, aVars, cFile, cMsg )

   cHead := StrTran( cHead, '$$INCLUDE$$', cSection )
   IF hb_FileExists( cFile )
      cFData := MemoRead( cFile )
   ENDIF
   IF ( nH := FCreate( cFile ) ) <> 0
      FWrite( nH, cHead )
      if ! Empty( cFData )
         FWrite( nH, cFData )
      ENDIF
      FClose( nH )
   ENDIF

RETURN self

METHOD Config:findHeader()

   LOCAL cData := ''
   LOCAL i := 1

   WHILE i < Len( ::aImp ) .AND. Empty( cData )
      cData := ::aImp[ i++ ]:findHeader()
   ENDDO

RETURN cData

METHOD Config:findDefault()

   LOCAL i
   LOCAL cDef := ::loadSection( 'default' )

   if ! Empty( cDef )
      IF ( i := At( 'mode=', cDef ) ) > 0
         cDef := SubStr( cDef, i + 5 )
         IF ( i := At( CRLF, cDef ) ) > 0
            cDef := Left( cDef, i - 1 )
         ENDIF
      ENDIF
   ENDIF

RETURN cDef

METHOD Config:loadVars()

   LOCAL cData := ::loadSection( 'vars' )
   LOCAL aRet := {}
   LOCAL i, v, n := 1
   LOCAL cTmp
   LOCAL cKey, cVal

   cData := ::aImp[ 1 ]:loadSection( 'vars' )
   cData += ::aImp[ 2 ]:loadSection( 'vars' )
   cData += ::aImp[ 2 ]:loadSection( 'vars' )


   if ! Empty( cData )
      if !( Right( cData, 2 ) == CRLF )
         cData += CRLF
      ENDIF

      WHILE n <= Len( cData ) .AND. SubStr( cData, n, 1 ) $ CRLF
         n++
      ENDDO

      WHILE ( i := At( CRLF, cData, n ) ) > 0
         cTmp := SubStr( cData, n, i - n )
         IF ( v := At( '=', cTmp ) ) > 0
            cKey := Left( cTmp, v - 1 )
            cVal := SubStr( cTmp, v + 1 )
            IF AScan( aRet, {| e | Lower( e[ 1 ] ) == Lower( cKey ) } ) == 0
               AAdd( aRet, { cKey, cVal } )
            ENDIF
         ENDIF
         n := i + 2
      ENDDO
   ENDIF

RETURN aRet


METHOD Config:loadSection( cSection )

   LOCAL cData := ''
   LOCAL i := 1

   WHILE i < Len( ::aImp ) .AND. Empty( cData )
      cData := ::aImp[ i++ ]:loadSection( cSection )
   ENDDO

RETURN cData

METHOD Config:convertToInclude( cData )

   LOCAL i, n := 1
   LOCAL cRet := ''
   LOCAL cTmp

   if !( Right( cData, 2 ) == CRLF )
      cData += CRLF
   ENDIF

   WHILE n <= Len( cData ) .AND. SubStr( cData, n, 1 ) $ CRLF
      n++
   ENDDO

   WHILE ( i := At( CRLF, cData, n ) ) > 0
      cTmp := SubStr( cData, n, i - n )
      cRet += '#include "' + cTmp + '"' + CRLF
      n := i + 2
   ENDDO

RETURN cRet

METHOD Config:insertVars( cData, aVars, cFile, cMsg )

   LOCAL i

   DEFAULT cMsg TO ''

   cData := StrTran( cData, '$$FILE$$', cFile )
   cData := StrTran( cData, '$$DATE$$', CGIDate1() )
   cData := StrTran( cData, '$$TIME$$', Left( Time(), 5 ) )
   cData := StrTran( cData, '$$DATETIME$$', SubStr( CGIDate2(), 6 ) )
   cData := StrTran( cData, '$$MESSAGE$$', cMsg )

   FOR i := 1 TO Len( aVars )
      hb_SetEnv( aVars[ i ][ 1 ], aVars[ i ][ 2 ] )
      cData := StrTran( cData, '$$' + aVars[ i ][ 1 ] + '$$', '$$%' + aVars[ i ][ 1 ] + '%$$' )
   NEXT

   cData := ::envVars( cData )

RETURN cData

METHOD Config:envVars( cData )

   LOCAL i, n
   LOCAL cTmp
   LOCAL cVar
   LOCAL cValue

   AltD()
   WHILE ( i := At( '$$%', cData ) ) > 0 .AND. ( n := At( '%$$', cData ) ) > 0
      cTmp := SubStr( cData, i, ( n - i ) + 3 )
      cVar := StrTran( cTmp, '$$%' )
      cVar := StrTran( cVar, '%$$' )
      cValue := GetEnv( cVar )
      cData := StrTran( cData, cTmp, cValue )
   ENDDO

RETURN cData

STATIC FUNCTION CGIDate1()

   LOCAL cDate := CGIDate2()

RETURN SubStr( cDate, 6, 11 )

STATIC FUNCTION CGIDate2( nSecs )

   LOCAL nDays
   LOCAL nTime := Seconds()
   LOCAL dDate := Date()
   LOCAL nDayLeft := 86400 - nTime
   LOCAL cRet

   DEFAULT nSecs TO 0

   IF nSecs > 0
      nDays := Int( nSecs / 86400 )
      nSecs -= nDays * 86400

      IF nSecs > nDayLeft
         nDays++
         nSecs -= nDayLeft
      ENDIF

      nTime += nSecs

      dDate += nDays
   ENDIF

   cRet := Left( CDoW( dDate ), 3 ) + ', '
   cRet += StrZero( Day( dDate ), 2 ) + '-' + Left( CMonth( dDate ), 3 ) + '-' + LTrim( Str( Year( dDate ) ) ) + ' '
   cRet += Secs2Time( nTime )

RETURN ( cRet )

STATIC FUNCTION Secs2Time( n )

   LOCAL nHrs := Int( n / 3600 )
   LOCAL nMins
   LOCAL nSecs

   n := n % 3600
   nMins := Int( n / 60 )
   nSecs := n % 60

RETURN StrZero( nHrs, 2 ) + ':' + StrZero( nMins, 2 ) + ':' + StrZero( nSecs, 2 )

FUNCTION Time2Secs( c )

   LOCAL nH := Val( Left( c, 2 ) )
   LOCAL nM := Val( SubStr( c, 4, 2 ) )
   LOCAL nS := if( Len( c ) == 8, Val( Right( c, 2 ) ), 0 )
   LOCAL nRet

   nM *= 60
   nH *= 60
   nH *= 60

   nRet := nS + nM + nH

RETURN ( nRet )

FUNCTION cFilePath( cPathMask )

   LOCAL cPath

   hb_FNameSplit( cPathMask, @cPath )

RETURN Left( cPath, Len( cPath ) - 1 )

FUNCTION cFileNoExt( cPathMask )

   LOCAL cName

   hb_FNameSplit( cPathMask, , @cName )

RETURN cName
