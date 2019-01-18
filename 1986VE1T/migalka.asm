	ALIGN 2
migalka	EQU $+1
	PUSH {LR}
	LDR R1,__0migalka__c___stokfn
	LDR R0,__1migalka__c___tokfn
	STR R1,[R0]
	LDR R0,__2migalka__c__migalka__fn
	LDR R1,[R0]
	LDR R0,__3migalka__c__nfopen__A__
	STR R1,[R0]
	LDR R1,__4migalka__c__migalka__B__
	LDR R0,__5migalka__c__nfopen__B__
	STR R1,[R0]
	BL nfopen
	LDR R0,__6migalka__c___fin
	STR R1,[R0]
	LDR R0,__7migalka__c___fin
	LDR R1,[R0]
	LDR R2,__8migalka__c__0
	SUBS R1,R2
	BNE __9migalka__c
	BL migalka__C__
__9migalka__c
	MOVS R1,#FALSE
	LDR R0,__10migalka__c___waseof
	STRB R1,[R0]
	LDR R1,__11migalka__c__1
	LDR R0,__12migalka__c___curline
	STR R1,[R0]
	BL initrd
	LDR R1,__13migalka__c__0
	LDR R0,__14migalka__c___lentokfn
	STR R1,[R0]
	LDR R1,__15migalka__c__0
	LDR R0,__16migalka__c__migalka__i
	STR R1,[R0]
migalka__E__	EQU $+1
	LDR R0,__17migalka__c__migalka__fn
	LDR R1,[R0]
	LDR R0,__18migalka__c___lentokfn
	LDR R2,[R0]
	ADDS R1,R2
	LDRB R1,[R1]
	SUBS R1,#'\0'
	BNE __19migalka__c
	BL migalka__F__
__19migalka__c
	LDR R0,__20migalka__c___tokfn
	LDR R1,[R0]
	LDR R0,__21migalka__c___lentokfn
	LDR R2,[R0]
	ADDS R1,R2
	LDR R0,__22migalka__c__migalka__fn
	LDR R2,[R0]
	LDR R0,__23migalka__c___lentokfn
	LDR R3,[R0]
	ADDS R2,R3
	LDRB R2,[R2]
	STRB R2,[R1]
	LDR R0,__24migalka__c__migalka__fn
	LDR R1,[R0]
	LDR R0,__25migalka__c___lentokfn
	LDR R2,[R0]
	ADDS R1,R2
	LDRB R1,[R1]
	SUBS R1,#'.'
	BEQ __26migalka__c
	BL migalka__G__
__26migalka__c
	LDR R0,__27migalka__c___lentokfn
	LDR R1,[R0]
	LDR R0,__28migalka__c__migalka__i
	STR R1,[R0]
migalka__G__	EQU $+1
	LDR R1,__29migalka__c___lentokfn
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	B migalka__E__
migalka__F__	EQU $+1
	LDR R0,__30migalka__c__migalka__i
	LDR R1,[R0]
	LDR R2,__31migalka__c__1
	ADDS R1,R2
	LDR R0,__32migalka__c___lentokfn
	STR R1,[R0]
	LDR R0,__33migalka__c___tokfn
	LDR R1,[R0]
	LDR R0,__34migalka__c__stradd__A__
	STR R1,[R0]
	LDR R0,__35migalka__c___lentokfn
	LDR R1,[R0]
	LDR R0,__36migalka__c__stradd__B__
	STR R1,[R0]
	LDR R0,__37migalka__c__migalka__fn
	LDR R1,[R0]
	LDR R0,__38migalka__c___lentokfn
	LDR R2,[R0]
	ADDS R1,R2
	LDRB R1,[R1]
	MOVS R2,#0xdf
	ANDS R1,R2
	LDR R0,__39migalka__c__stradd__C__
	STRB R1,[R0]
	BL stradd
	LDR R0,__40migalka__c___lentokfn
	STR R1,[R0]
	LDR R0,__41migalka__c___tokfn
	LDR R1,[R0]
	LDR R0,__42migalka__c__stradd__A__
	STR R1,[R0]
	LDR R0,__43migalka__c___lentokfn
	LDR R1,[R0]
	LDR R0,__44migalka__c__stradd__B__
	STR R1,[R0]
	MOVS R1,#'_'
	LDR R0,__45migalka__c__stradd__C__
	STRB R1,[R0]
	BL stradd
	LDR R0,__46migalka__c___lentokfn
	STR R1,[R0]
	LDR R0,__47migalka__c___tokfn
	LDR R1,[R0]
	LDR R0,__48migalka__c___lentokfn
	LDR R2,[R0]
	ADDS R1,R2
	MOVS R2,#'\0'
	STRB R2,[R1]
	LDR R0,__49migalka__c___tokfn
	LDR R1,[R0]
	LDR R0,__50migalka__c__openwrite__A__
	STR R1,[R0]
	BL openwrite
	LDR R0,__51migalka__c___fout
	STR R1,[R0]
migalka__loop	EQU $+1
	BL readfin
	LDR R0,__52migalka__c___cnext
	STRB R1,[R0]
	LDR R0,__53migalka__c___waseof
	LDRB R1,[R0]
	ORRS R1,R1
	BNE __54migalka__c
	BL migalka__I__
__54migalka__c
	B migalka__quit
