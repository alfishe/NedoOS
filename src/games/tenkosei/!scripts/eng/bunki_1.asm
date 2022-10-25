        include SUPER_C.inc
M_START:
BUNKI_1
	FLG_IF HAND,'=',1,TOIRE
	FLG_IF HOK,'=',1,KYOUSITU
	FLG_IF JUMP,'=',51,FF_52
	FLG_IF JUMP,'=',50,FF_51
	FLG_IF JUMP,'=',49,FF_50
	FLG_IF JUMP,'=',48,FF_49
	FLG_IF JUMP,'=',47,FF_48
	FLG_IF JUMP,'=',46,FF_47
	FLG_IF JUMP,'=',45,FF_46
	FLG_IF JUMP,'=',44,FF_45
	FLG_IF JUMP,'=',43,FF_44
	FLG_IF JUMP,'=',42,FF_43
	FLG_IF JUMP,'=',41,FF_42
	FLG_IF JUMP,'=',40,FF_41
	FLG_IF JUMP,'=',39,FF_40
	FLG_IF JUMP,'=',38,FF_39
	FLG_IF JUMP,'=',37,FF_38
	FLG_IF JUMP,'=',36,FF_37
	FLG_IF JUMP,'=',35,FF_36
	FLG_IF JUMP,'=',34,FF_35
	FLG_IF JUMP,'=',33,FF_34
	FLG_IF JUMP,'=',32,FF_33
	FLG_IF JUMP,'=',31,FF_32
	FLG_IF JUMP,'=',30,FF_31
	FLG_IF JUMP,'=',29,FF_30
	FLG_IF JUMP,'=',28,FF_29
	FLG_IF JUMP,'=',27,FF_28
	FLG_IF JUMP,'=',26,FF_27
	FLG_IF JUMP,'=',25,FF_26
	FLG_IF JUMP,'=',24,FF_25
	FLG_IF JUMP,'=',23,FF_23
	FLG_IF JUMP,'=',22,FF_22
	FLG_IF JUMP,'=',21,FF_21
	FLG_IF JUMP,'=',20,FF_20
	FLG_IF JUMP,'=',19,FF_19
	FLG_IF JUMP,'=',18,FF_18
	FLG_IF JUMP,'=',17,FF_17
	FLG_IF JUMP,'=',16,FF_16
	FLG_IF JUMP,'=',15,FF_15
	FLG_IF JUMP,'=',14,FF_14
	FLG_IF JUMP,'=',13,FF_13
	FLG_IF JUMP,'=',12,FF_12
	FLG_IF JUMP,'=',11,FF_11
	FLG_IF JUMP,'=',10,FF_10
	FLG_IF JUMP,'=',9,FF_9
	FLG_IF JUMP,'=',8,FF_8
	FLG_IF JUMP,'=',7,FF_7
	FLG_IF JUMP,'=',6,FF_6
	FLG_IF JUMP,'=',5,FF_5
	FLG_IF JUMP,'=',4,FF_4
	FLG_IF JUMP,'=',3,FF_3
	FLG_IF JUMP,'=',2,FF_2
	FLG_IF JUMP,'=',1,FF_1
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_2:
	FLG_KI	KURI,'=',0
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,JUGO
	FLG_KI JUMP,'=',3
	SINARIO 'NITI_KIT.OVL'
FF_3:
JUGO:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',4
	SINARIO 'NITI_ASA.OVL'
FF_4:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',5
	SINARIO 'NITI_HIR.OVL'
FF_5:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',6
	SINARIO 'NITI_HOK.OVL'
FF_6:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',7
	SINARIO 'NITI_MAT.OVL'
FF_7:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_1
	FLG_KI JUMP,'=',8
	SINARIO 'NITI_KIT.OVL'
FF_8:
TUGI_1:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',3,DD_1
	GO JUGO
DD_1:
	FLG_KI KURI,'=',0
	FLG_KI JUMP,'=',9
	SINARIO 'NITI_ASA.OVL'
FF_9:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',10
	FLG_KI MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FF_10:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',11
	FLG_KI MOTDOYOU,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_11:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_2
	FLG_KI JUMP,'=',12
	GO FF_12
