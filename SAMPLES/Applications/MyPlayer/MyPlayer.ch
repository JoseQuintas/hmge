#Define PROGRAM   'My Player'
#Define VERSION   'Version 1.1'
#Define COPYRIGHT '2004-2022'
#Define AUTOR     'Humberto Fornazier'

Declare Window Form_2
Declare Window Form_3
Declare Window Form_Alarme
Declare Window Form_Player
Declare Window Form_Config

Static nCtEfeito        := 0
Static xRetar           := 0
Static nProxima         := 1
Static nCt              := 1
Static nLenght          := 0
Static lPlayPause       := .F.
Static lSorteia         := .F.
Static lContinua        := .F.
Static lDesliga         := .F.
Static lPlaylist        := .F.
Static cSkin            := ""
Static cFile            := ""
Static cDirMusicas      := ""
Static cDirMP3          := ""
Static cNomeMusicaAtual := ""
Static nTempo           := ""
Static cDesligarEm      := ""
Static cMinutos         := ""
Static cDescEfeito      := ""
Static cDirExe          := ""
Static aMusicas         := {}
Static aOrd             := {}
