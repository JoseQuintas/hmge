/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2023 Verchenko Andrey <verchenkoag@gmail.com>
 *
*/
#define _HMG_OUTLOG

#include "minigui.ch"
#include "metrocolor.ch"

//////////////////////////////////////////////////////////////////////
FUNCTION myTable4Card(oWnd, nKy, cObj, oBrw)
   LOCAL hWin, oWin, nH, nW, nG, nWBtn, nHBtn, cIco, cTitle, aRet
   LOCAL cFont, nFSize, cBFont, nBFSize, nHIco, nCol, nRow, cFrm
   LOCAL aBackColor, aBackClr2, aBtnFC, cTxt, aBtn, bAct, nX, nY
   LOCAL aHide, aForm, cFormCurr, cFormMain, lVsbl, nI, aXFont
   LOCAL cForm, a4Brw
                       
   ? "-->> Start Form_Card", ProcNL(), oWnd:Name, nKy, cObj

   cIco       := "iDbInfo64x1"
   cTitle     := 'Карточка одной записи / Single entry card - MODAL'
   cFont      := App.Cargo:cDefFontName
   nFSize     := App.Cargo:nDefFontSize
   cBFont     := App.Cargo:cBtnFontName     // шрифт для кнопок
   nBFSize    := App.Cargo:nBtnFontSize + 2
   cFormMain  := App.Cargo:cWinMain         // имя окна MAIN формы
   aBtnFC     := BLACK                      // цвет инверт.фонта кнопок
   aBackColor := COLOR_AZURE3               // Цвет фона всей формы
   aBackClr2  := COLOR_DARK_PURPLE          // Цвет фона вверху формы
   nW         := App.Cargo:aDisplayMode[1]  //System.ClientWidth
   nH         := App.Cargo:aDisplayMode[2]  //System.ClientHeight
   nH         -= GetTaskBarHeight()         // высота Панели задач Desktop
   nG         := 10                         // отступ
   nY         := nX := 0
   nX         := nG*6
   cFormCurr  := ThisWindow.Name            // текущая форма
   cForm      := "Form_Card"                // новая форма
   aXFont     := FontCardLoad(cForm)        // загрузить фонты для карточки 
   a4Brw      := CardListField(oBrw)        // получить наименование и поля базы

   // скрыть все окна кроме текущего, пропуская скрытые окна
   aHide := {}
   aForm := HMG_GetForms()
   FOR nI := 1 TO Len(aForm)
      lVsbl := IsWindowVisible( GetFormHandle( aForm[nI] ) )
      IF aForm[nI] == cFormMain     ; LOOP
      ELSEIF aForm[nI] == cFormCurr ; LOOP
      ELSEIF !lVsbl                 ; LOOP
      ENDIF
      DoMethod(aForm[nI], "Hide")
      AADD( aHide, aForm[nI] )
   NEXT

   DEFINE WINDOW &cForm                                                ;
      At nY, nX WIDTH nW-nX HEIGHT nH                                  ;
      TITLE cTitle ICON cIco                                           ;
      MODAL NOSIZE                                                     ;
      BACKCOLOR aBackColor                                             ;
      FONT cFont SIZE nFSize                                           ;
      ON GOTFOCUS {|| App.Cargo:cFormGotFocus := This.Name }           ;
      ON INIT     {|| This.Topmost := .F., DoEvents(), _wPost(0) }     ;
      ON RELEASE  {|| AEval({91,92,93}, {|n| _wSend(n), DoEvents()}) } ; // executed before destroying the window

      This.Cargo := oHmgData()
      This.Cargo:aFont := aXFont        // положить список фонтов для _wSend(91)
      This.Cargo:cForm := cForm         // имя этой формы - в качестве примера
      nW   := This.ClientWidth
      nH   := This.ClientHeight
      oWin := This.Object
      cFrm := oWin:Name
      hWin := oWin:Handle

      @ 0, 0 LABEL Label_Buff WIDTH nW HEIGHT 80 VALUE "" BACKCOLOR aBackClr2

      @ 5, 0 LABEL Label_Title WIDTH nW HEIGHT 70 VALUE cTitle SIZE nFSize + 10 ;
        FONTCOLOR YELLOW BACKCOLOR aBackClr2  CENTERALIGN VCENTERALIGN

      nY += This.Label_Buff.Height + nG
      nX := nG

      mySayCardDatos(This.Cargo, a4Brw, nY, nX, nG)

      /////////////////////// Button ///////////////////////////////////////////
      nWBtn := 220                           // ширина кнопок вверху
      nHBtn := This.Label_Buff.Height - 10   // высота кнопок вверху
      nHIco := nHBtn - 10                    // высота иконки на кнопках вверху
      nRow  := 5
      nCol  := nW - nWBtn*2 - nG*2
      cTxt  := "Save" //+ CRLF + "this recno"
      aBtn  := { "Button_Save", cTxt, "iPiople64x1", "iPiople64x2", nHIco, aBtnFC, YELLOW, cBFont, nBFSize, .T. }
      bAct  := {|| /*MsgDebug(This.Cargo),*/ _wPost(90) }
      myDrawButtonGrad(nRow, nCol, nWBtn, nHBtn, aBtn, bAct, COLOR_GREEN_METRO)

      nCol := nW - nWBtn - nG
      cTxt := "Exit" //+ CRLF + "this card"
      aBtn := { "Button_Exit", cTxt, "iExit64x1", "iExit64x2", nHIco, aBtnFC, YELLOW, cBFont, nBFSize, .T. }
      bAct := {|| /*MsgDebug(This.Cargo),*/ _wPost(98) }
      myDrawButtonGrad(nRow, nCol, nWBtn, nHBtn, aBtn, bAct, COLOR_BRIGHT_RED)

      This.Label_Title.Width := This.Button_Save.Col - 5   // скорректируем ширину титула

      ON KEY ESCAPE OF &cForm ACTION _wPost(98)
      ON KEY F1     OF &cForm ACTION NIL

      WITH OBJECT This.Object
         :Event( 0, {|| InkeyGui(100), This.Label_Buff.Setfocus  } )

         :Event( 2, {|ow| ow:Setfocus('Label_Buff.Setfocus')     } )
         :Event(90, {|ow| // Save
                          LOCAL nPost
                          This.Button_Save.Enabled := .F.
                          aRet := {} //Modal2(cFont, nFSize)
                          IF LEN(aRet) > 0
                             IF AlertYesNo("Вы хотите записать изменения в этой записи ?;" + ;
                                HB_ValToExp(aRet))
                                nPost := 99
                             ELSE
                                nPost := 2
                             ENDIF
                          ELSE
                             nPost := 99
                          ENDIF
                          _wPost(nPost, ow:Name)
                          RETURN NIL
                          } )

         :Event(91, {|ow,ky| // выгружаем/удаляем фонты карточки
                             ? "-->> :Event(91) _ReleaseFont:"
                             FOR EACH ky IN ow:Cargo:aFont
                                ?? ky + " ,"
                                _ReleaseFont(ky)
                             NEXT
                             Return Nil
                             } )
         :Event(92, {|ow| _LogFile(.T., "-->> :Event(92) ON RELEASE WINDOW: "+ow:Name ) } )
         :Event(93, {|ow| _LogFile(.T., "-->> :Event(93) ON RELEASE WINDOW: "+ow:Name ) } )

         :Event(98, {|ow| // Exit this menu
                          This.Button_Exit.Enabled := .F.
                          _LogFile(.T., ">>> :Event(98) Button - Exit")
                          aRet := {}
                          _wPost(99, ow:Name)
                          Return Nil
                          } )
         :Event(99, {|ow| ow:Release()  } )
      END WITH

   END WINDOW

   //CENTER WINDOW &cForm
   ACTIVATE WINDOW &cForm

   ? "-->> End " + cForm

   // восстановить скрытые окна / restore hidden windows
   FOR nI := 1 TO Len(aHide)
      IF _IsWindowDefined(aHide[nI])
         DoMethod(aHide[nI], "Show")
      ENDIF
   NEXT

   SwitchToWin( cFormCurr )     // переключить на тек.форму

   SET WINDOW THIS TO           // restore This среду окна

   ? "-->> Return Form_Card", "aRet=", aRet, HB_ValToExp(aRet)

