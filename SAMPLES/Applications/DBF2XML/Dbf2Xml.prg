/*
 * MiniGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-2012 Roberto Lopez <roblez@ciudad.com.ar>
 *
 * Copyright 2004-2020 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "i_winuser.ch"
#include "FileIo.ch"

#define PROGRAM 'DBF to XML Wizard'
#define VERSION ' v1.02'
#define BUILT ' (August 06 2020)'
#define COPYRIGHT 'Copyright © 2020 Grigory Filatov'

#define MsgYesNo( c )  MsgYesNo( c, "Confirmation" )
#define MsgAlert( c )  MsgEXCLAMATION( c, "Attention" )

Static cWizIntroText := "", cFinishText := "", ;
	cBannerText := { "Select DBF file", ;
				"Select the output file" }, ;
	cSubBannerText := { "Click 'Browse' button", ;
				"Click 'Browse' button" }, ;
	cAddText := { " | Step 1 of 2", " | Step 2 of 2" }

Static cDbfName := "", cXmlOut := "", cINIPath := "", nCodePage := 1

Static lStruct := .t., lOpenNewFile := .t., lDeleteSpaces := .t., ;
       lDeleteCRLF := .t., lInformation := .t., lOverWrite := .t.

DECLARE WINDOW Form_1
DECLARE WINDOW Form_2
DECLARE WINDOW Form_3
DECLARE WINDOW Form_4

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
	Local cMsgExit := "Are you sure you want to exit?", ;
		cPath := cFilePath(GetModuleFileName(GetInstance())), fname

	cWizIntroText += "This program helps you to convert your DBF files to XML format."
	cWizIntroText += CRLF + CRLF
	cWizIntroText += "It is easy. Just follow the program instructions."
	cINIPath := cPath + "dbf2xml.ini"

	IF FILE(cINIPath)

		BEGIN INI FILE cINIPath

			GET cDbfName SECTION "Options" ENTRY "InputFile" DEFAULT cDbfName
			GET cXmlOut SECTION "Options" ENTRY "OutFile" DEFAULT cXmlOut

			GET lOverWrite SECTION "Options" ENTRY "OverWrite" DEFAULT lOverWrite
			GET nCodePage SECTION "Options" ENTRY "CodePage" DEFAULT nCodePage
			GET lStruct SECTION "Options" ENTRY "Struct" DEFAULT lStruct
			GET lInformation SECTION "Options" ENTRY "Information" DEFAULT lInformation
			GET lDeleteCRLF SECTION "Options" ENTRY "DeleteCRLF" DEFAULT lDeleteCRLF
			GET lDeleteSpaces SECTION "Options" ENTRY "DeleteSpaces" DEFAULT lDeleteSpaces

		END INI

	ENDIF

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		ICON "MAIN" ;
		MAIN NOCAPTION ;
		ON INIT ( ThisWindow.Hide, Form_1.Show )

		DEFINE TIMER Timer_1 INTERVAL 2000 ;
			ACTION IF( !IsWindowVisible(GetFormHandle("Form_1")) .AND. ;
					!IsWindowVisible(GetFormHandle("Form_2")) .AND. ;
					!IsWindowVisible(GetFormHandle("Form_3")) .AND. ;
					!IsWindowVisible(GetFormHandle("Form_4")), ;
					ThisWindow.Release, )
	END WINDOW

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 500 HEIGHT 384 ;
		TITLE PROGRAM ;
		ICON "MAIN" ;
		MODAL ;
		NOSIZE ;
		ON INIT ( PaintMsgs(1), Form_1.Btn_1.Setfocus ) ;
		ON GOTFOCUS OnTaskBar( 'Form_1' ) ;
		FONT 'MS Sans Serif'	;
		SIZE 9

		ON KEY ESCAPE ACTION IF(MsgYesNo(cMsgExit), ExitMainWindow(), )

		@ 0, 0 IMAGE Image_1 ;
			PICTURE 'INTRO' ;
			WIDTH 159 ;
			HEIGHT 311

	      @ 12,172 LABEL Label_1			;
			VALUE "Welcome to " + PROGRAM	;
			FONTCOLOR BLACK			;
			BACKCOLOR WHITE			;
			AUTOSIZE			;
			FONT 'Times New Roman'		;
			SIZE 12 BOLD

	      @ 32,170 LABEL Label_2			;
			VALUE VERSION + BUILT		;
			FONTCOLOR {192, 192, 192}	;
			BACKCOLOR WHITE			;
			FONT 'Tahoma'			;
			SIZE 8				;
			WIDTH 260 HEIGHT 12 CENTERALIGN

	      @ 72,172 LABEL Label_3			;
			VALUE cWizIntroText			;
			BACKCOLOR WHITE			;
			WIDTH 300 HEIGHT 72

		@ 152, 220 HYPERLINK Label_4				;
			VALUE "gfilatov@inbox.ru"			;
			ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +		;
				"&subject=Dbf2Xml%20Wizard%20Feedback:" 	;
			BACKCOLOR WHITE					;
			WIDTH 100 HEIGHT 16					;
			TOOLTIP "E-mail me if you have any comments or suggestions" HANDCURSOR

	      @ 282,172 LABEL Label_5			;
			VALUE "Click 'Next' to continue."	;
			BACKCOLOR WHITE			;
			AUTOSIZE

		@ Form_1.Height - 59, Form_1.Width - 178 BUTTON Btn_1 ; 
			CAPTION '&Next >' ; 
			ACTION ( Form_1.Hide, Form_2.Row := (Form_1.Row), Form_2.Col := (Form_1.Col), ;
				Form_2.Show, IF( !Empty(cDbfName), MakeBrowse(), ), Form_2.Btn_1.Setfocus ) ;
			WIDTH 74 ;
			HEIGHT 23

		@ Form_1.Height - 59, Form_1.Width - 91 BUTTON Btn_2 ; 
			CAPTION 'Cancel' ; 
			ACTION ExitMainWindow() ; 
			WIDTH 74 ; 
			HEIGHT 23

		@ Form_1.Height - 59, Form_1.Width - 252 BUTTON Btn_3 ;
			CAPTION '< Back' ; 
			ACTION _dummy() ; 
			WIDTH 74 ; 
			HEIGHT 23

	END WINDOW

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 500 HEIGHT 384 ;
		TITLE PROGRAM + cAddText[1] ;
		ICON "MAIN" ;
		MODAL ;
		NOSIZE ;
		ON INIT PaintMsgs(2) ;
		ON GOTFOCUS OnTaskBar( 'Form_2' ) ;
		FONT 'MS Sans Serif'	;
		SIZE 9

		ON KEY ESCAPE ACTION IF(MsgYesNo(cMsgExit), ExitMainWindow(), )

		@ 0, Form_2.Width - 280 IMAGE Image_1 ;
			PICTURE 'HEADER' ;
			WIDTH 279 ;
			HEIGHT 58

	      @ 10,22 LABEL Label_1			;
			VALUE cBannerText[1]		;
			BACKCOLOR WHITE			;
			AUTOSIZE BOLD

	      @ 26,45 LABEL Label_2			;
			VALUE cSubBannerText[1]		;
			BACKCOLOR WHITE			;
			AUTOSIZE

		@ 99, Form_2.Width - 102 BUTTON Btn_4 ;
			CAPTION '&Browse' ; 
			ACTION ( fname := GetFile( { {"DBF files (*.dbf)", "*.dbf"}, ;
				{"All files (*.*)", "*.*"} }, "Open" ), IF(Empty(fname), , ;
				( cDbfName := fname, Form_2.Text_1.Value := cDbfName, MakeBrowse(), ;
				cXmlOut := GenXmlName( cDbfName ), Form_3.Text_1.Value := cXmlOut, ;
				Form_2.Btn_1.Enabled := .t., Form_2.Btn_1.Setfocus )) ) ; 
			WIDTH 76 ; 
       	     	HEIGHT 23

		@ Form_2.Height - 59, Form_2.Width - 178 BUTTON Btn_1 ; 
			CAPTION 'Next >' ; 
			ACTION ( Form_2.Hide, Form_3.Row := (Form_2.Row), Form_3.Col := (Form_2.Col), Form_3.Show, Form_3.Btn_1.Setfocus ) ;
			WIDTH 74 ;
			HEIGHT 23

		@ Form_2.Height - 59, Form_2.Width - 91 BUTTON Btn_2 ; 
			CAPTION 'Cancel' ; 
			ACTION ExitMainWindow() ;
			WIDTH 74 ;
			HEIGHT 23

		@ Form_2.Height - 59, Form_2.Width - 252 BUTTON Btn_3 ;
			CAPTION '< Back' ; 
			ACTION ( Form_2.Hide, Form_1.Row := (Form_2.Row), Form_1.Col := (Form_2.Col), Form_1.Show, Form_1.Btn_1.Setfocus ) ;
			WIDTH 74 ;
			HEIGHT 23

	      @ 75,22 LABEL Label_3			;
			VALUE "You should enter the name of a DBF file:"	;
			AUTOSIZE

		@ 100,22 TEXTBOX Text_1 ; 
			VALUE cDbfName ; 
			WIDTH 370 ; 
			HEIGHT 21 ;
			ON CHANGE Form_2.Btn_1.Enabled := !Empty(Form_2.Text_1.Value)

	END WINDOW

	DEFINE WINDOW Form_3 ;
		AT 0,0 ;
		WIDTH 500 HEIGHT 384 ;
		TITLE PROGRAM + cAddText[2] ;
		ICON "MAIN" ;
		MODAL ;
		NOSIZE ;
		ON INIT PaintMsgs(3) ;
		ON GOTFOCUS OnTaskBar( 'Form_3' ) ;
		FONT 'MS Sans Serif'	;
		SIZE 9

		ON KEY ESCAPE ACTION IF(MsgYesNo(cMsgExit), ExitMainWindow(), )

		@ 0, Form_3.Width - 280 IMAGE Image_1 ;
			PICTURE 'HEADER' ;
			WIDTH 279 ;
			HEIGHT 58

	      @ 10,22 LABEL Label_1			;
			VALUE cBannerText[2]		;
			BACKCOLOR WHITE			;
			AUTOSIZE BOLD

	      @ 26,45 LABEL Label_2			;
			VALUE cSubBannerText[2]		;
			BACKCOLOR WHITE			;
			AUTOSIZE

		@ 99, Form_3.Width - 102 BUTTON Btn_4 ;
			CAPTION '&Browse' ; 
			ACTION ( fname := GetFile( { {"XML files (*.xml)", "*.xml"}, ;
				{"All files (*.*)", "*.*"} }, "Open" ), IF(Empty(fname), , ;
				( cXmlOut := fname, Form_3.Text_1.Value := cXmlOut, ;
				Form_3.Btn_1.Enabled := .t., Form_3.Btn_1.Setfocus )) ) ; 
			WIDTH 76 ; 
       	     	HEIGHT 23

		@ 142, 22 FRAME Frame_1 WIDTH 222 HEIGHT 42 OPAQUE

		@ 154, 36 CHECKBOX Check_1 ;
			CAPTION 'Overwrite existing file' ;
			WIDTH 200 ;
			HEIGHT 21 ;
			VALUE lOverWrite ;
			ON CHANGE lOverWrite := Form_3.Check_1.Value

		@ 136, 252 FRAME Frame_2 WIDTH 222 HEIGHT 48 OPAQUE CAPTION "Codepage"

		@ 154, 268 COMBOBOX Combo_1 WIDTH 100 HEIGHT 100 ITEMS {"As Is", "ANSI", "OEM"} VALUE nCodePage ;
			ON CHANGE nCodePage := Form_3.Combo_1.Value

		@ 192, 22 FRAME Frame_3 WIDTH 222 HEIGHT 64 OPAQUE

		@ 202, 36 CHECKBOX Check_2 ;
			CAPTION 'Structure' ;
			WIDTH 200 ;
			HEIGHT 21 ;
			VALUE lStruct ;
			ON CHANGE lStruct := Form_3.Check_2.Value

		@ 225, 36 CHECKBOX Check_3 ;
			CAPTION 'Information' ;
			WIDTH 200 ;
			HEIGHT 21 ;
			VALUE lInformation ;
			ON CHANGE lInformation := Form_3.Check_3.Value

		@ 192, 252 FRAME Frame_4 WIDTH 222 HEIGHT 64 OPAQUE

		@ 202, 268 CHECKBOX Check_4 ;
			CAPTION 'Remove CRLF in memo fields' ;
			WIDTH 200 ;
			HEIGHT 21 ;
			VALUE lDeleteCRLF ;
			ON CHANGE lDeleteCRLF := Form_3.Check_4.Value

		@ 225, 268 CHECKBOX Check_5 ;
			CAPTION 'Remove trailing spaces' ;
			WIDTH 200 ;
			HEIGHT 21 ;
			VALUE lDeleteSpaces ;
			ON CHANGE lDeleteSpaces := Form_3.Check_5.Value

		@ Form_3.Height - 59, Form_3.Width - 178 BUTTON Btn_1 ; 
			CAPTION 'Next >' ; 
			ACTION ( GenXML(), Form_3.Hide, Form_4.Row := (Form_3.Row), Form_4.Col := (Form_3.Col), Form_4.Show, Form_4.Btn_1.Setfocus ) ;
			WIDTH 74 ;
			HEIGHT 23

		@ Form_3.Height - 59, Form_3.Width - 91 BUTTON Btn_2 ; 
			CAPTION 'Cancel' ; 
			ACTION ExitMainWindow() ; 
			WIDTH 74 ; 
			HEIGHT 23

		@ Form_3.Height - 59, Form_3.Width - 252 BUTTON Btn_3 ;
			CAPTION '< Back' ; 
			ACTION ( Form_3.Hide, Form_2.Row := (Form_3.Row), Form_2.Col := (Form_3.Col), Form_2.Show, Form_2.Btn_1.Setfocus ) ;
			WIDTH 74 ;
			HEIGHT 23

	      @ 75,22 LABEL Label_3			;
			VALUE "You should enter the name of the output file:"	;
			AUTOSIZE

		@ 100,22 TEXTBOX Text_1 ; 
			VALUE cXmlOut ; 
			WIDTH 370 ; 
			HEIGHT 21 ;
			ON CHANGE ( cXmlOut := Form_3.Text_1.Value, Form_3.Btn_1.Enabled := !Empty(cXmlOut) )

	END WINDOW

	DEFINE WINDOW Form_4 ;
		AT 0,0 ;
		WIDTH 500 HEIGHT 384 ;
		TITLE PROGRAM ;
		ICON "MAIN" ;
		MODAL ;
		NOSIZE ;
		ON INIT PaintMsgs(4) ;
		ON GOTFOCUS OnTaskBar( 'Form_4' ) ;
		FONT 'MS Sans Serif'	;
		SIZE 9

		@ 0, 0 IMAGE Image_1 ;
			PICTURE 'INTRO' ;
			WIDTH 159 ;
			HEIGHT 311

	      @ 12,172 LABEL Label_1			;
			VALUE "Conversion complete"		;
			FONTCOLOR BLACK			;
			BACKCOLOR WHITE			;
			AUTOSIZE				;
			FONT 'Times New Roman'		;
			SIZE 12 BOLD

	      @ 72,172 LABEL Label_2			;
			VALUE cFinishText			;
			BACKCOLOR WHITE			;
			WIDTH 300 HEIGHT 72

		@ 132,172 CHECKBOX Check_1 ;
			CAPTION '&Open a new file' ;
			WIDTH 300 ;
			HEIGHT 21 ;
			VALUE lOpenNewFile ;
			BACKCOLOR WHITE ;
			ON CHANGE lOpenNewFile := Form_4.Check_1.Value

		@ Form_4.Height - 59, Form_4.Width - 178 BUTTON Btn_1 ; 
			CAPTION '&Finish' ; 
			ACTION ( SaveSettings(), ;
				IF(lOpenNewFile, _Execute( _HMG_MainHandle, "open", cXmlOut ), ), ExitMainWindow() ) ; 
			WIDTH 74 ; 
			HEIGHT 23

		@ Form_4.Height - 59, Form_4.Width - 91 BUTTON Btn_2 ; 
			CAPTION '&Cancel' ; 
			ACTION ExitMainWindow() ; 
			WIDTH 74 ; 
       	     	HEIGHT 23

		@ Form_4.Height - 59, Form_4.Width - 252 BUTTON Btn_3 ;
			CAPTION '< Back' ; 
			ACTION _dummy() ; 
			WIDTH 74 ; 
       	     	HEIGHT 23

	END WINDOW

	Form_4.Btn_3.Enabled := .f.
	Form_2.Btn_1.Enabled := !Empty(cDbfName) .AND. File(cDbfName)
	Form_1.Btn_3.Enabled := .f.

	CENTER WINDOW Form_1

	ACTIVATE WINDOW ALL

Return

*--------------------------------------------------------*
Static Procedure MakeBrowse( lWarning )
*--------------------------------------------------------*
	local astruct := {}, cAlias, i, size, size1
	local anames := {"iif( dbf->( Deleted() ), 'X', ' ' )"}
	local aheaders := {"X"}, asizes :={20}, ajustify := {0}

	DEFAULT lWarning := .t.
	If _IsControlDefined( 'Browse_1', 'Form_2' )
		_ReleaseControl( 'Browse_1', 'Form_2' )
	EndIf

	If !File(cDbfName)
		Return
	EndIf

	USE (cDBFName) ALIAS dbf

	If ! Used()
		if lWarning
			MsgAlert( cDBFName + CRLF + "The file have been used already." + CRLF + ;
				"Select the another filename or close the file in another application." )
		endif
		Return
	EndIf

	cAlias := dbf->( Alias() )
	astruct := dbf->( dbStruct() )

	for i := 1 to len(astruct)
		aadd(anames, astruct[i, 1])
		aadd(aheaders, astruct[i, 1])
		size := len(trim(astruct[i, 1])) * if(i < 2 .and. astruct[i, 2] == 'N', 15, 10)
		size1 := astruct[i, 3] * if(i < 2 .and. astruct[i, 2] == 'N', 15, 10)
		aadd(asizes, if(size < size1, size1, size))
		if astruct[i, 2] == 'N'
			aadd(ajustify, 1)
		else
			aadd(ajustify, 0)
		endif
	next

	DEFINE BROWSE Browse_1
               ROW 130
               COL 22
               WIDTH 450
               HEIGHT 160
               PARENT Form_2
               HEADERS aheaders
               WIDTHS asizes
               FIELDS anames
               JUSTIFY ajustify
               WORKAREA &cAlias
               VALUE dbf->( Recno() )
               VSCROLLBAR dbf->( LastRec() ) > 8
               FONTNAME 'MS Sans Serif'
               FONTSIZE 8
               PAINTDOUBLEBUFFER .T.
	END BROWSE

	Form_2.Browse_1.ColumnsAutoFit()
	Form_2.Browse_1.Refresh()
	if lWarning
		PaintMsgs(2)
	endif
Return

*--------------------------------------------------------*
Static Procedure GenXML()
*--------------------------------------------------------*
	LOCAL n := 0
	LOCAL aFields
	LOCAL cBuffer
	LOCAL cValue
	LOCAL nHandle
	LOCAL nFields
	LOCAL nField
	LOCAL data_type := { "Character", "Numeric", "Date", "Logical", "Memo" }

	dbf->(dbgotop())

	IF File(cXmlOut)
		IF lOverWrite
			nHandle := fCreate( cXmlOut, FC_NORMAL )
		ELSE
			IF !MsgYesNo(cXmlOut + " already exists." + CRLF + ;
				"Overwrite existing file?")
				cXmlOut := GenXmlName( cXmlOut )
			ENDIF
			nHandle := fCreate( cXmlOut, FC_NORMAL )
		ENDIF
	ELSE
		nHandle := fCreate( cXmlOut, FC_NORMAL )
	ENDIF

	//------------------
	// Writes XML header
	//------------------
	fWrite( nHandle, [<?xml version="1.0" encoding="ISO8859-1" ?>] + CRLF )
	fWrite( nHandle, Space( 0 ) + '<!-- Location: '  + cDbfName + ' -->' + CRLF )
	fWrite( nHandle, Space( 0 ) + '<Root Database="'  + cDbfName + '">' + CRLF )

	nFields := fCount()
	aFields := dbStruct()

	IF lStruct
		fWrite( nHandle, Space( 3 ) + "<Structure>" + CRLF )
		for nField := 1 to len(aFields)
			fWrite( nHandle, Space( 6 ) + "<Field>" + CRLF )
			cBuffer := Space( 9 ) + "<Field_Name>" + aFields[nField, 1] + "</Field_Name>" + CRLF
			cBuffer += Space( 9 ) + "<Field_Type>" + data_type[ AT(aFields[nField, 2], "CNDLM") ] + "</Field_Type>" + CRLF
			cBuffer += Space( 9 ) + "<Field_Len>" + Ltrim( Str( aFields[nField, 3] ) ) + "</Field_Len>" + CRLF
			cBuffer += Space( 9 ) + "<Field_Dec>" + Ltrim( Str( aFields[nField, 4] ) ) + "</Field_Dec>" + CRLF
			fWrite( nHandle, cBuffer )
			fWrite( nHandle, Space( 6 ) + "</Field>" + CRLF )
		next
		fWrite( nHandle, Space( 3 ) + "</Structure>" + CRLF )
	ENDIF
	IF lInformation
		fWrite( nHandle, Space( 3 ) + "<Information>" + CRLF )
*-----------
	DO WHILE .NOT. Eof()
		cBuffer := Space( 6 ) + "<Record>" + CRLF
		fWrite( nHandle, cBuffer )

		FOR nField := 1 TO nFields

			//-------------------
			// Beginning Record Tag
			//-------------------

			cBuffer:= Space( 9 ) + "<" + FieldName( nField ) + ">"

			DO CASE
				CASE aFields[nField, 2] == "D"
					cValue := DtoS( FieldGet( nField ) )

				CASE aFields[nField, 2] == "N"
					cValue := Ltrim( Str( FieldGet( nField ) ) )

				CASE aFields[nField, 2] == "L"
					cValue := If( FieldGet( nField ), "True", "False" )

				CASE aFields[nField, 2] == "C"
					IF lDeleteSpaces
						IF nCodePage == 2
							cValue := HB_OEMTOANSI( Alltrim( FieldGet( nField ) ) )
						ELSEIF nCodePage == 3
							cValue := HB_ANSITOOEM( Alltrim( FieldGet( nField ) ) )
						ELSE
							cValue := Alltrim( FieldGet( nField ) )
						ENDIF
					ELSE
						IF nCodePage == 2
							cValue := HB_OEMTOANSI( FieldGet( nField ) )
						ELSEIF nCodePage == 3
							cValue := HB_ANSITOOEM( FieldGet( nField ) )
						ELSE
							cValue := FieldGet( nField )
						ENDIF
					ENDIF

				OTHERWISE
					IF lDeleteCRLF
						cValue := strTran(FieldGet( nField ), CRLF, "")
					ELSE
						cValue := FieldGet( nField )
					ENDIF
			ENDCASE

			//--- Convert special characters
			cValue := strTran(cValue,"&","&amp;")
			cValue := strTran(cValue,"<","&lt;")
			cValue := strTran(cValue,">","&gt;")
			cValue := strTran(cValue,"'","&apos;")
			cValue := strTran(cValue,["],[&quot;])

			cBuffer += Alltrim( cValue )	+ ;
					"</"			+ ;
					FieldName( nField )	+ ;
					">"			+ ;
					CRLF

			fWrite( nHandle, cBuffer )

		NEXT nField

		//------------------
		// Ending Record Tag
		//------------------
		fWrite( nHandle, Space( 6 ) + "</Record>" + CRLF )
		n++

		dbf->(dbskip())

	ENDDO
*-----------
		fWrite( nHandle, Space( 3 ) + "</Information>" + CRLF )
	ENDIF

	dbCloseAll()
	fWrite( nHandle, Space(0) + "</Root>" + CRLF )
	fClose( nHandle )

	cFinishText += PROGRAM + " has finished its work."
	cFinishText += CRLF + CRLF
	cFinishText += Ltrim( Str(n) ) + " records have been imported."
	Form_4.Label_2.Value := cFinishText

	DO EVENTS

Return

*--------------------------------------------------------*
Static Procedure PaintMsgs( nDlg )
*--------------------------------------------------------*

	DO CASE
		CASE nDlg == 1

			DRAW RECTANGLE IN WINDOW Form_1 ;
				AT 0,159 TO 313,498 ;
				PENCOLOR GRAY ;
				FILLCOLOR WHITE

			DRAW LINE IN WINDOW Form_1 ;
				AT 312,0 TO 312,498 ;
				PENCOLOR GRAY

			DRAW LINE IN WINDOW Form_1 ;
				AT 313,0 TO 313,498 ;
				PENCOLOR WHITE

			Form_1.Label_1.Value := "Welcome to " + PROGRAM
			Form_1.Label_2.Value := VERSION + BUILT
			Form_1.Label_3.Value := cWizIntroText
			Form_1.Label_4.Value := "gfilatov@inbox.ru"
			Form_1.Label_5.Value := "Click 'Next' to continue."

		CASE nDlg == 2

			DRAW RECTANGLE IN WINDOW Form_2 ;
				AT -2,-2 TO 59,500 ;
				PENCOLOR GRAY ;
				FILLCOLOR WHITE

			DRAW LINE IN WINDOW Form_2 ;
				AT 59,0 TO 59,498 ;
				PENCOLOR WHITE

			DRAW LINE IN WINDOW Form_2 ;
				AT 312,0 TO 312,498 ;
				PENCOLOR GRAY

			DRAW LINE IN WINDOW Form_2 ;
				AT 313,0 TO 313,498 ;
				PENCOLOR WHITE

			Form_2.Label_1.Value := cBannerText[1]
			Form_2.Label_2.Value := cSubBannerText[1]
			Form_2.Image_1.Picture := "HEADER"

		CASE nDlg == 3

			DRAW RECTANGLE IN WINDOW Form_3 ;
				AT -2,-2 TO 59,500 ;
				PENCOLOR GRAY ;
				FILLCOLOR WHITE

			DRAW LINE IN WINDOW Form_3 ;
				AT 59,0 TO 59,498 ;
				PENCOLOR WHITE

			DRAW LINE IN WINDOW Form_3 ;
				AT 312,0 TO 312,498 ;
				PENCOLOR GRAY

			DRAW LINE IN WINDOW Form_3 ;
				AT 313,0 TO 313,498 ;
				PENCOLOR WHITE

			Form_3.Label_1.Value := cBannerText[2]
			Form_3.Label_2.Value := cSubBannerText[2]
			Form_3.Image_1.Picture := "HEADER"

		CASE nDlg == 4

			DRAW RECTANGLE IN WINDOW Form_4 ;
				AT 0,159 TO 313,498 ;
				PENCOLOR GRAY ;
				FILLCOLOR WHITE

			DRAW LINE IN WINDOW Form_4 ;
				AT 312,0 TO 312,498 ;
				PENCOLOR GRAY

			DRAW LINE IN WINDOW Form_4 ;
				AT 313,0 TO 313,498 ;
				PENCOLOR WHITE

			Form_4.Label_1.Value := "Conversion complete"
			Form_4.Label_2.Value := cFinishText

	ENDCASE

Return

*--------------------------------------------------------*
Static Function GenXmlName( cInFile )
*--------------------------------------------------------*
	LOCAL n := 1, cOutFile := Left( cInFile, LEN( cInFile ) - 4 ) + ".xml"

	WHILE ( FILE(cOutFile) )

		cOutFile := Left( cInFile, LEN( cInFile ) - 4 ) + "-" + Ltrim( Str(n) ) + ".xml"

		if !FILE(cOutFile)
			Exit
		end

		n++

		if n > 49
			Exit
		end
	END

Return cOutFile

*--------------------------------------------------------*
Static Procedure SaveSettings()
*--------------------------------------------------------*
	SET DECIMALS TO 0

	BEGIN INI FILE cINIPath

		SET SECTION "Options" ENTRY "InputFile" TO cDbfName
		SET SECTION "Options" ENTRY "OutFile" TO cXmlOut

		SET SECTION "Options" ENTRY "OverWrite" TO lOverWrite
		SET SECTION "Options" ENTRY "CodePage" TO nCodePage
		SET SECTION "Options" ENTRY "Struct" TO lStruct
		SET SECTION "Options" ENTRY "Information" TO lInformation
		SET SECTION "Options" ENTRY "DeleteCRLF" TO lDeleteCRLF
		SET SECTION "Options" ENTRY "DeleteSpaces" TO lDeleteSpaces

	END INI

Return

*--------------------------------------------------------*
Static Procedure ExitMainWindow()
*--------------------------------------------------------*
	PostMessage( _HMG_MainHandle, WM_CLOSE, 0, 0 )
Return

*--------------------------------------------------------*
Static Procedure OnTaskBar( cFormName )
*--------------------------------------------------------*
        ChangeStyle( GetFormHandle( cFormName ), WS_EX_APPWINDOW, , .T. )
	InvalidateRect( GetFormHandle( cFormName ), 0 )
	DoMethod( cFormName, 'SetFocus' )

Return

*--------------------------------------------------------*
Function cFilePath( cPathMask )
*--------------------------------------------------------*
	LOCAL n := RAt( "\", cPathMask )

Return If( n > 0, Upper( Left( cPathMask, n ) ), Left( cPathMask, 2 ) + "\" )
