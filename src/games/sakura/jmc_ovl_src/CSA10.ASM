;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ１０
;		瑠璃の看病：最終試練

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5, CM6, CM7
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,-1
CM2:	DW	VV2,	NN1,NN2,-1
CM3:	DW	VV3,	NN5,NN6,NN7,NN8,NN9,NN1,NN10,NN2,-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1
CM6:	DW	VV6,	-1
CM7:	DW	VV7,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'迷う',0
VV5:	DB	5,	'CONSIDER IT',0
;VV6:	DB	6,	'追いかける',0
VV6:	DB	6,	'CHASE HER',0
;VV7:	DB	7,	'追いかけない',0
VV7:	DB	7,	"DON'T CHASE HER",0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	'RURI',0
;NN2:	DB	2,	'今日子',0
NN2:	DB	2,	'KYOKO',0
;NN3:	DB	3,	'部屋',0
NN3:	DB	3,	'ROOM',0
;NN4:	DB	4,	'鏡',0
NN4:	DB	4,	'MIRROR',0
;NN5:	DB	5,	'みんなの事',0
NN5:	DB	5,	'EVERYONE',0
;NN6:	DB	6,	'誠',0
NN6:	DB	6,	'MAKOTO',0
;NN7:	DB	7,	'鈴子',0
NN7:	DB	7,	'REIKO',0
;NN8:	DB	8,	'清美',0
NN8:	DB	8,	'KIYOMI',0
;NN9:	DB	9,	'美緒',0
NN9:	DB	9,	'MIO',0
;NN10:	DB	10,	'亜希',0
NN10:	DB	10,	'AKI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　瑠璃
S2:		DW	VV1, NN2,  2, M5		;見る　今日子
S3:		DW	VV1, NN3,  3, M6		;見る　部屋
S4:		DW	VV1, NN4,  4, M7, M8		;見る　鏡
S5:		DW	VV2, NN1,  5, M9, M10, M11, M12		;話す　瑠璃
S6:		DW	VV2, NN2,  6, M13, M14, M15		;話す　今日子
S7:		DW	VV3, NN5,  7, M16		;聞く　みんなの事
S8:		DW	VV3, NN6,  8, M17, M18, M19		;聞く　誠３
S9:		DW	VV3, NN7,  9, M20, M21, M22		;聞く　鈴子３
S10:		DW	VV3, NN8,  10, M23, M24, M25		;聞く　清美３
S11:		DW	VV3, NN9,  11, M26, M27, M28		;聞く　美緒３
S12:		DW	VV3, NN1,  12, M29, M30, M31, M32, M33		;聞く　瑠璃５
S13:		DW	VV3, NN10,  13, M34, M35, M36		;聞く　亜希３
S14:		DW	VV3, NN2,  14, M37, M38		;聞く　今日子２
S15:		DW	VV4, -1,  15, M39, M40, M41, M42, M43, M44		;考える
S16:		DW	VV5, -1,  16, M45		;迷う
S17:		DW	VV6, -1,  17, M46, M47		;追いかける２
S18:		DW	VV7, -1,  18, M48, M49		;追いかけない２


;イニシャルメッセージ
M1:
	DB	BGM,31
	BAK_INIT 'AB_39'
	DB	BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'（・・・・・・・・・）'
	DB	".............."
	DB	NEXT
;	DB	'（・・・・・・痛てぇ・・・）'
	DB	".......................Ouch!"
	DB	NEXT
;	DB	'右目の上の辺りが、自分の鼓動に合わせてズッキン、ズッキン、と痛む。'
	DB	"The area above my my right eye is puffed up like a rock,"
	DB	CR
	DB	"and pulsating with pain."
	DB	NEXT
;	DB	'（あつつつ・・・）'
	DB	".........Owww!"
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,5
	DB C_BLD,C_V_ON,6
	DB C_BLD,C_V_ON,7
	DW	0000H

M2:		;見る　瑠璃
;	DB	'心配そうな顔で俺を見てる。'
	DB	"She's looking at me with worry written on her face."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　瑠璃
;	DB	'今はシラフみたいだ・・・多分。'
	DB	"She seems sober now."
	DB	NEXT
;	DB	'・・・白水さんって、表に出にくいんだよな・・・。'
	DB	"It's kind of hard to tell with her, since her facial"
	DB	CR
	DB	"expressions are all the same."
	DB	NEXT
;	DB	'もし今酔っ払ってるとしたら、明日の朝には話したことも忘れてるんだ・・・。'
	DB	"If she's drunk now, she won't remember anything tomorrow."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　瑠璃
;	DB	'（浴衣は着ないのか・・・）'
	DB	"She's not wearing her yutaka cotton kimono..."
	DW	0000H

M5:		;見る　今日子
;	DB	'今日子先生はいつになく真剣な顔をしてた。'
	DB	"Kyoko-sensei is unusually serious."
	DB	NEXT
;	DB	'そう、いつか白水さんが行方不明になった時と、同じ顔を。'
	DB	"It's the same expression she had when Ruri disappeared"
	DB	CR
	DB	"at summer camp."
	DW	0000H

M6:		;見る　部屋
;	DB	'旅館の一室だ。'
	DB	"It's a room in the hotel."
	DB	NEXT
;	DB	'俺と白水さんの二人しかいない。'
	DB	"Ruri and I are alone here."
	DW	0000H

