////////////////////////ESP32 PROCEDURES//////////////////////
void portOutput(char port, char data)
{
	disable_interrupt();
	output(0xfb, port);
	output(0xfa, data);
	enable_interrupt();
}

char portInput(char port)
{
	char byte;
	disable_interrupt();
	output(0xfb, port);
	byte = input(0xfa);
	enable_interrupt();
	return byte;
}

void uart_write(unsigned char data)
{
	unsigned char status;
	switch (comType)
	{
	case 0:
	case 2:
		while ((input(LSR) & 32) == 0)
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
		} while ((status & 32) == 0); // Проверяем 5 бит

		input(0x55fe);				 // Переход в режим команд
		input(0x03fe);				 // Команда записать в порт
		input((data << 8) | 0x00fe); // Записываем data в порт
		enable_interrupt();
		break;
	case 3:
		while ((portInput(LSR) & 32) == 0)
		{
		}
		disable_interrupt();
		output(0xfb, RBR_THR);
		output(0xfa, data);
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
		case 1: // Enable flow
			output(MCR, 2);
			break;
		case 0: // Stop flow
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
	case 3:
		switch (mode)
		{
		case 1:
			disable_interrupt();
			output(0xfb, MCR);
			output(0xfa, 2);
			enable_interrupt();
			break;
		case 0:
			disable_interrupt();
			output(0xfb, MCR);
			output(0xfa, 0);
			enable_interrupt();
			break;
		default:
			disable_interrupt();
			output(0xfb, MCR);
			output(0xfa, 2);
			output(0xfa, 0);
			enable_interrupt();
			break;
		}
		break;
	}
}
void uart_init(unsigned char divisor)
{
	switch (comType)
	{
	case 0:
	case 2:
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
		uart_setrts(0);
		break;
	case 3:
		portOutput(IIR_FCR, 0x87);	  // Enable fifo 8 level, and clear it
		portOutput(LCR, 0x83);		  // 8n1, DLAB=1
		portOutput(RBR_THR, divisor); // 115200 (divider 1-115200, 3 - 38400)
		portOutput(IER, 0x00);		  // (divider 0). Divider is 16 bit, so we get (#0002 divider)
		portOutput(LCR, 0x03);		  // 8n1, DLAB=0
		portOutput(IER, 0x00);		  // Disable int
		portOutput(MCR, 0x22);		  // Enable AFE
		enable_interrupt();
		uart_setrts(0);
		break;
	}
}

unsigned char uart_hasByte(void)
{
	unsigned char queue;
	switch (comType)
	{
	case 0: // Kondratyev  NO AFC
	case 2:
		return (1 & input(LSR));
	case 1:
		disable_interrupt();
		input(0x55fe);		   // Переход в режим команд
		queue = input(0xc2fe); // Получаем количество байт в приемном буфере
		enable_interrupt();
		return queue;
	case 3:
		return 1 & portInput(LSR);
	}
	printf("uart_hasByte () Error 001: Unknown port Type:[%d]", comType);
	getchar();
	return 255;
}

unsigned char uart_read(void)
{
	unsigned char data;
	switch (comType)
	{
	case 0: // Kondratyev  NO AFC
	case 2:
		return input(RBR_THR);
	case 1:
		disable_interrupt();
		input(0x55fe);		  // Переход в режим команд
		data = input(0x02fe); // Команда прочесть из порта
		enable_interrupt();
		return data;
	case 3:
		disable_interrupt();
		output(0xfb, RBR_THR);
		data = input(0xfa);
		output(0xfb, 0x00);
		enable_interrupt();
		return data;
	}
	return 255;
}

