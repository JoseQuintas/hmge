
#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

//        HMG_SetCursorPos ( [ hWnd ], nRow, nCol )
HB_FUNC ( HMG_SETCURSORPOS )
{
   HWND  hWnd;
   POINT Point;

   hWnd    = (HWND) hb_parnl (1);
   Point.y = (LONG) hb_parnl (2);
   Point.x = (LONG) hb_parnl (3);

   if ( IsWindow (hWnd) )
        ClientToScreen (hWnd, &Point);

   SetCursorPos ((int)Point.x, (int)Point.y);
}

#pragma ENDDUMP

*
* EOF
*