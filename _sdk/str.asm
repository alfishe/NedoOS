	ALIGN 2
strjoin	EQU $+1
	PUSH {LR}
	LDR R0,__0_______sdk__str__c__strjoin__to
	LDR R1,[R0]
	LDR R0,__1_______sdk__str__c__strjoin__tolen
	LDR R2,[R0]
	ADDS R1,R2
	LDR R0,__2_______sdk__str__c__strjoin__to
	STR R1,[R0]
	LDR R0,__3_______sdk__str__c__strjoin__tolen
	LDR R1,[R0]
	LDR R0,__4_______sdk__str__c__strjoin__len
	STR R1,[R0]
strjoin__loop	EQU $+1
	LDR R0,__5_______sdk__str__c__strjoin__s2
	LDR R1,[R0]
	LDRB R1,[R1]
	LDR R0,__6_______sdk__str__c__strjoin__c
	STRB R1,[R0]
	LDR R0,__7_______sdk__str__c__strjoin__c
	LDRB R1,[R0]
	SUBS R1,#'\0'
	MOV R1,R8
	BNE __8_______sdk__str__c
	EORS R1,R7
__8_______sdk__str__c
	LDR R0,__9_______sdk__str__c__strjoin__len
	LDR R2,[R0]
	LDR R3,__10_______sdk__str__c___STRMAX
	SUBS R2,R3
	SBCS R2,R2
	EORS R2,R7
	ORRS R1,R2
	BNE __11_______sdk__str__c
	BL strjoin__D__
__11_______sdk__str__c
	B strjoin__endloop
strjoin__D__	EQU $+1
	LDR R0,__12_______sdk__str__c__strjoin__to
	LDR R1,[R0]
	LDR R0,__13_______sdk__str__c__strjoin__c
	LDRB R2,[R0]
	STRB R2,[R1]
	LDR R1,__14_______sdk__str__c__strjoin__s2
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R1,__15_______sdk__str__c__strjoin__to
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R1,__16_______sdk__str__c__strjoin__len
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	B strjoin__loop
strjoin__endloop	EQU $+1
	LDR R0,__17_______sdk__str__c__strjoin__len
	LDR R1,[R0]
	MOVS R1,R1
	MOVS R1,R1
	POP {PC}
	ALIGN 4
__0_______sdk__str__c__strjoin__to
	DCD strjoin__to
__1_______sdk__str__c__strjoin__tolen
	DCD strjoin__tolen
__2_______sdk__str__c__strjoin__to
	DCD strjoin__to
__3_______sdk__str__c__strjoin__tolen
	DCD strjoin__tolen
__4_______sdk__str__c__strjoin__len
	DCD strjoin__len
__5_______sdk__str__c__strjoin__s2
	DCD strjoin__s2
__6_______sdk__str__c__strjoin__c
	DCD strjoin__c
__7_______sdk__str__c__strjoin__c
	DCD strjoin__c
__9_______sdk__str__c__strjoin__len
	DCD strjoin__len
__10_______sdk__str__c___STRMAX
	DCD _STRMAX
__12_______sdk__str__c__strjoin__to
	DCD strjoin__to
__13_______sdk__str__c__strjoin__c
	DCD strjoin__c
__14_______sdk__str__c__strjoin__s2
	DCD strjoin__s2
__15_______sdk__str__c__strjoin__to
	DCD strjoin__to
__16_______sdk__str__c__strjoin__len
	DCD strjoin__len
__17_______sdk__str__c__strjoin__len
	DCD strjoin__len
strjoineol	EQU $+1
	PUSH {LR}
	LDR R0,__18_______sdk__str__c__strjoineol__to
	LDR R1,[R0]
	LDR R0,__19_______sdk__str__c__strjoineol__tolen
	LDR R2,[R0]
	ADDS R1,R2
	LDR R0,__20_______sdk__str__c__strjoineol__to
	STR R1,[R0]
	LDR R0,__21_______sdk__str__c__strjoineol__tolen
	LDR R1,[R0]
	LDR R0,__22_______sdk__str__c__strjoineol__len
	STR R1,[R0]