M7:		;見る　鏡
;	DB	'（何となく予想は出来てるが・・・）'
	DB	"I can imagine what I must look like."
	DB	NEXT
;	DB	'【%001】：・・・ッわぁ！？'
	DB	"%001:  ................Wah!"
	DB	NEXT
;	DB	'俺は思わず飛びのいた。'
	DB	"I didn't think I looked that bad."
	DB	NEXT
;	DB	'右の眉毛の上に、紫色のでかいたんこぶが出来ていた。'
	DB	"There's a huge purple lump above my right eye."
	DB	NEXT
;	DB	'（そうだ、のぞいてるのがバレて、石をぶつけられたんだ。）'
	DB	"Now I remember. They caught me peeking at them, and threw"
	DB	CR
	DB	"rocks at me."
	DB	NEXT
;	DB	'（・・・世の中、悪いことは出来ねえよーになってんだな。',CR,'・・・なんて安心してどーする。）'
	DB	"What's this world come to, when you can't do someone evil"
	DB	CR
	DB	"without getting caught?"
	DB	FLG,F_COPYI,4,1
	DB	FLG,F_COPYI,5,2
	DW	0000H

M8:		;見る　鏡
;	DB	'・・・何度見ても、思わずどっきりする顔だ。月のない夜に道端で会ったら失禁するぞ。'
	DB	"I don't like looking at my face..."
	DB	NEXT
;	DB	'【%001】：ひでぇ顔・・・'
	DB	"%001:  That looks terrible."
	DB	NEXT
;	DB	'【瑠璃】：・・・さっきよりは、だいぶ腫れがひいたのよ。'
	DB	"Ruri:  ....The swelling's gone down quite a bit."
	DB	NEXT
;	DB	'【%001】：・・・さっきは、もっとひどかったって事？'
	DB	"%001:  .....You mean it was worse before?"
	DB	NEXT
;	DB	'【瑠璃】：・・・ええ。'
	DB	"Ruri:  ........Yes."
	DW	0000H

M9:		;話す　瑠璃
;	DB	'【%001】：えと・・・どうして？'
	DB	"%001:  What happened to me?"
	DB	NEXT
;	DB	'【瑠璃】：何が？'
	DB	"Ruri:  What?"
	DB	NEXT
;	DB	'【%001】：・・つまりその・・・'
	DB	"%001:  .....Well, what I mean is...."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M10:		;話す　瑠璃
;	DB	'【%001】：そうだな・・・俺の目の上、どうなってる？'
	DB	"%001:  What happened to my eye?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ................"
	DB	NEXT
;	DB	'白水さんは無言で、部屋の角にある鏡を指差した。'
	DB	"Ruri brought me a mirror."
	DB C_BLD,C_N_OFF,1,4
	DW	0000H

M11:		;話す　瑠璃
;	DB	'【%001】：白水さんが看病してくれたんだ・・・サンキュ。'
	DB	"%001:  You were taking care of me? Thank you."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............"
	DB C_BLD,C_V_OFF,3	;聞く
	DB C_BLD,C_N_ON,3,2
	DB C_BLD,C_N_ON,3,3
	DB C_BLD,C_N_ON,3,4
	DB C_BLD,C_N_ON,3,5
	DB C_BLD,C_N_ON,3,6
	DB C_BLD,C_N_ON,3,7
	DB C_BLD,C_N_ON,3,8
	DB	FLG,F_COPYI,5,3
	DW	0000H

M12:		;話す　瑠璃
;	DB	'【%001】：・・・この前のクリスマス以来だな・・・',CR,'こうやって２人で話すのって。'
	DB	"%001:  .....We haven't talked alone like this since after"
	DB	CR
	DB	"the Christmas Party."
	DB	NEXT
;	DB	'【瑠璃】：・・・そうね。'
	DB	"Ruri:  .........That's right."
	DW	0000H

M13:		;話す　今日子
;	DB	'【%001】：・・・何かあったんですか？'
	DB	"%001:  .....What happened?"
	DB	NEXT
;	DB	'【今日子】：瑠璃ちゃんがいなくなったの。これを残してね。'
	DB	"Kyoko:  Ruri disappeared. She left this."
	DB	NEXT
;	DB	'【%001】：何だって？！'
	DB	"%001:  What? "
	DB	NEXT
;	DB	'俺は今日子先生から紙切れをひったくった。'
	DB	"I took the letter from Kyoko-sensei and read it."
	DB	NEXT
;	DB	'「家に帰ります。',CR,'ごめんなさい。',CR,'　　　　　　　　　　　　　　　　　　白水　瑠璃」'
	DB	"'I'm going home. I'm sorry for everything."
	DB	CR
	DB	"                                       Ruri Shiromizu'"
	DB	NEXT
;	DB	'【%001】：そんな・・・もう夜だぞ！？'
	DB	"%001:  But it's nighttime already!"
	DB	NEXT
;	DB	'【%001】：大変だ、道に迷いでもしたら！'
	DB	"%001:  What if she gets lost going back into town?"
	DB	NEXT
;	DB	'【今日子】：それは大丈夫よ。駅に電話したら、ついさっき',CR,'瑠璃ちゃんらしい子が電車に乗るのを見掛けたって言ってたから。'
	DB	"Kyoko:  There's nothing to worry about there. I called "
	DB	CR
	DB	"the station and they said that a woman fitting Ruri's"
	DB	CR
	DB	"description just got on a train."
	DB	NEXT
