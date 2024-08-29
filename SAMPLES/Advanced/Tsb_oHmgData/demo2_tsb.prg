/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ������ � �������� / Working with a table
*/
#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"

///////////////////////////////////////////////////////////////////////////////////////
FUNCTION RecnoInsert_TSB(ow,ky,cn,ob)  // VK_INSERT
RETURN RecnoInsert(ow,ky,cn,ob)        // �������� ����

FUNCTION RecnoDelete_TSB(ow,ky,cn,ob)  // VK_DELETE
RETURN RecnoDelete(ow,ky,cn,ob)        // �������� ����

/////////////////////////////////////////////////////////////////////
FUNCTION Draw_TSB( oTsb, oWnd, cBrw )
   LOCAL cDat, cEnd, lBottom, cAnsOem, nLen, cMaska, cMaska2
   LOCAL oBrw, cForm := oTsb:cForm    // ���������� ����
   LOCAL cTtl, xSelector := .T.       // ������ ������� - ��������

   // ������ ������� �� �������� ��������
   DEFINE TBROWSE &cBrw OBJ oBrw OF &cForm           ;
      AT oTsb:nY, oTsb:nX ALIAS oTsb:cAls WIDTH oTsb:nW HEIGHT oTsb:nH CELL   ;
      FONT     oTsb:aFont                            ; // ��� ����� ��� �������
      BRUSH    oTsb:aClrBrush                        ; // ���� ���� ��� ��������
      HEADERS  oTsb:aHead                            ; // ������ ����� ������� �������
      COLSIZES oTsb:aSize                            ; // ������ ������� �������
      PICTURE  oTsb:aPict                            ; // ������ ������� ������� �������
      JUSTIFY  oTsb:aAlign                           ; // ������ ������� ������� �������
      COLUMNS  oTsb:aField                           ; // ������ ������������ ������� �������
      COLNAMES oTsb:aName                            ; // ������ ����� ���� ������� �������
      FOOTERS  oTsb:aFoot                            ; // ������ ������� ������� �������
      EDITCOLS oTsb:aEdit                            ; // ������ ������ ��� �������������� ������� .T.\.F.\Nil>\.T\.F.\NIL
      COLNUMBER oTsb:aNumber                         ; // ����� ������� ����������� ������� � ����������
      FIXED                                          ; // ���������� ������� �������� ������� �� ������������ ��������
      COLSEMPTY                                      ; // ������ �������� ������� � .T. (������ �������� ��� "") ��� ����� D,N,T,L
      LOADFIELDS                                     ; // �������������� �������� �������� �� ����� �������� ���� ������
      ENUMERATOR                                     ; // ��������� �������
      SELECTOR xSelector                             ; // ������ ������� - �������� �������
      EDIT GOTFOCUSSELECT                            ;
      LOCK                                           ; // �������������� ���������� ������ ��� ����� � ���� ������
      ON INIT  {|ob| ob:Cargo := oHmgData(), ;
                 ob:lNoChangeOrd  := .T., ;     // ��������� ����������
                 ob:nColOrder     :=  0 , ;     // ������ ������ ���������� �� �������
                 ob:lNoGrayBar    := .F., ;     // T-�� ���������� ���������� ������ � �������
                 ob:lNoLiteBar    := .F., ;     // ��� ������������ ������ �� ������ ���� �� ������� "������" Bar
                 ob:lNoResetPos   := .F., ;     // ������������� ����� ������� ������ �� gotfocus
                 ob:lPickerMode   := .F., ;     // ������ ���� ���������� ����� �����
                 ob:nStatusItem   :=  0 , ;     // � 1-� Item StatusBar �� �������� ��������� �� ���
                 ob:lNoKeyChar    := .T., ;     // .T. - ����. ����� KeyChar(...) - ���� �� ����, ����
                 ob:nWheelLines   :=  1 , ;     // ��������� ������� ����
                 ob:nCellMarginLR :=  1 , ;     // ������ �� ����� ������ ��� �������� �����, ������ �� ���-�� ��������
                 ob:lMoveCols     := .F., ;
                 ob:nMemoHV       :=  1 , ;     // ����� ����� ������ ����-����
                 ob:nLineStyle := LINES_ALL ,;
                 ob:nClrLine   := COLOR_GRID,;
                 ob:lCheckBoxAllReturn := .T. }
      // --------- �����, �.�. ������ ������� ���� �� ����� �������
      //  ob:lNoMoveCols   := .T., ;     // .T. - ������ ������ �������� ������ ��� ���������� �������
      // �� ��������� �����
      //COLORS  aBrwColors              ;   // ��� ����� �������
      //BACKCOLOR aBackColor            ;   // ��� ������� - ��������� � ����� ����
      //SIZES aFSize                    ;   // ������ ������� �������
      //EMPTYVALUE                      ;
      //  ob:uLastTag      := NIL, ;     // �����
      //  ob:bTagOrder     := NIL, ;     // �����

      :Cargo:nModify := 0                           // ��������� � �������
      :Cargo:nHBmp   := oTsb:nHBmp                  // ������ ��������
      :Cargo:nHImg   := oTsb:nHBmp + 2*2            // ������ �������� + ������ ����� � ���
      :Cargo:aFont   := oTsb:aFont                  // �������� �����
      :Cargo:aSupHd  := oTsb:aSupHd                 // ���������� �������
      // ��� ���. ������ �� ��������
      :Cargo:aColPrc := oTsb:aColPrc                // ��� ��������� �������
      :Cargo:aFunc1  := oTsb:aFunc1                 // �������-1 :bPrevEdit ��� ��������� ������� �������
      :Cargo:aFunc2  := oTsb:aFunc2                 // �������-2 :bPostEdit ��� ��������� ������� �������
      :Cargo:aTable  := oTsb:aTable                 // �������� ���� ������ ������� � cargo ����, �� ������ ������
      :Cargo:aBlock  := oTsb:aBlock                 // ������� ���� �� ��������� ���� � �������
      :Cargo:aDecode := oTsb:aDecode                // ��� ������� oCol:bDecode
      :Cargo:aCntMnu := oTsb:aCntMnu                // ������ ��� ������������ ���� - ��� "S"
      :Cargo:aBmp1   := oTsb:aBmp1                  // ������� 1 � ����������
      :Cargo:aBmp6   := oTsb:aBmp6                  // ������� 8 � ����������
      :Cargo:aIconDel:= oTsb:aIconDel               // ������� ��������
      :Cargo:lRecINS := .F.                         // ���������� ������� INS
      :Cargo:lRecDEL := .F.                         // ���������� ������� DEL
      :Cargo:cMaska  := App.Cargo:oIni:MAIN:cMaska  // �������� ����� ����� �� ���-�����

      Column_Init(oBrw,oTsb)          // ���������� ������� -> Column_TSB.prg

      myTsbInit( oBrw )               // ���������
      myTsbColor( oBrw )              // �����
      myTsbFont( oBrw )               // ����� � �������
      //myTsbDelColumn( oBrw )        // ������ ������� �� �����������
      myTsbSuperHd( oBrw )            // SuperHeader
      // ��������� ������� ������� ����� END TBROWSE
      myTsb_Before( oBrw )          // ��������� ������

      ? "===>" + ProcNL(), oBrw:nColumn("ORDKEYNO", .T.) // ������ ����

      // �������� ������������ ��������
      /*IF :nLen > :nRowCount()
         :ResetVScroll( .T. )
         :oHScroll:SetRange( 0, 0 )
      ENDIF */

   END TBROWSE ON END {|ob| ob:SetNoHoles(), ob:SetFocus() }

   ? "===>" + ProcNL(), oBrw:nColumn("ORDKEYNO", .T.) // ������ ����

   // ��������� ������� ������� ����� END TBROWSE ��-�� SELECTOR
   myTsbEdit( oBrw, oWnd )         // ��������� ��������������
   myTsbClick( oBrw )              // �����/������/������� - ������� ���������

   oBrw:GetColumn("SELECTOR"):nClrFootBack := oBrw:Cargo:nBtnFace    // �� ��������
   oBrw:aColumns[1]:nClrFootBack := CLR_RED                          // �� ��������

   oBrw:lNoKeyChar := .F.     // ���� � ������ �� ����, ����

   //  ��������� ����� ������� ����� �������������
   //  ������� ����� END TBROWSE ��-�� SELECTOR
   oBrw:Cargo:aEditOriginal := ARRAY(LEN(oBrw:aColumns))
   AEval(oBrw:aColumns, {|oc,ni| oBrw:Cargo:aEditOriginal[ni] := oc:lEdit })

   //  ����� ����� - � ���.������
   IF IsString( oBrw:Cargo:cMaska )
      cMaska := oBrw:Cargo:cMaska
   ELSE
      cMaska := App.Cargo:oIni:MAIN:cMaska 
   ENDIF
   cMaska  := ALLTRIM(cMaska)                             // � ���.������
   IF LEN(cMaska) == 0
      cMaska := App.Cargo:oIni:MAIN:cMaska 
   ENDIF
   // --------- ���������� ����� SCOPE ---------
   nLen    := LEN( (oBrw:cAlias)->DOCUM )                 // ���-�� �������� ���� DOCUM
   cMaska2 := UPPER(PADR(cMaska,nLen))                    // � ���.������
   cAnsOem := HB_ANSITOOEM(cMaska2)                       // � ���.������
   cDat    := cEnd := cAnsOem                             // ������� ������
   lBottom := .F. // Scope first
   lBottom := .T. // Scope last
   oBrw:Cargo:cScopeDat       := cAnsOem                  // ��������� SCOPE
   oBrw:Cargo:cMaska          := cMaska2                  // ��������� maska
   App.Cargo:oIni:MAIN:cMaska := cMaska                   // �������� ����� ����� ��� ���-�����
   oBrw:ScopeRec(cDat, cEnd, lBottom)
   ? ProcNL(), "----- SCOPE ----", "["+cDat+"]", LEN(cEnd), lBottom
   // ���������� � ������� �� ����� �������
   OrdSetFocus("DOCDTV")      // ������ "����� ����� �� ����"
   DbGotop()
   // ��� ����� ������ �������
   oBrw:uLastTag := (oBrw:cAlias)->( ordName( INDEXORD() ) )
   //oBrw:Reset()
   oBrw:GoTop()
   DO EVENTS
   ? SPACE(5) + "INDEXORD()=",INDEXORD(), ORDSETFOCUS(),
   ? SPACE(5) + "oBrw:Cargo:cMaska=","["+oBrw:Cargo:cMaska+"]", LEN(oBrw:Cargo:cMaska)
   ? SPACE(5) + "App.Cargo:oIni:MAIN:cMaska=","["+cMaska+"]", LEN(cMaska)
   // --------- ������������ ���������� ---------
   cTtl := TitleSuperHider(cMaska)
   oBrw:Cargo:TitleSupHd   := cTtl              // ��������� �����
   oBrw:aSuperhead[ 1, 3 ] := oBrw:Cargo:TitleSupHd
   oBrw:DrawHeaders()          // ���������� ����������/�����/���������

