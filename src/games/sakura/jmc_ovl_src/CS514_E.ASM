;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１４＿Ｅ
;		林間学校　今日子と酒盛り（未遂）

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
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	"RURI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　瑠璃１
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7, M8, M9, M10, M11		;話す　瑠璃９


;イニシャルメッセージ
M1:
	DB	BGM,32
	BAK_INIT 'AB_18'
	DB BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'【%001】：・・・ここまでくれば、大丈夫だな。'
	DB	"%001:  I should probably be okay over here."
	DB	NEXT
	T_CG 'CT12','F','K',10,1
;	DB	'【今日子】：あれ？%001君？'
	DB	"Kyoko:  %001?"
	DB	NEXT
;	DB	'【%001】：先生？'
	DB	"%001:  Sensei?"
	DB	NEXT
;	DB	'【今日子】：何やってんの？こんなとこで。'
	DB	"Kyoko:  What are you doing over here? Drinking again?"
	DB	NEXT
;	DB	'【%001】：それはこっちのセリフですよ。'
;	DB	"%001:  I could ask you the same thing."
;	DB	NEXT
;	DB	'【今日子】：私？見ての通りよ。'
	DB	"Kyoko:  Me? Does it look like I'm drinking?"
	DB	NEXT
;	DB	'【%001】：・・・またお酒ですか・・・？'
	DB	"%001:  .....Are you?"
	DB	NEXT
;	DB	'【今日子】：・・・いや～、流石に他の先生が居るところじゃちょっちね～。'
	DB	"Kyoko:  Well, I didn't want to be with the other professors."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .............................."
	DB	NEXT
;	DB	'【今日子】：・・・ま、いいわ。%001君もこっち来て一杯やんなさい。'
	DB	"Kyoko:  Come over here, %001, and have a glass."
	DB	NEXT
;	DB	'【%001】：やっぱり、そ～来るんですか？'
	DB	"%001:  You never change!"
	DB	NEXT
;	DB	'【今日子】：もちろん。'
	DB	"Kyoko:  Of course. Why should I change?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  .................."
	DB	NEXT
	T_CG1 'CT05','F',0,33,2
	DB	ANI,A_ON,1
;	DB	'【今日子】：あら、瑠璃ちゃん。どしたの？'
	DB	"Kyoko:  Oh, Ruri. What's up?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・先生、校長先生が呼んでます。'
	DB	"Ruri:  Sensei, the dean wants to see you."
	DB	NEXT
;	DB	'【今日子】：あ、そ。'
	DB	"Kyoko:  Oh."
	DB	PAUSE
;	DB	'・・・じゃあ瑠璃ちゃん、これ飲んで。'
	DB	"....Well, here, Ruri, drink this."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・これ、お酒・・・・・・？'
	DB	"Ruri:  Is this sake...?"
	DB	NEXT
;	DB	'【今日子】：瑠璃ちゃんがそれ飲んだら、行くから。'
	DB	"Kyoko:  Well, if you drink it, I'll leave."
	DB	NEXT
;	DB	'【%001】：・・・どーゆー理屈だ？'
	DB	"%001:  ........What does that have to do with it?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'ぐいっ'
	DB	"*GULP*"
	DB	NEXT
;	DB	'【今日子】：・・・を～、いい飲みっぷり！'
	DB	"Kyoko:  Oh, you're such a good girl!"
	DB	PAUSE
;	DB	'じゃ、ちょっち行ってくるから、お留守番お願いね。'
	DB	" Well, see you in"
	DB	CR
	DB	"a bit. You can drink that sake over there if you like."
	DB	NEXT
;	DB	'【%001】：・・・ちょっと先生・・・'
	DB	"%001:  Wait, Sensei!"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT05','F',0,33,2
;	DB	'【%001】：・・・ちょっと！'
	DB	"%001:  She's gone."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ..............."
	DW	0000H

M2:		;見る　瑠璃１
;	DB	'いつもと同じ、無表情だ。別に顔も赤くなってない。'
	DB	"As usual, she's totally emotionless. Her face hasn't even",CR,"gone red."
	DB	NEXT
;	DB	'（・・・結構酒、強いんだな。）'
	DB	"That stuff is pretty strong."
	DW	0000H

M3:		;話す　瑠璃１
;	DB	'【%001】：・・・どうしよっか？'
	DB	"%001:  ........What should we do?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ............."
	DB	PAUSE
;	DB	'私は先生を待つわ。'
	DB	"I'll wait for Sensei to come back."
	DB	NEXT
;	DB	'【%001】：・・・じゃあ、俺も待つか。'
	DB	"%001:  .........I guess I'll wait too then."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ..............."
	DB	PAUSE
;	DB	'そう。'
	DB	"I see."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　瑠璃２
