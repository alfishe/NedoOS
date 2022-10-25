        include SUPER_C.inc
M_START:
NITI_HIR
	FLG_IF HOK,'=',6,KYOUSITU
	FLG_IF HAND,'=',5,TOIRE
	F_O	B_NORM,C_KURO
	FLG_IF	MOTSUNE,'=',2,TETUKURU
	CDPLAY	14
	DB	"It's lunch time."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"I quickly eat my lunch and head out into the hallway."
	DB	NEXT
MODO:
	BAK_INIT	'tb_034a',B_NORM
	DB	"Kenjirou:  Well, I guess I'll go look for some dessert."
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
TETUKURU:
	FLG_KI	MOTSUNE,'=',3
	DB	"Tetsuya:  Hey, wake up." 
	DB	NEXT
	DB	"Kenjirou:  Nn?"
	DB	NEXT
	DB	"Tetsuya:  It's lunchtime, man."
	DB	NEXT
	DB	"Kenjirou:  Okay, I'm awake."
	DB	NEXT
	DB	"At Tetsuya's prompting, I take my head off the desk where I had been sleeping."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  I want to ask you a question."
	DB	NEXT
	DB	"Kenjirou:  Don't worry, I'm not seeing Shiho or anything."
	DB	NEXT
	DB	"Tetsuya:  I know that. No, I want to ask you about Motoka."
	DB	NEXT
	DB	"Kenjirou:  When you're done with Shiho, you want to go for my sister? I'm sorry, "
        DB      "but I don't think a guy who watches porno videos as much as you do is right for my sister."
	DB	NEXT
	DB	"Tetsuya:  Would you listen to me?"
	DB	NEXT
	DB	"Kenjirou:  Okay, what?"
	DB	NEXT
	DB	"Tetsuya:  I saw something on the way to school. Motoka was walking with Hara. " 
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  Are she and Hara going out or something?"
	DB	NEXT
	DB	"Kenjirou:  No, I'm sure of it."
	DB	NEXT
	DB	"Tetsuya:  That guy has a habit of using women, you know. I thought I'd warn you."
	DB	NEXT
	DB	"Kenjirou:  Hmm, I knew that Hiroshi was going for her, of course."
	DB	NEXT
	DB	"Tetsuya:  Aren't you worried?"
	DB	NEXT
	DB	"Kenjirou:  I'd be lying if I said that, but Motoka is over eighteen, "
        DB      "and was smart enough to avoid Hiroshi. I told him to lay off, too."
	DB	NEXT
	DB	"Tetsuya:  But they were walking to school together."
	DB	NEXT
	DB	"Kenjirou:  The route they walk is the same, isn't it? Maybe it was just a coincidence."
	DB	NEXT
	DB	"Tetsuya:  Maybe..."
	DB	T_WAIT,	3
	DB	" But I'm still a little worried."
	DB	NEXT
	DB	"Kenjirou:  I know what you mean."
	DB	NEXT
	DB	"Tetsuya:  Well, I'm going to go play some ball. Are you coming?"
	DB	NEXT
	DB	"Kenjirou:  I'll go next time."
	DB	NEXT
	DB	"Tetsuya:  Okay. But you should get more exercise, you know."
	DB	NEXT
	DB	"Kenjirou:  I know."
	DB	NEXT
	TATI_ERS
	DB	"Tetsuya runs out of the room."
	DB	NEXT
	DB	"Kenjirou:  I guess I'll leave, too."
	DB	NEXT
	DB	"I go out into the hall."
	DB	NEXT
	GO	MODO
ROUKA:
	CDPLAY	14
	BAK_INIT	'tb_034a',B_NORM
	DB	"Where should I go?"
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
	MENU_SET	T1,"RETURN TO CLASSROOM"
	MENU_SET	T2,"ROOF"
	MENU_SET	T3,"MOTOKA'S CLASSROOM"
	MENU_SET	T4,"PE STORAGE ROOM"
	MENU_SET	T5,"ART ROOM"
	MENU_SET	T6,"MEN'S ROOM"
	MENU_SET	T7,"NURSE'S OFFICE"
	MENU_END
	DB	EXIT
T1:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI	SIH_KAIS,'+',1
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB	"I head back to my own room."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	T_CG 'tt_02_10',SIH_A2,0
	DB	"I start to leave the room, when Shiho appears suddenly."
	DB	NEXT
	DB	"Shiho:  Ah, Kenjirou-kun."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	U1,"LOOK AT FACE"
	MENU_SET	U2,"LOOK AT TITS"
	MENU_SET	U3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
