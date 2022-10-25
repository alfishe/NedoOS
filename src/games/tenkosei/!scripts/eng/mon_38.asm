        include SUPER_C.inc
M_START:
MON_38
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  ..........."
	DB	T_WAIT,	3
	DB	"Guess it's time to wake up."
	DB	NEXT
	DB	"I check the clock. A little past noon."
	DB	NEXT
	DB	"Kenjirou:  Wow, that's late even for me..."
	DB	NEXT
	DB	"It's a day off today, so I should get some more sleep."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"What? It's dark outside."
	DB	NEXT
	DB	"I wonder what's for dinner."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"There's school tomorrow. I'd better prepare by sleeping some more."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	FLG_IF JUMP,'=',26,FF_2
	SINARIO	'MON_39.OVL'
	DB	EXIT
FF_2:
	SINARIO 'JUMP.OVL'
	DB	EXIT
END