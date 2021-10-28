;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　ＣＳＥ＿ＡＢＡＤ
;		鈴子バッドエンド

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子
S2:		DW	VV2, NN1,  2, M3, M4, M5	;話す　鈴子２


;イニシャルメッセージ
M1:
	DB	BGM,29
	BAK_INIT 'AB_23'
	DB BUF,B_COPY01
	T_CG 'CT01','F',0,15,1
;	DB	'【鈴子】：%001君・・・？'
	DB	"Reiko:  Shuji...?"
	DB G_FLG,G_COPYF,167,167
	DW	0000H

M2:		;見る　鈴子
;	DB	'鈴子さんは怪訝そうな目で、俺の言葉を待っている。'
	DB	"She's looking at me with eyes full of doubt, waiting for"
	DB	CR
	DB	"me to talk."
	DW	0000H

M3:		;話す　鈴子１
;	DB	'【%001】：鈴子さん・・・俺・・・'
	DB	"%001:  Reiko...I..."
	DB	NEXT
;	DB	'【鈴子】：・・・なに・・・？'
	DB	"Reiko:  ...What?"
	DB FLG,F_COPYI,2,1
	DB FLG,F_EXIT,167
	DB FLG,F_COPYI,2,3
	DW	0000H

M4:		;話す　鈴子２
;	DB	'【%001】：・・・俺、鈴子さんに大事な話があるんだ！'
	DB	"%001:  I've got to talk to you about something important!"
	DB	NEXT
;	DB	'【%001】：だから、き、今日鈴子さんの家に行っていい？'
	DB	"%001:  So, can I go to your house tonight?"
	DB	NEXT
;	DB	'【鈴子】：ここじゃ出来ないような話なの？'
	DB	"Reiko:  We can't talk here?"
	DB	NEXT
;	DB	'【%001】：その・・・バレンタインの・・・'
	DB	"%001:  It's...you know....."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ....................."
	DB	NEXT
;	DB	'【鈴子】：・・・もう分ってるわ。早く亜希ちゃんのところに行ってあげて。'
	DB	"Reiko:  ...I already know your answer. Why don't you go to"
	DB	CR
	DB	"Aki now?"
	DB	NEXT
;	DB	'【%001】：お、俺は鈴子さんが・・・！'
	DB	"%001:  What? But I love you...!"
	DB	NEXT
	K_CG 'CT01','D',15,2
;	DB	'【鈴子】：%001君。クリスマスの夜、誰と一緒にいたの？'
	DB	"Reiko:  %001, who were you with on Christmas Eve?"
	DB	NEXT
;	DB	'【%001】：！！！'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【鈴子】：亜希ちゃんからみんな聞いたわ。'
	DB	"Reiko:  Aki told us everything."
	DB	NEXT
;	DB	'【%001】：・・・え、ええっ！？'
	DB	"%001:  ...She what?"
	DB	NEXT
	DB	FLG,F_JR
	DW	M_ENDE
	DW	0000H

M5:		;話す　鈴子３
;	DB	'【%001】：・・・俺、鈴子さんに大事な話があるんだ！'
	DB	"%001:  I've got to talk to you about something important!"
	DB	NEXT
;	DB	'【%001】：だから、き、今日鈴子さんの家に行っていい？'
	DB	"%001:  So, can I go to your house tonight?"
	DB	NEXT
;	DB	'【鈴子】：ここじゃ出来ないような話なの？'
	DB	"Reiko:  We can't talk here?"
	DB	NEXT
;	DB	'【%001】：その・・・バレンタインの・・・'
	DB	"%001:  It's.....you know....."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ........................."
	DB	NEXT
;	DB	'【鈴子】：分かってたわ・・・君の目には、あの子しか映ってないってことは。'
	DB	"Reiko:  I know what you're here to tell me. You love someone"
	DB	CR
	DB	"else."
	DB	NEXT
;	DB	'【%001】：え・・・！？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【鈴子】：あ～あ、フラレちゃったか。'
	DB	"Reiko:  Oh well... I can't win, can I?"
	DB	NEXT
;	DB	'【%001】：あの・・・鈴子さん？'
	DB	"%001:  What? "
	DB	NEXT
	DB	FLG,F_JR
	DW	M_ENDE
	DW	0000H

M_ENDE:
	K_CG 'CT01','K',15,3
;	DB	'【鈴子】：さよなら、%001君。素敵な思い出をありがとう。'
	DB	"Reiko:  Goodbye, %001. Thank you for the good memories"
	DB	CR
	DB	"this year."
	DB	NEXT
;	DB	'【%001】：れ、鈴子さん・・・！'
	DB	"%001:  R- Reiko!"
	DB	NEXT
;	DB	'鈴子さんはにっこり微笑んで、走っていってしまった。'
	DB	"Reiko smiled once, then ran away from where I was."
	DB	NEXT
	B_P1 B_TATE
;	DB	'【%001】：鈴子さ～ん！！'
	DB	"%001:  Reiko!"
	DB	NEXT
;	DB	'追いかけようとした俺は、後から肩を叩かれた。'
	DB	"I started to run after her, but a hand stopped me."
	DB	NEXT
	DB	BGM,28
	DB BUF,B_COPY01
	T_CG 'CT13','F','D',15,8
;	DB	'【校長】：%001君。別れがつらいのは分かるが、君が笑顔で見送らんでどうする。'
	DB	"Dean:  %001, it's hard letting someone you love, go."
	DB	CR
	DB	"But you've got to keep your dignity."
	DB	NEXT
;	DB	'【%001】：は、放せ校長！'
	DB	"%001:  Let go of me!"
	DB	NEXT
;	DB	'【校長】：%001君・・・青春とは、二度とひっくり返らない砂時計の砂なのだ。'
	DB	"Dean:  %001, youth is like an hourglass. You can"
	DB	CR
	DB	"never stop the sand from falling."
	DB	NEXT
;	DB	'【%001】：あ～もうわけわかんねーっ！'
	DB	"%001:  Let go of me! Reiko!"
	DB	NEXT
	B_O B_WIPE
;	DB	'・・・これも自分の優柔不断が招いた不幸か。'
	DB	"....It was my own fault for not making up my mind sooner."
	DB	NEXT
;	DB	'ショックで呆けてる内に、俺はヒーローアクション部に入部させられていた。'
	DB	"While still recovering from the shock of it all, I was"
	DB	CR
	DB	"forced into the Action Hero Show club."
	DB	NEXT
;	DB	'【校長】：%001君、決めのポーズはこうだ！'
	DB	"Dean:  %001, you're on!"
	DB	NEXT
;	DB	'【%001】：はいっ先生！'
	DB	"%001:  Yes, sir!"
	DB	NEXT
;	DB	'【校長】：先生ではない！司令と呼びたまえ！'
	DB	"Dean:  Don't call me sir! Call me Commander!"
	DB	NEXT
;	DB	'【%001】：はいっ司令！'
	DB	"%001:  Yes, Commander!"
	DB	NEXT
;	DB	'最近、この環境が快感になりつつある。学校のみんなも楽しんでくれるし、俺の才能をフルに生かせるんだ。'
	DB	"But I'm getting used to it. The students love my performances,"
	DB	CR
	DB	"and I'm using my talents to their fullest."
	DB	NEXT
;	DB	'・・・さて、新入生の勧誘だ・・・。'
	DB	"Let's see... It's time to greet the incoming freshmen"
	DB	CR
	DB	"students."
	DB	NEXT
	DB	GAMEOVER
	DW	0000H
end