RETURN oBrw

//////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbInit( oBrw )       // ���������
   LOCAL nI, o := oBrw:Cargo  // ���� �� ���������� ���� ����������

   WITH OBJECT oBrw
     :nHeightCell   := o:nHImg      // ������ ����� = ������ ��������
     //:nHeightCell += 6
     :nHeightSpecHd := 12           // ������ ���������� ENUMERATOR
     :lFooting      := .T.          // ������������ ������
     :lDrawFooters  := .T.          // ��������  �������
     :nFreeze       := 2            // ���������� �������
     :lLockFreeze   := .T.          // �������� ���������� ������� �� ������������ ��������
     :nCell         := :nFreeze + 1
     // --------- ��������� ��������, ��������� ����� �������� ������� ��������� ------
     :aBitMaps      := { Nil, LoadImage("bRecDel16") }

     :aColumns[1]:nWidth   := :Cargo:nHImg  // ������ ������� ��� � ��������
     :aColumns[2]:nWidth   := :Cargo:nHImg  // ������ ������� ��� � ��������

     // ��������� �������� ��� �������� ������� � ������� ORDKEYNO
     :aColumns[1]:aBitMaps := :Cargo:aBmp1[2]
     :aColumns[1]:uBmpCell := {|nc,ob| nc:=nil, iif( (ob:cAlias)->(Deleted()), ob:aBitMaps[2], ob:aBitMaps[1] ) }

     // ������� � ����������
     //:aColumns[5]:lCheckBox := .F. - ������
     /*:aColumns[2]:aBitMaps := { LoadImage("bMinus32",,nHChk,nHChk), LoadImage("bZero32",,nHChk,nHChk),;
                                LoadImage("bPlus32",,nHChk,nHChk) }
     :aColumns[2]:uBmpCell := {|nc,ob|
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
                                Return ocol:aBitMaps[ni]                   // �������� � ������� �������
                              }
     */
     :aColumns[2]:aBitMaps := :Cargo:aBmp1[2]
     :aColumns[2]:uBmpCell := :Cargo:aBmp1[3]
     //
     :aColumns[2]:nAlign   := nMakeLong( DT_CENTER, DT_CENTER )
     :aColumns[2]:nHAlign  := DT_CENTER

     nI := oBrw:nColumn("KR1", .T.)
     :aColumns[nI]:lBitMap  := .T.           // ������ ����� �������� ���� �� �������
     :aColumns[nI]:nWidth   := :Cargo:nHImg  // ������ ������� ��� � ��������
     /*
     :aColumns[nI]:aBitMaps := { LoadImage("bFCalc32",,nHChk,nHChk) , LoadImage("bFCSV32",,nHChk,nHChk)  ,;
                                LoadImage("bFExcel32",,nHChk,nHChk), LoadImage("bFText32",,nHChk,nHChk) ,;
                                LoadImage("bFWord32",,nHChk,nHChk) , LoadImage("bFZero32",,nHChk,nHChk) }
     :aColumns[nI]:uBmpCell := {|nc,ob|
                                Local ocol  := ob:aColumns[nc]
                                Local ni    := 0                      // bFZero32
                                Local nMax  := LEN(ocol:aBitMaps)     // bFZero32
                                Local nCode := ob:GetValue("PRIXOD")  // ������� ���� ���� ������
                                //? ProcName(), nCode, ocol:cName, ocol:cField
                                //nCode := FIELDGET(FIELDNUM(ocol:cField))  // ����� � ���
                                IF !IsNumeric(nCode)
                                   nCode := 0
                                ENDIF
                                IF nCode <= 0 .OR. nCode >= nMax
                                   ni := nMax
                                ELSE
                                   ni := nCode
                                ENDIF
                                Return ocol:aBitMaps[ni]              // �������� � ������� �������
                              } */
     :aColumns[nI]:aBitMaps := :Cargo:aBmp6[2]
     :aColumns[nI]:uBmpCell := :Cargo:aBmp6[3]
     :aColumns[nI]:nAlign   := nMakeLong( DT_CENTER, DT_CENTER )
     :aColumns[nI]:nHAlign  := DT_CENTER
     //:aColumns[nI]:bData    :=  {||Nil}
     //:aColumns[nI]:cData    := '{||Nil}'

   END WITH

RETURN Nil

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbColor( oBrw )
   LOCAL nCol, oCol, O, aBClr, nBClr, nGrad

   aBClr := { 49, 177, 255 }               // ���� ���� �������
   nBClr := RGB(49, 177, 255)              // ���� ���� ��� ��������
   nGrad := RGB(48,29,26)                  // ��������

   WITH OBJECT oBrw:Cargo
      // ������ �������� ����������
      :nBtnText   :=  GetSysColor( COLOR_BTNTEXT )      // nClrSpecHeadFore
      :nBtnFace   :=  GetSysColor( COLOR_BTNFACE )      // nClrSpecHeadBack
      :nBClrSpH   :=  GetSysColor( COLOR_BTNFACE )      // nClrSpecHeadBack
      // ��� ����� � �������
      :nClrSilver := RGB(207,205,205)                   // ������-�����
      //:nClrBC   := RGB(183,221,232)                   // ���� ���� �������
      :nClrBC     := nBClr                              // ���� ���� �������
      :nClrPrc    := RGB(240,240,240)                   // ������ % 2
      //:nClrPrc  := RGB(aBClr[1],aBClr[2],aBClr[3])    // ������ % 2
      :nClrErr    := RGB(192,0,255)                     // ���������� - ���� �������
      :nClrTxt    := CLR_BLACK                          // ���� ������ � ������ �������
      :nClrTxt2   := CLR_WHITE                          // ���� ������ � ������ ��� ������
      :nClrMinus  := CLR_HRED                           // ���� ������ � ������ ��� ������
      :nHead2     := nBClr                              // ������ � ����� �������
      :nHead1     := RGB(48,29,26) //RGB(18,236,48)     // ������ � ����� �������
      //:nClr16   := {RGB(0,176,240),RGB(60,60,60)}     // 16, ���� ���������
      //:nClr16   := {RGB(40,110,212),RGB(0,176,240)}   // 16, ���� ���������
      :nClr16     := {:nHead1,:nHead2}                  // 16, ���� ���������
      :nClr17     := CLR_YELLOW                         // 17, ������ ���������
      :nClr16All  := {:nHead1,:nClrErr}                 // 16, ���� ��������� ��� ������
      :nClr16Del  := {:nHead1,CLR_BLUE}                 // 16, ���� ��������� �������� ������
      :nClr16New  := {:nHead1,CLR_ORANGE}               // 16, ���� ��������� ������ �� �������
      //:nClrLine   := aStaticLineColorTsb              // ������ � "------"
      :aClrBrush  := { 176, 222, 251 }                 // ���� ���� ��� ��������
  END WITH

   WITH OBJECT oBrw
      O := :Cargo
      :nClrLine              := RGB(180,180,180)                 // COLOR_GRID
      :SetColor( {  1 }, { { || CLR_BLACK               } } )    // 1 , ������ � ������� �������
      :SetColor( {  2 }, { { || O:nClrBC                } } )    // 2 , ���� � ������� �������
      :SetColor( {  3 }, { { || CLR_YELLOW              } } )    // 3 , ������ ����� �������
      :SetColor( {  4 }, { { || { O:nHead2, O:nHead1 }  } } )    // 4 , ���� ����� �������
      :SetColor( {  5 }, { { || RGB(0,0,0)              } } )    // 5 , ������ �������, ����� � ������� � �������
      :SetColor( {  6 }, { { |a,b,c| a:=nil, iif( c:nCell == b, -RGB(1,1,1), -CLR_HRED ) } } )  // 6 , ���� �������
      :SetColor( {  9 }, { { || CLR_YELLOW              } } )    // 9 , ������ ������� �������
      :SetColor( { 10 }, { { || { O:nHead1, O:nHead2 }  } } )    // 10, ���� ������� �������
      :SetColor( { 11 }, { { || RGB(0,0,0)              } } )    // 11, ������ ����������� ������� (selected cell no focused)
      :SetColor( { 12 }, { { |a,b,c| a:=nil, iif( c:nCell == b, -CLR_HRED, -RGB(9,57,16) ) } } ) // 12, ���� ����������� ������� (selected cell no focused)
      :hBrush  := CreateSolidBrush(o:aClrBrush[1], o:aClrBrush[2], o:aClrBrush[3])  // ���� ���� ��� ��������
      // ������ ����� �����������
      //:SetColor( {16}, { O:nClr16  } ) // 16, ���� ���������
      :SetColor( { 16 }, { { || { O:nHead2, O:nHead1 }  } } )
      :SetColor( { 17 }, { O:nClr17  } ) // 17, ������ ���������
   END WITH

   // ������� ���� ������� - ���� ����������� ������� / own virtual column
   oBrw:GetColumn("ORDKEYNO"):nClrBack     := oBrw:Cargo:nBtnFace
   oBrw:GetColumn("ORDKEYNO"):nClrFootBack := CLR_WHITE
   oBrw:GetColumn("ORDKEYNO"):nClrFootFore := CLR_BLACK
   oBrw:GetColumn("KR2"     ):nClrBack     := CLR_WHITE   // ������� � ����������
   oBrw:GetColumn("KR1"     ):nClrBack     := CLR_WHITE   // ������� � ����������
   oBrw:GetColumn("PUSTO"   ):nClrBack     := CLR_YELLOW  // ������� �� scope
   oBrw:GetColumn("DOCUM"   ):nClrBack     := CLR_HGRAY   // ������� � ��������� ������

   FOR EACH oCol IN oBrw:aColumns
      IF oCol:Cargo:lTotal
         oBrw:GetColumn(oCol:cName):nClrFootBack := CLR_WHITE
         oBrw:GetColumn(oCol:cName):nClrFootFore := CLR_BLACK
      ENDIF
      oCol:nClrEditFore := CLR_HBLUE                 // ���� ����� ������ ��� ��������������
      oCol:nClrEditBack := HMG_RGB2n(239,247,152)    // ���� ���� ������ ��� ��������������
   NEXT

   FOR nCol := 1 TO Len(oBrw:aColumns)
       oCol := oBrw:GetColumn(nCol)
       IF oCol:cName $ "ORDKEYNO,KR2,KR1,DOCUM,PUSTO"
          LOOP
       ENDIF
       // �������� ���� ����� � �������
       oCol:nClrBack := {|nv,nc,ob|
                          Local oc, nClr
                          Local o := ob:Cargo             // ������������� ���������
                          Local nClrPrc := o:nClrPrc        // ������ % 2
                          Local nClrBC  := o:nClrBC         // ���� ���� �������
                          Local nClr_1  := o:nBtnFace
                          Local lDel    := (ob:cAlias)->(DELETED())
                          oc  := ob:GetColumn(nc)
                          nClr := nv
                          // ���.��������
                          If nc == 1
                             nClr := nClr_1
                          ElseIf nc == 3
                             nClr := CLR_WHITE
                          Else
                             nClr := iif( ob:nAt % 2 == 0, nClrPrc, nClrBC )
                          Endif
                          // ��� ������� ��������� ������
                          IF lDel                // ������� �� ������ ?
                             nClr := CLR_BLUE
                          ENDIF
                          Return nClr
                          }
       // ������ ���� �� ������� ���������
       oCol:nClrFore := {|nv,nc,ob|
                          Local o := oBrw:Cargo        // ������������� ���������
                          Local nClr0 := o:nClrTxt     // ���� ������ � ������ �������
                          Local nClr2 := o:nClrMinus   // ���� ������ ��� ������
                          Local lDel  := (ob:cAlias)->(DELETED())
                          Local oc, nClr, nSum
                          oc   := ob:GetColumn(nc)
                          nv   := ob:GetValue(nc)
                          nSum := ob:GetValue("PRIXOD")  // ������� �����
                          nClr := iif( nSum >= 0 , nClr0, nClr2 )
                          // ��� ������� ��������� ������
                          IF lDel                // ������� �� ������ ?
                             nClr := CLR_YELLOW
                          ENDIF
                          Return nClr
                          }
   NEXT

