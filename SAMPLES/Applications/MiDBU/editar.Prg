#include <hmg.ch>
MEMVAR cArchivo
MEMVAR aNomb, aJust, aLong, aHdr, cBase, cCampo, cFiltro
*------------------------------------------------------------------------------*
FUNCTION EditarDBF()
*------------------------------------------------------------------------------*
   LOCAL nCamp, aEst, cCarpeta, i, nPos
   PUBLIC aNomb, aJust, aLong, aHdr, cBase, cCampo, cFiltro := ''

   SET SOFTSEEK ON

   IF cArchivo == ''
      cCarpeta := GetCurrentFolder()
      cArchivo := Getfile ( { { 'DBFs', '*.DBF' } }, 'Abrir base de datos', cCarpeta, .F., .T. )
   ENDIF

   nPos := RAt( '\', cArchivo )
   cCarpeta := SubStr( cArchivo, 1, nPos )
   cArchivo := SubStr( cArchivo, nPos + 1, Len( cArchivo ) )

   nPos := RAt( '.', cArchivo )
   cArchivo := SubStr( cArchivo, 1, nPos - 1 )

   IF File( cCarpeta + cArchivo + '.DBF' )
      USE ( cCarpeta + cArchivo ) Alias ( cArchivo ) EXCLUSIVE NEW

      cBase := Alias()
      nCamp := FCount()
      aEst := dbStruct()

      aNomb := {}
      aHdr := {}
      aJust := {}
      aLong := {}

      FOR i := 1 TO nCamp
         AAdd( aNomb, aEst[ i, 1 ] )
         AAdd( aHdr, aEst[ i, 1 ] )
         AAdd( aJust, iif( aEst[ i, 2 ] == 'N', 1, 0 ) )
         AAdd( aLong, Min( 250, Max( Len( aEst[ i, 1 ] ), aEst[ i, 3 ] ) * iif( aEst[ i, 3 ] > 5, 10, 12 ) ) )
      NEXT

      CreaBR()
   ENDIF

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION CreaBR()
*------------------------------------------------------------------------------*
   LOCAL aOrden := AClone( aNomb )

   AIns( aOrden, 1 )
   aOrden[ 1 ] := 'No Ordenado'

   DEFINE WINDOW Win_2 ;
         AT 0, 0 ;
         WIDTH 1024 ;
         HEIGHT 768 ;
         TITLE Upper( cArchivo ) ;
         MODAL ;
         ON RELEASE ( dbCloseAll(), FErase ( 'Aux1.CDX' ) )

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 58, 36 /*IMAGESIZE 20,20*/ FLAT BORDER
         BUTTON PRIMERO ;
            CAPTION '&Primero' ;
            PICTURE 'PRIMERO' ;
            ACTION ( _BrowseHome( 'BR_1', 'Win_2' ), Win_2.BR_1.VALUE := RecNo() )

         BUTTON ANTERIOR ;
            CAPTION '&Anterior' ;
            PICTURE 'ANTERIOR' ;
            ACTION ( _BrowseUp( 'BR_1', 'Win_2' ), Win_2.BR_1.VALUE := RecNo() )

         BUTTON SIGUIENTE ;
            CAPTION '&Siguiente' ;
            PICTURE 'SIGUIENTE' ;
            ACTION ( _BrowseDown( 'BR_1', 'Win_2' ), Win_2.BR_1.VALUE := RecNo() )

         BUTTON ULTIMO ;
            CAPTION '&Ultimo' ;
            PICTURE 'ULTIMO' ;
            ACTION ( _BrowseEnd( 'BR_1', 'Win_2' ), Win_2.BR_1.VALUE := RecNo() ) SEPARATOR

         BUTTON NUEVO ;
            CAPTION '&Nuevo' ;
            PICTURE 'NUEVO1' ;
            ACTION ( Nuevo() )

         BUTTON DELE ;
            CAPTION '&Borrar' ;
            PICTURE 'BORRAR' ;
            ACTION ( Borrar() )

         BUTTON ZAP ;
            CAPTION '&Pack' ;
            PICTURE 'BORRAR' ;
            ACTION ( BorrarTodo() )

         BUTTON CERRAR ;
            CAPTION '&Cerrar' ;
            PICTURE 'CERRAR1' ;
            ACTION ( cArchivo := '', Win_2.release )

      END TOOLBAR

      @ 60, 10 LABEL LABEL_1 VALUE 'Buscar:' HEIGHT 24 VCENTERALIGN
      @ 60, 70 TEXTBOX Control_1 WIDTH 250 ON ENTER ( Buscar() )

      @ 60, 450 LABEL LABEL_2 VALUE 'Ordenar:' HEIGHT 24 VCENTERALIGN
      @ 60, 510 COMBOBOX Combo_1 ITEMS aOrden VALUE 1 WIDTH 250 ON CHANGE ( Ordenar() )

      @ 60, 880 LABEL LABEL_3 VALUE 'Filtrar:' HEIGHT 24 VCENTERALIGN
      @ 51, 940 BUTTON FILTRAR CAPTION '' PICTURE 'FILTRAR' WIDTH 38 HEIGHT 38 TOP TOOLTIP 'Seleccionar registros' ACTION ( Filtrar() )

      @ 90, 10 BROWSE BR_1 ;
         WIDTH ( Win_2.WIDTH - 38 ) ;
         HEIGHT ( Win_2.HEIGHT - 135 ) ;
         WIDTHS aLong ;
         HEADERS aHdr ;
         WORKAREA &( cBase ) ;
         FIELDS aNomb ;
         JUSTIFY aJust ;
         INPLACE ;
         PAINTDOUBLEBUFFER ;
         ON DBLCLICK ( Win_2.BR_1.AllowEdit := .T. )

   END WINDOW
   SET TOOLTIP BACKCOLOR TO { 255, 255, 184 } OF Win_2
   SET TOOLTIP TEXTCOLOR TO { 000, 000, 000 } OF Win_2
   Win_2.BR_1.SetFocus

   CENTER WINDOW Win_2
   ACTIVATE WINDOW Win_2

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Ordenar()
*------------------------------------------------------------------------------*

   IF Win_2.Combo_1.Value > 1
      INDEX ON &( Win_2.Combo_1.Item( Win_2.Combo_1.Value ) ) TO Aux1
   ELSE
      SET ORDER TO 0
   ENDIF
   &cBase->( dbGoTop() )

   Win_2.BR_1.VALUE := &cBase->( RecNo() )

   Win_2.BR_1.Refresh
   Win_2.BR_1.SetFocus

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Buscar()
*------------------------------------------------------------------------------*

   IF Win_2.Combo_1.Value > 1
      cCampo := Win_2.Combo_1.Item( Win_2.Combo_1.Value )

      &cBase->( dbSetOrder( 1 ) )
      &cBase->( dbGoTop() )
      IF ValType( &cCampo ) == 'C'
         &cBase->( dbSeek( Win_2.Control_1.Value ) )
      ELSEIF ValType( &cCampo ) == 'N'
         &cBase->( dbSeek( Val( Win_2.Control_1.Value ) ) )
      ELSEIF ValType( &cCampo ) == 'D'
         &cBase->( dbSeek( CToD( Win_2.Control_1.Value ) ) )
      ENDIF

      Win_2.BR_1.VALUE := &cBase->( RecNo() )

      Win_2.BR_1.Refresh
      Win_2.BR_1.SetFocus
   ELSE
      MsgStop( 'No Ordenado' )
   ENDIF

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Nuevo()
*------------------------------------------------------------------------------*
   &cBase->( dbAppend() )

   IF IndexOrd() == 0
      _BrowseEnd( 'BR_1', 'Win_2' )
      Win_2.BR_1.VALUE := &cBase->( RecNo() )
   ELSE
      Win_2.BR_1.VALUE := &cBase->( RecNo() )
      Win_2.BR_1.Refresh
   ENDIF
   Win_2.BR_1.SetFocus

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Borrar()
*------------------------------------------------------------------------------*

   &cBase->( dbDelete() )
   &cBase->( dbSkip( -1 ) )
   IF &cBase->( Bof() )
      &cBase->( dbGoTop() )
   ENDIF

   Win_2.BR_1.VALUE := &cBase->( RecNo() )

   Win_2.BR_1.Refresh
   Win_2.BR_1.SetFocus

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION BorrarTodo()
*------------------------------------------------------------------------------*

   Select( cBase )
   PACK
   dbGoTop()

   Win_2.BR_1.VALUE := RecNo()

   Win_2.BR_1.Refresh
   Win_2.BR_1.SetFocus

RETURN NIL
*------------------------------------------------------------------------------*
STATIC FUNCTION Filtrar()
*------------------------------------------------------------------------------*

   IF Win_2.Combo_1.Value > 1
      cCampo := AllTrim( FieldName( Win_2.Combo_1.VALUE -1 ) )

      Select( cBase )
      cFiltro := AllTrim( InputBox( 'Filtro:', 'Busqueda', cFiltro ) )

      IF Len( cFiltro ) != 0
         IF ValType( &cCampo ) == 'C'
            SET FILTER TO ( cFiltro $ &cBase->( &cCampo ) )
         ELSEIF ValType( &cCampo ) == 'N'
            SET FILTER TO ( Val( cFiltro ) == &cBase->( &cCampo ) )
         ELSEIF ValType( &cCampo ) == 'D'
            SET FILTER TO ( CToD( cFiltro ) == &cBase->( &cCampo ) )
         ENDIF
      ELSE
         SET FILTER TO
      ENDIF

      dbGoTop()
      Win_2.BR_1.VALUE := RecNo()

      Win_2.BR_1.Refresh
      Win_2.BR_1.SetFocus
   ELSE
      MsgStop( 'No Ordenado' )
   ENDIF

RETURN NIL
