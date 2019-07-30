
SL811
.EP0Control=0
.EP0Address=1
.EP0Status=3
.EP0Counter=4
.CtrlReg=5
.IntEna=6
.IntStatus=13
.cDATASet=14
.cSOFcnt=15
.INT_CLEAR=0xff
	MACRO WRITE_REG _r,_v
	IF _r == 0x00
		xor a
	ELSE
		ld a,_r
	ENDIF
	out (c),a		
	IF _r != _v
		IF _v == 0x00
			xor a
		ELSE
			ld a,_v
		ENDIF
	ENDIF
	IF _v & 0x80
		dec b
		out (c),a
		inc b
	ELSE
		out (0xab),a
	ENDIF
	ENDM
.init	
; 32.	    SL11HardReset();
	
	CALL	.SL11HardReset
; 33.	    USBReset();
	CALL	.USBReset
; 34.	        temp=sl811_init_my();
	CALL	.sl811_init_my
	or a
	ld a,1
	ret z
; 35.	        temp=EnumUsbDev();                              // enumerate USB device, assign USB address = #1
	CALL	.EnumUsbDev
	or a
	ld a,1
	ret z
; 36.	        temp=EnumMassDev();
	CALL	.EnumMassDev
	or a
	ret z
	ld a,1
	ret

.DBUF=0x8000-1024
; 17.	void USBReset(void)   
; 18.	{
.USBReset:
	PUSH	BC
	PUSH	DE
	PUSH	AF
; 19.	        BYTE tmp;
; 20.	        tmp =  SL811Read(CtrlReg);
	LD	A,.CtrlReg	;0x05
	LD	BC,0x80ab
	OUT	(C),A
	in a,(0xab)
	LD	HL,0
	ADD	HL,SP
	LD	(HL),a
; 21.	        SL811Write(CtrlReg,0x08);
	WRITE_REG .CtrlReg,0x08
; 22.	        .delayms(100);
	LD	E,6
	CALL	.delayms
; 23.	        SL811Write(CtrlReg,0x18);
	WRITE_REG .CtrlReg, 0x18
; 24.	        .delayms(100);
	LD	E,6
	CALL	.delayms
; 25.	        SL811Write(CtrlReg,0x08);
	WRITE_REG .CtrlReg, 0x08
; 26.	        .delayms(500);
	LD	E,26
	CALL	.delayms
; 27.	        SL811Write(CtrlReg,tmp);
	LD	A,.CtrlReg	;0x05
	OUT	(C),A
	LD	HL,0
	ADD	HL,SP
	LD	A,(HL)
	dec B
	OUT	(C),A
; 28.	}   
	POP	HL
	POP	DE
	POP	BC
	RET
; 29.	BYTE sl811_init_my(void)
; 30.	{       
.sl811_init_my:
	PUSH	BC
	PUSH	DE
; 31.	                SL811Write(cSOFcnt, 0xae);  // Set SOF high counter, no change D+/D-SL11Write(CtrlReg, 0x48); // Setup Normal Operation
	LD	A,.cSOFcnt
	LD	BC,0x80ab
	OUT	(C),A
	LD	A,174
	dec	B	;LD	B,0x7f
	OUT	(C),A
	inc b
; 32.	                SL811Write(IntEna, 0x63); // USBA/B, Insert/Remove,USBRest/Resume.
	WRITE_REG .IntEna, 0x63
; 33.	                SL811Write(cSOFcnt, 0xae);  // Set SOF high counter, no change D+/D-SL11Write(CtrlReg, 0x48); // Setup Normal Operation
	WRITE_REG .cSOFcnt, 0xae
; 34.	                SL811Write(CtrlReg, 0);         // Disable USB transfer operation and SOF
	WRITE_REG .CtrlReg, 0x00
; 35.	                SL811Write(cSOFcnt, 0xae);      // Set SOF high counter, no change D+/D-SL11Write(CtrlReg, 0x48); 
	WRITE_REG .cSOFcnt, 0xae
; 36.	                                                                        // Clear SL811H mode and setup normal operation
; 37.	                .delayms(20);     // Delay for HW stablize
	LD	E,2
	CALL	.delayms
; 38.	                SL811Write(CtrlReg, 0);         // Disable USB transfer operation and SOF
	WRITE_REG .CtrlReg, 0
; 39.	                if(SL811Read(IntStatus)==0x05) return FALSE;
	LD	A,13
	OUT	(C),A
	IN	A,(0xab)
	CP	5
	JR	Z,.lo183
.lo010:
.lo011:
; 40.	                
; 41.	                SL811Write(cSOFcnt,0xae);
	WRITE_REG .cSOFcnt,0xae
	call .USBReset
; 42.	                SL811Write(IntEna,0x00);
	WRITE_REG .IntEna,0x00
; 43.	                SL811Write(IntStatus,INT_CLEAR);
	WRITE_REG .IntStatus, 0xFF
; 44.	                .delayms(100);
	LD	E,6
	CALL	.delayms
; 45.	                if((SL811Read(IntStatus)&0xc0)!=0x80) return FALSE;
	LD	A,13
	OUT	(C),A
	IN	a,(0xab)
	AND	0xc0
	cp 0x80
	jr z,.lo013
.lo012:
.lo183:
	XOR	A
; 46.	                puts("'Full' Speed is detected!");      // ** Full Speed is detected ** //   
	JR	.lo014
.lo013:
; 47.	                SL811Write(cSOFcnt,0xae);       // Set up Master & low speed direct and SOF cnt high=0x2e   
	WRITE_REG .cSOFcnt,0xae
; 48.	                SL811Write(cDATASet,0xe0);      // SOF Counter Low = 0xE0; 1ms interval   
	WRITE_REG .cDATASet,0xe0
; 49.	                SL811Write(CtrlReg,0x05);       // Setup 48MHz and SOF enable
	WRITE_REG .CtrlReg,0x05
; 50.	                SL811Write(EP0Status,0x50);     //90);
	WRITE_REG .EP0Status,0x50
; 51.	                SL811Write(EP0Counter,0x00);
	WRITE_REG .EP0Counter,0x00
; 52.	                SL811Write(EP0Control,1);       //sDATA0_RD);   //0x23
	WRITE_REG .EP0Control,1
; 53.	                .delayms(15);
	LD	E,A
	CALL	.delayms
; 54.	                SL811Write(IntEna,0x61);
	WRITE_REG .IntEna,0x61
; 55.	                SL811Write(IntStatus,INT_CLEAR);        //0xff
	WRITE_REG .IntStatus, 0xFF
; 56.	                return TRUE;
	LD	A,1
; 57.	}
.lo014:
	POP	DE
	POP	BC
	RET
