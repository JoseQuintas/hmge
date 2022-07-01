// -------------------------------------------------------------------------
// BUSCAMINAS
// -------------------------------------------------------------------------
// --> (c)by Salinetas24
// --> Autor...: José Manuel Carbonell Bernabé
// --> email...: SargantanaSoft@GMAIL.COM
// -------------------------------------------------------------------------
// Versión de juego de Windows desarrollado bajo HMG
// -------------------------------------------------------------------------

#include "HMG.CH"
#include "i_winuser.ch"

MEMVAR nNivel, nMin, nFil, nCol
MEMVAR nIntentos, nContador
MEMVAR aAlbedrio
MEMVAR nAnchoPantalla
MEMVAR nAltoPantalla
MEMVAR nXImagen
MEMVAR nYImagen

STATIC lFirstClick := .T.

// -------------------------------------------------------------------------
FUNCTION Main()
// -------------------------------------------------------------------------
   LOCAL SYSBG := GetSysColor( COLOR_BTNFACE )

   PRIVATE nNivel := 1, nMin, nFil, nCol
   PRIVATE nIntentos := nContador := 0
   // VARIABLE PARA EL AZAR
   // Array de tresposiciones
   // [1][1] -> Indica si esta disponible el cuadro [.t./.f.}
   // [1][2] -> Contiene el nº de aproximación
   // [1][3] -> Contiene si el cuadro está señalizado [.F./.T.]
   PRIVATE aAlbedrio := Array( 100, 3 ) // Por Defecto
   // DISEÑO DE PANTALLA para diversas resoluciones
   // Calculo la pantalla para el Juego y los datos
   // 3/4 partes para jugar
   // 1/4 parte para  info
   PRIVATE nAnchoPantalla := GetDesktopWidth()
   PRIVATE nAltoPantalla := GetDesktopHeight()
   // PRIVATE nPantallaJuego := Int( ( nAnchoPantalla / 4 ) * 3 )
   // PRIVATE nPantallaResto := nAnchoPantalla - nPantallaJuego
   PRIVATE nXImagen := 32
   PRIVATE nYImagen := 32

   // --------------------------------------------------------------------
   // Presento PANTALLA y la Maximizo
   DEFINE WINDOW PantallaJuego ;
         AT 0, 0 WIDTH nAnchoPantalla HEIGHT nAltoPantalla ;
         BACKCOLOR { 0, 125, 250 } NOCAPTION MAIN

      ON KEY ESCAPE ACTION SALIR()

      @ 15, 025 LABEL LB1 VALUE ' Elije Nivel ..: ' FONT "COURIER NEW" SIZE 18 AUTOSIZE TRANSPARENT BOLD VCENTERALIGN
      @ 15, 270 COMBOBOX CB1 ITEMS { '1 Principiante', '2 Amateur', '3 Profesional' } VALUE 0 ;
         WIDTH 220 FONT "COURIER NEW" SIZE 18 ;
         ON CHANGE ( BorraPantalla(), CambiaDificultad( This.Value ), PantallaPrincipal(), lFirstClick := .T., Reinicio() )

      // Pierpaolo Martinello May 2022
      // Add button for prevent wrong escape malfunction
      DEFINE BUTTONEX BTNEXIT
         ROW 5
         COL nAnchoPantalla - 45
         WIDTH 40
         HEIGHT 18
         CAPTION "X"
         FONTCOLOR GRAY
         BACKCOLOR RED
         FONTBOLD .T.
         ACTION {|| Salir() }
         ONGOTFOCUS ( PantallaJuego.BTNEXIT.GRADIENTFILL := { { 0, { 255, 64, 0 }, { 255, 64, 0 } } }, PantallaJuego.BTNEXIT.FONTCOLOR := WHITE )
         ONLOSTFOCUS ( PantallaJuego.BTNEXIT.GRADIENTFILL := { { 0, SYSBG, SYSBG } }, PantallaJuego.BTNEXIT.FONTCOLOR := GRAY )
      END BUTTONEX

   END WINDOW
   PantallaJuego.MAXIMIZE
   PantallaJuego.ACTIVATE

RETURN NIL

