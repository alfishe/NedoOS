;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０１＿Ｆ
;		亜希に謝る

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

;NN1:	DB	1,	'亜希',0
NN1:	DB	1,	'AKI',0
;NN2:	DB	2,	'プール',0
NN2:	DB	2,	'POOL',0
;NN3:	DB	3,	'グラウンド',0
NN3:	DB	3,	'BASEBALL FIELD',0
;NN4:	DB	4,	'テニスコート',0
NN4:	DB	4,	'TENNIS COURTS',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　亜希
S2:		DW	VV2, NN1,  2, M4, M5, M6		;話す　亜希３
S3:		DW	VV3, NN2,  3, M7, M8		;行く　プール２
S4:		DW	VV3, NN3,  4, M9, M10		;行く　グラウンド２
S5:		DW	VV3, NN4,  5, M11, M12		;行く　テニスコート２


;イニシャルメッセージ
M1:
        DB	BGM,7
        BAK_INIT "AB_44"
        DB	BUF,B_COPY01
        T_CG "CT06","W",0,10,1
        ;	DB	'俺は屋上に来た。'
        DB	"I'm on the roof."
        DB	NEXT
        ;	DB	'【%001】：・・・亜希ちゃん・・・。'
        DB	"%001:  ...Aki..."
        DB	NEXT
        DB	FLG,F_COPYI,104,1
        DB	G_FLG,G_COPYI,104,1
        DB	G_FLG,G_COPYF,3,101
        DB	G_FLG,G_COPYF,101,101
        DB	G_FLG,G_COPYF,4,102
        DB	G_FLG,G_COPYF,102,102
        DB	G_FLG,G_COPYF,5,103
        DB	G_FLG,G_COPYF,103,103
        DB	G_FLG,G_COPYF,199,199
        DB	G_FLG,G_COPYF,169,169
        DB	FLG,F_JGR,169
        DW	MAKOTO1
        ;	DB	'【亜希】：%001先輩・・・！'
        DB	"Aki:  %001!"
        DB	NEXT
        ;	DB	'亜希ちゃんが振り返った。'
        DB	"Aki turned around and looked at me."
        DB C_BLD,C_V_ON,3		;行く
        DB	FLG,F_CALLS,199
        DW	M_REIKO0,M_KIYOMI0,M_IO0,M_AKI
        DW	-1
        DW	0000H
        
M2:		;見る　亜希
        ;	DB	'亜希ちゃんは不安そうな目で、俺の言葉を待っている。'
        DB	"She's looking at me with a worried expression on her face."
        DW	0000H
        
M3:		;見る　亜希
        ;	DB	'亜希ちゃんは目に涙をためて、笑おうとしてる。'
        DB	"She forcing back her tears, trying to smile."
        DW	0000H
        
M4:		;話す　亜希１
        ;	DB	'【%001】：亜希ちゃん・・・俺・・・俺は・・・'
        DB	"%001:  Aki, I...."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・'
        DB	"Aki:  ....................."
        DB FLG,F_COPYI,2,1
        DW	0000H
        
M5:		;話す　亜希２
        ;	DB	'【%001】：俺は・・・俺は・・・'
        DB	"%001:  I....I don't know how to say this..."
        DB	NEXT
        K_CG 'CT06','D',10,2
        ;	DB	'【亜希】：はっきり言って先輩！'
        DB	"Aki:  Please, tell me!"
        DB	NEXT
        ;	DB	'【亜希】：覚悟は、出来てるから・・・！'
        DB	"Aki:  I... I'm ready for it!"
        DB	NEXT
        ;	DB	'【%001】：・・・俺は、亜希ちゃんとは・・・付き合えない。'
        DB	"%001:  .........I can't be your boyfriend."
        DB	NEXT
        ;	DB	'【亜希】：・・・やっぱり・・・あたしのこと、嫌いなんだ・・・'
        DB	"Aki:  I knew it. You hate me, don't you..."
        DB	NEXT
        ;	DB	'【%001】：違うよ！亜希ちゃんのことは、おてんばな妹みたいだって思ってる！・・・だけど・・・'
        DB	"%001:  No! That's not true! You're like a sister to me! I"
        DB	CR
        DB	"just..."
        DB	NEXT
        ;	DB	'【亜希】：・・・「妹」か・・・'
        DB	"Aki:  ...A sister?"
        DB FLG,F_COPYI,1,1
        DB FLG,F_COPYI,2,2
        DW	0000H
        
        