strjoineol__loop	EQU $+1
	LDR R0,__23_______sdk__str__c__strjoineol__s2
	LDR R1,[R0]
	LDRB R1,[R1]
	LDR R0,__24_______sdk__str__c__strjoineol__c
	STRB R1,[R0]
	LDR R0,__25_______sdk__str__c__strjoineol__c
	LDRB R1,[R0]
	LDR R0,__26_______sdk__str__c__strjoineol__eol
	LDRB R2,[R0]
	SUBS R1,R2
	MOV R1,R8
	BNE __27_______sdk__str__c
	EORS R1,R7
__27_______sdk__str__c
	LDR R0,__28_______sdk__str__c__strjoineol__len
	LDR R2,[R0]
	LDR R3,__29_______sdk__str__c___STRMAX
	SUBS R2,R3
	SBCS R2,R2
	EORS R2,R7
	ORRS R1,R2
	BNE __30_______sdk__str__c
	BL strjoineol__E__
__30_______sdk__str__c
	B strjoineol__endloop
strjoineol__E__	EQU $+1
	LDR R0,__31_______sdk__str__c__strjoineol__to
	LDR R1,[R0]
	LDR R0,__32_______sdk__str__c__strjoineol__c
	LDRB R2,[R0]
	STRB R2,[R1]
	LDR R1,__33_______sdk__str__c__strjoineol__s2
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R1,__34_______sdk__str__c__strjoineol__to
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R1,__35_______sdk__str__c__strjoineol__len
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	B strjoineol__loop
strjoineol__endloop	EQU $+1
	LDR R0,__36_______sdk__str__c__strjoineol__len
	LDR R1,[R0]
	MOVS R1,R1
	MOVS R1,R1
	POP {PC}
	ALIGN 4
__18_______sdk__str__c__strjoineol__to
	DCD strjoineol__to
__19_______sdk__str__c__strjoineol__tolen
	DCD strjoineol__tolen
__20_______sdk__str__c__strjoineol__to
	DCD strjoineol__to
__21_______sdk__str__c__strjoineol__tolen
	DCD strjoineol__tolen
__22_______sdk__str__c__strjoineol__len
	DCD strjoineol__len
__23_______sdk__str__c__strjoineol__s2
	DCD strjoineol__s2
__24_______sdk__str__c__strjoineol__c
	DCD strjoineol__c
__25_______sdk__str__c__strjoineol__c
	DCD strjoineol__c
__26_______sdk__str__c__strjoineol__eol
	DCD strjoineol__eol
__28_______sdk__str__c__strjoineol__len
	DCD strjoineol__len
__29_______sdk__str__c___STRMAX
	DCD _STRMAX
__31_______sdk__str__c__strjoineol__to
	DCD strjoineol__to
__32_______sdk__str__c__strjoineol__c
	DCD strjoineol__c
__33_______sdk__str__c__strjoineol__s2
	DCD strjoineol__s2
__34_______sdk__str__c__strjoineol__to
	DCD strjoineol__to
__35_______sdk__str__c__strjoineol__len
	DCD strjoineol__len
__36_______sdk__str__c__strjoineol__len
	DCD strjoineol__len
strcopy	EQU $+1
	PUSH {LR}
	LDR R0,__37_______sdk__str__c__strcopy__len
	LDR R1,[R0]
	LDR R2,__38_______sdk__str__c__1
	ADDS R1,R2
	LDR R0,__39_______sdk__str__c__strcopy__i
	STR R1,[R0]
