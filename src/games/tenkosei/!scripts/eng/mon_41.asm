        include SUPER_C.inc
M_START:
MON_41
	FLG_IF JUMP,'=',76,FF_4
	FLG_IF JUMP,'=',75,FF_3
	FLG_IF JUMP,'=',74,FF_2
	FLG_IF JUMP,'=',73,FF_1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  ...Well, guess I'll go eat breakfast."
	DB	NEXT
	DB	"I pull on my uniform and head for the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Motoka and Akemi-san are here."
	DB	NEXT
	DB	"Motoka:  Oniichan, good morning." 
	DB	NEXT
	DB	"Akemi:  Good morning, Kenjirou-kun." 
	DB	NEXT
	DB	"Kenjirou:  Good morning. Is breakfast ready?"
	DB	NEXT
	DB	"Akemi:  You don't seem very happy this morning?" 
	DB	NEXT
	DB	"Kenjirou:  R- Really?"
	DB	NEXT
	DB	"Akemi:  It's not a good idea to stay out too late."
	DB	NEXT
	DB	"Akemi-san apparently knew about my going out last night."
	DB	NEXT
	DB	"Kenjirou:  Okay..."
	DB	NEXT
	DB	"Akemi:  Eat your breakfast." 
	DB	NEXT
	DB	"Akemi-san puts toast and coffee in front of me."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_02',MOT_A2,0
	DB	"Motoka:  Oniichan?"
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Motoka:  Can I stay overnight with some friends tonight?"
	DB	NEXT
	DB	"Kenjirou:  Mm? I guess it's okay, if Akemi-san says so."
	DB	NEXT
	DB	"Motoka:  She said it's okay. But she said I should ask you, too." 
	DB	NEXT
	DB	"Kenjirou:  Okay, well. Go ahead."
	DB	NEXT
	DB	"Motoka:  Really?" 
	DB	NEXT
	DB	"Kenjirou:  Sure."
	DB	NEXT
	DB	"Motoka:  Thanks! ...Well, I'll get off to school." 
	DB	NEXT
	DB	"Motoka runs out of the dining kitchen."
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  She's happy, as usual. Guess I'd better get going, too."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_006',B_NORM
	CDPLAY	2
	DB	"I stop off at the convenience store to buy my 500 yen lunch."
	DB	NEXT
	FLG_IF	TERUNASI,'=',1,TINAI
	GO	PAPAPA
TINAI:
	BAK_INIT	'tb_007',B_NORM
	DB	"I don't see Terumi-senpai here today..."
	DB	NEXT
	DB	"I can understand why not."
	DB	NEXT
	DB	"I buy my 500 yen lunch, and head for school."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	EKI
PAPAPA:
	BAK_INIT	'tb_007',B_NORM
	CDPLAY	3
	DB	"Inside the convenience store, Terumi is waiting for me. "
	DB	NEXT
	DB	"I meet her here a lot."
	DB	NEXT
	T_CG	'tt_05_07',TER2,0
	DB	"Kenjirou:  Good morning, Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  Good morning." 
	DB	NEXT
	DB	"Kenjirou:  Are you killing time here again, as usual?"
	DB	NEXT
	DB	"Terumi:  I'm waiting for you." 
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Terumi:  I'm kidding." 
	DB	NEXT
	DB	"She laughs at my discomfort."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	R1,"INVITE HER TO SCHOOL"
	MENU_SET	R2,"GO ALONE"
	MENU_END
	DB	EXIT
R1:
	DB	"Kenjirou:  ......"
	DB	T_WAIT,	3
	DB	"Would you like to go to school now?"
	DB	NEXT
	DB	"Terumi:  Eh? Oh, yes, that's a good idea. What about your lunch?"
	DB	NEXT
	DB	"Kenjirou:  I forgot. I'll be right back."
	DB	NEXT
	DB	"I buy my lunch (under 500 yen) as quickly as I can."
	DB	NEXT
	DB	"Kenjirou:  Okay, Terumi-senpai, let's go."
	DB	NEXT
	DB	"Terumi:  Okay, let's."
	DB	NEXT
	DB	"I put my purchase in my bag, and we go off to school together."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	GAKU1
R2:
	DB	"Kenjirou:  ......."
	DB	T_WAIT,	3
	DB	"Well, bye."
	DB	NEXT
	DB	"Terumi:  Kenjirou, what about your lunch?"
	DB	NEXT
	DB	"I ignore her, and head off to school alone."
	DB	NEXT
	B_O	B_FADE,C_KURO
