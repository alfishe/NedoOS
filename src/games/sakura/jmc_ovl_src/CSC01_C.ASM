;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０１＿Ｃ
;		美緒に謝る
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

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	'MIO',0
;NN2:	DB	2,	'プール',0
NN2:	DB	2,	'POOL',0
;NN3:	DB	3,	'グラウンド',0
NN3:	DB	3,	'BASEBALL FIELD',0
;NN4:	DB	4,	'屋上',0
NN4:	DB	4,	'ROOF',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　美緒
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7		;話す　美緒４
S3:		DW	VV3, NN2,  3, M8, M9		;行く　プール２
S4:		DW	VV3, NN3,  4, M10, M11		;行く　グラウンド２
S5:		DW	VV3, NN4,  5, M12, M13		;行く　屋上２


;イニシャルメッセージ
M1:
        DB	BGM,15
        BAK_INIT "AB_12_2"
        B_P1 B_SUDA
        ;	DB	'俺はテニスコートに来た。'
        DB	"I'm at the tennis courts."
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT03","W",'R',15,1
        ;	DB	'【美緒】：%001先輩・・・！'
        DB	"Mio:  .....%001!"
        DB	NEXT
        ;	DB	'美緒ちゃんは目ざとく俺を見つけて、走って来た。'
        DB	"Noticing I was there, Mio ran over to me."
        DB	NEXT
        ;	DB	'【%001】：・・・美緒ちゃん・・・ちょっと来てくれ。'
        DB	"%001:  .....Mio, come over here."
        DB	NEXT
        T_CG "CT03","W",0,15,2
        ;	DB	'【美緒】：・・・%001先輩？'
        DB	"Mio: ........%001?"
        DB	G_FLG,G_COPYI,103,1
        DB	G_FLG,G_COPYF,3,101
        DB	G_FLG,G_COPYF,101,101
        DB	G_FLG,G_COPYF,4,102
        DB	G_FLG,G_COPYF,102,102
        DB	FLG,F_COPYI,103,1
        DB	G_FLG,G_COPYF,5,104
        DB	G_FLG,G_COPYF,104,104
        DB	G_FLG,G_COPYF,199,199
        DB C_BLD,C_V_ON,3	;行く
        DB	FLG,F_CALLS,199
        DW	M_REIKO0,M_KIYOMI0,M_IO,M_AKI0
        DW	-1
        DW	0000H
        
M2:		;見る　美緒
        ;	DB	'美緒ちゃんは不安そうな目で、俺の言葉を待っている。'
        DB	"She's got a worried expression on her face."
        DW	0000H
        
M3:		;見る　美緒
        ;	DB	'美緒ちゃんは泣いてる・・・'
        DB	"She's crying...."
        DW	0000H
        
M4:		;話す　美緒１
        ;	DB	'【%001】：美緒ちゃん・・・俺・・・俺は・・・'
        DB	"%001:  Mio, I.......I...."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・'
        DB	"Mio:  ......................."
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M5:		;話す　美緒２
        ;	DB	'【%001】：俺は・・・俺は・・・'
        DB	"%001:  .......I.........."
        DB	NEXT
        K_CG "CT03",'I',15,3
        ;	DB	'【美緒】：・・・先輩・・・'
        DB	"Mio:  What?"
        DB	NEXT
        ;	DB	'【%001】：・・・俺は、美緒ちゃんと・・・付き合えない。'
        DB	"%001:  .....I'm sorry, Mio. I can't be your boyfriend."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・あたしのこと・・・嫌いなの？'
        DB	"Mio:  Do you....hate me?"
        DB	NEXT
        ;	DB	'【%001】：違うよ！美緒ちゃんのことは、本当の妹みたいだって思ってたんだ！・・・だけど・・・'
        DB	"%001:  No! That's not it at all! You're like a little"
        DB	CR
        DB	"sister to me! I just..."
        DB	NEXT
        ;	DB	'【美緒】：・・・あたしは「妹」なの？・・・',CR,'・・・%001先輩の「恋人」にはなれないの？'
        DB	"Mio:  ..........I'm like......sister?",PAUSE," Can't I be your"
        DB	CR
        DB	"girlfriend?"
        DB FLG,F_COPYI,1,1
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
        
