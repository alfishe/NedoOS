void errorPrint(unsigned int error)
{
	clearStatus();
	AT(1, 24);
	switch (error)
	{
	case 2:
		printf("02 SHUT_RDWR");
		break;
	case 4:
		printf("04 ERR_INTR");
		break;
	case 23:
		printf("23 ERR_NFILE");
		break;
	case 35:
		printf("35 ERR_EAGAIN");
		break;
	case 37:
		printf("37 ERR_ALREADY");
		break;
	case 38:
		printf("38 ERR_NOTSOCK");
		break;
	case 40:
		printf("40 ERR_EMSGSIZE");
		break;
	case 41:
		printf("41 ERR_PROTOTYPE");
		break;
	case 47:
		printf("47 ERR_AFNOSUPPORT");
		break;
	case 53:
		printf("53 ERR_ECONNABORTED");
		break;
	case 54:
		printf("54 ERR_CONNRESET");
		break;
	case 57:
		printf("57 ERR_NOTCONN");
		break;
	case 65:
		printf("65 ERR_HOSTUNREACH");
		break;
	default:
		printf("[%u] UNKNOWN ERROR", error);
		break;
	}
	YIELD();
	do
	{
		key = _low_level_get();
	} while (key == 0);
}

unsigned char OpenSock(unsigned char family, unsigned char protocol)
{
	unsigned char socket;
	unsigned int todo;
	todo = OS_NETSOCKET((family << 8) + protocol);
	if (todo > 32767)
	{
		clearStatus();
		AT(1, 24);
		printf("OS_NETSOCKET: ");
		errorPrint(todo & 255);
		exit(0);
	}
	else
	{
		socket = ((todo & 65280) >> 8);
	}
	return socket;
}

unsigned char netConnect(unsigned char socket)
{
	unsigned int todo;

	targetadr.family = AF_INET;
	targetadr.porth = 00;
	targetadr.portl = 80;
	targetadr.b1 = 31;
	targetadr.b2 = 31;
	targetadr.b3 = 65;
	targetadr.b4 = 35;

	todo = OS_NETCONNECT(socket, &targetadr);
	if (todo > 32767)
	{
		clearStatus();
		AT(1, 24);
		printf("OS_NETCONNECT: ");
		errorPrint(todo & 255);
		exit(0);
	}
	return 0;
}

unsigned char saveBuf(unsigned char *fileNamePtr, unsigned char operation, unsigned int sizeOfBuf)
{
	unsigned char fileName[255];

	if (operation == 00)
	{
		strcpy(fileName, fileNamePtr);
		fp2 = OS_CREATEHANDLE(fileName, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			AT(1, 24);
			printf(fileName);
			printf(" creating error.");
			exit(0);
		}
		OS_CLOSEHANDLE(fp2);
		fp2 = OS_OPENHANDLE(fileName, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			AT(1, 24);
			printf(fileName);
			printf(" opening error.");

			exit(0);
		}
		AT(1, 24);
		return 0;
	}

	if (operation == 01)
	{
		OS_WRITEHANDLE(netbuf, fp2, sizeOfBuf);
		downloaded = downloaded + sizeOfBuf;
		return 0;
	}

	if (operation == 02)
	{
		OS_CLOSEHANDLE(fp2);
		return 0;
	}
	return 0;
}

void cancel(void)
{
	key = _low_level_get();
	if (key == 27)
	{
		saveBuf("fileNamePtr", 02, 00);
		fatalError("File download aborted!");
	}
}

unsigned int tcpRead(unsigned char socket)
{
	unsigned char retry = 250;
	unsigned int err, todo;
	readStruct.socket = socket;
	readStruct.BufAdr = (unsigned int)&netbuf;
	readStruct.bufsize = bufSize;
	readStruct.protocol = SOCK_STREAM;
wizread:
	todo = OS_WIZNETREAD(&readStruct);
	if (todo > 32767)
	{
		if (retry == 0)
		{
			err = todo & 255;
			clearStatus();
			AT(1, 24);
			printf("OS_WIZNETREAD: ");
			errorPrint(err);

			if (err == 35)
			{
				return 0;
			}
			fatalError("ERROR CONNECTION TO SERVER");
		}
		retry--;
		YIELD();
		YIELD();

		cancel();

		delay(300);
		YIELD();
		YIELD();
		goto wizread;
	}
	return todo;
}

unsigned int netShutDown(unsigned char socket)
{
	unsigned int todo;
	todo = OS_NETSHUTDOWN(socket);
	if (todo > 32767)
	{
		printf("OS_NETSHUTDOWN: ");
		errorPrint(todo & 255);
		return 255;
	}

	return 0;
}

unsigned int cutHeader(unsigned int todo)
{
	unsigned int q, headlng;
	unsigned char *count;
	count = strstr(netbuf, "Content-Length:");
	if (count == NULL)
	{
		clearStatus();
		AT(1, 24);
		printf("Content-Length:  not found.");
		contLen = 0;
	}
	else
	{
		contLen = atol(count + 15);
		bytecount = contLen;
		//    AT (1,24);
		//      printf("=> Dlinna  soderzhimogo = %lu \n\r", bytecount);
	}

	count = strstr(netbuf, "\r\n\r\n");
	headlng = ((unsigned int)count - (unsigned int)netbuf + 4);
	q = todo - headlng;
	memcpy(&netbuf, count + 4, q);
	return q;
}

unsigned int tcpSend(unsigned char socket, unsigned int messageadr, unsigned int size)
{
	unsigned char retry = 20;
	unsigned int todo;
	readStruct.socket = socket;
	readStruct.BufAdr = messageadr;
	readStruct.bufsize = size;
	readStruct.protocol = SOCK_STREAM;

wizwrite:
	todo = OS_WIZNETWRITE(&readStruct);
	if (todo > 32767)
	{
		clearStatus();
		AT(1, 24);
		printf("OS_WIZNETWRITE: ");
		errorPrint(todo & 255);
		if (retry == 0)
		{
			exit(0);
		}
		retry--;
		YIELD();
		cancel();
		delay(250);
		goto wizwrite;
	}

	return todo;
}
unsigned char getFile(unsigned char *fileLink, unsigned char *fileNamePtr)
{
	unsigned int todo;
	unsigned char cmdlist1[] = " HTTP/1.1\r\nHost: nedoos.ru\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0";
	unsigned char socket;
	unsigned int bytes2read, headskip;
	strcpy(netbuf, "GET ");
	strcat(netbuf, fileLink);
	strcat(netbuf, cmdlist1);
	clearStatus();
	socket = OpenSock(AF_INET, SOCK_STREAM);
	todo = netConnect(socket);
	todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
	headskip = 0;
	bytecount = 255;
	downloaded = 0;
	saveBuf(fileNamePtr, 00, 0);
	AT(1, 24);
	printf(" %s ", fileNamePtr);
	while (bytecount != 0)
	{
		todo = tcpRead(socket);
		if (todo == 0)
		{
			break;
		}
		bytes2read = todo;
		if (headskip == 0)
		{
			headskip = 1;
			bytes2read = cutHeader(todo);
		}
		AT(34, 24);
		printf("%lu of %lu kb", downloaded / 1024, contLen / 1024);

		saveBuf(fileNamePtr, 01, bytes2read);
		bytecount = bytecount - bytes2read;

		cancel();
	}
	saveBuf(fileNamePtr, 02, 00);
	netShutDown(socket);
	if (downloaded != contLen)
	{
		fatalError("File download error!");
	}
	return 0;
}