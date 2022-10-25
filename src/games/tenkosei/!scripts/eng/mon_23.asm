        include SUPER_C.inc
M_START:
MON_23
	FLG_IF JUMP,'=',63,FUFUFU_1
	FLG_IF HOK,'=',5,KYOUSITU1
	FLG_IF HAND,'=',4,TOIRE1
SMK:
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"I didn't get much sleep..."
	DB	NEXT
	DB	"I change my clothes and head downstairs."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY		20
	T_CG	'tt_20_02',AKE_A3,0
	T_CG	'tt_21_02',MOT_A1,0
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Akemi:  Good morning, Kenjirou."
	DB	NEXT
	DB	"Motoka:  ................."
	DB	NEXT
	DB	"Motoka doesn't greet me."
	DB	NEXT
	DB	"Kenjirou:  Motoka, you were out awfully late last night."
	DB	NEXT
	DB	"Motoka:  ................" 
	DB	NEXT
	DB	"Akemi:  Motoka, you should say good morning to Kenjirou."
	DB	NEXT
	DB	"Motoka:  I'm off to school."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_20_02',AKE_A2,0
	CDPLAY		6
	DB	"Akemi:  Ah, Motoka..."
	DB	NEXT
	DB	"Kenjirou:  ...Motoka."
	DB	NEXT
	DB	"Akemi:  I'm sorry, Kenjirou-kun." 
	DB	NEXT
	DB	"Kenjirou:  It's okay."
	DB	NEXT
	DB	"Akemi:  She's probably..." 
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Akemi:  It's nothing."
	DB	NEXT
	DB	"Kenjirou:  .................."
	DB	NEXT
	DB	"Kenjirou:  Well, I'll get off to school then, too."
	DB	NEXT
	DB	"Akemi:  See you later."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_006',B_NORM
	CDPLAY		2
	DB	"Guess I'll go inside..."
	DB	NEXT
	DB	"I go inside the convenience store."
	DB	NEXT
	BAK_INIT	'tb_007',B_NORM
	CDPLAY	3
	DB	NEXT
	DB	"I see Terumi-senpai here a lot."
	DB	NEXT
	T_CG	'tt_05_07',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai, good morning."
	DB	NEXT
	DB	"Terumi:  Good morning. You seem a little down today." 
	DB	NEXT
	DB	"Kenjirou:  Oh, I stayed up late last night."
	DB	NEXT
	DB	"Terumi:  I'll bet you were watching some of those adult videos, right?" 
	DB	NEXT
	DB	"Kenjirou:  ...Something like that."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	R1,"INVITE TERUMI-SENPAI"
	MENU_SET	R2,"GO TO SCHOOL ALONE"
	MENU_END
	DB	EXIT
R1:
	DB	"Kenjirou:  ......"
	DB	T_WAIT, 5
	DB	"Terumi-senpai, shall we go to school now?"
	DB	NEXT
	DB	"Terumi:  Eh? Oh, yes. What about your lunch?"
	DB	NEXT
	DB	"Kenjirou:  I'll be right back."
	DB	NEXT
	DB	"I pick up some rice balls and head for the register."
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai, I'm done. Let's go." 
	DB	NEXT
	DB	"Terumi:  Okay."
	DB	NEXT
	DB	"I put the rice balls in my bag, and leave the convenience store."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	GAKU1
R2:
	DB	"Kenjirou:  Well, I'll see you later."
	DB	NEXT
	DB	"I head off for school alone."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_009',B_NORM
	CDPLAY		23
	DB	"Kenjirou:  It's full of people, as usual."
	DB	NEXT
	DB	"Voice:  Kenjirou-kun."
	DB	NEXT
	DB	"I turn around to see who had called me."
	DB	NEXT
	T_CG	'tt_02_09',SIH_A2,0
	DB	"Shiho:  Kenjirou-kun, good morning."
	DB	NEXT
	DB	"Kenjirou:  Morning."
	DB	NEXT
	DB	"Shiho:  You don't seem very chipper today?"
	DB	NEXT
	DB	"Shiho looks at me with her big, full eyes."
	DB	NEXT
	DB	"Kenjirou:  I didn't get enough sleep last night."
	DB	NEXT
	DB	"Shiho:  You have to go to bed early." 
	DB	NEXT
	DB	"Kenjirou:  You're right."
	DB	NEXT
	DB	"Shiho:  Shall we go to school?" 
	DB	T_WAIT, 5
	DB	" together?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	S1,"GO WITH HER"
	MENU_SET	S2,"GO ALONE"
	MENU_END
	DB	EXIT
