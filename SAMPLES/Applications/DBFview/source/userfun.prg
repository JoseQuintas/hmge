#include "minigui.ch"
#include "directry.ch"

Memvar cFileIni, cFileLng
*--------------------------------------------------------*
Function GetFonts()
*--------------------------------------------------------*
   Local aFontList := {}, aTmpList, a

   aTmpList := GetFontList( , , ANSI_CHARSET )

   FOR EACH a IN aTmpList
      If a[ 4 ] != 0      /* TrueType fonts only */
         Aadd( aFontList, a[ 1 ] )
      EndIf
   NEXT

Return ( aFontList )

*--------------------------------------------------------*
Function FileTime( cFileName )
*--------------------------------------------------------*
Local aFiles := Directory( cFileName )

return IF( Len( aFiles ) == 1, aFiles[ 1, F_TIME ], '' )

*--------------------------------------------------------*
Procedure SaveParameter(cSection, cEntry, uValue)
*--------------------------------------------------------*
	BEGIN INI FILE cFileIni
		SET SECTION cSection ENTRY cEntry TO uValue
	END INI
return

*-----------------------------------------------------------------------------*
Function _GetIniSections()
*-----------------------------------------------------------------------------*

Return _GetSectionNames( cFileLng )

*-----------------------------------------------------------------------------*
Function _BrowseDelete ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   Local i , _BrowseRecMap , Value , _Alias , _RecNo , _BrowseArea 

	If pcount() == 2
		i := GetControlIndex ( ControlName , ParentForm )
	Else
		i := z
	EndIf

	If LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) == 0
		Return Nil
	EndIf

	_BrowseRecMap := _HMG_aControlRangeMax [i] 

	Value := _BrowseRecMap [ LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) ]

	If Value == 0
		Return Nil
	EndIf

	_Alias := Alias()
	_BrowseArea := _HMG_aControlSpacing [i]
	If Select (_BrowseArea) == 0
		Return Nil
	EndIf
	Select &_BrowseArea
	_RecNo := RecNo()

	Go Value

	If _HMG_aControlInputMask [i] == .t.
		If Rlock()
			Delete
			Skip
			if eof()
				Go Bottom
			EndIf
			DBunlock()
			If Set ( _SET_DELETED ) == .T.
				_BrowseSetValue( '' , '' , RecNo() , i , LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) )
			EndIf

		Else

			MsgStop('Record is being editied by another user. Retry later','Delete Record')

		EndIf

	Else

		Delete
		Skip
		if eof()
			Go Bottom
		EndIf
		If Set ( _SET_DELETED ) == .T.
			_BrowseSetValue( '' , '' , RecNo() , i , LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) )
		EndIf

	EndIf

	Go _RecNo
	_BrowseRefresh ( '' , '' , i )
	if Select( _Alias ) != 0
		Select &_Alias
	Else
		Select 0
	Endif

Return Nil

#define WM_COPYDATA           74
#define CDM_OPENDBF         2000

#define WM_MENUSELECT   287
#define WM_NOTIFY	78

#define MCN_FIRST           -750
#define MCN_LAST            -759
#define MCN_SELCHANGE       (MCN_FIRST + 1)
#define MCN_SELECT          (MCN_FIRST + 4)

#define NM_CLICK	(-2)
#define NM_DBLCLK	(-3)
#define NM_SETFOCUS      -7
#define NM_KILLFOCUS	(-8)

#define LVN_ITEMCHANGED	(-101)
#define LVN_COLUMNCLICK	(-108)
#define LVN_BEGINDRAG	(-109)

#define LVN_GETDISPINFO        (-150)
#define LVN_KEYDOWN	(-155)

#define DTN_FIRST	(-760)
#define DTN_DATETIMECHANGE (DTN_FIRST+1)

#define	TBN_FIRST	(-700)
#define TBN_DROPDOWN	(TBN_FIRST-10)
#define TTN_FIRST               (-520)       // tooltips
#ifdef UNICODE
#define TTN_NEEDTEXT        	(TTN_FIRST - 10)
#else
#define TTN_NEEDTEXT         	(TTN_FIRST - 0)
#endif
#define EN_SELCHANGE		1794

