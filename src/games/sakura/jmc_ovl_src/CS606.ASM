;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０６
;		臨海学校二日目

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN3,-1
CM4:	DW	VV4,	NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0
;VV4:	DB	4,	'行く',0
VV4:	DB	4,	"GO",0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	"KIYOMI",0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	"SKY",0
;NN3:	DB	3,	'鈴子',0
NN3:	DB	3,	"REIKO",0
;NN4:	DB	4,	'貸しボート屋',0
NN4:	DB	4,	"BOAT RENTAL",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　清美
S2:		DW	VV1, NN2,  2, M3		;見る　空
S3:		DW	VV2, NN1,  3, M4, M5, M6		;話す　清美
S4:		DW	VV3, NN3,  4, M7		;考える　鈴子
S5:		DW	VV4, NN4,  5, M8		;行く　貸しボート屋


;イニシャルメッセージ
M1:
	DB	BGM,2
	BAK_INIT 'AB_17_1'
	B_P1 B_FADE
;	DB	'翌日。'
	DB	"........The next day."
	DB	NEXT
;	DB	'俺は鈴子さんに合わせる顔が無くて、ぼんやりと歩いていた。'
	DB	"I was so ashamed of what I'd done to Reiko, that I couldn't"
	DB	CR
	DB	"face her. I walked around aimlessly."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','M',0,10,1
;	DB	'【清美】：%001さん。'
	DB	"Kiyomi:  %001."
	DB	NEXT
;	DB	'【%001】：あ、新藤さん。'
	DB	"%001:  Oh, Kiyomi."
	DB C_BLD,C_V_ON,4	;行く
	DW	0000H

M2:		;見る　清美
;	DB	'何か俺に用があるようだ。'
	DB	"She looks like she wants something from me."
	DW	0000H

M3:		;見る　空
;	DB	'青い空に白い雲・・・泳げる奴にとっては絶好の水泳日和だ。'
	DB	"White clouds in the blue sky...an ideal day for people"
	DB	CR
	DB	"who can swim."
	DW	0000H

M4:		;話す　清美
;	DB	'【清美】：%001さん、今日も泳ぎの練習をなさるのですか？'
	DB	"Kiyomi:  %001, are you having your swimming lessons again",CR,"today?"
	DB	NEXT
;	DB	'【%001】：いやー、全然上達しないし、鈴子さんに迷惑かけるし、やめとくわ。'
	DB	"%001:  Nah, I'm not getting any better. I was just being"
	DB	CR
	DB	"a pain to Reiko, so I quit."
	DB	NEXT
;	DB	'【清美】：という事は、今日はおヒマだということですわね？'
	DB	"Kiyomi:  So you have some free time today?"
	DB	NEXT
;	DB	'【%001】：そうなるな。'
	DB	"%001:  I suppose so."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す　清美
;	DB	'【清美】：おヒマでしたらわたくしとボートに乗りませんか？'
	DB	"Kiyomi:  Well, if you have time, will you go on a boat"
	DB	CR
	DB	"ride with me?"
	DB	NEXT
;	DB	'【%001】：ボート？'
	DB	"%001:  A boat ride?"
	DB	NEXT
;	DB	'【清美】：泳げない%001さんでもボートなら大丈夫と思ったのですが・・・ダメでしょうか？'
	DB	"Kiyomi:  Well, I thought a boat would be alright, even"
	DB	CR
	DB	"though you can't swim."
	DB	NEXT
;	DB	'【%001】：いんや、問題なし。'
	DB	"%001:  Sure, no problem."
	DB	NEXT
;	DB	'【清美】：そうですか！それでは、貸しボート屋さんに参りましょう。'
	DB	"Kiyomi:  Really! Well, let's go to the boat rental!"
	DB C_BLD,C_V_OFF,4	;行く
	DB	FLG,F_COPYI,3,2
	DW	0000H

M6:		;話す　清美
;	DB	'【清美】：貸しボート屋さんに参りましょう。'
	DB	"Kiyomi:  Let's find the boat rental person."
	DW	0000H

M7:		;考える　鈴子
;	DB	'（せっかく海に来たんだし、鈴子さんだって思う存分泳ぎたいはずだ。）'
	DB	"Since Reiko's come all this way to the sea, I'm sure she'd"
	DB	CR
	DB	"like some time to swim by herself."
	DB	NEXT
;	DB	'（かなづちの俺につきあわせちゃ申し訳ねーよな。）'
	DB	"It's not really fair of me, taking all of her time like"
	DB	CR
	DB	"that."
	DW	0000H