S1:
	DB	"Kenjirou:  Okay, let's go."
	DB	NEXT
	DB	"Shiho:  Okay."
	DB	NEXT
	DB	"I head for school with Shiho."
	DB	NEXT
	GO	GAKU2
	DB	EXIT
S2:
	DB	"Kenjirou:  No, I want to go alone."
	DB	NEXT
	DB	"Shiho:  I see..."
	DB	NEXT
	DB	"I head for school alone."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	GAKU1
	DB	EXIT
GAKU1:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		14
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Morning."
	DB	NEXT
	DB	"Kenjirou:  Morning."
	DB	NEXT
	DB	"Tetsuya:  How are you?"
	DB	NEXT
	DB	"Kenjirou:  Hmm, so-so."
	DB	NEXT
	DB	"Tetsuya:  Really? I'm fine."
	DB	NEXT
	DB	"Kenjirou:  ................"
	DB	NEXT
	DB	"Tetsuya:  Hey, react! Do something!"
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Suddenly the bell rang. Time for class."
	DB	NEXT
	DB	"Kenjirou:  Sorry, I'm a little tired."
	DB	NEXT
	DB	"Tetsuya:  ..............."
	DB	NEXT
	TATI_ERS
	DB	"I sit down in my seat."
	DB	NEXT
	;WAV  'STOP'
	CDPLAY	0
	F_O B_NORM,C_KURO
	DB	"I stare at the blackboard, thinking about nothing."
	DB	NEXT
	DB	"I can't stop thinking about Motoka."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO HIRUYASUMI
	DB	EXIT
GAKU2:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		23
	T_CG	'tt_02_10',SIH_A1,0
	T_CG	'tt_08_10',TET_A3,0
	DB	"Tetsuya:  Good morning, Kashima-san."
	DB	NEXT
	DB	"Shiho:  Good morning."
	DB	NEXT
	DB	"Kenjirou:  ................"
	DB	NEXT
	DB	"I sit in my seat."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		14
	DB	"I stare at the blackboard, blankly."
	DB	NEXT
	DB	"I can't stop thinking about Motoka."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	HIRUYASUMI
HIRUYASUMI:
	F_O B_NORM,C_KURO
	DB	"Suddenly, it was lunch time."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	DB	"I head out into the hallway."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB	"Time to go look for some beautiful women..."
	DB	NEXT
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
	GO	SENTAKU1
ROUKA1:
	CDPLAY		14
	BAK_INIT	'tb_034a',B_NORM
	DB	"So where should I go?"
	DB	NEXT
SENTAKU1:
	FLG_KI W,'=',-1
	FLG_IF	TEMP02,'=',0,SA_1
	FLG_KI W,'DOWN',0
SA_1:
	FLG_IF	TEMP03,'=',0,SA_2
	FLG_KI W,'DOWN',1
SA_2:
	FLG_IF	TEMP04,'=',0,SA_3
	FLG_KI W,'DOWN',2
SA_3:
	FLG_IF	TEMP05,'=',0,SA_4
	FLG_KI W,'DOWN',3
SA_4:
	FLG_IF	TEMP06,'=',0,SA_5
	FLG_KI W,'DOWN',4
SA_5:
	FLG_IF	TEMP07,'=',0,SA_6
	FLG_KI W,'DOWN',5
SA_6:
	FLG_IF	TEMP08,'=',0,SA_7
	FLG_KI W,'DOWN',6
SA_7:
	FLG_IF	SIZ_ATTA,'=',1,SA_8
	FLG_KI W,'DOWN',6
SA_8:
	MENU_S	2,W,-1
	MENU_SET	T1,"RETURN TO CLASS"
	MENU_SET	T2,"ROOF"
	MENU_SET	T3,"MOTOKA'S CLASSROOM"
	MENU_SET	T4,"PE LOCKER"
	MENU_SET	T5,"ART ROOM"
	MENU_SET	T6,"MEN'S ROOM"
	MENU_SET	T7,"NURSE'S OFFICE"
	MENU_END
	DB	EXIT
