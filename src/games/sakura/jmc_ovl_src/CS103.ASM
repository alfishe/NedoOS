;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
	
;		シーン　１０３
;		
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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,NN3,-1
CM3:	DW	VV3,	NN3,-1
CM4:	DW	VV4,	NN3,NN4,-1

;VV1:	DB	1,	"探す",0
VV1:	DB	1,	"LOOK FOR",0
;VV2:	DB	2,	"見る",0
VV2:	DB	2,	"LOOK",0
;VV3:	DB	3,	"話す",0
VV3:	DB	3,	"TALK",0
;VV4:	DB	4,	"考える",0
VV4:	DB	4,	"THINK",0

;NN1:	DB	1,	"自分の席",0
NN1:	DB	1,	"YOUR SEAT",0
;NN2:	DB	2,	"講堂",0
NN2:	DB	2,	"LECTURE HALL",0
;NN3:	DB	3,	"女生徒",0
NN3:	DB	3,	"FEMALE STUDENT",0
;NN4:	DB	4,	"自分のクラス",0
NN4:	DB	4,	"YOUR CLASS",0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;探す　自分の席
S2:		DW	VV2, NN2,  2, M5				;見る　講堂
S3:		DW	VV2, NN3,  3, M6				;見る　女生徒
S4:		DW	VV3, NN3,  4, M7, M8, M9		;話す　女生徒
S5:		DW	VV4, NN4,  5, M10				;考える　自分のクラス
S6:		DW	VV4, NN3,  6, M11, M12			;考える　女生徒２


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT "AB_21"
	B_P1 B_SUDA
;	DB	"俺が講堂に駆け込んだ時、大半の生徒は既に席に着いていた。"
	DB	"When I burst into the lecture hall, most of the other"
	DB	CR
	DB	"students were already in their seats."
	DB	NEXT
;	DB	"まだ校長やらなんやらの話が始まってないから、式自体には間に合ったらしい。"
	DB	"The dean had yet to start his boring speech. I was"
	DB	CR
	DB	"in time for the ceremony"
	DB	C_BLD,C_N_ON,2,2		;見る　女生徒　消し
	DB	C_BLD,C_V_ON,3		;話す　消し
	DB	C_BLD,C_N_ON,4,1		;考える　女生徒　消し
	DW	0000H

M2:		;探す　自分の席
;	DB	"（さて・・・俺の席は一体どこにあるんだ？）"
	DB	"Now, where is my seat?"
	DB	NEXT
;	DB	"・・・・・・・・・・・・"
	DB	"Hmmm..."
	DB	NEXT
;	DB	"（分からん。）"
	DB	"Can't find it."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;探す　自分の席
;	DB	"（・・・見たところ、開いてる席は見当たらない。）"
	DB	"I can't see any place to go..."
	DB	NEXT
;	DB	"（どうやって探したもんか？）"
	DB	"How am I supposed to find where to sit?"
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;探す　自分の席
;	DB	"（・・・参ったな・・・）"
	DB	"Now what?"
	DB	NEXT
;	DB	"【？】：山神さん！"
	DB	"???:  Yamagami-san!"
	DB	NEXT
;	DB	"【%001】：んん？"
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	"【？】：山神　%001さん、こちらですわ！"
	DB	"???:  %001 Yamagami-san, over here!"
	DB	NEXT
;	DB	"声のする方に目をやると、眼鏡の女の子がこっちに向かって手を振っていた。"

	DB	"I look over to where the voice came from. A woman in"
	DB	CR
	DB	"glasses is waving at me."
	DB	NEXT
	E_CG B_NORM,"AE_002"		;清美アップ
;	DB	"【%001】：お、おう。"
	DB	"%001:  Uh, hello."
	DB	NEXT
;	DB	"【清美】：よかったですわ。わたくし、山神さんが入学式においでにならないのかと心配しておりましたの。"
	DB	"Kiyomi:  I'm so relieved. I was worried that you wouldn't"
	DB	CR
	DB	"make it to the entrance ceremony."
	DB	NEXT
;	DB	"【%001】：ははは・・・"
	DB	"%001:  Uh, yeah..."
	DB	NEXT
;	DB	"（・・・誰だろう？）"
	DB	"Who the hell is she...?"
	DB	C_BLD,C_N_OFF,2,2		;見る　女生徒　出し
	DB	C_BLD,C_V_OFF,3		;話す　出し
	DB	C_BLD,C_N_OFF,4,1		;考える　女生徒　出し
	DB	C_BLD,C_V_ON,1		;探す　出し
	DW	0000H

M5:		;見る　講堂
;	DB	"（講堂には一年生全部に先生達がいる。）"
	DB	"All the freshmen and teachers are here."
	DB	NEXT
;	DB	"（まだ式は始まってない。セーフだな。）"
	DB	"I'm glad I made it in time."
	DW	0000H

