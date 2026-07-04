#include "netglue.h"

unsigned char netbuf[ATELNET_NETBUF_SIZE];
struct sockaddr_in targetadr;
struct sockaddr_in dnsaddress;
struct readstructure readStruct;
