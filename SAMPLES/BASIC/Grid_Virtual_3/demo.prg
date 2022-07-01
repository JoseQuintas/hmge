/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Demo was contributed to HMG forum by Edward 29/Nov/2021
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

* :encoding=windows-1250:	•∆ £—”åØè πÊÍ≥ÛÒúøü

#pragma -w3
#pragma -es2

#include "hmg.ch"
#Include "Fileio.CH"
#include "hbthread.ch"

#xtranslate Sleep( <t> ) => wapi_Sleep( <t> )

REQUEST HB_LANG_DEWIN
REQUEST HB_CODEPAGE_DEWIN

Set Procedure To vfFileRead

Static lCheck_1, lCheck_2, lCheck_3

Function Main
Local cFileToOpen := 'TestBIG.dat'
Local cDelimiter := CHR ( 9 )

set( _SET_CODEPAGE, "DEWIN" )
hb_LangSelect( 'DEWIN')
	
DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 1100 ;
	HEIGHT 660 ;
	TITLE 'Large text file viewer.' ;
	MAIN ;
	ON INIT Prepare( cFileToOpen, cDelimiter )

	DEFINE MAIN MENU
		DEFINE POPUP 'File'
			MENUITEM 'Open file (without counting the number of lines) - incremental reading file.'    ACTION OpenFile ( cFileToOpen, cDelimiter, 0 )
			MENUITEM 'Open file (count the number of lines before browsing) - static file loading.'    ACTION OpenFile ( cFileToOpen, cDelimiter, 1 )
			MENUITEM 'Open file (count the number of lines in another thread) - dynamic file loading.' ACTION OpenFile ( cFileToOpen, cDelimiter, 2 )
		END POPUP
		DEFINE POPUP 'Test'
			MENUITEM 'Test hb_F* functions'  ACTION Test ( 1, cFileToOpen )
			MENUITEM 'Test vfFileRead Class' ACTION Test ( 2, cFileToOpen )
		END POPUP
	END MENU
	
	@10, 880 Label Label_1 Width 230 Value ""
	@50, 880 Label Label_2 Width 230 Value ""
	@90, 880 Label Label_3 Width 230 Value ""

	@150, 880 CHECKBOX Check_1 CAPTION 'Get ListViewGetCountPerPage' WIDTH 230 VALUE .T. ON CHANGE lCheck_1 := Form_1.Check_1.Value 
	@180, 880 CHECKBOX Check_2 CAPTION 'Get Form_1.Grid_1.Height' WIDTH 230 VALUE .T. ON CHANGE lCheck_2 := Form_1.Check_2.Value
	@210, 880 CHECKBOX Check_3 CAPTION 'Get Form_1.Grid_1.ItemCount' WIDTH 230 VALUE .T. ON CHANGE lCheck_3 := Form_1.Check_3.Value

	Form_1.Check_1.Visible := .F.
	Form_1.Check_2.Visible := .F.
	Form_1.Check_3.Visible := .F.
	
	lCheck_1 := Form_1.Check_1.Value
	lCheck_2 := Form_1.Check_2.Value
	lCheck_3 := Form_1.Check_3.Value
    
	DEFINE STATUSBAR
		STATUSITEM "" WIDTH Form_1.Width / 2
		STATUSITEM "" WIDTH Form_1.Width / 2 
	END STATUSBAR

	ShowProgressBar( 1, , , (Form_1.Width / 2) + 5 , Form_1.Width / 2 - 30 )		//init progress bar
	ShowProgressBar( 0 )												//hide progress bar
		
END WINDOW

CENTER WINDOW Form_1
ACTIVATE WINDOW Form_1

Return Nil

***************************************************
Function QueryFile( oFile, cDelimiter )
Local nRecord          := This.QueryRowIndex
Local nCol             := This.QueryColIndex
Local nListRows        := LISTVIEWGETCOUNTPERPAGE ( Form_1.Grid_1.Handle )	//Number of visible lines in the grid
Local nItemCount       := Form_1.Grid_1.ItemCount
Local nIncrementalRead := 1000
Local aMemAlloc        := {}

Static aFields         := {}

IF oFile == Nil
	Return Nil
ENDIF

