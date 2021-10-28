;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０１＿Ｂ
;		清美に謝る

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM3:	DW	VV3,	NN2,NN3,NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'行く',0
VV3:	DB	3,	'GO',0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	'KIYOMI',0
;NN2:	DB	2,	'プール',0
NN2:	DB	2,	'POOL',0
;NN3:	DB	3,	'テニスコート',0
NN3:	DB	3,	'TENNIS COURTS',0
;NN4:	DB	4,	'屋上',0
NN4:	DB	4,	'ROOF',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　清美
S2:		DW	VV2, NN1,  2, M4, M5, M6		;話す　清美３
S3:		DW	VV3, NN2,  3, M7, M8		;行く　プール２
S4:		DW	VV3, NN3,  4, M9, M10		;行く　テニスコート２
S5:		DW	VV3, NN4,  5, M11, M12		;行く　屋上２


;イニシャルメッセージ
M1:
	DB	BGM,15
	BAK_INIT "AB_11_2"
	B_P1 B_SUDA
	DB	BUF,B_COPY01
;	DB	'俺は野球部グラウンドにやって来た。'
	DB	"I'm at the baseball field."
	DB	NEXT
	T_CG "CT02","W",'K',15,1
;	DB	'【%001】：・・・新藤さん・・・ちょっといい？'
	DB	"%001:  Kiyomi, can I talk to you a minute?"
	DB	NEXT
;	DB	'【清美】：%001さん・・・お待ちしておりました。'
	DB	"Kiyomi:  %001...I've been waiting for you."
	DB	NEXT
;	DB	'俺は新藤さんを、物陰に呼んだ。'
	DB	"I went off with Kiyomi, away from the others."
	DB	FLG,F_COPYI,102,1
	DB	G_FLG,G_COPYI,102,1
	DB	G_FLG,G_COPYF,3,101
	DB	G_FLG,G_COPYF,101,101
	DB	G_FLG,G_COPYF,4,103
	DB	G_FLG,G_COPYF,103,103
	DB	G_FLG,G_COPYF,5,104
	DB	G_FLG,G_COPYF,104,104
	DB	G_FLG,G_COPYF,199,199
	DB C_BLD,C_V_ON,3		;行く
	DB	FLG,F_CALLS,199
	DW	M_REIKO0,M_KIYOMI,M_IO0,M_AKI0
	DW	-1
	DW	0000H

M2:		;見る　清美
;	DB	'新藤さんは不安そうな目で、俺の言葉を待っている。'
	DB	"She's waiting for me to talk. She looks worried."
	DW	0000H

M3:		;見る　清美
;	DB	'新藤さんは無理に笑顔を作ってる。'
	DB	"She's doing her best to force a smile."
	DB	NEXT
;	DB	'（ごめん・・・新藤さん。）'
	DB	".......I'm sorry, Kiyomi."
	DW	0000H

M4:		;話す　清美１
;	DB	'【%001】：新藤さん・・・俺は・・・'
	DB	"%001:  Kiyomi, I.......I....."
	DB	NEXT
;	DB	'【%001】：・・・俺は・・・'
	DB	"%001:  ......I......."
	DB	NEXT
;	DB	'【清美】：・・・・・・続けて下さい・・・'
	DB	"Kiyomi:  Say it, %001......."
	DB	NEXT
	DB FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　清美２
;	DB	'【%001】：俺は・・・俺は・・・'
	DB	"%001:  I.......I don't know how to say this..."
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  ............."
	DB	NEXT
;	DB	'【%001】：・・・俺は、新藤さんとは・・・付き合えない。'
	DB	"%001:  ....I can't be your boyfriend."
	DB	NEXT
;	DB	'【%001】：新藤さんは俺にとって、大事な友達だ！・・・だけど・・・'
	DB	"%001:  You're a good friend to me! Please believe that! I"
	DB	CR
	DB	"just..."
	DB	NEXT
	T_CG "CT02","W",0,15,2
;	DB	'【清美】：・・・・・・わたくしより、大切な女性がいらっしゃるのですね・・・？'
	DB	"Kiyomi:  There's someone you care about more than me..."
	DB	NEXT
;	DB	'【%001】：・・・俺・・・！'
	DB	"%001:  Oh, Kiyomi...!"
	DB FLG,F_COPYI,1,1	;見る　清美２
	DB	FLG,F_COPYI,2,2
	DW	0000H


M6:		;話す　清美３
;	DB	'【%001】：・・・新藤さん・・・ごめん。'
	DB	"%001:  Kiyomi, I'm sorry."
	DB	NEXT
	K_CG "CT02",'K',15,1
;	DB	'【清美】：・・・・・・%001さん、わたくしでしたら平気ですのよ。'
	DB	"Kiyomi:  .....I'll be alright, %001. Don't worry about me."
	DB	NEXT
;	DB	'【清美】：今まで通り、お友達としてわたくしとお付き合いして下さいますか？'
	DB	"Kiyomi:  I'd be honored if you would remain my friend."
	DB	NEXT
;	DB	'【%001】：新藤さん・・・俺の方こそ、土下座してお願いしたいくらいだよ。'
	DB	"%001:  Kiyomi, me too! Of course!"
	DB	NEXT
	;清美泣き
	K_CG "CT02",'I',15,3
