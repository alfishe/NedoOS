;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０１＿Ａ
;		鈴子に謝る

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

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'グラウンド',0
NN2:	DB	2,	'BASEBALL FIELD',0
;NN3:	DB	3,	'テニスコート',0
NN3:	DB	3,	'TENNIS COURTS',0
;NN4:	DB	4,	'屋上',0
NN4:	DB	4,	'ROOF',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子
S2:		DW	VV2, NN1,  2, M4, M5, M6		;話す　鈴子３
S3:		DW	VV3, NN2,  3, M7, M8		;行く　グラウンド２
S4:		DW	VV3, NN3,  4, M9, M10		;行く　テニスコート２
S5:		DW	VV3, NN4,  5, M11, M12		;行く　屋上２


;イニシャルメッセージ
M1:
	DB	BGM,15
	BAK_INIT "AB_23"
	B_P1 B_SUDA
	DB	BUF,B_COPY01
;	DB	'俺はプールにやって来た。'
    DB	"I'm at the pool."
	DB	NEXT
	T_CG "CT01","W",0,15,1
;	DB	'【鈴子】：%001君・・・待ってたわ。'
    DB	"Reiko:  %001, I've been waiting for you."
    DB	NEXT
    ;	DB	'【%001】：・・・鈴子さん・・・'
    DB	"%001:  .........Reiko."
	DB	G_FLG,G_COPYI,101,1
	DB	FLG,F_COPYI,101,1
	DB	G_FLG,G_COPYF,3,102
	DB	G_FLG,G_COPYF,102,102
	DB	G_FLG,G_COPYF,4,103
	DB	G_FLG,G_COPYF,103,103
	DB	G_FLG,G_COPYF,5,104
	DB	G_FLG,G_COPYF,104,104
	DB	G_FLG,G_COPYF,199,199
	DB C_BLD,C_V_ON,3	;行く
	DB	FLG,F_CALLS,199
	DW	M_REIKO,M_KIYOMI0,M_IO0,M_AKI0
	DW	-1
	DW	0000H

M2:		;見る　鈴子
;	DB	'鈴子さんは不安そうな目で、俺の言葉を待っている。'
    DB	"She looks worried as she waits for me to speak first."
	DW	0000H

M3:		;見る　鈴子
;	DB	'鈴子さんは悲しそうな目で俺を見ている。'
    DB	"She looks sad. I'm hurting her."
	DW	0000H

M4:		;話す　鈴子１
;	DB	'【%001】：鈴子さん・・・俺・・・俺は・・・'
    DB	"%001:  Reiko, I......I..."
	DB	NEXT
	K_CG "CT01","I",15,2
;	DB	'【鈴子】：・・・・・・'
    DB	"Reiko:  ..............................."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　鈴子２
;	DB	'【%001】：俺は・・・俺は・・・'
    DB	"%001:  I........don't know how to say this..."
    DB	NEXT
    ;	DB	'【鈴子】：・・・・・・'
    DB	"Reiko:  ..............................."
    DB	NEXT
    ;	DB	'【%001】：・・・俺は、鈴子さんと・・・付き合えない。'
    DB	"%001:  ......I can't be your boyfriend."
    DB	NEXT
    ;	DB	'【%001】：鈴子さんが嫌いなんじゃないんだ、いや、鈴子さんのこと、本当の姉さんみたいだって思ってた！・・・だけど・・・'
    DB	"%001:  It's not because I don't like you! You're like a"
    DB	CR
    DB	"sister to me! I just..."
    DB	NEXT
    ;	DB	'【%001】：・・・俺・・・！'
    DB	"%001:  ......I...........!"
	DB	NEXT
	K_CG "CT01","K",15,3
;	DB	'【鈴子】：・・・あ～あ、フラレちゃったか。'
    DB	"Reiko:  ...I can swim like a fish, but I'm unlucky in love."
	DB FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,2
	DW	0000H