T1:
	FLG_IF	TEMP01,'>=',2,KYOUSITU1
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB	"Guess I'll head back to class."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		23
	T_CG	'tt_02_10',SIH_A2,0
	DB	"When I went to leave the classroom, I ran into Shiho."
	DB	NEXT
	DB	"Tetsuya:  Ah, Kenjirou-kun."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	U1,"LOOK AT FACE"
	MENU_SET	U2,"LOOK AT BREASTS"
	MENU_SET	U3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
U1:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Shiho's got a great face. Almost perfect."
	DB	NEXT
	GO BODY_SHIHO
U2:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"She's got excellent breasts, concealed under her uniform."
	DB	NEXT
	GO BODY_SHIHO
U3:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Wonderful thighs, soft and supple, with just the right amount of meat."
	DB	NEXT
	GO BODY_SHIHO
BODY_SHIHO:
	FLG_KI AKEM_NET,'=',0
	FLG_KI MIKA_NET,'=',0
	FLG_KI TER_NET,'=',0
	FLG_KI RENA_NET,'=',0
	FLG_KI NANA_NET,'=',0
	FLG_KI SIZU_NET,'=',0
	FLG_KI CHIE_NET,'=',0
	DB	"Hmm, I don't want to pollute her by thinking dirty thoughts about her."
	DB	NEXT
	DB	"Shiho:  What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing..."
	DB	NEXT
	DB	"Shiho:  Really? Well, I'm off to the library."
	DB	NEXT
	TATI_ERS
	DB	"She heads out of the classroom."
	DB	NEXT
	DB	"Guess I'll leave, too."
	DB	NEXT
	GO	ROUKA1
T2:
	FLG_IF	TEMP01,'>=',2,KYOUSITU1
	FLG_KI	TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"I head for the roof."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	DB	"I'm on the roof. I see Terumi-senpai standing against the chain link fencing."
	DB	NEXT
	T_CG	'tt_05_12',TER2,0
	DB	"Kenjirou:  Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  Ah, Kenjirou."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	V1,"LOOK AT BREASTS"
	MENU_SET	V2,"LOOK AT ASS"
	MENU_SET	V3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
V1:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',3
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT1
	FLG_KI	TER_NET,'=',1
TER_TAT1:
	DB	"She's got excellent breasts, large with excellent shape. Lots of volume."
	DB	NEXT
	GO BODY_TERMI
V2:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT2
	FLG_KI	TER_NET,'=',1
TER_TAT2:
	DB	"Her ass is small and fine, with a great waistline."
	DB	NEXT
	GO BODY_TERMI
V3:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT3
	FLG_KI	TER_NET,'=',1
TER_TAT3:
	DB	"Her thighs are smooth and silky, and they go all the way up."
	DB	NEXT
	GO BODY_TERMI
BODY_TERMI:
	DB	"Terumi:  What's the matter? Why are you staring at me?"
	DB	NEXT
	DB	"Kenjirou:  Oh, no reason. Um, what are you doing up here alone?"
	DB	NEXT
	DB	"Terumi:  Nothing, really. Just thinking." 
	DB	T_WAIT, 5
	DB	" What about you?"
	DB	NEXT
	DB	"Kenjirou:  Nothing special. Just roaming around the school."
	DB	NEXT
	DB	"Terumi:  You've got a lot of free time." 
	DB	NEXT
	DB	"Kenjirou:  Just like you."
	DB	NEXT
	DB	"Suddenly, she moves towards me."
	DB	NEXT
	DB	"Kenjirou:  Hahaha! (I'd better get out of here!)"
	DB	NEXT
	DB	"Kenjirou:  Well, see you later, Terumi-senpai!"
	DB	NEXT
	DB	"Terumi:  Ah, wait!" 
	DB	NEXT
	DB	"I head back downstairs."
	DB	NEXT
	GO	ROUKA1
T3:
	FLG_KI TEMP04,'=',1
	DB	"I probably shouldn't go see Motoka today. I'll just leave her alone."
	DB	NEXT
	GO	ROUKA1
