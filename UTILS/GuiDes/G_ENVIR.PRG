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

DECLARE WINDOW Main
DECLARE WINDOW OIWin
DECLARE WINDOW PropInspector
DECLARE WINDOW WinSelec

CREATE CLASS gEnvir

   DATA WinNum          INIT 0
   DATA NewWinRow       INIT G_WIN_TOP_ROW
   DATA NewWinCol       INIT G_WIN_TOP_COL
   DATA Windows         INIT {}
   DATA INDEX
   DATA CurDir          INIT CurDir()

   METHOD NEW           INLINE Self
   METHOD AddWindow
   METHOD KillWindow
   METHOD AddControl
   METHOD Act_Window()
   METHOD ActControl()   INLINE iif( Empty( ::Act_Window() ), NIL,  ::Act_Window():ActControl() )
   METHOD AnyWindow()
   METHOD AnyControl()

   METHOD SaveWindow()   INLINE IF( ::AnyWindow(), ::Act_Window():Save( FALSE ), NIL )
   METHOD NewWindowName()
   METHOD NewWindowPos()
   METHOD DoToAllWindows( cProcedure )
   METHOD MinimizeWindows()  INLINE ::DoToAllWindows( "Minimize" )
   METHOD RestoreWindows()  INLINE ::DoToAllWindows( "Restore" )
   METHOD CloseAllWindows()  INLINE ::DoToAllWindows( "Release" )
   METHOD DuplicateControl()
   METHOD WindowIndex( cWindow )
   METHOD ChangeToControl( nSelected )
   METHOD ChangeIndex( newIndex )
   METHOD ChangeToWindow( xRefere )

ENDCLASS


METHOD AddWindow( oWindow ) CLASS gEnvir

   AAdd( ::Windows, oWindow )
   ::INDEX := Len( ::Windows )

RETURN NIL


METHOD KillWindow() CLASS gEnvir

   LOCAL newIndex

   IF !Empty( ::Act_Window() )
      ADel( ::Windows, ::INDEX )
      ASize( ::Windows, Len( ::Windows ) - 1 )
      IF ::INDEX == WinSelec.WSGrid.Value
         WinSelec.WSGrid.DeleteItem( ::INDEX )
      ENDIF
   ENDIF

   newIndex := iif(  Len( ::Windows ) > 0, 1, 0 )
   ::ChangeIndex( newIndex )

RETURN NIL


METHOD AddControl( cType ) CLASS gEnvir

   IF ::AnyWindow()
      ::Act_Window():AddControl( cType )
   ENDIF

RETURN NIL


METHOD AnyWindow() CLASS gEnvir

   IF ( ::Act_Window() == NIL ) .OR. !( IsWindowDefined( &( ::Act_Window():Name ) ) )
      MsgBox( "No window has been defined!", "GuiDes" )
      RETURN FALSE
   ENDIF

RETURN TRUE


METHOD AnyControl() CLASS gEnvir

   IF !( ::AnyWindow() )
      RETURN FALSE
   ELSEIF ( ::ActControl() == NIL  )
      MsgBox( "No control has been defined!", "GuiDes" )
      RETURN FALSE
   ENDIF

RETURN TRUE


METHOD NewWindowName() CLASS gEnvir

   ::WinNum++

RETURN ( "Win_" + AllTrim( Str( ::WinNum ) ) )


METHOD NewWindowPos() CLASS gEnvir
   ::NewWinRow += G_NEWWIN_ROW_OFFSET
   ::NewWinCol += G_NEWWIN_COL_OFFSET

   IF ( ::NewWinRow > ( Main.Height - G_NEWWIN_ROW_OFFSET ) ) ;
         .OR. ( ::NewWinCol > ( Main.Width - G_NEWWIN_COL_OFFSET ) )
      ::NewWinRow := G_WIN_TOP_ROW + G_NEWWIN_ROW_OFFSET
      ::NewWinCol := G_WIN_TOP_COL + G_NEWWIN_COL_OFFSET
   ENDIF

RETURN { ::NewWinRow, ::NewWinCol }


METHOD DoToAllWindows( cProcedure ) CLASS gEnvir

   LOCAL nCount
   LOCAL nTotal := Len( ::Windows )

   FOR nCount :=  nTotal TO 1 STEP -1
      DoMethod ( ::Windows[ nCount ]:Name, cProcedure )
   NEXT

RETURN NIL


METHOD DuplicateControl() CLASS gEnvir

   LOCAL oControl

   IF ::AnyControl()
      oControl :=  __objClone( ::ActControl() )

      oControl:Name := ::Act_Window():AddControl( oControl )
      oControl:Id      := oControl:Name
      oControl:Row     := 0
      oControl:Col     := 0
      oControl:Define()
      oControl:AddToTree()
   ENDIF

RETURN NIL


METHOD WindowIndex( cWindow )  CLASS gEnvir
RETURN( AScan( ::Windows, {| x | x:Name == cWindow } ) )


METHOD Act_Window() CLASS gEnvir
RETURN iif( Empty( ::Windows ), NIL, ::Windows[ ::Index ] )


METHOD ChangeIndex( newIndex )

   ::INDEX := newIndex

   IF !( newIndex == 0 )
      ::Act_Window():BecomeActiveWindow()
   ELSE
      oProps:Subst( NIL )
      OIWin .OIGrid. DeleteAllItems
   ENDIF

RETURN NIL


METHOD ChangeToWindow( xRefere )

   LOCAL nIndex := IIF ( ValType( xRefere ) == "N", xRefere, ::WindowIndex( xRefere ) )

   IF  !( nIndex == ::INDEX )
      ::ChangeIndex( nIndex )
   ELSE
      ::Act_Window:BecomeActiveWindow()
   ENDIF

RETURN NIL


METHOD ChangeToControl( nSelected ) CLASS gEnvir

   IF nSelected <> 0
      IF oEnvir:Act_Window() != NIL
         oEnvir:Act_Window():ChangeToControl( nSelected )
      ENDIF
   ELSE
      oProps:Subst( NIL )
   ENDIF

RETURN NIL
