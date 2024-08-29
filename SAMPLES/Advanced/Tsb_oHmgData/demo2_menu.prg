/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2021 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2021 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ����(������) ��� ������� / Menu (buttons) for the table
*/

#include "hmg.ch"
#include "tsbrowse.ch"
///////////////////////////////////////////////////////////////////////////////////
FUNCTION CreateDataMenu()   // ����-������ ������ ����
   LOCAL oMenu, nKolvo, nWMenu, aCap, cCap, aDim, nWtxt, nWCap, nFSize, cFont
   LOCAL n2Btn, lBold, i, j, nW, nHMenu

   oMenu := oHmgData()
   oMenu:lDebug    := .T.       // �������, ����� ������
   oMenu:nPosWin   := 1         // 1-TopWindow, 2-BottomWindow, 3-LeftWindow, 4-RightWindow
   oMenu:nHAlign   := DT_LEFT   // �������������� ������: 0-LEFT, 1-CENTER, 2-RIGHT
   oMenu:nVAlign   := DT_TOP    // ������������ ������: 0-TOP , 1-CENTER, 2-BOTTOM
   IF App.Cargo:cLang == "RU"
      oMenu:aCaption := { "������", "F7 �����", "Ins-�����;������", "Del-�������;������", "F5 ������", "�����" }
   ELSE
      oMenu:aCaption := { "Help", "F7 Search", "Ins-new;entry", "Del-delete;entry", "F5 Print", "Exit" }
   ENDIF
   oMenu:aCaptMin  := { "Help"  , "F7"      , "Ins"             , "Del"               , "F5"       , "Esc"   }
   oMenu:aBtnPost  := { "_Help" , "_Find"   , "_RecIns"         , "_RecDel"           , "_Print"   , "_Exit" }
   oMenu:aBColor   := { { 40,122,237}    ,;   // 1  ������
                        { 33,140,194}    ,;   // 2  �����
                        {192, 185, 154}  ,;   // 3  ����� ������
                        {192, 185, 154}  ,;   // 4  ������� ������
                        { 94,  59, 185}  ,;   // 5  ������
                        {189, 30, 73}       } // 6  �����
   oMenu:lBtnIco   := .T.       // F-������ ��� ������
   oMenu:aIcon     := { {"iRHelp48x1" ,"iRHelp48x2"  ,.F.,48} ,;   // 1  ������
                        {"iFind48x1"  ,"iFind48x2"   ,.F.,48} ,;   // 2  �����
                        {"iInsert48x1","iInsert48x2" ,.F.,48} ,;   // 3  ����� ������
                        {"iDelete48x1","iDelete48x2" ,.F.,48} ,;   // 4  ������� ������
                        {"iPrint48x1" ,"iPrint48x2"  ,.F.,48} ,;   // 5  ������
                        {"iExit48x1"  ,"iExit48x2"   ,.F.,48} }    // 6  �����
   oMenu:nIcoSize  := 48
   oMenu:lTextVert := .T.  // .T.-������������ ����� ��� ������, .F.- �� ������������ �����
   oMenu:lTextLeft := .T.  // .T.-����� ����� ��� ������, .F.-������
   oMenu:aFont     := { "Comic Sans MS", 13, .T., .F. , 14, "���������� ����� ������" }
   oMenu:aFClr     := { BLACK , YELLOW }
   oMenu:aHelp     := {}
   oMenu:nIndent   := 0                  // ������ ������ ������  - ������
   oMenu:nHBtn     := 64                 // ������ ������
   oMenu:nHBtn     := IIF( App.Cargo:aDisplayMode[2] <= 1024, 64, 72 )
   oMenu:nHBtn     := IIF( App.Cargo:aDisplayMode[2] >= 1100, 96, oMenu:nHBtn )
   oMenu:nWBtn     := 220                // ������ ������
   oMenu:nGaps     := 5                  // ������ ������ �� ���� ����
   oMenu:nGapsBtn  := 10                 // ����� �������� �� ������/������

   // ������ ����� �� ��������
   cFont  := oMenu:aFont[1]
   nFSize := oMenu:aFont[5]
   lBold  := oMenu:aFont[3]
   nWtxt  := 0
   n2Btn  := 0
   aCap   := oMenu:aCaption
   FOR i  := 1 TO LEN(aCap)
      cCap := aCap[ i ]
      IF AT(";",cCap) > 0
         aDim  := HB_ATokens(cCap, ";")
         n2Btn := MAX( n2Btn,LEN(aDim) )
         FOR j := 1 TO LEN(aDim)
            nWCap := GetTxtWidth( aDim[j], nFSize, cFont, lBold )
            nWTxt := MAX(nWTxt,nWCap)
         NEXT
      ELSE
         nWCap := GetTxtWidth(cCap, nFSize, cFont, lBold )
         nWTxt := MAX(nWTxt,nWCap)
      ENDIF
   NEXT
   IF !oMenu:lTextVert      // �� ������������ ����� ��� ������
      oMenu:nWBtn := oMenu:nIcoSize + 5 + nWTxt // ����� ������ ������
   ELSE
      oMenu:nWBtn := nWTxt + 5          // ����� ������ ������
      // ������ ������
      IF n2Btn == 0
         oMenu:nHBtn := 48 + 2*2 + nFSize
      ELSE
         oMenu:nHBtn := 48 + 4*2 + nFSize * n2Btn + nFSize*n2Btn/2
      ENDIF
   ENDIF

   // �������� ������ ���� ������
   nKolvo := LEN(oMenu:aCaption)
   nWMenu := oMenu:nWBtn * nKolvo + oMenu:nGapsBtn * (nKolvo + 1)
   nW     := App.Cargo:aDisplayMode[1] //System.ClientWidth
   IF nWMenu > nW
      oMenu:nWBtn := ( nW - oMenu:nGaps*2 - oMenu:nGapsBtn * nKolvo ) / nKolvo

      nWCap := GetTxtWidth("Help0", nFSize, cFont, lBold )
      oMenu:nWBtn := oMenu:nIcoSize + 5 + nWCap  // ����� ������ ������
      oMenu:aCaption := oMenu:aCaptMin           // ������ ������� ������
   ENDIF

   IF oMenu:nPosWin == 1 .OR. oMenu:nPosWin == 2
      // ��� 1-TopWindow, 2-BottomWindow
      nHMenu         := oMenu:nHBtn + oMenu:nGaps * 2      // ������ ����� ����
      oMenu:nYMenu   := oMenu:nGapsBtn
      oMenu:nXMenu   := oMenu:nGapsBtn
      oMenu:nHMenu   := nHMenu
      oMenu:nWMenu   := oMenu:nGapsBtn         // ������ �� ������ ����� �� X
      oMenu:nHBtnEnd := nHMenu + 600           // ������ ��������� ������ �� �����
   ELSE
      nHMenu := oMenu:nWBtn * nKolvo + oMenu:nGapsBtn * (nKolvo + 1)
      // ���  3-LeftWindow, 4-RightWindow
      //oMenu:nHMenu   := oMenu:nWBtn + oMenu:nGaps * 2      // ������ ����� ����
      oMenu:nYMenu   := oMenu:nGapsBtn
      oMenu:nXMenu   := oMenu:nGapsBtn                       // ������ ����
      oMenu:nWMenu   := oMenu:nWBtn + oMenu:nGapsBtn
      oMenu:nWBtnEnd := oMenu:nWMenu + 800    // ������ ��������� ������ �� �����
      oMenu:nHBtnEnd := nHMenu                // ������ ��������� ������ �� �����
      oMenu:nHMenu   := nHMenu
   ENDIF