#define MsgYesNo( c, t ) MsgYesNo( c, t, , , .f. )
*------------------------------------------------------------------------------*
function MyEvents ( hWnd, nMsg, wParam, lParam )
*------------------------------------------------------------------------------*
Local i, x, ws, DeltaSelect, r, xs, xd, lvc, aCellData
Local hws, hwm, k, apos, _ThisQueryTemp, ControlCount
Local nCargo, cDbf

	do case

	*(JK)*****************************************************************
	case nMsg == WM_COPYDATA
	**********************************************************************

           cDBF := GetSentMsg( lParam, @nCargo)
           IF !EMPTY(cDbf) .and. nCargo==CDM_OPENDBF .and. FILE(StrTran(cDbf, '"', ""))
              OpenDBF(cDBF)
           ENDIF

	***********************************************************************
	case nMsg == WM_MENUSELECT
	***********************************************************************
	case nMsg == WM_NOTIFY 
	***********************************************************************

		* Process ToolBar ToolTip .....................................

		If GetNotifyCode ( lParam ) = TTN_NEEDTEXT   // for tooltip TOOLBUTTON
			ws := GetNotifyId( lParam)  
			x  := Ascan ( _HMG_aControlIds , ws )
			if ( x > 0 ) .And. _HMG_aControlType [x] = "TOOLBUTTON"
				SetButtonTip ( lParam , _HMG_aControlToolTip [x] )
			endif
		endif

		i := Ascan ( _HMG_aControlHandles , GetHwndFrom (lParam) )

		if i > 0

			* Process Browse .....................................

			if _HMG_aControlType [i] = "BROWSE"
        
				* Browse Click ................................

				If	GetNotifyCode ( lParam ) == NM_CLICK  .or. ;
					GetNotifyCode ( lParam ) == LVN_BEGINDRAG	

					If LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) > 0 
						DeltaSelect := LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) - ascan ( _HMG_aControlRangeMax [i] , _HMG_aControlValue [i] )
						_HMG_aControlValue [i] :=  _HMG_aControlRangeMax [i] [ LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) ]
						_BrowseVscrollFastUpdate ( i , DeltaSelect )
						_BrowseOnChange (i)
					EndIf

					Return 0
					
				EndIf

 				* Browse Refresh On Column Size ..............

				If	GetNotifyCode ( lParam ) == -12

					hws := 0
					hwm := .F.
					For x := 1 To Len ( _HMG_aControlProcedures [i] )
						hws := hws + ListView_GetColumnWidth ( _HMG_aControlHandles [i] , x - 1 )
						If _HMG_aControlProcedures [i] [x] != ListView_GetColumnWidth ( _HMG_aControlHandles [i] , x - 1 )
							hwm := .T.
							_HMG_aControlProcedures [i] [x] := ListView_GetColumnWidth ( _HMG_aControlHandles [i] , x - 1 )
							_BrowseRefresh('','',i)
						EndIf
					Next x

					* Browse ReDraw Vertical ScrollBar If Needed ...

					If _HMG_aControlIds [i] != 0 .and. hwm == .T.
						if hws > _HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() - 4
							MoveWindow ( _HMG_aControlIds [i] , _HMG_aControlCol[i]+_HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() , _HMG_aControlRow[i] , GETVSCROLLBARWIDTH() , _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT() , .t. )
							MoveWindow ( _HMG_aControlMiscData1 [i] [1], _HMG_aControlCol[i]+_HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() , _HMG_aControlRow[i] + _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT() , GETVSCROLLBARWIDTH() , GETHSCROLLBARHEIGHT() , .t. )
						Else
							MoveWindow ( _HMG_aControlIds [i] , _HMG_aControlCol[i]+_HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() , _HMG_aControlRow[i] , GETVSCROLLBARWIDTH() , _HMG_aControlHeight[i] , .t. )
							MoveWindow ( _HMG_aControlMiscData1 [i] [1], _HMG_aControlCol[i]+_HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() , _HMG_aControlRow[i] + _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT() , 0 , 0 , .t. )
						EndIf
					EndIf

					Return 0

				EndIf

				* Browse Key Handling .........................

				If GetNotifyCode ( lParam ) = LVN_KEYDOWN

					Do Case

					Case GetGridvKey(lParam) == 78 // N

						if lGetKeyState(VK_CONTROL) // CTRL

							if _HMG_acontrolmiscdata1 [i] [2] == .T.
       								_BrowseEdit ( _hmg_acontrolhandles[i] , _HMG_acontrolmiscdata1 [i] [4] , _HMG_acontrolmiscdata1 [i] [5] , _HMG_acontrolmiscdata1 [i] [3] , _HMG_aControlInputMask [i] , .t. , _HMG_aControlFontColor [i] )  
							EndIf

						EndIf

					Case GetGridvKey(lParam) == 46 // DEL

						If _HMG_aControlMiscData1 [i] [12] == .t.
						        If MsgYesNo (_HMG_BRWLangMessage [1] , _HMG_BRWLangMessage [2] ) == .t.
								_BrowseDelete('','',i)
							EndIf
						EndIf

					Case GetGridvKey(lParam) == 36 // HOME

						_BrowseHome('','',i)
						Return 1				

					Case GetGridvKey(lParam) == 35 // END

						_BrowseEnd('','',i)
						Return 1				

					Case GetGridvKey(lParam) == 33 // PGUP

						_BrowsePrior('','',i)
						Return 1				

					Case GetGridvKey(lParam) == 34 // PGDN

						_BrowseNext('','',i)
						Return 1				

					Case GetGridvKey(lParam) == 38 // UP

						_BrowseUp('','',i)
						Return 1				

					Case GetGridvKey(lParam) == 40 // DOWN

						_BrowseDown('','',i)
						Return 1				

					EndCase

					Return 0

				EndIf

				* Browse Double Click .........................

				If GetNotifyCode ( lParam ) == NM_DBLCLK  
					
					_PushEventInfo()
					_HMG_ThisFormIndex := ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
					_HMG_ThisType := 'C'
					_HMG_ThisIndex := i
					_HMG_ThisFormName :=  _HMG_aFormNames [ _HMG_ThisFormIndex ]
					_HMG_ThisControlName :=  _HMG_aControlNames [_HMG_THISIndex]
					r := ListView_HitTest ( _HMG_aControlHandles [i] , GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [i] )  , GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [i] ) )
					If r [2] == 1
						ListView_Scroll( _HMG_aControlHandles [i] ,	-10000  , 0 ) 
						r := ListView_HitTest ( _HMG_aControlHandles [i] , GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [i] )  , GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [i] ) )
					Else
						r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [i]  , r[1] - 1 , r[2] - 1 )
						
                                                      *	CellCol				CellWidth				
						xs :=	( ( _HMG_aControlCol [i] + r [2] ) +( r[3] ))  -  ( _HMG_aControlCol [i] + _HMG_aControlWidth [i] )
						xd := 20
						If xs > -xd 
							ListView_Scroll( _HMG_aControlHandles [i] ,	xs + xd , 0 ) 
						Else
							If r [2] < 0
								ListView_Scroll( _HMG_aControlHandles [i] , r[2]	, 0 )
							EndIf
						EndIf
							r := ListView_HitTest ( _HMG_aControlHandles [i] , GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [i] )  , GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [i] ) )
						EndIf

						_HMG_ThisItemRowIndex := r[1]
						_HMG_ThisItemColIndex := r[2]
						If r [2] == 1
							r := LISTVIEW_GETITEMRECT ( _HMG_aControlHandles [i]  , r[1] - 1 )
						Else
							r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [i]  , r[1] - 1 , r[2] - 1 )
						EndIf
						_HMG_ThisItemCellRow := _HMG_aControlRow [i] + r [1]
						_HMG_ThisItemCellCol := _HMG_aControlCol [i] + r [2]
						_HMG_ThisItemCellWidth := r[3]
						_HMG_ThisItemCellHeight := r[4]

						if _hmg_acontrolmiscdata1 [i] [6] == .T. 
							_BrowseEdit ( _hmg_acontrolhandles[i] , _HMG_acontrolmiscdata1 [i] [4] , _HMG_acontrolmiscdata1 [i] [5] , _HMG_acontrolmiscdata1 [i] [3] , _HMG_aControlInputMask [i] , .f. , _HMG_aControlFontColor [i] )  
						Else 
							if valtype( _HMG_aControlDblClick [i] ) == 'B'
								Eval( _HMG_aControlDblClick [i]  )
							EndIf
						Endif

						_PopEventInfo()
						_HMG_ThisItemRowIndex := 0
						_HMG_ThisItemColIndex := 0
						_HMG_ThisItemCellRow := 0
						_HMG_ThisItemCellCol := 0
						_HMG_ThisItemCellWidth := 0
						_HMG_ThisItemCellHeight := 0

				EndIf

				* Browse LostFocus ............................

				If GetNotifyCode ( lParam ) = NM_KILLFOCUS
					_DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
					Return 0
				EndIf

				* Browse GotFocus ..............................

				If GetNotifyCode ( lParam ) = NM_SETFOCUS
					_DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
					Return 0
				EndIf

				* Browse Header Click .........................

				If GetNotifyCode ( lParam ) =  LVN_COLUMNCLICK
					if ValType ( _HMG_aControlHeadClick [i] ) == 'A'
						lvc := GetGridColumn(lParam) + 1
						if len (_HMG_aControlHeadClick [i]) >= lvc
							_DoControlEventProcedure ( _HMG_aControlHeadClick [i] [lvc] , i )
						EndIf					
					EndIf
					Return 0
				EndIf

			EndIf

			* ToolBar DropDown Button Click .......................

			If GetNotifyCode ( lParam ) == TBN_DROPDOWN 

				DefWindowProc( hWnd, TBN_DROPDOWN, wParam, lParam )
   				ws := GetButtonPos( lParam)  
		    		x  := Ascan ( _HMG_aControlIds , ws )
				k  :=_HMG_aControlValue[x]  
		    		if ( x > 0 ) .And. _HMG_aControlType [x] = "TOOLBUTTON"
					aPos := {0,0,0,0}
					GetWindowRect(_HMG_aControlHandles [i], aPos)
					ws := GetButtonBarRect(_HMG_aControlHandles [i], k-1)
					TrackPopupMenu ( _HMG_aControlRangeMax [x] , aPos[1]+LoWord(ws) ,aPos[2]+HiWord(ws)+(aPos[4]-aPos[2]-HiWord(ws))/2+1 , hWnd )
			    	EndIf

				Return 0

			EndIf

			* Grid Processing .....................................

			if _HMG_aControlType [i] = "GRID" .Or. _HMG_aControlType [i] = "MULTIGRID"

				If GetNotifyCode ( lParam ) = -181
					ReDrawWindow ( _hmg_acontrolhandles [i] )
				endif

				* Grid OnQueryData ............................

				If GetNotifyCode ( lParam ) = LVN_GETDISPINFO 

					if valtype( _HMG_aControlProcedures [i] ) == 'B'

							_PushEventInfo()
							_HMG_ThisFormIndex := ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
							_HMG_ThisType := 'C'
							_HMG_ThisIndex := i
							_HMG_ThisFormName :=  _HMG_aFormNames [ _HMG_ThisFormIndex ] 
							_HMG_ThisControlName :=  _HMG_aControlNames [_HMG_THISIndex]
							_ThisQueryTemp  := GETGRIDDISPINFOINDEX ( lParam )
							_HMG_ThisQueryRowIndex  := _ThisQueryTemp [1]
							_HMG_ThisQueryColIndex  := _ThisQueryTemp [2]
							Eval( _HMG_aControlProcedures [i]  )
							if Len ( _HMG_aControlBkColor [i] ) > 0 .And. _HMG_ThisQueryColIndex == 1
								SetGridQueryImage ( lParam , _HMG_ThisQueryData )
							Else
								SetGridQueryData ( lParam , _HMG_ThisQueryData )
							EndIf
							_HMG_ThisQueryRowIndex  := 0
							_HMG_ThisQueryColIndex  := 0
							_HMG_ThisQueryData := ""
							_PopEventInfo()

	 				EndIf

				EndIf

				* Grid LostFocus ..............................

				If GetNotifyCode ( lParam ) = NM_KILLFOCUS
					_DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
					Return 0
				EndIf

				* Grid GotFocus ...............................

				If GetNotifyCode ( lParam ) = NM_SETFOCUS
					_DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
					Return 0
				EndIf

				* Grid Change .................................
						
				If GetNotifyCode ( lParam ) = LVN_ITEMCHANGED
					If GetGridOldState(lParam) == 0 .and. GetGridNewState(lParam) != 0
						_DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
						Return 0
					EndIf
				EndIf

				* Grid Header Click ..........................

				If GetNotifyCode ( lParam ) =  LVN_COLUMNCLICK
					if ValType ( _HMG_aControlHeadClick [i] ) == 'A'
						lvc := GetGridColumn(lParam) + 1
						if len (_HMG_aControlHeadClick [i]) >= lvc
							_DoControlEventProcedure ( _HMG_aControlHeadClick [i] [lvc] , i )
							Return 0
						EndIf					
					EndIf
				EndIf

				* Grid Double Click ...........................

				If GetNotifyCode ( lParam ) == NM_DBLCLK  

					if _hmg_acontrolspacing [i] == .T.
						_EditItem ( _hmg_acontrolhandles [i] )
					Else

						if valtype(_HMG_aControlDblClick [i]  )=='B'

								_PushEventInfo()
								_HMG_ThisFormIndex := ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
								_HMG_ThisType := 'C'
								_HMG_ThisIndex := i
								_HMG_ThisFormName :=  _HMG_aFormNames [ _HMG_ThisFormIndex ]
								_HMG_ThisControlName :=  _HMG_aControlNames [_HMG_ThisIndex]
								aCellData := _GetGridCellData(i)

								_HMG_ThisItemRowIndex := aCellData [1]
								_HMG_ThisItemColIndex := aCellData [2]
								_HMG_ThisItemCellRow := aCellData [3]
								_HMG_ThisItemCellCol := aCellData [4]
								_HMG_ThisItemCellWidth := aCellData [5]
								_HMG_ThisItemCellHeight := aCellData [6]

								Eval( _HMG_aControlDblClick [i]  )
								_PopEventInfo()

								_HMG_ThisItemRowIndex := 0
								_HMG_ThisItemColIndex := 0
								_HMG_ThisItemCellRow := 0
								_HMG_ThisItemCellCol := 0
								_HMG_ThisItemCellWidth := 0
								_HMG_ThisItemCellHeight := 0

	 					EndIf

					EndIf

					Return 0

				EndIf

			EndIf

			* DatePicker Process ..................................

			if _HMG_aControlType [i] = "DATEPICK" 

				* DatePicker Change ............................

				If GetNotifyCode ( lParam ) = DTN_DATETIMECHANGE
					_DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
					Return 0
				EndIf

				* DatePicker LostFocus ........................

				If GetNotifyCode ( lParam ) = NM_KILLFOCUS
					_DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
					Return 0
				EndIf

				* DatePicker GotFocus .........................

				If GetNotifyCode ( lParam ) = NM_SETFOCUS
					_DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
					Return 0
				EndIf

			EndIf

			* StatusBar Process ...................................

			if _HMG_aControlType [i] = "MESSAGEBAR" 

				* StatusBar Click

				If GetNotifyCode ( lParam ) == NM_CLICK  
					DefWindowProc( hWnd, NM_CLICK, wParam, lParam )
					x := GetItemPos( lParam)  
					ControlCount := Len (_HMG_aControlHandles)
					For i := 1 to ControlCount
						if _HMG_aControlType [i] == "ITEMMESSAGE" .And. _HMG_aControlParentHandles [i] == hWnd
							If _HMG_aControlHandles  [i]  == x+1
								if _DoControlEventProcedure ( _HMG_aControlProcedures  [i] , i )
									Return 0
								EndIf
							EndIf
						End if
					Next i
				EndIf

			EndIf

		EndIf

	otherwise

		Return Events ( hWnd, nMsg, wParam, lParam )

    endcase

