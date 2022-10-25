        include SUPER_C.inc
M_START:
MON_42
	FLG_KI	MOTSUNE,'=',2
	FLG_KI	HANAJI,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Guess I'll change and go have breakfast."
	DB	NEXT
	DB	"I pull my uniform on, and head down to the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi-san is here, but I don't see Motoka."
	DB	NEXT
	DB	"Kenjirou:  Akemi-san, where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She left already. She said she had to meet a friend."
	DB	NEXT
	DB	"Kenjirou:  I see. She said she was spending the night at her friend's hose, right?"
	DB	NEXT
	DB	"Akemi:  Yes. But I have to apologize to you..."
	DB	NEXT
	DB	"Kenjirou:  Why?"
	DB	NEXT
	DB	"Akemi:  I've got to be out tonight, too."
	DB	NEXT
	DB	"Kenjirou:  Really? Why?"
	DB	NEXT
	DB	"Akemi:  There's an all-night vigil. "
	DB	NEXT
	DB	"Kenjirou:  Really? Did someone die?"
	DB	NEXT
	DB	"Akemi:  Yes, the father of an old friend. So I'll be out tonight."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"Akemi:  If you could get dinner at a convenience store or someplace, I'd appreciate it."
	DB	NEXT
	DB	"Kenjirou:  Sure. I guess I'd better be off now."
	DB	NEXT
	DB	"Akemi:  Here's some money for dinner." 
	DB	NEXT
	DB	"Akemi gives me 1000 yen."
	DB	NEXT
	DB	"Kenjirou:  Oh, it's okay. I have money."
	DB	NEXT
	DB	"Akemi:  Just think of it as money for babysitting yourself."
	DB	NEXT
	DB	"Kenjirou:  Okay, then I'll take it."
	DB	NEXT
	DB	"I take the offered money, and leave the dining kitchen."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_006',B_NORM
	CDPLAY	2
	DB	"I stop off at the convenience store. I always buy my lunch here for 500 yen or less."
	DB	NEXT
	BAK_INIT	'tb_007',B_NORM
	DB	"I don't see Terumi-senpai here today."
	DB	NEXT
	DB	"I can't blame her..."
	DB	NEXT
	DB	"I buy my lunch (500 yen or less) and head for school."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_009',B_NORM
	DB	"It's crowded..."
	DB	NEXT
	DB	"I don't really want to eat dinner from the convenience store. I guess it's better than having Motoka make something, though."
	DB	NEXT
	DB	"Voice:  Kenjirou-kun..."
	DB	NEXT
	DB	"I turn around to see who the owner of the voice might be."
	DB	NEXT
	CDPLAY	23
	T_CG	'tt_02_09',SIH_A2,0
	DB	"Shiho:  Kenjirou-kun, good morning." 
	DB	NEXT
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Shiho:  ...You don't seem very happy today." 
	DB	NEXT
	DB	"Kenjirou:  Oh, I was thinking about something."
	DB	NEXT
	DB	"Shiho:  Is something wrong?" 
	DB	NEXT
	DB	"Kenjirou:  Oh, Akemi-san and Motoka will be out of the house this evening, so I was wondering what to do about dinner."
	DB	NEXT
	DB	"Shiho:  Oh, is that all?" 
	DB	NEXT
	DB	"Kenjirou:  It's a big deal to me. "
	DB	NEXT
	DB	"Shiho:  Haha... Sorry, it's kind of funny. Shall we go to school?"
	DB	NEXT
	DB	"Kenjirou:  Yes, let's."
	DB	NEXT
	DB	"I head for school with Shiho."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	23
	T_CG	'tt_02_10',SIH_A3,0
	T_CG	'tt_08_10',TET_A1,0
	DB	"Tetsuya:  Good morning, Kashima-san."
	DB	NEXT
	DB	"Shiho:  Good morning."
	DB	NEXT
	DB	"Kenjirou:  Hey..."
	DB	T_WAIT,	3
	DB	" What about me?"
	DB	NEXT
	DB	"Tetsuya:  Oh, Kenjirou. You're here."
	DB	NEXT
	DB	"Kenjirou:  Now wait a minute..."
	DB	NEXT
	DB	"Suddenly the bell rang. Time for class."
	DB	NEXT
	;WAV		'Se_ch'
	DB	"Shiho:  You should sit down."
	DB	NEXT
	DB	"Tetsuya:  Yes, we should."
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  ...I'll sit down, too."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"I stare blankly at the blackboard, wondering what the point of education is."
	DB	NEXT
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	CDPLAY	14
	DB	"Ahh, time to wake up."
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	T_CG	'tt_02_11a',SIH_A2,0
	DB	"Shiho is here."
	DB	NEXT
	DB	"Kenjirou:  Huh? Where's Tetsuya?"
	DB	NEXT
	DB	"Shiho:  You'd rather talk to him than me?" 
	DB	NEXT
	DB	"Kenjirou:  No, you. Definitely."
	DB	NEXT
	DB	"Shiho:  ..............." 
	DB	NEXT
	DB	"At my words, Shiho's face turns crimson, and she averts her eyes."
	DB	NEXT
	DB	"Kenjirou:  Aren't you going to play piano today?"
	DB	NEXT
	DB	"Shiho:  Eh? Oh, I..."
	DB	T_WAIT,	3
	DB	" Er, Kenjirou-kun? I was wondering..."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Shiho:  Um, well... Shall I make dinner for you tonight?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? You'll do that for me?"
	DB	NEXT
	DB	"Shiho:  I mean, if it's too much trouble, I don't mind..." 
	DB	NEXT
	DB	"Kenjirou:  No, it's no trouble at all. I'd love to have you cook for me."
	DB	NEXT
	DB	"Shiho:  Really?" 
	DB	NEXT
	DB	"Kenjirou:  Yes. Will you come over now?"
	DB	NEXT
	DB	"Shiho:  No, I've got to buy some food first."
	DB	NEXT
	DB	"Kenjirou:  Oh. Well, shall we meet someplace?"
	DB	NEXT
	DB	"Shiho:  Don't worry. I know where you live."
	DB	NEXT
	DB	"Kenjirou:  You do?"
	DB	NEXT
	DB	"Shiho:  Ah..."
	DB	T_WAIT,	3
	DB	" You know, when I transferred here, I got a list of all the students, with addresses."
	DB	NEXT
	DB	"Kenjirou:  You know where I live just from my address? Shouldn't I draw a map?"
	DB	NEXT
	DB	"Shiho:  No, I know." 
	DB	NEXT
	DB	"Kenjirou:  ...Okay. I'll be waiting, then."
	DB	NEXT
	DB	"Shiho:  Okay. I'll see you in a little bit."
	DB	NEXT
	DB	"Shiho waved goodbye, and left the room."
	DB	NEXT
	DB	"Kenjirou:  I'd better go home and clean my room."
	DB	NEXT
	DB	"I leave the room and head home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001a',B_FADE
	CDPLAY	12
	DB	"After changing clothes, I begin to clean my room."
	DB	NEXT
	DB	"Kenjirou:  It's pretty dirty in here..."
	DB	NEXT
	DB	"I pick up magazines and dirty laundry that lie on the floor, and put them under the bed."
	DB	NEXT
	DB	"Kenjirou:  Perfect. Now to tidy up the dining kitchen. It wouldn't do to have her cooking in a dirty kitchen."
	DB	NEXT
	DB	"I head for the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY		0
	DB	"Hmm... Where do I start?"
	DB	NEXT
	DB	"I look around the dining kitchen. There is no trash anywhere to be seen."
	DB	NEXT
	DB	"Akemi-san keeps this place pretty clean."
	DB	NEXT
	DB	"I look around some more, finding only one hair on the floor. I throw it in the trash."
	DB	NEXT
	DB	"This is a waste of time."
	DB	NEXT
	DB	"Just then, I hear the doorbell."
	DB	NEXT
	DB	"Kenjirou:  That must be Shiho."
	DB	NEXT
	DB	"I head for the foyer."
	DB	NEXT
	BAK_INIT	'tb_005b',B_NORM
	CDPLAY	23
	T_CG	'tt_01_05b',SIH_A2,0
	DB	"Shiho:  Am I too early?"
	DB	NEXT
	DB	"The setting sun paints the sky a brilliant orange, as Shiho appears, in a pretty pink one-piece dress."
	DB	NEXT
	DB	"Kenjirou:  Hmm, a little."
	DB	NEXT
	DB	"Shiho:  I'm sorry." 
	DB	NEXT
	DB	"Kenjirou:  Don't worry about it. Come on in, and make yourself at home."
	DB	NEXT
	DB	"Shiho:  Thanks." 
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	T_CG	'tt_01_02',SIH_A2,0
	DB	"Shiho:  I'll get started right away."
	DB	NEXT
	DB	"Kenjirou:  What can I be doing to help?"
	DB	NEXT
	DB	"Shiho:  You don't have to do anything. Just sit down and wait." 
	DB	NEXT
	DB	"Kenjirou:  But that's not fair to you..."
	DB	NEXT
	DB	"Shiho:  It's okay. The kitchen is a place for women." 
	DB	NEXT
	DB	"Hmm, she might be right. I might just get in the way."
	DB	NEXT
	DB	"Kenjirou:  Okay, I'll leave everything up to you."
	DB	NEXT
	DB	"Shiho:  Thanks." 
	DB	NEXT
	TATI_ERS
	DB	"Shiho starts unpacking food from a plastic supermarket bag."
	DB	NEXT
	DB	"I do as I'm told, and sit at the table."
	DB	NEXT
	DB	"Soon I hear the sound of a knife cutting."
	DB	NEXT
	DB	"Kenjirou:  Ah... This is great..."
	DB	NEXT
	DB	"Motoka:  I'm home."
	DB	NEXT
	DB	"From the foyer, I hear Motoka's voice."
	DB	NEXT
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A3,0
	DB	"Motoka:  Oniichan, I'm here to make dinner for you."
	DB	NEXT
	DB	"Kenjirou:  M- Motoka? Aren't you staying at a friend's house tonight?" 
	DB	NEXT
	DB	"Motoka:  Yes, but Mom's not home either, right? So I cancelled it and came home." 
	DB	NEXT
	DB	"Shiho:  Ah, hello."
	DB	NEXT
	DB	NEXT
	TATI_ERS
	CDPLAY	20
	T_CG	'tt_21_02',MOT_B3,0
	T_CG	'tt_01_02',SIH_A1,0
	DB	"Motoka:  ............"
	DB	NEXT
	DB	"Shiho:  I'll make dinner for you, too, Motoka-chan." 
	DB	NEXT
	DB	"Motoka:  .....I don't need any." 
	DB	NEXT
	TATI_ERS
	CDPLAY	23
	T_CG	'tt_01_02',SIH_A1,0
	DB	"Motoka runs out of the dining kitchen."
	DB	NEXT
	DB	"Kenjirou:  Motoka!"
	DB	NEXT
	DB	"I start to run after Motoka, but am stopped by Shiho's voice behind me."
	DB	NEXT
	DB	"Shiho:  ...I guess I did something wrong..." 
	DB	NEXT
	DB	"I turn around, and see Shiho standing in the doorway."
	DB	NEXT
	DB	"Kenjirou:  I'm sorry for the trouble. I'll explain everything to her later."
	DB	NEXT
	DB	"Shiho:  I- It's okay. She'll feel awkward if you do that." 
	DB	NEXT
	DB	"Kenjirou:  ...Okay."
	DB	NEXT
	DB	"Shiho:  I'll get back to making dinner." 
	DB	NEXT
	TATI_ERS
	DB	"Shiho returns to the kitchen."
	DB	NEXT
	DB	"Darn that Motoka. Now the mood is lost. Well... I am happy that she came home to make dinner for me."
	DB	NEXT
	DB	"Shiho:  ... Kenjirou-kun, it's ready."
	DB	NEXT
	T_CG	'tt_01_02',SIH_A2,0
	DB	"Kenjirou:  Oh! I'm hungry."
	DB	NEXT
	DB	"Shiho waits for me, a smile on her face."
	DB	NEXT
	DB	"Kenjirou:  Oh! Chicken!"
	DB	NEXT
	DB	"Shiho:  You like chicken, right?"
	DB	NEXT
	DB	"Kenjirou:  Yes. How did you know?"
	DB	NEXT
	DB	"Shiho:  I can tell from your face. You looked so happy just now."
	DB	NEXT
	DB	"Kenjirou:  I did?"
	DB	NEXT
	DB	"Shiho:  Yes." 
	DB	T_WAIT, 3
	DB	" But why don't you try some?"
	DB	NEXT
	DB	"Kenjirou:  Okay, thanks."
	DB	NEXT
	DB	"I put my hands together, and say 'itadakimasu.' "
	DB	NEXT
	DB	"After my first taste of Shiho's chicken, I catch my breath."
	DB	NEXT
	DB	"Shiho:  Does it taste bad?"
	DB	NEXT
	DB	"Shiho looks at me, worry in her eyes."
	DB	NEXT
	DB	"Kenjirou:  It's delicious. I was just surprised, since it was so incredibly good."
	DB	NEXT
	DB	"Shiho:  ...You're getting a little carried away there." 
	DB	NEXT
	DB	"At my lie, Shiho's cheeks turned slightly red, and she looked at her shoes."
	DB	NEXT
	DB	"I was exaggerating, but Shiho's chicken was really good. It made me feel I had eaten it before, sometime."
	DB	NEXT
	DB	"I wonder why I think I've eaten this before. It tastes...like what my mother used to make..."
	DB	NEXT
	DB	"Shiho:  ...Does it taste funny?"
	DB	NEXT
	DB	"Kenjirou:  No, it's really good. Really."
	DB	NEXT
	DB	"Shiho finally appeared to relax, as I wolfed down more of her chicken."
	DB	NEXT
	DB	"Finally, a smile appeared on her face as she watched me eat."
	DB	NEXT
	DB	"Then I noticed something odd."
	DB	NEXT
	DB	"Kenjirou:  Shiho, aren't you going to eat, too?" 
	DB	NEXT
	DB	"Shiho:  Me?" 
	DB	T_WAIT, 3
	DB	" I don't need any."
	DB	NEXT
	DB	"Kenjirou:  Why not?"
	DB	NEXT
	DB	"Shiho:  ...I'm not hungry. It's enough for me to watch you eat." 
	DB	NEXT
	DB	"Huh? For some reason, I get the feeling that this situation has happened before..."
	DB	NEXT
	DB	"Shiho:  What's wrong?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, I was just getting deja-vu for a second."
	DB	NEXT
	DB	"Shiho:  Really?" 
	DB	NEXT
	DB	"Kenjirou:  Yes. I'm, sure it's all in my mind."
	DB	NEXT
	DB	"As if to remove the strange feeling, I once again start to eat."
	DB	NEXT
	DB	"Shiho continued to watch me, but her smile of a few moments ago was gone."
	DB	NEXT
	DB	"When I finish, Shiho cleans up."
	DB	NEXT
	DB	"Shiho:  Well, I'm going home now." 
	DB	NEXT
	DB	"Kenjirou:  Eh? Already?"
	DB	NEXT
	DB	"I look at the clock. It reads 7:30 pm."
	DB	NEXT
	DB	"I follow her to the door."
	DB	NEXT
	BAK_INIT	'tb_005c',B_NORM
	T_CG	'tt_01_05c',SIH_A2,0
	DB	"Kenjirou:  I'll walk you to the station."
	DB	NEXT
	DB	"Shiho:  Thanks."
	DB	T_WAIT, 3
	DB	" But I can go home alone."
	DB	NEXT
	DB	"Kenjirou:  No, I don't mind."
	DB	NEXT
	DB	"Shiho:  I really..." 
	DB	T_WAIT, 3
	DB	" I'll be fine alone. I'll see you tomorrow."
	DB	NEXT
	DB	"She takes a few steps out the door, and smiles back to me."
	DB	NEXT
	DB	"Kenjirou:  Ah, okay. I'll see you tomorrow."
	DB	NEXT
	TATI_ERS
	DB	"I lamely wave goodbye."
	DB	NEXT
	DB	"Kenjirou:  Guess I'll go back in."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	DB	"Back inside, I remember Shiho's dinner."
	DB	NEXT
	DB	"I'm sure I've tasted that cooking before. But where?"
	DB	NEXT
	DB	"Kenjirou:  Oh well. "
	DB	NEXT
	DB	"I wonder what's wrong with Motoka. She probably got the wrong idea about Shiho and me."
	DB	NEXT
	DB	"Kenjirou:  I guess I'll go see Motoka."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"I knock on Motoka's door."
	DB	NEXT
	;WAV	'Se_no'
	DB	"But there's no answer."
	DB	NEXT
	DB	"Kenjirou:  Motoka."
	DB	NEXT
	DB	"I call her name, not hearing anything. I move to open the door."
	DB	NEXT
	DB	"Kenjirou:  Huh? It's locked."
	DB	NEXT
	DB	"I knock again, but give up, deciding that she must be asleep."
	DB	NEXT
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"I guess I'll have a talk with Motoka tomorrow."
	DB	NEXT
	DB	"I get into my pajamas, and climb into bed. But sleep alludes me."
	DB	NEXT
	DB	"It seems that I've forgotten something, recently. I wonder if that's possible?"
	DB	NEXT
	DB	"Kenjirou:  ......................"
	DB	NEXT
	DB	"...I can't remember."
	DB	NEXT
	DB	"Sometime later, I fall asleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	CDPLAY		0
	FLG_KI		HIDUKE,'+',1
	SINARIO	'MON_43.OVL'
	DB	EXIT
END