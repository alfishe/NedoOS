;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｂ０５＿Ｆ
;		亜希のチョコ

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
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7		;話す　亜希
S3:		DW	VV3, NN2,  3, M8		;行く　プール
S4:		DW	VV3, NN3,  4, M9		;行く　グラウンド
S5:		DW	VV3, NN4,  5, M10		;行く　テニスコート


;イニシャルメッセージ
M1:
        DB	BGM,13
        BAK_INIT "AB_44"
        DB	BUF,B_COPY01
        T_CG "CT06","W","R",15,1
        ;	DB	'俺は亜希ちゃんに、屋上に連れて来られた。'
        DB	"Aki takes me up to the roof."
        DB	G_FLG,G_COPYF,2,169	;話す　亜希
        DB	C_BLD,C_V_ON,3		;行く　消す
        DW	0000H
        
M2:		;見る　亜希
        ;	DB	'今までの勢いが嘘みたいにもじもじしてる・・・'
        DB	"She's silent all of the sudden. It's hard to believe she's"
        DB	CR
        DB	"so loud all the time."
        DB	NEXT
        ;	DB	'やっぱ、あれかな・・・'
        DB	"I guess she's going to..."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　亜希
        ;	DB	'亜希ちゃんは不安そうな目で、俺の次の言葉を待っている。'
        DB	"She's looking at me with worried eyes."
        DW	0000H
        
M4:		;話す　亜希１(G169=0)
        ;	DB	'【亜希】：%001先輩！これ・・・受け取って下さいっ！'
        DB	"Aki:  %001, please take this!"
        DB	NEXT
        ;	DB	'そう言って、亜希ちゃんは宅配ピザの箱ほどもある包みを俺に差し出した。'
        DB	"She hands me a beautful package as large as a pizza box."
        DB	NEXT
        ;	DB	'【亜希】：先輩には迷惑だと思うけど・・・あたし、%001先輩が、好きです！'
        DB	"Aki:  I'm sure I'm only causing trouble for you by saying"
        DB	CR
        DB	"this to you, but..... I love you!"
        DB	NEXT
        ;	DB	'【%001】：迷惑だなんてとんでもない。嬉しいよ、亜希ちゃん。'
        DB	"%001:  You're causing trouble for me, Aki. I'm really"
        DB	CR
        DB	"happy."
        DB	NEXT
        DB	"Aki:  ......Really?"
        DB	NEXT
        ;	DB	'【%001】：本当だよ。だけど・・・一つだけ、俺の頼みを聞いてくれないか？'
        DB	"%001:  Yes. But will you do one thing for me?"
        DB	NEXT
        ;	DB	'【亜希】：・・・'
        DB	"Aki:  ..................."
        DB FLG,F_COPYI,2,2	;話す　亜希３へ
        DW	0000H
        
