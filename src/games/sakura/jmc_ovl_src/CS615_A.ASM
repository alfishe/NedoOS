;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６１５＿Ａ
;		鈴子と二人

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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	"REIKO",0
;NN2:	DB	2,	'海',0
NN2:	DB	2,	"OCEAN",0
;NN3:	DB	3,	'月',0
NN3:	DB	3,	"MOON",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子
S2:		DW	VV1, NN2,  2, M4		;見る　海
S3:		DW	VV1, NN3,  3, M5, M6		;見る　月
S4:		DW	VV2, NN1,  4, M7, M8, M9, M10, M11, M12, M13, M14		;話す　鈴子
S5:		DW	VV3, NN1,  5, M15, M16		;考える　鈴子


;イニシャルメッセージ
M1:
	DB	BGM,9
	BAK_INIT "AB_17_3"
	DB	BUF,B_COPY01
;	DB	'【%001】：・・・鈴子さん、何やってんの？'
	DB	"%001:  ...Reiko, what are you up to?"
	DB	NEXT
	T_CG "CT01","F","V",15,1
;	DB	'【鈴子】：きゃあ！？'
	DB	"Reiko:  Kya!!"
	DB	PAUSE
;	DB	'・・・・・・%001・・・君？'
	DB	" %001?"
	DB	NEXT
;	DB	'【%001】：や。'
	DB	"%001:  It's me."
	DB	NEXT
;	DB	'突然後ろから声かけるんだもの、心臓止まっちゃうかと思ったわ。'
	DB	"Reiko:  You scared me, coming up behind like that."
	DB	NEXT
	T_CG "CT01",'F',0,15,2
;	DB	'【%001】：ははは、悪ィ。'
	DB	"%001:  Haha, sorry."
	DB G_FLG,G_COPYI,114,1
	DB G_FLG,G_COPYF,110,110
	DB	FLG,F_CALI,110,15
	DB G_FLG,G_COPYG,110,110
	DW	0000H

M2:		;見る　鈴子
;	DB	'俺と目が合ったとたん、視線を海の方に向けてしまった。'
	DB	"Just as our eyes met, she turned her gaze toward the"
	DB	CR
	DB	"ocean."
;	DB	NEXT
;	DB	'・・・どうかしたのかな？'
;	DB	"I wonder what's wrong."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　鈴子
;	DB	'月を見上げている。'
	DB	"Now she's looking up at the moon."
	DW	0000H

M4:		;見る　海
;	DB	'・・・やっぱり、ダメだ。'
	DB	"...It's no use."
	DB	NEXT
;	DB	'夜の海はこう、入ったら二度と出られないような・・・'
	DB	"It looks like if you went into the ocean now, at night,"
	DB	CR
	DB	"you could never get out again..."
	DW	0000H

M5:		;見る　月
;	DB	'【鈴子】：今日は、満月ね。'
	DB	"Reiko:  There's a full moon tonight."
	DB	NEXT
;	DB	'【%001】：ああ。・・・・・・綺麗だよな。'
	DB	"%001:  Yes. It's beautiful, isn't it?"
	DB	NEXT
;	DB	'【鈴子】：え！？'
	DB	"Reiko:  Eh?!"
	DB	NEXT
;	DB	'【%001】：・・・どうかした？'
	DB	"%001:  What's the matter?"
	DB	NEXT
;	DB	'【鈴子】：う、ううん、なんでもな～い。'
	DB	"Reiko:  Oh,  nothing."
	DB	NEXT
;	DB	'・・・・・・でも、月が綺麗だ、っていうのは素直に認めるのね。'
	DB	"Reiko:  You don't seem like the kind of person who would say",CR,"that about the moon."
	DB	NEXT
;	DB	'【%001】：・・・だ～か～ら～・・・'
	DB	"%001:  I don't?"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M6:		;見る　月
;	DB	'綺麗って言ったら、やっぱり月の方が綺麗だと思うなぁ。'
	DB	"%001:  If I say the moon is beautiful, then that's what"
	DB	CR
	DB	"I really think."
	DB	NEXT
