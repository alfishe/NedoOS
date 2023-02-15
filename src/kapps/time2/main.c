#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <socket.h>
#include <intrz80.h>

int GMT=3;
no_init unsigned char 	is_atm;
no_init unsigned char netbuf[4*1024];
no_init struct sockaddr_in ntp_ia;
union {unsigned long ul;unsigned char b[4];} secsUnix;
unsigned int hour, minute, second, day, month, year, weekday;
SOCKET s=0;
unsigned char inet=0;
const unsigned char monthDays[12] = 
		{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
const unsigned char ntpnead[48] =
		{0xdb, 0x00, 0x11, 0xfa, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0xfe,};
unsigned char * defntp = "2.ru.pool.ntp.org";
const unsigned char regaddr_ve[16]={0x10,0,0x50,0,0x90,0,0,0x12,0x52,0x92,0,0,0,0,0,0};

const unsigned char help[] = "\
-H help\r\n\
-T set time(-T17:59:38)\r\n\
-D set date(-D21-06-2019)\r\n\
-N ntp-server default: -N2.ru.pool.ntp.org\r\n\
-Z time-zone default: -Z3\r\n\
-i get datetime from internet";

extern void dns_resolve(void);

void exit(int e){
	if(s)closesocket(s,0);
	if(e!=0) {
		puts((char*)e);
		//puts("Press any key");
		//getchar();
	}
	((void(*)(int))0x0000)(e);
}

extern void dns_resolve(void);

/*
void delay(unsigned long counter)
{
  unsigned long start, finish;
  counter = counter / 20;
  if (counter < 1)
  {
    counter = 1;
  }
  start = time();
  finish = start + counter;

  while (start < finish)
  {
    start = time();
  }
}
*/


unsigned char readcmos(unsigned char r) {
    disable_interrupt();
    if(is_atm == 2 || is_atm == 3){
        r = regaddr_ve[r];
        if(r != 0){
            input(0x55FE);
            r = input((r << 8) | 0x00fe);
        }
    }else{
        output(0xdef7,r);
        r = input(0xbef7);
    }
    enable_interrupt();
    return r;

}

void writecmos(unsigned char r,unsigned char v) {
    disable_interrupt();
    if(is_atm == 2 || is_atm == 3){
        r = regaddr_ve[r] +1; 		// На запись порт + 1
        if(r != 0){
		input(0x55FE);	
		input((r << 8) | 0x00fe);
		input((v << 8) | 0x00fe);	
		}
    }else{
        output(0xdef7,r);
        r = input(0xbef7);
    }
    enable_interrupt();
}

void Unix_to_GMT(void)
{
 // корректировка часового пояса и синхронизация 
  unsigned char monthLength=0;
  int days=0;
  secsUnix.ul = secsUnix.ul + GMT * 3600;     

  second=secsUnix.ul%60;
  secsUnix.ul/=60; // now it is minutes
  minute=secsUnix.ul%60;
  secsUnix.ul/=60; // now it is hours
  hour=secsUnix.ul%24;
  secsUnix.ul/=24; // now it is days
  weekday=(secsUnix.ul+4)%7; // day week, 0-sunday
  year=70; 
  while(days + ((year % 4) ? 365 : 366) <= secsUnix.ul) {
     days += (year % 4) ? 365 : 366;
     year++;
  }
  secsUnix.ul -= days; // now it is days in this year, starting at 0
 
  days=0;
  month=0;
  for (month=0; month<12; month++) {
    if (month==1) { // february
      if (year%4) monthLength=28;
      else monthLength=29;
    }
    else monthLength = monthDays[month];
    if (secsUnix.ul>=monthLength) secsUnix.ul-=monthLength;
    else break;   
  }
  month++;       // jan is month 1
  day=secsUnix.ul+1;  // day of month
} 
void ntp_resolver(void){
	unsigned char i,j;
	signed char res;
	int len;
	ntp_ia.sin_port=123<<8;
	ntp_ia.sin_addr=*dns_resolver((void*)defntp);
	if(!ntp_ia.sin_addr.S_un.S_addr) exit((int)"error: domain name not resolved");			
	i=100;
inetloop:
	YIELD();
	i--;
	if(i==0){
		exit((int)"inet error");
	}
	s=socket(AF_INET,SOCK_DGRAM,0);
	if(s<0){
		s=0;
		goto inetloop;
	}
	memcpy(netbuf,ntpnead,sizeof(ntpnead));
	/*res=connect(s, &ntp_ia, sizeof(ntp_ia));
	if(res<0){
		closesocket(s,0);
		s=0;
		goto inetloop;
	}*/
	len=sendto(s,netbuf,48, 0, &ntp_ia, sizeof(ntp_ia));
	if(res<0){
		closesocket(s,0);
		s=0;
		goto inetloop;
	}
	j=50;
	while(j){
		j--;
		len=recvfrom(s,netbuf,sizeof(netbuf), 0, &ntp_ia, sizeof(ntp_ia));
		if(len<0){
			YIELD();
			continue;
		}
		break;
	}
	
	closesocket(s,0);
	s=0;
	if(len<=0){
	exit((int)"server error");
	}
	secsUnix.b[3] = netbuf[40];
	secsUnix.b[2] = netbuf[41];
	secsUnix.b[1] = netbuf[42];
	secsUnix.b[0] = netbuf[43];
	secsUnix.ul-=2208988800UL;
	Unix_to_GMT();
}

void set_datetime(void){

	writecmos(0x0b,readcmos(0x0b)|6);
	writecmos(0x07,day);
	writecmos(0x08,month);
	writecmos(0x09,year-100);
	writecmos(0x00,second);
	writecmos(0x02,minute);
	writecmos(0x04,hour);
}
void get_datetime(void)
{
	writecmos(0x0b,readcmos(0x0b)|6);
	second		= readcmos(0x00);
	minute		= readcmos(0x02);
	hour		= readcmos(0x04);
	weekday		= readcmos(0x06)-1;
	day			= readcmos(0x07);
	month		= readcmos(0x08);
	year		= readcmos(0x09)+100;	
}

C_task main (int argc, char *argv[]) 
{
	unsigned char i=1;
	os_initstdio();
	is_atm = (unsigned char)OS_GETCONFIG();

	if(argc==1) {
		get_datetime();
		puts(help);
	}
	while(i!=argc){
		char * p=argv[i];
		if(p[0]!='-') exit((int)"Wrong parameter. Use -H for help");
		switch (p[1]&0xdf){
			case 'T':
				get_datetime();
				if(sscanf(p+2,"%d:%d:%d",&hour,&minute,&second)==3){
					disable_interrupt();
					set_datetime();
					enable_interrupt();
				}
				break;
			case 'D':
				get_datetime();
				if(sscanf(p+2,"%d-%d-%d",&day,&month,&year)==3){
					disable_interrupt();
					year-=1900;
					set_datetime();
					enable_interrupt();
				}
				break;
			case 'N':
				defntp=p+2;
				break;
			case 'Z':
				if(sscanf(p+2,"%d",&GMT)!=1){
					GMT=3;
				}
				break;
			case 'H':
				exit((int)help);
				break;
			case 'I':
				inet=1;
				break;
			default:
				exit((int)"Wrong parameter. Use -H for help");
		}
		i++;
	}
	if(inet){
		ntp_resolver();
		set_datetime();
		writecmos(0x06,weekday+1);
	}
	puts("Now time:");
	printf("%02u-%02u-%04u ",day,month,year+1900);
	printf("%02u:%02u:%02u\r\n",hour,minute,second);
	exit(0);
	return 0;
}   
