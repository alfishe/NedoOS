;くらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ１１
;		トランプなど

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5, CM6, CM7, CM8, CM9
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN4,-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1
CM6:	DW	VV6,	-1
CM7:	DW	VV7,	-1
CM8:	DW	VV8,	-1
CM9:	DW	VV9,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0 
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'麻雀',0
VV5:	DB	5,	'MAHJONG',0
;VV6:	DB	6,	'トランプ',0
VV6:	DB	6,	'CARDS',0
;VV7:	DB	7,	'右',0
VV7:	DB	7,	'RIGHT',0
;VV8:	DB	8,	'左',0
VV8:	DB	8,	'LEFT',0
;VV9:	DB	9,	'卓球',0
VV9:	DB	9,	'PING-PONG',0

;NN1:	DB	1,	'今日子',0
NN1:	DB	1,	'KYOKO',0
;NN2:	DB	2,	'部屋',0
NN2:	DB	2,	'ROOM',0
;NN3:	DB	3,	'鏡',0
NN3:	DB	3,	'MIRROR',0
;NN4:	DB	4,	'みんなの事',0
NN4:	DB	4,	'EVERYONE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　今日子
S2:		DW	VV1, NN2,  2, M3		;見る　部屋
S3:		DW	VV1, NN3,  3, M4, M5		;見る　鏡
S4:		DW	VV2, NN1,  4, M6, M7, M8, M9, M10		;話す　今日子
S5:		DW	VV3, NN4,  5, M11, M12		;聞く　みんなの事２
S6:		DW	VV4, -1,  6, M13, M14, M15, M16, M17		;考える
S7:		DW	VV5, -1,  7, M18		;麻雀
S8:		DW	VV6, -1,  8, M19		;トランプ
S9:		DW	VV7, -1,  9, M20		;右
S10:		DW	VV8, -1,  10, M21		;左
S11:		DW	VV9, -1,  11, M22		;卓球


;イニシャルメッセージ
M1:
	DB	BGM,26
	BAK_INIT 'AB_39'
	DB	BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'（・・・・・・・・・）'
	DB	"..................."
	DB	NEXT
;	DB	'（・・・・・・痛てぇ・・・）'
	DB	".............Ouch!"
	DB	NEXT
;	DB	'右目の上の辺りが、自分の鼓動に合わせてズッキン、ズッキン、と痛む。'
	DB	"The area above my my right eye is puffed up like a rock,"
	DB	CR
	DB	"and pulsating with pain."
	DB	NEXT
;	DB	'（あつつつ・・・）'
	DB	"........Owww!"
	DB	C_BLD,C_V_ON,1	;「考える」以外全消し
	DB	C_BLD,C_V_ON,2	;「考える」以外全消し
	DB	C_BLD,C_V_ON,3	;「考える」以外全消し
	DB	C_BLD,C_V_ON,5	;「考える」以外全消し
	DB	C_BLD,C_V_ON,6	;「考える」以外全消し
	DB	C_BLD,C_V_ON,7	;「考える」以外全消し
	DB	C_BLD,C_V_ON,8	;「考える」以外全消し
	DB	C_BLD,C_V_ON,9	;「考える」以外全消し
	DW	0000H

M2:		;見る　今日子
;	DB	'（浴衣姿かぁ・・・）'
	DB	"She's dressed in her yukata, a cotton kimono..."
	DB	NEXT
;	DB	'（・・・・・・色っぽい。）'
	DB	"..........She looks sexy."
	DB	NEXT
;	DB	'【今日子】：まだ欲情してるの？'
	DB	"Kyoko:  You still want to look at women?"
	DB	NEXT
;	DB	'【%001】：あ・・・いやその・・・'
	DB	"%001:  ..........No, nevermind."
	DW	0000H

M3:		;見る　部屋
;	DB	'旅館の一室だ。'
	DB	"It's a room in the inn."
	DB	NEXT
;	DB	'俺と今日子先生の二人しかいない。'
	DB	"Kyoko and I are the only ones here."
	DW	0000H

M4:		;見る　鏡
;	DB	'（何となく予想は出来てるが・・・）'
	DB	"I can imagine what I must look like."
	DB	NEXT
;	DB	'【%001】：・・・ッわぁ！？'
	DB	"%001:  ......Wah!"
	DB	NEXT
;	DB	'俺は思わず飛びのいた。'
	DB	"I didn't think I looked that bad."
	DB	NEXT
;	DB	'右の眉毛の上に、紫色のでかいたんこぶが出来ていた。'
	DB	"There's a huge purple lump above my right eye."
	DB	NEXT
;	DB	'（そうだ、のぞいてるのがバレて、石をぶつけられたんだ。）'
	DB	"Now I remember. They caught me peeking at them, and"
	DB	CR
	DB	"threw rocks at me."
	DB	NEXT
;	DB	'（・・・世の中、悪いことは出来ねえよーになってんだな。',CR,'・・・なんて安心してどーする。）'
	DB	"What's this world come to, when you can't do someone evil"
	DB	CR
	DB	"without getting caught?"
	DB	FLG,F_COPYI,3,1
	DB	FLG,F_COPYI,4,2
	DW	0000H

M5:		;見る　鏡
;	DB	'・・・何度見ても、思わずどっきりする顔だ。月のない夜に道端で会ったら失禁するぞ。'
	DB	"I don't like looking at my face..."
	DB	NEXT
;	DB	'【%001】：ひでぇ顔・・・'
	DB	"%001:  That looks terrible."
	DB	NEXT
