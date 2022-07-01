/*
*        _____  _        __    __                 __      __
*       |  _  || |  __ _ \ \  / / ___  _ __      /  |    /  |
*       | |_| || | / _` | \ \/ / / _ \| '__|    |_  |   |_  |
*       |  ___|| || (_| |  \  / |  __/| |         | |  _  | |
*       |_|    |_| \__,_|  /_/   \___||_|         |_| |_| |_|
*
* (c) 2004 FreeWare - Humberto Fornazier / Brasil
*             hfornazier@yahoo.com.br
*      http://www.geocities.ws/harbourminas/
*
* Humberto Fornazier - Junho/2004
* hfornazier@yahoo.com.br
*
* Harbour MiniGUI Build 98 (HMG 1.0 RELEASE CANDIDATE XIV) (2004.05.30)
* Copyright 2002 Roberto Lopez <roblez@ciudad.com.ar>
* http://www.geocities.com/harbour_minigui/
*
* Rewritted for OOHG by Miguel A. Juárez A. <migsoft@oohg.org> - April/2022
* Rewritted for Minigui Extended by Grigory Filatov and Pierpaolo Martinello
*/

#include "minigui.ch"
#include "Directry.ch"
#include "fileio.ch"
#include "MyPlayer.ch"

#translate IsMp3() => !lPlaylist
#translate AutoMsgInfo => MsgInfo
/*
*/
PROCEDURE Main()

   Ambiente_Inicial()
   MusicasDisponiveis()
   Definiciones_One()

RETURN
/*
*/
PROCEDURE Ambiente_Inicial()

   Cria_Ini_File()

   cDirMusicas := PastaAtualDeMusicas()
   lContinua := ReproduzirContinuamente()
   lSorteia := SorteiaMusicas()

   cSkin := Skins()

   If ! File( cSkin )
      cSkin := "MyPlayer"
   ENDIF

RETURN
/*
 * - Esta Função verifica as Músicas disponíveis na pasta de Música Definida pelo usuário
 * - Verifica Musicas que contenham as Palavras definidas em MyPlayer.INI
 * -
 */
FUNCTION MusicasDisponiveis()

   LOCAL aFiles := Directory( cDirMusicas + "*.*" )
   LOCAL aF, cFn, ext, ww, lcW
   LOCAL aPalavras := Palavras()
   aMusicas := {}

   lcW := ( Len( apalavras ) = 0 )

   FOR EACH aF IN aFiles
      ww := .F.
      ext := Upper( hb_FNameExt( af[ 1 ] ) )
      Cfn := Upper( hb_FNameName( af[ 1 ] ) )
      AEval( aPalavras, {| x | if( x $ cFn, ww := .T., NIL ) } )
      ww := lcw .OR. ww

      DO CASE
      CASE EXT == ".MP3" .AND. ww
         AAdd( aMusicas, AllTrim( aF[ 1 ] ) )
         lPlaylist := .F.
      CASE EXT == ".M3U" .AND. ww
         AAdd( aMusicas, AllTrim( aF[ 1 ] ) )
         lPlaylist := .T.
      CASE EXT == ".M3U8" .AND. ww
         AAdd( aMusicas, AllTrim( aF[ 1 ] ) )
         lPlaylist := .T.
      ENDCASE
   NEXT

   ASort( aMusicas )

RETURN NIL
/*
*/
// ------------------------------------------------------------*
FUNCTION Slider1_Change()
// ------------------------------------------------------------*
   LOCAL nValue := Form_Player.Slider_1.VALUE
   SET PLAYER Play_1 OF Form_Player VOLUME nValue * 100

RETURN NIL
/*
*/
// ------------------------------------------------------------*
FUNCTION Slider2_Change()
// ------------------------------------------------------------*
   LOCAL nValue := Form_Player.Play_1.Position
   Form_Player.Slider_2.VALUE := ( Int( nValue / nLenght * 100 ) )

RETURN NIL
/*
*/
PROCEDURE ExecutarMusica( cMusica )

   If ! Empty( cMusica ) .OR. File( cMusica )
      IF IsControlDefined( Timer_Abertura, Form_Player )
         Form_Player.Timer_Abertura.RELEASE
      ENDIF

      IF Upper( Right( AllTrim( cMusica ), 3 ) ) = "M3U" .OR. Upper( Right( AllTrim( cMusica ), 4 ) ) = "M3U8"
         lPlaylist := .T.
         AchoiceChannel( cMusica )
      ELSE
         cFile := cMusica
         Form_Player.Play_1.Open( _GetShortPathName( cFile ) )

         If ! IsControlDefined( Timer_1, Form_Player )
            DEFINE TIMER Timer_1 INTERVAL 200 ACTION ChekaTerminoDaMusicaExecutada() OF Form_Player
         ENDIF

         cNomeMusicaAtual := NomeDoArquivo( cFile )
         nLenght := Form_Player.Play_1.Length
         Form_Player.Img_Leds1.PICTURE := "Led1On"

         Form_Player.Play_1.Play()

         lPlayPause := .F.
         Form_Player.TITLE := cNomeMusicaAtual
         Form_Player.LbTempoTotal.VALUE := TempoTotal( nLenght )
         nCtEfeito := 0
         cDescEfeito := ""

         CambiaTrack()

      ENDIF
   ELSE
      MsgInfo( "Error File is not Found: " + cMusica )
   ENDIF

RETURN
/*
 * El Temporizador configurado en el Programa (Timer_1) comprueba en esta función si la canción ha finalizado.
 * La variable nLenght tiene el tamaño de la canción y Form_Player.Play_1.Position proporciona la
 * posición actual de la canción que se está reproduciendo.
 * Cuando la Posición Escuchada es mayor o igual al tamaño total de la canción:
 * - El tamaño de la canción se restablece
 * - El lanzamiento se realiza en el temporizador (que se recreará cuando se reproduzca una nueva canción)
 * - Si la Variable lContinua es .T., el programa seleccionará una nueva canción, si
 *   de lo contrario marque Variable lPlayPause
 */