M5:		;話す　亜希２(G169=1)
        ;	DB	'【亜希】：%001先輩！これ・・・受け取って下さいっ！'
        DB	"Aki:  %001, please take this!"
        DB	NEXT
        ;DB	'そう言って、亜希ちゃんは宅配ピザの箱ほどもある包みを俺に差し出した。'
        DB	"She hands me a beautful package as large as a pizza box."
        DB	NEXT
        ;	DB	'【%001】：ありがとう。嬉しいよ、亜希ちゃん。'
        DB	"%001:  Thank you, Aki. I'm really happy."
        DB	NEXT
        ;	DB	'【亜希】：・・・本当？'
        DB	"Aki:  .........Really?"
        DB	NEXT
        ;	DB	'【%001】：本当だよ。だけど・・・一つだけ、俺の頼みを聞いてくれないか？'
        DB	"%001:  Yes. But will you do one thing for me?"
        DB	NEXT
        ;	DB	'【亜希】：・・・'
        DB	"Aki:  ..................."
        DB	NEXT
        ;	DB	'【%001】：出来たら・・・返事を待って欲しいんだ。一ヶ月後の、ホワイトデーまで。'
        DB	"%001:  I want you to wait for my answer. I'll give it to"
        DB	CR
        DB	"you in one month, on White Day."
        DB	NEXT
        ;	DB	'【亜希】：・・・どうして・・・？'
        DB	"Aki:  ....Why?"
        DB	NEXT
        ;	DB	'【%001】：鈴子さんの他にも、俺を好きだって言ってくれる女の子がいる。'
        DB	"%001:  There are others who have to tell me what you"
        DB	CR
        DB	"just told me."
        DB	NEXT
        ;	DB	'【亜希】：・・・それって、美緒のこと？'
        DB	"Aki:  ......You mean Mio, don't you?"
        DB	NEXT
        ;	DB	'【%001】：情けない話だけど、今の俺には分からないんだ。俺が一番に好きなのは誰かってことを。'
        DB	"%001:  I'm ashamed to say it, but I'm not sure yet... "
        DB	CR
        DB	"who I really love..."
        DB	NEXT
        ;	DB	'【%001】：俺、鈴子さんに好きって言ってもらって嬉しいんだ。この気持ちだけは、胸を張って言えるよ。'
        DB	"%001:  I'm really happy that you told me you loved me."
        DB	CR
        DB	"I'll hold that in my heart forever."
        DB	NEXT
        ;	DB	'【%001】：こんな優柔不断でカナヅチの俺を好きでいてくれるなら・・・一ヶ月待ってくれ！'
        DB	"%001:  I'm sorry for being so indecisive. But please"
        DB	CR
        DB	"wait one month!"
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・わかったわ。',CR,'その代わり、あたしの頼みも聞いてくれる？'
        DB	"Aki:  .....Okay.",PAUSE," In return, will you do"
        DB	CR
        DB	"something for me?"
        DB	NEXT
        ;	DB	'【%001】：ああ。'
        DB	"%001:  Sure."
        DB	NEXT
        ;	DB	'【亜希】：これ、島崎に渡してくれないかな。'
        DB	"Aki:  Give this to Makoto?"
        DB	NEXT
        ;	DB	'そう言って、亜希ちゃんは俺にくれた奴より遥かに小さな包みを差し出した。'
        DB	"She handed me another package, much smaller than the"
        DB	CR
        DB	"one she gave me."
        DB	NEXT
        ;	DB	'【%001】：誠に？'
        DB	"%001:  To Makoto?"
        DB	NEXT
        ;	DB	'【亜希】：も、もちろん義理よ、義理！'
        DB	"Aki:  Y- Yes! I just don't want him to feel bad."
        DB	NEXT
        ;	DB	'【亜希】：直接渡してる所を知り合いにでも見られて、',CR,'「本命」だなんて勘違いされたらイヤだから、お願い！'
        DB	"Aki:  If anyone saw me give it to him, they might get the"
        DB	CR
        DB	"wrong idea about us."
        DB	NEXT
        ;	DB	'【%001】：・・・だったら、下駄箱にでも入れてけばいいじゃないか。'
        DB	"%001:  Why didn't you put it in his shoes locker?"
        DB	NEXT
        ;	DB	'【亜希】：それもなんか本気っぽくてヤだ。'
        DB	"Aki:  Everyone does that. Someone would think I was"
        DB	CR
        DB	"really in love with him."
        DB	NEXT
        ;	DB	'【亜希】：それじゃ、お願いね。'
        DB	"Aki:  Well, thanks for giving it to him for"
        DB	CR
        DB	"me."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・先輩、あたし、待ってるから。'
        DB	"Aki:  .....I'll wait for your answer in a month."
        DB	NEXT
        ;	DB	'【亜希】：・・・ホワイトデーも・・・ここに来てね。'
        DB	"Aki:  Come here on White Day."
        DB	NEXT
        SUDA_CLS
        ;	DB	'そう言って、亜希ちゃんは校舎内に戻っていった。'
        DB	"Aki runs inside the school building."
        DB	NEXT
        ;	DB	'【%001】：・・・しょうがねーな・・・っても、俺だって直接手渡しするのはイヤだぞ。'
        DB	"%001:  .....I guess I'll go give Makoto his chocolate. "
        DB	NEXT
        ;	DB	'【%001】：誠だって泣いて嫌がるに違いない。う～む・・・'
        DB	"%001:  He'll probably cry or something stupid like that."
        DB	NEXT
        ;	DB	'【%001】：そうだ、今日子先生に頼んでみよう。それなら誠も喜ぶぞ。'
        DB	"%001:  I know! I'll ask Kyoko-sensei to give it to him for me."
        DB	C_BLD,C_V_OFF,3		;行く　出し
        DB	C_BLD,C_V_ON,1		;見る　消し
        DB	C_BLD,C_V_ON,2		;話す　消し
        DW	0000H
        
        
        
