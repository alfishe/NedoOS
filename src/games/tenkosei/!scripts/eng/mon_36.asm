        include SUPER_C.inc
M_START:
MON_36
	FLG_IF	JUMP,'=',69,FF_2
	FLG_IF	JUMP,'=',68,FF_1
	FLG_KI	JUMP,'=',68
	SINARIO	'NITI_ASA.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI	JUMP,'=',69
	SINARIO	'NITI_HIR.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	F_O	B_NORM,C_KURO
	CDPLAY	14
	DB	"Voice:  Hey! Hey, wake up!"
	DB	NEXT
	DB	"Kenjirou:  ...Mm?"
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	DB	"Tetsuya:  You're finally awake." 
	DB	NEXT
	DB	"I open my eyes to see Tetsuya standing in front of me."
	DB	NEXT
	T_CG	'tt_08_11a',TET_A2,0
	DB	"Tetsuya:  Hey, wake up."
	DB	NEXT
	DB	"Kenjirou:  Don't be cruel. Let me sleep."
	DB	NEXT
	DB	"Tetsuya:  It's time to get up. Now!" 
	DB	NEXT
	DB	"Kenjirou:  I'm up, I'm up."
	DB	T_WAIT,	3
	DB	" What do you want, anyway?"
	DB	NEXT
	DB	"Tetsuya:  Eh?"
	DB	T_WAIT,	3
	DB	" You can tell want something?"
	DB	NEXT
	DB	"Kenjirou:  You must, because you're still here."
	DB	NEXT
	DB	"Tetsuya:  Well, now that you mention it..." 
	DB	NEXT
	DB	"Kenjirou:  That tone worries me. You're not going to say that Motoka was doing something bad again, are you?"
	DB	NEXT
	DB	"Tetsuya:  No, this has nothing do with Motoka-chan."
	DB	NEXT
	DB	"Kenjirou:  I'm not so sure about that."
	DB	NEXT
	DB	"Kenjirou:  Does it have something to do with me?"
	DB	NEXT
	DB	"Tetsuya:  Sort of... Yes and no." 
	DB	NEXT
	DB	"Kenjirou:  Which is it?!"
	DB	NEXT
	DB	"Tetsuya:  Anyway, listen to me."
	DB	NEXT
	DB	"Kenjirou:  I'm listening."
	DB	NEXT
	DB	"Tetsuya:  I got my hands on Tachikawa's video." 
	DB	NEXT
	DB	"Kenjirou:  Wow! You found a copy?"
	DB	T_WAIT,	3
	DB	" And? Is it really her?"
	DB	NEXT
	DB	"Tetsuya:  Yes, the real McCoy." 
	DB	T_WAIT,	3
	DB	" It's got a mosaic on it, of course."
	DB	NEXT
	DB	"Kenjirou:  What else are you not telling me?"
	DB	T_WAIT,	3
	DB	" You watched the tape too much, and it broke? You dropped it in the mud on your way to school?"
	DB	NEXT
	DB	"Tetsuya:  Of course not! Would someone with such an excellent video collection as me do something like that?" 
	DB	NEXT
	DB	"Kenjirou:  Well..."
	DB	T_WAIT,	3
	DB	" But what do you want from me?"
	DB	NEXT
	DB	"Tetsuya:  Well..."
	DB	NEXT
	DB	"Kenjirou:  Go ahead and spit it out."
	DB	NEXT
	DB	"Tetsuya:  Okay, don't tell anyone, now." 
	DB	NEXT
	DB	"Kenjirou:  ...I'm waiting..."
	DB	NEXT
	DB	"I could feel my face getting red as my anger grew."
	DB	NEXT
	DB	"Tetsuya:  Well, the guy with her in the video..."
	DB	NEXT
	DB	"Kenjirou:  Yes? Who is it?"
	DB	NEXT
	DB	"Tetsuya:  Well, it's..."
	DB	NEXT
	DB	"Kenjirou:  It's not Motoka, right?"
	DB	NEXT
	DB	"Tetsuya:  No, not Motoka-chan."
	DB	NEXT
	DB	"Kenjirou:  Then who is it?"
	DB	NEXT
	DB	"Tetsuya:  Well..."
	DB	T_WAIT,	3
	DB	" You promise you won't tell anyone?"
	DB	NEXT
	DB	"Kenjirou:  Are you having fun, torturing me like this?"
	DB	NEXT
	DB	"Tetsuya:  Well... You know, I really..."
	DB	T_WAIT,	3
	DB	" I really like Kashima-san, and..."
	DB	NEXT
	DB	"Kenjirou:  What? What has this got to do with Shiho?"
	DB	NEXT
	DB	"Tetsuya:  Don't make me say any more. You know the rest, right?"
	DB	NEXT
	DB	"Kenjirou:  I know how you feel about her. And? What is the problem, and what does it have to do with me?"
	DB	NEXT
	DB	"Tetsuya:  My love problems have a lot to do with you, since you're my friend. Right?"
	DB	NEXT
	DB	"Kenjirou:  I wouldn't say that. I don't care who you're in love with, as long as it's not my little sister."
	DB	NEXT
	DB	"Tetsuya:  You're a cold one..."
	DB	T_WAIT,	3
	DB	" So are you saying that there's nothing between you and Kashima-san?"
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  You know. I see you two together sometimes." 
	DB	NEXT
	DB	"Kenjirou:  Sure, we meet at the station sometimes, and come to school together."
	DB	NEXT
	DB	"Tetsuya:  Really? But you call her by her first name. That tells me there's something more...?" 
	DB	NEXT
	DB	"Kenjirou:  That doesn't mean anything."
	DB	NEXT
	DB	"Tetsuya:  And she calls you Kenjirou-kun." 
	DB	NEXT
	DB	"Kenjirou:  So? Terumi-senpai calls me the same thing. It doesn't mean anything."
	DB	NEXT
	DB	"Tetsuya:  So there's nothing between you and Kashima-san?" 
	DB	NEXT
	DB	"Kenjirou:  Well, I wouldn't say nothing."
	DB	NEXT
	DB	"Tetsuya:  Which is it?"
	DB	NEXT
	DB	"Kenjirou:  Well, we're friends. I said this before, remember?"
	DB	NEXT
	DB	"Tetsuya:  Okay. If that's all it is."
	DB	NEXT
	DB	"Kenjirou:  Not to change the subject, but I want you to lend that video to me."
	DB	NEXT
	DB	"Tetsuya:  Ah..."
	DB	T_WAIT,	3
	DB	" I have one condition."
	DB	NEXT
	DB	"Kenjirou:  Condition?"
	DB	T_WAIT,	3
	DB	" You want me to give Shiho a letter from you? Or confess your love for her in your place?"
	DB	NEXT
	DB	"Tetsuya:  Y- You'd do that for me?"
	DB	NEXT
	DB	"Kenjirou:  Hell, no!"
	DB	NEXT
	DB	"Tetsuya:  I thought so."
	DB	T_WAIT,	3
	DB	" No, I didn't expect something like that."
	DB	NEXT
	DB	"Kenjirou:  So, what is your condition?"
	DB	NEXT
	DB	"Tetsuya:  I want to know more about her. I want information."
	DB	NEXT
	DB	"Kenjirou:  Information? I'm sure you'd be better at finding out about her than me."
	DB	NEXT
	DB	"Tetsuya:  Well, yes..."
	DB	T_WAIT,	3
	DB	" But for some reason, I can't find out anything about her. There's no information on file. So I thought I'd ask for your help."
	DB	NEXT
	DB	"Kenjirou:  What kind of information do you want to find?"
	DB	NEXT
	DB	"Tetsuya:  Anything you know."
	DB	NEXT
	DB	"Kenjirou:  ...Well, I have to warn you, I don't know what much about her."
	DB	NEXT
	DB	"Tetsuya:  I don't care. Tell me anything you can about her. I'll give you Tachikawa's video in return." 
	DB	NEXT
	DB	"Kenjirou:  It's a copy, right?"
	DB	NEXT
	DB	"Tetsuya:  Yes, but the picture is really good. Is it a deal?"
	DB	NEXT
	DB	"Kenjirou:  ...Okay. I don't know that much about her, though."
	DB	NEXT
	DB	"Tetsuya:  That's fine."
	DB	NEXT
	DB	"Kenjirou:  Okay."
	DB	T_WAIT,	3
	DB	" Let's see. First, she's really good at playing the piano."
	DB	NEXT
	DB	"Tetsuya:  Piano. Check."
	DB	NEXT
	DB	"Tetsuya takes a small notebook out of his pocket, and starts writing down what I say."
	DB	NEXT
	DB	"Kenjirou:  You didn't know that already?"
	DB	NEXT
	DB	"Tetsuya:  No, it's news to me. I didn't even know she played."
	DB	NEXT
	DB	"That's odd. She plays every day after school..."
	DB	NEXT
	DB	"Kenjirou:  She's also a songwriter, and her songs are really good."
	DB	NEXT
	DB	"Tetsuya:  Great. What else?"
	DB	NEXT
	DB	"Kenjirou:  Let's see..."
	DB	NEXT
	DB	"Tetsuya:  You have to tell me more!" 
	DB	NEXT
	DB	"Kenjirou:  Oh, I know. I saw her out of her uniform the other day, wearing regular clothes."
	DB	NEXT
	DB	"Tetsuya:  Really? Wow..."
	DB	NEXT
	DB	"Kenjirou:  It was nothing to get excited about."
	DB	NEXT
	DB	"Tetsuya:  I just don't know much about her, that's all."
	DB	NEXT
	DB	"Kenjirou:  God, you can be such a giddy little boy sometimes."
	DB	NEXT
	DB	"Tetsuya:  That's a little rude, isn't it?"
	DB	NEXT
	DB	"Kenjirou:  Sorry. Anyway, she was wearing a pink one-piece dress."
	DB	NEXT
	DB	"Tetsuya:  Oh! Kashima-san must have been cute!" 
	DB	NEXT
	DB	"Kenjirou:  Anyway, that's about all I know."
	DB	NEXT
	DB	"Tetsuya:  Thanks. You're a pal." 
	DB	NEXT
	DB	"Kenjirou:  Don't mention it."
	DB	NEXT
	DB	"Tetsuya:  Sure, I do."
	DB	T_WAIT,	3
	DB	" I wanted to know anything about her. Since I knew zero before, I'm much better off now."
	DB	NEXT
	DB	"Kenjirou:  Really?"
	DB	NEXT
	DB	"Tetsuya:  Here's the video I promised." 
	DB	NEXT
	DB	"He takes a video from his bag and hands it to me."
	DB	NEXT
	DB	"Tetsuya:  Well, I'm going home now. Don't jack off too much to this." 
	DB	NEXT
	TATI_ERS
	DB	"Tetsuya leave the classroom."
	DB	NEXT
	DB	"Kenjirou:  Guess I'll go home, too."
	DB	NEXT
	DB	"I head for home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_018b',B_NORM
	CDPLAY	2
	DB	"Tomorrow's a holiday, so there are a lot of people out today. "
	DB	NEXT
	DB	"Kenjirou:  Wow, too many people..."
	DB	T_WAIT,	3
	DB	" Guess I'll go home now. I've got Tachikawa's video to watch, too."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_005c',B_NORM
	DB	"Ahh, it's good to be home."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	DB	"Akemi-san and Motoka are here."
	DB	NEXT
	T_CG	'tt_11_02',MOT_C3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Motoka:  Oniichan, welcome home." 
	DB	NEXT
	DB	"Akemi:  Welcome home, Kenjirou-kun." 
	DB	NEXT
	DB	"Kenjirou:  Thanks."
	DB	NEXT
	FLG_KI	W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	H1,"LOOK AT COLLARBONE"
	MENU_SET	H2,"LOOK AT BREASTS"
	MENU_SET	H3,"LOOK AT STOCKINGS"
	MENU_END
	DB	EXIT
