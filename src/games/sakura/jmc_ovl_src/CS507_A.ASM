;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０７＿Ａ
;		川　釣りでの冷やかし（鈴子）

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
;NN3:	DB	3,	'鈴子',0
NN3:	DB	3,	'REIKO',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M7, M8, M9, M10		;話す　鈴子
S4:		DW	VV3, NN4,  4, M11		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_1'
	DB	BUF,B_COPY01
	T_CG 'CT01','T',0,30,1
;	DB	'鈴子さんのいる浅瀬Ａだ。'
	DB	"I'm at the shallows where Reiko is."
	DB	NEXT
;	DB	'【鈴子】：あら、%001くん。'
	DB	"Reiko:  Oh, %001."
	DB G_FLG,G_COPYI,102,1
	DW	0000H

M2:		;見る　川
;	DB	'魚がたくさんいるきれいな川だ。'
	DB	"It's a river overflowing with fish."
	DB	PAUSE
;	DB	'・・・多分。'
	DB	"......I think."
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
	DB	"%001:  Tuna and swordfish?"
	DB	NEXT
;	DB	'【鈴子】：%001くん、そんなのが川にいる訳ないでしょ？'
	DB	"Reiko:  %001, there's no way fish like that would be in"
	DB	CR
	DB	"this river."
	DB	NEXT
;	DB	'【%001】：冗談だよ。'
	DB	"%001:  I was kidding."
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

M7:		;話す　鈴子
;	DB	'【%001】：釣れてる？'
	DB	"%001:  Did you catch anything?"
	DB	NEXT
;	DB	'【鈴子】：ぜ～んぜん。'
	DB	"Reiko:  Nothing."
	DB	NEXT
;	DB	'【%001】：・・・そうですか。'
	DB	"%001:  ...Oh."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;話す　鈴子
;	DB	'【%001】：鈴子さん、泳がないの？'
	DB	"%001:  Reiko, aren't you going to swim?"
	DB	NEXT
;	DB	'【鈴子】：・・・ちょっとシーズンには早いんじゃないかしら。'
	DB	"Reiko:  The season for swimming isn't here yet."
	DB	NEXT
;	DB	'【鈴子】：でもせっかくだから、泳ぎを教えてあげましょうか？'
	DB	"Reiko:  But as long as we're here, do you want me to teach"
	DB	CR
	DB	"you how to swim?"
	DB	NEXT
;	DB	'【%001】：・・・水が冷たいからパス。'
	DB	"%001:  I'll pass!"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M9:		;話す　鈴子
;	DB	'【鈴子】：%001君の方は？'
	DB	"Reiko:  What about you, %001. Did you catch anything?"
	DB	NEXT
;	DB	'【%001】：誠が頑張ってる。'
	DB	"%001:  Makoto is doing his best, but nothing so far."
	DB	NEXT
;	DB	'【鈴子】：あの子、サバイバルなんとかって同好会の会長でしょ？'
	DB	"Reiko:  Isn't he the president of the survival club?"
	DB	CR
	DB	"He should come in handy."
	DB	NEXT
;	DB	'【%001】：釣りは好きじゃないみたいだったな。'
	DB	"%001:  I don't think he likes fishing."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M10:		;話す　鈴子
;	DB	'【鈴子】：はぁ・・・晩ご飯にありつけるかしら・・・'
	DB	"Reiko:  I wonder if we're all going to go hungry tonight."
	DW	0000H

M11:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I head back to the fishing spot where Makoto is."
	DB	NEXT
	DB SINARIO,'CS507_1.OVL',0
	DW	0000H

end
