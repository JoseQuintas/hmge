/*
 * MiniGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-2012 Roberto Lopez <roblez@ciudad.com.ar>
 *
 * Copyright 2004-2020 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Modified Marcos Jarrin <marvijarrin@gmail.com> 11/09/2020
*/

#include "minigui.ch"
#include "i_winuser.ch"
#include "FileIo.ch"

#define PROGRAM 'DBF to HTML Wizard'
#define VERSION ' v1.02'
#define BUILT ' (August 06 2020)'
#define COPYRIGHT 'Copyright © 2020 Grigory Filatov'

#define MsgYesNo( c )  MsgYesNo( c, "Confirmation" )
#define MsgAlert( c )  MsgEXCLAMATION( c, "Attention" )

STATIC cWizIntroText := "", cFinishText := "", ;
      cBannerText := { "Select DBF file", ;
      "Select the output file" }, ;
      cSubBannerText := { "Click 'Browse' button", ;
      "Select the necessary options" }, ;
      cAddText := { " | Step 1 of 2", " | Step 2 of 2" }

STATIC cDbfName := "", cHtmlOut := "", cINIPath := "", nCodePage := 1

STATIC nSetBrdWid := 4 // border width
STATIC nSetCeelSp := 2 // cell spacing
STATIC nSetCeelPd := 4 // cell padding

STATIC cSetClrBg := "#EEEEEE" // background color
STATIC cSetClrTab := "#DDDDDD" // table background
STATIC cSetClrText := "#0000ff" // text color (for table and header text)
STATIC cSetBgImage := "" // background image (.GIF picture)

STATIC lOpenNewFile := .T., lOverWrite := .T., cTitle := ""

REQUEST DBFCDX, DBFFPT

DECLARE WINDOW Form_1
DECLARE WINDOW Form_2
DECLARE WINDOW Form_3
DECLARE WINDOW Form_4