strcopy__D__	EQU $+1
	LDR R0,__40_______sdk__str__c__strcopy__from
	LDR R1,[R0]
	LDRB R1,[R1]
	LDR R0,__41_______sdk__str__c__strcopy__c
	STRB R1,[R0]
	LDR R0,__42_______sdk__str__c__strcopy__to
	LDR R1,[R0]
	LDR R0,__43_______sdk__str__c__strcopy__c
	LDRB R2,[R0]
	STRB R2,[R1]
	LDR R1,__44_______sdk__str__c__strcopy__from
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R1,__45_______sdk__str__c__strcopy__to
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R1,__46_______sdk__str__c__strcopy__i
	LDR R0,[R1]
	SUBS R0,#1
	STR R0,[R1]
	LDR R0,__47_______sdk__str__c__strcopy__i
	LDR R1,[R0]
	LDR R2,__48_______sdk__str__c__0
	SUBS R1,R2
	BEQ __49_______sdk__str__c
	BL strcopy__D__
__49_______sdk__str__c
strcopy__E__	EQU $+1
	LDR R0,__50_______sdk__str__c__strcopy__len
	LDR R1,[R0]
	MOVS R1,R1
	MOVS R1,R1
	POP {PC}
	ALIGN 4
__37_______sdk__str__c__strcopy__len
	DCD strcopy__len
__38_______sdk__str__c__1
	DCD 1
__39_______sdk__str__c__strcopy__i
	DCD strcopy__i
__40_______sdk__str__c__strcopy__from
	DCD strcopy__from
__41_______sdk__str__c__strcopy__c
	DCD strcopy__c
__42_______sdk__str__c__strcopy__to
	DCD strcopy__to
__43_______sdk__str__c__strcopy__c
	DCD strcopy__c
__44_______sdk__str__c__strcopy__from
	DCD strcopy__from
__45_______sdk__str__c__strcopy__to
	DCD strcopy__to
__46_______sdk__str__c__strcopy__i
	DCD strcopy__i
__47_______sdk__str__c__strcopy__i
	DCD strcopy__i
__48_______sdk__str__c__0
	DCD 0
__50_______sdk__str__c__strcopy__len
	DCD strcopy__len
memcopy	EQU $+1
	PUSH {LR}
memcopy__D__	EQU $+1
	LDR R0,__51_______sdk__str__c__memcopy__from
	LDR R1,[R0]
	LDRB R1,[R1]
	LDR R0,__52_______sdk__str__c__memcopy__c
	STRB R1,[R0]
	LDR R0,__53_______sdk__str__c__memcopy__to
	LDR R1,[R0]
	LDR R0,__54_______sdk__str__c__memcopy__c
	LDRB R2,[R0]
	STRB R2,[R1]
	LDR R1,__55_______sdk__str__c__memcopy__from
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R1,__56_______sdk__str__c__memcopy__to
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R1,__57_______sdk__str__c__memcopy__len
	LDR R0,[R1]
	SUBS R0,#1
	STR R0,[R1]
	LDR R0,__58_______sdk__str__c__memcopy__len
	LDR R1,[R0]
	LDR R2,__59_______sdk__str__c__0
	SUBS R1,R2
	BEQ __60_______sdk__str__c
	BL memcopy__D__
__60_______sdk__str__c
memcopy__E__	EQU $+1
	POP {PC}
	ALIGN 4
__51_______sdk__str__c__memcopy__from
	DCD memcopy__from
__52_______sdk__str__c__memcopy__c
	DCD memcopy__c
__53_______sdk__str__c__memcopy__to
	DCD memcopy__to
__54_______sdk__str__c__memcopy__c
	DCD memcopy__c
__55_______sdk__str__c__memcopy__from
	DCD memcopy__from
__56_______sdk__str__c__memcopy__to
	DCD memcopy__to
__57_______sdk__str__c__memcopy__len
	DCD memcopy__len
__58_______sdk__str__c__memcopy__len
	DCD memcopy__len
__59_______sdk__str__c__0
	DCD 0
memcopyback	EQU $+1
	PUSH {LR}
