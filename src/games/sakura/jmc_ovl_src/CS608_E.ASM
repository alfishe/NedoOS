;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０８＿Ｅ
;		瑠璃とボート

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	-1
MSGTBL:
	DW	M1
COMTBL:
	DW	-1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群


;イニシャルメッセージ
M1:
	DB	BGM,2
	BAK_INIT 'AB_41'
	DB	BUF,B_COPY01
	T_CG 'CT05','M',0,10,1
;	DB	'【瑠璃】：%001君。'
	DB	"Ruri:  %001."
	DB	NEXT
;	DB	'【%001】：えっ・・・白水さん？'
	DB	"%001:  Eh....Ruri?"
	DB	NEXT
;	DB	'【清美】：いらっしゃったのですか？'
	DB	"Kiyomi:  You're here too?"
	DB	NEXT
;	DB	'【瑠璃】：これ・・・%001君のボートでしょう。'
	DB	"Ruri:  This is probably your boat, %001."
	DB	NEXT
;	DB	'白水さんは、俺達の乗って来たボートのロープを掴んでいた。'
	DB	"Ruri was holding the our boat's rope in her hand."
	DB	NEXT
;	DB	'【瑠璃】：波にさらわれてたから。'
	DB	"Ruri:  It was swept away by a wave."
	DB	NEXT
;	DB	'【%001】：サ、サンキュ、助かったよ！'
	DB	"%001:  Th- Thanks!"
	DB	NEXT
;	DB	'【瑠璃】：・・・じゃ。'
	DB	"Ruri:  ........Well, bye."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','M','I',40,2
;	DB	'白水さんはボートを置くとそのまま海に入っていって、泳いで行ってしまった。'
	DB	"Ruri gave me the rope. Then she walked straight into"
	DB	CR
	DB	"the sea and swam off."
	DB	NEXT
;	DB	'【%001】：あー、よかった。'
	DB	"%001:  What a relief."
	DB	NEXT
;	DB	'【%001】：それじゃ俺達も戻ろう、新藤さん。'
	DB	"%001:  Well, we should go back too, Kiyomi."
	DB	NEXT
;	DB	'【清美】：・・・そうですわね。'
	DB	"Kiyomi:  ...I suppose so."
	DB	NEXT
;	DB	'【%001】：・・・どした？元気ねーな。'
	DB	"%001:  What's up? Are you alright?"
	DB	NEXT
;	DB	'【清美】：何でもありません。少し疲れただけですわ。'
	DB	"Kiyomi:  It's nothing. I'm just a bit tired."
	DB	NEXT
;	DB	'【%001】：そか。'
	DB	"%001:  Oh."
	DB	NEXT
	B_O B_SUDA
;	DB	'俺達は浜に戻った。'
	DB	"We returned to the beach."
	DB	NEXT
	DB SINARIO,'CS609.OVL',0
	DW	0000H


end