H1:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB	"Very sexy, and very strong. The collarbone of a sure woman."
	DB	NEXT
	GO	FUTU
H2:
	DB	"Her breasts. I'd sure love to slide my cock between them."
	DB	NEXT
	GO	FUTU
H3:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB	"I can see a patch of lace at the top of her stockings. It's just too sexy."
	DB	NEXT
	GO	FUTU
AKEM:
	FLG_KI	AKEM_NET,'=',1
	DB	"I- I'm going to explode!"
	DB	NEXT
FUTU:
	DB	"Motoka:  Ah, Oniichan, you're looking at my mother in a perverted way." 
	DB	NEXT
	DB	"Kenjirou:  I- I was not!"
	DB	NEXT
	DB	"She sure hit that on the head."
	DB	NEXT
	DB	"Akemi:  Motoka, stop teasing your brother." 
	DB	NEXT
	DB	"Kenjirou:  A- Anyway, what's for dinner?"
	DB	NEXT
	DB	"Akemi:  It'll be ready soon."
	DB	NEXT
	DB	"Motoka:  Ah, Oniichan, you changed the subject." 
	DB	NEXT
	DB	"Kenjirou:  I didn't."
	DB	NEXT
	DB	"Motoka:  Pervert! Oniichan's a pervert!" 
	DB	NEXT
	DB	"That was how the three of us passed our dinner that evening."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM	
	DB	"I took a bath. Guess it's time to watch Tachikawa's video."
	DB	NEXT
	GO	VIDEO
	DB	EXIT
