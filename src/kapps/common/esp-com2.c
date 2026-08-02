////////////////////////ESP32 PROCEDURES 2////////////////////

/* Non-blocking drain of whatever is already in the UART FIFO. */
int uartReadburst(unsigned int messageadr)
{
	unsigned int count;
	unsigned char data;

	writeLog("Reading  byte burst.", "uartReadBurst  ");
	count = 0;
	switch (comType)
	{
	case 0: /* Kondratyev NO AFC ? RTS nudge */
		disable_interrupt();
		for (;;)
		{
			output(MCR, 2);
			output(MCR, 0);
			if ((1 & input(LSR)) == 0)
			{
				((char *)messageadr)[count] = 0;
				enable_interrupt();
				writeLog(((char *)messageadr), "uartReadBurst  ");
				return (int)count;
			}
			((char *)messageadr)[count++] = input(RBR_THR);
		}
	case 2: /* Kondratyev AFC ? hardware RTS, just poll LSR */
		for (;;)
		{
			if ((1 & input(LSR)) == 0)
			{
				((char *)messageadr)[count] = 0;
				writeLog(((char *)messageadr), "uartReadBurst  ");
				return (int)count;
			}
			((char *)messageadr)[count++] = input(RBR_THR);
		}
	case 1: /* ATM2 COM ? queue count at 0xc2fe, data at 0x02fe */
		for (;;)
		{
			disable_interrupt();
			input(0x55fe);
			if (input(0xc2fe) == 0)
			{
				enable_interrupt();
				((char *)messageadr)[count] = 0;
				writeLog(((char *)messageadr), "uartReadBurst  ");
				return (int)count;
			}
			input(0x55fe);
			data = input(0x02fe);
			enable_interrupt();
			((char *)messageadr)[count++] = data;
		}
	case 3: /* ATM2IOESP ? same 16550 regs via 0xfb/0xfa */
		for (;;)
		{
			disable_interrupt();
			output(0xfb, MCR);
			output(0xfa, 2);
			output(0xfa, 0);
			output(0xfb, LSR);
			if ((1 & input(0xfa)) == 0)
			{
				enable_interrupt();
				((char *)messageadr)[count] = 0;
				writeLog(((char *)messageadr), "uartReadBurst  ");
				return (int)count;
			}
			output(0xfb, RBR_THR);
			data = input(0xfa);
			enable_interrupt();
			((char *)messageadr)[count++] = data;
		}
	}
	return 255;
}

/* TX raw UART bytes. Returns byte count, or -1 on timeout. */
int putDataEsp(unsigned int messageadr, unsigned int size)
{
	unsigned int counter;
	unsigned char byte;

	writeLog("put data Packet.", "putDataEsp     ");
	writeLog(((char *)messageadr), "putDataEsp     ");
	switch (comType)
	{
	case 0: /* NO AFC */
	case 2: /* AFC ? THR-ready wait is enough */
		for (counter = 0; counter < size; counter++)
		{
			timerok = factor;
			disable_interrupt();
			while ((input(LSR) & 32) == 0)
			{
				if (timerok == 0)
				{
					writeLog("[16550] TX timeout.", "putDataEsp     ");
					enable_interrupt();
					return -1;
				}
				timerok--;
			}
			output(RBR_THR, ((char *)messageadr)[counter]);
			enable_interrupt();
		}
		return (int)counter;

	case 1: /* ATM2 COM ? same as uart_write + timeout */
		for (counter = 0; counter < size; counter++)
		{
			timerok = factor;
			disable_interrupt();
			do
			{
				input(0x55fe);
				byte = (unsigned char)(input(0x42fe) & 32);
				if (byte != 0)
					break;
				if (timerok == 0)
				{
					writeLog("[ATM2 COM] TX timeout.", "putDataEsp     ");
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

	case 3: /* ATM2IOESP ? same as uart_write + timeout (LSR bit5) */
		for (counter = 0; counter < size; counter++)
		{
			timerok = factor;
			while ((portInput(LSR) & 32) == 0)
			{
				if (timerok == 0)
				{
					writeLog("[ATM2IOESP] TX timeout.", "putDataEsp     ");
					return -1;
				}
				timerok--;
			}
			disable_interrupt();
			output(0xfb, RBR_THR);
			output(0xfa, ((char *)messageadr)[counter]);
			enable_interrupt();
		}
		return (int)counter;
	}
	return -1;
}

/* Non-blocking try: 0 = no data yet, >0 = +IPD length, -1 = error/CLOSED. */
int recvHeadNoBlock(void)
{
	unsigned int dataRead = 0;
	unsigned int byte, todo = 0, count = 0, countErr = 0, toComa;
	unsigned char queue;
	const char closed[] = "CLOSED";
	const char error[] = "ERROR";

	/* Do NOT writeLog on the empty-poll path — main loop calls this every tick. */
	do
	{
		switch (comType)
		{
		case 0: /* NO AFC — RTS nudge then LSR */
			disable_interrupt();
			output(MCR, 2);
			output(MCR, 0);
			enable_interrupt();
			if ((1 & input(LSR)) == 0)
				return 0;
			break;
		case 2: /* AFC */
			if ((1 & input(LSR)) == 0)
				return 0;
			break;
		case 1:
			/*
			 * ATM2 COM: host RX queue fills only while DTR/RTS are asserted
			 * (same pulse as uartReadBlock). Plain uart_hasByte() never
			 * nudges the modem — after CIPSEND the UI spun with 0 forever,
			 * and welcome +IPD only appeared on ESC→esp_wait_send_prompt
			 * (which uses uartReadBlock and finally pulsed RTS).
			 */
			disable_interrupt();
			input(0x55fe);
			input(0x43fe);
			input(0x03fe); /* DTR+RTS on */
			input(0x55fe);
			input(0x43fe);
			input(0x00fe); /* off */
			input(0x55fe);
			queue = input(0xc2fe);
			enable_interrupt();
			if (queue == 0)
				return 0;
			break;
		case 3: /* ATM2IOESP — RTS pulse + LSR */
			disable_interrupt();
			output(0xfb, MCR);
			output(0xfa, 2);
			output(0xfa, 0);
			enable_interrupt();
			output(0xfb, LSR);
			if ((1 & input(0xfa)) == 0)
				return 0;
			break;
		}

		byte = uartReadBlock();
		if (byte > 255)
		{
			writeLog("Timeout reading +IPD head ", "recvHeadNoBlock");
			return -1;
		}

		netbuf[dataRead] = (unsigned char)byte;
		dataRead++;

		if ((unsigned char)byte == closed[count])
		{
			count++;
			if (count == strlen(closed))
				return -1;
		}
		else
			count = 0;

		if ((unsigned char)byte == error[countErr])
		{
			countErr++;
			if (countErr == strlen(error))
			{
				writeLog("Recieved 'ERROR' ", "recvHeadNoBlock");
				writeLog((char *)netbuf, "recvHeadNoBlock");
				return -1;
			}
		}
		else
			countErr = 0;
	} while ((unsigned char)byte != ',');

	toComa = dataRead;
	do
	{
		byte = uartReadBlock();
		if (byte > 255)
		{
			writeLog("Timeout waiting ':' ", "recvHeadNoBlock");
			return -1;
		}
		netbuf[dataRead] = (unsigned char)byte;
		dataRead++;
	} while ((unsigned char)byte != ':');

	todo = (unsigned int)atoi((char *)netbuf + toComa);
	/* writeLog("+IPD processing.", "recvHeadNoBlock"); */
	return (int)todo;
}
