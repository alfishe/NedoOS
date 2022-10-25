        include SUPER_C.inc
M_START:
MON_45
	FLG_IF JUMP,'=',93,FF_2
	FLG_IF JUMP,'=',92,FF_1
	FLG_KI JUMP,'=',92
	SINARIO	'NITI_ASA.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI	MOTDOYOU,'=',1
	FLG_KI JUMP,'=',93
	SINARIO	'NITI_HOK.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	FLG_KI	MOTDOYOU,'=',0
	BAK_INIT	'tb_018a',B_NORM
	CDPLAY	2
	DB	"Motoka's not here. That must mean she's at home. I should go there, too."
	DB	NEXT
	BAK_INIT	'tb_005a',B_NORM
	DB	"I'm sure she's here."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	DB	"Kenjirou:  I'm home."
	DB	NEXT
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Oh, you're early."
	DB	NEXT
	DB	"Kenjirou:  Is Motoka here?"
	DB	NEXT
	DB	"Akemi:  She was here, but she went out right away again."
	DB	NEXT
	DB	"We missed each other. That troubles me. I wanted to talk with her."
	DB	NEXT
	DB	"I head for my room."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Dazed, I just lie on my bed in silence. My eyes slowly close, and I sleep."
	DB	NEXT
	F_O	B_FADE,C_KURO
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"When I open them again, it's dark outside."
	DB	NEXT
	DB	"Kenjirou:  Wow, it's late. I wonder what time it is?"
	DB	NEXT
	DB	"Then I remembered Motoka. Was she home by now?"
	DB	NEXT
	DB	"I got out of bed, and headed for the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Hi, do you want dinner?"
	DB	NEXT
	DB	"Kenjirou:  Where's Motoka?"
	DB	NEXT
	DB	"Kenjirou:  She's not back yet."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"Akemi:  I'll put dinner on now."
	DB	NEXT
	DB	"Akemi-san started making dinner."
	DB	NEXT
	TATI_ERS
	DB	"Just then, the phone rang."
	DB	NEXT
	DB	"Kenjirou:  I'll get it."
	DB	NEXT
	DB	"I pick up the phone."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Kenjirou:  Hi, Kondo residence."
	DB	NEXT
	DB	"Voice:  O- Oniichan...?"
	DB	NEXT
	DB	"Kenjirou:  Motoka? Where are you? Dinner's almost ready."
	DB	NEXT
	DB	"Motoka:  Please tell mother that I don't need dinner tonight." 
	DB	NEXT
	DB	"Kenjirou:  Hey, Akemi-san's making your dinner, too..."
	DB	NEXT
	DB	"Motoka:  .....I said I don't need dinner." 
	DB	NEXT
	DB	"Voice:  Hey, Motoka, hurry up!"
	DB	NEXT
	DB	"Motoka:  Yes, wait. I'm almost finished." 
	DB	NEXT
	DB	"Kenjirou:  Motoka! That voice -- it's Hara, isn't it?"
	DB	NEXT
	DB	"Motoka:  It has nothing to do with you, doesn't it?" 
	DB	NEXT
	DB	"Kenjirou:  Come home right away."
	DB	NEXT
	DB	"Motoka:  I'm not a child anymore. Don't worry about me." 
	DB	NEXT
	DB	"Kenjirou:  Hey! What do you mean by that?"
	DB	NEXT
	DB	"Without replying to my words, she hangs up the phone."
	DB	NEXT
	DB	"I can't believe she's with Hiroshi."
	DB	NEXT
	DB	"Damn! I guess I'd better go find her..."
	DB	NEXT
	DB	"I head back to the dining kitchen, and explain things to Akemi-san, then leave the house."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_018c',B_NORM
	CDPLAY	22
	DB	"Rats. I can't find her anywhere."
	DB	T_WAIT,	3
	DB	" Mm? Wait a minute. What's that?"
	DB	NEXT
	T_CG	'tt_15_18c',RIS2,0
	DB	"It's Risa. She might know where Hiroshi would be. I'll talk to her."
	DB	NEXT
	DB	"Kenjirou:  Tachikawa-san."
	DB	NEXT
	FLG_IF	RISA_SYO,'=',1,KIKU
	DB	"Risa:  What do you want?"
	DB	NEXT
	DB	"Kenjirou:  I want to ask you something."
	DB	NEXT
	DB	"Risa:  I don't want to talk to you."
	DB	NEXT
	DB	"I guess I don't have a choice but to remind her..."
	DB	NEXT
	DB	"Kenjirou:  Tachikawa-san, are you sure you're in a position to take that tone with me?"
	DB	NEXT
	DB	"Risa:  What are you saying? Don't be stupid."
	DB	NEXT
	DB	"Kenjirou:  I've got a video with you in it."
	DB	NEXT
	DB	"Risa's face goes completely white."
	DB	NEXT
	DB	"Risa:  T- There are a lot of people who spread rumors about me. I wouldn't believe them if I were you."
	DB	NEXT
	DB	"Kenjirou:  In the video, you're being held down by a girl named Rie, and getting creamed pretty good."
	DB	NEXT
	DB	"Risa:  ................." 
	DB	NEXT
	DB	"Kenjirou:  Do you want me to give it to you in more detail?"
	DB	NEXT
	DB	"Risa:  ...Damn you." 
	DB	T_WAIT,	3
	DB	" But never mind. What is it you want me to do?"
	DB	NEXT
	DB	"Kenjirou:  Nothing. I just want you to answer a question for me."
	DB	NEXT
	DB	"Risa:  I see. Well, go ahead and ask it." 
	DB	NEXT
	DB	"Kenjirou:  Do you know where Hiroshi is?"
	DB	NEXT
	DB	"Risa:  ...Yes."
	DB	NEXT
	DB	"I'm not sure why, but her bottom lip is trembling for some reason."
	DB	NEXT
	DB	"Risa:  I- I know where he is. He took your sister to the bar." 
	DB	NEXT
	DB	"Kenjirou:  Really? Thanks."
	DB	NEXT
	DB	"I leave her and head for the bar."
	DB	NEXT
	GO	TASUKENI
