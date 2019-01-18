#include "../_sdk/str.h"

FUNC UINT strjoin(PCHAR to, UINT tolen, PCHAR s2/**, UINT s2len*/) //длина без терминатора!
{ //to = to + s2;
VAR UINT len;
VAR CHAR c;
  to = &to[tolen/**+_FIRST*/];
  len = tolen; //длина без терминатора!
  loop: //REPEAT {
    c = *(PCHAR)s2;
    IF ((c == '\0') || (len>=_STRMAX)) goto endloop; //BREAK; //терминатор не копируется
    POKE *(PCHAR)(to) = c;
    INC s2;
    INC to;
    INC len;
  goto loop; //}UNTIL ( (c=='\0') || (len>=_STRMAX) ); //терминатор не копируется
  endloop:
  RETURN len; //длина без терминатора!
}

FUNC UINT strjoineol(PCHAR to, UINT tolen, PCHAR s2/**, UINT s2len*/, CHAR eol) //длина без терминатора!
{ //to = to + s2;
VAR UINT len;
VAR CHAR c;
  to = &to[tolen/**+_FIRST*/];
  len = tolen; //длина без терминатора!
  loop: //REPEAT {
    c = *(PCHAR)s2;
    IF ((c == eol) || (len>=_STRMAX)) goto endloop; //BREAK; //терминатор не копируется
    POKE *(PCHAR)(to) = c;
    INC s2;
    INC to;
    INC len;
  goto loop; //}UNTIL ( (c==eol) || (len>=_STRMAX) ); //терминатор не копируется
  endloop:
  RETURN len; //длина без терминатора!
}

FUNC UINT strcopy(PCHAR from, UINT len, PCHAR to) //длина без терминатора!
{
VAR UINT i = len+1;
VAR CHAR c;
  REPEAT {
    c = *(PCHAR)from;
    POKE *(PCHAR)(to) = c;
    INC from;
    INC to;
    DEC i;
  }UNTIL (i==0); //(c=='\0'); //терминатор копируется
  RETURN len; //длина без терминатора!
}

PROC memcopy(PBYTE from, UINT len, PBYTE to)
{
VAR CHAR c;
  REPEAT {
    c = *(PCHAR)from;
    POKE *(PCHAR)(to) = c;
    INC from;
    INC to;
    DEC len;
  }UNTIL (len==0);
}

PROC memcopyback(PBYTE from, UINT len, PBYTE to)
{
VAR CHAR c;
  REPEAT {
    c = *(PCHAR)from;
    POKE *(PCHAR)(to) = c;
    DEC from;
    DEC to;
    DEC len;
  }UNTIL (len==0);
}

FUNC BOOL strcp(PCHAR s1, PCHAR s2)
{
VAR UINT i;
VAR CHAR c1;
VAR BOOL ok;
  i = 0;
  ok = +TRUE; //по умолчанию строки равны
  REPEAT { //проверяем все символы первой строки, кроме терминатора
    //IF (s1[i] != s2[i]) { //вторая строка рано кончилась или символ не совпал
    //  result = +FALSE;
    //  BREAK;
    //};
    c1 = s1[i];
    IF (c1 != s2[i]) {ok = +FALSE; BREAK; }; //символ не совпал или одна из строк кончилась
    //IF (c1 == '\0') BREAK; //обе строки кончились
    INC i;
  }UNTIL (c1 == '\0'); //обе строки кончились
  //IF (s2[i] != '\0') result = +FALSE; //вторая строка не кончилась
  RETURN ok;
}

/**
FUNC UINT strclear(PCHAR s)
{ //s = "";
  //s[_FIRST]='\0'; //терминатор (не нужен - используем потом strclose)
  RETURN 0; //длина без терминатора!
}
*/
FUNC UINT stradd(PCHAR s, UINT len, CHAR c) //длина без терминатора!
{ //s = s + c;
  IF (len < _STRMAX) {
    //POKE *(PCHAR)(+(POINTER)(s) + +(POINTER)(len) + +(POINTER)(_FIRST)) = c;
    s[len/**+_FIRST*/] = c;
    INC len;
    //s[len/**+_FIRST*/]='\0'; //терминатор (не нужен - используем потом strclose)
  };
  RETURN len;
}

//PROC strclose(PCHAR s, UINT len) //вызывать после strclear или группы stradd
//{
//  s[len/**+_FIRST*/] = '\0'; //терминатор
//}

//FUNC UINT strcopy(PCHAR from, UINT len, PCHAR to) //длина без терминатора!
//{
//  RETURN strjoin(to, 0/**strclear(to)*/, from); //tolen;
//}

/**
PROC stringdecapitalize(PCHAR s1, UINT s1len)
{
VAR UINT i;
VAR CHAR c;
  i = _FIRST;
  WHILE (+TRUE) {
    c = s1[i];
    IF (c == '\0') BREAK;
    IF ((c>='A') && (c<='Z')) {
      //POKE *(PCHAR)(+(POINTER)(s1) + +(POINTER)(i)) = c | +(CHAR)0x20;
      s1[i] = +(CHAR)(c | +(CHAR)0x20);
    };
    i = +(UINT)(i + 1);
  };
}
*/

FUNC BOOL strcplow(PCHAR s1/**, UINT s1len*/, PCHAR s2)
{
VAR UINT i;
VAR CHAR c1;
VAR CHAR c2;
VAR BOOL ok;
  i = 0;
  ok = +TRUE; //по умолчанию строки равны
  REPEAT { //проверяем все символы первой строки, кроме терминатора
    c1 = s1[i/**+_FIRST*/];
    c2 = s2[i/**+_FIRST*/];
    IF ((+(BYTE)c1>=+(BYTE)'A') && (+(BYTE)c1<=+(BYTE)'Z')) c1 = +(CHAR)(+(BYTE)c1 | 0x20);
    IF ((+(BYTE)c2>=+(BYTE)'A') && (+(BYTE)c2<=+(BYTE)'Z')) c2 = +(CHAR)(+(BYTE)c2 | 0x20);
    IF (c1 != c2) {ok = +FALSE; BREAK; }; //символ не совпал или одна из строк кончилась
    //IF (c1 == '\0') BREAK; //обе строки кончились
    //IF (c2 == '\0') {result = +FALSE; BREAK; }; //вторая строка рано кончилась
    INC i;
  }UNTIL (c1 == '\0'); //обе строки кончились
  //IF (s2[i/**+_FIRST*/] != '\0') result = +FALSE; //вторая строка не кончилась
  RETURN ok;
}

FUNC UINT hash(PBYTE pstr)
{
VAR UINT hash;
VAR BYTE c;
  hash = 0x0000;
  c = 0x00;
  REPEAT {
    c = c^(+(BYTE)hash);
    hash = hash + hash;
    c = c+(+(BYTE)hash);
    hash = (hash&0xff00) + +(UINT)c;
    c = *(PBYTE)(pstr); //метка в строке заканчивается 0x00
    INC pstr;
  }UNTIL (c == 0x00);
  RETURN hash;
};