IF oFile:CurrentLine() <> nRecord		//Prevents the current row from being reread when query to display the next column (speeding up)
	oFile:GoTo (  nRecord )
	aFields   := hb_ATokens ( oFile:ReadLine(), cDelimiter )
	aMemAlloc := GetProcessMemoryInfo()
ENDIF

This.QueryData := IF ( Len ( aFields ) < nCol , "", aFields [ nCol ] )

IF nRecord > nItemCount - nListRows .AND. oFile:nLastLine = Nil		//incremental reading file
	oFile:Skip ( nIncrementalRead )
	IF oFile:CurrentLine() > nItemCount
		Form_1.Grid_1.ItemCount := oFile:CurrentLine()		//Changing the ItemCount causes the Grid view to scroll to the position of the selected row
		Form_1.Grid_1.Value     := nRecord					//Re-scroll to the position nRecord of displayed line before the ItemCount was changed.
	ENDIF
	oFile:Skip ( 0 - nIncrementalRead )
ENDIF

IF Len ( aMemAlloc ) == 9 .AND. aMemAlloc [3] / 1024 ^ 2 > 50
	EmptyWorkingSet()	//Flush the current working set size
	//HMG_GarbageCall()  <- CAUTION!!!! DO NOT call HMG_GarbageCall () or Release Memory, this may cause hangon the application when using the vertical slider  
ENDIF

Return Nil

**************************************************************
Function MemoryLeakQuery()

IF lCheck_1
	ListViewGetCountPerPage ( Form_1.Grid_1.Handle )	//Number of visible lines in the grid
ENDIF
IF lCheck_2
	Form_1.Grid_1.Height
ENDIF
IF lCheck_3
	Form_1.Grid_1.ItemCount
ENDIF

This.QueryData := Str ( This.QueryRowIndex )  

Return Nil
**************************************************************
Function OpenFile ( cFileToOpen, cDelimiter, nMode )

Local aColumns, aHeaders := {}, aWidths := {}, i, oFile
Local pMutexCount, nListRows
Default nMode := 0

IF File ( cFileToOpen )

	oFile := vfFileRead():New( cFileToOpen, , , )
	oFile:Open()

	IF oFile:Error()
		MsgStop ("Error " + Str( oFile:ErrorNo() ), "Error" )
		RETURN Nil
	ENDIF
		
	IF IsControlDefined ( Grid_1, Form_1 )
  		Form_1.Grid_1.Release
  	ENDIF
  	
	//Preparing columns (based on the first row from the file)
	aColumns := hb_ATokens ( oFile:ReadLine(), cDelimiter )

	For i := 1 TO Len( aColumns )
		AADD( aHeaders, 'Col #' + AllTrim( Str( i ) ) )
		AADD( aWidths, Max(20, Len( aColumns [ i ] ) * 9 ) )
	Next i
	
	IF nMode == 1		//Calculate the number of rows before displaying the Grid
		WAIT WINDOW "Counting the number of records ..."  NOWAIT
		ShowProgressBar( 2 )		//show progress bar
		Form_1.StatusBar.Item(1) := "Counting the number of records ... This may take some time .... "
	
		//code block executed while the CountLines() method is running
		oFile:exGauge := { | nPos, nLastPos, nLines, cState | ( Form_1.StatusBar.Item(1) := "Counting the number of records: " + AllTrim ( Str ( nLines ) ) + "... This may take some time ... " + cState, Form_1.PBar.Value := nPos / nLastPos * 100, doEvents() ) }
		oFile:CountLines()
		Form_1.StatusBar.Item(1) := ""
		ShowProgressBar( 0 )		//hide progress bar

		WAIT CLEAR
	ENDIF
	
  	@ 10,10 GRID Grid_1 ;
  		OF Form_1 ;
		WIDTH 850 ;
		HEIGHT 530 ;
		VALUE 1 ;
		HEADERS aHeaders ;
		WIDTHS aWidths;
		VIRTUAL ;
		ITEMCOUNT 0 ;
		ON QUERYDATA If ( nMode < 3, QueryFile( oFile, cDelimiter ), MemoryLeakQuery() )
		
	nListRows := LISTVIEWGETCOUNTPERPAGE ( Form_1.Grid_1.Handle )		//Number of visible lines in the grid 
	Form_1.Grid_1.PaintDoubleBuffer := .T.

	IF nMode == 2 .AND. hb_mtvm()  //other thread
  		pMutexCount := hb_mutexCreate()		//Mutex used to transfer values between threads
		hb_threadStart( HB_THREAD_INHERIT_MEMVARS /* Required to access Form_1 on another thread*/ , @MT_Count(), cFileToOpen, oFile, pMutexCount )
	ENDIF
	
	IF oFile:nLastLine = Nil		//Incremental reading of the file. If we do not know the number of the last row, we try to read the next ones (twice as many as the number of rows visible in the grid)
		oFile:Goto ( nListRows * 2 )
		IF .NOT. oFile:nLastLine = Nil		//End of file has been reached
			Form_1.Grid_1.ItemCount := oFile:nLastLine
		ELSE
			Form_1.Grid_1.ItemCount := nListRows * 2
		ENDIF
	ELSE
		Form_1.Grid_1.ItemCount := oFile:nLastLine
	ENDIF
		
	Form_1.Check_1.Visible := .F.
	Form_1.Check_2.Visible := .F.
	Form_1.Check_3.Visible := .F.
	
	Form_1.Grid_1.Value := 1
	Form_1.Grid_1.Setfocus
	