;	DB	'【%001】：・・・ねえ、白水さん・・・'
	DB	"%001:  .......So, Ruri."
	DB	PAUSE
	DB BUF,B_COPY01
	T_CG 'CT05','F',0,10,3
;	DB	'あれ？'
	DB	" Huh?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'一体いつの間に移動したのか・・・白水さんは酒瓶の山のところで、'
;	DB	'手酌で酒を注いでいた。'
	DB	"I don't know how she moved so fast, but there was Ruri, over",CR,"at the heap of sake bottles, helping herself to some sake."
	DB	NEXT
;	DB	'【%001】：・・・・・・白水さん、お酒好きなの？'
	DB	"%001:  Do you like sake?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ................"
	DB	NEXT
;	DB	'すっ'
	DB	"*GULP*"
	DB	NEXT
;	DB	'返事の代わりに白水さんは、空のコップを俺に差し出した。'
	DB	"Instead of answering me, she held out the empty cup."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・あなたも飲む？'
	DB	"Ruri:  .....Do you want some, too?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DB	PAUSE
;	DB	'へ？'
	DB	"Huh?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・いやならいいわ。'
	DB	"Ruri:  If you don't, it's alright."
	DB	NEXT
;	DB	'【%001】：い、いや！そんな事はない！'
	DB	"%001:  N- No! That's not it!"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・そう。'
	DB	"Ruri:  .....Oh."
	DB	NEXT
;	DB	'言って白水さんは、俺のコップになみなみと酒を注いで手渡してくれた。'
	DB	"She filled my cup with sake and handed it to me."
	DB	NEXT
;	DB	'【%001】：・・・・・・あ、ありがとう。'
	DB	"%001:  .....Thanks."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  .............................."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　瑠璃３
;	DB	'【%001】：・・・こ、この酒美味いな。'
	DB	"%001:  .....Um, it's good, isn't it?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・そう？'
	DB	"Ruri:  ...Really?"
	DB	NEXT
;	DB	'【%001】：う、うん・・・多分。'
	DB	"%001:  Uh, yeah....."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ................................"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;話す　瑠璃４
;	DB	'【%001】：・・・せ、先生遅いな。何の用で呼ばれたんだろ？'
	DB	"%001:  ...Well, Sensei sure has been gone a long time. I"
	DB	CR
	DB	"wonder what the dean wanted to see her about?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・知らない。'
	DB	"Ruri:  ......I don't know."
	DB	NEXT
;	DB	'【%001】：・・・・・・そ、そか。'
	DB	"%001:  ................................."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ................................"
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;話す　瑠璃５
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................................"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ................................"
	DB	NEXT
;	DB	'（・・・うーむ、話題が無い・・・）'
	DB	"We always get like this...."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・%001君。'
	DB	"Ruri:  ...........%001."
	DB	NEXT
;	DB	'【%001】：な、なに？'
	DB	"%001:  Y- Yes?"
	DB	NEXT
;	DB	'【瑠璃】：%001君って・・・どんな人？'
	DB	"Ruri:  %001, what kind of person are you?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .........................."
	DB	PAUSE
;	DB	'え？'
	DB	"Huh?"
	DB	FLG,F_COPYI,2,5
	DW	0000H

M8:		;話す　瑠璃６
;	DB	'【%001】：・・・俺？'
	DB	"%001:  .........What kind of person am I?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ................................"
	DB	NEXT
;	DB	'【%001】：・・・うーん・・・どんな人？って言われてもなぁ・・・'
	DB	"%001:  .......Hmm, that's not easy to answer."
	DB	NEXT
;	DB	'【%001】：・・・・・・『見た通り』としか言えないなぁ・・・・・・'
	DB	"%001:  Well, I guess all I can say is 'What you see is what ",CR,"you get'."
	DB	PAUSE
;	DB	'ハハハ、芸のない返事だよな。'
	DB	" Hahaha, it's not a very creative answer, is it?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・そう。'
	DB	"Ruri:  No."
	DB	FLG,F_COPYI,2,6
	DW	0000H

M9:		;話す　瑠璃７
;	DB	'【%001】：・・・じゃあ聞くけどさ、白水さんは俺の事、どう見てる？'
	DB	"%001:  Well, what do you think of me, then?"
	DB	NEXT
;	DB	'【瑠璃】：1・・・・・・え・・・・・・？'
	DB	"Ruri:  Huh?"
	DB	NEXT
;	DB	'【%001】：やっぱさ、自分の事って自分じゃ良くわかんないんだよな。'
	DB	"%001:  Well, it's kind of hard to know that sort of thing ",CR,"about yourself, I guess."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ...................."
	DB	PAUSE
;	DB	'優しい人・・・・・・・・・'
	DB	"I think you're nice."
	DB	NEXT
;	DB	'【%001】：・・・え？'
	DB	"%001:  You do?"
	DB	NEXT
