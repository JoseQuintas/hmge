* **************************************
* author Brunello Pulix
* Cagliari (Italy)
* brunellopulix@gmail.com
* placed in the public domain
* **************************************
*
*
#include 'common.ch'
#include 'hbclass.ch'
*
#ifdef ___FV3_HMG___
#include 'hmg.ch'
#else
#include 'minigui.ch'
#ifndef ___FV3_EXT___
#define ___FV3_EXT___
#endif
#endif
*
#define  Version  '2.0'
*
#ifdef ___ITA___
#define _BTN_CANCEL 'Annulla'
#define _BTN_OK     'Conferma'
#define _BTN_CLOSE  'Fine'
#else
#define _BTN_CANCEL 'Cancel'
#define _BTN_OK     'OK'
#define _BTN_CLOSE  'Close'
#endif
*
#translate NTRIM( <v1> ) => Alltrim(str(<v1>))
*
Static aResult    := {}
Static aFV3       := {}
Static nCurrent   := 0
Static nWindow    := 0
Static aArrayMem  := {}
*
Class QForm
  Data aBackColor    INIT {}
  Data aCharMask     INIT {}
  Data aColumnFields INIT {}
  Data aCtrl         INIT {}
  Data aForeColor    INIT {0,0,0}
  Data aHeaders      INIT {}
  Data aItems        INIT {}
  Data aJustify      INIT {}
  Data aHeadClick    INIT {}
  Data aCheck        INIT {}
  Data Alias         INIT ''
  Data Alignment     INIT 0
  Data aReadOnly     INIT {}
  Data aValid        INIT {}
  Data aWidths       INIT {}
  Data ToolTip
  Data bChange
  Data bDblClick
  Data bEnter
  Data bLock
  Data bLostFocus
  Data bAction1
  Data bAction2
  Data Bold          INIT .F.
  Data Border        INIT .F.
  Data Caption       INIT ''
  Data ClientEdge    INIT .F.
  Data Col           INIT 0
  Data Control       INIT ''
  Data Field         INIT ''
  Data FontName      INIT 'Arial'
  Data FontSize      INIT 9
  Data Height        INIT 23
  Data Italic        INIT .F.
  Data lCheckBox     INIT .F.
  Data lEdit         INIT .F.
  Data lEnable       INIT .F.
  Data lHorizontal   INIT .F.
  Data lMultiselect  INIT .F.
  Data Max           INIT 0
  Data Min           INIT 0
  Data nSpace        INIT 0
  Data nMaxLen       INIT 10
  Data Picture       INIT ''
  Data Row           INIT 0
  Data Type
  Data Underline     INIT .F.
  Data Value         INIT ''
  Data Width         INIT 0
  Data xOpz          INIT 0
  Data ProgId
  Data RightAlign    INIT .T.
  Data lStretch
  Data lLines        INIT .T.
  Data lShowHeaders  INIT .T.
  *
End Class
*
Class KForm3
  *
  Data   Caption
  Data   Result
  Data   Window_Name
  Data   Window_Type
  Data   aDblClick
  Data   aChange
  Data   aEnter
  Data   aLostFocus
  Data   abCheckBox
  Data   aVars
  Data   aForm
  Data   aAllCtrl
  Data   MaxCol
  Data   MaxRow
  Data   aHeight
  Data   aCargo
  Data   Row
  Data   lRowPlus
  Data   Col
  Data   nLabel
  Data   nButton
  Data   nFrame
  Data   nImage
  Data   nTab
  Data   Current
  Data   FontName
  Data   aCtrlDsbl
  Data   aCtrlFont
  Data   bInit
  Data   bPostInit
  Data   bRelease
  Data   lDbf
  Data   cFields
  *
  Method New(cType,nMenu,cCaption,bInit,bPostInit,bRelease)
  Method Show(nMenu,lZoom,nWidth,nHeight,lDebug)
  *
  Method Label2(cField,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic)
  Method TextBox(cField,nWidth,cPict,xOpz,bEnter,bLostFocus,aBackColor,aForeColor,lBold,lItalic,bChange)
  Method ComboBox(cField,nWidth,nHeight,aRay,lEdit,bChange,lDisplayValue)
  Method DatePicker(cField,nWidth)
  Method EditBox(cField,nWidth,nHeight,bChange)
  Method CheckBox(cField,nWidth,cCaption)
  Method ListBox(cField,nWidth,nHeight,aRay,lMultiSelect,bEnter,bChange,lDisplayValue)
  Method RadioGroup(cField,nWidth,aRay,lHorizontal,nSpace,aReadOnly)
  Method RtfBox(cField,nWidth,nHeight)
  Method ProgressBar(cField,nWidth,nHeight)
  Method Spinner(cField,nWidth,nMin,nMax,bAction)
  *
  Method Label(cCaption,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic)
  Method Button(cText,nWidth,nHeight,bAction,lEnable)
  Method Frame(cText,nWidth,nHeight)
  Method Activex(cField,nWidth,nHeight,cProgId)
  Method Grid(cField,nWidth,nHeight,aWidths,aHeaders,aItems,bDblClick,bChange,aJustify,aCtrl,aValid,cAlias,lCheckBox,lEdit)
  Method Browse(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines)
  Method TSBrowse(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines)
  Method Image(cImage,nWidth,nHeight,lStretch)
  *
  Method BTnTextBox(cField,nWidth,nHeight,bAction1,bAction2,lEnable,nMaxLen,RightAlign,lEdit,cFontName,nFontsize,ToolTip)
  Method ChkListBox(cField,nWidth,nHeight,aItems,bDblClick,bChange,cFontName,nFontsize,ToolTip,aCheck,lMultiselect)
  *
  Method Disable(c)
  Method Result()
  Method Okay()
  *
  Method SetFont(c,cFont,nSize)
  Method SetAllCtrl(c,cProperty,Value,x,y)
  *
  Method SetCol(x)
  Method SetRow(x)
  Method SkipRow(x)
  Method SkipCol(x)
  Method GetRow()
  Method GetCol()
  Method SetSkipRow(uValue)
  *
  Method GetButtonName(c)
  Method GetLabelName(c)
  Method SetCheckBox()
  Method SetAllCheckBox(cField,lValue)
  *
  Method Tab_Begin(nWidth,nHeight)
  Method Tab_End()
  Method Tab_BeginPage(cPage,nCol,nRow)
  Method Tab_EndPage()
  *
  Method Tree_Begin(cRoot,nWidth,nHeight,nValue)
  Method Tree_End()
  Method Tree_BeginNode(cNode,cImage)
  Method Tree_AddItem(cItem)
  Method Tree_EndNode()
  *
  Method Run_DblClick()
  Method Run_OnChange(c)
  Method Run_OnChange2()
  Method Run_OnLostFocus()
  Method Run_OnEnter()
  *
  Method OnInit(cWin)
  Method OnClose(cWin)
  *
End Class
*
*************************************
*
Method New(cType,cCaption,bInit,bPostInit,bRelease) class KForm3
  Local nPos,cWin
  *
  Default cType     To [MODAL]
  Default cCaption  To 'KForm3'
  DEFAULT bInit     To {|| __Nulla() }
  DEFAULT bPostInit To {|| __Nulla() }
  DEFAULT bRelease  To {|| __Nulla() }
  *
  cWin   := '___WIN___'+strzero(++nWindow,5)
  self:Window_Name := cWin
  self:Window_Type := cType
  self:aVars       := {}
  self:aForm       := {}
  self:abCheckBox  := {}
  self:aAllCtrl    := {}
  self:MaxCol      := 15
  self:MaxRow      := 20
  self:aHeight     := {{0,0}}
  self:Row         := 20
  self:lRowPlus    := .T.
  self:Col         := 15
  self:nLabel      := 0
  self:nButton     := 0
  self:nFrame      := 0
  self:nImage      := 0
  self:nTab        := 0
  self:Current     := 0
  self:Caption     := cCaption
  self:FontName    := 'Arial'
  self:aCtrlDsbl   := {}
  Self:aCtrlFont   := {}
  self:bInit       := bInit
  self:bPostInit   := bPostInit
  self:bRelease    := bRelease
  self:lDbf        := .F.
  self:aCargo      := {}
  self:cFields     := ''
  aArrayMem        := {}
  *
  nPos := ascan(aResult,{|a| a[1] == self:Window_Name })
  If nPos == 0
     aadd(aResult,{self:Window_Name,.F.})
  else
     aResult[nPos,2] := .F.
  Endif
  *
