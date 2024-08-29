/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ����� �� ���� � ������� SCOPE
 * ������ ������ ��� ������� �� ���� �� "����"
 * Database report using SCOPE
 * Calculation of totals when filtering by database on the "fly"
*/

#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"
*-----------------------------------------------------------------------------*
FUNCTION Report_2_1(oWnd,oBrw)
*-----------------------------------------------------------------------------*
   LOCAL aList1, aMenu1, aScop1, aMsg, nI, aRpt, cDat, nLine, lDbf, oCol
   LOCAL cAls, dDate, cTime, nSumma, nKolvo, nJ, cTitle, cDbf, cMAls, aRet

   aList1 := oWnd:Cargo:aList1   // ������ ���.����� �� ���� ����
   aMenu1 := aList1[1]
   aScop1 := aList1[2]
   cMAls  := oBrw:cAlias
   nLine  := 0
   IF App.Cargo:cLang == "RU"
      cTitle := "������: � ���������� �� ���� ����"
      aMsg   := { "������ �� ���� ....", "����� �� ������ ���������� - ����� �1" }
   ELSE
      cTitle := "List: No. of documents in the entire database"
      aMsg   := { "Calculation based on ....", "Report by document number - Form D1" }
   ENDIF
   // ��������� ����� oBrw
   oCol := oBrw:aColumns[ 3 ]  // 3 ������� � ������
   oCol:SaveColor()
   oBrw:Cargo:aTsbColor := oCol:aColorsBack
   // ���������� ������� � ���������
   oBrw:nCLR_Gray  := HMG_RGB2n({184,196,55})
   oBrw:nCLR_HGray := HMG_RGB2n({184,196,55})
   oBrw:nCLR_Lines := CLR_YELLOW
   oBrw:Enabled(.F.)
   //oBrw:lEnabled := .F. �� ��������

   WaitWindow( aMsg, .T. , 600, 16, NIL, BLUE, App.Cargo:aBClrMain )

   // ������ � �����
   dbSelectArea(cMAls)
   OrdSetFocus("ULIST2")          // ��� ������ ������� �����
   // calculate the results
   aRpt := {}
   FOR nI := 1 TO LEN(aMenu1)
      aMsg := {nI, aMenu1[nI], 0, 0.00, CTOD(""), TIME() }
      cDat := aScop1[nI]
      SET SCOPE TO cDat, cDat
      GOTO TOP
      nKolvo := ORDKEYCOUNT()  // ����� ���-�� ������� �� �������
      nSumma := 0
      dDate  := (cMAls)->DATEVVOD2
      cTime  := (cMAls)->TIMEVVOD2
      FOR nJ := 1 TO nKolvo
         ORDKEYGOTO(nJ)
         nSumma += (cMAls)->PRIXOD
      NEXT
      aMsg[3] := nKolvo
      aMsg[4] := nSumma
      aMsg[5] := dDate
      aMsg[6] := cTime
      AADD( aRpt, aMsg )
      DO EVENTS
   NEXT
   //? "=======",ProcNL(), "aRpt=",aRpt ; ?v aRpt
   //31 {31, "��� ���� �� 02.05.2024 �����������", 3, 262.00, 0d20240502, "21:42:27"}
   //32 {32, "������� �� 03.05.2024 �������", 3, 157.00, 0d20240503, "21:42:27"}
   WaitWindow()
   DO EVENTS

   cDbf := App.Cargo:cPathDbf + "tmp_menu_" + ProcName() + ".dbf"
   cAls := "Menu"
   lDbf := New2Dbf(cDbf,cAls,aRpt)
   DbSelectArea(cAls)

   IF lDbf
      aRet := TsbReport( oWnd, cAls, cTitle )
      ? ProcNL(), "aReturn=", HB_ValToExp(aRet)
      IF LEN(aRet) > 0  ;  nLine := aRet[1]
      ENDIF
      (cAls)->( DbCloseArea() )
   ENDIF

   DbSelectArea(cMAls)
   oBrw:Enabled(.T.)
   //oBrw:lEnabled := .T. - �� ��������

   DO EVENTS

RETURN nLine

