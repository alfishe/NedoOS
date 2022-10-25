        include SUPER_C.inc
M_START:
MON_21
	FLG_IF JUMP,'=',62,FUFUFU_1
	CDPLAY		12
	BAK_INIT 'tb_001a',B_NORM
	DB	"I didn't get much sleep..."
	DB	NEXT
	DB	"I guess I'll get dressed, and go eat breakfast."
	DB	NEXT
	DB	"I change into my uniform, and head down to the dining kitchen."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		20
	T_CG 'tt_21_02',MOT_A3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Motoka:  Ah, good morning." 
	DB	NEXT
	DB	"Kenjirou:  Good morning..."
	DB	NEXT
	DB	"Akemi:  Good morning."
	DB	NEXT
	DB	"Motoka:  Mother, I'm going now..." 
	DB	NEXT
	DB	"Akemi:  Have a nice day."
	DB	NEXT
	TATI_ERS		;Tt_21
	T_CG 'tt_20_02',AKE_A2,0
	CDPLAY		6
	DB	"Akemi:  Kenjirou-kun, I'm not sure what's going on between the two of you, but I wish you'd trust her a little more."
	DB	NEXT
	DB	"Kenjirou:  You're right..."
	DB	NEXT
	DB	"After that, I picked up my bag and went to school."
	DB	NEXT
	BAK_INIT 'tb_006',B_NORM
	CDPLAY	2
	DB	"The convenience store."
	DB	NEXT
	DB	"I'm not really hungry now, but I guess I'll stop off."
	DB	NEXT
	DB	"I head inside."
	DB	NEXT
	BAK_INIT 'tb_007',B_NORM
	CDPLAY		3
	DB	"Terumi-senpai is here."
	DB	NEXT
	DB	"I meet her here quite often."
	DB	NEXT
	T_CG 'tt_05_07',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai. Good morning."
	DB	NEXT
	DB	"Terumi:  Good morning. What's wrong? You seem depressed."
	DB	NEXT
	DB	"Kenjirou:  It's nothing. I'm just tired."
	DB	NEXT
	DB	"Terumi:  I'll bet you were watching those adult videos again." 
	DB	NEXT
	DB	"Kenjirou:  ...Well, a few."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	R1,"INVITE TERUMI-SENPAI"
	MENU_SET	R2,"GO TO SCHOOL"
	MENU_END
	DB	EXIT
R1:
	DB	"Kenjirou:  ......"
	DB	T_WAIT, 5
	DB	"Terumi-senpai, shall we go to school now?"
	DB	NEXT
	DB	"Terumi:  Eh? Oh, sure, but what about your lunch?"
	DB	NEXT
	DB	"Kenjirou:  Oops. I'll get it now."
	DB	NEXT
	DB	"I pick up one rice ball and head for the register."
	DB	NEXT
	DB	"Kenjirou:  Thanks for waiting. Let's go."
	DB	NEXT
	DB	"Terumi:  Okay." 
	DB	NEXT
	DB	"I put my rice ball in my bag, and we leave the store."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO GAKU1
R2:
	DB	"Kenjirou:  Well, I'll see you later, Terumi-senpai..."
	DB	NEXT
	DB	"I leave for school alone."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_009',B_NORM
	DB	"It's really crowded."
	DB	NEXT
	DB	"Voice:  Kenjirou-kun."
	DB	NEXT
	DB	"I turn around at the sound of the voice."
	DB	NEXT
	T_CG 'tt_02_09',SIH_A2,0
	DB	"Shiho:  Kenjirou-kun, good morning."
	DB	NEXT
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Shiho:  What's wrong? You don't seem very happy today." 
	DB	NEXT
	DB	"Shiho's eyes take on a worried look."
	DB	NEXT
	DB	"Kenjirou:  ...I didn't get much sleep last night."
	DB	NEXT
	DB	"Shiho:  That's bad. You really need to get enough sleep every day." 
	DB	NEXT
	DB	"Kenjirou:  You're right."
	DB	NEXT
	DB	"Shiho:  Well..."
	DB	T_WAIT, 5
	DB	" Shall we go to school?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	S1,"GO WITH HER"
	MENU_SET	S2,"GO ALONE"
	MENU_END
	DB	EXIT
S1:
	DB	"Kenjirou:  Okay, let's go."
	DB	NEXT
	DB	"Shiho:  Okay." 
	DB	NEXT
	DB	"I headed for school with Shiho at my side."
	DB	NEXT
	GO GAKU2
S2:
	DB	"Kenjirou:  I'm sorry, I want to go alone."
	DB	NEXT
	DB	"Shiho:  ...Okay..." 
	DB	NEXT
	DB	"I headed for school alone."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO GAKU1
