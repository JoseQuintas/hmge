/*
  sistema     : ordem de serviço
  programa    : contas a pagar
  compilador  : harbour
  lib gráfica : minigui extended
*/

#include 'minigui.ch'
#include 'miniprint.ch'

FUNCTION cpagar()

   DEFINE WINDOW form_cpag ;
         AT 000, 000 ;
         WIDTH 1000 ;
         HEIGHT 605 ;
         TITLE 'Contas a Pagar' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

    /*
      toolbar
    */
      DEFINE BUTTONEX button_incluir
         PICTURE 'img_inclui'
         COL 002
         ROW 002
         WIDTH 90
         HEIGHT 90
         CAPTION 'Novo'
         ACTION dados_cpag( 1 )
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
         COL 94
         ROW 002
         WIDTH 90
         HEIGHT 90
         CAPTION 'Modificar'
         ACTION dados_cpag( 2 )
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
         COL 186
         ROW 002
         WIDTH 90
         HEIGHT 90
         CAPTION 'Apagar'
         ACTION excluir_cpag()
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _vermelho_002
         vertical .T.
         FLAT .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_baixa
         PICTURE 'img_baixa'
         COL 278
         ROW 002
         WIDTH 90
         HEIGHT 90
         CAPTION 'Baixar'
         ACTION baixar_cpag()
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
         COL 370
         ROW 002
         WIDTH 90
         HEIGHT 90
         CAPTION 'Sair (ESC)'
         ACTION form_cpag.RELEASE
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         FLAT .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX

    /*
      grid
    */
      DEFINE GRID grid_cpag
         parent form_cpag
         COL 0
         ROW 94
         WIDTH form_cpag.WIDTH -10
         HEIGHT 480
         HEADERS { 'id', 'Vencimento', 'Fornecedor', 'Forma Pagamento', 'Valor R$', 'Nº Documento' }
         WIDTHS { 001, 120, 300, 220, 120, 130 }
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .F.
         BACKCOLOR WHITE
         FONTCOLOR { 105, 105, 105 }
         ondblclick dados_cpag( 2 )
      END GRID

    /*
      filtro
    */
      DEFINE LABEL rodape_001
         parent form_cpag
         COL 470
         ROW 5
         VALUE 'Escolha o período'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         transparent .T.
      END LABEL
      DEFINE LABEL rodape_002
         parent form_cpag
         COL 580
         ROW 25
         VALUE 'até'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         transparent .T.
      END LABEL
      @ 025, 470 datepicker dp_inicio ;
         parent form_cpag ;
         VALUE Date() ;
         WIDTH 100 ;
         FONT 'verdana' SIZE 010
      @ 025, 610 datepicker dp_final ;
         parent form_cpag ;
         VALUE Date() ;
         WIDTH 100 ;
         FONT 'verdana' SIZE 010
      @ 025, 720 RADIOGROUP radio_tipo ;
         options { 'Mostrar PENDENTES', 'Mostrar BAIXADAS' } ;
         VALUE 1 ;
         WIDTH 140 ;
         leftjustify

      @ 025, 870 BUTTONEX botao_filtrar ;
         PICTURE 'img_filtro' ;
         CAPTION 'Filtrar' ;
         WIDTH 85 HEIGHT 50 ;
         ACTION pesquisar() ;
         BOLD

      ON KEY ESCAPE ACTION form_cpag.RELEASE

   END WINDOW

   form_cpag.CENTER
   form_cpag.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesquisar()

   LOCAL oQuery
   LOCAL n_i := 0
   LOCAL oRow := {}

   LOCAL x_data_inicio := td( form_cpag.dp_inicio.value )
   LOCAL x_data_final := td( form_cpag.dp_final.value )
   LOCAL x_tipo := AllTrim( Str( form_cpag.radio_tipo.value ) )

   DELETE ITEM ALL FROM grid_cpag OF form_cpag

   oQuery := oServer:Query( "select * from cpagar where vencimento>='" + x_data_inicio + "' and vencimento<='" + x_data_final + "' and baixado='" + x_tipo + "' order by vencimento" )

   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ENDIF

   IF oQuery:Eof()
      msginfo( 'Sua pesquisa não foi encontrada, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   FOR n_i := 1 TO oQuery:LastRec()
      oRow := oQuery:GetRow( n_i )
      add ITEM { AllTrim( Str( oRow:fieldGet( 1 ), 6 ) ), DToC( oRow:fieldGet( 9 ) ), AllTrim( oRow:fieldGet( 6 ) ), AllTrim( oRow:fieldGet( 8 ) ), Str( oRow:fieldGet( 10 ), 12, 2 ), AllTrim( oRow:fieldGet( 11 ) ) } TO grid_cpag OF form_cpag
      oQuery:Skip( 1 )
   NEXT n_i

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION dados_cpag( parametro )

   LOCAL oQuery
   LOCAL oRow := {}

   LOCAL x_id := AllTrim( valor_coluna( 'grid_cpag', 'form_cpag', 1 ) )
   LOCAL titulo := 'Incluir'
   LOCAL x_fornecedor := 0
   LOCAL x_forma := 0
   LOCAL x_data := Date()
   LOCAL x_valor := 0
   LOCAL x_numero := ''
   LOCAL x_obs := ''

   IF parametro == 2
      IF Empty( x_id )
         msginfo( 'Faça uma pesquisa antes', 'Atenção' )
         return( nil )
      ELSE
         oQuery := oServer:Query( 'select * from cpagar where id = ' + x_id )
         IF oQuery:NetErr()
            msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
            return( nil )
         ENDIF
      ENDIF
      x_titulo := 'Alterar'
      oRow := oQuery:GetRow( 1 )
      x_fornecedor := oRow:fieldGet( 5 )
      x_forma := oRow:fieldGet( 7 )
      x_data := oRow:fieldGet( 9 )
      x_valor := oRow:fieldGet( 10 )
      x_numero := AllTrim( oRow:fieldGet( 11 ) )
      x_obs := AllTrim( oRow:fieldGet( 12 ) )
      oQuery:Destroy()
   ENDIF

   DEFINE WINDOW form_dados ;
         AT 000, 000 ;
         WIDTH 430 ;
         HEIGHT 330 ;
         title ( titulo ) ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      // entrada de dados
      @ 010, 005 LABEL lbl_001 ;
         OF form_dados ;
         VALUE 'Fornecedor' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 030, 005 TEXTBOX tbox_001 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE x_fornecedor ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC ;
         ON enter pesq_fornecedor()
      @ 030, 075 LABEL lbl_nome_fornecedor ;
         OF form_dados ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR BLUE ;
         transparent
      // ----------
      @ 060, 005 LABEL lbl_002 ;
         OF form_dados ;
         VALUE 'Forma Pagamento' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 080, 005 TEXTBOX tbox_002 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE x_forma ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC ;
         ON enter pesq_fpagamento()
      @ 080, 075 LABEL lbl_nome_forma_pagamento ;
         OF form_dados ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR BLUE ;
         transparent
      // ----------
      @ 110, 005 LABEL lbl_003 ;
         OF form_dados ;
         VALUE 'Data' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR BLACK ;
         transparent
      @ 130, 005 TEXTBOX tbox_003 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE x_data ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         DATE
      // ----------
      @ 110, 140 LABEL lbl_004 ;
         OF form_dados ;
         VALUE 'Valor R$' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _vermelho_002 ;
         transparent
      @ 130, 140 getbox tbox_004 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE x_valor ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@E 999,999.99'
      // ----------
      @ 110, 270 LABEL lbl_005 ;
         OF form_dados ;
         VALUE 'Número documento' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 130, 270 TEXTBOX tbox_005 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 150 ;
         VALUE x_numero ;
         MAXLENGTH 015 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      // ----------
      @ 160, 005 LABEL lbl_006 ;
         OF form_dados ;
         VALUE 'Observação' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR _preto_001 ;
         transparent
      @ 180, 005 TEXTBOX tbox_006 ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 415 ;
         VALUE x_obs ;
         MAXLENGTH 040 ;
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
         ACTION gravar_cpag( parametro )
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
STATIC FUNCTION gravar_cpag( parametro )

   LOCAL cQuery
   LOCAL oQuery
   LOCAL v_id

   LOCAL x_fornecedor := AllTrim( Str( form_dados.tbox_001.value ) )
   LOCAL x_forma := AllTrim( Str( form_dados.tbox_002.value ) )
   LOCAL x_data := form_dados.tbox_003.VALUE
   LOCAL x_valor := Str( form_dados.tbox_004.VALUE, 12, 2 )
   LOCAL x_numero := AllTrim( form_dados.tbox_005.value )
   LOCAL x_obs := AllTrim( form_dados.tbox_006.value )
   LOCAL x_nome_fornecedor := AllTrim( form_dados.lbl_nome_fornecedor.value )
   LOCAL x_nome_fpagamento := AllTrim( form_dados.lbl_nome_forma_pagamento.value )

   IF parametro == 1
      IF Empty( x_fornecedor ) .OR. Empty( x_forma ) .OR. Empty( x_data ) .OR. Empty( x_valor )
         msginfo( 'Obrigatório preencher os campos : Fornecedor, Forma Pagamento, Data e Valor', 'Atenção' )
         return( nil )
      ELSE
         cQuery := "insert into cpagar (data_inclusao,hora_inclusao,baixado,id_fornecedor,nome_fornecedor,id_fpagamento,nome_fpagamento,vencimento,valor,numero_doc,observacao) values ('"
         cQuery += td( Date() ) + "','"
         cQuery += Time() + "','"
         cQuery += '1' + "','"
         cQuery += x_fornecedor + "','"
         cQuery += x_nome_fornecedor + "','"
         cQuery += x_forma + "','"
         cQuery += x_nome_fpagamento + "','"
         cQuery += td( x_data ) + "','"
         cQuery += x_valor + "','"
         cQuery += x_numero + "','"
         cQuery += x_obs + "')"
         oQuery := oQuery := oServer:Query( cQuery )
         IF oQuery:NetErr()
            msginfo( 'Erro na Inclusão : ' + oQuery:Error() )
            return( nil )
         ENDIF
         oQuery:Destroy()
         form_dados.RELEASE
      ENDIF
   ELSEIF parametro == 2
      v_id := AllTrim( valor_coluna( 'grid_cpag', 'form_cpag', 1 ) )
      IF Empty( x_fornecedor ) .OR. Empty( x_forma ) .OR. Empty( x_data ) .OR. Empty( x_valor )
         msginfo( 'Obrigatório preencher os campos : Fornecedor, Forma Pagamento, Data e Valor', 'Atenção' )
         return( nil )
      ELSE
         cQuery := "update cpagar set "
         cQuery += "id_fornecedor='" + x_fornecedor + "',"
         cQuery += "nome_fornecedor='" + x_nome_fornecedor + "',"
         cQuery += "id_fpagamento='" + x_forma + "',"
         cQuery += "nome_fpagamento='" + x_nome_fpagamento + "',"
         cQuery += "vencimento='" + td( x_data ) + "',"
         cQuery += "valor='" + x_valor + "',"
         cQuery += "numero_doc='" + x_numero + "',"
         cQuery += "observacao='" + x_obs + "'"
         cQuery += " where id='" + v_id + "'"
         oQuery := oQuery := oServer:Query( cQuery )
         IF oQuery:NetErr()
            msginfo( 'Erro na Alteração : ' + oQuery:Error() )
            return( nil )
         ENDIF
         oQuery:Destroy()
         form_dados.RELEASE
      ENDIF
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION excluir_cpag()

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_id := AllTrim( valor_coluna( 'grid_cpag', 'form_cpag', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_cpag', 'form_cpag', 3 ) )

   IF Empty( v_id )
      msginfo( 'Faça uma pesquisa antes, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Confirma a exclusão de : ' + v_nome + ' ?' )
      cQuery := 'delete from cpagar where id = ' + v_id
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
STATIC FUNCTION pesq_fornecedor()

   LOCAL x_fornec := form_dados.tbox_001.VALUE
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}

   IF x_fornec <> 0
      oQuery := oServer:Query( 'select * from fornecedores where id = ' + AllTrim( Str( x_fornec ) ) )
      IF oQuery:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 5 ) )
      SetProperty( 'form_dados', 'lbl_nome_fornecedor', 'value', x_nome )
      return( nil )
   ENDIF

   DEFINE WINDOW form_pesquisa ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 400 ;
         TITLE 'Pesquisa Fornecedor' ;
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

   oQuery := oServer:Query( 'select * from fornecedores order by nome' )

   FOR i := 1 TO oQuery:LastRec()
      oRow := oQuery:GetRow( i )
      add ITEM { AllTrim( Str( oRow:fieldGet( 1 ), 6 ) ), AllTrim( oRow:fieldGet( 5 ) ) } TO grid_pesquisa OF form_pesquisa
      oQuery:Skip( 1 )
   NEXT i

   oQuery:Destroy()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION passa_pesquisa()

   LOCAL v_id := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_pesquisa', 'form_pesquisa', 2 ) )

   SetProperty( 'form_dados', 'tbox_001', 'value', Val( v_id ) )
   SetProperty( 'form_dados', 'lbl_nome_fornecedor', 'value', v_nome )

   form_pesquisa.RELEASE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesq_fpagamento()

   LOCAL x_fpagamento := form_dados.tbox_002.VALUE
   LOCAL x_nome := ''
   LOCAL oQuery
   LOCAL oRow := {}

   IF x_fpagamento <> 0
      oQuery := oServer:Query( 'select * from fpagamentos where id = ' + AllTrim( Str( x_fpagamento ) ) )
      IF oQuery:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 2 ) )
      SetProperty( 'form_dados', 'lbl_nome_forma_pagamento', 'value', x_nome )
      return( nil )
   ENDIF

   DEFINE WINDOW form_pesquisa ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 400 ;
         TITLE 'Pesquisa Forma Pagamento' ;
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
STATIC FUNCTION alimenta_pesquisa_2()

   LOCAL i := 0
   LOCAL oQuery
   LOCAL oRow := {}

   oQuery := oServer:Query( 'select * from fpagamentos order by nome' )

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

   SetProperty( 'form_dados', 'tbox_002', 'value', Val( v_id ) )
   SetProperty( 'form_dados', 'lbl_nome_forma_pagamento', 'value', v_nome )

   form_pesquisa.RELEASE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION baixar_cpag()

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_id := AllTrim( valor_coluna( 'grid_cpag', 'form_cpag', 1 ) )
   LOCAL v_fornec := AllTrim( valor_coluna( 'grid_cpag', 'form_cpag', 3 ) )

   IF Empty( v_id )
      msginfo( 'Faça uma pesquisa antes, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Confirma a baixa de : ' + v_fornec + ' ?' )
      cQuery := "update cpagar set "
      cQuery += "baixado='" + '2' + "'"
      cQuery += " where id='" + v_id + "'"
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Alteração : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
      msginfo( 'A informação : ' + v_fornec + ' - foi baixada' )
   ENDIF

return( nil )
