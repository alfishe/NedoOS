;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０２＿Ａ
;		鈴子に会う

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

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子
S2:		DW	VV2, NN1,  2, M3, M4		;話す　鈴子２


;イニシャルメッセージ
M1:
        DB	BGM,29
        BAK_INIT "AB_23"
        DB	BUF,B_COPY01
        T_CG "CT01","W","R",15,1
        ;	DB	'俺はプールにやって来た。'
        DB	"I'm at the pool."
        DB	NEXT
        ;	DB	'【%001】：・・・れ、鈴子さん・・・！'
        DB	"%001:  Reiko...!"
        DB	NEXT
        DB G_FLG,G_COPYF,110,110
        DB G_FLG,G_COPYF,120,120
        DB G_FLG,G_COPYF,130,130
        DB G_FLG,G_COPYF,160,160
        DB G_FLG,G_COPYF,167,167
        DB FLG,F_JGR,167
        DW	M_AKI
        DB FLG,F_COMP,255,110,120	;鈴子－清美
        DB FLG,F_CALI,255,20	;温情修正
        DB FLG,F_JLW,255
        DW	M_AKI
        DB FLG,F_COMP,254,110,130	;鈴子－美緒
        DB FLG,F_CALI,254,20	;温情修正
        DB FLG,F_JLW,254
        DW	M_AKI
        DB FLG,F_COMP,253,110,160	;鈴子－亜希
        DB FLG,F_CALI,253,20	;温情修正
        DB FLG,F_JLW,253
        DW	M_AKI
        ;	DB	'【鈴子】：%001君・・・待ってたわ。'
        DB	"Reiko:  %001.... I've been waiting for you."
        DW	0000H
        
M2:		;見る　鈴子
        ;	DB	'鈴子さんは不安そうな目で、俺の言葉を待っている。'
        DB	"She's looking at me with worry in her eyes."
        DW	0000H
        
M3:		;話す　鈴子１
        ;	DB	'【%001】：鈴子さん・・・俺・・・'
        DB	"%001:  R- Reiko, I....."
        DB	NEXT
        ;	DB	'【鈴子】：・・・なに・・・？'
        DB	"Reiko:  .....Yes?"
        DB FLG,F_COPYI,2,1
        DW	0000H
        
M4:		;話す　鈴子２
        ;	DB	'【%001】：・・・俺、鈴子さんに大事な話があるんだ！'
        	DB	"%001:  I've got to talk to you about something!"
        DB	NEXT
        ;	DB	'【%001】：だから、き、今日鈴子さんの家に行っていい？'
        DB	"%001:  C- Can I come over to your house today?"
        DB	NEXT
        ;	DB	'【鈴子】：い、いいわよ！'
        DB	"Reiko:  Sure, that'd be fine..."
        DB	NEXT
        ;	DB	'【%001】：そ、それじゃ鈴子さん、また後で・・・'
        DB	"%001:  W- Well, then, I'll see you later..."
        DB	NEXT
        ;	DB	'【鈴子】：あ、私ならもうヒマよ！？だから一緒に帰れるけど・・・'
        DB	"Reiko:  I'm free now! Shall we go home together....?"
        DB	NEXT
        ;	DB	'【%001】：じゃっじゃあ、帰ろうか鈴子さん。'
        DB	"%001:  U- Um, okay, let's go, then."
        DB	NEXT
        ;	DB	'【鈴子】：そうね、帰りましょう%001君！'
        DB	"Reiko:  Okay. Let's go home, %001."
        DB	NEXT
        ;	DB	'俺は鈴子さんと２人で、ぎこちない空気を背負いながら鈴子さんの家に行った。'
        DB	"Still trying to put my nervousness behind me, I started"
        DB	CR
        DB	"walking with Reiko."
        DB	NEXT
        DB	SINARIO,'CSC03_A.OVL',0
        DW	0000H
        
M_AKI:
        DB	SINARIO,'CSE_ABAD.OVL',0
        DW	0000H

end