GAKU1:
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	T_CG 'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Good morning."
	DB	NEXT
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Tetsuya:  How are you, today?"
	DB	NEXT
	DB	"Kenjirou:  I'm okay..."
	DB	NEXT
	DB	"Tetsuya:  Really? I feel just great."
	DB	NEXT
	DB	"Kenjirou:  .................."
	DB	NEXT
	DB	"Tetsuya:  You're supposed to react, do something!" 
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Just then, the bell rang. It was time for class to start."
	DB	NEXT
	DB	"Kenjirou:  I'm sorry, I'm just tired."
	DB	NEXT
	DB	"Tetsuya:  .................." 
	DB	NEXT
	TATI_ERS		;tt_08
	DB	"I sat down at my desk."
	DB	NEXT
	F_O B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"I stared at the blackboard as class began."
	DB	NEXT
	DB	"My mind kept drifting back to Motoka and last night, and I couldn't concentrate on class."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO HIRU_1
GAKU2:
	CDPLAY		14
	BAK_INIT 'tb_010',B_NORM
	T_CG 'tt_02_10',SIH_A1,0
	T_CG 'tt_08_10',TET_A3,0
	DB	"Tetsuya:  Good morning, Kashima-san."
	DB	NEXT
	DB	"Shiho:  Good morning."
	DB	NEXT
	DB	"Kenjirou:  ..............."
	DB	NEXT
	DB	"I sat down at my desk."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"I stared at the blackboard as class began."
	DB	NEXT
	DB	"Motoka kept coming back to me in my mind, making me unable to concentrate on class."
	DB	NEXT
	B_O B_FADE,C_KURO
	F_O B_NORM,C_KURO
	DB	"The next thing I knew, it was lunchtime."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	T_CG 'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Um, Kenjirou?" 
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  Well..." 
	DB	NEXT
	DB	"Kenjirou:  What is it?"
	DB	NEXT
	DB	"Tetsuya:  Don't get mad, okay?" 
	DB	NEXT
	DB	"Kenjirou:  Get mad? Why?"
	DB	NEXT
	DB	"Tetsuya:  ...It's about Motoka." 
	DB	NEXT
	DB	"Kenjirou:  .................."
	DB	NEXT
	DB	"Tetsuya:  I think those rumors I told you about are true."
	DB	NEXT
	DB	"Kenjirou:  ...Why do you say that?"
	DB	NEXT
	DB	"Tetsuya:  Well, I saw a girl who really looked like Motoka walking with some bad people."
	DB	NEXT
	DB	"Kenjirou:  ...Did you really see that?"
	DB	NEXT
	DB	"Tetsuya:  I did. I was kind of far away, though, so I can't say one hundred per cent that it was her."
	DB	NEXT
	DB	"Kenjirou:  ...It wasn't her. She was at home last night."
	DB	NEXT
	DB	"Tetsuya:  Really? Oh, great, I'm glad it wasn't her. I'm really relieved. " 
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Just then, the bell rang, and Tetsuya sat down in his seat."
	DB	NEXT
	TATI_ERS	;tt_08
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"...I lied to Tetsuya."
	DB	NEXT
	DB	"Feeling awful for lying to a friend, I slept again."
	DB	NEXT
	;WAV  'STOP'
	B_O B_FADE,C_KURO
HIRU_1:
	FLG_KI JUMP,'=',62
	SINARIO 'NITI_HOK.OVL'
FUFUFU_1:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"The sun had set in the sky. These days, it really gets dark early."
	DB	NEXT
	DB	"I guess I won't go straight home."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	GO SENTAKU
MATI:
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"Where should I go?"
	DB	NEXT
SENTAKU:
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
	FLG_IF TEMP08,'=',0,SA_7
	FLG_KI W,'DOWN',6
SA_7:
	FLG_IF REN_ATTA,'=',1,SA_8
	FLG_KI W,'DOWN',5
SA_8:
	FLG_IF NAN_ATTA,'=',1,SA_9
	FLG_KI W,'DOWN',6
