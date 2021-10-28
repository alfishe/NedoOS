;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０１＿
;		運命の洗濯

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7, S8, S9
MSGTBL:
        DW	M1
COMTBL:
        DW	CM1, CM2, CM3, CM4, CM5, CM6
VNTBL:
        DW	V_FNAME,N_FNAME
ENDTBL:

        INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
        INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1
CM6:	DW	VV6,	NN2,NN3,NN4,NN5,-1

;VV1:	DB	1,	'振り返る',0
VV1:	DB	1,	'LOOK BACK',0
;VV2:	DB	2,	'鈴子',0
VV2:	DB	2,	'REIKO',0
;VV3:	DB	3,	'清美',0
VV3:	DB	3,	'KIYOMI',0
;VV4:	DB	4,	'美緒',0
VV4:	DB	4,	'MIO',0
;VV5:	DB	5,	'亜希',0
VV5:	DB	5,	'AKI',0
;VV6:	DB	6,	'行く',0
VV6:	DB	6,	'GO',0

;NN1:	DB	1,	'一年間',0
NN1:	DB	1,	'THE PAST YEAR',0
;NN2:	DB	2,	'プール',0
NN2:	DB	2,	'POOL',0
;NN3:	DB	3,	'グラウンド',0
NN3:	DB	3,	'BASEBALL FIELD',0
;NN4:	DB	4,	'テニスコート',0
NN4:	DB	4,	'TENNIS COURTS',0
;NN5:	DB	5,	'屋上',0
NN5:	DB	5,	'THE ROOF',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5, M6		;振り返る　一年間
S2:		DW	VV2, -1,  2, M7		;鈴子
S3:		DW	VV3, -1,  3, M8		;清美
S4:		DW	VV4, -1,  4, M9		;美緒
S5:		DW	VV5, -1,  5, M10		;亜希
S6:		DW	VV6, NN2,  6, M11, M12		;行く　プール２
S7:		DW	VV6, NN3,  7, M13, M14		;行く　グラウンド２
S8:		DW	VV6, NN4,  8, M15, M16		;行く　テニスコート２
S9:		DW	VV6, NN5,  9, M17, M18		;行く　屋上２


;イニシャルメッセージ
M1:
        DB	BGM,11
        B_O B_FADE
        E_CG B_FADE,"T_12"
        DB	NEXT
        BAK_INIT "AB_36_1"
        B_P1 B_SUDA
        ;	DB	'・・・・・・３月１４日・・・放課後・・・・・・'
        DB	"March 14th...after school."
        DB	NEXT
        DB	"White Day is here."
        DB C_BLD,C_V_ON,2		;鈴子
        DB C_BLD,C_V_ON,3		;清美
        DB C_BLD,C_V_ON,4		;美緒
        DB C_BLD,C_V_ON,5		;亜希
        DB C_BLD,C_V_ON,6		;行く
        DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109
        DW	0000H
        
M2:		;振り返る　一年間
        ;	DB	'（この一年・・・いろんな事があったな。）'
        DB	"A lot happened to us this year..."
        DB	NEXT
        ;	DB	'（・・・入学式の直前に、鈴子さんとぶつかりそうになって・・・）'
        DB	"Meeting Reiko by nearly crashing into her, that first"
        DB	CR
        DB	"morning..."
        DB	NEXT
        ;	DB	'（新藤さん、誠、吉田、中野・・・クラスのみんな、それに、今日子先生と出会って。）'
        DB	"Getting to know Kiyomi, Makoto, Meimi, Seia...  And of"
        DB	CR
        DB	"course, Kyoko-sensei."
        DB	NEXT
        ;	DB	'（桜の木の下で、美緒ちゃんと出会って・・・',CR
        ;	DB	'・・鈴子さんと新藤さんと、それぞれ俺をクラブに入れようとして。）'
        DB	"Then there was that outrageous cherry blossom viewing,"
        DB	CR
        DB	"and everyone trying to get me to join their favorite clubs."
        DB	NEXT
        ;	DB	'（・・・祥子さんに体育倉庫で襲われて・・・）'
        DB	".....Then that incident with Shoko."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;振り返る　一年間
        ;	DB	'（花見の次の日、二日酔いで学級閉鎖になって。）'
        DB	".....Everyone in the class being absent the day after"
        DB	CR
        DB	"the cherry blossom viewing party because of hangovers..."
        DB	NEXT
        ;	DB	'（白水さんが転校して来て・・・。）'
        DB	"Ruri transferred to our school shortly after that."
        DB	NEXT
        ;	DB	'（亜希ちゃんと初めて会ったのは、ゴールデンウィーク中だったっけ）'
        DB	"The first time I met Aki was during Golden Week."
        DB	FLG,F_COPYI,1,2
        DW	0000H
        
        