Return self
*
*************************************
*
Method Show(nMenu,lZoom,nWidth,nHeight,lDebug) Class KForm3
  Local i,nPos
  Local bLock
  Local cWin
  Local aRay := {}
  *
  Default nMenu   To 0
  Default lZoom   To .F.
  Default lDebug  To .F.
  Default nWidth  To 0
  Default nHeight To 0
  *
  self:aDblClick := {}
  self:aChange   := {}
  self:aLostFocus:= {}
  self:aEnter    := {}
  cWin           := self:Window_Name
  *
  If empty(self:aForm)
     self:MaxRow := 300
     self:MaxCol := 400
  Endif
  *
  self:MaxCol  += 30
  self:MaxRow  += 100
  If nMenu > 0
     self:MaxRow  += 20
  endif
  *
  If self:Window_Type == [MODAL]
     *
     If nWidth > 0 .or. nHeight > 0
        if nWidth == 0
           self:MaxCol += 10
           nWidth := self:MaxCol-9
        Endif
        DEFINE WINDOW &cWin WIDTH nWidth HEIGHT nHeight ;
           VIRTUAL WIDTH  self:MaxCol VIRTUAL HEIGHT self:MaxRow ;
           TITLE self:Caption MODAL ;
           ON INIT self:OnInit(cWin) ON RELEASE self:OnClose(cWin)
     else
        DEFINE WINDOW &cWin WIDTH self:MaxCol HEIGHT self:MaxRow ;
           TITLE self:Caption MODAL ;
           ON INIT self:OnInit(cWin) ON RELEASE self:OnClose(cWin) NOSIZE
     Endif
     *
  elseIf self:Window_Type == [MAIN]
     *
     DEFINE WINDOW &cWin WIDTH self:MaxCol HEIGHT self:MaxRow ;
        TITLE self:Caption MAIN ;
        ON INIT Self:OnInit(cWin) ON RELEASE self:OnClose(cWin)
        *
  Endif
  *
  For i := 1 To Len(self:aForm)
     *
     If lDebug
        aadd(aRay,{Self:aForm[i]:Control,Self:aForm[i]:Field,self:aForm[i]:Caption})
     Endif
     *
     self:cFields += '_'+upper(Self:aForm[i]:Field)
     *
     IF Self:aForm[i]:Control == 'TAB_BEGIN'
        *
        #ifdef ___FV3_EXT___
           DEFINE TAB &(Self:aForm[i]:Field)           ;
              AT     self:aForm[i]:Row,self:aForm[i]:Col  ;
              WIDTH  self:aForm[i]:Width                  ;
              HEIGHT self:aForm[i]:Height                 ;
              VALUE 1
              *
        #else
           *
           DEFINE TAB &(Self:aForm[i]:Field)           ;
              AT     self:aForm[i]:Row,self:aForm[i]:Col  ;
              WIDTH  self:aForm[i]:Width                  ;
              HEIGHT self:aForm[i]:Height                 ;
              VALUE 1
        #endif
        *
     ELSEIF Self:aForm[i]:Control == 'TABBEGINPAGE'
        *
        _BeginTabPage ( self:aForm[i]:Caption , )
        *
     ELSEIF Self:aForm[i]:Control == 'TREE_BEGIN'
        *
        _DefineTree (;
        (self:aForm[i]:Field) , , ;
        self:aForm[i]:Row , ;
        self:aForm[i]:Col , ;
        self:aForm[i]:Width , ;
        self:aForm[i]:Height , , , , , , , , .F. ,;
        self:aForm[i]:Value ,,,, .F. ,.F., .F., .F., .F. , .F. , Nil )
        *
     ELSEIF Self:aForm[i]:Control == 'BEGINNODE'
        *
        _DefineTreeNode (self:aForm[i]:Field, , )
        *
     ELSEIF Self:aForm[i]:Control == 'TREE_ITEM'
        *
        _DefineTreeItem (self:aForm[i]:Field, , )
        *
     ELSEIF Self:aForm[i]:Control == 'LABEL2'
        *
        _DefineLabel(                              ; // _DefineLabel(
        SELF:aForm[I]:field                       ,; // ControlName
        nil                                       ,; // ParentForm
        SELF:aForm[I]:col                         ,; // x
        SELF:aForm[I]:row                         ,; // y
        SELF:aForm[I]:caption                     ,; // Caption
        SELF:aForm[I]:width                       ,; // w
        SELF:aForm[I]:height                      ,; // h
        SELF:aForm[I]:fontname                    ,; // fontname
        SELF:aForm[I]:fontsize                    ,; // fontsize
        SELF:aForm[I]:bold                        ,; // bold
        SELF:aForm[I]:border                      ,; // BORDER
        SELF:aForm[I]:clientedge                  ,; // CLIENTEDGE
        .F.                                       ,; // HSCROLL
        .F.                                       ,; // VSCROLL
        .F.                                       ,; // TRANSPARENT
        SELF:aForm[I]:abackcolor                  ,; // aRGB_bk
        SELF:aForm[I]:aforecolor                  ,; // aRGB_font
        nil                                       ,; // ProcedureName
        nil                                       ,; // tooltip
        nil                                       ,; // HelpId
        nil                                       ,; // invisible
        SELF:aForm[I]:italic                      ,; // italic
        SELF:aForm[I]:underline                   ,; // underline
        .F.                                       ,; // strikeout
        .F.                                       ,; // autosize
        SELF:aForm[I]:alignment[3]                ,; // rightalign
        SELF:aForm[I]:alignment[2]                ,; // centeralign
        .F.                                       ,; // EndEllipses
        .F. )                                        // NoPrefix
        *
     ELSEIF Self:aForm[i]:Control == 'LABEL'
        _DefineLabel(;                               // _DefineLabel(
        self:aForm[i]:Field                       ,; // ControlName
        nil                                       ,; // ParentForm
        self:aForm[i]:Col                         ,; // x
        self:aForm[i]:Row                         ,; // y
        self:aForm[i]:Caption                     ,; // Caption
        self:aForm[i]:Width                       ,; // w
        self:aForm[i]:Height                      ,; // h
        self:aForm[i]:FontName                    ,; // fontname
        self:aForm[i]:FontSize                    ,; // fontsize
        self:aForm[i]:Bold                        ,; // bold
        self:aForm[i]:Border                      ,; // BORDER
        self:aForm[i]:ClientEdge                  ,; // CLIENTEDGE
        .F.                                       ,; // HSCROLL
        .F.                                       ,; // VSCROLL
        .F.                                       ,; // TRANSPARENT
        self:aForm[i]:aBackColor                  ,; // aRGB_bk
        self:aForm[i]:aForeColor                  ,; // aRGB_font
        nil                                       ,; // ProcedureName
        nil                                       ,; // tooltip
        nil                                       ,; // HelpId
        nil                                       ,; // invisible
        self:aForm[i]:Italic                      ,; // italic
        self:aForm[i]:Underline                   ,; // underline
        .F.                                       ,; // strikeout
        .F.                                       ,; // autosize
        self:aForm[i]:Alignment[3]                ,; // rightalign
        self:aForm[i]:Alignment[2]                ,; // centeralign
        .F.                                       ,; // EndEllipses
        .F. )                                        // NoPrefix
        *
     ELSEIF Self:aForm[i]:Control == 'TEXTBOX'
        If self:aForm[i]:Type == 'N' .and. !Empty(self:aForm[i]:Picture)
           *
           Define TextBox &(self:aForm[i]:Field)
              Row        self:aForm[i]:Row
              Col        self:aForm[i]:Col
              Value      self:aForm[i]:Value
              Width      self:aForm[i]:Width
              Height     self:aForm[i]:Height
              DataType   Numeric
              INPUTMASK  self:aForm[i]:Picture
              ONENTER    self:Run_OnEnter()
              ONCHANGE   self:Run_OnChange()
              RIGHTALIGN .T.
              BackColor  self:aForm[i]:aBackColor
              ForeColor  self:aForm[i]:aForeColor
              FontBold   self:aForm[i]:Bold
              FontItalic self:aForm[i]:Italic
              End TextBox
              *
        elseIf self:aForm[i]:Type == 'N' .and. Empty(self:aForm[i]:Picture)
           *
           Define TextBox &(self:aForm[i]:Field)
              Row        self:aForm[i]:Row
              Col        self:aForm[i]:Col
              Value      self:aForm[i]:Value
              Width      self:aForm[i]:Width
              Height     self:aForm[i]:Height
              DataType   Numeric
              ONENTER    self:Run_OnEnter()
              ONCHANGE   self:Run_OnChange()
              RIGHTALIGN .T.
              BackColor  self:aForm[i]:aBackColor
              ForeColor  self:aForm[i]:aForeColor
              FontBold   self:aForm[i]:Bold
              FontItalic self:aForm[i]:Italic
              End TextBox
              *
        elseIf self:aForm[i]:Type == 'D'
           *
           Define TextBox &(self:aForm[i]:Field)
              Row        self:aForm[i]:Row
              Col        self:aForm[i]:Col
              Value      self:aForm[i]:Value
              Width      self:aForm[i]:Width
              Height     self:aForm[i]:Height
              DataType   DATE
              ONENTER    self:Run_OnEnter()
              ONCHANGE   self:Run_OnChange()
              FontName   self:aForm[i]:FontName
              FontSize   self:aForm[i]:FontSize
              BackColor  self:aForm[i]:aBackColor
              ForeColor  self:aForm[i]:aForeColor
              FontBold   self:aForm[i]:Bold
              FontItalic self:aForm[i]:Italic
              End TextBox
              *
        else
           If Empty(self:aForm[i]:aCharMask)
              *
              If Empty(self:aForm[i]:Picture)
                 *
                 Define TextBox &(self:aForm[i]:Field)
                    Row        self:aForm[i]:Row
                    Col        self:aForm[i]:Col
                    Value      self:aForm[i]:Value
                    Width      self:aForm[i]:Width
                    Height     self:aForm[i]:Height
                    DataType   Character
                    ONENTER    self:Run_OnEnter()
                    ONCHANGE   self:Run_OnChange()
                    BackColor  self:aForm[i]:aBackColor
                    ForeColor  self:aForm[i]:aForeColor
                    FontBold   self:aForm[i]:Bold
                    FontItalic self:aForm[i]:Italic
                    End TextBox
                    *
              else
                 *
                 Define TextBox &(self:aForm[i]:Field)
                    Row        self:aForm[i]:Row
                    Col        self:aForm[i]:Col
                    Value      self:aForm[i]:Value
                    Width      self:aForm[i]:Width
                    Height     self:aForm[i]:Height
                    DataType   Character
                    INPUTMASK  self:aForm[i]:Picture
                    ONENTER    self:Run_OnEnter()
                    ONCHANGE   self:Run_OnChange()
                    BackColor  self:aForm[i]:aBackColor
                    ForeColor  self:aForm[i]:aForeColor
                    FontBold   self:aForm[i]:Bold
                    FontItalic self:aForm[i]:Italic
                    End TextBox
                    *
              endif
              *
           else
              *
              _DefineTextBox( ;
              (self:aForm[i]:Field)     ,;    // cControlName
              nil                       ,;    // cParentForm
              self:aForm[i]:Col         ,;    // nx
              self:aForm[i]:Row         ,;    // ny
              self:aForm[i]:Width       ,;    // nWidth
              self:aForm[i]:Height      ,;    // nHeight
              self:aForm[i]:Value       ,;    // cValue
              self:aForm[i]:FontName    ,;    // cFontName
              self:aForm[i]:FontSize    ,;    // nFontSize
              nil                       ,;    // ToolTip
              nil                       ,;    // nMaxLenght
              self:aForm[i]:aCharMask[1],;    // lUpper
              self:aForm[i]:aCharMask[2],;    // lLower
              .F.                       ,;    // lNumeric
              self:aForm[i]:aCharMask[3],;    // lPassword
              {|| self:Run_OnLostFocus()},;   // uLostFocus
              nil                       ,;    // uGotFocus
              {|| self:Run_OnChange()}  ,;    // uChange
              {|| self:Run_OnEnter()}   ,;    // uEnter
              .F.                       ,;    // RIGHT
              nil                       ,;    // HelpId
              .F.                       ,;    // readonly
              self:aForm[i]:Bold        ,;    // bold
              self:aForm[i]:Italic      ,;    // italic
              .F.                       ,;    // underline
              .F.                       ,;    // strikeout
              nil                       ,;    // field
              self:aForm[i]:aBackColor  ,;    // backcolor
              self:aForm[i]:aForeColor  ,;    // fontcolor
              .F.                       ,;    // invisible
              .F.                       ,;    // notabstop
              nil                       ,;    // disabledbackcolor
              nil                        )    // disabledfontcolor
              *
           endif
        endif
        *
        if !IsNil(self:aForm[i]:bEnter)
           bLock := self:aForm[i]:bEnter
           aadd(self:aEnter,{self:aVars[i,2],bLock})
        Endif
        if !IsNil(self:aForm[i]:bChange)
           bLock := self:aForm[i]:bChange
           aadd(self:aChange,{self:aVars[i,2],bLock})
        Endif
        if !IsNil(self:aForm[i]:bLostFocus)
           bLock := self:aForm[i]:bLostFocus
           aadd(self:aLostFocus,{self:aVars[i,2],bLock})
        Endif
        *
     ELSEIF Self:aForm[i]:Control == 'COMBOBOX'
        DEFINE COMBOBOX &(self:aForm[i]:Field)
           ROW         self:aForm[i]:Row
           COL         self:aForm[i]:Col
           VALUE       self:aForm[i]:Value
           WIDTH       self:aForm[i]:Width
           HEIGHT      self:aForm[i]:Height
           ITEMS       self:aForm[i]:aItems
           DISPLAYEDIT self:aForm[i]:lEdit
           ONCHANGE    self:Run_OnChange()
           END COMBOBOX
           *
           if !IsNil(self:aForm[i]:bChange)
              bLock := self:aForm[i]:bChange
              aadd(self:aChange,{self:aVars[i,2],bLock})
           Endif
           *
     ELSEIF Self:aForm[i]:Control == 'DATEPICKER'
        DEFINE DATEPICKER &(self:aForm[i]:Field)
           ROW         self:aForm[i]:Row
           COL         self:aForm[i]:Col
           VALUE       self:aForm[i]:Value
           WIDTH       self:aForm[i]:Width
           END DATEPICKER
           *
     ELSEIF Self:aForm[i]:Control == 'EDITBOX'
        DEFINE EDITBOX &(self:aForm[i]:Field)
           Row        self:aForm[i]:Row
           Col        self:aForm[i]:Col
           Value      self:aForm[i]:Value
           Width      self:aForm[i]:Width
           Height     self:aForm[i]:Height
           ONCHANGE   self:Run_OnChange()
           END EDITBOX
           *
           if !IsNil(self:aForm[i]:bChange)
              bLock := self:aForm[i]:bChange
              aadd(self:aChange,{self:aVars[i,2],bLock})
           Endif
           *
     ELSEIF Self:aForm[i]:Control == 'CHECKBOX'
        DEFINE CHECKBOX &(self:aForm[i]:Field)
           ROW       self:aForm[i]:Row
           COL       self:aForm[i]:Col
           Caption   self:aForm[i]:Caption
           Width     self:aForm[i]:Width
           Height    self:aForm[i]:Height
           Value     self:aForm[i]:Value
           ONCHANGE  self:Run_OnChange2()
           END CHECKBOX
           *
     ELSEIF Self:aForm[i]:Control == 'LISTBOX'
        *
        DEFINE LISTBOX &(self:aForm[i]:Field)
           ROW         self:aForm[i]:Row
           COL         self:aForm[i]:Col
           Value       self:aForm[i]:Value
           Width       self:aForm[i]:Width
           Height      self:aForm[i]:Height
           Items       self:aForm[i]:aItems
           MULTISELECT self:aForm[i]:lMultiselect
           ONDBLCLICK  self:Run_DblClick()
           ONCHANGE    self:Run_OnChange()
           END LISTBOX
           *
           if !IsNil(self:aForm[i]:bEnter)
              bLock := self:aForm[i]:bEnter
              aadd(self:aDblClick,{self:aVars[i,2],bLock})
           Endif
           if !IsNil(self:aForm[i]:bChange)
              bLock := self:aForm[i]:bChange
              aadd(self:aChange,{self:aVars[i,2],bLock})
           Endif
           *
     ELSEIF Self:aForm[i]:Control == 'RADIOGROUP'
        *
        #ifdef ___FV3_EXT___
           *
           _DefineradioGroup (;              //
           (self:aForm[i]:Field)             ,;  // <"name">, ;
           nil                               ,;  // <"parent">, ;
           self:aForm[i]:Col                 ,;  // <col>, ;
           self:aForm[i]:Row                 ,;  // <row>, ;
           self:aForm[i]:aItems              ,;  // <aOptions>, ;
           self:aForm[i]:Value               ,;  // <value> , ;
           nil                               ,;  // <fontname> , ;
           nil                               ,;  // <fontsize> , ;
           nil                               ,;  // <tooltip> , ;
           {|| self:Run_OnChange2()  }       ,;  // <{change}> , ;
           self:aForm[i]:Width               ,;  // <width> , ;
           self:aForm[i]:nSpace              ,;  // <spacing> , ;
           nil                               ,;  // <helpid>, ;
           nil                               ,;  // <.invisible.>, ;
           nil                               ,;  // <.notabstop.>, ;
           nil                               ,;  // <.bold.>, ;
           nil                               ,;  // <.italic.>, ;
           nil                               ,;  // <.underline.>, ;
           nil                               ,;  // <.strikeout.> , ;
           nil                               ,;  // <backcolor> , ;
           nil                               ,;  // <fontcolor> , ;
           nil                               ,;  // <.transparent.> , ;
           self:aForm[i]:lHorizontal         ,;  // <.horizontal.> , ;
           .F.                               ,;  // <.leftjustify.> , ;
           self:aForm[i]:aReadOnly           ,;  // <aReadOnly> , ;
           nil)                                  // <aId> )
           *
        #else
           *
           _DefineradioGroup (;
           (self:aForm[i]:Field)    ,;       // <"name">
           nil                      ,;       // <"parent">
           self:aForm[i]:Col        ,;       // <col>
           self:aForm[i]:Row        ,;       // <row>
           self:aForm[i]:aItems     ,;       // <aOptions>
           self:aForm[i]:Value      ,;       // <value>
           nil                      ,;       // <fontname>
           nil                      ,;       // <fontsize>
           nil                      ,;       // <tooltip>
           {|| self:Run_OnChange2()},;       // <{change}>
           self:aForm[i]:Width      ,;       // <width>
           self:aForm[i]:nSpace     ,;       // <spacing>
           nil                      ,;       // <helpid>
           nil                      ,;       // <.invisible.>
           nil                      ,;       // <.notabstop.>
           nil                      ,;       // <.bold.>
           nil                      ,;       // <.italic.>
           nil                      ,;       // <.underline.>
           nil                      ,;       // <.strikeout.>
           nil                      ,;       // <backcolor>
           nil                      ,;       // <fontcolor>
           nil                      ,;       // <.transparent.>
           self:aForm[i]:aReadOnly  ,;       // <aReadOnly>
           self:aForm[i]:lHorizontal)        // <.horizontal.>
        #endif
        *
     ELSEIF Self:aForm[i]:Control == 'BUTTON'
        *
        bLock := self:aForm[i]:bEnter
        aadd(self:aDblClick,{self:aForm[i]:Field,bLock})
        *
        Define Button &(self:aForm[i]:Field)
           Row       self:aForm[i]:Row
           Col       self:aForm[i]:Col
           Width     self:aForm[i]:Width
           Height    self:aForm[i]:Height
           Caption   self:aForm[i]:Caption
           Action    self:Run_DblClick()
           End Button
           *
           If !self:aForm[i]:lEnable
              aadd(self:aCtrlDsbl,self:aForm[i]:Field)
           Endif
           *
     ELSEIF Self:aForm[i]:Control == 'FRAME'
        *
        DEFINE FRAME &(self:aForm[i]:Field)
           ROW       self:aForm[i]:Row
           COL       self:aForm[i]:Col
           Width     self:aForm[i]:Width
           Height    self:aForm[i]:Height
           Caption   self:aForm[i]:Caption
           END FRAME
           *
     ELSEIF Self:aForm[i]:Control == 'ACTIVEX'
        DEFINE ACTIVEX &(self:aForm[i]:Field)
           ROW         self:aForm[i]:Row
           COL         self:aForm[i]:Col
           WIDTH       self:aForm[i]:Width
           HEIGHT      self:aForm[i]:Height
           PROGID      self:aForm[i]:ProgId
           END ACTIVEX
           *
     ELSEIF Self:aForm[i]:Control == 'GRID'
        *
        #ifdef ___FV3_EXT___
           *
           _DefineGrid (;
           (self:aForm[i]:Field)     ,; //<"name"> ,      ;
           nil                       ,; //<"parent"> ,    ;
           self:aForm[i]:Col         ,; //<col> ,         ;
           self:aForm[i]:Row         ,; //<row> ,         ;
           self:aForm[i]:Width       ,; //<w> ,           ;
           self:aForm[i]:Height      ,; //<h> ,           ;
           self:aForm[i]:aHeaders    ,; //<headers> ,     ;
           self:aForm[i]:aWidths     ,; //<widths> ,      ;
           self:aForm[i]:aItems      ,; //<rows> ,        ;
           self:aForm[i]:Value       ,; //<value> ,       ;
           nil                       ,; //<fontname> ,    ;
           nil                       ,; //<fontsize> ,    ;
           nil                       ,; //<tooltip> ,     ;
           {||  self:Run_OnChange()} ,; //<{change}> ,    ;
           {||  self:Run_DblClick() },; //<{dblclick}> ,  ;
           nil                       ,; //<aHeadClick> ,  ;
           nil                       ,; //<{gotfocus}> ,  ;
           nil                       ,; //<{lostfocus}>,  ;
           .F.                       ,; //<.style.>,      ;
           nil                       ,; //<aImage>,       ;
           self:aForm[i]:aJustify    ,; //<aJust>  ,      ;
           .F.                       ,; //<.break.> ,     ;
           .F.                       ,; //<helpid> ,      ;
           .F.                       ,; //<.bold.>,       ;
           .F.                       ,; //<.italic.>,     ;
           .F.                       ,; //<.underline.>,  ;
           .F.                       ,; //<.strikeout.> , ;
           .F.                       ,; //<.ownerdata.> , ;
           nil                       ,; //<{dispinfo}> ,  ;
           nil                       ,; //<itemcount> ,   ;
           self:aForm[i]:lEdit       ,; //<.edit.> ,  ;
           nil                       ,; //<dynamicforecolor> , ;
           Nil                       ,; //<dynamicbackcolor> , ;
           .F.                       ,; //<.multiselect.> , ;
           self:aForm[i]:aCtrl       ,; //<editcontrols> , ;
           nil                       ,; //<backcolor> , ;
           nil                       ,; //<fontcolor> ,;
           nil                       ,; //<nId>,;
           self:aForm[i]:aValid      ,; //<columnvalid> ,;
           nil                       ,; //<columnwhen> ,;
           nil                       ,; //<aValidMessages> ,;
           self:aForm[i]:lShowHeaders,; //!<.noshowheaders.> ,;
           nil                       ,; //<aImageHeader> ,;
           .F.                       ,; //<.notabstop.> ,;
           .F.                       ,; //<.cell.> ,;
           self:aForm[i]:lCheckBox   ,; //<.checkboxes.> ,;
           nil                       ,; //<lockcolumns> ,
           {|| self:SetCheckBox() }  ,; //<{OnCheckBoxClicked}> ,
           .F.                       ,; //<.doublebuffer.> ,
           .F.                       ,; //<.nosortheaders.> ,
           nil                       )  //<columnsort> )
           *
        #else
           *
           _DefineGrid ( ;                       // _DefineGrid (
           (self:aForm[i]:Field)              ,; // name
           nil                                ,; // parent
           self:aForm[i]:Col                  ,; // col
           self:aForm[i]:Row                  ,; // row
           self:aForm[i]:Width                ,; // w
           self:aForm[i]:Height               ,; // h
           self:aForm[i]:aHeaders             ,; // headers
           self:aForm[i]:aWidths              ,; // widths
           self:aForm[i]:aItems               ,; // rows
           self:aForm[i]:Value                ,; // value
           nil                                ,; // fontname
           nil                                ,; // fontsize
           nil                                ,; // tooltip
           {||  self:Run_OnChange()}          ,; // {change}
           {||  self:Run_DblClick() }         ,; // {dblclick}
           nil                                ,; // aHeadClick
           nil                                ,; // {gotfocus}
           nil                                ,; // {lostfocus}
           .F.                                ,; // .style.
           nil                                ,; // aImage
           self:aForm[i]:aJustify             ,; // aJust
           .F.                                ,; // .break.
           .F.                                ,; // helpid
           .F.                                ,; // .bold.
           .F.                                ,; // .italic.
           .F.                                ,; // .underline.
           .F.                                ,; // .strikeout.
           .F.                                ,; // .ownerdata.
           nil                                ,; // {dispinfo}
           nil                                ,; // itemcount
           nil                                ,; // nil
           nil                                ,; // Nil
           Nil                                ,; // Nil
           .F.                                ,; // .multiselect.
           nil                                ,; // Nil
           Nil                                ,; // backcolor
           nil                                ,; // fontcolor
           self:aForm[i]:lEdit                ,; // .edit.
           self:aForm[i]:aCtrl                ,; // editcontrols
           nil                                ,; // dynamicbackcolor
           nil                                ,; // dynamicforecolor
           self:aForm[i]:aValid               ,; // columnvalid
           nil                                ,; // columnwhen
           self:aForm[i]:lShowHeaders         ,; // .noshowheaders.
           nil                                ,; // headerimages
           .F.                                ,; // .cellnavigation.
           self:aForm[i]:Alias                ,; // recordsource
           self:aForm[i]:aColumnFields        ,; // columnfields
           .F.                                ,; // .append.
           .F.                                ,; // .buffered.
           .F.                                ,; // .allowdelete.
           nil                                ,; // dynamicdisplay
           nil                                ,; // {onsave}
           nil                                ,; // lockcolumns
           nil                                ,; // {onclick}
           nil                                ,; // {onkey}
           nil                                ,; // EditOption
           nil                                ,; // .notrans.
           .F.                                ,; // .notransheader.
           .F.                                ,; // aDynamicFont
           {|| self:SetCheckBox() }           )  // {OnCheckBoxClicked}
           *
        #endif
        *
        if !IsNil(self:aForm[i]:bDblClick)
           bLock := self:aForm[i]:bDblClick
           aadd(self:aDblClick,{self:aVars[i,2],bLock})
        Endif
        if !IsNil(self:aForm[i]:bChange)
           bLock := self:aForm[i]:bChange
           aadd(self:aChange,{self:aVars[i,2],bLock})
        Endif
        if self:aForm[i]:lCheckBox
           bLock := self:aForm[i]:lCheckBox
           aadd(self:abCheckBox,{self:aVars[i,2],bLock})
        Endif
        *
     ELSEIF Self:aForm[i]:Control == 'BROWSE'
        *
        #ifdef ___FV3_EXT___
           *
           _DefineBrowse(                          ;
           (self:aForm[i]:Field)                   ,;//ControlName,          "Pedidos" ,
           nil                                     ,;//ParentFormName,       nil,
           self:aForm[i]:Col                       ,;//x,                    10 ,
           self:aForm[i]:Row                       ,;//y,                    40 ,
           self:aForm[i]:Width                     ,;//w,                    380 ,
           self:aForm[i]:Height                    ,;//h,                    370 ,
           self:aForm[i]:aHeaders                  ,;//aHeaders,             { "Pedido" , "Cliente" , "Endereco" , "Cidade" } ,
           self:aForm[i]:aWidths                   ,;//aWidths,              { 100 , 250 , 250 , 150 } ,
           self:aForm[i]:aItems                    ,;//aFields,              { "Pedidos->Pedido" , "Clientes->Nome" , "Clientes->Endereco" , "Clientes->Cidade" } ,
           1                                       ,;//value, ;              nil,
           nil                                     ,;//fontname,             nil,
           nil                                     ,;//fontsize,             nil,
           nil                                     ,;//tooltip,              nil,
           {|| self:Run_OnChange()}                ,;//change,               {|| UpdateItems()},
           {|| self:Run_DblClick()}                ,;//dblclick,             nil,
           self:aForm[i]:aHeadClick                ,;//aHeadClick,           nil,
           nil                                     ,;//gotfocus,             nil,
           nil                                     ,;//lostfocus ,           nil,
           (self:aForm[i]:Alias)                   ,;//WorkArea , ;          "Pedidos" ,
           .F.                                     ,;//Delete ,              .F.,
           self:aForm[i]:lLines                    ,;//nogrid ,              .F. ,
           nil                                     ,;//aImage ,              nil ,
           self:aForm[i]:aJustify                  ,;//aJust ,               nil ,
           nil                                     ,;//HelpId ,              nil ,
           .F.                                     ,;//bold ,                .F. ,
           .F.                                     ,;//italic ,              .F. ,
           .F.                                     ,;//underline ,           .F. ,
           .F.                                     ,;//strikeout ,           .F. ,
           .F.                                     ,;//break , ;             .F. ,
           self:aForm[i]:aBackColor                ,;//backcolor,            nil ,
           nil                                     ,;//fontcolor,            nil ,
           .T.                                     ,;//lock,                 .T. ,
           .T.                                     ,;//inplace,              .T. ,
           .F.                                     ,;//novscroll,            .F. ,
           .F.                                     ,;//appendable,           .F. ,
           .F.                                     ,;//readonly,             { .T. , .F. , .F. , .F. } ,
           nil                                     ,;//valid,                nil ,
           nil                                     ,;//validmessages, ;      nil ,
           .F.                                     ,;//edit ,                .T. ,
           nil                                     ,;//dynamicforecolor ,    nil ,
           nil                                     ,;//dynamicbackcolor ,    nil ,
           nil                                     ,;//aWhenFields ,         nil,
           nil                                     ,;//nId ,                 nil,
           nil                                     ,;//aImageHeader ,        nil,
           .F.                                     ,;//NoTabStop , ;         .F. ,
           nil                                     ,;//inputitems ,          nil ,
           nil                                     ,;//displayitems ,        nil ,
           .F.                                     ,;//doublebuffer ,        .F. ,
           nil                                     ,;//columnsort ,          nil ,
           nil)                                      //bInit                 nil )
           *
        #else
           *
           _DefineBrowse ( ;                    //  _DefineBrowse (
           (self:aForm[i]:Field)             ,; //  name
           nil                               ,; //  parent
           self:aForm[i]:Col                 ,; //  col
           self:aForm[i]:Row                 ,; //  row
           self:aForm[i]:Width               ,; //  w
           self:aForm[i]:Height              ,; //  h
           self:aForm[i]:aHeaders            ,; //  headers
           self:aForm[i]:aWidths             ,; //  widths
           self:aForm[i]:aItems              ,; //  Fields
           nil                               ,; //  value
           nil                               ,; //  fontname
           nil                               ,; //  fontsize
           nil                               ,; //  tooltip
           {|| self:Run_OnChange()}          ,; //  {change}
           {|| self:Run_DblClick()}          ,; //  {dblclick}
           self:aForm[i]:aHeadClick          ,; //  aHeadClick
           nil                               ,; //  {gotfocus}
           nil                               ,; //  {lostfocus}
           (self:aForm[i]:Alias)             ,; //  workarea
           .F.                               ,; //  .Delete.
           self:aForm[i]:lLines              ,; //  .style.
           nil                               ,; //  aImage
           self:aForm[i]:aJustify            ,; //  aJust
           nil                               ,; //  helpid
           .F.                               ,; //  .bold.
           .F.                               ,; //  .italic.
           .F.                               ,; //  .underline.
           .F.                               ,; //  .strikeout.
           .F.                               ,; //  .break.
           nil                               ,; //  backcolor
           nil                               ,; //  fontcolor
           .F.                               ,; //  .lock.
           .F.                               ,; //  .inplace.
           .F.                               ,; //  .novscroll.
           .F.                               ,; //  .append.
           nil                               ,; //  aReadOnly
           nil                               ,; //  aValidFields
           nil                               ,; //  aValidMessages
           .F.                               ,; //  .edit.
           self:aForm[i]:aBackColor          ,; //  dynamicbackcolor
           nil                               ,; //  aWhenFields
           nil                               ,; //  dynamicforecolor
           nil                               ,; //  inputmask
           nil                               ,; //  format
           nil                               ,; //  inputitems
           nil                               ,; //  displayitems
           nil                                ) //  headerimages
        #endif
        *
        if !IsNil(self:aForm[i]:bDblClick)
           bLock := self:aForm[i]:bdBlClick
           aadd(self:aDblClick,{self:aVars[i,2],bLock})
        Endif
        *
        if !IsNil(self:aForm[i]:bChange)
           bLock := self:aForm[i]:bChange
           aadd(self:aChange,{self:aVars[i,2],bLock})
        Endif
        *
     ELSEIF Self:aForm[i]:Control == 'TSBROWSE'
        *
        *
     ELSEIF Self:aForm[i]:Control == 'SPINNER'
        *
        DEFINE SPINNER &(self:aForm[i]:Field)
           ROW         self:aForm[i]:Row
           COL         self:aForm[i]:Col
           Width       self:aForm[i]:Width
           RangeMin    self:aForm[i]:Min
           RangeMax    self:aForm[i]:Max
           Value       self:aForm[i]:Value
           ON CHANGE   self:Run_OnChange()
           END SPINNER
           *
           if !IsNil(self:aForm[i]:bChange)
              bLock := self:aForm[i]:bChange
              aadd(self:aChange,{self:aVars[i,2],bLock})
           Endif
           *
     ELSEIF Self:aForm[i]:Control == 'IMAGE'
        DEFINE IMAGE &(self:aForm[i]:Field)
           ROW         self:aForm[i]:Row
           COL         self:aForm[i]:Col
           WIDTH       self:aForm[i]:Width
           HEIGHT      self:aForm[i]:Height
           PICTURE     self:aForm[i]:Picture
           STRETCH     self:aForm[i]:lStretch
           END IMAGE
           *
     ELSEIF Self:aForm[i]:Control == 'RTF'
        *
        _DefineRichEditBox ( ;
        self:aForm[i]:Field,; // <"name">
        ,; // <"parent">
        self:aForm[i]:Col   ,; // <col>
        self:aForm[i]:Row   ,; // <row>
        self:aForm[i]:Width ,; // <w>
        self:aForm[i]:Height,; // <h>
        self:aForm[i]:Value ,; // <value>
        ,; // <f>
        ,; // <s>
        ,; // <tooltip>
        ,; // <maxlength>
        ,; // <{gotfocus}>
        ,; // <{change}>
        ,; // <{lostfocus}>
        ,; // <.readonly.>
        ,; // .f.
        ,; // <helpid>
        ,; // <.invisible.>
        ,; // <.notabstop.>
        ,; // <.bold.>
        ,; // <.italic.>
        ,; // <.underline.>
        ,; // <.strikeout.>
        ,; // <"field">
        ,; // <backcolor>
        ,; // <.noHscroll.>
        ,; // <.noVscroll.>
        ,; // <{selectchange}>
        ,; // <{onlink}>
        ) // <{OnVScroll}> )
     ELSEIF Self:aForm[i]:Control == 'PROGRESSBAR'
        *
        DEFINE PROGRESSBAR &(self:aForm[i]:Field)
           ROW         self:aForm[i]:Row
           COL         self:aForm[i]:Col
           WIDTH       self:aForm[i]:Width
           HEIGHT      self:aForm[i]:Height
           VALUE       self:aForm[i]:Value
           RANGEMAX    100
           RANGEMIN    1
           END PROGRESSBAR
           *
     ELSEIF Self:aForm[i]:Control == 'BTNTEXTBOX'
        *
        #ifdef ___FV3_EXT___
           *
           *
           _DefineBtnTextBox(;                            //
           (self:aForm[i]:Field),;                        //  <(name)>,;
           nil         ,;                                 //  <(parent)>,;
           self:aForm[i]:Col,;                            //  <col>,;
           self:aForm[i]:Row,;                            //  <row>,;
           self:aForm[i]:Width,;                          //  <width>,;
           self:aForm[i]:Height,;                         //  <height>,;
           self:aForm[i]:Value,;                          //  <value>,;
           self:aForm[i]:bAction1,;                       //  <{action}>,;
           self:aForm[i]:bAction2,;                       //  <{action2}>,;
           self:aForm[i]:Picture,;                        //  <abitmap>,;
           nil         ,;                                 //  <btnwidth>,;
           Self:aForm[i]:FontName,;                       //  <fontname>,;
           Self:aForm[i]:FontSize,;                       //  <fontsize>,;
           Self:aForm[i]:ToolTip,;                        //  <tooltip>,;
           self:aForm[i]:nMaxLen,;                        //  <maxlenght>, ;
           .F.         ,;                                 //  <.upper.>,;
           .F.         ,;                                 //  <.lower.>,;
           If(Valtype(self:aForm[i]:Value)='N',.T.,.F.),; //  <.numeric.>,;
           .F.         ,;                                 //  <.password.>,;
           nil         ,;                                 //  <{lostfocus}>,;
           nil         ,;                                 //  <{gotfocus}>,;
           nil         ,;                                 //  <{change}>,;
           nil         ,;                                 //  <{enter}>, ;
           self:aForm[i]:RightAlign,;                     //  <.RightAlign.>,;
           nil         ,;                                 //  <helpid>,;
           .F.         ,;                                 //  <.bold.>,;
           .F.         ,;                                 //  <.italic.>,;
           .F.         ,;                                 //  <.underline.>,;
           .F.         ,;                                 //  <.strikeout.>,;
           nil         ,;                                 //  <(field)>, ;
           nil         ,;                                 //  <backcolor>,;
           nil         ,;                                 //  <fontcolor>,;
           .F.         ,;                                 //  <.invisible.>,;
           .F.         ,;                                 //  <.notabstop.>,;
           nil         ,;                                 //  <nId>,;
           self:aForm[i]:lEdit,;                          //  <.disableedit.>,;
           .T.         ,;                                 //  <.default.>, ;
           nil         ,;                                 //  [<CueText>],;
           !.F.        ,;                                 //  !<.nokeepfocus.>,;
           nil          )                                 //  <bInit> )
           *
           *
        #endif
        *
     ELSEIF Self:aForm[i]:Control == 'CHKLISTBOX'
        *
        #ifdef ___FV3_EXT___
           *
           _DefineChkListBox(         ;
           (self:aForm[i]:Field)     ,; //     <(name)>,;
           nil                       ,; //     <(parent)>,;
           self:aForm[i]:Col         ,; //     <col>,;
           self:aForm[i]:Row         ,; //     <row>,;
           self:aForm[i]:Width       ,; //     <w>,;
           self:aForm[i]:Height      ,; //     <h>,;
           self:aForm[i]:aItems      ,; //     <aRows>,;
           self:aForm[i]:Value       ,; //     <value>, ;
           Self:aForm[i]:FontName    ,; //     <fontname>,;
           Self:aForm[i]:FontSize    ,; //     <fontsize>,;
           Self:aForm[i]:ToolTip     ,; //     <tooltip>,;
           {|| self:Run_OnChange()}  ,; //     <{change}>,;
           {|| self:Run_DblClick()}  ,; //     <{dblclick}>,;
           nil                       ,; //     <{gotfocus}>,;
           nil                       ,; //     <{lostfocus}>,;
           .F.                       ,; //     .f., ;
           nil                       ,; //     <helpid>,;
           .F.                       ,; //     <.invisible.>,;
           .F.                       ,; //     <.notabstop.>,;
           .F.                       ,; //     <.sort.> ,;
           .F.                       ,; //     <.bold.>,;
           .F.                       ,; //     <.italic.>,;
           .F.                       ,; //     <.underline.>,;
           .F.                       ,; //     <.strikeout.>, ;
           nil                       ,; //     <backcolor> ,;
           nil                       ,; //     <fontcolor> ,;
           self:aForm[i]:lMultiselect,; //     <.multiselect.> ,;
           self:aForm[i]:aCheck      ,; //     <aCheck>,;
           19                        ,; //     <nItemHeight>,;
           nil )                        //     <nId> )
           *
           if !IsNil(self:aForm[i]:bDblClick)
              bLock := self:aForm[i]:bdBlClick
              aadd(self:aDblClick,{self:aVars[i,2],bLock})
           Endif
           *
           if !IsNil(self:aForm[i]:bChange)
              bLock := self:aForm[i]:bChange
              aadd(self:aChange,{self:aVars[i,2],bLock})
           Endif
        #endif
        *
     ELSEIF Self:aForm[i]:Control == 'TREE_ENDNODE'
        _EndTreeNode()
     ELSEIF Self:aForm[i]:Control == 'TREE_END'
        _EndTree()
     ELSEIF Self:aForm[i]:Control == 'ENDPAGE'
        _EndTabPage()
     ELSEIF Self:aForm[i]:Control == 'TAB_END'
        _EndTab()
     Endif
     *
  Next
  *
  If nMenu == 2
     @ self:MaxRow-80,self:MaxCol-(230) BUTTON Button_Cancel ;
     Caption _BTN_CANCEL Width 100 Action ___Cancel(cWin)
     @ self:MaxRow-80,self:MaxCol-130   BUTTON Button_OK ;
     Caption _BTN_OK Width 100 Action ___OK(cWin,self:aVars)
  elseif nMenu == 1
     @ self:MaxRow-80,self:MaxCol-130 BUTTON Button_Cancel  ;
     Caption _BTN_CLOSE Width 100 Action ___Cancel(cWin)
  Endif
  *
  END WINDOW
  *
  If !Empty(self:aAllCtrl)
     aeval(self:aAllCtrl,{|_a| SetProperty(cWin,_a[1],_a[2],_a[3],_a[4],_a[5]) })
  Endif
  *
  For i := 1 To Len(self:aCtrlFont)
     nPos := ascan(self:aVars,{|x,y| upper(x[2]) == Upper(self:aCtrlFont[i,1]) } )
     IF nPos > 0
        SetProperty(cWin,self:aVars[nPos,2],'fontname',self:aCtrlFont[i,2])
        SetProperty(cWin,self:aVars[nPos,2],'fontsize',self:aCtrlFont[i,3])
     Endif
  Next
  *
  For i := 1 To Len(self:aCtrlDsbl)
     *
     nPos := ascan(self:aVars,{|x,y| upper(x[2]) == Upper(self:aCtrlDsbl[i]) } )
     IF nPos > 0
        SetProperty(cWin,self:aVars[nPos,2],'Enabled',.F.)
     ENDIF
     *
  Next
  *
  If self:bPostInit != nil
     eval(self:bPostInit,cWin)
  Endif
  *
  IF !Empty(aRay)
     asort(aRay,,,{|x,y| TRIM(x[1]) < TRIM(y[2]) })
     Set Alternate To 'Debug.Txt'
     Set Alternate On
     For i := 1 To Len(aRay)
        QQout(aRay[i,1]+'-'+aRay[i,2]+'-'+aRay[i,3]+CRLF)
     Next
     Set Alternate Off
  Endif
  *
  If lZoom
     DoMethod(cWin,'Maximize')
  else
     DoMethod(cWin,'Center')
  Endif
  DoMethod(cWin,'Activate')
  *