SA_9:
	MENU_S 2,W,-1
	MENU_SET	AH1,"MOVIE THEATRE"
	MENU_SET	AH2,"LINGERIE PUB"
	MENU_SET	AH3,"PARK"
	MENU_SET	AH4,"LOVE HOTEL"
	MENU_SET	AH5,"BAR"
	MENU_SET	AH6,"COFFEE SHOP"
	MENU_SET	AH7,"RESTAURANT"
	MENU_SET	AH8,"GO HOME"
	MENU_END
	DB EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"I guess I'll check out the movie theatre."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"This place is really run down."
	DB	NEXT
	DB	"Well, it's back here away from where all the people walk. It's to be expected."
	DB	NEXT
	DB	"There's nothing I want to see. Guess I'll go back."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Guess I'll go to the lingerie pub."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"Man, whoever thought of these places is a genius. Talk about a concept that reaches out to the Heart of Man."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Tetsuya:  What are you doing here?"
	DB	NEXT
	DB	"Tetsuya is here."
	DB	NEXT
	DB	"Kenjirou:  Me? What about you?"
	DB	NEXT
	DB	"Tetsuya:  Me? I'm just thinking how nice it would be to go inside..." 
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  Don't you think so?"
	DB	NEXT
	DB	"Kenjirou:  About what?"
	DB	NEXT
	DB	"Tetsuya:  Don't you want to go in here, and get the full service?" 
	DB	NEXT
	DB	"Kenjirou:  ...Well, sure."
	DB	NEXT
	DB	"Tetsuya:  See? Ah, just once, that's all I ask..." 
	DB	NEXT
	DB	"He stares at the sign to the lingerie pub with lust in his eyes. "
	DB	NEXT
	DB	"I'd better leave him alone."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"The park. That sounds like fun."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY		8
	DB	"There are lots of couples walking arm in arm here. I wonder how many there are in the bushes?"
	DB	NEXT
	DB	"Terumi:  What are you doing here?"
	DB	NEXT
	DB	"It's a voice I've heard before. I turn to see Terumi-senpai standing there."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AI1,"LOOK AT TITS"
	MENU_SET	AI2,"LOOK AT ASS"
	MENU_SET	AI3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI TER_NET,'=',1
LA_1:
	DB	"Her tits are wonderful. Lots of volume there."
	DB	NEXT
	GO BODY_TERUMI
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_2
	FLG_KI TER_NET,'=',1
LA_2:
	DB	"She's got a nice, soft ass, with a great curve from the hip."
	DB	NEXT
	GO BODY_TERUMI
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI TER_NET,'=',1
LA_3:
	DB	"Her thighs are soft and smooth. Mmmm."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Terumi:  W- What's wrong? You got quiet all of the sudden." 
	DB	NEXT
	DB	"Kenjirou:  Eh? O- Oh, nothing. Anyway, what are you doing here alone like this?"
	DB	NEXT
	DB	"Terumi:  I'm just out for a walk."
	DB	NEXT
	DB	"Kenjirou:  Alone? Out here in the dark like this?"
	DB	NEXT
	DB	"Terumi:  Are you worrying about me?"
	DB	NEXT
	DB	"She looks happy for a moment."
	DB	NEXT
	DB	"Kenjirou:  Yes, I'm worried you might get attacked..."
	DB	NEXT
	DB	"Terumi:  W- What did you say?" 
	DB	NEXT
	DB	"Kenjirou:  I- I'm sorry!"
	DB	NEXT
	DB	"I got out of there, fast."
	DB	NEXT
	GO MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"The love hotel. I've never been inside."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"There's a sign here, advertising the rates of the hotel."
	DB	NEXT
	DB	"This isn't the best place to be standing alone."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"I don't really want to go in there."
	DB	NEXT
	DB	"I guess I'll go out in front and see what's up."
	DB	NEXT
	DB	"I head for the bar."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB	"Hiroshi:  What are you doing here?" 
	DB	NEXT
	DB	"Oh no! It's Hiroshi!"
	DB	NEXT
	DB	"Kenjirou:  Oh, I was just passing by. Well, I'll see you later."
	DB	NEXT
	DB	"I leave the bar."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"The coffee shop... I wonder if Rena's still working there."
	DB	NEXT
	BAK_INIT 'tb_21',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB	"Rena:  Can I help..." 
	DB	T_WAIT, 5
	DB	" Oh, it's just you, Kenjirou."
	DB	NEXT
	DB	"Kenjirou:  You're not even going to welcome me to the shop?"
	DB	NEXT
	DB	"Rena:  But that's for customers. You're different."
	DB	NEXT
	DB	"Kenjirou:  Yes, yes. I know why I'm getting the cold shoulder."
	DB	NEXT
	DB	"Rena:  Sorry..."
	DB	NEXT
	DB	"Kenjirou:  By the way, aren't you cold, dressed up like that?"
	DB	NEXT
	DB	"Rena:  I'm just fine, actually."
	DB	NEXT
	DB	"Kenjirou:  Okay. (She looks cold to me.)"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AJ1,"LOOK AT NECK"
	MENU_SET	AJ2,"LOOK AT SHOULDER"
	MENU_SET	AJ3,"LOOK AT TITS"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI RENA_NET,'=',1
LL_1:
	DB	"She's got a nice, white neck, good for kissing."
	DB	NEXT
	GO BODY_RENA
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI RENA_NET,'=',1
LL_2:
	DB	"Soft, feminine shoulders. Good for holding a girl to you."
	DB	NEXT
	GO BODY_RENA
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI RENA_NET,'=',1
LL_3:
	DB	"I can't see her breasts through her apron. But they're milky white and so soft..."
	DB	NEXT
