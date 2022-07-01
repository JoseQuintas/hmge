#include <hmg.ch>
 
Function Main

  SET TOOLTIPSTYLE BALLOON
  SET CENTURY ON
  SET DELETED ON
  SET DATE GERMAN
  SET INTERACTIVECLOSE ON
  set navigation extended
  set multiple off warning 
     
DEFINE WINDOW Form_one ;
    AT 0,0 ;
    WIDTH 880 HEIGHT 660 ;
    TITLE 'HMG Case Utility'  ;
    MAIN ;
    ICON 'hmgcase' ;
    FONT 'Arial' SIZE 14   ;
    ON INIT Open_Data()  
   
    ON KEY ESCAPE ACTION DelTempData()

    DEFINE STATUSBAR FONT 'Arial' SIZE 12
       STATUSITEM 'HMG Case '  
       KEYBOARD
       DATE
       CLOCK
    END STATUSBAR

    Form_one.StatusBar.Width(2) := Form_one.StatusBar.Width(2) + 10
    Form_one.StatusBar.Width(3) := Form_one.StatusBar.Width(3) + 10
    Form_one.StatusBar.Width(4) := Form_one.StatusBar.Width(4) + 8
    Form_one.StatusBar.Width(5) := Form_one.StatusBar.Width(5) + 8

   DEFINE MAIN MENU
   
      DEFINE POPUP "Tables"
         MENUITEM "View "                ACTION dbf_view()
         SEPARATOR
         MENUITEM "Generate "            ACTION dbf_cre( 1 )
         MENUITEM "Import "              ACTION dbf_imp( 1 )
         SEPARATOR
         MENUITEM "Update "              ACTION dbf_upd()
         MENUITEM "Data folder"           ACTION edit_folder()
         SEPARATOR
         MENUITEM "Exit"                 ACTION CloseAll() 
      END POPUP

      DEFINE POPUP "Index"
         MENUITEM "Edit "                ACTION ntx_edit()
         MENUITEM "Generate "            ACTION ntx_cre( 1 )
         MENUITEM "Import "              ACTION ntx_imp( 1 )
      END POPUP

      DEFINE POPUP "Forms"
         MENUITEM "Default "             ACTION frm_def()
         MENUITEM "Edit "                ACTION frm_edt()
         MENUITEM "Generate "            ACTION frm_gen()
      END POPUP

      DEFINE POPUP "M/D Forms"
         MENUITEM "Default "             ACTION fmd_def()
         MENUITEM "Edit "                ACTION fmd_edt()
         MENUITEM "Generate "            ACTION fmd_gen()
      END POPUP
      
      DEFINE POPUP "Report"
         MENUITEM "Default "             ACTION rep_def()
         MENUITEM "Edit "                ACTION rep_edt()
         MENUITEM "Generate "            ACTION rep_gen()
         SEPARATOR
         MENUITEM "Parameters "           ACTION par_edit()
      END POPUP

      DEFINE POPUP "Project"
         MENUITEM "Aplication "          ACTION apl_apl()
         MENUITEM "Setting "              ACTION apl_set()
         MENUITEM "Menu "                ACTION apl_mnu()
         MENUITEM "SubMenu "             ACTION apl_mnus()
         SEPARATOR
         MENUITEM "Generate "            ACTION apl_gen()
         SEPARATOR
         MENUITEM "Make install"         ACTION edit_iss()
      END POPUP
     
      DEFINE POPUP "Utility"
         MENUITEM "List of function"     ACTION List_func()
         MENUITEM "List of pictures"     ACTION List_pict()
         SEPARATOR
         MENUITEM "DBF to Clipboard"     ACTION db2clip()
 	 END POPUP

      DEFINE POPUP "About"
         MENUITEM "About "               ACTION case_about()
      END POPUP
          
   END MENU
     
   @ 480,500 LABEL Label_1 ;
      WIDTH 400 HEIGHT 40 ;
      VALUE 'HMG Case for DBF' ;
      FONT 'Arial' SIZE 24 
             
  SET TOOLTIPBACKCOLOR { 193, 224, 255}
END WINDOW

    CENTER WINDOW Form_one
    ACTIVATE WINDOW Form_one