// ----------------------------------------------------------------------
// DEFINE LA VENTANA PARA JUGAR
// ----------------------------------------------------------------------
PROCEDURE PantallaPrincipal

   LOCAL nX, nY, nIni, cVar1

   DECLARE WINDOW PRINCIPAL1
   IF iswindowdefined( PRINCIPAL1 )
      PRINCIPAL1.RELEASE
      DoEvents()
   ENDIF

   DEFINE WINDOW PRINCIPAL1 ;
         AT 55, 0 WIDTH nAnchoPantalla - 5 HEIGHT nAltoPantalla - 55 ;
         BACKCOLOR { 0, 125, 250 } NOCAPTION TOPMOST

      ON KEY ESCAPE ACTION PantallaJuego.RELEASE
      ON KEY F10 ACTION ( lFirstClick := .T., Reinicio() )

      @ 080, 120 LABEL LB1 VALUE StrZero( nMin, 3 ) AUTOSIZE FONT "LCD" SIZE 20 FONTCOLOR RED BACKCOLOR YELLOW
      @ 080, 080 + ( nYImagen * nCol ) LABEL LB2 VALUE StrZero( nIntentos, 4 ) AUTOSIZE FONT "LCD" SIZE 20 FONTCOLOR RED BACKCOLOR YELLOW
      @ 090, 168 LABEL LB3 VALUE "Minas" AUTOSIZE FONT "COURIER NEW" SIZE 14 TRANSPARENT
      @ 090, 080 + ( nYImagen * nCol ) - 95 LABEL LB4 VALUE "Intentos" AUTOSIZE FONT "COURIER NEW" SIZE 14 TRANSPARENT
      // ---------------------------------------------------------------------
      // Ponemos el tablero de Juego
      nIni := 0
      FOR nX = 1 TO nFil
         FOR nY := 1 TO nCol
            nIni++
            cVar1 := "FOTO" + AllTrim( Str( nIni ) )
            @ 100 + ( nXImagen * nX ), 100 + ( nYImagen * nY ) IMAGE &cVar1 ;
               PICTURE "IMG\MINASPP.BMP" WIDTH nXImagen HEIGHT nYImagen ADJUSTIMAGE ;
               ON CLICK Comprueba( This.Index ) ON RCLICK Comprueba2( This.Index )
         NEXT
      NEXT

   END WINDOW
   // ------------------------------------------------------------------------
   // Inicio el procedimiento de Generacion de Albedrio, la primera vez envio
   // el parametro 1 para que no redibuje la pantalla de cuadros
   Reinicio( 1 )
   PRINCIPAL1.ACTIVATE

RETURN

// ----------------------------------------------------------------------
// Borra la pantalla del juego, se ha elegido otro nivel
// ----------------------------------------------------------------------
PROCEDURE BorraPantalla()

   IF IsWindowDefined( "PRINCIPAL1" )
      DoMethod( "PRINCIPAL1", "RELEASE" )
   ENDIF

RETURN

// ----------------------------------------------------------------------
// Cambia la dificultad del Juego y carga los correspondientes parametros
// ----------------------------------------------------------------------
PROCEDURE CambiaDificultad( nValor )

   nNivel := nValor
   DO CASE
   CASE nNivel = 1
      nFil := 10
      nCol := 10
      nMin := 10
   CASE nNivel = 2
      nFil := 17
      nCol := 17
      nMin := 40
   CASE nNivel = 3
      nFil := 17
      ncol := 30
      nMin := 100
   ENDCASE

RETURN

// ----------------------------------------------------------------------------
// COMPRUEBA LA PULSACION DEL RATÓN para MOSTRAR EL CUADRO
// ----------------------------------------------------------------------------
FUNCTION Comprueba( i )

   LOCAL cCadena
   LOCAL nOpc, nPos, cFoto
   LOCAL nFinal := 0

   nIntentos++
   SetProperty ( "Principal1", "LB2", "VALUE", StrZero( nIntentos, 4 ) )
   nPos := Val( SubStr( _HMG_aControlNames[ i ], 5 ) )
   // Cargo control de pantalla
   cCadena := "FOTO" + AllTrim( Str( nPos ) )
   // Ahora compruebo si la puedo pulsar
   IF aAlbedrio[ nPos ][ 1 ] .AND. ! aAlbedrio[ nPos ][ 3 ]
      IF lFirstClick .AND. aAlbedrio[ nPos ][ 2 ] == 10
         Reinicio()
      ENDIF
      lFirstClick := .F.
      // He Pulsado Boton Izquierdo - DESTAPO
      aAlbedrio[ nPos ][ 1 ] := .F.
      // Cargo tipo de dibujo
      nOpc := StrZero( aAlbedrio[ nPos ][ 2 ], 2 )
      cFoto := "IMG\MINAS" + nOpc + ".BMP"
      // Le doy la vuelta
      SetProperty( "Principal1", cCadena, "Picture", cFoto )
      IF nOpc == "10"
         nFinal := 1
      ENDIF
      // Ahora empieza el vaciado
      IF nFinal == 0
         IF nOpc == "00"
            VaciadoPantalla( nPos )
         ENDIF
         IF VaciadoPartida()
            nFinal := 2
         ENDIF
      ENDIF
      HMG_SysWait()
   ENDIF
   IF nFinal == 1
      FinalPartida()
   ELSEIF nFinal == 2
      FinalPartida2()
   ENDIF

