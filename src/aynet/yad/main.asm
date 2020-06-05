	NAME	main(16)
	RSEG	CODE(0)
	RSEG	CSTR(0)
	RSEG	NO_INIT(0)
	RSEG	IDATA0(0)
	RSEG	CDATA0(0)
	EXTERN	OS_ACCEPT
	EXTERN	OS_BIND
	EXTERN	OS_GETMAINPAGES
	EXTERN	OS_LISTEN
	EXTERN	OS_NETCLOSE
	EXTERN	OS_NETRECV
	EXTERN	OS_NETRECVFROM
	EXTERN	OS_NETSEND
	EXTERN	OS_NETSENDTO
	EXTERN	OS_NETSOCKET
	EXTERN	OS_SETGFX
	EXTERN	OS_SETMUSIC
	EXTERN	YIELD
	EXTERN	_low_level_get
	PUBLIC	app_pages
	EXTERN	buf_rx
	PUBLIC	cmds
	PUBLIC	datasoc
	EXTERN	errno
	PUBLIC	exit
	EXTERN	flag_int_change
	EXTERN	flag_syncrply
	EXTERN	getchar
	PUBLIC	grmod
	EXTERN	htons
	PUBLIC	initMCU
	EXTERN	int_null
	EXTERN	int_play
	PUBLIC	len
	PUBLIC	main
	EXTERN	msg_framesync
	EXTERN	msg_hello
	EXTERN	printf
	PUBLIC	ptr
	EXTERN	ptr_in_rx
	EXTERN	ptr_increment
	EXTERN	ptr_out_rx
	EXTERN	puts
	PUBLIC	putserr
	PUBLIC	scrredraw
	EXTERN	shutup
	EXTERN	strtoul
	PUBLIC	udp_buf
	PUBLIC	udpr_ia
	PUBLIC	udps
	PUBLIC	udps_ia
	PUBLIC	web_ia
	EXTERN	?CLZ80L_4_06_L00
	RSEG	CODE
scrredraw:
	PUSH	DE
	LD	DE,msg_hello+2
	CALL	puts
	XOR	A
	POP	DE
	RET
exit:
	PUSH	BC
	PUSH	IY
	PUSH	IX
	LD	IX,0
	ADD	IX,SP
	PUSH	DE
	POP	IY
	CALL	shutup
	LD	A,(cmds)
	OR	A
	JR	Z,?0011
?0010:
	LD	BC,(cmds)
	LD	E,0
	CALL	OS_NETCLOSE
?0011:
	LD	A,(datasoc)
	OR	A
	JR	Z,?0013
?0012:
	LD	BC,(datasoc)
	LD	E,0
	CALL	OS_NETCLOSE
?0013:
	LD	A,(udps)
	OR	A
	JR	Z,?0015
?0014:
	LD	BC,(udps)
	LD	E,0
	CALL	OS_NETCLOSE
?0015:
	LD	A,IYL
	OR	IYH
	JR	Z,?0017
?0016:
	LD	E,6
	CALL	OS_SETGFX
	PUSH	IY
	POP	DE
	CALL	puts
	LD	DE,?0018
	CALL	puts
	CALL	getchar
?0017:
	PUSH	IY
	POP	DE
	CALL	0
	LD	SP,IX
	POP	IX
	POP	IY
	POP	BC
	RET
initMCU:
	PUSH	BC
	PUSH	DE
	CALL	YIELD
	CALL	OS_GETMAINPAGES
	LD	(app_pages),HL
	LD	(app_pages+2),BC
	LD	E,6
	CALL	OS_SETGFX
	LD	DE,msg_hello+2
	CALL	puts
	POP	DE
	POP	BC
	RET
putserr:
	PUSH	IX
	LD	IX,0
	ADD	IX,SP
	PUSH	BC
	PUSH	DE
	LD	A,(grmod)
	OR	A
	JR	NZ,?0020
?0019:
	LD	E,6
	CALL	OS_SETGFX
	LD	A,1
	LD	(grmod),A
?0020:
	LD	L,(IX-2)
	LD	H,(IX-1)
	PUSH	HL
	LD	L,(IX-4)
	LD	H,(IX-3)
	PUSH	HL
	LD	HL,?0021
	PUSH	HL
	CALL	printf
	POP	AF
	POP	AF
	POP	AF
	LD	SP,IX
	POP	IX
	RET
