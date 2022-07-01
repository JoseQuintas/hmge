*
/*
* Project: HMG_MySync
* Description: Folders Synchronization
* Autor: Brunello Pulix
* Fecha: 12/24/2012
* brunellopulix@gmail.com
*
* corrected and perfected by Brunello Pulix
* added sync from leto server
* 05/03/2020
*
* rewrote corrected and perfected by Brunello Pulix
* added new features
* 23/11/2021
*
*/
# include 'minigui.ch'
#ifndef __HMG__
# include 'common.ch'
#endif
# include <Directry.ch>
*
# DEFINE _NAME     1
# DEFINE _SIZE     2
# DEFINE _DATE     3
# DEFINE _TIME     4
*
#translate NTRIM( <v1> ) => ( hb_ntos(<v1>) )
*
REQUEST DBFCDX,DBFFPT
*
REQUEST LETO, HB_MEMIO
REQUEST rddinfo
REQUEST leto_VarGet, leto_varSet, leto_varGetCached, leto_varDel
REQUEST DbSetIndex, DbClearIndex
REQUEST DBORDERINFO, ORDLISTCLEAR, ORDBAGCLEAR, ORDDESTROY
REQUEST LETO_DBEVAL, DBINFO
*
# define BUTTONSELECT 'Target Drive'
# define BUTTONCLOSE  'Close'
*
Static lTimer
Field Group In MySync
*
Memvar xToday,xTime,xBackup,xFolders,xFiles
Memvar xType,xIP,xMinimize,aType, aType2,xOff
*************************************
*
Procedure Main()
  Local lFlag := .F.
  *
  Set BrowseSync On
  Set Century ON
  Set Deleted ON
  Set Date British
  *
  Public xToday,xTime,xBackup,xFolders,xFiles
  Public xType,xIP,xMinimize,aType, aType2,xOff
  *
  aType  := {'INC','FULL','ZIP','LETO'}
  aType2 := {'incremental','full','zip','Leto'}
  *
  Install()
  *
  IF !File('.\DB\CFG.INI')
     F_Open('.\DB\CFG.INI')
     F_Write("[Setup]")
     F_Write("Today="+DtoC(Date()))
     F_Write("Drive="+hb_CurDrive())
     F_Write("Time=14:00")
     F_Write("Backup=0")
     F_Write("Folders=0")
     F_Write("Files=0")
     F_Write("Type=0")
     F_Write("IP=192.168.1.100")
     F_Write("Minimize=0")
     F_Write("Off=0")
     F_Close()
  Endif
  *
  BEGIN INI FILENAME '.\DB\CFG.INI'
  xToday    := Ini_Get('Setup',"Today"   ,'D')
  xTime     := Ini_Get('Setup',"Time"    ,'C')
  xBackup   := Ini_Get('Setup',"Backup"  ,{|x| if(x=='0',.F.,.T.)})
  xFolders  := Ini_Get('Setup',"Folders" ,{|x| if(x=='0',.F.,.T.)})
  xFiles    := Ini_Get('Setup',"Files"   ,{|x| if(x=='0',.F.,.T.)})
  xType     := Ini_Get('Setup',"Type"    ,{|x| if(x=='0',1,2)})
  xMinimize := Ini_Get('Setup',"Minimize",{|x| if(x=='0',.F.,.T.)})
  xIP       := Ini_Get('Setup',"IP"      ,'C')
  xOff      := Ini_Get('Setup',"Off"     ,{|x| if(x=='0',.F.,.T.)})
  END INI
  *
  M->Current := 0
  FV3_OpenMain('HMG_MYSYNC - folders synchronize - from Leto Server - by Brunello Pulix (Italy)',,{|cWin| PostInit(cWin) },{|| dbcloseall() })
  FV3_PutValue('ORIGIN','')
  FV3_PutValue('LSTBOX','' )
  *FV3_PutValue('Radio1',xType  )
  FV3_PutValue('CHECK1',xFolders)
  FV3_PutValue('CHECK2',xFiles)
  FV3_PutValue('TIME1' ,xTime)
  FV3_PutValue('TEXT2' ,'')
  FV3_PutValue('Turn_Off',xOff)
  *
  FV3_Label('Origin',70)
  FV3_FramedText3('ORIGIN',200,0,{255,255,255},'Courier New',10,,,,.T.,,)
  FV3_Label('',10)
  FV3_SetSkipRow(.F.)
  FV3_Label('',30)
  FV3_CheckBox('CHECK1',70,'Folders')
  FV3_CheckBox('CHECK2',70,'Files'  )
  FV3_SetCol(775)
  FV3_Button('Start',70,23,{|cWin| Start(cWin) })
  FV3_ButtonCancel(BUTTONCLOSE,70,23)
  FV3_SetSkipRow(.T.)
  FV3_SkipRow(35)
  FV3_ListBox('LSTBOX',900,450,{''})
  FV3_SkipRow(1)
  FV3_ProgressBar('PBar2',900,10)
  FV3_SkipRow(10)
  FV3_ProgressBar('PBar3',900,10)
  *
  FV3_SkipRow(25)
  *
  FV3_Label('',5)
  FV3_FramedText3('TEXT2',330,1,{255,255,255},'Courier New',10,,,,.T.,,)
  FV3_Label('',5)
  FV3_FramedText2('Time:',45,1)
  FV3_TextBox('TIME1'  ,50,'99:99',,,,,,.T.,,)
  FV3_Label('',5)
  FV3_Button('Start Timer',100,23,{|cWin| Start2(cWin) })
  *
  FV3_Button('Browse'  ,70,23,{|cWin| Menu(cWin) })
  FV3_Label('',5)
  FV3_CheckBox('Turn_Off',70,'Turn Off')
  *
  FV3_SetFont('LSTBOX','Courier New',9)
  *
  FV3_Show()
  *
  FV3_Result()
  *
Return
*
*************************************
*
Static Procedure PostInit(cWin)
  Local nHeight
  *
  nHeight := GetProperty(cWin,'Height')
  SetProperty(cWin,'Height',nHeight)
  *
  If xMinimize
     DoMethod(cWin,'Minimize')
  Endif
  *
  if Date() > xToday
     xToday := Date()
     Put_Ini('.\DB\CFG.INI','Setup','Today',Dtoc(xToday))
     If xBackup
        Start2(cWin)
     Endif
  Endif
  *
Return
*
*************************************
*
Procedure Out_List_1(c)
  *
  F_Write(c)
  FV3_DoMethod('LSTBOX','AddItem',c)
  FV3_SetProperty('LSTBOX','Value',++M->Current)
  DO EVENTS
  *
Return
*
*************************************
*
Procedure PBar2(x,y)
  Static nRange
  *
  If !hb_IsNil(y)
     FV3_SetProperty('PBar2','RangeMax',y)
     nRange := y
  Endif
  FV3_SetProperty('PBar2','Value',x)
  DO EVENTS
  *
Return
*
Procedure PBar3(x,y)
  Static nRange
  *
  If !hb_IsNil(y)
     FV3_SetProperty('PBar3','RangeMax',y)
     FV3_SetProperty('PBar3','BackColor',CLR_WHITE)
     nRange := y
  Endif
  FV3_SetProperty('PBar3','Value',x)
  DO EVENTS
  *