M6:		;見る　女生徒
;	DB	"（う～・・・・・・）"
;	DB	"Hmmm..."
;	DB	NEXT
;	DB	"（やっぱ、見覚えないな。）"
	DB	"Where have I seen this person before?"
	DB	NEXT
;	DB	"（でも向こうは俺を知ってるみたいだ。そして俺も向こうを知ってると思ってるらしい。）"
	DB	"Looks like she knows me. And it looks like I should know"
	DB	CR
	DB	"her..."
	DW	0000H

M7:		;話す　女生徒
;	DB	"【%001】：あのさ・・・"
	DB	"%001:  Uh..."
	DB	NEXT
;	DB	"【清美】：そうそう、まだお礼を申し上げておりませんでしたね。"
	DB	"Kiyomi:  Sorry, I haven't thanked you yet."
	DB	NEXT
;	DB	"【%001】：え？"
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	"【清美】：その節は大変お世話になりました。どうもありがとうございます。"
	DB	"Kiyomi:  You were a big help. Thank you very much for what you"
	DB	CR
	DB	"did."
	DB	NEXT
;	DB	"【%001】：はあ・・・？"
	DB	"%001:  What?"
	DB	FLG,F_COPYI,4,1
	DB	FLG,F_COPYI,6,1
	DW	0000H

M8:		;話す　女生徒
;	DB	"【清美】：そういえば、自己紹介をしておりませんでしたわね。"
	DB	"Kiyomi:  Oh, I haven't introduced myself, have I?"
	DB	NEXT
;	DB	"【清美】：わたくし、新藤　清美と申します。今後とも、よろしくお願い致しますわ。"
	DB	"Kiyomi: I'm Kiyomi Shinfuji. Nice to meet you."
	DB	NEXT
;	DB	"【%001】：はあ、これは御丁寧にわざわざどうも。"
	DB	"%001:  Uh, nice to meet you too."
	DB	NEXT
;	DB	"【%001】：俺は山神　%001・・・って、知ってるんだな。"
	DB	"%001:  I'm %001 Yamagami... But you know that already."
	DB	NEXT
;	DB	"【清美】：あの後、わたくしずいぶん貴方のことを探しましたのよ。"
	DB	"Kiyomi:  I searched for you for a long time."
	DB	NEXT
;	DB	"「山神」という名字は珍しいですから、すぐに見つかると考えていたのですが・・・"
	DB	"Kiyomi:  Yamagami is an unusual name. I thought it would"
	DB	CR
	DB	"be easy to find you, but..."
	DB	NEXT
;	DB	"【%001】：そのことだけど・・・"
	DB	"%001:  Um, that's nice."
	DB	NEXT
;	DB	"【清美】：でもこうして山神さんと同じ学校に入学出来た上、同じクラスになれるなんて、ただの偶然とは思えませんわよね。"
	DB	"Kiyomi:  It's amazing that we ended up in the same school."
	DB	CR
	DB	"We're even in the same class. It can't be just coincidence."
	DB	NEXT
;	DB	"【%001】：その・・・"
	DB	"%001:  Um, right..."
	DB	NEXT
;	DB	"【清美】：もしかしたら、わたくしたちは運命の糸で結ばれているのかもしれませんわね。"
	DB	"Kiyomi:  We must have been fated to be to be together."
	DB	NEXT
;	DB	"【%001】：そ"
	DB	"%001: ............................................"
	DB	NEXT
;	DB	"【清美】：あらいやですわ、わたくしったら「結ばれる」だなんて。"
	DB	"Kiyomi:  Wow. Two spirits, bound together by destiny..."
	DB	NEXT
;	DB	"（・・・会話にならない・・・。）"
	DB	"This is getting me nowhere..."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M9:		;話す　女生徒
;	DB	"（・・・さすがに俺の怪訝そうな顔に気付いたらしい。）"
	DB	"Confusion must be written on my face."
	DB	NEXT
;	DB	"【清美】：山神さん・・・もしかして、覚えてらっしゃいませんか？"
	DB	"Kiyomi:  Could it be? You don't remember?"
	DB	NEXT
;	DB	"【%001】：・・・悪ィ。俺、お礼言われるようなことはした覚え無いんだけど・・・"
	DB	"%001:  I'm sorry. I don't remember doing anything to be"
	DB	CR
	DB	"thanked for."
	DB	NEXT
;	DB	"【清美】：あれをお忘れになってしまったのですか・・・。"
	DB	"Kiyomi:  You forgot all about it?"
	DB	NEXT
;	DB	"【清美】：では、お話し致します。きっとすぐに思い出していただけますわ。"
	DB	"Kiyomi:  Then I will just have to tell you. I'm sure you'll"
	DB	CR
	DB	"remember."
	DB	NEXT