;	DB	'【瑠璃】：・・・誰も傷つけたくない、そう思っている人。'
	DB	"Ruri:  ........I think that you never would want to hurt",CR,"anyone."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................."
	DB	NEXT
;	DB	'【%001】：・・・・・・うーむ、何と言っていいのやら・・・・・・'
	DB	"%001:  Um, okay..."
	DB	FLG,F_COPYI,2,7
	DW	0000H

M10:		;話す　瑠璃８
;	DB	'【瑠璃】：・・・・・・私は・・・・・・'
	DB	"Ruri:  .......How about me?"
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  ......Hm?"
	DB	NEXT
;	DB	'【瑠璃】：%001君は私をどう見てるの？'
	DB	"Ruri:  What do you think of me, %001?"
	DB	NEXT
;	DB	'【%001】：白水さん・・・かい？'
	DB	"%001:  What do I think of you?"
	DB	NEXT
;	DB	'【瑠璃】：ええ。'
	DB	"Ruri:  ...........Yes."
	DB	FLG,F_COPYI,2,8
	DW	0000H

M11:		;話す　瑠璃９
;	DB	'【%001】：・・・そうだなあ・・・'
	DB	"%001:  Hmm..."
	DB	NEXT
;	DB	'【%001】：正直言って、良くわからねぇ。'
	DB	"%001:  To tell you the truth, I don't really know."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ............................"
	DB	NEXT
;	DB	'【%001】：・・・・・・今は良くわからねぇけど・・・・・・'
	DB	"%001:  Well, I don't know now, but I want to..."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・・・・'
	DB	"Ruri:  ................................"
	DB	NEXT
;	DB	'【%001】：・・・俺は・・・'
	DB	"%001:  Ruri, I..."
	DB	NEXT
	T_CG1 'CT12','F','K',33,1
	DB	ANI,A_ON,2
;	DB	'【今日子】：・・・いや～、マイッタマイッタ！'
	DB	"Kyoko:  Oh, I hate that man!"
	DB	NEXT
;	DB	'【%001】：ぅどぉわぁっ！？'
	DB	"%001:  What's wrong?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・あ、先生。'
	DB	"Ruri:  ......Oh, Sensei."
	DB	NEXT
;	DB	'【今日子】：校長先生ったら『先生方もフォークダンスに参加しよう！』'
;	DB	'なーんて言い出すんだもの。'
	DB	"Kyoko:  The dean ordered all the professors to dance with ",CR,"the students."
	DB	NEXT
;	DB	'【%001】：・・・それで、逃げて来たんですか？'
	DB	"%001:  So, you came here to escape?"
	DB	NEXT
;	DB	'【今日子】：・・・そんな年でもないしね～。'
	DB	"Kyoko:  Of course!"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ............."
	DB	PAUSE
;	DB	'じゃ、先生来たから。'
	DB	"Well, Sensei's back."
	DB	NEXT
;	DB	'【%001】：・・・白水さん？'
	DB	"%001:  Ruri?"
	DB	NEXT
;	DB	'【瑠璃】：さよなら。'
	DB	"Ruri:  Sayonara."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT12','F','K',33,1
;	DB	'【%001】：・・・あ！'
	DB	"%001:  Wait!"
	DB	PAUSE
;	DB	'・・・行っちゃった。'
	DB	"...She's gone."
	DB	NEXT
;	DB	'【今日子】：・・・をやぁ？もしかして私、お邪魔だったぁ～？'
	DB	"Kyoko:  ....Whoops! Did I interrupt anything between you two?"
	DB	NEXT
;	DB	'【%001】：・・・そんなんじゃねぇですよ。'
	DB	"%001:  No, of course not."
	DB	NEXT
;	DB	'【今日子】：あらら・・・'
	DB	"Kyoko:  Well, then..."
	DB	PAUSE
;	DB	'じゃお詫の印に、私と飲み明かしましょ！'
	DB	" As an apology, drink with me and tell"
	DB	CR
	DB	"me all about it!"
	DB	NEXT
;	DB	'【%001】：・・・何でそーゆー話になるんですかっ！？'
;	DB	"%001:  .....Where are you going with this?!"
;	DB	NEXT
;	DB	'【今日子】：・・・・・・ま～ま～い～からい～から・・・・・・'
;	DB	"Kyoko:  ...Well, well...come on, it's fine..."
;	DB	NEXT
;	DB	'・・・かくして。'
;	DB	"........Drink up/Hide."
;	DB	NEXT
;	DB	'俺は置いてあった酒が無くなるまで、今日子先生に付き合わされたのだった・・・・・・'
	DB	"So until I had drunk all the sake in my cup, I was stuck with",CR,"Kyoko-sensei."
	DB	NEXT
	DB	SINARIO,'CS516_E.OVL',0
	DW	0000H


end