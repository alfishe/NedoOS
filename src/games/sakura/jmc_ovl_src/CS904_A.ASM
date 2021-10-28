;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　
;		鈴子の家

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'ROOM',0
;NN2:	DB	2,	'部屋',0
NN2:	DB	2,	'REIKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　部屋
S2:		DW	VV2, NN2,  2, M3, M4, M5, M6, M7, M8, M9, M10		;話す
S3:		DW	VV3, -1,  3, M11		;考える


;イニシャルメッセージ
M1:
	DB	BGM,12
	BAK_INIT "AB_04_3"
	DB	BUF,B_COPY01
	B_P1 B_SUDA
    DB	BGM,12
    BAK_INIT "AB_04_3"
    DB	BUF,B_COPY01
    B_P1 B_SUDA
    ;	DB	'ここが鈴子さんの家・・・か。'
    DB	"So this is Reiko's house..."
    DB	NEXT
    ;	DB	'ごくっ。'
    DB	"*gulp*"
    DB	NEXT
    ;	DB	'・・・なんか、緊張するなあ。'
    DB	"I'm feeling kind of nervous."
    DB	NEXT
    ;	DB	'しっ、深呼吸でもするか。'
    DB	"I guess I need to breath deeply."
    DB	NEXT
    ;	DB	'すううぅぅぅぅぅぅぅぅぅぅぅぅ・・・'
    DB	"In............."
    DB	NEXT
    ;	DB	'はああぁぁぁぁぁぁぁぁぁぁぁぁ・・・'
    DB	"........And out."
    DB	NEXT
    ;	DB	'・・・・・・・・・'
    DB	"................................"
    DB	NEXT
    ;	DB	'よし、いくぞっ！'
    DB	"Okay, here goes nothing!"
    DB	NEXT
    ;	DB	'ぴんぽーー・・・'
    DB	"*DING DONG!*"
    DB	NEXT
    ;	DB	'がちゃっ'
    DB	"*kacha*"
    DB	NEXT
    ;	DB	'呼び鈴を押したと同時に、鈴子さんがドアを突き破る勢いで飛び出してきた'
    DB	"The door opens just as I ring the bell. It's Reiko."
    DB	NEXT
    	T_CG "CT01","C","R",15,1
    ;	DB	'【鈴子】：%001君！？'
    DB	"Reiko:  %001?"
    DB	NEXT
    ;	DB	'【%001】：・・・はっ・・・早いね・・・鈴子さん。'
    DB	"%001:  Yeah. You surprised me, opening the door like that."
    DB	NEXT
    ;	DB	'【鈴子】：そっ、そう？と、とにかく上がって。'
    DB	"Reiko:  Really? Sorry. Anyway, come on in."
    DB	NEXT
    ;	DB	'【%001】：あ、お、おじゃまします。'
    DB	"%001:  Thanks."
    	BAK_INIT "AB_31"
    	DB	BUF,B_COPY01
    	T_CG "CT01","C",0,15,2
    	DW	0000H
    
M2:		;見る　部屋
    ;	DB	'鈴子さんの部屋だ。'
    DB	"This is Reiko's room."
    DB	NEXT
    ;	DB	'さすがに片づいてる。その上、必要な物のみで構成されている'
    DB	"It's clean. I can tell she prides herself in organizing"
    DB	CR
    DB	"everything."
    DB	NEXT
    ;	DB	'その辺りに、鈴子さんの性格が表れているような気がする。'
    DB	"You can see a person's personality by looking at her room."
    	DW	0000H
    