RETURN NIL


FUNCTION Comprueba2( i )

   LOCAL cCadena
   LOCAL nPos, cFoto

   nIntentos++
   SetProperty ( "Principal1", "LB2", "VALUE", StrZero( nIntentos, 4 ) )
   nPos := Val( SubStr( _HMG_aControlNames[ i ], 5 ) )
   // Cargo control de pantalla
   cCadena := "FOTO" + AllTrim( Str( nPos ) )
   // Ahora compruebo si la puedo pulsar
   IF aAlbedrio[ nPos ][ 1 ]
      // He Pulsado Boton Derecho - SEÑALLIZACION  MINAS
      cFoto := "IMG\MINASPP.BMP"
      IF aAlbedrio[ nPos ][ 3 ] // Si es cierto, está señalizado.., desmarco
         aAlbedrio[ nPos ][ 3 ] := .F.
         nContador++
      ELSE
         IF nContador < 0
            PlayBeep()
         ELSE
            nContador--
            aAlbedrio[ nPos ][ 3 ] := .T.
            cFoto := "IMG\MINASMC.BMP"
         ENDIF
      ENDIF
      SetProperty ( "Principal1", cCadena, "Picture", cFoto )
      SetProperty ( "Principal1", "LB1", "VALUE", StrZero( nContador, 3 ) )
      HMG_SysWait()
      IF VaciadoPartida()
         FinalPartida2()
      ENDIF
   ENDIF

RETURN NIL

// --------------------------------------------------------------------------
// Reiniciliza el Juego si se pulsa [ F10 ]
// --------------------------------------------------------------------------
FUNCTION Reinicio( nVa )

   IF IsWindowDefined( "PRINCIPAL1" )
      DEFAULT nVa := 0

      // Inicializo Variables
      nContador := nMin
      SetProperty ( "Principal1", "LB1", "VALUE", StrZero( nContador, 3 ) )
      nIntentos := 0
      SetProperty ( "Principal1", "LB2", "VALUE", StrZero( nIntentos, 4 ) )

      // Inicio el Albedrio
      _Albedrio( nVA )
   ELSE
      SALIR()
   ENDIF

RETURN NIL

