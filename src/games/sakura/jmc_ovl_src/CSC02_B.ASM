;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０２＿Ｂ
;		清美に会う

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
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	'KIYOMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　清美
S2:		DW	VV2, NN1,  2, M3, M4		;話す　清美２


;イニシャルメッセージ
M1:
        DB	BGM,18
        BAK_INIT "AB_11_2"
        DB	BUF,B_COPY01
        T_CG "CT02","W",0,15,1
        ;	DB	'俺は野球部のグラウンドにやって来た。'
        DB	"I'm at the baseball field."
        DB	NEXT
        ;	DB	'【%001】：・・・し、新藤さん・・・！'
        DB	"%001:  ..........K- Kiyomi?"
        DB	NEXT
        DB G_FLG,G_COPYF,110,110
        DB G_FLG,G_COPYF,120,120
        DB G_FLG,G_COPYF,130,130
        DB G_FLG,G_COPYF,160,160
        DB G_FLG,G_COPYF,167,167
        DB FLG,F_JGR,167		;亜希クリスマス
        DW	M_AKI
        DB FLG,F_COMP,255,120,110	;清美－鈴子
        DB FLG,F_CALI,255,20	;温情修正
        DB FLG,F_JLW,255
        DW	M_AKI
        DB FLG,F_COMP,254,120,130	;清美－美緒
        DB FLG,F_CALI,254,20	;温情修正
        DB FLG,F_JLW,254
        DW	M_AKI
        DB FLG,F_COMP,253,120,160	;清美－亜希
        DB FLG,F_CALI,253,20	;温情修正
        DB FLG,F_JLW,253
        DW	M_AKI
        ;	DB	'【清美】：%001さん！・・・お待ちしておりましたわ。'
        DB	"Kiyomi:  %001! I've been waiting for you."
        DW	0000H
        
M2:		;見る　清美
        ;	DB	'新藤さんは何かを期待するような目で、俺の言葉を待っている。'
        DB	"She's looking at me with worry in her eyes."
        DW	0000H
        
M3:		;話す　清美１
        ;	DB	'【%001】：新藤さん・・・あのさ・・・'
        DB	"%001:  Kiyomi..... I, um..."
        DB	NEXT
        ;	DB	'【清美】：・・・何ですの・・・？'
        DB	"Kiyomi:  ......Yes?"
        DB FLG,F_COPYI,2,1
        DW	0000H
        
M4:		;話す　清美２
        ;	DB	'【%001】：・・・俺、新藤さんに大事な話があるんだ！'
        DB	"%001:  I....I've got something important to talk to you"
        DB	CR
        DB	"about!"
        DB	NEXT
        ;	DB	'【%001】：だから、き、今日新藤さんの家に行っていいか？'
        DB	"%001:  So, can I go to your house later?"
        DB	NEXT
        K_CG "CT02","R",15,2
        ;	DB	'【清美】：もちろんですわ！'
        DB	"Kiyomi:  Of course!"
        DB	NEXT
        ;	DB	'【%001】：そ、それじゃ新藤さん、また後で・・・'
        DB	"%001:  Okay, well, I'll see you later, then..."
        DB	NEXT
        ;	DB	'【清美】：いいえ、今すぐ参りましょう。'
        DB	"Kiyomi:  %001, shall we go to my house now?"
        DB	NEXT
        ;	DB	'【%001】：で、でも、まだ野球部の練習が・・・。'
        DB	"%001:  But you've got baseball practice, and..."
        DB	NEXT
        ;	DB	'【清美】：大丈夫ですわ、わたくし選手ではありませんもの。'
        DB	"Kiyomi:  It's alright. I'm just the manager. I don't have"
        DB	CR
        DB	"to practice."
        DB	NEXT
        ;	DB	'【%001】：そか。じゃあ問題ねーな。（←そうか？）'
        DB	"%001:  Oh. Well, in that case..."
        DB	NEXT
        ;	DB	'【清美】：さあ、参りましょう%001さん。'
        DB	"Kiyomi:  Shall we go?"
        DB	NEXT
        ;	DB	'【%001】：ああ。'
        DB	"%001:  Sure."
        DB	NEXT
        ;	DB	'俺は新藤さんと２人で、ぎこちない空気を背負いながら新藤さんの家に行った。'
        DB	"I leave the baseball field with Kiyomi."
        DB	NEXT
        DB	SINARIO,'CSC03_B.OVL',0
        DW	0000H
        
M_AKI:
        DB	SINARIO,'CSE_BBAD.OVL',0
        DW	0000H



end
