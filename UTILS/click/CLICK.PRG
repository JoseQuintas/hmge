*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\CLICK.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Procedure main()
*+               Static Procedure SaveIniPath()
*+               Static Procedure CheckVerbose()
*+               Static Procedure Check1Stwin()
*+               Static Procedure InitMain()
*+               Static Procedure SbarText()
*+               Static Procedure ShowAction()
*+               Static Procedure DoEsc()
*+               Static Procedure DoExit()
*+               Static Procedure StartClick()
*+               Static Function Func_head()
*+               Function Lineparse()
*+               Function RootName()
*+               Procedure Show_in()
*+               Procedure Show_out()
*+               Procedure Show_Status()
*+               Procedure Centertext()
*+               Procedure ResetInfo()
*+               Static Function afront()
*+               Static Function bReadPart()
*+               Static Function Pop_stack()
*+               Static Function Leadspace()
*+               Static Procedure TheAligner()
*+               Static Function Dbc_identify()
*+               Static Function IndentLevel()
*+               Static Procedure IndentReset()
*+               Static Procedure Main_screen()
*+               Static Function CutLine()
*+               Static Function ShowDir()
*+               Static Procedure Show_Source()
*+               Procedure setlinecont()
*+               Static Procedure CRE_INICLICK()
*+
*+       Tables: USE (cHome+"INICLICK.DBF") EXCLUSIVE
*+               USE (cHome+"INICLICK.DBF") EXCLUSIVE
*+               USE ( cDBFPath ) shared
*+               USE ( cDBFPath ) EXCLUSIVE
*+               USE (datei) ALIAS "INICLICK" VIA "DBFCDX" NEW EXCLUSIV
*+
*+      Indexes: INDEX ON FIELD->fnct + FIELD->srce TAG funct_src unique
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "HMG.CH"
#include "DIRECTRY.CH"
//#include "COMMON.CH"
#include "INKEY.CH"
#include "FILEIO.CH"
#include "Dbstruct.ch"

#define CVERSION '2.05.40'

REQUEST DBFCDX                                                        // DBFFPT do i need FPT ?
REQUEST DBFNTX

/*********************************************************************
* 2.05.40
* BUG Button "Source" / "DBF" : change assihn TEXTBOX       21.04.2022
*
* 2.05.39
* more for DEFINE REPORT                                    06.02.2022
*
* 2.05.38
* SnapToCtrl( cForm, cControl )                             13.08.2021
*
* 2.05.37
* add 'POPUP' / 'END POPUP' if not DEFINE                   06.05.2021
*
* 2.05.36
* "NODE" / nIndTree / nTabTree                              14.11.2020
*
* 2.05.35
* add lUse1Stwin ( nIndDefine DEFINE WINDOW )
*
* 2.05.34
* change for HMG \Source                                    09.09.2020
*
* 2.05.32                                                   05.09.2020
* add INICLICK.DBF to remember Path
*
* 2.05.31                                                   01.08.2020
* using "&" for Hotkey
*
* 2.05.29                                                   19.01.2020
* Release Source Code
*
* 2.05.28                                                   18.01.2020
* RC 2 Release : Show_Source()
*
* 2.05.27                                                   17.01.2020
* START PRINTxxx / BEGIN xxx
*
* 2.05.25                                                   15.01.2020
* NO *.FMG any more
*
* 2.05.24                                                   14.01.2020
* DEFINE PRINT
*
* 2.05.23                                                   12.01.2020
* add more for HMG DEFINE
*
* 2.05.20                                                   11.01.2020
* HMG Version work now
*
* 2.05.17                                                   03.01.2020
* INLINE / ENDCLASS ?
* CheckVerbose()
* TimeStamp : RETAIN_ORIGINAL_TIME_DATE_ON_OUTPUT_FILES=YES
*
* 2.05.16                                                   02.01.2020
* add cDBFNTX instead of cINI
* add BREAK / RECOVER to "skip file"
* fixed 8.3 *.PRG Filename Problem
*********************************************************************/

STATIC nLineCount    := 0
STATIC nMasterCount  := 0
STATIC lLineContinue := .f.
STATIC lLastContinue := .f.
STATIC nStripComment := 0
STATIC lCommentMode  := .f.
STATIC oOutHandle
STATIC cFuncDiv
STATIC lDumpBuffer   := .f.
STATIC lMoreToGo     := .f.
STATIC aCommand      := {}
STATIC aCmdLogic     := {}
STATIC aFunction     := {}
STATIC cComCase
STATIC cFunCase
STATIC cBoolCase
STATIC nAlignMethod
STATIC nUnCase
STATIC nUnFor
STATIC nUnSequence
STATIC lVerbose      := .T.
STATIC lMode5
STATIC nComntTab
STATIC lConvertSlash
STATIC lConvertStar
STATIC lConvertArray
STATIC lRemDupMTLine
STATIC lGotClass     := .f.
STATIC lDeflate1
STATIC lDeflate2
STATIC lDeflate3
STATIC lDeflate4
STATIC lDeflate5
STATIC nTabIf
STATIC nIndIf
STATIC nTabFor
STATIC nIndFor
STATIC nTabCase
STATIC nIndCase
STATIC nTabFunc
STATIC nIndFunc
STATIC nTabBegin
STATIC nIndBegin
STATIC nTabWhile
STATIC nIndWhile
STATIC nTabClass
STATIC lRestScrn
STATIC nMidScreen    := 15

// HMG
STATIC nTabDefine                                                     // Jimmy
STATIC nIndDefine                                                     // Jimmy

STATIC nTabStart                                                      // Jimmy
STATIC nIndStart                                                      // Jimmy

STATIC nTabTree                                                       // 2.05.36
STATIC nIndTree                                                       // 2.05.36

STATIC lUse1Stwin := .T.                                              // Jimmy

MEMVAR cStatusBox, cInBox, cOutBox
MEMVAR _HMG_SYSDATA

*+--------------------------------------------------------------------
*+
*+    Procedure main()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE main( filespec )