RETURN Nil

///////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbFont( oBrw )
   LOCAL hFont, nI, oCol

   hFont := oBrw:aColumns[1]:hFontSpcHd  // 4-special header font
   // ���������� ���� ��� 1 ������� �������
   oBrw:aColumns[1]:hFont := hFont     // 1-cells font

    // ����� ��� ������� 3-4 �������, ��������� �� ����
   For nI := 2 To 5  //oBrw:nColCount()
      oCol       := oBrw:aColumns[ nI ]
      oCol:hFont := {|nr,nc,ob| // ����� ��� ����� �������
                      Local nGet, xv
                      nGet := ob:GetValue("PRIXOD") // ������� �����
                      xv   := ob:GetValue(nc)
                      //? "**** ob:aColumns["+HB_NtoS(nc)+"]", nr, nc, xv, nGet
                      //!!! nr := ob:aColumns[ nc ]:hFont   // GetFontHandle( "Normal" )
                      nr := ob:hFont
                      IF nGet < 0   // ��������� �����
                         nr := oBrw:aColumns[nc]:hFontHead
                      ENDIF
                      //IF "---" $ cval
                      //    nr := ob:Cargo:hTsbBold4 // GetFontHandle( "Bold" )
                      //ENDIF
                      Return nr
                      }
   Next

RETURN Nil

