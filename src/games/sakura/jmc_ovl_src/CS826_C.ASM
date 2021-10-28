;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　
;		美緒と踊る

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
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'踊る',0
VV4:	DB	4,	'DANCE',0

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	'MIO',0
;NN2:	DB	2,	'まわり',0
NN2:	DB	2,	'AROUND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　美緒
S2:		DW	VV1, NN2,  2, M4		;見る　まわり
S3:		DW	VV2, NN1,  3, M5, M6		;話す　美緒
S4:		DW	VV3, -1,  4, M7		;考える
S5:		DW	VV4, -1,  5, M8, M9, M10, M11		;踊る


;イニシャルメッセージ
M1:
        DB	BGM,24
        BAK_INIT 'AB_27_2'
        DB BUF,B_COPY01
        T_CG "CT03","C",0,10,1
        ;	DB	'【美緒】：あ・・・%001先輩・・・'
        DB	"Mio:  Ah, %001..."
        DB	NEXT
        ;	DB	'【%001】：や、やあ、美緒ちゃん。'
        DB	"%001:  Hi, Mio."
        DB	NEXT
        ;	DB	'【美緒】：ど、どうしたんですか？'
        DB	"Mio:  Is anything wrong?"
        DB	NEXT
        ;	DB	'【%001】：いや、あの・・・美緒ちゃんはダンス、できる？'
        DB	"%001:  No, I just wanted to ask you... Do you know"
        DB	CR
        DB	"how to dance?"
        DB	NEXT
        ;	DB	'【美緒】：え・・・で、でき、できるよ。'
        DB	"Mio:  Um, a little."
        DB	NEXT
        ;	DB	'【%001】：・・・俺に・・・教えて欲しいんだ。'
        DB	"%001:  Would you teach me?"
        DB	NEXT
        ;	DB	'【美緒】：え・・・あたし・・・？・・・・・・うん！いいよ！'
        DB	"Mio:  Me? Sure, I'll do it."
        DB	NEXT
        ;	DB	'【%001】：じ、じゃあ、行こうか。'
        DB	"%001:  Thanks. Let's go."
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・・・・・・・'
        DB	"............................................."
        DB	NEXT
        DB	BGM,8
        E_CG B_FADE,'AE_035'
        ;	DB	'俺は美緒ちゃんにダンスを教わっている。'
        DB	"Mio's teaching me how to dance."
        DB	NEXT
        ;	DB	'正直な話、俺はダンスができない。'
        DB	"When I told her I didn't know how to dance, I was telling"
        DB	CR
        DB	"the truth."
        DB	NEXT
        ;	DB	'・・・単に経験がなかったせいだったりする。'
        DB	"I just never had the chance to learn."
        DB	NEXT
        ;	DB	'いざ踊ってしまえばどうにかなる、とか思ったのは甘かったらしい。'
        DB	"I always thought it was something you could pick up"
        DB	CR
        DB	"without any special lessons, but I was wrong."
        DB	NEXT
        ;	DB	'なにがなんだか分からずにオロオロしている俺に、美緒ちゃんは辛抱強く付き合ってくれている。'
        DB	"Mio's a good teacher."
        DW	0000H
        
M2:		;見る　美緒
        ;	DB	'俺にダンスを教えてくれてる。'
        DB	"She's teaching me how to dance."
        DB	NEXT
        ;	DB	'【美緒】：ほら、%001先輩！'
        DB	"Mio:  %001, you have to pay attention to your feet!"
        DB	NEXT
        ;	DB	'【%001】：あ、ごめん！'
        DB	"%001:  Oh, sorry."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　美緒
        ;	DB	'ちゃんと見てなきゃわかんないけど・・・'
        DB	"If I stare at her, she'll get angry again."
        DB	NEXT
        ;	DB	'ぼーっと見てると怒られるぞ。'
        DB	"I've got to do it casually."
        DW	0000H
        
M4:		;見る　まわり
        ;	DB	'今はまわりのことよりもダンスを覚えることが先決だ。'
        DB	"After I learn how to dance, I'll waste time looking at"
        DB	CR
        DB	"the other people."
        DW	0000H
        