EKI:
	BAK_INIT	'tb_009',B_NORM
	DB	"Kenjirou:  It sure it crowded."
	DB	NEXT
	DB	"I sure get tired of the train being so crowded."
	DB	NEXT
	DB	"Voice:  Kenjirou-kun..."
	DB	NEXT
	DB	"I turn around, to see who the owner of the voice could be."
	DB	NEXT
	T_CG	'tt_02_09',SIH_A2,0
	CDPLAY		23
	DB	"Shiho:  Kenjirou-kun, good morning." 
	DB	NEXT
	DB	"Kenjirou:  Oh, it's Shiho. Good morning."
	DB	NEXT
	DB	"Shiho:  What do you mean by, 'Oh, it's Shiho'?" 
	DB	NEXT
	DB	"She looked angry, but I knew she wasn't."
	DB	NEXT
	DB	"Kenjirou:  Sorry, sorry. I didn't mean anything."
	DB	NEXT
	DB	"Shiho:  Shall we go to school" 
	DB	T_WAIT,	3
	DB	" together?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	S1,"GO WITH HER"
	MENU_SET	S2,"DON'T BOTHER"
	MENU_END
	DB	EXIT
S1:
	DB	"I don't want to go alone..."
	DB	NEXT
	DB	"Kenjirou:  Sure, let's go together."
	DB	NEXT
	DB	"Shiho:  Okay."
	DB	NEXT
	DB	"I head for school with Shiho."
	DB	NEXT
	GO	GAKU2
	DB	EXIT
S2:
	DB	"Kenjirou:  I don't think it's a good idea."
	DB	NEXT
	DB	"Shiho:  Why not?" 
	DB	NEXT
	DB	"Kenjirou:  People might gossip. You know."
	DB	NEXT
	DB	"Shiho:  ................" 
	DB	NEXT
	DB	"Kenjirou:  Well, I'm..."
	DB	T_WAIT,	3
	DB	"going on alone."
	DB	NEXT
	DB	"I headed for school alone."
	DB	NEXT
	B_O	B_FADE,C_KURO
GAKU1:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	14
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Good morning." 
	DB	NEXT
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Tetsuya:  How are you?"
	DB	NEXT
	DB	"Kenjirou:  Huh?"
	DB	NEXT
	DB	"Tetsuya:  I'm fine."
	DB	NEXT
	DB	"Kenjirou:  ..............."
	DB	NEXT
	DB	"Tetsuya:  You should react! Do something!" 
	DB	NEXT
	DB	"Suddenly the bell rang. Time for class."
	DB	NEXT
	DB	"Kenjirou:  Oo, better sit down."
	DB	NEXT
	DB	"Tetsuya:  Wait!" 
	DB	T_WAIT,	3
	DB	" Come back and talk to me..."
	DB	NEXT
	TATI_ERS
	DB	"I sit in my seat."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"I stare listlessly at the blackboard, wondering what the point of education is."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	AHO
	DB	EXIT
GAKU2:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	23
	T_CG	'tt_02_10',SIH_A3,0
	T_CG	'tt_08_10',TET_A1,0
	DB	"Tetsuya:  Good morning, Kashima-san." 
	DB	NEXT
	DB	"Shiho:  Good morning." 
	DB	NEXT
	DB	"Kenjirou:  Wait a minute."
	DB	T_WAIT,	3
	DB	" What about me?"
	DB	NEXT
	DB	"Tetsuya:  Oh, Kenjirou's here."
	DB	NEXT
	DB	"Kenjirou:  Now wait a minute..."
	DB	NEXT
	DB	"The bell rang. Time for class."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Shiho:  We should sit down now..."
	DB	NEXT
	DB	"Tetsuya:  Good idea."
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  I'll go sit down, too."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"I stare at the blackboard listlessly, wondering what the point of education is."
	DB	NEXT
	B_O	B_FADE,C_KURO
AHO:
	FLG_KI JUMP,'=',73
	SINARIO	'NITI_HIR.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',74
	SINARIO	'NITI_HOK.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',75
	SINARIO	'NITI_MAT.OVL'
FF_3:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',76
	SINARIO	'NITI_KIT.OVL'
FF_4:
	FLG_KI JUMP,'=',0
	SINARIO	'MON_42.OVL'
	DB	EXIT
END