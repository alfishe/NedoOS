        include SUPER_C.inc
M_START:
NITI_ASA
	FLG_KI	HANAJI,'=',0
	BAK_INIT 'tb_001a',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  Ahhh... What a great sleep."
	DB	NEXT
	DB	"Kenjirou:  Now it's time to change, then go eat breakfast."
	DB	NEXT
	DB	"I change into my uniform, then head into the dining kitchen."
	DB	NEXT
	FLG_IF	MOTSUNE,'!=',0,SAKI
	BAK_INIT 'tb_002',B_NORM
	CDPLAY	9
	T_CG 'tt_10_02',MOT_A1,0
	T_CG 'tt_20_02',AKE_A3,0
	DB	"Motoka and Akemi-san are here."
	DB	NEXT
	DB	"Motoka:  Oniichan, good morning!" 
	DB	NEXT
	DB	"Akemi:  Ah, good morning, Kenjirou-kun." 
	DB	NEXT
	DB	"Kenjirou:  Good morning. Is breakfast ready?"
	DB	NEXT
	DB	"Akemi:  It's here."
	DB	NEXT
	DB	"She puts hot toast and a cup of fresh coffee in front of me."
	DB	NEXT
	TATI_ERS	;Tt_20
	T_CG 'tt_10_02',MOT_A2,0
	DB	"After giving me my breakfast, Akemi-san starts bustling around the house."
	DB	NEXT
	TATI_ERS	;Tt_10
	T_CG 'tt_21_02',MOT_B2,0
	DB	"Motoka:  Oniichan?"
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Motoka:  Do you want to go to school together?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	A1,"GO TOGETHER"
	MENU_SET	A2,"GO ALONE"
	MENU_END
	DB	EXIT
A1:
	DB	"Kenjirou:  Sure, let's go together."
	DB	NEXT
	TATI_ERS
	T_CG 'tt_10_02',MOT_A2,0
	DB	"Motoka:  Really?" 
	DB	NEXT
	DB	"She seems so happy as she pulls on my sleeve to hurry me. She makes me feel like I were her real brother."
	DB	NEXT
	DB	"I leave the house with Motoka."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO GAKU1
A2:
	DB	"Kenjirou:  Sorry, I want to go alone today."
	DB	NEXT
	DB	"Motoka:  Hmph! Why?" 
	DB	NEXT
	DB	"Kenjirou:  It would cramp my style to me seen with my younger sister walking to school. "
        DB      "Wouldn't you feel the same way, if your friends saw you walking with me?"
	DB	NEXT
	T_CG 'tt_21_02',MOT_B2,0
	DB	"Motoka:  ......." 
	DB	T_WAIT,	3
	DB	" I guess so."
	DB	NEXT
	DB	"She looks sad. I wonder if I hadn't said too much. I decide to apologize to her."
	DB	NEXT
	DB	"Kenjirou:  Motoka, I'm sorry."
	DB	NEXT
	DB	"Motoka:  Eh? Oh, don't worry about it. I'll go alone, too." 
	DB	NEXT
	TATI_ERS	;Tt_21
	DB	"With that, Motoka leaves the house alone."
	DB	NEXT
	DB	"After finishing my breakfast, I head for school."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	KONBINI
SAKI:
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Kenjirou:  Akemi-san, good morning."
	DB	NEXT
	DB	"Akemi:  Ah, good morning, Kenjirou." 
	DB	NEXT
	DB	"Kenjirou:  Where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She left for school already."
	DB	NEXT
	DB	"Kenjirou:  I see..."
	DB	NEXT
	DB	"I eat the breakfast Akemi-san made for me, and head for school myself."
	DB	NEXT
	B_O	B_FADE,C_KURO
KONBINI:
	BAK_INIT 'tb_006',B_NORM
	CDPLAY	2
	DB	"I stop off at a convenience store on the way to school. I like to pick up my lunch here every day."
	DB	NEXT
	DB	"I go into the store."
	DB	NEXT
	FLG_IF	TERUNASI,'!=',1,WAWAWA
	BAK_INIT	'tb_007',B_NORM
	DB	"Terumi-senpai is usually here, but she's not here today."
	DB	NEXT
	DB	"I think I know why she isn't here..."
	DB	NEXT
	DB	"I buy my lunch, and head for school."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	EKI
WAWAWA:
	BAK_INIT 'tb_007',B_NORM
	CDPLAY	3
	DB	"Terumi-senpai's here."
	DB	NEXT
	DB	"We run into each other almost every day here."
	DB	NEXT
	T_CG 'tt_05_07',TER2,0
	DB	"Kenjirou:  Good morning, Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  Good morning" 
	DB	NEXT
	DB	"Kenjirou:  Are you killing time here again, as usual?"
	DB	NEXT
	DB	"Terumi:  I'm waiting for you, of course."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Terumi:  Just kidding!" 
	DB	NEXT
	DB	"Terumi-senpai smiles cutely at seeing me flustered."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	R1,"INVITE TERUMI"
	MENU_SET	R2,"GO TO SCHOOL"
	MENU_END
	DB	EXIT