M4:		;振り返る　一年間
        ;	DB	'（林間学校・・・）'
        DB	"Then we had summer camp in Hokkaido."
        DB	NEXT
        ;	DB	'（臨海学校・・・）'
        DB	"And the seaside school..."
        DB	NEXT
        ;	DB	'（体育文化祭・・・）'
        DB	"And the sports and culture festival..."
        DB	NEXT
        ;	DB	'（・・・あんまり勉強した記憶が無いのは、気のせいじゃないよな。）'
        DB	"I don't remember doing any studying during this year. I was"
        DB	CR
        DB	"too busy."
        DB	NEXT
        ;	DB	'（今日子先生に、女の人の事を教えてもらった夜・・・）'
        DB	"Kyoko-sensei taught me about women after that..."
        DB	NEXT
        ;	DB	'（あの日から、確かに俺は変わった・・・）'
        DB	"I'll never be the same."
        DB	FLG,F_COPYI,1,3
        DW	0000H
        
        
M5:		;振り返る　一年間
        ;	DB	'（クリスマスパーティ・・・そして、お正月の温泉旅行。）'
        DB	"The Christmas Party......and the trip to the hot springs."
        DB	NEXT
        ;	DB	'（・・・白水さんは、お母さんのところに帰っていった。）'
        DB	"Ruri, leaving to go live with her mother..."
        DB	NEXT
        ;	DB	'（そして・・・みんなから告白されたバレンタインデー。）'
        DB	"And Valentine's Day."
        DB	NEXT
        ;	DB	'（鈴子さんがくれたのは、ちょっといびつなハート型のチョコレート。'
        DB	"Reiko gave me a heart-shaped chocolate with the words I"
        DB	CR
        DB	"LOVE YOU written in white chocolate."
        DB	NEXT
        ;	DB	'（新藤さんは、小さなハート型チョコを箱にたくさん詰めてくれた。',CR
        ;	DB	'　　食べやすい大きさのチョコに、俺は新藤さんの気配りを感じた。）'
        DB	"Kiyomi gave me a box with little heart-shaped chocolates."
        DB	NEXT
        ;	DB	'（美緒ちゃんは手作りのチョコレートケーキ。',CR
        ;	DB	'　　　　　　　　　　　　　　　　　・・・さすがにおいしかった。）'
        DB	"Mio gave me a chocolate cake that she had made herself."
        DB	CR
        DB	"It was delicious."
        DB	NEXT
        ;	DB	'（亜希ちゃんは特大のハートチョコ。',CR
        ;	DB	'　　　　　　　　　　　　　・・・食べ切るのに、一週間かかった。）'
        DB	"Aki gave me a giant heart-shaped chocolate. It took me a"
        DB	CR
        DB	"week to eat it."
        DB	FLG,F_COPYI,1,4
        DW	0000H
        
        
M6:		;振り返る　一年間
        ;	DB	'（俺はみんなに、ホワイトデーに答を出すって約束した。）'
        DB	"I made up my mind to choose one of them by White Day."
        DB	NEXT
        ;	DB	'（長いような、短いような１ヶ月が過ぎて・・・）'
        DB	"A strange month has passed since then..."
        DB	NEXT
        ;	DB	'（・・・・・・とうとう、この時が来た。）'
        DB	"But now March 14th is finally here."
        DB	NEXT
        ;	DB	'（俺は今日、俺を好きになってくれたみんなに、',CR,'　　　　　俺の出した答えを伝えなきゃいけない。）'
        DB	"Today is the day I'll finally choose one of the women, and"
        DB	CR
        DB	"end this vague existence we've been clinging to."
        DB	NEXT
        ;	DB	'（俺が一番好きな、いつまでも一緒にいたい女の子・・・）'
        DB	"The woman I love. The one I want to be with forever..."
        DB	NEXT
        ;	DB	'（それは・・・・・・・・・・・・・・・・・・・・・！）'
        DB	"She is....."
        DB C_BLD,C_V_ON,1		;振り返る
        DB C_BLD,C_V_OFF,2		;鈴子
        DB C_BLD,C_V_OFF,3		;清美
        DB C_BLD,C_V_OFF,4		;美緒
        DB C_BLD,C_V_OFF,5		;亜希
        DW	0000H
        