M5:		;話す　美緒
        ;	DB	'【%001】：ごめんな、美緒ちゃん・・・'
        DB	"%001:  I'm sorry, Mio."
        DB	NEXT
        ;	DB	'【美緒】：全然平気だよ！'
        DB	"Mio:  Don't worry about it!"
        DB	NEXT
        ;	DB	'【美緒】：さ、%001先輩！次はこう・・・やってみて！'
        DB	"Mio:  Okay, not, try doing this..."
        DB	NEXT
        ;	DB	'【%001】：え・・・と、こうかな？'
        DB	"%001:  Is this right?"
        DB	NEXT
        ;	DB	'【美緒】：うん、そう！'
        DB	"Mio:  Yes, that's good."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M6:		;話す　美緒
        ;	DB	'【%001】：ありがと、美緒ちゃん。'
        DB	"%001:  Thanks, Mio."
        DB	NEXT
        ;	DB	'【美緒】：え？やだ、%001先輩、まだ終わってないよ？'
        DB	"Mio:  Why are you thanking me? I'm not done teaching you"
        DB	CR
        DB	"yet."
        DB	NEXT
        ;	DB	'【%001】：ああ・・・そうだね。'
        DB	"%001:  Oh, you're right."
        DW	0000H
        
M7:		;考える
        ;	DB	'そ、そんな余裕はないぞ・・・'
        DB	"I don't have time for that."
        DW	0000H
        
M8:		;踊る
        ;	DB	'【美緒】：ううん、違うよ、%001先輩、ここは、こうだよ、こう。'
        DB	"Mio:  No, that's wrong. Try your left foot this way."
        DB	NEXT
        ;	DB	'【%001】：え？こ、こう？',PAUSE,CR,'（ぜ、ぜんぜん分からん）'
        DB	"%001:  Is this right? ",PAUSE,CR,"(I don't know what the hell I'm doing.)"
        DB	NEXT
        ;	DB	'【美緒】：うん、そう！やっぱり先輩、物覚えがいいなあ。'
        DB	"Mio:  Yes, that's good. You're really a fast learner."
        DB	NEXT
        ;	DB	'【%001】：そ、そう？',PAUSE,CR,'（今の、どこが違ったんだろう）'
        DB	"%001:  Really? ",PAUSE,CR,"(How is what I'm doing now different from what I was just"
        DB	CR
        DB	"doing?)"
        DB	NEXT
        ;	DB	'【美緒】：そう、そう・・・あ！%001先輩、そこ、こうだよ！'
        DB	"Mio:  Yes, you're great. Oops, that's wrong..."
        DB	NEXT
        ;	DB	'【%001】：え？こ、こうかな？',PAUSE,CR,'（やっぱり分からんなあ）'
        DB	"%001:  Um, is this right? ",PAUSE,CR,"(I don't know what she wants me to do!)"
        DB	NEXT
        ;	DB	'【美緒】：うん、そう！'
        DB	"Mio:  That's right!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ................................."
        DB	NEXT
        ;	DB	'（どこが違うんだろう？）'
        DB	"I don't understand dancing!"
        DB	FLG,F_COPYI,5,1
        DW	0000H
        
M9:		;踊る
        ;	DB	'【美緒】：そう、その調子！やっぱり、%001先輩ってすごいよ！'
        DB	"Mio:  You're great, %001!"
        DB	NEXT
        ;	DB	'【%001】：・・・へへ、当然。',PAUSE,CR,'（・・・実はあんまりよく分かってないんだけど・・・）'
        DB	"%001:  ....Of course, ha ha. ",PAUSE,CR,"(I don't know what she's so happy about...)"
        DB	NEXT
        ;	DB	'【美緒】：えっと、次はこう！'
        DB	"Mio:  Okay, let's try the next step."
        DB	NEXT
        ;	DB	'【%001】：なんだ、簡単だな。こうかっ。'
        DB	"%001:  Hey, this is really easy.....Whoops!"
        DB	NEXT,GATA,1
        ;	DB	'ずで～ん。'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'【%001】：いてててて・・・あれ？'
        DB	"%001:  Ouch."
        DB	NEXT
        ;	DB	'【美緒】：・・・%001先輩、大丈夫？'
        DB	"Mio:  .....%001, are you alright?"
        DB	NEXT
        ;	DB	'【%001】：あ、ああ、大丈夫。（なんで転んだんだ？俺）'
        DB	"%001:  Yes, I'm fine. I wonder what happened back there."
        DB	FLG,F_COPYI,5,2
        DW	0000H
        
