
*--------------------------------------------------------*
FUNCTION BrowStru( DBUstruct, aSqlStru, cTable, lNewTab, aSeq )
*--------------------------------------------------------*
   LOCAL oGrid_1, n, Mod := 0
   LOCAL aType := { "SQLITE_TEXT", "SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_BLOB", "SQLITE_NULL" }
   DEFAULT lNewTab := FALSE, aSeq := {}

   IF ( .NOT. IsWIndowActive ( FrameStru ) )
      DEFINE WINDOW FrameStru ;
            AT 0, 0 WIDTH 900 ;
            HEIGHT 430 ;
            TITLE "VIEW Table Structure" ;
            NOSIZE

         @ 15, 40 LABEL Lbl_TabNam ;
            VALUE "Table Name" ;
            WIDTH 80 ;

            @ 15, 140 TEXTBOX Table_Name ;
            WIDTH 150 ;
            UPPERCASE ;
            VALUE cTable ;
            ON CHANGE {|| FrameStru.Btn_AddTab.Enabled := ! Empty( FrameStru.Table_Name.Value ) .AND. oGrid_1:nLen > 0 .AND. ! oGrid_1:lPhantArrRow }

         FrameStru.Table_Name.READONLY := ! lNewTab
         IF lNewTab
            DBUstruct := {}
            FrameStru.Table_Name.BACKCOLOR := DBUgreen
            @ 15, 310 BUTTON Btn_AddTab ;
               CAPTION "Add Table" ;
               ACTION {|| if( CreateNewTable( oGrid_1, FrameStru.Table_Name.Value ), FrameStru.RELEASE, Nil ) }
            FrameStru.Btn_AddTab.Enabled := FALSE
         ENDIF

         @ 50, 10 FRAME Frame_2 ;
            CAPTION "Structure of SQLITE" ;
            WIDTH 600 ;
            HEIGHT 280

         DEFINE TBROWSE oGrid_1 AT 70, 20 ARRAY DBUstruct ;
               WIDTH 580 HEIGHT 250 ;
               HEADERS "Lp", "Name", "Type", "Init Type", "Size", "" + CRLF + "Dec." + CRLF + "(Max)", "" + CRLF + "Not" + CRLF + "Null", "" + CRLF + "Prim." + CRLF + "Key", "Incr", "" + CRLF + "Incr." + CRLF + "Value" ;
               WIDTHS 20, 130, 110, 75, 40, 40, 30, 35, 30, 50 ;
               SELECTOR 18 ;
               ON CHANGE onChangeRec( oGrid_1, aSqlStru ) ;
               ON DBLCLICK EditRecStru( oGrid_1 )

            oGrid_1:nLineStyle := LINES_VERT
            oGrid_1:nHeightCell += 1
            oGrid_1:nHeightHead += 8
            oGrid_1:Set3DText( FALSE, FALSE )
            oGrid_1:nWheelLines := 3
            oGrid_1:SetAppendMode( TRUE )


            oGrid_1:SetColor( { 1, 3, 5, 6, 13, 15, 17 }, ;
               { CLR_BLACK, CLR_YELLOW, CLR_RED, -3, ;
               CLR_HGREEN, CLR_BLACK, ; // text colors
            CLR_YELLOW } ) // text superheader
            oGrid_1:SetColor( { 2, 4, 14, 16 }, ;
               { { CLR_WHITE, CLR_HGRAY }, ; // degraded cells background color
            { CLR_WHITE, CLR_BLACK }, ;  // degraded headers backgroud color
            { CLR_HGREEN, CLR_BLACK }, ;  // degraded order column background color
            { CLR_WHITE, CLR_BLACK } } ) // degraded superheaders backgroud color
            oGrid_1:SetData( 3, ComboWBlock( oGrid_1, 3, 3, aType ) )
            oGrid_1:SetColor( { 1, 2 }, { CLR_BLACK, {|| if( ! oGrid_1:lPhantArrRow .AND. ( RTrim(Eval( oGrid_1:aColumns[ 5 ]:bData ) ) == 'FLOAT' .OR. Eval( oGrid_1:aColumns[ 7 ]:bData ) == 0 ), { CLR_WHITE, CLR_HGRAY }, ;
               { CLR_WHITE, CLR_HRED } ) } }, 6 )

            FOR n := 7 TO 9
               oGrid_1:aColumns[ n ]:lCheckBox := TRUE
               oGrid_1:aColumns[ n ]:cDataType := 'L'
            NEXT
            oGrid_1:aColumns[ 10 ]:nAlign := DT_CENTER
         END TBROWSE

         @ 20, 620 FRAME Frame_1 ;
            WIDTH 260 ;
            HEIGHT 310 ;
            CAPTION "Info Fields" ;

            @ 50, 630 LABEL Lbl_name WIDTH 60 BACKCOLOR DBUblue VALUE "Name"
         @ 80, 630 LABEL Lbl_type WIDTH 60 BACKCOLOR DBUblue VALUE "Type"
         @ 110, 630 LABEL Lbl_IniType WIDTH 60 BACKCOLOR DBUblue VALUE "Init Type"
         @ 140, 630 LABEL Lbl_Options WIDTH 60 HEIGHT 25 BACKCOLOR DBUblue VALUE "Options"
         @ 170, 630 LABEL Lbl_size WIDTH 60 BACKCOLOR DBUblue VALUE "Size"
         @ 195, 630 LABEL Lbl_decimal WIDTH 60 BACKCOLOR DBUblue VALUE "Decimals"

         @ 50, 700 TEXTBOX Text_Name ;
            WIDTH 100 ;
            UPPERCASE ;
            VALUE "" ;
            READONLY ;
            ON CHANGE OnChangeType( FrameStru.Text_Type.VALUE, oGrid_1, Mod )

         @ 80, 700 COMBOBOX Text_Type ;
            ITEMS aType ;
            WIDTH 110 ;
            VALUE 0 ;
            ON CHANGE OnChangeType( FrameStru.Text_Type.VALUE, oGrid_1, Mod )

         @ 110, 700 TEXTBOX Text_IniType ;
            VALUE '' ;
            WIDTH 120 ;
            READONLY

         @ 135, 700 RADIOGROUP Radio_1 ;
            OPTIONS { 'Char', 'Date', 'DateTime' } ;
            VALUE 0 ;
            WIDTH 59 ;
            SPACING 0 ;
            FONT 'Arial' SIZE 8 ;
            HORIZONTAL ;
            ON CHANGE OnChangeType( FrameStru.Text_Type.VALUE, oGrid_1, Mod )

         @ 165, 700 TEXTBOX Text_Size ;
            VALUE 0 ;
            NUMERIC ;
            WIDTH 90 ;
            RIGHTALIGN ;
            READONLY ;
            ON CHANGE OnChangeType( FrameStru.Text_Type.VALUE, oGrid_1, Mod )

         @ 195, 700 TEXTBOX Text_Decimals ;
            VALUE 0 ;
            NUMERIC ;
            WIDTH 90 ;
            RIGHTALIGN ;
            READONLY ;
            ON CHANGE OnChangeType( FrameStru.Text_Type.VALUE, oGrid_1, Mod )

         @ 225, 630 CHECKBOX Chk_Null ;
            CAPTION 'Not Null' ;
            WIDTH 70 ;
            VALUE FALSE

         @ 225, 710 CHECKBOX Chk_Key ;
            CAPTION 'Prim.Key' ;
            WIDTH 70 ;
            VALUE FALSE ;
            ON CHANGE OnChangeType( FrameStru.Text_Type.VALUE, oGrid_1, Mod )

         @ 225, 790 CHECKBOX Chk_Incr ;
            CAPTION 'Incr.' ;
            WIDTH 50 ;
            VALUE FALSE

         @ 255, 630 BUTTON Btn_Add ;
            CAPTION "Add" ;
            WIDTH 90 ;
            ACTION Mod := OnModRecStru( oGrid_1, cTable, 2, lNewTab )

         @ 255, 730 BUTTON Btn_Mod ;
            CAPTION "Modyfication" ;
            WIDTH 100 ;
            ACTION Mod := OnModRecStru( oGrid_1, cTable, 1, lNewTab )

         @ 290, 630 BUTTON Btn_Del ;
            CAPTION "Delete" ;
            WIDTH 90 ;
            ACTION Mod := OnModRecStru( oGrid_1, cTable, 3, lNewTab )

         @ 290, 730 BUTTON Btn_Cancel ;
            CAPTION "Cancel" ;
            WIDTH 100 ;
            ACTION Mod := CancelEdit( oGrid_1 )

         DEFINE BUTTON BtnChgRec
            ROW 350
            COL 20
            CAPTION "Change Rec"
            ACTION Mod := EditRecStru( oGrid_1, 1 )
         END BUTTON

         DEFINE BUTTON BtnAddRec
            ROW 350
            COL 170
            CAPTION "Add Rec"
            ACTION Mod := EditRecStru( oGrid_1, 0 )
         END BUTTON

         DEFINE BUTTON BtnModNull
            ROW 350
            COL 320
            CAPTION "Modify NULL"
            ACTION SqlNullUpdate( cTable, oGrid_1 )
         END BUTTON

         DEFINE BUTTON _DBUexitnew
            ROW 350
            COL 470
            CAPTION "Exit"
            ACTION ThisWindow.RELEASE
         END BUTTON

      END WINDOW
      FrameStru.BtnChgRec.Enabled := ( oGrid_1:nLen > 0 .AND. ! oGrid_1:lPhantArrRow )
      FrameStru.BtnModNull.Enabled := FALSE
      FrameStru.Btn_Add.Enabled := FALSE
      FrameStru.Btn_Mod.Enabled := FALSE
      FrameStru.Btn_Del.Enabled := FALSE
      FrameStru.Btn_Cancel.Enabled := FALSE
      FrameStru.Radio_1.Enabled := FALSE
      FrameStru.Radio_1.Visible := FALSE
      FrameStru.Chk_Null.Enabled := FALSE
      FrameStru.Chk_Key.Enabled := FALSE
      FrameStru.Chk_Incr.Enabled := FALSE

      CENTER WINDOW FrameStru

      ACTIVATE WINDOW FrameStru
   ELSE
      MsgInfo( "The window is already active.", "Attention!" )
   ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION EditRecStru( oGrid, Mod )