M7:		;鈴子
        ;	DB	'（・・・鈴子さん。）'
        DB	"...Reiko."
        DB	NEXT
        ;	DB	'（泳げない俺のために、一生懸命泳ぎを教えてくれた・・・）'
        DB	"She did all she could to teach me how to swim."
        DB	NEXT
        ;	DB	'（俺のことを・・・いつも見守ってくれた・・・）'
        DB	"Guiding me...protecting me."
        DB	NEXT
        ;	DB	'（・・・もうすぐ、遠くに行ってしまう・・・鈴子さん。）'
        DB	"But she's about to go very far away from me..."
        DB	NEXT
        ;	DB	'（そうだよ、この学校に来て最初に会った女の子が、',CR,'鈴子さんだった。）'
        DB	"She was the first people I met at this school."
        DB	NEXT
        ;	DB	'（俺は・・・鈴子さんが、好きなんだ。）'
        DB	"...And I love her."
        DB	NEXT
        ;	DB	'（今すぐこの思いを、伝えに行こう・・・鈴子さんに。）'
        DB	"Let's go tell her right now!"
        DB	NEXT
        ;	DB	'俺は教室を飛び出した。'
        DB	"I ran out of the classroom."
        DB	NEXT
        ;	DB	'（・・・待った！）'
        DB	"Wait!"
        DB	NEXT
        ;	DB	'（俺は・・・みんなに言ったんだ。',CR,'一ヶ月後の今日、答を出すって。）'
        DB	"I told everyone that I'd give them my answer today."
        DB	NEXT
        ;	DB	'（みんなが、俺を待ってくれてる・・・',CR,'・・・俺を信じて、待ってくれてる。）'
        DB	"They're probably waiting for me.....believing that I won't"
        DB	CR
        DB	"run away again."
        DB	NEXT
        ;	DB	'（だから、俺はみんなに言わなくちゃいけない。）'
        DB	".....I've got to go to them all."
        DB	NEXT
        ;	DB	'（新藤さんに、美緒ちゃんに、亜希ちゃんに・・・',CR,'・・・「ごめん」って。）'
        DB	"I've got to apologize to Kiyomi...to Mio...to Aki..."
        DB	NEXT
        ;	DB	'（それが出来なきゃ、鈴子さんに「好きだ」って言う資格なんかねぇ。）'
        DB	"If I can't do that, I don't have the right to tell Reiko I"
        DB	CR
        DB	"love her."
        DB	NEXT
        ;	DB	'（・・・行こう・・・）'
        DB	"I'd better get moving."
        DB G_FLG,G_COPYI,199,0
        DB FLG,F_COPYI,6,1	;行く　プール
        DB C_BLD,C_V_ON,2	;鈴子
        DB C_BLD,C_V_ON,3	;清美
        DB C_BLD,C_V_ON,4	;美緒
        DB C_BLD,C_V_ON,5	;亜希
        DB C_BLD,C_V_OFF,6	;行く
        DW	0000H
        
M8:		;清美
        ;	DB	'（・・・新藤さん。）'
        DB	"...Kiyomi."
        DB	NEXT
        ;	DB	'（一年前からずっと、俺を追いかけてくれた・・・）'
        DB	"She spent a year, looking for me."
        DB	NEXT
        ;	DB	'（俺のことを・・・いつも支えてくれた・・・）'
        DB	"She was always there for me, supporting me."
        DB	NEXT
        ;	DB	'（・・・いつもそばにいてくれた・・・・・・新藤さん。）'
        DB	"Always at my side.....Kiyomi."
        DB	NEXT
        ;	DB	'（そうだよ、この学校に来る前から、俺と新藤さんの運命は重なりあってたんだ。）'
        DB	"My life has been intertwined with Kiyomi's even before I"
        DB	CR
        DB	"came to this school..."
        DB	NEXT
        ;	DB	'（俺は・・・新藤さんが、好きなんだ。）'
        DB	".....And I love her."
        DB	NEXT
        ;	DB	'（今すぐこの思いを、伝えに行こう・・・新藤さんに。）'
        DB	"Let's go tell her right now!"
        DB	NEXT
        ;	DB	'俺は教室を飛び出した。'
        DB	"I ran out of the classroom."
        DB	NEXT
        ;	DB	'（・・・待った！）'
        DB	"Wait!"
        DB	NEXT
        ;	DB	'（俺は・・・みんなに言ったんだ。',CR,'一ヶ月後の今日、答を出すって。）'
        DB	"I told everyone that I'd give them my answer today."
        DB	NEXT
        ;	DB	'（みんなが、俺を待ってくれてる・・・',CR,'・・・俺を信じて、待ってくれてる。）'
        DB	"They're probably waiting for me.....believing that I won't"
        DB	CR
        DB	"run away again."
        DB	NEXT
        ;	DB	'（だから、俺はみんなに言わなくちゃいけない。）'
        DB	"I've got to tell them.....I'm sorry."
        DB	NEXT
        ;	DB	'（新藤さんに、美緒ちゃんに、亜希ちゃんに・・・',CR,'・・・「ごめん」って。）'
        DB	"I've got to apologize to Reiko...to Mio...to Aki..."
        DB	NEXT
        ;	DB	'（それが出来なきゃ、鈴子さんに「好きだ」って言う資格なんかねぇ。）'
        DB	"If I can't do that, I don't have the right to tell Kiyomi"
        DB	CR
        DB	"I love her."
        DB	NEXT
        ;	DB	'（・・・行こう・・・）'
        DB	"I'd better get moving."
        DB G_FLG,G_COPYI,199,1
        DB FLG,F_COPYI,7,1		;行く　グラウンド
        DB C_BLD,C_V_ON,2		;鈴子
        DB C_BLD,C_V_ON,3		;清美
        DB C_BLD,C_V_ON,4		;美緒
        DB C_BLD,C_V_ON,5		;亜希
        DB C_BLD,C_V_OFF,6		;行く
        DW	0000H
        
