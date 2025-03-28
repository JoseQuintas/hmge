/*-------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This  program is free software; you can redistribute it and/or modify it
   under  the  terms  of the GNU General Public License as published by the
   Free  Software  Foundation; either version 2 of the License, or (at your
   option) any later version.

   This  program  is  distributed  in  the hope that it will be useful, but
   WITHOUT   ANY   WARRANTY;   without   even   the   implied  warranty  of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
   Public License for more details.

   You  should have received a copy of the GNU General Public License along
   with  this  software;  see  the  file COPYING. If not, write to the Free
   Software  Foundation,  Inc.,  59  Temple  Place,  Suite  330, Boston, MA
   02111-1307 USA (or visit the web site http://www.gnu.org/).

   As  a  special exception, you have permission for additional uses of the
   text contained in this release of Harbour Minigui.

   The  exception  is  that,  if  you link the Harbour Minigui library with
   other  files to produce an executable, this does not by itself cause the
   resulting  executable  to  be covered by the GNU General Public License.
   Your  use  of  that  executable  is  in  no way restricted on account of
   linking the Harbour-Minigui library code into it.

   Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2025, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2021 Alexander S.Kresin <alex@kresin.ru>

   Parts of this code  is contributed and used here under permission of his
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
   ----------------------------------------------------------------------*/
#define _WIN32_IE    0x0501
#define _WIN32_WINNT 0x0600

#include <mgdefs.h>

#include "hbapierr.h"
#include "hbapiitm.h"
#include "hbapicdp.h"

#include <commctrl.h>

#ifndef TTS_CLOSE
#define TTS_CLOSE 0x80
#endif
#ifndef TTM_POPUP
#define TTM_POPUP ( WM_USER + 34 )
#endif
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 )
typedef struct _tagEDITBALLOONTIP
{
   DWORD    cbStruct;
   LPCWSTR  pszTitle;
   LPCWSTR  pszText;
   INT      ttiIcon; // From TTI_*
} EDITBALLOONTIP, *PEDITBALLOONTIP;

#define ECM_FIRST                                     0x1500            // Edit control messages
#define EM_SHOWBALLOONTIP                             ( ECM_FIRST + 3 ) // Show a balloon tip associated to the edit control
#define Edit_ShowBalloonTip( hwnd, peditballoontip )  ( BOOL ) SNDMSG( ( hwnd ), EM_SHOWBALLOONTIP, 0, ( LPARAM ) ( peditballoontip ) )
#define EM_HIDEBALLOONTIP                             ( ECM_FIRST + 4 ) // Hide any balloon tip associated with the edit control
#define Edit_HideBalloonTip( hwnd )                   ( BOOL ) SNDMSG( ( hwnd ), EM_HIDEBALLOONTIP, 0, 0 )
#endif
#ifndef __XHARBOUR__
#define HB_cdpGetU16( cdp, fCtrl, ch ) hb_cdpGetU16( cdp, ch )
#else
#define HB_cdpGetU16( cdp, fCtrl, ch ) hb_cdpGetU16( cdp, fCtrl, ch )
#define hb_vmCDP()                     hb_cdppage()
#endif
extern BOOL _isValidCtrlClass( HWND, LPCTSTR );

extern BOOL Array2Point( PHB_ITEM aPoint, POINT *pt );
extern BOOL Array2Rect( PHB_ITEM aPoint, RECT *rect );
extern BOOL Array2ColorRef( PHB_ITEM aCRef, COLORREF *cr );
extern HB_EXPORT PHB_ITEM Rect2Array( RECT *rc );

#ifdef UNICODE
LPWSTR AnsiToWide( LPCSTR );
#endif
HINSTANCE GetInstance( void );

static HB_BOOL g_bIsToolTipActive = TRUE;
static HB_BOOL g_bIsToolTipBalloon = FALSE;

static int g_iToolTipMaxWidth = -1;

HB_FUNC( SETTOOLTIPACTIVATE )
{
   HB_BOOL  g_bOldToolTipActive = g_bIsToolTipActive;

   if( HB_ISLOG( 1 ) )
   {
      g_bIsToolTipActive = hb_parl( 1 );
   }

   hb_retl( g_bOldToolTipActive );
}

