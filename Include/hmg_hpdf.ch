/*----------------------------------------------------------------------------
 HMG - Harbour Windows GUI library source code

 Copyright 2002-2010 Roberto Lopez <mail.box.hmg@gmail.com>
 http://sites.google.com/site/hmgweb/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of HMG.

 The exception is that, if you link the HMG library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 HMG library code into it.

 Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2025, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2021 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#xcommand SELECT HPDFDOC <cPDFFile> ;
   [ <lOrientation    : ORIENTATION>      <nOrientation> ] ;
   [ <lPaperSize      : PAPERSIZE>      <nPaperSize> ] ;
   [ <lPaperLength    : PAPERLENGTH>      <nPaperLength> ] ;
   [ <lPaperWidth      : PAPERWIDTH>      <nPaperWidth> ] ;
=> ;
   _HMG_HPDF_INIT ( <cPDFFile>, if ( <.lOrientation.>   , <nOrientation>   , 1 ) , if ( <.lPaperSize.>   , <nPaperSize>      , 1 ) , if ( <.lPaperLength.>   , <nPaperLength>   , -999 ) , if ( <.lPaperWidth.>   , <nPaperWidth>      , -999 )   )

#xcommand SELECT HPDFDOC <cPDFFile> TO <lSuccess> ;
   [ <lOrientation    : ORIENTATION>      <nOrientation> ] ;
   [ <lPaperSize      : PAPERSIZE>      <nPaperSize> ] ;
   [ <lPaperLength    : PAPERLENGTH>      <nPaperLength> ] ;
   [ <lPaperWidth      : PAPERWIDTH>      <nPaperWidth> ] ;
=> ;
   <lSuccess> := _HMG_HPDF_INIT ( <cPDFFile>, if ( <.lOrientation.>   , <nOrientation>   , 1 ) , if ( <.lPaperSize.>   , <nPaperSize>      , 1 ) , if ( <.lPaperLength.>   , <nPaperLength>   , -999 ) , if ( <.lPaperWidth.>   , <nPaperWidth>      , -999 )   )


#xcommand START HPDFDOC ;
=> ;
_hmg_hpdf_startdoc()


#xcommand START HPDFPAGE ;
=> ;
_hmg_hpdf_startpage()


#xcommand END HPDFPAGE ;
=> ;
_hmg_hpdf_endpage()


#xcommand END HPDFDOC ;
=> ;
_hmg_hpdf_enddoc()


#xcommand ABORT HPDFDOC ;
=> ;
_hmg_hpdf_abortdoc()


#xcommand @ <Row> , <Col> HPDFPRINT [ DATA ] <cText> ;
   [ <lfont : FONT> <cFontName> ] ;
   [ <lsize : SIZE> <nFontSize> ] ;
   [ <bold : BOLD> ] ;
   [ <italic : ITALIC> ] ;
   [ <underline : UNDERLINE> ] ;
   [ <strikeout : STRIKEOUT> ] ;
   [ <angle : ANGLE> <nAngle> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ <align : CENTER,RIGHT> ] ;
   => ;
   _HMG_HPDF_PRINT ( <Row> , <Col> , <cFontName> , <nFontSize> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <cText> , <.bold.> , <.italic.> , <.underline.> , <.strikeout.> , <.lcolor.> , <.lfont.> , <.lsize.> , <"align"> , <nAngle> )


#xcommand @ <Row> , <Col> HPDFPRINT [ DATA ] <cText> ;
   TO <ToRow> , <ToCol> ;
   [ <lfont : FONT> <cFontName> ] ;
   [ <lsize : SIZE> <nFontSize> ] ;
   [ <bold : BOLD> ] ;
   [ <italic : ITALIC> ] ;
   [ <underline : UNDERLINE> ] ;
   [ <strikeout : STRIKEOUT> ] ;
   [ <angle : ANGLE> <nAngle> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ <align:CENTER,RIGHT,JUSTIFY> ] ;
   [ <wrap : WRAP> ] ;
   [ <fit : FONTSIZEFIT,HEIGHTFIT> ] ;
   [ GETBOTTOM <xVariable> ] ;
   => ;
   _HMG_HPDF_MULTILINE_PRINT ( <Row> , <Col> , <ToRow> , <ToCol> , <cFontName> , <nFontSize> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <cText> , <.bold.> , <.italic.> , <.underline.> , <.strikeout.> , <.lcolor.> , <.lfont.> , <.lsize.> , <"align"> , <nAngle> , <.wrap.> , <"fit">, <xVariable> )


#xcommand @ <nRow> , <nCol> HPDFPRINT IMAGE <cImage> ;
   WIDTH <nWidth> ;
   HEIGHT <nheight> ;
   [ <stretch : STRETCH> ] ;
   => ;
   _HMG_HPDF_IMAGE ( <cImage> , <nRow> , <nCol> , <nheight> , <nWidth> , <.stretch.> )


#xcommand @ <Row> , <Col> HPDFPRINT LINE TO <ToRow> , <ToCol> ;
   [ <lwidth : PENWIDTH> <Width> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ STYLE <cStyle:HPDFDOTTED,HPDFDASHED,HPDFDASHDOT> ] ;
   => ;
   _HMG_HPDF_LINE ( <Row> , <Col> , <ToRow> , <ToCol> , <Width> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\]  , <.lwidth.> , <.lcolor.> , <"cStyle"> )


#xcommand @ <Row> , <Col> HPDFPRINT RECTANGLE TO <ToRow> , <ToCol> ;
   [ <lwidth : PENWIDTH> <Width> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ <lfilled: FILLED> ];
   => ;
   _HMG_HPDF_RECTANGLE ( <Row> , <Col> , <ToRow> , <ToCol> , <Width> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <.lwidth.> , <.lcolor.> ,<.lfilled.>)

#xcommand @ <Row> , <Col> HPDFPRINT RECTANGLE TO <ToRow> , <ToCol> ;
   [ <lwidth : PENWIDTH> <Width> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ <lfilled: FILLED> ];
   ROUNDED ;
   [ CURVE <nCurve> ];
   => ;
   _HMG_HPDF_ROUNDRECTANGLE ( <Row> , <Col> , <ToRow> , <ToCol> , <Width> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <.lwidth.> , <.lcolor.>, <.lfilled.>, <nCurve> )


#xcommand @ <Row> , <Col> HPDFPRINT CIRCLE RADIUS <nRadius> ;
   [ <lwidth : PENWIDTH> <Width> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ <lFilled: FILLED> ];
   => ;
   _HMG_HPDF_CIRCLE ( <Row> , <Col> , <nRadius> , <Width> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\]  , <.lwidth.> , <.lcolor.> , <.lFilled.>)


#xcommand @ <Row> , <Col> HPDFPRINT ELLIPSE HORIZONTAL RADIUS <nHRadius> ;
   VERTICAL RADIUS <nVRadius> ;
   [ <lwidth : PENWIDTH> <Width> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ <lFilled: FILLED> ];
   => ;
   _HMG_HPDF_ELLIPSE ( <Row> , <Col> , <nHRadius> , <nVRadius>, <Width> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\]  , <.lwidth.> , <.lcolor.> , <.lFilled.>)


#xcommand @ <Row> , <Col> HPDFPRINT ARC RADIUS <nRadius> ;
   ANGLE FROM <nFromAngle> ;
   TO <nToAngle> ;
   [ <lwidth : PENWIDTH> <Width> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   => ;
   _HMG_HPDF_Arc ( <Row> , <Col> , <nRadius> , <nFromAngle>, <nToAngle>, <Width> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\]  , <.lwidth.> , <.lcolor.> )


#xcommand @ <Row> , <Col> HPDFPRINT CURVE FROM <nFromRow>, <nFromCol> TO <ToRow> , <ToCol> ;
   [ <lwidth : PENWIDTH> <Width> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   => ;
   _HMG_HPDF_CURVE ( <Row> , <Col> , <nFromRow>, <nFromCol>, <ToRow> , <ToCol> , <Width> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\]  , <.lwidth.> , <.lcolor.> )


#xcommand SET HPDFDOC PASSWORD OWNER <cOwnerPass> [ USER <cUserPass> ] => _HMG_HPDF_SetPassword( <cOwnerPass>, <cUserPass> )

#xcommand SET HPDFDOC COMPRESS <mode:NONE,TEXT,IMAGE,METADATA,ALL>     => _HMG_HPDF_SetCompression( <"mode"> )

#xcommand SET HPDFDOC PERMISSION TO <mode:READ,PRINT,EDIT,COPY,EDIT_ALL>     => _HMG_HPDF_SetPermission( <"mode"> )

#xcommand SET HPDFDOC PAGEMODE TO <mode:NONE,OUTLINE,THUMBS,FULL_SCREEN,EOF>     => _HMG_HPDF_SetPageMode( <"mode"> )

#xcommand SET HPDFDOC ENCODING TO <cEncoding> => _HMG_HPDF_SetEncoding( <cEncoding> )

#xcommand SET HPDFDOC ROOTOUTLINE TITLE <cTitle> NAME <cName> [ PARENT <cParent> ] => _HMG_HPDF_RootOutline( <cTitle>, <cName>, <cParent> )

#xcommand SET HPDFDOC PAGEOUTLINE TITLE <cTitle> [ NAME <cName> ] [ PARENT <cParent> ] => _HMG_HPDF_PageOutline( <cTitle>, <cParent>, <cName> )


#xcommand @ <Row> , <Col> HPDFTOOLTIP <cToolTip> ;
   ICON <cIcon:COMMENT,KEY,NOTE,HELP,NEW_PARAGRAPH,PARAGRAPH,INSERT> ;
   => ;
   _HMG_HPDF_SetTextAnnot( <Row>, <Col>, <cToolTip>, <"cIcon"> )


#xcommand INSERT HPDFPAGE BEFORE PAGE <nPage> => _HMG_HPDF_InsertPage( <nPage> )

#xcommand SELECT HPDFPAGE <nPage> => _HMG_HPDF_GoToPage( <nPage> )


#xcommand @ <Row> , <Col> HPDFPAGELINK <cLink> TO <nPage> ;
   [ <lfont : FONT> <cFontName> ] ;
   [ <lsize : SIZE> <nFontSize> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ <align:CENTER,RIGHT,JUSTIFY> ] ;
   [ <lborder: BORDER> ] ;
   [ <lwidth: WIDTH> <nwidth> ] ;
   => ;
   _HMG_HPDF_SetPageLink( <Row>, <Col>, <cLink>, <nPage>, <cFontName>, <nFontSize>, <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <"align">, <.lcolor.>, <.lfont.>, <.lsize.>, <.lborder.>, <.lwidth.>, <nwidth> )

#xcommand @ <Row> , <Col> HPDFURLLINK <cTitle> TO <cLink> ;
   [ <lfont : FONT> <cFontName> ] ;
   [ <lsize : SIZE> <nFontSize> ] ;
   [ <lcolor : COLOR> <aColor> ] ;
   [ <align:CENTER,RIGHT,JUSTIFY> ] ;
   => ;
   _HMG_HPDF_SetURLLink( <Row>, <Col>, <cTitle>, <cLink>, <cFontName>, <nFontSize>, <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <"align">, <.lcolor.>, <.lfont.>, <.lsize.> )


#xcommand @ <Row> , <Col> HPDFPRINT SKEW <cText> ;
	[ <lfont : FONT> <cFontName> ] ;
	[ <lsize : SIZE> <nFontSize> ] ;
	[ <bold : BOLD> [ IF <lBold> ] ] ;
	[ <italic : ITALIC> [ IF <lItalic> ] ] ;
	[ <lcolor : COLOR> <aColor> ] ;
	[ <align : CENTER,RIGHT> ] ;
	[ <langle : ANGLE> <nAngle> ] ;
	[ <langle2: SKEW> <nAngle2> ] ;
	=> ;
	HPDF_SkewText ( <Row> , <Col> , <cFontName> , <nFontSize> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <cText> ,;
		<.bold.> .AND. iif( HB_IsLogical(<lBold>), <lBold>, HB_IsNil(<lBold>) ) ,; 
		<.italic.> .AND. iif( HB_IsLogical(<lItalic>), <lItalic>, HB_IsNil(<lItalic>) ) ,;
		<.lcolor.> , <.lfont.> , <.lsize.> , <"align"> , <nAngle> , <nAngle2> ) 

		
#xcommand @ <Row> , <Col> HPDFPRINT SCALE <cText> ;
	[ <lfont : FONT> <cFontName> ] ;
	[ <lsize : SIZE> <nFontSize> ] ;
	[ <bold : BOLD> [ IF <lBold> ] ] ;
	[ <italic : ITALIC> [ IF <lItalic> ] ] ;
	[ <lcolor : COLOR> <aColor> ] ;
	[ <align : CENTER,RIGHT> ] ;
	[ <lxscale : XSCALE> <nxscale> ] ;
	[ <lyscale : YSCALE> <nyscale> ] ;
	=> ;
	HPDF_ScaleText ( <Row> , <Col> , <cFontName> , <nFontSize> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <cText> ,;
		<.bold.> .AND. iif( HB_IsLogical(<lBold>), <lBold>, HB_IsNil(<lBold>) ) ,; 
		<.italic.> .AND. iif( HB_IsLogical(<lItalic>), <lItalic>, HB_IsNil(<lItalic>) ) ,;
		<.lcolor.> , <.lfont.> , <.lsize.> , <"align"> , <nxscale> , <nyscale> ) 


#xcommand @ <Row> , <Col> HPDFPRINT RENDER <cText> ;
	[ <lfont : FONT> <cFontName> ] ;
	[ <lsize : SIZE> <nFontSize> ] ;
	[ <bold : BOLD> [ IF <lBold> ] ] ;
	[ <italic : ITALIC> [ IF <lItalic> ] ] ;
	[ <lcolor : COLOR> <aColor> ] ;
	[ <align : CENTER,RIGHT> ] ;
	[ <mode : FILL, STROKE, FILL_THEN_STROKE, FILL_CLIPPING, STROKE_CLIPPING, FILL_STROKE_CLIPPING> ] ; 
	[ <lrim: RIM> <nrim> ] ;
	=> ;
	HPDF_RenderText ( <Row> , <Col> , <cFontName> , <nFontSize> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <cText> ,;
		<.bold.> .AND. iif( HB_IsLogical(<lBold>), <lBold>, HB_IsNil(<lBold>) ) ,; 
		<.italic.> .AND. iif( HB_IsLogical(<lItalic>), <lItalic>, HB_IsNil(<lItalic>) ) ,;
		<.lcolor.> , <.lfont.> , <.lsize.> , <"align"> , HPDF_<mode> , <nrim> ) 


#xcommand @ <Row> , <Col> HPDFPRINT CIRCLED TEXT <cText> ;
	[ <lfont : FONT> <cFontName> ] ;
	[ <lsize : SIZE> <nFontSize> ] ;
	[ <bold : BOLD> [ IF <lBold> ] ] ;
	[ <italic : ITALIC> [ IF <lItalic> ] ] ;
	[ <lcolor : COLOR> <aColor> ] ;
 	[ <lrad : RADIUS> <nRad> ] ;
	[ <lrims: RIMS> ] ;
	[ <align : TOP, BOTTOM> ] ;
	=> ;
	HPDF_CircleText ( <Row> , <Col> , <cFontName> , <nFontSize> , <aColor>\[1\] , <aColor>\[2\] , <aColor>\[3\] , <cText> ,;
		<.bold.> .AND. iif( HB_IsLogical(<lBold>), <lBold>, HB_IsNil(<lBold>) ) ,;
		<.italic.> .AND. iif( HB_IsLogical(<lItalic>), <lItalic>, HB_IsNil(<lItalic>) ) ,;
		<.lcolor.> , <.lfont.> , <.lsize.> , <nRad> , <.lrims.> , <"align"> )


#xcommand SET HPDFINFO <attrib:AUTHOR,CREATOR,TITLE,SUBJECT,KEYWORDS,DATECREATED,DATEMODIFIED> TO <xValue> [ TIME <cTime> ] => _HMG_HPDF_SetInfo( <"attrib">, <xValue>, <cTime> )

#xcommand GET HPDFINFO <attrib:AUTHOR,CREATOR,TITLE,SUBJECT,KEYWORDS,DATECREATED,DATEMODIFIED> TO <cValue> => <cValue> := _HMG_HPDF_GetInfo( <"attrib"> )

#xcommand SET HPDFDOC PAGENUMBERING [ FROM <nPage> ] [ STYLE <cStyle:DECIMAL,ROMAN,LETTERS> ] [ <cCase:UPPER,LOWER> ] [ PREFIX <cPrefix> ] => _HMG_HPDF_SetPageLabel( <nPage>, <"cStyle">, <"cCase">, <cPrefix> )

#xcommand SET HPDFPAGE LINESPACING TO <nSpacing> => _HMG_HPDF_SetLineSpacing( <nSpacing> )

#xcommand SET HPDFPAGE DASH STYLE [ TO ] <nDashMode> => _HMG_HPDF_SetDash( <nDashMode> )

#xcommand SET HPDFPAGE ORIENTATION [ TO ] <nMode> => _HMG_HPDF_SetOrientation( <nMode> )

#xcommand SET HPDFDOC FONT NAME TO [ <cFontName> ] => _HMG_HPDF_SetFontName( <cFontName> )   

#xcommand SET HPDFDOC FONT SIZE TO [ <nFontSize> ] => _HMG_HPDF_SetFontSize( <nFontSize> )


///////////////////////////////////////////////////////////////////////////////
// PDF CONFIGURATION CONSTANTS
///////////////////////////////////////////////////////////////////////////////


* Orientation

#define HPDF_ORIENT_PORTRAIT   1
#define HPDF_ORIENT_LANDSCAPE  2

* Dash Style

#define HPDF_SOLID             0
#define HPDF_DASH              1       /* ------- */
#define HPDF_DASH2             2       /* --  --  */
#define HPDF_DASHDOT           3       /* _._._._ */