//////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbSuperHd( oBrw )
   LOCAL hFont, nHFont, aSupHd
   LOCAL o := oBrw:Cargo      // ������������ �� ���������� ���� ����������

   hFont  := oBrw:hFontSupHdGet(1)
   nHFont := GetTextHeight( 0, "B", hFont )
   aSupHd := o:aSupHd

   WITH OBJECT oBrw
      // ������ ���������� � ������� �������� 0
      :AddSuperHead( 1, :nColCount(), "Super_Header_Table" ) //,,, .F.,,, .F., .F., .F., 0, )
      :aSuperhead[ 1, 3 ] := aSupHd[1]
      :nHeightSuper := nHFont * 3      // 3 ������
      // ������ ����� �����������
      :SetColor( {16}, { O:nClr16  } ) // 16, ���� ���������
      :SetColor( {17}, { O:nClr17  } ) // 17, ������ ���������
   END WIDTH

   o:TitleSupHd := oBrw:aSuperhead[ 1, 3 ]    // ���������
   o:ColorSupHd := O:nClr16                   // 16, ���� ���������

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////////
// ��������� ��������������
STATIC FUNCTION myTsbEdit( oBrw, oWnd )
   LOCAL i, oCol, aColPrc, aFunc1, aFunc2, aDim, nJ, nCol, cCol, nO, nS, nP
   LOCAL o := oBrw:Cargo      // ������������ �� ���������� ���� ����������

   aColPrc := o:aColPrc           // ��� ��������� �������
   aFunc1  := o:aFunc1            // �������-1 :bPrevEdit ��� ��������� ������� �������
   aFunc2  := o:aFunc2            // �������-2 :bPostEdit ��� ��������� ������� �������
   aDim    := o:aTable            // ���� ������ ������� � cargo ����

   nP := 0
   FOR nCol := 1 TO 3
      cCol := oBrw:aColumns[ nCol ]:cName
      IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
         nP ++
      ENDIF
   NEXT
   // ����� � ���
   nO := IIF( oBrw:nColumn("ORDKEYNO", .T.) > 0, 1, 0) // �������� ����, ���� ���, �� ����� 0
   nS := IIF( oBrw:lSelector, 1, 0 )   // ���� ����/��� ��������
   nJ := nO + nS

   ? "======= " + ProcName() , oWnd:Name, "SELECTOR .OR. ORDKEYNO = ", nJ, "nO=",nO, nS, "nP=", nP
   FOR EACH oCol IN oBrw:aColumns
       i := hb_EnumIndex(oCol)
       IF oCol:cFieldTyp == "D" ; oCol:cPicture := NIL  // ����������� !!! ����� �� ����� ����� � ����
       ENDIF
       //? i, oCol:cName, oBrw:nCell
       //?? oCol:cField, oCol:cFieldTyp
       //?? oCol:nFieldLen
       //?? oCol:nFieldDec
       //?? ":aEdit=",oCol:lEdit
       //?? oCol:cPicture
       IF oCol:cName == "KR2"          // BMP
          oCol:lEdit := .F.
          oCol:nEditMove := DT_DONT_MOVE  // ����. ����������� ������� ����� :Edit()
       ELSE
          //oCol:nEditMove := DT_MOVE_RIGHT  // ���. ����������� ������� ����� :Edit()
          oCol:bPrevEdit := {|xv,ob|
                              Local nc, oc, xGet, nAt, cNm, ni, cPrcs, lRet, cRun, nk, cStr
                              Local o := ob:Cargo     // ����� �� ���������� ���� ����������
                              Local aColProcess := o:aColPrc      // ��� ��������� �������
                              Local aRunFunc1   := o:aFunc1       // �������-1 :bPrevEdit
                              Local aDimTsb     := o:aTable       // ���� ������ �������
                              Local aVal, cMsg
                              Local nOrder := INDEXORD()
                              nc  := ob:nCell
                              oc  := ob:GetColumn( nc )
                              cNm := oc:cName
                              xv  := oc:Cargo
                              nAt := ob:nAt
                              nk  := IIF( oBrw:lSelector, 1, 0 )            // �������� ���������
                              nk  += IIF(ob:nColumn("ORDKEYNO", .T.)>0,1,0) // �������� ����
                              ni  := nc - nk            // ���.����� ������ � aColPrc[]
                              ? ":bPrevEdit",ProcNL(), "nc=", nc, "cNm=",cNm,oc:cPicture,"xv=", xv, "nAt=",nAt
                              xGet := ob:GetValue(nc)
                              ? ":bPrevEdit , xGet=", xGet, "INDEXORD()", nOrder
                              //? "   ���.����� ������ � aColPrc=", ni
                              //? "   =", HB_ValToExp(aDim[ni])
                              ////////////// ��������� ������� �� ����� /////////////
                              cStr  := HB_ValToExp(aDimTsb[ni])
                              cPrcs := aColProcess[ni]   // ��� ��������� �������
                              aVal  := { cNm, cPrcs, ni, aDimTsb[ni] }  // �������� � �������
                              IF (ob:cAlias)->(RLock())      // �� ������ ������
                                 ob:Cargo:nModify ++  // ���� ����������� �������
                                 IF cPrcs $ "CNDLM"
                                    ob:SetValue(cNm , xGet )
                                    lRet := .T.
                                 ELSEIF cPrcs $ "STKB"
                                    SET WINDOW THIS TO ob:cParentWnd  // ����������� !!!
                                    ColumnEdit_STKB(ob,aVal)          // ��� ���������� ��������
                                    SET WINDOW THIS TO
                                    //_PushKey( VK_RIGHT )   // �������� ������ �������
                                    ob:GoRight()             // ����������� ������ ������
                                    lRet := .F.   // �� ������ ������������� ���� � :get
                                 ELSE
                                    // ������� ��� ��������� ������� ������� ��� ���� "J"
                                    cRun := aRunFunc1[ni]
                                    SET WINDOW THIS TO ob:cParentWnd        // ����������� !!!
                                    ColumnEdit_J(ob,ni,cRun,cNm,aVal,cStr)  // ��� ���������� ��������
                                    SET WINDOW THIS TO
                                    //_PushKey( VK_RIGHT )   // �������� ������ �������
                                    ob:GoRight()             // ����������� ������ ������
                                    lRet := .F.              // �� ������ ������������� ���� � :get
                                 ENDIF
                              ELSE
                                 cMsg := "Recording is locked !; Recno="
                                 cMsg += HB_NtoS(RECNO()) + ";;" + ProcNL()
                                 AlertStop( cMsg )
                              ENDIF
                              (ob:cAlias)->(dbUnLock())
                              ob:Skip(0)
                              ob:DrawSelect()             // ������������ ������� ������ �������
                              DO EVENTS
                              ? ":bPrevEdit .end , lRet=", lRet, "INDEXORD()", nOrder
                              Return lRet
                             }

        oCol:bPostEdit := {|uVal,ob|
                              Local nc, oc, ni, cPrcs, cNm, cRun, xGet, nk
                              Local o := ob:Cargo     // ����� �� ���������� ���� ����������
                              Local aColProcess := o:aColPrc      // ��� ��������� �������
                              Local aRunFunc2   := o:aFunc2       // �������-2 :bPostEdit
                              Local aDimTsb     := o:aTable       // ���� ������ �������
                              Local aVal, cStr, lSay, xv
                              nc  := ob:nCell
                              oc  := ob:GetColumn(nc)
                              xv  := oc:Cargo
                              cNm := oc:cName
                              nk  := IIF( oBrw:lSelector, 1, 0 )            // �������� ���������
                              nk  += IIF(ob:nColumn("ORDKEYNO", .T.)>0,1,0) // �������� ����
                              ni  := nc - nk            // ���.����� ������ � aColPrc[]
                              ? ":bPostEdit",ProcNL(), oc:cName, "nc=", nc, "cNm=",cNm, "ni=", ni
                              xGet := ob:GetValue(nc)   // ������ ����
                              ? ":bPostEdit  , xGet=", xGet
                              ////////////// ��������� ������� �� �����
                              cStr  := HB_ValToExp(aDimTsb[ni])
                              aVal  := { cNm, cPrcs, ni, aDimTsb[ni] }  // �������� � �������
                              cPrcs := aColProcess[ni]                  // ��� ��������� �������
                              cRun  := aRunFunc2[ni]

                              SET WINDOW THIS TO ob:cParentWnd               // ����������� !!!
                              ColumnEdit_bPost(ob,ni,cRun,cNm,aVal,cStr,oc)  // ��� ���������� ��������
                              SET WINDOW THIS TO

                              ? ":bPostEdit  ,oc:Cargo:lTotal=",oc:Cargo:lTotal, "oc:xOldEditValue=",oc:xOldEditValue
                              lSay := .F.
                              IF oc:Cargo:lTotal .and. oc:xOldEditValue != uVal
                                 oc:Cargo:nTotal += uVal - oc:xOldEditValue
                                 lSay := .T.
                              ENDIF
                              ?? "oc:Cargo:nTotal=",oc:Cargo:nTotal
                              // ������� ��������� �� ��������� ����� � ��������
                              IF lSay ; _wPost("_ItogSay", ob:cParentWnd)
                              ENDIF

                              IF cPrcs $ "CNDLM"
                              ELSE
                                 //_PushKey( VK_RIGHT )   // �������� ������ �������
                                 ob:GoRight()             // ����������� ������ ������
                              ENDIF
                              DO EVENTS
                              ? ":bPostEdit  .end", "INDEXORD()=", INDEXORD()
                              Return Nil
                             }
       ENDIF
   NEXT

RETURN NIL

///////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsb_Before( oBrw )
   LOCAL nLen, cBrw, nTsb

   WITH OBJECT oBrw
      // ��������� ������
      /*
      :UserKeys(VK_SPACE, {|ob|
                           Local lRet := .T., lval, cval
                           ob:Cargo:nModify ++  // ���� ����������� �������
                           IF ob:nCell == 2
                              lval := ob:GetValue( ob:nCell )
                              cval := ob:GetValue( ob:nCell + 1 )
                              IF ! "---" $ cval
                                 ob:SetValue( ob:nCell, ! lval )
                                 ob:DrawSelect()
                                 DO EVENTS
                                 lRet := .F.
                              ENDIF
                           ENDIF
                           Return lRet
                           })
      :UserKeys(VK_RETURN, {|ob|
                            Local lRet := .T.
                            ob:Cargo:nModify ++  // ���� ����������� �������
                            IF ob:nCell == 2
                               DO EVENTS
                               ob:PostMsg( WM_KEYDOWN, VK_SPACE, 0 )
                               lRet := .F.
                            ENDIF
                            Return lRet
                            })
      // ��������� �����
      :bLDblClick := {|p1,p2,p3,ob| p1:=p2:=p3, ob:PostMsg( WM_KEYDOWN, VK_RETURN, 0 ) }

      // ������� � ������������� ���������
      // �.�. ������� 2 ��� �� CheckBox, ��������� ����������, �� ��� ������ ���.��������
      //  �� ����� �� ������� oBrw:aMsg, ��� �������� �������� {"��", "���" ...}
      IF hb_IsArray( :aMsg ) .and. Len( :aMsg ) > 1
         :aMsg[1] := ""
         :aMsg[2] := ""
      ENDIF
      */
      :SetAppendMode( .F. )    // ��������� ������� ������ � ����� ���� �������� ����
      //oBrw:SetDeleteMode( .T., .F. )
      //oBrw:SetDeleteMode( .T., .T. ) // ����������� ������ �� ��������
      // ���� ��� ��������, ����� �������� � �� ��������������
      :SetDeleteMode( .T., .F., {|| // ���� ��� ��������
                                    Local lDel := (oBrw:cAlias)->(Deleted())
                                    Local cDel := "������� ������ � ������� ?;;Delete a record in a table?"
                                    Local cIns := "������������ ������ � ������� ?;;Restore a record in a table??"
                                    Local cMsg := "�������� / ATTENTION;;" + iif(lDel, cIns, cDel)
                                    Local cTtl := "�������������/Confirmation"
                                    Local lRet, aClrs := { {45,223,70} , ORANGE }
                                    Local aTmp, aBClr, aFClr
                                    aBClr := {248,209,211}      // ������-�������
                                    aFClr := MAROON
                                    aTmp  := _SetMsgAlertColors(aBClr,aFClr)  // ����� �����
                                    lRet  := AlertYesNo( cMsg, cTtl, ,"ZZZ_B_STOP64", 64, aClrs )
                                    _SetMsgAlertColors(aTmp[1],aTmp[2])          // ������������ �����
                                    Return lRet
                                } )
      // ��������� ������� ESC � ������
      :UserKeys(VK_ESCAPE, {|ob| _wSend(99, ob:cParentWnd), .F.                        })
      //oMenu:aBtnPost  := { "_Help", "_Find", "_RecIns", "_RecDel", "_Print", "_Exit" }
      :UserKeys(VK_INSERT, {|ob| DoEvents(), _wPost("_RecIns", ob:cParentWnd, "BTN__RecIns"), .F. })
      :UserKeys(VK_DELETE, {|ob| DoEvents(), _wPost("_RecDel", ob:cParentWnd, "BTN__RecDel"), .F. })
      :UserKeys(VK_F7    , {|ob| DoEvents(), _wPost("_Find"  , ob:cParentWnd, "BTN__Find"  ), .F. })
      :UserKeys(VK_F5    , {|ob| DoEvents(), _wPost("_Print" , ob:cParentWnd, "BTN__Print" ), .F. })

      // ���� �� ������ �������
      :UserKeys(VK_F2 ,  {|ob| myTsbListColumn( ob ), ob:Setfocus() })  // ���� �� ������ �������
      :UserKeys(VK_F3 ,  {|ob| myTsbListFont( ob )  , ob:Setfocus() })  // ���� �� ������ �������
      :UserKeys(VK_F4 ,  {|ob| AlertInfo( myGetIndexUse() )  , ob:Setfocus() })  // ���� �� �������� �������

      cBrw := :cControlName
      nTsb := This.&(cBrw).ClientWidth
      nLen := :GetAllColsWidth() - 1
      IF nLen > nTsb
         //:lAdjColumn  := .T.
         //:lNoHScroll  := .F.
         //:lMoreFields := ( :nColCount() > 45 )
      ELSE
         //:AdjColumns()
      ENDIF

   END WITH

