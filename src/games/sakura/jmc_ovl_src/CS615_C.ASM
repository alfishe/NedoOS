;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　
;		

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	"MIO",0
;NN2:	DB	2,	'海',0
NN2:	DB	2,	"OCEAN",0
;NN3:	DB	3,	'月',0
NN3:	DB	3,	"MOON",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　美緒
S2:		DW	VV1, NN2,  2, M4, M5		;見る　海
S3:		DW	VV1, NN3,  3, M6		;見る　月
S4:		DW	VV2, NN1,  4, M7, M8, M9, M10, M11, M12, M13, M14, M15		;話す　美緒
S5:		DW	VV3, NN1,  5, M16, M17		;考える　美緒


;イニシャルメッセージ
M1:
	DB	BGM,9
	BAK_INIT "AB_17_3"
	DB	BUF,B_COPY01
;	DB	'【%001】：よ、なにやってんの？'
	DB	"%001:  Hi, what are you doing out here?"
	DB	NEXT
;	DB	'【美緒】：わっ！？'
	DB	"Mio:  Wahh!?!"
	DB	NEXT
	T_CG "CT03","F",0,12,2
;	DB	'【美緒】：・・・・・・%001先輩？'
	DB	"Mio:  ...%001?"
	DB	NEXT
;	DB	'【%001】：や。'
	DB	"%001:  Yup."
	DB	NEXT
;	DB	'【美緒】：・・・もう、びっくりしちゃった。'
	DB	"Mio:  You really scared me!"
	DB	NEXT
;	DB	'【%001】：ははは、悪ィ悪ィ。'
	DB	"%001:  Hahaha, sorry."
	DB	NEXT
;	DB	'【%001】：で、なにやってんの？'
	DB	"%001:  So, what are you up to?"
	DB	NEXT
;	DB	'【美緒】：え？・・・お散歩だよ。'
	DB	"Mio:  Huh? Just walking."
	DB	NEXT
;	DB	'【%001】：ふーん。・・・俺も付き合っていいかな？'
	DB	"%001:  Oh. Can I come with you?"
	DB	NEXT
;	DB	'【美緒】：うん！'
	DB	"Mio:  Sure!"
	DB G_FLG,G_COPYI,134,1
	DB G_FLG,G_COPYF,130,130
	DB	FLG,F_CALI,130,15
	DB G_FLG,G_COPYG,130,130
	DW	0000H

M2:		;見る　美緒
;	DB	'まっすぐに、俺を見上げている。'
	DB	"She looks up at me."
	DB	NEXT
;	DB	'・・・なんだか照れるな、こーゆーの。'
	DB	"She seems quiet, for some reason."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　美緒
;	DB	'静かに海を見つめている。'
	DB	"She's looking at the moon."
	DW	0000H

M4:		;見る　海
;	DB	'・・・恐いな・・・'
	DB	"It's kind of scary."
	DB	NEXT
;	DB	'今、波に飲まれたら二度と上がってこれないだろうな・・・'
	DB	"It seems like a big wave could come up and kill me, even"
	DB	CR
	DB	"from here."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;見る　海
;	DB	'・・・実はこの海全体が、俺への悪意に満ちた一個の生物で・・・'
	DB	"The whole ocean appears to me as some great creature"
	DB	CR
	DB	"that wants to devour me..."
	DB	NEXT
;	DB	'・・・・・・そうか、それなら俺が泳げないのも当然だ。'
	DB	"But that's probably just because I can't swim."
	DB	FLG,F_COPYI,2,0
	DW	0000H

M6:		;見る　月
;	DB	'綺麗な月だ。'
	DB	"What a beautiful moon."
	DB	NEXT
;	DB	'少なくとも、俺は海よりは１０００倍くらい綺麗だと思うぞ、俺は。'
	DB	"To me, it's at least a thousand times more beautiful"
	DB	CR
	DB	"than the ocean."
	DW	0000H

M7:		;話す　美緒
;	DB	'【美緒】：%001先輩は何してるの？'
	DB	"Mio:  What are you doing, %001?"
	DB	NEXT
;	DB	'【%001】：え？おれ？'
	DB	"%001:  Huh? Me?"
	DB	NEXT
;	DB	'【%001】：・・・・・・さあ？'
	DB	"%001:  Oh, nothing much."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:		;話す　美緒
;	DB	'【美緒】：夜の海って・・・すごいね。'
	DB	"Mio:  The ocean at night is really amazing, isn't it?"
	DB	NEXT
