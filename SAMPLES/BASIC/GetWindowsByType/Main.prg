/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Demo was contributed to HMG forum by Edward 18/Dec/2019
 *
 */

#include <hmg.ch>

PROCEDURE Main()

   LOAD WINDOW Main
   Main.Activate()

RETURN
**************************************************************************
PROCEDURE ChildForm()

   LOCAL ChildForm := HMG_GetUniqueName( "ChildForm_" )
   LOCAL nForm := Val( SubStr( ChildForm, RAt( "_", ChildForm ) + 1 ) )

   LOAD WINDOW Child AS &ChildForm

   SetProperty( ChildForm, "Title", "Child Form #" + hb_ntos( nForm ) )
   SetProperty( ChildForm, "Col", 25 * nForm )
   SetProperty( ChildForm, "Row", 25 * nForm )

   ACTIVATE WINDOW (ChildForm)

RETURN
*************************************************************
PROCEDURE StdForm()

   LOCAL StdForm := HMG_GetUniqueName( "StandardForm_" )
   LOCAL nForm := Val( SubStr( StdForm, RAt( "_", StdForm ) + 1 ) )

   LOAD WINDOW Standard AS &StdForm

   SetProperty ( StdForm, "Title", "Standard Form #" + hb_ntos( nForm ) )
   SetProperty ( StdForm, "Col", ( 25 * nForm ) + 400 )
   SetProperty ( StdForm, "Row", 25 * nForm )

   ACTIVATE WINDOW (StdForm)

RETURN
***********************************************************

FUNCTION GetWindowsByType( cType )

   LOCAL aForms := {} // List of forms { WindowName, WindowType, WindowIsDeleted, WindowIsActive, WindowHandle, WindowParentHandle }

   DEFAULT cType := ''
/*
 empty - all types
 A - main
 S - standard
 C - child
 M - modal
 P - panel
 X - spitchild
*/
   IF Upper( Left( cType, 1 ) ) $ "ASCMPX" .OR. Empty( cType )
      AEval( _HMG_aFormType, {| cWndType, nPos | IF( Empty( cType ) .OR. cWndType == Upper( Left(cType, 1 ) ), ;
         AAdd( aForms, ;
         { _HMG_aFormNames[ nPos ], ;
         _HMG_aFormType[ nPos ], ;
         _HMG_aFormDeleted[ nPos ], ;
         _HMG_aFormActive[ nPos ], ;
         _HMG_aFormHandles[ nPos ], ;
         _HMG_aFormParentHandle[ nPos ] } ), ;
         Nil ) } )
   ELSE
      MsgStop( 'Function GetWindowsByType(): invalid window type "' + cType + '"' )
   ENDIF

RETURN aForms
