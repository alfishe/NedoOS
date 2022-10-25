        include SUPER_C.inc
M_START:
MON_35
	FLG_IF JUMP,'=',67,FF_4
	FLG_IF JUMP,'=',66,FF_3
	FLG_IF JUMP,'=',65,FF_2
	FLG_IF JUMP,'=',64,FF_1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  Ahh. That was a good sleep."
	DB	NEXT
	DB	"Time to get dressed."
	DB	NEXT
	DB	"I get dressed, and head for the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A1,0
	T_CG	'tt_20_02',AKE_A3,0
	DB	"Motoka and Akemi-san are here."
	DB	NEXT
	DB	"Motoka:  Oniichan, good morning!" 
	DB	NEXT
	DB	"Motoka is different than she was yesterday. She's cheerful and happy."
	DB	NEXT
	DB	"Akemi:  Kenjirou-kun, good morning." 
	DB	NEXT
	DB	"Kenjirou:  Good morning. Akemi-san, is breakfast ready?"
	DB	NEXT
	DB	"Akemi:  It's right here."
	DB	NEXT
	DB	"She puts toast and coffee in front of me."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_02',MOT_A2,0
	DB	"After giving me my breakfast, Akemi-san goes back into the kitchen."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_02',MOT_B2,0
	DB	"Motoka:  Oniichan?"
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Motoka:  Would you like to..."
	DB	T_WAIT,	3
	DB	"go to school together?"
	DB	NEXT
	DB	"I haven't talked with her much these days. It's probably a good idea."
	DB	NEXT
	DB	"Motoka:  You don't want to?"
	DB	NEXT
	DB	"Kenjirou:  It's okay. Let's go together."
	DB	NEXT
	DB	"Motoka:  Okay, let's go." 
	DB	NEXT
	DB	"She pulls my arm as we head for school."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"I buy my 500 yen lunch at the convenience store, and we head for the station."
	DB	NEXT
	DB	"On the train, Motoka talks at me the whole time. I nod occasionally, but don't contribute "
        DB      "any more to the conversation. Even in the middle of the main morning crunch of students, she keeps talking."
	DB	NEXT
	BAK_INIT	'tb_009',B_NORM
	CDPLAY	23
	T_CG	'tt_10_09',SIH_A2,0
	DB	"Shiho:  Ah, Kenjirou-kun. Good morning." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_02_09',SIH_A1,0
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Motoka:  Kashima-senpai..."  
	DB	T_WAIT,	3
	DB	" Good morning."
	DB	NEXT
	DB	"Shiho:  Ah, good morning." 
	DB	NEXT
	DB	"Motoka pulls on my sleeve, pulling me close to her."
	DB	NEXT
	DB	"Shiho sees this, and moves back a little bit."
	DB	NEXT
	DB	"Motoka:  ....................." 
	DB	NEXT
	DB	"Shiho:  ....................." 
	DB	NEXT
	DB	"W- What's happening...?"
	DB	NEXT
	DB	"Terumi:  Good morning."
	DB	NEXT
	DB	"Terumi-senpai shows up, walking in between Motoka and me."
	DB	NEXT
	TATI_ERS
	CDPLAY	3
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_05_09',TER1,0
	DB	"Terumi:  What are you all standing here for? Time for school!" 
	DB	NEXT
	DB	"Terumi-senpai lightly knocks me on my head once, and goes off to school alone."
	DB	NEXT
	TATI_ERS
	CDPLAY	23
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_02_09',SIH_A1,0
	DB	"Kenjirou:  We should get going, too."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	F_O	B_NORM,C_KURO
	DB	"The rest of the way to school, no one said anything."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	23
	T_CG	'tt_02_10',SIH_A1,0
	T_CG	'tt_08_10',TET_A3,0
	DB	"Tetsuya:  Good morning, Kashima-san." 
	DB	NEXT
	DB	"Shiho:  Good morning." 
	DB	NEXT
	DB	"Kenjirou:  Wait a minute..."
	DB	T_WAIT,	3
	DB	" What about me?"
	DB	NEXT
	DB	"Tetsuya:  Oh, Kenjirou. You're here."
	DB	NEXT
	DB	"Kenjirou:  Now hang on..."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Shiho:  We'd better sit down."
	DB	NEXT
	DB	"Tetsuya:  You're right." 
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  I'd better sit down, too."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"I stare blandly at the blackboard, wondering what the point of education is anyway."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI JUMP,'=',0
	FLG_KI	JUMP,'=',64
	SINARIO	'NITI_HIR.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI	JUMP,'=',65
	SINARIO	'NITI_HOK.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	FLG_KI	JUMP,'=',66
	SINARIO	'NITI_MAT.OVL'
FF_3:
	FLG_KI JUMP,'=',0
	FLG_IF HANAJI,'>=',1,ABC
	FLG_KI	JUMP,'=',67
	SINARIO	'NITI_KIT.OVL'
FF_4:
	FLG_KI JUMP,'=',0
	FLG_IF	ONANI,'>=',5,DEF
	FLG_KI	ONANI,'=',0
DEF:
	SINARIO	'MON_36.OVL'
	DB	EXIT
ABC:
	FLG_IF	ONANI,'>=',5,GHI
	FLG_KI	ONANI,'=',0
GHI:
	SINARIO	'MON_36.OVL'
	DB	EXIT
END