PROCEDURE ChekaTerminoDaMusicaExecutada()

   IF IsMP3()

      IF Form_Player.Play_1.Position >= nLenght
         nLenght := 0
         IF IsControlDefined( Timer_1, Form_Player )
            Form_Player.Timer_1.RELEASE
         ENDIF
         IF lContinua
            nProxima ++
            IF Len( aMusicas ) > 0
               IF lSorteia
                  nProxima := Random( Len( aMusicas ) )
                  nProxima := iif( nProxima == 0, 1, nProxima )
               ENDIF
               IF nProxima > Len( aMusicas ) .OR. nProxima < 1
                  nProxima := 1
               ENDIF
               ExecutarMusica( cDirMusicas + aMusicas[ nProxima ] )
            ELSE
               lPlayPause := .T.
            ENDIF
         ELSE
            lPlayPause := .T.
         ENDIF
         IF lPlayPause
            IF IsControlDefined( Timer_1, Form_Player )
               Form_Player.Timer_1.RELEASE
            ENDIF
         ENDIF
      ENDIF

      Slider2_Change()
      Slider1_Change()

      If ! lPlayPause
         Form_Player.LbTempoReproducao.VALUE := TempoTotal( nLenght - Form_Player.Play_1.Position )
         EfeitoLabel2()
         IF lDesliga
            Form_Player.LbClockTermino.VALUE := "Clock: " + Right( ElapTime( cDesligarEm, Time() ), 5 ) + " in " + AllTrim( cMinutos )
            IF Right( ElapTime( cDesligarEm, Time() ), 5 ) >= AllTrim( cMinutos )
               IF IsControlDefined( Play_1, Form_Player )
                  Form_Player.Play_1.Stop
                  Form_Player.Play_1.RELEASE
               ENDIF
               Form_Player.RELEASE
            ENDIF
         ENDIF
      ENDIF

   ENDIF

   DO EVENTS

RETURN
/*
*/
PROCEDURE CambiaTrack
   Form_Player.LbMusicaAtual.VALUE := AllTrim( Str( nProxima ) ) + "/" + AllTrim( Str( Len( aMusicas ) ) )
   IF isWindowDefined( "Form_2" )
      Form_2.List_1.VALUE := nProxima
   ENDIF

RETURN
/*
*/
PROCEDURE MyPlay()
   IF IsMP3()
      IF Len( aMusicas ) > 0
         IF lPlayPause
            Form_Player.Play_1.Resume()
            Form_Player.Img_Leds1.PICTURE := "Led1On"
         ELSE
            SET PLAYER Play_1 OF Form_Player POSITION HOME
            Form_Player.Play_1.Play()
            nLenght := Form_Player.Play_1.Length
            ExecutarMusica( cDirMusicas + aMusicas[ nProxima ] )
            ChekaTerminoDaMusicaExecutada()
         ENDIF
         CambiaTrack()
         lPlayPause := .F.
      ENDIF
   ENDIF

RETURN
/*
*/
PROCEDURE MPProximaMusica()
   IF IsMP3()
      IF Len( aMusicas ) > 0
         SET PLAYER Play_1 OF Form_Player POSITION END
         lPlayPause := .F.
         nProxima ++
         IF nProxima >= Len( aMusicas )
            nProxima := Len( aMusicas )
         ENDIF
         ExecutarMusica( cDirMusicas + aMusicas[ nProxima ] )
         ChekaTerminoDaMusicaExecutada()
         CambiaTrack()
      ENDIF
   ENDIF

RETURN
/*
*/
PROCEDURE MPMusicaAnterior()
   IF IsMP3()
      IF Len( aMusicas ) > 0
         SET PLAYER Play_1 OF Form_Player POSITION END
         lPlayPause := .F.
         nProxima --
         IF nProxima <= 0
            nProxima := 1
         ENDIF
         ExecutarMusica( cDirMusicas + aMusicas[ nProxima ] )
         ChekaTerminoDaMusicaExecutada()
         CambiaTrack()
      ENDIF
   ENDIF

RETURN
/*
*/
PROCEDURE MPMusicaInicio()
   IF IsMP3()
      IF Len( aMusicas ) > 0
         SET PLAYER Play_1 OF Form_Player POSITION HOME
         lPlayPause := .F.
         nProxima := 1
         ExecutarMusica( cDirMusicas + aMusicas[ nProxima ] )
         ChekaTerminoDaMusicaExecutada()
         CambiaTrack()
      ENDIF
   ENDIF

RETURN
/*
*/
PROCEDURE MPMusicaFinal()
   IF IsMP3()
      IF Len( aMusicas ) > 0

         SET PLAYER Play_1 OF Form_Player POSITION END
         lPlayPause := .F.
         nProxima := Len( aMusicas )
         ExecutarMusica( cDirMusicas + aMusicas[ nProxima ] )
         ChekaTerminoDaMusicaExecutada()
         CambiaTrack()
      ENDIF
   ENDIF

RETURN
/*
*/
PROCEDURE PararReproducao()
   IF IsMP3()
      Form_Player.Play_1.Stop
      Form_Player.Img_Leds1.PICTURE := "Led1Off"
      IF IsControlDefined( Timer_1, Form_Player )
         Form_Player.Timer_1.RELEASE
      ENDIF
      ResetCount()
      nProxima := 1
      If ! IsControlDefined( Timer_Abertura, Form_Player )
         DEFINE TIMER Timer_Abertura INTERVAL 100 ACTION Efeito_Abertura() OF Form_Player
      ENDIF
      SET PLAYER Play_1 OF Form_Player POSITION HOME
      lPlayPause := .F.
      Form_Player.Slider_2.VALUE := 0
   ENDIF