;	DB	'【今日子】：それでもさっきよりはだいぶマシなのよ。'
	DB	"Kyoko:  It's a lot better than it was when they first"
	DB	CR
	DB	"brought you in here."
	DB	NEXT
;	DB	'【%001】：・・・さっきは、もっとひどかったって事？'
	DB	"%001:  ......It was worse?"
	DB	NEXT
;	DB	'【今日子】：そりゃもう、ほとんど妖怪だったわ。あの子達には見せられないわよね。'
	DB	"Kyoko:  You looked like you'd been shot. I couldn't let"
	DB	CR
	DB	"the others see you like that."
	DW	0000H

M6:		;話す　今日子
;	DB	'【%001】：先生・・・・・・俺の目の上、どうなってる？'
	DB	"%001:  Sensei, what's wrong with my eye?"
	DB	NEXT
;	DB	'【今日子】：・・・ぷっ・・・'
	DB	"Kyoko:  .....Hahaha...."
	DB	NEXT
;	DB	'先生は吹き出しそうになりながら、部屋の角にある鏡を指差した。'
	DB	"Laughing, she pointed to a mirror in the corner."
	DB C_BLD,C_N_OFF,1,3	;みる
	DB	FLG,F_COPYI,4,1
	DW	0000H

M7:		;話す　今日子
;	DB	'【%001】：先生・・・俺が寝てる間に、変な事してないだろーね？'
	DB	"%001:  Sensei, you didn't do anything to me while I"
	DB	CR
	DB	"was asleep, did you?"
	DB	NEXT
;	DB	'【今日子】：さて、どうかしら。'
	DB	"Kyoko:  Who, me?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .............."
	DB C_BLD,C_V_OFF,3	;聞く
	DW	0000H

M8:		;話す　今日子
;	DB	'【今日子】：ところで、そのコブは誰が作ったか分かる？'
	DB	"Kyoko:  Who do you think put that bump on your head?"
	DB	NEXT
;	DB	'【%001】：ああ・・・きっと亜希ちゃんだな。',CR,'絶妙のコントロールだぜ。'
	DB	"%001:  I'd guess it was Aki. She's so athletic."
	DB	NEXT
;	DB	'【今日子】：それがね、なんと瑠璃ちゃんなのよ。'
	DB	"Kyoko:  No, you're going to be surprised when you hear it.",PAUSE,CR,"It was Ruri."
	DB	NEXT
;	DB	'【%001】：・・・白水さん？'
	DB	"%001:  Really?"
	DB	NEXT
;	DB	'【今日子】：しかも、お酒飲んでからお風呂を出るまでの記憶が綺麗さっぱり飛んでるのよ。だから本人はこのこと知らないわ。'
	DB	"Kyoko:  But she doesn't remember anything after she started"
	DB	CR
	DB	"drinking in the bath."
	DB	NEXT
;	DB	'【%001】：・・・それにしても、なんか、すごい酔っぱらい方だったな。'
	DB	"%001:  I've never seen anyone act quite like that when"
	DB	CR
	DB	"they got drunk."
	DB	NEXT
;	DB	'【今日子】：温泉の効能じゃない？'
	DB	"Kyoko:  It was amazing, wasn't it?"
	DB	FLG,F_COPYI,4,3
	DB C_BLD,C_V_OFF,3	;聞く
	DW	0000H

M9:		;話す　今日子
;	DB	'【%001】：・・・白水さん、来てくれたんだな。'
	DB	"%001:  I'm glad Ruri came with us."
	DB	NEXT
;	DB	'【%001】：電話で断わられたから、諦めてたんだけど・・・'
	DB	"%001:  She told me over the phone she couldn't go."
	DB	NEXT
;	DB	'【%001】：先生、どうやって説得したの？'
	DB	"%001:  How did you change her mind?"
	DB	NEXT
;	DB	'【今日子】：ま、それは企業秘密ってことでネ。'
	DB	"Kyoko:  I'm sorry, I'm not at liberty to divulge that"
	DB	CR
	DB	"information."
	DB	NEXT
;	DB	'【%001】：・・・。'
	DB	"%001:  ................."
	DB	FLG,F_COPYI,4,4
	DW	0000H

M10:		;話す　今日子
;	DB	'【%001】：・・・どうしても・・・お母さんのところに戻らないといけねーのかな？'
	DB	"%001:  Does she really have to go back and live with her"
	DB	CR
	DB	"mother?"
	DB	NEXT
;	DB	'【今日子】：本人がそれを望んでるんだから、どうにもならないわね。'
	DB	"Kyoko:  It's what she wants, so there's nothing we can do"
	DB	CR
	DB	"about it."
	DB	NEXT
;	DB	'トントン'
	DB	"*knock knock*"
	DB	NEXT
;	DB	'【鈴子】：%001君・・・目、覚めた？'
	DB	"Reiko:  %001, are you awake?"
	DB	NEXT
;	DB	'【%001】：鈴子さん？'
	DB	"%001:  Reiko?"
	DB	NEXT
;	DB	'がらっ'
	DB	"*kacha*"
	DB	NEXT
;	DB	'ふすまが開いて、鈴子さんと新藤さん、美緒ちゃんが現われた。'
	DB	"Reiko, Kiyomi and Mio came into the room."
	DB	NEXT
	DB BUF,B_COPY01
	TU_CG 'CT03','Y',0,10,3
	TU_CG 'CT02','Y',0,0,2
	T_CG 'CT01','Y',0,34,1
	DB ANI,A_ON,2
	DB ANI,A_ON,3
	DB BUF,B_COPY10
