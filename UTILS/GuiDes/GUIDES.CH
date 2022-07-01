/*
 * GuiDes source code:
 *
 * Copyright 2002 Carlos Andr‚s <carlos.andres@navegalia.com>
 * www - http://www.geocities.com/harbour_links/guides
 *
 * GuiDes is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * GuiDes is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 */

#define G_RELEASE    "0.4.1"

#define G_WHITE      { 255, 255, 255 }
#define G_GREY       { 192, 192, 192 }
#define G_BLACK      { 0, 0, 0 }
#define G_LIGHTGREY  { 210, 210, 210 }

#define G_FONT       { "Segoe UI", 9, FALSE, FALSE, G_BLACK, FALSE, FALSE, 0 }
#define G_LINK       "https://www.oocities.org/harbour_links/guides"

#define CR_LF        CHR(13)+CHR(10)

#define G_MAINMENU          1
#define G_CONTEXTMENU       2
#define G_NOTIFYMENU        3
#define G_TREE              4
#define G_STATUSBAR         5

#define G_EXIT_SAVE         0
#define G_EXIT_DISCARD      1
#define G_EXIT_DESTROY      2

#define G_WIN_TOP_ROW       	130
#define G_WIN_TOP_COL      	250
#define G_NEWWIN_ROW_OFFSET	30
#define G_NEWWIN_COL_OFFSET	20

#define G_MAX_RECENT		5

#define PREF_FILE           "GUIDES"

#define IDH_CREATEWINDOW	1001
#define IDH_ADDCONTROL		1002
#define IDH_SELECTWINDOW	1003
#define IDH_MODIFYWINDOW	1004
#define IDH_SELECTCONTROL	1005
#define IDH_CHANGECONTROL	1006
#define IDH_MOVECONTROL		1007
#define IDH_DELCONTROL		1008
#define IDH_SAVEWINDOW		1009
#define IDH_EXPORTWINDOW	1010
#define IDH_ADDINGMENUS		1011
#define IDH_SELECTINGPREF	1012
#define IDH_SAVINGPREFS		1013
#define IDH_ENVIRONMENT		1014

#xtranslate Alltrim( Str( <i> ) ) => hb_ntos( <i> )

MEMVAR oEnvir, oProps, oStyle
MEMVAR oLayout
MEMVAR GuiDesDir
