;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０４
;		体育祭２日前　練習最終日
        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,-1
CM2:	DW	VV2,	NN1,NN2,NN3,NN4,NN5,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	'MAKOTO',0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	'REIKO',0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'KIYOMI',0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	'MIO',0
;NN5:	DB	5,	'恵依美',0
NN5:	DB	5,	'MEIMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　誠
S2:		DW	VV1, NN2,  2, M4, M5		;見る　鈴子
S3:		DW	VV1, NN3,  3, M6		;見る　清美
S4:		DW	VV1, NN4,  4, M7, M8		;見る　美緒
S5:		DW	VV1, NN5,  5, M9, M10		;見る　恵依美
S6:		DW	VV2, NN1,  6, M11, M12		;話す　誠２
S7:		DW	VV2, NN2,  7, M13, M14, M15, M16		;話す　鈴子４
S8:		DW	VV2, NN3,  8, M17, M18		;話す　清美２
S9:		DW	VV2, NN4,  9, M19, M20, M21		;話す　美緒３
S10:		DW	VV2, NN5,  10, M22, M23, M24		;話す　恵依美３
S11:		DW	VV3, -1,  11, M25, M26		;考える


;イニシャルメッセージ
M1:
        DB	BGM,6
        B_O B_FADE
        ;	DB	'・・・翌日、昼休み。'
        DB	".........The next day, lunchtime."
        DB	NEXT
        ;	DB	'【鈴子】：%001く～ん！',CR
        ;	DB	PAUSE
        ;	DB	'【美緒】：%001先輩！'
        DB	"Reiko:  %001!",CR
        DB	PAUSE
        DB	"Mio:  Oh, %001!"
        DB	NEXT
        ;	DB	'【鈴子・美緒】：お昼一緒に食べよっ！'
        DB	"Reiko/Mio:  Please eat lunch with me!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ........................"
        DB	PAUSE
        ;	DB	'すぴ～・・・・・・・・・'
        DB	"Zzzzzzzz....."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・',CR
        ;	DB	'【美緒】：・・・・・・・・・'
        DB	"Reiko:  ........................",CR
        DB	"Mio:  ........................"
        DB	NEXT
        ;	DB	'【誠】：こら、%001起きろ。'
        DB	"Makoto:  %001, wake up!"
        DB	PAUSE
        ;	DB	'鈴子さん達が来たぞ。'
        DB	" Reiko and Mio are here!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ...................."
        DB	PAUSE
        BAK_INIT "AB_36_3"
        B_P1 B_SUDA
        ;	DB	'むに？'
        DB	" What?"
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT01","W",0,35,1
        ;	DB	'【鈴子】：・・・もしかして、午前中ずっと寝てた訳？'
        DB	"Reiko:  Have you been sleeping during your morning class?"
        DB	NEXT
        T_CG1 "CT08","W",0,0,8
        DB ANI,A_ON,1
        ;	DB	'【恵依美】：うん、そりゃあも～景気よく寝てたわよぉ。'
        DB	"Meimi:  Yes, he was."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ........................"
        DB	PAUSE
        ;	DB	'ふに？'
        DB	"Huh?"
        DB	NEXT
        ;	DB BUF,B_COPY01
        ;	T_CG "CT08","W",0,0,8
        ;	DB	'【恵依美】：・・・・・・まだ寝足りないみたいだけどね。'
        DB	"Meimi:  He's not awake yet."
        DB	PAUSE
        ;	DB	'ほら、しゃっきりしなさい！'
        DB	" Hey, %001, wake up!"
        DB	NEXT
        DB	FLASH,3
        ;	DB	'すぱかーん！'
        DB	"*SMACK*"
        DB	NEXT
        ;	DB	'【%001】：・・・'
        DB	"%001:  Ouch! That hurts!"
        DB	NEXT
        DB BUF,B_COPY01
        TU_CG "CT01","W",0,35,1
        T_CG "CT03","W",0,10,3
        DB ANI,A_ON,1
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ................."
        DB	PAUSE
        ;	DB	'やあ、鈴子さんに美緒ちゃん。'
        DB	"Ah, Reiko and Mio. Good morning."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・',CR
        ;	DB	'【美緒】：・・・・・・・・・'
        DB	"Reiko:  ............................",CR
        DB	"Mio:  ............................"
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT08","W",0,0,8
        ;	DB	'【恵依美】：・・・・・・やれやれ・・・・・・'
        DB	"Meimi:  ............................"
        DW	0000H
        
