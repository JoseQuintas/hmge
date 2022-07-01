/*
  sistema     : ordem de serviço
  programa    : funcionários
  compilador  : harbour
  lib gráfica : minigui extended
*/

#include 'minigui.ch'
#include 'miniprint.ch'

FUNCTION funcionarios()

   DEFINE WINDOW form_funcionarios ;
         AT 000, 000 ;
         WIDTH 800 ;
         HEIGHT 605 ;
         TITLE 'Funcionários' ;
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
         ACTION form_funcionarios.RELEASE
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
         DEFINE GRID grid_funcionarios
            parent form_funcionarios
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS { 'Código', 'Nome', 'Telefone fixo', 'Telefone celular' }
            WIDTHS { 080, 400, 140, 140 }
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR WHITE
            FONTCOLOR { 105, 105, 105 }
            ondblclick dados( 2 )
         END GRID
      END splitbox

      DEFINE LABEL rodape_001
         parent form_funcionarios
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
         OF form_funcionarios ;
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
         parent form_funcionarios
         COL form_funcionarios.WIDTH -270
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

   form_funcionarios.CENTER
   form_funcionarios.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION dados( parametro )

   LOCAL oQuery
   LOCAL oRow := {}

   LOCAL x_id := AllTrim( valor_coluna( 'grid_funcionarios', 'form_funcionarios', 1 ) )
   LOCAL titulo := 'Incluir'
   LOCAL x_nome := ''
   LOCAL x_fixo := ''
   LOCAL x_celular := ''
   LOCAL x_endereco := ''
   LOCAL x_numero := ''
   LOCAL x_complem := ''
   LOCAL x_bairro := ''
   LOCAL x_cidade := ''
   LOCAL x_uf := ''
   LOCAL x_cep := ''
   LOCAL x_email := ''
   LOCAL x_cpf := ''

   IF parametro == 2
      IF Empty( x_id )
         msginfo( 'Faça uma pesquisa antes', 'Atenção' )
         return( nil )
      ELSE
         oQuery := oServer:Query( 'select * from funcionarios where id = ' + x_id )
         IF oQuery:NetErr()
            msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
            return( nil )
         ENDIF
      ENDIF
      titulo := 'Alterar'
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 3 ) )
      x_fixo := AllTrim( oRow:fieldGet( 4 ) )
      x_celular := AllTrim( oRow:fieldGet( 5 ) )
      x_endereco := AllTrim( oRow:fieldGet( 6 ) )
      x_numero := AllTrim( oRow:fieldGet( 7 ) )
      x_complem := AllTrim( oRow:fieldGet( 8 ) )
      x_bairro := AllTrim( oRow:fieldGet( 9 ) )
      x_cidade := AllTrim( oRow:fieldGet( 10 ) )
      x_uf := AllTrim( oRow:fieldGet( 11 ) )
      x_cep := AllTrim( oRow:fieldGet( 12 ) )
      x_email := AllTrim( oRow:fieldGet( 13 ) )
      x_cpf := AllTrim( oRow:fieldGet( 2 ) )
      oQuery:Destroy()
   ENDIF

   DEFINE WINDOW form_dados ;
         AT 000, 000 ;
         WIDTH 585 ;
         HEIGHT 370 ;
         title ( titulo ) ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      // entrada de dados
      @ 010, 005 LABEL lbl_001 ;
         OF form_dados ;
         VALUE 'Nome' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 030, 005 TEXTBOX tbox_001 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_nome ;
         MAXLENGTH 040 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 010, 325 LABEL lbl_002 ;
         OF form_dados ;
         VALUE 'Telefone fixo' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 030, 325 TEXTBOX tbox_002 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE x_fixo ;
         MAXLENGTH 010 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 010, 455 LABEL lbl_003 ;
         OF form_dados ;
         VALUE 'Telefone celular' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 030, 455 TEXTBOX tbox_003 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE x_celular ;
         MAXLENGTH 010 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060, 005 LABEL lbl_004 ;
         OF form_dados ;
         VALUE 'Endereço' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 080, 005 TEXTBOX tbox_004 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_endereco ;
         MAXLENGTH 040 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060, 325 LABEL lbl_005 ;
         OF form_dados ;
         VALUE 'Número' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 080, 325 TEXTBOX tbox_005 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE x_numero ;
         MAXLENGTH 006 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060, 395 LABEL lbl_006 ;
         OF form_dados ;
         VALUE 'Complemento' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 080, 395 TEXTBOX tbox_006 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_complem ;
         MAXLENGTH 020 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110, 005 LABEL lbl_007 ;
         OF form_dados ;
         VALUE 'Bairro' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 130, 005 TEXTBOX tbox_007 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_bairro ;
         MAXLENGTH 020 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110, 195 LABEL lbl_008 ;
         OF form_dados ;
         VALUE 'Cidade' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 130, 195 TEXTBOX tbox_008 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_cidade ;
         MAXLENGTH 020 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110, 385 LABEL lbl_009 ;
         OF form_dados ;
         VALUE 'UF' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 130, 385 TEXTBOX tbox_009 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 040 ;
         VALUE x_uf ;
         MAXLENGTH 002 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110, 435 LABEL lbl_010 ;
         OF form_dados ;
         VALUE 'CEP' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 130, 435 TEXTBOX tbox_010 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 080 ;
         VALUE x_cep ;
         MAXLENGTH 008 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1
      @ 160, 005 LABEL lbl_011 ;
         OF form_dados ;
         VALUE 'e-mail' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 180, 005 TEXTBOX tbox_011 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 450 ;
         VALUE x_email ;
         MAXLENGTH 050 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         lowercase
      @ 210, 005 LABEL lbl_015 ;
         OF form_dados ;
         VALUE 'CPF' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 230, 005 TEXTBOX tbox_015 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 135 ;
         VALUE x_cpf ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         INPUTMASK '999.999.999-99'

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

   LOCAL v_id := AllTrim( valor_coluna( 'grid_funcionarios', 'form_funcionarios', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_funcionarios', 'form_funcionarios', 2 ) )

   IF Empty( v_id )
      msginfo( 'Faça uma pesquisa antes, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Confirma a exclusão de : ' + v_nome + ' ?' )
      cQuery := 'delete from funcionarios where id = ' + v_id
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

   oQuery := oServer:Query( 'select * from funcionarios order by nome' )

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
      @ linha, 045 PRINT AllTrim( oRow:fieldGet( 3 ) ) FONT 'courier new' SIZE 10
      @ linha, 150 PRINT oRow:fieldGet( 4 ) + '-' + oRow:fieldGet( 5 ) FONT 'courier new' SIZE 10

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
   @ 010, 050 PRINT 'RELAÇÃO DE FUNCIONÁRIOS' FONT 'courier new' SIZE 018 BOLD
   @ 018, 050 PRINT 'Ordem Alfabética' FONT 'courier new' SIZE 014
   @ 024, 050 PRINT 'Página : ' + StrZero( p_pagina, 4 ) FONT 'courier new' SIZE 012

   @ 030, 000 PRINT LINE TO 030, 205 PENWIDTH 0.5 COLOR _preto_001

   @ 035, 025 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035, 045 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
   @ 035, 150 PRINT 'TELEFONE' FONT 'courier new' SIZE 010 BOLD

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

   LOCAL v_id := AllTrim( valor_coluna( 'grid_funcionarios', 'form_funcionarios', 1 ) )
   LOCAL v_nome := AllTrim( form_dados.tbox_001.value )
   LOCAL v_fixo := AllTrim( form_dados.tbox_002.value )
   LOCAL v_celular := AllTrim( form_dados.tbox_003.value )
   LOCAL v_endereco := AllTrim( form_dados.tbox_004.value )
   LOCAL v_numero := AllTrim( form_dados.tbox_005.value )
   LOCAL v_complem := AllTrim( form_dados.tbox_006.value )
   LOCAL v_bairro := AllTrim( form_dados.tbox_007.value )
   LOCAL v_cidade := AllTrim( form_dados.tbox_008.value )
   LOCAL v_uf := AllTrim( form_dados.tbox_009.value )
   LOCAL v_cep := AllTrim( form_dados.tbox_010.value )
   LOCAL v_email := AllTrim( form_dados.tbox_011.value )
   LOCAL v_cpf := AllTrim( form_dados.tbox_015.value )

   IF parametro == 1
      IF Empty( v_nome )
         msginfo( 'Obrigatório preencher o campo : Nome', 'Atenção' )
         return( nil )
      ELSE
         cQuery := "insert into funcionarios (nome,fixo,celular,endereco,numero,complemento,bairro,cidade,uf,cep,email,cpf,data_cad,hora_cad) values ('"
         cQuery += v_nome + "','"
         cQuery += v_fixo + "','"
         cQuery += v_celular + "','"
         cQuery += v_endereco + "','"
         cQuery += v_numero + "','"
         cQuery += v_complem + "','"
         cQuery += v_bairro + "','"
         cQuery += v_cidade + "','"
         cQuery += v_uf + "','"
         cQuery += v_cep + "','"
         cQuery += v_email + "','"
         cQuery += v_cpf + "','"
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
         cQuery := "update funcionarios set "
         cQuery += "nome='" + v_nome + "',"
         cQuery += "fixo='" + v_fixo + "',"
         cQuery += "celular='" + v_celular + "',"
         cQuery += "endereco='" + v_endereco + "',"
         cQuery += "numero='" + v_numero + "',"
         cQuery += "complemento='" + v_complem + "',"
         cQuery += "bairro='" + v_bairro + "',"
         cQuery += "cidade='" + v_cidade + "',"
         cQuery += "uf='" + v_uf + "',"
         cQuery += "cep='" + v_cep + "',"
         cQuery += "email='" + v_email + "',"
         cQuery += "cpf='" + v_cpf + "'"
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

   LOCAL v_conteudo := form_funcionarios.tbox_pesquisa.VALUE
   LOCAL v_pesquisa := '"' + Upper( AllTrim( form_funcionarios.tbox_pesquisa.value ) ) + '%"'
   LOCAL n_i := 0
   LOCAL oRow := {}

   DELETE ITEM ALL FROM grid_funcionarios OF form_funcionarios

   IF Empty( v_conteudo )
      oQuery := oServer:Query( 'select id,nome,fixo,celular from funcionarios order by nome' )
   ELSE
      oQuery := oServer:Query( 'select id,nome,fixo,celular from funcionarios where nome like ' + v_pesquisa + ' order by nome' )
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
      add ITEM { Str( oRow:fieldGet( 1 ) ), AllTrim( oRow:fieldGet( 2 ) ), AllTrim( oRow:fieldGet( 3 ) ), AllTrim( oRow:fieldGet( 4 ) ) } TO grid_funcionarios OF form_funcionarios
      oQuery:Skip( 1 )
   NEXT n_i

   oQuery:Destroy()

return( nil )