Return self
*
*************************************
*
Method OnInit(cWin) class KForm3
  *
  If self:bInit != nil
     eval(self:bInit,cWin)
  Endif
  *
Return self
*
*************************************
*
Method OnClose(cWin) class KForm3
  *
  If self:bRelease != nil
     eval(self:bRelease,cWin)
  Endif
  *
Return self
*
*************************************
*
Method SkipRow(x) Class KForm3
  *
  self:Row  += x
  If x > 0
     self:Col  := 15
     aadd(self:aHeight,{self:Row,0})
     self:Current++
  Endif
Return self
*
*************************************
*
Method SetRow(x) Class KForm3
  *
  self:Row        := x
  self:MaxRow     := Max(x,self:MaxRow)
Return self
*
*************************************
*
Method SkipCol(x) Class KForm3
  self:Col   += x
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
Return self
*
*************************************
*
Method SetCol(x) Class KForm3
  self:Col   := x
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
Return self
*
*************************************
*
Method Label2(cField,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic) Class KForm3
  Local oForm := QForm()
  *
  Default aBackColor To {255,255,255}
  Default nAlignment To 0
  *
  oForm:Control    := 'LABEL2'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Caption    := _VarGet(cField)
  oForm:Alignment  := {.F.,.F.,.F.}
  oForm:aForecolor := aForeColor
  oForm:aBackColor := aBackColor
  oForm:FontName   := cFont
  oForm:FontSize   := nSize
  oForm:Bold       := lBold
  oForm:Border     := lBorder
  oForm:ClientEdge := lClientEdge
  oForm:Underline  := lUnderline
  oForm:Italic     := lItalic
  *
  oForm:Alignment[nAlignment+1] := .T.
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
Return self
*
*************************************
*
Method Label(cCaption,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic) Class KForm3
  Local oForm := QForm()
  *
  Default nAlignment to 0
  *
  ++self:nLabel
  *
  oForm:Control    := 'LABEL'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := Ntrim(self:nLabel)
  oForm:Width      := nWidth
  oForm:Caption    := cCaption
  oForm:Alignment  := {.F.,.F.,.F.}
  oForm:aForecolor := aForeColor
  oForm:aBackColor := aBackColor
  oForm:FontName   := cFont
  oForm:FontSize   := nSize
  oForm:Bold       := lBold
  oForm:Border     := lBorder
  oForm:ClientEdge := lClientEdge
  oForm:Underline  := lUnderline
  oForm:Italic     := lItalic
  *
  oForm:Alignment[nAlignment+1] := .T.
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  aadd(Self:aVars,{9,'Label_'+Ntrim(self:nLabel),nil,nil})
  *
