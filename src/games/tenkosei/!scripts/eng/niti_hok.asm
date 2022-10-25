        include SUPER_C.inc
M_START:
NITI_HOK
	FLG_IF HOK,'=',7,KYOUSITU
	FLG_IF HAND,'=',6,TOIRE
	F_O	B_NORM,C_KURO
	DB	"Voice:  Hey! Wake up!"
	DB	NEXT
	DB	"Kenjirou:  .....Mm?"
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	CDPLAY	14
	DB	"Tetsuya:  You finally woke up." 
	DB	NEXT
	DB	"I lifted my heavy head up, and looked at my friend."
	DB	NEXT
	T_CG	'tt_08_11a',TET_A2,0
	DB	"Tetsuya:  Time to wake up, already!" 
	DB	NEXT
	DB	"Kenjirou:  Ah, sorry."
	DB	NEXT
	DB	"Tetsuya:  Well, I'm going home now."
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  Thanks."
	DB	NEXT
	DB	"Kenjirou:  I guess I'll wander around a bit."
	DB	NEXT
	DB	"I head out into the hallway."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB	"I guess I'll look for some pretty girls."
	DB	NEXT
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
	FLG_KI TEMP09,'=',0
	GO VV_1
SENTAKU1:
	CDPLAY	14
	BAK_INIT	'tb_034a',B_NORM
	DB	"So, where should I go?"
	DB	NEXT
VV_1:
	FLG_KI	W,'=',-1
	FLG_IF	TEMP02,'=',0,BUNKI_D
	FLG_KI	W,'DOWN',0
BUNKI_D:
	FLG_IF	TEMP03,'=',0,BUNKI_E
	FLG_KI	W,'DOWN',1
BUNKI_E:
	FLG_IF	TEMP04,'=',0,BUNKI_F
	FLG_KI	W,'DOWN',2
BUNKI_F:
	FLG_IF	TEMP05,'=',0,BUNKI_G
	FLG_KI	W,'DOWN',3
BUNKI_G:
	FLG_IF	TEMP06,'=',0,BUNKI_H
	FLG_KI	W,'DOWN',4
BUNKI_H:
	FLG_IF	TEMP07,'=',0,BUNKI_I
	FLG_KI	W,'DOWN',5
BUNKI_I:
	FLG_IF	TEMP08,'=',0,BUNKI_J
	FLG_KI	W,'DOWN',6
BUNKI_J:
	FLG_IF	TEMP09,'=',0,BUNKI_K
	FLG_KI	W,'DOWN',7
BUNKI_K:
	FLG_IF	SIHO_PIA,'=',1,BUNKI_A
	FLG_KI	W,'DOWN',0
BUNKI_A:
	FLG_IF	SIZ_ATTA,'=',1,BUNKI_B
	FLG_KI	W,'DOWN',6
BUNKI_B:
	FLG_IF	CHI_ATTA,'=',1,BUNKI_C
	FLG_KI	W,'DOWN',7
BUNKI_C:
	BAK_INIT	'tb_034a',B_NORM
	MENU_S	2,W,-1
	MENU_SET	AB1,"MUSIC ROOM"
	MENU_SET	AB2,"RETURN TO CLASSROOM"
	MENU_SET	AB3,"MOTOKA'S CLASSROOM"
	MENU_SET	AB4,"PE STORAGE ROOM"
	MENU_SET	AB5,"ART ROOM"
	MENU_SET	AB6,"MEN'S ROOM"
	MENU_SET	AB7,"NURSE'S OFFICE"
	MENU_SET	AB8,"CHANGING ROOM"
	MENU_END
	DB	EXIT
AB1:
	FLG_IF	TEMP01,'>=',3,KYOUSITU
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB	"Guess I'll go to the music room. I wonder if Shiho is there?"
	DB	NEXT
	BAK_INIT	'tb_016',B_NORM
	CDPLAY	10
	T_CG	'tt_02_16',SIH_A3,0
	FLG_KI	SIH_KAIS,'+',1
	DB	"Shiho is here."
	DB	NEXT
	DB	"Shiho:  Ah, Kenjirou-kun."
	DB	T_WAIT,	3
	DB	" Did you come to hear me play?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AC1,"LOOK AT FACE"
	MENU_SET	AC2,"LOOK AT TITS"
	MENU_SET	AC3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AC1:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Shiho's got such a cute face. Almost perfect."
	DB	NEXT
	GO	SIHO