; 58.	//*****************************************************************************************   
; 59.	// .usbXfer:   
; 60.	// successful transfer = return TRUE   
; 61.	// fail transfer = return FALSE   
; 62.	//*****************************************************************************************   
; 63.	unsigned char .usbXfer(void)   
; 64.	{     
.usbXfer:
	PUSH	BC
	PUSH	DE
	PUSH	IY
	PUSH	IX
	PUSH	AF
; 65.	    unsigned char xferLen, cmd;   
; 66.	    unsigned char result,remainder,dataX=0x10,bufLen,timeout;   
; 67.	    timeout=TIMEOUT_RETRY;
; 68.	        #define data0 EP0_Buf                    // DATA0 buffer address   
; 69.	    #define data1 (EP0_Buf + 64)                        // DATA1 buffer address   
; 70.	    //------------------------------------------------   
; 71.	    // Define data transfer payload   
; 72.	    //------------------------------------------------   
; 73.	    if (.usbstack.wLen >= 64)          // select proper data payload   
	LD	E,16
	LD	HL,0
	ADD	HL,SP
	LD	(HL),6
	LD	HL,(.usbstack+3)
	LD	BC,64
	AND	A
	SBC	HL,BC
	JR	C,.lo016
.lo015:
; 74.	        xferLen = 64;            // limit to wPayload size    
	LD	IXL,64
; 75.	    else                            // else take < payload len   
	JR	.lo017
.lo016:
; 76.	        xferLen = .usbstack.wLen;            //     
	LD	A,(.usbstack+3)
	LD	IXL,A
.lo017:
; 77.	       
; 78.	    // For IN token   
; 79.	    if (.usbstack.pid==PID_IN)               // for current IN tokens   
	LD	A,(.usbstack+2)
	CP	144
	JR	NZ,.lo019
.lo018:
; 80.	        {
; 81.	                cmd = sDATA0_RD;            // FS/FS on Hub, sync to sof   
	LD	D,35
	JR	.lo025
.lo019:
; 82.	        }   
; 83.	    // For OUT token   
; 84.	    else if(.usbstack.pid==PID_OUT)              // for OUT tokens   
	CP	16
	LD	B,IXL
	JR	NZ,.lo022
.lo021:
; 85.	    {      
; 86.	        if(xferLen)                                 // only when there are     
	INC	B
	DEC	B
	JR	Z,.lo024
.lo023:
; 87.	                {
; 88.	            SL811BufWrite(data0,.usbstack.buffer,xferLen);   // data to transfer on USB  
	PUSH	DE
	LD	HL,.usbstack+5
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	PUSH	BC
	LD	C,IXL
	LD	E,16
	CALL	SL811BUFWRITE
	POP	HL
	POP	DE
.lo024:
; 89.	                }
; 90.	                cmd = sDATA0_WR;                        // FS/FS on Hub, sync to sof 
; 91.	                .uDev.bData1[.usbstack.endpoint]=(cmd |= .uDev.bData1[.usbstack.endpoint])^0x40;
	LD	BC,(.usbstack+1)
	LD	B,0
	LD	HL,.uDev+1
	ADD	HL,BC
	LD	A,(HL)
	OR	39
	LD	D,A
	XOR	64
	LD	BC,(.usbstack+1)
	LD	B,0
	LD	HL,.uDev+1
	ADD	HL,BC
	LD	(HL),A
; 92.	    }   
; 93.	    //------------------------------------------------   
; 94.	    // For SETUP/OUT token   
; 95.	    //------------------------------------------------   
; 96.	    else                                            // for current SETUP/OUT tokens   
	JR	.lo025
.lo022:
; 97.	    {      
; 98.	        if(xferLen)                                 // only when there are     
	INC	B
	DEC	B
	JR	Z,.lo027
.lo026:
; 99.	        {                                       // data to transfer on USB 
; 100.	            SL811BufWrite(data0,&.usbstack.setup.bmRequest,xferLen); 
	PUSH	DE
	LD	HL,.usbstack+7
	PUSH	HL
	LD	C,IXL
	LD	E,16
	CALL	SL811BUFWRITE
	POP	HL
	POP	DE
.lo027:
; 101.	        }   
; 102.	                cmd = sDATA0_WR;                            // FS/FS on Hub, sync to sof   
	LD	D,39
.lo025:
.lo020:
; 103.	    }   
; 104.	    //------------------------------------------------   
; 105.	    // For EP0's IN/OUT token data, start with DATA1   
; 106.	    // Control Endpoint0's status stage.   
; 107.	    // For data endpoint, IN/OUT data, start ????   
; 108.	    //------------------------------------------------   
; 109.	    if (.usbstack.endpoint == 0 && .usbstack.pid != PID_SETUP)    // for Ep0's IN/OUT token   
	LD	A,(.usbstack+1)
	OR	A
	JR	NZ,.lo029
	LD	A,(.usbstack+2)
	CP	208
	JR	Z,.lo029
.lo031:
.lo030:
.lo028:
; 110.	        cmd |= 0x40;                    // always set DATA1   
	SET	6,D
.lo029:
; 111.	    //------------------------------------------------   
; 112.	    // Arming of USB data transfer for the first pkt   
; 113.	    //------------------------------------------------   
; 114.	    SL811Write(EP0Status,((.usbstack.endpoint&0x0F)|.usbstack.pid));  // PID + EP address   
	LD	A,3
	LD	BC,0x80ab
	OUT	(C),A
	ld hl,(.usbstack+1)
	LD	A,l
	AND	15
	OR	H
	dec B
	OUT	(C),A
	inc B
; 115.	    SL811Write(EP0Counter,.usbstack.usbaddr);                    // USB address   
	LD	A,4
	OUT	(C),A
	LD	A,(.usbstack)
	dec B
	OUT	(C),A
	inc B
; 116.	    SL811Write(EP0Address,data0);                   // buffer address, start with "data0"  
	WRITE_REG .EP0Address,16
; 117.	    SL811Write(.ep0XferLen,xferLen);                 // data transfer length   
	LD	A,2
	OUT	(C),A
	LD	A,IXL
	dec B
	OUT	(C),A
	inc B
; 118.	    SL811Write(IntStatus,INT_CLEAR);                // clear interrupt status 
	WRITE_REG .IntStatus,.INT_CLEAR
; 119.	    SL811Write(EP0Control,cmd);                     // Enable ARM and USB transfer start here  
	XOR	A
	OUT	(C),A
	dec B
	OUT	(C),D
.lo033:
; 120.	    //------------------------------------------------   
; 121.	    // Main loop for completing a wLen data trasnfer   
; 122.	    //------------------------------------------------   
; 123.	    while(TRUE)   
.lo034:
.lo036:
; 124.	    {      
; 125.	        //---------------Wait for done interrupt------------------   
; 126.	        while(TRUE)                                             // always ensure requested device is   
.lo037:
; 127.	        {                                                       // inserted at all time, then you will   
; 128.	            result = SL811Read(IntStatus);       
	LD	A,13
	LD	BC,0x80ab
	OUT	(C),A
	dec B
	IN	H,(C)
	LD	B,H
; 129.	                                    // wait for interrupt to be done, and    
; 130.	            if(result & (USB_RESET|INSERT_REMOVE))    // proceed to parse result from slave    
	LD	A,H
	AND	96
	JR	Z,.lo039
.lo038:
; 131.	            {                                                   // device. 
; 132.	                return FALSE;                                   // flag true, so that main loop will    
	XOR	A
	JP	.lo079
.lo039:
; 133.	            }else if(result & USB_A_DONE)                                           // know this condition and exit gracefully   
	BIT	0,B
	JR	Z,.lo033
.lo040:
; 134.	                break;                          // interrupt done !!!   
.lo041:
.lo035:
; 135.	        }   
; 136.	   
; 137.	        SL811Write(IntStatus,INT_CLEAR); // clear interrupt status  
	LD	B,0x80
	WRITE_REG .IntStatus,.INT_CLEAR
; 138.	        result    = SL811Read(EP0Status);                       // read EP0status register   
	LD	A,3
	LD	B,0x80
	OUT	(C),A
	IN	a,(0xab)
	LD	h,a
	LD	IYH,a
; 139.	        remainder = SL811Read(EP0Counter);                      // remainder value in last pkt xfer   
	LD	A,4
	OUT	(C),A
	IN	a,(0xab)
	LD	L,A
	LD	IYL,A
; 140.	   
; 141.	        //-------------------------ACK----------------------------   
; 142.	        if (result & EP0_ACK)                                   // Transmission ACK   
	BIT	0,H
	JP	Z,.lo063
.lo042:
; 143.	        {      
; 144.	   
; 145.	            // SETUP TOKEN   
; 146.	            if(.usbstack.pid == PID_SETUP)                               // do nothing for SETUP/OUT token    
	LD	A,(.usbstack+2)
	CP	208
	JP	Z,.lo032
.lo044:
; 147.	                break;                                          // exit while(1) immediately    
.lo045:
; 148.	            // OUT TOKEN                   
; 149.	            else if(.usbstack.pid == PID_OUT)   
	CP	16
	JP	Z,.lo032
.lo046:
; 150.	                break;     
.lo047:
; 151.	            // IN TOKEN   
; 152.	            else if(.usbstack.pid == PID_IN)   
	CP	144
	JP	NZ,.lo063
.lo048:
; 153.	            {                                                   // for IN token only   
; 154.	                .usbstack.wLen  -= (WORD)xferLen;    // update remainding wLen value   
	LD	HL,.usbstack+3
	LD	C,IXL
	LD	B,0
	LD	A,(HL)
	SUB	C
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	SBC	A,B
	LD	(HL),A
; 155.	                cmd   ^= 0x40;              // toggle DATA0/DATA1   
	LD	A,D
	XOR	64
	LD	D,A
; 156.	                dataX ^= 0x40;                // point to next dataX     
	LD	A,E
	XOR	64
	LD	E,A
; 157.	                //------------------------------------------------     
; 158.	                // If host requested for more data than the slave    
; 159.	                // have, and if the slave's data len is a multiple   
; 160.	                // of its endpoint payload size/last xferLen. Do    
; 161.	                // not overwrite data in previous buffer.   
; 162.	                //------------------------------------------------     
; 163.	                if(remainder==xferLen)          // empty data detected   
	LD	A,IYL
	CP	C
	JR	NZ,.lo051
.lo050:
; 164.	                    bufLen = 0;         // do not overwriten previous data   
	LD	IXH,0
; 165.	                else                    // reset bufLen to zero   
	JR	.lo052
.lo051:
; 166.	                    bufLen = xferLen;       // update previous buffer length   
	LD	IXH,IXL
.lo052:
; 167.	                   
; 168.	                //------------------------------------------------     
; 169.	                // Arm for next data transfer when requested data    
; 170.	                // length have not reach zero, i.e. wLen!=0, and   
; 171.	                // last xferlen of data was completed, i.e.   
; 172.	                // remainder is equal to zero, not a short pkt   
; 173.	                //------------------------------------------------     
; 174.	                if(!remainder && .usbstack.wLen)                         // remainder==0 when last xferLen   
	LD	B,IYL
	INC	B
	DEC	B
	JR	NZ,.lo054
	LD	HL,(.usbstack+3)
	LD	A,L
	OR	H
	JR	Z,.lo054
.lo056:
.lo055:
.lo053:
; 175.	                {                                               // was all completed or wLen!=0   
; 176.	                    xferLen = (BYTE)(.usbstack.wLen>=64) ? 64:.usbstack.wLen;    // get data length required   
	LD	C,64
	SBC	HL,BC
	JR	C,.lo058
	LD	A,C
	JR	.lo059
.lo058:
	LD	A,(.usbstack+3)
.lo059:
	LD	IXL,A
; 177.	                                   
; 178.	                    SL811Write(.ep0XferLen, xferLen);            // select next xfer length   
	LD	A,2
	LD	BC,0x80ab
	OUT	(C),A
	LD	A,IXL
	dec B	;LD	B,0x7f
	OUT	(C),A
	inc B
; 179.	                    SL811Write(EP0Address, dataX); //addr);               // data buffer addr    
	LD	A,1
	OUT	(C),A
	dec B
	OUT	(C),E
	inc B
; 180.	                    SL811Write(IntStatus,INT_CLEAR);            // is a LS is on Hub.   
	LD	A,13
	OUT	(C),A
	LD	A,255
	dec B
	OUT	(C),A
	inc B
; 181.	                    SL811Write(EP0Control,cmd);                 // Enable USB transfer and re-arm   
	XOR	A
	LD	B,0x80
	OUT	(C),A
	dec B
	LD	B,0x7f
	OUT	(C),D
.lo054:
; 182.	                                }                    
; 183.	                //------------------------------------------------   
; 184.	                // Copy last IN token data pkt from prev transfer   
; 185.	                // Check if there was data available during the   
; 186.	                // last data transfer   
; 187.	                //------------------------------------------------   
; 188.	                if(bufLen)                                         
	LD	B,IXH
	INC	B
	DEC	B
	JR	Z,.lo061
.lo060:
; 189.	                {      
; 190.	                    SL811BufRead(dataX^0x40, .usbstack.buffer, bufLen);   
	PUSH	DE
	LD	HL,.usbstack+5
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	PUSH	BC
	LD	C,IXH
	LD	A,E
	XOR	64
	LD	E,A
	CALL	SL811BUFREAD
	POP	HL
	POP	DE
; 191.	                    .usbstack.buffer += bufLen;                                 
	LD	HL,.usbstack+5
	LD	C,IXH
	LD	B,0
	LD	A,(HL)
	ADD	A,C
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
.lo061:
; 192.	                }   
; 193.	                //------------------------------------------------   
; 194.	                // Terminate on short packets, i.e. remainder!=0   
; 195.	                // a short packet or empty data packet OR when    
; 196.	                // requested data len have completed, i.e.wLen=0   
; 197.	                // For a LOWSPEED device, the 1st device descp,   
; 198.	                // wPayload is default to 64-byte, LS device will   
; 199.	                // only send back a max of 8-byte device descp,   
; 200.	                // and host detect this as a short packet, and    
; 201.	                // terminate with OUT status stage   
; 202.	                //------------------------------------------------   
; 203.	                if(remainder || !.usbstack.wLen)   
	LD	B,IYL
	INC	B
	DEC	B
	JR	NZ,.lo032
	LD	HL,(.usbstack+3)
	LD	A,L
	OR	H
	JR	Z,.lo032
.lo064:
.lo065:
.lo062:
; 204.	                    break;   
.lo063:
.lo049:
.lo043:
; 205.	            }// PID IN                             
; 206.	        }   
; 207.	               
; 208.	        //-------------------------NAK----------------------------   
; 209.	        if (result & EP0_NAK)                                   // NAK Detected   
	LD	B,IYH
	BIT	6,B
	JR	Z,.lo067
.lo066:
; 210.	        {                                                          
; 211.	                SL811Write(IntStatus,INT_CLEAR);                // clear interrupt status, need to   
	LD	BC,0x80ab
	WRITE_REG .IntStatus,.INT_CLEAR
; 212.	                SL811Write(EP0Control,cmd);                     // re-arm and request for last cmd, IN token   
	XOR	A
	OUT	(C),A
	dec B
	OUT	(C),D
; 213.	                                result = 0;                                     // respond to NAK status only   
	LD	IYH,0
.lo067:
; 214.	        }         
; 215.	        //-----------------------TIMEOUT--------------------------   
; 216.	        if (result & EP0_TIMEOUT)                               // TIMEOUT Detected   
	LD	B,IYH
	BIT	2,B
	JR	Z,.lo074
.lo068:
; 217.	        {                                                          
; 218.	            if(.usbstack.endpoint==0)                                        // happens when hub enumeration   
	LD	A,(.usbstack+1)
	OR	A
	JR	NZ,.lo032
.lo070:
; 219.	            {   
; 220.	                if((--timeout)==0)   
	LD	L,A
	LD	H,A
	ADD	HL,SP
	DEC	(HL)
	OR	(HL)
	JR	Z,.lo032
.lo072:
; 221.	                {      
; 222.	                    break;                                      // exit on the timeout detected    
.lo073:
; 223.	                }   
; 224.	                SL811Write(IntStatus,INT_CLEAR);                // clear interrupt status, need to   
	LD	BC,0x80ab
	WRITE_REG .IntStatus,.INT_CLEAR
; 225.	                SL811Write(EP0Control,cmd);                     // re-arm and request for last cmd again   
	XOR	A
	OUT	(C),A
	dec B
	OUT	(C),D
; 226.	                        }   
; 227.	            else                                                   
.lo071:
; 228.	            {                                                   // all other data endpoint, data transfer    
; 229.	                break;                                          // happens when data transfer on a device   
.lo074:
.lo069:
; 230.	            }                                                   // through the hub   
; 231.	        }     
; 232.	        //-----------------------STALL----------------------------   
; 233.	        if (result & EP0_STALL)                                 // STALL detected   
	LD	B,IYH
	BIT	7,B
	JR	Z,.lo076
.lo075:
; 234.	            return TRUE;                                        // for unsupported request.                                                                             
	LD	A,1
	JR	.lo079
.lo076:
; 235.	        //----------------------OVEFLOW---------------------------   
; 236.	        if (result & (EP0_OVERFLOW|EP0_ERROR))                              // OVERFLOW detected   
	LD	A,IYH
	AND	34
	JP	Z,.lo033
.lo077:
; 237.	            break;   
.lo078:
.lo032:
; 238.	        //-----------------------ERROR----------------------------   
; 239.	    }   // end of While(1)   
; 240.	    return result & EP0_ACK;
	LD	A,IYH
	AND	1
; 241.	}   
.lo079:
	POP	HL
	POP	IX
	POP	IY
	POP	DE
	POP	BC
	RET