M2:		;見る　誠
        ;	DB	'こいつはこいつなりに気を使ってくれている・・・'
        DB	"He's worried about me, although he won't show it."
        DB	NEXT
        ;	DB	'・・・と思っていいんだよな？'
        DB	"........I think. It's kind of hard to tell with him." 
        ;	DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　誠
        ;	DB	'・・・中野のものすごい蹴りを喰らってうめいている。'
        DB	"He's in pain from Meimi's kick."
        EF_SET 101
        DW	0000H
        
M4:		;見る　鈴子
        ;	DB	'心配そうだけど、今までに比べるとどこかほっとして見える。'
        DB	"She looks worried, although not as much as before."
        DB	NEXT
        ;	DB	'・・・まあ、練習も今日で終わりだから、ってとこだろーな。'
        DB	"Well, my practice ends today, so she doesn't have to"
        DB	CR
        DB	"worry anymore."
        ;	DB	FLG,F_COPYI,2,1
        DW	0000H
        
M5:		;見る　鈴子
        ;	DB	'呆気にとられて誠を見ている。'
        DB	"She's looking at Makoto."
        DB	NEXT
        ;	DB	'・・・まあ、誰でも驚くわなぁ・・・'
        DB	"I wonder what she's thinking."
        EF_SET 102
        DW	0000H
        
M6:		;見る　清美
        ;	DB	'ここにはいない・・・'
        DB	"She's not here."
        DB	NEXT
        ;	DB	'どこ行ったんだろう？'
        DB	"I wonder where she is."
        DW	0000H
        
M7:		;見る　美緒
        ;	DB	'今日も今日とて心配そーな顔を俺に向けてる。'
        DB	"She's looking at me with a worried expression on her face."
        DB	NEXT
        ;	DB	'心配しなくても、練習は今日で終わりなんだけどな。'
        DB	"Well, practice ends today, so she doesn't have to worry"
        DB	CR
        DB	"anymore."
        ;	DB	FLG,F_COPYI,4,1
        DW	0000H
        
M8:		;見る　美緒
        ;	DB	'心配そーに誠を見ている。'
        DB	"She's looking at Makoto with a worried expression on her"
        DB	CR
        DB	"face."
        DB	NEXT
        ;	DB	'・・・今のは誠の自業自得だと思うぞ。'
        DB	"It's his own fault... He should think before he opens his"
        DB	CR
        DB	"mouth like that."
        EF_SET 104
        DW	0000H
        
M9:		;見る　恵依美
        ;	DB	'ちょっと不機嫌に見える。'
        DB	"She looks a little upset."
        DB	NEXT
        ;	DB	'まあ、ちょいと迷惑かけちまったしなあ。'
        DB	".....Well, that's kind of understandable."
        ;	DB	FLG,F_COPYI,5,1
        DW	0000H
        
M10:		;見る　恵依美
        ;	DB	'怒って出ていったぞ。'
        DB	"She got angry and left."
        DB	NEXT
        ;	DB	'・・・まったく、誠も余計なことを・・・'
        DB	"What was Makoto thinking?"
        EF_SET 105
        DW	0000H
        
M11:		;話す　誠１
        DB BUF,B_COPY01
        T_CG "CT14","W",0,30,4
        ;	DB	'【誠】：しっかし、良く保ったよなお前。真面目と言うかバカ付きお人好しと言うか・・・'
        DB	"Makoto:  Well, I'm glad the practice is finally over. I"
        DB	CR
        DB	"don't know if you're a hero or a fool, though, for"
        DB	CR
        DB	"letting yourself get roped into this."
        DB	NEXT
        ;	DB	'【%001】：・・・誠。褒めるかけなすかどっちかにしてくれ。'
        DB	"%001:  ...Makoto, are you trying to praise me or what?"
        ;	DB	FLG,F_COPYI,6,1
        DW	0000H
        
