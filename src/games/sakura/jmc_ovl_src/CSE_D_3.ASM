;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　祥子３
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
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　祥子４
S2:		DW	VV2, NN1,  2, M6, M7		;話す　祥子２


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'【祥子】：・・・ん・・・'
	DB	"Shoko:  ........Mm......"
	E_CG B_SUDA,'AE_173'
	DB	NEXT
;	DB	'【%001】：・・・う、うわわわわっ！？'
	DB	"%001:  ......Wahh!!"
	DB	NEXT
;	DB	'いきなり西野さんが、俺の物を口に含む。'
	DB	"Suddenly Shoko put my cock into her mouth."
	DB	NEXT
;	DB	'生暖かい物がはいまわる感触に、俺は思わずうめき声を洩らしていた。'
	DB	"A fresh, wet feeling assulted my senses, causing me to"
	DB	CR
	DB	"moan."
	DW	0000H

M2:		;見る　祥子１
;	DB	'俺の物を咥え、舐め回している。'
	DB	"She's got my cock in her mouth."
	DB	NEXT
;	DB	'【祥子】：・・・ん・・・んふっ・・・'
	DB	"Shoko:  ......Mmm....mmmm....."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　祥子２
;	DB	'頭全体を動かし、俺の物を出し入れする。'
	DB	"Bobbing her forward and back, she's sliding my cock in"
	DB	CR
	DB	"and out of her mouth vigorously."
	DB	NEXT
	DB	"She's really good at this."
	DB	NEXT
;	DB	'【祥子】：・・・うんっ・・・うんっ・・・'
	DB	"Shoko:  Mmmm.......mmmmm...."
	DB	NEXT
;	DB	'【%001】：・・・う・・・'
	DB	"%001:  ...That's good."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　祥子３
;	DB	'突然、頬骨が見えるほど強く吸う。'
	DB	"Suddenly she sucks, hard enough for her face to contract"
	DB	CR
	DB	"inwards."
	DB	NEXT
;	DB	'【祥子】：・・・んっ・・・'
	DB	"Shoko:  ........Mmmm..."
	DB	NEXT
;	DB	'【%001】：・・・うぅっ・・・！'
	DB	"%001:  Ghhh!"
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;見る　祥子４
;	DB	'一端口から離し、舌で丹念に舐め上げる。'
	DB	"Taking me out of her mouth, she starts licking up and"
	DB	CR
	DB	"down my shaft with her tongue."
	DB	NEXT
;	DB	'【%001】：・・・くっ・・・！'
	DB	"%001:  Ku....!"
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;話す　祥子１
;	DB	'【%001】：・・・に・・・西野さん・・・'
	DB	"%001:  .....Sh- Shoko...."
	DB	NEXT
;	DB	'【祥子】：・・・んっ・・・んっ・・・'
	DB	"Shoko:  .......Mmmm.....mmmm......"
;	DB	FLG,F_COPYI,2,1
	DW	0000H

M7:		;話す　祥子２
;	DB	'【祥子】：・・・ね、しゅ～君・・・'
	DB	"Shoko:  ......Shu-kun..."
	DB	PAUSE
;	DB	'そろそろ、きて・・・'
	DB	"I want to make love now."
	DB	NEXT
;	DB	'【%001】：・・・う、うん・・・'
	DB	"%001:  Yes, it's time."
	DB	NEXT
	DB	SINARIO,'CSE_D_4.OVL',0
	DW	0000H


end
