;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｂ０５＿Ｂ
;		清美のチョコ

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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN2,NN3,-1

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

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　清美
S2:		DW	VV2, NN1,  2, M4, M5, M6		;話す　清美３
S3:		DW	VV3, NN2,  3, M7, M8		;行く　プール２
S4:		DW	VV3, NN3,  4, M9, M10		;行く　テニスコート


;イニシャルメッセージ
M1:
        DB	BGM,13
        BAK_INIT "AB_11_1"
        B_P1 B_SUDA
        ;	DB	'俺は野球部のグラウンドにやって来た。'
        DB	"I'm at the baseball field."
        DB	NEXT
        ;	DB	'【%001】：新藤さんは・・・'
        DB	"%001:  Where's Kiyomi?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・いた。'
        DB	"%001:  ..........Oh, there she is."
        DB	NEXT
        ;	DB	'【%001】：新藤さーん！'
        DB	"%001:  Kiyomi!"
        DB	NEXT
        ;	DB	'新藤さんは俺に気がつくと、ぱたぱたと走ってきた。'
        DB	"She runs over to me."
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT02","W","K",15,1
        ;	DB	'【清美】：%001さん、お待ちしておりましたわ！'
        DB	"Kiyomi:  %001, I've been waiting for you!"
        DB	G_FLG,G_COPYI,102,1
        DB	G_FLG,G_COPYF,3,101
        DB	G_FLG,G_COPYF,101,101
        DB	G_FLG,G_COPYF,102,102
        DB	G_FLG,G_COPYF,4,103
        DB	G_FLG,G_COPYF,103,103
        DB	C_BLD,C_V_ON,3		;行く　消す
        DW	0000H
        
M2:		;見る　清美
        ;	DB	'一見、いつもと変わらないように見える。'
        DB	"It's Kiyomi. She looks the same as she always does."
        DW	0000H
        
M3:		;見る　清美
        ;	DB	'新藤さんは不安そうな目で、俺の次の言葉を待っている。'
        DB	"She's looking at me with anxiety written on her face."
        DW	0000H
        
M4:		;話す　清美１
        T_CG "CT02","W",0,15,2
        ;	DB	'【清美】：%001さん・・・単刀直入に申し上げます。'
        DB	"Kiyomi:  %001, I'm going to say what I have to say to you."
        DB	NEXT
        ;	DB	'そう言って、新藤さんは四角い包みを俺に差し出した。'
        DB	"She handed me a square package."
        DB	NEXT
        ;	DB	'【清美】：わたくしは、あなたが好きです。'
        DB	"Kiyomi:  I love you, %001."
        DB	NEXT
        ;	DB	'【%001】：新藤さん、俺を好きになってくれてありがとう。'
        DB	"%001:  Kiyomi, thank you..."
        DB	NEXT
        ;	DB	'【%001】：俺、とても嬉しいんだ。・・・だけど・・・'
        DB	"%001:  I'm really happy, really. But..."
        DB	NEXT
        ;	DB	'【清美】：・・・・・・'
        DB	"Kiyomi:  ................................."
        DB	NEXT
        ;	DB	'【%001】：新藤さん・・・一つだけ、俺の頼みを聞いてくれねえか？'
        DB	"%001:  Kiyomi, will you do one thing for me?"
        DB	NEXT
        ;	DB	'【清美】：どうぞ、何でもおっしゃって下さい。'
        DB	"Kiyomi:  Yes, of course. Anything."
        DB FLG,F_COPYI,1,1
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M5:		;話す　清美２
        ;	DB	'【%001】：出来たら・・・返事を待って欲しいんだ。一ヶ月後の、ホワイトデーまで。'
        DB	"%001:  I want you to wait for my answer. I'll give it to"
        DB	CR
        DB	"you in one month, on White Day."
        DB	NEXT
        K_CG "CT02","I",15,1
        ;	DB	'【鈴子】：え？'
        DB	"Kiyomi:  What?"
        DB	NEXT
        ;	DB	'【%001】：鈴子さんの他にも、俺を好きだって言ってくれる女の子がいる。'
        DB	"%001:  There are others who feel the same way as you."
        DB	NEXT
        ;	DB	'【鈴子】：！'
        DB	"Kiyomi:  .....I know that."
        DB	NEXT
        ;	DB	'【%001】：情けない話だけど、今の俺には分からないんだ。俺が一番に好きなのは誰かってことを。'
        DB	"%001:  I'm ashamed to say it, but I'm not sure yet...who"
        DB	CR
        DB	"I really love..."
        DB	NEXT
        ;	DB	'【%001】：俺、鈴子さんに好きって言ってもらって嬉しいんだ。この気持ちだけは、胸を張って言えるよ。'
        DB	"%001:  I'm really happy that you told me you loved me. "
        DB	CR
        DB	"I'll hold that in my heart forever."
        DB	NEXT
        ;	DB	'【%001】：こんな優柔不断でカナヅチの俺を好きでいてくれるなら・・・一ヶ月待ってくれ！'
        DB	"%001:  I'm sorry for being so indecisive. But please"
        DB	CR
        DB	"wait one more month!"
        DB	NEXT
        ;	DB	'【鈴子】：・・・'
        DB	"Kiyomi:  ......................."
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
        
