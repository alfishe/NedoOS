;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０６
;		亜希退場

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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	"MIO",0
;NN2:	DB	2,	'亜希',0
NN2:	DB	2,	"AKI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　美緒
S2:		DW	VV1, NN2,  2, M3		;見る　亜希
S3:		DW	VV2, NN1,  3, M4, M5, M6		;話す　美緒
S4:		DW	VV2, NN2,  4, M7, M8, M9		;話す　亜希


;イニシャルメッセージ
M1:
	DB	BGM,7
	BAK_INIT 'AB_37'
	DB	BUF,B_COPY01
	T_CG 'CT03','F','K',0,1
;	DB	'【美緒】：お待たせ、%001先輩。'
	DB	"Mio:  Thanks for waiting, %001."
	DB	NEXT
;	DB	'【%001】：あ、美緒ちゃん。他の二人は？'
	DB	"%001:  Ah, Mio. Where are Reiko and Kiyomi?"
	DB	NEXT
;	DB	'【美緒】：まだ、売り場にいるよ。'
	DB	"Mio:  They're still shopping."
	DB	NEXT
;	DB	'【？】：美緒！'
	DB	"???:  Mio!"
	DB	NEXT
	E_CG B_YOKO,'AE_015'
;	DB	'【美緒】：え・・・？'
	DB	"Mio:  Eh...?"
	DB	NEXT
;	DB	'【美緒】：亜希ちゃん・・・'
	DB	"Mio:  Aki...."
	DB	NEXT
;	DB	'【%001】：やっぱり、美緒ちゃんの友達か。'
	DB	"%001:  So she's a friend of yours, Mio?"
	DB	NEXT
;	DB	'【美緒】：うん・・・'
	DB	"Mio:  Well..."
	DB	NEXT
;	DB	'【亜希】：いつあたしがあんたの友達になったのよ！'
	DB	"Aki:  Since when am I your friend?!"
	DB	NEXT
;	DB	'【美緒】：！'
	DB	"Mio:  !!"
	DB	NEXT
;	DB	'【%001】：え！？'
	DB	"%001:  What's going on here?"
	DW	0000H

M2:		;見る　美緒
;	DB	'困ったような顔で、亜希ちゃんを見上げている。'
	DB	"Mio, upset, is looking up at Aki."
	DW	0000H

M3:		;見る　亜希
;	DB	'挑戦的な目で美緒ちゃんを見てる。'
	DB	"Aki's challenging Mio with her eyes."
	DW	0000H

M4:		;話す　美緒
;	DB	'【%001】：あの子もテニス部だろ？'
	DB	"%001:  I guess you're on the tennis team together?"
	DB	NEXT
;	DB	'【美緒】：うん、あたしと同じクラスの雛菊　亜希ちゃん・・'
	DB	"Mio:  That's right, Aki Hinagiku is in my class."
	DB	NEXT
;	DB	'【%001】：・・・ちょっと待て、てことは中等部だろ？',CR,'さっき「高校テニス界の超新星」とか言ってなかったか？'
	DB	"%001:  So you're a tennis star?"
	DB	NEXT
;	DB	'【亜希】：これからそうなるのよ。全世界がこの天才プレイヤーに震撼するのよ！'
	DB	"Aki:  That's right. The whole world will tremble in the"
	DB	CR
	DB	"face of my talent!"
	DB	NEXT
;	DB	'（・・・・・・・・・・・・何も言えん。）'
	DB	"Wow, I guess there's nothing I can say to that..."
	DB	FLG,F_COPYI,3,1
	DW	0000H


M5:		;話す　美緒
;	DB	'【%001】：何であんなに目の仇にされてるんだ？'
	DB	"%001:  Why are you such enemies?"
	DB	NEXT
;	DB	'【美緒】：うん・・・亜希ちゃんは去年転入して来た帰国子女なの・・・'
	DB	"Mio:  Well, Aki transferred to our school last year. She'd"
	DB	CR
	DB	"been living in America."
	DB	NEXT
;	DB	'【美緒】：「本場でテニスをやってた」、ってテニス部に入って来たんだけど、あたしと試合して・・・'
	DB	"Mio:  Well, she said she played tennis where she was"
	DB	CR
	DB	"before, and joined the tennis team. Then she played a"
	DB	CR
	DB	"match with me..."
	DB	NEXT
;	DB	'【亜希】：そ！あの時はものの見事に０ゲームで惨敗したわ！'
	DB	"Aki:  Right! And at that time I suffered a crushing defeat!"
	DB	NEXT
