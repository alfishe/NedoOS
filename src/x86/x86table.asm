        MACRO DCOM wrd
        DB wrd&0xff;\0
        ORG $+255        DB wrd/256;'(\0)        ORG $-256        ENDM
;--------------------- -----------------------
MAINCOMS
;#0X
        DCOM ADDrmr8
        DCOM ADDrmr16
        DCOM ADDr8rm
        DCOM ADDr16rm
        DCOM ADDali8
        DCOM ADDaxi16
        DCOM PUSHes
        DCOM POPes
        DCOM ORrmr8
        DCOM ORrmr16
        DCOM ORr8rm
        DCOM ORr16rm
        DCOM ORali8
        DCOM ORaxi16
	DCOM PUSHcs
	DCOM EXTer ;<-------------- ;0f b6 d0 = movzx dx,al (move with zero-extend)
;#1X
        DCOM ADCrmr8
        DCOM ADCrmr16
        DCOM ADCr8rm
        DCOM ADCr16rm
        DCOM ADCali8
        DCOM ADCaxi16
        DCOM PUSHss
        DCOM POPss
        DCOM SBBrmr8
        DCOM SBBrmr16
        DCOM SBBr8rm
        DCOM SBBr16rm
        DCOM SBBali8
        DCOM SBBaxi16
	DCOM PUSHds
	DCOM POPds
;#2X
        DCOM ANDrmr8
        DCOM ANDrmr16
        DCOM ANDr8rm
        DCOM ANDr16rm
        DCOM ANDali8
        DCOM ANDaxi16
        DCOM ESer
        DCOM DAAal
        DCOM SUBrmr8
        DCOM SUBrmr16
        DCOM SUBr8rm
        DCOM SUBr16rm
        DCOM SUBali8
        DCOM SUBaxi16
	DCOM CSer
	DCOM DASal
;#3X
        DCOM XORrmr8
        DCOM XORrmr16
        DCOM XORr8rm
        DCOM XORr16rm
        DCOM XORali8
        DCOM XORaxi16
        DCOM SSer
        DCOM AAAal ;labir
        DCOM CMPrmr8
        DCOM CMPrmr16
        DCOM CMPr8rm
        DCOM CMPr16rm
        DCOM CMPali8
        DCOM CMPaxi16
	DCOM DSer
	DCOM AASal ;plutina
;#4X
        DCOM INCax
        DCOM INCcx
        DCOM INCdx
        DCOM INCbx
        DCOM INCsp
        DCOM INCbp
        DCOM INCsi
        DCOM INCdi
        DCOM DECax
        DCOM DECcx
        DCOM DECdx
        DCOM DECbx
        DCOM DECsp
        DCOM DECbp
        DCOM DECsi
        DCOM DECdi
;#5X
        DCOM PUSHax
        DCOM PUSHcx
        DCOM PUSHdx
        DCOM PUSHbx
        DCOM PUSHsp
        DCOM PUSHbp
        DCOM PUSHsi
        DCOM PUSHdi
        DCOM POPax
        DCOM POPcx
        DCOM POPdx
        DCOM POPbx
        DCOM POPsp
        DCOM POPbp
        DCOM POPsi
        DCOM POPdi
;#6x
        DCOM PUSHAer
        DCOM POPAer
        DCOM PANIC ;BOUNDr16m ;for basic.x86, ll, firefighter? TODO
        DCOM PANIC ;ARPLrmr16 ;for cgadots TODO;Compares the RPL fields of two segment selectors. The first operand (the destination operand) contains one segment selector and the second operand (source operand) contains the other. (The RPL field is located in bits 0 and 1 of each operand.) If the RPL field of the destination operand is less than the RPL field of the source operand, the ZF flag is set and the RPL field of the destination operand is increased to match that of the source operand. Otherwise, the ZF flag is cleared and no change is made to the destination operand. (The destination operand can be a word register or a memory location; the source operand must be a word register.)
        DCOM FSer
        DCOM GSer
        DCOM OPSIZEr ;???for lodsd (TODO может быть даже с repnz - blue) ;lander cs:0646: 66 ff 36 9a 08 "push dword ptr [089a]", 66 8f 06 96 08 "pop dword ptr [0896]" и есть 32-битные реги
        DCOM PANIC ;rgsize
        DCOM PUSHi16
        DCOM IMULr16rmi16
        DCOM PUSHi8
        DCOM IMULr16rmi8
	DCOM PANIC ;INSBer
	DCOM PANIC ;INSWer (TODO rep insw for lkccmini) for rax
	DCOM PANIC ;OUTSBer (TODO for ll)
	DCOM PANIC ;OUTSWer (TODO for firefighter)
