        include SUPER_C.inc
M_START:
MON_43
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  Wow, it's noon already. Guess I'll go eat."
	DB	NEXT
	DB	"Trying to clear my head, I headed downstairs, still in my pajamas."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Ah, Kenjirou. You're finally up?"
	DB	NEXT
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Akemi:  You mean, good afternoon. It's already past noon." 
	DB	NEXT
	DB	"Kenjirou:  Hahaha... Sorry."
	DB	NEXT
	DB	"Akemi:  You should spend more time with your friends when you have several days off in a row like this, not just sleep around."
	DB	NEXT
	DB	"Kenjirou:  But I like to sleep."
	DB	NEXT
	DB	"Akemi:  Really? I feel sorry for your girlfriend."
	DB	NEXT
	DB	"Kenjirou:  My girlfriend?"
	DB	NEXT
	DB	"Akemi:  I heard about her from Motoka. I can't take my eyes off you for a second." 
	DB	NEXT
	DB	"She must be talking about Shiho. I knew that Motoka had misunderstood the situation."
	DB	NEXT
	DB	"Kenjirou:  Are you taking about the girl who came here last night?"
	DB	NEXT
	DB	"Akemi:  So, you admit it."
	DB	NEXT
	DB	"Kenjirou:  No, she's not my girlfriend. She's just a friend."
	DB	NEXT
	DB	"Akemi:  I wonder." 
	DB	NEXT
	DB	"Kenjirou:  I'm telling the truth!"
	DB	NEXT
	DB	"Akemi:  Well, I guess I could believe you this once."
	DB	NEXT
	DB	"Kenjirou:  .....Anyway, what's for lunch?"
	DB	NEXT
	DB	"Akemi:  Hang on, it'll be ready soon."
	DB	NEXT
	TATI_ERS
	DB	"Akemi-san starts making my lunch."
	DB	NEXT
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  I'm sorry for making something so simple as fried rice. I haven't been shopping today."
	DB	NEXT
	DB	"Kenjirou:  It's okay. Your fried rice is the best."
	DB	NEXT
	DB	"Akemi:  Fufu... You're such a good boy." 
	DB	NEXT
	DB	"Kenjirou:  Akemi-san, where's Motoka?"
	DB	NEXT
	DB	"Akemi:  Motoka?  She's out with her friends."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"Akemi:  Do you want to talk to her or something?"
	DB	NEXT
	DB	"Kenjirou:  No, it's nothing."
	DB	NEXT
	DB	"Akemi:  Fufu... You want to explain the truth about that other girl to her, don't you?" 
	DB	NEXT
	DB	"Kenjirou:  Yeah, well..."
	DB	NEXT
	FLG_IF	AKE_YARU,'=',1,YATTA
	DB	"Akemi:  I want to ask you something. What are your feelings towards Motoka?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Well, she's my sister. What else is there?"
	DB	NEXT
	DB	"Akemi:  You're not thinking of her as a woman."
	DB	NEXT
	DB	"Kenjirou:  Of course I'm not!"
	DB	NEXT
	DB	"Akemi:  Even if you have no feelings for her, the same can't be said of Motoka."
	DB	NEXT
	DB	"Kenjirou:  ................"
	DB	NEXT
	DB	"Akemi:  I'm sure you've figured that out on your own, by now."
	DB	NEXT
	DB	"Kenjirou:  .....Yes."
	DB	NEXT
	DB	"Akemi:  In that case, why not let her think that the girl who was here last night "
        DB      "is really your girlfriend? That's if you have no intention of thinking of her as a woman, that is."
	DB	NEXT
	GO	GOURYU
YATTA:
	DB	"Akemi:  Are you prepared to think of her as a woman?"
	DB	NEXT
	DB	"Kenjirou:  No... Not yet."
	DB	NEXT
	DB	"Akemi:  Eventually?"
	DB	NEXT
	DB	"Kenjirou:  ...I can't say for sure."
	DB	NEXT
	DB	"Akemi:  I see."
	DB	T_WAIT,	3
	DB	" Why don't you just see how things turn out? If you leave things the way they are for a while."
	DB	NEXT