;	DB	'【今日子】：多分、一旦家に帰った後、お母さんのところに',CR,'行くつもりね。'
	DB	"Kyoko:  I'm sure she'll go home first, then head for her"
	DB	CR
	DB	"mother's."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M14:		;話す　今日子
;	DB	'【%001】：・・・追いかけなきゃ！'
	DB	"%001:  I've got to catch up with her!"
	DB	NEXT
;	DB	'【今日子】：それで追い付いて、どうするの？'
	DB	"Kyoko:  And if you do, what then?"
	DB	NEXT
;	DB	'【%001】：・・・ちゃんと・・・お別れを・・・'
	DB	"%001:  ...........Say goodbye.........."
	DB	NEXT
;	DB	'【今日子】：どうしてあの子が突然いなくなったのか分かる？'
	DB	"Kyoko:  Do you know why she ran away like that?"
	DB	NEXT
;	DB	'【%001】：・・・俺がのぞきなんかしたから？'
	DB	"%001:  Because I peeked at the women in the bath?"
	DB	NEXT
;	DB	'【今日子】：君が好きだからよ。'
	DB	"Kyoko:  Because she loves you."
	DB	NEXT
;	DB	'【%001】：・・・！'
	DB	"%001:  ...........!!"
	DB	FLG,F_COPYI,6,2
	DW	0000H

M15:		;話す　今日子
;	DB	'【今日子】：%001君、君が瑠璃ちゃんの気持ちに応える気があるなら今すぐ追いかけなさい。'
	DB	"Kyoko:  If you're prepared to return her feelings, then"
	DB	CR
	DB	"you should go after her."
	DB	NEXT
;	DB	'【今日子】：中途半端な気持ちで追いかけても、彼女を傷つけるだけよ。'
	DB	"Kyoko:  But if you're going to continue to do things"
	DB	CR
	DB	"halfway like you've done, then don't bother. You'll"
	DB	CR
	DB	"only hurt her."
	DB	NEXT
;	DB	'【今日子】：さあ・・・どうするの？'
	DB	"Kyoko:  What are you going to do?"
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_OFF,5
	DB C_BLD,C_V_OFF,6
	DB C_BLD,C_V_OFF,7
	DW	0000H

M16:		;聞く　みんなの事
;	DB	'【%001】：・・・他のみんな・・・怒ってた？'
	DB	"%001:  Is everyone angry at me?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .................."
	DB	NEXT
;	DB	'【%001】：そうだよな・・・怒るよなぁ・・・'
	DB	"%001:  What am I saying? Of course they are."
	DB	NEXT
;	DB	'【瑠璃】：・・・それがわかってるのに、何でのぞいたの？'
	DB	"Ruri:  ....If you knew it was wrong, why did you do it?"
	DB	NEXT
;	DB	'【%001】：・・・なんつーか・・・その・・・'
	DB	"%001:  ..................."
	DB	NEXT
;	DB	'【瑠璃】：島崎君にそそのかされたの？'
;	DB	"Ruri:  Did Shimazaki make you do it?"
;	DB	NEXT
;	DB	'【%001】：・・・まぁ、それもあるけど・・・',CR,'ただ、「見たかった」からだよ。'
	DB	"%001:  .........I just wanted to look."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・ったの・・・？'
	DB	"Ruri:  ...............You did?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ................"
	DB	NEXT
;	DB	'【瑠璃】：みんな、もう怒ってないわ。'
	DB	"Ruri:  They're not angry anymore."
	DB C_BLD,C_N_ON,3,1
	DB C_BLD,C_N_OFF,3,2
	DB C_BLD,C_N_OFF,3,3
	DB C_BLD,C_N_OFF,3,4
	DB C_BLD,C_N_OFF,3,5
	DB C_BLD,C_N_OFF,3,6
	DB C_BLD,C_N_OFF,3,7
	DB C_BLD,C_N_OFF,3,8
	DW	0000H

M17:		;聞く　誠１
;	DB	'【瑠璃】：誠君ならロビーでテレビを見ているわ。'
	DB	"Ruri:  Makoto's watching television in the lobby."
	DB	NEXT
;	DB	'（見つかったのは俺だけかよ・・・。）'
	DB	"(So he got away...)"
	DB	FLG,F_COPYI,8,1
	DW	0000H

M18:		;聞く　誠２
;	DB	'【瑠璃】：・・・さっき、誰かと電話で話していたわ。'
	DB	"Ruri:  He was calling someone on the phone a while ago."
	DB	NEXT
;	DB	'【%001】：電話？'
	DB	"%001:  Calling someone?"
	DB	NEXT
;	DB	'【瑠璃】：「作戦」がどうとか言っていたみたいだけど・・・'
	DB	"Ruri:  He was asking what the next battle plans were,"
	DB	CR
	DB	"or something like that."
	DB	NEXT
;	DB	'（一体何をたくらんでるんだ？）'
	DB	"He's a strange one, that Makoto."
	DB	FLG,F_COPYI,8,2
	DW	0000H

M19:		;聞く　誠３
;	DB	'【瑠璃】：仲が良いのね、あなた達。'
	DB	"Ruri:  You two are very close."
	DW	0000H

