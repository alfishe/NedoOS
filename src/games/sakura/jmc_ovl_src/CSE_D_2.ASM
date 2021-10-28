;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　祥子２
;		

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
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0

;NN1:	DB	1,	'祥子',0
NN1:	DB	1,	'SHOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M6, M7		;見る　祥子３
S2:		DW	VV2, NN1,  2, M3, M4, M5		;話す　祥子３


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'するするっ'
	E_CG B_SUDA,'AE_172'
;	DB	'西野さんは手早く俺の服を脱がすと、自分も服を脱いだ。'
	DB	"Shoko quickly takes my clothes off, then her own."
	DB	NEXT
;	DB	'【祥子】：・・・さ、しゅ～君・・・'
	DB	"Shoko:  ......Are you ready?"
	DB	NEXT
;	DB	'【%001】：・・・う、うん。'
	DB	"%001:  S- Sure..."
	DW	0000H

M2:		;見る　祥子１
;	DB	'青いパンティ以外は全部脱いで、ほぼ完全に生まれたままの姿だ。'
	DB	"She's wearing nothing but her blue panties. Her soft, white"
	DB	CR
	DB	"skin is laid bare before me."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;話す　祥子１
;	DB	'【祥子】：・・・しゅ～君・・・触って？'
	DB	"Shoko:  Touch me, Shu-kun."
	DB	NEXT
;	DB	'西野さんが俺の手を取り、自分の胸へと導く。'
	DB	"Shoko takes my hand and puts it on her breast."
	DB	NEXT
;	DB	'【%001】：・・・あ・・・'
	DB	"%001:  .......Ah..."
	DB	NEXT
;	DB	'弾力に満ちた左の膨らみから、心臓の音が伝わってくる。'
	DB	"It's soft and warm. I can feel blood coursing through it."
	DB	NEXT
;	DB	'【祥子】：・・・ね？どっきんどっきんしてるでしょ？'
	DB	"Shoko:  Can you feel my heart beating? Dokkin, dokkin..."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　祥子２
;	DB	'【祥子】：あたし・・・こんなにどっきんどっきんしたの、初めて・・・'
	DB	"Shoko:  I...I've never felt this way before, %001..."
	DB	NEXT
;	DB	'【祥子】：だから、あげるの・・・・・・しゅ～君にだけ、あげるの。'
	DB	"Shoko:  So I want to give...myself...to you..."
	DB	NEXT
;	DB	'【%001】：・・・西野さん・・・'
	DB	"%001:  Shoko...."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　祥子３
;	DB	'【祥子】：・・・だから・・・こんな事だって出来るよ？'
	DB	"Shoko:  I want to make you happy!"
	DB	NEXT
;	DB	'【%001】：・・・えっ！？'
	DB	"%001:  What?!"
	DB	NEXT
	DB	SINARIO,'CSE_D_3.OVL',0
	DW	0000H

M6:		;見る　祥子２
;	DB	'前に見た時は慌ててたんで良く分からなかったが・・・'
;	DB	'西野さんの胸は、かなり大きい。'
	DB	"The last time I saw them I was nervous, so I didn't pay"
	DB	CR
	DB	"much attention, but Shoko's breasts are really great."
	DB	NEXT
;	DB	'鈴子さんや今日子先生に比べても、まったく遜色が無い。'
	DB	"They're bigger than Reiko's, or even Kyoko-sensei's..."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M7:		;見る　祥子３
;	DB	'肌はかなり白く、健康的な艶がある。'
	DB	"Her skin is a white, healthy color."
	DB	FLG,F_COPYI,101,1
	DW	0000H


end