;#7x
        DCOM JOer
        DCOM JNOer
        DCOM JCer;JNAEer;JBer
        DCOM JNCer;JAEer;JNBer
        DCOM JEer;JZer
        DCOM JNEer;JNZer
        DCOM JBEer;JNAer
        DCOM JAer;JNBEer
        DCOM JSer
        DCOM JNSer
        DCOM JPer;JPEer
        DCOM JNPer;JPOer
        DCOM JLer;JNGEer
        DCOM JNLer;JGEer
        DCOM JLEer;JGer
        DCOM JGer;JNLEer
;#8x
        DCOM GRP1rmi8  ;80 MOD100RM disp16 i8 = AND R/[M],i8 (100 - код операции АЛУ, 111=CMP)
        DCOM GRP1rmi16 ;GRP1rmi16 ;то же с i16 (там cmp sp,i16)
        DCOM GRP1rmi8;PANIC ;GRP1rm8i8 - алиас GRP1rmi8 (в 8086 нет?)
        DCOM GRP1rm16i8 ;там add dx,6 - операнд расширяется со знаком
        DCOM TESTrmr8
        DCOM TESTrmr16
        DCOM XCHGr8rm ;for pixeltown
        DCOM XCHGr16rm
        DCOM MOVrmr8
        DCOM MOVrmr16
        DCOM MOVr8rm
        DCOM MOVr16rm
        DCOM MOVrm16sreg
        DCOM LEAr16rm ;(for ladybug)
        DCOM MOVsregrm16
        DCOM POPrm16 ;(for rogue)
;#9x
        DCOM NOPer
        DCOM XCHGaxcx
        DCOM XCHGaxdx
        DCOM XCHGaxbx
        DCOM XCHGaxsp
        DCOM XCHGaxbp
        DCOM XCHGaxsi
        DCOM XCHGaxdi
        DCOM CBWer
        DCOM CWDer
        DCOM CALLptr1616
        DCOM NOPer ;FWAITer ;TODO for ladybug, ElCsiP, hyper
        DCOM PUSHFer
        DCOM POPFer
        DCOM SAHFer
        DCOM LAHFer
;#Ax
        DCOM MOValmem
        DCOM MOVaxmem
        DCOM MOVmemal
        DCOM MOVmemax
        DCOM MOVSBer
        DCOM MOVSWer
        DCOM CMPSBer
        DCOM CMPSWer ;for firefighter
        DCOM TESTali8
        DCOM TESTaxi16
        DCOM STOSBer
        DCOM STOSWer
        DCOM LODSBer
        DCOM LODSWer
        DCOM SCASBer
        DCOM SCASWer
;#Bx
        DCOM MOVali8
        DCOM MOVcli8
        DCOM MOVdli8
        DCOM MOVbli8
        DCOM MOVahi8
        DCOM MOVchi8
        DCOM MOVdhi8
        DCOM MOVbhi8
        DCOM MOVaxi16
        DCOM MOVcxi16
        DCOM MOVdxi16
        DCOM MOVbxi16
        DCOM MOVspi16
        DCOM MOVbpi16
        DCOM MOVsii16
        DCOM MOVdii16
;#Cx
        DCOM GRP2rm8i8 ;rolls
        DCOM GRP2rm16i8 ;rolls
        DCOM RETi16 ;RET и потом SP += i16
        DCOM RETer
        DCOM LESr16mem
        DCOM LDSr16mem
        DCOM MOVrm8i8
        DCOM MOVrm16i16
        DCOM PANIC ;ENTERi16i8 (TODO ms pacman?)
        DCOM LEAVEer ;ptica (03c8)? или это глюк? (в td не могу найти эту точку, в начале программы точно нет)
        DCOM RETFi16 ;RETF и потом SP += i16 ;fot 
        DCOM RETFer
        DCOM INT3 ;for qloth_
        DCOM INTi8 ;TODO тут ещё fldcw cd 35 xx xx, fistp cd 3b xx xx (mips)
        DCOM INTOer ;Generate overflow trap if overflow flag is 1 ;for mips
        DCOM IRETer ;(for livin)