*--------------------------------------------------------*
   LOCAL aType := { "SQLITE_TEXT", "SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_BLOB", "SQLITE_NULL" }
   LOCAL nAt := oGrid:nAt
   LOCAL nPos, nKey, lKey := FALSE, lIncr := FALSE

   if ! oGrid:lPhantArrRow
      nKey := AScan( oGrid:aArray, {| x | x[ 8 ] == TRUE } )
   ENDIF

   IF Mod == 0
      nPos := 0
      lKey := nKey == 0
   ELSE
      nPos := AScan( aType, oGrid:aArray[ nAt, 3 ] )
      nPos := Max( 1, nPos )
      lKey := nKey == nAt
      lIncr := lKey
   ENDIF

   FrameStru.Text_IniType.VALUE := if( Mod == 1, oGrid:aArray[ nAt, 4 ], '' )
   FrameStru.Text_Name.VALUE := if( Mod == 1, oGrid:aArray[ nAt, 2 ], '' )
   FrameStru.Text_Type.VALUE := nPos
   FrameStru.Text_Size.VALUE := if( Mod == 1, oGrid:aArray[ nAt, 5 ], 0 )
   FrameStru.Text_Decimals.VALUE := if( Mod == 1, oGrid:aArray[ nAt, 6 ], 0 )
   FrameStru.Chk_Null.VALUE := if( Mod == 1, oGrid:aArray[ nAt, 7 ], FALSE )
   FrameStru.Chk_Key.VALUE := if( Mod == 1, oGrid:aArray[ nAt, 8 ], FALSE )
   FrameStru.Chk_Incr.VALUE := if( Mod == 1, oGrid:aArray[ nAt, 9 ], FALSE )

   FrameStru.Text_Name.BACKCOLOR := DBUgreen
   FrameStru.Text_Type.BACKCOLOR := DBUgreen
   FrameStru.Text_Size.BACKCOLOR := DBUgreen
   FrameStru.Text_Decimals.BACKCOLOR := DBUgreen
   FrameStru.Text_Name.READONLY := FALSE
   FrameStru.Text_Type.READONLY := FALSE
   FrameStru.Text_Size.READONLY := FALSE
   FrameStru.Text_Decimals.READONLY := FALSE
   FrameStru.Chk_Incr.Enabled := lIncr
   FrameStru.Chk_Null.Enabled := TRUE
   FrameStru.Chk_Key.Enabled := lKey

   FrameStru.Btn_Cancel.Enabled := TRUE
   FrameStru.BtnChgRec.Enabled := FALSE
   FrameStru.BtnAddRec.Enabled := FALSE
   IF Mod == 0
      FrameStru.Btn_Mod.Enabled := FALSE
      FrameStru.Btn_Add.Enabled := TRUE
      FrameStru.Btn_Del.Enabled := FALSE
      FrameStru.Text_Name.READONLY := FALSE
      FrameStru.Text_Name.BACKCOLOR := DBUgreen
   ELSE
      FrameStru.Btn_Mod.Enabled := TRUE
      FrameStru.Btn_Add.Enabled := FALSE
      FrameStru.Btn_Del.Enabled := TRUE
      FrameStru.Text_Name.READONLY := TRUE
      FrameStru.Text_Name.BACKCOLOR := CLR_HGRAY
   ENDIF

