;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１０＿１１
;		川　瑠璃の捜索（キャンプに戻る）

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1

;VV1:	DB	1,	'探す',0
VV1:	DB	1,	"LOOK FOR",0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	"RURI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3			;探す　瑠璃


;イニシャルメッセージ
M1:
	DB	BGM,20
	B_O B_SUDA
	BAK_INIT 'AB_16_2'
	DB BUF,B_COPY01
	T_CG 'CT12','T','I',30,1
;	DB	'【%001】：先生！見つかった？！'
	DB	"%001:  Sensei, did you find her?"
	DB	NEXT
;	DB	'【今日子】：まだよ・・・みんなに探してもらってるけど, まだ見つからないのよ。'
	DB	"Kyoko:  Not yet... We're looking everywhere for her, but"
	DB	CR
	DB	"we can't find her!"
	DW	0000H

M2:		;探す　瑠璃
;	DB	'【%001】：戻ってないのか・・・'
	DB	"%001:  I guess she hasn't come back."
	DB	NEXT
;	DB	'【誠】：・・・一体どこ行ったんだ！？・・・'
	DB	"Makoto:  Where the heck did she go?!"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;探す　瑠璃
;	DB	'【%001】：・・・・・どうしたんだろう。'
	DB	"%001:  I wonder what happened?"
	DB	NEXT
	T_CG1 'CT14','F','D',0,3
;	DB	'【誠】：・・・・・まさか熊にでも襲われたとか・・・・・'
	DB	"Makoto:  What if she was attacked by a bear?"
	DB	NEXT
;	DB	'【%001】：・・・・・それとも川で溺れたとか・・・・・'
	DB	"%001:  Or if she drowned in the river?"
	DB	NEXT
;	DB	'【誠】：・・・・・ひょっとして崖から落っこちたとか・・・・・'
	DB	"Makoto:  Or maybe fell off a cliff?"
	DB	NEXT
;	DB	'【%001】：・・・・・誠！もう一度探しにいこう！！'
	DB	"%001:  .............!!"

	DB	NEXT

	DB	"%001:  Makoto! Let's go look one more time!"
	DB	NEXT
;	DB	'【誠】：おうよ！'
	DB	"Makoto:  All right!"
	DB	NEXT
	DB SINARIO,'CS510_01.OVL',0	
	DW	0000H

end