RETURN Nil

//////////////////////////////////////////////////////////////////////////////
// ����� ������ � ���� ����������� � ����� ���� � ��������� ����� � ��������������
STATIC FUNCTION RecnoInsert(oWnd,nPost,cBtn,oBrw)
   LOCAL nTime := VAL(SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2))
   LOCAL nRecno, cMsg, aTmp, aBColor, aFColor, aColors

   ? ProcName()+"():", "oWnd:", oWnd:Name, nPost, cBtn, oBrw:ClassName

   IF oBrw:Cargo:lRecINS              // ���������� ������� INS
      RETURN NIL
   ENDIF

   IF LEN(ALLTRIM(oBrw:Cargo:cMaska)) == 0
      cMsg := "������ !;;"
      cMsg += "�� ��������� �����-����� ,;"
      cMsg += "�����: � ��������� ������ ;"
      cMsg += '���������� ��������� � !'
      cMsg += "ERROR!;;"
      cMsg += "INPUT-MASK not filled in ,;"
      cMsg += "column: payment document no. ;"
      cMsg += 'You need to fill it in!'
      AlertStop( cMsg, "��������" )
      RETURN NIL
   ENDIF

   cMsg    := "�������� !;;�������� ������ � ������� ? "
   cMsg    += "ATTENTION!;;Insert a record into the table ? "
   aColors := { {45,223,70} , ORANGE }
   aBColor := { 238, 249, 142 }   // ������-�����
   aFColor := BLACK
   aTmp    := _SetMsgAlertColors(aBColor,aFColor)  // ����� �����

   IF AlertYesNo( cMsg, "���������� ������ / Adding recno", , , 64, aColors )
      // ����������� ����� ��� ���������� ������
      // �������� � ���� ����+����� ������� ������
      oBrw:bAddAfter := {|ob,ladd|
                          Local cMaska := App.Cargo:oIni:MAIN:cMaska // ����� ����� �� ���-�����
                          Local cRecno := HB_NtoS( (ob:cAlias)->( RecNo() ) )
                          If ladd
                             ? "+++ :bAddAfter",ProcNL(), "INDEXORD()=", INDEXORD()
                             ?? "RecNo()= " + cRecno
                             (ob:cAlias)->KOPERAT   := M->nOperat   // ��� ������� ������
                             (ob:cAlias)->DATEVVOD  := DATE()       // ����/����� ������
                             (ob:cAlias)->TIMEVVOD  := nTime
                             (ob:cAlias)->KOPERAT0  := M->nOperat   // ��������� ������
                             (ob:cAlias)->DATEVVOD2 := DATE()       // ����/����� ��������
                             (ob:cAlias)->TIMEVVOD2 := TIME()
                             (ob:cAlias)->CVVOD2    := '22'             // ������ ���� ���������
                             //(ob:cAlias)->DOCUM   := ob:Cargo:cMaska  // No ��������� ������
                             (ob:cAlias)->DOCUM     := cMaska           // No ��������� ������
                             (ob:cAlias)->BOX       := "/"+cRecno       // ������ ��� �������
                             (ob:cAlias)->( dbSkip(0) )
                          EndIf
                          Return Nil
                        }

      // oBrw:bAddAfter  := Nil  // ��� ���� �� ����� ��� ���������� ����� ��� �������� ����� ������

      // ���������� ����� ��� ���������� ������
      oBrw:AppendRow(.T.)

      nRecno := (oBrw:cAlias)->( RecNo() )
      IF (oBrw:cAlias)->(RLock())
         // ���� ����� ������ � ���� ����+����� ��� ���� �������� (������� ����)
         //(oBrw:cAlias)->IM        := hb_DateTime()    // ����� �������� ������
         //(oBrw:cAlias)->KOPERAT   := M->nOperat       // ��� ������� ������ - ������
         //(oBrw:cAlias)->DATEVVOD  := DATE()
         //(oBrw:cAlias)->TIMEVVOD  := nTime
         (oBrw:cAlias)->(DbCommit())
         (oBrw:cAlias)->(DBUnlock())
         ? "+++ " + ProcNL(), "INDEXORD()=", INDEXORD(), "RecNo()=", nRecno
      ENDIF

      nRecno := (oBrw:cAlias)->( RecNo() )
      ? "+++ " + ProcNL(), hb_DateTime(), "Insert!", "RecNo()=", nRecno

      oBrw:nCell := oBrw:nColumn("PRIDAT", .T.)  // � ������ ������� ��� ��������������
      oBrw:Reset()
      //oBrw:Refresh(.T.,.T.)
      oBrw:GoBottom()     // ������ �� ����� ������ �������� ��� ������: 'DTOS(DATEVVOD2)+TIMEVVOD2'
      DO EVENTS

   ENDIF

   _SetMsgAlertColors(aTmp[1],aTmp[2])      // ������������ �����

RETURN Nil