RETURN Mod


*--------------------------------------------------------*
FUNCTION OnModRecStru( oGrid, cTable, mod, lNewTab )
*--------------------------------------------------------*
   LOCAL cRecName, cRecType, cRecIniType, cRecSize, cRecDec, lNull, lKey, lIncr, cIncr, dBStru := {}, n, aItem
   LOCAL nPos
   LOCAL nRow
   cRecName := FrameStru.Text_Name.VALUE
   cRecType := FrameStru.Text_Type.DisplayValue
   cRecIniType := FrameStru.Text_IniType.VALUE
   cRecSize := FrameStru.Text_Size.VALUE
   cRecDec := FrameStru.Text_Decimals.VALUE
   lIncr := FrameStru.Chk_Incr.VALUE
   lNull := FrameStru.Chk_Null.VALUE
   lKey := FrameStru.Chk_Key.VALUE
   cIncr := if( Mod == 1, oGrid:aArray[ oGrid:nAt, 10 ], '' )
   IF lNewTab
      nPos := oGrid:nAt
      nRow := if( mod == 2, oGrid:nLen + if( oGrid:lPhantArrRow, 0, 1 ), nPos )
      aItem := { nRow, cRecName, cRecType, cRecIniType, cRecSize, cRecDec, lNull, lKey, lIncr, '' }
      IF Mod == 2
         IF oGrid:lPhantArrRow
            oGrid:Del()
            oGrid:lPhantArrRow := FALSE
         ENDIF
         AAdd( oGrid:aArray, aItem )
         oGrid:UpAStable()

      ELSEIF Mod == 1
         FOR n := 1 TO Len( aItem )
            oGrid:aArray[ oGrid:nAt, n ] := aItem[ n ]
         NEXT
      ELSEIF mod == 3
         oGrid:Del()
         oGrid:UpAStable()
      ENDIF
      CancelEdit( oGrid )
      FrameStru.Btn_AddTab.Enabled := ! Empty( FrameStru.Table_Name.Value ) .AND. oGrid:nLen > 0 .AND. ! oGrid:lPhantArrRow

   ELSE
      IF Mod == 2
         IF AScan( oGrid:aArray, {| x | RTrim( x[ 2 ] ) == RTrim( cRecName ) } ) > 0
            MsgInfo( "Column Name " + cRecName + " exist in Table " + cTable )
            RETURN Mod
         ENDIF
      ENDIF
      AEval( oGrid:aArray, {| x | AAdd( dBStru, { x[ 2 ], x[ 3 ], x[ 4 ], x[ 5 ], x[ 6 ], x[ 7 ], x[ 8 ], x[ 9 ] } ) } )

      IF mod == 3
         oGrid:Del()
      ENDIF
      IF mod == 1
         oGrid:aArray[ oGrid:nAt, 3 ] := cRecType
         oGrid:aArray[ oGrid:nAt, 4 ] := cRecIniType
         oGrid:aArray[ oGrid:nAt, 5 ] := cRecSize
         oGrid:aArray[ oGrid:nAt, 6 ] := cRecDec
         oGrid:aArray[ oGrid:nAt, 7 ] := lNull
         oGrid:aArray[ oGrid:nAt, 8 ] := lKey
         oGrid:aArray[ oGrid:nAt, 9 ] := lIncr
         oGrid:aArray[ oGrid:nAt, 10 ] := cIncr
         oGrid:Refresh()
      ELSEIF Mod == 2
         nRow := Len( oGrid:aArray )
         aItem := { nRow + 1, cRecName, cRecType, cRecIniType, cRecSize, cRecDec, lNull, lKey, lIncr, cIncr }
         AAdd( oGrid:aArray, aItem )
         oGrid:UpAStable()
      ENDIF
      IF AlterRec( oGrid, cTable, cRecName, cRecIniType, Mod, dBStru )
         CancelEdit( oGrid )
      ENDIF
      FrameStru.BtnChgRec.Enabled := oGrid:nLen > 0 .AND. ! oGrid:lPhantArrRow
      FrameStru.BtnAddRec.Enabled := TRUE
   ENDIF

