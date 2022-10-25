        include SUPER_C.inc
M_START:
MON_18
	FLG_IF HOK,'=',4,KYOUSITU
	FLG_IF HAND,'=',3,TOIRE
	FLG_IF JUMP,'=',60,FUFUFU_7
	FLG_IF JUMP,'=',59,FUFUFU_6
	FLG_IF JUMP,'=',58,FUFUFU_5
	FLG_IF JUMP,'=',57,FUFUFU_4
	FLG_IF JUMP,'=',56,FUFUFU_3
	FLG_IF JUMP,'=',55,FUFUFU_2
	FLG_IF JUMP,'=',54,FUFUFU_1
	FLG_IF JUMP,'=',53,JITAKU
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	DB	"Well, time to look for dessert."
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Kenjirou."
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Tetsuya:  I just heard some interesting gossip..." 
	DB	NEXT
	DB	"Kenjirou:  Oh, great. More gossip."
	DB	NEXT
	DB	"Tetsuya:  This is different. If it's true, it has a lot to do with you."
	DB	NEXT
	DB	"Kenjirou:  With me?"
	DB	NEXT
	DB	"Tetsuya:  Yes. It's about your kid sister, Motoka."
	DB	NEXT
	DB	"Kenjirou:  Motoka?"
	DB	NEXT
	DB	"Tetsuya:  Yes."
	DB	NEXT
	DB	"Kenjirou:  I'm sure you're going to tell me Motoka was in an AV video or something, right?"
	DB	NEXT
	DB	"Tetsuya:  No, nothing like that. ...You know, she's been hanging around some pretty lame people lately." 
	DB	NEXT
	DB	"Kenjirou:  I want you to stop this joke, right now."
	DB	NEXT
	DB	"Tetsuya:  It's not a joke, but it is a rumor. I don't have any evidence, so I guess you don't have to worry after all."
	DB	NEXT
	DB	"Tetsuya:  Well, I'll be going."
	DB	NEXT
	DB	"Kenjirou:  Hold it."
	DB	NEXT
	TATI_ERS		;TT_08
	DB	"Ignoring me, Tetsuya leaves the classroom."
	DB	NEXT
	DB	"...I'm sure Motoka would never do anything stupid."
	DB	NEXT
	DB	"I head out into the hallway."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB	"Well, let's look for some dessert now."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	FLG_KI TEMP09,'=',0
	GO SENTAKU1
ROUKA:
	BAK_INIT	'tb_034a',B_NORM
	CDPLAY		14
	DB	"Where should I go?"
	DB	NEXT
SENTAKU1:
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
	FLG_IF SIZ_ATTA,'=',1,SA_8
	FLG_KI W,'DOWN',6
SA_8:
	MENU_S 2,W,-1
	MENU_SET	AB1,"MUSIC ROOM"
	MENU_SET	AB2,"CLASSROOM"
	MENU_SET	AB3,"MOTOKA'S ROOM"
	MENU_SET	AB4,"P.E. STORAGE ROOM"
	MENU_SET	AB5,"ART ROOM"
	MENU_SET	AB6,"MEN'S ROOM"
	MENU_SET	AB7,"NURSE'S OFFICE"
	MENU_END
	DB	EXIT
AB1:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"I wonder if Shiho's playing today?"
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	T_CG 'tt_02_16',SIH_A2,0
	FLG_KI	SIH_KAIS,'+',1
	CDPLAY		10
	DB	"Shiho's here."
	DB	NEXT
	DB	"Shiho:  Ah, Kenjirou-kun." 
	DB	T_WAIT,	5
	DB	" You came to listen to my piano playing."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AC1,"LOOK AT FACE"
	MENU_SET	AC2,"LOOK AT TITS"
	MENU_SET	AC3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AC1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Shiho is the perfect girl for me. Such a pretty face."
	DB	NEXT
	GO SHIHO_BODY
AC2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Her uniform is blocking me pretty well, but I'm sure her tits are the perfect size."
	DB	NEXT
	GO SHIHO_BODY
AC3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"The perfect thighs. White, with just the right amount of meat on them."
	DB	NEXT
	GO SHIHO_BODY
