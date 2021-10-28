;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６１３
;		恵依美乱入

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
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	"MEIMI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　恵依美
S2:		DW	VV2, NN1,  2, M3, M4, M5		;話す　恵依美
S3:		DW	VV3, -1,  3, M6		;考える


;イニシャルメッセージ
M1:
	DB	BGM,9
	BAK_INIT "AB_17_2"
	DB BUF,B_COPY01
	TU_CG "CT08","F","D",30,1
	T_CG "CT03","M",0,0,2
;	DB	'【恵依美】：ちょっと%001！'
	DB	"Meimi:  Excuse me, %001!"
	DB	NEXT
;	DB	'【%001】：中野・・・？'
	DB	"%001:  Meimi...?"
	DW	0000H

M2:		;見る　恵依美
;	DB	'中野が何やら怒ってる。'
	DB	"Meimi looks mad about something."
	DB	NEXT
;	DB	'（・・・俺、なんかしたのか？）'
	DB	"Did I do something wrong?"
	DW	0000H

M3:		;話す　恵依美
;	DB	'【%001】：どーした怖い顔して。'
	DB	"%001:  Why are you looking at me like that?"
	DB	NEXT
;	DB	'【恵依美】：あんた、一体どーゆーつもり！？'
	DB	"Meimi:  What do you think you're doing?"
	DB	NEXT
;	DB	'【%001】：だから何が？'
	DB	"%001:  ....?? I'm talking to Mio, what else?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・・・・'
	DB	"Meimi:  ....................."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　恵依美
;	DB	'【%001】：俺、何かしたか・・・？'
	DB	"%001:  Did I do something wrong....?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ........................."
	EF_SET 101
	DW	0000H

M5:		;話す　恵依美
	K_CG "CT08","I",30,3
	DB ANI,A_ON,2
;	DB	'【恵依美】：・・・・・・・・・そろそろ夕食の時間よ。'
	DB	"Meimi:  ...Anyway, it's almost dinnertime."
	DB	NEXT
;	DB	'【%001】：え、もうそんな時間？'
	DB	"%001:  What, already?"
	DB	NEXT
;	DB	'【%001】：わかった。行こう、美緒ちゃん。'
	DB	"%001:  All right. Well, let's go, Mio!"
	DB	NEXT
;	DB	'【美緒】：う、うん！'
	DB	"Mio:  Y- yes!"
	DB	NEXT
;	DB	'【%001】：悪ィな、中野。わざわざ呼びに来てもらって。'
	DB	"%001:  Sorry, Meimi, that you had to come all the way to"
	DB	CR
	DB	"call us."
	DB	NEXT
;	DB	'【恵依美】：それじゃ・・・あたし、用事があるから。'
	DB	"Meimi:  Well, nevermind."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT03","M",0,0,2
;	DB	'・・・中野はすたすたと歩いていってしまった。'
	DB	"Meimi walked off briskly."
	DB	NEXT
;	DB	'【%001】：クラス委員って大変なんだな・・・。'
	DB	"%001:  Wow, it must be hard to be class chairperson."
	DB	NEXT
;	DB	'【美緒】：%001先輩、貝持っていかなきゃ。'
	DB	"Mio:  %001, don't forget the clams."
	DB	NEXT
;	DB	'【%001】：あ、忘れてた。'
	DB	"%001:  Oh, whoops."
	DB	NEXT
	DB SINARIO,'CS614.OVL',0
	DW	0000H

M6:		;考える
;	DB	'（中野のやつ、何怒ってんだ？）'
	DB	"I wonder why Meimi's mad?"
	DB	NEXT
;	DB	'（考えても分からん。直接聞いた方が早い。）'
	DB	"I have no idea. I should probably just ask."
	EF_SET 102
	DW	0000H

M_EXIT:
	DB FLG,F_AND,255,101,102
	DB FLG,F_EXIT,255
	DB FLG,F_COPYI,2,2	;話す　恵依美３
	DW	0000H

end