Return self
*
*************************************
*
Method TextBox(cField,nWidth,cPict,xOpz,bEnter,bLostFocus,aBackColor,aForeColor,lBold,lItalic,bChange) Class KForm3
  Local oForm  := QForm()
  Local uValue := _VarGet(cField)
  *
  Default cPict To ''
  DEFAULT xOpz  To 0
  DEFAULT bEnter     To {|| __Nulla() }
  DEFAULT bLostFocus To {|| __Nulla() }
  DEFAULT bChange    To {|| __Nulla() }
  *
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
  oForm:Control    := 'TEXTBOX'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:bEnter     := bEnter
  oForm:bChange    := bChange
  oForm:bLostFocus := bLostFocus
  oForm:Value      := uValue
  oForm:Type       := Valtype(uValue)
  oForm:xOpz       := xOpz
  oForm:aCharMask  := {}
  oForm:Picture    := cPict
  oForm:aForecolor := aForeColor
  oForm:aBackColor := aBackColor
  oForm:FontName   := nil
  oForm:FontSize   := nil
  oForm:Bold       := lBold
  oForm:Underline  := nil
  oForm:Italic     := lItalic
  *
  If xOpz > 0
     oForm:aCharMask  := {.F.,.F.,.F.}
     oForm:aCharMask[xOpz] := .T.
  Endif
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method ComboBox(cField,nWidth,nHeight,aRay,lEdit,bChange,lDisplayValue) Class KForm3
  Local nPos
  Local uValue
  Local nCode
  Local aTemp  := {}
  Local bLock2 := {|x,y| x }
  Local oForm  := QForm()
  Local xField
  *
  Default lEdit          To .F.
  Default lDisplayValue  To .F.
  DEFAULT bChange        To {|| __Nulla() }
  *
  nCode  := 0
  nPos   := 1
  *
  If lEdit
     aTemp  := aClone(aRay)
     nCode  := 1
     bLock2 := nil
     uValue := _VarGet(cField)
     If Valtype(uValue) == 'C'
        nPos := aScan(aTemp,{|aVal| upper(aVal) == upper(uValue) })
     else
        nPos := aScan(aTemp,{|aVal| aVal == uValue })
     endif
  else
     If !Empty(aRay) .and. Valtype(aRay[1]) == 'A'
        aeval(aRay,{|a| aadd(aTemp,a[1]) })
        bLock2  := {|x,a| a[x,2] }
        nCode   := 2
        xField := _VarGet(cField)
        nPos    := AScan(aRay,{|aVal| aVal[2] == xField })
     else
        aTemp  := aClone(aRay)
        nCode  := 0
        xField := _VarGet(cField)
        nPos   := AScan(aTemp,{|aVal| aVal == xField })
        If lDisplayValue
           bLock2 := {|x,a| a[x] }
        Endif
     endif
  Endif
  If nPos == 0
     nPos := 1
  Endif
  *
  aadd(Self:aVars,{nCode,cField,aRay,bLock2})
  *
  oForm:Control    := 'COMBOBOX'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  oForm:bChange    := bChange
  oForm:Value      := nPos
  oForm:lEdit      := lEdit
  oForm:aItems     := aTemp
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method ListBox(cField,nWidth,nHeight,aRay,lMultiSelect,bEnter,bChange,lDisplayValue) Class KForm3
  Local nPos,i,c1,c2,bLock
  Local aTemp  := {}
  Local bLock2 := {|x,y| x }
  Local oForm  := QForm()
  Local nCode  := 0
  *
  Default lMultiSelect   To .F.
  Default lDisplayValue  To .F.
  Default bEnter         To {|| __Nulla() }
  Default bChange        To {|| __Nulla() }
  *
  If lMultiSelect
     aTemp := aClone(aRay)
     nPos := 1
  else
     bLock := {|x,y| Upper(x) == Upper(y) }
     If IsArray(aRay[1])
        *
        If valtype(aRay[1,2]) == 'N'
           bLock := {|x,y| x == y }
        else
           bLock2 := {|n,a| a[n,2] }
        endif
        *
        nCode  := 3
        *
     else
        *
        If lDisplayValue
           bLock2 := nil
           nCode  := 4
        else
           bLock2 := nil
           nCode  := 0
        Endif
        *
     Endif
     *
     nPos := 0
     c1   := _VarGet(cField)
     For i := 1 To Len(aRay)
        If valtype(aRay[i]) == 'A'
           c2 := aRay[i,2]
           aadd(aTemp,aRay[i,1])
        else
           c2 := aRay[i]
           aadd(aTemp,aRay[i])
        Endif
        If eval(bLock,c1,c2)
           nPos := i
        Endif
     Next
     If nPos == 0
        nPos := 1
     Endif
  endif
  *
  If Len(aRay) == 1 .and. empty(aRay[1])
     aRay  := {}
     aTemp := {}
  Endif
  *
  aadd(Self:aVars,{nCode,cField,aRay,bLock2})
  *
  oForm:Control      := 'LISTBOX'
  oForm:Row          := self:Row
  oForm:Col          := self:Col
  oForm:Field        := cField
  oForm:Width        := nWidth
  oForm:Height       := nHeight
  oForm:bEnter       := bEnter
  oForm:bChange      := bChange
  oForm:lMultiselect := lMultiselect
  oForm:Value        := nPos
  oForm:aItems       := aTemp
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  If self:lRowPlus
     self:Row    += nHeight
  Endif
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method DatePicker(cField,nWidth) Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
  oForm:Control    := 'DATEPICKER'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Value      := _VarGet(cField)
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method Spinner(cField,nWidth,nMin,nMax,bAction) Class KForm3
  Local oForm := QForm()
  *
  DEFAULT bAction To {|| __Nulla() }
  *
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
  oForm:Control    := 'SPINNER'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Value      := _VarGet(cField)
  oForm:Min        := nMin
  oForm:Max        := nMax
  oForm:bChange    := bAction
  *
  aadd(Self:aForm,oForm)
  *
  *
  self:Col    += nWidth
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method EditBox(cField,nWidth,nHeight,bChange) Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
  oForm:Control    := 'EDITBOX'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  oForm:Value      := _VarGet(cField)
  oForm:bChange    := bChange
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  If self:lRowPlus
     self:Row    += nHeight
  Endif
  self:MaxCol  := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method CheckBox(cField,nWidth,cCaption) Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
  oForm:Control    := 'CHECKBOX'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Height     := 23
  oForm:Caption    := cCaption
  oForm:Value      := _VarGet(cField)
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:MaxCol  := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method RadioGroup(cField,nWidth,aRay,lHorizontal,nSpace,aReadOnly) Class KForm3
  Local nPos
  Local oForm := QForm()
  *
  Default lHorizontal   To .T.
  Default nSpace        To 50
  Default aReadOnly     To {}
  *
  If Empty(aReadOnly)
     aReadOnly := Array(Len(aRay))
     aFill(aReadOnly,.F.)
  Endif
  *
  nPos := _VarGet(cField)
  If nPos == nil
     nPos := 1
  Endif
  *
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
  oForm:Control    := 'RADIOGROUP'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Value      := nPos
  oForm:aItems     := aRay
  oForm:lHorizontal:= lHorizontal
  oForm:aReadOnly  := aReadOnly
  oForm:nSpace     := nSpace
  *
  aadd(Self:aForm,oForm)
  *
  self:Col += nWidth
  If self:lRowPlus
     If !lHorizontal
        self:Row    += (nSpace*Len(aRay))+5
     else
        self:Row    += 25
     Endif
  Endif
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method Button(cValue,nWidth,nHeight,bAction,lEnable) Class KForm3
  Local oForm := QForm()
  *
  Default lEnable To .T.
  DEFAULT bAction To {|| __Nulla() }
  *
  aadd(Self:aVars,{0,'Button_'+Ntrim(++self:nButton),nil,nil})
  *
  oForm:Control    := 'BUTTON'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := 'Button_'+Ntrim(self:nButton)
  oForm:Caption    := cValue
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  oForm:lEnable    := lEnable
  oForm:bEnter     := bAction
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:MaxCol  := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method Result() Class KForm3
  Local nPos
  *
  nPos := ascan(aResult,{|a| a[1] == self:Window_Name })
  *
