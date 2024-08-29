/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * C����� ������� ������� / List of table columns
*/
#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"
///////////////////////////////////////////////////////////////////////////////////////////
FUNCTION Column_TSB( oTsb, cAls )   // ������ ������� �������
   LOCAL aDim[29], a, i, n, j, oDlu, cFld, cType, bBlock, lEdit, c8Col, aIconDel, aFldSum
   LOCAL aKey[10], cMsg, cErr, lFind, aImgColumn, nHImage, aDcd, aIcon, aField, aName

   IF App.Cargo:cLang == "RU"   
   // �������� ! � ���� ������ ���� ���� PUSTO,KR2 ������� �� ������������, ��� ����� ��� :LoadFields()
   //            1    2    3            4                  5               6                7             8            9              10
   //         �����|Edit| ��� | �������� �������      | ���� ��/�����.| ������ ����  | ������ ���� |���� ���� | *F �������1    |  **F �������2
   aDim[1 ] := { 0 , "R","BMP", "*"                   , "KR2"         , "XXX"        , "999"       , "bKey01" , "������ ����"  , nil }
   aDim[2 ] := { 0 , "W", "D" , "����;������"         , "PRIDAT"      , "99099099000", "99.99.99"  , nil      , nil            , "CheckDate()"  } // �������� ����� �����
   aDim[3 ] := { 1 , "W", "N" , "�����;(���.)"        , "PRIXOD"      , REPL("9",12) , "999 999.99", nil      , nil , nil }
   aDim[4 ] := { 0 , "W", "C" , "�/�;��������"        , "RC_ABON"     , REPL("A",10) , REPL("x",8) , nil      , nil , "SeekAbonRc()"  } // ����� ����� �����
   aDim[5 ] := { 0 , "W", "C" , "5 - �/� ��������"    , "RC_NEW18"    , REPL("A",20) , REPL("x",18), nil      , nil , "SeekAbonRc18()" } // ����� ����� �����
   //                                                                                    ��� �� ���� --- VVV
   //aDim[6 ] := { 1 , "W","BMP", "���;�����"           , "KR1"         , "999"        , "999"       , "bKey06" , "myImage()" , nil }
   aDim[6 ] := { 0 , "W","BMP", "���;�����"           , "KR1"         , "999"        , "999"       , nil      , "myImage()" , nil }
   aDim[7 ] := { 0 , "W", "C" , "�.�.�. ��������"     , "FIO"         , REPL("A",27) , REPL("x",35), nil      , nil , nil }
   aDim[8 ] := { 0 , "W", "C" , "���������� �� ������", "REM"         , REPL("A",24) , REPL("x",35), nil      , nil , nil }
   aDim[9 ] := { 0 , "W", "J" , "����� �����������"   , "ADRESPRN"    , REPL("x",31) , REPL("A",35), nil      , "myAdres()" , nil }   // ������� ��������������
   aDim[10] := { 0 , "W", "C" , "�������;��������"    , "TELFIO"      , REPL("A",15) , REPL("x",15), nil      , nil , nil }
   aDim[11] := { 0 , "W", "N" , "No ������.;���������", "NUMPLATP"    , REPL("9",11) , REPL("9",8) , nil      , nil , nil }
   aDim[12] := { 0 , "R", "C" , "No ��������� ������" , "DOCUM"       , REPL("a",30) , REPL("x",40), nil      , nil , nil }
   aDim[13] := { 0 , "R", "C" , "No �����"            , "BOX"         , REPL("a",10) , REPL("x",10), nil      , nil , nil }
   aDim[14] := { 0 , "W", "S" , "��� ������"          , "KOPLATA"     , REPL("a",20) , REPL("x",20), "bKey12" , {"Oplata","KOplata","Oplata","��� ������","Name",""}     , nil }
   aDim[15] := { 0 , "W", "S" , "�����"               , "KFIRMA"      , REPL("a",20) , REPL("x",20), "bKey15" , {"Firma" ,"KFirma" ,"Firma" ,"�����","Name",""}          , nil }
   aDim[16] := { 0 , "W", "S" , "���� ����������"     , "KBANK"       , REPL("a",20) , REPL("x",20), "bKey16" , {"Bank"  ,"KBank"  ,"Bank"  ,"���� ����������","Name",""}, nil }
   aDim[17] := { 0 , "W", "J" , "������ ������"       , "KDMFANT"     , REPL("a",20) , REPL("x",20), "bKey17" , "Vvod_Usluga()"    ,  nil }
   aDim[18] := { 0 , "W", "S" , "��� �������"         , "KOPERAT0"    , REPL("A",25) , REPL("x",25), "bKey18" , {"Operat","KOperat","Operat","���������","Name",""}      , nil }
   aDim[19] := { 0 , "R", "C" , "����/����� ��������" , "PUSTO"       , REPL("A",25) , REPL("A",25), "bKey19" , nil , nil }
   aDim[20] := { 0 , "R", "S" , "��� ������"          , "KOPERAT"     , REPL("A",25) , REPL("x",25), "bKey20" , {"Operat","KOperat","Operat","���������","Name",""}      , nil }
   aDim[21] := { 0 , "R", "C" , "����/����� ������"   , "PUSTO"       , REPL("A",22) , REPL("A",23), "bKey21" , nil , nil }
   aDim[22] := { 0 , "R", "+" , "ID recno"            , "IDP"         , REPL("9",9)  , REPL("9",8) , nil      , nil , nil }
   aDim[23] := { 0 , "R", "=" , "TS recno"            , "TSP"         , REPL("9",23) , REPL("9",22), nil      , nil , nil }
   aDim[24] := { 1 , "W", "N" , "������-1;(����)"     , "TARIF"       , REPL("9",10) , "999.9999"  , nil      , nil , nil }
   aDim[25] := { 1 , "W", "N" , "������-2;(%.)"       , "NACHIS"      , REPL("9",10) , "99999.99"  , nil      , nil , nil }
   aDim[26] := { 1 , "W", "N" , "������-3;(���.)"     , "DOBAVKA"     , REPL("9",10) , "99999.99"  , nil      , nil , nil }
   aDim[27] := { 0 , "W", "@" , "DT_Test"             , "DT_TEST"     , REPL("9",23) , REPL("9",22), nil      , nil , nil }
   aDim[28] := { 0 , "W", "L" , "*-*"                 , "MARK"        , REPL("X",5)  , REPL("X",1) , nil      , nil , nil }
   aDim[29] := { 0 , "W", "M" , "����-����"           , "FMEMO"       , REPL("X",15) , REPL("X",80), nil      , nil , nil }
   //            1    2    3            4                  5               6                7             8            9              10
   ELSE
      aDim[1 ] := { 0 , "R","BMP", "*"                 , "KR2"        , "XXX"        , "999"       , "bKey01" , "������ ����"  , nil }
      aDim[2 ] := { 0 , "W", "D" , "Payment;Date"      , "PRIDAT"     , "99099099000", "99.99.99"  , nil , nil , "CheckDate()" } // check after entering
      aDim[3 ] := { 1 , "W", "N" , "Amount;(RUB)"      , "PRIXOD"     , REPL("9",12) , "999 999.99", nil , nil , nil }
      aDim[4 ] := { 0 , "W", "C" , "Payer;pers.acc."   , "RC_ABON"    , REPL("A",10) , REPL("x",8) , nil , nil , "SeekAbonRc()" } // search after entering
      aDim[5 ] := { 0 , "W", "C" , "Payer;5-pers.account", "RC_NEW18" , REPL("A",20) , REPL("x",18), nil , nil , "SeekAbonRc18()" } // search after entering
      aDim[6 ] := { 0 , "W","BMP", "FileType"          , "KR1"        , "999"        , "999"       , nil , "myImage()" , nil }
      aDim[7 ] := { 0 , "W", "C" , "Subscrib.full name", "FIO"        , REPL("A",27) , REPL("x",35), nil , nil , nil }
      aDim[8 ] := { 0 , "W", "C" , "Payment note"      , "REM"        , REPL("A",24) , REPL("x",35), nil , nil , nil }
      aDim[9 ] := { 0 , "W", "J" , "Payer Address"     , "ADRESPRN"   , REPL("x",31) , REPL("A",35), nil , "myAdres() " , nil } // do it yourself
      aDim[10] := { 0 , "W", "C" , "Phone;subscriber"  , "TELFIO"     , REPL("A",15) , REPL("x",15), nil , nil , nil }
      aDim[11] := { 0 , "W", "N" , "� payment;instruct.", "NUMPLATP"  , REPL("9",11) , REPL("9",8) , nil , nil , nil }
      aDim[12] := { 0 , "R", "C" , "� payment document", "DOCUM"      , REPL("a",30) , REPL("x",40), nil , nil , nil }
      aDim[13] := { 0 , "R", "C" , "� pack"            , "BOX"        , REPL("a",10) , REPL("x",10), nil , nil , nil }
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
   // ��� ������ ����� ��� ������ � �������
   aKey[1]  := { "bKey01", {|| Nil  }                                             }
   aKey[2]  := { "bKey06", FieldWBlock( "KR1", SELECT() ) /*FieldBlock("KR1")*/   }   // ������ ���
   aKey[3]  := { "bKey12", {|| SAY_SEL_DIM(FIELD->KOPLATA, "Oplata", "Oplata")  } }   // ��� ������
   aKey[4]  := { "bKey15", {|| SAY_SEL_DIM(FIELD->KFIRMA , "FIRMA" , "FIRMA")   } }   // �����
   aKey[5]  := { "bKey16", {|| SAY_SEL_DIM(FIELD->KBANK  , "Bank"  , "Bank")    } }   // ���� ����������
   aKey[6]  := { "bKey17", {|| DimUsluga(FIELD->KDMFANT)                        } }   // ������ ������
   aKey[7]  := { "bKey18", {|| SAY_SEL_DIM(FIELD->KOPERAT0,"Operat", "Operat")  } }   // ��� �������
   aKey[8]  := { "bKey19", {|| DTOC(FIELD->DATEVVOD2)+' '+FIELD->TIMEVVOD2      } }   // ����/����� ��������
   aKey[9]  := { "bKey20", {|| SAY_SEL_DIM(FIELD->KOPERAT,"Operat", "Operat")   } }   // ��� ������
   aKey[10] := { "bKey21", {|| myFldTime()                                      } }   // ����/����� ������
   cErr     := ""

   // ��� ������� ����� ���������� ��������� 30 �������� �� ������ � ������� ?
   // oCol:bDecode := {|ca| ca := trim(ca), iif( Len(ca) > 30, "..."+right(ca, 30), ca ) }
   aDcd := ARRAY(LEN(aDim))
   AFILL(aDcd, "" )
   aDcd[9] := {|ca| ca := trim(ca), iif( Len(ca) > 27, ".."+right(ca, 27), ca ) }

   // ����� ������� � ������� �������
   //aSumm := {"PRIXOD","TARIF","NACHIS","DOBAVKA"} - ������ �������: �����
   aField := {} ; aName := {} ; aFldSum := {}
   AEval(aDim, {|a|
                    AAdd(aField, a[5])
                    AAdd(aName , a[5])
                    IF !Empty(a[1])
                       IF     a[1] == 1         // ������� ����� �����
                          AAdd(aFldSum, a[5])
                       ELSEIF a[1] == 2         // ������ ����� ����� - ������
                       // AAdd(aItgOther, a[5]) // �.�. ��. ��������
                       ENDIF
                    ENDIF
                    Return Nil
                    })
   This.Cargo:aFldSum := aFldSum  // �������� �� ����

   // ������ ��� ������������ ���� - ��� "S"
   aIcon := ARRAY(LEN(aDim))
   AFILL(aIcon, "" )
   aIcon[14] := { 24, "iRuble24"  }    // ��� ������
   aIcon[15] := { 24, "iFirma24"  }    // �����
   aIcon[16] := { 24, "iBank24"   }    // ���� ����������
   aIcon[18] := { 32, "iUser32"   }    // ��� �������
   aIcon[20] := { 32, "iUser32"   }    // ��� ������
   aIconDel  := { 32, "iDelVal32" }    // ������� ��������

   // �������� � �������
   nHImage     := 32               // ������ �������� � �������
   oTsb:nHBmp  := nHImage          // �������� ��� �������

   // ������� � ����������
   aImgColumn  := myLoadBmpTsb(1,nHImage)
   oTsb:aBmp1  := { aImgColumn[1], aImgColumn[2], aImgColumn[3], aImgColumn[4] }

   // ������� � ����������
   aImgColumn  := myLoadBmpTsb(6,nHImage)
   oTsb:aBmp6  := { aImgColumn[1], aImgColumn[2], aImgColumn[3], aImgColumn[4] }

   oTsb:cAls      := cAls
   //                    cell     Head   foot    SpecHider  SuperHider   Edit
   oTsb:aFont     := { "Normal", "Bold", "Bold", "SpecHdr" , "ItalBold", "TsbEdit" }
   oTsb:lSpecHd   := .T.
   oTsb:aHead     := {}
   oTsb:aField    := {}
   oTsb:aPict     := {}
   oTsb:aSize     := {}  // !!! :aSize - ������ ������, ���������� � _TBrowse(...)
   oTsb:aName     := {}
   oTsb:aFoot     := {}  // .T.
   oTsb:aEdit     := {}  // .T.    // ������������� ��� �������
   oTsb:aColPrc   := {}
   oTsb:aFunc1    := {}
   oTsb:aFunc2    := {}
   oTsb:aBlock    := {}
   oTsb:aDecode   := {}   // ��� ������� oCol:bDecode
   oTsb:aCntMnu   := {}   // ������ ��� ������������ ���� - ��� "S"
   oTsb:aTable    := aDim
   oTsb:aClrBrush := { 176, 222, 251 }  // ���� ���� ��� ��������
   oTsb:aNumber   := { 1, 50 }
   oTsb:aSupHd    := { "1" + CRLF + "2" + CRLF + "3" }
   oTsb:aIconDel  := aIconDel    // ������� ��������

   IF ( i := GetControlIndex( oTsb:aFont[1], "Main" ) ) > 0
      n := _HMG_aControlFontSize[ i ]
   ELSE
      n := _HMG_DefaultFontSize
   ENDIF

   oDlu := oDlu4Font( n )

   FOR EACH a IN aDim
       i := hb_EnumIndex(a)
       AAdd(oTsb:aHead , StrTran(a[4], ";", CRLF)  )
       AAdd(oTsb:aSize , oDlu:TextWidth(a[6])      )  // !!! :aSize - ������ ������, ���������� � _TBrowse(...)
       AAdd(oTsb:aName , a[5]   ) // "NAME_"+HB_NtoS(i) )
       AAdd(oTsb:aFoot , a[5]   ) // "NAME_"+HB_NtoS(i) )
       cFld  := a[5]
       cType := a[3]
       c8Col := a[8]   // �������� �� ���� - ���������
       IF !IsString(c8Col)
          c8Col := ''
       ENDIF
       // ����� ����� ��� ����� ���� � ������� aKey[?]
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
             cErr += "��� �����: " + c8Col + ";"
          ENDIF
       ENDIF
       // ������� ���� ����
       AAdd(oTsb:aBlock, bBlock )
       // ������� ���� ����
       AAdd(oTsb:aField, upper(cFld) )

       lEdit := IIF( a[2] == "W", .T., .F. )  // ������ � �������: "R" ������, "W" ������
       AAdd(oTsb:aEdit, lEdit  )

       // ��� ���������� ���������
       AAdd(oTsb:aColPrc , cType    )  // ��� ��������� �������: "BMP", "K", "S", "C", "N", "D"
       AAdd(oTsb:aFunc1  , a[9]     )  // �������-1 :bPrevEdit ��� ��������� ������� �������
       AAdd(oTsb:aFunc2  , a[10]    )  // �������-2 :bPostEdit ��� ��������� ������� �������
       AAdd(oTsb:aDecode , aDcd[i]  )  // ��� ������� oCol:bDecode
       AAdd(oTsb:aCntMnu , aIcon[i] )  // ������ ��� ������������ ���� - ��� "S"
   NEXT
   //
   IF LEN(cErr) > 0
      IF App.Cargo:cLang == "RU"
      cMsg := "������ !;"
      cMsg += "����� ����� ��� ����� ���� � ������� aKey[?];;"
      ELSE
      cMsg := "ERROR!;"
      cMsg += "Searching for a key for a code block in the array aKey[?];;"
      ENDIF
      cMsg += ProcNL()
      AlertStop(cMsg + cErr, ProcNL() )
   ENDIF

   oTsb:aDim := aDim    // ������ ������� ������� - ��������
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
      //������ - ������ ������� ����/�������
      aBmp    := aBmp1
      nK      := LEN(aBmp)
      aHandle := ARRAY(nK)
      FOR nI := 1 TO nK
         aHandle[nI] := LoadImage(aBmp[nI],,nHImg,nHImg)
      NEXT
      bBmpCell := {|nc,ob| // ����� �������� � ����������� �� ����� ���� PRIXOD
                          Local ocol := ob:aColumns[nc]
                          Local ni   := 0
                          Local nSum := ob:GetValue("PRIXOD")  // ������� �����
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
                          Return ocol:aBitMaps[ni]  // �������� � ������� �������
                          }
      aRet := { aBmp, aHandle, bBmpCell, {} }
   ELSEIF nCol == 6
      // ������ - ������ ����� ����/������� KR1
      aBmp    := aBmp6
      nK      := LEN(aBmp)
      aHandle := ARRAY(nK)
      FOR nI := 1 TO nK
         aHandle[nI] := LoadImage(aBmp[nI],,nHImg,nHImg)
      NEXT
      bBmpCell := {|nc,ob| // ����� �������� � ����������� �� ���� KR1
                          Local ocol  := ob:aColumns[nc]
                          Local ni    := 0                      // bFZero32
                          Local nMax  := LEN(ocol:aBitMaps)     // bFZero32
                          Local nCode := ob:GetValue("KR1")  // ������� ���� ���� ������
                          //? ProcName(), nCode, ocol:cName, ocol:cField
                          nCode := FIELDGET(FIELDNUM(ocol:cField))  // ����� � ���
                          IF !IsNumeric(nCode)
                             nCode := 0
                          ENDIF
                          IF nCode <= 0 .OR. nCode >= nMax
                             ni := nMax
                          ELSE
                             ni := nCode
                          ENDIF
                          Return ocol:aBitMaps[ni]  // �������� � ������� �������
                          }
      aRet := { aBmp, aHandle, bBmpCell, aMsg6 }
   ELSE
      AlertStop("��� ����� ������� !; nCol="+ HB_NtoS(nCol)+";"+ ProcNL())
      aRet := {}
   ENDIF

