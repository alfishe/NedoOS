;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６１５＿Ｈ
;		浜辺の恵依美

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,NN4,-1
CM3:	DW	VV3,	NN1,-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0
;VV4:	DB	4,	'もう寝る',0
VV4:	DB	4,	"GO TO BED",0

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	"MEIMI",0
;NN2:	DB	2,	'海',0
NN2:	DB	2,	"OCEAN",0
;NN3:	DB	3,	'月',0
NN3:	DB	3,	"MOON",0
;NN4:	DB	4,	'瑠璃のこと',0
NN4:	DB	4,	"ABOUT RURI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　恵依美２
S2:		DW	VV1, NN2,  2, M4		;見る　海２
S3:		DW	VV1, NN3,  3, M6		;見る　月２
S4:		DW	VV2, NN1,  4, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20, M21, M22, M23, M24, M25, M26, M27, M28, M29, M30		;話す　恵依美２３
S5:		DW	VV2, NN4,  5, M31, M32, M33, M34		;話す　瑠璃のこと４
S6:		DW	VV3, NN1,  6, M35		;考える　恵依美１
S7:		DW	VV4,  -1,  7, M36		;もう寝る１


;イニシャルメッセージ
M1:
	DB	BGM,9
	BAK_INIT "AB_17_3"
	DB	BUF,B_COPY01
	T_CG "CT08","F",0,15,1
;	DB	'【%001】：・・・よ、何やってんだい？'
	DB	"%001:  ...Yo, whatcha doin'?"
	DB	NEXT
;	DB	'【恵依美】：きゃっ！？'
	DB	"Meimi:  Wah!"
	DB	PAUSE
;	DB	'・・・・・・%001？'
	DB	" .....%001?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yeah."
	DB	NEXT
;	DB	'【恵依美】：・・・も～、おどかさないでよ。'
	DB	"Meimi:  Hey, don't do that."
	DB	NEXT
;	DB	'【%001】：わりわり。'
	DB	"%001:  Sorry."
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_N_ON,2,2
	DB G_FLG,G_COPYI,184,1
	DB G_FLG,G_COPYF,180,180
	DB	FLG,F_CALI,180,15
	DB G_FLG,G_COPYG,180,180
	DW	0000H

M2:		;見る　恵依美１
;	DB	'・・・いつもは強気な中野が大人しいと、なんだか変だ。'
	DB	"It's strange for her to be so quiet."
;	DB	NEXT
;	DB	'・・・落ち着かない、と言うか。'
;	DB	"Or maybe just tense."
;	DB	NEXT
;	DB	'・・・言ったら淒い勢いで怒るんだろうな・・・'
;	DB	"Well, she could actually be really angry..."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　恵依美２
;	DB	'ちらっと、中野の方を見る。いつの間にか、中野も月を見上げている。'
	DB	"I sneak a glimpse of Meimi. She was looking at the moon,"
	DB	CR
	DB	"too."
	DB	NEXT
;	DB	'月明かりが仄かに中野を照らしている。太陽の下での元気いっぱいな中野とは違う、なにか、こう・・・'
	DB	"The faint moonlight fell upon Meimi. She seemed somehow"
	DB	CR
	DB	"very different from the high-energy girl she always is"
	DB	CR
	DB	"during the day..."
	DB	NEXT
;	DB	'・・・神秘的というか・・・とにかく、そんな感じだ。'
	DB	"...Somehow mysterious."
	DW	0000H

M4:		;見る　海１
;	DB	'・・・やっぱり、ダメだ。'
	DB	"Hmmm."
	DB	NEXT
;	DB	'夜の海が神秘的、ってのは、俺にはわからない。'
	DB	"I just don't understand why the night ocean is supposed"
	DB	CR
	DB	"to be mysterious."
	DB	NEXT
;	DB	'ただ、恐いってイメージしかないからな・・・'
	DB	"It only has a scary image for me."
	DB	NEXT
;	DB	'・・・俺の場合、特に昼夜は関係ないんだけど。'
	DB	"Although I don't have a specific reason to be scared"
	DB	CR
	DB	"of it at night."
	DW	0000H


M6:		;見る　月１
;	DB	'綺麗って言ったら、やっぱり月の方が綺麗だと思うなぁ。'
	DB	"If something is beautiful, then it's the moon, by far."
	DB	NEXT
;	DB	'だから・・・泳げないからって訳じゃないぞ。'
	DB	"But it isn't because I can't swim."
	DB	NEXT