Return aResult[nPos,2]
*
*************************************
*
Method Run_DblClick() Class KForm3
  Local nPos,c1,c2,cWin
  *
  cWin := self:Window_Name
  c1   := This.Name
  nPos := ascan(self:aDblClick,{|_a| upper(_a[1]) == Upper(c1) })
  *
  If nPos > 0
     c2 := self:aDblClick[nPos,2]
     If Valtype(c2) == 'B'
        *eval(c2,This.Caption,cWin)
        *eval(c2,cWin,This.Caption)
        eval(c2,cWin,This.Name,This.Value)
     elseif c2 == '___Cancel()'
        ___Cancel(cWin)
     elseif c2 == '___OK()'
        ___OK(cWin,self:aVars)
     else
        &(c2)
     endif
  Endif
  *
Return nil
*
*************************************
*
Method Run_OnChange(c) Class KForm3
  Local nPos,c1,c2
  *
  If !IsNil(c)
     c1 := c
     msginfo(c)
  else
     c1   := This.Name
  endif
  nPos := ascan(self:aChange,{|_a| upper(_a[1]) == Upper(c1) })
  *
  If nPos > 0
     c2 := self:aChange[nPos,2]
     If Valtype(c2) == 'B'
        eval(c2,self:Window_Name,c1)
     else
        &(c2)
     endif
  Endif
  *
Return nil
*
*************************************
*
Method Run_OnChange2() Class KForm3
  Local c1,c2,bLock
  *
  c1 := This.Name
  c2 := c1+'_Onchange('+self:Window_Name+','+c1+')'
  If hb_IsFunction(c1+'_OnChange')
     bLock := &("{|cWin,cName| "+c1+"_OnChange(cWin,cName) }")
     eval(bLock,self:Window_Name,c1)
  Endif
  *
Return nil
*
*************************************
*
Method Run_OnLostFocus() Class KForm3
  Local nPos,c1,c2,n,x
  *
  c1   := This.Name
  nPos := ascan(self:aLostFocus,{|_a| upper(_a[1]) == Upper(c1) })
  *
  If nPos > 0
     c2 := self:aLostFocus[nPos,2]
     If Valtype(c2) == 'B'
        eval(c2,self:Window_Name,c1)
     endif
  Endif
  *
