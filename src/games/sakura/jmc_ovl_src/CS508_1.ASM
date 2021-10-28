;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０８＿１
;		川　瑠璃を捜す

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN5,-1
CM2:	DW	VV2,	NN4,-1
CM3:	DW	VV3,	NN6,NN7,NN8,NN9,NN10,NN11,NN12,NN13,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'聞く',0
VV2:	DB	2,	'ASK',0  
;VV3:	DB	3,	'行く',0
VV3:	DB	3,	'GO',0

;NN1:	DB	1,	'川',0
NN1:	DB	1,	'RIVER',0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	'SKY',0
;NN3:	DB	3,	'周り',0
NN3:	DB	3,	'AROUND',0
;NN4:	DB	4,	'瑠璃',0
NN4:	DB	4,	'RURI',0
;NN5:	DB	5,	'釣り場Ａ',0
NN5:	DB	5,	'FISHING SPOT A',0
;NN6:	DB	6,	'釣り場Ｂ',0
NN6:	DB	6,	'FISHING SPOT B',0
;NN7:	DB	7,	'釣り場Ｃ',0
NN7:	DB	7,	'FISHING SPOT C',0
;NN8:	DB	8,	'岩場Ａ',0
NN8:	DB	8,	'ROCK A',0
;NN9:	DB	9,	'岩場Ｂ',0
NN9:	DB	9,	'ROCK B',0
;NN10:	DB	10,	'浅瀬Ａ',0
NN10:	DB	10,	'SHALLOWS A',0
;NN11:	DB	11,	'浅瀬Ｂ',0
NN11:	DB	11,	'SHALLOWS B',0
;NN12:	DB	12,	'浅瀬Ｃ',0
NN12:	DB	12,	'SHALLOWS C',0
;NN13:	DB	13,	'滝壷の近く',0
NN13:	DB	13,	'WATERFALL',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4			;見る　川
S2:		DW	VV1, NN2,  2, M5				;見る　空
S3:		DW	VV1, NN3,  3, M7, M8, M9, M10, M11, M11B	;見る　周り
S4:		DW	VV2, NN4,  4, M12, M12B		;話す　誠
S5:		DW	VV1, NN5,  5, M13		;見る　釣り場
S6:		DW	VV3, NN6,  6, M14		;行く　釣り場Ｂ
S7:		DW	VV3, NN7,  7, M15		;行く　釣り場Ｃ
S8:		DW	VV3, NN8,  8, M16		;行く　岩場Ａ
S9:		DW	VV3, NN9,  9, M17		;行く　岩場Ｂ
S10:	DW	VV3, NN10,  10, M18		;行く　浅瀬Ａ
S11:	DW	VV3, NN11,  11, M19		;行く　浅瀬Ｂ
S12:	DW	VV3, NN12,  12, M20		;行く　浅瀬Ｃ
S13:	DW	VV3, NN13,  13, M21		;行く　滝壷の近く


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_3'
	DB	BUF,B_COPY01
	T_CG 'CT14','T',0,25,1
;	DB	'誠のいる釣り場Ａだ。'
	DB	"I'm at the fishing spot where Makoto is."
	DB	NEXT
	DB G_FLG,G_COPYF,101,101
	DB G_FLG,G_COPYF,102,102
	DB G_FLG,G_COPYF,103,103
	DB	FLG,F_MOR,3,101,102,103
	DB	FLG,F_JGR,101
	DW	REI
;	DB	'・・・白水さん、どこにいるんだろ？'
	DB	"I wonder where Ruri went?"
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
;	DB	'できればあまり近づきたくないな。'
	DB	"I don't want to get too close to it."
	DB	NEXT
;	DB	'なぜって・・・・・・泳げねーから。'
	DB	"The reason for that is....I can't swim."
	DW	0000H

M5:		;見る　空
;	DB	'天気もいいし、見渡すかぎり青い空だ。'
	DB	"The weather's fine, and the sky is blue."
	DW	0000H


