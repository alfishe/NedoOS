        include SUPER_C.inc
M_START:
MON_11
	CDPLAY		14
	F_O B_NORM,C_KURO
	DB	"I head for the music room. As I approach, the sound of piano music gets louder."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB	"I stand in front of the door to the music room. I then move to open it."
	DB	NEXT
	EVENT_CG 'ti_049',B_NORM,74
	SWAIT
	CDPLAY	13
	DB	"Entering, I see the woman of my fantasy,  Shiho Kashima, playing passionately at the piano. She hasn't noticed me entering."
	DB	T_WAIT, 20
	DB	CLS
	DB	"Kenjirou:  ... (Kashima-san?)"
	DB	T_WAIT, 10
	DB	CLS
	DB	"Kenjirou:  ...I wonder why I feel so strange? I've never heard the song before, but it seems so familiar to me."
	DB	T_WAIT, 20
	DB	CLS
	DB	"I stare dumbly at her piano playing, unable to move in the face of her beautiful performance."
	DB	T_WAIT, 30
	EWAIT	160
	DB	CLS
	DB	"Shiho:  Ah, Kondo-kun..."
	DB	NEXT
	DB	"Kashima-san finally notices me, and stands. "
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	CDPLAY		10
	T_CG	'tt_02_16',SIH_A2,0
	DB	"Kenjirou:  It's a very pretty song."
	DB	NEXT
	DB	"Shiho:  Really? Do you know this song?"
	DB	NEXT
	DB	"Kenjirou:  Eh? No, I don't."
	DB	NEXT
	DB	"Shiho:  That's not surprising. I wrote it myself."
	DB	NEXT
	DB	"She finished speaking, and an uncomfortable silence pervaded the room."
	DB	NEXT
	DB	"D- Did I say something wrong?"
	DB	NEXT
	DB	"Kenjirou:  ...But somehow, I feel like I've heard it before, somewhere..."
	DB	T_WAIT, 5
	DB	" It's weird, but I'm sure of it."
	DB	NEXT
	DB	"Shiho:  Really?"
	DB	NEXT
	DB	"She looks at me with a puzzled expression."
	DB	NEXT
	DB	"Kenjirou:  I'm serious."
	DB	NEXT
	DB	"At my words, she looked embarrassed."
	DB	NEXT
	DB	"Just then, she looked so much like my other Shiho, the Shiho of my fantasy, that I couldn't do anything but stare."
	DB	NEXT
	DB	"Shiho:  ...Did you like it? My song."
	DB	NEXT
	DB	"Kenjirou:  Eh? Y- Yes, it was really good."
	DB	NEXT
	DB	"Shiho:  I'm happy." 
	DB	NEXT
	DB	"She smiled, her eyes twinkling."
	DB	NEXT
	DB	"Shiho:  Um, I..."
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Shiho:  I'll be playing tomorrow after school, too. If you want, you can come by and listen to me playing."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	T_WAIT, 5
	DB	" Sure, I'll come by."
	DB	NEXT
	DB	"Shiho:  Really?" 
	DB	NEXT
	DB	"Kenjirou:  Sure. It's a promise."
	DB	NEXT
	DB	"Shiho:  I'll be waiting here tomorrow, then."
	DB	NEXT
	DB	"With that, she left the music room."
	DB	NEXT
	TATI_ERS	;Tt_02
	DB	"There's no reason for me to stay here. Guess I'll leave."
	DB	NEXT
	FLG_KI	SIHO_PIA,'=',1
	CDPLAY		14
	BAK_INIT 'tb_034b',B_NORM 
	DB	"I leave the music room. Outside, the sun has started to set."
	DB	NEXT
	DB	"Guess I'll go home now..."
	DB	NEXT
	DB	"I leave the school."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"As I walk home, the sun sets completely and the sky goes completely dark. "
	DB	NEXT
	DB	"I guess I don't have to go straight home..."
	DB	NEXT
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Where should I go?"
	DB	NEXT
	FLG_KI W,'=',-1
	FLG_IF TEMP02,'=',0,SA_1
	FLG_KI W,'DOWN',0
SA_1:
	FLG_IF TEMP03,'=',0,SA_2
	FLG_KI W,'DOWN',1
SA_2:
	FLG_IF TEMP04,'=',0,SA_3
	FLG_KI W,'DOWN',2
