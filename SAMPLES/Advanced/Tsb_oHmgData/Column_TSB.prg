/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Cписок колонок таблицы / List of table columns
*/
#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"
///////////////////////////////////////////////////////////////////////////////////////////
FUNCTION Column_TSB( oTsb, cAls )   // список колонок таблицы
   LOCAL aDim[29], a, i, n, j, oDlu, cFld, cType, bBlock, lEdit, c8Col, aIconDel, aFldSum
   LOCAL aKey[10], cMsg, cErr, lFind, aImgColumn, nHImage, aDcd, aIcon, aField, aName

   IF App.Cargo:cLang == "RU"   
   // ВНИМАНИЕ ! В базе должно быть поле PUSTO,KR2 которое не используется, это нужно для :LoadFields()
   //            1    2    3            4                  5               6                7             8            9              10
   //         ИТОГО|Edit| тип | название колонок      | поле бд/функц.| ширина поля  | формат поля |блок кода | *F функция1    |  **F функция2
   aDim[1 ] := { 0 , "R","BMP", "*"                   , "KR2"         , "XXX"        , "999"       , "bKey01" , "внутри кода"  , nil }
   aDim[2 ] := { 0 , "W", "D" , "Дата;оплаты"         , "PRIDAT"      , "99099099000", "99.99.99"  , nil      , nil            , "CheckDate()"  } // проверка после ввода
   aDim[3 ] := { 1 , "W", "N" , "Сумма;(руб.)"        , "PRIXOD"      , REPL("9",12) , "999 999.99", nil      , nil , nil }
   aDim[4 ] := { 0 , "W", "C" , "Л/с;абонента"        , "RC_ABON"     , REPL("A",10) , REPL("x",8) , nil      , nil , "SeekAbonRc()"  } // поиск после ввода
   aDim[5 ] := { 0 , "W", "C" , "5 - Л/с абонента"    , "RC_NEW18"    , REPL("A",20) , REPL("x",18), nil      , nil , "SeekAbonRc18()" } // поиск после ввода
   //                                                                                    так не надо --- VVV
   //aDim[6 ] := { 1 , "W","BMP", "Тип;файла"           , "KR1"         , "999"        , "999"       , "bKey06" , "myImage()" , nil }
   aDim[6 ] := { 0 , "W","BMP", "Тип;файла"           , "KR1"         , "999"        , "999"       , nil      , "myImage()" , nil }
   aDim[7 ] := { 0 , "W", "C" , "Ф.И.О. абонента"     , "FIO"         , REPL("A",27) , REPL("x",35), nil      , nil , nil }
   aDim[8 ] := { 0 , "W", "C" , "Примечание по оплате", "REM"         , REPL("A",24) , REPL("x",35), nil      , nil , nil }
   aDim[9 ] := { 0 , "W", "J" , "Адрес плательщика"   , "ADRESPRN"    , REPL("x",31) , REPL("A",35), nil      , "myAdres()" , nil }   // сделать самостоятельно
   aDim[10] := { 0 , "W", "C" , "Телефон;абонента"    , "TELFIO"      , REPL("A",15) , REPL("x",15), nil      , nil , nil }
   aDim[11] := { 0 , "W", "N" , "No платеж.;поручения", "NUMPLATP"    , REPL("9",11) , REPL("9",8) , nil      , nil , nil }
   aDim[12] := { 0 , "R", "C" , "No документа оплаты" , "DOCUM"       , REPL("a",30) , REPL("x",40), nil      , nil , nil }
   aDim[13] := { 0 , "R", "C" , "No пачки"            , "BOX"         , REPL("a",10) , REPL("x",10), nil      , nil , nil }
   aDim[14] := { 0 , "W", "S" , "Вид оплаты"          , "KOPLATA"     , REPL("a",20) , REPL("x",20), "bKey12" , {"Oplata","KOplata","Oplata","Вид оплаты","Name",""}     , nil }
   aDim[15] := { 0 , "W", "S" , "Фирма"               , "KFIRMA"      , REPL("a",20) , REPL("x",20), "bKey15" , {"Firma" ,"KFirma" ,"Firma" ,"Фирма","Name",""}          , nil }
   aDim[16] := { 0 , "W", "S" , "Банк получателя"     , "KBANK"       , REPL("a",20) , REPL("x",20), "bKey16" , {"Bank"  ,"KBank"  ,"Bank"  ,"Банк получателя","Name",""}, nil }
   aDim[17] := { 0 , "W", "J" , "Оплата услуги"       , "KDMFANT"     , REPL("a",20) , REPL("x",20), "bKey17" , "Vvod_Usluga()"    ,  nil }
   aDim[18] := { 0 , "W", "S" , "Кем введено"         , "KOPERAT0"    , REPL("A",25) , REPL("x",25), "bKey18" , {"Operat","KOperat","Operat","Операторы","Name",""}      , nil }
   aDim[19] := { 0 , "R", "C" , "Дата/время создания" , "PUSTO"       , REPL("A",25) , REPL("A",25), "bKey19" , nil , nil }
   aDim[20] := { 0 , "R", "S" , "Кто правил"          , "KOPERAT"     , REPL("A",25) , REPL("x",25), "bKey20" , {"Operat","KOperat","Operat","Операторы","Name",""}      , nil }
   aDim[21] := { 0 , "R", "C" , "Дата/время правки"   , "PUSTO"       , REPL("A",22) , REPL("A",23), "bKey21" , nil , nil }
   aDim[22] := { 0 , "R", "+" , "ID recno"            , "IDP"         , REPL("9",9)  , REPL("9",8) , nil      , nil , nil }
   aDim[23] := { 0 , "R", "=" , "TS recno"            , "TSP"         , REPL("9",23) , REPL("9",22), nil      , nil , nil }
   aDim[24] := { 1 , "W", "N" , "Разное-1;(метр)"     , "TARIF"       , REPL("9",10) , "999.9999"  , nil      , nil , nil }
   aDim[25] := { 1 , "W", "N" , "Разное-2;(%.)"       , "NACHIS"      , REPL("9",10) , "99999.99"  , nil      , nil , nil }
   aDim[26] := { 1 , "W", "N" , "Разное-3;(коп.)"     , "DOBAVKA"     , REPL("9",10) , "99999.99"  , nil      , nil , nil }
   aDim[27] := { 0 , "W", "@" , "DT_Test"             , "DT_TEST"     , REPL("9",23) , REPL("9",22), nil      , nil , nil }
   aDim[28] := { 0 , "W", "L" , "*-*"                 , "MARK"        , REPL("X",5)  , REPL("X",1) , nil      , nil , nil }
   aDim[29] := { 0 , "W", "M" , "Мемо-поле"           , "FMEMO"       , REPL("X",15) , REPL("X",80), nil      , nil , nil }
   //            1    2    3            4                  5               6                7             8            9              10
   ELSE
      aDim[1 ] := { 0 , "R","BMP", "*"                 , "KR2"        , "XXX"        , "999"       , "bKey01" , "внутри кода"  , nil }
      aDim[2 ] := { 0 , "W", "D" , "Payment;Date"      , "PRIDAT"     , "99099099000", "99.99.99"  , nil , nil , "CheckDate()" } // check after entering
      aDim[3 ] := { 1 , "W", "N" , "Amount;(RUB)"      , "PRIXOD"     , REPL("9",12) , "999 999.99", nil , nil , nil }
      aDim[4 ] := { 0 , "W", "C" , "Payer;pers.acc."   , "RC_ABON"    , REPL("A",10) , REPL("x",8) , nil , nil , "SeekAbonRc()" } // search after entering
      aDim[5 ] := { 0 , "W", "C" , "Payer;5-pers.account", "RC_NEW18" , REPL("A",20) , REPL("x",18), nil , nil , "SeekAbonRc18()" } // search after entering
      aDim[6 ] := { 0 , "W","BMP", "FileType"          , "KR1"        , "999"        , "999"       , nil , "myImage()" , nil }
      aDim[7 ] := { 0 , "W", "C" , "Subscrib.full name", "FIO"        , REPL("A",27) , REPL("x",35), nil , nil , nil }
      aDim[8 ] := { 0 , "W", "C" , "Payment note"      , "REM"        , REPL("A",24) , REPL("x",35), nil , nil , nil }
      aDim[9 ] := { 0 , "W", "J" , "Payer Address"     , "ADRESPRN"   , REPL("x",31) , REPL("A",35), nil , "myAdres() " , nil } // do it yourself
      aDim[10] := { 0 , "W", "C" , "Phone;subscriber"  , "TELFIO"     , REPL("A",15) , REPL("x",15), nil , nil , nil }
      aDim[11] := { 0 , "W", "N" , "№ payment;instruct.", "NUMPLATP"  , REPL("9",11) , REPL("9",8) , nil , nil , nil }
      aDim[12] := { 0 , "R", "C" , "№ payment document", "DOCUM"      , REPL("a",30) , REPL("x",40), nil , nil , nil }
      aDim[13] := { 0 , "R", "C" , "№ pack"            , "BOX"        , REPL("a",10) , REPL("x",10), nil , nil , nil }
      aDim[14] := { 0 , "W", "S" , "Payment type"      , "KOPLATA"    , REPL("a",20) , REPL("x",20), "bKey12" , {" Oplata","KOplata","Oplata","Payment type","Name",""} , nil }
      aDim[15] := { 0 , "W", "S" , "Firm's"            , "KFIRMA"     , REPL("a",20) , REPL("x",20), "bKey15" , {"Firma " ,"KFirma" ,"Firma" ,"Firm","Name",""} , nil }
      aDim[16] := { 0 , "W", "S" , "Recipient's bank"  , "KBANK"      , REPL("a",20) , REPL("x",20), "bKey16" , {" Bank" ,"KBank" ,"Bank" ,"Recipient's bank","Name",""}, nil }
      aDim[17] := { 0 , "W", "J" , "Payment service"   , "KDMFANT"    , REPL("a",20) , REPL("x",20), "bKey17" , "Vvod_Usluga ()", nil }
      aDim[18] := { 0 , "W", "S" , "Input by"          , "KOPERAT0"   , REPL("A",25) , REPL("x",25), "bKey18" , {" Operat","KOperat","Operat","Operators","Name",""} , nil }
      aDim[19] := { 0 , "R", "C" , "Date/time;of creation", "PUSTO"   , REPL("A",25) , REPL("A",25), "bKey19" , nil, nil}
      aDim[20] := { 0 , "R", "S" , "Who ruled"         , "KOPERAT"    , REPL("A",25) , REPL("x",25), "bKey20" , {" Operat","KOperat","Operat","Operators","Name",""} , nil }
      aDim[21] := { 0 , "R", "C" , "Date/time;of edit" , "PUSTO"      , REPL("A",22) , REPL("A",23), "bKey21" , nil , nil }
      aDim[22] := { 0 , "R", "+" , "ID recno"          , "IDP"        , REPL("9",9)  , REPL("9",8) , nil      , nil , nil }
      aDim[23] := { 0 , "R", "=" , "TS recno"          , "TSP"        , REPL("9",23) , REPL("9",22), nil      , nil , nil }
      aDim[24] := { 1 , "W", "N" , "Miscellaneous-1"   , "TARIF"      , REPL("9",10) , "999.9999"  , nil      , nil , nil }
      aDim[25] := { 1 , "W", "N" , "Miscellaneous-2"   , "NACHIS"     , REPL("9",10) , "99999.99"  , nil      , nil , nil }
      aDim[26] := { 1 , "W", "N" , "Miscellaneous-3"   , "DOBAVKA"    , REPL("9",10) , "99999.99"  , nil      , nil , nil }
      aDim[27] := { 0 , "W", "@" , "DT_Test"           , "DT_TEST"    , REPL("9",23) , REPL("9",22), nil      , nil , nil }
      aDim[28] := { 0 , "W", "L" , "*-*"               , "MARK"       , REPL("X",5)  , REPL("X",1) , nil      , nil , nil }
      aDim[29] := { 0 , "W", "M" , "Memo-field"        , "FMEMO"      , REPL("X",15) , REPL("X",80), nil      , nil , nil }
   ENDIF
   // это замена строк для вывода в колонке
   aKey[1]  := { "bKey01", {|| Nil  }                                             }
   aKey[2]  := { "bKey06", FieldWBlock( "KR1", SELECT() ) /*FieldBlock("KR1")*/   }   // только так
   aKey[3]  := { "bKey12", {|| SAY_SEL_DIM(FIELD->KOPLATA, "Oplata", "Oplata")  } }   // Вид оплаты
   aKey[4]  := { "bKey15", {|| SAY_SEL_DIM(FIELD->KFIRMA , "FIRMA" , "FIRMA")   } }   // Фирма
   aKey[5]  := { "bKey16", {|| SAY_SEL_DIM(FIELD->KBANK  , "Bank"  , "Bank")    } }   // Банк получателя
   aKey[6]  := { "bKey17", {|| DimUsluga(FIELD->KDMFANT)                        } }   // Оплата услуги
   aKey[7]  := { "bKey18", {|| SAY_SEL_DIM(FIELD->KOPERAT0,"Operat", "Operat")  } }   // Кем введено
   aKey[8]  := { "bKey19", {|| DTOC(FIELD->DATEVVOD2)+' '+FIELD->TIMEVVOD2      } }   // Дата/время создания
   aKey[9]  := { "bKey20", {|| SAY_SEL_DIM(FIELD->KOPERAT,"Operat", "Operat")   } }   // Кто правил
   aKey[10] := { "bKey21", {|| myFldTime()                                      } }   // Дата/время правки
   cErr     := ""

   // Как сделать чтобы показывало последние 30 символов из строки в колонке ?
   // oCol:bDecode := {|ca| ca := trim(ca), iif( Len(ca) > 30, "..."+right(ca, 30), ca ) }
   aDcd := ARRAY(LEN(aDim))
   AFILL(aDcd, "" )
   aDcd[9] := {|ca| ca := trim(ca), iif( Len(ca) > 27, ".."+right(ca, 27), ca ) }

   // Сумма колонок в подвале таблицы
   //aSumm := {"PRIXOD","TARIF","NACHIS","DOBAVKA"} - Первая колонка: ИТОГО
   aField := {} ; aName := {} ; aFldSum := {}
   AEval(aDim, {|a|
                    AAdd(aField, a[5])
                    AAdd(aName , a[5])
                    IF !Empty(a[1])
                       IF     a[1] == 1         // обычный вывод итога
                          AAdd(aFldSum, a[5])
                       ELSEIF a[1] == 2         // другой вывод итога - пример
                       // AAdd(aItgOther, a[5]) // т.е. др. алгоритм
                       ENDIF
                    ENDIF
                    Return Nil
                    })
   This.Cargo:aFldSum := aFldSum  // запомним на окне

   // Иконки для контекстного меню - тип "S"
   aIcon := ARRAY(LEN(aDim))
   AFILL(aIcon, "" )
   aIcon[14] := { 24, "iRuble24"  }    // Вид оплаты
   aIcon[15] := { 24, "iFirma24"  }    // Фирма
   aIcon[16] := { 24, "iBank24"   }    // Банк получателя
   aIcon[18] := { 32, "iUser32"   }    // Кем введено
   aIcon[20] := { 32, "iUser32"   }    // Кто правил
   aIconDel  := { 32, "iDelVal32" }    // удалить значение

   // картинки в таблице
   nHImage     := 32               // высота картинки в таблице
   oTsb:nHBmp  := nHImage          // запомним для таблицы

   // колонка с картинками
   aImgColumn  := myLoadBmpTsb(1,nHImage)
   oTsb:aBmp1  := { aImgColumn[1], aImgColumn[2], aImgColumn[3], aImgColumn[4] }

   // колонка с картинками
   aImgColumn  := myLoadBmpTsb(6,nHImage)
   oTsb:aBmp6  := { aImgColumn[1], aImgColumn[2], aImgColumn[3], aImgColumn[4] }

   oTsb:cAls      := cAls
   //                    cell     Head   foot    SpecHider  SuperHider   Edit
   oTsb:aFont     := { "Normal", "Bold", "Bold", "SpecHdr" , "ItalBold", "TsbEdit" }
   oTsb:lSpecHd   := .T.
   oTsb:aHead     := {}
   oTsb:aField    := {}
   oTsb:aPict     := {}
   oTsb:aSize     := {}  // !!! :aSize - менять нельзя, определено в _TBrowse(...)
   oTsb:aName     := {}
   oTsb:aFoot     := {}  // .T.
   oTsb:aEdit     := {}  // .T.    // редактировать все колонки
   oTsb:aColPrc   := {}
   oTsb:aFunc1    := {}
   oTsb:aFunc2    := {}
   oTsb:aBlock    := {}
   oTsb:aDecode   := {}   // для колонки oCol:bDecode
   oTsb:aCntMnu   := {}   // иконки для контекстного меню - тип "S"
   oTsb:aTable    := aDim
   oTsb:aClrBrush := { 176, 222, 251 }  // цвет фона под таблицей
   oTsb:aNumber   := { 1, 50 }
   oTsb:aSupHd    := { "1" + CRLF + "2" + CRLF + "3" }
   oTsb:aIconDel  := aIconDel    // удалить значение

   IF ( i := GetControlIndex( oTsb:aFont[1], "Main" ) ) > 0
      n := _HMG_aControlFontSize[ i ]
   ELSE
      n := _HMG_DefaultFontSize
   ENDIF

   oDlu := oDlu4Font( n )

   FOR EACH a IN aDim
       i := hb_EnumIndex(a)
       AAdd(oTsb:aHead , StrTran(a[4], ";", CRLF)  )
       AAdd(oTsb:aSize , oDlu:TextWidth(a[6])      )  // !!! :aSize - менять нельзя, определено в _TBrowse(...)
       AAdd(oTsb:aName , a[5]   ) // "NAME_"+HB_NtoS(i) )
       AAdd(oTsb:aFoot , a[5]   ) // "NAME_"+HB_NtoS(i) )
       cFld  := a[5]
       cType := a[3]
       c8Col := a[8]   // проверка на поля - составные
       IF !IsString(c8Col)
          c8Col := ''
       ENDIF
       // поиск ключа для блока кода в массиве aKey[?]
       bBlock := ''
       IF LEN(c8Col) > 0
          lFind := .F.
          FOR j := 1 TO LEN(aKey)
             IF UPPER(c8Col) == UPPER(aKey[j,1])
                bBlock := aKey[j,2]
                lFind := .T.
                EXIT
             ENDIF
          NEXT
          IF !lFind
             cErr += "Нет ключа: " + c8Col + ";"
          ENDIF
       ENDIF
       // добавим блок кода
       AAdd(oTsb:aBlock, bBlock )
       // добавим поля базы
       AAdd(oTsb:aField, upper(cFld) )

       lEdit := IIF( a[2] == "W", .T., .F. )  // доступ к колонке: "R" чтение, "W" запись
       AAdd(oTsb:aEdit, lEdit  )

       // моя добавочная обработка
       AAdd(oTsb:aColPrc , cType    )  // тип обработки колонки: "BMP", "K", "S", "C", "N", "D"
       AAdd(oTsb:aFunc1  , a[9]     )  // функция-1 :bPrevEdit для обработки колонки таблицы
       AAdd(oTsb:aFunc2  , a[10]    )  // функция-2 :bPostEdit для обработки колонки таблицы
       AAdd(oTsb:aDecode , aDcd[i]  )  // для колонки oCol:bDecode
       AAdd(oTsb:aCntMnu , aIcon[i] )  // иконки для контекстного меню - тип "S"
   NEXT
   //
   IF LEN(cErr) > 0
      IF App.Cargo:cLang == "RU"
      cMsg := "ОШИБКА !;"
      cMsg += "Поиск ключа для блока кода в массиве aKey[?];;"
      ELSE
      cMsg := "ERROR!;"
      cMsg += "Searching for a key for a code block in the array aKey[?];;"
      ENDIF
      cMsg += ProcNL()
      AlertStop(cMsg + cErr, ProcNL() )
   ENDIF

   oTsb:aDim := aDim    // массив колонок таблицы - сохраним
   ? ProcNL(), "oTsb:aDim=", oTsb:aDim
   ?v oTsb:aDim

