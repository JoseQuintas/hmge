#Include "hmg.ch"

static  aGrid := {}

Function Fmd_DEF() 		

   cre_select()
   sel_work()
   
   use _sel_det new
   zap 
   dbappend()
   replace fld_name with '<none>'  
  
   use _sel_mas new
   zap
   dbappend()
   replace fld_name with '<none>'  
   
   use _dbf new
   use _select new
      
	DEFINE WINDOW FmdDefForm ;
		AT 0,0 ;
		WIDTH 400 ;  
		HEIGHT 400 ;
        TITLE 'Generate Master/Detail default Form' ;
		MODAL
      		
      ON KEY ESCAPE ACTION the_end_3m_1()
            
      @ 10, 10 label _dbf1 value "Master"     
      @ 10, 200 label _dbf2 value "Detail"  
      @ 70, 10 label _rel value "Relation"   
      
      @ 30,10 COMBOBOX Combo_1 ;
         ITEMSOURCE _SELECT->DBF_NAME ;
         VALUE 1 ;
         WIDTH 150 HEIGHT 100 ;
         FONT "Arial" SIZE 10 ; 
         ON LOSTFOCUS upd_mas() 

      @ 30,200 COMBOBOX Combo_2 ;
         ITEMSOURCE _SELECT->DBF_NAME ;
         VALUE 1 ;
         WIDTH 150 HEIGHT 100 ;
         FONT "Arial" SIZE 10 ; 
         ON LOSTFOCUS upd_det() 

      @ 90,10 COMBOBOX Combo_11 ;
         ITEMSOURCE _SEL_MAS->FLD_NAME ;
         VALUE 1 ;
         WIDTH 150 HEIGHT 100 ;
         FONT "Arial" SIZE 10 ; 
         TOOLTIP "Select Field" 

      @ 90,200 COMBOBOX Combo_12 ;
         ITEMSOURCE _SEL_DET->FLD_NAME ;
         VALUE 1 ;
         WIDTH 150 HEIGHT 100 ;
         FONT "Arial" SIZE 10 ; 
         TOOLTIP "Select Field" 

      @ 130, 100 BUTTON ADDING_111 ; 
         CAPTION " Add " ;
         WIDTH 200 ;
         ACTION upd_grid()
         
      @ 170,10 GRID Fmd_Grid_2 ;
         WIDTH 370 ;
         HEIGHT 120 ;
         HEADERS { "Master DBF","Field","Detail DBF","Field" } ;
         WIDTHS { 90,90,90,90 } 
                  
      @ 310, 100 BUTTON DEFAULT_111 ; 
         CAPTION " Create Default Form " ;
         WIDTH 200 ;
         ACTION fmd_deff() 

	END WINDOW		 

	CENTER WINDOW   FmdDefForm
	ACTIVATE WINDOW FmdDefForm

Return
*:*********************************************************************
FUNCTION fmd_deff

LOCAL a_name[64], a_type[64], a_len[64], a_dec[64]
LOCAL i, ii, mname, w_num, _i, w_pict, w_def
LOCAL act_row, act_col, len_name, len_fild
LOCAL _pocetak, _naziv, _kraj, pomeraj

_key := FmdDefForm.Combo_1.Value
_key2 := FmdDefForm.Combo_2.Value
dbcloseall()

upd_fmd_rel( _key )

use _select 
go _key

mname = dbf_name
mname = ALLTRIM( mname )
frmname = mname

use _select 
go _key2

mname2 = dbf_name
mname2 = ALLTRIM( mname2 )

read_dir()

SELECT 6
USE _fmd_dbf INDEX _fmd_dbf

SELECT 5
USE _fmd_apl INDEX _fmd_apl

SELECT 2
USE _fmd_fld INDEX _fmd_fld

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
REPLACE dbfname2  WITH mname2
REPLACE dbfseq   WITH 1

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
_row = 50
_col = 20

*** master block ***

   SELECT 2
   FOR i = 1 TO ii
      dbappend()
      REPLACE formname WITH frmname
      REPLACE block    WITH 1
      REPLACE dbfname WITH mname
      REPLACE fldname  WITH a_name[i]
      REPLACE fldlabel WITH a_name[i]
      REPLACE fldseq   WITH i
      REPLACE fldtype  WITH a_type[i]
      REPLACE fldlen   WITH a_len[i]
      REPLACE flddec   WITH a_dec[i]
      REPLACE fldrow   WITH _row
      REPLACE fldcol   WITH _col
      if fldtype = 'D'
         REPLACE fldlen   WITH 10
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
      REPLACE fldatr2 WITH .t.
      REPLACE fldatr3 WITH .t.
      REPLACE fldatr4 WITH .t.
      REPLACE fldatr5 WITH .f.
      REPLACE fldatr6 WITH .t.
      REPLACE fldatr7 WITH .f.
      REPLACE fldatr8 WITH .f.

      IF a_type[i] = 'M'
         REPLACE fldatr1 WITH .f.
         REPLACE fldatr2 WITH .t.
         REPLACE fldatr3 WITH .t.
         REPLACE fldatr4 WITH .t.
         REPLACE fldatr5 WITH .f.
         REPLACE fldatr6 WITH .f.
         REPLACE fldatr7 WITH .f.
         REPLACE fldatr8 WITH .f.

        * REPLACE rang_low WITH STR(fldrow)
        * REPLACE rang_high WITH STR(fldcol+35)
      ENDIF

      _len1 = len(alltrim(fldname))
      _len2 = len(alltrim(fldlabel))
      _len3 = fldlen

      _fldlen = max( _len1, _len2)
      _fldlen = max( _fldlen, _len3)

      *_col = _col + _fldlen*10 + 10
      *if _col > 600
      *   _row = _row + 60
      *   _col = 20
      *endif
      
	  _row = _row + 30
	  
   NEXT
   
