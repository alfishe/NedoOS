        include SUPER_C.inc
M_START:
MON_34
	FLG_KI	MOTSUNE,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  Oh well. Guess there's nothing I can do about it."
	DB	NEXT
	DB	"Motoka:  Please, stop!" 
	DB	NEXT
	DB	"Kenjirou:  Eh? That was Motoka's voice."
	DB	NEXT
	DB	"I put my ear against the door."
	DB	NEXT
	DB	"Motoka:  Go home, all of you. Just go home!" 
	DB	NEXT
	DB	"Wow, I've never heard Motoka get this mad."
	DB	NEXT
	DB	"Hiroshi:  Ah, okay. Sorry."
	DB	NEXT
	DB	"I get the feeling that Hiroshi and the others are about to go home."
	DB	NEXT
	DB	"I hear the sound of Motoka running up the stairs to me, and then a door slam."
	DB	NEXT
	DB	"I haven't heard Motoka be so upset before."
	DB	NEXT
	DB	"I haven't been talking to her much these days. I guess I'll go see how she is."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"I leave my room, and knock on her door."
	DB	NEXT
	DB	"I usually just knock casually on her door, but for some reason I hesitated this time."
	DB	NEXT
	DB	"Then I knocked on the door, twice."
	DB	NEXT
	;WAV	'Se_no'
	DB	"Silence. "
	DB	NEXT
	DB	"I went to knock again."
	DB	NEXT
	DB	"Suddenly the door to Motoka's room opened."
	DB	NEXT
	BAK_INIT	'tb_003',B_NORM
	CDPLAY		20
	T_CG	'tt_21_03',MOT_B2,0
	DB	"Motoka:  O- Oniichan..." 
	DB	NEXT
	DB	"Kenjirou:  Motoka, um... I was just wondering what was wrong? I heard you shout."
	DB	NEXT
	DB	"Motoka:  Eh? Oh, Hara-senpai's friends..."
	DB	NEXT
	DB	"Kenjirou:  He brought friends in there with you?"
	DB	NEXT
	DB	"Motoka:  They were horsing around, opening the drawers to my dresser and stuff..."
	DB	NEXT
	DB	"Kenjirou:  Why did you shout like that?"
	DB	NEXT
	DB	"Motoka:  ..............." 
	DB	NEXT
	DB	"Kenjirou:  You know, Motoka..."
	DB	NEXT
	DB	"Motoka:  I'm sorry." 
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Motoka:  What you want to say to me. I understand." 
	DB	NEXT
	DB	"Kenjirou:  Okay. Why don't you let me know if you're having problems, okay?"
	DB	NEXT
        TATI_ERS ;	-- TATI_ERS   ;;;!!! TODO
	T_CG	'tt_10_03',MOT_A2,0
	DB	"Motoka:  Okay!"
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY		12
	F_O	B_NORM,C_KURO
	DB	"It's been a long time since I've seen Motoka smile like that."
	DB	NEXT
	DB	"I'm sure that Hiroshi and his jerk friends wouldn't think about laying a hand on Motoka after this."
	DB	NEXT
	DB	"Anyway, I'm glad I was able to make up with Motoka."
	DB	NEXT
	DB	"I fell into a deep sleep."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEKINAI
	FLG_KI	ONANI,'=',0
DEKINAI:
	SINARIO	'MON_35.OVL'
	DB	EXIT
END