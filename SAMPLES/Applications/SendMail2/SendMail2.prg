/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2007 Grigory Filatov <gfilatov@gmail.com>
 *
 * Copyright 2022 Pierpaolo Martinello
*/

ANNOUNCE RDDSYS

#include <hmg.ch>
#include <i_Mail.ch>
#include "hbextcdp.ch"
#include <I_Winuser.Ch>

#define UNICODE
REQUEST HB_CODEPAGE_UTF8

Static cIni, aData := {}, aAddress := {}, aSubject := {} , qFile := {}
Static lStop := .F. , init1 := .T. , lSPwd := .F.

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*
   SET CENTERWINDOW RELATIVE PARENT
   SET MULTIPLE OFF WARNING

   HB_cdpSelect("UTF8")

   cIni := GetStartupFolder()+"\MailConfig.ini"

   LOAD WINDOW Main

   Main.PROGRESSBAR_1.Enabled := .f.
   Main.PROGRESSBAR_2.Enabled := .f.
   Main.BUTTONEX_1.Enabled := .f.

   IF !File(cIni) .or. (Main.ROW) + (Main.COL) <= 0
      CENTER WINDOW Main
   EndIF

   Main.TAB_1.SETFOCUS

   ACTIVATE WINDOW Main

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Config
*-----------------------------------------------------------------------------*

   LOAD WINDOW Config

   Config.TEXTBOX_1.Value   := aData[1][1]  // cHost
   Config.TEXTBOX_2.Value   := aData[1][2]  // cPort
   Config.TEXTBOX_3.Value   := aData[1][3]  // cEmail
   Config.TEXTBOX_4.Value   := aData[1][4]  // cPass

   Config.CHECKBOX_1.Value  := aData[2][1]  // lSave
   Config.CHECKBOX_2.Value  := aData[2][2]  // lPosition
   Config.CHECKBOX_3.Value  := aData[2][3]  // lSize
   Config.CHECKBOX_4.Value  := aData[2][4]  // lOnTop
   Config.CHECKBOX_5.Value  := aData[2][5]  // LSort
   Config.CHECKBOX_6.Value  := aData[2][6]  // Usessl
   Config.CHECKBOX_7.Value  := aData[2][7]  // Use Temp For ssl operations
   Config.CHECKBOX_8.Value  := aData[2][8]  // Use only CURL
   Config.CHECKBOX_9.Value  := aData[2][9]  // Use only CDO
   Config.CHECKBOX_10.Value := aData[2][10] // lReceipt

   IF aData[2][4] == .T.
      Main.TopMost := .F.
   EndIF
   Config.TAB_1.SetFocus

   CENTER WINDOW Config
   ACTIVATE WINDOW Config

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure LoadData
*-----------------------------------------------------------------------------*
   LOCAL nI, cInput := "", nsplit,OnlyCurl := .T., OnlyCDO := .F. ,lreceipt := .F.
   LOCAL cHost := "", cPort := "", cEmail := "", cPass := "", usessl := .F.
   LOCAL lSave := .t., lPosition := .t., lSize := .t., lOnTop := .f., lSort := .t.
   LOCAL nLeft := 0, nTop := 0, nWidth := 0, nHeight := 0, Body:= "", usetemp := .F.
   LOCAL aUsed:= 0, sUsed := 0

   BEGIN INI FILE cIni

      GET cHost     SECTION "Config" ENTRY "Host"       Default "mail"

      GET cPort     SECTION "Config" ENTRY "Port"       Default "25"

      GET cEmail    SECTION "Config" ENTRY "Email"      Default ""

      GET cPass     SECTION "Config" ENTRY "Password"   Default ""

      GET lOnTop    SECTION "Config" ENTRY "OnTop"      Default lOnTop

      GET lSave     SECTION "Config" ENTRY "SaveOnExit" Default lSave

      GET lPosition SECTION "Config" ENTRY "Position"   Default lPosition

      GET lSize     SECTION "Config" ENTRY "Size"       Default lSize

      GET lSort     SECTION "Config" ENTRY "Sort"       Default lSort

      GET nLeft     SECTION "Config" ENTRY "Left"       Default nLeft

      GET nTop      SECTION "Config" ENTRY "Top"        Default nTop

      GET nWidth    SECTION "Config" ENTRY "Width"      Default nWidth

      GET nHeight   SECTION "Config" ENTRY "Height"     Default nHeight

      GET UseSSl    SECTION "Config" ENTRY "UseSSL"     Default UseSsl

      GET UseTemp   SECTION "Config" ENTRY "UseTemp"    Default Usetemp

      GET OnlyCurl  SECTION "Config" ENTRY "OnlyCurl"   Default OnlyCurl

      GET OnlyCDO   SECTION "Config" ENTRY "OnlyCDO"    Default OnlyCDO

      GET lReceipt  SECTION "Config" ENTRY "Receipt"    Default lreceipt

      Aadd(aData, {cHost, cPort, cEmail, crypt(cPass,"D") })
      Aadd(aData, {lSave, lPosition, lSize, lOnTop, lSort, UseSsl, UseTemp, Onlycurl, OnlyCdo, lreceipt})

      For nI := 1 To 99
         GET cInput SECTION "Address History" ENTRY hb_ntos(nI) Default ""
         IF !Empty(cInput)
            Aadd(aAddress, cInput)
         ELSE
            Exit
         EndIF
      Next

      GET aUsed  SECTION "Address History" ENTRY "aUsed"  Default aUsed

      For nI := 1 To 99
         GET cInput SECTION "Subject History" ENTRY hb_ntos(nI) Default ""
         IF !Empty(cInput)
            Aadd(aSubject, cInput)
         ELSE
            Exit
         EndIF
      Next

      GET sUsed  SECTION "Subject History" ENTRY "sUsed"  Default sUsed

      ni := 1
      cInput := "*"
      While !empty(cInput)
            GET cInput SECTION "File History" ENTRY hb_ntos(nI) Default ""
            nsplit := at("|" ,cInput)
            IF nsplit > 0
               DoMethod ( "Main", "Grid_1", 'AddItem', {left(cinput, nsplit-2), substr(cinput, nsplit+2) } )
            EndIF
            ni ++
      End

      ni := 1
      cInput := "*"
      While !empty(cInput)
            GET cInput SECTION "BODY" ENTRY hb_ntos(nI) Default ""
            IF ! empty(cinput)
               Body += RemLeft(cInput,"*") + CRLF
            EndIF
            ni ++
      End
      Body := remRight( body,CRLF)

   END INI

   UpdateStatus()

   IF !Empty(nLeft)
      Main.Col := nLeft
   EndIF
   IF !Empty(nTop)
      Main.Row := nTop
   EndIF

   Main.MinWidth := 460
   Main.MinHeight := 300+IF(IsXPThemeActive(), 10, 0)

   IF !Empty(nWidth)
      Main.Width := nWidth
   EndIF

   IF !Empty(nHeight)
      Main.Height := nHeight
   EndIF

   Main.ComboBox_1.DeleteAllItems

   Combo1Upg()
   Main.ComboBox_1.Value := aUsed

   Combo2Upg()
   Main.ComboBox_2.Value := sUsed

   Main.EDITBOX_1.value       := Body
   Main.label_3.visible       := !aData[2][8] .and. !aData[2][9]
   Main.ProgressBar_1.visible := !aData[2][8] .and. !aData[2][9]
   Main.ProgressBar_2.visible := !aData[2][8] .and. !aData[2][9]
   Main.ButtonEx_1.visible    := !aData[2][8] .and. !aData[2][9]

   OnTopMain()
   UpdateToolBtns()

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Combo1Upg()
*-----------------------------------------------------------------------------*
   Main.ComboBox_1.DeleteAllItems
   IF LEN(aAddress) > 0
      aeval(aAddress,{|x|Main.ComboBox_1.AddItem(lower(x))})
   EndIF
   Main.ComboBox_1.Value := Main.ComboBox_1.ItemCount

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Combo2Upg()
*-----------------------------------------------------------------------------*
   Main.ComboBox_2.DeleteAllItems
   IF LEN(aSubject) > 0
      aeval(aSubject,{|x|Main.ComboBox_2.AddItem(x)})
   EndIF
   Main.ComboBox_2.Value := Main.ComboBox_2.ItemCount

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Tadd()
*-----------------------------------------------------------------------------*
   LOCAL pntto := 0 , src4 := LOWER(Main.COMBOBOX_1.DisplayValue)

   IF len(src4) < 1
      return
   ELSEif !( "@" $ src4 )
      MSGEXCLAMATION("Ivalid address!","Error")
      return
   EndIF

   IF ascan(aAddress,src4 ) < 1
      aadd(aAddress,src4)
      ASORT(aAddress, , , { |a,b| a < b } )
      pntto := ascan(aAddress,src4 )
      Main.ComboBox_1.DeleteAllItems
      IF LEN(aAddress) > 0
         aeval(aAddress,{|x|Main.ComboBox_1.AddItem(x)})
         Main.ComboBox_1.value := pntto
      EndIF
   Else
      MessageBoxTimeOut( src4+" is already present !","Warning Input Error",0,2500 )
   EndIF
   UpdateToolBtns()
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Tdel()
*-----------------------------------------------------------------------------*
   LOCAL cS := Main.COMBOBOX_1.DisplayValue
   IF len(cs) > 0
      hb_adel(aAddress,ascan( aAddress,cS ) ,.T.)
      Combo1Upg()
   EndIF
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Sadd()
*-----------------------------------------------------------------------------*
   LOCAL pntto := 0 , src4 := Main.COMBOBOX_2.DisplayValue

   IF len(src4) < 1
      return
   EndIF

   IF ascan(aSubject,src4 ) < 1
      aadd(aSubject,Main.COMBOBOX_2.DisplayValue)
      ASORT(aSubject, , , { |a,b| a < b } )
      pntto := ascan(aSubject,src4 )
      Main.ComboBox_2.DeleteAllItems
      IF LEN(aSubject) > 0
         aeval(aSubject,{|x|Main.ComboBox_2.AddItem(x)})
         Main.ComboBox_2.value := pntto
      EndIF
   Else
      MessageBoxTimeOut( src4+" is already present !","Warning Input Error",0,2500 )
   EndIF
   UpdateToolBtns()
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Sdel()
*-----------------------------------------------------------------------------*
   LOCAL cS := Main.COMBOBOX_2.DisplayValue
   IF len(cs) > 0
      hb_adel(aSubject,ascan( aAddress,cS ) ,.T.)
      Combo2Upg()
   EndIF
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure OnTopMain()
*-----------------------------------------------------------------------------*
   LOCAL cStatus := "Smtp: "+alltrim(aData[1][1])+":"+aData[1][2]+" With: "
   IF aData[2][4] == .T.
      Main.TopMost := .T.
   EndIF
   Main.label_3.visible       := !aData[2][8] .and. !aData[2][9]
   Main.ProgressBar_1.visible := !aData[2][8] .and. !aData[2][9]
   Main.ProgressBar_2.visible := !aData[2][8] .and. !aData[2][9]
   Main.ButtonEx_1.visible    := !aData[2][8] .and. !aData[2][9]

   IF aData[2][6]  // Usessl
      cStatus += "SSL and "
   EndIF
   Do case
      Case aData[2][8]  // Use only CURL
           cStatus += "CURL"

      Case aData[2][9]  // Use only CDO
           cStatus += "CDO"

      Otherwise
           cStatus += "TSMTP"
   EndCAse
   IF adata[2][10]
      cStatus += "+ RECEIPT"
   EndIF
   Main.StatusBar.Item (3)    := cStatus

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure GetItems
*-----------------------------------------------------------------------------*
   LOCAL aFiles := {}
   LOCAL cFile  := GetFile( , , , .t. )

   IF !Empty(cFile)
      IF Valtype(cFile) # "A"
         Aadd(aFiles, cFile)
      ELSE
         aFiles := cFile
      EndIF

      TakeDrop( aFiles )

   EndIF

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure DeleteItem
*-----------------------------------------------------------------------------*
   LOCAL aItem := Main.GRID_1.Value

   IF !Empty(aItem)
      repeat
         Main.Grid_1.DeleteItem( aItem[1] )
         aItem := Main.GRID_1.Value
      until !Empty(aItem)
      UpdateToolBtns()
      UpdateStatus()
   EndIF

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure DeleteAll
*-----------------------------------------------------------------------------*
   IF MsgYesNo( "Are you sure you want to delete the all items?", "Confirm", , , .f. )
      Main.Grid_1.DeleteAllItems
      UpdateToolBtns()
      UpdateStatus()
   EndIF

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure UpdateToolBtns
*-----------------------------------------------------------------------------*
   LOCAL cCombo := Main.COMBOBOX_1.DisplayValue
   LOCAL nItems := Main.GRID_1.ItemCount
   LOCAL aItem  := Main.GRID_1.Value

   Main.MnuSend.Enabled      := !Empty(cCombo)  //.And. !Empty(nItems)
   Main.MnuDelete.Enabled    := !Empty(aItem)  .And. Main.tab_1.value = 2
   Main.MnuDeleteAll.Enabled := !Empty(nItems) .And. Main.tab_1.value = 2

   Main.btnSend.Enabled      := !Empty(cCombo)  //.And. !Empty(nItems)
   Main.btnDelete.Enabled    := !Empty(aItem)  .And. Main.tab_1.value = 2
   Main.btnDeleteAll.Enabled := !Empty(nItems) .And. Main.tab_1.value = 2

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure UpdateStatus
*-----------------------------------------------------------------------------*
   LOCAL nFiles := Main.Grid_1.ItemCount, aFiles := {}
   LOCAL cFiles := "Files: " + Ltrim(Str(nFiles))
   LOCAL nSize := 0, cSize := "Size: ", i

   For i := 1 To nFiles
      nSize += FileSize(Main.Grid_1.Cell(i, 1))
   Next
   cSize += Ltrim( Transform( nSize, "999 999 999 999" ) ) + " b"

   Main.StatusBar.Width(2) := Len(cSize) * 8
   Main.StatusBar.Width(3) := Main.Width - 90 - Len(cSize) * 8
   Main.StatusBar.Item (1) := cFiles
   Main.StatusBar.Item (2) := cSize

   IF aData[2][5] == .t.   //  lSort
      For i := 1 To nFiles
         Aadd(aFiles, {Main.Grid_1.Cell(i, 1), Main.Grid_1.Cell(i, 2)})
      Next

      ASORT(aFiles, , , {|a,b| UPPER(a[1]) < UPPER(b[1])})

      Main.Grid_1.DeleteAllItems
      IF nFiles > 9
         Main.Grid_1.DeleteColumn( 2 )
         Main.Grid_1.DeleteColumn( 1 )
         Main.Grid_1.AddColumn( 1 , "File" , Main.Grid_1.Width - 104 , 0 )
         Main.Grid_1.AddColumn( 2 , "Size" , 82 , 1 )
      EndIF
      Main.Grid_1.DisableUpdate
      For i=1 To nFiles
         DoMethod ( "Main" , "Grid_1" , 'AddItem' , { aFiles[i][1], aFiles[i][2] } )
      Next
      Main.Grid_1.EnableUpdate
   EndIF

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure OnSize (arg1)
*-----------------------------------------------------------------------------*
   LOCAL nFiles := Main.Grid_1.ItemCount, aFiles := {}, i
   Default arg1 to .T.

   Main.PROGRESSBAR_1.Width := Main.Width - 210
   Main.PROGRESSBAR_2.Width := Main.Width - 210
   Main.BUTTONEX_1.Col      := Main.Width - 95
   Main.Tsave.Col           := Main.Width - 45
   Main.Ssave.Col           := Main.Width - 45
   Main.TDel.Col            := Main.Width - 77
   Main.SDel.Col            := Main.Width - 77
   Main.TAdd.Col            := Main.Width - 105
   Main.SAdd.Col            := Main.Width - 105
   Main.Tab_1.Width         := Main.Width - 15
   Main.Tab_1.Height        := Main.Height - 115 - IF(IsXPThemeActive(), 10, 0)
   Main.ComboBox_1.Width    := Main.Width - 168
   Main.ComboBox_2.Width    := Main.Width - 168
   Main.EDITBOX_1.Width     := Main.Width - 26
   Main.EDITBOX_1.Height    := Main.Height - 217 - IF(IsXPThemeActive(), 10, 0)
   Main.Grid_1.Width        := Main.Width - 23
   Main.Grid_1.Height       := Main.Height - 152 - IF(IsXPThemeActive(), 10, 0)

   For i := 1 To nFiles
      Aadd(aFiles, {Main.Grid_1.Cell(i, 1), Main.Grid_1.Cell(i, 2)})
   Next

   Main.Grid_1.DeleteAllItems
   Main.Grid_1.DeleteColumn( 2 )
   Main.Grid_1.DeleteColumn( 1 )
   Main.Grid_1.AddColumn( 1 , "File" , Main.Grid_1.Width - 104 , 0 )
   Main.Grid_1.AddColumn( 2 , "Size" , 82 , 1 )
   Main.Grid_1.DisableUpdate

   For i=1 To nFiles
      DoMethod ( "Main" , "Grid_1" , 'AddItem' , { aFiles[i][1], aFiles[i][2] } )
   Next
   Main.Grid_1.EnableUpdate
   Main.StatusBar.Width(3) := Main.Width - 90 - ( Main.StatusBar.Width(2) )

   IF init1
      init1 := .F.
   Else
     IF arg1
        SaveData (.T.,.T.)
     EndIF
   EndIF
   Main.StatusBar.Item (3) := this.name
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure SaveData( arg1, geo, addr, subj)
*-----------------------------------------------------------------------------*
   LOCAL nI , nd, cInput := '*', tbody
   Default arg1 to .F., geo to .f. , addr to .f. , subj to .f.

   IF aData[2][1] == .t. .or. arg1
      BEGIN INI FILE cIni
            IF geo
               IF aData[2][2] == .t.
                  SET SECTION "Config" ENTRY "Left" TO max(Main.Col,0)
                  SET SECTION "Config" ENTRY "Top" TO max(Main.Row,0)
               EndIF

               IF aData[2][3] == .t.
                  SET SECTION "Config" ENTRY "Width" TO Main.Width
                  SET SECTION "Config" ENTRY "Height" TO Main.Height
               EndIF
            elseif addr = .T.

               Nd := 0
               While !empty(cInput)
                  GET cInput SECTION "Address History" ENTRY hb_ntos(nd+1) Default ""
                  Nd ++
               End
               For nI := 1 To Nd-1
                   DEl SECTION "Address History" ENTRY hb_ntos(nI)
               Next

               For nI := 1 To Len(aAddress)
                   SET SECTION "Address History" ENTRY Ltrim(Str(nI, 2)) TO aAddress[nI]
               Next

               IF Main.ComboBox_1.Value > 0
                  SET SECTION "Address History" ENTRY "aUsed" TO Main.ComboBox_1.value
               EndIF

            elseif Subj = .T.

               cInput:="*"
               Nd := 0
               While !empty(cInput)
                  GET cInput SECTION "Subject History" ENTRY hb_ntos(nd+1) Default ""
                  Nd ++
               End
               For nI := 1 To Nd-1
                  DEl SECTION "Subject History" ENTRY hb_ntos(nI)
               Next

               For nI := 1 To Len(aSubject)
                   SET SECTION "Subject History" ENTRY Ltrim(Str(nI, 2)) TO aSubject[nI]
               Next

               IF Main.ComboBox_2.Value > 0
                  SET SECTION "Subject History" ENTRY "sUsed" TO Main.ComboBox_2.value
               EndIF

            else
               SET SECTION "Config" ENTRY "Host"       TO aData[1][1]

               SET SECTION "Config" ENTRY "Port"       TO aData[1][2]

               SET SECTION "Config" ENTRY "Email"      TO aData[1][3]

               SET SECTION "Config" ENTRY "Password"   TO crypt(aData[1][4])

               SET SECTION "Config" ENTRY "SaveOnExit" TO aData[2][1]

               SET SECTION "Config" ENTRY "Position"   TO aData[2][2]

               SET SECTION "Config" ENTRY "Size"       TO aData[2][3]

               SET SECTION "Config" ENTRY "OnTop"      TO aData[2][4]

               SET SECTION "Config" ENTRY "Sort"       TO aData[2][5]

               SET SECTION "Config" ENTRY "UseSSL"     TO aData[2][6]

               SET SECTION "Config" ENTRY "UseTemp"    TO aData[2][7]

               SET SECTION "Config" ENTRY "OnlyCurl"   TO aData[2][8]

               SET SECTION "Config" ENTRY "OnlyCDO"    TO aData[2][9]

               SET SECTION "Config" ENTRY "Receipt"    TO aData[2][10]

               IF aData[2][2] == .t.
                  SET SECTION "Config" ENTRY "Left" TO max(Main.Col,0)
                  SET SECTION "Config" ENTRY "Top" TO max(Main.Row,0)
               EndIF

               IF aData[2][3] == .t.
                  SET SECTION "Config" ENTRY "Width" TO Main.Width
                  SET SECTION "Config" ENTRY "Height" TO Main.Height
               EndIF

               cInput:="*"
               Nd := 0
               While !empty(cInput)
                  GET cInput SECTION "Address History" ENTRY hb_ntos(nd+1) Default ""
                  Nd ++
               End
               For nI := 1 To Nd-1
                  DEl SECTION "Address History" ENTRY hb_ntos(nI)
               Next

               For nI := 1 To Len(aAddress)
                  SET SECTION "Address History" ENTRY hb_ntos(nI) TO aAddress[nI]
               Next

               IF Main.ComboBox_1.Value > 0
                  SET SECTION "Address History" ENTRY "aUsed" TO Main.ComboBox_1.value
               EndIF

               cInput:="*"
               Nd := 0
               While !empty(cInput)
                  GET cInput SECTION "Subject History" ENTRY hb_ntos(nd+1) Default ""
                  Nd ++
               End
               For nI := 1 To Nd-1
                  DEl SECTION "Subject History" ENTRY hb_ntos(nI)
               Next

               For nI := 1 To Len(aSubject)
                  SET SECTION "Subject History" ENTRY hb_ntos(nI) TO aSubject[nI]
               Next

               IF Main.ComboBox_2.Value > 0
                  SET SECTION "Subject History" ENTRY "sUsed" TO Main.ComboBox_2.value
               EndIF

               // clean body section
               cInput := "*"
               Nd := 0
               While !empty(cInput)
                  GET cInput SECTION "BODY" ENTRY hb_ntos(nd+1) Default ""
                  Nd ++
               End
               For nI := 1 To Nd-1
                  DEl SECTION "BODY" ENTRY hb_ntos(nI)
               Next

               // save Body section
               tbody := hb_atokens(Main.editbox_1.value,CRLF)

               For nI := 1 To IF (empty(atail(tBody)),len(tBody)-1,len(tbody) )
                  SET SECTION "BODY" ENTRY hb_ntos(nI) TO [*]+tBody[nI]
               Next

               // clean File History
               cInput := "*"
               Nd := 0
               While !empty(cInput)
                  GET cInput SECTION "File History" ENTRY hb_ntos(nd+1) Default ""
                  Nd ++
               End
               For nI := 1 To Nd-1
                  DEl SECTION "File History" ENTRY hb_ntos(nI)
               Next

               // save File History
               For nI := 1 To Main.Grid_1.ItemCount
                  SET SECTION "File History" ENTRY hb_ntos(nI) TO Main.grid_1.item(Ni)[1]  +" | "+ltrim(+Main.grid_1.item(Ni)[2])
               Next
            EndIF

      END INI

   ELSEiF FileSize(cIni) == 0
      Ferase(cIni)
   EndIF

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure SaveConfig()
*-----------------------------------------------------------------------------*
   aData[1][1]  := Config.TEXTBOX_1.Value
   aData[1][2]  := Config.TEXTBOX_2.Value
   aData[1][3]  := Config.TEXTBOX_3.Value
   aData[1][4]  := Config.TEXTBOX_4.Value

   aData[2][1]  := Config.CHECKBOX_1.Value
   aData[2][2]  := Config.CHECKBOX_2.Value
   aData[2][3]  := Config.CHECKBOX_3.Value
   aData[2][4]  := Config.CHECKBOX_4.Value
   aData[2][5]  := Config.CHECKBOX_5.Value
   aData[2][6]  := Config.CHECKBOX_6.Value
   aData[2][7]  := Config.CHECKBOX_7.Value
   aData[2][8]  := Config.CHECKBOX_8.Value
   aData[2][9]  := Config.CHECKBOX_9.Value
   aData[2][10] := Config.CHECKBOX_10.Value

