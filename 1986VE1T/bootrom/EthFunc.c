
#ifndef __ETHFUNC_C
#define __ETHFUNC_C

#include "config.h"
#include "ethfunc.h"
#include "opora.h"

extern const uint16_t MyMAC[3];
extern const uint16_t MyIPAddress[2];
/*-----------------------------------------------------
*------------------------------------------------------
*------------------------------------------------------
*--------------- Функции контроллра PHY ---------------
*------------------------------------------------------
*------------------------------------------------------
------------------------------------------------------*/


//*** Функция для конфигурирования PHY модуля через MDIO интерфейс ***
//Addr - адрес модуля PHY
//Mode - режим работы контроллера PHY
void PHYInit(uint8_t Addr, uint8_t Mode)
{
                uint32_t tmp;

                tmp = ETHERNET->PHY_CTRL;
                tmp &= 0x0770;  //сбросили поля адреса PHY, режима работы по умолчанию, режим FiberOptic
                tmp |= (Addr<<11)|(Mode<<1)|1;

                ETHERNET->PHY_CTRL=tmp;
                while((ETHERNET->PHY_STATUS&0x10)==0);  //ждем пока модуль в состоянии сброса
}

//*** Функция для записи регистров PHY модуля через MDIO интерфейс ***
//Addr  - адрес модуля PHY
//Num   - номер регистра, куда будем записывать данные
//Data  - данные для записи
void SetPHYReg(uint8_t Addr, uint8_t Num, uint16_t Data)
{
        uint32_t i;
        ETHERNET->MDIO_DATA=Data;
        i=0xC000|((Addr&0x1F)<<8)|(Num&0x1F)|(0x01<<5);
        ETHERNET->MDIO_CTRL=(uint16_t)i;
        while((ETHERNET->MDIO_CTRL&0x8000)==0);
}

//*** Функция для чтения регистров PHY модуля через MDIO интерфейс ***
//Addr  - адрес модуля PHY
//Num   - номер регистра, который необходимо прочитать
//возвращает значение регистра по адресу Num в Addr модуле PHY.
uint16_t GetPHYReg(uint8_t Addr, uint8_t Num)
{
        uint32_t i;
        i=0xE000|((Addr&0x1F)<<8)|(0x1<<5)|(Num&0x1F);
        ETHERNET->MDIO_CTRL=(uint16_t)i;
        while((ETHERNET->MDIO_CTRL&0x8000)==0);
        return  ETHERNET->MDIO_DATA;
}

/*-----------------------------------------------------
*------------------------------------------------------
*------------------------------------------------------
*--------------- Функции контроллра MAC ---------------
*------------------------------------------------------
*------------------------------------------------------
-----------------------------------------------------*/
//*** Функция для конфигурирования MAC модуля ***
void EthernetConfig()
{
        PHYInit(0x1C,3);        //PHY address 0x1C, Mode 100BaseT_Full_Duplex

        ETHERNET->MAC_T=MyMAC[0];
        ETHERNET->MAC_M=MyMAC[1];
        ETHERNET->MAC_H=MyMAC[2];

        MACReset();
        ETHERNET->IMR=0x0101;   //разрешение прерываний при успешном приеме пакета
}

//*** Функция для конфигурирования MAC модуля с исходными значениями регистров ***
void MACReset()
{
        ETHERNET->G_CFG|=0x00030000;    //RRST=1, XRST=1 сброс приемника и передатчика

        ClearMemory();

        ETHERNET->Delimiter=0x1000;     //4096 байт буфер передатчика, 4096 байт буфер приемника

        ETHERNET->HASH0=0;
        ETHERNET->HASH1=0;
        ETHERNET->HASH2=0;
        ETHERNET->HASH3=0x8000;

        ETHERNET->IPG=0x0060;
        ETHERNET->PSC=0x0050;
        ETHERNET->BAG=0x0200;
        ETHERNET->JitterWnd=0x0005;
        ETHERNET->R_CFG=0x8406;
        ETHERNET->X_CFG=0x81FA;

        ETHERNET->G_CFG=0x30030080;     //линейный режим работы буферов.

        ETHERNET->IMR=0;
        ETHERNET->IFR=0xFFFF;

        ETHERNET->R_Head=0x0000;
        ETHERNET->X_Tail=0x1000;

        ETHERNET->G_CFG&=0xFFFCBFFF;    //RRST=0, XRST=0 штатный режим работы
}

