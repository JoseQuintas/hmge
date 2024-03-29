#include "hmg.ch"

Procedure Main

	Set Century On
	Set Date Ansi
	Set Exclusive Off
	
	Use Test

	DEFINE WINDOW Win_1 ;
		ROW 0 ;
		COL 0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello Report' ;
		WINDOWTYPE MAIN ;
		ONINIT CreateReport()

		DEFINE MAIN MENU
			POPUP 'File'
				ITEM 'Execute Report'	ACTION ExecuteReport('Report1',.t.,.t.)
			END POPUP
		END MENU


	END WINDOW

	Win_1.Center

	Win_1.Activate

Return

Procedure CreateReport

	DEFINE REPORT Report1

		* Report Layout ***********************************************

		BEGIN LAYOUT 
			PAPERSIZE	PRINTER_PAPER_A4
			ORIENTATION	PRINTER_ORIENT_PORTRAIT 
		END LAYOUT

		* Header Band *************************************************

		BEGIN HEADER

			BANDHEIGHT	25

			BEGIN LINE
				FROMROW		23
				FROMCOL		10
				TOROW		23
				TOCOL		200 - IF(IsWinNT(), 0, 7)
				PENWIDTH	0.1
				PENCOLOR	{ 0 , 0 , 0 }
			END LINE

			BEGIN TEXT
				EXPRESSION	'Report Header'
				ROW		13
				COL		10
				WIDTH		100
				HEIGHT		10
				FONTNAME	'Arial'
				FONTSIZE	20
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left
			END TEXT

			BEGIN PICTURE
				VALUE		'hmg.jpg'
				ROW		10
				COL		189 - IF(IsWinNT(), 0, 7)
				WIDTH		11
				HEIGHT		11
				STRETCH		.F.
			END PICTURE

		END HEADER

		* Detail Band *************************************************

		BEGIN DETAIL

			BANDHEIGHT	6

			BEGIN TEXT
				EXPRESSION	Test->Code
				ROW		2
				COL		18
				WIDTH		10
				HEIGHT		10
				FONTNAME	'Arial'
				FONTSIZE	9
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left
			END TEXT

			BEGIN TEXT
				EXPRESSION	Test->First
				ROW		2	
				COL		30	
				WIDTH		60
				HEIGHT		10	
				FONTNAME	'Arial'
				FONTSIZE	9	
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left 
			END TEXT

			BEGIN TEXT
				EXPRESSION	Test->Last
				ROW		2	
				COL		70	
				WIDTH		60	
				HEIGHT		10	
				FONTNAME	'Arial'
				FONTSIZE	9	
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left 
			END TEXT

			BEGIN TEXT
				EXPRESSION	Test->Country
				ROW		2	
				COL		110	
				WIDTH		60	
				HEIGHT		10	
				FONTNAME	'Arial'
				FONTSIZE	9	
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left 
			END TEXT

			BEGIN TEXT
				EXPRESSION	Test->Province
				ROW		2	
				COL		140	
				WIDTH		60	
				HEIGHT		10	
				FONTNAME	'Arial'
				FONTSIZE	9	
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left 
			END TEXT

			BEGIN TEXT
				EXPRESSION	Test->Birth
				ROW		2	
				COL		175
				WIDTH		60	
				HEIGHT		10	
				FONTNAME	'Arial'
				FONTSIZE	9	
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left 
			END TEXT

		END DETAIL

		* Footer Band *************************************************

		BEGIN FOOTER

			BANDHEIGHT	27

			BEGIN LINE
				FROMROW		4
				FROMCOL		10	
				TOROW		4	
				TOCOL		200 - IF(IsWinNT(), 0, 7)
				PENWIDTH	0.1	
				PENCOLOR	{ 0 , 0 , 0 }	
			END LINE

			BEGIN TEXT
				EXPRESSION	'Page. No:' + Str(_PageNo)
				ROW		7	
				COL		11	
				WIDTH		100	
				HEIGHT		10	
				FONTNAME	'Arial'
				FONTSIZE	12	
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left 
			END TEXT

			BEGIN TEXT
				EXPRESSION	Date()
				ROW		7	
				COL		177 - IF(IsWinNT(), 0, 5)	
				WIDTH		30	
				HEIGHT		10	
				FONTNAME	'Arial'
				FONTSIZE	12	
				FONTBOLD	.F.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left 
			END TEXT

		END FOOTER

		* Summary Band ************************************************

		BEGIN SUMMARY

			BANDHEIGHT	30

			BEGIN TEXT
				EXPRESSION	'Total Records: ' + Str(RecCount()) + chr(13) + 'Total Pages: '  + Str(_PAGENO)
				ROW		10
				COL		20	
				WIDTH		100	
				HEIGHT		30
				FONTNAME	'Arial'
				FONTSIZE	12
				FONTBOLD	.T.
				FONTITALIC	.F.
				FONTUNDERLINE	.F.
				FONTSTRIKEOUT	.F.
				FONTCOLOR	{ 0 , 0 , 0 }
				ALIGNMENT	Left
			END TEXT

		END SUMMARY

		* Group Definition *********************************************

		BEGIN GROUP

			GROUPEXPRESSION	Test->Country

			BEGIN GROUPHEADER

				BANDHEIGHT	15

				BEGIN TEXT
					EXPRESSION	Test->Country
					ROW		5
					COL		20
					WIDTH		100
					HEIGHT		30
					FONTNAME	'Arial'
					FONTSIZE	14	
					FONTBOLD	.T.
				END TEXT

			END GROUPHEADER

			BEGIN GROUPFOOTER

				BANDHEIGHT	10

				BEGIN LINE
					FROMROW		8
					FROMCOL		50
					TOROW		8
					TOCOL		160
					PENWIDTH	0.1
					PENCOLOR	{ 0 , 0 , 0 }
				END LINE

			END GROUPFOOTER

		END GROUP

	END REPORT

Return

