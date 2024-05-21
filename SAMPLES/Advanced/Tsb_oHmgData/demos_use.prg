/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * –абота с базой / Working with the database
*/
#define _HMG_OUTLOG

#include "minigui.ch"

FIELD City, KCity, Street, KStreet, firma, Kfirma
FIELD Bank, KBank, Oplata, KOplata, Operat, KOperat
///////////////////////////////////////////////////////////////////////////////
FUNCTION UseBase(cAlsMain,cDbf)
   LOCAL cUsl, cFor, cInxTemp, aFile, nI, cAls, cPath, cFile

   IF App.Cargo:cLang == "RU" ; cFile := "Plat2024.dbf"
   ELSE                       ; cFile := "Plat2024en.dbf"
   ENDIF

   cPath := App.Cargo:cPathDbf
   cDbf  := cPath + cFile
   IF !File(cDbf)
      AlertStop("Not file !;" + cDbf)
      RETURN .F.
   ENDIF

   // Ёто индекс просто в качестве примера.
   // »ндекс открыт на сервере, может быть много индексов
   USE ( cDbf )  ALIAS (cAlsMain)  NEW SHARED CODEPAGE "RU866"
   If OrdCount() < 1
      cUsl := 'NNN'
      INDEX ON &cUsl TAG NNN
   EndIf

   // временный индекс на локальной станции
   // дл€ работы юзера
   cInxTemp := ChangeFileExt( cDbf, '.temp.cdx' )
   DELETEFILE(cInxTemp)

   cUsl := 'DTOS(DATEVVOD2)+TIMEVVOD2'
   INDEX ON &cUsl  TAG ALL  TO (cInxTemp)
   cUsl := 'IDP'
   INDEX ON &cUsl  TAG DEL  TO (cInxTemp)  FOR  Deleted()   // поле "+"
   //INDEX ON &cUsl  TAG NODEL   FOR  !Deleted()

   // Complex Scope
   cUsl := 'UPPER(DOCUM) + DTOS(DATEVVOD2) + TIMEVVOD2'
   cFor := "CVVOD2 == '22' .AND. !Deleted()"
   INDEX ON &cUsl  TAG DOCDTV  TO (cInxTemp)  FOR  &cFor        // поле "маска ввода за день"

   cUsl := "UPPER(DOCUM)"
   cFor := "CVVOD2 == '22' .AND. !Deleted()"
   INDEX ON &cUsl  TAG ULIST   TO (cInxTemp)  FOR  &cFor UNIQUE // список руч.ввода по всей базе
   INDEX ON &cUsl  TAG ULIST2  TO (cInxTemp)  FOR  &cFor        // все записи ручного ввода

   // список док. за мес€ц года + ручной ввод оператора ( code = '22' )
   cUsl := 'DTOS(DATEVVOD2)'
   cFor := "CVVOD2 == '22' .AND. !Deleted()"
   //cFor := "AT('22',CVVOD2) > 0 .AND. !Deleted()" - функци€ AT() медленна€
   INDEX ON &cUsl  TAG V22DATE  TO (cInxTemp)  FOR  &cFor UNIQUE  // список руч.ввода по всей базе
   INDEX ON &cUsl  TAG V22LIST  TO (cInxTemp)  FOR  &cFor         // все записи ручного ввода
   //------------------------------------------------------------

   IF App.Cargo:cLang == "RU" 
      aFile := { {"City.Dbf","City"} , {"Street.Dbf","Street"} , {"Operat.Dbf","Operat"},;
               {"firma.Dbf","firma"} , {"Bank.Dbf","Bank"} , {"Oplata.Dbf","Oplata"} }
   ELSE
      aFile := { {"City.Dbf","City"} , {"Street.Dbf","Street"} , {"OperatEn.Dbf","Operat"},;
               {"firmaEn.Dbf","firma"} , {"BankEn.Dbf","Bank"} , {"OplataEn.Dbf","Oplata"} }
   ENDIF

   FOR nI := 1 TO LEN(aFile)
      cDbf := cPath + aFile[nI,1]
      cAls := aFile[nI,2]
      USE ( cDbf ) ALIAS (cAls) NEW SHARED CODEPAGE "RU866"
   NEXT

   SELECT City
   If OrdCount() < 1
      INDEX ON KCity       TAG Code
      INDEX ON UPPER(City) TAG Name
   ENDIF

   SELECT Street
   If OrdCount() < 1
      INDEX ON KStreet       TAG Code
      INDEX ON UPPER(Street) TAG Name
   ENDIF

   SELECT firma
   If OrdCount() < 1
      INDEX ON Kfirma       TAG Code
      INDEX ON UPPER(firma) TAG Name
   ENDIF

   SELECT Bank
   If OrdCount() < 1
      INDEX ON KBank       TAG Code
      INDEX ON UPPER(Bank) TAG Name
   ENDIF

   SELECT Oplata
   If OrdCount() < 1
      INDEX ON KOplata       TAG Code
      INDEX ON UPPER(Oplata) TAG Name
   ENDIF

   SELECT Operat
   If OrdCount() < 1
      INDEX ON KOperat       TAG Code
      INDEX ON UPPER(Operat) TAG Name
   ENDIF

   DbSelectArea(cAlsMain)

RETURN .T.

