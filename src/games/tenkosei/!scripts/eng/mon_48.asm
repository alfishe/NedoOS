        include SUPER_C.inc
M_START:
MON_48
	FLG_IF JUMP,'=',99,FF_2
	FLG_IF JUMP,'=',98,FF_1
	FLG_KI JUMP,'=',98
	SINARIO 'NITI_ASA.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',99
	SINARIO 'NITI_HIR.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"Time to get up."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	DB	"Today's the day I'm going to listen to Shiho's piano playing."
	DB	NEXT
	CDPLAY	23
	T_CG	'tt_02_10',SIH_A2,0
	DB	"Shiho:  Kenjirou-kun, excuse me."
	DB	NEXT
	DB	"She'll approach me, I think."
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Shiho:  It's time." 
	DB	T_WAIT,	3
	DB	" Are you listening to me?"
	DB	NEXT
	DB	"Shiho looks around nervously as she speaks to me. Her cheeks redden slightly."
	DB	NEXT
	FLG_IF	TER_YATT,'=',1,AITENAI
	FLG_IF	MOT_YATT,'=',1,AITENAI
	FLG_IF	AKE_YARU,'=',1,AITENAI
	FLG_IF	RISA_SYO,'=',1,AITENAI
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	ISOG,"I DON'T HAVE TIME"
	MENU_SET	HIMA,"SURE- I'VE GOT TIME"
	MENU_END
	DB	EXIT
ISOG:
	SINARIO	'BUNKI_2.OVL'