*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*
   LOCAL cMsgExit := "Are you sure you want to exit?", ;
      cPath := cFilePath( GetModuleFileName( GetInstance() ) ), fname

   SET MULTIPLE OFF

   cWizIntroText += "This program helps you to convert your DBF files to HTML format."
   cWizIntroText += CRLF + CRLF
   cWizIntroText += "It is easy. Just follow the program instructions."
   cINIPath := cPath + "dbf2html.ini"

   IF File( cINIPath )

      BEGIN INI FILE cINIPath

         GET cDbfName SECTION "Options" ENTRY "InputFile" DEFAULT cDbfName
         GET cHtmlOut SECTION "Options" ENTRY "OutFile" DEFAULT cHtmlOut

         GET lOverWrite SECTION "Options" ENTRY "OverWrite" DEFAULT lOverWrite
         GET nCodePage SECTION "Options" ENTRY "CodePage" DEFAULT nCodePage
         GET nSetBrdWid SECTION "Options" ENTRY "BorderWidth" DEFAULT nSetBrdWid
         GET nSetCeelSp SECTION "Options" ENTRY "CellSpacing" DEFAULT nSetCeelSp
         GET nSetCeelPd SECTION "Options" ENTRY "CellPadding" DEFAULT nSetCeelPd
         GET cSetClrBg SECTION "Options" ENTRY "PageBack" DEFAULT cSetClrBg
         GET cSetClrTab SECTION "Options" ENTRY "TableBack" DEFAULT cSetClrTab
         GET cSetClrText SECTION "Options" ENTRY "TextColor" DEFAULT cSetClrText

      END INI

   ENDIF

   DEFINE WINDOW Form_0 ;
         AT 0, 0 ;
         WIDTH 0 HEIGHT 0 ;
         ICON "MAIN" ;
         MAIN NOCAPTION ;
         ON INIT ( Form_0.Hide, Form_1.Show )

      DEFINE TIMER Timer_1 INTERVAL 2000 ;
         ACTION IF( ! IsWindowVisible( GetFormHandle( "Form_1" ) ) .AND. ;
         ! IsWindowVisible( GetFormHandle( "Form_2" ) ) .AND. ;
         ! IsWindowVisible( GetFormHandle( "Form_3" ) ) .AND. ;
         ! IsWindowVisible( GetFormHandle( "Form_4" ) ), ;
         Form_0.RELEASE, )
   END WINDOW

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 500 HEIGHT 384 ;
         TITLE PROGRAM ;
         ICON "MAIN" ;
         MODAL ;
         NOSIZE ;
         ON INIT ( PaintMsgs( 1 ), Form_1.Btn_1.Setfocus ) ;
         ON GOTFOCUS OnTaskBar( 'Form_1' ) ;
         FONT 'MS Sans Serif' ;
         SIZE 9

      ON KEY ESCAPE ACTION IF( MsgYesNo( cMsgExit ), ExitMainWindow(), )

      @ 0, 0 IMAGE Image_1 ;
         PICTURE 'INTRO' ;
         WIDTH 159 ;
         HEIGHT 311

      @ 12, 172 LABEL Label_1 ;
         VALUE "Welcome to " + PROGRAM ;
         FONTCOLOR BLACK ;
         BACKCOLOR WHITE ;
         AUTOSIZE ;
         FONT 'Times New Roman' ;
         SIZE 12 BOLD

      @ 32, 170 LABEL Label_2 ;
         VALUE VERSION + BUILT ;
         FONTCOLOR { 192, 192, 192 } ;
         BACKCOLOR WHITE ;
         FONT 'Tahoma' ;
         SIZE 8 ;
         WIDTH 260 HEIGHT 12 CENTERALIGN

      @ 72, 172 LABEL Label_3 ;
         VALUE cWizIntroText ;
         BACKCOLOR WHITE ;
         WIDTH 310 HEIGHT 72

      @ 152, 220 HYPERLINK Label_4 ;
         VALUE "gfilatov@inbox.ru" ;
         ADDRESS "gfilatov@inbox.ru?cc=&bcc=" + ;
         "&subject=Dbf2Html%20Wizard%20Feedback:" ;
         BACKCOLOR WHITE ;
         WIDTH 100 HEIGHT 16 ;
         TOOLTIP "E-mail me if you have any comments or suggestions" HANDCURSOR

      @ 282, 172 LABEL Label_5 ;
         VALUE "Click 'Next' to continue." ;
         BACKCOLOR WHITE ;
         AUTOSIZE

      @ Form_1.HEIGHT -59, Form_1.WIDTH -178 BUTTON Btn_1 ;
         CAPTION '&Next >' ;
         ACTION ( Form_1.Hide, Form_2.ROW := ( Form_1.Row ), Form_2.COL := ( Form_1.Col ), ;
         Form_2.Show, IF( ! Empty( cDbfName ), MakeBrowse(), ), Form_2.Btn_1.Setfocus ) ;
         WIDTH 74 ;
         HEIGHT 23

      @ Form_1.HEIGHT -59, Form_1.WIDTH -91 BUTTON Btn_2 ;
         CAPTION 'Cancel' ;
         ACTION ExitMainWindow() ;
         WIDTH 74 ;
         HEIGHT 23

      @ Form_1.HEIGHT -59, Form_1.WIDTH -252 BUTTON Btn_3 ;
         CAPTION '< Back' ;
         ACTION _dummy() ;
         WIDTH 74 ;
         HEIGHT 23

   END WINDOW

   DEFINE WINDOW Form_2 ;
         AT 0, 0 ;
         WIDTH 500 HEIGHT 384 ;
         TITLE PROGRAM + cAddText[ 1 ] ;
         ICON "MAIN" ;
         MODAL ;
         NOSIZE ;
         ON INIT PaintMsgs( 2 ) ;
         ON GOTFOCUS OnTaskBar( 'Form_2' ) ;
         FONT 'MS Sans Serif' ;
         SIZE 9

      ON KEY ESCAPE ACTION IF( MsgYesNo( cMsgExit ), ExitMainWindow(), )

      @ 0, Form_2.WIDTH -310 IMAGE Image_1 ;
         PICTURE 'HEADER' ;
         WIDTH 304 ;
         HEIGHT 58

      @ 10, 22 LABEL Label_1 ;
         VALUE cBannerText[ 1 ] ;
         BACKCOLOR WHITE ;
         AUTOSIZE BOLD

      @ 26, 45 LABEL Label_2 ;
         VALUE cSubBannerText[ 1 ] ;
         BACKCOLOR WHITE ;
         AUTOSIZE

      @ 99, Form_2.WIDTH -102 BUTTON Btn_4 ;
         CAPTION '&Browse' ;
         ACTION ( fname := GetFile( { { "DBF files (*.dbf)", "*.dbf" }, ;
         { "All files (*.*)", "*.*" } }, "Open" ), IF( Empty( fname ), , ;
         ( cDbfName := fname, Form_2.Text_1.VALUE := cDbfName, MakeBrowse(), ;
         cHtmlOut := GenHtmlName( cDbfName ), Form_3.Text_1.VALUE := cHtmlOut, ;
         Form_2.Btn_1.Enabled := .T., Form_2.Btn_1.Setfocus ) ) ) ;
         WIDTH 76 ;
         HEIGHT 23

      @ Form_2.HEIGHT -59, Form_2.WIDTH -178 BUTTON Btn_1 ;
         CAPTION 'Next >' ;
         ACTION ( Form_2.Hide, Form_3.ROW := ( Form_2.Row ), Form_3.COL := ( Form_2.Col ), Form_3.Show, Form_3.Btn_1.Setfocus ) ;
         WIDTH 74 ;
         HEIGHT 23

      @ Form_2.HEIGHT -59, Form_2.WIDTH -91 BUTTON Btn_2 ;
         CAPTION 'Cancel' ;
         ACTION ExitMainWindow() ;
         WIDTH 74 ;
         HEIGHT 23

      @ Form_2.HEIGHT -59, Form_2.WIDTH -252 BUTTON Btn_3 ;
         CAPTION '< Back' ;
         ACTION ( Form_2.Hide, Form_1.ROW := ( Form_2.Row ), Form_1.COL := ( Form_2.Col ), Form_1.Show, Form_1.Btn_1.Setfocus ) ;
         WIDTH 74 ;
         HEIGHT 23

      @ 75, 22 LABEL Label_3 ;
         VALUE "You should enter the name of a DBF file:" ;
         AUTOSIZE

      @ 100, 22 TEXTBOX Text_1 ;
         VALUE cDbfName ;
         WIDTH 370 ;
         HEIGHT 21 ;
         ON CHANGE Form_2.Btn_1.Enabled := ! Empty( Form_2.Text_1.Value )

   END WINDOW

   DEFINE WINDOW Form_3 ;
         AT 0, 0 ;
         WIDTH 500 HEIGHT 384 ;
         TITLE PROGRAM + cAddText[ 2 ] ;
         ICON "MAIN" ;
         MODAL ;
         NOSIZE ;
         ON INIT PaintMsgs( 3 ) ;
         ON GOTFOCUS OnTaskBar( 'Form_3' ) ;
         FONT 'MS Sans Serif' ;
         SIZE 9

      ON KEY ESCAPE ACTION IF( MsgYesNo( cMsgExit ), ExitMainWindow(), )

      @ 0, Form_2.WIDTH -310 IMAGE Image_1 ;
         PICTURE 'HEADER' ;
         WIDTH 304 ;
         HEIGHT 58

      @ 10, 22 LABEL Label_1 ;
         VALUE cBannerText[ 2 ] ;
         BACKCOLOR WHITE ;
         AUTOSIZE BOLD

      @ 26, 45 LABEL Label_2 ;
         VALUE cSubBannerText[ 2 ] ;
         BACKCOLOR WHITE ;
         AUTOSIZE

      @ 99, Form_3.WIDTH -102 BUTTON Btn_4 ;
         CAPTION '&Browse' ;
         ACTION ( fname := GetFile( { { "Html files (*.html)", "*.html" }, ;
         { "All files (*.*)", "*.*" } }, "Open" ), IF( Empty( fname ), , ;
         ( cHtmlOut := fname, Form_3.Text_1.VALUE := cHtmlOut, ;
         Form_3.Btn_1.Enabled := .T., Form_3.Btn_1.Setfocus ) ) ) ;
         WIDTH 76 ;
         HEIGHT 23

      @ 140, 22 FRAME Frame_1 WIDTH 222 HEIGHT 42 OPAQUE

      @ 152, 36 CHECKBOX Check_1 ;
         CAPTION 'Overwrite existing file' ;
         WIDTH 200 ;
         HEIGHT 21 ;
         VALUE lOverWrite ;
         ON CHANGE lOverWrite := Form_3.Check_1.VALUE

      @ 134, 252 FRAME Frame_2 WIDTH 222 HEIGHT 48 OPAQUE CAPTION "Codepage"

      @ 152, 268 COMBOBOX Combo_1 WIDTH 100 HEIGHT 100 ITEMS { "As Is", "ANSI", "OEM" } VALUE nCodePage ;
         ON CHANGE nCodePage := Form_3.Combo_1.VALUE

      @ 190, 22 FRAME Frame_3 WIDTH 222 HEIGHT 104 OPAQUE CAPTION "Border"

      @ 208, 36 LABEL Label_4 ;
         VALUE 'Width' ;
         WIDTH 80 ;
         HEIGHT 23

      @ 205, 148 SPINNER Spinner_1 ;
         RANGE 0, 128 ;
         HEIGHT 23 ;
         WIDTH 64 ;
         VALUE nSetBrdWid ;
         ON CHANGE nSetBrdWid := Form_3.Spinner_1.VALUE

      @ 236, 36 LABEL Label_5 ;
         VALUE 'Cellspacing' ;
         WIDTH 80 ;
         HEIGHT 23

      @ 233, 148 SPINNER Spinner_2 ;
         RANGE 0, 128 ;
         HEIGHT 23 ;
         WIDTH 64 ;
         VALUE nSetCeelSp ;
         ON CHANGE nSetCeelSp := Form_3.Spinner_2.VALUE

      @ 264, 36 LABEL Label_6 ;
         VALUE 'Cellpadding' ;
         WIDTH 80 ;
         HEIGHT 23

      @ 261, 148 SPINNER Spinner_3 ;
         RANGE 0, 128 ;
         HEIGHT 23 ;
         WIDTH 64 ;
         VALUE nSetCeelPd ;
         ON CHANGE nSetCeelPd := Form_3.Spinner_3.VALUE

      @ 190, 252 FRAME Frame_4 WIDTH 222 HEIGHT 104 OPAQUE CAPTION "Colors"

      @ 208, 266 LABEL Label_7 ;
         VALUE 'Page Back' ;
         WIDTH 80 ;
         HEIGHT 23

      @ 205, 372 TEXTBOX Text_2 ;
         VALUE cSetClrBg ;
         WIDTH 88 ;
         HEIGHT 23 ;
         ON CHANGE cSetClrBg := Form_3.Text_2.VALUE

      @ 236, 266 LABEL Label_8 ;
         VALUE 'Table Back' ;
         WIDTH 80 ;
         HEIGHT 23

      @ 233, 372 TEXTBOX Text_3 ;
         VALUE cSetClrTab ;
         WIDTH 88 ;
         HEIGHT 23 ;
         ON CHANGE cSetClrTab := Form_3.Text_3.VALUE

      @ 264, 266 LABEL Label_9 ;
         VALUE 'Text' ;
         WIDTH 80 ;
         HEIGHT 23

      @ 261, 372 TEXTBOX Text_4 ;
         VALUE cSetClrText ;
         WIDTH 88 ;
         HEIGHT 23 ;
         ON CHANGE cSetClrText := Form_3.Text_4.VALUE

      @ Form_3.HEIGHT -59, Form_3.WIDTH -178 BUTTON Btn_1 ;
         CAPTION 'Next >' ;
         ACTION ( GenHtml(), Form_3.Hide, Form_4.ROW := ( Form_3.Row ), Form_4.COL := ( Form_3.Col ), Form_4.Show, Form_4.Btn_1.Setfocus ) ;
         WIDTH 74 ;
         HEIGHT 23

      @ Form_3.HEIGHT -59, Form_3.WIDTH -91 BUTTON Btn_2 ;
         CAPTION 'Cancel' ;
         ACTION ExitMainWindow() ;
         WIDTH 74 ;
         HEIGHT 23

      @ Form_3.HEIGHT -59, Form_3.WIDTH -252 BUTTON Btn_3 ;
         CAPTION '< Back' ;
         ACTION ( Form_3.Hide, Form_2.ROW := ( Form_3.Row ), Form_2.COL := ( Form_3.Col ), Form_2.Show, Form_2.Btn_1.Setfocus ) ;
         WIDTH 74 ;
         HEIGHT 23

      @ 75, 22 LABEL Label_3 ;
         VALUE "You should enter the name of the output file:" ;
         AUTOSIZE

      @ 100, 22 TEXTBOX Text_1 ;
         VALUE cHtmlOut ;
         WIDTH 370 ;
         HEIGHT 21 ;
         ON CHANGE ( cHtmlOut := Form_3.Text_1.VALUE, Form_3.Btn_1.Enabled := ! Empty( cHtmlOut ) )

   END WINDOW

   DEFINE WINDOW Form_4 ;
         AT 0, 0 ;
         WIDTH 500 HEIGHT 384 ;
         TITLE PROGRAM ;
         ICON "MAIN" ;
         MODAL ;
         NOSIZE ;
         ON INIT PaintMsgs( 4 ) ;
         ON GOTFOCUS OnTaskBar( 'Form_4' ) ;
         FONT 'MS Sans Serif' ;
         SIZE 9

      @ 0, 0 IMAGE Image_1 ;
         PICTURE 'INTRO' ;
         WIDTH 159 ;
         HEIGHT 311

      @ 12, 172 LABEL Label_1 ;
         VALUE "Conversion complete" ;
         FONTCOLOR BLACK ;
         BACKCOLOR WHITE ;
         AUTOSIZE ;
         FONT 'Times New Roman' ;
         SIZE 12 BOLD

      @ 72, 172 LABEL Label_2 ;
         VALUE cFinishText ;
         BACKCOLOR WHITE ;
         WIDTH 300 HEIGHT 58

      @ 132, 172 CHECKBOX Check_1 ;
         CAPTION '&Open a new file' ;
         WIDTH 300 ;
         HEIGHT 21 ;
         VALUE lOpenNewFile ;
         BACKCOLOR WHITE ;
         ON CHANGE lOpenNewFile := Form_4.Check_1.VALUE

      @ Form_4.HEIGHT -59, Form_4.WIDTH -178 BUTTON Btn_1 ;
         CAPTION '&Finish' ;
         ACTION ( SaveSettings(), ;
         IF( lOpenNewFile, _Execute( _HMG_MainHandle, "open", cHtmlOut ), ), ExitMainWindow() ) ;
         WIDTH 74 ;
         HEIGHT 23

      @ Form_4.HEIGHT -59, Form_4.WIDTH -91 BUTTON Btn_2 ;
         CAPTION '&Cancel' ;
         ACTION ExitMainWindow() ;
         WIDTH 74 ;
         HEIGHT 23

      @ Form_4.HEIGHT -59, Form_4.WIDTH -252 BUTTON Btn_3 ;
         CAPTION '< Back' ;
         ACTION _dummy() ;
         WIDTH 74 ;
         HEIGHT 23

   END WINDOW

   Form_4.Btn_3.Enabled := .F.
   Form_2.Btn_1.Enabled := ! Empty( cDbfName ) .AND. File( cDbfName )
   Form_1.Btn_3.Enabled := .F.

   CENTER WINDOW Form_1

   ACTIVATE WINDOW ALL

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE MakeBrowse( lWarning )
*--------------------------------------------------------*
   LOCAL aStruct := {}, cAlias, i, SIZE, size1
   LOCAL anames := { "iif(dbf->(Deleted()), 'X', ' ')" }
   LOCAL aheaders := { "X" }, asizes := { 20 }, ajustify := { 0 }

   DEFAULT lWarning := .T.

   IF _IsControlDefined( 'Browse_1', 'Form_2' )
      _ReleaseControl( 'Browse_1', 'Form_2' )
   ENDIF

   If ! File( cDbfName )
      RETURN
   ENDIF

   IF File( Left( cDbfName, Len( cDbfName ) - 3 ) + "fpt" )
      USE &cDBFName ALIAS dbf VIA "DBFCDX"
   ELSE
      USE &cDBFName ALIAS dbf
   ENDIF

   If ! Used()
      IF lWarning
         MsgAlert( cDBFName + CRLF + "The file have been used already." + CRLF + ;
            "Select the another filename or close the file in another application." )
      ENDIF
      RETURN
   ENDIF

   cAlias := dbf->( Alias() )
   aStruct := dbf->( dbStruct() )

   FOR i := 1 TO Len( aStruct )
      AAdd( anames, astruct[ i, 1 ] )
      AAdd( aheaders, aStruct[ i, 1 ] )
      SIZE := Len( Trim( aStruct[ i, 1 ] ) ) * if( i < 2 .AND. aStruct[ i, 2 ] == 'N', 15, 10 )
      size1 := aStruct[ i, 3 ] * if( i < 2 .AND. aStruct[ i, 2 ] == 'N', 15, 10 )
      AAdd( asizes, if( size < size1, size1, size ) )
      IF aStruct[ i, 2 ] == 'N'
         AAdd( ajustify, 1 )
      ELSE
         AAdd( ajustify, 0 )
      ENDIF
   NEXT

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
      VALUE dbf->( RecNo() )
      VSCROLLBAR dbf->( LastRec() ) > 8
      FONTNAME 'MS Sans Serif'
      FONTSIZE 8
      PAINTDOUBLEBUFFER .T.
   END BROWSE

   Form_2.Browse_1.ColumnsAutoFit()
   Form_2.Browse_1.Refresh()
   IF lWarning
      PaintMsgs( 2 )
   ENDIF