KIKU:
	DB	"Risa:  Ah..."
	DB	NEXT
	DB	"Risa sees me, and her face takes on a defensive air."
	DB	NEXT
	DB	"Kenjirou:  I want to ask you a question."
	DB	NEXT
	DB	"Risa:  .............." 
	DB	NEXT
	DB	"Kenjirou:  Are you listening to me?"
	DB	NEXT
	DB	NEXT
	DB	"She wears a slight sneer as she says it."
	DB	NEXT
	DB	"Kenjirou:  Do you know where Hiroshi is?"
	DB	NEXT
	DB	"I'm not sure why, but her lower lip is trembling for some reason."
	DB	NEXT
	DB	"Risa:  I- I know. He took your sister to the bar." 
	DB	NEXT
	DB	"Suddenly, I see a tear well up on her eye, and begin to slide down her cheek."
	DB	NEXT
	DB	"Kenjirou:  Risa?"
	DB	NEXT
	DB	"Risa:  If only... If only you and your sister weren't around..." 
	DB	NEXT
	DB	"Kenjirou:  ................."
	DB	NEXT
	DB	"With no time to digest what she said, I leave her and head for the bar. "
        DB      "I'm not sure what happened to her, but I knew I had to find Motoka."
	DB	NEXT
TASUKENI:
	B_O	B_FADE,C_KURO
	CDPLAY		0
	BAK_INIT	'tb_029',B_NORM
	DB	"Kenjirou:  So this is where she is..."
	DB	NEXT
	DB	"I've stood in front of this place before, but this is the first time I've gone in."
	DB	NEXT
	DB	"I open the door and take a step inside."
	DB	NEXT
	BAK_INIT	'tb_030',B_NORM
	CDPLAY	25
	DB	"The atmosphere of the place almost knocks me down."
	DB	NEXT
	DB	"There's a long counter here."
	DB	NEXT
	DB	"Woman's voice:  Hara-senpai, what about Tachikawa-senpai...?"
	DB	NEXT
	DB	"Man's voice:  Don't worry, she's just some girl I know. She means nothing to me."
	DB	NEXT
	DB	"Woman's voice:  Yes, but..."
	DB	NEXT
	DB	"Man's voice:  You're the one I really love."
	DB	NEXT
	DB	"From inside the bar, I can hear the couple's voices. And I know instantly who they belong to."
	DB	NEXT
	DB	"I walk openly into the room now."
	DB	NEXT
	EVENT_CG	'th_105',B_NORM,50
	DB	"Motoka:  O- Oniichan..." 
	DB	NEXT
	DB	"Hiroshi:  Kondo, what are you doing here?" 
	DB	NEXT
	DB	"Kenjirou:  Motoka! What are you doing in a dirty place like this?"
	DB	NEXT
	DB	"Motoka:  .................." 
	DB	NEXT
	DB	"Hiroshi:  Us? What about you?" 
	DB	NEXT
	DB	"Kenjirou:  I'm here to take Motoka home."
	DB	NEXT
	DB	"Hiroshi:  Hey, get off our case. We're going out, that's all, "
        DB      "and we're here enjoying each other's company. Isn't that right, Motoka?" 
	DB	NEXT
	DB	"Hiroshi hugs Motoka close to her."
	DB	NEXT
	DB	"Kenjirou:  Motoka, do you really love this guy?"
	DB	NEXT
	DB	"Motoka:  ................" 
	DB	NEXT
	DB	"Motoka looked right into my eyes, and slowly nodded once."
	DB	NEXT
	DB	"Hiroshi:  You see? So that's the situation."
	DB	NEXT
	DB	"With that, he started to reach out to squeeze her breast."
	DB	NEXT
	EVENT_CG	'th_106',B_NORM,51
	DB	"Motoka allowed him to touch her breasts, but when he moved a hand to her crotch, she pushed his hand away."
	DB	NEXT
	DB	"Motoka:  No..." 
	DB	NEXT
	DB	"Hiroshi:  Anyway, that's the situation. So I guess you'll be leaving, then?" 
	DB	NEXT
	DB	"Kenjirou:  Motoka..."
	DB	NEXT
	DB	"Hiroshi continued to massage her breasts through her bra."
	DB	NEXT
	DB	"Motoka let her guard down for a moment, and Hiroshi's hand flashed to her crotch again, finding her warm slit this time."
	DB	NEXT
	DB	"Motoka:  Oniichan, s- save me..." 
	DB	NEXT
	DB	"The moment I heard her words, I moved towards Hiroshi and hit him as hard as I could."
	DB	NEXT
	;WAV	'Se_at1'
	DB	GATA,	1
	F_O	B_NORM,C_KURO
	DB	"Motoka:  Oniichan!" 
	DB	NEXT
	DB	"She ran to me, and I caught her, folding my arms around her for protection."
	DB	NEXT
	DB	"Kenjirou:  Let's go, Motoka."
	DB	NEXT
	DB	"Motoka:  O- Okay..."
	DB	NEXT
	DB	"Motoka turned to Hiroshi, who was holding his cheek."
	DB	NEXT
	DB	"Motoka:  Hara-senpai, please take care of Tachikawa-senpai..." 
	DB	NEXT
	DB	"Hiroshi:  Hmmm..."
	DB	T_WAIT,	3
	DB	" Yeah, I guess." 
	DB	NEXT
	DB	"With Motoka at my side, we leave the bar together."
	DB	NEXT
	BAK_INIT	'tb_029',B_NORM
	CDPLAY	19
	T_CG	'tt_11_29',MOT_B2,0
	DB	"Motoka:  O- Oniichan... Why did you come for me?"
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	T_WAIT,	3
	DB	" Well, because I was worried about you."
	DB	NEXT
	DB	"Motoka:  ...Why were you worried?" 
	DB	T_WAIT,	3
	DB	" I, I want to know the reason..."
	DB	NEXT
	DB	"Kenjirou:  Well..."
	DB	NEXT
	DB	"Words failed me. I knew exactly what Motoka wanted to hear from me."
	DB	NEXT
	DB	"I was her brother, at least on paper. We weren't related by blood, but to me, she was really a younger sister."
	DB	NEXT
	DB	"It was a difficult situation for me."
	DB	NEXT
	DB	"Motoka:  I, I have to tell you..." 
	DB	T_WAIT,	3
	DB	"that I've... I've felt a certain way..."
	DB	NEXT
	FLG_KI	GOGATU_6,'=',0
	FLG_IF	TER_YATT,'=',1,SISISI
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	SINAI,"CONSOLE HER"
	MENU_SET	YARU,"HOLD HER"
	MENU_END
	DB	EXIT