Return  
*********************************************
Procedure Open_Data()

if ! file ("_DBF.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"DBF_NAME",  "C",  8, 0})
   aadd(alist_fld,{"FIELD_SEQ", "N",  3, 0})
   aadd(alist_fld,{"FIELD_NAME","C", 10, 0})
   aadd(alist_fld,{"FIELD_TYPE","C",  1, 0})
   aadd(alist_fld,{"FIELD_LEN", "N",  3, 0})
   aadd(alist_fld,{"FIELD_DEC", "N",  2, 0})
   dbcreate("_DBF",alist_fld)
endif

if ! file ("_NTX.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"DBF_NAME",  "C",  8, 0})
   aadd(alist_fld,{"ORDER",     "N",  2, 0})
   aadd(alist_fld,{"NTX_NAME",  "C",  8, 0})
   aadd(alist_fld,{"NTX_UNIQ",  "C",  1, 0})
   aadd(alist_fld,{"KEY",       "C", 80, 0})
   dbcreate("_NTX",alist_fld)
endif

if ! file ("_FMD_APL.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FORMNAME","C",8,0})
   aadd(alist_fld,{"APL_NUM","N",3,0})
   dbcreate("_FMD_APL",alist_fld)
endif

if ! file ("_FMD_DBF.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FORMNAME","C",8,0})
   aadd(alist_fld,{"DBFNAME","C",8,0})
   aadd(alist_fld,{"DBFNAME2","C",8,0})
   aadd(alist_fld,{"DBFSEQ","N",3,0})
   dbcreate("_FMD_DBF",alist_fld)
endif

if ! file ("_FMD_FLD.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FORMNAME","C",8,0})
   aadd(alist_fld,{"BLOCK","N",2,0})
   aadd(alist_fld,{"DBFNAME","C",8,0})
   aadd(alist_fld,{"FLDSEQ","N",2,0})
   aadd(alist_fld,{"FLDNAME","C",10,0})
   aadd(alist_fld,{"FLDLABEL","C",20,0})
   aadd(alist_fld,{"FLDTYPE","C",1,0})
   aadd(alist_fld,{"FLDLEN","N",3,0})
   aadd(alist_fld,{"FLDDEC","N",2,0})
   aadd(alist_fld,{"FLDROW","N",4,0})
   aadd(alist_fld,{"FLDCOL","N",4,0})
   aadd(alist_fld,{"FLDPICT","C",30,0})
   aadd(alist_fld,{"FLDDEF","C",30,0})
   aadd(alist_fld,{"FLDATR1","L",1,0})
   aadd(alist_fld,{"FLDATR2","L",1,0})
   aadd(alist_fld,{"FLDATR3","L",1,0})
   aadd(alist_fld,{"FLDATR4","L",1,0})
   aadd(alist_fld,{"FLDATR5","L",1,0})
   aadd(alist_fld,{"FLDATR6","L",1,0})
   aadd(alist_fld,{"FLDATR7","L",1,0})
   aadd(alist_fld,{"FLDATR8","L",1,0})
   aadd(alist_fld,{"VALID_DBF","C",10,0})
   aadd(alist_fld,{"VALID_KEY","C",10,0})
   aadd(alist_fld,{"VALID_FLD","C",10,0})
   aadd(alist_fld,{"VALID_DSP","C",10,0})
   dbcreate("_FMD_FLD",alist_fld)
endif

if ! file ("_FMD_REL.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FORMNAME","C",8,0})
   aadd(alist_fld,{"SEQ","N",2,0})
   aadd(alist_fld,{"DBF1","C",10,0})
   aadd(alist_fld,{"FIELD1","C",10,0})
   aadd(alist_fld,{"DBF2","C",10,0})
   aadd(alist_fld,{"FIELD2","C",10,0})
   dbcreate("_FMD_REL",alist_fld)
endif

if ! file ("_FRM_APL.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FORMNAME",  "C",  8, 0})
   aadd(alist_fld,{"APL_NUM",   "N",  3, 0})
   dbcreate("_FRM_APL",alist_fld)
endif

