
#include "config.h"
#include "ethfunc.h"
#include "RamFunctions.h"
#include "opora.h"

const uint16_t MyMAC[3]={0x3412,0x7856,0xBC9A}; //MAC-адрес контроллера
/*const*/ uint16_t MyIPAddress[2]={0xA8C0,0x5701}; //IP-адрес: 192.168.1.87

_Rec_Frame Frame;
uint32_t Time_old,Time_new,Time_delta;
uint16_t Counter;

//typedef struct
  union
  {
    uint8_t    buffer8[1600];
    uint16_t   buffer[800];
    uint32_t   buffer32[400];
  }  outbuf;

// uint16_t buffer[800];

void Answear_ARP(void);
void PacketAnaliser(void);
uint16_t CheckSum_IP(void);
uint16_t CheckSum_ICMP(uint16_t);
void Answear_ICMP(void);
void Answear_UDP(void);
void Request_ARP(void);
void SysTickInit(void);

void /*int*/ main()
{
        ClkConfig();
        EthernetConfig();
        PortConfig();
        SysTickInit(); // инициализация системного таймера

        WriteDataToRAM(0x60000000,0);

        if (TestData(0x60000000,0)) {
                //PORTD->SETTX=1<<7;      //тест успешно завершен!
        }else {
                MyIPAddress[1]=0x5601; //PORTD->SETTX=1<<8;      //тест завершился с ошибкой!
        }
//loop:
        WriteDataToRAM(0x60000000,1);

        if(TestData(0x60000000,1)) {
                //PORTD->SETTX=1<<9;      //тест успешно завершен!
        }else {
                MyIPAddress[1]=0x5501; //PORTD->SETTX=1<<10;     //тест завершился с ошибкой!
        }
 //goto loop;
        NVIC_EnableIRQ(ETHERNET_IRQn);
        while(1)
        {
                if((ETHERNET->PHY_STATUS&0x02)==0x00)   PORTB->SETTX=1<<15;             //отображение сигнала LINK
                else                                                                    PORTB->CLRTX=1<<15;

                if((ETHERNET->PHY_STATUS&0x08)==0x00)   PORTB->SETTX=1<<14;             //Full Duplex Mode
                else                                                                    PORTB->CLRTX=1<<14;
        }
                //Time_old=0x00FFFFFF;
}

void ETHERNET_Handler()
{
        uint16_t Status;

        Status=ETHERNET->IFR;
        ETHERNET->IFR=Status;
        Status&=0x101;
        PORTD->RXTX^=(1<<9);
        if((Status&0x01)==0x01)
        {
                PORTD->SETTX=1<<7;
                Counter=ReadPacket(&Frame);
                PacketAnaliser();
                PORTD->CLRTX=1<<7;
        }
}

//*** Функция разбора полученного пакета
void PacketAnaliser(void)
{
        switch(Frame.Data[6])  //определяем тип следующего протокола
    {
        case 0x0008:       //протокол IP
                if((Frame.Data[15]==MyIPAddress[0])&&(Frame.Data[16]==MyIPAddress[1]))  //сравниваем IP адреса в пакете с нашим
            {                                                                                 //если они совпадают, то занимаемся разбором пакета дальше,
                if(CheckSum_IP()==Frame.Data[12])   //если контрольные суммы пакета и вычисленная совпадают, продолжаем
                {                                                           //иначе - отбрасываем пакет
                                        //--------------------UDP-------------------
                        if((Frame.Data[11]&0xFF00)==0x1100)     //определили следующий протокол: UDP
                    {
                                                        PORTD->SETTX=1<<8;
                                Answear_UDP();       //отправили ответ на запрос Echo (ping) request
                                                        PORTD->CLRTX=1<<8;
                    }
                                        //--------------------ICMP-------------------
                        if((Frame.Data[11]&0xFF00)==0x0100)     //определили следующий протокол: ICMP
                    {
                        if(Frame.Data[17]==0x0008)        //определили тип - Echo (ping) request
                                                {
                                                        PORTD->SETTX=1<<8;
                                Answear_ICMP();       //отправили ответ на запрос Echo (ping) request
                                                        PORTD->CLRTX=1<<8;
                                                }
                    }
                }
                //-------------------------------------------
            }
            break;
                case 0x0608:      //протокол ARP
                if((Frame.Data[19]==MyIPAddress[0])&&(Frame.Data[20]==MyIPAddress[1]))  //сравниваем IP адреса в пакете с нашим
            {                                                                                 //если они совпадают, то занимаемся разбором пакета дальше,
                Answear_ARP();  //отправили ответ на ARP-запрос
            }
            break;
        }
}