;	DB	'だから・・・泳げないからって訳じゃないぞ。'
	DB	"%001:  It has nothing to do with not being able to swim."
;	DB	NEXT
;	DB	'って鈴子さんに言っても、きっと信じないだろうな・・・'
;	DB	"But even if I tell Reiko, she won't believe me..."
	DB	0000H

M7:		;話す　鈴子
;	DB	'【%001】：ところで、鈴子さん何してたの？'
	DB	"%001:  So what were you doing out here, Reiko?"
	DB	NEXT
;	DB	'【鈴子】：え・・・？私？'
	DB	"Reiko:  Me?"
	DB	PAUSE
;	DB	'・・・・・・別に、大したことじゃないわよ。で、%001君は何してるの？'
	DB	" Just walking. How about you?"
	DB	NEXT
;	DB	'【%001】：へ？俺？・・・・・・'
	DB	"%001:  What, me?"
	DB	PAUSE
;	DB	'・・・・・・・・・・・・さあ？'
	DB	" The same as you, I guess."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:		;話す　鈴子
;	DB	'【%001】：ま、気にしない気にしない。些細なことだよ。'
;	DB	"%001:  Well, never mind."
;	DB	PAUSE
;	DB	'・・・・・・・・・ねえ、%001君。'
	DB	"Reiko:  %001?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・少し・・・歩かない？'
	DB	"Reiko:  Do you want to walk a bit?"
	DB	NEXT
;	DB	'【%001】：ああ、いいよ。'
	DB	"%001:  Yeah, sure."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M9:		;話す　鈴子
;	DB	'【鈴子】：ねえ、%001君・・・夜の海って、どう思う？'
	DB	"Reiko:  What do you think of the ocean at night?"
	DB	NEXT
;	DB	'【%001】：どうって、う～ん・・・・・・恐いよ、やっぱり。'
	DB	"%001:  Well, I guess.....it's pretty scary."
	DB	NEXT
;	DB	'【鈴子】：ふふっ、それは%001君が泳げないからでしょ？'
	DB	"Reiko:  Oho, that must be because you can't swim."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・それは言わない約束だって。'
	DB	"%001:  Reiko, you said you wouldn't talk about that."
	DB	NEXT
;	DB	'【鈴子】：はいはい。'
	DB	"Reiko:  Okay, okay."
	DB	PAUSE
;	DB	'・・・・・・・・・・・・私は、綺麗だと思うな・・・'
	DB	" Well, I think it's beautiful."
	DB	NEXT
;	DB	'【%001】：え～っ・・・俺は無気味なだけと思うけどな。'
	DB	"%001:  Really? It just gives me the creeps."
	DB	NEXT
;	DB	'【鈴子】：も～っ、いくら泳げないからって、海の美しさを認めない事はないでしょ。'
	DB	"Reiko:  But, it's not like you can't appreciate the beauty"
	DB	CR
	DB	"of the ocean just because you can't swim."
	DB	NEXT
;	DB	'【%001】：・・・・・・う～。'
	DB	"%001:  Yeah, I guess."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M10:		;話す　鈴子
;	DB	'【%001】：そだ、鈴子さん、吉田は泳げるようになったの？'
	DB	"%001:  So Reiko, did Seia learn to swim?"
	DB	NEXT
;	DB	'【鈴子】：あら？気になるの？'
	DB	"Reiko:  Why do you ask?"
	DB	NEXT
;	DB	'【%001】：・・・まぁ、同じ悩みを持つ者としては・・・'
	DB	"%001:  You know, as someone suffering from the same"
	DB	CR
	DB	"problem."
	DB	NEXT
;	DB	'【鈴子】：表現がちょっと違うわね。'
	DB	"Reiko:  I don't know how to break this to you, but...",CR,"She can swim now."
	DB	NEXT