// -----------------------------------------------------------------------------
// Esta función Genera de forma aleatoria una secuencia de x Numeros
// -----------------------------------------------------------------------------
FUNCTION _Albedrio( nVa )
   // Modificación para cargar los dibujos ALEATORIAMENTE
   LOCAL nFor, nPos, nNUm, lOk, nMax, nVez, cVarp1

   nMax := nFil * nCol
   // Inicializo el Array y Pantalla
   aAlbedrio := Array( nMax, 3 )
   FOR nFor = 1 TO nMax
      aAlbedrio[ nFor ][ 1 ] := .T.
      aAlbedrio[ nFor ][ 2 ] := 0
      aAlbedrio[ nFor ][ 3 ] := .F.
      IF nVA == 0
         cVarp1 := "FOTO" + AllTrim( Str( nFor ) )
         SetProperty( "PRINCIPAL1", cVarp1, "PICTURE", "IMG\MINASPP.BMP" )
      ENDIF
   NEXT

   // Genero una posición de las minas aleatoria
   FOR nFor = 1 TO nMin
      // Mientras no encuentre un cuadro vacio, y tienen que ser dos
      lOk := .T.
      DO WHILE lOk
         nNum := Int( hb_Random( 1, nMax ) )
         // Veo si el cuadro está libre
         IF aAlbedrio[ nNum ][ 2 ] == 0
            aAlbedrio[ nNum ][ 2 ] := 10 // Cargo la mina con valor 10
            lOk := .F.
         ENDIF
      ENDDO
   NEXT

   // Ahora tengo que calcular la aproximaciºn.
   FOR nNum = 1 TO nMax
      // Localizo la Mina
      IF aAlbedrio[ nNum ][ 2 ] == 10
         // Empiezo a sumar Valores
         // FILA SUPERIOR
         nPos := nNum - ( nCol + 1 ) // 11
         FOR nVez = 1 TO 3
            IF nPos / nCol == Int( nPos / nCol ) .AND. nVez == 1 // Me he subido de fila
               nVez++
               nPos++
            ENDIF
            IF nPos > 1 .AND. aAlbedrio[ nPos ][ 2 ] != 10
               aAlbedrio[ nPos ][ 2 ] ++
            ENDIF
            IF nPos / nCol == Int( nPos / nCol ) .AND. nVez == 2 // Me Salgo de la fila
               EXIT
            ENDIF
            nPos++
         NEXT
         // LATERAL IZQUIERDO
         nPos := nNum - 1
         IF nPos > 1 .AND. Int( nPos / nCol ) != nPos / nCol .AND. aAlbedrio[ nPos ][ 2 ] != 10
            aAlbedrio[ nPos ][ 2 ] ++
         ENDIF
         // LATERAL DERECHO
         nPos := nNum + 1
         IF nPos <= nMax .AND. Int( nNum / nCol ) != nNum / nCol .AND. aAlbedrio[ nPos ][ 2 ] != 10
            aAlbedrio[ nPos ][ 2 ] ++
         ENDIF
         // FILA INFERIOR
         nPos := nNum + ( nCol - 1 ) // 9
         FOR nVez = 1 TO 3
            // El principio de la linea Inferior
            IF nPos / nCol == Int( nPos / nCol ) .AND. nVez == 1
               nVez++
               nPos++
            ENDIF
            IF nPos <= nMax .AND. aAlbedrio[ nPos ][ 2 ] != 10
               aAlbedrio[ nPos ][ 2 ] ++
            ENDIF
            nPos++
            // Final Linea Inferior
            IF nNum / nCol == Int( nNum / nCol ) .AND. nVez == 2
               EXIT
            ENDIF

         NEXT
      ENDIF
   NEXT

/*
 // Comprobacion de la carga
 nNum:=0
 cCadena:=""
 FOR nX=1 TO nFil
  FOR nY:=1 TO nCol
   nNum++
   cCadena:=cCadena+STRZERO(nNUm,3)+"-"+ALLTRIM(str(aAlbedrio[nNum][2]))+":"
  NEXT
  cCadena:=cCadena+CRLF+CRLF
 NEXT
 MSGBOX(cCadena)
*/

RETURN NIL