RETURN oMenu

////////////////////////////////////////////////////////////////////////////////
FUNCTION DRAW_Menu(oMenu,nWGaps,nHGaps,oThis)   // ���� ������ ��� �������
                             // nWGaps,nHGaps - ������� ������ ���
   LOCAL aPos, lDebug, nPosWin, lShow, cErr, nHAlign, nVAlign
   LOCAL nHMenu, aObj, nD1, nD2, nD3, nD4

   aPos   := { 0, 0, 0, 0 }
   lDebug := .F.
   lShow  := .T.
   cErr   := ""
   nD1    := nD2 := nD3 := 0

   IF hb_IsLogical(oMenu:lDebug)
      lDebug := oMenu:lDebug   // �������, ����� ������
   ENDIF

   IF hb_IsNumeric(oMenu:nPosWin)
      nPosWin := oMenu:nPosWin
   ELSE
      cErr += "Error ! IsNumeric() ! Not - oMenu:nPosWin := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsNumeric(oMenu:nHAlign)
      nHAlign := oMenu:nHAlign
   ELSE
      cErr += "Error ! IsNumeric() ! Not - oMenu:nHAlign := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsNumeric(oMenu:nVAlign)
      nVAlign := oMenu:nVAlign
   ELSE
      cErr += "Error ! IsNumeric() ! Not - oMenu:nVAlign := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsArray(oMenu:aBtnPost)
      nD1 := LEN(oMenu:aBtnPost)
   ELSE
      cErr += "Error ! IsArray() ! Not - oMenu:aBtnPost := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsArray(oMenu:aCaption)
      nD2 := LEN(oMenu:aCaption)
   ELSE
      cErr += "Error ! IsArray() ! Not - oMenu:aCaption := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsArray(oMenu:aBColor)
      nD3 := LEN(oMenu:aBColor)
   ELSE
      cErr += "Error ! IsArray() ! Not - oMenu:aBColor := ??? ;"
      lShow := .F.
   ENDIF

   IF nD1 # nD2 .OR. nD1 # nD3
      cErr += "Error ! Arrays are not equal ! ;;"
      cErr += "        Len(oMenu:aBtnPost) = " + HB_NtoS(nD1) + ";"
      cErr += "        Len(oMenu:aCaption) = " + HB_NtoS(nD2) + ";"
      cErr += "        Len(oMenu:aBColor)  = " + HB_NtoS(nD3) + ";"
      lShow := .F.
   ENDIF

   IF hb_IsLogical(oMenu:lBtnIco)
      IF oMenu:lBtnIco
         IF hb_IsArray(oMenu:aIcon)
            nD4 := LEN(oMenu:aIcon)
            IF nD1 # nD4
               cErr  += "Error ! Len(oMenu:aIcon)  = " + HB_NtoS(nD4) + ";"
               lShow := .F.
            ENDIF
         ELSE
            cErr  += "Error ! IsArray() ! Not - oMenu:aIcon := ??? ;"
            lShow := .F.
         ENDIF
      ENDIF
   ENDIF

   // ����� ���� ��� ������
   IF lShow
      nHMenu  := IIF( hb_IsNumeric(oMenu:nHMenu), oMenu:nHMenu, 45)  // ������ ����� ����
      nPosWin := IIF( nPosWin == 0, 1, nPosWin )
      nPosWin := IIF( nPosWin > 4 , 1, nPosWin )
      nPosWin := IIF( nPosWin < 1 , 1, nPosWin )
      IF nPosWin == 1          // TopWindow
         aPos[1] := nHMenu - nHGaps
         aPos[4] := -nHMenu + nHGaps
      ELSEIF nPosWin == 2      // BottomWindow
         aPos[4] := -nHMenu + nHGaps
      ELSEIF nPosWin == 3      // LeftWindow
         aPos[2] := nHMenu - nWGaps
         aPos[3] := -nHMenu + nWGaps
      ELSEIF nPosWin == 4      // RightWindow
         aPos[3] := -nHMenu + nWGaps
      ENDIF

      aObj := Show_Button(oMenu,nWGaps,nHGaps,nPosWin,oThis)
      oThis:Cargo:aObjBtn := aObj

   ELSE
      IF lDebug
         cErr += ";;" + ProcNL()
         AlertStop(cErr, "Error !")
         ? ATREPL( ";", cErr, CRLF )
      ENDIF
   ENDIF