; 242.	//*****************************************************************************************   
; 243.	// Control Endpoint 0's USB Data Xfer   
; 244.	// .ep0Xfer, endpoint 0 data transfer   
; 245.	//*****************************************************************************************   
; 246.	unsigned char .ep0Xfer(void)   
; 247.	{   
.ep0Xfer:
	PUSH	DE
; 248.	    .usbstack.endpoint=0;   
	XOR	A
	LD	(.usbstack+1),A
; 249.	    //----------------------------------------------------   
; 250.	    // SETUP token with 8-byte request on endpoint 0   
; 251.	    //----------------------------------------------------   
; 252.	    .usbstack.pid=PID_SETUP;   
	LD	A,208
	LD	(.usbstack+2),A
; 253.	    .usbstack.wLen=8;   
	LD	HL,8
	LD	(.usbstack+3),HL
; 254.	    if (!.usbXfer())
	CALL	.usbXfer
	OR	A
	JR	Z,.lo191
.lo080:
; 255.	        {       
; 256.	                return FALSE;
; 257.	        }
.lo081:
; 258.	    .usbstack.pid  = PID_IN;   
	LD	A,144
	LD	(.usbstack+2),A
; 259.	    //----------------------------------------------------   
; 260.	    // IN or OUT data stage on endpoint 0      
; 261.	    //----------------------------------------------------   
; 262.	    .usbstack.wLen=.usbstack.setup.wLength;   
	LD	HL,(.usbstack+13)
	LD	(.usbstack+3),HL
; 263.	    if (.usbstack.wLen)                                          // if there are data for transfer   
	LD	A,L
	OR	H
	JR	Z,.lo088
.lo082:
; 264.	    {   
; 265.	        if (.usbstack.setup.bmRequest & 0x80)        // host-to-device : IN token   
	LD	A,(.usbstack+7)
	OR	A
	JP	P,.lo085
.lo084:
; 266.	        {   
; 267.	            .usbstack.pid  = PID_IN;    
	LD	A,144
	LD	(.usbstack+2),A
; 268.	               
; 269.	            if(!.usbXfer())
	CALL	.usbXfer
	OR	A
	JR	Z,.lo191
.lo086:
; 270.	                        {       
; 271.	                                return FALSE;
; 272.	                        }
.lo087:
; 273.	            .usbstack.pid  = PID_OUT;   
	LD	A,16
	JR	.lo188
; 274.	        }   
; 275.	        else                                            // device-to-host : OUT token   
.lo085:
; 276.	        {
; 277.	            .usbstack.pid  = PID_OUT;   
	LD	A,16
	LD	(.usbstack+2),A
; 278.	                   
; 279.	            if(!.usbXfer())
	CALL	.usbXfer
	OR	A
	JR	Z,.lo191
.lo089:
; 280.	                        {       
; 281.	                                return FALSE;
; 282.	                        }
.lo090:
; 283.	            .usbstack.pid  = PID_IN;   
	LD	A,144
.lo188:
	LD	(.usbstack+2),A
.lo088:
.lo083:
; 284.	        }   
; 285.	    }   
; 286.	    .delayms(10);   
	LD	E,1
	CALL	.delayms
; 287.	    //----------------------------------------------------   
; 288.	    // Status stage IN or OUT zero-length data packet   
; 289.	    //----------------------------------------------------   
; 290.	    .usbstack.wLen=0;   
	LD	HL,0
	LD	(.usbstack+3),HL
; 291.	    if(!.usbXfer())
	CALL	.usbXfer
	OR	A
	JR	NZ,.lo092
.lo091:
; 292.	        {       
; 293.	                return FALSE;
.lo191:
	XOR	A
; 294.	        }
	JR	.lo093
.lo092:
; 295.	    return TRUE;                                               
	LD	A,1
; 296.	}   
.lo093:
	POP	DE
	RET