Return
/*
*/
*-----------------------------------------------------------------------------*
Function MsgAbout
*-----------------------------------------------------------------------------*
Return MsgInfo("SendMail2 version 1.0 - Freeware" + CRLF + ;
   "Copyright (c) 2007 Grigory Filatov" + CRLF + CRLF + ;
     padc("Email: gfilatov@gmail.com", 36) + CRLF + CRLF + ;
 "Revised in 2022 by Pierpaolo Martinello" + CRLF + CRLF + ;
   hb_compiler() + CRLF + ;
   version() + CRLF + ;
   substr(MiniGuiVersion(), 1, 38), "About")
/*
*/
*-----------------------------------------------------------------------------*
Procedure SendMails
*-----------------------------------------------------------------------------*
Local cSMTP, nPort, cUser := "", cFrom, cPassWord, oMail, ;
      cCopy, cTo, cSubject, cMsgBody, oSocket, ;
      i, nAtt := Main.Grid_1.ItemCount, nMsgs := max(1,nAtt), acCmd := {} , ;
      lMsg := {} , aBody ,ncrp := Main.EDITBOX_1.CaRetPos

      // avoid double click
      Main.MnuSend.Enabled      := .F.
      Main.btnSend.Enabled      := .F.

      cSMTP       := aData[1][1]
      nPort       := Val(aData[1][2])
      cFrom       := aData[1][3]
      cPassWord   := aData[1][4]
      cTo         := Alltrim(Main.COMBOBOX_1.DisplayValue)
      cSubject    := Alltrim(Main.COMBOBOX_2.DisplayValue)
      cMsgBody    := Alltrim(Main.EDITBOX_1.Value)

      aBody       := Hb_Atokens (alltrim(cMsgbody),CRLF)

      if Atail(abody) == CRLF
         msgbox("SDSD")
      Endif
      // preserve text compatibility with one html trick
      if !Is_Html( aBody )
         cMsgBody := St2Html(cMsgBody)
      Endif

      Main.EDITBOX_1.setfocus

      // Clean Sender address and prevent duplicate "<>" errors
      i := At( "<", cFrom )
      IF i > 0
         cUser := Chr(34) + Alltrim(Left(cFrom, i-1)) + Chr(34)
         cFrom := hb_StrReplace( substr(cFrom,i) , { '<' => '', '>' => '' } )
      EndIF

      IF cUser == Chr(34) + Chr(34) .or. len(cuser) = 0
         Cuser := cFrom
      EndIF

      // Clean  target address
      i := At( "<", cTo )
      cTo := hb_StrReplace( substr(cTo,i) , { '<' => '', '>' => '' } )

      do case
         case adata[2][9]   // use Cdo

              DEFINE MAIL oMail ;
              SUBJECT cSubject ;
              TEXT cMsgBody ;

              WITH OBJECT oMail
                 :cServer     := cSMTP
              IF ! Empty( nPort )
                 :nPort       := nPort
              EndIF
                 :cUser       := cFrom
                 :cPass       := cPassWord
                 :aOrigin     := { cUser, cFrom }
                 :aRecipients := {{ cto,NIL} }
                 :lReceipt    := adata[2][10]
              IF ! Empty( cCopy )
                 :cCopy       := cCopy
              EndIF
              IF nAtt > 0
                 For i := 1 TO nMsgs
                     aadd(:afiles,{ Main.Grid_1.Cell(i, 1) } )
                 Next
              EndIF
              /*
                 :nPriority   := nPriority
              */
              END WITH

              ACTIVATE MAIL oMail

              IF oMail:lSuccess ; MsgInfo( "Mail sent","Sent with CDO" ) ; EndIF

         case adata[2][8]   // use Curl
              IF nAtt > 0
                 For i := 1 TO nMsgs
                     aadd(lMsg , Main.Grid_1.Cell(i, 1) )
                 Next
              EndIF
              aadd(acCmd, " -# --insecure  ")

              IF adata [2][6] // use ssl
                 aadd(acCmd, "--ssl-reqd --url smtps://")
              Else
                 aadd(acCmd, "--url smtp://")
              EndIF

              // add smtp
              aadd(acCmd, cSmtp+":"+aData[1][2])
              aadd(acCmd," --user "+cFrom+":"+cPassword)
              aadd(acCmd," --mail-from "+cFrom+"|"+cUser )
              aadd(acCmd," --mail-rcpt "+cTo )

              Waitwindow("mail body creation",.T.)
              MailEncode(lmsg,,aCCmd,cSubject,aBody)
              Waitwindow()

       OtherWise           // use Tsmtp by Matteo Baccan

              IF Ascan( aAddress, cTo ) == 0
                 Aadd(aAddress, cTo)
              EndIF

              IF Ascan( aSubject, cSubject ) == 0
                 Aadd(aSubject, cSubject)
              EndIF
              oSocket := TSMTP():New()

              IF oSocket:Connect( cSMTP, nPort )

                 IF ! oSocket:Login( cFrom, cPassWord )
                    MsgStop( oSocket:GetLastError(), "While trying to login got an error messages from server" )
                    oSocket:Close()
                    RETURN
                 EndIF

                 Main.PROGRESSBAR_1.Enabled  := .t.
                 Main.PROGRESSBAR_2.Enabled  := .t.
                 Main.PROGRESSBAR_2.RangeMax := nMsgs
                 Main.BUTTONEX_1.Enabled     := .t.

                 For i := 1 TO nMsgs

                     IF lStop
                        EXIT
                     EndIF

                     oSocket:ClearData()

                     oSocket:SetFrom( cUser, "<"+cFrom+">" )

                     oSocket:AddTo( cUser, cTo )

                     oSocket:SetSubject( cSubject )

                     IF nAtt > 0
                        oSocket:AddAttach( Main.Grid_1.Cell(i, 1) )
                     EndIF

                     // send alwais on Html
                     oSocket:SetData( cMsgbody , .T. )

                     Main.PROGRESSBAR_1.Value := 5

                     IF ! oSocket:Send(.T.,adata[2][10] )
                        MsgStop( oSocket:GetLastError(), "While trying to send data got an error messages from server" )
                        oSocket:Close()
                        RETURN
                     EndIF

                     Main.PROGRESSBAR_1.Value := 10
                     Main.PROGRESSBAR_2.Value := i
                     DO EVENTS

                 NEXT i

                 oSocket:Close()

                 Main.PROGRESSBAR_1.Value   := 0
                 Main.PROGRESSBAR_2.Value   := 0
                 Main.PROGRESSBAR_1.Enabled := .f.
                 Main.PROGRESSBAR_2.Enabled := .f.
                 Main.BUTTONEX_1.Enabled    := .f.

                 MsgInfo( "Mail sent!","Sent with TSMTP" )

                 UpdateStatus()

              ELSE

                 MsgStop( "Can't connect to SMTP server: " + cSMTP, "Error while trying to connect to SMTP server" )

              EndIF

      Endcase

      UpdateToolBtns()