*-----------------------------------------------------------------------------*
STATIC FUNCTION TsbReport( oWnd, cAls, cTitle )
*-----------------------------------------------------------------------------*
   LOCAL oRpt, nY, nX, nW, nH, nG, cTltip, aField, aHead, o, owc
   LOCAL oCel, oBrw, oGet, aReturn, hFont, aFont, cMsg, aHW, aItogo
   LOCAL aFldSum := {"F3", "F4"}  // ���� dbf ��� ������� �����

   oBrw    := oWnd:Cargo:oBrw  // �������� �������
   // initial columns
   aField  := { "F2", "F3", "F4", "F5", "F6", "F1" }
   IF App.Cargo:cLang == "RU"
      aHead := { "� ��������� ������", "���-��"+CRLF+"���������", "�����"+CRLF+"�����", "����", "�����","ID" }
      cMsg  := "������ ������ �� dbf-�����..."
   ELSE
      aHead := { "� payment document", "Quantity"+CRLF+"receipts", "Total"+CRLF+"amount", "Date", "Time","ID" }
      cMsg  := "Calculation of TOTAL by dbf file..."
   ENDIF
   cTltip  := "" //"������� ���� �� ��������� � ����������"
   hFont   := GetFontHandle('ComSanMS')
   aFont   := GetFontParam(hFont)

   nG := 10     // ������ ����� � ����� �������� �� ������/������
   nY := nX := nG
   nW := 900 ; nH := 650+GetTitleHeight()+GetBorderHeight()
   DbSelectArea(cAls)
   aItogo := Itogo_Dbf(aFldSum, Alias(), cMsg)

   DEFINE WINDOW Report AT nY,nX WIDTH nW HEIGHT nH TITLE cTitle ;
      MODAL NOSIZE BACKCOLOR oWnd:Cargo:aBColor                  ;
      FONT aFont[1] SIZE aFont[2]                                ;
      ON INIT    _wPost( 0)                                      ;
      ON RELEASE _wSend(90)

      This.Cargo  := oHmgData() ; owc := This.Cargo  // ��� ���� ������� ������ ��� ���������� (������� ������)
      owc:oWin    := This.Object      // ������ ����
      owc:cForm   := This.Name        // ��� ����
      owc:aReturn := {}               // ������� ������ ��������� ��������
      owc:nHIco   := 48               // ������ ������ �� ������
      owc:aFldSum := aFldSum          // ��� ������� ������� - �����
      owc:nCount  := aItogo[1]
      owc:aItogo  := aItogo[2]

      /////////////////////// ������ ������ ����� ///////////////////////////////////
      aHW := myTopMenu( nY/2, nX, nG, owc:nHIco )
      nY  := aHW[1]
      nX  := nG
      nW  := This.ClientWidth
      nH  := This.ClientHeight - nY

      DEFINE TBROWSE oRpt OBJ oRpt AT nY, nX ALIAS cAls WIDTH nW-nG*2 HEIGHT nH-nG CELL ;
         FONT    oBrw:Cargo:aFont         ; // ��� ����� ��� �������
         BRUSH   oBrw:Cargo:aClrBrush     ; // ���� ���� ��� ��������
         HEADERS aHead                    ; // ������ ����� ������� �������
         COLUMNS aField                   ; // ������ ������������ ������� �������
         COLNUMBER { 1 , 50 }             ; // ����� ������� ����������� ������� � ����������
         LOADFIELDS                       ; // �������������� �������� �������� �� ����� �������� ���� ������
         GOTFOCUSSELECT                   ;
         EMPTYVALUE                       ;
         FIXED                            ; // ���������� ������� �������� ������� �� ������������ ��������
         TOOLTIP cTltip                   ;
         ON INIT {|ob| myTsbInit( ob ) }    // ��������� ������� - �������� ����

         myTsbTune(oRpt)              // ���������
         myTsbColor(oRpt,oBrw)        // ����� ��������
         myTsbKeys(oRpt)              // ��������� ������
         // �� ������ ���� �����, ����� ������� ! myTsbItogo() // ��������� �������

      END TBROWSE ON END {|ob| ob:SetNoHoles(), ob:SetFocus() }

      This.Cargo:oRpt := oRpt        // �������� ������ oRpt (�������) �� ����
      ? ProcNL() , "~~~~~~~>>>", oRpt, This.Cargo

      ON KEY F1     ACTION NIL
      ON KEY ESCAPE ACTION _wPost(98)

      // ���������� ������ � ������� GetBox
      oCel := oRpt:GetCellInfo( 2 )
      nX   := oCel:nCol + 2
      nW   := oCel:nWidth - 5
      nH   := oRpt:nHeightCell
      nY   := ( oRpt:nHeightFoot - nH ) / 2
      nY   := This.ClientHeight - oRpt:nHeightFoot + nY
      cMsg := oRpt:aColumns[2]:cFooting             // "�����:"
      nX   += GetTextWidth( NIL, cMsg, GetFontHandle('Bold') ) + 10
      nW   -= GetTextWidth( NIL, cMsg, GetFontHandle('Bold') ) + 10
      // GetBox � ������� �������
      @ nY-nG, nX+nG GETBOX GB_Find OBJ oGet WIDTH nW-nG HEIGHT nH VALUE space(30) ;
        PICTURE "@K" NOTABSTOP INVISIBLE   ;
        ON LOSTFOCUS {|| This.Cargo := .F., This.Value := space(30), This.Hide } ;
        ON CHANGE    {|| iif( Empty( This.Cargo ), NIL, Search_TSB( ThisWindow.Object, .T. ) ) } ;
        ON INIT      {|| This.Cargo := .T. }

      This.Cargo:oGet := oGet
      This.Cargo:cGet := "GB_Find"    // ��������� ��� ����������� �������������

      ///////////////////////////////////
      o := This.Object

      o:Event( 0, {|ow| _wPost(22, ow)  } )  // ������������� ����� ���������� ����

      // ������ ������ �����
      //aPost := { "_2Enter", "_2Prn" , "_2Excel", "_2Exit" }
      o:Event({10, "_2Enter"}, {|ow| // ������� ��������� ������
                                     Local oRpt := ow:Cargo:oRpt
                                     Local cAls := oRpt:cAlias
                                     ow:Cargo:aReturn := {(cAls)->F1,(cAls)->F2}
                                     _wSend(99)           // ������� Modal ����
                                     Return Nil
                                } )

      o:Event({11, "_2Prn"}, {|ow,ky,cn| ;
                                   AlertInfo('Printing.  This.Name = ' + This.Name, ow:Name) ,;
                                   ky := cn, This.&(cn).Enabled := .T.    } )

      o:Event({12,"_2Excel"}, {|ow,ky,cn| ;
                                MsgBox('Export to MS Excel. This.Name = ' + This.Name, ow:Name) ,;
                                ky := cn, This.&(cn).Enabled := .T.    } )

      o:Event({15,"_2Exit" }, {|ow| _LogFile(.T., ProcNL(),">>> Exit button pressed! Window: "+ow:Name), _wSend(99) } )

      // ������ � ��������
      o:Event( 22, {|ow| myTsbItogo(ow)                  } )    // ����� refresh

      o:Event( 90, {|  | aReturn := (This.Cargo):aReturn  } )    // ������� LOCAL aReturn

      o:Event( 98, {|ow|
                    Local oRpt := ow:Cargo:oRpt
                    Local cGet := ow:Cargo:cGet
                    Local lGet := This.&(cGet).Cargo
                    IF !Empty( lGet )       // mode find
                       oRpt:SetFocus()
                    ELSE                    // no mode
                       _wSend(99)
                    ENDIF
                    Return Nil
                    } )
      o:Event( 99, {|ow| ow:Release()  } )

   END WINDOW

     CENTER WINDOW Report
   ACTIVATE WINDOW Report