//*** Функция формирования ответа на ARP-запрос
void Answear_ARP(void)
{
        uint16_t Buf[22];
        Buf[0]=Frame.Data[3];           //MAC-адрес источника
        Buf[1]=Frame.Data[4];           //MAC-адрес источника
        Buf[2]=Frame.Data[5];           //MAC-адрес источника
        Buf[3]=ETHERNET->MAC_T;         //наш MAC-адрес
        Buf[4]=ETHERNET->MAC_M;         //наш MAC-адрес
        Buf[5]=ETHERNET->MAC_H;         //наш MAC-адрес
        Buf[6]=Frame.Data[6];           //type - ARP
        Buf[7]=Frame.Data[7];           //Hardware type - Ethernet
        Buf[8]=Frame.Data[8];           //Protocol type - IP
        Buf[9]=Frame.Data[9];           //Hardware size - 6; Protocol size - 4
        Buf[10]=0x0200;                 //код ответа на запрос Who has...
        Buf[11]=ETHERNET->MAC_T;        //Sender MAC-address: 0A.1B.2C.3D.4E.5F
        Buf[12]=ETHERNET->MAC_M;        //Sender MAC-address: 0A.1B.2C.3D.4E.5F
        Buf[13]=ETHERNET->MAC_H;        //Sender MAC-address: 0A.1B.2C.3D.4E.5F
        Buf[14]=MyIPAddress[0];                 //My_IP_Address[0];    //Sender IP-address: 192.168.1.87
        Buf[15]=MyIPAddress[1];                 //My_IP_Address[1];    //Sender IP-address: 192.168.1.87
        Buf[16]=Frame.Data[3];          //Target MAC-address
        Buf[17]=Frame.Data[4];          //Target MAC-address
        Buf[18]=Frame.Data[5];          //Target MAC-address
        Buf[19]=Frame.Data[14];         //Target IP-address
        Buf[20]=Frame.Data[15];         //Target IP-address
        Buf[21]=0;

        SendPacket(Buf,42);
}

//*** Функция для подсчета контрольной суммы пакета IP-протокола
uint16_t CheckSum_IP(void)
{
        unsigned long cs=0;
        cs = cs + Frame.Data[7];
        cs = cs + Frame.Data[8];
        cs = cs + Frame.Data[9];
        cs = cs + Frame.Data[10];
        cs = cs + Frame.Data[11];
        cs = cs + Frame.Data[13];
        cs = cs + Frame.Data[14];
        cs = cs + Frame.Data[15];
        cs = cs + Frame.Data[16];
        cs = (cs >> 16) + (cs & 0xFFFF);
        return (uint16_t)(~cs);
}

//*** Функция для подсчета контрольной суммы пакета ICMP-протокола
//*** size - кол-во слов, по которому необходимо посчитать контрольную сумму
uint16_t CheckSum_ICMP(uint16_t size)
{
        unsigned long a, cs=0;
        for(a=0;a<size;a++)
        {
                if(a==1) continue;
                else cs+=Frame.Data[a+17];
        }
        cs=(cs>>16)+(cs&0xFFFF);
        return (uint16_t)(~cs);
}

