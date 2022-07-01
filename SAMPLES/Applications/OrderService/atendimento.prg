/*
  sistema     : ordem de serviço
  programa    : atendimento
  compilador  : harbour
  lib gráfica : minigui extended
*/

#include 'minigui.ch'
#include 'miniprint.ch'

FUNCTION atendimento()

   LOCAL cNumero := SubStr( AllTrim( Str( hb_Random(123513,999999 ) ) ), 1, 6 )
   nNumOS := Val( cNumero )

   PUBLIC m_nome_servico := ''
   PUBLIC m_nome_peca := ''
   PUBLIC m_nome_tecnico := ''

   PUBLIC n_soma_total := 0

   DEFINE WINDOW form_atendimento ;
         AT 0, 0 ;
         WIDTH 1000 ;
         HEIGHT 700 ;
         TITLE 'Atendimento' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

     /*
       número da OS
     */
      @ 225, 740 LABEL lbl_numero_os ;
         WIDTH 300 ;
         VALUE 'OS Nº : ' + AllTrim( Str( nNumOS ) ) ;
         FONT 'verdana' SIZE 18 BOLD ;
         fontcolor { 176, 0, 0 }
     /*
       labels
     */
      @ 005, 010 LABEL lbl_cliente ;
         VALUE 'Cliente' ;
         AUTOSIZE ;
         FONT 'verdana' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 025, 080 LABEL lbl_nome_cliente ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'verdana' SIZE 014 BOLD ;
         FONTCOLOR BLACK transparent
      @ 060, 080 LABEL lbl_endereco_cliente ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'verdana' SIZE 012 ;
         FONTCOLOR BLACK transparent
      @ 080, 080 LABEL lbl_baicid_cliente ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'verdana' SIZE 012 ;
         FONTCOLOR BLACK transparent
      @ 100, 080 LABEL lbl_complemento_cliente ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'verdana' SIZE 012 ;
         FONTCOLOR BLACK transparent
      @ 130, 080 LABEL lbl_fixo_cliente ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'verdana' SIZE 016 BOLD ;
         FONTCOLOR BLACK transparent
      @ 170, 080 LABEL lbl_celular_cliente ;
         VALUE '' ;
         AUTOSIZE ;
         FONT 'verdana' SIZE 016 BOLD ;
         FONTCOLOR BLACK transparent

      @ 005, 560 LABEL lbl_aparelho ;
         VALUE 'Aparelho' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 040, 560 LABEL lbl_marca ;
         VALUE 'Marca' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 075, 560 LABEL lbl_modelo ;
         VALUE 'Modelo' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 110, 560 LABEL lbl_numserie ;
         VALUE 'Nº Série' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 145, 560 LABEL lbl_defeito ;
         VALUE 'Defeito' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 180, 560 LABEL lbl_estado ;
         VALUE 'Estado' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 180, 745 LABEL lbl_condicao ;
         VALUE 'Condição' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
     /*
       textbox
     */
      @ 025, 010 TEXTBOX tbox_cliente ;
         WIDTH 50 ;
         VALUE 0 ;
         NUMERIC ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON enter pesq_cliente()
      @ 005, 635 TEXTBOX tbox_aparelho ;
         HEIGHT 027 ;
         WIDTH 350 ;
         VALUE '' ;
         MAXLENGTH 050 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 040, 635 TEXTBOX tbox_marca ;
         HEIGHT 027 ;
         WIDTH 350 ;
         VALUE '' ;
         MAXLENGTH 050 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 075, 635 TEXTBOX tbox_modelo ;
         HEIGHT 027 ;
         WIDTH 350 ;
         VALUE '' ;
         MAXLENGTH 050 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110, 635 TEXTBOX tbox_numserie ;
         HEIGHT 027 ;
         WIDTH 350 ;
         VALUE '' ;
         MAXLENGTH 040 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 145, 635 TEXTBOX tbox_defeito ;
         HEIGHT 027 ;
         WIDTH 350 ;
         VALUE '' ;
         MAXLENGTH 060 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 180, 635 comboboxex cbo_estado ;
         WIDTH 100 ;
         ITEMS aEstado ;
         VALUE 1
      @ 180, 815 comboboxex cbo_condicao ;
         WIDTH 100 ;
         ITEMS aCondicao ;
         VALUE 1
     /*
               linha separadora - meio da tela
              */
      DEFINE LABEL linha_rodape_1
         COL 0
         ROW 220
         VALUE ''
         WIDTH form_atendimento.WIDTH
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
         ACTION servico_incluir( cNumero )
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
         ACTION servico_excluir()
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
         headers { 'ID', 'Descrição', 'Qtd.', 'Unit.R$', 'Sub-Total R$', 'Técnico', 'ID Tec.' } ;
         widths { 1, 300, 60, 100, 120, 100, 1 } ;
         FONT 'courier new' SIZE 10 BOLD ;
         BACKCOLOR _AMARELO2 ;
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
         ACTION pecas_incluir( cNumero )
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
         ACTION pecas_excluir()
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
         headers { 'ID', 'Descrição', 'Qtd.', 'Unit.R$', 'Sub-Total R$', 'Técnico', 'ID Tec.' } ;
         widths { 1, 300, 60, 100, 120, 100, 1 } ;
         FONT 'courier new' SIZE 10 BOLD ;
         BACKCOLOR _AMARELO2 ;
         FONTCOLOR BLACK
     /*
       previsão entrega
     */
      @ 300, 750 LABEL lbl_previsao ;
         VALUE 'PREVISÃO DE ENTREGA' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 12 BOLD ;
         FONTCOLOR BLUE transparent
      @ 330, 770 LABEL lbl_data_entrega ;
         VALUE 'Data' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 350, 770 datepicker dpi_data_entrega ;
         WIDTH 100 ;
         VALUE Date()
      @ 330, 880 LABEL lbl_hora_entrega ;
         VALUE 'Hora' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 BOLD ;
         FONTCOLOR _preto_001 transparent
      @ 350, 880 TEXTBOX tbox_hora_entrega ;
         HEIGHT 027 ;
         WIDTH 50 ;
         VALUE '' ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         INPUTMASK '99:99'
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
         ROW form_atendimento.HEIGHT -090
         VALUE ''
         WIDTH form_atendimento.WIDTH
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL
              /*
                botões
              */
      DEFINE BUTTONEX button_recibo
         PICTURE 'imprimir'
         COL form_atendimento.WIDTH -515
         ROW form_atendimento.HEIGHT -085
         WIDTH 140
         HEIGHT 050
         CAPTION 'Recibo OS'
         ACTION recibo_os( cNumero )
         FONTBOLD .T.
         TOOLTIP 'Imprimir o Recibo desta Ordem de Serviço para o Cliente'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_imprime
         PICTURE 'imprimir'
         COL form_atendimento.WIDTH -370
         ROW form_atendimento.HEIGHT -085
         WIDTH 140
         HEIGHT 050
         CAPTION 'Imprime OS'
         ACTION imprime_os( cNumero )
         FONTBOLD .T.
         TOOLTIP 'Imprimir esta Ordem de Serviço'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_ok
         PICTURE 'img_gravar'
         COL form_atendimento.WIDTH -225
         ROW form_atendimento.HEIGHT -085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Gravar OS'
         ACTION gravar_os( cNumero )
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informações digitadas'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE 'img_voltar'
         COL form_atendimento.WIDTH -100
         ROW form_atendimento.HEIGHT -085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_atendimento.RELEASE
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela sem gravar informações'
         FLAT .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.RELEASE

   END WINDOW

   form_atendimento.CENTER
   form_atendimento.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION pesq_cliente()

   LOCAL x_cliente := form_atendimento.tbox_cliente.VALUE
   LOCAL x_nome := ''
   LOCAL x_endereco := ''
   LOCAL x_baicid := ''
   LOCAL x_complem := ''
   LOCAL x_fixo := ''
   LOCAL x_celular := ''
   LOCAL oQuery
   LOCAL oRow := {}

   IF x_cliente <> 0
      oQuery := oServer:Query( 'select nome,endereco,numero,bairro,cidade,complemento,fixo,celular from clientes where id = ' + AllTrim( Str( x_cliente ) ) )
      IF oQuery:NetErr()
         msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oRow := oQuery:GetRow( 1 )
      x_nome := AllTrim( oRow:fieldGet( 1 ) )
      x_endereco := AllTrim( oRow:fieldGet( 2 ) ) + ', ' + AllTrim( oRow:fieldGet( 3 ) )
      x_baicid := AllTrim( oRow:fieldGet( 4 ) ) + ', ' + AllTrim( oRow:fieldGet( 5 ) )
      x_complem := AllTrim( oRow:fieldGet( 6 ) )
      x_fixo := AllTrim( oRow:fieldGet( 7 ) )
      x_celular := AllTrim( oRow:fieldGet( 8 ) )
      SetProperty( 'form_atendimento', 'lbl_nome_cliente', 'value', x_nome )
      SetProperty( 'form_atendimento', 'lbl_endereco_cliente', 'value', x_endereco )
      SetProperty( 'form_atendimento', 'lbl_baicid_cliente', 'value', x_baicid )
      SetProperty( 'form_atendimento', 'lbl_complemento_cliente', 'value', x_complem )
      SetProperty( 'form_atendimento', 'lbl_fixo_cliente', 'value', x_fixo )
      SetProperty( 'form_atendimento', 'lbl_celular_cliente', 'value', x_celular )
      return( nil )
   ENDIF

   DEFINE WINDOW form_pesquisa ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 400 ;
         TITLE 'Pesquisa Cliente' ;
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

   oQuery := oServer:Query( 'select id,nome from clientes order by nome' )

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

   LOCAL x_cliente := Val( v_id )
   LOCAL x_nome := ''
   LOCAL x_endereco := ''
   LOCAL x_baicid := ''
   LOCAL x_complem := ''
   LOCAL x_fixo := ''
   LOCAL x_celular := ''
   LOCAL oQuery
   LOCAL oRow := {}

   oQuery := oServer:Query( 'select nome,endereco,numero,bairro,cidade,complemento,fixo,celular from clientes where id = ' + AllTrim( Str( x_cliente ) ) )
   IF oQuery:NetErr()
      msginfo( 'Erro de Pesquisa : ' + oQuery:Error() )
      return( nil )
   ENDIF
   oRow := oQuery:GetRow( 1 )
   x_nome := AllTrim( oRow:fieldGet( 1 ) )
   x_endereco := AllTrim( oRow:fieldGet( 2 ) ) + ', ' + AllTrim( oRow:fieldGet( 3 ) )
   x_baicid := AllTrim( oRow:fieldGet( 4 ) ) + ', ' + AllTrim( oRow:fieldGet( 5 ) )
   x_complem := AllTrim( oRow:fieldGet( 6 ) )
   x_fixo := AllTrim( oRow:fieldGet( 7 ) )
   x_celular := AllTrim( oRow:fieldGet( 8 ) )
   SetProperty( 'form_atendimento', 'tbox_cliente', 'value', Val( v_id ) )
   SetProperty( 'form_atendimento', 'lbl_nome_cliente', 'value', x_nome )
   SetProperty( 'form_atendimento', 'lbl_baicid_cliente', 'value', x_baicid )
   SetProperty( 'form_atendimento', 'lbl_complemento_cliente', 'value', x_complem )
   SetProperty( 'form_atendimento', 'lbl_fixo_cliente', 'value', x_fixo )
   SetProperty( 'form_atendimento', 'lbl_celular_cliente', 'value', x_celular )

   form_pesquisa.RELEASE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION servico_excluir()

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_id := AllTrim( valor_coluna( 'grid_servicos', 'form_atendimento', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_servicos', 'form_atendimento', 2 ) )

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
      msginfo( 'A informação : ' + v_nome + ' - foi excluída' )
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION servico_incluir( p_numero_os )

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
      SetProperty( 'form_inclui_servico', 'tbox_servico', 'value', 0 )
      SetProperty( 'form_inclui_servico', 'txt_quantidade', 'value', 0 )
      SetProperty( 'form_inclui_servico', 'txt_unitario', 'value', 0 )
      SetProperty( 'form_inclui_servico', 'tbox_tecnico', 'value', 0 )
      SetProperty( 'form_inclui_servico', 'lbl_nome_servico', 'value', '' )
      SetProperty( 'form_inclui_servico', 'lbl_nome_tecnico', 'value', '' )
      add ITEM { AllTrim( x_1 ), m_nome_servico, x_2, x_3, Str( n_subtotal, 12, 2 ), m_nome_tecnico, x_4 } TO grid_servicos OF form_atendimento
      n_soma_total := n_soma_total + n_subtotal
      SetProperty( 'form_atendimento', 'lbl_total_os', 'value', trans( n_soma_total, '@E 999,999.99' ) )
   ENDIF

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
STATIC FUNCTION pecas_excluir()

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_id := AllTrim( valor_coluna( 'grid_pecas', 'form_atendimento', 1 ) )
   LOCAL v_nome := AllTrim( valor_coluna( 'grid_pecas', 'form_atendimento', 2 ) )

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
STATIC FUNCTION pecas_incluir( p_numero_os )

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
      SetProperty( 'form_inclui_peca', 'tbox_peca', 'value', 0 )
      SetProperty( 'form_inclui_peca', 'txt_quantidade', 'value', 0 )
      SetProperty( 'form_inclui_peca', 'txt_unitario', 'value', 0 )
      SetProperty( 'form_inclui_peca', 'tbox_tecnico', 'value', 0 )
      SetProperty( 'form_inclui_peca', 'lbl_nome_peca', 'value', '' )
      SetProperty( 'form_inclui_peca', 'lbl_nome_tecnico', 'value', '' )
      add ITEM { AllTrim( x_1 ), m_nome_peca, x_2, x_3, Str( n_subtotal, 12, 2 ), m_nome_tecnico, x_4 } TO grid_pecas OF form_atendimento
      n_soma_total := n_soma_total + n_subtotal
      SetProperty( 'form_atendimento', 'lbl_total_os', 'value', trans( n_soma_total, '@E 999,999.99' ) )
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
STATIC FUNCTION gravar_os( p_numero_os )

   LOCAL oRow_2
   LOCAL oRow_3
   LOCAL n_i := 0
   LOCAL v_qtd := 0
   LOCAL v_id_prod := 0
   LOCAL v_soma := 0
   LOCAL cQuery, cQuery_2, cQuery_3
   LOCAL oQuery, oQuery_2, oQuery_3, oQuery_4

   LOCAL x_numero := p_numero_os
   LOCAL x_data := Date()
   LOCAL x_hora := Time()
   LOCAL x_cliente := AllTrim( Str( form_atendimento.tbox_cliente.value ) )
   LOCAL x_nome_cliente := AllTrim( form_atendimento.lbl_nome_cliente.value )
   LOCAL x_condicao := AllTrim( Str( form_atendimento.cbo_condicao.value ) )
   LOCAL x_data_prevista := form_atendimento.dpi_data_entrega.VALUE
   LOCAL x_hora_prevista := AllTrim( form_atendimento.tbox_hora_entrega.value )
   LOCAL x_aparelho := AllTrim( form_atendimento.tbox_aparelho.value )
   LOCAL x_marca := AllTrim( form_atendimento.tbox_marca.value )
   LOCAL x_modelo := AllTrim( form_atendimento.tbox_modelo.value )
   LOCAL x_numero_serie := AllTrim( form_atendimento.tbox_numserie.value )
   LOCAL x_estado_aparelho := AllTrim( Str( form_atendimento.cbo_estado.value ) )
   LOCAL x_defeito := AllTrim( form_atendimento.tbox_defeito.value )

   IF Empty( m_nome_tecnico )
      msgalert( 'Nenhum SERVIÇO ou PEÇA foi selecionado', 'Atenção' )
      return( nil )
   ENDIF

   IF x_cliente == '0'
      msginfo( 'Obrigatório preencher os campos', 'Atenção' )
      return( nil )
   ELSE
          /*
            grava OS
          */
      cQuery := "insert into os (numero,data,hora,cliente,nome_cliente,condicao_aparelho,data_prevista,hora_prevista,aparelho,marca,modelo,numero_serie,estado_aparelho,defeito,encerrado,nome_atendente) values ('"

      cQuery += x_numero + "','"
      cQuery += td( x_data ) + "','"
      cQuery += x_hora + "','"
      cQuery += x_cliente + "','"
      cQuery += x_nome_cliente + "','"
      cQuery += x_condicao + "','"
      cQuery += td( x_data_prevista ) + "','"
      cQuery += x_hora_prevista + "','"
      cQuery += x_aparelho + "','"
      cQuery += x_marca + "','"
      cQuery += x_modelo + "','"
      cQuery += x_numero_serie + "','"
      cQuery += x_estado_aparelho + "','"
      cQuery += x_defeito + "','"
      cQuery += '0' + "','"
      cQuery += m_nome_tecnico + "')"

      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Inclusão : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
         /*
           baixa estoque peças
         */
      oQuery_2 := oServer:Query( "select * from os_pecas where numero_os='" + AllTrim( x_numero ) + "' order by numero_os" )
      FOR n_i := 1 TO oQuery_2:LastRec()
         v_qtd := 0
         v_soma := 0
         oRow_2 := oQuery_2:GetRow( n_i )
         v_qtd := oRow_2:fieldGet( 6 )
         v_id_prod := oRow_2:fieldGet( 4 )
         oQuery_3 := oServer:Query( "select * from produtos where id='" + AllTrim( Str( v_id_prod ) ) + "' order by id" )
         oRow_3 := oQuery_3:GetRow( 1 )
         v_soma := ( oRow_3:fieldGet( 11 ) - v_qtd )
         cQuery_3 := "update produtos set estoque_atual='" + AllTrim( Str( v_soma ) ) + "' where id='" + AllTrim( Str( v_id_prod ) ) + "'"
         oQuery_4 := oQuery_4 := oServer:Query( cQuery_3 )
         IF oQuery_4:NetErr()
            msginfo( 'Erro na operação : ' + oQuery_4:Error() )
            return( nil )
         ENDIF
         oQuery_2:Skip( 1 )
         oQuery_3:Destroy()
      NEXT n_i
      form_atendimento.RELEASE
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION recibo_os( p_numero_os )

   LOCAL n_linha := 60

   SELECT PRINTER DIALOG PREVIEW
   START PRINTDOC NAME 'Gerenciador de impressão'
   START PRINTPAGE

   cabecalho_recibo_os( p_numero_os )

   @ n_linha, 020 PRINT 'Data/Hora Atendimento' FONT 'courier new' SIZE 12
   @ n_linha, 100 PRINT 'Data/Hora Previsão Entrega' FONT 'courier new' SIZE 12
   n_linha += 5
   @ n_linha, 020 PRINT DToC( Date() ) + ' / ' + Time() FONT 'courier new' SIZE 12 BOLD
   @ n_linha, 100 PRINT DToC( form_atendimento.dpi_data_entrega.value ) + ' / ' + AllTrim( form_atendimento.tbox_hora_entrega.value ) FONT 'courier new' SIZE 12 BOLD

   n_linha += 10

   @ n_linha, 020 PRINT 'DADOS DO CLIENTE' FONT 'courier new' SIZE 12 BOLD
   n_linha += 10
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_nome_cliente.value ) FONT 'courier new' SIZE 12 BOLD
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_endereco_cliente.value ) FONT 'courier new' SIZE 12
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_baicid_cliente.value ) FONT 'courier new' SIZE 12
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_complemento_cliente.value ) FONT 'courier new' SIZE 12
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_fixo_cliente.value ) + '   ' + AllTrim( form_atendimento.lbl_celular_cliente.value ) FONT 'courier new' SIZE 12

   n_linha += 10

   @ n_linha, 010 PRINT LINE TO n_linha, 205 PENWIDTH 0.5 COLOR _preto_001

   n_linha += 10

   @ n_linha, 040 PRINT 'Aparelho    : ' + AllTrim( form_atendimento.tbox_aparelho.value ) FONT 'courier new' SIZE 12
   n_linha += 5
   @ n_linha, 040 PRINT 'Marca       : ' + AllTrim( form_atendimento.tbox_marca.value ) FONT 'courier new' SIZE 12
   n_linha += 5
   @ n_linha, 040 PRINT 'Modelo      : ' + AllTrim( form_atendimento.tbox_modelo.value ) FONT 'courier new' SIZE 12
   n_linha += 5
   @ n_linha, 040 PRINT 'Nº de Série : ' + AllTrim( form_atendimento.tbox_numserie.value ) FONT 'courier new' SIZE 12

   n_linha += 10

   @ n_linha, 040 PRINT 'Defeito Apresentado  : ' + AllTrim( form_atendimento.tbox_defeito.value ) FONT 'courier new' SIZE 12

   n_linha += 10

   @ n_linha, 040 PRINT 'Estado do Aparelho   : ' + aEstado[ form_atendimento.cbo_estado.value ] FONT 'courier new' SIZE 12
   n_linha += 5
   @ n_linha, 040 PRINT 'Condição do Aparelho : ' + aCondicao[ form_atendimento.cbo_condicao.value ] FONT 'courier new' SIZE 12

   n_linha += 50

   @ n_linha, 070 PRINT LINE TO n_linha, 205 PENWIDTH 0.5 COLOR _preto_001
   n_linha += 3
   @ n_linha, 120 PRINT 'Assinatura do Cliente' FONT 'courier new' SIZE 12

   rodape()

   END PRINTPAGE
   END PRINTDOC

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION cabecalho_recibo_os( p_numero_os )

   @ 007, 010 PRINT IMAGE 'logotipo' WIDTH 030 HEIGHT 025 STRETCH
   @ 010, 050 PRINT 'Empresa Teste & Teste Ltda' FONT 'verdana' SIZE 012 BOLD
   @ 015, 050 PRINT 'CNPJ : 99.999.999/9999-99 - Insc.Estadual : 154954554620-XX' FONT 'verdana' SIZE 010
   @ 018, 050 PRINT 'Rua Mal Floriano Peixoto, 8437 - Centro - São Paulo/SP' FONT 'verdana' SIZE 010
   @ 021, 050 PRINT 'Telefone : (11) 9999-9999 - empresateste@empresa.com.br' FONT 'verdana' SIZE 010
   @ 028, 050 PRINT 'Nº da OS : ' + p_numero_os FONT 'verdana' SIZE 014 BOLD

   @ 035, 000 PRINT LINE TO 035, 205 PENWIDTH 0.5 COLOR _preto_001

   @ 040, 065 PRINT 'RECIBO DE ENTREGA' FONT 'verdana' SIZE 018 BOLD

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION imprime_os( p_numero_os )

   LOCAL oQuery_1, oQuery_2
   LOCAL n_i := 0
   LOCAL oRow_1 := {}
   LOCAL oRow_2 := {}

   LOCAL n_linha := 50

   LOCAL nCod_Cliente := 0
   LOCAL nSub_Servico := 0
   LOCAL nTot_Servico := 0
   LOCAL nSub_Peca := 0
   LOCAL nTot_Peca := 0
   LOCAL nTotal_OS := 0

   SELECT PRINTER DIALOG PREVIEW
   START PRINTDOC NAME 'Gerenciador de impressão'
   START PRINTPAGE

   cabecalho_os( p_numero_os )

   @ n_linha, 020 PRINT 'Data/Hora Atendimento' FONT 'courier new' SIZE 10
   @ n_linha, 100 PRINT 'Data/Hora Previsão Entrega' FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 020 PRINT DToC( Date() ) + ' / ' + Time() FONT 'courier new' SIZE 10 BOLD
   @ n_linha, 100 PRINT DToC( form_atendimento.dpi_data_entrega.value ) + ' / ' + AllTrim( form_atendimento.tbox_hora_entrega.value ) FONT 'courier new' SIZE 10 BOLD

   n_linha += 8

   @ n_linha, 020 PRINT 'DADOS DO CLIENTE' FONT 'courier new' SIZE 10 BOLD
   n_linha += 6
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_nome_cliente.value ) FONT 'courier new' SIZE 10 BOLD
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_endereco_cliente.value ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_baicid_cliente.value ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_complemento_cliente.value ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT AllTrim( form_atendimento.lbl_fixo_cliente.value ) + '   ' + AllTrim( form_atendimento.lbl_celular_cliente.value ) FONT 'courier new' SIZE 10

   n_linha += 5
   @ n_linha, 010 PRINT LINE TO n_linha, 205 PENWIDTH 0.5 COLOR _preto_001
   n_linha += 5

   @ n_linha, 040 PRINT 'Aparelho             : ' + AllTrim( form_atendimento.tbox_aparelho.value ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Marca                : ' + AllTrim( form_atendimento.tbox_marca.value ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Modelo               : ' + AllTrim( form_atendimento.tbox_modelo.value ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Nº de Série          : ' + AllTrim( form_atendimento.tbox_numserie.value ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Defeito Apresentado  : ' + AllTrim( form_atendimento.tbox_defeito.value ) FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Estado do Aparelho   : ' + aEstado[ form_atendimento.cbo_estado.value ] FONT 'courier new' SIZE 10
   n_linha += 5
   @ n_linha, 040 PRINT 'Condição do Aparelho : ' + aCondicao[ form_atendimento.cbo_condicao.value ] FONT 'courier new' SIZE 10

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