SA_3:
	FLG_IF TEMP05,'=',0,SA_4
	FLG_KI W,'DOWN',3
SA_4:
	FLG_IF TEMP06,'=',0,SA_5
	FLG_KI W,'DOWN',4
SA_5:
	FLG_IF TEMP07,'=',0,SA_6
	FLG_KI W,'DOWN',5
SA_6:
	MENU_S 2,W,-1
	MENU_SET	F1,"MOVIE THEATRE"
	MENU_SET	F2,"LINGERIE PUB"
	MENU_SET	F3,"PARK"
	MENU_SET	F4,"HOTEL"
	MENU_SET	F5,"BAR"
	MENU_SET	F6,"COFFEE SHOP"
	MENU_SET	F7,"HOME"
	MENU_END
	DB	EXIT
F1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Guess I'll go see a movie."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"This movie theatre is really run-down."
	DB	NEXT
	DB	"It's on a side-street like this, far from the station. It's not surprising that it would be run-down like this."
	DB	NEXT
	DB	"There's no movie I really want to see. Guess there's no need to stay here."
	DB	NEXT
	GO MATI
F2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"That's right, there's a lingerie pub around here somewhere. Guess I'll go check it out."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"This is a great place. They really understand human nature here."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1 
	DB	"Tetsuya:  What are you doing here?"
	DB	NEXT
	DB	"Tetsuya appears in front of me, a questioning expression on his face."
	DB	NEXT
	DB	"Kenjirou:  I could ask you the same question?"
	DB	NEXT
	DB	"Tetsuya:  Me? I was, um, just passing by for a look..."
	DB	NEXT
	DB	"Kenjirou:  Really?"
	DB	NEXT
	DB	"Tetsuya:  This place is great, don't you think?"
	DB	NEXT
	DB	"Kenjirou:  I guess."
	DB	NEXT
	DB	"Tetsuya:  I mean, any man would love to go inside, just once." 
	DB	NEXT
	DB	"Kenjirou:  I guess."
	DB	NEXT
	DB	"Tetsuya:  I mean, just once, that's all it would take... Then I could die satisfied." 
	DB	NEXT
	DB	"Tetsuya stared at the lingerie pub sign, a puppy-like longing in his eyes. He's in his own world."
	DB	NEXT
	DB	"Guess I should leave him be."
	DB	NEXT
	GO MATI
F3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"The park, at night? Sounds pretty erotic."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM 
	DB	"There are many couples walking here. In the bush, there are probably more, enjoying a private moment together."
	DB	NEXT
	DB	"Terumi:  What are you doing here?"
	DB	NEXT
	DB	"I've heard the voice before. I turn to see Terumi-senpai standing there."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0 
	DB	"Kenjirou:  Ah, Terumi-senpai."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	G1,"LOOK AT TITS"
	MENU_SET	G2,"LOOK AT ASS"
	MENU_SET	G3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
G1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,WW_1
WW_2:
	DB	"Her breasts are wonderful, although I can't see them all that well through her folded arms."
	DB	NEXT
	GO BODY
WW_1:
	FLG_KI TER_NET,'=',1
	GO WW_2
G2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,WW_3
WW_4:
	DB	"A lovely ass. Nice rounding curves from her waist."
	DB	NEXT
	GO BODY
WW_3:
	FLG_KI TER_NET,'=',1
	GO WW_4
G3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,WW_5
WW_6:
	DB	"Her thighs are soft and supple."
	DB	NEXT
	GO BODY
WW_5:
	FLG_KI TER_NET,'=',1
	GO WW_6
BODY:
	DB	"Terumi:  What's wrong? You got quiet all of the sudden." 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing. I was just wondering what you were doing here alone."
	DB	NEXT
	DB	"Terumi:  Me? I'm just out for a walk."
	DB	NEXT
	DB	"Kenjirou:  Here? At night?"
	DB	NEXT
	DB	"Terumi:  Are you worried about me?" 
	DB	NEXT
	DB	"She smiles shyly."
	DB	NEXT
	DB	"Kenjirou:  Yes, I was worried that you might get attacked..."
	DB	NEXT
	DB	"Terumi:  W- What? Why you...?"
	DB	NEXT
	DB	"Kenjirou:  I- I'm sorry!"
	DB	NEXT
	DB	"Fearing the iron fist of Terumi-senpai, I ran from the park."
	DB	NEXT
	GO MATI
