*:***********************
*: Program OPEN_DBF.PRG 
*:***********************
PROCEDURE open_mnu

LOCAL alist_fld

if ! file ("_APL.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"NAME","C",20,0})
   aadd(alist_fld,{"TITLE","C",30,0})
   aadd(alist_fld,{"WIDTH","N",4,0})
   aadd(alist_fld,{"HEIGHT","N",4,0})
   aadd(alist_fld,{"MNUCOL","N",2,0})
   aadd(alist_fld,{"MNUROW","N",2,0})
   dbcreate("_APL",alist_fld)
endif

if ! file ("_APLADD.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"MODUL","C",20,0})
   dbcreate("_APLADD",alist_fld)
endif

if ! file ("_APLMNU.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"LEVEL1","N",2,0})
   aadd(alist_fld,{"LEVEL2","N",2,0})
   aadd(alist_fld,{"ITEM","C",50,0})
   aadd(alist_fld,{"ACTION","C",20,0})
   aadd(alist_fld,{"MODUL","C",20,0})
   dbcreate("_APLMNU",alist_fld)
endif

if ! file ("_APLMNUS.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"LEVEL3","N",3,0})
   aadd(alist_fld,{"LEVEL4","N",2,0})
   aadd(alist_fld,{"ITEM","C",50,0})
   aadd(alist_fld,{"ACTION","C",20,0})
   aadd(alist_fld,{"MODUL","C",20,0})
   dbcreate("_APLMNUS",alist_fld)
endif

if ! file ("_APLSET.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"SETING","C",40,0})
   dbcreate("_APLSET",alist_fld)
endif

if ! file ("_APLADD.ntx")
   use _APLADD
   index on MODUL to _APLADD
   use 
endif

if ! file ("_APLMNU.ntx")
   use _APLMNU
   index on STR(LEVEL1,2)+STR(LEVEL2,2) to _APLMNU
   use 
endif

if ! file ("_APLMNUS.ntx")
   use _APLMNUS
   index on STR(LEVEL3,3)+STR(LEVEL4,2) to _APLMNUS
   use 
endif

if ! file ("_APLSET.ntx")
   use _APLSET
   index on SETING to _APLSET
   use 
endif

init_apl_dbf()

RETURN
*:*******************************************************
function re_order_mnu ()

dbcloseall()

use _apladd index _apladd new
pack

dbcloseall()

use _aplmnu index _aplmnu
pack
copy to _work

dbcloseall()

select 2
use _aplmnu index _aplmnu
zap

select 1
use _work 
index on str(level1,2)+str(level2,2) to _work

_lvl2 = 0

*** level 0 ***

do while .not. eof()

   if Level1 != 0
      dbskip()
      loop
   endif

   _level1 = level1 
   _level2 = level2
   _item   = item
   _action = action
   
   _lvl2++

   select 2
   dbappend()
   replace level1 with 0
   replace level2 with _lvl2
   replace item with _item
   replace action with _action

   select 1
   dbskip()
enddo

*** ostalo ***

_old = level1
_lvl1 = 0
_lvl2 = 0

dbgotop()
do while .not. eof()

   if level1 = 0
      dbskip()
      loop
   endif

   _level1 = level1 
   _level2 = level2
   _item   = item
   _action = action
   _modul = modul

   if _old < level1
      _lvl1++
      _lvl2 = 0
   endif
   _lvl2++

   select 2
   dbappend()
   replace level1 with _lvl1
   replace level2 with _lvl2
   replace item with _item
   replace action with _action
   replace modul with _modul

   _old = level1

   select 1
   dbskip()
enddo

dbcloseall()

delete file _work.dbf
delete file _work.ntx

return
*:********************************
procedure init_apl_dbf

/* aplication */
use _APL 

if reccount() > 1
   delete for recno() > 1
   pack
endif

if reccount() = 0
   dbappend()
   replace name with 'main'
   replace title with 'main from hmgcase'
   replace width with 800
   replace height with 600
   replace mnucol with 3
   replace mnurow with 3
endif

_mnucol = mnucol
_mnurow = mnurow

dbcloseall()

/* menu */

use _aplmnu index _aplmnu

if reccount() = 0

   for _i = 1 to _mnucol
      dbappend()
      replace level1 with 0
      replace level2 with _i
      replace item with 'Menu ' + alltrim(str(_i))
   next

   for _i = 1 to _mnucol
      for _j = 1 to _mnurow
         dbappend()
         replace level1 with _i
         replace level2 with _j
         replace item with 'Item ' + alltrim(str(_i)) + ' ' + alltrim(str(_j))
         replace action with 'nil'
      next
   next

         dbappend()
         replace level1 with 1
         replace level2 with _mnurow + 1
         replace item with '.'
         replace action with 'nil'

         dbappend()
         replace level1 with 1
         replace level2 with _mnurow + 2
         replace item with 'Exit'
         replace action with 'MainForm.Release'

endif
		 
dbcloseall()

/* seting */

use _aplset index _aplset

if reccount() = 0
   dbappend()
   replace seting with 'century on'
   dbappend()
   replace seting with 'date german'
   dbappend()
   replace seting with 'interactiveclose on'
   dbappend()
   replace seting with 'navigation extended'
   dbappend()
   replace seting with 'tooltipstyle balloon'
*   dbappend()
*   replace seting with 'tooltipbackcolor { 193, 224, 255}'
   dbappend()
   replace seting with 'multiple off warning'
endif

dbcloseall()

/* add module */

use _apladd index _apladd

if reccount() = 0
   dbappend()
   replace modul with 'open_dbf'
   dbappend()
   replace modul with 'open_ntx'
   dbappend()
   replace modul with 'use_dbf'
endif

dbcloseall()

return 
