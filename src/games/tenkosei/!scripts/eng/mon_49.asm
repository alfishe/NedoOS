        include SUPER_C.inc
M_START:
MON_49
	BAK_INIT 'tb_001a',B_NORM
	CDPLAY 14
	DB	"Grudgingly, I woke up, and looked at the notebook I had written last night."
        DB      " I knew one thing -- that Shiho had really been in my life."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY 0
	DB	"Going down to the dining kitchen, I eat breakfast and head for the train station."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_009',B_NORM
	CDPLAY 2
	DB	"Shiho was gone, according to the notebook, I used to meet her on the way to the "
        DB      "station in the morning. I decided to wait at the station for her."
	DB	NEXT
	DB	"The clock told me it was almost time to start class, but here I still was."
	DB	NEXT
	DB	"Kenjirou:  Maybe she's at school?"
	DB	NEXT
	DB	"Knowing I shouldn't get my hopes up, I headed off to school."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_010',B_NORM
	CDPLAY 14
	DB	"In the classroom, everyone was talking loudly. The instructor wasn't here yet."
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB	"Kenjirou:  What's wrong, why is everyone so excited?"
	DB	NEXT
	DB	"Tetsuya:  It's because there's a new student joining the class today. A transfer student." 
	DB	NEXT
	DB	"Kenjirou:  ...A transfer student? Shiho?"
	DB	NEXT
	DB	"Kenjirou:  Well, what kind of student is it? Is she pretty?"
	DB	NEXT
	DB	"Tetsuya:  ...You amaze me sometimes, you know that? What a pervert. It's a male student."
	DB	NEXT
	DB	"Kenjirou:  Really?"
	DB	T_WAIT, 3
	DB	" ...A male student."
	DB	NEXT
	DB	"Tetsuya:  Don't worry, if you're hard up, I'll loan you some more of my videos."
	DB	NEXT
	DB	"He squeezed my shoulder, and sat down in his seat. I sat down, too."
	DB	NEXT
	TATI_ERS
	DB	"It was time to start another boring class. Time for me to sleep."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY 0
	DB	"The new student introduced himself to us, and the teacher had him sit in the seat that Shiho had been in."
	DB	NEXT
	DB	"It filled me with anger and confusion to have a new student in Shiho's seat."
	DB	NEXT
	DB	"The bell eventually rang, but I barely heard it. I was thinking about Shiho, gone from my world."
	DB	NEXT
	DB	"After the bell had rung a few more times, Tetsuya came over to wake me up."
	DB	NEXT
	DB	"Tetsuya:  Wake up, it's lunchtime."
	DB	NEXT
	DB	"I slowly raised my head."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	CDPLAY 14
	T_CG 'tt_08_10',TET_A2,0
	DB	"Tetsuya:  You're awake. I'm shocked. "
	DB	NEXT
	DB	"Kenjirou:  Really?"
	DB	NEXT
	DB	"Tetsuya:  What happened to you, anyway? You're acting funny."
	DB	NEXT
	DB	"Kenjirou:  I'm fine."
	DB	NEXT
	DB	"Tetsuya:  Really? I hope so..."
	DB	NEXT
	DB	"Kenjirou:  Hey, Tetsuya..."
	DB	T_WAIT, 5
	DB	" No, never mind."
	DB	NEXT
	DB	"Tetsuya:  What? Tell me."
	DB	NEXT
	DB	"I slowly got to my feet."
	DB	NEXT
	DB	"Tetsuya:  Where are you going?"
	DB	NEXT
	DB	"Kenjirou:  I'm sorry. I need to be alone for a while."
	DB	NEXT
	DB	"Tetsuya:  .....Okay. But I just hope you're okay."
	DB	NEXT
	DB	"Kenjirou:  Thanks."
	DB	NEXT
	DB	"Leaving Tetsuya, I head for the roof."
	DB	NEXT
	BAK_INIT 'tb_012',B_NORM
	DB	"There are quite a few people on the roof. I haven't seen much of her lately, but I used to see Terumi-senpai here quite a bit."
	DB	NEXT
	DB	"I think of Shiho, gone forever -- forever? I don't know, but I do know that she really existed."
	DB	NEXT
	DB	"I look up into the sky...only to see Shiho's smiling face, floating there."
	DB	NEXT
	EVENT_CG 'ti_135',B_FADE,77
	CDPLAY 21
	FLG_IF SIH_KAIS,'>=',8,ENDING_SIHO
	DB	"Shiho:  I know I'll see you again, in your dreams. Until then, Kenjirou-kun." 
	DB	NEXT
	DB	"At least, I'm sure that's what she meant to say. Her smile told me so."
	DB	NEXT
	GAME_END
 	DB EXIT
ENDING_SIHO:
	DB	"Shiho:  I was happy that you noticed me... I thank you for that." 
	DB	NEXT
	DB	"Kenjirou:  Shiho..."
	DB	NEXT
	DB	"Shiho:  Don't make that face, please. I know we'll meet again, somewhere. If you keep on loving me, I know..."
	DB	NEXT
	DB	"Kenjirou:  .....Shiho!"
	DB	NEXT
	B_O B_FADE,C_KURO
	CDPLAY 11
	F_O B_NORM,C_KURO
	DB	"Then she was gone, really gone this time -- but inside me, she had returned."
	DB	NEXT
	DB	"Since I couldn't be with Shiho like I wanted every night, instead I threw myself into my "
        DB      "studies, entering a top-notch university, and enjoying a great campus life."
	DB	NEXT
	DB	"One afternoon, when I was relaxing under the shade of a tree, a wind, slightly cool, "
        DB      "picked up. I closed my eyes and felt the soothing wind on my face."
	DB	NEXT
	DB	"The wind touched my cheek, and there was a scent, so familiar, on it. Slowly my eyes opened."
	DB	NEXT
	EVENT_CG 'th_ed01',B_FADE,78
	DB	"A female student who had been watching me napping was standing there. "
	DB	NEXT
	DB	"Kenjirou:  What do you want, Shiho?"
	DB	NEXT
	DB	"Shiho:  Eh! You knew it was me?" 
	DB	NEXT
	DB	"Kenjirou:  Yes, I knew it. So...How long can you stay this time, Shiho?"
	DB	NEXT
	DB	"Shiho:  I'm not sure. It depends on you."
	DB	NEXT
	DB	"Kenjirou:  I see. Well, let's make a lot of memories together, shall we?"
	DB	NEXT
	DB	"Shiho:  Yes." 
	DB	T_WAIT, 3
	DB	" But how did you know it was me?"
	DB	NEXT
	DB	"Kenjirou:  I won't tell."
	DB	NEXT
	DB	"Shiho:  I can't believe you! Come on, tell me."
	DB	NEXT
	DB	"Kenjirou:  Nope! It's an industrial secret. "
	DB	NEXT
	DB	"I can't tell her it was because I wrote down the fact that we had sex in the music room in my notebook."
	DB	NEXT
	DB	"Resolving to make the most of the time we were allotted together, I pulled her to me."
	DB	NEXT
	GAME_END
	DB EXIT
END