FF_12:
TUGI_2:
	FLG_KI HANAJI,'=',0
	FLG_KI JUMP,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  ........"
	DB	T_WAIT,	3
	DB	"I guess it's time to get up."
	DB	NEXT
	DB	"I look at the clock. It was a little past 12 noon."
	DB	NEXT
	DB	"Kenjirou:  Wow, I really slept in..."
	DB	NEXT
	DB	"Kenjirou:  But it is Sunday, so I guess I'll get a little more sleep."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	CDPLAY		12
	DB	"It's almost dinnertime."
	DB	NEXT
	DB	"I guess I'll play some video games until dinner's ready."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Tomorrow's Monday. I need to be well rested for Monday, so I guess I'll get some more sleep now."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_1
	FLG_KI	ONANI,'=',0
DEF_1:
NIJU:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',13
	SINARIO 'NITI_ASA.OVL'
FF_13:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',14
	SINARIO 'NITI_HIR.OVL'
FF_14:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',15
	SINARIO 'NITI_HOK.OVL'
FF_15:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',16
	SINARIO 'NITI_MAT.OVL'
FF_16:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_3
	FLG_KI JUMP,'=',17
	SINARIO 'NITI_KIT.OVL'
FF_17:
TUGI_3:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',5,DD_2
	GO NIJU
DD_2:
	FLG_KI	KURI,'=',0
	FLG_KI JUMP,'=',18
	SINARIO 'NITI_ASA.OVL'
FF_18:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',19
	FLG_KI MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FF_19:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',20
	FLG_KI MOTDOYOU,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_20:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,NIGO
	FLG_KI JUMP,'=',21
	GO FF_21
FF_21:
NIGO:
	FLG_KI HANAJI,'=',0
	FLG_KI JUMP,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  ........"
	DB	T_WAIT,	3
	DB	"I guess it's time to get up."
	DB	NEXT
	DB	"I look at the clock. It was a little past twelve noon."
	DB	NEXT
	DB	"I sure slept in..."
	DB	NEXT
	DB	"But it's Sunday, so I guess I'll get a little more sleep."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	DB	"It's almost dinnertime."
	DB	NEXT
	DB	"I guess I'll play some video games until dinner's ready."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Tomorrow's Monday. I'd better get lots of sleep now."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_2
	FLG_KI	ONANI,'=',0
DEF_2:
NIJU_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',22
	SINARIO 'NITI_ASA.OVL'
FF_22:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',23
	SINARIO 'NITI_HIR.OVL'
FF_23:
	FLG_KI JUMP,'=',0
	FLG_IF KURI,'=',1,ZZ_1
	F_O	B_NORM,C_KURO
	DB	"Voice:  Hey! Wake up, already!"
	DB	NEXT
	DB	"Kenjirou:  .......Mm?"
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	CDPLAY	14
	DB	"Tetsuya:  You finally woke up." 
	DB	NEXT
	DB	"I lifted my head up to see Tetsuya standing in front of me. Somehow he seemed more foolish than usual."
	DB	NEXT
	T_CG	'tt_08_11a',TET_A2,0
	DB	"Tetsuya:  Get up already. School's already over."
	DB	NEXT
	DB	"Kenjirou:  Oh, yeah."
	DB	NEXT
	DB	"Tetsuya:  Well, I'm going home."
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  Thanks."
	DB	NEXT
	DB	"Well, maybe I'll get up..."
	DB	NEXT
	DB	"I head out into the hallway."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB	"*** BOOM!! ***"
	DB	NEXT
	DB	GATA,	2
	DB	"Kenjirou: W- What was that?"
	DB	NEXT
	DB	"That came from one of the P.E. rooms."
	DB	NEXT
	FLG_KI	W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	IKU,"Let's go"
	MENU_SET	IKANAI,"Nevermind"
	MENU_END
	DB	EXIT
