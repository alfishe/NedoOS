#ifndef TTY_H
#define TTY_H
unsigned int ttygetkey(void);
unsigned int ttygetkey_ne(void);
int ttyputchar(int ch);
void putf(int ch);
void putcsi(char ch);
#endif