M20:		;聞く　鈴子１
;	DB	'【瑠璃】：・・・新藤さんと鈴木さんと、誰があなたを看病するかで勝負してるわ。'
	DB	"Ruri:  Kiyomi and Reiko and Mio were trying to decide"
	DB	CR
	DB	"who should take care of you."
	DB	NEXT
;	DB	'【%001】：勝負って？'
	DB	"%001:  How?"
	DB	NEXT
;	DB	'【瑠璃】：トランプよ。'
	DB	"Ruri:  By playing cards."
	DB	NEXT
;	DB	'【瑠璃】：・・・その勝負がつくまで、私が代わり。'
	DB	"Ruri:  .......I thought I'd take care of you until they"
	DB	CR
	DB	"make up their minds."
	DB	FLG,F_COPYI,9,1
	DB	FLG,F_COPYI,10,1
	DB	FLG,F_COPYI,11,1
	DW	0000H

M21:		;聞く　鈴子２
;	DB	'【瑠璃】：・・・もうすぐここに来ると思うわ。'
	DB	"Ruri:  I'm sure she'll be here soon."
	DB	FLG,F_COPYI,9,2
	DW	0000H

M22:		;聞く　鈴子３
;	DB	'【瑠璃】：・・・もうすぐここに来ると思うわ。'
	DB	"Ruri:  ......Are you worried about her?"
	DW	0000H

M23:		;聞く　清美１
;	DB	'【瑠璃】：・・・新藤さんと鈴木さんと、誰があなたを看病するかで勝負してるわ。'
	DB	"Ruri:  Kiyomi and Reiko and Mio were trying to decide"
	DB	CR
	DB	"who should take care of you."
	DB	NEXT
;	DB	'【%001】：勝負って？'
	DB	"%001:  How?"
	DB	NEXT
;	DB	'【瑠璃】：トランプよ。'
	DB	"Ruri:  By playing cards."
	DB	NEXT
;	DB	'【瑠璃】：・・・その勝負がつくまで、私が代わり。'
	DB	"Ruri:  .......I thought I'd take care of you until"
	DB	CR
	DB	"they make up their minds."
	DB	FLG,F_COPYI,9,1
	DB	FLG,F_COPYI,10,1
	DB	FLG,F_COPYI,11,1
	DW	0000H

M24:		;聞く　清美２
;	DB	'【瑠璃】：・・・もうすぐここに来ると思うわ。'
	DB	"Ruri:  I'm sure she'll be here soon."
	DB	FLG,F_COPYI,10,2
	DW	0000H

M25:		;聞く　清美３
;	DB	'【瑠璃】：・・・もうすぐここに来ると思うわ。'
	DB	"Ruri:  ......Are you worried about her?"
	DW	0000H

M26:		;聞く　美緒１
;	DB	'【瑠璃】：・・・新藤さんと鈴木さんと、誰があなたを看病するかで勝負してるわ。'
	DB	"Ruri:  Kiyomi and Reiko and Mio were trying to decide"
	DB	CR
	DB	"who should take care of you."
	DB	NEXT
;	DB	'【%001】：勝負って？'
	DB	"%001:  How?"
	DB	NEXT
;	DB	'【瑠璃】：トランプよ。'
	DB	"Ruri:  By playing cards."
	DB	NEXT
;	DB	'【瑠璃】：・・・その勝負がつくまで、私が代わり。'
	DB	"Ruri:  .......I thought I'd take care of you until they"
	DB	CR
	DB	"make up their minds."
	DB	FLG,F_COPYI,9,1
	DB	FLG,F_COPYI,10,1
	DB	FLG,F_COPYI,11,1
	DW	0000H

M27:		;聞く　美緒２
;	DB	'【瑠璃】：・・・もうすぐここに来ると思うわ。'
	DB	"Ruri:  I'm sure she'll be here soon."
	DB	FLG,F_COPYI,11,2
	DW	0000H

M28:		;聞く　美緒３
;	DB	'【瑠璃】：・・・もうすぐここに来ると思うわ。'
	DB	"Ruri:  ......Are you worried about her?"
	DW	0000H

M29:		;聞く　瑠璃１
;	DB	'【%001】：・・・怒ってるよな。悪ィ、やっぱのぞきなんて',CR,'男らしくなかった。'
	DB	"%001:  I'm sure sure you're angry, too. I'm sorry. That"
	DB	CR
	DB	"wasn't such a good idea after all."
	DB	NEXT
;	DB	'【瑠璃】：・・・もういいわ。十分痛い目に会ったでしょう。'
	DB	"Ruri:  .........It doesn't matter anymore. You've paid"
	DB	CR
	DB	"enough."
	DB	NEXT
;	DB	'【%001】：ああ・・・ありゃきっと亜希ちゃんだな。',CR,'絶妙のコントロールだぜ。'
	DB	"%001:  I have. Who threw the rock that hit me? It had to be"
	DB	CR
	DB	"Aki. She's got the control for such a long throw."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ..............."
	DB	FLG,F_COPYI,12,1
	DW	0000H

M30:		;聞く　瑠璃２
;	DB	'【%001】：・・・でも、よかったよ。白水さんが来てくれて。'
	DB	"%001:  .......I'm really glad you came along with us,"
	DB	CR
	DB	"though."
	DB	NEXT
;	DB	'【瑠璃】：・・・え・・・？'
	DB	"Ruri:  .............You are?"
	DB	NEXT
