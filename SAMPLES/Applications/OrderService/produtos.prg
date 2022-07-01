/*
  sistema     : ordem de serviço
  programa    : produtos
  compilador  : harbour
  lib gráfica : minigui extended
*/

#include 'minigui.ch'
#include 'miniprint.ch'

FUNCTION produtos()

   DEFINE WINDOW form_produtos ;
         AT 000, 000 ;
         WIDTH 800 ;
         HEIGHT 605 ;
         TITLE 'Produtos' ;
         ICON 'icone' ;
         modal ;
         NOSIZE ;
         ON INIT pesquisar()

      // botões (toolbar)
      DEFINE BUTTONEX button_incluir
         PICTURE 'img_inclui'
         COL 005
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'Incluir'
         ACTION dados( 1 )
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         FLAT .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_alterar
         PICTURE 'img_altera'
         COL 107
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'Alterar'
         ACTION dados( 2 )
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         FLAT .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_excluir
         PICTURE 'img_exclui'
         COL 209
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'Excluir'
         ACTION excluir()
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         FLAT .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_imprimir
         PICTURE 'img_imprime'
         COL 311
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'Imprimir'
         ACTION relacao()
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         FLAT .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_sair
         PICTURE 'img_sair'
         COL 413
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'ESC-Voltar'
         ACTION form_produtos.RELEASE
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         FLAT .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX

      DEFINE splitbox
         DEFINE GRID grid_produtos
            parent form_produtos
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS { 'Código', 'Tipo', 'Descrição', 'Unidade' }
            WIDTHS { 080, 100, 350, 100 }
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR WHITE
            FONTCOLOR { 105, 105, 105 }
            ondblclick dados( 2 )
         END GRID
      END splitbox

      DEFINE LABEL rodape_001
         parent form_produtos
         COL 005
         ROW 545
         VALUE 'Digite sua pesquisa'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         transparent .T.
      END LABEL
      @ 540, 160 TEXTBOX tbox_pesquisa ;
         OF form_produtos ;
         HEIGHT 027 ;
         WIDTH 300 ;
         VALUE '' ;
         MAXLENGTH 040 ;
         FONT 'verdana' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE ;
         ON CHANGE pesquisar()
      DEFINE LABEL rodape_002
         parent form_produtos
         COL form_produtos.WIDTH -270
         ROW 545
         VALUE 'DUPLO CLIQUE : Alterar informação'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _verde_002
         transparent .T.
      END LABEL

      ON KEY ESCAPE ACTION thiswindow.RELEASE

   END WINDOW

   form_produtos.CENTER
   form_produtos.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION dados( parametro )

   LOCAL oQuery
   LOCAL oRow := {}

   LOCAL x_id := AllTrim( valor_coluna( 'grid_produtos', 'form_produtos', 1 ) )
   LOCAL titulo := 'Incluir'
   LOCAL x_nome := ''
   LOCAL x_tipo := 1
   LOCAL x_codbarras := ''
   LOCAL x_unidade := 1
   LOCAL x_id_grupo := 0
   LOCAL x_custo := 0
   LOCAL x_preco := 0
   LOCAL x_cmedio := 0
   LOCAL x_comissao := 0
   LOCAL x_est_atual := 0
   LOCAL x_est_minimo := 0
   LOCAL x_aplicacao := ''
   LOCAL x_fiscal := ''
   LOCAL x_icms := 0
   LOCAL x_ipi := 0
   LOCAL x_iss := 0
   LOCAL x_bxa_estoque := 1

   IF parametro == 2
      IF Empty( x_id )
         msginfo( 'Faça uma pesquisa antes', 'Atenção' )
         return( nil )
      ELSE
         oQuery := oServer:Query( 'select * from produtos where id = ' + x_id )
         IF oQuery:NetErr()
            msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
            return( nil )
         ENDIF
      ENDIF
      titulo := 'Alterar'
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 2 ) )
      x_tipo := oRow:fieldGet( 3 )
      x_codbarras := AllTrim( oRow:fieldGet( 4 ) )
      x_unidade := oRow:fieldGet( 5 )
      x_id_grupo := oRow:fieldGet( 6 )
      x_custo := oRow:fieldGet( 7 )
      x_preco := oRow:fieldGet( 8 )
      x_cmedio := oRow:fieldGet( 9 )
      x_comissao := oRow:fieldGet( 10 )
      x_est_atual := oRow:fieldGet( 11 )
      x_est_minimo := oRow:fieldGet( 12 )
      x_aplicacao := AllTrim( oRow:fieldGet( 13 ) )
      x_fiscal := AllTrim( oRow:fieldGet( 14 ) )
      x_icms := oRow:fieldGet( 15 )
      x_ipi := oRow:fieldGet( 16 )
      x_iss := oRow:fieldGet( 17 )
      x_bxa_estoque := oRow:fieldGet( 18 )
      oQuery:Destroy()
   ENDIF

   DEFINE WINDOW form_dados ;
         AT 000, 000 ;
         WIDTH 440 ;
         HEIGHT 460 ;
         title ( titulo ) ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      // entrada de dados
      @ 010, 010 LABEL lbl_nome ;
         VALUE 'Descrição' ;
         BOLD
      @ 010, 330 LABEL lbl_tipo ;
         VALUE 'Tipo' ;
         BOLD
      @ 060, 010 LABEL lbl_codigo_barras ;
         VALUE 'Código Barras' ;
         BOLD
      @ 060, 230 LABEL lbl_unidade ;
         VALUE 'Unidade' ;
         BOLD
      @ 060, 310 LABEL lbl_bxa_estoque ;
         VALUE 'Baixar do Estoque ?' ;
         BOLD
      @ 110, 010 LABEL lbl_grupo ;
         VALUE 'Grupo' ;
         BOLD
      @ 160, 010 LABEL lbl_custo ;
         VALUE 'Custo R$' ;
         BOLD
      @ 160, 150 LABEL lbl_preco ;
         VALUE 'Preço R$' ;
         BOLD
      @ 160, 300 LABEL lbl_custo_medio ;
         VALUE 'Custo Médio R$' ;
         BOLD
      @ 210, 010 LABEL lbl_estoque_atual ;
         VALUE 'Estoque Atual' ;
         BOLD
      @ 210, 150 LABEL lbl_estoque_minimo ;
         VALUE 'Estoque Mínimo' ;
         BOLD
      @ 210, 300 LABEL lbl_comissao ;
         VALUE 'Comissão (%)' ;
         BOLD
      @ 260, 010 LABEL lbl_aplicacao ;
         VALUE 'Aplicação' ;
         BOLD
      @ 310, 010 LABEL lbl_classificacao_fiscal ;
         VALUE 'Classif. Fiscal' ;
         BOLD
      @ 310, 120 LABEL lbl_icms ;
         VALUE 'ICMS' ;
         BOLD
      @ 310, 210 LABEL lbl_ipi ;
         VALUE 'IPI' ;
         BOLD
      @ 310, 300 LABEL lbl_iss ;
         VALUE 'ISS' ;
         BOLD

      @ 030, 010 TEXTBOX txt_nome ;
         WIDTH 300 ;
         MAXLENGTH 40 ;
         VALUE x_nome ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 030, 330 comboboxex cbo_tipo ;
         WIDTH 080 ;
         ITEMS aTipo ;
         VALUE x_tipo
      @ 080, 010 TEXTBOX txt_codigo_barras ;
         WIDTH 200 ;
         VALUE x_codbarras ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1
      @ 080, 230 comboboxex cbo_unidade ;
         WIDTH 060 ;
         ITEMS aUnidade ;
         VALUE x_unidade
      @ 080, 310 comboboxex cbo_baixa_estoque ;
         WIDTH 060 ;
         ITEMS aSimNao ;
         VALUE x_bxa_estoque
      @ 130, 010 TEXTBOX tbox_grupo ;
         WIDTH 50 ;
         VALUE x_id_grupo ;
         NUMERIC ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON enter pesq_grupo()
      @ 130, 075 LABEL lbl_nome_grupo ;
         VALUE '' ;
         AUTOSIZE ;
         BOLD ;
         FONTCOLOR BLUE ;
         transparent
      @ 180, 010 TEXTBOX txt_custo ;
         WIDTH 100 ;
         VALUE x_custo ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999,999.99'
      @ 180, 150 TEXTBOX txt_preco ;
         WIDTH 100 ;
         VALUE x_preco ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999,999.99'
      @ 180, 300 TEXTBOX txt_custo_medio ;
         WIDTH 100 ;
         VALUE x_cmedio ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999,999.99'
      @ 230, 010 TEXTBOX txt_estoque_atual ;
         WIDTH 100 ;
         VALUE x_est_atual ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999999'
      @ 230, 150 TEXTBOX txt_estoque_minimo ;
         WIDTH 100 ;
         VALUE x_est_minimo ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999999'
      @ 230, 300 TEXTBOX txt_comissao ;
         WIDTH 100 ;
         VALUE x_comissao ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999.99'
      @ 280, 010 TEXTBOX txt_aplicacao ;
         WIDTH 390 ;
         MAXLENGTH 50 ;
         VALUE x_aplicacao ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 330, 010 TEXTBOX txt_classificacao_fiscal ;
         WIDTH 100 ;
         MAXLENGTH 10 ;
         VALUE x_fiscal ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 330, 120 TEXTBOX txt_icms ;
         WIDTH 080 ;
         VALUE x_icms ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999.99'
      @ 330, 210 TEXTBOX txt_ipi ;
         WIDTH 080 ;
         VALUE x_ipi ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999.99'
      @ 330, 300 TEXTBOX txt_iss ;
         WIDTH 080 ;
         VALUE x_iss ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC INPUTMASK '999.99'

      // linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_dados.HEIGHT -090
         VALUE ''
         WIDTH form_dados.WIDTH
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL

      // botões
      DEFINE BUTTONEX button_ok
         PICTURE 'img_gravar'
         COL form_dados.WIDTH -225
         ROW form_dados.HEIGHT -085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar( parametro )
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informações digitadas'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE 'img_voltar'
         COL form_dados.WIDTH -100
         ROW form_dados.HEIGHT -085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_dados.RELEASE
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela sem gravar informações'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX

   END WINDOW

   sethandcursor( getcontrolhandle( 'button_ok', 'form_dados' ) )
   sethandcursor( getcontrolhandle( 'button_cancela', 'form_dados' ) )

   form_dados.CENTER
   form_dados.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION excluir()

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_id := AllTrim( valor_coluna( 'grid_produtos', 'form_produtos', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_produtos', 'form_produtos', 3 ) )

   IF Empty( v_id )
      msginfo( 'Faça uma pesquisa antes, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Confirma a exclusão de : ' + v_nome + ' ?' )
      cQuery := 'delete from produtos where id = ' + v_id
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Exclusão : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
      msginfo( 'A informação : ' + v_nome + ' - foi excluída' )
      pesquisar()
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION relacao()

   DEFINE WINDOW form_relatorio_001 ;
         AT 000, 000 ;
         WIDTH 320 ;
         HEIGHT 150 ;
         TITLE 'Relatório:por ordem alfabética' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      @ 010, 010 LABEL label_tipo VALUE 'Clique no botão Ok para ver o relatório' BOLD AUTOSIZE

      DEFINE LABEL linha_horizontal
         COL 000
         ROW form_relatorio_001.HEIGHT -090
         VALUE ''
         WIDTH form_relatorio_001.WIDTH
         HEIGHT 001
         BACKCOLOR { 128, 128, 128 }
         transparent .F.
      END LABEL

      DEFINE BUTTONEX button_relatorio
         PICTURE 'relatorio'
         COL form_relatorio_001.WIDTH -305
         ROW form_relatorio_001.HEIGHT -085
         WIDTH 160
         HEIGHT 050
         CAPTION 'Ok, imprimir'
         ACTION executa_relatorio_001()
         FONTBOLD .T.
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_voltar
         PICTURE 'img_voltar'
         COL form_relatorio_001.WIDTH -140
         ROW form_relatorio_001.HEIGHT -085
         WIDTH 130
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_relatorio_001.RELEASE
         FONTBOLD .T.
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION form_relatorio_001.RELEASE

   END WINDOW

   form_relatorio_001.CENTER
   form_relatorio_001.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION executa_relatorio_001()

   LOCAL oQuery, oQuery_setor, oQuery_local
   LOCAL oRow := {}

   LOCAL n_i := 0

   LOCAL pagina := 1
   LOCAL p_linha := 045
   LOCAL u_linha := 260
   LOCAL linha := p_linha

   oQuery := oServer:Query( 'select * from produtos order by nome' )

   IF oQuery:Eof()
      msginfo( 'Não existem informações para serem impressas', 'Atenção' )
      return( nil )
   ENDIF

   SELECT PRINTER DIALOG PREVIEW
   START PRINTDOC NAME 'Gerenciador de impressão'
   START PRINTPAGE

   cabecalho_1( pagina )

   FOR n_i := 1 TO oQuery:LastRec()

      oRow := oQuery:GetRow( n_i )

      @ linha, 030 PRINT AllTrim( Str( oRow:fieldGet( 1 ), 6 ) ) FONT 'courier new' SIZE 10
      @ linha, 045 PRINT AllTrim( oRow:fieldGet( 2 ) ) FONT 'courier new' SIZE 10
      @ linha, 150 PRINT aTipo[ oRow:fieldGet( 3 ) ] FONT 'courier new' SIZE 10

      linha += 5

      IF linha >= u_linha
         pagina++
         rodape()
         END PRINTPAGE
         START PRINTPAGE
         cabecalho_1( pagina )
         linha := p_linha
      ENDIF

      oQuery:Skip( 1 )

   NEXT n_i

   rodape()

   END PRINTPAGE
   END PRINTDOC

   oQuery:Destroy()

   form_relatorio_001.RELEASE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION cabecalho_1( p_pagina )

   @ 007, 010 PRINT IMAGE 'logotipo' WIDTH 030 HEIGHT 025 STRETCH
   @ 010, 050 PRINT 'RELAÇÃO DE PRODUTOS' FONT 'courier new' SIZE 018 BOLD
   @ 018, 050 PRINT 'Ordem Alfabética' FONT 'courier new' SIZE 014
   @ 024, 050 PRINT 'Página : ' + StrZero( p_pagina, 4 ) FONT 'courier new' SIZE 012

   @ 030, 000 PRINT LINE TO 030, 205 PENWIDTH 0.5 COLOR _preto_001

   @ 035, 025 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035, 045 PRINT 'DESCRIÇÃO' FONT 'courier new' SIZE 010 BOLD
   @ 035, 150 PRINT 'TIPO' FONT 'courier new' SIZE 010 BOLD

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION rodape()

   @ 275, 000 PRINT LINE TO 275, 205 PENWIDTH 0.5 COLOR _preto_001
   @ 276, 010 PRINT 'impresso em ' + DToC( Date() ) + ' as ' + Time() FONT 'courier new' SIZE 008

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION gravar( parametro )

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_id := AllTrim( valor_coluna( 'grid_produtos', 'form_produtos', 1 ) )

   LOCAL v_nome := AllTrim( form_dados.txt_nome.value )
   LOCAL v_tipo := AllTrim( Str( form_dados.cbo_tipo.value ) )
   LOCAL v_codbarras := AllTrim( form_dados.txt_codigo_barras.value )
   LOCAL v_unidade := AllTrim( Str( form_dados.cbo_unidade.value ) )
   LOCAL v_grupo := AllTrim( Str( form_dados.tbox_grupo.value ) )
   LOCAL v_custo := Str( form_dados.txt_custo.VALUE, 12, 2 )
   LOCAL v_preco := Str( form_dados.txt_preco.VALUE, 12, 2 )
   LOCAL v_custo_medio := Str( form_dados.txt_custo_medio.VALUE, 12, 2 )
   LOCAL v_comissao := Str( form_dados.txt_comissao.VALUE, 10, 2 )
   LOCAL v_est_atual := AllTrim( Str( form_dados.txt_estoque_atual.value ) )
   LOCAL v_est_minimo := AllTrim( Str( form_dados.txt_estoque_minimo.value ) )
   LOCAL v_aplicacao := AllTrim( form_dados.txt_aplicacao.value )
   LOCAL v_fiscal := AllTrim( form_dados.txt_classificacao_fiscal.value )
   LOCAL v_icms := Str( form_dados.txt_icms.VALUE, 10, 2 )
   LOCAL v_ipi := Str( form_dados.txt_ipi.VALUE, 10, 2 )
   LOCAL v_iss := Str( form_dados.txt_iss.VALUE, 10, 2 )
   LOCAL v_bxa_estoque := AllTrim( Str( form_dados.cbo_baixa_estoque.value ) )

   IF parametro == 1
      IF Empty( v_nome )
         msginfo( 'Obrigatório preencher o campo : Nome', 'Atenção' )
         return( nil )
      ELSE
         cQuery := "insert into produtos (nome,tipo,codigo_barras,unidade,id_grupo,custo,preco,custo_medio,comissao,estoque_atual,estoque_minimo,aplicacao,cla_fiscal,icms,ipi,iss,baixa_estoque,data_cad,hora_cad) values ('"
         cQuery += v_nome + "','"
         cQuery += v_tipo + "','"
         cQuery += v_codbarras + "','"
         cQuery += v_unidade + "','"
         cQuery += v_grupo + "','"
         cQuery += v_custo + "','"
         cQuery += v_preco + "','"
         cQuery += v_custo_medio + "','"
         cQuery += v_comissao + "','"
         cQuery += v_est_atual + "','"
         cQuery += v_est_minimo + "','"
         cQuery += v_aplicacao + "','"
         cQuery += v_fiscal + "','"
         cQuery += v_icms + "','"
         cQuery += v_ipi + "','"
         cQuery += v_iss + "','"
         cQuery += v_bxa_estoque + "','"
         cQuery += td( Date() ) + "','"
         cQuery += Time() + "')"
         oQuery := oQuery := oServer:Query( cQuery )
         IF oQuery:NetErr()
            msginfo( 'Erro na Inclusão : ' + oQuery:Error() )
            return( nil )
         ENDIF
         oQuery:Destroy()
         form_dados.RELEASE
         pesquisar()
      ENDIF
   ELSEIF parametro == 2
      IF Empty( v_nome )
         msginfo( 'Obrigatório preencher o campo : Nome', 'Atenção' )
         return( nil )
      ELSE
         cQuery := "update produtos set "
         cQuery += "nome='" + v_nome + "',"
         cQuery += "tipo='" + v_tipo + "',"
         cQuery += "codigo_barras='" + v_codbarras + "',"
         cQuery += "unidade='" + v_unidade + "',"
         cQuery += "id_grupo='" + v_grupo + "',"
         cQuery += "custo='" + v_custo + "',"
         cQuery += "preco='" + v_preco + "',"
         cQuery += "custo_medio='" + v_custo_medio + "',"
         cQuery += "comissao='" + v_comissao + "',"
         cQuery += "estoque_atual='" + v_est_atual + "',"
         cQuery += "estoque_minimo='" + v_est_minimo + "',"
         cQuery += "aplicacao='" + v_aplicacao + "',"
         cQuery += "cla_fiscal='" + v_fiscal + "',"
         cQuery += "icms='" + v_icms + "',"
         cQuery += "ipi='" + v_ipi + "',"
         cQuery += "iss='" + v_iss + "',"
         cQuery += "baixa_estoque='" + v_bxa_estoque + "'"
         cQuery += " where id='" + v_id + "'"
         oQuery := oQuery := oServer:Query( cQuery )
         IF oQuery:NetErr()
            msginfo( 'Erro na Alteração : ' + oQuery:Error() )
            return( nil )
         ENDIF
         oQuery:Destroy()
         form_dados.RELEASE
         pesquisar()
      ENDIF
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesquisar()

   LOCAL oQuery

   LOCAL v_conteudo := form_produtos.tbox_pesquisa.VALUE
   LOCAL v_pesquisa := '"' + Upper( AllTrim( form_produtos.tbox_pesquisa.value ) ) + '%"'
   LOCAL n_i := 0
   LOCAL oRow := {}

   DELETE ITEM ALL FROM grid_produtos OF form_produtos

   IF Empty( v_conteudo )
      oQuery := oServer:Query( 'select id,tipo,nome,unidade from produtos order by nome' )
   ELSE
      oQuery := oServer:Query( 'select id,tipo,nome,unidade from produtos where nome like ' + v_pesquisa + ' order by nome' )
   ENDIF

   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ENDIF

   IF oQuery:Eof()
      return( nil )
   ENDIF

   FOR n_i := 1 TO oQuery:LastRec()
      oRow := oQuery:GetRow( n_i )
      add ITEM { Str( oRow:fieldGet( 1 ) ), aTipo[ oRow:fieldGet( 2 ) ], AllTrim( oRow:fieldGet( 3 ) ), aUnidade[ oRow:fieldGet( 4 ) ] } TO grid_produtos OF form_produtos
      oQuery:Skip( 1 )
   NEXT n_i

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesq_grupo()

   LOCAL x_grupo := form_dados.tbox_grupo.VALUE
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}

   IF x_grupo <> 0
      oQuery := oServer:Query( 'select * from grupos where id = ' + AllTrim( Str( x_grupo ) ) )
      IF oQuery:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 2 ) )
      SetProperty( 'form_dados', 'lbl_nome_grupo', 'value', x_nome )
      return( nil )
   ENDIF

   DEFINE WINDOW form_pesquisa ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 400 ;
         TITLE 'Pesquisa Grupo' ;
         ICON 'icone' ;
         modal ;
         NOSIZE ;
         ON INIT alimenta_pesquisa()

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
         ondblclick passa_pesquisa()
      END GRID

      ON KEY ESCAPE ACTION form_pesquisa.RELEASE

   END WINDOW

   form_pesquisa.CENTER
   form_pesquisa.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION alimenta_pesquisa()

   LOCAL i := 0
   LOCAL oQuery
   LOCAL oRow := {}

   oQuery := oServer:Query( 'select * from grupos order by nome' )

   FOR i := 1 TO oQuery:LastRec()
      oRow := oQuery:GetRow( i )
      add ITEM { AllTrim( Str( oRow:fieldGet( 1 ), 6 ) ), AllTrim( oRow:fieldGet( 2 ) ) } TO grid_pesquisa OF form_pesquisa
      oQuery:Skip( 1 )
   NEXT i

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION passa_pesquisa()

   LOCAL v_id := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 2 ) )

   SetProperty( 'form_dados', 'tbox_grupo', 'value', Val( v_id ) )
   SetProperty( 'form_dados', 'lbl_nome_grupo', 'value', v_nome )

   form_pesquisa.RELEASE

return( nil )