;	DB	'【亜希】：でも、いつまでもあの時のあたしのままだと思わないでよ！'
	DB	"Aki:  But I'm certainly not the same person I was then!"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M6:		;話す　美緒
;	DB	'【亜希】：あんたの無敗神話を破るのはこのあ・た・し！',CR,'そしてそれがあたしの常勝神話の始まりでもあるのよ！'
	DB	"Aki:  I'm the one who's going to break your winning streak!"
	DB	CR
	DB	"I'm the one who is invincible!"
	DB	NEXT
;	DB	'【%001】：美緒ちゃん、なんか言い返さなくていいのか？'
	DB	"%001:  Mio, don't you want to say anything?"
	DB	NEXT
;	DB	'【美緒】：・・・うん・・・'
	DB	"Mio:  Mmm."
	EF_SET 102
	DW	0000H

M7:		;話す　亜希
;	DB	'【亜希】：いっとくけど、あたしはあんたを友達だと思ったことは一度もないからね、美緒。'
	DB	"Aki:  Well, just so you know, Mio, I have never once"
	DB	CR
	DB	"thought of you as my friend."
	DB	NEXT
;	DB	'それを聞くと、美緒ちゃんは何かに打たれたみたいにビクッと体を震わせた。'
	DB	"What Aki said seemed to hit Mio pretty hard."
	DB	NEXT
;	DB	'【亜希】：あたし達はあくまでライバル同士。チャラチャラしたお友達ごっこをする気はないわ！'
	DB	"Aki:  We are nothing but arch-rivals. I have no desire to"
	DB	CR
	DB	"be buddies with you!"
	DB	NEXT
;	DB	'【美緒】：亜希ちゃん・・・'
	DB	"Mio:  Aki......"
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:		;話す　亜希
;	DB	'【%001】：それで、俺に何か用？'
	DB	"%001:  So what do you want?"
	DB	NEXT
;	DB	'【亜希】：テニス部員でもないのに美緒に勝ったって奴の顔を一目見ておきたかったのよ。'
	DB	"Aki:  I wanted to see the person who beat Mio at tennis."
	DB	NEXT
;	DB	'【亜希】：いっくら高校生だからって、美緒があたし以外に負けるなんて信じられないもの。'
	DB	"Aki:  There is noone who can beat Mio, only me."
	DB	NEXT
;	DB	'【亜希】：美緒、こ～んなトロくさそうな奴に負けるなんて、それでもあたしのライバルなの？'
	DB	"Aki:  So, Mio, you think you're my rival even if you lose"
	DB	CR
	DB	"to this fool, here?"
	DB	NEXT
;	DB	'彼女は俺をビシッと指差してそう言った。'
	DB	"She pointed her finger in my direction."
	DB	NEXT
;	DB	'【%001】：と・・・トロくさい？'
	DB	"%001:  ...Fool?"
	DB	NEXT
;	DB	'【美緒】：そんな事ない！%001先輩は本当にすごいんだから！'
	DB	"Mio:  That's not true! %001 is a naturally talented"
	DB	CR
	DB	"player!"
	DB	NEXT
;	DB	'【亜希】：そんなスゴイやつが、どーして無名なままなわけ？'
	DB	"Aki:  Well if he's so great, then why isn't he famous?"
	DB	NEXT
;	DB	'【美緒】：それは・・・！'
	DB	"Mio:  What...!?"
	DB	NEXT
;	DB	'【亜希】：！　ふ～ん、そういうことか。'
	DB	"Aki:  ....I think I see it, now. You must have let him win, "
	DB	CR
	DB	"didn't you?"
;	DB	NEXT
;	DB	'【%001】：・・・何が？'
;	DB	"%001:  ...See what?"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M9:		;話す　亜希
;	DB	'【亜希】：いいわ美緒、あんたの負けはなかったことにしてあげる。ノーカンよ、ノーカン。'
	DB	"Aki:  Okay, Mio, let's say you didn't lose to %001. We"
	DB	CR
	DB	"won't count it."
	DB	NEXT
;	DB	'【美緒】：・・・？'
	DB	"Mio:  ....?"
	EF_SET 101
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,3,255,101,102
	DB FLG,F_EXIT,255
	DB	NEXT
;	DB	'【亜希】：ホントは美緒を倒したあなたに挑戦するつもりだったけど・・・'
	DB	"Aki:  Well, I was going to challenge you because you beat"
	DB	CR
	DB	"Mio, but....."
	DB	NEXT