;	DB	'【%001】：電話で断わられたから、諦めてたんだけど・・・'
	DB	"%001:  When you said you couldn't go on the telephone, I"
	DB	CR
	DB	"guess I gave up. What did Kyoko-sensei say to get you to"
	DB	CR
	DB	"come?"
	DB	NEXT
;	DB	'【瑠璃】：・・・転校する前に・・・思い出を作りなさいって・・・'
	DB	"Ruri:  ...That before I change schools again, I should make"
	DB	CR
	DB	"some memories with all of you."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  ......I see."
	DB	FLG,F_COPYI,12,2
	DW	0000H

M31:		;聞く　瑠璃３
;	DB	'【%001】：・・・どうしても・・・お母さんのところに戻らないと、いけねーのか？'
	DB	"%001:  .......Do you really have to return to your mother?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  .............."
	DB	NEXT
;	DB	'【瑠璃】：お母様の所以外に、私の帰れる場所はないもの。'
	DB	"Ruri:  There's nowone else for me to go home to except"
	DB	CR
	DB	"her."
	DB	FLG,F_COPYI,12,3
	DW	0000H

M32:		;聞く　瑠璃４
;	DB	'【%001】：・・・俺達じゃ、ダメなのか？'
	DB	"%001:  .....I guess we're not good enough..."
	DB	NEXT
;	DB	'【瑠璃】：・・・？'
	DB	"Ruri:  ...............?"
	DB	NEXT
;	DB	'【%001】：俺達１－Ａの・・・いや、今日ここにいる俺達は・・・白水さんの「帰る場所」にはなれねーのか？'
	DB	"%001:  I mean, class 1-A...everyone here tonight...can't"
	DB	CR
	DB	"we become your 'place to go home to'?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ........................"
	DB	NEXT
;	DB	'【%001】：・・・悪ィ、変なこと聞いて。'
	DB	"%001:  .....I'm sorry, I shouldn't have said that."
	DB	FLG,F_COPYI,12,4
	DW	0000H

M33:		;聞く　瑠璃５
	K_CG 'CT05','I',10,4
;	DB	'【瑠璃】：・・・ごめんなさい・・・'
	DB	"Ruri:  .........I'm sorry."
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【瑠璃】：・・・私なの・・・'
	DB	"Ruri:  .......I threw it..."
	DB	NEXT
;	DB	'【%001】：・・・何が？'
	DB	"%001:  .....Threw what?"
	DB	NEXT
;	DB	'【瑠璃】：・・・石・・・'
	DB	"Ruri:  ......The rock."
	DB	NEXT
;	DB	'【%001】：・・・石？'
	DB	"%001:  .....The rock?"
	DB	NEXT
;	DB	'【瑠璃】：%001君に当たった石・・・'
	DB	"Ruri:  ............The rock that hit you."
	DB	NEXT
;	DB	'【%001】：あ・・・、そーなんだ。'
	DB	"%001:  Oh. I see."
	DB	NEXT
;	DB	'【瑠璃】：ごめんなさい・・・！'
	DB	"Ruri:  I'm sorry...!"
	DB	NEXT
;	DB	'【%001】：いやアレは当然の報いだし、白水さんが謝ること',CR,'ねーって！'
	DB	"%001:  No, I don't care about that. I deserved it, really."
	DB	CR
	DB	"You don't have anything to apologize to me for."
	DB	NEXT
;	DB	'トントン'
	DB	"*KNOCK KNOCK*"
	DB	NEXT
;	DB	'【鈴子】：%001君・・・目、覚めた？'
	DB	"Reiko:  %001, are you awake?"
	DB	NEXT
;	DB	'【%001】：鈴子さん？'
	DB	"%001:  Reiko?"
	DB	NEXT
;	DB	'がらっ'
	DB	"*KACHA*"
	DB	NEXT
	DB BUF,B_COPY01
	TU_CG 'CT03','Y',0,10,3
	TU_CG 'CT02','Y',0,0,2
	T_CG 'CT01','Y',0,34,1
	DB ANI,A_ON,2
	DB ANI,A_ON,3
	DB BUF,B_COPY10
;	DB	'ふすまが開いて、鈴子さんと新藤さん、美緒ちゃんが現われた。'
	DB	"Reiko, Kiyomi and Mio enter the room."
	DB	NEXT
;	DB	'【美緒】：・・・白水先輩？'
	DB	"Mio:  Ruri?"
	DB	NEXT
;	DB	'【清美】：瑠璃さん・・・%001さんに付き添ってらしたのですか？'
	DB	"Kiyomi:  Ruri, I didn't know you were in here."
	DB	NEXT
	E_CG B_NORM,"AB_39"
	T_CG1 'CT05','C',0,10,5
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  .............."
	DB	NEXT
;	DB	'【瑠璃】：もう、大丈夫みたいだから。'
	DB	"Ruri:  Well, I guess he'll be in good hands now."
	DB	NEXT
;	DB	'そう言って、白水さんは部屋を出て行こうとした。'
	DB	"With that, Ruri went to leave the room."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【鈴子】：あ、白水さん！一緒にトランプしない？'
	DB	"Reiko:  Wait, Ruri? Would you like to play cards with"
	DB	CR
	DB	"us?"
	DB	NEXT
;;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ........................."
	DB	NEXT
;	DB	'白水さんは部屋を出て行った。'
	DB	"Ruri left the room."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	".............................."
	DB	NEXT
	BAK_INIT 'AB_39'
	DB BUF,B_COPY01
	T_CG 'CT12','Y','K',30,8
