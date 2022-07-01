#include "GUIDES.CH"
#include "minigui.ch"
#include "hbclass.ch"


CREATE CLASS gDBFTool

   DATA aDBFStruc    INIT {}
   DATA bDBFStruc    INIT {}
   DATA ALIAS    INIT ""
   DATA oWindow

   METHOD New( oWindow )
   METHOD Define()
   METHOD OpenDBF()
   METHOD AddField()
   METHOD DeleteField()
   METHOD FieldsToWindow()
   METHOD GetFields()
   METHOD AddAll()
   METHOD RemoveAll()

END CLASS


METHOD New( oWindow ) CLASS gDBFTool

   ::oWindow := oWindow
   ::aDBFStruc := ::OpenDBF()
   ::Define()

RETURN Self

METHOD Define() CLASS gDBFTool

   IF !Empty( ::aDBFStruc )

      DEFINE WINDOW DBFields ;
         AT 0, 0 ;
         WIDTH 716 ;
         HEIGHT 320 ;
         TITLE 'Select Database fields' ;
         MODAL ;
         NOSIZE  ;
         NOSYSMENU

      @ 10, 0.00 GRID DBGrid ;
         OF DBFields ;
         WIDTH 300.00 ;
         HEIGHT 150.00 ;
         HEADERS { "Name", "Type", "Length", "Decimals" } ;
         WIDTHS { 150, 50, 50, 50 } ;
         ITEMS ::aDBFStruc ;
         FONT 'Arial' ;
         SIZE 8.00 ;
         ON DBLCLICK ::AddField()

      @ 10, 330 BUTTON AddButton ;
         OF DBFields ;
         PICTURE 'RIGHT' ;
         ACTION ::AddField() ;
         WIDTH 50.00 ;
         HEIGHT 30.00

      @ 50, 330 BUTTON RemoveButton ;
         OF DBFields ;
         PICTURE 'LEFT' ;
         ACTION ::DeleteField();
         WIDTH 50.00 ;
         HEIGHT 30.00 ;

         @ 90, 330 BUTTON AddAllButton ;
         OF DBFields ;
         PICTURE 'DO_RIGHT' ;
         ACTION ::AddAll();
         WIDTH 50.00 ;
         HEIGHT 30.00 ;

         @ 130, 330 BUTTON RemoveAllButton ;
         OF DBFields ;
         PICTURE 'DO_LEFT' ;
         ACTION ::RemoveAll();
         WIDTH 50.00 ;
         HEIGHT 30.00 ;

         @ 10, 400 GRID DestinationGrid ;
         OF DBFields ;
         WIDTH 300.00 ;
         HEIGHT 150.00 ;
         HEADERS { "Name", "Type", "Length", "Decimals" } ;
         WIDTHS { 150, 50, 50, 50 } ;
         FONT 'Arial' ;
         SIZE 8.00 ;
         ON DBLCLICK ::DeleteField()

      @ 178, 26 LABEL CONTROL_1 ;
         OF DBFields ;
         VALUE 'Database ALIAS:' ;
         WIDTH 100 ;
         HEIGHT 30 ;
         FONT 'Arial' ;
         SIZE 8.00 ;
         TRANSPARENT ;
         FONTCOLOR { 0.00, 0.00, 0.00 }

      @ 175, 126 TEXTBOX ALiasTextBox ;
         OF DBFields ;
         HEIGHT 20 ;
         WIDTH 100 ;
         VALUE ::Alias ;
         FONT 'Arial' ;
         SIZE 8.00 ;
         UPPERCASE ;
         BACKCOLOR { 255, 255, 255 } ;
         FONTCOLOR { 0.00, 0.00, 0.00 }

      @ 188, 280 BUTTON OKButton ;
         CAPTION 'OK' ;
         ACTION ::GetFields( TRUE ) ;
         WIDTH 50 ;
         HEIGHT 30 ;
         FONT 'Arial' ;
         SIZE 8.00

      @ 188, 370 BUTTON DiscardButton ;
         CAPTION 'Discard' ;
         ACTION ThisWindow.RELEASE ;
         WIDTH 50 ;
         HEIGHT 30 ;
         FONT 'Arial' ;
         SIZE 8.00

      @ 240, 10 CHECKBOX ChkAddNavigation ;
         CAPTION 'Add database navigation buttons' ;
         WIDTH 200 ;
         HEIGHT 20 ;
         VALUE oStyle:AddMoveButtons() ;
         FONT 'Arial' ;
         SIZE 8.00 ;
         TRANSPARENT

      END WINDOW

      CENTER WINDOW DBFields
      ACTIVATE WINDOW DBFields

      ::FieldsToWindow()

   ENDIF

