        include SUPER_C.inc
M_START:
MON_16
	FLG_IF JUMP,'=',52,KYOUSITU
	BAK_INIT 'tb_034a',B_NORM
	CDPLAY		14
	T_CG 'tt_02_34a',SIH_A3,0
	T_CG 'tt_08_34a',TET_A1,0
	DB	"Shiho and I approached the door to our classroom. Tetsuya was standing there."
	DB	NEXT
	DB	"Kenjirou:  Good morning!"
	DB	NEXT
	DB	"Tetsuya:  .............."
	DB	NEXT
	TATI_ERS	;tt_08
	DB	"Ignoring my greetings, he silently went into the classroom."
	DB	NEXT
	T_CG 'tt_02_34a',SIH_A2,0
	DB	"Shiho:  ...What's wrong with him?" 
	DB	NEXT
	DB	"Kenjirou:  I don't know. He must have watched too much AV last night."
	DB	NEXT
	DB	"Shiho:  What's 'AV'?" 
	DB	NEXT
	DB	"Kenjirou:  ...Anyway, let's get inside. Class will be starting soon."
	DB	NEXT
	DB	"I headed into the classroom."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	;WAV	'Se_ch'
	DB	"Just then, the bell rang. "
	DB	NEXT
	DB	"Kenjirou:  Okay... (I guess I should stay awake in class every once in a while.)"
	DB	NEXT
	F_O B_NORM,C_KURO		;TB_000
	;WAV  'STOP'
	CDPLAY		0
	DB	"Kenjirou:  Zzzz.............................................................................."
        DB      "............................................................"
	DB	NEXT
	B_O B_FADE,C_KURO
	DB	"Kenjirou:  ....Mmmm......."
	DB	NEXT
	DB	"I slowly picked my head up."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	DB	"Kenjirou:  Ah!  (I had planned on staying awake today, but I fell asleep after all...)"
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB	"Tetsuya:  ...Um, Kenjirou. I wanted to apologize about this morning." 
	DB	NEXT
	DB	"Kenjirou:  What are you talking about?"
	DB	NEXT
	DB	"Tetsuya:  I ignored you this morning." 
	DB	NEXT
	DB	"Kenjirou:  Mm? I didn't notice anything."
	DB	NEXT
	DB	"Tetsuya:  ...You didn't? And you call yourself a friend?" 
	DB	NEXT
	DB	"Kenjirou:  I figured you had watched too much AV last night, and hadn't gotten enough sleep."
	DB	NEXT
	DB	"Tetsuya:  ...Well, if you're not worried about it..."
	DB	NEXT
	DB	"Kenjirou:  I'm not."
	DB	NEXT
	DB	"Tetsuya:  Okay."
	DB	NEXT
	DB	"Tetsuya:  Do you want to go hang out, play some basketball?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	P1,"SURE - WHY NOT?"
	MENU_SET	P2,"NAH - I'D RATHER NOT"
	MENU_END
	DB	EXIT
P1:
	DB	"Kenjirou:  Sure, I need to get more exercise anyway."
	DB	NEXT
	DB	"Tetsuya:  Great, let's go."
	DB	NEXT
	DB	"Tetsuya:  I'll go get a ball from the P.E. storage room."
	DB	NEXT
	DB	"Kenjirou:  I'll get one. "
	DB	NEXT
	DB	"Tetsuya:  Oh, okay. Then I'll see you on the roof. Don't get one that has no air in it."
	DB	NEXT
	TATI_ERS		;tt_08
	DB	"With that, he left the classroom."
	DB	NEXT
	DB	"Guess I'll head for the P.E. storage locker."
	DB	NEXT
	SINARIO 'MON_17.OVL'
P2:
	DB	"Kenjirou:  Nah, there's something I've got to do."
	DB	NEXT
	DB	"Tetsuya:  Something you've got to do?"
	DB	NEXT
	DB	"Kenjirou:  Yes. Go for a walk."
	DB	NEXT
	DB	"Tetsuya:  .................."
	DB	NEXT
	DB	"Kenjirou:  I'm kidding. But I just want to walk around and relax a little."
	DB	NEXT
	DB	"Tetsuya:  You got enough relaxing during class! You slept through the whole thing!" 
	DB	NEXT
	DB	"Kenjirou:  Yes, but sleep isn't the same as just relaxing."
	DB	NEXT
	DB	"Tetsuya:  I see. Well, I'll see you later, then."
	DB	NEXT
	DB	"Kenjirou:  Okay."
	DB	NEXT
	TATI_ERS		;tt_08
	DB	"Tetsuya leaves the classroom."
	DB	NEXT
	DB	"Guess I'll wander around now."
	DB	NEXT
	FLG_KI JUMP,'=',52
	SINARIO 'NITI_HIR.OVL'
KYOUSITU:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_034a',B_NORM
	DB	"Class is about to start. I'd better get back to my classroom."
	DB	NEXT
	SINARIO 'MON_18.OVL'
END