RETURN aReturn

//////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbInit( oRpt )  // ��������� ���  !!!

   WITH OBJECT oRpt
      :Cargo := oHmgData()
      :lNoChangeOrd  := .T.     // ��������� ���������� �� ��������
      :nColOrder     :=  0      // ������ ������ ���������� �� �������
      :lNoGrayBar    := .F.     // T-�� ���������� ���������� ������ � �������
      :lNoLiteBar    := .F.     // ��� ������������ ������ �� ������ ���� �� ������� "������" Bar
      :lNoResetPos   := .F.     // ������������� ����� ������� ������ �� gotfocus
      :lPickerMode   := .F.     // ������ ���� ���������� ����� �����
      :nStatusItem   :=  0      // � 1-� Item StatusBar �� �������� ��������� �� ���
      :lNoKeyChar    := .T.     // .T. - ����. ����� KeyChar(...) - ���� �� ����, ����
      :nWheelLines   :=  1      // ��������� ������� ����
      :nCellMarginLR :=  1      // ������ �� ����� ������ ��� �������� �����, ������ �� ���-�� ��������
      :lMoveCols     := .F.
      :nMemoHV       :=  1      // ����� ����� ������ ����-����
      :nLineStyle := LINES_ALL
      :nClrLine   := COLOR_GRID
      :lCheckBoxAllReturn := .T.
      :lNoVScroll    := .F.
      :lNoHScroll    := .T.
   END WITH

   oRpt:Cargo:cKeyLang := '('+KB_LANG()+')' // -> util_keychar.prg