//*** Функция для очистки буферов приемника и передатчика MAC модуля ***
//Буфер приемника 4096 байт
//Буфер передатчика 4096 байт
void ClearMemory()
{
        uint32_t Temp;
        uint32_t *ptr;
        ptr=(uint32_t*)0x38000000;
        for(Temp=0;Temp<2048;Temp++)    *ptr++=0;
}



/*---------------------------------------------------------------------------------------------------
*--------------- Функции для работы с буферами приемника и передатчика контроллра MAC ---------------
---------------------------------------------------------------------------------------------------*/
//*** Функция для считывания пакета из буфера приемника ***
//*** *Frame - указтель на структуру пакета
uint32_t ReadPacket(_Rec_Frame* Frame)
{
        uint16_t space_start=0;
        uint16_t space_end=0;
        uint16_t tail;
        uint16_t head;
        uint32_t *src, *dst;
        uint32_t size, i;
        uint16_t tmp[2];

        tail=ETHERNET->R_Tail;
        head=ETHERNET->R_Head;

        if(tail>head)
        {
                space_end=tail-head;
                space_start=0;
        }
        else
        {
                space_end=0x1000-head;
                space_start=tail;
        }

        src=(uint32_t*)(0x38000000+head);
        dst=(uint32_t*)(Frame->Data);

        *((uint32_t*)tmp)=*src++;       //прочитали кол-во байт в полученном пакете
        space_end-=4;
        if((uint16_t)src>0xFFF) src=(uint32_t*)0x38000000;

        size=(tmp[0]+3)/4;
        if(tmp[0]<=space_end)
        {
                for(i=0;i<size;i++)
                        *dst++ = *src++;
        }
        else
        {
                size=size-space_end/4;
                for(i=0; i<(space_end/4); i++)
                        *dst++ = *src++;
                src=(uint32_t*)0x38000000;
                for(i=0; i<size; i++)
                        *dst++ = *src++;
        }
        if((uint16_t)src>0xFFF) src=(uint32_t*)0x38000000;

        ETHERNET->R_Head=(uint16_t)src;
        ETHERNET->STAT-=0x20;
        return tmp[0];
}

//*** Функция для записи пакета в буфер передатчика ***
//*** *buffer - указтель на буфер данных
//*** size - кол-во отправляемых байт
int     SendPacket(void* buffer, int size)
{
        uint16_t i;
        uint32_t tmp, head, tail;
        uint32_t *src, *dst;
        uint16_t space[2];

        head = ETHERNET->X_Head;
        tail = ETHERNET->X_Tail;

        //вычисляем кол-во свободного места в буфере передатчика
        if(head>tail)
        {
                space[0]=head-tail;
                space[1]=0;
        } else
        {
                space[0]=0x2000-tail;
                space[1]=head-0x1000;
        }
        //вычислили кол-во свободного места в буфере передатчика

        if(size>(space[0]+space[1]-8))  return 0;       //-8, так как 4 байта занимает поле длины данных и 4 байта занимает поле статуса пакета

        tmp=size;
        src=buffer;
        dst=(uint32_t*)(0x38000000+tail);

        *dst++ =tmp;
        space[0]-=4;
        if((uint16_t)dst>0x1FFC)        dst=(uint32_t*)0x38001000;

        tmp=(size+3)/4;

        if(size<=space[0])
        {
                for(i=0; i<tmp; i++)
                        *dst++ = *src++;
        }
        else
        {
                tmp-=space[0]/4;
                for(i=0;i<(space[0]/4);i++)
                        *dst++ = *src++;
                dst=(uint32_t*)0x38001000;
                for(i=0;i<tmp;i++)
                        *dst++ = *src++;
        }
        if((uint16_t)dst>0x1FFC)        dst=(uint32_t*)0x38001000;
        tmp=0;
        *dst++ =tmp;
        if((uint16_t)dst>0x1FFC)        dst=(uint32_t*)0x38001000;

        ETHERNET->X_Tail=(uint16_t)dst;
        return  size;
}


#endif  //__ETHFUNC_C