Return
/*
*/
*-----------------------------------------------------------------------------*
Static Function TakeDrop( aFiles )
*-----------------------------------------------------------------------------*
   LOCAL i, d:= 0 , cntErr :=0 , extPass:= {".PDF",".GIF",".TXT",".JPG",".BMP",".PNG"}
   LOCAL vGrid := Main.Grid_1.getarray

   // avoid duplicate files
   aeval (vgrid,{|x,y|d := ascan(afiles,x[1]),if(d > 0,hb_adel(aFiles,d,.t.),Nil) } )

   For i=1 To Len( aFiles )
      // Mime Filter: most providers do not accept bat or exe
      IF ASCAN(extPass, UPPER(hb_FNameExt(aFiles[i]) ) ) > 0

         DoMethod ( "Main" , "Grid_1" , 'AddItem' , { aFiles[i], Transform( FileSize(aFiles[i]), "999 999 999 999" ) } )
      Else
         IF cntErr < 1
            cntErr ++
            MsgExclamation("Only PDF,GIF,TXT,JPG,BMP,PNG are supported!", "Demo Limit!")
         EndIF
      EndIF
   Next

   IF cntErr = 0
      UpdateToolBtns()
      UpdateStatus()
      Main.Tab_1.Value := 2
   EndIF

return nil
/*
*/
*-----------------------------------------------------------------------------*
Function Crypt(cPass, act)
*-----------------------------------------------------------------------------*
// CHARXOR( cPass, REPL("@#$%&", 4) ) Is wrong, why truncates passwords
Local rtv
Default act to "E"