HIMA:
	DB	"Kenjirou:  Sure, I've got lots of free time."
	DB	NEXT
	DB	"Shiho:  I made a new song. Would you... Would you listen to it, and tell me what you think?"
	DB	NEXT
	DB	"Kenjirou:  Sure, I'd love to."
	DB	NEXT
	DB	"Shiho:  Really?" 
	DB	NEXT
	DB	"Kenjirou:  I like to hear you play, and a new song? I'd love to hear that."
	DB	NEXT
	DB	"Shiho:  I- It's nothing special, really..." 
	DB	NEXT
	DB	"We head for the music room."
	DB	NEXT
	DB	"I hope that Tetsuya doesn't see us. He would get the wrong idea."
	DB	NEXT
	BAK_INIT	'tb_016',B_NORM
	CDPLAY	10
	T_CG	'tt_02_16',SIH_A2,0
	DB	"Wow, we're alone here..."
	DB	NEXT
	DB	"Kenjirou:  H- Hey, Shiho."
	DB	NEXT
	TATI_ERS
	DB	"What?"
	DB	NEXT
	DB	"In the blink of an eye, Shiho was seated at the piano."
	DB	NEXT
	DB	"But she was standing right beside me a second ago."
	DB	NEXT
	EVENT_CG	'ti_049',B_NORM,74
	DB	"Shiho:  Yes? What is it?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, never mind."
	DB	NEXT
	DB	"I watched her silently as she readied herself and began to play."
	DB	NEXT
	CDPLAY	21
	DB	"Kenjirou:  ..........................."
	DB	NEXT
	DB	"This is the first time I've heard this song. Wow, it's really good."
	DB	NEXT
	DB	"I watch her quietly and wait for her to finish."
	DB	NEXT
	DB	"Shiho:  Well, that's it. Did you..." 
	DB	T_WAIT,	3
	DB	" Did you like it?"
	DB	NEXT
	CDPLAY	10
	DB	"Kenjirou:  Yes. What I mean is, I don't really understand the mechanics of songwriting themselves, but I really like the song."
	DB	NEXT
	DB	"Shiho:  Really?"
	DB	NEXT
	DB	"Kenjirou:  Yes."
	DB	NEXT
	DB	"Shiho:  I'm so glad..." 
	DB	NEXT
	DB	"Kenjirou:  There's something I want to talk to you about. Is this a good time?"
	DB	NEXT
	DB	"Shiho:  Eh? Sure, go ahead."
	DB	NEXT
	DB	"Kenjirou:  .....Well, Shiho... I, um..."
	DB	NEXT
	DB	"Shiho:  ................." 
	DB	NEXT
	DB	"Kenjirou:  How can I put this?"
	DB	NEXT
	DB	"Shiho:  I'm listening." 
	DB	NEXT
	DB	"Kenjirou:  Will you promise not to laugh?"
	DB	NEXT
	DB	"Shiho:  Sure...."
	DB	NEXT
	DB	"Kenjirou:  It's strange, but you're the perfect girl for me, in every way..."
	DB	NEXT
	DB	"Shiho:  .....You finally..." 
	DB	T_WAIT,	10
	DB	"You finally noticed..."
	DB	NEXT
	DB	"Kenjirou:  .....Shiho?"
	DB	T_WAIT,	3
	DB	"Noticed what?"
	DB	NEXT
	DB	"Tears appeared in Shiho's eyes, and she nodded without saying anything."
	DB	NEXT
	DB	"Shiho:  I waited... I wanted so long, for you to notice how I felt about you..." 
	DB	NEXT
	DB	"Large teardrops begin to roll down Shiho's cheeks now."
	DB	NEXT
	DB	"Shiho:  The song I wrote... It was a song of 'sayonara.'" 
	DB	NEXT
	DB	"Kenjirou:  Sayonara?"
	DB	NEXT
	DB	"Shiho:  I've got to leave here soon. I can't stay."
	DB	T_WAIT,	3
	DB	" So it's a song to say goodbye."
	DB	NEXT
	DB	"Kenjirou:  You can't stay...?!"
	DB	NEXT
	DB	"Shiho:  ...My time limit... " 
	DB	T_WAIT,	3
	DB	"It ends today."
	DB	NEXT
	DB	"Kenjirou:  I don't pretend to understand what you're talking about -- are you saying we can't see each other anymore?"
	DB	NEXT
	DB	"Shiho:  Not in your time, that is." 
	DB	NEXT
	DB	"Kenjirou:  ................"
	DB	NEXT
	DB	"Shiho:  But we can meet... in your dream world." 
	DB	NEXT
	DB	"In my dream world... When she spoke those words to me, I knew for the first time that the "
        DB      "transfer student Shiho and my dream Shiho were one and the same person after all."
	DB	NEXT
	DB	"Her words echoed inside my head."
	DB	NEXT
	DB	"The day Shiho appeared to me, and told me she wanted me to remember her forever..."
	DB	NEXT
	DB	"Kenjirou:  Shiho... I'm so sorry."
	DB	NEXT
	DB	"Shiho:  Eh?" 
	DB	NEXT
	DB	"Kenjirou:  You told me not to forget you. But I..."
	DB	NEXT
	DB	"Shiho:  It can't be helped. That's the way it is." 
	DB	NEXT
	DB	"Kenjirou:  Is there really nothing we can do?"
	DB	NEXT
	DB	"Shiho:  ........................" 
	DB	NEXT
	DB	"She shook her head."
	DB	NEXT
	DB	"Shiho:  No. The process has already started. Soon, you'll forget me entirely." 
	DB	NEXT
	DB	"Kenjirou:  ...................."
	DB	NEXT
	DB	"Shiho:  Do you remember the day I transferred here? What was the date?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? It was April... April..." 
	DB	NEXT
	DB	"Shiho:  You don't remember, do you?" 
	DB	NEXT
	DB	"Kenjirou:  ....No."
	DB	NEXT
	DB	"Shiho:  But it was because you gave me some of your strength that I was able to "
        DB      "stay as long as I did. I was really supposed to go home much earlier." 
	DB	NEXT
	DB	"I gave her strength? Oh, I remember now. When I met her, there were a few times I didn't feel sexually aroused for her."
	DB	NEXT
	DB	"Shiho:  I'm sorry." 
	DB	NEXT
	DB	"Kenjirou:  Why?"
	DB	NEXT
	DB	"Shiho:  I should have spoken..."
	DB	NEXT
	DB	"Without saying anything, I hugged Shiho from behind."
	DB	NEXT
	DB	"Kenjirou:  It's okay. You had a reason, right?"
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Shiho:  I've got to go now." 
	DB	NEXT
	DB	"Kenjirou:  Don't go, Shiho."
	DB	NEXT
	DB	"Shiho:  It's, it's not like I want to go. I want..." 
	DB	T_WAIT,	3
	DB	" I want to stay by your side, forever."
	DB	NEXT
	DB	"Kenjirou:  Then don't go."
	DB	NEXT
	DB	"Shiho:  This is something... I can't do anything about!" 
	DB	NEXT
	DB	"Kenjirou:  I don't care. Stay with me."
	DB	NEXT
	DB	"Shiho:  Please, don't ask...don't ask me to do things...that I can't do!" 
	DB	NEXT
	DB	"Kenjirou:  ..................."
	DB	NEXT
	DB	NEXT
	EVENT_CG	'th_124',B_NORM,64
	CDPLAY	5
	DB	"Shiho:  Ah... N- No, you can't..." 
	DB	NEXT
	DB	"Kenjirou:  ...It's not impossible, right? I can still touch you in this world."
	DB	NEXT
	DB	"Shiho:  T- That's true, but..." 
	DB	NEXT
	DB	"Kenjirou:  I want to make love. With you."
	DB	NEXT
	DB	"As I spoke the words, I moved my other hand to her bosom, touching them and covering them with my hands."
	DB	NEXT
	DB	"The feel of her soft breasts through her blazer was slowly arousing me."
	DB	NEXT
	DB	"Kenjirou:  Shiho, I want you to be my first..."
	DB	NEXT
	DB	"I confessed to her my virginity, and offered it to her."
	DB	NEXT
	DB	"I had been with Shiho on several occasions, but only in the secret world of my imagination."
	DB	NEXT
	DB	"If I let Shiho go now, my first experience would be with some other girl. "
        DB      "Some other girl... This seemed somehow to be a sin to me."
	DB	NEXT
	DB	"I didn't want to be with any other woman, if Shiho wasn't my first lover."
	DB	NEXT
	DB	"Shiho:  I shouldn't agree to this, but..." 
	DB	NEXT
	DB	"Shiho:  Okay."
	DB	NEXT
	DB	"Upon hearing her words, my right hand immediately moved down towards her skirt, searching for the softness within."
	DB	NEXT
	DB	"Shiho:  Ah..." 
	DB	NEXT
	DB	"The warm slit I found between her legs was slippery and wet, perhaps as a side effect of her passionate piano playing earlier."
	DB	NEXT
	DB	"Kenjirou:  Shiho... You're wet."
	DB	NEXT
	DB	"Shiho:  Don't say things like that to me..." 
	DB	NEXT
	DB	"I pushed the tip of my finger into her pussy, and felt a great deal of resistance, denying my entrance."
	DB	NEXT
	DB	"At my finger motions, Shiho's body moved as though with an electric shock."
	DB	NEXT
	DB	"Kenjirou:  Relax a little."
	DB	NEXT
	DB	"Through her panties, I stroked the soft flesh on the sides of her womanhood."
	DB	NEXT
	DB	"Moving my finger through her underpants again, I find the fuzzy softness of her pussy hair."
	DB	NEXT
	DB	"Shiho:  Ah...ahhhn... Okay, I'll try to relax my legs." 
	DB	NEXT
	DB	"She relaxed, and opened her legs farther for me."
	DB	NEXT
	DB	"Once again, I move my fingers inside her panties to softly stroke her wet slit."
	DB	NEXT
	DB	"Shiho:  Ahhhnnn..."
	DB	NEXT
	DB	"The sweet cat-like sound emitted by Shiho made me bold."
	DB	NEXT
	DB	"Kenjirou:  Shiho..."
	DB	NEXT
	DB	"She turned to me, and her eyes were wet with tears."
	DB	NEXT
	DB	"I kissed her sweetly, as my finger was continuing its delicate probing of her virgin flesh."
	DB	NEXT
	DB	"Shiho:  Ahhhnn... Oh, Kenjirou-kun..." 
	DB	NEXT
	DB	"The crotch of her panties was now completely damp, as her sexual excitement grew."
	DB	NEXT
	DB	"I slowly inserted my finger inside her again, first my fingertip again, then the rest of the way."
	DB	NEXT
	DB	"Shiho:  Ahh! Ahhhn! .... Kenjirou-kun..."
	DB	NEXT
	DB	"Her pussy was twitching and blood-engorged. I now pulled my hand away and moved up to her hot nipples."
	DB	NEXT
	DB	"More tears were visible in her eyes. She looked at me with solemn, knowing eyes."
	DB	NEXT
	DB	"It was hard to notice at first, but as she pressed against me, I could feel that "
        DB      "she was somehow lighter, less substantial. It was beginning."
	DB	NEXT
	DB	"Kenjirou:  Shiho... You're..."
	DB	NEXT
	DB	"Shiho:  My body is starting to return. I'm fading away, Kenjirou-kun." 
	DB	NEXT
	DB	"Her sad face cause a stab of pain in my heart. I pulled her to me violently, and resumed touching her."
	DB	NEXT
	DB	"Shiho:  Ahh! Ahhhn! Kenjirou-kun...!" 
	DB	NEXT
	DB	"I slowly moved her back against the piano. She moved against the keyboard, causing a loud sound."
	DB	NEXT
	EVENT_CG	'th_125',B_NORM,65
	DB	"Laying her back on the piano now, I lifted up one leg, and began rolling up her skirt. "
        DB      "One of Shiho's shoes fell onto the floor with a thud."
	DB	NEXT
	DB	"Her white cotton panties, clearly damp now, lie before me."
	DB	NEXT
	DB	"I brought my face to the area of her pussy, smelling the female smells that originated there."
	DB	NEXT
	DB	"Shiho:  ...No, don't smell down there." 
	DB	NEXT
	DB	"Kenjirou:  It's a good smell, Shiho. Open your legs for me."
	DB	NEXT
	DB	"Shiho:  Eh? But..." 
	DB	NEXT
	DB	"Kenjirou:  Hurry. We don't have much time."
	DB	NEXT
	DB	"Shiho:  O- Okay." 
	DB	NEXT
	DB	"She slowly opened her legs, opening her pussy area fully to me."
	DB	NEXT
	DB	"The female smell that wafts from her pussy increases in strength."
	DB	NEXT
	DB	"I begin to poke at the twitching dampness of her pussy with a finger, "
        DB      "seeing her pink lips through the damp fabric of her panties."
	DB	NEXT
	DB	"Shiho:  Kenjirou-kun, please...I'm too embarrassed..." 
	DB	NEXT
	DB	"Ignoring her pleas to stop, I start stimulating her pussy with my tongue, finding the hard knot of her clit almost immediately."
	DB	NEXT
	DB	"Shiho:  N- No! It's too dirty...! Ahhn!" 
	DB	NEXT
	DB	"She shuddered again, a mini-orgasm. At the same moment, a hot, yellow liquid "
        DB      "stains the whiteness of her panties as her bladder lets go."
	DB	NEXT
	DB	"Shiho:  Ahhh... I can't believe I did that. I'm sorry." 
	DB	NEXT
	DB	"Her pussy continued twitching with excitement."
	DB	NEXT
	DB	"The sweet ammonia smell of Shiho's urine is added to the smells assaulting me."
	DB	NEXT
	DB	"Kenjirou:  Did it feel good enough for you to wet yourself?"
	DB	NEXT
	DB	"She nodded once, slowly."
	DB	NEXT
	DB	"Kenjirou:  Don't worry about it. "
	DB	NEXT
	DB	"Shiho:  But it's..." 
	DB	NEXT
	DB	"I took my hand away from her pussy, and began taking her blouse off. The feel of her soft breasts through her bra was wonderful."
	DB	NEXT
	DB	"Shiho:  Haah! Ahhnnn!" 
	DB	NEXT
	DB	"I removed her bra, and began stimulating her bare nipples."
	DB	NEXT
	DB	"Shiho:  Hyaa! Ahhnnn...!"
	DB	NEXT
	DB	"Her pussy continued twitching, wanting."
	DB	NEXT
	DB	"I moved her strangely light body to mine, and picked her up, ignoring the strange feeling of her insubstantial ness."
	DB	NEXT
	DB	"I tried to stand her up, but she had no strength in her legs. She fell back against the piano keyboard."
	DB	NEXT
	EVENT_CG	'th_126',B_NORM,66
	DB	"Shiho:  Ah..." 
	DB	NEXT
	DB	"Kenjirou:  Your panties. Take them off."
	DB	NEXT
	DB	"Slowly she submitted, moving her panties down to her knees, then down to her ankles."
	DB	NEXT
	DB	"I looked at the lining of her panties, seeing the yellow stain."
	DB	NEXT
	DB	"But there was another stain on her panties, from the leaking excitement of her pussy. I pointed this out to her."
	DB	NEXT
	DB	"Shiho:  Kenjirou-kun! Y- You're such a pervert..." 
	DB	NEXT
	DB	"She tried to hide her panties so that I couldn't see the inner lining, but lacked the balance."
	DB	NEXT
	DB	"Kenjirou:  Open your legs, Shiho. I want to see it all."
	DB	NEXT
	DB	"Shiho:  I'm sorry..." 
	DB	NEXT
	DB	"Around the bottom of her pussy there was no hair to be seen. Only on a the top, a small patch that I had felt earlier."
	DB	NEXT
	DB	"I reached out a hand to stroke her yearning pussy."
	DB	NEXT
	DB	"Slowly I moved the flesh of her apart, to see the full pink glory of her slit."
	DB	NEXT
	DB	"Kenjirou:  Shiho, you're beautiful..."
	DB	NEXT
	DB	"Shiho:  Kenjirou-kun, this is so embarrassing..." 
	DB	NEXT
	DB	"I look and see that a tiny part of her inner lip is poking outside to greet me. "
        DB      "I fold the flesh back, exposing her rock-hard clitoris to the air."
	DB	NEXT
	DB	"Shiho:  Fuuu...nnn..." 
	DB	NEXT
	DB	"Her clit is large, hard, and poking up above the surrounding terrain."
	DB	NEXT
	DB	"Shiho:  Ahhn!"
	DB	NEXT
	DB	"She moves her body upwards in reaction to my probing."
	DB	NEXT
	DB	"I begin to lick her willing pussy, lapping softly like a cat."
	DB	NEXT
	DB	"I move the tip of my tongue to her urethra, tasting the saltiness there."
	DB	NEXT
	DB	"Shiho:  N- No..." 
	DB	NEXT
	DB	"Kenjirou:  You just peed. I have to clean it up for you."
	DB	NEXT
	DB	"Shiho:  N- No! Stop it, Kenjirou-kun...ahhh!!" 
	DB	NEXT
	DB	"Kenjirou:  Thought so."
	DB	NEXT
	DB	"I continued my thorough cleaning of her urethra area."
	DB	NEXT
	DB	"Her piss-hole clean, I moved down to her pussy proper and continued my lapping."
	DB	NEXT
	DB	"Shiho:  Ah, no, that's too good...!" 
	DB	NEXT
	DB	"I ignored her, moving my tongue slowly down, sliding it between the fleshy folds of her most private place."
	DB	NEXT
	DB	"Her pussy, slightly sepia-colored, accepted my tongue."
	DB	NEXT
	DB	"Moving it out again, I started licking the opening to her pussy with the large, flat part of my tongue."
	DB	NEXT
	DB	"Shiho:  T- That tickles!" 
	DB	NEXT
	DB	"Shiho begins to move in response to my tongue movements, increasing her sensation all the more."
	DB	NEXT
	DB	"Kenjirou:  What's wrong? Do you want me to lick you anywhere else?"
	DB	NEXT
	DB	"Shiho:  I- I can't..." 
	DB	NEXT
	DB	"Kenjirou:  How about here?"
	DB	NEXT
	DB	"I put my tongue inside her pussy again, pushing it up as far as I could go, "
        DB      "feeling an immediate flood of lubricant from inside her."
	DB	NEXT
	DB	"Shiho:  Ahh...ahh..." 
	DB	NEXT
	DB	"Kenjirou:  Did you like that?"
	DB	NEXT
	DB	"Shiho:  ..................." 
	DB	NEXT
	DB	"She nodded once."
	DB	NEXT
	DB	"Kenjirou:  Then I'll do it some more."
	DB	NEXT
	DB	"I repeated my attack, bringing even more lubricant from her."
	DB	NEXT
	DB	"Shiho:  Mmm! Ahh...!" 
	DB	NEXT
	DB	"Harder and harder her clit grew. I verified its hardness with the tip of my tongue."
	DB	NEXT
	DB	"Shiho:  Kyaa!"
	DB	NEXT
	DB	"Her lower back moved up and back again."
	DB	NEXT
	DB	"As she did this, she hit the keyboard again, causing a thunderous sound."
	DB	NEXT
	DB	"Shiho:  P- Please... It's time..." 
	DB	NEXT
	DB	"Kenjirou:  Time? Time for what?"
	DB	NEXT
	DB	"Shiho:  Don't make me say it." 
	DB	NEXT
	DB	"Kenjirou:  Is this what you're talking about?"
	DB	NEXT
	DB	"I brought my hardened cock out of my pants, and brought it to her pussy, teasing her slit with the tip."
	DB	NEXT
	DB	"Shiho:  Haa! Haaaa!"
	DB	NEXT
	DB	"Kenjirou:  Do you want this inside you?"
	DB	NEXT
	DB	"Shiho:  ............" 
	DB	T_WAIT,	3
	DB	"Yes."
	DB	NEXT
	DB	"Shiho opened her legs further, to aid my entry. "
	DB	NEXT
	DB	"Wanting her, my cock found her pussy again, moving halfway inside her wet pussy. Warmness assaulted me."
	DB	NEXT
	DB	"Shiho:  O- Oh!"
	DB	NEXT
	DB	"Wanting me, Shiho moved herself upwards, bringing my cock all the way inside her."
	DB	NEXT
	DB	"The wet closeness of her walls around me was all I could think of, as I tried to bring my impatience under control."
	DB	NEXT
	EVENT_CG	'th_127a',B_NORM,67
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_127a","th_127b",0,0,0,EVENT_YSIZE
	SCR_END
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_127a","th_127b",0,EVENT_YSIZE,0,0
	SCR_END
	DB	"Shiho:  Ahhh!" 
	DB	NEXT
	DB	"She yearns, cat-like, as I begin to fuck her for real."
	DB	NEXT
	DB	"Kenjirou:  Shiho! Shiho!"
	DB	NEXT
	DB	"Shiho:  Ahh! Ahhh! Kenjirou-kun!" 
	DB	NEXT
	DB	"Faster and faster I pumped, wanting her as she wanted me, my cock firmly clasped between her lower lips."
	DB	NEXT
	DB	"I felt her warmth. The warmth that was her was disappearing, though, even now, as she lay beneath me, around me."
	DB	NEXT
	DB	"She called out to me, more loudly this time, moving in opposition to my thrusts."
	DB	NEXT
	DB	"Kenjirou:  I- I'll never forget! No matter what happens, I'll never forget...!!"
	DB	NEXT
	DB	"My cock, inside her, was nearing explosion."
	DB	NEXT
	DB	"Shiho:  Kenjirou-kun! Come! Come inside me! I'll never forget, either...!!" 
	DB	NEXT
	DB	"She made one high-pitched sound, just as my cock was preparing to spit white semen into her."
	DB	NEXT
	DB	"Kenjirou:  Uuu....!!"
	DB	NEXT
	MC_FLASH	3,C_SIRO
	B_O	B_FADE,C_SIRO
	B_O	B_NORM,C_KURO
	FLG_KI	YOKU,'=',0
	DB	"I collapsed on Shiho, and felt the flow. When minutes or hours had passed, I spoke."
	DB	NEXT
	DB	"Kenjirou:  Shiho, I don't..."
	DB	T_WAIT,	3
	DB	"I don't want to lose you."
	DB	NEXT
	DB	"Shiho:  Yes. I want to... want to stay by your side, forever. Forever." 
	DB	NEXT
	DB	"I pulled out of her, and slowly picked her off the floor, pulling her to me. The inexplicable "
        DB      "lightness of her tore at my heart. I knew that she must have used up much of her remaining strength to be with me."
	DB	NEXT
        DB	"Shiho:  I want... I want to stay like this forever..." 
	DB	NEXT
	DB	"Kenjirou:  Then stay. Just stay."
	DB	NEXT
	DB	"Shiho:  ......................." 
	DB	NEXT
	DB	"She moves back from me, and looks into my eyes."
	DB	NEXT
	BAK_INIT	'tb_016',B_NORM
	CDPLAY	10
	T_CG	'tt_02_16',SIH_A3,0
	DB	"Kenjirou:  Shiho..."
	DB	NEXT
	DB	"Shiho:  Please... Stay back." 
	DB	T_WAIT,	3
	DB	" I'm out of time."
	DB	NEXT
	DB	"Kenjirou:  Time?"
	DB	NEXT
	DB	"I question her, but I know the answer. Without knowing, I know."
	DB	NEXT
	DB	"She couldn't stay by my side any longer. I knew it. The shadow she was casting on the floor was "
        DB      "almost gone now, as her form continue to disappear in front of me."
	DB	NEXT
	DB	"Shiho:  S- Sayonara..." 
	DB	NEXT
	TATI_ERS
	DB	"Not wanting to show her tears to me, she turned, and ran out of the music room."
	DB	NEXT
	DB	"Kenjirou:  Shiho!"
	DB	NEXT
	DB	"Forgetting even to put my cock away, I ran out after her."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB	"But what I saw was an empty hallway. Shiho was nowhere to be seen."
	DB	NEXT
	DB	"Kenjirou:  Shiho..." 
	DB	NEXT
	BAK_INIT	'tb_016',B_NORM
	CDPLAY	21
	DB	"I return to the music room, and get dressed. My fingers reach out to touch the piano keys."
	DB	NEXT
	DB	"The warmth of her touch on the keys was gone, almost as if no one had ever touched these keys at all."
	DB	NEXT
	DB	"I left the place of our last words, and somberly headed for home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	CDPLAY	12
	DB	"Reaching home, I head immediately for my room, entering my private world. I began to write everything "
        DB      "I could remember about Shiho down in a notebook."
	DB	NEXT
	DB	"I knew that I wouldn't understand the meaning of the words later, but I wrote anyway. "
        DB      "On the outside of the notebook, I wrote, 'Never Forget.'"
	DB	NEXT
	DB	"Then, I slept."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_49.OVL'
AITENAI:
	SINARIO	'BUNKI_2.OVL'
END