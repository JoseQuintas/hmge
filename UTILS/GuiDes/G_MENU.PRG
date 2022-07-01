/*
 * GuiDes source code:
 *
 * Copyright 2002 Carlos Andr‚s <carlos.andres@navegalia.com>
 * www - http://www.geocities.com/harbour_links/guides
 *
 * GuiDes is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * GuiDes is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 */

#include "GUIDES.CH"
#include "minigui.ch"
#include "hbclass.ch"

DECLARE WINDOW MenuEditor

CREATE CLASS gMenu

   DATA TYPE                  INIT G_MAINMENU
   DATA Elements              INIT {}
   DATA ExitStatus            INIT G_EXIT_SAVE

   METHOD New( nMenuType )    CONSTRUCTOR
   METHOD Definition()
   METHOD Edit()
   METHOD AddItem( lTopLevel )
   METHOD RemoveItem()
   METHOD AddTopLevelItem()   INLINE ::AddItem( TRUE )
   METHOD AddElementItem()    INLINE ::AddItem( FALSE )
   METHOD SetTree
   METHOD EXIT
   METHOD RELEASE
   METHOD ClearText()
   METHOD GetItemValues
   METHOD ApplyCurrentValues
   METHOD CODE
/*
   METHOD MoveUp()
   METHOD MoveDown()
*/

END CLASS


METHOD New( nMenuType ) CLASS gMenu

   IF nMenuType == NIL
      nMenuType := G_MAINMENU
   ENDIF

   ::TYPE := nMenuType

RETURN Self



METHOD Edit() CLASS gMenu

   LOCAL cType := ""

   IF ::TYPE == G_MAINMENU
      cType := "MAINMENU"

   ELSEIF ::TYPE == G_CONTEXTMENU
      cType := "CONTEXTMENU"

   ELSEIF ::TYPE == G_TREE
      cType := "TREE"

   ELSEIF ::TYPE == G_STATUSBAR
      cType := "STATUSBAR"

   ENDIF

   ::Definition()

   MenuEditor.Title := MenuEditor.Title + ": " + cType

   IF ::TYPE == G_MAINMENU
      MenuEditor.NameTextBox.Enabled   :=  TRUE
      MenuEditor.AddItemButton.Visible :=  TRUE
      MenuEditor.cFirst.Value   := "Menu Item Caption"
      MenuEditor.cSecond.Value  := "Menu Item Action"
      MenuEditor.cThird.Value   := "Menu Item Name"
   ELSEIF ::TYPE == G_CONTEXTMENU
      MenuEditor.AddItemButton.Visible :=  FALSE
      MenuEditor.cFirst.Value   := "Menu Item Caption"
      MenuEditor.cSecond.Value  := "Menu Item Action"
      MenuEditor.cThird.Value   := "Menu Item Name (ID)"
   ELSEIF ::TYPE == G_NOTIFYMENU
      MenuEditor.AddItemButton.Visible :=  FALSE
      MenuEditor.cFirst.Value   := "Menu Item Caption"
      MenuEditor.cSecond.Value  := "Menu Item Action"
      MenuEditor.cThird.Value   := "Menu Item Name (ID)"
   ELSEIF ::TYPE == G_TREE
      MenuEditor.NameTextBox.Enabled   :=  TRUE
      MenuEditor.AddItemButton.Visible :=  TRUE
      MenuEditor.cFirst.Value   := "Node/Item Caption"
      MenuEditor.cSecond.Value  := "Images"
      MenuEditor.cThird.Value   := "Node/Item ID (number)"
   ENDIF

   MenuEditor.Center
   MenuEditor.Activate

RETURN Self


