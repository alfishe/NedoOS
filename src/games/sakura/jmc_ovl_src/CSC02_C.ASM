;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０２＿Ｃ
;		美緒に会う

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

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	'MIO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　美緒
S2:		DW	VV2, NN1,  2, M3, M4, M5		;話す　美緒３


;イニシャルメッセージ
M1:
        DB	BGM,19
        BAK_INIT "AB_12_2"
        B_P1 B_SUDA
        ;	DB	'俺はテニスコートにやって来た。'
        DB	"I'm at the tennis courts"
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT03","W",0,15,1
        ;	DB	'【%001】：・・・み、美緒ちゃん・・・！'
        DB	"%001:  ........M- Mio?"
        DB	NEXT
        DB G_FLG,G_COPYF,110,110
        DB G_FLG,G_COPYF,120,120
        DB G_FLG,G_COPYF,130,130
        DB G_FLG,G_COPYF,160,160
        DB G_FLG,G_COPYF,167,167
        DB FLG,F_JGR,167
        DW	M_AKI
        DB FLG,F_COMP,255,130,110	;美緒－鈴子
        DB FLG,F_CALI,255,20	;温情修正
        DB FLG,F_JLW,255
        DW	M_AKI
        DB FLG,F_COMP,254,130,120	;美緒－清美
        DB FLG,F_CALI,254,20	;温情修正
        DB FLG,F_JLW,254
        DW	M_AKI
        DB FLG,F_COMP,253,130,160	;美緒－亜希
        DB FLG,F_CALI,253,20	;温情修正
        DB FLG,F_JLW,253
        DW	M_AKI
        ;	DB	'【美緒】：%001先輩！・・・来てくれたんだ・・・。'
        DB	"Mio:  %001! I've been waiting for you..."
        DW	0000H
        
M2:		;見る　美緒
        ;	DB	'美緒ちゃんはもじもじしながら、俺の言葉を待っている。'
        DB	"She's looking at me with worry in her eyes."
        DW	0000H
        
M3:		;話す　美緒１
        ;	DB	'【%001】：美緒ちゃん・・・あのさ・・・'
        DB	"%001:  Mio, I.......um....."
        DB	NEXT
        K_CG "CT03","R",15,1
        ;	DB	'【美緒】：・・・何・・・？'
        DB	"Mio:  ............Yes?"
        DB FLG,F_COPYI,2,1
        DW	0000H
        
M4:		;話す　美緒２
        ;	DB	'【%001】：そ、そうだ美緒ちゃん、高等部合格おめでとう！'
        DB	"%001:  Um, isn't it nice to be done with finals?"
        DB	NEXT
        ;	DB	'【美緒】：うん、新藤先輩達が勉強教えてくれたから・・・。'
        DB	"Mio:  I guess.... Why?"
        DB	NEXT
        ;	DB	'【%001】：じゃ、来年から同じ高校だな！'
        DB	"%001:  Oh, no reason."
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M5:		;話す　美緒３
        ;	DB	'【%001】：・・・俺、美緒ちゃんに大事な話があるんだ！'
        DB	"%001:  I've got something to talk to you about!"
        DB	NEXT
        ;	DB	'【%001】：ちょっと付き合ってくれねーか？'
        DB	"%001:  Will you come with me?"
        DB	NEXT
        ;	DB	'【美緒】：う、うん！'
        DB	"Mio:  Okay!"
        DB	NEXT
        DB	SINARIO,'CSC03_C.OVL',0
        DW	0000H
        
M_AKI:
        DB	SINARIO,'CSE_CBAD.OVL',0
        DW	0000H

end