SHIHO_BODY:
	FLG_KI AKEM_NET,'=',0
	FLG_KI MIKA_NET,'=',0
	FLG_KI TER_NET,'=',0
	FLG_KI RENA_NET,'=',0
	FLG_KI NANA_NET,'=',0
	FLG_KI SIZU_NET,'=',0
	FLG_KI CHIE_NET,'=',0
	DB	"This isn't right. I don't want to pollute the perfect girl for me. "
	DB	NEXT
	DB	"Shiho:  What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  What? Oh, nothing..."
	DB	NEXT
	DB	"Shiho:  I see..."
	DB	NEXT
	DB	"Kenjirou:  Aren't you going to play today?"
	DB	NEXT
	DB	"Shiho:  I'm sorry. I have to go home early today..." 
	DB	NEXT
	DB	"Kenjirou:  Oh, I see. That's too bad."
	DB	NEXT
	DB	"Shiho:  I'm sorry."
	DB	NEXT
	DB	"Kenjirou:  It's okay. "
	DB	NEXT
	DB	"Shiho:  Well, I'll see you tomorrow." 
	DB	NEXT
	DB	"Kenjirou:  Okay..."
	DB	NEXT
	TATI_ERS		;Tt_02
	DB	"Shiho leaves the music room."
	DB	NEXT
	DB	"Guess I'll leave, too."
	DB	NEXT
	GO ROUKA
AB2:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Guess I'll head back to class."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	CDPLAY		14
	DB	"There's no one in the classroom."
	DB	NEXT
	DB	"Kenjirou:  I'm the only one here."
	DB	NEXT
	DB	"I head back out into the hallway."
	DB	NEXT
	GO ROUKA
AB3:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"Guess I'll check out Motoka's classroom."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	T_CG 'tt_10_11a',MOT_A2,0
	DB	"Seeing me, Motoka runs over."
	DB	NEXT
	DB	"Motoka:  Ah, Oniichan." 
	DB	NEXT
	DB	"Kenjirou:  Ah, you're still here."
	DB	NEXT
	DB	"Motoka:  Yes. But I was about to go home now. What about you?"
	DB	NEXT
	DB	"Kenjirou:  I'm going to hang around a while longer."
	DB	NEXT
	DB	"Motoka:  Really? Why don't we go home together?"
	DB	NEXT
	DB	"Kenjirou:  I'm sorry, but I've still got things to do."
	DB	NEXT
	TATI_ERS
	T_CG 'tt_21_11a',MOT_A2,0
	DB	"Motoka:  ...Okay. I'll go on ahead, then." 
	DB	NEXT
	TATI_ERS		;Tt_10
	DB	"Kenjirou:  Ah, Motoka."
	DB	NEXT
	DB	"I call out to her, and she stops."
	DB	NEXT
	T_CG 'tt_21_11a',MOT_A2,0
	DB	"Motoka:  Yes? Oniichan." 
	DB	NEXT
	DB	"Kenjirou:  ...I'm sorry."
	DB	NEXT
	DB	"Motoka:  It's okay. I'll see you later, Oniichan." 
	DB	NEXT
	TATI_ERS
	DB	"Motoka leaves the classroom."
	DB	NEXT
	DB	"Motoka hasn't been smiling much these days."
	DB	NEXT
	DB	"Guess I'll head out, too."
	DB	NEXT
	DB	"I leave Motoka's classroom."
	DB	NEXT
	GO ROUKA
AB4:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Guess I'll check out the P.E. storage room."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"There's no one here."
	DB	NEXT
	DB	"Guess I'll go back."
	DB	NEXT
	GO ROUKA
AB5:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"I don't have any reason to go there, but I want to see my favorite teacher."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY		18
	DB	"Mika is here, dusting a statue."
	DB	NEXT
	DB	"Kenjirou:  Mika-sensei."
	DB	NEXT
	DB	"Mika:  Oh, Kondo-kun."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AD1,"LOOK AT TITS"
	MENU_SET	AD2,"LOOK AT ASS"
	MENU_SET	AD3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AD1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_1
	FLG_KI MIKA_NET,'=',1
WQ_1:
	DB	"Her arms are crossed, blocking the view of her tits. I'd love to slide my cock in between those tits, though."
	DB	NEXT
	GO BODY_MIKA
AD2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_2
	FLG_KI MIKA_NET,'=',1
WQ_2:
	DB	"My face has been buried in that ass. I'll not soon forget the memory."
	DB	NEXT
	GO BODY_MIKA
AD3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',6
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_3
	FLG_KI MIKA_NET,'=',1
