;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０７＿Ｇ
;		川　釣りでの冷やかし（星愛）

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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN3,-1
CM3:	DW	VV3,	NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'戻る',0
VV3:	DB	3,	'GO BACK',0

;NN1:	DB	1,	'川',0
NN1:	DB	1,	'RIVER',0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	'SKY',0
;NN3:	DB	3,	'星愛',0
NN3:	DB	3,	'SEIA',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M7, M8, M9, M10		;話す　星愛
S4:		DW	VV3, NN4,  4, M11		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_5'
	DB	BUF,B_COPY01
	T_CG 'CT07','T',0,25,1
;	DB	'吉田のいる滝のそばだ。'
	DB	"I'm near the waterfall where Seia is."
	DB	NEXT
;	DB	'【星愛】：まあ、%001君。'
	DB	"Seia:  Oh, %001."
	DB G_FLG,G_COPYI,107,1
	DW	0000H

M2:		;見る　川
;	DB	'【%001】：魚がたくさんいるきれいな川だ。'
	DB	"It's a river overflowing with fish."
	DB	PAUSE
;	DB	'・・・多分。'
	DB	"....I think."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　川
;	DB	'昨日の雨で増水してるみたいだ。'
	DB	"The rain yesterday has filled the river up with water."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　川
;	DB	'【%001】：どれどれ、どんな魚がいるのかな・・・・・おっ、よく見るとイワメやニジマスがいるな。'
	DB	"%001:  I wonder what kind of fish are in this river?"
	DB	NEXT
;	DB	'【%001】：・・・・・・マグロとかカジキとかいればなぁ・・・。'
	DB	"%001:  Tuna and baracuda?"
	DB	NEXT
;	DB	'【星愛】：主よ、この哀れな仔羊をお救いください。'
	DB	"Seia:  Lord, please teach this silly man about fish..."
	DB	NEXT
;	DB	'【%001】：・・・冗談だってば。'
	DB	"%001:  I was only kidding."
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;見る　川
;	DB	'できればあまり近づきたくないな。'
	DB	"I don't want to get too close to it."
	DB	NEXT
;	DB	'なぜって・・・・・・泳げねーから。'
	DB	"The reason for that is...I can't swim."
	DW	0000H

M6:		;見る　空
;	DB	'天気もいいし、見渡すかぎり青い空だ。'
	DB	"The weather's fine, and the sky is blue."
	DW	0000H

M7:		;話す　星愛
;	DB	'【%001】：釣れてる？'
	DB	"%001:  Are you catching anything?"
	DB	NEXT
;	DB	'【星愛】：まあ、わたくしが釣りをしているように見えますの？'
	DB	"Seia:  %001, does it look like I'm fishing?"
	DB	NEXT
;	DB	'【%001】：・・・晩ご飯は自給自足だぞ。'
	DB	"%001:  We have to catch our dinner tonight, you know."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;話す　星愛
;	DB	'【%001】：で、吉田は釣りもしないで何してんだ？'
	DB	"%001:  So, if you weren't fishing, what were you doing"
	DB	CR
	DB	"this whole time?"
	DB	NEXT
;	DB	'【%001】：ぼーっと滝を見てるようだけど・・・'
	DB	"%001:  Just staring at the waterfall?"
	DB	NEXT
;	DB	'【星愛】：はい。滝の向こうにマリア様のお姿を垣間見たような気がしまして・・・'
	DB	"Seia:  Yes. I thought I saw the Virgin Mary on the other"
	DB	CR
	DB	"side of the water."
	DB	NEXT
;	DB	'【%001】：・・・大丈夫か、吉田。'
	DB	"%001:  ................."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M9:		;話す　星愛
;	DB	'【星愛】：%001君の方はいかがですか？'
	DB	"Seia:  How about you? Did you catch anything?"
	DB	NEXT
;	DB	'【%001】：ああ、誠が頑張ってる。全然釣れてねーけど。'
	DB	"%001:  Makoto is doing his best. Nothing so far, though."
	DB	NEXT
;	DB	'【星愛】：全ては主の御心次第ですわ。'
	DB	"Seia:  It's all in the Lord's hands."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M10:		;話す　星愛
;	DB	'【星愛】：主よ・・・わたくしどもに今日の糧をお与えください。'
	DB	"Seia:  Lord, please give us our daily bread today."
	DW	0000H

M11:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I go back to where Makoto is."
	DB	NEXT
	DB SINARIO,'CS507_1.OVL',0
	DW	0000H

end