;	DB	'【今日子】：で、結局誰が勝ったわけ？'
	DB	"Kyoko:  So who won?"
	DB	NEXT
;	DB	'【清美】：それが、いつまでたっても勝負がつきませんので、３人で公平にお世話しようということになりまして・・・'
	DB	"Kiyomi:  There wasn't a clear winner, so we decided to"
	DB	CR
	DB	"come in together..."
	DB	NEXT
;	DB	'【今日子】：な～んだ・・・この際、勝負がつくまでとことんやれば良かったのに。'
	DB	"Kyoko:  You should have kept trying to choose one person."
	DB	NEXT
;	DB	'【今日子】：%001君は自分じゃ決められないから、あなた達で結論出した方が早いわよ？'
	DB	"Kyoko:  Since %001 is unable to make up his mind himself,"
	DB	CR
	DB	"you've got to decide for him."
	DB	NEXT
	E_CG B_NORM,'AB_39'
	T_CG1 'CT06','Y',0,30,6
;	DB	'【亜希】：ちょっと、あたしを忘れてもらっちゃ困るわね。'
	DB	"Aki:  Hey, don't forget about me."
	DB	NEXT
;	DB	'【美緒】：あ、亜希ちゃん！大丈夫？'
	DB	"Mio:  Ah, Aki? Are you okay?"
	DB	NEXT
;	DB	'【亜希】：まぁね・・・しっかしひどい目にあったわ・・・'
	DB	"Aki:  I just swallowed a little water, that's all. Wow,"
	DB	CR
	DB	"look at %001's eye..."
	DB	NEXT
	T_CG1 'CT05','C',0,10,5
;	DB	'【瑠璃】：雛菊さん。'
	DB	"Ruri:  Aki?"
	DB	NEXT
;	DB	'【亜希】：な・・・なに？'
	DB	"Aki:  W- What do you want?"
	DB	NEXT
;	DB	'【瑠璃】：お風呂で溺れるほど、お酒を飲むのはやめた方がいいわ。'
	DB	"Ruri:  You really shouldn't drink so much while you're"
	DB	CR
	DB	"in the bath."
	DB	NEXT
;	DB	'【亜希】：それはどーもご親切に！（あなたに言われたくないっ！）'
	DB	"Aki:  Oh, is that so? Thank you very much for that"
	DB	CR
	DB	"advice!"
	DB	NEXT
;	DB	'【瑠璃】：・・・何を怒っているの？'
	DB	"Ruri:  ......Why are you angry?"
	DB	NEXT
;	DB	'【亜希】：別に何でもない！（思い出させないでよ！）'
	DB	"Aki:  Nothing! Nevermind! Don't remind me of it!"
	DB	NEXT
	E_CG B_NORM,'AB_39'
	T_CG1 'CT14','Y',0,10,4
;	DB	'【誠】：よ、男前だな、%001。'
	DB	"Makoto:  You're a real man, now, %001."
	DB	NEXT
;	DB	'【%001】：・・・誠！・・・てめーって奴は・・・'
	DB	"%001:  Makoto! You got me into all this!"
	DB	NEXT
;	DB	'【誠】：な、麻雀やろうぜ！温泉っていったら麻雀だよなぁ！'
	DB	"Makoto:  .....Hey, let's play some mahjong!"
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【美緒】：先輩、トランプやろ！'
	DB	"Mio:  No, let's play some card games."
	DB	NEXT
	E_CG B_NORM,'AB_39'
	T_CG1 'CT06','Y',0,30,6
;	DB	'【亜希】：なに言ってんのよ、美緒！温泉っていったら卓球に決まってるじゃない！'
	DB	"Aki:  Cards? Are you kidding? When you come to an inn like"
	DB	CR
	DB	"this, you have to play ping-pong!"
	DB	NEXT
;	DB	'（・・・どうしようかな？）'
	DB	"What should I do?"
	DB	C_BLD,C_V_OFF,5	;麻雀
	DB	C_BLD,C_V_OFF,6	;トランプ
	DB	C_BLD,C_V_OFF,9	;卓球
	DB	C_BLD,C_V_ON,1	;その他全て消し
	DB	C_BLD,C_V_ON,2	;その他全て消し
	DB	C_BLD,C_V_ON,3	;その他全て消し
	DB	C_BLD,C_V_ON,4	;その他全て消し
	DW	0000H

M11:		;聞く　みんなの事
;	DB	'【%001】：・・・他のみんな・・・怒ってた？'
	DB	"%001:  ........Are the others mad at me?"
	DB	NEXT
;	DB	'【今日子】：そりゃ怒ってたわよ。もう口も聞かないって。'
	DB	"Kyoko:  They're not mad. They'll just never talk to you"
	DB	CR
	DB	"again, that's all."
	DB	NEXT
;	DB	'【%001】：そうだよな・・・怒るよなぁ・・・'
	DB	"%001:  I guess I deserve that..."
	DB	NEXT
;	DB	'【今日子】：それがわかってるのに、何でのぞいたの？'
	DB	"Kyoko:  If you feel that way, why did you do it?"
	DB	NEXT
;	DB	'【%001】：・・・なんつーか・・・その・・・'
	DB	"%001:  ................"
	DB	NEXT
;	DB	'【今日子】：誠君にそそのかされたから？'
	DB	"Kyoko:  Did Makoto put you up to it?"
	DB	NEXT