////////////////////////////////////////////////////////////////
// выборка в массив дл€ построени€ списков документов
FUNCTION DbfSelection(nVal,cAls)
   LOCAL aList, aScope, nIndex, cStr, nI, a2Dim, dDate, cMsg
   LOCAL aMonth, aTemp, nMnth, cMnth, nJ, hDim, cKey

   aList  := {}
   aScope := {}
   a2Dim  := {}
   aMonth := {}
   aTemp  := {}
   hDim   := HASH()
   nIndex := INDEXORD()

   IF nVal == 1
      OrdSetFocus("ULIST")     // все записи ручного ввода
      FOR nI := 1 TO ORDKEYCOUNT()  // общее кол-во записей по индексу
         ORDKEYGOTO(nI)
         cStr := ALLTRIM( (cAls)->DOCUM )
         //AADD( aList, cStr )
         //cStr := UPPER((cAls)->DOCUM)
         //AADD( aScope, cStr )
         AADD( a2Dim, { cStr, UPPER((cAls)->DOCUM), DTOS((cAls)->DATEVVOD2) } )
      NEXT
      a2Dim := ASORT( a2Dim,,, { |x, y| x[3] < y[3] } )
      FOR nI := 1 TO LEN(a2Dim)
         AADD( aList , a2Dim[nI,1] )
         AADD( aScope, a2Dim[nI,2] )
      NEXT

   ELSEIF nVal == 2
      IF App.Cargo:cLang # "RU" 
         SET CODEPAGE TO ENGLISH       
         SET LANGUAGE TO ENGLISH       
      ENDIF
      // список док. по мес€цам года + ручной ввод оператора ( code = '22' )
      OrdSetFocus("V22DATE")
      FOR nI := 1 TO ORDKEYCOUNT()  // общее кол-во записей по индексу
         ORDKEYGOTO(nI)
         dDate := (cAls)->DATEVVOD2
         IF App.Cargo:cLang == "RU" 
            cStr := "список ручного ввода от"
         ELSE                       
            cStr := "manual input list from"
         ENDIF
         cStr += " " + DTOC(dDate)
         cMnth := LOWER(CMonth(dDate))
         AADD( a2Dim, { cStr, DTOS(dDate) , Month( dDate ), cMnth } )
      NEXT
      a2Dim := ASORT( a2Dim,,, { |x, y| x[2] < y[2] } )
      ? ProcNL(), "a2Dim=", a2Dim, nJ //; ?v a2Dim
      FOR nI := 1 TO LEN(a2Dim)
         AADD( aList , { a2Dim[nI,1] , a2Dim[nI,3] } )
         AADD( aScope, { a2Dim[nI,2] , a2Dim[nI,3] } )
         // выдел€ем мес€ца года
         nMnth := a2Dim[nI,3]
         cMnth := a2Dim[nI,4]
         cKey := ALLTRIM(STR(nMnth)) + cMnth
         hDim[cKey] := nMnth
      NEXT

      aMonth := HGetValues(hDim)
      //? ProcNL(),"---------- –езультат выборки по мес€цам:"
      //?? "aMonth=",aMonth ; ?v aMonth

   ELSE
      IF App.Cargo:cLang == "RU" ; cMsg := "Ќет обработки"
      ELSE                       ; cMsg := "No processing"
      ENDIF
      AlertStop(cMsg + " nVal="+HB_NtoS(nVal)+;
                 ";" + ProcNL() )
   ENDIF
   //? ProcNL(), "aTemp=", aTemp, "aMonth",aMonth ; ?v aMonth

   OrdSetFocus(nIndex)
   DbGotop()

RETURN {aList, aScope, aMonth}

////////////////////////////////////////////////////////////////
FUNCTION SAY_SEL_DIM(nCode, cAlias, cField)
   LOCAL cAlsMain := ALIAS()
   LOCAL nOrder, xRet

   DbSelectArea(cAlias)
   nOrder := INDEXORD()
   DBSETORDER(1)
   GOTO TOP
   SEEK nCode
   IF FOUND()
      xRet := (cAlias)->&cField
      IF IsString(xRet)
         xRet := ALLTRIM(xRet) //HB_OEMTOANSI(xRet)
      ELSE
         xRet := cValToChar(xRet)
      ENDIF
   ELSE
      IF App.Cargo:cLang == "RU" ; xRet := "нет данных"
      ELSE                       ; xRet := "no data"
      ENDIF
      xRet += " = " + HB_NtoS(nCode)
   ENDIF
   DbSetOrder(nOrder)
   DbSelectArea(cAlsMain)

RETURN xRet

//////////////////////////////////////////////////////////////////////////
FUNCTION Itogo_Dbf(aFld, cAls, aWait)  // расчЄты итого по базе
   LOCAL nLen := 0, nRec, aItg, aPos, nPos, cScope := ""
   LOCAL nOld := Select(), nCnt := 0, nSum
   Default cAls := Alias(), aWait := .F.

   IF !Empty(aWait)
      IF HB_ISLOGICAL(aWait)
         aWait := "Wait processing ..."
      ENDIF
      WaitWindow( aWait, .T. , 600, 16, NIL, BLUE, App.Cargo:aBClrMain )
   ENDIF

   dbSelectArea( cAls )

   nRec := RecNo()
   aItg := Array(Len(aFld)) ; aFill(aItg, 0)
   aPos := {} ; AEval(aFld, {|cn| AAdd(aPos, FieldPos(cn)) })

   DO EVENTS
   GO TOP
   DO WHILE ! EOF()
      nCnt++
      DO EVENTS
      FOR EACH nPos IN aPos
          IF nPos > 0 .and. HB_ISNUMERIC( nSum := FieldGet( nPos ) )
             aItg[ hb_EnumIndex(nPos) ] += nSum
          ENDIF
      NEXT
      SKIP
   ENDDO

   DbGoTo( nRec )       ; DO EVENTS

   IF !Empty(aWait)     ; WaitWindow()
   ENDIF

   dbSelectArea( nOld ) ; DO EVENTS

RETURN { nCnt, aItg }

