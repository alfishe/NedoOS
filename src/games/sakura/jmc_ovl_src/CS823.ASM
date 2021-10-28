;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２３
;		人のかたち、亜希のかたち

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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'亜希',0
NN1:	DB	1,	'AKI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　亜希２
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7, M8, M9, M10, M11, M12		;話す　亜希９
S3:		DW	VV3, -1,  3, M13, M14, M15		;考える３


;イニシャルメッセージ
M1:
	DB	BGM,7
	B_O B_SUDA
;	DB	'【%001】：・・・ふう。スッキリした。'
	DB	"%001:  Wow, I really had to go bad."
	DB	NEXT
	E_CG B_SUDA,"AE_031"
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  .................................."
	DB	NEXT
;	DB	'【%001】：あれ？亜希ちゃんじゃないか？'
	DB	"%001:  Well, hi there, Aki."
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  .................................."
	DW	0000H

M2:		;見る　亜希１
;	DB	'何だかもじもじして、上目使いに俺を見ている。'
	DB	"Something seems wrong with her."
	DB	NEXT
;	DB	'・・・ものすご～く、亜希ちゃんのイメージにそぐわない。'
	DB	"Why is she so quiet all of the sudden?"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　亜希２
;	DB	'いつもの象が踏んでも壊れそうにない雰囲気は何処かに消えて、'
;	DB	'ちょっと触ったら折れそうだ。'
	DB	"She's always so strong, so sure of herself."
	DB	NEXT
;	DB	'（・・・亜希ちゃんって、こんなに華奢だっけ・・・？）'
	DB	"But now she looks like a scared little girl."
	DW	0000H

M4:		;話す　亜希１
;	DB	'【%001】：どしたい、こんなとこで？'
	DB	"%001:  What's the matter?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  .................................."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　亜希２
;	DB	'【%001】：・・・俺に、用があるんだろ？'
	DB	"%001:  Do you need anything?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  .................................."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　亜希３
;	DB	'【%001】：・・・どしたい、らしくないぞ。いつもの亜希ちゃんは、'
;	DB	'もっと元気だぜ？'
	DB	"%001:  This isn't like you at all. What's the matter?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  .................................."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M7:		;話す　亜希４
;	DB	'【%001】：・・・・・・俺は、いつもの亜希ちゃんの方が好きだけどな。'
;	DB	'元気が有り余るくらいいっぱいの、いつもの亜希ちゃんがさ。'
	DB	"%001:  .......I have to say, I think I like the old Aki"
	DB	CR
	DB	"better, violent nature and all."
	DB	NEXT
;	DB	'【亜希】：・・・・・・！'
	DB	"Aki:  .....................!!"
	DB	FLG,F_COPYI,2,4
	DW	0000H

M8:		;話す　亜希５
;	DB	'【%001】：・・・話してみな？誰にも言わないから。'
	DB	"%001:  Can you tell me what the problem is? I'll keep it"
	DB	CR
	DB	"a secret, I promise."
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ................................."
	DB	PAUSE
;	DB	'あの・・・ね、%001先輩。'
	DB	"Um..."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Yes?"
	DB	FLG,F_COPYI,2,5
	DW	0000H

M9:		;話す　亜希６
;	DB	'【亜希】：・・・・・・この間は、ありがとう。'
	DB	"Aki:  Thank you..... for what you did for me."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  Are you talking about what happened at the sports"
	DB	CR
	DB	"festival?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ....................."
	DB	PAUSE
;	DB	'うん。'
	DB	"Yes."
	DB	FLG,F_COPYI,2,6
	DW	0000H

M10:		;話す　亜希７
;	DB	'【%001】：・・・な～に、いいんだよ。'
	DB	"%001:  Oh, that was nothing."
	DB	PAUSE
;	DB	'俺は、ホントの事を言っただけさ。'
	DB	" I just told everyone what"
	DB	CR
	DB	"really happened."
	DB	NEXT
