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
	DCOM PANIC ;ext ;<--------------
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
        DCOM PANIC ;ESer
        DCOM PANIC ;DAAal
        DCOM SUBrmr8
        DCOM SUBrmr16
        DCOM SUBr8rm
        DCOM SUBr16rm
        DCOM SUBali8
        DCOM SUBaxi16
	DCOM PANIC ;CSer
	DCOM PANIC ;DASal
;#3X
        DCOM XORrmr8
        DCOM XORrmr16
        DCOM XORr8rm
        DCOM XORr16rm
        DCOM XORali8
        DCOM XORaxi16
        DCOM PANIC ;SSer
        DCOM PANIC ;AAAal
        DCOM CMPrmr8
        DCOM CMPrmr16
        DCOM CMPr8rm
        DCOM CMPr16rm
        DCOM CMPali8
        DCOM CMPaxi16
	DCOM PANIC ;DSer
	DCOM PANIC ;AASal
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
        DCOM PANIC ;PUSHAer
        DCOM PANIC ;POPAer
        DCOM PANIC ;BOUNDr16m
        DCOM PANIC ;ARPLrmr16
        DCOM PANIC ;FSer
        DCOM PANIC ;GSer
        DCOM PANIC ;opsize
        DCOM PANIC ;rgsize
        DCOM PUSHi16
        DCOM PANIC ;IMULr16rmi16
        DCOM PUSHi8
        DCOM PANIC ;IMULr16rmi8
	DCOM PANIC ;INSBer
	DCOM PANIC ;INSWer
	DCOM PANIC ;OUTSBer
	DCOM PANIC ;OUTSWer
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
        DCOM PANIC ;GRP1rm8i8
        DCOM PANIC ;GRP1rm16i8
        DCOM PANIC ;TESTrmr8
        DCOM PANIC ;TESTrmr16
        DCOM PANIC ;XCHGr8rm
        DCOM PANIC ;XCHGr16rm
        DCOM MOVrmr8
        DCOM MOVrmr16
        DCOM MOVr8rm
        DCOM MOVr16rm
        DCOM PANIC ;MOVrm16sreg
        DCOM PANIC ;LEAr16rm
        DCOM PANIC ;MOVsregrm16
        DCOM PANIC ;POPrm16
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
        DCOM PANIC ;CALLptr1616
        DCOM PANIC ;FWAITer
        DCOM PANIC ;PUSHFer
        DCOM PANIC ;POPFer
        DCOM PANIC ;SAHFer
        DCOM PANIC ;LAHFer
;#Ax
        DCOM MOValmem
        DCOM MOVaxmem
        DCOM MOVmemal
        DCOM MOVmemax
        DCOM MOVSBer
        DCOM PANIC ;MOVSWer
        DCOM CMPSBer
        DCOM PANIC ;CMPSWer
        DCOM PANIC ;TESTali8
        DCOM PANIC ;TESTaxi16
        DCOM STOSBer
        DCOM STOSWer
        DCOM LODSBer
        DCOM LODSWer
        DCOM SCASBer
        DCOM PANIC ;SCASWer
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
        DCOM MOVspi16
        DCOM MOVsii16
        DCOM MOVdii16
;#Cx
        DCOM PANIC ;GRP2rm8i8
        DCOM PANIC ;GRP2rm16i8
        DCOM PANIC ;RETi16
        DCOM RETer
        DCOM PANIC ;LESr16mem
        DCOM PANIC ;LDSr16mem
        DCOM MOVrm8i8
        DCOM PANIC ;MOVrm16i16
        DCOM PANIC ;ENTERi16i8
        DCOM PANIC ;LEAVEer
        DCOM PANIC ;RETFi16
        DCOM PANIC ;RETFer
        DCOM PANIC ;INT3
        DCOM INTi8
        DCOM PANIC ;INTOer
        DCOM PANIC ;IRETer
;#Dx
        DCOM PANIC ;GRP2rm81 ;rolls
        DCOM PANIC ;GRP2rm161 ;rolls
        DCOM PANIC ;GRP2rm8cl ;rolls
        DCOM PANIC ;GRP2rm16cl ;rolls
        DCOM PANIC ;AAMer
        DCOM PANIC ;AADer
        DCOM PANIC ;SALCer
        DCOM PANIC ;XLATBer
        DCOM PANIC ;FPU0er
        DCOM PANIC ;FPU1er
        DCOM PANIC ;FPU2er
        DCOM PANIC ;FPU3er
        DCOM PANIC ;FPU4er
        DCOM PANIC ;FPU5er
        DCOM PANIC ;FPU6er
        DCOM PANIC ;FPU7er
;#Ex
        DCOM LOOPNZer
        DCOM LOOPZer
        DCOM LOOPer
        DCOM JCXZer
        DCOM INali8
        DCOM PANIC ;INaxi8
        DCOM PANIC ;OUTi8al
        DCOM PANIC ;OUTi8ax
        DCOM CALLer
        DCOM JMPer
        DCOM PANIC ;JMPptr1616
        DCOM JRer
        DCOM PANIC ;INaldx
        DCOM PANIC ;INaxdx
        DCOM PANIC ;OUTdxal
        DCOM PANIC ;OUTdxax
;#Fx
        DCOM PANIC ;LOCKer
        DCOM PANIC ;INT1
        DCOM REPNZer ;используется для cmpsb
        DCOM REPZer ;используется также для movsb и т.д.
        DCOM PANIC ;HLTer
        DCOM CMCer
        DCOM PANIC ;GRP38 ;mul,div,test,not,neg
        DCOM GRP316 ;mul,div,test,not,neg
        DCOM CLCer
        DCOM STCer
        DCOM CLIer
        DCOM STIer
        DCOM CLDer
        DCOM STDer
        DCOM PANIC ;GRP48
        DCOM GRP416 ;FF MOD01fRM disp16 = CALLrm+... /f - межсегментный/, так же можно PUSHrm+..., INCrm+... ;FF 25 = jmp word [di]

	DISPLAY $-MAINCOMS,"=256"
        ORG $+256