iF act  = "E"  // Encript
   rtv := hb_strtohex (hb_MD5Encrypt (cPass, REPL("@#$%&", 4)) )
Else          // Decript
   rtv := hb_MD5Decrypt(hb_HexToStr (cPass), REPL("@#$%&", 4))
Endif
Return rtv
/*
*/
*-----------------------------------------------------------------------------*
Procedure MailEncode(cFile,cDest,acCmd,cSubject,cbody)
*-----------------------------------------------------------------------------*
  LOCAL hf, aout:={} , csr, rOk := .F., sta, hfin
  LOCAL mr, nf, n1, cUser, cMsgerr
  LOCAL uFile, nmf, curlcmd:='', tFile
  LOCAL nAtt := Main.Grid_1.ItemCount
  LOCAL BOM  := "" //CHR(255)+chr(254) //CHR(239)+chr(187)+chr(191)
  Local Boundary := {[---=__Part__]+right(hb_md5( Time() ),24 ) ,[---=__Part__]+left(hb_md5( Time() ),24 ) }

  Default cfile to {hb_dirbase()+"Test.pdf"}
  Default cdest to hb_dirbase()+"Template.eml", cSubject to ""
  Default cBody to {}

  tFile := if( adata [2][7], hb_DirTemp(),hb_dirbase() )+"CurlReply.txt"

  aadd(acCmd," --stderr "+ tFile )
  aadd(acCmd," --upload-file "+cdest)

  nmf   := len(cfile)
  nf    := rat(" ",acCmd[5])+1
  cUser := substr(acCmd[5], 14 )
  nf    := rat("|",cUser)+1
  acCmd[5] := " --mail-from "+substr(cUser,1,at("|",cUser)-1 )
  cUser := substr(cUser,nf) +" <"+substr(cUser,1,at("|",cUser)-1 )+">"

  Waitwindow([Composition and send mail],.T.)

  aadd(aout,BOM+[From: ]+cUser )                                // Some Name <gfilatov@gmail.com>])
  aadd(aout,[To: <]+substr(acCmd[6],Rat(" ",acCmd[6])+1 ) +[>]) // Some Name <gfilatov@inbox.ru>])
  aadd(aout,[Subject: ]+alltrim(cSubject) )
  aadd(aout,[Reply-To: ]+ cUser)

  IF adata[2][10]     // read receipt
     Aadd(aout ,[Disposition-Notification-To: ]+ cUser )
  EndIF

  aadd(aout,[X-Mailer: Harbour and Curl by Pierpaolo Martinello] )
  /*  Option Not yet implemented
  aadd(aout,[Cc:])
  aadd(aout,[Ccn:])
  */
  aadd(aout,[MIME-Version: 1.0])
  aadd(aout,[Content-Type: multipart/mixed; boundary="]+Boundary[1]+["] )
  aadd(aout,[])
  if nAtt > 0
     aadd(aout,[This is a multi-part message in MIME format.])
  Endif
  aadd(aout,[--]+boundary[1] )
  // Plain text
  IF len(cbody) > 0
     aadd(aout,[Content-Type: multipart/alternative;])
     aadd(aout,[ boundary="]+Boundary[2]+["] )
     aadd(aout,[])
     aadd(aout,[--]+boundary[2] )

     // aadd(aout,[Content-Type: text/plain; charset="iso-8859-1"])
     aadd(aout,[Content-Type: text/plain; charset="UTF-8" ])
     aadd(aout,[Content-Transfer-Encoding: quoted-printable])
     aadd(aout,[])
     Aeval(cbody,{|x| aadd(aout,QPEncode( utf8convert(x) ) ) } )
     aadd(aout,[--]+boundary[2] )
     aadd(aout,[Content-Type: text/html; charset=UTF-8])
     aadd(aout,[Content-Transfer-Encoding: 8bit])
     aadd(aout,[])
     Aadd(aout,ST2Html(Alltrim(Main.EDITBOX_1.Value) ) )
     aadd(aout,[--]+boundary[2]+[--] )
  EndIF

  // the attachments
  IF nAtt > 0
     For nf = 1 to nmf
         uFile := cFileNopath(cfile[nf])
         aadd(aout,[--]+boundary[1] )
         aadd(aout,[Content-Type: application/pdf; name="]+ufile+["])
         aadd(aout,[Content-Disposition: attachment; filename="]+ufile+["] )
         aadd(aout,"Content-Transfer-Encoding: base64"+CRLF)
         hf  := memoread(cFile[nf])
         hf  := hb_base64encode( hf )
         mr  := round(len(hf)/72,0)
         For n1 = 0 to mr
             sta  := ( 72*n1 ) + 1
             hfin := substr(hf,sta,72)
             aadd (aout,hfin)
         Next
         aadd(aout,[--]+boundary[1] )
     Next
     aout[len(aout)] := atail(aout)+"--"
  Else
     aadd(aout,[--]+boundary[1]+[--] )
  EndIF

  Ferase(cdest)
  WriteFile(cdest,aout)
  waitwindow()

  IF filesize(cdest ) < 390
     cMsgErr :="File creation error:"+CRLF+CRLF + cdest
  Else
     Aeval (acCmd,{|x| curlcmd += x})

     CmdExe ( Curlcmd )      // Send Mail

     IF len( Curlcmd ) < 10000

        csr := hb_atokens( memoread( tfile ) ,CRLF)

        Aeval ( csr,{|x,y| csr[y] := ltrim(hb_StrReplace( x,"#=","")) } )

        // detect ok and purge
        mr := 0
        For nf = 1 to len(csr)
            IF ( "100,0%" $ csr [nf] , RoK := .T.,NIL )
            IF ( Left(csr[nf],5) = "curl:", cMsgErr := csr[nf],NIL )
        Next

     EndIF

     Ferase ( cdest )
     Ferase ( tFile )

  EndIF

  IF RoK
     msginfo("Mail sent correctly.","Sent with CURL")
  Else
     // not tested for all errors
     msgStop(if(empty(cMsgErr),"No Mail created! ",cMsgErr),"Errors details:")
  EndIF