; 297.	
; 298.	unsigned char .epBulkSend(unsigned char *pBuffer,unsigned int len)   
; 299.	{
.epBulkSend:
	PUSH	IX
	PUSH	DE
	PUSH	BC
	POP	IX
; 300.	    .usbstack.usbaddr=myusbaddr;   
	LD	A,1
	LD	(.usbstack),A
; 301.	    .usbstack.endpoint=.usbstack.epbulkout;   
	LD	A,(.usbstack+16)
	LD	(.usbstack+1),A
; 302.	    .usbstack.pid=PID_OUT;     
	LD	A,16
	LD	(.usbstack+2),A
; 303.	    .usbstack.wLen=len;   
	LD	(.usbstack+3),BC
; 304.	    .usbstack.buffer=pBuffer;   
	LD	L,E
	LD	H,D
	LD	(.usbstack+5),HL
.lo095:
; 305.	    while(len>0)   
	LD	A,IXL
	OR	IXH
	JR	Z,.lo094
.lo096:
; 306.	    {   
; 307.	        if (len >= 64)   
	LD	BC,64
	PUSH	IX
	POP	HL
	SBC	HL,BC
	JR	C,.lo098
.lo097:
; 308.	            .usbstack.wLen = 64;   
	LD	L,C
	LD	H,B
	JR	.lo193
; 309.	        else                   
.lo098:
; 310.	            .usbstack.wLen = len; 
	PUSH	IX
	POP	HL
.lo193:
	LD	(.usbstack+3),HL
.lo099:
; 311.	        disable_interrupt();
	DI
.lo101:
; 312.	        while(!.usbXfer()){
	CALL	.usbXfer
	OR	A
	EI
	JR	Z,.lo103
.lo102:
; 313.	                enable_interrupt();
; 314.	                puts(".epBulkSend ERROR");
; 315.	            return FALSE;
; 316.	        } 
.lo100:
; 317.	        enable_interrupt(); 
; 318.	        len-=.usbstack.wLen;   
	LD	BC,(.usbstack+3)
	PUSH	IX
	POP	HL
	AND	A
	SBC	HL,BC
	PUSH	HL
	POP	IX
; 319.	        .usbstack.buffer=.usbstack.buffer+.usbstack.wLen;   
	LD	HL,.usbstack+5
	LD	A,(HL)
	ADD	A,C
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
	JR	.lo095
.lo094:
; 320.	    }   
; 321.	    return TRUE;       
	LD	A,1
; 322.	}   
.lo103:
	POP	HL
	POP	IX
	RET
