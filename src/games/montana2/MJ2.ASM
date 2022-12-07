        if USEINT == 0
IntTable = 0xFD00
IntAddr = 0xFEFE
        endif
        if EGA == 0
BufferScreen = #c000
        endif

;	ORG	#61A8
;
;	LD	SP,#0000
;	LD	HL,L_A74A
;	LD	DE,L_EE61
;	LD	BC,#083F
;	LDIR
;	LD	HL,L_A749
;	LD	DE,L_BFFF
;	LD	BC,#3360
;	LDDR

	;ORG #61C1
;GO;STARD
	;JP	GO2
;
therosprites
;+1: state (direction) for state machine?
;+5: phase
	DB #00,#00,#00
L_61C7	DB #12
L_61C8	DB #10,#00,#12,#10
L_61CC	DB #00,#12,#10
       if EGA
        dw hero_r0-412
       else
	dw MJ_sprites-#60 ;#B0,#B3
       endif
         dw 0 ;old xy

talien1sprites
	DB #01,#00,#00
	db #02
	db #08,#00,#02,#08
	db #00,#02,#08
       if EGA
        ;dw hero_r0-412
        dw alien1_r0-412
       else
	dw Alien1_sprite-#60
       endif
         dw 0 ;old xy

talien2sprites
	DB #02,#00,#00
	db #06
	db #5A,#00,#06,#5A
	db #00,#06,#5A
       if EGA
        ;dw hero_r0-412
        dw alien2_r0-412
       else
	dw Alien2_sprite-#60
       endif
         dw 0 ;old xy

L_61EB
       DB       #00,#0C,#18,#28,#38,#40,#58,#68       ;...(8@Xh
       DB       #74,#80,#8C,#98,#A4,#B0,#BC       ;t...$0<

tdelta2yXatdirection
       DB       #FC,#FF,#FC,#00,#FC,#01,#FC,#02       ;|.|.|.|.
       DB       #00,#FF,#00,#00,#00,#01,#00,#02       ;........
       DB       #04,#FF,#04,#00,#04,#01,#04,#02       ;........
       DB       #08,#FF,#08,#00,#08,#01,#08,#02       ;........
tlifechars       DB       #40,#23,#00       ;@#.
tnolifechars     DB       #20,#20,#00       ;  .

tscore_level       DM       "SCORE              LEVEL  "
       DB       #00       ;.
;
panelattrs
       DB       #84,#20,#85,#06,#87,#08,#06,#06       ;. ......
       DB       #85,#09,#07,#07,#FF       ;.....
curdirection       DB       #00       ;.
curlives       DB       #00       ;.
L_624A       DB       #00,#00       ;..
curlevel       DB       #00       ;.
L_624D       DB       #00       ;.
isdead       DB       #00       ;.
L_624F       DB       #00       ;.
L_6250       DB       #00       ;.
L_6251       DB       #00       ;.
demoon       DB       #00       ;.
curdemoaddr       dw 0;DB       #00,#00       ;..
L_6255       DB       #08       ;.
firephase       DB       #00       ;.
;
L_6257       DB       #00,#00       ;..
tgameover       DM       "GAME  OVER"
       DB       #00       ;.
L_6264       DM       "LEVEL"
       DB       #00       ;.
;
L_626A       DB       #00,#00       ;..
;
tdirectionjumps
       DW       L_6382 ;no move?
       DW       L_6322 ;left?
       DW       L_6322 ;right?
       DW       L_6382 ;down?
       DW       L_6382 ;up?
       DW       L_635B ;up-left?
       DW       L_6322 ;up-right?
       DW       L_635B
       DW       L_651F
       DW       L_6322
       DW       L_651F
       DW       L_635B
       DW       L_6540
       DW       L_6322
       DW       L_6540
       DW       L_635B