memcopyback__D__	EQU $+1
	LDR R0,__61_______sdk__str__c__memcopyback__from
	LDR R1,[R0]
	LDRB R1,[R1]
	LDR R0,__62_______sdk__str__c__memcopyback__c
	STRB R1,[R0]
	LDR R0,__63_______sdk__str__c__memcopyback__to
	LDR R1,[R0]
	LDR R0,__64_______sdk__str__c__memcopyback__c
	LDRB R2,[R0]
	STRB R2,[R1]
	LDR R1,__65_______sdk__str__c__memcopyback__from
	LDR R0,[R1]
	SUBS R0,#1
	STR R0,[R1]
	LDR R1,__66_______sdk__str__c__memcopyback__to
	LDR R0,[R1]
	SUBS R0,#1
	STR R0,[R1]
	LDR R1,__67_______sdk__str__c__memcopyback__len
	LDR R0,[R1]
	SUBS R0,#1
	STR R0,[R1]
	LDR R0,__68_______sdk__str__c__memcopyback__len
	LDR R1,[R0]
	LDR R2,__69_______sdk__str__c__0
	SUBS R1,R2
	BEQ __70_______sdk__str__c
	BL memcopyback__D__
__70_______sdk__str__c
memcopyback__E__	EQU $+1
	POP {PC}
	ALIGN 4
__61_______sdk__str__c__memcopyback__from
	DCD memcopyback__from
__62_______sdk__str__c__memcopyback__c
	DCD memcopyback__c
__63_______sdk__str__c__memcopyback__to
	DCD memcopyback__to
__64_______sdk__str__c__memcopyback__c
	DCD memcopyback__c
__65_______sdk__str__c__memcopyback__from
	DCD memcopyback__from
__66_______sdk__str__c__memcopyback__to
	DCD memcopyback__to
__67_______sdk__str__c__memcopyback__len
	DCD memcopyback__len
__68_______sdk__str__c__memcopyback__len
	DCD memcopyback__len
__69_______sdk__str__c__0
	DCD 0
strcp	EQU $+1
	PUSH {LR}
	LDR R1,__71_______sdk__str__c__0
	LDR R0,__72_______sdk__str__c__strcp__i
	STR R1,[R0]
	MOVS R1,#TRUE
	LDR R0,__73_______sdk__str__c__strcp__ok
	STRB R1,[R0]
strcp__C__	EQU $+1
	LDR R0,__74_______sdk__str__c__strcp__s1
	LDR R1,[R0]
	LDR R0,__75_______sdk__str__c__strcp__i
	LDR R2,[R0]
	ADDS R1,R2
	LDRB R1,[R1]
	LDR R0,__76_______sdk__str__c__strcp__c1
	STRB R1,[R0]
	LDR R0,__77_______sdk__str__c__strcp__c1
	LDRB R1,[R0]
	LDR R0,__78_______sdk__str__c__strcp__s2
	LDR R2,[R0]
	LDR R0,__79_______sdk__str__c__strcp__i
	LDR R3,[R0]
	ADDS R2,R3
	LDRB R2,[R2]
	SUBS R1,R2
	BNE __80_______sdk__str__c
	BL strcp__E__
__80_______sdk__str__c
	MOVS R1,#FALSE
	LDR R0,__81_______sdk__str__c__strcp__ok
	STRB R1,[R0]
	B strcp__D__
strcp__E__	EQU $+1
	LDR R1,__82_______sdk__str__c__strcp__i
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R0,__83_______sdk__str__c__strcp__c1
	LDRB R1,[R0]
	SUBS R1,#'\0'
	BEQ __84_______sdk__str__c
	BL strcp__C__
__84_______sdk__str__c
strcp__D__	EQU $+1
	LDR R0,__85_______sdk__str__c__strcp__ok
	LDRB R1,[R0]
	POP {PC}
	ALIGN 4
__71_______sdk__str__c__0
	DCD 0
__72_______sdk__str__c__strcp__i
	DCD strcp__i
__73_______sdk__str__c__strcp__ok
	DCD strcp__ok