RETURN Mod

*--------------------------------------------------------*
FUNCTION CancelEdit( oGrid )
*--------------------------------------------------------*
   FrameStru.Text_Name.VALUE := ''
   FrameStru.Text_Type.VALUE := 0
   FrameStru.Text_IniType.VALUE := ''
   FrameStru.Text_Size.VALUE := ''
   FrameStru.Text_Decimals.VALUE := ''
   FrameStru.Chk_Incr.VALUE := FALSE
   FrameStru.Chk_Null.VALUE := FALSE
   FrameStru.Chk_Key.VALUE := FALSE

   FrameStru.Text_Name.READONLY := TRUE
   FrameStru.Text_IniType.READONLY := TRUE
   FrameStru.Text_Size.READONLY := TRUE
   FrameStru.Text_Decimals.READONLY := TRUE
   FrameStru.Chk_Incr.Enabled := FALSE
   FrameStru.Chk_Null.Enabled := FALSE
   FrameStru.Chk_Key.Enabled := FALSE


   FrameStru.Text_Name.BACKCOLOR := CLR_HGRAY
   FrameStru.Text_IniType.BACKCOLOR := CLR_HGRAY
   FrameStru.Text_Size.BACKCOLOR := CLR_HGRAY
   FrameStru.Text_Decimals.BACKCOLOR := CLR_HGRAY

   FrameStru.Btn_Mod.Enabled := FALSE
   FrameStru.Btn_Mod.Enabled := FALSE
   FrameStru.Btn_Add.Enabled := FALSE
   FrameStru.Btn_Del.Enabled := FALSE
   FrameStru.Btn_Cancel.Enabled := FALSE
   FrameStru.BtnChgRec.Enabled := oGrid:nLen > 0 .AND. ! oGrid:lPhantArrRow
   FrameStru.BtnAddRec.Enabled := TRUE
   FrameStru.Radio_1.VALUE := 0
   FrameStru.Radio_1.Visible := FALSE

RETURN 0

*--------------------------------------------------------*
FUNCTION OnChangeRec( oGrid, aSqlStru )
*--------------------------------------------------------*
   LOCAL nAt := oGrid:nAt
   IF IsControlDefined ( BtnModNull, FrameStru )
      IF nAt <= Len( aSqlStru )
         IF AllTrim( aSqlStru[ nAt, 2 ] ) == "SQLITE_NULL"
            FrameStru.BtnModNull.Enabled := TRUE
         ELSE
            FrameStru.BtnModNull.Enabled := FALSE
         ENDIF
      ELSE
         FrameStru.BtnModNull.Enabled := FALSE
      ENDIF
   ENDIF