AC2:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Her uniform keeps me from seeing her breast perfectly, but they look great."
	DB	NEXT
	GO	SIHO
AC3:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Excellent thighs. White, with not too much meat on them."
	DB	NEXT
	GO	SIHO
SIHO:
	FLG_KI	AKEM_NET,'=',0
	FLG_KI	MIKA_NET,'=',0
	FLG_KI	TER_NET,'=',0
	FLG_KI	RENA_NET,'=',0
	FLG_KI	NANA_NET,'=',0
	FLG_KI	SIZU_NET,'=',0
	FLG_KI	CHIE_NET,'=',0
	DB	"I should stop. I don't want to dirty this perfect flower."
	DB	NEXT
	DB	"Shiho:  What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing."
	DB	NEXT
	DB	"Shiho:  I see..."
	DB	NEXT
	DB	"Kenjirou:  Are you going to play today?"
	DB	NEXT
	DB	"Shiho:  I'm sorry... I have to go home early today." 
	DB	NEXT
	DB	"Kenjirou:  Oh, oh well."
	DB	NEXT
	DB	"Shiho:  Sorry." 
	DB	NEXT
	DB	"Kenjirou:  It's okay."
	DB	NEXT
	DB	"Shiho:  Well, I'll see you later."
	DB	NEXT
	DB	"Kenjirou:  Okay, take care."
	DB	NEXT
	TATI_ERS
	DB	"Shiho leaves the music room."
	DB	NEXT
	DB	"Guess I'll leave too."
	DB	NEXT
	GO	SENTAKU1
AB2:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP03,'=',1
	DB	"I guess I'll go back to my own room."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB	"There's no one here."
	DB	NEXT
	DB	"Kenjirou:  I wonder where everyone is."
	DB	NEXT
	DB	"I go back into the hallway."
	DB	NEXT
	GO	SENTAKU1
AB3:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP04,'=',1
	DB	"I guess I'll go see Motoka."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB	"There's no one here. She must have gone home early."
	DB	NEXT
	GO	SENTAKU1
AB4:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP05,'=',1
	DB	"I guess I'll go to the PE storage room."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Nope, no one here."
	DB	NEXT
	DB	"Guess I'll go back."
	DB	NEXT
	GO	SENTAKU1
AB5:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP06,'=',1
	DB	"Maybe I'll go see my sweet peach in the art room."
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
	MENU_SET	AD1,"LOOK AT TITS"
	MENU_SET	AD2,"LOOK AT ASS"
	MENU_SET	AD3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AD1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_7
	FLG_KI MIKA_NET,'=',1
WW_7:
	DB	"Her arms are keeping me from seeing her breasts, but they look good."
	DB	NEXT
	GO BODY_MIKA
AD2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_8
	FLG_KI MIKA_NET,'=',1
WW_8:
	DB	"An excellent ass. I still can't forget the last time I touched it."
	DB	NEXT
	GO BODY_MIKA
AD3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_9
	FLG_KI MIKA_NET,'=',1
WW_9:
	DB	"Really nice thighs. Very soft and silky."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Mika:  Hey, watch where you look." 
	DB	NEXT
	DB	"Kenjirou:  Eh? I wasn't looking at anything..."
	DB	NEXT
	DB	"Mika:  Oh well, never mind."
	DB	NEXT
	DB	"Mika:  Anyway, I'm glad you came on time."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Mika:  Don't tell me you forgot!" 
	DB	NEXT
	DB	"Yikes! I did forget!"
	DB	NEXT
	DB	"Kenjirou:  I- I'll see you tomorrow, sensei..."
	DB	NEXT
	DB	"Mika:  Come back here, Kondo-kun!" 
	DB	NEXT
	DB	"I leave the art room in a hurry."
	DB	NEXT
	GO	SENTAKU1
AB6:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP07,'=',1
	DB	"I head for the men's room."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"The second stall from the back, my office. It's empty as usual."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AE1,"ENTER OFFICE"
	MENU_SET	AE2,"DON'T BOTHER"
	MENU_END
	DB	EXIT
AE1:
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'=',0,SS_1
	FLG_KI HAND,'=',6
	SINARIO 'AK_H.OVL'