M6:		;話す　美緒３
        ;	DB	'【%001】：ごめん・・・。'
        DB	"%001:  I'm sorry."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・・・・'
        DB	"Mio:  ......................"
        DB	NEXT
        ;	DB	'【美緒】：%001先輩・・・あたし、妹でもいい・・・'
        DB	"Mio:  %001, I don't mind being like a sister to you."
        DB	NEXT
        ;	DB	'【%001】：美緒ちゃん・・・。'
        DB	"%001:  Mio..........."
        DB	NEXT
        ;	DB	'【美緒】：・・・その代わり、一つだけワガママ言わせて・・'
        DB	"Mio:  But will you just...do one thing for me?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・ああ。'
        DB	"%001:  Sure."
        DB	NEXT
        ;	DB	'美緒ちゃんは、俺の胸にぎゅっと顔を押し付けて来た。'
        DB	"Mio embraced me, then, her face pressing against my chest."
        DB	NEXT
        ;	DB	'【美緒】：・・・しばらく・・・このままでいさせて・・・。'
        DB	"Mio:  Can we stay like this for...just a little while?"
        DB	NEXT
        ;	DB	'【%001】：・・・いいとも・・・'
        DB	"%001:  Alright."
        DB	NEXT
        ;	DB	'美緒ちゃんの肩が小刻みに上下し、押し殺した鳴咽が洩れてくる。'
        DB	"Mio's shoulders shook as her sobs came, then."
        DB	NEXT
        ;	DB	'俺はそっと美緒ちゃんの頭を撫でた。'
        DB	"I did my best to hold her."
        DB	FLG,F_COPYI,2,3
        DW	0000H
        
M7:		;話す　美緒４
        ;	DB	'しばらくすると、美緒ちゃんは俺から離れた。'
        DB	"After a time, Mio moved away from me."
        DB	NEXT
        ;	DB	'【美緒】：・・・%001先輩が選んだ人って、誰なの？'
        DB	"Mio:  .....*sniff* Who did you choose, anyway?"
        DB	NEXT
        DB	FLG,F_CALLS,199
        DW	M_REIKO,M_KIYOMI,M_IO,M_AKI
        DW	-1
        B_P1 B_SUDA
        ;	DB	'美緒ちゃんはテニスコートに走っていった。'
        DB	"Mio runs back to the tennis courts."
        DB	C_BLD,C_V_OFF,3		;行く
        DB	C_BLD,C_V_ON,1		;見る
        DB	C_BLD,C_V_ON,2		;話す
        DB	FLG,F_PLUS,255,101
        DB	FLG,F_PLUS,255,102
        DB	FLG,F_PLUS,255,103
        DB	FLG,F_PLUS,255,104
        DB	FLG,F_COMPI,255,255,2
        DB	FLG,F_JGR,255
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
        DW	M_REIKO2,M_KIYOMI2,M_IO,M_AKI2
        DW	-1
        DW	0000H
        
M8:		;行く　プール１
        ;	DB	'【%001】：鈴子さんが待ってる・・・'
        DB	"%001:  Reiko's waiting for me."
        DB	NEXT
        ;	DB	'俺はプールに向かった。'
        DB	"I head for the pool."
        DB	NEXT
        DB	SINARIO,'CSC01_A.OVL',0
        DW	0000H
        
M9:		;行く　プール２
        ;	DB	'鈴子さんには、今会って来ただろ・・・。'
        DB	"I already talked to her. There's no need to go back."
        DW	0000H
        
M10:		;行く　グラウンド１
        ;	DB	'【%001】：新藤さんが待ってる・・・'
        DB	"%001:  Kiyomi's waiting for me."
        DB	NEXT
        ;	DB	'俺は野球部のグラウンドに向かった。'
        DB	"I head for the baseball field."
        DB	NEXT
        DB	SINARIO,'CSC01_B.OVL',0
        DW	0000H
        
M11:		;行く　グラウンド２
        ;	DB	'新藤さんには、もう会って来ただろ・・・。'
        DB	"I already talked to Kiyomi. There's no point in going back."
        DW	0000H
        
M12:		;行く　屋上
        ;	DB	'【%001】：亜希ちゃんが待ってる・・・'
        DB	"%001:  Aki's waiting for me."
        DB	NEXT
        ;	DB	'俺は屋上に向かった。'
        DB	"I head for the roof of the school."
        DB	NEXT
        DB	SINARIO,'CSC01_F.OVL',0
        DW	0000H
        