PUBLIC cStatusBox := ""
PUBLIC cInBox     := ""
PUBLIC cOutBox    := ""

   SET MULTIPLE OFF
   SET EPOCH TO YEAR( DATE() ) - 50
   SET CENTURY ON
   SET DATE GERMAN                                                    // Jimmy Germany

   RDDSETDEFAULT( "DBFCDX" )

   DEFAULT filespec TO '*.PRG'

   DEFINE WINDOW ClickForm ;
         AT 218, 337 ;
         WIDTH 1024 ;
         HEIGHT 706 ;
         TITLE "Click HMG Version" ;
         ICON "MYMAIN" ;
         MAIN ;
         NOMAXIMIZE ;
         ON INIT InitMain( /*filespec*/ ) ;
         ON RELEASE SaveIniPath()

      DEFINE STATUSBAR FONT "Arial" SIZE 9
         STATUSITEM "Harbour Statusbar Ready !" WIDTH 500
         DATE
         CLOCK
      END STATUSBAR

      DEFINE RICHEDITBOX StatusBox
         ROW 10
         COL 20
         WIDTH 970
         HEIGHT 150
         VALUE ""
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .T.
         BACKCOLOR NIL
      END RICHEDITBOX

      DEFINE RICHEDITBOX InBox
         ROW 200
         COL 20
         WIDTH 970
         HEIGHT 155
         VALUE ""
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .T.
         BACKCOLOR NIL
      END RICHEDITBOX

      DEFINE RICHEDITBOX OutBox
         ROW 360
         COL 20
         WIDTH 970
         HEIGHT 155
         VALUE ""
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .T.
         BACKCOLOR NIL
      END RICHEDITBOX

      DEFINE PROGRESSBAR ProgressBar_1
         ROW 164
         COL 20
         WIDTH 970
         HEIGHT 30
         RANGEMIN 1
         RANGEMAX 100
         VALUE 0
         TOOLTIP ""
         HELPID Nil
         VISIBLE .T.
         SMOOTH .F.
         VERTICAL .F.
         BACKCOLOR NIL
         FORECOLOR NIL
      END PROGRESSBAR

      DEFINE BUTTON Button_StartClick
         ROW 520
         COL 880
         WIDTH 120
         HEIGHT 120
         ACTION StartClick()
         CAPTION "&Click"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         HELPID Nil
         FLAT .F.
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         MULTILINE .F.
         PICTURE Nil
         PICTALIGNMENT TOP
      END BUTTON

      DEFINE BUTTON Button_EXE
         ROW 520
         COL 20
         WIDTH 58
         HEIGHT 28
         ACTION ShowDir( "EXE" )
         CAPTION "Click.EXE"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         HELPID Nil
         FLAT .F.
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         MULTILINE .F.
         PICTURE Nil
         PICTALIGNMENT TOP
      END BUTTON

      DEFINE TEXTBOX Text_EXE
         ROW 520
         COL 80
         WIDTH 500
         HEIGHT 28
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP "Folder of Click.EXE"
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONENTER Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         RIGHTALIGN .F.
         DISABLEDBACKCOLOR Nil
         DISABLEDFONTCOLOR Nil
         CASECONVERT NONE
         BACKCOLOR NIL
         FONTCOLOR NIL
         INPUTMASK Nil
         FORMAT Nil
         VALUE ""
      END TEXTBOX

      DEFINE BUTTON Button_Source
         ROW 550
         COL 20
         WIDTH 58
         HEIGHT 28
         ACTION ShowDir( "SOURCE" )
         CAPTION "&Source"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         HELPID Nil
         FLAT .F.
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         MULTILINE .F.
         PICTURE Nil
         PICTALIGNMENT TOP
      END BUTTON

      DEFINE TEXTBOX Text_Source
         ROW 550
         COL 80
         WIDTH 500
         HEIGHT 28
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP "Folder of Source"
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONENTER Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         RIGHTALIGN .F.
         DISABLEDBACKCOLOR Nil
         DISABLEDFONTCOLOR Nil
         CASECONVERT NONE
         BACKCOLOR NIL
         FONTCOLOR NIL
         INPUTMASK Nil
         FORMAT Nil
         VALUE ""
      END TEXTBOX

      DEFINE BUTTON Button_DBF
         ROW 580
         COL 20
         WIDTH 58
         HEIGHT 28
         ACTION ShowDir( "DBF" )
         CAPTION "&DBF Path"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         HELPID Nil
         FLAT .F.
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         MULTILINE .F.
         PICTURE Nil
         PICTALIGNMENT TOP
      END BUTTON

      DEFINE TEXTBOX Text_DBF
         ROW 580
         COL 80
         WIDTH 500
         HEIGHT 28
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP "Folder of Click.INI"
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONENTER Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         RIGHTALIGN .F.
         DISABLEDBACKCOLOR Nil
         DISABLEDFONTCOLOR Nil
         CASECONVERT NONE
         BACKCOLOR NIL
         FONTCOLOR NIL
         INPUTMASK Nil
         FORMAT Nil
         VALUE ""
      END TEXTBOX

      DEFINE BUTTON Button_Target
         ROW 610
         COL 20
         WIDTH 58
         HEIGHT 28
         ACTION ShowDir( "TARGET" )
         CAPTION "&Target"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         HELPID Nil
         FLAT .F.
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         MULTILINE .F.
         PICTURE Nil
         PICTALIGNMENT TOP
      END BUTTON

      DEFINE TEXTBOX Text_Target
         ROW 610
         COL 80
         WIDTH 500
         HEIGHT 28
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP "Folder of Target"
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONENTER Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         RIGHTALIGN .F.
         DISABLEDBACKCOLOR Nil
         DISABLEDFONTCOLOR Nil
         CASECONVERT NONE
         BACKCOLOR NIL
         FONTCOLOR NIL
         INPUTMASK Nil
         FORMAT Nil
         VALUE ""
      END TEXTBOX

      DEFINE CHECKBOX Check_1
         ROW 520
         COL 600
         WIDTH 60
         HEIGHT 28
         CAPTION "&Verbose"
         VALUE lVerbose
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP "Default enable. show Output is slow. Speed-up disable it"
         ONCHANGE CheckVerbose()
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
      END CHECKBOX

      DEFINE CHECKBOX Check_2
         ROW 550
         COL 600
         WIDTH 160
         HEIGHT 28
         CAPTION "use DEFINE &WINDOW"
         VALUE lUse1Stwin
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP "Default enable. for HMG \Source disable it"
         ONCHANGE Check1Stwin()
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
      END CHECKBOX

   END WINDOW

   main_screen( filespec )

   ON KEY ESCAPE OF ClickForm ACTION ClickForm.Release
   CENTER WINDOW ClickForm

   Activate Window ClickForm

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure SaveIniPath()
*+
*+    Called from ( click.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE SaveIniPath()

LOCAL cINIPATH    := ClickForm.Text_DBF.Value
LOCAL cSOURCEPATH := ClickForm.Text_Source.Value
LOCAL cTARGETPATH := ClickForm.Text_Target.Value
LOCAL cHome       := AppFolder()

   USE (cHome+"INICLICK.DBF") EXCLUSIVE
   REPLACE INICLICK->INIPATH WITH cINIPATH
   REPLACE INICLICK->SOURCEPATH WITH cSOURCEPATH
   REPLACE INICLICK->TARGETPATH WITH cTARGETPATH
   REPLACE INICLICK->USE1STWIN WITH lUse1Stwin

   CLOSE

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure CheckVerbose()
*+
*+    Called from ( click.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE CheckVerbose()

   lVerbose := GetProperty( "ClickForm", "Check_1", "Value" )
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure Check1Stwin()
*+
*+    Called from ( click.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE Check1Stwin()

   lUse1Stwin := GetProperty( "ClickForm", "Check_2", "Value" )
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure InitMain()
*+
*+    Called from ( click.prg )   1 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE InitMain( /*filespec*/ )

LOCAL aDbStruct
LOCAL cEXE, cINI, cHome := AppFolder()
LOCAL cDBFNTX
LOCAL cSource
LOCAL cTarget

   cEXE := ft_origin()
   cINI := STRTRAN( cEXE, ".EXE", ".INI" )

   IF !FILE( cHome + "INICLICK.DBF" )
      CRE_INICLICK( cHome + "INICLICK.DBF" )
   ENDIF

   //  cSource := GetCurrentFolder()
   //  cDBFNTX := GetCurrentFolder()
   //  cTarget := GetCurrentFolder() + "\CLICKOUT"

   USE (cHome+"INICLICK.DBF") EXCLUSIVE
   aDbStruct := DBSTRUCT()
   IF LEN( aDbStruct ) <> 4
      CLOSE
      FERASE( cHome + "INICLICK.DBF" )
      MsgInfo( "new Structure. please restart" )
      CRE_INICLICK( cHome + "INICLICK.DBF" )
      QUIT
   ENDIF

   cDBFNTX := INICLICK->INIPATH
   cSource := INICLICK->SOURCEPATH
   cTarget := INICLICK->TARGETPATH
   lUse1Stwin := INICLICK->USE1STWIN
   CLOSE

   SetProperty( "ClickForm", "Text_EXE", "Value", cEXE )
   SetProperty( "ClickForm", "Text_Source", "Value", cSource )
   SetProperty( "ClickForm", "Text_DBF", "Value", cDBFNTX )
   SetProperty( "ClickForm", "Text_Target", "Value", cTarget )

   IF .NOT. FILE( cINI )
      createini( cINI )
   ENDIF

   ClickForm.Button_EXE.hide()

   SbarText( "welcome to CLICK " )

   SnapToCtrl( "ClickForm", "Button_StartClick" )

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure SbarText()
*+
*+    Called from ( click.prg )   1 - static procedure initmain()
*+                                   2 - static procedure startclick()
*+                                   4 - static function showdir()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE SbarText( cText )

   DEFAULT cText TO ""

   ClickForm.StatusBar.Item( 1 ) := cText

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure ShowAction()
*+
*+    Called from ( click.prg )   2 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE ShowAction( cWho )

LOCAL nIndex := GetControlIndex( "Button_StartClick", "ClickForm" )

   DO CASE
      CASE cWho = "ESC"
         SetProperty( "ClickForm", "Button_StartClick", "Caption", "&Abort" )
         ClickForm.Button_StartClick.ACTION := { || DoEsc() }

      CASE cWho = "EXIT"
         SetProperty( "ClickForm", "Button_StartClick", "Caption", "E&xit" )
         ClickForm.Button_StartClick.ACTION := { || DoExit() }

      CASE cWho = "CLICK"
         SetProperty( "ClickForm", "Button_StartClick", "Caption", "&Click" )
         ClickForm.Button_StartClick.ACTION := { || StartClick() }
   ENDCASE

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure DoEsc()
*+
*+    Called from ( click.prg )   1 - static procedure showaction()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE DoEsc()

   IF verify( 'Do you want to QUIT now', ;
              .t., 'Yes', 'No' )
      QUIT
   ENDIF
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure DoExit()
*+
*+    Called from ( click.prg )   1 - static procedure showaction()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE DoExit()

   ClickForm.Release
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure StartClick()
*+
*+    Called from ( click.prg )   1 - procedure main()
*+                                   1 - static procedure showaction()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE StartClick( filespec )

LOCAL cDataPath
LOCAL cDebug, cType                                                   // Jimmy
LOCAL cSourcePath                                                     // Jimmy
LOCAL aStack           := {}
LOCAL aFileNames
LOCAL aParse
LOCAL aLine
LOCAL uLine
LOCAL aType
LOCAL oBuffObj1
LOCAL oBuffObj2
LOCAL aFileList        := {}
LOCAL aLibList         := {}
LOCAL aNewLine
LOCAL aNewType
LOCAL aAss
LOCAL aTss
LOCAL aVars
LOCAL aTars
LOCAL cThisFile
LOCAL cPathFile
LOCAL cOutFile
LOCAL cOrigLine
LOCAL nOrigLen
LOCAL cThisLine
LOCAL uThisLine
LOCAL cHeadText
LOCAL cLast
LOCAL cContSpace       := ''
LOCAL cDBFPath
LOCAL cNSXPath
LOCAL cFullPath
LOCAL cComment
LOCAL cOutput
LOCAL cFirstWord
LOCAL cErrorText
LOCAL cThisText
LOCAL cGrab            := ''
LOCAL cHeadDiv
LOCAL cOutExt
LOCAL cOutDir
LOCAL cOutOver
LOCAL cClickLog
LOCAL x
LOCAL xx
LOCAL y
LOCAL nNumFiles
LOCAL nPointer
LOCAL nDefIndent
LOCAL nMaxSmartAlign
LOCAL nOutPad
LOCAL nParenCount
LOCAL nFileCount       := 0
LOCAL nFirstNonComment
LOCAL nPcntDone
LOCAL nOldPcntDone
LOCAL nTo
LOCAL nLineLen
LOCAL lContSpace       := .f.
LOCAL lIfCommand
LOCAL lGotOne
LOCAL lGotFunction
LOCAL lGrabMore        := .f.
LOCAL lFileList
LOCAL lLinkList
LOCAL lSnapKill
LOCAL lMultKill
LOCAL lClickKill
LOCAL lClickAdd
LOCAL lClickFunc
LOCAL lClickEOF
LOCAL lErrNotify
LOCAL lEraseLog
LOCAL lFuncIndent
LOCAL lLocIndent
LOCAL lCaseIndent
LOCAL lDeclBust
LOCAL lTheAligner
LOCAL lRepl2Assign
LOCAL lStor2Assign
LOCAL lRetTimeDate
LOCAL lSkipFiles
LOCAL lConvertDo
LOCAL nStartJulian
LOCAL cTemp
LOCAL oBuffSave
LOCAL lTempFunction
LOCAL bTempLine
LOCAL tLine
LOCAL tType
LOCAL lOnReturn
LOCAL cMSG

LOCAL nTotBytes                                                       // Jimmy
LOCAL nFileBytes                                                      // Jimmy

   //    FIELD fnct
   //    FIELD srce

   DEFAULT filespec TO '*.PRG'

   SET SCOREBOARD off
   SET CURSOR off

   SbarText( "start CLICK " + TIME() )

   cDBFPath := rootname( ft_origin() ) + '.DBF'
   cNSXPath := rootname( ft_origin() ) + ORDBAGEXT()
   cFullPath := IF( FILE( 'CLICK.INI' ), 'CLICK', RootName( ft_origin() ) ) + '.INI'

   cHeadDiv := ProfileString( cFullPath, 'CLICK', 'HEAD_DIV', '²' )
   cOutExt := ProfileString( cFullPath, 'CLICK', 'OUTPUT_EXTENSION', '.PRG' )
   cOutDir := ProfileString( cFullPath, 'CLICK', 'OUTPUT_DIRECTORY', 'CLICKOUT' )
   cOutOver := ProfileString( cFullPath, 'CLICK', 'OUTPUT_OVERWRITE', 'ASK' )
   cClickLog := ProfileString( cFullPath, 'CLICK', 'CLICK_LOG', 'CLICKOUT\CLICK.LOG' )
   lSnapKill := ProfileString( cFullPath, 'CLICK', 'REMOVE_SNAP_HEADERS', 'YES' ) == 'YES'
   lMultKill := ProfileString( cFullPath, 'CLICK', 'REMOVE_MULTIEDIT_HEADERS', 'YES' ) == 'YES'
   lClickKill := ProfileString( cFullPath, 'CLICK', 'REMOVE_CLICK_HEADERS', 'YES' ) == 'YES'
   lClickAdd := ProfileString( cFullPath, 'CLICK', 'ADD_CLICK_HEADER', 'YES' ) == 'YES'
   lClickFunc := ProfileString( cFullPath, 'CLICK', 'ADD_FUNCTION_HEADERS', 'YES' ) == 'YES'
   lClickEOF := ProfileString( cFullPath, 'CLICK', 'ADD_EOF_MARKER', 'YES' ) == 'YES'
   lErrNotify := ProfileString( cFullPath, 'CLICK', 'NOTIFY_OF_ERROR_ON_SCREEN', 'YES' ) == 'YES'
   lEraseLog := ProfileString( cFullPath, 'CLICK', 'CLICK_LOG_ERASE', 'YES' ) == 'YES'
   lFuncIndent := ProfileString( cFullPath, 'CLICK', 'INDENT_FUNCTIONS', 'NO' ) == 'YES'
   lLocIndent := ProfileString( cFullPath, 'CLICK', 'INDENT_LOCALS', 'NO' ) == 'YES'
   lCaseIndent := ProfileString( cFullPath, 'CLICK', 'INDENT_DO_CASE', 'NO' ) == 'YES'
   lDeclBust := ProfileString( cFullPath, 'CLICK', 'PREPROCESS_WITH_DECLARATION_BUSTER', 'YES' ) == 'YES'
   lTheAligner := ProfileString( cFullPath, 'CLICK', 'POSTPROCESS_WITH_THE_ALIGNER', 'YES' ) == 'YES'
   lRepl2Assign := ProfileString( cFullPath, 'CLICK', 'CHANGE_REPLACE_WITH_TO_ASSIGNMENT', 'YES' ) == 'YES'
   lStor2Assign := ProfileString( cFullPath, 'CLICK', 'CHANGE_STORE_TO_ASSIGNMENT', 'YES' ) == 'YES'
   lRetTimeDate := ProfileString( cFullPath, 'CLICK', 'RETAIN_ORIGINAL_TIME_DATE_ON_OUTPUT_FILES', 'YES' ) == 'YES'
   lSkipFiles := ProfileString( cFullPath, 'CLICK', 'SKIP_FILES_WITH_NO_CHANGES', 'YES' ) == 'YES'
   lConvertDo := ProfileString( cFullPath, 'CLICK', 'CONVERT_OLD_STYLE_FUNCTIONS', 'NO' ) == 'YES'

   nDefIndent := ProfileNum( cFullPath, 'CLICK', 'DEFAULT_INDENT', 8 )
   nMaxSmartAlign := ProfileNum( cFullPath, 'CLICK', 'SMART_ALIGN_MAX_ELEMENTS', 11 )

   cFuncDiv := ProfileString( cFullPath, 'CLICK', 'FUNC_DIV', '±' )
   cComCase := ProfileString( cFullPath, 'CLICK', 'CASE_OF_COMMANDS', 'NOCHANGE' )
   cFunCase := ProfileString( cFullPath, 'CLICK', 'CASE_OF_FUNCTIONS', 'NOCHANGE' )
   cBoolCase := ProfileString( cFullPath, 'CLICK', 'CASE_OF_BOOLEAN', 'NOCHANGE' )
   nAlignMethod := ProfileNum( cFullPath, 'CLICK', '@_SAY_GET_ALIGNMENT_METHOD', 1 )
   lVerbose := ProfileString( cFullPath, 'CLICK', 'VERBOSE', 'YES' ) == 'YES'
   nComntTab := ProfileNum( cFullPath, 'CLICK', 'COMMENTTAB', 10 )
   lConvertSlash := ProfileString( cFullPath, 'CLICK', 'CONVERT_&&_TO_//', 'YES' ) == 'YES'
   lConvertStar := ProfileString( cFullPath, 'CLICK', 'CONVERT_*_TO_//', 'YES' ) == 'YES'
   lConvertArray := ProfileString( cFullPath, 'CLICK', 'CONVERT_][_TO_,', 'YES' ) == 'YES'
   lDeflate1 := ProfileString( cFullPath, 'CLICK', 'DEFLATE_(', 'NO' ) == 'YES'
   lDeflate2 := ProfileString( cFullPath, 'CLICK', 'DEFLATE_[', 'NO' ) == 'YES'
   lDeflate3 := ProfileString( cFullPath, 'CLICK', 'DEFLATE_{', 'NO' ) == 'YES'
   lDeflate4 := ProfileString( cFullPath, 'CLICK', 'DEFLATE_,', 'NO' ) == 'YES'
   lDeflate5 := ProfileString( cFullPath, 'CLICK', 'DEFLATE_+', 'NO' ) == 'YES'

   nTabIf := ProfileNum( cFullPath, 'CLICK', 'INDENT_IF', 3 )
   nIndIf := 0
   nTabFor := ProfileNum( cFullPath, 'CLICK', 'INDENT_FOR', 3 )
   nIndFor := 0
   nTabCase := ProfileNum( cFullPath, 'CLICK', 'INDENT_CASE', 3 )
   nIndCase := 0
   nTabFunc := ProfileNum( cFullPath, 'CLICK', 'INDENT_FUNC', 3 )
   nIndFunc := 0
   nTabBegin := ProfileNum( cFullPath, 'CLICK', 'INDENT_BEGIN', 3 )
   nIndBegin := 0
   nTabWhile := ProfileNum( cFullPath, 'CLICK', 'INDENT_WHILE', 3 )
   nIndWhile := 0
   nTabClass := ProfileNum( cFullPath, 'CLICK', 'INDENT_CLASS', 3 )

   // HMG
   nTabDefine := 3                                                    // Jimmy
   nIndDefine := 0                                                    // Jimmy

   nTabStart := 3                                                     // Jimmy
   nIndStart := 0                                                     // Jimmy

   nTabTree := 3                                                      // 2.05.36
   nIndTree := 0                                                      // 2.05.36

   lUse1Stwin := .F.

   lMode5 := UPPER( ProfileString( cFullPath, 'CLICK', 'RUNMODE', '5.X' ) ) == '5.X'
   lRestScrn := UPPER( ProfileString( cFullPath, 'CLICK', 'RESTORE_SCREEN_ON_EXIT', 'NO' ) ) == 'YES'
   lRemDupMTLine := ProfileString( cFullPath, 'CLICK', 'REMOVE_DUPLICATE_EMPTY_LINES', 'YES' ) == 'YES'

   // ------------ override ----------------*

   ShowAction( "ESC" )

   cOutDir := TRIM( GetProperty( "ClickForm", "Text_Target", "Value" ) )
   IF "\\" $ cOutDir
      cOutDir := STRTRAN( cOutDir, "\\", "\" )
   ENDIF

   SetProperty( "ClickForm", "Check_1", "Value", lVerbose )

   // --------------------------------------*

   IF !lMode5
      lDeclBust := .f.
   ELSE
      MsgInfo( "5.X Style might Indent wrong" )
   ENDIF

   filespec := UPPER( filespec )

   IF filespec $ '/REBUILD|/UPDATE|CLICK.DBF'
      main_screen( filespec )
      libread( cDBFPath, cNSXPath )
      QUIT
   ENDIF

   lFileList := LEFT( filespec, 1 ) == '@'

   lLinkList := '.LNK' $ filespec

   IF RootName( filespec ) == filespec
      filespec += '.PRG'
   ENDIF

   DO CASE
      CASE lLinkList
         IF LEFT( filespec, 1 ) == '@'
            filespec := SUBSTR( filespec, 2 )
         ENDIF

         cTemp := readlnk( filespec )
         aFileList := cTemp[ 1 ]
         aLibList := cTemp[ 2 ]

      CASE lFileList
         aFileList := readlist( SUBSTR( filespec, 2 ), '@' )

      OTHERWISE
         // ------------ override ----------------*
         //   cSourcePath := GetProperty( "ClickForm", "Text_DBF", "Value" )
         cSourcePath := TRIM( GetProperty( "ClickForm", "Text_Source", "Value" ) )
         IF "\\" $ cSourcePath
            cSourcePath := STRTRAN( cSourcePath, "\\", "\" )
         ENDIF
         //   cDataPath := TRIM( GetProperty( "ClickForm", "Text_Source", "Value" ) )
         cDataPath := TRIM( GetProperty( "ClickForm", "Text_DBF", "Value" ) )
         IF "\\" $ cDataPath
            cDataPath := STRTRAN( cDataPath, "\\", "\" )
         ENDIF
         // --------------------------------------*

         aFileNames := DIRECTORY( cSourcePath + "\" + filespec )
         nNumFiles := LEN( aFileNames )
         FOR x := 1 TO nNumFiles
            IF aFileNames[ x, F_NAME ] = "HB_FUNC.PRG"
               // use this Filename "HB_FUNC.PRG" for HMG C-Code
            ELSEIF aFileNames[ x, F_NAME ] = "HMG_FUNC.PRG"
               // use this Filename "HB_FUNC.PRG" for MiniGUI C-Code
            ELSE
               AADD( aFileList, aFileNames[ x, F_NAME ] )
            ENDIF
         NEXT
   ENDCASE

   aFileList := ASORT( aFileList )

   nNumFiles := LEN( aFileList )

   IF nNumFiles == 0
      cMSG := 'Click! ' + CVERSION + CRLF
      cMSG += '' + CRLF
      cMSG += 'Usage:' + CRLF
      cMSG += '' + CRLF
      cMSG += '    CLICK [ [@]<filename/filespec> ]' + CRLF
      cMSG += '' + CRLF
      cMSG += '       Where:' + CRLF
      cMSG += '' + CRLF
      cMSG += '       <filename> is the name of your link script (myprog.lnk)' + CRLF
      cMSG += '   or' + CRLF
      cMSG += '       <filespec> is a legal DOS filespec. Wildcards permitted.' + CRLF
      cMSG += '                  (myprog.prg) (*.prg)' + CRLF
      cMSG += '                  Click with no parameters assumes *.PRG' + CRLF
      cMSG += '   or' + CRLF
      cMSG += '       @<filename> is a text file containing a list of filenames' + CRLF
      cMSG += '                   (progname.txt)' + CRLF
      cMSG += '' + CRLF
      MsgInfo( cMsg )
      QUIT
   ENDIF

   main_screen( filespec )

   IF !FILE( cDBFPath )
      IF verify( 'Click! needs to scan your library files.', .t., 'OK', 'Quit' )
         libread( cDBFPath, cNSXPath )
      ELSE
         QUIT
      ENDIF
   ENDIF

   IF lConvertDo
      IF verify( { 'You have turned on the conversion of DO/WITH', ;
                   'to formal function with parameters', ;
                   '', ;
                   'CONVERT_OLD_STYLE_FUNCTIONS=YES', ;
                   '', ;
                   'Due to DO/WITH passing the parameters by reference', ;
                   'and FUNCTION( PARAMETERS ) not passing by reference,', ;
                   'the only way to make the change is to precede all', ;
                   'parameters in the parameter list with @', ;
                   '', ;
                   'This has the potential to cause compiler error C2009', ;
                   '', ;
                   'To correct the compiler errors, you will have to', ;
                   'remove the @ sign when it is not needed in the', ;
                   'converted function call and recompile' }, .f., 'Continue', 'Stop' )
      ELSE
         QUIT
      ENDIF
   ENDIF

   DBCLOSEALL()
   USE ( cDBFPath ) shared

   IF FILE( cNSXPath )
      SET INDEX TO ( cNSXPath )
   ELSE
      DBCLOSEALL()
      USE ( cDBFPath ) EXCLUSIVE
      show_in( 'Creating ' + cNSXPath + ' for ' + cDBFPath )
      INDEX ON FIELD->fnct + FIELD->srce TAG funct_src unique
      DBCLOSEALL()
      USE ( cDBFPath ) shared
      SET INDEX TO ( cNSXPath )
   ENDIF

   click->( DBSETORDER( 1 ) )

   IF !isdir( cOutDir )
      IF verify( 'The output directory "' + cOutDir + '" does not exist.', ;
                 .t., 'Create', 'Abort' )
         ft_mkdir( cOutDir )
      ELSE
         QUIT
      ENDIF
   ENDIF

   cClickLog := cOutDir + '\' + cClickLog

   IF lEraseLog
      FERASE( cClickLog )
   ENDIF

   err_log( cClickLog, '>>>>>> Click! Run Start: ' + DTOS( DATE() ) + ' ' + TIME() )
   err_log( cClickLog, '' )

   // Initialize the arrays that the program uses to figure out things...

   Show_Status( 'Initializing Arrays from ' + cFullPath + ' file' )

   aLine := init_list()                                               // why waste a variable name here???
   aCommand := aLine[ 1 ]
   aFunction := aLine[ 2 ]
   aCmdLogic := aLine[ 3 ]
   op_list( '' )
   nStartJulian := td2jul()

   FOR xx := 1 TO nNumFiles                                           // FOR - NEXT

      BEGIN SEQUENCE

         cThisFile := afileList[ xx ]                                 // Jimmy

         IF !FILE( cSourcePath + '\' + cThisFile )
            BREAK                                                     // Jimmy
         ENDIF

         IndentReset()
         cContSpace := ''
         lContSpace := .f.
         lCommentMode := .f.
         lLineContinue := .f.
         lLastContinue := .f.
         nLineCount := 0
         nStripComment := 0

         ResetInfo()
         aStack := {}

         cPathFile := STRTRAN( cSourcePath + '\' + cThisFile, "\\", "\" )
         centertext( 'Current File => ' + cPathFile, 4 )

         IF UPPER( cOutExt ) == '.PRG' .AND. ( cOutDir == '.' .OR. EMPTY( cOutDir ) )
            pop_msg( { 'You cannot use the .PRG extension', ;
                       'unless you direct output to a different directory' } )
            QUIT
         ENDIF

         IF lSkipFiles
            cOutFile := cOutDir + '\' + RootName( cThisFile ) + cOutExt
            IF FILE( cOutFile )
               IF td2jul( filetime( cOutFile ), filedate( cOutFile ) ) >= ;
                          td2jul( filetime( cPathFile ), filedate( cPathFile ) )
                  show_out( 'Skipping ' + cPathFile )
                  BREAK                                               // Jimmy
               ENDIF
            ENDIF
         ENDIF

         IF lTheAligner
            cOutFile := '$prealin.tmp'
         ELSE
            cOutFile := cOutDir + '\' + RootName( cThisFile ) + cOutExt
         ENDIF

         IF cOutOver != 'ALWAYS'
            IF FILE( cOutFile )
               IF cOutOver == 'ASK'
                  IF !verify( { 'Output file exists. Overwrite?', '', '<Esc> to end Click!' } )
                     IF LASTKEY() == 27
                        QUIT
                     ELSE
                        BREAK                                         // Jimmy
                     ENDIF
                  ENDIF
               ELSE
                  BREAK                                               // Jimmy
               ENDIF
            ENDIF
         ENDIF

         nFileCount ++

         centertext( 'PASS' )
         centertext( 'File ' + LTRIM( STR( xx ) ) + ' of ' + LTRIM( STR( nNumFiles ) ), 7 )

         IF lDeclBust
            Show_Status( "Phase 1" )
            declbust( cSourcePath + '\' + cThisFile, '$declbst.tmp' )
            oBuffObj1 := bInit( '$declbst.tmp' )
         ELSE
            oBuffObj1 := bInit( cSourcePath + '\' + cThisFile )
         ENDIF

         Show_Status( "Phase 2" )
         init_func_text( cSourcePath + '\' + cThisFile )
         nPcntDone := 0

         IF bopen( oBuffObj1 )

            FERASE( cOutFile )
            oOutHandle := bo_init( cOutFile )
            bo_open( oOutHandle )

            IF lClickAdd
               bo_write( oOutHandle, '*+' + REPLICATE( cHeadDiv, 68 ) + CRLF )
               bo_write( oOutHandle, '*+' + CRLF )
               bo_write( oOutHandle, '*+ Source Module => ' + ;
                         STRTRAN( cSourcePath + '\' + cThisFile, "\\", "\" ) + CRLF )

               oBuffObj2 := {}
               IF FILE( 'CLICK.HDR' )
                  oBuffObj2 := bInit( 'CLICK.HDR' )
               ELSEIF FILE( RootName( ft_origin() ) + '.HDR' )
                  oBuffObj2 := bInit( RootName( ft_origin() ) + '.HDR' )
               ENDIF
               IF !EMPTY( oBuffObj2 )
                  bo_write( oOutHandle, '*+' + CRLF )
                  IF bopen( oBuffObj2 )
                     DO WHILE !beof( oBuffObj2 )
                        bo_write( oOutHandle, '*+    ' + bReadLine( oBuffObj2 ) + CRLF )
                        // Show_Status(str( bLineNumber( oBuffObj2 ), 8 ))
                     ENDDO
                  ENDIF
                  bclose( oBuffObj2 )
               ENDIF

               bo_write( oOutHandle, '*+' + CRLF )
               bo_write( oOutHandle, '*+    Reformatted by Click! ' + CVERSION + ' on ' + nicedate( DATE() ) + ' at ' + am_pm( TIME() ) + CRLF )
               bo_write( oOutHandle, '*+' + CRLF )
               bo_write( oOutHandle, '*+' + REPLICATE( cHeadDiv, 68 ) + CRLF )
               IF lRemDupMTLine
                  bo_write( oOutHandle, CRLF )
               ENDIF
            ENDIF

            SetProperty( "ClickForm", "ProgressBar_1", "Value", 0 )
            DO EVENTS

            DO WHILE !beof( oBuffObj1 ) .OR. lMoreToGo

               nOldPcntDone := nPcntDone
               nPcntDone := INT( bRelative( oBuffObj1 ) * 50 )
               IF nOldPcntDone <> nPcntDone
                  nTotBytes := oBuffObj1[ 7 ]
                  nFileBytes := oBuffObj1[ 9 ]
                  SetProperty( "ClickForm", "ProgressBar_1", "Value", CalcPos( nTotBytes, nFileBytes ) )
                  // SetProperty( "ClickForm", "ProgressBar_1", "Value", nPcntDone * 2 )
                  DO EVENTS
               ENDIF

               aParse := bReadPart( oBuffObj1 )
               aLine := aParse[ 1 ]
               aType := aParse[ 2 ]
               cOrigLine := aParse[ 3 ]
               nLineLen := LEN( aLine )

               IF lGrabMore
                  lGrabMore := .f.
                  cOrigLine := cGrab + cOrigLine
                  aParse := lineparse( cOrigLine )
                  aLine := aParse[ 1 ]
                  aType := aParse[ 2 ]
               ELSE
                  lGrabMore := .f.
                  IF nlineLen == 3
                     IF UPPER( aLine[ 1 ] ) == 'DO' .AND. aLine[ 3 ] == ';'
                        lGrabMore := .t.
                        cGrab := aLine[ 1 ] + ' '
                        LOOP
                     ENDIF
                  ENDIF
               ENDIF

               // does the user want out?

               IF INKEY() == 27
                  BREAK
               ENDIF

               lLastContinue := lLineContinue
               lLineContinue := ASCAN( aType, 'LC' ) > 0

               // Blow past empty lines

               IF EMPTY( aLine )
                  bo_write( oOutHandle, CRLF )
                  show_out( '' )
                  lMoreToGo := .f.
                  cContSpace := ''
                  lContSpace := .f.
                  LOOP
               ENDIF

               // Kill Click Headers

               IF PAD( cOrigLine, 2 ) == '*þ'                         // old style headers that sucked
                  LOOP
               ENDIF

               IF lClickKill
                  IF PAD( cOrigLine, 2 ) == '*+'
                     LOOP
                  ENDIF
               ENDIF

               // Kill Snap Headers

               IF lSnapKill
                  IF PAD( cOrigLine, 2 ) $ '*:|*!'
                     LOOP
                  ENDIF
               ENDIF

               // Kill Multi-Edit headers

               IF lMultKill
                  IF PAD( cOrigLine, 2 ) == '#/' .OR. ;
                          LEFT( cOrigLine, 6 ) == '/* --%'
                     LOOP
                  ENDIF
               ENDIF

               // Check for /* and */ comments and skip them

               IF lCommentMode
                  IF ( nPointer := AT( '*/', cOrigLine ) ) > 0
                     nPointer ++

                     lCommentMode := .f.
                     bo_write( oOutHandle, LEFT( cOrigLine, nPointer ) + CRLF )
                     show_out( LEFT( cOrigLine, nPointer ) )
                     cOrigLIne := SUBSTR( cOrigLine, nPointer + 1 )
                     IF !EMPTY( cOrigLine )
                        nStripComment := nPointer + 1
                     ENDIF
                     LOOP
                  ELSE
                     bo_write( oOutHandle, cOrigLine + CRLF )
                     show_out( cOrigLine )
                     LOOP
                  ENDIF
               ELSE
                  IF ATAIL( aType ) == '/*'
                     lCommentMode := .t.
                  ENDIF
               ENDIF

               // write comments and loop

               IF LEFT( aLine[ 1 ], 1 ) == '*'
                  cOrigLine := ALLTRIM( cOrigLine )
                  nOrigLen := LEN( cOrigLine )
                  IF lConvertStar
                     DO CASE
                        CASE nOrigLen == 1
                           cOrigLine := '//'
                        CASE nOrigLen > 1 .AND. LEFT( cOrigLine, 2 ) <> '*+'
                           cOrigLine := '// ' + SUBSTR( cOrigLine, 2 )
                     ENDCASE
                  ENDIF
                  bo_write( oOutHandle, SPACE( IndentLevel() ) + cOrigline + CRLF )
                  show_out( SPACE( IndentLevel() ) + cOrigLine )
                  lDumpBuffer := .t.
                  LOOP
               ENDIF

               // write # directives and loop

               IF aType[ 1 ] == '#'

                  bo_write( oOutHandle, LTRIM( cOrigLine ) + CRLF )
                  lDumpBuffer := .t.
                  show_out( LTRIM( cOrigLine ) )
                  IF ASCAN( aType, 'LC' ) > 0
                     // if right( trim( cOrigLine ), 1 ) == ';'
                     DO WHILE .t.
                        cOrigLine := bReadLine( oBuffObj1 )
                        // Show_Status( str( bLineNumber( oBuffObj1 ), 8 ) )
                        bo_write( oOutHandle, cOrigLine + CRLF )
                        show_out( LTRIM( cOrigLine ) )
                        aParse := lineparse( cOrigLine )
                        aLine := aParse[ 1 ]
                        aType := aParse[ 2 ]
                        IF ASCAN( aType, 'LC' ) == 0
                           EXIT
                        ENDIF
                     ENDDO
                  ENDIF
                  LOOP
               ENDIF

               // smart indent on @

               IF aLine[ 1 ] == '@' .AND. !lLastContinue
                  IF LEN( aLine ) > 2
                     IF VAL( aLine[ 3 ] ) < 10 .AND. aLine[ 3 ] $ '9876543210'
                        aLine[ 3 ] := ' ' + aLine[ 3 ]
                     ENDIF
                  ENDIF
                  IF LEN( aLine ) > 5
                     IF VAL( aLine[ 6 ] ) < 10 .AND. aLine[ 6 ] $ '9876543210'
                        aLine[ 6 ] := ' ' + aLine[ 6 ]
                     ENDIF
                  ENDIF
               ENDIF

               // clone the aLine array, but in upper case

               uLine := ACLONE( aLine )
               nPointer := LEN( ULine )
               FOR y := 1 TO nPointer
                  // uLine[ y ] := UPPER( uLine[ y ] )
                  uLine[ y ] := UPPER( LTRIM( uLine[ y ] ) ) + SPACE( 8 )                                                                   // Jimmy
               NEXT

               // it's possible that a line starts with a /**/ comment
               // if so, find the first non-comment pointer

               nFirstNonComment := 1
               FOR x := 1 TO nPointer
                  IF aType[ x ] == '/**/' .OR. aLine[ x ] == ' '
                     nFirstNonComment := x + 1
                     IF nFirstNonComment > LEN( aType )
                        nFirstNonComment := 1
                     ENDIF
                  ELSE
                     EXIT
                  ENDIF
               NEXT

               // decrease the indent level on an END or NEXT

               IF !lLastContinue
                  cErrorText := ""                                    // Jimmy
                  cDebug := TRIM( uLine[ nFirstNonComment ] )
                  cType := aType[ nFirstNonComment ]

                  BEGIN SEQUENCE
                     // Jimmy 202009
                     IF lUse1Stwin = .T.
                        IF "END WINDOW" $ cOrigLine
                           BREAK
                        ENDIF
                     ENDIF

                     IF aType[ nFirstNonComment ] $ 'CT' .AND. ;
                                ( LEFT( uLine[ nFirstNonComment ], 3 ) == 'END' .OR. ;
                                LEFT( uLine[ nFirstNonComment ], 4 ) == 'NEXT' )

                        IF ( LEFT( uLine[ nFirstNonComment ], 8 ) == 'ENDCLASS' .OR. ;
                             ( LEN( uLine ) > 2 .AND. ;
                             LEFT( uLine[ nFirstNonComment ], 3 ) == 'END' ) .AND. ;
                             LEFT( uLine[ nFirstNonComment + 2 ], 5 ) == 'CLASS' )
                           // nIndIf --
                           BREAK
                        ENDIF

                        cLast := pop_stack( aStack )
                        DO CASE
                           CASE EMPTY( cLast )
                              cErrorText := 'Control Underflow 1: Error detected at line ' + ALLTRIM( STR( nLineCount ) )
                              IF lErrNotify                           // Control Underflow
                                 //  pop_msg( cErrorText )
                              ENDIF
                              err_log( cClickLog, cPathFile )
                              err_log( cClickLog, cErrorText )
                              err_log( cClickLog, '' )
                              IndentReset()
                              //  aStack := {}
                           CASE cLast == 'IF'
                              nIndIf --
                           CASE cLast == 'FOR'
                              nIndFor --
                           CASE cLast == 'CASE'
                              nIndCase --
                              IF lCaseIndent .AND. cLast == 'CASE'
                                 nIndCase --
                              ENDIF

                           CASE cLast == 'TRY'
                              nIndCase --
                           CASE cLast == 'CATCH'
                              nIndCase --

                           CASE cLast == 'BEGIN'
                              nIndBegin --

                           CASE cLast == 'WHILE'
                              nIndWhile --

                              // HMG
                           CASE cLast == 'DEFINE'                     // Jimmy
                              nIndDefine --

                           CASE cLast == 'POPUP'
                              nIndDefine --
#IFDEF Use_Switch
                           CASE cLast == 'SWITCH'                     // Jimmy
                              nIndCase --
                              IF lCaseIndent                          //.AND. cLast == 'CASE'
                                 nIndCase --
                              ENDIF
#ENDIF
                           CASE cLast == 'START'                      // Jimmy
                              nIndStart --

                           CASE cLast == 'NODE'                       // 2.05.36
                              nIndTree --

                        ENDCASE

                     ENDIF

                  END SEQUENCE
               ENDIF

               IF !EMPTY( cErrorText )
                  IF lErrNotify                                       // Control Underflow
                     Show_Source()                                    // Jimmy
                     IF verify( cErrorText + CRLF + "Skip File " + cThisFile, .t., 'Yes', 'No' )
                        BREAK                                         // Jimmy
                     ENDIF
                  ELSE
                     BREAK                                            // Jimmy
                  ENDIF
               ENDIF

               IF lFuncIndent

                  // read ahead to see if this is the last return

                  IF aType[ nFirstNonComment ] $ 'CT' .AND. ;
                             LEFT( uLine[ nFirstNonComment ], 4 ) == 'RETU'
                     oBuffSave := bGetSet( oBuffObj1 )

                     lTempFunction := .f.
                     lOnReturn := .t.
                     tType := ACLONE( aType )
                     DO WHILE .t.

                        IF lOnReturn
                           IF ASCAN( tType, 'LC' ) > 0
                              bTempLine := bReadPart( oBuffObj1 )
                              tLine := bTempLine[ 1 ]
                              tType := bTempLine[ 2 ]
                              LOOP
                           ENDIF
                           lOnReturn := .f.
                        ENDIF

                        bTempLine := bReadPart( oBuffObj1 )

                        tLine := bTempLine[ 1 ]
                        tType := bTempLine[ 2 ]

                        DO CASE
                           CASE LEN( tLine ) > 2 .AND. ;
                                        UPPER( PAD( tLine[ 1 ], 4 ) ) $ 'FUNC|PROC|METH|CLAS' .AND. ;
                                        tType[ 1 ] $ 'CT' .AND. ;
                                        LEFT( tLine[ 2 ], 1 ) <> '('
                              lTempFunction := .t.
                           CASE LEN( tLine ) > 4 .AND. ;
                                        UPPER( LEFT( tLine[ 1 ], 4 ) ) $ 'STAT|EXIT|INIT' .AND. ;
                                        tType[ 3 ] $ 'CT' .AND. ;
                                        UPPER( PAD( tLine[ 3 ], 4 ) ) $ 'FUNC|PROC|METH|CLAS'
                              lTempFunction := .t.
                           CASE bEof( oBuffObj1 )
                              lTempFunction := .t.
                           CASE EMPTY( tLine ) .OR. '//' $ tType[ 1 ] .OR. '/*' $ tType[ 1 ]
                           OTHERWISE
                              EXIT
                        ENDCASE

                        IF lTempFunction
                           nIndFunc --
                           EXIT
                        ENDIF

                     ENDDO

                     oBuffObj1 := bRestSet( oBuffSave )
                  ENDIF

               ENDIF

               // check for underflow at any time

               IF IndentLevel() < 0
                  cErrorText := 'Control Underflow 2: Error detected at line ' + ALLTRIM( STR( nLineCount ) )
                  IF lErrNotify                                       // Control Underflow
                     // pop_msg( cErrorText )
                  ENDIF
                  err_log( cClickLog, cPathFile )
                  err_log( cClickLog, cErrorText )
                  err_log( cClickLog, '' )
                  IndentReset()
                  //  aStack := {}
                  IF lErrNotify                                       // Control Underflow
                     Show_Source()                                    // Jimmy
                     IF verify( cErrorText + CRLF + "Skip File " + cThisFile, .t., 'Yes', 'No' )
                        BREAK                                         // Jimmy
                     ENDIF
                  ELSE
                     BREAK                                            // Jimmy
                  ENDIF
               ENDIF

               // correct Replace x with y statements if necessary

               IF lRepl2Assign .AND. lDeclBust
                  IF aType[ nFirstNonComment ] $ 'CT' .AND. ;
                             LEFT( uLine[ nFirstNonComment ], 4 ) == 'REPL'

                     IF ASCAN( uLine, 'ALL' ) == 0 .AND. ;
                               ASCAN( uLine, 'WHIL' ) == 0 .AND. ;
                               ASCAN( uLine, 'FOR' ) == 0 .AND. ;
                               ASCAN( uLine, 'REST' ) == 0 .AND. ;
                               ASCAN( uLine, 'RECO' ) == 0 .AND. ;
                               ASCAN( uLine, 'NEXT' ) == 0

                        // Dump the word REPLACE and the space following it

                        ADEL( aLine, 1 )
                        ADEL( aLine, 1 )
                        ASIZE( aLine, LEN( aLine ) - 2 )

                        ADEL( uLine, 1 )
                        ADEL( uLine, 1 )
                        ASIZE( uLine, LEN( aLine ) )

                        ADEL( aType, 1 )
                        ADEL( aType, 1 )
                        ASIZE( aType, LEN( aLine ) )

                        // put the field-> designator on the field name if needed

                        IF AT( '->', aLine[ 1 ] ) == 0
                           aLine[ 1 ] := 'FIELD->' + aLine[ 1 ]
                           uLine[ 1 ] := 'FIELD->' + uLine[ 1 ]
                        ENDIF

                        // Then, replace the WITH with an :=

                        nPointer := LEN( aLine )

                        FOR x := 1 TO nPointer
                           IF uLine[ x ] == 'WITH'
                              aLine[ x ] := ':='
                              uLine[ x ] := ':='
                              aType[ x ] := 'O'
                           ENDIF
                        NEXT

                     ENDIF

                  ENDIF
               ENDIF

               IF lMode5                                              // Warning

                  // correct STORE x to y, m, w statements if necessary

                  IF lStor2Assign
                     IF aType[ nFirstNonComment ] $ 'CT' .AND. ;
                                LEFT( uLine[ nFirstNonComment ], 4 ) == 'STOR'

                        DO CASE
                           CASE ATAIL( aType ) == 'LC'
                              cErrorText := 'No Conversion of STORE due to ; at end of line ' + ALLTRIM( STR( nLineCount ) )
                              IF lErrNotify                           // No Conversion of STORE
                                 // pop_msg( cErrorText )
                              ENDIF
                              err_log( cClickLog, cPathFile )
                              err_log( cClickLog, cErrorText )
                              err_log( cClickLog, '' )
                              IF lErrNotify                           // Control Underflow
                                 Show_Source()                        // Jimmy
                                 IF verify( cErrorText + CRLF + "Skip File " + cThisFile, .t., 'Yes', 'No' )
                                    BREAK                             // Jimmy
                                 ENDIF
                              ELSE
                                 BREAK                                // Jimmy
                              ENDIF

                           OTHERWISE

                              // Dump the word STORE and the space following it

                              ADEL( aLine, 1 )
                              ADEL( aLine, 1 )
                              ASIZE( aLine, LEN( aLine ) - 2 )

                              ADEL( uLine, 1 )
                              ADEL( uLine, 1 )
                              ASIZE( uLine, LEN( aLine ) )

                              ADEL( aType, 1 )
                              ADEL( aType, 1 )
                              ASIZE( aType, LEN( aLine ) )

                              // Find the pointer to the TO command.

                              nTo := ASCAN( uLine, { | x | x == 'TO' } )

                              IF nTo > 0

                                 // grab the left half (assignment)

                                 aNewLine := ACLONE( aLine )
                                 aNewType := ACLONE( aType )

                                 aAss := {}
                                 aTss := {}
                                 FOR x := 1 TO nTo - 2
                                    AADD( aAss, aNewLine[ x ] )
                                    AADD( aTss, aNewType[ x ] )
                                 NEXT

                                 // grab the vars to assign to

                                 aVars := {}
                                 aTars := {}
                                 nParenCount := 0
                                 FOR x := nTo + 2 TO LEN( aLine )
                                    IF aType[ x ] == '+'
                                       nParenCount ++
                                    ENDIF
                                    IF aType[ x ] == '-'
                                       nParenCount --
                                    ENDIF
                                    IF aLine[ x ] == ',' .AND. nParenCount == 0
                                       AADD( aVars, ' :=' )
                                       AADD( aTars, 'O' )
                                    ELSE
                                       AADD( aVars, aNewLine[ x ] )
                                       AADD( aTars, aNewType[ x ] )
                                    ENDIF
                                 NEXT

                                 AADD( aVars, ' := ' )
                                 AADD( aTars, 'O' )

                                 aLine := ACLONE( aVars )
                                 aType := ACLONE( aTars )

                                 FOR x := 1 TO LEN( aAss )
                                    AADD( aLine, aAss[ x ] )
                                    AADD( aType, aTss[ x ] )
                                 NEXT

                              ENDIF
                        ENDCASE
                     ENDIF
                  ENDIF
               ENDIF

               // does this line start a function or method?

               lGotFunction := .f.
               IF LEN( aLine ) > 2 .AND. ;
                       UPPER( PAD( aLine[ 1 ], 4 ) ) $ 'FUNC|PROC|METH|CLAS' .AND. ;
                       aType[ 1 ] $ 'CT' .AND. ;
                       LEFT( aLine[ 2 ], 1 ) <> '('
                  lGotFunction := .t.
               ENDIF
               IF LEN( aLine ) > 4 .AND. ;
                       UPPER( LEFT( aLine[ 1 ], 4 ) ) $ 'STAT|EXIT|INIT|CREA' .AND. ;
                       aType[ 3 ] $ 'CT' .AND. ;
                       UPPER( PAD( aLine[ 3 ], 4 ) ) $ 'FUNC|PROC|METH|CLAS'
                  lGotFunction := .t.
               ENDIF

               // turn off header detection in the middle of a class creation

               IF lGotFunction .AND. lGotClass
                  lGotFunction := .f.
               ENDIF

               IF nIndFunc > 0 .AND. lFuncIndent .AND. lGotFunction
                  nIndFunc --
               ENDIF

               // check for overflow and create header if necessary

               IF lGotFunction .AND. !EMPTY( cHeadText := func_head( aLine ) )
                  IF IndentLevel() > 0
                     cErrorText := 'Control Overflow 1: Error detected at line ' + ALLTRIM( STR( nLineCount ) )
                     IF lErrNotify                                    // Control Overflow
                        // pop_msg( cErrorText )
                     ENDIF
                     err_log( cClickLog, cPathFile )
                     err_log( cClickLog, cErrorText )
                     err_log( cClickLog, '' )
                     IF lErrNotify                                    // Control Underflow
                        Show_Source()                                 // Jimmy
                        IF verify( cErrorText + CRLF + "Skip File " + cThisFile, .t., 'Yes', 'No' )
                           BREAK                                      // Jimmy
                        ENDIF
                     ELSE
                        BREAK                                         // Jimmy
                     ENDIF
                  ENDIF
                  IndentReset()
                  //  aStack := {}
                  IF lClickFunc
                     bo_write( oOutHandle, cHeadText )
                  ENDIF
               ENDIF

               IF !lGotFunction
                  func_call( aLine, aType, cOrigLine )
               ENDIF

               // identify the function IF( by comma in program line
               // remember, anything followed is already assumed to be
               // a function, so if we find it's not a function, we
               // make it a command and put back the missing space

               IF UPPER( aLine[ nFirstNonComment ] ) == 'IF' .AND. LEFT( aLine[ nFirstNonComment + 1 ], 1 ) == '('
                  nPointer := LEN( aLine )
                  nParenCount := 0
                  lIfCommand := .t.
                  lGotOne := .f.                                      // .t. means we got a command

                  IF nPointer >= nFirstNonComment + 4
                     IF '=' $ aType[ nFirstNonComment + 4 ]
                        lGotOne := .t.
                     ENDIF
                  ENDIF

                  IF !lGotOne
                     FOR x := nFirstNonComment TO nPointer
                        IF aType[ x ] == '+' .OR. ( aType[ x ] == 'V' .AND. '(' $ aLine[ x ] )
                           nParenCount ++
                           lGotOne := .t.
                        ENDIF
                        IF aType[ x ] == '-' .OR. ( aType[ x ] == 'V' .AND. ')' $ aLine[ x ] )
                           nParenCount --
                        ENDIF
                        IF aLIne[ x ] == ',' .AND. nParenCount == 1
                           lIfCommand := .f.
                           EXIT
                        ENDIF
                        IF nParenCount == 0 .AND. lGotOne
                           EXIT
                        ENDIF
                     NEXT
                  ENDIF

                  IF lIfCommand
                     aType[ nFirstNonComment ] := 'CT'
                     ASIZE( aLine, LEN( aLine ) + 1 )
                     ASIZE( aType, LEN( aType ) + 1 )
                     AINS( aLine, nFirstNonComment + 1 )
                     AINS( aType, nFirstNonComment + 1 )
                     aLine[ nFirstNonComment + 1 ] := ' '
                     aType[ nFirstNonComment + 1 ] := 'SP'
                  ENDIF

               ENDIF

               IF lGotFunction .AND. LEN( aLine ) > 2 .AND. ;
                          ( ( UPPER( LEFT( aLine[ 1 ], 5 ) ) == 'CLASS' .AND. ;
                          UPPER( LEFT( aLine[ 3 ], 6 ) ) != 'METHOD' ) .OR. ;
                          ( UPPER( LEFT( aLine[ 1 ], 6 ) ) == 'CREATE' .AND. ;
                          UPPER( LEFT( aLine[ 3 ], 5 ) ) == 'CLASS' ) .OR. ;
                          ( UPPER( LEFT( aLine[ 1 ], 5 ) ) == 'CLASS' .AND. ;
                          UPPER( LEFT( aLine[ 3 ], 6 ) ) == 'INLINE' ) )                                                                    // Jimmy

                  lGotClass := .t.
               ENDIF

               IF lGotClass .AND. ;
                          ( UPPER( LEFT( aLine[ 1 ], 8 ) ) == 'ENDCLASS' .OR. ;
                          ( LEN( aLine ) > 2 .AND. ;
                          UPPER( LEFT( aLine[ 1 ], 3 ) ) == 'END' .AND. ;
                          UPPER( LEFT( aLine[ 3 ], 5 ) ) == 'CLASS' ) )
                  lGotClass := .f.
               ENDIF

               cThisLine := ''
               cComment := ''
               nLineLen := LEN( aLine )
               FOR y := 1 TO nLineLen
                  IF aType[ y ] == '//' .AND. y > 1
                     cComment := aLine[ y ]
                  ELSE
                     cThisLine += aLine[ y ]
                  ENDIF
               NEXT

               uThisLine := UPPER( cThisLine )

               nUnFor := 0
               nUnCase := 0
               nUnSequence := 0

               IF aType[ nFirstNonComment ] $ 'CT'
                  cFirstWord := UPPER( PAD( aLine[ nFirstNonComment ], 4 ) )
                  DO CASE
                     CASE cFirstWord == 'ELSE'
                        nUnFor := 1
                     CASE cFirstWord $ 'CASE|OTHE|CATC|'
                        nUnCase := 1
                     CASE cFirstWord == 'RECO'
                        nUnSequence := 1
                     CASE cFirstWord $ 'ENDS'
                        nUnCase := 1
                  ENDCASE
               ENDIF

               cOutput := SPACE( IndentLevel() ) + cContSpace + cThisLine

               nUnFor := 0
               nUnCase := 0
               nUnSequence := 0

               IF !EMPTY( cComment )
                  nOutPad := LEN( cOutput )
                  nOutPad += nComntTab - ( nOutPad % nComntTab )
                  cOutput := PAD( cOutput, nOutPad ) + cComment
                  cComment := ""
               ENDIF

               IF lFuncIndent .AND. !lLocIndent
                  cTemp := UPPER( LTRIM( cOutput ) )
                  IF PAD( UPPER( ALLTRIM( cTemp ) ), 4 ) $ ;
                          'LOCA|PRIV|MEMV|STAT|PUBL'                  // Jimmy del |FIEL
                     cOutput := LTRIM( cOutput )
                  ENDIF
                  bo_write( oOutHandle, cOutput + CRLF )
                  show_out( cOutput )
               ELSE
                  bo_write( oOutHandle, cOutput + CRLF )
                  show_out( cOutput )
               ENDIF

               IF lGotFunction .AND. lRemDupMTLine .AND. !ASCAN( aType, 'LC' ) > 0
                  bo_write( oOutHandle, CRLF )
               ENDIF

               IF !lLastContinue
                  cThisText := LTRIM( UPPER( aLine[ nFirstNonComment ] ) )                                                                  // Jimmy LTRIM()

                  DO CASE
                        // HMG
                     CASE LEFT( LTRIM( cThisText ), 6 ) == 'DEFINE'   // Jimmy
                        // Jimmy 20200921
                        IF lUse1Stwin = .T.
                           IF "DEFINE WINDOW" $ UPPER( cOrigLine )
                           ELSEIF "TIMER" $ UPPER( cOrigLine )
                           ELSE
                              nIndDefine ++
                              AADD( aStack, 'DEFINE' )
                           ENDIF
                        ELSE
                           IF "TIMER" $ UPPER( cOrigLine )
                           ELSE
                              nIndDefine ++
                              AADD( aStack, 'DEFINE' )
                           ENDIF
                        ENDIF

                     CASE LEFT( LTRIM( cThisText ), 5 ) == 'POPUP'    // Jimmy
                        nIndDefine ++
                        AADD( aStack, 'DEFINE' )

                     CASE LEFT( LTRIM( cThisText ), 4 ) == 'NODE'     // 2.05.36
                        nIndTree ++
                        AADD( aStack, 'NODE' )

#IFDEF Use_Switch
                     CASE LEFT( LTRIM( cThisText ), 6 ) == 'SWITCH'   // Jimmy
                        nIndCase ++
                        AADD( aStack, 'SWITCH' )
                        // IF lCaseIndent
                        //     nIndCase ++
                        // ENDIF
#ENDIF
                     CASE LEFT( LTRIM( cThisText ), 5 ) == 'START'    // Jimmy
                        IF "PRINTDOC" $ UPPER( cOrigLine ) .OR. "PRINTPAGE" $ UPPER( cOrigLine ) .OR. "START DOC" $ UPPER( cOrigLine ) .OR. "START PAGE" $ UPPER( cOrigLine )
                           nIndStart ++
                           AADD( aStack, 'START' )
                        ENDIF

                     CASE cThisText == 'IF'
                        DO CASE
                           CASE LEFT( aLine[ nFirstNonComment + 1 ], 1 ) <> '('
                              nIndIf ++
                              AADD( aStack, 'IF' )
                           CASE aType[ nFirstNonComment ] $ 'CT'
                              nIndIf ++
                              AADD( aStack, 'IF' )
                        ENDCASE

                     CASE lFuncIndent .AND. lGotFunction
                        nIndFunc ++
                        AADD( aStack, 'FUNC' )

                     CASE LEFT( cThisText, 5 ) == 'BEGIN'
                        nIndBegin ++
                        AADD( aStack, 'BEGIN' )

                     CASE LEFT( cThisText, 3 ) == 'TRY'
                        nIndCase ++
                        AADD( aStack, 'TRY' )

                        //                      CASE LEFT( cThisText, 5 ) == 'CATCH'
                        //                         nIndCase ++
                        //                         AADD( aStack, 'CATCH' )

                     OTHERWISE
                        // do not indent these if they are variables
                        IF aType[ nFirstNonComment ] $ 'CT'
                           DO CASE
                              CASE LEFT( cThisText, 7 ) == 'DO WHIL'
                                 nIndWhile ++
                                 AADD( aStack, 'WHILE' )
                              CASE LEFT( cThisText, 4 ) == 'WHIL'
                                 nIndWhile ++
                                 AADD( aStack, 'WHILE' )
                              CASE PAD( cThisText, 4 ) == 'FOR '
                                 nIndFor ++
                                 AADD( aStack, 'FOR' )
                              CASE LEFT( cThisText, 7 ) == 'DO CASE'
                                 nIndCase ++
                                 AADD( aStack, 'CASE' )
                                 IF lCaseIndent
                                    nIndCase ++
                                 ENDIF

                              CASE LEFT( cThisText, 5 ) == 'CATCH'
                                 nIndCase ++
                                 AADD( aStack, 'CATCH' )

                                 //                               CASE LEFT( cThisText, 5 ) == 'BEGIN'
                                 //                                  nIndBegin ++
                                 //                                  AADD( aStack, 'BEGIN' )

                           ENDCASE
                        ENDIF
                  ENDCASE

               ENDIF

               // The smart alignment section of Click!

               IF ASCAN( aType, 'LC' ) > 0
                  IF !lContSpace
                     cContSpace := ''
                     nLineLen := LEN( aLine )
                     DO CASE
                           // HMG
                        CASE UPPER( aLine[ 1 ] ) == 'DEFINE'          // Jimmy
                           // just LEN("DEFINE")
                           // cContSpace := SPACE( LEN( afront( aLine, 1 ) ) - 3 )
                           cContSpace := SPACE( 3 )

                        CASE UPPER( aLine[ 1 ] ) == 'SWITCH'          // Jimmy
#IFDEF Use_Switch
#ENDIF
                           cContSpace := SPACE( LEN( afront( aLine, 1 ) ) )

                        CASE UPPER( aLine[ 1 ] ) == 'START'           // Jimmy
                           //                           cContSpace := SPACE( LEN( afront( aLine, 1 ) ) - 3 )
                           cContSpace := SPACE( 3 )

                        CASE UPPER( aLine[ 1 ] ) == 'BEGIN'           // Jimmy
                           //  cContSpace := SPACE( LEN( afront( aLine, 1 ) ) - 3 )
                           cContSpace := SPACE( 3 )

                        CASE UPPER( aLine[ nFirstNonComment ] ) == 'IF'
                           DO CASE
                              CASE nLineLen > 6 .AND. aLine[ 7 ] == '{'
                                 cContSpace := SPACE( LEN( afront( aLine, 8 ) ) - 3 )
                              CASE nLineLen > 5 .AND. aLine[ 6 ] == '{'
                                 cContSpace := SPACE( LEN( afront( aLine, 7 ) ) - 3 )
                              CASE nLineLen > 4 .AND. aLine[ 5 ] == '('
                                 IF nLineLen > 9 .AND. aLine[ 9 ] == ':='
                                    cContSpace := SPACE( LEN( afront( aLine, 10 ) ) - 3 )
                                 ELSE
                                    cContSpace := SPACE( LEN( afront( aLine, 6 ) ) - 3 )
                                 ENDIF
                              CASE nLineLen > 3 .AND. aLine[ 4 ] == '('
                                 IF nLineLen > 8 .AND. aLine[ 8 ] == ':='
                                    cContSpace := SPACE( LEN( afront( aLine, 9 ) ) - 3 )
                                 ELSE
                                    cContSpace := SPACE( LEN( afront( aLine, 5 ) ) - 3 )
                                 ENDIF
                              CASE nLineLen > 2 .AND. aLine[ 3 ] == '('
                                 IF nLineLen > 7 .AND. aLine[ 7 ] == ':='
                                    cContSpace := SPACE( LEN( afront( aLine, 8 ) ) - 3 )
                                 ELSE
                                    cContSpace := SPACE( LEN( afront( aLine, 4 ) ) - 3 )
                                 ENDIF
                              CASE nLineLen > 3 .AND. aLine[ 4 ] == '->' .AND. aLine[ nFirstNonComment + 4 ] == '('
                                 cContSpace := SPACE( LEN( afront( aLine, nFirstNonComment + 5 ) ) - 3 )
                              CASE nLineLen > 1 .AND. aLine[ 2 ] == '(' .AND. aType[ nFirstNonComment ] $ 'CT'
                                 cContSpace := SPACE( LEN( afront( aLine, nFirstNonComment + 3 ) ) )
                              CASE aLine[ 2 ] == '('
                                 cContSpace := SPACE( LEN( afront( aLine, 3 ) ) )
                              OTHERWISE
                                 cContSpace := SPACE( nDefIndent )
                           ENDCASE
                        CASE UPPER( aLine[ 1 ] ) == 'DO'
                           cContSpace := SPACE( LEN( afront( aLine, 4 ) ) - 3 )
                        CASE UPPER( LEFT( aLine[ 1 ], 4 ) ) == 'WHIL'
                           cContSpace := SPACE( LEN( afront( aLine, 2 ) ) - 3 )

                        OTHERWISE
                           DO CASE
                              CASE nLineLen > 6 .AND. aLine[ 3 ] == ':=' .AND. aLine[ 7 ] == '+'
                                 cContSpace := SPACE( LEN( afront( aLine, 4 ) ) )
                              CASE ( nPointer := ASCAN( aLine, '{' ) ) > 0
                                 IF nPointer < nMaxSmartAlign
                                    cContSpace := SPACE( LEN( afront( aLine, nPointer + 1 ) ) )
                                 ENDIF
                              CASE ( nPointer := ASCAN( aLine, '(' ) ) > 0
                                 IF nPointer < nMaxSmartAlign
                                    cContSpace := SPACE( LEN( afront( aLine, nPointer + 1 ) ) )
                                 ENDIF
                           ENDCASE
                     ENDCASE
                     IF LEN( cContSpace ) == 0
                        cContSpace := SPACE( nDefIndent )
                     ENDIF
                     lContSpace := .t.
                  ENDIF
               ELSE
                  cContSpace := ''
                  lContSpace := .f.
               ENDIF

            ENDDO

            IF lClickEOF

               IF lRemDupMTLine
                  bo_write( oOutHandle, CRLF )
               ENDIF
               bo_write( oOutHandle, '*+ EOF: ' + cThisFile + CRLF )
               show_out( '*+ EOF: ' + cThisFile )

            ENDIF

            bo_close( oOutHandle )
            oOutHandle := NIL

            bclose( oBuffObj1 )
            oBuffObj1 := NIL

            IF lFuncIndent .AND. nIndFunc == 1
               nIndFunc --
            ENDIF

            IF IndentLevel() < 0
               cErrorText := 'Control Underflow 3: Error detected at line ' + ALLTRIM( STR( nLineCount ) )
               IF lErrNotify                                          // Control Underflow
                  // pop_msg( cErrorText )
               ENDIF
               err_log( cClickLog, cPathFile )
               err_log( cClickLog, cErrorText )
               err_log( cClickLog, '' )
               IF lErrNotify                                          // Control Underflow
                  Show_Source()                                       // Jimmy
                  IF verify( cErrorText + CRLF + "Skip File " + cThisFile, .t., 'Yes', 'No' )
                     BREAK                                            // Jimmy
                  ENDIF
               ELSE
                  BREAK                                               // Jimmy
               ENDIF
            ENDIF

            IF IndentLevel() > 0
               cErrorText := 'Control Overflow 2: Error detected at line ' + ALLTRIM( STR( nLineCount ) )
               IF lErrNotify                                          // Control Overflow
                  // pop_msg( cErrorText )
               ENDIF
               err_log( cClickLog, cPathFile )
               err_log( cClickLog, cErrorText )
               err_log( cClickLog, '' )
               IF lErrNotify                                          // Control Underflow
                  Show_Source()                                       // Jimmy
                  IF verify( cErrorText + CRLF + "Skip File " + cThisFile, .t., 'Yes', 'No' )
                     BREAK                                            // Jimmy
                  ENDIF
               ELSE
                  BREAK                                               // Jimmy
               ENDIF
            ENDIF

            end_func_text()

            IF lTheAligner
               Show_Status( "Phase 3" )
               Show_Status( "write " + cOutDir + '\' + RootName( cThisFile ) + cOutExt )
               TheAligner( '$prealin.tmp', cOutDir + '\' + RootName( cThisFile ) + cOutExt )
            ENDIF

            IF lRetTimeDate
               setfdati( cOutDir + '\' + RootName( cThisFile ) + cOutExt, filedate( cSourcePath + '\' + cThisFile ), filetime( cSourcePath + '\' + cThisFile ) )
            ENDIF

         ENDIF

         // IF LASTKEY() == 27  // does not react under GUI
         //    EXIT
         // ENDIF

      RECOVER
         IF !EMPTY( oBuffObj1 )
            bclose( oBuffObj1 )
            oBuffObj1 := NIL
         ENDIF
         IF !EMPTY( oOutHandle )
            bo_close( oOutHandle )
            oOutHandle := NIL
         ENDIF
         FERASE( '$declbst.tmp' )
         FERASE( '$prealin.tmp' )
      END SEQUENCE

   NEXT                                                               // end 1

   // write Function into Header
   //

   Show_Status( "write Function into Header " )
   func_text( aLibList, aFileList )                                   // in FUNCTRAK.PRG !

   GetDBFInfo( cOutDir, cDataPath )

   IF lDeclBust
      FERASE( '$declbst.tmp' )
   ENDIF

   IF lTheAligner
      FERASE( '$prealin.tmp' )
   ENDIF

   lVerbose := .t.

   ResetInfo()
   Show_Status( '' )
   Show_Status( 'Processed ' + ALLTRIM( STR( nFileCount ) ) + ' files, containing ' + ALLTRIM( STR( nMasterCount ) ) + ' lines of source code' )
   Show_Status( 'Time in process: ' + diff2jul( td2jul(), nStartJulian ) )
   Show_Status( '' )

   err_log( cClickLog, '>>>>>> Click! Run End:   ' + DTOS( DATE() ) + ' ' + TIME() )
   err_log( cClickLog, '' )

   IF LASTKEY() == 27
      ERRORLEVEL( 1 )
   ENDIF

   ShowAction( "EXIT" )

   SbarText( "thx for using CLICK " + TIME() )

   //    ClickForm.Button_StartClick.SetFocus
   SnapToCtrl( "ClickForm", "Button_StartClick" )

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Function Func_head()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION Func_head( aLine )

LOCAL cDataOut   := ''
LOCAL nWordLen
LOCAL cThisWord
LOCAL cFuncChars := ''
LOCAL lFunc      := .f.
LOCAL lProc      := .f.
LOCAL lClas      := .f.
LOCAL lMeth      := .f.
LOCAL lStat      := .f.
LOCAL lInit      := .f.
LOCAL lExit      := .f.

   IF LEN( aLine ) > 2
      cThisWord := UPPER( aLine[ 1 ] )
      IF LEN( cThisWord ) < 4
         cThisWord := PAD( cThisWord, 4 )
      ENDIF
      nWordLen := LEN( cThisWord )

      IF LEFT( 'FUNCTION', nWordLen ) == cThisWord
         lFunc := .t.
      ELSEIF LEFT( 'PROCEDURE', nWordLen ) == cThisWord
         lProc := .t.
      ELSEIF LEFT( 'METHOD', nWordLen ) == cThisWord .AND. ':' $ aLine[ 3 ]
         lMeth := .t.
      ELSEIF LEFT( 'CLASS', nWordLen ) == cThisWord
         lClas := .t.
      ELSEIF LEFT( 'CREATE', nWordLen ) == cThisWord
         lClas := .t.
      ENDIF

   ENDIF

   IF ( !lFunc .OR. !lProc .OR. !lMeth ) .AND. LEN( aLine ) > 4
      cThisWord := UPPER( aLine[ 1 ] )
      IF LEN( cThisWord ) < 4
         cThisWord := PAD( cThisWord, 4 )
      ENDIF
      nWordLen := LEN( cThisWord )

      IF LEFT( 'STATIC', nWordLen ) == cThisWord
         lStat := .t.
      ENDIF

      IF LEFT( 'INIT', nWordLen ) == cThisWord
         lInit := .t.
      ENDIF

      IF LEFT( 'EXIT', nWordLen ) == cThisWord
         lExit := .t.
      ENDIF

      IF lStat .OR. lInit .OR. lExit

         cThisWord := UPPER( aLine[ 3 ] )
         IF LEN( cThisWord ) < 4
            cThisWord := PAD( cThisWord, 4 )
         ENDIF
         nWordLen := LEN( cThisWord )

         IF LEFT( 'FUNCTION', nWordLen ) == cThisWord
            lFunc := .t.
         ELSEIF LEFT( 'PROCEDURE', nWordLen ) == cThisWord
            lProc := .t.
         ELSEIF LEFT( 'METHOD', nWordLen ) == cThisWord .AND. ':' $ aLine[ 3 ]
            lMeth := .t.
         ELSEIF LEFT( 'CLASS', nWordLen ) == cThisWord
            lClas := .t.
         ELSE
            lStat := .f.
         ENDIF

      ENDIF

   ENDIF

   IF lStat .OR. lInit .OR. lExit .OR. lFunc .OR. lProc .OR. lMeth .OR. lClas
      IF lRemDupMTLine
         cDataOut += CRLF
      ENDIF
      cDataOut += '*+' + REPLICATE( cFuncDiv, 68 ) + CRLF
      show_out( '*+' + REPLICATE( cFuncDiv, 68 ) )
      cDataOut += '*+' + CRLF
      show_out( '*+' )

      DO CASE
         CASE lStat .AND. lFunc
            cFuncChars := '*+' + SPACE( 4 ) + 'Static Function ' + aLine[ 5 ] + '()'
         CASE lStat .AND. lProc
            cFuncChars := '*+' + SPACE( 4 ) + 'Static Procedure ' + aLine[ 5 ] + '()'
         CASE lStat .AND. lMeth
            cFuncChars := '*+' + SPACE( 4 ) + 'Static Method ' + aLine[ 5 ] + '()'

         CASE lInit .AND. lFunc
            cFuncChars := '*+' + SPACE( 4 ) + 'Init Function ' + aLine[ 5 ] + '()'
         CASE lInit .AND. lProc
            cFuncChars := '*+' + SPACE( 4 ) + 'Init Procedure ' + aLine[ 5 ] + '()'
         CASE lInit .AND. lMeth
            cFuncChars := '*+' + SPACE( 4 ) + 'Init Method ' + aLine[ 5 ] + '()'

         CASE lExit .AND. lFunc
            cFuncChars := '*+' + SPACE( 4 ) + 'Exit Function ' + aLine[ 5 ] + '()'
         CASE lExit .AND. lProc
            cFuncChars := '*+' + SPACE( 4 ) + 'Exit Procedure ' + aLine[ 5 ] + '()'
         CASE lExit .AND. lMeth
            cFuncChars := '*+' + SPACE( 4 ) + 'Exit Method ' + aLine[ 5 ] + '()'

         CASE lFunc
            cFuncChars := '*+' + SPACE( 4 ) + 'Function ' + aLine[ 3 ] + '()'
         CASE lProc
            cFuncChars := '*+' + SPACE( 4 ) + 'Procedure ' + aLine[ 3 ] + '()'
         CASE lMeth
            cFuncChars := '*+' + SPACE( 4 ) + 'Method ' + aLine[ 3 ] + '()'

         CASE lClas .AND. UPPER( aLine[ 3 ] ) == 'METHOD'
            cFuncChars := '*+' + SPACE( 4 ) + 'Class Method ' + aLine[ 5 ] + '()'
         CASE lClas .AND. UPPER( aLine[ 1 ] ) == 'CREATE' .AND. UPPER( aLine[ 3 ] ) == 'CLASS'
            cFuncChars := '*+' + SPACE( 4 ) + 'Create Class ' + aLine[ 5 ] + '()'
         CASE lClas
            cFuncChars := '*+' + SPACE( 4 ) + 'Class ' + aLine[ 3 ]

      ENDCASE

      cDataOut += cFuncChars + CRLF
      show_out( cFuncChars )

      functrak( SUBSTR( cFuncChars, 7 ) )

      cDataOut += '*+' + CRLF
      show_out( '*+' )
      cDataOut += '*+' + REPLICATE( cFuncDiv, 68 ) + CRLF
      show_out( '*+' + REPLICATE( cFuncDiv, 68 ) )
      cDataOut += '*+' + CRLF
      show_out( '*+' )

   ENDIF

RETURN cDataOut

*+--------------------------------------------------------------------
*+
*+    Function Lineparse()
*+
*+    Called from ( click.prg )   2 - static procedure startclick()
*+                                   1 - static function breadpart()
*+                                   7 - static procedure thealigner()
*+                ( declbust.prg )   3 - procedure declbust()
*+
*+--------------------------------------------------------------------
*+
FUNCTION Lineparse( cThisLine )

LOCAL lQuoteMode  := .f.
LOCAL lWordMode   := .f.
LOCAL lAction     := .f.
LOCAL lBrackMode  := .f.
LOCAL aLine       := {}
LOCAL aTemp1      := {}
LOCAL aTemp2      := {}
LOCAL aType       := {}
LOCAL cThisChar
LOCAL uThisChar
LOCAL cThisPair
LOCAL cWord
LOCAL cQuoteChar
LOCAL cLookFor
LOCAL cTheString  := ''
LOCAL cThisWord   := ''
LOCAL wordchars
LOCAL cRestOfline := ''
LOCAL nElements
LOCAL nPointer    := 0
LOCAL nLineLen    := LEN( cThisLine )
LOCAL x
LOCAL xx
LOCAL nX
LOCAL cLeft
LOCAL cRight
LOCAL uThisLine   := UPPER( cThisLine )
LOCAL lShortCut
LOCAL nParenLevel
LOCAL nStartElem

STATIC cTab := CHR( K_TAB )

   BEGIN SEQUENCE

      IF LEFT( cThisLine, 1 ) == '*' .OR. lCommentMode
         aLine := { cThisLine }
         aType := { '  //' }
         BREAK
      ENDIF

      IF LEFT( cThisLine, 2 ) $ '//|&&'
         aLine := { cThisLine }
         aType := { '  //' }
         BREAK
      ENDIF

      IF LEFT( cThisLine, 1 ) == '#'
         aLine := { cThisLine }
         aType := { '#' }
         BREAK
      ENDIF

      lShortCut := .f.
      DO CASE
         CASE LEFT( uThisLIne, 4 ) == 'USE '
            lShortCut := .t.
         CASE LEFT( uThisLIne, 5 ) == 'COPY '
            lShortCut := .t.
         CASE LEFT( uThisLIne, 5 ) == 'SAVE '
            lShortCut := .t.
         CASE LEFT( uThisLIne, 6 ) == 'ERASE '
            lShortCut := .t.
         CASE LEFT( uThisLIne, 7 ) == 'CREATE '
            lShortCut := .t.
         CASE LEFT( uThisLine, 8 ) == 'COPY TO '
            lShortCut := .t.
         CASE LEFT( uThisLine, 8 ) == 'RESTORE '
            lShortCut := .t.
         CASE LEFT( uThisLine, 8 ) == 'SET COLO'
            lShortCut := .t.
         CASE LEFT( uThisLine, 8 ) == 'SET ORDE'
            lShortCut := .t.
         CASE LEFT( uThisLine, 10 ) == 'COPY FILE '
            lShortCut := .t.
         CASE LEFT( uThisLine, 11 ) == 'DELETE FILE'
            lShortCut := .t.
      ENDCASE

      IF lShortCut
         nX := numtoken( cThisLine, ' ' )
         FOR x := 1 TO nX
            AADD( aLine, token( cThisLine, ' ', x ) )
            AADD( aType, 'V' )
            IF x < nX
               AADD( aLine, ' ' )
               AADD( aType, 'V' )
            ENDIF
         NEXT

         nX := LEN( aLine )

         FOR x := 1 TO nX

            DO CASE
               CASE cmd_list( aLine[ x ], @nPointer )
                  aType[ x ] := 'C'
                  IF aCmdLogic[ nPointer ]
                     aType[ x ] := 'CT'
                  ENDIF
                  DO CASE
                     CASE cComCase == 'UPPER'
                        aLine[ x ] := UPPER( aLine[ x ] )
                     CASE cComCase == 'LOWER'
                        aLine[ x ] := LOWER( aLine[ x ] )
                     CASE cComCase == 'PROPER'
                        aLine[ x ] := proper( aLine[ x ] )
                     CASE cComCase == 'LIKEINFILE'
                        aLine[ x ] := TRIM( aCommand[ nPointer ] )
                  ENDCASE
               CASE fnc_list( aLine[ x ], @nPointer )
                  aType[ x ] := 'FF'
                  // fix 13Dec'98 (DJW): case below was using cComCase instead of cFunCase
                  DO CASE
                     CASE cFunCase == 'UPPER'
                        aLine[ x ] := UPPER( aLine[ x ] )
                     CASE cFunCase == 'LOWER'
                        aLine[ x ] := LOWER( aLine[ x ] )
                     CASE cFunCase == 'PROPER'
                        aLine[ x ] := proper( aLine[ x ] )
                     CASE cFunCase == 'LIKEINFILE'
                        aLine[ x ] := TRIM( aFunction[ nPointer ] )
                  ENDCASE
               CASE aLine[ x ] == ';'
                  aType[ x ] := 'LC'
               OTHERWISE
                  aType[ x ] := 'V'
            ENDCASE
         NEXT
         BREAK
      ENDIF

      FOR x := 1 TO nLineLen

         cThisChar := SUBSTR( cThisLine, x, 1 )
         uThisChar := UPPER( cThisChar )
         // padding added to eliminate recognition of single :
         cThisPair := PAD( SUBSTR( cThisLine, x, 2 ), 2 )

         IF cThisPair $ '&&|:='
            wordchars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890._\'
         ELSE
            wordchars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890._\&:'
         ENDIF

         // This is the beginning of a quote
         IF !lQuoteMode .AND. ( cThisChar == '"' .OR. cThisChar == "'" .OR. ( lBrackMode .AND. cThisChar == '[' ) )
            // If we are in word mode and find the start of a quote
            // save the word and end word mode, then start quote mode.
            IF lWordMode
               AADD( aLine, cThisWord )
               AADD( aType, 'W' )
               lWordMode := .f.
               cThisWord := ''
            ENDIF
            IF ( lBrackMode .AND. cThisChar == '[' )
               cQuoteChar := ']'
               cTheString := '['
            ELSE
               cQuoteChar := cThisChar
               cTheString := cThisChar
            ENDIF
            lQuoteMode := .t.
            LOOP
         ENDIF

         // This is the end of a quote
         IF lQuoteMode .AND. cThisChar == cQuoteChar
            cTheString += cThisChar
            AADD( aLine, cTheString )
            AADD( aType, 'S' )                                        // String
            cTheString := ''
            lQuoteMode := .f.
            LOOP
         ENDIF

         // if we are in quote mode, just gather the characters
         IF lQuoteMode
            cTheString += cThisChar
            LOOP
         ENDIF

         // this is the beginning of a word
         IF !lWordMode .AND. uThisChar $ wordchars
            lWordMode := .t.
            IF x == nLineLen
               AADD( aLine, cThisChar )
               AADD( aType, 'W' )                                     // Word
            ELSE
               cThisWord := cThisChar
            ENDIF
            lBrackMode := .f.
            LOOP
         ENDIF

         // This is the end of a word
         IF lWordMode .AND. ( !( uThisChar $ wordchars ) .OR. x == nLineLen )
            IF x == nLineLen .AND. uThisChar $ wordchars
               AADD( aLine, cThisWord + cThisChar )
               AADD( aType, 'W' )
               EXIT
            ELSE
               AADD( aLine, cThisWord )
               AADD( aType, 'W' )
            ENDIF
            lWordMode := .f.
            cThisWord := ''
         ENDIF

         // if we are in word mode, just gather the characters
         IF lWordMode
            cThisWord += cThisChar
            LOOP
         ENDIF

         DO CASE
            CASE cThisPair == '/*'
               cRestOfLine := SUBSTR( cThisLine, x )
               IF ( npointer := AT( '*/', cRestOfLine ) ) > 0
                  AADD( aLine, LEFT( cRestOfLine, nPointer + 1 ) )
                  AADD( aType, '/**/' )
                  x += nPointer
               ELSE
                  AADD( aLine, cRestOfLine )
                  AADD( aType, '/*' )
                  EXIT
               ENDIF
            CASE cThisPair == '//' .OR. cThisPair == '&&'
               IF lConvertSlash
                  AADD( aLine, '//' + SUBSTR( cThisLine, x + 2 ) )
               ELSE
                  AADD( aLine, SUBSTR( cThisLine, x ) )
               ENDIF
               AADD( aType, '//' )
               EXIT
            CASE cThisPair == '*/'
               AADD( aLine, '*/' )
               AADD( aType, '*/' )
               x ++
            CASE cThisPair == '()'
               AADD( aLine, cThisPair )
               AADD( aType, 'O' )
               x ++
            CASE cThisPair == '{}'
               AADD( aLine, cThisPair )
               AADD( aType, 'O' )
               x ++
            CASE cThisPair == '<>'
               AADD( aLine, cThisPair )
               AADD( aType, 'O' )
               x ++
            CASE cThisPair == '<='
               AADD( aLine, cThisPair )
               AADD( aType, 'O' )
               x ++
            CASE cThisPair == '>='
               AADD( aLine, cThisPair )
               AADD( aType, 'O' )
               x ++
            CASE cThisPair == '->'
               AADD( aLine, cThisPair )
               AADD( aType, 'O' )
               x ++
            CASE cThisChar $ '-+/*=?|:' .AND. ATAIL( aLine ) == cThisChar
               aLine[ LEN( aLine ) ] += cThisChar
            CASE cThisChar == '=' .AND. !EMPTY( aLine ) .AND. ATAIL( aLine ) $ '+-/*^:'
               aLine[ LEN( aLine ) ] += cThisChar
            CASE cThisChar $ '-+/*=?|:'
               AADD( aLine, cThisChar )
               AADD( aType, 'O' )                                     // Operator
            CASE cThisChar == '&'
               AADD( aLine, cThisChar )
               AADD( aType, 'M' )                                     // Macro
            CASE cThisChar == '\'
               AADD( aLine, cThisChar )
               AADD( aType, '\' )                                     // File Slash
            CASE cThisChar == cTab
               AADD( aLine, ' ' )                                     // Convert Tab to Space for stripping.
               AADD( aType, 'SP' )
            OTHERWISE
               AADD( aLine, cThisChar )
               AADD( aType, 'U' )
         ENDCASE

         IF cThisChar $ '-+/*=?|:(,'
            lBrackMode := .t.
         ENDIF

      NEXT

      nElements := LEN( aLine )

      IF nElements > 0

         IF '.AND.' $ uThisLine

            // check for .and. boolean command imbedded in words

            FOR x := 1 TO nElements
               IF aType[ x ] == 'W' .AND. LEN( aLine[ x ] ) > 5
                  DO WHILE LEN( aLine[ x ] ) > 5 .AND. ( nPointer := AT( '.AND.', UPPER( aLine[ x ] ) ) ) > 0

                     cLeft := LEFT( aLine[ x ], nPointer - 1 )
                     cRight := SUBSTR( aLine[ x ], nPointer + 5 )

                     IF !EMPTY( cLeft )
                        nElements ++
                        ASIZE( aLine, nElements )
                        ASIZE( aType, nElements )
                        AINS( aLine, x )
                        AINS( aType, x )
                        aLine[ x ] := cLeft
                        aType[ x ] := 'W'
                        x ++
                     ENDIF

                     aLine[ x ] := SUBSTR( aLine[ x ], nPointer, 5 )
                     aType[ x ] := 'W'                                // to be identified later...

                     IF !EMPTY( cRight )
                        nElements ++
                        x ++
                        ASIZE( aLine, nElements )
                        ASIZE( aType, nElements )
                        AINS( aLine, x )
                        AINS( aType, x )
                        aLine[ x ] := cRight
                        aType[ x ] := 'W'
                     ENDIF

                  ENDDO
               ENDIF
            NEXT

         ENDIF

         // check for .or. boolean command imbedded in words

         IF '.OR.' $ uThisLine

            nElements := LEN( aLine )
            FOR x := 1 TO nElements
               IF aType[ x ] == 'W' .AND. LEN( aLine[ x ] ) > 4
                  DO WHILE LEN( aLine[ x ] ) > 4 .AND. ( nPointer := AT( '.OR.', UPPER( aLine[ x ] ) ) ) > 0

                     cLeft := LEFT( aLine[ x ], nPointer - 1 )
                     cRight := SUBSTR( aLine[ x ], nPointer + 4 )

                     IF !EMPTY( cLeft )
                        nElements ++
                        ASIZE( aLine, nElements )
                        ASIZE( aType, nElements )
                        AINS( aLine, x )
                        AINS( aType, x )
                        aLine[ x ] := cLeft
                        aType[ x ] := 'W'
                        x ++
                     ENDIF

                     aLine[ x ] := SUBSTR( aLine[ x ], nPointer, 4 )
                     aType[ x ] := 'W'                                // to be identified later...

                     IF !EMPTY( cRight )
                        nElements ++
                        x ++
                        ASIZE( aLine, nElements )
                        ASIZE( aType, nElements )
                        AINS( aLine, x )
                        AINS( aType, x )
                        aLine[ x ] := cRight
                        aType[ x ] := 'W'
                     ENDIF

                  ENDDO
               ENDIF
            NEXT
         ENDIF

         // check for .not. boolean command imbedded in words

         IF '.NOT.' $ uThisLine

            nElements := LEN( aLine )
            FOR x := 1 TO nElements
               IF aType[ x ] == 'W' .AND. LEN( aLine[ x ] ) > 5
                  DO WHILE LEN( aLine[ x ] ) > 5 .AND. ( nPointer := AT( '.NOT.', UPPER( aLine[ x ] ) ) ) > 0

                     cLeft := LEFT( aLine[ x ], nPointer - 1 )
                     cRight := SUBSTR( aLine[ x ], nPointer + 5 )

                     IF !EMPTY( cLeft )
                        nElements ++
                        ASIZE( aLine, nElements )
                        ASIZE( aType, nElements )
                        AINS( aLine, x )
                        AINS( aType, x )
                        aLine[ x ] := cLeft
                        aType[ x ] := 'W'
                        x ++
                     ENDIF

                     aLine[ x ] := SUBSTR( aLine[ x ], nPointer, 5 )
                     aType[ x ] := 'W'                                // to be identified later...

                     IF !EMPTY( cRight )
                        nElements ++
                        x ++
                        ASIZE( aLine, nElements )
                        ASIZE( aType, nElements )
                        AINS( aLine, x )
                        AINS( aType, x )
                        aLine[ x ] := cRight
                        aType[ x ] := 'W'
                     ENDIF

                  ENDDO
               ENDIF
            NEXT

         ENDIF

         // Kill off the space elements in the array

         nElements := LEN( aLine )
         aTemp1 := {}
         aTemp2 := {}
         FOR x := 1 TO nElements
            IF aLine[ x ] != ' '
               AADD( aTemp1, aLine[ x ] )
               AADD( aTemp2, aType[ x ] )
            ENDIF
         NEXT

         // combine two word commands

         nElements := LEN( aTemp1 ) - 1

         FOR x := 1 TO nElements
            cWord := UPPER( aTemp1[ x ] )
            IF '|' + cWord + '|' $ '|BEGIN|'
               ALTD()
            ENDIF
            IF '|' + cWord + '|' $ '|DO|BEGIN|END|SET|CLEAR|COPY STRU|APPEND|LABEL|REPORT|CREATE|DELETE|MENU|RESTORE|SAVE|DEFINE|SWITCH|POPUP|TRY|'                                                               // |START

               lAction := .f.
               cLookFor := UPPER( PAD( aTemp1[ x + 1 ], 4 ) )

               DO CASE
                  CASE cWord == 'DO'
                     lAction := cLookFor $ 'WHIL|CASE'

                  CASE cWord == 'TRY'
                     lAction := cLookFor $ 'CATC'

                  CASE cWord == 'BEGIN'
                     //   lAction := cLookFor $ 'SEQU' .OR. cLookFor $ 'STRU' // Jimmy
                     lAction := cLookFor $ 'SEQU|STRU|' + ;
                             'INI |LAYO|HEAD|TEXT|LINE|FOOT|' + ;
                             'DATA|DETA|SUMM|GROU|RECT|PICT|'

                  CASE cWord == 'END'
                     lAction := cLookFor $ 'CASE|DO  |IF  |SEQU|WHIL|STRU|'

                     *+ ;
                     //                       'LAYO|HEAD|LINE|PICT|DATA|DETA|FOOT|SUMM|GROU|RECT|'
                     //  |DOC |PRIN
                     // do NOT add NO more
                     //  'INI |LAYO|HEAD|TEXT|LINE|FOOT|' + ;
                     //  'DATA|DETA|SUMM|GROU|RECT|'

                  CASE cWord == 'SET'
                     lAction := cLookFor $ 'ALTE|BELL|CENT|COLO|CONF|CONS|CURS|DATE|DECI|DEFA|DELE|DELI|DEVI|EPOC|ESCA|EXAC|EXCL|FILT|FIXE|FORM|FUNC|INDE|INTE|KEY |MARG|MESS|ORDE|PATH|PRIN|PROC|RELA|SCOR|SOFT|TYPE|UNIQ|WRAP'
                  CASE cWord == 'CLASS'
                     lAction := cLookFor $ 'METH|VAR '
                  CASE cWord == 'CLEAR'
                     lAction := cLookFor $ 'ALL |GETS|MEMO|SCRE|TYPE'
                  CASE cWord == 'COPY'
                     lAction := cLookFor $ 'FILE|STRU|TO  '
                  CASE PAD( cWord, 9 ) == 'COPY STRU'
                     lAction := cLookFor == 'EXTE'
                  CASE cWord == 'APPEND'
                     lAction := cLookFor $ 'BLAN|FROM'
                  CASE cWord == 'LABEL'
                     lAction := cLookFor == 'FORM'
                  CASE cWord == 'REPORT'
                     lAction := cLookFor == 'FORM'
                  CASE cWord == 'CREATE'
                     lAction := cLookFor == 'FROM'
                  CASE cWord == 'DELETE'
                     lAction := cLookFor == 'FILE'
                  CASE cWord == 'MENU'
                     lAction := cLookFor == 'TO  '
                  CASE cWord == 'RESTORE'
                     lAction := cLookFor == 'SCRE'
                  CASE cWord == 'SAVE'
                     lAction := cLookFor == 'SCRE'

                     // HMG
                  CASE cWord == 'DEFINE'                              // Jimmy
                     // Jimmy 20200921
                     IF lUse1Stwin = .T.
                        lAction := cLookFor $ 'WIND|TOOL|GRID|BUTT|MENU|POPU|TEXT|RICH|STAT|CONT|NOTI|MAIN|' + ;
                                'DATE|EDIT|HYPE|IMAG|LABE|LIST|ACTI|ANIM|BROW|CHEC|COMB|DROP|' + ;
                                'FRAM|IPAD|MONT|PLAY|PROG|SLID|SPLI|SPIN|TAB |TIME|TREE|REPO|PAGE|DOC |'
                     ELSE
                        lAction := cLookFor $ 'TOOL|GRID|BUTT|MENU|POPU|TEXT|RICH|STAT|CONT|NOTI|MAIN|' + ;
                                'DATE|EDIT|HYPE|IMAG|LABE|LIST|ACTI|ANIM|BROW|CHEC|COMB|DROP|' + ;
                                'FRAM|IPAD|MONT|PLAY|PROG|SLID|SPLI|SPIN|TAB |TIME|TREE|REPO|PAGE|DOC |'
                     ENDIF

#IFDEF Use_Switch
                  CASE cWord == 'SWITCH'                              // Jimmy
                     lAction := cLookFor $ 'NTYP|CTYP|NFOR|END |NWRI'
#ENDIF
                  CASE cWord == 'START'                               // Jimmy
                     lAction := cLookFor $ 'PRIN|DOC|PAGE'

                  CASE cWord == 'POPUP'
                     lAction := cLookFor == 'END '

               ENDCASE

               IF lAction
                  aTemp1[ x ] += ' ' + aTemp1[ x + 1 ]
                  ADEL( aTemp1, x + 1 )
                  ADEL( aTemp2, x + 1 )
                  ASIZE( aTemp1, nElements )
                  ASIZE( aTemp2, nElements )
                  nElements --
                  aTemp2[ x ] := 'W'
               ENDIF

            ENDIF

         NEXT

         // Now, put a space element in every other position

         nElements := LEN( aTemp1 )
         aLine := {}
         aType := {}

         FOR x := 1 TO nElements
            AADD( aLine, aTemp1[ x ] )
            AADD( aType, aTemp2[ x ] )
            IF x < nElements
               AADD( aLine, ' ' )
               AADD( aType, 'SP' )
            ENDIF
         NEXT

         // identify the 'W' and 'U' elements

         nElements := LEN( aLine )

         nParenLevel := 0

         FOR x := 1 TO nElements

            DO CASE
               CASE aType[ x ] == 'W'
                  DO CASE
                     CASE VAL( aLine[ x ] ) > 0
                        aType[ x ] := 'N'
                     CASE UPPER( aLine[ x ] ) $ '.AND.|.OR.|.NOT.' .AND. ;
                                    LEFT( aLine[ x ], 1 ) == '.' .AND. ;
                                    RIGHT( aLine[ x ], 1 ) == '.'

                        aType[ x ] := 'BOOL'
                        DO CASE
                           CASE cBoolCase == 'UPPER'
                              aLine[ x ] := UPPER( aLine[ x ] )
                           CASE cBoolCase == 'LOWER'
                              aLine[ x ] := LOWER( aLine[ x ] )
                        ENDCASE

                     CASE nParenLevel == 0 .AND. cmd_list( aLine[ x ], @nPointer )
                        aType[ x ] := 'C'
                        IF aCmdLogic[ nPointer ]
                           aType[ x ] := 'CT'
                        ENDIF
                        DO CASE
                           CASE cComCase == 'UPPER'
                              aLine[ x ] := UPPER( aLine[ x ] )
                           CASE cComCase == 'LOWER'
                              aLine[ x ] := LOWER( aLine[ x ] )
                           CASE cComCase == 'PROPER'
                              aLine[ x ] := proper( aLine[ x ] )
                           CASE cComCase == 'LIKEINFILE'
                              aLine[ x ] := TRIM( aCommand[ nPointer ] )
                        ENDCASE

                     CASE nElements > x + 1 .AND. LEFT( aLine[ x + 2 ], 1 ) == '(' .AND. fnc_list( aLine[ x ], @nPointer )
                        aType[ x ] := 'FF'
                        // fix 13Dec'98 (DJW): case below was using cComCase instead of cFunCase
                        DO CASE
                           CASE cFunCase == 'UPPER'
                              aLine[ x ] := UPPER( aLine[ x ] )
                           CASE cFunCase == 'LOWER'
                              aLine[ x ] := LOWER( aLine[ x ] )
                           CASE cFunCase == 'PROPER'
                              aLine[ x ] := proper( aLine[ x ] )
                           CASE cFunCase == 'LIKEINFILE'
                              aLine[ x ] := TRIM( aFunction[ nPointer ] )
                        ENDCASE

                     OTHERWISE
                        aType[ x ] := 'V'

                  ENDCASE

               CASE aType[ x ] == 'U'

                  DO CASE
                     CASE aLine[ x ] == ';'
                        aType[ x ] := 'LB'

                     CASE aLine[ x ] $ '({['
                        aType[ x ] := '+'
                        nParenLevel ++

                     CASE aLine[ x ] $ ')}]'
                        aType[ x ] := '-'
                        nParenLevel --

                     CASE op_list( aLine[ x ] )
                        aType[ x ] := 'OP'

                  ENDCASE
            ENDCASE
         NEXT

         IF nElements > 0 .AND. UPPER( aLIne[ 1 ] ) == 'IF'
            aType[ 1 ] := 'F'
         ENDIF

         // Identify SET( as a function

         IF UPPER( aLine[ 1 ] ) == 'SET'
            IF LEN( aLine ) > 2
               IF aLine[ 3 ] == '('
                  aType[ 1 ] := 'FF'
               ENDIF
            ENDIF
         ENDIF

         // throw away spaces after functions and before parenthesis or brackets

         nElements := LEN( aLine ) - 1

         FOR x := 2 TO nElements

            IF UPPER( aLine[ x ] ) == 'IF'                            // any IF after the first element is a function!
               aType[ x ] := 'FF'
            ENDIF

            IF aLine[ x ] == ' ' .AND. ;
                       LEFT( aLine[ x + 1 ], 1 ) $ '([' .AND. ;
                       aType[ x - 1 ] $ 'FFVC'

               IF LEFT( aLine[ x + 1 ], 1 ) == '('
                  IF aType[ x - 1 ] <> 'FF'
                     aType[ x - 1 ] := 'F'
                  ENDIF
               ENDIF
               ADEL( aLine, x )
               ADEL( aType, x )
               ASIZE( aLine, nElements )
               ASIZE( aType, nElements )
               nElements --
               x --
            ENDIF

         NEXT

         // throw away spaces after macro's

         nElements := LEN( aLine ) - 1

         FOR x := 2 TO nElements
            IF aLine[ x ] == ' ' .AND. aType[ x - 1 ] == 'M'
               ADEL( aLine, x )
               ADEL( aType, x )
               ASIZE( aLine, nElements )
               ASIZE( aType, nElements )
               nElements --
               x --
            ENDIF
         NEXT

         // throw away spaces before commas

         nElements := LEN( aLine ) - 1

         FOR x := 1 TO nElements
            IF aLine[ x ] == ' ' .AND. aLine[ x + 1 ] == ','
               ADEL( aLine, x )
               ADEL( aType, x )
               ASIZE( aLine, nElements )
               ASIZE( aType, nElements )
               nElements --
            ENDIF
         NEXT

         // throw away spaces after ! and @ except:
         //    a. When first element on line starts with !=,
         //    b. When the line starts with @ and lLastContinue

         IF ( aLine[ 1 ] == '!' .AND. aLine[ 3 ] == '=' ) .OR. ;
              ( aLine[ 1 ] == '@' .AND. lLastContinue )
            nStartElem := 1
         ELSE
            nStartElem := 2
         ENDIF

         nElements := LEN( aLine ) - 1

         FOR x := nStartElem TO nElements
            IF ( LEFT( aLine[ x ], 1 ) $ '!@' .OR. aLine[ x ] == '::' ) .AND. ;
                 LEFT( aLine[ x + 1 ], 1 ) == ' '
               ADEL( aLine, x + 1 )
               ADEL( aType, x + 1 )
               ASIZE( aLine, nElements )
               ASIZE( aType, nElements )
               nElements --
            ENDIF
         NEXT

         // throw away spaces on both sides of -> and : and \
         // Make into a single element...

         nElements := LEN( aLine ) - 2

         FOR x := 3 TO nElements
            IF aLine[ x ] == '->' .OR. aLine[ x ] $ ':\'
               aLine[ x - 2 ] += aLine[ x ] + aLine[ x + 2 ]
               aType[ x - 2 ] := 'V'
               FOR xx := 1 TO 4
                  ADEL( aLine, x - 1 )
                  ADEL( aType, x - 1 )
               NEXT
               nElements -= 4
               ASIZE( aLine, nElements + 2 )
               ASIZE( aType, nElements + 2 )
            ENDIF
         NEXT

         // Identify line breaks and line continuations

         nElements := LEN( aLine )

         FOR x := 1 TO nElements
            IF aType[ x ] == 'LB'
               // if a ; (linebreak) is in the last position,
               // it ALWAYS means that the line is continued.
               IF x == nElements
                  aType[ x ] := 'LC'
               ENDIF
               IF x == nElements - 2
                  IF LEFT( ATAIL( aType ), 1 ) == '/'
                     aType[ x ] := 'LC'
                  ENDIF
               ENDIF
            ENDIF
         NEXT

         IF LEN( aLine ) > 2 .AND. aLine[ 1 ] == '@' .AND. aLine[ 2 ] == ' ' .AND. LEFT( aLine[ 3 ], 1 ) == ':'
            ADEL( aLine, 2 )
            ADEL( aType, 2 )
            ASIZE( aLine, LEN( aLine ) - 1 )
            ASIZE( aType, LEN( aType ) - 1 )
         ENDIF

         IF lMode5                                                    // this is 5.x specific stuff

            // throw away spaces after >)}] and before : // oo stuff

            nElements := LEN( aLine ) - 2

            FOR x := 1 TO nElements

               IF aType[ x ] $ 'O-' .AND. ;
                          aType[ x + 1 ] == 'SP' .AND. ;
                          aType[ x + 2 ] $ 'F' .AND. ;
                          LEFT( aLine[ x + 2 ], 1 ) == ':'

                  ADEL( aLine, x + 1 )
                  ADEL( aType, x + 1 )

                  ASIZE( aLine, nElements + 1 )
                  ASIZE( aType, nElements + 1 )

                  nElements --

               ENDIF
            NEXT

            // throw away spaces between ] [

            nElements := LEN( aLine ) - 2

            FOR x := 1 TO nElements

               IF aLine[ x ] == ']' .AND. ;
                          aType[ x + 1 ] == 'SP' .AND. ;
                          aLine[ x + 2 ] = '['

                  IF lConvertArray

                     aLine[ x ] := ', ' + SUBSTR( aLine[ x + 2 ], 2 )

                     ADEL( aLine, x + 1 )
                     ADEL( aType, x + 1 )

                     ADEL( aLine, x + 1 )
                     ADEL( aType, x + 1 )

                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )

                     nElements -= 2
                  ELSE
                     ADEL( aLine, x + 1 )
                     ADEL( aType, x + 1 )

                     ASIZE( aLine, nElements + 1 )
                     ASIZE( aType, nElements + 1 )

                     nElements --
                  ENDIF

               ENDIF
            NEXT

            // See if this is an assignment beyond position 3 but not
            // surrounded by parenthetic levels  like:
            // x[ 4 ] := .t.  // := in position 8

            IF !( LEFT( aType[ 1 ], 1 ) $ 'CF' )

               nParenLevel := 0
               nElements := LEN( aLine )
               FOR x := 1 TO nElements

                  DO CASE
                     CASE aType[ x ] == '+'
                        nParenLevel ++
                     CASE aType[ x ] == '-'
                        nParenLevel --
                  ENDCASE

                  IF nParenLevel == 0 .AND. aLine[ x ] == ':='

                     // incorporate all 2 thru x-2 elements into element 1
                     // and delete the combined pieces
                     // resize the array appropriately

                     aType[ 1 ] := 'V'
                     FOR xx := 2 TO x - 2
                        aLine[ 1 ] += aLine[ xx ]
                     NEXT
                     FOR xx := 2 TO x - 2
                        ADEL( aLine, 2 )
                        ADEL( aType, 2 )
                        nElements --
                     NEXT
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )

                     EXIT

                  ENDIF

               NEXT

            ENDIF

            // if there is an = in position 3, it must be an assignment!
            // unless it is a continued line

            IF !lLineContinue

               IF LEN( aLine ) > 2
                  IF aLine[ 3 ] == '='
                     aLine[ 3 ] := ':='
                     aType[ 1 ] := 'V'
                  ENDIF
               ENDIF

               // also, the = in a for next is an assignment

               IF LEN( aLine ) > 10
                  IF aLine[ 5 ] == '=' .AND. UPPER( aLine[ 1 ] ) == 'FOR'
                     aLine[ 5 ] := ':='
                     aType[ 3 ] := 'V'
                  ENDIF
               ENDIF

            ENDIF

            // If deflate1 is on, throw away spaces after ( and before )
            IF lDeflate1
               nElements := LEN( aLine ) - 1
               FOR x := 1 TO nElements
                  IF RIGHT( aLine[ x ], 1 ) == '(' .AND. ;
                            aType[ x + 1 ] == 'SP'
                     ADEL( aLine, x + 1 )
                     ADEL( aType, x + 1 )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
               FOR x := 1 TO nElements
                  IF LEFT( aLine[ x + 1 ], 1 ) == ')' .AND. ;
                           aType[ x ] == 'SP'
                     ADEL( aLine, x )
                     ADEL( aType, x )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
            ENDIF

            // If deflate2 is on, throw away spaces after [ and before ]
            IF lDeflate2
               nElements := LEN( aLine ) - 1
               FOR x := 1 TO nElements
                  IF RIGHT( aLine[ x ], 1 ) == '[' .AND. ;
                            aType[ x + 1 ] == 'SP'
                     ADEL( aLine, x + 1 )
                     ADEL( aType, x + 1 )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
               FOR x := 1 TO nElements
                  IF LEFT( aLine[ x + 1 ], 1 ) == ']' .AND. ;
                           aType[ x ] == 'SP'
                     ADEL( aLine, x )
                     ADEL( aType, x )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
            ENDIF

            // If deflate3 is on, throw away spaces after { and before }
            IF lDeflate3
               nElements := LEN( aLine ) - 1
               FOR x := 1 TO nElements
                  IF RIGHT( aLine[ x ], 1 ) == '{' .AND. ;
                            aType[ x + 1 ] == 'SP'
                     ADEL( aLine, x + 1 )
                     ADEL( aType, x + 1 )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
               FOR x := 1 TO nElements
                  IF LEFT( aLine[ x + 1 ], 1 ) == '}' .AND. ;
                           aType[ x ] == 'SP'
                     ADEL( aLine, x )
                     ADEL( aType, x )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
            ENDIF

            // If deflate4 is on, throw away spaces after ,
            IF lDeflate4
               nElements := LEN( aLine ) - 1
               FOR x := 1 TO nElements
                  IF aLine[ x ] == ',' .AND. ;
                             aType[ x + 1 ] == 'SP'
                     ADEL( aLine, x + 1 )
                     ADEL( aType, x + 1 )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
            ENDIF

            // If deflate5 is on, throw away spaces surrounding +
            IF lDeflate5
               nElements := LEN( aLine ) - 1
               FOR x := 1 TO nElements
                  IF aLine[ x ] == '+' .AND. ;
                             aType[ x + 1 ] == 'SP'
                     ADEL( aLine, x + 1 )
                     ADEL( aType, x + 1 )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
               FOR x := 1 TO nElements
                  IF aLine[ x + 1 ] == '+' .AND. ;
                             aType[ x ] == 'SP'
                     ADEL( aLine, x )
                     ADEL( aType, x )
                     ASIZE( aLine, nElements )
                     ASIZE( aType, nElements )
                     nElements --
                  ENDIF
               NEXT
            ENDIF

         ENDIF

         // Identify known assignments as variables.

         nElements := LEN( aLine )

         FOR x := 3 TO nElements
            IF aLine[ x ] == ':='
               aType[ x - 2 ] := 'V'
            ENDIF
         NEXT

      ENDIF

   END SEQUENCE

RETURN { aLine, aType }

*+--------------------------------------------------------------------
*+
*+    Function RootName()
*+
*+    Called from ( click.prg )  11 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( cmd_list.prg )   1 - function init_list()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - procedure init_func_text()
*+                                   1 - function func_text()
*+                ( libread.prg )   4 - procedure libread()
*+                ( obufwrit.prg )   1 - function bo_init()
*+                ( readlnk.prg )   3 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION RootName( cFileName )

LOCAL DotAt := RAT( '.', cFileName )

   IF DotAt > 0
      cFileName := LEFT( cFileName, DotAt - 1 )
   ENDIF

RETURN ALLTRIM( cFileName )

*+--------------------------------------------------------------------
*+
*+    Procedure Show_in()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                                   1 - static function breadpart()
*+                                   3 - static procedure thealigner()
*+                                   1 - static procedure show_source()
*+                ( cmd_list.prg )   5 - function init_list()
*+                ( functrak.prg )   5 - function func_text()
*+                ( libread.prg )   3 - procedure libread()
*+                                   1 - static procedure dir_recurs()
*+                ( xbase.prg )   1 - procedure getdbfinfo()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE Show_in( cData )

STATIC nLine := 0

   cInBox += cData + CRLF

   IF lVerbose = .T.
      IF VAL( cData ) > 0
      ELSE
#IFDEF TIP_EDK
         nLine ++
         SetProperty( "ClickForm", "InBox", "AddText", LEN( GetProperty( "ClickForm", "InBox", "Value" ) ), cData + CRLF )
         IF nLine % 250 = 0                                           //Every 250 lines, release memory and execute the event queue
            RELEASE MEMORY
            DO EVENTS
         ENDIF
#ELSE
         SetProperty( "ClickForm", "InBox", "Value", cInBox := CutLine( cInBox ) )
#ENDIF

      ENDIF
   ENDIF
RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure Show_out()
*+
*+    Called from ( click.prg )  10 - static procedure startclick()
*+                                   6 - static function func_head()
*+                                   2 - static function breadpart()
*+                                  14 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   9 - function func_text()
*+                ( libread.prg )   2 - procedure libread()
*+                                   1 - static procedure dir_recurs()
*+                ( xbase.prg )   1 - procedure getdbfinfo()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE Show_out( cData /*, cColor*/ )

   cOutBox += cData + CRLF

   IF lVerbose = .T.
      IF VAL( cData ) > 0
      ELSE
#IFDEF TIP_EDK
         SetProperty( "ClickForm", "OutBox", "AddText", LEN( GetProperty( "ClickForm", "OutBox", "Value" ) ), cData + CRLF )
#ELSE
         SetProperty( "ClickForm", "OutBox", "Value", cOutBox := CutLine( cOutBox ) )
#ENDIF
      ENDIF
   ENDIF
RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure Show_Status()
*+
*+    Called from ( click.prg )  10 - static procedure startclick()
*+                                   1 - procedure centertext()
*+                ( xbase.prg )   1 - procedure getdbfinfo()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE Show_Status( cData )

   cStatusBox += cData + CRLF

#IFDEF TIP_EDK
   SetProperty( "ClickForm", "StatusBox", "AddText", LEN( GetProperty( "ClickForm", "StatusBox", "Value" ) ), cData + CRLF )
#ELSE
   SetProperty( "ClickForm", "StatusBox", "Value", CutLine( cStatusBox ) )
#ENDIF

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure Centertext()
*+
*+    Called from ( click.prg )   3 - static procedure startclick()
*+                ( functrak.prg )   4 - function func_text()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE Centertext( cSomeText /*, nLineNumber, cColor*/ )

   Show_Status( cSomeText )
RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure ResetInfo()
*+
*+    Called from ( click.prg )   2 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( functrak.prg )   1 - function func_text()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE ResetInfo( lleave )

   DEFAULT lleave TO .T.

   cStatusBox := ""                                                   // reset
   cInBox := ""
   cOutBox := ""
   SetProperty( "ClickForm", "StatusBox", "Value", "" )
   SetProperty( "ClickForm", "InBox", "Value", "" )
   SetProperty( "ClickForm", "OutBox", "Value", "" )
   SetProperty( "ClickForm", "ProgressBar_1", "Value", 0 )

   RELEASE MEMORY
   DO EVENTS
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Function afront()
*+
*+    Called from ( click.prg )  17 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION afront( aLine, nHowMany )

LOCAL cSomeData := ''
LOCAL x

   nHowMany := MIN( nHowMany, LEN( aLine ) )

   IF nHowMany > 0
      FOR x := 1 TO nHowMany
         cSomeData += aLine[ x ]
      NEXT
   ENDIF

RETURN cSomeData

*+--------------------------------------------------------------------
*+
*+    Static Function bReadPart()
*+
*+    Called from ( click.prg )   3 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION bReadPart( oBuffObj1 )

LOCAL aLineParts   := {}
LOCAL aLeftLine    := {}
LOCAL aLeftType    := {}
LOCAL cComment
LOCAL cThisLine
LOCAL nNumParts
LOCAL nNumDivs
LOCAL x
LOCAL nLBPointer
LOCAL nNumTaken
LOCAL lClickIgnore := .f.
LOCAL nOldPcntDone
LOCAL nPcntDone    := 0
LOCAL nTotBytes                                                       // Jimmy
LOCAL nFileBytes                                                      // Jimmy

STATIC aLine     := {}
STATIC aType     := {}
STATIC cLineBuff := ''

   IF lDumpBuffer
      aLine := {}
      aType := {}
      cLineBuff := ''
      lDumpBuffer := .f.
   ENDIF

   IF EMPTY( aLine )

      SetProperty( "ClickForm", "ProgressBar_1", "Value", 0 )
      DO EVENTS

      DO WHILE .t.

         IF nStripComment > 0
            cLineBuff := SUBSTR( cLineBuff, nStripComment )
            nStripComment := 0
         ELSE
            cLineBuff := bReadLine( oBuffObj1 )
            // Show_Status( str( bLineNumber( oBuffObj1 ), 8 ) )
            show_in( cLineBuff )                                      // str( bLineNumber( oBuffObj1 ), 8 )
            nLineCount ++
            nMasterCount ++

            nOldPcntDone := nPcntDone
            nPcntDone := INT( bRelative( oBuffObj1 ) * 50 )
            IF nOldPcntDone <> nPcntDone
               nTotBytes := oBuffObj1[ 7 ]
               nFileBytes := oBuffObj1[ 9 ]
               SetProperty( "ClickForm", "ProgressBar_1", "Value", CalcPos( nTotBytes, nFileBytes ) )
               //               SetProperty( "ClickForm", "ProgressBar_1", "Value", nPcntDone * 2 )
               DO EVENTS
            ENDIF

            IF UPPER( TabSpStrip( cLineBuff ) ) == '*+CLICKOFF' .OR. ;
                      UPPER( TabSpStrip( cLineBuff ) ) == 'TEXT'
               lClickIgnore := .t.
            ENDIF
            IF lClickIgnore
               bo_write( oOutHandle, cLineBuff + CRLF )
               show_out( cLineBuff )
               IF UPPER( TabSpStrip( cLineBuff ) ) == '*+CLICKON' .OR. ;
                         UPPER( TabSpStrip( cLineBuff ) ) == 'ENDTEXT' .OR. ;
                         bEof( oBuffObj1 )
                  lClickIgnore := .f.
               ENDIF
               LOOP
            ENDIF
         ENDIF

         cLineBuff := tabstrip( cLineBuff )

         IF lCommentMode .AND. !( '*/' $ cLineBuff ) .AND. !bEof( oBuffObj1 )
            bo_write( oOutHandle, cLineBuff + CRLF )
            show_out( cLineBuff )
            LOOP
         ELSE
            EXIT
         ENDIF

      ENDDO

      cThisLine := ALLTRIM( cLineBuff )

      // waste any remaining tabs or spaces on the left of the line
      cThisLine := TabSpStrip( cThisLine )

      IF LEFT( cThisLine, 1 ) == '*'
         aLine := { cThisLine }
         aType := { '  //' }
      ELSE
         aLineParts := lineparse( cThisLine )
         aLine := aLineParts[ 1 ]
         aType := alineParts[ 2 ]
      ENDIF

   ENDIF

   // Is this a multipart command with a comment?
   // If so, comment goes in second position

   // if this is the beginning of a strikeout section, comment stays on end

   nNumParts := LEN( aLine )
   nNumDivs := 0
   nLBPointer := 0
   FOR x := 1 TO nNumParts
      IF aType[ x ] == 'LB'
         IF EMPTY( nLBPointer )
            // this grabs an array pointer to the last item before the LB
            nLBPointer := x - 1
         ENDIF
         nNumDivs ++
      ENDIF
   NEXT

   IF nNumDivs > 0

      cComment := ''
      IF ATAIL( aType ) == '//'
         // remove the comment to be appended to first element
         cComment := aLine[ LEN( aLine ) ]
         ASIZE( aLine, LEN( aLine ) - 2 )
         ASIZE( aType, LEN( aType ) - 2 )
      ENDIF

      aLeftLine := {}
      aLeftType := {}
      FOR x := 1 TO nLBPointer
         AADD( aLeftLine, aLine[ x ] )
         AADD( aLeftType, aType[ x ] )
      NEXT

      nNumTaken := LEN( aLeftLine ) + 2                               // toss the data, LB and space
      FOR x := 1 TO nNumTaken
         ADEL( aLine, 1 )
         ADEL( aType, 1 )
      NEXT
      ASIZE( aLine, LEN( aLine ) - nNumTaken )
      ASIZE( aType, LEN( aType ) - nNumTaken )

      // if we grabbed a comment off of the end of the line,
      // we append it to the first line element

      IF !EMPTY( cComment )
         AADD( aLeftLine, ' ' )
         AADD( aLeftType, 'SP' )
         AADD( aLeftLine, cComment )
         AADD( aLeftType, '//' )
      ENDIF

      lMoreToGo := .t.

   ELSE
      aLeftLine := aLine
      aLeftType := aType
      aLine := {}
      aType := {}
      lMoreToGo := .f.
   ENDIF

RETURN { aLeftLine, aLeftType, cLineBuff }

*+--------------------------------------------------------------------
*+
*+    Static Function Pop_stack()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION Pop_stack( aStack )

LOCAL nLength := LEN( aStack )
LOCAL retval  := ''

   IF nLength > 0
      retval := aStack[ nLength ]
      ASIZE( aStack, nLength - 1 )
   ENDIF

RETURN retval

*+--------------------------------------------------------------------
*+
*+    Static Function Leadspace()
*+
*+    Called from ( click.prg )   8 - static procedure thealigner()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION Leadspace( aString )

LOCAL x
LOCAL nStrLength := LEN( aString )

   FOR x := 1 TO nStrLength
      IF SUBSTR( aString, x, 1 ) != ' '
         x --
         EXIT
      ENDIF
   NEXT

   IF x > nStrLength
      x := nStrLength
   ENDIF

RETURN x

*+--------------------------------------------------------------------
*+
*+    Static Procedure TheAligner()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE TheAligner( cInFile, cOutFile )

LOCAL oBuffObj4    := bInit( cInFile )
LOCAL oHandle
LOCAL nOldPcntDone
LOCAL nPcntDone    := 0
LOCAL cThisLine    := ''
LOCAL cTempLine
LOCAL cThisCommand
LOCAL cNextLine
LOCAL cOutput
LOCAL aLines       := {}
LOCAL aLControl    := {}
LOCAL x
LOCAL y
LOCAL nY
LOCAL aParse
LOCAL aLine        := {}
LOCAL aType        := {}
LOCAL aNextParse
LOCAL aNextLine
LOCAL aNextType
LOCAL aControl     := { '@   ', 'SAY ', 'GET ', 'PICT', 'VALI', 'RANG', 'WHEN', 'COLO', 'SEND', 'MESS' }
LOCAL aOutPut
LOCAL aOutLines
LOCAL aOutMax      := ARRAY( 10 )
LOCAL nNumLines
LOCAL nNumElements
LOCAL nPointer
LOCAL nLastPointer
LOCAL lClickIgnore := .f.
LOCAL nMaxLen
LOCAL nHowmany
LOCAL nShorter
LOCAL nLeadSpace
LOCAL lInDbcre8    := .f.
LOCAL lInDbcre82   := .f.
LOCAL lInClasAlin  := .f.
LOCAL nMaxName
LOCAL nMaxN1
LOCAL nMaxN2
LOCAL lWorking
LOCAL nCommaAt
LOCAL cTabStrip
LOCAL cComment
LOCAL nOffset
LOCAL nOutPad
LOCAL nLineLen
LOCAL lTwoLevel

LOCAL cFullPath     := IF( FILE( 'CLICK.INI' ), 'CLICK', RootName( ft_origin() ) ) + '.INI'
LOCAL dbCreateAlign := ProfileString( cFullPath, 'CLICK', 'ALIGN_DBCREATE_IN_THE_ALIGNER', 'YES' ) == 'YES'
LOCAL lClassAlign   := ProfileString( cFullPath, 'CLICK', 'ALIGN_CLASS_IN_THE_ALIGNER', 'YES' ) == 'YES'
LOCAL cAlignChars   := IF( lMode5, ':=|+=|-=|*=|/=|^=|!=', '=|!=' )

LOCAL nTotBytes                                                       // Jimmy
LOCAL nFileBytes                                                      // Jimmy

   FERASE( cOutFile )
   oHandle := bo_init( cOutFile )
   IF bo_open( oHandle )

      IF bOpen( oBuffObj4 )
         ResetInfo()

         DO WHILE !bEof( oBuffObj4 )

            lLineContinue := ASCAN( aType, 'LC' ) > 0

            cThisLine := bReadLine( oBuffObj4 )
            // Show_Status( str( bLineNumber( oBuffObj4 ), 8 ) )
            show_in( cThisLine )                                      // str( bLineNumber( oBuffObj4 ), 8 )

            nOldPcntDone := nPcntDone
            nPcntDone := INT( bRelative( oBuffObj4 ) * 50 )
            IF nOldPcntDone <> nPcntDone
               nTotBytes := oBuffObj4[ 7 ]
               nFileBytes := oBuffObj4[ 9 ]
               SetProperty( "ClickForm", "ProgressBar_1", "Value", CalcPos( nTotBytes, nFileBytes ) )
               // SetProperty( "ClickForm", "ProgressBar_1", "Value", nPcntDone * 2 )
               DO EVENTS
            ENDIF

            aParse := lineparse( LTRIM( cThisLine ) )
            aLine := aParse[ 1 ]
            aType := aParse[ 2 ]
            cTabStrip := TabSpStrip( cThisLine )
            nLineLen := LEN( aLine )

            IF UPPER( cTabStrip ) == '*+CLICKOFF'
               lClickIgnore := .t.
            ENDIF
            IF lClickIgnore
               bo_writeNoDupe( oHandle, cThisLine + CRLF )
               show_out( cThisLine )
               IF UPPER( cTabStrip ) == '*+CLICKON' .OR. bEof( oBuffObj4 )
                  lClickIgnore := .f.
               ENDIF
               IF AT( '*/', cThisLine ) > 0
                  lCommentMode := .f.
               ENDIF
               LOOP
            ENDIF

            IF LEFT( cTabStrip, 1 ) == '*' .OR. LEFT( cTabStrip, 2 ) $ '//|&&'
               bo_writeNoDupe( oHandle, cThisLine + CRLF )
               show_out( cThisLine )
               IF AT( '*/', cThisLine ) > 0
                  lCommentMode := .f.
               ENDIF
               LOOP
            ENDIF

            IF lCommentMode
               IF ( nPointer := AT( '*/', cThisLine ) ) > 0
                  nPointer ++

                  lCommentMode := .f.
                  bo_writeNoDupe( oHandle, LEFT( cThisLine, nPointer ) + CRLF )
                  show_out( LEFT( cThisLine, nPointer ) )
                  cThisLine := SUBSTR( cThisLine, nPointer + 1 )
                  IF !EMPTY( cThisLine )
                     nStripComment := nPointer + 1
                  ENDIF
                  LOOP
               ELSE
                  bo_writeNoDupe( oHandle, cThisLine + CRLF )
                  show_out( cThisLine )
                  LOOP
               ENDIF
            ELSE
               IF ATAIL( aType ) == '/*'
                  lCommentMode := .t.
               ENDIF
            ENDIF

            DO CASE

                  // This case aligns CLASS HEADERS
               CASE lClassAlign .AND. ;
                          ( ( nLineLen > 2 .AND. UPPER( aLine[ 1 ] ) == 'CREATE' .AND. UPPER( aLine[ 3 ] ) == 'CLASS' ) .OR. ;
                          ( nLineLen > 0 .AND. UPPER( aLine[ 1 ] ) == 'CLASS' ) .OR. lInClasAlin )

                  AADD( aLines, { leadspace( cThisLine ), LTRIM( cThisLine ), aLine, aType } )

                  IF EMPTY( aLine ) .OR. ;
                            ! ( UPPER( aLine[ 1 ] ) == 'ENDCLASS' .OR. ;
                            ( LEN( aLine ) > 2 .AND. UPPER( aLine[ 1 ] ) == 'END' .AND. UPPER( aLine[ 3 ] ) == 'CLASS' ) )
                     lInClasAlin := .t.
                     LOOP
                  ENDIF
                  lInClasAlin := .f.

                  nNumLines := LEN( aLines )

                  lTwoLevel := .f.
                  FOR x := 1 TO nNumLines
                     IF LEN( aLines[ x, 3 ] ) > 0 .AND. ;
                             RIGHT( aLines[ x, 3, 1 ], 1 ) == ':'
                        lTwoLevel := .t.
                        EXIT
                     ENDIF
                  NEXT

                  FOR x := 1 TO nNumLines

                     nY := LEN( aLines[ x, 3 ] )
                     cTempLine := ''

                     IF nY > 0
                        FOR y := 1 TO nY
                           cTempline += aLines[ x, 3, y ]
                        NEXT
                     ENDIF

                     DO CASE
                        CASE x == 1 .OR. x == nNumLines
                           aLines[ x, 1 ] := 0
                        CASE LEN( aLines[ x, 3 ] ) > 0 .AND. ;
                                     RIGHT( aLines[ x, 3, 1 ], 1 ) == ':'
                           aLines[ x, 1 ] := nTabClass
                        OTHERWISE
                           aLines[ x, 1 ] := IIF( lTwoLevel, nTabClass * 2, nTabClass )
                     ENDCASE

                     cTempLine := SPACE( aLines[ x, 1 ] ) + cTempline

                     IF ( nPointer := AT( '//', cTempline ) ) > 0
                        cComment := SUBSTR( cTempline, nPointer )
                        cTempLine := TRIM( LEFT( cTempline, nPointer - 1 ) )
                     ELSE
                        cComment := ''
                     ENDIF

                     cTempLine += SPACE( nComntTab - ( LEN( cTempLine ) % nComntTab ) ) + cComment

                     bo_writeNoDupe( oHandle, TRIM( cTempline ) + CRLF )
                  NEXT

                  aLines := {}

                  // This case aligns DBCREATE()
               CASE dbCreateAlign .AND. nLineLen > 0 .AND. ;
                          ( UPPER( aLine[ 1 ] ) == 'DBCREATE' .OR. lInDbcre8 )

                  AADD( aLines, { leadspace( cThisLine ), LTRIM( cThisLine ), aLine, aType } )

                  //cNextLine  := bNextLine( oBuffObj4 )
                  //aNextParse := lineparse( ltrim( cNextLine ) )
                  //aNextLine  := aNextParse[ 1 ]
                  //aNextType  := aNextParse[ 2 ]

                  // lLineContinue := ascan( aNextType, 'LC' ) > 0 .or. ascan( aType, 'LC' ) > 0

                  IF ASCAN( aType, 'LC' ) > 0
                     lInDbcre8 := .t.
                     LOOP
                  ENDIF
                  lInDbcre8 := .f.

                  nNumLines := LEN( aLines )

                  nMaxName := 0
                  nMaxN1 := 0
                  nMaxN2 := 0
                  nCommaAt := ASCAN( aLines[ 1, 3 ], ',' )
                  lWorking := nCommaAt > 0

                  IF lWorking

                     BEGIN SEQUENCE

                        FOR x := 1 TO nNumLines
                           IF LEN( aLines[ x, 3 ] ) > IF( x == 1, 20, 12 ) .AND. ;
                                   aLines[ x, 3, IF( x == 1, nCommaAt + 2, 1 ) ] == '{' .AND. ;
                                   aLines[ x, 3, IF( x == 1, nCommaAt + 4, 1 ) ] == '{'
                              nMaxName := MAX( nMaxName, LEN( aLines[ x, 3, IF( x == 1, 11, 3 ) ] ) )
                              nMaxN1 := MAX( nMaxN1, LEN( aLines[ x, 3, IF( x == 1, 17, 9 ) ] ) )
                              nMaxN2 := MAX( nMaxN2, LEN( aLines[ x, 3, IF( x == 1, 20, 12 ) ] ) )
                           ELSE
                              lWorking := .f.
                              BREAK
                           ENDIF
                        NEXT

                     END SEQUENCE

                  ENDIF

                  IF lWorking
                     FOR x := 1 TO nNumLines
                        IF LEN( aLines[ x, 3 ] ) > IF( x == 1, 20, 12 )
                           aLines[ x, 3, IF( x == 1, 11, 3 ) ] := UPPER( PADR( aLines[ x, 3, IF( x == 1, 11, 3 ) ], nMaxName ) )
                           aLines[ x, 3, IF( x == 1, 17, 9 ) ] := PADL( aLines[ x, 3, IF( x == 1, 17, 9 ) ], nMaxN1 )
                           aLines[ x, 3, IF( x == 1, 20, 12 ) ] := PADL( aLines[ x, 3, IF( x == 1, 20, 12 ) ], nMaxN2 )
                        ENDIF
                     NEXT

                     aLines[ 1, 3, 4 ] := UPPER( aLines[ 1, 3, 4 ] )
                  ENDIF

                  FOR x := 1 TO nNumLines
                     nY := LEN( aLines[ x, 3 ] )
                     cTempLine := ''
                     FOR y := 1 TO nY
                        cTempline += aLines[ x, 3, y ]
                     NEXT

                     bo_writeNoDupe( oHandle, SPACE( aLines[ x, 1 ] ) + cTempline + CRLF )
                  NEXT

                  aLines := {}

                  // This case aligns arrays which contain DBCREATE() data
               CASE dbCreateAlign .AND. nLineLen > 0 .AND. ;
                          ( dbc_identify( aType ) .OR. lInDbcre82 )

                  AADD( aLines, { leadspace( cThisLine ), LTRIM( cThisLine ), aLine, aType } )

                  cNextLine := bNextLine( oBuffObj4 )
                  aNextParse := lineparse( LTRIM( cNextLine ) )
                  aNextLine := aNextParse[ 1 ]
                  aNextType := aNextParse[ 2 ]

                  lLineContinue := ASCAN( aNextType, 'LC' ) > 0 .OR. ASCAN( aType, 'LC' ) > 0

                  IF lLineContinue
                     lInDbcre82 := .t.
                     LOOP
                  ENDIF
                  lInDbcre82 := .f.

                  nNumLines := LEN( aLines )

                  nMaxName := 0
                  nMaxN1 := 0
                  nMaxN2 := 0
                  lWorking := .t.

                  BEGIN SEQUENCE

                     FOR x := 1 TO nNumLines
                        IF LEN( aLines[ x, 3 ] ) > IF( x == 1, 20, 12 ) .AND. ;
                                aLines[ x, 3, IF( x == 1, 5, 1 ) ] == '{' .AND. ;
                                aLines[ x, 3, IF( x == 1, 7, 1 ) ] == '{'
                           nMaxName := MAX( nMaxName, LEN( aLines[ x, 3, IF( x == 1, 9, 3 ) ] ) )
                           nMaxN1 := MAX( nMaxN1, LEN( aLines[ x, 3, IF( x == 1, 15, 9 ) ] ) )
                           nMaxN2 := MAX( nMaxN2, LEN( aLines[ x, 3, IF( x == 1, 18, 12 ) ] ) )
                        ELSE
                           lWorking := .f.
                           BREAK
                        ENDIF
                     NEXT

                  END SEQUENCE

                  IF lWorking
                     FOR x := 1 TO nNumLines
                        IF LEN( aLines[ x, 3 ] ) > IF( x == 1, 20, 12 )
                           aLines[ x, 3, IF( x == 1, 9, 3 ) ] := UPPER( PADR( aLines[ x, 3, IF( x == 1, 9, 3 ) ], nMaxName ) )
                           aLines[ x, 3, IF( x == 1, 15, 9 ) ] := PADL( aLines[ x, 3, IF( x == 1, 15, 9 ) ], nMaxN1 )
                           aLines[ x, 3, IF( x == 1, 18, 12 ) ] := PADL( aLines[ x, 3, IF( x == 1, 18, 12 ) ], nMaxN2 )
                        ENDIF
                     NEXT

                     aLines[ 1, 3, 4 ] := UPPER( aLines[ 1, 3, 4 ] )
                  ENDIF

                  nOffset := AT( ':=', aLines[ 1, 2 ] ) - AT( ':=', aLines[ 1, 3, 1 ] + aLines[ 1, 3, 2 ] + aLines[ 1, 3, 3 ] )

                  FOR x := 1 TO nNumLines
                     nY := LEN( aLines[ x, 3 ] )
                     cTempLine := ''
                     FOR y := 1 TO nY
                        cTempline += aLines[ x, 3, y ]
                     NEXT

                     bo_writeNoDupe( oHandle, SPACE( aLines[ x, 1 ] - IF( x > 1, nOffset, 0 ) ) + cTempline + CRLF )
                  NEXT

                  aLines := {}

                  // This case aligns @ say gets
               CASE !lLineContinue .AND. nAlignMethod > 0 .AND. nLineLen > 0 .AND. aLine[ 1 ] == '@'

                  IF nLineLen > 2 .AND. VAL( aLine[ 3 ] ) < 10 .AND. aLine[ 3 ] $ '9876543210'
                     aLine[ 3 ] := ' ' + aLine[ 3 ]
                  ENDIF
                  IF nLineLen > 5 .AND. VAL( aLine[ 6 ] ) < 10 .AND. aLine[ 6 ] $ '9876543210'
                     aLine[ 6 ] := ' ' + aLine[ 6 ]
                  ENDIF

                  AADD( aLines, { leadspace( cThisLine ), LTRIM( cThisLine ), aLine, aType } )

                  cNextLine := bNextLine( oBuffObj4 )
                  aNextParse := lineparse( LTRIM( cNextLine ) )
                  aNextLine := aNextParse[ 1 ]
                  aNextType := aNextParse[ 2 ]

                  IF LEN( aNextLine ) > 0 .AND. aNextLine[ 1 ] == '@'
                     LOOP
                  ENDIF

                  nNumLines := LEN( aLines )

                  aOutLines := {}
                  AFILL( aOutMax, 0 )

                  FOR x := 1 TO nNumLines

                     aOutPut := ARRAY( 10 )
                     AFILL( aOutPut, '' )
                     nLastPointer := 1
                     nNumElements := LEN( aLines[ x, 3 ] )
                     FOR y := 1 TO nNumElements
                        IF /*aLines[ x, 4, y ] $ 'CT' .or.*/ PAD( UPPER( aLines[ x, 3, y ] ), 4 ) $ 'SAY |GET |PICT|COLO|WHEN|RANG|VALI'
                           cThisCommand := PAD( UPPER( aLines[ x, 3, y ] ), 4 )                                                             // grab the matching command

                           // look for it in the control array
                           nPointer := ASCAN( aControl, { | a | cThisCommand == a } )

                           IF nPointer > 0
                              IF nAlignMethod == 1
                                 nLastPointer := nPointer
                              ELSE
                                 nLastPointer ++
                              ENDIF
                           ENDIF
                        ENDIF

                        aOutPut[ nLastPointer ] += aLines[ x, 3, y ]

                     NEXT

                     AADD( aOutLines, ACLONE( aOutPut ) )

                  NEXT

                  ASIZE( aLControl, nNumLines )
                  AFILL( aLControl, .t. )

                  FOR x := 1 TO nNumLines
                     cTempLine := ''
                     FOR y := 2 TO 10
                        cTempLine += TRIM( aOutLines[ x, y ] )
                     NEXT
                     IF EMPTY( cTempLine )
                        aLControl[ x ] := .f.
                     ELSE
                        FOR y := 1 TO 10
                           aOutMax[ y ] := MAX( aOutMax[ y ], LEN( TRIM( aOutLines[ x, y ] ) ) + 1 )
                        NEXT
                     ENDIF
                  NEXT

                  FOR x := 1 TO nNumLines
                     IF aLControl[ x ]
                        IF nAlignMethod == 3
                           FOR y := 2 TO 10
                              IF y == 2
                                 cTempline := SPACE( aLines[ x, 1 ] ) + ;
                                                     aOutLines[ x, 1 ] + ;
                                                     aOutLines[ x, y ] + ;
                                                     IIF( !EMPTY( aOutLines[ x, y + 1 ] ), ';', '' )
                                 bo_writeNoDupe( oHandle, cTempline + CRLF )
                                 show_out( cTempLine )
                              ELSE
                                 IF !EMPTY( aOutLines[ x, y ] )
                                    cTempline := SPACE( aLines[ x, 1 ] ) + ;
                                                        SPACE( LEN( aOutLines[ x, 1 ] ) ) + ;
                                                        aOutLines[ x, y ] + ;
                                                        IIF( x < 10 .AND. !EMPTY( aOutLines[ x, y + 1 ] ), ';', '' )
                                    bo_writeNoDupe( oHandle, cTempline + CRLF )
                                    show_out( cTempLine )
                                 ENDIF
                              ENDIF
                           NEXT
                        ELSE
                           cTempLine := ''
                           FOR y := 1 TO 10
                              cTempLine += PAD( aOutLines[ x, y ], aOutMax[ y ] )
                           NEXT
                           bo_writeNoDupe( oHandle, SPACE( aLines[ x, 1 ] ) + cTempLine + CRLF )
                           show_out( SPACE( aLines[ x, 1 ] ) + cTempLine )
                        ENDIF
                     ELSE
                        bo_writeNoDupe( oHandle, SPACE( aLines[ x, 1 ] ) + aLines[ x, 2 ] + CRLF )
                        show_out( SPACE( aLines[ x, 1 ] ) + aLines[ x, 2 ] )
                     ENDIF
                  NEXT

                  aLines := {}
                  aOutLines := {}

                  // This case aligns assignments
               CASE !lLineContinue .AND. nLineLen > 2 .AND. ;
                          PAD( aLine[ 3 ], 2 ) $ cAlignChars

                  AADD( aLines, { leadspace( cThisLine ), LTRIM( cThisLine ), aLine, aType, AT( aLine[ 3 ], cThisLine ) } )

                  cNextLine := bNextLine( oBuffObj4 )
                  aNextParse := lineparse( LTRIM( cNextLine ) )
                  aNextLine := aNextParse[ 1 ]
                  aNextType := aNextParse[ 2 ]

                  IF LEN( aNextLine ) > 2 .AND. ;
                          PAD( aNextLine[ 3 ], 2 ) $ cAlignChars .AND. ;
                          ! ASCAN( aType, 'LC' ) > 0
                     LOOP
                  ENDIF

                  nNumLines := LEN( aLines )
                  aOutLines := {}
                  nMaxLen := 0

                  FOR x := 1 TO nNumLines
                     nMaxLen := MAX( LEN( aLines[ x, 3, 1 ] ), nMaxLen )
                  NEXT

                  nMaxLen += 1

                  FOR x := 1 TO nNumLines
                     aLines[ x, 3, 2 ] := SPACE( nMaxLen - LEN( aLines[ x, 3, 1 ] ) )

                     aLines[ x, 2 ] := ''
                     nHowMany := LEN( aLines[ x, 3 ] )
                     cComment := ''
                     FOR y := 1 TO nHowMany
                        IF aLines[ x, 4, y ] == '//'
                           cComment := aLines[ x, 3, y ]
                        ELSE
                           aLines[ x, 2 ] += aLines[ x, 3, y ]
                        ENDIF
                     NEXT

                     cOutput := SPACE( aLines[ x, 1 ] ) + aLines[ x, 2 ]

                     IF !EMPTY( cComment )
                        cOutput += SPACE( nComntTab - ( LEN( cOutput ) % nComntTab ) ) + cComment
                     ENDIF

                     bo_writeNoDupe( oHandle, cOutput + CRLF )
                     show_out( SPACE( aLines[ x, 1 ] ) + aLines[ x, 2 ] )
                  NEXT

                  // was the last line continued?
                  IF ASCAN( aLines[ nNumLines, 4 ], 'LC' ) > 0
                     nShorter := aLines[ nNumLines, 5 ] - AT( aLines[ nNumLines, 3, 3 ], SPACE( aLines[ nNumLines, 1 ] ) + aLines[ nNumLines, 2 ] )

                     nShorter ++

                     DO WHILE .t.

                        cThisLine := bReadLine( oBuffObj4 )
                        // Show_Status( str( bLineNumber( oBuffObj4 ), 8 ) )
                        show_in( cThisLine )                          // str( bLineNumber( oBuffObj4 ), 8 )

                        nLeadSpace := leadspace( cThisLine )

                        DO CASE
                           CASE nLeadSpace > nShorter .AND. nShorter < 0
                              cOutput := SPACE( ABS( nShorter ) + 1 ) + cThisLine
                           CASE nLeadSpace > nShorter
                              cOutput := SUBSTR( cThisLine, nShorter )
                           OTHERWISE
                              cOutput := cThisLine
                        ENDCASE

                        /***********************************************
                        * Until I can figure out how to align comments here, I
                        * will not mess with them.
                        *
                        * if ( nPointer := rat( '//', cOutput ) ) > 0
                        *    cLeft   := trim( left( cOutput, nPointer - 1 ) )
                        *    cRight  := substr( cOutput, nPointer )
                        *    cOutput := cLeft + space( nComntTab - ( len( cLeft ) % nComntTab ) ) + cRight
                        * endif
                        ***********************************************/

                        bo_writeNoDupe( oHandle, cOutput + CRLF )
                        show_out( cOutput )

                        aParse := lineparse( LTRIM( cThisLine ) )
                        aLine := aParse[ 1 ]
                        aType := aParse[ 2 ]
                        IF ASCAN( aType, 'LC' ) == 0                  // no more continues
                           EXIT
                        ENDIF

                     ENDDO
                  ENDIF

                  aLines := {}
                  aOutLines := {}

                  // this case aligns declarations.
               CASE !lLineContinue .AND. nLineLen > 0 .AND. ;
                          aType[ 1 ] $ 'CT' .AND. ;
                          UPPER( PAD( aLine[ 1 ], 4 ) ) $ 'LOCA|STAT|PUBL|PRIV|MEMV'                                                        // Jimmy del |FIEL

                  AADD( aLines, { leadspace( cThisLine ), LTRIM( cThisLine ), aLine, aType, AT( aLine[ 3 ], cThisLine ) } )

                  cNextLine := bNextLine( oBuffObj4 )
                  aNextParse := lineparse( LTRIM( cNextLine ) )
                  aNextLine := aNextParse[ 1 ]
                  aNextType := aNextParse[ 2 ]

                  IF LEN( aNextLine ) > 0 .AND. ;
                          aNextType[ 1 ] $ 'CT' .AND. ;
                          UPPER( PAD( aNextLine[ 1 ], 4 ) ) $ 'LOCA|STAT|PUBL|PRIV|MEMV'                                                    // Jimmy del |FIEL
                     LOOP
                  ENDIF

                  nNumLines := LEN( aLines )
                  aOutLines := {}
                  nMaxLen := 0

                  FOR x := 1 TO nNumLines
                     nMaxLen := MAX( LEN( aLines[ x, 3, 1 ] + aLines[ x, 3, 2 ] + aLines[ x, 3, 3 ] ), nMaxLen )
                  NEXT

                  nMaxLen += 1

                  FOR x := 1 TO nNumLines
                     IF LEN( aLines[ x, 3 ] ) > 4 .AND. aLines[ x, 3, 5 ] == ':='
                        aLines[ x, 3, 4 ] := SPACE( nMaxLen - LEN( aLines[ x, 3, 1 ] + aLines[ x, 3, 2 ] + aLines[ x, 3, 3 ] ) )
                     ENDIF

                     aLines[ x, 2 ] := ''
                     nHowMany := LEN( aLines[ x, 3 ] )
                     FOR y := 1 TO nHowMany
                        IF aLines[ x, 4, y ] == '//'
                           nOutPad := LEN( aLines[ x, 2 ] )
                           nOutPad += nComntTab - ( nOutPad % nComntTab )
                           aLines[ x, 2 ] := PAD( aLines[ x, 2 ], nOutPad ) + aLines[ x, 3, y ]
                        ELSE
                           alines[ x, 2 ] += aLines[ x, 3, y ]
                        ENDIF
                     NEXT

                     bo_writeNoDupe( oHandle, SPACE( aLines[ x, 1 ] ) + aLines[ x, 2 ] + CRLF )
                     show_out( SPACE( aLines[ x, 1 ] ) + aLines[ x, 2 ] )
                  NEXT

                  // was the last line continued?
                  IF ASCAN( aLines[ nNumLines, 4 ], 'LC' ) > 0
                     nShorter := aLines[ nNumLines, 5 ] - AT( aLines[ nNumLines, 3, 3 ], SPACE( aLines[ nNumLines, 1 ] ) + aLines[ nNumLines, 2 ] )

                     nShorter ++

                     DO WHILE .t.
                        cThisLine := bReadLine( oBuffObj4 )
                        // Show_Status( str( bLineNumber( oBuffObj4 ), 8 ) )
                        show_in( cThisLine )                          // str( bLineNumber( oBuffObj4 ), 8 )
                        IF leadspace( cThisLine ) > nShorter
                           bo_writeNoDupe( oHandle, SUBSTR( cThisLine, nShorter ) + CRLF )
                           show_out( SUBSTR( cThisLine, nShorter ) )
                        ELSE
                           bo_writeNoDupe( oHandle, cThisLine + CRLF )
                           show_out( cThisLine )
                        ENDIF

                        aParse := lineparse( LTRIM( cThisLine ) )
                        aLine := aParse[ 1 ]
                        aType := aParse[ 2 ]
                        IF ASCAN( aType, 'LC' ) == 0                  // no more continues
                           EXIT
                        ENDIF

                     ENDDO
                  ENDIF

                  aLines := {}
                  aOutLines := {}

               OTHERWISE
                  bo_writeNoDupe( oHandle, cThisLine + CRLF )
                  show_out( cThisLine )
            END CASE

         ENDDO

         bClose( oBuffObj4 )

      ENDIF

      bo_close( oHandle )

   ENDIF

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Function Dbc_identify()
*+
*+    Called from ( click.prg )   1 - static procedure thealigner()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION Dbc_identify( aType )

LOCAL logic := .t.

   IF LEN( aType ) >= 20

      DO CASE
         CASE aType[ 1 ] != 'V'
            logic := .f.
         CASE aType[ 3 ] != 'O'
            logic := .f.
         CASE aType[ 5 ] != '+'
            logic := .f.
         CASE aType[ 7 ] != '+'
            logic := .f.
         CASE aType[ 9 ] != 'S'
            logic := .f.
         CASE aType[ 12 ] != 'S'
            logic := .f.
         CASE aType[ 15 ] != 'V'
            logic := .f.
         CASE aType[ 18 ] != 'V'
            logic := .f.
         CASE aType[ 20 ] != '-'
            logic := .f.
      ENDCASE
   ELSE
      logic := .f.
   ENDIF

RETURN logic

*+--------------------------------------------------------------------
*+
*+    Static Function IndentLevel()
*+
*+    Called from ( click.prg )   7 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION IndentLevel()

LOCAL nRet

   nRet := ( nTabIf * nIndIf )
   nRet += ( nTabFor * ( nIndFor - nUnFor ) )
   nRet += ( nTabCase * ( nIndCase - nUnCase ) )
   nRet += ( nTabFunc * nIndFunc )
   nRet += ( nTabBegin * ( nIndBegin - nUnSequence ) )
   nRet += ( nTabWhile * nIndWhile )
   nRet += ( nTabDefine * nIndDefine )                                // Jimmy
   nRet += ( nTabStart * nIndStart )                                  // Jimmy
   nRet += ( nTabTree * nIndTree )                                    // 2.05.36

RETURN nRet

*+--------------------------------------------------------------------
*+
*+    Static Procedure IndentReset()
*+
*+    Called from ( click.prg )   4 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE IndentReset()

   nIndIf := 0
   nIndFor := 0
   nIndCase := 0
   nIndFunc := 0
   nIndBegin := 0
   nIndWhile := 0
   nUnFor := 0
   nUnCase := 0
   nUnSequence := 0
   // HMG
   nIndDefine := 0                                                    // Jimmy
   nIndStart := 0                                                     // Jimmy
   nIndTree := 0                                                      // 2.05.36

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure Main_screen()
*+
*+    Called from ( click.prg )   1 - procedure main()
*+                                   2 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE Main_screen( filespec )

LOCAL cDummy

   cDummy := ' Clipper Source Code Reformatter,  harbour Version ' + CRLF
   cDummy += '' + CRLF
   cDummy += ' Working set: ' + filespec + CRLF
   cDummy += '' + CRLF
   cDummy += ' Migrated to harbour / HMG by Auge & Ohr, Jimmy ' + CRLF
   SetProperty( "ClickForm", "StatusBox", "Value", cDummy )

   cDummy := GetProperty( "ClickForm", "Title" )
   IF .NOT. CVERSION $ cDummy
      cDummy += " " + CVERSION
      SetProperty( "ClickForm", "Title", cDummy )
   ENDIF

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Function CutLine()
*+
*+    Called from ( click.prg )   1 - procedure show_in()
*+                                   1 - procedure show_out()
*+                                   1 - procedure show_status()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION CutLine( cIn )

LOCAL cOut   := ""
LOCAL i, iMax
LOCAL nLines := 8

   iMax := MLCOUNT( cIn, 80 )
   IF iMax > nLines
      FOR i := iMax - nLines TO iMax
         cOut += TRIM( MEMOLINE( cIn, 80, i ) ) + CRLF
      NEXT
   ELSE
      cOut := cIn + CRLF
   ENDIF
RETURN cOut

*+--------------------------------------------------------------------
*+
*+    Static Function ShowDir()
*+
*+    Called from ( click.prg )   4 - procedure main()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION ShowDir( cWho )

LOCAL cRet             := ""
LOCAL cTitle           := ""
LOCAL cInitPath        := ""
LOCAL lNewFolderButton := .F.

   DO CASE
      CASE cWho = "EXE"
         cTitle := "Click.EXE Folder"
         cInitPath := GetProperty( "ClickForm", "Text_EXE", "Value" )
         cInitPath := STRTRAN( cInitPath, "CLICK.EXE", "" )
         SbarText( "Click.EXE Folder" )

      CASE cWho = "SOURCE"
         cTitle := "Source Folder"
         cInitPath := GetProperty( "ClickForm", "Text_Source", "Value" )
         cInitPath := STRTRAN( cInitPath, "*.PRG", "" )
         SbarText( "Source Folder" )

      CASE cWho = "DBF"
         cTitle := "DBF Folder"
         cInitPath := GetProperty( "ClickForm", "Text_DBF", "Value" )
         cInitPath := STRTRAN( cInitPath, "CLICK.INI", "" )
         SbarText( "DBF Folder" )

      CASE cWho = "TARGET"
         cTitle := "Target Folder"
         cInitPath := GetProperty( "ClickForm", "Text_Target", "Value" )
         cInitPath := STRTRAN( cInitPath, "\CLICKOUT", "\" )
         lNewFolderButton := .T.
         SbarText( "Target Folder" )
   ENDCASE

   cRet := GetFolder( cTitle, TRIM( cInitPath ),, lNewFolderButton )

   IF !EMPTY( cRet )
      DO CASE
         CASE cWho = "EXE"
            SetProperty( "ClickForm", "Text_EXE", "Value", cRet )
         CASE cWho = "SOURCE"
            SetProperty( "ClickForm", "Text_Source", "Value", cRet )
         CASE cWho = "DBF"
            SetProperty( "ClickForm", "Text_DBF", "Value", cRet )
         CASE cWho = "TARGET"
            SetProperty( "ClickForm", "Text_Target", "Value", cRet )
      ENDCASE
   ENDIF

RETURN cRet

*+--------------------------------------------------------------------
*+
*+    Static Procedure Show_Source()
*+
*+    Called from ( click.prg )   6 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE Show_Source()

   SetProperty( "ClickForm", "Check_1", "Value", .T. )
   show_in( "Error ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" )

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure setlinecont()
*+
*+    Called from ( declbust.prg )   1 - procedure declbust()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE setlinecont( aType )                                        // Called from ( declbust.prg )

   // sets these static variables when called from declbuster.
   lLastContinue := lLineContinue
   lLineContinue := ASCAN( aType, 'LC' ) > 0
RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure CRE_INICLICK()
*+
*+    Called from ( click.prg )   2 - static procedure initmain()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE CRE_INICLICK( datei )

LOCAL field_list := {}
LOCAL cHome      := AppFolder()

   IF !FILE( datei )
      AADD( field_list, { "INIPATH", "C", 80, 0 } )
      AADD( field_list, { "SOURCEPATH", "C", 80, 0 } )
      AADD( field_list, { "TARGETPATH", "C", 80, 0 } )
      AADD( field_list, { "USE1STWIN", "L", 1, 0 } )
      DBCREATE( datei, field_list, "DBFCDX" )

      USE (datei) ALIAS "INICLICK" VIA "DBFCDX" NEW EXCLUSIV
      APPEND BLANK
      REPLACE INICLICK->INIPATH WITH cHome
      REPLACE INICLICK->SOURCEPATH WITH cHome
      REPLACE INICLICK->TARGETPATH WITH cHome + "\CLICKOUT"
      REPLACE INICLICK->USE1STWIN WITH .F.

      CLOSE
   ENDIF

RETURN

*+ EOF: CLICK.PRG
