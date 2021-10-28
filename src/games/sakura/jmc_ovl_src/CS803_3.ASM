;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０３＿３
;		体育祭３日前　菜食主義の狼さん　恵依美編

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
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	'MEIMI',0
;NN2:	DB	2,	'練習のこと',0
NN2:	DB	2,	'PRACTICE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　恵依美
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12		;話す　恵依美１０
S3:		DW	VV3, NN2,  3, M13, M14, M15, M16		;考える　練習の事４


;イニシャルメッセージ
M1:
	DB	BGM,16
	BAK_INIT "AB_04_3"
	DB BUF,B_COPY01
	T_CG "CT08","W",0,30,1
;	DB	'中野を送る道すがら、寿命の切れかけた蛍光燈だけが辺りを照らす路地で・・・今まで黙っていた中野が、突然口を開いた。'
	DB	"Meimi was silent as I escorted her through the dark"
	DB	CR
	DB	"streets. Then she spoke to me."
	DB	NEXT
;	DB	'【恵依美】：・・・ねえ修司・・・練習、楽しい？'
	DB	"Meimi:  %001, do you enjoy your practice?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................."
	DB	PAUSE
;	DB	'あん？'
	DB	"Enjoy it?"
	DB	NEXT
;	DB	'【恵依美】：だってさ・・・あんなスゴイ練習を毎日してるんだもん。'
	DB	"Meimi:  I mean, to practice that hard, every day..."
	DB	NEXT
;	DB	'何か楽しい事がなきゃ、続かないわよ。'
	DB	"Meimi:  There has to be something fun about it for you"
	DB	CR
	DB	"to go on every day."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............."
	DB	PAUSE
;	DB	'そうだな・・・・・・'
	DB	"I guess."
	DB	C_BLD,C_V_ON,1		;「見る」　消す
	DB	C_BLD,C_V_ON,2		;「話す」　消す
	DW	0000H

M2:		;見る　恵依美
;	DB	'心底不思議そうに俺を見ている。'
	DB	"She's looking at me with curiosity in her eyes."
	DB	NEXT
;	DB	'別に俺は未知の生命体じゃないぞ？'
	DB	"Almost as if I were some sort of alien."
	DW	0000H

M3:		;話す　恵依美１
;	DB	'【恵依美】：ど～したのよ？突然立ち止まってぶつぶつ言ったりして？'
	DB	"Meimi:  What's wrong? Why did you stop walking?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ........................"
	DB	PAUSE
;	DB	'え？止まってた俺？'
	DB	"Did I stop?"
	DB	NEXT
;	DB	'【恵依美】：ええ、そりゃ～もうびったり。'
	DB	"Meimi:  Yes. Did I say something wrong?"
	DB	NEXT
;	DB	'【%001】：・・・・・・そか。悪りィ悪りィ。'
	DB	"%001:  No, nothing. Nevermind."
	DB	PAUSE
;	DB	'俺、考え出すと何もかも止まっちまうから・・・・・・'
	DB	" When I think about something"
	DB	CR
	DB	"deep, I always stop walking."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　恵依美２
;	DB	'【恵依美】：・・・もしかして、あたしが聞いた事？'
	DB	"Meimi:  Were you thinking about what I just asked you?"
	DB	NEXT
;	DB	'【%001】：・・・ああ。'
	DB	"%001:  ....Yeah."
	DB	PAUSE
;	DB	'言われるまで、考えてもみなかったから・・・'
	DB	" I'd never thought about it before."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ............."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　恵依美３
;	DB	'【%001】：・・・「練習が楽しいか？」って事なら「楽しくない」って言える。'
	DB	"%001:  If you ask me if practice is fun, I'd have to say no."
	DB	NEXT
;	DB	'【%001】：だけど・・・俺、嫌じゃないんだよな。'
	DB	"%001:  But I don't hate it for some reason."
	DB	PAUSE
;	DB	'今までだったら、嫌で嫌でしょうがなかったんだけど・・・'
	DB	" Before recently,"
	DB	CR
	DB	"I'm sure I would have hated it, though. Something's changed"
	DB	CR
	DB	"in me."
	DB	NEXT