M9:		;美緒
        ;	DB	'（・・・美緒ちゃん。）'
        DB	"...Mio."
        DB	NEXT
        ;	DB	'（俺に・・・おいしい料理を食べさせてくれた・・・）'
        DB	"She always fussed so much over me, cooking for me so I'd"
        DB	CR
        DB	"be happy."
        DB	NEXT
        ;	DB	'（・・・俺と同じ悩みを持ってた・・・・・・美緒ちゃん。）'
        DB	"She and I are the same.....Mio."
        DB	NEXT
        ;	DB	'（俺の探してた「すごい奴」・・・それは美緒ちゃんだったのかもしれない。）'
        DB	"The person I've been searching for. She's been this"
        DB	CR
        DB	"close to me, all this time."
        DB	NEXT
        ;	DB	'（俺は・・・美緒ちゃんが、好きなんだ。）'
        DB	"....And I love her."
        DB	NEXT
        ;	DB	'（今すぐこの思いを、伝えに行こう・・・鈴子さんに。）'
        DB	"Let's go tell her right now!"
        DB	NEXT
        ;	DB	'俺は教室を飛び出した。'
        DB	"I ran out of the classroom."
        DB	NEXT
        ;	DB	'（・・・待った！）'
        DB	"Wait!"
        DB	NEXT
        ;	DB	'（俺は・・・みんなに言ったんだ。',CR,'一ヶ月後の今日、答を出すって。）'
        DB	"I told everyone that I'd give them my answer today."
        DB	NEXT
        ;	DB	'（みんなが、俺を待ってくれてる・・・',CR,'・・・俺を信じて、待ってくれてる。）'
        DB	"They're probably waiting for me.....believing that I won't"
        DB	CR
        DB	"run away again."
        DB	NEXT
        ;	DB	'（だから、俺はみんなに言わなくちゃいけない。）'
        DB	"........I've got to tell them...I'm sorry."
        DB	NEXT
        ;	DB	'（新藤さんに、美緒ちゃんに、亜希ちゃんに・・・',CR,'・・・「ごめん」って。）'
        DB	"I've got to apologize to Reiko...to Kiyomi...to Aki..."
        DB	NEXT
        ;	DB	'（それが出来なきゃ、鈴子さんに「好きだ」って言う資格なんかねぇ。）'
        DB	"If I can't do that, I don't have the right to tell Mio I"
        DB	CR
        DB	"love her."
        DB	NEXT
        ;	DB	'（・・・行こう・・・）'
        DB	"I'd better get moving."
        DB G_FLG,G_COPYI,199,2
        DB FLG,F_COPYI,8,1	;行く　テニスコート
        DB C_BLD,C_V_ON,2		;鈴子
        DB C_BLD,C_V_ON,3		;清美
        DB C_BLD,C_V_ON,4		;美緒
        DB C_BLD,C_V_ON,5		;亜希
        DB C_BLD,C_V_OFF,6		;行く
        DW	0000H
        