;	DB	'【%001】：・・・まぁ、それもあるけど・・・',CR,'ただ、「見たかった」からだよ。'
	DB	"%001:  That was part of it. But the real reason was...",PAUSE,CR,"I wanted to look."
	DB	NEXT
;	DB	'【%001】：・・・だけど、男らしくないよな、やっぱ。'
	DB	"%001:  ............It was terrible, though, wasn't it?"
	DB	NEXT
;	DB	'【今日子】：・・・・・・クス・・・・・・'
	DB	"Kyoko:  ......Hahaha...."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'【今日子】：みんな、もう怒ってないわ。'"
	DB	"Kyoko:  They're not mad at you anymore."
	DB	NEXT
;	DB	'【今日子】：その顔を見たら、怒る気もなくなるわよ。'
	DB	"Kyoko:  As soon as they saw your face, they forgave you."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M12:		;聞く　みんなの事２
;	DB	'【今日子】：鈴子ちゃんに清美ちゃんに美緒ちゃんは、誰があなたを看病するかで勝負してるわ。'
	DB	"Kyoko:  Reiko, Kiyomi and Mio are trying to decide who"
	DB	CR
	DB	"gets to take care of you. They couldn't decide who should"
	DB	CR
	DB	"be the one."
	DB	NEXT
;	DB	'【%001】：勝負って？'
	DB	"%001:  How are they going to decide?"
	DB	NEXT
;	DB	'【今日子】：トランプよ。ま、長引きそうだからあたしが代わりに来たってわけ。'
	DB	"Kyoko:  By playing cards. It looked like it was going to take"
	DB	CR
	DB	"a while, so I came in here first."
	DB	NEXT
;	DB	'【今日子】：瑠璃ちゃんは亜希ちゃんを介抱してたわ。'
	DB	"Kyoko:  Ruri's taking care of Aki right now."
	DB	NEXT
;	DB	'【今日子】：誠君はロビーでテレビを見てたわね。'
	DB	"Kyoko:  Makoto's watching TV in the lobby..."
	DB	NEXT
;	DB	'（見つかったのは俺だけかよ・・・。）'
	DB	"(So he got away...)"
	DB	FLG,F_COPYI,5,1
	DB C_BLD,C_V_ON,3
	DW	0000H

M13:		;考える
;	DB	'（・・・・・・何があったんだ？）'
	DB	"What the hell happened?"
	DB	NEXT
;	DB	'（・・・・・・・・・・・・）'
	DB	"........................."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M14:		;考える
;	DB	'（・・・そうだ！女風呂をのぞいてて・・・）'
	DB	"........Now I remember! I was peeking into the women's"
	DB	CR
	DB	"bath, and..."
	DB	NEXT
;	DB	'（・・・いやぁ・・・素晴らしい光景だった・・・）'
	DB	"I'll never forget that scene as long as I live..."
	DB	NEXT
;	DB	'（あづっ！？）'
	DB	"Ouch!"
	DB	FLG,F_COPYI,6,2
	DW	0000H

M15:		;考える
;	DB	'（俺の右目の上がズキズキいってるな。）'
	DB	"The area above my right eye is killing me."
	DB	NEXT
;	DB	'（・・・何でだ？）'
	DB	"I wonder what happened?"
	DB	FLG,F_COPYI,6,3
	DW	0000H

M16:		;考える
;	DB	'（ここ、どこだ？）'
	DB	"Where am I?"
	DB	NEXT
;	DB	'（・・・・・・・・・・・・・・・）'
	DB	".............."
	DB	NEXT
;	DB	'（・・・温泉旅館の、俺と誠の部屋だな。）'
	DB	"I'm in my room in the inn."
	DB	NEXT
;	DB	'（・・・・・・・・・誠のやつ、どこ行ったんだ？）'
	DB	"..........Where the hell is Makoto?"
	DB	FLG,F_COPYI,6,4
	DW	0000H

M17:		;考える
;	DB	'【%001】：うぅ・・・'
	DB	"%001:  Ouch...!"
	DB	NEXT
;	DB	'「あ、気が付いた？」'
	DB	"???:  Are you awake?"
	DB	NEXT
;	DB	'【%001】：うわっ！？'
	DB	"%001:  ....Who's there?"
	DB	NEXT
	T_CG 'CT12','Y',0,20,8
;	DB	'【今日子】：大丈夫？あたしが誰だか分かる？'
	DB	"Kyoko:  Are you alright? Do you know who I am?"
	DB	NEXT
;	DB	'【%001】：・・・今日子先生、２９才独身、無類の酒好きでガサツでズボラ・・・'
	DB	"%001:  ......Kyoko-sensei, age twenty-nine, single, you"
	DB	CR
	DB	"like different varieties of sake and beer and..."
	DB	NEXT
;	DB	'【今日子】：・・・どーやら大丈夫の様ね。'
	DB	"Kyoko:  ...........You're fine."
	DB C_BLD,C_V_OFF,1	;みる
	DB C_BLD,C_N_ON,1,3	;みる
	DB C_BLD,C_V_OFF,2	;話す
	DB C_BLD,C_V_ON,4	;考える
	DW	0000H

M18:		;麻雀
;	DB	'【%001】：それで、面子は？'
	DB	"%001:  Who's going to play?"
	DB	NEXT
	DB ANI,A_INIT
	BAK_INIT 'AB_39'
	DB BUF,B_COPY01
	T_CG 'CT14','Y',0,10,4
