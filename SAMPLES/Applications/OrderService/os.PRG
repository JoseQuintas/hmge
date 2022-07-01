/*
  sistema     : ordem de serviço
  programa    : principal
  compilador  : harbour
  lib gráfica : minigui extended
*/

#include 'minigui.ch'
#include 'miniprint.ch'
/*
#define WM_USER              0x400
#define TTM_SETTIPBKCOLOR   (WM_USER + 19)
#define TTM_SETTIPTEXTCOLOR (WM_USER + 20)
#define TTM_SETTITLE        (WM_USER + 32)
#define TTI_NONE                0
#define TTI_INFO                1
#define TTI_WARNING             2
#define TTI_ERROR               3
*/
FUNCTION Main()

   LOCAL aColors

   PUBLIC nChave_ForPro := 0
   PUBLIC nCod_Usu_Log := 0
   PUBLIC cNom_Usu_Log := Space( 30 )
   PUBLIC nTotServ := 0
   PUBLIC nTotPeca := 0
   PUBLIC lLog_IAE := .F.
   PUBLIC nNumOS := 0
   PUBLIC lEncerrada := .F.
   PUBLIC _numero_os := ''
  /*
    tabela de cores
  */
   PUBLIC _AZUL := { 071, 089, 135 }
   PUBLIC _AMARELO := { 255, 255, 225 }
   PUBLIC _AMARELO2 := { 255, 255, 255 }
   PUBLIC _CIANO := { 000, 255, 255 }
   PUBLIC _AZUL_CLARO := { 000, 118, 236 }
   PUBLIC _AZUL_CLARO_2 := { 113, 184, 255 }
   PUBLIC _VERMELHO := { 242, 079, 000 }
   PUBLIC _LARANJA := { 255, 126, 064 }
   PUBLIC _VERDE := { 000, 102, 051 }
   PUBLIC _AZUL_ESCURO := { 000, 000, 128 }
   PUBLIC _CINZA := { 128, 128, 128 }
         /*
           cores para labels, botões e janelas
         */
   PUBLIC _branco_001 := { 255, 255, 255 }
   PUBLIC _preto_001 := { 000, 000, 000 }
   PUBLIC _azul_001 := { 108, 108, 255 }
   PUBLIC _azul_002 := { 000, 000, 255 }
   PUBLIC _azul_003 := { 032, 091, 164 }
   PUBLIC _azul_004 := { 023, 063, 115 }
   PUBLIC _azul_005 := { 071, 089, 135 }
   PUBLIC _azul_006 := { 000, 073, 148 }
   PUBLIC _laranja_001 := { 255, 163, 070 }
   PUBLIC _verde_001 := { 000, 094, 047 }
   PUBLIC _verde_002 := { 000, 089, 045 }
   PUBLIC _cinza_001 := { 128, 128, 128 }
   PUBLIC _cinza_002 := { 192, 192, 192 }
   PUBLIC _cinza_003 := { 229, 229, 229 }
   PUBLIC _cinza_004 := { 226, 226, 226 }
   PUBLIC _cinza_005 := { 245, 245, 245 }
   PUBLIC _vermelho_001 := { 255, 000, 000 }
   PUBLIC _vermelho_002 := { 160, 000, 000 }
   PUBLIC _vermelho_003 := { 190, 000, 000 }
   PUBLIC _amarelo_001 := { 255, 255, 225 }
   PUBLIC _amarelo_002 := { 255, 255, 121 }
   PUBLIC _marrom_001 := { 143, 103, 080 }
   PUBLIC _ciano_001 := { 215, 255, 255 }
   PUBLIC _grid_001 := _branco_001
   PUBLIC _grid_002 := { 210, 233, 255 }
   PUBLIC _super := { 128, 128, 255 }
   PUBLIC _acompanhamento := { 255, 255, 220 }
   /*
     cores para get e botão
   */
   PUBLIC _fundo_get := { 255, 255, 255 }
   PUBLIC _letra_get := { 000, 000, 255 }
   PUBLIC _letra_get_1 := { 000, 000, 255 }
   PUBLIC _letra_botao := WHITE
   PUBLIC _fundo_botao := BLACK
   /*
     setamentos de ambiente
     alguns vindos do clipper outros da minigui
   */
   SET autoadjust ON
   SET DELETED ON
   SET INTERACTIVECLOSE query
   SET DATE british
   SET CENTURY ON
   SET EPOCH TO 1980
   SET browsesync ON
   SET MULTIPLE OFF WARNING
   SET tooltipballoon ON
   SET NAVIGATION EXTENDED
   SET codepage TO portuguese
   SET language TO portuguese
   /*
     definir fonte do menu
   */
   DEFINE FONT font_1 FONTNAME 'verdana' SIZE 10
   fonte_menu := GetFontHandle( 'font_1' )
   /*
     setar estilo do menu
   */
   SET MENUSTYLE EXTENDED
   SET MENUCURSOR FULL
   SET MENUSEPARATOR SINGLE RIGHTALIGN
   SET MENUITEM BORDER FLAT
   /*
     reconfigurar cores do menu
   */
   aColors := GetMenuColors()
   aColors[ MNUCLR_SEPARATOR1 ] := RGB( 128, 128, 128 ) // linha separadora
   aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 236, 233, 216 ) // fundo bmp do ítem
   aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 236, 233, 216 ) // fundo bmp do ítem
   aColors[ MNUCLR_MENUBARBACKGROUND1 ] := GetSysColor( 15 )
   aColors[ MNUCLR_MENUBARBACKGROUND2 ] := GetSysColor( 15 )
   aColors[ MNUCLR_MENUBARSELECTEDITEM1 ] := RGB( 198, 211, 239 )
   aColors[ MNUCLR_MENUBARSELECTEDITEM2 ] := RGB( 198, 211, 239 )
   aColors[ MNUCLR_MENUITEMSELECTEDTEXT ] := RGB( 000, 000, 000 )
   aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := RGB( 255, 255, 255 ) // fundo geral menu
   aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := RGB( 255, 255, 255 ) // fundo geral menu
   aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB( 049, 105, 198 ) // bordas do ítem
   aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB( 049, 105, 198 ) // bordas do ítem
   aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB( 049, 105, 198 ) // bordas do ítem
   aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB( 049, 105, 198 ) // bordas do ítem
   aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB( 198, 211, 239 ) // fundo ítem menu
   aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB( 198, 211, 239 ) // fundo ítem menu
   SetMenuColors( aColors )
      /*
        montar janela principal
      */
   DEFINE WINDOW form_main ;
         AT 000, 000 ;
         WIDTH 1300 ;
         HEIGHT 600 ;
         TITLE 'Ordem de Serviço 8.0 :: versão MySQL' ;
         MAIN ;
         ICON 'icone' ;
         noshow ;
         ON INIT entrada()
                /*
                  mostrar imagem de fundo : wallpaper
                */
      DEFINE IMAGE img_001
         ROW 0
         COL 0
         HEIGHT getdesktopheight()
         WIDTH getdesktopwidth()
         PICTURE 'wallpaper'
         stretch .T.
      END IMAGE
                /*
                  montar o menu principal do programa
                */
      DEFINE MAIN MENU OF form_main
         DEFINE POPUP 'Tabelas'
            MENUITEM 'Grupos (produtos)' ACTION grupos() IMAGE 'img_grupos' FONT fonte_menu
            MENUITEM 'Formas de Pagamento' ACTION fpagamentos() IMAGE 'img_fpagamento' FONT fonte_menu
            MENUITEM 'Funcionários' ACTION funcionarios() IMAGE 'img_grupos' FONT fonte_menu
         END POPUP
         DEFINE POPUP 'Financeiro'
            MENUITEM 'Contas a Receber' ACTION creceber() IMAGE 'img_crec' FONT fonte_menu
            MENUITEM 'Contas a Pagar' ACTION cpagar() IMAGE 'img_cpag' FONT fonte_menu
         END POPUP
         DEFINE POPUP '&Relatórios'
            MENUITEM 'Ordem de Serviço em Aberto (por período)' ACTION OS_af_periodo() IMAGE 'img_relatorios' FONT fonte_menu
            MENUITEM 'Ordem de Serviço Encerrada (por período)' ACTION OS_af2_periodo() IMAGE 'img_relatorios' FONT fonte_menu
            SEPARATOR
            MENUITEM 'Ordem de Serviço em Aberto (por técnico e período)' ACTION OS_tecnico_1() IMAGE 'img_relatorios' FONT fonte_menu
            MENUITEM 'Ordem de Serviço Encerrada (por técnico e período)' ACTION OS_tecnico_2() IMAGE 'img_relatorios' FONT fonte_menu
            SEPARATOR
            MENUITEM 'Ordem de Serviço em Aberto (por cliente e período)' ACTION OS_cliente_1() IMAGE 'img_relatorios' FONT fonte_menu
            MENUITEM 'Ordem de Serviço Encerrada (por cliente e período)' ACTION OS_cliente_2() IMAGE 'img_relatorios' FONT fonte_menu
            SEPARATOR
            MENUITEM 'Posição do Estoque de Produtos' ACTION Posicao_Estoque() IMAGE 'img_relatorios' FONT fonte_menu
            MENUITEM 'Produtos em Falta no Estoque' ACTION Produtos_em_Falta() IMAGE 'img_relatorios' FONT fonte_menu
         END POPUP
      END MENU
  /*
    botões menu principal : estilo metro
  */
      DEFINE BUTTONEX button_menu_1
         ROW 30
         COL 10
         WIDTH 300
         HEIGHT 150
         PICTURE 'atendimento'
         CAPTION 'ATENDIMENTO' + CRLF + 'Registro da OS'
         ACTION atendimento()
         vertical .T.
         lefttext .F.
         FLAT .T.
         FONTSIZE 12
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 244, 244, 244 }
         uppertext .F.
         nohotlight .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_menu_2
         ROW 30
         COL 320
         WIDTH 300
         HEIGHT 150
         PICTURE 'andamento'
         CAPTION 'ACOMPANHAR' + CRLF + 'Andamento de uma OS'
         ACTION acompanha()
         vertical .T.
         lefttext .F.
         FLAT .T.
         FONTSIZE 12
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 244, 244, 244 }
         uppertext .F.
         nohotlight .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_menu_3
         ROW 190
         COL 10
         WIDTH 300
         HEIGHT 150
         PICTURE 'produtos'
         CAPTION 'Produtos'
         ACTION produtos()
         vertical .T.
         lefttext .F.
         FLAT .T.
         FONTSIZE 12
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 244, 244, 244 }
         uppertext .F.
         nohotlight .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_menu_4
         ROW 190
         COL 320
         WIDTH 145
         HEIGHT 150
         PICTURE 'fornecedores'
         CAPTION 'Fornecedores'
         ACTION fornecedores()
         vertical .T.
         lefttext .F.
         FLAT .T.
         FONTSIZE 12
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 244, 244, 244 }
         uppertext .F.
         nohotlight .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_menu_5
         ROW 190
         COL 475
         WIDTH 145
         HEIGHT 150
         PICTURE 'clientes'
         CAPTION 'Clientes'
         ACTION clientes()
         vertical .T.
         lefttext .F.
         FLAT .T.
         FONTSIZE 12
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 244, 244, 244 }
         uppertext .F.
         nohotlight .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_menu_6
         ROW 350
         COL 320
         WIDTH 300
         HEIGHT 075
         CAPTION 'Sair do Programa'
         ACTION form_main.RELEASE
         vertical .T.
         lefttext .F.
         FLAT .T.
         FONTSIZE 12
         FONTBOLD .T.
         FONTCOLOR { 255, 255, 255 }
         BACKCOLOR { 212, 65, 50 }
         uppertext .F.
         nohotlight .F.
         noxpstyle .T.
      END BUTTONEX
      // ----------------------------*
      // *
      // agenda de compromissos   *
      // *
      // ----------------------------*
       /*
         cabeçalho
       */
      @ 000, getdesktopwidth() - 400 LABEL label_agenda_1 WIDTH 400 HEIGHT 35 VALUE '' backcolor { 26, 40, 77 }
      @ 002, getdesktopwidth() - 400 LABEL label_agenda_2 WIDTH 400 HEIGHT 30 VALUE 'Agenda' ;
         FONT 'verdana' SIZE 14 FONTCOLOR GRAY BOLD transparent CENTERALIGN VCENTERALIGN
               /*
                 calendário
               */
      @ 036, getdesktopwidth() - 400 MONTHCALENDAR calendario ;
         VALUE Date() ;
         FONT 'verdana' SIZE 14 ;
         WEEKNUMBERS ;
         NOTABSTOP ;
         ON CHANGE mostra_data()
           /*
             define largura e altura do calendário
           */
      form_main.calendario.WIDTH := 400
      form_main.calendario.HEIGHT := 170
                 /*
                   grid compromissos
                 */
      DEFINE GRID grid_compromissos
         COL getdesktopwidth() - 400
         ROW 207
         WIDTH 400
         HEIGHT getdesktopheight() - 427
         HEADERS { 'id', 'status', 'hora', 'descricao' }
         WIDTHS { 1, 30, 50, 530 }
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .F.
         BACKCOLOR { 200, 200, 200 }
         FONTCOLOR BLACK
         nolines .T.
         showheaders .F.
      END GRID
               /*
                 frame
               */
      DEFINE LABEL label_frame
         COL getdesktopwidth() - 400
         ROW getdesktopheight() - 220
         WIDTH 630
         HEIGHT 500
         VALUE ''
         transparent .F.
         BACKCOLOR WHITE
      END LABEL
              /*
                   botões
                */
      DEFINE BUTTONEX button_marcarok
         COL getdesktopwidth() - 315
         ROW getdesktopheight() - 210
         WIDTH 100
         HEIGHT 40
         CAPTION 'OK'
         ACTION marcar_ok()
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 200, 200, 200 }
         FLAT .T.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_imprimir
         COL getdesktopwidth() - 210
         ROW getdesktopheight() - 210
         WIDTH 100
         HEIGHT 40
         CAPTION 'Agenda'
         ACTION periodo_agenda()
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 200, 200, 200 }
         FLAT .T.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_excluir
         COL getdesktopwidth() - 105
         ROW getdesktopheight() - 210
         WIDTH 100
         HEIGHT 40
         CAPTION 'Excluir'
         ACTION excluir_agenda()
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 200, 200, 200 }
         FLAT .T.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_gravar
         COL getdesktopwidth() - 105
         ROW getdesktopheight() - 130
         WIDTH 100
         HEIGHT 40
         CAPTION 'Gravar'
         ACTION gravar_agenda()
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR BLACK
         BACKCOLOR { 200, 200, 200 }
         FLAT .T.
         noxpstyle .T.
      END BUTTONEX
           /*
             campos : hora e compromisso
           */
      @ getdesktopheight() - 165, getdesktopwidth() - 390 TEXTBOX gbox_hora HEIGHT 28 WIDTH 60 ;
         FONT 'verdana' SIZE 10 BACKCOLOR WHITE FONTCOLOR BLUE INPUTMASK '99:99'
      @ getdesktopheight() - 165, getdesktopwidth() - 320 TEXTBOX tbox_descricao WIDTH 315 HEIGHT 28 FONT 'verdana' SIZE 10 ;
         BACKCOLOR WHITE FONTCOLOR BLUE UPPERCASE MAXLENGTH 50
                /*
                  informações do programa, do cliente e do suporte
                */
      DEFINE LABEL nome_programa_001
         parent form_main
         COL 5
         ROW getdesktopheight() - 230
         VALUE 'OSFácil'
         WIDTH 200
         HEIGHT 050
         FONTNAME 'tahoma'
         FONTSIZE 022
         FONTBOLD .T.
         FONTCOLOR _super
         transparent .T.
      END LABEL
      DEFINE LABEL nome_programa_002
         parent form_main
         COL 120
         ROW getdesktopheight() - 230
         VALUE '2017'
         WIDTH 200
         HEIGHT 050
         FONTNAME 'tahoma'
         FONTSIZE 022
         FONTBOLD .T.
         FONTCOLOR _laranja_001
         transparent .T.
      END LABEL
      DEFINE LABEL softhouse_001
         parent form_main
         COL 5
         ROW getdesktopheight() - 190
         VALUE 'Este software foi desenvolvido por'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _branco_001
         transparent .T.
      END LABEL
      DEFINE LABEL softhouse_002
         parent form_main
         COL 5
         ROW getdesktopheight() - 175
         VALUE 'NOME DA SUA EMPRESA'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 014
         FONTBOLD .T.
         FONTCOLOR _amarelo_001
         transparent .T.
      END LABEL
      DEFINE LABEL suporte_001
         parent form_main
         COL 5
         ROW getdesktopheight() - 135
         VALUE 'Para obter suporte técnico deste produto'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR { 160, 160, 160 }
         transparent .T.
      END LABEL
      DEFINE LABEL suporte_002
         parent form_main
         COL 5
         ROW getdesktopheight() - 120
         VALUE 'Telefone: (99) 9999-9999'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR { 160, 160, 160 }
         transparent .T.
      END LABEL
      DEFINE LABEL suporte_003
         parent form_main
         COL 5
         ROW getdesktopheight() - 105
         VALUE 'E-mail:suaempresa@seudominio.com.br'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR { 160, 160, 160 }
         transparent .T.
      END LABEL

   END WINDOW

   sendmessagestring( getformtooltiphandle( 'form_main' ), TTM_SETTITLE, TTI_WARNING, 'ajuda rápida' )
   sendmessage( getformtooltiphandle( 'form_main' ), TTM_SETTIPBKCOLOR, RGB( 128, 128, 255 ), 0 )
   sendmessage( getformtooltiphandle( 'form_main' ), TTM_SETTIPTEXTCOLOR, RGB( 255, 255, 255 ), 0 )

   form_main.CENTER
   form_main.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION entrada()

   LOCAL v_hostname := 'localhost'
   LOCAL v_usuario := 'root'
   LOCAL v_senha := ''
   LOCAL v_database := 'os'

   PUBLIC oServer

   VariaveisPUB()

   oServer := TMySQLServer():New( v_hostname, v_usuario, v_senha )

   IF oServer:NetErr()
      msginfo( 'Houve um erro de conexão com o servidor de banco de dados MySQL :: ' + oServer:Error(), 'Atenção' )
      form_main.RELEASE
   ELSE
      criar_banco_de_dados( v_database )
      criar_tabelas()
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION criar_banco_de_dados( p_basededados )

   LOCAL i := 0
   LOCAL aBaseDeDadosExistentes := {}

   p_basededados := Lower( p_basededados )

   // antes de criar verifica se a base de dados já existe
   aBaseDeDadosExistentes := oServer:ListDBs()

   // verifica se ocorreu algum erro
   IF oServer:NetErr()
      msginfo( 'Erro verificando lista de base de dados' + oServer:Error(), 'Atenção' )
      form_main.RELEASE
   ENDIF

   // verifica se na array aBaseDeDadosExistentes tem a base de dados
   IF AScan( aBaseDeDadosExistentes, Lower( p_basededados ) ) != 0
      // conecta na base de dados
      oServer:SelectDB( p_basededados )
      // verifica se ocorreu algum erro
      IF oServer:NetErr()
         msginfo( 'Houve um erro tentando conectar à base de dados ' + p_basededados + ' , ERRO : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
   ELSE
      // cria a base de dados
      oServer:CreateDatabase( p_basededados )
      // verifica se ocorreu algum erro
      IF oServer:NetErr()
         msginfo( 'Houve um erro na criação da base de dados ' + p_basededados + ' , ERRO : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ELSE
         // conecta na base de dados
         oServer:SelectDB( p_basededados )
         // verifica se ocorreu algum erro
         IF oServer:NetErr()
            msginfo( 'Houve um erro tentando conectar à base de dados ' + p_basededados + ' , ERRO : ' + oServer:Error(), 'Atenção' )
            form_main.RELEASE
         ENDIF
      ENDIF
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION criar_tabelas()

   LOCAL i := 0
   //LOCAL aTabelasExistentes := {}
   LOCAL cQuery
   LOCAL oQuery

   // carrega todas as tabelas no array
   // aTabelasExistentes := oServer:ListTables()

   // clientes
   IF oServer:TableExists( 'clientes' )
   ELSE
      cQuery := 'CREATE TABLE clientes (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'cnpj char(18),' + ;
         'cpf char(15),' + ;
         'insc_est char(20),' + ;
         'nome char(40),' + ;
         'fixo char(10),' + ;
         'celular char(10),' + ;
         'endereco char(40),' + ;
         'numero char(10),' + ;
         'complemento char(20),' + ;
         'bairro char(20),' + ;
         'cidade char(30),' + ;
         'uf char(02),' + ;
         'cep char(08),' + ;
         'email char(50),' + ;
         'aniv_dia int,' + ;
         'aniv_mes int,' + ;
         'data_cad date,' + ;
         'hora_cad char(08),' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : clientes : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // fornecedores
   IF oServer:TableExists( 'fornecedores' )
   ELSE
      cQuery := 'CREATE TABLE fornecedores (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'cnpj char(18),' + ;
         'cpf char(15),' + ;
         'insc_est char(20),' + ;
         'nome char(40),' + ;
         'fixo char(10),' + ;
         'celular char(10),' + ;
         'endereco char(40),' + ;
         'numero char(10),' + ;
         'complemento char(20),' + ;
         'bairro char(20),' + ;
         'cidade char(30),' + ;
         'uf char(02),' + ;
         'cep char(08),' + ;
         'email char(50),' + ;
         'data_cad date,' + ;
         'hora_cad char(08),' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : fornecedores : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // funcionários
   IF oServer:TableExists( 'funcionarios' )
   ELSE
      cQuery := 'CREATE TABLE funcionarios (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'cpf char(15),' + ;
         'nome char(40),' + ;
         'fixo char(10),' + ;
         'celular char(10),' + ;
         'endereco char(40),' + ;
         'numero char(10),' + ;
         'complemento char(20),' + ;
         'bairro char(20),' + ;
         'cidade char(30),' + ;
         'uf char(02),' + ;
         'cep char(08),' + ;
         'email char(50),' + ;
         'data_cad date,' + ;
         'hora_cad char(08),' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : funcionarios : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // ordem de serviço
   IF oServer:TableExists( 'os' )
   ELSE
      cQuery := 'CREATE TABLE os (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'numero int,' + ;
         'data date,' + ;
         'hora char(08),' + ;
         'cliente int,' + ;
         'nome_cliente char(40),' + ;
         'atendente int,' + ;
         'nome_atendente char(40),' + ;
         'condicao int,' + ;
         'aprovado int,' + ;
         'data_prevista date,' + ;
         'hora_prevista char(08),' + ;
         'data_saida date,' + ;
         'hora_saida char(08),' + ;
         'data_garantia date,' + ;
         'aparelho char(40),' + ;
         'marca char(30),' + ;
         'modelo char(30),' + ;
         'numero_serie char(30),' + ;
         'estado_aparelho int,' + ;
         'condicao_aparelho int,' + ;
         'defeito char(70),' + ;
         'observacao blob,' + ;
         'encerrado int,' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : os : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // produtos
   IF oServer:TableExists( 'produtos' )
   ELSE
      cQuery := 'CREATE TABLE produtos (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'nome char(40),' + ;
         'tipo int,' + ;
         'codigo_barras char(25),' + ;
         'unidade int,' + ;
         'id_grupo int,' + ;
         'custo float(12,2),' + ;
         'preco float(12,2),' + ;
         'custo_medio float(12,2),' + ;
         'comissao float(10,2),' + ;
         'estoque_atual int,' + ;
         'estoque_minimo int,' + ;
         'aplicacao char(50),' + ;
         'cla_fiscal char(10),' + ;
         'icms float(10,2),' + ;
         'ipi float(10,2),' + ;
         'iss float(10,2),' + ;
         'baixa_estoque int,' + ;
         'data_cad date,' + ;
         'hora_cad char(08),' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : produtos : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // serviços da ordem de serviço
   IF oServer:TableExists( 'os_servicos' )
   ELSE
      cQuery := 'CREATE TABLE os_servicos (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'id_os int,' + ;
         'numero_os int,' + ;
         'servico int,' + ;
         'nome_servico char(40),' + ;
         'quantidade int,' + ;
         'unitario float(12,2),' + ;
         'subtotal float(12,2),' + ;
         'tecnico int,' + ;
         'data date,' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : os_servicos : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // peças da ordem de serviço
   IF oServer:TableExists( 'os_pecas' )
   ELSE
      cQuery := 'CREATE TABLE os_pecas (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'id_os int,' + ;
         'numero_os int,' + ;
         'peca int,' + ;
         'nome_peca char(40),' + ;
         'quantidade int,' + ;
         'unitario float(12,2),' + ;
         'subtotal float(12,2),' + ;
         'tecnico int,' + ;
         'data date,' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : os_pecas : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // grupos
   IF oServer:TableExists( 'grupos' )
   ELSE
      cQuery := 'CREATE TABLE grupos (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'nome char(30),' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : grupos : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // formas de pagamento
   IF oServer:TableExists( 'fpagamentos' )
   ELSE
      cQuery := 'CREATE TABLE fpagamentos (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'nome char(30),' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : forma de pagamentos : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // contas a pagar
   IF oServer:TableExists( 'cpagar' )
   ELSE
      cQuery := 'CREATE TABLE cpagar (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'data_inclusao DATE,' + ;
         'hora_inclusao CHAR(10),' + ;
         'baixado CHAR(1),' + ;
         'id_fornecedor INT,' + ;
         'nome_fornecedor CHAR(40),' + ;
         'id_fpagamento INT,' + ;
         'nome_fpagamento CHAR(20),' + ;
         'vencimento DATE,' + ;
         'valor FLOAT(12,2),' + ;
         'numero_doc CHAR(20),' + ;
         'observacao CHAR(40),' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : contas a pagar : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // contas a receber
   IF oServer:TableExists( 'creceber' )
   ELSE
      cQuery := 'CREATE TABLE creceber (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'data_inclusao DATE,' + ;
         'hora_inclusao CHAR(10),' + ;
         'baixado CHAR(1),' + ;
         'id_cliente INT,' + ;
         'nome_cliente CHAR(40),' + ;
         'id_fpagamento INT,' + ;
         'nome_fpagamento CHAR(20),' + ;
         'vencimento DATE,' + ;
         'valor FLOAT(12,2),' + ;
         'numero_doc CHAR(20),' + ;
         'observacao CHAR(40),' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : contas a receber : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // usuários
   IF oServer:TableExists( 'usuarios' )
   ELSE
      cQuery := 'CREATE TABLE usuarios (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'nome char(20),' + ;
         'login char(10),' + ;
         'senha char(10),' + ;
         'tipo int,' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : usuarios : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   // agenda
   IF oServer:TableExists( 'agenda' )
   ELSE
      cQuery := 'CREATE TABLE agenda (id INT UNSIGNED NOT NULL AUTO_INCREMENT,' + ;
         'data DATE,' + ;
         'hora CHAR(10),' + ;
         'assunto CHAR(40),' + ;
         'status_1 INT,' + ;
         'PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8'
      oQuery := oServer:Query( cQuery )
      IF oServer:NetErr()
         msginfo( 'Erro criando tabela : agenda : ' + oServer:Error(), 'Atenção' )
         form_main.RELEASE
      ENDIF
      oQuery:Destroy()
   ENDIF

   tela_login()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION tela_login()

   DEFINE WINDOW form_login ;
         AT 0, 0 ;
         WIDTH 700 ;
         HEIGHT 500 ;
         TITLE 'Tela de Login' ;
         ICON 'icone' ;
         modal ;
         noautorelease ;
         NOSIZE ;
         nosysmenu

      DEFINE IMAGE img_loginlogo
         ROW 0
         COL 0
         HEIGHT 347
         WIDTH 700
         PICTURE 'tela_login'
         stretch .F.
      END IMAGE

      DEFINE LABEL label_versao
         COL form_login.WIDTH -210
         ROW 315
         VALUE 'versão 2017, revisão 016.008'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .F.
         FONTCOLOR { 0, 0, 0 }
         transparent .T.
      END LABEL
     /*
      login e senha
     */
      DEFINE LABEL label_usuario
         COL 305
         ROW 360
         VALUE 'Usuário'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR { 0, 0, 0 }
         transparent .T.
      END LABEL
      @ 360, 375 TEXTBOX gbox_login ;
         OF form_login ;
         HEIGHT 27 ;
         WIDTH 120 ;
         VALUE '' ;
         MAXLENGTH 100 ;
         FONT 'verdana' SIZE 10 ;
         backcolor { 255, 244, 206 } ;
         fontcolor { 0, 0, 0 }
      DEFINE LABEL label_senha
         COL 505
         ROW 360
         VALUE 'Senha'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR { 0, 0, 0 }
         transparent .T.
      END LABEL
      @ 360, 565 TEXTBOX gbox_senha ;
         OF form_login ;
         HEIGHT 27 ;
         WIDTH 120 ;
         VALUE '' ;
         MAXLENGTH 100 ;
         FONT 'verdana' SIZE 10 ;
         backcolor { 255, 244, 206 } ;
         fontcolor { 0, 0, 0 } ;
         password
            /*
               botão : acessar
           */
      DEFINE BUTTONEX button_acessar
         ROW form_login.HEIGHT -100
         COL 485
         WIDTH 200
         HEIGHT 60
         PICTURE 'acessar'
         CAPTION 'Acessar o programa'
         ACTION acessar_programa()
         vertical .F.
         lefttext .F.
         FLAT .F.
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR BLACK
      END BUTTONEX
     /*
      criar usuário
     */
      DEFINE BUTTONEX button_criarusuario
         ROW form_login.HEIGHT -100
         COL 250
         WIDTH 200
         HEIGHT 60
         PICTURE 'login'
         CAPTION 'Criar usuário'
         ACTION criar_usuario()
         vertical .F.
         lefttext .F.
         FLAT .F.
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR BLACK
      END BUTTONEX
     /*
      sair
     */
      DEFINE BUTTONEX button_sairlogin
         ROW form_login.HEIGHT -100
         COL 5
         WIDTH 200
         HEIGHT 60
         PICTURE 'exit'
         CAPTION 'Sair do programa'
         ACTION ( form_login.RELEASE, form_main.release )
         vertical .F.
         lefttext .F.
         FLAT .F.
         FONTSIZE 10
         FONTBOLD .T.
         FONTCOLOR BLACK
      END BUTTONEX

   END WINDOW

   form_login.CENTER
   form_login.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION acessar_programa()

   LOCAL oQuery
   LOCAL oRow := {}

   LOCAL v_login := AllTrim( form_login.gbox_login.value )
   LOCAL v_senha := AllTrim( form_login.gbox_senha.value )

   oQuery := oServer:Query( "select * from usuarios where login='" + v_login + "' and senha='" + v_senha + "' order by login" )

   IF oQuery:Eof()
      msginfo( 'Login ou Senha incorretos, tecle ENTER', 'Atenção' )
      form_login.gbox_login.setfocus
      return( nil )
   ELSE
      oRow := oQuery:GetRow( 1 )
      v_nome := AllTrim( oRow:fieldGet( 2 ) )
      tipo_do_usuario := oRow:fieldGet( 5 )
      oQuery:Destroy()
      form_login.RELEASE
      form_main.show
      form_main.MAXIMIZE
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION criar_usuario()

   LOCAL x_nome := ''
   LOCAL x_login := ''
   LOCAL x_senha := ''

   DEFINE WINDOW form_dados ;
         AT 000, 000 ;
         WIDTH 650 ;
         HEIGHT 180 ;
         TITLE 'Criar usuário' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      // entrada de dados
      @ 010, 010 LABEL label_nome ;
         OF form_dados ;
         VALUE 'Nome Completo' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR BLACK ;
         transparent
      @ 030, 010 TEXTBOX tbox_nome ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 200 ;
         VALUE x_nome ;
         MAXLENGTH 030 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR WHITE ;
         FONTCOLOR BLUE ;
         UPPERCASE
      // ----------
      @ 010, 220 LABEL label_login ;
         OF form_dados ;
         VALUE 'Login' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR BLACK ;
         transparent
      @ 030, 220 TEXTBOX tbox_login ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 200 ;
         VALUE x_login ;
         MAXLENGTH 010 ;
         FONT 'tahoma' SIZE 010 ;
         BACKCOLOR WHITE ;
         FONTCOLOR BLUE ;
         UPPERCASE
      // ----------
      @ 010, 430 LABEL label_senha ;
         OF form_dados ;
         VALUE 'Senha' ;
         AUTOSIZE ;
         FONT 'tahoma' SIZE 010 ;
         BOLD ;
         FONTCOLOR BLACK ;
         transparent
      @ 030, 430 TEXTBOX tbox_senha ;
         OF form_dados ;
         HEIGHT 027 ;
         WIDTH 200 ;
         VALUE x_senha ;
         MAXLENGTH 010 ;
         FONT 'tahoma' SIZE 010 ;
         password ;
         BACKCOLOR WHITE ;
         FONTCOLOR BLUE ;
         UPPERCASE

      // linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_dados.HEIGHT -090
         VALUE ''
         WIDTH form_dados.WIDTH
         HEIGHT 001
         BACKCOLOR BLACK
         transparent .F.
      END LABEL

      // botões
      DEFINE BUTTONEX button_ok
         PICTURE 'gravar'
         COL form_dados.WIDTH -225
         ROW form_dados.HEIGHT -085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar_novo_usuario()
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informações digitadas'
         FLAT .T.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE 'retornar'
         COL form_dados.WIDTH -100
         ROW form_dados.HEIGHT -085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_dados.RELEASE
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela sem gravar informações'
         FLAT .T.
         noxpstyle .T.
      END BUTTONEX

   END WINDOW

   form_dados.CENTER
   form_dados.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION gravar_novo_usuario()

   LOCAL cQuery, oQuery

   LOCAL v_tipo := '1'
   LOCAL v_nome := AllTrim( form_dados.tbox_nome.value )
   LOCAL v_login := AllTrim( form_dados.tbox_login.value )
   LOCAL v_senha := AllTrim( form_dados.tbox_senha.value )

   IF Empty( v_nome ) .OR. Empty( v_login ) .OR. Empty( v_senha )
      msginfo( 'Obrigatório preencher os campos : Nome, Login e Senha', 'Atenção' )
      return( nil )
   ELSE
      cQuery := "insert into usuarios (nome,login,senha,tipo) values ('"
      cQuery += v_nome + "','"
      cQuery += v_login + "','"
      cQuery += v_senha + "','"
      cQuery += v_tipo + "')"
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Inclusão : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
      form_dados.RELEASE
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
FUNCTION VariaveisPUB()

   PUBLIC aEstado := {}
   PUBLIC aCondicao := {}
   PUBLIC aTipo := {}
   PUBLIC aClassifica := {}
   PUBLIC aUnidade := {}
   PUBLIC aDiaSemana := {}
   PUBLIC aTipoFJ := {}
   PUBLIC aSexo := {}
   PUBLIC aLogradouro := {}
   PUBLIC aUf := {}
   PUBLIC aSimNao := {}

   AAdd( aSimNao, 'Sim' )
   AAdd( aSimNao, 'Não' )

   AAdd( aCondicao, 'Montado' )
   AAdd( aCondicao, 'Desmontado' )

   AAdd( aEstado, 'Novo' )
   AAdd( aEstado, 'Bom' )
   AAdd( aEstado, 'Ruim' )

   AAdd( aTipo, 'Peça' )
   AAdd( aTipo, 'Serviço' )

   AAdd( aClassifica, 'Ótimo' )
   AAdd( aClassifica, 'Bom' )
   AAdd( aClassifica, 'Regular' )

   AAdd( aUnidade, 'UN' )
   AAdd( aUnidade, 'PC' )
   AAdd( aUnidade, 'KG' )
   AAdd( aUnidade, 'H.' )

   AAdd( aDiaSemana, 'Domingo' )
   AAdd( aDiaSemana, 'Segunda' )
   AAdd( aDiaSemana, 'Terça' )
   AAdd( aDiaSemana, 'Quarta' )
   AAdd( aDiaSemana, 'Quinta' )
   AAdd( aDiaSemana, 'Sexta' )
   AAdd( aDiaSemana, 'Sábado' )

   AAdd( aTipoFJ, 'Jurídica' )
   AAdd( aTipoFJ, 'Física' )

   AAdd( aSexo, 'Feminino ' )
   AAdd( aSexo, 'Masculino' )

   AAdd( aLogradouro, 'Rua' )
   AAdd( aLogradouro, 'Avenida' )
   AAdd( aLogradouro, 'Rodovia' )
   AAdd( aLogradouro, 'Travessa' )
   AAdd( aLogradouro, 'Alameda' )
   AAdd( aLogradouro, 'BR' )
   AAdd( aLogradouro, 'Km' )
   AAdd( aLogradouro, 'Trevo' )
   AAdd( aLogradouro, 'Via' )

   AAdd( aUf, 'AC' ) // acre
   AAdd( aUf, 'AL' ) // alagoas
   AAdd( aUf, 'AM' ) // amazonas
   AAdd( aUf, 'AP' ) // amapá
   AAdd( aUf, 'BA' ) // bahia
   AAdd( aUf, 'CE' ) // ceará
   AAdd( aUf, 'DF' ) // distrito federal
   AAdd( aUf, 'ES' ) // espírito santo
   AAdd( aUf, 'GO' ) // goiás
   AAdd( aUf, 'MA' ) // maranhão
   AAdd( aUf, 'MG' ) // minas gerais
   AAdd( aUf, 'MS' ) // mato grosso do sul
   AAdd( aUf, 'MT' ) // mato grosso
   AAdd( aUf, 'PA' ) // pará
   AAdd( aUf, 'PB' ) // paraíba
   AAdd( aUf, 'PE' ) // pernambuco
   AAdd( aUf, 'PI' ) // piauí
   AAdd( aUf, 'PR' ) // paraná
   AAdd( aUf, 'RJ' ) // rio de janeiro
   AAdd( aUf, 'RN' ) // rio grande do norte
   AAdd( aUf, 'RO' ) // rondonia
   AAdd( aUf, 'RR' ) // roraima
   AAdd( aUf, 'RS' ) // rio grande do sul
   AAdd( aUf, 'SC' ) // santa catarina
   AAdd( aUf, 'SE' ) // sergipe
   AAdd( aUf, 'SP' ) // são paulo
   AAdd( aUf, 'TO' ) // tocantins

return( Nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION gravar_agenda()

   LOCAL cQuery, oQuery

   LOCAL v_data := form_main.calendario.VALUE
   LOCAL v_hora := AllTrim( form_main.gbox_hora.value )
   LOCAL v_assunto := AllTrim( form_main.tbox_descricao.value )

   IF Empty( v_hora )
      msgalert( 'Hora não pode estar em branco, tecle ENTER', 'Atenção' )
      form_main.gbox_hora.setfocus
      return( nil )
   ENDIF

   IF Empty( v_assunto )
      msgalert( 'Assunto não pode estar em branco, tecle ENTER', 'Atenção' )
      form_main.tbox_descricao.setfocus
      return( nil )
   ENDIF

   cQuery := "insert into agenda (data,hora,assunto) values ('"
   cQuery += td( v_data ) + "','"
   cQuery += v_hora + "','"
   cQuery += v_assunto + "')"
   oQuery := oQuery := oServer:Query( cQuery )
   IF oQuery:NetErr()
      msginfo( 'Erro na Inclusão : ' + oQuery:Error() )
      return( nil )
   ENDIF
   oQuery:Destroy()

   SetProperty( 'form_main', 'gbox_hora', 'value', '' )
   SetProperty( 'form_main', 'tbox_descricao', 'value', '' )

   atualiza_agenda()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION atualiza_agenda()

   LOCAL oQuery
   LOCAL n_i := 0
   LOCAL oRow := {}

   LOCAL v_data := form_main.calendario.VALUE
   LOCAL x_data_inicio := td( form_main.calendario.value )

   DELETE ITEM ALL FROM grid_compromissos OF form_main

   oQuery := oServer:Query( "select * from agenda where data='" + x_data_inicio + "' order by data" )

   FOR n_i := 1 TO oQuery:LastRec()

      oRow := oQuery:GetRow( n_i )

      add ITEM { Str( oRow:fieldGet( 1 ) ), iif( oRow:fieldGet( 5 ) == 2, 'OK', '-' ), SubStr( oRow:fieldGet( 3 ), 1, 2 ) + ':' + SubStr( oRow:fieldGet( 3 ), 4, 2 ), oRow:fieldGet( 4 ) } TO grid_compromissos OF form_main

      oQuery:Skip( 1 )

   NEXT n_i

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION mostra_data()

   LOCAL v_data_completa
   LOCAL v_data := form_main.calendario.VALUE

   v_data_1 := AllTrim( SubStr( DToC( v_data ), 1, 2 ) )
   v_data_2 := AllTrim( dia_da_semana( v_data, 1 ) )
   v_data_3 := AllTrim( mes_do_ano( Month( v_data ), 2 ) ) + ' ' + SubStr( DToC( v_data ), 7, 4 )

   v_data_completa := v_data_2 + ', ' + v_data_1 + ' de ' + v_data_3

   SetProperty( 'form_main', 'label_agenda_2', 'value', AllTrim( v_data_completa ) )

   atualiza_agenda()

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION excluir_agenda()

   LOCAL cQuery
   LOCAL oQuery

   LOCAL v_id := valor_coluna( 'grid_compromissos', 'form_main', 1 )

   IF Empty( v_id )
      msginfo( 'Selecione primeiro uma informação na agenda, e depois clique no botão excluir', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Confirma a exclusão ?' )
      cQuery := 'delete from agenda where id = ' + v_id
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Exclusão : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
      atualiza_agenda()
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION marcar_ok()

   LOCAL cQuery
   LOCAL oQuery
   LOCAL v_id := valor_coluna( 'grid_compromissos', 'form_main', 1 )

   IF Empty( v_id )
      msginfo( 'Selecione primeiro uma informação na agenda, e depois clique no botão marcar OK', 'Atenção' )
      return( nil )
   ENDIF

   IF msgyesno( 'Marcar como OK esse compromisso ?', 'Marcar OK' )
      cQuery := "update agenda set status_1 = 2 where id='" + v_id + "'"
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Alteração : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
      atualiza_agenda()
   ELSE
      cQuery := "update agenda set status_1 = 1 where id='" + v_id + "'"
      oQuery := oQuery := oServer:Query( cQuery )
      IF oQuery:NetErr()
         msginfo( 'Erro na Alteração : ' + oQuery:Error() )
         return( nil )
      ENDIF
      oQuery:Destroy()
      atualiza_agenda()
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION periodo_agenda()

   LOCAL WIDTH, HEIGHT

   DEFINE WINDOW form_imprime ;
         AT 0, 0 ;
         WIDTH 400 ;
         HEIGHT 220 ;
         TITLE 'Imprimir Agenda' ;
         ICON 'icone' ;
         modal ;
         NOSIZE
     /*
       labels
     */
      @ 010, 010 LABEL lbl_de ;
         VALUE 'Inicia em' FONT 'verdana' SIZE 10 FONTCOLOR BLACK BOLD transparent
      @ 010, 200 LABEL lbl_ate ;
         VALUE 'Termina em' FONT 'verdana' SIZE 10 FONTCOLOR BLACK BOLD transparent
      @ 010, 080 datepicker dpi_de WIDTH 100 VALUE Date()
      @ 010, 290 datepicker dpi_ate WIDTH 100 VALUE Date()
         /*
             botões
           */
      DEFINE BUTTONEX button_cadastrar
         COL form_imprime.WIDTH -215
         ROW form_imprime.HEIGHT -85
         WIDTH 100
         HEIGHT 40
         CAPTION 'Imprime'
         ACTION imprime_agenda()
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .T.
         FLAT .T.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_voltar
         COL form_imprime.WIDTH -110
         ROW form_imprime.HEIGHT -85
         WIDTH 100
         HEIGHT 40
         CAPTION 'Voltar'
         ACTION form_imprime.RELEASE
         FONTNAME 'verdana'
         FONTSIZE 10
         FONTBOLD .T.
         FLAT .T.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION form_imprime.RELEASE

   END WINDOW

   form_imprime.CENTER
   form_imprime.ACTIVATE

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION imprime_agenda()

   LOCAL lSuccess
   LOCAL v_cor_texto
   LOCAL v_linha := 0
   LOCAL v_pagina := 1
   LOCAL v_data_ini := form_imprime.dpi_de.VALUE
   LOCAL v_data_fim := form_imprime.dpi_ate.VALUE

   LOCAL x_data_inicio := td( v_data_ini )
   LOCAL x_data_final := td( v_data_fim )

   LOCAL oQuery
   LOCAL n_i := 0
   LOCAL oRow := {}

   IF v_data_fim < v_data_ini
      msgalert( 'Data FINAL maior que data INICIAL, tecle ENTER', 'Atenção' )
      return( nil )
   ENDIF

   oQuery := oServer:Query( "select * from agenda where data>='" + x_data_inicio + "' and data<='" + x_data_final + "' order by data" )

   SELECT PRINTER DIALOG TO lSuccess PREVIEW

   IF lSuccess == .T.

      START PRINTDOC NAME 'Agenda de Compromissos'
      START PRINTPAGE

      cab_agenda( v_pagina, v_data_ini, v_data_fim )

      v_linha := 45

      FOR n_i := 1 TO oQuery:LastRec()

         oRow := oQuery:GetRow( n_i )

         IF oRow:fieldGet( 5 ) == 1 .OR. Empty( oRow:fieldGet( 5 ) )
            @ v_linha - 3, 010 PRINT IMAGE 'nao_feito' WIDTH 7 HEIGHT 7 STRETCH
            v_cor_texto := BLACK
         ELSEIF oRow:fieldGet( 5 ) == 2
            @ v_linha - 3, 010 PRINT IMAGE 'feito' WIDTH 7 HEIGHT 7 STRETCH
            v_cor_texto := BLUE
         ENDIF

         @ v_linha, 025 PRINT DToC( oRow:fieldGet( 2 ) ) FONT 'courier new' SIZE 10 COLOR v_cor_texto
         @ v_linha, 050 PRINT oRow:fieldGet( 3 ) FONT 'courier new' SIZE 10 COLOR v_cor_texto
         @ v_linha, 070 PRINT AllTrim( oRow:fieldGet( 4 ) ) FONT 'courier new' SIZE 10 COLOR v_cor_texto

         v_linha += 6

         IF v_linha >= 260
            END PRINTPAGE
            START PRINTPAGE
            v_pagina++
            cab_agenda( v_pagina, v_data_ini, v_data_fim )
            v_linha := 45
         ENDIF

         v_linha += 4
         @ v_linha, 000 PRINT LINE TO v_linha, 205 PENWIDTH 0.5 COLOR BLACK

         v_linha += 4

         IF v_linha >= 260
            END PRINTPAGE
            START PRINTPAGE
            v_pagina++
            cab_agenda( v_pagina, v_data_ini, v_data_fim )
            v_linha := 45
         ENDIF

         oQuery:Skip( 1 )

      NEXT n_i

      END PRINTPAGE
      END PRINTDOC

      form_imprime.RELEASE

   ENDIF

return( nil )
// -------------------------------------------------------------------------------
STATIC FUNCTION cab_agenda( p_pagina, p_data1, p_data2 )

   @ 007, 010 PRINT IMAGE 'logotipo' WIDTH 030 HEIGHT 025 STRETCH
   @ 015, 035 PRINT 'Agenda de compromissos : de ' + DToC( p_data1 ) + ' à ' + DToC( p_data2 ) FONT 'verdana' SIZE 12 BOLD

   @ 035, 000 PRINT LINE TO 035, 205 PENWIDTH 0.5 COLOR BLACK

return( nil )