U1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Shiho has a lovely face. Almost perfect."
	DB	NEXT
	GO BODY_SHIHO
U2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Her uniform keeps me from seeing her breasts' true size, but they look to be great."
	DB	NEXT
	GO BODY_SHIHO
U3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Excellent thighs, white, with just enough meat on them."
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
	DB	"Hmm, I don't want to pollute her any more with this."
	DB	NEXT
	DB	"Shiho:  What's wrong?" 
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing."
	DB	NEXT
	DB	"Shiho:  Really? Well, I'll see you later. I'm off to the library."
	DB	NEXT
	TATI_ERS
	DB	"Shiho leaves the room."
	DB	NEXT
	DB	"Guess I'll leave, too."
	DB	NEXT
	GO ROUKA
T2:
	FLG_IF	TEMP01,'>=',2,KYOUSITU
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP03,'=',1
	DB	"Kenjirou:  Guess I'll go to the roof."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	FLG_IF	TERUNASI,'=',1,TERUINAI
	DB	"Over by the chain link fence, I see Terumi-senpai, standing alone."
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
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT1
	FLG_KI	TER_NET,'=',1
TER_TAT1:
	DB	"She has wonderful breasts, although I can't see all that well because of her right hand."
	DB	NEXT
	GO BODY_TERUMI
V2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT2
	FLG_KI	TER_NET,'=',1
TER_TAT2:
	DB	"Terumi-senpai's ass. She has a great curve going from her waist to her hip -- very erotic."
	DB	NEXT
	GO BODY_TERUMI
V3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT3
	FLG_KI	TER_NET,'=',1
TER_TAT3:
	DB	"Terumi-senpai's thighs. Her legs go all the way up."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Terumi:  What's the matter? Hadn't you seen my body before?"
	DB	NEXT
	DB	"Kenjirou:  I- I wasn't looking! Um, anyway, what are you doing up here?"
	DB	NEXT
	DB	"Terumi:  Oh, nothing special. Just wandering around."
	DB	T_WAIT, 5
	DB	" What about you?"
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing. Just wandering around, too."
	DB	NEXT
	DB	"Terumi:  We both have a lot of time to kill."
	DB	NEXT
	DB	"Kenjirou:  Yes, I guess."
	DB	NEXT
	DB	"Suddenly, Terumi-senpai put her hand on my arm, as if to move the conversation into a new area."
	DB	NEXT
	DB	NEXT
	DB	"Kenjirou:  Well, I'll be seeing you, Terumi-senpai. Bye!"
	DB	NEXT
	DB	"Terumi:  Wait!" 
	DB	NEXT
	DB	"Unsure of why I was running, I descended the stairs."
	DB	NEXT
	GO	ROUKA
TERUINAI:
	DB	"I look around, but don't see Terumi-senpai."
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai's not here..."
	DB	NEXT
	DB	"Guess there's nothing for me to do up here."
	DB	NEXT
	DB	"I go back downstairs."
	DB	NEXT
	GO	ROUKA
T3:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP04,'=',1
	FLG_IF	MOTSUNE,'!=',0,MOTOINAI
	DB	"Seeing me, Motoka runs over."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG 'tt_10_10',MOT_A2,0
	DB	"Motoka:  Oniichan!" 
	DB	NEXT
	DB	"Motoka:  What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  Nothing..."
	DB	NEXT
	DB	"Motoka:  Nothing? It doesn't sound like it. Why did you come by?" 
	DB	NEXT
	DB	"Kenjirou:  Oh, no reason."
	DB	NEXT
	DB	"Motoka:  Ah, I know! You wanted to see my pretty face!" 
	DB	NEXT
	DB	"Kenjirou:  No, I was just passing by, and..."
	DB	NEXT
	DB	"Motoka:  Liar!" 
	DB	NEXT
	DB	"Motoka:  ...But I guess it's all the same, right? "
	DB	NEXT
	DB	"I'd better not hang around. If I get caught up in her pace, I'll never get out of here."
	DB	NEXT
	DB	"Kenjirou:  Well, bye."
	DB	NEXT
	DB	"Motoka:  Wait, Oniichan!" 
	DB	NEXT
	DB	"I go back out into the hallway."
	DB	NEXT
	GO	ROUKA