M3:		;話す　鈴子
    ;	DB	'【鈴子】：あ、ちょっと待っててね、なにか飲み物持ってくるから。'
    DB	"Reiko:  Hang on, and I'll get us something to drink."
    DB	NEXT
    B_P1 B_SUDA
    ;	DB	'【%001】：あ、うん。'
    DB	"%001:  Oh, thanks."
    DB	NEXT
    ;	DB	'【%001】：・・・・・・'
    DB	"%001:  ......................"
    DB	NEXT
    B_P0 B_SUDA
    DB	ANI,A_ON,1
    ;	DB	'【鈴子】：お待たせ、%001君。コーラでいいかしら。'
    DB	"Reiko:  Here you go. Is cola alright?"
    DB	NEXT
    ;	DB	'【%001】：あ、う、うん、いいよ。'
    DB	"%001:  Ah, sure. It's fine."
    DB	NEXT
    ;	DB	'【鈴子】：・・・どうしたの？'
    DB	"Reiko:  What's the matter? You look nervous."
    DB	NEXT
    ;	DB	'【%001】：あ・・・な、なんでもないよ、うん。'
    DB	"%001:  It- It's nothing. Nevermind."
    DB	NEXT
    ;	DB	'【鈴子】：そ、そう？やだ、私ったらなにを気にしてるのかしら。'
    DB	"Reiko:  Are you it's not me, making you nervous?"
    DB	NEXT
    ;	DB	'【%001】：そ、そうだよ、変な鈴子さん。'
    DB	"%001:  No! It's nothing!"
    DB	NEXT
    ;	DB	'【鈴子】：あはははは・・・'
    DB	"Reiko:  Ha ha! I guess not."
    DB	NEXT
    ;	DB	'【%001】：あはは・・・'
    DB	"%001:  Haha..."
    DB	NEXT
    ;	DB	'【鈴子】：・・・'
    DB	"Reiko:  ..........."
    DB	NEXT
    ;	DB	'【%001】：・・・'
    DB	"%001:  ..........."
    	DB	FLG,F_COPYI,2,1
    	DW	0000H
    
M4:		;話す
    ;	DB	'【鈴子】：・・・き、今日は楽しかったわね？'
    DB	"Reiko:  D- Did you have fun at the party today?"
    DB	NEXT
    ;	DB	'【%001】：ああ、・・・しっかし、ほーんと、ウチのクラスの連中と来たら宴会好きぞろいだからなあ。・・・俺も人のこと言えねえけど。'
    DB	"%001:  Yes. But our class likes parties way too much."
    DB	NEXT
    ;	DB	'【鈴子】：そうよねえ・・・考えてみたら、私は１－Ａとはなんの関係もないのよねえ。'
    DB	"Reiko:  Now that you mention it, I'm not even in class 1-A,"
    DB	CR
    DB	"but I'm drinking with you all the time."
    DB	NEXT
    ;	DB	'【%001】：いいんじゃないの？それ言ったら、美緒ちゃんや亜希ちゃんは高校生ですらないし。'
    DB	"%001:  That's alright, it's the same for Aki and Mio."
    DB	NEXT
    ;	DB	'【鈴子】：・・・そうよね。'
    DB	"Reiko:  That's right."
    	DB	FLG,F_COPYI,2,2
    	DW	0000H
    
M5:		;話す
    ;	DB	'【鈴子】：すごく楽しかった・・・この一年間・・・'
    DB	"Reiko:  This has been a good year. I really enjoyed it."
    DB	NEXT
    ;	DB	'【鈴子】：初めて%001君と会ったとき、すごく元気な子だな、と思って。'
    DB	"Reiko:  Remember the time we first met?"
    DB	NEXT
    ;	DB	'【%001】：あ～、あの時ね。'
    DB	"%001:  Oh, yeah. I remember. A lot's happened since then."
    DB	NEXT
    ;	DB	'【鈴子】：それで、部活の勧誘合戦をして・・・'
    DB	"Reiko:  Like recruitment week..."
    DB	NEXT
    ;	DB	'【%001】：あの時は参ったよ。俺、口挟む隙がないんだもん。俺が中心にいるはずなのに。'
    DB	"%001:  That was terrible."
    DB	NEXT
    ;	DB	'【鈴子】：あははは、そう言えばそうだっけ。'
    DB	"Reiko:  That's right."
    	DB	FLG,F_COPYI,2,3
    	DW	0000H
    
    