RETURN Nil

//////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbTune(oRpt)              // ���������
   LOCAL cMsg := IIF( App.Cargo:cLang == "RU", "�����:", "Search:")

   WITH OBJECT oRpt

      :HideColumns( {7} ,.t.)   // ������ �������
      :nHeightCell  += 6
      :nHeightHead  := :nHeightCell + 2
      :nHeightFoot  := :nHeightCell + 2
      :lDrawFooters := .T.
      :lFooting     := .T.

      :aColumns[ 2 ]:hFont    := GetFontHandle('ComSanMS')
      :aColumns[ 2 ]:nWidth   += 40
      :aColumns[ 2 ]:cFooting := cMsg
      :aColumns[ 2 ]:nFAlign  := DT_LEFT
      :aColumns[ 6 ]:nWidth   += 10

      // ����� ��������� � �������������� ����������� ����� TBrowse
      :bEvents := { |a,b| myTsbEvents(a,b) }

      :lNoChangeOrd := .F.  // �������� ���������� �� ��������
      AEval( :aColumns, {|oc,nc| oc:lFixLite := .T., oc:lIndexCol := nc > 1 })

      :AdjColumns({4, 5, 6})   // :AdjColumns()

      :nFreeze     := oRpt:nColumn("ORDKEYNO") // ���������� ������� �� ����� �������
      :lLockFreeze := .T.                      // �������� ���������� ������� �� ������������ ��������
      :nCell       := oRpt:nFreeze + 1         // ����������� ������ �� ������� �����

   END WITH

RETURN Nil

//////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbItogo( oWnd )  // ������ - ������ �����
   LOCAL aItg := oWnd:Cargo:aItogo
   Local oRpt := oWnd:Cargo:oRpt

   ? ProcNL(), "##", oWnd, oWnd:Cargo, oWnd:Classname
   ? "oWnd:Cargo:aItogo=   aItg=",aItg, HB_ValToExp(aItg)
   ? "oRpt:=", oRpt, oRpt:Classname,oRpt:cAlias

   oRpt:aColumns[1]:cFooting := {|nc,ob| nc := ob:nLen, iif( Empty(nc), "", hb_NtoS(nc) ) }
   oRpt:aColumns[3]:cFooting := {|nc   | nc := aItg[1], iif( Empty(nc), "", hb_NtoS(nc) ) }
   oRpt:aColumns[4]:cFooting := {|nc   | nc := aItg[2], iif( Empty(nc), "", hb_NtoS(nc) ) }

   oRpt:Cargo:cKeyLang := '('+KB_LANG()+')' // -> util_keychar.prg
   oRpt:aColumns[5]:cFooting := oRpt:Cargo:cKeyLang

   oRpt:DrawFooters() ; DO EVENTS

RETURN Nil

//////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbColor(oRpt,oBrw)  // ����� ��������
   LOCAL aColor, nCol, nJ, nClrBC, aBClr

   // ����� ����� ���������� �������
   aColor := oBrw:Cargo:aTsbColor
   nClrBC := oBrw:Cargo:nClrBC
   aBClr  := oBrw:Cargo:aClrBrush        // ���� ���� ��� ��������

   // ������������ ����� � 2-�� �������
   FOR nCol := 1 TO LEN(oRpt:aColumns)
      FOR nJ := 1 to 15  // ������ ���� �� 15
         oRpt:Setcolor( { nJ }, { aColor[nJ] }, nCol  )
      NEXT
      oRpt:SetColor( {  1 }, { { || CLR_BLUE     } } )    // 1 , ������ � ������� �������
      oRpt:SetColor( {  2 }, { { || nClrBC       } } )    // 2 , ���� � ������� �������
   NEXT
   oRpt:hBrush := CreateSolidBrush(aBClr[1], aBClr[2], aBClr[3])  // ���� ���� ��� ��������
   oRpt:GetColumn("ORDKEYNO"):nClrBack := oBrw:Cargo:nBtnFace
   oRpt:GetColumn("ORDKEYNO"):nClrFore := CLR_RED
   oRpt:aColumns[7]:nClrFore := CLR_WHITE