M12:		;話す　誠２
        ;	DB	'【%001】：誠・・・生きてるか？'
        DB	"%001:  Makoto, are you alive?"
        DB	NEXT
        ;	DB	'【誠】：・・・じに゛ぞう゛・・・'
        DB	"%001:  Guess not."
        EF_SET 106
        DW	0000H
        
M13:		;話す　鈴子１
        DB BUF,B_COPY01
        T_CG "CT01","W",0,35,1
        ;	DB	'【鈴子】：・・・・・・大丈夫なの？'
        DB	"Reiko:  ...Will you be alright?"
        DB	NEXT
        ;	DB	'【%001】：ああ、全然平気。'
        DB	"%001:  Ah, I'll be fine."
        DB	NEXT
        ;	DB	'【鈴子】：・・・そう？'
        DB	"Reiko:  ........I wonder."
        DB	FLG,F_COPYI,7,1
        DW	0000H
        
M14:		;話す　鈴子２
        DB BUF,B_COPY01
        T_CG "CT01","W",0,35,1
        ;	DB	'【%001】：ま、大丈夫じゃなくたって今日で終わりだ。'
        DB	"%001:  Well, in any event, the practice ends today."
        DB	PAUSE
        ;	DB	'流石に、ほっとするな。'
        DB	" I'm"
        DB	CR
        DB	"really glad it's over."
        DB	NEXT
        ;	DB	'【鈴子】：・・・そうよね。%001君、ホントに良く頑張ったわ。'
        DB	"Reiko:  That's true. You really worked hard, %001."
        DB	NEXT
        ;	DB	'【%001】：・・・いやあ、そ～でもないよ。'
        DB	"%001:  No, not really..."
        DB	NEXT
        ;	DB	'【鈴子】：謙遜しなくってもいいのよ。あの練習をこなしたんですもの。'
        DB	"Reiko:  Don't be so honest. You were terrific."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・そ、そーかな？'
        DB	"%001:  ...................Um, yeah, I guess."
        DB	FLG,F_COPYI,7,2
        DW	0000H
        
M15:		;話す　鈴子３
        DB BUF,B_COPY01
        T_CG "CT01","W",0,35,1
        ;	DB	'【鈴子】：ところで%001君、今日は練習軽いんでしょ？'
        DB	"Reiko:  So you're going to take it easy today, right?"
        DB	CR
        DB	"Since it is the last day of practice and all."
        DB	NEXT
        ;	DB	'【%001】：いや・・・大して変わんないと思うけど？'
        DB	"%001:  Not really. I'm going to do the same practice as"
        DB	CR
        DB	"before, pretty much."
        DB	NEXT
        ;	DB	'【鈴子】：どうして？今日最終日なんでしょ？'
        DB	"Reiko:  Why? Today's the last day. You should take it easy."
        DB	NEXT
        ;	DB	'【%001】：いや・・・俺、特別だから。'
        DB	"%001:  .....I'll be okay."
        DB	NEXT
        ;	DB	'【鈴子】：そっか・・・・・・残念ね、記念に驕ってあげようと思ったのに。'
        DB	"Reiko:  That's a shame. I wanted to buy you ice cream."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ............"
        DB	PAUSE
        ;	DB	'ま、まぁしょーが無いさ。また今度な。'
        DB	"Well, next time, then."
        DB	FLG,F_COPYI,7,3
        DW	0000H
        
M16:		;話す　鈴子４
        DB BUF,B_COPY01
        T_CG "CT01","W",0,35,1
        ;	DB	'【鈴子】：何にしても来週は、頑張りましょうね。'
        DB	"Reiko:  Well, the sports festival is next week. Let's"
        DB	CR
        DB	"do our best."
        DB	NEXT
        ;	DB	'【%001】：ああ、お互いにね。'
        DB	"%001:  Yep, I plan to."
        EF_SET 107
        DW	0000H
        
M17:		;話す　清美１
        ;	DB	'【%001】：あれ？新藤さんは？'
        DB	"%001:  Where's Kiyomi?"
        DB	NEXT
        ;	DB	'【誠】：なんか知らんが、吉田と一緒にどっか行ったぞ。'
        DB	"Makoto:  She left with Seia a while ago. I wonder where"
        DB	CR
        DB	"they went."
        DB	NEXT
        ;	DB	'【%001】：・・・あ、そう。'
        DB	"%001:  .............Hmmm."
        DB	FLG,F_COPYI,8,1
        DW	0000H
        