;	DB	'【%001】：・・・俺は恐いだけだよ。'
	DB	"%001:  I just think it's scary."
	DB	NEXT
;	DB	'【美緒】：くすっ、泳げないから？'
	DB	"Mio:  Is that because you can't swim?"
	DB	NEXT
;	DB	'【%001】：・・・い～んだ、い～んだ。',CR,'ど～せ俺はいまだにカナヅチさ。'
	DB	"%001:  Yes, it is. Alright?"
	DB	NEXT
;	DB	'【美緒】：あ・・・、ごめんなさい。'
	DB	"Mio:  Oh...I'm sorry. I didn't mean to make you feel bad"
	DB	CR
	DB	"about not being able to swim."
	DB	FLG,F_COPYI,4,2
	DW	0000H


M9:		;話す　美緒
	K_CG "CT03","I",12,3
;	DB	'【美緒】：あの、%001先輩・・・'
	DB	"Mio:  %001?"
	DB	NEXT
;	DB	'【%001】：ん？どしたの？'
	DB	"%001:  Hm? What?"
	DB	NEXT
;	DB	'【美緒】：・・・ごめんなさい。'
	DB	"Mio:  I'm Sorry."
	DB	NEXT
;	DB	'【%001】：は？・・・ああ、さっきの？別に、あんな事で怒ったりはしないよ。'
	DB	"%001:  Why? Oh, what you just said? Oh, that doesn't matter."
	DB	NEXT
;	DB	'【美緒】：・・・そうじゃなくて・・・'
	DB	"Mio:  No..."
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  ......................??"
	DB	NEXT
;	DB	'【美緒】：あたし、今日のお昼・・・先輩に変なこと言っちゃったから・・・'
	DB	"Mio:  I'm sorry about what I said to you this afternoon..."
	DB	NEXT
;	DB	'【%001】：・・・？・・・ああ、あれね。'
	DB	"%001:  Oh."
	DB	NEXT
;	DB	'【%001】：別に、美緒ちゃんは悪い事なんて一つも言ってねェって。'
	DB	"%001:  Not at all, Mio, you didn't say even one bad thing."
	DB	NEXT
	T_CG1 "CT03","F",0,12,2
;	DB	'【美緒】：え？・・・ありがとう、%001先輩。'
	DB	"Mio:  Really? .....Thanks, %001."
	DB	NEXT
;	DB	'【%001】：そーそー、美緒ちゃんはそーやって笑ってるのが一番似合ってるよ。'
	DB	"%001:  I like it best when you smile. "
	DB	NEXT
	K_CG "CT03","R",12,1
;	DB	'【美緒】：え？・・・・・・（ポッ）'
	DB	"Mio:  Huh?  *blush*"
	DB	FLG,F_COPYI,4,3
	DW	0000H

M10:		;話す　美緒
;	DB	'【美緒】：・・・・・・'
	DB	"Mio:  ................."
	DB	NEXT
;	DB	'【%001】：どーした？黙り込んじゃって。'
	DB	"%001:  What's up? You're quiet all of the sudden."
	DB	NEXT
	T_CG1 "CT03","F",0,12,2
;	DB	'【美緒】：ちょっと、お話、いいかな？'
	DB	"Mio:  ....Can I ask you something?"
	DB	NEXT
;	DB	'【%001】：は？・・・うん、別に構わないけど？'
	DB	"%001:  Huh? Sure, go ahead."
	DB	FLG,F_COPYI,4,4
	DW	0000H

M11:		;話す　美緒
;	DB	'【美緒】：あのね・・・すっごく、テニスの上手い子が、ある日転校してきたの。'
	DB	"Mio:  Well, one day, this woman who's really good at"
	DB	CR
	DB	"tennis transferred to out school."
	DB	NEXT
;	DB	'【%001】：ふんふん。'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【美緒】：でね・・・その子、あたしに挑戦してきたんだ・・・「どっちが中学ナンバーワンかはっきりさせよう」、って。'
	DB	"Mio:  This person challenged me to a game. 'Let's see who's"
	DB	CR
	DB	"number one around here,' she said."
	DB	NEXT
;	DB	'【%001】：（亜希ちゃんのことか？）'
	DB	"(...Is this about Aki?)"
	DB	NEXT
;	DB	'【美緒】：あたし・・・負けなかった。その後何度も試合したけど、一度も負けてないの。'
	DB	"Mio:  I didn't lose. We've played a lot of matches since"
	DB	CR
	DB	"then, but I never lose."
	DB	NEXT