RETURN NIL


*--------------------------------------------------------*
FUNCTION OnChangeType( nType, oGrid, Mod )
*--------------------------------------------------------*
   LOCAL nKey := 0, lIncr := FALSE, lKey := FALSE
   if ! oGrid:lPhantArrRow
      nKey := AScan( oGrid:aArray, {| x | x[ 8 ] == TRUE } )
   ENDIF
   IF Mod == 1
      IF nKey > 0
         lIncr := oGrid:aArray[ nKey, 8 ] .AND. nKey == oGrid:nAt
         lKey := oGrid:aArray[ nKey, 8 ] .AND. nKey == oGrid:nAt
      ELSE
         lIncr := TRUE
         lKey := TRUE
      ENDIF
   ELSE
      lIncr := nKey == 0
      lKey := nKey == 0
   ENDIF
   FrameStru.Chk_Incr.Enabled := FALSE
   FrameStru.Chk_Key.Enabled := lKey
   DO CASE
   CASE nType == 1
      FrameStru.Chk_Incr.Enabled := FALSE
      FrameStru.Chk_Incr.VALUE := FALSE
      FrameStru.Radio_1.Visible := TRUE
      FrameStru.Radio_1.Enabled := TRUE
      FrameStru.Radio_1.Caption( 1 ) := 'Char'
      FrameStru.Radio_1.Caption( 2 ) := 'Date'
      FrameStru.Radio_1.Caption( 3 ) := 'DateTime'

      FrameStru.Text_Size.VALUE := if( Empty( FrameStru.Text_Size.Value ), 0, FrameStru.Text_Size.Value )
      FrameStru.Text_Size.Enabled := TRUE
      FrameStru.Text_Decimals.VALUE := 0
      FrameStru.Text_Decimals.Enabled := FALSE

      IF FrameStru.Radio_1.VALUE == 0
         IF RTrim( FrameStru.Text_IniType.Value ) == 'DATETIME'
            FrameStru.Radio_1.VALUE := 3
         ELSEIF RTrim( FrameStru.Text_IniType.Value ) == 'DATE'
            FrameStru.Radio_1.VALUE := 2
         ELSE
            FrameStru.Radio_1.VALUE := 1
         ENDIF
      ELSEIF FrameStru.Radio_1.VALUE == 1
         FrameStru.Text_Size.Enabled := TRUE
         IF FrameStru.Text_Size.VALUE == 0
            FrameStru.Text_IniType.VALUE := 'TEXT'
         ELSE
            FrameStru.Text_IniType.VALUE := "CHAR(" + LTrim( Str( FrameStru.Text_Size.Value ) ) + ")"
         ENDIF
      ELSEIF FrameStru.Radio_1.VALUE == 2
         FrameStru.Text_IniType.VALUE := 'DATE'
         FrameStru.Text_Size.VALUE := 10
         FrameStru.Text_Size.Enabled := FALSE
      ELSEIF FrameStru.Radio_1.VALUE == 3
         FrameStru.Text_IniType.VALUE := 'DATETIME'
         FrameStru.Text_Size.VALUE := 19
         FrameStru.Text_Size.Enabled := FALSE
      ENDIF
   CASE nType == 2
      FrameStru.Radio_1.Visible := TRUE
      FrameStru.Radio_1.Enabled := TRUE
      FrameStru.Radio_1.Caption( 1 ) := 'Bool'
      FrameStru.Radio_1.Caption( 2 ) := 'Integer'
      FrameStru.Radio_1.Caption( 3 ) := ''
      FrameStru.Radio_1.Enabled( 3 ) := FALSE
      IF FrameStru.Radio_1.VALUE == 0
         IF FrameStru.Text_IniType.VALUE == 'BOOL'
            FrameStru.Radio_1.VALUE := 1
         ELSE
            FrameStru.Radio_1.VALUE := 2
         ENDIF
      ENDIF
      IF FrameStru.Text_Size.VALUE == 0
         FrameStru.Text_Size.VALUE := INT_LNG
      ENDIF
      IF FrameStru.Text_Size.VALUE == 1
         FrameStru.Radio_1.Enabled( 1 ) := TRUE
      ENDIF
      FrameStru.Chk_Incr.Enabled := lIncr
      FrameStru.Text_IniType.VALUE := 'INTEGER'
      FrameStru.Text_Decimals.VALUE := 0
      FrameStru.Text_Size.Enabled := TRUE
      FrameStru.Text_Decimals.Enabled := FALSE
      IF FrameStru.Chk_Key.VALUE
         FrameStru.Radio_1.VALUE := 2
         FrameStru.Radio_1.Enabled( 1 ) := FALSE
      ELSE
         FrameStru.Radio_1.Enabled( 1 ) := TRUE
      ENDIF
      IF FrameStru.Text_Size.VALUE == 1 .AND. FrameStru.Radio_1.VALUE == 1
         FrameStru.Text_IniType.VALUE := 'BOOL'
         FrameStru.Radio_1.Enabled( 1 ) := TRUE
      ELSEIF FrameStru.Radio_1.VALUE == 2
         FrameStru.Text_IniType.VALUE := 'INTEGER'
         IF FrameStru.Text_Size.Value > 1
            FrameStru.Radio_1.Enabled( 1 ) := FALSE
         ENDIF
      ENDIF

   CASE nType == 3
      FrameStru.Radio_1.Visible := FALSE
      FrameStru.Text_Size.VALUE := FL_LNG
      FrameStru.Text_IniType.VALUE := "FLOAT"
      FrameStru.Text_Decimals.VALUE := FL_DEC
      FrameStru.Text_Size.Enabled := FALSE
      FrameStru.Text_Decimals.Enabled := FALSE
      FrameStru.Radio_1.Enabled := TRUE
   CASE nType == 4 .OR. nType == 5
      FrameStru.Radio_1.Visible := FALSE
      IF nType == 4
         FrameStru.Text_IniType.VALUE := "BLOB"
      ENDIF
      FrameStru.Text_Size.VALUE := 0
      FrameStru.Text_Decimals.VALUE := 0
      FrameStru.Text_Size.Enabled := FALSE
      FrameStru.Text_Decimals.Enabled := FALSE
   ENDCASE