;	DB	'【恵依美】：・・・%001・・・'
	DB	"Meimi:  %001..."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;話す　恵依美４
;	DB	'【恵依美】：ねえ、%001・・・'
	DB	"Meimi:  Why would you have hated practicing before?"
	DB	NEXT
;	DB	'【%001】：そりゃあ、目立つからさ。'
	DB	"%001:  I hate standing out from everyone else."
	DB	NEXT
;	DB	'【恵依美】：目立つ・・・から？'
	DB	"Meimi:  Standing out?"
	DB	NEXT
;	DB	'【%001】：より正確には・・・浮いちまうからだな。'
	DB	"%001:  Yeah. I never liked that."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;話す　恵依美５
;	DB	'【%001】：確かに俺が勝てば、みんな喜んでくれたさ。'
	DB	"%001:  Before, when I did well at sports, people pretended"
	DB	CR
	DB	"to be happy for me..."
	DB	PAUSE
;	DB	'・・・だけど心の底では、違う事を考えてる。'
	DB	" But it was all a lie."
	DB	NEXT
;	DB	'【%001】：それに気が付いた時には、もう手後れだった。'
;	DB	'俺には、友達と呼べる奴は誰もいなくなってた。'
	DB	"%001:  By the time I noticed that, it was too late. All"
	DB	CR
	DB	"of my friends were gone."
	DB	NEXT
	K_CG "CT08","I",30,2
;	DB	'【恵依美】：・・・%001・・・'
	DB	"Meimi:  %001..."
	DB	NEXT
;	DB	'【%001】：あの時は・・・学校の何もかもが嫌になったっけ。'
	DB	"%001:  I hated school... I hated everything about school."
	DB	PAUSE
;	DB	'家出なんかも、本気で考えてたなぁ。'
	DB	" I"
	DB	CR
	DB	"even thought about running away from home."
	DB	NEXT
;	DB	'【恵依美】：・・・%001、ごめん。変な事聞いちゃって。'
;	DB	'もういいよ。'
	DB	"Meimi:  I'm sorry for asking something so personal."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M8:		;話す　恵依美６
;	DB	'【%001】：・・・あ、いや。こんな話するつもりはなかったんだ。'
	DB	"%001:  No, I'm sorry for talking like this..."
	DB	PAUSE
;	DB	'・・・何の話だっけ？'
	DB	" Um, what were"
	DB	CR
	DB	"we talking about?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ...................."
	DB	PAUSE
;	DB	'練習がどうして嫌だったか、って話・・・・・・'
	DB	"About practice."
	DB	NEXT
;	DB	'【%001】：・・・ああ、そ～だそ～だ。'
	DB	"%001:  Oh, that's right."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................."
	DB	FLG,F_COPYI,2,6
	DW	0000H

M9:		;話す　恵依美７
;	DB	'【%001】：分ったんだよ・・・どうして俺が、練習嫌じゃないかが。'
	DB	"%001:  I just realized why I don't hate practice."
	DB	NEXT
;	DB	'【%001】：・・・なぁ中野。クラスのみんな、俺の能力知ってるよな？'
	DB	"%001:  ...Everyone in our class knows pretty much what"
	DB	CR
	DB	"I'm capable of, right?"
	DB	NEXT
;	DB	'【恵依美】：・・・あ、うん。'
	DB	"Meimi:  I guess so."
	DB	NEXT
;	DB	'【%001】：だけど・・・誠も鈴子さんも新藤さんも美緒ちゃんも、'
;	DB	PAUSE
;	DB	'西野さんも亜希ちゃんも吉田も俺を敬遠したりはしない。'
;	DB	PAUSE
;	DB	'他の連中と同じように、俺に接してくれる。'
	DB	"%001:  But everyone's letting me into their group, being"
	DB	CR
	DB	"nice to me. I like that."
	DB	NEXT
;	DB	'【恵依美】：うん・・・そうだね。'
	DB	"Meimi:  I guess so. Yes."
	DB	FLG,F_COPYI,2,7
	DW	0000H