// --------------------------------------------------------------------------------
// Limpia zona libre de nuestra pulsaciºn
// --------------------------------------------------------------------------------
FUNCTION VaciadoPantalla( nPosicion )

   LOCAL aSitua := {}
   LOCAL nNum, nPos, nOpc, nVez
   LOCAL nMax := nFil * nCol

   AAdd( aSitua, nPosicion )
   DO WHILE Len( aSitua ) > 0
      nNum := aSitua[ 1 ]
      // Compruebo FILA SUPERIOR
      nPos := nNum - ( nCol + 1 ) // 11
      FOR nVez = 1 TO 3
         IF nPos / nCol != Int( nPos / nCol ) .AND. nVez != 1
            IF nPos > 1 .AND. aAlbedrio[ nPos ][ 2 ] != 10
               // Si no tengo nada, me guardo la posicion para seguir la busqueda
               IF aAlbedrio[ nPos ][ 1 ]
                  IF aAlbedrio[ nPos ][ 2 ] == 0
                     AAdd( aSitua, nPos )
                  ENDIF
                  // Cargo tipo de dibujo
                  MuestraRastreo( nPos, nOpc )
                  aAlbedrio[ nPos ][ 1 ] := .F.
               ENDIF
            ENDIF
         ENDIF
         // Final Linea de Arriba
         IF nPos / nCol == Int( nPos / nCol ) .AND. nVez == 2
            EXIT
         ENDIF
         nPos++
      NEXT

      // LATERAL IZQUIERDO
      nPos := nNum - 1
      IF nPos > 1 .AND. Int( nPos / nCol ) != nPos / nCol .AND. aAlbedrio[ nPos ][ 2 ] != 10
         // Si no tengo nada, me guardo la posicion para seguir la busqueda
         IF aAlbedrio[ nPos ][ 1 ]
            IF aAlbedrio[ nPos ][ 2 ] == 0
               AAdd( aSitua, nPos )
            ENDIF
            // Cargo tipo de dibujo
            MuestraRastreo( nPos, nOpc )
            aAlbedrio[ nPos ][ 1 ] := .F.
         ENDIF
      ENDIF

      // LATERAL DERECHO
      nPos := nNum + 1
      IF nPos <= nMax .AND. Int( nNum / nCol ) != nNum / nCol .AND. aAlbedrio[ nPos ][ 2 ] != 10
         IF aAlbedrio[ nPos ][ 1 ]
            IF aAlbedrio[ nPos ][ 2 ] == 0
               AAdd( aSitua, nPos )
            ENDIF
            // Cargo tipo de dibujo
            MuestraRastreo( nPos, nOpc )
            aAlbedrio[ nPos ][ 1 ] := .F.
         ENDIF
      ENDIF

      // FILA INFERIOR
      nPos := nNum + ( nCol - 1 ) // 9
      FOR nVez = 1 TO 3
         // El principio de la linea de Abajo
         IF nPos / nCol == Int( nPos / nCol ) .AND. nVez == 1
            nVez++
            nPos++
         ENDIF
         IF nPos <= nMax .AND. aAlbedrio[ nPos ][ 2 ] != 10
            IF aAlbedrio[ nPos ][ 1 ]
               IF aAlbedrio[ nPos ][ 2 ] == 0
                  AAdd( aSitua, nPos )
               ENDIF
               // Cargo tipo de dibujo
               MuestraRastreo( nPos, nOpc )
               aAlbedrio[ nPos ][ 1 ] := .F.
            ENDIF
         ENDIF
         nPos++
         // Final Linea de Abajo
         IF nNum / nCol == Int( nNum / nCol ) .AND. nVez == 2
            EXIT
         ENDIF
      NEXT
      // ------------------------------
      // Borro posicion procesada
      ADel( aSitua, 1 )
      ASize( aSitua, Len( aSitua ) - 1 )
   ENDDO

RETURN NIL


PROCEDURE MuestraRastreo( nPos, nOpc )

   LOCAL cFoto, cCadena
   DEFAULT nOpc := ""

   // Cargo tipo de dibujo
   cCadena := "FOTO" + AllTrim( Str( nPos ) )
   nOpc := StrZero( aAlbedrio[ nPos ][ 2 ], 2 )
   cFoto := "IMG\MINAS" + nOpc + ".BMP"
   SetProperty( "Principal1", cCadena, "Picture", cFoto )

RETURN


PROCEDURE FinalPartida()

   LOCAL nFor
   LOCAL nMax := nFil * nCol

   FOR nFor = 1 TO nMax
      IF aAlbedrio[ nFor ][ 1 ]
         MuestraRastreo( nFor )
      ENDIF
   NEXT
   msgbox( "GAME OVER" )
   lFirstClick := .T.
   Reinicio()

RETURN


PROCEDURE MuestraRastreo2( nPos, nOpc )

   LOCAL cFoto, cCadena
   DEFAULT nOpc := ""

   // Cargo tipo de dibujo
   cCadena := "FOTO" + AllTrim( Str( nPos ) )
   IF aAlbedrio[ nPos ][ 2 ] < 9
      nOpc := StrZero( aAlbedrio[ nPos ][ 2 ], 2 )
   ELSE
      nOpc := "M1"
   ENDIF
   cFoto := "IMG\MINAS" + nOpc + ".BMP"
   SetProperty( "Principal1", cCadena, "Picture", cFoto )

RETURN


PROCEDURE FinalPartida2()

   LOCAL nFor
   LOCAL nMax := nFil * nCol

   FOR nFor = 1 TO nMax
      IF aAlbedrio[ nFor ][ 1 ]
         MuestraRastreo2( nFor )
      ENDIF
   NEXT
   msgbox( "YOU WON!" )
   lFirstClick := .T.
   Reinicio()

RETURN


PROCEDURE SALIR

   PLAY WAVE "FIN.wav"
   INKEYGUI( 200 )

   PantallaJuego.RELEASE

RETURN


FUNCTION VaciadoPartida()

   LOCAL nFor
   LOCAL nNum := 0
   LOCAL nMax := nFil * nCol

   FOR nFor = 1 TO nMax
      IF aAlbedrio[ nFor ][ 1 ]
         nNum++
      ENDIF
      IF aAlbedrio[ nFor ][ 3 ]
         nNum--
      ENDIF
   NEXT

RETURN ( nNum == 0 )