main:
	PUSH	IX
	LD	IX,0
	ADD	IX,SP
	PUSH	BC
	PUSH	DE
	PUSH	AF
	PUSH	AF
	LD	IY,1
	CALL	initMCU
	LD	HL,buf_rx
	LD	(ptr_out_rx),HL
	LD	HL,buf_rx+4096
	LD	(ptr_in_rx),HL
	LD	DE,16729
	CALL	htons
	LD	(web_ia+1),HL
	LD	DE,16729
	CALL	htons
	LD	(udpr_ia+1),HL
?0023:
	LD	L,(IX-4)
	LD	H,(IX-3)
	PUSH	IY
	POP	BC
	AND	A
	SBC	HL,BC
	JR	Z,?0022
?0024:
	PUSH	IY
	POP	HL
	ADD	HL,HL
	LD	C,(IX-2)
	LD	B,(IX-1)
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	LD	(IX-6),L
	LD	(IX-5),H
	LD	A,(HL)
	CP	45
	JR	Z,?0026
?0025:
	LD	DE,?0027
	CALL	exit
?0026:
	LD	L,(IX-6)
	LD	H,(IX-5)
	INC	HL
	LD	B,(HL)
	RES	5,B
	LD	A,B
	CP	80
	JR	NZ,?0030
?0029:
	LD	HL,10
	PUSH	HL
	LD	BC,ptr
	LD	E,(IX-6)
	LD	D,(IX-5)
	INC	DE
	INC	DE
	CALL	strtoul
	POP	AF
	EX	DE,HL
	CALL	htons
	LD	(web_ia+1),HL
	JR	?0028
?0030:
	LD	DE,?0027
	CALL	exit
?0028:
	INC	IY
	JR	?0023
?0022:
	LD	DE,513
	CALL	OS_NETSOCKET
	LD	(cmds),A
	LD	C,A
	LD	DE,web_ia
	CALL	OS_BIND
	LD	BC,(cmds)
	LD	DE,0
	CALL	OS_LISTEN
?0032:
	XOR	A
	INC	A
?0063:
?0033:
	LD	A,(datasoc)
	OR	A
	JP	NZ,?0035
?0034:
	LD	A,(udps)
	OR	A
	JR	NZ,?0037
?0036:
	LD	DE,515
	CALL	OS_NETSOCKET
	LD	(udps),A
	LD	C,A
	LD	DE,udpr_ia
	CALL	OS_BIND
?0037:
	LD	HL,udp_buf
	PUSH	HL
	LD	HL,50
	PUSH	HL
	LD	BC,(udps)
	LD	DE,udps_ia
	CALL	OS_NETRECVFROM
	POP	AF
	POP	AF
	PUSH	HL
	POP	IY
	LD	C,L
	LD	B,H
	LD	HL,0
	OR	128
	SBC	HL,BC
	JP	PO,?0062
	XOR	H
?0062:
	JP	P,?0039
?0038:
	LD	HL,udp_buf
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(HL),0
	LD	DE,udp_buf
	CALL	puts
	LD	HL,msg_hello+2
	PUSH	HL
	LD	HL,8
	PUSH	HL
	LD	BC,(udps)
	LD	DE,udps_ia
	CALL	OS_NETSENDTO
	POP	AF
	POP	AF
?0039:
	LD	A,(cmds)
	OR	A
	JR	NZ,?0041
?0040:
	LD	DE,513
	CALL	OS_NETSOCKET
	LD	(cmds),A
	LD	C,A
	LD	DE,web_ia
	CALL	OS_BIND
	LD	BC,(cmds)
	LD	DE,0
	CALL	OS_LISTEN
?0041:
	LD	BC,(cmds)
	LD	DE,0
	CALL	OS_ACCEPT
	LD	(datasoc),A
	OR	A
	JP	P,?0043
?0042:
	XOR	A
	LD	(datasoc),A
	LD	BC,(app_pages+2)
	LD	DE,int_null
	CALL	OS_SETMUSIC
	LD	A,(errno)
	CP	35
	JR	Z,?0045
