/*
  propósito |relatórios de ordens de serviço - encerradas - por período
  parâmetros|nenhum
  retorno   |nil
*/

#include "minigui.ch"
#include "miniprint.ch"
// -------------------------------------------------------------------------------
FUNCTION OS_af2_periodo()

   DEFINE WINDOW form_os_periodo_2 ;
         AT 000, 000 ;
         WIDTH 315 ;
         HEIGHT 160 ;
         TITLE 'Relatório: OS Encerradas (por período)' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      @ 010, 005 LABEL lbl_periodo ;
         WIDTH 160 ;
         VALUE 'Escolha o período' ;
         FONTCOLOR BLUE BOLD
      @ 030, 005 LABEL lbl_de ;
         WIDTH 025 ;
         VALUE 'de' ;
         FONTCOLOR BLACK BOLD
      @ 030, 160 LABEL lbl_ate ;
         WIDTH 025 ;
         VALUE 'até' ;
         FONTCOLOR BLACK BOLD
      @ 030, 035 datepicker dpi_de ;
         WIDTH 100 ;
         VALUE Date() ;
         TOOLTIP 'clicando na seta aparecerá um calendário'
      @ 030, 205 datepicker dpi_ate ;
         WIDTH 100 ;
         VALUE Date() ;
         TOOLTIP 'clicando na seta aparecerá um calendário'

      DEFINE BUTTONEX btn_imprime
         ROW 075
         COL 095
         WIDTH 100
         HEIGHT 050
         CAPTION 'Imprimir'
         PICTURE 'imprimir'
         FONTBOLD .T.
         lefttext .F.
         ACTION Imprime_OS_Periodo_2()
      END BUTTONEX
      DEFINE BUTTONEX btn_volta
         ROW 075
         COL 205
         WIDTH 100
         HEIGHT 050
         CAPTION 'Voltar'
         PICTURE 'img_voltar'
         FONTBOLD .T.
         lefttext .F.
         ACTION form_os_periodo_2.RELEASE
      END BUTTONEX

   END WINDOW

   form_os_periodo_2.CENTER
   form_os_periodo_2.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Imprime_OS_Periodo_2()

   LOCAL nLinha := 35
   LOCAL Pagina := 1
   LOCAL nCod_Cliente := 0
   LOCAL nSub_Servico := 0
   LOCAL nTot_Servico := 0
   LOCAL nSub_Peca := 0
   LOCAL nTot_Peca := 0
   LOCAL nTotal_OS := 0
   LOCAL nGT_Servico := 0
   LOCAL nGT_Peca := 0
   LOCAL nNumOS := 0
   LOCAL dData_01
   LOCAL dData_02

   LOCAL lSuccess
   LOCAL v_linha := 50
   LOCAL u_linha := 260
   LOCAL v_pagina := 1

   LOCAL oQuery, cQuery
   LOCAL oQuery_1, cQuery_1
   LOCAL oQuery_2, cQuery_2
   LOCAL oRow := {}
   LOCAL oRow_1 := {}
   LOCAL oRow_2 := {}
   LOCAL n_i := 0
   LOCAL n_1 := 0
   LOCAL n_2 := 0

   dData_01 := td( form_os_periodo_2.dpi_de.value )
   dData_02 := td( form_os_periodo_2.dpi_ate.value )

   oQuery := oServer:Query( "select * from os where data>='" + dData_01 + "' and data<='" + dData_02 + "' and encerrado=1 order by data" )

   SELECT PRINTER DIALOG TO lSuccess PREVIEW

   IF lSuccess == .T.

      START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

      cabecalho_os_periodo_2( pagina, form_os_periodo_2.dpi_de.VALUE, form_os_periodo_2.dpi_ate.value )

      FOR n_i := 1 TO oQuery:LastRec()
         oRow := oQuery:GetRow( n_i )
         nNumOS := oRow:fieldGet( 2 )
         @ nLinha, 010 PRINT 'Nº: ' + AllTrim( Str( nNumOS ) ) FONT 'courier new' SIZE 8 BOLD
         @ nLinha, 040 PRINT 'Data-Hora: ' + DToC( oRow:fieldGet( 3 ) ) + '-' + AllTrim( oRow:fieldGet( 4 ) ) FONT 'courier new' SIZE 8
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
         @ nLinha, 010 PRINT 'Cliente : ' + AllTrim( oRow:fieldGet( 6 ) ) FONT 'courier new' SIZE 8 BOLD
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
         @ nLinha, 010 PRINT 'Aparelho: ' + AllTrim( oRow:fieldGet( 16 ) ) FONT 'courier new' SIZE 8
         @ nLinha, 100 PRINT 'Marca: ' + AllTrim( oRow:fieldGet( 17 ) ) FONT 'courier new' SIZE 8
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
         @ nLinha, 010 PRINT 'Modelo  : ' + AllTrim( oRow:fieldGet( 18 ) ) FONT 'courier new' SIZE 8
         @ nLinha, 100 PRINT 'Nº Série: ' + AllTrim( oRow:fieldGet( 19 ) ) FONT 'courier new' SIZE 8
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
         @ nLinha, 010 PRINT 'Defeito : ' + AllTrim( oRow:fieldGet( 22 ) ) FONT 'courier new' SIZE 8
         nLinha += 5
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
      /*
        cabeçalho : serviços e peças
      */
         @ nLinha, 010 PRINT 'CÓD.' FONT 'courier new' SIZE 8 BOLD
         @ nLinha, 020 PRINT 'DESCRIÇÃO' FONT 'courier new' SIZE 8 BOLD
         @ nLinha, 100 PRINT 'QTD.' FONT 'courier new' SIZE 8 BOLD
         @ nLinha, 120 PRINT 'UNIT.R$' FONT 'courier new' SIZE 8 BOLD
         @ nLinha, 150 PRINT 'SUB-TOTAL R$' FONT 'courier new' SIZE 8 BOLD
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
      /*
        serviços
      */
         n_1 := 0
         oQuery_1 := oServer:Query( "select * from os_servicos where numero_os='" + AllTrim( Str( nNumOS ) ) + "' order by data" )
         FOR n_1 := 1 TO oQuery_1:LastRec()
            oRow_1 := oQuery_1:GetRow( n_1 )
            nSub_Servico := ( nSub_Servico + ( oRow_1:fieldGet( 6 ) * oRow_1:fieldGet( 7 ) ) )
            nTot_Servico := ( nTot_Servico + nSub_Servico )
            @ nLinha, 010 PRINT StrZero( oRow_1:fieldGet( 4 ), 4 ) FONT 'courier new' SIZE 8
            @ nLinha, 020 PRINT AllTrim( oRow_1:fieldGet( 5 ) ) FONT 'courier new' SIZE 8
            @ nLinha, 100 PRINT StrZero( oRow_1:fieldGet( 6 ), 4 ) FONT 'courier new' SIZE 8
            @ nLinha, 120 PRINT trans( oRow_1:fieldGet( 7 ), '@E 9,999.99' ) FONT 'courier new' SIZE 8
            @ nLinha, 150 PRINT trans( oRow_1:fieldGet( 8 ), '@E 99,999.99' ) FONT 'courier new' SIZE 8
            nSub_Servico := 0
            oQuery_1:Skip( 1 )
            IF oRow_1:fieldGet( 3 ) <> nNumOS
               EXIT
            ENDIF
            nLinha += 4
            IF nLinha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
               pagina++
               cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
               nLinha := 35
            ENDIF
         NEXT n_1
         nSub_Servico := 0
         IF nLinha <> 35
            nLinha += 4
            IF nLinha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
               pagina++
               cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
               nLinha := 35
            ENDIF
         ENDIF
                        /*
                          peças
                        */
         n_2 := 0
         oQuery_2 := oServer:Query( "select * from os_pecas where numero_os='" + AllTrim( Str( nNumOS ) ) + "' order by data" )
         FOR n_2 := 1 TO oQuery_2:LastRec()
            oRow_2 := oQuery_2:GetRow( n_2 )
            nSub_Peca := ( nSub_Peca + ( oRow_2:fieldGet( 6 ) * oRow_2:fieldGet( 7 ) ) )
            nTot_Peca := ( nTot_Peca + nSub_Peca )
            @ nLinha, 010 PRINT StrZero( oRow_2:fieldGet( 4 ), 4 ) FONT 'courier new' SIZE 8
            @ nLinha, 020 PRINT AllTrim( oRow_2:fieldGet( 5 ) ) FONT 'courier new' SIZE 8
            @ nLinha, 100 PRINT StrZero( oRow_2:fieldGet( 6 ), 4 ) FONT 'courier new' SIZE 8
            @ nLinha, 120 PRINT trans( oRow_2:fieldGet( 7 ), '@E 9,999.99' ) FONT 'courier new' SIZE 8
            @ nLinha, 150 PRINT trans( oRow_2:fieldGet( 8 ), '@E 99,999.99' ) FONT 'courier new' SIZE 8
            nSub_Peca := 0
            oQuery_2:Skip( 1 )
            IF oRow_2:fieldGet( 3 ) <> nNumOS
               EXIT
            ENDIF
            nLinha += 4
            IF nLinha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
               pagina++
               cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
               nLinha := 35
            ENDIF
         NEXT n_2
         nSub_Peca := 0
      /*
        totais : parciais
      */
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
         @ nLinha, 020 PRINT 'TOTAL Serviço(s) R$ :' + trans( nTot_Servico, '@E 999,999.99' ) FONT 'courier new' SIZE 8 BOLD
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
         @ nLinha, 020 PRINT 'TOTAL Peça(s)    R$ :' + trans( nTot_Peca, '@E 999,999.99' ) FONT 'courier new' SIZE 8 BOLD
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
         @ nLinha, 020 PRINT 'TOTAL GERAL (OS) R$ :' + trans( nTot_Servico + nTot_Peca, '@E 999,999.99' ) FONT 'courier new' SIZE 8 BOLD
      /*
        acumular valores para totalização geral
      */
         nGT_Servico := ( nGT_Servico + nTot_Servico )
         nGT_Peca := ( nGT_Peca + nTot_Peca )
         nTot_Servico := 0
         nTot_Peca := 0
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF
                        /*
                          linha separadora
                        */
         @ nlinha, 010 PRINT LINE TO nLinha, 205 PENWIDTH 0.5 COLOR BLACK
         nLinha += 4
         IF nLinha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
            pagina++
            cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
            nLinha := 35
         ENDIF

         oQuery:Skip( 1 )

      NEXT n_i
   /*
     final do relatório
   */
      nLinha += 4
      IF nLinha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
         pagina++
         cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
         nLinha := 35
      ENDIF
      @ nLinha, 020 PRINT 'TOTAL SERVIÇO R$ :' + trans( nGT_Servico, '@E 999,999.99' ) FONT 'courier new' SIZE 8 BOLD
      nLinha += 4
      IF nLinha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
         pagina++
         cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
         nLinha := 35
      ENDIF
      @ nLinha, 020 PRINT 'TOTAL PEÇA    R$ :' + trans( nGT_Peca, '@E 999,999.99' ) FONT 'courier new' SIZE 8 BOLD
      nLinha += 4
      IF nLinha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
         pagina++
         cabecalho_os_periodo_2( Pagina, dData_01, dData_02 )
         nLinha := 35
      ENDIF
      @ nLinha, 020 PRINT 'TOTAL GERAL   R$ :' + trans( nGT_Servico + nGT_Peca, '@E 999,999.99' ) FONT 'courier new' SIZE 8 BOLD

      END PRINTPAGE
      END PRINTDOC

   ENDIF

   oQuery:Destroy()

   form_os_periodo_2.RELEASE

return( nil )
// -------------------------------------------------------------------------------
FUNCTION cabecalho_os_periodo_2( pPagina, dData1, dData2 )

   @ 005, 010 PRINT 'RELAÇÃO DE ORDENS DE SERVIÇO ENCERRADAS - (Por Período)' FONT 'courier new' SIZE 10 BOLD
   @ 010, 010 PRINT 'PERÍODO : ' + DToC( dData1 ) + ' até ' + DToC( dData2 ) FONT 'courier new' SIZE 10
   @ 015, 010 PRINT 'EMISSÃO : ' + Chk_DiaSem( Date(), 2 ) + ', ' + AllTrim( Str( Day( Date() ) ) ) + ' de ' + Chk_Mes( Month( Date() ), 1 ) + ' de ' + StrZero( Year( Date() ), 4 ) + ' - ' + Time() + 'h.' FONT 'courier new' SIZE 10
   @ 020, 010 PRINT 'PÁGINA  : ' + StrZero( pPagina, 3 ) FONT 'courier new' SIZE 10

   @ 025, 000 PRINT LINE TO 025, 205 PENWIDTH 0.5 COLOR BLACK

return( nil )