GOURYU:
	DB	"Kenjirou:  That may be so."
	DB	T_WAIT,	3
	DB	" But I wouldn't want to cause problems at home. I wouldn't want to hurt her."
	DB	NEXT
	DB	"Akemi:  I'm sure that's as good an answer as any."
	DB	NEXT
	DB	"Suddenly, it was kind of hard for me to be in the room with Akemi-san, so I excused myself and went to my room."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"But Motoka is my sister..."
	DB	T_WAIT,	3
	DB	" But is that really all she is?"
	DB	NEXT
	DB	"There's nothing I can do about that, though. I guess I'll play some video games!"
	DB	NEXT
	DB	"I turn on the game console, and pick up a controller."
	DB	NEXT
	DB	"With nothing in my head at all, I began to play the games."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Akemi:  Kenjirou, dinner's ready!"
	DB	NEXT
	DB	"I turn around at Akemi-san's voice, surprised to see that it had grown dark outside."
	DB	NEXT
	DB	"Kenjirou:  Wow, now that's a good way to spend a day off..."
	DB	NEXT
	DB	"I head for the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi-san is here, but there's no sign of Motoka."
	DB	NEXT
	DB	"Kenjirou:  Where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She just came back, but she went to her room right away."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"After eating dinner with Akemi-san, I head for my own room."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"I wonder if I should go to Motoka's room..."
	DB	NEXT
	DB	"Hmm... I guess I shouldn't. Instead, I should try to brush this whole thing off."
	DB	NEXT
	DB	"Guess I'll get to sleep."
	DB	NEXT
	DB	"I turn off the light, and get into bed."
	DB	NEXT
	DB	"I wasn't really tired, but I fell asleep right away anyway."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF
	FLG_KI	ONANI,'=',0
DEF:
	BAK_INIT	'tb_001a',B_NORM
	DB	"Kenjirou:  *Yawn!*  I really slept well!"
	DB	NEXT
	DB	"Kenjirou:  Today's a holiday, so I don't have to go to school or anything.  "
        DB      "I can just stay home, and have fun inside my own little world."
	DB	NEXT
	DB	"I turn on the game console, and pick up the controller."
	DB	NEXT
	DB	"I submerge myself in my gaming."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Akemi:  Kenjirou-kun, dinner's ready!"
	DB	NEXT
	DB	"I turn around at Akemi-san's voice, surprised to see darkness out the windows."
	DB	NEXT
	DB	"Kenjirou:  Now that's a way to spend a day off. I think I've got the hang of this game."
	DB	NEXT
	DB	"I head for the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	T_CG	'tt_20_02',AKE_A2,0
	CDPLAY	6
	DB	"Akemi-san's here, but Motoka is nowhere to be found."
	DB	NEXT
	DB	"Kenjirou:  Akemi-san, where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She came home a few minutes ago, but went to her room."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"I ate dinner with Akemi-san, then went to my room."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"I wonder if I should go to Motoka's room..."
	DB	NEXT
	DB	"Nah. I should just pretend like there's nothing going on, instead."
	DB	NEXT
	DB	"I'm tired of thinking of all of this. Tomorrow's a day off, so I think I'll play some more video games."
	DB	NEXT
	DB	"That night, I played games all night long."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	DB	"Kenjirou:  *Yawn*  I'm almost to the ending of this game..."
	DB	NEXT
	DB	"I'm surprised to see the sun coming through the windows."
	DB	NEXT
	DB	"Kenjirou:  Oh no! It's 5 in the morning! I should get some sleep."
	DB	NEXT
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	DB	"Kenjirou:  Guess it's time to get up..."
	DB	NEXT
	DB	"I somehow manage to get my body out of bed."
	DB	NEXT
	DB	"Kenjirou:  What? It's dark in here. What's up?"
	DB	NEXT
	DB	"I grope for the light switch, and turn on the light."
	DB	NEXT
	DB	"Kenjirou:  What? It's 7 pm!  Damn, my long vacation is over already, and I didn't get anything done at all!"
	DB	NEXT
	DB	"Oh well.  I've got school tomorrow, so I'd better get some more sleep."
	DB	NEXT
	DB	"And this was how I spent my long vacation..."
	DB	NEXT
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_44.OVL'
	DB	EXIT
END