SS_1:
	FLG_IF MIKA_NET,'=',0,SS_2
	FLG_KI HAND,'=',6
	SINARIO 'MI_H.OVL'
SS_2:
	FLG_IF TER_NET,'=',0,SS_3
	FLG_KI HAND,'=',6
	SINARIO 'TE_H.OVL'
SS_3:
	FLG_IF RENA_NET,'=',0,SS_4
	FLG_KI HAND,'=',6
	SINARIO 'RE_H.OVL'
SS_4:
	FLG_IF NANA_NET,'=',0,SS_5
	FLG_KI HAND,'=',6
	SINARIO 'NA_H.OVL'
SS_5:
	FLG_IF SIZU_NET,'=',0,SS_6
	FLG_KI HAND,'=',6
	SINARIO 'SI_H.OVL'
SS_6:
	FLG_IF CHIE_NET,'=',0,SS_7
	FLG_KI HAND,'=',6
	SINARIO 'CH_H.OVL'
SS_7:
SENTAKU2:
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,JJ_1
	FLG_KI W,'DOWN',3
JJ_1:
	FLG_IF NAN_ATTA,'=',1,JJ_2
	FLG_KI W,'DOWN',4
JJ_2:
	FLG_IF SIZ_ATTA,'=',1,JJ_3
	FLG_KI W,'DOWN',5
JJ_3:
	FLG_IF CHI_ATTA,'=',1,JJ_4
	FLG_KI W,'DOWN',6
JJ_4:
	MENU_S	 2,W,-1
	MENU_SET	AF1,"AKEMI KONDO"
	MENU_SET	AF2,"TERUMI KINOUCHI"
	MENU_SET	AF3,"MIKA MAEDA"
	MENU_SET	AF4,"RENA WATANABE"
	MENU_SET	AF5,"NANA HIROSE"
	MENU_SET	AF6,"SHIZUKA HASEGAWA"
	MENU_SET	AF7,"CHIE UTSUMI"
	MENU_SET	AF8,"DON'T DO IT"
	MENU_END
	DB	EXIT
AF1:
	DB	"Let's do it with Akemi-san."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'AK_H.OVL'
AF2:
	DB	"Mmm, Terumi-senpai would be nice."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'TE_H.OVL'
AF3:
	DB	"I'd love to have my way with Mika."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'MI_H.OVL'
AF4:
	DB	"I'd love to relive my memories of spring vacation..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'RE_H.OVL'
AF5:
	DB	"Mmm, it'd be nice to tear that uniform off of her..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'NA_H.OVL'
AF6:
	DB	"Shizuka-sensei'd be a great lay..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'SI_H.OVL'
AF7:
	DB	"I love seeing Chie in her bathing suit."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'CH_H.OVL'
AF8:
AE2:
DERU:
	DB	"Guess I'll go back outside."
	DB	NEXT
	GO SENTAKU1
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Feeling rejuvenated after getting my rocks off, I stand in front of the bathroom mirror."
	DB	NEXT
	DB	"Kenjirou:  Mmm, that was good."
	DB	NEXT
	DB	"I wash my hands, and leave."
	DB	NEXT
	GO	SENTAKU1
AB7:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"Guess I'll go see Shizuka-sensei."
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB	"Shizuka:  Is something the matter?"
	DB	NEXT
	DB	"Kenjirou:  Nope."
	DB	NEXT
	DB	"Shizuka:  Then why are you here?"
	DB	NEXT
	DB	"Kenjirou:  I wanted to see you."
	DB	NEXT
	DB	"Shizuka:  Oh, I'm so happy."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AG_1,"LOOK AT FACE"
	MENU_SET	AG_2,"LOOK AT HANDS"
	MENU_SET	AG_3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AG_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_10
	FLG_KI SIZU_NET,'=',1
WW_10:
	DB	"She's got a cute face."
	DB	NEXT
	GO BODY_SIZUKA
AG_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_11
	FLG_KI SIZU_NET,'=',1
WW_11:
	DB	"I'd love to have her red-painted fingernails moving up and down my shaft."
	DB	NEXT
	GO BODY_SIZUKA
AG_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_12
	FLG_KI SIZU_NET,'=',1
