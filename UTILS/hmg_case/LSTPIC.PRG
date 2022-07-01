#Include "hmg.ch"

static  aGrid := {}

FUNCTION LIST_PICT() 		

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

if ! file ("_RC.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"NAME",      "C",30, 0})
   aadd(alist_fld,{"TYPE",      "C",10, 0})
   aadd(alist_fld,{"FULLNAME",   "C",30, 0})
   dbcreate("_RC",alist_fld)
endif

if ! file ("_RC.ntx")
   use _RC via "dbfntx"
   index on type+FULLNAME to _RC unique
   use
endif

if ! file ("_TEMP.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"LINIJA",    "C",200, 0})
   dbcreate("_TEMP",alist_fld)
endif

list_of_pict()
      
   DEFINE WINDOW ListForp ;
      AT 0,0 ;
      WIDTH 600 ;  
      HEIGHT 400 ;
      TITLE 'List of Pictures' ;
      MODAL ;
      ON INIT load_grip()
      		
      ON KEY ESCAPE ACTION ListForp.Release
         
      @ 30,30 GRID ListGrid ;
         WIDTH 530 ;
         HEIGHT 310 ;
         HEADERS { "Program","Row","Line" } ;
         WIDTHS { 80, 50, 390 } 
        
	END WINDOW		 

	CENTER WINDOW   ListForp
	ACTIVATE WINDOW ListForp

Return
*:************************************************************
Function list_of_pict ()

read_dir()

select 4
use _rc index _rc
zap

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
_pos = 0
_tip = ''

* if at('.BMP',_lin) > 0 .or. at('.GIF',_lin) > 0 .or. at('.ICO',_lin) > 0 .or. at('.JPG',_lin) > 0 .or. at('.PNG',_lin) > 0

do case
   case at('.BMP',_lin) > 0
     _pos = at('.BMP',_lin)
     _tip = 'BITMAP'
     
   case at('.GIF',_lin) > 0 
     _pos = at('.GIF',_lin)
     _tip = 'GIF'
     
   case at('.ICO',_lin) > 0 
     _pos = at('.ICO',_lin)
     _tip = 'ICON'
  
   case at('.JPG',_lin) > 0 
     _pos = at('.JPG',_lin)
     _tip = 'JPG'
 
   case at('.PNG',_lin) > 0
     _pos = at('.PNG',_lin)
     _tip = 'PNG'
  
 endcase
  
if _POS > 0

   select 3
   dbappend()
   replace program with _prg
   replace no with _red
   replace line with _lin

   for i = _pos to 1 step -1
  
      _ch = substr(_lin,i,1)
      if _ch = chr(34) .or. _ch = chr(39)
         _name = substr(_lin,i+1,_pos-i-1)
         _fullname = substr(_lin,i+1,_pos-i+3)
         exit
      else
         loop
      endif

   next

   select 4
   dbappend()
   replace name   with lower(_name)
   replace type   with _tip
   replace fullname with lower(_fullname)

endif

select 2
dbskip()
enddo

select 1
dbskip()
enddo

select 3
copy to pict.txt sdf

select 4
copy to main.rc sdf

dbcloseall()

return
*:***********************************************************
FUNCTION load_grip ()

use _list index _list

do while .not. eof()

_fld1 = program
_fld2 = str(no)
_fld3 = line
   
   Aadd( aGrid, { _fld1, _fld2, _fld3 }) 

dbskip()
enddo
   
   ListForp.ListGrid.DeleteAllItems()
   FOR i = 1 to LEN(aGrid)
      ListForp.ListGrid.AddItem(aGrid[i])
   NEXT
   ListForp.ListGrid.Refresh

dbcloseall()

return 
