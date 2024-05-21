/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Работа с меню / Working with the menu
*/

#define _HMG_OUTLOG
#include "minigui.ch"

///////////////////////////////////////////////////////////////////////////////////////
FUNCTION Menu_Print(oWnd,ky,cn,oBrw)                 // F5 - печать
   LOCAL aMenu, nY, nX, nI, cForm, aBtnObj, aBtn5, cMsg

   ? ProcNL(), oWnd,ky,cn,oBrw
   cForm   := oWnd:Name
   aBtnObj := oWnd:Cargo:aBtnObj     // массив кнопок на форме
   aBtn5   := aBtnObj[5]

   This.&(cn).Enabled := .F.         // для вызова по клавише F5

   aMenu := {}
   IF App.Cargo:cLang == "RU"
      AADD( aMenu, {"iPrint48x1", "Печать форма А10" } )
      AADD( aMenu, {"", ""                           } )
      AADD( aMenu, {"iPrint48x1", "Печать форма Ф12" } )
      AADD( aMenu, {"", ""                           } )
      AADD( aMenu, {"iExcel48x1", "Экспорт в Эксель - форма Э2" } )
   ELSE
      AADD( aMenu, {"iPrint48x1", "Print form A10" } )
      AADD( aMenu, {"", "" } )
      AADD( aMenu, {"iPrint48x1", "Print form F12" } )
      AADD( aMenu, {"", ""                           } )
      AADD( aMenu, {"iExcel48x1", "Export to Excel - E2 form" } )
   ENDIF
   //  1      2          3             4      5   6    7    8
   // {5, "_Print", "-имя объекта", "Печать", 0, 564, 131, 69, "_Print", "-событие"}
   nY := GetProperty(cForm, cn, "Row") + aBtn5[5] + aBtn5[8] + 2
   nX := GetProperty(cForm, cn, "Col") + aBtn5[6] - 5
   nI := myContextMenu(aMenu, nY, nX, "Icon")  // "Bmp"

   cMsg := IIF( App.Cargo:cLang == "RU","нет выбора!", "no choice!" )
   MsgDebug(nI, IIF( nI>0,aMenu[nI],cMsg) )

   This.&(cn).Enabled := .T.         // для вызова по клавише F5

RETURN NIL