M6:		;話す　亜希３
        ;	DB	'【%001】：ごめん・・・。'
        DB	"%001:  .....I'm sorry."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・'
        DB	"Aki:  ...................."
        DB	NEXT
        T_CG 'CT06','W',0,10,2
        ;	DB	'【亜希】：・・・いいわ、「妹」で。'
        DB	"Aki:  It's alright. I'll be your sister if that's what you"
        DB	CR
        DB	"want."
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん・・・'
        DB	"%001:  Aki..."
        DB	NEXT
        ;	DB	'【亜希】：・・・よかった・・・あたし、%001先輩に嫌われてると思ったから・・・。'
        DB	"Aki:  I'm just glad you don't hate me, that's all."
        DB	NEXT
        ;	DB	'【%001】：前にも言ったろ、亜希ちゃんを嫌いになるわけないって。'
        DB	"%001:  I told you before! Why would I hate you?"
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・先輩・・・。'
        DB	"Aki:  .......%001...."
        DB	NEXT
        ;	DB	'【%001】：ん？'
        DB	"%001:  Yes?"
        DB	NEXT
        ;	DB	'【亜希】：・・・%001先輩が選んだ人って、誰なの？'
        DB	"Aki:  Who did you pick?"
        DB	NEXT
        DB	FLG,F_CALLS,199
        DW	M_REIKO,M_KIYOMI,M_IO,M_AKI
        DW	-1
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'亜希ちゃんは校舎内に走っていった。'
        DB	"Aki heads back inside."
        DB	C_BLD,C_V_OFF,3	;行く
        DB	C_BLD,C_V_ON,1	;見る
        DB	C_BLD,C_V_ON,2	;話す
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
        DB	"....Well, that's done."
        DB	NEXT
        ;	DB	'後は、俺の気持ちを伝えるだけだ・・・！'
        DB	"Now to reveal my feelings...!"
        DB	NEXT
        DB	FLG,F_CALLS,199
        DW	M_REIKO2,M_KIYOMI2,M_IO2,M_AKI
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
        DB	"I already talked to her. There's no point in going back."
        DW	0000H
        
M9:		;行く　グラウンド１
        ;	DB	'【%001】：新藤さんが待ってる・・・'
        DB	"%001:  Kiyomi's waiting for me."
        DB	NEXT
        ;	DB	'俺は野球部のグラウンドに向かった。'
        DB	"I head for the baseball field."
        DB	NEXT
        DB	SINARIO,'CSC01_B.OVL',0
        DW	0000H
        
M10:		;行く　グラウンド２
        ;	DB	'新藤さんには、もう会って来ただろ・・・。'
        DB	"I already talked to her. There's no need to go back."
        DW	0000H
        
M11:		;行く　テニスコート
        ;	DB	'【%001】：美緒ちゃんが待ってる・・・'
        DB	"%001:  Mio's waiting for me..."
        DB	NEXT
        ;	DB	'俺はテニスコートに向かった。'
        DB	"I head for the tennis courts."
        DB	NEXT
        DB	SINARIO,'CSC01_C.OVL',0
        DW	0000H
        
M12:		;行く　テニスコート２
        ;	DB	'美緒ちゃんの所には行けないだろ・・・。'
        DB	"That's not a good idea."
        DW	0000H
        
        
M_AKI:
        ;	DB	'【亜希】：・・・フラグがおかしいよ。'
        DB	"Your flag is screwed up"
        DW	0000H
        
M_REIKO0:
        DB C_BLD,C_N_ON,3,1		;行く　プール
        DW	0000H
        
