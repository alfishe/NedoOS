;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０３＿Ｂ
;		山道　清美と会う

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
;NN2:	DB	2,	'清美',0
NN2:	DB	2,	'KIYOMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　森の中
S2:		DW	VV2, NN2,  2, M3, M4		;話す　清美


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
	DB	"I guess I'll have to go a little bit deeper into the forest."
	DB G_FLG,G_COPYI,159,1
	DB G_FLG,G_COPYF,120,120
	DB	FLG,F_CALI,120,10
	DB G_FLG,G_COPYG,120,120
	DB C_BLD,C_V_ON,2
	DW	0000H

M2:		;見る　森の中
	DB	BUF,B_COPY01
	T_CG 'CT02','T',0,35,1
;	DB	'【清美】：あら、%001さん？'
	DB	"Kiyomi:  Oh, %001."
	DB	NEXT
;	DB	'【%001】：新藤さん。'
	DB	"%001:  Ah, Kiyomi."
	DB	NEXT
;	DB	'両手一杯に枯れ枝を抱えた新藤さんが、ふらふら歩いていた。'
	DB	"Kiyomi appeared, holding firewood in her arms."
	DB	NEXT
;	DB	'【%001】：重そうだね・・・持つの手伝おうか？'
	DB	"%001:  That looks heavy. Want me to help you?"
	DB	NEXT
;	DB	'【清美】：助かりますわ。'
	DB	"Kiyomi:  Thank you very much."
	DB	NEXT
;	DB	'【清美】：でも、%001さんはテント係でしたわよね？'
	DB	"Kiyomi:  But aren't you supposed to be putting up the tents?"
	DB	NEXT
;	DB	'【%001】：ああ、もう張り終わったんだけど、「やることないなら薪でも拾って来い！」って言われてさ。'
	DB	"%001:  I finished early."
	DB	NEXT
;	DB	'【清美】：そうですか。'
	DB	"Kiyomi:  Oh."
	DB	NEXT
;	DB	'【清美】：それでは、半分持って下さいますか？'
	DB	"Kiyomi:  Would you mind carrying half of this for me?"
	DB	NEXT
;	DB	'【%001】：ああ、いいよ。'
	DB	"%001:  Sure, I don't mind."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_OFF,2
	DW	0000H

M3:		;話す　清美
;	DB	'【%001】：参ったよ。この辺、薪になりそうな枝落ちてねーんだもん。'
	DB	"%001:  It doesn't look like there's any good wood around"
	DB	CR
	DB	"here."
	DB	NEXT
;	DB	'【清美】：あらあら。もう少しお早めにおこしになればよかったのですわ。'
	DB	"Kiyomi:  The others must have found it already."
	DB	FLG,F_COPYI,2,1
	DW	0000H


M4:		;話す　清美
;	DB	'ゴロゴロゴロ・・・'
	DB	"*BOOM*"
	DB	NEXT
;	DB	'【清美】：この音・・・'
	DB	"Kiyomi:  Thunder..."
	DB	NEXT
;	DB	'急に風が強くなったかと思うと、今の今まで青かった空が真っ黒な雲に覆われた。'
	DB	"Suddenly the wind picked up, and the sky grew dark."
	DB	NEXT
	DB	ANI,A_OFF
	K_CG 'CT02','I',35,2
;	DB	'【清美】：これは一雨来ますわね。'
	DB	"Kiyomi:  It's going to rain."
	DB	NEXT
;	DB	'【%001】：山の天気は変わりやすいって言うしな。新藤さん、急いでキャンプに戻ろう！'
	DB	"%001:  The weather can change quickly up here in the"
	DB	CR
	DB	"mountains. Let's get back to camp."
	DB	NEXT
;	DB	'・・・と、言ったか言わないかのうちに叩きつけるような雨が降って来た。'
	DB	"But then it started to fall, first a little, then more."
	DB	NEXT
;	DB	'【清美】：困りましたわね・・・これではキャンプに戻る前に濡れ鼠になってしまいますわ。'
	DB	"Kiyomi:  This is bad. We'll be soaked before we can get"
	DB	CR
	DB	"back."
	DB	NEXT
;	DB	'【清美】：どこかに、この雨をしのげるような場所がありませんでしょうか？'
	DB	"Kiyomi:  Is there anywhere we can wait for the rain to stop?"
	DB	NEXT
;	DB	'【%001】：えっと・・・'
	DB	"%001:  Um, well..."
	DB	NEXT
;	DB	'【%001】：あそこに洞窟がある！'
	DB	"%001:  How about the cave over there?"
	DB	NEXT
;	DB	'【清美】：それでは、取り合えずあそこに逃げ込みましょう。'
	DB	"Kiyomi:  It's fine. Let's go quickly."
	DB	NEXT
;	DB	'俺達は手近な洞窟に駆け込んだ。'
	DB	"We ran into the cave."
	DB	NEXT
	B_O B_SUDA
	DB SINARIO,'CS504_B.OVL',0
	DW	0000H


end
