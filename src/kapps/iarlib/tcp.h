
struct sockaddr_in {
        unsigned char   family;			/*net type*/
        unsigned char 	porth;			/*port*/
		unsigned char 	portl;			/*port*/
        unsigned char 	b1; 
		unsigned char 	b2;
		unsigned char 	b3; 
		unsigned char 	b4;
        unsigned char	zero[8];		/*reserved*/
};

struct readstructure
			{
			unsigned char  	socket; 
			unsigned int	BufAdr;
			unsigned int 	bufsize;
			unsigned char	protocol;
			};

void OS_SETDNS(void * addr);

void OS_GETDNS(void * addr);

unsigned int OS_NETSOCKET(unsigned int);
//	D - семейство адресов, беззнаковое 8-битное число, допускается только значение 2 (AF_INET).
//  E - протокол соединения(0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip)
// 	Возвращаемые значения в регистрах:
//  L - SOCKET при положительном значении, при отрицательном значении  - функция завершилась с ошибкой.
//  А - errno при ошибке.
//	HL - параметр вернем

unsigned int OS_NETCONNECT (unsigned char socket,struct sockaddr_in *);
//	A - SOCKET
//	DE - указатель на структуру sockaddr_in содержащую IP адрес и порт хоста.
//	Возвращаемые значения в регистрах:
//  L - При отрицательном значении  - функция завершилась с ошибкой.
//  А - errno при ошибке.


unsigned int OS_WIZNETREAD (struct readstructure *);
//	A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) ; 
//	out: HL=count if HL < 0 then A=error

unsigned int OS_WIZNETWRITE (struct readstructure *);
//CMD_WIZNETWRITE=0xde
//if TCP: A=SOCKET, de=buffer_ptr, HL=sizeof(buffer)
//else:	 A=SOCKET, IX=buffer_ptr, HL=sizeof(buffer), de=sockaddr_in ptr
//out: HL=count if HL < 0 then A=error 

unsigned int OS_BIND(unsigned char socket,struct sockaddr_in *);
//	A=SOCKET, DE=sockaddr ptr {unsigned char sin_family /*net type*/; unsigned short sin_port; struct in_addr sin_addr /*4 bytes IP*/; char sin_zero[8];}

unsigned int OS_LISTEN(unsigned char socket);
// A - SOCKET
// Возвращаемые значения в регистрах:
// L - При отрицательном значении - функция завершилась с ошибкой.
// А - errno при ошибке.

unsigned int OS_ACCEPT(unsigned char socket);
// A - SOCKET
// Возвращаемые значения в регистрах:
// L - SOCKET при положительном значении, при отрицательном значении  - функция завершилась с ошибкой.
// А - errno при ошибке.

unsigned int OS_NETSHUTDOWN (unsigned char socket, unsigned char type);
// A=SOCKET
// E=Type 0 - immediately 1 - only if output buffer empty
// out: if HL < 0 then A=error

unsigned long OS_DNSRESOLVE (unsigned int adrptr);
//	de=buffer_ptr adress
//	out:


#define IPPROTO_TCP 6
#define IPPROTO_UDP 17

#define AF_UNSPEC 0
#define AF_INET 2
#define AF_INET6 23

#define SOCK_STREAM 0x01	//tcp/ip
#define SOCK_ICMP 	0x02	//icmp
#define SOCK_DGRAM 	0x03	//udp/ip
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