RETURN // Rok
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION CmdExe( cCommand )
*-----------------------------------------------------------------------------*
   LOCAL hProcess, cResult
   LOCAL hStdOut, hStderr, nState, nBytes
   LOCAL cBuff, wdir:= hb_GetEnv("Windir","C:\Windows")
   LOCAL Pcurl:=""

   IF isexe64()
      IF file( wDir+"\Syswow64\Curl.exe")
         Pcurl := wDir+"\Syswow64\Curl.exe"
      EndIF
   Else
      IF file( wDir+"\System32\Curl.exe")
         Pcurl := wDir+"\System32\Curl.exe"
      EndIF
   EndIF

   IF file(hb_dirbase()+"Curl.exe")
      Pcurl := hb_dirbase()+"Curl.exe"
   EndIF

   IF empty ( Pcurl )
      msgstop("This operating system does not have Curl.Exe !")
      Return ''
   else
      cCommand := pCurl+ " "+ cCommand
   EndIF

   cBuff := Space( 1024 )

   hProcess := hb_processOpen( cCommand, NIL, @hStdOut, @hStdErr, .T. )

   IF hProcess != -1

      nState := hb_processValue( hProcess, .T. )

      WHILE nState <> -1

         nBytes := FRead( hStdOut, @cBuff, 1024 )

         IF nBytes == 0
            EXIT
         EndIF

         nState := hb_processValue( hProcess, .T. )

      END
         cBuff   := StrTran( cBuff, Chr( 13 ) )
         cBuff   := StrTran( cBuff, Chr( 10 ) )
         cResult := CharRem( " ", cBuff )

      hb_processClose( hProcess )

   EndIF f