; 323.	   
; 324.	unsigned char .epBulkRcv(unsigned char *pBuffer,unsigned int len)   
; 325.	{   
.epBulkRcv:
	PUSH	IX
	LD	IX,0
	ADD	IX,SP
	PUSH	BC
	PUSH	DE
; 326.	    .usbstack.usbaddr=myusbaddr;   
	LD	A,1
	LD	(.usbstack),A
; 327.	    .usbstack.endpoint=.usbstack.epbulkin;   
	LD	A,(.usbstack+15)
	LD	(.usbstack+1),A
; 328.	    .usbstack.pid=PID_IN;    
	LD	A,144
	LD	(.usbstack+2),A
; 329.	    .usbstack.wLen=len;   
	LD	(.usbstack+3),BC
; 330.	    .usbstack.buffer=pBuffer;
	LD	(.usbstack+5),DE
; 331.	    if(.usbstack.wLen)   
	LD	A,C
	LD	H,B
	OR	H
	JR	Z,.lo106
.lo104:
; 332.	    {    
; 333.	        disable_interrupt();  
	DI
.lo107:
; 334.	        while(!.usbXfer()){
	CALL	.usbXfer
	OR	A
	EI
	JR	Z,.lo109
.lo108:
; 335.	                enable_interrupt(); 
; 336.	            return FALSE; 
; 337.	        } 
.lo106:
; 338.	        enable_interrupt();    
.lo105:
; 339.	    }   
; 340.	    return TRUE;   
	LD	A,1
; 341.	}   
.lo109:
	LD	SP,IX
	POP	IX
	RET
; 342.	   
; 343.	//*****************************************************************************************   
; 344.	// Set Device Address :    
; 345.	//*****************************************************************************************   
; 346.	unsigned char SetAddress(unsigned char addr)   
; 347.	{   
.SetAddress:
	PUSH	BC
	PUSH	DE
; 348.	    .usbstack.usbaddr=0;   
	XOR	A
	LD	(.usbstack),A
; 349.	    .usbstack.setup.bmRequest=0;   
	LD	(.usbstack+7),A
; 350.	    .usbstack.setup.bRequest=SET_ADDRESS;   
	LD	A,5
	LD	(.usbstack+8),A
; 351.	    .usbstack.setup.wValue=addr;   
	LD	C,E
	LD	B,0
	LD	(.usbstack+9),BC
; 352.	    .usbstack.setup.wIndex=0;   
	LD	L,B
	LD	H,B
	LD	(.usbstack+11),HL
; 353.	    .usbstack.setup.wLength=0;   
	LD	(.usbstack+13),HL
; 354.	    return .ep0Xfer();   
	CALL	.ep0Xfer
; 355.	}   
	POP	HL
	POP	BC
	RET
; 356..	
; 357.	//*****************************************************************************************   
; 358.	// Set Device Configuration :    
; 359.	//*****************************************************************************************   
; 360.	unsigned char Set_Configuration(void)   
; 361.	{   
.Set_Configuration:
; 362.	    .usbstack.setup.bmRequest=0;   
	XOR	A
	LD	(.usbstack+7),A
; 363.	    .usbstack.setup.bRequest=SET_CONFIG;   
	LD	A,9
	LD	(.usbstack+8),A
; 364.	    .usbstack.setup.wIndex=0;   
	LD	HL,0
	LD	(.usbstack+11),HL
; 365.	    .usbstack.setup.wLength=0;   
	LD	(.usbstack+13),HL
; 366.	    .usbstack.buffer=NULL;   
	LD	(.usbstack+5),HL
; 367.	    return .ep0Xfer();   
	JP	.ep0Xfer
; 368.	}
; 369.	
; 370.	//*****************************************************************************************   
; 371.	// Get Device Descriptor : Device, Configuration, String   
; 372.	//*****************************************************************************************   
; 373.	unsigned char GetDesc(void)   
; 374.	{    
.GetDesc:
	PUSH	BC
; 375.	    .usbstack.setup.bmRequest=0x80;   
	LD	A,0x80
	LD	(.usbstack+7),A
; 376.	    .usbstack.setup.bRequest=GET_DESCRIPTOR;   
	LD	A,6
	LD	(.usbstack+8),A
; 377.	    .usbstack.setup.wValue=.usbstack.setup.wValue<<8; 
	LD	HL,.usbstack+9
	LD	B,(HL)
	LD	(HL),0
	INC	HL
	LD	(HL),B
; 378.	    return .ep0Xfer();   
	CALL	.ep0Xfer
; 379.	}   
	POP	BC
	RET
