
#ifndef __CONFIG_H
#define __CONFIG_H

#define REVISION_2

#define HSE2_OSCILLATOR

//typedef struct
//{
//        unsigned short Data[800];       //1600 байт
//        unsigned short Counter;         //счетчик кол-ва байт данных в буфере Data
//                unsigned short Status;
//} _Rec_Frame;

typedef union
{
        unsigned char Data8[1600];
        unsigned short Data[800];       //1600 байт
        unsigned int Data32[400];
} _Rec_Frame;

void ClkConfig(void);
void PortConfig(void);

#endif  //__CONFIG_H