RETURN

#xtranslate FWriteLn( <xHandle>, <cString> ) => ;
      FWrite( < xHandle >, < cString > +CRLF )

*--------------------------------------------------------*
STATIC PROCEDURE GenHtml()
*--------------------------------------------------------*
   LOCAL n := 0
   LOCAL aFields
   LOCAL cValue
   LOCAL nHandle
   LOCAL nFields, nField
   LOCAL cAlign, cCell

   IF File( cHtmlOut )
      IF lOverWrite
         nHandle := FCreate( cHtmlOut, FC_NORMAL )
      ELSE
         nHandle := FOpen( cHtmlOut, FO_WRITE )
         FSeek( nHandle, 0, FS_END )
      ENDIF
   ELSE
      nHandle := FCreate( cHtmlOut, FC_NORMAL )
   ENDIF

   cTitle := cDbfName

   // -------------------
   // Writes HTML header
   // -------------------
   FWrite ( nHandle, "<!DOCTYPE html>" + CRLF )
   FWrite ( nHandle, "<html lang='en'>" + CRLF )
   FWrite ( nHandle, "<head>" + CRLF )
   FWrite ( nHandle, "   <title>" + cDbfName + "</title>" + CRLF )
   FWrite ( nHandle, '   <meta charset="utf-8"> ' + CRLF )
   FWrite ( nHandle, '   <meta name="viewport" content="width=device-width, initial-scale=1.0"> ' + CRLF )
   FWrite ( nHandle, '   <meta name="Author" CONTENT="">' + CRLF )
   FWrite ( nHandle, '   <meta name="GENERATOR" CONTENT="' + ;
      'Dbf2Html for Harbour by' + Right( COPYRIGHT, 16 ) + '">' + CRLF )

   FWrite ( nHandle, '   <link rel="stylesheet" href="css/dataTables.bootstrap4.min.css">  ' + CRLF )
   FWrite ( nHandle, '   <link rel="stylesheet" href="css/adminlte.min.css">  ' + CRLF )

   FWrite ( nHandle, "</head>" + CRLF )

   // setting colors - note than we are setting only background (BGCOLOR)
   // and text (TEXT) color, not the link colors (LINK/VLINK/ALINK)
   FWrite ( nHandle, '<body BGCOLOR="' + cSetClrBg + '"' )
   FWrite ( nHandle, ' text="' + cSetClrText + '"' )
   if ! Empty( cSetBgImage )
      // add backround image, if you specified one
      FWrite ( nHandle, ' background="' + cSetBgImage + '"' )
   ENDIF
   FWrite ( nHandle, '>' + CRLF )

   // write table title (in bold face)
   if ! Empty( cTitle )
      // FWrite (nHandle, '<CAPTION ALIGN=TOP><B>' + cTitle + '</B></CAPTION>')

      FWrite ( nHandle, '<section class="content-header">' )
      FWrite ( nHandle, '<div class="container-fluid">' )
      FWrite ( nHandle, '<div class="row mb-2">' )
      FWrite ( nHandle, '<div class="col-sm-6 text-center ">' )
      FWrite ( nHandle, '<h1> ' + cTitle + ' </h1>' )
      FWrite ( nHandle, '</div>' )
      FWrite ( nHandle, '</div>' )
      FWrite ( nHandle, '</div>' )
      FWrite ( nHandle, '</section>' )
      FWrite ( nHandle, CRLF )
   ENDIF

   nFields := FCount()

   // define table display format (border and cell look)
   // and structure (number of columns)
   FWrite ( nHandle, '<div class="row"> ' + CRLF )
   FWrite ( nHandle, '<div class="col-12"> ' + CRLF )
   FWrite ( nHandle, '<div class="card"> ' + CRLF )
   FWrite ( nHandle, '<div class="card-body"> ' + CRLF )


   FWrite ( nHandle, ' <table ' ) // don't delete space chars from end
   FWrite ( nHandle, 'bgcolor="' + cSetClrTab + '"' )
   FWrite ( nHandle, 'border=' + LTrim( Str( nSetBrdWid ) ) + ' ' )
   FWrite ( nHandle, 'frame=ALL ' )
   FWrite ( nHandle, 'CellPadding=' + LTrim( Str( nSetCeelPd ) ) + ' ' )
   FWrite ( nHandle, 'CellSpacing=' + LTrim( Str( nSetCeelSp ) ) + ' ' )
   FWrite ( nHandle, 'cols=' + LTrim( Str( nFields ) ) )
   FWrite ( nHandle, ' id="example" class="table table-bordered table-hover" ' )
   FWrite ( nHandle, '>' + CRLF )


   aFields := dbStruct()

   // output column headers

   FWrite ( nHandle, "<thead>" + CRLF )
   FWrite ( nHandle, "<tr>" + CRLF )
   FOR nField := 1 TO nFields
      cValue := FieldName( nField )
      FWrite ( nHandle, "<th colspan=1 valign= bottom >" + cValue + "</th>" + CRLF )
   NEXT
   FWrite ( nHandle, '</tr>' + CRLF )
   FWrite ( nHandle, "</thead>" + CRLF )
   FWrite ( nHandle, CRLF )

   // here comes the main loop which generate the table body
   FWrite ( nHandle, '<tbody>' + CRLF )

   dbf->( dbGoTop() )

   DO WHILE .NOT. Eof()

      FWrite ( nHandle, "<tr>" + CRLF ) // new table row

      FOR nField := 1 TO nFields

         DO CASE
         CASE aFields[ nField, 2 ] == "D"
            cValue := DToS( FieldGet( nField ) )
            IF Empty( FieldGet( nField ) ) // empty dates
               cCell := "&nbsp"
            ELSE
               cCell := cValue
            ENDIF
            cAlign := "<td align=center>"

         CASE aFields[ nField, 2 ] == "N"
            cValue := Str( FieldGet( nField ) )
            IF Empty( cValue )
               cCell := "&nbsp" // non-breaking space
            ELSE
               cCell := cValue
            ENDIF
            cAlign := "<td align=right>"

         CASE aFields[ nField, 2 ] == "L"
            cCell := If( FieldGet( nField ), "Yes", "No" )
            cAlign := "<td align=center>"

         CASE aFields[ nField, 2 ] == "C"
            IF nCodePage == 2
               cValue := hb_OEMToANSI( AllTrim( FieldGet( nField ) ) )
            ELSEIF nCodePage == 3
               cValue := hb_ANSIToOEM( AllTrim( FieldGet( nField ) ) )
            ELSE
               cValue := AllTrim( FieldGet( nField ) )
            ENDIF
            IF Empty( cValue )
               // if empty, display non-breaking space (&nbsp)
               // to prevent displaying "hole" in table
               cCell := "&nbsp"
            ELSE
               cCell := cValue
            ENDIF
            // text fields are left aligned
            cAlign := "<td Align=Left>"

         OTHERWISE
            cCell := "Memo"
            cAlign := "<td align=center>"
         ENDCASE

         FWrite ( nHandle, cAlign + cCell ) // write cell

         FWrite ( nHandle, '</td>' + CRLF )

      NEXT nField

      FWrite ( nHandle, "</tr>" + CRLF ) // end of row
      n++

      dbf->( dbSkip() )

   ENDDO

   dbCloseAll()

   // writing HTML tail
   FWrite ( nHandle, '</tbody>' + CRLF )
   FWriteLn( nHandle, "</table>" )
   FWrite ( nHandle, '</div> ' )
   FWrite ( nHandle, '</div> ' )
   FWrite ( nHandle, '</div> ' )
   FWrite ( nHandle, '</div> ' )


   FWriteLn( nHandle, '<script src="js/jquery.min.js"></script> ' )
   FWriteLn( nHandle, '<script src="js/bootstrap.bundle.min.js"></script> ' )
   FWriteLn( nHandle, '<script src="js/jquery.dataTables.min.js"></script> ' )
   FWriteLn( nHandle, '<script src="js/dataTables.bootstrap4.min.js"></script> ' )

   FWriteLn( nHandle, '<script> ' )
   FWriteLn( nHandle, '$(function () { ' )
   FWriteLn( nHandle, ' $("#example").DataTable(  { ' )
   FWriteLn( nHandle, ' "scrollX": true ' )
   FWriteLn( nHandle, '} ); ' )
   FWriteLn( nHandle, '}); ' )
   FWriteLn( nHandle, '</script> ' )


   FWriteLn( nHandle, "</body>" )
   FWriteLn( nHandle, "</html>" )
   FClose( nHandle )

   cFinishText += PROGRAM + " has finished its work."
   cFinishText += CRLF + CRLF
   cFinishText += LTrim( Str( n ) ) + " records have been imported."
   Form_4.Label_2.VALUE := cFinishText

   DO EVENTS

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE PaintMsgs( nDlg )
*--------------------------------------------------------*

   DO CASE
   CASE nDlg == 1

      DRAW RECTANGLE IN WINDOW Form_1 ;
         AT 0, 159 TO 313, 498 ;
         PENCOLOR GRAY ;
         FILLCOLOR WHITE

      DRAW LINE IN WINDOW Form_1 ;
         AT 312, 0 TO 312, 498 ;
         PENCOLOR GRAY

      DRAW LINE IN WINDOW Form_1 ;
         AT 313, 0 TO 313, 498 ;
         PENCOLOR WHITE

      Form_1.Label_1.VALUE := "Welcome to " + PROGRAM
      Form_1.Label_2.VALUE := VERSION + BUILT
      Form_1.Label_3.VALUE := cWizIntroText
      Form_1.Label_4.VALUE := "gfilatov@inbox.ru"
      Form_1.Label_5.VALUE := "Click 'Next' to continue."

   CASE nDlg == 2

      DRAW RECTANGLE IN WINDOW Form_2 ;
         AT - 2, -2 TO 59, 500 ;
         PENCOLOR GRAY ;
         FILLCOLOR WHITE

      DRAW LINE IN WINDOW Form_2 ;
         AT 59, 0 TO 59, 498 ;
         PENCOLOR WHITE

      DRAW LINE IN WINDOW Form_2 ;
         AT 312, 0 TO 312, 498 ;
         PENCOLOR GRAY

      DRAW LINE IN WINDOW Form_2 ;
         AT 313, 0 TO 313, 498 ;
         PENCOLOR WHITE

      Form_2.Label_1.VALUE := cBannerText[ 1 ]
      Form_2.Label_2.VALUE := cSubBannerText[ 1 ]
      Form_2.Image_1.PICTURE := "HEADER"

   CASE nDlg == 3

      DRAW RECTANGLE IN WINDOW Form_3 ;
         AT - 2, -2 TO 59, 500 ;
         PENCOLOR GRAY ;
         FILLCOLOR WHITE

      DRAW LINE IN WINDOW Form_3 ;
         AT 59, 0 TO 59, 498 ;
         PENCOLOR WHITE

      DRAW LINE IN WINDOW Form_3 ;
         AT 312, 0 TO 312, 498 ;
         PENCOLOR GRAY

      DRAW LINE IN WINDOW Form_3 ;
         AT 313, 0 TO 313, 498 ;
         PENCOLOR WHITE

      Form_3.Label_1.VALUE := cBannerText[ 2 ]
      Form_3.Label_2.VALUE := cSubBannerText[ 2 ]
      Form_3.Image_1.PICTURE := "HEADER"

   CASE nDlg == 4

      DRAW RECTANGLE IN WINDOW Form_4 ;
         AT 0, 159 TO 313, 498 ;
         PENCOLOR GRAY ;
         FILLCOLOR WHITE

      DRAW LINE IN WINDOW Form_4 ;
         AT 312, 0 TO 312, 498 ;
         PENCOLOR GRAY

      DRAW LINE IN WINDOW Form_4 ;
         AT 313, 0 TO 313, 498 ;
         PENCOLOR WHITE

      Form_4.Label_1.VALUE := "Conversion complete"
      Form_4.Label_2.VALUE := cFinishText

   ENDCASE

