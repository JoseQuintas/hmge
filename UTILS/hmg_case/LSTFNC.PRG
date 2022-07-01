#Include "hmg.ch"

static  aGrid := {}

FUNCTION LIST_FUNC () 		

delete file _temp.dbf

if ! file ("_LIST.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"PROGRAM",   "C", 20, 0})
   aadd(alist_fld,{"NO",        "N",  5, 0})
   aadd(alist_fld,{"F",         "C",  1, 0})
   aadd(alist_fld,{"LINE",      "C", 60, 0})
   dbcreate("_LIST",alist_fld)
endif

if ! file ("_LIST.ntx")
   use _LIST via "dbfntx"
   index on LINE to _LIST
   use 
endif

if ! file ("_TEMP.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"LINIJA",    "C",100, 0})
   dbcreate("_TEMP",alist_fld)
endif

list_of_func()
      
   DEFINE WINDOW ListForm ;
      AT 0,0 ;
      WIDTH 600 ;  
      HEIGHT 400 ;
      TITLE 'List of Function & Procedures' ;
      MODAL ;
      ON INIT load_grid()
      		
      ON KEY ESCAPE ACTION ListForm.Release
         
      @ 30,30 GRID ListGrid ;
         WIDTH 530 ;
         HEIGHT 310 ;
         HEADERS { "Program","Row","Line" } ;
         WIDTHS { 80, 50, 375 } 
        
	END WINDOW		 

	CENTER WINDOW   ListForm
	ACTIVATE WINDOW ListForm

Return
*:************************************************************
Function list_of_func ()

read_dir()

select 3
use _list  index _list
zap

select 2
use _temp
zap

select 1
use _files
delete for ext != 'PRG'
pack

do while .not. eof()

_prg = alltrim(name)
_load = _prg + '.prg'

select 2
zap
append from &_load sdf

dbgotop()
do while .not. eof()

_red = recno()
_lin = upper(alltrim(linija))

if substr(_lin,1,4) = 'FUNC' .or. substr(_lin,1,4) = 'PROC'

select 3
dbappend()
replace program with _prg
replace no with _red
replace line with _lin

endif

select 2
dbskip()
enddo

select 1
dbskip()
enddo

select 3
copy to func.txt sdf

dbcloseall()

return
*:***********************************************************
FUNCTION Load_Grid ()

use _list index _list

do while .not. eof()

_fld1 = program
_fld2 = str(no)
_fld3 = line
   
   Aadd( aGrid, { _fld1, _fld2, _fld3 }) 

dbskip()
enddo
   
   ListForm.ListGrid.DeleteAllItems()
   FOR i = 1 to LEN(aGrid)
      ListForm.ListGrid.AddItem(aGrid[i])
   NEXT
   ListForm.ListGrid.Refresh

dbcloseall()

return 
