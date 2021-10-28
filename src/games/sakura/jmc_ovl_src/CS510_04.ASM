;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１０＿４
;		川　瑠璃の捜索（浅瀬Ｂ）
;イニシャルメッセージ

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	NN3,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'探す',0
VV2:	DB	2,	'LOOK FOR',0
;VV3:	DB	3,	'戻る',0
VV3:	DB	3,	'GO BACK',0

;NN1:	DB	1,	'周り',0
NN1:	DB	1,	'AROUND',0
;NN2:	DB	2,	'瑠璃',0
NN2:	DB	2,	'RURI',0
;NN3:	DB	3,	'釣り場Ａ',0
NN3:	DB	3,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2	;	見る　周り
S2:		DW	VV2, NN2,  2, M3	;	探す　瑠璃
S3:		DW	VV3, NN3,  3, M4	;	戻る　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,20
	B_O B_SUDA
	BAK_INIT 'AB_09_2'
	DB BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'俺達は浅瀬Ｂに来た。'
	DB	"We're at Shallows B."
	DB	NEXT
	TU_CG 'CT01','F','I',0,1
	T_CG 'CT02','F','I',30,2
	DB ANI,A_ON,1
;	DB	'【鈴子】：あ, %001君!'
	DB	"Reiko:  Oh, %001!"
	DB	NEXT
;	DB	"【誠】：・・・見つかりましたか？!ｼ"
	DB	"Makoto:  Did you find her?!"
	DB	NEXT
;	DB	"【清美】：いいえ・・・"
	DB	"Kiyomi:  No..."
	DB	NEXT
;	DB	"%001:  ・・・白水さん, どこに行ったんだ・・・"
	DB	"%001:  Where did she go...?"
	DB G_FLG,G_COPYI,103,1
	DW	0000H

M2:	;	見る　周り
;	DB	"%001:  ・・・まさか白水さん・・・川で溺れて流されたんじゃないだろうな？"
	DB	"%001:  My God.... Ruri couldn't have drowned in the"
	DB	CR
	DB	"river, could she?"
	DB	NEXT
;	DB	'【鈴子】：%001君じゃないんだから・・・'
	DB	"Reiko:  I'm sure she's fine."
	DW	0000H

M3:	;	探す　瑠璃
;	DB	'%001:  ここにもいない・・・・・・一体どこに行ったんだろう。'
	DB	"%001:  She's not here either... Where the heck did she go?"
	DW	0000H

M4:	;	戻る　釣り場Ａ
;	DB	'%001:  俺達, 他を探して来る!'
	DB	"%001:  We'll go look somewhere else!"
	DB	NEXT
;	DB	"【鈴子】：わかったわ!"
	DB	"Reiko:  Okay!"
	DB	NEXT
;	DB	"【清美】：%001さん達も, お気を付けて・・・"
	DB	"Kiyomi:  %001, please be careful, too..."
	DB	NEXT

	DB	"Makoto:  Thanks, we will!"
	DB	NEXT

	DB SINARIO,'CS510_01.OVL',0
	DW	0000H


end
