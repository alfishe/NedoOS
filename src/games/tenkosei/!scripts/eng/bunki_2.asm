        include SUPER_C.inc
M_START:
BUNKI_2
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		23
	T_CG	'tt_02_10',SIH_A2,0
	DB	"Kenjirou:  I'm sorry, I wasn't listening."
	DB	NEXT
	DB	"I was thinking dirty thoughts, of course."
	DB	NEXT
	DB	"Shiho:  I see."
	DB	NEXT
	DB	"Shiho turns her beautiful eyes on me, then looks away."
	DB	NEXT
	DB	"Suddenly feeling odd, I stand up and prepare to leave the room."
	DB	NEXT
	DB	"Shiho:  Wait." 
	DB	NEXT
	DB	"Shiho calls out to stop me, and suddenly presses her body against mine."
	DB	NEXT
	DB	"Kenjirou:  W- What?"
	DB	NEXT
	EVENT_CG	'ti_122',B_NORM,76
	DB	"Kenjirou:  Mmmm..."
	DB	NEXT
	DB	"Shiho slides her tongue into my mouth, suddenly exploring."
	DB	NEXT
	DB	"Shocked, all I could do was allow her tongue's entry."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG	'tt_02_10',SIH_A2,0
	DB	"Kenjirou:  ................"
	DB	NEXT
	DB	"Shiho:  Goodbye, Kenjirou." 
	DB	NEXT
	DB	"Shiho waved to me once, and left the classroom. Dazed, I just watched her go."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Y- You son of a bitch! When did you and Shiho...?!"
	DB	NEXT
	DB	"Kenjirou:  ..............."
	DB	NEXT
	DB	"Leaving the shocked Tetsuya behind me, I left for home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY		12
	DB	"Back in my room, I fell into an uncomfortable sleep, unable to think coherently about Shiho."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	BAK_INIT	'tb_001a',B_NORM
	DB	"I wake my tired body up and slowly get dressed, ready to go off to school."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		14
	DB	"I look around for Shiho. However, I can't find her, and even her desk is gone."
	DB	NEXT
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Hey, Kenjirou."
	DB	NEXT
	DB	"Tetsuya sounds like he always does. It's almost like what happened yesterday never really happened."
	DB	NEXT
	DB	"Kenjirou:  Morning..."
	DB	NEXT
	DB	"Tetsuya:  What's wrong?" 
	DB	NEXT
	DB	"Kenjirou:  Huh? Aren't you mad?"
	DB	NEXT
	DB	"Tetsuya:  Mad? Why would I be mad?"
	DB	NEXT
	DB	"Kenjirou:  Well.. I mean, what happened with Shiho..."
	DB	NEXT
	DB	"Tetsuya:  Shiho? Who's Shiho?"
	DB	NEXT
	DB	"Kenjirou:  You know, the girl in this class. Shiho Kashima."
	DB	NEXT
	DB	"Tetsuya:  Shiho Kashima? There's no one with that name in our class." 
	DB	NEXT
	DB	"Kenjirou:  What? But that can't be..."
	DB	NEXT
	DB	"Tetsuya:  I think you slept a little too much last night." 
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Just then, the bell rang. I sat down at my desk, leaving my confusion in the air."
	DB	NEXT
	TATI_ERS
	F_O	B_NORM,C_KURO
	;WAV  'STOP'
	DB	"Suddenly I heard the door open, and the classroom was silent. I was sure the professor had entered the room."
	DB	NEXT
	DB	"After that, whenever the bell would ring, I would look down, and think about how Shiho had disappeared from the class."
	DB	NEXT
	DB	"After the bell had rung several times, Tetsuya came to wake me up."
	DB	NEXT
	DB	"Tetsuya:  Wake up already. It's lunchtime."
	DB	NEXT
	DB	"I wasn't asleep, but I slowly lifted my head up, as if I still were."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Oh, you're awake. I'm shocked."
	DB	NEXT
	DB	"Kenjirou:  Really?"
	DB	NEXT
	DB	"Tetsuya:  What happened to you, anyway? You're scaring me, you know." 
	DB	NEXT
	DB	"Kenjirou:  I'm not sure..."
	DB	NEXT
	DB	"Tetsuya:  You sleep way too much, you know. It's frying your brain."
	DB	NEXT
	DB	"Kenjirou:  I'll try to watch myself."
	DB	NEXT
	DB	"Slowly, I got to my feet."
	DB	NEXT
	DB	"Tetsuya:  Are you going somewhere?"
	DB	NEXT
	DB	"Kenjirou:  Sorry... Would you mind leaving me alone for a while?"
	DB	NEXT
	DB	"Tetsuya:  Are you okay, man? I mean, you're..." 
	DB	NEXT
	DB	"Kenjirou:  I'm alright, I just got too much sleep, and my head's kind of hazy right now. I'm going up to the roof for some air."
	DB	NEXT
	DB	"Leaving Tetsuya behind, I headed for the roof."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	DB	"There are quite a lot of people on the roof of the school building at lunchtime."
	DB	NEXT
	DB	"I met Terumi-senpai up here quite a bit, too."
	DB	NEXT
	DB	"Looking at the sky, my thoughts turned to Shiho, who had disappeared like the clouds above me."
	DB	NEXT
	EVENT_CG	'ti_135',B_NORM,77
	CDPLAY		23
	DB	"Shiho, you were really here, I know you were. I didn't dream you."
	DB	NEXT
	FLG_IF	MOT_YATT,'=',1,DAREKA
	FLG_IF	TER_YATT,'=',1,DAREKA
	DB	"Shiho:  You didn't imagine me." 
	DB	NEXT
	DB	"Kenjirou:  Shiho..."
	DB	NEXT
	DB	"Shiho:  Kenjirou... Love me again, in a dream."
	DB	NEXT
	DB	"Looking at the sky, I was sure I could hear Shiho talking to me."
	DB	NEXT
	GAME_END
	DB	EXIT
