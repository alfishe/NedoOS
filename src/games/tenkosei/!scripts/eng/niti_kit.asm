        include SUPER_C.inc
M_START:
NITI_KIT
	BAK_INIT	'tb_005c',B_NORM
	CDPLAY	22
	DB	"Ah, it's good to be home."
	DB	NEXT
	FLG_IF	MOT_KOKU,'=',1,SEX
	FLG_IF	MOTSUNE,'>=',1,MUSI
	BAK_INIT	'tb_002',B_NORM;‚c‚j
	CDPLAY	9
	DB	"Akemi-san and Motoka are here."
	DB	NEXT
	T_CG	'tt_11_02',MOT_A3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Motoka:  Oniichan, welcome home." 
	DB	NEXT
	DB	"Akemi:  Hello, Kenjirou." 
	DB	NEXT
	DB	"Kenjirou:  Hi."
	DB	NEXT
	GO	TUUJOU
MUSI:
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Welcome home." 
	DB	NEXT
	DB	"Kenjirou:  Hi... Uh, where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She hasn't come home yet." 
	DB	NEXT
TUUJOU:
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	H1,"LOOK AT COLLARBONE"
	MENU_SET	H2,"LOOK AT BREASTS"
	MENU_SET	H3,"LOOK AT STOCKINGS"
	MENU_END
	DB	EXIT
H1:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB	"She's got a great collarbone. I'd love to trace a line of saliva with my tongue over it."
	DB	NEXT
	GO	FUTU
H2:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB	"She's got great breasts. I'd really love to kiss the valley in between them."
	DB	NEXT
	GO	FUTU
H3:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB	"She's got great thighs, and the nylons make them all the more shapely."
	DB	NEXT
	GO	FUTU
AKEM:
	FLG_KI	AKEM_NET,'=',1
	DB	"I'm going to explode!"
	DB	NEXT
FUTU:
	FLG_IF	MOTSUNE,'>=',1,KAE
	DB	"Motoka:  Oniichan, you were looking my mom with lust in your eyes, weren't you?" 
	DB	NEXT
	DB	"Kenjirou:  W- What the fuck!"
	DB	NEXT
	DB	"She was right, but getting caught made me red in the face."
	DB	NEXT
	DB	"Akemi:  Motoka, don't tease your brother like that." 
	DB	NEXT
	DB	"Kenjirou:  A- Anyway, what's for dinner?"
	DB	NEXT
	DB	"Akemi:  A surprise. It'll be ready soon."
	DB	NEXT
	DB	"Motoka:  Ah, you changed the subject!" 
	DB	NEXT
	DB	"Kenjirou:  No, I didn't, I just..."
	DB	NEXT
	DB	"Motoka:  Pervert, pervert! Oniichan's a pervert!" 
	DB	NEXT
	DB	"And that's how the three of us had dinner that evening."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO TUGI
KAE:
	BAK_INIT	'tb_002',B_NORM
	DB	"Akemi:  Fufu... What's wrong?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing."
	DB	NEXT
	DB	"Akemi:  Really?"
	DB	NEXT
	DB	"Kenjirou:  Yep. By the way, don't you think Motoka's really late?"
	DB	NEXT
	DB	"Akemi:  You worry too much."
	DB	NEXT
	DB	"Kenjirou:  You think so?"
	DB	NEXT
	DB	"Akemi:  I'm home..."
	DB	NEXT
	DB	"Motoka's voice echoes from the front door, but she sounds sad somehow."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_02',MOT_B3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Motoka:  Ah, Oniichan..." 
	DB	NEXT
	DB	"Kenjirou:  Welcome home."
	DB	NEXT
	DB	"Akemi:  You came home just in time for dinner."
	DB	NEXT
	DB	"Motoka:  I'm not hungry..." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_20_02',AKE_A2,0
	DB	"With that, Motoka went to her room."
	DB	NEXT
	DB	"Akemi:  I wonder what's wrong with her?"
	DB	NEXT
	DB	"So Akemi-san and I ate our dinner alone that night."
	DB	NEXT
TUGI:
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  Well, I took a bath. Guess I'll go to bed."
	DB	NEXT
	FLG_IF	MOTSUNE,'=',1,MODORU
	FLG_IF	TERUNASI,'=',1,MODORU
	FLG_IF	TER_DEN,'=',1,TEL
MODORU:
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
	DB	EXIT
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	CDPLAY		0
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Uuuu....unnn...?"
	DB	NEXT
	DB	"Slowly, my eyes opened."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  Where am I?"
	DB	NEXT
	DB	"Still confused, I looked around me. I seemed to be in my own room."
	DB	NEXT
	DB	"But what the hell happened?"
	DB	NEXT
	DB	"There was a brown stain on my shirt."
	DB	NEXT
	DB	"Blood? But what happened? Did I have a nosebleed in my sleep or something?"
	DB	NEXT
	DB	"What's happening...?"
	DB	NEXT
	DB	"I must have passed out or something."
	DB	NEXT
	DB	"Someone must have put me in my bed, because I don't remember coming here on my own."
	DB	NEXT
	FLG_IF	TER_DEN,'=',1,TEL
	B_O	B_FADE,C_KURO
	CDPLAY	0
	FLG_KI	HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
	DB	EXIT
TEL:
	FLG_KI	TER_DEN,'=',0
	SINARIO	'MON_40.OVL'
	DB	EXIT
SEX:
	SINARIO	'BUNKI_5.OVL'
END