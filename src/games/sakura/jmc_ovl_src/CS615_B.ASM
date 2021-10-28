;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　
;		

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

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	"KIYOMI",0
;NN2:	DB	2,	'海',0
NN2:	DB	2,	"OCEAN",0
;NN3:	DB	3,	'月',0
NN3:	DB	3,	"MOON",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　清美
S2:		DW	VV1, NN2,  2, M4, M5		;見る　海
S3:		DW	VV1, NN3,  3, M6		;見る　月
S4:		DW	VV2, NN1,  4, M7, M8, M9, M10, M11, M12, M13		;話す　清美
S5:		DW	VV3, NN1,  5, M14, M15		;考える　清美２


;イニシャルメッセージ
M1:
	DB	BGM,9
	BAK_INIT "AB_17_3"
	DB	BUF,B_COPY01
	T_CG "CT02","F",0,15,1
;	DB	'【%001】：新藤さん、何やってんの？こんなとこで。'
	DB	"%001:  Kiyomi, what are you doing out here?"
	DB	NEXT
;	DB	'【清美】：えっ！？'
	DB	"Kiyomi:  Wah!"
	DB	PAUSE
;	DB	'・・・・・・%001さん？'
	DB	" %001?"
	DB	NEXT
;	DB	'【%001】：よう。'
	DB	"%001:  Yeah."
	DB	NEXT
;	DB	'【清美】：まあ・・・驚きましたわ。'
	DB	"Kiyomi:  Oh...you scared me."
	DB	NEXT
;	DB	'【%001】：悪ィ悪ィ。んで、何やってんの？'
	DB	"%001:  Sorry. What are you up to?"
	DB	NEXT
;	DB	'【清美】：わたくしは・・・そう、お散歩ですわ。%001さんも御一緒にいかがですか？'
	DB	"Kiyomi:  I was taking a walk. Would you like to come with"
	DB	CR
	DB	"me?"
	DB	NEXT
;	DB	'【%001】：そーだな。'
	DB	"%001:  Sure."
	DB G_FLG,G_COPYI,124,1
	DB G_FLG,G_COPYF,120,120
	DB	FLG,F_CALI,120,15
	DB G_FLG,G_COPYG,120,120
	DW	0000H

M2:		;見る　清美
;	DB	'まっすぐ俺を見ている。'
	DB	"She's looking at me."
	DB	NEXT
;	DB	'・・・なんか照れるね、こーゆーのも。'
	DB	"She seems kind of quiet tonight."
	DW	0000H

M3:		;見る　清美
;	DB	'・・・なんだか物憂げな顔で月を見ている。'
	DB	"...She's looking at the moon in a sort of moody way."
	DB	NEXT
;	DB	'・・・なんかあったのかな。'
	DB	"...Something must be up."
	DW	0000H

M4:		;見る　海
;	DB	'・・・俺が泳げないせいか、随分と不気味に見える。'
	DB	"Maybe it's because I can't swim, but it sure looks creepy"
	DB	CR
	DB	"to me."
	DB	NEXT
;	DB	'・・・入り込んだら二度と上がってこれないような、そんな錯覚に陥る。'
	DB	"I have a vision of falling into it and never being able"
	DB	CR
	DB	"to get out again."
	DB	NEXT
;	DB	'・・・あ、俺の場合、あながち錯覚でもないか。'
	DB	"But in my case it's not necessarily just a vision."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;見る　海
;	DB	'・・・俺が泳げないせいか、随分と不気味に見える。'
	DB	"...Maybe it's because I can't swim, but it sure looks"
	DB	CR
	DB	"creepy to me."
	DW	0000H

M6:		;見る　月
;	DB	'綺麗な満月だ。'
	DB	"It's a beautiful full moon."
	DB	NEXT
;	DB	'・・・なんか、海の上に浮かんでいる月って、不思議な感じがする。'
	DB	"...It looks really strange, like it's floating on the"
	DB	CR
	DB	"ocean."
;	DB	NEXT
;	DB	'・・・なんて言ったらいいのかよく分かんねーけど'
;	DB	"...I don't really know what to say"
	DW	0000H


M7:		;話す　清美
;	DB	'【清美】：月が綺麗ですわね・・・'
	DB	"Kiyomi:  The moon really is beautiful, isn't it..."
	DB	NEXT
;	DB	'【%001】：うん・・・って、あれ？'
	DB	"%001:  Um...what?"
	DB	NEXT