;	DB	'【誠】：オレと、お前。あと二人いるといーんだけど。'
	DB	"Makoto:  You, and me. We need two more players."
	DB	NEXT
	T_CG1 'CT06','Y',0,30,6
	DB ANI,A_ON,4
;	DB	'【亜希】：あたし、マージャン出来るわよ。'
	DB	"Aki:  I know how to play mah-jong."
	DB	NEXT
;	DB	'【誠】：ホントかぁ？'
	DB	"Makoto:  Really?"
	DB	NEXT
;	DB	'【亜希】：ウソじゃないわよ！ドラ○もんをそろえるゲームでしょ？'
	DB	"Aki:  It's the game where you have to make your opponent"
	DB	CR
	DB	"take the joker from you, right?"
	DB	NEXT
;	DB	'【誠】：そりゃ○ンジャラだ！ほら、行った行った！'
	DB	"Makoto:  That's Old Maid! Get out of here!"
	DB	NEXT
;	DB	'【亜希】：フンだ、イジワル！',CR,'美緒、行きましょ！卓球で勝負よ！'
	DB	"Aki:  Well, I don't need you! Come on, Mio, let's go"
	DB	CR
	DB	"play ping-pong."
	DB	NEXT
;	DB	'【美緒】：あうあう・・・'
	DB	"Mio:  Okay..."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT14','Y',0,10,4
;	DB	'美緒ちゃんは亜希ちゃんに引きずられていった。'
	DB	"Mio and Aki are gone."
	DB	NEXT
;	DB	'【鈴子】：私は知らないから、見てるわね。'
	DB	"Reiko:  I don't know how to play, so I'll just watch."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT02','Y',0,0,2
;	DB	'【清美】：わたくし、一通りルールは存じておりますわ。'
	DB	"Kiyomi:  I think I know how to play."
	DB	NEXT
;	DB	'【%001】：へぇ・・・意外。'
	DB	"%001:  You do? I'm surprised."
	DB	NEXT
	T_CG1 'CT05','C',0,35,5
	DB ANI,A_ON,2
;	DB	'【瑠璃】：・・・私も知ってるわ。'
	DB	"Ruri:  .......I know."
	DB	NEXT
;	DB	'【誠】：うそぉっ！？'
	DB	"Makoto:  Really?"
	DB	NEXT
;	DB	'【瑠璃】：さっき、本、読んだから。'
	DB	"Ruri:  ....I just read a book about mah-jong."
	DB	NEXT
;	DB	'白水さんの手には、「楽しい麻雀教室」という本が握られていた。'
	DB	"In Ruri's hand was a book entitled, 'Mah-jong For"
	DB	CR
	DB	"Beginners.'"
	DB	NEXT
;	DB	'【今日子】：さっきあたしが貸しといたのよ。んじゃ、',CR,'あたし達はギャラリーしながら飲みましょ、鈴子ちゃん！'
	DB	"Kyoko:  I just lent it to her. Let's have a few drinks"
	DB	CR
	DB	"while we play!"
	DB	NEXT
;	DB	'【鈴子】：わ、私突然卓球がしたくなっちゃったわ！'
	DB	"Reiko:  Oh, I just realized I wanted to play ping-pong!"
	DB	NEXT
;	DB	'鈴子さんは逃げるように去っていった。'
	DB	"Reiko goes off."
	DB	NEXT
;	DB	'【今日子】：ふぅ・・・しゃーない、もう一ッ風呂浴びてくるかぁ。'
	DB	"Kyoko:  Hmm, maybe I'll go back to the bath..."
	DB	NEXT
;	DB	'【今日子】：%001君、のぞいちゃイヤよ☆'
	DB	"Kyoko:  Don't peek now, %001!"
	DB	NEXT
;	DB	'【%001】：う・・・'
	DB	"%001:  ................"
	DB	NEXT
;	DB	'ちなみに、総合トップは「ダマテンの瑠璃」さんだった。'
	DB	"We played mah-jong for hours that night. In the end, 'Lucky"
	DB	CR
	DB	"Ruri' was the winner."
	DB	NEXT
	B_O B_SUDA
	DB FLG,F_JR
	DW FAREWELL

M19:		;トランプ
;	DB	'【%001】：そ～だな、ババ抜きでもしよーか。'
	DB	"%001:  Okay, let's play Old Maid."
	DB	NEXT
	DB ANI,A_INIT
	BAK_INIT 'AB_39'
	DB BUF,B_COPY01
	T_CG 'CT14','Y',0,10,4
;	DB	'【誠】：%001～、ババ抜きはマズイんじゃねぇの？'
	DB	"Makoto:  %001! D'you think that's a good idea?"
	DB	NEXT
;	DB	'【%001】：そうか？'
	DB	"%001:  Why not?"
	DB	NEXT
;	DB	'【今日子】：誠く～ん、何か言いたそうねェ。'
	DB	"Kyoko:  Makoto, did I hear you say anything?"
	DB	NEXT
;	DB	'【誠】：いやぁ、オレは８人じゃ多すぎるんじゃないか、って思っただけですよ。'
	DB	"Makoto:  No, ma'am!"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT05','C',0,25,4
;	DB	'【瑠璃】：私・・・そのゲーム知らないから。'
	DB	"Ruri:  I don't know this game."
	DB	NEXT
;	DB	'【鈴子】：え・・・'
	DB	"Reiko:  What?"
	DB	NEXT