//////////////////////////////////////////////////////////////////////////
STATIC FUNCTION RecnoDelete(oWnd,nPost,cBtn,oBrw)
   LOCAL lChange, nAt, lDelete, nRecno, nCell, nMetod, nRec
   LOCAL aSumm, oCol, nCol, nSum, cFld

   ? " -Del- "+ProcNL(), "oWnd:", oWnd:Name, nPost, cBtn, oBrw:ClassName
   ?? ":nLen=", oBrw:nLen //,":lIsXXX=", oBrw:lIsDbf, oBrw:lIsArr
   ?? ":nRowPos=", oBrw:nRowPos

   IF oBrw:nLen == 0        // ��� ������� � �������
      RETURN Nil
   ENDIF

   IF oBrw:Cargo:lRecDEL    // ���������� ������� DEL
      RETURN NIL
   ENDIF

   // �������� ����� ��� ������� �����
   aSumm := ARRAY( LEN(oBrw:aColumns) )
   AFILL( aSumm, 0 )
   FOR EACH oCol IN oBrw:aColumns
      nCol := hb_EnumIndex(oCol)
      //? nCol, oCol:cName
      IF oCol:cName == "SELECTOR"     ; LOOP
      ELSEIF oCol:cName == "ORDKEYNO" ; LOOP
      ENDIF
      IF oCol:Cargo:lTotal
         //?? oCol:Cargo:lTotal, oCol:Cargo:nTotal
         cFld := oCol:cName
         //aSumm[nCol] := (oBrw:cAlias)->&cFld
         aSumm[nCol] := oBrw:GetValue(oCol:cName)
      ENDIF
   NEXT

   // ����������� ����� ��� �������� ������
   oBrw:bDelAfter := {|nr,ob|
                             Local cAls := ob:cAlias
                             Local nOld := (cAls)->( RecNo() )
                             Local cVal := SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2)
                             Local nTime := VAL( cVal )
                             //If (cAls)->( deleted() )
                             ? " -Del-  :bDelAfter" + ProcNL(), "nRecno=", nOld
                             ?? "INDEXORD()=", INDEXORD()
                             If (cAls)->( RLock() )
                                // ���� ����� ������ � ���� ����+����� ��� ���� ��������
                                //If lDel ; (cAls)->DT_DEL  := hb_DateTime()
                                //Else    ; (cAls)->DT_REST := hb_DateTime()
                                //EndIf
                                (cAls)->KOPERAT  := M->nOperat  // ��� ������ ������
                                (cAls)->DATEVVOD := DATE()      // ����� ������� ������
                                (cAls)->TIMEVVOD := nTime
                                (cAls)->( DbUnLock() )
                                ?? "Write field: ", DATE(), nTime, M->nOperat
                                (cAls)->( dbSkip(0) )
                             EndIf
                             //EndIf
                             Return nr
                            }

   lDelete := (oBrw:cAlias)->( Deleted() )
   nRecno  := (oBrw:cAlias)->( RecNo() )
   nCell   := oBrw:nCell    // ������ �� ������� �������
   nAt     := oBrw:nAt      // ��� ������� - ������ ������� �� ������
   nAt     := oBrw:nRowPos  // ��� dbf     - ������ ������� �� ������
   ? " -Del-  lDelete=", lDelete, "nRecno=",nRecno

   nMetod := 0
   IF oBrw:lIsArr                 //  ��� �������
      ? " -Del- :nLen == :nAt", oBrw:nLen, oBrw:nAt
      IF oBrw:nLen == oBrw:nAt
         nMetod := 1  // ��� ��������� ������
      ENDIF
   ELSEIF oBrw:lIsDbf            //  ��� dbf
      ? " -Del- ordKeyNo() == ordKeyCount()"
      ?? ordKeyNo(), ordKeyCount()
      IF ordKeyNo() == ordKeyCount()
         nMetod := 1  // ��� ��������� ������
      ENDIF
      ?? ":nRowPos=", oBrw:nRowPos
   ENDIF
   ?? "nMetod=",nMetod

   // ��������/�������������� ������ ��������� !!!
   // ���������� ����� ��� �������� ������� ������
   lChange := oBrw:DeleteRow(.F., .T.)

   IF lChange                              // ��������� ����
      ? " -Del- " + ProcNL(), "lChange="+cValToChar(lChange), "�������! ����� ������!"
      ?? "-> nMetod=" + HB_NtoS(nMetod)
      IF nMetod == 1        // ��� ��������� ������ � ���� � �������
         IF oBrw:lIsArr                   // ��� �������
            oBrw:Refresh(.T., .T.)
            nRec := oBrw:nLen
            oBrw:GoPos(nRec, nCell)
            ?? "������� :GoPos(:nLen=", nRec
         ELSEIF oBrw:lIsDbf               // ��� dbf
            (oBrw:cAlias)->( dbSkip(0) )
            oBrw:Reset()
            oBrw:Refresh(.T., .T.)
            oBrw:GoBottom()               // �� ��������� ������
            nRec   := oBrw:nRowPos        // ����� ������ � �������
            nRecno := (oBrw:cAlias)->( RecNo() )
            oBrw:GoToRec( nRecno )
            DO EVENTS
            ?? "������� :GoToRec()=", nRecno, ":nRowPos=",nRec
         ENDIF
      ELSE
         IF nAt == 1
            oBrw:Reset()
            oBrw:Refresh()
            nRecno += 1
         ENDIF
         oBrw:GoToRec( nRecno )
         ?? "GoToRec()=", nRecno
      ENDIF
      // �������� ����� �������� ������
      FOR EACH oCol IN oBrw:aColumns
         nCol := hb_EnumIndex(oCol)
         //? nCol, oCol:cName
         IF oCol:cName == "SELECTOR"     ; LOOP
         ELSEIF oCol:cName == "ORDKEYNO" ; LOOP
         ENDIF
         IF oCol:Cargo:lTotal
            nSum := oCol:Cargo:nTotal
            oCol:Cargo:nTotal := nSum - aSumm[nCol]
            //?? oCol:Cargo:lTotal, oCol:Cargo:nTotal, "|"
            //?? nSum,"-",aSumm[nCol], "=", oCol:Cargo:nTotal
         ENDIF
      NEXT

      oBrw:DrawFooters()   // ���������� ������
      DO EVENTS
      //������ � ������-��������-�������������-���������
      //write to the program-user-actions-log
   ELSE
      ?? "������ ��������", lChange
   ENDIF

   DO EVENTS
   ? " -Del-  .end"

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
//  ��������� �� ����� � ������ ��������� ������� � ������� �������
STATIC FUNCTION myTsbClick( oBrw )
   LOCAL oCol

   //  ��������� �� ���������� ��������� ������� ��� ������ ����� END TBROWSE
   FOR EACH oCol IN oBrw:aColumns
      // ����� � ������ ������ ����� ��� ����� �������
      oCol:bHLClicked := {|Ypix,Xpix,nAt,ob| iif( Ypix > ob:nHeightSuper, ;
                           Tsb_Header(1,"Header!",Ypix,Xpix,nAt,ob) ,;
                           Tsb_SuperHd(1,"Super!",Ypix,Xpix,nAt,ob) ) }
      oCol:bHRClicked := {|Ypix,Xpix,nAt,ob| iif( Ypix > ob:nHeightSuper, ;
                           Tsb_Header(2,"Header!",Ypix,Xpix,nAt,ob) ,;
                           Tsb_SuperHd(2,"Super!",Ypix,Xpix,nAt,ob) ) }
      // ����� � ������ ������ ����� ��� ������� � ������� �������
      oCol:bFLClicked := {|nrp,ncp,nat,obr| Tsb_Foot(1,obr,nrp,ncp,nat) }
      oCol:bFRClicked := {|nrp,ncp,nat,obr| Tsb_Foot(2,obr,nrp,ncp,nat) }
      //oCol:bLClicked:= {|nrp,ncp,nat,obr| Tsb_Cell(1,obr,nrp,ncp,nat) }
      oCol:bRClicked  := {|nrp,ncp,nat,obr| Tsb_Cell(2,obr,nrp,ncp,nat) }
      // ��������� ��� SpecHd �������
      oCol:bSLClicked := {|nrp,ncp,nat,obr| Tsb_SpcHd(1,nrp,ncp,nat,obr) }
      oCol:bSRClicked := {|nrp,ncp,nat,obr| Tsb_SpcHd(2,nrp,ncp,nat,obr) }
   NEXT

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Tsb_Foot( nClick, oBrw, nRowPix, nColPix, nAt )
   LOCAL nRow  := oBrw:GetTxtRow(nRowPix)       // ����� ������ ������� � �������
   LOCAL nCol  := Max(oBrw:nAtCol(nColPix), 1)  // ����� ������� ������� � �������
   LOCAL nCell := oBrw:nCell                    // ����� ������ � �������
   LOCAL cNam  := {'Left mouse', 'Right mouse'}[ nClick ]
   LOCAL cMs, cRW, cCV, xVal, cMsg, cCol

   cMs  := "Mouse y:x = " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix)
   cRW  := "Cell position row/column: " + hb_ntos(nAt) + '/' + hb_ntos(nCell)
   xVal := oBrw:GetValue(nCell)
   cCV  := "Get cell value: [" + cValToChar(xVal) + "]"
   cCol := "Columns: " + oBrw:aColumns[nCol]:cName
   cMsg := cNam + ";" + cMs + ";" + cRW + ";" + cCV + ";" + cCol
   AlertInfo(cMsg,"Footer Table")

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Tsb_Cell( nClick, oBrw, nRowPix, nColPix )
   LOCAL cNam, cForm, Font1, Font2, Font3, cStr, nRow2, nCol, cVal, cNmCol, cFldTp
   LOCAL cCel1, cCel2, cCel3, cCel4, cMsg, cType, xVal, nRow, nI, aDim, cField

   Font1  := GetFontHandle( "ComSanMS" )
   Font2  := GetFontHandle( "Bold"     )
   Font3  := GetFontHandle( "ItalBold" )
   cForm  := oBrw:cParentWnd
   nRow   := oBrw:GetTxtRow(nRowPix)        // ����� ������ ������� � �������
   nCol   := Max(oBrw:nAtCol(nColPix), 1)   // ����� ������� ������� � �������
   nRow2  := oBrw:nAt                       // ����� ������ � �������
   cMsg   := "Mouse y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix)
   cNam   := {'Left mouse', 'Right mouse'}[ nClick ]
   xVal   := oBrw:GetValue(nCol)
   cType  :=  ValType(xVal)
   cCel1  := "Cell position row/column: " + hb_ntos(nRow2) + '/' + hb_ntos(nCol)
   cCel2  := "Type Cell: " + cType
   IF cType == "C"
      cCel3 := "Get Cell value: [" + ALLTRIM(xVal) + "]"
      cVal  := xVal
   ELSE
      cCel3 := "Get Cell value: [" + ALLTRIM(cValToChar(xVal)) + "]"
      cVal  := cValToChar(xVal)
   ENDIF
   cNmCol := oBrw:aColumns[nCol]:cName
   cCel4  = "Columns: " + cNmCol
   // �������� ��� ���� ��
   aDim   := oBrw:Cargo:aTable              // ���� ������ ������� ������� � cargo ����
   nI     := nCol - IIF( oBrw:nColumn("ORDKEYNO", .T.) > 0, 1, 0)  // �������� ����, ���� ���, �� ����� 0
   nI     := nI   - IIF( oBrw:lSelector, 1, 0 )                    // ���� ����/��� ��������
   // {1, "R", "+", "ID recno", "IDP", "999999999", "99999999", NIL, NIL, NIL}
   cField := aDim[nI,5]  // ���� �� ��� �������
   cFldTp := aDim[nI,3]  // ��� ��� �������

   cStr := cNam + CRLF + cMsg  + CRLF + cCel1 + CRLF
   cStr += cCel2 + CRLF + cCel3 + CRLF + cCel4
   DEFINE CONTEXT MENU OF &cForm
      IF App.Cargo:cLang == "RU"
      Item "�������� �������� ������"           ACTION {|| AlertInfo(cVal,"�������� ������")                    } ICON "iEdit64x2"  FONT Font1
      Item "����������� � ����� ������"         ACTION {|| System.Clipboard := cVal /*xVal-������!!!*/          } ICON "iEdit64x1"  FONT Font1
      Item "�������� � ������ �� ������ ������" ACTION {|| Cell_Clipboard(oBrw,cType,nCol,cNmCol,cField,cFldTp) } ICON "iEdit64x1"  FONT Font1
      Item "�������� ������"                    ACTION {|| Cell_Delete(oBrw,cType,xVal,nCol,cField)             } ICON "iEdit64x1"  FONT Font1
      SEPARATOR
      Item "�������� ���� �� ������"    ACTION {|| AlertInfo(cStr,"���� �� ������")  } ICON "iEdit64x2"  FONT Font1
      Item "����������� � ����� ������" ACTION {|| System.Clipboard := cStr          } ICON "iEdit64x1"  FONT Font1
      ELSE
      Item "Show cell value"              ACTION {|| AlertInfo(cVal,"Cell value")                         } ICON "iEdit64x2" FONT Font1
      Item "Copy to clipboard"            ACTION {|| System.Clipboard := cVal /*xVal-impossible!!!*/      } ICON "iEdit64x1" FONT Font1
      Item "Paste to cell from clipboard" ACTION {|| Cell_Clipboard(oBrw,cType,nCol,cNmCol,cField,cFldTp) } ICON "iEdit64x1" FONT Font1
      Item "Clear cell"                   ACTION {|| Cell_Delete(oBrw,cType,xVal,nCol,cField)             } ICON "iEdit64x1" FONT Font1
      SEPARATOR
      Item "Show cell info"    ACTION {|| AlertInfo(cStr,"Cell info") } ICON "iEdit64x2" FONT Font1
      Item "Copy to clipboard" ACTION {|| System.Clipboard := cStr    } ICON "iEdit64x1" FONT Font1
      ENDIF
   END MENU

   _ShowContextMenu(cForm, , , .f. ) // ����� ����������� ����

   InkeyGui(100)  // menu �������� ����� ������� !

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

RETURN Nil

