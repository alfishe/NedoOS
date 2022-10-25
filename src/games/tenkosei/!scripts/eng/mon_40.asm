        include SUPER_C.inc
M_START:
MON_40
	FLG_KI	TER_DEN,'=',0
	FLG_KI	TERUNASI,'=',1
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"Just as I'm trying to get to sleep, my cellular phone starts to ring."
	DB	NEXT
	DB	"Kenjirou:  Who the hell would call me this late?"
	DB	NEXT
	DB	"Of course, I knew it must have been Tetsuya."
	DB	NEXT
	DB	"I got out of bed, and answered the phone."
	DB	NEXT
	DB	"Kenjirou:  Hey, what time do you think it is?"
	DB	NEXT
	DB	"Voice:  Ah, I'm sorry. Were you sleeping?"
	DB	NEXT
	DB	"The voice is female -- definitely not Tetsuya."
	DB	NEXT
	DB	"I know I've heard the voice before. It takes me a minute to get it."
	DB	NEXT
	DB	"Kenjirou:  T- T- Terumi-senpai!"
	DB	NEXT
	DB	"Wow! She's calling me..."
	DB	NEXT
	DB	"Terumi:  What do you mean, 'T- T- T-'?" 
	DB	NEXT
	DB	"Kenjirou:  I'm sorry. I was sure it was going to be Tetsuya. You kind of took me by surprise."
	DB	NEXT
	DB	"Terumi:  I can imagine. You probably don't get many calls from beautiful girls like me." 
	DB	NEXT
	DB	"Kenjirou:  Hey, leave me alone! Why did you call, anyway?"
	DB	NEXT
	DB	"Terumi:  Eh?" 
	DB	T_WAIT,	3
	DB	" Oh. I've...got something to talk about with you. Is now a good time?"
	DB	NEXT
	DB	"Kenjirou:  Sure. "
	DB	T_WAIT,	3
	DB	" What is it?"
	DB	NEXT
	DB	"Terumi:  .....Can you come out?" 
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Terumi:  It's...not something I can say on the phone." 
	DB	NEXT
	DB	"What up with her? She's kind of scaring me. I wonder what's up..."
	DB	NEXT
	DB	"Terumi:  I guess you can't...?" 
	DB	NEXT
	DB	"I'm not sure what's up, but I'd better go find out."
	DB	NEXT
	DB	"Kenjirou:  No, I can make it. Where are you now?"
	DB	NEXT
	DB	"Terumi:  I'm in the park." 
	DB	NEXT
	DB	"Kenjirou:  Okay, I'll see you in a few minutes."
	DB	NEXT
	DB	"Terumi:  Okay. I'll be waiting here." 
	DB	NEXT
	DB	"I hung up the phone."
	DB	NEXT
	DB	"I quickly got dressed and headed to the park."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_032b',B_NORM
	CDPLAY	8
	DB	"I arrived at the park, but didn't see Terumi-senpai anywhere."
	DB	NEXT
	DB	"Kenjirou:  Where could she be?"
	DB	NEXT
	DB	"Sitting down on a rock, I decide to wait for her."
	DB	NEXT
	DB	"But she still fails to show up."
	DB	NEXT
	DB	"Kenjirou:  Hmmm..."
	DB	T_WAIT,	3
	DB	" Could she have gone home?"
	DB	NEXT
	DB	"I wonder where she is?"
	DB	NEXT
	DB	"I look at my watch, and see that thirty minutes have passed already. Still no Terumi-senpai."
	DB	NEXT
	DB	"I wonder what happened..."
	DB	NEXT
	DB	"Maybe she got attacked, or something?"
	DB	NEXT
	DB	"I guess not. It would have to be a bear or a tiger to be any threat to Terumi-senpai."
	DB	NEXT
	DB	"I guess I'll head home."
	DB	NEXT
	DB	"Confused, I head for the entrance to the park."
	DB	NEXT
	DB	"Voice:  Kya!"
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	T_WAIT,	3
	DB	" That sounded like Terumi-senpai's voice..."
	DB	NEXT
	DB	"I wonder..."
	DB	T_WAIT,	3
	DB	" But if it was her voice..."
	DB	NEXT
	DB	"I am suddenly filled with fear. I run towards where I heard the voice from."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY	22
	BAK_INIT	'tb_024',B_NORM
	DB	"I'm sure I heard it from this direction."
	DB	NEXT
	DB	"I head down the path."
	DB	NEXT
	DB	"Man's voice:  No matter how hard you resist, you're still a woman..."
	DB	NEXT
	DB	"Woman's voice:  Damn..."
	DB	NEXT
	DB	"Huh? It was Terumi-senpai's voice..."
	DB	NEXT
	DB	"Slowly, I look at the area where the voice came from."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"It was a scene of bloodshed. Three men, with bloodied faces, stood around Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  Se-ya!" 
	DB	NEXT
	MC_FLASH	1,C_SIRO
	DB	"She struck out at the big one, using all her strength."
	DB	NEXT
	DB	"But he caught her arm, and dealt her a blow himself."
	DB	NEXT
	DB	"The blow tore part of her top off, exposing one breast to the open air."
	DB	NEXT
	EVENT_CG	'th_022',B_NORM,7
	DB	"Big man:  You've got pretty nice tits, honey."
	DB	NEXT
	DB	"The man walked purposefully towards Terumi-senpai."
	DB	NEXT
	DB	"W- What do I do?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET    SEIKOU, "IS THERE SOMETHING I CAN USE AS A WEAPON?"
	MENU_SET    SIPPAI, "I'VE GOT TO SAVE HER NOW!"
	MENU_END
	DB	EXIT
