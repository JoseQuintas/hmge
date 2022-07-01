***********************************************************
* Programa de ejemplo para encontrar figuras pares
* (c) 2014, Roberto Sánchez
* eMail:  jrsancheze@gmail.com
***********************************************************

#include <hmg.ch>

#define lVerdadero  .T.
#define lFalso      .F.
#define NuevaLinea  hb_eol()

MEMVAR acCargado
MEMVAR aImagenCtrl, aObjetoCtrl
MEMVAR nControl

***************************************************
** Función principal
***************************************************

FUNCTION Main()

   PUBLIC acCargado := Array( 12 )
   PUBLIC aImagenCtrl := Array( 2 ), aObjetoCtrl := Array( 2 )
   PUBLIC nControl := 0

   AFill( aImagenCtrl, "" )
   AFill( aObjetoCtrl, "" )

   Set Language To Spanish
   Set Multiple Off
   Set Navigation Extended

   LOAD WINDOW Main
   SetProperty( "Main", "Sizable", .F. )
   ArmarArreglo()
   Main.Center()
   Main.Activate()

RETURN NIL

***************************************************
** Función para salir de la aplicación
***************************************************

PROCEDURE Salir()

   RELEASE WINDOW ALL

RETURN

***************************************************
** Función para llenar los arreglos de memoria
***************************************************

PROCEDURE ArmarArreglo()

   LOCAL cc, lBuscar, cNumero

   AFill( acCargado, "" )

   FOR cc := 1 TO 12
      lBuscar := lVerdadero
      DO WHILE lBuscar
         cNumero := StrZero( Random( 12 ), 2 )
         IF AScan( acCargado, cNumero ) == 0
            IF cNumero <> "00"
               lBuscar := lFalso
            ENDIF
         ENDIF
      ENDDO
      acCargado[ cc ] := cNumero
   NEXT cc

RETURN

***************************************************
** Función para mostrar las imágenes en la ventana
***************************************************

PROCEDURE Mostrar( cCargado, cObjeto )

   LOCAL cc, lCont, cFigura := "Fig" + cCargado

   SetProperty( "Main", cObjeto, "Picture", cFigura )
   SetProperty( "Main", cObjeto, "Enabled", lFalso )
   DoMethod( "Main", cObjeto, "Refresh" )

   IF nControl < 2
      DO CASE
      CASE cCargado == "07"
         cCargado := "01"
      CASE cCargado == "08"
         cCargado := "02"
      CASE cCargado == "09"
         cCargado := "03"
      CASE cCargado == "10"
         cCargado := "04"
      CASE cCargado == "11"
         cCargado := "05"
      CASE cCargado == "12"
         cCargado := "06"
      ENDCASE
      nControl += 1
      aImagenCtrl[ nControl ] := cCargado
      aObjetoCtrl[ nControl ] := cObjeto
   ENDIF

   HMG_SysWait( .5 )

   IF aImagenCtrl[ 1 ] == aImagenCtrl[ 2 ] .AND. nControl == 2
      SetProperty( "Main", aObjetoCtrl[ 1 ], "Visible", lFalso )
      SetProperty( "Main", aObjetoCtrl[ 2 ], "Visible", lFalso )
      AFill( aImagenCtrl, "" )
      AFill( aObjetoCtrl, "" )
      nControl := 0
   ENDIF

   IF aImagenCtrl[ 1 ] <> aImagenCtrl[ 2 ] .AND. nControl == 2
      SetProperty( "Main", aObjetoCtrl[ 1 ], "Picture", "Oculto" )
      SetProperty( "Main", aObjetoCtrl[ 2 ], "Picture", "Oculto" )
      SetProperty( "Main", aObjetoCtrl[ 1 ], "Enabled", lVerdadero )
      SetProperty( "Main", aObjetoCtrl[ 2 ], "Enabled", lVerdadero )
      AFill( aImagenCtrl, "" )
      AFill( aObjetoCtrl, "" )
      nControl := 0
   ENDIF

   FOR cc := 1 TO 12
      lCont := GetProperty( "Main", "IMG_" + StrZero( cc, 2 ), "Visible" )
      IF lCont
         EXIT
      ENDIF
   NEXT cc

   IF ! lCont
      MsgBox( "Game is Over!", "Fin..." )
   ENDIF

RETURN

***************************************************
** Función para reiniciar el juego
***************************************************

PROCEDURE Reiniciar()

   LOCAL cc, cObjeto

   AFill( aImagenCtrl, "" )
   AFill( aObjetoCtrl, "" )
   nControl := 0
   ArmarArreglo()
   FOR cc := 1 TO 12
      cObjeto := StrZero( cc, 2 )
      SetProperty( "Main", "IMG_" + cObjeto, "Picture", "Oculto" )
      SetProperty( "Main", "IMG_" + cObjeto, "Enabled", lVerdadero )
      SetProperty( "Main", "IMG_" + cObjeto, "Visible", lVerdadero )
   NEXT cc

RETURN

***************************************************
** Función para acerca de la aplicación
***************************************************

PROCEDURE AcercaDe()

   MsgBox( "(c) 2014, Roberto Sanchez" + NuevaLinea + "eMail: jrsancheze@gmail.com", "Derechos..." )

RETURN
