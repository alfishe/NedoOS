        include SUPER_C.inc
M_START:
ER
	CDPLAY		14
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	FLG_KI	YOKU,'/',2
	FLG_KI	SIZ_ATTA,'=',1
	EVENT_CG	'th_072',B_FADE,35
	DB	"Kenjirou:  Mm? Shizuka-sensei?"
	DB	NEXT
	DB	"Shizuka:  Are you awake?"
	DB	NEXT
	DB	"Kenjirou:  W- What happened?"
	DB	NEXT
	DB	"Shizuka:  You had a nose bleed, and collapsed."
	DB	NEXT
	DB	"Kenjirou:  .............."
	DB	NEXT
	DB	"Shizuka:  You're young, so you have to get that kind of stuff out of your system. You should try masturbation."
	DB	NEXT
	DB	"Kenjirou:  Hahaha...yes..."
	DB	NEXT
	DB	"Shizuka:  But you're pretty good. You managed to have a nosebleed but not get any blood on your clothes."
	DB	NEXT
	DB	"Kenjirou:  Yes, I'm good at that."
	DB	NEXT
	DB	"Kenjirou:  Well, I'll be going now."
	DB	NEXT
	DB	"Shizuka:  Be careful not to get any more nosebleeds."
	DB	NEXT
	DB	"Kenjirou:  I will."
	DB	NEXT
	DB	"I leave the nurse's office."
	DB	NEXT
	JTBL HOK
	DW	FF_0,FF_1,FF_2,FF_3,FF_4,FF_5,FF_6,FF_7,-1
	DB	EXIT
FF_0:
FF_1:
	SINARIO 'BUNKI_1.OVL'
FF_2:
	SINARIO 'MON_10.OVL'
FF_3:
	SINARIO 'MON_14.OVL'
FF_4:
	SINARIO 'MON_18.OVL'
FF_5:
	SINARIO 'MON_23.OVL'
FF_6:
	SINARIO 'NITI_HIR.OVL'
FF_7:
	SINARIO 'NITI_HOK.OVL'
END