;	DB	'って中野に言っても、きっと信じないだろうな・・・'
	DB	"But even if I told Meimi, she wouldn't believe me..."
	DW	0000H

M8:		;話す　恵依美１
;	DB	'【%001】：で？何やってんだ１人で？'
	DB	"%001:  What are you doing here by yourself?"
	DB	NEXT
;	DB	'【恵依美】：・・・あたしは・・・'
	DB	"Meimi:  ...Me?"
	DB	NEXT
;	DB	'【恵依美】：%001こそ、何やってんのよ？'
	DB	"Meimi:  What about you?"
	DB	NEXT
;	DB	'【%001】：俺？'
;	DB	"%001:  Me?"
;	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'【%001】：さあ？'
	DB	"%001:  Just walking on the beach, I guess."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M9:		;話す　恵依美２
;	DB	'【%001】：・・・ま、いいや。人間、何となくやっちまう事だってあるさ。'
	DB	"%001:  It's nice out here, isn't it?"
	DB	NEXT
;	DB	'【恵依美】：相っ変わらず、い～加減ね～。'
	DB	"Meimi:  Yes, I guess."
	DB	NEXT
;	DB	'【%001】：・・・悪かったな。'
;	DB	"%001:  Sorry."
;	DB	NEXT
;	DB	'【恵依美】：あはは・・・・・・'
;	DB	"Meimi:  Ah, hahaha."
;	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ............."
	DB	NEXT
;	DB	'【恵依美】：ねえ、%001。'
	DB	"Meimi:  %001?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Hm?"
	DB	NEXT
;	DB	'【恵依美】：少し・・・歩かない？'
	DB	"Meimi:  D'you want to take a walk?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、いいぜ。'
	DB	"%001:  Sure, why not?"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M10:		;話す　恵依美３
;	DB	'【恵依美】：・・・夜の海って、神秘的よね。'
	DB	"Meimi:  The ocean at night is really mysterious, isn't it?"
	DB	NEXT
;	DB	'【%001】：俺は恐いぞ。はっきり言って。'
	DB	"%001:  To tell the truth, I'm scared of it."
	DB	NEXT
;	DB	'【恵依美】：それは、%001が泳げないからでしょ。'
	DB	"Meimi:  That's probably because you can't swim, %001."
	DB	NEXT
;	DB	'【%001】：・・・ど～せ俺はかなづちさ、しくしく・・・'
	DB	"%001:  ...I guess I'm just the non-swimmer...*sob*..."
	DB	NEXT
;	DB	'【恵依美】：よしよし、泣かない泣かない。'
	DB	"Meimi:  There there, don't cry."
	DB	NEXT
;	DB	'【%001】：・・・バカにしてるだろお前。'
	DB	"%001:  You're making fun of me."
	DB	NEXT
;	DB	'【恵依美】：あはは、ちょっとだけ。'
	DB	"Meimi:  Ha, ha. Maybe a little"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・ちぇ。'
	DB	"%001:  Doh!"
	DB	FLG,F_COPYI,4,3
	DW	0000H

M11:		;話す　恵依美４
;	DB	'【%001】：・・・そ～言えば、吉田は泳げるよ～になったのかな？'
	DB	"%001:  By the way, do you know if Seia learned to swim?"
	DB	CR
	DB	"Reiko was going to teach her."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・知らない。'
	DB	"Meimi:  I don't know."
	DB	NEXT
;	DB	'【%001】：そか？・・・中野なら、知ってると思ったんだけどな。'
	DB	"%001:  Really? I thought you would know."
	DB	NEXT
	K_CG "CT08","D",15,2
;	DB	'【恵依美】：・・・知らないものは、知らないもん！'
	DB	"Meimi:  I don't, okay?"
	DB	NEXT
;	DB	'【%001】：・・・・・・何怒ってんだ？'
	DB	"%001:  What are you mad about?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ............."
	DB	FLG,F_COPYI,4,4
	DW	0000H

M12:		;話す　恵依美５
;	DB	'【%001】：・・・なぁ・・・何かあったのか？この頃お前、変だぞ？'
	DB	"%001:  ...Did anything happen? What's the deal with you"
	DB	CR
	DB	"lately?"
	DB	NEXT
;	DB	'【%001】：いつぞや河原で石投げてた時もそうだったし、昼間だって・・・'
	DB	"%001:  You were like that earlier today at the river when"
	DB	CR
	DB	"we were skipping stones..."
	DB	NEXT
