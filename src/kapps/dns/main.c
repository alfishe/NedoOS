#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <tcp.h>
#include <intrz80.h>
#include <stdlib.h>

no_init unsigned char ipadress[4];
no_init unsigned int ip16[4];

const unsigned char help[] = "View and set system DNS server\r\nUsage: dns.com [ip-adress]\r\n\0";

void get_dns(void)
{
	printf("Current DNS-server: ");
	OS_GETDNS(ipadress);
	printf("%d.%d.%d.%d\r\n", ipadress[0], ipadress[1], ipadress[2], ipadress[3]);
}

void setdns(const char * strIP)
{
    
    if( sscanf(strIP,"%d.%d.%d.%d", ip16, ip16+1,ip16+2,ip16+3) == 4 )
    {
        ipadress[0] = ip16[0];
        ipadress[1] = ip16[1];
        ipadress[2] = ip16[2];
        ipadress[3] = ip16[3];
        OS_SETDNS(ipadress);
    }
    else
    {
        printf("Wrong parameter\r\n");
    }
	
}

C_task main(int argc, char *argv[])
{
	os_initstdio();

	if (argc == 1)
	{
		puts(help);
	}
	else if (argc == 2)
	{
		setdns(argv[1]);
	}
    
	get_dns();
}
