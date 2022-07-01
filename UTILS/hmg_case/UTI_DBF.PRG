#include "hmg.ch"

Function dbf_upd

    dbf_updd()
    use _select index _select

    DEFINE WINDOW Win_1_5 ;
        AT 0,0 ;
        WIDTH 500 HEIGHT 400 ;
        TITLE 'DBF tables ' ;
        MODAL 
 
        ON KEY ESCAPE ACTION Win_1_5.Release
  
        @ 30,30 BROWSE Browse_1_5 ;
           WIDTH  400 ;
           HEIGHT 300 ;
           VALUE 0 ;
           WIDTHS {130,120,120} ;
           HEADERS {'DBF','In dictionary','On disk'} ;
           WORKAREA _SELECT ;
           FIELDS {'dbf_name','dbf_dict','dbf_disk'} ;
           FONT "Arial" ;
           SIZE 10
             
        DEFINE CONTROL CONTEXTMENU Browse_1_5 OF Win_1_5
            ITEM "Update" ACTION upd_dbf_1()
            ITEM "Delete" ACTION del_dbf_1()
        END MENU
             
    END WINDOW

    CENTER WINDOW Win_1_5
    ACTIVATE WINDOW Win_1_5

Return Nil
*****************************************************************
function upd_dbf_1

_red = win_1_5.browse_1_5.Value

go _red
_dbff = alltrim(dbf_name)

dbcloseall()

imp_dbf1 ( _dbff )

msginfo ('Updated')

win_1_5.Release

return 0
**********************************************************************
function del_dbf_1

_red = win_1_5.browse_1_5.Value

go _red
_dbff = alltrim(dbf_name)

dbcloseall()

use _dbf index _dbf new
delete for dbf_name = _dbff
pack

dbcloseall()

msginfo( 'Deleted' )

win_1_5.Release

return 0
!*********************************************************************
FUNCTION dbf_updd

read_dir()

SELECT 4
USE _select INDEX _select
ZAP

SELECT 2
USE _dbf

SELECT 1
USE _files

DELETE FOR ext != "DBF"
DELETE FOR SUBSTR(name,1,1) = "_"
PACK

dbgotop()
DO WHILE .NOT. EOF()
   _name = name
   SELECT 4
   SEEK _name
   IF FOUND()
      REPLACE dbf_disk WITH 'Y'
   ELSE
      dbappend()
      REPLACE dbf_name WITH _name
      REPLACE dbf_disk WITH 'Y'
   ENDIF
   SELECT 1
   dbskip()
ENDDO

SELECT 2
dbgotop()
DO WHILE .NOT. EOF()
   _name = dbf_name
   SELECT 4
   SEEK _name
   IF FOUND()
      REPLACE dbf_dict WITH 'Y'
   ELSE
      dbappend()
      REPLACE dbf_name WITH _name
      REPLACE dbf_dict WITH 'Y'
   ENDIF
   SELECT 2
   dbskip()
ENDDO

dbcloseall()

RETURN 0
*!*********************************************************************
FUNCTION imp_dbf1( _dbf_name )

LOCAL alist_dbf, mname, i, ii, _full_dbf, _dbf, _buffer, _dbf_type

mname = ALLTRIM(_dbf_name)

select 2
use _dbf index _dbf
delete for dbf_name = mname
pack

_buffer = SPACE(10)

_full_dbf = mname + '.DBF'
_dbf = FOPEN( _full_dbf, 0 )
FREAD( _dbf, @_buffer, 10 )
DO CASE
CASE SUBSTR(_buffer,1,1) = CHR(3)
   _dbf_type = 'NTX'
CASE SUBSTR(_buffer,1,1) = CHR(131)
   _dbf_type = 'NTX'
* CASE SUBSTR(_buffer,1,1) = CHR(245)
*   _dbf_type = 'CDX'
ENDCASE
FCLOSE( _dbf )

select 3
USE &mname

alist_fld := DBSTRUCT()
ii = LEN( alist_fld )

SELECT 2
FOR i = 1 TO ii
   APPEND BLANK
   REPLACE dbf_name   WITH mname
   REPLACE field_seq  WITH i
   REPLACE field_name WITH alist_fld[i][1]
   REPLACE field_type WITH alist_fld[i][2]
   REPLACE field_len  WITH alist_fld[i][3]
   REPLACE field_dec  WITH alist_fld[i][4]
NEXT

RETURN 0
*: EOF: UTI_DBF.PRG