?0044:
	LD	BC,(cmds)
	LD	E,0
	CALL	OS_NETCLOSE
	XOR	A
	LD	(cmds),A
	JP	?0032
?0045:
	CALL	_low_level_get
?0046:
	JP	?0032
?0043:
	LD	BC,(cmds)
	LD	E,0
	CALL	OS_NETCLOSE
	XOR	A
	LD	(cmds),A
	LD	BC,(udps)
	LD	E,0
	CALL	OS_NETCLOSE
	XOR	A
	LD	(udps),A
	LD	HL,9
	PUSH	HL
	LD	BC,(datasoc)
	LD	DE,msg_hello
	CALL	OS_NETSEND
	POP	AF
	LD	HL,buf_rx
	LD	(ptr_in_rx),HL
	LD	HL,0
	LD	(ptr_out_rx),HL
	LD	BC,(app_pages+2)
	LD	DE,int_play
	CALL	OS_SETMUSIC
?0035:
	LD	A,(flag_int_change)
	OR	A
	JR	Z,?0048
?0047:
	XOR	A
	LD	(flag_int_change),A
	LD	A,(flag_syncrply)
	DEC	A
	DEC	A
	JR	NZ,?0050
?0049:
	LD	HL,10
	PUSH	HL
	LD	BC,(datasoc)
	LD	DE,msg_framesync
	CALL	OS_NETSEND
	POP	AF
	JR	?0051
?0050:
	LD	HL,5
	PUSH	HL
	LD	BC,(datasoc)
	LD	DE,msg_framesync
	CALL	OS_NETSEND
	POP	AF
?0051:
	XOR	A
	LD	(flag_syncrply),A
?0048:
	LD	BC,(ptr_in_rx)
	LD	HL,(ptr_out_rx)
	AND	A
	SBC	HL,BC
	JR	NC,?0053
?0052:
	LD	BC,(ptr_in_rx)
	LD	HL,buf_rx+4096
	AND	A
	SBC	HL,BC
	PUSH	HL
	LD	BC,(datasoc)
	LD	DE,(ptr_in_rx)
	CALL	OS_NETRECV
	POP	AF
	PUSH	HL
	POP	IY
	JR	?0057
?0053:
	LD	BC,(ptr_out_rx)
	LD	HL,(ptr_in_rx)
	AND	A
	SBC	HL,BC
	JP	NC,?0032
?0055:
	LD	BC,(ptr_in_rx)
	LD	HL,(ptr_out_rx)
	AND	A
	SBC	HL,BC
	PUSH	HL
	LD	BC,(datasoc)
	LD	DE,(ptr_in_rx)
	CALL	OS_NETRECV
	POP	AF
	PUSH	HL
	POP	IY
?0056:
?0057:
?0054:
	LD	B,IYH
	BIT	7,B
	JR	Z,?0059
?0058:
	CALL	shutup
	LD	BC,(datasoc)
	LD	E,0
	CALL	OS_NETCLOSE
	LD	BC,(app_pages+2)
	LD	DE,int_null
	CALL	OS_SETMUSIC
	XOR	A
	LD	(datasoc),A
	JP	?0032
?0059:
	LD	A,IYL
	OR	IYH
	JR	NZ,?0061
?0060:
	CALL	_low_level_get
	JP	?0032
?0061:
	PUSH	IY
	POP	DE
	CALL	ptr_increment
	JP	?0032
?0031:
	RSEG	CSTR
?0018:
	DEFB	'Press any key'
	DEFB	0
?0021:
	DEFB	'Error: %s %s!'
	DEFB	0
?0027:
	DEFB	'Wrong parameter'
	DEFB	0
	RSEG	NO_INIT
app_pages:
	DEFS	4
len:
	DEFS	2
web_ia:
	DEFS	15
udps_ia:
	DEFS	15
udpr_ia:
	DEFS	15
udp_buf:
	DEFS	50
ptr:
	DEFS	2
	RSEG	IDATA0
cmds:
	DEFS	1
datasoc:
	DEFS	1
grmod:
	DEFS	1
udps:
	DEFS	1
	RSEG	CDATA0
	DEFB	0
	DEFB	0
	DEFB	0
	DEFB	0
	END