* Paper Size

#define HPDF_PAPER_FIRST                DMPAPER_LETTER
#define HPDF_PAPER_LETTER               1  /* Letter 8 1/2 x 11 in               */
#define HPDF_PAPER_LETTERSMALL          2  /* Letter Small 8 1/2 x 11 in         */
#define HPDF_PAPER_TABLOID              3  /* Tabloid 11 x 17 in                 */
#define HPDF_PAPER_LEDGER               4  /* Ledger 17 x 11 in                  */
#define HPDF_PAPER_LEGAL                5  /* Legal 8 1/2 x 14 in                */
#define HPDF_PAPER_STATEMENT            6  /* Statement 5 1/2 x 8 1/2 in         */
#define HPDF_PAPER_EXECUTIVE            7  /* Executive 7 1/4 x 10 1/2 in        */
#define HPDF_PAPER_A3                   8  /* A3 297 x 420 mm                    */
#define HPDF_PAPER_A4                   9  /* A4 210 x 297 mm                    */
#define HPDF_PAPER_A4SMALL             10  /* A4 Small 210 x 297 mm              */
#define HPDF_PAPER_A5                  11  /* A5 148 x 210 mm                    */
#define HPDF_PAPER_B4                  12  /* B4 (JIS) 250 x 354                 */
#define HPDF_PAPER_B5                  13  /* B5 (JIS) 182 x 257 mm              */
#define HPDF_PAPER_FOLIO               14  /* Folio 8 1/2 x 13 in                */
#define HPDF_PAPER_QUARTO              15  /* Quarto 215 x 275 mm                */
#define HPDF_PAPER_10X14               16  /* 10x14 in                           */
#define HPDF_PAPER_11X17               17  /* 11x17 in                           */
#define HPDF_PAPER_NOTE                18  /* Note 8 1/2 x 11 in                 */
#define HPDF_PAPER_ENV_9               19  /* Envelope #9 3 7/8 x 8 7/8          */
#define HPDF_PAPER_ENV_10              20  /* Envelope #10 4 1/8 x 9 1/2         */
#define HPDF_PAPER_ENV_11              21  /* Envelope #11 4 1/2 x 10 3/8        */
#define HPDF_PAPER_ENV_12              22  /* Envelope #12 4 \276 x 11           */
#define HPDF_PAPER_ENV_14              23  /* Envelope #14 5 x 11 1/2            */
#define HPDF_PAPER_CSHEET              24  /* C size sheet                       */
#define HPDF_PAPER_DSHEET              25  /* D size sheet                       */
#define HPDF_PAPER_ESHEET              26  /* E size sheet                       */
#define HPDF_PAPER_ENV_DL              27  /* Envelope DL 110 x 220mm            */
#define HPDF_PAPER_ENV_C5              28  /* Envelope C5 162 x 229 mm           */
#define HPDF_PAPER_ENV_C3              29  /* Envelope C3  324 x 458 mm          */
#define HPDF_PAPER_ENV_C4              30  /* Envelope C4  229 x 324 mm          */
#define HPDF_PAPER_ENV_C6              31  /* Envelope C6  114 x 162 mm          */
#define HPDF_PAPER_ENV_C65             32  /* Envelope C65 114 x 229 mm          */
#define HPDF_PAPER_ENV_B4              33  /* Envelope B4  250 x 353 mm          */
#define HPDF_PAPER_ENV_B5              34  /* Envelope B5  176 x 250 mm          */
#define HPDF_PAPER_ENV_B6              35  /* Envelope B6  176 x 125 mm          */
#define HPDF_PAPER_ENV_ITALY           36  /* Envelope 110 x 230 mm              */
#define HPDF_PAPER_ENV_MONARCH         37  /* Envelope Monarch 3.875 x 7.5 in    */
#define HPDF_PAPER_ENV_PERSONAL        38  /* 6 3/4 Envelope 3 5/8 x 6 1/2 in    */
#define HPDF_PAPER_FANFOLD_US          39  /* US Std Fanfold 14 7/8 x 11 in      */
#define HPDF_PAPER_FANFOLD_STD_GERMAN  40  /* German Std Fanfold 8 1/2 x 12 in   */
#define HPDF_PAPER_FANFOLD_LGL_GERMAN  41  /* German Legal Fanfold 8 1/2 x 13 in */
#define HPDF_PAPER_ISO_B4              42  /* B4 (ISO) 250 x 353 mm              */
#define HPDF_PAPER_JAPANESE_POSTCARD   43  /* Japanese Postcard 100 x 148 mm     */
#define HPDF_PAPER_9X11                44  /* 9 x 11 in                          */
#define HPDF_PAPER_10X11               45  /* 10 x 11 in                         */
#define HPDF_PAPER_15X11               46  /* 15 x 11 in                         */
#define HPDF_PAPER_ENV_INVITE          47  /* Envelope Invite 220 x 220 mm       */
#define HPDF_PAPER_RESERVED_48         48  /* RESERVED--DO NOT USE               */
#define HPDF_PAPER_RESERVED_49         49  /* RESERVED--DO NOT USE               */
#define HPDF_PAPER_LETTER_EXTRA        50  /* Letter Extra 9 \275 x 12 in        */
#define HPDF_PAPER_LEGAL_EXTRA         51  /* Legal Extra 9 \275 x 15 in         */
#define HPDF_PAPER_TABLOID_EXTRA       52  /* Tabloid Extra 11.69 x 18 in        */
#define HPDF_PAPER_A4_EXTRA            53  /* A4 Extra 9.27 x 12.69 in           */
#define HPDF_PAPER_LETTER_TRANSVERSE   54  /* Letter Transverse 8 \275 x 11 in   */
#define HPDF_PAPER_A4_TRANSVERSE       55  /* A4 Transverse 210 x 297 mm         */
#define HPDF_PAPER_LETTER_EXTRA_TRANSVERSE 56 /* Letter Extra Transverse 9\275 x 12 in */
#define HPDF_PAPER_A_PLUS              57  /* SuperA/SuperA/A4 227 x 356 mm      */
#define HPDF_PAPER_B_PLUS              58  /* SuperB/SuperB/A3 305 x 487 mm      */
#define HPDF_PAPER_LETTER_PLUS         59  /* Letter Plus 8.5 x 12.69 in         */
#define HPDF_PAPER_A4_PLUS             60  /* A4 Plus 210 x 330 mm               */
#define HPDF_PAPER_A5_TRANSVERSE       61  /* A5 Transverse 148 x 210 mm         */
#define HPDF_PAPER_B5_TRANSVERSE       62  /* B5 (JIS) Transverse 182 x 257 mm   */
#define HPDF_PAPER_A3_EXTRA            63  /* A3 Extra 322 x 445 mm              */
#define HPDF_PAPER_A5_EXTRA            64  /* A5 Extra 174 x 235 mm              */
#define HPDF_PAPER_B5_EXTRA            65  /* B5 (ISO) Extra 201 x 276 mm        */
#define HPDF_PAPER_A2                  66  /* A2 420 x 594 mm                    */
#define HPDF_PAPER_A3_TRANSVERSE       67  /* A3 Transverse 297 x 420 mm         */
#define HPDF_PAPER_A3_EXTRA_TRANSVERSE 68  /* A3 Extra Transverse 322 x 445 mm   */
#define HPDF_PAPER_DBL_JAPANESE_POSTCARD 69 /* Japanese Double Postcard 200 x 148 mm */
#define HPDF_PAPER_A6                  70  /* A6 105 x 148 mm                 */
#define HPDF_PAPER_JENV_KAKU2          71  /* Japanese Envelope Kaku #2       */
#define HPDF_PAPER_JENV_KAKU3          72  /* Japanese Envelope Kaku #3       */
#define HPDF_PAPER_JENV_CHOU3          73  /* Japanese Envelope Chou #3       */
#define HPDF_PAPER_JENV_CHOU4          74  /* Japanese Envelope Chou #4       */
#define HPDF_PAPER_LETTER_ROTATED      75  /* Letter Rotated 11 x 8 1/2 11 in */
#define HPDF_PAPER_A3_ROTATED          76  /* A3 Rotated 420 x 297 mm         */
#define HPDF_PAPER_A4_ROTATED          77  /* A4 Rotated 297 x 210 mm         */
#define HPDF_PAPER_A5_ROTATED          78  /* A5 Rotated 210 x 148 mm         */
#define HPDF_PAPER_B4_JIS_ROTATED      79  /* B4 (JIS) Rotated 364 x 257 mm   */
#define HPDF_PAPER_B5_JIS_ROTATED      80  /* B5 (JIS) Rotated 257 x 182 mm   */
#define HPDF_PAPER_JAPANESE_POSTCARD_ROTATED 81 /* Japanese Postcard Rotated 148 x 100 mm */
#define HPDF_PAPER_DBL_JAPANESE_POSTCARD_ROTATED 82 /* Double Japanese Postcard Rotated 148 x 200 mm */
#define HPDF_PAPER_A6_ROTATED          83  /* A6 Rotated 148 x 105 mm         */
#define HPDF_PAPER_JENV_KAKU2_ROTATED  84  /* Japanese Envelope Kaku #2 Rotated */
#define HPDF_PAPER_JENV_KAKU3_ROTATED  85  /* Japanese Envelope Kaku #3 Rotated */
#define HPDF_PAPER_JENV_CHOU3_ROTATED  86  /* Japanese Envelope Chou #3 Rotated */
#define HPDF_PAPER_JENV_CHOU4_ROTATED  87  /* Japanese Envelope Chou #4 Rotated */
#define HPDF_PAPER_B6_JIS              88  /* B6 (JIS) 128 x 182 mm           */
#define HPDF_PAPER_B6_JIS_ROTATED      89  /* B6 (JIS) Rotated 182 x 128 mm   */
#define HPDF_PAPER_12X11               90  /* 12 x 11 in                      */
#define HPDF_PAPER_JENV_YOU4           91  /* Japanese Envelope You #4        */
#define HPDF_PAPER_JENV_YOU4_ROTATED   92  /* Japanese Envelope You #4 Rotated*/
#define HPDF_PAPER_P16K                93  /* PRC 16K 146 x 215 mm            */
#define HPDF_PAPER_P32K                94  /* PRC 32K 97 x 151 mm             */
#define HPDF_PAPER_P32KBIG             95  /* PRC 32K(Big) 97 x 151 mm        */
#define HPDF_PAPER_PENV_1              96  /* PRC Envelope #1 102 x 165 mm    */
#define HPDF_PAPER_PENV_2              97  /* PRC Envelope #2 102 x 176 mm    */
#define HPDF_PAPER_PENV_3              98  /* PRC Envelope #3 125 x 176 mm    */
#define HPDF_PAPER_PENV_4              99  /* PRC Envelope #4 110 x 208 mm    */
#define HPDF_PAPER_PENV_5              100 /* PRC Envelope #5 110 x 220 mm    */
#define HPDF_PAPER_PENV_6              101 /* PRC Envelope #6 120 x 230 mm    */
#define HPDF_PAPER_PENV_7              102 /* PRC Envelope #7 160 x 230 mm    */
#define HPDF_PAPER_PENV_8              103 /* PRC Envelope #8 120 x 309 mm    */
#define HPDF_PAPER_PENV_9              104 /* PRC Envelope #9 229 x 324 mm    */
#define HPDF_PAPER_PENV_10             105 /* PRC Envelope #10 324 x 458 mm   */
#define HPDF_PAPER_P16K_ROTATED        106 /* PRC 16K Rotated                 */
#define HPDF_PAPER_P32K_ROTATED        107 /* PRC 32K Rotated                 */
#define HPDF_PAPER_P32KBIG_ROTATED     108 /* PRC 32K(Big) Rotated            */
#define HPDF_PAPER_PENV_1_ROTATED      109 /* PRC Envelope #1 Rotated 165 x 102 mm */
#define HPDF_PAPER_PENV_2_ROTATED      110 /* PRC Envelope #2 Rotated 176 x 102 mm */
#define HPDF_PAPER_PENV_3_ROTATED      111 /* PRC Envelope #3 Rotated 176 x 125 mm */
#define HPDF_PAPER_PENV_4_ROTATED      112 /* PRC Envelope #4 Rotated 208 x 110 mm */
#define HPDF_PAPER_PENV_5_ROTATED      113 /* PRC Envelope #5 Rotated 220 x 110 mm */
#define HPDF_PAPER_PENV_6_ROTATED      114 /* PRC Envelope #6 Rotated 230 x 120 mm */
#define HPDF_PAPER_PENV_7_ROTATED      115 /* PRC Envelope #7 Rotated 230 x 160 mm */
#define HPDF_PAPER_PENV_8_ROTATED      116 /* PRC Envelope #8 Rotated 309 x 120 mm */
#define HPDF_PAPER_PENV_9_ROTATED      117 /* PRC Envelope #9 Rotated 324 x 229 mm */
#define HPDF_PAPER_PENV_10_ROTATED     118 /* PRC Envelope #10 Rotated 458 x 324 mm */

#define HPDF_PAPER_USER                256
