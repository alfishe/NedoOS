;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｃ０１＿Ｆ
;		亜希に謝る
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
	DB	BGM,7
	BAK_INIT "AB_44"
	DB	BUF,B_COPY01
	T_CG "CT06","W",0,10,1
;	DB	'俺は屋上に来た。'
	DB	"I'm on the roof."
	DB	NEXT
;	DB	'【%001】：・・・亜希ちゃん・・・。'
	DB	"%001:  .....Aki..."
	DB	NEXT
;	DB	'【亜希】：あ、%001先輩。何か用？'
	DB	"Aki:  Ah, %001. Do you need anything?"
	DB	NEXT
;	DB	'【%001】：・・・・・・え？'
	DB	"%001:  ......What?"
	DB	NEXT
;	DB	'【亜希】：・・・ってのはジョーダンで、あれでしょ、一ヶ月前の約束。'
	DB	"Aki:  I'm kidding. I know why you're here. You're finally"
	DB	CR
	DB	"going to tell me, aren't you?"
	DB	NEXT
;	DB	'【%001】：・・・そうなんだ・・・俺・・・'
	DB	"%001:  ...........That's right. But I..."
	DB	NEXT
;	DB	'【亜希】：%001先輩、ちょっと言いにくいんだけど、あたし',CR,'棄権するわ。'
	DB	"Aki:  Before you say anything, I have to tell you something."
	DB	NEXT
;	DB	'【%001】：・・・・・・何だって？'
	DB	"%001:  ...What?"
	DB	NEXT
;	DB	'【亜希】：あたし、誠と付き合うことにしたの。'
	DB	"Aki:  I'm going out with Makoto."
	DB	NEXT
;	DB	'【%001】：へっ？！'
	DB	"%001:  What?!"
	DB	NEXT
;	DB	'【亜希】：あいつが「付き合ってくれないと死ぬぅ～」なんて土下座して頼むから、仕方なくね。'
	DB	"Aki:  He said he'd die without me, and begged me to be his"
	DB	CR
	DB	"girlfriend. What else could I do?"
	DB	NEXT
	T_CG1 "CT14","W",'D',28,3
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
	T_CG1 "CT14","W",0,28,4
;	DB	'【誠】：あ、いたのか%001。'
	DB	"Makoto:  Oh, %001. I didn't see you."
	DB	NEXT
	K_CG "CT14","K",28,5
;	DB	'【誠】：・・・・・・・・・まっ、そーいうわけだから。',CR,'じゃあな%001。'
	DB	"Makoto:  Well, that's the way things are. Take care,"
	DB	CR
	DB	"%001."
	DB	NEXT
;	DB	'【亜希】：バイバーイ！'
	DB	"Aki:  Bye, %001!"
	DB	NEXT
	B_P1 B_SUDA
;	DB	'・・・誠と亜希ちゃんは仲良く廊下を歩いていった。'
	DB	"......Makoto and Aki walk away together."
	DB	NEXT
;	DB	'【%001】：ちょ、ちょっと！'
	DB	"%001:  W- Wait a minute! Aki!"
	DB	NEXT
;	DB	'追いかけようとした俺は、後から肩を叩かれた。'
	DB	"I tried to chase after her, but a hand stopped me."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT13','F',0,0,20
;	DB	'【校長】：%001君。話は全て聞かせてもらった。'
	DB	"Dean:  Hello, son."
	DB	NEXT
;	DB	'【%001】：こ、校長先生？！'
	DB	"%001:  Dean!"
	DB	NEXT
;	DB	'【校長】：%001君・・・青春とは、二度とひっくり返らない砂時計の砂なのだ。'
	DB	"Dean:  %001, youth is like an hourglass. You can"
	DB	CR
	DB	"never stop the sand from falling. Let her go."
	DB	NEXT
;	DB	'【%001】：あ～もうわけわかんねーっ！'
	DB	"%001:  Let go of me! Aki!"
	DB	NEXT
	B_O B_WIPE
;	DB	'・・・これも自分の優柔不断が招いた不幸か。'
	DB	"........It was my own fault for not making up my mind"
	DB	CR
	DB	"sooner."
	DB	NEXT
;	DB	'ショックで呆けてる内に、俺はヒーローアクション部に入部させられていた。'
	DB	"While still recovering from the shock of it all, I was"
	DB	CR
	DB	"forced into the Action Hero Show club."
	DB	NEXT
;	DB	'【校長】：%001君、決めのポーズはこうだ！'
	DB	"Dean:  %001, you're on!"
	DB	NEXT
;	DB	'【%001】：はいっ先生！'
	DB	"%001:  Yes, sir!"
	DB	NEXT
;	DB	'【校長】：先生ではない！司令と呼びたまえ！'
	DB	"Dean:  Don't call me sir! Call me Commander!"
	DB	NEXT
;	DB	'【%001】：はいっ司令！'
	DB	"%001:  Yes, Commander!"
	DB	NEXT
;	DB	'最近、この環境が快感になりつつある。学校のみんなも楽しんでくれるし、俺の才能をフルに生かせるんだ。'
	DB	"But I'm getting used to it. The students love my performances,"
	DB	CR
	DB	"and I'm using my talents to their fullest."
	DB	NEXT
;	DB	'・・・さて、新入生の勧誘だ・・・。'
	DB	"Let's see... It's time to greet the incoming freshmen"
	DB	CR
	DB	"students."
	DB	NEXT
	DB	GAMEOVER
	DW	0000H

END