IKU:
	DB	"I'm in the hallway, outside where the P.E. rooms are."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"I'm sure the sound I heard came from here."
	DB	NEXT
	DB	"Voice:  W- What?!"
	DB	NEXT
	DB	"I hear a young woman's voice, and then a great crash, coming from the girls' swim team changing room."
	DB	NEXT
	DB	"Hmm... Think I'll take a look."
	DB	NEXT
	DB	"But wait? What if someone catches me? "
	DB	NEXT
	DB	"Hmm, I'll just have to make sure no one does, that's all."
	DB	NEXT
	DB	"Convinced, I slowly push the metal door ajar."
	DB	NEXT
	DB	"Kenjirou:  Wah!"
	DB	NEXT
	DB	GATA,	1
	DB	"I slip, and my forward momentum carries me through the door into the girls' swim team locker room."
	DB	NEXT
	DB	"Voice:  Kya!!"
	DB	NEXT
	BAK_INIT	'tb_014',B_NORM
	T_CG	'tt_13_14',CHI2,0
	DB	"Kenjirou:  Ah..."
	DB	NEXT
	DB	"In front of me is a young woman, clad in a bathing suit."
	DB	NEXT
	DB	"Kenjirou:  Eh, um, I..."
	DB	NEXT
	DB	"Girl:  Um, excuse me? What happened?"
	DB	NEXT
	DB	"Kenjirou:  Well, I heard a crash, and I wondered what it was. That's why I came in here. Is everything okay?"
	DB	NEXT
	DB	"Girl:  Well... "
	DB	T_WAIT,	3
	DB	" I'm sorry. I knocked over one of the locker units."
	DB	NEXT
	DB	"Kenjirou:  How did you do that?"
	DB	NEXT
	DB	"Girl:  Well... The other girls asked me to clean the room, and..."
	DB	NEXT
	DB	"Kenjirou:  They asked you to clean it all by yourself?"
	DB	NEXT
	DB	"Girl:  Yes."
	DB	NEXT
	DB	"Kenjirou:  You seem to be a first year student. Where are the other women?"
	DB	NEXT
	DB	"Girl:  ...They went home."
	DB	NEXT
	DB	"Ah, I see how it is. They asked the youngest girl on the team to do the work they didn't want to do..."
	DB	NEXT
	DB	"Kenjirou:  Um, what's your name?"
	DB	NEXT
	DB	"Girl:  Um, I'm sorry..."
	DB	T_WAIT,	3
	DB	" My name is Chie Utsumi."
	DB	NEXT
	DB	"This poor girl... I've got to help her."
	DB	NEXT
	DB	"Kenjirou:  I'll take care of it for you."
	DB	NEXT
	DB	"Chie:  W- What will you say?"
	DB	NEXT
	DB	"Kenjirou:  I'll  tell the teacher about the other girls making you do their work for them."
	DB	NEXT
	DB	"Chie:  N- No! Please don't do that!"
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Chie:  If you told the teacher, I..."
	DB	T_WAIT,	6
	DB	" I..."
	DB	NEXT
	DB	"Kenjirou:  But it's not right, them making you do their work for them."
	DB	NEXT
	DB	"Chie:  I- It's okay! I like to clean, and it's really not a problem!"
	DB	NEXT
	DB	"Kenjirou:  You're sure?"
	DB	NEXT
	DB	"Slowly, Chie nods to me."
	DB	NEXT
	DB	"Kenjirou:  Well..."
	DB	T_WAIT,	3
	DB	" I guess I'll be going then."
	DB	NEXT
	DB	"Chie:  Thank you."
	DB	NEXT
	DB	"I leave the changing room."
	DB	NEXT
;	-- Bryan commented out 4/15/02- should eliminate all Chie options
	FLG_KI	CHI_ATTA,'=',1
	GO	PPP
	DB	EXIT
IKANAI:
	DB	"Well, I guess it has nothing to do with me."
	DB	NEXT
	GO PPP
ZZ_1:
	FLG_IF CHI_ATTA,'=',0,PPP
	FLG_KI	TEMP09,'=',1
PPP:
	BAK_INIT	'tb_034a',B_NORM
	DB	"Kenjirou:  Well, guess I'll go look for some dessert..."
	DB	NEXT
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
SENTAKU1:
	BAK_INIT 'tb_034a',B_NORM
	CDPLAY	14
	DB	"Where shall I go now?"
	DB	NEXT
	FLG_KI	W,'=',-1
	FLG_IF	SIHO_PIA,'=',1,BUNKI_A
	FLG_KI	W,'DOWN',0