Return nil
*
*************************************
*
Method Run_OnEnter() Class KForm3
  Local nPos,c1,c2,n,x
  *
  c1   := This.Name
  nPos := ascan(self:aEnter,{|_a| upper(_a[1]) == Upper(c1) })
  *
  If nPos > 0
     c2 := self:aEnter[nPos,2]
     If Valtype(c2) == 'B'
        eval(c2,self:Window_Name,c1)
     endif
  Endif
  *
Return nil
*
*************************************
*
Method SetCheckBox() Class KForm3
  Local nPos,c1,n,x,i
  *
  c1   := This.Name
  nPos := ascan(self:abCheckBox,{|_a| upper(_a[1]) == Upper(c1) })
  *
  If nPos > 0
     n := ascan(self:aVars,{|_a| upper(_a[2]) == Upper(c1) })
     If n > 0
        #ifdef ___FV3_EXT___
           For i := 1 To GetProperty(self:Window_Name,c1,'ItemCount')
              self:aVars[n,5,i] := GetProperty(self:Window_Name,c1,'CheckBoxItem',i)
           Next
        #else
           x  := GetProperty(self:Window_Name,c1,'CellRowClicked')
           self:aVars[n,5,x] := if(self:aVars[n,5,x],.f.,.t.)
        #endif
     Endif
  Endif
  *
Return self
*
*************************************
*
Method SetAllCheckBox(cField,lValue) Class KForm3
  Local nPos,i
  *
  nPos := ascan(self:aVars,{|_a| upper(_a[2]) == Upper(cField) })
  If nPos > 0
     For i := 1 To Len(self:aVars[nPos,5])
        self:aVars[nPos,5,i] := lValue
        SetProperty(self:Window_Name,cField, "CheckBoxItem", i, lValue )
     Next
  Endif
Return self
*
*************************************
*
Method Frame(cText,nWidth,nHeight) Class KForm3
  Local oForm := QForm()
  *
  ++self:nFrame
  aadd(Self:aVars,{9,'Frame_'+Ntrim(self:nFrame),nil,nil})
  *
  oForm:Control    := 'FRAME'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := 'Frame_'+Ntrim(self:nFrame)
  oForm:Caption    := cText
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  If self:lRowPlus
     self:Row    += nHeight
  Endif
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method Activex(cField,nWidth,nHeight,cProgId) Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{0,cField,nil,nil})
  *
  oForm:Control    := 'ACTIVEX'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  oForm:ProgId     := cProgId
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  If self:lRowPlus
     self:Row    += nHeight
  Endif
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method RtfBox(cField,nWidth,nHeight) Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
  oForm:Control    := 'RTF'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  If self:lRowPlus
     self:Row    += nHeight
  Endif
  self:MaxCol  := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method ProgressBar(cField,nWidth,nHeight) Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{0,cField,nil,{|x,y| x }})
  *
  oForm:Control    := 'PROGRESSBAR'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  *If self:lRowPlus
  *   self:Row    += nHeight
  *Endif
  self:MaxCol  := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method GetRow() Class KForm3
Return self:Row
*
*************************************
*
Method GetCol() Class KForm3
Return self:Col
*
*************************************
*
Method SetFont(c,cFont,nSize) Class KForm3
  aadd(self:aCtrlFont,{c,cFont,nSize})
Return self
*
*************************************
*
Method SetAllCtrl(c,cProperty,Value,x,y) Class KForm3
  aadd(self:aAllCtrl,{c,cProperty,Value,x,y})
Return self
*
*************************************
*
Method Disable(c) Class KForm3
  aadd(self:aCtrlDsbl,c)
  Return self
  *
  *************************************
  *
  Method Grid(cField,nWidth,nHeight,aWidths,aHeaders,aItems,bDblClick,bChange,;
  aJustify,aCtrl,aValid,cAlias,lCheckBox,lEdit) Class KForm3
  Local nPos,i,c1,c2,bLock
  Local nCode
  Local aTemp  := {}
  Local bLock2 := {|x,y| x }
  Local oForm  := QForm()
  *
  Default bDblClick To {|| __Nulla() }
  Default bChange   To {|| __Nulla() }
  Default lCheckBox To .F.
  Default lEdit     To .F.
  Default cAlias    To nil
  *
  nCode := 5
  nPos := 1
  *
  If !IsNil(aItems)
     asize(aTemp,len(aItems))
     afill(aTemp,.f.)
  Endif
  *
  aadd(Self:aVars,{nCode,cField,aItems,bLock2,aTemp})
  *
  oForm:Control       := 'GRID'
  oForm:Row           := self:Row
  oForm:Col           := self:Col
  oForm:Field         := cField
  oForm:Width         := nWidth
  oForm:Height        := nHeight
  oForm:aWidths       := aWidths
  oForm:aHeaders      := aHeaders
  oForm:Value         := nPos
  oForm:bDblClick     := bDblClick
  oForm:bChange       := bChange
  oForm:aJustify      := aJustify
  oForm:aCtrl         := aCtrl
  oForm:aValid        := aValid
  oForm:Alias         := cAlias
  oForm:lCheckBox     := lCheckBox
  oForm:lEdit         := lEdit
  *
  If !IsNil(cAlias)
     oForm:aColumnFields := aItems
     oForm:aItems        := nil
  else
     oForm:aColumnFields := nil
     oForm:aItems        := aItems
  Endif
  If lCheckBox
     oForm:lShowHeaders  := .F.
  Endif
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  If self:lRowPlus
     self:Row    += nHeight
  Endif
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
  Return self
  *
  *************************************
  *
  Method Browse(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,;
  a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines) Class KForm3
  Local nPos,i,c1,c2,bLock
  Local nCode
  Local aTemp  := {}
  Local aTemp2 := aclone(abHead)
  Local bLock2 := {|x,y| x }
  Local oForm  := QForm()
  *
  Default bChange   To {|| __Nulla() }
  Default bDblClick To {|| __Nulla() }
  Default lLines    To .T.
  *
  nCode := 6
  *
  aadd(Self:aVars,{nCode,cField,nil,bLock2})
  *
  oForm:Control       := 'BROWSE'
  oForm:Row           := self:Row
  oForm:Col           := self:Col
  oForm:Field         := cField
  oForm:Width         := nWidth
  oForm:Height        := nHeight
  oForm:aWidths       := aWidths
  oForm:aHeaders      := aHeaders
  oForm:Value         := nPos
  oForm:aItems        := a_Fields
  oForm:bDblClick     := bDblClick
  oForm:bChange       := bChange
  oForm:aJustify      := aJustify
  *oForm:aCtrl         := aCtrl
  *oForm:aValid        := aValid
  oForm:Alias         := cAlias
  oForm:aBackColor    := aBackColor
  oForm:aHeadClick    := aTemp2
  oForm:lLines        := lLines
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  If self:lRowPlus
     self:Row    += nHeight
  Endif
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
  Return self
  *****************************************************************
  Method TSBrowse(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,;
  a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines) Class KForm3
  Local nPos,i,c1,c2,bLock
  Local nCode
  Local aTemp  := {}
  Local aTemp2 := aclone(abHead)
  Local bLock2 := {|x,y| x }
  Local oForm  := QForm()
  *
  Default bChange   To {|| __Nulla() }
  Default bDblClick To {|| __Nulla() }
  Default lLines    To .T.
  *
  nCode := 6
  *
  aadd(Self:aVars,{nCode,cField,nil,bLock2})
  *
  oForm:Control       := 'TSBROWSE'
  oForm:Row           := self:Row
  oForm:Col           := self:Col
  oForm:Field         := cField
  oForm:Width         := nWidth
  oForm:Height        := nHeight
  oForm:aWidths       := aWidths
  oForm:aHeaders      := aHeaders
  *oForm:Value         := nPos
  oForm:aItems        := a_Fields
  oForm:bDblClick     := bDblClick
  oForm:bChange       := bChange
  oForm:aJustify      := aJustify
  *oForm:aCtrl         := aCtrl
  *oForm:aValid        := aValid
  oForm:Alias         := cAlias
  oForm:aBackColor    := aBackColor
  oForm:aHeadClick    := aTemp2
  oForm:lLines        := lLines
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  If self:lRowPlus
     self:Row    += nHeight
  Endif
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method Tab_Begin(nWidth,nHeight) Class KForm3
  Local oForm := QForm()
  *
  ++self:nTab
  aadd(Self:aVars,{7,'Tab_'+Ntrim(self:nTab),nil,nil})
  *
  oForm:Control       := 'TAB_BEGIN'
  oForm:Field         := 'Tab_'+Ntrim(self:nTab)
  oForm:Row           := self:Row
  oForm:Col           := self:Col
  oForm:Width         := nWidth
  oForm:Height        := nHeight
  *
  aadd(Self:aForm,oForm)
  *
  self:MaxCol := Max(self:Col,nWidth+15)
  self:MaxRow := Max(self:Row,nHeight)
  self:Col    += 5  //nWidth
  self:Row    += 15 //nHeight
  *
  *
Return self
*
*************************************
*
Method Tab_End() Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{7,'',nil,nil})
  *
  oForm:Control       := 'TAB_END'
  aadd(Self:aForm,oForm)
  *
  *
Return self
*
*************************************
*
Method Tab_BeginPage(cPage,nCol,nRow) Class KForm3
  Local oForm := QForm()
  *
  Default nCol to 15
  Default nRow to 45
  *
  ++self:nTab
  aadd(Self:aVars,{7,'Tab_'+Ntrim(self:nTab),nil,nil})
  *
  oForm:Control       := 'TABBEGINPAGE'
  oForm:Caption       := cPage
  oForm:Field         := 'Tab_'+Ntrim(self:nTab)
  aadd(Self:aForm,oForm)
  *
  If nCol != nil
     Self:SetCol(nCol)
  Endif
  *
  If nRow != nil
     self:Row := nRow
  Endif
  *
Return self
*
*************************************
*
Method Tab_EndPage() Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{7,'',nil,nil})
  *
  oForm:Control       := 'ENDPAGE'
  aadd(Self:aForm,oForm)
  *
  *
Return self
*
*************************************
*
Method Tree_Begin(cRoot,nWidth,nHeight,nValue) Class KForm3
  Local oForm := QForm()
  *
  Default nValue To 0
  *
  aadd(Self:aVars,{8,cRoot,nil,nil})
  *
  oForm:Control       := 'TREE_BEGIN'
  oForm:Row           := self:Row
  oForm:Col           := self:Col
  oForm:Width         := nWidth
  oForm:Height        := nHeight
  oForm:Field         := cRoot
  oForm:Value         := nValue
  *
  aadd(Self:aForm,oForm)
  *
  *
  self:Col += nWidth
  If self:lRowPlus
     self:Row += nHeight
  Endif
  *
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method Tree_End() Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{8,'',nil,nil})
  *
  oForm:Control       := 'TREE_END'
  aadd(Self:aForm,oForm)
  *
  *
Return self
*
*************************************
*
Method Tree_BeginNode(cNode,cImage) Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{8,cNode,nil,nil})
  *
  oForm:Control       := 'BEGINNODE'
  oForm:Field         := cNode
  aadd(Self:aForm,oForm)
  *
  *
Return self
*
*************************************
*
Method Tree_AddItem(cItem)   Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{8,cItem,nil,nil})
  *
  oForm:Control       := 'TREE_ITEM'
  oForm:Field         := cItem
  aadd(Self:aForm,oForm)
  *
Return self
*
*************************************
*
Method Tree_EndNode()  Class KForm3
  Local oForm := QForm()
  *
  aadd(Self:aVars,{8,'',nil,nil})
  *
  oForm:Control       := 'TREE_ENDNODE'
  aadd(Self:aForm,oForm)
  *
Return self
*
*************************************
*
Method Image(cImage,nWidth,nHeight,lStretch) Class KForm3
  Local oForm := QForm()
  *
  Default lStretch To .F.
  *
  ++self:nImage
  aadd(Self:aVars,{0,'Image_'+Ntrim(self:nImage),nil,nil})
  *
  oForm:Control    := 'IMAGE'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := 'Image_'+Ntrim(self:nImage)
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  oForm:Picture    := cImage
  oForm:lStretch   := lStretch
  *
  aadd(Self:aForm,oForm)
  *
  self:Col += nWidth
  If self:lRowPlus
     self:Row += nHeight
  Endif
  *
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
*************************************
*
Method GetButtonName(c) Class KForm3
  Local cName,i,c1 := ''
  *
  For i := 1 To Len(self:aForm)
     If self:aForm[i]:Control == 'BUTTON'
        If self:aForm[i]:Caption == c
           c1 := self:aForm[i]:Field
           exit
        Endif
     Endif
  Next
  *
Return c1
*
*************************************
*
Method GetLabelName(c) Class KForm3
  Local cName,i,c1 := ''
  *
  For i := 1 To Len(self:aForm)
     If self:aForm[i,1]:Control == 'LABEL'
        If self:aForm[i]:Caption == c
           c1 := self:aForm[i]:Field
           exit
        Endif
     Endif
  Next
  *
Return c1
*
*************************************
*
Method SetSkipRow(lValue) Class KForm3
  *
  self:lRowPlus := lValue
  *
