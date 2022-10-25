        include SUPER_C.inc
M_START:
MON_37
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Well, guess I'll wake up now. I don't want to keep Risa waiting."
	DB	NEXT
	DB	"After getting dressed, I headed straight for the park."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_031a',B_NORM
	CDPLAY	8
	DB	"There's no one here. I look at the watch on my wrist."
	DB	NEXT
	DB	NEXT
	DB	"I sit down on a stone nearby, and prepare to wait."
	DB	NEXT
	DB	"About fifteen minutes later, Risa shows up."
	DB	NEXT
	T_CG	'tt_15_31a',RIS2,0
	DB	"Risa:  I'm here."
	DB	NEXT
	DB	"She's standing in front of me, seemingly on guard."
	DB	NEXT
	DB	"I've got to get her guard down as best I can."
	DB	NEXT
	DB	"Kenjirou:  Can I remind you of something?"
	DB	NEXT
	DB	"Risa:  Yes? What is it?"
	DB	NEXT
	DB	"Kenjirou:  The video."
	DB	NEXT
	DB	"Risa:  ..................." 
	DB	NEXT
	DB	"At the mention of the video, she shut up in a hurry. She knows I have the upper hand."
	DB	NEXT
	DB	"Risa:  I- If it's money you want, I brought some..." 
	DB	NEXT
	DB	"She really seems upset. The poor girl."
	DB	NEXT
	DB	"Kenjirou:  Don't worry, it's not money that I'm after."
	DB	NEXT
	DB	"Risa:  ...................." 
	DB	NEXT
	DB	"I can see her thinking it over."
	DB	NEXT
	DB	"Looking like she could cry any moment, she just stares at me blankly."
	DB	NEXT
	DB	"I hope she doesn't run away. I don't want her to get the wrong idea."
	DB	NEXT
	DB	"Kenjirou:  Um, what I was going to say was, I'll keep quiet about the video for you."
	DB	NEXT
	DB	"She awaits what I'm going to say next."
	DB	NEXT
	DB	"Kenjirou:  What I want you to do is... go on a date with me."
	DB	NEXT
	DB	"Perhaps it was my shyness, saying the words. But she smiled."
	DB	NEXT
	DB	"Kenjirou:  I mean, I'm not very popular with girls. So I'd like to go on a date with a pretty girl like you..."
	DB	NEXT
	DB	"Risa:  Well, I guess I could do that."
	DB	NEXT
	DB	"Great! I'm in. Now I want to find a place with no people. The park is way too obvious."
	DB	NEXT
	DB	"Risa:  What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing. I was just...glad you said yes."
	DB	NEXT
	DB	"I know. I'll take her to see a movie."
	DB	NEXT
	DB	"Risa:  Do you want to stand here all day?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh no, um, let's go see a movie."
	DB	NEXT
	DB	"Risa:  ...Okay. But that's all."
	DB	NEXT
	DB	"I take Risa's hand, and we head downtown."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_018a',B_NORM
	CDPLAY	2
	T_CG	'tt_15_18a',RIS2,0
	DB	"Risa:  Which movie do you want to see?"
	DB	NEXT
	DB	"Kenjirou:  There's a movie theatre that is playing old revival movies from the 1970's. Want to go?"
	DB	NEXT
	DB	"Risa:  Okay, but let's hurry. I've got things to do today."
	DB	NEXT
	DB	"I see her old bad attitude is back. Oh well..."
	DB	NEXT
	DB	"Risa:  Well, let's go."
	DB	NEXT
	DB	"I take her hand, and we head for the movie theatre."
	DB	NEXT
	BAK_INIT	'tb_019',B_NORM
	T_CG	'tt_15_19',RIS2,0
	DB	"Risa:  ...I- Is this the place?"
	DB	NEXT
	DB	"Kenjirou:  Yep."
	DB	NEXT
	DB	"Risa:  ...Oh well, let's go in."
	DB	NEXT
	DB	"Kenjirou:  Um, let's see..."
	DB	NEXT
	DB	"I look at the movie listing on the sign above me."
	DB	NEXT
	DB	"The next movie starts in an hour."
	DB	NEXT
	DB	"Kenjirou:  We've got a lot of time before the next showing..."
	DB	NEXT
	DB	"Risa:  ...Well, I'm kind of hungry."
	DB	NEXT
	DB	"Kenjirou:  Well, let's get something."
	DB	NEXT
	DB	"Risa:  Okay. Let's hurry, though."
	DB	NEXT
	DB	"I take Risa to a fast food restaurant."
	DB	NEXT
	BAK_INIT	'tb_023',B_NORM
	T_CG	'tt_15_23',RIS2,0
	DB	"Girl:  Can I help you?"
	DB	NEXT
	DB	"Kenjirou:  Tachikawa-san, go ahead and order. I'll get a seat."
	DB	NEXT
	TATI_ERS
	FLG_IF	NAN_ATTA,'=',0,ATTENAI
	DB	"Hmm, I think that girl's named Nana. She's pretty."
	DB	NEXT
	DB	"Guess I'll talk to her later. "
	DB	NEXT