;	DB	'【%001】：えっ！？じゃあ・・・ひょっとして？'
	DB	"%001:  Eh? You mean..."
	DB	NEXT
;	DB	'【鈴子】：まだまだ改善の余地はあるけど、少なくとも%001君よりはすじがいいみたいね。'
	DB	"Reiko:  Well, she needs some improvement, but at least she's"
	DB	CR
	DB	"she's doing better than you did."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ........................"
	DB	NEXT
;	DB	'【鈴子】：あ・・・やだ、ゴメン！気に障った？'
	DB	"Reiko:  Oh, I'm sorry, I didn't mean it that way!"
	DB	NEXT
;	DB	'【%001】：・・・あ、そ～じゃなくて。その・・・'
	DB	"%001:  Oh, it's not that. It's just..."
;	DB	NEXT
	DB	FLG,F_COPYI,4,4
	DW	0000H

M11:		;話す　鈴子
;	DB	'【%001】：その・・・俺達のせいで、鈴子さん、ゆっくり泳げなかっただろ？'
	DB	"%001:  Because of all of us, you didn't get a chance"
	DB	CR
	DB	"to swim yourself, did you?"
	DB	NEXT
;	DB	'【鈴子】：う・・・ううん、そんなことないわよ。'
	DB	"Reiko:  Oh. That's okay."
	DB	PAUSE
;	DB	'・・・結構、楽しかったわよ。来てよかった、って思ってる。'
	DB	" I had a good time anyway. I'm glad"
	DB	CR
	DB	"I came."
	DB	NEXT
;	DB	'【%001】：・・・鈴子さん・・・'
	DB	"%001:  Reiko..."
;	DB	PAUSE,CR
;	DB	'・・・・・・そっか。'
;	DB	"Really."
	DB	FLG,F_COPYI,4,5
	DW	0000H

M12:		;話す　鈴子
;	DB	'【鈴子】：何故かしら・・・？'
	DB	"Reiko:  I wonder why it is..."
	DB	NEXT
;	DB	'【%001】：は？'
	DB	"%001:  Why what?"
;	DB	NEXT
;	DB	'【鈴子】：え？べ、別に、その・・・そう、%001君！'
	DB	NEXT
;	DB	'【鈴子】：なんで、運動神経の固まりのような君が泳げないの？'
	DB	"Reiko:  Why is it that you, who are so good at sports, "
	DB	CR
	DB	"can't swim?"
	DB	NEXT
;	DB	'【%001】：・・・なんか、取って付けたような質問だね？'
	DB	"%001:  Why do you want to know?"
	DB	NEXT
;	DB	'【鈴子】：い・・・いいから答えて！'
	DB	"Reiko:  Just tell me!"
	DB	NEXT
;	DB	'【%001】：へぇへぇ・・・'
	DB	"%001:  Heh heh..."
	DB	FLG,F_COPYI,4,6
	DW	0000H

M13:		;話す　鈴子
;	DB	'【%001】：俺・・・小さい頃にさ。'
	DB	"%001:  When I was little..."
	DB	NEXT
;	DB	'【鈴子】：うん・・・'
	DB	"Reiko:  Uh huh..."
	DB	NEXT
;	DB	'【%001】：家族で、海に来た事があったんだ。'
	DB	"%001:  My family came to the beach... I was building a sand",CR,"castle or something at the water's edge."	
	DB	NEXT
;	DB	'【鈴子】：そしたら？'
	DB	"Reiko:  And?"
	DB	NEXT
;	DB	'【%001】：・・・突然、でかい波がきてさ、俺・・・波にさらわれちまったんだ。'
	DB	"%001:  Suddenly, a huge wave came and swept me away with"
	DB	CR
	DB	"it."
	DB	NEXT
;	DB	'【%001】：親父やかーちゃんが気が付いたときには、俺はもう海の中だったらしい。'
	DB	"%001:  By the time my Dad noticed, I was already way out"
	DB	CR
	DB	"to sea."
	DB	NEXT