M10:		;亜希
        ;	DB	'（・・・亜希ちゃん。）'
        DB	".....Aki."
        DB	NEXT
        ;	DB	'（・・・はっきり言って、第一印象は良くなかったな。）'
        DB	"To be honest, she didn't make a very good impression on"
        DB	CR
        DB	"me at first."
        DB	NEXT
        ;	DB	'（自分に正直で、あけすけで、負けず嫌いで・・・純粋で。）'
        DB	"But she was always tough, never giving up in a fight...and"
        DB	CR
        DB	"somehow pure."
        DB	NEXT
        ;	DB	'（俺と違って、風に逆らう勇気を持った・・素敵な女の子。）'
        DB	"She has the strength to go against the wind. She's"
        DB	CR
        DB	"a wonderful woman...."
        DB	NEXT
        ;	DB	'（俺は・・・亜希ちゃんが、好きなんだ。）'
        DB	".....And I love her."
        DB	NEXT
        ;	DB	'（今すぐこの思いを、伝えに行こう・・・鈴子さんに。）'
        DB	"Let's go tell her right now!"
        DB	NEXT
        ;	DB	'俺は教室を飛び出した。'
        DB	"I ran out of the classroom."
        DB	NEXT
        ;	DB	'（・・・待った！）'
        DB	"Wait!"
        DB	NEXT
        ;	DB	'（俺は・・・みんなに言ったんだ。',CR,'一ヶ月後の今日、答を出すって。）'
        DB	"I told everyone that I'd give them my answer today."
        DB	NEXT
        ;	DB	'（みんなが、俺を待ってくれてる・・・',CR,'・・・俺を信じて、待ってくれてる。）'
        DB	"They're probably waiting for me...believing that I won't"
        DB	CR
        DB	"run away again."
        DB	NEXT
        ;	DB	'（だから、俺はみんなに言わなくちゃいけない。）'
        DB	"....I've got to tell them...I'm sorry."
        DB	NEXT
        ;	DB	'（新藤さんに、美緒ちゃんに、亜希ちゃんに・・・',CR,'・・・「ごめん」って。）'
        DB	"I've got to apologize to Reiko...to Kiyomi...to Mio..."
        DB	NEXT
        ;	DB	'（それが出来なきゃ、鈴子さんに「好きだ」って言う資格なんかねぇ。）'
        DB	"If I can't do that, I don't have the right to tell Aki"
        DB	CR
        DB	"I love her."
        DB	NEXT
        ;	DB	'（・・・行こう・・・）'
        DB	"I'd better get moving."
        DB G_FLG,G_COPYI,199,3
        DB FLG,F_COPYI,9,1	;行く　屋上
        DB C_BLD,C_V_ON,2		;鈴子
        DB C_BLD,C_V_ON,3		;清美
        DB C_BLD,C_V_ON,4		;美緒
        DB C_BLD,C_V_ON,5		;亜希
        DB C_BLD,C_V_OFF,6		;行く
        DW	0000H
        
M11:		;行く　プール１
        ;	DB	'（・・・鈴子さんに・・・「ごめん」って言わなきゃ。）'
        DB	"I've got to apologize to Reiko."
        DB	NEXT
        DB SINARIO,'CSC01_A.OVL',0
        DW	0000H
        
M12:		;行く　プール２
        ;	DB	'（鈴子さんに会いに行く前に、やるべき事が残ってるだろ？）'
        DB	"Isn't there something you have to do before that, though?"
        DW	0000H
        
        
M13:		;行く　グラウンド１
        ;	DB	'（・・・新藤さんに・・・「ごめん」って言わなきゃ。）'
        DB	"I've got to apologize to Kiyomi."
        DB	NEXT
        DB SINARIO,'CSC01_B.OVL',0
        DW	0000H
        
M14:		;行く　グラウンド２
        ;	DB	'（新藤さんに会いに行く前に、やるべき事が残ってるだろ？）'
        DB	"Isn't there something you have to do before that, though?"
        DW	0000H
        
        
M15:		;行く　テニスコート１
        ;	DB	'（・・・美緒ちゃんに・・・「ごめん」って言わなきゃ。）'
        DB	"I've got to apologize to Mio."
        DB	NEXT
        DB SINARIO,'CSC01_C.OVL',0
        DW	0000H
        
M16:		;行く　テニスコート２
        ;	DB	'（美緒ちゃんに会いに行く前に、やるべき事が残ってるだろ？）'
        DB	"Isn't there something you have to do before that, though?"
        DW	0000H
        
        
M17:		;行く　屋上１
        ;	DB	'（・・・亜希ちゃんに・・・「ごめん」って言わなきゃ。）'
        DB	"I've got to go apologize to Aki."
        DB	NEXT
        DB SINARIO,'CSC01_F.OVL',0
        DW	0000H
        
M18:		;行く　屋上２
        ;	DB	'（亜希ちゃんに会いに行く前に、やるべき事が残ってるだろ？）'
        DB	"Isn't there something you have to do before that, though?"
        DW	0000H


end