;	DB	'【鈴子】：あなた、トランプやった事ないの？'
	DB	"Reiko:  You've never played Old Maid?"
	DB	NEXT
;	DB	'白水さんはコクリと頷いた。'
	DB	"Ruri just shakes her head."
	DB	NEXT
;	DB	'【清美】：大丈夫ですわ、すぐ覚えられますわよ。'
	DB	"Kiyomi:  It's okay. You'll pick it up in no time."
	DB	NEXT
;	DB	'・・・・・・そして・・・・・・'
	DB	"......And so..."
	DB	NEXT
;	DB	'【%001】：う～ん・・・'
	DB	"%001:  Hmmmmm...."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ..............."
	DB	NEXT
;	DB	'【%001】：こっち！'
	DB	"%001:  This card...!"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'【%001】：・・・はババだから、こっちだ！'
	DB	"%001:  No wait, that's probably the joker. How about this"
	DB	CR
	DB	"one?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ................"
	DB	NEXT
;	DB	'（表情が読めん・・・）'
	DB	"I can't read her expression..."
	DB	NEXT
;	DB	'【今日子】：ほらほら、負けた方は日本酒一気飲みよン★'
	DB	"Kyoko:  Whoever loses has to drink with me!"
	DB	NEXT
;	DB	'すでに俺と白水さん以外は「あがり」になっている。'
	DB	"Suddenly everyone except Ruri and I dropped out of the game."
	DB	NEXT
;	DB	'俺の手札は１枚。白水さんは２枚。'
	DB	"I've got one card. She's got two. One of them is the joker."
	DB	NEXT
;	DB	'勝つためにはここでジョーカーを引いてはならない。'
	DB	"I've got to pick the other card..."
	DB	NEXT
;	DB	'（右か・・・左か・・・？）'
	DB	"Should I pick the right one, or the left one?"
	DB	C_BLD,C_V_ON,5	;その他全て消し
	DB	C_BLD,C_V_ON,6	;その他全て消し
	DB	C_BLD,C_V_ON,9	;その他全て消し
	DB	C_BLD,C_V_OFF,7	;
	DB	C_BLD,C_V_OFF,8	;
	DW	0000H

M20:		;右
;	DB	'【%001】：こっち！'
	DB	"%001:  This card!"
	DB	NEXT
;	DB	'ぶっぶー！'
	DB	"Oh no!"
	DB	NEXT
;	DB	'（ババ・・・）'
	DB	"I picked the joker!"
	DB	NEXT
;	DB	'【瑠璃】：はい・・・'
	DB	"Ruri:  I'll take this card."
	DB	NEXT
;	DB	'【%001】：あ゛！？'
	DB	"%001:  No!"
	DB	NEXT
;	DB	'俺がジョーカーを引いてうろたえてる隙に、白水さんは素早く俺の手札を掠め取った。'
	DB	"Before I could mix up the two cards I had, she took the"
	DB	CR
	DB	"first card I had."
	DB	NEXT
	K_CG 'CT05','K',25,5
;	DB	'【瑠璃】：私の勝ちね、%001君。'
	DB	"Ruri:  I win, %001."
	DB	NEXT
;	DB	'【今日子】：弱いわねー、%001君って。ほら、飲んで飲んで。'
	DB	"Kyoko:  %001, you lost! Oh well, come over here and have"
	DB	CR
	DB	"a drink!"
	DB	NEXT
;	DB	'【%001】：んぐ、んぐ・・・'
	DB	"%001:  No...."
	DB	NEXT
;	DB	'【%001】：ぶっはー、くっそー、もう一度勝負！'
	DB	"%001:  This can't be happening to me! I demand a rematch!"
	DB	NEXT
;	DB	'【瑠璃】：クス・・・。'
	DB	"Ruri:  ......*smile*...."
	DB	NEXT
	B_O B_FADE
;	DB	'・・・俺たちは夜遅くまでトランプをしていた。'
	DB	"We stayed up very late playing cards..."
	DB	NEXT
;	DB	'ただのババ抜きをこんなに面白いと感じたのは、もう何年振りだろう？'
	DB	"I never thought that Old Maid could be so fun..."
	DB	NEXT
;	DB	'もっとも、俺は美緒ちゃんの次に酔い潰れたので、結果がどうなったかは知らない。'
	DB	"Eventually I passed out drunk, thanks to Kyoko-sensei. I"
	DB	CR
	DB	"didn't see how the rest of the evening turned out."
	DB	NEXT
	B_O B_SUDA
	DB FLG,F_JR
	DW FAREWELL

M21:		;左
;	DB	'【%001】：こっち！'
	DB	"%001:  This card!"
	DB	NEXT
;	DB	'ぴんぽーん！'
	DB	"Yes!!"
	DB	NEXT
;	DB	'【%001】：うし、あがり！'
	DB	"%001:  Okay, I'm out!"
	DB	NEXT
	K_CG 'CT05','I',25,5
;	DB	'【瑠璃】：・・・負けちゃったの？私・・・'
	DB	"Ruri:  ........Did I lose?"
	DB	NEXT
;	DB	'【今日子】：さて、決まりは決まりだから飲んでもらうわよ、瑠璃ちゃん。'
	DB	"Kyoko:  Okay, Ruri. A deal is a deal. Come over here and"
	DB	CR
	DB	"drink with me."
	DB	NEXT
;	DB	'【亜希】：やっばーい・・・'
	DB	"Aki:  .......Oh no!"
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  ................."
	DB	NEXT
