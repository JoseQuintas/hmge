/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ������������ ������� � Tsbrowse ��� dbf �����
 * ���� � �������. �������� �� � ����� �����.
 * ����� �� �������� �����, �������������� �������� ��� ��������� ������ � �������
 * ��� ���� �������������� ����-���� � ��������� ������� � CRLF
 * ��������� ����� ����� (������/�����) �� �����������/�����/�������/������ �������
 * ������ �� SCOPE.
 * ����������/�������������� �������� ���� � ���-����.
 * ������ � ������� ������: �����������/������� ����� ������� ������� �������
 * Testing columns in Tsbrowse for a dbf file
 * Entering into a table. Check before and after input.
 * Totals for numeric fields, automatic recalculation when data in a column changes
 * Your own window for editing memo fields and text columns with CRLF 
 * Working out a mouse click (right/left) on a superheader/header/footer/table cell
 * Working with SCOPE.
 * Saving/restoring window sizes to an ini file.
 * Working with the clipboard: copying/pasting table cells of different formats
*/
#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"

REQUEST HB_CODEPAGE_UTF8, HB_CODEPAGE_RU866, HB_CODEPAGE_RU1251
REQUEST DBFNTX, DBFCDX, DBFFPT

#define PROGRAM  "Testing columns in Tsbrowse for a dbf file (2)"
#define PROGVER  "Version 0.1 (02.03.2024)"
#define LANG_PRG "RU"  // "EN" English interface-lang