;	DB	'【清美】：え？どうかなさいましたか？'
	DB	"Kiyomi:  Hm? Is something the matter?"
	DB	NEXT
;	DB	'【%001】：いや・・・夜の浜辺にいるからさ、海が綺麗、とか神秘的、とか言うかと思ったんだけど・・・'
	DB	"%001:  No, I just thought you would say something about"
	DB	CR
	DB	"the ocean being beautiful or mysterious, since we're"
	DB	CR
	DB	"here on the beach at night..." 
	DB	NEXT
;	DB	'【清美】：あら、でも%001さんは海がお嫌いなんでしょう？'
	DB	"Kiyomi:  But you hate the ocean, don't you %001?"
	DB	NEXT
;	DB	'【%001】：・・・まあね。'
	DB	"%001:  ...Well, yes."
	DB	NEXT
;	DB	'【清美】：でしたら、そのような事は言わない方が良いと思ったのです。'
	DB	"Kiyomi:  So, I thought it better not to say something"
	DB	CR
	DB	"like that."
	DB	NEXT
;	DB	'【%001】：そか・・・気ぃ使わせちゃったな。'
	DB	"%001:  So, I guess I'm spoiling your mood."
	DB	NEXT
;	DB	'【清美】：そのようなことは・・・'
	DB	"Kiyomi:  Oh, no. "
	DB	PAUSE
;	DB	'・・・わたくしは太陽の降り注ぐ明るい海の方が好きですから。'
	DB	"I prefer a bright ocean with the sun"
	DB	CR
	DB	"sparkling on it anyway."
	DB	NEXT
;	DB	'【%001】：・・・さんきゅ。'
	DB	"%001:  Thanks."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:		;話す　清美
;	DB	'【%001】：そう言えば今日は全然見掛けなかったけど、どこにいたの？'
	DB	"%001:  I didn't see you at all today, where were you?"
	DB	NEXT
;	DB	'【清美】：その・・・疲れていたようで、夕方まで寝過ごしてしまいましたの。'
	DB	"Kiyomi:  I guess I was tired. I pretty much slept in all"
	DB	CR
	DB	"day."
	DB	NEXT
;	DB	'【清美】：せっかく海に来ましたのに、もったいないことをしましたわ。'
	DB	"Kiyomi:  After coming all this way to the ocean, I shouldn't"
	DB	CR
	DB	"have wasted the day like that."
	DB	FLG,F_COPYI,4,2
	DB	FLG,F_COPYI,5,1
	DW	0000H

M9:		;話す　清美
;	DB	'【清美】：%001さんは何をなさっていたのですか？'
	DB	"Kiyomi:  What did you do today, %001?"
	DB	NEXT
;	DB	'【%001】：今日は美緒ちゃんと潮干狩りしてた。'
	DB	"%001:  Today I went looking for clams with Mio."
	DB	NEXT
	K_CG "CT02","I",15,2
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ........................."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  What's wrong?"
	DB	FLG,F_COPYI,4,3
	DW	0000H

M10:		;話す　清美
;	DB	'【清美】：%001さん・・・'
	DB	"Kiyomi:  %001..."
	DB	NEXT
;	DB	'【%001】：・・・なに？'
	DB	"%001:  ...Yes?"
	DB	NEXT
;	DB	'【清美】：・・・美緒さんの事・・・どう思っていらっしゃいますか？'
	DB	"Kiyomi:  ...How do you feel about Mio?"
	DB	NEXT
;	DB	'【%001】：え・・・？'
	DB	"%001:  How do I feel about her?"
	DB	NEXT
	K_CG "CT02","R",15,3
;	DB	'【清美】：わ、わたくしったら、一体何を・・・'
	DB	"Kiyomi:  I...I shouldn't have asked..."
	DB	NEXT
;	DB	'【%001】：・・・妹・・・かな？'
	DB	"%001:  She's like a little sister to me, I guess."
	DB	NEXT
	T_CG "CT02","F",0,15,1
;	DB	'【清美】：・・・・・・妹、ですか？'
	DB	"Kiyomi:  ...A younger sister?"
	DB	NEXT
;	DB	'【%001】：ああ。・・・いや～、俺一人っ子だからさ、兄弟ってのに憧れてたんだ。'
	DB	"%001:  Yeah. You know, I'm an only child, so I missed"
	DB	CR
	DB	"out on having sisters and brothers."
	DB	NEXT
