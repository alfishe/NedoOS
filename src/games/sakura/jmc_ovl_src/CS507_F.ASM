;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０７＿Ｆ
;		川　釣りでの冷やかし（亜希）

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
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'AKI',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M7, M8, M9, M10		;話す　亜希
S4:		DW	VV3, NN4,  4, M11		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_5'
	DB	BUF,B_COPY01
	T_CG 'CT06','M',0,30,1
;	DB	'亜希ちゃんのいる岩場Ｂだ。'
	DB	"I'm on the rock where Aki is."
	DB	NEXT
;	DB	'【亜希】：あ、%001先輩！'
	DB	"Aki:  Oh, hi, %001."
	DB G_FLG,G_COPYI,106,1
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
;	DB	'【%001】：・・・・・・タイとかヒラメとかいればなぁ・・・。'
	DB	"%001:  Flounder and red snapper?"
	DB	NEXT
;	DB	'【亜希】：%001先輩って、バカ？'
	DB 	"Aki:  %001, are you stupid or something?"
	DB	NEXT
;	DB	'【%001】：・・・・・・冗談なのに・・・。'
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

M7:		;話す　亜希
;	DB	'【%001】：・・・なんで水着なんか着てんの？'
	DB	"%001:  Why are you wearing a bathing suit?"
	DB	NEXT
;	DB	'【亜希】：せっかく川に来たんだし、泳ごうかなって思ったのよ。'
	DB	"Aki:  Well, I thought I'd go swimming, since we are here"
	DB	CR
	DB	"and all."
	DB	NEXT
;	DB	'【%001】：・・・水、冷たいんじゃないか？'
	DB	"%001:  Isn't the water cold?"
	DB	NEXT
;	DB	'【亜希】：・・・ちょっとね。'
	DB	"Aki:  A little."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;話す　亜希
;	DB	'【%001】：・・・あそこの岩に干してあるのは亜希ちゃんの体操着？'
	DB	"%001:  Is that your P.E. uniform hanging up over there?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・。'
	DB	"Aki:  ......................."
	DB	NEXT
;	DB	'【%001】：コケで滑ってびしょ濡れになったから、やむなく水着を着てるのか、ひょっとして。'
	DB	"%001:  I'll bet you really slipped on some moss, fell"
	DB	CR
	DB	"into the river, and put on your bathing suit so no one"
	DB	CR
	DB	"would know, right?"
	DB	NEXT
	DB	ANI,A_OFF
	K_CG 'CT06','D',30,2
;	DB	'【亜希】：それ以上言うと川に突き落とすわよ。'
	DB	"Aki:  If you say anything about it I'll throw you into the"
	DB	CR
	DB	"river."
	DB	NEXT
;	DB	'【%001】：・・・ボクが悪かったです。'
	DB	"%001:  .....Sorry."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M9:		;話す　亜希
;	DB	'【亜希】：いいのよ、持って来た水着が役に立ったから！'
	DB	"Aki:  It's okay! I'm just glad I was able to use the"
	DB	CR
	DB	"bathing suit I brought with me!"
	DB	FLG,F_COPYI,3,3
	DW	0000H

M10:		;話す　亜希
;	DB	'【亜希】：釣りなんかかったるくてやってらんないわ！'
	DB	"Aki:  I'm so sick of this!"
	DB	NEXT
;	DB	'そういう亜希ちゃんの足元には二つに折れた竿の残骸が転がっていた。'
	DB	"I looked at her feet and saw her fishing pole, broken in"
	DB	CR
	DB	"two."
	DW	0000H

M11:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I head back to the fishing spot where Makoto is."
	DB	NEXT
	DB SINARIO,'CS507_1.OVL',0
	DW	0000H

end