;	DB	'【美緒】：・・・その子・・・負けるとすごく悔しがって、泣くの。'
	DB	"Mio:  She hates to lose so much, that it makes her cry."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......................"
	DB	NEXT
;	DB	'【美緒】：あたし、敗けてあげた方がいいのかな・・・？'
	DB	"Mio:  Do you think I should let her win?"
	DB	NEXT
;	DB	'【美緒】：でも、わざと敗けたりしたら、あ・・・その子、かえって怒るかも知れない・・・'
	DB	"Mio:  I'm afraid that if she knows I let her win, she'll"
	DB	CR
	DB	"be hurt."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..............................."
	DB	NEXT
;	DB	'【美緒】：その子が悔しがっているのも、怒っているのももう見たくない！あたし、どうすればいいんだろう？'
	DB	"Mio:  I just can't stand her envy and anger anymore! What"
	DB	CR
	DB	"should I do?"
	DB	FLG,F_COPYI,4,5
	DB	FLG,F_COPYI,5,1
	DW	0000H

M12:		;話す　美緒
;	DB	'【%001】：・・・その子は、なにか卑怯な事をしてくるのかい？'
	DB	"%001:  This person, does she do mean things to you?"
	DB	NEXT
;	DB	'【美緒】：・・・ううん、いつだって、真正面からぶつかってくるよ・・・'
	DB	"Mio:  ...Yes."
	DB	NEXT
;	DB	'【%001】：なら、美緒ちゃんも、正々堂々、本気で相手するべきだよ。'
	DB	"%001:  If that's the case, Mio, then you have to be an"
	DB	CR
	DB	"up-front and honest rival to her."
	DB	NEXT
;	DB	'【美緒】：！'
	DB	"Mio:  !!"
	DB	NEXT
;	DB	'【%001】：自分の前に堂々と立ちふさがる者は、どんなに実力の差があっても、ライバルだ。'
	DB	"%001:  Any person who is trying to get in your way, no"
	DB	CR
	DB	"matter the difference in strength, is a rival."
	DB	NEXT
;	DB	'【%001】：そのライバルに対して敬意を払う気があるなら、美緒ちゃん、君は本気をださなきゃいけない。'
	DB	"%001:  So if you want to respect your rival, Mio, then"
	DB	CR
	DB	"you need to give it the best you've got."
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・'
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	'【%001】：それが、礼儀ってモンだと思うぜ？'
	DB	"%001:  That's the proper way to show courtesy, don't you"
	DB	CR
	DB	"think?"
	DB	NEXT
;	DB	'【美緒】：うん・・・'
	DB	"Mio:  Yes. Yes, you're right."
	DB	NEXT
;	DB	'【%001】：・・・美緒ちゃんは優しいけど、その優しさも時と場所を選ばないとな。'
	DB	"%001:  You're a nice woman, Mio, but niceness has its"
	DB	CR
	DB	"time and place."
	DB	NEXT
;	DB	'【美緒】：うん。'
	DB	"Mio:  Yes."
	DB	NEXT
;	DB	'【%001】：ライバルに対して本気をだして見せるのは、傲慢なんかじゃないよ。'
	DB	"%001:  Showing your best to your rival isn't bragging or"
	DB	CR
	DB	"anything. I think that hurt someone more by being"
	DB	CR
	DB	"condescending to them."
	DB	NEXT
;	DB	'【美緒】：・・・そうだよね・・・'
	DB	"Mio:  Thanks."
	DB	FLG,F_COPYI,4,6
	DW	0000H


M13:		;話す　美緒
;	DB	'【%001】：そうやって、お互い手加減無用で勝負していたら、いつの間にかお互いにかけがえのない親友になっているかも知れない。'
	DB	"%001:  So then, if you meet and play an honest game with"
	DB	CR
	DB	"each other, then it could well be that you end up being"
	DB	CR
	DB	"friends."
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・'
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	'【%001】：無責任にこんな事言ってるけど、もしそうなったら最高だろ？'
	DB	"%001:  I don't really have the right to say this, but"
	DB	CR
	DB	"wouldn't that be a good thing?"
	DB	NEXT
;	DB	'【美緒】：うん！'
	DB	"Mio:  Yes!"
	DB	NEXT
;	DB	'【%001】：・・・なぁ～んて、俺がこんな事言っても全っ然説得力無いのな。'
	DB	"%001:  Well, even though I said all that, I probably"
	DB	CR
	DB	"still haven't convinced you, have I?"
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・'
	DB	"Mio:  %001..."
	DB	FLG,F_COPYI,4,7
	DW	0000H