Return (0)

*-----------------------------------------------------------------------------*
STATIC FUNCTION _GetGridCellData ( i )
*-----------------------------------------------------------------------------*
   LOCAL ThisItemRowIndex
   LOCAL ThisItemColIndex
   LOCAL ThisItemCellRow
   LOCAL ThisItemCellCol
   LOCAL ThisItemCellWidth
   LOCAL ThisItemCellHeight
   LOCAL r
   LOCAL xs
   LOCAL xd
   LOCAL aCellData

   r := ListView_HitTest ( _HMG_aControlHandles [ i ], GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [ i ] ), GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [ i ] ) )

   IF r [ 2 ] == 1

      ListView_Scroll( _HMG_aControlHandles [ i ], -10000, 0 )
      r := ListView_HitTest ( _HMG_aControlHandles [ i ], GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [ i ] ), GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [ i ] ) )

   ELSEIF r[ 1 ] > 0 .AND. r[ 2 ] > 0

      r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [ i ], r[ 1 ] - 1, r[ 2 ] - 1 )

      *          CellCol                      CellWidth
      xs := ( ( _HMG_aControlCol [ i ] + r [ 2 ] ) + ( r[ 3 ] ) ) - ( _HMG_aControlCol [ i ] + _HMG_aControlWidth [ i ] )

      IF ListViewGetItemCount( _HMG_aControlHandles [ i ] ) > ListViewGetCountPerPage( _HMG_aControlHandles [ i ] )
         xd := 20
      ELSE
         xd := 0
      ENDIF

      IF xs > -xd
         ListView_Scroll( _HMG_aControlHandles [ i ], xs + xd, 0 )
      ELSE
         IF r [ 2 ] < 0
            ListView_Scroll( _HMG_aControlHandles [ i ], r[ 2 ], 0 )
         ENDIF
      ENDIF

      r := ListView_HitTest ( _HMG_aControlHandles [ i ], GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [ i ] ), GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [ i ] ) )

   ELSE

      r := AFill( Array( 4 ), 0 )

   ENDIF

   ThisItemRowIndex := r[ 1 ]
   ThisItemColIndex := r[ 2 ]

   IF r [ 2 ] == 1

      r := ListView_GetItemRect ( _HMG_aControlHandles [ i ], r[ 1 ] - 1 )

   ELSEIF r[ 1 ] > 0 .AND. r[ 2 ] > 0

      r := ListView_GetSubItemRect ( _HMG_aControlHandles [ i ], r[ 1 ] - 1, r[ 2 ] - 1 )

   ENDIF

   ThisItemCellRow := _HMG_aControlRow [ i ] + r[ 1 ]
   ThisItemCellCol := _HMG_aControlCol [ i ] + r[ 2 ]
   ThisItemCellWidth := r[ 3 ]
   ThisItemCellHeight := r[ 4 ]

   aCellData := { ThisItemRowIndex, ThisItemColIndex, ThisItemCellRow, ThisItemCellCol, ThisItemCellWidth, ThisItemCellHeight }