METHOD AddItem( lTopLevel ) CLASS gMenu

   LOCAL cElement := MenuEditor.ElemTextBox.Value
   LOCAL cAction  := MenuEditor.ActionTextBox.Value
   LOCAL cName    := MenuEditor.NameTextBox.Value
   LOCAL nPos := 0
   LOCAL nLevel := 0
   LOCAL lProceed := TRUE
   LOCAL aNewElems := {}
   LOCAL lFoundParent := FALSE
   LOCAL nCount

   IF !lTopLevel
      nPos  := MenuEditor.ElemsTree.Value
      nLevel   := ::Elements[ nPos ][ 1 ] + 1
   ENDIF

   IF !lTopLevel .AND. ( MenuEditor.ElemsTree.ItemCount == 0  )
      MsgBox( "First elements must be top level!", "GuiDes" )
      lProceed := FALSE
   ENDIF

   IF AllTrim( cElement ) == ""
      MsgBox( "Item Caption cannot be empty!", "GuiDes" )
      lProceed := FALSE
   ENDIF

   IF lProceed

      MenuEditor.ElemsTree.AddItem( cElement, nPos )

      IF lTopLevel
         AAdd( ::Elements, { nLevel, cElement, cAction, cName }  )
      ELSE
         FOR nCount := 1 TO Len( ::Elements )
            IF lFoundParent .AND. ::Elements[ nCount ][ 1 ] == ( nLevel - 1 )
               AAdd( aNewElems, { nLevel, cElement, cAction, cName }  )
               lFoundParent := FALSE
            ENDIF

            AAdd( aNewElems, AClone( ::Elements[ nCount ] ) )

            IF ( nCount == nPos )
               lFoundParent := TRUE
            ENDIF
         NEXT

         IF lFoundParent
            AAdd( aNewElems, { nLevel, cElement, cAction, cName }  )
         ENDIF

         ::Elements := aNewElems
      ENDIF

      MenuEditor.ElemsTree.Value := nPos + 1
      ::ClearText()
      MenuEditor.ElemTextBox.SetFocus()
   ENDIF

RETURN Self


METHOD RemoveItem() CLASS gMenu

   LOCAL nElement
   LOCAL nLevel
   LOCAL nCount
   LOCAL aContent
   LOCAL nTotal := MenuEditor.ElemsTree.ItemCount
   LOCAL aNewElems := {}
   LOCAL lCopy := TRUE

   IF ( nTotal > 0 )
      nElement := MenuEditor.ElemsTree.Value
      nLevel   := ::Elements[ nElement ][ 1 ]

      MenuEditor.ElemsTree.DeleteItem( nElement )

      FOR nCount := 1 TO Len( ::Elements )

         aContent := ::Elements[ nCount ]

         IF ( nCount == nElement )
            lCopy := FALSE
         ELSE
            IF !lCopy .AND. aContent[ 1 ] <= nLevel
               lCopy := TRUE
            ENDIF
         ENDIF

         IF lCopy
            AAdd( aNewElems, AClone( aContent ) )
         ENDIF
      NEXT

      ::Elements := aNewElems

      IF !nElement == 1
         MenuEditor.ElemsTree.Value :=  nElement - 1
      ELSEIF ( nTotal > 1 )
         MenuEditor.ElemsTree.Value :=  1
      ENDIF
   ELSE
      PlayHand()
   ENDIF

RETURN Self


METHOD GetItemValues() CLASS gMenu

   LOCAL nElement := MenuEditor.ElemsTree.Value
   LOCAL aAux

   IF nElement > 0
      aAux := ::Elements[ nElement ]

      IF !Empty( aAux )
         MenuEditor.ElemTextBox.Value     := aAux[ 2 ]
         MenuEditor.ActionTextBox.Value   := aAux[ 3 ]
         MenuEditor.NameTextBox.Value     := aAux[ 4 ]
      ENDIF
   ELSE
      PlayHand()
   ENDIF

RETURN Self


METHOD SetTree CLASS gMenu

   LOCAL aIndexes := {}
   LOCAL nCount
   LOCAL nLevel
   LOCAL nPos

   FOR nCount := 1 TO Len( ::Elements )

      nLevel := ::Elements[ nCount ][ 1 ]
      IF Len( aIndexes ) < ( nLevel + 1 )
         AAdd( aIndexes, nCount )
      ELSE
         aIndexes[ nLevel + 1 ] := nCount
      ENDIF

      nPos := iif( nLevel == 0, 0, aIndexes[ nLevel ] )

      MenuEditor.ElemsTree.AddItem( ::Elements[ nCount, 2 ], nPos )
   NEXT

RETURN Self


METHOD Exit( nExitStyle ) CLASS gMenu

   ::ExitStatus := nExitStyle
   MenuEditor.Release

RETURN Self


METHOD Release() CLASS gMenu

RETURN Self