ENDIF

RETURN oFile

*********************************************
Function MT_Count( cFileToOpen, oFileGrid, pMutexCount )

* Calculating the number of lines in a separate thread.

Local xResp, pThID := hb_threadSelf(), nThread
Local oFileMT, nCurrDispRec

* To avoid skipping lines in the grid while counting lines, let's open the file in another object.
IF File ( cFileToOpen )		
	oFileMT := vfFileRead():New( cFileToOpen )
	oFileMT:Open()

	IF oFileMT:Error()
		MsgStop ("Error " + Str( oFileMT:ErrorNo() ), "Error" )
		hb_threadDetach( pThID )		// close thread handle
		hb_threadQuitRequest( pThID )	// terminate thread
		oFileMT:Close()
		RETURN Nil
	ENDIF
	
	ShowProgressBar( 2 )		//show progress bar
	Form_1.StatusBar.Item(1) := "Background line counting. This may take some time .... "
	
	* Call a counting function (Run_MT_Count()) in a separate thread 
	* (I can't use the CountLines() method itself as a thread)
	nThread := hb_threadStart( @Run_MT_Count(), oFileMT, pMutexCount )

	Do While hb_mutexSubscribe( pMutexCount, /* 0.00000001 */ , @xResp )
	
		* After Mutex is notified, the xResp variable should contain a matrix with variables:
		* 1st - current position of the file pointer, 
		* 2nd - last position of the file pointer,
		* 3th - number of counted records,
		* 4th - status
	
		Form_1.PBar.Value := xResp [ 2 ] / xResp [ 3 ]  * 100
		Form_1.StatusBar.Item(1) := "Background line counting. This may take some time ... Counts: " + AllTrim( Str( xResp [ 1 ] ) )
		
		IF IsControlDefined ( Grid_1, Form_1 )
			nCurrDispRec := oFileGrid:CurrentLine()
  			SetProperty('Form_1', 'Grid_1', 'ItemCount', xResp [ 1 ] )		//Changing the ItemCount causes the Grid view to scroll to the position of the selected row
  			SetProperty('Form_1', 'Grid_1', 'Value', nCurrDispRec )		//Re-scroll to the position of the last displayed line before the ItemCount was changed.
  			
  			//We count the lines in the secondary object, therefore we have to rewrite the record map to the object displayed in the Grid.
  			oFileGrid:PutRecordsMap ( oFileMT:GetRecordsMap() )
  			
  			//We do the same with the variable: nLastLine
  			oFileGrid:nLastLine := oFileMT:nLastLine

		ENDIF
		
		Do Events
		hb_ReleaseCPU()
		
		IF xResp [ 4 ] == 'Done'
			
			//Counting finished, I am sending the final results.
		
			IF IsControlDefined ( Grid_1, Form_1 )
				nCurrDispRec := oFileGrid:CurrentLine()
				SetProperty('Form_1', 'Grid_1', 'ItemCount', xResp [ 1 ] )		//Changing the ItemCount causes the Grid view to scroll to the position of the selected row
				SetProperty('Form_1', 'Grid_1', 'Value', nCurrDispRec )		//Re-scroll to the position of the last displayed line before the ItemCount was changed.
				
				//We count the lines in the secondary object, therefore we have to rewrite the record map to the object displayed in the Grid.
				oFileGrid:PutRecordsMap ( oFileMT:GetRecordsMap() )
				
				//We do the same with the variable: nLastLine
				oFileGrid:nLastLine := oFileMT:nLastLine
			ENDIF
			EXIT
		ENDIF
		
	EndDo
	
	Form_1.StatusBar.Item(1) := ""
	ShowProgressBar( 0 )		//hide
	
	oFileMT:Close()

	//Close Run_MT_Count Thread
	hb_threadDetach( nThread )		// close thread handle
	hb_threadQuitRequest( nThread )	// terminate thread
	
	//Close mySelf Thread
	hb_threadDetach( pThID )		// close thread handle
	hb_threadQuitRequest( pThID )	// terminate thread

ENDIF

RETURN Nil

*********************************************
FUNCTION Run_MT_Count( oFile, pMutex )
* Calling the CountLines() method, you can declare as an argument
* a block of code that will be executed while the method is running.
* Here we are passing values to another thread using Mutex.
oFile:CountLines( { | nPos, nLastPos, nLines, cState | hb_mutexNotify( pMutex, { nLines, nPos, nLastPos, cState } ) } /* exGauge */ )
RETURN Nil
*********************************************
Function Refr_Mem_Stat()
DO WHILE .T.

	Form_1.Label_1.Value := "Total app memory: "     + AllTrim( Str ( GlobalMemoryStatusEx () [6] / 1024 ^ 2 ) ) + " MB "
	Form_1.Label_2.Value := "Available app memory: " + AllTrim( Str ( GlobalMemoryStatusEx () [7] / 1024 ^ 2 ) ) + " MB "
	Form_1.Label_3.Value := "Working memory set: "   + AllTrim( Str ( GetProcessMemoryInfo () [3] / 1024 ^ 2 ) ) + " MB "
	
	Sleep (500)
								
ENDDO
RETURN Nil
*********************************************
Function Prepare ( cFileToOpen, cDelimiter )
Local hTestFile, i, x, nMaxRec := 70000000, aTestRec

Release Memory

hb_threadStart( HB_THREAD_INHERIT_MEMVARS /* Required to access Form_1 on another thread*/ , @Refr_Mem_Stat() )

IF !File ( cFileToOpen )
	Msginfo ("A test file will be prepared, this may take some time, please be patient ... ")
	nMaxRec  := Val(InputBox('Number of records','Prepare a sample data file.',AllTrim(Str(nMaxRec))))
	aTestRec := {"DP/DP_Kamat_HD.Soll_Umin_HD_Bediener", "DB_Baggerpumpe_1.Ist_Strom_BP1", "DB_Analoganzeigen_Pult.Sandmenge_m3_h_Visu", ;
			"DP/DP_Kamat_HD.Soll_Umin_HD_Kamat", "DB_Analoganzeigen_Pult.Druck_Schneidrad_REAL_VI", "F¸llstand_Druck_Land.Fuell_Sumpf_min_unter", "DB_Analoganzeigen_Pult.Speisedruck_REAL_Visu", ;
			"DB_Analoganzeigen_Pult.Foerdermenge_t_h_Visu" ,"DB_Analoganzeigen_Pult.Druck_vor_BP2_REAL_Visu ", "DB_Analoganzeigen_Pult.Druck_SW_BB_REAL_VISU", ;
			"DB_Analoganzeigen_Pult.Foerderdichte_REAL_Visu", "F¸llstand_Druck_Land.Fuell_Sumpf_Land_Differe", "DB_Analoganzeigen_Pult.Druck_nach_BP1_real_Visu" ,;
			"DB_Analoganzeigen_Pult.Druck_Hyd_Pumpe_1_Visu", "F¸llstand_Druck_Land.Fuell_Sumpf_zeit1", "DP/DP_Kamat_HD.Hochdruck_bar", "DB_Z‰hler Winden.Zaehler_STP_Mitte_7", ;
			"DB_Z‰hler Winden.Zaehler_SW_StB_7", "DB_Baggerpumpe_2.Ist_U_min_BP2", "DB_Analoganzeigen_Pult.Saugdruck_BP1_Real_Visu", "DB_Baggerpumpe_1.Ist_U_min_BP1", ;
			"DB_Analoganzeigen_Pult.Foerdergeschw_REAL_Visu", "DB_Z‰hler Winden.Zaehler_SW_BB_7", "DB_Analoganzeigen_Pult.Druck_Hyd_Pumpe_2_3_Visu", "DB_Baggerpumpe_2.Ist_Strom_BP2", ;
			"DB_Analoganzeigen_Pult.Seillast_REAL_VISU", "DP/DP_Kamat_HD.Ist_U_min_HD_PUMPE", "DB_Analoganzeigen_Pult.Druck_nach_BP2_real_Visu", "DB_Analoganzeigen_Pult.Tiefe_Leiter_PED550_Visu", ;
			"F¸llstand_Druck_Land.Druck_vor_BP2_Land_bar_r", "F¸llstand_Druck_Land.Fuell_Vorlage_maximu_aus", "DB_Analoganzeigen_Pult.Druck_SW_STB_REAL_VISU", "DB_Z‰hler Winden.Zaehler_STP_BB_7", "DP/DP_Kamat_HD.Kamat_HD_PUMPE_Soll_Umin",;
			"DB_Leiterwinde.Baggertiefe_WSP", "F¸llstand_Druck_Land.Fuell_Sumpf_minimu_ein", "DB_Analoganzeigen_Pult.Sandmenge_t_tag_Visu", "F¸llstand_Druck_Land.Fuell_Sumpf_Land_real", ;
			"DB_Z‰hler Winden.Zaehler_STP_StB_7", "F¸llstand_Druck_Land.Fuell_Sumpf_Land_U_min", "F¸llstand_Druck_Land.Druck_nach_BP2_La_bar_r", "DB_Analoganzeigen_Pult.Druck_vor_BP1_REAL_Visu", "Tiefenberechnung.Baggertiefe" }

	WAIT WINDOW "Preparing a test file. This may take some time .... "  NOWAIT 

	ShowProgressBar( 2 )		//show progress bar
	Form_1.StatusBar.Item(1) := "Preparing a test file. This may take some time .... "
	
	hTestFile := hb_FCreate( cFileToOpen, FC_NORMAL, FO_EXCLUSIVE)
	
	x := 0
	FOR  i := 1 TO nMaxRec
		x++
		IF x > Len( aTestRec )
			x := 1
		ENDIF
		FWrite( hTestFile, StrZero (i, 8) + cDelimiter + '"' + aTestRec [ x ] + '"' + cDelimiter + '"' + hb_TSToStr(hb_DateTime()) + '"' + cDelimiter + AllTrim (Str ( hb_Rand32() ) ) + cDelimiter + AllTrim( Str( hb_RandomInt() ) ) + cDelimiter + AllTrim( Str( hb_TtoN(hb_DateTime()) ) ) + CRLF )
		IF i % (nMaxRec/100) == 0
			WAIT WINDOW "Preparing a test file. This may take some time .... " + Str (i / nMaxRec * 100) + " % " NOWAIT
			Form_1.PBar.Value := i / nMaxRec * 100
			Do Events
		ENDIF
	Next i
	FClose( hTestFile )
	
	Form_1.StatusBar.Item(1) := ""
	ShowProgressBar( 0 )		//hide progress bar
	
	WAIT CLEAR
ENDIF

RETURN Nil
*********************************************

FUNCTION Test ( nTest , cFileToOpen )
Local oFile, nStartTime

IF nTest = 1

	hb_FUSE( cFileToOpen )

	HB_FGoTo (1)
	MessageRecNo( 1, HB_FReadLn () )
	
	HB_FGoTo (2)
	MessageRecNo( 2, HB_FReadLn () )
	
	HB_FGoTo (3)
	MessageRecNo( 3, HB_FReadLn () )
	
	HB_FGoTo (4)
	MessageRecNo( 4, HB_FReadLn () )
	
	HB_FGoTo (5)
	MessageRecNo( 5, HB_FReadLn () )
	
	HB_FGoTo (2)
	MessageRecNo( 2, HB_FReadLn () )
	
	HB_FGoTo (3)
	MessageRecNo( 3, HB_FReadLn () )
	
	WAIT WINDOW "Counting the number of records ..."  NOWAIT
	
	MsgInfo ( Str( HB_FLastRec() ) + " records have been enumerated." )
	
	WAIT CLEAR
	
	hb_FUSE()

ELSE

	oFile := vfFileRead():New( cFileToOpen )
	oFile:Open()
	
	IF oFile:Error()
		MsgStop ("Error " + Str( oFile:ErrorNo() ) )
		RETURN Nil
	ENDIF

	oFile:GoTo( 1 )
	MessageRecNo( 1, oFile:ReadLine() )
	
	oFile:GoTo( 2 )
	MessageRecNo( 2, oFile:ReadLine() )
	
	oFile:GoTo( 3 )
	MessageRecNo( 3, oFile:ReadLine() )
	
	oFile:GoTo( 4 )
	MessageRecNo( 4, oFile:ReadLine() )
	
	oFile:GoTo( 5 )
	MessageRecNo( 5, oFile:ReadLine() )
	
	oFile:GoTo( 2 )
	MessageRecNo( 2, oFile:ReadLine() )
	
	oFile:GoTo( 3 )
	MessageRecNo( 3, oFile:ReadLine() )
	
	WAIT WINDOW "Counting the number of records ..."  NOWAIT
	
	ShowProgressBar( 2 )		//show progress bar
	Form_1.StatusBar.Item(1) := "Counting the number of records ... This may take some time .... "

	//code block executed while the CountLines() method is running
	oFile:exGauge := { | nPos, nLastPos, nLines, cState | ( Form_1.StatusBar.Item(1) := "Counting the number of records: " + AllTrim ( Str ( nLines )) + "... This may take some time ... " + cState, Form_1.PBar.Value := nPos / nLastPos * 100, DoEvents() ) }
	
	nStartTime := Seconds()
	MsgInfo ( Str( oFile:CountLines() ) + " records have been enumerated is seconds: " + AllTrim (Str( Seconds() - nStartTime ) ) )
	
	Form_1.StatusBar.Item(1) := ""
	ShowProgressBar( 0 )		//hide progress bar
	
	WAIT CLEAR

	oFile:Close()

ENDIF
		

RETURN Nil 

*********************************************
FUNCTION MessageRecNo( nValidRec, cRec )
IF Val( cRec ) == nValidRec
	MsgInfo ( cRec ,"The record number is correct." )
ELSE
	MsgStop ( cRec ,"The record number is invalid!, should be " +AllTrim( Str( nValidRec ) ) )
ENDIF                 
RETURN  Nil

***************************************************************************
Function ShowProgressBar( nMode, nMin, nMax, nCol, nLenght )
Default nMode := 1		//1 = init, 2 = set/show, 3 = close, 0/other = hide
Default nMin:=1, nMax:=100
Default nCol:=20, nLenght:=740
DO CASE 
	Case nMode = 1 
		DEFINE PROGRESSBAR PBar
			PARENT Form_1
			ROW    5 
			COL    nCol
			WIDTH  nLenght
			HEIGHT 12
			RANGEMIN nMin
			RANGEMAX nMax
			VALUE nMin
			TOOLTIP ""
			HELPID Nil
			VISIBLE .F.
			SMOOTH .T.
			VERTICAL .F. 
			BACKCOLOR Nil
			FORECOLOR Nil
		END PROGRESSBAR
		
		/* put the progress bar in the status bar */
		SETPARENT(Form_1.PBar.Handle, Form_1.STATUSBAR.Handle)
		
	Case nMode = 3
		Form_1.PBar.Release
		
	Case nMode = 2
		Form_1.PBar.RangeMin :=  nMin
		Form_1.PBar.RangeMax :=  nMax
		Form_1.PBar.Value :=  nMin
		Form_1.PBar.Visible := .T.
		DO EVENTS
	
	Other
		Form_1.PBar.Visible := .F.
		DO EVENTS
ENDCASE
RETURN Nil


#pragma BEGINDUMP   

#include <mgdefs.h>
#include <psapi.h>


//        GlobalMemoryStatusEx () --> return array with 7 numbers
HB_FUNC ( GLOBALMEMORYSTATUSEX )
{
   MEMORYSTATUSEX statex;
   statex.dwLength = sizeof (MEMORYSTATUSEX);
   GlobalMemoryStatusEx (&statex);   // reflects the state of memory at the time of the call
   hb_reta (7);
   hb_storvnll ( statex.dwMemoryLoad     , -1, 1 );   // approximate percentage of physical memory that is in use (0 indicates no memory use and 100 indicates full memory use)
   hb_storvnll ( statex.ullTotalPhys     , -1, 2 );   // amount of actual physical memory, in bytes
   hb_storvnll ( statex.ullAvailPhys     , -1, 3 );   // amount of physical memory currently available, in bytes
   hb_storvnll ( statex.ullTotalPageFile , -1, 4 );   // current committed memory limit for the system or the current process, whichever is smaller, in bytes
   hb_storvnll ( statex.ullAvailPageFile , -1, 5 );   // maximum amount of memory the current process can commit, in bytes
   hb_storvnll ( statex.ullTotalVirtual  , -1, 6 );   // size of the user-mode portion of the virtual address space of the calling process, in bytes
   hb_storvnll ( statex.ullAvailVirtual  , -1, 7 );   // amount of unreserved and uncommitted memory currently in the user-mode portion of the virtual address space of the calling process, in bytes
}


//        SetParent (hWndChild, hWndNewParent)
HB_FUNC ( SETPARENT )
{
   HWND hWndChild     = (HWND) HB_PARNL (1);
   HWND hWndNewParent = (HWND) HB_PARNL (2);
   hb_retnl ((LONG_PTR)  SetParent (hWndChild, hWndNewParent) );
}


//        GetProcessMemoryInfo ( [ ProcessID ] )  --> return array with 9 numbers
HB_FUNC ( GETPROCESSMEMORYINFO )
{
   typedef BOOL (WINAPI *Func_GetProcessMemoryInfo) (HANDLE,PPROCESS_MEMORY_COUNTERS,DWORD);
   static Func_GetProcessMemoryInfo pGetProcessMemoryInfo = NULL;

   PROCESS_MEMORY_COUNTERS pmc;

   DWORD ProcessID;

   HANDLE hProcess;

   if (pGetProcessMemoryInfo == NULL)
   {   HMODULE hLib = LoadLibrary (TEXT("Kernel32.dll"));
       pGetProcessMemoryInfo = (Func_GetProcessMemoryInfo) GetProcAddress(hLib, "K32GetProcessMemoryInfo");
   }

   if (pGetProcessMemoryInfo == NULL)
   {   HMODULE hLib = LoadLibrary (TEXT("Psapi.dll"));
       pGetProcessMemoryInfo = (Func_GetProcessMemoryInfo) GetProcAddress(hLib, "GetProcessMemoryInfo");
   }

   if (pGetProcessMemoryInfo == NULL)
       return;

   ProcessID = HB_ISNUM (1) ? (DWORD) hb_parnl(1) : GetCurrentProcessId();

   hProcess = OpenProcess (PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessID);
   if (NULL == hProcess)
       return;

   pmc.cb = sizeof(pmc);
   if (pGetProcessMemoryInfo (hProcess, &pmc, sizeof(pmc)))
   {
       hb_reta (9);
       hb_storvnll ( pmc.PageFaultCount             , -1, 1 );   // The number of page faults (Numero de fallos de pagina)
       hb_storvnll ( pmc.PeakWorkingSetSize         , -1, 2 );
       hb_storvnll ( pmc.WorkingSetSize             , -1, 3 );   // The current working set size, in bytes (Cantidad de memoria fisica usada actualmente por el proceso)
       hb_storvnll ( pmc.QuotaPeakPagedPoolUsage    , -1, 4 );
       hb_storvnll ( pmc.QuotaPagedPoolUsage        , -1, 5 );   // The current paged pool usage, in bytes (Uso actual del bloque de memoria paginado)
       hb_storvnll ( pmc.QuotaPeakNonPagedPoolUsage , -1, 6 );
       hb_storvnll ( pmc.QuotaNonPagedPoolUsage     , -1, 7 );   // The current nonpaged pool usage, in bytes (Uso actual del bloque de memoria no paginado)
       hb_storvnll ( pmc.PagefileUsage              , -1, 8 );   // Total amount of memory that the memory manager has committed for the running this process, in bytes (Cantidad de memoria virtual reservada por el sistema para el proceso)
       hb_storvnll ( pmc.PeakPagefileUsage          , -1, 9 );
   }

   CloseHandle( hProcess );
}

#pragma ENDDUMP

************************ THE END *********************