;	DB	'【鈴子】：それで・・・水恐怖症とかになって、泳げなくなっちゃったの？'
	DB	"Reiko:  So you became afraid of the water because of"
	DB	CR
	DB	"that event?"
	DB	NEXT
;	DB	'【%001】：まあ、水恐怖症はともかく、思い出せる理由はそんなもんかな。'
	DB	"%001:  Well, as far as I can remember, that's probably"
	DB	CR
	DB	"where my fear of the water came from."
	DB	NEXT
;	DB	'【鈴子】：ふう・・・ん。'
	DB	"Reiko:  Interesting..."
	DB	FLG,F_COPYI,4,7
	DW	0000H

M14:		;話す　鈴子
;	DB	'【鈴子】：そうだったんだ・・・'
	DB	"Reiko:  So that's why you're afraid of water."
	DB	NEXT
;	DB	'【%001】：たぶんね。'
	DB	"%001:  I think so."
	DB	NEXT
;	DB	'【%001】：・・・な～んか、なっさけねえなあ、俺。'
	DB	"%001:  Pretty lame, huh?"
	DB	NEXT
;	DB	'【鈴子】：そんなことないって！'
	DB	"Reiko:  No, that's not true!"
	DB	NEXT
;	DB	'【%001】：あ・・・そう？'
;	DB	"%001:  Oh, really?"
;	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ..........................."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..........................."
	DB	NEXT
;	DB	'う～ん、こういう状況で２人して口をつぐんじゃうと・・・'
	DB	"We're both quiet for a time."
	DB	NEXT
;	DB	'なんか、気まずいなあ'
	DB	"It's kind of uncomfortable, actually."
	DB	NEXT
;	DB	'う～～ん・・・話そうにも、話題が・・・'
	DB	"Hmmm, can't think of anything to talk about."
	DB	NEXT
;	DB	'【鈴子】：もう少し、散歩してかない？'
	DB	"Reiko:  Shall we walk a little further?"
	DB	NEXT
;	DB	'【%001】：え？別にいいけど。'
	DB	"%001:  Eh? Well, if you want."
	DB	NEXT
;	DB	'【鈴子】：そう？じゃ・・・'
	DB	"Reiko:  Okay."
	DB	NEXT
;	DB	'すいっ。'
	DB	"*GULP*"
	DB	NEXT
;	DB	'突然、鈴子さんが俺の腕を取る。'
	DB	"Suddenly, Reiko took my arm."
	DB	NEXT
;	DB	'【%001】：え？・・・ちょっと、鈴子さん・・・？'
	DB	"%001:  Eh? What are you doing, Reiko?"
	DB	NEXT
	K_CG "CT01",'K',15,3
;	DB	'【鈴子】：・・・いいじゃない・・・たまには。'
	DB	"Reiko:  You don't mind, do you?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【%001】：ま、いっか。'
	DB	"%001:  Well, okay."
	DB	NEXT
;	DB	'・・・そして、俺たちは立ち止まって海を眺めた。'
	DB	"We both stopped and gazed at the ocean."
	DB	NEXT
;	DB	'もうすぐ、夏が終わる。'
	DB	"Summer will be over soon."
	DB	NEXT
;	DB	'ここでの様々な思い出が、俺の胸に浮かび上がっては消えて行く。'
	DB	"All kinds of memories welled up in my mind and floated"
	DB	CR
	DB	"away. No doubt Reiko was feeling something similar."
	DB	NEXT
;	DB	'そう、俺たちは今、同じ思いを共有・・・・・・'
	DB	"Maybe we were thinking the same thing..."
	DB	NEXT
	B_P1 B_SUDA
	;立ちポーズクリア
;	DB	'ざばざば'
	DB	"*SQUELCH*"
	DB	NEXT
;	DB	'【鈴子】：ね、ねぇ、何かしらあれ？'
	DB	"Reiko:  What is that?"
	DB	NEXT
;	DB	'【%001】：ん！？'
	DB	"%001:  Huh?!"
	DB	NEXT
