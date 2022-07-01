* Project: UUEncode-UUDecode
* Autor: Brunello Pulix
* Date:  07/01/2022
*
#include <hmg.ch>
*
Function Main
  Load Window Main
  Main.Center
  Main.Activate
Return Nil
*
Procedure Waiting(cMess)
  Static x := .F.
  *
  hb_Default(@cMess,'..........Work in progress............')
  *
  If !x
     WAIT WINDOW cMess NOWAIT
        x := .T.
     else
     WAIT CLEAR
     x := .F.
  endif
  *
Return
*
*
Procedure Encode()
  Local nPos
  Local nPos2
  Local cFile
  Local cName
  Local cRoot := hb_Curdrive()+':\'+Curdir()
  *
  cFile := GetFile( {{'Tutti Files', '*.*'}}, 'Select File', cRoot, .F. , .T. )
  *
  IF EMPTY( cFile )
     RETURN
  ENDIF
  *
  nPos := RAt("\", cFile)
  IF nPos > 0
     cName := SubStr(cFile,nPos+1)
  ELSE
     cName := cFile
  ENDIF
  nPos2 := RAt(".", cName)
  cName := Left(cName,nPos2-1)
  *
  UUEncode(cFile,cName+'.UUE')
  *
Return
*
Procedure DEcode()
  Local nPos
  Local cFile
  Local cRoot := hb_Curdrive()+':\'+Curdir()
  *
  cFile := GetFile( {{'Tutti Files', '*.UUE'}}, 'Select File',cRoot, .F. , .T. )
  *
  IF EMPTY( cFile )
     RETURN
  ENDIF
  *
  nPos := RAt("\", cFile)
  IF nPos > 0
     cFile := SubStr(cFile,nPos+1)
  ENDIF
  *
  UUDEcode(cFile,cRoot)
  *
Return