;	DB	'【恵依美】：・・・！'
	DB	"Meimi:  ......!"
	DB	FLG,F_COPYI,4,5
	DW	0000H

M13:		;話す　恵依美６
;	DB	'【%001】：・・・なあ中野・・・俺、なんかしたのか？'
	DB	"%001:  Is it something I've done?"
	DB	NEXT
;	DB	'【%001】：ホントにわかんね～んだよ・・・言ってくれれば、気をつけるからさ。'
	DB	"%001:  I really don't know what it would be. But if you"
	DB	CR
	DB	"tell what it is, I'll make sure I never do it again."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  .............."
	DB	FLG,F_COPYI,4,6
	DW	0000H

M14:		;話す　恵依美７
;	DB	'【%001】：中野・・・・・・聞いてる？'
	DB	"%001:  Meimi, are you listening?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ..........."
	DB	NEXT
	B_P1 B_NORM
;	DB	'ばふっ。'
	DB	"*THUMP*"
	DB	NEXT
;	DB	'・・と音を立てて、中野はつまずいて顔から砂に突っ込んだ。'
	DB	".....Meimi tripped in the sand, face down."
	DB	NEXT
;	DB	'【%001】：・・・お、おい！？'
	DB	"%001:  Meimi?"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT08","F",'I',15,3
;	DB	'【恵依美】：・・・いった～い・・・'
	DB	"Meimi:  .....Oh, I'm all dirty now."
	DB	FLG,F_COPYI,4,7
	DW	0000H

M15:		;話す　恵依美８
;	DB	'【%001】：大丈夫か・・・よっ、と。'
	DB	"%001:  Are you all right?"
	DB	NEXT
;	DB	'俺は中野の手を取り、立たせた。'
	DB	"I gave Meimi my hand and pulled her up."
	DB	NEXT
;	DB	'【%001】：何にもねーところで、コケるなよな。'
	DB	"%001:  Doesn't seem like there was anything here to trip ",CR,"over."
	DB	NEXT
;	DB	'【%001】：・・・あーあ、砂だらけじゃね～か。'
	DB	"%001:  ...Look, you've got sand all over you."
	DB	NEXT
;	DB	'俺は服や髮に付いた砂を払ってやる。'
	DB	"I brushed the sand off her clothes and her hair."
	DB	NEXT
;	DB	'（・・・なんか、親になった気分だ・・・）'
	DB	"...Weird, I feel like her mother or something."
	DB	NEXT
	T_CG1 "CT08","F",0,15,1
;	DB	'【恵依美】：・・・・・・ありがと、%001。'
	DB	"Meimi:  Thanks, %001."
	DB	NEXT
;	DB	'【%001】：なになに。'
	DB	"%001:  No sweat."
	DB	FLG,F_COPYI,4,8
	DW	0000H

M16:		;話す　恵依美９
;	DB	'【%001】：大丈夫か？どっか痛くないか？'
	DB	"%001:  Are you okay? Did you hurt yourself?"
	DB	NEXT
;	DB	'【恵依美】：うん、全然平気。ありがと。'
	DB	"Meimi:  No, I'm fine. Thanks."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  Good."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ........."
	DB	NEXT
;	DB	'【恵依美】：ねえ%001。'
	DB	"Meimi:  Hey %001."
	DB	PAUSE
;	DB	'・・・・・・白水さんって、どんな人？'
	DB	" So what kind of person is Ruri?"
	DB	FLG,F_COPYI,4,9
	DW	0000H

M17:		;話す　恵依美１０
;	DB	'【%001】：・・・・・・へ？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【恵依美】：あ、違うの！そうじゃなくて・・・・・・'
	DB	"Meimi:  Oh, that's not what I mean! I..."
	DB	PAUSE,CR
;	DB	'お友達になりたいな～、と思って。'
	DB	"I thought I'd like to become her friend, that's all." 
	DB	NEXT
;	DB	'【%001】：・・・・・・ああ、そーゆー事か。'
	DB	"%001:  Oh, you did, huh?"
	DB C_BLD,C_N_ON,2,1
	DB C_BLD,C_N_OFF,2,2
	DB	FLG,F_COPYI,4,10
	DW	0000H

M18:		;話す　恵依美１１
;	DB	'【恵依美】：・・・と、ところでさ%001。%001は将来、何になるの？'
	DB	"Meimi:  Um, so, %001. What do you want to be?"
	DB	NEXT
;	DB	'【%001】：・・・俺の・・・将来？'
	DB	"%001:  When I...grow up...?"
	DB	NEXT
