;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０６
;		テニス部見学

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
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
CM2:	DW	VV2,	NN1,NN3,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"話す",0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	"プールに行く",0
VV3:	DB	3,	"TRY SWIMMING",0
;VV4:	DB	4,	"野球部に行く",0
VV4:	DB	4,	"TRY BASEBALL",0

;NN1:	DB	1,	"美緒",0
NN1:	DB	1,	"MIO",0
;NN2:	DB	2,	"テニスコート",0
NN2:	DB	2,	"TENNIS COURTS",0
;NN3:	DB	3,	"今日子",0
NN3:	DB	3,	"KYOKO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　美緒
S2:		DW	VV1, NN2,  2, M3		;見る　テニスコート
S3:		DW	VV2, NN3,  3, M4, M6		;話す　今日子
S4:		DW	VV2, NN1,  4, M5		;話す　美緒
S5:		DW	VV3, -1,  5, M7		;プールに行く
S6:		DW	VV4, -1,  6, M8		;野球部に行く


;イニシャルメッセージ
M1:
	DB	BGM,19
	B_O B_SUDA
	BAK_INIT "AB_12_1"
	B_P1 B_SUDA
;	DB	"俺はテニスコートに来た。"
	DB	"I arrived at the tennis courts."
	DB	NEXT
;	DB	"【%001】：ここか。"
	DB	"%001:  This looks like the place."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT12","T",0,30,1
;	DB	"【今日子】：あら、宴会委員の%001君じゃない。"
	DB	"Kyoko:  Oh, hello, %001!"
	DB	NEXT
;	DB	"【%001】：あれ、先生。何してるんですか。"
	DB	"%001:  What are you doing here?"
	DB	NEXT
;	DB	"【今日子】：あたし、テニス部の顧問なのよ。"
	DB	"Kyoko:  I'm the advisor for the tennis club."
	DB	NEXT
;	DB	"【今日子】：君は何しに来たの？あ、入部？"
	DB	"Kyoko:  What are you doing here? Do you want to join?"
	DB	NEXT
;	DB	"【%001】：いや・・・ちょっと知り合いに頼まれて。"
	DB	"%001:  Not really. I was just invited to try out the club."
	DB	NEXT
	T_CG "CT03","T","K",0,2
	DB ANI,A_ON,1
;	DB	"【美緒】：%001先輩！"
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	"【%001】：よ、美緒ちゃん。"
	DB	"%001:  Hey, Mio."
	DB	NEXT
;	DB	"美緒ちゃんが現われた。"
	DB	"Mio came running up to me."
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DW	0000H

M2:		;見る　美緒
;	DB	"（何か、うれしそうだ。）"
	DB	"She looks really happy."
	DB	NEXT
;	DB	"（俺がテニス部に入るって信じてるんだろうか？）"
	DB	"She must expect me to join the tennis club."
	DW	0000H

M3:		;見る　テニスコート
;	DB	"全部で８面あるようだ。"
	DB	"There are eight courts in all."
	DB	NEXT
;	DB	"テニス部員が練習してる。"
	DB	"All the club members are practicing."
	DW	0000H

M4:		;話す　今日子
;	DB	"【%001】：先生、ここで何してるんです？"
	DB	"%001:  What do you do here?"
	DB	NEXT
;	DB	"【今日子】：生徒が怪我しないように、監視役してるのよ。"
	DB	"Kyoko:  I'm here to watch over the students, and make "
	DB	CR
	DB	"sure nobody gets hurt."
	DB	NEXT
;	DB	"【%001】：指導とかしなくていいんですか？"
	DB	"%001:  You don't have to instruct or anything?"
	DB	NEXT
;	DB	"【今日子】：生徒の自主性を尊重するのがこの学校の方針なのよ。"
	DB	"Kyoko:  At this school, we like to leave things up to"
	DB	CR
	DB	"student motivation."
	DB	NEXT
;	DB	"【%001】：へえ、俺はまためんどくさがってるのかと思ったけど。"
	DB	"%001:  I admire your dedication..."
	DB	NEXT
;	DB	"【今日子】：（どき）そ、そんなわけないでしょ。"
	DB	"Kyoko:  Hey!"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す　美緒
;	DB	"【美緒】：先輩、ようこそテニス部へ！"
	DB	"Mio:  Welcome to the tennis club!"
	DB	NEXT
;	DB	"【今日子】：はい、%001君。"
	DB	"Kyoko:  Here you go, %001."
	DB	NEXT
;	DB	"【%001】：へ？"
	DB	"%001:  What's this?"
	DB	NEXT
;	DB	"俺はラケットを手渡された。"
	DB	"She handed me a tennis racket."
	DB	NEXT
	K_CG "CT12","K",30,4
	DB	ANI,A_ON,2
;	DB	"【今日子】：何事も習うより慣れろ、よ。"
	DB	"Kyoko:  The best way to get good at something is to just do"
	DB	CR
	DB	"it."
	DB	NEXT
;	DB	"【%001】：でも、俺・・・"
	DB	"%001:  But, I..."
	DB	NEXT
