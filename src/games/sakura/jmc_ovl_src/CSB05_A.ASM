	;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｂ０５＿Ａ
;		鈴子のチョコ
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN2,NN3,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'行く',0
VV3:	DB	3,	'GO',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'グラウンド',0
NN2:	DB	2,	'BASEBALL FIELD',0
;NN3:	DB	3,	'テニスコート',0
NN3:	DB	3,	'TENNIS COURTS',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子
S2:		DW	VV2, NN1,  2, M4, M5, M6		;話す　鈴子３
S3:		DW	VV3, NN2,  3, M7, M8		;行く　グラウンド２
S4:		DW	VV3, NN3,  4, M9, M10		;行く　テニスコート


;イニシャルメッセージ
M1:
	DB	BGM,13
	BAK_INIT "AB_23"
	B_P1 B_SUDA
;	DB	'俺はプールにやって来た。'
	DB	"I'm at the pool."
	DB	NEXT
;	DB	'【%001】：鈴子さーん！'
	DB	"%001:  Reiko?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT01","W","R",15,1
;	DB	'【鈴子】：%001君、来てくれたのね。'
	DB	"Reiko:  %001, you're here. I knew you'd come for me."
	DB	G_FLG,G_COPYI,101,1
	DB	G_FLG,G_COPYF,101,101
	DB	G_FLG,G_COPYF,3,102
	DB	G_FLG,G_COPYF,102,102
	DB	G_FLG,G_COPYF,4,103
	DB	G_FLG,G_COPYF,103,103
	DB	C_BLD,C_V_ON,3		;行く　消す
	DW	0000H

M2:		;見る　鈴子
;	DB	'今日は水着じゃないんだ・・・'
	DB	"She's not wearing her bathing suit today."
	DW	0000H

M3:		;見る　鈴子
;	DB	'鈴子さんは不安そうな目で、俺の次の言葉を待っている。'
	DB	"She's looking at me with worried eyes."
	DW	0000H

M4:		;話す　鈴子１
;	DB	'【鈴子】：%001君・・・これ、受け取って。'
	DB	"Reiko:  Here, %001, this is for you."
	DB	NEXT
;	DB	'そう言って、鈴子さんはリボンで飾られた包みを俺に差し出した。'
	DB	"She handed me a beautiful package decorated with a ribbon."
	DB	NEXT
;	DB	'【鈴子】：この一年間、いろんな事があったわ。'
	DB	"Reiko:  A lot has happened over the past year..."
	DB	NEXT
;	DB	'【鈴子】：君との出会いに始まって・・・君と一緒に、今日まで過ごしてきた。'
	DB	"Reiko:  Since the moment we met on the sidewalk outside"
	DB	CR
	DB	"the school, up til now..."
	DB	NEXT
;	DB	'【鈴子】：・・・私の思い出の光景には、必ず君の顔が映ってるの。'
	DB	"Reiko:  Every time I remember it all, you're there, in my"
	DB	CR
	DB	"mind."
	DB	NEXT
;	DB	'【鈴子】：%001君・・・私、あなたが好き。'
	DB	"Reiko:  %001... I love you."
	DB	NEXT
;	DB	'【%001】：ありがとう、鈴子さん。俺を好きになってくれて。'
	DB	"%001:  Thank you, Reiko, for that."
	DB	NEXT
;	DB	'【%001】：俺、とても嬉しいよ、鈴子さん。'
	DB	"%001:  I'm really happy. Really."
	DB	NEXT
;	DB	'【鈴子】：・・・%001君・・・'
	DB	"Reiko:  ........%001...."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・一つだけ、俺の頼みを聞いてくれないか？'
	DB	"%001:  Reiko, will you do one thing for me?"
	DB	NEXT
;	DB	'【鈴子】：頼み？'
	DB	"Reiko:  Yes, what?"
	DB	FLG,F_COPYI,1,1
	DB FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　鈴子２
;	DB	'【%001】：出来たら・・・返事を待って欲しいんだ。一ヶ月後の、ホワイトデーまで。'
	DB	"%001:  I want you to wait for my answer. I'll give it to"
	DB	CR
	DB	"you in one month, on White Day."
	DB	NEXT
	K_CG "CT01","I",15,2