//*** Функция для формирования ответа на запрос ICMP
void Answear_ICMP(void)
{
    unsigned long a;
        uint16_t buffer[288];
        uint16_t tmp;

        //Кол-во байт в ICMP-пакете
        tmp=Counter-34-4; //34 байта - заголовок Eth2 и IP пакетов, 4 байта - контрольная сумма Eth2 пакета.
        if((tmp&0x01)==1)
        {
                tmp=(tmp+1)>>1; //из кол-ва байт получили кол-во слов
                Frame.Data[tmp+16]=Frame.Data[tmp+16]&0x00FF;
        }
        else                            tmp=tmp>>1;             //из кол-ва байт получили кол-во слов

        //-------Ethernet 2 Protocol---------
    buffer[0]=Frame.Data[3];
    buffer[1]=Frame.Data[4];
    buffer[2]=Frame.Data[5];

        buffer[3]=ETHERNET->MAC_T;
        buffer[4]=ETHERNET->MAC_M;
        buffer[5]=ETHERNET->MAC_H;

        buffer[6]=Frame.Data[6];
    //-------IP Protocol---------
    for(a=7;a<12;a++)
        {
            buffer[a]= Frame.Data[a];
    }
    //---------------------------
    buffer[12]=CheckSum_IP();
        buffer[13]=Frame.Data[15];//IP->DestinAddr[0];
        buffer[14]=Frame.Data[16];//IP->DestinAddr[1];
        buffer[15]=Frame.Data[13];//IP->SourceAddr[0];
        buffer[16]=Frame.Data[14];//IP->SourceAddr[1];
        //-------ICMP Protocol---------
        buffer[17]=0x0000; //ответ
    Frame.Data[17]=0x0000;
        //-----------------------------
        buffer[18]=CheckSum_ICMP(tmp);
    for(a=19;a<((tmp-2)+19);a++)
        {
        buffer[a]=Frame.Data[a];
        }
        SendPacket(buffer,(tmp*2+34));
}

/*
   Пакет команды
   *************
................................. MAC заголовок
байт 1  - MAC адрес получателя (микроконтроллер) ст.байт
байт 2  -   -"-                              ср.байт
байт 3  -   -"-                              ср.байт
байт 4  -   -"-                              ср.байт
байт 5  -   -"-                              ср.байт
байт 6  -   -"-                              мл.байт
байт 7  - MAC адрес отправителя (ПЭВМ)       ст.байт
байт 8  -   -"-                              ср.байт
байт 9  -   -"-                              ср.байт
байт 10 -   -"-                              ср.байт
байт 11 -   -"-                              ср.байт
байт 12 -   -"-                              мл.байт
байт 13 - протокол IP  (800h)                ст.байт
байт 14 -   -"-                              мл.байт
................................. IP заголовок
байт 15 - версия 4, длина заголовка 5 слов  (45h)
байт 16 - тип службы  (0)
байт 17 - общая длина в байтах               ст.байт
байт 18 -   -"-                              мл.байт
байт 19 - идентификатор                      ст.байт
байт 20 -   -"-                              мл.байт
байт 21 - флаги (0)
байт 22 - смещение фрагмента (0)
байт 23 - срок жизни
байт 24 - протокол UDP  (11h)
байт 25 - контрольная сумма IP заголовка     ст.байт
байт 26 -   -"-                              мл.байт
байт 27 - IP адрес отправителя               ст.байт
байт 28 -   -"-                              ср.байт
байт 29 -   -"-                              ср.байт
байт 30 -   -"-                              мл.байт
байт 31 - IP адрес получателя                ст.байт
байт 32 -   -"-                              ср.байт
байт 33 -   -"-                              ср.байт
байт 34 -   -"-                              мл.байт
................................. UDP заголовок
байт 35 - порт отправителя                   ст.байт
байт 36 -   -"-                              мл.байт
байт 37 - порт получателя                    ст.байт
байт 38 -   -"-                              мл.байт
байт 39 - длина дейтаграммы UDP              ст.байт
байт 40 -   -"-                              мл.байт
байт 41 - контрольная сумма                  ст.байт
байт 42 -   -"-                              мл.байт
................................. заголовок команды
байт 43 - номер цикла                        ст.байт
байт 44 -   -"-                              мл.байт
байт 45 - длина буфера текущего состояния (дв.слов)
             0 - буфер не выдаётся
байт 46 - код операции команды
................................. данные команды
   ...
...................................................
байт N-(N+3) - контрольная сумма MAC пакета
*/
/*
int writetoarm(unsigned int addr,byte* mas,int bytes_in_line)
{
int i;
byte msg[300];
 cycle++;
        msg[0]=cycle>>8;
        msg[1]=cycle;
        msg[2]=0; //длина буфера текущего состояния
        msg[3]=0x04;
        msg[4]=bytes_in_line>>8;//0x00;
        msg[5]=bytes_in_line;//0x01;
        msg[6]=addr>>24;
        msg[7]=addr>>16;
        msg[8]=addr>>8;
        msg[9]=addr;
for(i=0;i<bytes_in_line;i++) {
        msg[10+i]=mas[i];
};
        call_dunin(msg,10+bytes_in_line);
        read_dunin(msg,10);
        addr++;
return(0);
}
*/
/*
2.1.1. Загрузить массив в ЗУ по байтам
......................................
    байт46 - 004h
    байт47-48 - количество байт (сетевой порядок байт)
    байт49-52 - адрес (сетевой порядок байт)
    байт53    - мл.байт массива
    ...
    байтN     - ст.байт массива
Данные ответного сообщения:
              - отсутствуют
С заданного адреса ЗУ загружается заданное
количество байт.
*/
/*
Выполнить программу по заданному адресу
    байт46 - 0f0h
    байт47-50 - адрес (сетевой порядок байт)
Данные ответного сообщения:
              - отсутствуют
запускается программа с заданным адресом, затем выдаётся ответное сообщение
*/
//нумерация с 1, т.е. надо вычитать 1