Return
*
Procedure CopyFromServer(cLocalfile,cServerFile/*,cFileName*/)
  Local nHandle
  Local nHandle2
  Local nBytes
  Local nTotBytes
  Local cBuff
  Local Count
  Local x
  Local y
  Local x1,x2,x3
  *Local a1
  *Local n3
  *
  nTotBytes := Leto_FileSize(cServerFile)
  nBytes    := 5700*8
  nHandle   := Leto_Fopen(cServerFile)
  cBuff     := space(nBytes)
  *
  nHandle2 := FCreate(cLocalFile)
  *
  x := int((nTotBytes/nBytes)/100)
  *
  PBar3(0,100)
  *
  *a1 := {'25%','50%','75%','100%'}
  x2 := int(x/2)
  x1 := int(x2/2)
  x3 := x2+x1
  *n3 := 0
  Count := 0
  y     := 0
  Do While (!Leto_Feof(nHandle))
     *
     ++Count
     If Count == x
        ++y
        PBar3(y)
        Count := 0
*        IF y == 25 .or. y == 50 .or. y == 75
*           SendToLog('(D0) - '+Time()+' ('+a1[++n3]+')'+'-Download '+Trim(cFilename))
*        Endif
     Endif
     *
     Leto_Fread(nHandle,@cBuff,nBytes)
     FWrite(nHandle2,cBuff)
     nTotBytes -= nBytes
     If nTotBytes < nBytes
        nBytes := nTotBytes
        cBuff  := space(nBytes)
     Endif
     *
  Enddo
  Leto_FClose(nHandle)
  FClose(nHandle2)
  PBar3(0)
  *
Return
*
Procedure Start2(cWin)
  Local cTime
  Local nSecs
  Local nx
  *
  cTime := Left(GetProperty(cWin,'TIME1','Value'),5)
  *
  nSecs := TimeAsSeconds(cTime+':00')
  nx    := nSecs+60*3
  lTimer := .F.
  *
  SetProperty(cWin,'TEXT2','Value','........Wait for '+cTime+'........')
  *
  If !lTimer
     DEFINE TIMER Timer1 OF &(cWin) INTERVAL 800 ACTION UpdateMsg(cWin,nSecs)
        lTimer := .T.
  else
     SetProperty(cWin,'Timer1','Enabled',.T.)
  endif
  *