F4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"The love hotel? I've never been inside..."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"A gaudy sign is standing in front of the hotel."
	DB	NEXT
	DB	"Guess there's no reason for me to be standing here alone."
	DB	NEXT
	GO MATI
F5:
	FLG_KI TEMP06,'=',1
	DB	"I'm sure it's not open yet. It's much too early."
	DB	NEXT
	DB	"I should go back."
	DB	NEXT
	GO MATI
F6:
	FLG_KI TEMP07,'=',1
	DB	"Coffee shop? I seem to remember there was one around here somewhere."
	DB	NEXT
	GO MATI
F7:
	DB	"I shouldn't be puttering around here. Guess I'll go home."
	DB	NEXT
	DB	"I head for home."
	DB	NEXT
	GO JITAKU2
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Guess I'll go home now."
	DB	NEXT
	DB	"I head for home."
	DB	NEXT
JITAKU2:
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ah, it's good to be home."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		9
	DB	"Akemi-san and Motoka are here."
	DB	NEXT
	T_CG 'tt_11_02',MOT_C3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Motoka:  Oniichan, welcome home."
	DB	NEXT
	DB	"Akemi:  Hello, Kenjirou-kun."
	DB	NEXT
	DB	"Kenjirou:  Thanks."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	H1,"LOOK AT COLLARBONE"
	MENU_SET	H2,"LOOK AT TITS"
	MENU_SET	H3,"LOOK AT STOCKINGS"
	MENU_END
	DB	EXIT
H1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',11
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,SS_1
SS_2:
	DB	"She's got a sexy collarbone. It's strong and sharp and adds beauty to Akemi-san."
	DB	NEXT
	GO BODY_2
SS_1:
	FLG_KI AKEM_NET,'=',1
	GO SS_2
H2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,SS_3
SS_4:
	DB	"Her tits are soft and well-shaped. I long to lie my cock in that heavenly valley..."
	DB	NEXT
	GO BODY_2
SS_3:
	FLG_KI AKEM_NET,'=',1
	GO SS_4
H3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,SS_5
SS_6:
	DB	"Her stocking covered legs are shapely and sexy, and cause an immediate response in my cock."
	DB	NEXT
	GO BODY_2
SS_5:
	FLG_KI AKEM_NET,'=',1
	GO SS_6
BODY_2:
	DB	"Motoka:  Ah! Oniichan, you're looking at my mother with lust in your eyes." 
	DB	NEXT
	DB	"Kenjirou:  I- I'm not!"
	DB	NEXT
	DB	"She was right. But I couldn't admit it."
	DB	NEXT
	DB	"Akemi:  Motoka, don't tease your brother like that."
	DB	NEXT
	DB	"Kenjirou:  A- Anyway, what's for dinner tonight?"
	DB	NEXT
	DB	"Akemi:  It'll be ready soon."
	DB	NEXT
	DB	"Motoka:  Ah, Oniichan, you changed the subject." 
	DB	NEXT
	DB	"Kenjirou:  I didn't. I-"
	DB	NEXT
	DB	"Motoka:  Pervert! Oniichan's a pervert!" 
	DB	NEXT
	DB	"That was how the three of us spent the evening that night."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"I took a bath, so I guess I'll go to bed now."
	DB	NEXT
	DB	"I'll go see Kashima-san tomorrow after school. I'm looking forward to it."
	DB	NEXT
	DB	"I'm sure I've heard the song she was playing somewhere before, though.... Oh well. I'll think about it tomorrow."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_12.OVL'
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Uuunn?"
	DB	NEXT
	DB	"I slowly opened my eyelids."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  Where am I?"
	DB	NEXT
	DB	"I look around me. I appear to be back in my room."
	DB	NEXT
	DB	"I wonder what happened?"
	DB	NEXT
	DB	"There's a brown stain on my clothes."
	DB	NEXT
	DB	"Blood? That's right, I had a nosebleed..."
	DB	NEXT
	DB	"I must have collapsed, lost consciousness."
	DB	NEXT
	DB	"Someone must have brought me back to my room."
	DB	NEXT
	DB	"But who? Oh well, I guess it's not important now."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_12.OVL'
END