RETURN

*--------------------------------------------------------*
STATIC FUNCTION GenHtmlName( cInFile )
*--------------------------------------------------------*
   LOCAL n := 1, cOutFile := Left( cInFile, Len( cInFile ) - 4 ) + ".html"

   WHILE ( File( cOutFile ) )

      cOutFile := Left( cInFile, Len( cInFile ) - 4 ) + "-" + LTrim( Str( n ) ) + ".html"

      if ! File( cOutFile )
         EXIT
      END

      n++

      IF n > 49
         EXIT
      END
   END

RETURN cOutFile

*--------------------------------------------------------*
STATIC PROCEDURE SaveSettings()
*--------------------------------------------------------*
   SET DECIMALS TO 0

   BEGIN INI FILE cINIPath

      SET SECTION "Options" ENTRY "InputFile" TO cDbfName
      SET SECTION "Options" ENTRY "OutFile" TO cHtmlOut

      SET SECTION "Options" ENTRY "OverWrite" TO lOverWrite
      SET SECTION "Options" ENTRY "CodePage" TO nCodePage
      SET SECTION "Options" ENTRY "BorderWidth" TO nSetBrdWid
      SET SECTION "Options" ENTRY "CellSpacing" TO nSetCeelSp
      SET SECTION "Options" ENTRY "CellPadding" TO nSetCeelPd
      SET SECTION "Options" ENTRY "PageBack" TO cSetClrBg
      SET SECTION "Options" ENTRY "TableBack" TO cSetClrTab
      SET SECTION "Options" ENTRY "TextColor" TO cSetClrText

   END INI

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE ExitMainWindow()
*--------------------------------------------------------*
   PostMessage( _HMG_MainHandle, WM_CLOSE, 0, 0 )

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE OnTaskBar( cFormName )
*--------------------------------------------------------*
   ChangeStyle( GetFormHandle( cFormName ), WS_EX_APPWINDOW, , .T. )
   InvalidateRect( GetFormHandle( cFormName ), 0 )
   DoMethod( cFormName, 'SetFocus' )

RETURN

*--------------------------------------------------------*
FUNCTION cFilePath( cPathMask )
*--------------------------------------------------------*
   LOCAL n := RAt( "\", cPathMask )

RETURN If( n > 0, Upper( Left( cPathMask, n ) ), Left( cPathMask, 2 ) + "\" )
