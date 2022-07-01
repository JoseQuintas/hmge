/*
  sistema     : ordem de serviço
  programa    : acompanhamento
  compilador  : harbour
  lib gráfica : minigui extended
*/

#include 'minigui.ch'
#include 'miniprint.ch'

FUNCTION acompanha()

   LOCAL cNumero
   PRIVATE nNumOS

   PUBLIC m_nome_servico := ''
   PUBLIC m_nome_peca := ''
   PUBLIC m_nome_tecnico := ''

   PUBLIC n_soma_total := 0

   DEFINE WINDOW form_acompanhamento ;
         AT 0, 0 ;
         WIDTH 1000 ;
         HEIGHT 700 ;
         TITLE 'Acompanhamento' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      @ 005, 005 LABEL lbl_001 ;
         VALUE 'Pesquisar por'
      @ 005, 140 LABEL lbl_002 ;
         VALUE 'Digite sua pesquisa'
      @ 025, 005 comboboxex cbo_001 ;
         WIDTH 120 ;
         items { 'Nº da OS', 'Nome do Cliente' } ;
         VALUE 1
      @ 025, 140 TEXTBOX txt_pesquisa ;
         WIDTH 300 ;
         MAXLENGTH 30 ;
         UPPERCASE
      DEFINE BUTTONEX button_filtra
         COL 460
         ROW 7
         WIDTH 100
         HEIGHT 040
         CAPTION 'Pesquisar'
         ACTION filtra_os()
         FONTBOLD .T.
         FONTCOLOR WHITE
         BACKCOLOR BLUE
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
    /*
   mostrar resultado do filtro
    */
      @ 050, 005 GRID grid_os ;
         OF form_andamento ;
         WIDTH 980 ;
         HEIGHT 140 ;
         headers { 'ID', 'Nº OS', 'Data', 'Hora', 'Aparelho', 'Nº Série', 'Marca', 'Modelo', 'Cliente' } ;
         widths { 1, 60, 80, 70, 200, 130, 130, 130, 130 } ;
         BACKCOLOR WHITE ;
         FONTCOLOR BLUE ;
         TOOLTIP 'Para implantar a DATA/HORA de saída e DATA de GARANTIA, dê um duplo-clique sobre a OS' ;
         ON dblclick Inserir_Datas() ;
         ON change( Mostra_Servicos_Pecas() )
      @ 195, 005 LABEL lbl_003 ;
         VALUE 'Cliente'
      @ 195, 400 LABEL lbl_data_prevista ;
         VALUE 'Previsão Entrega'
      @ 195, 055 LABEL lbl_nome_cliente ;
         VALUE '' ;
         BOLD ;
         FONTCOLOR BLUE
      @ 195, 510 LABEL lbl_data_hora_previsao ;
         VALUE '' ;
         BOLD ;
         FONTCOLOR BLUE
      @ 195, 720 LABEL lbl_encerrada ;
         VALUE '' ;
         BOLD ;
         FONTCOLOR RED

     /*
               linha separadora - meio da tela
              */
      DEFINE LABEL linha_rodape_1
         COL 0
         ROW 220
         VALUE ''
         WIDTH form_acompanhamento.WIDTH
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL
     /*
       serviços
     */
      @ 225, 250 LABEL lbl_servicos ;
         VALUE 'SERVIÇOS' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 14 BOLD ;
         FONTCOLOR _preto_001 transparent
      DEFINE BUTTONEX button_inc_servico
         COL 5
         ROW 225
         WIDTH 110
         HEIGHT 30
         CAPTION 'Incluir Serviço'
         ACTION servico_incluir_2( _numero_os )
         FONTNAME 'tahoma'
         FONTCOLOR BLUE
         FONTBOLD .T.
         TOOLTIP 'Clique aqui para INCLUIR um serviço na Ordem de Serviço'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_exc_servico
         COL 120
         ROW 225
         WIDTH 110
         HEIGHT 30
         CAPTION 'Excluir Serviço'
         ACTION servico_excluir_2()
         FONTNAME 'tahoma'
         FONTCOLOR BLUE
         FONTBOLD .T.
         TOOLTIP 'Clique aqui para EXCLUIR um serviço na Ordem de Serviço'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      @ 260, 005 GRID grid_servicos ;
         WIDTH 700 ;
         HEIGHT 150 ;
         headers { 'ID', 'Descrição', 'Qtd.', 'Unit.R$', 'Sub-Total R$', 'ID Tec.' } ;
         widths { 1, 300, 60, 100, 120, 1 } ;
         FONT 'courier new' SIZE 10 BOLD ;
         BACKCOLOR WHITE ;
         FONTCOLOR BLACK
     /*
       peças
     */
      @ 420, 250 LABEL lbl_pecas ;
         VALUE 'PEÇAS' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 14 BOLD ;
         FONTCOLOR _preto_001 transparent
      DEFINE BUTTONEX button_inc_peca
         COL 5
         ROW 420
         WIDTH 110
         HEIGHT 30
         CAPTION 'Incluir Peça'
         ACTION pecas_incluir_2( _numero_os )
         FONTNAME 'tahoma'
         FONTCOLOR BLUE
         FONTBOLD .T.
         TOOLTIP 'Clique aqui para INCLUIR uma peça na Ordem de Serviço'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_exc_peca
         COL 120
         ROW 420
         WIDTH 110
         HEIGHT 30
         CAPTION 'Excluir Peça'
         ACTION pecas_excluir_2()
         FONTNAME 'tahoma'
         FONTCOLOR BLUE
         FONTBOLD .T.
         TOOLTIP 'Clique aqui para EXCLUIR uma peça na Ordem de Serviço'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      @ 455, 005 GRID grid_pecas ;
         WIDTH 700 ;
         HEIGHT 150 ;
         headers { 'ID', 'Descrição', 'Qtd.', 'Unit.R$', 'Sub-Total R$', 'ID Tec.' } ;
         widths { 1, 300, 60, 100, 120, 1 } ;
         FONT 'courier new' SIZE 10 BOLD ;
         BACKCOLOR WHITE ;
         FONTCOLOR BLACK
     /*
       total da OS
     */
      DEFINE FRAME frame_total
         COL 720
         ROW 440
         WIDTH 270
         HEIGHT 160
         opaque .F.
         transparent .F.
      END FRAME
      @ 450, 790 LABEL lbl_total ;
         VALUE 'TOTAL DA OS' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 12 BOLD ;
         FONTCOLOR BLUE transparent
      @ 520, 750 LABEL lbl_total_os ;
         VALUE trans( n_soma_total, '@E 999,999.99' ) ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 20 BOLD ;
         fontcolor { 0, 106, 53 } transparent
              /*
                rodapé
              */
      DEFINE LABEL linha_rodape_2
         COL 000
         ROW form_acompanhamento.HEIGHT -090
         VALUE ''
         WIDTH form_acompanhamento.WIDTH
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL
              /*
                botões
              */
      DEFINE BUTTONEX button_imprime
         PICTURE 'imprimir'
         COL form_acompanhamento.WIDTH -370
         ROW form_acompanhamento.HEIGHT -085
         WIDTH 140
         HEIGHT 050
         CAPTION 'Imprime OS'
         ACTION imprime_os_2( _numero_os )
         FONTBOLD .T.
         TOOLTIP 'Imprimir esta Ordem de Serviço'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_ok
         COL form_acompanhamento.WIDTH -225
         ROW form_acompanhamento.HEIGHT -085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Encerrar OS'
         ACTION encerrar_os()
         FONTBOLD .T.
         FONTCOLOR WHITE
         BACKCOLOR RED
         TOOLTIP 'Encerrar OS'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE 'img_voltar'
         COL form_acompanhamento.WIDTH -100
         ROW form_acompanhamento.HEIGHT -085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_acompanhamento.RELEASE
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela sem gravar informações'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.RELEASE

   END WINDOW

   form_acompanhamento.CENTER
   form_acompanhamento.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Filtra_OS()

   LOCAL oQuery
   LOCAL oRow := {}

   LOCAL chave
   LOCAL cNome_Anterior := Space( 40 )

   IF form_acompanhamento.cbo_001.VALUE == 1 // nº da OS

      chave := AllTrim( form_acompanhamento.txt_pesquisa.value )
      oQuery := oServer:Query( 'select id,numero,data,hora,aparelho,numero_serie,marca,modelo,nome_cliente from os where numero = ' + chave + ' and encerrado = 0 order by numero' )
      IF oQuery:Eof()
         msgstop( 'Este Nº de OS não existe', 'Atenção' )
         form_acompanhamento.txt_pesquisa.setfocus
         return( nil )
      ELSE
         oRow := oQuery:GetRow( 1 )
         nNumOS := Str( oRow:fieldGet( 2 ) )
         DELETE ITEM ALL FROM grid_os OF form_acompanhamento
         add ITEM { Str( oRow:fieldGet( 1 ) ), Str( oRow:fieldGet( 2 ) ), DToC( oRow:fieldGet( 3 ) ), oRow:fieldGet( 4 ), oRow:fieldGet( 5 ), oRow:fieldGet( 6 ), oRow:fieldGet( 7 ), oRow:fieldGet( 8 ), oRow:fieldGet( 9 ) } TO grid_os OF form_acompanhamento
         form_acompanhamento.lbl_nome_cliente.VALUE := AllTrim( oRow:fieldGet( 9 ) )
      ENDIF
      oQuery:Destroy()

   ELSEIF form_acompanhamento.cbo_001.VALUE == 2 // nome do cliente

      chave := '"' + Upper( AllTrim( form_acompanhamento.txt_pesquisa.value ) ) + '%"'
      oQuery := oServer:Query( 'select id,numero,data,hora,aparelho,numero_serie,marca,modelo,nome_cliente from os where nome_cliente like ' + chave + ' and encerrado = 0 order by nome_cliente' )
      IF oQuery:Eof()
         msgstop( 'Não existe(m) OS(s) para este Cliente', 'Atenção' )
         form_acompanhamento.txt_pesquisa.setfocus
         return( nil )
      ELSE
         oRow := oQuery:GetRow( 1 )
         cNome_Anterior := Upper( AllTrim( oRow:fieldGet( 9 ) ) )
         DELETE ITEM ALL FROM grid_os OF form_acompanhamento
         n_conta := 1
         WHILE .NOT. oQuery:Eof()
            oRow := oQuery:GetRow( n_conta )
            add ITEM { Str( oRow:fieldGet( 1 ) ), Str( oRow:fieldGet( 2 ) ), DToC( oRow:fieldGet( 3 ) ), AllTrim( oRow:fieldGet( 4 ) ), AllTrim( oRow:fieldGet( 5 ) ), AllTrim( oRow:fieldGet( 6 ) ), AllTrim( oRow:fieldGet( 7 ) ), AllTrim( oRow:fieldGet( 8 ) ), AllTrim( oRow:fieldGet( 9 ) ) } TO grid_os OF form_acompanhamento
            oQuery:Skip( 1 )
            n_conta++
            IF AllTrim( oRow:fieldGet( 9 ) ) <> cNome_Anterior
               EXIT
            ENDIF
         END
      ENDIF
      oQuery:Destroy()

   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION servico_excluir_2()

   LOCAL cQuery, cQuery_1
   LOCAL oQuery, oQuery_1
   LOCAL oRow_1
   LOCAL n_i := 0
   LOCAL nSub_Total := 0

   LOCAL v_id := AllTrim( valor_coluna( 'grid_servicos', 'form_acompanhamento', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_servicos', 'form_acompanhamento', 2 ) )

   IF Empty( v_id )
      msginfo( 'Faça uma pesquisa antes, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Confirma a exclusão de : ' + v_nome + ' ?' )
      cQuery := 'delete from os_servicos where id = ' + v_id
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Exclusão : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
    /*
      atualizar informações
    */
      oQuery_1 := oServer:Query( 'select * from os_servicos where numero_os = ' + _numero_os )
      IF oQuery_1:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery_1:Error() )
         return( nil )
      ELSE
         DELETE ITEM ALL FROM grid_servicos OF form_acompanhamento
         FOR n_i := 1 TO oQuery_1:LastRec()
            oRow_1 := oQuery_1:GetRow( n_i )
            nSub_Total := ( oRow_1:fieldGet( 7 ) * oRow_1:fieldGet( 6 ) )
            add ITEM { AllTrim( Str( oRow_1:fieldGet( 1 ) ) ), AllTrim( oRow_1:fieldGet( 5 ) ), Str( oRow_1:fieldGet( 6 ), 4 ), trans( oRow_1:fieldGet( 7 ), '@E 9,999.99' ), trans( nSub_Total, '@E 99,999.99' ), AllTrim( Str( oRow_1:fieldGet( 9 ) ) ) } TO grid_servicos OF form_acompanhamento
            oQuery_1:Skip( 1 )
         NEXT n_i
         oQuery_1:Destroy()
      ENDIF
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION servico_incluir_2( p_numero_os )

   DEFINE WINDOW form_inclui_servico ;
         AT 0, 0 ;
         WIDTH 280 ;
         HEIGHT 225 ;
         TITLE 'Incluir Serviço' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

     /*
       label
     */
      @ 010, 010 LABEL lbl_servico ;
         VALUE 'Serviço' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 060, 010 LABEL lbl_quantidade ;
         VALUE 'QTD' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 060, 120 LABEL lbl_unitario ;
         VALUE 'UNIT.R$' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 110, 010 LABEL lbl_tecnico ;
         VALUE 'Técnico' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 030, 080 LABEL lbl_nome_servico ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR BLUE transparent
      @ 130, 080 LABEL lbl_nome_tecnico ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR BLUE transparent

     /*
       textbox
     */
      @ 030, 010 TEXTBOX tbox_servico ;
         WIDTH 50 ;
         VALUE 0 ;
         NUMERIC ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON enter pesq_servico()
      @ 080, 010 TEXTBOX txt_quantidade ;
         WIDTH 100 ;
         VALUE 0 ;
         NUMERIC INPUTMASK '999999'
      @ 080, 120 TEXTBOX txt_unitario ;
         WIDTH 100 ;
         VALUE 0 ;
         NUMERIC INPUTMASK '9,999.99'
      @ 130, 010 TEXTBOX tbox_tecnico ;
         WIDTH 50 ;
         VALUE 0 ;
         NUMERIC ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON enter pesq_tecnico()

      DEFINE BUTTONEX btn_grava
         ROW 160
         COL 086
         WIDTH 080
         HEIGHT 030
         CAPTION 'Gravar'
         PICTURE 'ok'
         FONTBOLD .T.
         lefttext .F.
         ACTION ( grava_servico( p_numero_os ), form_inclui_servico.tbox_servico.setfocus )
      END BUTTONEX
      DEFINE BUTTONEX btn_cancela
         ROW 160
         COL 170
         WIDTH 100
         HEIGHT 030
         CAPTION 'Cancelar'
         PICTURE 'cancela'
         FONTBOLD .T.
         lefttext .F.
         ACTION form_inclui_servico.RELEASE
      END BUTTONEX

   END WINDOW

   form_inclui_servico.tbox_servico.setfocus
   form_inclui_servico.CENTER
   form_inclui_servico.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesq_servico()

   LOCAL x_servico := form_inclui_servico.tbox_servico.VALUE
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}
   LOCAL x_2 := '2'

   IF x_servico <> 0
      oQuery := oServer:Query( "select id,nome,preco from produtos where id='" + AllTrim( Str( x_servico ) ) + "' and tipo='" + x_2 + "' order by nome" )
      IF oQuery:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 2 ) )
      m_nome_servico := x_nome
      SetProperty( 'form_inclui_servico', 'lbl_nome_servico', 'value', x_nome )
      SetProperty( 'form_inclui_servico', 'txt_unitario', 'value', oRow:fieldGet( 3 ) )
      return( nil )
   ENDIF

   DEFINE WINDOW form_pesquisa ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 400 ;
         TITLE 'Pesquisa Serviço' ;
         ICON 'icone' ;
         modal ;
         NOSIZE ;
         ON INIT alimenta_pesquisa_2()

      DEFINE GRID grid_pesquisa
         parent form_pesquisa
         COL 0
         ROW 0
         WIDTH form_pesquisa.WIDTH
         HEIGHT form_pesquisa.HEIGHT
         HEADERS { 'Cód.', 'Nome' }
         WIDTHS { 50, 400 }
         FONTNAME 'verdana'
         FONTSIZE 10
         BACKCOLOR WHITE
         FONTCOLOR { 0, 0, 0 }
         ondblclick passa_pesquisa_2()
      END GRID

      ON KEY ESCAPE ACTION form_pesquisa.RELEASE

   END WINDOW

   form_pesquisa.CENTER
   form_pesquisa.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION grava_servico( p_numero_os )

   LOCAL cQuery
   LOCAL oQuery

   LOCAL x_1 := AllTrim( Str( form_inclui_servico.tbox_servico.value ) )
   LOCAL x_2 := AllTrim( Str( form_inclui_servico.txt_quantidade.value ) )
   LOCAL x_3 := AllTrim( Str( form_inclui_servico.txt_unitario.VALUE, 12, 2 ) )
   LOCAL x_4 := AllTrim( Str( form_inclui_servico.tbox_tecnico.value ) )

   LOCAL n_quantidade := form_inclui_servico.txt_quantidade.VALUE
   LOCAL n_unitario := form_inclui_servico.txt_unitario.VALUE
   LOCAL n_subtotal := ( n_quantidade * n_unitario )

   IF x_1 == '0'
      msginfo( 'Obrigatório preencher os campos', 'Atenção' )
      return( nil )
   ELSE
      cQuery := "insert into os_servicos (numero_os,servico,nome_servico,quantidade,unitario,subtotal,tecnico,data) values ('"
      cQuery += p_numero_os + "','"
      cQuery += x_1 + "','"
      cQuery += m_nome_servico + "','"
      cQuery += x_2 + "','"
      cQuery += x_3 + "','"
      cQuery += AllTrim( Str( n_subtotal, 12, 2 ) ) + "','"
      cQuery += x_4 + "','"
      cQuery += td( Date() ) + "')"

      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Inclusão : ' + oQuery:Error() )
         return( nil )
      ENDIF

      oQuery:Destroy()

      add ITEM { AllTrim( p_numero_os ), m_nome_servico, Str( form_inclui_servico.txt_quantidade.VALUE, 4 ), trans( form_inclui_servico.txt_unitario.VALUE, '@E 9,999.99' ), trans( n_subtotal, '@E 99,999.99' ), x_4 } TO grid_servicos OF form_acompanhamento

      n_soma_total := n_soma_total + n_subtotal
      SetProperty( 'form_acompanhamento', 'lbl_total_os', 'value', trans( n_soma_total, '@E 999,999.99' ) )
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION alimenta_pesquisa_2()

   LOCAL i := 0
   LOCAL oQuery
   LOCAL oRow := {}
   LOCAL x_2 := '2'

   oQuery := oServer:Query( "select id,nome from produtos where tipo='" + x_2 + "' order by nome" )

   FOR i := 1 TO oQuery:LastRec()
      oRow := oQuery:GetRow( i )
      add ITEM { AllTrim( Str( oRow:fieldGet( 1 ), 6 ) ), AllTrim( oRow:fieldGet( 2 ) ) } TO grid_pesquisa OF form_pesquisa
      oQuery:Skip( 1 )
   NEXT i

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION passa_pesquisa_2()

   LOCAL v_id := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 2 ) )

   LOCAL x_servico := Val( v_id )
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}
   LOCAL x_2 := '2'

   oQuery := oServer:Query( "select id,nome,preco from produtos where id='" + AllTrim( Str( x_servico ) ) + "' and tipo='" + x_2 + "' order by nome" )
   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ENDIF
   oRow := oQuery:GetRow( 1 )
   x_nome := AllTrim( oRow:fieldGet( 2 ) )
   m_nome_servico := x_nome
   SetProperty( 'form_inclui_servico', 'tbox_servico', 'value', Val( v_id ) )
   SetProperty( 'form_inclui_servico', 'lbl_nome_servico', 'value', x_nome )
   SetProperty( 'form_inclui_servico', 'txt_unitario', 'value', oRow:fieldGet( 3 ) )

   form_pesquisa.RELEASE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesq_tecnico()

   LOCAL x_servico := form_inclui_servico.tbox_tecnico.VALUE
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}

   IF x_servico <> 0
      oQuery := oServer:Query( "select id,nome from funcionarios order by nome" )
      IF oQuery:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 2 ) )
      m_nome_tecnico := x_nome
      SetProperty( 'form_inclui_servico', 'lbl_nome_tecnico', 'value', x_nome )
      return( nil )
   ENDIF

   DEFINE WINDOW form_pesquisa ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 400 ;
         TITLE 'Pesquisa Técnico' ;
         ICON 'icone' ;
         modal ;
         NOSIZE ;
         ON INIT alimenta_pesquisa_3()

      DEFINE GRID grid_pesquisa
         parent form_pesquisa
         COL 0
         ROW 0
         WIDTH form_pesquisa.WIDTH
         HEIGHT form_pesquisa.HEIGHT
         HEADERS { 'Cód.', 'Nome' }
         WIDTHS { 50, 400 }
         FONTNAME 'verdana'
         FONTSIZE 10
         BACKCOLOR WHITE
         FONTCOLOR { 0, 0, 0 }
         ondblclick passa_pesquisa_3()
      END GRID

      ON KEY ESCAPE ACTION form_pesquisa.RELEASE

   END WINDOW

   form_pesquisa.CENTER
   form_pesquisa.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION alimenta_pesquisa_3()

   LOCAL i := 0
   LOCAL oQuery
   LOCAL oRow := {}

   oQuery := oServer:Query( "select id,nome from funcionarios order by nome" )

   FOR i := 1 TO oQuery:LastRec()
      oRow := oQuery:GetRow( i )
      add ITEM { AllTrim( Str( oRow:fieldGet( 1 ), 6 ) ), AllTrim( oRow:fieldGet( 2 ) ) } TO grid_pesquisa OF form_pesquisa
      oQuery:Skip( 1 )
   NEXT i

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION passa_pesquisa_3()

   LOCAL v_id := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 2 ) )

   LOCAL x_servico := Val( v_id )
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}

   oQuery := oServer:Query( "select id,nome from funcionarios order by nome" )
   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ENDIF
   oRow := oQuery:GetRow( 1 )
   x_nome := AllTrim( oRow:fieldGet( 2 ) )
   m_nome_tecnico := x_nome
   SetProperty( 'form_inclui_servico', 'tbox_tecnico', 'value', Val( v_id ) )
   SetProperty( 'form_inclui_servico', 'lbl_nome_tecnico', 'value', x_nome )

   form_pesquisa.RELEASE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pecas_excluir_2()

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_id := AllTrim( valor_coluna( 'grid_pecas', 'form_acompanhamento', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_pecas', 'form_acompanhamento', 2 ) )

   IF Empty( v_id )
      msginfo( 'Faça uma pesquisa antes, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Confirma a exclusão de : ' + v_nome + ' ?' )
      cQuery := 'delete from os_pecas where id = ' + v_id
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Exclusão : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
      msginfo( 'A informação : ' + v_nome + ' - foi excluída' )
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pecas_incluir_2( p_numero_os )

   DEFINE WINDOW form_inclui_peca ;
         AT 0, 0 ;
         WIDTH 280 ;
         HEIGHT 225 ;
         TITLE 'Incluir Peças' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

     /*
       label
     */
      @ 010, 010 LABEL lbl_peca ;
         VALUE 'Peça' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 060, 010 LABEL lbl_quantidade ;
         VALUE 'QTD' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 060, 120 LABEL lbl_unitario ;
         VALUE 'UNIT.R$' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 110, 010 LABEL lbl_tecnico ;
         VALUE 'Técnico' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 030, 080 LABEL lbl_nome_peca ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR BLUE transparent
      @ 130, 080 LABEL lbl_nome_tecnico ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR BLUE transparent

     /*
       textbox
     */
      @ 030, 010 TEXTBOX tbox_peca ;
         WIDTH 50 ;
         VALUE 0 ;
         NUMERIC ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON enter pesq_peca()
      @ 080, 010 TEXTBOX txt_quantidade ;
         WIDTH 100 ;
         VALUE 0 ;
         NUMERIC INPUTMASK '999999'
      @ 080, 120 TEXTBOX txt_unitario ;
         WIDTH 100 ;
         VALUE 0 ;
         NUMERIC INPUTMASK '9,999.99'
      @ 130, 010 TEXTBOX tbox_tecnico ;
         WIDTH 50 ;
         VALUE 0 ;
         NUMERIC ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON enter pesq_tecnico_2()

      DEFINE BUTTONEX btn_grava
         ROW 160
         COL 086
         WIDTH 080
         HEIGHT 030
         CAPTION 'Gravar'
         PICTURE 'ok'
         FONTBOLD .T.
         lefttext .F.
         ACTION ( grava_peca( p_numero_os ), form_inclui_peca.tbox_peca.setfocus )
      END BUTTONEX
      DEFINE BUTTONEX btn_cancela
         ROW 160
         COL 170
         WIDTH 100
         HEIGHT 030
         CAPTION 'Cancelar'
         PICTURE 'cancela'
         FONTBOLD .T.
         lefttext .F.
         ACTION form_inclui_peca.RELEASE
      END BUTTONEX

   END WINDOW

   form_inclui_peca.tbox_peca.setfocus
   form_inclui_peca.CENTER
   form_inclui_peca.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION grava_peca( p_numero_os )

   LOCAL cQuery
   LOCAL oQuery

   LOCAL x_1 := AllTrim( Str( form_inclui_peca.tbox_peca.value ) )
   LOCAL x_2 := AllTrim( Str( form_inclui_peca.txt_quantidade.value ) )
   LOCAL x_3 := AllTrim( Str( form_inclui_peca.txt_unitario.VALUE, 12, 2 ) )
   LOCAL x_4 := AllTrim( Str( form_inclui_peca.tbox_tecnico.value ) )

   LOCAL n_quantidade := form_inclui_peca.txt_quantidade.VALUE
   LOCAL n_unitario := form_inclui_peca.txt_unitario.VALUE
   LOCAL n_subtotal := ( n_quantidade * n_unitario )

   IF x_1 == '0'
      msginfo( 'Obrigatório preencher os campos', 'Atenção' )
      return( nil )
   ELSE
      cQuery := "insert into os_pecas (numero_os,peca,nome_peca,quantidade,unitario,subtotal,tecnico,data) values ('"
      cQuery += p_numero_os + "','"
      cQuery += x_1 + "','"
      cQuery += m_nome_peca + "','"
      cQuery += x_2 + "','"
      cQuery += x_3 + "','"
      cQuery += AllTrim( Str( n_subtotal, 12, 2 ) ) + "','"
      cQuery += x_4 + "','"
      cQuery += td( Date() ) + "')"

      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Inclusão : ' + oQuery:Error() )
         return( nil )
      ENDIF

      oQuery:Destroy()

      add ITEM { AllTrim( p_numero_os ), m_nome_peca, Str( form_inclui_peca.txt_quantidade.VALUE, 4 ), trans( form_inclui_peca.txt_unitario.VALUE, '@E 9,999.99' ), trans( n_subtotal, '@E 99,999.99' ), x_4 } TO grid_pecas OF form_acompanhamento

      n_soma_total := n_soma_total + n_subtotal
      SetProperty( 'form_acompanhamento', 'lbl_total_os', 'value', trans( n_soma_total, '@E 999,999.99' ) )
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesq_peca()

   LOCAL x_peca := form_inclui_peca.tbox_peca.VALUE
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}
   LOCAL x_2 := '1'

   IF x_peca <> 0
      oQuery := oServer:Query( "select id,nome,preco from produtos where id='" + AllTrim( Str( x_peca ) ) + "' and tipo='" + x_2 + "' order by nome" )
      IF oQuery:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 2 ) )
      m_nome_peca := x_nome
      SetProperty( 'form_inclui_peca', 'lbl_nome_peca', 'value', x_nome )
      SetProperty( 'form_inclui_peca', 'txt_unitario', 'value', oRow:fieldGet( 3 ) )
      return( nil )
   ENDIF

   DEFINE WINDOW form_pesquisa ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 400 ;
         TITLE 'Pesquisa Peça' ;
         ICON 'icone' ;
         modal ;
         NOSIZE ;
         ON INIT alimenta_pesquisa_4()

      DEFINE GRID grid_pesquisa
         parent form_pesquisa
         COL 0
         ROW 0
         WIDTH form_pesquisa.WIDTH
         HEIGHT form_pesquisa.HEIGHT
         HEADERS { 'Cód.', 'Nome' }
         WIDTHS { 50, 400 }
         FONTNAME 'verdana'
         FONTSIZE 10
         BACKCOLOR WHITE
         FONTCOLOR { 0, 0, 0 }
         ondblclick passa_pesquisa_4()
      END GRID

      ON KEY ESCAPE ACTION form_pesquisa.RELEASE

   END WINDOW

   form_pesquisa.CENTER
   form_pesquisa.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION alimenta_pesquisa_4()

   LOCAL i := 0
   LOCAL oQuery
   LOCAL oRow := {}
   LOCAL x_2 := '1'

   oQuery := oServer:Query( "select id,nome from produtos where tipo='" + x_2 + "' order by nome" )

   FOR i := 1 TO oQuery:LastRec()
      oRow := oQuery:GetRow( i )
      add ITEM { AllTrim( Str( oRow:fieldGet( 1 ), 6 ) ), AllTrim( oRow:fieldGet( 2 ) ) } TO grid_pesquisa OF form_pesquisa
      oQuery:Skip( 1 )
   NEXT i

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION passa_pesquisa_4()

   LOCAL v_id := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 2 ) )

   LOCAL x_peca := Val( v_id )
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}
   LOCAL x_2 := '1'

   oQuery := oServer:Query( "select id,nome,preco from produtos where id='" + AllTrim( Str( x_peca ) ) + "' and tipo='" + x_2 + "' order by nome" )
   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ENDIF
   oRow := oQuery:GetRow( 1 )
   x_nome := AllTrim( oRow:fieldGet( 2 ) )
   m_nome_peca := x_nome
   SetProperty( 'form_inclui_peca', 'tbox_peca', 'value', Val( v_id ) )
   SetProperty( 'form_inclui_peca', 'lbl_nome_peca', 'value', x_nome )
   SetProperty( 'form_inclui_peca', 'txt_unitario', 'value', oRow:fieldGet( 3 ) )

   form_pesquisa.RELEASE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesq_tecnico_2()

   LOCAL x_servico := form_inclui_peca.tbox_tecnico.VALUE
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}

   IF x_servico <> 0
      oQuery := oServer:Query( "select id,nome from funcionarios order by nome" )
      IF oQuery:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 2 ) )
      m_nome_tecnico := x_nome
      SetProperty( 'form_inclui_peca', 'lbl_nome_tecnico', 'value', x_nome )
      return( nil )
   ENDIF

   DEFINE WINDOW form_pesquisa ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 400 ;
         TITLE 'Pesquisa Técnico' ;
         ICON 'icone' ;
         modal ;
         NOSIZE ;
         ON INIT alimenta_pesquisa_5()

      DEFINE GRID grid_pesquisa
         parent form_pesquisa
         COL 0
         ROW 0
         WIDTH form_pesquisa.WIDTH
         HEIGHT form_pesquisa.HEIGHT
         HEADERS { 'Cód.', 'Nome' }
         WIDTHS { 50, 400 }
         FONTNAME 'verdana'
         FONTSIZE 10
         BACKCOLOR WHITE
         FONTCOLOR { 0, 0, 0 }
         ondblclick passa_pesquisa_5()
      END GRID

      ON KEY ESCAPE ACTION form_pesquisa.RELEASE

   END WINDOW

   form_pesquisa.CENTER
   form_pesquisa.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION alimenta_pesquisa_5()

   LOCAL i := 0
   LOCAL oQuery
   LOCAL oRow := {}

   oQuery := oServer:Query( "select id,nome from funcionarios order by nome" )

   FOR i := 1 TO oQuery:LastRec()
      oRow := oQuery:GetRow( i )
      add ITEM { AllTrim( Str( oRow:fieldGet( 1 ), 6 ) ), AllTrim( oRow:fieldGet( 2 ) ) } TO grid_pesquisa OF form_pesquisa
      oQuery:Skip( 1 )
   NEXT i

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION passa_pesquisa_5()

   LOCAL v_id := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 2 ) )

   LOCAL x_servico := Val( v_id )
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}

   oQuery := oServer:Query( "select id,nome from funcionarios order by nome" )
   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ENDIF
   oRow := oQuery:GetRow( 1 )
   x_nome := AllTrim( oRow:fieldGet( 2 ) )
   m_nome_tecnico := x_nome
   SetProperty( 'form_inclui_peca', 'tbox_tecnico', 'value', Val( v_id ) )
   SetProperty( 'form_inclui_peca', 'lbl_nome_tecnico', 'value', x_nome )

   form_pesquisa.RELEASE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION imprime_os_2( p_numero_os )

   LOCAL oQuery, oQuery_1, oQuery_2, oQuery_3
   LOCAL n_i := 0
   LOCAL oRow := {}
   LOCAL oRow_1 := {}
   LOCAL oRow_2 := {}
   LOCAL oRow_3 := {}

   LOCAL n_linha := 50

   LOCAL nCod_Cliente := 0
   LOCAL nSub_Servico := 0
   LOCAL nTot_Servico := 0
   LOCAL nSub_Peca := 0
   LOCAL nTot_Peca := 0
   LOCAL nTotal_OS := 0

   LOCAL v_id_cliente

   IF Empty( p_numero_os )
      return( nil )
   ENDIF

    /*
      seleciona OS
    */
   oQuery := oServer:Query( "select * from os where numero = '" + p_numero_os + "' order by data" )
   oRow := oQuery:GetRow( 1 )
   v_id_cliente := AllTrim( Str( oRow:fieldGet( 5 ) ) )
    /*
      seleciona cliente
    */
   oQuery_3 := oServer:Query( "select * from clientes where id = '" + v_id_cliente + "' order by id" )
   oRow_3 := oQuery_3:GetRow( 1 )

   SELECT PRINTER DIALOG PREVIEW
   START PRINTDOC NAME 'Gerenciador de impressão'
   START PRINTPAGE

   cabecalho_os( p_numero_os )

   @ n_linha, 020 PRINT 'Data/Hora Atendimento' FONT 'courier new' SIZE 10
   @ n_linha, 100 PRINT 'Data/Hora Previsão Entrega' FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 020 PRINT DToC( oRow:fieldGet( 3 ) ) + ' / ' + oRow:fieldGet( 4 ) FONT 'courier new' SIZE 10 BOLD
   @ n_linha, 100 PRINT DToC( oRow:fieldGet( 11 ) ) + ' / ' + AllTrim( oRow:fieldGet( 12 ) ) FONT 'courier new' SIZE 10 BOLD

   n_linha += 8

   @ n_linha, 020 PRINT 'DADOS DO CLIENTE' FONT 'courier new' SIZE 10 BOLD
   n_linha += 6
   @ n_linha, 040 PRINT AllTrim( oRow_3:fieldGet( 5 ) ) FONT 'courier new' SIZE 10 BOLD
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( oRow_3:fieldGet( 8 ) ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( oRow_3:fieldGet( 11 ) ) + ' - ' + AllTrim( oRow_3:fieldGet( 12 ) ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( oRow_3:fieldGet( 10 ) ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( oRow_3:fieldGet( 6 ) ) + ' - ' + AllTrim( oRow_3:fieldGet( 7 ) ) FONT 'courier new' SIZE 10

   n_linha += 5
   @ n_linha, 010 PRINT LINE TO n_linha, 205 PENWIDTH 0.5 COLOR _preto_001
   n_linha += 5

   @ n_linha, 040 PRINT 'Aparelho             : ' + AllTrim( oRow:fieldGet( 16 ) ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Marca                : ' + AllTrim( oRow:fieldGet( 17 ) ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Modelo               : ' + AllTrim( oRow:fieldGet( 18 ) ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Nº de Série          : ' + AllTrim( oRow:fieldGet( 19 ) ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Defeito Apresentado  : ' + AllTrim( oRow:fieldGet( 22 ) ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Estado do Aparelho   : ' + aEstado[ oRow:fieldGet( 20 ) ] FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Condição do Aparelho : ' + aCondicao[ oRow:fieldGet( 21 ) ] FONT 'courier new' SIZE 10

   n_linha += 5
   @ n_linha, 010 PRINT LINE TO n_linha, 205 PENWIDTH 0.5 COLOR _preto_001
   n_linha += 5
    /*
   serviços
    */
   @ n_linha, 020 PRINT 'SERVIÇOS' FONT 'courier new' SIZE 10 BOLD
   n_linha += 8
   @ n_linha, 020 PRINT 'Descrição' FONT 'courier new' SIZE 10 BOLD
   @ n_linha, 100 PRINT 'QTD.' FONT 'courier new' SIZE 10 BOLD
   @ n_linha, 130 PRINT 'Unitário R$' FONT 'courier new' SIZE 10 BOLD
   @ n_linha, 170 PRINT 'Sub-Total R$' FONT 'courier new' SIZE 10 BOLD
   n_linha += 5

   oQuery_1 := oServer:Query( "select nome_servico,quantidade,unitario,subtotal from os_servicos where numero_os = '" + p_numero_os + "' order by data" )
   IF oQuery_1:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery_1:Error() )
      return( nil )
   ENDIF
   IF oQuery_1:Eof()
      msginfo( 'Sua pesquisa não foi encontrada, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF
   n_total_servicos := 0
   FOR n_i := 1 TO oQuery_1:LastRec()
      oRow_1 := oQuery_1:GetRow( n_i )
      @ n_linha, 020 PRINT AllTrim( oRow_1:fieldGet( 1 ) ) FONT 'courier new' SIZE 010
      @ n_linha, 100 PRINT AllTrim( Str( oRow_1:fieldGet( 2 ) ) ) FONT 'courier new' SIZE 010
      @ n_linha, 130 PRINT trans( oRow_1:fieldGet( 3 ), '@E 999,999.99' ) FONT 'courier new' SIZE 010
      @ n_linha, 170 PRINT trans( oRow_1:fieldGet( 4 ), '@E 999,999.99' ) FONT 'courier new' SIZE 010
      n_total_servicos := ( n_total_servicos + oRow_1:fieldGet( 4 ) )
      n_linha += 5
      oQuery_1:Skip( 1 )
   NEXT n_i
   @ n_linha, 170 PRINT trans( n_total_servicos, '@E 999,999.99' ) FONT 'courier new' SIZE 010 BOLD
   oQuery_1:Destroy()

   n_linha += 10
   n_i := 0
    /*
      peças
    */
   @ n_linha, 020 PRINT 'PEÇAS' FONT 'courier new' SIZE 10 BOLD
   n_linha += 8
   @ n_linha, 020 PRINT 'Descrição' FONT 'courier new' SIZE 10 BOLD
   @ n_linha, 100 PRINT 'QTD.' FONT 'courier new' SIZE 10 BOLD
   @ n_linha, 130 PRINT 'Unitário R$' FONT 'courier new' SIZE 10 BOLD
   @ n_linha, 170 PRINT 'Sub-Total R$' FONT 'courier new' SIZE 10 BOLD
   n_linha += 5

   oQuery_2 := oServer:Query( "select nome_peca,quantidade,unitario,subtotal from os_pecas where numero_os = '" + p_numero_os + "' order by data" )
   IF oQuery_2:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery_2:Error() )
      return( nil )
   ENDIF
   IF oQuery_2:Eof()
      msginfo( 'Sua pesquisa não foi encontrada, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF
   n_total_pecas := 0
   FOR n_i := 1 TO oQuery_2:LastRec()
      oRow_2 := oQuery_2:GetRow( n_i )
      @ n_linha, 020 PRINT AllTrim( oRow_2:fieldGet( 1 ) ) FONT 'courier new' SIZE 010
      @ n_linha, 100 PRINT AllTrim( Str( oRow_2:fieldGet( 2 ) ) ) FONT 'courier new' SIZE 010
      @ n_linha, 130 PRINT trans( oRow_2:fieldGet( 3 ), '@E 999,999.99' ) FONT 'courier new' SIZE 010
      @ n_linha, 170 PRINT trans( oRow_2:fieldGet( 4 ), '@E 999,999.99' ) FONT 'courier new' SIZE 010
      n_total_pecas := ( n_total_pecas + oRow_2:fieldGet( 4 ) )
      n_linha += 5
      oQuery_2:Skip( 1 )
   NEXT n_i
   @ n_linha, 170 PRINT trans( n_total_pecas, '@E 999,999.99' ) FONT 'courier new' SIZE 010 BOLD
   oQuery_2:Destroy()

   n_linha += 8
   @ n_linha, 140 PRINT 'TOTAL DA OS :' FONT 'courier new' SIZE 010 BOLD
   @ n_linha, 170 PRINT trans( n_total_servicos + n_total_pecas, '@E 999,999.99' ) FONT 'courier new' SIZE 010 BOLD

   n_linha += 30

   @ n_linha, 070 PRINT LINE TO n_linha, 205 PENWIDTH 0.5 COLOR _preto_001
   n_linha += 3
   @ n_linha, 120 PRINT 'Assinatura do Cliente' FONT 'courier new' SIZE 10

   rodape()

   END PRINTPAGE
   END PRINTDOC

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION cabecalho_os( p_numero_os )

   @ 007, 010 PRINT IMAGE 'logotipo' WIDTH 030 HEIGHT 025 STRETCH
   @ 010, 050 PRINT 'Empresa Teste & Teste Ltda' FONT 'verdana' SIZE 012 BOLD
   @ 015, 050 PRINT 'CNPJ : 99.999.999/9999-99 - Insc.Estadual : 154954554620-XX' FONT 'verdana' SIZE 010
   @ 018, 050 PRINT 'Rua Mal Floriano Peixoto, 8437 - Centro - São Paulo/SP' FONT 'verdana' SIZE 010
   @ 021, 050 PRINT 'Telefone : (11) 9999-9999 - empresateste@empresa.com.br' FONT 'verdana' SIZE 010

   @ 030, 000 PRINT LINE TO 030, 205 PENWIDTH 0.5 COLOR _preto_001

   @ 037, 040 PRINT 'ORDEM DE SERVIÇO Nº : ' + AllTrim( p_numero_os ) FONT 'verdana' SIZE 018 BOLD

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION rodape()

   @ 275, 000 PRINT LINE TO 275, 205 PENWIDTH 0.5 COLOR _preto_001
   @ 276, 010 PRINT 'impresso em ' + DToC( Date() ) + ' as ' + Time() FONT 'courier new' SIZE 008

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Inserir_Datas()

   LOCAL x_data_saida, x_hora_saida, x_data_garantia

   LOCAL cQuery
   LOCAL oQuery
   LOCAL oRow

   LOCAL nCodigo := AllTrim( valor_coluna( 'grid_os', 'form_acompanhamento', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_os', 'form_acompanhamento', 9 ) )

   IF Empty( nCodigo )
      msginfo( 'Faça uma pesquisa antes, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   oQuery := oServer:Query( 'select * from os where id = ' + nCodigo )
   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ELSE
      oRow := oQuery:GetRow( 1 )
      x_data_saida := oRow:fieldGet( 13 )
      x_hora_saida := AllTrim( oRow:fieldGet( 14 ) )
      x_data_garantia := oRow:fieldGet( 15 )
      oQuery:Destroy()
   ENDIF

   DEFINE WINDOW form_data ;
         AT 000, 000 ;
         WIDTH 250 ;
         HEIGHT 200 ;
         TITLE 'Saída do aparelho' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      @ 010, 005 LABEL lbl_001 ;
         VALUE 'Data Entrega'
      @ 040, 005 LABEL lbl_002 ;
         VALUE 'Hora Entrega'
      @ 070, 005 LABEL lbl_003 ;
         VALUE 'Data Garantia' ;
         BOLD
      @ 010, 100 datepicker dpi_data_entrega ;
         WIDTH 100 ;
         VALUE x_data_saida
      @ 040, 100 TEXTBOX txt_hora_entrega ;
         WIDTH 45 ;
         VALUE x_hora_saida ;
         INPUTMASK '99:99'
      @ 070, 100 datepicker dpi_data_garantia ;
         WIDTH 100 ;
         VALUE x_data_garantia

      DEFINE BUTTONEX btn_grava
         COL form_data.WIDTH -225
         ROW form_data.HEIGHT -085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Gravar'
         PICTURE 'img_gravar'
         FONTBOLD .T.
         lefttext .F.
         ACTION Gravar_Datas( nCodigo )
      END BUTTONEX
      DEFINE BUTTONEX btn_cancela
         COL form_data.WIDTH -100
         ROW form_data.HEIGHT -085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         PICTURE 'img_voltar'
         FONTBOLD .T.
         lefttext .F.
         ACTION form_data.RELEASE
      END BUTTONEX

   END WINDOW

   form_data.CENTER
   form_data.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION gravar_datas( p_id )

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_data_entrega := form_data.dpi_data_entrega.VALUE
   LOCAL v_hora_entrega := AllTrim( form_data.txt_hora_entrega.value )
   LOCAL v_data_garantia := form_data.dpi_data_garantia.VALUE

   cQuery := "update os set "
   cQuery += "data_saida='" + td( v_data_entrega ) + "',"
   cQuery += "hora_saida='" + v_hora_entrega + "',"
   cQuery += "data_garantia='" + td( v_data_garantia ) + "'"
   cQuery += " where id='" + p_id + "'"

   oQuery := oQuery := oServer:Query( cQuery )

   IF oQuery:NetErr()
      msginfo( 'Erro na Alteração : ' + oQuery:Error() )
      return( nil )
   ENDIF

   oQuery:Destroy()

   form_data.RELEASE

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Mostra_Servicos_Pecas()

   LOCAL cQuery, cQuery_1, cQuery_2
   LOCAL oQuery, oQuery_1, oQuery_2
   LOCAL oRow, oRow_1, oRow_2

   LOCAL cNumero_OS := AllTrim( valor_coluna( 'grid_os', 'form_acompanhamento', 2 ) )
   LOCAL nSub_Total := 0
   LOCAL nTotal_servico := 0
   LOCAL nTotal_peca := 0

   LOCAL n_i := 0

   IF Empty( cNumero_OS )
      return( nil )
   ENDIF

   /*
     atribui o número da OS para variável pública
   */
   _numero_os := cNumero_OS

   /*
     pesquisa : os
   */
   oQuery := oServer:Query( 'select * from os where numero = ' + cNumero_OS )
   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ELSE
      oRow := oQuery:GetRow( 1 )
      form_acompanhamento.lbl_nome_cliente.VALUE := AllTrim( oRow:fieldGet( 6 ) )
      form_acompanhamento.lbl_data_hora_previsao.VALUE := DToC( oRow:fieldGet( 11 ) ) + ' - ' + SubStr( oRow:fieldGet( 12 ), 1, 5 )
      IF oRow:fieldGet( 24 ) == 2
         form_acompanhamento.lbl_encerrada.VALUE := 'ENCERRADA'
         lEncerrada := .T.
      ELSE
         form_acompanhamento.lbl_encerrada.VALUE := ''
         lEncerrada := .F.
      ENDIF
      oQuery:Destroy()
   ENDIF
   /*
     pesquisa : serviço os
   */
   oQuery_1 := oServer:Query( 'select * from os_servicos where numero_os = ' + cNumero_OS )
   IF oQuery_1:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery_1:Error() )
      return( nil )
   ELSE
      DELETE ITEM ALL FROM grid_servicos OF form_acompanhamento
      FOR n_i := 1 TO oQuery_1:LastRec()
         oRow_1 := oQuery_1:GetRow( n_i )
         nSub_Total := ( oRow_1:fieldGet( 7 ) * oRow_1:fieldGet( 6 ) )
         nTotal_servico := ( nTotal_servico + nSub_Total )
         add ITEM { AllTrim( Str( oRow_1:fieldGet( 1 ) ) ), AllTrim( oRow_1:fieldGet( 5 ) ), Str( oRow_1:fieldGet( 6 ), 4 ), trans( oRow_1:fieldGet( 7 ), '@E 9,999.99' ), trans( nSub_Total, '@E 99,999.99' ), AllTrim( Str( oRow_1:fieldGet( 9 ) ) ) } TO grid_servicos OF form_acompanhamento
         oQuery_1:Skip( 1 )
      NEXT n_i
      oQuery_1:Destroy()
   ENDIF
         /*
           zera variável
         */
   n_i := 0
   /*
     pesquisa : peças
   */
   oQuery_2 := oServer:Query( 'select * from os_pecas where numero_os = ' + cNumero_OS )
   IF oQuery_2:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery_2:Error() )
      return( nil )
   ELSE
      DELETE ITEM ALL FROM grid_pecas OF form_acompanhamento
      FOR n_i := 1 TO oQuery_2:LastRec()
         oRow_2 := oQuery_2:GetRow( n_i )
         nSub_Total := ( oRow_2:fieldGet( 7 ) * oRow_2:fieldGet( 6 ) )
         nTotal_peca := ( nTotal_peca + nSub_Total )
         add ITEM { AllTrim( Str( oRow_2:fieldGet( 1 ) ) ), AllTrim( oRow_2:fieldGet( 5 ) ), Str( oRow_2:fieldGet( 6 ), 4 ), trans( oRow_2:fieldGet( 7 ), '@E 9,999.99' ), trans( nSub_Total, '@E 99,999.99' ), AllTrim( Str( oRow_2:fieldGet( 9 ) ) ) } TO grid_pecas OF form_acompanhamento
         oQuery_2:Skip( 1 )
      NEXT n_i
      oQuery_2:Destroy()
   ENDIF

   n_soma_total := ( nTotal_servico + nTotal_peca )

   lLog_IAE := .T.
   SetProperty( 'form_acompanhamento', 'lbl_total_os', 'value', trans( n_soma_total, '@E 999,999.99' ) )

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION encerrar_os()

   LOCAL nCodigo_Confirma := hb_Random( 1649738, 9999999 )

   LOCAL nNumOS := AllTrim( valor_coluna( 'grid_os', 'form_acompanhamento', 2 ) )

   if ! lLog_IAE
      msgexclamation( 'Selecione uma OS primeiro', 'Atenção' )
      return( nil )
   ENDIF

   DEFINE WINDOW form_encerra ;
         AT 000, 000 ;
         WIDTH 260 ;
         HEIGHT 160 ;
         TITLE 'Encerrar OS' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      @ 005, 005 LABEL lbl_001 ;
         WIDTH 170 ;
         VALUE 'Digite aqui o código ao lado'
      @ 030, 005 TEXTBOX txt_digita ;
         WIDTH 100 ;
         MAXLENGTH 10 ;
         UPPERCASE
      @ 030, 150 LABEL lbl_codigo_confirma ;
         VALUE SubStr( AllTrim( Str( nCodigo_Confirma ) ), 1, 7 ) ;
         FONT 'verdana' SIZE 14 ;
         BOLD ;
         FONTCOLOR _AZUL_ESCURO

      DEFINE BUTTONEX btn_grava
         ROW 090
         COL 065
         WIDTH 080
         HEIGHT 030
         CAPTION 'Ok'
         FONTBOLD .T.
         lefttext .F.
         ACTION Grava_Encerra( SubStr( AllTrim( Str(nCodigo_Confirma ) ), 1, 7 ), nNumOS )
      END BUTTONEX
      DEFINE BUTTONEX btn_cancela
         ROW 090
         COL 150
         WIDTH 100
         HEIGHT 030
         CAPTION 'Cancelar'
         FONTBOLD .T.
         lefttext .F.
         ACTION form_encerra.RELEASE
      END BUTTONEX
   END WINDOW

   form_encerra.txt_digita.setfocus
   form_encerra.CENTER
   form_encerra.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION Grava_Encerra( cParametro, p_os )

   LOCAL v_os := AllTrim( p_os )
   LOCAL cQuery
   LOCAL oQuery
   LOCAL cDigitado := SubStr( AllTrim( form_encerra.txt_digita.value ), 1, 7 )

   IF cDigitado <> cParametro
      msgstop( 'O código digitado não corresponde ao fornecido pelo sistema', 'Atenção' )
      return( nil )
   ELSE
      cQuery := "update os set encerrado=1 where numero='" + v_os + "'"
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Alteração : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
      form_encerra.RELEASE
      DELETE ITEM ALL FROM grid_os OF form_acompanhamento
      DELETE ITEM ALL FROM grid_servicos OF form_acompanhamento
      DELETE ITEM ALL FROM grid_pecas OF form_acompanhamento
      SetProperty( 'form_acompanhamento', 'lbl_003', 'value', '' )
      SetProperty( 'form_acompanhamento', 'lbl_data_prevista', 'value', '' )
      SetProperty( 'form_acompanhamento', 'lbl_nome_cliente', 'value', '' )
      SetProperty( 'form_acompanhamento', 'lbl_data_hora_previsao', 'value', '' )
      SetProperty( 'form_acompanhamento', 'lbl_encerrada', 'value', '' )
      SetProperty( 'form_acompanhamento', 'lbl_total', 'value', '' )
      SetProperty( 'form_acompanhamento', 'lbl_total_os', 'value', '' )
      form_acompanhamento.txt_pesquisa.setfocus
   ENDIF

return( nil )
