/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This program is free software; you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2023, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2021 Alexander S.Kresin <alex@kresin.ru>

   Parts of this code is contributed and used here under permission of his author:
       Copyright 2005 (C) Jacek Kubica <kubica@wssk.wroc.pl>
   ---------------------------------------------------------------------------*/
#include <mgdefs.h>

#include <shellapi.h>
#include <commctrl.h>
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 )

// Button Class Name
#define WC_BUTTON                      "Button"
#define BUTTON_IMAGELIST_ALIGN_CENTER  4
#endif
#include <math.h>

#include "hbapiitm.h"
#include "hbvm.h"

#ifndef BCM_FIRST
#define BCM_FIRST          0x1600
#define BCM_SETIMAGELIST   ( BCM_FIRST + 0x0002 )
#endif
static HBRUSH     CreateGradientBrush( HDC hDC, INT nWidth, INT nHeight, COLORREF Color1, COLORREF Color2 );

HBITMAP           HMG_LoadPicture
                  (
                     const char  *FileName,
                     int         New_Width,
                     int         New_Height,
                     HWND        hWnd,
                     int         ScaleStretch,
                     int         Transparent,
                     long        BackgroundColor,
                     int         AdjustImage,
                     HB_BOOL     bAlphaFormat,
                     int         iAlpfaConstant
                  );

HIMAGELIST        HMG_SetButtonImageList( HWND hButton, const char *FileName, int Transparent, UINT uAlign );
BOOL              bmp_SaveFile( HBITMAP hBitmap, TCHAR *FileName );

LRESULT CALLBACK  OwnButtonProc( HWND hbutton, UINT msg, WPARAM wParam, LPARAM lParam );

#ifdef UNICODE
LPWSTR            AnsiToWide( LPCSTR );
#endif
HINSTANCE         GetInstance( void );
HINSTANCE         GetResources( void );

// Minigui Resources control system
void              RegisterResource( HANDLE hResource, LPCSTR szType );

