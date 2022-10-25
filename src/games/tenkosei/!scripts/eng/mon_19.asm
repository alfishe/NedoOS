        include SUPER_C.inc
M_START:
MON_19
	FLG_IF JUMP,'=',61,FUFUFU_1
	BAK_INIT 'tb_001a',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  Mmm? Time to wake up, I guess..."
	DB	NEXT
	DB	"I get dressed and head down to the dining kitchen."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		9
	T_CG 'tt_10_02',MOT_A3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Motoka and Akemi-san are here."
	DB	NEXT
	DB	"Motoka:  Oniichan, good morning."
	DB	NEXT
	DB	"Akemi:  Good morning, Kenjirou-kun."
	DB	NEXT
	DB	"Kenjirou:  Good morning. Akemi-san, is breakfast ready?"
	DB	NEXT
	DB	"Akemi:  Yes, here it is."
	DB	NEXT
	DB	"She puts toast and coffee in front of me."
	DB	NEXT
	TATI_ERS		;Tt_20
	T_CG 'tt_10_02',MOT_A2,0
	DB	"Having put my breakfast on the table, Akemi-san starts her housework."
	DB	NEXT
	DB	"Motoka:  Oniichan, let's go to school together."
	DB	NEXT
	DB	"Kenjirou:  Why?"
	DB	NEXT
	DB	"Motoka:  Why? Because I want to go with you, that's why. Is it okay?" 
	DB	NEXT
	DB	"She's been really solemn these days. I should make her happy."
	DB	NEXT
	DB	"Kenjirou:  Okay."
	DB	NEXT
	DB	"Motoka:  Eh?" 
	DB	NEXT
	DB	"Kenjirou:  What the heck. Let's go to school together."
	DB	NEXT
	DB	"Motoka:  G- Great!" 
	DB	NEXT
	DB	"She smiles until her face looks like it's going to crack in half. "
	DB	NEXT
	CDPLAY		0
	F_O B_NORM,C_KURO
	DB	"I leave the house with Motoka. We stop at the convenience store, then head for school. "
        DB      "Riding the packed train with me, Motoka chirps happily all the way."
	DB	NEXT
	BAK_INIT 'tb_009',B_NORM
	CDPLAY		20
	T_CG 'tt_10_09',MOT_A2,0
	DB	"Shiho:  Kenjirou-kun, good morning."
	DB	NEXT
	DB	"I turn around to see Shiho, smiling in front of me."
	DB	NEXT
	TATI_ERS		;Tt_10
	T_CG 'tt_02_09',SIH_A1,0
	T_CG 'tt_10_09',MOT_A3,0
	DB	"Motoka:  Ah, Kashima-san... Good morning." 
	DB	NEXT
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Motoka:  I- I'm going on ahead, Oniichan." 
	DB	NEXT
	TATI_ERS		;Tt_21
	DB	"Kenjirou:  Wait, Motoka..."
	DB	NEXT
	DB	"Motoka nods goodbye to Shiho, and goes on ahead to school."
	DB	NEXT
	CDPLAY		23
	T_CG 'tt_02_09',SIH_A2,0
	DB	"Shiho:  .............." 
	DB	NEXT
	DB	"Kenjirou:  Well, let's go to school."
	DB	NEXT
	DB	"Shiho:  O- Okay." 
	DB	NEXT
	DB	"I leave the station with Shiho."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_010',B_NORM
	T_CG 'tt_02_10',SIH_A1,0
	T_CG 'tt_08_10',TET_A3,0
	DB	"Tetsuya:  Good morning, Kashima-san."
	DB	NEXT
	DB	"Shiho:  Good morning."
	DB	NEXT
	DB	"Kenjirou:  Hey, wait a minute."
	DB	T_WAIT, 5
	DB	" What about me?"
	DB	NEXT
	DB	"Tetsuya:  Oh, Kenjirou. You're here."
	DB	NEXT
	DB	"Kenjirou:  Hey..."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Suddenly the bell rings."
	DB	NEXT
	DB	"Shiho:  We should sit down..."
	DB	NEXT
	DB	"Tetsuya:  Yes, you're right."
	DB	NEXT
	TATI_ERS	;Tt_02
	DB	"Kenjirou:  I'll sit down too."
	DB	NEXT
	F_O B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"Looking at the blackboard, I wonder to myself what the purpose of education really is."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
	FLG_KI JUMP,'=',61
	SINARIO 'NITI_HIR.OVL'