RETURN NIL


*--------------------------------------------------------*
FUNCTION SqlNullUpdate( cTable, oGrid )
*--------------------------------------------------------*
   LOCAL cField, aResult, cQuery
   LOCAL nColumn := oGrid:nAt

   IF nColumn > 0
      aResult := SQLITE_COLUMNS( cTable, pDb )
      IF Len( aResult ) > 0 .AND. Len( aResult ) >= nColumn

         cField := aResult[ nColumn, 1 ]

         cQuery := "UPDATE " + cTable + " SET  " + cField + " = ''  WHERE " + cField + " IS NULL "
         IF sqlite3_exec( pDb, cQuery ) == SQLITE_OK

            MsgInfo( "Record is updated", "Result" )

         ELSE
            MsgInfo( "Tabele " + cTable + " is not modified. " )

         ENDIF

         cQuery := "select " + cField + " from " + cTable + " where " + cField + " IS NULL"

         aResult := SQLITE_QUERY( pDb, RTrim( cQuery ) + ";" )

         IF Empty( Len( aResult ) )
            IF ! MsgRetryCancel( "No record match your query. Retry ?", "Empty" )
               RETURN 0
            ENDIF
         ENDIF

      ENDIF
   ENDIF

RETURN TRUE


*---------------------------------------------------------------------------
FUNCTION AlterRec( oGrid, cTable, cKol, cType, Mod, aDbStru )
*---------------------------------------------------------------------------
   LOCAL db
   LOCAL lRet := FALSE
   LOCAL cQuery, cInfo, EmptyVal
   LOCAL cTable2 := cTable + "Tmp"


   DO CASE
   CASE Mod == 12
      cQuery := " ALTER TABLE " + cTable + " ALTER COLLUMN " + cKol + " " + cType
      cInfo := " In Tabele " + cTable + " changend type of Column " + cKol
   CASE Mod == 2
      cQuery := " ALTER TABLE " + cTable + " ADD " + cKol + " " + cType
      cInfo := " In Tabele " + cTable + " add Collumn " + cKol
   CASE Mod == 3 .OR. Mod == 1
      cQuery := "BEGIN TRANSACTION; " + CRLF
      cQuery += QueryCrea( cTable, 2, cTable2, aDbStru ) + CRLF
      cQuery += QueryCrea( cTable, 3, cTable2, aDbStru ) + CRLF
      cQuery += "DROP TABLE " + cTable + " ;" + CRLF
      cQuery += QueryNewTbl( oGrid, cTable ) + CRLF// "CREATE TABLE t1(a,b);
      adBStru := {}
      AEval( oGrid:aArray, {| x | AAdd( adBStru, { x[ 2 ], x[ 3 ], x[ 4 ], x[ 5 ] } ) } )
      cQuery += QueryCrea( cTable2, 3, cTable, aDbStru ) + CRLF
      cQuery += "DROP TABLE " + ctable2 + ";" + CRLF
      cQuery += "COMMIT; "
      IF Mod == 1
         cInfo := " In Tabele " + cTable + " changend type of Column " + cKol
      ELSE
         cInfo := " In Tabel " + cTable + " removed Column " + cKol
      ENDIF
   ENDCASE
   db := sqlite3_open_v2( SqlDbName, SQLITE_OPEN_READWRITE + SQLITE_OPEN_EXCLUSIVE )
   IF DB_IS_OPEN( db )
      IF SQLITE_TABLEEXISTS( cTable, db )
         IF sqlite3_exec( db, cQuery ) == SQLITE_OK
            lRet := TRUE
            IF mod == 2
               IF "TEXT" $ cType .OR. "CHR" $ cType
                  EmptyVal := " '' "
               ELSE
                  EmptyVal := " 0 "
               ENDIF
               cQuery := "UPDATE " + cTable + " SET  " + cKol + " = " + EmptyVal + "  WHERE " + cKol + " IS NULL "
               IF sqlite3_exec( db, cQuery ) == SQLITE_OK
                  lRet := TRUE
               ENDIF
            ELSE
               lRet := TRUE
            ENDIF
         ELSE
            MsgInfo( "Tabele " + cTable + " is not modified. " )
         ENDIF
      ELSE
         MsgInfo( "Tabele " + cTable + " not exist in Database " + SqlDbName )
      ENDIF
   ELSE
      MsgInfo( "Baza nie mo¿e byæ otwarta w trybie EXCLUSIVE" )
   ENDIF
   IF lRet
      MsgInfo( cInfo, "Report" )
   ENDIF