HB_FUNC( SETTOOLTIPBALLOON )
{
   HB_BOOL  g_bOldToolTipBalloon = g_bIsToolTipBalloon;

   if( HB_ISLOG( 1 ) )
   {
      g_bIsToolTipBalloon = hb_parl( 1 );
   }

   hb_retl( g_bOldToolTipBalloon );
}

HB_FUNC( SETTOOLTIPMAXWIDTH )
{
   HB_BOOL  g_iOldToolTipMaxWidth = g_iToolTipMaxWidth;

   if( HB_ISNUM( 1 ) )
   {
      g_iToolTipMaxWidth = hb_parni( 1 );
   }

   hb_retni( g_iOldToolTipMaxWidth );
}

/*
   nToolTip := InitToolTip ( nFormHandle, SetToolTipBalloon() )

   for ModalWindow : nToolTip := InitToolTip ( , SetToolTipBalloon() )
 */
HB_FUNC( INITTOOLTIP )
{
   HWND  hwndParent = HB_ISNUM( 1 ) ? hmg_par_raw_HWND( 1 ) : ( HWND ) NULL;

   if( HB_ISNIL( 1 ) ? TRUE : IsWindow( hwndParent ) )                  // hack for ModalWindow
   {
      DWORD                dwStyle = WS_POPUP | TTS_ALWAYSTIP;
      INITCOMMONCONTROLSEX icex = { sizeof( INITCOMMONCONTROLSEX ), ICC_BAR_CLASSES };

      if( hb_pcount() > 1 )
      {
         if( HB_ISLOG( 2 ) && hb_parl( 2 ) )
         {
            dwStyle |= TTS_BALLOON;
         }
      }
      else if( g_bIsToolTipBalloon )
      {
         dwStyle |= TTS_BALLOON;
      }

      InitCommonControlsEx( &icex );

      /* Create a tooltip */
      hmg_ret_raw_HWND
      (
         CreateWindow
            (
               TOOLTIPS_CLASS,
               NULL,
               dwStyle,
               CW_USEDEFAULT,
               CW_USEDEFAULT,
               CW_USEDEFAULT,
               CW_USEDEFAULT,
               hwndParent,
               ( HMENU ) NULL,
               GetInstance(),
               NULL
            )
      );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

HB_FUNC( SETTOOLTIP )
{
   HWND  hwndTool = hmg_par_raw_HWND( 1 );
   HWND  hwndToolTip = hmg_par_raw_HWND( 3 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      if( IsWindow( hwndTool ) )
      {
#ifndef UNICODE
         LPSTR    lpText = ( LPSTR ) hb_parc( 2 );
#else
         LPWSTR   lpText = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
         TOOLINFO ti;

         /* Set up "tool" information */
         memset( &ti, 0, sizeof( ti ) );
         ti.cbSize = sizeof( TOOLINFO );
         ti.uFlags = TTF_SUBCLASS | TTF_IDISHWND;
         ti.hwnd = GetParent( hwndTool );
         ti.uId = ( UINT_PTR ) hwndTool;

         if( SendMessage( hwndToolTip, TTM_GETTOOLINFO, ( WPARAM ) 0, ( LPARAM ) ( LPTOOLINFO ) &ti ) )
         {
            SendMessage( hwndToolTip, TTM_DELTOOL, ( WPARAM ) 0, ( LPARAM ) ( LPTOOLINFO ) &ti );
         }

         if( hb_parclen( 2 ) > 0 )
         {
            ti.lpszText = lpText;
         }

         hmg_ret_L( SendMessage( hwndToolTip, TTM_ADDTOOL, ( WPARAM ) 0, ( LPARAM ) ( LPTOOLINFO ) &ti ) );

         SendMessage( hwndToolTip, TTM_ACTIVATE, ( WPARAM ) ( BOOL ) g_bIsToolTipActive, 0 );
#ifdef UNICODE
         hb_xfree( ( TCHAR * ) lpText );
#endif
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 2, hb_paramError( 1 ), hb_paramError( 2 ) );
   }
}

/*
   ShowBalloonTip ( hWnd, cText [ , cTitle ] [ , nTypeIcon ] )
 */
HB_FUNC( SHOWBALLOONTIP )
{
   WCHAR          Text[512];
   WCHAR          Title[512];
   EDITBALLOONTIP bl;
   const char     *s;
   int            i, k;

   PHB_CODEPAGE   s_cdpHost = hb_vmCDP();

   HWND           hWnd = hmg_par_raw_HWND( 1 );

   if( IsWindow( hWnd ) )
   {
      bl.cbStruct = sizeof( EDITBALLOONTIP );
      bl.pszTitle = NULL;
      bl.pszText = NULL;
      bl.ttiIcon = hb_parnidef( 4, 0 /*TTI_NONE*/ );

      if( HB_ISCHAR( 2 ) )
      {
         ZeroMemory( Text, sizeof( Text ) );
         k = ( int ) hb_parclen( 2 );
         s = ( const char * ) hb_parc( 2 );
         for( i = 0; i < k; i++ )
         {
            Text[i] = HB_cdpGetU16( s_cdpHost, TRUE, s[i] );
         }

         bl.pszText = Text;
      }

      if( HB_ISCHAR( 3 ) )
      {
         ZeroMemory( Title, sizeof( Title ) );
         k = ( int ) hb_parclen( 3 );
         s = ( const char * ) hb_parc( 3 );
         for( i = 0; i < k; i++ )
         {
            Title[i] = HB_cdpGetU16( s_cdpHost, TRUE, s[i] );
         }

         bl.pszTitle = Title;
      }

      Edit_ShowBalloonTip( hWnd, &bl );
   }
}

HB_FUNC( HIDEBALLOONTIP )
{
   HWND  hWnd = hmg_par_raw_HWND( 1 );

   if( IsWindow( hWnd ) )
   {
      Edit_HideBalloonTip( hWnd );
   }
}

/*
   nToolTip := InitToolTipEx ( nFormHandle [, aRect ][, cToolTip ][, cTitle ][, nIcon ][, nStyle ][, nFlags ] )
 */
HB_FUNC( INITTOOLTIPEX )
{
   HWND  hwndParent = hmg_par_raw_HWND( 1 );

   if( IsWindow( hwndParent ) )
   {
      PHB_ITEM             aRect = hb_param( 2, HB_IT_ANY );
      RECT                 rect;
#ifndef UNICODE
      LPSTR                lpszText = ( LPSTR ) NULL;
      LPSTR                lpszTitle = ( LPSTR ) ( HB_ISCHAR( 4 ) ? hb_parc( 4 ) : NULL );
#else
      LPWSTR               lpszText = ( LPWSTR ) NULL;
      LPWSTR               lpszTitle = HB_ISCHAR( 4 ) ? AnsiToWide( ( char * ) hb_parc( 4 ) ) : NULL;
#endif
      int                  nIcon = hb_parnidef( 5, TTI_NONE );
      DWORD                dwStyle = WS_POPUP;
      HWND                 hwndToolTip;
      TOOLINFO             ti;
      UINT                 uFlags = 0;
      INITCOMMONCONTROLSEX icex = { sizeof( INITCOMMONCONTROLSEX ), ICC_BAR_CLASSES };

      if( !Array2Rect( aRect, &rect ) )
      {
         GetClientRect( hwndParent, &rect );
      }

      if( hb_parclen( 3 ) > 0 )
      {
#ifndef UNICODE
         lpszText = ( LPSTR ) hb_parc( 3 );
#else
         lpszText = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif
      }
      else if( HB_ISNUM( 3 ) )
      {
         lpszText = MAKEINTRESOURCE( hb_parni( 3 ) );
      }

      if( HB_ISNUM( 6 ) )
      {
         dwStyle |= hmg_par_DWORD( 6 );
      }

      if( HB_ISNUM( 7 ) )
      {
         uFlags = hmg_par_UINT( 7 );
      }

      InitCommonControlsEx( &icex );

      /* Create a tooltip */
      hwndToolTip = CreateWindowEx
         (
            WS_EX_TOPMOST,
            TOOLTIPS_CLASS,
            NULL,
            dwStyle,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            hwndParent,
            ( HMENU ) NULL,
            GetInstance(),
            NULL
         );

      SetWindowPos( hwndToolTip, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE );

      /* Set up "tool" information. In this case, the "tool" is the entire parent window. */
      memset( &ti, 0, sizeof( ti ) );
      ti.cbSize = sizeof( ti );
      ti.uFlags = uFlags;
      ti.hwnd = hwndParent;
      ti.uId = ( UINT_PTR ) hwndParent;
      ti.rect = rect;
      ti.hinst = GetInstance();
      ti.lpszText = lpszText;

      // Associate the tooltip with the "tool" window.
      SendMessage( hwndToolTip, TTM_ADDTOOL, 0, ( LPARAM ) ( LPTOOLINFO ) &ti );

      if( NULL != lpszTitle )
      {
         SendMessage( hwndToolTip, TTM_SETTITLE, nIcon, ( LPARAM ) lpszTitle );
      }

      if( g_iToolTipMaxWidth != -1 )
      {
         SendMessage( hwndToolTip, TTM_SETMAXTIPWIDTH, 0, ( LPARAM ) g_iToolTipMaxWidth );
      }

      SendMessage( hwndToolTip, TTM_ACTIVATE, ( WPARAM ) ( BOOL ) g_bIsToolTipActive, 0 );

      hmg_ret_raw_HWND( hwndToolTip );

#ifdef UNICODE
      if( lpszText != NULL )
      {
         hb_xfree( ( TCHAR * ) lpszText );
      }

      if( lpszTitle != NULL )
      {
         hb_xfree( ( TCHAR * ) lpszTitle );
      }
#endif
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   ToolTip messages - TTM_messages
 */

/*
   TM_ACTIVATE - activates or deactivates a tooltip control,

   has no effect if g_bIsToolTipActive == FALSE ( after SetToolTipActivate( .F. ) )
 */
HB_FUNC( TTM_ACTIVATE )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      if( g_bIsToolTipActive )
      {
         SendMessage( hwndToolTip, TTM_ACTIVATE, ( WPARAM ) ( BOOL ) hb_parl( 2 ), 0 );
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/* TODO
   TTM_ADDTOOL - registers a tool with a tooltip control

   TTM_ADJUSTRECT -
   calculates   a   tooltip  control's  text  display  rectangle  from  its
   window  rectangle,    or   the   tooltip   window  rectangle  needed  to
   display a specified text display rectangle.

   TTM_DELTOOL - removes a tool from a tooltip control

   TTM_ENUMTOOLS -
   retrieves  the  information  that  a tooltip control maintains about the
   current  tool�that  is,  the  tool  for  which  the tooltip is currently
   displaying text.

   TTM_GETBUBBLESIZE - returns the width and height of a tooltip control

   TTM_GETCURRENTTOOL -
   retrieves the information for the current tool in a tooltip control
 */

/*
   TTM_GETDELAYTIME -
   retrieves  the initial, pop-up, and reshow durations currently set for a
   tooltip control
 */
HB_FUNC( TTM_GETDELAYTIME )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      hb_retni( ( int ) SendMessage( hwndToolTip, TTM_GETDELAYTIME, hb_parnidef( 2, TTDT_AUTOPOP ), 0 ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_GETMARGIN -
   retrieves  the  top,  left,  bottom, and right margins set for a tooltip
   window.  A margin is the distance, in pixels, between the tooltip window
   border and the text contained within the tooltip window
 */
HB_FUNC( TTM_GETMARGIN )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      RECT  rect;

      SendMessage( hwndToolTip, TTM_GETMARGIN, 0, ( LPARAM ) &rect );

      hb_itemReturnRelease( Rect2Array( &rect ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_GETMAXTIPWIDTH - retrieves the maximum width for a tooltip window
 */
HB_FUNC( TTM_GETMAXTIPWIDTH )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      hb_retni( ( int ) SendMessage( hwndToolTip, TTM_GETMAXTIPWIDTH, 0, 0 ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/* TODO
   TTM_GETTEXT -
   retrieves the information a tooltip control maintains about a tool
 */

/*
   TTM_GETTIPBKCOLOR - retrieves the background color in a tooltip window
 */
HB_FUNC( TTM_GETTIPBKCOLOR )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      hmg_ret_COLORREF( SendMessage( hwndToolTip, TTM_GETTIPBKCOLOR, 0, 0 ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_GETTIPTEXTCOLOR  - retrieves the text color in a tooltip window
 */
HB_FUNC( TTM_GETTIPTEXTCOLOR )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      hmg_ret_COLORREF( SendMessage( hwndToolTip, TTM_GETTIPTEXTCOLOR, 0, 0 ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/* TODO
   TTM_GETTITLE -
   retrieve information concerning the title of a tooltip control
 */

/*
   TTM_GETTOOLCOUNT -
   retrieves a count of the tools maintained by a tooltip control
 */
HB_FUNC( TTM_GETTOOLCOUNT )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      hb_retni( ( int ) SendMessage( hwndToolTip, TTM_GETTOOLCOUNT, 0, 0 ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/* TODO
   TTM_GETTOOLINFO -
   retrieves the information that a tooltip control maintains about a tool

   TTM_HITTEST -
   tests  a  point to determine whether it is within the bounding rectangle
   of  the  specified  tool  and, if it is, retrieves information about the
   tool

   TTM_NEWTOOLRECT - sets a new bounding rectangle for a tool
 */

/*
   TTM_POP - removes a displayed tooltip window from view
 */
HB_FUNC( TTM_POP )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      SendMessage( hwndToolTip, TTM_POP, ( WPARAM ) 0, ( LPARAM ) 0 );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_POPUP -
   causes the tooltip to display at the coordinates of the last mouse message
 */
HB_FUNC( TTM_POPUP )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      SendMessage( hwndToolTip, TTM_POPUP, 0, 0 );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/* TODO
   TTM_RELAYEVENT -
   passes a mouse message to a tooltip control for processing
 */

/*
   TTM_SETDELAYTIME
   sets the initial, pop-up, and reshow durations for a tooltip control
 */
HB_FUNC( TTM_SETDELAYTIME )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      int   nMilliSec = hb_parnidef( 3, -1 );

      if( nMilliSec < 0 )
      {
         SendMessage( hwndToolTip, TTM_SETDELAYTIME, hb_parnidef( 2, TTDT_AUTOPOP ), -1 );
      }
      else
      {
         SendMessage( hwndToolTip, TTM_SETDELAYTIME, hb_parnidef( 2, TTDT_AUTOPOP ), ( LPARAM ) ( DWORD ) nMilliSec );
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_SETMARGIN  -
   sets  the  top,  left, bottom, and right margins for a tooltip window. A
   margin is the distance, in pixels, between the tooltip window border and
   the text contained within the tooltip window.
 */
HB_FUNC( TTM_SETMARGIN )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      RECT  rect;

      if( Array2Rect( hb_param( 2, HB_IT_ANY ), &rect ) )
      {
         SendMessage( hwndToolTip, TTM_SETMARGIN, 0, ( LPARAM ) &rect );
      }
      else
      {
         hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 2 ) );
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_SETMAXTIPWIDTH - sets the maximum width for a tooltip window
 */
HB_FUNC( TTM_SETMAXTIPWIDTH )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      hb_retni( ( int ) SendMessage( hwndToolTip, TTM_SETMAXTIPWIDTH, 0, ( LPARAM ) hb_parnidef( 2, g_iToolTipMaxWidth ) ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_SETTIPBKCOLOR - sets the background color in a tooltip window
 */
HB_FUNC( TTM_SETTIPBKCOLOR )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      COLORREF cr = ( COLORREF ) 0;

      if( HB_ISNUM( 2 ) || Array2ColorRef( hb_param( 2, HB_IT_ARRAY ), &cr ) )
      {
         if( HB_ISNUM( 2 ) )
         {
            cr = hmg_par_COLORREF( 2 );
         }

         SendMessage( hwndToolTip, TTM_SETTIPBKCOLOR, ( WPARAM ) cr, 0 );
      }
      else
      {
         hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 2 ) );
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_SETTIPTEXTCOLOR - sets the text color in a tooltip window
 */
HB_FUNC( TTM_SETTIPTEXTCOLOR )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      COLORREF cr = ( COLORREF ) 0;

      if( HB_ISNUM( 2 ) || Array2ColorRef( hb_param( 2, HB_IT_ANY ), &cr ) )
      {
         if( HB_ISNUM( 2 ) )
         {
            cr = hmg_par_COLORREF( 2 );
         }

         SendMessage( hwndToolTip, TTM_SETTIPTEXTCOLOR, ( WPARAM ) cr, 0 );
      }
      else
      {
         hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 2 ) );
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/* TODO
   TTM_SETTITLE - adds a standard icon and title string to a tooltip

   TTM_SETTOOLINFO -
   sets the information that a tooltip control maintains for a tool

   TTM_SETWINDOWTHEME - sets the visual style of a tooltip control
 */

/*
   TTM_TRACKACTIVATE - activates or deactivates a tracking tooltip
 */
HB_FUNC( TTM_TRACKACTIVATE )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );
   HWND  hwndTool = hmg_par_raw_HWND( 2 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) && IsWindow( hwndTool ) )
   {
      TOOLINFO ti;

      memset( &ti, 0, sizeof( ti ) );
      ti.cbSize = sizeof( TOOLINFO );
      ti.hwnd = hwndTool;
      ti.uId = ( UINT_PTR ) hwndTool;

      SendMessage( hwndToolTip, TTM_TRACKACTIVATE, ( WPARAM ) hb_parl( 3 ), ( LPARAM ) ( LPTOOLINFO ) &ti );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 2, hb_paramError( 1 ), hb_paramError( 2 ) );
   }
}

/*
   TTM_TRACKPOSITION - sets the position of a tracking tooltip
 */
HB_FUNC( TTM_TRACKPOSITION )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );
   HWND  hwndTool = hmg_par_raw_HWND( 2 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) && IsWindow( hwndTool ) )
   {
      POINT point;

      if( Array2Point( hb_param( 3, HB_IT_ARRAY ), &point ) )
      {
         ClientToScreen( hwndTool, &point );

         SendMessage( hwndToolTip, TTM_TRACKPOSITION, 0, ( LPARAM ) MAKELONG( point.x, point.y ) );
      }
      else
      {
         hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 3 ) );
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 2, hb_paramError( 1 ), hb_paramError( 2 ) );
   }
}

/*
   TTM_UPDATE - forces the current tooltip to be redrawn
 */
HB_FUNC( TTM_UPDATE )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) )
   {
      SendMessage( hwndToolTip, TTM_UPDATE, 0, 0 );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

/*
   TTM_UPDATETIPTEXT - sets the tooltip text for a tool
 */
HB_FUNC( TTM_UPDATETIPTEXT )  //old HB_FUNC( UPDATETOOLTIPTEXT )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );
   HWND  hwndTool = hmg_par_raw_HWND( 2 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) && IsWindow( hwndTool ) )
   {
      if( hb_parclen( 3 ) > 0 )
      {
#ifndef UNICODE
         LPSTR    lpszText = ( LPSTR ) hb_parc( 3 );
#else
         LPWSTR   lpszText = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif
         TOOLINFO ti;

         memset( &ti, 0, sizeof( ti ) );
         ti.cbSize = sizeof( TOOLINFO );
         ti.hinst = ( HINSTANCE ) 0;
         ti.hwnd = hwndTool;
         ti.uId = ( UINT_PTR ) hwndTool;
         ti.lpszText = lpszText;

         SendMessage( hwndToolTip, TTM_UPDATETIPTEXT, 0, ( LPARAM ) ( LPTOOLINFO ) &ti );
#ifdef UNICODE
         if( lpszText != NULL )
         {
            hb_xfree( ( TCHAR * ) lpszText );
         }
#endif
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 2, hb_paramError( 1 ), hb_paramError( 2 ) );
   }
}

/*
   TTM_WINDOWFROMPOINT -
   allows  a  subclass  procedure  to cause a tooltip to display text for a
   window other than the one beneath the mouse cursor
 */
HB_FUNC( TTM_WINDOWFROMPOINT )
{
   HWND  hwndToolTip = hmg_par_raw_HWND( 1 );
   HWND  hwndTool = hmg_par_raw_HWND( 2 );

   if( _isValidCtrlClass( hwndToolTip, TOOLTIPS_CLASS ) && IsWindow( hwndTool ) )
   {
      POINT point;

      if( Array2Point( hb_param( 3, HB_IT_ARRAY ), &point ) )
      {
         ClientToScreen( hwndTool, &point );

         hmg_ret_raw_HWND( SendMessage( hwndToolTip, TTM_WINDOWFROMPOINT, 0, ( LPARAM ) MAKELONG( point.x, point.y ) ) );
      }
      else
      {
         hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 3 ) );
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 2, hb_paramError( 1 ), hb_paramError( 2 ) );
   }
}
