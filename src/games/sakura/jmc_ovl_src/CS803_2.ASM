;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０３＿２
;		体育祭３日前　ＣＡＳＥ１　恵依美と星愛

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	NN1,NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'迷う',0
VV3:	DB	3,	'CONSIDER IT',0
;VV4:	DB	4,	'送る',0
VV4:	DB	4,	'TAKE HOME',0

;NN1:	DB	1,	'星愛',0
NN1:	DB	1,	'SEIA',0
;NN2:	DB	2,	'恵依美',0
NN2:	DB	2,	'MEIMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　星愛
S2:		DW	VV1, NN2,  2, M4, M5		;見る　恵依美
S3:		DW	VV2, NN2,  3, M6, M7, M8		;話す　恵依美３
S4:		DW	VV3, -1,  4, M9		;迷う
S5:		DW	VV4, NN1,  5, M10		;送る　星愛
S6:		DW	VV4, NN2,  6, M11		;送る　恵依美


;イニシャルメッセージ
M1:
	DB	BGM,17
	BAK_INIT "AB_04_3"
	DB BUF,B_COPY01
	T_CG "CT07","W",0,0,1
;	DB	'【星愛】：・・・じゃあ、わたくしはここで。'
	DB	"Seia:  Okay, I'll see you tomorrow, %001."
	DB	NEXT
	T_CG1 "CT08","W",0,30,2
	DB ANI,A_ON,1
;	DB	'【恵依美】：あれ？星愛、家こっちでしょ？'
	DB	"Meimi:  What? Seia, your house is this way."
	DB	NEXT
	K_CG "CT07","K",0,3
	DB ANI,A_ON,2
;	DB	'【星愛】：・・・・・・ええ、ちょっと寄るところがありますの。'
	DB	"Seia:  Yes, but I've got to go somewhere tonight."
	DB	PAUSE
;	DB	'%001さん、恵依美ちゃんを送ってあげてくださいね。'
	DB	" %001,"
	DB	CR
	DB	"please take Meimi home."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT08","W",0,30,2
;	DB	'【恵依美】：ちょ・・・ちょっと星愛！！'
	DB	"Meimi:  Wait, Seia!"
	DB	PAUSE
;	DB	'・・・行っちゃった。'
	DB	" Too late....."
	DB	C_BLD,C_V_ON,3		;「迷う」　消す
	DB	C_BLD,C_V_ON,4		;「送る」　消す
	DW	0000H

M2:		;見る　星愛
;	DB	'とっとと行ってしまった。'
	DB	"She's gone."
	DB	NEXT
;	DB	'・・・どーしたんだろ、急に。'
	DB	"I wonder what's going on."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　星愛
;	DB	'結構遠くにいる・・・'
	DB	"She's pretty far away by now."
	DB	NEXT
;	DB	'走って追いつけない距離じゃない。'
	DB	"I could catch up with her if I wanted to."
	DB	FLG,F_COPYI,101,1
	DW	0000H

M4:		;見る　恵依美
;	DB	'心配そうに吉田を見ている。'
	DB	"She's watching Seia with a worried expression on her face."
	DB	NEXT
;	DB	'・・・ホント、仲いいんだな。'
	DB	"They're really good friends."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;見る　恵依美
;	DB	'吉田の心配もいいけど・・・'
	DB	"She's worried about Seia..."
	DB	NEXT
;	DB	'自分はどうするんだろ？ここからだと、吉田の家に行くのも中野の家に行くのも、大して変わらないはずだけど。'
	DB	"But it's the same distance from here to her house as it"
	DB	CR
	DB	"is to Seia's house."
	DB	FLG,F_COPYI,102,1
	DW	0000H

M6:		;話す　恵依美１
;	DB	'【恵依美】：・・・どうしたんだろ星愛？'
	DB	"Meimi:  I wonder what got into Seia."
	DB	NEXT
;	DB	'【%001】：さあ？'
	DB	"%001:  If you don't know, I really have no idea."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ....................."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M7:		;話す　恵依美２
