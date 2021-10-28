;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｂ０５＿Ｃ
;		水脈のチョコ

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

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	'MIO',0
;NN2:	DB	2,	'プール',0
NN2:	DB	2,	'POOL',0
;NN3:	DB	3,	'グラウンド',0
NN3:	DB	3,	'BASEBALL FIELD',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　美緒
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7		;話す　美緒４
S3:		DW	VV3, NN2,  3, M8, M9		;行く　プール
S4:		DW	VV3, NN3,  4, M10, M11		;行く　グラウンド２


;イニシャルメッセージ
M1:
	DB	BGM,13
	BAK_INIT "AB_12_1"
	B_P1 B_SUDA
;	DB	'俺はテニスコートにやって来た。'
	DB	"I'm at the tennis courts."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT12","T",0,15,1
;	DB	'【今日子】：あら、%001くんじゃない。'
	DB	"Kyoko:  Oh, it's %001."
	DB	NEXT
;	DB	'【%001】：きょ・・・今日子先生・・・'
	DB	"%001:  K- Kyoko-sensei!"
	DB	NEXT
;	DB	'【%001】：その・・・美緒ちゃんは？'
	DB	"%001:  Um, where's Mio?"
	DB	NEXT
;	DB	'【今日子】：美緒！愛しの%001君がチョコもらいに来たわよ！'
	DB	"Kyoko:  Mio! %001's here to get his chocolate and your"
	DB	CR
	DB	"confession of true love!"
	DB	NEXT
;	DB	'【%001】：せ・・・先生・・・'
	DB	"%001:  ....S- Sensei...."
	DB	NEXT
;	DB	'【今日子】：はいはい、お邪魔虫は退散するわ。'
	DB	"Kyoko:  Okay, I know when I'm not wanted."
	DB	NEXT
	DB	G_FLG,G_COPYI,103,1
	DB	G_FLG,G_COPYF,3,101
	DB	G_FLG,G_COPYF,101,101
	DB	G_FLG,G_COPYF,4,102
	DB	G_FLG,G_COPYF,102,102
	DB	G_FLG,G_COPYF,103,103
	DB	G_FLG,G_COPYF,169,169
	DB	C_BLD,C_V_ON,3		;行く
	DB	FLG,F_JGR,169
	DW	M_AKI
;	DB	'今日子先生と入れ替わりに、美緒ちゃんが走ってきた。'
	DB	"As Kyoko-sensei left, Mio came running up."
	DB	NEXT
	DB	BUF,B_COPY01
	DB	ANI,A_OFF
	T_CG "CT03","W","R",15,2
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【%001】：美緒ちゃん・・・'
	DB	"%001:  Mio....."
	DW	0000H

M2:		;見る　美緒
;	DB	'・・・真っ赤っかだ・・・'
	DB	"Her face is bright red."
	DW	0000H

M3:		;見る　美緒
;	DB	'美緒ちゃんは泣きそうな目で、俺の次の言葉を待っている。'
	DB	"She's looking at me like she's about to cry. "
	DW	0000H

M4:		;話す　美緒１
;	DB	'【美緒】：%001先輩・・・あの・・・あたし・・・'
	DB	"Mio:  %001, I...I, um..."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　美緒２
;	DB	'【美緒】：・・・あの・・・あの・・・'
	DB	"Mio:  I, um..."
	DB	NEXT
;	DB	'美緒ちゃんは大きな四角い箱を俺に差し出した。'
	DB	"She hands me a cutely-decorated package."
	DB	NEXT
;	DB	'【美緒】：こっっこれ、食べて下さい！'
	DB	"Mio:  P- Please eat this!"
	DB	NEXT
;	DB	'【%001】：美緒ちゃん・・・これ、バレンタインのチョコ、だよね？'
	DB	"%001:  Mio, is this Valentine's Day chocolate?"
	DB	NEXT
;	DB	'【美緒】：う、うん！'
	DB	"Mio:  Yes!"
	DB	NEXT
;	DB	'【%001】：・・・そ、その・・・義理、なのかな・・・'
	DB	"%001:  ....You didn't have to."
	DB	NEXT
;	DB	'【美緒】：そんなことない！あたし、あたし先輩のことが・・・'
	DB	"Mio:  Oh, I wanted to! I mean, well, what I mean is...."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・・・・・・・・・・・・・・・・スキ。'
	DB	"Mio:  ......I love you."
	DB	NEXT
;	DB	'【%001】：・・・ありがとう、美緒ちゃん。とても嬉しいよ。'
	DB	"%001:  Thank you, Mio. I'm really happy."
	DB	NEXT
;	DB	'【美緒】：・・・%001先輩・・・！'
	DB	"Mio:  .....%001...!!"
	DB	NEXT
;	DB	'【%001】：美緒ちゃん・・・一つだけ、俺の頼みを聞いてくれないか？'
	DB	"%001:  Mio, will you do something for me?"
	DB	NEXT
;	DB	'【美緒】：頼み？'
	DB	"Mio:  Do something for you?"
	DB FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　美緒３
;	DB	'【%001】：出来たら・・・返事を待って欲しいんだ。一ヶ月後の、ホワイトデーまで。'
	DB	"%001:  I want you to wait for my answer. I'll give it to"
	DB	CR
	DB	"you in one month, on White Day."
	DB	NEXT
	K_CG "CT03","I",15,3
;	DB	'【美緒】：・・・どうして？'
	DB	"Mio:  ....Why?"
	DB	NEXT
