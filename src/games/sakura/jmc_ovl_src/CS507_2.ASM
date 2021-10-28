;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０７＿２
;		川　釣りでの冷やかし（今日子）

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
;NN3:	DB	3,	'今日子',0
NN3:	DB	3,	'KYOKO',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M7, M8, M9		;話す　今日子
S4:		DW	VV3, NN4,  4, M10		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_5'
	DB	BUF,B_COPY01
	T_CG 'CT12','T',0,30,1
;	DB	'今日子先生のいる岩場Ｂだ。'
	DB	"This is the rock where Kyoko-sensei is."
	DB	NEXT
;	DB	'【今日子】：あら、%001くん。'
	DB	"Kyoko:  Ah, %001."
	DB G_FLG,G_COPYI,101,1
	DW	0000H

M2:		;見る　川
;	DB	'【%001】：魚がたくさんいるきれいな川だ。'
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
;	DB	'【%001】：・・・・・鯛とか伊勢エビとかいればなぁ・・・。'
	DB	"%001:  Maybe some snapper and shrimp?"
	DB	NEXT
;	DB	'【今日子】：%001くん、そんなのが川にいる訳ないでしょ？'
	DB	"Kyoko:  %001, there's no way they'd be in a river!"
	DB	NEXT
;	DB	'【今日子】：ひょっとして、あたしに内緒でお酒を飲んだんじゃないでしょうね。'
	DB	"Kyoko:  You haven't been drinking behind my back or"
	DB	CR
	DB	"anything, have you?"
	DB	NEXT
;	DB	'【%001】：い、いや・・・ただの冗談です。'
	DB	"%001:  No, it was just a joke."
	DB	NEXT
;	DB	'【今日子】：ほんとに～～～～！？'
	DB	"Kyoko:  Really?"
	DB	NEXT
;	DB	'【%001】：ほ、本当ですって。',CR,'（もう、先生のお酒につきあうのはごめんだぞ）'
	DB	"%001:  Yes."
	DB	NEXT
	DB	"Everything comes down to drinking with Kyoko-sensei."
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

M7:		;話す　今日子
;	DB	'【%001】：・・・ど～です、釣れますか？'
	DB	"%001:  So, have you caught anything yet?"
	DB	NEXT
;	DB	'【今日子】：それがね～、さっぱりなのよ～。'
	DB	"Kyoko:  No, nothing so far."
	DB	NEXT
;	DB	'【%001】：・・・そうですか。'
	DB	"%001:  I see."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;話す　今日子
;	DB	'【%001】：・・・先生の場合、魚よりも他に釣らなきゃならないものがあるんじゃ・・・'
	DB	"%001:  There's something you need to be fishing for other"
	DB	CR
	DB	"than fish."
	DB	NEXT
	K_CG 'CT12','D',30,2
;	DB	'【今日子】：・・・主語を入れてもう一度言ってくれる？'
	DB	"Kyoko:  Want to say that again, buster?"
	DB	NEXT
;	DB	'【%001】：・・・いい天気ですね。'
	DB	"%001:  .........What a lovely day it is today."
	DB	NEXT
;	DB	'【今日子】：ごまかすんじゃな～い！'
	DB	"Kyoko:  Don't change the subject!"
	T_CG1 'CT12','T',0,30,1
	DB	FLG,F_COPYI,3,2
	DW	0000H

M9:		;話す　今日子
;	DB	'【今日子】：邪魔だから行った行った！'
	DB	"Kyoko:  You're bugging me. Go back with the others."
	DB	NEXT
;	DB	'【%001】：・・・先生、お酒はほどほどにして下さいね。'
	DB	"%001:  Be sure to warm up the sake for us tonight, okay?"
	DB	NEXT
;	DB	'【今日子】：ぎくっ。'
	DB	"Kyoko:  Oh, you"
	DW	0000H

M10:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I head back to the fishing spot where Makoto is."
	DB	NEXT
	DB SINARIO,'CS507_1.OVL',0
	DW	0000H


end