;	DB	'【恵依美】：うん、将来の夢・・・・・・'
	DB	"Meimi:  Yeah, your dreams..."
	DB	PAUSE
;	DB	'あたしね、ママみたいになるのが夢なんだ。'
	DB	" My dream is to be what my Mom"
	DB	CR
	DB	"was."
	DB	NEXT
;	DB	'【%001】：・・・確か、サーカスのスターだったんだっけ？'
	DB	"%001:  She was a circus star, right?"
	DB	NEXT
;	DB	'【恵依美】：うん！空中ブランコの花形スター！'
	DB	"Meimi:  Yes! She's was a trapeze artist!"
	DB	FLG,F_COPYI,4,11
	DW	0000H

M19:		;話す　恵依美１２
;	DB	'【恵依美】：今でもはっきり覚えてる・・・スポットライトの中で、'
	DB	"Meimi:  I still remember it so clearly, my Mom in the"
	DB	CR
	DB	"spotlight, with everybody applauding."
	DB	NEXT
;	DB	'【恵依美】：そしてママは軽やかに空を切って、天幕に舞うの。'
	DB	"Meimi:  She would fly through the air, above everyone in"
	DB	CR
	DB	"the tent."
	DB	NEXT
;	DB	'【恵依美】：すっごく綺麗だった・・・ママは天使なんだって思った。'
	DB	"Meimi:  She was beautiful.  I thought she was an angel."
	DB	NEXT
;	DB	'【恵依美】：家にいるママも美人だってみんな言ってくれるけど・・・'
	DB	"Meimi:  When Mom was at home, everyone always said that"
	DB	CR
	DB	"she was pretty, but... I always thought she was the most"
	DB	CR
	DB	"beautiful when she was performing."
	DB	NEXT
;	DB	'【恵依美】：・・・あたしも、あんな風になりたい。一生なれないかも'
	DB	"Meimi:  ...I want to be just like that, even though I'll"
	DB	CR
	DB	"probably have a short life. She wasn't well-known, but"
	DB	CR
	DB	"I always want to follow her..."
	DB	NEXT
;	DB	'【恵依美】：『あたしは、ママの子供なんだ』って、胸張って言えるように・・・・・・'
	DB	"Meimi:  You could say that I feel very strongly in my"
	DB	CR
	DB	"heart that I'm her child."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ....................."
	DB	NEXT
;	DB	'（そうか・・・中野には、尊敬出来る人がいるんだな。）'
	DB	"(So, I guess there is someone that Meimi can respect.)"
	DB	FLG,F_COPYI,4,12
	DW	0000H

M20:		;話す　恵依美１３
;	DB	'【%001】：・・・絶対なれるさ、中野なら。'
	DB	"%001:  I'm sure you can do it, Meimi."
	DB	NEXT
;	DB	'【%001】：それだけしっかりした目標があるんだし、中野の根性なら'
	DB	"%001:  If you know what you want, I'm sure you have the"
	DB	CR
	DB	"guts to reach it, Meimi."
;	DB	'大丈夫。俺が保証する。'
	DB	" It'll be fine. I guarantee it."
	DB	NEXT
	K_CG "CT08",'K',15,4
;	DB	'【恵依美】：あはっ・・・ありがと、%001。'
	DB	"Meimi:  Ah, Thanks, %001."
	DB	NEXT
	T_CG1 "CT08","F",0,15,1
;	DB	'【恵依美】：じゃあさ・・・今度は%001の夢、聞かせてよ。'
	DB	"Meimi:  So tell me your dream now, %001."
	DB	NEXT
;	DB	'【%001】：俺、か・・・・・・'
	DB	"%001:  My dream...?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .............."
	DB	NEXT
;	DB	'【%001】：俺には、無いな。'
	DB	"%001:  You know, don't really have one."
	DB	FLG,F_COPYI,4,13
	DB C_BLD,C_V_OFF,3
	DW	0000H

M21:		;話す　恵依美１４
;	DB	'【恵依美】：・・・無い、って・・・どうして？'
	DB	"Meimi:  You don't have one? Why?"
	DB	NEXT
;	DB	'【恵依美】：%001、何でも出来るじゃない。'
	DB	"Meimi:  But you can do anything, %001."
	DB	NEXT
;	DB	'【%001】：・・・ああ、だからなんだよ。'
	DB	"%001:  ...Yeah, well I guess that's the reason."
	DB	NEXT
