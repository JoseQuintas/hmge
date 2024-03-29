//
#define _HMG_OUTLOG

#include "hmg.ch"
#include "i_winuser.ch"

#xcommand DEF BTN <name> ;
      [ ID <nId> ] ;
      [ OBJ <oBtn> ] ;
      [ GAPS <aGaps> ] ;
      [ <rows: ROWS> ] ;
      [ <cols: COLS> ] ;
      CAPTION <caption> ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ FONT <font> ] ;
      [ SIZE <size> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
    	[ <dummy5: ON INIT> <binit> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ HOTKEY <key> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <multiline: MULTILINE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
   [ <oBtn> := ] _Def_Btn ( <"name">, <.cols.>, <.rows.>, <caption>, <{action}>, ;
            <w>, <h>, <font>, <size>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
  		      <.flat.>, <.notabstop.>, <helpid>, <.invisible.> ,       ;
            <.bold.>, <.italic.>, <.underline.>, <.strikeout.>,      ;
            <.multiline.>, <.default.>, <"key">, <nId>, <aGaps>, <{binit}> )

#xcommand DEF BTN <name> ;
      [ ID <nId> ] ;
      [ OBJ <oBtn> ] ;
      [ GAPS <aGaps> ] ;
      [ <rows: ROWS> ] ;
      [ <cols: COLS> ] ;
      PICTURE <bitmap> ;
      [ ICON <icon> [ <extract: EXTRACT> <idx> ] ] ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ <notrans: NOTRANSPARENT > ] ;
      [ <noxpstyle: NOXPSTYLE > ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
    	[ <dummy5: ON INIT> <binit> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ HOTKEY <key> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
   [ <oBtn> := ] _Def_ImgBtn ( <"name">, <.cols.>, <.rows.>, "", <{action}>,   ;
		    <w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>,    ;
		    <.flat.>, <.notrans.>, <helpid>, <.invisible.>, <.notabstop.>, ;
		    <.default.>, <icon>, <.extract.>, <idx>, <.noxpstyle.>,        ;
          <"key">, <nId>, <aGaps>, <{binit}> )

#xcommand DEF BTN <name> ;
      [ ID <nId> ] ;
      [ OBJ <oBtn> ] ;
      [ GAPS <aGaps> ] ;
      [ <rows: ROWS> ] ;
      [ <cols: COLS> ] ;
      [ PICTURE <bitmap> ] ;
      ICON <icon> [ <extract: EXTRACT> <idx> ] ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ <notrans: NOTRANSPARENT > ] ;
      [ <noxpstyle: NOXPSTYLE > ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
    	[ <dummy5: ON INIT> <binit> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ HOTKEY <key> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
   [ <oBtn> := ] _Def_ImgBtn ( <"name">, <.cols.>, <.rows.>, "", <{action}>, ;
		    <w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
		    <.flat.>, <.notrans.>, <helpid>, <.invisible.>, <.notabstop.>, ;
		    <.default.>, <icon>, <.extract.>, <idx>, <.noxpstyle.>, ;
          <"key">, <nId>, <aGaps>, <{binit}> )

#xcommand DEF BTNEX <name> ;
      [ OBJ <oBtn> ] ;
      [ GAPS <aGaps> ] ;
      [ <rows: ROWS> ] ;
      [ <cols: COLS> ] ;
      [ CAPTION <caption> ] ;
      [ PICTURE <bitmap> ] ;
      [ IMAGESIZE <imagewidth> , <imageheight> ] ;
      [ ICON <icon> ] ;
      [ <vertical : VERTICAL> ] ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ FONT <font> ] ;
      [ SIZE <size> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ <lefttext : LEFTTEXT> ] ;
      [ <uptext : UPPERTEXT> ] ;
      [ <adjust : ADJUST> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ <nohotlight : NOHOTLIGHT> ] ;
      [ GRADIENTFILL <aGradInfo> [ <horizontal : HORIZONTAL> ] ] ;
      [ <flat: FLAT> ] ;
      [ <notrans: NOTRANSPARENT > ] ;
      [ <noxpstyle: NOXPSTYLE > ] ;
      [ <dummy3: ON GOTFOCUS,ON MOUSEHOVER> <gotfocus> ] ;
      [ <dummy4: ON LOSTFOCUS,ON MOUSELEAVE> <lostfocus> ] ;
    	[ <dummy5: ON INIT> <binit> ] ;
      [ <handcursor: HANDCURSOR> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
   [ <oBtn> := ] _Def_OwnBtn ( <"name">, <.cols.>, <.rows.>, <caption>, <{action}>,  ;
 	  <w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, <.flat.>,     ;
	  <.notrans.>, <helpid>, <.invisible.>, <.notabstop.>, <.default.>, <icon>, ;
	  <font>, <size>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>,       ;
	  <.vertical.>, <.lefttext.>, <.uptext.>, [ <backcolor> ], [ <fontcolor> ], ;
	  <.nohotlight.>, <.noxpstyle.>, <.adjust.>, <.handcursor.>, <imagewidth>,  ;
     <imageheight>, <aGradInfo>, <.horizontal.>, <aGaps>, <{binit}> )

#command DEF SAY <name> ;
	[ ID <nId> ] ;
   [ OBJ <oLbl> ] ;
   [ GAPS <aGaps> ] ;
   [ <rows: ROWS> ] ;
   [ <cols: COLS> ] ;
	[ VALUE <value> ] ;
	[ <dummy2: ACTION, ON CLICK, ONCLICK> <action> ] ;
	[ <dummy3: ON MOUSEHOVER, ONMOUSEHOVER> <overproc> ] ;
	[ <dummy4: ON MOUSELEAVE, ONMOUSELEAVE> <leaveproc> ] ;
  	[ <dummy5: ON INIT> <binit> ] ;
	[ WIDTH <width> ] ;
	[ HEIGHT <height> ] ;
	[ <autosize : AUTOSIZE> ] ;
	[ FONT <fontname> ] ;
	[ SIZE <fontsize> ] ;
	[ <bold : BOLD> ] ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
	[ TOOLTIP <tooltip> ] ;
	[ BACKCOLOR <backcolor> ] ;
	[ FONTCOLOR <fontcolor> ] ;
	[ <border: BORDER> ] ;
	[ <clientedge: CLIENTEDGE> ] ;
	[ <hscroll: HSCROLL> ] ;
	[ <vscroll: VSCROLL> ] ;
	[ <transparent: TRANSPARENT> ] ;
	[ <rightalign: RIGHTALIGN> ] ;
	[ <centeralign: CENTERALIGN> ] ;
	[ <vcenteralign: VCENTERALIGN> ] ;
	[ <blink: BLINK> ]  ;
	[ HELPID <helpid> ] ;
	[ <invisible: INVISIBLE> ] ;
	[ <noprefix: NOPREFIX> ] ;
=> ;
	[ <oLbl> := ] _Def_Say (    ;
	<"name">,         ;
	<.cols.>,         ;
	<.rows.>,         ;
	<value>,          ;
	<width>,          ;
	<height>,         ;
	<fontname> ,      ;
	<fontsize> ,      ;
	<.bold.>,         ;
	<.border.> ,      ;
	<.clientedge.> ,  ;
	<.hscroll.> ,     ;
	<.vscroll.> ,     ;
	<.transparent.> , ;
	[ <backcolor> ],  ;
	[ <fontcolor> ],  ;
	<{action}>,	  ;
	<tooltip>,	  ;
	<helpid>,         ;
	<.invisible.>,    ;
	<.italic.>,       ;
	<.underline.>,    ;
	<.strikeout.> ,   ;
	<.autosize.> ,    ;
	<.rightalign.> ,  ;
	<.centeralign.> , ;
	<.blink.> ,       ;
	<{overproc}>,	  ;
	<{leaveproc}>,	  ;
	<.vcenteralign.>, ;
	<.noprefix.>, ;
   <nId>, ;
   <aGaps>, ;
   <{binit}> )

#command DEF GET <name>                                        ;
                [<clauses,...>]                                ;
                RANGE <lo>, <hi>                               ;
                [<moreClauses,...>]                            ;
      =>                                                       ;
         DEF GET <name>                                        ;
                [<clauses>]                                    ;
                VALID { |_1| _RangeCheck( _1, <lo>, <hi> ) }   ;
                [<moreClauses>]

#command DEF GET <name>   ;
        [ ID <nId> ] ;
        [ OBJ <oGet> ] ;
        [ GAPS <aGaps> ] ;
        [ <rows: ROWS> ] ;
        [ <cols: COLS> ] ;
        [ HEIGHT <height> ]             ;
        [ WIDTH <width> ]               ;
        [ FIELD <field> ]               ;
        [ VALUE <value> ]               ;
        [ <dummy1: ACTION,ON CLICK,ONCLICK> <action> ] ;
        [ ACTION2 <action2> ]           ;
        [ IMAGE <abitmap> ]             ;
        [ PICTURE <cPicture> ]          ;
        [ BUTTONWIDTH <btnwidth> ]      ;
        [ VALID <valid> ]               ;
        [ VALIDMESSAGE <cValidMessage> ];
        [ WHEN <when>   ]               ;
        [ < readonly: READONLY > ]      ;
        [ FONT <fontname> ]             ;
        [ SIZE <fontsize> ]             ;
        [ <bold : BOLD> ]               ;
        [ <italic : ITALIC> ]           ;
        [ <underline : UNDERLINE> ]     ;
        [ <strikeout : STRIKEOUT> ]     ;
        [ TOOLTIP <tooltip> ]           ;
        [ BACKCOLOR <backcolor> ]       ;
        [ FONTCOLOR <fontcolor> ]       ;
        [ <password: PASSWORD> ]        ;
        [ ON GOTFOCUS <gotfocus> ]      ;
        [ ON LOSTFOCUS <lostfocus> ]    ;
        [ ON CHANGE <uChange> ]         ;
        [ MESSAGE <cMessage> ]          ;
        [ <RightAlign: RIGHTALIGN> ]    ;
  	     [ <CenterAlign: CENTERALIGN> ]	 ;
        [ <invisible: INVISIBLE> ]      ;
        [ <notabstop: NOTABSTOP> ]      ;
        [ <nominus: NOMINUS> ]          ;
        [ <noborder: NOBORDER> ]        ;
        [ <GotFocusSelect: GOTFOCUSSELECT> ] ;
        [ HELPID <helpid> ]             ;
  		  [ ON INIT <bInit> ] 		       ;
  		  [ ON DBLCLICK <dblclick> ] 		 ;
        [ ON KEY <aKeyEvent> ]          ;
   => ;
        [ <oGet> := ] _Def_Get( <"name">, <.cols.>, <.rows.>, <width>, <height>, <value>, ;
            <fontname>, <fontsize>, <tooltip>, <.password.>, <{lostfocus}>, <{gotfocus}>, <{uChange}>, ;
            <.RightAlign.>, <helpid>, <.readonly.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
            <"field">, <backcolor>, <fontcolor>, <.invisible.>, <.notabstop.>, <nId>, ;
            <{valid}>, <cPicture>, <cMessage>, <cValidMessage>, <{when}>, <{action}>, ;
            <{action2}>, <abitmap>, <btnwidth>, <.nominus.>, <.noborder.>, ;
            <.CenterAlign.>, <aGaps>, <.GotFocusSelect.>, <aKeyEvent>, ;
            <{dblclick}>, <{bInit}> )