DAREKA:
	DB	"Shiho:  Don't worry about me. There's someone who really loves you. I want you to take care of her, and protect her." 
	DB	NEXT
	DB	"Kenjirou:  Shiho... I... Okay."
	DB	NEXT
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	FLG_IF	TER_YATT,'=',1,TERUEND
	CDPLAY		0
	DB	"Three years later..."
	DB	NEXT
	DB	"Motoka and I were married the same month she graduated from college."
	DB	NEXT
	EVENT_CG	'th_ed02',B_FADE,55
	CDPLAY		26
	DB	"Akemi and my father were surprisingly happy for us, and encouraged us to get married."
	DB	NEXT
	DB	"Motoka:  Onii- Er, I mean..." 
	DB	T_WAIT,	3
	DB	"..... Kenjirou."
	DB	NEXT
	DB	"Her cheeks suddenly red, Motoka shyly calls me by my name for the first time."
	DB	NEXT
	DB	"Motoka:  Let's... Let be happy together." 
	DB	NEXT
	DB	"Kenjirou:  Yes, we will."
	DB	NEXT
	DB	"Motoka:  I'm so happy!" 
	DB	NEXT
	DB	"Looking at the smiling Motoka filled me with happiness."
	DB	NEXT
	E_NO	-1
	GAME_END
	DB	EXIT
TERUEND:
	DB	"I haven't seen Terumi-senpai for a long time, so I decide to drop by her house. We go up to her room."
	DB	NEXT
	DB	"Terumi-senpai tells me that she had been avoiding me, because of her embarrassment."
	DB	NEXT
	DB	"After that..."
	DB	NEXT
	EVENT_CG	'th_ed03',B_FADE,0
	CDPLAY		19
	DB	"We made love again."
	DB	NEXT
	CDPLAY		0
	DB	"Terumi:  I never thought that Kenjirou and I would end up here, in bed together."
	DB	NEXT
	DB	"Kenjirou:  Me neither."
	DB	NEXT
	DB	"Terumi:  Mmm... But I like it." 
	DB	NEXT
	DB	"Kenjirou:  You did?"
	DB	NEXT
	DB	"Terumi:  Yes. I... I'm really happy now, Kenjirou." 
	DB	NEXT
	DB	"Saying nothing, I held her close to me. I prayed that our happiness would continue forever."
	DB	NEXT
	E_NO	-1
	GAME_END
	DB	EXIT
END