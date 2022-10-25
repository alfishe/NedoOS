        include SUPER_C.inc
M_START:
ER2
	CDPLAY		14
	EVENT_CG	'th_072',B_FADE,35
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	DB	"I see a flash of red, then the world goes dark."
	DB	NEXT
	DB	"Kenjirou:  Uuu..."
	DB	NEXT
	DB	"Shizuka:  Kya!!"
	DB	NEXT
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	FLG_KI	YOKU,'/',2
	DB	"Kenjirou:  Where...where am I?"
	DB	NEXT
	DB	"Kenjirou:  What happened?"
	DB	NEXT
	DB	"I slowly open my eyes."
	DB	NEXT
	EVENT_CG	'th_072',B_FADE,35
	DB	"Kenjirou:  Huh? Shizuka-sensei?"
	DB	NEXT
	DB	"Shizuka:  Are you awake?"
	DB	NEXT
	DB	"Kenjirou:  Y- Yes. Um, what happened?"
	DB	NEXT
	DB	"Shizuka:  You had a nosebleed and collapsed." 
	DB	NEXT
	DB	"Kenjirou:  A nosebleed?"
	DB	NEXT
	DB	"Shizuka:  Yes. You surprised me. It was like a fountain. It took a long time to get it all cleaned up."
	DB	NEXT
	DB	"Kenjirou:  I- I'm sorry..."
	DB	NEXT
	DB	"Shizuka:  Well, I'll forgive you, since you got excited by looking at me. But you should masturbate every day"
    DB  " -- it's unhealthy not to."
	DB	NEXT
	DB	"Kenjirou:  O- Okay, thanks. Well, I guess I'll be going now."
	DB	NEXT
	DB	"I leave the nurse's office."
	DB	NEXT
	JTBL HOK
	DW	FF_0,FF_1,FF_1,FF_3,FF_4,FF_5,FF_6,FF_7,-1
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