M6:		;話す　鈴子３
;	DB	'【鈴子】：・・・分かってたわ・・・%001君。'
    DB	"Reiko:  ..........I knew what you were going to say."
    DB	NEXT
    ;	DB	'【鈴子】：ここに来た時、まるで、お葬式みたいな顔してたもの。'
    DB	"Reiko:  I could see it in your face when you walked in"
    DB	CR
    DB	"here."
    DB	NEXT
    ;	DB	'【%001】：鈴子さん・・・。'
    DB	"%001:  Reiko...."
    DB	NEXT
    ;	DB	'【鈴子】：いいわ、私は今まで通り「お姉さん」で。',CR,'・・・それくらい、許してくれるわね？'
    DB	"Reiko:  I'll be alright, %001.",PAUSE," If you'll let me go on"
    DB	CR
    DB	"being your big sister. "
    DB	NEXT
    ;	DB	'【%001】：・・・鈴子さん・・・ごめん。'
    DB	"%001:  Reiko, I'm sorry."
    DB	NEXT
    ;	DB	'【鈴子】：%001君、真剣に考えてくれたんでしょ？だったら、もっと堂々と胸を張りなさい。'
    DB	"Reiko:  You thought about it, right? And this is your "
    DB	CR
    DB	"answer. Then there's nothing to be sorry about."
	DB	NEXT
	K_CG "CT01","I",15,2
;	DB	'【鈴子】：・・・私まで、泣きたくなっちゃうわ・・・。'
    DB	"Reiko:  ......Don't make me cry, too."
    DB	NEXT
    ;	DB	'【%001】：鈴子さん・・・。'
    DB	"%001:  Reiko....."
    DB	NEXT
    ;	DB	'【鈴子】：・・・%001君。君が選んだ子って、誰？'
    DB	"Reiko:  ......%001, tell me, who is it? Who did you choose?"
    DB	NEXT
	DB	FLG,F_CALLS,199
	DW	M_REIKO,M_KIYOMI,M_IO,M_AKI
	DW	-1
    ;	DB	'鈴子さんはプールの向こうへ・・・俺はプールの外へ、歩いていった。'
    DB	"I left Reiko and went outside."
	B_P1 B_SUDA
	DB	C_BLD,C_V_OFF,3	;行く
	DB	C_BLD,C_V_ON,1	;見る
	DB	C_BLD,C_V_ON,2	;話す
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
	DW	M_REIKO,M_KIYOMI2,M_IO2,M_AKI2
	DW	-1
	DW	0000H

M7:		;行く　グラウンド１
    ;	DB	'【%001】：新藤さんが待ってる・・・'
    DB	"%001:  Kiyomi's waiting for me."
    DB	NEXT
    ;	DB	'俺は野球部のグラウンドに向かった。'
    DB	"I head for the baseball field."
	DB	NEXT
	DB	SINARIO,'CSC01_B.OVL',0
	DW	0000H

M8:		;行く　グラウンド２
    ;	DB	'新藤さんには、もう会って来ただろ・・・。'
    DB	"I already talked to her. There's no need to go back."
	DW	0000H

M9:		;行く　テニスコート
    ;	DB	'【%001】：美緒ちゃんが待ってる・・・'
    DB	"%001:  Mio's waiting for me."
    DB	NEXT
    ;	DB	'俺はテニスコートに向かった。'
    DB	"I head for the tennis courts."
	DB	NEXT
	DB	SINARIO,'CSC01_C.OVL',0
	DW	0000H

M10:		;行く　テニスコート２
    DB	"Going back would only hurt Mio more, wouldn't it?"
	DW	0000H

M11:		;行く　屋上
;	DB	'【%001】：亜希ちゃんが待ってる・・・'
    DB	"%001:  Aki's waiting for me."
    DB	NEXT
;	DB	'俺は屋上に向かった。'
    DB	"I head for the roof of the school."
	DB	NEXT
	DB	SINARIO,'CSC01_F.OVL',0
	DW	0000H

M12:		;行く　屋上２
;	DB	'また会っても、亜希ちゃんを傷つけるだけだ。'
    DB	"I'll only hurt her if I go back."
	DW	0000H