*** detail block *** 
  
SELECT 3
USE &mname2

ii = AFIELDS(a_name)
AFIELDS(a_name,a_type,a_len,a_dec)

act_row = 2
act_col = 2
len_name = 0
len_fild = 0
_row = 100
_col = 100

*** master block ***

   SELECT 2
   FOR i = 1 TO ii
      dbappend()
      REPLACE formname WITH frmname
      REPLACE block    WITH 2
      REPLACE dbfname WITH mname2
      REPLACE fldname  WITH a_name[i]
      REPLACE fldlabel WITH a_name[i]
      REPLACE fldseq   WITH i
      REPLACE fldtype  WITH a_type[i]
      REPLACE fldlen   WITH a_len[i]
      REPLACE flddec   WITH a_dec[i]
      REPLACE fldrow   WITH _row
      REPLACE fldcol   WITH _col
      if fldtype = 'D'
         REPLACE fldlen   WITH 10
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
      REPLACE fldatr2 WITH .t.
      REPLACE fldatr3 WITH .t.
      REPLACE fldatr4 WITH .t.
      REPLACE fldatr5 WITH .f.
      REPLACE fldatr6 WITH .f.
      REPLACE fldatr7 WITH .f.
      REPLACE fldatr8 WITH .f.

      IF a_type[i] = 'M'
         REPLACE fldatr1 WITH .f.
         REPLACE fldatr2 WITH .t.
         REPLACE fldatr3 WITH .t.
         REPLACE fldatr4 WITH .t.
         REPLACE fldatr5 WITH .f.
         REPLACE fldatr6 WITH .f.
         REPLACE fldatr7 WITH .f.
         REPLACE fldatr8 WITH .f.

         REPLACE rang_low WITH STR(fldrow)
         REPLACE rang_high WITH STR(fldcol+35)
      ENDIF
      
     _row = _row + 30 
      
   NEXT
   
dbcloseall()
delete file _files.*

msginfo( 'Finish' )

FmdDefForm.Release

RETURN 0
*:********************************
function the_end_3m_1()

   *dbcloseall()
   FmdDefForm.Release

return 
*:****************************************
FUNCTION sel_work ()

if ! file ("_SEL_MAS.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FLD_NAME","C",10,0})
   dbcreate("_SEL_MAS",alist_fld)
endif

if ! file ("_SEL_DET.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"FLD_NAME","C",10,0})
   dbcreate("_SEL_DET",alist_fld)
endif

RETURN
*:****************************************
function upd_mas()

_baz := FmdDefForm.Combo_1.Value

select _select 
go _baz
_baza = alltrim(dbf_name)

aMas := {}

select _sel_mas
zap

select _dbf
dbgotop()
do while .not. eof()

   if dbf_name = _baza
      _fld_name = field_name 
     
      select _sel_mas
      dbappend()
      replace fld_name with _fld_name
   endif

   select _dbf
   dbskip()
enddo

FmdDefFORM.Combo_11.Refresh

return 0
*:*****************************************
function upd_det ()

_baz := FmdDefForm.Combo_2.Value

select _select 
go _baz
_baza = alltrim(dbf_name)

select _sel_det
zap

select _dbf
dbgotop()
do while .not. eof()

   if dbf_name = _baza
      _fld_name = field_name 
     
      select _sel_det
      dbappend()
      replace fld_name with _fld_name
   endif

   select _dbf
   dbskip()
enddo

FmdDefFORM.Combo_12.Refresh

return 0
*:*********************************************************
FUNCTION upd_grid ()
  
  _d1 := FmdDefForm.Combo_1.Value
  _f1 := FmdDefForm.Combo_11.Value
  _d2 := FmdDefForm.Combo_2.Value
  _f2 := FmdDefForm.Combo_12.Value
    
    select _select 
    go _d1
    _dbf1 = dbf_name
    go _d2
    _dbf2 = dbf_name
    
    select _sel_mas 
    go _f1
    _fild1 = fld_name
    
    select _sel_det
    go _f2
    _fild2 = fld_name
    
   Aadd( aGrid, { _dbf1, _fild1, _dbf2, _fild2 }) 
   
   FmdDefForm.Fmd_Grid_2.DeleteAllItems()
   FOR i = 1 to LEN(aGrid)
      FmdDefForm.Fmd_Grid_2.AddItem(aGrid[i])
   NEXT
   FmdDefForm.Fmd_Grid_2.Refresh
      
RETURN 0
*:*************************************************
FUNCTION upd_fmd_rel ( _d1 )
   
   use _fmd_rel index _fmd_rel new    
   use _select new
   go _d1
   _frm_name = alltrim(dbf_name)

   select _fmd_rel
 
   delete for formname = _frm_name
   pack

   FOR i = 1 to LEN(aGrid)
  
      dbappend()
      replace formname with _frm_name
      replace seq      with i
      replace dbf1    with aGrid[i][1]
      replace field1  with aGrid[i][2]
      replace dbf2    with aGrid[i][3]
      replace field2  with aGrid[i][4]
      
   NEXT

   dbcloseall()
   
RETURN 0