RETURN cResult
/*
*/
*-----------------------------------------------------------------------------*
Procedure Writefile(filename, arrayname)
*-----------------------------------------------------------------------------*
   LOCAL f_handle

   * open file and position pointer at the end of file
   IF VALTYPE(filename) == "C"
     f_handle := FOPEN(filename,2)
     *- IF not joy opening file, create one
     IF Ferror() <> 0
        f_handle := Fcreate(filename,0)
     EndIF
     FSEEK(f_handle,0,2)
   ELSE
     f_handle := filename
     FSEEK(f_handle,0,2)
   EndIF

   IF VALTYPE(arrayname) == "A"
     * IF its an array, do a loop to write it out
     * msginfo(str(len(arrayname)),"FKF")
     Aeval( Arrayname,{|x|FWRITE(f_handle,x+CRLF )} )
   ELSE
     * must be a character string - just write it
     if arrayname == "BOM"
        FWRITE(f_handle,CHR(255)+chr(254) )
     Else
       FWRITE(f_handle,arrayname+CRLF )
     Endif
     //msgbox(Arrayname,"Array")
   EndIF

   * close the file
   IF VALTYPE(filename)=="C"
      Fclose(f_handle)
   EndIF

Return
/*
*/
*-----------------------------------------------------------------------------*
Function Utf8Convert(string)
*-----------------------------------------------------------------------------*
DEFAULT string to ""
   string := alltrim(string)
