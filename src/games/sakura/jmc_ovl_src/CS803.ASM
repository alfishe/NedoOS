;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０３
;		体育祭３日前　恵依美＆星愛

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	-1
MSGTBL:
        DW	M1
COMTBL:
        DW	-1
VNTBL:
        DW	V_FNAME,N_FNAME
ENDTBL:

        INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
        INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群


;イニシャルメッセージ
M1:
        DB	BGM,6
        B_O B_SUDA
        BAK_INIT "AB_27_2"
        B_P1 B_SUDA
        ;	DB	'・・・・・・・・・・・・・・・・'
        DB	".............................................."
        DB	NEXT
        ;	DB	'【%001】：さて、後片付けも終わったし・・・帰るか。'
        DB	"%001:  Okay, I'm done here. Guess I'll go home." 
        DB	PAUSE
        B_O B_SUDA
        ;	DB	'・・・ふぁ～ぁ・・・'
        DB	" *YAWN*"
        DB	NEXT
        BAK_INIT "AB_03_3"
        DB BUF,B_COPY01
        T_CG "CT08","W",0,8,1
        ;	DB	'【恵依美】：・・・・・・・・・'
        DB	"Meimi:  ............................."
        DB	PAUSE
        ;	DB	'あ、%001。'
        DB	"%001?"
        DB	NEXT
        T_CG "CT07","W",0,32,2
        DB ANI,A_ON,1
        ;	DB	'【星愛】：・・・お待ちしてましたわ。'
        DB	"Seia:  We've been waiting for you."
        DB	NEXT
        ;	DB	'【%001】：・・・中野？'
        DB	"%001:  Meimi?"
        DB	PAUSE
        ;	DB	'それに吉田も。'
        DB	" And Seia."
        DB	PAUSE
        ;	DB	'どしたい、こんな時間に？'
        DB	" What are you two doing here?"
        DB	NEXT
        ;	DB	'【恵依美】：・・・うん・・・ちょっと、話したい事があって。'
        DB	"Meimi:  We wanted to talk to you."
        DB	NEXT
        ;	DB	'【%001】：話したい事？'
        DB	"%001:  What about?"
        DB	NEXT
        ;	DB	'【恵依美】：うん。'
        DB	"Meimi:  .........................................."
        DB	NEXT
        ;	DB	'【星愛】：こんなところで立ち話もなんですから、何処かでお食事でもしながらお話したいのですが。'
        DB	"Seia:  Can we go somewhere to talk? Someplace where we"
        DB	CR
        DB	"could eat dinner?"
        DB	NEXT
        ;	DB	'【%001】：・・・うーん・・・でもなあ・・・'
        DB	"%001:  Sure...I guess..."
        DB	NEXT
        ;	DB	'【恵依美】：もちろん、あたし達のおごりよ。'
        DB	"Meimi:  We'll treat you."
        DB	NEXT
        ;	DB	'【%001】：じゃあ行く。'
        DB	"%001:  Okay, let's go."
        DB	NEXT
        K_CG "CT07","K",32,3
        DB ANI,A_ON,1
        ;	DB	'【星愛】：くす・・・では参りましょうか。'
        DB	"Seia:  Well, let's go."
        DB	NEXT
        DB	SINARIO,'CS803_1.OVL',0
        DW	0000H


end