SEIKOU:
	DB	"I look around for something that could be used as a weapon."
	DB	NEXT
	DB	"I've got to hurry!"
	DB	NEXT
	DB	"I pick up a stone, the size of my fist, and approach the big man, and slam it down on the back of his head."
	DB	NEXT
	;WAV	'Se_at1'
	DB	"The stone makes a sick, breaking sound, and blood starts to flow from the back of the man's head."
	DB	NEXT
	DB	"Terumi:  Kenjirou!" 
	DB	NEXT
	DB	"As she calls out to me, the big man collapses."
	DB	NEXT
	DB	"With the shock of seeing the black blood spilling on the ground started to make my body shake."
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai..."
	DB	NEXT
	DB	"Terumi:  Kenjirou! Come over here." 
	DB	NEXT
	DB	"But I can't move. After a time, Terumi-senpai takes my hand and leads me out of the park."
	DB	NEXT
	BAK_INIT	'tb_032b',B_NORM
	CDPLAY	8
	T_CG	'tt_05_32b',TER2,0
	DB	"Inside my head, my brain was spinning around. Had I just killed someone?"
	DB	NEXT
	DB	"The shaking continues, as I try to understand what had happened."
	DB	NEXT
	DB	"Kenjirou:  T- Terumi-senpai, I..."
	DB	NEXT
	DB	"Terumi:  Kenjirou... Why did you do that?" 
	DB	NEXT
	DB	"Kenjirou:  I had to save you."
	DB	T_WAIT,	3
	DB	" Do, do you think that guy's dead?"
	DB	NEXT
	DB	"Terumi:  He'll be fine. There's no way he could be dead from a small rock like that."
	DB	NEXT
	DB	"Kenjirou:  Really? Then it was nothing, then. I feel better."
	DB	NEXT
	DB	"At her words, I was slowly able to get my fear under control."
	DB	NEXT
	DB	"Kenjirou:  ...T- Terumi-senpai..."
	DB	T_WAIT,	3
	DB	" Um, what did you want to talk to me about?"
	DB	NEXT
	DB	"Terumi:  Don't try changing the subject. It was a stupid thing to do." 
	DB	NEXT
	DB	"Kenjirou:  ...I'm sorry."
	DB	NEXT
	DB	"Terumi:  ...On the other hand, you saved me."
	DB	NEXT
	DB	"Terumi:  Thanks." 
	DB	NEXT
	DB	"Kenjirou:  ...So you didn't call me out here to play some kind of practical joke or anything?"
	DB	NEXT
	DB	"Terumi:  What? No, nothing like that." 
	DB	T_WAIT,	3
	DB	" I had a good reason to call you out here."
	DB	NEXT
	DB	"Kenjirou:  ...What was it?"
	DB	NEXT
	DB	"Terumi:  Well..."
	DB	T_WAIT,	3
	DB	" Let's forget about it for now. "
	DB	NEXT
	DB	"Kenjirou:  That's not very like you, Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  ................" 
	DB	NEXT
	DB	"Kenjirou:  I mean, you've always got every situation under control."
	DB	NEXT
	CDPLAY	19
	DB	"Terumi:  ...I'm not a strong woman at all." 
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Terumi:  I'm not. A strong woman."
	DB	T_WAIT,	3
	DB	" Even now. I can't even say what I want to say."
	DB	NEXT
	DB	"Kenjirou:  What is it you want to say?"
	DB	NEXT
	DB	"Terumi:  ........" 
	DB	T_WAIT,	3
	DB	"That I love you."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Terumi:  Don't say 'Eh?'" 
	DB	NEXT
	DB	"Her face turns suddenly red, and she looks down at the ground. Silence reigned around us."
	DB	NEXT
	DB	"She's in love with me? I never suspected it. Do I... Do I love her, too?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	UKERU,"I LOVE HER"
	MENU_SET	KOTOW,"I LOVE HER AS A SENPAI"	
	MENU_END
	DB	EXIT
