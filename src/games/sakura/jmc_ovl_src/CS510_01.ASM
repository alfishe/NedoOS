;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１０＿１
;		川　瑠璃の捜索（釣り場Ａ）

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	NN3,NN4,NN5,NN6,NN7,NN8,NN9,NN10,NN11,-1
CM4:	DW	VV4,	NN12,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'探す',0
VV2:	DB	2,	'LOOK FOR',0
;VV3:	DB	3,	'行く',0
VV3:	DB	3,	'GO',0
;VV4:	DB	4,	'戻る',0
VV4:	DB	4,	'GO BACK',0

;NN1:	DB	1,	'周り',0
NN1:	DB	1,	'AROUND',0
;NN2:	DB	2,	'瑠璃',0
NN2:	DB	2,	'RURI',0
;NN3:	DB	3,	'釣り場Ｂ',0
NN3:	DB	3,	'FISHING SPOT B',0
;NN4:	DB	4,	'釣り場Ｃ',0
NN4:	DB	4,	'FISHING SPOT C',0
;NN5:	DB	5,	'岩場Ａ',0
NN5:	DB	5,	'ROCKY AREA A',0
;NN6:	DB	6,	'岩場Ｂ',0
NN6:	DB	6,	'ROCKY AREA B',0
;NN7:	DB	7,	'浅瀬Ａ',0
NN7:	DB	7,	'SHALLOWS A',0
;NN8:	DB	8,	'浅瀬Ｂ',0
NN8:	DB	8,	'SHALLOWS B',0
;NN9:	DB	9,	'浅瀬Ｃ',0
NN9:	DB	9,	'SHALLOWS C',0
;NN10:	DB	10,	'滝壷の近く',0
NN10:	DB	10,	'NEAR WATERFALL',0
;NN11:	DB	11,	'崖',0
NN11:	DB	11,	'CLIFF',0
;NN12:	DB	12,	'キャンプ場',0
NN12:	DB	12,	'CAMPGROUND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　周り
S2:		DW	VV2, NN2,  2, M4		;探す　瑠璃
S3:		DW	VV3, NN3,  3, M14		;行く　釣り場Ｂ
S4:		DW	VV3, NN4,  4, M15		;行く　釣り場Ｃ
S5:		DW	VV3, NN5,  5, M16		;行く　岩場Ａ
S6:		DW	VV3, NN6,  6, M17		;行く　岩場Ｂ
S7:		DW	VV3, NN7,  7, M18		;行く　浅瀬Ａ
S8:		DW	VV3, NN8,  8, M19		;行く　浅瀬Ｂ
S9:		DW	VV3, NN9,  9, M20		;行く　浅瀬Ｃ
S10:		DW	VV3, NN10,  10, M21		;行く　滝壷の近く
S11:		DW	VV3, NN11,  11, M22		;行く　崖
S12:		DW	VV4, NN12,  12, M23		;戻る　キャンプ場


;イニシャルメッセージ
M1:
	DB	BGM,20
	B_O B_SUDA
	BAK_INIT 'AB_09_4'
	DB BUF,B_COPY01
	T_CG 'CT14','F','D',0,1
;	DB	'【%001】：・・・白水さ～ん！'
	DB	"%001:  Ruri!!"
	DB	NEXT
;	DB	'【誠】：・・・白水さ～ん！'
	DB	"Makoto:  Ruri!!"
	DB	NEXT
;	DB	'%001:  ・・・・・・ここにはいないか。'
	DB	"%001:  She's not here!"
	DB G_FLG,G_COPYF,101,101
	DB G_FLG,G_COPYF,102,102
	DB G_FLG,G_COPYF,103,103
	DB G_FLG,G_COPYF,104,104
	DB G_FLG,G_COPYF,105,105
	DB G_FLG,G_COPYF,106,106
	DB G_FLG,G_COPYF,107,107
	DB G_FLG,G_COPYF,108,108
	DB G_FLG,G_COPYF,109,109
	DB	FLG,F_PLUS,101,102
	DB	FLG,F_PLUS,101,103
	DB	FLG,F_PLUS,101,104
	DB	FLG,F_PLUS,101,105
	DB	FLG,F_PLUS,101,106
	DB	FLG,F_PLUS,101,107
	DB	FLG,F_PLUS,101,108
	DB	FLG,F_PLUS,101,109
	DB	FLG,F_COMPI,255,101,4
	DB	FLG,F_JGR,255
	DW	REI
	DW	0000H

M2:	;	見る　周り
;	DB	'日が落ちて、すっかり暗くなっている。'
	DB	"The sun is going down, and it's getting pretty dark."
	DW	0000H

M3:	;	見る　周り
;	DB	'・・・白水さんはここにはいないようだ。'
	DB	"Ruri doesn't seem to be here."
	DW	0000H

M4:	;	探す　瑠璃
;	DB	'何処にもいない・・・・・・一体どこに行ったんだろう。'
	DB	"There's nobody here... I wonder where she went?"
	DW	0000H

M14:;	行く　釣り場Ｂ
	DB SINARIO,'CS510_05.OVL',0
	DW	0000H

M15:;	行く　釣り場Ｃ
	DB SINARIO,'CS510_10.OVL',0
	DW	0000H

M16:;	行く　岩場Ａ
	DB SINARIO,'CS510_02.OVL',0
	DW	0000H

M17:;	行く　岩場Ｂ
	DB SINARIO,'CS510_08.OVL',0
	DW	0000H

M18:;	行く　浅瀬Ａ
	DB SINARIO,'CS510_03.OVL',0
	DW	0000H

M19:;	行く　浅瀬Ｂ
	DB SINARIO,'CS510_04.OVL',0
	DW	0000H

M20:;	行く　浅瀬Ｃ
	DB SINARIO,'CS510_06.OVL',0
	DW	0000H

M21:;	行く　滝壷の近く
	DB SINARIO,'CS510_09.OVL',0
	DW	0000H

M22:;	行く　崖
	DB SINARIO,'CS510_07.OVL',0
	DW	0000H

M23:	;	戻る　キャンプ場
;	DB	'%001:  誠・・・一旦戻ってみるか。'
	DB	"%001:  Makoto...should we go back and take a look?"
	DB	NEXT
;	DB	'【誠】：・・・そうだな。けっこー、もう帰って来てるかもな。'
	DB	"Makoto:  Yeah...I guess so. She's probably come back by now."
	DB	NEXT
	DB SINARIO,'CS510_11.OVL',0
	DW	0000H

REI:
	DB	NEXT
;	DB	'%001:  誠・・・一旦戻ってみるか。'
	DB	'%001:  Makoto, should we go back to the camp?'
	DB	NEXT
;	DB	'【誠】：・・・そうだな。けっこー、もう帰って来てるかもな。'
	DB	"Makoto:  Yeah...I guess so. She's probably back by now."
	DB	NEXT
	DB SINARIO,'CS510_12.OVL',0
	DW	0000H

end