BUNKI_A:
	FLG_IF	SIZ_ATTA,'=',1,BUNKI_B
	FLG_KI	W,'DOWN',6
BUNKI_B:
	FLG_IF	CHI_ATTA,'=',1,BUNKI_C
	FLG_KI	W,'DOWN',7
BUNKI_C:
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
	MENU_S	2,W,-1
	MENU_SET	AB1,"MUSIC ROOM"
	MENU_SET	AB2,"CLASSROOM"
	MENU_SET	AB3,"MOTOKA'S ROOM"
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
	DB	"Maybe Shiho's practicing her piano today."
	DB	NEXT
	BAK_INIT	'tb_016',B_NORM
	CDPLAY	10
	T_CG	'tt_02_16',SIH_A3,0
	FLG_KI	SIH_KAIS,'+',1
	DB	"Shiho's here."
	DB	NEXT
	DB	"Shiho:  Ah, Kondo-kun." 
	DB	T_WAIT,	3
	DB	" You came."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AC1,"LOOK AT FACE"
	MENU_SET	AC2,"LOOK AT BREASTS"
	MENU_SET	AC3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AC1:
	FLG_KI	YOKU,'-',15
;	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Shiho's here. She really is the perfect girl."
	DB	NEXT
	GO	SIHO
AC2:
	FLG_KI	YOKU,'-',15
;	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Her school uniform keeps me from seeing what I want to see, but her breasts seem to be close to my favorite type."
	DB	NEXT
	GO	SIHO
AC3:
	FLG_KI	YOKU,'-',15
;	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Perfect thighs. White, with soft flesh that looks so inviting."
	DB	NEXT
	GO	SIHO
SIHO:
	FLG_KI	AKEM_NET,'=',0
	FLG_KI	MIKA_NET,'=',0
	FLG_KI	TER_NET,'=',0
	FLG_KI	RENA_NET,'=',0
	FLG_KI	NANA_NET,'=',0
	FLG_KI	SIZU_NET,'=',0
	DB	"Hmm, on the other hand, this isn't for me. I guess I'm the kind of guy who wants to preserve the"
    DB  " unspoiled beauty of the girl he loves."
	DB	NEXT
	DB	"Shiho:  What's wrong?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing."
	DB	NEXT
	DB	"Shiho:  Oh."
	DB	NEXT
	DB	"Kenjirou:  Aren't you going to practice?"
	DB	NEXT
	DB	"Shiho:  I'm sorry. I have to go home today..." 
	DB	NEXT
	DB	"Kenjirou:  Oh, well, I'll come back next time."
	DB	NEXT
	DB	"Shiho:  I'm sorry." 
	DB	NEXT
	DB	"Kenjirou:  It's okay."
	DB	NEXT
	DB	"Shiho:  Well, I've got to go now."
	DB	NEXT
	DB	"Kenjirou:  Okay, see you later."
	DB	NEXT
	TATI_ERS
	DB	"She leaves the music room."
	DB	NEXT
	DB	".....Guess I'll leave, too."
	DB	NEXT
	GO	BUNKI_K
AB2:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP03,'=',1
	DB	"Guess I'll go back to my own room."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB	"There's no one here."
	DB	NEXT
	DB	"Kenjirou:  I wonder where everyone is..."
	DB	NEXT
	DB	"I go back into the hall."
	DB	NEXT
	GO	SENTAKU1
AB3:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP04,'=',1
	DB	"Guess I'll look into Motoka's classroom."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB	"Kenjirou:  There's no one here. Maybe she went home."
	DB	NEXT
	GO	SENTAKU1
AB4:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP05,'=',1
	DB	"I'll take a look inside the PE storage room."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Nope, nobody."
	DB	NEXT
	DB	"Kenjirou:  Guess I'll head back."
	DB	NEXT
	GO	SENTAKU1
AB5:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP06,'=',1
	DB	"I don't really have a reason to go there, but what the hell?"
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY	18
	DB	"Mika is dusting her statues."
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
	FLG_KI YOKU,'+',4