#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 ) || ( defined( __MINGW32__ ) && defined( __MINGW32_VERSION ) )
typedef struct
{
   HIMAGELIST  himl;
   RECT        margin;
   UINT        uAlign;
} BUTTON_IMAGELIST, *PBUTTON_IMAGELIST;
#endif
HB_FUNC( INITBUTTON )
{
#ifndef UNICODE
   LPCSTR   lpWindowName = hb_parc( 2 );
#else
   LPCWSTR  lpWindowName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   DWORD    Style = BS_NOTIFY | WS_CHILD | ( hb_parl( 14 ) ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON );

   if( hb_parl( 10 ) )
   {
      Style |= BS_FLAT;
   }

   if( !hb_parl( 11 ) )
   {
      Style |= WS_TABSTOP;
   }

   if( !hb_parl( 12 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( hb_parl( 13 ) )
   {
      Style |= BS_MULTILINE;
   }

   hmg_ret_raw_HWND
   (
      CreateWindowEx
         (
            0,
            WC_BUTTON,
            lpWindowName,
            Style,
            hb_parni( 4 ),
            hb_parni( 5 ),
            hb_parni( 6 ),
            hb_parni( 7 ),
            hmg_par_raw_HWND( 1 ),
            hmg_par_raw_HMENU( 3 ),
            GetInstance(),
            NULL
         )
   );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpWindowName );
#endif
}

HB_FUNC( INITIMAGEBUTTON )
{
   HWND        hbutton;
   HWND        himage;
   HICON       hIcon;

#ifndef UNICODE
   LPCSTR      lpWindowName = hb_parc( 2 );
   LPCSTR      lpIconName = hb_parc( 14 );
#else
   LPWSTR      lpWindowName = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPWSTR      lpIconName = AnsiToWide( ( char * ) hb_parc( 14 ) );
#endif
   HIMAGELIST  himl;

   HWND        hwnd = hmg_par_raw_HWND( 1 );
   DWORD       Style = BS_NOTIFY | WS_CHILD | ( hb_parl( 13 ) ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON ) | ( ( hb_parc( 14 ) == NULL ) ? BS_BITMAP : BS_ICON );

   if( hb_parl( 9 ) )
   {
      Style |= BS_FLAT;
   }

   if( !hb_parl( 11 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( !hb_parl( 12 ) )
   {
      Style |= WS_TABSTOP;
   }

   hbutton = CreateWindowEx
      (
         0,
         WC_BUTTON,
         lpWindowName,
         Style,
         hb_parni( 4 ),
         hb_parni( 5 ),
         hb_parni( 6 ),
         hb_parni( 7 ),
         hwnd,
         hmg_par_raw_HMENU( 3 ),
         GetInstance(),
         NULL
      );

#ifdef UNICODE
   hb_xfree( lpWindowName );
#endif
   if( HB_ISNIL( 14 ) )
   {
      if( !hb_parl( 17 ) )
      {
         himage = ( HWND ) HMG_LoadPicture( hb_parc( 8 ), -1, -1, hwnd, 0, hb_parl( 10 ) ? 0 : 1, -1, 0, HB_FALSE, 255 );

         SendMessage( hbutton, BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

         hb_reta( 2 );
         hmg_storvnl_HANDLE( hbutton, -1, 1 );
         hmg_storvnl_HANDLE( himage, -1, 2 );
      }
      else
      {
         himl = HMG_SetButtonImageList( hbutton, hb_parc( 8 ), hb_parl( 10 ) ? 0 : 1, BUTTON_IMAGELIST_ALIGN_CENTER );

         hb_reta( 2 );
         hmg_storvnl_HANDLE( hbutton, -1, 1 );
         hmg_storvnl_HANDLE( himl, -1, 2 );
      }
   }
   else
   {
      if( !hb_parl( 15 ) )
      {
         hIcon = ( HICON ) LoadImage( GetResources(), lpIconName, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR );

         if( hIcon == NULL )
         {
            hIcon = ( HICON ) LoadImage( 0, lpIconName, IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );
         }
      }
      else
      {
         hIcon = ( HICON ) ExtractIcon( GetInstance(), lpIconName, hb_parni( 16 ) );

         if( hIcon == NULL )
         {
            hIcon = ( HICON ) ExtractIcon( GetInstance(), TEXT( "user.exe" ), 0 );
         }
      }

#ifdef UNICODE
      hb_xfree( lpIconName );
#endif
      if( hb_parl( 17 ) )
      {
         BITMAP            bm;
         ICONINFO          sIconInfo;
         BUTTON_IMAGELIST  bi;

         if( GetIconInfo( hIcon, &sIconInfo ) )
         {
            GetObject( sIconInfo.hbmColor, sizeof( BITMAP ), ( LPVOID ) & bm );

            if( sIconInfo.hbmMask )
            {
               DeleteObject( sIconInfo.hbmMask );
            }

            if( sIconInfo.hbmColor )
            {
               DeleteObject( sIconInfo.hbmColor );
            }

            himl = ImageList_Create( bm.bmWidth, bm.bmHeight, ILC_COLOR32 | ILC_MASK, 1, 0 );

            ImageList_AddIcon( himl, hIcon );

            DestroyIcon( hIcon );

            bi.himl = himl;
            bi.margin.left = 10;
            bi.margin.top = 10;
            bi.margin.bottom = 10;
            bi.margin.right = 10;
            bi.uAlign = BUTTON_IMAGELIST_ALIGN_CENTER;

            SendMessage( ( HWND ) hbutton, BCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) & bi );

            hb_reta( 2 );
            hmg_storvnl_HANDLE( hbutton, -1, 1 );
            hmg_storvnl_HANDLE( himl, -1, 2 );
         }
      }
      else
      {
         SendMessage( hbutton, BM_SETIMAGE, ( WPARAM ) IMAGE_ICON, ( LPARAM ) hIcon );

         hb_reta( 2 );
         hmg_storvnl_HANDLE( hbutton, -1, 1 );
         hmg_storvnl_HANDLE( hIcon, -1, 2 );
      }
   }
}

HB_FUNC( INITOWNERBUTTON )
{
   HWND     hbutton;
   HWND     himage;
   HICON    hIcon;

#ifndef UNICODE
   LPCSTR   lpWindowName = hb_parc( 2 );
   LPCSTR   lpImageName = hb_parc( 8 );
   LPCSTR   lpIconName = hb_parc( 14 );
#else
   LPCWSTR  lpWindowName = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPCWSTR  lpImageName = AnsiToWide( ( char * ) hb_parc( 8 ) );
   LPCWSTR  lpIconName = AnsiToWide( ( char * ) hb_parc( 14 ) );
#endif
   DWORD    Style = BS_NOTIFY | WS_CHILD | BS_OWNERDRAW | ( hb_parl( 13 ) ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON ) | ( HB_ISNIL( 14 ) ? BS_BITMAP : BS_ICON );
   UINT     ImgStyle = hb_parl( 10 ) ? 0 : LR_LOADTRANSPARENT;

   if( hb_parl( 9 ) )
   {
      Style |= BS_FLAT;
   }

   if( !hb_parl( 11 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( !hb_parl( 12 ) )
   {
      Style |= WS_TABSTOP;
   }

   hbutton = CreateWindowEx
      (
         0,
         WC_BUTTON,
         lpWindowName,
         Style,
         hb_parni( 4 ),
         hb_parni( 5 ),
         hb_parni( 6 ),
         hb_parni( 7 ),
         hmg_par_raw_HWND( 1 ),
         hmg_par_raw_HMENU( 3 ),
         GetInstance(),
         NULL
      );

   SetProp( ( HWND ) hbutton, TEXT( "oldbtnproc" ), ( HWND ) GetWindowLongPtr( ( HWND ) hbutton, GWLP_WNDPROC ) );
   SubclassWindow2( hbutton, OwnButtonProc );

   if( HB_ISNIL( 14 ) )
   {
      himage = ( HWND ) LoadImage
         (
            GetResources(),
            lpImageName,
            IMAGE_BITMAP,
            HB_MAX( hb_parnidef( 15, 0 ), 0 ),
            HB_MAX( hb_parnidef( 16, 0 ), 0 ),
            LR_LOADMAP3DCOLORS | ImgStyle
         );

      if( himage == NULL )
      {
         himage = ( HWND ) LoadImage
            (
               NULL,
               lpImageName,
               IMAGE_BITMAP,
               HB_MAX( hb_parnidef( 15, 0 ), 0 ),
               HB_MAX( hb_parnidef( 16, 0 ), 0 ),
               LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | ImgStyle
            );
      }

      hb_reta( 2 );
      hmg_storvnl_HANDLE( hbutton, -1, 1 );
      hmg_storvnl_HANDLE( himage, -1, 2 );
   }
   else
   {
      hIcon = ( HICON ) LoadImage
         (
            GetResources(),
            lpIconName,
            IMAGE_ICON,
            HB_MAX( hb_parnidef( 15, 0 ), 0 ),
            HB_MAX( hb_parnidef( 16, 0 ), 0 ),
            LR_DEFAULTCOLOR
         );

      if( hIcon == NULL )
      {
         hIcon = ( HICON ) LoadImage
            (
               NULL,
               lpIconName,
               IMAGE_ICON,
               HB_MAX( hb_parnidef( 15, 0 ), 0 ),
               HB_MAX( hb_parnidef( 16, 0 ), 0 ),
               LR_LOADFROMFILE | LR_DEFAULTCOLOR
            );
      }

      if( hIcon == NULL )
      {
         hIcon = ( HICON ) ExtractIcon( GetInstance(), lpIconName, 0 );
      }

      hb_reta( 2 );
      hmg_storvnl_HANDLE( hbutton, -1, 1 );
      hmg_storvnl_HANDLE( hIcon, -1, 2 );
   }

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpWindowName );
   hb_xfree( ( TCHAR * ) lpImageName );
   hb_xfree( ( TCHAR * ) lpIconName );
#endif
}

HB_FUNC( _SETBTNPICTURE )
{
   HWND     hwnd = hmg_par_raw_HWND( 1 );
   HWND     himage;

#ifndef UNICODE
   LPCSTR   lpImageName = hb_parc( 2 );
#else
   LPWSTR   lpImageName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   himage = ( HWND ) LoadImage
      (
         GetResources(),
         lpImageName,
         IMAGE_BITMAP,
         HB_MAX( hb_parnidef( 3, 0 ), 0 ),
         HB_MAX( hb_parnidef( 4, 0 ), 0 ),
         LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT
      );

   if( himage == NULL )
   {
      himage = ( HWND ) LoadImage
         (
            NULL,
            lpImageName,
            IMAGE_BITMAP,
            HB_MAX( hb_parnidef( 3, 0 ), 0 ),
            HB_MAX( hb_parnidef( 4, 0 ), 0 ),
            LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT
         );
   }

   if( himage == NULL )
   {
      himage = ( HWND ) HMG_LoadPicture( hb_parc( 2 ), hb_parni( 3 ), hb_parni( 4 ), hwnd, 0, 1, -1, 0, HB_FALSE, 255 );
   }

   SendMessage( hwnd, BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

   RegisterResource( himage, "BMP" );
   hmg_ret_raw_HANDLE( himage );

#ifdef UNICODE
   hb_xfree( lpImageName );
#endif
}

HB_FUNC( _GETBTNPICTUREHANDLE )
{
   hmg_ret_raw_HWND( SendMessage( hmg_par_raw_HWND( 1 ), BM_GETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) 0 ) );
}

HB_FUNC( _SETMIXEDBTNPICTURE )
{
   HIMAGELIST  himl;

   himl = HMG_SetButtonImageList( hmg_par_raw_HWND( 1 ), hb_parc( 2 ), hb_parl( 3 ) ? 0 : 1, BUTTON_IMAGELIST_ALIGN_CENTER );

   RegisterResource( himl, "IMAGELIST" );
   hmg_ret_raw_HANDLE( himl );
}

// HMG 1.0 Experimental Build 8e
HB_FUNC( _SETBTNICON )
{
   HICON    hIcon;

#ifndef UNICODE
   LPCSTR   lpIconName = hb_parc( 2 );
#else
   LPWSTR   lpIconName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   hIcon = ( HICON ) LoadImage( GetResources(), lpIconName, IMAGE_ICON, HB_MAX( hb_parnidef( 3, 0 ), 0 ), HB_MAX( hb_parnidef( 4, 0 ), 0 ), LR_DEFAULTCOLOR );

   if( hIcon == NULL )
   {
      hIcon = ( HICON ) LoadImage
         (
            NULL,
            lpIconName,
            IMAGE_ICON,
            HB_MAX( hb_parnidef( 3, 0 ), 0 ),
            HB_MAX( hb_parnidef( 4, 0 ), 0 ),
            LR_LOADFROMFILE | LR_DEFAULTCOLOR
         );
   }

   SendMessage( hmg_par_raw_HWND( 1 ), BM_SETIMAGE, ( WPARAM ) IMAGE_ICON, ( LPARAM ) hIcon );

   RegisterResource( hIcon, "ICON" );
   hmg_ret_raw_HANDLE( hIcon );

#ifdef UNICODE
   hb_xfree( lpIconName );
#endif
}

HB_FUNC( _SETMIXEDBTNICON )
{
   BITMAP            bm;
   ICONINFO          sIconInfo;

#ifndef UNICODE
   LPCSTR            lpIconName = hb_parc( 2 );
#else
   LPWSTR            lpIconName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   HIMAGELIST        himl;
   BUTTON_IMAGELIST  bi;

   HICON             hIcon = ( HICON ) LoadImage( GetResources(), lpIconName, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR );

   if( hIcon == NULL )
   {
      hIcon = ( HICON ) LoadImage( NULL, lpIconName, IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );
   }

   GetIconInfo( hIcon, &sIconInfo );

   GetObject( sIconInfo.hbmColor, sizeof( BITMAP ), ( LPVOID ) & bm );

   if( sIconInfo.hbmMask )
   {
      DeleteObject( sIconInfo.hbmMask );
   }

   if( sIconInfo.hbmColor )
   {
      DeleteObject( sIconInfo.hbmColor );
   }

   himl = ImageList_Create( bm.bmWidth, bm.bmHeight, ILC_COLOR32 | ILC_MASK, 1, 0 );

   ImageList_AddIcon( himl, hIcon );

   DestroyIcon( hIcon );

   bi.himl = himl;
   bi.margin.left = 10;
   bi.margin.top = 10;
   bi.margin.bottom = 10;
   bi.margin.right = 10;
   bi.uAlign = 4;

   SendMessage( hmg_par_raw_HWND( 1 ), BCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) & bi );

   RegisterResource( himl, "IMAGELIST" );
   hmg_ret_raw_HANDLE( himl );

#ifdef UNICODE
   hb_xfree( lpIconName );
#endif
}

HB_FUNC( DRAWBUTTON )
{
   DRAWITEMSTRUCT *pps = hmg_par_raw_DITEMSTRUCT( 4 );

   UINT           iFocus = hb_parni( 2 );
   UINT           iState = hb_parni( 3 );
   UINT           iMouseOver = hb_parni( 5 );
   UINT           iFlat = hb_parni( 6 );

   if( iFocus == 1 || iMouseOver == 1 )
   {
      InflateRect( &pps->rcItem, -1, -1 );
   }

   DrawFrameControl( pps->hDC, &pps->rcItem, DFC_BUTTON, iFlat ? ( iState | DFCS_FLAT ) : iState );

   if( iFocus == 1 )
   {
      HPEN     OldPen = ( HPEN ) SelectObject( pps->hDC, GetStockObject( BLACK_PEN ) );
      HBRUSH   OldBrush = ( HBRUSH ) SelectObject( pps->hDC, GetStockObject( NULL_BRUSH ) );

      InflateRect( &pps->rcItem, 1, 1 );
      Rectangle( pps->hDC, pps->rcItem.left, pps->rcItem.top, pps->rcItem.right, pps->rcItem.bottom );

      SelectObject( pps->hDC, OldBrush );
      SelectObject( pps->hDC, OldPen );
   }
}

/*
   Function GETOWNBTNHANDLE return value of hwndItem DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNHANDLE )
{
   DRAWITEMSTRUCT *pps = hmg_par_raw_DITEMSTRUCT( 1 );

   if( pps )
   {
      hmg_ret_raw_HWND( pps->hwndItem );
   }
}

/*
   Function GETOWNBTNSTATE return value of itemState DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNSTATE )
{
   DRAWITEMSTRUCT *pps = hmg_par_raw_DITEMSTRUCT( 1 );

   if( pps )
   {
      hmg_ret_UINT( pps->itemState );
   }
}

/*
   Function GETOWNBTNDC return value of hDC DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNDC )
{
   DRAWITEMSTRUCT *pps = hmg_par_raw_DITEMSTRUCT( 1 );

   if( pps )
   {
      hmg_ret_raw_HANDLE( pps->hDC );
   }
}

/*
   Function GETOWNBTNITEMACTION return value of itemID DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNITEMID )
{
   DRAWITEMSTRUCT *pps = hmg_par_raw_DITEMSTRUCT( 1 );

   if( pps )
   {
      hmg_ret_UINT( pps->itemID );
   }
}

/*
   Function GETOWNBTNITEMACTION return value of itemAction DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNITEMACTION )
{
   DRAWITEMSTRUCT *pps = hmg_par_raw_DITEMSTRUCT( 1 );

   if( pps )
   {
      hmg_ret_UINT( pps->itemAction );
   }
}

/*
   Function GETOWNBTNCTLTYPE return value of CtlType DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNCTLTYPE )
{
   DRAWITEMSTRUCT *pps = hmg_par_raw_DITEMSTRUCT( 1 );

   if( pps )
   {
      hmg_ret_UINT( pps->CtlType );
   }
}

/*
   Function GETOWNBTNRECT return array with button rectangle coords
 */
HB_FUNC( GETOWNBTNRECT )
{
   PHB_ITEM       aMetr = hb_itemArrayNew( 4 );
   DRAWITEMSTRUCT *pps = hmg_par_raw_DITEMSTRUCT( 1 );

   RECT           rc = pps->rcItem;

   HB_arraySetNL( aMetr, 1, rc.left );
   HB_arraySetNL( aMetr, 2, rc.top );
   HB_arraySetNL( aMetr, 3, rc.right );
   HB_arraySetNL( aMetr, 4, rc.bottom );

   hb_itemReturnRelease( aMetr );
}

LRESULT CALLBACK OwnButtonProc( HWND hButton, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB   pSymbol = NULL;
   LRESULT           r;
   TRACKMOUSEEVENT   tme;
   WNDPROC           OldWndProc;

   OldWndProc = ( WNDPROC ) ( HB_PTRUINT ) GetProp( hButton, TEXT( "oldbtnproc" ) );

   switch( Msg )
   {
      case WM_DESTROY:
         SubclassWindow2( hButton, OldWndProc );
         RemoveProp( hButton, TEXT( "oldbtnproc" ) );
         break;

      case WM_LBUTTONDBLCLK:
         SendMessage( hButton, WM_LBUTTONDOWN, wParam, lParam );
         break;

      case WM_MOUSEMOVE:
         tme.cbSize = sizeof( TRACKMOUSEEVENT );
         tme.dwFlags = TME_LEAVE;
         tme.hwndTrack = hButton;
         tme.dwHoverTime = 0;
         _TrackMouseEvent( &tme );

         if( !pSymbol )
         {
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OBTNEVENTS" ) );
         }

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( HB_PTRUINT ) hButton );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hmg_par_LRESULT( -1 );

         return( r != 0 ) ? r : DefWindowProc( hButton, Msg, wParam, lParam );

      case WM_MOUSELEAVE:
         if( !pSymbol )
         {
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OBTNEVENTS" ) );
         }

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( HB_PTRUINT ) hButton );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hmg_par_LRESULT( -1 );

         return( r != 0 ) ? r : DefWindowProc( hButton, Msg, wParam, lParam );
   }

   return CallWindowProc( OldWndProc, hButton, Msg, wParam, lParam );
}

/*
 * Added in Build 16.12
 */
HB_FUNC( CREATEBUTTONBRUSH )
{
   HBRUSH   hBrush = CreateGradientBrush( hmg_par_raw_HDC( 1 ), hb_parni( 2 ), hb_parni( 3 ), hmg_par_COLORREF( 4 ), hmg_par_COLORREF( 5 ) );

   RegisterResource( hBrush, "BRUSH" );
   hmg_ret_raw_HBRUSH( hBrush );
}

static HBRUSH CreateGradientBrush( HDC hDC, INT nWidth, INT nHeight, COLORREF Color1, COLORREF Color2 )
{
   HDC      hDCComp;
   HBITMAP  hBitmap;
   HBRUSH   hBrush, hBrushOld, hBrushPat;
   RECT     rcF;
   int      r1, g1, b1, r2, g2, b2;
   int      nCount;
   int      i;

   r1 = GetRValue( Color1 );
   g1 = GetGValue( Color1 );
   b1 = GetBValue( Color1 );
   r2 = GetRValue( Color2 );
   g2 = GetGValue( Color2 );
   b2 = GetBValue( Color2 );

   hDCComp = CreateCompatibleDC( hDC );
   hBitmap = CreateCompatibleBitmap( hDC, nWidth, nHeight );
   SelectObject( hDCComp, hBitmap );

   rcF.left = 0;
   rcF.top = 0;
   rcF.right = nWidth;
   rcF.bottom = nHeight;
   nCount = ( int ) ceil( ( double ) ( ( nWidth > nHeight ) ? nHeight : nWidth ) / 2 );

   for( i = 0; i < nCount; i++ )
   {
      hBrush = CreateSolidBrush( RGB( r1 + ( i * ( r2 - r1 ) / nCount ), g1 + ( i * ( g2 - g1 ) / nCount ), b1 + ( i * ( b2 - b1 ) / nCount ) ) );
      hBrushOld = SelectObject( hDCComp, hBrush );
      FillRect( hDCComp, &rcF, hBrush );
      SelectObject( hDCComp, hBrushOld );
      DeleteObject( hBrush );

      InflateRect( &rcF, -1, -1 );
   }

   hBrushPat = CreatePatternBrush( hBitmap );

   DeleteDC( hDCComp );
   DeleteObject( hBitmap );

   return hBrushPat;
}

HIMAGELIST HMG_SetButtonImageList( HWND hButton, const char *FileName, int Transparent, UINT uAlign )
{
   HBITMAP           hBitmap;
   HIMAGELIST        hImageList;
   BITMAP            Bmp;
   BUTTON_IMAGELIST  bi;
   TCHAR             TempPathFileName[MAX_PATH];

   hBitmap = HMG_LoadPicture( FileName, -1, -1, NULL, 0, 0, -1, 0, HB_TRUE, 255 );
   if( hBitmap == NULL )
   {
      return NULL;
   }

   GetObject( hBitmap, sizeof( BITMAP ), &Bmp );

   GetTempPath( MAX_PATH, TempPathFileName );
   lstrcat( TempPathFileName, TEXT( "_MG_temp.BMP" ) );
   bmp_SaveFile( hBitmap, TempPathFileName );
   DeleteObject( hBitmap );

   if( Transparent == 1 )
   {
      hImageList = ImageList_LoadImage
         (
            GetResources(),
            TempPathFileName,
            Bmp.bmWidth,
            6,
            CLR_DEFAULT,
            IMAGE_BITMAP,
            LR_LOADFROMFILE | LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT
         );
   }
   else
   {
      hImageList = ImageList_LoadImage
         (
            GetResources(),
            TempPathFileName,
            Bmp.bmWidth,
            6,
            CLR_NONE,
            IMAGE_BITMAP,
            LR_LOADFROMFILE | LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS
         );
   }

   DeleteFile( TempPathFileName );

   bi.himl = hImageList;
   bi.margin.left = 10;
   bi.margin.top = 10;
   bi.margin.bottom = 10;
   bi.margin.right = 10;
   bi.uAlign = uAlign;

   SendMessage( hButton, BCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) & bi );

   return hImageList;
}