WQ_3:
	DB	"Nice thighs, with good shape. Delicious."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Mika:  Were you looking at me just now?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Looking at you?"
	DB	NEXT
	DB	"Mika:  ...Never mind. Forget I said anything."
	DB	NEXT
	DB	"Mika:  Anyway, I'm glad you came on time."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Mika:  ...Don't tell me you forgot." 
	DB	NEXT
	DB	"Ulp! I did forget!"
	DB	NEXT
	DB	"Kenjirou:  I- I'll see you later, Mika-sensei..."
	DB	NEXT
	DB	"Mika:  W- Wait! Come back!" 
	DB	NEXT
	DB	"I hurriedly left the art room."
	DB	NEXT
	GO ROUKA
AB6:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"I head for the men's room."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"Second stall from the back, my private room. It's empty, as usual."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AE1,"GO IN"
	MENU_SET	AE2,"LEAVE"
	MENU_END
	DB	EXIT
AE1:
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'!=',1,QQ_1
	FLG_KI HAND,'=',3
	SINARIO 'AK_H.OVL'
QQ_1:
	FLG_IF MIKA_NET,'!=',1,QQ_2
	FLG_KI HAND,'=',3
	SINARIO 'MI_H.OVL'
QQ_2:
	FLG_IF TER_NET,'!=',1,QQ_3
	FLG_KI HAND,'=',3
	SINARIO 'TE_H.OVL'
QQ_3:
	FLG_IF RENA_NET,'!=',1,QQ_4
	FLG_KI HAND,'=',3
	SINARIO 'RE_H.OVL'
QQ_4:
	FLG_IF NANA_NET,'!=',1,QQ_5
	FLG_KI HAND,'=',3
	SINARIO 'NA_H.OVL'
QQ_5:
	FLG_IF SIZU_NET,'!=',1,QQ_6
	FLG_KI HAND,'=',3
	SINARIO 'SI_H.OVL'
QQ_6:
	FLG_IF CHIE_NET,'!=',1,QQ_7
	FLG_KI HAND,'=',3
	SINARIO 'CH_H.OVL'
QQ_7:
SENTAKU2:
	FLG_KI W,'=',-1
	FLG_IF RENA_NET,'!=',0,QW_1
	FLG_KI W,'DOWN',3
QW_1:
	FLG_IF NANA_NET,'!=',0,QW_2
	FLG_KI W,'DOWN',4
QW_2:
	FLG_IF SIZU_NET,'!=',0,QW_3
	FLG_KI W,'DOWN',5
QW_3:
	FLG_IF CHIE_NET,'!=',0,QW_4
	FLG_KI W,'DOWN',6
QW_4:
	MENU_S 2,W,-1
	MENU_SET	AF1,"AKEMI KONDO"
	MENU_SET	AF2,"TERUMI KINOUCHI"
	MENU_SET	AF3,"MIKA MAEDA"
	MENU_SET	AF4,"RENA WATANABE"
	MENU_SET	AF5,"NANA HIROSE"
	MENU_SET	AF6,"SHIZUKA HASEGAWA"
	MENU_SET	AF7,"CHIE UTSUMI"
	MENU_SET	AF8,"DON'T BOTHER"
	MENU_END
	DB	EXIT
AF1:
	DB	"Yes, Akemi-san would be nice."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'AK_H.OVL'
AF2:
	DB	"Let's go with Terumi-senpai."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'TE_H.OVL'
AF3:
	DB	"I'd love to do that with Mika-sensei."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'MI_H.OVL'
AF4:
	DB	"I can't forget the memories of spring vacation."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'RE_H.OVL'
AF5:
	DB	"I'd love to rip that uniform off her..."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'NA_H.OVL'
AF6:
	DB	"It'd be nice to get inside her."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'SI_H.OVL'
AF7:
	DB	"She looks great in her bathing suit."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'CH_H.OVL'
AF8:
	DB	"Nah, I guess I won't bother."
	DB	NEXT
	GO ROUKA
AE2:
DERU:
	DB	"I guess I should leave now."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Feeling much better, I head for the sink."
	DB	NEXT
	DB	"Ah, that was fine."
	DB	NEXT
	DB	"I wash my hands, and head out into the hall."
	DB	NEXT
	GO ROUKA