M13:		;行く　屋上２
        ;	DB	'また会っても、亜希ちゃんを傷つけるだけだ。'
        DB	"I'll only hurt her if I go back."
        DW	0000H
        
        
        
M_IO:
        ;	DB	'【美緒】：・・・フラグがおかしいよ。'
        DB	"Your flag is wrong"
        DW	0000H
        
M_KIYOMI0:
        DB C_BLD,C_N_ON,3,2		;行く　グラウンド
        DW	0000H
        
        
M_KIYOMI:
        ;	DB	'【%001】：・・・新藤さんだよ。'
        DB	"%001:  ..........It's Kiyomi."
        DB	NEXT
        ;	DB	'【美緒】：・・・清美先輩かぁ・・・。'
        DB	"Mio:  .........I see."
        DB	NEXT
        ;	DB	'【美緒】：・・・%001先輩・・・清美先輩を、幸せにしてあげて。'
        DB	"Mio:  %001, please try to make her happy, alright?"
        DB	NEXT
        ;	DB	'【%001】：・・・ありがとう、美緒ちゃん・・・。'
        DB	"%001:  Thank you, Mio."
        DW	0000H
        
M_KIYOMI2:
        ;	DB	'俺は新藤さんの待つ、野球部のグラウンドに向かった。'
        DB	"I head for the baseball field."
        DB	NEXT
        DB SINARIO,'CSC02_B.OVL',0
        DW	0000H
        
M_REIKO0:
        DB C_BLD,C_N_ON,3,1		;行く　プール
        DW	0000H
        
M_REIKO:
        ;	DB	'【%001】：・・・鈴子さんだよ。'
        DB	"%001:  ........It's Reiko."
        DB	NEXT
        ;	DB	'【美緒】：・・・鈴子先輩かぁ・・・'
        DB	"Mio:  .........I see."
        DB	NEXT
        ;	DB	'【美緒】：先輩って、ムネの大きな人が好きなの？'
        DB	"Mio:  Did you choose her because her breasts are big?"
        DB	NEXT
        ;	DB	'【%001】：え゛！？'
        DB	"%001:  What?!"
        DB	NEXT
        DB ANI,A_INIT
        K_CG "CT03",'K',15,5
        ;	DB	'【美緒】：ジョーダン、ジョーダンだってば！'
        DB	"Mio:  I'm kidding!"
        DB	NEXT
        ;	DB	'【美緒】：・・・鈴子先輩だったら、仕方ないな・・・許してあげる。'
        DB	"Mio:  ......I couldn't compete with Reiko. I forgive you."
        DB	NEXT
        ;	DB	'【%001】：美緒ちゃん・・・ありがとう。'
        DB	"%001:  Thank you, Mio."
        DW	0000H
        
M_REIKO2:
        ;	DB	'俺は鈴子さんのいるプールに向かった。'
        DB	"I head off for the pool."
        DB	NEXT
        DB SINARIO,'CSC02_A.OVL',0
        DW	0000H
        
M_AKI0:
        DB C_BLD,C_N_ON,3,3		;行く　屋上
        DW	0000H
        
M_AKI:
        ;	DB	'【%001】：・・・亜希ちゃんだよ。'
        DB	"%001:  ......It's Aki."
        DB	NEXT
        ;	DB	'【美緒】：・・・亜希ちゃんかぁ・・・大事な勝負で、負けちゃったな・・・。'
        DB	"Mio:  .....I see. I lost the most important competition"
        DB	CR
        DB	"I ever had with her..."
        DB	NEXT
        ;	DB	'【美緒】：・・・%001先輩・・・亜希ちゃんをよろしくね。'
        DB	"Mio:  .......Please take good care of her, alright?"
        DB	NEXT
        ;	DB	'【%001】：ありがとう、美緒ちゃん・・・。'
        DB	"%001:  Thank you, Mio."
        DW	0000H
        
M_AKI2:
        ;	DB	'俺は亜希ちゃんの待つ、屋上に向かった。'
        DB	"I head for the roof."
        DB	NEXT
        DB SINARIO,'CSC02_F.OVL',0
        DW	0000H
        
        
        
        

end