FUFUFU_1:
	F_O B_NORM,C_KURO	
	DB	"Voice:  Hey! Wake up!"
	DB	NEXT
	DB	"Kenjirou:  ...Mm?"
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	CDPLAY		14
	DB	"Tetsuya:  You're finally awake."
	DB	NEXT
	DB	"I lift my head off the desk slowly and look around."
	DB	NEXT
	T_CG 'tt_08_11b',TET_A2,0
	DB	"Tetsuya:  School's over. Time to get up."
	DB	NEXT
	DB	"Kenjirou:  Thanks..."
	DB	NEXT
	DB	"Tetsuya:  Man, you take the cake."
	DB	NEXT
	DB	T_WAIT, 2
	DB	" I've never seen anyone sleep so much."
	DB	NEXT
	DB	"Kenjirou:  Thanks for the praise."
	DB	NEXT
	DB	T_WAIT, 5
	DB	" I didn't know you cared."
	DB	NEXT
	DB	"Tetsuya:  I wasn't praising you!" 
	DB	NEXT
	DB	"Tetsuya:  Anyway, I've got to talk to you about something..."
	DB	NEXT
	DB	"Kenjirou:  Is it more gossip and rumors?"
	DB	NEXT
	DB	"Tetsuya:  No, not today."
	DB	NEXT
	DB	"Kenjirou:  Well, what is it?"
	DB	NEXT
	DB	"Tetsuya:  There's something I want to ask you."
	DB	NEXT
	DB	"Kenjirou:  Something you want to ask me?"
	DB	NEXT
	DB	"Tetsuya:  Y- Yes. Are you and Kashima-san..."
	DB	T_WAIT, 3
	DB	"going out or anything?"
	DB	NEXT
	DB	"Kenjirou:  Huh?"
	DB	NEXT
	DB	"Tetsuya:  You know. Are you seeing each other or anything?" 
	DB	NEXT
	DB	"Kenjirou:  ...Ah, it becomes clear."
	DB	NEXT
	DB	"Tetsuya:  W- What are you talking about?"
	DB	NEXT
	DB	"Kenjirou:  You're the one spreading the rumors about people. Tachikawa-san and Motoka -- you're the source of the gossip."
	DB	NEXT
	DB	"Tetsuya:  N- No way! You're wrong!" 
	DB	NEXT
	DB	"Kenjirou:  Then why are you asking me something like that?"
	DB	NEXT
	DB	"Tetsuya:  You know. You sometimes..." 
	DB	NEXT
	DB	" You sometimes hang out with Kashima-san after school. You even came to school with her today."
	DB	NEXT
	DB	"And if you are seeing her, I just wanted to congratulate you, that's all."
	DB	NEXT
	DB	"Kenjirou:  I'm not seeing Shiho or anything."
	DB	NEXT
	DB	"Tetsuya:  Well, why do you call her 'Shiho' instead of 'Kashima-san'?" 
	DB	NEXT
	DB	"Kenjirou:  Because we're friends. For the same reason that you call me Kenjirou."
	DB	NEXT
	DB	"Tetsuya:  Really?"
	DB	NEXT
	DB	"Kenjirou:  ...Have I ever lied to you?"
	DB	NEXT
	DB	"Tetsuya:  ...Okay, I believe you. So you're not involved with Kashima-san at all."
	DB	NEXT
	DB	"Kenjirou:  Well, I wouldn't go that far."
	DB	NEXT
	DB	"Tetsuya:  Eh?" 
	DB	NEXT
	DB	"Kenjirou:  I mean, we're friends. That's not nothing." 
	DB	NEXT
	DB	"Tetsuya:  Friends! Okay, that's great news..." 
	DB	NEXT
	TATI_ERS	;tt_08
	DB	"Nodding happily to himself, Tetsuya goes out into the hallway."
	DB	NEXT
	DB	"Kenjirou:  What's up with him?"
	DB	NEXT
	DB	"Kenjirou:  Oh well. I guess it's time to go home now."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"The sky is almost dark when I leave the school. It's getting dark so much earlier these days."
	DB	NEXT
	DB	"Time to go home."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI JUMP,'=',0
	SINARIO 'MON_20.OVL'
END