RETURN aRet

//////////////////////////////////////////////////////////////////////////
FUNCTION Column_Init( ob, op )
   Local oCol, aDim, nI, nJ, nO, nS, bBlock, aBlock, nLen, cStr, nMax
   Local aColPrc, aFunc1, aFunc2, aDecode, bDecode

   // ��� ���������� ���������
   aDim    := op:aDim     // ���� ������ �������
   aBlock  := op:aBlock   // ���� ����
   aColPrc := op:aColPrc  // ��� ��������� �������: "BMP", "K", "S", "C", "N", "D"
   aFunc1  := op:aFunc1   // �������-1 :bPrevEdit ��� ��������� ������� �������
   aFunc2  := op:aFunc2   // �������-2 :bPostEdit ��� ��������� ������� �������
   aDecode := op:aDecode  // ��� ������� oCol:bDecode
   nMax    := 0

   nO := IIF( ob:nColumn("ORDKEYNO", .T.) > 0, 1, 0) // �������� ����, ���� ���, �� ����� 0
   nS := IIF( ob:lSelector, 1, 0 )   // ���� ����/��� ��������
   nJ := nO + nS
   ? ProcNL(), "ORDKEYNO:", nO, "lSelector:", nS

   FOR EACH oCol IN ob:aColumns
      cStr := ATREPL( CRLF, oCol:cHeading, "|" )
      nMax := MAX( nMax, LEN(cStr) )
   NEXT

   // ������ ���� �� ���� ���� � ������ ����� �� ��������
   FOR EACH oCol IN ob:aColumns
       nI := hb_EnumIndex(oCol)
       ? nI, oCol:cName, PADR( ATREPL( CRLF, oCol:cHeading, "|" ), nMax ) + ","
       ?? oCol:cField
       oCol:Cargo := oHmgData()
       oCol:Cargo:cName  := oCol:cName
       oCol:Cargo:lTotal := .F.
       oCol:Cargo:nTotal :=  0                 // ���� �� �������
       IF nI <= ob:nColumn("ORDKEYNO") ; LOOP
       ENDIF
       nJ := nI - nO // ��������� ������� ORDKEYNO
       IF aDim[nJ,1] == 1
          oCol:Cargo:lTotal := .T.
       ENDIF
       IF oCol:Cargo:lTotal
          // ��� �-� ������ �� Cargo ������� �������� ����� � oCol:cFooting,
          // �������� ��������� ���� ���� ���� ������� oBrw:DrawFooters()
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
            nLen          := LEN(aDim[nJ,6])  // ������ ���� - 6 ��������
            oCol:nWidth   := oCol:ToWidth( REPL("a",nLen) )
            oCol:cPicture := aDim[nJ,7]       // ������ ����
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