M8:		;行く　貸しボート屋
;	DB	'【%001】：じゃ、行くか。'
	DB	"%001:  Well, let's go."
	DB	NEXT
;	DB	'【清美】：ええ！'
	DB	"Kiyomi:  Yes!"
	DB	NEXT
;	DB	'俺達二人が貸しボート屋に向かうと・・・'
	DB	"Just as we turned to go to the boat rental place..."
	DB	NEXT
	T_CG1 'CT01','M',0,30,2
	DB	ANI,A_ON,1
;	DB	'【鈴子】：あら、どこに行くの%001君。'
	DB	"Reiko:  Oh...where are you off to, %001?"
	DB	NEXT
;	DB	'【%001】：鈴子さん。'
	DB	"%001:  Reiko."
	DB	NEXT
;	DB	'【清美】：%001さんはわたくしとボートに乗るのですわ。'
	DB	"Kiyomi:  %001 and I are going on a boat ride."
	DB	NEXT
;	DB	'【鈴子】：ボートって・・・泳ぎの練習はどうするのよ？'
	DB	"Reiko:  A boat ride? What about swimming?"
	DB	NEXT
;	DB	'【%001】：せっかく海に来たんだし、鈴子さんだって思う存分泳ぎたいだろ？'
	DB	"%001:  Since you've come all this way to the ocean, I"
	DB	CR
	DB	"guess you want to go swimming, right, Reiko?"
	DB	NEXT
;	DB	'【%001】：俺につきあわせちゃ、鈴子さんに申し訳ねーし。',CR,'俺のことはいーから、鈴子さんは自由に楽しんでよ。'
	DB	"%001:  It's really not fair of me to impose on you like"
	DB	CR
	DB	"this. Don't worry about me, just enjoy yourself."
	DB	NEXT
;	DB	'【鈴子】：%001君、私は・・・'
	DB	"Reiko:  Yes, but I..."
	DB	NEXT
;	DB	'【清美】：%001さんもこうおっしゃってることですし、鈴子さんは皆さんと楽しんで下さいな。'
	DB	"Kiyomi:  Well, since %001 says so, why don't you go"
	DB	CR
	DB	"enjoy yourself with the others?"
	DB	NEXT
	T_CG1 'CT01','M','D',30,3
	DB	ANI,A_ON,1
;	DB	'【鈴子】：私はねえ！'
	DB	"Reiko:  Yes, but I...!"
	DB	NEXT
;	DB	'【美緒】：鈴子先輩！'
	DB	"Mio:  Reiko!"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT01','M',0,30,2
	T_CG 'CT03','M',0,0,4
	DB	ANI,A_ON,2
;	DB	'美緒ちゃんが走って来た。'
	DB	"Mio came running up."
	DB	NEXT
;	DB	'【美緒】：鈴子先輩、今日はあたしに泳ぎを教えてくれるって約束したじゃない。'
	DB	"Mio:  Reiko, didn't you promise you would teach me how"
	DB	CR
	DB	"to swim today?"
	DB	NEXT
;	DB	'【鈴子】：ええ？'
	DB	"Reiko:  Yes?"
	DB	NEXT
;	DB	'【清美】：美緒さんも、泳げないのですか？'
	DB	"Kiyomi:  Mio, you can't swim either?"
	DB	NEXT
;	DB	'【美緒】：うん・・・。'
	DB	"Mio:  No..."
	DB	NEXT
;	DB	'【%001】：へぇ・・・知らなかった。'
	DB	"%001:  Really...I didn't know."
	DB	NEXT
;	DB	'【清美】：まあ、%001さんと「おそろい」ですのね。'
	DB	"Kiyomi:  Well, I guess you and %001 are the same."
	DB	NEXT
;	DB	'【亜希】：ふぅん・・・あんた、カナヅチなんだ。'
	DB	"Aki:  Really...you can't swim at all?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT06','M',0,30,5
;	DB	'唐突に亜希ちゃんが割り込んで来た。'
	DB	"Suddenly, Aki was there too."
	DB	NEXT
;	DB	'【美緒】：う、うん。'
	DB	"Mio:  Uh, yes."
	DB	NEXT
;	DB	'【亜希】：へぇ～・・・そんな弱点を隠してたとはねぇ。'
	DB	"Aki:  So...you were hiding it from us?"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT01','M',0,30,2
	T_CG 'CT03','M',0,0,4
	DB	ANI,A_ON,2