;	DB	'【恵依美】：・・・え？'
	DB	"Meimi:  ...Eh?"
	DB	FLG,F_COPYI,4,14
	DW	0000H

M22:		;話す　恵依美１５
;	DB	'【%001】：確かに俺は、何でも出来る。'
	DB	"%001:  It does seem like I can do anything."
	DB	NEXT
;	DB	'【%001】：・・・だけどさ、それって目標が無いって事なんだよな。'
	DB	"%001:  ...But I think that's the reason why I don't have ",CR,"any goals."
	DB	NEXT
;	DB	'【%001】：俺は、大抵の事は１日で覚えちまう。そして覚えちまったら、'
	DB	"%001:  I can learn most things in just a day. So when I've"
	DB	CR
	DB	"learned, nobody beats me."
	DB	NEXT
;	DB	'【%001】：山登りやる奴は「そこに山があるから」登るって話だけど、'
	DB	"%001:  You know that mountain climber who said he climbed a"
	DB	CR
	DB	"mountain 'because it was there'?"
	DB	NEXT
	DB	"%001:  But it's not really a challenge to climb a mountain in"
	DB	CR
	DB	"one step, is it?"
	DB	NEXT
	K_CG "CT08",'I',15,3
;	DB	'【恵依美】：うん・・・'
	DB	"Meimi:  I guess."
	DB	NEXT
;	DB	'【%001】：すぐに掴めちまうもんに・・・夢なんかねぇ。'
	DB	"%001:  There's no point in doing something that's so easy"
	DB	CR
	DB	"to reach."
	DB	FLG,F_COPYI,4,15
	DW	0000H

M23:		;話す　恵依美１６
;	DB	'【恵依美】：・・・でも%001！'
	DB	"Meimi:  But %001!"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Hm?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DB	NEXT
;	DB	'【%001】：・・・あ～、何だ。'
	DB	"%001:  Oh, well."
	DB	NEXT
;	DB	'【%001】：まぁ今はそんな感じだけどさ、その内見付かるかもしんねぇし・・・気長にやるよ、卒業までに决めりゃあい～んだから。'
	DB	"%001:  Well, that's how I feel right now, but I'm sure I'll"
	DB	CR
	DB	"find something. I'll just be patient, and I have to"
	DB	CR
	DB	"decide by the time I graduate anyway."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ..............."
	DB	NEXT
;	DB	'【%001】：・・・だからさ、そんな顔すんなって。俺は、大丈夫だから。'
	DB	"%001:  Don't look at me like that. I'm fine, okay?"
	DB	NEXT
;	DB	'【恵依美】：・・・うん・・・'
	DB	"Meimi:  ....Okay...."
	DB	FLG,F_COPYI,4,16
	DW	0000H

M24:		;話す　恵依美１７
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .............."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  .............."
	DB	NEXT
;	DB	'（なんか・・・気まずいなぁ）'
	DB	"Now I feel all embarrassed."
	DB	FLG,F_COPYI,4,17
	DW	0000H

M25:		;話す　恵依美１８
;	DB	'【%001】：・・・で？何だ話って？'
	DB	"%001:  Well, what is it?"
	DB	NEXT
;	DB	'【恵依美】：う、うん・・・・・・'
	DB	"Meimi:  Uh, um..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  .............."
	DB	NEXT
;	DB	'【%001】：？どした？早く言えよ。らしくもない。'
	DB	"%001:  What? What do you want to say?"
	DB	NEXT
;	DB	'【恵依美】：う、うん・・・・・・'
	DB	"Meimi:  Uh..."
	DB	FLG,F_COPYI,4,18
	DW	0000H

M26:		;話す　恵依美１９
	T_CG1 "CT08","F",0,15,1
;	DB	'【恵依美】：・・・・・・そうだ！あ、あのさ%001。'
	DB	"Meimi:  I have an idea! Um, %001.",PAUSE
;	DB	'ピエロ・・・目指してみない？'
	DB	" Why don't you try being a clown?"
	DB	NEXT
;	DB	'【%001】：・・・・・・へ？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【恵依美】：ピエロよ、ピエロ・・・サーカスの。'
	DB	"Meimi:  A clown...a circus clown."
	DB	NEXT
;	DB	'【%001】：・・・ああ、アレね。'
	DB	"%001:  Oh, right."
	DB	FLG,F_COPYI,4,19
	DW	0000H

