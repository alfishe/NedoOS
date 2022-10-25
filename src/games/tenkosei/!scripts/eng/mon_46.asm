        include SUPER_C.inc
M_START:
MON_46
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  Hey, it's a nice day out."
	DB	T_WAIT,	3
	DB	" Time for some video games!"
	DB	NEXT
	DB	"I turn on the video game console and pick up a controller."
	DB	NEXT
	DB	"Staring at the TV screen, I begin to play."
	DB	NEXT
	FLG_IF	TET_KAIS,'>=',25,RANP
GAME:
	F_O	B_FADE,C_KURO
	DB	"Suddenly, I look up, and notice that it's gotten dark outside."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	DB	"Kenjirou:  What the..."
	DB	T_WAIT,	3
	DB	" It's dark out."
	DB	NEXT
	F_O	B_FADE,C_KURO
	DB	"I took a bath, and then headed for bed."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEKINAI
	FLG_KI	ONANI,'=',0
DEKINAI:
	SINARIO	'MON_47.OVL'
	DB	EXIT
RANP:
	F_O	B_FADE,C_KURO
	TATI_ERS
	;WAV	'Se_no'
	DB	"I hear a knock on the door."
	DB	NEXT
	DB	"Akemi:  Kenjirou, are you up? Telephone." 
	DB	NEXT
	DB	"Kenjirou:  Okay, I'll be right there."
	DB	NEXT
	DB	"Telephone? Who would be calling me?"
	DB	NEXT
	DB	"I pause my game and leave the room."
	DB	NEXT
	F_O	B_NORM,C_KURO
;-- I see in this section, he's talking to Tetsuya on the phone, so really,
;-- we;d rather have no face for tetsuya at all. Is this possible?
	DB	"Kenjirou:  Hello?"
	DB	NEXT
	DB	"Voice:  Ah, Kenjirou?"
	DB	NEXT
	DB	"Kenjirou:  Oh, Tetsuya. What's up?"
	DB	NEXT
	DB	"Tetsuya:  What do you mean, 'Oh, Tetsuya?'" 
	DB	NEXT
	DB	"Kenjirou:  Sorry."
	DB	NEXT
	DB	"Kenjirou:  And? Why are you calling?"
	DB	NEXT
	DB	"Tetsuya:  You want to know the reason?" 
	DB	NEXT
	DB	"Kenjirou:  Sure. Tell me."
	DB	NEXT
	DB	"Tetsuya:  Okay, I'll tell you. At 5:30, put on some grown-up clothes and come to my house." 
	DB	NEXT
	DB	"Kenjirou:  Your house?"
	DB	NEXT
	DB	"Tetsuya:  Bye!" 
	DB	NEXT
	DB	"Kenjirou:  Wait! Tetsuya!"
	DB	NEXT
	DB	"The phone was dead."
	DB	NEXT
	DB	"What is he talking about?"
	DB	NEXT
	DB	"I guess I'll go play some more video games."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	DB	"I pick up the controller and un-pause my game."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	TATI_ERS
	DB	"Hmm, stupid game."
	DB	NEXT
	DB	"I look at the clock, which reports that it's a little past 4 pm."
	DB	NEXT
	DB	"Oh, that reminds me, Tetsuya was saying something to me on the phone..."
	DB	NEXT
	DB	"What should I do?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	IKU,"GO WITH TETSUYA"
	MENU_SET	YAME,"DON'T BOTHER"
	MENU_END
	DB	EXIT
IKU:
	DB	"Guess I'll go with Tetsuya."
	DB	NEXT
	GO MAN
	DB	EXIT
YAME:
	DB	"Nah, it's not worth my trouble."
	DB	NEXT
	DB	"I turn back to my video games."
	DB	NEXT
	GO GAME
	DB	EXIT