;	DB	'【清美】：・・・本当にわたくし・・・なんとも・・・'
	DB	"Kiyomi:  ......I don't know what's wrong with me..."
	DB	NEXT
	DB	"Her eyes were beginning to grow moist."
	DB	NEXT
;	DB	'【%001】：新藤さん・・・。'
	DB	"%001:  Kiyomi..."
	DB	NEXT
;	DB	'【清美】：・・・おかしいですわ・・・本当に平気ですのに・・・'
	DB	"Kiyomi:  .....It's so odd. I'm really fine, really..."
	DB	NEXT
;	DB	'【清美】：・・・・・・きっと、目にゴミが入ったのですわ。'
	DB	"Kiyomi:  Some dust must have gotten in my eye..."
	DB	NEXT
	DB	"Kiyomi:  I...... I......."
	DB	NEXT
;	DB	'【清美】：・・・・・・目の病気かもしれませんわ。',CR,'わたくし、これで失礼させていただきます・・・！'
	DB	"Kiyomi:  .....Goodbye, %001!"
	DB	NEXT
	B_P1 B_SUDA
;	DB	'新藤さんは校舎の方に走っていった。'
	DB	"Kiyomi ran back into the school."
	DB	NEXT
;	DB	'【%001】：新藤さん・・・こんな時まで、俺なんかのために',CR,'気をつかってくれて・・・'
	DB	"%001:  Even when I break her heart, she's trying to make"
	DB	CR
	DB	"things easier for me..."
	DB	NEXT
;	DB	'【%001】：・・・ありがとう、新藤さん・・・'
	DB	"%001:  Thank you, Kiyomi."
	DB	C_BLD,C_V_OFF,3		;行く
	DB	C_BLD,C_V_ON,1		;見る
	DB	C_BLD,C_V_ON,2		;話す
	DB	FLG,F_PLUS,255,101
	DB	FLG,F_PLUS,255,102
	DB	FLG,F_PLUS,255,103
	DB	FLG,F_PLUS,255,104
	DB	FLG,F_COMPI,254,255,2
	DB	FLG,F_JGR,254
	DW	HEKETON
	DW	0000H

HEKETON:
	DB	NEXT
;	DB	'・・・これで、一通りのけじめはつけた。'
	DB	"....Well, that's done."
	DB	NEXT
;	DB	'後は、俺の気持ちを伝えるだけだ・・・！'
	DB	"Now to reveal my feelings...!"
	DB	NEXT
	DB	FLG,F_CALLS,199
	DW	M_REIKO2,M_KIYOMI,M_IO2,M_AKI2
	DW	-1
	DW	0000H

M7:		;行く　プール１
;	DB	'【%001】：鈴子さんが待ってる・・・'
	DB	"%001:  Reiko's waiting for me..."
	DB	NEXT
;	DB	'俺はプールに向かった。'
	DB	"I head for the pool."
	DB	NEXT
	DB	SINARIO,'CSC01_A.OVL',0
	DW	0000H

M8:		;行く　プール２
;	DB	'鈴子さんには、今会って来ただろ・・・。'
	DB	"I just went there."
	DW	0000H

M9:		;行く　テニスコート
;	DB	'【%001】：美緒ちゃんが待ってる・・・'
	DB	"%001:  Mio's waiting for me..."
	DB	NEXT
;	DB	'俺はテニスコートに向かった。'
	DB	"I head for the tennis courts."
	DB	NEXT
	DB	SINARIO,'CSC01_C.OVL',0
	DW	0000H

M10:		;行く　テニスコート２
;	DB	'美緒ちゃんの所には行けないだろ・・・。'
	DB	"That's not a good idea, is it?"
	DW	0000H

M11:		;行く　屋上
;	DB	'【%001】：亜希ちゃんが待ってる・・・'
	DB	"%001:  Aki's waiting for me..."
	DB	NEXT
;	DB	'俺は屋上に向かった。'
	DB	"I head for the roof."
	DB	NEXT
	DB	SINARIO,'CSC01_F.OVL',0
	DW	0000H

M12:		;行く　屋上２
;	DB	'また会っても、亜希ちゃんを傷つけるだけだ。'
	DB	"Going back will only hurt Aki more."
	DW	0000H



M_KIYOMI:
;	DB	'【清美】：・・・フラグがおかしいわよ。'
	DB	"Your flag is wrong!!"
	DW	0000H

M_REIKO0:
	DB C_BLD,C_N_ON,3,1		;行く　プール
	DW	0000H



M_REIKO2:
;	DB	'俺は鈴子さんの待つ、プールに向かった。'
	DB	"I head for the pool."
	DB	NEXT
	DB SINARIO,'CSC02_A.OVL',0
	DW	0000H

M_IO0:
	DB C_BLD,C_N_ON,3,2		;行く　テニスコート
	DW	0000H


M_IO2:
;	DB	'俺は美緒ちゃんのいる、テニスコートに向かった。'
	DB	"I head for the tennis courts."
	DB	NEXT
	DB SINARIO,'CSC02_C.OVL',0
	DW	0000H

M_AKI0:
	DB C_BLD,C_N_ON,3,3		;行く　屋上
	DW	0000H


M_AKI2:
;	DB	'俺は亜希ちゃんの待つ、屋上に向かった。'
	DB	"I head for the roof."
	DB	NEXT
	DB SINARIO,'CSC02_F.OVL',0
	DW	0000H





end