Return
*
Procedure Start(/*cWin*/)
  Local cDrive  := ''
  Local cOrigin
  Local cTarget
  Local lFolders
  Local lFiles
  Local a3      := {}
  Local c1
  Local n,i
  Local aPaths
  Local aLeto
  Local lForce  := .F.
  *
  FV3_SetProperty('TEXT2','Value','........Connecting........')
  FV3_SetProperty('TEXT2','Value','')
  aPaths := {}
  aLeto  := {}
  Select MySync
  dbgotop()
  Do while !Eof()
     IF Field->Active
        aadd(aPaths,{Trim(Field->Origin),Trim(Field->Target),nil,.F.,.F.,Field->Flag2})
        aadd(aLeto,Trim(Left(Field->LetoPath,AT('/*',Field->LetoPath)-1)))
     Endif
     MySync->(dbskip())
  Enddo
  *
  dbgotop()
  FV3_DoMethod('LSTBOX','DeleteAllItems')
  F_Open('LOG\'+Dtos(Date())+'_'+StrTran(Time(),':','_')+'.TXT')
  M->Current := 0
  For i := 1 To Len(aPaths)
     *
     If !empty(aLeto[i])
        IF leto_Connect( aLeto[i] ) < 0
           F_Write(aLeto[i]+'   -   Connection '+aLeto[i]+' Error!')
           msginfo('Connection '+aLeto[i]+' Error!')
        else
           *
           F_Write(aLeto[i]+'   -   Connection '+aLeto[i]+' OK!')
           cOrigin  := aPaths[i,1]
           cTarget  := aPaths[i,2]
           lFolders := FV3_GetProperty('CHECK1','Value')
           lFiles   := FV3_GetProperty('CHECK2','Value')
           a3       := hb_ATokens(cTarget,'\')
           c1       := ''
           *
           If Left(cOrigin,1) != '\'
              M->LetoPath := aLeto[i]
              FV3_SetProperty('ORIGIN','Value',cOrigin)
              cDrive  := Left(cOrigin,2)
              cOrigin := Substr(cOrigin,3)
              *  copia sul server
              SaveFilesToLeto(cOrigin,cTarget,lForce,lFolders,lFiles,cDrive)
           else
              *
              M->LetoPath := aLeto[i]
              FV3_SetProperty('ORIGIN','Value',aLeto[i])
              cDrive  := Left(cTarget,2)
              cTarget := Substr(cTarget,3)
              * copia dal server
              SaveFilesFromLeto(cOrigin,cTarget,lForce,lFolders,lFiles,cDrive)
           endif
           *
           leto_disconnect()
        Endif
     else
        cOrigin  := aPaths[i,1]
        cTarget  := aPaths[i,2]
        lFolders := FV3_GetProperty('CHECK1','Value')
        lFiles   := FV3_GetProperty('CHECK2','Value')
        a3       := hb_ATokens(cTarget,'\')
        c1       := ''
        FV3_SetProperty('ORIGIN','Value',cOrigin)
        If aPaths[i,6] == 2
           Zippy(cOrigin,cTarget)
        else
           FOR n := 2 TO Len(a3)
              c1 += '\'+a3[n]
              MakeDir(c1)
           NEXT
           SaveFiles(cOrigin,cTarget,lForce,lFolders,lFiles)
        Endif
     Endif
  Next
  F_Close()
  IF xOff
     FV3_EndWindow()
  Endif
  *
Return
*
Procedure UpdateMsg(cWin,nSecs)
  *
  If Seconds() >= nSecs
     lTimer := .F.
     SetProperty(cWin,'Timer1','Enabled',.F.)
     SetProperty(cWin,'TEXT2' ,'Value'  ,'')
     Start()
  endif
  *
Return
*
Function SecsToTime(n)
  Local cTime := Time()
  Local nH
  Local nM
  *
  nH := val(Left(cTime,2))
  nM := Val(Substr(cTime,4,2))+n
  *
  If nM > 60
     nH := nH+1
     nM := 60-nM
  Endif
  *
Return StrZero(nH,2)+':'+StrZero(nM,2)
*
Procedure Iberna()
  ShellExecute(,"Open",'Iberna.Bat','',,0)
Return
*
Procedure Install()
  LOCAL aDbf
  LOCAL i
  Local aTemp := {}
  *
  MakeDir('LOG')
  MakeDir('DB')
  MakeDir('ZIP')
  *
  IF !File('.\DB\MySync.Dbf')
     *
     aDbf := {;
     {'ORIGIN'   ,'C',100,0},;
     {'TARGET'   ,'C',100,0},;
     {'ACTIVE'   ,'L',  1,0},;
     {'FLAG1'    ,'L',  1,0},;
     {'FLAG2'    ,'N',  1,0},;
     {'LETOPATH' ,'C', 50,0},;
     {'GROUP'    ,'C',  1,0}}
     *
     DBCREATE('.\DB\MySync.Dbf',aDbf,'DBFCDX')
     *
  ENDIF
  *
  DBUSEAREA(.T.,'DBFCDX','.\DB\MySync.Dbf','MySync',.F.)
  If !File('.\DB\MySync.cdx')
     index on Group To ('.\DB\MySync.cdx')
  else
     Set index To ('.\DB\MySync.cdx')
  Endif
  If File('.\DB\_MySync.dbf')
     Append From ('.\DB\_MySync.Dbf')
     ferase('.\DB\_MySync.Dbf')
  Endif
  dbgotop()
  *
  aTemp := Directory('.\LOG\*.Txt')
  If Len(aTemp) > 10
     ASort(aTemp,,,{|x,y| x[1] > y[1] })
     For i := 11 To Len(aTemp)
        Ferase('.\LOG\'+aTemp[i,1])
     Next
  Endif
  *
Return
*
Procedure Menu(/*cWin*/)
  *
  FV3_OpenModal('Browse - Archives',nil,{|cWin| Browse1PostInit(cWin) },nil)
  *
  FV3_Browse('BROWSE1',900,320,;
  {60,50,265,265,50,190},;
  {'Active','Group','Folders Origin','Folders Target','Type','LetoPath'},;
  'MySync',;
  {"If(Field->Active,'ON','OFF')",'Group','Origin','Target',"GetType()",'LetoPath'},;
  {|| Properties(.F.) },;
  nil,;
  {2,2,0,0,2,0},;
  nil,;
  nil,;
  .F.)
  *
  FV3_SkipRow(25)
  FV3_Button('New Record'      ,087,30,{|| NewRecord()     })
  FV3_Button('Properties'      ,087,30,{|| Properties(.F.) })
  FV3_Button('Delete'          ,087,30,{|| DeleteRecord()  })
  FV3_Button('Invert'          ,087,30,{|| Invert()        })
  FV3_Button('Sort Dbf'        ,087,30,{|| SortDbf()       })
  FV3_Button('All ON'          ,087,30,{|| All_ON_Dbf()    })
  FV3_Button('All OFF'         ,087,30,{|| All_OFF_Dbf()   })
  FV3_Button('Delete All'      ,087,30,{|| DeleteAll()     })
  FV3_Button('Multi SubFolders',097,30,{|| Properties(.T.,.T.)})
  FV3_ButtonCancel('Close'     ,115,30)
  *
  FV3_Show()
  *
  FV3_Result()
  *
Return
*
Procedure NewRecord()
  *
  Properties(.T.)
  *
Return
*****************************
Procedure Properties(lNew,l2)
  Local cTitle,aTemp
  Local i,c1,c2,a1
  Local aGroup := {'A','B','C','D','E','F','G','H','K','J','I'}
  *
  hb_Default(@lNew,.F.)
  hb_Default(@l2  ,.F.)
  *
  If !lNew .and. Eof()
     *   lNew := .T.
     Return
  Endif
  *
  aTemp := array(6)
  *
  If lNew
     aTemp[1] := {'_Active'  ,.F.       }
     aTemp[2] := {'_Origin'  ,Space(100)}
     aTemp[3] := {'_Target'  ,Space(100)}
     aTemp[4] := {'_Flag2'   ,1         }
     aTemp[5] := {'_LetoPath',space(30) }
     aTemp[6] := {'_Group'   ,'A'       }
     cTitle   := [New Record - Properties']
  else
     aTemp[1] := {'_Active'  ,MySync->Active  }
     aTemp[2] := {'_Origin'  ,MySync->Origin  }
     aTemp[3] := {'_Target'  ,MySync->Target  }
     aTemp[4] := {'_Flag2'   ,MySync->Flag2+1 }
     aTemp[5] := {'_LetoPath',MySync->LetoPath}
     aTemp[6] := {'_Group'   ,MySync->Group   }
     cTitle   := [Properties']
  Endif
  *
  FV3_OpenModal(cTitle)
  FV3_APutValues(aTemp)
  *
  FV3_Label(''     ,50)
  FV3_CheckBox('_Active',100,'Active')
  FV3_Label('Group',50)
  FV3_ComboBox('_Group',40,100,aGroup)
  FV3_SkipRow(30)
  *
  FV3_Label('Origin'     ,50)
  FV3_TextBox('_Origin'  ,400)
  FV3_Button('...',25,25,{|| Get_Folders(1) })
  *
  FV3_SkipRow(30)
  FV3_Label('Target'     ,50)
  FV3_TextBox('_Target'  ,400)
  FV3_Button('...',25,25,{|| Get_Folders(2) })
  *
  FV3_SkipRow(30)
  FV3_Label('LetoPath'   ,50)
  FV3_TextBox('_LetoPath',400)
  FV3_Button('...',25,25,{|| Get_Path() })
  *
  If !l2
     FV3_SkipRow(30)
     FV3_Label(''     ,50)
     FV3_RadioGroup('_Flag2',080,{'Incremental','Full','Zip','Leto'},.T.,25,{.F.,.F.,.F.,.F.})
  Endif
  *
  FV3_Show(2)
  *
  If FV3_Result()
     IF lNew
        Mysync->(dbappend())
     Endif
     Replace MySync->Active with FV3_GetValue('_Active')
     If !l2
        Replace MySync->Origin   with FV3_GetValue('_Origin')
        Replace MySync->Target   with FV3_GetValue('_Target')
        Replace MySync->Flag2    with FV3_GetValue('_Flag2')-1
        Replace MySync->LetoPath with FV3_GetValue('_LetoPath')
        Replace MySync->Group    with aGroup[FV3_GetValue('_Group')]
        If MySync->Flag2  == 2
           Replace MySync->Target with workdir()+'ZIP'
        Endif
        If MySync->Flag2 != 3 .and. !Empty(MySync->LetoPath)
           Replace MySync->LetoPath with ''
        Endif
     else
        *
        c1 := FV3_GetValue('_Origin')
        c2 := FV3_GetValue('_Target')
        a1 := Directory(c1+'\','D')
        *
        For i := 1 To Len(a1)
           *
           If left(a1[i,1],1)  != '.'
              dbappend()
              Replace Field->Origin with c1+'\'+a1[i,1]
              Replace Field->Target with c2+'\'+a1[i,1]
           Endif
           *
        Next
     Endif
     ReFreshBrowse1()
  Endif
  *
Return
*
Static Procedure Browse1PostInit(cWin)
  *
  DEFINE MAIN MENU OF &cWin
     POPUP 'Options'
        ITEM "Group Activation"              ACTION {|| GroupActivation(cWin) }
        SEPARATOR
        ITEM "Clone Record"                  ACTION {|| Duplica(cWin) }
        SEPARATOR
        ITEM "ZIP Folder"                    ACTION {|| CartellaZip()}
     END POPUP
  END MENU
  *
Return
*
Procedure Get_Folders(Opz)
  Local cFolder
  *
  cFolder := GetFolder(If(Opz==1,'Origin','Target'))
  *
  If empty(cFolder)
     Return
  Endif
  *
  If Opz == 1
     FV3_SetProperty('_Origin','Value',cFolder)
  else
     FV3_SetProperty('_Target','Value',cFolder)
  Endif
  *
Return
*
Procedure DeleteRecord()
  LOCAL nRec1
  LOCAL nRec2
  *
  MySync->(dbgoto(FV3_GetProperty('Browse1','Value')))
  *
  If MsgYesNo('Sure Confirm delete?','Alert!')
     *EliminaRecord()
     *
     nRec1 := RECNO()
     DBSKIP(-1)
     IF !BOF()
        nRec2 := RECNO()
     ELSE
        nRec2 := 0
     ENDIF
     DBGOTO(nRec1)
     IF DBRLOCK()
        DBDELETE()
        DBUNLOCK()
     ENDIF
     DBGOBOTTOM()
     IF nRec2 > 0
        DBGOTO(nRec2)
     ENDIF
     *
     RefreshBrowse1()
  Endif
  *
Return
*
Procedure Invert()
  LOCAL c1
  LOCAL c2
  LOCAL c3
  LOCAL c4
  LOCAL n5
  *
  MySync->(dbgoto(FV3_GetProperty('Browse1','Value')))
  *
  IF Empty(Field->Origin) .and. Empty(Field->Target)
     Return
  Endif
  *
  c1 := Field->Target
  c2 := Field->Origin
  c3 := Field->Group
  c4 := Field->LetoPath
  n5 := Field->Flag2
  *
  IF MsgYesNo([Origin => ]+c1+CHR(10)+[Target => ]+c2+CHR(10)+[Duplicate and Reverse registration?],'Alert!')
     *
     dbAppend()
     replace Field->Target   with c2
     replace Field->Origin   with c1
     replace Field->Group    with c3
     replace Field->LetoPath with c4
     replace Field->Flag2    with n5
     *
     RefreshBrowse1()
  Endif
  *
Return
*
Procedure RefreshBrowse1()
  *
  FV3_SetRecno('BROWSE1',MySync->(Recno()))
  FV3_DoMethod('BROWSE1','Refresh')
  *
Return
*
Procedure SortDbf()
  *
  __dbPack()
  SORT TO ".\DB\_MySync.dbf" ON "Origin"
  __dbZap()
  Append From ".\DB\_MySync.dbf"
  FErase(WorkDir()+".\DB\_MySync.dbf")
  *
  dbgotop()
  RefreshBrowse1()
  *
Return
*
Procedure All_ON_Dbf()
  *
  dbgotop()
  do while !Eof()
     Replace Field->Active with .T.
     dbskip()
  enddo
  *
  dbgotop()
  RefreshBrowse1()
  *
Return
*
Procedure All_OFF_Dbf()
  *
  dbgotop()
  do while !Eof()
     Replace Field->Active with .F.
     dbskip()
  enddo
  *
  dbgotop()
  RefreshBrowse1()
  *
Return
*
Procedure Get_Path()
  Local i
  Local aTemp
  *
  If !File('.\DB\MyIp.Txt')
     hb_MemoWrit('.\DB\MyIp.Txt','//192.168.1.100:2812/')
  Endif
  *
  aTemp := hb_ATokens(hb_MemoRead('.\DB\MyIp.Txt'),CRLF)
  *
  i := Mychoice(350,210,aTemp,'List',1)
  *
  If i > 0
     FV3_SetProperty('_LetoPath','Value',Trim(aTemp[i]))
     FV3_DoMethod('_LetoPath','Refresh')
  Endif
  *
Return
*
Procedure Turn_Off_OnChange(cWin,cName)
  Local lSel := GetProperty(cWin,cName,'Value')
  Local c1
  *
  If lSel
     xOff := .T.
     c1 := '1'
  else
     xOff := .F.
     c1 := '0'
  endif
  *
  Put_Ini('.\DB\CFG.INI','Setup','Off',c1)
  *
Return
*
Procedure Check1_OnChange(cWin,cName)
  Local lSel := GetProperty(cWin,cName,'Value')
  Local c1
  *
  If lSel
     xFolders := .T.
     c1 := '1'
  else
     xFolders := .F.
     c1 := '0'
  endif
  *
  Put_Ini('.\DB\CFG.INI','Setup','Folders',c1)
  *
Return
*
Procedure Check2_OnChange(cWin,cName)
  Local lSel := GetProperty(cWin,cName,'Value')
  Local c1
  *
  If lSel
     xFiles := .T.
     c1 := '1'
  else
     xFiles := .F.
     c1 := '0'
  endif
  *
  Put_Ini('.\DB\CFG.INI','Setup','Files',c1)
  *
Return
*
Procedure LetoCopyFromLeto( src, dst )
  Local dDate := Leto_FileTime(src,,,2)
  Local cTime := Leto_FileTime(src,,,4)
  Local nSize := Leto_FileSize(src)
  Local c1
  *
  c1 := Substr(src,Rat('\',src)+1)
  If nSize > 5700*8
     CopyFromServer(dst,src,c1)
  else
     Leto_FCopyFromSrv(dst,src)
  endif
  *
  hb_FSetDateTime(dst ,dDate, cTime )
  *
Return
*
*************************************
*
/***
*
*  Occurs( <cSearch>, <cTarget> ) --> nCount
*
*  Determine the number of times <cSearch> is found in <cTarget>
*
*/
FUNCTION Occurs( cSearch, cTarget )
  LOCAL nPos
  LOCAL nCount := 0
  DO WHILE !EMPTY( cTarget )
     IF ( nPos := AT( cSearch, cTarget )) != 0
        nCount++
        cTarget := SUBSTR( cTarget, nPos + 1 )
     ELSE
        * End of string
        cTarget := ""
     ENDIF
  ENDDO
RETURN ( nCount )
*
Function GetType()
Return  aType[Field->Flag2+1]
*
Procedure LetoCopyToLeto( src, dst )
  Local dDate,cTime,nSize
  *
  HB_FGETDATETIME( src , @dDate, @cTime  )
  *
  nSize := Len(hb_MemoRead(src))
  *
  Leto_FCopyToSrv(src,dst)
  dDate := Leto_FileTime(src,,,2)
  cTime := Leto_FileTime(src,,,4)
  nSize := Leto_FileSize(src)
  *
Return
*
Procedure Duplica()
  Local aRay := {}
  Local i
  *
  MySync->(dbgoto(FV3_GetProperty('Browse1','Value')))
  *
  For i := 1 To MySync->(Fcount())
     aadd(aRay,FieldGet(i))
  Next
  *
  Select MySync
  MySync->(dbappend())
  For i := 1 To MySync->(Fcount())
     MySync->(FieldPut(i,aRay[i]))
  Next
  MySync->(dbgoto(Recno()))
  *
  RefreshBrowse1()
  *
Return
*
Procedure GroupActivation()
  Local Scelta,i
  Local aTemp := {}
  Local a1    := {}
  Local aGroup := {'A','B','C','D','E','F','G','H','K','J','I'}
  *
  For i := 1 To Len(aGroup)
     aadd(aTemp,'Group Activation '+aGroup[i])
  Next
  *
  Scelta := Mychoice(250,160,aTemp,'Group Activation',1)
  *
  If Scelta > 0
     *
     MySync->(dbgotop())
     Do while MySync->(!eof())
        If MySync->Group == aGroup[Scelta]
           Replace MySync->Active with .T.
        Endif
        MySync->(dbskip())
     Enddo
     MySync->(dbgotop())
     MySync->(dbseek(aGroup[Scelta]))
     RefreshBrowse1()
     *
  Endif
  *
Return
*
Procedure Zippy(cOrigin,cTarget)
  Local cName,cNum,cFile,cExt
  *
  cExt := '.ZIP'
  *
  cOrigin := Trim(cOrigin)
  cName   := SubStr(cOrigin,RAt('\',cOrigin)+1)
  cNum    := '_'+DToS(Date())+'_'+StrZero(Seconds(),5)
  cTarget := Trim(cTarget)+'\'
  *
  cFile := cTarget+cName+cNum+cExt
  *
  *eval(abFunctions[nType],cFile,cOrigin)
  ZipWithHbZipFile(cFile,cOrigin)
  *
  *Pack_Zips(cName,nLimit,cExt)
  *Fill_List_2()
  *
Return
*
Procedure ZipWithHBZipFile(cZip,cFolder)
  Local aFiles
  *
  aFiles := Scandir(cFolder,{'.ZIP'},'A')
  *
  Out_List_1(cZip)
  Out_List_1('........Wait for........')
  *
  HB_ZipFile(cZip, aFiles, 8,nil,.T.,nil,.T.,nil,nil)
  *[ <lSuccess> := ] hb_ZipFile( <zipfile> , <afiles> , <level> , <block> , <.ovr.> , <password> , <.srp.> , , <fileblock> )
  Out_List_1('........OK! Done......')
  execute file '.\ZIP'
  *
Return
*
Procedure CartellaZip()
  execute file '.\ZIP'
Return
*
*
Procedure CopyFileOK( src, dst )
  Local dDate,cTime
  *
  IF !('\' $ src)
     src := SET(_SET_DEFAULT) + '\' + src
  ENDIF
  IF !('\' $ dst)
     dst := SET(_SET_DEFAULT) + '\' + dst
  ENDIF
  *
  HB_FGETDATETIME( src , @dDate, @cTime  )
  *
  If Len(Dst) > 255
     hb_vfCopyFile(src,dst)
  else
     HB_FCopy( src, dst)
  endif
  hb_FSetDateTime( dst , @dDate, @cTime )
  *do Events
  *
Return
*
*
*************************************
/*
Static FUNCTION  MyDrives()
  LOCAL a1 := {'C','D','E','F','G','H','I','J','K',;
  'L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
  LOCAL c2
  Local a2 := {}
  *
  For i := 1 To len(a1)
     If IsDisk(a1[i])
        aadd(a2,a1[i]+':')
     Endif
  next
  *
RETURN a2
*
*************************************
*
Static FUNCTION TimeAsString( nSeconds )
  Local cRet
  *
  cRet := StrZero(INT(Mod(nSeconds / 3600, 24)), 2, 0) + ":" +;
  StrZero(INT(Mod(nSeconds / 60, 60)), 2, 0) + ":" +;
  StrZero(INT(Mod(nSeconds, 60)), 2, 0)
  *
Return cRet
*/
Static PROCEDURE Deleteall()
  *
  If MsgYesNo('Sure Confirm delete all?','Alert!')
     __dbzap()
     RefreshBrowse1()
  Endif
  *
Return
*
Static Procedure Leto_Scandir3(cDir,aRay,aPath)
  LOCAL i
  LOCAL a1
  LOCAL a2
  LOCAL nLen
  LOCAL c1
  *
  nLen := Len(cDir)+1
  *
  a1 := Leto_ReadDir3({cDir+'\'},aRay,nLen)
  FOR i := 1 TO Len(a1)
     c1 := SubStr(a1[i],nLen)
     c1 := Left(c1,Len(c1)-1)
     AAdd(aPath,c1)
  NEXT
  *
  DO WHILE .T.
     a2 := Leto_ReadDir3(a1,aRay,nLen)
     IF Empty(a2)
        EXIT
     ENDIF
     a1 := AClone(a2)
     FOR i := 1 TO Len(a1)
        c1 := SubStr(a1[i],nLen)
        c1 := Left(c1,Len(c1)-1)
        AAdd(aPath,c1)
     NEXT
  ENDDO
  *
RETURN
*
*************************************
*
STATIC FUNCTION Leto_ReadDir3(a,aRay,nLen)
  LOCAL i
  LOCAL j
  LOCAL aDirTmp
  LOCAL aFiles
  *
  aDirTmp := {}
  FOR j := 1 TO Len(a)
     aFiles := Leto_Directory(a[j]+'','DH')
     FOR i := 1 TO Len(aFiles)
        IF 'D' $ aFiles[i,F_ATTR].and. Left(aFiles[i,F_NAME],1) != '.'
           AAdd(aDirTmp,a[j]+aFiles[i,F_NAME]+'\')
        ELSEIF Left(aFiles[i,F_NAME],1) != '.'
           *
           IF aFiles[i,F_SIZE] > 0
              AAdd(aRay,{;
              SubStr(a[j]+aFiles[i,F_NAME],nLen),;
              aFiles[i,F_SIZE],;
              Val(DToS(aFiles[i,F_DATE])),;
              Secs(aFiles[i,F_TIME]),;
              FALSE,;
              Val(DToS(aFiles[i,F_DATE])+StrZero(Secs(aFiles[i,F_TIME]),5))})
           Endif
           *
        ENDIF
     NEXT
  NEXT
  *
RETURN aDirTmp
*
Static Procedure Scandir3(cDir,aRay,aPath)
  LOCAL i
  LOCAL a1
  LOCAL a2
  LOCAL nLen
  LOCAL c1
  *
  nLen := Len(cDir)+1
  *
  a1 := ReadDir3({cDir+'\'},aRay,nLen)
  FOR i := 1 TO Len(a1)
     c1 := SubStr(a1[i],nLen)
     c1 := Left(c1,Len(c1)-1)
     AAdd(aPath,c1)
  NEXT
  *
  DO WHILE .T.
     a2 := ReadDir3(a1,aRay,nLen)
     IF Empty(a2)
        EXIT
     ENDIF
     a1 := AClone(a2)
     FOR i := 1 TO Len(a1)
        c1 := SubStr(a1[i],nLen)
        c1 := Left(c1,Len(c1)-1)
        AAdd(aPath,c1)
     NEXT
  ENDDO
  *
RETURN
*
*************************************
*
STATIC FUNCTION ReadDir3(a,aRay,nLen)
  LOCAL i
  LOCAL j
  LOCAL aDirTmp
  LOCAL aFiles
  *
  aDirTmp := {}
  FOR j := 1 TO Len(a)
     aFiles := Directory(a[j]+'','DH')
     FOR i := 1 TO Len(aFiles)
        IF 'D' $ aFiles[i,F_ATTR].and. Left(aFiles[i,F_NAME],1) != '.'
           AAdd(aDirTmp,a[j]+aFiles[i,F_NAME]+'\')
        ELSEIF Left(aFiles[i,F_NAME],1) != '.'
           *
           IF aFiles[i,F_SIZE] > 0
              AAdd(aRay,{;
              SubStr(a[j]+aFiles[i,F_NAME],nLen),;
              aFiles[i,F_SIZE],;
              Val(DToS(aFiles[i,F_DATE])),;
              Secs(aFiles[i,F_TIME]),;
              FALSE,;
              Val(DToS(aFiles[i,F_DATE])+StrZero(Secs(aFiles[i,F_TIME]),5))})
           Endif
           *
        ENDIF
     NEXT
  NEXT
  *
RETURN aDirTmp
*
Procedure SaveFiles(cOrigin,cTarget,lForce,lFolders,lFiles)
  LOCAL aFolders1
  LOCAL aFolders2
  LOCAL i
  LOCAL n
  LOCAL j
  LOCAL aChange
  LOCAL a6
  LOCAL aNew
  LOCAL Tot1
  LOCAL Tot2
  LOCAL nDiskFree
  LOCAL aSourge
  LOCAL aTarget
  LOCAL nPos
  LOCAL lChange
  Local Time1   := Time()
  Local bLock1  := {|_a| CopyFileOK(_a[1],_a[2]) }
  Local bLock2  := {|_a| File(_a) }
  Local bLock3  := {|  | Ferror() }
  *
  Hb_Default(@lForce,.F.)
  *
  Out_List_1('')
  Out_List_1('TYPE BACKUP '+if(lForce,'FULL','INCREMENTAL')+'  -  #'+Procname(0)+'#')
  Out_List_1('**********************************************')
  Out_List_1('Today.............: '+DToC(date())+' Time '+Time())
  Out_List_1('Folder Origin.....: '+cOrigin)
  Out_List_1('Folder Target.....: '+cTarget)
  Out_List_1('**********************************************')
  *
  aSourge     := {}
  aTarget     := {}
  Tot1        := 0
  Tot2        := 0
  aChange          := {}
  a6          := {}
  aNew          := {}
  aFolders1   := {}
  aFolders2   := {}
  nDiskFree   := HB_DiskSpace(Left(cTarget,2))
  *
  FV3_SetProperty('TEXT2','Value',[..........Wait..........])
  *
  Out_List_1('Wait...data reading.......')
  *
  Scandir3(cOrigin,ASourge,aFolders1)
  Scandir3(cTarget,aTarget,aFolders2)
  *
  If Empty(aSourge)
     lFolders := .F.
     lFiles   := .F.
     Out_List_1('')
     Out_List_1('Warning!!! Check data origin.......')
     Out_List_1('')
  Endif
  *
  FOR i := 1 TO Len(aFolders1)
     MakeDir(cTarget+aFolders1[i])
  NEXT
  *
  ******************************************************************
  Out_List_1('Check update on folder '+cTarget)
  *
  PBar2(0,Len(aSourge))
  *
  FOR i := 1 TO Len(aSourge)
     *
     If chr(126) $ aSourge[i,_NAME]
        Loop
     Endif
     *
     PBar2(i)
     *
     Tot2 += aSourge[i,_SIZE]
     nPos := AScan(aTarget,{|_a| Upper(_a[1]) == Upper(aSourge[i,_NAME]) })
     IF nPos == 0
        AAdd(aNew,{cOrigin+aSourge[i,1],cTarget+aSourge[i,1]})
        Tot1 += aSourge[i,_SIZE]
     ELSE
        aTarget[nPos,5] := .T.
        *
        lChange := .F.
        IF aSourge[i,2] == aTarget[nPos,2]
           IF aSourge[i,6] > aTarget[nPos,6]
              lChange := .T.
           Endif
        elseIF aSourge[i,2] != aTarget[nPos,2]
           lChange := .T.
        ENDIF
        IF lForce
           lChange := .T.
        ENDIF
        *
        IF lChange
           AAdd(aChange,{cOrigin+aSourge[i,_NAME],cTarget+aTarget[nPos,_NAME]})
        ENDIF
        AKill(aTarget,nPos)
     ENDIF
  NEXT
  *
  Out_List_1('OK! Done......')
  *
  PBar2(0)
  *
  IF lFiles
     Out_List_1([Delete files that no longer........])
     n := 0
     FOR i := 1 TO Len(aTarget)
        IF !aTarget[i,5]
           IF File(cTarget+aTarget[i,1])
              ++n
              Out_List_1(cTarget+aTarget[i,1])
              FErase(cTarget+aTarget[i,1])
           ENDIF
        ENDIF
     NEXT
     If n == 0
        Out_List_1('Nothing')
     Endif
  ENDIF
  *
  IF lFolders
     Out_List_1([Delete folders that non longer.....])
     For i := 1 To Len(aFolders2)
        AAdd(a6,{aFolders2[i],Occurs('\',aFolders2[i])})
     Next
     ASort(a6,,,{|x,y| x[2] < y[2] })
     *
     j := 0
     n := 0
     PBar2(0,Len(a6))
     FOR i := Len(a6) TO 1 STEP -1
        PBar2(++j)
        nPos := ascan(aFolders1,{|_a| _a == a6[i,1] })
        If nPos == 0
           IF hb_DirDelete(cTarget+a6[i,1]) == 0
              ++n
              Out_List_1(cTarget+a6[i,1])
           ENDIF
        Endif
     Next
     *
     If n == 0
        Out_List_1('Nothing')
     Endif
  ENDIF
  *
  WriteFiles(aChange,aNew,bLock1,bLock2,Time1,cTarget,bLock3)
  *
  FV3_SetProperty('TEXT2','Value',[])
  PBar2(0)
  PBar3(0)
  *
RETURN
*
Procedure SaveFilesFromLeto(cOrigin,cTarget,lForce,lFolders,lFiles,cDrive)
  LOCAL aFolders1
  LOCAL aFolders2
  LOCAL aSourgeA
  LOCAL aTargetA
  LOCAL i
  LOCAL j
  LOCAL aChange                                     // files changed
  LOCAL a6                                          // folders deleted
  LOCAL aNew                                        // new files
  LOCAL Tot1                                        // bytes files
  LOCAL Tot2                                        // diskspace
  LOCAL nDiskFree
  LOCAL nPos
  LOCAL lChange
  Local n
  Local Time1
  Local PathLeto
  Local bLock1  := {|_a| LetoCopyFromLeto(_a[1],_a[2]) }
  Local bLock2  := {|_a| File(_a) }
  Local bLock3  := {|  | Ferror() }
  *
  hb_Default(@lForce,.F.)
  *
  PathLeto := Trim(FV3_GetProperty('ORIGIN','Value'))
  Time1    := Time()
  *
  Out_List_1('')
  Out_List_1('TYPE BACKUP '+if(lForce,'FULL','INCREMENTAL')+'  -  #'+Procname(0)+'#')
  Out_List_1('**********************************************')
  Out_List_1('Today.............: '+DToC(date())+' Time '+Time1)
  Out_List_1('Folder Origin.....: '+PathLeto+cOrigin)
  Out_List_1('Folder Target.....: '+cDrive+cTarget)
  Out_List_1('**********************************************')
  *
  aFolders1   := {}
  aFolders2   := {}
  aSourgeA    := {}
  aTargetA    := {}
  Tot1        := 0
  Tot2        := 0
  aChange          := {}
  a6          := {}
  aNew          := {}
  nDiskFree   := HB_DiskSpace(cDrive)
  *
  Out_List_1('Wait....Data Reading.......')
  *
  FV3_SetProperty('TEXT2','Value',[..........Wait..........])
  *
  Leto_Scandir3(cOrigin,ASourgeA,aFolders1)
  Scandir3(cDrive+cTarget,aTargetA,aFolders2)
  *
  FV3_SetProperty('TEXT2','Value','')
  If Empty(aSourgeA)
     lFolders := .F.
     lFiles   := .F.
     Out_List_1('')
     Out_List_1('Warning!!! Check data origin.......')
     Out_List_1('')
  Endif
  *
  FOR i := 1 TO Len(aFolders1)
     MakeDir(cDrive+cTarget+aFolders1[i])
  Next
  *For i := 1 To 10
  *Msginfo(aTargetA[i,1])
  *Next
  *
  Out_List_1('Check update on folder '+cDrive+cTarget)
  Out_List_1('Wait...........')
  *
  PBar2(0,Len(aSourgeA))
  *
  FOR i := 1 TO Len(aSourgeA)
     *
     If chr(126) $ aSourgeA[i,_NAME]
        Loop
     Endif
     *
     PBar2(i)
     *
     Tot2 += aSourgeA[i,_SIZE]
     *
     nPos := AScan(aTargetA,{|_a| Trim(Upper(_a[1])) == Trim(Upper(aSourgeA[i,_NAME])) })
     IF nPos == 0
        AAdd(aNew,{cOrigin+aSourgeA[i,_NAME],cDrive+cTarget+aSourgeA[i,_NAME]})
        Tot1 += aSourgeA[i,_SIZE]
     ELSE
        aTargetA[nPos,5] := .T.
        *
        lChange := .F.
        IF aSourgeA[i,2] == aTargetA[nPos,2]
           IF aSourgeA[i,6] > aTargetA[nPos,6]
              lChange := .T.
           Endif
        elseIF aSourgeA[i,2] != aTargetA[nPos,2]
           lChange := .T.
        ENDIF
        IF lForce
           lChange := .T.
        ENDIF
        *
        IF lChange
           AAdd(aChange,{cOrigin+aSourgeA[i,_NAME],cDrive+cTarget+aTargetA[nPos,_NAME]})
        ENDIF
        aKill(aTargetA,nPos)
     ENDIF
  NEXT
  *
  PBar2(0)
  *
  IF lFiles
     Out_List_1([Delete files that on longer.......])
     n := 0
     FOR i := 1 TO Len(aTargetA)
        IF !aTargetA[i,5]
           IF File(cDrive+cTarget+aTargetA[i,1])
              ++n
              Out_List_1(cDrive+cTarget+aTargetA[i,1])
              FErase(cDrive+cTarget+aTargetA[i,1])
           ENDIF
        ENDIF
     NEXT
     If n == 0
        Out_List_1('Nothing')
     Endif
  ENDIF
  *
  IF lFolders
     Out_List_1([Delete folders that on longer.....])
     For i := 1 To Len(aFolders2)
        AAdd(a6,{aFolders2[i],Occurs('\',aFolders2[i])})
     Next
     ASort(a6,,,{|x,y| x[2] < y[2] })
     *
     j := 0
     n := 0
     PBar2(0,Len(a6))
     FOR i := Len(a6) TO 1 STEP -1
        PBar2(++j)
        nPos := ascan(aFolders1,{|_a| _a == a6[i,1] })
        If nPos == 0
           IF hb_DirDelete(cDrive+cTarget+a6[i,1]) == 0
              ++n
              Out_List_1(cDrive+cTarget+a6[i,1])
           ENDIF
        Endif
     Next
     *
     If n == 0
        Out_List_1('Nothing')
     Endif
  ENDIF
  *
  WriteFiles(aChange,aNew,bLock1,bLock2,Time1,cTarget,bLock3)
  *
  FV3_SetProperty('TEXT2','Value',[])
  PBar2(0)
  PBar3(0)
  *
RETURN
*
Procedure SaveFilesToLeto(cOrigin,cTarget,lForce,lFolders,lFiles,cDrive)
  LOCAL aFolders1
  LOCAL aFolders2
  LOCAL aSourgeA
  LOCAL aTargetA
  LOCAL i
  LOCAL j
  LOCAL aChange                                     // files changed
  LOCAL a6                                          // folders deleted
  LOCAL aNew                                        // new files
  LOCAL Tot1                                        // bytes files
  LOCAL Tot2                                        // diskspace
  LOCAL nPos
  LOCAL lChange
  Local n
  Local Time1
  Local bLock1  := {|_a| LetoCopyToLeto(_a[1],_a[2]) }
  Local bLock2  := {|_a| Leto_File(_a) }
  Local bLock3  := {|  | Leto_Ferror() }
  *
  hb_Default(@lForce,.F.)
  *
  Time1    := Time()
  *
  Out_List_1('')
  Out_List_1('TYPE BACKUP '+if(lForce,'FULL','INCREMENTAL')+'  -  #'+Procname(0)+'#')
  Out_List_1('**********************************************')
  Out_List_1('Today................: '+DToC(date())+' Time '+Time1)
  Out_List_1('Folder Origin........: '+cDrive+cOrigin)
  Out_List_1('Folder Target........: '+M->LetoPath+cTarget)
  Out_List_1('**********************************************')
  *
  aFolders1   := {}
  aFolders2   := {}
  aSourgeA    := {}
  aTargetA    := {}
  Tot1        := 0
  Tot2        := 0
  aChange          := {}
  a6          := {}
  aNew          := {}
  *
  Out_List_1('Wait data reading.......')
  *
  FV3_SetProperty('TEXT2','Value',[..........Wait..........])
  *
  Scandir3(cDrive+cOrigin,aSourgeA,aFolders1)
  Leto_Scandir3(cTarget,ATargetA,aFolders2)
  *
  FV3_SetProperty('TEXT2','Value','')
  *
  FOR i := 1 TO Len(aFolders1)
     Leto_MakeDir(cTarget+aFolders1[i])
  Next
  *
  If Empty(aSourgeA)
     lFolders := .F.
     lFiles   := .F.
     Out_List_1('')
     Out_List_1('Warning!!! Check data origin.......')
     Out_List_1('')
  Endif
  *
  Out_List_1('Check update on folder '+M->LetoPath+cTarget)
  Out_List_1('Wait..........')
  *
  PBar2(0,Len(aSourgeA))
  *
  FOR i := 1 TO Len(aSourgeA)
     *
     If chr(126) $ aSourgeA[i,_NAME]
        Loop
     Endif
     *
     PBar2(i)
     *
     Tot2 += aSourgeA[i,_SIZE]
     *
     nPos := AScan(aTargetA,{|_a| Trim(Upper(_a[1])) == Trim(Upper(aSourgeA[i,_NAME])) })
     IF nPos == 0
        AAdd(aNew,{cDrive+cOrigin+aSourgeA[i,_NAME],cTarget+aSourgeA[i,_NAME]})
        Tot1 += aSourgeA[i,_SIZE]
     ELSE
        aTargetA[nPos,5] := .T.
        *
        lChange := .F.
        IF aSourgeA[i,2] == aTargetA[nPos,2]
           IF aSourgeA[i,6] > aTargetA[nPos,6]
              lChange := .T.
           Endif
        elseIF aSourgeA[i,2] != aTargetA[nPos,2]
           lChange := .T.
        ENDIF
        IF lForce
           lChange := .T.
        ENDIF
        *
        IF lChange
           AAdd(aChange,{cDrive+cOrigin+aSourgeA[i,_NAME],cTarget+aTargetA[nPos,_NAME]})
        ENDIF
        aKill(aTargetA,nPos)
     ENDIF
  NEXT
  *
  PBar2(0)
  *
  IF lFiles
     Out_List_1([Delete files that on longer.......])
     n := 0
     FOR i := 1 TO Len(aTargetA)
        IF !aTargetA[i,5]
           IF Leto_File(cTarget+aTargetA[i,1])
              ++n
              Out_List_1(cTarget+aTargetA[i,1])
              Leto_FErase(cTarget+aTargetA[i,1])
           ENDIF
        ENDIF
     NEXT
     If n == 0
        Out_List_1('Nothing')
     Endif
  ENDIF
  *
  IF lFolders
     Out_List_1([Delete folders that on longer.....])
     For i := 1 To Len(aFolders2)
        AAdd(a6,{aFolders2[i],Occurs('\',aFolders2[i])})
     Next
     ASort(a6,,,{|x,y| x[2] < y[2] })
     *
     j := 0
     n := 0
     PBar2(0,Len(a6))
     FOR i := Len(a6) TO 1 STEP -1
        PBar2(++j)
        nPos := ascan(aFolders1,{|_a| _a == a6[i,1] })
        If nPos == 0
           IF Leto_DirRemove(cTarget+a6[i,1]) != -1
              ++n
              Out_List_1(cTarget+a6[i,1])
           ENDIF
        Endif
     Next
     *
     If n == 0
        Out_List_1('Nothing')
     Endif
  ENDIF
  *
  WriteFiles(aChange,aNew,bLock1,bLock2,Time1,cTarget)
  *
  FV3_SetProperty('TEXT2','Value',[])
  PBar2(0)
  PBar3(0)
  *
RETURN
*
Procedure WriteFiles(aChange,aNew,bLock1,bLock2,Time1,cTarget,Block3)
  Local aChangeb         := {}
  Local aNewb         := {}
  Local a8          := {}
  Local a9          := {}
  Local i
  Local Time2
  *
  IF Empty(aChange) .and. Empty(aNew)
     Out_List_1('')
     Out_List_1('No data update on folder '+cTarget)
     Out_List_1('')
     Time2   := Time()
     Out_List_1('Today '+DToC(date())+' Elapsed Time '+ElapTime(Time1,Time2)+' - '+'Folder: '+cTarget)
     Out_List_1('')
  ELSE
     IF !Empty(aNew)
        Out_List_1('Copy new files')
        PBar2(0,Len(aNew))
        FOR i := 1 TO Len(aNew)
           Out_List_1('copy '+aNew[i,2])
           PBar2(i)
           eval(bLock1,aNew[i])
           IF Eval(bLock2,aNew[i,2])
              Out_List_1('OK!')
           ELSE
              AAdd(aNewb,aNew[i,2])
              Out_List_1('error! '+ntrim(eval(bLock3)))
           ENDIF
        NEXT
        PBar2(0)
        Out_List_1('**********New files NOT Copied**********')
        IF !Empty(aNewb)
           FOR i := 1 TO Len(aNewb)
              Out_List_1(aNewb[i])
           NEXT
        else
           Out_List_1('Nothing')
        endif
     ENDIF
     *
     IF !Empty(aChange)
        Out_List_1('Copy changed files')
        PBar2(0,Len(aChange))
        FOR i := 1 TO Len(aChange)
           Out_List_1('copy '+aChange[i,2])
           PBar2(i)
           eval(bLock1,aChange[i])
           IF Eval(bLock2,aChange[i,2])
              Out_List_1('OK!')
           ELSE
              AAdd(aChangeb,aChange[i,2])
           ENDIF
        NEXT
        PBar2(0)
        Out_List_1('**********Changed Files NOT Copied**********')
        IF !Empty(aChangeb)
           FOR i := 1 TO Len(aChangeb)
              Out_List_1(aChangeb[i])
           NEXT
        else
           Out_List_1('Nothing')
        endif
     ENDIF
     *
     FOR i := 1 TO Len(aChange)
        IF !Eval(bLock2,aChange[i,2])
           AAdd(a8,{aChange[i,1],aChange[i,2]})
        ENDIF
     NEXT
     FOR i := 1 TO Len(aNew)
        IF !Eval(bLock2,aNew[i,2])
           AAdd(a8,{aNew[i,1],aNew[i,2]})
        ENDIF
     NEXT
     IF Empty(a8)
        Out_List_1('')
        Out_List_1('**********operation completed!**********')
        Out_List_1('')
        Time2   := Time()
        Out_List_1('Today '+DToC(date())+' Elapsed Time '+ElapTime(Time1,Time2)+' - '+'Folder: '+cTarget)
        Out_List_1('')
     ELSE
        FOR i := 1 TO Len(a8)
           eval(bLock1,a8[i])
        NEXT
        FOR i := 1 TO Len(a8)
           IF Eval(bLock2,a8[i,2])
              AAdd(a9,a8[i,2])
           ENDIF
        NEXT
        IF !Empty(a9)
           Out_List_1('******************************************')
           Out_List_1('These files have not been written on: '+cTarget)
           FOR i := 1 TO Len(a9)
              Out_List_1(a9[i])
           NEXT
           Out_List_1('')
           Out_List_1([**********it is advisable repeat!**********])
        Endif
        Out_List_1('')
        Time2   := Time()
        Out_List_1('Today '+DToC(date())+' Elapsed Time '+ElapTime(Time1,Time2)+' - '+'Folder: '+cTarget)
        Out_List_1('')
        *
     ENDIF
  ENDIF
  *
Return
*
Procedure AKill( a, n )
  ASize( ADel( a, n ), Len( a ) - 1 )
Return
*
Function WorkDir()
Return  hb_Curdrive()+':\'+StrTran(CurDir(),'\\','\')+'\'
*
FUNCTION TimeAsSeconds( cTime )
RETURN VAL(cTime) * 3600 + VAL(SUBSTR(cTime, 4)) * 60 + VAL(SUBSTR(cTime, 7))
*
FUNCTION Scandir(cDir,aExclude,cOpz)
  LOCAL a1
  LOCAL a2
  LOCAL cString
  *
  hb_Default(@cOpz,'S')
  *
  IF Right(cDir,1) != '\'
     cDir += '\'
  ENDIF
  *
  IF cOpz == 'A'
     cString := {}
  ELSE
     cString := ''
  ENDIF
  a1    := ReadDir({cDir},@cString,aExclude)
  *
  DO WHILE .T.
     a2 := ReadDir(a1,@cString,aExclude)
     IF Empty(a2)
        EXIT
     ENDIF
     a1 := AClone(a2)
  ENDDO
  *
RETURN cString
*
*************************************
*
STATIC FUNCTION ReadDir(a,cString,aExc)
  LOCAL i
  LOCAL j
  LOCAL aDirTmp
  LOCAL aFiles
  *
  aDirTmp := {}
  FOR j := 1 TO Len(a)
     aFiles := Directory(a[j],'DH')
     FOR i := 1 TO Len(aFiles)
        IF 'D' $ aFiles[i,F_ATTR].and. Left(aFiles[i,F_NAME],1) != '.'
           AAdd(aDirTmp,a[j]+aFiles[i,F_NAME]+'\')
        ELSEIF Left(aFiles[i,F_NAME],1) != '.' .and. AScan(aExc,{|_1| Upper(Right(aFiles[i,F_NAME],Len(_1))) == Upper(_1) }) == 0
           IF ValType(cString) == 'A'
              AAdd(cString,a[j]+aFiles[i,F_NAME])
           ELSE
              cString += a[j]+aFiles[i,F_NAME]+' '
           ENDIF
        ENDIF
     NEXT
  NEXT
  *
RETURN aDirTmp
*
FUNCTION MyChoice(nWidth,nHeight,aRay,cCaption,nValue)
  Local nRet := 0
  *
  hb_Default(@nWidth ,300)
  hb_Default(@nHeight,200)
  hb_Default(@nValue ,  1)
  *
  M->_LSTBOX_ := ''
  *
  FV3_OpenModal(cCaption,nil,{|cWin| SetProperty(cWin,'_LSTBOX_','Value',nValue) })
  FV3_ListBox('_LSTBOX_',nWidth,nHeight,aRay,.F.,{|| FV3_Okay()})
  *
  FV3_SetFont('_LSTBOX_','Courier New',9)
  *
  FV3_Show(2)
  *
  If FV3_Result()
     nRet := M->_LSTBOX_
  Endif
  *
Return nRet
*
Procedure F_Open(cFile)
  Set Alternate To &cFile
  Set Alternate On
Return
*
*************************************
*
Procedure F_Write(c)
  QQout(c+CRLF)
Return
*
*************************************
*
Procedure F_Close()
  Set Alternate Off
Return
*
Procedure Put_Ini(cIni,cSection,cKey,uVar)
  *
  if valtype(uVar) == 'N'
     uVar := ntrim(uVar)
  elseif valtype(uVar) == 'D'
     uVar := dtoc(uVar)
  else
     uVar := trim(uVar)
  endif
  *
  BEGIN INI FILENAME (cIni)
  SET SECTION cSection ENTRY cKey TO uVar
  END INI
  *
Return
*
Function Get_Ini(cIni,cSection,cKey)
  Local uVar
  *
  BEGIN INI FILENAME (cIni)
  GET uVar SECTION cSection ENTRY cKey  DEFAULT ""
  END INI
  *
Return uVar
*
Function  Ini_Get(cSection,cKey,cValue)
  Local uVar
  *
  GET uVar SECTION cSection ENTRY cKey  DEFAULT ""
  *
  if Valtype(cValue) != 'NIL'
     if Valtype(cValue) == 'B'
        uVar := Eval(cValue,uVar)
     elseif cValue == 'N'
        uVar := val(uVar)
     elseif cValue == 'D'
        uVar := ctod(uVar)
     endif
  endif
  *
Return uVar
*