RETURN
/*
*/
PROCEDURE MyPause()
   IF IsMP3()
      If ! Empty( cFile ) .OR. File ( cFile )
         IF Form_Player.Play_1.Position > 0
            If ! lPlayPause
               Form_Player.Img_Leds1.PICTURE := "Led1Off"
               Form_Player.LbMusicaAtual.VALUE := "Pause "
               Form_Player.Play_1.Pause()
               lPlayPause := .T.
            ELSE
               Form_Player.Img_Leds1.PICTURE := "Led1On"
               CambiaTrack()
               Form_Player.Play_1.Resume()
               lPlayPause := .F.
            ENDIF
         ENDIF
      ENDIF
   ENDIF

RETURN
/*
*/
FUNCTION AchoiceMusicas()

   LOCAL aItens := {}
   LOCAL nRow := App.HEIGHT + App.ROW + GetBorderHeight()
   LOCAL nCol := App.COL

   MusicasDisponiveis() // add By Pierpaolo Martinello  for relist the new songs added to folder

   aItens := aMusicas

   IF isWindowDefined( "Form_2" ) // add By Pierpaolo Martinello
      RETURN NIL
   ENDIF

   DEFINE WINDOW Form_2 ;  // 212
         AT nRow, nCol ;  // 192
         WIDTH 492 HEIGHT 280 ;
         TITLE 'Select File:' ;
         ICON 'Musicas2' ;
         CHILD ;
         NOSIZE ;
         NOSYSMENU

      @ 190, 0 IMAGE BackGr ;
         PICTURE cSkin ;
         WIDTH 490 ;
         HEIGHT 100 STRETCH

      @ 0, 0 LISTBOX List_1 ;
         WIDTH 490 ;
         HEIGHT 200 ;
         ITEMS aItens ;
         VALUE nProxima ;
         FONT "Ms Sans Serif" SIZE 09 ;
         ON DBLCLICK DesdeList( aItens )

      @ 210, 10 LABEL LbPastaAtual ;
         WIDTH 330 ;
         HEIGHT 20 ;
         VALUE 'Folder: ' + cDirMusicas ;
         FONT 'Arial' SIZE 07 ;
         FONTCOLOR WHITE ;
         AUTOSIZE TRANSPARENT

      @ 228, 10 BUTTON Bt_Folder ;
         PICTURE 'Folder' ;
         ACTION NovaPastaDeMusicas() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Select Folder:"

      @ 228, 36 BUTTON Bt_Close ;
         PICTURE 'Close' ;
         ACTION Form_2.RELEASE ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Close..."

   END WINDOW

   Form_2.ACTIVATE

RETURN NIL
/*
*/
PROCEDURE DesdeList( aOrd )

   nProxima := Form_2.List_1.VALUE
   ExecutarMusica( cDirMusicas + aOrd[ Form_2.List_1.Value ] )

RETURN
/*
*/
FUNCTION AchoiceChannel( cMusica )

   LOCAL aItens := {}, aNome := {}, aM3U, n
   LOCAL nRow := App.HEIGHT + App.ROW
   LOCAL nCol := App.COL

   ResetCount()

   aOrd := {}
   aM3U := M3U2Arr( cMusica )

   FOR n := 1 TO Len( aM3U )
      AAdd( aItens, aM3U[ n ][ 3 ] )
      AAdd( aOrd, aM3U[ n ][ 4 ] )
      AAdd( aNome, NomeDoArquivo( aM3U[ n ][ 4 ] ) )
   NEXT

   IF Upper( Right( AllTrim( aM3U[ 1 ][ 4 ] ), 4 ) ) = "MP3"
      cDirMP3 := cFilePath( aM3U[ 1 ][ 4 ] )
      ACopy( aOrd, aItens )
   ENDIF

   IF isWindowDefined( "Form_3" )
      RETURN NIL
   ENDIF

   DEFINE WINDOW Form_3 ;
         AT nRow, nCol ; // 260,192
         WIDTH 492 HEIGHT 280 ;
         TITLE 'Select Channel:' ;
         ICON 'Musicas2' ;
         CHILD ;
         NOSIZE ;
         NOSYSMENU

      @ 190, 0 IMAGE BackGr ;
         PICTURE cSkin ;
         WIDTH 490 ;
         HEIGHT 100

      @ 0, 0 LISTBOX List_1 ;
         WIDTH 490 ;
         HEIGHT 200 ;
         ITEMS aItens ;
         VALUE 1 ;
         FONT "Ms Sans Serif" SIZE 09 ;
         ON DBLCLICK DesdeList2( aOrd )

      @ 228, 36 BUTTON Bt_Close ;
         PICTURE 'Close' ;
         ACTION Form_3.RELEASE ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Close..."

   END WINDOW

   Form_3.ACTIVATE

RETURN NIL
/*
*/
PROCEDURE DesdeList2()

   LOCAL cDos

   cDos := NomeDoArquivo( aOrd[ Form_3.List_1.Value ] )
   cDos := StrTran( cDos, Chr( 13 ), "" )

   ParaPlay()

   IF Upper( Right( cDos, 3 ) ) == "MP3"
      // cFileMP3 := '"' + cDirMP3 + '"'
      // EXECUTE FILE "wmplayer.exe" PARAMETERS "/prefetch:1 "+cFileMP3
      EXECUTE FILE "vlc.exe" PARAMETERS '"' + cDos + '"'
   ELSE
      cDos := aOrd[ Form_3.List_1.Value ]
      cDos := StrTran( cDos, Chr( 13 ), "" )
      // EXECUTE FILE "wmplayer.exe" PARAMETERS cDos
      EXECUTE FILE "vlc.exe" PARAMETERS '"' + cDos + '"'
   ENDIF

RETURN
/*
*/
PROCEDURE ParaPlay()
   IF Form_Player.Play_1.Position > 0
      Form_Player.Img_Leds1.PICTURE := "Led1Off"
      ResetCount()
      Form_Player.Play_1.Stop
      SET PLAYER Play_1 OF Form_Player POSITION HOME
      Form_Player.Slider_2.VALUE := 0
      Form_Player.Slider_2.Redraw()
      lPlayPause := .F.
   ENDIF