RETURN aDim

//////////////////////////////////////////////////////////////////
FUNCTION myLoadBmpTsb(nCol,nHImg)
   LOCAL aRet, aBmp, aHandle, bBmpCell, nI, nK
   LOCAL aBmp1 := {"bMinus32", "bZero32", "bPlus32"}
   LOCAL aBmp6 := {"bFWord32","bFExcel32","bFCalc32","bFText32","bFCSV32","bFZero32"}
   LOCAL aMsg6 := {"File MS Word", "File MS Excel", "File OO Calc", "File *.txt",;
                   "File *.csv", "Delete value" }
   IF nCol == 1
      //Логика - правка другого поля/колонки
      aBmp    := aBmp1
      nK      := LEN(aBmp)
      aHandle := ARRAY(nK)
      FOR nI := 1 TO nK
         aHandle[nI] := LoadImage(aBmp[nI],,nHImg,nHImg)
      NEXT
      bBmpCell := {|nc,ob| // показ картинки в зависимости от суммы поля PRIXOD
                          Local ocol := ob:aColumns[nc]
                          Local ni   := 0
                          Local nSum := ob:GetValue("PRIXOD")  // колонка суммы
                          IF !IsNumeric(nSum)
                             nSum := 0
                          ENDIF
                          IF nSum < 0
                             ni := 1
                          ELSEIF nSum == 0
                             ni := 2
                          ELSE
                             ni := 3
                          ENDIF
                          Return ocol:aBitMaps[ni]  // картинку с позиции массива
                          }
      aRet := { aBmp, aHandle, bBmpCell, {} }
   ELSEIF nCol == 6
      // Логика - правка этого поля/колонки KR1
      aBmp    := aBmp6
      nK      := LEN(aBmp)
      aHandle := ARRAY(nK)
      FOR nI := 1 TO nK
         aHandle[nI] := LoadImage(aBmp[nI],,nHImg,nHImg)
      NEXT
      bBmpCell := {|nc,ob| // показ картинки в зависимости от поля KR1
                          Local ocol  := ob:aColumns[nc]
                          Local ni    := 0                      // bFZero32
                          Local nMax  := LEN(ocol:aBitMaps)     // bFZero32
                          Local nCode := ob:GetValue("KR1")  // колонка коды типа файлов
                          //? ProcName(), nCode, ocol:cName, ocol:cField
                          nCode := FIELDGET(FIELDNUM(ocol:cField))  // можно и так
                          IF !IsNumeric(nCode)
                             nCode := 0
                          ENDIF
                          IF nCode <= 0 .OR. nCode >= nMax
                             ni := nMax
                          ELSE
                             ni := nCode
                          ENDIF
                          Return ocol:aBitMaps[ni]  // картинку с позиции массива
                          }
      aRet := { aBmp, aHandle, bBmpCell, aMsg6 }
   ELSE
      AlertStop("Нет такой колонки !; nCol="+ HB_NtoS(nCol)+";"+ ProcNL())
      aRet := {}
   ENDIF