HEYA:
	CDPLAY		0
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI	YOKU,'/',2
	F_O	B_NORM,C_KURO
	DB	"Kenjirou:  Uuunnn...??"
	DB	NEXT
	DB	"I slowly open my eyes."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  Where am I?"
	DB	NEXT
	DB	"I look around me. I'm in my room."
	DB	NEXT
	DB	"Huh? What happened?"
	DB	NEXT
	DB	"I look at my clothes, and see a brown stain."
	DB	NEXT
	DB	"Dried blood? Oh, that's right. I had a nosebleed."
	DB	NEXT
	DB	"What happened after that?"
	DB	NEXT
	DB	"I must have lost consciousness."
	DB	NEXT
	DB	"But how did I get back here? Someone must have carried me."
	DB	NEXT
	DB	"But who?"
	DB	NEXT
	DB	"Oh well. Guess I'll watch Tetsuya's video."
	DB	NEXT
	GO	VIDEO
	DB	EXIT
VIDEO:
	CDPLAY		0
	DB	"I put the headphones in the headphone jack in the TV, and put the tape into the VCR."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"The video starts to play."
	DB	NEXT
	DB	"I put the headphones in my ears, leaving one ear free, just in case Akemi-san or Motoka come snooping around."
	DB	NEXT
	DB	"After the static clears, I see the logo of the company that made the video, and then, I see my classmate, Risa Tachikawa."
	DB	NEXT
	DB	"The man holding the camera asks Risa and another girl questions. 'Do you have a boyfriend?' "
        DB      "'How old were you when you lose your virginity?' and so on. I fast forward the video."
	DB	NEXT
	DB	"The other girl starts touching Risa's tits from behind. I stop the fast forward."
	DB	NEXT
	EVENT_CG	'th_066',B_NORM,31
	CDPLAY	15
	DB	"Man:  Okay, Eri-chan, go ahead and touch Risa's tits now."
	DB	NEXT
	DB	"Kenjirou:  So, the other girl's name is Eri..."
	DB	NEXT
	DB	"Eri:  ...Like this?"
	DB	NEXT
	DB	"Man:  That's fine. Risa-chan, how do you like that?"
	DB	NEXT
	DB	"Risa:  How do I... I can't say, really..." 
	DB	NEXT
	DB	"Kenjirou:  Ah, Tachikawa looks great..."
	DB	NEXT
	DB	"The girl Eri starts massaging Risa's breasts harder."
	DB	NEXT
	DB	"Risa:  T- That hurts..." 
	DB	NEXT
	DB	"Man:  Risa-chan, you've got great tits. Has anyone ever told you that before?"
	DB	NEXT
	DB	"Risa:  O- Of course not!" 
	DB	NEXT
	DB	"Eri:  Are you sure? I'll bet you've got a lot of boyfriends."
	DB	NEXT
	DB	"Eri massaged Risa's breasts some more. Risa's face was a mask of pain."
	DB	NEXT
	DB	"Risa:  T- That hurts! I told you already!" 
	DB	NEXT
	DB	"Eri:  Really? I'm sure a girl who's played around as much as you doesn't mind a little pain. I'm sorry."
	DB	NEXT
	DB	"Man:  I think she's telling the truth."
	DB	NEXT
	DB	"Risa:  I don't..." 
	DB	NEXT
	DB	"Eri continued to massage, even harder this time."
	DB	NEXT
	DB	"Risa:  Stop it!" 
	DB	NEXT
	DB	"Risa hits Eri's hand away."
	DB	NEXT
	DB	"Hmm, this is kind of boring."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"I hit the fast forward button some more. Risa takes off her clothes."
	DB	NEXT
	EVENT_CG	'th_067',B_NORM,32
	DB	"The man behind the camera, took off his pants, and brought his cock out. A mosaic censor spot covers his penis."
	DB	NEXT
	DB	"Man:  Risa-chan, suck me."
	DB	NEXT
	DB	"Risa:  Eh? O- Okay." 
	DB	NEXT
	DB	"Risa starts sucking the man's cock. Her tongue flashes out, washing his member as her face disappears in the mosaic."
	DB	NEXT
	DB	"She looks like she does that very well..."
	DB	NEXT
	DB	"Man:  Risa-chan, you're really good. Do you do this with your boyfriend, too?"
	DB	NEXT
	DB	"Risa ignores his question, and continues to suck his penis. But she seemed in pain, somehow."
	DB	NEXT
	DB	"Man:  Put it all the way in, this time."
	DB	NEXT
	DB	"She nods, and slides his cock all the way into her mouth, to the back of her throat. "
	DB	NEXT
	DB	"Eri:  I want to, too..."
	DB	NEXT
	DB	"Man:  Both of you can do it."
	DB	NEXT
	DB	"Eri and Risa take turns sucking the man's cock."
	DB	NEXT
	DB	"Now Risa puts his cock in her mouth, as Eri washes his balls with the flat part of her tongue. I writhe in envy."
	DB	NEXT
	DB	"Now the man takes his cock out of Risa's mouth."
	DB	NEXT
	DB	"Man:  Now Risa, I want you to eat out Eri's pussy."
	DB	NEXT
	DB	"Risa:  Eh?" 
	DB	NEXT
	DB	"Man:  I said I want you to eat Eri's pussy."
	DB	NEXT
	DB	"Eri drops the man's balls, and opens her legs."
	DB	NEXT
	EVENT_CG	'th_068',B_NORM,33
	DB	"Eri:  What are you waiting for? Hurry up."
	DB	NEXT
	DB	"Risa:  .............." 
	DB	NEXT
	DB	"Her legs open now, Eri holds the man's stiff cock in her hand as she waits for Risa to come to her."
	DB	NEXT
	DB	"Slowly, Risa moves her tongue towards Eri's slit."
	DB	NEXT
	DB	"Risa:  Uuu..." 
	DB	NEXT
	DB	"Risa groans as she starts to lick Eri's cunt like a dog."
	DB	NEXT
	DB	"Eri:  Don't be so weak. Lick it properly!"
	DB	NEXT
	DB	"Risa's tongue movements get more purposeful, as she starts to lap with greater speed."
	DB	NEXT
	DB	"Eri:  Ahhh, ahh... Y- Yes, that's good...!"
	DB	NEXT
	DB	"Man:  Risa-chan, you're good at eating women, too."
	DB	NEXT
	DB	"Tachikawa's really going at it. I could never do what she's doing to someone of my own sex, even if my life depended on it."
	DB	NEXT
	DB	"Eri-chan was sucking the man off, as Risa kept licking Eri-chan's pussy. "
	DB	NEXT
	DB	"I like what I'm seeing, but I hate hearing the man grunting as he gets sucked off."
	DB	NEXT
	EVENT_CG	'th_069a',B_NORM,34
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_069a","th_069b",0,0,0,EVENT_YSIZE
	SCR_END
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_069a","th_069b",0,EVENT_YSIZE,0,0
	SCR_END
	DB	"Suddenly, the man moved away from Eri, and went behind Risa. He lifted up her ass, and moved his cock near her slit."
	DB	NEXT
	DB	"Risa:  S- Stop! You said you wouldn't go all the way today..." 
	DB	NEXT
	DB	"Risa stood up, and tried to move away from the man. But Eri caught her from behind, and held her down."
	DB	NEXT
	DB	"She forced Risa's legs open with her hands as she perched on top of Risa."
	DB	NEXT
	DB	"Risa:  S- Stop, please! Eri-san!" 
	DB	NEXT
	DB	"Eri:  Don't worry, you'll like it. Besides, if you run away, you won't get paid."
	DB	NEXT
	DB	"The man brings his face to Risa and starts licking her."
	DB	NEXT
	DB	"Risa:  S- Stop... Ahhhnn..." 
	DB	NEXT
	DB	"Man:  You're pretty wet for a girl who pretends she doesn't want to do it. Did you get that way licking Eri's pussy?"
	DB	NEXT
	DB	"Eri:  This girl's quite a sex machine."
	DB	NEXT
	DB	"Risa:  I- I'm not!" 
	DB	NEXT
	DB	"Man:  Why are you so wet?"
	DB	NEXT
	DB	"The man took his cock out and pushed it into Risa's pussy."
	DB	NEXT
	DB	"Risa:  N- No! Stop it...!" 
	DB	NEXT
	DB	"On the screen, Risa started to cry. But she didn't resist any longer."
	DB	NEXT
	DB	"Risa:  Ahhhn.... I don't like this..." 
	DB	NEXT
	DB	"Slowly, Risa's hips started moving in opposition to the man's, as she stopped fighting completely."
	DB	NEXT
	DB	"Eri:  That's a good girl..."
	DB	NEXT
	DB	"Man:  Yes, I knew she'd come around."
	DB	NEXT
	DB	"Now the man took his cock out of Risa, and put it in Eri's pussy, fucking her as hard as he could."
	DB	NEXT
	DB	"With each thrust, both Risa and Eri's tits moved vertically."
	DB	NEXT
	DB	"Eri:  I- It's good! Yes! Yes...!!"
	DB	NEXT
	DB	"Eri was acting more like you expect an AV gal to behave. She expertly moved her hips against the man's, "
        DB      "as they pushed against each other, as if an effort to get into the same body."
	DB	NEXT
	DB	"Perhaps nearing his orgasm, he pulled his cock our of Eri suddenly."
	DB	NEXT
	DB	"Eri:  No, do it some more..."
	DB	NEXT
	DB	"Ignoring her, he put his cock into Risa once more."
	DB	NEXT
	DB	"Risa:  N- No! Nooo...  Ahhnnn...." 
	DB	NEXT
	DB	"Man:  I'm going to blow my wad inside you, honey."
	DB	NEXT
	DB	"Risa's groaned again."
	DB	NEXT
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_069a","th_069b",0,0,0,EVENT_YSIZE
	SCR_END
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_069a","th_069b",0,EVENT_YSIZE,0,0
	SCR_END
	DB	"The man pumped harder and harder into Risa, making her body quiver with pleasure."
	DB	NEXT
	DB	"Man:  I- It's coming!"
	DB	NEXT
	DB	"Risa:  No..." 
	DB	NEXT
	DB	"The man came, filling Risa's pussy with hot white fluid, which mixed freely with Risa's own juices."
	DB	NEXT
	DB	"Risa began to cry."
	DB	NEXT
	DB	"Risa:  ...H- Hiroshi..." 
	DB	NEXT
	DB	"Eri:  Hey, do me, do me, too!" 
	DB	NEXT
	DB	"Man:  Sure, babe."
	DB	NEXT
	DB	"I'm sure I heard Risa say Hiroshi's name..."
	DB	NEXT
	DB	"Now the man in the video and Eri start to fuck, ignoring Risa completely."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"This is pathetic. Poor Tachikawa-san..."
	DB	NEXT
	DB	"I turn the VCR off."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"But that really was Tachikawa in the video."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"I laugh to myself, suddenly, getting an idea."
	DB	NEXT
	DB	"There's no telling what I can make Risa do, now that I have this video."
	DB	NEXT
	FLG_KI	W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	YARU,"GO FOR IT"
	MENU_SET	SINAI,"NO- SHE'S BEEN THROUGH ENOUGH"
	MENU_END
	DB	EXIT
