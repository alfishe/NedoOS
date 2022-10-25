        include SUPER_C.inc
M_START:
MON_22
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"The clock shows a little past ten. Motoka's not home yet."
	DB	NEXT
	DB	"Kenjirou:  Damn you, Motoka..."
	DB	NEXT
	DB	"Suddenly, I hear noises from the foyer. It must be Motoka."
	DB	NEXT
	DB	"I start to get up, but suddenly remember Akemi's words this morning."
	DB	NEXT
	DB	"Kenjirou:  She told me to trust in Motoka..."
	DB	T_WAIT, 3
	DB	" I guess I can do that."
	DB	NEXT
	DB	"Motoka will be alright. I've just got to trust her."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"I turn out the light, and sleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_23.OVL'
END