RETURN Nil

////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbKeys(oRpt)          // ��������� ������

   WITH OBJECT oRpt

      :UserKeys( VK_F5, {|ob| _wPost(/*1*/"Print", ob) } )
      :UserKeys( VK_F6, {|ob| _wPost(/*2*/"Excel", ob) } )
      // ������� ���� ����� �� �������
      :bLDblClick := {|p1,p2,p3,ob| p1:=p2:=p3, ob:PostMsg( WM_KEYDOWN, VK_RETURN, 0 ) }
      // ��������� ������� ENTER � ESC
      :UserKeys(VK_RETURN, {|ob| _wPost(10, ob:cParentWnd) })  // ������� ��������� ������
      :UserKeys(VK_ESCAPE, {|ob| _wSend(98, ob:cParentWnd) })
      :UserKeys(         , {|ob,ky,ck| // ����� ���� ��� ������
                             Local oWnd := _WindowObj(ob:cParentWnd)
                             Local cGet := oWnd:Cargo:cGet //"GB_Find"
                             Local oGet := oWnd:GetObj(cGet), cVal
                             SET WINDOW THIS TO oWnd
                             ck := KeyToChar(ky)
                             If len(ck) > 0
                                IF !Empty((ob:cAlias)->( dbFilter() ))
                                   ob:FilterFTS( Nil )
                                   //ob:FilterRow()
                                ENDIF
                                This.&(cGet).Cargo := .T. // find mode
                                oGet:Show()
                                oGet:SetFocus()
                                DO EVENTS
                                cVal := oGet:Get:VarGet()
                                oGet:Get:VarPut(space(len(cVal)))
                                DO EVENTS
                                _PushKey(ky)
                             EndIf
                             SET WINDOW THIS TO
                             Return Nil
                             })
   END WITH

RETURN Nil

////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbEvents(oRpt, nMsg)
   LOCAL cLang

   IF nMsg != WM_PAINT
      cLang := '('+KB_LANG()+')'
      IF cLang != oRpt:Cargo:cKeyLang
         oRpt:aColumns[5]:cFooting := cLang
         oRpt:Cargo:cKeyLang := cLang
         oRpt:DrawFooters()
      ENDIF
   ENDIF

RETURN 0

//////////////////////////////////////////////////////////////////////
// GetBox � ������� �������
STATIC FUNCTION Search_TSB(oWnd, aWait)          // ����� �� ����
   LOCAL oRpt, cVal, cGet, aItg
   Default oWnd  := ThisWindow.Object
   Default aWait := .F.

   oRpt := oWnd:Cargo:oRpt
   cGet := oWnd:Cargo:cGet             // ��� "GB_Find"

   IF !Empty(aWait)
      IF HB_ISLOGICAL(aWait)
         aWait := "Calculation RESULTS..."
      ENDIF
      // ������ ����������� LOSGFOCUS getbox
      //WaitWindow( aWait, .T. , 600, 16, NIL, BLUE, App.Cargo:aBClrMain )
   ENDIF

   SET WINDOW THIS TO oWnd
   This.&(cGet).Show
   cVal := Trim( This.&(cGet).Value )
   SET WINDOW THIS TO

   oRpt:FilterFTS( cVal, .T. )         // Empty(cVal) ��������� ������ ������

   aItg := Itogo_Dbf(oWnd:Cargo:aFldSum, oRpt:cAlias) // ������� �����

   oWnd:Cargo:nCount  := aItg[1]
   oWnd:Cargo:aItogo  := aItg[2]

   // ������ ����������� LOSGFOCUS getbox
   //IF !Empty(aWait) ; WaitWindow()
   //ENDIF

   _wSend( 22, oWnd )                                  // ����� � ������
   //�� ����� �
   //_wPost( 22, oWnd )                                // ����� � ������

RETURN .T.

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION Itogo_Dbf(aFld, cAls, aWait)  // ������� �����
   LOCAL nLen := 0, nRec, aItg, aPos, nPos
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

////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION New2Dbf(cDbf,cAls,aRpt)
   LOCAL lUsed, cUsl, cFor, cFor2, aStr := {}, a, i := 0

   //31 {31, "��� ���� �� 02.05.2024 �����������", 3, 262.00, 0d20240502, "21:42:27"}
   //32 {32, "������� �� 03.05.2024 �������", 3, 157.00, 0d20240503, "21:42:27"}
   hb_FileDelete( cDbf )

   FOR EACH a IN aRpt
      i := MAX( LEN(ALLTRIM(a[2])), i )
   NEXT
   i += 5

   AAdd( aStr, { 'F1', 'N',  6, 0 } )
   AAdd( aStr, { 'F2', 'C',  i, 0 } )
   AAdd( aStr, { 'F3', 'N',  6, 0 } )
   AAdd( aStr, { 'F4', 'N', 12, 2 } )
   AAdd( aStr, { 'F5', 'D',  8, 0 } )
   AAdd( aStr, { 'F6', 'C',  8, 0 } )

   DbCreate( cDbf, aStr )

   // ������ �������� ���� ������� ��������������
   USE (cDbf) ALIAS (cAls) NEW CODEPAGE "RU1251"

   FOR EACH a IN aRpt
      (cAls)->( DbAppend() )
      (cAls)->F1 := a[1]
      (cAls)->F2 := a[2]
      (cAls)->F3 := a[3]
      (cAls)->F4 := a[4]
      (cAls)->F5 := a[5]
      (cAls)->F6 := a[6]
   NEXT

   lUsed := Used()
   IF ( lUsed := Used() )
      cUsl  := 'UPPER(F2)'
      cFor  := "!Deleted()"
      cFor2 := "Deleted()"
      //INDEX ON &cUsl TAG DOC FOR &cFor  ADDITIVE
      //INDEX ON &cUsl TAG DEL FOR &cFor2 ADDITIVE
      //INDEX ON &cUsl TAG ALL ADDITIVE
      //SET ORDER TO 3
      GO TOP
   ENDIF

RETURN lUsed