FUNCTION Main()
   LOCAL oBrw, oTsb, nY, nX, nH, nW, nG, o, owc, oWin, oMenu
   LOCAL cTitle, cForm := "wMain", cBrw  := "oBrw"
   LOCAL aDim, aList1, aList2, aClmn, cAls := "PLT24"

   SET WINDOW MAIN OFF

   IF App.Cargo:cLang == "RU"
      aDim := { "������ ��������� ....", App.ExeName }
   ELSE
      aDim := { "Running the program ....", App.ExeName }
   ENDIF
   WaitWindow( aDim, .T. , 600, 16, NIL, BLUE, App.Cargo:aBClrMain )

   IF !UseBase(cAls) ;  QUIT                      // -> demos_use.prg
   ENDIF
   // ������ ������� �� ���� �� ���������� �������
   // ��� ��������� ������� ���������� � ����
   aList1 := DbfSelection(1, cAls)                // -> demos_use.prg
   aList2 := DbfSelection(2, cAls)                // -> demos_use.prg
   //? "aList1=",aList1 ; ?v aList1
   //? "aList2=",aList2 ; ?v aList2
   DbSelectArea(cAls)
   // ��� �������� TBrowse ���� ������� ���������� ��� �������
   // TBrowse ��� ����������, ���� �� ������������ �������� ����� � ��������
   OrdSetFocus("DOCDTV")   // ������ ����� ����� !!!
   DbGotop()

   WaitWindow()

   //SET WINDOW MAIN ON
   oWin   := CreateDataWin()     // ��������� ����
   cTitle := App.Cargo:cTitle + SPACE(5) + App.Cargo:cVersion + SPACE(5) + App.Cargo:cDisplayMode
   Windows2Coordinat(oWin)       // ������� ��������� �� ���-����� �� ���������� ����

   DEFINE WINDOW &cForm AT oWin:nY, oWin:nX WIDTH oWin:nW HEIGHT oWin:nH ;
      MINWIDTH 500 MINHEIGHT 500                                         ; // ���������� ���������� �������� ����
      TITLE cTitle                                                       ;
      MAIN TOPMOST                                                       ;
      ON MAXIMIZE ( ResizeForm( oBrw ) )                                 ;
      ON SIZE     ( ResizeForm( oBrw ) )                                 ;
      BACKCOLOR oWin:aBClr                                               ;
      ON INIT    _wPost( 0)                                              ;
      ON RELEASE _wSend(90)

      nY := nX := nG := 0
      nW := This.ClientWidth
      nH := This.ClientHeight

      This.Cargo := oHmgData() ; owc := This.Cargo  // ��� ���� ������� ������ ��� ���������� (������� ������)
      owc:oWinMain := This.Object      // ������ ����, ������ ��� �������
      owc:cWinMain := This.Name        // ��� ����, ������ ��� �������
      owc:aBColor  := This.BackColor   // ���� ����
      owc:cForm    := cForm
      owc:aList1   := aList1           // ������ ���.����� �� ���� ����
      owc:aList2   := aList2           // ������ ���. �� ������� ���� + ������ ���� ���������
      owc:aFldSum  := {}               // ������ ����� dbf ��� ������� �����
      owc:nCount   := 0                // ����� � ������� �������
      owc:aItogo   := {0}              // ����� � ������� �������
      owc:cAls     := cAls

      nG := 10                         // ������ ����� � ����� �������� �� ������/������
      /////////////////////// ������ ������ ����� ///////////////////////////////////
      oMenu          := CreateDataMenu()    // ��������� ������ �������� ���� -> demo2_menu.prg
      //_o2log(o:oMenu, 27, ProcNL() + "  o:oMenu => ", .T. ) ; ?
      owc:aBtnObj    := DRAW_Menu( oMenu, nG, oMenu:nYMenu, This.Object)  // ����� ������ ������ �� �����
      owc:nWBtnEnd   := oMenu:nWBtnEnd   // ������ ��������� ������ �� �����
      owc:nHBtnEnd   := oMenu:nHBtnEnd   // ������ ��������� ������ �� ����� ��� ������������ �������
      This.MinWidth  := owc:nWBtnEnd + GetBorderWidth()*2   // ���������� ���������� �������� ���� !!!
      This.MinHeight := owc:nHBtnEnd + GetBorderHeight()*2  // ���������� ���������� �������� ���� !!!
      owc:nHMenu     := oMenu:nHMenu
      owc:nHIco      := oMenu:nHMenu                // ������� ������ ������ �����
      owc:nColF7     := oMenu:nWBtnF7               // ������ ������ F7

      /////////////////////// ����������� - ShowBalloonTip /////////////////////////
      @ nY, owc:nColF7 + 20 EDITBOX myBallon OF &cForm VALUE "" WIDTH 10 HEIGHT 10 ;
        FONTCOLOR oWin:aBClr BACKCOLOR oWin:aBClr
      owc:hBallon  := This.myBallon.Handle
      owc:cMsg     := oWin:cMsg
      owc:cMsgTitl := IIF( App.Cargo:cLang == "RU" ,;
                           "�������� ! ����� ����� !", "ATTENTION! VERY IMPORTANT!" )

      owc:nXGIco    := owc:nWBtnEnd                 // ������ ��� ������ �� ������ ����� �� X
      Draw_Icon(owc)                                // ������ �� ����� -> demo2_menu.prg
      oMenu:nXGaps  := owc:nWIcoEnd + owc:nXGaps    // ������ ������ �� ���� ���� �� X
      owc:aLblYX    := owc:aIcoLogoYX[2]            // ���������� ������ ������
      ? ProcNL(), "### Draw_Icon()  nHIcon=", owc:nHIco, HB_ValToExp(owc:aIcoLogoYX)

      oTsb := oHmgData()                           // �������� ��������� ��� �������
      oTsb:aNumber := {1, 80}
      oTsb:cForm   := cForm
      oTsb:nY      := oMenu:nHMenu                 // ������ ���� = ������ �������
      oTsb:nG      := oMenu:nGapsBtn               // ������ ����� ��������
      oTsb:nX      := oMenu:nWMenu                 // ������ �� ������ ����� �� X
      oTsb:nW      := nW - oTsb:nX * 2             // ������ �������
      oTsb:nH      := nH - oTsb:nY - oTsb:nG * 2   // ������ �������
      owc:nTsbY    := oTsb:nY
      owc:nTsbX    := oTsb:nX
      owc:nG       := nG                           // ����� ��������� �� ������/������

      //oBrw := _TBrowse( oTsb, cAls, cBrw, nY, nX, nW, nH )
      //////////// ���������� ������� / building a TABLE /////////////////////////
      aClmn      := Column_TSB( oTsb, cAls )              // ������ ������� �������  -> Column_TSB.prg
      owc:aClmn  := aClmn                                 // �������� �� ���� ������ �������
      oBrw       := Draw_TSB( oTsb, This.Object, cBrw )   // ������� -> demo2_tsb.prg
      //_o2log(o:oBrw, 27, ProcNL() + "  o:oBrw => ", .T. ) ; ?

      oBrw:Cargo:aFldSum := owc:aFldSum           // ������ ����� dbf ��� ������� ����� -> ������� � Column_TSB.prg
      oBrw:Cargo:oWnd    := This.Cargo            // Cargo ���� ��������� �� �������
      App.Cargo:oBrw     := oBrw                  // ��������� ��� ������� �������
      This.Cargo:oBrw    := oBrw                  // ��������� �� ���� ���� ������

      ON KEY F1     ACTION _wPost(60,cForm)
      ON KEY ESCAPE ACTION ( iif( oBrw:IsEdit, oBrw:SetFocus(), _wPost(99) ) )

      o := This.Object
     //oMenu:aBtnPost  := { "_Help", "_Find", "_RecIns", "_RecDel", "_Print", "_Exit" }  -> demo2_menu.prg
      o:Event( 1, {|ow| This.Topmost := .F., _wPost(1, ow) })  // ������ ������� 1
      o:Event( 0, {|ow,ky| // ������� ��������� �� ���-�����
                           Local oBrw, o := App.Cargo
                           Local aWin := o:oIni:MAIN:aWindow
                           Local cMsk := o:oIni:MAIN:cMaska
                           ow:Cargo:cMaska   := cMsk
                           oBrw := App.Cargo:oBrw
                           oBrw:Cargo:cMaska := cMsk                 // ��������� ����� � oBrw
                           ? ProcNL(), "aWin=", HB_ValToExp(aWin)
                           ?? "---[ "+ow:Name+":Event("+hb_ntos(ky)+") ]---"
                           // WindowsCoordinat(ow)  - �� ���� ��� ������ !!!  // ������������ ���������� ����
                           This.Topmost := .F.
                           SendMessage( ow:Handle, WM_PAINT, 0, 0 )  // ����� ������ �����
                           DO EVENTS
                           This.myBallon.Setfocus
                           This.myBallon.Hide
                           ShowBalloonTip( ow:Cargo:hBallon, ow:Cargo:cMsg, owc:cMsgTitl, TTI_WARNING_LARGE )
                           InkeyGui( 20 * 1000 )
                           HideBalloonTip( ow:Cargo:hBallon )
                           DO EVENTS
                           _wSend(2,ow)  // ����� �� ����
                           ow:Cargo:oBrw:SetFocus()
                           // _wSend(5,,ow)  // ������ ������ ����
                           DO EVENTS
                           Return Nil
                           })

      o:Event({2, "_ItogGet"}, {|ow| // ����� �� ���� -> demos_use.prg
                                     Local ob := ow:Cargo:oBrw, oCol, cFld
                                     Local aFldSum := ow:Cargo:aFldSum
                                     Local aItog := Itogo_Dbf(aFldSum, ow:Cargo:cAls)
                                     ow:Cargo:nCount := aItog[1]
                                     ow:Cargo:aItogo := aItog[2]
                                     // ��������� � �������
                                     FOR EACH cFld IN aFldSum
                                         oCol := oBrw:GetColumn(cFld)
                                         IF oCol:Cargo:lTotal
                                            oCol:Cargo:nTotal := aItog[2][ hb_enumindex(cFld) ]
                                         ENDIF
                                     NEXT
                                     ? REPL("#",10) + " _ItogGet", ProcNL()
                                     ?? "INDEXORD()=",INDEXORD(), ORDSETFOCUS()
                                     _wPost("_ItogSay", ob:cParentWnd)
                                     Return Nil
                                     } )

      o:Event({3, "_ItogSay"}, {|ow| // ����� �� ����
                                     ow:Cargo:oBrw:DrawFooters()
                                     Return Nil
                                     } )

      o:Event( 5, {|ow,ky,cn,ob| ob := ow:Cargo:oBrw, _SetThisFormInfo(ow), ;
                                _LogFile(.T., ProcNL(), "=======> ky/cn", ky, cn ) ,;
                                ky := 10,  cn := "Btn__Find" ,;
                                Menu_Find(ow,ky,cn,ob) ,; // -> demo2_menu_Fxx.prg
                                _SetThisFormInfo(), This.&(cn).Enabled := .T., ob:Setfocus() } )

      o:Event({ 6,"_Help"  }, {|ow,ky,cn| _SetThisFormInfo(ow), MsgAbout(,,ky), _SetThisFormInfo(),;
                                          This.&(cn).Enabled := .T., ow:Cargo:oBrw:SetFocus()        } )

      o:Event({10,"_Find"  }, {|ow,ky,cn,ob| ob := ow:Cargo:oBrw, _SetThisFormInfo(ow), ;
                                             Menu_Find(ow,ky,cn,ob) ,; // -> demo2_menu_Fxx.prg
                                             _SetThisFormInfo(), This.&(cn).Enabled := .T., ob:Setfocus() } )
      o:Event({11,"_RecIns"}, {|ow,ky,cn,ob| ob := ow:Cargo:oBrw   , RecnoInsert_TSB(ow,ky,cn,ob),;
                                             IIF( ob:Cargo:lRecINS , nil, This.&(cn).Enabled := .T.) ,; // ���������� ������� INS
                                             ob:Setfocus()  } )                             // VK_INSERT
      o:Event({12,"_RecDel"}, {|ow,ky,cn,ob| ob := This.oBrw.Object, RecnoDelete_TSB(ow,ky,cn,ob),;
                                             IIF( ob:Cargo:lRecDEL , nil, This.&(cn).Enabled := .T.) ,; // ���������� ������� DEL
                                             ob:Setfocus()  } )                             // VK_DELETE
      o:Event({70,"_Print" }, {|ow,ky,cn,ob| ob := ow:Cargo:oBrw, Menu_Print(ow,ky,cn,ob),; // -> demo2_menu_Fxx.prg
                                             This.&(cn).Enabled := .T., ob:Setfocus()                         } )
      o:Event({89,"_Exit"  }, {|ow| _LogFile(.T., ProcNL(),">>> Exit button pressed! Window: "+ow:Name), _wSend(99) } )
      o:Event(90, {|ow,ky|  // Release
                        Local cMsg, aWin, oIni, i
                        ow:Hide()
                        DO EVENTS
                        IF IsArray(ow:Cargo:ahIcoLogo)
                           FOR i := 1 TO LEN(ow:Cargo:ahIcoLogo)
                              DestroyIcon(ow:Cargo:ahIcoLogo[i])
                           NEXT
                        ENDIF
                        ?  ( cMsg := ProcNL() )
                        ?? "---[ "+ow:Name+":Event("+hb_ntos(ky)+") ]---"
                        ?  Repl(".", Len(cMsg)), "=> RELEASE WINDOW <=", ow:Name
                        ?? "... Program running time -", HMG_TimeMS( App.Cargo:tStart )
                        // ��������� ������� ����
                        aWin := { ow:Row, ow:Col, ow:Width, ow:Height }
                        App.Cargo:oIni:MAIN:aWindow := aWin
                        // ��������� ��������� ����� ����� - �� �����
                        // ��� ���������� ���� ���������� ����� ����� � ���� ���
                        // App.Cargo:oIni:MAIN:cMaska := "????"
                        oIni := App.Cargo:oIni
                        Save_Ini2File( oIni )
                        Return Nil
                        })
      o:Event(99, {|ow| ow:Release()        })

   END WINDOW

     //CENTER WINDOW &cForm
   ACTIVATE WINDOW &cForm

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
INIT PROCEDURE Sets_ENV()
   LOCAL o, cIni  := hb_FNameExtSet( App.ExeName, ".ini" )

   SET CODEPAGE TO RUSSIAN
   SET LANGUAGE TO RUSSIAN

   rddSetDefault( "DBFCDX" )

   SET DECIMALS  TO 4
   SET EPOCH     TO 2000
   SET DATE      TO GERMAN
   SET CENTURY   ON
   SET DELETED   OFF
   SET AUTOPEN   OFF
   SET EXACT     ON
   SET EXCLUSIVE ON
   SET SOFTSEEK  ON
   SET OOP ON
   SET DATE FORMAT TO "DD.MM.YY"
   SET TOOLTIPSTYLE BALLOON

   SET WINDOW MAIN OFF

   IF !HB_ISOBJECT( App.Cargo ) ; App.Cargo := oHmgData()
   ENDIF
   o := App.Cargo

   o:tStart         := hb_DateTime()   // start time
   o:cFontName      := "DejaVu Sans Mono" //"Arial"
   o:cFontName2     := "Comic Sans MS"
   o:nFontSize      := 13
   o:cLogFile       := "_msg2.log"
   o:cIniFile       := cIni
   o:lLogDel        := .T.
   o:cDlgFont       := "DejaVu Sans Mono"
   o:nDlgSize       := o:nFontSize + 2
   o:aDlgBColor     := { 141, 179, 226 }     // Alert* BackColor
   o:aDlgFColor     := {  0 ,  0 ,  0  }     // Alert* FontColor
   o:aBClrMain      := {127,189,228}
   o:cDefAppIcon    := "1MG"
   o:lDebug         := .T.
   o:nMenuBmpHeight := 32
   o:cLang          := LANG_PRG
   o:cTitle         := PROGRAM
   o:cVersion       := PROGVER
   o:cAvtor         := "Copyright 2024 Verchenko Andrey + Sergej Kiselev"
   o:cEmail         := "<verchenkoag@gmail.com> Dmitrov, Moscow region / <bilance@bilance.lv>"
   o:cPrgInfo1      := "Many thanks for your help: Grigory Filatov <gfilatov@inbox.ru>"
   o:cPrgInfo2      := "Tips and tricks programmers from our forum http://clipper.borda.ru"
   o:cPathTemp      := GetUserTempFolder() + "\"
   o:cPathDbf       := GetStartUpFolder() + "\DBF\"
   //o:aDisplayMode := { System.DesktopWidth , System.DesktopHeight - GetTaskBarHeight() }
   o:aDisplayMode   := { Sys.ClientWidth , Sys.ClientHeight }
   // ������� ����� ����������, ��������� �������������� �� ������ ���������� ������
   // setting your parameters, allows you to test for other screen resolutions
   //o:aDisplayMode   := { 1280 , 1280 }
   o:cDisplayMode   := HB_NtoS(o:aDisplayMode[1]) + "x" + HB_NtoS(o:aDisplayMode[2])

   _SetGetLogFile( o:cLogFile )

   IF o:lLogDel ; hb_FileDelete( o:cLogFile )
   ENDIF

   IF o:lDebug ; SET LOGERROR ON
   ELSE        ; SET LOGERROR OFF
   ENDIF

   // Default font
   SET FONT TO o:cFontName , o:nFontSize
   // TsBrowse                                       bold italic
   _DefineFont("Normal"  , o:cFontName, o:nFontSize  , .F., .F. )
   _DefineFont("Bold"    , o:cFontName, o:nFontSize  , .T., .F. )
   _DefineFont("Italic"  , o:cFontName, o:nFontSize-2, .F., .T. )
   _DefineFont("ItalBold", o:cFontName, o:nFontSize-2, .T., .T. )
   _DefineFont("SpecHdr" , o:cFontName, o:nFontSize-4, .T., .T. )
   _DefineFont("TsbEdit" , "TArial"    , o:nFontSize+1, .F., .T. )
   // Menu* font
   _DefineFont("ComSanMS" , o:cFontName2 , o:nFontSize+2 , .F., .F. )
   // Alert* font
   _DefineFont("DlgFont" , o:cDlgFont , o:nDlgSize   , .F., .F. )
   // Alert* colors
   SET MSGALERT BACKCOLOR  TO o:aDlgBColor
   SET MSGALERT FONTCOLOR  TO o:aDlgFColor
   //
   SET DEFAULT ICON TO o:cDefAppIcon
   SET WINDOW MODAL PARENT HANDLE ON
   SET TOOLTIPSTYLE BALLOON
   SET NAVIGATION EXTENDED
   SET MENUSTYLE  EXTENDED
   Set ShowRedAlert On        // ��������� ���� ��� ���� "Program Error"

   // �������� �� ������ ������ ����� ���������
   _HMG_MESSAGE[4] := "������� ������� ������ ����� ���������:" + CRLF + ;
                      App.ExeName + CRLF + ;
                      "�������� � �������." + CRLF + _HMG_MESSAGE[4]
   SET MULTIPLE QUIT WARNING  // ���� ���������

   SetMenuBitmapHeight( o:nMenuBmpHeight )

   PUBLIC nOperat, cOperator, nPubYear                      
   M->nOperat     := 111
   M->cOperator   := "Admin-Test"
   M->nPubYear    := YEAR(DATE())

   ? PadC( " Program start - " + HB_TTOC( hb_DateTime() ) + " ", 80, "-" )
   ? " Screen resolution:", HB_NtoS(GetDesktopWidth())+" x "+HB_NtoS(GetDesktopHeight())
   ?? "LargeFontsMode()=", HB_NtoS( LargeFontsMode() )
   ? "Free Open Software:", Version()
   ? "     Free Compiler:", hb_Ccompiler()
   ? "  Free Gui library:", MiniGuiVersion()

   o:cIniFile := cIni
   o:lIni     := hb_FileExists(cIni)
   // ������ � ���-����� ����� � ��������� - App.Cargo:oIni
   o:oIni := TIniData():New(cIni, .T.):Read()

   Default o:oIni:INFO := oHmgData()
   Default o:oIni:INFO:Developed_in   := MiniGUIVersion()
   Default o:oIni:INFO:xBase_compiler := Version()
   Default o:oIni:INFO:C_compiler     := Hb_Compiler()
   Default o:oIni:INFO:Programm       := o:cTitle
   Default o:oIni:INFO:ProgVers       := o:cVersion
   Default o:oIni:INFO:Avtor          := o:cAvtor
   Default o:oIni:INFO:Email          := o:cEmail

   Default o:oIni:MAIN := oHmgData()
   Default o:oIni:MAIN:aBClrMain    := {215, 166, 0}
   Default o:oIni:MAIN:ComSanMS     := { o:cFontName2 , o:nFontSize+2 , .F., .F. }   // ���� �������� �������� ����
   Default o:oIni:MAIN:aWindow      := {0, 0, 0, 0}
   Default o:oIni:MAIN:cMaska       := "���� ����� ���������"
   Default o:oIni:MAIN:cMaskaRU     := "���� 16.03.24 �������"
   Default o:oIni:MAIN:cMaskaEN     := "input 16.03.24 Ivanova"
   IF App.Cargo:cLang == "RU"   // Russian interface-lang
      o:oIni:MAIN:cMaska := o:oIni:MAIN:cMaskaRU
   ELSE
      o:oIni:MAIN:cMaska := o:oIni:MAIN:cMaskaEN
   ENDIF
   // TsBrowse
   Default o:oIni:TsBrowse := oHmgData()
   Default o:oIni:TsBrowse:Normal   := { o:cFontName, o:nFontSize  , .F., .F. }
   Default o:oIni:TsBrowse:Bold     := { o:cFontName, o:nFontSize  , .T., .F. }
   Default o:oIni:TsBrowse:Italic   := { o:cFontName, o:nFontSize-2, .F., .T. }
   Default o:oIni:TsBrowse:ItalBold := { o:cFontName, o:nFontSize-2, .T., .T. }
   Default o:oIni:TsBrowse:SpecHdr  := { o:cFontName, o:nFontSize-2, .T., .T. }
   Default o:oIni:TsBrowse:SuperHdr := { o:cFontName, o:nFontSize-2, .T., .F. }
   Default o:oIni:TsBrowse:Edit     := { o:cFontName, o:nFontSize+2, .F., .F. }
   //                    cell     Head   foot    SpecHider  SuperHider   Edit
   //oTsb:aFont   := { "Normal", "Bold", "Bold", "SpecHdr" , "ItalBold", "DlgFont" }
   //_o2log(o:oIni, 27, ProcNL() + "  o:oIni => ", .T. ) ; ?

   IF !o:lIni
      // ���� ��� �����, �� �������� ���
      o:oIni:cCommentBegin  := " Modify: " + hb_TtoC( hb_DateTime() )
      o:oIni:Write()  // �� UTF8, �.�. ��� BOM �� ������
   ENDIF