;
parseherosprites
	LD	IX,therosprites
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_62A5
	CALL	Control
	LD	D,(IX+#01) ;state (direction)
	CALL	JumpDirectionHander
	LD	(IX+#01),D ;state (direction)
	CALL	L_68B4
L_62A5	LD	A,(IX+#01)
	OR	A
	CALL	NZ,L_6561
	LD	A,(IX+#02)
	OR	A
	JP	NZ,L_6C3A
	 CALL	L_67A8
	CALL	L_6C3A
	JP	L_6830
;
parsealien1sprites
	LD	IX,talien1sprites
       ld a,(timer) ;phase
       and 3
       jr z,skipalienmove
	LD	A,(IX+#01)
	CP	#10
	JR	C,L_62CD
	JP	Z,L_6ADE
	JP	L_6B00
;
L_62CD	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_62D9
	CALL	L_6971
L_62D6	LD	(IX+#01),D
L_62D9	LD	A,(IX+#01)
	OR	A
	CALL	NZ,L_6561
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_62EE
	CALL	L_6A51
	JR	C,L_62F1
	CALL	L_6830
skipalienmove
L_62EE	JP	L_6C3A ;draw
;
L_62F1
;very rare!
	CALL	PlaySFXL_6E0B
	JP	L_6883
;
parsealien2sprites
	LD	IX,talien2sprites
       ld a,(timer) ;phase
       and 3
       jr z,skipalienmove
	LD	A,(IX+#01)
	CP	#10
	JR	C,L_6308
	JP	Z,L_6ADE
	JP	L_6B00
;
L_6308	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_62D9
	CALL	L_6A68
	JR	L_62D6
;
JumpDirectionHander
	LD	HL,tdirectionjumps
	LD	A,D
	RLCA
	ADD	A,L
	LD	L,A
	JR	NC,L_631D
	INC	H
L_631D	LD	C,(HL)
	INC	HL
	LD	B,(HL) ;proc addr
	PUSH	BC
	RET
;
L_6322
	LD	A,#09
	CALL	CheckTileAtDirection
	CP	#05
	JR	Z,L_6382
	LD	A,#0A
	CALL	CheckTileAtDirection
	CP	#05
	JR	Z,L_6382
	LD	A,#0D
	CALL	CheckTileAtDirection
	CP	#04
	JR	NC,L_6382
	LD	A,#0E
	CALL	CheckTileAtDirection
	CP	#04
	JR	NC,L_6382
	LD	A,D
	CP	#04
	JR	NC,L_634E
	LD	D,#07
	RET
;
L_634E	CP	#06
	JP	Z,L_6485
	CP	#09
	JP	Z,L_64CB
	JP	L_64F5
;
L_635B	LD	A,#09
	CALL	CheckTileAtDirection
	CP	#05
	JR	Z,L_6382
	LD	A,#0A
	CALL	CheckTileAtDirection
	CP	#05
	JR	Z,L_6382
	LD	A,#0D
	CALL	CheckTileAtDirection
	CP	#05
	JR	NC,L_6382
	LD	A,#0E
	CALL	CheckTileAtDirection
	CP	#05
	JR	NC,L_6382
	LD	D,#05
	RET
;
L_6382	LD	A,D
	CP	#01
	JR	Z,L_6399
	CP	#02
	JR	Z,L_6399
	CP	#05
	JR	Z,L_6399
	CP	#0B
	JR	Z,L_6399
	CP	#0F
	JR	Z,L_6399
	JR	L_639C
;
L_6399	CALL	ShutSFX
L_639C	LD	D,#00
	LD	A,(curdirection)
	OR	A
	RET	Z ;no move
	CP	#01 ;left
	JR	Z,L_63BB
	CP	#02 ;right
	JR	Z,L_63CE
	CP	#03 ;down
	JR	Z,L_63E1
	CP	#04 ;up
	JR	Z,L_6403
	CP	#05 ;up-left
	JP	Z,L_6430
	JP	L_645A ;up-right?
;
L_63BB	LD	A,#04
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	A,#08
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	D,#01
	RET
;
L_63CE	LD	A,#07
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	A,#0B
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	D,#02
	RET
;
L_63E1	LD	A,#0D
	CALL	CheckTileAtDirection
	CP	#05
	JR	NZ,L_63F5
	LD	A,#0E
	CALL	CheckTileAtDirection
	CP	#05
	RET	NZ
	LD	D,#03
	RET
;
L_63F5	CP	#04
	RET	NC
	LD	A,#0E
	CALL	CheckTileAtDirection
	CP	#04
	RET	NC
	LD	D,#05
	RET
;
L_6403
;called at jump, result d=6
	LD	A,#01
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	A,#02
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	A,#09
	CALL	CheckTileAtDirection
	CP	#05
	LD	A,#0A
	JR	NZ,L_6427
	CALL	CheckTileAtDirection
	CP	#05
	RET	NZ
	LD	D,#04
	RET
;
L_6427	CALL	CheckTileAtDirection
	CP	#05
	RET	Z
	LD	D,#06
	RET
;
L_6430	LD	A,#01
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	A,#04
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	A,#09
	CALL	CheckTileAtDirection
	CP	#05
	RET	Z
	LD	A,#0A
	CALL	CheckTileAtDirection
	CP	#05
	RET	Z
	XOR	A
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	D,#08
	RET
;
L_645A	LD	A,#02
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	A,#07
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	A,#09
	CALL	CheckTileAtDirection
	CP	#05
	RET	Z
	LD	A,#0A
	CALL	CheckTileAtDirection
	CP	#05
	RET	Z
	LD	A,#03
	CALL	CheckTileAtDirection
	CP	#06
	RET	NC
	LD	D,#0C
	RET
;
L_6485	LD	D,#07
	LD	A,(curdirection)
	CP	#01 ;left
	JR	Z,L_649B
	CP	#02 ;right
	JR	Z,L_64B3
	CP	#05 ;up-left
	JR	Z,L_649B
	CP	#06 ;up-right
	JR	Z,L_64B3
	RET
;
L_649B	LD	A,#08
	CALL	CheckTileAtDirection
	CP	#05
	JR	NC,L_64AF
	LD	A,#0C
	CALL	CheckTileAtDirection
	CP	#04
	RET	C
	LD	D,#01
	RET
;
L_64AF	RET	NZ
	LD	D,#01
	RET
;
L_64B3	LD	A,#0B
	CALL	CheckTileAtDirection
	CP	#05
	JR	NC,L_64C7
	LD	A,#0F
	CALL	CheckTileAtDirection
	CP	#04
	RET	C
	LD	D,#02 ;right?
	RET
;
L_64C7	RET	NZ
	LD	D,#02 ;right?
	RET
;
L_64CB	LD	A,(curdirection)
	CP	#01 ;left
	JR	NZ,L_64D4
	JR	L_64D8 ;left
;
L_64D4	CP	#05 ;up-left
	JR	NZ,L_651F
;left, up-left
L_64D8	LD	A,#08
	CALL	CheckTileAtDirection
	CP	#05
	JR	NC,L_64F0
	LD	A,#0C
	CALL	CheckTileAtDirection
	CP	#04
	JR	C,L_64ED ;???
L_64EA	LD	D,#01 ;left?
	RET
;
L_64ED	LD	D,#0A ;???
	RET
;
L_64F0	JR	Z,L_64EA ;left?
	LD	D,#07 ;???
	RET
;
L_64F5	LD	A,(curdirection)
	CP	#02 ;right
	JR	NZ,L_64FE
	JR	L_6502 ;right
;
L_64FE	CP	#06 ;up-right
	JR	NZ,L_6540
;right, up-right
L_6502	LD	A,#0B
	CALL	CheckTileAtDirection
	CP	#05
	JR	NC,L_651A
	LD	A,#0F
	CALL	CheckTileAtDirection
	CP	#04
	JR	C,L_6517 ;???
L_6514	LD	D,#02 ;right?
	RET
;
L_6517	LD	D,#0E ;???
	RET
;
L_651A	JR	Z,L_6514 ;right?
	LD	D,#07 ;???
	RET
;
L_651F	INC	D
	LD	A,#08
	CALL	CheckTileAtDirection
	CP	#06
	JR	NC,L_6531
	LD	A,#0C
	CALL	CheckTileAtDirection
	CP	#06
	RET	C
L_6531	LD	A,D
	CP	#0A ;???
	JR	Z,L_653D ;???
	LD	D,#05 ;up-left?
	LD	(IX+#02),#01
	RET
;
L_653D	LD	D,#07 ;???
	RET
;
L_6540	INC	D
	LD	A,#0B
	CALL	CheckTileAtDirection
	CP	#06
	JR	NC,L_6552
	LD	A,#0F
	CALL	CheckTileAtDirection
	CP	#06
	RET	C
L_6552	LD	A,D
	CP	#0E ;???
	JR	Z,L_655E ;???
	LD	D,#05 ;up-left?
	LD	(IX+#02),#01
	RET
;
L_655E	LD	D,#07 ;???
	RET
;
L_6561	DEC	A
	LD	HL,L_61EB
	ADD	A,L
	LD	L,A
	JR	NC,L_656A
	INC	H
L_656A	LD	H,(HL)
	LD	A,(IX+#02)
	RLCA
	RLCA
	ADD	A,H
	LD	HL,L_ACB4
	ADD	A,L
	LD	L,A
	JR	NC,L_6579
	INC	H
L_6579	LD	B,(HL)
	LD	A,(IX+#03)
	ADD	A,B
	LD	(IX+#03),A
	INC	HL
	LD	B,(HL)
	LD	A,(IX+#04) ;y?
	ADD	A,B
	LD	(IX+#04),A ;y?
	INC	HL
	LD	A,(HL)
	CP	#FF
	JR	Z,L_6593
	LD	(IX+#05),A
L_6593	INC	HL
	LD	A,(HL)
	LD	(IX+#02),A
	RET
;
CheckTileAtDirection
;a=direction (5=center)
;0 1 2 3
;4<5>6 7
;7 8 9 10
;11 12 13 14
	PUSH	DE
	RLCA
	LD	HL,tdelta2yXatdirection
	ADD	A,L
	LD	L,A
	JR	NC,L_65A3
	INC	H
L_65A3	LD	B,(HL)
	INC	HL
	LD	C,(HL)
	LD	A,(IX+#04) ;y2?
	ADD	A,B
	LD	B,A
	LD	A,(IX+#03) ;X?
	ADD	A,C
	LD	C,A
	SRL	C
	SRL	B
	SRL	B
	SRL	B
	LD	A,C
	LD	(L_624F),A
	LD	A,B
	LD	(L_6250),A
	LD	A,#00
	PUSH	AF
	LD	HL,#0000
	LD	DE,#001E
	CP	B
	JR	Z,L_65CF
L_65CC	ADD	HL,DE
	DJNZ	L_65CC
L_65CF	ADD	HL,BC
	LD	BC,unpackedlevel
	ADD	HL,BC
	POP	AF
	LD	A,(HL)
	POP	DE
	RET	NC ;???
	CP	#04
	RET	NZ
	XOR	A
	RET
;
Control
	LD	A,(demoon)
	OR	A
	JP	NZ,ControlDemo
	LD	A,(curcontroldevice)
	LD	B,#1F
	OR	A
	JP	Z,ControlKempstonJoy
	CP	#01
	JR	Z,ControlQAOP
	CP	#03
	JR	Z,ControlCursorJoy
	LD	A,#EF
	IN	A,(#FE)
L_65F9	BIT	1,A ;'9'
	JR	NZ,L_6611
	BIT	4,A ;'6'
	JR	NZ,L_6605
	LD	A,#05 ;up-left
	JR	L_662A
;
L_6605	BIT	3,A ;'7'
	JR	NZ,L_660D
	LD	A,#06 ;up-right
	JR	L_662A
;
L_660D	LD	A,#04 ;up
	JR	L_662A
;
L_6611	BIT	4,A ;'6'
	JR	NZ,L_6619
	LD	A,#01 ;left
	JR	L_662A
;
L_6619	BIT	3,A ;'7'
	JR	NZ,L_6621
	LD	A,#02 ;right
	JR	L_662A
;
L_6621	BIT	2,A ;'8'
	JR	NZ,L_6629
	LD	A,#03 ;down
	JR	L_662A
;
L_6629	XOR	A ;no move
L_662A	LD	(curdirection),A
	RET
;
ControlQAOP
	LD	A,#FB
	IN	A,(#FE)
	RRA ;'q'
	JR	C,L_6637
	RES	1,B
L_6637	LD	A,#FD
	IN	A,(#FE)
	RRA ;'a'
	JR	C,L_6640
	RES	2,B
L_6640	LD	A,#DF
	IN	A,(#FE)
	RRA ;'p'
	JR	C,L_6649
	RES	3,B
L_6649	RRA ;'o'
	JR	C,L_664E
	RES	4,B
L_664E	LD	A,B
	JR	L_65F9
;
ControlCursorJoy
	LD	A,#EF
	IN	A,(#FE)
	BIT	3,A
	JR	NZ,L_665B
	RES	1,B
L_665B	BIT	4,A
	JR	NZ,L_6661
	RES	2,B
L_6661	BIT	2,A
	JR	NZ,L_6667
	RES	3,B
L_6667	LD	A,#F7
	IN	A,(#FE)
	BIT	4,A
	JR	NZ,L_6671
	RES	4,B
L_6671	JR	L_664E
;
ControlKempstonJoy
curkempston=$+1
        ld a,0
	;IN	A,(#1F)
	RRA
	JR	NC,L_667A
	RES	3,b;4,B
L_667A	RRA
	JR	NC,L_667F
	RES	4,b;3,B
L_667F	RRA
	JR	NC,L_6684
	RES	2,b;1,B
L_6684	RRA
	JR	NC,L_6689
	RES	1,b;2,B
L_6689	JR	L_664E
;
MenuStartGame
        if USEINT
        call SetGameInt
        else
	DI
        endif
	LD	A,(startlevel)
	LD	(curlevel),A
	CALL	L_EEEC
	CALL	ShowLevelPrepare
	XOR	A
	LD	(demoon),A
GameOrDemo
	AND	#00
	SET	2,A
	LD	(curlives),A
	LD	HL,#0000
	LD	(L_624A),HL
	LD	HL,#03E8
	LD	(L_6257),HL
L_66AF	LD	DE,#0601
	CALL	OutAY_Dreg_E
        if EGA == 0
	LD	HL,panelattrs
	LD	DE,#5AC0
	CALL	L_705A
        endif
	LD	HL,tscore_level
	LD	BC,#1700
        if EGA
	CALL	PrintString_EGA
        else
	CALL	PrintString
        endif
	CALL	L_66CC
	JR	L_66E0
;
L_66CC	LD	A,(curlives)
	OR	A
	RET	Z
	LD	BC,#1600
L_66D4	PUSH	AF
	LD	HL,tlifechars
        if EGA
	CALL	PrintString_EGA
        else
	CALL	PrintString
        endif
	POP	AF
	DEC	A
	JR	NZ,L_66D4
	RET

         if EGA
restoresprites
	LD	IX,therosprites
        call RestoreSpriteEGA
	LD	IX,talien1sprites
        call RestoreSpriteEGA
	LD	IX,talien2sprites
        jp RestoreSpriteEGA
         endif
;
L_66E0	LD	BC,#1719
	CALL	PrintLevelNumber
	LD	BC,#0000
	CALL	AddScoreBC ;print score
	XOR	A
	LD	(L_624D),A
	LD	(isdead),A
	LD	A,#20
	LD	BC,#170E
        if EGA
        call PrintCharA_EGA
        else
	CALL	PrintCharYScaleL_7111
        endif
	LD	A,#20
	LD	BC,#170F
        if EGA
        call PrintCharA_EGA
        else
	CALL	PrintCharYScaleL_7111
        endif
	LD	A,(curlevel)
	CALL	UnpackLevel_A
	LD	IX,therosprites
	INC	HL
	LD	A,(HL)
	LD	(L_6251),A
	CALL	L_6765
	LD	IX,talien1sprites
	CALL	L_6765
	LD	IX,talien2sprites
	CALL	L_6765
	LD	A,(demoon)
	OR	A
	CALL	Z,WaitKey
L_672A	LD	A,(firephase)
	INC	A
	CP	#03
	JR	NZ,L_6736
	CALL	AnimFire
	XOR	A
L_6736	LD	(firephase),A
         ld hl,timer
         inc (hl)
         ld a,0xfe
         in a,(0xfe)
         bit 3,a ;'c'
         jr nz,nocheat
         xor a
         ld (cheatpatch),a
nocheat
         if EGA
         call restoresprites
         endif
	CALL	parseherosprites
	LD	A,(isdead)
	CP	#01
	JP	NC,L_6757
	CALL	parsealien1sprites
	CALL	parsealien2sprites
	CALL	L_690D
	CALL	CheckLevelExit
	LD	A,(isdead)
	CP	#01
	JR	C,L_672A
L_6757	JP	Z,L_66AF
	CP	#04
	JP	Z,Victory
	CALL	GameOver
	JP	GoMenu
;
L_6765	INC	HL
	LD	A,(HL)
	LD	(IX+#03),A
	LD	(IX+#09),A
	LD	B,#00
	CP	#1E
	JR	C,L_6774
	INC	B
L_6774	INC	HL
	LD	A,(HL)
	LD	(IX+#04),A ;y?
	LD	(IX+#0A),A
	CP	#4D
	JR	C,L_6782
	INC	B
	INC	B
L_6782	LD	(IX+#08),B
	XOR	A
	LD	(IX+#05),A
	LD	(IX+#01),A
	LD	(IX+#02),A
	PUSH	HL
	LD	A,(IX+#00)
	OR	A
	JR	NZ,L_679E
	CALL	L_6CD2
	CALL	L_6C3A
	JR	L_67A6
;
L_679E	LD	(IX+#08),#00
	LD	(IX+#01),#11
L_67A6	POP	HL
	RET
;
L_67A8	LD	A,#05 ;"middle tile"
	CALL	CheckTileAtDirection
	CP	#01
	CALL	Z,L_67D1
	LD	A,#06 ;"middle right tile"
	CALL	CheckTileAtDirection
	CP	#01
	CALL	Z,L_67D1
	LD	A,#09 ;"middle bottom tile"
	CALL	CheckTileAtDirection
	CP	#01
	CALL	Z,L_67D1
	LD	A,#0A ;"middle right bottom tile"
	CALL	CheckTileAtDirection
	CP	#01
	CALL	Z,L_67D1
	RET
;
L_67D1	LD	(HL),#00
	CALL	PlaySFXL_6DE1
	LD	HL,L_6251
	DEC	(HL)
	LD	A,(HL)
	OR	A
	CALL	Z,L_6815
	LD	BC,#000A
	CALL	AddScoreBC
	JP	L_68DA
;
AddScoreBC
	LD	HL,(L_624A)
	ADD	HL,BC
	LD	(L_624A),HL
	LD	BC,#1706
	CALL	PrNum
	LD	HL,(L_624A)
	LD	DE,(L_6257)
	OR	A
	SBC	HL,DE
	RET	C
	LD	HL,#03E8
	ADD	HL,DE
	LD	(L_6257),HL
	LD	HL,curlives
	INC	(HL)
	LD	A,#11
	CP	(HL)
	JP	NZ,L_66CC
	DEC	(HL)
	JP	L_66CC
;
L_6815	LD	BC,#0064
	CALL	AddScoreBC
	LD	A,#01
	LD	(L_624D),A
	LD	A,#5B
	LD	BC,#170E
        if EGA
        call PrintCharA_EGA
        else
	CALL	PrintCharYScaleL_7111
        endif
	LD	A,#5D
	LD	BC,#170F
        if EGA
        jp PrintCharA_EGA
        else
	JP	PrintCharYScaleL_7111
        endif
;
L_6830	LD	A,#05 ;"middle tile"
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_6855
	LD	A,#06 ;"middle right tile"
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_6855
	LD	A,#09 ;"middle bottom tile"
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_6855
	LD	A,#0A ;"middle right bottom tile"
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_6855
	RET
;
L_6855	CALL	PlaySFXL_6DEF
	LD	A,(IX+#00)
	OR	A
	JR	Z,L_6883
	LD	(IX+#01),#10
	LD	A,(IX+#04) ;y?
	LD	(IX+#08),A
	RET
;
L_6869	LD	A,(curlives)
	OR	A
	JR	Z,L_68AE
cheatpatch=$
	DEC	A ;/nop
	LD	(curlives),A
	RLCA
	LD	C,A
	LD	B,#16
	LD	HL,tnolifechars
        if EGA
	CALL	PrintString_EGA
        else
	CALL	PrintString
        endif
	LD	A,#01
	LD	(isdead),A
	RET
;
L_6883
;very rare! fly dead?
         if EGA
         call restoresprites
         endif
	LD	IX,talien1sprites
	CALL	L_6D9A
	LD	IX,talien2sprites
	CALL	L_6D9A
	LD	IX,therosprites
	LD	(IX+#05),#08
	LD	A,(IX+#04) ;y?
L_689C
         if EGA
         push ix
         call restoresprites
         pop ix
         endif
	DEC	(IX+#04) ;y?
	CALL	L_6C3A
	CALL	L_6914
	LD	A,(IX+#04) ;y?
	CP	#01
	JR	NZ,L_689C
	JR	L_6869
;
L_68AE	LD	A,#03
	LD	(isdead),A
	RET
;
L_68B4	LD	A,(L_624D)
	OR	A
	RET	Z
	LD	A,(curdirection)
	CP	#02 ;right
	JR	Z,L_68C7
	CP	#01 ;left
	RET	NZ
	LD	A,#04 ;"left tile"
	JR	L_68C9
;
L_68C7	LD	A,#07 ;"right tile"
L_68C9	CALL	CheckTileAtDirection
	CP	#07
	RET	NZ
	LD	(HL),#00
	LD	BC,#0032
	CALL	AddScoreBC
	CALL	PlaySFXL_6DFD
L_68DA	LD	A,(L_624F)
	BIT	0,(IX+#08)
	JR	Z,L_68E5
	SUB	#0E
L_68E5	LD	C,A
	LD	A,(L_6250)
	BIT	1,(IX+#08)
	JR	Z,L_68F1
	SUB	#09
L_68F1	LD	B,A
	XOR	A
	SLA	C
	SLA	B
L_68F7
        if EGA
	jp DrawTileEGA_twoscr
        else
	LD	DE,0xFACB ; 0xCB,0xFA = set 7,d
	LD	(L_6EBA),DE
	PUSH	AF
	CALL	DrawTile
	POP	AF
	LD	DE,#0000
	LD	(L_6EBA),DE
	JP	DrawTile
        endif
;
L_690D	LD	A,#FE
	IN	A,(#FE)
	RRCA ;caps shift
	JR	NC,PauseMenu
L_6914	LD	A,(L_7110)
	INC	A
	CALL	PlaySFX
	;LD	C,#00
	;RLCA
	;RLCA
	;RLCA
	LD	B,A
         halt
         djnz $-1
	;JP	PauseBC
         ret
;
PauseMenu
	CALL	PlaySFX
	LD	BC,#080A
	LD	HL,L_AC05
	LD	A,#07
L_692F	PUSH	BC
	PUSH	AF
	CALL	PrintString_EGA
	POP	AF
	POP	BC
	INC	B
	DEC	A
	JR	NZ,L_692F
	LD	DE,#590A
	LD	HL,L_AC60
	LD	B,#07
L_6942	LD	A,#0C
L_6944	LDI
	INC	BC
	DEC	A
	JR	NZ,L_6944
	LD	A,#14
	ADD	A,E
	LD	E,A
	JR	NC,L_6951
	INC	D
L_6951	DJNZ	L_6942
L_6953	LD	IX,therosprites
	LD	A,#F7
	IN	A,(#FE)
	BIT	0,A
	JP	Z,L_6CD2
	BIT	1,A
	JR	NZ,L_6967
	JP	L_6869
;
L_6967	BIT	2,A
	JR	NZ,L_6953
	LD	A,#02
	LD	(isdead),A
	RET
;
L_6971	LD	D,(IX+#01)
	LD	A,(L_61C8)
	LD	B,(IX+#04)
	CP	B
	JR	Z,L_6982
	JR	C,L_69CF
	JP	L_6A12
;
L_6982	LD	A,(L_61C7)
	LD	B,(IX+#03)
	CP	B
	JR	NC,L_69A5
	LD	A,#0C
	CALL	CheckTileAtDirection
	CP	#04
	JR	C,L_69A1
	LD	A,#04
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_69A1
	LD	A,#01
	JR	L_69BD
;
L_69A1	LD	A,#05
	JR	L_69BD
;
L_69A5	LD	A,#0F
	CALL	CheckTileAtDirection
	CP	#04
	JR	C,L_69BB
	LD	A,#07
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_69BB
	LD	A,#02 ;right
	JR	L_69BD
;
L_69BB	LD	A,#06
L_69BD	LD	(curdirection),A
	CALL	JumpDirectionHander
	LD	A,D
	OR	A
	RET	NZ
	LD	A,#04 ;up
L_69C8	LD	(curdirection),A
	CALL	JumpDirectionHander
	RET
;
L_69CF	LD	A,(L_61C7)
	LD	B,(IX+#03)
	CP	B
	JR	NZ,L_69F1
	LD	A,#04 ;up
L_69DA	LD	(curdirection),A
	CALL	JumpDirectionHander
	LD	A,D
	OR	A
	RET	NZ
L_69E3	LD	A,(IX+#05)
	OR	A
	JR	Z,L_69ED
	LD	A,#01
	JR	L_69C8
;
L_69ED	LD	A,#02
	JR	L_69C8
;
L_69F1	LD	A,#09
	CALL	CheckTileAtDirection
	CP	#05
	JR	NZ,L_6982
	LD	A,#0A
	CALL	CheckTileAtDirection
	CP	#05
	JP	NZ,L_6982
	LD	A,#04 ;up
	LD	(curdirection),A
	CALL	JumpDirectionHander
	LD	A,D
	OR	A
	RET	NZ
	JP	L_6982
;
L_6A12	LD	A,D
	CP	#06
	JR	NC,L_6A22
	LD	A,#03 ;down
	LD	(curdirection),A
	CALL	JumpDirectionHander
	LD	A,D
	OR	A
	RET	NZ
L_6A22	LD	A,(L_61C7)
	LD	B,(IX+#03)
	CP	B
	JR	Z,L_69E3
	JR	NC,L_6A3E
	LD	A,#04
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_6A3A
	LD	A,#01
	JR	L_69C8
;
L_6A3A	LD	A,#05
	JR	L_69C8
;
L_6A3E	LD	A,#07
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_6A4C
	LD	A,#02
	JP	L_69C8
;
L_6A4C	LD	A,#06
	JP	L_69C8
;
L_6A51	LD	A,(L_61C7)
	LD	B,(IX+#03)
	SUB	B
	INC	A
	CP	#03
	RET	NC
	LD	A,(L_61C8)
	LD	B,(IX+#04) ;y?
	SUB	B
	ADD	A,#04
	CP	#09
	RET
;
L_6A68	LD	D,(IX+#01)
	LD	A,(L_61C7)
	LD	B,(IX+#03)
	CP	B
	JR	Z,L_6A78
	JR	C,L_6A8C
	JR	L_6AA6
;
L_6A78	LD	A,(L_61C8)
	LD	B,(IX+#04) ;y?
	DEC	A
	CP	B
	JR	C,L_6A87
	LD	A,#03
	JP	L_69DA
;
L_6A87	LD	A,#04
	JP	L_69DA
;
L_6A8C	LD	A,#0C
	CALL	CheckTileAtDirection
	CP	#04
	JR	C,L_6AA2
	LD	A,#04
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_6AA2
	LD	A,#01
	JR	L_6ABE
;
L_6AA2	LD	A,#05
	JR	L_6ABE
;
L_6AA6	LD	A,#0F
	CALL	CheckTileAtDirection
	CP	#04
	JR	C,L_6ABC
	LD	A,#07
	CALL	CheckTileAtDirection
	CP	#02
	JR	Z,L_6ABC
	LD	A,#02
	JR	L_6ABE
;
L_6ABC	LD	A,#06
L_6ABE	LD	(curdirection),A
	CALL	JumpDirectionHander
	LD	A,D
	OR	A
	RET	NZ
	JR	L_6A78
;
	LD	A,(L_61C8)
	LD	B,(IX+#04) ;y?
	CP	B
	JR	C,L_6AD6
	LD	A,#03 ;down
	JR	L_6AD8
;
L_6AD6	LD	A,#04 ;up
L_6AD8	LD	(curdirection),A
	JP	JumpDirectionHander
;
L_6ADE	LD	A,(IX+#08)
	CP	#01
	JR	Z,L_6AF3
	DEC	A
	LD	(IX+#08),A
	DEC	(IX+#04) ;y?
	LD	(IX+#05),#08
	JP	L_6C3A
;
L_6AF3	CALL	L_6D9A
	PUSH	IX
	POP	HL
	LD	BC,#0008
	ADD	HL,BC
	JP	L_6765
;
L_6B00	LD	A,(IX+#08)
	CP	#10
	JR	Z,L_6B17
	INC	A
	INC	A
	LD	(IX+#08),A
	DEC	(IX+#04) ;y?
	ADD	A,#04
	LD	(spritehgt),A
	JP	L_6C46
;
L_6B17	LD	(IX+#01),#00
	RET
;
ShowLevelPrepare
        if EGA
        call Set6912
        endif
	CALL	ClsZeroAttr
	CALL	SetSomeAttrs
	LD	BC,#0A0B
	LD	HL,L_6264
	LD	A,#03
	LD	(L_7111),A
	CALL	PrintString
	LD	BC,#0A12
	;CALL	PrintLevelNumber
	 LD A,(curlevel)
         call PrintNN_A
	LD	A,#01
	LD	(L_7111),A
	call	WaitKey
        if EGA
        call SetEGA
        endif
        ret
;
CheckLevelExit
	LD	A,(L_61C8)
	OR	A
	RET	NZ
	LD	BC,#01F4
	CALL	AddScoreBC
	LD	HL,curlevel
	INC	(HL)
	LD	A,#1F
	CP	(HL)
	JR	NZ,L_6B58
	LD	A,#04
	LD	(isdead),A
	RET
;
L_6B58	LD	A,#01
	LD	(isdead),A
	LD	HL,L_8EB3
	LD	(L_6E6E),HL
	LD	B,#56
L_6B65	PUSH	BC
	CALL	PlaySFXL_6E68
	;LD	BC,#07D0
	;CALL	PauseBC
         halt
	POP	BC
	DJNZ	L_6B65
	JP	ShowLevelPrepare
;
PrintLevelNumber
	LD	A,(curlevel)
        if EGA
	LD	DE,0xFF0A
L_6B7BEGA	SUB	E
	INC	D
	JR	NC,L_6B7BEGA
	ADD	A,E
	LD	E,A
	LD	A,D
	ADD	A,#30
	PUSH	DE
	PUSH	BC
	CALL	PrintCharA_EGA
	POP	BC
	POP	DE
	INC	C
	LD	A,E
	ADD	A,#30
	JP	PrintCharA_EGA
        endif
        
PrintNN_A
	LD	DE,0xFF0A
L_6B7B	SUB	E
	INC	D
	JR	NC,L_6B7B
	ADD	A,E
	LD	E,A
	LD	A,D
	ADD	A,#30
	PUSH	DE
	PUSH	BC
	CALL	PrintCharYScaleL_7111
	POP	BC
	POP	DE
	INC	C
	LD	A,E
	ADD	A,#30
	JP	PrintCharYScaleL_7111
;
GameOver
         if EGA
         call Set6912
         else
	CALL	FadeOut
         endif
	CALL	ClsZeroAttr
	LD	A,(isdead)
	CP	#02
	RET	Z
	CALL	SetSomeAttrs
	LD	A,#03
	LD	(L_7111),A
	LD	HL,tgameover
	LD	BC,#0A0B
	CALL	PrintString
	LD	A,#01
	LD	(L_7111),A
	JP	WaitKey
;
SetSomeAttrs
	LD	HL,#5940
	LD	C,#07
	CALL	L_6BC5
	LD	C,#05
	CALL	L_6BC5
	DEC	C
L_6BC5	LD	B,#20
L_6BC7	LD	(HL),C
	INC	HL
	DJNZ	L_6BC7
	RET
;
FadeOut
	LD	BC,#0003
	LD	HL,#5800
	LD	E,B
L_6BD3	LD	A,(HL)
	AND	A
	JR	Z,L_6BEE
	EXX
	INC	DE
	LD	A,D
	AND	#07
	OR	#00
	LD	D,A
	LD	A,(DE)
	EXX
	AND	#03
	LD	D,A
	LD	A,(HL)
	AND	#07
	SUB	D
	JR	NC,L_6BEB
	XOR	A
L_6BEB	LD	(HL),A
	LD	E,#01
L_6BEE	INC	HL
	DJNZ	L_6BD3
	DEC	C
	JR	NZ,L_6BD3
	;LD	BC,#2EE0
	;CALL	PauseBC
         halt
         halt
         halt
         halt
	DEC	E
	RET	NZ
	JR	FadeOut
;
PauseBC
	PUSH	BC
	PUSH	AF
L_6C00	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,L_6C00
	POP	AF
	POP	BC
	RET
;
AnimFire
	LD	HL,L_6255
	LD	A,(HL)
	CP	#0A
	JR	NZ,L_6C12
	LD	(HL),#07
L_6C12	INC	(HL)
       if EGA
        ld ix,therosprites
	LD	HL,unpackedlevel
	BIT	0,(IX+#08)
	JR	Z,animfire_noRscreen
	LD	BC,#000E
	ADD	HL,BC
animfire_noRscreen
	BIT	1,(IX+#08)
	JR	Z,animfire_noDscreen
	LD	BC,#010E
	ADD	HL,BC
animfire_noDscreen
;to screen and to BufferScreen
	LD	BC,#0000
animfire_0
	LD	A,(HL)
	INC	HL
        cp 2
	LD	A,(L_6255)
        call z,DrawTileEGA_twoscr
	INC	C
	INC	C
	LD	A,#20
	CP	C
	JR	NZ,animfire_0
	INC	B
	INC	B
	LD	A,#16
	CP	B
	ret z
	LD	DE,#000E
	ADD	HL,DE
	LD	C,#00
	JR animfire_0
        
       else ;~EGA
	LD	HL,#5800
	LD	BC,#0000
L_6C19	LD	A,#02
	CP	(HL)
	LD	A,(L_6255)
	CALL	Z,L_68F7
	INC	C
	INC	C
	INC	HL
	INC	HL
	LD	A,#20
	CP	C
	JR	NZ,L_6C19
	LD	C,#00
	INC	B
	INC	B
	LD	A,#16
	CP	B
	RET	Z
	LD	DE,#0020
	ADD	HL,DE
	JR	L_6C19
;
       DB       #C9       ;I
       endif ;~EGA
;
L_6C3A
	LD	A,#18
	LD	(spritehgt),A
	LD	A,(IX+#00)
	OR	A
	CALL	Z,L_6C84
L_6C46	CALL	L_6C5C
	LD	A,(spritey)
	CP	-8;#F8
	JR	NC,L_6C53
	CP	#59
	RET	NC
L_6C53
       if EGA
        jp DrawSpriteEGA
       else
	CALL	KeepSpriteToL_D800
	CALL	BlitSpriteInL_D800
	JP	DrawSpriteFromL_D800
       endif
;
L_6C5C	LD	HL,L_61CC
	LD	A,(IX+#03)
	BIT	0,(HL)
	JR	Z,L_6C68
	SUB	#1C
L_6C68	LD	(spriteX),A
	LD	A,(IX+#04) ;y?
	BIT	1,(HL)
	JR	Z,L_6C74
	SUB	#48
L_6C74	LD	(spritey),A
	LD	A,(IX+#05)
	OR	A
	RET	NZ
	LD	A,(spriteX)
	DEC	A
	LD	(spriteX),A
	RET
;
L_6C84	LD	A,(IX+#04) ;y?
	CP	#4D
	JR	C,L_6C99
	BIT	1,(IX+#08)
	JR	NZ,L_6C99
	INC	(IX+#08)
	INC	(IX+#08)
	JR	L_6CD2
;
L_6C99	CP	#4C
	JR	NC,L_6CAB
	BIT	1,(IX+#08)
	JR	Z,L_6CAB
	DEC	(IX+#08)
	DEC	(IX+#08)
	JR	L_6CD2
;
L_6CAB	LD	A,(IX+#03)
	CP	#1D
	JR	NZ,L_6CC4
	LD	A,(IX+#05)
	CP	#01
	JR	NZ,L_6CC4
	BIT	0,(IX+#08)
	JR	NZ,L_6CC4
	INC	(IX+#08)
	JR	L_6CD2
;
L_6CC4	LD	A,(IX+#03)
	CP	#1C
	RET	NZ
	BIT	0,(IX+#08)
	RET	Z
	DEC	(IX+#08)
L_6CD2	LD	HL,unpackedlevel
	BIT	0,(IX+#08)
	JR	Z,L_6CDF
	LD	BC,#000E
	ADD	HL,BC
L_6CDF	BIT	1,(IX+#08)
	JR	Z,L_6CE9
	LD	BC,#010E
	ADD	HL,BC
L_6CE9	JP	DrawTileMap
;
KeepSpriteToL_D800
         if EGA
         ret
         endif
	LD	A,(spritey) ;y
	LD	C,A
	LD	B,#00
	LD	A,#08
	ADD	A,C
	LD	C,A ;in case of negative y?
	SLA	C
	RL	B
	SLA	C
	RL	B
        if USEINT == 0
	LD	hl,tscreenaddrs
	ADD	hl,BC
	LD	(curspritescraddr),hl
	LD	(L_626A),SP
	LD	SP,HL
        else
	LD	iy,tscreenaddrs
	ADD	iy,BC
	LD	(curspritescraddr),iy
        endif
	LD	DE,L_D800
	LD	A,(spritehgt) ;hgt
	LD	B,A
L_6D11
        if USEINT == 0
        POP	HL ;screen address
        else
        ld l,(iy)
        inc iy
        ld h,(iy)
        inc iy
        endif
	SET	7,H       ;find addr in buffer screen
	LD	A,(spriteX) ;x?
	LD	C,A
	CP	#20
	JR	NC,L_6D1E
	ADD	A,L
	LD	L,A
L_6D1E	LD	A,#03 ;wid
L_6D20	EX	AF,AF' ;'
	LD	A,C
	CP	#20
	JR	NC,L_6D29
	LD	A,(HL)
	LD	(DE),A
	INC	HL
L_6D29	INC	DE
	INC	C
	EX	AF,AF' ;'
	DEC	A
	JR	NZ,L_6D20
	DJNZ	L_6D11
        if USEINT == 0
	LD	SP,(L_626A)
	;LD	IY,#5C3A
        endif
	RET
;
BlitSpriteInL_D800
         if EGA
         ret
         endif        
	LD	DE,L_D800+0x0C
	LD	A,(IX+#05) ;phase
	INC	A
	LD	HL,#0000
	LD	BC,#0060 ;sprite size
L_6D43	ADD	HL,BC
	DEC	A
	JR	NZ,L_6D43
	LD	C,(IX+#0B) ;
	LD	B,(IX+#0C) ;sprites base
	ADD	HL,BC
	PUSH	HL ;mask addr
	POP	IY
	LD	BC,#0030
	ADD	IY,BC ;gfx addr
	LD	B,C ;0x30
L_6D57	LD	A,(DE)
	AND	(HL) ;mask
	OR	(IY+#00) ;gfx
	LD	(DE),A
	INC	HL
	INC	DE
	INC	IY
	DJNZ	L_6D57
        if USEINT == 0
	LD	IY,#5C3A
        endif
	RET
;
DrawSpriteFromL_D800
         if EGA
         ret
         endif
        if USEINT == 0
	LD	hl,(curspritescraddr)
	LD	(L_626A),SP
	LD	SP,HL
        else
	LD	iy,(curspritescraddr)
        endif
	LD	HL,L_D800
	LD	A,(spritehgt)
	LD	B,A
L_6D77
        if USEINT == 0
        POP	DE
        else
        ld e,(iy)
        inc iy
        ld d,(iy)
        inc iy
        endif
	LD	A,(spriteX)
	LD	C,A
	CP	#20
	JR	NC,L_6D82
	ADD	A,E
	LD	E,A
L_6D82	LD	A,#03
L_6D84	EX	AF,AF' ;'
	LD	A,C
	CP	#20
	JR	NC,L_6D8D
	LD	A,(HL)
	LD	(DE),A
	INC	DE
L_6D8D	INC	HL
	INC	C
	EX	AF,AF' ;'
	DEC	A
	JR	NZ,L_6D84
	DJNZ	L_6D77
        if USEINT == 0
	LD	SP,(L_626A)
	;LD	IY,#5C3A
        endif
	RET
;
L_6D9A
;very rare!
	LD	A,#18
	LD	(spritehgt),A
	CALL	L_6C5C
	LD	A,(spritey)
	CP	#F8
	JR	NC,L_6DAC
	CP	#59
	RET	NC
L_6DAC
       if EGA
        jp RestoreSpriteEGA
       else
        CALL	KeepSpriteToL_D800
	JP	DrawSpriteFromL_D800
       endif
;
spriteX       DB       #00
spritey       DB       #00
spritehgt       DB       #00
curspritescraddr       DB       #00,#00
;
PlaySFXL_6DFD
	LD	HL,L_6DFD
	JR	L_6DC9
;
PlaySFXL_6DE1
	LD	HL,L_6DE1
	JR	L_6DC9
;
PlaySFXL_6E0B
	LD	HL,L_6E0B
	JR	L_6DC9
;
PlaySFXL_6DEF
	LD	HL,L_6DEF
L_6DC9	LD	D,#00
	LD	A,#0E
L_6DCD	LD	E,(HL)
	INC	HL
	CALL	OutAY_Dreg_E
	INC	D
	CP	D
	RET	Z
	JR	L_6DCD
;
OutAY_Dreg_E
	LD	BC,0xFFFD
	OUT	(C),D
	LD	B,#BF
	OUT	(C),E
	RET
;
L_6DE1       DB       #00,#00,#CA,#00,#C8,#00,#01,#F8
       DB       #00,#10,#10,#00,#0A,#00
L_6DEF       DB       #00,#00,#00,#00,#00,#00,#01,#1F
       DB       #00,#00,#10,#00,#28,#00
L_6DFD       DB       #00,#00,#00,#03,#00,#00,#01,#2D
       DB       #00,#10,#00,#01,#32,#00
L_6E0B       DB       #00,#00,#00,#00,#00,#06,#1F,#DB
       DB       #00,#00,#10,#00,#1E,#00
;
ShutSFX
	LD	BC,0xFFFD
	LD	A,#07
	OUT	(C),A
	IN	A,(C)
	RES	3,A
	LD	B,#BF
	OUT	(C),A
	RET
;
PlaySFX
	PUSH	AF
	LD	BC,0xFFFD
	LD	A,#07
	OUT	(C),A
	IN	A,(C)
	SET	3,A
	LD	B,#BF
	OUT	(C),A
	LD	B,#FF
	LD	A,#08
	OUT	(C),A
	LD	A,#0F
	LD	B,#BF
	OUT	(C),A
	POP	AF
	RET
;
PlaySFXL_6E68
	LD	DE,#07DC
	CALL	OutAY_Dreg_E
	LD	HL,(L_6E6E)
	LD	B,#06
	LD	DE,L_6E68
L_6E55	LD	A,(DE)
	INC	DE
	PUSH	BC
	LD	BC,0xFFFD
	OUT	(C),A
	LD	B,#BF
	OUTI
	POP	BC
	DJNZ	L_6E55
	LD	(L_6E6E),HL
	RET
;
L_6E68       DB       #00,#01,#02,#03,#08,#09 ;reg numbers
;
L_6E6E       DW       #0000 ;sfx cur addr
;
DrawTileMap
;to screen and to BufferScreen
	CALL	PlaySFX
	LD	BC,#0000
L_6E76	LD	A,(HL)
	INC	HL
        if EGA
        call DrawTileEGA
        else
	CALL	DrawTile
        endif
	INC	C
	INC	C
	LD	A,#20
	CP	C
	JR	NZ,L_6E76
	INC	B
	INC	B
	LD	A,#16
	CP	B
	JR	Z,CopyScreenToBufferScreen
	LD	DE,#000E
	ADD	HL,DE
	LD	C,#00
	JR	L_6E76
;
CopyScreenToBufferScreen
        if EGA
        push ix
        ld hl,scrbase
        ld de,scrhgt*256+(scrwid/4);d=hgt,e=wid (/8)
        call copyimgega_curtodefault ;before swapscr
        pop ix
        ret
        else
	LD	HL,#4000
	LD	DE,BufferScreen
	LD	BC,#1800
	LDIR
	RET
        endif
;
        if EGA == 0
DrawTile
;a=tile
;bc=YX
      PUSH	BC
      PUSH	HL
       PUSH	BC
	OR	A
	LD	DE,#0000
	JR	Z,L_6EB3
	ADD	A,A
	ADD	A,A
	LD	E,A
	ADD	A,A
	ADD	A,A
	RLA
	RL	D
	ADD	A,E
	LD	E,A
	JR	NC,L_6EB3
	INC	D
L_6EB3	LD	HL,tileset
	ADD	HL,DE
	CALL	XYCBtoDEscr
L_6EBA	ds 2 ;/set 7,d
	LD	BC,#08FF
L_6EBF	LDI
	LDI
	DEC	DE
	DEC	DE
	INC	D
	DJNZ	L_6EBF
	CALL	DownDEChr
	LD	B,#08
L_6ECD	LDI
	LDI
	DEC	DE
	DEC	DE
	INC	D
	DJNZ	L_6ECD
       POP	BC
	XOR	A
	RR	B
	RRA
	RR	B
	RRA
	RR	B
	RRA
	OR	C
	LD	E,A
	LD	A,#58
	OR	B
	LD	D,A
	LDI
	LDI
	LD	A,#1E
	ADD	A,E
	LD	E,A
	JR	NC,L_6EF2
	INC	D
L_6EF2	LDI
	LDI
      POP	HL
      POP	BC
	RET
        endif
;
GO
	LD	A,#02
	LD	(curcontroldevice),A
	LD	A,#01
	LD	(L_7110),A
	LD	(startlevel),A
GoMenu
        call Set6912
	XOR	A
	OUT	(#FE),A
	CALL	ClsZeroAttr
	CALL	PrintLogo
	CALL	L_6F7B
	CALL	L_6F99
	CALL	L_6FAF
	CALL	L_6FC5
	CALL	SetInt
	LD	DE,#5800
	LD	HL,L_719A
	CALL	L_705A
MenuLoop
	call WaitKeyCheckQuit ;CALL	WaitKey
	LD	A,#EF
	IN	A,(#FE)
	RRA ;'0'
	JP	NC,MenuStartGame
	LD	A,#F7
	IN	A,(#FE)
	RRA ;'1'
	JP	NC,MenuControl
	RRA ;'2'
	JP	NC,MenuSpeed
	RRA ;'3'
	JP	NC,MenuLevel
	RRA ;'4'
	JP	NC,MenuDemo
	JR	MenuLoop
;
WaitKey
	LD	BC,0xFEFE
L_6F4B	IN	A,(C)
	RRC	B
	CPL
	AND	#1F
	JR	Z,L_6F4B
	;LD	BC,#2710
	;JP	PauseBC
         halt
         halt
         halt
         halt
         ret
;
PrintLogo
         ;if USEINT
         ;di
         ;endif
        if USEINT == 0
	LD	(L_626A),SP
        endif
	LD	HL,MontanaJones2_logo
        if USEINT == 0
	DI
	LD sp,tscreenaddrs4040
        else
	LD iy,tscreenaddrs4040
        endif
	LD	B,#14
L_6F67
        if USEINT == 0
	POP	DE
        else
        ld e,(iy)
        inc iy
        ld d,(iy)
        inc iy
        endif
	LD	A,#03
	ADD	A,E
	LD	E,A
	LD	A,#1A
L_6F6E	LDI
	INC	BC
	DEC	A
	JR	NZ,L_6F6E
	DJNZ	L_6F67
        if USEINT == 0
	LD	SP,(L_626A)
        endif
         ;if USEINT
         ;ei
         ;endif
	RET
;
L_6F7B	LD	HL,L_714B
	LD	BC,#0706
	LD	A,#05
L_6F83	PUSH	AF
	PUSH	BC
	CALL	PrintString
	POP	BC
	POP	AF
	CP	#02
	JR	NZ,L_6F8F
	INC	B
L_6F8F	INC	B
	INC	B
	DEC	A
	JR	NZ,L_6F83
	LD	C,#02
	JP	PrintString
;
L_6F99	LD	A,(curcontroldevice)
	LD	B,A
	RLCA
	RLCA
	RLCA
	ADD	A,B
	LD	HL,L_7112
	ADD	A,L
	LD	L,A
	JR	NC,L_6FA9
	INC	H
L_6FA9	LD	BC,#0712
	JP	PrintString
;
L_6FAF	LD	A,(L_7110)
	LD	B,A
	RLCA
	RLCA
	RLCA
	SUB	B
	LD	HL,L_7136
	ADD	A,L
	LD	L,A
	JR	NC,L_6FBF
	INC	H
L_6FBF	LD	BC,#0910
	JP	PrintString
;
L_6FC5	LD	A,(startlevel)
	LD	BC,#0B10
	JP	PrintNN_A
;
MenuControl
	LD	HL,curcontroldevice
	LD	A,#03
	CP	(HL)
	JR	NZ,L_6FD8
	LD	(HL),#FF
L_6FD8	INC	(HL)
	CALL	L_6F99
L_6FDC	LD	A,#F7
	IN	A,(#FE)
	BIT	0,A
	JR	Z,L_6FDC
	JP	MenuLoop
;
MenuSpeed
	LD	HL,L_7110
	LD	A,#02
	CP	(HL)
	JR	NZ,L_6FF1
	LD	(HL),#FF
L_6FF1	INC	(HL)
	CALL	L_6FAF
L_6FF5	LD	A,#F7
	IN	A,(#FE)
	BIT	1,A
	JR	Z,L_6FF5
	JP	MenuLoop
;
MenuLevel
	LD	HL,startlevel
	LD	A,#1A
	CP	(HL)
	JR	NZ,L_700A
	LD	(HL),#FC
L_700A	LD	A,(HL)
	ADD	A,#05
	LD	(HL),A
	CALL	L_6FC5
L_7011	LD	A,#F7
	IN	A,(#FE)
	BIT	2,A
	JR	Z,L_7011
	JP	MenuLoop
;
UnpackLevel_A
;a=1..NN
	LD	DE,#00E9
	LD	HL,#0000
L_7022	ADD	HL,DE
	DEC	A
	JR	NZ,L_7022
	LD	DE,levels-#00E9;L_8FCE
	ADD	HL,DE
	LD	IX,unpackedlevel
	LD	B,#4B
L_7030	PUSH	BC
	LD	B,#08
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
L_7039	XOR	A
	SLA	C
	RL	E
	RL	D
	RLA
	SLA	C
	RL	E
	RL	D
	RLA
	SLA	C
	RL	E
	RL	D
	RLA
	LD	(IX+#00),A
	INC	IX
	DJNZ	L_7039
	POP	BC
	DJNZ	L_7030
	RET
;
L_705A	LD	A,(HL)
	CP	#FF
	RET	Z
	BIT	7,A
	JR	NZ,L_7066
	LDI
	JR	L_705A
L_7066	RES	7,A
	INC	HL
	LD	B,(HL)
L_706A	LD	(DE),A
	INC	DE
	DJNZ	L_706A
	INC	HL
	JR	L_705A
;
PrintString
	LD	A,(HL)
	INC	HL
	OR	A
	RET	Z
	PUSH	HL
	PUSH	BC
	CALL	PrintCharYScaleL_7111
	POP	BC
	POP	HL
	INC	C
	JR	PrintString

        if EGA
PrintString_EGA
	LD	A,(HL)
	INC	HL
	OR	A
	RET	Z
	PUSH	HL
	PUSH	BC
	CALL	PrintCharA_EGA ;PrintCharYScaleL_7111
	POP	BC
	POP	HL
	INC	C
	JR	PrintString_EGA
        endif
;
PrintCharYScaleL_7111
	LD	H,#00
	LD	L,A
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	CALL	XYCBtoDEscr
	LD	BC,Font-256
	ADD	HL,BC
	LD	B,#08
	LD	A,(L_7111)
L_7091	LD	C,A ;y scale
	EX	AF,AF' ;'
L_7093	LD	A,(HL)
	LD	(DE),A
	CALL	DownDE
	DEC	C
	JP	NZ,L_7093
	EX	AF,AF' ;'
	INC	HL
	DJNZ	L_7091
	RET
;
DownDE	INC	D
	LD	A,D
	AND	#07
	RET	NZ
DownDEChr
	LD	A,E
	ADD	A,#20
	LD	E,A
	RET	C
	LD	A,D
	SUB	#08
	LD	D,A
	RET
;
XYCBtoDEscr
	LD	A,B
	RRCA
	RRCA
	RRCA
	AND	#E0
	OR	C
	LD	E,A
	LD	A,#18
	AND	B
	OR	#40
	LD	D,A
	RET
;
PrNum
	LD	(L_71E1),BC
	LD	C,#00
	LD	DE,10000;#2710
	CALL	L_70E6
	LD	DE,1000;#03E8
	CALL	L_70E6
	LD	DE,100;#0064
	CALL	L_70E6
	LD	DE,10;#000A
	CALL	L_70E6
	LD	A,L
	ADD	A,#30
	LD	BC,(L_71E1)
        if EGA
        jp PrintCharA_EGA
        else
	JR	PrintCharYScaleL_7111
        endif
;
L_70E6	XOR	A
L_70E7	INC	A
	SBC	HL,DE
	JR	NC,L_70E7
	ADD	HL,DE
	CP	C
	RET	Z
	DEC	C
	ADD	A,#2F
	PUSH	BC
	PUSH	HL
	LD	BC,(L_71E1)
	LD	HL,L_71E1
	INC	(HL)
        if EGA
        call PrintCharA_EGA
        else
	CALL	PrintCharYScaleL_7111
        endif
	POP	HL
	POP	BC
	RET
;
Set6912
        if EGA
        push ix
        ld e,3+0x80 ;6912+[8noturbo]+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld a,(user_scr0_high) ;ok
        SETPG16K
        ld de,standardpal
        OS_SETPAL
        pop ix
        endif
        ret

ClsZeroAttr
	LD	HL,#5AFF
L_7105	LD	(HL),#00
	DEC	HL
	LD	A,H
	CP	#3F
	JR	NZ,L_7105
	RET
;
startlevel       DB       #00       ;.
curcontroldevice       DB       #00       ;.
;
L_7110       DB       #00       ;.
L_7111       DB       #01       ;.
L_7112 DM       "KEMPSTON",#00       ;.
       DM       "KEYBOARD",#00       ;.
       DM       "SINCLAIR",#00       ;.
       DM       "CURSOR  ",#00       ;.
L_7136 DM       "FAST  ",#00       ;.
       DM       "NORMAL",#00       ;.
       DM       "SLOW  ",#00       ;.
L_714B DM       "1  CONTROL:",#00       ;.
       DM       "2  SPEED:",#00       ;.
       DM       "3  LEVEL:",#00       ;.
       DM       "4  DEMO",#00       ;.
       DM       "0  START GAME",#00       ;.
       DM       "SHIFT  PAUSE ( IN GAME )",#00       ;.
;
L_719A       DB       #80,#43,#83,#1A,#80,#06,#83,#1A       ;.C......
       DB       #80,#06,#83,#1A,#80,#49,#07,#00       ;.....I..
       DB       #00,#85,#08,#00,#86,#08,#80,#2C       ;.......,
       DB       #07,#00,#00,#85,#06,#00,#86,#06       ;........
       DB       #80,#30,#07,#00,#00,#85,#06,#00       ;.0......
       DB       #86,#02,#80,#34,#07,#00,#00,#85       ;...4....
       DB       #04,#80,#59,#07,#00,#00,#85,#0A       ;..Y.....
       DB       #80,#2F,#87,#05,#00,#00,#85,#11       ;./......
       DB       #80,#66,#87,#20,#80,#20,#FF       ;.f. . .
;
L_71E1       DB       #00,#00
tcongratulations       DM       "CONGRATULATIONS !!!",#00
tseeyoulater       DM       "SEE YOU LATER !",#00
twaitnewgames       DM       "WAIT NEW GAMES BY HOME MASTERS",#00
L_7226       DB       #86,#20,#83,#80,#85,#80,#FF       ;. .....
;
Victory
         if EGA
         call Set6912
         endif
	CALL	ClsZeroAttr
	LD	BC,#0707
	LD	A,#02
	LD	(L_7111),A
	LD	HL,tcongratulations
	CALL	PrintString
	LD	A,#01
	LD	(L_7111),A
	LD	BC,#0C09
	LD	HL,tseeyoulater
	CALL	PrintString
	LD	BC,#0E01
	LD	HL,twaitnewgames
	CALL	PrintString
	LD	DE,#58E0
	LD	HL,L_7226
	CALL	L_705A
victorynokey0
         halt
         xor a
         in a,(0xfe)
         cpl
         and 0x1f
         jr nz,victorynokey0
	CALL	WaitKey
	JP	GoMenu
;
MenuDemo
        if USEINT == 0
	DI
        else
        ;di
        ;halt
        call SetGameInt
        endif
        if EGA
        call SetEGA
        endif
	CALL	L_EEEC
	CALL	ClsZeroAttr
	LD	HL,demo
	LD	(curdemoaddr),HL
	LD	A,#0D
	LD	(curlevel),A
	LD	A,#01
	LD	(demoon),A
	JP	GameOrDemo
;
ControlDemo
	LD	HL,(curdemoaddr)
	LD	A,(HL)
	LD	(curdirection),A
	INC	HL
	LD	(curdemoaddr),HL
	LD	BC,L_8E94
	OR	A
	SBC	HL,BC
	RET	C
	LD	A,#02
	LD	(isdead),A
	RET
;
	if EGA
SetEGA
        push ix
        ld e,0+0x80 ;EGA+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0
        OS_CLS
        ld de,pal
        OS_SETPAL
        pop ix
        ret
	endif

        if USEINT
SetGameInt
        ld hl,reter
        ld (imer_addr),hl
        ;di
        ret
        endif

SetInt
        if USEINT==0
        DI
	LD	HL,IntTable
	LD	BC,#00FE
L_729D	LD	(HL),C
	INC	HL
	DJNZ	L_729D
	LD	(HL),C
	LD	A,#C3
	LD	(IntAddr),A
	LD	HL,L_72BE
	LD	(IntAddr+1),HL
	LD	A,high IntTable
	LD	I,A
	IM	2
        else
        ld hl,L_72BE
        ld (imer_addr),hl
        endif
	CALL	L_EEEC
	LD	HL,tscroll
	LD	(curscrolladdr),HL
        if USEINT==0
	EI
        endif
	RET
;
L_72BE	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	EXX
	PUSH	BC
	PUSH	DE
	PUSH	HL
	EX	AF,AF' ;'
	PUSH	AF
	PUSH	IX
	PUSH	IY
	CALL	L_EFE0
	LD	HL,curscrollphase
	DEC	(HL)
	JR	NZ,L_7304
	LD	(HL),#08
	LD	HL,(curscrolladdr)
	LD	A,(HL)
	OR	A
	JR	NZ,L_72E2
	LD	HL,tscroll
	LD	A,(HL)
L_72E2	INC	HL
	LD	(curscrolladdr),HL
	LD	D,#00
	SLA	A
	RL	D
	SLA	A
	RL	D
	SLA	A
	RL	D
	LD	E,A
	LD	HL,Font-256
	ADD	HL,DE
	LD	DE,#50E0
	LD	B,#08
L_72FE	LD	A,(HL)
	INC	HL
	LD	(DE),A
	INC	D
	DJNZ	L_72FE
L_7304	LD	A,#08
	LD	HL,#50E0
L_7309	PUSH	HL
	OR	A
	LD	B,#21
L_730D	RL	(HL)
	DEC	HL
	DJNZ	L_730D
	POP	HL
	INC	H
	DEC	A
	JR	NZ,L_7309
	POP	IY
	POP	IX
	POP	AF
	EX	AF,AF' ;'
	POP	HL
	POP	DE
	POP	BC
	EXX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
        if USEINT == 0
	EI
        endif
	RET
;
curscrolladdr       dw 0 ;DB       #00,#00
curscrollphase       DB       #01
;
tscroll       DM       " HOME MASTERS PRESENTS  'MONTANA"
       DM       " JONES 2'  ALL CODE, GRAPHICS AN"
       DM       "D SOUND BY PAVEL, SERGEY AND ALE"
       DM       "XEY  MUSIC FROM 'TASK FORCE'  MA"
       DM       "DE IN 1994 IN TOMSK             "
       DM       "                               "
       DB       #00       ;.
;
       DB       #03,#03,#03,#03,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#01,#01,#01,#01,#00,#00       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #02,#02,#02,#06,#06,#02,#02,#02       ;........
       DB       #03,#03,#02,#02,#02,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #06,#06,#06,#06,#02,#02,#02,#02       ;........
       DB       #02,#02,#06,#06,#06,#06,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#06       ;........
       DB       #06,#02,#02,#02,#00,#00,#01,#01       ;........
       DB       #01,#01,#01,#01,#01,#01,#05,#05       ;........
       DB       #01,#01,#01,#01,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#05,#05,#01,#01       ;........
       DB       #04,#02,#02,#02,#02,#01,#01,#01       ;........
       DB       #05,#01,#01,#01,#01,#01,#01,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#02,#02,#00       ;........
       DB       #01,#01,#05,#05,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#05,#05,#01,#01       ;........
       DB       #01,#01,#01,#01,#02,#02,#06,#06       ;........
       DB       #02,#02,#04,#04,#01,#01,#02,#02       ;........
       DB       #06,#06,#06,#06,#06,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #06,#06,#06,#06,#06,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #01,#01,#01,#01,#05,#04,#04,#04       ;........
       DB       #04,#04,#04,#04,#02,#02,#02,#06       ;........
       DB       #06,#04,#04,#04,#04,#04,#06,#06       ;........
       DB       #04,#04,#04,#02,#04,#04,#04,#04       ;........
       DB       #02,#02,#06,#06,#02,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#00,#00,#00,#00       ;........
       DB       #00,#00,#04,#01,#01,#01,#02,#06       ;........
       DB       #06,#02,#02,#04,#04,#04,#02,#02       ;........
       DB       #02,#02,#06,#04,#04,#04,#01,#01       ;........
       DB       #01,#01,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#01,#01,#01,#01,#01,#01,#01       ;........
       DB       #01,#00,#00,#00,#06,#06,#06,#06       ;........
       DB       #06,#06,#06,#04,#04,#04,#04,#06       ;........
       DB       #06,#02,#02,#00,#04,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#04,#04,#04       ;........
       DB       #04,#04,#04,#04,#02,#02,#01,#01       ;........
       DB       #01,#01,#01,#01,#04,#01,#01,#04       ;........
       DB       #01,#01,#01,#01,#05,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#04,#00,#00,#05       ;........
       DB       #05,#05,#05,#05,#05,#05,#05,#05       ;........
       DB       #05,#05,#05,#01,#01,#01,#05,#05       ;........
       DB       #01,#04,#04,#04,#04,#04,#02,#02       ;........
       DB       #02,#06,#06,#04,#04,#04,#04,#02       ;........
       DB       #04,#04,#02,#02,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#01,#01,#00,#00       ;........
       DB       #00,#04,#04,#01,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#00,#02,#02,#01       ;........
       DB       #01,#01,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#05,#05,#01,#01,#05       ;........
       DB       #01,#01,#01,#01,#01,#01,#01,#01       ;........
       DB       #01,#01,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#8E,#01,#79,#01,#0C       ;.....y..
       DB       #00,#CA,#01,#7B,#01,#0B,#0D,#06       ;.J.{....
       DB       #02,#7D,#01,#0A,#0B,#42,#02,#7B       ;.}...B.{
       DB       #01,#09,#0C,#7E,#02,#79,#01,#08       ;...~.y..
       DB       #0C,#BA,#02,#52,#01,#07,#0C,#8E       ;.:.R....
       DB       #01,#54,#01,#0C,#0C,#CA,#01,#52       ;.T...J.R
       DB       #01,#0B,#0C,#06,#02,#50,#01,#0A       ;.....P..
       DB       #0C,#42,#02,#1C,#01,#09,#0C,#7E       ;.B.....~
       DB       #02,#1E,#01,#08,#0C,#BA,#02,#1C       ;.....:..
       DB       #01,#07,#0C,#8E,#01,#1A,#01,#0C       ;........
       DB       #0C,#CA,#01,#1C,#01,#0B,#0C,#06       ;.J......
       DB       #02,#54,#01,#0A,#0C,#42,#02,#52       ;.T...B.R
       DB       #01,#09,#0C,#7E,#02,#50,#01,#08       ;...~.P..
       DB       #0C,#BA,#02,#52,#01,#07,#0C,#8E       ;.:.R....
       DB       #01,#1E,#01,#0C,#0C,#CA,#01,#1C       ;.....J..
       DB       #01,#0B,#0C,#06,#02,#1A,#01,#0A       ;........
       DB       #0C,#42,#02,#1C,#01,#09,#0C,#7E       ;.B.....~
       DB       #02,#1E,#01,#08,#0C,#BA,#02,#FD       ;.....:.}
       DB       #00,#07,#0C,#E6,#01,#FB,#00,#0C       ;...f.{..
       DB       #0C,#22,#02,#FD,#00,#0B,#0C,#5E       ;.".}...^
       DB       #02,#FF,#00,#0A,#0C,#9A,#02,#1C       ;........
       DB       #01,#09,#0C,#D6,#02,#1A,#01,#08       ;...V....
       DB       #0C,#12,#03,#1C,#01,#07,#0C,#E6       ;.......f
       DB       #01,#1E,#01,#0C,#0C,#22,#02,#1C       ;....."..
       DB       #01,#0B,#0C,#5E,#02,#D3,#00,#0A       ;...^.S..
       DB       #0C,#9A,#02,#D5,#00,#09,#0C,#D6       ;...U...V
       DB       #02,#D7,#00,#08,#0C,#12,#03,#D5       ;.W.....U
       DB       #00,#07,#0C,#E6,#01,#FB,#00,#0C       ;...f.{..
       DB       #0C,#22,#02,#FD,#00,#0B,#0C,#5E       ;.".}...^
       DB       #02,#FF,#00,#0A,#0C,#9A,#02,#FD       ;.......}
       DB       #00,#09,#0C,#D6,#02,#FB,#00,#08       ;...V.{..
       DB       #0C,#12,#03,#D5,#00,#07,#0C,#E6       ;...U...f
       DB       #01,#D7,#00,#0C,#0C,#22,#02,#D5       ;.W...".U
       DB       #00,#0B,#0C,#5E,#02,#D3,#00,#0A       ;...^.S..
       DB       #0C,#9A,#02,#BE,#00,#09,#0C,#D6       ;...>...V
       DB       #02,#C0,#00,#08,#0C,#12,#03,#BE       ;.@.....>
       DB       #00,#07,#0C,#36,#02,#BC,#00,#0C       ;...6.<..
       DB       #0C,#72,#02,#BE,#00,#0B,#0C,#AE       ;.r.>....
       DB       #02,#D7,#00,#0A,#0C,#EA,#02,#D5       ;.W...j.U
       DB       #00,#09,#0C,#26,#03,#D3,#00,#08       ;...&.S..
       DB       #0C,#62,#03,#D5,#00,#07,#0C,#36       ;.b.U...6
       DB       #02,#C0,#00,#0C,#0C,#72,#02,#BE       ;.@...r.>
       DB       #00,#0B,#0C,#AE,#02,#BC,#00,#0A       ;.....<..
       DB       #0C,#EA,#02,#BE,#00,#09,#0C,#26       ;.j.>...&
       DB       #03,#C0,#00,#08,#0C,#62,#03,#A9       ;.@...b.)
       DB       #00,#07,#0C,#36,#02,#A7,#00,#0C       ;...6.'..
       DB       #0C,#72,#02,#A9,#00,#0B,#0C,#AE       ;.r.)....
       DB       #02,#AB,#00,#0A,#0C,#EA,#02,#BE       ;.+...j.>
       DB       #00,#09,#0C,#26,#03,#BC,#00,#08       ;...&.<..
       DB       #0C,#62,#03,#BE,#00,#07,#0C,#36       ;.b.>...6
       DB       #02,#C0,#00,#0C,#0C,#72,#02,#BE       ;.@...r.>
       DB       #00,#0B,#0C,#AE,#02,#A7,#00,#0A       ;.....'..
       DB       #0C,#EA,#02,#A9,#00,#09,#0C,#26       ;.j.)...&
       DB       #03,#AB,#00,#08,#0C,#62,#03,#A9       ;.+...b.)
       DB       #00,#07,#0C,#E0,#02,#7D,#00,#0C       ;...`.}..
       DB       #0E,#1C,#03,#7F,#00,#0B,#0C,#58       ;.......X
       DB       #03,#81,#00,#0A,#0A,#94,#03,#7F       ;........
       DB       #00,#09,#09,#D0,#03,#7D,#00,#08       ;...P.}..
       DB       #0B,#0C,#04,#7F,#00,#07,#0B,#A4       ;.......$
       DB       #02,#81,#00,#00,#0B,#A4,#02,#7F       ;.....$..
       DB       #00,#00,#0B,#A4,#02,#7D,#00,#00       ;...$.}..
       DB       #0B,#A4,#02,#7F,#00,#00,#0B,#A4       ;.$.....$
       DB       #02,#81,#00,#00,#0B,#A4,#02,#7F       ;.....$..
       DB       #00,#00,#0B,#A4,#02,#7D,#00,#00       ;...$.}..
       DB       #00,#00,#00,#00,#00,#00,#00,#D7       ;.......W
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B5,#1C,#00,#05,#00,#03       ;[m5.....
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#D4       ;6[m6[m6T
       DB       #01,#40,#07,#6D,#B6,#DB,#6D,#B6       ;.@.m6[m6
       DB       #DB,#02,#75,#03,#50,#0E,#DB,#6D       ;[.u.P.[m
       DB       #B6,#DB,#6D,#B6,#D7,#6D,#B0,#16       ;6[m6Wm0.
       DB       #09,#26,#DB,#6D,#B6,#DB,#6D,#B5       ;.&[m6[m5
       DB       #00,#00,#05,#02,#01,#B6,#DB,#6D       ;.....6[m
       DB       #B6,#DB,#6D,#40,#00,#01,#40,#80       ;6[m@..@.
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#5D,#86       ;m6[m6[].
       DB       #DB,#6D,#80,#1B,#6D,#B6,#DB,#6D       ;[m..m6[m
       DB       #B6,#D4,#00,#08,#20,#80,#4E,#DB       ;6T.. .N[
       DB       #6D,#B6,#DB,#6D,#B5,#00,#00,#00       ;m6[m5...
       DB       #02,#49,#B6,#DB,#6D,#B6,#DB,#6D       ;.I6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#DB,#60,#00,#00,#00       ;[m6[`...
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #FF,#0A,#08,#48,#24,#50,#28,#50       ;...H$P(P
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#BB,#6D,#B0,#00,#00,#00,#00       ;6;m0....
       DB       #00,#00,#1C,#00,#28,#00,#6C,#00       ;....(.l.
       DB       #24,#81,#B6,#DB,#6D,#AE,#DB,#6D       ;$.6[m.[m
       DB       #80,#1B,#5D,#B6,#DB,#60,#40,#00       ;..]6[`@.
       DB       #0A,#00,#00,#92,#06,#D4,#00,#00       ;.....T..
       DB       #00,#00,#49,#02,#80,#24,#92,#4B       ;..I..$.K
       DB       #B5,#00,#6D,#64,#D2,#49,#24,#DB       ;5.mdRI$[
       DB       #6C,#00,#02,#ED,#B6,#D8,#50,#30       ;l..m6XP0
       DB       #00,#00,#00,#00,#02,#00,#BB,#10       ;......;.
       DB       #00,#17,#6D,#B6,#DB,#6B,#B6,#C0       ;..m6[k6@
       DB       #0D,#B6,#C4,#0B,#B6,#C4,#00,#01       ;.6D.6D..
       DB       #22,#80,#36,#BB,#01,#B1,#02,#80       ;".6;.1..
       DB       #00,#00,#00,#00,#A0,#00,#28,#24       ;.... .($
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #D8,#00,#00,#00,#00,#00,#00,#00       ;X.......
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#FF,#0F,#04,#10,#20,#68,#04       ;..... h.
       DB       #50,#DB,#6D,#B6,#BB,#6D,#B6,#DB       ;P[m6;m6[
       DB       #6D,#B6,#DB,#6D,#B0,#1C,#71,#E8       ;m6[m0.qh
       DB       #E3,#81,#B6,#DB,#6D,#B6,#DB,#6D       ;c.6[m6[m
       DB       #76,#DB,#6D,#B6,#DA,#ED,#B6,#DB       ;v[m6Zm6[
       DB       #6D,#B6,#DB,#54,#95,#00,#50,#00       ;m6[T..P.
       DB       #BB,#6D,#B6,#DB,#6D,#B6,#D5,#15       ;;m6[m6U.
       DB       #76,#D6,#49,#2E,#DB,#6D,#B6,#DB       ;vVI.[m6[
       DB       #6D,#B5,#00,#50,#05,#29,#1B,#B6       ;m5.P.).6
       DB       #DB,#6D,#B6,#DB,#6D,#76,#D4,#01       ;[m6[mvT.
       DB       #40,#02,#ED,#B6,#DB,#6D,#B6,#DB       ;@.m6[m6[
       DB       #50,#05,#C3,#5D,#B6,#BB,#6D,#B6       ;P.C]6;m6
       DB       #DB,#6D,#B6,#D4,#11,#70,#D4,#00       ;[m6T.pT.
       DB       #2E,#DB,#6D,#B6,#DB,#6D,#B5,#00       ;.[m6[m5.
       DB       #5D,#75,#04,#8B,#B6,#DB,#6D,#B6       ;]u..6[m6
       DB       #DB,#6D,#76,#D7,#51,#76,#DA,#ED       ;[mvWQvZm
       DB       #B6,#DB,#6D,#B6,#DB,#50,#05,#D4       ;6[m6[P.T
       DB       #50,#00,#BB,#6D,#B6,#DB,#6D,#B6       ;P.;m6[m6
       DB       #D7,#59,#75,#14,#00,#2E,#DB,#6D       ;WYu...[m
       DB       #B6,#DB,#6D,#B5,#D4,#51,#45,#DA       ;6[m5TQEZ
       DB       #EB,#B6,#DB,#6D,#B6,#DB,#6D,#75       ;k6[m6[mu
       DB       #D7,#6D,#40,#A2,#ED,#B6,#DB,#6D       ;Wm@"m6[m
       DB       #B6,#DB,#5D,#75,#00,#50,#28,#BB       ;6[]u.P(;
       DB       #6D,#B6,#DB,#6D,#B6,#D5,#25,#41       ;m6[m6U%A
       DB       #14,#0A,#2E,#DB,#6D,#B6,#DB,#6D       ;...[m6[m
       DB       #B5,#04,#50,#05,#DB,#6B,#B6,#DB       ;5.P.[k6[
       DB       #6D,#B6,#DB,#6D,#40,#17,#6D,#41       ;m6[m@.mA
       DB       #22,#ED,#B6,#DB,#6D,#B6,#DB,#6D       ;"m6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#FF,#0A,#06,#90,#16,#88       ;m6......
       DB       #28,#50,#DB,#6D,#B6,#DB,#6D,#B5       ;(P[m6[m5
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#70,#00,#00,#00,#02       ;6[mp....
       DB       #ED,#B6,#DB,#6D,#B6,#DB,#5E,#00       ;m6[m6[^.
       DB       #00,#00,#00,#BB,#6D,#B6,#DB,#6D       ;...;m6[m
       DB       #B6,#D2,#49,#24,#92,#5C,#2E,#DB       ;6RI$.\.[
       DB       #6D,#B6,#DB,#6D,#B0,#00,#00,#00       ;m6[m0...
       DB       #14,#0B,#B6,#DB,#6D,#B6,#DB,#6D       ;..6[m6[m
       DB       #64,#92,#48,#05,#02,#ED,#B6,#DB       ;d.H..m6[
       DB       #6D,#B6,#DB,#50,#00,#00,#0D,#B0       ;m6[P...0
       DB       #BB,#6D,#B6,#DB,#6D,#B6,#D6,#49       ;;m6[m6VI
       DB       #00,#00,#00,#2E,#DB,#6D,#B6,#DB       ;....[m6[
       DB       #6D,#B5,#04,#11,#86,#DB,#6B,#B6       ;m5...[k6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DA,#EC,#00,#04,#00,#00,#00       ;6Zl.....
       DB       #00,#00,#00,#00,#46,#BB,#00,#00       ;....F;..
       DB       #BB,#6D,#B6,#DB,#60,#00,#00,#01       ;;m6[`...
       DB       #AE,#D7,#01,#26,#00,#00,#00,#00       ;.W.&....
       DB       #60,#34,#12,#EB,#B5,#C9,#20,#64       ;`4.k5I d
       DB       #92,#49,#26,#00,#00,#00,#5A,#ED       ;.I&...Zm
       DB       #40,#00,#00,#06,#07,#63,#B4,#DA       ;@....c4Z
       DB       #6D,#8E,#BB,#00,#40,#00,#60,#40       ;m.;.@.`@
       DB       #00,#00,#00,#00,#0B,#AE,#C8,#00       ;......H.
       DB       #06,#22,#01,#24,#92,#49,#24,#92       ;.".$.I$.
       DB       #6B,#B0,#00,#60,#04,#92,#04,#B6       ;k0.`...6
       DB       #00,#00,#00,#1E,#EC,#06,#00,#24       ;....l..$
       DB       #92,#10,#15,#B2,#01,#00,#B6,#DB       ;...2..6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#FF,#0A,#12,#60,#2C       ;[m6...`,
       DB       #48,#28,#48,#55,#24,#92,#49,#24       ;H(HU$.I$
       DB       #92,#49,#24,#92,#49,#24,#90,#E0       ;.I$.I$.`
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#25,#24,#92,#49,#24,#92,#49       ;.%$.I$.I
       DB       #24,#92,#49,#24,#A9,#00,#48,#00       ;$.I$).H.
       DB       #00,#00,#00,#80,#00,#00,#00,#02       ;........
       DB       #44,#01,#64,#80,#58,#29,#06,#49       ;D.d.X).I
       DB       #24,#80,#50,#90,#12,#40,#08,#04       ;$.P..@..
       DB       #8A,#20,#00,#00,#09,#24,#25,#00       ;. ...$%.
       DB       #04,#90,#00,#00,#C9,#0D,#92,#50       ;....I..P
       DB       #00,#29,#01,#00,#02,#81,#20,#00       ;.).... .
       DB       #01,#40,#02,#49,#02,#40,#01,#24       ;.@.I.@.$
       DB       #00,#00,#24,#92,#00,#00,#00,#0A       ;..$.....
       DB       #92,#49,#24,#92,#49,#24,#92,#49       ;.I$.I$.I
       DB       #24,#92,#4A,#A4,#00,#00,#00,#00       ;$.J$....
       DB       #00,#00,#00,#00,#00,#07,#09,#49       ;.......I
       DB       #24,#92,#49,#24,#92,#49,#24,#92       ;$.I$.I$.
       DB       #49,#22,#54,#00,#00,#04,#00,#49       ;I"T....I
       DB       #20,#80,#40,#20,#00,#95,#03,#0D       ; .@ ....
       DB       #80,#18,#00,#00,#00,#00,#00,#20       ;....... 
       DB       #24,#00,#00,#01,#80,#1B,#6C,#30       ;$.....l0
       DB       #18,#0C,#00,#29,#00,#00,#00,#10       ;...)....
       DB       #00,#24,#00,#08,#04,#0C,#02,#44       ;.$.....D
       DB       #82,#01,#00,#80,#40,#00,#80,#00       ;....@...
       DB       #00,#8A,#90,#00,#00,#06,#00,#0D       ;........
       DB       #80,#03,#01,#80,#03,#25,#B0,#C0       ;.....%0@
       DB       #60,#30,#18,#00,#30,#00,#01,#B0       ;`0..0..0
       DB       #09,#24,#92,#49,#24,#92,#49,#24       ;.$.I$.I$
       DB       #92,#49,#24,#92,#FF,#0E,#02,#88       ;.I$.....
       DB       #0C,#20,#38,#80,#DB,#6D,#B6,#DB       ;. 8.[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#09,#B0       ;m6[m6[.0
       DB       #00,#00,#00,#03,#6D,#80,#00,#00       ;....m...
       DB       #00,#D0,#6C,#00,#24,#00,#00,#DB       ;.Pl.$..[
       DB       #60,#2E,#DA,#EB,#B0,#9B,#6D,#9E       ;`.Zk0.m.
       DB       #DB,#6D,#B6,#DA,#CA,#00,#A2,#8D       ;[m6ZJ.".
       DB       #06,#C0,#00,#00,#00,#6C,#00,#A2       ;.@...l."
       DB       #80,#28,#A3,#09,#B6,#7B,#6A,#00       ;.(#.6{j.
       DB       #00,#00,#2E,#D8,#6A,#28,#D0,#6D       ;...Xj(Pm
       DB       #9E,#DA,#E7,#B6,#DB,#6A,#00,#02       ;.Zg6[j..
       DB       #8A,#30,#9B,#62,#00,#A0,#00,#00       ;.0.b. ..
       DB       #C2,#8C,#00,#BA,#ED,#06,#DA,#C0       ;B..:m.Z@
       DB       #B6,#D0,#00,#30,#A3,#08,#2E,#BB       ;6P.0#..;
       DB       #09,#B0,#00,#00,#00,#DA,#ED,#B6       ;.0...Zm6
       DB       #C2,#0D,#AE,#D0,#6C,#00       ;B..Pl.
unpackedlevel
       DB       #DB,#6D,#B0,#BB,#6D,#B5,#DB,#6B       ;[m0;m5[k
       DB       #B0,#9B,#00,#00,#00,#00,#2E,#24       ;0......$
       DB       #9D,#70,#1A,#9D,#06,#DB,#6D,#64       ;.p...[md
       DB       #BB,#6D,#B6,#D7,#5C,#06,#A7,#09       ;;m6W\.'.
       DB       #B5,#00,#50,#2E,#00,#00,#35,#D3       ;5.P...5S
       DB       #13,#A9,#D0,#6D,#76,#DA,#41,#AE       ;.)PmvZA.
       DB       #DA,#8D,#7D,#04,#EA,#70,#9B,#50       ;Z.}.jp.P
       DB       #00,#00,#0B,#80,#DB,#5D,#76,#BB       ;....[]v;
       DB       #0D,#06,#D7,#6D,#A4,#92,#00,#30       ;..Wm$..0
       DB       #17,#00,#28,#13,#09,#B5,#DB,#00       ;..(..5[.
       DB       #00,#00,#5C,#35,#DB,#09,#36,#D0       ;..\5[.6P
       DB       #6D,#40,#00,#6D,#B6,#D4,#92,#76       ;m@.m6T.v
       DB       #C0,#0E,#00,#9B,#6D,#B6,#DB,#6D       ;@...m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#FF       ;6[m6[m6.
       DB       #10,#10,#10,#32,#38,#0E,#90,#DB       ;...28..[
       DB       #6D,#76,#DB,#6D,#B6,#DB,#6D,#B6       ;mv[m6[m6
       DB       #DB,#6D,#B0,#00,#51,#C0,#00,#00       ;[m0.Q@..
       DB       #00,#00,#00,#00,#00,#6C,#34,#D7       ;.....l4W
       DB       #6D,#B6,#DB,#6B,#B6,#D7,#6D,#76       ;m6[k6Wmv
       DB       #DB,#12,#75,#00,#00,#00,#C6,#92       ;[.u...F.
       DB       #75,#40,#D2,#4E,#DA,#ED,#76,#DB       ;u@RNZmv[
       DB       #6D,#76,#DB,#5D,#75,#92,#59,#B1       ;mv[]u.Y1
       DB       #B8,#50,#01,#18,#D0,#00,#00,#55       ;8P..P..U
       DB       #64,#92,#6D,#2E,#DB,#6D,#4E,#DA       ;d.m.[mNZ
       DB       #C9,#24,#90,#09,#24,#1B,#1A,#08       ;I$..$...
       DB       #20,#D2,#8D,#A0,#00,#00,#00,#00       ; R. ....
       DB       #06,#D2,#89,#24,#92,#48,#2C,#92       ;.R.$.H,.
       DB       #49,#24,#92,#4B,#B1,#A0,#82,#08       ;I$.K1 ..
       DB       #28,#DA,#01,#00,#10,#49,#22,#ED       ;(Z...I"m
       DB       #28,#92,#49,#24,#82,#83,#48,#34       ;(.I$..H4
       DB       #8B,#69,#BB,#10,#09,#34,#92,#00       ;.i;..4..
       DB       #A6,#9A,#69,#A4,#1A,#6E,#DB,#09       ;&.i$.n[.
       DB       #25,#92,#00,#01,#A6,#9A,#69,#34       ;%...&.i4
       DB       #8B,#B6,#D8,#01,#40,#00,#00,#0D       ;.6X.@...
       DB       #20,#D2,#0D,#22,#EC,#71,#02,#59       ; R."lq.Y
       DB       #24,#92,#20,#42,#04,#20,#02,#BB       ;$. B. .;
       DB       #5D,#9E,#14,#00,#00,#00,#00,#00       ;].......
       DB       #00,#00,#2E,#D4,#0D,#85,#92,#49       ;...T...I
       DB       #24,#9B,#4D,#B4,#DB,#4B,#B5,#D6       ;$.M4[K5V
       DB       #8A,#28,#00,#00,#00,#14,#01,#40       ;.(.....@
       DB       #B6,#EC,#71,#55,#25,#41,#24,#90       ;6lqU%A$.
       DB       #2A,#A2,#AA,#00,#BB,#6D,#B6,#DB       ;*"*.;m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #FF,#32,#18,#68,#04,#10,#10,#20       ;.2.h... 
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DA,#ED       ;[m6[m6Zm
       DB       #B6,#DB,#6D,#B0,#00,#00,#00,#00       ;6[m0....
       DB       #00,#38,#A0,#12,#49,#20,#6C,#49       ;.8 .I lI
       DB       #DB,#6D,#B6,#DB,#6D,#B0,#02,#81       ;[m6[m0..
       DB       #40,#1B,#5D,#B6,#DB,#01,#68,#00       ;@.]6[.h.
       DB       #10,#00,#12,#49,#46,#D4,#01,#B6       ;...IFT.6
       DB       #02,#81,#76,#78,#00,#09,#08,#51       ;..vx...Q
       DB       #B5,#00,#0C,#05,#00,#5D,#AE,#02       ;5....]..
       DB       #DD,#A4,#94,#6D,#41,#20,#0A,#01       ;]$.mA ..
       DB       #34,#0B,#81,#14,#12,#45,#1B,#51       ;4....E.Q
       DB       #20,#14,#01,#B5,#DA,#EB,#36,#DB       ; ..5Zk6[
       DB       #31,#46,#D4,#01,#20,#00,#0D,#76       ;1FT. ..v
       DB       #BA,#80,#48,#04,#51,#B5,#00,#00       ;:.H.Q5..
       DB       #00,#03,#5D,#AE,#A2,#ED,#45,#14       ;..]."mE.
       DB       #6C,#24,#00,#92,#49,#D7,#6B,#AC       ;l$..IWk,
       DB       #80,#50,#05,#1B,#48,#24,#DB,#6D       ;.P..H$[m
       DB       #B5,#DA,#EA,#00,#34,#81,#46,#C2       ;5Zj.4.FB
       DB       #41,#76,#D8,#01,#76,#BA,#59,#24       ;AvX.v:Y$
       DB       #80,#51,#B4,#80,#5D,#B6,#BB,#5D       ;.Q4.]6;]
       DB       #A8,#14,#00,#89,#14,#6C,#24,#17       ;(....l$.
       DB       #6D,#AE,#D7,#6B,#B6,#92,#6D,#45       ;m.Wk6.mE
       DB       #1B,#48,#05,#DB,#6B,#B5,#26,#ED       ;.H.[k5&m
       DB       #80,#24,#51,#46,#C2,#40,#00,#02       ;.$QFB@..
       DB       #ED,#B6,#BB,#64,#AE,#7B,#53,#B0       ;m6;d.{S0
       DB       #18,#49,#24,#A0,#00,#28,#00,#0A       ;.I$ .(..
       DB       #00,#17,#6C,#36,#A0,#92,#28,#49       ;..l6 .(I
       DB       #0A,#09,#22,#82,#45,#1B,#6D,#B6       ;..".E.m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#FF,#26,#30,#10,#2A,#70,#0A       ;6.&0.*p.
       DB       #88,#C0,#60,#00,#18,#00,#00,#00       ;.@`.....
       DB       #00,#30,#A0,#01,#B0,#14,#00,#05       ;.0 .0...
       DB       #00,#00,#00,#00,#0A,#2C,#D2,#6C       ;.....,Rl
       DB       #05,#08,#01,#40,#09,#24,#80,#02       ;...@.$..
       DB       #8A,#38,#1B,#01,#40,#01,#54,#00       ;.8..@.T.
       DB       #00,#00,#00,#A2,#49,#2E,#C0,#50       ;..."I.@P
       DB       #00,#14,#00,#00,#00,#00,#28,#00       ;......(.
       DB       #0B,#B0,#14,#00,#05,#00,#00,#00       ;.0......
       DB       #00,#0A,#24,#92,#EC,#35,#D3,#6D       ;..$.l5Sm
       DB       #75,#92,#49,#24,#94,#50,#00,#BB       ;u.I$.P.;
       DB       #01,#40,#00,#51,#40,#00,#00,#05       ;.@.Q@...
       DB       #B6,#49,#2E,#C0,#50,#00,#14,#50       ;6I.@P..P
       DB       #00,#00,#01,#6D,#00,#0B,#B4,#96       ;...m..4.
       DB       #49,#25,#B6,#49,#24,#92,#51,#64       ;I%6I$.Qd
       DB       #B2,#6C,#05,#00,#01,#45,#00,#00       ;2l...E..
       DB       #00,#14,#50,#28,#1B,#01,#64,#92       ;..P(..d.
       DB       #51,#40,#00,#00,#05,#16,#4B,#26       ;Q@....K&
       DB       #C0,#52,#49,#36,#D9,#24,#92,#49       ;@RI6Y$.I
       DB       #6D,#02,#81,#B4,#96,#49,#25,#B4       ;m..4.I%4
       DB       #00,#00,#00,#5B,#64,#B2,#6C,#05       ;...[d2l.
       DB       #00,#01,#45,#24,#92,#49,#34,#50       ;..E$.I4P
       DB       #28,#1B,#49,#64,#92,#51,#65,#92       ;(.Id.Qe.
       DB       #49,#25,#16,#4B,#26,#C0,#52,#49       ;I%.K&@RI
       DB       #36,#DA,#28,#A2,#8B,#6D,#02,#81       ;6Z(".m..
       DB       #B0,#16,#49,#25,#14,#51,#45,#14       ;0.I%.QE.
       DB       #5B,#64,#B2,#6C,#95,#24,#93,#45       ;[d2l.$.E
       DB       #24,#94,#91,#34,#52,#69,#3B,#6D       ;$..4Ri;m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#FF,#22,#24,#40,#24,#30       ;m6."$@$0
       DB       #38,#88,#D7,#6D,#B6,#DB,#6D,#B6       ;8.Wm6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B5,#18,#00       ;[m6[m5..
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #6D,#47,#04,#10,#41,#04,#02,#08       ;mG..A...
       DB       #20,#82,#08,#3B,#6D,#B6,#BB,#6D       ; ..;m6;m
       DB       #B6,#DB,#6D,#76,#DB,#6D,#AE,#C0       ;6[mv[m.@
       DB       #00,#28,#00,#00,#00,#00,#50,#00       ;.(....P.
       DB       #00,#0B,#B0,#00,#0A,#00,#00,#00       ;..0.....
       DB       #00,#14,#00,#00,#02,#EC,#41,#06       ;.....lA.
       DB       #90,#41,#04,#02,#0D,#20,#82,#08       ;.A... ..
       DB       #BB,#5D,#B6,#DB,#6B,#B6,#DB,#6D       ;;]6[k6[m
       DB       #B6,#D7,#6D,#B6,#D4,#00,#00,#02       ;6Wm6T...
       DB       #80,#00,#00,#00,#05,#00,#01,#B5       ;.......5
       DB       #00,#00,#00,#A0,#00,#00,#00,#01       ;... ....
       DB       #40,#00,#6D,#41,#04,#10,#69,#04       ;@.mA..i.
       DB       #02,#08,#20,#D2,#08,#3B,#6D,#B5       ;.. R.;m5
       DB       #DB,#6D,#B6,#DB,#6B,#B6,#DB,#6D       ;[m6[k6[m
       DB       #AE,#C0,#01,#40,#00,#00,#00,#02       ;.@.@....
       DB       #80,#00,#00,#0B,#B0,#00,#50,#00       ;....0.P.
       DB       #00,#00,#00,#A0,#00,#00,#02,#EC       ;... ...l
       DB       #41,#14,#10,#41,#04,#02,#28,#20       ;A..A..( 
       DB       #82,#08,#BB,#5D,#B6,#DB,#6D,#B6       ;..;]6[m6
       DB       #B7,#6D,#B6,#DB,#6D,#AE,#D4,#00       ;7m6[m.T.
       DB       #00,#00,#0D,#AD,#D8,#00,#00,#00       ;...-X...
       DB       #0B,#B6,#C0,#00,#00,#00,#6B,#70       ;.6@...kp
       DB       #00,#00,#00,#1B,#6D,#B6,#01,#00       ;....m6..
       DB       #80,#02,#D0,#02,#00,#20,#36,#DB       ;..P.. 6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#FF,#31,#18,#10,#08       ;[m6.1...
       DB       #98,#32,#98,#DB,#6B,#B6,#DB,#6D       ;.2.[k6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B0,#02       ;6[m6[m0.
       DB       #8C,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#6C,#00,#A3,#80,#00,#00,#00       ;.l.#....
       DB       #49,#00,#12,#40,#1B,#25,#B6,#DB       ;I..@.%6[
       DB       #6D,#B6,#BB,#69,#24,#9B,#6B,#B6       ;m6;i$.k6
       DB       #D4,#00,#00,#00,#00,#28,#00,#00       ;T....(..
       DB       #00,#02,#81,#B5,#00,#12,#40,#1B       ;...5..@.
       DB       #6D,#AE,#D8,#00,#00,#A0,#6D,#76       ;m.X.. mv
       DB       #DA,#49,#00,#00,#0B,#B0,#1B,#5D       ;ZI...0.]
       DB       #A8,#1B,#51,#B6,#24,#00,#00,#02       ;(.Q6$...
       DB       #80,#00,#14,#0A,#06,#D4,#0D,#B4       ;.....T.4
       DB       #D2,#6D,#B6,#DB,#52,#48,#02,#81       ;Rm6[RH..
       DB       #B5,#00,#6C,#00,#00,#00,#00,#16       ;5.l.....
       DB       #49,#20,#BB,#6D,#46,#D8,#00,#00       ;I ;mFX..
       DB       #00,#00,#05,#00,#00,#28,#1B,#51       ;.....(.Q
       DB       #B0,#00,#00,#2E,#DB,#6D,#40,#00       ;0...[m@.
       DB       #0A,#06,#D4,#00,#12,#00,#40,#00       ;..T...@.
       DB       #00,#50,#00,#92,#81,#B5,#24,#00       ;.P...5$.
       DB       #00,#00,#00,#49,#34,#02,#49,#A0       ;...I4.I 
       DB       #6D,#66,#03,#61,#A4,#B2,#49,#25       ;mf.a$2I%
       DB       #C0,#00,#28,#1B,#50,#00,#00,#00       ;@.(.P...
       DB       #28,#00,#01,#76,#00,#6D,#86,#D4       ;(..v.m.T
       DB       #24,#00,#00,#0B,#B6,#DB,#6D,#B5       ;$...6[m5
       DB       #DB,#6B,#B5,#00,#00,#30,#02,#80       ;[k5..0..
       DB       #00,#00,#01,#40,#02,#ED,#40,#03       ;...@.m@.
       DB       #6D,#80,#A0,#00,#00,#00,#50,#10       ;m. ...P.
       DB       #BB,#6D,#B6,#DB,#6D,#B6,#DB,#65       ;;m6[m6[e
       DB       #B6,#DB,#6D,#B6,#FF,#0F,#36,#10       ;6[m6..6.
       DB       #16,#18,#06,#98,#C0,#00,#00,#03       ;....@...
       DB       #50,#00,#00,#00,#00,#00,#01,#B0       ;P......0
       DB       #00,#00,#00,#1C,#00,#00,#00,#00       ;........
       DB       #00,#00,#6C,#49,#00,#00,#2C,#00       ;..lI..,.
       DB       #00,#09,#24,#00,#00,#1B,#3D,#B6       ;..$...=6
       DB       #00,#0A,#00,#1B,#6D,#B6,#DA,#ED       ;....m6Zm
       DB       #B6,#C0,#01,#B0,#02,#80,#36,#00       ;6@.0..6.
       DB       #00,#00,#A0,#01,#B1,#24,#0D,#80       ;.. .1$..
       DB       #A0,#6C,#00,#00,#92,#28,#00,#6D       ; l...(.m
       DB       #76,#D4,#6C,#28,#D8,#01,#AE,#DB       ;vTl(X..[
       DB       #6B,#B0,#1B,#50,#05,#03,#6B,#B0       ;k0.P..k0
       DB       #00,#0A,#00,#00,#00,#06,#D4,#01       ;......T.
       DB       #40,#02,#80,#00,#02,#80,#00,#00       ;@.......
       DB       #01,#B5,#00,#50,#00,#A0,#00,#00       ;.5.P. ..
       DB       #A0,#00,#00,#00,#6D,#40,#14,#00       ; ...m@..
       DB       #00,#24,#90,#28,#24,#90,#00,#1B       ;.$.($...
       DB       #50,#06,#D7,#6D,#B6,#DB,#6B,#B6       ;P.Wm6[k6
       DB       #DB,#5D,#B6,#D4,#00,#05,#00,#00       ;[]6T....
       DB       #00,#00,#00,#00,#14,#01,#B5,#00       ;......5.
       DB       #01,#40,#00,#00,#00,#00,#00,#05       ;.@......
       DB       #00,#6D,#40,#00,#50,#48,#00,#90       ;.m@.PH..
       DB       #00,#00,#91,#40,#1B,#50,#06,#DB       ;...@.P.[
       DB       #6D,#AE,#D8,#00,#2E,#DB,#6C,#06       ;m.X..[l.
       DB       #D4,#00,#00,#00,#0A,#00,#00,#0A       ;T.......
       DB       #00,#00,#01,#B5,#00,#00,#00,#02       ;...5....
       DB       #80,#00,#02,#80,#00,#00,#6D,#41       ;......mA
       DB       #24,#00,#00,#A0,#12,#40,#A0,#00       ;$.. .@ .
       DB       #09,#1B,#6D,#B6,#DB,#6D,#B6,#DB       ;..m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#FF,#23,#12       ;m6[m6.#.
       DB       #90,#20,#18,#0A,#78,#D7,#6D,#B6       ;. ..xWm6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B5,#E0,#00,#00,#00,#10,#48,#00       ;5`....H.
       DB       #02,#09,#00,#6D,#64,#00,#00,#00       ;...md...
       DB       #12,#59,#00,#02,#09,#25,#1B,#00       ;.Y...%..
       DB       #04,#00,#D2,#00,#00,#00,#25,#04       ;..R...%.
       DB       #02,#06,#C0,#00,#04,#96,#41,#24       ;..@...A$
       DB       #00,#08,#24,#92,#01,#B0,#00,#00       ;..$..0..
       DB       #05,#02,#80,#00,#02,#80,#28,#00       ;......(.
       DB       #6C,#09,#00,#02,#08,#A0,#01,#2C       ;l.... .,
       DB       #84,#8A,#00,#1B,#49,#20,#12,#49       ;....I .I
       DB       #24,#04,#0A,#06,#C4,#00,#06,#C0       ;$...D..@
       DB       #00,#20,#34,#82,#2C,#02,#81,#B6       ;. 4.,..6
       DB       #00,#91,#B0,#04,#41,#48,#22,#80       ;..0.AH".
       DB       #20,#A0,#90,#24,#92,#6C,#36,#80       ;  .$.l6.
       DB       #02,#28,#00,#01,#76,#D8,#00,#28       ;.(..vX.(
       DB       #1B,#00,#20,#02,#80,#05,#00,#50       ;.. ....P
       DB       #40,#80,#8A,#06,#C4,#C8,#00,#00       ;@...DH..
       DB       #18,#00,#12,#40,#04,#92,#41,#A4       ;...@..A$
       DB       #90,#00,#44,#90,#02,#00,#20,#00       ;..D... .
       DB       #48,#02,#6C,#00,#17,#6D,#40,#1B       ;H.l..m@.
       DB       #61,#24,#02,#49,#24,#9B,#00,#05       ;a$.I$...
       DB       #00,#50,#08,#02,#82,#08,#84,#00       ;.P......
       DB       #06,#C4,#01,#49,#14,#09,#26,#02       ;.D.I..&.
       DB       #49,#25,#10,#91,#B6,#DA,#49,#05       ;I%..6ZI.
       DB       #20,#90,#44,#02,#00,#04,#92,#EC       ; .D....l
       DB       #00,#00,#00,#24,#92,#48,#00,#00       ;...$.H..
       DB       #00,#00,#1B,#24,#92,#49,#24,#92       ;...$.I$.
       DB       #49,#24,#92,#49,#24,#96,#FF,#14       ;I$.I$...
       DB       #06,#80,#0E,#20,#28,#18,#00,#00       ;... (...
       DB       #00,#00,#0A,#28,#A0,#00,#00,#00       ;...( ...
       DB       #00,#00,#00,#00,#00,#02,#6B,#A0       ;......k 
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#03,#80,#00,#00,#10,#00,#00       ;........
       DB       #00,#00,#04,#01,#44,#B0,#50,#00       ;....D0P.
       DB       #14,#00,#00,#00,#00,#05,#00,#49       ;.......I
       DB       #2C,#90,#01,#45,#14,#00,#00,#00       ;,..E....
       DB       #51,#45,#00,#0A,#00,#00,#49,#64       ;QE....Id
       DB       #00,#00,#00,#12,#59,#00,#02,#80       ;....Y...
       DB       #00,#00,#50,#00,#00,#00,#00,#14       ;..P.....
       DB       #0A,#00,#A0,#0A,#00,#14,#00,#06       ;.. .....
       DB       #00,#00,#05,#02,#49,#2C,#92,#0A       ;....I,..
       DB       #05,#02,#81,#B0,#02,#81,#40,#A0       ;...0..@ 
       DB       #0A,#00,#02,#49,#64,#80,#EC,#00       ;...Id.l.
       DB       #92,#59,#20,#02,#80,#00,#00,#50       ;.Y ....P
       DB       #00,#BB,#08,#00,#14,#50,#00,#A0       ;.;...P. 
       DB       #01,#44,#14,#40,#20,#10,#00,#05       ;.D.@ ...
       DB       #12,#49,#2C,#92,#41,#B3,#DB,#60       ;.I,.A3[`
       DB       #00,#9B,#01,#40,#00,#0A,#00,#00       ;...@....
       DB       #6D,#76,#D8,#00,#00,#DB,#3C,#00       ;mvX..[<.
       DB       #22,#82,#00,#DB,#52,#76,#00,#00       ;"..[Rv..
       DB       #36,#D7,#60,#20,#A2,#01,#1B,#74       ;6W` "..t
       DB       #9C,#00,#00,#01,#B5,#7B,#6D,#B6       ;....5{m6
       DB       #DB,#6D,#B3,#7B,#00,#00,#00,#0D       ;[m3{....
       DB       #99,#65,#96,#59,#65,#96,#76,#00       ;.e.Ye.v.
       DB       #00,#00,#00,#6D,#B6,#DB,#6D,#B6       ;...m6[m6
       DB       #DB,#6C,#00,#01,#24,#92,#49,#24       ;[l..$.I$
       DB       #92,#49,#24,#92,#49,#24,#92,#FF       ;.I$.I$..
       DB       #11,#34,#58,#04,#68,#00,#48,#D8       ;.4X.h.HX
       DB       #00,#06,#00,#00,#00,#00,#0D,#B6       ;.......6
       DB       #00,#01,#B4,#E0,#0D,#70,#00,#00       ;..4`.p..
       DB       #00,#00,#00,#00,#00,#6D,#20,#18       ;.....m .
       DB       #D2,#00,#00,#00,#00,#1B,#00,#00       ;R.......
       DB       #1B,#40,#31,#34,#9D,#24,#80,#00       ;.@14.$..
       DB       #31,#38,#00,#06,#D0,#0D,#B5,#DB       ;18..P.5[
       DB       #00,#00,#A0,#62,#01,#C0,#51,#B4       ;.. b.@Q4
       DB       #03,#13,#49,#C0,#00,#2E,#00,#50       ;..I@...P
       DB       #00,#D4,#6D,#00,#04,#D2,#76,#00       ;.Tm..Rv.
       DB       #0A,#36,#D7,#6D,#85,#1B,#4D,#B6       ;.6Wm..M6
       DB       #D7,#6D,#B0,#02,#81,#89,#27,#01       ;Wm0...'.
       DB       #46,#D0,#0C,#4D,#27,#00,#00,#A0       ;FP.M'.. 
       DB       #0D,#B5,#00,#51,#B4,#03,#13,#49       ;.5.Q4..I
       DB       #C0,#01,#B6,#00,#00,#00,#DB,#6D       ;@.6...[m
       DB       #00,#DB,#5D,#B0,#02,#C9,#24,#92       ;.[]0.I$.
       DB       #49,#24,#9B,#40,#31,#D4,#00,#04       ;I$.@1T..
       DB       #B0,#00,#06,#C0,#00,#06,#D0,#00       ;0..@..P.
       DB       #75,#13,#60,#28,#00,#0C,#4E,#00       ;u.`(..N.
       DB       #01,#B4,#1B,#1D,#76,#D8,#4B,#28       ;.4..vXK(
       DB       #18,#80,#70,#14,#6D,#30,#C7,#52       ;..p.m0GR
       DB       #70,#C2,#8B,#40,#02,#80,#2D,#1B       ;pB.@..-.
       DB       #4C,#01,#14,#9C,#30,#A2,#8B,#B6       ;L...0".6
       DB       #BB,#51,#46,#D3,#0D,#B4,#DB,#0C       ;;QFS.4[.
       DB       #28,#A0,#62,#49,#C0,#51,#B4,#C0       ;( bI@Q4@
       DB       #01,#40,#1B,#0A,#28,#02,#ED,#80       ;.@..(.m.
       DB       #14,#6D,#00,#00,#00,#00,#02,#ED       ;.m.....m
       DB       #80,#00,#00,#36,#DB,#6D,#B6,#DB       ;...6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #FF,#23,#0E,#90,#2C,#30,#2A,#78       ;.#..,0*x
       DB       #DA,#ED,#B6,#DB,#6D,#B6,#DB,#6D       ;Zm6[m6[m
       DB       #B6,#DB,#6D,#B0,#A3,#90,#2D,#C4       ;6[m0#.-D
       DB       #0A,#05,#16,#E2,#01,#00,#ED,#B6       ;...b..m6
       DB       #D8,#4D,#70,#A0,#DA,#2E,#B8,#49       ;XMp Z.8I
       DB       #24,#1B,#12,#00,#83,#5C,#28,#A0       ;$....\( 
       DB       #D1,#AD,#00,#60,#06,#C2,#49,#21       ;Q-.`.BI!
       DB       #D7,#0A,#00,#00,#EB,#86,#04,#61       ;W...k..a
       DB       #B6,#D7,#6D,#B5,#DA,#ED,#B6,#DA       ;6Wm5Zm6Z
       DB       #ED,#B6,#DA,#EC,#00,#00,#01,#40       ;m6Zl...@
       DB       #00,#00,#00,#A0,#00,#00,#1B,#5D       ;... ...]
       DB       #B6,#DB,#5D,#B6,#DB,#6D,#AE,#DB       ;6[]6[m.[
       DB       #6D,#B6,#D4,#10,#41,#D7,#10,#00       ;m6T.AW..
       DB       #04,#6B,#40,#20,#03,#B4,#10,#41       ;.k@ .4.A
       DB       #35,#CC,#09,#80,#1A,#E0,#24,#00       ;5L...`$.
       DB       #6C,#24,#92,#0D,#68,#38,#8C,#C6       ;l$..h8.F
       DB       #B9,#E0,#33,#1B,#40,#8A,#13,#5D       ;9`3.@..]
       DB       #9E,#60,#0D,#AE,#05,#E2,#2E,#DB       ;.`...b.[
       DB       #6D,#AE,#D7,#6D,#B6,#BB,#6B,#B6       ;m.Wm6;k6
       DB       #DB,#6B,#B0,#00,#00,#05,#00,#00       ;[k0.....
       DB       #00,#02,#80,#00,#00,#6D,#AE,#DB       ;.....m.[
       DB       #6D,#76,#DB,#6D,#B6,#BB,#6D,#76       ;mv[m6;mv
       DB       #DB,#31,#8B,#3B,#5B,#6D,#B6,#DB       ;[1.;[m6[
       DB       #AE,#20,#00,#0E,#C3,#1C,#30,#D7       ;. ..C.0W
       DB       #24,#92,#4A,#EB,#84,#92,#41,#B5       ;$.Jk..A5
       DB       #0C,#50,#ED,#C4,#10,#40,#BA,#E5       ;.PmD.@:e
       DB       #11,#51,#6C,#31,#C1,#8D,#71,#92       ;.Ql1A.q.
       DB       #49,#25,#B4,#49,#24,#3B,#6D,#B6       ;I%4I$;m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#FF,#24,#0A,#68,#34,#70,#1E       ;6.$.h4p.
       DB       #38,#DB,#6D,#B6,#DB,#6D,#B6,#BB       ;8[m6[m6;
       DB       #6D,#B6,#DB,#6D,#B0,#00,#00,#00       ;m6[m0...
       DB       #00,#00,#28,#00,#00,#00,#00,#6C       ;..(....l
       DB       #01,#24,#90,#08,#01,#0A,#00,#00       ;.$......
       DB       #00,#00,#1B,#59,#34,#9A,#5C,#00       ;...Y4.\.
       DB       #E2,#80,#00,#00,#12,#46,#D4,#00       ;b....FT.
       DB       #00,#17,#01,#B6,#D8,#00,#00,#BB       ;...6X..;
       DB       #6B,#B5,#48,#24,#05,#C0,#00,#00       ;k5H$.@..
       DB       #00,#6D,#A8,#02,#ED,#40,#00,#01       ;.m(.m@..
       DB       #72,#49,#24,#90,#00,#0A,#40,#3B       ;rI$...@;
       DB       #50,#48,#00,#5D,#B6,#DB,#6D,#A8       ;PH.]6[m(
       DB       #02,#C0,#36,#D2,#4A,#09,#17,#00       ;.@6RJ...
       DB       #00,#00,#0A,#00,#A0,#01,#B4,#82       ;.... .4.
       DB       #ED,#40,#C0,#12,#49,#20,#00,#28       ;m@@.I .(
       DB       #04,#6D,#20,#A0,#5D,#B6,#BB,#6D       ;.m  ]6;m
       DB       #B6,#C3,#6B,#86,#BB,#48,#28,#14       ;6Ck.;H(.
       DB       #00,#28,#00,#00,#00,#02,#81,#AE       ;.(......
       DB       #D2,#0A,#05,#00,#00,#00,#00,#00       ;R.......
       DB       #00,#A0,#0B,#B4,#80,#12,#09,#24       ;. .4...$
       DB       #00,#48,#00,#92,#28,#02,#ED,#76       ;.H..(.mv
       DB       #DB,#6D,#B6,#D7,#6D,#86,#DB,#6A       ;[m6Wm.[j
       DB       #00,#BB,#50,#00,#00,#00,#05,#00       ;.;P.....
       DB       #00,#00,#02,#80,#2E,#D4,#12,#09       ;.....T..
       DB       #04,#81,#40,#24,#12,#40,#A0,#0B       ;..@$.@ .
       DB       #B5,#92,#49,#24,#97,#6D,#76,#12       ;5.I$.mv.
       DB       #C1,#A8,#03,#6D,#40,#00,#00,#00       ;A(.m@...
       DB       #DB,#00,#00,#A0,#00,#06,#DB,#6D       ;[.. ..[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#FF,#28,#2C,#20,#22,#20       ;m6.(, " 
       DB       #0C,#98,#DB,#6D,#B6,#DB,#6D,#B6       ;..[m6[m6
       DB       #DB,#6D,#B6,#DA,#ED,#B0,#00,#00       ;[m6Zm0..
       DB       #00,#00,#ED,#B1,#00,#6C,#00,#A0       ;..m1.l. 
       DB       #6C,#00,#00,#00,#04,#80,#01,#20       ;l...... 
       DB       #03,#6D,#A8,#1B,#00,#00,#04,#01       ;.m(.....
       DB       #20,#00,#48,#00,#20,#0E,#06,#DB       ; .H. ..[
       DB       #6D,#76,#D2,#6D,#AD,#DB,#49,#B6       ;mvRm-[I6
       DB       #BB,#6D,#B0,#00,#50,#04,#80,#0B       ;;m0.P...
       DB       #40,#12,#00,#28,#00,#6C,#00,#34       ;@..(.l.4
       DB       #11,#20,#02,#D0,#04,#80,#8A,#40       ;. .P...@
       DB       #1B,#6D,#76,#D2,#6D,#AE,#DB,#5D       ;.mvRm.[]
       DB       #B4,#9B,#6B,#B6,#C0,#50,#04,#80       ;4.k6@P..
       DB       #0A,#00,#14,#01,#20,#02,#81,#B0       ;.... ..0
       DB       #34,#01,#20,#02,#80,#45,#00,#48       ;4. ..E.H
       DB       #00,#A4,#6D,#76,#D2,#6D,#AE,#DB       ;.$mvRm.[
       DB       #6D,#B5,#DB,#49,#B6,#BB,#50,#04       ;m5[I6;P.
       DB       #80,#0A,#00,#00,#01,#40,#12,#00       ;.....@..
       DB       #2E,#D4,#01,#20,#02,#80,#08,#00       ;.T. ....
       DB       #50,#04,#80,#0B,#B6,#D2,#6D,#AE       ;P...6Rm.
       DB       #DB,#6D,#B6,#DB,#5D,#B4,#9B,#6C       ;[m6[]4.l
       DB       #04,#80,#0A,#00,#00,#00,#00,#14       ;........
       DB       #01,#20,#1B,#01,#20,#02,#80,#00       ;. .. ...
       DB       #04,#00,#05,#00,#48,#06,#D2,#6D       ;....H.Rm
       DB       #AE,#DB,#6D,#B6,#DB,#6D,#B5,#DB       ;.[m6[m5[
       DB       #49,#B4,#80,#0A,#00,#00,#00,#00       ;I4......
       DB       #00,#01,#40,#12,#6D,#20,#02,#80       ;..@.m ..
       DB       #00,#00,#80,#00,#00,#50,#04,#9B       ;.....P..
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#FF,#0C,#1E,#90,#02       ;[m6.....
       DB       #20,#2C,#20,#DB,#6D,#B6,#DB,#6D       ; , [m6[m
       DB       #AE,#DB,#6D,#B6,#DB,#6D,#B0,#00       ;.[m6[m0.
       DB       #00,#00,#00,#0A,#00,#00,#00,#00       ;........
       DB       #00,#6D,#6D,#CF,#6D,#B6,#DA,#E9       ;.mmOm6Zi
       DB       #24,#92,#49,#00,#1B,#13,#40,#00       ;$.I...@.
       DB       #90,#00,#E0,#00,#09,#00,#0A,#4E       ;..`....N
       DB       #C4,#D4,#92,#26,#49,#24,#92,#42       ;DT.&I$.B
       DB       #52,#4A,#93,#B1,#34,#00,#24,#92       ;RJ.14.$.
       DB       #49,#24,#92,#40,#00,#A4,#EC,#4D       ;I$.@.$lM
       DB       #40,#0A,#00,#14,#00,#28,#14,#00       ;@....(..
       DB       #A9,#3B,#13,#50,#D8,#60,#05,#1B       ;);.PX`..
       DB       #0A,#28,#14,#2A,#4E,#C4,#D4,#28       ;.(.*NDT(
       DB       #04,#91,#40,#00,#0A,#05,#0A,#93       ;..@.....
       DB       #B1,#35,#61,#88,#A0,#49,#25,#02       ;15a. I%.
       DB       #49,#22,#A4,#EC,#4D,#40,#81,#46       ;I"$lM@.F
       DB       #04,#00,#08,#20,#10,#A9,#3B,#13       ;... .);.
       DB       #56,#18,#60,#24,#B0,#61,#B0,#C0       ;V.`$0a0@
       DB       #2A,#4E,#C4,#D4,#28,#A0,#90,#68       ;*NDT( .h
       DB       #20,#00,#40,#0A,#93,#B1,#35,#01       ; .@..15.
       DB       #80,#00,#0B,#24,#96,#48,#02,#A4       ;...$.H.$
       DB       #EC,#4D,#40,#01,#20,#02,#81,#45       ;lM@. ..E
       DB       #00,#60,#A8,#1B,#13,#55,#00,#0C       ;.`(..U..
       DB       #30,#A0,#01,#46,#D8,#2A,#06,#DF       ;0 .FX*._
       DB       #8A,#30,#A0,#09,#2C,#92,#59,#00       ;.0 .,.Y.
       DB       #0A,#81,#B0,#1C,#01,#2C,#10,#01       ;..0..,..
       DB       #40,#14,#00,#00,#00,#6C,#01,#E0       ;@....l.`
       DB       #10,#08,#04,#00,#45,#04,#00,#00       ;....E...
       DB       #1B,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;.m6[m6[m
       DB       #B6,#DB,#6D,#B6,#FF,#0A,#0C,#90       ;6[m6....
       DB       #38,#10,#02,#98,#DB,#6D,#B6,#DB       ;8...[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DA,#ED,#B0       ;m6[m6Zm0
       DB       #20,#00,#00,#00,#00,#00,#00,#00       ; .......
       DB       #00,#E0,#6C,#00,#12,#40,#00,#00       ;.`l..@..
       DB       #00,#00,#00,#40,#2D,#1B,#0A,#12       ;...@-...
       DB       #49,#01,#6D,#B6,#DB,#6D,#02,#00       ;I.m6[m..
       DB       #06,#C2,#80,#00,#00,#50,#00,#00       ;.B...P..
       DB       #01,#40,#10,#01,#B0,#A0,#00,#00       ;.@..0 ..
       DB       #14,#48,#00,#00,#50,#00,#B0,#6C       ;.H..P.0l
       DB       #28,#12,#40,#05,#24,#D9,#09,#14       ;(.@.$Y..
       DB       #0C,#F4,#1B,#09,#20,#A0,#05,#44       ;.t..  .D
       DB       #80,#50,#05,#01,#91,#06,#C0,#01       ;.P....@.
       DB       #2C,#15,#54,#92,#5B,#01,#40,#65       ;,.T.[.@e
       DB       #C1,#B0,#92,#0A,#05,#40,#00,#00       ;A0...@..
       DB       #00,#50,#19,#70,#6D,#40,#02,#81       ;.P.pm@..
       DB       #40,#04,#92,#44,#94,#06,#5C,#1B       ;@..D..\.
       DB       #02,#48,#00,#50,#01,#34,#90,#05       ;.H.P.4..
       DB       #03,#17,#06,#C2,#EC,#04,#14,#00       ;...Bl...
       DB       #00,#00,#01,#40,#A2,#49,#B0,#24       ;...@"I0$
       DB       #91,#85,#B6,#DB,#6D,#B6,#D1,#44       ;..6[m6QD
       DB       #10,#6D,#05,#00,#00,#00,#00,#00       ;.m......
       DB       #00,#00,#00,#2C,#1B,#60,#04,#92       ;...,.`..
       DB       #49,#04,#92,#49,#24,#10,#00,#2E       ;I..I$...
       DB       #C2,#49,#00,#10,#00,#21,#20,#41       ;BI...! A
       DB       #00,#B0,#41,#B0,#18,#09,#24,#DB       ;.0A0..$[
       DB       #5D,#06,#C2,#01,#06,#80,#6C,#00       ;].B...l.
       DB       #10,#00,#10,#00,#08,#00,#14,#00       ;........
       DB       #00,#9B,#6D,#B6,#DB,#6D,#B6,#DB       ;..m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#FF,#1D,#1A       ;m6[m6...
       DB       #20,#0A,#10,#38,#90,#00,#00,#05       ; ..8....
       DB       #DB,#6D,#B6,#DB,#6D,#B0,#00,#00       ;[m6[m0..
       DB       #00,#00,#6D,#70,#00,#00,#00,#D8       ;..mp...X
       DB       #01,#B0,#00,#00,#06,#D8,#7D,#76       ;.0...X}v
       DB       #DB,#60,#06,#24,#9D,#B0,#00,#0D       ;[`.$.0..
       DB       #80,#BB,#50,#00,#1B,#13,#B6,#BB       ;.;P...6;
       DB       #0D,#80,#1B,#00,#28,#17,#6D,#80       ;....(.m.
       DB       #D9,#E0,#28,#00,#6C,#36,#17,#6D       ;Y`(.l6.m
       DB       #B0,#60,#6C,#00,#00,#0D,#80,#03       ;0`l.....
       DB       #6C,#05,#00,#0D,#B0,#03,#6B,#B6       ;l...0.k6
       DB       #DB,#6D,#B5,#1B,#6D,#B6,#00,#00       ;[m5.m6..
       DB       #00,#02,#80,#00,#00,#0D,#46,#C4       ;......FD
       DB       #81,#B6,#D7,#6B,#B6,#DB,#6D,#B6       ;.6Wk6[m6
       DB       #A3,#51,#B6,#C0,#62,#4D,#1A,#81       ;#Q6@bM..
       DB       #B6,#D8,#00,#28,#D4,#6D,#B5,#DA       ;6X.(Tm5Z
       DB       #ED,#86,#24,#B0,#00,#03,#6C,#35       ;m.$0..l5
       DB       #1B,#01,#76,#00,#61,#B5,#D8,#10       ;..v.a5X.
       DB       #06,#DB,#6D,#AE,#C0,#6D,#B6,#B8       ;.[m.@m68
       DB       #6D,#76,#18,#0B,#80,#00,#6B,#B5       ;mv....k5
       DB       #00,#00,#28,#00,#50,#06,#00,#6B       ;..(.P..k
       DB       #89,#3A,#ED,#B6,#DB,#6B,#B5,#DB       ;.:m6[k5[
       DB       #51,#B5,#DA,#ED,#B6,#BB,#6D,#B0       ;Q5Zm6;m0
       DB       #02,#ED,#46,#D4,#01,#40,#A0,#00       ;.mFT.@ .
       DB       #2E,#C4,#E2,#49,#B8,#D0,#35,#03       ;.DbI8P5.
       DB       #6C,#06,#DB,#6B,#B5,#DA,#ED,#B6       ;l.[k5Zm6
       DB       #D7,#5D,#B6,#C0,#0D,#B0,#02,#ED       ;W]6@.0.m
       DB       #40,#00,#00,#05,#00,#00,#00,#DB       ;@......[
       DB       #62,#49,#BB,#6D,#B6,#DB,#6D,#B6       ;bI;m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#FF,#1D       ;[m6[m6..
       DB       #08,#90,#06,#28,#36,#30,#DB,#6D       ;...(60[m
       DB       #B5,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;5[m6[m6[
       DB       #6D,#B6,#D9,#B7,#76,#DB,#6D,#B6       ;m6Y7v[m6
       DB       #6D,#B6,#DB,#6D,#ED,#80,#E0,#50       ;m6[mm.`P
       DB       #00,#01,#B7,#9E,#DB,#3D,#B3,#7B       ;..7.[=3{
       DB       #6B,#B0,#7B,#0D,#B6,#D9,#B6,#DB       ;k0{.6Y6[
       DB       #79,#B6,#F6,#DA,#81,#06,#C3,#6D       ;y6vZ..Cm
       DB       #B6,#DB,#36,#DB,#6F,#6D,#B6,#A3       ;6[6[om6#
       DB       #89,#80,#00,#9D,#B6,#D8,#8C,#F3       ;....6X.s
       DB       #6F,#6C,#E8,#DB,#61,#B6,#DB,#66       ;olh[a6[f
       DB       #DB,#7B,#67,#9B,#DB,#37,#B6,#D8       ;[{g.[76X
       DB       #6D,#B6,#CD,#E6,#F6,#CD,#B7,#B6       ;m6MfvM76
       DB       #D8,#02,#43,#04,#80,#33,#DB,#66       ;X.C..3[f
       DB       #DB,#7B,#6D,#B3,#AD,#B7,#9B,#6D       ;[{m3-7.m
       DB       #BD,#B6,#DB,#6D,#9B,#6F,#6C,#C3       ;=6[m.olC
       DB       #DB,#6D,#B6,#7B,#37,#B6,#6D,#BD       ;[m6{76m=
       DB       #B6,#DB,#66,#F0,#DB,#3D,#A4,#78       ;6[fp[=$x
       DB       #90,#00,#00,#02,#76,#DA,#BD,#58       ;....vZ=X
       DB       #63,#09,#36,#DB,#6C,#C6,#D9,#B7       ;c.6[lFY7
       DB       #B6,#7B,#6D,#B6,#DA,#46,#F3,#6F       ;6{m6ZFso
       DB       #31,#B6,#CD,#ED,#AE,#27,#00,#00       ;16Mm.'..
       DB       #93,#32,#40,#00,#00,#09,#DB,#67       ;.2@...[g
       DB       #58,#C0,#92,#24,#CF,#61,#B6,#DB       ;X@.$Oa6[
       DB       #6D,#B6,#DB,#3A,#F5,#20,#D9,#1E       ;m6[:u Y.
       DB       #D8,#6D,#B6,#DB,#3D,#B6,#27,#5D       ;Xm6[=6']
       DB       #49,#36,#47,#A8,#00,#00,#00,#17       ;I6G(....
       DB       #6D,#B6,#CD,#BD,#B6,#D9,#B9,#24       ;m6M=6Y9$
       DB       #92,#49,#24,#3B,#6D,#B6,#DB,#6D       ;.I$;m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#FF       ;6[m6[m6.
       DB       #1C,#2A,#28,#2E,#90,#0A,#60,#DA       ;.*(...`Z
       DB       #ED,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B0,#BC,#00,#00,#00,#00       ;[m0<....
       DB       #00,#00,#00,#00,#00,#6C,#3F,#E0       ;.....l?`
       DB       #7F,#FF,#FF,#FF,#FF,#FF,#FF,#F8       ;.......x
       DB       #1B,#01,#C0,#E0,#00,#00,#00,#0C       ;..@`....
       DB       #00,#00,#0F,#FE,#DF,#81,#F8,#12       ;...~_.x.
       DB       #49,#24,#83,#00,#00,#FC,#7F,#B0       ;I$...|.0
       DB       #00,#00,#20,#03,#49,#26,#C0,#0F       ;.. .I&@.
       DB       #C7,#FF,#EC,#3F,#1C,#40,#05,#00       ;G.l?.@..
       DB       #00,#07,#FC,#7F,#FF,#FB,#5F,#FF       ;..|..{_.
       DB       #02,#00,#00,#00,#00,#07,#FF,#FE       ;.......~
       DB       #06,#D4,#00,#3F,#E0,#0D,#B6,#03       ;.T.?`.6.
       DB       #6D,#B6,#DB,#6D,#B5,#03,#8E,#00       ;m6[m5...
       DB       #00,#00,#00,#C0,#00,#00,#00,#6C       ;...@...l
       DB       #28,#1C,#70,#00,#00,#01,#F0,#00       ;(.p...p.
       DB       #49,#24,#1B,#0F,#40,#E3,#80,#38       ;I$..@c.8
       DB       #E0,#7D,#24,#83,#FE,#3E,#C0,#51       ;`}$.~>@Q
       DB       #C7,#1C,#0E,#3F,#FF,#60,#07,#02       ;G..?.`..
       DB       #41,#B0,#FE,#8E,#38,#E3,#80,#00       ;A0~.8c..
demo
       DB       #03,#03,#03,#03,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#01,#01,#01,#01,#00,#00       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #02,#02,#02,#06,#06,#02,#02,#02       ;........
       DB       #03,#03,#02,#02,#02,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #06,#06,#06,#06,#02,#02,#02,#02       ;........
       DB       #02,#02,#06,#06,#06,#06,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#06       ;........
       DB       #06,#02,#02,#02,#00,#00,#01,#01       ;........
       DB       #01,#01,#01,#01,#01,#01,#05,#05       ;........
       DB       #01,#01,#01,#01,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#05,#05,#01,#01       ;........
       DB       #04,#02,#02,#02,#02,#01,#01,#01       ;........
       DB       #05,#01,#01,#01,#01,#01,#01,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#02,#02,#00       ;........
       DB       #01,#01,#05,#05,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#05,#05,#01,#01       ;........
       DB       #01,#01,#01,#01,#02,#02,#06,#06       ;........
       DB       #02,#02,#04,#04,#01,#01,#02,#02       ;........
       DB       #06,#06,#06,#06,#06,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #06,#06,#06,#06,#06,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#02,#02,#02,#02       ;........
       DB       #01,#01,#01,#01,#05,#04,#04,#04       ;........
       DB       #04,#04,#04,#04,#02,#02,#02,#06       ;........
       DB       #06,#04,#04,#04,#04,#04,#06,#06       ;........
       DB       #04,#04,#04,#02,#04,#04,#04,#04       ;........
       DB       #02,#02,#06,#06,#02,#02,#02,#02       ;........
       DB       #02,#02,#02,#02,#00,#00,#00,#00       ;........
       DB       #00,#00,#04,#01,#01,#01,#02,#06       ;........
       DB       #06,#02,#02,#04,#04,#04,#02,#02       ;........
       DB       #02,#02,#06,#04,#04,#04,#01,#01       ;........
       DB       #01,#01,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#01,#01,#01,#01,#01,#01,#01       ;........
       DB       #01,#00,#00,#00,#06,#06,#06,#06       ;........
       DB       #06,#06,#06,#04,#04,#04,#04,#06       ;........
       DB       #06,#02,#02,#00,#04,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#04,#04,#04       ;........
       DB       #04,#04,#04,#04,#02,#02,#01,#01       ;........
       DB       #01,#01,#01,#01,#04,#01,#01,#04       ;........
       DB       #01,#01,#01,#01,#05,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#04,#00,#00,#05       ;........
       DB       #05,#05,#05,#05,#05,#05,#05,#05       ;........
       DB       #05,#05,#05,#01,#01,#01,#05,#05       ;........
       DB       #01,#04,#04,#04,#04,#04,#02,#02       ;........
       DB       #02,#06,#06,#04,#04,#04,#04,#02       ;........
       DB       #04,#04,#02,#02,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#01,#01,#00,#00       ;........
       DB       #00,#04,#04,#01,#01,#01,#01,#01       ;........
       DB       #01,#01,#01,#01,#00,#02,#02,#01       ;........
       DB       #01,#01,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#05,#05,#01,#01,#05       ;........
       DB       #01,#01,#01,#01,#01,#01,#01,#01       ;........
       DB       #01,#01,#00,#00       ;....
;
L_8E94       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00
;
L_8EB3       DB       #8E,#01,#79,#01,#0C,#00,#CA,#01       ;..y...J.
       DB       #7B,#01,#0B,#0D,#06,#02,#7D,#01       ;{.....}.
       DB       #0A,#0B,#42,#02,#7B,#01,#09,#0C       ;..B.{...
       DB       #7E,#02,#79,#01,#08,#0C,#BA,#02       ;~.y...:.
       DB       #52,#01,#07,#0C,#8E,#01,#54,#01       ;R.....T.
       DB       #0C,#0C,#CA,#01,#52,#01,#0B,#0C       ;..J.R...
       DB       #06,#02,#50,#01,#0A,#0C,#42,#02       ;..P...B.
       DB       #1C,#01,#09,#0C,#7E,#02,#1E,#01       ;....~...
       DB       #08,#0C,#BA,#02,#1C,#01,#07,#0C       ;..:.....
       DB       #8E,#01,#1A,#01,#0C,#0C,#CA,#01       ;......J.
       DB       #1C,#01,#0B,#0C,#06,#02,#54,#01       ;......T.
       DB       #0A,#0C,#42,#02,#52,#01,#09,#0C       ;..B.R...
       DB       #7E,#02,#50,#01,#08,#0C,#BA,#02       ;~.P...:.
       DB       #52,#01,#07,#0C,#8E,#01,#1E,#01       ;R.......
       DB       #0C,#0C,#CA,#01,#1C,#01,#0B,#0C       ;..J.....
       DB       #06,#02,#1A,#01,#0A,#0C,#42,#02       ;......B.
       DB       #1C,#01,#09,#0C,#7E,#02,#1E,#01       ;....~...
       DB       #08,#0C,#BA,#02,#FD,#00,#07,#0C       ;..:.}...
       DB       #E6,#01,#FB,#00,#0C,#0C,#22,#02       ;f.{...".
       DB       #FD,#00,#0B,#0C,#5E,#02,#FF,#00       ;}...^...
       DB       #0A,#0C,#9A,#02,#1C,#01,#09,#0C       ;........
       DB       #D6,#02,#1A,#01,#08,#0C,#12,#03       ;V.......
       DB       #1C,#01,#07,#0C,#E6,#01,#1E,#01       ;....f...
       DB       #0C,#0C,#22,#02,#1C,#01,#0B,#0C       ;..".....
       DB       #5E,#02,#D3,#00,#0A,#0C,#9A,#02       ;^.S.....
       DB       #D5,#00,#09,#0C,#D6,#02,#D7,#00       ;U...V.W.
       DB       #08,#0C,#12,#03,#D5,#00,#07,#0C       ;....U...
       DB       #E6,#01,#FB,#00,#0C,#0C,#22,#02       ;f.{...".
       DB       #FD,#00,#0B,#0C,#5E,#02,#FF,#00       ;}...^...
       DB       #0A,#0C,#9A,#02,#FD,#00,#09,#0C       ;....}...
       DB       #D6,#02,#FB,#00,#08,#0C,#12,#03       ;V.{.....
       DB       #D5,#00,#07,#0C,#E6,#01,#D7,#00       ;U...f.W.
       DB       #0C,#0C,#22,#02,#D5,#00,#0B,#0C       ;..".U...
       DB       #5E,#02,#D3,#00,#0A,#0C,#9A,#02       ;^.S.....
       DB       #BE,#00,#09,#0C,#D6,#02,#C0,#00       ;>...V.@.
       DB       #08,#0C,#12       ;...
;levels=$+#00E9;L_8FCE
       DB       #03,#BE,#00,#07,#0C,#36,#02,#BC       ;.>...6.<
       DB       #00,#0C,#0C,#72,#02,#BE,#00,#0B       ;...r.>..
       DB       #0C,#AE,#02,#D7,#00,#0A,#0C,#EA       ;...W...j
       DB       #02,#D5,#00,#09,#0C,#26,#03,#D3       ;.U...&.S
       DB       #00,#08,#0C,#62,#03,#D5,#00,#07       ;...b.U..
       DB       #0C,#36,#02,#C0,#00,#0C,#0C,#72       ;.6.@...r
       DB       #02,#BE,#00,#0B,#0C,#AE,#02,#BC       ;.>.....<
       DB       #00,#0A,#0C,#EA,#02,#BE,#00,#09       ;...j.>..
       DB       #0C,#26,#03,#C0,#00,#08,#0C,#62       ;.&.@...b
       DB       #03,#A9,#00,#07,#0C,#36,#02,#A7       ;.)...6.'
       DB       #00,#0C,#0C,#72,#02,#A9,#00,#0B       ;...r.)..
       DB       #0C,#AE,#02,#AB,#00,#0A,#0C,#EA       ;...+...j
       DB       #02,#BE,#00,#09,#0C,#26,#03,#BC       ;.>...&.<
       DB       #00,#08,#0C,#62,#03,#BE,#00,#07       ;...b.>..
       DB       #0C,#36,#02,#C0,#00,#0C,#0C,#72       ;.6.@...r
       DB       #02,#BE,#00,#0B,#0C,#AE,#02,#A7       ;.>.....'
       DB       #00,#0A,#0C,#EA,#02,#A9,#00,#09       ;...j.)..
       DB       #0C,#26,#03,#AB,#00,#08,#0C,#62       ;.&.+...b
       DB       #03,#A9,#00,#07,#0C,#E0,#02,#7D       ;.)...`.}
       DB       #00,#0C,#0E,#1C,#03,#7F,#00,#0B       ;........
       DB       #0C,#58,#03,#81,#00,#0A,#0A,#94       ;.X......
       DB       #03,#7F,#00,#09,#09,#D0,#03,#7D       ;.....P.}
       DB       #00,#08,#0B,#0C,#04,#7F,#00,#07       ;........
       DB       #0B,#A4,#02,#81,#00,#00,#0B,#A4       ;.$.....$
       DB       #02,#7F,#00,#00,#0B,#A4,#02,#7D       ;.....$.}
       DB       #00,#00,#0B,#A4,#02,#7F,#00,#00       ;...$....
       DB       #0B,#A4,#02,#81,#00,#00,#0B,#A4       ;.$.....$
       DB       #02,#7F,#00,#00,#0B,#A4,#02,#7D       ;.....$.}
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00
levels
	db #D7,#6D,#B6,#DB,#6D,#B6,#DB       ;.Wm6[m6[
       DB       #6D,#B6,#DB,#6D,#B5,#1C,#00,#05       ;m6[m5...
       DB       #00,#03,#B6,#DB,#6D,#B6,#DB,#6D       ;..6[m6[m
       DB       #B6,#D4,#01,#40,#07,#6D,#B6,#DB       ;6T.@.m6[
       DB       #6D,#B6,#DB,#02,#75,#03,#50,#0E       ;m6[.u.P.
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#D7,#6D       ;[m6[m6Wm
       DB       #B0,#16,#09,#26,#DB,#6D,#B6,#DB       ;0..&[m6[
       DB       #6D,#B5,#00,#00,#05,#02,#01,#B6       ;m5.....6
       DB       #DB,#6D,#B6,#DB,#6D,#40,#00,#01       ;[m6[m@..
       DB       #40,#80,#6D,#B6,#DB,#6D,#B6,#DB       ;@.m6[m6[
       DB       #5D,#86,#DB,#6D,#80,#1B,#6D,#B6       ;].[m..m6
       DB       #DB,#6D,#B6,#D4,#00,#08,#20,#80       ;[m6T.. .
       DB       #4E,#DB,#6D,#B6,#DB,#6D,#B5,#00       ;N[m6[m5.
       DB       #00,#00,#02,#49,#B6,#DB,#6D,#B6       ;...I6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#60,#00       ;m6[m6[`.
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#FF,#0A,#08,#48,#24,#50       ;.....H$P
       DB       #28,#50,#DB,#6D,#B6,#DB,#6D,#B6       ;(P[m6[m6
       DB       #DB,#6D,#B6,#BB,#6D,#B0,#00,#00       ;[m6;m0..
       DB       #00,#00,#00,#00,#1C,#00,#28,#00       ;......(.
       DB       #6C,#00,#24,#81,#B6,#DB,#6D,#AE       ;l.$.6[m.
       DB       #DB,#6D,#80,#1B,#5D,#B6,#DB,#60       ;[m..]6[`
       DB       #40,#00,#0A,#00,#00,#92,#06,#D4       ;@......T
       DB       #00,#00,#00,#00,#49,#02,#80,#24       ;....I..$
       DB       #92,#4B,#B5,#00,#6D,#64,#D2,#49       ;.K5.mdRI
       DB       #24,#DB,#6C,#00,#02,#ED,#B6,#D8       ;$[l..m6X
       DB       #50,#30,#00,#00,#00,#00,#02,#00       ;P0......
       DB       #BB,#10,#00,#17,#6D,#B6,#DB,#6B       ;;...m6[k
       DB       #B6,#C0,#0D,#B6,#C4,#0B,#B6,#C4       ;6@.6D.6D
       DB       #00,#01,#22,#80,#36,#BB,#01,#B1       ;..".6;.1
       DB       #02,#80,#00,#00,#00,#00,#A0,#00       ;...... .
       DB       #28,#24,#6D,#B6,#DB,#6D,#B6,#DB       ;($m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#D8,#00,#00,#00,#00,#00       ;m6X.....
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#FF,#0F,#04,#10,#20       ;....... 
       DB       #68,#04,#50,#DB,#6D,#B6,#BB,#6D       ;h.P[m6;m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B0,#1C       ;6[m6[m0.
       DB       #71,#E8,#E3,#81,#B6,#DB,#6D,#B6       ;qhc.6[m6
       DB       #DB,#6D,#76,#DB,#6D,#B6,#DA,#ED       ;[mv[m6Zm
       DB       #B6,#DB,#6D,#B6,#DB,#54,#95,#00       ;6[m6[T..
       DB       #50,#00,#BB,#6D,#B6,#DB,#6D,#B6       ;P.;m6[m6
       DB       #D5,#15,#76,#D6,#49,#2E,#DB,#6D       ;U.vVI.[m
       DB       #B6,#DB,#6D,#B5,#00,#50,#05,#29       ;6[m5.P.)
       DB       #1B,#B6,#DB,#6D,#B6,#DB,#6D,#76       ;.6[m6[mv
       DB       #D4,#01,#40,#02,#ED,#B6,#DB,#6D       ;T.@.m6[m
       DB       #B6,#DB,#50,#05,#C3,#5D,#B6,#BB       ;6[P.C]6;
       DB       #6D,#B6,#DB,#6D,#B6,#D4,#11,#70       ;m6[m6T.p
       DB       #D4,#00,#2E,#DB,#6D,#B6,#DB,#6D       ;T..[m6[m
       DB       #B5,#00,#5D,#75,#04,#8B,#B6,#DB       ;5.]u..6[
       DB       #6D,#B6,#DB,#6D,#76,#D7,#51,#76       ;m6[mvWQv
       DB       #DA,#ED,#B6,#DB,#6D,#B6,#DB,#50       ;Zm6[m6[P
       DB       #05,#D4,#50,#00,#BB,#6D,#B6,#DB       ;.TP.;m6[
       DB       #6D,#B6,#D7,#59,#75,#14,#00,#2E       ;m6WYu...
       DB       #DB,#6D,#B6,#DB,#6D,#B5,#D4,#51       ;[m6[m5TQ
       DB       #45,#DA,#EB,#B6,#DB,#6D,#B6,#DB       ;EZk6[m6[
       DB       #6D,#75,#D7,#6D,#40,#A2,#ED,#B6       ;muWm@"m6
       DB       #DB,#6D,#B6,#DB,#5D,#75,#00,#50       ;[m6[]u.P
       DB       #28,#BB,#6D,#B6,#DB,#6D,#B6,#D5       ;(;m6[m6U
       DB       #25,#41,#14,#0A,#2E,#DB,#6D,#B6       ;%A...[m6
       DB       #DB,#6D,#B5,#04,#50,#05,#DB,#6B       ;[m5.P.[k
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#40,#17       ;6[m6[m@.
       DB       #6D,#41,#22,#ED,#B6,#DB,#6D,#B6       ;mA"m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#DB,#6D,#B6,#FF,#0A,#06,#90       ;6[m6....
       DB       #16,#88,#28,#50,#DB,#6D,#B6,#DB       ;..(P[m6[
       DB       #6D,#B5,#DB,#6D,#B6,#DB,#6D,#B6       ;m5[m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#70,#00,#00       ;[m6[mp..
       DB       #00,#02,#ED,#B6,#DB,#6D,#B6,#DB       ;..m6[m6[
       DB       #5E,#00,#00,#00,#00,#BB,#6D,#B6       ;^....;m6
       DB       #DB,#6D,#B6,#D2,#49,#24,#92,#5C       ;[m6RI$.\
       DB       #2E,#DB,#6D,#B6,#DB,#6D,#B0,#00       ;.[m6[m0.
       DB       #00,#00,#14,#0B,#B6,#DB,#6D,#B6       ;....6[m6
       DB       #DB,#6D,#64,#92,#48,#05,#02,#ED       ;[md.H..m
       DB       #B6,#DB,#6D,#B6,#DB,#50,#00,#00       ;6[m6[P..
       DB       #0D,#B0,#BB,#6D,#B6,#DB,#6D,#B6       ;.0;m6[m6
       DB       #D6,#49,#00,#00,#00,#2E,#DB,#6D       ;VI....[m
       DB       #B6,#DB,#6D,#B5,#04,#11,#86,#DB       ;6[m5...[
       DB       #6B,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;k6[m6[m6
       DB       #DB,#6D,#B6,#DA,#EC,#00,#04,#00       ;[m6Zl...
       DB       #00,#00,#00,#00,#00,#00,#46,#BB       ;......F;
       DB       #00,#00,#BB,#6D,#B6,#DB,#60,#00       ;..;m6[`.
       DB       #00,#01,#AE,#D7,#01,#26,#00,#00       ;...W.&..
       DB       #00,#00,#60,#34,#12,#EB,#B5,#C9       ;..`4.k5I
       DB       #20,#64,#92,#49,#26,#00,#00,#00       ; d.I&...
       DB       #5A,#ED,#40,#00,#00,#06,#07,#63       ;Zm@....c
       DB       #B4,#DA,#6D,#8E,#BB,#00,#40,#00       ;4Zm.;.@.
       DB       #60,#40,#00,#00,#00,#00,#0B,#AE       ;`@......
       DB       #C8,#00,#06,#22,#01,#24,#92,#49       ;H..".$.I
       DB       #24,#92,#6B,#B0,#00,#60,#04,#92       ;$.k0.`..
       DB       #04,#B6,#00,#00,#00,#1E,#EC,#06       ;.6....l.
       DB       #00,#24,#92,#10,#15,#B2,#01,#00       ;.$...2..
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#FF,#0A,#12       ;m6[m6...
       DB       #60,#2C,#48,#28,#48,#55,#24,#92       ;`,H(HU$.
       DB       #49,#24,#92,#49,#24,#92,#49,#24       ;I$.I$.I$
       DB       #90,#E0,#00,#00,#00,#00,#00,#00       ;.`......
       DB       #00,#00,#00,#25,#24,#92,#49,#24       ;...%$.I$
       DB       #92,#49,#24,#92,#49,#24,#A9,#00       ;.I$.I$).
       DB       #48,#00,#00,#00,#00,#80,#00,#00       ;H.......
       DB       #00,#02,#44,#01,#64,#80,#58,#29       ;..D.d.X)
       DB       #06,#49,#24,#80,#50,#90,#12,#40       ;.I$.P..@
       DB       #08,#04,#8A,#20,#00,#00,#09,#24       ;... ...$
       DB       #25,#00,#04,#90,#00,#00,#C9,#0D       ;%.....I.
       DB       #92,#50,#00,#29,#01,#00,#02,#81       ;.P.)....
       DB       #20,#00,#01,#40,#02,#49,#02,#40       ; ..@.I.@
       DB       #01,#24,#00,#00,#24,#92,#00,#00       ;.$..$...
       DB       #00,#0A,#92,#49,#24,#92,#49,#24       ;...I$.I$
       DB       #92,#49,#24,#92,#4A,#A4,#00,#00       ;.I$.J$..
       DB       #00,#00,#00,#00,#00,#00,#00,#07       ;........
       DB       #09,#49,#24,#92,#49,#24,#92,#49       ;.I$.I$.I
       DB       #24,#92,#49,#22,#54,#00,#00,#04       ;$.I"T...
       DB       #00,#49,#20,#80,#40,#20,#00,#95       ;.I .@ ..
       DB       #03,#0D,#80,#18,#00,#00,#00,#00       ;........
       DB       #00,#20,#24,#00,#00,#01,#80,#1B       ;. $.....
       DB       #6C,#30,#18,#0C,#00,#29,#00,#00       ;l0...)..
       DB       #00,#10,#00,#24,#00,#08,#04,#0C       ;...$....
       DB       #02,#44,#82,#01,#00,#80,#40,#00       ;.D....@.
       DB       #80,#00,#00,#8A,#90,#00,#00,#06       ;........
       DB       #00,#0D,#80,#03,#01,#80,#03,#25       ;.......%
       DB       #B0,#C0,#60,#30,#18,#00,#30,#00       ;0@`0..0.
       DB       #01,#B0,#09,#24,#92,#49,#24,#92       ;.0.$.I$.
       DB       #49,#24,#92,#49,#24,#92,#FF,#0E       ;I$.I$...
       DB       #02,#88,#0C,#20,#38,#80,#DB,#6D       ;... 8.[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #09,#B0,#00,#00,#00,#03,#6D,#80       ;.0....m.
       DB       #00,#00,#00,#D0,#6C,#00,#24,#00       ;...Pl.$.
       DB       #00,#DB,#60,#2E,#DA,#EB,#B0,#9B       ;.[`.Zk0.
       DB       #6D,#9E,#DB,#6D,#B6,#DA,#CA,#00       ;m.[m6ZJ.
       DB       #A2,#8D,#06,#C0,#00,#00,#00,#6C       ;"..@...l
       DB       #00,#A2,#80,#28,#A3,#09,#B6,#7B       ;.".(#.6{
       DB       #6A,#00,#00,#00,#2E,#D8,#6A,#28       ;j....Xj(
       DB       #D0,#6D,#9E,#DA,#E7,#B6,#DB,#6A       ;Pm.Zg6[j
       DB       #00,#02,#8A,#30,#9B,#62,#00,#A0       ;...0.b. 
       DB       #00,#00,#C2,#8C,#00,#BA,#ED,#06       ;..B..:m.
       DB       #DA,#C0,#B6,#D0,#00,#30,#A3,#08       ;Z@6P.0#.
       DB       #2E,#BB,#09,#B0,#00,#00,#00,#DA       ;.;.0...Z
       DB       #ED,#B6,#C2,#0D,#AE,#D0,#6C,#00       ;m6B..Pl.
       DB       #DB,#6D,#B0,#BB,#6D,#B5,#DB,#6B       ;[m0;m5[k
       DB       #B0,#9B,#00,#00,#00,#00,#2E,#24       ;0......$
       DB       #9D,#70,#1A,#9D,#06,#DB,#6D,#64       ;.p...[md
       DB       #BB,#6D,#B6,#D7,#5C,#06,#A7,#09       ;;m6W\.'.
       DB       #B5,#00,#50,#2E,#00,#00,#35,#D3       ;5.P...5S
       DB       #13,#A9,#D0,#6D,#76,#DA,#41,#AE       ;.)PmvZA.
       DB       #DA,#8D,#7D,#04,#EA,#70,#9B,#50       ;Z.}.jp.P
       DB       #00,#00,#0B,#80,#DB,#5D,#76,#BB       ;....[]v;
       DB       #0D,#06,#D7,#6D,#A4,#92,#00,#30       ;..Wm$..0
       DB       #17,#00,#28,#13,#09,#B5,#DB,#00       ;..(..5[.
       DB       #00,#00,#5C,#35,#DB,#09,#36,#D0       ;..\5[.6P
       DB       #6D,#40,#00,#6D,#B6,#D4,#92,#76       ;m@.m6T.v
       DB       #C0,#0E,#00,#9B,#6D,#B6,#DB,#6D       ;@...m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#FF       ;6[m6[m6.
       DB       #10,#10,#10,#32,#38,#0E,#90,#DB       ;...28..[
       DB       #6D,#76,#DB,#6D,#B6,#DB,#6D,#B6       ;mv[m6[m6
       DB       #DB,#6D,#B0,#00,#51,#C0,#00,#00       ;[m0.Q@..
       DB       #00,#00,#00,#00,#00,#6C,#34,#D7       ;.....l4W
       DB       #6D,#B6,#DB,#6B,#B6,#D7,#6D,#76       ;m6[k6Wmv
       DB       #DB,#12,#75,#00,#00,#00,#C6,#92       ;[.u...F.
       DB       #75,#40,#D2,#4E,#DA,#ED,#76,#DB       ;u@RNZmv[
       DB       #6D,#76,#DB,#5D,#75,#92,#59,#B1       ;mv[]u.Y1
       DB       #B8,#50,#01,#18,#D0,#00,#00,#55       ;8P..P..U
       DB       #64,#92,#6D,#2E,#DB,#6D,#4E,#DA       ;d.m.[mNZ
       DB       #C9,#24,#90,#09,#24,#1B,#1A,#08       ;I$..$...
       DB       #20,#D2,#8D,#A0,#00,#00,#00,#00       ; R. ....
       DB       #06,#D2,#89,#24,#92,#48,#2C,#92       ;.R.$.H,.
       DB       #49,#24,#92,#4B,#B1,#A0,#82,#08       ;I$.K1 ..
       DB       #28,#DA,#01,#00,#10,#49,#22,#ED       ;(Z...I"m
       DB       #28,#92,#49,#24,#82,#83,#48,#34       ;(.I$..H4
       DB       #8B,#69,#BB,#10,#09,#34,#92,#00       ;.i;..4..
       DB       #A6,#9A,#69,#A4,#1A,#6E,#DB,#09       ;&.i$.n[.
       DB       #25,#92,#00,#01,#A6,#9A,#69,#34       ;%...&.i4
       DB       #8B,#B6,#D8,#01,#40,#00,#00,#0D       ;.6X.@...
       DB       #20,#D2,#0D,#22,#EC,#71,#02,#59       ; R."lq.Y
       DB       #24,#92,#20,#42,#04,#20,#02,#BB       ;$. B. .;
       DB       #5D,#9E,#14,#00,#00,#00,#00,#00       ;].......
       DB       #00,#00,#2E,#D4,#0D,#85,#92,#49       ;...T...I
       DB       #24,#9B,#4D,#B4,#DB,#4B,#B5,#D6       ;$.M4[K5V
       DB       #8A,#28,#00,#00,#00,#14,#01,#40       ;.(.....@
       DB       #B6,#EC,#71,#55,#25,#41,#24,#90       ;6lqU%A$.
       DB       #2A,#A2,#AA,#00,#BB,#6D,#B6,#DB       ;*"*.;m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #FF,#32,#18,#68,#04,#10,#10,#20       ;.2.h... 
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DA,#ED       ;[m6[m6Zm
       DB       #B6,#DB,#6D,#B0,#00,#00,#00,#00       ;6[m0....
       DB       #00,#38,#A0,#12,#49,#20,#6C,#49       ;.8 .I lI
       DB       #DB,#6D,#B6,#DB,#6D,#B0,#02,#81       ;[m6[m0..
       DB       #40,#1B,#5D,#B6,#DB,#01,#68,#00       ;@.]6[.h.
       DB       #10,#00,#12,#49,#46,#D4,#01,#B6       ;...IFT.6
       DB       #02,#81,#76,#78,#00,#09,#08,#51       ;..vx...Q
       DB       #B5,#00,#0C,#05,#00,#5D,#AE,#02       ;5....]..
       DB       #DD,#A4,#94,#6D,#41,#20,#0A,#01       ;]$.mA ..
       DB       #34,#0B,#81,#14,#12,#45,#1B,#51       ;4....E.Q
       DB       #20,#14,#01,#B5,#DA,#EB,#36,#DB       ; ..5Zk6[
       DB       #31,#46,#D4,#01,#20,#00,#0D,#76       ;1FT. ..v
       DB       #BA,#80,#48,#04,#51,#B5,#00,#00       ;:.H.Q5..
       DB       #00,#03,#5D,#AE,#A2,#ED,#45,#14       ;..]."mE.
       DB       #6C,#24,#00,#92,#49,#D7,#6B,#AC       ;l$..IWk,
       DB       #80,#50,#05,#1B,#48,#24,#DB,#6D       ;.P..H$[m
       DB       #B5,#DA,#EA,#00,#34,#81,#46,#C2       ;5Zj.4.FB
       DB       #41,#76,#D8,#01,#76,#BA,#59,#24       ;AvX.v:Y$
       DB       #80,#51,#B4,#80,#5D,#B6,#BB,#5D       ;.Q4.]6;]
       DB       #A8,#14,#00,#89,#14,#6C,#24,#17       ;(....l$.
       DB       #6D,#AE,#D7,#6B,#B6,#92,#6D,#45       ;m.Wk6.mE
       DB       #1B,#48,#05,#DB,#6B,#B5,#26,#ED       ;.H.[k5&m
       DB       #80,#24,#51,#46,#C2,#40,#00,#02       ;.$QFB@..
       DB       #ED,#B6,#BB,#64,#AE,#7B,#53,#B0       ;m6;d.{S0
       DB       #18,#49,#24,#A0,#00,#28,#00,#0A       ;.I$ .(..
       DB       #00,#17,#6C,#36,#A0,#92,#28,#49       ;..l6 .(I
       DB       #0A,#09,#22,#82,#45,#1B,#6D,#B6       ;..".E.m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#FF,#26,#30,#10,#2A,#70,#0A       ;6.&0.*p.
       DB       #88,#C0,#60,#00,#18,#00,#00,#00       ;.@`.....
       DB       #00,#30,#A0,#01,#B0,#14,#00,#05       ;.0 .0...
       DB       #00,#00,#00,#00,#0A,#2C,#D2,#6C       ;.....,Rl
       DB       #05,#08,#01,#40,#09,#24,#80,#02       ;...@.$..
       DB       #8A,#38,#1B,#01,#40,#01,#54,#00       ;.8..@.T.
       DB       #00,#00,#00,#A2,#49,#2E,#C0,#50       ;..."I.@P
       DB       #00,#14,#00,#00,#00,#00,#28,#00       ;......(.
       DB       #0B,#B0,#14,#00,#05,#00,#00,#00       ;.0......
       DB       #00,#0A,#24,#92,#EC,#35,#D3,#6D       ;..$.l5Sm
       DB       #75,#92,#49,#24,#94,#50,#00,#BB       ;u.I$.P.;
       DB       #01,#40,#00,#51,#40,#00,#00,#05       ;.@.Q@...
       DB       #B6,#49,#2E,#C0,#50,#00,#14,#50       ;6I.@P..P
       DB       #00,#00,#01,#6D,#00,#0B,#B4,#96       ;...m..4.
       DB       #49,#25,#B6,#49,#24,#92,#51,#64       ;I%6I$.Qd
       DB       #B2,#6C,#05,#00,#01,#45,#00,#00       ;2l...E..
       DB       #00,#14,#50,#28,#1B,#01,#64,#92       ;..P(..d.
       DB       #51,#40,#00,#00,#05,#16,#4B,#26       ;Q@....K&
       DB       #C0,#52,#49,#36,#D9,#24,#92,#49       ;@RI6Y$.I
       DB       #6D,#02,#81,#B4,#96,#49,#25,#B4       ;m..4.I%4
       DB       #00,#00,#00,#5B,#64,#B2,#6C,#05       ;...[d2l.
       DB       #00,#01,#45,#24,#92,#49,#34,#50       ;..E$.I4P
       DB       #28,#1B,#49,#64,#92,#51,#65,#92       ;(.Id.Qe.
       DB       #49,#25,#16,#4B,#26,#C0,#52,#49       ;I%.K&@RI
       DB       #36,#DA,#28,#A2,#8B,#6D,#02,#81       ;6Z(".m..
       DB       #B0,#16,#49,#25,#14,#51,#45,#14       ;0.I%.QE.
       DB       #5B,#64,#B2,#6C,#95,#24,#93,#45       ;[d2l.$.E
       DB       #24,#94,#91,#34,#52,#69,#3B,#6D       ;$..4Ri;m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#FF,#22,#24,#40,#24,#30       ;m6."$@$0
       DB       #38,#88,#D7,#6D,#B6,#DB,#6D,#B6       ;8.Wm6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B5,#18,#00       ;[m6[m5..
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #6D,#47,#04,#10,#41,#04,#02,#08       ;mG..A...
       DB       #20,#82,#08,#3B,#6D,#B6,#BB,#6D       ; ..;m6;m
       DB       #B6,#DB,#6D,#76,#DB,#6D,#AE,#C0       ;6[mv[m.@
       DB       #00,#28,#00,#00,#00,#00,#50,#00       ;.(....P.
       DB       #00,#0B,#B0,#00,#0A,#00,#00,#00       ;..0.....
       DB       #00,#14,#00,#00,#02,#EC,#41,#06       ;.....lA.
       DB       #90,#41,#04,#02,#0D,#20,#82,#08       ;.A... ..
       DB       #BB,#5D,#B6,#DB,#6B,#B6,#DB,#6D       ;;]6[k6[m
       DB       #B6,#D7,#6D,#B6,#D4,#00,#00,#02       ;6Wm6T...
       DB       #80,#00,#00,#00,#05,#00,#01,#B5       ;.......5
       DB       #00,#00,#00,#A0,#00,#00,#00,#01       ;... ....
       DB       #40,#00,#6D,#41,#04,#10,#69,#04       ;@.mA..i.
       DB       #02,#08,#20,#D2,#08,#3B,#6D,#B5       ;.. R.;m5
       DB       #DB,#6D,#B6,#DB,#6B,#B6,#DB,#6D       ;[m6[k6[m
       DB       #AE,#C0,#01,#40,#00,#00,#00,#02       ;.@.@....
       DB       #80,#00,#00,#0B,#B0,#00,#50,#00       ;....0.P.
       DB       #00,#00,#00,#A0,#00,#00,#02,#EC       ;... ...l
       DB       #41,#14,#10,#41,#04,#02,#28,#20       ;A..A..( 
       DB       #82,#08,#BB,#5D,#B6,#DB,#6D,#B6       ;..;]6[m6
       DB       #B7,#6D,#B6,#DB,#6D,#AE,#D4,#00       ;7m6[m.T.
       DB       #00,#00,#0D,#AD,#D8,#00,#00,#00       ;...-X...
       DB       #0B,#B6,#C0,#00,#00,#00,#6B,#70       ;.6@...kp
       DB       #00,#00,#00,#1B,#6D,#B6,#01,#00       ;....m6..
       DB       #80,#02,#D0,#02,#00,#20,#36,#DB       ;..P.. 6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#FF,#31,#18,#10,#08       ;[m6.1...
       DB       #98,#32,#98,#DB,#6B,#B6,#DB,#6D       ;.2.[k6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B0,#02       ;6[m6[m0.
       DB       #8C,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#6C,#00,#A3,#80,#00,#00,#00       ;.l.#....
       DB       #49,#00,#12,#40,#1B,#25,#B6,#DB       ;I..@.%6[
       DB       #6D,#B6,#BB,#69,#24,#9B,#6B,#B6       ;m6;i$.k6
       DB       #D4,#00,#00,#00,#00,#28,#00,#00       ;T....(..
       DB       #00,#02,#81,#B5,#00,#12,#40,#1B       ;...5..@.
       DB       #6D,#AE,#D8,#00,#00,#A0,#6D,#76       ;m.X.. mv
       DB       #DA,#49,#00,#00,#0B,#B0,#1B,#5D       ;ZI...0.]
       DB       #A8,#1B,#51,#B6,#24,#00,#00,#02       ;(.Q6$...
       DB       #80,#00,#14,#0A,#06,#D4,#0D,#B4       ;.....T.4
       DB       #D2,#6D,#B6,#DB,#52,#48,#02,#81       ;Rm6[RH..
       DB       #B5,#00,#6C,#00,#00,#00,#00,#16       ;5.l.....
       DB       #49,#20,#BB,#6D,#46,#D8,#00,#00       ;I ;mFX..
       DB       #00,#00,#05,#00,#00,#28,#1B,#51       ;.....(.Q
       DB       #B0,#00,#00,#2E,#DB,#6D,#40,#00       ;0...[m@.
       DB       #0A,#06,#D4,#00,#12,#00,#40,#00       ;..T...@.
       DB       #00,#50,#00,#92,#81,#B5,#24,#00       ;.P...5$.
       DB       #00,#00,#00,#49,#34,#02,#49,#A0       ;...I4.I 
       DB       #6D,#66,#03,#61,#A4,#B2,#49,#25       ;mf.a$2I%
       DB       #C0,#00,#28,#1B,#50,#00,#00,#00       ;@.(.P...
       DB       #28,#00,#01,#76,#00,#6D,#86,#D4       ;(..v.m.T
       DB       #24,#00,#00,#0B,#B6,#DB,#6D,#B5       ;$...6[m5
       DB       #DB,#6B,#B5,#00,#00,#30,#02,#80       ;[k5..0..
       DB       #00,#00,#01,#40,#02,#ED,#40,#03       ;...@.m@.
       DB       #6D,#80,#A0,#00,#00,#00,#50,#10       ;m. ...P.
       DB       #BB,#6D,#B6,#DB,#6D,#B6,#DB,#65       ;;m6[m6[e
       DB       #B6,#DB,#6D,#B6,#FF,#0F,#36,#10       ;6[m6..6.
       DB       #16,#18,#06,#98,#C0,#00,#00,#03       ;....@...
       DB       #50,#00,#00,#00,#00,#00,#01,#B0       ;P......0
       DB       #00,#00,#00,#1C,#00,#00,#00,#00       ;........
       DB       #00,#00,#6C,#49,#00,#00,#2C,#00       ;..lI..,.
       DB       #00,#09,#24,#00,#00,#1B,#3D,#B6       ;..$...=6
       DB       #00,#0A,#00,#1B,#6D,#B6,#DA,#ED       ;....m6Zm
       DB       #B6,#C0,#01,#B0,#02,#80,#36,#00       ;6@.0..6.
       DB       #00,#00,#A0,#01,#B1,#24,#0D,#80       ;.. .1$..
       DB       #A0,#6C,#00,#00,#92,#28,#00,#6D       ; l...(.m
       DB       #76,#D4,#6C,#28,#D8,#01,#AE,#DB       ;vTl(X..[
       DB       #6B,#B0,#1B,#50,#05,#03,#6B,#B0       ;k0.P..k0
       DB       #00,#0A,#00,#00,#00,#06,#D4,#01       ;......T.
       DB       #40,#02,#80,#00,#02,#80,#00,#00       ;@.......
       DB       #01,#B5,#00,#50,#00,#A0,#00,#00       ;.5.P. ..
       DB       #A0,#00,#00,#00,#6D,#40,#14,#00       ; ...m@..
       DB       #00,#24,#90,#28,#24,#90,#00,#1B       ;.$.($...
       DB       #50,#06,#D7,#6D,#B6,#DB,#6B,#B6       ;P.Wm6[k6
       DB       #DB,#5D,#B6,#D4,#00,#05,#00,#00       ;[]6T....
       DB       #00,#00,#00,#00,#14,#01,#B5,#00       ;......5.
       DB       #01,#40,#00,#00,#00,#00,#00,#05       ;.@......
       DB       #00,#6D,#40,#00,#50,#48,#00,#90       ;.m@.PH..
       DB       #00,#00,#91,#40,#1B,#50,#06,#DB       ;...@.P.[
       DB       #6D,#AE,#D8,#00,#2E,#DB,#6C,#06       ;m.X..[l.
       DB       #D4,#00,#00,#00,#0A,#00,#00,#0A       ;T.......
       DB       #00,#00,#01,#B5,#00,#00,#00,#02       ;...5....
       DB       #80,#00,#02,#80,#00,#00,#6D,#41       ;......mA
       DB       #24,#00,#00,#A0,#12,#40,#A0,#00       ;$.. .@ .
       DB       #09,#1B,#6D,#B6,#DB,#6D,#B6,#DB       ;..m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#FF,#23,#12       ;m6[m6.#.
       DB       #90,#20,#18,#0A,#78,#D7,#6D,#B6       ;. ..xWm6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B5,#E0,#00,#00,#00,#10,#48,#00       ;5`....H.
       DB       #02,#09,#00,#6D,#64,#00,#00,#00       ;...md...
       DB       #12,#59,#00,#02,#09,#25,#1B,#00       ;.Y...%..
       DB       #04,#00,#D2,#00,#00,#00,#25,#04       ;..R...%.
       DB       #02,#06,#C0,#00,#04,#96,#41,#24       ;..@...A$
       DB       #00,#08,#24,#92,#01,#B0,#00,#00       ;..$..0..
       DB       #05,#02,#80,#00,#02,#80,#28,#00       ;......(.
       DB       #6C,#09,#00,#02,#08,#A0,#01,#2C       ;l.... .,
       DB       #84,#8A,#00,#1B,#49,#20,#12,#49       ;....I .I
       DB       #24,#04,#0A,#06,#C4,#00,#06,#C0       ;$...D..@
       DB       #00,#20,#34,#82,#2C,#02,#81,#B6       ;. 4.,..6
       DB       #00,#91,#B0,#04,#41,#48,#22,#80       ;..0.AH".
       DB       #20,#A0,#90,#24,#92,#6C,#36,#80       ;  .$.l6.
       DB       #02,#28,#00,#01,#76,#D8,#00,#28       ;.(..vX.(
       DB       #1B,#00,#20,#02,#80,#05,#00,#50       ;.. ....P
       DB       #40,#80,#8A,#06,#C4,#C8,#00,#00       ;@...DH..
       DB       #18,#00,#12,#40,#04,#92,#41,#A4       ;...@..A$
       DB       #90,#00,#44,#90,#02,#00,#20,#00       ;..D... .
       DB       #48,#02,#6C,#00,#17,#6D,#40,#1B       ;H.l..m@.
       DB       #61,#24,#02,#49,#24,#9B,#00,#05       ;a$.I$...
       DB       #00,#50,#08,#02,#82,#08,#84,#00       ;.P......
       DB       #06,#C4,#01,#49,#14,#09,#26,#02       ;.D.I..&.
       DB       #49,#25,#10,#91,#B6,#DA,#49,#05       ;I%..6ZI.
       DB       #20,#90,#44,#02,#00,#04,#92,#EC       ; .D....l
       DB       #00,#00,#00,#24,#92,#48,#00,#00       ;...$.H..
       DB       #00,#00,#1B,#24,#92,#49,#24,#92       ;...$.I$.
       DB       #49,#24,#92,#49,#24,#96,#FF,#14       ;I$.I$...
       DB       #06,#80,#0E,#20,#28,#18,#00,#00       ;... (...
       DB       #00,#00,#0A,#28,#A0,#00,#00,#00       ;...( ...
       DB       #00,#00,#00,#00,#00,#02,#6B,#A0       ;......k 
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#03,#80,#00,#00,#10,#00,#00       ;........
       DB       #00,#00,#04,#01,#44,#B0,#50,#00       ;....D0P.
       DB       #14,#00,#00,#00,#00,#05,#00,#49       ;.......I
       DB       #2C,#90,#01,#45,#14,#00,#00,#00       ;,..E....
       DB       #51,#45,#00,#0A,#00,#00,#49,#64       ;QE....Id
       DB       #00,#00,#00,#12,#59,#00,#02,#80       ;....Y...
       DB       #00,#00,#50,#00,#00,#00,#00,#14       ;..P.....
       DB       #0A,#00,#A0,#0A,#00,#14,#00,#06       ;.. .....
       DB       #00,#00,#05,#02,#49,#2C,#92,#0A       ;....I,..
       DB       #05,#02,#81,#B0,#02,#81,#40,#A0       ;...0..@ 
       DB       #0A,#00,#02,#49,#64,#80,#EC,#00       ;...Id.l.
       DB       #92,#59,#20,#02,#80,#00,#00,#50       ;.Y ....P
       DB       #00,#BB,#08,#00,#14,#50,#00,#A0       ;.;...P. 
       DB       #01,#44,#14,#40,#20,#10,#00,#05       ;.D.@ ...
       DB       #12,#49,#2C,#92,#41,#B3,#DB,#60       ;.I,.A3[`
       DB       #00,#9B,#01,#40,#00,#0A,#00,#00       ;...@....
       DB       #6D,#76,#D8,#00,#00,#DB,#3C,#00       ;mvX..[<.
       DB       #22,#82,#00,#DB,#52,#76,#00,#00       ;"..[Rv..
       DB       #36,#D7,#60,#20,#A2,#01,#1B,#74       ;6W` "..t
       DB       #9C,#00,#00,#01,#B5,#7B,#6D,#B6       ;....5{m6
       DB       #DB,#6D,#B3,#7B,#00,#00,#00,#0D       ;[m3{....
       DB       #99,#65,#96,#59,#65,#96,#76,#00       ;.e.Ye.v.
       DB       #00,#00,#00,#6D,#B6,#DB,#6D,#B6       ;...m6[m6
       DB       #DB,#6C,#00,#01,#24,#92,#49,#24       ;[l..$.I$
       DB       #92,#49,#24,#92,#49,#24,#92,#FF       ;.I$.I$..
       DB       #11,#34,#58,#04,#68,#00,#48,#D8       ;.4X.h.HX
       DB       #00,#06,#00,#00,#00,#00,#0D,#B6       ;.......6
       DB       #00,#01,#B4,#E0,#0D,#70,#00,#00       ;..4`.p..
       DB       #00,#00,#00,#00,#00,#6D,#20,#18       ;.....m .
       DB       #D2,#00,#00,#00,#00,#1B,#00,#00       ;R.......
       DB       #1B,#40,#31,#34,#9D,#24,#80,#00       ;.@14.$..
       DB       #31,#38,#00,#06,#D0,#0D,#B5,#DB       ;18..P.5[
       DB       #00,#00,#A0,#62,#01,#C0,#51,#B4       ;.. b.@Q4
       DB       #03,#13,#49,#C0,#00,#2E,#00,#50       ;..I@...P
       DB       #00,#D4,#6D,#00,#04,#D2,#76,#00       ;.Tm..Rv.
       DB       #0A,#36,#D7,#6D,#85,#1B,#4D,#B6       ;.6Wm..M6
       DB       #D7,#6D,#B0,#02,#81,#89,#27,#01       ;Wm0...'.
       DB       #46,#D0,#0C,#4D,#27,#00,#00,#A0       ;FP.M'.. 
       DB       #0D,#B5,#00,#51,#B4,#03,#13,#49       ;.5.Q4..I
       DB       #C0,#01,#B6,#00,#00,#00,#DB,#6D       ;@.6...[m
       DB       #00,#DB,#5D,#B0,#02,#C9,#24,#92       ;.[]0.I$.
       DB       #49,#24,#9B,#40,#31,#D4,#00,#04       ;I$.@1T..
       DB       #B0,#00,#06,#C0,#00,#06,#D0,#00       ;0..@..P.
       DB       #75,#13,#60,#28,#00,#0C,#4E,#00       ;u.`(..N.
       DB       #01,#B4,#1B,#1D,#76,#D8,#4B,#28       ;.4..vXK(
       DB       #18,#80,#70,#14,#6D,#30,#C7,#52       ;..p.m0GR
       DB       #70,#C2,#8B,#40,#02,#80,#2D,#1B       ;pB.@..-.
       DB       #4C,#01,#14,#9C,#30,#A2,#8B,#B6       ;L...0".6
       DB       #BB,#51,#46,#D3,#0D,#B4,#DB,#0C       ;;QFS.4[.
       DB       #28,#A0,#62,#49,#C0,#51,#B4,#C0       ;( bI@Q4@
       DB       #01,#40,#1B,#0A,#28,#02,#ED,#80       ;.@..(.m.
       DB       #14,#6D,#00,#00,#00,#00,#02,#ED       ;.m.....m
       DB       #80,#00,#00,#36,#DB,#6D,#B6,#DB       ;...6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #FF,#23,#0E,#90,#2C,#30,#2A,#78       ;.#..,0*x
       DB       #DA,#ED,#B6,#DB,#6D,#B6,#DB,#6D       ;Zm6[m6[m
       DB       #B6,#DB,#6D,#B0,#A3,#90,#2D,#C4       ;6[m0#.-D
       DB       #0A,#05,#16,#E2,#01,#00,#ED,#B6       ;...b..m6
       DB       #D8,#4D,#70,#A0,#DA,#2E,#B8,#49       ;XMp Z.8I
       DB       #24,#1B,#12,#00,#83,#5C,#28,#A0       ;$....\( 
       DB       #D1,#AD,#00,#60,#06,#C2,#49,#21       ;Q-.`.BI!
       DB       #D7,#0A,#00,#00,#EB,#86,#04,#61       ;W...k..a
       DB       #B6,#D7,#6D,#B5,#DA,#ED,#B6,#DA       ;6Wm5Zm6Z
       DB       #ED,#B6,#DA,#EC,#00,#00,#01,#40       ;m6Zl...@
       DB       #00,#00,#00,#A0,#00,#00,#1B,#5D       ;... ...]
       DB       #B6,#DB,#5D,#B6,#DB,#6D,#AE,#DB       ;6[]6[m.[
       DB       #6D,#B6,#D4,#10,#41,#D7,#10,#00       ;m6T.AW..
       DB       #04,#6B,#40,#20,#03,#B4,#10,#41       ;.k@ .4.A
       DB       #35,#CC,#09,#80,#1A,#E0,#24,#00       ;5L...`$.
       DB       #6C,#24,#92,#0D,#68,#38,#8C,#C6       ;l$..h8.F
       DB       #B9,#E0,#33,#1B,#40,#8A,#13,#5D       ;9`3.@..]
       DB       #9E,#60,#0D,#AE,#05,#E2,#2E,#DB       ;.`...b.[
       DB       #6D,#AE,#D7,#6D,#B6,#BB,#6B,#B6       ;m.Wm6;k6
       DB       #DB,#6B,#B0,#00,#00,#05,#00,#00       ;[k0.....
       DB       #00,#02,#80,#00,#00,#6D,#AE,#DB       ;.....m.[
       DB       #6D,#76,#DB,#6D,#B6,#BB,#6D,#76       ;mv[m6;mv
       DB       #DB,#31,#8B,#3B,#5B,#6D,#B6,#DB       ;[1.;[m6[
       DB       #AE,#20,#00,#0E,#C3,#1C,#30,#D7       ;. ..C.0W
       DB       #24,#92,#4A,#EB,#84,#92,#41,#B5       ;$.Jk..A5
       DB       #0C,#50,#ED,#C4,#10,#40,#BA,#E5       ;.PmD.@:e
       DB       #11,#51,#6C,#31,#C1,#8D,#71,#92       ;.Ql1A.q.
       DB       #49,#25,#B4,#49,#24,#3B,#6D,#B6       ;I%4I$;m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#FF,#24,#0A,#68,#34,#70,#1E       ;6.$.h4p.
       DB       #38,#DB,#6D,#B6,#DB,#6D,#B6,#BB       ;8[m6[m6;
       DB       #6D,#B6,#DB,#6D,#B0,#00,#00,#00       ;m6[m0...
       DB       #00,#00,#28,#00,#00,#00,#00,#6C       ;..(....l
       DB       #01,#24,#90,#08,#01,#0A,#00,#00       ;.$......
       DB       #00,#00,#1B,#59,#34,#9A,#5C,#00       ;...Y4.\.
       DB       #E2,#80,#00,#00,#12,#46,#D4,#00       ;b....FT.
       DB       #00,#17,#01,#B6,#D8,#00,#00,#BB       ;...6X..;
       DB       #6B,#B5,#48,#24,#05,#C0,#00,#00       ;k5H$.@..
       DB       #00,#6D,#A8,#02,#ED,#40,#00,#01       ;.m(.m@..
       DB       #72,#49,#24,#90,#00,#0A,#40,#3B       ;rI$...@;
       DB       #50,#48,#00,#5D,#B6,#DB,#6D,#A8       ;PH.]6[m(
       DB       #02,#C0,#36,#D2,#4A,#09,#17,#00       ;.@6RJ...
       DB       #00,#00,#0A,#00,#A0,#01,#B4,#82       ;.... .4.
       DB       #ED,#40,#C0,#12,#49,#20,#00,#28       ;m@@.I .(
       DB       #04,#6D,#20,#A0,#5D,#B6,#BB,#6D       ;.m  ]6;m
       DB       #B6,#C3,#6B,#86,#BB,#48,#28,#14       ;6Ck.;H(.
       DB       #00,#28,#00,#00,#00,#02,#81,#AE       ;.(......
       DB       #D2,#0A,#05,#00,#00,#00,#00,#00       ;R.......
       DB       #00,#A0,#0B,#B4,#80,#12,#09,#24       ;. .4...$
       DB       #00,#48,#00,#92,#28,#02,#ED,#76       ;.H..(.mv
       DB       #DB,#6D,#B6,#D7,#6D,#86,#DB,#6A       ;[m6Wm.[j
       DB       #00,#BB,#50,#00,#00,#00,#05,#00       ;.;P.....
       DB       #00,#00,#02,#80,#2E,#D4,#12,#09       ;.....T..
       DB       #04,#81,#40,#24,#12,#40,#A0,#0B       ;..@$.@ .
       DB       #B5,#92,#49,#24,#97,#6D,#76,#12       ;5.I$.mv.
       DB       #C1,#A8,#03,#6D,#40,#00,#00,#00       ;A(.m@...
       DB       #DB,#00,#00,#A0,#00,#06,#DB,#6D       ;[.. ..[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#FF,#28,#2C,#20,#22,#20       ;m6.(, " 
       DB       #0C,#98,#DB,#6D,#B6,#DB,#6D,#B6       ;..[m6[m6
       DB       #DB,#6D,#B6,#DA,#ED,#B0,#00,#00       ;[m6Zm0..
       DB       #00,#00,#ED,#B1,#00,#6C,#00,#A0       ;..m1.l. 
       DB       #6C,#00,#00,#00,#04,#80,#01,#20       ;l...... 
       DB       #03,#6D,#A8,#1B,#00,#00,#04,#01       ;.m(.....
       DB       #20,#00,#48,#00,#20,#0E,#06,#DB       ; .H. ..[
       DB       #6D,#76,#D2,#6D,#AD,#DB,#49,#B6       ;mvRm-[I6
       DB       #BB,#6D,#B0,#00,#50,#04,#80,#0B       ;;m0.P...
       DB       #40,#12,#00,#28,#00,#6C,#00,#34       ;@..(.l.4
       DB       #11,#20,#02,#D0,#04,#80,#8A,#40       ;. .P...@
       DB       #1B,#6D,#76,#D2,#6D,#AE,#DB,#5D       ;.mvRm.[]
       DB       #B4,#9B,#6B,#B6,#C0,#50,#04,#80       ;4.k6@P..
       DB       #0A,#00,#14,#01,#20,#02,#81,#B0       ;.... ..0
       DB       #34,#01,#20,#02,#80,#45,#00,#48       ;4. ..E.H
       DB       #00,#A4,#6D,#76,#D2,#6D,#AE,#DB       ;.$mvRm.[
       DB       #6D,#B5,#DB,#49,#B6,#BB,#50,#04       ;m5[I6;P.
       DB       #80,#0A,#00,#00,#01,#40,#12,#00       ;.....@..
       DB       #2E,#D4,#01,#20,#02,#80,#08,#00       ;.T. ....
       DB       #50,#04,#80,#0B,#B6,#D2,#6D,#AE       ;P...6Rm.
       DB       #DB,#6D,#B6,#DB,#5D,#B4,#9B,#6C       ;[m6[]4.l
       DB       #04,#80,#0A,#00,#00,#00,#00,#14       ;........
       DB       #01,#20,#1B,#01,#20,#02,#80,#00       ;. .. ...
       DB       #04,#00,#05,#00,#48,#06,#D2,#6D       ;....H.Rm
       DB       #AE,#DB,#6D,#B6,#DB,#6D,#B5,#DB       ;.[m6[m5[
       DB       #49,#B4,#80,#0A,#00,#00,#00,#00       ;I4......
       DB       #00,#01,#40,#12,#6D,#20,#02,#80       ;..@.m ..
       DB       #00,#00,#80,#00,#00,#50,#04,#9B       ;.....P..
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B6,#FF,#0C,#1E,#90,#02       ;[m6.....
       DB       #20,#2C,#20,#DB,#6D,#B6,#DB,#6D       ; , [m6[m
       DB       #AE,#DB,#6D,#B6,#DB,#6D,#B0,#00       ;.[m6[m0.
       DB       #00,#00,#00,#0A,#00,#00,#00,#00       ;........
       DB       #00,#6D,#6D,#CF,#6D,#B6,#DA,#E9       ;.mmOm6Zi
       DB       #24,#92,#49,#00,#1B,#13,#40,#00       ;$.I...@.
       DB       #90,#00,#E0,#00,#09,#00,#0A,#4E       ;..`....N
       DB       #C4,#D4,#92,#26,#49,#24,#92,#42       ;DT.&I$.B
       DB       #52,#4A,#93,#B1,#34,#00,#24,#92       ;RJ.14.$.
       DB       #49,#24,#92,#40,#00,#A4,#EC,#4D       ;I$.@.$lM
       DB       #40,#0A,#00,#14,#00,#28,#14,#00       ;@....(..
       DB       #A9,#3B,#13,#50,#D8,#60,#05,#1B       ;);.PX`..
       DB       #0A,#28,#14,#2A,#4E,#C4,#D4,#28       ;.(.*NDT(
       DB       #04,#91,#40,#00,#0A,#05,#0A,#93       ;..@.....
       DB       #B1,#35,#61,#88,#A0,#49,#25,#02       ;15a. I%.
       DB       #49,#22,#A4,#EC,#4D,#40,#81,#46       ;I"$lM@.F
       DB       #04,#00,#08,#20,#10,#A9,#3B,#13       ;... .);.
       DB       #56,#18,#60,#24,#B0,#61,#B0,#C0       ;V.`$0a0@
       DB       #2A,#4E,#C4,#D4,#28,#A0,#90,#68       ;*NDT( .h
       DB       #20,#00,#40,#0A,#93,#B1,#35,#01       ; .@..15.
       DB       #80,#00,#0B,#24,#96,#48,#02,#A4       ;...$.H.$
       DB       #EC,#4D,#40,#01,#20,#02,#81,#45       ;lM@. ..E
       DB       #00,#60,#A8,#1B,#13,#55,#00,#0C       ;.`(..U..
       DB       #30,#A0,#01,#46,#D8,#2A,#06,#DF       ;0 .FX*._
       DB       #8A,#30,#A0,#09,#2C,#92,#59,#00       ;.0 .,.Y.
       DB       #0A,#81,#B0,#1C,#01,#2C,#10,#01       ;..0..,..
       DB       #40,#14,#00,#00,#00,#6C,#01,#E0       ;@....l.`
       DB       #10,#08,#04,#00,#45,#04,#00,#00       ;....E...
       DB       #1B,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;.m6[m6[m
       DB       #B6,#DB,#6D,#B6,#FF,#0A,#0C,#90       ;6[m6....
       DB       #38,#10,#02,#98,#DB,#6D,#B6,#DB       ;8...[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DA,#ED,#B0       ;m6[m6Zm0
       DB       #20,#00,#00,#00,#00,#00,#00,#00       ; .......
       DB       #00,#E0,#6C,#00,#12,#40,#00,#00       ;.`l..@..
       DB       #00,#00,#00,#40,#2D,#1B,#0A,#12       ;...@-...
       DB       #49,#01,#6D,#B6,#DB,#6D,#02,#00       ;I.m6[m..
       DB       #06,#C2,#80,#00,#00,#50,#00,#00       ;.B...P..
       DB       #01,#40,#10,#01,#B0,#A0,#00,#00       ;.@..0 ..
       DB       #14,#48,#00,#00,#50,#00,#B0,#6C       ;.H..P.0l
       DB       #28,#12,#40,#05,#24,#D9,#09,#14       ;(.@.$Y..
       DB       #0C,#F4,#1B,#09,#20,#A0,#05,#44       ;.t..  .D
       DB       #80,#50,#05,#01,#91,#06,#C0,#01       ;.P....@.
       DB       #2C,#15,#54,#92,#5B,#01,#40,#65       ;,.T.[.@e
       DB       #C1,#B0,#92,#0A,#05,#40,#00,#00       ;A0...@..
       DB       #00,#50,#19,#70,#6D,#40,#02,#81       ;.P.pm@..
       DB       #40,#04,#92,#44,#94,#06,#5C,#1B       ;@..D..\.
       DB       #02,#48,#00,#50,#01,#34,#90,#05       ;.H.P.4..
       DB       #03,#17,#06,#C2,#EC,#04,#14,#00       ;...Bl...
       DB       #00,#00,#01,#40,#A2,#49,#B0,#24       ;...@"I0$
       DB       #91,#85,#B6,#DB,#6D,#B6,#D1,#44       ;..6[m6QD
       DB       #10,#6D,#05,#00,#00,#00,#00,#00       ;.m......
       DB       #00,#00,#00,#2C,#1B,#60,#04,#92       ;...,.`..
       DB       #49,#04,#92,#49,#24,#10,#00,#2E       ;I..I$...
       DB       #C2,#49,#00,#10,#00,#21,#20,#41       ;BI...! A
       DB       #00,#B0,#41,#B0,#18,#09,#24,#DB       ;.0A0..$[
       DB       #5D,#06,#C2,#01,#06,#80,#6C,#00       ;].B...l.
       DB       #10,#00,#10,#00,#08,#00,#14,#00       ;........
       DB       #00,#9B,#6D,#B6,#DB,#6D,#B6,#DB       ;..m6[m6[
       DB       #6D,#B6,#DB,#6D,#B6,#FF,#1D,#1A       ;m6[m6...
       DB       #20,#0A,#10,#38,#90,#00,#00,#05       ; ..8....
       DB       #DB,#6D,#B6,#DB,#6D,#B0,#00,#00       ;[m6[m0..
       DB       #00,#00,#6D,#70,#00,#00,#00,#D8       ;..mp...X
       DB       #01,#B0,#00,#00,#06,#D8,#7D,#76       ;.0...X}v
       DB       #DB,#60,#06,#24,#9D,#B0,#00,#0D       ;[`.$.0..
       DB       #80,#BB,#50,#00,#1B,#13,#B6,#BB       ;.;P...6;
       DB       #0D,#80,#1B,#00,#28,#17,#6D,#80       ;....(.m.
       DB       #D9,#E0,#28,#00,#6C,#36,#17,#6D       ;Y`(.l6.m
       DB       #B0,#60,#6C,#00,#00,#0D,#80,#03       ;0`l.....
       DB       #6C,#05,#00,#0D,#B0,#03,#6B,#B6       ;l...0.k6
       DB       #DB,#6D,#B5,#1B,#6D,#B6,#00,#00       ;[m5.m6..
       DB       #00,#02,#80,#00,#00,#0D,#46,#C4       ;......FD
       DB       #81,#B6,#D7,#6B,#B6,#DB,#6D,#B6       ;.6Wk6[m6
       DB       #A3,#51,#B6,#C0,#62,#4D,#1A,#81       ;#Q6@bM..
       DB       #B6,#D8,#00,#28,#D4,#6D,#B5,#DA       ;6X.(Tm5Z
       DB       #ED,#86,#24,#B0,#00,#03,#6C,#35       ;m.$0..l5
       DB       #1B,#01,#76,#00,#61,#B5,#D8,#10       ;..v.a5X.
       DB       #06,#DB,#6D,#AE,#C0,#6D,#B6,#B8       ;.[m.@m68
       DB       #6D,#76,#18,#0B,#80,#00,#6B,#B5       ;mv....k5
       DB       #00,#00,#28,#00,#50,#06,#00,#6B       ;..(.P..k
       DB       #89,#3A,#ED,#B6,#DB,#6B,#B5,#DB       ;.:m6[k5[
       DB       #51,#B5,#DA,#ED,#B6,#BB,#6D,#B0       ;Q5Zm6;m0
       DB       #02,#ED,#46,#D4,#01,#40,#A0,#00       ;.mFT.@ .
       DB       #2E,#C4,#E2,#49,#B8,#D0,#35,#03       ;.DbI8P5.
       DB       #6C,#06,#DB,#6B,#B5,#DA,#ED,#B6       ;l.[k5Zm6
       DB       #D7,#5D,#B6,#C0,#0D,#B0,#02,#ED       ;W]6@.0.m
       DB       #40,#00,#00,#05,#00,#00,#00,#DB       ;@......[
       DB       #62,#49,#BB,#6D,#B6,#DB,#6D,#B6       ;bI;m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#FF,#1D       ;[m6[m6..
       DB       #08,#90,#06,#28,#36,#30,#DB,#6D       ;...(60[m
       DB       #B5,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;5[m6[m6[
       DB       #6D,#B6,#D9,#B7,#76,#DB,#6D,#B6       ;m6Y7v[m6
       DB       #6D,#B6,#DB,#6D,#ED,#80,#E0,#50       ;m6[mm.`P
       DB       #00,#01,#B7,#9E,#DB,#3D,#B3,#7B       ;..7.[=3{
       DB       #6B,#B0,#7B,#0D,#B6,#D9,#B6,#DB       ;k0{.6Y6[
       DB       #79,#B6,#F6,#DA,#81,#06,#C3,#6D       ;y6vZ..Cm
       DB       #B6,#DB,#36,#DB,#6F,#6D,#B6,#A3       ;6[6[om6#
       DB       #89,#80,#00,#9D,#B6,#D8,#8C,#F3       ;....6X.s
       DB       #6F,#6C,#E8,#DB,#61,#B6,#DB,#66       ;olh[a6[f
       DB       #DB,#7B,#67,#9B,#DB,#37,#B6,#D8       ;[{g.[76X
       DB       #6D,#B6,#CD,#E6,#F6,#CD,#B7,#B6       ;m6MfvM76
       DB       #D8,#02,#43,#04,#80,#33,#DB,#66       ;X.C..3[f
       DB       #DB,#7B,#6D,#B3,#AD,#B7,#9B,#6D       ;[{m3-7.m
       DB       #BD,#B6,#DB,#6D,#9B,#6F,#6C,#C3       ;=6[m.olC
       DB       #DB,#6D,#B6,#7B,#37,#B6,#6D,#BD       ;[m6{76m=
       DB       #B6,#DB,#66,#F0,#DB,#3D,#A4,#78       ;6[fp[=$x
       DB       #90,#00,#00,#02,#76,#DA,#BD,#58       ;....vZ=X
       DB       #63,#09,#36,#DB,#6C,#C6,#D9,#B7       ;c.6[lFY7
       DB       #B6,#7B,#6D,#B6,#DA,#46,#F3,#6F       ;6{m6ZFso
       DB       #31,#B6,#CD,#ED,#AE,#27,#00,#00       ;16Mm.'..
       DB       #93,#32,#40,#00,#00,#09,#DB,#67       ;.2@...[g
       DB       #58,#C0,#92,#24,#CF,#61,#B6,#DB       ;X@.$Oa6[
       DB       #6D,#B6,#DB,#3A,#F5,#20,#D9,#1E       ;m6[:u Y.
       DB       #D8,#6D,#B6,#DB,#3D,#B6,#27,#5D       ;Xm6[=6']
       DB       #49,#36,#47,#A8,#00,#00,#00,#17       ;I6G(....
       DB       #6D,#B6,#CD,#BD,#B6,#D9,#B9,#24       ;m6M=6Y9$
       DB       #92,#49,#24,#3B,#6D,#B6,#DB,#6D       ;.I$;m6[m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#FF       ;6[m6[m6.
       DB       #1C,#2A,#28,#2E,#90,#0A,#60,#DA       ;.*(...`Z
       DB       #ED,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6D,#B0,#BC,#00,#00,#00,#00       ;[m0<....
       DB       #00,#00,#00,#00,#00,#6C,#3F,#E0       ;.....l?`
       DB       #7F,#FF,#FF,#FF,#FF,#FF,#FF,#F8       ;.......x
       DB       #1B,#01,#C0,#E0,#00,#00,#00,#0C       ;..@`....
       DB       #00,#00,#0F,#FE,#DF,#81,#F8,#12       ;...~_.x.
       DB       #49,#24,#83,#00,#00,#FC,#7F,#B0       ;I$...|.0
       DB       #00,#00,#20,#03,#49,#26,#C0,#0F       ;.. .I&@.
       DB       #C7,#FF,#EC,#3F,#1C,#40,#05,#00       ;G.l?.@..
       DB       #00,#07,#FC,#7F,#FF,#FB,#5F,#FF       ;..|..{_.
       DB       #02,#00,#00,#00,#00,#07,#FF,#FE       ;.......~
       DB       #06,#D4,#00,#3F,#E0,#0D,#B6,#03       ;.T.?`.6.
       DB       #6D,#B6,#DB,#6D,#B5,#03,#8E,#00       ;m6[m5...
       DB       #00,#00,#00,#C0,#00,#00,#00,#6C       ;...@...l
       DB       #28,#1C,#70,#00,#00,#01,#F0,#00       ;(.p...p.
       DB       #49,#24,#1B,#0F,#40,#E3,#80,#38       ;I$..@c.8
       DB       #E0,#7D,#24,#83,#FE,#3E,#C0,#51       ;`}$.~>@Q
       DB       #C7,#1C,#0E,#3F,#FF,#60,#07,#02       ;G..?.`..
       DB       #41,#B0,#FE,#8E,#38,#E3,#80,#00       ;A0~.8c..
       DB       #E2,#01,#C7,#F0,#6C,#07,#00,#71       ;b.Gpl..q
       DB       #C0,#FF,#F1,#F8,#1C,#00,#38,#FB       ;@.qx..8{
       DB       #01,#20,#03,#8E,#00,#E0,#01,#C0       ;. ...`.@
       DB       #1C,#0F,#C6,#C0,#4F,#F8,#1C,#70       ;..F@Ox.p
       DB       #3F,#E0,#0E,#07,#00,#0F,#B0,#83       ;?`....0.
       DB       #6D,#80,#E0,#00,#3F,#1C,#0F,#F8       ;m.`.?..x
       DB       #E0,#6D,#00,#DB,#6C,#00,#00,#01       ;`m.[l...
       DB       #C0,#1C,#01,#C0,#3B,#6D,#B6,#DB       ;@..@;m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #FF,#01,#08,#08,#38,#40,#04,#20       ;....8@. 
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#BB,#6D,#B0,#00,#00,#00,#00       ;6;m0....
       DB       #00,#49,#24,#9C,#28,#00,#6C,#00       ;.I$.(.l.
       DB       #00,#00,#00,#00,#00,#00,#03,#84       ;........
       DB       #80,#1B,#5D,#B1,#27,#6D,#B4,#D2       ;..]1'm4R
       DB       #59,#34,#92,#40,#2E,#D4,#01,#36       ;Y4.@.T.6
       DB       #C0,#00,#00,#14,#00,#00,#02,#8B       ;@.......
       DB       #B5,#00,#00,#00,#01,#00,#00,#00       ;5.......
       DB       #00,#28,#02,#ED,#40,#49,#00,#36       ;.(.m@I.6
       DB       #DB,#41,#40,#02,#82,#00,#BB,#5B       ;[A@...;[
       DB       #B6,#D2,#80,#00,#00,#59,#24,#BB       ;6R...Y$;
       DB       #6D,#AE,#D4,#00,#00,#A0,#40,#00       ;m.T.. @.
       DB       #00,#00,#00,#00,#0B,#B0,#00,#02       ;.....0..
       DB       #28,#02,#EB,#86,#1A,#4A,#00,#02       ;(.k..J..
       DB       #EC,#00,#02,#1A,#40,#A2,#80,#00       ;l...@"..
       DB       #02,#80,#00,#BB,#00,#48,#10,#40       ;...;.H.@
       DB       #28,#A0,#00,#01,#BB,#00,#06,#D6       ;( ..;..V
       DB       #49,#20,#00,#0A,#2E,#9B,#6D,#A8       ;I ....m(
       DB       #00,#09,#B5,#00,#00,#00,#02,#8A       ;..5.....
       DB       #00,#00,#0A,#00,#18,#6D,#41,#00       ;.....mA.
       DB       #00,#08,#A2,#80,#01,#26,#81,#70       ;.."..&.p
       DB       #1B,#5D,#B6,#D4,#0D,#AC,#B3,#49       ;.]6T.,3I
       DB       #B6,#A0,#50,#06,#C0,#00,#05,#40       ;6 P.@..@
       DB       #0A,#28,#09,#61,#A8,#14,#01,#B0       ;.(.a(..0
       DB       #00,#01,#40,#02,#8A,#00,#00,#0A       ;..@.....
       DB       #05,#00,#6C,#48,#58,#50,#00,#A2       ;..lHXP."
       DB       #82,#46,#DB,#01,#41,#1B,#6D,#B6       ;.F[.A.m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#FF,#1B,#28,#88,#0A,#90,#28       ;6..(...(
       DB       #38,#D7,#6D,#B6,#DB,#6D,#B6,#DB       ;8Wm6[m6[
       DB       #6D,#B6,#DB,#6D,#B7,#00,#00,#00       ;m6[m7...
       DB       #00,#00,#00,#00,#00,#00,#00,#6D       ;.......m
       DB       #68,#00,#82,#08,#20,#82,#08,#20       ;h... .. 
       DB       #82,#08,#3B,#5C,#30,#C3,#0C,#30       ;..;\0C.0
       DB       #C3,#0C,#30,#A3,#0C,#2E,#D4,#00       ;C.0#..T.
       DB       #00,#00,#00,#00,#00,#00,#28,#00       ;......(.
       DB       #0B,#B5,#04,#10,#41,#04,#10,#41       ;.5..A..A
       DB       #04,#10,#41,#06,#ED,#46,#18,#61       ;..A.mF.a
       DB       #46,#18,#61,#86,#18,#61,#86,#BB       ;F.a..a.;
       DB       #50,#00,#00,#50,#00,#00,#00,#00       ;P..P....
       DB       #00,#00,#2E,#D4,#82,#08,#20,#82       ;...T.. .
       DB       #08,#20,#82,#08,#20,#8B,#B5,#C3       ;. .. .5C
       DB       #0C,#30,#C3,#0C,#30,#C2,#8C,#30       ;.0C.0B.0
       DB       #C2,#ED,#40,#00,#00,#00,#00,#00       ;Bm@.....
       DB       #00,#A0,#00,#00,#BB,#50,#41,#04       ;. ..;PA.
       DB       #10,#41,#04,#10,#41,#04,#10,#6E       ;.A..A..n
       DB       #D4,#61,#46,#18,#61,#86,#18,#61       ;TaF.a..a
       DB       #86,#18,#6B,#B5,#00,#50,#00,#00       ;..k5.P..
       DB       #00,#00,#00,#00,#00,#02,#ED,#48       ;......mH
       DB       #20,#82,#08,#20,#82,#08,#20,#82       ; .. .. .
       DB       #08,#BB,#5C,#30,#C3,#0C,#28,#C3       ;.;\0C.(C
       DB       #0C,#30,#C3,#0C,#2E,#D4,#00,#00       ;.0C..T..
       DB       #00,#0A,#00       ;...
L_A749       DB       #00       ;.
L_A74A       DB       #00,#00,#00,#0B,#B1,#04,#10,#41       ;....1..A
       DB       #04,#10,#41,#04,#10,#41,#04,#6D       ;..A..A.m
       DB       #86,#18,#61,#86,#18,#61,#86,#18       ;..a..a..
       DB       #61,#86,#1B,#6D,#B6,#DB,#6D,#B6       ;a..m6[m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#FF,#40       ;[m6[m6.@
       DB       #08,#90,#08,#18,#30,#98,#DA,#ED       ;....0.Zm
       DB       #B6,#DB,#6D,#B6,#BB,#6D,#B6,#DB       ;6[m6;m6[
       DB       #6D,#B5,#B8,#08,#F4,#00,#0D,#6E       ;m58.t..n
       DB       #02,#67,#00,#03,#5D,#7E,#13,#5A       ;.g..]~.Z
       DB       #E0,#23,#5E,#C4,#D6,#E8,#08,#D7       ;`#^DVh.W
       DB       #6C,#26,#B6,#DD,#01,#6D,#89,#AD       ;l&6].m.-
       DB       #B7,#40,#76,#C0,#4D,#69,#36,#E8       ;7@v@Mi6h
       DB       #30,#13,#5A,#4D,#BA,#0C,#30,#9A       ;0.ZM:.0.
       DB       #D2,#49,#B7,#4C,#23,#B4,#92,#6D       ;RI7L#4.m
       DB       #D3,#0D,#36,#DB,#13,#B6,#DB,#4D       ;S.6[.6[M
       DB       #B6,#C4,#B7,#B6,#D3,#40,#00,#D6       ;6D76S@.V
       DB       #E0,#40,#70,#00,#35,#B8,#10,#34       ;`@p.58.4
       DB       #DB,#00,#1E,#6E,#49,#36,#60,#06       ;[..nI6`.
       DB       #F6,#92,#4D,#B6,#B9,#E6,#F6,#DB       ;v.M69fv[
       DB       #3D,#AE,#DB,#3D,#B6,#DB,#6D,#6E       ;=.[=6[mn
       DB       #02,#3D,#00,#03,#5A,#C0,#9B,#40       ;.=..Z@.@
       DB       #00,#D7,#5F,#84,#D6,#E8,#08,#D7       ;.W_.Vh.W
       DB       #B1,#35,#BA,#02,#35,#DB,#09,#AD       ;15:.5[.-
       DB       #B7,#40,#76,#C2,#6B,#6D,#70,#17       ;7@vBkmp.
       DB       #B0,#13,#5A,#4D,#BA,#0C,#04,#76       ;0.ZM:..v
       DB       #93,#6E,#83,#0C,#26,#B4,#92,#6D       ;.n..&4.m
       DB       #73,#09,#AD,#24,#9B,#74,#C3,#4D       ;s.-$.tCM
       DB       #B6,#C4,#ED,#9E,#D3,#6D,#B1,#3B       ;6Dm.Sm1;
       DB       #6D,#B4,#D0,#00,#35,#B8,#10,#34       ;m4P.58.4
       DB       #00,#0D,#6B,#04,#0D,#36,#C0,#06       ;..k..6@.
       DB       #DB,#92,#4C,#F0,#03,#66,#E4,#91       ;[.Lp.fd.
       DB       #ED,#AE,#DB,#37,#B6,#DB,#6B,#B6       ;m.[76[k6
       DB       #CD,#ED,#B6,#DB,#5B,#80,#9B,#40       ;Mm6[[..@
       DB       #00,#D6,#E0,#26,#D0,#00,#35,#FF       ;.V`&P.5.
       DB       #2C,#30,#58,#26,#90,#20,#88,#DB       ;,0X&. .[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #DB,#6B,#B5,#00,#00,#00,#00,#00       ;[k5.....
       DB       #00,#00,#00,#00,#1A,#ED,#70,#00       ;.....mp.
       DB       #02,#48,#00,#92,#49,#24,#00,#06       ;.H..I$..
       DB       #BB,#5D,#B5,#1B,#5D,#85,#92,#49       ;;]5.]..I
       DB       #24,#B2,#4B,#AE,#D7,#01,#40,#14       ;$2K.W.@.
       DB       #01,#40,#00,#00,#28,#26,#EB,#B5       ;.@..(&k5
       DB       #C0,#50,#05,#00,#00,#00,#00,#00       ;@P......
       DB       #36,#BA,#ED,#70,#14,#01,#60,#96       ;6:mp..`.
       DB       #40,#00,#00,#00,#2E,#BB,#5C,#00       ;@....;\.
       DB       #00,#00,#00,#00,#12,#01,#20,#9B       ;...... .
       DB       #AE,#D7,#4D,#76,#1B,#6D,#64,#04       ;.WMv.md.
       DB       #80,#48,#92,#EB,#B5,#60,#50,#00       ;.H.k5`P.
       DB       #00,#50,#01,#20,#12,#00,#BA,#ED       ;.P. ..:m
       DB       #70,#14,#00,#00,#14,#00,#48,#04       ;p.....H.
       DB       #80,#2E,#BB,#5C,#00,#00,#00,#05       ;..;\....
       DB       #DB,#6C,#F3,#DB,#6B,#AE,#D7,#5D       ;[ls[k.W]
       DB       #B6,#A0,#01,#40,#00,#00,#00,#02       ;6 .@....
       DB       #EB,#B5,#D4,#00,#29,#24,#D0,#00       ;k5T.)$P.
       DB       #00,#00,#00,#BA,#ED,#75,#00,#0B       ;...:mu..
       DB       #B6,#D7,#0C,#36,#D4,#61,#AE,#BB       ;6W.6Ta.;
       DB       #5D,#40,#02,#80,#05,#00,#00,#05       ;]@......
       DB       #00,#0B,#AE,#D7,#52,#48,#00,#00       ;...WRH..
       DB       #00,#00,#01,#49,#26,#EB,#B5,#DA       ;...I&k5Z
       DB       #49,#64,#92,#5B,#24,#92,#59,#24       ;Id.[$.Y$
       DB       #DA,#ED,#40,#00,#50,#00,#00,#00       ;Zm@.P...
       DB       #00,#14,#00,#38,#BB,#6D,#B6,#DB       ;...8;m6[
       DB       #6D,#B6,#DB,#6D,#B6,#DB,#6D,#B6       ;m6[m6[m6
       DB       #FF,#20,#1A,#90,#12,#98,#26,#98       ;. ....&.
       DB       #C3,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;Cm6[m6[m
       DB       #B6,#DB,#6D,#B0,#1C,#1C,#49,#24       ;6[m0..I$
       DB       #97,#B6,#D9,#92,#49,#24,#ED,#B6       ;.6Y.I$m6
       DB       #D7,#6D,#76,#C4,#92,#49,#27,#6D       ;WmvD.I'm
       DB       #B6,#7B,#62,#49,#C4,#D2,#76,#D7       ;6{bIDRvW
       DB       #6D,#B6,#64,#92,#5E,#DA,#ED,#B5       ;m6d.^Zm5
       DB       #DB,#6C,#71,#24,#82,#49,#DB,#57       ;[lq$.I[W
       DB       #B6,#B8,#93,#71,#24,#DD,#B6,#DB       ;68.q$]6[
       DB       #6D,#76,#D5,#ED,#A9,#3B,#3D,#B6       ;mvUm);=6
       DB       #C4,#92,#49,#2D,#DD,#49,#7B,#6D       ;D.I-]I{m
       DB       #AE,#2F,#12,#4D,#DB,#6D,#AE,#C7       ;./.M[m.G
       DB       #5D,#9E,#C4,#9B,#AE,#D7,#6D,#B1       ;].D..Wm1
       DB       #24,#EB,#B6,#D7,#67,#B4,#DB,#6A       ;$k6Wg4[j
       DB       #4D,#C7,#02,#76,#BA,#E2,#49,#25       ;MG.v:bI%
       DB       #ED,#36,#24,#EC,#75,#DB,#6D,#AE       ;m6$lu[m.
       DB       #BB,#6D,#75,#7B,#4C,#4E,#DB,#6C       ;;mu{LN[l
       DB       #49,#C4,#9B,#A9,#27,#5D,#5E,#D3       ;ID.)']^S
       DB       #5D,#89,#3B,#6D,#75,#DB,#63,#B1       ;].;mu[c1
       DB       #C7,#57,#B4,#D7,#13,#B6,#DB,#5D       ;GW4W.6[]
       DB       #76,#DB,#6D,#76,#D5,#ED,#35,#D7       ;v[mvUm5W
       DB       #6C,#49,#27,#52,#49,#3B,#12,#4D       ;lI'RI;.M
       DB       #7B,#4C,#4D,#DB,#5D,#B6,#DB,#6D       ;{LM[]6[m
       DB       #AB,#7B,#5D,#9E,#D3,#6D,#71,#27       ;+{].Smq'
       DB       #62,#49,#24,#93,#99,#C4,#93,#B4       ;bI$..D.4
       DB       #24,#DD,#75,#24,#ED,#B6,#DB,#6D       ;$]u$m6[m
       DB       #76,#DA,#ED,#B6,#C4,#DD,#B6,#D8       ;vZm6D]6X
       DB       #92,#49,#24,#D2,#49,#3B,#6D,#B6       ;.I$RI;m6
       DB       #DB,#6D,#B6,#DB,#6D,#B6,#DB,#6D       ;[m6[m6[m
       DB       #B6,#FF,#5A,#1A,#48,#26,#28,#08       ;6.Z.H&(.
       DB       #10,#DB,#6D,#B6,#BB,#6D,#B6,#DB       ;.[m6;m6[
       DB       #6D,#B6,#DB,#6D,#B0,#00,#00,#28       ;m6[m0..(
       DB       #E0,#00,#00,#00,#00,#00,#00,#6C       ;`......l
       DB       #40,#00,#09,#24,#80,#80,#40,#82       ;@..$..@.
       DB       #48,#00,#3B,#40,#01,#00,#80,#00       ;H.;@....
       DB       #80,#41,#40,#02,#82,#26,#C2,#09       ;.A@..&B.
       DB       #24,#90,#01,#04,#00,#51,#20,#22       ;$....Q "
       DB       #01,#B1,#12,#10,#00,#22,#02,#28       ;.1...".(
       DB       #02,#00,#24,#82,#ED,#40,#10,#89       ;..$.m@..
       DB       #24,#02,#0A,#00,#00,#00,#00,#BB       ;$......;
       DB       #50,#00,#84,#00,#04,#02,#80,#24       ;P......$
       DB       #04,#90,#2E,#D4,#02,#04,#00,#08       ;...T....
       DB       #00,#02,#80,#24,#92,#01,#B5,#02       ;...$..5.
       DB       #48,#05,#10,#40,#44,#A0,#92,#49       ;H..@D .I
       DB       #02,#ED,#41,#00,#01,#44,#92,#49       ;.mA..D.I
       DB       #2C,#92,#49,#20,#1B,#51,#20,#20       ;,.I .Q  
       DB       #50,#00,#00,#0A,#00,#00,#00,#2E       ;P.......
       DB       #C0,#01,#24,#14,#01,#24,#80,#12       ;@.$..$..
       DB       #44,#90,#0B,#B5,#90,#00,#05,#90       ;D..5....
       DB       #02,#40,#92,#49,#01,#00,#6D,#40       ;.@.I..m@
       DB       #22,#49,#00,#12,#48,#00,#A0,#01       ;"I..H. .
       DB       #40,#BB,#50,#20,#00,#01,#20,#00       ;@;P .. .
       DB       #00,#00,#90,#00,#2E,#C0,#51,#01       ;.....@Q.
       DB       #02,#80,#24,#80,#00,#00,#90,#91       ;..$.....
       DB       #B0,#14,#09,#20,#02,#40,#04,#80       ;0.. .@..
       DB       #0A,#04,#92,#EC,#85,#00,#50,#00       ;...l..P.
       DB       #00,#0A,#00,#90,#00,#00,#BB,#6D       ;......;m
       DB       #B6,#DB,#6D,#B6,#DB,#6D,#B6,#DB       ;6[m6[m6[
       DB       #6D,#B6,#FF,#1E,#34,#90,#08,#20       ;m6..4.. 
       DB       #28,#10,#C0,#60,#30,#00,#00,#00       ;(.@`0...
       DB       #00,#01,#B6,#18,#0D,#80,#C0,#60       ;..6...@`
       DB       #36,#DB,#6D,#36,#DB,#01,#B8,#C0       ;6[m6[.8@
       DB       #61,#80,#C0,#60,#00,#04,#92,#00       ;a.@`....
       DB       #18,#0C,#06,#03,#01,#80,#C0,#6D       ;......@m
       DB       #B6,#D3,#6D,#80,#C0,#60,#30,#03       ;6Sm.@`0.
       DB       #01,#80,#C0,#00,#49,#20,#0C,#06       ;..@.I ..
       DB       #03,#0D,#06,#03,#01,#80,#DB,#6D       ;......[m
       DB       #B6,#C0,#60,#30,#D3,#49,#86,#03       ;6@`0SI..
       DB       #01,#80,#04,#92,#06,#03,#0D,#34       ;.......4
       DB       #D2,#69,#86,#03,#01,#B6,#DB,#60       ;Ri...6[`
       DB       #30,#D3,#4D,#34,#9A,#69,#86,#03       ;0SM4.i..
       DB       #00,#49,#23,#0D,#34,#D3,#4D,#26       ;.I#.4SM&
       DB       #9A,#69,#86,#03,#6B,#76,#13,#4D       ;.i..kv.M
       DB       #34,#D3,#49,#A6,#9A,#69,#86,#04       ;4SI&.i..
       DB       #92,#06,#13,#4D,#34,#D2,#69,#A6       ;...M4Ri&
       DB       #9A,#68,#36,#D3,#6C,#06,#13,#4D       ;.h6Sl..M
       DB       #34,#9A,#69,#A6,#83,#00,#49,#20       ;4.i&..I 
       DB       #0C,#06,#13,#4D,#26,#9A,#68,#30       ;...M&.h0
       DB       #1B,#6D,#36,#D8,#0C,#06,#13,#49       ;.m6X...I
       DB       #A6,#83,#01,#80,#04,#92,#00,#18       ;&.......
       DB       #0C,#06,#12,#68,#30,#18,#0D,#B6       ;...h0..6
       DB       #D3,#6D,#B0,#18,#0C,#06,#83,#01       ;Sm0.....
       DB       #80,#C0,#00,#49,#20,#00,#30,#18       ;.@.I .0.
       DB       #0C,#30,#18,#0C,#06,#DB,#6D,#B6       ;.0...[m6
       DB       #DB,#60,#30,#18,#01,#80,#C0,#60       ;[`0...@`
       DB       #00,#04,#92,#00,#00,#60,#30,#18       ;.....`0.
       DB       #0C,#06,#03,#6D,#B6,#DB,#6D,#B6       ;...m6[m6
       DB       #C0,#60,#36,#FF,#24,#2A,#08,#18       ;@`6.$*..
       DB       #58,#22,#48       ;X"H
;
L_AC05 DB       "abbbbbbbbbbc",#00
       DB       "h1 CONTINUEd",#00
       DB       "h          d",#00
       DB       "h2 ABORT   d",#00
       DB       "h          d",#00
       DB       "h3 EXIT    d",#00
       DB       "gffffffffffe",#00
;
L_AC60       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A       ;........
       DB       #0A,#0A,#0A,#0A,#0A,#0F,#0F,#0D       ;........
       DB       #0D,#0D,#0D,#0D,#0D,#0D,#0D,#0A       ;........
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A       ;........
       DB       #0A,#0A,#0A,#0A,#0A,#0F,#0F,#0D       ;........
       DB       #0D,#0D,#0D,#0D,#0D,#0D,#0D,#0A       ;........
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A       ;........
       DB       #0A,#0A,#0A,#0A,#0A,#0F,#0F,#0D       ;........
       DB       #0D,#0D,#0D,#0D,#0D,#0D,#0D,#0A       ;........
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A       ;........
       DB       #0A,#0A,#0A,#0A       ;....
L_ACB4       DB       #FF,#00,#04,#01,#00,#00,#05,#02       ;........
       DB       #00,#00,#03,#00,#00,#00,#01,#01       ;........
       DB       #00,#00,#02,#02,#01,#00,#00,#00       ;........
       DB       #00,#00,#07,#01,#00,#02,#06,#02       ;........
       DB       #00,#00,#06,#03,#00,#02,#07,#00       ;........
       DB       #00,#00,#06,#01,#00,#FE,#07,#02       ;.....~..
       DB       #00,#00,#07,#03,#00,#FE,#06,#00       ;.....~..
       DB       #00,#02,#FF,#01,#00,#02,#FF,#00       ;........
       DB       #00,#FE,#FF,#01,#00,#FE,#FF,#02       ;.~...~..
       DB       #00,#FE,#FF,#03,#00,#FF,#FF,#04       ;.~......
       DB       #00,#FF,#FF,#05,#00,#00,#FF,#00       ;........
       DB       #00,#00,#FF,#01,#00,#01,#FF,#02       ;........
       DB       #00,#01,#FF,#03,#00,#02,#FF,#00       ;........
       DB       #FF,#FE,#04,#01,#00,#FE,#05,#02       ;.~...~..
       DB       #00,#FE,#03,#00,#FF,#FF,#04,#01       ;.~......
       DB       #00,#FF,#05,#02,#00,#00,#03,#00       ;........
       DB       #FF,#00,#04,#01,#00,#01,#05,#02       ;........
       DB       #00,#01,#03,#00,#FF,#02,#04,#01       ;........
       DB       #00,#02,#05,#02,#00,#02,#03,#00       ;........
       DB       #00,#FE,#01,#01,#00,#FE,#02,#02       ;.~...~..
       DB       #01,#FE,#00,#00,#00,#FF,#01,#01       ;.~......
       DB       #00,#FF,#02,#02,#01,#00,#00,#00       ;........
       DB       #00,#00,#01,#01,#00,#01,#02,#02       ;........
       DB       #01,#01,#00,#00,#00,#02,#01,#01       ;........
       DB       #00,#02,#02,#02,#01,#02,#00,#00       ;........
MontanaJones2_logo
       DB       #1F,#80,#03,#F0,#00,#00,#00,#08       ;...p....
       DB       #00,#00,#00,#00,#00,#00,#01,#FE       ;.......~
       DB       #00,#00,#00,#00,#00,#00,#00,#07       ;........
       DB       #FB,#FC,#07,#80,#03,#C0,#00,#00       ;{|...@..
       DB       #00,#08,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#78,#00,#00,#00,#00,#00,#00       ;.x......
       DB       #00,#01,#E0,#F0,#07,#C0,#07,#C0       ;..`p.@.@
       DB       #00,#00,#00,#18,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#78,#00,#00,#00,#00       ;...x....
       DB       #00,#00,#00,#01,#E0,#F0,#07,#C0       ;....`p.@
       DB       #07,#C0,#00,#00,#00,#18,#00,#00       ;.@......
       DB       #00,#00,#00,#00,#00,#78,#00,#00       ;.....x..
       DB       #00,#00,#00,#00,#00,#01,#E0,#F0       ;......`p
       DB       #07,#E0,#0F,#C0,#00,#00,#00,#38       ;.`.@...8
       DB       #00,#00,#00,#00,#00,#00,#00,#78       ;.......x
       DB       #00,#00,#00,#00,#00,#00,#00,#01       ;........
       DB       #E0,#F0,#07,#E0,#0F,#C0,#78,#02       ;`p.`.@x.
       DB       #70,#FE,#07,#E0,#13,#80,#7E,#00       ;p~.`..~.
       DB       #00,#78,#0F,#00,#4E,#00,#F0,#07       ;.x..N.p.
       DB       #E0,#01,#E0,#F0,#06,#F0,#1B,#C0       ;`.`p.p.@
       DB       #CC,#0E,#F8,#38,#0E,#70,#77,#C0       ;L.x8.pw@
       DB       #E7,#00,#00,#78,#19,#81,#DF,#01       ;g..x.._.
       DB       #98,#0E,#78,#01,#E0,#F0,#06,#F0       ;..x.`p.p
       DB       #1B,#C1,#86,#1F,#3C,#38,#1C,#38       ;.A..<8.8
       DB       #F9,#E1,#C3,#80,#00,#78,#30,#C3       ;yaC..x0C
       DB       #E7,#83,#0C,#1C,#38,#01,#E0,#F0       ;g...8.`p
       DB       #06,#78,#33,#C1,#86,#0E,#1C,#38       ;.x3A...8
       DB       #1C,#38,#70,#E1,#C3,#80,#00,#78       ;.8paC..x
       DB       #30,#C1,#C3,#83,#0C,#1C,#18,#01       ;0AC.....
       DB       #E0,#F0,#06,#78,#33,#C3,#87,#0E       ;`p.x3C..
       DB       #1C,#38,#08,#38,#70,#E0,#83,#80       ;.8.8p`..
       DB       #00,#78,#70,#E1,#C3,#87,#0E,#1C       ;.xpaC...
       DB       #08,#01,#E0,#F0,#06,#3C,#63,#C3       ;..`p.<cC
       DB       #87,#0E,#1C,#38,#00,#F8,#70,#E0       ;...8.xp`
       DB       #0F,#80,#00,#78,#70,#E1,#C3,#87       ;...xpaC.
       DB       #0E,#1E,#00,#01,#E0,#F0,#06,#3C       ;....`p.<
       DB       #63,#C3,#87,#0E,#1C,#38,#03,#38       ;cC...8.8
       DB       #70,#E0,#33,#80,#00,#78,#70,#E1       ;p`3..xpa
       DB       #C3,#87,#0E,#0F,#80,#01,#E0,#F0       ;C.....`p
       DB       #06,#1E,#C3,#C3,#87,#0E,#1C,#38       ;..CC...8
       DB       #0E,#38,#70,#E0,#E3,#80,#00,#78       ;.8p`c..x
       DB       #70,#E1,#C3,#87,#FE,#07,#E0,#01       ;paC.~.`.
       DB       #E0,#F0,#06,#1E,#C3,#C3,#87,#0E       ;`p..CC..
       DB       #1C,#38,#1C,#38,#70,#E1,#C3,#80       ;.8.8paC.
       DB       #00,#78,#70,#E1,#C3,#87,#00,#01       ;.xpaC...
       DB       #F0,#01,#E0,#F0,#06,#0F,#83,#C3       ;p.`p...C
       DB       #87,#0E,#1C,#38,#1C,#38,#70,#E1       ;...8.8pa
       DB       #C3,#80,#0C,#78,#70,#E1,#C3,#87       ;C..xpaC.
       DB       #00,#00,#78,#01,#E0,#F0,#06,#0F       ;..x.`p..
       DB       #83,#C3,#87,#0E,#1C,#38,#1C,#38       ;.C...8.8
       DB       #70,#E1,#C3,#80,#1E,#78,#70,#E1       ;paC..xpa
       DB       #C3,#87,#02,#10,#38,#01,#E0,#F0       ;C...8.`p
       DB       #06,#07,#03,#C1,#86,#0E,#1C,#38       ;...A...8
       DB       #1C,#38,#70,#E1,#C3,#80,#1E,#70       ;.8paC..p
       DB       #30,#C1,#C3,#83,#84,#18,#38,#01       ;0AC...8.
       DB       #E0,#F0,#06,#07,#03,#C1,#86,#0E       ;`p...A..
       DB       #1C,#3C,#9E,#78,#70,#E1,#E7,#80       ;.<.xpag.
       DB       #1E,#70,#30,#C1,#C3,#83,#9C,#1C       ;.p0AC...
       DB       #38,#01,#E0,#F0,#06,#02,#03,#C0       ;8.`p...@
       DB       #CC,#0E,#1C,#1F,#0F,#BC,#70,#E0       ;L....<p`
       DB       #FB,#C0,#0C,#E0,#19,#81,#C3,#81       ;{@.`..C.
       DB       #F8,#1E,#70,#01,#E0,#F0,#1F,#82       ;x.p.`p..
       DB       #0F,#F0,#78,#1F,#3E,#0E,#07,#18       ;.px.>...
       DB       #F9,#F0,#71,#80,#07,#C0,#0F,#03       ;ypq..@..
       DB       #E7,#C0,#F0,#07,#E0,#07,#FB,#FC       ;g@p.`.{|

;Font

tileset
       DB       #4A,#4A,#00,#00,#20,#00,#00,#00       ;JJ.. ...
       DB       #A4,#A4,#00,#00,#02,#02,#00,#00       ;$$......
       DB       #92,#92,#00,#00,#08,#00,#00,#00       ;........
       DB       #29,#29,#00,#00,#00,#20,#00,#00       ;))... ..
       DB       #05,#05,#05,#05,#4A,#4A,#00,#00       ;....JJ..
       DB       #20,#00,#00,#00,#A4,#A4,#00,#00       ; ...$$..
       DB       #00,#02,#07,#E0,#8F,#F2,#1F,#F8       ;...`.r.x
       DB       #00,#00,#1E,#78,#17,#E9,#10,#08       ;...x.i..
       DB       #17,#E8,#1F,#F8,#05,#05,#05,#05       ;.h.x....
       DB       #0C,#04,#58,#18,#C3,#69,#8A,#71       ;..X.Ci.q
       DB       #1E,#BC,#5D,#B1,#7C,#F4,#FF,#FF       ;.<]1|t..
       DB       #20,#46,#44,#04,#0D,#11,#39,#60       ; FD...9`
       DB       #7B,#44,#73,#D5,#F6,#B7,#FF,#FF       ;{DsUv7..
       DB       #02,#02,#16,#16,#C3,#BD,#B7,#FF       ;....C=7.
       DB       #E2,#F9,#E5,#77,#D3,#FF,#C6,#F7       ;byewS.Fw
       DB       #A5,#EE,#00,#00,#6E,#D1,#FF,#B6       ;%n..nQ.6
       DB       #C7,#D3,#FF,#E5,#FC,#D3,#FE,#17       ;GS.e|S~.
       DB       #69,#A3,#00,#00,#0F,#0F,#0F,#0F       ;i#......
       DB       #FF,#FF,#DE,#DE,#63,#63,#63,#63       ;..^^cccc
       DB       #26,#26,#1C,#1C,#F3,#F3,#C1,#C1       ;&&..ssAA
       DB       #00,#00,#00,#00,#08,#00,#00,#00       ;........
       DB       #29,#29,#00,#00,#00,#20,#00,#00       ;))... ..
       DB       #04,#04,#05,#05,#9F,#F9,#60,#06       ;.....y`.
       DB       #60,#06,#60,#06,#9F,#F9,#60,#06       ;`.`..y`.
       DB       #60,#06,#60,#06,#9F,#F9,#60,#06       ;`.`..y`.
       DB       #60,#06,#60,#06,#9F,#F9,#60,#06       ;`.`..y`.
       DB       #60,#06,#60,#06,#06,#06,#06,#06       ;`.`.....
       DB       #C3,#BD,#B7,#FF,#E2,#F9,#E5,#77       ;C=7.byew
       DB       #D3,#FF,#C6,#F7,#A5,#EE,#00,#00       ;S.Fw%n..
       DB       #6E,#D1,#FF,#B6,#C7,#D3,#FF,#E5       ;nQ.6GS.e
       DB       #FC,#D3,#FE,#17,#69,#A3,#00,#00       ;|S~.i#..
       DB       #0F,#0F,#0F,#0F,#3F,#F8,#23,#C2       ;....?x#B
       DB       #27,#E2,#2F,#F2,#BF,#F8,#33,#FC       ;'b/r?x3|
       DB       #21,#FC,#21,#FC,#B3,#FC,#33,#FC       ;!|!|3|3|
       DB       #33,#FC,#3F,#F8,#2F,#F2,#27,#E2       ;3|?x/r'b
       DB       #23,#C2,#3F,#F8,#07,#07,#07,#07       ;#B?x....
       DB       #0C,#04,#58,#18,#C3,#69,#8A,#71       ;..X.Ci.q
       DB       #1E,#BC,#5D,#B1,#7C,#F4,#FF,#FF       ;.<]1|t..
       DB       #20,#46,#44,#04,#0D,#11,#39,#60       ; FD...9`
       DB       #7B,#44,#73,#D5,#F6,#B7,#FF,#FF       ;{DsUv7..
       DB       #02,#02,#16,#16,#24,#04,#60,#81       ;....$.`.
       DB       #4B,#59,#1A,#50,#76,#F4,#67,#BF       ;KY.Pvtg?
       DB       #7F,#9F,#FF,#FF,#22,#11,#46,#94       ;....".F.
       DB       #44,#60,#D9,#C9,#B7,#CA,#7B,#5B       ;D`YI7J{[
       DB       #DF,#F7,#FF,#FF,#02,#02,#16,#16       ;_w......
       DB       #00,#C1,#19,#00,#90,#48,#BA,#82       ;.A...H:.
       DB       #3E,#B6,#1F,#6F,#96,#C3,#FF,#FF       ;>6.o.C..
       DB       #08,#60,#40,#C4,#48,#8D,#12,#A0       ;.`@DH.. 
       DB       #7B,#C4,#F7,#55,#E6,#B7,#FF,#FF       ;{DwUf7..
       DB       #02,#02,#16,#16
       ;display $-tileset ;11 tiles of 36 bytes
MJ_sprites
	db #FF,#FC,#3F,#FF       ;.....|?.
       DB       #E0,#07,#FF,#C0,#03,#FF,#80,#01       ;`..@....
       DB       #FF,#80,#03,#FF,#C0,#07,#FF,#80       ;....@...
       DB       #03,#FF,#00,#03,#FF,#00,#01,#FF       ;........
       DB       #80,#00,#FF,#C0,#00,#FF,#E0,#01       ;...@..`.
       DB       #FF,#E0,#07,#FF,#C1,#83,#FF,#C3       ;.`..A..C
       DB       #C3,#FF,#C1,#C1,#00,#00,#00,#00       ;C.AA....
       DB       #03,#C0,#00,#1F,#F8,#00,#3F,#FC       ;.@..x.?|
       DB       #00,#00,#00,#00,#1E,#A0,#00,#22       ;..... ."
       DB       #08,#00,#4F,#B8,#00,#4F,#E4,#00       ;..O8.Od.
       DB       #27,#F2,#00,#1F,#EE,#00,#07,#E0       ;'r..n..`
       DB       #00,#0E,#70,#00,#1C,#38,#00,#18       ;..p..8..
       DB       #18,#00,#1C,#1C,#FF,#87,#FF,#FC       ;.......|
       DB       #00,#FF,#F8,#00,#7F,#F0,#00,#3F       ;..x..p.?
       DB       #F8,#00,#7F,#FC,#00,#FF,#F8,#00       ;x..|..x.
       DB       #7F,#F0,#00,#7F,#F0,#00,#7F,#F8       ;.p..p..x
       DB       #00,#3F,#FC,#00,#3F,#FE,#00,#7F       ;.?|.?~..
       DB       #FE,#03,#FF,#FE,#03,#FF,#FF,#03       ;~..~....
       DB       #FF,#FF,#C1,#FF,#00,#00,#00,#00       ;..A.....
       DB       #78,#00,#03,#FF,#00,#07,#FF,#80       ;x.......
       DB       #00,#00,#00,#01,#D4,#00,#02,#41       ;....T..A
       DB       #00,#04,#F7,#00,#04,#FD,#00,#02       ;..w..}..
       DB       #3C,#80,#01,#FF,#80,#00,#FC,#00       ;<.....|.
       DB       #00,#D8,#00,#00,#F8,#00,#00,#18       ;.X..x...
       DB       #00,#00,#1C,#00,#FF,#E1,#FF,#FF       ;.....a..
       DB       #00,#3F,#FE,#00,#1F,#FC,#00,#0F       ;.?~..|..
       DB       #FE,#00,#1F,#FF,#80,#3F,#FF,#00       ;~....?..
       DB       #1F,#FE,#00,#1F,#FE,#00,#3F,#FF       ;.~..~.?.
       DB       #00,#1F,#FF,#80,#1F,#FF,#80,#3F       ;.......?
       DB       #FF,#C0,#7F,#FF,#C0,#3F,#FF,#C0       ;.@..@?.@
       DB       #7F,#FF,#C1,#FF,#00,#00,#00,#00       ;..A.....
       DB       #1E,#00,#00,#FF,#C0,#01,#FF,#E0       ;....@..`
       DB       #00,#00,#00,#00,#35,#00,#00,#50       ;....5..P
       DB       #40,#00,#9D,#C0,#00,#8F,#80,#00       ;@..@....
       DB       #47,#40,#00,#3F,#C0,#00,#3F,#00       ;G@.?@.?.
       DB       #00,#1B,#00,#00,#1B,#80,#00,#18       ;........
       DB       #00,#00,#1C,#00,#FC,#3F,#FF,#E0       ;....|?.`
       DB       #07,#FF,#C0,#03,#FF,#80,#01,#FF       ;..@.....
       DB       #C0,#01,#FF,#E0,#03,#FF,#C0,#01       ;@..`..@.
       DB       #FF,#C0,#00,#FF,#80,#00,#FF,#00       ;.@......
       DB       #01,#FF,#00,#03,#FF,#80,#07,#FF       ;........
       DB       #E0,#07,#FF,#C1,#83,#FF,#C3,#C3       ;`..A..CC
       DB       #FF,#83,#83,#FF,#00,#00,#00,#03       ;........
       DB       #C0,#00,#1F,#F8,#00,#3F,#FC,#00       ;@..x.?|.
       DB       #00,#00,#00,#05,#78,#00,#10,#44       ;....x..D
       DB       #00,#1D,#F2,#00,#27,#F2,#00,#4F       ;..r.'r.O
       DB       #E4,#00,#77,#F8,#00,#07,#E0,#00       ;d.wx..`.
       DB       #0E,#70,#00,#1C,#38,#00,#18,#18       ;.p..8...
       DB       #00,#38,#38,#00,#FF,#E1,#FF,#FF       ;.88..a..
       DB       #00,#3F,#FE,#00,#1F,#FC,#00,#0F       ;.?~..|..
       DB       #FE,#00,#1F,#FF,#00,#3F,#FE,#00       ;~....?~.
       DB       #1F,#FE,#00,#0F,#FE,#00,#0F,#FC       ;.~..~..|
       DB       #00,#1F,#FC,#00,#3F,#FE,#00,#7F       ;..|.?~..
       DB       #FF,#C0,#7F,#FF,#C0,#7F,#FF,#C0       ;.@..@..@
       DB       #FF,#FF,#83,#FF,#00,#00,#00,#00       ;........
       DB       #1E,#00,#00,#FF,#C0,#01,#FF,#E0       ;....@..`
       DB       #00,#00,#00,#00,#2B,#80,#00,#82       ;....+...
       DB       #40,#00,#EF,#20,#00,#BF,#20,#01       ;@.o .? .
       DB       #3C,#40,#01,#FF,#80,#00,#3F,#00       ;<@....?.
       DB       #00,#1B,#00,#00,#1F,#00,#00,#18       ;........
       DB       #00,#00,#38,#00,#FF,#87,#FF,#FC       ;..8....|
       DB       #00,#FF,#F8,#00,#7F,#F0,#00,#3F       ;..x..p.?
       DB       #F8,#00,#7F,#FC,#01,#FF,#F8,#00       ;x..|..x.
       DB       #FF,#F8,#00,#7F,#FC,#00,#7F,#F8       ;.x..|..x
       DB       #00,#FF,#F8,#01,#FF,#FC,#01,#FF       ;..x..|..
       DB       #FE,#03,#FF,#FC,#03,#FF,#FE,#03       ;~..|..~.
       DB       #FF,#FF,#83,#FF,#00,#00,#00,#00       ;........
       DB       #78,#00,#03,#FF,#00,#07,#FF,#80       ;x.......
       DB       #00,#00,#00,#00,#AC,#00,#02,#0A       ;....,...
       DB       #00,#03,#B9,#00,#01,#F1,#00,#02       ;..9..q..
       DB       #E2,#00,#03,#FC,#00,#00,#FC,#00       ;b..|..|.
       DB       #00,#D8,#00,#01,#D8,#00,#00,#18       ;.X..X...
       DB       #00,#00,#38,#00,#FC,#30,#FF,#E0       ;..8.|0.`
       DB       #00,#FF,#C0,#00,#FF,#80,#01,#FF       ;..@.....
       DB       #00,#00,#FF,#00,#01,#FF,#00,#03       ;........
       DB       #FF,#80,#07,#FF,#C0,#0F,#FF,#E0       ;....@..`
       DB       #0F,#FF,#E0,#0F,#FF,#C0,#0F,#FF       ;..`..@..
       DB       #E3,#07,#FF,#FF,#87,#FF,#FF,#87       ;c.......
       DB       #FF,#FF,#83,#FF,#00,#06,#00,#03       ;........
       DB       #C6,#00,#1B,#DA,#00,#39,#9C,#00       ;F..Z.9..
       DB       #5C,#3A,#00,#67,#E4,#00,#78,#18       ;\:.gd.x.
       DB       #00,#3F,#F0,#00,#07,#E0,#00,#0F       ;.?p..`..
       DB       #E0,#00,#0F,#E0,#00,#1C,#60,#00       ;`..`..`.
       DB       #00,#70,#00,#00,#30,#00,#00,#30       ;.p..0..0
       DB       #00,#00,#38,#00,#0C,#3F,#FF,#00       ;..8..?..
       DB       #07,#FF,#00,#03,#FF,#80,#01,#FF       ;........
       DB       #00,#00,#FF,#80,#00,#FF,#C0,#00       ;......@.
       DB       #FF,#E0,#01,#FF,#F0,#03,#FF,#F0       ;.`..p..p
       DB       #07,#FF,#F0,#07,#FF,#F0,#03,#FF       ;..p..p..
       DB       #E0,#C7,#FF,#E1,#FF,#FF,#E1,#FF       ;`G.a..a.
       DB       #FF,#C1,#FF,#FF,#60,#00,#00,#63       ;.A..`..c
       DB       #C0,#00,#5B,#D8,#00,#39,#9C,#00       ;@.[X.9..
       DB       #5C,#3A,#00,#27,#E6,#00,#18,#1E       ;\:.'f...
       DB       #00,#0F,#FC,#00,#07,#E0,#00,#07       ;..|..`..
       DB       #F0,#00,#07,#F0,#00,#06,#38,#00       ;p..p..8.
       DB       #0E,#00,#00,#0C,#00,#00,#0C,#00       ;........
       DB       #00,#1C,#00,#00,#FC,#3F,#FF,#FB       ;....|?.{
       DB       #DF,#FF,#F7,#EF,#FF,#EF,#F7,#FF       ;_.wo.ow.
       DB       #EF,#F7,#FF,#DF,#FB,#FF,#BF,#FD       ;ow._{.?}
       DB       #FF,#7F,#FE,#FF,#7F,#FE,#FF,#7F       ;..~..~..
       DB       #FE,#FF,#7F,#FE,#FF,#6F,#F6,#FF       ;~..~.ov.
       DB       #8F,#F1,#FF,#EE,#77,#FF,#DE,#7B       ;.q.nw.^{
       DB       #FF,#DD,#BB,#FF,#00,#00,#00,#03       ;.];.....
       DB       #C0,#00,#04,#20,#00,#08,#10,#00       ;@.. ....
       DB       #0A,#50,#00,#10,#08,#00,#20,#04       ;.P.... .
       DB       #00,#40,#02,#00,#48,#12,#00,#48       ;.@..H..H
       DB       #12,#00,#58,#1A,#00,#68,#16,#00       ;..X..h..
       DB       #09,#90,#00,#0A,#50,#00,#12,#48       ;....P..H
       DB       #00,#1C,#38,#00
       ;display $-MJ_sprites ;9 sprites of 96 bytes
Alien1_sprite
	db	#FF,#FC,#3F,#FF       ;..8..|?.
       DB       #F0,#0F,#FF,#E0,#07,#FF,#F0,#0F       ;p..`..p.
       DB       #FF,#E0,#0F,#FF,#C0,#0F,#FF,#80       ;.`..@...
       DB       #07,#FF,#00,#03,#FF,#00,#01,#FF       ;........
       DB       #00,#00,#FF,#00,#00,#FF,#00,#01       ;........
       DB       #FF,#00,#07,#FF,#00,#03,#FF,#80       ;........
       DB       #03,#FF,#C1,#C1,#00,#00,#00,#00       ;..AA....
       DB       #03,#C0,#00,#0F,#F0,#00,#00,#00       ;.@..p...
       DB       #00,#04,#A0,#00,#1E,#00,#00,#23       ;.. ....#
       DB       #B0,#00,#4F,#F8,#00,#4F,#E4,#00       ;0.Ox.Od.
       DB       #47,#F2,#00,#4F,#EE,#00,#4F,#E8       ;Gr.On.Oh
       DB       #00,#4E,#70,#00,#75,#B8,#00,#08       ;.Np.u8..
       DB       #18,#00,#1C,#1C,#FF,#87,#FF,#FE       ;.......~
       DB       #01,#FF,#FC,#00,#FF,#FE,#01,#FF       ;..|..~..
       DB       #FC,#01,#FF,#F8,#01,#FF,#F0,#00       ;|..x..p.
       DB       #FF,#E0,#00,#7F,#E0,#00,#7F,#E0       ;.`..`..`
       DB       #00,#3F,#E0,#00,#3F,#E0,#00,#7F       ;.?`.?`..
       DB       #E0,#00,#7F,#E0,#00,#FF,#F0,#03       ;`..`..p.
       DB       #FF,#FF,#C1,#FF,#00,#00,#00,#00       ;..A.....
       DB       #78,#00,#01,#FE,#00,#00,#00,#00       ;x..~....
       DB       #00,#94,#00,#03,#C0,#00,#04,#76       ;....@..v
       DB       #00,#08,#FF,#00,#08,#FD,#00,#08       ;.....}..
       DB       #3C,#80,#09,#FF,#80,#09,#FD,#00       ;<.....}.
       DB       #09,#DB,#00,#0E,#F8,#00,#00,#18       ;.[..x...
       DB       #00,#00,#1C,#00,#FF,#E1,#FF,#FF       ;.....a..
       DB       #80,#7F,#FF,#00,#3F,#FF,#80,#7F       ;....?...
       DB       #FF,#00,#7F,#FE,#00,#7F,#FC,#00       ;...~..|.
       DB       #3F,#F8,#00,#1F,#F8,#00,#1F,#F8       ;?x..x..x
       DB       #00,#1F,#F8,#00,#1F,#F8,#00,#1F       ;..x..x..
       DB       #F8,#00,#1F,#F8,#00,#3F,#FC,#00       ;x..x.?|.
       DB       #7F,#FF,#C1,#FF,#00,#00,#00,#00       ;..A.....
       DB       #1E,#00,#00,#7F,#80,#00,#00,#00       ;........
       DB       #00,#25,#00,#00,#F0,#00,#01,#1D       ;.%..p...
       DB       #80,#02,#1F,#C0,#02,#0F,#C0,#02       ;...@..@.
       DB       #47,#40,#02,#7F,#C0,#02,#7F,#40       ;G@..@..@
       DB       #02,#7B,#40,#03,#DB,#80,#00,#18       ;.{@.[...
       DB       #00,#00,#1C,#00,#FC,#3F,#FF,#F0       ;....|?.p
       DB       #0F,#FF,#E0,#07,#FF,#F0,#0F,#FF       ;..`..p..
       DB       #F0,#07,#FF,#F0,#03,#FF,#E0,#01       ;p..p..`.
       DB       #FF,#C0,#00,#FF,#80,#00,#FF,#00       ;.@......
       DB       #00,#FF,#00,#00,#FF,#80,#00,#FF       ;........
       DB       #E0,#00,#FF,#C0,#00,#FF,#C0,#01       ;`..@..@.
       DB       #FF,#83,#83,#FF,#00,#00,#00,#03       ;........
       DB       #C0,#00,#0F,#F0,#00,#00,#00,#00       ;@..p....
       DB       #05,#20,#00,#00,#78,#00,#0D,#C4       ;. ..x..D
       DB       #00,#1F,#F2,#00,#27,#F2,#00,#4F       ;..r.'r.O
       DB       #E2,#00,#77,#F2,#00,#17,#F2,#00       ;b.wr..r.
       DB       #0E,#72,#00,#1D,#AE,#00,#18,#10       ;.r......
       DB       #00,#38,#38,#00,#FF,#E1,#FF,#FF       ;.88..a..
       DB       #80,#7F,#FF,#00,#3F,#FF,#80,#7F       ;....?...
       DB       #FF,#80,#3F,#FF,#80,#1F,#FF,#00       ;..?.....
       DB       #0F,#FE,#00,#07,#FE,#00,#07,#FC       ;.~..~..|
       DB       #00,#07,#FC,#00,#07,#FE,#00,#07       ;..|..~..
       DB       #FE,#00,#07,#FF,#00,#07,#FF,#C0       ;~......@
       DB       #0F,#FF,#83,#FF,#00,#00,#00,#00       ;........
       DB       #1E,#00,#00,#7F,#80,#00,#00,#00       ;........
       DB       #00,#29,#00,#00,#03,#C0,#00,#6E       ;.)...@.n
       DB       #20,#00,#FF,#10,#00,#BF,#10,#01       ; ....?..
       DB       #3C,#10,#01,#FF,#90,#00,#BF,#90       ;<.....?.
       DB       #00,#DB,#90,#00,#1F,#70,#00,#18       ;.[...p..
       DB       #00,#00,#38,#00,#FF,#87,#FF,#FE       ;..8....~
       DB       #01,#FF,#FC,#00,#FF,#FE,#01,#FF       ;..|..~..
       DB       #FE,#00,#FF,#FE,#00,#7F,#FC,#00       ;~..~..|.
       DB       #3F,#F8,#00,#1F,#F8,#00,#1F,#F8       ;?x..x..x
       DB       #00,#1F,#F8,#00,#1F,#F8,#00,#1F       ;..x..x..
       DB       #F8,#00,#1F,#FC,#00,#1F,#FE,#00       ;x..|..~.
       DB       #3F,#FF,#83,#FF,#00,#00,#00,#00       ;?.......
       DB       #78,#00,#01,#FE,#00,#00,#00,#00       ;x..~....
       DB       #00,#A4,#00,#00,#0F,#00,#01,#B8       ;.$.....8
       DB       #80,#03,#F8,#40,#03,#F0,#40,#02       ;..x@.p@.
       DB       #E2,#40,#03,#FE,#40,#02,#FE,#40       ;b@.~@.~@
       DB       #02,#DE,#40,#01,#DB,#C0,#00,#18       ;.^@.[@..
       DB       #00,#00,#38,#00,#FC,#00,#FF,#F0       ;..8.|..p
       DB       #00,#FF,#E0,#00,#FF,#80,#00,#FF       ;..`.....
       DB       #00,#00,#FF,#00,#01,#FF,#00,#01       ;........
       DB       #FF,#80,#01,#FF,#80,#01,#FF,#80       ;........
       DB       #03,#FF,#C0,#03,#FF,#C0,#03,#FF       ;..@..@..
       DB       #E0,#07,#FF,#C0,#07,#FF,#E0,#07       ;`..@..`.
       DB       #FF,#FF,#83,#FF,#00,#06,#00,#03       ;........
       DB       #C6,#00,#0B,#D6,#00,#08,#16,#00       ;F..V....
       DB       #67,#EE,#00,#68,#14,#00,#77,#E4       ;gn.h..wd
       DB       #00,#21,#84,#00,#20,#04,#00,#20       ;.!.. .. 
       DB       #08,#00,#10,#08,#00,#10,#08,#00       ;........
       DB       #08,#10,#00,#17,#E0,#00,#00,#10       ;....`...
       DB       #00,#00,#38,#00,#00,#3F,#FF,#00       ;..8..?..
       DB       #0F,#FF,#00,#07,#FF,#00,#01,#FF       ;........
       DB       #00,#00,#FF,#80,#00,#FF,#80,#00       ;........
       DB       #FF,#80,#01,#FF,#80,#01,#FF,#C0       ;.......@
       DB       #01,#FF,#C0,#03,#FF,#C0,#03,#FF       ;..@..@..
       DB       #E0,#07,#FF,#E0,#03,#FF,#E0,#07       ;`..`..`.
       DB       #FF,#C1,#FF,#FF,#60,#00,#00,#63       ;.A..`..c
       DB       #C0,#00,#6B,#D0,#00,#68,#10,#00       ;@.kP.h..
       DB       #77,#E6,#00,#28,#16,#00,#27,#EE       ;wf.(..'n
       DB       #00,#21,#84,#00,#20,#04,#00,#10       ;.!.. ...
       DB       #04,#00,#10,#08,#00,#10,#08,#00       ;........
       DB       #08,#10,#00,#07,#E8,#00,#08,#00       ;....h...
       DB       #00,#1C,#00,#00,#FC,#3F,#FF,#FB       ;....|?.{
       DB       #DF,#FF,#F7,#EF,#FF,#EF,#F7,#FF       ;_.wo.ow.
       DB       #EF,#F7,#FF,#F7,#EF,#FF,#EF,#F7       ;ow.wo.ow
       DB       #FF,#DF,#FB,#FF,#BF,#FD,#FF,#BF       ;._{.?}.?
       DB       #FD,#FF,#BF,#FD,#FF,#BF,#FD,#FF       ;}.?}.?}.
       DB       #BF,#FD,#FF,#CE,#73,#FF,#EE,#77       ;?}.Ns.nw
       DB       #FF,#DE,#7B,#FF,#00,#00,#00,#03       ;.^{.....
       DB       #C0,#00,#04,#20,#00,#0A,#50,#00       ;@.. ..P.
       DB       #08,#10,#00,#04,#20,#00,#08,#10       ;.... ...
       DB       #00,#10,#08,#00,#20,#04,#00,#20       ;.... .. 
       DB       #04,#00,#28,#14,#00,#28,#14,#00       ;..(..(..
       DB       #39,#9C,#00,#0A,#50,#00,#0A,#50       ;9...P..P
       DB       #00,#1E,#78,#00
       ;display $-Alien1_sprite ;9 sprites of 96 bytes
Alien2_sprite
        db #FF,#F8,#1F,#FF       ;..x..x..
       DB       #F0,#0F,#FF,#E0,#07,#FF,#E0,#07       ;p..`..`.
       DB       #FF,#C0,#03,#FF,#80,#01,#FF,#00       ;.@......
       DB       #01,#FF,#00,#01,#FF,#00,#01,#FF       ;........
       DB       #80,#00,#FF,#80,#00,#FF,#C0,#01       ;......@.
       DB       #FF,#E0,#03,#FF,#C1,#83,#FF,#C3       ;.`..A..C
       DB       #C3,#FF,#C1,#C1,#00,#00,#00,#00       ;C.AA....
       DB       #07,#E0,#00,#0F,#10,#00,#0C,#A0       ;.`..... 
       DB       #00,#10,#08,#00,#20,#E4,#00,#44       ;.... d.D
       DB       #14,#00,#48,#14,#00,#48,#14,#00       ;..H..H..
       DB       #24,#22,#00,#27,#F2,#00,#1F,#EC       ;$".'r..l
       DB       #00,#0E,#70,#00,#1C,#38,#00,#18       ;..p..8..
       DB       #18,#00,#1C,#1C,#FF,#03,#FF,#FE       ;.......~
       DB       #01,#FF,#FC,#00,#FF,#FC,#00,#FF       ;..|..|..
       DB       #F8,#00,#7F,#F0,#00,#3F,#F0,#00       ;x..p.?p.
       DB       #3F,#F0,#00,#7F,#F0,#00,#7F,#F8       ;?p..p..x
       DB       #00,#3F,#FC,#00,#3F,#FE,#00,#7F       ;.?|.?~..
       DB       #FE,#00,#FF,#FE,#03,#FF,#FF,#03       ;~..~....
       DB       #FF,#FF,#C1,#FF,#00,#00,#00,#00       ;..A.....
       DB       #FC,#00,#01,#E2,#00,#01,#94,#00       ;|..b....
       DB       #02,#01,#00,#04,#1C,#80,#04,#82       ;........
       DB       #80,#04,#83,#00,#04,#C3,#00,#02       ;.....C..
       DB       #24,#80,#01,#3C,#80,#00,#FB,#00       ;$..<..{.
       DB       #00,#D8,#00,#00,#F8,#00,#00,#18       ;.X..x...
       DB       #00,#00,#1C,#00,#FF,#C0,#FF,#FF       ;.....@..
       DB       #80,#7F,#FF,#00,#3F,#FF,#00,#3F       ;....?..?
       DB       #FF,#00,#1F,#FE,#00,#1F,#FE,#00       ;...~..~.
       DB       #1F,#FE,#00,#1F,#FE,#00,#3F,#FF       ;.~..~.?.
       DB       #00,#1F,#FF,#80,#1F,#FF,#80,#3F       ;.......?
       DB       #FF,#C0,#7F,#FF,#C0,#3F,#FF,#C0       ;.@..@?.@
       DB       #7F,#FF,#C1,#FF,#00,#00,#00,#00       ;..A.....
       DB       #3F,#00,#00,#78,#80,#00,#75,#00       ;?..x..u.
       DB       #00,#40,#40,#00,#87,#40,#00,#90       ;.@@..@..
       DB       #C0,#00,#90,#C0,#00,#88,#80,#00       ;@..@....
       DB       #45,#40,#00,#27,#40,#00,#3F,#80       ;E@.'@.?.
       DB       #00,#1B,#00,#00,#1B,#80,#00,#18       ;........
       DB       #00,#00,#1C,#00,#F8,#1F,#FF,#F0       ;....x..p
       DB       #0F,#FF,#E0,#07,#FF,#E0,#07,#FF       ;..`..`..
       DB       #C0,#03,#FF,#80,#01,#FF,#80,#00       ;@.......
       DB       #FF,#80,#00,#FF,#80,#00,#FF,#00       ;........
       DB       #01,#FF,#00,#01,#FF,#80,#03,#FF       ;........
       DB       #C0,#07,#FF,#C1,#83,#FF,#C3,#C3       ;@..A..CC
       DB       #FF,#83,#83,#FF,#00,#00,#00,#07       ;........
       DB       #E0,#00,#08,#F0,#00,#05,#30,#00       ;`..p..0.
       DB       #10,#08,#00,#27,#04,#00,#28,#22       ;...'..("
       DB       #00,#28,#12,#00,#28,#12,#00,#44       ;.(..(..D
       DB       #24,#00,#4F,#E4,#00,#37,#F8,#00       ;$.Od.7x.
       DB       #0E,#70,#00,#1C,#38,#00,#18,#18       ;.p..8...
       DB       #00,#38,#38,#00,#FF,#C0,#FF,#FF       ;.88..@..
       DB       #80,#7F,#FF,#00,#3F,#FF,#00,#3F       ;....?..?
       DB       #FE,#00,#1F,#FC,#00,#0F,#FC,#00       ;~..|..|.
       DB       #0F,#FE,#00,#0F,#FE,#00,#0F,#FC       ;.~..~..|
       DB       #00,#1F,#FC,#00,#3F,#FE,#00,#7F       ;..|.?~..
       DB       #FF,#00,#7F,#FF,#C0,#7F,#FF,#C0       ;....@..@
       DB       #FF,#FF,#83,#FF,#00,#00,#00,#00       ;........
       DB       #3F,#00,#00,#47,#80,#00,#29,#80       ;?..G..).
       DB       #00,#80,#40,#01,#38,#20,#01,#41       ;..@.8 .A
       DB       #20,#00,#C1,#20,#00,#C3,#20,#01       ; .A .C .
       DB       #24,#40,#01,#3C,#80,#00,#DF,#00       ;$@.<.._.
       DB       #00,#1B,#00,#00,#1F,#00,#00,#18       ;........
       DB       #00,#00,#38,#00,#FF,#03,#FF,#FE       ;..8....~
       DB       #01,#FF,#FC,#00,#FF,#FC,#00,#FF       ;..|..|..
       DB       #F8,#00,#FF,#F8,#00,#7F,#F8,#00       ;x..x..x.
       DB       #7F,#F8,#00,#7F,#FC,#00,#7F,#F8       ;.x..|..x
       DB       #00,#FF,#F8,#01,#FF,#FC,#01,#FF       ;..x..|..
       DB       #FE,#03,#FF,#FC,#03,#FF,#FE,#03       ;~..|..~.
       DB       #FF,#FF,#83,#FF,#00,#00,#00,#00       ;........
       DB       #FC,#00,#01,#1E,#00,#00,#AE,#00       ;|.......
       DB       #02,#02,#00,#02,#E1,#00,#03,#09       ;....a...
       DB       #00,#03,#09,#00,#01,#11,#00,#02       ;........
       DB       #A2,#00,#02,#E4,#00,#01,#FC,#00       ;"..d..|.
       DB       #00,#D8,#00,#01,#D8,#00,#00,#18       ;.X..X...
       DB       #00,#00,#38,#00,#F8,#00,#FF,#F0       ;..8.x..p
       DB       #00,#FF,#E0,#00,#FF,#80,#00,#FF       ;..`.....
       DB       #00,#00,#FF,#00,#00,#FF,#00,#01       ;........
       DB       #FF,#00,#03,#FF,#80,#07,#FF,#C0       ;.......@
       DB       #0F,#FF,#E0,#0F,#FF,#C0,#0F,#FF       ;..`..@..
       DB       #E3,#07,#FF,#FF,#87,#FF,#FF,#87       ;c.......
       DB       #FF,#FF,#83,#FF,#00,#0E,#00,#07       ;........
       DB       #EA,#00,#0F,#F2,#00,#0F,#F2,#00       ;j..r..r.
       DB       #77,#E2,#00,#50,#02,#00,#40,#04       ;wb.P..@.
       DB       #00,#40,#18,#00,#3C,#20,#00,#0F       ;.@..< ..
       DB       #E0,#00,#0F,#E0,#00,#1C,#60,#00       ;`..`..`.
       DB       #00,#70,#00,#00,#30,#00,#00,#30       ;.p..0..0
       DB       #00,#00,#38,#00,#00,#1F,#FF,#00       ;..8.....
       DB       #0F,#FF,#00,#07,#FF,#00,#01,#FF       ;........
       DB       #00,#00,#FF,#00,#00,#FF,#80,#00       ;........
       DB       #FF,#C0,#00,#FF,#E0,#01,#FF,#F0       ;.@..`..p
       DB       #03,#FF,#F0,#07,#FF,#F0,#03,#FF       ;..p..p..
       DB       #E0,#C7,#FF,#E1,#FF,#FF,#E1,#FF       ;`G.a..a.
       DB       #FF,#C1,#FF,#FF,#70,#00,#00,#57       ;.A..p..W
       DB       #E0,#00,#4F,#F0,#00,#4F,#F0,#00       ;`.Op.Op.
       DB       #47,#EE,#00,#40,#0A,#00,#20,#02       ;Gn.@.. .
       DB       #00,#18,#02,#00,#04,#3C,#00,#07       ;.....<..
       DB       #F0,#00,#07,#F0,#00,#06,#38,#00       ;p..p..8.
       DB       #0E,#00,#00,#0C,#00,#00,#0C,#00       ;........
       DB       #00,#1C,#00,#00,#F0,#0F,#FF,#EF       ;....p..o
       DB       #F7,#FF,#DF,#FB,#FF,#BF,#FD,#FF       ;w._{.?}.
       DB       #BF,#FD,#FF,#7F,#FE,#FF,#7F,#FE       ;?}..~..~
       DB       #FF,#7F,#FE,#FF,#7F,#FE,#FF,#7F       ;..~..~..
       DB       #FE,#FF,#BF,#FD,#FF,#DF,#FB,#FF       ;~.?}._{.
       DB       #E7,#E7,#FF,#EF,#F7,#FF,#DF,#FB       ;gg.ow._{
       DB       #FF,#DE,#7B,#FF,#00,#00,#00,#0F       ;.^{.....
       DB       #F0,#00,#10,#08,#00,#20,#04,#00       ;p.... ..
       DB       #22,#44,#00,#40,#02,#00,#40,#02       ;"D.@..@.
       DB       #00,#40,#02,#00,#48,#12,#00,#48       ;.@..H..H
       DB       #12,#00,#24,#24,#00,#18,#18,#00       ;..$$....
       DB       #04,#20,#00,#0C       ;. ..
       DB       #30,#00,#11,#88,#00,#1E,#78,#00       ;0.....x.
       ;display $-Alien2_sprite ;9 sprites of 96 bytes
tscreenaddrs;=$-8
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       dup 20;16
       dw killablescraddr
       edup
        dw #4000
        dw #4100
        dw #4200
        dw #4300
        dw #4400
        dw #4500
        dw #4600
        dw #4700
        dw #4020
        dw #4120
        dw #4220
        dw #4320
        dw #4420
        dw #4520
        dw #4620
        dw #4720
tscreenaddrs4040
       DW       #4040
       DW       #4140
       DW       #4240
       DW       #4340
       DW       #4440
       DW       #4540
       DW       #4640
       DW       #4740
       DW       #4060
       DW       #4160
       DW       #4260
       DW       #4360
       DW       #4460
       DW       #4560
       DW       #4660
       DW       #4760
       DW       #4080
       DW       #4180
       DW       #4280
       DW       #4380
       DW       #4480
       DW       #4580
       DW       #4680
       DW       #4780
       DW       #40A0
       DW       #41A0
       DW       #42A0
       DW       #43A0
       DW       #44A0
       DW       #45A0
       DW       #46A0
       DW       #47A0
       DW       #40C0
       DW       #41C0
       DW       #42C0
       DW       #43C0
       DW       #44C0
       DW       #45C0
       DW       #46C0
       DW       #47C0
       DW       #40E0
       DW       #41E0
       DW       #42E0
       DW       #43E0
       DW       #44E0
       DW       #45E0
       DW       #46E0
       DW       #47E0
       DW       #4800
       DW       #4900
       DW       #4A00
       DW       #4B00
       DW       #4C00
       DW       #4D00
       DW       #4E00
       DW       #4F00
       DW       #4820
       DW       #4920
       DW       #4A20
       DW       #4B20
       DW       #4C20
       DW       #4D20
       DW       #4E20
       DW       #4F20
       DW       #4840
       DW       #4940
       DW       #4A40
       DW       #4B40
       DW       #4C40
       DW       #4D40
       DW       #4E40
       DW       #4F40
       DW       #4860
       DW       #4960
       DW       #4A60
       DW       #4B60
       DW       #4C60
       DW       #4D60
       DW       #4E60
       DW       #4F60
       DW       #4880
       DW       #4980
       DW       #4A80
       DW       #4B80
       DW       #4C80
       DW       #4D80
       DW       #4E80
       DW       #4F80
       DW       #48A0
       DW       #49A0
       DW       #4AA0
       DW       #4BA0
       DW       #4CA0
       DW       #4DA0
       DW       #4EA0
       DW       #4FA0
       DW       #48C0
       DW       #49C0
       DW       #4AC0
       DW       #4BC0
       DW       #4CC0
       DW       #4DC0
       DW       #4EC0
       DW       #4FC0
       DW       #48E0
       DW       #49E0
       DW       #4AE0
       DW       #4BE0
       DW       #4CE0
       DW       #4DE0
       DW       #4EE0
       DW       #4FE0
       DW       #5000
       DW       #5100
       DW       #5200
       DW       #5300
       DW       #5400
       DW       #5500
       DW       #5600
       DW       #5700
       DW       #5020
       DW       #5120
       DW       #5220
       DW       #5320
       DW       #5420
       DW       #5520
       DW       #5620
       DW       #5720
       DW       #5040
       DW       #5140
       DW       #5240
       DW       #5340
       DW       #5440
       DW       #5540
       DW       #5640
       DW       #5740
       DW       #5060
       DW       #5160
       DW       #5260
       DW       #5360
       DW       #5460
       DW       #5560
       DW       #5660
       DW       #5760
       DW       #5080
       DW       #5180
       DW       #5280
       DW       #5380
       DW       #5480
       DW       #5580
       DW       #5680
       DW       #5780
       DW       #50A0
       DW       #51A0
       DW       #52A0
       DW       #53A0
       DW       #54A0
       DW       #55A0
       DW       #56A0
       DW       #57A0
;
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       dup 24+16
       dw killablescraddr
       edup
;skoree vsego adresa dlya starih procedur
;       DB       #C0,#50,#C0,#51,#C0,#52,#C0,#53       ;@P@Q@R@S
;       DB       #C0,#54,#C0,#55,#C0,#56,#C0,#57       ;@T@U@V@W
;       DB       #E0,#50,#E0,#51,#E0,#52,#E0,#53       ;`P`Q`R`S
;       DB       #E0,#54,#E0,#55,#E0,#56,#E0,#57       ;`T`U`V`W
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       ;DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........

        if EGA == 0
        ds 0xc000-$ ;shadow screen

	ds #1800
        endif

L_D800
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00       ;....
;L_D80C
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00       ;......
L_EDBA       DB       #00       ;.
L_EDBB       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00       ;...
L_EDC6       DB       #00,#00       ;..
L_EDC8       DB       #00       ;.
L_EDC9       DB       #00       ;.
L_EDCA       DB       #00,#00,#00       ;...
L_EDCD       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00       ;....
L_EE61       DB       #01       ;.
;
;	ds 128
OutAYportHdataL
	LD	BC,0xFFFD
	OUT	(C),H
	LD	B,#BF
	OUT	(C),L
	RET
;
L_EE6C       DB       #00       ;.
L_EE6D       DB       #00,#00,#00,#00,#00       ;.....
L_EE72       DB       #00       ;.
L_EE73       DB       #F8       ;x
L_EE74       DB       #00       ;.
L_EE75       DB       #00       ;.
L_EE76       DB       #00       ;.
L_EE77       DB       #AB,#F5       ;+u
L_EE79       DB       #01,#18,#00,#00,#14,#00,#0F,#01       ;........
       DB       #FF,#00,#02,#00,#01,#08,#00,#00       ;........
       DB       #01,#AA,#F4,#AB,#F5       ;.*t+u
L_EE8E       DB       #00,#00,#FF,#FF,#01,#01,#00,#02       ;........
       DB       #01,#F4,#F4,#02,#EE,#F4,#F4       ;.tt.ntt
L_EE9D       DB       #C0,#F5       ;@u
L_EE9F       DB       #01,#03,#00,#00,#14,#00,#0F,#01       ;........
       DB       #FF,#01,#02,#02,#03,#09,#00,#00       ;........
       DB       #01,#86,#F4,#C0,#F5       ;..t@u
L_EEB4       DB       #01,#EF,#FF,#FF,#01,#01,#00,#02       ;.o......
       DB       #01,#09,#F5,#20,#07,#F5       ;..u .u
L_EEC2       DB       #18,#F5       ;.u
L_EEC4       DB       #01,#18,#00,#00,#14,#00,#0F,#01       ;........
       DB       #FF,#00,#02,#04,#05,#0A,#00,#00       ;........
       DB       #01,#86,#F4,#18,#F5       ;..t.u
L_EED9       DB       #00,#00,#FF,#FF,#01,#01,#00,#02       ;........
       DB       #01,#0C,#F5,#02,#0A,#F5,#00,#00       ;..u..u..
       DB       #00,#00,#00       ;...
;
L_EEEC	LD	A,#0F
	LD	(L_EDC6),A
	LD	(L_EDC9),A
	XOR	A
	LD	(L_EDC8),A
	LD	A,(L_EDBA)
	CP	#FF
	JP	NZ,L_EF02
	LD	A,#00
L_EF02	ADD	A,A
	LD	H,#00
	LD	L,A
	LD	DE,L_EDCD
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	(L_EDCA),BC
L_EF11	CALL	L_EFB4
	LD	A,(L_EDBA)
	CP	#FF
	JP	NZ,L_EF20
	INC	A
	LD	(L_EDBA),A
L_EF20	LD	A,#01
	LD	(L_EE79),A
	LD	(L_EE9F),A
	LD	(L_EEC4),A
	PUSH	IX
	LD	IX,L_EE77
	LD	A,(L_EDBA)
	ADD	A,A
	LD	B,A
	ADD	A,A
	ADD	A,B
	LD	L,A
	LD	H,#00
	LD	DE,L_F4E8
	ADD	HL,DE
	LD	(L_EF4D),HL
	INC	HL
	INC	HL
	LD	(L_EF57),HL
	INC	HL
	INC	HL
	LD	(L_EF61),HL
	LD	HL,(L_F4E8)
L_EF4D       EQU       $-2
	CALL	L_EF86
	LD	IX,L_EE9D
	LD	HL,(L_F4EA)
L_EF57       EQU       $-2
	CALL	L_EF86
	LD	IX,L_EEC2
	LD	HL,(L_F4EC)
L_EF61       EQU       $-2
	CALL	L_EF86
	LD	A,#01
	LD	(L_EE61),A
	LD	H,#07
	LD	L,#F8
	CALL	OutAYportHdataL
	LD	A,(L_EDBA)
	CP	#01
	POP	IX
	RET
;
       DB       #76,#CD,#E0,#EF,#3A,#61,#EE,#A7       ;vM`o:an'
       DB       #C2,#7A,#EF,#C9       ;BzoI
;
L_EF86	LD	(IX+#20),L
	LD	(IX+#23),L
	LD	(IX+#00),L
	LD	(IX+#21),H
	LD	(IX+#24),H
	LD	(IX+#01),H
	CALL	L_F2E1
	LD	(IX+#02),#01
	RES	7,(IX+#0C)
	LD	(IX+#05),#00
	LD	(IX+#04),#00 ;y?
	RET
;
L_EFAC	CALL	L_EFB4
	XOR	A
	LD	(L_EE61),A
	RET
;
L_EFB4	LD	H,#07
	LD	L,#FF
	CALL	OutAYportHdataL
	LD	HL,L_EE6C
	LD	DE,L_EE6D
	LD	BC,#000A
	LD	(HL),#00
	LDIR
	LD	A,#F8
	LD	(L_EE73),A
L_EFCD	LD	B,#0B
	LD	H,#00
	LD	DE,L_EE6C
L_EFD4	LD	A,(DE)
	LD	L,A
	PUSH	BC
	CALL	OutAYportHdataL
	POP	BC
	INC	H
	INC	DE
	DJNZ	L_EFD4
	RET
;
L_EFE0	LD	A,(L_EE61)
	AND	A
	JR	Z,L_F036
	PUSH	IX
	LD	IX,L_EE77
	BIT	7,(IX+#0C)
	CALL	Z,L_F037
	LD	IX,L_EE9D
	BIT	7,(IX+#0C)
	CALL	Z,L_F037
	LD	IX,L_EEC2
	BIT	7,(IX+#0C)
	CALL	Z,L_F037
	LD	A,(L_EDC6)
	CPL
	AND	#0F
	LD	B,A
	LD	A,(L_EE74)
	SUB	B
	JP	NC,L_F018
	XOR	A
L_F018	LD	(L_EE74),A
	LD	A,(L_EE75)
	SUB	B
	JP	NC,L_F023
	XOR	A
L_F023	LD	(L_EE75),A
	LD	A,(L_EE76)
	SUB	B
	JP	NC,L_F02E
	XOR	A
L_F02E	LD	(L_EE76),A
	CALL	L_EFCD
	POP	IX
L_F036	RET
;
L_F037	LD	A,(IX+#02)
	DEC	(IX+#02)
	JP	Z,L_F14A
L_F040	BIT	0,(IX+#0C)
	JR	NZ,L_F0B4
	BIT	1,(IX+#0C)
	JR	NZ,L_F083
	LD	A,(IX+#0B)
	AND	A
	JR	Z,L_F057
	DEC	(IX+#0B)
	JR	L_F0B4
;
L_F057	LD	A,(IX+#04) ;y?
	LD	B,(IX+#08)
	ADD	A,B
	LD	(IX+#04),A ;y?
	LD	B,(IX+#05)
	CP	B
	JR	Z,L_F077
	JR	NC,L_F071
	LD	A,(IX+#07)
	LD	(IX+#0B),A
	JR	L_F0B4
;
L_F071	LD	A,(IX+#05)
	LD	(IX+#04),A ;y?
L_F077	LD	A,(IX+#0C)
	AND	#FC
	OR	#02
	LD	(IX+#0C),A
	JR	L_F0B4
;
L_F083	LD	A,(IX+#0B)
	AND	A
	JR	Z,L_F08E
	DEC	(IX+#0B)
	JR	L_F0B4
;
L_F08E	LD	A,(IX+#04) ;y?
	LD	B,(IX+#0A)
	ADD	A,B
	LD	(IX+#04),A ;y?
	BIT	7,A
	JR	NZ,L_F0A4
	LD	A,(IX+#09)
	LD	(IX+#0B),A
	JR	L_F0B4
;
L_F0A4	LD	(IX+#04),#00 ;y?
	LD	A,(IX+#0C)
	AND	#FC
	OR	#02
	LD	(IX+#0C),A
	JR	L_F0B4
;
L_F0B4	LD	A,(IX+#04) ;y?
	LD	HL,L_EE6C
	LD	D,#00
	LD	E,(IX+#0F)
	ADD	HL,DE
	LD	(HL),A
	LD	H,(IX+#14)
	LD	L,(IX+#13)
	LD	D,#00
	LD	E,(IX+#10)
	ADD	HL,DE
	LD	A,(IX+#03)
	PUSH	AF
	LD	A,(HL)
	ADD	A,(IX+#03)
	LD	(IX+#03),A
	CALL	L_F1B8
	POP	AF
	LD	(IX+#03),A
	INC	(IX+#10)
	LD	A,(IX+#12)
	XOR	(IX+#10)
	JR	NZ,L_F0F0
	LD	A,(IX+#11)
	LD	(IX+#10),A
L_F0F0	LD	A,(IX+#1A)
	CP	#FF
	JR	Z,L_F140
	AND	A
	JR	Z,L_F0FF
	DEC	(IX+#1A)
	JR	NZ,L_F140
L_F0FF	DEC	(IX+#1F)
	JR	NZ,L_F112
	LD	A,(IX+#1E)
	LD	(IX+#1F),A
	LD	A,(IX+#1C)
	XOR	#01
	LD	(IX+#1C),A
L_F112	BIT	0,(IX+#1C)
	LD	B,(IX+#1B)
	LD	A,(IX+#1D)
	JR	Z,L_F121
	ADD	A,B
	JR	L_F122
;
L_F121	SUB	B
L_F122	LD	(IX+#1D),A
	LD	C,A
	LD	B,#FF
	BIT	7,A
	JR	NZ,L_F12E
	LD	B,#00
L_F12E	LD	HL,L_EE6C
	LD	D,#00
	LD	E,(IX+#0D)
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
L_F140	LD	A,(IX+#02)
	SRL	A
	AND	#07
	DB	#00
	DB	#00
	RET
;
L_F14A	LD	L,(IX+#00)
	LD	H,(IX+#01)
	LD	(IX+#10),#00
L_F154	LD	A,(HL)
	CP	#60
	JR	Z,L_F1B2
	CP	#61
	JP	Z,L_F25A
	CP	#62
	JP	Z,L_F20F
	CP	#63
	CP	#69
	JP	Z,L_F1EA
	CP	#FE
	JP	Z,L_F23C
	LD	(IX+#0C),#00
	SUB	#FF
L_F174       EQU       $-1
	LD	(IX+#03),A
L_F178	INC	HL
	LD	A,(HL)
	DEC	A
	PUSH	HL
	LD	H,#00
	LD	L,A
	LD	DE,(L_EDBB)
	ADD	HL,DE
	LD	A,(HL)
	POP	HL
	INC	HL
	LD	(IX+#02),A
	LD	A,(IX+#07)
	LD	(IX+#0B),A
	LD	(IX+#00),L
	LD	(IX+#01),H
	CALL	L_F1B8
	LD	A,(IX+#19)
	LD	(IX+#1A),A
	LD	A,(IX+#1E)
	SRL	A
	LD	(IX+#1F),A
	LD	(IX+#1C),#01
	LD	(IX+#1D),#00
	JP	L_F040
;
L_F1B2	LD	(IX+#0C),#02
	JR	L_F178
;
L_F1B8	LD	A,(IX+#17)
	AND	A
	JR	NZ,L_F1DB
	LD	A,(IX+#03)
	INC	A
	INC	A
	ADD	A,A
	LD	D,#00
	LD	E,A
	LD	HL,L_F332
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
L_F1CE	LD	HL,L_EE6C
	LD	D,#00
	LD	E,(IX+#0D)
	ADD	HL,DE
	LD	(HL),C
	INC	HL
	LD	(HL),B
	RET
;
;	ds 128
L_F1DB	LD	A,(IX+#03)
	NEG
	AND	#1F
	LD	(L_EE72),A
	LD	BC,#0000
	JR	L_F1CE
;
L_F1EA	XOR	A
	LD	(L_EE8E),A
	LD	(L_EEB4),A
	LD	(L_EED9),A
	LD	A,#F8
	LD	(L_EE73),A
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	(IX+#17),A
	AND	A
	JR	Z,L_F251
	LD	B,(IX+#18)
	LD	A,(L_EE73)
	LD	A,#EA
	LD	(L_EE73),A
	JR	L_F251
;
L_F20F	INC	HL
	LD	A,(HL)
	INC	HL
	PUSH	HL
	LD	(IX+#00),L
	LD	(IX+#01),H
	LD	DE,#0012
	LD	HL,L_F472
	INC	A
	LD	B,A
L_F221	ADD	HL,DE
	DJNZ	L_F221
	LD	A,(HL)
	LD	(IX+#11),A
	INC	HL
	LD	A,(HL)
	LD	(IX+#12),A
	INC	HL
	LD	(IX+#14),H
	LD	(IX+#13),L
	POP	HL
	LD	(IX+#10),#00
	JP	L_F154
;
L_F23C	LD	A,(IX+#22)
	DEC	A
	LD	(IX+#22),A
	JR	NZ,L_F24B
	JP	L_F2D3
;
       DB       #C3,#54,#F1       ;CTq
;
L_F24B	LD	L,(IX+#15)
	LD	H,(IX+#16)
L_F251	LD	(IX+#01),H
	LD	(IX+#00),L
	JP	L_F154
;
L_F25A	INC	HL
	LD	A,(HL)
	INC	HL
	PUSH	HL
	LD	(IX+#00),L
	LD	(IX+#01),H
	LD	DE,#0009
	LD	HL,L_F44E
	INC	A
	LD	B,A
L_F26C	ADD	HL,DE
	DJNZ	L_F26C
	PUSH	HL
	PUSH	IX
	POP	HL
	LD	DE,#0005
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	LD	BC,#0006
	LDIR
	LD	A,(HL)
	LD	(IX+#19),A
	INC	HL
	LD	A,(HL)
	LD	(IX+#1B),A
	INC	HL
	LD	A,(HL)
	LD	(IX+#1E),A
	POP	HL
	JP	L_F154
;
L_F290	INC	HL
	LD	A,(HL)
	INC	HL
	PUSH	HL
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	H,#00
	LD	L,A
	LD	DE,L_F406
	ADD	HL,DE
	LD	(L_EDBB),HL
	POP	HL
	JP	L_F2E7
;
L_F2A5	INC	HL
	LD	A,(HL)
	INC	HL
	LD	(L_F174),A
	JP	L_F2E7
;
L_F2AE	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,(L_F174)
	ADD	A,B
	LD	(L_F174),A
	JP	L_F2E7
;

;	ds 128
       DB       #DD,#36,#0C,#FF,#DD,#36,#03,#00       ;]6..]6..
       DB       #DD,#36,#04,#00,#23,#7E,#A7,#CA       ;]6..#~'J
       DB       #40,#F0,#CD,#AC,#EF,#C3,#40,#F0       ;@pM,oC@p
;
L_F2D3	CALL	L_F2E1
	JP	L_F14A
;
L_F2D9	POP	BC
	JP	L_EFAC
;
L_F2DD	POP	BC
	JP	L_EF11
;
L_F2E1	LD	L,(IX+#20)
	LD	H,(IX+#21)
L_F2E7	LD	A,(HL)
	CP	#FA
	JP	Z,L_F2AE
	CP	#FB
	JP	Z,L_F2A5
	CP	#FC
	JP	Z,L_F290
	CP	#FD
	JP	Z,L_F2DD
	CP	#FE
	JR	Z,L_F32A
	CP	#FF
	JR	Z,L_F2D9
	PUSH	HL
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	LD	DE,L_F4CC
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	(IX+#15),E
	LD	(IX+#16),D
	POP	HL
	INC	HL
	LD	A,(HL)
	LD	(IX+#22),A
	INC	HL
	LD	(IX+#20),L
	LD	(IX+#21),H
	RET
;
L_F32A	LD	L,(IX+#23)
	LD	H,(IX+#24)
	JR	L_F2E7
;
L_F332       DW       #0000
       DW       #0FBF
       DW       #0EDC
       DW       #0E07
       DW       #0D3D
       DW       #0C7F
       DW       #0BCC
       DW       #0B22
       DW       #0A82
       DW       #09EB
       DW       #095D
       DW       #08D6
       DW       #0857
       DW       #07DF
       DW       #076E
       DW       #0703
       DW       #069F
       DW       #0640
       DW       #05E6
       DW       #0591
       DW       #0541
       DW       #04F6
       DW       #04AE
       DW       #046B
       DW       #042C
       DW       #03F0
       DW       #03B7
       DW       #0382
       DW       #034F
       DW       #0320
       DW       #02F3
       DW       #02C8
       DW       #02A1
       DW       #027B
       DW       #0257
       DW       #0236
       DW       #0216
       DW       #01F8
       DW       #01DC
       DW       #01C1
       DW       #01A8
       DW       #0190
       DW       #0179
       DW       #0164
       DW       #0150
       DW       #013D
       DW       #012C
       DW       #011B
       DW       #010B
       DW       #00FC
       DW       #00EE
       DW       #00E0
       DW       #00D4
       DW       #00C8
       DW       #00BD
       DW       #00B2
       DW       #00A8
       DW       #009F
       DW       #0096
       DW       #008D
       DW       #0085
       DW       #007E
       DW       #0077
       DW       #0070
       DW       #006A
       DW       #0064
       DW       #005E
       DW       #0059
       DW       #0054
       DW       #004F
       DW       #004B
       DW       #0047
       DW       #0043
       DW       #003F
       DW       #003B
       DW       #0038
       DW       #0035
       DW       #0032
       DW       #002F
       DW       #002D
       DW       #002A
       DW       #0028
       DW       #0025
       DW       #0023
       DW       #0021
       DW       #001F
       DW       #001E
       DW       #001C
       DW       #001A
       DW       #0019
       DW       #0018
       DW       #0013
       DW       #0012
       DW       #0011
       DW       #0010
       DW       #000F
       DW       #000E
       DW       #000D
       DW       #000C
       DW       #000C
       DW       #000B
       DW       #000B
       DW       #000A
       DW       #0009
       DW       #0009
       DW       #0008
;
L_F406       DB       #01,#02,#03,#04,#06,#08,#0C,#10       ;........
       DB       #02,#04,#06,#08,#0C,#10,#18,#20       ;....... 
       DB       #03,#06,#09,#0C,#12,#18,#24,#30       ;......$0
       DB       #04,#08,#0C,#10,#18,#20,#30,#40       ;..... 0@
       DB       #05,#0A,#0F,#14,#1E,#28,#3C,#50       ;.....(<P
       DB       #06,#0C,#12,#18,#24,#30,#48,#60       ;....$0H`
       DB       #07,#0E,#15,#1C,#2A,#38,#54,#62       ;....*8Tb
       DB       #70,#08,#10,#18,#20,#30,#40,#60       ;p... 0@`
       DB       #80,#09,#12,#1B,#24,#36,#48,#6C       ;....$6Hl
;
L_F44E       DB       #90,#0A,#14,#1E,#28,#3C,#50,#78
       DB       #A0,#0F,#14,#00,#0F,#01,#FF,#FF
       DB       #01,#02,#0E,#C8,#00,#0F,#C8,#FF
       DB       #14,#01,#04,#0F,#00,#00,#0F,#00
       DB       #F0,#FF,#00,#00
;
L_F472       DB       #0F,#14,#00,#0F,#01,#FF,#FF,#00       ;........
       DB       #00,#0F,#23,#00,#0F,#07,#FF,#00       ;..#.....
       DB       #01,#02,#00,#01,#00,#0C,#18,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#01,#00,#0C       ;........
       DB       #18,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#01       ;........
       DB       #0C,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#07,#0C,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00       ;..
;
;	ds 128
L_F4CC       DW       L_F513
       DW       L_F518
       DW       L_F5AB
       DW       L_F5C0
       DW       L_F607
       DW       L_F52D
       DW       L_F557
       DW       L_F581
       DW       L_F542
       DW       L_F56C
       DW       L_F596
       DW       L_F62C
       DW       L_F651
       DW       L_F66E
L_F4E8       DW       L_F4EE
L_F4EA       DW       L_F507
L_F4EC       DW       L_F50A
;
L_F4EE       DB       #FC,#06,#FB,#FF,#02,#02,#08,#02       ;|.{.....
       DB       #09,#02,#0A,#02,#04,#02,#0B,#02       ;........
       DB       #0C,#02,#0D,#02,#04,#01,#0C,#01       ;........
       DB       #FD       ;}
L_F507       DB       #03,#20,#FE       ;. ~
L_F50A       DB       #01,#02,#05,#02,#06,#02,#07,#02       ;........
       DB       #FE       ;~
L_F513       DB       #61,#00,#62,#00,#FE       ;a.b.~
L_F518       DB       #61,#00,#62,#00,#0D,#01,#0D,#01       ;a.b.....
       DB       #19,#01,#0D,#01,#19,#01,#0D,#01       ;........
       DB       #17,#01,#19,#01,#FE       ;....~
L_F52D       DB       #61,#00,#62,#00,#09,#01,#09,#01       ;a.b.....
       DB       #15,#01,#09,#01,#15,#01,#09,#01       ;........
       DB       #14,#01,#15,#01,#FE       ;....~
L_F542       DB       #61,#00,#62,#02,#09,#01,#09,#01       ;a.b.....
       DB       #15,#01,#09,#01,#15,#01,#09,#01       ;........
       DB       #14,#01,#15,#01,#FE       ;....~
L_F557       DB       #61,#00,#62,#00,#0B,#01,#0B,#01       ;a.b.....
       DB       #17,#01,#0B,#01,#17,#01,#0B,#01       ;........
       DB       #15,#01,#17,#01,#FE       ;....~
L_F56C       DB       #61,#00,#62,#02,#0B,#01,#0B,#01       ;a.b.....
       DB       #17,#01,#0B,#01,#17,#01,#0B,#01       ;........
       DB       #15,#01,#17,#01,#FE       ;....~
L_F581       DB       #61,#00,#62,#00,#06,#01,#06,#01       ;a.b.....
       DB       #12,#01,#06,#01,#12,#01,#06,#01       ;........
       DB       #10,#01,#12,#01,#FE       ;....~
L_F596       DB       #61,#00,#62,#02,#06,#01,#06,#01       ;a.b.....
       DB       #12,#01,#06,#01,#12,#01,#06,#01       ;........
       DB       #10,#01,#12,#01,#FE       ;....~
L_F5AB       DB       #61,#03,#62,#02,#01,#01,#01,#01       ;a.b.....
       DB       #19,#01,#01,#01,#19,#01,#01,#01       ;........
       DB       #17,#01,#19,#01,#FE       ;....~
L_F5C0       DB       #61,#02,#62,#00,#69,#00,#01,#01       ;a.b.i...
       DB       #69,#01,#1E,#01,#1E,#01,#1E,#01       ;i.......
       DB       #61,#00,#69,#01,#02,#04,#61,#02       ;a.i...a.
       DB       #69,#00,#01,#02,#01,#02,#61,#00       ;i.....a.
       DB       #69,#01,#02,#04,#61,#02,#69,#00       ;i...a.i.
       DB       #01,#01,#69,#01,#1E,#01,#1E,#01       ;..i.....
       DB       #1E,#01,#61,#00,#02,#04,#69,#00       ;..a...i.
       DB       #61,#02,#01,#02,#01,#02,#69,#01       ;a.....i.
       DB       #61,#00,#02,#02,#02,#02,#FE       ;a.....~
L_F607       DB       #61,#01,#62,#01,#31,#07,#36,#02       ;a.b.1.6.
       DB       #31,#02,#38,#06,#34,#06,#36,#07       ;1.8.4.6.
       DB       #34,#02,#33,#02,#28,#02,#34,#02       ;4.3.(.4.
       DB       #28,#02,#34,#02,#27,#02,#33,#02       ;(.4.'.3.
       DB       #27,#02,#33,#02,#FE       ;'.3.~
L_F62C       DB       #61,#01,#62,#01,#38,#07,#3B,#02       ;a.b.8.;.
       DB       #3D,#02,#40,#04,#3F,#04,#3D,#04       ;=.@.?.=.
       DB       #3B,#02,#3D,#07,#3B,#02,#39,#02       ;;.=.;.9.
       DB       #38,#02,#36,#04,#38,#04,#34,#04       ;8.6.8.4.
       DB       #36,#02,#31,#02,#FE       ;6.1.~
L_F651       DB       #61,#04,#62,#03,#3D,#09,#40,#09       ;a.b.=.@.
       DB       #3D,#05,#3B,#05,#39,#04,#36,#09       ;=.;.9.6.
       DB       #40,#09,#44,#09,#45,#05,#47,#05       ;@.D.E.G.
       DB       #49,#04,#42,#09,#FE       ;I.B.~
L_F66E       DB       #61,#01,#62,#01,#25,#08,#28,#01       ;a.b.%.(.
       DB       #25,#01,#21,#08,#23,#01,#25,#01       ;%.!.#.%.
       DB       #23,#08,#25,#01,#23,#01,#1E,#09       ;#.%.#...
       DB       #25,#08,#28,#01,#2A,#01,#28,#08       ;%.(.*.(.
       DB       #2A,#01,#2D,#01,#2A,#08,#23,#01       ;*.-.*.#.
       DB       #28,#01,#25,#09,#FE

Font
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #08,#1C,#0C,#1C,#14,#08,#1C,#08       ;........
       DB       #00,#24,#6C,#90,#90,#48,#00,#00       ;.$l..H..
       DB       #00,#C0,#E0,#E0,#FC,#62,#9C,#00       ;.@``|b..
       DB       #00,#04,#04,#24,#64,#F8,#60,#20       ;...$dx` 
       DB       #4E,#E6,#4C,#18,#30,#62,#C7,#C2       ;NfL.0bGB
       DB       #38,#44,#92,#AA,#A2,#9C,#41,#3E       ;8D.*".A>
       DB       #00,#18,#38,#20,#10,#00,#00,#00       ;..8 ....
       DB       #02,#0C,#18,#18,#18,#18,#0C,#02       ;........
       DB       #40,#30,#18,#18,#18,#18,#30,#40       ;@0....0@
       DB       #00,#22,#1C,#3A,#FF,#3A,#1C,#22       ;.".:.:."
       DB       #04,#18,#08,#00,#7F,#00,#08,#1C       ;........
       DB       #00,#00,#00,#18,#3C,#34,#08,#10       ;....<4..
       DB       #00,#00,#00,#7F,#FE,#00,#00,#00       ;....~...
       DB       #00,#00,#00,#00,#18,#24,#3C,#18       ;.....$<.
       DB       #01,#03,#05,#0C,#18,#30,#A0,#C0       ;.....0 @
       DB       #3D,#4A,#85,#8B,#93,#A3,#42,#BC       ;=J...#B<
       DB       #0C,#14,#3C,#0C,#0C,#0C,#0C,#36       ;..<....6
       DB       #7C,#C6,#83,#86,#3C,#61,#DF,#FF       ;|F..<a_.
       DB       #1C,#26,#43,#0E,#03,#43,#26,#1C       ;.&C..C&.
       DB       #08,#18,#30,#60,#EC,#6F,#0C,#0C       ;..0`lo..
       DB       #02,#7E,#42,#38,#06,#E6,#44,#38       ;.~B8.fD8
       DB       #3C,#46,#80,#DC,#E2,#C3,#7D,#36       ;<F.\bC}6
       DB       #7F,#FA,#86,#0C,#18,#30,#30,#20       ;.z...00 
       DB       #3C,#66,#C3,#5E,#F3,#C3,#66,#3C       ;<fC^sCf<
       DB       #1C,#2E,#63,#47,#39,#03,#06,#1C       ;..cG9...
       DB       #10,#38,#10,#00,#10,#38,#10,#00       ;.8...8..
       DB       #00,#08,#1C,#08,#00,#0C,#9C,#60       ;.......`
       DB       #10,#10,#28,#28,#44,#44,#82,#FE       ;..((DD.~
       DB       #00,#00,#FE,#F2,#00,#3E,#FF,#00       ;..~r.>..
       DB       #7F,#7F,#3E,#3E,#1C,#1C,#08,#08       ;..>>....
       DB       #7C,#86,#C2,#46,#0C,#18,#00,#18       ;|.BF....
       DB       #00,#03,#07,#01,#3E,#7F,#3F,#00       ;....>.?.
       DB       #18,#34,#66,#64,#6E,#42,#26,#E7       ;.4fdnB&g
       DB       #F8,#54,#46,#6C,#46,#42,#4C,#F8       ;xTFlFBLx
       DB       #3C,#62,#C6,#80,#C0,#C2,#46,#3C       ;<bF.@BF<
       DB       #F8,#46,#63,#62,#43,#63,#66,#F8       ;xFcbCcfx
       DB       #BC,#66,#42,#78,#44,#41,#63,#EF       ;<fBxDAco
       DB       #BC,#46,#42,#70,#48,#40,#60,#30       ;<FBpH@`0
       DB       #3C,#66,#C2,#80,#8A,#C6,#6A,#3C       ;<fB..Fj<
       DB       #C0,#9C,#EE,#C6,#84,#88,#0C,#06       ;@.nF....
       DB       #70,#28,#10,#08,#18,#18,#14,#3C       ;p(.....<
       DB       #05,#03,#03,#03,#03,#81,#46,#3C       ;......F<
       DB       #80,#C7,#4C,#D8,#F4,#AE,#C5,#E3       ;.GLXt.Ec
       DB       #C0,#60,#60,#60,#60,#61,#53,#7F       ;@````aS.
       DB       #83,#46,#6C,#51,#49,#43,#42,#A3       ;.FlQICB#
       DB       #EE,#5B,#61,#41,#43,#66,#A6,#03       ;n[aACf&.
       DB       #3C,#46,#83,#83,#83,#83,#46,#3C       ;<F....F<
       DB       #78,#CC,#82,#C4,#78,#C0,#C0,#80       ;xL.Dx@@.
       DB       #3C,#42,#83,#83,#92,#9B,#C4,#7B       ;<B....D{
       DB       #BC,#46,#63,#63,#46,#3C,#66,#F3       ;<FccF<fs
       DB       #3C,#7A,#40,#36,#03,#C3,#6E,#3C       ;<z@6.Cn<
       DB       #FF,#C2,#99,#10,#18,#18,#28,#70       ;.B....(p
       DB       #20,#41,#83,#83,#C1,#A7,#6D,#39       ; A..A'm9
       DB       #81,#81,#C3,#C2,#A7,#62,#3C,#18       ;..CB'b<.
       DB       #81,#C3,#D3,#D1,#DB,#CB,#F7,#62       ;.CSQ[Kwb
       DB       #C3,#E3,#50,#28,#1C,#6E,#E7,#C2       ;CcP(.ngB
       DB       #00,#81,#C3,#C6,#7D,#01,#62,#3C       ;..CF}.b<
       DB       #7D,#F6,#84,#08,#10,#21,#5D,#FF       ;}v...!].
       DB       #18,#3C,#66,#67,#67,#66,#3C,#18       ;.<fggf<.
       DB       #00,#00,#40,#20,#10,#08,#04,#00       ;..@ ....
       DB       #00,#00,#00,#FF,#FF,#0E,#0E,#0A       ;........
       DB       #00,#10,#38,#54,#10,#10,#10,#00       ;..8T....
       DB       #00,#00,#00,#00,#00,#00,#00,#FF       ;........
       DB       #00,#1C,#22,#78,#20,#20,#7E,#00       ;.."x  ~.
       DB       #FF,#84,#87,#84,#88,#F0,#A0,#A0       ;.....p  
       DB       #FF,#00,#FF,#00,#00,#00,#00,#00       ;........
       DB       #FF,#21,#E1,#21,#11,#0F,#05,#05       ;.!a!....
       DB       #05,#05,#05,#05,#05,#05,#05,#05       ;........
       DB       #05,#05,#0F,#11,#21,#E1,#21,#FF       ;....!a!.
       DB       #00,#00,#00,#00,#00,#FF,#00,#FF       ;........
       DB       #A0,#A0,#F0,#88,#84,#87,#84,#FF       ;  p.....
       DB       #A0,#A0,#A0,#A0,#A0,#A0,#A0,#A0       ;        
       DB       #00,#46,#A8,#84,#82,#AA,#44,#00       ;.F(..*D.
       DB       #00,#66,#88,#44,#22,#AA,#44,#00       ;.f.D"*D.
       DB       #00,#EA,#8A,#CE,#8A,#8A,#EA,#00       ;.j.N..j.
       DB       #00,#6C,#8A,#4A,#2C,#A8,#48,#00       ;.l.J,(H.
       DB       #00,#C8,#A8,#A8,#A8,#A8,#CE,#00       ;.H((((N.
       DB       #00,#00,#30,#38,#3C,#00,#00,#00       ;..08<...
       DB       #00,#00,#38,#44,#44,#44,#38,#00       ;..8DDD8.
       DB       #00,#00,#78,#44,#44,#78,#40,#40       ;..xDDx@@
       DB       #00,#00,#3C,#44,#44,#3C,#04,#06       ;..<DD<..
       DB       #00,#00,#1C,#20,#20,#20,#20,#00       ;...    .
       DB       #00,#00,#38,#40,#38,#04,#78,#00       ;..8@8.x.
       DB       #00,#10,#38,#10,#10,#10,#0C,#00       ;..8.....
       DB       #00,#00,#44,#44,#44,#44,#38,#00       ;..DDDD8.
       DB       #00,#00,#44,#44,#28,#28,#10,#00       ;..DD((..
       DB       #00,#00,#44,#54,#54,#54,#28,#00       ;..DTTT(.
       DB       #00,#00,#44,#28,#10,#28,#44,#00       ;..D(.(D.
       DB       #00,#00,#44,#44,#44,#3C,#04,#38       ;..DDD<.8
       DB       #00,#00,#7C,#08,#10,#20,#7C,#00       ;..|.. |.
       DB       #00,#0E,#08,#30,#08,#08,#0E,#00       ;...0....
       DB       #00,#08,#08,#08,#08,#08,#08,#00       ;........
       DB       #00,#70,#10,#0C,#10,#10,#70,#00       ;.p....p.
       DB       #00,#14,#28,#00,#00,#00,#00,#00       ;..(.....
       DB       #3C,#42,#99,#A1,#A1,#99,#42,#3C       ;<B.!!.B<