M6:		;話す
    ;	DB	'【鈴子】：・・・それで、林間学校に行って。'
    DB	"Reiko:  And then camping in Hokkaido." 
    DB	NEXT
    ;	DB	'【%001】：ああ、あったあった。'
    DB	"%001:  I remember that."
    DB	NEXT
    ;	DB	'【鈴子】：・・・その後、臨海学校に行って。'
    DB	"Reiko:  Then the seaside school."
    DB	NEXT
    ;	DB	'【%001】：ああ、鈴子さんに指導してもらったけど、結局泳げるようになんなかったなあ。'
    DB	"%001:  Yeah. In the end, you were never able to teach me"
    DB	CR
    DB	"how to swim."
    DB	NEXT
    ;	DB	'【鈴子】：そうそう。まったく、将来の金メダリストの指導でも泳げないなんて、筋金入りよね。'
    DB	"Reiko:  That's right. Even when a future Olympic gold"
    DB	CR
    DB	"medalist gives you private lessons, you still can't learn"
    DB	CR
    DB	"how to swim!"
    DB	NEXT
    ;	DB	'【%001】：へいへい・・・'
    DB	"%001:  Well, it's scary!"
    	DB	FLG,F_COPYI,2,4
    	DW	0000H
    
    
M7:		;話す
    ;	DB	'【鈴子】：・・・その後の誕生日に、%001君からすてきなプレゼントを貰って・・・'
    DB	"Reiko:  And then there was my birthday, and the wonderful"
    DB	CR
    DB	"present you gave me."
    DB	NEXT
    ;	DB	'【%001】：・・・いやあ、面目ない。あれ、時間がなくってさ、上手くできなかったんだ。'
    DB	"%001:  No, it wasn't very good. I didn't have enough time"
    DB	CR
    DB	"to make it right."
    DB	NEXT
    ;	DB	'【鈴子】：ううん、そんなことない！・・・すっごく、嬉しかった。'
    DB	"Reiko:  No, it was wonderful! I was really happy."
    DB	NEXT
    ;	DB	'【%001】：・・・そう？'
    DB	"%001:  You were?"
    DB	NEXT
    ;	DB	'【鈴子】：うん・・・私の、宝物よ。'
    DB	"Reiko:  Yes. It's like a treasure to me."
    DB	NEXT
    ;	DB	'【%001】：そっか・・・なんか、嬉しいな・・・'
    DB	"%001:  Well, that's good. That makes me happy."
    	DB	FLG,F_COPYI,2,5
    	DW	0000H
    
    
M8:		;話す
    ;	DB	'【鈴子】：ふふ・・・で、その後の学園祭で、%001君ものすごい大活躍だったしね。'
    DB	"Reiko:  And then there was the sports festival."
    DB	NEXT
    ;	DB	'【%001】：あれは俺の意志じゃなかったんだけど・・・'
    DB	"%001:  But I was forced into that..."
    DB	NEXT
    ;	DB	'【鈴子】：でも、絶対に出場種目を減らさなかったわよね？'
    DB	"Reiko:  But we all tried to get you to go out for less"
    DB	CR
    DB	"events."
    DB	NEXT
    ;	DB	'【%001】：・・・約束だったしね。'
    DB	"%001:  Well...I'd promised everyone."
    DB	NEXT
    ;	DB	'【鈴子】：・・・そうね・・・%001君、一度も約束破らなかったもんね。'
    DB	"Reiko:  That's right. And you never break a promise."
    DB	NEXT
    ;	DB	'【鈴子】：・・・すごいわよね・・・'
    DB	"Reiko:  That's really great."
    DB	NEXT
    ;	DB	'【%001】：・・・そんな、大したことじゃないよ・・・一度口にしたことには責任を持たなきゃいけない、そう思っただけなんだ。'
    DB	"%001:  It's nothing, really. I just try to do what I say"
    DB	CR
    DB	"I'll do."
    DB	NEXT
    ;	DB	'【鈴子】：・・・そう言うのを、立派だ、って言うのよ、%001君。'
    DB	"Reiko:  That's really wonderful, though, %001."
    DB	NEXT
    ;	DB	'【%001】：・・・よくわかんねーや。'
    DB	"%001:  I don't know about that..."
    DB	NEXT
    ;	DB	'【鈴子】：・・・よくわかんない・・・か。私も・・・わかんないの。'
    DB	"Reiko:  You don't know... I don't know, either."
    	DB	FLG,F_COPYI,2,6
    	DW	0000H
    
    
