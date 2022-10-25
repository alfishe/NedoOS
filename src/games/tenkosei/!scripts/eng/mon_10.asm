        include SUPER_C.inc
M_START:
MON_10
	FLG_IF HOK,'=',2,HUHUHU
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Zzzz... (...I'm so sleepy...)"
	DB	NEXT
	DB	"Kenjirou:  ........................................................................................"
	DB	NEXT
	CDPLAY	14
	F_O B_NORM,C_KURO
	DB	"Voice:  Hey! Wake up!"
	DB	NEXT
	DB	"Kenjirou:  .....Mm?"
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"Tetsuya:  You're finally up."
	DB	NEXT
	DB	"I lifted my head off the desk and looked at Tetsuya. "
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB	"Tetsuya:  It's lunchtime. Time to wake up."
	DB	NEXT
	DB	"Kenjirou:  Oh, you're right."
	DB	NEXT
	DB	"Tetsuya:  Well, I'm taking off. See you later." 
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  Have fun."
	DB	NEXT
	DB	"Guess I'll wander around myself, too."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
ROUKA:
	BAK_INIT 'tb_034a',B_NORM
	DB	"Well, where should I go?"
	DB	NEXT
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
	MENU_S 2,W,-1
	MENU_SET	C1,"GO BACK TO CLASS"
	MENU_SET	C2,"ROOF"
	MENU_SET	C3,"MUSIC ROOM"
	MENU_SET	C4,"P.E. ROOM"
	MENU_SET	C5,"ART ROOM"
	MENU_SET	C6,"MEN'S ROOM"
	MENU_END
	DB	EXIT
C1:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"I head back to my classroom."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"There's a wall of girls around Shiho again today, just like yesterday. There's no way I can approach her."
	DB	NEXT
	GO ROUKA
C2:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Guess I'll head for the roof."
	DB	NEXT
	BAK_INIT 'tb_012',B_NORM
	DB	"On the roof, standing near the chain-link fence, is Terumi-senpai."
	DB	NEXT
	T_CG 'tt_05_12',TER2,0
	DB	"Kenjirou:  Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  Ah, Kenjirou."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	D1,"LOOK AT TITS"
	MENU_SET	D2,"LOOK AT ASS"
	MENU_SET	D3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
D1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'	;
	DB	"Her tits are fine. The right one might be bigger than the other."
	DB	NEXT
	GO BODY
D2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Ah, a nice ass. There's a nice line moving out from her hips."
	DB	NEXT
	GO BODY
D3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Such nice thighs. Those legs go all the way down."
	DB	NEXT
	GO BODY
BODY:
	DB	"Terumi:  What's wrong? Why are you looking at me like that?"
	DB	NEXT
	DB	"Kenjirou:  I- I wasn't looking. Anyway, what are you doing up here?"
	DB	NEXT
	DB	"Terumi:  Nothing. I was just wandering around the school. What about you?"
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing, too. Just seeing what was up here."
	DB	NEXT
	DB	"Terumi:  You sure have a lot of free time."
	DB	NEXT
	DB	"Kenjirou:  Just like you."
	DB	NEXT
	DB	"Terumi:  I what? Why, you..." 
	DB	NEXT
	DB	"Pretending to be angry, she came at me with her fists balled up."
	DB	NEXT
	DB	"Kenjirou:  Hahaha (Hmm, think I'll get out of here, just in case.)"
	DB	NEXT
	DB	"Kenjirou:  Well, bye, Terumi-senpai!"
	DB	NEXT
	DB	"Terumi:  Wait, you!" 
	DB	NEXT
	DB	"I quickly put the roof behind me."
	DB	NEXT
	GO ROUKA
C3:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	BAK_INIT	'tb_010',B_NORM
	DB	"When I enter the room, Motoka runs over to me."
	DB	NEXT
	T_CG 'tt_10_10',MOT_A2,0
	DB	"Motoka:  Oniichan!"
	DB	NEXT
	DB	"Motoka:  What's up?"
	DB	NEXT
	DB	"Kenjirou:  Nothing."
	DB	NEXT
	DB	"Motoka:  Nothing? But there's a reason you're here, right?"
	DB	NEXT
	DB	"Kenjirou:  No, no reason."
	DB	NEXT
	DB	"Motoka:  I know! You got lonely, and wanted to see my pretty face." 
	DB	NEXT
	DB	"Kenjirou:  No, I was just passing by your classroom."
	DB	NEXT
	DB	"Motoka:  That's no fun." 
	DB	NEXT
	DB	"Motoka:  But the important part is, you came to see me, right?"
	DB	NEXT
	DB	"I'd better leave, before I get pulled into another embarrassing situation..."
	DB	NEXT
	DB	"Kenjirou:  Well, bye."
	DB	NEXT
	DB	"Motoka:  Oniichan!" 
	DB	NEXT
	DB	"I leave Motoka's classroom."
	DB	NEXT
	GO ROUKA
C4:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Guess I'll see what's in the P.E. storage room."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Tetsuya is here, looking for a ball."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Kenjirou:  Tetsuya, what are you doing in here?"
	DB	NEXT
	DB	"Tetsuya:  Ah, Kenjirou. We couldn't find a good ball to play with, so I'm looking for one in here. How about you?"
	DB	NEXT
	DB	"Kenjirou:  I'm just wandering around the school. "
	DB	NEXT
	DB	"Tetsuya:  You're what?"
	DB	NEXT
	DB	"Kenjirou:  See you later, Tetsuya."
	DB	NEXT
	DB	"I leave the P.E. storage room."
	DB	NEXT
	GO ROUKA
C5:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"Guess I'll go see what Mika-sensei is doing."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	DB	"Mika is dusting one of her strange-looking statues."
	DB	NEXT
	DB	"Kenjirou:  Mika-sensei."
	DB	NEXT
	DB	"Mika:  Ah, Kondo-kun."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	E1,"LOOK AT TITS"
	MENU_SET	E2,"LOOK AT ASS"
	MENU_SET	E3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
E1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,MIKA_1
;MIKA_NETA
MIKA_2:
	DB	"Her arms are folded over her tits, blocking my view. But they look nice."
	DB	NEXT
	GO MIKA_7
MIKA_1:
	FLG_KI MIKA_NET,'=',1
	GO MIKA_2
E2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,MIKA_3
;MIKA_NETA
MIKA_4:
	DB	"My face has known the supple bounciness of her ass. I'll never forget that moment."
	DB	NEXT
	GO MIKA_7
MIKA_3:
	FLG_KI MIKA_NET,'=',1
	GO MIKA_4
E3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',6
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,MIKA_5
;MIKA_NETA
MIKA_6:
	DB	"Nice thighs. Just the right amount of meat. "
	DB	NEXT
	GO MIKA_7
MIKA_5:
	FLG_KI MIKA_NET,'=',1
	GO MIKA_6
MIKA_7:
	DB	"Mika:  ...You were looking at me with lust in your eyes just now." 
	DB	NEXT
	DB	"Kenjirou:  Eh? I was? "
	DB	NEXT
	DB	"Mika:  ...Oh, never mind. "
	DB	NEXT
	DB	"Mika:  Anyway, why are you here? You're not supposed to start your extra lessons until tomorrow."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Mika:  ...Did you forget already?"
	DB	NEXT
	DB	"Oh no! I did forget!"
	DB	NEXT
	DB	"Kenjirou:  Well, I'll be going now..."
	DB	NEXT
	DB	"Mika:  W- Wai! Come back here!" 
	DB	NEXT
	DB	"I leave the art room."
	DB	NEXT
	GO ROUKA
C6:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"I head for the men's room."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"Second stall from the back, that's my office."
	DB	NEXT
	DB	"I've got nothing to do here. Guess I'll leave..."
	DB	NEXT
	GO ROUKA
KYOUSITU:
	BAK_INIT 'tb_034a',B_NORM
	DB	"Class will be starting again soon. Guess I'll go back now."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"The students are still talking among themselves. The girls are surrounding Kashima-san, as usual."
	DB	NEXT
	DB	"Is the new transfer student that new and interesting to them all?"
	DB	NEXT
	DB	"I put my head on the desk and prepare for sleep again."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Good night..."
	DB	NEXT
	DB	"Kenjirou:  ......................................................................................................."
	DB	NEXT
	DB	"Voice:  Hey, wake up!"
	DB	NEXT
	DB	"Kenjirou:  ...Mm?"
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  You're finally awake."
	DB	NEXT
	DB	"I pick my heavy head off the desk and look at him."
	DB	NEXT
	T_CG 'tt_08_11a',TET_A2,0
	DB	"Tetsuya:  You sure sleep a lot."
	DB	NEXT
	DB	"Kenjirou:  Don't praise me like that. I'm blushing."
	DB	NEXT
	DB	"Tetsuya:  It wasn't praise!" 
	DB	NEXT
	DB	"Tetsuya:  Anyway, I'm going home now. You should, too."
	DB	NEXT
	DB	"Kenjirou:  Ah."
	DB	NEXT
	DB	"Tetsuya:  Well, take care."
	DB	NEXT
	TATI_ERS 
	DB	"Tetsuya leaves the classroom. I get my bag up and prepare to do the same."
	DB	NEXT
	DB	"Well, time to head for home."
	DB	NEXT
	GO HUHUHU
HOKEN:
	FLG_KI HOK,'=',2
	SINARIO 'ER.OVL'
HUHUHU:
	FLG_KI HOK,'=',0
	BAK_INIT 'tb_034a',B_NORM
	DB	"It's quiet. I can't hear a sound. Everyone else must have gone home for the day. "
	DB	NEXT
	DB	"Huh? I hear something..."
	DB	NEXT
	DB	"A soft musical sound, coming from one of the rooms nearby."
	DB	NEXT
	CDPLAY	11
	DB	"Piano? Someone's playing. I've heard the song before..."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	F1,"GO TO MUSIC ROOM" 
	MENU_SET	F2,"GO HOME"
	MENU_END
	DB	EXIT
F1: 
	DB	"I swear I've heard that song before. I guess I'll go check it out..."
	DB	NEXT
	SINARIO 'MON_11.OVL'
F2:
	FLG_KI SIHO_PIA,'=',0
	DB	"I don't really care about that. I'll go home instead."
	DB	NEXT
	DB	"I leave the school."
	DB	NEXT
	SINARIO 'BUNKI_1.OVL'
END