T4:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"I guess I'll look at the PE storage room."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Tetsuya is here, looking for a ball."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Kenjirou:  Hey, Tetsuya. What are you doing here?"
	DB	NEXT
	DB	"Tetsuya:  Oh, Kenjirou. I'm trying to find a good ball."
	DB	NEXT
	DB	"Kenjirou:  I'm just wandering around."
	DB	NEXT
	DB	"Tetsuya:  You are?"
	DB	NEXT
	DB	"Kenjirou:  Yep. Well, see you later."
	DB	NEXT
	DB	"I leave the PE storage room."
	DB	NEXT
	GO	ROUKA1
T5:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"I wonder if my wonderful Mika-sensei is here."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY		18
	DB	"Mika-sensei is here, dusting her statues."
	DB	NEXT
	DB	"Kenjirou:  Mika-sensei."
	DB	NEXT
	DB	"Mika:  Ah, Kondo-kun."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	X1,"LOOK AT BREASTS"
	MENU_SET	X2,"LOOK AT ASS"
	MENU_SET	X3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
X1:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MIKA_TAT1
	FLG_KI	MIKA_NET,'=',1
MIKA_TAT1:
	DB	"She's got her arms crossed, so I can't see her breasts. But I'd love to slide my cock in between them."
	DB	NEXT
	GO BODY_MIKA
X2:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MIKA_TAT2
	FLG_KI	MIKA_NET,'=',1
MIKA_TAT2:
	DB	"A very nice ass. I'll never forget the feel of it..."
	DB	NEXT
	GO BODY_MIKA
X3:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MMM
	FLG_KI	MIKA_NET,'=',1
MMM:
	DB	"Soft, supple, very nice thighs."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Mika:  Were you looking at me in a lewd way?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? What do you mean by lewd?"
	DB	NEXT
	DB	"Mika:  Oh, never mind."
	DB	NEXT
	DB	"Mika:  I'm glad you came here on time."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Mika:  Don't tell me you forgot!"
	DB	NEXT
	DB	"Oh no! I forgot!"
	DB	NEXT
	DB	"Kenjirou:  I'll see you later, sensei..."
	DB	NEXT
	DB	"Mika:  Wait, Kondo-kun!"
	DB	NEXT
	DB	"I leave the art room in a hurry."
	DB	NEXT
	GO ROUKA1
T6:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"I head for the men's room."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	T_CG 'tt_03_17a',HIR2,0
	DB	"On my way in, I run into Hiroshi."
	DB	NEXT
	DB	"Hiroshi:  Oh, Kondo. Here to take a crap?"
	DB	NEXT
	DB	"Kenjirou:  Yes, something like that."
	DB	NEXT
	DB	"Hiroshi:  Well, see you later."
	DB	NEXT
	TATI_ERS
	DB	"The second stall from the back, my operating room. It's open as usual."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	Y1,"DO IT"
	MENU_SET	Y2,"DON'T BOTHER"
	MENU_END
	DB	EXIT
Y1:
	F_O	B_NORM,C_KURO
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'!=',1,SS_1
	FLG_KI HAND,'=',4
	SINARIO 'AK_H.OVL'
SS_1:
	FLG_IF MIKA_NET,'!=',1,SS_2
	FLG_KI HAND,'=',4
	SINARIO 'MI_H.OVL'
SS_2:
	FLG_IF TER_NET,'!=',1,SS_3
	FLG_KI HAND,'=',4
	SINARIO 'TE_H.OVL'
SS_3:
	FLG_IF RENA_NET,'!=',1,SS_4
	FLG_KI HAND,'=',4
	SINARIO 'RE_H.OVL'
SS_4:
	FLG_IF NANA_NET,'!=',1,SS_5
	FLG_KI HAND,'=',4
	SINARIO 'NA_H.OVL'
SS_5:
	FLG_IF SIZU_NET,'!=',1,SS_6
	FLG_KI HAND,'=',4
	SINARIO 'SI_H.OVL'
SS_6:
	FLG_IF CHIE_NET,'!=',1,SS_7
	FLG_KI HAND,'=',4
	SINARIO 'CH_H.OVL'
