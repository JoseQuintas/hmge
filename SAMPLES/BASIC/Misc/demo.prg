/*
 * HMG Misc demo
*/

#include "hmg.ch"


FUNCTION Main

   DEFINE WINDOW oWindow1;
      Row    10;
      Col    10;
      Width  400;
      Height 400;
      Title  'HMG misc funcs/objects';
      WindowType MAIN;
      OnInit oWindow1.Center()

      DEFINE MAIN MENU OF oWindow1

        DEFINE POPUP 'Misc functions'

           DEFINE POPUP 'Folders'
              MenuItem 'GetDesktopFolder'      OnClick MsgInfo( GetDesktopFolder() )
              MenuItem 'GetMyDocumentsFolder'  OnClick MsgInfo( GetMyDocumentsFolder() )
              MenuItem 'GetProgramFilesFolder' OnClick MsgInfo( GetProgramFilesFolder() )
              MenuItem 'GetTempFolder'         OnClick MsgInfo( GetTempFolder() )
              MenuItem 'GetClipboard'          OnClick MsgInfo( RetrieveTextFromClipboard() )
              MenuItem 'SetClipboard'          onClick CopyToClipboard( 'New Clipboard Value' )
           END POPUP

           DEFINE POPUP 'System.Objects'
              MenuItem 'System.DesktopFolder'            OnClick MsgInfo( System.DesktopFolder )
              MenuItem 'System.MyDocumentsFolder'        OnClick MsgInfo( System.MyDocumentsFolder )
              MenuItem 'System.ProgramFilesFolder'       OnClick MsgInfo( System.ProgramFilesFolder )
              MenuItem 'System.TempFolder'               OnClick MsgInfo( System.TempFolder )
              MenuItem 'System.Clipboard'                OnClick MsgInfo( System.Clipboard )
              MenuItem 'System.Clipboard := "New Value"' OnClick System.Clipboard := "New Value"
              MenuItem 'System.DefaultPrinter'           OnClick MsgInfo( System.DefaultPrinter )
           END POPUP

           DEFINE POPUP 'Desktop Size'
              MenuItem 'Width'         OnClick MsgInfo( GetDesktopWidth() )
              MenuItem 'Client Width'  OnClick MsgInfo( System.ClientWidth )
              MenuItem 'Height'        OnClick MsgInfo( GetDesktopHeight() )
              MenuItem 'Client Height' OnClick MsgInfo( System.ClientHeight )
           END POPUP

        END POPUP

      END MENU

   END WINDOW

   ACTIVATE WINDOW oWindow1

RETURN NIL
