;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１０＿１０
;		川　瑠璃の捜索（釣り場Ｃ）

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
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'探す',0
VV2:	DB	2,	"LOOK FOR",0
;VV3:	DB	3,	'戻る',0
VV3:	DB	3,	"GO BACK",0

;NN1:	DB	1,	'周り',0
NN1:	DB	1,	"AROUND",0
;NN2:	DB	2,	'瑠璃',0
NN2:	DB	2,	"RURI",0
;NN3:	DB	3,	'釣り場Ａ',0
NN3:	DB	3,	"FISHING SPOT A",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2	;	見る　周り
S2:		DW	VV2, NN2,  2, M3	;	探す　瑠璃
S3:		DW	VV3, NN3,  3, M4	;	戻る　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,20
	B_O B_SUDA
	BAK_INIT 'AB_09_4'
	DB BUF,B_COPY01
	T_CG 'CT14','F','D',20,1
;	DB	'俺達は釣り場Ｃに来た。'
	DB	"We got to Fishing Spot C."
	DB	NEXT
;	DB	'【%001】：・・・白水さ～ん!'
	DB	"%001:  Ruri!!"
	DB	NEXT
;	DB	'【誠】：・・・白水さ～ん!'
	DB	"Makoto:  Ruri!!"
	DB	NEXT
;	DB	'【%001】：・・・・・・ここじゃないのか？'
	DB	"%001:  She's not here, either?"
	DB G_FLG,G_COPYI,109,1
	DW	0000H

M2:	;	見る　周り
;	DB	'【%001】：・・・まさか白水さん・・・川で溺れて流されたんじゃないだろうな？'
	DB	"%001:  My God... Ruri couldn't have drowned in the"
	DB	CR
	DB	"river, could she?"
	DB	NEXT
;	DB	'【誠】：まさか, お前じゃあるまいし。'
	DB	"Makoto:  I'm sure she's alright."
	DW	0000H

M3:	;	探す　瑠璃
;	DB	'【%001】：ここにもいない・・・・・・一体どこに行ったんだろう。'
	DB	"%001:  She's not here either... Where the heck did she go?"
	DW	0000H

M4:	;	戻る　釣り場Ａ
;	DB	'【誠】：%001, ここにはいねーと思うぞ!'
	DB	"Makoto:  %001, I really don't think she's here!"
	DB	NEXT
;	DB	'【%001】：他を捜そう!'
	DB	"%001:  Let's look somewhere else!"
	DB	NEXT
	DB SINARIO,'CS510_01.OVL',0
	DW	0000H


end