migalka__I__	EQU $+1
	LDR R0,__55migalka__c___fout
	LDR R1,[R0]
	LDR R0,__56migalka__c__writebyte__A__
	STR R1,[R0]
	LDR R0,__57migalka__c___cnext
	LDRB R1,[R0]
	LDR R0,__58migalka__c__writebyte__B__
	STRB R1,[R0]
	BL writebyte
	B migalka__loop
migalka__quit	EQU $+1
	LDR R0,__59migalka__c___fout
	LDR R1,[R0]
	LDR R0,__60migalka__c__fclose__A__
	STR R1,[R0]
	BL fclose
	LDR R0,__61migalka__c___fin
	LDR R1,[R0]
	LDR R0,__62migalka__c__fclose__A__
	STR R1,[R0]
	BL fclose
migalka__led	EQU $+1
	LDR R1,__63migalka__c__LED_DRXTX
	LDR R2,__64migalka__c__1
	LDR R3,__65migalka__c__7
	PUSH {R1}
	MOVS R1,R2
	MOVS R2,R3
	BL _SHL__
	POP {R2}
	STR R1,[R2]
	LDR R1,__66migalka__c__LED_DRXTX
	LDR R2,__67migalka__c__0
	LDR R3,__68migalka__c__7
	PUSH {R1}
	MOVS R1,R2
	MOVS R2,R3
	BL _SHL__
	POP {R2}
	STR R1,[R2]
	B migalka__led
migalka__C__	EQU $+1
	POP {PC}
	ALIGN 4
__0migalka__c___stokfn
	DCD _stokfn
__1migalka__c___tokfn
	DCD _tokfn
__2migalka__c__migalka__fn
	DCD migalka__fn
__3migalka__c__nfopen__A__
	DCD nfopen__A__
__4migalka__c__migalka__B__
	DCD migalka__B__
__5migalka__c__nfopen__B__
	DCD nfopen__B__
__6migalka__c___fin
	DCD _fin
__7migalka__c___fin
	DCD _fin
__8migalka__c__0
	DCD 0
__10migalka__c___waseof
	DCD _waseof
__11migalka__c__1
	DCD 1
__12migalka__c___curline
	DCD _curline
__13migalka__c__0
	DCD 0
__14migalka__c___lentokfn
	DCD _lentokfn
__15migalka__c__0
	DCD 0
__16migalka__c__migalka__i
	DCD migalka__i
__17migalka__c__migalka__fn
	DCD migalka__fn
__18migalka__c___lentokfn
	DCD _lentokfn
__20migalka__c___tokfn
	DCD _tokfn
__21migalka__c___lentokfn
	DCD _lentokfn
__22migalka__c__migalka__fn
	DCD migalka__fn
__23migalka__c___lentokfn
	DCD _lentokfn
__24migalka__c__migalka__fn
	DCD migalka__fn
__25migalka__c___lentokfn
	DCD _lentokfn
__27migalka__c___lentokfn
	DCD _lentokfn
__28migalka__c__migalka__i
	DCD migalka__i
__29migalka__c___lentokfn
	DCD _lentokfn
__30migalka__c__migalka__i
	DCD migalka__i
__31migalka__c__1
	DCD 1
__32migalka__c___lentokfn
	DCD _lentokfn
__33migalka__c___tokfn
	DCD _tokfn
__34migalka__c__stradd__A__
	DCD stradd__A__
__35migalka__c___lentokfn
	DCD _lentokfn
__36migalka__c__stradd__B__
	DCD stradd__B__
__37migalka__c__migalka__fn
	DCD migalka__fn
__38migalka__c___lentokfn
	DCD _lentokfn
__39migalka__c__stradd__C__
	DCD stradd__C__
__40migalka__c___lentokfn
	DCD _lentokfn
__41migalka__c___tokfn
	DCD _tokfn
__42migalka__c__stradd__A__
	DCD stradd__A__
__43migalka__c___lentokfn
	DCD _lentokfn
__44migalka__c__stradd__B__
	DCD stradd__B__
__45migalka__c__stradd__C__
	DCD stradd__C__
__46migalka__c___lentokfn
	DCD _lentokfn
__47migalka__c___tokfn
	DCD _tokfn
__48migalka__c___lentokfn
	DCD _lentokfn
__49migalka__c___tokfn
	DCD _tokfn
__50migalka__c__openwrite__A__
	DCD openwrite__A__
__51migalka__c___fout
	DCD _fout
__52migalka__c___cnext
	DCD _cnext
__53migalka__c___waseof
	DCD _waseof
__55migalka__c___fout
	DCD _fout
__56migalka__c__writebyte__A__
	DCD writebyte__A__
__57migalka__c___cnext
	DCD _cnext
__58migalka__c__writebyte__B__
	DCD writebyte__B__
__59migalka__c___fout
	DCD _fout
__60migalka__c__fclose__A__
	DCD fclose__A__
__61migalka__c___fin
	DCD _fin
__62migalka__c__fclose__A__
	DCD fclose__A__
__63migalka__c__LED_DRXTX
	DCD LED_DRXTX
__64migalka__c__1
	DCD 1
__65migalka__c__7
	DCD 7
__66migalka__c__LED_DRXTX
	DCD LED_DRXTX
__67migalka__c__0
	DCD 0
__68migalka__c__7
	DCD 7
	END