;	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_7
	FLG_KI MIKA_NET,'=',1
WW_7:
	DB	"Her arms are akimbo over her beautiful breasts. I imagine what my cock would feel like, gliding between her twin glories."
	DB	NEXT
	GO BODY_MIKA
AD2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
;	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_8
	FLG_KI MIKA_NET,'=',1
WW_8:
	DB	"A wonderful ass, nearly perfect. I still can't forget the feel of it."
	DB	NEXT
	GO BODY_MIKA
AD3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',1
;	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_9
	FLG_KI MIKA_NET,'=',1
WW_9:
	DB	"Nice thighs, with great spring to the flesh."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Mika:  Are you looking someplace you shouldn't be?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Like where?"
	DB	NEXT
	DB	"Mika:  Oh, never mind."
	DB	NEXT
	DB	"Mika:  Anyway, I'm glad you came."
	DB	NEXT
	DB	"Kenjirou:  You are?"
	DB	NEXT
	DB	"Mika:  ...Did you forget?"
	DB	NEXT
	DB	"Oh no! I did forget!"
	DB	NEXT
	DB	"Kenjirou:  I- I'll be right back... Bye!" 
	DB	NEXT
	DB	"Mika:  Wait, Kondo-kun!" 
	DB	NEXT
	DB	"I hurriedly leave the art room."
	DB	NEXT
	GO	SENTAKU1
AB6:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP07,'=',1
	DB	"I head for the bathroom."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"Second stall from the back, my office. It's my own private place. It's unoccupied now, too."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AE1,"ENTER OFFICE"
	MENU_SET	AE2,"LEAVE"
	MENU_END
	DB	EXIT
AE1:
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'=',0,SS_1
	FLG_KI HAND,'=',1
	SINARIO 'AK_H.OVL'
SS_1:
	FLG_IF MIKA_NET,'=',0,SS_2
	FLG_KI HAND,'=',1
	SINARIO 'MI_H.OVL'
SS_2:
	FLG_IF TER_NET,'=',0,SS_3
	FLG_KI HAND,'=',1
	SINARIO 'TE_H.OVL'
SS_3:
	FLG_IF RENA_NET,'=',0,SS_4
	FLG_KI HAND,'=',1
	SINARIO 'RE_H.OVL'
SS_4:
	FLG_IF NANA_NET,'=',0,SS_5
	FLG_KI HAND,'=',1
	SINARIO 'NA_H.OVL'
SS_5:
	FLG_IF SIZU_NET,'=',0,SS_6
	FLG_KI HAND,'=',1
	SINARIO 'SI_H.OVL'
SS_6:
;	-- Bryan commented out 12/26/01
        FLG_IF CHIE_NET,'=',0,SS_7
        FLG_KI HAND,'=',1
        SINARIO 'CH_H.OVL'
SS_7:
SENTAKU2:
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,GG_1
	FLG_KI W,'DOWN',3
GG_1:
	FLG_IF NAN_ATTA,'=',1,GG_2
	FLG_KI W,'DOWN',4
GG_2:
	FLG_IF SIZ_ATTA,'=',1,GG_3
	FLG_KI W,'DOWN',5
GG_3:
	FLG_IF CHI_ATTA,'=',1,GG_4
	FLG_KI W,'DOWN',6
GG_4:
	MENU_S	2,W,-1
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
	DB	"Hmm, let's do it with Akemi-san."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'AK_H.OVL'
AF2:
	DB	"Mmm, Terumi-senpai would be nice."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'TE_H.OVL'
AF3:
	DB	"I'd love to do it with Mika-sensei..."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'MI_H.OVL'
AF4:
	DB	"Mmm, the memory of spring vacation..."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'RE_H.OVL'
AF5:
	DB	"Her giant breasts, bursting through her uniform... Mmmm..."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'NA_H.OVL'
AF6:
	DB	"Shizuka would be great..."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'SI_H.OVL'
AF7:
;	-- Bryan commented out 12/26/01
;	-- DB	"I'd love to have my way with Chie..."
;	-- DB	NEXT
;	-- FLG_KI HAND,'=',1
;	-- SINARIO 'CH_H.OVL'
AF8:
	DB	"Hmm, never mind. I wouldn't want to go blind."
	DB	NEXT
