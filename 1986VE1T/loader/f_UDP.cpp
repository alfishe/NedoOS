// Пакет функций обмена данными по UDP

//---------------------------------------------------------------------------
#include <vcl.h>
#include <stdio.h>
#include <NMUDP.hpp>

//---------------------------------------------------------------------------
extern unsigned char BufEth[2000];
extern int kolEth;
int proshUDP;

//---------------------------------------------------------------------------
class TMyUDP:public TObject
{
__published:
        TNMUDP *NMUDP1;
        TNMUDP *NMUDP2;
        void __fastcall NMUDP1DataSend(TObject *Sender);
        void __fastcall NMUDP2DataReceived(TComponent *Sender,
          int NumberBytes, AnsiString FromIP, int Port);
public:		// User declarations
    __fastcall TMyUDP();
};

//---------------------------------------------------------------------------
//Конструктор
__fastcall TMyUDP::TMyUDP()
{
    NMUDP1=new TNMUDP(NULL);
    NMUDP2=new TNMUDP(NULL);
    NMUDP1->OnDataSend=NMUDP1DataSend;
    NMUDP2->OnDataReceived=NMUDP2DataReceived;
}

//---------------------------------------------------------------------------
TMyUDP *MyUDP;
//---------------------------------------------------------------------------
//Создать объект
void ObUDP()
{
  proshUDP=1;
  MyUDP=new TMyUDP();     // создать объект
}

//---------------------------------------------------------------------------
//Передать данные (UDP сокет)
void PeredUDP(AnsiString adr,int nport)
//   adr   - адрес сети Ethernet для БУ
//   nport - номер порта
{
  MyUDP->NMUDP1->RemoteHost = adr;
  MyUDP->NMUDP1->ReportLevel = Status_Basic;
  MyUDP->NMUDP1->RemotePort = nport;
  MyUDP->NMUDP1->SendBuffer(BufEth,kolEth,kolEth);   // передать байты
}

//---------------------------------------------------------------------------
// Данные получены (UDP сокет)
void __fastcall TMyUDP::NMUDP2DataReceived(TComponent *Sender,
      int NumberBytes, AnsiString FromIP, int Port)
{
  if (NumberBytes<2000)
    {
    int j;
    NMUDP2->ReadBuffer(BufEth, kolEth, j); //прочитать байты
    proshUDP=0;
    }
  else
    proshUDP=1;
}

//---------------------------------------------------------------------------
// Данные переданы (UDP сокет)
void __fastcall TMyUDP::NMUDP1DataSend(TObject *Sender)
{
    proshUDP=0;
}

//---------------------------------------------------------------------------
//Удалить объект
void DelUDP()
{
   delete MyUDP;
}
//---------------------------------------------------------------------------