METHOD Definition() CLASS gMenu

   DEFINE WINDOW  MenuEditor ;
      AT 0, 0 ;
      WIDTH 457 ;
      HEIGHT 402 ;
      TITLE 'Menu Editor' ;
      ICON 'AGUIDES' ;
      MODAL ;
      ON INIT ::SetTree() ;
      ON RELEASE ::Release()

   DEFINE TREE ElemsTree ;
      AT 10, 10 ;
      WIDTH 350 ;
      HEIGHT 200 ;
      FONT 'ARIAL' ;
      SIZE 8 ;
      ON DBLCLICK ::GetItemValues()

   END TREE

   @ 270, 130 BUTTON AddItemButton ;
      CAPTION 'Add SubItem' ;
      ACTION ::AddElementItem() ;
      WIDTH 110 ;
      HEIGHT 30 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 270, 250 BUTTON RemoveButton ;
      CAPTION 'Remove' ;
      ACTION ::RemoveItem() ;
      WIDTH 50 ;
      HEIGHT 30 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 270, 10 BUTTON AddTopItemButton ;
      CAPTION 'Add Top Level Item' ;
      ACTION ::AddTopLevelItem() ;
      WIDTH 110 ;
      HEIGHT 30 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 240, 10 TEXTBOX ElemTextBox ;
      HEIGHT 20 ;
      WIDTH 110 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 240, 150 TEXTBOX ActionTextBox ;
      HEIGHT 20 ;
      WIDTH 130 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 240, 300 TEXTBOX NameTextBox ;
      HEIGHT 20 ;
      WIDTH 130 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 220, 10 LABEL cFirst ;
      VALUE 'MenuItem Caption:' ;
      WIDTH 110 ;
      HEIGHT 20 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 220, 150 LABEL cSecond ;
      VALUE 'Associated Action:' ;
      WIDTH 110 ;
      HEIGHT 20 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 220, 300 LABEL cThird ;
      VALUE 'MenuItem Name:' ;
      WIDTH 110 ;
      HEIGHT 20 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 270, 310 BUTTON EditButton ;
      CAPTION 'Apply To Current Item' ;
      ACTION ::ApplyCurrentValues() ;
      WIDTH 110 ;
      HEIGHT 30 ;
      FONT 'ARIAL' ;
      SIZE 8
/*
        @ 10,390 BUTTON UpButton ;
            PICTURE 'UP' ;
            ACTION ::MoveUp() ;
            WIDTH 50 ;
            HEIGHT 30

        @ 50,390 BUTTON DownButton ;
            PICTURE 'DOWN' ;
            ACTION ::MoveDown() ;
            WIDTH 50 ;
            HEIGHT 30
*/
   @ 310, 10 BUTTON SaveExit ;
      CAPTION 'Save and Exit' ;
      ACTION ::Exit( 0 ) ;
      WIDTH 110 ;
      HEIGHT 30 ;
      FONT 'ARIAL' ;
      SIZE 8

   @ 310, 130 BUTTON removeExit ;
      CAPTION 'Exit and Remove' ;
      ACTION ::Exit( 2 ) ;
      WIDTH 110 ;
      HEIGHT 30 ;
      FONT 'ARIAL' ;
      SIZE 8 ;

   END WINDOW

RETURN NIL


METHOD ClearText() CLASS gMenu
   MenuEditor .ElemTextBox.Value    := ""
   MenuEditor .ActionTextBox.Value  := ""
   MenuEditor .NameTextBox.Value    := ""

RETURN NIL


METHOD ApplyCurrentValues CLASS gMenu

   LOCAL cElement := MenuEditor.ElemTextBox.Value
   LOCAL cAction  := MenuEditor.ActionTextBox.Value
   LOCAL cName    := MenuEditor.NameTextBox.Value
   LOCAL nPos  := MenuEditor.ElemsTree.Value
   LOCAL nLevel
   LOCAL lProceed := TRUE

   IF ( nPos == 0 )
      lProceed := FALSE
   ENDIF

   IF ( AllTrim( cElement ) == "" )
      MsgBox( "Element Name cannot be empty", "GuiDes" )
      lProceed := FALSE
   ENDIF

   IF lProceed
      nLevel := ::Elements[ nPos ][ 1 ]

      ::Elements[ nPos ] := { nLevel, cElement, cAction, cName }

      MenuEditor .ElemsTree. Item( nPos ) := cElement
      ::ClearText()
   ENDIF