M10:		;話す　恵依美８
;	DB	'【%001】：そう・・・一緒に練習しているみんなだってそうだ。'
	DB	"%001:  The guys who are practicing with me are the same."
	DB	NEXT
;	DB	'【%001】：ほんのちょっとしか練習しない俺の為に、時間を空けて待っててくれる。呼びに来てくれる。'
	DB	"%001:  They're going to all that trouble to set up time for"
	DB	CR
	DB	"me so I can train with them."
	DB	NEXT
;	DB	'【%001】：・・・これって、スゲー有り難い事だよな。'
	DB	"%001:  That's really nice of them."
	DB	NEXT
;	DB	'【恵依美】：・・・うん。'
	DB	"Meimi:  That's right."
	DB	NEXT
;	DB	'【%001】：だから俺は、頑張れるんだ。'
	DB	"%001:  So I've got to do my best."
	DB	PAUSE
;	DB	'俺なんかの為に、色々してくれるみんなに報いる為に。'
	DB	" I've got to. Do you see"
	DB	CR
	DB	"that?"
	DB	NEXT
;	DB	'【恵依美】：・・・%001・・・'
	DB	"Meimi:  %001..."
	DB	FLG,F_COPYI,2,8
	DW	0000H

M11:		;話す　恵依美９
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............"
	DB	PAUSE
;	DB	'な～んちゃって、ちょ～っとらしくなかったかな？ははは・・・・・・'
	DB	" Something must be wrong with me tonight,"
	DB	CR
	DB	"talking about heavy topics like this."
	DB	NEXT
	T_CG "CT08","W",0,30,3
;	DB	'【恵依美】：・・・'
	DB	"Meimi:  ..............."
	DB	PAUSE
;	DB	'ううん。そんな事無いよ。'
	DB	"No, it's okay."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか？'
	DB	"%001:  ..........Really?"
	DB	NEXT
;	DB	'【恵依美】：うん。'
	DB	"Meimi:  Really."
	DB	PAUSE
;	DB	'・・・あたしだって・・・'
	DB	" I mean, even I..."
	DB	FLG,F_COPYI,2,9
	DW	0000H

M12:		;話す　恵依美１０
;	DB	'【%001】：え？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【恵依美】：・・・'
	DB	"Meimi:  .................."
	DB	PAUSE
;	DB	'あ、ううん。'
	DB	"Oh, nothing."
	DB	PAUSE
;	DB	'何でも、ない。'
	DB	" Really. Nothing."
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  ....................??"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  .........................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........................."
	DB	NEXT
	K_CG "CT08","K",30,4
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  .........................."
	DB	PAUSE
;	DB	'うふふっ。'
	DB	"Haha..."
	DB	NEXT
;	DB	'【%001】：・・・・・・何だよ突然。'
	DB	"%001:  ......What are you laughing at?"
	DB	NEXT
;	DB	'【恵依美】：・・・良かったなぁ、って思って。'
	DB	"Meimi:  I'm just happy."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..................."
	DB	PAUSE
;	DB	'へ？何が？'
	DB	"Happy? Why?"
	DB	NEXT
;	DB	'【恵依美】：うふふ・・・・・・'
	DB	"Meimi:  Haha....."
	DB	PAUSE
;	DB	'教えな～い！'
	DB	"It's a secret!"
	DB	NEXT
;	DB	'【%001】：・・・何だよそりゃあ。'
	DB	"%001:  Secret? What?"
	DB	NEXT
;	DB	'【恵依美】：さ、行こ！あんまり遅いと、ママが心配しちゃう！'
	DB	"Meimi:  Let's hurry along! If we take too long, Mom will"
	DB	CR
	DB	"be worried about me!"
	DB	NEXT
;	DB	'【%001】：あ、ああ・・・・・・'
	DB	"%001:  I guess so..."
	DB	NEXT
	B_O B_SUDA
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"........................"
	DB	NEXT
;	DB	'【恵依美】：・・・ありがと%001。ここまででいいよ。'
	DB	"Meimi:  Thank you, %001. I'll be fine by myself from here"
	DB	CR
	DB	"on."
	DB	NEXT
