;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０７
;		体育祭１日前　鈴子ｖｓＵＦ○キャッチャー

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'クレーンゲーム',0
NN2:	DB	2,	'CRANE GAME',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子
S2:		DW	VV1, NN2,  2, M4		;見る　クレーンゲーム
S3:		DW	VV2, NN1,  3, M5, M6, M7		;話す　鈴子
S4:		DW	VV3, NN1,  4, M8		;考える　鈴子


;イニシャルメッセージ
M1:
	DB	BGM,17
;	B_O B_SUDA
	BAK_INIT "AB_25"
	B_P1 B_YOKO
;	DB	'【%001】：・・・さて。いい汗かいたし、そろそろ帰るか。'
	DB	"%001:  ..........Well, guess I'll go home now."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	PAUSE
;	DB	'あれ？'
	DB	"Huh?"
	DB	NEXT
;	DB	'【%001】：・・・鈴子さんじゃないか？'
	DB	"%001:  Look, it's Reiko."
	DB	NEXT
	DB	BGM,29
	DB BUF,B_COPY01
	T_CG "CT01","C",'D',5,1
;	DB	'【鈴子】：・・・あ゛～～～～～～っ！また落ちたぁ！'
	DB	"Reiko:  Damn! I dropped it again!"
	DB	NEXT
;	DB	'【%001】：・・・・・・何をやってるかと思えば・・・・・・'
	DB	"What's she doing?"
	DB	NEXT
;	DB	'【鈴子】：今度こそ！見てらっしゃいっ！！'
	DB	"Reiko:  This time! This time I'm going to get it!"
	DB	NEXT
;	DB	'俺の視線の先、ゲーセンの入口には・・・人形取り機と熱いバトルを繰り広げる鈴子さんの姿があった。'
	DB	"Reiko was at the crane game machine, trying to pick up a"
	DB	CR
	DB	"doll from inside the machine." 
; Note: what the fuck is "UFO Catcher" in Engish?
	DW	0000H

M2:		;見る　鈴子
;	DB	'鈴子さんが・・・クレーンゲームやってる？'
	DB	"Reiko is playing the 'UFO Catcher' crane game."
	DB	NEXT
;	DB	'・・・なんか、見慣れない構図だ・・・'
	DB	"....I didn't think she'd be the kind of person to go out"
	DB	CR
	DB	"for those things."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　鈴子
;	DB	'なんか・・・クレーンゲームに悪態ついてるぞ？'
	DB	"That crane machine is famous for being evil."
	DB	NEXT
;	DB	'・・・いくらつぎ込んだんだろう？'
	DB	"I wonder how much money she's lost so far?"
	DW	0000H

M4:		;見る　クレーンゲーム
;	DB	'・・・ここのクレーンゲームは、アームの力が他の店に比べて若干強い・・・と思ったけど・・・'
	DB	"I thought that the arm on this machine was slightly"
	DB	CR
	DB	"stronger than on other machines I've played."
	DB	NEXT
;	DB	'だからといって人形がとりやすい、とはかぎんないしな・・・'
	DB	"But that still doesn't make it an easy game."
	DW	0000H

M5:		;話す　鈴子
;	DB	'【鈴子】：・・・よーしよし、その調子・・・'
	DB	"Reiko:  Good, good..."
	DB	PAUSE
;	DB	'あ゛あ゛っ！またおちたぁあぁぁぁっっ！！'
	DB	" Damn! I dropped it again!"
	DB	NEXT
;	DB	'【%001】：・・・鈴子さん。'
	DB	"%001:  Hello, Reiko."
	DB	NEXT
;	DB	'【鈴子】：も～～～っ！'
	DB	"Reiko:  I hate this stupid game!"
	DB	PAUSE
;	DB	'機械のくせに馬鹿にしてぇっ！'
	DB	" Stop mocking me! You cruel"
	DB	CR
	DB	"machine!"
	DB	PAUSE
;	DB	'今度こそ取って見せるわ！覚悟なさい！！'
	DB	" ARRGH!!"
	DB	NEXT
;	DB	'【%001】：・・・鈴子さん・・・それじゃ亜希ちゃんと同類・・・'
	DB	"%001:  Reiko, you're acting just like Aki..."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M6:		;話す　鈴子
;	DB	'【鈴子】：・・・そーっと・・・そーっと・・・'
	DB	"Reiko:  Gently, gently..."
	DB	PAUSE
;	DB	'あ゛あ゛あ゛っ！『そ～っと』っ;て言ってるでしょっ！'
;	DB	'なんで「がっくん」しちゃうのよっ！？'
	DB	" Damn you! I'm being gentle with"
	DB	CR
	DB	"you! Why do you always drop it like that?"
	DB	NEXT
;	DB	'【%001】：・・・鈴子さん・・・機械に言ってもしょーがないと思う・・・'
	DB	"%001:  It's a machine, Reiko. You can't reason with it."
	DB	NEXT
;	DB	'【鈴子】：うるさいわねっ！外野は黙っててっ！！'
	DB	"Reiko:  I don't care! Shut up!"
	DB	NEXT