WW_12:
	DB	"You can see the top of her stocking. It's so sexy."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Shizuka:  Just where do you think you're looking?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nowhere..."
	DB	NEXT
	DB	"Shizuka:  You're young, so there's nothing that can be done about it, I suppose."
	DB	NEXT
	DB	"Kenjirou:  E- Excuse me!"
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"There's no woman hotter than Shizuka-sensei."
	DB	NEXT
	GO	SENTAKU1
HOKEN:
	FLG_KI HOK,'=',7
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',7
	SINARIO 'ER2.OVL'
AB8:
	FLG_IF	TEMP01,'>=',3,KYOUSITU
	FLG_KI	TEMP01,'+',1
	FLG_KI TEMP09,'=',1
	DB	"I wonder if Chie's cleaning up today?"
	DB	NEXT
	DB	"Guess I'll go see."
	DB	NEXT
	BAK_INIT	'tb_014',B_NORM
	T_CG	'tt_13_14',CHI2,0
	DB	"Chie:  Ah, Kenjirou-senpai..."
	DB	NEXT
	DB	"Kenjirou:  Are you cleaning up today, too?"
	DB	NEXT
	DB	"Chie:  Ah, um, well... Yes."
	DB	NEXT
	DB	"She's wearing her bathing suit again. I'm so happy!"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AG_4,"LOOK AT FACE"
	MENU_SET	AG_5,"LOOK AT HANDS"
	MENU_SET	AG_6,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AG_4:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_1
	FLG_KI CHIE_NET,'=',1
KK_1:
	DB	"She's got a cute, innocent face, that somehow makes me want to tease her..."
	DB	NEXT
	DB	"Chie:  Um, is there something on my face?"
	DB	NEXT
	DB	"Kenjirou:  Eh? No, nothing. Is something wrong?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, um, nothing. It's nothing."
	DB	NEXT
	GO	HHH
AG_5:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_2
	FLG_KI CHIE_NET,'=',1
KK_2:
	DB	"It's odd to see such beautiful, luxurious fingernails on a plain girl like this."
	DB	NEXT
	DB	"Chie:  Is there something wrong?"
	DB	NEXT
	DB	"Kenjirou:  Like what?"
	DB	NEXT
	DB	"Chie:  ...Oh, nothing..."
	DB	NEXT
	GO	HHH
AG_6:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_3
	FLG_KI CHIE_NET,'=',1
KK_3:
	DB	"Looking at her white, fleshy thighs poking out under her bathing suit makes me hot."
	DB	NEXT
	DB	"Chie:  Um, I..."
	DB	NEXT
	DB	"She seems to have noticed my stare."
	DB	NEXT
	DB	"Kenjirou:  Aren't you cold?"
	DB	NEXT
	DB	"Chie:  What?"
	DB	NEXT
	DB	"Kenjirou:  I mean, you're not wearing much..."
	DB	NEXT
	DB	"Chie:  Oh... I'm, um, used to it."
	DB	NEXT
	DB	"Kenjirou:  Really? Careful not to catch a cold, though."
	DB	NEXT
	DB	"At that, Chie seemed to relax a little, and stopped moving away from me."
	DB	NEXT
	DB	"Chie:  Um..."
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Chie:  I- It's nothing."
	DB	NEXT
HHH:
	DB	"Kenjirou:  Well, I'll be going now."
	DB	NEXT
	DB	"Chie:  Okay."
	DB	NEXT
	DB	"Kenjirou:  You know, if you don't tell people your opinion, you'll always be doing the worst jobs, "
        DB      "like cleaning up after the other girls."
	DB	NEXT
	DB	"Chie:  ................"
	DB	NEXT
	DB	"Chie doesn't say anything."
	DB	NEXT
	DB	"Kenjirou:  Well, bye."
	DB	NEXT
	DB	"I leave the changing room."
	DB	NEXT
	GO	SENTAKU1
KYOUSITU:
	FLG_KI HOK,'=',0
	FLG_IF	MOTDOYOU,'=',1,DOYOUBI
	BAK_INIT	'tb_034b',B_NORM
	DB	"Oh, look how late it is."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB	"Guess I'll get ready to go home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO 'JUMP.OVL'
	DB	EXIT
DOYOUBI:
	FLG_KI MOTDOYOU,'=',0
	BAK_INIT	'tb_034a',B_NORM
	DB	"Guess I'll go back to my classroom."
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	DB	"It's still light outside, but I' guess I'll head home now."
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO 'JUMP.OVL'
	DB	EXIT
END