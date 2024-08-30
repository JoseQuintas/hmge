#include <minigui.ch>

FUNCTION Main

	SET DELETED ON

	LOAD WINDOW Win_1
	Win_1.Center
	Win_1.Activate

RETURN( NIL )
********************
Procedure Refresh

	Win_1.Text_1.Refresh
	Win_1.Text_2.Refresh
	Win_1.Text_3.Refresh
	Win_1.Date_4.Refresh
	Win_1.Check_5.Refresh
	Win_1.Edit_6.Refresh

	Win_1.Text_1.SetFocus

Return
*********************
Procedure Save

	select test

	IF RLOCK()

		Win_1.Text_1.Save
		Win_1.Text_2.Save
		Win_1.Text_3.Save
		Win_1.Date_4.Save
		Win_1.Check_5.Save
		Win_1.Edit_6.Save

		UNLOCK
	ENDIF

	select 0
Return
*********************
Procedure New
Local n

	select test

	DbGoBottom()
	n := TEST->CODE

	APPEND BLANK
	TEST->CODE := ++n

	select 0
Return
********************
Procedure DelRec

	select test

	IF RLOCK()

		DELETE

		UNLOCK
	ENDIF

	WHILE Deleted()
		DbSkip(-1)
	END

	select 0
Return
*******************
Procedure OpenTables

	USE TEST SHARED

	IF !FILE( 'TEST.NTX' )
		INDEX ON FIELD->CODE TO TEST
	ENDIF

	select 0

Return
*******************
Procedure CloseTables

	select test
	USE
	ERASE TEST.NTX

Return