;	DB	'亜希ちゃんと美緒ちゃんが部屋の隅に退避する。'
	DB	"Aki and Mio both retreat to the corner of the room."
	DB	NEXT
;	DB	'（・・・そか、白水さんは飲むと記憶が飛んじゃうんだった。）'
	DB	"That's right. Ruri forgot everything that happened after she"
	DB	CR
	DB	"drank the last time."
	DB	NEXT
;	DB	'（・・・そうなったら、思い出作りどころじゃないな・・・よし。）'
	DB	"We want her to make memories on this trip, not lose them."
	DB	CR
	DB	"I've got to do something."
	DB	NEXT
;	DB	'俺は白水さんのコップをひったくって、一気に飲み干した。'
	DB	"I took the cup out of Ruri's hands and drank the sake myself."
	DB	NEXT
;	DB	'【瑠璃】：%001君・・・？'
	DB	"Ruri:  %001....?"
	DB	NEXT
;	DB	'【%001】：いや、ちょうど飲みてぇなーって思ったから。'
	DB	"%001:  I just got a little thirsty there, sorry!"
	DB	NEXT
;	DB	'【誠】：間接キッスだ、ひゅーひゅー！'
	DB	"Makoto:  Indirect kiss! Indirect kiss! Oo oo oo!"
	DB	NEXT
;	DB	'【%001】：お前は小学生か！？'
	DB	"%001:  Grow up, Makoto!"
	DB	NEXT
	K_CG 'CT05','K',25,5
;	DB	'【瑠璃】：・・・クス・・・'
	DB	"Ruri:  .............*smile*"
	DB	NEXT
;	DB	'【鈴子】：・・・さぁ、次の勝負行くわよ！'
	DB	"Reiko:  Let's play again!"
	DB	NEXT
;	DB	'【清美】：%001さん、大丈夫ですか？さっきからずっと飲みっ放しのようですが。'
	DB	"Kiyomi:  %001, are you alright? Don't drink too much..."
	DB	NEXT
;	DB	'【%001】：へーきへーき、万事オッケー！'
	DB	"%001:  I'm fine! Everything is fine!"
	DB	NEXT
	B_O B_FADE
;	DB	'・・・俺たちは夜遅くまでトランプをしていた。'
	DB	"We played cards until late that night."
	DB	NEXT
;	DB	'ただのババ抜きをこんなに面白いと感じたのは、もう何年振りだろう？'
	DB	"I never knew Old Maid could be so much fun..."
	DB	NEXT
	B_O B_SUDA
	DB FLG,F_JR
	DW FAREWELL

M22:		;卓球
	DB ANI,A_INIT
	BAK_INIT 'AB_39'
	DB BUF,B_COPY01
;	DB	'【%001】：うーし、それじゃやるか。'
	DB	"%001:  Okay, let's go."
	DB	NEXT
	TU_CG 'CT03','Y',0,0,3
	T_CG 'CT06','Y',0,30,6
	DB ANI,A_ON,3
;	DB	'【亜希】：ちょっと待った！'
	DB	"Aki:  Just a minute!"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'【亜希】：%001先輩はラケットつかっちゃダメ！スリッパでやるのよ。当然のハンデでしょ？'
	DB	"Aki:  You aren't allowed to use a ping-pong raquet. You"
	DB	CR
	DB	"have to hit the ball with a slipper. It's a handicap"
	DB	CR
	DB	"because you're a man. Okay?"
	DB	NEXT
;	DB	'【%001】：・・・ま、いいけど。'
	DB	"%001:  ....I guess."
	DB	NEXT
;	DB	'【亜希】：じゃあ美緒、最初はあんたが審判やって。'
	DB	"Aki:  Okay, %001 and me first. Okay, Mio?"
	DB	NEXT
;	DB	'【美緒】：うん。'
	DB	"Mio:  Okay."
	DB	NEXT
;	DB	'【亜希】：じゃ、あたしから行くわよ！'
	DB	"Aki:  I'll serve."
	DB	NEXT
;	DB	'カコッ！'
	DB	"*BAT*"
	DB	NEXT
	DB	CR
;	DB	'　　　　　　　　　　　　　　　カッ！'
	DB	"                               *KACHA*"
	DB	NEXT
;	DB	'　　　　　　　　　　　　　　　　　　　　　　　　ぺちっ！'
	DB	"       *KACHA*"
	DB	NEXT
	DB	CR
;	DB	'　　　　　　カッ！'
	DB	"                                       *ZING*"
	DB	NEXT
;	DB	'【亜希】：あっ！'
	DB	"Aki:  Ha!"
	DB	NEXT
;	DB	'【美緒】：０－１ね。'
	DB	"Mio:  0-1!"
	DB	NEXT
;	DB	'【亜希】：さすが先輩、伊達に一年余計に生きてないわね。'
	DB	"Aki:  What's the matter, %001?"
	DB	NEXT
;	DB	'【%001】：俺はスリッパで卓球やるのは初めてだぞ。'
	DB	"%001:  I've never played ping-pong with a slipper before!"
	DB	NEXT
;	DB	'【誠】：お～、やってるやってる。'
	DB	"Makoto:  Oh, look at them go."
	DB	NEXT
;	DB	'【清美】：わたくしたちも、卓球に入れていただけますか？'
	DB	"Kiyomi:  We'd like to play, too."
	DB	NEXT
;	DB	'【亜希】：ほ～ら、やっぱり温泉と言えば卓球でしょ！'
	DB	"Aki:  See what I told you? Playing ping-pong in a ryokan,"
	DB	CR
	DB	"wearing yukata, that's what it means to be Japanese."
	DB	NEXT