;	DB	'【今日子】：こっちはどぉ？'
	DB	"Kyoko:  How are you doing?"
	DB	NEXT
;	DB	'【%001】：おかげさまで・・・'
	DB	"%001:  I'll live."
	DB	NEXT
;	DB	'【今日子】：あ～ら、すっかり男前になっちゃって。'
	DB	"Kyoko:  Well, you got what you deserved, doing what you did."
	DB	NEXT
;	DB	'【%001】：ハハハハ・・・'
	DB	"%001:  Yes, hahaha..."
	DB	NEXT
	T_CG1 'CT06','Y',0,5,6
;	DB	'【亜希】：あ゛～、ひどい目にあったわ・・・'
	DB	"Aki:  Oh, your face is so swolen!"
	DB	NEXT
;	DB	'【亜希】：あれ？あの人は？'
	DB	"Aki:  Hey, where'd they go?"
	DB	NEXT
;	DB	'【鈴子】：誠君ならロビーでテレビ見てたわよ。'
	DB	"Reiko:  If you're looking for Makoto, he's watching TV in"
	DB	CR
	DB	"the lobby."
	DB	NEXT
;	DB	'【亜希】：違うわよ！白水先輩の方！'
	DB	"Aki:  No, I'm talking about the woman, Ruri Shiromizu."
	DB	NEXT
;	DB	'【美緒】：え、そっちの部屋じゃないの？'
	DB	"Mio:  Isn't she in her room?"
	DB	NEXT
;	DB	'【今日子】：一度だけ荷物取りに来たけど・・・こっちにいないの？'
	DB	"Kyoko:  She came to get her bag, then left. She's not"
	DB	CR
	DB	"here?"
	DB	NEXT
;	DB	'【清美】：きっと、お風呂ですわ。先程はゆっくり入れませんでしたから・・・'
	DB	"Kiyomi:  She must be in the bath again. We were "
	DB	CR
	DB	"interrupted before..."
	DB	NEXT
;	DB	'【%001】：・・・ご、ごめん・・・つい魔が差して・・・'
	DB	"%001:  .....I'm sorry! I don't know what got into me..."
	DB	NEXT
;	DB	'【亜希】：ま、こんな美女がお風呂に入ってたらのぞきたくなるのも分かるけど・・・'
	DB	"Aki:  Well, I can understand you wanting to see a beautiful"
	DB	CR
	DB	"woman like me naked, but..."
	DB	NEXT
;	DB	'【亜希】：犯した罪はつぐなってもらわなきゃね。'
	DB	"Aki:  You've still got to pay for what you did."
	DB	NEXT
;	DB	'【%001】：う・・・'
	DB	"%001:  ..........I do?"
	DB	NEXT
;	DB	'【今日子】：焼酎一気飲みってのはどう？'
	DB	"Kyoko:  How about straight shots of tequilla?"
	DB	NEXT
;	DB	'【亜希】：甘い！女の子のハダカ見たんだから、それ相当のことはしてもらわなくちゃ！'
	DB	"Aki:  No! Since he saw us all naked, we've got to think"
	DB	CR
	DB	"up a punishment that fits the crime."
	DB	NEXT
;	DB	'【%001】：お・・・俺にどうしろと？'
	DB	"%001:  W- What do you want me to do?"
	DB	NEXT
;	DB	'【亜希】：ズバリ！ハダカにひんむいてさらし者の刑よ！'
	DB	"Aki:  You're going to streak for us!"
	DB	NEXT
;	DB	'【今日子】：ナイスなアイデアね、亜希ちゃん！'
	DB	"Kyoko:  Oh, that's a nice idea, Aki!"
	DB	NEXT
;	DB	'【%001】：・・・・・・マジ？'
	DB	"%001:  .............Are you serious?"
	DB	NEXT
;	DB	'【今日子】：逃がさないわよ%001君！みんな、かかれ～！'
	DB	"Kyoko:  You won't get away this time, %001! Everyone, get"
	DB	CR
	DB	"him!"
	DB	NEXT
;	DB	'【%001】：・・・うわあああっ！・・・'
	DB	"%001:  ..............No!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・'
	DB	"................................"
	DB	NEXT
	B_O B_SUDA
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG 'CT12','Y','D',30,1
;	DB	'【%001】：・・・うう・・・ひどい目にあった・・・'
	DB	"%001:  ........I can't believe they did that to me."
	DB	NEXT
;	DB	'【今日子】：%001君。'
	DB	"Kyoko:  %001?"
	DB	NEXT
;	DB	'【%001】：わっ！もう勘弁して下さい！'
	DB	"%001:  No, please! No more, I beg you!"
	DB	NEXT
;	DB	'【今日子】：落ち着いて聞いて、%001君。'
	DB	"Kyoko:  Listen to what I have to say, %001. It's important."
	DB	NEXT
;	DB	'【%001】：・・・先生？'
	DB	"%001:  .....Sensei?"
	DB C_BLD,C_N_OFF,1,2	;見る　今日子
	DB C_BLD,C_N_OFF,2,2	;話す　今日子
	DB C_BLD,C_N_ON,1,1	;
	DB C_BLD,C_N_ON,1,3	;
	DB C_BLD,C_N_ON,1,4	;
	DB C_BLD,C_N_ON,2,1	;
	DB C_BLD,C_V_ON,3	;
	DB C_BLD,C_V_ON,4	;
	DB C_BLD,C_V_ON,5	;
	DW	0000H

