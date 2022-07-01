* Project: UUEncode-UUDecode
* Autor: Brunello Pulix
* Date:  07/01/2022
*
#define CRLF hb_eol()
#include "fileio.ch"
*
FUNCTION UUEncode(cFile,cDest)
  LOCAL hf, hfOut
  LOCAL nBytes := 0
  *
  Waiting()
  IF (Len(cFile) == 0) .OR. (Len(cDest) == 0)
     RETURN FALSE
  ENDIF
  hfOut := FCreate(cDest)
  IF hfOut = F_ERROR
     RETURN FALSE
  ENDIF
  IF Len(cFile) > 0
     hf := FOpen(cFile, FO_READ)
     IF hf != F_ERROR
        nBytes += EncodeUU(hf, hfOut, cFile)
     ENDIF
  ENDIF
  FClose(hfOut)
  FClose(hf)
  *
  Waiting()
  *
RETURN Nil
*
Static FUNCTION __GetHeader(cFile)
  LOCAL nPos
  LOCAL cName
  LOCAL cBuffer
  *
  nPos := RAt("\", cFile)
  IF nPos > 0
     cName := SubStr(cFile, nPos + 1)
  ELSE
     cName := cFile
  ENDIF
  cBuffer := 'begin 777 ' + cName + CRLF
  *
RETURN cBuffer
*
Static FUNCTION EncodeUU(hf,hfOut,cFile)
  LOCAL nBytes
  Local n
  LOCAL cContent
  LOCAL nTotalBytes
  LOCAL cBuffer
  *
  cBuffer     := space(50)
  cContent    := __GetHeader(cFile)
  nTotalBytes := FWrite(hfOut,cContent,Len(cContent) )
  nBytes      := 45
  DO WHILE nBytes == 45
     cContent := ""
     cBuffer  := space(50)
     nBytes   := FRead(hf, @cBuffer,45)
     cContent := GetLineUU(cBuffer,nBytes)+CRLF
     n        := Len(cContent)
     IF FWrite(hfOut,cContent, n ) == n
        nTotalBytes += n
     ELSE
        EXIT
     ENDIF
  ENDDO
  cContent := " " + CRLF + "end" + CRLF
  nBytes   := Len(cContent)
  FWrite(hfOut,cContent, nBytes )
  *
RETURN nTotalBytes
*
Static FUNCTION GetLineUU(cTemp,nReadBytes)
  Local i
  Local c1,c2,c3
  Local x1,x2,x3,x4
  LOCAL cContent
  Local cString
  *
  if nReadBytes < 45
     cContent := ''
  else
     cContent := 'M'
  Endif
  *
  For i := 1 To nReadBytes step 3
     *
     cString := Substr(cTemp,i,3)
     If Len(cString) < 3
        cString := Left(cString+space(3),3)
     Endif
     *
     c1 := DecToBin(Asc(Substr(cString,1,1)))
     c2 := DecToBin(Asc(Substr(cString,2,1)))
     c3 := DecToBin(Asc(Substr(cString,3,1)))
     *
     x1 := Substr(c1+c2+c3, 1,6)
     x2 := Substr(c1+c2+c3, 7,6)
     x3 := Substr(c1+c2+c3,13,6)
     x4 := Substr(c1+c2+c3,19,6)
     *
     cContent += chr(BinToDec(x1)+32)
     cContent += chr(BinToDec(x2)+32)
     cContent += chr(BinToDec(x3)+32)
     cContent += chr(BinToDec(x4)+32)
     *
  Next
  *
Return cContent
*
*
FUNCTION UUDecode(cFile)
  Local oFile
  Local cTitle
  Local nHandle
  *
  Waiting()
  oFile := TFileRead():New(cFile)
  oFile:Open()
  cTiTle := Substr(oFile:ReadLine(),11)
  nHandle := FCreate(cTiTle)
  DO WHILE oFile:MoreToRead()
     UUDecodeLine(oFile:ReadLine(),nHandle)
  ENDDO
  oFile:Close()
  FClose(nHandle)
  Waiting()
  *
Return Nil
*
Static Function UUDecodeLine(cLine, hfOut)
  Local c1,x1
  Local c2,x2
  Local c3,x3
  Local c4
  Local i
  Local cString
  *
  If Left(cLine,1) == 'M'
     cLine := Substr(cLine,2)
  elseIf Left(cLine,3) == 'end' .or. empty(cLine)
     Return Nil
  endif
  *
  For i := 1 To Len(cLine) step 4
     *
     cString := Substr(cLine,i,4)
     *
     c1 := Right(DecToBin(asc(Substr(cString,1,1))-32),6)
     c2 := Right(DecToBin(asc(Substr(cString,2,1))-32),6)
     c3 := Right(DecToBin(asc(Substr(cString,3,1))-32),6)
     c4 := Right(DecToBin(asc(Substr(cString,4,1))-32),6)
     *
     x1 := BinToDec(Substr(c1+c2+c3+c4, 1,8))
     x2 := BinToDec(Substr(c1+c2+c3+c4, 9,8))
     x3 := BinToDec(Substr(c1+c2+c3+c4,17,8))
     *
     FWrite(hfOut,chr(x1)+chr(x2)+chr(x3))
     *
  Next
  *
Return Nil
*
Static FUNCTION BinToDec(cString)
  Local nNumber    := 0
  Local i          := 0
  Local cNewString := AllTrim(cString)
  Local nLen       := Len(cNewString)
  *
  cString := Right('00000000'+cString,8)
  FOR i := 1 to nLen
     nNumber += (At(SubStr(cNewString,i,1),'01')-1)*(2**(nLen-i))
  NEXT
  *
RETURN int(nNumber)
*
Static FUNCTION DecToBin(nNumber,xVal)
  Local cNewString := ''
  Local nTemp      := 0
  *
  hb_Default(@xVal,8)
  *
  DO WHILE (nNumber > 0)
     nTemp      := (nNumber%2)
     cNewString := SubStr('01',(nTemp+1),1)+cNewString
     nNumber    := Int((nNumber-nTemp)/2)
  ENDDO
  *
RETURN Right('00000000'+cNewString,xVal)