SS_7:
SENTAKU2:
	F_O	B_NORM,C_KURO
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,DD_1
	FLG_KI W,'DOWN',3
DD_1:
	FLG_IF NAN_ATTA,'=',1,DD_2
	FLG_KI W,'DOWN',4
DD_2:
	FLG_IF SIZ_ATTA,'=',1,DD_3
	FLG_KI W,'DOWN',5
DD_3:
	FLG_IF CHI_ATTA,'=',1,DD_4
	FLG_KI W,'DOWN',6
DD_4:
	MENU_S	2,W,-1
	MENU_SET	Z1,"AKEMI KONDO"
	MENU_SET	Z2,"TERUMI KINOUCHI"
	MENU_SET	Z3,"MIKA MAEDA"
	MENU_SET	Z4,"RENA WATANABE"
	MENU_SET	Z5,"NANA HIROSE"
	MENU_SET	Z6,"SHIZUKA HASEGAWA"
	MENU_SET	Z7,"CHIE UTSUMI"
	MENU_SET	Z8,"DON'T DO IT"
	MENU_END
	DB	EXIT
Z1:
        DB	"Mmm, let's do it with Akemi-san."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'AK_H.OVL'
Z2:
	DB	"Mmm, Terumi-senpai would be nice."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'TE_H.OVL'
Z3:
	DB	"I'd love to have my way with Mika-sensei..."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'MI_H.OVL'
Z4:
	DB	"I want to relive the memories of spring vacation."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'RE_H.OVL'
Z5:
	DB	"I'd love to tear those clothes off of her..."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'NA_H.OVL'
Z6:
	DB	"She gets me so hot. I'll for her."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'SI_H.OVL'
Z7:
	DB	"I just love her in that bathing suit."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'CH_H.OVL'
Z8:
	DB	"Hmm, guess I won't bother."
	DB	NEXT
Y2:
DERU:
	DB	"I've got no reason to be here, guess I'll leave."
	DB	NEXT
	GO ROUKA1
TOIRE1:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Feeling much better after getting my rocks off, I go to the bathroom sink."
	DB	NEXT
	DB	"Ah, that was nice..."
	DB	NEXT
	DB	"Guess I'd better wash my hands."
	DB	NEXT
	DB	"I finish up, and head out into the hall."
	DB	NEXT
	GO ROUKA1
T7:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"The nurse's office. I wonder how Shizuka-sensei is doing?"
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB	"Shizuka:  Do you hurt somewhere?"
	DB	NEXT
	DB	"Kenjirou:  No, I'm fine."
	DB	NEXT
	DB	"Shizuka:  Then why are you here?"
	DB	NEXT
	DB	"Kenjirou:  I wanted to see you."
	DB	NEXT
	DB	"Shizuka:  Gee, thanks. "
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AA_1,"LOOK AT FACE"
	MENU_SET	AA_2,"LOOK AT HANDS"
	MENU_SET	AA_3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AA_1:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_1
	FLG_KI SIZU_NET,'=',1
GG_1:
	DB	"She's got a great sexy face."
	DB	NEXT
	GO BODY_SIZUKA
AA_2:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_2
	FLG_KI SIZU_NET,'=',1
GG_2:
	DB	"I'd love to have those manicured fingers around my shaft."
	DB	NEXT
AA_3:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_3
	FLG_KI SIZU_NET,'=',1
GG_3:
	DB	"I can just see the lace on the top of her stockings. It's too sexy."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Shizuka:  Just where are you looking?"
	DB	NEXT
	DB	"Kenjirou:  Oh, nowhere."
	DB	NEXT
	DB	"Shizuka:  You're young, so there's nothing that can be done about it, I guess."
	DB	NEXT
	DB	"Kenjirou:  E- Excuse me."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"There's no woman hotter than Shizuka-sensei."
	DB	NEXT
	GO ROUKA1
HOKEN1:
	FLG_KI HOK,'=',5
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',5
	SINARIO 'ER2.OVL'