///////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTopMenu( nY, nX, nG, nHIco )
   LOCAL nHeight, nWidth, i, y, x, w, h, nGaps, cObj, aObj, aCEng, nW, nH
   LOCAL aIcon, aBClr, aPost, aCapt, cCap, nWBtn, aFont, nPosWin, nHAlign
   LOCAL aGrad, nHBtn, lIco, aBtnObj, aFntClr, aBlk, nWCap, nWTxt, lVert, lLeft

   ? ProcNL(), nY, nX, nG, nHIco
   nW      := This.ClientWidth
   nH      := This.ClientHeight
   nPosWin := 1         // 1-TopWindow // �� �����: 2-BottomWindow, 3-LeftWindow, 4-RightWindow
   nHAlign := DT_CENTER //DT_LEFT   // �������������� ������: 0-DT_LEFT, 1-DT_CENTER, 2-DT_RIGHT
   aBtnObj := {}
   nHeight := nWTxt := 0
          //     1           2         3         4
   IF App.Cargo:cLang == "RU"
      aCapt := { "�����"  , "������", "������" , "�����"  }
   ELSE
      aCapt := { "Select" , "Print" , "Excel" , "Exit" }
   ENDIF
   aCEng := { "Help"   , "Print" , "Excel"  , "Esc"    }
   aPost := { "_2Enter", "_2Prn" , "_2Excel", "_2Exit" }
   aBClr := { { 94, 59 , 185}    ,;   // 1  �����
              { 33, 140, 194}    ,;   // 2  ������
              { 35, 179,  15}    ,;   // 3  ������
              {128,   0,   0}       } // 4  �����

   lIco  := IIF(nHIco==48,.F.,.T.)  // �������� ������, ���� �����
   aIcon := { {"iEnter48x1" ,"iEnter48x2" , lIco, nHIco} ,;   // 1  ������
              {"iPrint48x1" ,"iPrint48x2" , lIco, nHIco} ,;   // 2  ������
              {"iExcel48x1" ,"iExcel48x2" , lIco, nHIco} ,;   // 3  ������
              {"iExitM48x1" ,"iExitM48x2" , lIco, nHIco} }    // 4  �����

   aFont   := { "Comic Sans MS", 14, .T., 16, "���������� ����� ������" }  // ����� 21.04.24
   aFntClr := {  BLACK, YELLOW }

   FOR i := 1 TO LEN(aCapt)
      cCap  := aCapt[i]
      nWCap := GetTxtWidth(cCap, aFont[4], aFont[1], aFont[3] )
      nWTxt := MAX(nWTxt,nWCap)
   NEXT
   nWBtn := nHIco + nG + nWTxt // ������ ������
   nHBtn := nHIco + 4*2       // ������ ������
   nGaps := nG                // ����� ��������
   y     := nY
   x     := nX
   h     := nHBtn
   w     := nWBtn
   //?? "nWBtn=", nWBtn, "nHBtn=",nHBtn,"nGaps=", nGaps

   aObj  := array(Len(aCapt))
   aBlk  := array(Len(aCapt)) ; aFill(aBlk, .T.   )  // ����������� ������ ��� �������
   aGrad := array(Len(aCapt)) ; aFill(aGrad, WHITE)  //; aGrad[7] := { 0,62, 0 }

   lVert := .F.  // .T.-������������ ����� ��� ������, .F.- �� ������������ �����
   lLeft := .F.  // .T.-����� ����� ��� ������, .F.-������

   // �������������� ������: 0-LEFT, 1-CENTER, 2-RIGHT
   IF nHAlign == DT_LEFT
      FOR i := 1 TO LEN(aCapt)
         cObj := "Btn" + aPost[i]  //StrZero(i, 2)
         cCap := StrTran( aCapt[i], ";" , CRLF )
         my2BUTTON(y, x, w, h, cObj, cCap, {aBClr[i], aGrad[i]}, , aIcon[i], aFntClr, aFont, aPost[i], aBlk[i], .F., lVert, lLeft )
         AADD( aBtnObj, { i, cObj, y, x, w, h, cCap, aBClr[i], aGrad[i], aIcon[i], aPost[i], aBlk[i] } )
         x += This.&(cObj).Width + nGaps
         nWidth := x
      NEXT
   ELSEIF nHAlign == DT_RIGHT
      lLeft := .T.  // .T.-����� ����� ��� ������, .F.-������
      nW    := This.ClientWidth
      x     := nW - nG - nWBtn
      FOR i := LEN(aCapt) TO 1 STEP -1
         cObj := "Btn" + aPost[i]  //StrZero(i, 2)
         cCap := StrTran( aCapt[i], ";" , CRLF )
         my2BUTTON(y, x, w, h, cObj, cCap, {aBClr[i], aGrad[i]}, , aIcon[i], aFntClr, aFont, aPost[i], aBlk[i], .F., lVert, lLeft )
         AADD( aBtnObj, { i, cObj, y, x, w, h, cCap, aBClr[i], aGrad[i], aIcon[i], aPost[i], aBlk[i] } )
         x -= (This.&(cObj).Width + nGaps )
         nWidth := x
      NEXT
   ELSE
      lLeft  := .T.  // .T.-����� ����� ��� ������, .F.-������
      nW     := This.ClientWidth
      nWidth := nWBtn * LEN(aCapt) + nGaps * LEN(aCapt) + 1
      x := ( nW - nWidth ) / 2
      FOR i := 1 TO LEN(aCapt)
         cObj := "Btn" + aPost[i]  //StrZero(i, 2)
         cCap := StrTran( aCapt[i], ";" , CRLF )
         my2BUTTON(y, x, w, h, cObj, cCap, {aBClr[i], aGrad[i]}, , aIcon[i], aFntClr, aFont, aPost[i], aBlk[i], .F., lVert, lLeft )
         AADD( aBtnObj, { i, cObj, y, x, w, h, cCap, aBClr[i], aGrad[i], aIcon[i], aPost[i], aBlk[i] } )
         x += This.&(cObj).Width + nGaps
         nWidth := x
      NEXT
   ENDIF

   nHeight := h + nY * 2

RETURN { nHeight, nWidth }