;	DB	'【鈴子】：それじゃ、私たちは隣使うわね。'
	DB	"Reiko:  We'll use this table over here."
	DB	NEXT
;	DB	'【誠】：鈴子さん！俺とダブルス組みましょう！'
	DB	"Makoto:  Reiko, will you play doubles with me?"
	DB	NEXT
;	DB	'【鈴子】：いいけど、清美ちゃんのパートナーは？'
	DB	"Reiko:  I don't mind. But who'll be Kiyomi's partner?"
	DB	NEXT
;	DB	'【清美】：瑠璃さん、私のパートナーになっていただけますか？'
	DB	"Kiyomi:  Ruri, will you be by partner at ping-pong?"
	DB	NEXT
;	DB	'【瑠璃】：・・・いいの？'
	DB	"Ruri:  .........You don't mind?"
	DB	NEXT
;	DB	'【清美】：もちろんですわ！'
	DB	"Kiyomi:  Of course not!"
	DB	NEXT
;	DB	'カコッ！'
	DB	"*BAT*"
	DB	NEXT
	DB	CR
;	DB	'　　　　　　　　　　　　　　　カッ！'
	DB	"                               *KACHA*"
	DB	NEXT
;	DB	'　　　　　　　　　　　　　　　　　　　　　　　　ぺちっ！'
	DB	"       *KACHA*"
	DB	NEXT
	DB	CR
;	DB	'　　　　　　カッ！'
	DB	"                                       *KACHA*"
	DB	NEXT
;	DB	'カコッ！'
	DB	CR
	DB	CR
	DB	"    *GATCHA*"
	DB	NEXT
	DB	CR
;	DB	'      　　　　　　　　　　　　　　　　カコッ！'
	DB	"                                             *GACHA*"
	DB	NEXT
;	DB	'・・・ってな具合いで、俺たちは卓球で心地好い汗を流した。'
	DB	"We played ping-pong that way until late at night."
	DB	NEXT
	B_O B_SUDA
	DB FLG,F_JR
	DW FAREWELL

FAREWELL:
;	DB	'・・・そして、翌日。'
	DB	"............The next day."
	DB	NEXT
	BAK_INIT 'AB_43_1'
	DB BUF,B_COPY01
;	DB	'俺たちは、自分たちの街に帰って来た。'
	DB	"We arrived back home."
	DB	NEXT
	T_CG 'CT12','C','K',10,8
;	DB	'【今日子】：いやー、充実した二日間だったわねー。'
	DB	"Kyoko:  That was a great experience."
	DB	NEXT
;	DB	'【%001】：先生はずっとお酒飲んでただけでしょーが。'
	DB	"%001:  You didn't do anything but drink!"
	DB	NEXT
;	DB	'【今日子】：だから充実してるんじゃない。'
	DB	"Kyoko:  That's what I meant."
	DB	NEXT
;	DB	'【%001】：はいはい。'
	DB	"%001:  .......Oh."
	DB	NEXT
	T_CG1 'CT05','C','K',30,5
;	DB	'【瑠璃】：・・・みんな・・・ありがとう・・・楽しかった。'
	DB	"Ruri:  Everyone........ Thank you so much. It was really fun."
	DB	NEXT
;	DB	'【瑠璃】：私・・・この旅行のこと、絶対忘れない・・・。'
	DB	"Ruri:  I'll never forget...any of you..."
	DB	NEXT
;	DB	'【今日子】：帰るのね・・・お母さんのところに。'
	DB	"Kyoko:  So you're going back to live with your mother"
	DB	CR
	DB	"after all?"
	DB	NEXT
;	DB	'【瑠璃】：・・・はい。'
	DB	"Ruri:  .....Yes."
	DB	NEXT
;	DB	'【瑠璃】：私が帰らないと、母は独りぼっちだから・・・'
	DB	"Ruri:  If I don't go home, my mother will be all alone."
	DB	NEXT
;	DB	'【誠】：白水さん・・・俺たち、待ってるからさ。'
	DB	"Makoto:  Ruri... We'll wait for you."
	DB	NEXT
;	DB	'【清美】：いつかまた、私たちのところに帰ってきて下さいね・・・'
	DB	"Kiyomi:  Come back to us anytime you like."
	DB	NEXT
;	DB	'【瑠璃】：約束は出来ないわ。'
	DB	"Ruri:  I can't promise anything."
	DB	NEXT
;	DB	'【瑠璃】：でも・・・いつか、きっと・・・'
	DB	"Ruri:  But.......someday......someday..."
	DB	NEXT
;	DB	'【%001】：じゃあ、さよならはナシだな。'
	DB	"%001:  So don't say 'sayonara.'"
	DB	NEXT
;	DB	'【%001】：・・・またな、白水さん。'
	DB	"%001:  We'll see you later, Shiromizu-san."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・またね、みんな。'
	DB	"Ruri:  ..........Thanks. See you all later."
	DB	NEXT
	B_O B_FADE
;	DB	'・・・こうして、白水　瑠璃さんは俺達の前から姿を消した。'
	DB	"And then Ruri Shiromizu was gone."
	DB	NEXT
;	DB	'いつかまた会えるという、ささやかな希望を残して。'
	DB	"Leaving only the hope that we might see her again someday."
	DB	NEXT
	DB SINARIO,'CSB01.OVL',0
	DW	0000H


end
;	さ