RETURN

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION ResizeForm( oBrw, oWnd )
   Local nG, owc, nTsbY, nTsbX, cBrw
   DEFAULT oWnd := _WindowObj( GetActiveWindow() )

   IF !ISOBJECT(oBrw)
      AlertStop("Not an oBrw object !;" + ProcNL())
      RETURN NIL
   ENDIF

   owc   := oWnd:Cargo
   nTsbY := owc:nTsbY
   nTsbX := owc:nTsbX
   nG    := owc:nG

   cBrw  := oBrw:cControlName
   This.&(cBrw).Enabled := .F. // ����������� ������� ������� (������ �� ������������)

   // �� ������ Move() ����������� ReSize() - �������� ���������� ��. TControl.prg
   oBrw:Move( oBrw:nLeft, oBrw:nTop, This.ClientWidth - oBrw:nLeft - nG, This.ClientHeight - oBrw:nTop - nG, .T. )

   This.&(cBrw).Enabled := .T.     // �������������� ������� ������� (������ ������������)

   oBrw:Paint()
   oBrw:Refresh(.T.)
   oBrw:SetNoHoles()
   oBrw:SetFocus()

   DO EVENTS

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION CreateDataWin()
   LOCAL oWin

   oWin := oHmgData()
   oWin:nY         := 0
   oWin:nX         := 0
   oWin:nW         := App.Cargo:aDisplayMode[1]  //System.ClientWidth
   oWin:nH         := App.Cargo:aDisplayMode[2]  //System.ClientHeight
   //oWin:nW       := Sys.ClientWidth
   //oWin:nH       := Sys.ClientHeight
   //oWin:nH       -= GetTaskBarHeight()         // ������ ������ ����� Desktop
   oWin:aBClr      := {127,189,228}
   oWin:cTitle     := PROGRAM
   oWin:cIcon      := App.Cargo:cDefAppIcon
   oWin:lTopmost   := .F.      // This.Topmost := lTopmost, ���� .T. �� ������������� �� ������ ���� ����� ������
   oWin:bOnInit    := Nil      // ����� ���������� �����
   oWin:bOnRelease := {||Nil}  // ����� ���������� �����
   oWin:bIAClose   := {||Nil}  // ����� ���������� �����
   oWin:lWait      := .T. // .T.-"WAIT", .F.="NOWAIT"
   oWin:lCenter    := .F.
   IF App.Cargo:cLang == "RU"
      oWin:cMsg := "��� ����� ��������� �� ������ ����, ���������� ������: No ��������� ������ !" + CRLF
      oWin:cMsg += "�.�. �� ��������� ���� ����� ����� ��������� ����������� �������� ��� !" + CRLF
      oWin:cMsg += "� ��������� ������ ��� ���� ����� ��������� ��� ����� ������ ��������� �����."
   ELSE
      oWin:cMsg := "When entering receipts for each day, YOU MUST CHANGE: Payment document No!" +CRLF
      oWin:cMsg += "That is, the next day after entering receipts, you MUST change it!" +CRLF
      oWin:cMsg += "Otherwise, your input will not be clear to you after some time."
   ENDIF