M14:		;話す　美緒
;	DB	'【%001】：ん？どしたの？俺の顔になんかついてる？'
	DB	"%001:  Well, what? Do I have something stuck to my face?"
	DB	NEXT
;	DB	'【美緒】：・・・ううん！ありがとう、%001先輩！'
	DB	"Mio:  No, no! Thanks, %001!"
	DB	NEXT
;	DB	'【%001】：いやいや。なんの参考にもなんなかったろ？'
	DB	"%001:  No problem. So I didn't help you at all, did I?"
	DB	NEXT
;	DB	'【美緒】：ううん、そんなことないよ！'
	DB	"Mio:  Of course you did!"
	DB	FLG,F_COPYI,4,8
	DW	0000H

M15:		;話す　美緒
;	DB	'【美緒】：・・・ね、%001先輩、もう少し、お散歩してから帰ろ？'
	DB	"Mio:  Hey, %001, let's walk a little further and then go"
	DB	CR
	DB	"back?"
	DB	NEXT
;	DB	'【%001】：ああ、いいよ。'
	DB	"%001:  Yeah, sure."
	DB	NEXT
;	DB	'俺達は、夜の浜辺をぶらぶらと散歩した。'
	DB	"We walked around the dark beach."
	DB	NEXT
;	DB	'この時の月明かりは・・・何故か妙に明るく、暖かかったような気がする。'
	DB	"The moonlight seemed strangely bright and almost warm."
	DB	NEXT
;	DB	'それはもしかすると、側にいる美緒ちゃんのせいだったかもしれない。'
	DB	"I'm not sure, but it could have been because Mio was walking"
	DB	CR
	DB	"by my side."
	DB	NEXT
	B_O B_SUDA			;ブラックアウト
;	DB	'・・・・・・・・・'
	DB	"............................."
	DB	NEXT
;	DB	'そんなこんなで、俺の高校生活最初の夏は終わった。'
	DB	"So, the summer ended..."
	DB	NEXT
;	DB	'様々な想い出を残して・・・・・・'
	DB	"There were all kinds of memories..."
	DB	NEXT

;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	".............................."
	DB	NEXT
;	DB	'ざばざば'
	DB	"*SQUELCH*"
	DB	NEXT
;	DB	'【？】：・・・'
	DB	"???:  ......."
	DB	NEXT
;	DB	'ざばざば'
	DB	"*SQUELCH*"
	DB	NEXT
;	DB	'【？】：・・・・・・'
	DB	"???:  ......"
	DB	NEXT
;	DB	'ばしゃばしゃ・・・'
	DB	"Splash..."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT13",'F',0,15,3 	;校長
;	DB	'【校長】：・・・・・・・・・'
	DB	"Dean:  ......................"
	DB	NEXT
;	DB	'【校長】：・・・やっと・・・帰って来られた・・・'
	DB	"Dean:  ...Finally...got back..."
	DB	NEXT
;	DB	'【校長】：私ももう年だろーか、前後不覚になるほど酔ってしまうとは。'
	DB	"Dean:  I passed out..."
	DB	NEXT
;	DB	'【校長】：しかも、酔いが覚めてみたら知らない島にいるし・・・'
	DB	"Dean:  And then when I woke up and looked around, I"
	DB	CR
	DB	"was on this island..."
	DB	NEXT
;	DB	'【校長】：小林先生とお酒を飲むのはもう止めよう・・・'
	DB	"Dean:  I don't think I'll be drinking with Kobayashi-"
	DB	CR
	DB	"sensei anymore..."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS701.OVL',0
	DW	0000H

M16:		;考える　美緒
;	DB	'なんか、昼とは違う・・・'
	DB	"She's a little different from this afternoon..."
	DB	NEXT
;	DB	'少し、大人びて見える。'
	DB	"She seems a little older."
	DB	NEXT
;	DB	'月明かりのせいなのかな。'
	DB	"Must be the moonlight."
	DW	0000H

M17:		;考える　美緒
;	DB	'いつも元気で、悩みなんか無いように見えてたけど・・・'
	DB	"She's always cheerful, always seemed to be pretty"
	DB	CR
	DB	"carefree..."
	DB	NEXT
;	DB	'・・・そりゃあ、悩みの一つや二つ、あるよなあ。'
	DB	"But I guess she does have one or two worries."
	DB	NEXT
;	DB	'・・・ごめんな、美緒ちゃん。'
	DB	"I'm sorry, Mio."
	DW	0000H


end