KYOUSITU1:
	FLG_KI HOK,'=',0
	DB	"Guess I should be getting back."
	DB	NEXT
	BAK_INIT	'tb_010',B_FADE
	DB	"Let's see, time for a nap."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"The bell rings, waking me up. Time for class."
	DB	NEXT
	DB	"Stupid bell."
	DB	NEXT
	B_O B_FADE,C_KURO
	;WAV  'STOP'
	FLG_KI JUMP,'=',63
	SINARIO	'NITI_HOK.OVL'
FUFUFU_1:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"When I leave, it's dark already. It sure gets dark early these days."
	DB	NEXT
	DB	"Guess I won't go straight home today."
	DB	NEXT
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
	GO	SENTAKU
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB	"So where should I go?"
	DB	NEXT
SENTAKU:
	FLG_KI W,'=',-1
	FLG_IF	TEMP02,'=',0,MM_1
	FLG_KI W,'DOWN',0
MM_1:
	FLG_IF	TEMP03,'=',0,MM_2
	FLG_KI W,'DOWN',1
MM_2:
	FLG_IF	TEMP04,'=',0,MM_3
	FLG_KI W,'DOWN',2
MM_3:
	FLG_IF	TEMP05,'=',0,MM_4
	FLG_KI W,'DOWN',3
MM_4:
	FLG_IF	TEMP06,'=',0,MM_5
	FLG_KI W,'DOWN',4
MM_5:
	FLG_IF	TEMP07,'=',0,MM_6
	FLG_KI W,'DOWN',5
MM_6:
	FLG_IF	TEMP08,'=',0,MM_7
	FLG_KI W,'DOWN',6
MM_7:
	FLG_IF	REN_ATTA,'=',1,MM_8
	FLG_KI W,'DOWN',5
MM_8:
	FLG_IF	NAN_ATTA,'=',1,MM_9
	FLG_KI W,'DOWN',6
MM_9:
	MENU_S	2,W,-1
	MENU_SET	AH1,"MOVIE THEATRE"
	MENU_SET	AH2,"LINGERIE PUB"
	MENU_SET	AH3,"PARK"
	MENU_SET	AH4,"LOVE HOTEL"
	MENU_SET	AH5,"BAR"
	MENU_SET	AH6,"COFFEE SHOP"
	MENU_SET	AH7,"RESTAURANT"
	MENU_SET	AH8,"GO HOME"
	MENU_END
	DB	EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Guess I'll go see a movie."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"It's really run down around here."
	DB	NEXT
	DB	"It's a big problem in Japan."
	DB	NEXT
	DB	"Well, there's no movie I want to see, so I guess I won't bother."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Guess I'll go check out the lingerie pub."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"What a great place."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Tetsuya:  Kenjirou, what are you doing here?"
	DB	NEXT
	DB	"Tetsuya appears."
	DB	NEXT
	DB	"Kenjirou:  Me? What about you?"
	DB	NEXT
	DB	"Tetsuya:  Me? Oh, I'm just, just..."
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Tetsuya:  Well you have to admit, this place is pretty cool."
	DB	NEXT
	DB	"Kenjirou:  I guess."
	DB	NEXT
	DB	"Tetsuya:  Wouldn't you love to come here, just once?" 
	DB	NEXT
	DB	"Kenjirou:  Well, a little."
	DB	NEXT
	DB	"Tetsuya:  See? I just want to come here once." 
	DB	NEXT
	DB	"Tetsuya looks at the lingerie pub sign, lost in his own world."
	DB	NEXT
	DB	"Guess I should leave him alone."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"The park. Now that's an erotic place to go."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY		8
	DB	"There are many couples, walking together. I wonder if there are many of them hiding in the bushes?"
	DB	NEXT
	DB	"Terumi:  What are you doing here?"
	DB	NEXT
	DB	"I turn at the voice to see Terumi-senpai standing there."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AI1,"LOOK AT BREASTS"
	MENU_SET	AI2,"LOOK AT ASS"
	MENU_SET	AI3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_1
	FLG_KI TER_NET,'=',1
JOJO_1:
	DB	"She has excellent breasts. Lots of volume."
	DB	NEXT
	GO BODY_TERMI_2
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',11
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_2
	FLG_KI TER_NET,'=',1
JOJO_2:
	DB	"Her ass is small and hard, with a great waistline."
	DB	NEXT
	GO BODY_TERMI_2
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_3
	FLG_KI TER_NET,'=',1
