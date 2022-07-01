#Include "hmg.ch"

Function REP_DEF() 		

   cre_select()
   use _select
      
	DEFINE WINDOW RepDefForm ;
		AT 0,0 ;
		WIDTH 400 ;  
		HEIGHT 300 ;
      TITLE 'Generate Deafult Form' ;
		MODAL 
      		
      ON KEY ESCAPE ACTION the_end_4_1()
            
		@ 010,010 COMBOBOX Combo_1 ;
			ITEMSOURCE _SELECT->DBF_NAME ;
         VALUE 1 ;
 			WIDTH 200 HEIGHT 100 ;
			FONT "Arial" SIZE 10 ; 
			TOOLTIP "Report" 

      @ 150, 100 BUTTON DEFAULT_111 ; 
         CAPTION " Create Default Report " ;
         WIDTH 200 ;
         ACTION rep_deff() 

	END WINDOW		 

	CENTER WINDOW   RepDefForm
	ACTIVATE WINDOW RepDefForm

Return
*:*********************************************************************
FUNCTION rep_deff

* LOCAL a_name[64], a_type[64], a_len[64], a_dec[64]
LOCAL mname, w_num, i, ii, w_pict, alist_fld

_key := RepDefForm.Combo_1.Value
dbcloseall()

use _select
go _key

mname = dbf_name
mname = ALLTRIM( mname )

frmname = mname

read_dir()

SELECT 5
USE _rep_apl INDEX _rep_apl

SELECT 2
USE _rep_fld INDEX _rep_fld

SELECT 1
USE _files

DELETE FOR ext != "DBF"
DELETE FOR SUBSTR(name,1,1) = "_"
PACK

SELECT 5
DELETE FOR repname = mname
PACK

w_num = 0
DO WHILE .NOT. EOF()
   IF w_num < apl_num
      w_num = apl_num
   ENDIF
   dbskip()
ENDDO
dbgotop()

w_num++
dbappend()
REPLACE repname WITH mname
REPLACE apl_num WITH w_num

SELECT 2
dbgotop()
DELETE FOR repname = mname
PACK

SELECT 3
USE &mname

* ii = AFIELDS(a_name)
* AFIELDS(a_name,a_type,a_len,a_dec)

alist_fld := DBSTRUCT()
ii = LEN( alist_fld )

SELECT 2
FOR i = 1 TO ii
   
   IF alist_fld[i][2] = 'M'
      LOOP
   ENDIF
   
   dbappend()
   REPLACE repname WITH frmname
   REPLACE dbfname WITH mname
   REPLACE fldname WITH alist_fld[i][1]
   REPLACE fldhead WITH alist_fld[i][1]
   REPLACE fldseq  WITH i
   REPLACE fldtype WITH alist_fld[i][2]
   REPLACE fldlen  WITH alist_fld[i][3]
   REPLACE flddec  WITH alist_fld[i][4]
   if fldtype = 'D'   
      REPLACE fldlen  WITH 10
   endif

   w_pict = ' '
   DO CASE
   CASE alist_fld[i][2] = 'N'
      w_pict = REPLICATE('9', alist_fld[i][3])
      IF alist_fld[i][4] > 0
         w_pict = SUBSTR(w_pict, 1, alist_fld[i][3]-alist_fld[i][4]-1 )
         w_pict = w_pict + '.' + REPLICATE('9', alist_fld[i][4] )
      ENDIF
   CASE alist_fld[i][2] = 'C'
      IF alist_fld[i][3] < 30
         w_pict = REPLICATE('X',alist_fld[i][3])
      ENDIF
   ENDCASE
   REPLACE fldpict WITH w_pict
   
   REPLACE fldatr1 WITH .T.
   REPLACE fldatr2 WITH .F.
   REPLACE fldatr3 WITH .F.
   REPLACE fldatr4 WITH .F.
   REPLACE fldatr5 WITH .F.
   REPLACE fldatr6 WITH .F.
      
   REPLACE fldduz WITH alist_fld[i][3]
   if fldtype = 'D'   
      REPLACE fldduz  WITH 10
   endif
   
NEXT

dbcloseall()
delete file _files.*

msginfo( 'Finish' )

RepDefForm.Release

RETURN 0
*:*******************************************
function the_end_4_1 ()

dbcloseall()
RepDefForm.Release

return