__74_______sdk__str__c__strcp__s1
	DCD strcp__s1
__75_______sdk__str__c__strcp__i
	DCD strcp__i
__76_______sdk__str__c__strcp__c1
	DCD strcp__c1
__77_______sdk__str__c__strcp__c1
	DCD strcp__c1
__78_______sdk__str__c__strcp__s2
	DCD strcp__s2
__79_______sdk__str__c__strcp__i
	DCD strcp__i
__81_______sdk__str__c__strcp__ok
	DCD strcp__ok
__82_______sdk__str__c__strcp__i
	DCD strcp__i
__83_______sdk__str__c__strcp__c1
	DCD strcp__c1
__85_______sdk__str__c__strcp__ok
	DCD strcp__ok
stradd	EQU $+1
	PUSH {LR}
	LDR R0,__86_______sdk__str__c__stradd__len
	LDR R1,[R0]
	LDR R2,__87_______sdk__str__c___STRMAX
	SUBS R1,R2
	BCC __88_______sdk__str__c
	BL stradd__D__
__88_______sdk__str__c
	LDR R0,__89_______sdk__str__c__stradd__s
	LDR R1,[R0]
	LDR R0,__90_______sdk__str__c__stradd__len
	LDR R2,[R0]
	ADDS R1,R2
	LDR R0,__91_______sdk__str__c__stradd__c
	LDRB R2,[R0]
	STRB R2,[R1]
	LDR R1,__92_______sdk__str__c__stradd__len
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
stradd__D__	EQU $+1
	LDR R0,__93_______sdk__str__c__stradd__len
	LDR R1,[R0]
	MOVS R1,R1
	MOVS R1,R1
	POP {PC}
	ALIGN 4
__86_______sdk__str__c__stradd__len
	DCD stradd__len
__87_______sdk__str__c___STRMAX
	DCD _STRMAX
__89_______sdk__str__c__stradd__s
	DCD stradd__s
__90_______sdk__str__c__stradd__len
	DCD stradd__len
__91_______sdk__str__c__stradd__c
	DCD stradd__c
__92_______sdk__str__c__stradd__len
	DCD stradd__len
__93_______sdk__str__c__stradd__len
	DCD stradd__len
strcplow	EQU $+1
	PUSH {LR}
	LDR R1,__94_______sdk__str__c__0
	LDR R0,__95_______sdk__str__c__strcplow__i
	STR R1,[R0]
	MOVS R1,#TRUE
	LDR R0,__96_______sdk__str__c__strcplow__ok
	STRB R1,[R0]
strcplow__C__	EQU $+1
	LDR R0,__97_______sdk__str__c__strcplow__s1
	LDR R1,[R0]
	LDR R0,__98_______sdk__str__c__strcplow__i
	LDR R2,[R0]
	ADDS R1,R2
	LDRB R1,[R1]
	LDR R0,__99_______sdk__str__c__strcplow__c1
	STRB R1,[R0]
	LDR R0,__100_______sdk__str__c__strcplow__s2
	LDR R1,[R0]
	LDR R0,__101_______sdk__str__c__strcplow__i
	LDR R2,[R0]
	ADDS R1,R2
	LDRB R1,[R1]
	LDR R0,__102_______sdk__str__c__strcplow__c2
	STRB R1,[R0]
	LDR R0,__103_______sdk__str__c__strcplow__c1
	LDRB R1,[R0]
	MOVS R2,#'A'
	SUBS R1,R2
	SBCS R1,R1
	EORS R1,R7
	LDR R0,__104_______sdk__str__c__strcplow__c1
	LDRB R2,[R0]
	MOVS R3,#'Z'
	SUBS R3,R2
	SBCS R2,R2
	EORS R2,R7
	ANDS R1,R2
	BNE __105_______sdk__str__c
	BL strcplow__E__
