        include SUPER_C.inc
M_START:
MON_39
	FLG_IF JUMP,'=',72,FF_3
	FLG_IF JUMP,'=',71,FF_2
	FLG_IF JUMP,'=',70,FF_1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  *Yawn*  Ah, I slept well..."
	DB	NEXT
	DB	"Guess I'll get dressed and go eat breakfast."
	DB	NEXT
	DB	"I put on my uniform, and head down to the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Akemi:  Good morning."
	DB	NEXT
	DB	"Motoka is nowhere to be seen in the dining kitchen."
	DB	NEXT
	DB	"Kenjirou:  Akemi-san, where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She went to school already. She said something about meeting a friend, or something."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"Akemi:  Did you want to walk to school with her?"
	DB	NEXT
	DB	"Kenjirou:  N- No, of course not! I didn't mean it that way."
	DB	NEXT
	DB	"I finished my breakfast, and headed off to school."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY	2
	BAK_INIT	'tb_006',B_NORM
	DB	"I stopped off at the convenience store to get my lunch. I always spend less than 500 yen on lunch."
	DB	NEXT
	BAK_INIT	'tb_007',B_NORM
	CDPLAY	3
	DB	"Inside, Terumi-senpai is in the magazine corner, reading the magazines."
	DB	NEXT
	T_CG	'tt_05_07',TER2,0
	DB	"Kenjirou:  Good morning, Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  Good morning. Shall we go to school?" 
	DB	NEXT
	DB	"Kenjirou:  Eh?" 
	DB	NEXT
	DB	"Terumi:  You know, our school?" 
	DB	NEXT
	DB	"Kenjirou:  O- Okay, let's go..."
	DB	NEXT
	DB	"I went out the door with Terumi-senpai, not forgetting for some time that I had forgotten to buy my lunch."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"I went to the train station and got on my train."
	DB	NEXT
	BAK_INIT	'tb_008',B_NORM
	T_CG	'tt_05_08',TER2,0
	DB	"Terumi:  Darn, I hate this next stop. A ton of people always get on the train." 
	DB	NEXT
	DB	"Kenjirou:  Yes, well, this is Japan."
	DB	NEXT
	DB	"The train stopped, and the doors opened. Immediately a flood of people raced at us."
	DB	NEXT
	DB	"Terumi:  Here they come..."
	DB	NEXT
	DB	"The rush of people was so great, that Terumi and I were caught in it, utterly unable to move."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Terumi:  T- This is the worst I've ever seen..."
	DB	NEXT
	DB	"Kenjirou:  Yes. The things we do to avoid being late for school."
	DB	NEXT
	DB	"Terumi:  ...I don't mind being late, if the train will be less crowded than this." 
	DB	NEXT
	DB	"Kenjirou:  Yes, yes."
	DB	NEXT
	DB	"As we neared our stop, the train got quieter and quieter, as people prepared to get off."
	DB	NEXT
	DB	"Terumi:  Kya!" 
	DB	NEXT
	DB	"(Kya?)"
	DB	NEXT
	DB	"Terumi-senpai let out a little shriek, and was trying to move her body."
	DB	NEXT
	DB	"I look down at Terumi-senpai's bottom, and see a man's hand there, feeling it."
	DB	NEXT
	DB	"Oh, how sad. Even Terumi-senpai gets groped on trains."
	DB	NEXT
	DB	"I was sure what she would do next."
	DB	NEXT
	DB	"But to my surprise, she just pushed his hand away, and moved away from it."
	DB	NEXT
	DB	"Terumi:  Damn perverts..." 
	DB	NEXT
	DB	"Kenjirou:  Huh? "
	DB	NEXT
	DB	"Because the train was so crowded, she couldn't free her hands to do anything."
	DB	NEXT
	DB	"I could probably reach her..."
	DB	NEXT
	DB	"Slowly, I move towards the pervert, careful so that he doesn't see me coming."
	DB	NEXT
	DB	"Kenjirou:  Hey!"
	DB	NEXT
	DB	"Pervert:  Wah?"
	DB	NEXT
	DB	"With an unrepentant grin, he moved away from Terumi, and melted away into the crush of bodies."
	DB	NEXT
	DB	"He's good at that. He must be a repeat offender."
	DB	NEXT
	DB	"Terumi:  ...Thanks." 
	DB	NEXT
	DB	"Kenjirou:  ...Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  ................." 
	DB	NEXT
	DB	"Kenjirou:  Why didn't you ask me for help before?"
	DB	NEXT
	DB	"Terumi:  ....................." 
	DB	NEXT
	DB	"Kenjirou:  ...Am I so useless that you couldn't ask me directly?"
	DB	NEXT
	DB	"Terumi:  That's not it..." 
	DB	NEXT
	DB	"Kenjirou:  You know, I'm..."
	DB	T_WAIT,	3
	DB	" I'm a man, too."
	DB	NEXT
	DB	"Terumi:  I know. I've been noticing that a lot..." 
	DB	T_WAIT,	3
	DB	"You've changed, recently."
	DB	NEXT
	FLG_KI	TER_DEN,'=',1
	DB	"Just then, the train arrived at its destination, and the doors opened, flooding everyone out onto the train platform."
	DB	NEXT
	BAK_INIT	'tb_009',B_NORM
	CDPLAY	2
	DB	"Kenjirou:  Huh? Where's Terumi-senpai?"
	DB	NEXT
	DB	"I look around me, but can't see her anywhere."
	DB	NEXT
	DB	"I guess she got swept away."
	DB	NEXT
	DB	"But if that's the case, she could wait for me, at least."
	DB	NEXT
	DB	"I head for school alone."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	14
	T_CG	'tt_08_10',TET_A2,0
	DB	"Tetsuya:  Morning." 
	DB	NEXT
	DB	"Kenjirou:  Morning."
	DB	NEXT
	DB	"Tetsuya:  You came alone today."
	DB	NEXT
	DB	"Kenjirou:  That doesn't mean anything."
	DB	NEXT
	DB	"Tetsuya:  Really? I wonder. Oh, Kashima-san's here."
	DB	NEXT
	DB	"I hate it when he makes observations like that..."
	DB	NEXT
	DB	"Tetsuya:  What's the matter? Why did you get so quiet all of the sudden?"
	DB	NEXT
	DB	"Kenjirou:  Nothing."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"The bell rings, signaling the start of class."
	DB	NEXT
	DB	"Kenjirou:  Guess I'll go sit down."
	DB	NEXT
	DB	"Tetsuya:  Yep." 
	DB	NEXT
	TATI_ERS
	DB	"I take my seat."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"I blandly watch the blackboard, and wonder what the point of an education is."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	JUMP,'=',70
	SINARIO	'NITI_HIR.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI	JUMP,'=',71
	SINARIO	'NITI_HOK.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY	22
	DB	"It was evening by the time I got out of school, and the sun was below the horizon. "
	DB	NEXT
	DB	"Guess I'll go home today."
	DB	NEXT
	FLG_KI JUMP,'=',72
	SINARIO	'NITI_KIT.OVL'
FF_3:
	FLG_KI JUMP,'=',0
	SINARIO 'MOM_40.OVL'
END