BODY_RENA:
	DB	"Rena:  Ah, your eyes." 
	DB	T_WAIT, 5
	DB	" You're thinking evil thoughts, aren't you?"
	DB	NEXT
	DB	"Kenjirou:  I admit it. "
	DB	NEXT
	DB	"Rena:  There's nothing between us anymore, okay? That's in the past."
	DB	NEXT
	DB	"Kenjirou:  I know. (But I've got my regrets)"
	DB	NEXT
	DB	"Rena:  Then okay." 
	DB	NEXT
	DB	"She patted me once on the head."
	DB	NEXT
	DB	"Kenjirou:  Haha..."
	DB	T_WAIT, 5
	DB	" Thanks."
	DB	NEXT
	DB	"That's why I have regrets, of course..."
	DB	NEXT
	DB	"I leave the coffee shop."
	DB	NEXT
	GO MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"I'm not hungry, but what the heck. I can go there."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	DB	"Nana:  Hello, can I help you?"
	DB	NEXT
	DB	"Kenjirou:  Ah, you're here. Great."
	DB	NEXT
	DB	"Nana:  What would you like to order?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AK1,"LOOK AT TITS"
	MENU_SET	AK2,"LOOK AT TITS"
	MENU_SET	AK3,"LOOK AT TITS"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_1
	FLG_KI NANA_NET,'=',1
LS_1:
	DB	"Great breasts. "
	DB	NEXT
	GO BODY_NANA
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_2
	FLG_KI NANA_NET,'=',1
LS_2:
	DB	"Wonderful breasts."
	DB	NEXT
	GO BODY_NANA
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_3
	FLG_KI NANA_NET,'=',1
LS_3:
	DB	"They look like they're going to rip through her uniform any second."
	DB	NEXT
	GO BODY_NANA
BODY_NANA:
	DB	"Nana:  What would you like to order?"
	DB	NEXT
	DB	"Kenjirou:  Breasts..."
	DB	NEXT
	DB	"Nana:  I'm sorry, we don't have that at this restaurant."
	DB	NEXT
	DB	"Kenjirou:  Then never mind."
	DB	NEXT
	DB	"Nana:  Thank you very much. Please come again."
	DB	NEXT
	DB	"I leave the restaurant."
	DB	NEXT
	GO MATI
AH8:
	DB	"Guess I'll go home now..."
	DB	NEXT
	GO JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Well, time to head home."
	DB	NEXT
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ah, there's nothing as nice as seeing home after a long day."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Kenjirou:  I'm home."
	DB	NEXT
	DB	"Akemi:  Welcome home."
	DB	NEXT
	DB	"Kenjirou:  Where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She's not home yet." 
	DB	NEXT
	DB	"Kenjirou:  I see. (Again...?)"
	DB	NEXT
	DB	"Akemi:  Shall we have dinner?" 
	DB	NEXT
	DB	"Kenjirou:  ...Sure, sounds good."
	DB	NEXT
	DB	"Akemi:  Okay."
	DB	NEXT
	DB	"The two of us had a quiet dinner. Akemi put Motoka's portion aside for later."
	DB	NEXT
	B_O B_FADE,C_KURO
	SINARIO 'MON_22.OVL'
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Unnngh...?"
	DB	NEXT
	DB	"I slowly open my heavy eyelids."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Where am I?"
	DB	NEXT
	DB	"I look around me. I seem to be in my own room."
	DB	NEXT
	DB	"But how did I get here?"
	DB	NEXT
	DB	"I look down to see a brown stain on my clothes."
	DB	NEXT
	DB	"Blood? Oh, I had a nosebleed..."
	DB	NEXT
	DB	"What happened after that?"
	DB	NEXT
	DB	"I must have lost consciousness."
	DB	NEXT
	DB	"Someone must have brought me back here. But who?"
	DB	NEXT
	DB	"I look at the clock. It reads half past nine."
	DB	NEXT
	DB	"I wonder if Motoka's home?"
	DB	NEXT
	DB	"I change my clothes and head for Motoka's room."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"I knock several times on the door. There's no answer."
	DB	NEXT
	DB	"Maybe she's in the dining kitchen."
	DB	NEXT
	DB	"I head downstairs."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB	"On the table, Motoka's dinner is still there, wrapped with plastic wrap."
	DB	NEXT
	DB	"So, she's not home yet."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"I head back to my room, and lie down, waiting for Motoka to come home. Around 10 pm, I hear sounds coming from the foyer."
	DB	NEXT
	DB	"I start to get up, but remember the words of Akemi this morning."
	DB	NEXT
	DB	"She told me to trust Motoka..."
	DB	T_WAIT, 3
	DB	" Well, I guess I can do that."
	DB	NEXT
	DB	"Motoka will be fine. I've got to trust her."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"I turn out the light, and sleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_22.OVL'
END