;	DB	"【清美】：あれは・・・"
	DB	"Kiyomi:  It was about a year ago..."
	DB	NEXT
;	DB	"「え～、それでは平成８年度、入学式を始めます。一同、起立。」"
	DB	"Dean:  Ahem... All students please rise."
	DB	NEXT
;	DB	"新藤さんが話を始めた途端に、入学式が厳かに始まってしまった。"
	DB	"Just when she was starting to speak, the ceremony started."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT13","F",0,15,1
;	DB	"【校長】：あ～、私がこの葉隠高校の校長、斎藤　達彦である。"
	DB	"Dean:  I'm Katsuhiko Saito, Dean of Kotobuki"
	DB	CR
	DB	"Junior College."
	DB	NEXT
;	DB	"【校長】：これから三年間、諸君と共に血と汗と涙を流し、青春のなんたるかを学んで行こうと思う。"
	DB	"Dean:  For the next three years we will shed blood,"
	DB	CR
	DB	"sweat, and tears..."
	DB	NEXT
;	DB	"【校長】：さて諸君！青春とは何だろう！"
	DB	"Dean:  But for now, I want someone to tell me what it"
	DB	CR
	DB	"means to be young."
	DB	NEXT
;	DB	"【校長】：そこのキミ！そう、右から３列目の一番前のキミだ！"
	DB	"Dean:  You at the end of the third row!"
	DB	PAUSE,CR
;	DB	"【生徒Ａ】：ぼ、ぼくですか！？"
	DB	"Student A:  M- Me?"
	DB	NEXT
;	DB	"【校長】：そうキミだ！さあ、キミにとって青春とはなんだね？"
	DB	"Dean:  Yes you! What is youth to you?"
	DB	PAUSE,CR
;	DB	"【生徒Ａ】：え、ええと、スポーツかな？"
	DB	"Student A:  Um, sports?"
	DB	NEXT
;	DB	"【校長】：スポーツか！それもいいだろう！"
	DB	"Dean:  Sports, huh? Very well!"
	DB	NEXT
;	DB	"【校長】：その隣の女の子はどうかな？"
	DB	"Dean:  And you, the girl next to him?"
	DB	NEXT
;	DB	"【生徒Ｂ】：・・・恋（ぽっ）"
	DB	"Student B:  ...Love? *blush*"
	DB	NEXT
;	DB	"【校長】：うむ！それもまた青春だ！"
	DB	"Dean:  Ahem! Okay, that'll do!"
	DB	NEXT
;	DB	"【校長】：中には勉強に青春を賭けてるものもいるだろう！"
	DB	"Dean:  ...And studying, is that part of youth?"
	DB	PAUSE
;	DB	"・・・いるよね？"
	DB	" Well?"
	DB	NEXT
;	DB	"【校長】：とにかく我が葉隠高校は、諸君の青春のニーズに全力で答えていきたいと思う！以上！"
	DB	"Dean:  Anyway, at Kotobuki Junior College, we try"
	DB	CR
	DB	"to meet all of the needs of youth! That is all!"
	DB	NEXT
;	DB	"満場の拍手に送られて、校長先生がステージを降りた。"
	DB	"Showered the applause of a full hall, the Dean"
	DB	CR
	DB	"left the stage."
	DB	NEXT
;	DB	"・・・その後、教頭やら学年主任やらが長くてつまらない話を延々と",CR,"した挙げ句、業を煮やした校長が市会議員からマイクをひったくって",CR,"「以上、終わり！」と宣言するまで、入学式は続いたのだった。
	DB	"After that the other teachers made their long and boring"
	DB	CR
	DB	"speeches. It continued until the dean took the mike"
	DB	CR
	DB	"from a city councilman to put an end to the cermony."
	DB	NEXT
	DB SINARIO,"CS104.OVL",0
	DW	0000H

M10:		;考える　自分のクラス
;	DB	"（・・・そういやあ・・・俺、何組なんだ？）"
	DB	"Come to think of it, I don't even know what class I'm in."
	DB	NEXT
;	DB	"（・・・クラス発表見てくりゃよかった・・・）"
	DB	"I have to look at the class registry."
	DW	0000H

M11:		;考える　女生徒１
;	DB	"（・・・前にどっかで会ったっけか？）"
	DB	"Have I met her before?"
	DW	0000H

M12:		;考える　女生徒２
;	DB	"（どうやら、俺の事知ってるらしいな。）"
	DB	"She seems to know a lot about me."
	DB	NEXT
;	DB	"（もしかして、中学かどっかで同級生だったとか？）"
	DB	"Could we have been in the same class before?"
	DB	NEXT
;	DB	"（・・・だめだ、ど～～～～～～しても、思いだせん）"
	DB	"I can't remember her at all."
	DW	0000H


end
