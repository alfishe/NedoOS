unsigned int RBR_THR = 0xf8ef;
unsigned int IER = 0xf9ef;
unsigned int IIR_FCR = 0xfaef;
unsigned int LCR = 0xfbef;
unsigned int MCR = 0xfcef;
unsigned int LSR = 0xfdef;
unsigned int MSR = 0xfeef;
unsigned int SR = 0xffef;
unsigned int divider = 1;
unsigned char comType = 0;
unsigned int espType = 32;

////////////////////////ESP32 PROCEDURES//////////////////////
void uart_write(unsigned char data)
{
	unsigned char status;
	switch (comType)
	{
	case 0:
	case 2:
		while ((input(LSR) & 64) == 0)
		{
		}
		output(RBR_THR, data);
		break;
	case 1:
		disable_interrupt();
		do
		{
			input(0x55fe);			// Переход в режим команд
			status = input(0x42fe); // Команда прочесть статус
		} while ((status & 64) == 0); // Проверяем 6 бит

		input(0x55fe);				 // Переход в режим команд
		input(0x03fe);				 // Команда записать в порт
		input((data << 8) | 0x00fe); // Записываем data в порт
		enable_interrupt();
		break;
	}
}

void uart_setrts(unsigned char mode)
{
	switch (comType)
	{
	case 0:
		switch (mode)
		{
		case 1:
			output(MCR, 2);
			break;
		case 0:
			output(MCR, 0);
			break;
		default:
			disable_interrupt();
			output(MCR, 2);
			output(MCR, 0);
			enable_interrupt();
			break;
		}
	case 1:
		switch (mode)
		{
		case 1:
			disable_interrupt();
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x03fe); // Устанавливаем готовность DTR и RTS
			enable_interrupt();
			break;
		case 0:
			disable_interrupt();
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x00fe); // Снимаем готовность DTR и RTS
			enable_interrupt();
			break;
		default:
			disable_interrupt();
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x03fe); // Устанавливаем готовность DTR и RTS
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x00fe); // Снимаем готовность DTR и RTS
			enable_interrupt();
			break;
		}
	case 2:
		break;
	}
}

void uart_init(unsigned char divisor)
{
	switch (comType)
	{
	case 0:
	case 2:
		output(MCR, 0x00);		  // Disable input
		output(IIR_FCR, 0x87);	  // Enable fifo 8 level, and clear it
		output(LCR, 0x83);		  // 8n1, DLAB=1
		output(RBR_THR, divisor); // 115200 (divider 1-115200, 3 - 38400)
		output(IER, 0x00);		  // (divider 0). Divider is 16 bit, so we get (#0002 divider)
		output(LCR, 0x03);		  // 8n1, DLAB=0
		output(IER, 0x00);		  // Disable int
		output(MCR, 0x2f);		  // Enable AFE
		break;
	case 1:
		disable_interrupt();
		input(0x55fe);
		input(0xc3fe);
		input((divisor << 8) | 0x00fe);
		enable_interrupt();
		break;
	}
}

unsigned char uart_hasByte(void)
{
	unsigned char queue;
	switch (comType)
	{
	case 0:
	case 2:
		return (1 & input(LSR));
	case 1:
		disable_interrupt();
		input(0x55fe);		   // Переход в режим команд
		queue = input(0xc2fe); // Получаем количество байт в приемном буфере
		enable_interrupt();
		return queue;
	}
	return 255;
}

unsigned char uart_read(void)
{
	unsigned char data;
	switch (comType)
	{
	case 0:
	case 2:
		return input(RBR_THR);
	case 1:
		disable_interrupt();
		input(0x55fe);		  // Переход в режим команд
		data = input(0x02fe); // Команда прочесть из порта
		enable_interrupt();
		return data;
	}
	return 255;
}

unsigned char uart_readBlock(void)
{
	unsigned char data;
	switch (comType)
	{
	case 0:
		while (uart_hasByte() == 0)
		{
			uart_setrts(2);
		}
		return input(RBR_THR);
	case 1:
		while (uart_hasByte() == 0)
		{
			uart_setrts(2);
		}
		disable_interrupt();
		input(0x55fe);		  // Переход в режим команд
		data = input(0x02fe); // Команда прочесть из порта
		enable_interrupt();
		return data;
	case 2:
		while (uart_hasByte() == 0)
		{
		}
		return input(RBR_THR);
	}
	return 255;
}

void uart_flush(void)
{
	unsigned int count;
	for (count = 0; count < 6000; count++)
	{
		uart_setrts(1);
		uart_read();
	}
}

