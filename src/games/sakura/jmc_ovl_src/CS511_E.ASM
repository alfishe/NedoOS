;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１１＿Ｅ
;		林間学校　妖精が見守る朝

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
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	"RURI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　瑠璃１
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7		;話す　瑠璃５


;イニシャルメッセージ
M1:
	DB	BGM,21
	B_O B_FADE
	BAK_INIT 'AB_16_1'
	DB BUF,B_COPY01
;	DB	'【%001】：・・・・・・・・・ぐ～・・・・・・・・・'
	DB	"%001:  .....Zzzzzzzzzz...."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・ぴ～・・・・・・・・・'
	DB	"%001:  *SNORE*"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・か～・・・・・・・・・'
	DB	"%001:  Unhnh......"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ....."
	DB	PAUSE
;	DB	'ふぁ～～～～～～あ、良く寝た。'
	DB	"*YAWN*  I slept really well."
	DB	NEXT
;	DB	'ごそごそ'
;	DB	"Rustle"
;	DB	NEXT
	B_P1 B_SUDA
;	DB	'【%001】：・・・ん～～～～～～っ・・・今日もいい天気だ。'
	DB	"%001:  Great weather again today."
	DB	NEXT
	T_CG 'CT05','T',0,40,1
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DB	PAUSE
;	DB	'わっ！白水さん！？'
	DB	'Ruri.'
	DW	0000H

M2:		;見る　瑠璃１
;	DB	'包帯とかしてないところを見ると、ど～やら大した傷ではなかったらしい。'
	DB	"I see she's not wearing any bandages or anything, so it seems ",CR,"that she wasn't hurt very badly."
	DB	NEXT
;	DB	'（・・・ま、大事が無くて何よりだ。）'
	DB	"Well, what's most important it that it wasn't serious."
	DW	0000H

M3:		;話す　瑠璃１
;	DB	'【%001】：・・・お、おはよ。'
	DB	"%001:  Uh, hi."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・もう昼よ。'
	DB	"Ruri:  ......It's noon."
	DB	NEXT
;	DB	'【%001】：・・・そ、そうなの？'
	DB	"%001:  Uh, really?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  .........."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　瑠璃２
;	DB	'【%001】：・・・それで、傷の方は大丈夫なのか？'
	DB	"%001:  So, I guess you're feeling better?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・ええ。大した事ないわ。'
	DB	"Ruri:  .....Yeah. I'll be fine."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  That's good."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　瑠璃３
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................................"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................................"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................................"
	DB	NEXT
;	DB	'（・・・うーん、話題が無い・・・）'
	DB	"(Somebody say something!)"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・どうして。'
	DB	"Ruri:  .......Why?"
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・どうして、助けたの？'
	DB	"Ruri:  ............Why did you save me?"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;話す　瑠璃４
;	DB	'【%001】：・・・白水さんを助けた理由か？'
	DB	"%001:  You want to know why I saved you?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................................"
	DB	NEXT
;	DB	'【%001】：・・・別に、助けちゃいけない理由・・・無いだろ？'
	DB	"%001:  Well, there was no reason not to save you, right?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................................"
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;話す　瑠璃５
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................................"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................................"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................................"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・%001君、先生が呼んでるわ。'
	DB	"Ruri:  ....%001, Kyoko-sensei wants to see you."
	DB	NEXT
;	DB	'【%001】：・・・あ・・・'
	DB	"%001:  Oh, okay."
	DB	NEXT
;	DB	'【%001】：・・・・・・何だったんだ、一体？'
;	DB	"%001:  .....What the heck was that about?"
;	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
;	DB	"%001:  ......................................"
;	DB	NEXT
;	DB	'【%001】：ま、い～や。'
;	DB	"%001:  Whatever."
;	DB	NEXT
;	DB	'俺は先生を探しに行く事にした。'
	DB	"I started looking for Kyoko-sensei."
	DB	NEXT
	DB G_FLG,G_COPYF,150,150
	DB FLG,F_CALI,150,25
	DB G_FLG,G_COPYG,150,150
	DB	SINARIO,'CS512.OVL',0
	DW	0000H


end