AB7:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'=',1
	FLG_KI TEMP08,'=',1
	DB	"The nurse's office... I wonder if Shizuka-sensei is in?"
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB	"Shizuka:  Are you sick?"
	DB	NEXT
	DB	"Kenjirou:  No, I'm fine."
	DB	NEXT
	DB	"Shizuka:  Then why are you here?"
	DB	NEXT
	DB	"Kenjirou:  I wanted to see you."
	DB	NEXT
	DB	"Shizuka:  Oh, that makes me so happy."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AG_1,"LOOK AT FACE"
	MENU_SET	AG_2,"LOOK AT ASS"
	MENU_SET	AG_3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AG_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_1
	FLG_KI SIZU_NET,'=',1
UR_1:
	DB	"She's lovely. A truly beautiful face."
	DB	NEXT
	GO BODY_SIZUKA
AG_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_2
	FLG_KI SIZU_NET,'=',1
UR_2:
	DB	"I'd love to have those manicured fingers gripping my cock."
	DB	NEXT
	GO BODY_SIZUKA
AG_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_3
	FLG_KI SIZU_NET,'=',1
UR_3:
	DB	"I can just see the lace at the top of her stockings. It's just too erotic."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Shizuka:  Where do you think you're looking, buster?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nowhere..."
	DB	NEXT
	DB	"Shizuka:  You're young, so I guess there's nothing that can be done about it."
	DB	NEXT
	DB	"Kenjirou:  I- I'll see you later, Shizuka-sensei."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Man, she's too smart for me."
	DB	NEXT
	GO ROUKA
HOKEN:
	FLG_KI HOK,'=',4
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',4
	SINARIO 'ER2.OVL'
KYOUSITU:
	FLG_KI HOK,'=',0
	BAK_INIT 'tb_034b',B_NORM
	DB	"I guess I'll go back to my own classroom."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB	"Time to get ready to go home."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI JUMP,'=',53
	SINARIO 'NITI_MAT.OVL'
JITAKU:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ah, it's great to be home."
	DB	NEXT
	DB	"I open the front door and enter."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		9
	T_CG 'tt_11_02',MOT_C3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Motoka and Akemi-san are here."
	DB	NEXT
	DB	"Kenjirou:  Hi, I'm home."
	DB	NEXT
	DB	"Motoka:  Oniichan, hi."
	DB	NEXT
	DB	"Akemi:  Kenjirou-kun, welcome home."
	DB	NEXT
	DB	"...Man, for some reason, I can't stop thinking about some of the things Tetsuya was saying about Motoka."
	DB	NEXT
	DB	"Motoka:  Oniichan? What's wrong?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing."
	DB	NEXT
	DB	"Akemi:  Are you feeling okay, Kenjirou-kun? Do you want to lie down?"
	DB	NEXT
	DB	"Kenjirou:  No, I'm really fine."
	DB	NEXT
	DB	"Akemi:  In that case, why don't you sit down? Dinner's almost ready." 
	DB	NEXT
	DB	"Kenjirou:  Okay. Sure."
	DB	NEXT
	DB	"I slowly sit down in my chair."
	DB	NEXT
	DB	"Motoka:  Why don't you put your book bag down, at least?"
	DB	NEXT
	DB	"Kenjirou:  Oh, that's a good idea."
	DB	NEXT
	DB	"I hadn't noticed until Motoka mentioned it, but I was holding my book bag to my chest. I hurriedly put it down by my feet."
	DB	NEXT
	DB	"Motoka:  ...You're acting kind of strange, Oniichan." 
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"...Why did Tetsuya have to go and start spreading rumors about Motoka? I'm sure there's nothing to them."
	DB	NEXT
	DB	"I could never doubt my own sister."
	DB	NEXT
	DB	"Kenjirou:  Well, time for bed."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
	FLG_KI HIDUKE,'+',1
	BAK_INIT 'tb_001a',B_NORM
	FLG_KI JUMP,'=',54
	SINARIO 'NITI_ASA.OVL'
FUFUFU_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',55
	SINARIO 'NITI_HIR.OVL'
FUFUFU_2:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',56
	SINARIO 'NITI_HOK.OVL'
FUFUFU_3:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',57
	SINARIO 'NITI_MAT.OVL'
FUFUFU_4:
	FLG_IF HANAJI,'=',1,ASA1
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',58
	SINARIO 'NITI_KIT.OVL'