M18:		;話す　清美２
        ;	DB	'新藤さんは、ここにはいない。'
        DB	"Kiyomi's not here."
        DB	NEXT
        ;	DB	'（めずらしいな、鈴子さん達と一緒に昼飯食べないなんて。）'
        DB	"That's unusual. She usually eats lunch here."
        EF_SET 108
        DW	0000H
        
M19:		;話す　美緒１
        DB BUF,B_COPY01
        T_CG "CT03","W",0,10,3
        ;	DB	'【美緒】：・・・%001先輩・・・'
        DB	"Mio:  ......%001..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・大丈夫だって美緒ちゃん。'
        DB	"%001:  I'll be fine, Mio."
        DB	PAUSE
        ;	DB	'練習、今日で終わりなんだから。'
        DB	" Today is the last day of practice,"
        DB	CR
        DB	"so please stop worrying about me."
        DB	NEXT
        ;	DB	'【美緒】：・・・うん、そうだね。'
        DB	"Mio:  You're right."
        DB	FLG,F_COPYI,9,1
        DW	0000H
        
M20:		;話す　美緒２
        DB BUF,B_COPY01
        T_CG "CT03","W",0,10,3
        ;	DB	'【美緒】：先輩・・・・・・今日も遅いの？'
        DB	"Mio:  Are you going to go home late again today?"
        DB	NEXT
        ;	DB	'【%001】：ああ、俺は出るのが沢山あるからな。'
        DB	"%001:  Yeah, I've got a lot of practice to get through."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・・・・'
        DB	"Mio:  ........................"
        DB	FLG,F_COPYI,9,2
        DW	0000H
        
M21:		;話す　美緒３
        DB BUF,B_COPY01
        T_CG "CT03","W",0,10,3
        ;	DB	'【%001】：ま、何にしても来週が本番だ。頑張ろうぜ美緒ちゃん。'
        DB	"%001:  Next week is the real thing. Let's do our best"
        DB	CR
        DB	"and have fun."
        DB	NEXT
        ;	DB	'【美緒】：・・・うん！'
        DB	"Mio:  Okay!"
        EF_SET 109
        DW	0000H
        
M22:		;話す　恵依美１
        DB BUF,B_COPY01
        T_CG "CT08","W",0,0,8
        ;	DB	'【恵依美】：%001、後で清美に感謝しときなさいよ。'
        DB	"Meimi:  %001, please say thank you to Kiyomi later."
        DB	NEXT
        ;	DB	'【%001】：へ？'
        DB	"%001:  Why?"
        DB	NEXT
        ;	DB	'【恵依美】：これ、あんたが寝てた授業のノートよ。'
        DB	"Meimi:  She took notes for you in the classes you missed"
        DB	CR
        DB	"because you were sleeping."
        DB	PAUSE
        ;	DB	'・・・まったく、清美もこんなのほっとけばいいのに。'
        DB	" Look in your notebook."
        DB	NEXT
        T_CG1 "CT14","W",0,30,4
        DB ANI,A_ON,8
        ;	DB	'【誠】：・・・とか言ってる割には、一生懸命起こそうとしてたな。'
        DB	"Makoto:  Weren't you one of the ones trying to wake him"
        DB	CR
        DB	"up, Meimi?"
        DB	NEXT
        K_CG "CT08","D",0,5
        DB ANI,A_ON,4
        ;	DB	'【恵依美】：・・・ちっっっ・・・'
        DB	"Meimi:  Me?"
        DB	PAUSE
        ;	DB	'ちがうわよっ！あたしにまでとばっちり来たら嫌だから、それで・・・・・・'
        DB	" No, I didn't do that. I just didn't want him"
        DB	CR
        DB	"to sleep through lunch."
        DB	NEXT
        ;	DB	'【誠】：わかったわかった。'
        DB	"Makoto:  Okay, okay."
        DB	FLG,F_COPYI,10,1
        DW	0000H
        
