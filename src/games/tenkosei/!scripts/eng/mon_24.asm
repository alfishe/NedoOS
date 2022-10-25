        include SUPER_C.inc
M_START:
MON_24
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"I didn't get much sleep last night..."
	DB	NEXT
	DB	"Well, I'll get dressed and head down for breakfast."
	DB	NEXT
	DB	"I put on my uniform, and head down to the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY		20
	T_CG	'tt_20_02',AKE_A3,0
	T_CG	'tt_21_02',MOT_B1,0
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Akemi:  Good morning."
	DB	NEXT
	DB	"Motoka:  ..................."
	DB	NEXT
	DB	"Motoka doesn't greet me, but just stares in front of her."
	DB	NEXT
	DB	"Kenjirou:  Motoka, you were pretty late last night."
	DB	NEXT
	DB	"Motoka:  ................" 
	DB	NEXT
	DB	"Akemi:  Motoka, greet your brother."
	DB	NEXT
	DB	"Motoka:  I'm going to school." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_20_02',AKE_A2,0
	CDPLAY		6
	DB	"Akemi:  Ah, Motoka..."
	DB	NEXT
	DB	"Kenjirou:  ...I guess she's decided she hates me."
	DB	NEXT
	DB	"Akemi:  I'm really sorry, Kenjirou-kun." 
	DB	NEXT
	DB	"Kenjirou:  It's okay. I'm sure it will blow over."
	DB	NEXT
	DB	"Akemi:  ...That girl is..." 
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Akemi:  Oh, nothing."
	DB	NEXT
	DB	"Kenjirou:  ...................."
	DB	NEXT
	DB	"Kenjirou:  Well, I'm off to school."
	DB	NEXT
	DB	"Akemi:  Okay, have a good day."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_007',B_NORM
	CDPLAY	3
	DB	"I head for the convenience store. Terumi-senpai is waiting here, as usual."
	DB	NEXT
	DB	"I meet her here almost every day."
	DB	NEXT
	T_CG	'tt_05_07',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai... Good morning."
	DB	NEXT
	DB	"Terumi:  Good morning. You don't seem very happy today again." 
	DB	NEXT
	DB	"Terumi:  ............."
	DB	T_WAIT,	3
	DB	"Terumi-senpai..."
	DB	NEXT
	DB	"Terumi:  Mm?"
	DB	NEXT
	DB	"Maybe I should ask Terumi-senpai what she thinks?"
	DB	NEXT
	DB	"Kenjirou:  Um, I..."
	DB	NEXT
	DB	"Terumi:  You're a man. Say what you have to say."
	DB	NEXT
	DB	"Kenjirou:  Can I talk to you about something?"
	DB	NEXT
	DB	"Terumi:  Sure. Unless you're going to confess your love for me." 
	DB	NEXT
	DB	"Terumi:  No, that's not it..."
	DB	NEXT
	DB	"Terumi:  I know! You want to talk about the girl who was with you in the station. The pretty transfer student..." 
	DB	NEXT
	DB	"Kenjirou:  N- No!"
	DB	NEXT
	DB	"Terumi:  Ah, I think I've hit the bull's-eye."
	DB	NEXT
	DB	"Terumi-senpai looks in my reddening face."
	DB	NEXT
	DB	"Kenjirou:  No, that's not it at all. It's about Motoka."
	DB	NEXT
	DB	"Terumi:  ...What? You're her brother? That's pretty heavy..."
	DB	NEXT
	DB	"Kenjirou:  What are you talking about?"
	DB	NEXT
	DB	"Terumi:  I mean, it's not incest if she's not really a blood relative of yours, but still..." 
	DB	NEXT
	DB	"Kenjirou:  Why do you always assume things like that?"
	DB	NEXT
	DB	"Terumi:  ...Oh. Sorry." 
	DB	T_WAIT,	3
	DB	" So, what about Motoka-chan?"
	DB	NEXT
	DB	"Kenjirou:  She's been ignoring me completely these days."
	DB	NEXT
	DB	"Terumi:  What?"
	DB	NEXT
	DB	"Kenjirou:  I said, she's been ignoring me. Completely. "
	DB	NEXT
	DB	"Terumi:  ...Ah, hahahaha!" 
	DB	NEXT
	DB	"Terumi-senpai opened her mouth and laughed in the middle of the convenience store."
	DB	NEXT
	DB	"Kenjirou:  It's not a laughing matter!"
	DB	NEXT
	DB	"Terumi:  Y- Yes it is!"
	DB	T_WAIT,	2
	DB	" It's so funny!"
	DB	NEXT
	DB	"She held her stomach, laughing more and more."
	DB	NEXT
	DB	"Terumi:  I can't believe that's what you've been upset about..." 
	DB	NEXT
	DB	"Kenjirou:  Yes, well..."
	DB	NEXT
	DB	"Terumi:  Ah, I can't stop laughing." 
	DB	NEXT
	DB	"Kenjirou:  Please listen to me!"
	DB	NEXT
	DB	"Terumi:  You've got a 'sister complex.' Hahaha!"
	DB	NEXT
	DB	"Kenjirou:  Leave me alone!"
	DB	NEXT
	DB	"She started laughing all over again."
	DB	NEXT
	DB	"I guess I shouldn't have said anything to Terumi-senpai..."
	DB	NEXT
	DB	"Kenjirou:  Well, I'll see you later. "
	DB	NEXT
	DB	"Terumi:  Good bye, Mr. sister complex."
	DB	NEXT
	DB	"I left the convenience store alone."
	DB	NEXT
	BAK_INIT	'tb_006',B_NORM
	CDPLAY	2
	DB	"That Terumi-senpai. She's not someone to confide in at all."
	DB	NEXT
	DB	"Thinking about how stupid I was to tell her what was bothering me, I went to school."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_034a',B_NORM
	CDPLAY		23	;`Žu"¿‚Q`
	DB	"The classroom door opened, and Shiho came out."
	DB	NEXT
	T_CG	'tt_02_34a',SIH_A2,0
	DB	"Shiho:  Ah, Kenjirou-kun."
	DB	NEXT
	DB	"Kenjirou:  Good morning. You're here early."
	DB	NEXT
	DB	"Shiho:  Yes, I arrived early today. Well, I'm off to the teacher's room."
	DB	NEXT
	TATI_ERS
	DB	"Shiho left, and I entered the classroom."
	DB	NEXT
	CDPLAY		14
	BAK_INIT	'tb_010',B_NORM
	T_CG	'tt_08_10',TET_A2,0
	DB	"I put my bag on my desk and sat down."
	DB	NEXT
	DB	"Tetsuya:  Good morning."
	DB	NEXT
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Tetsuya:  You don't seem very happy this morning." 
	DB	NEXT
	DB	"Kenjirou:  Really?"
	DB	NEXT
	DB	"Tetsuya:  Are you tired?"
	DB	NEXT
	DB	"Kenjirou:  ...Yes, a little."
	DB	NEXT
	DB	"Tetsuya:  You've been jacking off too much. Got to watch that." 
	DB	NEXT
	DB	"Kenjirou:  You're probably right."
	DB	NEXT
	DB	"Tetsuya:  I'm probably right?" 
	DB	T_WAIT,	3
	DB	"You're supposed to get mad, or something."
	DB	NEXT
	DB	"Kenjirou:  Sorry. I'm just tired."
	DB	NEXT
	DB	"Being laughed at by Terumi-senpai did it..."
	DB	NEXT
	DB	"Tetsuya:  ...I see."
	DB	T_WAIT,	2
	DB	" By the way, there's something I wanted to talk to you about."
	DB	NEXT
	DB	" I can come back."
	DB	NEXT
	TATI_ERS
	DB	"Tetsuya disappears into the back of the classroom."
	DB	NEXT
	F_O B_NORM,C_KURO
	;WAV	'Se_ch'
	CDPLAY		0
	DB	"I put my arms in front of me, preparing for sleep."
	DB	NEXT
	DB	"Kenjirou:  ..........................................................................................................."
	DB	NEXT
	B_O B_FADE,C_KURO
	;WAV	'STOP'
	F_O B_NORM,C_KURO
	DB	"Guess I'll wake up now."
	DB	NEXT
	DB	"I slowly stretch and look around me."
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	CDPLAY		14
	T_CG	'tt_08_11a',TET_A2,0
	DB	"Tetsuya:  You're awake."
	DB	NEXT
	DB	"Looking around, I see no one in the class but Tetsuya."
	DB	NEXT
	DB	"Kenjirou:  Tetsuya."
	DB	NEXT
	DB	"Tetsuya:  Good morning." 
	DB	NEXT
	DB	"Kenjirou:  Oh, that's right. You said there was something you wanted to talk to me about."
	DB	NEXT
	DB	"Tetsuya:  Yes, I was waiting for you wake up."
	DB	NEXT
	DB	"Tetsuya:  Oh, sorry."
	DB	T_WAIT,	3
	DB	" How long did you wait?"
	DB	NEXT
	DB	"Tetsuya:  Oh, about two minutes."
	DB	NEXT
	DB	"Tetsuya:  ...That's not very long."
	DB	NEXT
	DB	"Tetsuya:  I know."
	DB	NEXT
	DB	"Kenjirou:  ..............."
	DB	T_WAIT,	3
	DB	"So? What did you want to talk to me about?"
	DB	NEXT
	DB	"Tetsuya:  Yes, about that..."
	DB	NEXT
	DB	"Kenjirou:  Is it about Tachikawa's adult video?"
	DB	NEXT
	DB	"Tetsuya:  No, not that."
	DB	T_WAIT,	3
	DB	" Do you remember me telling you about Motoka the other day?"
	DB	NEXT
	DB	"Tetsuya:  Yes, you said she was walking with a bad crowd or something."
	DB	NEXT
	DB	"Tetsuya:  Yes, well..." 
	DB	T_WAIT,	3
	DB	" It seems the problem has gotten a little worse."
	DB	NEXT
	DB	"Tetsuya:  I don't care about that. remember, I told you it wasn't her."
	DB	NEXT
	DB	"Tetsuya:  Well, that might have been so, but..."
	DB	NEXT
	DB	"Kenjirou:  But what?"
	DB	NEXT
	DB	"Tetsuya:  Yesterday, I was hanging out in a game center until late, and..."
	DB	NEXT
	DB	"Kenjirou:  ...You're going to turn into one of those bad people you keep spreading rumors about."
	DB	NEXT
	DB	"Tetsuya:  Yes, well. "
	DB	NEXT
	DB	"Tetsuya:  So what does you playing games late at night have to do with Motoka?"
	DB	NEXT
	DB	"Tetsuya:  Just as I came out of the game center..."
	DB	NEXT
	DB	"Tetsuya couldn't go on. I knew what he was going to say next."
	DB	NEXT
	DB	"Kenjirou:  ........."
	DB	T_WAIT,	5
	DB	"I see."
	DB	NEXT
	DB	"Tetsuya:  Ah..."
	DB	T_WAIT,	3
	DB	"But there wasn't a guy with her or anything."
	DB	NEXT
	DB	"Tetsuya:  That's good, at least."
	DB	NEXT
	DB	"Tetsuya:  Yes. It's something."
	DB	NEXT
	DB	"Tetsuya:  Anyway..."
	DB	T_WAIT,	2
	DB	"I'm going to go home now."
	DB	NEXT
	DB	"He headed for the classroom door."
	DB	NEXT
	DB	"Kenjirou:  Tetsuya."
	DB	NEXT
	DB	"Tetsuya:  Yeah?"
	DB	NEXT
	DB	"Kenjirou:  Thanks."
	DB	NEXT
	DB	"Tetsuya:  Oh, it's okay. "
	DB	NEXT
	TATI_ERS
	DB	"He left the room."
	DB	NEXT
	DB	"Before I go home, I'll drop by and see if Motoka's still in her classroom."
	DB	NEXT
	DB	"I head for Motoka's classroom."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_011a',B_NORM
	DB	"Motoka's classroom is empty, not a soul in sight."
	DB	NEXT
	DB	"Kenjirou:  No one here..."
	DB	NEXT
	DB	"She might have gone home. I'll go there and check."
	DB	NEXT
	DB	"I leave the school."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_005a',B_NORM
	DB	"I wonder if she's here..."
	DB	NEXT
	DB	"Now that I think about it, I could have called instead of coming straight here."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_002',B_NORM
	CDPLAY		6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Kenjirou:  I'm home."
	DB	NEXT
	DB	"Akemi:  Welcome home."
	DB	NEXT
	DB	"Kenjirou:  Is Motoka here?"
	DB	NEXT
	DB	"Akemi:  She didn't come home yet."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	T_WAIT,	3
	DB	" Did she call or anything?"
	DB	NEXT
	DB	"Akemi:  No, no call."
	DB	NEXT
	DB	"Kenjirou:  ...I see."
	DB	NEXT
	DB	"Akemi:  But it is only 3:00 in the afternoon."
	DB	NEXT
	DB	"Kenjirou:  That's true."
	DB	NEXT
	DB	"Akemi:  Oh, now I remember. Motoka didn't call, but a boy named Hara or something did."
	DB	NEXT
	DB	"Kenjirou:  H- Hara...?"
	DB	NEXT
	DB	"Shit! That's Hiroshi!"
	DB	NEXT
	DB	"Kenjirou:  And what did this Hara say?"
	DB	NEXT
	DB	"Akemi:  He said, 'Is Motoka there?'"
	DB	T_WAIT,	2
	DB	" That's all."
	DB	NEXT
	DB	"I knew it! He's trying to get my sister...!"
	DB	NEXT
	DB	"I can't let him have her! I've got to protect Motoka!"
	DB	NEXT
	DB	"Kenjirou:  Akemi-san, I'll be back later."
	DB	NEXT
	DB	"Akemi:  Okay. Don't be too late."
	DB	NEXT
	B_O B_FADE,C_KURO
	SINARIO	'MON_25.OVL'
END