Return self
*
*************************************
*
Method Okay() Class KForm3
  *
  ___OK(self:Window_Name,self:aVars)
  *
Return self
*
*************************************
*
Method BtnTextBox(cField,nWidth,nHeight,bAction1,bAction2,lEnable,nMaxLen,lRightAlign,lEdit,cFontName,nFontsize,ToolTip) Class KForm3
  Local oForm := QForm()
  Local uValue := _VarGet(cField)
  *
  hb_Default(@lEnable    ,.T.)
  hb_Default(@lEdit      ,.F.)
  hb_Default(@nMaxLen    ,10)
  hb_Default(@lRightAlign,10)
  hb_Default(@cFontName  ,'Arial')
  hb_Default(@nFontSize  ,10)
  hb_Default(@ToolTip    ,{})
  *
  aadd(Self:aVars,{0,cField,nil,nil})
  *
  oForm:Control    := 'BTNTEXTBOX'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Value      := uValue
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  oForm:lEnable    := lEnable
  oForm:lEdit      := lEdit
  oForm:bAction1   := bAction1
  oForm:bAction2   := bAction2
  oForm:nMaxLen    := nMaxLen
  oForm:RightAlign := lRightAlign
  oForm:FontName   := cFontName
  oForm:FontSize   := nFontSize
  oForm:ToolTip    := ToolTip
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
************************************************
*
Method ChkListBox(cField,nWidth,nHeight,aItems,bDblClick,bChange,cFontName,nFontsize,ToolTip,aCheck,lMultiselect) Class KForm3
  Local oForm := QForm()
  Local uValue := _VarGet(cField)
  *
  hb_Default(@cFontName   ,'Arial')
  hb_Default(@nFontSize   ,10)
  hb_Default(@ToolTip    ,'')
  hb_Default(@aCheck      ,{})
  hb_Default(@lMultiselect,.T.)
  *hb_Default(@bDblClick   ,nil)
  hb_Default(@bChange     ,nil)
  *
  aadd(Self:aVars,{10,cField,nil,nil})
  *
  oForm:Control    := 'CHKLISTBOX'
  oForm:Row        := self:Row
  oForm:Col        := self:Col
  oForm:Field      := cField
  oForm:Value      := uValue
  oForm:aItems     := aItems
  oForm:Width      := nWidth
  oForm:Height     := nHeight
  oForm:bDblClick  := bDblClick
  oForm:bChange    := bChange
  oForm:FontName   := cFontName
  oForm:FontSize   := nFontSize
  oForm:ToolTip    := ToolTip
  oForm:aCheck     := aCheck
  *
  aadd(Self:aForm,oForm)
  *
  self:Col    += nWidth
  self:Row    += nHeight
  self:MaxCol := Max(self:Col,self:MaxCol)
  self:MaxRow := Max(self:Row,self:MaxRow)
  *
Return self
*
********************************************************
*
Function FV3_Open(cType,cCaption,bInit,bPostInit,bRelease)
  *
  ++nCurrent
  aadd(aFV3,nil)
  *
  aFV3[nCurrent] := KForm3():New(cType,cCaption,bInit,bPostInit,bRelease)
  *
Return aFV3[nCurrent]
*
*************************************
*
Procedure FV3_SkipRow(x)
  aFV3[nCurrent]:SkipRow(x)
Return
*
*************************************
*
Procedure FV3_SkipCol(x)
  aFV3[nCurrent]:SkipCol(x)
Return
*
*************************************
*
Procedure FV3_SetCol(x)
  aFV3[nCurrent]:SetCol(x)
Return
*
*************************************
*
Procedure FV3_SetRow(x)
  aFV3[nCurrent]:SetRow(x)
Return
*
*************************************
*
Procedure FV3_Show(nMenu,lZoom,nWidth,nHeight,lDebug)
  aFV3[nCurrent]:Show(nMenu,lZoom,nWidth,nHeight,lDebug)
Return
*
*************************************
*
Procedure FV3_Label(cCaption,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic)
  aFV3[nCurrent]:Label(cCaption,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic)
Return
*
*************************************
*
Procedure FV3_TextBox(cField,nWidth,cPict,xOpz,bEnter,bLostFocus,aBackColor,aForeColor,lBold,lItalic,bChange)
  aFV3[nCurrent]:TextBox(cField,nWidth,cPict,xOpz,bEnter,bLostFocus,aBackColor,aForeColor,lBold,lItalic,bChange)
Return
*
*************************************
*
Procedure FV3_ComboBox(cField,nWidth,nHeight,aRay,lEdit,bChange,lDisplayValue)
  aFV3[nCurrent]:ComboBox(cField,nWidth,nHeight,aRay,lEdit,bChange,lDisplayValue)
Return
*
*************************************
*
Procedure FV3_DatePicker(cField,nWidth)
  aFV3[nCurrent]:DatePicker(cField,nWidth)
Return
*
*************************************
*
Procedure FV3_CheckBox(cField,nWidth,cCaption)
  aFV3[nCurrent]:CheckBox(cField,nWidth,cCaption)
Return
*
*************************************
*
Procedure FV3_ListBox(cField,nWidth,nHeight,aRay,lMultiSelect,bEnter,bChange,lDisplayvalue)
  aFV3[nCurrent]:ListBox(cField,nWidth,nHeight,aRay,lMultiSelect,bEnter,bChange,lDisplayValue)
Return
*
*************************************
*
Procedure FV3_Button(cText,nWidth,nHeight,bAction,lEnable)
  aFV3[nCurrent]:Button(cText,nWidth,nHeight,bAction,lEnable)
Return
*
*************************************
*
Procedure FV3_RadioGroup(cField,nWidth,aRay,lHorizontal,nSpace,aReadOnly)
  aFV3[nCurrent]:RadioGroup(cField,nWidth,aRay,lHorizontal,nSpace,aReadOnly)
Return
*
*************************************
*
Procedure FV3_FramedText(cText,nWidth,nAlignment)
  aFV3[nCurrent]:Label(cText,nWidth,nAlignment,{215,215,215},,,,.F.,.F.,.T.)
Return
*
*************************************
*
Procedure FV3_FramedText2(cText,nWidth,nAlignment)
  aFV3[nCurrent]:Label(cText,nWidth,nAlignment,{255,255,255},,,,.F.,.F.,.T.)
Return
*
*************************************
*
Procedure FV3_FramedText3(cField,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic)
  aFV3[nCurrent]:Label2(cField,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic)
Return
*
*************************************
*
Procedure FV3_Label2(cField,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic)
  aFV3[nCurrent]:Label2(cField,nWidth,nAlignment,aBackColor,cFont,nSize,aForeColor,lBold,lBorder,lClientEdge,lUnderline,lItalic)
Return
*
*************************************
*
Function FV3_Result()
  Local o := aFV3[nCurrent]
  --nCurrent
  asize(aFV3,nCurrent)
  *
Return o:Result()
*
*************************************
*
Procedure FV3_Frame(cText,nWidth,nHeight)
  aFV3[nCurrent]:Frame(cText,nWidth,nHeight)
Return
*
*************************************
*
Procedure FV3_Activex(cField,nWidth,nHeight,cProgId)
  aFV3[nCurrent]:Activex(cField,nWidth,nHeight,cProgId)
Return
*
*************************************
*
Procedure FV3_EditBox(cField,nWidth,nHeight,bChange)
  aFV3[nCurrent]:EditBox(cField,nWidth,nHeight,bChange)
Return
*
*************************************
*
Procedure FV3_RtfBox(cField,nWidth,nHeight)
  aFV3[nCurrent]:RtfBox(cField,nWidth,nHeight)
Return
*
*************************************
*
Procedure FV3_ProgressBar(cField,nWidth,nHeight)
  aFV3[nCurrent]:ProgressBar(cField,nWidth,nHeight)
Return
*
*************************************
*
Function FV3_GetRow()
Return aFV3[nCurrent]:GetRow()
*
*************************************
*
Function FV3_GetCol()
Return aFV3[nCurrent]:GetCol()
*
*************************************
*
Procedure FV3_SkipRow20()
  aFV3[nCurrent]:SkipRow(20)
Return
*
*************************************
*
Procedure FV3_SkipRow25()
  aFV3[nCurrent]:SkipRow(25)
Return
*
*************************************
*
Procedure FV3_SkipRow30()
  aFV3[nCurrent]:SkipRow(30)
Return
*
*************************************
*
Procedure FV3_SetFont(c,cFont,nSize)
  aFV3[nCurrent]:SetFont(c,cFont,nSize)
Return
*
*************************************
*
Procedure FV3_SetAllCtrl(c,cProperty,Value,x,y)
  aFV3[nCurrent]:SetAllCtrl(c,cProperty,Value,x,y)
Return
*
*************************************
*
Procedure FV3_Disable(c)
  aFV3[nCurrent]:Disable(c)
Return
*************************************
Procedure FV3_Enable(c)
  aFV3[nCurrent]:Enable(c)
Return
*************************************
*
Procedure FV3_Okay()
  aFV3[nCurrent]:Okay()
Return
*
*************************************
*
Function FV3_Recno(c,Recno)
Return aFV3[nCurrent]:DoMethod(c,'Recno',Recno)
*
*************************************
*
Procedure FV3_Grid(cField,nWidth,nHeight,aWidths,aHeaders,aItems,bDblClick,bChange,aJustify,aCtrl,aValid,cAlias,lCheckBox,lEdit)
  aFV3[nCurrent]:Grid(cField,nWidth,nHeight,aWidths,aHeaders,aItems,bDblClick,bChange,aJustify,aCtrl,aValid,cAlias,lCheckBox,lEdit)
Return
*
*************************************
*
Procedure FV3_Browse(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines)
  aFV3[nCurrent]:Browse(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines)
Return
*
*************************************
*
Procedure FV3_TSBrowse(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines)
  aFV3[nCurrent]:TSBrowse(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines)
Return
*************************************
*
Procedure FV3_Spinner(cField,nWidth,nMin,nMax,bAction)
  aFV3[nCurrent]:Spinner(cField,nWidth,nMin,nMax,bAction)
Return
*
*************************************
*
Function FV3_Tab_Begin(cTab,nWidth,nHeight)
Return aFV3[nCurrent]:Tab_Begin(cTab,nWidth,nHeight)
*
*************************************
*
Procedure FV3_Tab_End()
  aFV3[nCurrent]:Tab_End()
Return
*
*************************************
*
Procedure FV3_Tab_BeginPage(cPage,nCol,nRow)
  aFV3[nCurrent]:Tab_BeginPage(cPage,nCol,nRow)
Return
*
*************************************
*
Procedure FV3_Tab_EndPage()
  aFV3[nCurrent]:Tab_EndPage()
Return
*
*************************************
*
Procedure FV3_Image(cImage,nWidth,nHeight,lStretch)
  aFV3[nCurrent]:Image(cImage,nWidth,nHeight,lStretch)
Return
*
*************************************
*
Procedure FV3_Tree_Begin(cRoot,nWidth,nHeight,nValue)
  aFV3[nCurrent]:Tree_Begin(cRoot,nWidth,nHeight,nValue)
Return
*
*************************************
*
Procedure FV3_Tree_End()
  aFV3[nCurrent]:Tree_End()
Return
*
*************************************
*
Procedure FV3_Tree_BeginNode(cNode,cImage)
  aFV3[nCurrent]:Tree_BeginNode(cNode,cImage)
Return
*
*************************************
*
Procedure FV3_Tree_AddItem(cItem)
  aFV3[nCurrent]:Tree_AddItem(cItem)
Return
*
*************************************
*
Procedure FV3_Tree_EndNode()
  aFV3[nCurrent]:Tree_EndNode()
Return
*
*************************************
*
Procedure FV3_EndWindow()
  ___Cancel(ThisWindow.Name)
Return
*
*************************************
*
Procedure FV3_OpenMain(cCaption,bInit,bPostInit,bRelease)
  FV3_Open('MAIN',cCaption,bInit,bPostInit,bRelease)
Return
*
*************************************
*
Procedure FV3_OpenModal(cCaption,bInit,bPostInit,bRelease)
  FV3_Open('MODAL',cCaption,bInit,bPostInit,bRelease)
Return
*
*************************************
*
Procedure FV3_SetDbf(x)
  aFV3[nCurrent]:lDbf    := x
Return
*
*************************************
*
Function FV3_GetDbf()
Return aFV3[nCurrent]:lDbf
*
*************************************
*
Procedure FV3_SetSkipRow(lValue)
  *
  aFV3[nCurrent]:SetSkipRow(lValue)
  *
Return
*
*************************************
*
Procedure FV3_SetPos(x,y)
  *
  FV3_SkipRow(x)
  FV3_SkipCol(y)
  *
Return
*
*************************************
*
Procedure FV3_ButtonCancel(cCaption,nWidth,nHeight)
  *
  FV3_Button(cCaption,nWidth,nHeight,'___Cancel()')
  *