unsigned char uart_readBlock(void)
{
	unsigned char data;
	unsigned long timer;
	timer = espRetry;
	switch (comType)
	{
	case 0: // Kondratyev  NO AFC
		while ((1 & input(LSR)) == 0)
		{
			if (timer-- == 0)
			{
				puts("\r[uart_readBlock] receiving timeout. returning 0.");
				return false;
			}
			disable_interrupt();
			output(MCR, 2);
			output(MCR, 0);
			enable_interrupt();
		}
		return input(RBR_THR);
	case 1: // ATM2 COM port
		while (uart_hasByte() == 0)
		{
			if (timer-- == 0)
			{
				puts("\r[uart_readBlock] receiving timeout. returning 0.");
				return false;
			}
			disable_interrupt();
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x03fe); // Устанавливаем готовность DTR и RTS
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x00fe); // Снимаем готовность DTR и RTS
			enable_interrupt();
		}
		disable_interrupt();
		input(0x55fe);		  // Переход в режим команд
		data = input(0x02fe); // Команда прочесть из порта
		enable_interrupt();
		return data;
	case 2: // Kondratyev AFC
		while ((1 & input(LSR)) == 0)
		{
			if (timer-- == 0)
			{
				puts("\r[uart_readBlock] receiving timeout. Returning 0.");
				return false;
			}
		}
		return input(RBR_THR);
	case 3: // ATM2IOESP
		// disable_interrupt();
		output(0xfb, LSR);
		while ((1 & input(0xfa)) == 0)
		{
			if (timer-- == 0)
			{
				enable_interrupt();
				puts("\r[uart_readBlock] receiving timeout. Returning 0.");
				return false;
			}
			disable_interrupt();
			output(0xfb, MCR);
			output(0xfa, 2);
			output(0xfa, 0);
			output(0xfb, LSR);
			enable_interrupt();
		}
		output(0xfb, RBR_THR);
		data = input(0xfa);
		// enable_interrupt();
		return data;
	}
	return 255;
}

void uart_flush(void)
{
	uart_setrts(1);
	delay(200);
	uart_setrts(0);
}

void uartFlush(unsigned int millis)
{
	uart_setrts(1);
	delay(millis);
	uart_setrts(0);
}

char getdataEsp(unsigned int counted)
{
	unsigned int counter;
	unsigned long timer;
	switch (comType)
	{
	case 0: // Kondratyev  NO AFC
		for (counter = 0; counter < counted; counter++)
		{
			timer = espRetry;
			while ((1 & input(LSR)) == 0)
			{
				if (timer-- == 0)
				{
					return false;
				}
				disable_interrupt();
				output(MCR, 2);
				output(MCR, 0);
				enable_interrupt();
			};
			netbuf[counter] = input(RBR_THR);
		}
		break;
	case 1: // ATM2 COM port
		for (counter = 0; counter < counted; counter++)
		{
			timer = espRetry;
			while (uart_hasByte() == 0)
			{
				if (timer-- == 0)
				{
					return false;
				}
				disable_interrupt();
				input(0x55fe); // Переход в режим команд
				input(0x43fe); // Команда установить статус
				input(0x03fe); // Устанавливаем готовность DTR и RTS
				input(0x55fe); // Переход в режим команд
				input(0x43fe); // Команда установить статус
				input(0x00fe); // Снимаем готовность DTR и RTS
				enable_interrupt();
			}
			disable_interrupt();
			input(0x55fe);					 // Переход в режим команд
			netbuf[counter] = input(0x02fe); // Команда прочесть из порта
			enable_interrupt();
		}
		break;
	case 2: // Kondratyev AFC
		for (counter = 0; counter < counted; counter++)
		{
			timer = espRetry;
			while ((1 & input(LSR)) == 0)
			{
				if (timer-- == 0)
				{
					return false;
				}
			}
			netbuf[counter] = input(RBR_THR);
		}
		break;
	case 3: // ATM2IOESP
		for (counter = 0; counter < counted; counter++)
		{
			timer = espRetry;
			output(0xfb, LSR);
			while ((1 & input(0xfa)) == 0)
			{
					if (timer-- == 0)
					{
						return false;
					}

				disable_interrupt();
				output(0xfb, MCR);
				output(0xfa, 2);
				output(0xfa, 0);
				output(0xfb, LSR);
				enable_interrupt();
			}
			output(0xfb, RBR_THR);
			netbuf[counter] = input(0xfa);
		}
		break;
	}
	return true;
}