M23:		;話す　恵依美２
        DB BUF,B_COPY01
        T_CG "CT08","W",0,0,8
        ;	DB	'【%001】：・・・そっか、とんだ迷惑掛けちまったな。'
        DB	"%001:  I caused you trouble by falling asleep like that."
        DB	PAUSE
        ;	DB	'ごめんな、中野。'
        DB	" I'm"
        DB	CR
        DB	"sorry, Meimi."
        DB	NEXT
        ;	DB	'【恵依美】：・・・・・・'
        DB	"Meimi:  ......"
        DB	PAUSE
        ;	DB	'べ、別にいいわよ。'
        DB	"No, it's nothing."
        DB	NEXT
        T_CG1 "CT14","W",0,30,4
        DB ANI,A_ON,8
        ;	DB	'【誠】：お？顔赤くないか中野？'
        DB	"Makoto:  Your face is turning red, Meimi."
        DB	NEXT
        ;	DB	'【恵依美】：！'
        DB	"Meimi:  !!"
        DB	PAUSE
        ;	DB	'　そ、そんな事・・・・・・'
        DB	" No, it's not, I..."
        DB	NEXT
        ;	DB	'【誠】：おやぁ？もしかしてお前・・・'
        DB	"Makoto:  You know what I think? I think Meimi is in love"
        DB	CR
        DB	"with..."
        DB	NEXT
        K_CG "CT08","D",0,5
        ;	DB	'【恵依美】：うるさいっっっ！！！'
        DB	"Meimi:  Shut up, you!"
        DB	NEXT,FLASH,6
        ;	DB	'どげしっ！'
        DB	"*SMACK*"
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT08","W",'D',0,5
        ;	DB	'【誠】：ぐえっ！？'
        DB	"Makoto:  I'm sorry!!"
        DB	NEXT
        ;	DB	'【恵依美】：・・・フンだ。'
        DB	"Meimi:  I'm not talking to you anymore."
        DB	PAUSE
        ;	DB	'あたし、星愛捜して来る！'
        DB	" I'll go look for Seia"
        DB	CR
        DB	"instead."
        B_P1 B_YOKO
        DB	NEXT
        ;	DB	'言うが早いか、中野はずかずかと大股に教室を出て行った。'
        DB	"Meimi left the classroom."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  .........."
        DB	PAUSE
        ;	DB	'何だったんだ？今の。'
        DB	"What the hell was that all about?"
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"Reiko:  ....................."
        DB	FLG,F_COPYI,10,2
        DB	FLG,F_COPYI,11,1
        DB	FLG,F_COPYI,6,1
        DB	FLG,F_COPYI,5,1
        DB	FLG,F_COPYI,4,1
        DB	FLG,F_COPYI,2,1
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M24:		;話す　恵依美３
        ;	DB	'中野はさっき出て行ったぞ。つまり、ここにはいないって事だな。'
        DB	"She's not here. She just left, remember?"
        EF_SET 110
        DW	0000H
        
M25:		;考える
        ;	DB	'そーだ、考えてみたら練習も今日で終わりだ。'
        DB	"Today is the last day of practice."
        DB	NEXT
        ;	DB	'これだけ頑張ってこれたのも、みんなが応援してくれたからだよな。'
        DB	"I'm kind of surprised I was able to make it this far. "
        DB	NEXT
        ;	DB	'・・・なんか、すごくうれしい。'
        DB	"Everyone was so nice to worry about me. They're really great."
        DB	NEXT
        ;	DB	'いかんいかん、まだ終わった訳じゃないってのに。'
        DB	"Of course, I'm not done with what I have to do."
        	DB	FLG,F_COPYI,11,1
        DW	0000H
        
M26:		;考える
        ;	DB	'誠、憫れな奴・・・'
        DB	"Makoto can be such a geek sometims."
        DB	NEXT
        ;	DB	'見てる分には楽しいから、いいか。'
        DB	"I feel sorry for him."
        EF_SET 111
        DW	0000H
        
M_EXIT:		;
        DB	FLG,F_COPYI,255,1
        DB	FLG,F_MAND,4,255,111,109,107
        DB	FLG,F_EXIT,255
        DB	NEXT
        ;	B_O B_SUDA
        ;	DB	'・・・てな事やってる内に放課後。'
        DB	"........School's over."
        DB	NEXT
        DB	SINARIO,'CS804_1.OVL',0
        DW	0000H


end
