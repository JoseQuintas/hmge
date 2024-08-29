
#define _HMG_OUTLOG

#include "hmg.ch"
#include "TSBrowse.ch"

#define CLR_HGREY           CLR_SILVER

#define CLR_BLACK                              0      // RGB(   0,   0,   0  )                
#define CLR_MAROON                           128      // RGB( 128,   0,   0  )                
#define CLR_DARKRED                          139      // RGB( 139,   0,   0  )                
#define CLR_RED                              255      // RGB( 255,   0,   0  )                
#define CLR_ORANGERED                      17919      // RGB( 255,  69,   0  )                
#define CLR_DARKGREEN                      25600      // RGB(   0, 100,   0  )                
#define CLR_GREEN                          32768      // RGB(   0, 128,   0  )                
#define CLR_OLIVE                          32896      // RGB( 128, 128,   0  )                
#define CLR_DARKORANGE                     36095      // RGB( 255, 140,   0  )                
#define CLR_ORANGE                         42495      // RGB( 255, 165,   0  )                
#define CLR_GOLD                           55295      // RGB( 255, 215,   0  )                
#define CLR_LAWNGREEN                      64636      // RGB( 124, 252,   0  )                
#define CLR_LIME                           65280      // RGB(   0, 255,   0  )                
#define CLR_CHARTREUSE                     65407      // RGB( 127, 255,   0  )                
#define CLR_DARKGOLDENROD                 755384      // RGB( 184, 134,  11  )                
#define CLR_SADDLEBROWN                  1262987      // RGB( 139,  69,  19  )                
#define CLR_CHOCOLATE                    1993170      // RGB( 210, 105,  30  )                
#define CLR_GOLDENROD                    2139610      // RGB( 218, 165,  32  )                
#define CLR_FIREBRICK                    2237106      // RGB( 178,  34,  34  )                
#define CLR_FORESTGREEN                  2263842      // RGB(  34, 139,  34  )                
#define CLR_OLIVEDRAB                    2330219      // RGB( 107, 142,  35  )                
#define CLR_BROWN                        2763429      // RGB( 165,  42,  42  )                
#define CLR_SIENNA                       2970272      // RGB( 160,  82,  45  )                
#define CLR_DARKOLIVEGREEN               3107669      // RGB(  85, 107,  47  )                
#define CLR_GREENYELLOW                  3145645      // RGB( 173, 255,  47  )                
#define CLR_LIMEGREEN                    3329330      // RGB(  50, 205,  50  )                
#define CLR_YELLOWGREEN                  3329434      // RGB( 154, 205,  50  )                
#define CLR_CRIMSON                      3937500      // RGB( 220,  20,  60  )                
#define CLR_PERU                         4163021      // RGB( 205, 133,  63  )                
#define CLR_TOMATO                       4678655      // RGB( 255,  99,  71  )                
#define CLR_DARKSLATEGRAY                5197615      // RGB(  47,  79,  79  )                
#define CLR_CORAL                        5275647      // RGB( 255, 127,  80  )                
#define CLR_SEAGREEN                     5737262      // RGB(  46, 139,  87  )                
#define CLR_YELLOW                       6053069      // RGB( 205,  92,  92  )                
#define CLR_SANDYBROWN                   6333684      // RGB( 244, 164,  96  )                
#define CLR_DIMGRAY                      6908265      // RGB( 105, 105, 105  )                
#define CLR_DARKKHAKI                    7059389      // RGB( 189, 183, 107  )                
#define CLR_MIDNIGHTBLUE                 7346457      // RGB(  25,  25, 112  )                
#define CLR_MEDIUMSEAGREEN               7451452      // RGB(  60, 179, 113  )                
#define CLR_SALMON                       7504122      // RGB( 250, 128, 114  )                
#define CLR_DARKSALMON                   8034025      // RGB( 233, 150, 122  )                
#define CLR_LIGHTSALMON                  8036607      // RGB( 255, 160, 122  )                
#define CLR_SPRINGGREEN                  8388352      // RGB(   0, 255, 127  )                
#define CLR_NAVY                         8388608      // RGB(   0,   0, 128  )                
#define CLR_PURPLE                       8388736      // RGB( 128,   0, 128  )                
#define CLR_TEAL                         8421376      // RGB(   0, 128, 128  )                
#define CLR_GRAY                         8421504      // RGB( 128, 128, 128  )                
#define CLR_LIGHTCORAL                   8421616      // RGB( 240, 128, 128  )                
#define CLR_INDIGO                       8519755      // RGB(  75,   0, 130  )                
#define CLR_MEDIUMVIOLETRED              8721863      // RGB( 199,  21, 133  )                
#define CLR_BURLYWOOD                    8894686      // RGB( 222, 184, 135  )                
#define CLR_DARKBLUE                     9109504      // RGB(   0,   0, 139  )                
#define CLR_DARKMAGENTA                  9109643      // RGB( 139,   0, 139  )                
#define CLR_DARKSLATEBLUE                9125192      // RGB(  72,  61, 139  )                
#define CLR_DARKCYAN                     9145088      // RGB(   0, 139, 139  )                
#define CLR_TAN                          9221330      // RGB( 210, 180, 140  )                
#define CLR_KHAKI                        9234160      // RGB( 240, 230, 140  )                
#define CLR_ROSYBROWN                    9408444      // RGB( 188, 143, 143  )                
#define CLR_DARKSEAGREEN                 9419919      // RGB( 143, 188, 143  )                
#define CLR_SLATEGRAY                    9470064      // RGB( 112, 128, 144  )                
#define CLR_LIGHTGREEN                   9498256      // RGB( 144, 238, 144  )                
#define CLR_DEEPPINK                     9639167      // RGB( 255,  20, 147  )                
#define CLR_PALEVIOLETRED                9662683      // RGB( 219, 112, 147  )                
#define CLR_PALEGREEN                   10025880      // RGB( 152, 251, 152  )                
#define CLR_LIGHTSLATEGRAY              10061943      // RGB( 119, 136, 153  )                
#define CLR_MEDIUMSPRINGGREEN           10156544      // RGB(   0, 250, 154  )                
#define CLR_CADETBLUE                   10526303      // RGB(  95, 158, 160  )                
#define CLR_DARKGRAY                    11119017      // RGB( 169, 169, 169  )                
#define CLR_LIGHTSEAGREEN               11186720      // RGB(  32, 178, 170  )                
#define CLR_MEDIUMAQUAMARINE            11193702      // RGB( 102, 205, 170  )                
#define CLR_PALEGOLDENROD               11200750      // RGB( 238, 232, 170  )                
#define CLR_NAVAJOWHITE                 11394815      // RGB( 255, 222, 173  )                
#define CLR_WHEAT                       11788021      // RGB( 245, 222, 179  )                
#define CLR_HOTPINK                     11823615      // RGB( 255, 105, 180  )                
#define CLR_STEELBLUE                   11829830      // RGB(  70, 130, 180  )                
#define CLR_MOCCASIN                    11920639      // RGB( 255, 228, 181  )                
#define CLR_PEACHPUFF                   12180223      // RGB( 255, 218, 185  )                
#define CLR_SILVER                      12632256      // RGB( 192, 192, 192  )                
#define CLR_LIGHTPINK                   12695295      // RGB( 255, 182, 193  )                
#define CLR_BISQUE                      12903679      // RGB( 255, 228, 196  )                
#define CLR_PINK                        13353215      // RGB( 255, 192, 203  )                
#define CLR_DARKORCHID                  13382297      // RGB( 153,  50, 204  )                
#define CLR_MEDIUMTURQUOISE             13422920      // RGB(  72, 209, 204  )                
#define CLR_MEDIUMBLUE                  13434880      // RGB(   0,   0, 205  )                
#define CLR_SLATEBLUE                   13458026      // RGB( 106,  90, 205  )                
#define CLR_BLANCHEDALMOND              13495295      // RGB( 255, 235, 205  )                
#define CLR_LEMONCHIFFON                13499135      // RGB( 255, 250, 205  )                
#define CLR_TURQUOISE                   13688896      // RGB(  64, 224, 208  )                
#define CLR_DARKTURQUOISE               13749760      // RGB(   0, 206, 209  )                
#define CLR_LIGHTGOLDENRODYELLOW        13826810      // RGB( 250, 250, 210  )                
#define CLR_DARKVIOLET                  13828244      // RGB( 148,   0, 211  )                
#define CLR_MEDIUMORCHID                13850042      // RGB( 186,  85, 211  )                
#define CLR_LIGHTGRAY                   13882323      // RGB( 211, 211, 211  )                
#define CLR_AQUAMARINE                  13959039      // RGB( 127, 255, 212  )                
#define CLR_PAPAYAWHIP                  14020607      // RGB( 255, 239, 213  )                
#define CLR_ORCHID                      14053594      // RGB( 218, 112, 214  )                
#define CLR_ANTIQUEWHITE                14150650      // RGB( 250, 235, 215  )                
#define CLR_THISTLE                     14204888      // RGB( 216, 191, 216  )                
#define CLR_MEDIUMPURPLE                14381203      // RGB( 147, 112, 219  )                
#define CLR_GAINSBORO                   14474460      // RGB( 220, 220, 220  )                
#define CLR_BEIGE                       14480885      // RGB( 245, 245, 220  )                
#define CLR_CORNSILK                    14481663      // RGB( 255, 248, 220  )                
#define CLR_PLUM                        14524637      // RGB( 221, 160, 221  )                
#define CLR_LIGHTSTEELBLUE              14599344      // RGB( 176, 196, 222  )                
#define CLR_LIGHTYELLOW                 14745599      // RGB( 255, 255, 224  )                
#define CLR_ROYALBLUE                   14772545      // RGB(  65, 105, 225  )                
#define CLR_MISTYROSE                   14804223      // RGB( 255, 228, 225  )                
#define CLR_BLUEVIOLET                  14822282      // RGB( 138,  43, 226  )                
#define CLR_LIGHTBLUE                   15128749      // RGB( 173, 216, 230  )                
#define CLR_POWDERBLUE                  15130800      // RGB( 176, 224, 230  )                
#define CLR_LINEN                       15134970      // RGB( 250, 240, 230  )                
#define CLR_OLDLACE                     15136253      // RGB( 253, 245, 230  )                
#define CLR_SKYBLUE                     15453831      // RGB( 135, 206, 235  )                
#define CLR_CORNFLOWERBLUE              15570276      // RGB( 100, 149, 237  )                
#define CLR_MEDIUMSLATEBLUE             15624315      // RGB( 123, 104, 238  )                
#define CLR_VIOLET                      15631086      // RGB( 238, 130, 238  )                
#define CLR_PALETURQUOISE               15658671      // RGB( 175, 238, 238  )                
#define CLR_SEASHELL                    15660543      // RGB( 255, 245, 238  )                
#define CLR_FLORALWHITE                 15792895      // RGB( 255, 250, 240  )                
#define CLR_HONEYDEW                    15794160      // RGB( 240, 255, 240  )                
#define CLR_IVORY                       15794175      // RGB( 255, 255, 240  )                
#define CLR_LAVENDERBLUSH               16118015      // RGB( 255, 240, 245  )                
#define CLR_WHITESMOKE                  16119285      // RGB( 245, 245, 245  )                
#define CLR_LIGHTSKYBLUE                16436871      // RGB( 135, 206, 250  )                
#define CLR_LAVENDER                    16443110      // RGB( 230, 230, 250  )                
#define CLR_SNOW                        16448255      // RGB( 255, 250, 250  )                
#define CLR_MINTCREAM                   16449525      // RGB( 245, 255, 250  )                
#define CLR_BLUE                        16711680      // RGB(   0,   0, 255  )                
#define CLR_FUCHSIA                     16711935      // RGB( 255,   0, 255  )                
#define CLR_DODGERBLUE                  16748574      // RGB(  30, 144, 255  )                
#define CLR_DEEPSKYBLUE                 16760576      // RGB(   0, 191, 255  )                
#define CLR_ALICEBLUE                   16775408      // RGB( 240, 248, 255  )                
#define CLR_GHOSTWHITE                  16775416      // RGB( 248, 248, 255  )                
#define CLR_CYAN                        16776960      // RGB(   0, 255, 255  )                
#define CLR_LIGHTCYAN                   16777184      // RGB( 224, 255, 255  )                
#define CLR_AZURE                       16777200      // RGB( 240, 255, 255  )                
#define CLR_WHITE                       16777215      // RGB( 255, 255, 255  )                