FUFUFU_5:
	FLG_KI JUMP,'=',0
ASA1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',59
	SINARIO 'NITI_ASA.OVL'
FUFUFU_6:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',60
	FLG_KI	MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FUFUFU_7:
	FLG_KI JUMP,'=',0
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	BAK_INIT 'tb_018a',B_NORM
	CDPLAY		2
	FLG_KI	MOTDOYOU,'=',0
	DB	"I haven't been here during the day in a while."
	DB	NEXT
	GO	RARA
MATI:
	BAK_INIT	'tb_018a',B_NORM
	DB	"I wonder if there's anything to do ?"
	DB	NEXT
RARA:
	FLG_KI W,'=',-1
	FLG_IF TEMP02,'=',0,FF_1
	FLG_KI W,'DOWN',0
FF_1:
	FLG_IF TEMP03,'=',0,FF_2
	FLG_KI W,'DOWN',1
FF_2:
	FLG_IF TEMP04,'=',0,FF_3
	FLG_KI W,'DOWN',2
FF_3:
	FLG_IF TEMP05,'=',0,FF_4
	FLG_KI W,'DOWN',3
FF_4:
	FLG_IF TEMP06,'=',0,FF_5
	FLG_KI W,'DOWN',4
FF_5:
	FLG_IF TEMP07,'=',0,FF_6
	FLG_KI W,'DOWN',5
FF_6:
	MENU_S 2,W,-1
	MENU_SET	F1,"MOVIE THEATRE"
	MENU_SET	F2,"LINGERIE PUB"
	MENU_SET	F3,"PARK"
	MENU_SET	F4,"LOVE HOTEL"
	MENU_SET	F5,"BAR"
	MENU_SET	F6,"COFFEE SHOP"
	MENU_SET	F7,"GO HOME"
	MENU_END
	DB	EXIT
F1:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"A movie, huh? Maybe there's something good playing."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"It's daytime, but near this place it seems like the sun has started to disappear."
	DB	NEXT
	DB	"This place always looks the same, I guess."
	DB	NEXT
	DB	"There's nothing I want to see playing."
	DB	T_WAIT, 5
	DB	" Guess I'll go back."
	DB	NEXT
	GO MATI
F2:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"It's not the kind of place to go to during the day."
	DB	NEXT
	GO MATI
F3:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"I guess it's a good place to kill some time..."
	DB	NEXT
	BAK_INIT 'tb_032a',B_NORM
	CDPLAY		8
	DB	"It's daytime out, but I can still see couples walking together, hand in hand."
	DB	NEXT
	DB	"Terumi:  What are you doing here?"
	DB	NEXT
	DB	"I turn around to see Terumi-senpai standing there."
	DB	NEXT
	T_CG 'tt_05_32a',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	G1,"LOOK AT TITS"
	MENU_SET	G2,"LOOK AT ASS"
	MENU_SET	G3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
G1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI TER_NET,'=',1
LL_1:
	DB	"Terumi-senpai's tits are soft and round. Lots of volume, too."
	DB	NEXT
	GO BODY_TERUMI
G2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI TER_NET,'=',1
LL_2:
	DB	"A nice ass indeed. A nice line coming out from her waist."
	DB	NEXT
	GO BODY_TERUMI
G3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI TER_NET,'=',1
LL_3:
	DB	"Her thighs are soft and smooth. They go all the way down."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Terumi:  W- What's wrong? You got all quiet all of the sudden." 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing. What are you doing out here alone?"
	DB	NEXT
	DB	"Terumi:  I'm just out for a walk. What about you?"
	DB	NEXT
	DB	"Kenjirou:  Me?"
	DB	T_WAIT, 5
	DB	"Me? Well, I..."
	DB	NEXT
	DB	"I go over to Terumi-senpai and take a long sniff of her."
	DB	NEXT
	DB	"Terumi:  Are you a dog?!"
	DB	NEXT
	DB	"Kenjirou:  Yes, I'm your dog, Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  ...Okay, let's go, dog." 
	DB	NEXT
	DB	"I looked up at her. She was smiling."
	DB	NEXT
	DB	"Oh no! I'll bet Terumi-senpai is going to play another cruel joke on me, or something."
	DB	NEXT
	DB	"Terumi:  Aren't you going to reply to me, dog?"
	DB	NEXT
	DB	"Kenjirou:  *Bark!*"
	DB	NEXT
	DB	"Terumi:  Good dog!" 
	DB	NEXT
	DB	"Time for my escape!"
	DB	NEXT
	DB	"Kenjirou:  *Bark! Bark! Bark!*"
	DB	NEXT
	DB	"Terumi:  Ah! Come back!" 
	DB	NEXT
	DB	"Leaving Terumi-senpai behind me, I leave the park."
	DB	NEXT
	GO MATI