Return hb_StrToUTF8( string, hb_cdpOS() )
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION QPEncode( cData ) // from Tip Library
*-----------------------------------------------------------------------------*
   LOCAL nPos, c, nLen
   LOCAL cString := "" , nLineLen := 0

   nLen := hb_BLen( cData )
   FOR nPos := 1 TO nLen
      c := hb_BSubStr( cData, nPos, 1 )
      IF c == Chr( 10 )
         cString += Chr( 13 ) + Chr( 10 )
         nLineLen := 0
      ELSEIF hb_BCode( c ) >= 127 .OR. ;
         c $ '=?!"#$@[\]^`{|}~' .OR. ;
         ( hb_BCode( c ) < 32 .AND. !( c $ Chr( 13 ) + Chr( 10 ) + Chr( 9 ) ) ) .OR. ;
         ( c $ " " + Chr( 9 ) .AND. hb_BSubStr( cData, nPos + 1, 1 ) $ Chr( 13 ) + Chr( 10 ) )
         IF nLineLen + 3 > 75
            cString += "=" + Chr( 13 ) + Chr( 10 )
            nLineLen := 0
         EndIF
         cString += "=" + hb_NumToHex( hb_BCode( c ), 2 )
         nLineLen += 3
      ELSEIF !( c == Chr( 13 ) )
         IF nLineLen + 3 > 75
            cString += "=" + Chr( 13 ) + Chr( 10 )
            nLineLen := 0
         EndIF
         cString += c
         nLineLen += 1
      EndIF
   NEXT

   RETURN cString
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Is_Html( aData )
*-----------------------------------------------------------------------------*
Local rtv := 0, i, ;
Src4 := {"<BR>","<HTML>","<HEAD>","<BODY>","/<BODY>","</BR>","</HTML>","</HEAD>"}