M7:		;見る　周り
;	DB	'楽しく釣りをしている生徒、ぐっすりと寝ている生徒、無邪気に走り回っている生徒、みんなめいめい楽しんでいる。'
	DB	"I see some students enjoying a day of fishing, other"
	DB	CR
	DB	"students sleeping, and still others just horsing around."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;見る　周り
;	DB	'先生と亜紀ちゃんが上流の岩場の方にいる。'
	DB	"Sensei and Aki are sitting on a rock upstream."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M9:		;見る　周り
;	DB	'鈴子さんと新藤さんと西野さんが浅瀬の方にいるのが見える。'
	DB	"Reiko, Kiyomi and Shoko are in the shallow part of the river."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M10:	;見る　周り
;	DB	'釣り場にいるのは美緒ちゃんと中野と誠。'
	DB	"In the fishing area are Mio, Meimi and Makoto."
	DB	FLG,F_COPYI,3,4
	DW	0000H

M11:	;見る　周り
;	DB	'滝壺の近くに吉田がいるな。'
	DB	"Seia is near the waterfall basin."
	DB	FLG,F_COPYI,3,5
	DW	0000H

M11B:	;見る　周り
;	DB	'白水さんはいない・・・・・・'
	DB	"Everyone's here except Ruri..."
	DB	FLG,F_COPYI,3,0
	DW	0000H

M12:	;話す　誠
;	DB	'【%001】：なあ、誠。'
	DB	"%001:  Hey, Makoto."
	DB	NEXT
;	DB	'【誠】：ん～？'
	DB	"Makoto:  Mm?"
	DB	NEXT
;	DB	'【%001】：白水さん見なかった？'
	DB	"%001:  Did you see Ruri today?"
	DB	NEXT
;	DB	'【誠】：さあ。白水さんがどうかしたのか？'
	DB	"Makoto:  Nope. Are you worried about her?"
	DB	NEXT
;	DB	'【%001】：いや・・・知らないならいいんだ。'
	DB	"%001:  Not really. I just wondered where she was."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M12B:	;話す　誠
;	DB	'【誠】：お前、もしかして・・・'
	DB	"Makoto:  Hey, you and her aren't..."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【誠】：・・・・・・いや、ンなことあるわけねーか。'
	DB	"Makoto:  .....Nevermind. It's it couldn't be."
	DB	NEXT
;	DB	'【%001】：何なんだ一体？'
	DB	"%001:  What the hell are you talking about?"
	DB	NEXT
;	DB	'【誠】：いや、こっちの話。'
	DB	"Makoto:  Nevermind."
	DW	0000H




M13:	;見る　釣り場
;	DB	'誠は浮きを眺めながら、サバイバルナイフを砥いでる。'
	DB	"Makoto is here at the water, sharpening his survival"
	DB	CR
	DB	"knife."
	DW	0000H


M14:	;行く　釣り場Ｂ
	DB SINARIO,'CS508_C.OVL',0
	DW	0000H

M15:	;行く　釣り場Ｃ
	DB SINARIO,'CS508_H.OVL',0
	DW	0000H

M16:	;行く　岩場Ａ
	DB SINARIO,'CS508_2.OVL',0
	DW	0000H

M17:	;行く　岩場Ｂ
	DB SINARIO,'CS508_F.OVL',0
	DW	0000H

M18:	;行く　浅瀬Ａ
	DB SINARIO,'CS508_A.OVL',0
	DW	0000H

M19:	;行く　浅瀬Ｂ
	DB SINARIO,'CS508_B.OVL',0
	DW	0000H

M20:	;行く　浅瀬Ｃ
	DB SINARIO,'CS508_D.OVL',0
	DW	0000H

M21:	;行く　滝壷の近く
	DB SINARIO,'CS508_G.OVL',0
	DW	0000H

REI:
;	DB	'（とにかく、白水さんは上流の方にいるらしいな。）'
	DB	"I guess she must be upstream. I'll try there."
	DB	NEXT
;	DB	'俺は川伝いにどんどん歩いていった。'
	DB	"I walk along the river to find Ruri."
	DB	NEXT
	DB SINARIO,'CS508_E.OVL',0
	DW	0000H

end