ATTENAI:
	DB	"I look for an empty seat, and sit down."
	DB	NEXT
	DB	"A few minutes later, Risa shows up with a tray of food."
	DB	NEXT
	T_CG	'tt_15_23',RIS2,0
	DB	"Risa puts the tray down on the table, and reaches her empty hand out to me."
	DB	NEXT
	DB	"I knew what she wanted to say, but I pretended ignorance."
	DB	NEXT
	DB	"Kenjirou:  What's wrong? Why are you holding your hand out like that?"
	DB	NEXT
	DB	"Risa:  ...Give me some money." 
	DB	NEXT
	DB	"Kenjirou:  Eh? I don't know what you're talking about."
	DB	NEXT
	DB	"Risa:  I paid for lunch. I want you to pay me back."
	DB	NEXT
	DB	"Kenjirou:  You're paying for everything today."
	DB	NEXT
	DB	"Risa:  Oh my god! You're the lowest form of guy there is!" 
	DB	NEXT
	DB	"Kenjirou:  ......................"
	DB	NEXT
	DB	"I don't say anything, counting on Risa's intelligence to do the rest. She sits down."
	DB	NEXT
	DB	"Risa:  ...O- Okay, I'll pay. " 
	DB	NEXT
	DB	"I open the hamburger and begin to eat. I try to start a conversation several times with Risa, but she's not in the mood."
	DB	NEXT
	DB	"Well, I can understand..."
	DB	NEXT
	DB	"Kenjirou:  Shall we go?"
	DB	NEXT
	DB	"Risa:  ...Yes, let's go."
	DB	NEXT
	DB	"We leave the restaurant, and go back to the movie theatre."
	DB	NEXT
	BAK_INIT	'tb_019',B_NORM
	T_CG	'tt_15_19',RIS2,0
	DB	"Looking at the clock, I see we have ten minutes before the next showing. I stare at Risa until she gets the message."
	DB	NEXT
	DB	"Risa:  Okay! I'll go buy the tickets!"
	DB	NEXT
	DB	"I take my ticket from Risa, and we go into the theatre. "
	DB	NEXT
	BAK_INIT	'tb_020',B_NORM
	T_CG	'tt_15_20',RIS2,0
	DB	"Inside, we're greeted by an ugly, run-down theatre."
	DB	NEXT
	DB	"I guess it's not only the outside that's dirty."
	DB	NEXT
	DB	"Risa:  ...This place is kind of creepy." 
	DB	NEXT
	DB	"As she says this, she kicks an empty tub of popcorn that was lying by her feet."
	DB	NEXT
	DB	"The paper tub rolls under a chair."
	DB	NEXT
	DB	"Risa:  Let's sit down." 
	DB	NEXT
	DB	"She starts walking into the theatre by herself."
	DB	NEXT
	TATI_ERS
	DB	"I follow her, and sit down next to her."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"The buzzer rings, signifying the start of the movie."
	DB	NEXT
	DB	"I completely ignored the movie in front of me, and waited for my chance with Risa."
	DB	NEXT
	DB	"However, Risa had her guard up again, and she was keeping one eye on the movie and one on me."
	DB	NEXT
	DB	"This girl's got to be used to guys like me."
	DB	NEXT
	DB	"With nothing left to do, I pretended to be caught up in the movie, as I considered my options."
	DB	NEXT
	DB	"Being careful, so as not to alert her, I put my hand over hers."
	DB	NEXT
	EVENT_CG	'th_058',B_NORM,25
	DB	"Her body goes a little stiff, but she doesn't object. She does make a funny face, though."
	DB	NEXT
	DB	"She probably knew this was coming from the moment we entered the movie theatre."
	DB	NEXT
	DB	"Kenjirou:  Your hand is really warm."
	DB	NEXT
	DB	"Risa:  .............." 
	DB	NEXT
	DB	"It's part of my plan that she should get mad at me. This should work well."
	DB	NEXT
	DB	"Just as I thought, her eyebrows bunch into a frown."
	DB	NEXT
	DB	"Enjoying myself, I start to pet her hand softly."
	DB	NEXT
	DB	"Risa:  Stop that..." 
	DB	NEXT
	DB	"She's so cute."
	DB	NEXT
	DB	"Wanting to egg her on some more, I pretend to not know what she's talking about."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Risa:  Your hand." 
	DB	T_WAIT,	3
	DB	" Move it, please."
	DB	NEXT
	DB	"Kenjirou:  ................"
	DB	NEXT
	DB	"I stop petting her hand, and move it inside her skirt instead."
	DB	NEXT
	EVENT_CG	'th_059',B_NORM,26
	DB	"Risa:  W- What the hell do you think you're doing?" 
	DB	NEXT
	DB	"She grabbed my wrist in a death grip, holding it back. I hadn't reached her crotch when her hand grabbed mine."
	DB	NEXT
	DB	"Her Mound of Venus is higher than most other girls, and I had felt the rough "
        DB      "steely mass of her pubic hair for a second through her panties."
	DB	NEXT
	DB	"Kenjirou:  You asked me not to touch your hand. So I'm doing what you said."
	DB	NEXT
	DB	"Risa:  W- What? Do you have water on the brain?" 
	DB	NEXT
	DB	"Her voice echoes around the inside of the theatre, but no one even turns to look."
	DB	NEXT
	DB	"Kenjirou:  Tachikawa-san, do you know what a position you're in?"
	DB	NEXT
	DB	"She released my wrist, allowing my hand to find her slit once again."
	DB	NEXT
	DB	"Now, Risa closed her legs as tightly as she could in an effort to deny my hand access to her."
	DB	NEXT
	DB	"Kenjirou:  Open your legs... remember the video..."
	DB	NEXT
	DB	"Risa:  ................." 
	DB	NEXT
	DB	"I wait, not entirely sure what course she'll take."
	DB	NEXT
	DB	"Grudgingly, she opens her legs for my hand."
	DB	NEXT
	DB	"My finger quickly moves through her panties and into the dampness of her pussy."
	DB	NEXT
	DB	"With no choice, Risa allows her pussy to swallow my finger."
	DB	NEXT
	DB	"Risa:  K- Ku..." 
	DB	NEXT
	DB	"I slide my finger in and out of her, stimulating her, all the while toying with her clit through the fabric of her panties."
	DB	NEXT
	DB	"I devote extra energy to her clit, now, stimulating it directly."
	DB	NEXT
	DB	"Risa:  Uguuu..." 
	DB	NEXT
	DB	"Risa struggles to keep from letting any sound out of her throat, as she continues to let me play with her pussy."
	DB	NEXT
	DB	"Wanting to make her emit that noise, I work even harder to stimulate her clit with my fingers."
	DB	NEXT
	DB	"Risa:  Ahh...!" 
	DB	NEXT
	DB	"Her tiny shriek echoes around the inside of the movie theatre. Just then, Risa stands up suddenly."
	DB	NEXT
	BAK_INIT	'tb_020',B_NORM
	T_CG	'tt_15_20',RIS2,0
	DB	"Risa:  I- I'm going to the bathroom." 
	DB	NEXT
	TATI_ERS
	DB	"She leaves the inside of the theatre. Unable to believe that she's really going into the bathroom, I follow her."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Looking around her, she heads into the women's bathroom. I wait outside."
	DB	NEXT
	DB	"But five minutes later, she's still failed to reappear."
	DB	NEXT
	DB	"Suddenly worried, I poke my head inside the women's bathroom, to see if she's in there."
	DB	NEXT
	BAK_INIT	'tb_017b',B_NORM
	DB	"I look around for her, but don't see any stalls that are in use."
	DB	NEXT
	DB	"Damn! She got away..."
	DB	T_WAIT,	3
	DB	" I wonder how she managed it?"
	DB	NEXT
	DB	"Just as I was about to leave the woman's restroom, I heard a tiny sound from the stall in the back."
	DB	NEXT
	DB	"I stand in front of the stall."
	DB	NEXT
	DB	"It's unlocked. I verify that she's inside by putting my ear against the door."
	DB	NEXT
	DB	"Slowly, I peek through the crack."
	DB	NEXT
	EVENT_CG	'th_060',B_NORM,27
	CDPLAY	15
	DB	"Risa has her panties down around her ankles, her sweater pulled up, as she massaged her own tits."
	DB	NEXT
	DB	"She's masturbating?!"
	DB	NEXT
	DB	"Risa:  Uun...kuu...I'll never forgive him, for getting me this hot..." 
	DB	NEXT
	DB	"Unable to stand it any longer, I throw open the door to the stall and enter."
	DB	NEXT
	DB	"Risa:  Eh?!" 
	DB	NEXT
	DB	"She stares at me, unbelieving."
	DB	NEXT
	DB	"I take my hard cock out of my pants, and offer it to her."
	DB	NEXT
	DB	"Risa:  W- What...?" 
	DB	NEXT
	DB	"Kenjirou:  Can I give you a hand?"
	DB	NEXT
	DB	"I put my bright-red cock near Risa's face."
	DB	NEXT
	DB	"Kenjirou:  Here. I want you to do it."
	DB	NEXT
	DB	"She stared at it for a few seconds, clearly wanting it."
	DB	NEXT
	DB	"Risa:  Y- You know I'm Hiroshi's woman." 
	DB	NEXT
	DB	"Kenjirou:  Hiroshi's? I hate to tell you, but he's just playing with you."
	DB	NEXT
	DB	"Risa:  T- That's not true!" 
	DB	NEXT
	DB	"But she knew, and her eyes couldn't lie. "
	DB	NEXT
	DB	"Kenjirou:  It was because of Hiroshi that you were put in that video, too, wasn't it?"
	DB	NEXT
	DB	"Risa:  .................." 
	DB	NEXT
	DB	"She grew quiet, considering."
	DB	NEXT
	DB	GATA,	2
	F_O	B_NORM,C_KURO
	DB	"Kenjirou:  Wahh!"
	DB	NEXT
	DB	"She suddenly moved towards me, trying to push past."
	DB	NEXT
	DB	"I put a hand out to stop her."
	DB	NEXT
	EVENT_CG	'th_061',B_NORM,28
	DB	"Risa:  Guu!" 
	DB	NEXT
	DB	"Kenjirou:  Come on... You know you want this."
	DB	NEXT
	DB	"Risa:  You don't know what I really want!" 
	DB	NEXT
	DB	NEXT
	F_O	B_NORM,C_KURO
	EVENT_CG	'th_062',B_NORM,29
	DB	"We moved into the stall, then, and moving behind her, I spread her legs into an M shape, and gazed straight at her pussy."
	DB	NEXT
	DB	"Her pubic hair was dark, and full around her Mound of Venus."
	DB	NEXT
	DB	"The area around her pussy was glistening with her lubricant."
	DB	NEXT
	DB	"Kenjirou:  You've got a lot of hair down here. How about your ass?"
	DB	NEXT
	DB	"Risa:  ................." 
	DB	NEXT
	DB	"She stared dumbly at me, and ignored what I had said."
	DB	NEXT
	DB	"Risa:  You want to do it, right? Go ahead and get it over with." 
	DB	NEXT
	DB	"Kenjirou:  Okay, I will. But I want to get a good look at you first."
	DB	NEXT
	DB	"Risa:  Damn you!  Just keep your promise about the video!" 
	DB	NEXT
	DB	"Her pussy was trembling as I continued to gaze at her pink flesh."
	DB	NEXT
	DB	"I put my face down near her slit, and smelled her sweet scent."
	DB	NEXT
	DB	"Kenjirou:  Mmm, smells pretty ripe. Did you just come off your period?"
	DB	NEXT
	DB	"Risa:  Shut up!" 
	DB	NEXT
	DB	"I pushed open the flesh of her cunt, and began to lick her pussy slowly."
	DB	NEXT
	DB	"Risa:  Ahhn..."
	DB	NEXT
	DB	"As I stimulate the clitoral hood with my tongue, she lets out a soft, low moan."
	DB	NEXT
	DB	"Yeaning to make her really yell with pleasure, I put my tongue inside her pussy, feeling her warm walls around it."
	DB	NEXT
	DB	"Risa:  Mmmm......aahhh...."
	DB	NEXT
	DB	"She moved her head back and forth, refusing to show me a sign of any pleasure, "
        DB      "but the sound that I sought slowly started to come."
	DB	NEXT
	DB	"I move up to her pubic mound, and start stimulating that area, pressing in on her clit with my thumb."
	DB	NEXT
	DB	"Risa:  Hii!!" 
	DB	NEXT
	DB	"Along with her sound, a fresh supply of lubricant is delivered unseen to her pussy."
	DB	NEXT
	DB	"Kenjirou:  You're really into this kind of thing, Risa. I can tell."
	DB	NEXT
	DB	"Risa:  That's not true! And stop calling me by my first name... Just do it, okay?" 
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"I strip her naked, and open her legs."
	DB	NEXT
	EVENT_CG	'th_063a',B_NORM,30
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_063a","th_063b",0,0,0,EVENT_YSIZE
	SCR_END
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_063a","th_063b",0,EVENT_YSIZE,0,0
	SCR_END
	DB	"Kenjirou:  I think you've played around too much. Your pussy is a funny color."
	DB	NEXT
	DB	"Risa:  That has nothing to do with anything! You don't know much about women!" 
	DB	NEXT
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_063a","th_063b",0,0,0,EVENT_YSIZE
	SCR_END
	DB	"I touch her well-endowed pubic mound with one hand, keeping my thumb on her clit an inch below."
	DB	NEXT
	DB	"Risa:  Kiii!" 
	DB	NEXT
	DB	"She yells with pleasure so loudly that I wonder if her words aren't heard in the lobby outside."
	DB	NEXT
	DB	"Risa:  S- Stop that!" 
	DB	NEXT
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_063a","th_063b",0,EVENT_YSIZE,0,0
	SCR_END
	DB	"Kenjirou:  ...Okay, open your pussy to me."
	DB	NEXT
	DB	"She opened her pussy, all the way. I positioned my penis at the pink, wet opening of her flesh."
	DB	NEXT
	DB	"Enjoying my victory, I move my stiff cock to the opening of her pussy and then pushing it in."
	DB	NEXT
	DB	"Risa:  ..........Mm!" 
	DB	NEXT
	DB	"Her clit is large, and I touch it lightly with one finger."
	DB	NEXT
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_063a","th_063b",0,0,0,EVENT_YSIZE
	SCR_END
	DB	"Risa:  Ahhn!" 
	DB	NEXT
	DB	"Slowly, I slide my cock into her, until the movement starts to get smooth again."
	DB	NEXT
	DB	"Risa:  Ahhn! Ahhh...." 
	DB	NEXT
	DB	"The inner walls of her honey pot are all around me."
	DB	NEXT
	FLG_IF	AKE_YARU,'=',0,DOUTEI
	DB	"Unlike the time with Akemi-san, I am thinking only of my own pleasure, and not of hers."
	DB	NEXT
	DB	"Risa:  No! .....It's good! It's good...!" 
	DB	NEXT
	DB	"Kenjirou:  Uuu... I'm coming...!"
	DB	NEXT
	DB	"Kenjirou:  .....Can't...hold it!"
	DB	NEXT
	MC_FLASH	3,C_SIRO
	B_O	B_FADE,C_SIRO
	F_O	B_NORM,C_KURO
	FLG_KI	YOKU,'=',0
	FLG_KI	RISA_SYO,'=',1
	DB	"Having had my fun, I put my pants back on and said goodbye to Risa. She doesn't speak to me."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Welcome home. Where were you off to today? A date with some girl, perhaps?"
	DB	NEXT
	DB	"Kenjirou:  Eh? "
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing like that. Um, where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She's in her room, studying."
	DB	NEXT
	DB	"Kenjirou:  I see. I'll go study, too, I guess."
	DB	NEXT
	DB	"Akemi:  Study female anatomy?" 
	DB	NEXT
	DB	"Kenjirou:  N- No, nothing like that."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"I cut my conversation with Akemi-san short, and head to my room."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"In my room, I felt guilty about what I had done."
	DB	NEXT
	DB	"That's not good, is it?"
	DB	NEXT
	DB	"Now I feel bad..."
	DB	NEXT
	DB	"Resolving to never repeat the events of today, I head for bed."
	DB	NEXT
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_39.OVL'
	DB	EXIT