Return
*
*************************************
*
Procedure FV3_ButtonOK(c,nWidth,nHeight)
  *
  *FV3_Button(c,nWidth,nHeight,{||   _OKKK_() })
  FV3_Button(c,nWidth,nHeight,{||  aFV3[nCurrent]:Okay() })
  *
Return
*
*************************************
*
Procedure FV3_DisableButton(c)
  *
  SetProperty(aFV3[nCurrent]:Window_Name,aFV3[nCurrent]:GetButtonName(c),'Enabled',.F.)
  *
Return
*
*************************************
*
Procedure FV3_EnableButton(c)
  *
  SetProperty(aFV3[nCurrent]:Window_Name,aFV3[nCurrent]:GetButtonName(c),'Enabled',.T.)
  *
Return
*
*************************************
*
Procedure FV3_SetAllCheckBox(cField,lValue)
  aFV3[nCurrent]:SetAllCheckBox(cField,lValue)
Return
*
*************************************
*
Function FV3_GetMaxCol()
Return aFV3[nCurrent]:MaxCol()
*
*************************************
*
Function FV3_GetMaxRow()
Return aFV3[nCurrent]:MaxRow()
*
*************************************
*
Procedure FV3_Refresh(c)
  *
  If upper(c) $ aFV3[nCurrent]:cFields
     DoMethod(aFV3[nCurrent]:Window_Name,c,'Refresh')
  else
     MsgDebug('Alert! Parameter UnkNow!')
  Endif
  *
Return
*
*************************************
*
Static Procedure ___Cancel(cWin)
  Local nPos
  *
  If cWin == nil
     cWin := aFV3[nCurrent]:Window_Name
  Endif
  *
  aArrayMem               := {}
  aFV3[nCurrent]:lDbf     := .F.
  nPos := ascan(aResult,{|a| a[1] == cWin})
  aResult[nPos,2]         := .F.
  DoMethod(cWin,'Release')
  *
Return
*
*************************************
*
Static Procedure ___OK(cWinName,aVars)
  Local i,a1,nPos,n,a2,c1
  *
  For i := 1 To len(aVars)
     if aVars[i,1] == 0
        nPos := GetProperty(cWinName,aVars[i,2],"Value")
        If valtype(aVars[i,4]) == 'B'
           _VarPut(aVars[i,2],eval(aVars[i,4],nPos,aVars[i,3]))
        else
           _VarPut(aVars[i,2],GetProperty(cWinName,aVars[i,2],"Value"))
        Endif
        *
     elseif aVars[i,1] == 1    // ComboBox Edit
        *
        If valtype(aVars[i,4]) == 'B'
           nPos := GetProperty(cWinName,aVars[i,2],"Value")
           _VarPut(aVars[i,2],eval(aVars[i,4],nPos,aVars[i,3]))
        else
           _VarPut(aVars[i,2],Trim(GetProperty(cWinName,aVars[i,2],"DisplayValue")))
        Endif
        *
     elseif aVars[i,1] == 2    // ComboBox 2dim
        *
        If valtype(aVars[i,4]) == 'B'
           nPos := GetProperty(cWinName,aVars[i,2],"Value")
           _VarPut(aVars[i,2],eval(aVars[i,4],nPos,aVars[i,3]))
        else
           _VarPut(aVars[i,2],Trim(GetProperty(cWinName,aVars[i,2],"DisplayValue")))
        Endif
        *
     elseif aVars[i,1] == 3 // ListBox 2 dim
        *
        If valtype(aVars[i,4]) == 'B'
           _VarPut(aVars[i,2],eval(aVars[i,4],GetProperty(cWinName,aVars[i,2],"Value"),aVars[i,3]))
        else
           _VarPut(aVars[i,2],_VarPut(aVars[i,2],GetProperty(cWinName,aVars[i,2],"Value")))
        Endif
        *
     elseif aVars[i,1] == 4 // ListBox
        *
        a1 := {}
        For n := 1 To GetProperty(cWinName,aVars[i,2],"ItemCount")
           aadd(a1,GetProperty(cWinName,aVars[i,2],"Item",n))
        Next
        If valtype(aVars[i,4]) == 'B'
           _VarPut(aVars[i,2],eval(aVars[i,4],GetProperty(cWinName,aVars[i,2],"Value"),a1))
        else
           nPos := GetProperty(cWinName,aVars[i,2],"Value")
           _VarPut(aVars[i,2],a1[nPos])
        Endif
        *
     elseif aVars[i,1] == 5 /* GRID */
        a1 := {}
        #ifdef ___FV3_EXT___
           For n := 1 To GetProperty(cWinName,aVars[i,2],"ItemCount")
              c1 := GetProperty(cWinName,aVars[i,2],"CheckBoxItem",n)
              aadd(a1,c1)
           Next
           _VarPut(aVars[i,2],a1)
        #else
           if GetProperty(cWinName,aVars[i,2],"CheckBoxEnabled")
              _VarPut(aVars[i,2],aVars[i,5])
           else
              For n := 1 To GetProperty(cWinName,aVars[i,2],"ItemCount")
                 c1 := GetProperty(cWinName,aVars[i,2],"Item",n)
                 aadd(a1,c1)
              Next
              _VarPut(aVars[i,2],a1)
           endif
        #endif
        *
     elseif aVars[i,1] == 5 /* GRID */
     elseif aVars[i,1] == 6 /* BROWSE */
     elseif aVars[i,1] == 7 /* Tab  */
     elseif aVars[i,1] == 8 /* Tree */
     elseif aVars[i,1] == 9 /* Label-FramedText-Frame */
     elseif aVars[i,1] == 10 /* CHECKLISTBOX */
        a1 := {}
        #ifdef ___FV3_EXT___
           For n := 1 To GetProperty(cWinName,aVars[i,2],"ItemCount")
              c1 := GetProperty(cWinName,aVars[i,2],"CheckBoxItem",n)
              aadd(a1,c1)
           Next
           _VarPut(aVars[i,2],a1)
        #endif
     endif
  next
  *
  aArrayMem    := {}
  aArrayMem    := aclone(aFV3[nCurrent]:aCargo)
  aFV3[nCurrent]:lDbf := .F.
  nPos := ascan(aResult,{|a| a[1] == cWinName})
  aResult[nPos,2] := .T.
  DoMethod(cWinName,'Release')
  *
Return
*
*************************************
*
Function FV3_Find_ListBox(cField,cSearch)
  Local n,c1,i,nRet
  *
  nRet := 0
  n := FV3_GetProperty(cField,'ItemCount')
  For i := 1 To n
     c1 := FV3_GetProperty(cField,'Item',i)
     If c1 == cSearch
        nRet := i
        exit
     Endif
  Next
  *
Return nRet
*
*************************************
*
Function FV3_Get_ListBox(cField)
  Local n,i,aRet
  *
  aRet := {}
  n := FV3_GetProperty(cField,'ItemCount')
  For i := 1 To n
     aadd(aRet,FV3_GetProperty(cField,'Item',i))
  Next
  *
Return aRet
*
*************************************
*
Procedure FV3_FramedText4(cText,nWidth,nAlignment)
  aFV3[nCurrent]:Label(cText,nWidth,nAlignment,{255,255,255}, , ,{128,128,128},,,.T.)
Return
*
*************************************
*
Procedure FV3_SetProperty(p1,p2,p3)
  *
  If upper(p1) $ aFV3[nCurrent]:cFields
  else
     MsgInfo('Alert! '+p1+' UnkNow!')
  Endif
  if Pcount() == 3
     SetProperty(aFV3[nCurrent]:Window_Name,p1,p2,p3)
  elseif Pcount() == 2
     SetProperty(aFV3[nCurrent]:Window_Name,p1,p2)
  elseif Pcount() == 1
     SetProperty(aFV3[nCurrent]:Window_Name,p1)
  Endif
  *
Return
*
*************************************
*
Function FV3_GetProperty(p1,p2,p3)
  Local uValue
  *
  If upper(p1) $ aFV3[nCurrent]:cFields
  else
     MsgInfo('Alert! '+p1+' UnkNow!')
  Endif
  if Pcount() == 3
     uValue := GetProperty(aFV3[nCurrent]:Window_Name,p1,p2,p3)
  elseif Pcount() == 2
     uValue := GetProperty(aFV3[nCurrent]:Window_Name,p1,p2)
  elseif Pcount() == 1
     uValue := GetProperty(aFV3[nCurrent]:Window_Name,p1)
  Endif
  *
Return uValue
*
*************************************
*
Procedure FV3_DoMethod(p1,p2,p3)
  *
  If upper(p1) $ aFV3[nCurrent]:cFields
  else
     MsgInfo('Alert! '+p1+' UnkNow!')
  Endif
  if Pcount() == 3
     DoMethod(aFV3[nCurrent]:Window_Name,p1,p2,p3)
  elseif Pcount() == 2
     DoMethod(aFV3[nCurrent]:Window_Name,p1,p2)
  elseif Pcount() == 1
     DoMethod(aFV3[nCurrent]:Window_Name,p1)
  Endif
  *
Return
*
*************************************
*
Function FV3_Version()
Return Version
*
*************************************
*
Procedure FV3_SetValue(cField,uValue)
  AADD(aFV3[nCurrent]:aCargo,{upper(cField),uValue})
Return
*
*************************************
*
Procedure FV3_PutValue(cField,uValue)
  AADD(aFV3[nCurrent]:aCargo,{upper(cField),uValue})
Return
*
*************************************
*
Procedure FV3_APutValues(aRay)
  aeval(aRay,{|a| FV3_PutValue(a[1],a[2]) })
Return
*
*************************************
*
Function FV3_GetValue(cField)
  Local nPos := ascan(aArrayMem,{|a| a[1] == upper(cField) })
  *
Return aArrayMem[nPos,2]
*
*************************************
*
Procedure FV3_Browse2(cField,nWidth,nHeight,aWidths,aHeaders,cAlias,a_Fields,bDblClick,bChange,aJustify,abHead,aBackColor,lLines)
  FV3_Grid(cField,nWidth,nHeight,aWidths,aHeaders,a_Fields,bDblClick,bChange,aJustify,nil,nil,cAlias,.F.,.F.)
Return
*
*************************************
*
Procedure FV3_SetRecno(cField,nRecno)
  FV3_SetProperty(cField,'Value',nRecno)
Return
*
*************************************
*
Procedure FV3_SetRecno2(cField,nRecno)
  FV3_SetProperty(cField,'Recno',nRecno)
Return
*
*************************************
*
Procedure FV3_Enabled(c,l)
  FV3_SetProperty(c,'Enabled',l)
Return
*
*************************************
*
Procedure FV3_BtnTextBox(cText,nWidth,nHeight,bAction1,bAction2,lEnable,nMaxLen,lRightAlign,lEdit,cFontName,nFontsize,ToolTip)
  aFV3[nCurrent]:BtnTextBox(cText,nWidth,nHeight,bAction1,bAction2,lEnable,nMaxLen,lRightAlign,lEdit,cFontName,nFontsize,ToolTip)
Return
*
*************************************
*
Procedure FV3_ChkListBox(cField,nWidth,nHeight,aItems,bDblClick,bChange,cFontName,nFontsize,ToolTip,aCheck,lMultiselect)
  aFV3[nCurrent]:ChkListBox(cField,nWidth,nHeight,aItems,bDblClick,bChange,cFontName,nFontsize,ToolTip,aCheck,lMultiselect)
Return
*
*************************************
*
*
Function FV3_GetButtonName(c)
Return aFV3[nCurrent]:GetButtonName(c)
*
*************************************
*
Function FV3_GetLabelName(c)
Return aFV3[nCurrent]:GetLabelName(c)
*
*************************************
*
Function FV3_GetLastWindow(nLast)
  Local n := nCurrent
  *
  Default nLast To 0
  *
  If nLast > 0
     n -= nLast
  Endif
  *
Return aFV3[n]:Window_Name
*
*************************************
*
Static Procedure __Nulla()
  *msginfo('ok __Nulla')
Return
*
*************************************
*
Static Function _VarGet(cVar)
  Local uValue,nPos
  *
  If aFV3[nCurrent]:lDbf
     uValue := FieldGet(FieldPos(cVar))
  else
     IF !empty(aFV3[nCurrent]:aCargo)
        nPos := ascan(aFV3[nCurrent]:aCargo,{|a| a[1] == upper(cVar) })
        uValue := aFV3[nCurrent]:aCargo[nPos,2]
        aFV3[nCurrent]:aCargo[nPos,2] := nil
     else
        uValue := __MVGET(cVar)
     Endif
  Endif
  *
Return uValue
*
*************************************
*
Static Procedure _VarPut(cVar,uValue)
  Local i
  *
  If aFV3[nCurrent]:lDbf
     FieldPut(FieldPos(cVar),uValue)
  else
     IF !empty(aFV3[nCurrent]:aCargo)
        For  i := 1 To Len(aFV3[nCurrent]:aCargo)
           IF aFV3[nCurrent]:aCargo[i,1] == upper(cVar)
              aFV3[nCurrent]:aCargo[i,2] := uValue
              exit
           Endif
        Next
     else
        __MVPUT(cVar,uValue)
     Endif
  Endif
  *
Return
*
*************************************
*
