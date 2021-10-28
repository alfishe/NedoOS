;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０４＿１
;		体育祭２日前　瑠璃、感情の発露

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5
MSGTBL:
        DW	M1
COMTBL:
        DW	CM1, CM2, CM3, CM4, CM5
VNTBL:
        DW	V_FNAME,N_FNAME
ENDTBL:

        INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
        INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'そうだ',0
VV4:	DB	4,	"YES",0
;VV5:	DB	5,	'違う',0
VV5:	DB	5,	"NO",0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	'RURI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　瑠璃２
S2:		DW	VV2, NN1,  2, M4, M5, M7, M8, M10		;話す　瑠璃５	
S3:		DW	VV3, -1,  3, M11		;考える
S4:		DW	VV4, -1,  4, M6		;そうだ				☆正解ルート
S5:		DW	VV5, -1,  5, M9		;違う				☆失敗ルート


;イニシャルメッセージ
M1:
        DB	BGM,31
        BAK_INIT "AB_36_3"
        B_P1 B_SUDA
        ;	DB	'【%001】：・・・さぁて、最後の練習だ。気合い入れて行くか！'
        DB	"%001:  Well, today is the last day of practice. Guess I'd"
        DB	CR
        DB	"better get moving."
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT02","W",'I',10,2
        ;	DB	'【清美】：%001さん、今日も遅いのですか？'
        DB	"Kiyomi:  %001, are you going home late again today?"
        DB	NEXT
        ;	DB	'【%001】：ああ・・・新藤さん達は早いんだろ？そのまま帰っちゃっていいよ。'
        DB	"%001:  Yeah. You guys can go on home without me."
        DB	NEXT
        ;	DB	'【清美】：ですが・・・・・・'
        DB	"Kiyomi:  Yes, but..."
        DB	NEXT
        ;	DB	'【%001】：い～からい～から。'
        DB	"%001:  Don't worry, I'll be okay."
        DB	PAUSE
        ;	DB	'じゃ、また来週！'
        DB	" Well, see you next week."
        DB	NEXT
        ;	DB	'【清美】：・・・あ・・・'
        DB	"Kiyomi:  But I..."
        DB	NEXT
        BAK_INIT "AB_27_1"
        B_P1 B_SUDA
        DB BUF,B_COPY01
        T_CG "CT05","W",0,20,5
        ;	DB	'【瑠璃】：・・・・・・・・・%001君。'
        DB	"Ruri:  ........%001."
        DB	NEXT
        ;	DB	'【%001】：・・・わっ！'
        DB	"%001:  Wah!!"
        DB	PAUSE
        ;	DB	'・・・し、白水さん・・・'
        DB	"........Ruri, hello."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  ......................................."
        DB	C_BLD,C_V_ON,4
        DB	C_BLD,C_V_ON,5
        DW	0000H
        
M2:		;見る　瑠璃１
        ;	DB	'・・・俺に用があるみたいだけど・・・'
        DB	"She seems to want to talk to me about something."
        DW	0000H
        
M3:		;見る　瑠璃２
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  ..............."
        DB	NEXT
        ;	DB	'・・・相変わらず無表情なんで、質問の意図が掴めない。'
        DB	"She looks as depressed as ever."
        DB	NEXT
        ;	DB	'・・・笑うか怒るかしてくれれば、こっちもリアクションのしようが',CR,'あるんだけど・・・。'
        DB	"I wish she'd either get angry or happy. It's hard to"
        DB	CR
        DB	"know what she's feeling."
        DW	0000H
        