;	DB	'【%001】：そか？'
	DB	"%001:  You're sure?"
	DB	NEXT
;	DB	'【恵依美】：うん、そこの角曲がったらすぐだから。'
	DB	"Meimi:  My house is right around this corner."
	DB	NEXT
;	DB	'【%001】：そか。'
	DB	"%001:  Okay. "
	DB	PAUSE
;	DB	'じゃあな。'
	DB	" Well, see you tomorrow."
	DB	NEXT
;	DB	'【恵依美】：うん。'
	DB	"Meimi:  Okay."
	DB	PAUSE
;	DB	'・・・・・・あのさ、%001。'
	DB	"...%001?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Yes?"
	DB	NEXT
;	DB	'【恵依美】：・・・あのね、その・・・'
	DB	"Meimi:  ...I'm going to find my own dream, like you..."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......."
	DB	PAUSE
;	DB	'ああ、そうだな。'
	DB	"That's good."
	DB	PAUSE
;	DB	'ありがとな、中野。'
	DB	" Thanks, Meimi."
	DB	NEXT
;	DB	'【恵依美】：うん・・・'
	DB	"Meimi:  Goodnight, %001."
	DB	NEXT
;	DB	'【%001】：ああ、お休み。'
	DB	"%001:  Goodnight."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".................................."
	E_CG B_SUDA,'AB_43_2'
							;街・夜
	DB	NEXT
;	DB	'【%001】：夢、',PAUSE,'か・・・・・・'
	DB	"%001:  A dream..."
	DB	NEXT
;	DB	'【%001】：俺にも、見つけられるかも知れねぇな。あいつらとなら・・・・・・'
	DB	"%001:  I'd better find a dream of my own."
	DB	NEXT
	DB G_FLG,G_COPYF,180,180
	DB FLG,F_CALI,180,20
	DB G_FLG,G_COPYG,180,180
	B_O B_SUDA
	DB	SINARIO,'CS804.OVL',0
	DW	0000H

M13:		;考える　練習の事１
;	DB	'（・・・そうだな・・・言われてみれば、確かにそうだ。）'
	DB	".....Hmmm, that's right..."
	DB	NEXT
;	DB	'（・・・・・・何でだろ？）'
	DB	"I wonder why I never realized it before?"
	DB	NEXT
;	DB	'【恵依美】：・・・%001？'
	DB	"Meimi:  ...........%001?"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M14:		;考える　練習の事２
;	DB	'（中野の言うとおり、練習が楽しいのか？）'
	DB	"It's just as Meimi said..."
	DB	NEXT
;	DB	'（・・・いや、ンな事はないな。訳が解んなくなんないのが不思議だもんな。）'
	DB	"Practice isn't fun, but I don't hate it at all."
	DB	NEXT
;	DB	'【恵依美】：・・・%001ってば。'
	DB	"Meimi:  %001, are you listening to me?"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M15:		;考える　練習の事３
;	DB	'（じゃあ、約束したからか？）'
	DB	"Do I like practice because I promised everyone?"
	DB	NEXT
;	DB	'（・・・・・・・・・）'
	DB	".........................."
	DB	NEXT
;	DB	'（確かにそれもあるが・・・・・・）'
	DB	"That might be part of it..."
	DB	NEXT
;	DB	'【恵依美】：・・・ねぇ、%001！'
	DB	"Meimi:  %001!"
	DB	FLG,F_COPYI,3,3
	DW	0000H

M16:		;考える　練習の事４
;	DB	'（・・・・・・うーむ・・・・・・）'
	DB	"Hmmm..."
	DB	NEXT
;	DB	'【恵依美】：・・・も～、%001っ！！'
	DB	"Meimi:  %001!"
	DB	NEXT
;	DB	'【%001】：わっ！びっくりしたっ！'
	DB	"%001:  Huh? You scared me!"
	DB	C_BLD,C_V_OFF,1		;「見る」　出す
	DB	C_BLD,C_V_OFF,2		;「話す」　出す
	DB	C_BLD,C_V_ON,3		;「考える」　消す
	DW	0000H


end