RETURN aRet

//////////////////////////////////////////////////////////////////////
STATIC FUNCTION FontCardLoad(cForm)
   LOCAL cNam, aFnt, aSiz, aNam, cFnt, nSiz, cFont, nSize, aBld, aItl
   LOCAL nI, hFont, aFont, lBld, lItl

   cFont := App.Cargo:cDefFontName
   nSize := App.Cargo:nDefFontSize

   cNam := "_"+cForm
   aFnt := {"Normal", "Bold" , "Italic", "ComSnMs"      , "SnapITC"  }
   aSiz := { nSize  ,  nSize , nSize   ,  nSize + 2     ,  nSize     }
   aNam := { cFont  ,  cFont , cFont   , "Comic Sans MS", "Snap ITC" }
   aBld := { .F.    ,  .T.   , .F.     , .F.            , .F.        }
   aItl := { .F.    ,  .F.   , .T.     , .F.            , .F.        }

   aFont := {}
   FOR nI := 1 TO LEN(aFnt)
      cFnt := aFnt[nI] + "_" + cForm
      cNam := aNam[nI]
      nSiz := aSiz[nI]
      lBld := aBld[nI]
      lItl := aItl[nI]
      //AADD( aFont, { cFnt, nSize, lBld, lItl } )
      AADD( aFont, cFnt )
      IF lItl
         DEFINE FONT &(cFnt) FONTNAME cNam SIZE nSiz ITALIC
      ELSE
         IF lBld
            DEFINE FONT &(cFnt) FONTNAME cNam SIZE nSiz BOLD
         ELSE
            DEFINE FONT &(cFnt) FONTNAME cNam SIZE nSiz 
         ENDIF
      ENDIF
      // или так
      hFont := GetFontHandle( cFnt )
      //IF hFont == 0
      //   _DefineFont( cFnt, cNam, nSiz, lBld, lItl, .F., .F.,, .F., )
      //ENDIF
   NEXT

   //AEval(aFnt, {|cn,ni| aFnt[ni] := cn+cNam })
   //FOR EACH cFnt, nSiz, cNam IN aFnt, aSiz, aNam
   //   DEFINE FONT &(cFnt) FONTNAME cNam SIZE nSiz
   //NEXT

   //или
   //DEFINE FONT &(aFnt[1]) FONTNAME cFont SIZE nSize
   //DEFINE FONT &(aFnt[2]) FONTNAME cFont SIZE nSize BOLD
   //DEFINE FONT &(aFnt[3]) FONTNAME cFont SIZE nSize ITALIC
   //DEFINE FONT &(aFnt[4]) FONTNAME "Comic Sans MS" SIZE nSize + 2
   //DEFINE FONT &(aFnt[5]) FONTNAME "Snap ITC" SIZE nSize 

