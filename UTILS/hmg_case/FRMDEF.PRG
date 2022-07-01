#Include "hmg.ch"

Function Frm_DEF() 		

   cre_select()
   use _select
      
	DEFINE WINDOW FrmDefForm ;
		AT 0,0 ;
		WIDTH 400 ;  
		HEIGHT 300 ;
      TITLE 'Generate Deafult Form' ;
		MODAL 
		
      ON KEY ESCAPE ACTION the_end_3_1()
            
		@ 010,010 COMBOBOX Combo_1 ;
			ITEMSOURCE _SELECT->DBF_NAME ;
         VALUE 1 ;
 			WIDTH 200 HEIGHT 100 ;
			FONT "Arial" SIZE 10 ; 
			TOOLTIP "Form" 

      @ 150, 100 BUTTON DEFAULT_111 ; 
         CAPTION " Create Default Form " ;
         WIDTH 200 ;
         ACTION frm_deff() 

	END WINDOW		 

	CENTER WINDOW   FrmDefForm
	ACTIVATE WINDOW FrmDefForm

Return
*:*********************************************************************
FUNCTION frm_deff

LOCAL a_name[64], a_type[64], a_len[64], a_dec[64]
LOCAL i, ii, mname, w_num, _i, w_pict, w_def
LOCAL act_row, act_col, len_name, len_fild
LOCAL _pocetak, _naziv, _kraj, pomeraj

_key := FrmDefForm.Combo_1.Value
dbcloseall()

use _select 
go _key

mname = dbf_name
mname = ALLTRIM( mname )

frmname = mname

read_dir()

SELECT 6
USE _frm_dbf INDEX _frm_dbf

SELECT 5
USE _frm_apl INDEX _frm_apl

SELECT 2
USE _frm_fld INDEX _frm_fld

SELECT 1
USE _files

DELETE FOR ext != "DBF"
DELETE FOR SUBSTR(name,1,1) = "_"
PACK

SELECT 5
DELETE FOR formname = mname
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
REPLACE formname WITH mname
REPLACE apl_num  WITH w_num

SELECT 6
DELETE FOR formname = mname
PACK

dbappend()
REPLACE formname WITH mname
REPLACE dbfname  WITH mname
REPLACE dbfseq   WITH 1
REPLACE grid_w    WITH 350
REPLACE grid_h    WITH 450

SELECT 2
dbgotop()
DELETE FOR formname = mname
PACK

SELECT 3
USE &mname

ii = AFIELDS(a_name)
AFIELDS(a_name,a_type,a_len,a_dec)

act_row = 2
act_col = 2
len_name = 0
len_fild = 0
_row = 100

   SELECT 2
   FOR i = 1 TO ii
      dbappend()
      REPLACE formname WITH frmname
      REPLACE dbfname  WITH mname
      REPLACE fldname  WITH a_name[i]
      REPLACE fldlabel WITH a_name[i]
      REPLACE fldseq   WITH i
      REPLACE fldtype  WITH a_type[i]
      REPLACE fldlen   WITH a_len[i]
      REPLACE flddec   WITH a_dec[i]
      REPLACE fldrow   WITH _row
      REPLACE fldcol   WITH 520
      REPLACE labrow   WITH 0
      REPLACE labcol   WITH -100
      if fldtype = 'D'
         REPLACE fldlen   WITH 8
      endif

      w_pict = ' '
      DO CASE
      CASE a_type[i] = 'N'
         w_pict = REPLICATE('9',a_len[i])
         IF a_dec[i] > 0
            w_pict = SUBSTR(w_pict,1,a_len[i]-a_dec[i]-1)
            w_pict = w_pict + '.' + REPLICATE('9',a_dec[i])
         ENDIF
         
      CASE a_type[i] = 'C'
         IF a_len[i] < 31
            w_pict = REPLICATE('X',a_len[i])
         ENDIF
         
      CASE a_type[i] = 'M'
         w_pict = SPACE(10)
         
      ENDCASE
      REPLACE fldpict WITH w_pict
      
      DO CASE
      CASE a_type[i] = 'N'
         w_def = '0'
      CASE a_type[i] = 'D'
         w_def = 'date()'
      CASE a_type[i] = 'C'
         w_def = 'space(' + ALLTRIM(STR(a_len[i])) + ')'
      CASE a_type[i] = 'L'
         w_def = '.T.'
      CASE a_type[i] = 'M'
         w_def = 'space(10)'

      ENDCASE
      REPLACE flddef WITH w_def
      
      REPLACE fldatr1 WITH .t.
      REPLACE fldatr2 WITH .f.
      REPLACE fldatr3 WITH .t.
      REPLACE fldatr4 WITH .t.
      REPLACE fldatr5 WITH .t.
      REPLACE fldatr6 WITH .t.
      REPLACE fldatr7 WITH .f.
      REPLACE fldatr8 WITH .f.

      IF a_type[i] = 'M'
         REPLACE fldatr1 WITH .f.
         REPLACE fldatr2 WITH .f.
         REPLACE fldatr3 WITH .t.
         REPLACE fldatr4 WITH .t.
         REPLACE fldatr5 WITH .f.
         REPLACE fldatr6 WITH .f.
         REPLACE fldatr7 WITH .f.
         REPLACE fldatr8 WITH .f.

        * REPLACE rang_low WITH STR(fldrow)
        * REPLACE rang_high WITH STR(fldcol+35)
      ENDIF
      _row = _row + 30
   NEXT
   
dbcloseall()
delete file _files.*

msginfo( 'Finish' )

FrmDefForm.Release

RETURN 0
*:********************************
function the_end_3_1()

dbcloseall()
FrmDefForm.Release

return 