;	DB	'【美緒】：だから昨日の夜、鈴子先輩にお願いしたんだ。'
	DB	"Mio:  That's why I asked Reiko last night."
	DB	NEXT
;	DB	'【鈴子】：（そう言えば・・・寝る前に・・・）'
	DB	"Reiko:  Well, right as I was falling asleep..."
	DB	NEXT
;	DB	'【美緒】：今日はあたしが鈴子先輩を独り占めしてもいいよね？'
	DB	"Mio:  So it's alright. if I have Reiko all to myself today?"
	DB	NEXT
;	DB	'【清美】：もちろんですわ。'
	DB	"Kiyomi:  Of course."
	DB	NEXT
	T_CG1 'CT01','M','V',30,6
	DB	ANI,A_ON,4
;	DB	'【鈴子】：ちょちょっと、そんな勝手な・・・'
	DB	"Reiko:  Hey...what?"
	DB	NEXT
;	DB	'【美緒】：じゃ、行こっ、鈴子先輩！'
	DB	"Mio:  Well, let's go, Reiko!"
	DB	NEXT
;	DB	'【鈴子】：あらら・・・'
	DB	"Reiko:  Uh...well..."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'美緒ちゃんと鈴子さんは波打ち際に消えた。'
	DB	"Mio and Reiko went away down to the water's edge."
	DB	NEXT
	DB	BUF,B_COPY01
	DB	ANI,A_INIT
	T_CG 'CT02','M','K',10,1
;	DB	'【清美】：さあ、ボートを借りに参りましょう、%001さん。'
	DB	"Kiyomi:  Well, let's go rent a boat, %001."
	DB	NEXT
;	DB	'【%001】：そだな。亜希ちゃんはどーする？'
	DB	"%001:  Oh, yeah. Do you want to come with us, Aki?"
	DB	NEXT
;	DB	'【清美】：・・・'
	DB	"Kiyomi:  ......................"
	DB	NEXT
	TU_CG 'CT06','M',0,30,2
	T_CG 'CT02','M',0,10,3
	DB	ANI,A_ON,2
;	DB	'【亜希】：え、あたし？'
	DB	"Aki:  Uh, me?"
	DB	NEXT
;	DB	'【亜希】：%001先輩に付き合ってあげたいのは山々だけど、ちょっと用事が出来ちゃったのよね。'
	DB	"Aki:  I'd really like to come with you, %001, but I have"
	DB	CR
	DB	"some things to do."
	DB	NEXT
;	DB	'【亜希】：まぁ、また今度付き合ってあげるわよ。'
	DB	"Aki:  We can do something together next time."
	DB	NEXT
;	DB	'【%001】：そか。'
	DB	"%001:  Oh."
	DB	NEXT
	TU_CG 'CT06','M','K',30,4
	T_CG 'CT02','M',0,10,3
	DB	ANI,A_ON,4
;	DB	'【亜希】：じゃあね！'
	DB	"Aki:  Bye!"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','M',0,10,3
;	DB	'亜希ちゃんは砂の上を走っていった。'
	DB	"Aki ran off."
	DB	NEXT
;	DB	'【%001】：結局二人になっちゃったな。'
	DB	"%001:  Well, I guess it's just the two of us."
	DB	NEXT
;	DB	'【清美】：わたくしは一向に構いませんわ。'
	DB	"Kiyomi:  I like it better that way, actually..."
	DB	NEXT
;	DB	'【%001】：じゃ、行くか。'
	DB	"%001:  Well, let's go."
	DB	NEXT
;	DB	'【清美】：はい。'
	DB	"Kiyomi:  Okay."
	DB	NEXT
	B_O B_FADE
	E_CG B_FADE,'AB_40'
;	DB	'俺達はボートを借りて、浜辺の近くを流していた。'
	DB	"We rented a boat and were rowing around close to the"
	DB	CR
	DB	"beach."
	DB	NEXT
;	DB	'【清美】：%001さん、あそこに見える小島まで行ってみませんか？'
	DB	"Kiyomi:  %001, do you want to try going out as far as"
	DB	CR
	DB	"that small island?"
	DB	NEXT
;	DB	'【%001】：けっこう遠いな・・・'
	DB	"%001:  It's kind of far..."
	DB	NEXT
;	DB	'【%001】：ま、行ってみるか。'
	DB	"%001:  Well, let's try it."
	DB	NEXT
;	DB	'【清美】：はい！'
	DB	"Kiyomi:  Alright!"
	DB	NEXT
	DB SINARIO,'CS607.OVL',0
	DW	0000H


end