MAN:
	DB	"As Tetsuya instructed me, I dressed in my best clothes."
	DB	NEXT
	DB	"I guess this is good enough."
	DB	NEXT
	DB	"Leaving my room, I head for the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_11_02',MOT_C3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Motoka:  W- What are you dressed up like that for?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Does it look funny?"
	DB	NEXT
	DB	"Motoka:  No, it's just a little strange..."
	DB	NEXT
	DB	"Akemi:  Are you going out?"
	DB	NEXT
	DB	"Kenjirou:  Yes, I'm going to Tetsuya's house."
	DB	NEXT
	DB	"Akemi:  You're dressed up like that to go to a guy's house?"
	DB	NEXT
	DB	"Kenjirou:  Oh, well... He told me to dress like this."
	DB	NEXT
	DB	"Akemi:  Don't do anything stupid."
	DB	NEXT
	DB	"Kenjirou:  Haha, yeah..."
	DB	NEXT
	B_O	B_FADE,C_KURO
	DB	"I leave the house and head for Tetsuya's place."
	DB	NEXT
	BAK_INIT	'tb_033',B_NORM
	CDPLAY	17
	T_CG	'tt_07_33',TET_B2,0
	DB	"He's waiting for me in front of his house."
	DB	NEXT
	DB	"Tetsuya:  Kenjirou! You're late!" 
	DB	NEXT
	DB	"Kenjirou:  I am?"
	DB	NEXT
	DB	"Tetsuya:  Anyway, let's go."
	DB	NEXT
	DB	"Kenjirou:  Go where?"
	DB	NEXT
	DB	"He starts walking without me, forcing me to run to catch him."
	DB	NEXT
	DB	"Kenjirou:  Where are we going?"
	DB	NEXT
	DB	"Tetsuya:  Hehe..."
	DB	T_WAIT,	3
	DB	" Someplace good."
	DB	NEXT
	DB	"He stop, turns around at me, and smiles slyly."
	DB	NEXT
	DB	"Kenjirou:  So?"
	DB	NEXT
	DB	"Tetsuya:  Just follow me, hehe." 
	DB	NEXT
	DB	"What the...? I don't know about this."
	DB	NEXT
	DB	"Tetsuya:  Come, my friend, to walk the road where only real men can walk!"
	DB	NEXT
	DB	"Kenjirou:  ................"
	DB	NEXT
	DB	"He starts walking again."
	DB	NEXT
	DB	"Kenjirou:  Are you feeling okay? You might have a fever."
	DB	NEXT
	DB	"Growing all the more confused, I follow behind him."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_018c',B_NORM
	CDPLAY	22
	T_CG	'tt_07_18c',TET_B2,0
	DB	"The sun sinks low on the horizon."
	DB	NEXT
	DB	"Tetsuya:  My friend, tomorrow is almost here." 
	DB	NEXT
	DB	"Kenjirou:  Yes, yes."
	DB	NEXT
	DB	"Faster and faster Tetsuya walks."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_027',B_NORM
	T_CG	'tt_07_27',TET_B2,0
	DB	"He stops in front of the lingerie pub, and turns an evil grid towards me."
	DB	NEXT
	DB	"O- Oh no!"
	DB	NEXT
	DB	"Tetsuya:  My friend, this is our destination."
	DB	NEXT
	DB	"Kenjirou:  Eh? This place?"
	DB	NEXT
	DB	"Tetsuya:  Yes. "
	DB	NEXT
	DB	"Kenjirou:  Tetsuya, you're not serious about going in here, are you?"
	DB	NEXT
	DB	"Tetsuya:  He he he..."
	DB	NEXT
	DB	"With another evil grin, he brings out a card from his pocket."
	DB	NEXT
	DB	"Kenjirou:  Are you serious about this?"
	DB	NEXT
	DB	"Tetsuya:  Well, let's go in."
	DB	NEXT
	DB	"Kenjirou:  ...Yeah, let's."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"Inside, an odd man wearing a black suit and a tie appears."
	DB	NEXT
	DB	"Man in Black:  Hello, may I help you?"
	DB	NEXT
	DB	"Tetsuya:  Here you go, sir." 
	DB	T_WAIT,	3
	DB	" I think you'll enjoy this, Kenjirou."
	DB	NEXT
	DB	"He shows the card to the man."
	DB	NEXT
	DB	"Man in black:  W- Why this is our platinum card! I- I'm so sorry, sir."
	DB	NEXT
	DB	"The man led us into the pub."
	DB	NEXT
	BAK_INIT	'tb_028',B_NORM
	CDPLAY	16
	DB	"Inside the room were several beautiful women, clad only in stunningly sexy lingerie. We're lead to a special VIP area."
	DB	NEXT
	DB	"Tetsuya:  Kenjirou, isn't it great to be alive?"
	DB	NEXT
	DB	"Kenjirou:  Yep..."
	DB	NEXT
	DB	"Lingerie girl 1:  Oh, sir!"
	DB	NEXT
	DB	"A beautiful lingerie-clad waitress was suddenly sitting on Tetsuya's lap, laughing."
	DB	NEXT
	DB	"Tetsuya:  What's so amazing?"
	DB	NEXT
	DB	"Lingerie girl 1:  I've never seen such a young, good-looking man in the VIP corner."
	DB	NEXT
	DB	"Tetsuya:  Oh, I'm only here because my father is who he is."
	DB	NEXT
	DB	"Lingerie girl 2:  Please introduce your papa to me."
	DB	NEXT
	DB	"Man, he's lucky to be getting all the attention."
	DB	NEXT
	DB	"I feel a little sad to be left out. I look around the room."
	DB	NEXT
	DB	"All around the room, girls were sitting on customers' laps, putting their breasts in the men's' faces, and so on."
	DB	NEXT
	DB	"Damn! I want some of that..."
	DB	NEXT
	DB	"Suddenly, a girl's eyes meet mine."
	DB	NEXT
	DB	"Lingerie girl 2:  Sir, what's wrong?"
	DB	NEXT
	DB	"Kenjirou:  Eh? What do you mean?"
	DB	NEXT
	DB	"Lingerie girl 2:  You've been so quiet, and you're looking around the room."
	DB	NEXT
	DB	"Kenjirou:  Oh, it's nothing. Just a little envious, perhaps."
	DB	NEXT
	DB	"I pointed to a customer, eating out one of the girl's pussies at another table."
	DB	NEXT
	DB	"Lingerie girl 2:  Oh, sir, you're such a pervert."
	DB	NEXT
	DB	"Kenjirou:  Well, I'm a man."
	DB	NEXT
	DB	"Lingerie girl 2:  Shall I do that for you?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Are you serious?"
	DB	NEXT
	DB	"Lingerie girl 2:  If you promise to introduce your father to me next time."
	DB	NEXT
	DB	"Kenjirou:  I will, I will."
	DB	NEXT
	DB	"Lingerie girl 2:  Then I'll do it for you."
	DB	NEXT
	DB	"The hostess got up onto the sofa, and straddled me."
	DB	NEXT
	DB	"Lingerie girl 2:  Relax your back, and put your face down like this, sir."
	DB	NEXT
	DB	"I did as I was told, and she moved up to straddle my face with her pussy."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Slowly, she pushed her slit towards my face, allowing me to lick it through her panty bottoms."
	DB	NEXT
	DB	"Kenjirou:  Fo, fooaha."
	DB	NEXT
	DB	"Lingerie girl 2:  Oh! Sir, try not to talk."
	DB	NEXT
	DB	"She moved her lower back, stroking my face with her entire pussy region."
	DB	NEXT
	DB	"I could tell there was dampness in her crotch."
	DB	NEXT
	DB	"Lingerie girl 2:  Okay, that's all."
	DB	NEXT
	BAK_INIT	'tb_028',B_NORM
	DB	"Lingerie girl 2:  How was it?"
	DB	NEXT
	DB	"Kenjirou:  Great."
	DB	NEXT
	DB	"Lingerie girl 2:  I've got to change my panties. I'll be right back."
	DB	NEXT
	DB	"Kenjirou:  Why do that?"
	DB	NEXT
	DB	"Lingerie girl 2:  Oh! You know..."
	DB	NEXT
	DB	"Kenjirou:  I like you just the way you are now."
	DB	NEXT
	DB	"Lingerie girl 2:  Oh, you're such a bad man. Okay, I'll keep these on then, just...for...you."
	DB	NEXT
	F_O	B_FADE,C_KURO
	DB	"I was quite for a while, then."
	DB	NEXT
	TATI_ERS
	DB	"Tetsuya:  Hey, Kenjirou."
	DB	NEXT
	DB	"Kenjirou:  What is it?"
	DB	NEXT
	DB	"Tetsuya:  Let's go home."
	DB	NEXT
	DB	"Kenjirou:  Hmm, I wanted to do a little more here. Oh well, we can come back, I guess."
	DB	NEXT
	DB	"Tetsuya:  Okay, let's go."
	DB	NEXT
	DB	"Lingerie girl 1:  Oh, are you leaving already?"
	DB	NEXT
	DB	"Kenjirou:  Haha, sorry."
	DB	NEXT
	DB	"Lingerie girl 2:  These two are going home."
	DB	NEXT
	DB	"At her words, the man in the black suit reappeared."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"Man in black:  Will you be going home then, sirs?"
	DB	NEXT
	DB	"Tetsuya:  Yes."
	DB	NEXT
	DB	"Man in black:  That comes to $1,280, then."
	DB	NEXT
	DB	"Tetsuya handed the man the card."
	DB	NEXT
	DB	"Tetsuya:  Put it on our tab." 
	DB	NEXT
	DB	"Man in black:  Excuse me?"
	DB	NEXT
	DB	"Tetsuya:  I said, put it on our tab."
	DB	NEXT
	DB	"Man in black:  We don't have a service like that at this establishment, sir."
	DB	NEXT
	DB	"Tetsuya:  Oh."
	DB	NEXT
	DB	"Tetsuya pretends to open his wallet, and quietly makes eye contact with me."
	DB	NEXT
	DB	"I- Is he serious?"
	DB	NEXT
	DB	"I knew what he was going to do."
	DB	NEXT
	DB	"He looked at me one more time to check if I had caught the meaning of his glance, "
        DB      "then he dropped his wallet on the floor. The moment the man in black's eyes moved "
        DB      "towards the dropped object, we ran out of the pub."
	DB	NEXT
	BAK_INIT	'tb_027',B_NORM
	T_CG	'tt_07_27',TET_B2,0
	DB	"Tetsuya:  Run, man!" 
	DB	NEXT
	DB	"Kenjirou:  I'm running!"
	DB	NEXT
	DB	"We both sprinted as fast as we could away from there."
	DB	NEXT
	BAK_INIT	'tb_018c',B_NORM
	CDPLAY	22
	T_CG	'tt_07_18c',TET_B2,0
	DB	"Tetsuya:  Oh, that was dangerous!" 
	DB	NEXT
	DB	"Kenjirou:  I can't believe you!"
	DB	NEXT
	DB	"Tetsuya:  You're right, Kenjirou. I'm sorry. But it was fun, wasn't it?" 
	DB	NEXT
	DB	"Kenjirou:  So where did you get that platinum card from, anyway?"
	DB	NEXT
	DB	"Tetsuya:  I picked it up in front of the pub. Someone had dropped it."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  Well, I was going there every day. I guess God took pity on me and sent it to me as a gift."
	DB	NEXT
	DB	"Kenjirou:  I see. I don't think it was God, though."
	DB	NEXT
	DB	"Tetsuya:  I'm sure it was. God, please let me go steady with Kashima-san..." 
	DB	NEXT
	DB	"He made praying gestures at the sky."
	DB	NEXT
	DB	"Kenjirou:  Anyway, I'm going home now."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"That Tetsuya, he's such a card..."
	DB	NEXT
	DB	"Running away without paying like that."
	DB	NEXT
	DB	"Oh well, let's go to sleep."
	DB	NEXT
	FLG_KI	RAYABA,'=',1
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_IF	ONANI,'>=',5,DEKINAI_1
	FLG_KI	ONANI,'=',0
DEKINAI_1:
	FLG_KI HIDUKE,'+',1
	SINARIO	'MON_47.OVL'
	DB	EXIT
END