MOTOINAI:
	BAK_INIT	'tb_010',B_NORM
	DB	"Kenjirou:  What? I wonder where Motoka is."
	DB	NEXT
	GO	ROUKA
T4:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP05,'=',1
	DB	"I guess I'll see what's inside the PE storage room."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Tetsuya is here, looking for something."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Kenjirou:  Tetsuya, what are you doing here?"
	DB	NEXT
	DB	"Tetsuya:  Ah, Kenjirou. I'm trying to find a good ball to use. What about you?"
	DB	NEXT
	DB	"Kenjirou:  I'm just wandering around. "
	DB	NEXT
	DB	"Tetsuya:  Really? Why don't you help me...?"
	DB	NEXT
	DB	"Kenjirou:  Sorry, gotta go..."
	DB	NEXT
	DB	"I leave the PE storage room."
	DB	NEXT
	GO ROUKA
T5:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP06,'=',1
	DB	"I guess I'll go see my sweet peach."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY	18
	DB	"Mika-sensei is dusting her statues."
	DB	NEXT
	DB	"Kenjirou:  Mika-sensei."
	DB	NEXT
	DB	"Mika:  Ah, Kondo-kun."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	X1,"LOOK AT TITS"
	MENU_SET	X2,"LOOK AT ASS"
	MENU_SET	X3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
X1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_1
	FLG_KI MIKA_NET,'=',1
WW_1:
	DB	"Her arms are hiding her breasts, but they look good to me."
	DB	NEXT
	GO BODY_MIKA
X2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_2
	FLG_KI MIKA_NET,'=',1
WW_2:
	DB	"A nice ass, firm and beautiful."
	DB	NEXT
	GO BODY_MIKA
X3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_3
	FLG_KI MIKA_NET,'=',1
WW_3:
	DB	"Nice shape, not too big and not too bony."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Mika:  ...Were you looking somewhere you shouldn't have been?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? I don't know what you mean?"
	DB	NEXT
	DB	"Mika:  Oh, never mind."
	DB	NEXT
	DB	"Mika:  I'm glad you made it here on time."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Mika:  ...Don't tell me you forgot!"
	DB	NEXT
	DB	"Oh no! I did forget...!"
	DB	NEXT
	DB	"Kenjirou:  I- I'll see you later, sensei..."
	DB	NEXT
	DB	"Mika:  Wait, Kondo-kun!" 
	DB	NEXT
	DB	"I leave Mika-sensei and the art room behind me."
	DB	NEXT
	GO ROUKA
T6:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP07,'=',1
	DB	"I head for the men's room."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	T_CG 'tt_03_17a',HIR2,0
	DB	"I meet Hiroshi on his way out of the stall."
	DB	NEXT
	DB	"Hiroshi:  Oh, Kondo. Hello."
	DB	NEXT
	DB	"Kenjirou:  Um, hi."
	DB	NEXT
	DB	"Hiroshi:  Well, see you."
	DB	NEXT
	TATI_ERS	;TT_03
	DB	"The second stall from the back is my office. It's empty, as usual."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	Y1,"ENTER OFFICE"
	MENU_SET	Y2,"GO OUTSIDE"
	MENU_END
	DB	EXIT
Y1:
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'=',0,DD_1
	FLG_KI HAND,'=',5
	SINARIO 'AK_H.OVL'
DD_1:
	FLG_IF MIKA_NET,'=',0,DD_2
	FLG_KI HAND,'=',5
	SINARIO 'MI_H.OVL'
DD_2:
	FLG_IF TER_NET,'=',0,DD_3
	FLG_KI HAND,'=',5
	SINARIO 'TE_H.OVL'
DD_3:
	FLG_IF RENA_NET,'=',0,DD_4
	FLG_KI HAND,'=',5
	SINARIO 'RE_H.OVL'
DD_4:
	FLG_IF NANA_NET,'=',0,DD_5
	FLG_KI HAND,'=',5
	SINARIO 'NA_H.OVL'
DD_5:
	FLG_IF SIZU_NET,'=',0,DD_6
	FLG_KI HAND,'=',5
	SINARIO 'SI_H.OVL'
DD_6:
	FLG_IF CHIE_NET,'=',0,DD_7
	FLG_KI HAND,'=',5
	SINARIO 'CH_H.OVL'