;	DB	'【亜希】：・・・・・・でも！'
	DB	"Aki:  ...........That's not true!"
	DB	PAUSE
;	DB	'アレじゃ先輩が悪者になっちゃうよ！'
	DB	" You took the blame for me!"
	DB	CR
	DB	"Now everyone'll think badly of you!"
	DB	FLG,F_COPYI,2,7
	DW	0000H

M11:		;話す　亜希８
;	DB	'【%001】：・・・なあ、亜希ちゃん。'
	DB	"%001:  Aki..."
	DB	PAUSE
;	DB	'俺、悪者扱されてたか？'
	DB	"Did it look like everyone was blaming me for"
	DB	CR
	DB	"anything?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ...................................."
	DB	PAUSE
;	DB	'ううん。'
	DB	"I guess not."
	DB	NEXT
;	DB	'【%001】：なら、それでいいじゃないか。'
	DB	"%001:  Then there's no problem."
	DB	NEXT
;	DB	'【亜希】：でも・・・！'
	DB	"Aki:  Yes, but.....!!"
	DB	FLG,F_COPYI,2,8
	DW	0000H

M12:		;話す　亜希９
;	DB	'【%001】：・・・じゃあ、こうしよう。'
	DB	"%001:  Let's do this..."
	DB	NEXT
;	DB	'【%001】：来年、また俺と組もう。'
	DB	"%001:  Next year, you be my partner again."
	DB	PAUSE
;	DB	'今度はちゃんと練習して・・・ブッチ切りで勝ってやろうぜ。'
	DB	" We'll get in a"
	DB	CR
	DB	"lot of practice, and rip everyone else to shreds."
	DB	NEXT
;	DB	'【亜希】：・・・先輩・・・'
	DB	"Aki:  ......%001."
	DB	NEXT
;	DB	'【%001】：それなら・・・納得してくれるだろ？みんなも、君も。'
	DB	"%001:  Okay? Then everyone will know the truth."
	DB	NEXT
;	DB	'【亜希】：・・・・・・先輩・・・・・・！'
	DB	"Aki:  ...........Okay."
	DB	NEXT
;	DB	'【%001】：じゃあな・・・来年、楽しみにしてるぜ。'
	DB	"%001:  So we have a date, right? For next year."
	DB	NEXT
;	DB	'俺は亜希ちゃんの頭をポンポンと叩くと、鈴子さん達のところへ戻って行った。'
	DB	"I squeezed her shoulder and went back into Reiko's classroom."
	DB	NEXT
	B_O B_SUDA
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"..................................."
	DB	NEXT
;	DB	'【亜希】：・・・・・・先輩・・・・・・ありがとう・・・・・・'
	DB	"Aki:  .........%001..."
	DB	NEXT
	DB G_FLG,G_COPYF,160,160
	DB FLG,F_CALI,160,20
	DB G_FLG,G_COPYG,160,160
	DB	SINARIO,'CS825.OVL',0
	DW	0000H

M13:		;考える１
;	DB	'この間から、ど～も様子が変なんだよな。'
	DB	"She's been acting strangely for a while."
	DB	NEXT
;	DB	'・・・・・・やっぱり、体育祭の時の事なんだろうな。'
	DB	"It must be because of what happened at the sports"
	DB	CR
	DB	"festival."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M14:		;考える２
;	DB	'亜希ちゃんって、プライドの塊だからなぁ・・・あの負けが、よっぱど'
;	DB	'ショックだったんだろう。'
	DB	"Aki has a lot of pride. I'm sure she was shocked at"
	DB	CR
	DB	"losing the way she did."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M15:		;考える３
;	DB	'亜希ちゃんは負けず嫌いだけど、真っ直ぐないい子だ。'
	DB	"Aki doesn't like to lose. That's a very good quality in"
	DB	CR
	DB	"a woman."
	DW	0000H


end
