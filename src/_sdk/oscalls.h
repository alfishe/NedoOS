#ifndef OSCALLS_H
#define OSCALLS_H
void YIELD(void);
void OS_SETGFX(unsigned char mode);
void OS_CLS(unsigned char color);
void OS_SETCOLOR(unsigned char color);
void OS_SETXY(unsigned char x,unsigned char y);
void OS_SCROLLUP(unsigned int xy, unsigned int wh);
unsigned int _low_level_get(void);
unsigned int OS_GETXY(void);
void conv1251to866(unsigned char * bufer);
extern unsigned char t1251to866[128];
extern unsigned char syspath[8];

typedef unsigned int FILE;

typedef struct {
	unsigned char drv; 				/* drive number */
	unsigned char fname[11];
	unsigned char extentnumberlo;
	unsigned char fattrib;
	unsigned char extentnumberhi;
	unsigned char recordcount;
	unsigned long fsize;	
	unsigned int  ftime;	
	unsigned int  ffsfcb;			/* trdosfcb или fil */
	unsigned int  dirpos;			/* прив¤зка к точке поиска */
	unsigned int  reserv;
	unsigned int  recordsize;		/* must be 128 */
	unsigned int  fdate;
	unsigned char frecord;			/*номер записи внутри экстента*/
} FCB;

FILE		 	OS_CREATEHANDLE(unsigned char * path, unsigned char flags);
unsigned int 	OS_WRITEHANDLE(unsigned char * buffer, FILE hnd, unsigned int count);
unsigned int 	OS_READHANDLE(unsigned char * buffer, FILE hnd, unsigned int count);
FILE		 	OS_OPENHANDLE(unsigned char * path, unsigned char flags);
unsigned int 	OS_CLOSEHANDLE(FILE hnd);
unsigned long	OS_GETFILESIZE(FILE hnd);
unsigned char * OS_GETPATH(unsigned char * path);
unsigned char	OS_SETDTA(FCB * fcb);
unsigned char	OS_FSEARCHFIRST(FCB * fcb);
unsigned char	OS_FSEARCHNEXT(FCB * fcb);
unsigned char	OS_CHDIR(const unsigned char * path);
unsigned char	OS_MKDIR(unsigned char * path);
unsigned char	OS_DELETE(unsigned char * path);
void			OS_SETSYSDRV(void);
void exit(int e);
unsigned char scrredraw(void);	//если приложение реагирует на событие redraw, 
								//то необходимо определить свою функцию scrredraw
								//возвращает подмененную кнопку, обычно 0x00

typedef signed char SOCKET;
struct in_addr {
	union {
		struct {unsigned char s_b1; unsigned char s_b2;
			unsigned char s_b3; unsigned char s_b4;} S_un_b;
		struct {unsigned short s_w1; unsigned short s_w2;} S_un_w;
		unsigned long S_addr;
	} S_un;
};

struct sockaddr_in {
        unsigned char   sin_family;
        unsigned short sin_port;
        struct  in_addr sin_addr;
        char    sin_zero[8];
};


SOCKET  OS_NETSOCKET(unsigned int);
#define socket(domain, type, protocol) OS_NETSOCKET((domain<<8)+type)
int OS_NETRECV(unsigned char * buffer, SOCKET socket, unsigned int buf_size);
#define recv(socket, buffer, buf_size, flags) OS_NETRECV(buffer, socket, buf_size)
int OS_NETSEND(unsigned char * buffer, SOCKET socket, unsigned int length);
#define send(socket, buffer, length, flags) OS_NETSEND(buffer, socket, length)
signed char  OS_NETCLOSE(unsigned char,SOCKET);
#define closesocket(socket,how) OS_NETCLOSE(how,socket)
extern unsigned char errno;
signed char OS_NETCONNECT(const struct sockaddr_in * addr, SOCKET socket);
#define connect(socket, addr, address_len) OS_NETCONNECT(addr,socket)
signed char OS_LISTEN(int, SOCKET socket);
#define listen(socket, backlog) OS_LISTEN(backlog,socket)
signed char OS_BIND(const struct sockaddr_in * addr, SOCKET socket);
#define bind(socket, addr, address_len) OS_BIND(addr,socket)
SOCKET OS_ACCEPT(const struct sockaddr_in * addr, SOCKET socket);
#define accept(socket, addr, address_len) OS_ACCEPT(addr,socket)
unsigned short htons(unsigned short hostshort);

struct in_addr * dns_resolver(char *);


#define IPPROTO_TCP 6
#define IPPROTO_UDP 17

#define AF_UNSPEC 0
#define AF_INET 2
#define AF_INET6 23

#define SOCK_STREAM 0x01	//tcp/ip
#define SOCK_DGRAM 	0x03		//udp/ip

#define ERR_INTR 		 4
#define ERR_NFILE 		 23
#define ERR_ALREADY 	 37
#define ERR_NOTSOCK 	 38
#define	ERR_EAGAIN		 35			/* Try again */
#define	ERR_EWOULDBLOCK	 ERR_EAGAIN		/* Operation would block */
#define ERR_EMSGSIZE 	 40    		/* Message too long */
#define ERR_PROTOTYPE 	 41
#define ERR_AFNOSUPPORT  47
#define ERR_HOSTUNREACH  65
#define	ECONNABORTED	53	/* Software caused connection abort */
#define ERR_CONNRESET 	 54
#define ERR_NOTCONN 	 57

#endif