M6:		;話す　亜希３(G169=0)
        ;	DB	'【%001】：出来たら・・・返事を待って欲しいんだ。一ヶ月後の、ホワイトデーまで。'
        DB	"%001:  I want you to wait for my answer. I'll give it to"
        DB	CR
        DB	"you in one month, on White Day."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・'
        DB	"Aki:  .................."
        DB	NEXT
        ;	DB	'【%001】：これから俺は・・・別の女の子に会いに行く。約束してるんだ。'
        DB	"%001:  I have to go meet the other girls."
        DB	NEXT
        DB ANI,A_OFF
        T_CG "CT06","W","D",15,2
        ;	DB	'【亜希】：イヤ！'
        DB	"Aki:  No!"
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん！？'
        DB	"%001:  Aki?"
        DB	NEXT
        ;	DB	'【亜希】：何よ、嬉しいって言ってくれたじゃない！何で他の子に会いに行くの！？'
        DB	"Aki:  You just told me you were happy when I said I loved"
        DB	CR
        DB	"you! Why are you going to go see the others now?"
        DB	NEXT
        ;	DB	'【亜希】：行かないで！今ここであたしを抱き締めてよ！'
        DB	"Aki:  Don't go! Please, stay here with me...!"
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん・・・'
        DB	"%001:  Aki...."
        DB	NEXT
        ;	DB	'【%001】：情けない話だけど、今の俺には分からないんだ。俺が一番に好きなのは誰かってことを。'
        DB	"%001:  I'm ashamed to say it, but I'm not sure yet...who"
        DB	CR
        DB	"I really love..."
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃんに好きだって言われて、正直、嬉しいんだ。だけど・・・亜希ちゃんを一番に好きなのか、まだ俺には分からない。'
        DB	"%001:  I was really happy when you told me you loved me."
        DB	CR
        DB	"But I'm just not sure what to do yet."
        DB	NEXT
        ;	DB	'【%001】：こんな優柔不断でカナヅチの俺を好きでいてくれるなら・・・一ヶ月待ってくれ！'
        DB	"%001:  I'm sorry for being so indecisive. But please"
        DB	CR
        DB	"wait one month!"
        DB	NEXT
        ;	DB	'【亜希】：・・・'
        DB	"Aki:  ......................"
        DB	FLG,F_COPYI,2,3
        DW	0000H
        
        
