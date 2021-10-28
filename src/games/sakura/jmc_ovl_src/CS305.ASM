;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　３０５
;		星愛の部屋

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'寝かせる',0
VV2:	DB	2,	"PUT TO BED",0

;NN1:	DB	1,	'星愛',0
NN1:	DB	1,	"SEIA",0
;NN2:	DB	2,	'部屋',0
NN2:	DB	2,	"ROOM",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M5		;見る　星愛１
S2:		DW	VV1, NN2,  2, M3		;見る　部屋１
S3:		DW	VV2, NN1,  3, M4		;寝かせる　星愛


;イニシャルメッセージ
M1:
	DB	BGM,1
	BAK_INIT "AB_04_1"
	B_P1 B_SUDA
;	DB	'【%001】：・・・え～っと？ここの角を右、と・・・'
	DB	"%001:  Okay, turn right here, and..."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"...................."
	DB	NEXT
;	DB	'【%001】：お、ここだな。「吉田」って表札ぶら下がってるから、間違いない。'
	DB	"%001:  This is it. It says Yoshida. No mistake."
	DB	NEXT
;	DB	'ピンポーン。'
	DB	"*DING DONG*"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"....................."
	DB	NEXT
;	DB	'【%001】：返事がねぇな。誰もいないのか？'
	DB	"%001:  No answer. Is nobody home?"
	DB	NEXT
;	DB	'ピンポーン。'
	DB	"*DING DONG*"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"......................."
	DB	NEXT
;	DB	'【%001】：しょーがねぇなもう。・・・ど～すんだよこいつ。'
	DB	"%001:  Oh well. What am I supposed to do with her?"
	DB	NEXT
;	DB	'【%001】：・・・・・・ダメ元で、開けてみっか。'
	DB	"%001:  Better go in."
	DB	NEXT
;	DB	'がちゃ。'
;	DB	"*Kacha*"
;	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ...................."
	DB	NEXT
;	DB	'【%001】：不用心だな。ホントに開いてやんの。'
	DB	"%001:  They shouldn't leave their door unlocked like that."
	DB	NEXT
;	DB	'【%001】：・・・まぁいっか。おじゃましま～す。'
	DB	"%001:  Oh well. Hello? Is anyone home?"
	DB	NEXT
;	DB	'・・・・・・'
	DB	"............................"
	DB	NEXT
;	DB	'【%001】：ここだな・・・「星愛の部屋」って書いてある。'
	DB	"%001:  This must be it. It says 'Seia's room' on the door."
	DB	NEXT
;	DB	'がちゃ。'
	DB	"*Kacha*."
	BAK_INIT "AB_30"
	B_P1 B_SUDA
	DB	NEXT
;	DB	'【%001】：・・・ふ～ん、ここが吉田の部屋か。'
	DB	"%001:  ...So this is Seia's room."
	DB C_BLD,C_N_ON,1,1
	DW	0000H

M2:		;見る　星愛１
;	DB	'【星愛】：・・・すぅ・・・すぅ・・・'
	DB	"Seia:  Zzzzzzzz..."
	DB	NEXT
;	DB	'平和そのものって顔で、眠りこけている。'
	DB	"She is sleeping so peacefully."
	DB	NEXT
;	DB	'【%001】：・・・まったく・・・'
	DB	"%001:  .....Sheesh......"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　部屋１
;	DB	'きれいにはしてあるみたいだが、割りと何にもない部屋だ。'
	DB	"It is pretty clean room, but there's not much in it."
	DB	NEXT
;	DB	'【%001】：・・・女の子の部屋って、もっと物あるかと思ってたけど・・・'
	DB	"I figured there would be more stuff in a woman's room."
	DW	0000H

M4:		;寝かせる　星愛
	E_CG B_NORM,"AE_007"
;	DB	'【%001】：・・・どれ、こいつをベッドにおいて、っと・・・'
	DB	"%001:  Okay, get her on the bed."
	DB	NEXT
;	DB	'【%001】：・・・布団をかけて・・・'
	DB	"%001:  Put a blanket on her."
	DB	NEXT
;	DB	'【%001】：・・・これでよし、と・・・'
	DB	"%001:  Okay, that's about it..."
	DB C_BLD,C_N_OFF,1,1
	DB C_BLD,C_V_ON,2
	DW	0000H
	


M5:		;見る　星愛１
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  .............."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ................"
	DB	NEXT
	T_CG1 "AE_007G",0,0,0,0
;	DB	'【%001】：・・・よ、よう。気が付いたか？'
	DB	"%001:  Hey. are you awake, yet?"
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  .................."
	DB	NEXT
;	DB	'むくっ。'
	DB	"*BADUMP*"
	DB	NEXT
;	DB	'【%001】：・・・お、おい・・・？'
	DB	"%001:  .....H- Hey!"
	DB	NEXT
	DB	SINARIO,'CS306.OVL',0
	DW	0000H


end