UKERU:
	DB	"Kenjirou:  Terumi-senpai, I..."
	DB	T_WAIT,	3
	DB	" I really..."
	DB	NEXT
	DB	"Terumi:  Eh?" 
	DB	NEXT
	DB	"Kenjirou:  I really do love you..."
	DB	NEXT
	DB	"Terumi:  Kenjirou..." 
	DB	NEXT
	SINARIO	'BUNKI_3.OVL'
	DB	EXIT
KOTOW:
	CDPLAY	4
	DB	"Kenjirou:  Terumi-senpai, I..."
	DB	T_WAIT,	3
	DB	" You mean a lot to me. You're very dear to me. But as a senpai..."
	DB	NEXT
	DB	"Terumi:  ...I understand." 
	DB	T_WAIT,	3
	DB	" I'm sorry for putting you on the spot."
	DB	NEXT
	DB	"Her eyes still fixed on the ground, she forced a smile."
	DB	NEXT
	DB	"Seeing that smile brought me nothing but pain, somehow..."
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai..."
	DB	NEXT
	DB	"Terumi:  Well, I'm finished here. " 
	DB	NEXT
	TATI_ERS
	DB	" She turned her back to me, and started to walk home."
	DB	NEXT
	DB	"Kenjirou:  Terumi-senpai."
	DB	NEXT
	DB	"Terumi:  I'm sorry. Will you leave me alone for a little while?" 
	DB	NEXT
	DB	"I could hear the tears in her voice. They told me to stay away."
	DB	NEXT
	DB	"Kenjirou:  ...Okay. I'll go home now, then."
	DB	NEXT
	DB	"Terumi:  ............." 
	DB	NEXT
	DB	"She nodded in reply, and I went home, not looking back at her."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"In my bed, I stared at the ceiling, thinking."
	DB	NEXT
	DB	"Kenjirou:  Kiyomi-senpai..."
	DB	NEXT
	DB	"She was crying."
	DB	NEXT
	DB	"When I left, I could see her shoulders going up and down as she sobbed."
	DB	NEXT
	DB	"I, who have been unsuccessful in love so many times, understand the reason for her tears."
	DB	NEXT
	DB	"Regret."
	DB	NEXT
	DB	"Regret. Asking yourself why you spoke, why you didn't just keep quiet."
	DB	NEXT
	DB	"I understand that pain. I understand it all too well."
	DB	NEXT
	DB	"I'm sorry, Terumi-senpai."
	DB	NEXT
	DB	"Lying in my bed, I touched my eye. My finger came away wet."
	DB	NEXT
	DB	"At some point, I cried myself to sleep and knew no more."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_41.OVL'
	DB	EXIT