M34:		;聞く　亜希１
;	DB	'【瑠璃】：・・・雛菊さんなら、酔って温泉で溺れて、先生に介抱されていたわ。'
	DB	"Ruri:  Aki almost drowned in the bath. Kyoko-sensei is"
	DB	CR
	DB	"taking care of her."
	DB	NEXT
;	DB	'【%001】：ふぅん・・・'
	DB	"%001:  I see."
	DB	NEXT
;	DB	'（・・・確か・・・白水さんにキスされて倒れたんじゃなかったか？）'
	DB	".....I seem to recall Ruri kissing Aki before that all"
	DB	CR
	DB	"happened..."
	DB	NEXT
;	DB	'【%001】：白水さん、覚えてないの？'
	DB	"%001:  Don't you remember it?"
	DB	NEXT
;	DB	'【瑠璃】：・・・何を？'
	DB	"Ruri:  Remember what?"
	DB	NEXT
;	DB	'【%001】：・・・いや、なんでもない。'
	DB	"%001:  ......Oh, nevermind."
	DB	NEXT
;	DB	'（そうそう、白水さんはお酒飲むと記憶が消えるんだった。）'
	DB	"I forgot, when she drinks, she loses her memory."
	DB	FLG,F_COPYI,13,1
	DW	0000H

M35:		;聞く　亜希２
;	DB	'【瑠璃】：・・・先生が看病しているわ。'
	DB	"Ruri:  Kyoko-sensei is taking care of her."
	DB	FLG,F_COPYI,13,2
	DW	0000H

M36:		;聞く　亜希３
;	DB	'【瑠璃】：・・・すぐ、元気になるわ。'
	DB	"Ruri:  I'm sure she'll be alright soon."
	DW	0000H

M37:		;聞く　今日子先生１
;	DB	'【瑠璃】：先生なら、部屋で雛菊さんに付き添っているわ。'
	DB	"Ruri:  She's taking care of Aki."
	DB	FLG,F_COPYI,14,1
	DW	0000H

M38:		;聞く　今日子先生２
;	DB	'【瑠璃】：・・・先生が、気になるの？'
	DB	"Ruri:  Are you worried about her?"
	DB	NEXT
;	DB	'【%001】：・・・まーね・・・'
	DB	"%001:  ......Not really."
	DW	0000H

M39:		;考える
;	DB	'（・・・・・・何があったんだ？）'
	DB	"......What happened to me?"
	DB	NEXT
;	DB	'（・・・・・・・・・・・・）'
	DB	"........................."
	DB	FLG,F_COPYI,15,1
	DW	0000H

M40:		;考える
;	DB	'（・・・そうだ！女風呂をのぞいてて・・・）'
	DB	".....Now I remember! I was peeking into the women's"
	DB	CR
	DB	"bath, and..."
	DB	NEXT
;	DB	'（・・・いやぁ・・・素晴らしい光景だった・・・）'
	DB	"I'll never forget that scene as long as I live..."
	DB	NEXT
;	DB	'（あづっ！？）'
	DB	"Ouch!"
	DB	FLG,F_COPYI,15,2
	DW	0000H

M41:		;考える
;	DB	'右目の上の辺りが、自分の鼓動に合わせてズッキン、ズッキン、と痛む。'
	DB	"The area above my my right eye is puffed up like a rock,"
	DB	CR
	DB	"and pulsating with pain."
	DB	NEXT
;	DB	'（・・・何でだ？）'
	DB	"..............Why?"
	DB	FLG,F_COPYI,15,3
	DW	0000H

M42:		;考える
;	DB	'（ここ、どこだ？）'
	DB	"Where am I?"
	DB	NEXT
;	DB	'（・・・・・・・・・・・・・・・）'
	DB	".........................."
	DB	NEXT
;	DB	'（・・・温泉旅館の、俺と誠の部屋だな。）'
	DB	"I'm in my room in the inn."
	DB	NEXT
;	DB	'（・・・・・・・・・誠のやつ、どこ行ったんだ？）'
	DB	"..........Where the hell is Makoto?"
	DB	FLG,F_COPYI,15,4
	DW	0000H

M43:		;考える
;	DB	'【%001】：うぅ・・・'
	DB	"%001:  Ouch...!"
	DB	NEXT
;	DB	'「あ、気が付いた？」'
	DB	"???:  Are you awake?"
	DB	NEXT
;	DB	'【%001】：うわっ！？'
	DB	"%001:  ....Wah!"
	DB	NEXT
;	DB	'突然他人の声が聞こえて、俺は跳ね起きた。'
	DB	"I jumped at the sudden voice. A wet towel fell from my eyes,"
	DB	CR
	DB	"then."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT05','C',0,10,5
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ..............."
	DB	NEXT
;	DB	'【%001】：・・・白水さん・・・？'
	DB	"%001:  ......Ruri...?"
	DB	FLG,F_COPYI,15,5
	DB C_BLD,C_V_OFF,1
	DB C_BLD,C_N_ON,1,2
	DB C_BLD,C_N_ON,1,4
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_N_ON,2,2
	DW	0000H

M44:		;考える
;	DB	'（もしかして・・・看病してくれてるの？）'
	DB	"Has she been taking care of me?"
	DW	0000H

