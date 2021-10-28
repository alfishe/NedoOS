
;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　３０８
;		花見の後

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
CM2:	DW	VV2,	NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'教室',0
NN1:	DB	1,	"CLASSROOM",0
;NN2:	DB	2,	'今日子',0
NN2:	DB	2,	"KYOKO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　教室
S2:		DW	VV2, NN2,  2, M4, M5		;話す　今日子


;イニシャルメッセージ
M1:
	DB	BGM,32
	BAK_INIT "AB_38_1"
	B_P1 B_SUDA
;	DB	'・・・次に目覚めた時、俺は自分の家で寝てた。'
	DB	".....I wake up in my own bed."
	DB	NEXT
;	DB	'頭の奥で小人さんが道路工事をしてるみたいだ・・・'
	DB	"It feels like a bunch of little men are doing roadwork"
	DB	CR
	DB	"in my head."
	DB	NEXT
;	DB	'これが「二日酔い」ってやつ？'
	DB	"This must be what a hangover feels like..."
	DB	NEXT
;	DB	'しかし高校生が二日酔いで学校を休んじゃ洒落にならん。'
	DB	"But I can't let that make me miss school. That would be"
	DB	CR
	DB	"too much."
	DB	NEXT
	E_CG B_YOKO,'AB_03_1'
;	DB	'俺はふらふら歩きながら学校に向かった。'
	DB	"I stumble off to school."
;	DB	NEXT
	DB	C_BLD,C_V_ON,2		;話す　消す
	E_CG B_SUDA,"AE_010"
	DW	0000H

M2:		;見る　教室
;	DB	'がらーん'
	DB	"*KACHA*"
;	DB	NEXT
;	DB	'・・・・・・'
	DB	"..................."
	DB	NEXT
;	DB	'あれっ？'
	DB	"Hey?"
	DB	NEXT
;	DB	'なんで、誰もいね～んだ？'
	DB	"Nobody's here."
	DB	NEXT
;	DB	'でも、今日子先生はいるぞ。'
	DB	"Nobody's here except Kyoko-sensei!"
	DB	FLG,F_COPYI,1,1
	DB	C_BLD,C_V_OFF,2		;話す　出し
	DW	0000H

M3:		;見る　教室
;	DB	'・・・誰もいない・・・'
	DB	"There's no one here!"
	DB	NEXT
;	DB	'・・・なんで？・・・'
	DB	"Why?"
	DW	0000H

M4:		;話す　今日子
;	DB	'【%001】：おはよ～～す・・・・・・'
 	DB	"%001:  Good morning, Kyoko-sensei."
	DB	NEXT
;	DB	'【今日子】：おはよ、%001君。大丈夫？'
	DB	"Kyoko:  Good morning %001. Are you feeling alright?"
	DB	NEXT
;	DB	'【%001】：あんまり大丈夫じゃねえです・・・'
	DB	"%001:  To tell the truth, no, but I'm here."
	DB	NEXT
;	DB	'【%001】：ところで、みんなどこ行ったんです？体育の授業・・・じゃないよな。'
	DB	"%001:  By the way, where is everyone?"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　今日子
;	DB	'【今日子】：みんなお休み。'
	DB	"Kyoko:  Everyone is absent."
	DB	NEXT
;	DB	'【%001】：・・・ひょっとして、今日学校来たの俺だけ？'
	DB	"%001:  ....So I am the only one here today?"
	DB	NEXT
;	DB	'【今日子】：そうなのよ～。だから今日は学級閉鎖。'
	DB	"Kyoko:  That's right. So I'm cancelling class."
	DB	NEXT
;	DB	'【%001】：ふっ・・・二日酔いで学級閉鎖・・・'
	DB	"%001:  Because of hangovers..."
	DB	NEXT
;	DB	'【%001】：はっ・・・恥だァ！！'
	DB	"%001:  Man.....That is embarrassing!!"
	DB	NEXT
;	DB	'・・・こうして俺達１－Ａ組は「二日酔いで学級閉鎖」という、恥くさい記録を残してしまったのだった。'
	DB	"And that is how we of class 1-A set the not-so-proud"
	DB	CR
	DB	"record for hangover vacations at our school."
	DB	NEXT
	DB SINARIO,'CS401.OVL',0
	DW	0000H


end
