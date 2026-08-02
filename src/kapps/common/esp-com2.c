////////////////////////ESP32 PROCEDURES 2////////////////////

// è‡ÆÊ•§„‡† ¢ÎÁ®‚Î¢†•‚ ¢·• ®ß ØÆ‡‚† °•ß °´Æ™®‡Æ¢™®.
int uartReadburst(unsigned int messageadr)
{
	unsigned char data, count;
	writeLog("Reading  byte burst.", "uartReadBurst  ");
	switch (comType)
	{
	case 0: // Kondratyev  NO AFC
		count = 0;
		disable_interrupt();
		while (42)
		{
			output(MCR, 2);
			output(MCR, 0);

			if ((1 & input(LSR)) == 0)
			{
				((char *)messageadr)[count] = 0;
				enable_interrupt();
				writeLog(((char *)messageadr), "uartReadBurst  ");
				return count;
			}
			((char *)messageadr)[count] = input(RBR_THR);
			count++;
		}
	case 2: // Kondratyev AFC
		break;
	case 1: // ATM2 COM port
		disable_interrupt();
		input(0x55fe);		  // –ü–µ—Ä–µ—Ö–æ–¥ –≤ —Ä–µ–∂–∏–º –∫–æ–º–∞–Ω–¥
		data = input(0x02fe); // –ö–æ–º–∞–Ω–¥–∞ –ø—Ä–æ—á–µ—Å—Ç—å –∏–∑ –ø–æ—Ä—Ç–∞
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
/* TX raw UART bytes. Returns byte count, or -1 on timeout (int, not char). */
int putDataEsp(unsigned int messageadr, unsigned int size)
{
	unsigned int counter;
	writeLog("put data Packet.", "putDataEsp     ");
	writeLog(((char *)messageadr), "putDataEsp     ");
	switch (comType)
	{
	case 0: // Kondratyev  NO AFC
	case 2: // Kondratyev AFC
		for (counter = 0; counter < size; counter++)
		{
			timerok = factor;
			disable_interrupt();
			while ((input(LSR) & 32) == 0)
			{
				if (timerok == 0)
				{
					writeLog("[NO AFC]Timeout.", "putDataEsp     ");
					enable_interrupt();
					return -1;
				}
				timerok--;
			}
			output(RBR_THR, ((char *)messageadr)[counter]);
			enable_interrupt();
		}
		return (int)counter;
	case 1: // ATM2 COM port
		for (counter = 0; counter < size; counter++)
		{
			unsigned char byte;
			disable_interrupt();
			timerok = factor;
			do
			{
				input(0x55fe);
				byte = (input(0x42fe) & 32);
				if (byte != 0)
				{
					break;
				}
				if (timerok == 0)
				{
					writeLog("[ATM2 COM] ready timeout.", "putDataEsp     ");
					enable_interrupt();
					return -1;
				}
				timerok--;
			} while (42);

			input(0x55fe);
			input(0x03fe);
			input((((char *)messageadr)[counter] << 8) | 0x00fe);
			enable_interrupt();
		}
		return (int)counter;
	case 3: // ATM2IOESP
		for (counter = 0; counter < size; counter++)
		{
			timerok = factor;
			disable_interrupt();
			while (42)
			{
				char byte;
				output(0xfb, LSR);
				byte = input(0xfa);

				if (byte != 0)
				{
					break;
				}
				if (timerok == 0)
				{
					enable_interrupt();
					writeLog("[ATM2IOESP]Timeout.", "putDataEsp     ");
					return -1;
				}
				timerok = timerok - 1;
			}
			output(0xfb, RBR_THR);
			output(0xfa, ((char *)messageadr)[counter]);
			enable_interrupt();
		}
		return (int)counter;
	}
	return -1;
}
// ≠•°´Æ™®‡„ÓÈ†Ô ØÆØÎ‚™† ØÆ´„Á®‚Ï +IPD
int recvHeadNoBlock(void)
{
	unsigned int dataRead = 0;
	unsigned int byte, todo = 0, count = 0, countErr = 0, toComa;
	const char closed[] = "CLOSED";
	const char error[] = "ERROR";
	//+IPD,<length>:<data>
	//+CIPRECVDATA:<actual_len>,<data>
	writeLog("Waiting +IPD head ", "recvHeadNoBlock");
	do
	{

		switch (comType)
		{
		case 0: // Kondratyev   NO AFC

			disable_interrupt();
			output(MCR, 2);
			output(MCR, 0);
			enable_interrupt();
			if ((1 & input(LSR)) == 0)
			{
				return 0;
			}
			break;
		case 1:
			break;
		case 2: // Kondratyev with AFC
			if ((1 & input(LSR)) == 0)
			{
				return 0;
			}
			break;
		case 3:
			disable_interrupt();
			output(0xfb, MCR);
			output(0xfa, 2);
			output(0xfa, 0);
			enable_interrupt();

			output(0xfb, LSR);
			if ((1 & input(0xfa)) == 0)
			{
				return 0;
			}
			break;
		}

		byte = uartReadBlock();

		if (byte > 255)
		{
			writeLog("Timeout reading +IPD head ", "recvHeadNoBlock");
			return -1;
		}

		netbuf[dataRead] = byte;
		dataRead++;
		// printf("[%c]", byte);

		if (byte == closed[count])
		{
			count++;
			if (count == strlen(closed))
			{
				return -1;
			}
		}
		else
		{
			count = 0;
		}

		if (byte == error[countErr])
		{
			countErr++;
			if (countErr == strlen(error))
			{
				writeLog("Recieved 'ERROR' ", "recvHeadNoBlock");
				writeLog(netbuf, "recvHeadNoBlock");
				return -1;
			}
		}
		else
		{
			countErr = 0;
		}
	} while (byte != ','); // SEND OK<CR><LF><CR><LF>+IPD,
	toComa = dataRead;
	do
	{
		byte = uartReadBlock();
		if (byte > 255)
		{
			writeLog("Timeout waiting ':' ", "recvHeadNoBlock");
			return false;
		}

		netbuf[dataRead] = byte;
		dataRead++;

	} while (byte != ':'); //:<data>
	todo = atoi(netbuf + toComa);

	// <actual_len>
	// printf("recvHead(); todo = %d  ", todo);
	// sprintf(cmd, "In header[todo=%d]", todo);
	writeLog("+IPD processing.", "recvHeadNoBlock");
	return todo;
}