RETURN aObj

////////////////////////////////////////////////////////////////////////
FUNCTION Show_Button(oMenu,nX,nY,nPosWin,oThis)
   LOCAL cForm, nW, nH, aBtnCap, aBtnIco, aBtnClr, aBtnPst, cCapt
   LOCAL cN, cFont, nFSize, lFBold, nJ, aBtnGrd, aGrOver, aGrFill
   LOCAL aFntClr, nwPost, aBtnObj, aFont, aColor, lItalic, nF2Size
   LOCAL lBtnIco, nGBtn, nWBtn, nHBtn, nIndent, nIcoSize, nOnePos
   LOCAL nHAlign, nVAlign, nY2, nX2, nLenBtn, nWBthAll, nHBthAll
   LOCAL lTextVert, lTextLeft, aIco, nWBtnF7, hIco1, hIco2
   LOCAL owc := oThis:Cargo

   aBtnObj := {}
   cForm   := oThis:Name  //ThisWindow.Name
   nW      := This.ClientWidth
   nH      := This.ClientHeight
   nY2     := nY
   nX2     := nX
   // ������
   // �������������� ������: 0-LEFT, 1-CENTER, 2-RIGHT
   nHAlign  := IIF( hb_IsNumeric(oMenu:nHAlign), oMenu:nHAlign, DT_LEFT )
   // ������������ ������: 0-TOP , 1-CENTER, 2-BOTTOM
   nVAlign  := IIF( hb_IsNumeric(oMenu:nVAlign), oMenu:nVAlign, DT_TOP )
   // ������ ������ ������ - ������
   nIndent  := IIF( hb_IsNumeric(oMenu:nIndent), oMenu:nIndent, 0 )
   nWBtn    := oMenu:nWBtn         // ������ ������
   nHBtn    := oMenu:nHBtn         // ������ ������
   nOnePos  := oMenu:nGaps         // ������ ������ �� ���� ����
   nGBtn    := oMenu:nGapsBtn      // ����� �������� �� ������/������
   // ������� ��� DT_CENTER
   aBtnCap  := oMenu:aCaption
   nLenBtn  := LEN(aBtnCap)
   nWBthAll := ( nW - nWBtn * nLenBtn - nGBtn * ( nLenBtn - 1 ) ) / 2
   nHBthAll := ( nH - nHBtn * nLenBtn - nGBtn * ( nLenBtn - 1 ) ) / 2

   IF nPosWin = 1                  // TopWindow
      nY := nOnePos
      IF nHAlign == DT_LEFT        // �������������� ������
      ELSEIF nHAlign == DT_CENTER
         nX := nWBthAll
      ELSEIF nHAlign == DT_RIGHT
         nX := nW - nX2 - nWBtn
      ENDIF
   ELSEIF nPosWin = 2              // BottomWindow
      nY := nH - nHBtn - nOnePos
      IF nHAlign == DT_LEFT        // �������������� ������
      ELSEIF nHAlign == DT_CENTER
         nX := nWBthAll
      ELSEIF nHAlign == DT_RIGHT
         nX := nW - nX2 - nWBtn
      ENDIF
   ELSEIF nPosWin == 3             // LeftWindow
      nX := nOnePos
      IF nVAlign == DT_TOP         // ������������ ������
      ELSEIF nVAlign == DT_CENTER
         nY := nHBthAll
      ELSEIF nVAlign == DT_BOTTOM
         nY := nH - nY2 - nHBtn
      ENDIF
   ELSEIF nPosWin == 4             // RightWindow
      nX := nW - nWBtn - nOnePos
      IF nVAlign == DT_TOP         // ������������ ������
      ELSEIF nVAlign == DT_CENTER
         nY := nHBthAll
      ELSEIF nVAlign == DT_BOTTOM
         nY := nH - nY2 - nHBtn
      ENDIF
   ENDIF

   IF hb_IsLogical(oMenu:lBtnIco)
      lBtnIco := oMenu:lBtnIco
   ELSE
      lBtnIco := .F.       // F-������ ��� ������
   ENDIF
   nIcoSize  := oMenu:nIcoSize
   aIco      := IIF( hb_IsArray(oMenu:aIcon), oMenu:aIcon, {} )
   aBtnCap   := oMenu:aCaption
   aBtnIco   := oMenu:aIcon
   aBtnClr   := oMenu:aBColor
   aBtnPst   := oMenu:aBtnPost
   // �����  ��� ������
   aFntClr   := oMenu:aFClr  //{ BLACK , OLIVE }
   aFont     := oMenu:aFont
   cFont     := aFont[1]     //"Comic Sans MS"
   nFSize    := aFont[2]     //16
   lFBold    := aFont[3]     //.T.
   lItalic   := aFont[4]     //.T.
   nF2Size   := aFont[5]     //32
   // ����� ��� ������
   lTextVert := IIF( hb_IsLogical(oMenu:lTextVert), oMenu:lTextVert, .F. )
   lTextLeft := IIF( hb_IsLogical(oMenu:lTextLeft), oMenu:lTextLeft, .F. )
   ? ProcNL(), "###### ����� ��� ������ ######", "lTextVert=",lTextVert, "lTextLeft=", lTextLeft
   FOR nJ := 1 TO LEN(aBtnCap)
      cCapt   := StrTran( aBtnCap[nJ], ";" , CRLF )
      aColor  := aBtnClr[nJ]
      aBtnGrd := { HMG_RGB2n( aColor ), CLR_WHITE }  // �������� ������
      aGrOver := { { 0.5, aBtnGrd[2], aBtnGrd[1] }, { 0.5, aBtnGrd[1], aBtnGrd[2] } }
      aGrFill := { { 0.5, aBtnGrd[1], aBtnGrd[2] }, { 0.5, aBtnGrd[2], aBtnGrd[1] } }
      nwPost  := aBtnPst[nJ]
      IF IsNumeric(nwPost)
         cN := 'Btn' + HB_NtoS(nwPost) //StrZero(nJ, 2)
      ELSEIF IsString(nwPost)
         cN := 'Btn' + nwPost //StrZero(nJ, 2)
      ELSE
         AlertStop('Error ! Btn_XX - ������� �� "N" ��� "C' + cValToChar(nwPost) )
      ENDIF
      AADD( aBtnObj, { cN, aBtnCap[nJ], nY, nX, nWBtn, nHBtn, aColor, nwPost, IIF( lBtnIco, aIco[1], Nil ) } )

      IF lBtnIco .AND. LEN(aIco) > 0  // ������ � ��������
         aIco  := aBtnIco[nJ]
         hIco1 := LoadIconByName( aIco[1], nIcoSize, nIcoSize )
         hIco2 := LoadIconByName( aIco[2], nIcoSize, nIcoSize )
      ENDIF

      // alt_syntax
      DEFINE BUTTONEX &cN
         ROW           nY
         COL           nX
         WIDTH         nWBtn
         HEIGHT        nHBtn
         CAPTION       cCapt
         ICON          IIF( lBtnIco, hIco1, Nil )
         FONTNAME      cFont
         FONTSIZE      nFSize
         FONTCOLOR     aFntClr[1]
         FONTBOLD      .F.
         BACKCOLOR     aGrOver
         GRADIENTFILL  aGrFill
         LEFTTEXT      lTextLeft
         VERTICAL      lTextVert
         FLAT          .T.
         NOHOTLIGHT    .F.
         NOXPSTYLE     .T.
         HANDCURSOR    .T.
         NOTABSTOP     .T.
         ONMOUSEHOVER ( myMouseHL(2) )
         ONMOUSELEAVE ( myMouseHL(1) )
         ACTION ( This.Enabled := .F., _wPost(This.Cargo:nPost, ThisWindow.Name, This.Name) )
         //ACTION ( This.Enabled := .F., _wPost(This.Cargo:nPost, This.Index) )
         /*ONINIT {|o|   // ����� � ��� ������
                    This.Cargo := oHmgData()  // ������� ������ (���������) ��� ���� ������
                    o := This.Cargo
                    // ������� �� ������ ������ ������
                    o:nBtn     := nJ
                    o:nPost    := nwPost
                    o:cCapt    := cCapt
                    o:aIco     := aIco
                    o:aBClr    := aColor
                    o:cObj     := cN
                    o:aGrFill  := aGrFill
                    o:aGrOver  := aGrOver
                    o:aFntClr1 := aFntClr[1]
                    o:aFntClr2 := aFntClr[2]
                    o:lBold2   := .T.
                    o:lBold1   := .F.
                    o:nFSize2  := nF2Size        // ����������� ���� ������
                    o:nFSize   := nFSize         // ���� ������
                    o:nIcoSize := nIcoSize       // ������ ������
                    o:aIco     := aIco           // 2 ������ ������
                    o:ahIco    := {hIco1,hIco2}  // 2 ������ ������ ������
                    o:lBtnIco  := lBtnIco        // ����/��� ������ �� ������
                    Return Nil
                   }          // ON INIT ���� �������� ������ ������ ���� */
      END BUTTONEX

      IF AT("F7",cCapt) > 0
         nWBtnF7 := nX
      ENDIF

      This.&(cN).Cargo := oHmgData()
      WITH OBJECT This.&(cN).Cargo
         :nBtn     := nJ
         :nPost    := nwPost
         :cCapt    := cCapt
         :aBClr    := aColor
         :cObj     := cN
         :aGrFill  := aGrFill
         :aGrOver  := aGrOver
         :aFntClr1 := aFntClr[1]
         :aFntClr2 := aFntClr[2]
         :lBold2   := .T.
         :lBold1   := .F.
         :nFSize2  := nF2Size        // ����������� ���� ������
         :nFSize   := nFSize         // ���� ������
         :nIcoSize := nIcoSize       // ������ ������
         :aIco     := aIco           // 2 ������ ������
         :ahIco    := {hIco1,hIco2}  // 2 ������ ������ ������
         :lBtnIco  := lBtnIco        // ����/��� ������ �� ������
      END WITH

      // ����� ������
      IF nPosWin = 1 .OR. nPosWin = 2   // TopWindow-BottomWindow
         // �������������� ������
         IF nHAlign == DT_LEFT .OR. nHAlign == DT_CENTER
            nX += nWBtn + nGBtn
         ELSE
            nX -= ( nWBtn + nGBtn )
         ENDIF
      ELSE                             // LeftWindow-RightWindow
         // ������������ ������
         IF nVAlign == DT_TOP .OR. nVAlign == DT_CENTER
            nY += nHBtn + nGBtn
         ELSE
            nY -= ( nHBtn + nGBtn )
         ENDIF
      ENDIF

      IF lBtnIco .AND. LEN(aIco) > 0  // ������ � ��������
         // ��� ������ ���������� �������� ������� ������
         This.&(cN).ImageWidth  := nIcoSize
         This.&(cN).ImageHeight := nIcoSize
         This.&(cN).Icon        := hIco1
         // ��� �������� ������� ������ � �����
         AADD( owc:ahIcoDel , hIco1 )
         AADD( owc:ahIcoDel , hIco2 )
      ENDIF

   NEXT

   oMenu:nWBtnEnd := nX           // ��������� ������ �� �����
   oMenu:nWBtnF7  := nWBtnF7      // ������ ������ F7