//////////////////////////////////////////////////////////////////
STATIC FUNCTION Cell_Delete(oBrw,cType,xVal,nCol,cField)
   LOCAL nTime := VAL( SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2) )
   LOCAL cFType, cMsg

   IF cType == "C"
      xVal := ""
   ELSEIF cType == "N"
      xVal := 0
   ELSEIF cType == "D"
      xVal := CTOD("")
   ELSEIF cType == "T" .OR. cType == "@"
      xVal := hb_CToT("")
   ELSEIF cType == "L"
      xVal := .F.
   ENDIF

   cFType := FieldType( FieldNum(cField) )
   IF cFType $ "+=^"   // Type field: [+] [=] [^]
      cMsg := "It is forbidden to edit this type of field: "
      cMsg += cField + " !;;"+ProcNL()
      AlertStop(cMsg)
   ELSE
      IF (oBrw:cAlias)->( RLock() )
         oBrw:SetValue(nCol, xVal)
         (oBrw:cAlias)->KOPERAT   := M->nOperat  // ��� ������ ������
         (oBrw:cAlias)->DATEVVOD  := DATE()      // ���� ������
         (oBrw:cAlias)->TIMEVVOD  := nTime       // 9999 ����� ������
         (oBrw:cAlias)->( DbUnlock() )
         (oBrw:cAlias)->( DbCommit() )
      ELSE
         AlertStop("Recording is locked!")
      ENDIF
   ENDIF

   oBrw:DrawSelect()
   oBrw:SetFocus()

RETURN Nil

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Cell_Clipboard(oBrw,cType,nCol,cNmCol,cField,cFldTp)
   LOCAL cFType, cMsg, xWrt, nTime, cClpb

   nTime  := VAL( SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2) )
   xWrt   := System.Clipboard
   cClpb  := VALTYPE(xWrt)
   cFType := FieldType( FieldNum(cField) )
   //MsgDebug(cType,nCol,cField,"|",xWrt,"|",cFType,"cClpb=",cClpb)

   cMsg := "�� �������������� ������ ��� ������� !"
   cMsg += ";  �������: " + cNmCol + " ���: " + cFldTp
   cMsg += ";���� � ��: " + cField + " ���: " + cFType
   cMsg += ";;Unsupported format when pasting! ;"
   cMsg += ";  Column: " + cNmCol + " type: " + cFldTp
   cMsg += ";Field DB: " + cField + " type: " + cFType
   cMsg += ";;"+ProcNL()
   IF cFldTp $ "SJKB"
      AlertStop(cMsg)
      RETURN NIL
   ELSEIF cFldTp == "BMP"
      AlertStop(cMsg)
      RETURN NIL
   ENDIF

   IF cFType == "L"
      xWrt := IIF(UPPER(xWrt)=="T",.T.,.F.)
   ELSE
      IF cType == cClpb
         // ���� ���������
      ELSEIF cType == "C" .AND. cClpb # "C"
         xWrt := cValToChar(xWrt)
      ELSEIF cType == "N" .AND. cClpb == "C"
         xWrt := VAL(xWrt)
      ELSEIF cType == "D" .AND. cClpb == "C"
         xWrt := CTOD(xWrt)
      ELSEIF cClpb # "T" .OR. cClpb == "@"
         xWrt := hb_CToT(xWrt)
      ELSE
         cMsg := "�� ������������ ����� ������ ��� ������� !"
         cMsg += ";  �������: " + cNmCol + " ���: " + cType
         cMsg += ";���� � ��: " + cField + " ���: " + cFType
         cMsg += ";;Data type mismatch when inserting!"
         cMsg += "; Column: " + cNmCol + " type: " + cType
         cMsg += ";Field in the database: " + cField + " type: " + cFType
         cMsg += ";;"+ProcNL()
         AlertStop(cMsg)
         RETURN NIL
      ENDIF
   ENDIF

   IF cFType $ "M"
      // �� �������
   ELSEIF cFType $ "C" .AND. CRLF $ xWrt
      xWrt := ATREPL( CRLF, xWrt, "|" )
      xWrt := ALLTRIM( xWrt )
   ENDIF

   IF cFType $ "+=^"   // Type field: [+] [=] [^]
      cMsg := "It is forbidden to edit this type of field: "
      cMsg += cField + " !;;"+ProcNL()
      AlertStop(cMsg)
   ELSE
      IF (oBrw:cAlias)->( RLock() )
         oBrw:SetValue(nCol, xWrt)
         (oBrw:cAlias)->KOPERAT   := M->nOperat  // ��� ������ ������
         (oBrw:cAlias)->DATEVVOD  := DATE()      // ���� ������
         (oBrw:cAlias)->TIMEVVOD  := nTime       // 9999 ����� ������
         (oBrw:cAlias)->( DbUnlock() )
         (oBrw:cAlias)->( DbCommit() )
      ELSE
         AlertStop("Recording is locked!")
      ENDIF
   ENDIF

   oBrw:DrawSelect()
   oBrw:SetFocus()

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Tsb_Header(nClick,cMenu,nRowPix,nColPix,nAt,oBrw)
   LOCAL nCol, oCol, cName, cMouse, cPix, cCell, nCell, cMsg

   nCol   := Max(oBrw:nAtColActual( nColPix ), 1 )  // ����� �������� ������� ������� � �������
   oCol   := oBrw:aColumns[ nCol ]
   nCell  := oBrw:nCell                              // ����� ������ � �������
   cName  := "Columns: " + oCol:cName
   cMouse := {'Left mouse', 'Right mouse'}[ nClick ]
   cPix   := "Mouse y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix)
   cCell  := "nCell: " + HB_NtoS(nCell) + " nLine: " + HB_NtoS(nAt)
   cMsg   := cMouse + ";" + cMenu + ";" + cPix + ";" + cName + ";" + cCell

   AlertInfo(cMsg,"Header Table")

   oBrw:SetFocus()

RETURN NIL

////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Tsb_SuperHd(nClick,cMenu,nRowPix,nColPix,nAt,oBrw)
   LOCAL cForm, nCell, cCell, nCol, oCol, nRow, cName, cMouse, cPix, cMsg

   cForm  := oBrw:cParentWnd
   nRow   := oBrw:GetTxtRow(nRowPix)                 // �� �� ! ����� ������ ������� � �������
   nCol   := Max(oBrw:nAtColActual( nColPix ), 1 )   // ����� �������� ������� ������� � �������
   nCell  := oBrw:nCell                              // ����� ������ � �������
   oCol   := oBrw:aColumns[ nCol ]
   cName  := "Columns: " + oCol:cName
   cMouse := {'Left mouse', 'Right mouse'}[ nClick ]
   cPix   := "Mouse y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix)
   cCell  := "nCell: " + HB_NtoS(nCell) + " nLine: " + HB_NtoS(nAt)
   cMsg   := cMouse + ";" + cMenu + ";" + cPix + ";" + cName + ";" + cCell

   AlertInfo(cMsg,"Super Header Table")

   oBrw:SetFocus()

RETURN NIL

////////////////////////////////////////////////////////////////////////////
FUNCTION TitleSuperHider(cMaska,lSay)
   LOCAL cTtl
   DEFAULT lSay := .T.

   IF lSay 
      IF App.Cargo:cLang == "RU"
         cTtl := "�������: No ��������� ������ = " + cMaska + CRLF
         cTtl += "�������������� ������� - ���������" + CRLF
         cTtl += "���������� �� ��������: ���� � ����� �������� ������"
      ELSE
         cTtl := "Selection: Payment document No. = " + cMaska + CRLF
         cTtl += "Editing columns is allowed" + CRLF
         cTtl += "Sort by columns: Date and time of record creation"
      ENDIF
   ELSE
      IF App.Cargo:cLang == "RU"
         cTtl := cMaska + CRLF + "�������������� ������� - ���������" + CRLF
         cTtl += "�������� ! ��� �������� ����� � �������: F7-�����,"
         cTtl += " ����� ���� ����: ������������� �� ����"
      ELSE
         cTtl := cMaska + CRLF + "editing columns is PROHIBITED" + CRLF
         cTtl += "Attention! To return input to the table: F7-search,"
         cTtl += "next menu item: Switch to input"
      ENDIF
   ENDIF

RETURN cTtl

//////////////////////////////////////////////////////////////////////////////////
// ��������� ����������(����������) �������
STATIC FUNCTION Tsb_SpcHd( nClick, nRowPix, nColPix, nAt, oBrw )
   LOCAL cForm, nRPos, nAtCol, cNam, cName, cMsg, cCnr, nCnr, cMsg0
   LOCAL oCol, nY, nX, cMsg1, cMsg2, cMsg3, cMsg4, nVirt, cCol, nCol
   LOCAL nClickRow := oBrw:GetTxtRow( nRowPix )

   cForm  := oBrw:cParentWnd
   nRPos  := oBrw:nRowPos
   nAtCol := Max( oBrw:nAtCol( nColPix ), 1 )  // ����� �������
   oCol   := oBrw:aColumns[ nAtCol ]
   cName  := oCol:cName
   nVirt  := 0
   cCnr   := ""
   nCnr   := 0
   nY     := GetProperty(cForm, "Row") + GetTitleHeight()
   nX     := GetProperty(cForm, "Col") + GetBorderWidth() - 4
   // ����� ���������� �� ����� �������
   nY     += GetMenuBarHeight() + oBrw:nTop + 2
   nY     += IIF( oBrw:lDrawSuperHd, oBrw:nHeightSuper , 0 )
   nY     += IIF( oBrw:lDrawHeaders, oBrw:nHeightHead  , 0 )
   nY     -= 1   //IIF( oBrw:lDrawSpecHd , oBrw:nHeightSpecHd, 0 )
   nX     += oCol:oCell:nCol
   nX     += IIF( oBrw:lSelector, oBrw:aColumns[1]:nWidth , 0 )  // ���� ���� ��������
   nX     -= 5
   nX     := INT(nX)
   nY     := INT(nY)

   FOR nCol := 1 TO 3
      cCol := oBrw:aColumns[ nCol ]:cName
      IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
         nVirt ++
      ENDIF
   NEXT

   cMsg  := "Special Header - "
   cNam  := {'Left mouse', 'Right mouse'}[ nClick ]
   cMsg0 := cMsg + cNam
   cMsg1 := "Mouse  y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix)
   cMsg2 := "Head position y/x: " + hb_ntos(nY) + '/' + hb_ntos(nX)
   // ������ ������� �� ��������� � �������� ����� � ����,
   // �.�. ���� �������/�������� ������� �� ������� ��.������� myBrwDelColumn()
   // ��������� ����� �� ���������� �������
   //cCnr := oBrw:aColumns[ oBrw:nCell ]:cSpcHeading - ��� ������
   cCnr := oBrw:aColumns[ nAtCol ]:cSpcHeading
   nCnr := Val( cCnr )

   cMsg3 := "Column header: " + hb_ntos(nCnr) + "  [" + cName + "]"
   cMsg4 := "nAt=" + hb_ntos(nAt) + ", nAtCol=" + hb_ntos(nAtCol)
   cMsg4 += ", nClickRow=" + hb_ntos(nClickRow)
   cMsg  := cMsg0 + ";" + cMsg1 + ";" + cMsg2 + ";" + cMsg3 + ";" + cMsg4

   IF     cName == "SELECTOR"
   ELSEIF cName == "ORDKEYNO"
   ENDIF
   AlertInfo( cMsg, "Special Header Table" )