;#Dx
        DCOM GRP2rm81 ;rolls
        DCOM GRP2rm161 ;rolls
        DCOM GRP2rm8cl ;rolls
        DCOM GRP2rm16cl ;rolls
        DCOM AAMer
        DCOM AADer
        DCOM PANIC ;SALCer
        DCOM XLATBer
        DCOM PANIC ;FPU0er ;D8 /0 = FADD m32fp ;Add m32fp to ST(0) and store result in ST(0) ;D8 C0+i = FADD ST(0), ST(i) ;Add ST(0) to ST(i) and store result in ST(0) ;D8 /1 = FMUL m32fp ;Multiply ST(0) by m32fp and store result in ST(0) ;D8 /2 = FCOM m32fp ;Compare ST(0) with m32fp ;D8 /3 = FCOMP m32fp ;Compare ST(0) with m32fp and pop register stack ;D8 /4 = FSUB m32fp ;Subtract m32fp from ST(0) and store result in ST(0) ;D8 /6 = FDIV m32fp ;Divide ST(0) by m32fp and store result in ST(0) ;D8 /7 = FDIVR m32fp ;Divide m32fp by ST(0) and store result in ST(0)
        DCOM PANIC ;FPU1er ;D9 E0 = FCHS ;Complements sign of ST(0) ;D9 E1 = FABS ;Replace ST with its absolute value ;D9 F6 = FDECSTP ;Decrement TOP field in FPU status word (rotate the stack by one position) ;D9 FF = FCOS ;Replace ST(0) with its approximate cosine
        DCOM PANIC ;FPU2er ;DA /0 = FIADD m32int ;Add m32int to ST(0) and store result in ST(0)
        DCOM FPU3er ;DB /0 = FILD m32int ;Push m32int onto the FPU register stack ;DB F0+i = FCOMI ST, ST(i) ;Compare ST(0) with ST(i) and set status flags accordingly ;DB E3 finit
        DCOM PANIC ;FPU4er ;DC /0 = FADD m64fp ;Add m64fp to ST(0) and store result in ST(0) ;DC C0+i = FADD ST(i), ST(0) ;Add ST(i) to ST(0) and store result in ST(i)
        DCOM PANIC ;FPU5er
        DCOM PANIC ;FPU6er ;DE /0 = FIADD m16int ;Add m16int to ST(0) and store result in ST(0) ;DE C0+i = FADDP ST(i), ST(0) ;Add ST(0) to ST(i), store result in ST(i), and pop the register stack ;DE C1 = FADDP ;Add ST(0) to ST(1), store result in ST(1), and pop the register stack
        DCOM PANIC ;FPU7er ;DF /0 = FILD m16int ;Push m16int onto the FPU register stack ;DF /5 = FILD m64int ;Push m64int onto the FPU register stack
;#Ex
        DCOM LOOPNZer
        DCOM LOOPZer
        DCOM LOOPer
        DCOM JCXZer
        DCOM INali8
        DCOM INaxi8
        DCOM OUTi8al
        DCOM OUTi8ax
        DCOM CALLer
        DCOM JMPer
        DCOM JMPptr1616
        DCOM JRer
        DCOM INaldx
        DCOM INaxdx
        DCOM OUTdxal
        DCOM OUTdxax
;#Fx
        DCOM PANIC ;LOCKer
        DCOM INT1 ;(atom)
        DCOM REPNZer ;используется для cmpsb
        DCOM REPZer ;используется также для movsb и т.д.
        DCOM HLTer
        DCOM CMCer
        DCOM GRP38 ;mul,div,test,not,neg
        DCOM GRP316 ;mul,div,test,not,neg
        DCOM CLCer
        DCOM STCer
        DCOM CLIer
        DCOM STIer
        DCOM CLDer
        DCOM STDer
        DCOM GRP48 ;inc/dec rm8
        DCOM GRP416 ;inc/dec rm16, push rm16, FF MD01fR/M disp16 = CALLrm+... /f - межсегментный/, FF 25 = jmp word [di]

	;DISPLAY $-MAINCOMS,"=256"
        ORG $+256