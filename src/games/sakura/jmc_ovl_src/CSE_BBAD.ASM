;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　ＣＳＥ＿ＢＢＡＤ
;		清美バッドエンド

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
S2:		DW	VV2, NN1,  2, M3, M4, M5	;話す　清美２


;イニシャルメッセージ
M1:
	DB	BGM,18
	BAK_INIT 'AB_11_2'
	DB BUF,B_COPY01
	T_CG 'CT02','W',0,15,1
;	DB	'【清美】：%001さん・・・？'
	DB	"Kiyomi:  %001?"
	DB G_FLG,G_COPYF,167,167
	DW	0000H

M2:		;見る　清美
;	DB	'新藤さんはきょとんとした目で、俺を見ている。'
	DB	"She's looking at me with doubt in her eyes."
	DW	0000H

M3:		;話す　清美１
;	DB	'【%001】：新藤さん・・・俺・・・'
	DB	"%001:  Kiyomi, I....."
	DB	NEXT
;	DB	'【清美】：・・・なんですの・・・？'
	DB	"Kiyomi:  Yes?"
	DB FLG,F_COPYI,2,1
	DB FLG,F_EXIT,167
	DB FLG,F_COPYI,2,3
	DW	0000H

M4:		;話す　清美２
;	DB	'【%001】：・・・俺、新藤さんに大事な話があるんだ！'
	DB	"%001:  ....I've got something important to talk to you"
	DB	CR
	DB	"about!"
	DB	NEXT
;	DB	'【%001】：だから、き、今日新藤さんの家に行っていい？'
	DB	"%001:  So, can I go to your house tonight?"
	DB	NEXT
;	DB	'【清美】：ここじゃ出来ないような話なのでしょうか？'
	DB	"Kiyomi:  What do you have to say to me that can't be said"
	DB	CR
	DB	"here?"
	DB	NEXT
;	DB	'【%001】：その・・・バレンタインの・・・'
	DB	"%001:  You know.... Valentine's Day..."
	DB	NEXT
;	DB	'【清美】：・・・はぁ・・・？'
	DB	"Kiyomi:  ..........What??"
	DB	NEXT
;	DB	'【%001】：ほら、返事を１ヶ月待って欲しいって・・・'
	DB	"%001:  Remember, I told you I'd give you my answer in a"
	DB	CR
	DB	"month."
	DB	NEXT
;	DB	'【清美】：その事でしたら存じておりますわ。早く亜希さんのところに行ってあげて下さい。'
	DB	"Kiyomi:  I don't know anything about that. Why don't you"
	DB	CR
	DB	"go see Aki?  She's waiting for you."
	DB	NEXT
;	DB	'【%001】：お、俺は新藤さんが・・・！'
	DB	"%001:  But I love...!"
	DB	NEXT
;	DB	'【清美】：%001さん・・・クリスマスの夜、亜希さんと一緒にいらっしゃったのではないのですか？'
	DB	"Kiyomi:  %001, who were you with on Christmas Eve?"
	DB	NEXT
;	DB	'【%001】：！！！'
	DB	"%001:  !!!"
	DB	NEXT
;	DB	'【清美】：亜希さんからみんな聞きましたわ。'
	DB	"Kiyomi:  I heard all about it from Aki."
	DB	NEXT
;	DB	'【%001】：・・・え、ええっ！？'
	DB	"%001  .........What?!"
	DB	NEXT
;	DB	'【清美】：%001さん、わたくしお二人を応援致しますから。'
	DB	"Kiyomi:  I hope the two of you are happy...I really do."
	DB	NEXT
;	DB	'【%001】：し、新藤さん・・・！'
	DB	"%001:  ........Kiyomi!"
	DB	NEXT
	DB	FLG,F_JR
	DW	M_ENDE
	DW	0000H

M5:		;話す　清美３
;	DB	'【%001】：・・・俺、新藤さんに大事な話があるんだ！'
	DB	"%001:  ....I've got something important to talk to you"
	DB	CR
	DB	"about!"
	DB	NEXT
