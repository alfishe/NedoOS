;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０４＿Ｅ
;		瑠璃と雨宿り

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	'RURI',0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	'SKY',0
;NN3:	DB	3,	'洞窟',0
NN3:	DB	3,	'CAVE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　瑠璃
S2:		DW	VV1, NN2,  2, M3, M4		;見る　空
S3:		DW	VV1, NN3,  3, M5		;見る　洞窟
S4:		DW	VV2, NN1,  4, M6, M7, M8, M9, M10, M11, M12		;話す　瑠璃


;イニシャルメッセージ
M1:
	DB	BGM,31
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  .............................."
	DB	NEXT
;	DB	'【%001】：待ってて、今火を起こすから。'
	DB	"%001:  Hang on a minute, I'll start a fire for us."
	DB	NEXT
;	DB	'俺はライターで小枝に火を付けて、小さな火を起こした。'
	DB	"I lit the firewood with my lighter."
	E_CG B_FADE,'AE_020'
	DW	0000H

M2:		;見る　瑠璃
;	DB	'雨に濡れて、体操着が透けてる・・・'
	DB	"She's dripping wet. I can see through her P.E. uniform."
	DB	NEXT
;	DB	'【瑠璃】：・・・あまり見ないでくれる。'
	DB	"Ruri:  ......................Stop staring, will you?"
	DB	NEXT
;	DB	'【%001】：ご、ごめん！'
	DB	"%001:  Sorry!"
	DW	0000H

M3:		;見る　空
;	DB	'【%001】：こりゃしばらく止みそうにないな。'
	DB	"%001:  It'll be coming down for a while."
	DB	NEXT
;	DB	'【瑠璃】：・・・すぐにやむわ。'
	DB	"Ruri:  It'll stop in a bit."
	DB	NEXT
;	DB	'【%001】：・・・何でわかるの？'
	DB	"%001:  What makes you so sure?"
	DB	NEXT
;	DB	'【瑠璃】：・・・わかるの。'
	DB	"Ruri:  I just know."
	DW	0000H

M4:		;見る　空
;	DB	'見上げている内に、雨は上がって青空がひろがった。'
	DB	"The rain is finally letting up."
	DW	0000H

M5:		;見る　洞窟
;	DB	'俺達は入り口のすぐ近くにいるが、まだまだ奥に行けそうだ。'
	DB	"We're near the entrance, but the cave goes on for quite"
	DB	CR
	DB	"a ways."
	DW	0000H

M6:		;話す　瑠璃
;	DB	'【%001】：この洞窟、どこまで続いてるんだろ？'
	DB	"%001:  I wonder how far this cave goes on for."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ................................."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M7:		;話す　瑠璃
;	DB	'【%001】：奥まで行ってみよーか？'
	DB	"%001:  You want to check it out?"
	DB	NEXT
;	DB	'【瑠璃】：・・・行けば。'
	DB	"Ruri:  ....Why don't you go by yourself?"
	DB	NEXT
;	DB	'【%001】：・・・やっぱいいや。'
	DB	"%001:  Nevermind."
	DB	NEXT
;	DB	'【瑠璃】：・・・そう。'
	DB	"Ruri:  ..................................."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M8:		;話す　瑠璃
;	DB	'【%001】：みんな心配してるな、きっと。'
	DB	"%001:  I'll bet everyone's worried about us."
	DB	NEXT
;	DB	'【瑠璃】：・・・あなたのことをね。'
	DB	"Ruri:  .....Worried about you, yes."
	DB	NEXT
;	DB	'【%001】：俺達のことを、だよ。'
	DB	"%001:  I said 'us.'"
	DB	NEXT
;	DB	'【瑠璃】：・・・そんなわけないわ。'
	DB	"Ruri:  No one's going to worry about me."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M9:		;話す　瑠璃
;	DB	'【%001】：前から・・・白水さんに聞いてみたい事があったんだ。'
	DB	"%001:  There's something I've wanted to ask you, Ruri."
	DB	NEXT
;	DB	'【%001】：・・・どうして誰とも話さないんだ？'
	DB	"%001:  Why are you so quiet all the time?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............................."
	DB	NEXT
;	DB	'【%001】：もし俺達に悪い点があるなら改める。どうしてだ？'
	DB	"%001:  Is it your other classmates? Is it us?"

	DB	NEXT

	DB	"%001:  If there's something we do that you don't like, we"
	DB	CR
	DB	"can talk about it."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............................."
	DB	NEXT
;	DB	'【%001】：俺達に不満があるなら、言ってくれよ！'
	DB	"%001:  If there's something you don't like about us, just"
	DB	CR
	DB	"tell us!"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............................."
	DB	NEXT
;	DB	'【%001】：そうやってすぐに黙り込んで！'
	DB	"%001:  See? You're so quiet all the time! You just sit"
	DB	CR
	DB	"there like a dead thing!"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............................."
	DB	FLG,F_COPYI,4,4
	DW	0000H

M10:		;話す　瑠璃
;	DB	'【%001】：・・・ごめん・・・怒鳴ったりして。'
	DB	"%001:  ....I'm sorry. I got a little carried away."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............................."
	DB	NEXT
;	DB	'【瑠璃】：・・・あなた達は悪くない。'
	DB	"Ruri:  ...It's not the fault of any of you."
	DB	NEXT
;	DB	'【%001】：だったら、どうして俺達が話し掛けても答えてくれないんだ？'
	DB	"%001:  Then why don't you answer when we talk to you?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .........................."
	DB	FLG,F_COPYI,4,5
	DW	0000H

M11:		;話す　瑠璃
;	DB	'【瑠璃】：雨がやむわ・・・。'
	DB	"Ruri:  The rain's stopping."
	DB	NEXT
;	DB	'【%001】：・・・？'
	DB	"%001:  ....................?"
	DB	NEXT
;	DB	'【瑠璃】：あと、１分。'
	DB	"Ruri:  It'll stop in one minute."
	DB	NEXT
;	DB	'【%001】：こんなにドバドバ降ってるのに？'
	DB	"%001:  Even though it's pouring now?"
	DB	NEXT
;	DB	'【%001】：・・・あれ？'
	DB	"%001:  ...Huh?"
	DB FLG,F_COPYI,2,1	;見る　空
	DB	FLG,F_COPYI,4,6
	DW	0000H


M12:		;話す　瑠璃
;	DB	'【%001】：・・・本当だ。雨、やんだ。'
	DB	"%001:  You were right. The rain stopped."
	DB	NEXT
;	DB	'【瑠璃】：早く戻った方がいいわね。風邪ひくわよ。'
	DB	"Ruri:  We should get back to camp. We'll catch colds."
	DB	NEXT
;	DB	'そういうなり、白水さんは洞窟を出ていってしまった。'
	DB	"Ruri left the cave."
	DB	NEXT
;	DB	'【%001】：ま、待って！'
	DB	"%001:  Wait for me!"
	DB	NEXT
	DB	"How did she know the rain was going to stop like that?"
	DB	NEXT
;	DB	'俺は薪を抱えて、白水さんを追いかけてキャンプに戻った。'
	DB	"Gathering up the firewood, I chased after her."
	DB	NEXT
	DB SINARIO,'CS505.OVL',0
	DW	0000H


end