RETURN oWin

///////////////////////////////////////////////////////////////////////////////
// ������� ��������� �� ���-����� ����� ���������� ����
FUNCTION WindowsCoordinat(ow)
   Local aWin := App.Cargo:oIni:MAIN:aWindow

   IF IsArray(aWin)
      IF aWin[1] < 0 .OR. aWin[2] < 0
         // ��� ������� ����
      ELSEIF aWin[3] <= 0 .OR. aWin[4] <= 0
         // ��� ���� ��������� ����
      ELSE
         ow:Row    := aWin[1]
         ow:Col    := aWin[2]
         ow:Width  := aWin[3]
         ow:Height := aWin[4]
      ENDIF
      // �������� �� ������ ���.������
      IF aWin[3] > App.Cargo:aDisplayMode[1]
         ow:Width  := aWin[3] := App.Cargo:aDisplayMode[1]
      ENDIF
      IF aWin[4] > App.Cargo:aDisplayMode[2]
         ow:Height := aWin[4] := App.Cargo:aDisplayMode[2]
      ENDIF
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
// ������� ��������� �� ���-����� �� ���������� ����
STATIC FUNCTION Windows2Coordinat(oWin)
   Local aWin := App.Cargo:oIni:MAIN:aWindow

   IF IsArray(aWin)
      IF aWin[1] < 0 .OR. aWin[2] < 0
         // ��� ������� ����
      ELSEIF aWin[3] <= 0 .OR. aWin[4] <= 0
         // ��� ���� ��������� ����
      ELSE
         oWin:nY := aWin[1]
         oWin:nX := aWin[2]
         oWin:nW := aWin[3]
         oWin:nH := aWin[4]
      ENDIF
      // �������� �� ������ ���.������
      IF aWin[3] > App.Cargo:aDisplayMode[1]
         oWin:nW  := aWin[3] := App.Cargo:aDisplayMode[1]
      ENDIF
      IF aWin[4] > App.Cargo:aDisplayMode[2]
         oWin:nH := aWin[4] := App.Cargo:aDisplayMode[2]
      ENDIF
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Save_Ini2File( oIni )  // ������ � ���-����

   oIni:cCommentBegin  := " Modify: " + hb_TtoC( hb_DateTime() )
   oIni:Write()  // �� UTF8, �.�. ��� BOM �� ������

RETURN NIL