RETURN lRet

/*
BEGIN TRANSACTION;
CREATE TEMPORARY TABLE t1_backup(a,b);
INSERT INTO t1_backup SELECT a,b FROM t1;
DROP TABLE t1;
CREATE TABLE t1(a,b);
INSERT INTO t1 SELECT a,b FROM t1_backup;
DROP TABLE t1_backup;
COMMIT;

*/

*--------------------------------------------------------*
FUNCTION QueryNewTbl( oGrid, cTable )
*--------------------------------------------------------*
   LOCAL i, cQuery := "CREATE TABLE IF NOT EXISTS " + cTable + " ( "
   LOCAL cFldName, cFldIniType, lNull, lKey, lIncr

   FOR i := 1 TO oGrid:nLen
      cFldName := oGrid:aArray[ i, 2 ]
      cFldIniType := oGrid:aArray[ i, 4 ]
      lNull := oGrid:aArray[ i, 7 ]
      lKey := oGrid:aArray[ i, 8 ]
      lIncr := oGrid:aArray[ i, 9 ]
      IF i > 1
         cQuery += ", "
      ENDIF
      cQuery += AllTrim( cFldName ) + " " + cFldIniType + " "
      IF lKey
         cQuery += "  PRIMARY KEY"
      ENDIF
      IF lIncr
         cQuery += "  AUTOINCREMENT"
      ENDIF
      IF lNull
         cQuery += "  NOT NULL"
      ENDIF
   NEXT
   cQuery += ");"

RETURN cQuery

*--------------------------------------------------------*
FUNCTION BrowseTable( cTable, mod )
*--------------------------------------------------------*
   LOCAL cSelect, bSetup, oBrw, aResult, aStruct
   cSelect := "SELECT * FROM " + cTable + " LIMIT 10 OFFSET 0 ;"
   aResult := SQLITE_QUERY( pDb, RTrim( cSelect ) )
   IF Empty( Len( aResult ) )
      MsgInfo( "No records in Table : " + cTable, "Empty" )
      RETURN 0
   ENDIF
   aStruct := SQLITE_COLUMNS( cTable, pDb )
   IF mod
      cSelect := "SELECT * FROM " + cTable
      IF ( .NOT. IsWIndowActive ( Form_1 ) )
         dbUseArea( TRUE,, cSelect, "TABLE",,, "UTF8" )

         SELECT TABLE
         DEFINE WINDOW Form_1 AT 0, 0 WIDTH SqlDbuwindowwidth HEIGHT SqlDbuwindowheight TITLE "Tabele: " + cTable CHILD BACKCOLOR RGB( 191, 219, 255 )

            DEFINE TBROWSE oBrw AT 10, 10 ALIAS "TABLE" WIDTH SqlDbuwindowwidth - 16 HEIGHT SqlDbuwindowheight - 30 ; // HEADER aCols ;
               AUTOCOLS SELECTOR 20 EDITABLE CELLED

               AEval( oBrw:aColumns, {| oCol, nCol | PostBlob( oBrw, oCol, nCol, aStruct, cTable, mod ) } )

               oBrw:SetAppendMode( TRUE )
               oBrw:SetDeleteMode( TRUE, TRUE, {|| SqlDelete( cTable, FALSE ) } )
            END TBROWSE
         END WINDOW
         CENTER WINDOW Form_1
         ACTIVATE WINDOW Form_1
      ELSE
         MsgInfo( "The window is already active.", "attention!" )
      ENDIF

      CLOSE TABLE
   ELSE
      bSetup := {| oBrw | SetMyBrowser( oBrw, aStruct ) }
      SBrowse( cTable, "Tabele: " + cTable, bSetup,, SqlDbuwindowwidth, SqlDbuwindowheight, TRUE )
   ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION PostBlob( oBrw, oCol, nCol, aStru, cTable, mod )
*--------------------------------------------------------*
   LOCAL cField, cFile
   DEFAULT mod := TRUE
   IF nCol <= Len( aStru ) .AND. aStru[ nCol, 3 ] == 'BLOB'
      oBrw:SetData( nCol, 'Blob' )
      IF mod
         oCol:lBtnGet := TRUE
         cField := aStru[ nCol, 1 ]
         cFile := GetCurrentFolder() + '\BlobData.dat'
         oCol:bAction := {|| SQLITE_GET_BLOB( cTable, cField, pDb, cFile ) }
         oCol:bAction := {|| ModBlob( cTable, cField ) }
      ENDIF
   ELSE
      oCol:bPostEdit := {| uVal, oBr, lApp | SqlUpdate( uVal, oBr:nCell - 1, cTable, lApp ) }
   ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION ModBlob( cTable, cField )
