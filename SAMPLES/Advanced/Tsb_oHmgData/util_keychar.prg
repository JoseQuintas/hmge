/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2021 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2021 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ѕоиск по нескольким €зыкам RU-EN-UA в Tsbrowse
 * Search multiple languages RU-EN-UA in Tsbrowse
*/

#define  _HMG_OUTLOG
#include "hmg.ch"

////////////////////////////////////////////////////////////////////////////////
FUNCTION myModeFind(nKey,cForm)
   LOCAL nModeFind, cChr

   nModeFind := GetProperty(cForm, "Combo_1", "Value" )
   IF nModeFind == 1                   // обработка “—Ѕ: поиск строго по одному €зыку
      cChr := KeyToChar(nKey)
   ELSEIF nModeFind == 2               // обработка “—Ѕ: преобразовать Eng -> Rus
      cChr := LatUkrRus(nKey,"RU")
   ELSEIF nModeFind == 3               // обработка “—Ѕ: преобразовать Eng -> Ukr
      cChr := LatUkrRus(nKey,"UK")
   ELSE
      AlertStop("Ќет обработки по –≈∆»ћ” поиска: "+STR(nModeFind))
      cChr := "***"
   ENDIF

RETURN cChr

////////////////////////////////////////////////////////////////////////////////
/*STATIC FUNCTION myKeyAction(nKey,nValButton,nFlags,oBrw)
   LOCAL cForm, cAlias, cSearch, lRet := .T.
   DEFAULT oBrw := oBrw_Street
   DEFAULT nValButton := 0, nFlags := 0

   IF ! ISOBJECT(oBrw) ; RETURN .F.
   ENDIF

   cForm   := oBrw:cParentWnd
   cAlias  := oBrw:cAlias
   cSearch := Alltrim(cStaticFind)

   DO CASE
      CASE nKey == VK_BACK      // Backspace
         IF LEN(cSearch) > 0
            cSearch     := LEFT(cSearch,LEN(cSearch)-1)
            cStaticFind := cSearch
            SetProperty(cForm, "Text_1", "Value", cSearch )
            _wSend(1, cForm)
         ENDIF

      CASE nKey > 31 .AND. nKey < 254
         ? KB_LANG(), "nKey=", nKey, "->", myModeFind(nKey,cForm)
         cSearch     := cSearch + myModeFind(nKey,cForm)
         cStaticFind := cSearch
         SetProperty(cForm, "Text_1", "Value", cSearch )
         _wSend(1, cForm)

      CASE nKey == 16 .OR. nKey == 17  // Shift+Alt  Shift+Ctrl  "RUS/ENG"
         SetProperty(cForm, "Label_KB", "Value", '('+KB_LANG()+')' )
         lRet := .f.

   ENDCASE

Return lRet
*/

//////////////////////////////////////////////////////////////////////////////
// ѕреобразование клавиши к верхнему регистру русского/украинского алфавита
Function LatUkrRus(nKey, cLang)
   LOCAL nKeyboardMode := GetKeyboardMode()
   LOCAL cStr := UPPER(CHR(nKey))
   DEFAULT cLang := ""

   IF nKeyboardMode == 1049                                 // RU
      cStr := CharRepl("F,DULT;PBQRKVYJGHCNEA[WXIOSM'.Z",cStr,;
                       'јЅ¬√ƒ≈∆«»… ЋћЌќѕ–—“”‘’÷„Ўўџ№Ёёя')
   ELSEIF nKeyboardMode == 1033 .AND. cLang == "RU"         // US -> RU
      cStr := CharRepl("F,DULT;PBQRKVYJGHCNEA[WXIOSM'.Z",cStr,;
                       'јЅ¬√ƒ≈∆«»… ЋћЌќѕ–—“”‘’÷„Ўўџ№Ёёя')
   ELSEIF nKeyboardMode == 1033  .AND. cLang == "UK"        // US -> UK
      // не знаю как здесь делать
      MsgDebug( App.ExeName, "—делать ввод дл€ украинского €зыка !" )
   ELSEIF nKeyboardMode == 1058                             // UK
      // не знаю как здесь делать
      MsgDebug( App.ExeName, "—делать ввод дл€ украинского €зыка !" )
   ELSE
      MsgDebug( App.ExeName, "New mode ! nKeyboardMode =", nKeyboardMode )
   ENDIF

Return cStr

/*------------------------------------------------------------------------------
*      http://clipper.borda.ru/?1-4-0-00000995-000-0-0-1408978369
*/
Function KB_LANG()
Local rsl, cRet := "???"

rsl := RASKLADKA()
IF rsl == "00000409"
   cRet := "ENG"
ELSEIF rsl == "00000419"
   cRet := "RUS"