;	DB	'【%001】：は、はい・・・・・・'
	DB	"%001:  Yes ma'am!"
	DB	NEXT
;	DB	'【鈴子】：・・・まったく・・・'
	DB	"Reiko:  ....I hate this thing so much."
	DB	PAUSE
	K_CG "CT01",'V',5,2
;	DB	'って、え？'
	DB	" Huh?"
	DB	PAUSE
;	DB	'・・・%001君っ！？'
	DB	" %001? When"
	DB	CR
	DB	"did you get here?"
	DB	NEXT
;	DB	'【%001】：・・・うん・・・まぁ一応・・・'
	DB	"%001:  Oh, I've been here a while."
	DB	NEXT
;	DB	'【鈴子】：・・・あ、あ、あ・・・'
	DB	"Reiko:  Oh, I, um..."
	DB	PAUSE
;	DB	'ご、ごめんね！ついそのあの・・・'
	DB	" I'm sorry I told you to shut up."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M7:		;話す　鈴子
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	PAUSE
;	DB	'ぷっ。'
	DB	" Hahaha..."
	DB	NEXT
;	DB	'【鈴子】：・・・何がおかしいのよぉ・・・'
	DB	"Reiko:  Do you see something funny?"
	DB	NEXT
;	DB	'【%001】：・・・だってさ・・・ぷぷぷっ・・・'
	DB	"%001:  I do. Hahaha..."
	DB	NEXT
	K_CG "CT01",'D',5,1
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ....."
	DB	PAUSE
;	DB	'知らない！'
	DB	"Are you laughing at me, buster?"
	DB	NEXT
;	DB	'【%001】：悪りィ悪りィ。'
	DB	"%001:  I'm sorry. I won't laugh."
	DB	PAUSE
;	DB	'・・・でさ、何を取ろうとしてたの？'
	DB	" So what are you trying to"
	DB	CR
	DB	"get, anyway?"
	DB	NEXT
	T_CG "CT01",'C',0,5,3
;	DB	'【鈴子】：・・・これ。'
	DB	"Reiko:  That."
	DB	NEXT
;	DB	'【%001】：ああ、○りか。どれどれ・・・'
	DB	"%001:  Oh, it's cute. Let's see..."
	DB	NEXT
;	DB	'ちゃりん。'
	DB	"*JERK*"
	DB	PAUSE
;	DB	'うぃぃぃぃぃぃん。'
	DB	" *MOVE MOVE MOVE*"
	DB	PAUSE
;	DB	'がっきょん。'
	DB	" *GRAB*"
	DB	NEXT
;	DB	'【鈴子】：・・・掴んだ！'
	DB	"Reiko:  You've got it!"
	DB	NEXT
;	DB	'【%001】：・・・よっ、と。'
	DB	"%001:  Now for the hard part..."
	DB	NEXT
;	DB	'うぃぃぃぃぃぃん。'
	DB	"*MOVE MOVE MOVE*"
	DB	PAUSE
;	DB	'がたん！'
	DB	" *KACHA*"
	DB	NEXT
	K_CG "CT01",'K',5,4
;	DB	'【鈴子】：・・・やった！凄いわ%001君！'
	DB	"Reiko:  You got it! You're great, %001!"
	DB	NEXT
;	DB	'【%001】：・・・・・・はい、鈴子さん。'
	DB	"%001:  ........Anything for you, Reiko."
	DB	NEXT
;	DB	'【鈴子】：ありがとう。'
	DB	"Reiko:  Thank you very much."
	DB	PAUSE
;	DB	'・・・%001君、上手いわねぇ。'
	DB	" %001's good at everything."
	DB	NEXT
;	DB	'【%001】：・・・ま、ゲーセン通いは俺の日課みたいなもんだしな。'
	DB	"%001:  Well, I've been coming into game centers all my"
	DB	CR
	DB	"life."
	DB	NEXT
;	DB	'【鈴子】：・・・ところで%001君、ヒマ？'
	DB	"Reiko:  Are you busy right now?"
	DB	NEXT
;	DB	'【%001】：ああ、もうする事無くなっちゃったし。'
	DB	"%001:  No. Why?"
	DB	NEXT
;	DB	'【鈴子】：じゃあさ、何処かその辺で軽く食べない？'
	DB	"Reiko:  You want to get some dinner?"
	DB	PAUSE
;	DB	'・・・驕るわよ、この人形のお礼に。'
	DB	" I'll treat, since you"
	DB	CR
	DB	"got this for me."
	DB	NEXT
;	DB	'【%001】：は～い、お供しま～す。'
	DB	"%001:  Okay, let's go."
	DB	NEXT
	DB	SINARIO,'CS808.OVL',0
	DW	0000H

M8:		;考える　鈴子
;	DB	'鈴子さん、ゲーセンに来ることあるんだなあ・・・'
	DB	"I never thought she was the kind of person to come to"
	DB	CR
	DB	"game centers."
	DB	NEXT
;	DB	'・・・以外だよなあ。'
	DB	"You learn something new every day."
	DW	0000H


end