M6:		;話す　清美３
        K_CG "CT02","K",15,3
        ;	DB	'【清美】：・・・分かりました。'
        DB	"Kiyomi:  .....Alright."
        DB	NEXT
        ;	DB	'【清美】：%001さんに・・・全てお任せ致します。'
        DB	"Kiyomi:  I'll wait, %001."
        DB	NEXT
        ;	DB	'【%001】：新藤さん・・・ありがとう。'
        DB	"%001:  Kiyomi, thank you."
        DB	NEXT
        ;	DB	'【清美】：%001さん・・・わたくし、いつまでもお待ちしております。'
        DB	"Kiyomi:  No, it's nothing. I'll wait forever, if you ask me."
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'・・・新藤さんは走っていった。'
        DB	".....Kiyomi runs off."
        DB	C_BLD,C_V_OFF,3		;行く　出し
        DB	C_BLD,C_V_ON,1		;見る　消し
        DB	C_BLD,C_V_ON,2		;話す　消し
        DB	FLG,F_COPYI,255,1
        DB	FLG,F_MAND,4,255,101,102,103
        DB	FLG,F_EXIT,255
        DB	NEXT
        SUDA_CLS
        ;	DB	'・・・これで、みんなから気持ちを受け取った。'
        DB	"....Now I've heard what everyone has to tell me."
        DB	NEXT
        ;	DB	'後は・・・俺が答えを出さなきゃならない。'
        DB	"Now...I've got to make up my mind which one I really love."
        DB	NEXT
        ;	DB	'・・・みんなの気持ちに、報いるために。'
        DB	"I owe that to all of them."
        DB	NEXT
        DB	SINARIO,'CSC01_.OVL',0
        DW	0000H
        
        
M7:		;行く　プール１
        ;	DB	'【%001】：鈴子さんが待ってる・・・'
        DB	"%001:  Reiko's waiting for me."
        DB	NEXT
        ;	DB	'俺はプールに向かった。'
        DB	"I head for the pool."
        DB	NEXT
        DB	SINARIO,'CSB05_A.OVL',0
        DW	0000H
        
M8:		;行く　プール２
        ;	DB	'鈴子さんとは、もう話した。'
        DB	"I've already talked to Reiko."
        DW	0000H
        
M9:		;行く　テニスコート
        ;	DB	'【%001】：美緒ちゃんが待ってる・・・'
        DB	"%001:  Mio's waiting for me."
        DB	NEXT
        ;	DB	'俺はテニスコートに向かった。'
        DB	"I head for the tennis courts."
        DB	NEXT
        DB	SINARIO,'CSB05_C.OVL',0
        DW	0000H
        
M10:		;行く　テニスコート
        ;	DB	'美緒ちゃんとは、もう話した。'
        DB	"I already talked to Mio."
        DW	0000H


end