SINAI:
SISISI:
	DB	"Kenjirou:  Motoka, let's go home. Akemi-san is waiting for us."
	DB	NEXT
	DB	"Motoka:  .....Okay." 
	DB	NEXT
	DB	"Motoka looked a little sad."
	DB	NEXT
	DB	"Kenjirou:  That's my answer."
	DB	NEXT
	DB	"Motoka:  Eh?" 
	DB	NEXT
	DB	"Kenjirou:  You asked me why I was worried about you."
	DB	NEXT
	DB	"Motoka:  I see."
	DB	NEXT
	DB	"Kenjirou:  You're my sister, who I love very much. You're the only sister I've ever had, and you're very important to me."
	DB	NEXT
	DB	"Motoka:  ...Very important...?" 
	DB	NEXT
	DB	"Kenjirou:  Yes. You're my sister, and you're the only woman in the world who can be that to me."
	DB	NEXT
	CDPLAY	9
	DB	"Motoka:  ............" 
	DB	T_WAIT,	3
	DB	"Okay! I'll be your sister, if you'll keep on being my brother."
	DB	NEXT
	DB	"Kenjirou:  Okay."
	DB	NEXT
	DB	"She took my arm and we started walking."
	DB	NEXT
	DB	"Kenjirou:  H- Hey..."
	DB	NEXT
	DB	"Motoka:  Let's hurry home." 
	DB	NEXT
	DB	"We headed for home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"Whew, I'm tired..."
	DB	NEXT
	DB	"Kenjirou:  Well, I made up with Motoka, so that was good."
	DB	NEXT
	DB	"I sleep, just a little more soundly than usual."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_KI	MOTSUNE,'=',0
	SINARIO	'MON_46.OVL'
	DB	EXIT
YARU:
	FLG_KI	MOTSUNE,'=',0
	FLG_KI	MOT_KOKU,'=',1
	SINARIO	'BUNKI_4.OVL'
	DB	EXIT
END