;	DB	"【今日子】：いいからいいから。美緒ちゃんに稽古つけてもらいなさい。"
	DB	"Kyoko:  Go practice with Mio."
	DB	NEXT
;	DB	"【美緒】：いい？ラケットはこうやって持つの。"
	DB	"Mio:  You hold the racket like this."
	DB	NEXT
;	DB	"【%001】：こ、こう？"
	DB	"%001:  Like this?"
	DB	NEXT
;	DB	"【美緒】：で、体をこうひねって・・・"
	DB	"Mio:  And twist your body like this..."
	DB	NEXT
;	DB	"【%001】：こうか？"
	DB	"%001:  Is this okay?"
	DB	NEXT
;	DB	"【美緒】：そうじゃなくって、こうするの。１、２、３。"
	DB	"Mio:  Not like that. Like this. One, two, three."
	DB	NEXT
;	DB	"【%001】：・・・やっぱ俺には向いてねーな。"
	DB	"%001:  This is really not my thing."
	DB	NEXT
	T_CG "CT03","T",0,0,5
	DB ANI,A_ON,4
;	DB	"【美緒】：そんな事ないよ！いい？こうするの。"
	DB	"Mio:  You're doing okay. Try it like this."
	DB	NEXT
;	DB	"美緒ちゃんが俺の背中に密着して、俺の腕に手を添えた。"
	DB	"Mio reached around from behind me held my arm in the right"
	DB	CR
	DB	"position."
	DB	NEXT
;	DB	"【美緒】：脇を締めて・・・こう体をひねって・・・"
	DB	"Mio:  Hold it here... And turn your body like this."
	DB	NEXT
;	DB	"【%001】：で・・・１、２、３。"
	DB	"%001:  And, one, two, three."
	DB	NEXT
;	DB	"【美緒】：そう、それでいいの！忘れない内に、もう１回。"
	DB	"Mio:  That right. One more time before you forget."
	DB	NEXT
;	DB	"【%001】：１、２、３。"
	DB	"%001:  One, two, three."
	DB	NEXT
;	DB	"【美緒】：１、２、３。"
	DB	"Mio:  One, two, three."
	DB	NEXT
;	DB	"・・・・・・・・・３０分経過・・・・・・・・・"
	DB	"............Thirty minutes later.............."
	DB	NEXT
;	DB	"【美緒】：じゃあ先輩、そろそろゲームしてみようか。"
	DB	"Mio:  Let's have a game."
	DB	NEXT
;	DB	"【%001】：そうだな・・・"
	DB	"%001:  What, already?"
	DB	NEXT
;	DB	"【%001】：じゃないや。まだ他の場所にも行かなきゃならんから、そろそろ行くわ。"
	DB	"%001:  But I have to go to the other clubs, too."
	DB	NEXT
;	DB	"【美緒】：えぇ～・・・"
	DB	"Mio:  Do you have to go?"
	DB	NEXT
;	DB	"【今日子】：%001君、キミけっこういいスジしてるわよ。",CR,"どう、本格的に始めてみない？"
	DB	"Kyoko:  %001, you'd be good at tennis. Please think about it."
	DB	NEXT
;	DB	"【%001】：考えときます。"
	DB	"%001:  I will."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_OFF,3
	DB C_BLD,C_V_OFF,4
	DW	0000H

M6:		;話す　今日子
;	DB	"【%001】：先生はテニスしないんですか？"
	DB	"%001:  Why don't you play?"
	DB	NEXT
;	DB	"【今日子】：もうそんな年でもないしね～。"
	DB	"Kyoko:  I'm not as young as I used to be."
	DW	0000H

M7:		;プールに行く
;	DB	"（・・・・・・・・・）"
	DB	"................................"
	DB	NEXT
;	DB	"（水泳部は後回しにしよう。）"
	DB	"Why don't I put off going to the swim team for later."
	DB	NEXT
;	DB	"俺は野球部のグラウンドに向かった。"
	DB	"I go to the baseball field."
	DB	NEXT
;	DB	"・・・・・・・・・・・・"
	DB	"................."
	DB	NEXT
;	DB	"【美緒】：先輩・・・あたしと一緒にテニスしようよ・・・。"
	DB	"Mio:  %001, play tennis with me......."
	DB	NEXT
	DB SINARIO,"CS207.OVL",0
	DW	0000H

M8:		;野球部に行く
;	DB	"（さて、新藤さんが待ってるな・・・。）"
	DB	"Kiyomi is waiting for me."
	DB	NEXT
;	DB	"俺は野球部のグラウンドに向かった。"
	DB	"I head for the baseball field."
	DB	NEXT
;	DB	"・・・・・・・・・・・・"
	DB	"................."
	DB	NEXT
;	DB	"【美緒】：先輩・・・あたしと一緒にテニスしようよ・・・。"
	DB	"Mio:  %001, please choose me..."
	DB	NEXT
	DB SINARIO,"CS207.OVL",0
	DW	0000H


end
