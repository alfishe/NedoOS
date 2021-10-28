;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０３＿Ｅ
;		山道　瑠璃と会う

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
CM2:	DW	VV2,	NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'森の中',0
NN1:	DB	1,	'FOREST',0
;NN2:	DB	2,	'瑠璃',0
NN2:	DB	2,	'RURI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　森の中
S2:		DW	VV2, NN2,  2, M3, M4		;話す　瑠璃


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_08_1'
	B_P1 B_SUDA
;	DB	'【%001】：薪拾いっつっても、手頃な枝はみんな拾われた後だしな・・・'
	DB	"The hard part of gathering firewood is after you find it."
	DB	NEXT
;	DB	'【%001】：そこに落ちてる丸太拾って帰っても仕方ねえか。'
	DB	"You have to carry it all back to camp."
	DB	NEXT
;	DB	'【%001】：もっと森の奥に入らないとダメか？'
	DB	"I guess I'll have to go a little bit deeper into the"
	DB	CR
	DB	"forest."
	DB G_FLG,G_COPYF,150,150
	DB	FLG,F_CALI,150,10
	DB G_FLG,G_COPYG,150,150
	DB C_BLD,C_V_ON,2
	DW	0000H

M2:		;見る　森の中
;	DB	'【%001】：あれ・・・白水さん？'
	DB	"%001:  Is that Ruri? Yes, it is."
	DB	NEXT
;	DB	'【%001】：白水さ～ん！'
	DB	"%001:  Hi, Ruri!"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT05','T',0,10,1
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  .........................."
	DB	NEXT
;	DB	'俺は、両手一杯に枯れ枝を抱えた白水さんに追い付いた。'
	DB	"I chased after Ruri, holding a bundle of firewood in her"
	DB	CR
	DB	"arms."
	DB	NEXT
;	DB	'【瑠璃】：・・・なに？'
	DB	"Ruri:  ....What?"
	DB	NEXT
;	DB	'【%001】：ああ、「やることないなら薪でも拾って来い！」って言われてさ。'
	DB	"%001:  I was told to go get some firewood, so I came out"
	DB	CR
	DB	"here."
	DB	NEXT
;	DB	'【%001】：人使い荒いんだあいつら、ハハ・・・。'
	DB	"%001:  The girls back at camp can be pretty rough, the way"
	DB	CR
	DB	"they order me around."
	DB	NEXT
;	DB	'【瑠璃】：・・・嫌ならやめれば。'
	DB	"Ruri:  If you don't want to gather firewood, why are you"
	DB	CR
	DB	"here?"
	DB	NEXT
;	DB	'【%001】：いや、別に、イヤってわけじゃねーんだ。'
	DB	"%001:  Oh, I don't mind, it's just, well, you know."
	DB	NEXT
;	DB	'【%001】：やることなくなってヒマだったから、ちょうど良かったし。'
	DB	"%001:  I finished putting up the tents, so I had nothing"
	DB	CR
	DB	"to do anyway."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .........................."
	DB	NEXT
;	DB	'【%001】：白水さん、それ、重くない？何だったら半分持つけど。'
	DB	"%001:  Ruri, isn't that heavy? Shall I carry some for"
	DB	CR
	DB	"you?"
	DB	NEXT
;	DB	'【瑠璃】：・・・いい。'
	DB	"Ruri:  .....I'm okay."
	DB	NEXT
;	DB	'【%001】：・・・そう。'
	DB	"%001:  ....Oh."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_OFF,2
	DW	0000H

M3:		;話す　瑠璃
;	DB	'【%001】：参ったよ。この辺、薪になりそうな枝、落ちてねえんだもん。'
	DB	"%001:  It doesn't look like there's any more firewood"
	DB	CR
	DB	"around here"
	DB	NEXT
;	DB	'【瑠璃】：・・・そう。'
	DB	"Ruri:  ...You're right."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .................................."
	DB	NEXT
;	DB	'・・・相変らず、やりにくい・・・'
	DB	"She never makes it easy."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　瑠璃
;	DB	'【%001】：そう言えば、この前は・・・'
	DB	"%001:  About the other day at the river..."
	DB	NEXT
;	DB	'【瑠璃】：雨・・・'
	DB	"Ruri:  Rain..."
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'ゴロゴロゴロ・・・'
	DB	"*BOOM*"
	DB	NEXT
;	DB	'急に風が強くなったかと思うと、今の今まで青かった空が真っ黒な雲に覆われた。'
	DB	"Suddenly the wind picked up, and the sky grew dark."
	DB	NEXT
;	DB	'【%001】：ホントだ・・・こりゃ、一雨降るな。'
	DB	"%001:  You're right. We'd better hurry back."
	DB	NEXT
;	DB	'・・・と、言ったか言わないかのうちに叩きつけるような雨が降って来た。'
	DB	"The moment I spoke, it started:  first in little droplets,"
	DB	CR
	DB	"then more."
	DB	NEXT
;	DB	'【%001】：どっか雨宿り出来る場所はねーか・・・？'
	DB	"%001:  Is there anywhere we can wait out the rain?"
	DB	NEXT
;	DB	'【%001】：よし！あそこの洞窟にしよう！'
	DB	"%001:  Hey, what about that cave?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .................................."
	DB	NEXT
;	DB	'【%001】：ほら、ボーッとしてねーで、行こう！'
	DB	"%001:  Come on, let's go!"
	DB	NEXT
;	DB	'【瑠璃】：・・・あっ・・・'
	DB	"Ruri:  Okay."
	DB	NEXT
;	DB	'俺は白水さんの手を引っ張って手近な洞窟に駆け込んだ。'
	DB	"Pulling Ruri along with me, I ran for the cave."
	DB	NEXT
	B_O B_SUDA
	DB SINARIO,'CS504_E.OVL',0
	DW	0000H


end