; 380.	   
; 381.	//*****************************************************************************************   
; 382.	// USB Device Enumeration Process   
; 383.	// Support 1 confguration and interface #0 and alternate setting #0 only   
; 384.	// Support up to 1 control endpoint + 4 data endpoint only   
; 385.	//*****************************************************************************************   
; 386.	unsigned char EnumUsbDev(void)   
; 387.	{
.EnumUsbDev:
	PUSH	BC
	PUSH	DE
	PUSH	IX
	PUSH	AF
	PUSH	AF
; 388.	    unsigned char i;                                    // always reset USB transfer address    
; 389.	    unsigned char uAddr = 0;                            // for enumeration to Address #0   
; 390.	    unsigned char epLen;
; 391.	
; 392.	    //------------------------------------------------   
; 393.	    // Reset only Slave device attached directly   
; 394.	    //------------------------------------------------   
; 395.	    //.uDev.wPayLoad[0] = 64;  // default 64-byte payload of Endpoint 0, address #0   
; 396.	    if(myusbaddr == 1)        // bus reset for the device attached to SL811HS only   
.lo110:
; 397.	        USBReset();     // that will always have the USB address = 0x01 (for a hub)
	CALL	.USBReset
.lo111:
; 398.	    //------------------------------------------------   
; 399.	    // Set Slave USB Device Address   
; 400.	    //------------------------------------------------
; 401.	    if (!SetAddress(myusbaddr))                       // set to specific USB address   
	LD	E,1
	CALL	.SetAddress
	OR	A
	JR	Z,.lo198
.lo112:
; 402.	        return FALSE;                               //   
.lo113:
; 403.	    uAddr = myusbaddr;                                // transfer using this new address   
; 404.	
; 405.	    //------------------------------------------------   
; 406.	    // Get Slave USB Configuration Descriptors   
; 407.	    //------------------------------------------------   
; 408.	    .usbstack.usbaddr=uAddr;   
	LD	A,1
	LD	(.usbstack),A
; 409.	    .usbstack.setup.wValue=CONFIGURATION;   
	LD	HL,2
	LD	(.usbstack+9),HL
; 410.	    .usbstack.setup.wIndex=0;   
	DEC	HL
	DEC	HL
	LD	(.usbstack+11),HL
; 411.	    .usbstack.setup.wLength=64;   
	LD	L,64
	LD	(.usbstack+13),HL
; 412.	    .usbstack.buffer=.DBUF;      
	LD	HL,.DBUF
	LD	(.usbstack+5),HL
; 413.	    if (!GetDesc())
	LD	IXH,1
	CALL	.GetDesc
	OR	A
	JR	Z,.lo198
.lo114:
; 414.	        return FALSE;        
.lo115:
; 415.	    .uDev.bNumOfEPs = (.DBUF[9+4] <= MAX_EP) ? .DBUF[9+4] : MAX_EP;   
	LD	A,(.DBUF+13)
	LD	B,A
	LD	A,5
	CP	B
	JR	C,.lo117
	LD	A,(.DBUF+13)
.lo117:
	LD	(.uDev),A
; 416.	    if(.DBUF[9+5]==8) //mass storage device   
	LD	A,(.DBUF+14)
	CP	8
	JR	NZ,.lo120
.lo119:
; 417.	        .bFlags.bits.bMassDevice=TRUE;   
	LD	A,1
	LD	(.bFlags),A
.lo120:
; 418.	    //------------------------------------------------   
; 419.	    // Set configuration (except for HUB device)   
; 420.	    //------------------------------------------------   
; 421.	    .usbstack.usbaddr=uAddr;   
	LD	A,IXH
	LD	(.usbstack),A
; 422.	    .usbstack.setup.wValue=DEVICE;   
	LD	HL,1
	LD	(.usbstack+9),HL
; 423.	                                        // enumerating a FS/LS non-hub device   
; 424.	        if (!Set_Configuration())       // connected directly to SL811HS   
	CALL	.Set_Configuration
	OR	A
	JR	NZ,.lo122
.lo121:
; 425.	                return FALSE;   
.lo198:
	XOR	A
	JR	.lo132
.lo122:
; 426.	
; 427.	    //------------------------------------------------   
; 428.	    // For each slave endpoints, get its attributes   
; 429.	    // Excluding endpoint0, only data endpoints   
; 430.	    //------------------------------------------------   
; 431.	
; 432.	    epLen = 0;   
; 433.	    for (i=1; i<=.uDev.bNumOfEPs; i++)                // For each data endpoint   
	LD	E,0
	LD	IXL,1
.lo124:
	LD	A,(.uDev)
	CP	IXL
	JR	C,.lo123
.lo125:
; 434.	    {
; 435.	        unsigned char bEPAddr  = .DBUF[9 + 9 + epLen+2];    // Ep address and direction  
	LD	HL,.DBUF+20
	LD	C,E
	LD	B,0
	ADD	HL,BC
	LD	D,(HL)
; 436.	        if(.DBUF[9 + 9 + epLen+3]==0x2)     //bulk transfer   
	LD	HL,.DBUF+21
	ADD	HL,BC
	LD	B,(HL)
	DEC	B
	DEC	B
	JR	NZ,.lo131
.lo127:
; 437.	        {
; 438.	            if(bEPAddr&0x80)
	BIT	7,D
	LD	A,D
	JR	Z,.lo130
.lo129:
; 439.	                .usbstack.epbulkin=bEPAddr;
	LD	(.usbstack+15),A
; 440.	            else   
	JR	.lo131
.lo130:
; 441.	                .usbstack.epbulkout=bEPAddr;
	LD	(.usbstack+16),A
.lo131:
.lo128:
; 442.	        }           
; 443.	        .uDev.bData1[i] = 0;                     // init data toggle   
	LD	HL,.uDev+1
	LD	C,IXL
	LD	B,0
	ADD	HL,BC
	LD	(HL),B
; 444.	        epLen += 7;   
	LD	A,E
	ADD	A,7
	LD	E,A
	INC	IXL
	JR	.lo124
.lo123:
; 445.	        //////////////////////////////   
; 446.	        //////////////////////////////   
; 447.	    }
; 448.	    return TRUE;   
	LD	A,1
; 449.	}
.lo132:
	POP	HL
	POP	HL
	POP	IX
	POP	DE
	POP	BC
	RET
