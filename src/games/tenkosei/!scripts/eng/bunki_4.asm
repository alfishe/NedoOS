        include SUPER_C.inc
M_START:
BUNKI_4
	FLG_KI	GOGATU_6,'=',1
	BAK_INIT	'tb_029',B_NORM
	CDPLAY		19
	T_CG	'tt_11_29',MOT_C2,0
	DB	"Kenjirou:  Motoka..."
	DB	NEXT
	DB	"Motoka:  Ah..." 
	DB	NEXT
	DB	"I pull her towards me, and hold her as hard as I can."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Kenjirou:  Motoka, I..."
	DB	NEXT
	DB	"Motoka:  Oniichan..." 
	DB	NEXT
	DB	"Kenjirou:  I...I finally realized. Seeing you with that guy, I finally realized..."
    DB  " I was so afraid of some other guy taking you away from me."
	DB	NEXT
	DB	"Motoka:  Oniichan... I just wanted... I just wanted to be your girl, yours and no one else's." 
	DB	NEXT
	DB	"Kenjirou:  ...I knew that."
	DB	NEXT
	DB	"Motoka:  Eh?" 
	DB	NEXT
	DB	"Kenjirou:  I knew how you felt about me. I just... I mean, think about it... I'm so sorry, Motoka."
	DB	NEXT
	DB	"Motoka:  It's okay. I'm just happy that you're with me now." 
	DB	NEXT
	DB	"Kenjirou:  Let's go home, okay? Akemi-san's going to be worried."
	DB	NEXT
	DB	"Motoka:  Okay..."
	DB	NEXT
	DB	"We head for home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY		12
	DB	"Man, am I tired..."
	DB	NEXT
	DB	"But I made up with Motoka. That's good news."
	DB	NEXT
	DB	"I slipped into a deeper sleep than usual."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_46.OVL'
	DB	EXIT
END