F4:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP05,'=',1
	DB	"It's not a place to go to during the day."
	DB	NEXT
	GO MATI
F5:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP06,'=',1
	DB	"It's not a place to go to during the day."
	DB	NEXT
	GO MATI
F6:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP07,'=',1
	DB	"A coffee shop. I think there was one around here somewhere..."
	DB	NEXT
	GO MATI
F7:
	DB	"It's too early to go home."
	DB	NEXT
	GO MATI
JITAKU2:
	BAK_INIT	'tb_018b',B_NORM
	DB	"I guess it's okay to go home now. I'm kind of hungry, too."
	DB	NEXT
	BAK_INIT 'tb_005b',B_NORM
	DB	"By the time I reach home, the sun is starting to set."
	DB	NEXT
	DB	"Ah, it's nice to be home..."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	DB	"Akemi-san is here, but Motoka is nowhere to be seen."
	DB	NEXT
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Akemi:  Ah, Kenjirou-kun. Welcome home."
	DB	NEXT
	DB	"Kenjirou:  Thanks."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	H1,"LOOK AT COLLARBONE"
	MENU_SET	H2,"LOOK AT TITS"
	MENU_SET	H3,"LOOK AT STOCKINGS"
	MENU_END
	DB	EXIT
H1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI AKEM_NET,'=',1
LA_1:
	DB	"A strong, sexy collarbone. The symbol of a beautiful woman."
	DB	NEXT
	GO BODY_AKEMI
H2:
	DB	"Her breasts are soft hills, creating a nice valley in the middle. I'm getting tired of looking at them, though."
	DB	NEXT
	GO BODY_AKEMI
H3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI AKEM_NET,'=',1
LA_3:
	DB	"Her long, shapely legs look so much better under the black nylon fabric of her stockings."
	DB	NEXT
	GO BODY_AKEMI
BODY_AKEMI:
	DB	"Akemi:  What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing."
	DB	NEXT
	DB	"Akemi:  You're acting a little strange, aren't you?"
	DB	NEXT
	DB	"Kenjirou:  ...Um, Akemi-san, where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She's in her room."
	DB	NEXT
	DB	"Kenjirou:  ...Oh."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"I'm bored. Guess I'll go to bed now."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	GO	KEKEKE
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Uuunnn??"
	DB	NEXT
	DB	"My eyelids slowly open."
	DB	NEXT
	BAK_INIT 'tb_001b',B_FADE
	DB	"Where am I?"
	DB	NEXT
	DB	"I look around me. I appear to be in my own room."
	DB	NEXT
	DB	"But what happened?"
	DB	NEXT
	DB	"I look at my clothes. There's a brown stain on them."
	DB	NEXT
	DB	"Blood? Now I remember -- I had a nosebleed."
	DB	NEXT
	DB	"I must have collapsed. But what happened after that?"
	DB	NEXT
	DB	"I lost consciousness..."
	DB	NEXT
	DB	"But someone must have brought me here."
	DB	NEXT
	DB	"Who could it have been?  ...Well, I'll think about it later. Time for bed now."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
KEKEKE:
	BAK_INIT 'tb_001a',B_FADE
	CDPLAY		12
	DB	"Kenjirou:  ..........."
	DB	NEXT
	DB	T_WAIT, 5
	DB	" Time to wake up."
	DB	NEXT
	DB	"I look at the clock. It reads just past noon."
	DB	NEXT
	DB	"Kenjirou:  Wow, I really got a lot of sleep..."
	DB	NEXT
	DB	"Well, it is Sunday. I guess I could sleep a little more."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_FADE
	DB	"Kenjirou:  Time for dinner..."
	DB	NEXT
	DB	"I can play some video games while I wait."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_FADE
	DB	"Tomorrow's Monday. I should get lots of sleep, to prepare for school."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,UIUI
	FLG_KI	ONANI,'=',0
UIUI:
	SINARIO 'MON_19.OVL'
END