__105_______sdk__str__c
	LDR R0,__106_______sdk__str__c__strcplow__c1
	LDRB R1,[R0]
	MOVS R2,#0x20
	ORRS R1,R2
	LDR R0,__107_______sdk__str__c__strcplow__c1
	STRB R1,[R0]
strcplow__E__	EQU $+1
	LDR R0,__108_______sdk__str__c__strcplow__c2
	LDRB R1,[R0]
	MOVS R2,#'A'
	SUBS R1,R2
	SBCS R1,R1
	EORS R1,R7
	LDR R0,__109_______sdk__str__c__strcplow__c2
	LDRB R2,[R0]
	MOVS R3,#'Z'
	SUBS R3,R2
	SBCS R2,R2
	EORS R2,R7
	ANDS R1,R2
	BNE __110_______sdk__str__c
	BL strcplow__G__
__110_______sdk__str__c
	LDR R0,__111_______sdk__str__c__strcplow__c2
	LDRB R1,[R0]
	MOVS R2,#0x20
	ORRS R1,R2
	LDR R0,__112_______sdk__str__c__strcplow__c2
	STRB R1,[R0]
strcplow__G__	EQU $+1
	LDR R0,__113_______sdk__str__c__strcplow__c1
	LDRB R1,[R0]
	LDR R0,__114_______sdk__str__c__strcplow__c2
	LDRB R2,[R0]
	SUBS R1,R2
	BNE __115_______sdk__str__c
	BL strcplow__I__
__115_______sdk__str__c
	MOVS R1,#FALSE
	LDR R0,__116_______sdk__str__c__strcplow__ok
	STRB R1,[R0]
	B strcplow__D__
strcplow__I__	EQU $+1
	LDR R1,__117_______sdk__str__c__strcplow__i
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R0,__118_______sdk__str__c__strcplow__c1
	LDRB R1,[R0]
	SUBS R1,#'\0'
	BEQ __119_______sdk__str__c
	BL strcplow__C__
__119_______sdk__str__c
strcplow__D__	EQU $+1
	LDR R0,__120_______sdk__str__c__strcplow__ok
	LDRB R1,[R0]
	POP {PC}
	ALIGN 4
__94_______sdk__str__c__0
	DCD 0
__95_______sdk__str__c__strcplow__i
	DCD strcplow__i
__96_______sdk__str__c__strcplow__ok
	DCD strcplow__ok
__97_______sdk__str__c__strcplow__s1
	DCD strcplow__s1
__98_______sdk__str__c__strcplow__i
	DCD strcplow__i
__99_______sdk__str__c__strcplow__c1
	DCD strcplow__c1
__100_______sdk__str__c__strcplow__s2
	DCD strcplow__s2
__101_______sdk__str__c__strcplow__i
	DCD strcplow__i
__102_______sdk__str__c__strcplow__c2
	DCD strcplow__c2
__103_______sdk__str__c__strcplow__c1
	DCD strcplow__c1
__104_______sdk__str__c__strcplow__c1
	DCD strcplow__c1
__106_______sdk__str__c__strcplow__c1
	DCD strcplow__c1
__107_______sdk__str__c__strcplow__c1
	DCD strcplow__c1
__108_______sdk__str__c__strcplow__c2
	DCD strcplow__c2
__109_______sdk__str__c__strcplow__c2
	DCD strcplow__c2
__111_______sdk__str__c__strcplow__c2
	DCD strcplow__c2
__112_______sdk__str__c__strcplow__c2
	DCD strcplow__c2
__113_______sdk__str__c__strcplow__c1
	DCD strcplow__c1
__114_______sdk__str__c__strcplow__c2
	DCD strcplow__c2
__116_______sdk__str__c__strcplow__ok
	DCD strcplow__ok
__117_______sdk__str__c__strcplow__i
	DCD strcplow__i
__118_______sdk__str__c__strcplow__c1
	DCD strcplow__c1
__120_______sdk__str__c__strcplow__ok
	DCD strcplow__ok