;	DB	'漆黒の夜の海から、何かが俺たちに近付いてきた。'
	DB	"Something was coming towards us from the pitch-black"
	DB	CR
	DB	"ocean."
	DB	NEXT
;	DB	'【鈴子】：も、もしかして、ウミガメとか・・・'
	DB	"Reiko:  M- Maybe it's a sea turtle..."
	DB	NEXT
;	DB	'【%001】：・・・海坊主・・・'
	DB	"%001:  ....Or one of those salt worm things."
	DB	NEXT
;	DB	'ざばっ！'
	DB	"SQUELCH!"
	DB	NEXT
;	DB	'【鈴子】：きゃあ！'
	DB	"Reiko:  Kyaa!"
	DB	NEXT
;	DB	'【%001】：うわあああああ！'
	DB	"%001:  Yeeeeagh!"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT13",'F',0,15,3 	;校長
;	DB	'【校長】：・・・やっと・・・帰って来られた・・・'
	DB	"Dean:  ...Finally...got back..."
	DB	NEXT
;	DB	'【鈴子】：え！？'
	DB	"Reiko:  Eh?!"
	DB	NEXT
;	DB	'【%001】：こっ、校長先生！？'
	DB	"%001:  It's the dean!"
	DB	NEXT
;	DB	'夜の海から現れたのは、他でもない校長先生だった。'
	DB	"What appeared out of the dark sea was none other than"
	DB	CR
	DB	"the dean!"
	DB	NEXT
;	DB	'【校長】：ん？やあ、%001君じゃあないか。'
	DB	"Dean:  Oh, it's you, %001."
	DB	NEXT
;	DB	'【%001】：いっ、一体何をしてるんですかっ！？'
	DB	"%001:  W- What are you doing out here?!"
	DB	NEXT
;	DB	'【校長】：う～む、それがよく分からないのだよ。'
	DB	"Dean:  You know, I don't really know."
	DB	NEXT
;	DB	'【%001】：は？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【校長】：私ももう年だろーか、前後不覚になるほど酔ってしまうとは。'
	DB	"Dean:  I passed out..."
	DB	NEXT
;	DB	'【校長】：しかも、酔いが覚めてみたら知らない島にいるし・・・'
	DB	"Dean:  And then when I woke up and looked around,"
	DB	CR
	DB	"I was on this island that I've never seen."
	DB	NEXT
;	DB	'【%001】：そっ、それはまたお気の毒に・・・'
	DB	"%001:  Wow, that's really too bad..."
	DB	NEXT
;	DB	'ほ・・・本当のことを知ってるだけに・・・つらい'
	DB	"Whew... knowing the truth sure is tough..."
	DB	NEXT
;	DB	'【校長】：小林先生とお酒を飲むのはもうやめよう・・・'
	DB	"Dean:  I don't think I'll be drinking with Kyoko-"
	DB	CR
	DB	"sensei anymore..."
	DB	NEXT
;	DB	'【%001】：ぜひ、そうするべきですっ！'
	DB	"%001:  Yes, that's definitely a good idea!"
	DB	NEXT
;	DB	'【校長】：・・・？どーしたのかね、%001君。'
	DB	"Dean:  Hm? What do you mean?"
	DB	NEXT
;	DB	'【%001】：え？・・・あ～・・・その～・・・'
	DB	"%001:  Eh? Oh, ah..."
	DB	NEXT
;	DB	'いかん、ついつい本音を吐いてしまった'
	DB	"Oh no...looks like I let the cat slip out of the bag..."
	DB	NEXT
;	DB	'【校長】：・・・そうか・・・そう言うことか・・・'
	DB	"Dean:  ...I see."
	DB	NEXT
;	DB	'げっ、校長先生、今日子先生の企みに気付いた！？'
	DB	"Has the dean figured out Kyoko-sensei's plot?!"
	DB	NEXT