;	DB	'【%001】：俺に勝てば、美緒ちゃんに勝ったことになるから？'
	DB	"%001:  Why, because beating me would mean beating Mio?"
	DB	NEXT
;	DB	'【亜希】：まあね、でもやめたわ。美緒が本気出したら、あなたなんかに負けるわけないもの。'
	DB	"Aki:  But never mind. If Mio was really trying, you"
	DB	CR
	DB	"certainly couldn't have beaten her like that."
	DB	NEXT
;	DB	'【亜希】：でも、最後に笑うのはこのあたしよ！必ずあんたをコートに這いつくばらせて大笑いしてやるから！'
	DB	"Aki:  But I will laugh last! I will have great pleasure"
	DB	CR
	DB	"in humiliating you on the court!"
	DB	NEXT
;	DB	'【亜希】：それじゃ、せいぜい腕を磨いておくことね！'
	DB	"Aki:  I'd practice some more if I were you!"
	DB	NEXT
	B_O B_GURU
;	DB	'そう一方的にまくしたてると、亜希ちゃんは階段を駆け上がっていった。'
	DB	"Aki disappeared up the staircase."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT03','F','I',10,2
;	DB	'【美緒】：亜希ちゃん・・・'
	DB	"Mio:  Aki........."
	DB	NEXT
	T_CG1 'CT02','F',0,0,3
	DB	ANI,A_ON,2
;	DB	'【清美】：・・・お待たせ致しましたわ。'
	DB	"Kiyomi:  Sorry to keep you waiting."
	DB	NEXT
	T_CG1 'CT01','F',0,35,4
	DB	ANI,A_ON,3
	DB	ANI,A_ON,2
;	DB	'【鈴子】：今話してた子、美緒ちゃんの友達？'
	DB	"Reiko:  That woman you were talking to, is she a friend of"
	DB	CR
	DB	"yours, Mio?"
	DB	NEXT
;	DB	'【%001】：あ・・・新藤さん、鈴子さん。'
	DB	"%001:  Oh, Kiyomi and Reiko..."
	DB	NEXT
;	DB	'【清美】：どうかなさいましたの？'
	DB	"Kiyomi:  What happened?"
	DB	NEXT
	K_CG 'CT03','K',10,5
	DB	ANI,A_ON,4
	DB	ANI,A_ON,3
;	DB	'【美緒】：ううん・・・なんでもないの。'
	DB	"Mio:  Oh, nothing."
	DB	NEXT
;	DB	'（美緒ちゃん・・・）'
	DB	"Poor Mio..."
	DB	NEXT
;	DB	'【美緒】：ね、今度はどこ行こうか！'
	DB	"Mio:  Where d'you want to go next?"
	DB	NEXT
	BAK_INIT 'AB_43_1'
	B_P1 B_YOKO
;	DB	'・・・その後いくつかの店をまわった後、俺は駅の前で３人と分かれて、家に帰った。'
	DB	"After going to several more stores, I left the three of"
	DB	CR
	DB	"them at the station, and went home."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	".................................."
	DB	NEXT
	T_CG1 'CT01','F',0,35,4
;	DB	'【鈴子】：美緒ちゃん・・・あの子と、何かあったの？'
	DB	"Reiko:  ...Did something happen between you and that"
	DB	CR
	DB	"woman, Mio?"
	DB	NEXT
	T_CG1 'CT03','F',0,10,6
	DB	ANI,A_ON,4
;	DB	'【美緒】：・・・えと・・・'
	DB	"Mio:  Well..."
	DB	NEXT
;	DB	'【鈴子】：嫌なら無理に話してくれなくてもいいのよ。'
	DB	"Reiko:  You don't have to talk about it if you don't want to."
	DB	NEXT
	T_CG1 'CT02','F',0,0,3
	DB	ANI,A_ON,6
	DB	ANI,A_ON,4
;	DB	'【清美】：ですが、わたくしたちでよければ、お力になれるかもしれませんわ。昔から、「３人寄れば文殊の知恵」というではありませんか。'
	DB	"Kiyomi:  Well, if you want to tell us, I'm sure we can"
	DB	CR
	DB	"help you. It's always better when you share your problems"
	DB	CR
	DB	"with others."
	DB	NEXT
;	DB	'【美緒】：・・・うん。・・・ありがとう。'
	DB	"Mio:  Thanks."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	".................................."
	DB	NEXT
	B_O B_WIPE
	DB SINARIO,'CS407.OVL',0
	DW	0000H


end