RETURN aBtnObj

///////////////////////////////////////////////////////////////////
FUNCTION myMouseHL(n)
   LOCAL o := This.Cargo

   //? "    *** " + ProcNL(), "n=", n
   IF n == 2
      This.FontColor    := o:aFntClr2
      This.FontSize     := o:nFSize2
      This.FontBold     := o:lBold2
      This.GradientFill := o:aGrFill
   ELSE
      This.FontColor    := o:aFntClr1
      This.FontSize     := o:nFSize
      This.FontBold     := o:lBold1
      This.GradientOver := o:aGrOver
   ENDIF

   //?? o:lBtnIco
   IF o:lBtnIco      // ������ � ��������
      This.Icon := o:ahIco[n]
      //?? o:ahIco[n]
   ENDIF

RETURN NIL

//////////////////////////////////////////////////////////////////////////////////
FUNCTION Draw_Icon(owc)  // ������ �� �����
   LOCAL nI, nX, nY, hIcon, cForm, nHIco, cMsg := ""
   LOCAL aIcon := { "iMg1x64", "iMg2x64", "iMg3x64" }

   owc:aIcoLogo    := aIcon  // �������� ��� ��������� ������
   owc:ahIcoLogo   := { 0, 0, 0 }
   owc:aIcoLogoYX  := { 0, 0, 0 }
   owc:nYGaps      := 0           // ������ �� ������ ����� �� Y
   owc:nXGaps      := owc:nXGIco  // ������ �� ������ ����� �� X -> owc:nXGIco = ��. ������� �����
   cForm           := owc:cForm
   nHIco           := owc:nHIco
   nX              := owc:nXGaps
   nY              := owc:nYGaps

   FOR nI := 1 TO LEN(aIcon)

      hIcon := LoadIconByName( aIcon[nI], nHIco, nHIco )

      IF hIcon == 0
         cMsg += "Error ! No icon " + aIcon[nI]
         cMsg += " in program resources !;"
      ELSE
         DRAW ICON IN WINDOW &cForm AT nY, nX HICON hIcon ;
               WIDTH nHIco HEIGHT nHIco COLOR This.BackColor
      ENDIF

      owc:ahIcoLogo[nI]  := hIcon
      owc:aIcoLogoYX[nI] := { owc:nYGaps, nX }

      AADD( owc:ahIcoDel, hIcon )         // ��� �������� ������� ������ � �����

      nX += nHIco

   NEXT

   owc:nWIcoEnd := owc:nXGaps + nHIco*3  // ��������� ���������� ������

   IF LEN(cMsg) > 0
      AlertStop(cMsg)
   ENDIF

RETURN NIL

/*---------------------------------------------------------------------------
 * MINIGUI - Harbour Win32 GUI library
*/
*----------------------------------------------------------------------------*
STATIC FUNCTION GetTxtWidth( cText, nFontSize, cFontName, lBold )  // �������� Width ������
*----------------------------------------------------------------------------*
   LOCAL hFont, nWidth
   DEFAULT cText     := REPL('A', 2)        ,  ;
           cFontName := _HMG_DefaultFontName,  ;   // �� MiniGUI.Init()
           nFontSize := _HMG_DefaultFontSize,  ;   // �� MiniGUI.Init()
           lBold     := .F.

   IF Valtype(cText) == 'N'
      cText := repl('A', cText)
   ENDIF

   hFont  := InitFont(cFontName, nFontSize, lBold)
   nWidth := GetTextWidth(0, cText, hFont)         // ������ ������
   DeleteObject (hFont)

RETURN nWidth