;	DB	'バカバカ俺のバカ！今日子先生が校長先生に怒られるのは構わないけど、その後に真っ先にとばっちりを食うのは俺じゃないか！'
	DB	"I am such an idiot! I mean, it doesn't matter if the"
	DB	CR
	DB	"dean gets mad at Kyoko-sensei, but I'm sure I'll"
	DB	CR
	DB	"be the one who will really have to pay!"
	DB	NEXT
;	DB	'【校長】：%001君は、１－Ａだったね。'
	DB	"Dean:  %001, you're in 1-A, right?"
	DB	NEXT
;	DB	'【%001】：は、はい。'
	DB	"%001:  Y- Yes."
	DB	NEXT
;	DB	'【校長】：・・・君は、今日子先生の「恐ろしさ」が、骨身に染みて分かっているんだねえ。'
	DB	"Dean:  So I'm sure you're very familiar with how scary"
	DB	CR
	DB	"Kyoko-sensei can be."
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【校長】：いやいや、隠す必要はない。'
	DB	"Dean:  It's okay, you don't need to hide it."
	DB	NEXT
;	DB	'【校長】：どうだね、同じ苦しみを味わった者同士だ。%001君も、私が直接指揮を取る『ヒーローアクション部』に入部してみないかね？'
	DB	"Dean:  It's all right, I'm sure you have suffered at"
	DB	CR
	DB	"her hands too. %001, why don't you join the 'Action Hero"
	DB	CR
	DB	"Club'? I'm in charge of the club, you know."
	DB	NEXT
;	DB	'【%001】：え？あの・・・'
	DB	"%001:  Huh? But I..."
	DB	NEXT
;	DB	'【校長】：いや、返事は急がんでよろしい。そろそろ夜も遅いし、ここらで帰るとしようか。'
	DB	"Dean:  You don't have to answer right away. It's"
	DB	CR
	DB	"getting late. I guess I'll head on back."
	DB	NEXT
;	DB	'【%001】：はあ・・・'
	DB	"%001:  Okay."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ........................."
	DB	NEXT
;	DB	'【校長】：では、%001君、そして鈴子君ごきげんよう！'
	DB	"Dean:  Well, %001, Reiko, take care!"
	DB	PAUSE
;	DB	'%001君、いい返事を期待しているぞ！わははははははははははははは！'
	DB	" %001, I'll be ",CR,"expecting your answer! Hahahahaha!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"...................................."
	DB	NEXT
;	DB	'・・・こ・・・こうして・・・'
	DB	"Well, uh..."
	DB	NEXT
;	DB	'最後の最後で淒すぎるインパクトを俺の脳裏に焼き付けて、臨海学校は終わった・・・・・・'
	DB	"And so seaside camp ended, with this truly bizarre encounter,"
	DB	CR
	DB	"forever imprinted on my mind."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS701.OVL',0
	DW	0000H

M15:		;考える　鈴子
;	DB	'・・・きっと１人で泳ぎたかったろーに、俺に泳ぎを教える！って言って・・・'
	DB	"I'm sure she wanted to go swimming by herself, but"
	DB	CR
	DB	"she offered to teach me instead."
	DB	NEXT
;	DB	'昨日は美緒ちゃんに泳ぎを教えて・・・'
	DB	"And then yesterday she taught Mio..."
	DB	NEXT
;	DB	'今日は吉田を指導して・・・'
	DB	"Today she helped Seia..."
	DB	NEXT
;	DB	'・・・結局、自分の時間って、持てなかったんじゃないか？鈴子さん・・・'
	DB	"Poor Reiko, did she end up having any time to herself?"
	DB	FLG,F_COPYI,5,1
	DW	0000H

M16:		;考える　鈴子
;	DB	'なんか、今回、迷惑かけっぱなしだな・・・'
	DB	"It seems like we all just caused her trouble this"
	DB	CR
	DB	"time..."
	DB	NEXT
;	DB	'・・・今回だけに限った事じゃねえか・・・'
	DB	"I wonder if that's happened more than once..."
	DW	0000H


end