*--------------------------------------------------------*
   LOCAL cfile, lRet := FALSE
   cFile := GetFile ( { { "Blob Files", "*.*" } }, "Open Files", GetCurrentFolder(), FALSE, TRUE )
   if ! Empty( cFile )
      IF SQLITE_SET_BLOB( cTable, cField, pDb, cFile )
         MsgInfo( "Save BLOB into field " + cField + " - Done" )
         lRet := TRUE
      ENDIF
   ENDIF

RETURN lRet


*--------------------------------------------------------*
FUNCTION SetMyBrowser( oBrw, aStruct )
*--------------------------------------------------------*
   oBrw:nHeightCell += 5
   oBrw:nHeightHead += 5
   oBrw:nClrFocuFore := CLR_BLACK
   oBrw:nClrFocuBack := COLOR_GRID
   AEval( oBrw:aColumns, {| oCol, nCol | PostBlob( oBrw, oCol, nCol, aStruct ) } )

RETURN FALSE

*--------------------------------------------------------*
FUNCTION SqlUpdate( uVal, nCol, cTable, lApp )
*--------------------------------------------------------*
   LOCAL cQuery, i, cFldName, cQuery2, cSep := ""
   LOCAL aDbStru := dbStruct()
   LOCAL aInfo := SQLITE_COLUMNS_METADATA( pDb, cTable )
   uVal := NIL
   IF lApp
      cQuery := "INSERT INTO " + cTable + " ( "
      cQuery2 := " ) values ( "
      FOR i := 1 TO Len( aDbStru )
         if ! aInfo[ i, 8 ]
            cFldName := aDbStru[ i, 1 ]
            cQuery += cSep + cFldName
            cQuery2 += cSep + c2sql( &cFldName )
            cSep := " , "
         ENDIF
      NEXT
      cQuery += cQuery2 + " )"
   ELSE
      cFldName := aDbStru[ nCol, 1 ]
      cQuery := "UPDATE " + cTable + " SET " + cFldName + " = " + c2sql( &cFldName ) + " WHERE "
      FOR i := 1 TO Len( aDbStru )
         IF i != nCol .AND. aDbStru[ i, 2 ] != 'W' .AND. ! aInfo[ i, 8 ]
            cFldName := aDbStru[ i, 1 ]
            cQuery += cSep + cFldName + " = " + c2sql( &cFldName )
            cSep := " AND "
         ENDIF
      NEXT
      cQuery += " "
   ENDIF

   If ! rddInfo( RDDI_EXECUTE, cQuery )
      MsgStop( "Can't update record in table " + cTable + " !", "Error" )
      RETURN FALSE
   ENDIF

RETURN TRUE

*--------------------------------------------------------*
FUNCTION SqlDelete( cTable, lAll )
*--------------------------------------------------------*
   LOCAL cQuery, i, cFldName, cQueryTest, aResult
   LOCAL aDbStru := dbStruct() // , cTest

   cQuery := "DELETE FROM " + cTable
   cQueryTest := "SELECT * FROM " + cTable
   IF lAll
      IF ! MsgYesNo( "All Records from table " + cTable + " will be deleted" + CRLF + ;
            "without any choice to recover." + CRLF + CRLF + ;
            "       Continue ?", "Warning!" )
         RETURN FALSE
      ENDIF
   ELSE
      cQuery += " WHERE "
      cQueryTest += " WHERE "
      FOR i := 1 TO Len( aDbStru ) // test
         cFldName := aDbStru[ i, 1 ]
         IF i > 1 .AND. aDbStru[ i, 2 ] != 'W'
            cQuery += " AND "
            cQueryTest += " AND "
         ENDIF
         cQuery += cFldName + " = " + c2sql( &cFldName )
         cQueryTest += cFldName + " = " + c2sql( &cFldName )
         // cTest :=  c2sql(&cFldName)
      NEXT
      cQuery += " "
      cQueryTest += " "
   ENDIF

   aResult := SQLITE_QUERY( pDb, RTrim( cQueryTest ) )
   IF Empty( Len( aResult ) )
      MsgStop( "Can't Find record in table " + cTable + " !", "Error" )
      RETURN FALSE
   ELSE


      If ! rddInfo( RDDI_EXECUTE, cQuery )
         MsgStop( "Can't Delete record in table " + cTable + " !", "Error" )
         RETURN FALSE
      ELSE
         aResult := SQLITE_QUERY( pDb, RTrim( cQueryTest ) )
         IF ! Empty( Len( aResult ) )
            MsgStop( "Can't Delete record in table " + cTable + " !", "Error" )
            RETURN FALSE
         ELSE
            MsgInfo( "Deleted record in table " + cTable + " !", "Info" )
         ENDIF
      ENDIF
   ENDIF

RETURN TRUE