M27:		;話す　恵依美２０
;	DB	'【恵依美】：あたしのパパがピエロやってるんだけど・・・すっごく難しいのよ、ピエロって。'
	DB	"Meimi:  That's what my Dad does, he says it's really"
	DB	CR
	DB	"difficult to be a good clown."
	DB	NEXT
;	DB	'【恵依美】：危険な事を、わざと失敗しなくちゃならなかったりするし'
	DB	"Meimi:  They have to do dangerous stuff on purpose. The"
	DB	CR
	DB	"most difficult thing to do is to make the people laugh."
	DB	NEXT
;	DB	'【%001】：人を笑わせるのが・・・難しい？'
	DB	"%001:  Making people laugh....is difficult?"
	DB	NEXT
;	DB	'【恵依美】：そう。今の人達って、みんな目が肥えちゃってるでしょう？'
	DB	"Meimi:  Yes. People nowadays, they've all gotten really"
	DB	CR
	DB	"passive, right? From television and things like that."
	DB	NEXT
;	DB	'だから、ちょっとズッコケたくらいじゃダメなんだって。'
	DB	"Meimi:  So,  he says that if you don't pull some really "
	DB	CR
	DB	"outrageous stunts, it won't work."
	DB	NEXT
;	DB	'【%001】：それは、そうだろうな。'
	DB	"%001:  That's probably true."
	DB	NEXT
;	DB	'【恵依美】：だから、失敗するにしても派手にやらないとダメなんだって。'
	DB	"Meimi:  So, even if you make a mistake, your show still"
	DB	CR
	DB	"really has to be flashy."
	DB	NEXT
;	DB	'しかも、自分は怪我しちゃいけないんだもの。難しいわよ。'
	DB	"Meimi:  On top of all this, you have to try not to injure ",CR,"yourself. It's hard."
	DB	NEXT
;	DB	'【%001】：・・・そうだな。確かに、難しそうだ。'
	DB	"%001:  Wow, sure sounds that way."
	DB	FLG,F_COPYI,4,20
	DW	0000H

M28:		;話す　恵依美２１
;	DB	'【恵依美】：難しいのは、身のこなしだけじゃないわ。'
	DB	"Meimi:  What's hard is not only the way you carry yourself."
	DB	NEXT
;	DB	'【恵依美】：それなりに「筋立て」も必要だし、何よりわざと失敗してる'
	DB	"Meimi:  You also have to make up a story, and then you have"
	DB	CR
	DB	"to make mistakes on purpose, but you can't let the audience"
	DB	CR
	DB	"know that, because it would ruin the show."
	DB	NEXT
;	DB	'【%001】：・・・確かに。'
	DB	"%001:  Right."
	DB	NEXT
;	DB	'【恵依美】：だから、ピエロって役柄は誰にでも出来る訳じゃないわ。'
	DB	"Meimi:  So not just anybody can be a clown, you know."
	DB	NEXT
;	DB	'【恵依美】：サーカスの中でも、もっとも敬意を払われている役の一つよ。'
	DB	"Meimi:  Even in the circus, the clown is one of the most"
	DB	CR
	DB	"respected performers there."
	DB	NEXT
;	DB	'【%001】：・・・そっかぁ。ピエロね・・・'
	DB	"%001:  I didn't know that."
	DB	FLG,F_COPYI,4,21
	DW	0000H


M29:		;話す　恵依美２２
;	DB	'【%001】：・・・しっかし中野・・・お前本当に好きなんだな、サーカス。'
	DB	"%001:  So Meimi, you really like the circus, don't you?"
	DB	NEXT
;	DB	'【恵依美】：え？'
	DB	"Meimi:  Huh?"
	DB	NEXT
;	DB	'【%001】：心底、楽しそうだぜ・・・サーカスの話する時のお前。'
	DB	"%001:  When you talk about the circus, your eyes light up. "
	DB	NEXT
;	DB	'【恵依美】：・・・そう？'
	DB	"Meimi:  Really?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yeah."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ............."
	DB	NEXT
	K_CG "CT08",'I',15,3
;	DB	'【恵依美】：・・・そう・・・かも知れない。'
	DB	"Meimi:  ....I...suppose so."
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  ???"
	DB	FLG,F_COPYI,4,22
	DW	0000H

M30:		;話す　恵依美２３
;	DB	'【%001】：ど～した中野？どっか痛いのか？'
	DB	"%001:  Are you all right? What's wrong?"
	DB	NEXT
;	DB	'【恵依美】：・・・あ・・・'
	DB	"Meimi:  ...Uh..."
	DB	PAUSE