M45:		;迷う
;	DB	'【%001】：わからねぇ・・・どうすればいいのかわかんねぇんだ！'
	DB	"%001:  I don't know! I don't know what I should do!"
	DB	NEXT
;	DB	'【今日子】：落ち着きなさい、%001君。'
	DB	"Kyoko:  Calm down, %001!"
	DB	NEXT
;	DB	'【今日子】：あの子に面と向かって「好きだ」って言える？'
	DB	"Kyoko:  Can you look her in the face and say, 'I love"
	DB	CR
	DB	"you' to her?"
	DB	NEXT
;	DB	'【%001】：・・・俺・・・俺は・・・！'
	DB	"%001:  .....I...........I think so, but...!"
	DB	NEXT
;	DB	'【今日子】：ただの同情は、あの子をますます傷つけるだけよ・・・。'
	DB	"Kyoko:  Sympathy won't do anything for her, if that's all"
	DB	CR
	DB	"you're feeling."
	DW	0000H

M46:		;追いかける１
;	DB	'【%001】：俺は・・・'
	DB	"%001:  I...."
	DB	NEXT
	T_CG1 'CT02','Y','I',0,2
;	DB	'【清美】：・・・どうなさいましたの？'
	DB	"Kiyomi:  What's the matter?"
	DB	NEXT
;	DB	'【%001】：新藤さん・・・'
	DB	"%001:  Kiyomi, I..."
	DB	NEXT
;	DB	'【今日子】：%001君・・・心に迷いがあるなら、追いかけるべきじゃないわ。'
	DB	"Kyoko:  %001, if you're not sure of yourself, you"
	DB	CR
	DB	"shouldn't run after her."
	DB	NEXT
;	DB	'【今日子】：ただの同情は、あの子をますます傷つけるのよ・・・。'
	DB	"Kyoko:  Sympathy is only going to hurt her more."
	DB	NEXT
;	DB	'【%001】：俺は・・・'
	DB	"%001:  I......."
	DB	FLG,F_COPYI,17,1
	DW	0000H


M47:		;追いかける２
;	DB	'【%001】：俺は・・・白水さんを放っておけない。'
	DB	"%001:  I can't just let her go like that."
	DB	NEXT
;	DB	'【清美】：・・・！'
	DB	"Kiyomi:  .........!"
	DB	NEXT
;	DB	'【%001】：きっと、初めて会った時から、俺は・・・'
	DB	"%001:  Ever since I met Ruri, I've known...she was the"
	DB	CR
	DB	"one."
	DB	NEXT
;	DB	'【今日子】：なら、追いかけなさい。急いで！'
	DB	"Kyoko:  Then go after her! Hurry!"
	DB	NEXT
;	DB	'【%001】：新藤さん、みんなに謝っといてくれ！'
	DB	"%001:  Kiyomi, apologize to the others for me!"
	DB	NEXT
;	DB	'【清美】：%001さん、わたくしは・・・あなたのことが！'
	DB	"Kiyomi:  Wait, %001! I love you!"
	DB	NEXT
;	DB	'【%001】：・・・ごめん！'
	DB	"%001:  ......Forgive me, Kiyomi!"
	DB	NEXT
	B_O B_FADE
	DB SINARIO,'CSE_E_1.OVL',0
	DW	0000H


M48:		;追いかけない
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................"
	DB	NEXT
;	DB	'【今日子】：いいのよ%001君。それも一つの答だから。'
	DB	"Kyoko:  That's alright, too."
	DB	NEXT
;	DB	'【今日子】：瑠璃ちゃんじゃない人が好きなら、追いかけないことがあの子に対して誠実であるということよ。'
	DB	"Kyoko:  If you love someone other than Ruri, it'd be unfair"
	DB	CR
	DB	"for you to chase after her."
	DB	FLG,F_COPYI,18,1
	DW	0000H


M49:		;追いかけない２
;	DB	'【%001】：俺は・・・白水さんを・・・傷つけると思う。'
	DB	"%001:  If I went after her, I think I'd only hurt her."
	DB	NEXT
;	DB	'【今日子】：そう思うなら、ここにいなさい。それも一つの答だから、自分を責めることはないのよ。'
	DB	"Kyoko:  Then stay here. That's your answer, and there's"
	DB	CR
	DB	"no reason to be ashamed of yourself."
	DB	NEXT
;	DB	'【今日子】：ま、引率者としての責任上、あたしは今から追いかけるわ。誠君、駅まで付いて来てくれる？'
	DB	"Kyoko:  As her teacher, though, I will go after her."
	DB	CR
	DB	"Makoto, will you go to the station with me?"
	DB	NEXT
;	DB	'【誠】：任務了解！'
	DB	"Makoto:  Roger, Commander!"
	DB	NEXT
;	DB	'【今日子】：それじゃ・・・後はよろしくね、%001君。'
	DB	"Kyoko:  Okay, I'll see you back at home, %001."
	DB	NEXT
;	DB	'【%001】：・・・はい・・・'
	DB	"%001:  ...Alright."
	DB	NEXT
;	DB	'・・・こうして、白水　瑠璃さんは俺達の前から姿を消した。'
	DB	"And that was how Ruri Shiromizu left our lives forever."
	DB	NEXT
	B_O B_FADE
	DB SINARIO,'CSB01.OVL',0
	DW	0000H


end