SIPPAI:
	CDPLAY	15
	DB	"I look around for something to use as a weapon."
	DB	NEXT
	DB	"Finding nothing, I move to attack him with my bare hands."
	DB	NEXT
	BAK_INIT	'tb_024',B_NORM
	DB	"Kenjirou:  I'll save you, Terumi-senpai!"
	DB	NEXT
	DB	"I swing at the man as hard as I can."
	DB	NEXT
	;WAV	'Se_at1'
	DB	GATA,	1
	DB	"My fist hits a great force, as if I had struck a wall."
	DB	NEXT
	DB	"Terumi:  Kenjirou! Run away!" 
	DB	NEXT
	DB	"Just as her words reached my ear, the man's fist slams into the side of my head."
	DB	NEXT
	;WAV	'Se_at1'
	DB	GATA,	1
	DB	"Kenjirou:  Uuu!"
	DB	NEXT
	DB	GATA,	3
	;WAV	'Se_AT2'
	DB	"I fall, and sometime later, pain starts reverberating through my body."
	DB	NEXT
	DB	"With no strength in my legs, I lie there like a rag doll."
	DB	NEXT
	DB	"Terumi:  Kenjirou!" 
	DB	NEXT
	DB	"I see Terumi-senpai trying to run to me."
	DB	NEXT
	DB	"The man catches her, and rips the rest of her clothes off of her."
	DB	NEXT
	DB	"She hides her breasts, and tries to escape the man's clutches."
	DB	NEXT
	DB	"The man, emboldened by the sign of Terumi-senpai's naked body, pulls her over to him."
	DB	NEXT
	DB	"Terumi:  Stop...!!" 
	DB	NEXT
	;WAV	'Se_at1'
	DB	"With one blow, he puts an end to Terumi-senpai's scream."
	DB	NEXT
	EVENT_CG	'th_023',B_NORM,8
	DB	"Ignoring her pleas, he brings out his filthy cock, and proceeds to slide it inside Terumi-senpai's helpless pussy."
	DB	NEXT
	DB	"Terumi:  No...!!" 
	DB	NEXT
	DB	"Terumi-senpai's face is distorted with pain."
	DB	NEXT
	DB	"At the sounds of Terumi-senpai's screaming, one of the unconscious men regained consciousness."
	DB	NEXT
	DB	"Big man:  You picked a good time to wake up."
	DB	NEXT
	DB	"Man:  T- This bitch..."
	DB	NEXT
	DB	"Big man:  She got her poke at you. You can have her when I'm done here."
	DB	NEXT
	DB	"Man:  Hehe, thanks."
	DB	NEXT
	DB	"The man, who was covered in his own blood from the bloody nose Terumi-senpai had given him, "
        DB      "took his pants off and began stuffing it inside her mouth."
	DB	NEXT
	DB	"But she refused its entry."
	DB	NEXT
	DB	"Man:  Bitch! I want you to eat it!"
	DB	NEXT
	DB	"Big man:  Hey! Do as you're told, you!"
	DB	NEXT
	DB	"The big man violently moved his hips, pushing his cock deeper into her. Blood began to flow."
	DB	NEXT
	DB	"Terumi:  Gnngh...!" 
	DB	NEXT
	DB	"She gnashed her teeth, and shook her head at the pain."
	DB	NEXT
	DB	"Big man:  If you don't suck it for him, I'll do worse to you."
	DB	NEXT
	DB	"He started to fuck her even harder."
	DB	NEXT
	DB	"Terumi:  Uuuu!!" 
	DB	NEXT
	DB	"Man:  What'll it be? You can probably still have kids now."
	DB	NEXT
	DB	"He pushed his cock into Terumi-senpai's mouth."
	DB	NEXT
	DB	"She resisted, but had to give up now."
	DB	NEXT
	DB	"Man:  Oh! That's good..."
	DB	NEXT
	DB	"Big man:  You're pretty good, honey. Did you learn this from that guy over there?"
	DB	NEXT
	DB	"Terumi-senpai..."
	DB	NEXT
	DB	"The spectacle went on like that, until I finally lost consciousness."
	DB	NEXT
	MC_FLASH	3,C_KURO
	B_O	B_FADE,C_KURO
	CDPLAY		0
	BAK_INIT	'tb_024',B_FADE
	DB	"Kenjirou:  T- Terumi-senpai?" 
	DB	NEXT
	DB	"I looked around, and found her torn, bloody clothes."
	DB	NEXT
	DB	"Kenjirou:  ......................."
	DB	NEXT
	DB	"I wanted to believe it was all a bad dream, but my aching body wouldn't allow it. "
	DB	NEXT
	DB	"I wanted to look for Terumi-senpai, but there was nothing I could do. I limped home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	4
	DB	"Kenjirou:  Terumi-senpai..."
	DB	NEXT
	DB	"I wonder what happened after that?"
	DB	NEXT
	DB	"D- Damn it!"
	DB	NEXT
	DB	"Filled with anger and regret that I hadn't been able to protect Terumi-senpai, the tears welled up in me."
	DB	NEXT
	DB	"Kenjirou:  Shit!!"
	DB	NEXT
	DB	"With each sob, a new wave of pain racks my body."
	DB	NEXT
	DB	"In that manner, I fell asleep and knew no more."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_41.OVL'
	DB	EXIT
END