M10:		;踊る
        ;	DB	'【美緒】：次は、こう・・・ね？'
        DB	"Mio:  Next, try this."
        DB	NEXT
        ;	DB	'【%001】：うん。え・・と、こう？'
        DB	"%001:  Is this right?"
        DB	NEXT
        ;	DB	'ぐら・・・'
        DB	"*SLIP*"
        DB	NEXT
        ;	DB	'【美緒】：あ！あぶない、%001せんぱ・・・！'
        DB	"Mio:  Oh! Be careful, %001!"
        DB	NEXT
        ;	DB	'【%001】：おっとっと！'
        DB	"%001:  ....Not again!"
        DB	NEXT
        ;	DB	'またスッ転びそうになった俺を、美緒ちゃんが支えてくれた。'
        DB	"Almost falling, I managed to grab ahold of Mio at the last"
        DB	CR
        DB	"moment."
        DB	NEXT
        ;	DB	'【%001】：あ～ぶねぇ。ありがとな美緒ちゃん・・・？'
        DB	"%001:  That was dangerous. I almost went down again."
        DB	NEXT
        ;	DB	'【美緒】：あ・・・'
        DB	"Mio:  %001..."
        DB	NEXT
        ;	DB	'・・・美緒ちゃんの顔が、わずか３センチの距離にあった。'
        DB	"My face was just an inch away from Mio's."
        DB	NEXT
        ;	DB	'一瞬の沈黙。',PAUSE,'俺達はあわてて飛びのいた。'
        DB	"There was a silence. ",PAUSE,"And then I moved away from her."
        DB	NEXT
        ;	DB	'【%001】：・・・つ、続けようか、',PAUSE,'・・・踊りの練習。'
        DB	"%001:  .....Well, l- let's get on with the dance lessons."
        DB	NEXT
        ;	DB	'【美緒】：・・・う、うん。'
        DB	"Mio:  ......Okay."
        DB	FLG,F_COPYI,5,3
        DW	0000H
        
M11:		;踊る
        ;	DB	'【美緒】：すごいすごい、もうほとんど完璧だね！'
        DB	"Mio:  You're almost perfect!"
        DB	NEXT
        ;	DB	'【%001】：え？そーかな？'
        DB	"%001:  Really? I don't know about that."
        DB	NEXT
        ;	DB	'【美緒】：うん、まだちょっと危なっかしいけど、さっきよりは随分上手になったよ、%001せんぱ・・・'
        DB	"Mio:  You're still a little wobbly, but you've improved"
        DB	CR
        DB	"a lot."
        DB	NEXT,GATA,1
        ;	DB	'ずで～ん。'
        DB	"*SMASH*"
        DB	NEXT
        ;	DB	'【%001】：いてててて・・・'
        DB	"%001:  Ouch!"
        DB	NEXT
        ;	DB	'【美緒】：・・・%001先輩、ひょっとして遊んでる？、'
        DB	"Mio:  .....%001, are you doing that on purpose?"
        DB	NEXT
        ;	DB	'【%001】：いや・・・わざとじゃないんだけど・・・'
        DB	"%001:  No, I'm not..."
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・・・・・・・'
        DB	"................................................"
        DB	NEXT
        ;	DB	'俺は美緒ちゃんのおかげでどうにか人並に踊れるようになった。'
        DB	"Thanks to Mio I was soon able to dance with the other"
        DB	CR
        DB	"dancers."
        DB	NEXT
        ;	DB	'・・・美緒ちゃんが俺に合わせてくれるからだけど。'
        DB	"Although Mio was helping me quite a bit."
        DB	NEXT
        ;	DB	'【美緒】：・・・先輩って、ホントにすぐになんでも出来ちゃうんだ・・・。'
        DB	"Mio:  %001, you're really a fast learner."
        DB	NEXT
        ;	DB	'【%001】：俺がこうして踊れるのは、美緒ちゃんが俺に合わせてくれるからだよ。一人で踊れって言われたらまたコケまくるだろーな。'
        DB	"%001:  I couldn't do any of this on my own. It's all"
        DB	CR
        DB	"because you're leading me, keeping me from making"
        DB	CR
        DB	"mistakes."
        DB	NEXT
        ;	DB	'【%001】：・・・だからさ。今日は俺がコケないように、最後まで一緒に踊ってくれねーか？'
        DB	"%001:  .....I'm going to do my best to finish the evening"
        DB	CR
        DB	"without falling anymore."
        DB	NEXT
        ;	DB	'【美緒】：・・・うん！'
        DB	"Mio:  That's good."
        DB	NEXT
        ;	DB	'・・・月明かりの下、俺と美緒ちゃんは心ゆくまで踊った。'
        DB	".....In the silver moonlight, Mio and I danced and"
        DB	CR
        DB	"danced."
        DB	NEXT
        ;	DB	'今夜の月を、俺はずっと忘れないだろう。'
        DB	"I'll never forget that moonlit night."
        DB	NEXT
        DB	"...................................................."
        DB	NEXT
        DB G_FLG,G_COPYI,136,1
        DB G_FLG,G_COPYF,130,130
        DB	FLG,F_CALI,130,20
        DB G_FLG,G_COPYG,130,130
        DB	SINARIO,'CS901.OVL',0
        DW	0000H


end