DOUTEI:
	DB	"Mmm, it's so warm, so good..."
	DB	NEXT
	DB	"Kenjirou:  I- It's no good! I'm coming!"
	DB	NEXT
	DB	"Risa:  N- No!" 
	DB	NEXT
	DB	"Kenjirou:  Uuu........" 
	DB	NEXT
	MC_FLASH	3,C_SIRO
	B_O	B_FADE,C_SIRO
	F_O	B_NORM,C_KURO
	CDPLAY		0
	FLG_KI	YOKU,'=',0
	FLG_KI	RISA_SYO,'=',1
	DB	"Oops, I didn't mean to come so fast. Embarrassed, I put my pants back on and say goodbye to Risa. She doesn't speak to me."
	DB	NEXT
	F_O	B_NORM,C_KURO
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Welcome home. Where were you all day? A date?"
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing like that. Where's Motoka?"
	DB	NEXT
	DB	"Akemi:  Motoka? She's in her room, studying."
	DB	NEXT
	DB	"Kenjirou:  I see. I guess I'll do some of that, too."
	DB	NEXT
	DB	"Akemi:  Studying...girls?" 
	DB	NEXT
	DB	"Kenjirou:  N- No, of course not!"
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"I cut my conversation with Akemi short and head to my room."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"In my room, I felt guilty about what I had done."
	DB	NEXT
	DB	"That's not good, is it?"
	DB	NEXT
	DB	"Now I feel bad..."
	DB	NEXT
	DB	"Resolving to never repeat the events of today, I head for bed."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_39.OVL'
	DB	EXIT
END