;	DB	'【%001】：だから、き、今日新藤さんの家に行っていい？'
	DB	"%001:  So, can I go to your house tonight?"
	DB	NEXT
;	DB	'【清美】：ここじゃ出来ないような話なのでしょうか？'
	DB	"Kiyomi:  What do you have to say to me that can't be said"
	DB	CR
	DB	"here?"
	DB	NEXT
;	DB	'【%001】：その・・・バレンタインの・・・'
	DB	"%001:  You know.... Valentine's Day..."
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  .................................."
	DB	NEXT
;	DB	'【%001】：ほら、返事を１ヶ月待って欲しいって・・・'
	DB	"%001:  Remember, I told you I'd give you my answer in a"
	DB	CR
	DB	"month."
	DB	NEXT
;	DB	'【清美】：その事ですか・・・。早くあの方のところに行ってあげて下さい。'
	DB	"Kiyomi:  I see. Please go to the one you really love,"
	DB	CR
	DB	"%001."
	DB	NEXT
;	DB	'【%001】：え・・・？！'
	DB	"%001:  What...?"
	DB	NEXT
;	DB	'【清美】：%001さんはきっとこうお考えになったのでしょう？',CR,'「自分はみんなに答を出すと約束した。だからみんなに言わなきゃいけない」って。'
	DB	"Kiyomi:  You told us a month ago to wait, and you'd make"
	DB	CR
	DB	"your decision clear."
	DB	NEXT
;	DB	'【%001】：そ、そうなんだ、だから・・・'
	DB	"%001:  Yes. That's why I'm here...!"
	DB	NEXT
;	DB	'【清美】：いいんです・・・わたくし、%001さんがずっとあの方を追いかけてらっしゃったことは存じておりましたから。'
	DB	"Kiyomi:  I don't care anymore. I know there's someone you"
	DB	CR
	DB	"love more than me."
	DB	NEXT
;	DB	'【%001】：・・・え、ええっ！？'
	DB	"%001:  .....What?!"
	DB	NEXT
	DB	FLG,F_JR
	DW	M_ENDE
	DW	0000H

M_ENDE:		
	K_CG 'CT02','K',15,7
;	DB	'【清美】：それでは、わたくし仕事がありますので。'
	DB	"Kiyomi:  Well, I've got to get back to work."
	DB	NEXT
	B_P1 B_TATE
;	DB	'新藤さんはにっこり微笑んで、走っていってしまった。'
	DB	"Kiyomi smiled once then went over to where the team"
	DB	CR
	DB	"was."
	DB	NEXT
;	DB	'【%001】：新藤さ～ん・・・！'
	DB	"%001:  Kiyomi...!!"
	DB	NEXT
;	DB	'追いかけようとした俺は、後から肩を叩かれた。'
	DB	"I went to chase after her, but a hand stopped me."
	DB	NEXT
	DB	BGM,28
	DB BUF,B_COPY01
	T_CG 'CT13','F','D',15,8
;	DB	'【校長】：%001君。話は全て聞かせてもらった。'
	DB	"Dean:  Hello, son!"
	DB	NEXT
;	DB	'【%001】：こ、校長先生？！'
	DB	"%001:  Dean!"
	DB	NEXT
;	DB	'【校長】：%001君・・・青春とは、二度とひっくり返らない砂時計の砂なのだ。'
	DB	"Dean:  %001, youth is like an hourglass. You can"
	DB	CR
	DB	"never stop the sand from falling. It's over, son."
	DB	NEXT
;	DB	'【%001】：あ～もうわけわかんねーっ！'
	DB	"%001:  Let go of me! Kiyomi!"
	DB	NEXT
	B_O B_WIPE
;	DB	'・・・これも自分の優柔不断が招いた不幸か。'
	DB	"........It was my own fault for not making up my mind sooner."
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



end