RETURN
/*
*/
PROCEDURE ResetCount()
   Form_Player.LbTempoReproducao.VALUE := '00:00'
   Form_Player.LbTempoTotal.VALUE := '00:00'
   Form_Player.LbMusicaAtual.VALUE := '0/0'

RETURN
/*
*/
PROCEDURE NovaPastaDeMusicas()

   LOCAL cFolder := GetFolder( NIL, cDirMusicas )
   LOCAL cOldDir := cDirMusicas

   If ! Empty( cFolder )
      BEGIN INI FILE cDirExe + "MyPlayer.ini"
         SET SECTION "SONGS" ENTRY "Music Folder" TO AllTrim( cFolder ) + "\"
      END INI
   ENDIF

   cDirMusicas := PastaAtualDeMusicas()

   IF Empty( cDirMusicas ) .OR. cDirMusicas == cOldDir
      RETURN
   ENDIF

   MusicasDisponiveis()

   IF IsMP3()

      IF Len( aMusicas ) > 0
         ExecutarMusica( cDirMusicas + aMusicas[ 1 ] )
      ENDIF

   ENDIF

   Form_2.RELEASE
   DoEvents()
   AchoiceMusicas()

RETURN
/*
 * Cria o Arquivo MyPlayer.INI
 */
FUNCTION Cria_Ini_File()
   IF Empty( cDirExe )
      cDirExe := GetStartupFolder() + "\"
   ENDIF
   If ! File( cDirExe + "MyPlayer.INI" )
      BEGIN INI FILE cDirExe + "MyPlayer.ini"
         SET SECTION "SONGS" ENTRY "Music Folder" TO cDirExe + "Songs\"
         SET SECTION "PREFERENCES" ENTRY "Play Continuously" TO "YES"
         SET SECTION "PREFERENCES" ENTRY "Songs That Contain the Word" TO ""
         SET SECTION "PREFERENCES" ENTRY "Raffle Songs" TO "NO"
         SET SECTION "PREFERENCES" ENTRY "Skin" TO "MyPlayer.Gif"
      END INI
   ENDIF

RETURN NIL
/*
 *   Ao Sair do Programa Passa por esta Rotina:
 * - Elimina o Controle Player
 * - Atualiza variáveis no Arquivo Player.INI
 */
PROCEDURE PlayerSaidaDoPrograma()
   IF IsControlDefined( Player, Form_Player )
      Form_Player.Play_1.Stop
      Form_Player.Play_1.RELEASE
   ENDIF
   // ** Atualiza Arquivo MyPlayer.INI
   BEGIN INI FILE cDirExe + "MyPlayer.ini"
      SET SECTION "SONGS" ENTRY "Music Folder" TO cDirMusicas
      SET SECTION "PREFERENCES" ENTRY "Play Continuously" TO iif( lContinua, "YES", "NO" )
      SET SECTION "PREFERENCES" ENTRY "Raffle Songs" TO iif( lSorteia, "YES", "NO" )
      SET SECTION "PREFERENCES" ENTRY "Skin" TO cSkin
   END INI

RETURN
/*
 * Lee Arquivo MyPlayer.Ini e Retorna a Pasta de Musicas
 */
FUNCTION PastaAtualdeMusicas()

   LOCAL cValue := ""
   BEGIN INI FILE cDirExe + "MyPlayer.ini"
      GET cValue SECTION "SONGS" ENTRY "Music Folder"
   END INI

RETURN Upper( cValue )
/*
 * Lee Arquivo MyPlayer.Ini e Retorna Palavras Selecionadas
 * as palavras devem estar separadas com ";" Ponto e Vírgula
 * Exemplo: Viver;Elvis Plesley;Beatles;coração
 */
FUNCTION Palavras()

   LOCAL aValue := {}
   LOCAL cValue

   BEGIN INI FILE cDirExe + "MyPlayer.ini"
      GET cValue SECTION "PREFERENCES" ENTRY "Songs That Contain the Word"
   END INI

   IF ! Empty( cVAlue )
      aValue := hb_ATokens ( Trim( Upper( cValue ) ), ";" )
      AEval( aValue, {| x, y | aValue[ y ] := Upper( x ) } )
   ENDIF

RETURN aValue
/*
 * Lee Arquivo MyPlayer.Ini e Retorna .T. se o Programa vai Sortear Musicas para a execução
 */
FUNCTION SorteiaMusicas()

   LOCAL cvalue := ""

   BEGIN INI FILE cDirExe + "MyPlayer.ini"
      GET cValue SECTION "PREFERENCES" ENTRY "Raffle Songs"
   END INI

RETURN ( iif( AllTrim( cValue ) == "YES", .T., .F. ) )
/*
 * Lee Arquivo MyPlayer.Ini e Retorna .T. se o Programa vai Reproduzir Musicas continuamente
 */
FUNCTION ReproduzirContinuamente()

   LOCAL cvalue := ""
   BEGIN INI FILE cDirExe + "MyPlayer.ini"
      GET cValue SECTION "PREFERENCES" ENTRY "Play Continuously"
   END INI

RETURN ( iif( AllTrim( cValue ) == "YES", .T., .F. ) )
/*
 * Lee Arquivo MyPlayer.Ini e Retorna imagem para Skin
 */
FUNCTION Skins()

   LOCAL cvalue := ""
   BEGIN INI FILE cDirExe + "MyPlayer.ini"
      GET cValue SECTION "PREFERENCES" ENTRY "Skin"
   END INI

RETURN ( AllTrim( cValue ) )
/*
*/
FUNCTION ListAsArray( cList, cDelimiter )

   LOCAL nPos
   LOCAL aList := {}
   If ! Empty( cList )
      DO WHILE ( nPos := At( cDelimiter, cList ) ) != 0
         AAdd( aList, SubStr( cList, 1, nPos - 1 ) )
         cList := SubStr( cList, nPos + 1 )
      ENDDO
      AAdd( aList, cList )
   ENDIF