AE2:
DERU:
	DB	"I've got no reason to be in here. Guess I'll go outside."
	DB	NEXT
	GO SENTAKU1
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Feeling much better, I stand in front of the bathroom mirror."
	DB	NEXT
	DB	"Kenjirou:  Hmm, that's great."
	DB	NEXT
	DB	"Guess I'll wash my hands."
	DB	NEXT
	DB	"Hands clean, I head out into the hall."
	DB	NEXT
	GO	SENTAKU1
AB7:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"The nurse's office... I wonder if Shizuka-sensei is in?"
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB	"Shizuka:  What's wrong today?"
	DB	NEXT
	DB	"Kenjirou:  Nothing."
	DB	NEXT
	DB	"Shizuka:  Then why are you here?"
	DB	NEXT
	DB	"Kenjirou:  I wanted to see you." 
	DB	NEXT
	DB	"Shizuka:  Ah, I'm so happy."
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
	FLG_KI YOKU,'+',4
;	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_10
	FLG_KI SIZU_NET,'=',1
WW_10:
	DB	"She's beautiful..."
	DB	NEXT
	GO BODY_SIZUKA
AG_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',5
;	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_11
	FLG_KI SIZU_NET,'=',1
WW_11:
	DB	"She's got bright red fingernail polish on. I'd love to have those hands on my cock."
	DB	NEXT
	GO BODY_SIZUKA
AG_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',9
;	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_12
	FLG_KI SIZU_NET,'=',1
WW_12:
	DB	"I can just see the lace at the top of her stockings. It's just too sexy."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Shizuka:  So, are you sick?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, no, nothing like that..."
	DB	NEXT
	DB	"Shizuka:  Well, you're young. I guess there's nothing I can do about that sex drive of yours."
	DB	NEXT
	DB	"Kenjirou:  S- sorry!"
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Hmm... She can see right through me, can't she?"
	DB	NEXT
	GO	SENTAKU1
HOKEN:
	FLG_KI HOK,'=',1
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',1
	SINARIO 'ER2.OVL'
AB8:
	DB	"I just did that. I'm through for the day."
	DB	NEXT
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP09,'=',1
	GO	SENTAKU1
KYOUSITU:
	FLG_KI HOK,'=',0
	FLG_IF	MOTDOYOU,'=',1,DOYOUBI
	BAK_INIT 'tb_034b',B_NORM
	DB	"I guess I'll head back to my own classroom."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB	"I guess I'll get ready to go home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO FF_24
	DB	EXIT
DOYOUBI:
	BAK_INIT	'tb_034a',B_NORM
	DB	"I guess I'll head back to class."
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	DB	"It's still light outside, but I guess I'll go home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO FF_24
	DB	EXIT
FF_24:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',24
	SINARIO 'NITI_MAT.OVL'
FF_25:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_4
	FLG_KI JUMP,'=',25
	SINARIO 'NITI_KIT.OVL'
FF_26:
TUGI_4:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',2,GG_10
	GO NIJU_1
GG_10:
	FLG_KI KURI,'=',0
	FLG_KI JUMP,'=',26
	SINARIO 'MON_38.OVL'
FF_27:
NIJU_2:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',27
	SINARIO 'NITI_ASA.OVL'
FF_28:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',28
	SINARIO 'NITI_HIR.OVL'
FF_29:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',29
	SINARIO 'NITI_HOK.OVL'
FF_30:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',30
	SINARIO 'NITI_MAT.OVL'
FF_31:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_5
	FLG_KI JUMP,'=',31
	SINARIO 'NITI_KIT.OVL'
FF_32:
TUGI_5:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',2,TT_1
	GO NIJU_2
TT_1:
	FLG_KI KURI,'=',0
	FLG_KI JUMP,'=',32
	SINARIO 'NITI_ASA.OVL'
FF_33:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',33
	FLG_KI MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FF_34:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',34
	FLG_KI MOTDOYOU,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_35:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,GONI
	FLG_KI JUMP,'=',35
	GO FF_36
