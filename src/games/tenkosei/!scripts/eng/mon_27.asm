        include SUPER_C.inc
M_START:
MON_27
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
	BAK_INIT	'tb_018a',B_NORM
	CDPLAY	2
	DB	"Well, where should I search for Motoka...?"
	DB	NEXT
FF_1:
	BAK_INIT	'tb_018a',B_NORM
	CDPLAY	2
	FLG_KI	W,'=',-1
	FLG_IF	REN_ATTA,'=',1,BUNKI_A
	FLG_KI	W,'DOWN',5
BUNKI_A:
	FLG_IF	NAN_ATTA,'=',1,BUNKI_B
	FLG_KI	W,'DOWN',6
BUNKI_B:
	FLG_IF	TEMP02,'=',0,BUNKI_C
	FLG_KI	W,'DOWN',0
BUNKI_C:
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
	MENU_S	2,W,-1
	MENU_SET	AH1,"MOVIE THEATRE"
	MENU_SET	AH2,"LINGERIE PUB"
	MENU_SET	AH3,"PARK"
	MENU_SET	AH4,"LOVE HOTEL"
	MENU_SET	AH5,"BAR"
	MENU_SET	AH6,"COFFEE SHOP"
	MENU_SET	AH7,"RESTAURANT"
	MENU_END
	DB	EXIT
AH1:
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB	"The movie theater? She might be there. It might be worth a look."
	DB	NEXT
	BAK_INIT	'tb_019',B_NORM
	DB	"This place is so run down. I don't see Motoka here at all..."
	DB	NEXT
	DB	"Guess I'll go back."
	DB	NEXT
	GO	FF_1
AH2:
	FLG_KI	TEMP03,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"I'm sure she would never go in a place like that."
	DB	NEXT
	GO	FF_1
AH3:
	DB	"The park? It's possible."
	DB	NEXT
	FLG_KI	TEMP04,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	BAK_INIT	'tb_031a',B_NORM
	CDPLAY	8
	DB	"Hmm, I can't stand out here like an idiot. "
	DB	NEXT
	DB	"Let's go in and see if Motoka's there."
	DB	NEXT
	BAK_INIT	'tb_032a',B_NORM
	DB	"There are couples here, clawing at each other, not concerned in the least about the eyes of others around them."
	DB	NEXT
	DB	"Kenjirou:  Now where could Motoka be?"
	DB	T_WAIT,	3
	DB	" ...Not here."
	DB	NEXT
	DB	"Guess I'll head back."
	DB	NEXT
	GO	FF_1
AH4:
	FLG_KI	TEMP05,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"Tetsuya said that Motoka was with some other girls. I'm sure Motoka didn't go with other girls into a love hotel."
	DB	NEXT
	DB	"...Wait a minute. Hiroshi said he was looking for her, too. I wonder if he's in the love hotel with her?"
	DB	NEXT
	DB	"...Nah, she's not that stupid. I'll look somewhere else."
	DB	NEXT
	GO	FF_1
AH5:
	FLG_KI	TEMP06,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"It's not open. It's too early."
	DB	NEXT
	GO	FF_1
AH6:
	FLG_KI	TEMP07,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"I was just there. If Motoka shows up there, Rena will call me on my phone."
	DB	NEXT
	DB	"Let's look somewhere else."
	DB	NEXT
	GO	FF_1
AH7:
	FLG_KI	TEMP08,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"Hmm, it's not likely. Motoka doesn't like junk food, and never goes to that place."
	DB	NEXT
	GO	FF_1