//*** Функция для формирования ответа на запрос UDP
void Answear_UDP(void)
{
unsigned long a,b, cs=0;
uint16_t tmp;
int i, n;
unsigned char * framebytes = (unsigned char *)Frame.Data;
uint32_t addr;

        if (framebytes[45]==0x04) {
                n = (framebytes[46]<<8) + framebytes[47];
                addr = (framebytes[48]<<24) + (framebytes[49]<<16) + (framebytes[50]<<8) + framebytes[51];
                for(i=0; i<n; i++) {
                        WriteByteToRAM(addr+i, framebytes[52+i]);
                };
        };
        if (framebytes[45]==0xf0) {
                //addr = 0x50000000;
                //addr = 0x20002000;
                addr = (framebytes[46]<<24) + (framebytes[47]<<16) + (framebytes[48]<<8) + framebytes[49];
                CallRAM(addr);
        };

//                uint32_t *buf32, *buf321;
                Time_new=SysTick->VAL&0x00FFFFFF; // чтение текущего системного времени
                if((SysTick->CTRL&0x10000)==0x10000)
                {
                        Time_delta=(0x00FFFFFF+Time_old-Time_new);
                }
                else
                {
                        Time_delta=(Time_old-Time_new);
                };
                outbuf.buffer[21]=(uint16_t)((Time_delta&0xFFFF0000)>>16); // период обмена в тактах - старшие байты
                outbuf.buffer[22]=(uint16_t)(Time_delta&0x0000FFFF); // период обмена в тактах - младшие байты
                Time_old=Time_new;
        //Кол-во байт в ICMP-пакете
        tmp=Counter-34-4; //34 байта - заголовок Eth2 и IP пакетов, 4 байта - контрольная сумма Eth2 пакета.
        if((tmp&0x01)==1) // если нечётное кол-во байт
        {
                tmp=(tmp+1)>>1; //из кол-ва байт получили кол-во слов в UDP-пакете
                Frame.Data[tmp+16]=Frame.Data[tmp+16]&0x00FF; // обрезаем наполовину слово содержащее последний байт
        }
        else                            tmp=tmp>>1;             //из кол-ва байт получили кол-во слов в UDP-пакете

        //-------Ethernet 2 Protocol---------
        outbuf.buffer[0]=Frame.Data[3];
        outbuf.buffer[1]=Frame.Data[4];
        outbuf.buffer[2]=Frame.Data[5];

        outbuf.buffer[3]=ETHERNET->MAC_T;
        outbuf.buffer[4]=ETHERNET->MAC_M;
        outbuf.buffer[5]=ETHERNET->MAC_H;

        outbuf.buffer[6]=Frame.Data[6];
    //-------IP Protocol---------
        outbuf.buffer[7]=Frame.Data[7];
        outbuf.buffer[8]=Frame.Data[8];
        outbuf.buffer[9]=Frame.Data[9];
        outbuf.buffer[10]=Frame.Data[10];
        outbuf.buffer[11]=Frame.Data[11];
        outbuf.buffer[13]=Frame.Data[15];//IP->DestinAddr[0];
        outbuf.buffer[14]=Frame.Data[16];//IP->DestinAddr[1];
        outbuf.buffer[15]=Frame.Data[13];//IP->SourceAddr[0];
        outbuf.buffer[16]=Frame.Data[14];//IP->SourceAddr[1];
    //-----------Подсчет контрольной суммы пакета IP-протокола----------------
                cs = cs + outbuf.buffer[7];
                cs = cs + outbuf.buffer[8];
                cs = cs + outbuf.buffer[9];
                cs = cs + outbuf.buffer[10];
                cs = cs + outbuf.buffer[11];
                cs = cs + outbuf.buffer[13];
                cs = cs + outbuf.buffer[14];
                cs = cs + outbuf.buffer[15];
                cs = cs + outbuf.buffer[16];
        cs = (cs >> 16) + (cs & 0xFFFF);
        outbuf.buffer[12]=(uint16_t)(~cs);
//              outbuf.buffer[12]=CheckSum_IP();
        //-------UDP Protocol---------
        outbuf.buffer[17]=Frame.Data[18];//Порт отправителя
        outbuf.buffer[18]=Frame.Data[17];//Порт получателя
        outbuf.buffer[19]=Frame.Data[19];//Длинна UDP
        outbuf.buffer[20]=0x0000; // контрольная сумма
        //-----------------------------
        // outbuf.buffer[18]=CheckSum_ICMP(tmp);
                tmp=tmp+17; // суммарная длина в словах
//                buf321=(uint32_t*)(Frame.Data[25]);
//                buf32=(uint32_t*)(outbuf.buffer[25]);
        outbuf.buffer[25]=Frame.Data[25];
                b=tmp/2;
    for(a=13;a<b;a++) // переписать все данные
        {
        outbuf.buffer32[a]=Frame.Data32[a];
        a++;
        outbuf.buffer32[a]=Frame.Data32[a];
        a++;
        outbuf.buffer32[a]=Frame.Data32[a];
        a++;
        outbuf.buffer32[a]=Frame.Data32[a];
        };
//         /*{
//        buf321=(uint32_t*)(Frame.Data[a]);
//       buf32=(uint32_t*)(outbuf.buffer[a]);
//        *(buf32)=(uint32_t)a;//*(buf321);
//        a++;
//        *(buf32++)=*(buf321++);
//        a++;
//        *(buf32++)=*(buf321++);
//        a++;
//        *(buf32++)=*(buf321++);
//        }
//      for(a=25;a<tmp;a++)
//        {
//        outbuf.buffer[a]=Frame.Data[a];
//        a++;
//        outbuf.buffer[a]=Frame.Data[a];
//        a++;
//        outbuf.buffer[a]=Frame.Data[a];
//        a++;
//        outbuf.buffer[a]=Frame.Data[a];
//        }  */
                Time_new=SysTick->VAL&0x00FFFFFF; // чтение текущего системного времени
                if((SysTick->CTRL&0x10000)==0x10000)
                {
                        Time_delta=(0x00FFFFFF+Time_old-Time_new);
                }
                else
                {
                        Time_delta=(Time_old-Time_new);
                };
                outbuf.buffer[23]=(uint16_t)((Time_delta&0xFFFF0000)>>16); // кол-во тактов, затраченных на вычисления - старшие байты
                outbuf.buffer[24]=(uint16_t)(Time_delta&0x0000FFFF); // кол-во тактов, затраченных на вычисления - младшие байты
        SendPacket(outbuf.buffer,(tmp*2));
}

//--- System Timer initialization ---
void SysTickInit() // инициализация системного таймера
{
        SysTick->LOAD = 0x00FFFFFF;     //Pause 177 ms (HCLK = 96MHz)
        SysTick->CTRL = 0x00000001;     //Enabel SysTick
}
