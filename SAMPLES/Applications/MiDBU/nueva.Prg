#include <hmg.ch>
MEMVAR cArchivo
MEMVAR Nuevo
*------------------------------------------------------------------------------*
FUNCTION NuevaDBF()
*------------------------------------------------------------------------------*
   PRIVATE Nuevo := .T.

   DEFINE WINDOW Win_2 ;
         AT 0, 0 ;
         WIDTH 555 ;
         HEIGHT 485 ;
         TITLE 'Crear o modificar una base de datos' ;
         MODAL ;
         ON INIT InicializaVariables()

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 58, 36 /*IMAGESIZE 20, 20*/ FLAT BORDER

         BUTTON NUEVO ;
            CAPTION '&Nuevo' ;
            PICTURE 'NUEVO1' ;
            ACTION ( Nuevo() )

         BUTTON EDITAR ;
            CAPTION '&Editar' ;
            PICTURE 'EDITAR1' ;
            ACTION ( Editar() )

         BUTTON GUARDAR ;
            CAPTION '&Guardar' ;
            PICTURE 'EDITAR1' ;
            ACTION ( Guardar(), cArchivo := '', InicializaVariables() )

         BUTTON CERRAR ;
            CAPTION '&Cerrar' ;
            PICTURE 'CERRAR1' ;
            ACTION ( cArchivo := '', Win_2.release )

      END TOOLBAR

      @ 55, 10 LABEL BASE VALUE 'Nombre: ' AUTOSIZE

      @ 55, 90 TEXTBOX NOMBRE WIDTH 250 MAXLENGTH 8 UPPER

      @ 85, 10 LABEL CAMPO VALUE 'Campo' AUTOSIZE
      @ 85, 270 LABEL TIPO VALUE 'Tipo' AUTOSIZE
      @ 85, 360 LABEL LARGO VALUE 'Largo' AUTOSIZE
      @ 85, 450 LABEL DECIMALES VALUE 'Decimales' AUTOSIZE

      @ 110, 10 TEXTBOX NOMBRE_CAMPO WIDTH 250 MAXLENGTH 10 UPPER
      @ 110, 270 COMBOBOX TIPO_CAMPO WIDTH 80 ITEMS { 'C', 'N', 'D', 'L', 'M' } VALUE 1
      @ 110, 360 TEXTBOX LARGO_CAMPO WIDTH 80 NUMERIC INPUTMASK '999' RIGHTALIGN
      @ 110, 450 TEXTBOX DECIMALES_CAMPO WIDTH 80 NUMERIC INPUTMASK '99' RIGHTALIGN ON ENTER AgregaCampo()

      @ 140, 10 GRID ESTRUCTURA ;
         WIDTH 520 ;
         HEIGHT 300 ;
         HEADERS { 'Nombre', 'Tipo', 'Longitud', 'Decimales' } ;
         WIDTHS { 260, 80, 80, 80 } ;
         JUSTIFY { 0, 0, 1, 1 } ;
         ITEMS {}

      DEFINE CONTEXT MENU
         ITEM "Modificar Linea" + Chr( 9 ) + 'F2' ACTION ( Modifica_Linea() )
         ITEM "Eliminar Linea " + Chr( 9 ) + '^Del' ACTION ( Eliminar_Linea() )
      END MENU

      ON KEY F2 ACTION ( Modifica_Linea() )
      ON KEY CONTROL + DELETE ACTION ( Eliminar_Linea() )

   END WINDOW
   CENTER WINDOW Win_2
   ACTIVATE WINDOW Win_2

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION InicializaVariables()
*------------------------------------------------------------------------------*

   Win_2.NOMBRE_CAMPO.VALUE := ''
   Win_2.TIPO_CAMPO.VALUE := 1
   Win_2.LARGO_CAMPO.VALUE := 0
   Win_2.DECIMALES_CAMPO.VALUE := 0

   Win_2.NOMBRE.ENABLED := .F.
   Win_2.NOMBRE_CAMPO.ENABLED := .F.
   Win_2.TIPO_CAMPO.ENABLED := .F.
   Win_2.LARGO_CAMPO.ENABLED := .F.
   Win_2.DECIMALES_CAMPO.ENABLED := .F.

   Win_2.ESTRUCTURA.ENABLED := .F.

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Nuevo()
*------------------------------------------------------------------------------*

   Win_2.NOMBRE.ENABLED := .T.
   Win_2.NOMBRE_CAMPO.ENABLED := .T.
   Win_2.TIPO_CAMPO.ENABLED := .T.
   Win_2.LARGO_CAMPO.ENABLED := .T.
   Win_2.DECIMALES_CAMPO.ENABLED := .T.

   Win_2.ESTRUCTURA.ENABLED := .T.

   Win_2.NOMBRE.SetFocus

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Editar()
*------------------------------------------------------------------------------*
   LOCAL aEstructura, cCarpeta, i, nPos

   IF cArchivo == ''
      cCarpeta := GetCurrentFolder()
      cArchivo := AllTrim( Getfile ( { { 'DBFs', '*.DBF' } }, 'Abrir base de datos', cCarpeta, .F., .T. ) )
   ENDIF

   nPos := RAt( '\', cArchivo )
   cCarpeta := SubStr( cArchivo, 1, nPos )
   cArchivo := SubStr( cArchivo, nPos + 1, Len( cArchivo ) )

   nPos := RAt( '.', cArchivo )
   cArchivo := SubStr( cArchivo, 1, nPos - 1 )

   Win_2.NOMBRE.VALUE := cArchivo

   IF Win_2.NOMBRE.VALUE == ''
      Win_2.NOMBRE.SetFocus
      RETURN NIL
   ENDIF

   Win_2.NOMBRE.ENABLED := .T.
   Win_2.NOMBRE_CAMPO.ENABLED := .T.
   Win_2.TIPO_CAMPO.ENABLED := .T.
   Win_2.LARGO_CAMPO.ENABLED := .T.
   Win_2.DECIMALES_CAMPO.ENABLED := .T.

   Win_2.ESTRUCTURA.ENABLED := .T.

   IF File( cCarpeta + cArchivo + '.DBF' )
      USE ( cCarpeta + cArchivo ) Alias ( cArchivo ) EXCLUSIVE NEW
      aEstructura := dbStruct()
      CLOSE ( cArchivo )

      Win_2.ESTRUCTURA.DeleteAllItems
      FOR i := 1 TO Len( aEstructura )
         Win_2.ESTRUCTURA.AddItem( { aEstructura[ i, 1 ], aEstructura[ i, 2 ], AllTrim( Str( aEstructura[ i, 3 ], 3, 0 ) ), AllTrim( Str( aEstructura[ i, 4 ], 2, 0 ) ) } )
      NEXT i
   ENDIF

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Modifica_Linea()
*------------------------------------------------------------------------------*

   Win_2.NOMBRE_CAMPO.VALUE := Win_2.ESTRUCTURA.Item( Win_2.ESTRUCTURA.Value )[ 1 ]
   Win_2.TIPO_CAMPO.VALUE := AScan( { 'C', 'N', 'D', 'L', 'M' }, Win_2.ESTRUCTURA.Item( Win_2.ESTRUCTURA.Value )[ 2 ] )
   Win_2.LARGO_CAMPO.VALUE := Val( Win_2.ESTRUCTURA.Item( Win_2.ESTRUCTURA.Value )[ 3 ] )
   Win_2.DECIMALES_CAMPO.VALUE := Val( Win_2.ESTRUCTURA.Item( Win_2.ESTRUCTURA.Value )[ 4 ] )

   Nuevo := .F.

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Eliminar_Linea()
*------------------------------------------------------------------------------*
   LOCAL v

   v := Win_2.ESTRUCTURA.VALUE
   Win_2.ESTRUCTURA.DeleteItem( Win_2.ESTRUCTURA.Value )
   Win_2.ESTRUCTURA.VALUE := iif( v > 1, v - 1, 1 )
   Win_2.ESTRUCTURA.Setfocus

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION AgregaCampo()
*------------------------------------------------------------------------------*

   IF Win_2.TIPO_CAMPO.VALUE == 3
      Win_2.LARGO_CAMPO.VALUE := 8
   ELSEIF Win_2.TIPO_CAMPO.VALUE == 4
      Win_2.LARGO_CAMPO.VALUE := 1
   ELSEIF Win_2.TIPO_CAMPO.VALUE == 5
      Win_2.LARGO_CAMPO.VALUE := 10
   ENDIF
   IF Win_2.TIPO_CAMPO.Value > 2
      Win_2.DECIMALES_CAMPO.VALUE := 0
   ENDIF

   IF Nuevo

      Win_2.ESTRUCTURA.AddItem( { Win_2.NOMBRE_CAMPO.VALUE, ;
         Win_2.TIPO_CAMPO.Item( Win_2.TIPO_CAMPO.Value ), ;
         hb_ntos( Win_2.LARGO_CAMPO.Value ), ;
         hb_ntos( Win_2.DECIMALES_CAMPO.Value ) } )

   ELSE

      Win_2.ESTRUCTURA.Cell( Win_2.ESTRUCTURA.VALUE, 1 ) := Win_2.NOMBRE_CAMPO.VALUE
      Win_2.ESTRUCTURA.Cell( Win_2.ESTRUCTURA.VALUE, 2 ) := Win_2.TIPO_CAMPO.Item( Win_2.TIPO_CAMPO.Value )
      Win_2.ESTRUCTURA.Cell( Win_2.ESTRUCTURA.VALUE, 3 ) := hb_ntos( Win_2.LARGO_CAMPO.Value )
      Win_2.ESTRUCTURA.Cell( Win_2.ESTRUCTURA.VALUE, 4 ) := hb_ntos( Win_2.DECIMALES_CAMPO.Value )

      Nuevo := .T.

   ENDIF

   Win_2.ESTRUCTURA.Refresh

   Win_2.NOMBRE_CAMPO.VALUE := ''
   Win_2.TIPO_CAMPO.VALUE := 1
   Win_2.LARGO_CAMPO.VALUE := ''
   Win_2.DECIMALES_CAMPO.VALUE := ''

   Win_2.NOMBRE_CAMPO.SetFocus

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Guardar()
*------------------------------------------------------------------------------*
   LOCAL aStruct := {}, i

   IF Win_2.NOMBRE.VALUE == ''
      Win_2.NOMBRE.SetFocus
      RETURN NIL
   ENDIF

   FOR I := 1 TO Win_2.ESTRUCTURA.ItemCount
      IF AScan( aStruct, {| e | e[ 1 ] == Win_2.ESTRUCTURA.Item( I )[ 1 ] } ) == 0
         AAdd( aStruct, { Win_2.ESTRUCTURA.Item( I )[ 1 ], Win_2.ESTRUCTURA.Item( I )[ 2 ], Val( Win_2.ESTRUCTURA.Item( I )[ 3 ] ), Val( Win_2.ESTRUCTURA.Item( I )[ 4 ] ) } )
      ENDIF
   NEXT I

   Win_2.NOMBRE.VALUE := AllTrim( Win_2.NOMBRE.Value )

   IF File( Win_2.NOMBRE.VALUE +'.DBF' )

      /* Cambiar el nombre de la base de datos */

      USE ( Win_2.NOMBRE.Value )
      COPY TO ( '_' + Win_2.NOMBRE.Value )
      CLOSE ( Win_2.NOMBRE.Value )

      /* Crear la base de datos con la nueva estructura */

      dbCreate( Win_2.NOMBRE.VALUE, aStruct )

      /* Recuperar los datos si los hubiera */

      USE ( Win_2.NOMBRE.Value )
      ZAP
      APPEND FROM ( '_' + Win_2.NOMBRE.Value )
      CLOSE ( Win_2.NOMBRE.Value )

      /* Eliminar la base de datos auxiliar */

      FErase( '_' + Win_2.NOMBRE.VALUE +'.DBF' )
      IF File ( '_' + Win_2.NOMBRE.VALUE +'.FPT' )
         FErase( '_' + Win_2.NOMBRE.VALUE +'.FPT' )
      ENDIF

   ELSE

      /* Crear la base de datos con la nueva estructura */

      dbCreate( Win_2.NOMBRE.VALUE, aStruct )

   ENDIF

RETURN NIL
