/*
  propósito |relatório posição estoque dos produtos
  parâmetros|nenhum
  retorno   |nil
*/
#include "minigui.ch"
#include "miniprint.ch"
// -------------------------------------------------------------------------------
FUNCTION Posicao_Estoque()

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

      Cabecalho_Estoque_Produtos( nPagina )

      nLinha := 40

      FOR n_i := 1 TO oQuery:LastRec()

         oRow := oQuery:GetRow( n_i )

         @ nLinha, 010 PRINT StrZero( oRow:fieldGet( 1 ), 6 ) FONT 'courier new' SIZE 8
         @ nLinha, 030 PRINT AllTrim( oRow:fieldGet( 2 ) ) FONT 'courier new' SIZE 8
         @ nLinha, 110 PRINT Str( oRow:fieldGet( 11 ), 6 ) FONT 'courier new' SIZE 8
         @ nLinha, 130 PRINT trans( oRow:fieldGet( 7 ), '@E 99,999.99' ) FONT 'courier new' SIZE 8
         @ nLinha, 160 PRINT trans( oRow:fieldGet( 7 ) * oRow:fieldGet( 11 ), '@E 999,999.99' ) FONT 'courier new' SIZE 8

         nLinha += 5
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            nPagina++
            Cabecalho_Estoque_Produtos( nPagina )
            nLinha := 40
         ENDIF

         nTotal_Qtd := ( nTotal_Qtd + oRow:fieldGet( 11 ) )
         nTotal_Custo := ( nTotal_Custo + ( oRow:fieldGet( 7 ) * oRow:fieldGet( 11 ) ) )

         oQuery:Skip( 1 )

      NEXT n_i

      nLinha += 10
      IF nLinha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
         nPagina++
         Cabecalho_Estoque_Produtos( nPagina )
         nLinha := 40
      ENDIF

      @ nLinha, 020 PRINT 'Total Quantidade : ' + AllTrim( Str( nTotal_Qtd ) ) FONT 'courier new' SIZE 10 BOLD

      nLinha += 5
      IF nLinha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
         nPagina++
         Cabecalho_Estoque_Produtos( nPagina )
         nLinha := 40
      ENDIF

      @ nLinha, 020 PRINT 'Total Estoque    : ' + AllTrim( trans( nTotal_Custo, '@E 999,999,999.99' ) ) FONT 'courier new' SIZE 10 BOLD

      END PRINTPAGE
      END PRINTDOC

   ENDIF

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Cabecalho_Estoque_Produtos( pPagina )

   @ 010, 010 PRINT 'RELAÇÃO DA POSIÇÃO DE ESTOQUE DOS PRODUTOS' FONT 'courier new' SIZE 10 BOLD
   @ 015, 010 PRINT 'EMISSÃO: ' + Chk_DiaSem( Date(), 2 ) + ', ' + AllTrim( Str( Day( Date() ) ) ) + ' de ' + Chk_Mes( Month( Date() ), 1 ) + ' de ' + StrZero( Year( Date() ), 4 ) + ' - ' + Time() + 'h.' FONT 'courier new' SIZE 10
   @ 020, 010 PRINT 'PÁGINA : ' + StrZero( pPagina, 3 ) FONT 'courier new' SIZE 10

   @ 025, 000 PRINT LINE TO 025, 205 PENWIDTH 0.5 COLOR BLACK

   @ 030, 010 PRINT 'CÓD.' FONT 'courier new' SIZE 8 BOLD
   @ 030, 030 PRINT 'DESCRIÇÃO' FONT 'courier new' SIZE 8 BOLD
   @ 030, 110 PRINT 'QUANT.' FONT 'courier new' SIZE 8 BOLD
   @ 030, 130 PRINT 'VALOR CUSTO R$' FONT 'courier new' SIZE 8 BOLD
   @ 030, 160 PRINT 'TOTAL CUSTO R$' FONT 'courier new' SIZE 8 BOLD

return( nil )
