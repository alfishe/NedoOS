        include SUPER_C.inc
M_START:
MON_31C
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI	 YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O	B_NORM,C_KURO
	DB	"Kenjirou:  ...Uuun?"
	DB	NEXT
	DB	"I lift my heavy eyelids and look around."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Where am I?"
	DB	NEXT
	DB	"I look around. I seem to be in my own room."
	DB	NEXT
	DB	"What happened?"
	DB	NEXT
	DB	"There's a brown stain on my clothes."
	DB	NEXT
	DB	"Blood? Oh yeah, I had a nosebleed..."
	DB	NEXT
	DB	"But what happened after that?"
	DB	NEXT
	DB	"I must have lost consciousness."
	DB	NEXT
	DB	"Then someone must have brought me back here."
	DB	NEXT
	DB	"It must have been that girl. But wait, she didn't know where I live? Hmm, oh well. No sense in worrying about it."
	DB	NEXT
	DB	"I'm in the middle of changing my clothes when suddenly I hear I hear a noise coming from downstairs."
	DB	NEXT
	DB	"Kenjirou:  What's that?"
	DB	NEXT
	DB	"I finished getting dressed and head down to the dining kitchen."
	DB	NEXT
	SINARIO	'MON_32.OVL'
	DB	EXIT
END