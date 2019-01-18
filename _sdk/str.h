#define _STRLEN 80 /**включая 0*/
#define _STRMAX (UINT)(_STRLEN-1) /**не включая 0*/

FUNC UINT stradd FORWARD(PCHAR s, UINT len, CHAR c);
FUNC UINT strjoin FORWARD(PCHAR to, UINT tolen, PCHAR s2); //длина без терминатора!
FUNC UINT strjoineol FORWARD(PCHAR to, UINT tolen, PCHAR s2/**, UINT s2len*/, CHAR eol); //длина без терминатора!
FUNC UINT strcopy FORWARD(PCHAR from, UINT len, PCHAR to); //длина без терминатора!
PROC memcopy FORWARD(PBYTE from, UINT len, PBYTE to);
PROC memcopyback FORWARD(PBYTE from, UINT len, PBYTE to);
FUNC BOOL strcp FORWARD(PCHAR s1, PCHAR s2);
FUNC UINT hash FORWARD(PBYTE pstr);