YARU:
	DB	"What a great idea. I've got the video, so I've got leverage."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"How can I contact her?"
	DB	T_WAIT,	3
	DB	"I've got her phone number around here somewhere, on the class register."
	DB	NEXT
	DB	"I look for my room, and eventually find the paper."
	DB	NEXT
	DB	"Guess I'll give her a call now."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"The phone rings on the other end, and a woman's voice comes on."
	DB	NEXT
	DB	"Voice:  Tachikawa residence..."
	DB	NEXT
	DB	"Suddenly my blood freezes. This is her mother!"
	DB	NEXT
	DB	"Voice:  Hello?"
	DB	NEXT
	DB	"Kenjirou:  H- Hello?"
	DB	NEXT
	DB	"Voice:  Yes?"
	DB	NEXT
	DB	"Kenjirou:  My name is Kondo. I'm just wonder if Risa-san is there? We're classmates..."
	DB	NEXT
	DB	"Voice:  Okay, hang on a moment."
	DB	NEXT
	DB	"I wait. At least she's home."
	DB	NEXT
	DB	"After a while, Risa comes on the phone."
	DB	NEXT
	DB	"Risa:  Hello, who is this?" 
	DB	NEXT
	DB	"Kenjirou:  Ah, hello. I'm Kondo, from your class."
	DB	NEXT
	DB	"Risa:  Yes? What do you want?" 
	DB	NEXT
	DB	"Kenjirou:  ... (What do I say?)"
	DB	NEXT
	DB	"Risa:  Hello?  Are you there? I'm going to hang up." 
	DB	NEXT
	DB	"Kenjirou:  ....I've saw..."
	DB	NEXT
	DB	"The words stuck in my throat."
	DB	NEXT
	DB	"Risa:  Yes?" 
	DB	NEXT
	DB	"Kenjirou:  .....I saw the video."
	DB	NEXT
	DB	"Risa:  .......W- What did you say?" 
	DB	NEXT
	DB	"Kenjirou:  I said, I saw the video you made."
	DB	NEXT
	DB	"Risa:  ......................." 
	DB	NEXT
	DB	"Kenjirou:  I'll be waiting at 1:00 pm tomorrow, in the park."
	DB	NEXT
	DB	"Risa:  Wait a minute..." 
	DB	NEXT
	DB	"I hung up the phone."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"I wonder if she'll come? "
	DB	NEXT
	DB	"Hmm. I've had enough excitement for today. Time for bed."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"I get into bed, and get ready for sleep."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_37.OVL'
	DB	EXIT
SINAI:
	DB	"T- That would be terrible..."
	DB	NEXT
	DB	"I don't want to do anything like that."
	DB	NEXT
	DB	"I'll stick to my fantasy world for things like that."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_38.OVL'
	DB	EXIT
END