M7:		;話す　亜希４(G169=0)
        ;	DB	'【亜希】：・・・・・・・・さっさと行けばいいでしょ・・・'
        DB	"Aki:  ..........Then go."
        DB	NEXT
        ;	DB	'【亜希】：本当はあたしなんか嫌いなんでしょ！だったら最初からそう言えばいいじゃない！'
        DB	"Aki:  You really hate me, don't you? If so, then you"
        DB	CR
        DB	"should come right out and say it!"
        DB	NEXT
        ;	DB	'【亜希】：どうせ美緒のところに行くんでしょ！あたしのことなんかほっといて行きなさいよ！
        DB	"Aki:  I know you really love Mio! Why don't you go to her?"
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん・・・'
        DB	"%001:  Aki....."
        DB	NEXT
        ;	DB	'【%001】：・・・ごめんな。'
        DB	"%001:  .....I'm sorry."
        DB	NEXT
        ;	DB	'俺は校舎内に引き返・・・'
        DB	"I moved to go back inside the school building."
        B_P1 B_SUDA
        DB	PAUSE
        ;	DB	'・・・そうとした時、背中から抱きつかれた。'
        DB	"....when"
        DB	CR
        DB	"suddenly she embraced me from behind."
        DB	NEXT
        ;	DB	'【亜希】：ごめんなさい！'
        DB	"Aki:  I'm sorry!"
        DB	NEXT
        ;	DB	'【亜希】：あたしのこと嫌いにならないで！'
        DB	"Aki:  Don't hate me, please!"
        DB	NEXT
        ;	DB	'【亜希】：あたし、待つから・・・先輩のこと、待つから・・'
        DB	"Aki:  I'll wait for you! I'll always wait for you!"
        DB	NEXT
        ;	DB	'【亜希】：だから、嫌いにならないで！'
        DB	"Aki:  Just...don't hate me!"
        DB	NEXT
        ;	DB	'【亜希】：嫌いにならないで・・・！'
        DB	"Aki:  Please... *sob*"
        DB	NEXT
        ;	DB	'・・・後は、嗚咽にしかならなかった。'
        DB	"The rest was unintelligible."
        DB	NEXT
        ;	DB	'【%001】：嫌いになんか、なるわけないだろ。'
        DB	"%001:  I promise, I'll never hate you."
        DB	NEXT
        ;	DB	'【亜希】：ひぐっ・・・ひぐっ・・・'
        DB	"Aki:  ....*sob*........*sob*........"
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん・・・笑ってくれよ。俺は・・・その、笑顔の亜希ちゃんが・・・好きだから。'
        DB	"%001:  Aki, smile for me. I love it when you smile."
        DB	NEXT
        ;	DB	'【亜希】：・・・ひっく・・・・・・'
        DB	"Aki:  ......*sob*..............."
        DB	NEXT
        ;	DB	'【亜希】：今笑えなんて言ったって無理よ・・・',CR,'あたしのヒドイ顔、先輩に見られたくないから、行って。'
        DB	"Aki:  I don't think I can. I don't want you to see my face"
        DB	CR
        DB	"right now, so go, would you? They're waiting."
        DB	NEXT
        ;	DB	'【亜希】：・・・早く行ってあげて。美緒、きっと待ちくたびれてるわ。'
        DB	"Aki:  ........Go to them. Mio's waiting for you."
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん・・・'
        DB	"%001:  Aki....."
        DB	NEXT
        ;	DB	'【亜希】：ほら早く！ぼやぼやしてないで！あたしはもうしばらくここで頭冷やしてから帰るから！'
        DB	"Aki:  Don't just stand there, go!"
        DB	NEXT
        SUDA_CLS
        ;	DB	'【%001】：とっとっ・・・'
        DB	"%001:  ..............."
        DB	NEXT
        ;	DB	'俺は亜希ちゃんに、屋上から締め出された。'
        DB	"I start to walk back inside the building."
        DB	NEXT
        ;	DB	'【亜希】：・・・ホワイトデー・・・ここで待ってるから。'
        DB	"Aki:  I'll be waiting here...on White Day..."
        DB	NEXT
        ;	DB	'【%001】：・・・ありがとう・・・分かってくれて・・・'
        DB	"%001:  ....Thank you, Aki. Please understand."
        DB	C_BLD,C_V_OFF,3		;行く　出し
        DB	C_BLD,C_V_ON,1		;見る　消し
        DB	C_BLD,C_V_ON,2		;話す　消し
        DW	0000H
        
M8:		;行く　プール
        ;	DB	'【%001】：鈴子さんが待ってる・・・'
        DB	"%001:  Reiko's waiting for me."
        DB	NEXT
        ;	DB	'俺はプールに向かった。'
        DB	"I head for the pool."
        DB	NEXT
        DB	SINARIO,'CSB05_A.OVL',0
        DW	0000H
        
M9:		;行く　グラウンド
        ;	DB	'【%001】：新藤さんが待ってる・・・'
        DB	"Kiyomi's waiting for me."
        DB	NEXT
        ;	DB	'俺は野球部のグラウンドに向かった。'
        DB	"I head for the tennis courts."
        DB	NEXT
        DB	SINARIO,'CSB05_B.OVL',0
        DW	0000H
        
M10:	;行く　テニスコート
        ;	DB	'【%001】：美緒ちゃんが待ってる・・・'
        DB	"%001:  Mio's waiting for me."
        DB	NEXT
        ;	DB	'俺はテニスコートに向かった。'
        DB	"I head for the tennis courts."
        DB	NEXT
        DB	SINARIO,'CSB05_C.OVL',0
        DW	0000H


end