;	DB	'【%001】：だから、美緒ちゃんが俺を慕って来てくれたりすると、なんか妹ができたみたいでさ、嬉しいんだよ。'
	DB	"%001:  So, I'm happy that she seeks me out. It's like I've"
	DB	CR
	DB	"found a younger sister."
	DB	FLG,F_COPYI,4,4
	DW	0000H

M11:		;話す　清美
;	DB	'【清美】：・・・そうですか・・・では、鈴子さんの事はどう思っていらっしゃるのですか？'
	DB	"Kiyomi:  Really. And what do you think of Reiko?"
	DB	NEXT
;	DB	'【%001】：鈴子さんは・・・姉さん、かな。'
	DB	"%001:  Reiko? Well, she's like an older sister, I guess."
	DB	NEXT
;	DB	'【清美】：お姉さま・・・'
	DB	"Kiyomi:  An older sister..."
	DB	NEXT
;	DB	'【%001】：そ。なんか、俺、色々メンドー見てもらってるし。・・・正直、あんな姉さんがいたらいいな、とか思った事もあるしね。'
	DB	"%001:  Yeah. She takes care of me... you know, I always"
	DB	CR
	DB	"think that it would be great to have an older sister"
	DB	CR
	DB	"like Reiko."
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  ................................"
	DB	FLG,F_COPYI,4,5
	DW	0000H

M12:		;話す　清美
;	DB	'【%001】：俺・・・この学校来て良かったよ。誠、鈴子さん、新藤さん、美緒ちゃん、中野や吉田や白水さん、それに今日子先生・・・'
	DB	"%001:  I'm really glad I came to this school. Makoto,"
	DB	CR
	DB	"Reiko, you, Mio, Meimi, Seia, Ruri and Kyoko-sensei..."
	DB	NEXT
;	DB	'・・・みんなに会えたんだから。'
	DB	"I'm glad to have met all of you."
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  ..............."
	DB	NEXT
;	DB	'【%001】：な～んて、似合わねえな、俺には。'
	DB	"%001:  Guess I was just lucky to pick this school."
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  ................"
	DB	NEXT
;	DB	'【%001】：・・・新藤さん？どうしたの？'
	DB	"%001:  ...Kiyomi? Is there anything wrong?"
	DB	NEXT
;	DB	'【清美】：は、はい！？・・・いえ、別に、なんでもありませんわ。'
	DB	"Kiyomi:  No! Nothing, nothing at all."
	DB	NEXT
;	DB	'【%001】：そう？'
	DB	"%001:  Really?"
	DB	FLG,F_COPYI,4,6
	DW	0000H

M13:		;話す　清美
;	DB	'【清美】：・・・あの・・・%001さん・・・'
	DB	"Kiyomi:  %001?"
	DB	NEXT
;	DB	'【%001】：何？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【清美】：もう少し、お散歩しませんか？'
	DB	"Kiyomi:  Shall we walk a little further?"
	DB	NEXT
;	DB	'【%001】：え？ああ、いいよ。'
	DB	"%001:  Sure, why not?"
	DB	NEXT
;	DB	'突然、新藤さんが俺の腕を取る。'
	DB	"Suddenly, Kiyomi took my arm."
	DB	NEXT
;	DB	'【%001】：あ、あれ？新藤さん？'
	DB	"%001:  Um, Kiyomi?"
	DB	NEXT
	K_CG "CT02","K",15,4
;	DB	'【清美】：・・・・・・少しくらい、構わないでしょう？'
	DB	"Kiyomi:  You don't mind, do you?"
	DB	NEXT
;	DB	'【%001】：そりゃ、まあ・・・'
	DB	"%001:  Er, well..."
	DB	NEXT
;	DB	'【%001】：・・・・・・ま、いっか。'
	DB	"%001:  Okay."
	DB	NEXT
;	DB	'・・・そして、俺たちは立ち止まって海を眺めた。'
	DB	"We both stopped and gazed at the ocean."
	DB	NEXT
;	DB	'もうすぐ、夏が終わる。'
	DB	"Summer will be over soon."
	DB	NEXT
;	DB	'ここでの様々な思い出が、俺の胸に浮かび上がっては消えて行く。'
	DB	"All kinds of memories welled up in my mind and floated away."
	DB	CR