RETURN NIL


METHOD OpenDBF() CLASS gDBFTool

   LOCAL cFileName
   LOCAL aStruc
   LOCAL bStruc := {}

   cFileName := GetFile( { { "Database files", "*.DBF" } }, "Select Database file", oStyle:ProjectDir(), FALSE, FALSE )

   IF !File( cFileName )
      MsgBox( "No DBF file selected", "Guides" )
      RETURN NIL
   ELSE
      USE ( cFileName ) EXCLUSIVE
      IF NetErr()
         MsgBox( "DBF File is in use!", "Guides" )
         RETURN NIL
      ELSE
         aStruc := dbStruct()
         AEval( aStruc, {| elemento | AAdd( bStruc, { elemento[ 1 ], elemento[ 2 ], Str( elemento[ 3 ] ), Str( elemento[ 4 ] ) } ) } )
         ::Alias := Alias()
         dbCloseArea()
      ENDIF
   ENDIF

RETURN bStruc


METHOD AddField() CLASS gDBFTool

   LOCAL nPos := DBFields.DBGrid.Value
   LOCAL acField := DBFields.DBGrid.Item( nPos )

   DBFields.DestinationGrid.AddItem( acField )
   DBFields.DBGrid.DeleteItem( nPos )

RETURN NIL


METHOD DeleteField() CLASS gDBFTool

   LOCAL nPos := DBFields.DestinationGrid.Value
   LOCAL acField := DBFields.DestinationGrid.Item( nPos )

   DBFields.DBGrid.AddItem( acField )
   DBFields.DestinationGrid.DeleteItem( nPos )

RETURN NIL