RETURN aRet

//////////////////////////////////////////////////////////////////////////
FUNCTION Column_Init( ob, op )
   Local oCol, aDim, nI, nJ, nO, nS, bBlock, aBlock, nLen, cStr, nMax
   Local aColPrc, aFunc1, aFunc2, aDecode, bDecode

   // моя добавочная обработка
   aDim    := op:aDim     // весь массив таблицы
   aBlock  := op:aBlock   // блок кода
   aColPrc := op:aColPrc  // тип обработки колонки: "BMP", "K", "S", "C", "N", "D"
   aFunc1  := op:aFunc1   // функция-1 :bPrevEdit для обработки колонки таблицы
   aFunc2  := op:aFunc2   // функция-2 :bPostEdit для обработки колонки таблицы
   aDecode := op:aDecode  // для колонки oCol:bDecode
   nMax    := 0

   nO := IIF( ob:nColumn("ORDKEYNO", .T.) > 0, 1, 0) // проверка поля, если нет, то будет 0
   nS := IIF( ob:lSelector, 1, 0 )   // если есть/нет селектор
   nJ := nO + nS
   ? ProcNL(), "ORDKEYNO:", nO, "lSelector:", nS

   FOR EACH oCol IN ob:aColumns
      cStr := ATREPL( CRLF, oCol:cHeading, "|" )
      nMax := MAX( nMax, LEN(cStr) )
   NEXT

   // меняем поля на блок кода и ставим итого по колонкам
   FOR EACH oCol IN ob:aColumns
       nI := hb_EnumIndex(oCol)
       ? nI, oCol:cName, PADR( ATREPL( CRLF, oCol:cHeading, "|" ), nMax ) + ","
       ?? oCol:cField
       oCol:Cargo := oHmgData()
       oCol:Cargo:cName  := oCol:cName
       oCol:Cargo:lTotal := .F.
       oCol:Cargo:nTotal :=  0                 // итог по колонке
       IF nI <= ob:nColumn("ORDKEYNO") ; LOOP
       ENDIF
       nJ := nI - nO // учитываем колонку ORDKEYNO
       IF aDim[nJ,1] == 1
          oCol:Cargo:lTotal := .T.
       ENDIF
       IF oCol:Cargo:lTotal
          // это ф-я вывода из Cargo колонки значение итога в oCol:cFooting,
          // выполнив записаный туда блок кода методом oBrw:DrawFooters()
          oCol:cFooting := {|nc,ob|
                            Local oc, cv, nv
                            oc := ob:aColumns[ nc ]
                            nv := oc:Cargo:nTotal
                            cv := iif( Empty(nv), "", hb_ntos(nv) )
                            Return cv
                            }
          ?? "lTotal"
       ENDIF
       IF nJ > 0
          bBlock := aBlock[nJ]
          IF ISBLOCK(bBlock)
            ?? "bBlock=" , bBlock
            //oCol:bData  := &(bBlock)
            oCol:bData    := bBlock
            oCol:nAlign   := DT_LEFT
            nLen          := LEN(aDim[nJ,6])  // ширина поля - 6 значение
            oCol:nWidth   := oCol:ToWidth( REPL("a",nLen) )
            oCol:cPicture := aDim[nJ,7]       // формат поля
            //oCol:l3DLook   := .T.
            oCol:l3DTextCell := .T.
            //oCol:nClr3DLCell := CLR_RED
          ENDIF
          //?? VALTYPE(bBlock), bBlock
          bDecode := aDecode[nJ]
          IF ISBLOCK(bDecode)
             ?? "bDecode=", bDecode
             oCol:bDecode := bDecode
          ENDIF
          //oCol:cFooting := ""
       ENDIF
   NEXT

RETURN NIL