M4:		;話す　瑠璃１
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ....................."
        DB	PAUSE
        ;	DB	'ど、どうしたの？'
        DB	"What's wrong?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・あなたに、聞きたい事があるの。'
        DB	"Ruri:  ...........There's something I want to ask you."
        DB	NEXT
        ;	DB	'【%001】：へ？'
        DB	"%001:  Ask me?"
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M5:		;話す　瑠璃２
        ;	DB	'【%001】：・・・・・・聞きたい、事？'
        DB	"%001:  What do you want to ask me?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・どうして、そんなに一生懸命やるの？'
        DB	"Ruri:  ....Why do you try so hard?"
        DB	NEXT
        ;	DB	'【%001】：え？'
        DB	"%001:  What?"
        DB	NEXT
        ;	DB	'【瑠璃】：たくさん掛け持ちして・・・そんなに、みんなから好かれたいの？'
        DB	"Ruri:  Participating in all those sporting events. Are"
        DB	CR
        DB	"you that concerned with making everyone else like you?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ........................."
        DB	FLG,F_COPYI,1,1
        DB	C_BLD,C_V_ON,2
        DB	C_BLD,C_V_OFF,4
        DB	C_BLD,C_V_OFF,5
        DW	0000H
        
M6:		;そうだ				☆正解ルート
        ;	DB	'【%001】：・・・うーん・・・そ～だなぁ。'
        DB	"%001:  ....I guess that's basically right."
        DB	PAUSE
        ;	DB	'・・・確かに、嫌われたくはないな。'
        DB	" I mean, no one"
        DB	CR
        DB	"wants to be hated,right?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・そう・・・'
        DB	"Ruri:  ....................I see."
        DB	NEXT
        ;	DB	'【%001】：だけどそれ以上にさ・・・'
        DB	"%001:  But more than that..."
        DB	PAUSE
        ;	DB	'俺、約束を破りたくね～んだ。'
        DB	" I made a promise, and I don't"
        DB	CR
        DB	"want to break that promise."
        DB	NEXT
        ;	DB	'【瑠璃】：約束？'
        DB	"Ruri:  Promise?"
        DB	C_BLD,C_V_OFF,2
        DB	C_BLD,C_V_ON,4
        DB	C_BLD,C_V_ON,5
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M7:		;話す　瑠璃３				☆正解ルート
        ;	DB	'【%001】：ああ・・・成り行きとは言え、俺は出るって言っちまったんだ。'
        DB	"%001:  Yes. I'm not sure how it happened, but suddenly"
        DB	CR
        DB	"I was promising to be in all those events."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  ..................."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ................."
        DB	PAUSE
        ;	DB	'ってのはタテマエで、ホントは俺・・・'
        DB	"Although that might not be it,"
        DB	CR
        DB	"either. I think I really wanted to know that everyone was"
        DB	CR
        DB	"rooting for me."
        DB	NEXT
        ;	DB	'【瑠璃】：応援？'
        DB	"Ruri:  Rooting for you?"
        DB	FLG,F_COPYI,2,3
        DW	0000H
        
M8:		;話す　瑠璃４				☆正解ルート
        ;	DB	'【%001】：そう。'
        DB	"%001:  Yeah."
        DB	PAUSE
        ;	DB	'・・・この学校に来るまで、俺に「頑張れ」って言う奴はみんな、'
        ;	DB	'自分の為に言ってたんだ。俺が勝てば得をするから・・・'
        DB	" Before I came to this school, no one had ever"
        DB	CR
        DB	"said to me, 'Do your best. Go out there and win for us.'"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  .................................."
        DB	NEXT
        ;	DB	'【%001】：だけどさ、あいつらは違う・・・・・・'
        DB	"%001:  But now, everyone wants me to get out and do the"
        DB	CR
        DB	"best I can."
        DB	PAUSE
        ;	DB	'そんな事関係ナシに、俺と言う人間を応援してくれる。'
        DB	" They're really supportive of me, and that"
        DB	CR
        DB	"makes me feel good."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  .................................."
        DB	NEXT
        ;	DB	'【%001】：だから俺は・・・みんなの期待に応えたい。'
        DB	"%001:  So I want to try hard for them."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  .................................."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・ま、これが『みんなに好かれたい』って事ならそーなんだろ～けどな。'
        DB	"%001:  .......If that means that I want everyone to like"
        DB	CR
        DB	"me, well I guess there's nothing I can do about that."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  .................................."
        DB	PAUSE
        K_CG "CT05","K",20,6
        						;瑠璃微笑
        ;	DB	'そう。'
        DB	"I see."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・私、練習があるから。'
        DB	"Ruri:  Well, I've got to get to practice myself."
        DB	NEXT
        ;	DB	'【%001】：・・・あ、ああ・・・'
        DB	"%001:  Okay. See you later."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・・・・・・・・'
        DB	"Ruri:  ..........................."
        DB	PAUSE
        ;	DB	'さよなら。'
        DB	"Bye."
        DB	NEXT
        B_P1 B_SUDA
        						;瑠璃消し
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  .................................."
        DB	NEXT
        ;	DB	'【%001】：結局、何だったんだ？'
        DB	"%001:  What was that all about?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  .................................."
        DB	NEXT
        ;	DB	'【生徒Ａ】：・・・おーい山神ィ！とっととこ～い！'
        DB	"Student A:  Hey, Yamagami! Are you coming or what?"
        DB	NEXT
        ;	DB	'【%001】：・・・',PAUSE,'あ、ああ今行く！'
        DB	"%001:  .................",PAUSE,"Ah, I'll be right there!"
        DB	NEXT
        DB G_FLG,G_COPYI,150,150
        DB FLG,F_CALI,150,5
        DB G_FLG,G_COPYI,150,150
        B_O B_SUDA
        DB	SINARIO,'CS805.OVL',0
        DW	0000H
        