; 450.	unsigned char .outbuf[0x20];   
; 451.	///////////////////////////////////////////////////////////////////////////   
; 452.	unsigned char EnumMassDev(void)   
; 453.	{   
.EnumMassDev:
; 454.	    if(!.SPC_Inquiry())
	CALL	.SPC_Inquiry
	OR	A
	JR	NZ,.lo134
.lo133:
; 455.	        return 0x81;//FALSE;   
	LD	A,1
	RET
.lo134:
; 456.	    if(!SPC_TestUnit())   
	CALL	.SPC_TestUnit
	OR	A
	JR	NZ,.lo136
.lo135:
; 457.	        return 0x82;//FALSE;   
	LD	A,1
	RET
.lo136:
; 458.	    if(!SPC_LockMedia())   
	CALL	.SPC_LockMedia
	OR	A
	JR	NZ,.lo138
.lo137:
; 459.	        return 0x83;//FALSE;   
	LD	A,1
	RET
.lo138:
; 460.	    if(!SPC_RequestSense())   
	CALL	.SPC_RequestSense
	OR	A
	JR	NZ,.lo140
.lo139:
; 461.	        return 0x84;//FALSE;   
	LD	A,1
	RET
.lo140:
; 462.	    if(!SPC_TestUnit())   
	CALL	.SPC_TestUnit
	OR	A
	JR	NZ,.lo142
.lo141:
; 463.	        return 0x85;//FALSE;   
	LD	A,1
	RET
.lo142:
; 464.	    if(!.RBC_ReadCapacity())   
	CALL	.RBC_ReadCapacity
	OR	A
	JR	NZ,.lo144
.lo143:
; 465.	        return 0x86;//FALSE;   
	LD	A,1
	RET
.lo144:
; 466.	   
; 467.	    ////////////////////////////////////////////////////   
; 468.	    //DeviceInfo.BPB_BytesPerSec=512; //SectorSize 512   
; 469.	       
; 470.	    if(!SPC_RequestSense())   
	CALL	.SPC_RequestSense
	OR	A
	JR	NZ,.lo146
.lo145:
; 471.	        return 0x87;//FALSE;   
	LD	A,1
	RET
.lo146:
; 472.	    if(!SPC_TestUnit())   
	CALL	.SPC_TestUnit
	OR	A
	JR	NZ,.lo148
.lo147:
; 473.	        return 0x88;//FALSE;   
	LD	A,1
	RET
.lo148:
; 474.	    if(!.RBC_ReadCapacity())   
	CALL	.RBC_ReadCapacity
	OR	A
	JR	NZ,.lo150
.lo149:
; 475.	        return 0x89;//FALSE;   
	LD	A,1
	RET
.lo150:
; 476.	    ////////////////////////////////////////////////////   
; 477.	    //if(!.RBC_Read(0x0,1,.DBUF))   
; 478.	    //   return 0x8a;//FALSE;   
; 479.	    //////////////////////////////////
; 480.	
; 481.	    return TRUE;   
	LD	A,0
; 482.	}   
.lo151:
	RET
; 483.	
; 484.	const unsigned char .data00[25]={
; 485.	        0x55,0x53,0x42,0x43,0x60,0xa6,0x24,0xde,   
; 486.	        0x24,0x00,0x00,0x00,0x80,0x00,0x06,SPC_CMD_INQUIRY,
; 487.	        0x00,0x00,0x00,0x24,}; 
; 488.	             
; 489.	unsigned char .SPC_Inquiry(void)   
; 490.	{   
.SPC_Inquiry:
	PUSH	BC
	PUSH	DE
; 491.	    memcpy(.outbuf,.data00,21); 
	LD	BC,21
	LD	DE,.outbuf
	LD	HL,.data00
	LDIR
; 492.	    if(!.epBulkSend(.outbuf,0x1f))      
	CALL	.lo208
	OR	A
	JR	Z,.lo201
.lo152:
; 493.	        return FALSE;   
.lo153:
; 494.	    .delayms(150);   
	LD	E,8
	CALL	.delayms
; 495.	    if(!.epBulkRcv(.DBUF,36))   
	LD	BC,36
	LD	DE,.DBUF
	CALL	.epBulkRcv
	OR	A
	JR	Z,.lo201
.lo154:
; 496.	        return FALSE;      
.lo155:
; 497.	    if(!.epBulkRcv(.outbuf,13))   
	CALL	.lo210
	OR	A
	JR	NZ,.lo157
.lo156:
; 498.	        return FALSE;     
.lo201:
	XOR	A
	JR	.lo158
.lo157:
; 499.	    return TRUE;       
	LD	A,1
; 500.	}   
.lo158:
	POP	DE
	POP	BC
	RET
.lo209:
	LD	(.outbuf+19),A
.lo208:
	LD	C,31
	LD	DE,.outbuf
	JP	.epBulkSend
.lo212:
	LD	E,1
	CALL	.delayms
.lo210:
	LD	BC,13
.lo211:
	LD	DE,.outbuf
	JP	.epBulkRcv
; 501.	   
; 502.	unsigned char SPC_RequestSense(void)   
; 503.	{   
.SPC_RequestSense:
	PUSH	BC
	PUSH	DE
; 504.	    memcpy(.outbuf,.data00,21);  
	LD	BC,21
	LD	DE,.outbuf
	LD	HL,.data00
	LDIR
; 505.	    .outbuf[8]=0x0e;   
	LD	A,14
	LD	(.outbuf+8),A
; 506.	    .outbuf[15]=SPC_CMD_REQUESTSENSE;
	LD	A,3
	LD	(.outbuf+15),A
; 507.	    .outbuf[19]=0x0e;        
	LD	A,14
; 508.	    if(!.epBulkSend(.outbuf,0x1f))      
	CALL	.lo209
	OR	A
	JR	Z,.lo203
.lo159:
; 509.	        return FALSE;   
.lo160:
; 510.	    .delayms(5);   
	LD	E,1
	CALL	.delayms
; 511.	    if(!.epBulkRcv(.outbuf,18))   
	LD	BC,18
	CALL	.lo211
	OR	A
	JR	Z,.lo203
.lo161:
; 512.	        return FALSE; 
.lo162:
; 513.	    if(!.epBulkRcv(.outbuf,13))   
	CALL	.lo210
	OR	A
	JR	NZ,.lo164
.lo163:
; 514.	        return FALSE;     
.lo203:
	XOR	A
	JR	.lo165
.lo164:
; 515.	    return TRUE;   
	LD	A,1
; 516.	}   
.lo165:
	POP	DE
	POP	BC
	RET
; 517.	   
; 518.	unsigned char SPC_TestUnit(void)   
; 519.	{   
.SPC_TestUnit:
	PUSH	BC
	PUSH	DE
; 520.	    memcpy(.outbuf,.data00,21);  
	LD	BC,21
	LD	DE,.outbuf
	LD	HL,.data00
	LDIR
; 521.	    ////////////////////////////////      
; 522.	    .outbuf[8]=0x00;  
	XOR	A
	LD	(.outbuf+8),A
; 523.	    .outbuf[12]=0x00;
	LD	(.outbuf+12),A
; 524.	    /////////////////////////////////////      
; 525.	    .outbuf[15]=SPC_CMD_TESTUNITREADY;   
	LD	(.outbuf+15),A
; 526.	    .outbuf[19]=0;  
; 527.	    //////////////////////////////////////   
; 528.	    if(!.epBulkSend(.outbuf,0x1f))
	CALL	.lo209
	OR	A
	JR	Z,.lo204
.lo166:
; 529.	        return FALSE;
.lo167:
; 530.	    .delayms(5);   
; 531.	    if(!.epBulkRcv(.outbuf,13))
	CALL	.lo212
	OR	A
	JR	NZ,.lo169
.lo168:
; 532.	        return FALSE;
.lo204:
	XOR	A
	JR	.lo170
.lo169:
; 533.	    return TRUE;   
	LD	A,1
; 534.	}   
.lo170:
	POP	DE
	POP	BC
	RET