M_REIKO:
        ;	DB	'【%001】：・・・鈴子さんだよ。'
        DB	"%001:  ....It's Reiko."
        DB	NEXT
        ;	DB	'【亜希】：・・・鈴子先輩かぁ・・・'
        DB	"Aki:  ......I see."
        DB	NEXT
        ;	DB	'【亜希】：はっきり言って、３年後のあたしの方がいい女だと思うけど、ま、仕方ないか。'
        DB	"Reiko:  But I have to tell you... When I'm her age, I plan"
        DB	CR
        DB	"to be an even greater woman than she is."
        DB	NEXT
        ;	DB	'【亜希】：・・・早く行ってあげたら？どうせまだ告白してないんでしょ！'
        DB	"Aki:  .......Why don't you go to her? I'll bet you haven't"
        DB	CR
        DB	"even told her how you felt yet."
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん・・・ありがとう。'
        DB	"%001:  Aki, thank you."
        DW	0000H
        
M_REIKO2:
        ;	DB	'俺は鈴子さんのいるプールに向かった。'
        DB	"I head for the pool."
        DB	NEXT
        DB SINARIO,'CSC02_A.OVL',0
        DW	0000H
        
M_KIYOMI0:
        DB C_BLD,C_N_ON,3,2		;行く　グラウンド
        DW	0000H
        
        
M_KIYOMI:
        ;	DB	'【%001】：・・・新藤さんだよ。'
        DB	"%001:  ......It's Kiyomi."
        DB	NEXT
        ;	DB	'【亜希】：・・・へぇ・・・清美先輩かぁ・・・。'
        DB	"Aki:  ...I see."
        DB	NEXT
        ;	DB	'【亜希】：・・・%001先輩には、もったいない相手よね。',CR,'せいぜい大事にしなさいよ。'
        DB	"Aki:  %001, she's almost too good for you. Make sure you"
        DB	CR
        DB	"take care of her."
        DB	NEXT
        ;	DB	'【%001】：・・・ありがとう、亜希ちゃん・・・。'
        DB	"%001:  ......Thanks, Aki."
        DW	0000H
        
M_KIYOMI2:
        ;	DB	'俺は新藤さんの待つ、野球部のグラウンドに向かった。'
        DB	"I head for the baseball field."
        DB	NEXT
        DB SINARIO,'CSC02_B.OVL',0
        DW	0000H
        
M_IO0:
        DB C_BLD,C_N_ON,3,3	;行く　テニスコート
        DW	0000H
        
M_IO:
        ;	DB	'【%001】：・・・美緒ちゃんだよ。'
        DB	"%001:  It's Mio."
        DB	NEXT
        ;	DB	'【亜希】：・・・ちぇ、また負けちゃったな・・・。'
        DB	"Aki:  What? You mean I lost to her again?"
        DB	NEXT
        ;	DB	'【亜希】：フンだ、今度テニスでコテンパンに負かしてやるから！先輩、しっかりなぐさめてあげるのよ！'
        DB	"Aki:  Hmph! I'll teach her to steal men from me, the next"
        DB	CR
        DB	"time I get her on the tennis court!"
        DB	NEXT
        DB	"Aki:  .......But take good care of her, will you?"
        DB	NEXT
        ;	DB	'【%001】：ありがとう、亜希ちゃん・・・。'
        DB	"%001:  Thanks, Aki."
        DW	0000H
        
M_IO2:
        ;	DB	'俺は美緒ちゃんの待つ、テニスコートに向かった。'
        DB	"I head for the tennis courts."
        DB	NEXT
        DB SINARIO,'CSC02_C.OVL',0
        DW	0000H
        