ELSEIF rsl == "00020422"
   cRet := "UKR"
ELSE
   cRet := rsl
ENDIF

return cRet


#pragma BEGINDUMP

#include "Windows.h"
#include "hbapi.h"

HB_FUNC(KB_RUS) { LoadKeyboardLayout("00000419", KLF_ACTIVATE) ; }
HB_FUNC(KB_ENG) { LoadKeyboardLayout("00000409", KLF_ACTIVATE) ; }
HB_FUNC(KB_UKR) { LoadKeyboardLayout("00020422", KLF_ACTIVATE) ; }

HB_FUNC(RASKLADKA)
{
TCHAR m_PreviousLayout[KL_NAMELENGTH] ;
GetKeyboardLayoutName(m_PreviousLayout);
hb_retc(m_PreviousLayout);
}

#pragma ENDDUMP

//------------------------------------------------------------------------------
// http://clipper.borda.ru/?1-1-0-00000133-000-0-1-1633722825
Function KeyToChar( nVirtKey )
//------------------------------------------------------------------------------
   LOCAL i, cRetChar := ""
   LOCAL nKeyboardMode := GetKeyboardMode()
   LOCAL lShift := CheckBit( GetKeyState( 16 ), 32768 )
   LOCAL aKeysNumPad := { 96,97,98,99,100,101,102,103,104,105,106,107,109,110,111 }
   LOCAL cKeysNumPad := "0123456789*+-./"
   LOCAL aKeys1 := { 192,189,187,219,221,220,186,222,188,190,191 }
   LOCAL cKeys1US := "`-=[]\;',./"
   LOCAL cKeys1ShiftUS := '~_+{}|:"<>?'
   LOCAL cKeys1RU := "®-=’Џ\∆ЁЅё."
   LOCAL cKeys1ShiftRU := "®_+’Џ/∆ЁЅё,"
   LOCAL cKeys2US := "1234567890QWERTYUIOPASDFGHJKLZXCVBNM "
   LOCAL cKeys2ShiftUS := "!@#$%^&*()QWERTYUIOPASDFGHJKLZXCVBNM "
   LOCAL cKeys2RU := "1234567890…÷” ≈Ќ√Ўў«‘џ¬јѕ–ќЋƒя„—ћ»“№ "
   LOCAL cKeys2ShiftRU := '!"є;%:?*()…÷” ≈Ќ√Ўў«‘џ¬јѕ–ќЋƒя„—ћ»“№ '

   i := ascan( aKeysNumPad, nVirtKey )
   if i > 0
      RETURN substr( cKeysNumPad, i, 1 )
   endif

   i := ascan( aKeys1, nVirtKey )
   if i > 0
      if nKeyboardMode == 1033                        // US
         if lShift
            cRetChar := substr( cKeys1ShiftUS, i, 1 )
         else
            cRetChar := substr( cKeys1US, i, 1 )
         endif
      elseif nKeyboardMode == 1049                    // RU
         if lShift
            cRetChar := substr( cKeys1ShiftRU, i, 1 )
         else
            cRetChar := substr( cKeys1RU, i, 1 )
         endif
      elseif nKeyboardMode == 1058                   // UK
         // не знаю как здесь делать
         MsgDebug( App.ExeName, "—делать ввод дл€ украинского €зыка !" )

      else
         MsgDebug( App.ExeName, "New mode ! nKeyboardMode =", nKeyboardMode )
      endif
      RETURN cRetChar
   endif

   i := at( chr( nVirtKey ), cKeys2US )
   if i > 0
      if nKeyboardMode == 1033                       // US
         if lShift
            cRetChar := substr( cKeys2ShiftUS, i, 1 )
         else
            cRetChar := substr( cKeys2US, i, 1 )
         endif
      elseif nKeyboardMode == 1049                   // RU
         if lShift
            cRetChar := substr( cKeys2ShiftRU, i, 1 )
         else
            cRetChar := substr( cKeys2RU, i, 1 )
         endif
      elseif nKeyboardMode == 1058                  // UK
         // не знаю как здесь делать
         MsgDebug( App.ExeName, "—делать ввод дл€ украинского €зыка !" )

      endif
   endif

   RETURN cRetChar

//------------------------------------------------------------------------------
#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( GETKEYBOARDMODE )
{
   HKL kbl;
   HWND CurApp;
   DWORD idthd;
   int newmode;

   CurApp=GetForegroundWindow();
   idthd=GetWindowThreadProcessId(CurApp,NULL);

   kbl=GetKeyboardLayout(idthd);
   newmode=(int)LOWORD(kbl);

   hb_retnl(newmode);
}
#pragma ENDDUMP