FF_36:
GONI:
	FLG_KI HANAJI,'=',0
	FLG_KI JUMP,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  ............"
	DB	T_WAIT,	3
	DB	"Time to wake up."
	DB	NEXT
	DB	"I look at the clock. Just past noon."
	DB	NEXT
	DB	"Kenjirou:  Wow, I sure slept a lot..."
	DB	NEXT
	DB	"Well, it is Sunday, and that's the day to sleep in."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	DB	"Wow, it's almost time for dinner..."
	DB	NEXT
	DB	"Guess I'll play a game."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Kenjirou:  Tomorrow's Monday. I'd better get some more sleep now, while I can."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_3
	FLG_KI	ONANI,'=',0
DEF_3:
	F_O	B_NORM,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_4
	FLG_KI	ONANI,'=',0
DEF_4:
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"I've got to go to school tomorrow. What a pain."
	DB	NEXT
	DB	"Oh well. At least I can meet all my girlfriends."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
GORO:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',36
	SINARIO 'NITI_ASA.OVL'
FF_37:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',37
	SINARIO 'NITI_HIR.OVL'
FF_38:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',38
	SINARIO 'NITI_HOK.OVL'
FF_39:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',39
	SINARIO 'NITI_MAT.OVL'
FF_40:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_6
	FLG_KI JUMP,'=',40
	SINARIO 'NITI_KIT.OVL'
FF_41:
TUGI_6:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',3,NN_1
	GO GORO
NN_1:
	FLG_KI KURI,'=',0
	FLG_KI JUMP,'=',41
	SINARIO 'NITI_ASA.OVL'
FF_42:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',42
	FLG_KI MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FF_43:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',43
	FLG_KI MOTDOYOU,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_44:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,GOKU
	FLG_KI JUMP,'=',44
	GO FF_45
FF_45:
GOKU:
	FLG_KI HANAJI,'=',0
	FLG_KI JUMP,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Kenjirou:  ............"
	DB	T_WAIT,	3
	DB	"Guess I'll wake up now."
	DB	NEXT
	DB	"The clock reads a few minutes past noon."
	DB	NEXT
	DB	"Kenjirou:  Wow, I overslept..."
	DB	NEXT
	DB	"Well, it is Sunday, and that's the day for sleeping in..."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	DB	"Wow, it's almost dinnertime..."
	DB	NEXT
	DB	"Guess I'll play a game or something."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Tomorrow's Monday, so I'd better get a lot of sleep now, while I can."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_6
	FLG_KI	ONANI,'=',0
DEF_6:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',45
	SINARIO 'NITI_ASA.OVL'
FF_46:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',46
	SINARIO 'NITI_HIR.OVL'
FF_47:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',47
	SINARIO 'NITI_HOK.OVL'
FF_48:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',48
	SINARIO 'NITI_MAT.OVL'
FF_49:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_7
	FLG_KI JUMP,'=',49
	SINARIO 'NITI_KIT.OVL'
FF_50:
TUGI_7:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',50
	SINARIO 'NITI_ASA.OVL'
FF_51:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',51
	SINARIO 'NITI_HIR.OVL'