RETURN ( aList )
/*
*/
FUNCTION TempoTotal( nTam )

   LOCAL cRet := AllTrim( Str( Int( ( nTam / 60 ) / 1000 ) ) ) + ":" + AllTrim( Str( Int( ((( nTam / 60 ) / 1000 ) - Int( ( nTam / 60 ) / 1000 ) ) * 60 ) ) )
   IF Int( Val( cRet ) ) < 10
      cRet := "0" + cRet
   ENDIF
   IF Left( Right( cRet, 2 ), 1 ) == ":"
      cRet := cRet + "0"
   ENDIF

RETURN cRet
/*
*/
FUNCTION NomeDoArquivo( cArq )
   IF Upper( Right( cArq, 3 ) ) = "MP3"
      cArq := Right( cArq, Len( cArq ) - ( RAt( "\", cArq ) ) )
      cArq := StrTran( cArq, ".MP3", "" )
      cArq := StrTran( cArq, ".mp3", "" )
   ELSEIF Upper( Right( cArq, 3 ) ) = "M3U"
      cArq := Right( cArq, Len( cArq ) - ( RAt( "\", cArq ) ) )
      cArq := StrTran( cArq, ".M3U", "" )
      cArq := StrTran( cArq, ".m3u", "" )
   ELSEIF Upper( Right( cArq, 4 ) ) = "M3U8"
      cArq := Right( cArq, Len( cArq ) - ( RAt( "\", cArq ) ) )
      cArq := StrTran( cArq, ".M3U8", "" )
      cArq := StrTran( cArq, ".m3u8", "" )
   ENDIF

RETURN ( cArq )
/*
    Para Este efeito o Label deve ser declarado como CenterAlign
*/
PROCEDURE EfeitoLabel2()

   LOCAL cTxt := AllTrim( cNomeMusicaAtual )
   LOCAL nTam := Len( cTxt )
   nCtEfeito += 1
   IF nCtEfeito > nTam
      IF nCtEfeito > 50
         nCtEfeito := 0
         cDescEfeito := ""
      ENDIF
   ELSE
      cDescEfeito += SubStr( cTxt, nCtEfeito, 1 )
   ENDIF
   Form_Player.TITLE := cDescEfeito

RETURN
/*
*/
PROCEDURE Efeito_Abertura()

   LOCAL cTxt
   LOCAL nTam
   LOCAL aMensag := { "MyPlayer - Version 1.1", ;
      "By Humberto Fornazier/Brasil", ;
      "http://www.geocities.ws/harbourminas/ ", ;
      "Harbour - Harbour Project", ;
      "https://harbour.github.io/", ;
      "HMG - Roberto Lopez - Argentina", ;
      "http://harbourminigui.blogspot.com" }

   cTxt := aMensag[ nCt ]
   nTam := Len( cTxt )

   nCtEfeito += 1

   IF nCtEfeito > nTam
      nCtEfeito := 0
      cDescEfeito := ""
      nCt++
      nCt := iif( nCt > 7, 1, nCt )
   ELSE
      cDescEfeito += SubStr( cTxt, nCtEfeito, 1 )
   ENDIF

   Form_Player.TITLE := cDescEfeito

RETURN
/*
*/
PROCEDURE Bt_Salvar_Execute()

   LOCAL cPalavras := AllTrim( Form_Config.Palavras.Value )
   BEGIN INI FILE cDirExe + "MyPlayer.ini"
      SET SECTION "PREFERENCES" ENTRY "Play Continuously" TO iif( Form_Config.Reproduzir.VALUE, "YES", "NO" )
      SET SECTION "PREFERENCES" ENTRY "Songs That Contain the Word" TO cPalavras
      SET SECTION "PREFERENCES" ENTRY "Raffle Songs" TO iif( Form_Config.Sortear.VALUE, "YES", "NO" )
   END INI
   lContinua := Form_Config.Reproduzir.VALUE
   lSorteia := Form_Config.Sortear.VALUE
   Form_Config.RELEASE

   IF IsWindowDefined( "Form_2" ) // add By Pierpaolo Martinello  for relist the new songs added to folder
      MusicasDisponiveis()
      Form_2.List_1.deleteallitems
      AEval( aMusicas, {| x | Form_2.List_1.additem( x ) } )
   ENDIF

RETURN
// ------------------------------------------------------------*
FUNCTION m3u2Arr ( cFileM3U )
// ------------------------------------------------------------*
   LOCAL cMemo, n, nMax, nPosi, nPos2, cLine, oError
   LOCAL aOne := {}, aLines
   LOCAL cTVname, cTVlogo, cTVgroup, cTVurl
   LOCAL lDone

   BEGIN SEQUENCE WITH {| oError | Break( oError ) }

      cMemo := hb_MemoRead( cFileM3U )
      cMemo := StrTran( cMemo, Chr( 10 ), Chr( 13 ) + Chr( 10 ) )
      aLines := hb_ATokens( cMemo, Chr( 10 ) )
      nMax := Len( aLines )

      FOR n := 1 TO nMax

         cLine := MemoLine( cMemo, 15000, n, 2, .T. )

         IF Empty( cLine ) .OR. "#EXTM3U" $ Upper( cLine )
            LOOP
         ENDIF

         IF "#EXTINF" $ Upper( cLine )

            cTVname := ""
            cTVlogo := ""
            cTVgroup := ""
            cTVurl := ""
            lDone := .F.

            DO WHILE lDone = .F.

               IF At( "tvg-logo=", cLine ) > 0
                  nPosi := At( "tvg-logo=", cLine )
                  IF nPosi > 0
                     cTVlogo := SubStr( cLine, nPosi + 10 )
                     nPos2 := ATI( '"', cTVlogo )
                     cTVlogo := Left( SubStr( cTVlogo, 1, nPos2 - 1 ), 300 )
                  ENDIF
               ENDIF

               IF At( "group-title=", cLine ) > 0
                  nPosi := At( "group-title=", cLine )
                  IF nPosi > 0
                     cTVgroup := SubStr( cLine, nPosi + 13 )
                     nPos2 := ATI( '"', cTVgroup )
                     cTVgroup := Left( SubStr( cTVgroup, 1, nPos2 - 1 ), 80 )
                  ENDIF
               ENDIF

               IF At( ',', cLine ) > 0
                  nPosi := At( ',', cLine )
                  IF nPosi > 0
                     cTVname := SubStr( cLine, nPosi + 1 )
                     nPos2 := ATI( ',', cTVname )
                     IF nPos2 > 0
                        cTVname := SubStr( cTVname, nPos2 + 1 )
                     ENDIF
                  ENDIF
               ENDIF

               lDone := .T.

            ENDDO

         ELSEIF "HTTP" $ Upper( cLine ) .OR. "PLUGIN://" $ Upper( cLine ) .OR. ":\" $ Upper( cLine )

            IF At( "http://", cLine ) > 0
               nPosi := At( "http://", cLine )
               IF nPosi > 0
                  cTVurl := Left( SubStr( cLine, nPosi ), 500 )
               ENDIF
            ENDIF

            IF Empty( cTVurl )

               IF At( "https://", cLine ) > 0
                  nPosi := At( "https://", cLine )
                  IF nPosi > 0
                     cTVurl := Left( SubStr( cLine, nPosi ), 500 )
                  ENDIF
               ENDIF

            ENDIF

            IF At( "plugin://", cLine ) > 0
               nPosi := At( "plugin://", cLine )
               IF nPosi > 0
                  cTVurl := Left( SubStr( cLine, nPosi ), 500 )
               ENDIF
            ENDIF

            IF At( ":\", cLine ) > 0
               nPosi := At( ":\", cLine )
               IF nPosi > 0
                  cTVurl := Left( SubStr( cLine, nPosi - 1 ), 500 )
               ENDIF
            ENDIF

            AAdd( aOne, { AllTrim( cTVlogo ), AllTrim( cTVgroup ), AllTrim( cTVname ), AllTrim( cTVurl ) } )

         ENDIF

         DO EVENTS

      NEXT

   RECOVER USING oError

      AutoMsgInfo( oError:Operation + CRLF + oError:Description, "Error !!!" )

   END

RETURN( aOne )

// ---------------------------------------------------------------------*
PROCEDURE Definiciones_One()
// ---------------------------------------------------------------------*
   LOCAL nCol := 10, nColp := ( GetDeskTopWidth() + 8 ) / 2

   DEFINE WINDOW Form_Player ;
         AT 100, nColp - 160 - 80 ;
         WIDTH 492 ;
         HEIGHT 160 ;
         TITLE 'MyPlayer - Status' ;
         ICON "MUSICAS2" ;
         MAIN ;
         NOSIZE ;
         NOMAXIMIZE ;
         TOPMOST ;
         ON MOVE DragFormS() ;
         ON RELEASE PlayerSaidaDoPrograma()

      @ 0, 0 IMAGE ImageBackGr ;
         PICTURE cSkin ;
         WIDTH 486 HEIGHT 131 STRETCH

      @ 000, 008 FRAME Frame1 ;
         CAPTION '' ;
         WIDTH 470 ;
         HEIGHT 49

      @ 050, 008 FRAME Frame2 ;
         CAPTION '' ;
         WIDTH 470 ;
         HEIGHT 39

      @ 019, 012 LABEL LbMusicaAtual2 ;
         WIDTH 45 ;
         HEIGHT 20 ;
         VALUE 'Song: ' ;
         FONT 'MS Sans Serif' SIZE 12 ;
         FONTCOLOR WHITE TRANSPARENT

      @ 018, 060 LABEL LbMusicaAtual ;
         WIDTH 80 ;
         HEIGHT 20 ;
         VALUE '0/0' ;
         FONT 'MS Sans Serif' SIZE 14 ;
         FONTCOLOR WHITE TRANSPARENT BOLD

      @ 064, 013 LABEL LbReproduzindo ;
         WIDTH 98 ;
         HEIGHT 16 ;
         VALUE 'Countdown: ' ;
         FONT 'MS Sans Serif' SIZE 10 ;
         FONTCOLOR WHITE TRANSPARENT

      @ 060, 105 LABEL LbTempoReproducao ;
         WIDTH 50 ;
         HEIGHT 24 ;
         VALUE '00:00' ;
         FONT 'MS Sans Serif' SIZE 14 BOLD ;
         FONTCOLOR WHITE TRANSPARENT

      @ 064, 205 LABEL LbClockTermino ;
         WIDTH 80 ;
         HEIGHT 16 ;
         VALUE 'Clock 00:00' ;
         FONT 'MS Sans Serif' SIZE 10 ;
         FONTCOLOR WHITE TRANSPARENT

      @ 063, 320 LABEL LbTotal ;
         WIDTH 90 ;
         HEIGHT 16 ;
         VALUE 'Total Time:' ;
         FONT 'MS Sans Serif' SIZE 10 ;
         FONTCOLOR WHITE TRANSPARENT

      @ 059, 411 LABEL LbTempoTotal ;
         WIDTH 50 ;
         HEIGHT 24 ;
         VALUE '00:00' ;
         FONT 'MS Sans Serif' SIZE 14 BOLD ;
         FONTCOLOR WHITE TRANSPARENT

      @ 096, nCol BUTTON Bt_Stop ;
         PICTURE 'Stop' ;
         ACTION PararReproducao() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Stop..."

      @ 096, nCol += 26 BUTTON Bt_Play ;
         PICTURE 'Play' ;
         ACTION MyPlay() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Play..."

      @ 096, nCol += 26 BUTTON Bt_Pause ;
         PICTURE 'Pause' ;
         ACTION MyPause() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Pause..."

      @ 096, nCol += 26 BUTTON Bt_Next ;
         PICTURE 'Next' ;
         ACTION MPProximaMusica() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Next..."

      @ 096, nCol += 26 BUTTON Bt_Back ;
         PICTURE 'Back' ;
         ACTION MPMusicaAnterior() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Back..."

      @ 096, nCol += 26 BUTTON Bt_Home ;
         PICTURE 'Home' ;
         ACTION MPMUsicaInicio() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Home..."

      @ 096, nCol += 26 BUTTON Bt_Last ;
         PICTURE 'Last' ;
         ACTION MPMUsicaFinal() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Last..."

      nCol := 322

      @ 096, nCol BUTTON Bt_Folder ;
         PICTURE 'Folder' ;
         ACTION AchoiceMusicas() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Select Folder/File: "

      @ 096, nCol += 26 BUTTON Bt_Clock ;
         PICTURE 'Clock' ;
         ACTION MPAlarme() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Turn Off Player"

      @ 096, nCol += 26 BUTTON Bt_Skins ;
         PICTURE 'Preview' ;
         ACTION SkinsDisponiveis() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Change Skin"

      @ 096, nCol += 26 BUTTON Bt_Config ;
         PICTURE 'Config' ;
         ACTION Config() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Config"

      @ 096, nCol += 26 BUTTON Bt_Close ;
         PICTURE 'Close' ;
         ACTION Form_Player.RELEASE ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "Close Player"

      @ 096, nCol += 26 BUTTON Bt_Info ;
         PICTURE 'Info' ;
         ACTION MsgSobre() ;
         WIDTH 22 ;
         HEIGHT 22 ;
         FLAT ;
         TOOLTIP "About..."

      @ 095, 205 SLIDER Slider_1 ;
         RANGE 0, 10 ;
         WIDTH 100 ;
         HEIGHT 24 ;
         VALUE 5 ;
         ON CHANGE Slider1_Change()

      @ 017, 150 SLIDER Slider_2 ;
         RANGE 0, 100 ;
         WIDTH 320 ;
         HEIGHT 24 ;
         VALUE 0 ;
         NOTICKS ;
         ON CHANGE Slider2_Change()

      @ 50, 460 IMAGE Img_Leds1 ;
         PICTURE "Led1off" ;
         WIDTH 14 HEIGHT 7 ;
         ACTION PararReproducao()

      @ 00, 02 PLAYER Play_1 ;
         WIDTH 05 ;
         HEIGHT 05 FILE "" ;
         NOMENU NOOPEN ;
         SHOWPOSITION

      DEFINE TIMER Timer_Abertura INTERVAL 100 ACTION Efeito_Abertura() OF Form_Player

   END WINDOW

#ifdef _DEBUG_
   ON KEY F3 OF Form_Player ACTION AutoMsgInfo( hb_ValToExp( M3u2Arr( "t2.m3u" ) ) )
   ON KEY F4 OF Form_Player ACTION AutoMsgInfo( hb_ValToExp( aMusicas ) )
   ON KEY F5 OF Form_Player ACTION AutoMsgInfo( hb_ValToExp( aMusicas[ 1 ] ) )

   ON KEY F6 OF Form_Player ACTION AutoMsgInfo( cDirMusicas + aMusicas[ 1 ] )
   ON KEY F7 OF Form_Player ACTION AutoMsgInfo( Right( cDirMusicas + aMusicas[ 1 ], 3 ) )
   ON KEY F8 OF Form_Player ACTION AutoMsgInfo( hb_ValToExp( aOrd ) )

#endif
   Form_Player.LbMusicaAtual.SetFocus
   Form_Player.ACTIVATE

RETURN
/*
*/
// ---------------------------------------------------------------------*
PROCEDURE DragFormS() // Pierpaolo Martinello
// ---------------------------------------------------------------------*
   LOCAL nRow := App.HEIGHT + App.ROW + GetBorderHeight()
   LOCAL nCol := App.COL

   IF isWindowDefined( "Form_2" )
      Form_2.ROW := nRow
      Form_2.COL := nCol
   ENDIF

   IF isWindowDefined( "Form_3" )
      Form_3.ROW := nRow
      Form_3.COL := nCol
   ENDIF

RETURN

/*
 * Clock - Habilita Minutos para desligar o Player Automaticamente
 */
PROCEDURE MPAlarme()

   LOCAL nRow := App.HEIGHT + App.ROW + GetBorderHeight()
   LOCAL nCol := App.COL

   DEFINE WINDOW Form_Alarme ;
         AT nRow, nCol + 138 ; // 260,330
         WIDTH 217 ;
         HEIGHT 99 ;
         TITLE 'Turn Off MyPlayer' ;
         ICON "Musicas2" ;
         MODAL ;
         NOSIZE

      @ -10, -10 IMAGE ImageBackGr ;
         PICTURE cSkin ;
         WIDTH 320 HEIGHT 100

      @ 0, 0 FRAME GroupBox1 ;
         CAPTION '' ;
         WIDTH 208 ;
         HEIGHT 41

      @ 15, 11 LABEL Label1 ;
         WIDTH 73 ;
         HEIGHT 16 ;
         VALUE 'Turn Off in' ;
         FONT 'MS Sans Serif' SIZE 10 ;
         FONTCOLOR WHITE Transparent

      @ 15, 147 LABEL Label2 ;
         WIDTH 46 ;
         HEIGHT 16 ;
         VALUE 'minutes' ;
         FONT 'MS Sans Serif' SIZE 10 ;
         FONTCOLOR WHITE Transparent

      @ 13, 92 TEXTBOX TxtMinutos ;
         WIDTH 49 ;
         VALUE '00:00' ;
         INPUTMASK "99:99"

      @ 48, 8 BUTTON BtOk ;
         CAPTION '&Ok' ;
         Action ( lDesliga := .T., Form_Player.LbClockTermino.Visible := .T., ;
         cDesligarEm := Time(), cMinutos := AllTrim( Form_Alarme.TxtMinutos.Value ), ;
         Form_Alarme.Release ) ;
         WIDTH 75 ;
         HEIGHT 21

      @ 48, 128 BUTTON BtCancela ;
         CAPTION '&Cancel' ;
         ACTION Form_Alarme.RELEASE ;
         WIDTH 75 ;
         HEIGHT 21

   END WINDOW

   Form_Alarme.ACTIVATE

RETURN
/*
*/
STATIC FUNCTION MsgSobre()
#define NPAD 38
   MsgInfo( PadC( "    " + PROGRAM + " " + VERSION, NPAD ) + CRLF + ;
      PadC( " Copyright " + Chr( 169 ) + COPYRIGHT, NPAD ) + CRLF + ;
      PadC( "  " + AUTOR, NPAD ) + CRLF + ;
      PadC( "hfornazier@yahoo.com.br", NPAD ) + CRLF + CRLF + ;
      PadC( "* This program is FreeWare *", NPAD ) + CRLF + CRLF + ;
      PadC( "   Compiler and Libs", NPAD ) + CRLF + CRLF + ;
      PadC( AllTrim( hb_Compiler() ), NPAD ) + CRLF + ;
      PadC( AllTrim( Version() ), NPAD ) + CRLF + ;
      PadC( "https://harbour.github.io/", NPAD ) + CRLF + CRLF + ;
      Left( MiniGuiVersion(), NPAD ) + CRLF + ;
      PadC( "", NPAD ) + CRLF + ;
      PadC( " Rewritted by MigSoft 2022 ", NPAD ), ;
      "About MyPlayer" )

RETURN NIL
/*
*/
PROCEDURE SkinsDisponiveis()

   LOCAL aFiles := Directory( cDirExe + "Skins\*.Gif" )
   LOCAL aItens := {}, i
   LOCAL nCol := iif( App.COL - 105 >= 0, App.COL - 105 - GetBorderWidth(), App.COL + App.WIDTH + GetBorderWidth() )

   FOR i := 1 TO Len( aFiles )
      AAdd( aItens, AllTrim( aFiles[ i ][ 1 ] ) )
   NEXT

   IF Len( aItens ) == 0
      MsgInfo( "No Skins Available!!" )
      RETURN
   ENDIF

   ASort( aItens )

   DEFINE WINDOW Form_Skins ;
         AT App.ROW, nCol ; // 100,88
         WIDTH 105 ;
         HEIGHT 300 ;
         TITLE 'Skins...' ;
         ICON "MUSICAS2" ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU

      @ 246, 0 IMAGE BackGr ;
         PICTURE cSkin ;
         WIDTH 285 HEIGHT 80

      @ 0, 0 LISTBOX List_1 ;
         WIDTH 100 ;
         HEIGHT 245 ;
         ITEMS aItens ;
         VALUE 1 ;
         FONT "Ms Sans Serif" SIZE 09 ;
         ON CHANGE PreviewSkin( aItens[ Form_Skins.List_1.Value ] )

      @ 250, 05 BUTTON Bt_Close ;
         PICTURE 'Close' ;
         ACTION Form_Skins.RELEASE ;
         WIDTH 22 ;
         HEIGHT 22 FLAT TOOLTIP "Close"

   END WINDOW

   Form_Skins.ACTIVATE

RETURN
/*
*/
PROCEDURE PreviewSkin( xSkin )
   cSkin := cDirExe + "Skins\" + xSkin
   Form_Player.ImageBackGr.PICTURE := cSkin
   InvalidateRect( App.Handle, 1 )

RETURN
/*
*/
PROCEDURE Config()

   LOCAL cValue := ""
   LOCAL nRow := App.HEIGHT + App.ROW + GetBorderHeight()
   LOCAL nCol := App.COL

   BEGIN INI FILE cDirExe + "MyPlayer.ini"
      GET cValue SECTION "PREFERENCES" ENTRY "Songs That Contain the Word"
   END INI

   DEFINE WINDOW Form_Config ;
         AT nRow, nCol ; // 260,192
         WIDTH 491 ;
         HEIGHT 153 ;
         TITLE 'Player - Config' ;
         ICON "Musicas2" ;
         MODAL ;
         NOSIZE ;
         FONT 'MS Sans Serif' SIZE 8

      @ 0, 0 IMAGE ImageBackGr ;
         PICTURE cSkin ;
         WIDTH 486 HEIGHT 131 STRETCH

      @ 3, 3 FRAME GroupBox1 ;
         CAPTION ' Preferences ' ;
         WIDTH 190 ;
         HEIGHT 89 ;
         FONTCOLOR WHITE BACKCOLOR BLACK

      @ 25, 16 CHECKBOX Reproduzir ;
         CAPTION 'Play Continuously' ;
         WIDTH 148 ;
         HEIGHT 17 ;
         FONTCOLOR BLACK

      @ 42, 16 CHECKBOX Sortear ;
         CAPTION 'Raffle Songs ' ;
         WIDTH 148 ;
         HEIGHT 17 ;
         FONTCOLOR BLACK

      @ 3, 196 FRAME GroupBox2 ;
         CAPTION ' Select Songs With These Words ' ;
         WIDTH 283 ;
         HEIGHT 89 ;
         FONTCOLOR WHITE BACKCOLOR BLACK

      @ 16, 203 EDITBOX Palavras ;
         VALUE cValue ;
         WIDTH 266 ;
         HEIGHT 71

      @ 96, 197 BUTTON Bt_Salvar ;
         CAPTION '&Save Config' ;
         ACTION Bt_Salvar_Execute() ;
         WIDTH 131 ;
         HEIGHT 25 FLAT ;
         TOOLTIP "Save - Attention: Words must be separated by semicolons ';' "

      @ 96, 348 BUTTON Bt_Cancela ;
         CAPTION '&Cancel' ;
         ACTION Form_Config.RELEASE ;
         WIDTH 131 ;
         HEIGHT 25 FLAT

   END WINDOW

   Form_Config.Reproduzir.VALUE := lContinua
   Form_Config.Sortear.VALUE := lSorteia

   Form_Config.ACTIVATE

RETURN
