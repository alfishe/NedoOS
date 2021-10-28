;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　恵依美１
;		
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
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	'MEIMI',0
;NN2:	DB	2,	'部屋',0
NN2:	DB	2,	'ROOM',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN2,  1, M2		;見る　部屋１
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7, M8, M9, M10, M11		;話す　恵依美９
S3:		DW	VV1, NN1,  3, M12, M13		;見る　恵依美２


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'【恵依美】：・・・さ、どうぞ。'
	DB	"Meimi:  .....Come in, please."
	DB	NEXT
;	DB	'【%001】：・・・・・・おじゃましま～す。'
	DB	"%001:  Thanks"
	E_CG B_SUDA,'AE_102'
	DW	0000H

M2:		;見る　部屋１
;	DB	'綺麗な部屋だ。女の子の部屋にしては少々飾りっけが無い気もするが、'
;	DB	'中野らしいといえばらしい。'
	DB	"It's a pretty room. It looks like the kind of place"
	DB	CR
	DB	"a young woman would live in."
	DW	0000H

M3:		;話す　恵依美１
;	DB	'【%001】：綺麗な部屋じゃないか。'
	DB	"%001:  You have a nice room."
	DB	NEXT
;	DB	'【恵依美】：・・・ありがと。'
	DB	"Meimi:  Thanks."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　恵依美２
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ................"
	DB	NEXT
;	DB	'【%001】：な、なあ中野。'
	DB	"%001:  Um, Meimi?"
	DB	NEXT
;	DB	'【恵依美】：な、なに？'
	DB	"Meimi:  Yes?"
	DB	NEXT
;	DB	'【%001】：さっき見掛けなかったけどさ・・・・・・'
;	DB	'お前のパパとママは？'
	DB	"%001:  I didn't see anyone downstairs. Where are your"
	DB	CR
	DB	"parents?"
	DB	NEXT
;	DB	'【恵依美】：え？'
	DB	"Meimi:  Hm?"
	DB	PAUSE
;	DB	'・・・う、うん、ちょっと出てるみたい。'
	DB	" Oh, they're out."
	DB	NEXT
;	DB	'【%001】：・・・そか。お前のあこがれの人を見てみたかったんだけどな。'
	DB	"%001:  I see. I wanted to see what they were like."
	DB	NEXT
;	DB	'【恵依美】：ざ、残念だったわね。'
	DB	"Meimi:  Well, you can meet them next time."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　恵依美３
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ................"
	DB	NEXT
;	DB	'【%001】：あ、あのさ',CR
;	DB	'【恵依美】：あ、あのね'
	DB	"%001:  By the way, I...",CR
	DB	"Meimi:  I, um..."
	DB	NEXT
;	DB	'【%001】：・・・・・・',CR
	DB	"%001:  ..............",CR
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  .............."
	DB	NEXT
;	DB	'【%001・恵依美】：ど、どうぞ。'
	DB	"%001/Meimi:  Go ahead."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ................."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;話す　恵依美４
;	DB	'【%001】：・・・・・・あ、あはあはあは・・・・・・'
	DB	"%001:  .....Hahahaha..."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・あは、あは、あははははは・・・・・・'
	DB	"Meimi:  Hahahaha...."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ........."
	DB	NEXT
;	DB	'（・・・く、空気が重い・・・）'
	DB	"(I've got to do something!)"
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;話す　恵依美５
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ........"
	DB	PAUSE
;	DB	'そ、そうだ。'
	DB	"Oh, I almost forgot!"
	DB	NEXT
;	DB	'ごそごそ'
	DB	"*rustle rustle*"
	DB	NEXT
;	DB	'【%001】：・・・・・・はい、これ。'
	DB	"%001:  ..........Here you are."
	DB	NEXT
;	DB	'【恵依美】：・・・これは・・・？'
	DB	"Meimi:  What is it?"
	DB	NEXT
;	DB	'【%001】：クリスマスプレゼントだよ。'
	DB	"%001:  Your Christmas present!"
	DB	NEXT
;	DB	'【恵依美】：あたしに！？'
	DB	"Meimi:  For me?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ........."
	DB	PAUSE
;	DB	'ありがと、%001・・・・・・嬉しい、とっても。'
	DB	"Thank you, %001. I'm so happy."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M8:		;話す　恵依美６
;	DB	'【%001】：・・・でさ、中野のプレゼントって何？'
	DB	"%001:  ...What did you get for me?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・・・・・・・・'
	DB	"Meimi:  ................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................"
	DB	 PAUSE
;	DB	'中野？'
	DB	"Meimi?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  .............."
	DB	PAUSE
;	DB	'あたし・・・・・・・・・'
	DB	"I......"
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  Eh?"
	DB	FLG,F_COPYI,2,6
	DW	0000H

M9:		;話す　恵依美７
;	DB	'【恵依美】：・・・・・・・・・だから、あたし・・・・・・・・・'
	DB	"Meimi:  .......My present is........."
	DB	NEXT
;	DB	'【%001】：・・・・・・へ？'
	DB	"%001:  ...........!!"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ............."
	DB	NEXT
;	DB	'【恵依美】：も～っ！この鈍感！'
	DB	"Meimi:  Are you dense? Are you going to make me say it?"
	DB	NEXT
;	DB	'【恵依美】：あ・た・し・を・あ・げ・る・のっ！！'
	DB	"Meimi:  I'm giving myself to you!!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'【%001】：え゛～～～～～～～～～～～～～～～～っ！！？'
	DB	"%001:  ....What?!"
	DB	FLG,F_COPYI,2,7
	DB	FLG,F_COPYI,3,1
	DW	0000H

M10:		;話す　恵依美８
;	DB	'【恵依美】：・・・・・・馬鹿！もう知らない！！'
	DB	"Meimi:  .......Idiot! Why are you so stupid?"
	DB	FLG,F_COPYI,2,8
	DW	0000H

M11:		;話す　恵依美９
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........"
	DB	PAUSE
;	DB	'ごめん。ちょっと心の準備が出来てなかったんだ。'
	DB	"I'm sorry. I just wasn't expecting you to say"
	DB	CR
	DB	"that."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ............."
	DB	NEXT
;	DB	'【%001】：・・・・・・いいの？本当に・・・・・・'
	DB	"%001:  Are you sure you want to do it?"
	DB	NEXT
;	DB	'耳まで真っ赤になりながら、中野はこっくりと頷く。'
	DB	"She blushed bright red, even to her ears. She nodded."
	DB	NEXT
;	DB	'【%001】：・・・・・・それじゃ・・・・・・'
	DB	"%001:  Okay, then....."
	DB	NEXT
	DB	SINARIO,'CSE_H_2.OVL',0
	DW	0000H

M12:		;見る　恵依美１
;	DB	'ベッドに座り、俯き加減にこちらを見ている'
	DB	"She's sitting on the bed, looking nervous."
;	DB	FLG,F_COPYI,3,1
	DW	0000H

M13:		;見る　恵依美２
;	DB	'文字通り、真っ赤っかだ。'
	DB	"She's blushing bright red."
	DW	0000H


end
