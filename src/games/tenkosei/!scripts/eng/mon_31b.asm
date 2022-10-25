        include SUPER_C.inc
M_START:
MON_31B
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	DB	"Kenjirou:  I'm home."
	DB	NEXT
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Welcome back."
	DB	NEXT
	DB	"Kenjirou:  Is Motoka home?"
	DB	NEXT
	DB	"Akemi:  No, not yet."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"Akemi:  Do you want to have dinner?"
	DB	NEXT
	DB	"Kenjirou:  No, not yet. Although I am hungry."
	DB	NEXT
	DB	"Akemi:  Okay, I'll make dinner now."
	DB	NEXT
	DB	"Kenjirou:  Okay, thanks. I'll be in my room."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	DB	"Damn that girl Motoka. Where has she got to?"
	DB	NEXT
	DB	"I wonder if she was in that hotel after all?"
	DB	NEXT
	DB	"No, I don't think so."
	DB	NEXT
	DB	"At least, I don't want to believe it. I don't know what to believe anymore."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	F_O	B_NORM,C_KURO
	DB	"Huh? I guess I fell asleep."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"What? There's some noise coming from the living room. I'd better go check it out."
	DB	NEXT
	SINARIO	'MON_32.OVL'
	DB	EXIT
END