M9:		;違う				☆失敗ルート
        ;	DB	'【%001】：そんなんじゃね～さ。'
        DB	"%001:  No, that's not it."
        DB	PAUSE
        ;	DB	'・・・俺はただ、約束を破りたくないだけさ。'
        DB	" I just don't want to break the"
        DB	CR
        DB	"promise I made to everyone else."
        DB	NEXT
        ;	DB	'【瑠璃】：約束？'
        DB	"Ruri:  Promise?"
        DB	C_BLD,C_V_OFF,2
        DB	C_BLD,C_V_ON,4
        DB	C_BLD,C_V_ON,5
        DB	FLG,F_COPYI,2,4
        DW	0000H
        
M10:		;話す　瑠璃５				☆失敗ルート
        ;	DB	'【%001】：ああ・・・成り行きとは言え、俺は出るって言っちまったんだ。'
        DB	"%001:  Yes. I'm not sure how it happened, but suddenly I"
        DB	CR
        DB	"was promising everyone to be in all those events."
        DB	NEXT
        ;	DB	'だからさ。'
        DB	"%001:  That's why."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  ..........."
        DB	NEXT
        ;	DB	'【%001】：俺、今まで約束だけは破った事無いし・・・これからもそうでありたい。'
        DB	"%001:  I've never broken a promise before. I don't want"
        DB	CR
        DB	"to start now."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  ......................"
        DB	PAUSE
        ;	DB	'そう。'
        DB	"I see."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・私、練習があるから。'
        DB	"Ruri:  ........Well, I've got practice myself."
        DB	NEXT
        ;	DB	'【%001】：・・・あ、ああ・・・'
        DB	"%001:  Okay, see you later."
        DB	NEXT
        ;	DB	'【瑠璃】：さよなら。'
        DB	"Ruri:  Goodbye."
        DB	NEXT
        B_P1 B_SUDA
        						;瑠璃消し
        ;	DB	'【%001】：・・・あ・・・'
        DB	"%001:  ...........Wait! "
        DB	PAUSE
        ;	DB	'もういねぇ。'
        DB	"She's gone."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・何だったんだ？'
        DB	"%001:  What was that all about?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  .................................."
        DB	NEXT
        ;	DB	'【%001】：ま、い～や。俺も行こ。'
        DB	"%001:  Hmm, guess I'll be going, too."
        DB	NEXT
        B_O B_SUDA
        DB G_FLG,G_COPYI,159,1
        DB	SINARIO,'CS805.OVL',0
        DW	0000H
        
M11:		;考える
        ;	DB	'・・・白水さん・・・何が言いたいんだろう？'
        DB	"What does she want to tell me?"
        DW	0000H


end