M9:		;話す
    ;	DB	'【%001】：・・・なにが？'
    DB	"%001:  Don't know what?"
    DB	NEXT
    ;	DB	'【鈴子】：・・・進路のこと・・・'
    DB	"Reiko:  ....I don't know what I should do about college."
    DB	NEXT
    ;	DB	'【%001】：え？だって、鈴子さん、本鮪大学に行くんじゃ・・・'
    DB	"%001:  What? But I thought you were going to Honmaguro"
    DB	CR
    DB	"University?"
    DB	NEXT
    ;	DB	'【鈴子】：・・・ん・・・でも・・・迷ってるの・・・'
    DB	"Reiko:  I was. But now I'm not sure."
    DB	NEXT
    ;	DB	'【鈴子】：・・・オリンピック出場は私の夢で、本鮪大学に入学することがその近道って事も解ってる。けど・・・'
    DB	"Reiko:  I've always wanted to go to the Olympics, Honmaguro"
    DB	CR
    DB	"University has a great training program. But..."
    DB	NEXT
    ;	DB	'【%001】：けど？'
    DB	"%001:  But?"
    DB	NEXT
    ;	DB	'【鈴子】：・・・・・・わかんないの・・・・・・・'
    DB	"Reiko:  I just don't know what to do?"
    DB	NEXT
    ;	DB	'【%001】：・・・え？なにが・・・'
    DB	"%001:  Why is that?"
    DB	NEXT
    ;	DB	'【鈴子】：・・・・・・'
    DB	"Reiko:  ...................."
    DB	NEXT
    ;	DB	'【%001】：・・・・・・'
    DB	"%001:  ...................."
    DB	NEXT
    ;	DB	'（な、なんか空気が重い・・・）'
    DB	"One of us has to say something...!"
    	DB	FLG,F_COPYI,2,7
    	DW	0000H
    
    