RETURN aFont

////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION CardListField(oBrw)   // получить наименование и поля базы
   LOCAL cMsg, a4Dim, oCol, cCol

   IF !hb_IsObject(oBrw)
      cMsg := "ERROR ! oBrw is not an object!;;"
      cMsg += ProcNL() + ";" + ProcNL(1)
      AlertStop(cMsg)
      RETURN {}
   ENDIF

   a4Dim := {}
   FOR EACH oCol IN oBrw:aColumns
      cCol := oCol:cName
      IF cCol == "ORDKEYNO" .OR. cCol == "SELECTOR"
      ELSE
         cMsg := oCol:cHeading
         cMsg := AtRepl( "\r", cMsg, " " )
         AADD( a4Dim, { cMsg, cCol, oCol:cFieldTyp, oCol:cPicture } )
      ENDIF
   NEXT

   ? ProcNL()
   ?v a4Dim

RETURN a4Dim

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION mySayCardDatos(oCargo, a4Brw, nY, nX, nG)
   LOCAL nJ, nI, nW, nGRow, nGCol, aFont, nWLbl, nWTxt, cNgrp
   LOCAL cSay, cN, cN2, cGrp, cDbf, nWGbx, nLine, xVal, hFont, nHeight
   LOCAL cFont1, cFont2, cFont5, cForm, aHeader, aField
                                                                 
   ? "   ====[card]==== " + ProcNL()
   cForm   := oCargo:cForm
   aFont   := oCargo:aFont            // [5] cписок фонтов для карточки
   aHeader := {}
   aField  := {}
   cFont1  := aFont[2]
   cFont2  := aFont[1]
   cFont5  := aFont[5]
   hFont   := GetFontHandle( cFont1 )
   nHeight := GetTextHeight( 0, "A" , hFont )    // высота шрифта
   nGRow   := nG
   nGCol   := nG*2
   nWLbl   := 0
   nLine   := nHeight + 6

   FOR nI := 1 TO LEN(a4Brw)
      AADD( aHeader, a4Brw[nI,1] )
      AADD( aField , a4Brw[nI,2] )
   NEXT

   hFont := GetFontHandle( cFont5 )
   FOR nI := 1 TO LEN(aHeader)
      cSay  := aHeader[nI]
      //cSay  := AtRepl( ";", cSay, " " )
      cSay  := ALLTRIM( cSay )
      nWTxt := GetTextWidth( Nil, cSay, hFont )  // ширина текста
      //nWTxt := GetTxtWidth( cSay, nSize, cFont, lBold )    // получить Width текста
      nWLbl := MAX( nWLbl, nWTxt )
      aHeader[nI] := cSay
   NEXT

   nW    := This.ClientWidth
   nWLbl += nG*2
   nWGbx := nW - nGCol - nWLbl - nGCol

   FOR nJ := 1 TO 5  // пример 

      cNgrp  := 'Lbl_Group_' + StrZero(nJ,2)
      cGrp   := StrZero(nJ,2)
      cSay   := "Group (" + HB_NtoS(nJ) + ") - example of a group header"
      hFont  := GetFontHandle( cFont5 )
      nWTxt  := GetTextWidth( Nil, cSay, hFont ) + nG         // ширина текста

      @ nY, nX LABEL &cNgrp WIDTH nWTxt HEIGHT nLine VALUE cSay ;
        FONT cFont5 FONTCOLOR RED VCENTERALIGN TRANSPARENT
      nY += nLine + nGRow/2

      FOR nI := 1 TO LEN(aHeader)
         cSay := aHeader[nI]
         IF LOWER(cSay) == "not-show"     //  удаляемая колонка
            // пропуск
            LOOP
         ELSE

            cN := 'Lbl_Card_' + cGrp + '_' + StrZero(nI,2)
            @ nY, nX + nG LABEL &cN WIDTH nWLbl HEIGHT nLine VALUE cSay + ":" ;
              FONT cFont1 FONTCOLOR BLUE RIGHTALIGN VCENTERALIGN TRANSPARENT

            cN2    := 'GBox_Card_'  + cGrp + '_' + StrZero(nI,2)
            cDbf   := aField[nI]
            xVal   := FIELDGET( FIELDNUM( cDbf ) )
            @ nY, nX + nWLbl + nGCol/2 GETBOX &cN2 WIDTH nWGbx HEIGHT nLine VALUE xVal PICTURE "@K" FONT cFont2

            IF Valtype(xVal) == "N"
               //SetProperty(This.Name, cN2, "ALIGNMENT", "LEFT")
               This.&(cN2).Alignment := "LEFT"
            ENDIF

            nY += nLine + nGRow/2

         ENDIF
      NEXT

   NEXT

   ? "   ====[end]==== " + ProcNL(), cForm

RETURN NIL