RETURN NIL

//////////////////////////////////////////////////////////////////////////////////
FUNCTION ColumnEdit_STKB(oBrw,aVal)
   LOCAL cMsg, aTyp, aDim, cFld, cAls, nClmn, aCntMn, aIcon, a2Dim, aSpr, aRet

   //{"NAME_14", "S", 14, {1, "W", "S", "��� ������", "KOPLATA", "aaa..", "xxx...", "bKey12", {"Oplata", "KOplata", "Oplata", "��� ������"}, NIL}}
   aTyp   := aVal[2]   // ��� ���������
   nClmn  := aVal[3]   // ����� ������� � ������� ������� Column_TSB()
   aDim   := aVal[4]   // ������ ������ ������� �� Column_TSB()
   aCntMn := oBrw:Cargo:aCntMnu    // ������ ��� ������������ ���� - ��� "S"
   aIcon  := aCntMn[nClmn]
   cFld   := aDim[5]   // ��� ���� ��� ������
   aSpr   := aDim[9]   // ������ ��� ����
   cAls   := ALIAS()
   cMsg   := ProcNL(0) + ";" + ProcNL(1) + ";;"
   cMsg   += "��������: " + oBrw:ClassName + " � "
   cMsg   += HB_ValToExp(aVal)  + ";;"
   cMsg   += '������� ��������� �����: "S", "T", "K", "B" !;;'
   cMsg   += 'Type processing function: "S", "T", "K", "B" !;;'

   IF FIELDNUM(cFld) == 0
      cMsg := "������ ! ��� ���� [" + cFld + "] � ��-"
      cMsg += cAls + ";;"
      cMsg += "ERROR! There is no field [" + cFld + "] in DB-"
      cMsg += cAls + ";;"
      cMsg += ProcNL(0) + ";" + ProcNL(1)
      AlertStop(cMsg)
      RETURN NIL
   ENDIF

   IF aTyp == "S"
      // aSpr = {"Oplata","KOplata","Oplata","��� ������","Name","cFilter"}
      a2Dim := myGetDbf2Dim(cAls,aSpr)
      aRet  := mySpavContexMenu(a2Dim,aSpr[4],aIcon,"ICO")
      IF LEN(aRet) > 0
         (cAls)->&cFld := aRet[1] // ��� � ����
      ENDIF
   ELSE
      myRunInfo(cMsg)
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION ColumnEdit_J(ob,ni,cRun,cNm,aVal,cStr)  // ��� ���������� ��������
   LOCAL cBlock, cMsg, xv, aRet

   IF IsArray(cRun)
      cRun := HB_ValToExp(cRun)
   ENDIF
   IF ! IsString(cRun)
      cRun := cValToChar(cRun)
   ENDIF
   //
   cRun   := SUBSTR(cRun,1,AT("(",cRun)-1)
   cBlock := cRun + "(" + HB_ValToExp(aVal) + ")"
   IF !hb_IsFunction( cRun )
      cMsg := ":bPrevEdit - �������/column " + cNm + ";;"
      cMsg += "�������: " + cRun + "()  ��� � EXE-����� !;;"
      cMsg += "������: aDim[" + HB_NtoS(ni) + "];"
      cMsg += "Functions: " + cRun + "() not in the EXE file!;;"
      cMsg += "Line: aDim[" + HB_NtoS(ni) + "];"
      cMsg += cStr + ";;"
      cMsg += ProcNL( 0 ) + ";" + ProcNL( 1 )
      AlertStop( cMsg, "������ ������� / Startup error !" )
   ELSE
      aRet := Eval( hb_macroBlock( cBlock ) )
      // ������ ��� �������������
      // ������ ��������� ������ � ����
      cMsg := ":bPrevEdit - �������/column " + cNm + ";;"
      cMsg += "Function: " + cRun + "() !;;"
      IF IsNumeric(aRet)
         xv := aRet
         IF xv >= 0  // ��������� ���� !
            ob:SetValue(cNm , xv )
            ?? " -->>  cNm=",cNm, "Write=", xv
         ENDIF
      ELSEIF IsArray(aRet)
         cMsg += "�������/Return = " + HB_ValToExp(aRet) + " !;;"
         cMsg += ProcNL( 0 ) + ";" + ProcNL( 1 )
         AlertInfo( cMsg, "����� ������� / Launch success !" )
         ?? " -->>  cNm=",cNm, "Write=", xv
       ELSE
         cMsg += "������ - ������� �� ������ {} !;"
         cMsg += "ERROR - return is not an array {} !;"
         cMsg += "aRet = " + cValToChar(aRet) + ";;"
         cMsg += ProcNL( 0 ) + ";" + ProcNL( 1 )
         AlertStop( cMsg, "������ ������� / Startup error !" )
      ENDIF
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION ColumnEdit_bPost(ob,ni,cRun,cNm,aVal,cStr,oc)  // ��� ���������� ��������
   LOCAL cBlock, cMsg, aRet, lModify, xGet
   LOCAL nTime := VAL( SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2) )

   IF IsArray(cRun)
      cRun := HB_ValToExp(cRun)
   ENDIF
   IF ! IsString(cRun)
      cRun := cValToChar(cRun)
   ENDIF
   IF LEN(cRun) > 0
      cRun   := SUBSTR(cRun,1,AT("(",cRun)-1)
      cBlock := cRun + "(" + HB_ValToExp(aVal) + ")"
      IF !hb_IsFunction( cRun )
         cMsg := ":bPostEdit - ������� " + cNm + ";;"
         cMsg += "�������: " + cRun + "()  ��� � EXE-����� !;;"
         cMsg += "������: aDim[" + HB_NtoS(ni) + "];"
         cMsg += "Functions: " + cRun + "() not in the EXE file!;;"
         cMsg += "Line: aDim[" + HB_NtoS(ni) + "];"
         cMsg += cStr + ";;"
         cMsg += ProcNL(0) + ";" + ProcNL(1)
         AlertStop( cMsg, "������ ������� / Startup error !" )
         aRet := {}
      ELSE
         aRet := Eval( hb_macroBlock( cBlock ) )
         // ������ ��� �������������
         // ������ ��������� ������ � ����
         cMsg := ":bPrevEdit - �������/column " + cNm + ";;"
         cMsg += "Function: " + cRun + "() !;;"
         IF IsArray(aRet)
            cMsg += "�������/Return = " + HB_ValToExp(aRet) + " !;;"
            cMsg += ProcNL(0) + ";" + ProcNL(1)
            //AlertInfo( cMsg, "����� ������� !" )
          ELSE
            cMsg += "������ - ������� �� ������ {} !;"
            cMsg += "ERROR - return is not an array {} !;"
            cMsg += "aRet = " + cValToChar(aRet) + ";;"
            cMsg += ProcNL(0) + ";" + ProcNL(1)
            AlertStop( cMsg, "������ ������� / Startup error !" )
            aRet := {}
         ENDIF
      ENDIF
      IF LEN(aRet) > 0
         xGet := aRet[1]
         IF (ob:cAlias)->(RLock())      // �� ������ ������
            //?? " -->>  cNm=",cNm, "Write=", HB_ValToExp(aRet)
            ob:SetValue(cNm , xGet )    // ������ � ����
            IF ( lModify := oc:xOldEditValue != xGet )  // modify value
               ob:Cargo:nModify ++  // ���� ����������� �������
               //������ � ������-��������-�������������-���������
               //write to the program-user-actions-log
            ENDIF
         ELSE
            cMsg := "������ ������������� !;"
            cMsg += "Recno blocked !; Recno="
            cMsg += HB_NtoS(RECNO()) + ";;" + ProcNL()
            AlertStop( cMsg )
         ENDIF
         (ob:cAlias)->KOPERAT   := M->nOperat // ��� ������ ������
         (ob:cAlias)->DATEVVOD  := DATE()     // ���� ������
         (ob:cAlias)->TIMEVVOD  := nTime      // 9999 ����� ������
         (ob:cAlias)->(dbUnLock())
         ob:Skip(0)
         ob:DrawSelect()    // ������������ ������� ������ �������
      ENDIF
   ENDIF

RETURN NIL