hash	EQU $+1
	PUSH {LR}
	LDR R1,__121_______sdk__str__c__0x0000
	LDR R0,__122_______sdk__str__c__hash__hash
	STR R1,[R0]
	MOVS R1,#0x00
	LDR R0,__123_______sdk__str__c__hash__c
	STRB R1,[R0]
hash__B__	EQU $+1
	LDR R0,__124_______sdk__str__c__hash__c
	LDRB R1,[R0]
	LDR R0,__125_______sdk__str__c__hash__hash
	LDR R2,[R0]
	ANDS R2,R7
	EORS R1,R2
	LDR R0,__126_______sdk__str__c__hash__c
	STRB R1,[R0]
	LDR R0,__127_______sdk__str__c__hash__hash
	LDR R1,[R0]
	LDR R0,__128_______sdk__str__c__hash__hash
	LDR R2,[R0]
	ADDS R1,R2
	LDR R0,__129_______sdk__str__c__hash__hash
	STR R1,[R0]
	LDR R0,__130_______sdk__str__c__hash__c
	LDRB R1,[R0]
	LDR R0,__131_______sdk__str__c__hash__hash
	LDR R2,[R0]
	ANDS R2,R7
	ADDS R1,R2
	ANDS R1,R7
	LDR R0,__132_______sdk__str__c__hash__c
	STRB R1,[R0]
	LDR R0,__133_______sdk__str__c__hash__hash
	LDR R1,[R0]
	LDR R2,__134_______sdk__str__c__0xff00
	ANDS R1,R2
	LDR R0,__135_______sdk__str__c__hash__c
	LDRB R2,[R0]
	ADDS R1,R2
	LDR R0,__136_______sdk__str__c__hash__hash
	STR R1,[R0]
	LDR R0,__137_______sdk__str__c__hash__pstr
	LDR R1,[R0]
	LDRB R1,[R1]
	LDR R0,__138_______sdk__str__c__hash__c
	STRB R1,[R0]
	LDR R1,__139_______sdk__str__c__hash__pstr
	LDR R0,[R1]
	ADDS R0,#1
	STR R0,[R1]
	LDR R0,__140_______sdk__str__c__hash__c
	LDRB R1,[R0]
	SUBS R1,#0x00
	BEQ __141_______sdk__str__c
	BL hash__B__
__141_______sdk__str__c
hash__C__	EQU $+1
	LDR R0,__142_______sdk__str__c__hash__hash
	LDR R1,[R0]
	MOVS R1,R1
	MOVS R1,R1
	POP {PC}
	ALIGN 4
__121_______sdk__str__c__0x0000
	DCD 0x0000
__122_______sdk__str__c__hash__hash
	DCD hash__hash
__123_______sdk__str__c__hash__c
	DCD hash__c
__124_______sdk__str__c__hash__c
	DCD hash__c
__125_______sdk__str__c__hash__hash
	DCD hash__hash
__126_______sdk__str__c__hash__c
	DCD hash__c
__127_______sdk__str__c__hash__hash
	DCD hash__hash
__128_______sdk__str__c__hash__hash
	DCD hash__hash
__129_______sdk__str__c__hash__hash
	DCD hash__hash
__130_______sdk__str__c__hash__c
	DCD hash__c
__131_______sdk__str__c__hash__hash
	DCD hash__hash
__132_______sdk__str__c__hash__c
	DCD hash__c
__133_______sdk__str__c__hash__hash
	DCD hash__hash
__134_______sdk__str__c__0xff00
	DCD 0xff00
__135_______sdk__str__c__hash__c
	DCD hash__c
__136_______sdk__str__c__hash__hash
	DCD hash__hash
__137_______sdk__str__c__hash__pstr
	DCD hash__pstr
__138_______sdk__str__c__hash__c
	DCD hash__c
__139_______sdk__str__c__hash__pstr
	DCD hash__pstr
__140_______sdk__str__c__hash__c
	DCD hash__c
__142_______sdk__str__c__hash__hash
	DCD hash__hash
	END