Default aData to {}

   For i=1 To Len( adata )

      IF ASCAN( Src4, upper( aData[i] ) ) > 0
         rtv ++
      Endif
   Next

Return ( rtv > 1 )
/*
*/
*-----------------------------------------------------------------------------*
Function St2Html( arg1 ) // SimpleTextToHtml
*-----------------------------------------------------------------------------*
Default arg1 to ""
   arg1:= " "+hb_StrReplace(arg1 , { chr(13)+chr(10) => '<br>'+CRLF+" " } )

   arg1 := "<html>"+CRLF+" <head>"+CRLF+;
        [  <meta http-equiv="content-type" content="text/html; charset=UTF-8">]+CRLF ;
        +" </head>"+CRLF+" <body> <p>"+CRLF+utf8convert( arg1 )+"  </p>"+CRLF+" </body>"+CRLF+"</html>"

Return arg1
/*
*/
*-----------------------------------------------------------------------------*
Procedure ShowPassword()
*-----------------------------------------------------------------------------*
  LOCAL cPass_1 := Config.TEXTBOX_4.VALUE, cPass_2 := Config.TEXTBOX_5.VALUE

  If lSPwd = .F.
     Config.TEXTBOX_4.HIDE
     Config.TEXTBOX_5.VALUE := cPass_1
     Config.TEXTBOX_5.SHOW
     lSPwd = .T.
  Else
     Config.TEXTBOX_5.HIDE
     Config.TEXTBOX_4.VALUE := cPass_2
     Config.TEXTBOX_4.SHOW
     lSPwd = .F.
  EndIf

Return
/*
*/