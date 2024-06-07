/*
 * HMG Misc demo
*/

#include "hmg.ch"

FUNCTION Main()

   DEFINE WINDOW oWindow1 ;
         ROW 10 ;
         COL 10 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'HMG misc funcs/objects' ;
         WindowType Main ;
         OnInit oWindow1.Center()

      DEFINE MAIN MENU

         DEFINE POPUP 'Misc functions'

            DEFINE POPUP 'Folders'
               MENUITEM 'GetDesktopFolder'      ONCLICK MsgInfo( GetDesktopFolder() )
               MENUITEM 'GetMyDocumentsFolder'  ONCLICK MsgInfo( GetMyDocumentsFolder() )
               MENUITEM 'GetProgramFilesFolder' ONCLICK MsgInfo( GetProgramFilesFolder() )
               MENUITEM 'GetTempFolder'         ONCLICK MsgInfo( GetTempFolder() )
               MENUITEM 'GetWindowsTempFolder'  ONCLICK MsgInfo( GetWindowsTempFolder() )
               MENUITEM 'GetClipboard'          ONCLICK MsgInfo( RetrieveTextFromClipboard() )
               MENUITEM 'SetClipboard'          ONCLICK CopyToClipboard( 'New Clipboard Value' )
               MENUITEM 'Clean Temp Folder'     ONCLICK MsgInfo( DirRemoveAllExceptParent( GetTempFolder() ) )
               IF !( GetTempFolder() == GetWindowsTempFolder() )
                  MENUITEM 'Clean Windows Temp Folder' ONCLICK MsgInfo( DirRemoveAllExceptParent( GetWindowsTempFolder() ) )
               ENDIF
            END POPUP

            DEFINE POPUP 'System.Objects'
               MENUITEM 'System.DesktopFolder'      ONCLICK MsgInfo( System.DesktopFolder )
               MENUITEM 'System.MyDocumentsFolder'  ONCLICK MsgInfo( System.MyDocumentsFolder )
               MENUITEM 'System.ProgramFilesFolder' ONCLICK MsgInfo( System.ProgramFilesFolder )
               MENUITEM 'System.TempFolder'         ONCLICK MsgInfo( System.TempFolder )
               MENUITEM 'System.Clipboard'          ONCLICK MsgInfo( System.Clipboard )
               MENUITEM 'System.Clipboard := "New Value"' ONCLICK System.Clipboard := "New Value"
               MENUITEM 'System.DefaultPrinter'     ONCLICK MsgInfo( System.DefaultPrinter )
            END POPUP

            DEFINE POPUP 'Desktop Size'
               MENUITEM 'Width'         ONCLICK MsgInfo( GetDesktopWidth() )
               MENUITEM 'Client Width'  ONCLICK MsgInfo( System.ClientWidth )
               MENUITEM 'Height'        ONCLICK MsgInfo( GetDesktopHeight() )
               MENUITEM 'Client Height' ONCLICK MsgInfo( System.ClientHeight )
            END POPUP

         END POPUP

      END MENU

   END WINDOW

   ACTIVATE WINDOW oWindow1

RETURN NIL

// -----------------------------------------------------------------------------

#include "directry.ch"
#include "fileio.ch"

FUNCTION DirRemoveAllExceptParent( cDir )

   LOCAL aFile, cPath, cFile, nAttr, lSuccess := .T.

   IF ! Empty( cDir ) .AND. hb_vfDirExists( cDir )
      cPath := hb_DirSepAdd( cDir )
      FOR EACH aFile IN hb_vfDirectory( cPath + hb_osFileMask(), "HSD" )
         IF "D" $ aFile[ F_ATTR ]
            IF !( aFile[ F_NAME ] == "." .OR. aFile[ F_NAME ] == ".." .OR. aFile[ F_NAME ] == "" )
               IF ! hb_DirRemoveAll( cPath + aFile[ F_NAME ] )
                  lSuccess := .F.
               ENDIF
            ENDIF
         ELSE
            cFile := cPath + aFile[ F_NAME ]
            IF "R" $ aFile[ F_ATTR ] .AND. hb_vfAttrGet( cFile, @nAttr )
               hb_vfAttrSet( cFile, hb_bitAnd( nAttr, hb_bitNot( HB_FA_READONLY ) ) )
            ENDIF
            IF ! hb_vfErase( cFile ) == 0
               lSuccess := .F.
            ENDIF
         ENDIF
      NEXT
      RETURN lSuccess
   ENDIF

RETURN lSuccess
