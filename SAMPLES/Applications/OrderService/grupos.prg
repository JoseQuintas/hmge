/*
  sistema     : ordem de serviço
  programa    : grupos (produtos)
  compilador  : harbour
  lib gráfica : minigui extended
*/

#include 'minigui.ch'
#include 'miniprint.ch'

FUNCTION grupos()

   DEFINE WINDOW form_grupos ;
         AT 000, 000 ;
         WIDTH 800 ;
         HEIGHT 605 ;
         TITLE 'Grupos (produtos)' ;
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
         ACTION form_grupos.RELEASE
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
         DEFINE GRID grid_grupos
            parent form_grupos
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS { 'Código', 'Nome' }
            WIDTHS { 100, 600 }
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR WHITE
            FONTCOLOR { 105, 105, 105 }
            ondblclick dados( 2 )
         END GRID
      END splitbox

      DEFINE LABEL rodape_001
         parent form_grupos
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
         OF form_grupos ;
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
         parent form_grupos
         COL form_grupos.WIDTH -270
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

   form_grupos.CENTER
   form_grupos.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION dados( parametro )

   LOCAL oQuery
   LOCAL oRow := {}

   LOCAL x_id := AllTrim( valor_coluna( 'grid_grupos', 'form_grupos', 1 ) )
   LOCAL titulo := 'Incluir'
   LOCAL x_nome := ''

   IF parametro == 2
      IF Empty( x_id )
         msginfo( 'Faça uma pesquisa antes', 'Atenção' )
         return( nil )
      ELSE
         oQuery := oServer:Query( 'select * from grupos where id = ' + x_id )
         IF oQuery:NetErr()
            msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
            return( nil )
         ENDIF
      ENDIF
      titulo := 'Alterar'
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 2 ) )
      oQuery:Destroy()
   ENDIF

   DEFINE WINDOW form_dados ;
         AT 000, 000 ;
         WIDTH 365 ;
         HEIGHT 180 ;
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
         WIDTH 350 ;
         VALUE x_nome ;
         MAXLENGTH 030 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE

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

   LOCAL v_id := AllTrim( valor_coluna( 'grid_grupos', 'form_grupos', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_grupos', 'form_grupos', 2 ) )

   IF Empty( v_id )
      msginfo( 'Faça uma pesquisa antes, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Confirma a exclusão de : ' + v_nome + ' ?' )
      cQuery := 'delete from grupos where id = ' + v_id
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

   oQuery := oServer:Query( 'select * from grupos order by nome' )

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
   @ 010, 050 PRINT 'RELAÇÃO DE GRUPOS (produtos)' FONT 'courier new' SIZE 018 BOLD
   @ 018, 050 PRINT 'Ordem Alfabética' FONT 'courier new' SIZE 014
   @ 024, 050 PRINT 'Página : ' + StrZero( p_pagina, 4 ) FONT 'courier new' SIZE 012

   @ 030, 000 PRINT LINE TO 030, 205 PENWIDTH 0.5 COLOR _preto_001

   @ 035, 025 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035, 045 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD

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

   LOCAL v_id := AllTrim( valor_coluna( 'grid_grupos', 'form_grupos', 1 ) )
   LOCAL v_nome := AllTrim( form_dados.tbox_001.value )

   IF parametro == 1
      IF Empty( v_nome )
         msginfo( 'Obrigatório preencher o campo : Nome', 'Atenção' )
         return( nil )
      ELSE
         cQuery := "insert into grupos (nome) values ('"
         cQuery += v_nome + "')"
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
         cQuery := "update grupos set "
         cQuery += "nome='" + v_nome + "'"
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

   LOCAL v_conteudo := form_grupos.tbox_pesquisa.VALUE
   LOCAL v_pesquisa := '"' + Upper( AllTrim( form_grupos.tbox_pesquisa.value ) ) + '%"'
   LOCAL n_i := 0
   LOCAL oRow := {}

   DELETE ITEM ALL FROM grid_grupos OF form_grupos

   IF Empty( v_conteudo )
      oQuery := oServer:Query( 'select id,nome from grupos order by nome' )
   ELSE
      oQuery := oServer:Query( 'select id,nome from grupos where nome like ' + v_pesquisa + ' order by nome' )
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
      add ITEM { Str( oRow:fieldGet( 1 ) ), AllTrim( oRow:fieldGet( 2 ) ) } TO grid_grupos OF form_grupos
      oQuery:Skip( 1 )
   NEXT n_i

   oQuery:Destroy()

return( nil )