;	DB	'【恵依美】：・・・ねえ%001。星愛の事、送ってあげてくれない？'
	DB	"Meimi:  %001, will you walk her home instead of me?"
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  Me?"
	DB	NEXT
;	DB	'【恵依美】：だからぁ、女の子がこんな時間に一人で歩いてたら危ないでしょ？'
	DB	"Meimi:  It's dangerous for a woman to be out this late at"
	DB	CR
	DB	"night, right?"
	DB	NEXT
;	DB	'【%001】：そらそ～だ。'
	DB	"%001:  That's true."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M8:		;話す　恵依美３
;	DB	'【恵依美】：ねえ・・・追い掛けてあげてよ。%001の足なら、追い着けるでしょ？'
	DB	"Meimi:  Go after her, would you? You can catch her easily."
	DB	NEXT
	DB	G_FLG,G_COPYF,0,174
	DB	FLG,F_JEQ,0
	DW	SKIP_SAIA
;	DB	'【%001】：・・・ああ・・・'
	DB	"%001:  ...I guess so."
	DB	FLG,F_COPYI,103,1
	DB	C_BLD,C_V_OFF,3		;「迷う」　出す
	DB	C_BLD,C_V_OFF,4		;「送る」　出す
	DB	C_BLD,C_V_ON,2		;「話す」　消す
	DW	0000H

M9:		;迷う
;	DB	'う～ん、確かに中野の言うことも一理ある・・・'
	DB	"I hear what Meimi is saying..."
	DB	NEXT
;	DB	'・・・けど、それを言っちゃあ、中野はどうするんだ？'
	DB	"But if I walk Seia home, what about Meimi?"
	DB	NEXT
;	DB	'・・・さて、どうしたもんか・・・？'
	DB	"What should I do?"
	DW	0000H

M10:		;送る　星愛
;	DB	'【%001】：・・・わかった。吉田を追いかける。'
	DB	"%001:  Okay, I'll walk her home instead."
	DB	PAUSE
;	DB	'じゃな中野！気ィ付けてな！'
	DB	" See you tomorrow."
	DB	CR
	DB	"Be careful!"
	DB	NEXT
	K_CG "CT08","K",30,4
;	DB	'【恵依美】：うん。%001もね。'
	DB	"Meimi:  Goodnight, %001."
	DB	NEXT
;	DB	'俺は中野に手を振ると、全速力で吉田の後を追い掛け始めた。'
	DB	"I waved goodbye to Meimi, then ran at full speed towards"
	DB	CR
	DB	"Seia."
	DB	NEXT
	DB G_FLG,G_COPYI,175,1
	DB	SINARIO,'CS803_4.OVL',0
	DW	0000H

M11:		;送る　恵依美
SKIP_SAIA:
;	DB	'【%001】：・・・いや。中野、送って行くよ。'
	DB	"%001:  No, I'll walk you home."
	DB	NEXT
	K_CG "CT08","I",30,5
;	DB	'【恵依美】：え？でも・・・'
	DB	"Meimi:  Me? But..."
	DB	NEXT
;	DB	'【%001】：吉田は大丈夫だろ。ヤバいところに近づくとは思えないし。'
	DB	"%001:  She'll be alright. She's a smart woman."
	DB	NEXT
;	DB	'【恵依美】：それはそ～だけど・・・'
	DB	"Meimi:  Yes, but..."
	DB	NEXT
;	DB	'【%001】：それより、こっち方面が中野の家なんだろ？'
	DB	"%001:  Your house is this way, right?"
	DB	PAUSE
;	DB	'こっから先は人通りが少なくて暗いところが多いからな。'
	DB	" The road ahead is dark."
	DB	CR
	DB	"It looks dangerous."
	DB	PAUSE
;	DB	'・・・ま、吉田にも頼まれたこったし、送ってくよ。'
	DB	" Besides, Seia asked me to walk you home."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ............."
	DB	PAUSE
	K_CG "CT08","K",30,4
;	DB	'ありがと。じゃあ行こ？'
	DB	"Thanks. Let's go."
	DB	NEXT
	DB G_FLG,G_COPYI,185,1
	DB	SINARIO,'CS803_3.OVL',0
	DW	0000H


end
