;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ｂ＿４
;		清美フィニッシュ

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'入れる',0
VV1:	DB	1,	'ENTER KIYOMI',0
;VV2:	DB	2,	'動く',0
VV2:	DB	2,	'MOVE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;入れる
S2:		DW	VV2, -1,  2, M3		;動く


;イニシャルメッセージ
M1:
	DB	BGM,13
	B_O B_SUDA
;	DB	'【清美】：・・・無理ですわ！そんなに大きなものが、わたくしの中に入るなんて・・・！'
	DB	"Kiyomi:  Wait, this is impossible. There's no way"
	DB	CR
	DB	"something that large is going to fit inside me!"
	DB	NEXT
;	DB	'【%001】：清美、大丈夫だよ・・・なるべく痛くないようにするから。'
	DB	"%001:  It's alright. I'll be careful not to hurt you."
	DB	NEXT
;	DB	'【清美】：駄目です！わたくし、きっと死んでしまいますわ！'
	DB	"Kiyomi:  No, it's impossible. I'll die!"
	DB	NEXT
;	DB	'【%001】：俺を信じて。俺、清美との約束破ったことないだろ？'
	DB	"%001:  Please, trust me. Have I ever broken a promise I"
	DB	CR
	DB	"made do you?"
	DB	NEXT
;	DB	'清美が答えるより先に、俺は唇を重ね、舌を侵入させる。'
	DB	"Before she can answer, I kiss her, entering her mouth"
	DB	CR
	DB	"with my tongue."
	DB	NEXT
;	DB	'【%001】：・・・な？'
	DB	"%001:  ..........Okay?"
	DB	NEXT
;	DB	'【清美】：・・・はい・・・'
	DB	"Kiyomi:  ...........Alright...."
	DB C_BLD,C_V_ON,2
	DW	0000H

M2:		;入れる
;	DB	'【%001】：じゃあ・・・行くよ、清美・・・'
	DB	"%001:  Okay, I'm coming in, Kiyomi."
	E_CG B_FADE,'AE_155'
	DB	NEXT
;	DB	'【清美】：・・・っ！'
	DB	"Kiyomi:  ...............!!"
	DB	NEXT
;	DB	'俺の物がずぶずぶと清美の中に埋まっていく。'
	DB	"My cock sank slowly into Kiyomi's folds."
	DB	NEXT
;	DB	'【%001】：・・・痛い？'
	DB	"%001:  ..........Does it hurt?"
	DB	NEXT
;	DB	'清美の苦悶の表情を見て思わず聞いてしまったが、愚問もいい所だ。'
	DB	"Kiyomi shook her head, but the expression on her face"
	DB	CR
	DB	"told me the truth."
	DB	NEXT
;	DB	'【清美】：・・・いいえ・・・平気・・・ですわ。'
	DB	"Kiyomi:  .....No....it's alright..."
	DB	NEXT
;	DB	'・・・口とは裏腹に、清美の目尻からはポロポロと雫が零れ落ちる。'
	DB	"Out of the corner of her eyes, then, I saw her tears."
	DB	NEXT
;	DB	'【%001】：清美・・・愛してる！'
	DB	"%001:  Kiyomi.....I love you!"
	DB	NEXT
;	DB	'【清美】：%001さん・・・あなたが、好きです・・・！'
	DB	"Kiyomi:  %001.....I love you, too....!"
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_V_ON,1
	DW	0000H

M3:		;動く
;	DB	'俺はゆっくりと時間をかけて、清美の中を行き来した。やがて、清美の声に悦びの色が混ざり始める。'
	DB	"Slowly, I increase my movements. Kiyomi's voice gets"
	DB	CR
	DB	"louder, desperate."
	DB	NEXT
;	DB	'【清美】：・・・あっ・・・わたくし・・・体がふわふわして・・・'
	DB	"Kiyomi:  .......What's happening?  I....feel so strange..."
	DB	NEXT
;	DB	'【%001】：清美・・・！'
	DB	"%001:  Kiyomi....!"
	DB	NEXT
;	DB	'【清美】：・・・あっ・・・ああっ・・・・・・'
	DB	"Kiyomi:  ...........Ahhh!............Ahhhhhh!."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・・んんっ・・・！'
	DB	"Kiyomi:  .......................................Mmmm...!!"
	DB	NEXT
;	DB	'【清美】：・・・・・・アアアアアアッ・・・！'
	DB	"Kiyomi:  ..........................Ahhhhh, %001!"
	DB	NEXT
;	DB	'【%001】：くぅっ・・・！'
	DB	"%001:  ..................I can't hold it.....!!"
	DB	NEXT
;	DB	'清美が大きくのけぞったと同時に、俺の頭の中も真っ白になった・・・'
	DB	"Kiyomi arched her back up towards me one final time, just"
	DB	CR
	DB	"as my vision went white."
	DB	NEXT
	DB	"Then I came, filling Kiyomi's pussy in a creamy rush."
	DB	NEXT
;	DB	'【%001】：清美・・・'
	DB	"%001:  Kiyomi..."
	DB	NEXT
;	DB	'【清美】：%001さん・・・今のが、イクという事なのですね・・・'
	DB	"Kiyomi:  %001, did I just...come?"
	DB	NEXT
;	DB	'【%001】：そうだよ・・・'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【清美】：・・・・・・%001さん・・・・・・'
	DB	"Kiyomi:  ........%001......"
	DB	NEXT
;	DB	'【清美】：・・・もう一度、していただけますか・・・？'"
	DB	"Kiyomi:  ....It was so...good..."
	DB	NEXT
;	DB	'俺は清美を抱きしめた。'
	DB	"I held Kiyomi to me."
	DB	NEXT
;	DB	'もっともっと清美を悦ばせたい・・・'
	DB	"I loved her more than I had thought possible."
	DB	NEXT
;	DB	'もっともっと清美を気持ちよくしてあげたい・・・'
	DB	"I loved her, and wanted to make her feel good, forever."
	DB	NEXT
;	DB	'人のために何かをすることの喜び。俺と清美は一晩中、お互いを慈しみ、愛しあった・・・'
	DB	"We lay like that a long time, finally sleeping, waking"
	DB	CR
	DB	"later to love each other some more...."
	DB	NEXT
	DB	BGM,33
	DB	ENDING,2
	DW	0000H


end