;	DB	'【%001】：俺、美緒ちゃんの気持ちは嬉しいんだ。・・・だけど、美緒ちゃんの他にも、俺を好きだって言ってくれる女の子がいる。'
	DB	"%001:  I'm really happy to hear how you feel. But there"
	DB	CR
	DB	"are other girls who feel the same way."
	DB	NEXT
;	DB	'【美緒】：・・・！'
	DB	"Mio:  .......!!"
	DB	NEXT
;	DB	'【%001】：情けない話だけど、今の俺には分からないんだ。俺が一番に好きなのは誰かってことを。'
	DB	"%001:  I'm ashamed to say it, but I'm not sure yet...who"
	DB	CR
	DB	"I really love..."
	DB	NEXT
;	DB	'【%001】：俺、鈴子さんに好きって言ってもらって嬉しいんだ。この気持ちだけは、胸を張って言えるよ。'
	DB	"%001:  I'm really happy that you told me you loved me. I'll"
	DB	CR
	DB	"hold that in my heart forever."
	DB	NEXT
;	DB	'【%001】：こんな優柔不断でカナヅチの俺を好きでいてくれるなら・・・一ヶ月待ってくれ！'
	DB	"%001:  I'm sorry for being so indecisive. But please wait"
	DB	CR
	DB	"one month!"
	DB	NEXT
;	DB	'【美緒】：・・・先輩・・・'
	DB	"Mio:  %001......"
	DB	FLG,F_COPYI,2,3
	DW	0000H


M7:		;話す　美緒４
;	DB	'【美緒】：・・・・・・・・・・・・'
	DB	"Mio:  .........................."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  .................."
	DB	NEXT
;	DB	'【美緒】：・・・・・・'
	DB	"Mio:  ............."
	DB	NEXT
;	DB	'【美緒】：・・・'
	DB	"Mio:  ......"
	DB	NEXT
;	DB	'【美緒】：・・・・・・%001先輩・・・。'
	DB	"Mio:  %001, I...."
	DB	NEXT
;	DB	'【美緒】：・・・・・・あたし、あたし・・・・・・・・・待ってる。'
	DB	"Mio:  I'll wait for you."
	DB	NEXT
;	DB	'【%001】：美緒ちゃん・・・ありがとう。'
	DB	"%001:  Thank you, Mio."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・・・・・・・・・・・・・・待ってるから。'
	DB	"Mio:  I'll wait for your answer."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'・・・美緒ちゃんは走っていった。'
	DB	"Mio runs off."
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
	DB	"Now...I've got to make up my mind which one I really love."
	DB	NEXT
;	DB	'・・・みんなの気持ちに、報いるために。'
	DB	"I owe that to all of them."
	DB	NEXT
	DB	SINARIO,'CSC01_.OVL',0
	DW	0000H


M8:		;行く　プール
;	DB	'【%001】：鈴子さんが待ってる・・・'
	DB	"%001:  Reiko's waiting for me."
	DB	NEXT
;	DB	'俺はプールに向かった。'
	DB	"I head for the pool."
	DB	NEXT
	DB	SINARIO,'CSB05_A.OVL',0
	DW	0000H

M9:		;行く　プール
;	DB	'鈴子さんとは、もう話した。'
	DB	"I've already talked to Reiko."
	DW	0000H

M10:		;行く　グラウンド１
;	DB	'【%001】：新藤さんが待ってる・・・'
	DB	"%001:  Kiyomi's waiting for me."
	DB	NEXT
;	DB	'俺は野球部のグラウンドに向かった。'
	DB	"I head for the baseball field."
	DB	NEXT
	DB	SINARIO,'CSB05_B.OVL',0
	DW	0000H

M11:		;行く　グラウンド２
;	DB	'新藤さんとは、もう話した。'
	DB	"I already talked to Kiyomi."
	DW	0000H

M_AKI:
;	DB	'【%001】：あ、先生、ちょっとお願いがあるんだけど。'
	DB	"%001:  Oh, Kyoko-sensei, I've got a favor to ask of you..."
	DB	NEXT
;	DB	'【今日子】：あら、な～に？'
	DB	"Kyoko:  What is it?"
	DB	NEXT
;	DB	'俺は亜希ちゃんから預かった、誠あてのチョコを出した。'
	DB	"I took out the chocolate Aki gave me for Makoto."
	DB	NEXT
;	DB	'【%001】：これ、亜希ちゃんに「誠に渡してくれ」って頼まれたんだけど・・・'
	DB	"%001:  Aki gave this to me, and asked me to give it to"
	DB	CR
	DB	"Makoto."
	DB	NEXT
;	DB	'【今日子】：あら%001君、亜希ちゃんにはフラレちゃったの？'
	DB	"Kyoko:  Oh, did she decide she doesn't love you?"
	DB	NEXT
;	DB	'【%001】：・・・俺ももらいました。'
	DB	"%001:  I got some, too."
	DB	NEXT
;	DB	'【%001】：で、これ先生から誠に渡してくれません？そーすれば誠も復活すると思うんで。'
	DB	"%001:  Will you give this to him for me? I'm sure he'd be"
	DB	CR
	DB	"happy."
	DB	NEXT
;	DB	'【今日子】：ふ～ん。ま、一肌脱ぎましょ。'
	DB	"Kyoko:  Well, I guess I can do that."
	DB	NEXT
;	DB	'今日子先生は校舎の方に行き、入れ替わりに美緒ちゃんが走ってきた。'
	DB	"As Kyoko runs off towards the school building, Mio runs"
	DB	CR
	DB	"up to me."
	DB	NEXT
	DB	BUF,B_COPY01
	DB	ANI,A_OFF
	T_CG "CT03","W","R",15,2
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【%001】：美緒ちゃん・・・'
	DB	"%001:  Mio...."
	DW	0000H


end