;	DB	'【鈴子】：え？'
	DB	"Reiko:  What?"
	DB	NEXT
;	DB	'【%001】：鈴子さんの他にも、俺を好きだって言ってくれる女の子がいる。'
	DB	"%001:  There are others who feel the same way you do."
	DB	NEXT
;	DB	'【鈴子】：！'
	DB	"Reiko:  !!"
	DB	NEXT
;	DB	'【%001】：情けない話だけど、今の俺には分からないんだ。俺が一番に好きなのは誰かってことを。'
	DB	"%001:  I'm ashamed to say it, but I'm not sure yet..."
	DB	CR
	DB	"who I really love..."
	DB	NEXT
;	DB	'【%001】：俺、鈴子さんに好きって言ってもらって嬉しいんだ。この気持ちだけは、胸を張って言えるよ。'
	DB	"%001:  I'm really happy that you told me you loved me."
	DB	CR
	DB	"I'll hold that in my heart forever."
	DB	NEXT
;	DB	'【%001】：こんな優柔不断でカナヅチの俺を好きでいてくれるなら・・・一ヶ月待ってくれ！'
	DB	"%001:  I'm sorry for being so indecisive. But please"
	DB	CR
	DB	"wait one more month!"
	DB	NEXT
;	DB	'【鈴子】：・・・'
	DB	"Reiko:  ............."
	DB	FLG,F_COPYI,2,2
	DW	0000H


M6:		;話す　鈴子３
	T_CG "CT01","W",0,15,3
;	DB	'【鈴子】：・・・分かったわ・・・%001君。'
	DB	"Reiko:  Alright, I'll wait."
	DB	NEXT
;	DB	'【鈴子】：君が誰を選んでも、私はその結果を受け入れるわ。'
	DB	"Reiko:  And I'll respect your decision."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・ありがとう。'
	DB	"%001:  Reiko, thank you."
	DB	NEXT
;	DB	'【鈴子】：さて、練習練習！金メダル目指してがんばらなきゃ！'
	DB	"Reiko:  Okay, I've got to practice now! That gold medal"
	DB	CR
	DB	"is waiting for me..."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'・・・鈴子さんは走っていった。'
	DB	"Reiko ran off."
	DB	C_BLD,C_V_OFF,3		;行く
	DB	C_BLD,C_V_ON,1		;見る
	DB	C_BLD,C_V_ON,2		;話す
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,4,255,101,102,103
	DB	FLG,F_EXIT,255
	DB	NEXT
	SUDA_CLS
;	DB	'・・・これで、みんなから気持ちを受け取った。'
	DB	"....Now I've heard what everyone has to tell me."
	DB	NEXT
;	DB	'後は・・・俺が答えを出さなきゃならない。'
	DB	"Now, I've got to make up my mind which one I really love."
	DB	NEXT
;	DB	'・・・みんなの気持ちに、報いるために。'
	DB	"I owe that to all of them."
	DB	NEXT
	DB	SINARIO,'CSC01_.OVL',0
	DW	0000H


M7:		;行く　グラウンド１
;	DB	'【%001】：新藤さんが待ってる・・・'
	DB	"%001:  Kiyomi's waiting for me."
	DB	NEXT
;	DB	'俺は野球部のグラウンドに向かった。'
	DB	"I head for the baseball field."
	DB	NEXT
	DB	SINARIO,'CSB05_B.OVL',0
	DW	0000H

M8:		;行く　グラウンド２
;	DB	'新藤さんとは、もう話した。'
	DB	"I already talked to Kiyomi."
	DW	0000H

M9:		;行く　テニスコート
;	DB	'【%001】：美緒ちゃんが待ってる・・・'
	DB	"%001:  Mio's waiting for me."
	DB	NEXT
;	DB	'俺はテニスコートに向かった。'
	DB	"I head for the tennis courts."
	DB	NEXT
	DB	SINARIO,'CSB05_C.OVL',0
	DW	0000H

M10:		;行く　テニスコート
;	DB	'美緒ちゃんとは、もう話した。'
	DB	"I already talked to Mio."
	DW	0000H


end