if ! file ("_FRM_DBF.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FORMNAME",  "C",  8, 0})
   aadd(alist_fld,{"DBFNAME",   "C",  8, 0})
   aadd(alist_fld,{"DBFSEQ",    "N",  3, 0})
   aadd(alist_fld,{"GRID_W",    "N",  4, 0})
   aadd(alist_fld,{"GRID_H",    "N",  4, 0})
   dbcreate("_FRM_DBF",alist_fld)
endif

if ! file ("_FRM_FLD.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FORMNAME",  "C",  8, 0})
   aadd(alist_fld,{"DBFNAME",   "C",  8, 0})
   aadd(alist_fld,{"FLDSEQ",    "N",  2, 0})
   aadd(alist_fld,{"FLDNAME",   "C", 10, 0})
   aadd(alist_fld,{"FLDLABEL",  "C", 20, 0})
   aadd(alist_fld,{"FLDTYPE",   "C",  1, 0})
   aadd(alist_fld,{"FLDLEN",    "N",  3, 0})
   aadd(alist_fld,{"FLDDEC",    "N",  2, 0})
   aadd(alist_fld,{"FLDROW",    "N",  4, 0})
   aadd(alist_fld,{"FLDCOL",    "N",  4, 0})
   aadd(alist_fld,{"LABROW",    "N",  4, 0})
   aadd(alist_fld,{"LABCOL",    "N",  4, 0})
   aadd(alist_fld,{"FLDPICT",   "C", 30, 0})
   aadd(alist_fld,{"FLDDEF",    "C", 30, 0})
   aadd(alist_fld,{"FLDATR1",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR2",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR3",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR4",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR5",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR6",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR7",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR8",   "L",  1, 0})
   aadd(alist_fld,{"VALID_DBF",  "C", 10, 0})
   aadd(alist_fld,{"VALID_KEY",  "C", 10, 0})
   aadd(alist_fld,{"VALID_FLD",  "C", 10, 0})
   aadd(alist_fld,{"VALID_DSP",  "C", 10, 0})
   dbcreate("_FRM_FLD",alist_fld)
endif


if ! file ("_REP_APL.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"REPNAME",   "C",  8, 0})
   aadd(alist_fld,{"APL_NUM",   "N",  3, 0})
   dbcreate("_REP_APL",alist_fld)
endif

if ! file ("_REP_BRK.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FLDBRK",    "N",  2, 0})
   aadd(alist_fld,{"FLDSEQ",    "N",  2, 0})
   dbcreate("_REP_BRK",alist_fld)
endif

if ! file ("_REP_FLD.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"REPNAME",   "C",  8, 0})
   aadd(alist_fld,{"DBFNAME",   "C",  8, 0})
   aadd(alist_fld,{"FLDSEQ",    "N",  2, 0})
   aadd(alist_fld,{"FLDNAME",   "C", 10, 0})
   aadd(alist_fld,{"FLDTYPE",   "C",  1, 0})
   aadd(alist_fld,{"FLDLEN",    "N",  3, 0})
   aadd(alist_fld,{"FLDDEC",    "N",  2, 0})
   aadd(alist_fld,{"FLDPICT",   "C", 30, 0})
   aadd(alist_fld,{"FLDHEAD",   "C", 30, 0})
   aadd(alist_fld,{"FLDATR",    "C",  8, 0})
   aadd(alist_fld,{"FLDATR1",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR2",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR3",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR4",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR5",   "L",  1, 0})
   aadd(alist_fld,{"FLDATR6",   "L",  1, 0})
   aadd(alist_fld,{"FLDDUZ",    "N",  3, 0})
   dbcreate("_REP_FLD",alist_fld)
endif

if ! file ("_REP_REP.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FLDSEQ",    "N",  2, 0})
   aadd(alist_fld,{"FLDPOS",    "N",  3, 0})
   aadd(alist_fld,{"FLDLEN",    "N",  2, 0})
   aadd(alist_fld,{"FLDNAME",   "C", 10, 0})
   aadd(alist_fld,{"FLDTYPE",   "C",  1, 0})
   aadd(alist_fld,{"FLDPICT",   "C", 30, 0})
   aadd(alist_fld,{"FLDHEAD",   "C", 30, 0})
   aadd(alist_fld,{"FLDBREAK",  "N",  1, 0})
   aadd(alist_fld,{"FLDSUMB",   "N",  1, 0})
   aadd(alist_fld,{"FLDSUMR",   "N",  1, 0})
   dbcreate("_REP_REP",alist_fld)
endif

if ! file ("_SELECT.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"DBF_NAME",  "C",  8, 0})
   aadd(alist_fld,{"DBF_DICT",  "C",  1, 0})
   aadd(alist_fld,{"DBF_DISK",  "C",  1, 0})
   dbcreate("_SELECT",alist_fld)
endif


if ! file ("_DBF.ntx")
   use _DBF via "dbfntx"
   index on DBF_NAME+STR(FIELD_SEQ,3) to _DBF
   use 
endif

if ! file ("_NTX.ntx")
   use _NTX via "dbfntx"
   index on DBF_NAME+STR(ORDER,2) to _NTX
   use 
endif

if ! file ("_FMD_APL.ntx")
   use _FMD_APL
   index on FORMNAME to _FMD_APL
   use 
endif

if ! file ("_FMD_DBF.ntx")
   use _FMD_DBF
   index on FORMNAME to _FMD_DBF
   use 
endif

if ! file ("_FMD_FLD.ntx")
   use _FMD_FLD
   index on FORMNAME+STR(BLOCK,2)+STR(FLDSEQ,2) to _FMD_FLD
   use 
endif

if ! file ("_FMD_REL.ntx")
   use _FMD_REL
   index on FORMNAME+STR(SEQ,2) to _FMD_REL
   use 
endif

if ! file ("_FRM_APL.ntx")
   use _FRM_APL via "dbfntx"
   index on FORMNAME to _FRM_APL
   use 
endif

if ! file ("_FRM_DBF.ntx")
   use _FRM_DBF via "dbfntx"
   index on FORMNAME+STR(DBFSEQ,3) to _FRM_DBF
   use 
endif

if ! file ("_FRM_FLD.ntx")
   use _FRM_FLD via "dbfntx"
   index on FORMNAME+STR(FLDSEQ,3) to _FRM_FLD
   use 
endif

if ! file ("_REP_APL.ntx")
   use _REP_APL via "dbfntx"
   index on REPNAME to _REP_APL
   use 
endif

if ! file ("_REP_BRK.ntx")
   use _REP_BRK via "dbfntx"
   index on STR(FLDBRK,2)+STR(FLDSEQ,2) to _REP_BRK
   use 
endif

if ! file ("_REP_FLD.ntx")
   use _REP_FLD via "dbfntx"
   index on REPNAME+STR(FLDSEQ,2) to _REP_FLD
   use 
endif

if ! file ("_SELECT.ntx")
   use _SELECT via "dbfntx"
   index on DBF_NAME to _SELECT
   use 
endif

open_folder()

use _dbf index _dbf
if reccount() = 0
   dbf_imp( 0 )
endif

use _ntx index _ntx
if reccount() = 0
   ntx_imp( 0 )
endif

dbf_cre( 0 )
ntx_cre( 0 )

Return
*********************************************
Procedure DelTempData

*msginfo('Del Temp Data')

dbcloseall()

del ('_*.ntx')

Form_one.Release

return
*********************************************
Procedure CloseAll()

Close all
Form_one.Release

Return
********************************************
procedure case_about

        // Local variable declaration.-----------------------------------------
        LOCAL cMessage := ""

        // Shows the about window.---------------------------------------------
        cMessage := CRLF
        cMessage += "HMG CASE" + CRLF
        cMessage += "tool for generate programs" + CRLF
        cMessage += "(data dictionary, forms, reports, menu and other)" + CRLF
        cMessage += "(c) 2014-2021" + CRLF
        cMessage += CRLF
        cMessage += "created by Dragan Čizmarević" + CRLF
        cMessage += "dragancesu(at)gmail.com" + CRLF
        cMessage += CRLF
        cMessage += "Please report bugs to HMG forum" + CRLF
        MsgInfo( cMessage, "About" )

return 0
********************************************
procedure radise

msginfo ( 'Under construction ...' )

return 0