; 535.	   
; 536.	unsigned char SPC_LockMedia(void)   
; 537.	{   
.SPC_LockMedia:
	PUSH	BC
	PUSH	DE
; 538.	    memcpy(.outbuf,.data00,21);      
	LD	BC,21
	LD	DE,.outbuf
	LD	HL,.data00
	LDIR
; 539.	    .outbuf[8]=0x00;   
	XOR	A
	LD	(.outbuf+8),A
; 540.	    .outbuf[12]=0x00;
	LD	(.outbuf+12),A
; 541.	    .outbuf[14]=5;   
	LD	A,5
	LD	(.outbuf+14),A
; 542.	    ///////////////////////////////////////////   
; 543.	    .outbuf[15]=SPC_CMD_PRVENTALLOWMEDIUMREMOVAL;   
	LD	A,30
	LD	(.outbuf+15),A
; 544.	    .outbuf[19]=1;   
	LD	A,1
; 545.	    ///////////////////////////////////////////   
; 546.	    if(!.epBulkSend(.outbuf,0x1f))      
	CALL	.lo209
	OR	A
	JR	Z,.lo205
.lo171:
; 547.	        return FALSE;   
.lo172:
; 548.	    .delayms(5);   
; 549.	   
; 550.	    if(!.epBulkRcv(.outbuf,13))   
	CALL	.lo212
	OR	A
	JR	NZ,.lo174
.lo173:
; 551.	        return FALSE;   
.lo205:
	XOR	A
	JR	.lo175
.lo174:
; 552.	   
; 553.	/////////////////////////////   
; 554.	    return TRUE;   
	LD	A,1
; 555.	}   
.lo175:
	POP	DE
	POP	BC
	RET
; 556.	   
; 557.	unsigned char .RBC_ReadCapacity(void)   
; 558.	{   
.RBC_ReadCapacity:
	PUSH	BC
	PUSH	DE
; 559.	    memcpy(.outbuf,.data00,25);    
	LD	BC,25
	LD	DE,.outbuf
	LD	HL,.data00
	LDIR
; 560.	    .outbuf[8]=0x08;     
	LD	A,8
	LD	(.outbuf+8),A
; 561.	    .outbuf[14]=10;   
	LD	A,10
	LD	(.outbuf+14),A
; 562.	    /////////////////////////////////////   
; 563.	    .outbuf[15]=RBC_CMD_READCAPACITY;
	LD	A,37
	LD	(.outbuf+15),A
; 564.	    .outbuf[19]=0;
	XOR	A
; 565.	    /////////////////////////////////////   
; 566.	    if(!.epBulkSend(.outbuf,0x1f))      
	CALL	.lo209
	OR	A
	JR	Z,.lo207
.lo176:
; 567.	        return FALSE;   
.lo177:
; 568.	    .delayms(10);   
	LD	E,1
	CALL	.delayms
; 569.	    if(!.epBulkRcv(.DBUF,8))   
	LD	BC,8
	LD	DE,.DBUF
	CALL	.epBulkRcv
	OR	A
	JR	Z,.lo207
.lo178:
; 570.	        return FALSE;   
.lo179:
; 571.	    if(!.epBulkRcv(.outbuf,13))   
	CALL	.lo210
	OR	A
	JR	NZ,.lo181
.lo180:
; 572.	        return FALSE;   
.lo207:
	XOR	A
	JR	.lo182
.lo181:
; 573.	    /////////////////////////////   
; 574.	    return TRUE;   
	LD	A,1
; 575.	}   
.lo182:
	POP	DE
	POP	BC
	RET
	;RSEG	CONST
.data00:
	DEFB	'U'
	DEFB	'S'
	DEFB	'B'
	DEFB	'C'
	DEFB	'`'
	DEFB	166
	DEFB	'$'
	DEFB	222
	DEFB	'$'
	DEFB	0
	DEFB	0
	DEFB	0
	DEFB	128
	DEFB	0
	DEFB	6
	DEFB	18
	DEFB	0
	DEFB	0
	DEFB	0
	DEFB	'$'
	DEFB	0,0,0,0,0
	;RSEG	NO_INIT
.bFlags:
	DEFS	1
.usbstack:
	DEFS	17
;.DBUF:
;	DEFS	1024
.uDev:
	DEFS	6
	;RSEG	UDATA0
.outbuf:
	DEFS	32
	
	
.delayms
	halt
	dec e
	jr nz,.delayms
	ret
	
	;bcde=lba,hl=buf,a'=count
.RBC_Read
	push hl
	ld hl,0xa660
	ld (.outbuf+4),hl
	ld hl,0xde24
	ld (.outbuf+6),hl
	ld hl,0x0080
	ld (.outbuf+12),hl
	ld hl,0x2810	;RBC_CMD_READ10
	ld (.outbuf+14),hl
	call .send_cmd
	pop de ;buffer
	ret z
	call .epBulkRcv
	jr .RBC_rw_end
.RBC_Write
	push hl
	ld hl,0xd9b4
	ld (.outbuf+4),hl
	ld hl,0xc177
	ld (.outbuf+6),hl
	ld hl,0x0000
	ld (.outbuf+12),hl
	ld hl,0x2a10	;RBC_CMD_WRITE10
	ld (.outbuf+14),hl
	call .send_cmd
	pop de ;buffer
	ret z
	call .epBulkSend
.RBC_rw_end
	or a
	ret z
	ld de,.outbuf
	ld bc,13
	call .epBulkRcv
	or a
	ld a,0
	ret nz
	ld de,.outbuf
	ld bc,13
	call .epBulkRcv
	xor a
	ret
	
.send_cmd	;out bc=length
	ld hl,0x5355
	ld (.outbuf+0),hl
	ld hl,0x4342
	ld (.outbuf+2),hl
	ld hl,.outbuf+16
	ld (hl),0
	inc hl
	ld (hl),b	;LBA
	inc hl
	ld (hl),c
	inc hl
	ld (hl),d
	inc hl
	ld (hl),e
	ex af,af'
	ld l,a
	ld h,0
	ld (.outbuf+23),hl
	ld b,l		;count*512
	sla b
	ld c,h
	ld (.outbuf+8),bc	;(long)bytes length
	ld l,h
	ld (.outbuf+10),hl
	ld (.outbuf+21),hl
	push bc
	ld bc,0x82ab
	in a,(c)
	and 0xaf		;хост-мод и сл811 в портах
	out (c),a	
	ld de,.outbuf
	ld bc,31
	call .epBulkSend
	pop bc
	or a
	ret

	
.SL11HardReset
	push bc
	ld bc,0x83ab	;ресет sl811
	in a,(c)
	and 0xdf
	out (c),a
	ld b,0x82		;сняли питание с разъёма
	in a,(c)
	or 0x40
	out (c),a
	;ld e,2;0xff&(2000+20)/20		;пару секунд чтоп девайс сдох совсем
	;call .delayms
	ld bc,0x82ab
	in a,(c)
	and 0xaf		;хост-мод и сл811 в портах
	out (c),a	
	ld e,2;0xff&(50+20)/20
	call .delayms
	ld bc,0x83ab
	in a,(c)
	or 0x20
	out (c),a		;убрали ресет	
	pop bc
	ret
		
	
SL811BUFWRITE	
	pop af
	pop hl
	push hl
	push af
	;HL-buf,E-reg, C-count
	ld a,c
.wrloop
	ld bc,0x80ab
	out (c),e
	inc e
	ld b,a
	outi
	ld a,b
	jp nz,.wrloop
	ret
	
SL811BUFREAD	
	pop af
	pop hl
	push hl
	push af
	;HL-buf,E-reg, C-count
	ld a,c
.rdloop
	ld bc,0x80ab
	out (c),e
	inc e
	ld b,a
	ini
	ld a,b
	jp nz,.rdloop
	ret