void getdataEsp(unsigned int counted)
{
	unsigned int counter;
	for (counter = 0; counter < counted; counter++)
	{
		netbuf[counter] = uart_readBlock();
	}
	netbuf[counter] = 0;
}

void sendcommand(char *commandline)
{
	unsigned int count, cmdLen;
	cmdLen = strlen(commandline);
	for (count = 0; count < cmdLen; count++)
	{
		uart_write(commandline[count]);
	}
	uart_write('\r');
	uart_write('\n');
	// printf("Sended:[%s] \r\n", commandline);
}

unsigned char getAnswer2(void)
{
	unsigned char readbyte;
	unsigned int curPos = 0;
	do
	{
		readbyte = uart_readBlock();
		// putdec(readbyte);
	} while (((readbyte == 0x0a) || (readbyte == 0x0d)));

	netbuf[curPos] = readbyte;
	curPos++;
	do
	{
		readbyte = uart_readBlock();
		netbuf[curPos] = readbyte;
		curPos++;
	} while (readbyte != 0x0d);
	netbuf[curPos - 1] = 0;
	uart_readBlock(); // 0xa
	// printf("Answer:[%s]\r\n", netbuf);
	//    getchar();
	return curPos;
}

void espReBoot(void)
{
	unsigned char byte, count;
	uart_flush();
	sendcommand("AT+RST");
	printf("Resetting ESP...");
	count = 0;
	do
	{
		byte = uart_readBlock();
		if (byte == gotWiFi[count])
		{
			count++;
		}
		else
		{
			count = 0;
		}
	} while (count < strlen(gotWiFi));
	uart_readBlock(); // CR
	uart_readBlock(); // LF
	printf("Reset complete.");

	sendcommand("ATE0");
	do
	{
		byte = uart_readBlock();
	} while (byte != 'K'); // OK
	// puts("ATE0 Answer:[OK]");
	uart_readBlock(); // CR
	uart_readBlock(); // LN

	sendcommand("AT+CIPCLOSE");
	getAnswer2();
	sendcommand("AT+CIPDINFO=0");
	getAnswer2();
	sendcommand("AT+CIPMUX=0");
	getAnswer2();
	sendcommand("AT+CIPSERVER=0");
	getAnswer2();
	sendcommand("AT+CIPRECVMODE=0");
	getAnswer2();
}

unsigned int recvHead(void)
{
	unsigned char byte, dataRead = 0;
	unsigned int loaded;
	do
	{
		byte = uart_readBlock();
	} while (byte != ',');

	dataRead = 0;
	do
	{
		byte = uart_readBlock();
		netbuf[dataRead] = byte;
		dataRead++;
	} while (byte != ':');
	netbuf[dataRead] = 0;
	loaded = atoi(netbuf); // <actual_len>
	// printf("\r\n loaded %u\r\n", loaded);
	return loaded;
}

void loadEspConfig(void)
{
	unsigned char curParam[256];
	unsigned char res;
	FILE *espcom;
	OS_SETSYSDRV();
	OS_CHDIR("../ini");
	espcom = OS_OPENHANDLE("espcom.ini", 0x80);
	if (((int)espcom) & 0xff)
	{
		clearStatus();
		printf("espcom.ini opening error");
		return;
	}

	OS_READHANDLE(curParam, espcom, 256);

	res = sscanf(curParam, "%x %x %x %x %x %x %x %x %u %u %u", &RBR_THR, &IER, &IIR_FCR, &LCR, &MCR, &LSR, &MSR, &SR, &divider, &comType, &espType);
	puts("Config loaded:");
	if (comType == 1)
	{
		puts("     Controller base port: 0x55fe");
	}
	else
	{
		printf("     RBR_THR:0x%4x     IER    :0x%4x\r\n     IIR_FCR:0x%4x     LCR    :0x%4x\r\n", RBR_THR, IER, IIR_FCR, LCR);
		printf("     MCR    :0x%4x     LSR    :0x%4x\r\n     MSR    :0x%4x     SR     :0x%4x\r\n", MCR, LSR, MSR, SR);
	}
	printf("     DIV    :%u    TYPE    :%u    ESP    :%u ", divider, comType, espType);
	switch (comType)
	{
	case 0:
		puts("(16550 like w/o AFC)");
		break;
	case 1:
		puts("(ATM Turbo 2+)");
		break;
	case 2:
		puts("(16550 with AFC)");
	default:
		puts("(Unknown type)");
		break;
	}
}
////////////////////////ESP32 PROCEDURES//////////////////////