RETURN aCellData


#pragma BEGINDUMP

#include "mgdefs.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include <commctrl.h>

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif

HB_FUNC( FINDWINDOW )
{
#ifndef UNICODE
   LPCSTR lpszWindow = ( LPCSTR ) hb_parc( 1 );
#else
   LPWSTR lpszWindow = AnsiToWide( ( char * ) hb_parc( 1 ) );
#endif
   HB_RETNL( ( LONG_PTR ) FindWindow( 0, lpszWindow ) );

#ifdef UNICODE
   hb_xfree( lpszWindow );
#endif
}

HB_FUNC( KEYBD_DEL )
{
	keybd_event(
		VK_DELETE,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);
} 

HB_FUNC( INSERT_CTRL_N )
{
	keybd_event(
		VK_CONTROL,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	keybd_event(
		78	,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	keybd_event(
		VK_CONTROL,	// virtual-key code
		0,		// hardware scan code
		KEYEVENTF_KEYUP,// flags specifying various function options
		0		// additional data associated with keystroke
	);
}

HB_FUNC( LGETKEYSTATE )
{
	hb_retl( 0x8000 & GetKeyState( hb_parni( 1 ) ) );
}

HB_FUNC( MYSENDMSG )
{
	HWND hwnd;
	COPYDATASTRUCT cds;

	hwnd = (HWND) HB_PARNL (1);

	cds.dwData = 2000;
	cds.lpData = (char *) hb_parc(2);       
	cds.cbData = strlen((char*)cds.lpData); 

	SendMessage(hwnd,WM_COPYDATA,0,(LPARAM)&cds);
}

#ifndef __XHARBOUR__
   #define ISBYREF( n )          HB_ISBYREF( n )
#endif

HB_FUNC( GETSENTMSG )
{
   PCOPYDATASTRUCT pcds = (PCOPYDATASTRUCT) HB_PARNL( 1 );
   if( pcds ) 
   {    
   if( pcds->lpData )
   {
     hb_retclen(  pcds->lpData,  pcds->cbData );
   }
   else 
   {
     hb_retc( "" );
   }
   }
   else 
   {
      hb_retc( "" );  
   }
   if ISBYREF( 2 )
   {
      hb_stornl( pcds->dwData, 2 );
   }
}

#pragma ENDDUMP
