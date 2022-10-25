        include SUPER_C.inc
M_START:
MON_04
	CDPLAY		14
	BAK_INIT 'tb_034a',B_NORM
	DB	"I somehow managed to make it to school on time."
	DB	NEXT
	DB	"Hmm, for some reason, the class seems noisier than usual this morning. Something must be up."
	DB	NEXT
	DB	"I slide the door open."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"Kenjirou:  Good morning!"
	DB	NEXT
	DB	"Tetsuya:  Oh, good morning, Kenjirou."
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB	"Tetsuya's here. He's been my friend since elementary school. We even went to high school together. "
	DB	NEXT
	DB	"He used to get quite a lot of dates, but then the fact that he's an avid adult video collector"
    DB  " got out. Now the girls won't go near him."
	DB	NEXT
	DB	"Tetsuya:  Hey, listen to this, Kenjirou..."
	DB	NEXT
	DB	"Kenjirou:  Did you get a new video?"
	DB	NEXT
	DB	"Tetsuya:  Well, yes, but that's not what I want to tell you now."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  There's a new student coming into our class. A transfer student." 
	DB	NEXT
	DB	"Kenjirou:  Hmm. So that's why everyone was so excited."
	DB	NEXT
	DB	"Tetsuya:  Yep. Don't you want to see what the new student's like?"
	DB	NEXT
	DB	"Kenjirou:  I don't really care."
	DB	NEXT
	DB	"Tetsuya:  Really? But wait 'till you hear this..."
	DB	NEXT
	DB	"He put his hand on my shoulder, and started to whisper."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  You want me to tell you? Okay, I'll tell you. "
	DB	NEXT
	DB	"Kenjirou:  Tetsuya."
	DB	NEXT
	DB	"Tetsuya:  Yes?"
	DB	NEXT
	DB	"Kenjirou:  You seem very excited yourself."
	DB	NEXT
	DB	"Tetsuya:  Well, I am. You see, the transfer student is..."
	DB	NEXT
	DB	"Kenjirou:  Is what?"
	DB	NEXT
	DB	"Tetsuya:  A girl. And she's beautiful." 
	DB	NEXT
	DB	"Kenjirou:  ...Really?"
	DB	NEXT
	DB	"Kenjirou:  You should have told me that earlier!"
	DB	NEXT
	DB	"Tetsuya:  I finally got your attention, didn't I." 
	DB	NEXT
	DB	"Kenjirou:  And? Have you seen her yet?"
	DB	NEXT
	DB	"Tetsuya:  Yes, this morning, in the teacher's room."
	DB	NEXT
	DB	"Kenjirou:  And?"
	DB	NEXT
	DB	"Tetsuya:  And nothing. But she is really beautiful. "
	DB	NEXT
	DB	"Kenjirou:  Really? If you say so, it must be true, since you're always one to go for the face."
	DB	NEXT
	DB	"Tetsuya:  Right before she went into the teacher's room, she smiled at me for a second." 
	DB	NEXT
	DB	"Kenjirou:  That's not true. You're lying."
	DB	NEXT
	DB	"Tetsuya:  ...You can tell?"
	DB	NEXT
	DB	"Kenjirou:  Of course."
	DB	NEXT
	DB	"Tetsuya:  Well, she did look in my direction."
	DB	NEXT
	DB	"Kenjirou:  Probably because she hadn't seen a rare animal like you before."
	DB	NEXT
	DB	"Tetsuya:  I can't believe you!" 
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Suddenly, the bell rang. The teacher would come in soon, so people started getting in their seats."
	DB	NEXT
	;WAV 'STOP'
	F_O	B_NORM,C_KURO
	DB	"I sat down, too."
	DB	NEXT
	DB	"Teacher:  Everyone, I'm sure you've heard that we have a transfer student today."
	DB	NEXT
	DB	"When he was done, the door opened, and in she walked. It was a person I was well familiar with."
	DB	NEXT
	CDPLAY		23
	EVENT_CG 'ti_029',B_NORM,73
	DB	"The teacher wrote her name on the board:  Shiho Kashima. "
	DB	NEXT
	DB	"Teacher:  I'll introduce you to her now. She's joining this class, and her name is Shiho."
	DB	NEXT
	DB	"She took a half-step forward, and bowed to all of us."
	DB	NEXT
	DB	"Shiho:  My name is Shiho Kashima. I'm happy to be joining this class." 
	DB	NEXT
	DB	"I thought it was my imagination, but I swore she looked at me when she introduced herself."
	DB	NEXT
	DB	"Teacher:  Okay, then. Go ahead and find an empty seat to sit in."
	DB	NEXT
	DB	"Shiho:  Yes, sir."
	DB	NEXT
	DB	"She walked past me to get to her seat. When she passed, she looked at me."
	DB	NEXT
	DB	"That wasn't my imagination. She looked at me. She smiled and looked right at me."
	DB	NEXT
	CDPLAY		14
	F_O	B_NORM,C_KURO
	DB	"I put my head down on the desk, and began to fall asleep. I always sleep in class."
	DB	NEXT
	DB	"Kenjirou:  Zzzz... (Is she just a stranger? There's no way a woman from my fantasy world could really exist.)"
	DB	NEXT
	DB	"Kenjirou:  Zzzz... (I mean, the other Shiho was my ideal woman in every way. This girl can't be that perfect.)"
	DB	NEXT
	DB	"Kenjirou:  Zzzz... (Wait a minute, what did my Shiho look like, anyway? Can't...remember...)"
	DB	NEXT
	DB	"Kenjirou:  Zzzz... (...so sleepy...)"
	DB	NEXT
	DB	"Kenjirou:  Zzzzzzzzz....................................."
	DB	NEXT
	DB	"Voice:  Hey, wake up! Wake up!"
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"Kenjirou:  Huh?"
	DB	NEXT
	DB	"Tetsuya:  You're finally awake." 
	DB	NEXT
	DB	"I slowly pick my head up off the desk and look at  Tetsuya."
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB	"Kenjirou:  Oh, it's just you..."
	DB	NEXT
	DB	"Tetsuya:  Just me? That's no way to..."
	DB	NEXT
	DB	"Kenjirou:  Is class over?"
	DB	NEXT
	DB	"Tetsuya:  Yes, it's lunchtime now."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Tetsuya:  Don't act so surprised. You do this every day. Anyway, what did you think of the new girl, Kashima?"
	DB	NEXT
	DB	"Kenjirou:  Huh?"
	DB	NEXT
	DB	"Tetsuya:  You know, the new girl in our class."
	DB	NEXT
	DB	"Kenjirou:  Well, she's cute."
	DB	NEXT
	DB	"Tetsuya:  That's all you can say about her? I think she's beautiful."
	DB	NEXT
	DB	"Kenjirou:  Where is she now?"
	DB	NEXT
	DB	"Tetsuya:  Look for yourself."
	DB	NEXT
	DB	"I followed his pointing finger. Shiho was at her desk, surrounded by all the girls in the class, who wanted to talk to her."
	DB	NEXT
	DB	"Kenjirou:  Wow, she's really popular..."
	DB	NEXT
	DB	"Tetsuya:  I told you. I can't get in there to talk to her."
	DB	NEXT
	DB	"Kenjirou:  Yes, that'd be impossible."
	DB	NEXT
	DB	"Tetsuya:  It's not fair, I tell you..." 
	DB	NEXT
	DB	"Kenjirou:  Yes. They're probably telling her about your AV collection right at this moment."
	DB	NEXT
	DB	"Tetsuya:  N- No! They wouldn't do that, would they?" 
	DB	NEXT
	DB	"Kenjirou:  *Yawn*  Tetsuya?"
	DB	NEXT
	DB	"Tetsuya:  Yes?"
	DB	NEXT
	DB	"Kenjirou:  I'm going to take a nap now."
	DB	NEXT
	DB	"Tetsuya:  W- What?"
	DB	NEXT
	DB	"Kenjirou:  Zzzz..."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Ignoring Tetsuya, I started to drift off to sleep..."
	DB	NEXT
	DB	"Kenjirou:  Zzzz... (Sorry, Tetsuya. I've got some thinking to do.)"
	DB	NEXT
	DB	"Kenjirou:  Zzzz... (I want to remember what my Shiho was like... What did she look like? I can't remember...)"
	DB	NEXT
	DB	"Kenjirou:  Zzzz... (...so sleepy...)"
	DB	NEXT
	DB	"Kenjirou:  Zzzzzzzzz....................................."
	DB	NEXT
	B_O	B_FADE,C_KURO
	DB	"Kenjirou:  Uuu... Huh?"
	DB	NEXT
	DB	"It's too quiet..."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB	"I open my eyes, and look around me. The room is tinted orange, with the setting sun."
	DB	NEXT
	DB	"There's a paper on my desk."
	DB	NEXT
	DB	"What's this? It says, 'How long are you going to sleep? You idiot! by Tetsuya.'"
	DB	NEXT
	DB	"Well, guess I'll go home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT 'tb_005c',B_NORM
	CDPLAY		22
	DB	"It's almost dark. It gets dark so quickly these days. "
	DB	NEXT
	DB	"Kenjirou:  Shiho...Kashima."
	DB	NEXT
	DB	"I opened the door to my house, and went in."
	DB	NEXT
	SINARIO 'MON_05.OVL'
END