RETURN NIL


METHOD Code( oCode ) CLASS gMenu

// LOCAL cName
   LOCAL nCount, lCount
   LOCAL nLevel
   LOCAL Nextlevel
   LOCAL cFirstLine    := ""
   LOCAL Node_word     := ""
   LOCAL End_Node_word := ""
   LOCAL Element_word  := ""
   LOCAL Action_word   := "ACTION"
   LOCAL ID_word       := "NAME"

   IF ::TYPE == G_MAINMENU
      cFirstLine    := "DEFINE MAIN MENU"
      Node_word     := "POPUP"
      End_Node_word := "END POPUP"
      Element_word  := "ITEM"
      Action_word   := "ACTION"
      ID_word       := "NAME"

   ELSEIF ::TYPE == G_CONTEXTMENU
      cFirstLine    := "DEFINE CONTEXT MENU"
      Node_word     := "MENUITEM"
      End_Node_word := ""
      Element_word  := "MENUITEM"
      Action_word   := "ACTION"
      ID_word       := "NAME"

// ELSEIF ::Type == G_TREE
// cName := "TREE"

   ELSEIF ::TYPE == G_NOTIFYMENU
      cFirstLine    := "DEFINE NOTIFY MENU"
      Node_word     := "MENUITEM"
      End_Node_word := ""
      Element_word  := "MENUITEM"
      Action_word   := "ACTION"
      ID_word       := "NAME"

   ENDIF

   oCode:MoreTab()
   oCode:AddLine( cFirstLine, TRUE )
   oCode:MoreTab()

   FOR nCount := 1 TO Len( ::Elements )
      NextLevel := iif( nCount == Len( ::Elements ), 0, ::Elements[ nCount + 1 ][ 1 ] )
      nLevel := ::Elements[ nCount ][ 1 ]

      IF NextLevel > nLevel
         oCode:AddQuoted( Node_word, ::Elements[ nCount ][ 2 ], TRUE )
         oCode:AddNotEmpty( Action_word, ::Elements[ nCount ][ 3 ] )
         oCode:AddNotEmpty( Id_word, ::Elements[ nCount ][ 4 ] )
         oCode:MoreTab()
      ELSE
         oCode:AddQuoted( Element_word, ::Elements[ nCount ][ 2 ], TRUE )
         oCode:AddNotEmpty( Action_word, ::Elements[ nCount ][ 3 ] )
         oCode:AddNotEmpty( Id_word, ::Elements[ nCount ][ 4 ] )

         FOR lCount := 1 TO ( nLevel - NextLevel )
            oCode:LessTab()
            oCode:AddLine( End_node_word, TRUE  )
         NEXT

      ENDIF
   NEXT

   oCode:LessTab()
   oCode:AddLine( "END MENU", TRUE )
   oCode:LessTab()

RETURN NIL

/*
METHOD MoveUp() CLASS gMenu
 LOCAL nPos  := MenuEditor.ElemsTree.Value
 LOCAL aPrevious := {}
 LOCAL aCurrent := {}

 IF nPos == 1
  PlayHand()
 ELSE
  aPrevious := ::Elements[ nPos-1 ]
  aCurrent  := ::Elements[ nPos ]

  IF aPrevious[ 1 ] == aCurrent[ 1 ]
   FOR nCount := nPos TO LEN( ::Elements )
    IF ::Elements[ nCount ][ 1 ] > ::Elements[ nCount-1 ][ 1 ]
     ::JustSwap( nCount-1 )
    ELSE
     EXIT
    ENDIF
   NEXT
  ELSE

 ENDIF

RETURN NIL

METHOD MoveDown() CLASS gMenu
RETURN NIL

METHOD JustSwap() CLASS gMenu
RETURN NIL


METHOD Redraw CLASS gMenu
 LOCAL nCount, mCount
 LOCAL nLevel := 0
 LOCAL nCurrentElemLevel := 0

 MenuEditor.ElemsTree.DeleteAllItems

 FOR nCount := 1 TO LEN( ::Elements )
  nLevel := nCurrentElemLevel
  nCurrentElemLevel := :Elements[ nCount ]

  IF

  MenuEditor.ElemsTree.AddItem(

  nCurrentElemLevel := :Elements

*/