MATI02:
	BAK_INIT	'tb_018a',B_NORM
	DB	"I've thought about this a long time, and I just can't guess where Motoka might be. "
	DB	NEXT
	DB	"I look around, and spy some tough-looking guys, standing nearby."
	DB	NEXT
	DB	"They say that birds of a feather flock together. Maybe these guys know something that can help me find Motoka?"
	DB	NEXT
	DB	"Okay, let's go ask!"
	DB	NEXT
	DB	NEXT
	DB	"I'm...kind of scared to come right and ask them. Maybe I'll stand here a while, and listen to their conversation."
	DB	NEXT
	DB	"Punk 1:  Hey, who's that, over there?"
	DB	NEXT
	DB	"One of the punks had noticed me. He gestured to his friends."
	DB	NEXT
	DB	"Punk 2:  Who knows?"
	DB	NEXT
	DB	"Punk 3:  Just some asshole."
	DB	NEXT
	DB	"Asshole...?"
	DB	T_WAIT,	3
	DB	" Well, pay it no mind."
	DB	NEXT
	DB	"Punk 1:  Well, where shall we start?"
	DB	NEXT
	DB	"Punk 2:  Yes, where?"
	DB	NEXT
	DB	"The jerks slowly start to stand up."
	DB	NEXT
	DB	"Punk 1:  Who are you looking at?!"
	DB	NEXT
	DB	"The leader reared up, and stared right at me."
	DB	NEXT
	DB	"Kenjirou:  Uuu..."
	DB	NEXT
	DB	"His face was so ugly, I could feel my body quivering."
	DB	NEXT
	DB	"Punk 3:  Stop staring at us!!"
	DB	NEXT
	DB	"I couldn't believe how ugly the three of them were. My quaking increased."
	DB	NEXT
	;WAV	'Se_at1'
	DB	"Kenjirou:  Uuu..."
	DB	T_WAIT,	3
	DB	" (But I can't run away! I've got to find out something that will let me help Motoka!)"
	DB	NEXT
	DB	"They slowly pushed me towards the alley, and one of them swung at me."
	DB	NEXT
	DB	"I felt a fierce crashing on my cheek."
	DB	NEXT
	EVENT_CG	'ti_108',B_NORM,82
	;WAV	'Se_at1'
	DB	GATA,	1
	DB	"The punk's fist sunk deep into the pit of my stomach."
	DB	NEXT
	DB	"I doubled over in pain, as if I was a turtle."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	;WAV	'Se_at1'
	DB	GATA,	1
	;WAV	'Se_at2'
	DB	GATA,	2
	DB	"Another massive force runs across my back, causing an instant jar of pain. "
	DB	NEXT
	DB	"Kenjirou:  Uuuu..."
	DB	NEXT
	;WAV	'Se_at1'
	DB	GATA,	1
	;WAV	'Se_at2'
	DB	GATA,	2
	;WAV	'Se_at2'
	DB	"Suddenly I hear a massively loud "
	DB	NEXT
	DB	"...Huh? I- It doesn't hurt..."
	DB	NEXT
	DB	"I slowly open my eyes, to see thin, feminine fingers clasping my own hand, pulling me out of there."
	DB	NEXT
	BAK_INIT	'tb_018b',B_NORM
	CDPLAY	3
	T_CG	'tt_05_18b',TER2,0
	DB	"Terumi:  Kenjirou, are you okay?" 
	DB	NEXT
	DB	"Then I understood. Terumi-senpai had appeared at the last minute and saved me."
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai..."
	DB	NEXT
	DB	"Terumi:  Oh, the trouble you manage to get yourself into..." 
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai, where are those punks?"
	DB	NEXT
	DB	"Terumi:  Who knows?" 
	DB	T_WAIT,	3
	DB	" They're probably sleeping like babies right now."
	DB	NEXT
	DB	"Kenjirou:  ...I see."
	DB	NEXT
	DB	"Terumi:  You should have done better against them then you did." 
	DB	T_WAIT,	3
	DB	" You've cut your mouth. Come here a second."
	DB	NEXT
	DB	"She pulled my arm again, and started to walk."
	DB	NEXT
	DB	"Kenjirou:  W- Wait, Terumi-senpai, it's too embarrassing..."
	DB	NEXT
	BAK_INIT	'tb_032b',B_NORM
	DB	"The sun had set, and night was upon us as we walked."
	DB	NEXT
	T_CG	'tt_05_32b',TER2,0
	DB	"Terumi:  Okay, wait here. "
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  T- Terumi-senpai..."
	DB	T_WAIT,	3
	DB	" Damn it, doesn't she know how to listen to a person?"
	DB	NEXT
	DB	"A few minutes later, she returned, panting."
	DB	NEXT
	T_CG	'tt_05_32b',TER2,0
	DB	"Terumi:  I'm back." 
	DB	NEXT
	DB	"In her hand was a set handkerchief."
	DB	NEXT
	DB	"Terumi:  Come here, I'll wipe the blood."
	DB	NEXT
	DB	"She approached and started wiping the place where I'd been cut."
	DB	NEXT
	DB	"Kenjirou:  H- Hey, stop it!"
	DB	NEXT
	DB	"Terumi:  Be quiet, or I can't do this right." 
	DB	NEXT
	DB	"She went back to work, wiping away the blood from my cut."
	DB	NEXT
	DB	"Kenjirou:  That hurts!"
	DB	NEXT
	DB	"Terumi:  You're a man, so you have to endure a little pain." 
	DB	NEXT
	DB	"When she was done, she handed me the wet handkerchief."
	DB	NEXT
	DB	"Terumi:  Hold this on your cut for a while, and the bleeding will stop. "
	DB	NEXT
	DB	"I did as I was told, too embarrassed to say anything."
	DB	NEXT
	DB	"Terumi:  How did you get into a mess like that, anyway? It's not like you."
	DB	NEXT
	DB	"Kenjirou:  ...There's a reason."
	DB	NEXT
	DB	"Terumi:  A reason? What kind of reason?"
	DB	NEXT
	DB	"Kenjirou:  Do you remember me talking about Motoka this morning?"
	DB	NEXT
	DB	"Terumi:  Did you say anything this morning? I don't remember."
	DB	NEXT
	DB	"That's because she was too busy teasing me to listen."
	DB	NEXT
	DB	"Kenjirou:  Well anyway, it's nothing for you to worry about."
	DB	NEXT
	DB	"Terumi:  It doesn't look like that from where I stand. " 
	DB	NEXT
	DB	"Kenjirou:  ...The truth is, Motoka has been running with some scary people lately, according to what I've heard."
	DB	NEXT
	DB	"Terumi:  Who did you hear it from?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Well, from Tetsuya."
	DB	NEXT
	DB	"Terumi:  Oh, the rumor man himself?" 
	DB	NEXT
	DB	"Kenjirou:  Anyway, Tetsuya said he saw Motoka out late with some punks. And lately, "
        DB      "she's been coming home later and later. So I was out looking for her..."
	DB	NEXT
	DB	"Terumi:  That's all? You're looking for her because she came home late?" 
	DB	NEXT
	DB	"Kenjirou:  Well, yes."
	DB	NEXT
	DB	"Terumi:  ...Go on."
	DB	NEXT
	DB	"Kenjirou:  I've thought this over, and I don't think I'm overreacting."
	DB	NEXT
	DB	"Terumi:  Oh?" 
	DB	NEXT
	DB	"Kenjirou:  Yes. If it was just that she was coming home late, I wouldn't be out here looking for her."
	DB	NEXT
	DB	"In the past, if she was going to be out late, she would have called to let "
        DB      "us know she was okay, but she hasn't done that at all."
	DB	NEXT
	DB	"Terumi:  Maybe she has a boyfriend." 
	DB	NEXT
	DB	"She winked at me, knowing the comment would fluster me."
	DB	NEXT
	DB	"Kenjirou:  If she has a boyfriend, that's fine with me..."
	DB	NEXT
	DB	"Actually, it isn't really fine. But I can't tell that to Terumi-senpai..."
	DB	NEXT
	DB	"Kenjirou:  Another thing is that Hiroshi is going for Motoka. He wants to add her to his collection of women."
	DB	NEXT
	DB	"Terumi:  ...Hiroshi? Is that Hiroshi Hara, from your class?" 
	DB	NEXT
	DB	"Kenjirou:  Yes, that's the one."
	DB	NEXT
	DB	"Terumi:  Well, he's one to stay away from. There are plenty of women in our school alone who've been hurt by him." 
	DB	NEXT
	DB	"Kenjirou:  If you see Motoka, please contact me. I've got to keep on looking."
	DB	NEXT
	DB	"I left Terumi-senpai standing there, and departed into the night."
	DB	NEXT
	;WAV	'Se_at1'
	DB	"Kenjirou:  Owowowow..."
	DB	NEXT
	DB	"I felt a sudden sharp pain in my back."
	DB	NEXT
	DB	"Terumi:  I think you should go home and get some rest."
	DB	NEXT
	DB	"Kenjirou:  But I..."
	DB	NEXT
	DB	"Terumi:  You go home. I'll look for Motoka for you." 
	DB	T_WAIT,	3
	DB	" Or are you worried that I won't do a good job?"
	DB	NEXT
	DB	"Kenjirou:  That's not it, but..."
	DB	NEXT
	DB	"Terumi:  Besides, she's hanging out with some bad people, right? I think I should be the one "
        DB      "to find her, since you'll just get beat up again." 
	DB	NEXT
	DB	"Kenjirou:  ...If you find her, just tell me where she is. I don't want to cause any inconvenience to you."
	DB	NEXT
	;WAV	'Se_at1'
	DB	GATA,	1
	DB	"Kenjirou:  Uuu!!"
	DB	NEXT
	DB	"She slapped me on the back in a gesture that said, go home and rest. It hurt."
	DB	NEXT
	DB	"Terumi:  Go on home. I'll find her for you." 
	DB	NEXT
	DB	"Kenjirou:  I'm sorry to inconvenience you. "
	DB	T_WAIT,	3
	DB	"Okay, let me know if you find her."
	DB	NEXT
	DB	"Terumi:  I'll call you on your cell-phone when I find her."
	DB	NEXT
	DB	"Kenjirou:  ...Okay, thanks."
	DB	NEXT
	SINARIO	'MON_28.OVL'
	DB	EXIT
END