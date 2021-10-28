;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０３＿Ｃ
;		美緒に告白

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3
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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'深呼吸',0
VV1:	DB	1,	'BREATH DEEPLY',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'キス',0
VV3:	DB	3,	'KISS',0

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	'MIO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3		;深呼吸
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7		;話す　美緒
S3:		DW	VV3, -1,  3, M8		;キス


;イニシャルメッセージ
M1:
        DB	BGM,19
        BAK_INIT "AB_46"
        DB	BUF,B_COPY01
        T_CG "CT03","W","R",15,1
        ;	DB	'俺は美緒ちゃんと、裏庭の桜の下までやってきた。'
        DB	"Mio and I go to the sakura tree behind the school, where we"
        DB	CR
        DB	"first met."
        DB	NEXT
        ;	DB	'【%001】：も、もうすぐ、桜が咲くね・・・'
        DB	"%001:  Th- The cherry blossoms will be in bloom again soon..."
        DB	NEXT
        ;	DB	'【美緒】：うん・・・'
        DB	"Mio:  You're right."
        DB	C_BLD,C_V_ON,1		;深呼吸　消し
        DB	C_BLD,C_V_ON,3		;キス　消し
        DW	0000H
        
M2:		;深呼吸
        ;	DB	'すぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅ'
        DB	"In.............."
        DB	NEXT
        ;	DB	'はぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁ'
        DB	"And out.........."
        DB	NEXT
        ;	DB	'・・・・・・'
        DB	"..................................."
        DB	NEXT
        ;	DB	'（落ち着け・・・）'
        DB	"I've got to calm down!"
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
        
M3:		;深呼吸
        ;	DB	'すぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅぅ'
        DB	"In.........."
        DB	NEXT
        ;	DB	'はぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁぁ'
        DB	"And out.........."
        DB	NEXT
        ;	DB	'・・・・・・'
        DB	".................................."
        DB	NEXT
        ;	DB	'（よし・・・落ち着いたぞ・・・）'
        DB	"That's better. I'm calm now."
        DB	FLG,F_COPYI,2,1
        DB	C_BLD,C_V_ON,1		;深呼吸　消し
        DW	0000H
        
        
M4:		;話す　美緒
        ;	DB	'【%001】：みっっ美緒ちゃおっおれ・・・'
        DB	"%001:  M- Mio.... I w- want to t-t-talk to y-you..."
        DB	NEXT
        ;	DB	'【美緒】：な、何、先輩？'
        DB	"Mio:  What? I can't understand you."
        DB	NEXT
        ;	DB	'（だあ、ロレツが回ってない！）'
        DB	"Shit! I've got to get ahold of myself!"
        DB	C_BLD,C_V_OFF,1		;深呼吸　出し
        DW	0000H
        
        
M5:		;話す　美緒
        ;	DB	'【%001】：美緒ちゃん。'
        DB	"%001:  Mio."
        DB	NEXT
        ;	DB	'【美緒】：はいっ！'
        DB	"Mio:  Yes?"
        DB	NEXT
        ;	DB	'【%001】：覚えてるかな・・・俺たちが初めて会って声を交わしたのは、この木の下だったよね。'
        DB	"%001:  Do you remember the first time we met, under this"
        DB	CR
        DB	"tree?"
        DB	NEXT
        ;	DB	'【美緒】：・・・先輩も、覚えててくれたんだ！'
        DB	"Mio:  You remembered that moment, too? I'm so happy!"
        DB	NEXT
        ;	DB	'【%001】：ああ、印象が強かったから・・・。'
        DB	"%001:  Yes, I do. I think about it often."
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M6:		;話す　美緒
        ;	DB	'【%001】：今年も、去年と同じ桜が咲こうとしてる。だけど、俺は去年の俺じゃない。'
        DB	"%001:  It's just like it was last year, with the sakura"
        DB	CR
        DB	"about to bloom. But I'm not the same person I was last year."
        DB	NEXT
        ;	DB	'【%001】：俺には分かるようになったんだ。'
        DB	"%001:  I've learned a lot..."
        DB	PAUSE
        ;	DB	'・・・自分の能力を出し惜しみしてても、いいことはないってことが。'
        DB	" About myself, and about more."
        DB	NEXT
        ;	DB	'【美緒】：先輩・・・'
        DB	"Mio:  %001..."
        DB	FLG,F_COPYI,2,3
        DW	0000H
        
        
M7:		;話す　美緒
        ;	DB	'【%001】：他人の目を気にして、全力を出さない様にするなんて、傲慢だって事が・・・'
        DB	"%001:  It's just stupid to not push yourself to your full"
        DB	CR
        DB	"potential just because you don't want to stand out."
        DB	NEXT
        ;	DB	'【%001】：何事も全力でやるからこそ、面白いんだって事が。'
        DB	"%001:  Life's only interesting when you try as hard as "
        DB	CR
        DB	"you can at everything you do."
        DB	NEXT
        ;	DB	'【%001】：・・・美緒ちゃんは俺にそれを教えてくれた。'
        DB	"%001:  .....You taught me that, Mio."
        DB	NEXT
        ;	DB	'【%001】：美緒ちゃんが俺を心から応援してくれて・・・心から喜んでくれるから、俺は全力で戦えるんだ。'
        DB	"%001:  You always rooted for me, supported me with all"
        DB	CR
        DB	"your heart... That enabled me to try my best."
        DB	NEXT
        ;	DB	'【美緒】：・・・'
        DB	"Mio:  ..........."
        DB	NEXT
        ;	DB	'【%001】：美緒ちゃん。これからも、俺の側にいて欲しい。'
        DB	"%001:  Mio, I want you to be by my side."
        DB	PAUSE
        ;	DB	'君が・・・好きだ。'
        DB	" I love you."
        DB	NEXT
        K_CG "CT03","I",15,2
        ;	DB	'【美緒】：・・・%001先輩・・・！'
        DB	"Mio:  ......%001!"
        DB	NEXT
        ;	DB	'美緒ちゃんの頬を、大粒の涙がぽろぽろと溢れ落ちる。'
        DB	"Tears started welling up in Mio's eyes."
        DB	NEXT
        ;	DB	'【美緒】：あれ、おかしいな？・・・うれしいのに・・・すっごくうれしいのに・・・'
        DB	"Mio:  What? That's strange. I'm really happy...but for"
        DB	CR
        DB	"some reason..."
        DB	NEXT
        ;	DB	'【美緒】：涙が、止まらないよ・・・'
        DB	"Mio:  I can't stop crying!"
        DB	C_BLD,C_V_OFF,3		;キス　出し
        DB	C_BLD,C_V_ON,2		;話す　消し
        DW	0000H
        
M8:		;キス
        ;	DB	'俺は美緒ちゃんの肩をそっと引き寄せた。'
        DB	"I took Mio by the shoulders and pulled her close to me."
        DB	NEXT
        ;	DB	'美緒ちゃんは目をつぶって、顔を空に向ける。'
        DB	"She closed her eyes, and lifted her face up towards mine."
        DB	NEXT
        ;	DB	'・・・・・・そして、俺の唇に柔らかくて甘い感触がひろがった。'
        DB	"Then the kiss was all we knew."
        DB	NEXT
        DB	SINARIO,'CSE_C_1.OVL',0
        DW	0000H
        

end