;	DB	'ううん、何でもない。'
	DB	"No, I'm fine."
	DB	NEXT
;	DB	'【%001】：・・・そか？なんか、また泣きそうな顔してたからよ。'
	DB	"%001:  Really? You look as though you're going to cry."
	DB	NEXT
	K_CG "CT08",'K',15,4
;	DB	'【恵依美】：・・・・・・何でもない。'
	DB	"Meimi:  It's nothing.",PAUSE
;恵依美笑い立ちポーズ
;	DB	'ホントに、何でもないの。'
	DB	" Really, I'm fine."
	DB	NEXT
;	DB	'【%001】：・・・ならい～んだけど・・・'
	DB	"%001:  Are you sure...?"
	DB	NEXT
;	DB	'【恵依美】：・・・そんな事よりさ、もう少し歩かない？'
	DB	"Meimi:  Don't worry. Actually, want to walk some more?",PAUSE,CR
;	DB	'話もしたいし・・・さ。'
	DB	"And talk some more...?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、いいよ別に。'
	DB	"%001:  ....Sure, I don't mind."
	DB	NEXT
;	DB	'【恵依美】：・・・ありがと、%001。'
	DB	"Meimi:  Thanks, %001."
	DB	NEXT
	DB	"Suddenly, Meimi took my arm."
	DB	NEXT
;	DB	'【%001】：・・・お、おい中野？'
	DB	"%001:  Meimi?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・いいじゃない、少しくらい・・・・・・'
	DB	"Meimi:  What's wrong with it, just for a while....."
	DB	PAUSE
;	DB	'ね？'
	DB	" Okay?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......."
	DB	NEXT
;	DB	'【%001】：ま、いっか。'
	DB	"%001:  Okay, whatever."
	DB	NEXT
;	DB	'そして俺達は、夜の浜辺をぶらぶらと散歩した。'
	DB	"We walked together around the dark beach."
	DB	NEXT
;	DB	'この時の月明かりは・・・何故か妙に明るく、暖かかったような気がする。'
	DB	"The light of the moon seemed strangely bright and warm."
	DB	NEXT
;	DB	'それはもしかすると、側にいる中野のせいだったかもしれない。'
	DB	"Of course, that could have been because Meimi was there,"
	DB	CR
	DB	"walking at my side."
	DB	NEXT
	B_O B_SUDA			;ブラックアウト
;	DB	'・・・・・・・・・'
	DB	"................."
	DB	NEXT
;	DB	'そんなこんなで、俺の高校生活最初の夏は終わった。'
	DB	"And so, summer ended..."
	DB	NEXT
;	DB	'様々な想い出を残して・・・・・・'
	DB	"There were all kinds of memories..."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"................."
	DB	NEXT
	DB	BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'ざばざば'
	DB	"*SQUELCH*"
	DB	NEXT
;	DB	'【？】：・・・'
	DB	"???:  ................."
	DB	NEXT
;	DB	'ざばざば'
	DB	"*SQUELCH*"
	DB	NEXT
;	DB	'【？】：・・・・・・'
	DB	"???:  ................."
	DB	NEXT
;	DB	'ばしゃばしゃ・・・'
	DB	"*SPLASH*"
	DB	NEXT
	T_CG "CT13","F",0,15,3 	;校長
;	DB	'【校長】：・・・・・・・・・'
	DB	"Dean:  ................."
	DB	NEXT
;	DB	'【校長】：・・・やっと・・・帰って来られた・・・'
	DB	"Dean:  ...Finally...got back..."
	DB	NEXT
;	DB	'【校長】：私ももう年だろーか、前後不覚になるほど酔ってしまうとは。'
	DB	"Dean:  I passed out, got drunker than I've been in "
	DB	CR
	DB	"years..."
	DB	NEXT
;	DB	'【校長】：しかも、酔いが覚めてみたら知らない島にいるし・・・'
	DB	"Dean:  And then when I woke up and looked around, I"
	DB	CR
	DB	"was on this island that I've never seen..."
	DB	NEXT
;	DB	'【校長】：小林先生とお酒を飲むのはもう止めよう・・・'
	DB	"Dean:  I don't think I'll be drinking with Kyoko-"
	DB	CR
	DB	"sensei anymore..."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS701.OVL',0
	DW	0000H

M31:		;話す　瑠璃のこと１
;	DB	'【%001】：・・・え～っと、白水さんは転校生だ。'
	DB	"%001:  Well, she's the transfer student."
	DB	NEXT
