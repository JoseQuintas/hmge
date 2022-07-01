#include <hmg.ch>

#define ZFORM_MAIN      "Main"
#define ZBUTTON_GETFILE "Button_1"
#define ZBUTTON_HB_REGEX_ALL "Button_2"
#define ZBUTTON_HB_REGEX     "Button_3"
#define ZBUTTON_PROJECTUDF "Button_4"
#define ZCHECK_ASCII128 "Check_1"
#define ZEDIT_FILE      "RichEdit_1"
#define ZEDIT_UDF       "Edit_2"
#define ZEDIT_FUNC      "Edit_3"
#define ZEDIT_REGEX     "Edit_4"
#define ZEDIT_HBFUNC    "Edit_5"
#define ZEDIT_PJT_UDF   "Edit_6"
#define ZEDIT_PJT_FUNC  "Edit_7"
#define ZGRID_UDF       "Grid_1"
#define ZGRID_FUNC      "Grid_2"
#define ZGRID_PJT_UDF   "Grid_3"
#define ZGRID_PJT_FUNC  "Grid_4"
#define ZLABEL_FILE     "Label_1"
#define ZLIST_FILES     "List_1"
#define ZTEXT_PATH      "Text_1"
#define ZTEXT_REGEX     "Text_2"

#define ZREGEX_FUNC   "(?i) \w+\("
#define ZREGEX_UDF    "(?i)(function | func | procedure | proc )[\w_]+\([\w\s,\.]*\)"

#define ZSPACE        " "
#define ZBSLASH '\'
#define ZCR     CHR( 13)
#define ZLF     CHR( 10)
#define ZCRLF   ZCR + ZLF
#define ZNOTFOUND     "Not Found !"


#define LEFT_TOP       chr( 218) && "+"
#define RIGHT_TOP      chr( 191) && "+"
#define LEFT_BOTTOM    chr( 192) && "+"
#define RIGHT_BOTTOM   chr( 217) && "+"
#define VER              chr( 179) && ZSPACE
#define HOR              chr( 196) && "-"
#define CROSS            chr( 197) && "+"
#define TIE              chr( 194) && ZSPACE
#define UTIE             chr( 193) && ZSPACE
#define LEFT_TIE         chr( 195) && "+"
#define RIGHT_TIE        chr( 180) && "Ù"
#define DHOR             chr( 205) && "Ú"
#define DLEFT_TOPD       chr( 201) && ZSPACE   ?
#define DRIGHT_TOPD      chr( 187) && ZSPACE
#define DLEFT_BOTTOMD    chr( 200) && ZSPACE
#define DRIGHT_BOTTOMD   chr( 188) && ZSPACE
#define DVER             chr( 186) && ZSPACE
#define DHCROSS          CHR( 216) && "+"

#define UNILEFT_TOP       	HB_UCHAR(0x250C) && "+"
#define UNIRIGHT_TOP      	HB_UCHAR(0x2510) && "+"
#define UNILEFT_BOTTOM    	HB_UCHAR(0x2514)&& "+"
#define UNIRIGHT_BOTTOM   	HB_UCHAR(0x2518)&& "+"
#define UNIVER              	HB_UCHAR(0x2502)&& ZSPACE
#define UNIHOR              	HB_UCHAR(0x2500)&& "-"
#define UNICROSS            	HB_UCHAR(0x253C)&& "+"
#define UNITIE              	HB_UCHAR(0x252C)&& ZSPACE
#define UNIUTIE             	HB_UCHAR(0x2534)&& ZSPACE
#define UNILEFT_TIE         	HB_UCHAR(0x251C)&& "+"
#define UNIRIGHT_TIE        	HB_UCHAR(0x2524)&& "Ù"
#define UNIDHOR             	HB_UCHAR(0x2550)&& "Ú"
#define UNIDLEFT_TOPD       	HB_UCHAR(0x2554)&& ZSPACE
#define UNIDRIGHT_TOPD      	HB_UCHAR(0x2557)&& ZSPACE
#define UNIDLEFT_BOTTOMD    	HB_UCHAR(0x255A)&& ZSPACE
#define UNIDRIGHT_BOTTOMD   	HB_UCHAR(0x255D)&& ZSPACE
#define UNIDVER             	HB_UCHAR(0x2551)&& ZSPACE
#define UPARROW               HB_UCHAR(0x2912) && 0x25B2)
#define DNARROW               HB_UCHAR(0x2913) && 0x25BC)
