#include <stdio.h>
#include <stdlib.h>
#include <mem.h>
#include <string.h>

#include <vcl.h>
#include <NMHttp.hpp>
#include <NMUDP.hpp>
TNMUDP *NMUDP1;

#define BYTE unsigned char
#define FILESIZE 1048576
#define MAXLINESIZE 16

BYTE filebuf[FILESIZE];

unsigned short cycle;

//Передать данные (UDP сокет)
void __fastcall PeredUDP(AnsiString adr,int nLport,int nRport,unsigned char *Buf,int kol)
//   adr   - адрес сети Ethernet для БУ
//   nport - номер порта
{
    int j=kol;
//  UDP_send=-1;
  NMUDP1->RemoteHost = adr;
  NMUDP1->ReportLevel = 2/*Status_Basic*/;
  NMUDP1->RemotePort = nRport;
  NMUDP1->LocalPort = nLport;
//  kolEthUDP=kol;
  NMUDP1->SendBuffer(Buf,kol,j);   // передать байты
}

int call_armmon(BYTE* msg, int len)
{
 int VZ;
 int i;
 //int b=0xd0;
 //if (len<15) for(i=len;i<15;i++)msg[i]=0x00;
 //fwrite(msg,15,1,fout);
 //fwrite(&b,1,1,fout);
// try {;
// Form1->UDP_read=0;
  PeredUDP("192.168.1.87",39000,39000,msg,len);
// VZ=Form1->UDP_send;
// } catch (const Exception &e) {
// VZ=-1;
// };
 //Form6->Obr_ZO("0555");
 return(VZ);
}
/*
int read_armmon(BYTE* msg, int len)
{
 int VZ,oldVZ,i;
 double begtime,curtime;
 int b=0x0d;
 begtime=Form6->Read_ots_Vrem();
 do {
  Form6->Obr_ZO("0777");
  curtime=Form6->Read_ots_Vrem();
  VZ=Form1->UDP_cycle;
  if(VZ!=oldVZ) { //получено новое сообщение
   oldVZ=VZ;
   for(i=0;i<len;i++) {
    msg[i]=Form1->BufEthUDP[i];
    globmsg[i]=Form1->BufEthUDP[i];
   }
   if (len<15) for(i=len;i<15;i++)msg[i]=0x00;
   fwrite(msg,15,1,fout);
   fwrite(&b,1,1,fout);
   if((byte)(msg[1]&0xff)==(byte)(cycle&0xff))break;
  }
 }while((curtime-begtime)<0.1);
 return(VZ);
}
*/
int writetoarm(unsigned int addr, BYTE* mas, int bytes_in_line)
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
        call_armmon(msg,10+bytes_in_line);
        //read_armmon(msg,10);
        addr++;
return(0);
}

int runprogram(unsigned int addr)
{
byte msg[300];
 cycle++;
        msg[0]=cycle>>8;
        msg[1]=cycle;
        msg[2]=0; //длина буфера текущего состояния
        msg[3]=0xf0; //0x10;
        msg[4]=addr>>24;
        msg[5]=addr>>16;
        msg[6]=addr>>8;
        msg[7]=addr;
//msg[4]=n;
call_armmon(msg,8/*5*/);
//read_armmon(msg,10);
return(0);
}

void loadfile(unsigned int startaddr, char * filename)
{
FILE* file;
int size, wrsize;
unsigned int index;
  file = fopen(filename, "rb");
  if (file) {
    printf("opened file: %s\n",filename);
    size = fread(filebuf, 1, FILESIZE, file);
    fclose(file);

    index = 0;
    while (size > 0) {

      if (size > MAXLINESIZE) {
        wrsize = MAXLINESIZE;
      }else {
        wrsize = size;
      };
      writetoarm(startaddr + index, &filebuf[index], wrsize);
      size = size - wrsize;
      index = index + wrsize;
    };
  }else {
    printf("file not found: %s\n",filename);
  };
}

unsigned int hexatoi(char* s)
{
unsigned int res;
int i;
BYTE c;
  if (s[0] == '0') {
    if (s[1] != 'x') goto nohex;
    res = 0;
    i = 2;
    while (s[i] != '\0') {
      res = res << 4;
      c = (BYTE)s[i];
      if       (c >= (BYTE)'a') {
        c = c - (BYTE)'a' + 10;
      }else if (c >= (BYTE)'A') {
        c = c - (BYTE)'A' + 10;
      }else {
        c = c - (BYTE)'0';
      };
      res = res + c;
      i++;
    };
  }else {
    nohex:
    res = atoi(s);
  };
return res;
}

int main(int argc,char* argv[])
{
int i;
unsigned int startaddr;
char *filename;
  startaddr = 0;//0x20100000;
  filename = "_tokarm.bin";

  if (argc<2) {
    printf(
      "NedoLoader\n"
      "load file(s) at given address(es) and run from given address:\n"
      "\tloader.exe -l 0x60000000 filename.bin -r 0x60000001\n"
    );
  };

  NMUDP1 = new TNMUDP(0);

  cycle = 0;

  for (i=1; i<argc; i++) {
    if       (!strcmp(argv[i],"-l")) { //set load address
      i++;
      startaddr = hexatoi(argv[i]);
    }else if (!strcmp(argv[i],"-r")) { //run from address
      i++;
      startaddr = hexatoi(argv[i]);
      runprogram(startaddr);
    }else {
      filename = argv[i];
      loadfile(startaddr, filename);
    };
  }
/*  i=1;
  while (i<argc) {
    filename = argv[i];
    i++;
    if (i<argc) {
      startaddr = hexatoi(argv[i]);
      i++;
      loadfile(startaddr, filename);
    };
    //startaddr = 0x50000000;
  };

  runprogram(0x20100001);*/
return 0;
}