DD_7:
SENTAKU2:
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,LL_1
	FLG_KI W,'DOWN',3
LL_1:
	FLG_IF NAN_ATTA,'=',1,LL_2
	FLG_KI W,'DOWN',4
LL_2:
	FLG_IF SIZ_ATTA,'=',1,LL_3
	FLG_KI W,'DOWN',5
LL_3:
	FLG_IF CHI_ATTA,'=',1,LL_4
	FLG_KI W,'DOWN',6
LL_4:
	MENU_S	2,W,-1
	MENU_SET	Z1,"AKEMI KONDO"
	MENU_SET	Z2,"TERUMI KINOUCHI"
	MENU_SET	Z3,"MIKA MAEDA"
	MENU_SET	Z4,"RENA WATANABE"
	MENU_SET	Z5,"NANA HIROSE"
	MENU_SET	Z6,"SHIZUKA HASEGAWA"
	MENU_SET	Z7,"CHIE UTSUMI"
	MENU_SET	Z8,"DON'T BOTHER"
	MENU_END
	DB	EXIT
Z1:
	DB	"Akemi-san would be good."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'AK_H.OVL'
Z2:
	DB	"Let's go with Terumi-senpai."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'TE_H.OVL'
Z3:
	DB	"Mm, I just love Mika..."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'MI_H.OVL'
Z4:
	DB	"Id's like to relive my memories of spring vacation..."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'RE_H.OVL'
Z5:
	DB	"I'd love to be with Nana..."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'NA_H.OVL'
Z6:
	DB	"She's got a great body."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'SI_H.OVL'
Z7:
	DB	"I just love her in that bathing suit."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'CH_H.OVL'
Z8:
	DB	"I guess I won't bother today."
	DB	NEXT
Y2:
DERU:
	DB	"I've got nothing to do here, so I guess I'll leave."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"After getting myself off, I stand in front of the mirror."
	DB	NEXT
	DB	"Mmm, that was nice."
	DB	NEXT
	DB	"I wash my hands and go back into the hall."
	DB	NEXT
	GO ROUKA
T7:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP08,'=',1
	DB	"Guess I'll go see how Shizuka-sensei is doing."
	DB	NEXT
	EVENT_CG 'th_072',B_NORM,35
	DB	"Shizuka:  Is something the matter?"
	DB	NEXT
	DB	"Kenjirou:  Oh, no."
	DB	NEXT
	DB	"Shizuka:  Then why are you here?" 
	DB	NEXT
	DB	"Kenjirou:  I just wanted to see you."
	DB	NEXT
	DB	"Shizuka:  Oh, I'm so happy."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AA_1,"LOOK AT FACE"
	MENU_SET	AA_2,"LOOK AT HANDS"
	MENU_SET	AA_3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AA_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_4
	FLG_KI SIZU_NET,'=',1
WW_4:
	DB	"She's got a great set of eyes."
	DB	NEXT
	GO BODY_SIZUKA
AA_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_5
	FLG_KI SIZU_NET,'=',1
WW_5:
	DB	"I'd love to have those red-painted nails stroking my cock."
	DB	NEXT
	GO BODY_SIZUKA
AA_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_6
	FLG_KI SIZU_NET,'=',1
WW_6:
	DB	"I can just see the lace at the top of her stockings. It's just too sexy."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Shizuka:  Just where do you think you're looking?"
	DB	NEXT
	DB	"Kenjirou:  Ah, nowhere..."
	DB	NEXT
	DB	"Shizuka:  You're young, so I guess there's nothing that can be done about it."
	DB	NEXT
	DB	"Kenjirou:  W- Well, I'll see you later..."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"There's no woman hotter than Shizuka-sensei."
	DB	NEXT
	GO ROUKA
HOKEN:
	FLG_KI HOK,'=',6
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',6
	SINARIO 'ER2.OVL'
KYOUSITU:
	FLG_KI HOK,'=',0
	BAK_INIT	'tb_034a',B_NORM
	DB	"Kenjirou:  Ah, look at the time. Guess I'll get back."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"The bell for class rings just as I get back to my room."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"More boring lessons..."
	DB	NEXT
	DB	"I guess I'll get some sleep."
	DB	NEXT
	DB	"Kenjirou: ................................."
	DB	NEXT
	B_O	B_FADE,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	SINARIO 'JUMP.OVL'
	DB	EXIT
END