#define _STRLEN 255 /**including terminator*/
#define _STRMAX (UINT)(_STRLEN-1) /**without terminator*/

/*FUNC UINT strlen FORWARD(PCHAR s);*/
FUNC UINT stradd FORWARD(PCHAR s, UINT len, CHAR c);
FUNC UINT strjoin FORWARD(PCHAR to, UINT tolen, PCHAR s2); //len without terminator!
FUNC UINT strjoineol FORWARD(PCHAR to, UINT tolen, PCHAR s2, CHAR eol); //len without terminator!
FUNC UINT strcopy FORWARD(PCHAR from, UINT len, PCHAR to); //len without terminator!
PROC memcopy FORWARD(PBYTE from, UINT len, PBYTE to);
PROC memcopyback FORWARD(PBYTE from, UINT len, PBYTE to);
FUNC BOOL strcp FORWARD(PCHAR s1, PCHAR s2);
FUNC UINT hash FORWARD(PBYTE pstr);