;	DB	'それは、きっと鈴子さんも同じはずだ。'
	DB	"No doubt Kiyomi was feeling something similar."
	DB	NEXT
;	DB	'そう、俺たちは今、同じ思いを共有・・・・・・'
	DB	"Maybe we were thinking the same thing..."
	DB	NEXT
	K_CG "CT02","D",15,5
;	DB	'【清美】：・・・何かが、泳いでますわ！'
	DB	"Kiyomi:  ...Something's swimming out there!"
	DB	NEXT
;	DB	'【%001】：ん！？'
	DB	"%001:  What?!"
	DB	NEXT
	B_P1 B_SUDA
;	DB	'ざばざば'
	DB	"*SQUELCH*"
	DB	NEXT
;	DB	'【鈴子】：ね、ねぇ、何かしらあれ？'
	DB	"Kiyomi:  What is that?"
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
	DB	"Kiyomi:  M- Maybe it's a sea turtle..."
	DB	NEXT
;	DB	'【%001】：・・・海坊主・・・'
	DB	"%001:  ...Or one of those salt worm things."
	DB	NEXT
;	DB	'ざばっ！'
	DB	"SQUELCH!"
	DB	NEXT
;	DB	'【鈴子】：きゃあ！'
	DB	"Kiyomi:  Kyaa!"
	DB	NEXT
;	DB	'【%001】：うわあああああ！'
	DB	"%001:  Yeeeeagh!"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT13","F",0,15,3 	;校長
;	DB	'【校長】：・・・やっと・・・帰って来られた・・・'
;	DB	'【校長】：・・・やっと・・・帰って来られた・・・'
	DB	"Dean:  ...Finally...got back..."
	DB	NEXT
;	DB	'【鈴子】：え！？'
	DB	"Kiyomi:  Eh?!"
	DB	NEXT
;	DB	'【%001】：こっ、校長先生！？'
	DB	"%001:  The Dean?!"
	DB	NEXT
;	DB	'夜の海から現れたのは、他でもない校長先生だった。'
	DB	"What appeared out of the dark sea was none other than"
	DB	CR
	DB	"the dean."
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
	DB	"Dean:  And then when I woke up and looked around, I"
	DB	CR
	DB	"was on this island that I've never seen."
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
	DB	"I am such an idiot! I mean, it doesn't matter if the dean"
	DB	CR
	DB	"gets mad at Kyoko-sensei, but I'm sure I'll be the one"
	DB	CR
	DB	"who will really have to pay!"
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
	DB	"Dean:  It's all right, I'm sure you have suffered"
	DB	CR
	DB	"at her hands too. %001, why don't you join the 'Action"
	DB	CR
	DB	"Hero Club'? I'm in charge of the club, you know."
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
	DB	"Kiyomi:  .........................."
	DB	NEXT
;	DB	'【校長】：では、%001君、そして鈴子君ごきげんよう！'
	DB	"Dean:  Well, %001, Kiyomi, take care!"
	DB	PAUSE
;	DB	'%001君、いい返事を期待しているぞ！わははははははははははははは！'
	DB	" %001, I'll be ",CR,"expecting your answer! Hahahahaha!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"......................................"
	DB	NEXT
;	DB	'・・・こ・・・こうして・・・'
	DB	"Well, uh..."
	DB	NEXT
;	DB	'最後の最後で淒すぎるインパクトを俺の脳裏に焼き付けて、臨海学校は終わった・・・・・・'
	DB	"And so seaside camp ended, with this truly bizarre"
	DB	CR
	DB	"encounter, forever imprinted on my mind."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS701.OVL',0
	DW	0000H

M14:		;考える　清美
;	DB	'（昨日は、なんかいつもより元気だったな。）'
	DB	"She was much more cheerful than usual yesterday."
	DB	NEXT
;	DB	'（よっぽど海が好きなんだなあ。）'
	DB	"I guess she really likes the ocean."
	DW	0000H

M15:		;考える　清美２
;	DB	'（夕方まで寝てたとはね。どーりで見なかったわけだ。）'
	DB	"She says she slept until evening. So that's why I didn't"
	DB	CR
	DB	"see her all day."
	DB	NEXT
;	DB	'（はしゃぎ過ぎて疲れたんだろ。ま、それだけ海が好きってことだ。）'
	DB	"Probably wore herself out being so cheerful yesterday."
	DB	CR
	DB	"She must like the ocean a whole lot."
	DW	0000H


end