MAKOTO1:
        ;	DB	'【亜希】：あ、%001先輩。何か用？'
        DB	"Aki:  %001? What's up?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・え？'
        DB	"%001:  What?"
        DB	NEXT
        K_CG 'CT06','K',10,3
        ;	DB	'【亜希】：・・・ってのはジョーダンで、あれでしょ、一ヶ月前の約束。'
        DB	"Aki:  I'm kidding. I know why you're here. You're finally"
        DB	CR
        DB	"going to tell me, aren't you?"
        DB	NEXT
        ;	DB	'【%001】：・・・そうなんだ・・・俺・・・'
        DB	"%001:  ...That's right. But I..."
        DB	NEXT
        ;	DB	'【亜希】：%001先輩、ちょっと言いにくいんだけど、あたし',CR,'棄権するわ。'
        DB	"Aki:  Before you say anything, I have to tell you"
        DB	CR
        DB	"something."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・何だって？'
        DB	"%001:  .....What?"
        DB	NEXT
        ;	DB	'【亜希】：あたし、誠と付き合うことにしたの。'
        DB	"Aki:  I'm going out with Makoto."
        DB	NEXT
        ;	DB	'【%001】：へっ？！'
        DB	"%001:  What?!"
        DB	NEXT
        ;	DB	'【亜希】：あいつが「付き合ってくれないと死ぬぅ～」なんて土下座して頼むから、仕方なくね。'
        DB	"Aki:  He said he'd die without me, and begged me to be"
        DB	CR
        DB	"his girlfriend. What else could I do?"
        DB	NEXT
        DB BUF,B_COPY01
        TU_CG 'CT14','W','D',30,8
        T_CG 'CT06','W','K',10,3
        DB ANI,A_ON,8
        ;	DB	'【誠】：・・・誰が土下座したって？'
        DB	"Makoto:  I didn't exactly beg!"
        DB	NEXT
        ;	DB	'【亜希】：遅～い！レディを何分待たせれば気が済むのよ！'
        DB	"Aki:  You're late! Don't you know it's impolite to keep"
        DB	CR
        DB	"a lady waiting!"
        DB	NEXT
        ;	DB	'【誠】：誰がレディだよ、誰が。'
        DB	"Makoto:  Lady? I don't see any ladies around here."
        DB	NEXT
        ;	DB	'【亜希】：さ、行くわよ誠。あんたがぼやぼやしてるから、',CR,'こんな時間になっちゃったじゃない！'
        DB	"Aki:  Let's go, Makoto. You've made us late as it is."
        DB	NEXT
        ;	DB	'【誠】：サバ研の活動で忙しかったんだよ。'
        DB	"Makoto:  I was busy with survival training!"
        DB	NEXT
        DB BUF,B_COPY01
        TU_CG 'CT14','W',0,30,7
        T_CG 'CT06','W','K',10,3
        DB ANI,A_ON,7
        ;	DB	'【誠】：あ、いたのか%001。'
        DB	"Makoto:  Oh, %001. I didn't see you."
        DB	NEXT
        DB BUF,B_COPY01
        TU_CG 'CT14','W','K',30,6
        T_CG 'CT06','W','K',10,3
        DB ANI,A_ON,6
        ;	DB	'【誠】：・・・・・・・・・まっ、そーいうわけだから。',CR,'じゃあな%001。'
        DB	"Makoto:  ....And so, I'm going out with Aki now. I'll see"
        DB	CR
        DB	"you later!"
        DB	NEXT
        ;	DB	'【亜希】：バイバーイ！'
        DB	"Aki:  Bye, %001!"
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'・・・誠と亜希ちゃんは仲良く廊下を歩いていった。'
        DB	"Makoto and Aki leave, hand in hand."
        DB	NEXT
        ;	DB	'【%001】：ちょっと釈然としないものが残るんだが・・・'
        DB	"%001:  I didn't expect that to happen."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・ま、いいか。'
        DB	"%001:  Well.....I'm happy for them."
        ;DB	NEXT
        DB	FLG,F_CALLS,199
        DW	M_REIKO0,M_KIYOMI0,M_IO0,M_AKI
        DW	-1
        DB	C_BLD,C_V_OFF,3	;行く
        DB	C_BLD,C_V_ON,1	;見る
        DB	C_BLD,C_V_ON,2	;話す
        DB	FLG,F_PLUS,255,101
        DB	FLG,F_PLUS,255,102
        DB	FLG,F_PLUS,255,103
        DB	FLG,F_PLUS,255,104
        DB	FLG,F_COMPI,255,255,2
        DB	FLG,F_JGR,255
        DW	HEKETON
        DW	0000H



end