JOJO_3:
	DB	"Her thighs are soft and supple."
	DB	NEXT
	GO BODY_TERMI_2
BODY_TERMI_2:
	DB	"Terumi:  W- Why did you get so quiet like that?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing. What are you here?"
	DB	NEXT
	DB	"Terumi:  I'm just out for a walk."
	DB	NEXT
	DB	"Kenjirou:  In a dark, dangerous place like this?"
	DB	NEXT
	DB	"Terumi:  Are you worried about me?" 
	DB	NEXT
	DB	"She looks somehow happy."
	DB	NEXT
	DB	"Kenjirou:  Yes, worried about anyone who tried to attack you..."
	DB	NEXT
	DB	"Terumi:  What did you say?" 
	DB	NEXT
	DB	"Kenjirou:  I- I'm sorry!"
	DB	NEXT
	DB	"I leave the park in a hurry."
	DB	NEXT
	GO MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"This is the love hotel. I've never been inside."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"There's a big lit-up sign here."
	DB	NEXT
	DB	"There's no reason to stand around here. Guess I'll leave."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"There's no reason for me to go inside."
	DB	NEXT
	DB	"I guess there's no problem with me standing outside though."
	DB	NEXT
	DB	"I head for the bar."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB	"Hiroshi:  What are you doing here?"
	DB	NEXT
	DB	"It's Hiroshi!"
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing. I was just walking by. See you later."
	DB	NEXT
	DB	"I leave the area around the bar."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"The coffee shop. I wonder if Rena's still there?"
	DB	NEXT
	BAK_INIT 'tb_021',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB	"Rena:  Hello, can I help..."
	DB	T_WAIT, 5
	DB	" Oh, it's you, Kenjirou." 
	DB	NEXT
	DB	"Kenjirou:  You shouldn't say things like that!"
	DB	NEXT
	DB	"Rena:  But 'Can I help you?' is something we say to customers. You're a friend."
	DB	NEXT
	DB	"Kenjirou:  I know. I was just pulling your chain."
	DB	NEXT
	DB	"Kenjirou:  Aren't you cold, dressed up like that?"
	DB	NEXT
	DB	"Rena:  No, I'm fine." 
	DB	NEXT
	DB	"Kenjirou:  I see. (She looks a little cold to me.)"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AJ1,"LOOK AT NECK"
	MENU_SET	AJ2,"LOOK AT SHOULDER"
	MENU_SET	AJ3,"LOOK AT BREASTS"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_1
	FLG_KI RENA_NET,'=',1
JJ_1:
	DB	"A white, thin neck... I want to lick it, once more."
	DB	NEXT
	GO BODY_RENA_2
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_2
	FLG_KI RENA_NET,'=',1
JJ_2:
	DB	"Her shoulders look firm and erotic. I'd love to pull her to me."
	DB	NEXT
	GO BODY_RENA_2
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_3
	FLG_KI RENA_NET,'=',1
JJ_3:
	DB	"I can't tell much from her apron, but they look great to me."
	DB	NEXT
	GO BODY_RENA_2
BODY_RENA_2:
	DB	"Rena:  Ah, your eyes." 
	DB	T_WAIT, 5
	DB	" They were looking at dirty places."
	DB	NEXT
	DB	"Kenjirou:  I was born this way."
	DB	NEXT
	DB	"Rena:  Well, you and I aren't dating any more, so don't get any ideas." 
	DB	NEXT
	DB	"Kenjirou:  I know. "
	DB	NEXT
	DB	"Rena:  Then okay." 
	DB	NEXT
	DB	"Rena patted my head, like a dog."
	DB	NEXT
	DB	"Kenjirou:  Haha..."
	DB	T_WAIT, 5
	DB	" Thanks."
	DB	NEXT
	DB	"I leave the coffee shop."
	DB	NEXT
	GO MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"I'm not really hungry, but I guess I could go there."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	DB	"Nana:  Hello, can I help you?" 
	DB	NEXT
	DB	"Kenjirou:  Ah, she's here."
	DB	NEXT
	DB	"Nana:  What would you like, sir?" 
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AK1,"LOOK AT BREASTS"
	MENU_SET	AK2,"LOOK AT BREASTS"
	MENU_SET	AK3,"LOOK AT BREASTS"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_1
	FLG_KI NANA_NET,'=',1
