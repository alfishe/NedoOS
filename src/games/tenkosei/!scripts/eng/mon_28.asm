        include SUPER_C.inc
M_START:
MON_28
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Kenjirou:  I'm home..."
	DB	NEXT
	DB	"Akemi:  Hi, glad you're back."
	DB	NEXT
	DB	"Kenjirou:  Did Motoka come home?"
	DB	NEXT
	DB	"Akemi:  She's not home yet."
	DB	NEXT
	DB	"Kenjirou:  ...I see."
	DB	NEXT
	DB	"Akemi:  I'm sure you don't need to worry yourself about her."
	DB	NEXT
	DB	"Kenjirou:  .............."
	DB	NEXT
	DB	"Akemi:  She can be really spoiled sometimes, but when you get down to it, she's a good girl." 
	DB	NEXT
	DB	"Kenjirou:  Yes, but..."
	DB	T_WAIT,	3
	DB	" She's been hanging around with some pretty shady characters lately..."
	DB	NEXT
	DB	"Akemi:  Kenjirou-kun, please don't bad-mouth Motoka's friends like that."
	DB	NEXT
	DB	"Kenjirou:  Bad-mouthing?"
	DB	T_WAIT,	3
	DB	" ...I didn't mean to do anything like that. I'm just worried about Motoka."
	DB	NEXT
	DB	"Akemi:  I know that. I know some of her friends might not be the best influence, but they're probably fine." 
	DB	NEXT
	DB	"Kenjirou:  Aren't you worried about Motoka?"
	DB	NEXT
	DB	"Akemi:  No, not a bit. I believe in Motoka, and I know she'll be fine. Shall we have dinner?" 
	DB	NEXT
	DB	"Kenjirou:  ............"
	DB	NEXT
	DB	"Akemi:  Or do you want to wait for Motoka?"
	DB	NEXT
	DB	"Just then, the insect that lived in my stomach let out a growl. "
	DB	NEXT
	DB	"Akemi:  Heh, I guess we should eat now."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"We finished eating, and I took a bath, yelping with pain as the water hit my bruises. Then I fell into bed."
	DB	NEXT
	DB	"Akemi-san said she wasn't worried about Motoka..."
	DB	T_WAIT,	3
	DB	" But I'm sure she is. There's no way a mother couldn't not be."
	DB	NEXT
	DB	"Damn, Motoka's really late again."
	DB	T_WAIT,	3
	DB	" Where could she be?"
	DB	NEXT
	DB	CLS
	DB	"I look at the clock on the wall. It reads 12:00 midnight."
	DB	NEXT
	DB	"Just then, my cell-phone started to vibrate on the desk where I'd left it. "
	DB	NEXT
	DB	"I quickly picked up the phone and answered it."
	DB	NEXT
	DB	CLS
	DB	"Terumi:  Ah, Kenjirou."
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai, did you find Motoka?"
	DB	NEXT
	DB	"Terumi:  ...No, I'm sorry." 
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Terumi:  I couldn't find her anywhere." 
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	T_WAIT,	3
	DB	" Thanks for trying, though."
	DB	NEXT
	DB	"Terumi:  Try not to be too upset. I'm sure she'll be fine."
	DB	NEXT
	DB	"Kenjirou:  ...Yes, I'm sure she will be."
	DB	NEXT
	DB	"Terumi:  I'm going to hang up now. Take care."
	DB	NEXT
	DB	"Kenjirou:  Okay. Good night."
	DB	NEXT
	DB	"Terumi:  Good night." 
	DB	NEXT
	DB	"I turned off the phone, and put it back on the desk."
	DB	NEXT
	DB	"Terumi-senpai couldn't find her..."
	DB	T_WAIT,	3
	DB	"I wonder if I should tell this to Akemi-san?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	A1,"TELL AKEMI"
	MENU_SET	A2,"DON'T TELL HER"
	MENU_END
	DB	EXIT
A1:
	DB	"That's a good idea. I'm sure she really is worried about Motoka, and would like some news."
	DB	NEXT
	SINARIO	'MON_29.OVL'
	DB	EXIT
A2:
	DB	"Hmm, it's probably for the best. I don't want to add to her worry."
	DB	NEXT
	DB	"Damn that Motoka. Is she going to stay out all night?"
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Still worried about my sister, I somehow managed to fall asleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_30.OVL'
	DB	EXIT
END