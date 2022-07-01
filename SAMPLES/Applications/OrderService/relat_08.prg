/*
  propósito |relatório produtos em falta
  parâmetros|nenhum
  retorno   |nil
*/
#include "minigui.ch"
#include "miniprint.ch"
// -------------------------------------------------------------------------------
FUNCTION Produtos_em_Falta()

   LOCAL nTotal_Qtd := 0
   LOCAL nTotal_Custo := 0

   LOCAL lSuccess
   LOCAL nLinha := 40
   LOCAL u_linha := 260
   LOCAL nPagina := 1

   LOCAL oQuery, cQuery
   LOCAL oRow := {}
   LOCAL n_i := 0

   oQuery := oServer:Query( "select * from produtos order by nome" )

   SELECT PRINTER DIALOG TO lSuccess PREVIEW

   IF lSuccess == .T.

      START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

      Cabecalho_Produtos_Falta( nPagina )

      nLinha := 40

      FOR n_i := 1 TO oQuery:LastRec()

         oRow := oQuery:GetRow( n_i )

         IF oRow:fieldGet( 11 ) < oRow:fieldGet( 12 )

            @ nLinha, 010 PRINT StrZero( oRow:fieldGet( 1 ), 6 ) FONT 'courier new' SIZE 8
            @ nLinha, 030 PRINT AllTrim( oRow:fieldGet( 2 ) ) FONT 'courier new' SIZE 8
            @ nLinha, 110 PRINT Str( oRow:fieldGet( 11 ), 6 ) FONT 'courier new' SIZE 8
            @ nLinha, 130 PRINT Str( oRow:fieldGet( 12 ), 6 ) FONT 'courier new' SIZE 8
            @ nLinha, 160 PRINT Str( oRow:fieldGet( 11 ) - oRow:fieldGet( 12 ), 6 ) FONT 'courier new' SIZE 8

            nLinha += 5
            IF nLinha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
               nPagina++
               Cabecalho_Produtos_Falta( nPagina )
               nLinha := 40
            ENDIF

         ENDIF

         oQuery:Skip( 1 )

      NEXT n_i

      END PRINTPAGE
      END PRINTDOC

   ENDIF

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Cabecalho_Produtos_Falta( pPagina )

   @ 010, 010 PRINT 'RELAÇÃO DE PRODUTOS EM FALTA' FONT 'courier new' SIZE 10 BOLD
   @ 015, 010 PRINT 'EMISSÃO: ' + Chk_DiaSem( Date(), 2 ) + ', ' + AllTrim( Str( Day( Date() ) ) ) + ' de ' + Chk_Mes( Month( Date() ), 1 ) + ' de ' + StrZero( Year( Date() ), 4 ) + ' - ' + Time() + 'h.' FONT 'courier new' SIZE 10
   @ 020, 010 PRINT 'PÁGINA : ' + StrZero( pPagina, 3 ) FONT 'courier new' SIZE 10

   @ 025, 000 PRINT LINE TO 025, 205 PENWIDTH 0.5 COLOR BLACK

   @ 030, 010 PRINT 'CÓD.' FONT 'courier new' SIZE 8 BOLD
   @ 030, 030 PRINT 'DESCRIÇÃO' FONT 'courier new' SIZE 8 BOLD
   @ 030, 110 PRINT 'EST.ATUAL' FONT 'courier new' SIZE 8 BOLD
   @ 030, 130 PRINT 'EST.MINIMO' FONT 'courier new' SIZE 8 BOLD
   @ 030, 160 PRINT 'DIFERENÇA' FONT 'courier new' SIZE 8 BOLD

return( nil )