M10:		;話す
    ;	DB	'【%001】：・・・あ、そーだ！'
    DB	"%001:  Oh, I just remembered!"
    DB	NEXT
    ;	DB	'【鈴子】：え！？な、なに？'
    DB	"Reiko:  What?"
    DB	NEXT
    ;	DB	'俺は魚の形のブローチを、手のひらに乗せて差し出した。'
    DB	"I handed Reiko her present, a brooch shaped like a fish."
    DB	NEXT
    ;	DB	'【%001】：鈴子さん、これ、クリスマスプレゼント・・・今度は時間があったから、ちゃんと作れたと思うけど。'
    DB	"%001:  This is your Christmas present. I knew I could"
    DB	CR
    DB	"make a good one if I had enough time."
    DB	NEXT
    ;	DB	'【鈴子】：え？・・・手・・・手作り・・・なの？'
    DB	"Reiko:  .......%001, you made this?"
    DB	NEXT
    ;	DB	'【%001】：ああ・・・気に入ってもらえればいいけど・・・'
    DB	"%001:  Yes. I hope you like it."
    DB	NEXT
    ;	DB	'【鈴子】：ありがとう！！！'
    DB	"Reiko:  Thank you!"
    DB	NEXT
    ;	DB	'鈴子さんはとても嬉しそうに俺の手を取った・・・は、いいけど、なんかこーいうのって、すごく照れる。'
    DB	"Reiko looks happier than I've ever seen her. It's kind"
    DB	CR
    DB	"of embarrassing..."
    DB	NEXT
    ;	DB	'【鈴子】：・・・？どうしたの、%001君・・・・・・・・・あ！やだ、私ったら・・・！'
    DB	"Reiko:  Thank you so much! I don't know what to say..."
    DB	CR
    DB	"I..."
    DB	NEXT
    ;	DB	'・・・鈴子さんは手元に視線を落とすと、そのまま真っ赤になってしまった。'
    DB	"I look at her face, now blushing bright red."
    DB	NEXT
    ;	DB	'時間が・・・止まる。鈴子さんの瞳から、俺は目が離せなくなっていた。'
    DB	"Time stops for us. Our eyes are locked."
    DB	NEXT
    ;	DB	'心臓の音がやけに耳につく静寂の中、鈴子さんはそっと顔を上げた。そして、ゆっくりとその瞼を降ろす。'
    DB	"I'm aware of the sound of my own heart beating."
    DB	NEXT
    DB	"Reiko's lifts her face up slightly and closes her eyes,"
    DB	CR
    DB	"ready to kiss me."
    DB	NEXT
    ;	DB	'こっ・・・これは・・・そういうことなのか・・・？'
    DB	"It was happening just like in a woman's romantic comic"
    DB	CR
    DB	"book."
    DB	NEXT
    ;	DB	'どきどきどきどきっ。'
    DB	"*DOKI DOKI DOKI*"
    DB	NEXT
    ;	DB	'えぇい、うるさいぞ、俺の心臓！もー少し落ちつけ！'
    DB	"Shut up, heart! You're too loud!"
    DB	NEXT
    ;	DB	'どっきん！どっきん！どっきん！どっきん！'
    DB	"*DOKI...DOKI...DOKI*"
    DB	NEXT
    ;	DB	'く・・・お、落ち着こうにも落ち着かん！'
    DB	"I said you're too loud!"
    DB	NEXT
    ;	DB	'・・・・・・・・・・・・・・・そのまま行っけぇえ～！'
    DB	"I had to think of Reiko now."
    DB	NEXT
    ;	DB	'俺は鈴子さんの肩を抱く。抵抗はない。'
    DB	"I put my hands on Reiko's shoulders. She doesn't pull"
    DB	CR
    DB	"away."
    DB	NEXT
    ;	DB	'ゆっくりと、唇を近づけて行く・・・・・・'
    DB	"I brought my lips close to hers."
    DB	NEXT
    ;	DB	'・・・・・・・・・・・・・・・'
    DB	"..................................."
    DB	NEXT
    ;	DB	'【？】：鈴子ちゃ～ん？鈴子ちゃん、いるの～？'
    DB	"???:  Reiko? Are you in there?"
    DB	NEXT
    ;	DB	'【%001】：！？'
    DB	"%001:  !!"
    DB	NEXT
    ;	DB	'【鈴子】：！？'
    DB	"Reiko:  !!"
    DB	NEXT
    ;	DB	'突然の声に、俺は文字通り飛び上がった。なんだ？なんだなんだ？'
    DB	"We both jumped at the sudden voice."
    DB	NEXT
    ;	DB	'【鈴子】：な、な～に！ママ！'
    DB	"Reiko:  What do you want, Mom?"
    DB	NEXT
    ;	DB	'【鈴子の母】：あら、いるの～！'
    DB	"Reiko's mother:  Oh, you are in there. I was just checking"
    DB	CR
    DB	"to see where you were."
    DB	NEXT
    ;	DB	'・・・それだけ言うと、鈴子さんのかーちゃんはなにも言ってこない。'
    DB	"With that, Reiko's mother goes back downstairs."
    DB	NEXT
    ;	DB	'・・・なんだったんだろう？'
    DB	"What the hell?"
    DB	NEXT
    ;	DB	'・・・・・・なんだか、もうここにいちゃいけないような気になってきた。'
    DB	"Suddenly I realize it's time to go."
    DB	NEXT
    ;	DB	'【%001】：あ・・・じゃあ、鈴子さん、俺そろそろ帰るわ。'
    DB	"%001:  Well, I guess I'll be leaving."
    DB	NEXT
    ;	DB	'【鈴子】：あ、%001君・・・！'
    DB	"Reiko:  %001!"
    DB	NEXT
    ;	DB	'・・・ものすごく恥ずかしくなった俺は、猛烈な勢いで帰り支度を済ませ、鈴子さんの家を後にした・・・'
    DB	"Feeling incredibly embarrassed, I got my things together"
    DB	CR
    DB	"and left Reiko's house."
    DB	NEXT
    ;	DB	'・・・・・・・・・・・・・・・・・・はぁ。'
    DB	".............*sigh*"
    DB	NEXT
    	B_O B_WIPE
    	DB G_FLG,G_COPYF,110,110
    	DB	FLG,F_CALI,110,20
    	DB G_FLG,G_COPYG,110,110
    	DB G_FLG,G_COPYI,117,1
    	DB	SINARIO,'CSA01.OVL',0
    	DW	0000H
    
    
    
M11:		;考える
    ;	DB	'・・・なんだか、落ち着かない・・・'
    DB	"Something's not right about this."
    DB	NEXT
    ;	DB	'えぇい、いつも話している鈴子さんじゃないか、なんだってんだよ、おい！？'
    DB	"What's wrong with her?"
    	DW	0000H

end