void sendcommand(const char *commandline)
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

void sendcommandNrn(const char *commandline)
{
	unsigned int count, cmdLen;
	cmdLen = strlen(commandline);
	for (count = 0; count < cmdLen; count++)
	{
		uart_write(commandline[count]);
	}
	// printf("[Nrn]Sended:[%s] \r\n", commandline);
}

unsigned char getAnswer2(void)
{
	unsigned char readbyte;
	unsigned int curPos = 0;
	do
	{
		readbyte = uart_readBlock();
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
	// getchar();
	return curPos;
}

void espReBoot(void)
{
	unsigned char byte, count;
	clearStatus();
	printf("Resetting ESP...");

	uartFlush(200);

	sendcommand("AT+RST");
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
	clearStatus();
	printf("Reset complete.");
	sendcommand("ATE0");
	do
	{
		byte = uart_readBlock();
	} while (byte != 'K'); // OK
	uart_readBlock(); // CR
	uart_readBlock(); // LN
	// puts("ATE0 Answer:[OK]");
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

int recvHead(void)
{
	unsigned char byte, dataRead;
	int todo = 0, count = 0, countErr = 0;
	const char closed[] = "CLOSED";
	const char error[] = "ERROR";
	//+IPD<,length>:<data>
	//+CIPRECVDATA:<actual_len>,<data>
	dataRead = 0;
	do
	{
		byte = uart_readBlock();
		// printf("[%c]", byte);

		if (byte == closed[count])
		{
			count++;
		}
		else
		{
			count = 0;
		}

		if (byte == error[countErr])
		{
			countErr++;
		}
		else
		{
			countErr = 0;
		}
		if ((count == strlen(closed)) || (countErr == strlen(error)))
		{
			// uart_readBlock(); // CR
			// uart_readBlock(); // LF
			return todo;
		}
	} while (byte != ',');

	do
	{
		byte = uart_readBlock();
		netbuf[dataRead] = byte;
		dataRead++;
	} while (byte != ':');
	todo = atoi(netbuf);
	// <actual_len>
	// printf("recvHead(); todo = %d   ", todo);

	return todo;
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
	OS_READHANDLE(curParam, espcom, 250);
	OS_CLOSEHANDLE(espcom);

	res = sscanf(curParam, "%x %x %x %x %x %x %x %x %u %u %u %lu", &RBR_THR, &IER, &IIR_FCR, &LCR, &MCR, &LSR, &MSR, &SR, &divider, &comType, &espType, &espRetry);

	if (espRetry == 0)
	{
		espRetry = 500000;
	}

	puts("Config loaded:");
	if (comType == 1)
	{
		puts("     Controller IO port: 0x55fe");
	}
	else
	{
		printf("     RBR_THR:0x%4x     IER    :0x%4x\r\n     IIR_FCR:0x%4x     LCR    :0x%4x\r\n", RBR_THR, IER, IIR_FCR, LCR);
		printf("     MCR    :0x%4x     LSR    :0x%4x\r\n     MSR    :0x%4x     SR     :0x%4x\r\n", MCR, LSR, MSR, SR);
	}
	printf("     DIV    :%u    TYPE    :%u    ESP    :%u    Retry  :%lu  \r\n", divider, comType, espType, espRetry);
	switch (comType)
	{
	case 0:
		puts("     Port (16550 like w/o AFC)");
		break;
	case 1:
		puts("     Port (ATM Turbo 2+)");
		break;
	case 2:
		puts("     Port (16550 with AFC)");
		break;
	case 3:
		puts("     Port (ATM2IOESP Card)");
		break;
	default:
		puts("     Port (Unknown type)");
		break;
	}
	puts(" ");
	YIELD();
}
////////////////////////ESP32 PROCEDURES//////////////////////