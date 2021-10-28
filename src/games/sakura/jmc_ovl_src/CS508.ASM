;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０８
;		川　ん？

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'捜す',0
VV1:	DB	1,	'LOOK FOR HER',0
;VV2:	DB	2,	'捜さない',0
VV2:	DB	2,	"DON'T BOTHER",0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;捜す１
S2:		DW	VV2, -1,  2, M3		;捜さない１


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_3'
	DB	BUF,B_COPY01
	T_CG 'CT14','T',0,25,1
;	DB	'誠のいる釣り場Ａだ。'
	DB	"I'm back at the fishing spot where Makoto is."
	DB	NEXT
;	DB	'【%001】：・・・え～っと、これで一通り回ったかな？'
	DB	"Well, I went around to everyone..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"........................."
	DB	NEXT
;	DB	'【%001】：・・・何だ？なんか引っ掛かるんだけど・・・'
	DB	"%001:  Something's bothering me."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"........................."
	DB	NEXT
;	DB	'【%001】：そうだ、白水さんを見掛けてないんだ。'
	DB	"%001:  That's right! I haven't seen Ruri all day."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・どこにいるんだ？'
	DB	".........I wonder where she is?"
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DW	0000H

M2:		;捜す１
;	DB	'【%001】：・・・よし、白水さんを捜そう。'
	DB	"%001:  ...I guess I'll go look for her."
	DB	NEXT
	DB	SINARIO,'CS508_1.OVL',0
	DW	0000H

M3:		;捜さない１
;	DB	'【%001】：・・・ま、いっか。'
	DB	"%001:  ...Well, I'm sure she's alright."
	DB	NEXT
;	DB	'俺は、誠の隣に腰掛けて、釣り糸を垂らした。'
	DB	"I sat down next to Makoto and tended my fishing line."
	DB	NEXT
;	DB	'【%001】：・・・釣れねえな。'
	DB	"%001:  ...We're not going to eat tonight, are we?"
	DB	NEXT
;	DB	'【誠】：・・・ああ。'
	DB	"Makoto:  Maybe not."
	DB	NEXT
	DB G_FLG,G_COPYI,159,1
	DB	SINARIO,'CS509.OVL',0
	DW	0000H


end