;	DB	'【%001】：誠の話によると、家の都合であちこち転校させられてるってえ'
	DB	"%001:  Makoto says that she's been transferred all over"
	DB	CR
	DB	"the place because of her family."
;	DB	'話だ。'
	DB	" That's what they say."
	DB	NEXT
;	DB	'【恵依美】：・・・知ってる。'
	DB	"Meimi:  ...I've heard that, too."
	DB	NEXT
;	DB	'【%001】：・・・・・・あ、そう。'
	DB	"%001:  Oh."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M32:		;話す　瑠璃のこと２
;	DB	'【%001】：・・・え～っと、趣味とか好きなものとかは、はっきり言って'
	DB	"%001:  To tell the truth, we don't know what her hobbies and ",CR,"interests are because she won't talk to us."
	DB	NEXT
;	DB	'【恵依美】：・・・うん。そうだね。'
	DB	"Meimi:  Yeah. She doesn't talk at all."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M33:		;話す　瑠璃のこと３
;	DB	'【%001】：・・・え～っと、それから・・・'
	DB	"%001:  Let's see, what else?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ................"
	DB	NEXT
;	DB	'【%001】：あれ？'
	DB	"%001:  Eh?"
	DB	FLG,F_COPYI,5,3
	DW	0000H

M34:		;話す　瑠璃のこと４
;	DB	'【%001】：・・・うーん、それから・・・それから・・・'
	DB	"%001:  Hmm, what else can I say about her?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ..............."
	DB	NEXT
;	DB	'【%001】：・・・うーん・・・うーん・・・'
	DB	"%001:  Hmmm..."
	DB	NEXT
;	DB	'【恵依美】：・・・あ、ありがと%001。もういいよ。'
	DB	"Meimi:  Uh, thanks, %001. That's okay."
	DB	NEXT
;	DB	'【%001】：・・・そか？悪ィな、全然役に立たなくて・・・'
	DB	"%001:  Sorry I can't help you more."
;	DB	NEXT
;	DB	'【恵依美】：・・・ううん、いいの。'
;	DB	"Meimi:  No, it's fine."
;	DB	PAUSE
;	DB	'そんな事で悩んでたんじゃないし。'
;	DB	"That's not what I would be hurting from ."
;	DB	NEXT
;	DB	'【%001】：へ？'
;	DB	"%001:  Huh?"
;	DB	NEXT
;	DB	'【恵依美】：う、ううん。何でもない。'
;	DB	"Meimi:  Oh, nothing."
;	DB	NEXT
;	DB	'【%001】：？'
;	DB	"%001:  ???"
	DB C_BLD,C_N_OFF,2,1
	DB C_BLD,C_N_ON,2,2
	DW	0000H

M35:		;考える　恵依美１
;	DB	'・・・夢、か・・・'
	DB	"She asked me about my dream."

	DB	NEXT
;	DB	'・・・そう言えば、考えたことないなぁ・・・'
	DB	"Can't say that I've thought about it much..."
	DB	NEXT
;	DB	'小学校に通ってた位の頃は、なにかしらあったんだろうけど。'
	DB	"I'm sure there must have been something in elementary"
	DB	CR
	DB	"school."
	DB	NEXT
;	DB	'今は・・・ないや。'
	DB	"But there isn't now."
	DB	NEXT
;	DB	'・・・俺は・・・無意味に全力を出したらダメなんだ。'
	DB	"I gave my best but it wasn't any use."
	DB	NEXT
;	DB	'・・・いかんいかん、俺が沈んでどうするっ。中野がようやく少しだけ元気になったのに。'
	DB	"Dammit, I'm flailing here. And just when Meimi was"
	DB	CR
	DB	"getting more cheerful."
	DW	0000H

M36:		;もう寝る１
;	DB	'【%001】：・・・そろそろ遅いから、俺もう寝るわ。中野も、早めに'
	DB	"%001:  Well it's pretty late, so I'm going to bed."
	DB	NEXT
	DB	"%001:  You know, it's time you went back yourself. ",CR,"Goodnight."
	DB	NEXT
;	DB	'【恵依美】：ち、ちょっと待って！'
	DB	"Meimi:  W- Wait!"
	DB	NEXT
;	DB	'【%001】：ん？まだ何か話あるのか？'
	DB	"%001:  Do you have something you want to tell me?"
	DB	NEXT
;	DB	'【恵依美】：・・・う、うん。'
	DB	"Meimi:  Um, yes."
	DW	0000H


end