R1:
	DB	"Kenjirou:  ......"
	DB	T_WAIT, 5
	DB	"Terumi-senpai, would you like go to school together?"
	DB	NEXT
	DB	"Terumi:  What? Oh, okay. But aren't you going to get anything?"
	DB	NEXT
	DB	"Kenjirou:  Oh, I forgot. I'll get my lunch and be right back."
	DB	NEXT
	DB	"I pick up what I want to eat, and take it to the register. I like to keep it all under 500 yen."
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai, let's go."
	DB	NEXT
	DB	"Terumi:  Okay, let's go."
	DB	NEXT
	DB	"Without even putting what we bought in our packs, we head to school together."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
	GO GAKU1
R2:
	DB	"Kenjirou:  ............"
	DB	T_WAIT, 5
	DB	" Well, bye."
	DB	NEXT
	DB	"Terumi:  Kenjirou, what about your lunch?"
	DB	NEXT
	DB	"Ignoring her voice, I hurry off to school alone, not sure of what had happened."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
EKI:
	BAK_INIT 'tb_009',B_NORM
	CDPLAY	23
	DB	"Kenjirou:  It sure is crowded here."
	DB	NEXT
	DB	"It tires me out to do this every day."
	DB	NEXT
	DB	'Voice:  Kenjirou-kun'
	DB	NEXT
	DB	"I look behind me to see who the other of the voice was."
	DB	NEXT
	T_CG 'tt_02_09',SIH_A2,0
	DB	"Shiho:  Good morning, Kenjirou-kun."
	DB	NEXT
	DB	"Kenjirou:  Ah, it's Shiho. Morning."
	DB	NEXT
	DB	"Shiho:  You don't seem happy to see me."
	DB	NEXT
	DB	"Shiho stands in front of me, frowning."
	DB	NEXT
	DB	"Kenjirou:  Sorry, I didn't mean it that way, believe me."
	DB	NEXT
	DB	"Shiho:  Do you want to go to school..."
	DB	T_WAIT, 5
	DB	"together?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	S1,"GO WITH HER"
	MENU_SET	S2,"GO ALONE"
	MENU_END
	DB	EXIT
S1:
	DB	"Well, I don't want to go alone..."
	DB	NEXT
	DB	"Kenjirou:  Okay, let's go."
	DB	NEXT
	DB	"Shiho:  Okay!" 
	DB	NEXT
	DB	"Shiho at my side, I head for school."
	DB	NEXT
	GO GAKU2
S2:
	DB	"Kenjirou:  No, I don't think it's a good idea."
	DB	NEXT
	DB	"Shiho:  Why?" 
	DB	NEXT
	DB	"Kenjirou:  I don't want people to gossip. Don't you agree?"
	DB	NEXT
	DB	"Shiho:  ..............." 
	DB	NEXT
	DB	"Kenjirou:  Well, I'll..."
	DB	T_WAIT, 5
	DB	" I'll see you in school. Bye!"
	DB	NEXT
	DB	"Leaving her behind, I head for school alone."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
GAKU1:
	BAK_INIT 'tb_010',B_NORM
	CDPLAY	14
	T_CG 'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Good morning." 
	DB	NEXT
	DB	"Kenjirou:  Morning."
	DB	NEXT
  	DB	"Tetsuya:  How are you today?"
	DB	NEXT
	DB	"Kenjirou:  Huh?"
	DB	NEXT
	DB	"Tetsuya:  I'm doing fine!"
	DB	NEXT
	DB	"Kenjirou:  ................."
	DB	NEXT
	DB	"Tetsuya:  Come on, I asked you a question. You have to react!" 
	DB	NEXT
	DB	"Then the chime rang through the room."
	DB	NEXT
	DB	"Kenjirou:  Ah, we've got to go sit down."
	DB	NEXT
	DB	"Tetsuya:  Wait."
	DB	T_WAIT, 5
	DB	"Talk to me, Kenjirou!"
	DB	NEXT
	TATI_ERS	;tt_08
	DB	"Afraid to hang around the ever-strange Tetsuya, I found my seat and sat down."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"During the day, I stared blankly at the board, wondering what the use of education was in society. "
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO 'JUMP.OVL'
	DB	EXIT
GAKU2:
	BAK_INIT 'tb_010',B_NORM
	CDPLAY	23
	T_CG 'tt_02_10',SIH_A3,0
	T_CG 'tt_08_10',TET_A1,0
	DB	"Tetsuya:  Good morning, Kashima-san." 
	DB	NEXT
	DB	"Shiho:  Good morning." 
	DB	NEXT
	DB	"Kenjirou:  Wait a minute."
	DB	T_WAIT, 5
	DB	" Aren't you going to say good morning to me, too?"
	DB	NEXT
	DB	"Tetsuya:  Ah, Kenjirou. You're here."
	DB	NEXT
	DB	"Kenjirou:  Hey.."
	DB	NEXT
	DB	"Then the chime rang, and it was time to start class."
	DB	NEXT
	;WAV		'Se_ch'
	DB	"Tetsuya:  You'd better go sit down."
	DB	NEXT
	DB	"Tetsuya:  Yes, Kenjirou. Go sit down."
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  I'd better sit down, too."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"All day, I stared blankly at the board, wondering what use education was, anyway?"
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO 'JUMP.OVL'
	DB	EXIT
END