M_REIKO:
;	DB	'【鈴子】：・・・フラグがおかしいわよ。'
    DB	"Reiko:  Your flag is fucked up. (This is a game internal"
    DB	CR
    DB	"thing)"
	DW	0000H

M_KIYOMI0:
	DB C_BLD,C_N_ON,3,1		;行く　グラウンド
	DW	0000H


M_KIYOMI:
;	DB	'【%001】：・・・新藤さんだよ。'
    DB	"%001:  ............It's Kiyomi."
	DB	NEXT
	K_CG "CT01","K",15,3
    DB	"Reiko:  .......I see."
    DB	NEXT
;	DB	'【鈴子】：%001君、清美ちゃんに甘えてばっかりじゃダメよ。'
    DB	"Reiko:  %001, you have to be firm with her. You can't let"
    DB	CR
    DB	"her have her way all the time."
    DB	NEXT
    ;	DB	'【鈴子】：・・・%001君・・・楽しい思い出を、ありがとう。'
    DB	"Reiko:  %001..... Thanks for making this past year so"
    DB	CR
    DB	"much fun for me."
    DB	NEXT
    ;	DB	'【%001】：鈴子さん・・・俺の方こそ、ありがとう・・・。'
    DB	"%001:  No, Reiko. Thank you."
	DW	0000H

M_KIYOMI2:
;	DB	'俺は新藤さんの待つ、野球部のグラウンドに向かった。'
    DB	"I headed for the baseball field."
	DB	NEXT
	DB SINARIO,'CSC02_B.OVL',0
	DW	0000H

M_IO0:
	DB C_BLD,C_N_ON,3,2		;行く　テニスコート
	DW	0000H

M_IO:
;	DB	'【%001】：・・・美緒ちゃんだよ。'
    DB	"%001:  .....It's Mio."
	DB	NEXT
	K_CG "CT01","K",15,3
;	DB	'【鈴子】：・・・そっか。'
    DB	"Reiko:  ..........I see."
    DB	NEXT
;	DB	'【鈴子】：%001君、美緒ちゃん泣かせたら、この私が承知しないからね。'
    DB	"Reiko:  Take good care of her, understand? Or I'll come and"
    DB	CR
    DB	"find you."
    DB	NEXT
    ;	DB	'【鈴子】：・・・%001君・・・楽しい思い出を、ありがとう。'
    DB	"Reiko:  %001.... Thanks for making this past year so much"
    DB	CR
    DB	"fun for me."
    DB	NEXT
    ;	DB	'【%001】：鈴子さん・・・俺の方こそ、ありがとう・・・。'
    DB	"%001:  No, Reiko... Thank you."
	DW	0000H

M_IO2:
;	DB	'俺は美緒ちゃんのいる、テニスコートに向かった。'
    DB	"I headed for the tennis courts."
	DB	NEXT
	DB SINARIO,'CSC02_C.OVL',0
	DW	0000H

M_AKI0:
	DB C_BLD,C_N_ON,3,3	;行く　屋上
	DW	0000H

M_AKI:
;	DB	'【%001】：・・・亜希ちゃんだよ。'
    DB	"%001:  .....It's Aki."
    DB	NEXT
    ;	DB	'【鈴子】：%001君・・・苦労するわよ。・・・って、それは承知の上か。'
    DB	"Reiko:  I see. Are you sure you won't be sorry later?"
	DB	NEXT
	K_CG "CT01","K",15,3
;	DB	'【鈴子】：・・・%001君・・・楽しい思い出を、ありがとう。'
    DB	"Reiko:  %001, Thanks for making this past year so"
    DB	CR
    DB	"much fun for me."
    DB	NEXT
    ;	DB	'【%001】：鈴子さん・・・俺の方こそ、ありがとう・・・。'
    DB	"%001:  No, Reiko, thank you."
	DW	0000H

M_AKI2:
;	DB	'俺は亜希ちゃんの待つ、屋上に向かった。'
    DB	"I head for the roof."
	DB	NEXT
	DB SINARIO,'CSC02_F.OVL',0
	DW	0000H





end