II_1:
	DB	"They're great. What more can I say?"
	DB	NEXT
	GO BODY_NANA_2
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_2
	FLG_KI NANA_NET,'=',1
II_2:
	DB	"Wonderful breasts."
	DB	NEXT
	GO BODY_NANA_2
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_3
	FLG_KI NANA_NET,'=',1
II_3:
	DB	"I want to rip that uniform off her."
	DB	NEXT
	GO BODY_NANA_2
BODY_NANA_2:
	DB	"Nana:  What would you like?"
	DB	NEXT
	DB	"Kenjirou:  Breasts..."
	DB	NEXT
	DB	"Nana:  I'm sorry, we don't have that item here at this restaurant." 
	DB	NEXT
	DB	"Kenjirou:  Oh, then I'll leave."
	DB	NEXT
	DB	"Nana:  Thank you very much." 
	DB	NEXT
	DB	"I leave the fast-food restaurant."
	DB	NEXT
	GO MATI
AH8:
	DB	"Guess I should go home."
	DB	NEXT
	GO	JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB	"I'm hungry."
	DB	T_WAIT,	3
	DB	" Time to go home."
	DB	NEXT
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ah, it's good to be home."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Kenjirou:  I'm home."
	DB	NEXT
	DB	"Akemi:  Hello."
	DB	NEXT
	DB	"Kenjirou:  Where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She's not back yet." 
	DB	NEXT
	DB	"Kenjirou:  I see. "
	DB	NEXT
	DB	"Akemi:  Shall I start dinner?"
	DB	NEXT
	DB	"Kenjirou:  ...Sure, thanks."
	DB	NEXT
	DB	"Akemi:  Okay."
	DB	NEXT
	DB	"I ate a lonely dinner with Akemi-san. She wrapped up Motoka's portion for later."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY		12
	DB	"It's 10 pm, and Motoka still isn't back."
	DB	NEXT
	DB	"Kenjirou:  Where is that girl...?"
	DB	NEXT
	DB	"Just then, I hear small steps in the foyer."
	DB	NEXT
	DB	"I should probably leave her alone for a while."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"I turn out the light, and prepare for sleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',3,NUKE
	GO	SMK
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI	YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Uuuunnn..."
	DB	NEXT
	DB	"I slowly open my eyes."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  Where am I?"
	DB	NEXT
	DB	"I was confused, but it was slowly coming back to me. I was in my own room."
	DB	NEXT
	DB	"How did I get back here?"
	DB	NEXT
	DB	"There's a brown stain on my clothes."
	DB	NEXT
	DB	"Blood? I had a nosebleed."
	DB	NEXT
	DB	"What happened after that?"
	DB	NEXT
	DB	"I must have lost consciousness."
	DB	NEXT
	DB	"Someone must have carried me back to my room."
	DB	NEXT
	DB	"I look at the clock. It read 9:30."
	DB	NEXT
	DB	"Is Motoka home yet?"
	DB	NEXT
	DB	"I get dressed and leave my room."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"I knocked on Motoka's door, but there was no reply."
	DB	NEXT
	DB	"Kenjirou:  Maybe she's in the dining kitchen..."
	DB	NEXT
	DB	"I head for the dining kitchen."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB	"Her dinner is still on the table, still wrapped up as it was last night. It seems she didn't come home last night."
	DB	NEXT
	DB	"Kenjirou:  She didn't come home."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"I go back to my room, and lie down on the bed. I knew I had heard footsteps in the foyer at 10 pm, and I'm sure it was her."
	DB	NEXT
	DB	"I try to get out of bed, but Akemi's words come back to me."
	DB	NEXT
	DB	"Trust in Motoka..."
	DB	T_WAIT, 3
	DB	" I guess she's right."
	DB	NEXT
	DB	"I shouldn't worry about her so much. I'm sure she's fine."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"I turn out the light, and prepare for sleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',3,NUKE
	GO	SMK
NUKE:
	FLG_KI	KURI,'=',0
	SINARIO 'MON_24.OVL'
END