METHOD FieldsToWindow() CLASS gDBFTool

   LOCAL nCount
   LOCAL cValue, cType
   LOCAL oLabel, oContentBox, oButton
   LOCAL yPos := 0, xPos := 0
   LOCAL nLength
   LOCAL nDecs
   LOCAL cPattern

   IF oStyle:AddMoveButtons()
      oButton := gButton():AddFromDB( ::oWindow )
      oButton:CAPTION := "<<"
      oButton:Action  := "{ || " + ::ALIAS + "->(dbGoTop()), Refresh_" + ::oWindow:Id + "() }"
      oButton:Row := yPos
      oButton:Col := xPos
      oButton:Id  := "but_GoFirst"
      oButton:Update()
      xPos += oStyle:Width()

      oButton := gButton():AddFromDB( ::oWindow )
      oButton:CAPTION := "<"
      oButton:Action  := "{ || " + ::ALIAS + "->(dbSkip(-1)), Refresh_" + ::oWindow:Id + "() }"
      oButton:Row := yPos
      oButton:Col := xPos
      oButton:Id  := "but_Backwards"
      oButton:Update()
      xPos += oStyle:Width()

      oButton := gButton():AddFromDB( ::oWindow )
      oButton:CAPTION := ">"
      oButton:Action  := "{ || " + ::ALIAS + "->(dbSkip()), iif(" + ::ALIAS + "->(EoF())," + ::ALIAS + "->(dbGoBottom()), ), Refresh_" + ::oWindow:Id + "() }"
      oButton:Row := yPos
      oButton:Col := xPos
      oButton:Id  := "but_Forward"
      oButton:Update()
      xPos += oStyle:Width()

      oButton := gButton():AddFromDB( ::oWindow )
      oButton:CAPTION := ">>"
      oButton:Action  := "{ || " + ::ALIAS + "->(dbGoBottom()), Refresh_" + ::oWindow:Id + "() }"
      oButton:Row := yPos
      oButton:Col := xPos
      oButton:Id  := "but_GoLast"
      oButton:Update()
      xPos += oStyle:Width()

      yPos += oStyle:Height()
   ENDIF

   FOR nCount := 1 TO Len( ::bDBFStruc )
      cValue := ::bDBFStruc[ nCount ][ 1 ]
      cType  := ::bDBFStruc[ nCount ][ 2 ]
      nLength := Val( ::bDBFStruc[ nCount ][ 3 ] )
      nDecs := Val( ::bDBFStruc[ nCount ][ 4 ] )
      oLabel := gLabel():AddFromDB( ::oWindow )
      oLabel:Value := cValue
      oLabel:Row := yPos
      oLabel:Col := 0
      oLabel:Id := "lbl_" + cValue
      oLabel:Update()
      IF cType == "L"
         oContentBox := gCheckBox():AddFromDB( ::oWindow )
         oContentBox:FieldName := iif( Empty( ::Alias ), cValue, ::ALIAS + "->" + cValue )
         oContentBox:CAPTION := cValue
         oContentBox:Row := yPos
         yPos += oStyle:Height()
         oContentBox:Col := oStyle:Width()
         oContentBox:Id := "chk_" + cValue
         oContentBox:Update()
      ELSEIF cType == "M"
         oContentBox := gEditBox():AddFromDB( ::oWindow )
         oContentBox:FieldName := iif( Empty( ::Alias ), cValue, ::ALIAS + "->" + cValue )
         oContentBox:Value := cValue
         oContentBox:Row := yPos
         yPos += oStyle:BigHeight()
         oContentBox:Col := oStyle:Width()
         oContentBox:Id := "edt_" + cValue
         oContentBox:Update()
      ELSEIF cType == "D"
         oContentBox := gDatePicker():AddFromDB( ::oWindow )
         oContentBox:FieldName := iif( Empty( ::Alias ), cValue, ::ALIAS + "->" + cValue )
         oContentBox:Value := "DATE()"
         oContentBox:Row := yPos
         yPos += oStyle:Height()
         oContentBox:Col := oStyle:Width()
         oContentBox:ShowNone := TRUE
         oContentBox:Id := "dat_" + cValue
         oContentBox:Update()
      ELSE
         oContentBox := gTextBox():AddFromDB( ::oWindow )
         oContentBox:Value := cValue
         oContentBox:FieldName := iif( Empty( ::Alias ), cValue, ::ALIAS + "->" + cValue )
         oContentBox:Row := yPos
         yPos += oStyle:Height()
         oContentBox:Col := oStyle:Width()
         IF cType == "N"
            oContentBox:Numeric := TRUE
            IF nDecs > 0
               cPattern := Replicate( "#", nLength - nDecs - 1 ) + "." + Replicate( "#", nDecs )
            ELSE
               cPattern := Replicate( "#", nLength )
            ENDIF
            oContentBox:InputMask := StrTran( cPattern, "#", "9" )
         ENDIF
         oContentBox:Id := "txt_" + cValue
         oContentBox:Update()
      ENDIF
   NEXT

RETURN NIL


METHOD GetFields() CLASS gDBFTool

   LOCAL nFields := DBFields.DestinationGrid.ItemCount
   LOCAL nCount
   LOCAL acField

   FOR nCount := 1 TO nFields
      acField := DBFields.DestinationGrid.Item( nCount )
      AAdd( ::bDBFStruc, acField )
   NEXT

   ::ALIAS := DBFields.AliasTextBox.Value
   DBFields.Release

RETURN NIL


METHOD AddAll() CLASS gDBFTool

   LOCAL nLeftCount := DBFields.DBGrid.ItemCount
   LOCAL acField
   LOCAL nCount

   FOR nCount := 1 TO nLeftCount
      acField := DBFields.DBGrid.Item( 1 )
      DBFields.DestinationGrid.AddItem( acField )
      DBFields.DBGrid.DeleteItem( 1 )
   NEXT

RETURN NIL


METHOD RemoveAll() CLASS gDBFTool

   LOCAL nRightCount := DBFields.DestinationGrid.ItemCount
   LOCAL acField
   LOCAL nCount

   FOR nCount := 1 TO nRightCount
      acField := DBFields.DestinationGrid.Item( 1 )
      DBFields.DBGrid.AddItem( acField )
      DBFields.DestinationGrid.DeleteItem( 1 )
   NEXT

RETURN NIL