FF_52:
	FLG_KI JUMP,'=',0
	F_O	B_NORM,C_KURO
	DB	"Guess I'll wake up now."
	DB	NEXT
	DB	"I slowly open my eyes, only to see the face of Shiho, staring back at me."
	DB	NEXT
	BAK_INIT	'tb_010',B_FADE
	CDPLAY		14
	T_CG	'tt_02_10',SIH_A2,0
	DB	"Shiho:  Kenjirou-kun, can I have a word with you?"
	DB	NEXT
	DB	"Kenjirou:  Uh, sure. What's wrong?"
	DB	NEXT
	DB	"Ready to listen to whatever it is Shiho wants to tell me, I take a seat."
	DB	NEXT
	DB	"Kenjirou:  What is it?"
	DB	NEXT
	DB	"Shiho:  ..............."
	DB	NEXT
	EVENT_CG	'ti_121',B_NORM,75
	DB	"Kenjirou:  !!"
	DB	NEXT
	DB	"Without warning, Shiho kisses me softly. Unable to react in the slightest, I stare back at her."
	DB	NEXT
	BAK_INIT	'tb_010',B_FADE
	T_CG	'tt_02_10',SIH_A2,0
	DB	"Shiho:  Sayonara..."
	DB	NEXT
	DB	"The word hangs in the air, as Shiho hurriedly leaves the room."
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  .....Shiho?"
	DB	NEXT
	DB	"Feeling warm and at peace, I head for home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Unable to comprehend the meaning of Shiho's words, I go to my room, and allow myself to drift off into an uneasy sleep."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"The next morning, I head for school, my body creaking with exhaustion and lack of sleep."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		14
	DB	"In the classroom, I look for Shiho. But she's nowhere to be found. Even the desk she was sitting at has vanished."
	DB	NEXT
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Good morning, Kenjirou."
	DB	NEXT
	DB	"Tetsuya nods a greeting to me."
	DB	NEXT
	DB	"Kenjirou:  Morning..."
	DB	NEXT
	DB	"Tetsuya:  What's the matter?"
	DB	NEXT
	DB	"Kenjirou:  Hmm, nothing."
	DB	NEXT
	DB	"Tetsuya:  Is anything wrong?" 
	DB	NEXT
	DB	"Kenjirou:  No, I'm fine. By the way, did you see Shiho this morning?"
	DB	NEXT
	DB	"Tetsuya:  Who?"
	DB	NEXT
	DB	"Kenjirou:  You know, our classmate, Shiho Kashima."
	DB	NEXT
	DB	"Tetsuya:  Shiho? There's no one by that name in our class, Kenjirou."
	DB	NEXT
	DB	"Kenjirou:  What? But that can't..."
	DB	NEXT
	DB	"Tetsuya:  Are you sure you didn't sleep too much last night? You're acting kind of funny." 
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Just then, the bell rang, and I had to sit down."
	DB	NEXT
	TATI_ERS
	;WAV  'STOP'
	F_O	B_NORM,C_KURO
	DB	"The door opens, and the room grows quiet. It's time for the instructor to come into the room."
	DB	NEXT
	DB	"During the class, though, all I can think about is how Shiho disappeared entirely from our lives."
	DB	NEXT
	DB	"Later, Tetsuya came over to wake me up."
	DB	NEXT
	DB	"Tetsuya:  Wake up, man. It's lunch time."
	DB	NEXT
	DB	"Not sure that I had really been asleep, I nodded."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Oh, you're awake. I'm shocked."
	DB	NEXT
	DB	"Kenjirou:  Really?"
	DB	NEXT
	DB	"Tetsuya:  ...What happened this morning, anyway? There's something you're hiding from me. You're acting odd." 
	DB	NEXT
	DB	"Kenjirou:  I know..."
	DB	NEXT
	DB	"Tetsuya:  I think you slept way too much last night." 
	DB	NEXT
	DB	"Kenjirou:  I'll try to watch that in the future."
	DB	NEXT
	DB	"Slowly, I got to my feet."
	DB	NEXT
	DB	"Tetsuya:  Where are you going?"
	DB	NEXT
	DB	"Kenjirou:  I'm sorry... I kind of need to be alone right now."
	DB	NEXT
	DB	"Tetsuya:  ...Are you okay, man? What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  I'm alright. I just have to get the cotton out of my head." 
	DB	NEXT
	DB	"I leave Tetsuya, and go to the roof."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	DB	"There are always quite a few people on the roof at lunchtime."
	DB	NEXT
	DB	"Looking up at the sky, I remember Shiho, who had disappeared so mysteriously."
	DB	NEXT
	EVENT_CG	'ti_135',B_NORM,77
	CDPLAY		21
	DB	"Kenjirou:  Shiho, you were here, I know it. You weren't a daydream of mine, I'm sure of it!"
	DB	NEXT
	DB	"Shiho:  It's true, I wasn't a fantasy of yours..." 
	DB	NEXT
	DB	"Kenjirou:  Shiho..."
	DB	NEXT
	DB	"Shiho:  Kenjirou-kun, I want to see you again, in your dreams." 
	DB	NEXT
	DB	"Shiho, floating in the sky above me, smiled."
	DB	NEXT
	GAME_END
	DB	EXIT
END