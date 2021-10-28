;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０８＿Ｈ
;		川　瑠璃を捜す（恵依美）

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
;VV2:	DB	2,	'聞く',0
VV2:	DB	2,	'ASK',0
;VV3:	DB	3,	'戻る',0
VV3:	DB	3,	'GO BACK',0

;NN1:	DB	1,	'川',0
NN1:	DB	1,	'RIVER',0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	'SKY',0
;NN3:	DB	3,	'瑠璃',0
NN3:	DB	3,	'RURI',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M8, M9		;話す　恵依美
S4:		DW	VV3, NN4,  4, M11		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_3'
	DB	BUF,B_COPY01
	T_CG 'CT08','T',0,0,1
;	DB	'中野のいる釣り場Ｃだ。'
	DB	"I'm at the fishing spot where Meimi is."
	DB	NEXT
;	DB	'【恵依美】：あ、%001！ほら！'
	DB	"Meimi:  Hi, %001. Look at all the fish I've got!"
	DB	NEXT
;	DB	'【%001】：・・・おっ、けっこう釣れたじゃねえか。'
	DB	"%001:  Hey, you're doing great!"
	DW	0000H

M2:		;見る　川
	DB	"It's a river overflowing with fish."
	DB	PAUSE
;	DB	'・・・多分。'
	DB	"...I think."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　川
;	DB	'昨日の雨で増水してるみたいだ。'
	DB	"The rain yesterday has filled the river up with water."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M5:		;見る　川
;	DB	'できればあまり近づきたくないな。'
	DB	"I don't want to get too close to it."
	DB	NEXT
;	DB	'なぜって・・・・・・泳げねーから。'
	DB	"The reason for that is... I can't swim."
	DW	0000H

M6:		;見る　空
;	DB	'天気もいいし、見渡すかぎり青い空だ。'
	DB	"The weather's fine, and the sky is blue."
	DW	0000H

M8:		;話す　恵依美
;	DB	'【%001】：あのさ、白水さん知らない？'
	DB	"%001:  Have you seen Ruri?"
	DB	NEXT
;	DB	'【恵依美】：さあ、知らないけど。'
	DB	"Meimi:  Hmm, I haven't"
	DB	NEXT
;	DB	'【%001】：・・・そか。ならいーんだ。'
	DB	"%001:  I see. Nevermind, then."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M9:		;話す　恵依美
;	DB	'【恵依美】：%001、白水さんに何の用なの？'
	DB	"Meimi:  Why are you looking for her?"
	DB	NEXT
;	DB	'【%001】：・・・・・・さあ？'
	DB	"%001:  .....No reason."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  .................................."
	DW	0000H

	
M11:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I go back to the fishing spot where Makoto is."
	DB	NEXT
	DB SINARIO,'CS508_1.OVL',0
	DW	0000H

end
