/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * The idea of 2013 Verchenko Andrey <verchenkoag@gmail.com>
*/

///////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
FUNCTION MyStart( xVal )
   Inkey( xVal )

RETURN .T.

///////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
FUNCTION Dummy_1( xVal )
   Inkey( xVal )

RETURN .T.

///////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
FUNCTION Dummy_2( xVal )
   Inkey( xVal )

RETURN .T.

///////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
FUNCTION MyOpenDbf( xVal )

   LOCAL aFilesDbf := {}, nI, cVal

   AAdd ( aFilesDbf, "Base01.dbf" )
   AAdd ( aFilesDbf, "Base02.dbf" )
   AAdd ( aFilesDbf, "Base03.dbf" )
   AAdd ( aFilesDbf, "Base04.dbf" )

   cVal := GetProperty( "Form_Splash", "Label_1", "Value" )
   FOR nI := 1 TO Len( aFilesDbf )
      SetProperty( "Form_Splash", "Label_1", "Value", cVal + "->" + aFilesDbf[ nI ] )
      Inkey( xVal )
   NEXT

   Inkey( 1 )

RETURN .T.

///////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
FUNCTION MyCopyFiles( xVal )

   LOCAL aFiles := {}, nI, cVal, cMask := "Rep-"

   FOR nI := 1 TO 5
      AAdd ( aFiles, cMask + StrZero( nI, 6 ) + ".txt" )
   NEXT

   cVal := GetProperty( "Form_Splash", "Label_1", "Value" )
   FOR nI := 1 TO Len( aFiles )
      SetProperty( "Form_Splash", "Label_1", "Value", cVal + "->" + aFiles[ nI ] )
      Inkey( 0.1 )
   NEXT

   Inkey( xVal )

RETURN .T.
