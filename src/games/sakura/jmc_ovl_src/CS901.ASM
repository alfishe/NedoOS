;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　９０１
;		野郎共、クリスマスパーティーよっ！

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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'話す',0
VV1:	DB	1,	'TALK',0
;VV2:	DB	2,	'相談する',0
VV2:	DB	2,	'CONSULT',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'美緒',0
NN2:	DB	2,	'MIO',0
;NN3:	DB	3,	'事情',0
NN3:	DB	3,	'THE SITUATION',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;話す　鈴子２
S2:		DW	VV1, NN2,  2, M4, M5		;話す　美緒２
S3:		DW	VV1, NN3,  3, M6, M7		;話す　事情２
S4:		DW	VV2, -1,  4, M8, M9, M10, M11		;相談する４


;イニシャルメッセージ
M1:
	DB	BGM,12
;	DB	'・・・吐く息も、白く凍える１２月。'
	DB	".........................."
	DB	NEXT
	DB	"December, when the cold air turns your breath white."
	DB	NEXT
	E_CG B_SUDA,'AE_003'
;	DB	'【今日子】：さぁ、クリスマスパーティーの予定を决めるわよ！'
	DB	"Kyoko:  Okay, we have to decide when to have the Christmas"
	DB	CR
	DB	"Party today! "
	DB	NEXT
;	DB	'【今日子】：・・・ンじゃ宴会委員！まかせたわよ！'
	DB	"Kyoko:  It's all up to to you students, so I hope you do"
	DB	CR
	DB	"a good job!"
	DB	NEXT
;	DB	'この間、大まかなイベントだけで５０くらい案が出た。'
	DB	"There were over fifty suggestions for things to do at the"
	DB	CR
	DB	"Christmas Party."
	DB	NEXT
;	DB	'結局、収拾がつかなくなり・・・俺達宴会委員に押しつけられる、'
	DB	"Unfortunately, there was no budget to do anything, so we"
	DB	CR
	DB	"do the best we could by ourselves."
	DB	NEXT
;	DB	'もとい一任される事になったのであった。'
	DB	"I had been nominated again."
	DB	NEXT
;	DB	'【%001】：・・・はあ・・・'
	DB	"%001:  *sigh*"
	DB	NEXT
	BAK_INIT "AB_36_3"
	DB	BUF,B_COPY01										;背景コピー
	T_CG "CT14","W",0,10,4
;	DB	'【誠】：溜息をつくな。こっちまで気が滅入る。',CR
;	DB	'【清美】：・・・あの・・・%001さん・・・'
	DB	"Makoto:  It's not good manners to sigh like that.",CR
	DB	"Kiyomi:  .....Um, %001?"
	DB	NEXT
;	DB	'【%001】：・・・そ～は言うけどよ・・・ど～やって収集つけんだ？'
	DB	"%001:  Yeah, I guess. I'm just wondering what to do, that's"
	DB	CR
	DB	"all."
	DB	NEXT
;	DB	'【誠】：・・・・・・・・・',CR
;	DB	'【清美】：・・・・・・あの・・・・・・'
	DB	"Makoto:  ................",CR
	DB	"Kiyomi:  ......%001?"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	TU_CG "CT01","W",0,30,1
	T_CG 'CT03','W',0,0,3
	DB	ANI,A_ON,1
;	DB	'【鈴子】：%001く～ん！',CR
;	DB	'【美緒】：%001先輩！'
	DB	"Reiko:  %001!",CR
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【鈴子・美緒】：一緒にお昼食べよっ！'
	DB	"Reiko/Mio:  Let's eat lunch!"
	DB	NEXT
;	DB	'【%001・誠】：・・・はあ・・・'
	DB	"%001/Makoto:  ...........They're back."
	DB	NEXT
;	DB	'【鈴子】：・・・どうしたの２人とも？'
	DB	"Reiko:  What's wrong with the two of you?"
	DB	C_BLD,C_N_ON,1,1		;「話す　鈴子」　消す
	DB	C_BLD,C_N_ON,1,2		;「話す　美緒」　消す
	DB	C_BLD,C_V_ON,2			;「相談する」　消す
	DW	0000H

M2:		;話す　鈴子１
;	DB	'【%001】：鈴子さんも、来るんだろ？クリスマスパーティー。'
	DB	"%001:  Are you coming to our class's Christmas Party,"
	DB	CR
	DB	"Reiko?"
	DB	NEXT
;	DB	'【鈴子】：もっちろん！'
	DB	"Reiko:  Of course!"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;話す　鈴子２
;	DB	'【鈴子】：・・・今から、楽しみね。'
	DB	"Reiko:  I'm really looking forward to it."
	EF_SET 101
	DW	0000H

M4:		;話す　美緒１
;	DB	'【%001】：美緒ちゃんも、来るんだろ？クリスマスパーティー。'
	DB	"%001:  Are you coming to the Christmas Party, Mio?"
	DB	NEXT
;	DB	'【美緒】：・・・・・・'
	DB	"Mio:  Yes, of course!"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　美緒２
;	DB	'【美緒】：みんなでクリスマスパーティーかぁ・・・'
	DB	"Mio:  It'll be fun."
	EF_SET 102
	DW	0000H

M6:		;話す　事情１
;	DB	'【%001】：実は・・・かくかくしかじか。'
	DB	"I explained our problem to the girls."
	DB	NEXT
;	DB	'【鈴子】：なるほど・・・大変ねぇ。'
	DB	"Reiko:  Really? That's rough."
	DB	NEXT
;	DB	'【誠】：そ～なんですよ～。'
	DB	"Makoto:  It sure is!"
	DB	NEXT
;	DB	'【清美】：・・・あの・・・'
	DB	"Kiyomi:  Excuse me..."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M7:		;話す　事情２
;	DB	'【%001】：・・・ホントにもぉ、俺にど～しろってゆ～んだまったく。'
	DB	"%001:  I don't know how to organize a Christmas party."
	DB	NEXT
;	DB	'【清美】：・・・あの・・・'
	DB	"Kiyomi:  Could I say something?"
	DB	NEXT
;	DB	'【鈴子】：・・・そうだ！清美に手伝ってもらったら？'
	DB	"Reiko:  Why don't you have Kiyomi help you?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................."
	DB	PAUSE
;	DB	'あ、なるほど。'
	DB	"Now that's a good idea."
	DB	C_BLD,C_V_OFF,2			;「相談する」
	DW	0000H

M8:		;相談する１
	DB BUF,B_COPY01
	T_CG "CT02","W",0,5,2
;	DB	'【%001】：・・・新藤さん、悪いんだけど知恵貸してくれない？'
	DB	"%001:  Kiyomi, will you give us some advice?"
	DB	NEXT
;	DB	'【清美】：・・・あの・・・先程からそれを言おうとして、'
;	DB	'声をかけていたのですが・・・'
	DB	"Kiyomi:  That's what I've been trying to say for the past"
	DB	CR
	DB	"few minutes. You wouldn't listen to me."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DB	NEXT
;	DB	'【%001】：ごっごめん！'
	DB	"%001:  I'm sorry!"
	DB	NEXT
;	DB	'【清美】：いえ・・・結果オーライですわ。'
	DB	"Kiyomi:  It's alright."
	DB	FLG,F_COPYI,4,1
	DB	C_BLD,C_V_ON,1			;「話す」　消す
	DW	0000H

M9:		;相談する２
;	DB	'【%001】：でさ・・・どうすればいいと思う？'
	DB	"%001:  So, what should we do?"
	DB	NEXT
;	DB	'【清美】：そうですわね・・・まずはアイディアの整理から始めないと、'
;	DB	'どうにもなりませんわね。'
	DB	"Kiyomi:  Well, first you should organize all the various"
	DB	CR
	DB	"ideas you get."
	DB	NEXT
;	DB	'【清美】：ですから、明日までにわたくしが整理してまいりますわ。'
	DB	"Kiyomi:  I'll write everything down and we'll talk about"
	DB	CR
	DB	"it again tomorrow."
	DB	NEXT
;	DB	'【%001】：・・・悪ィ。たのまぁ。'
	DB	"%001:  Ah, thanks."
	DB	NEXT
;	DB	'【清美】：お任せください。'
	DB	"Kiyomi:  Just leave it up to me."
	DB	NEXT
	T_CG1 "CT07","W",0,30,7
	DB ANI,A_ON,2
;	DB	'【星愛】：・・・もし宜しければ、わたくしにもお手伝いさせて下さい。'
	DB	"Seia:  I'd like to help, too."
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  You would?"
	DB	NEXT
;	DB	'【星愛】：わたくし、クラス委員ですもの。'
	DB	"Seia:  I am the class representative, after all."
	DB	NEXT
;	DB	'【清美】：そうですか・・・ぜひお願いいたしますわ。'
	DB	"Kiyomi:  That's right. Please help us."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................."
	DB	NEXT
;	DB	'【美緒】：？　どうしたの先輩？'
	DB	"Mio:  What's wrong, %001?"
	DB	NEXT
;	DB	'【%001】：・・・あ、いやなんでもない。'
	DB	"%001:  Oh, nothing."
	DB	NEXT
;	DB	'（・・・あの吉田が宴会の手伝いをねえ・・・）'
	DB	"I'm just surprised to see Seia helping out with a"
	DB	CR
	DB	"party..."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M10:		;相談する３
;	DB	'【星愛】：・・・・・・それに、白水さんのお別れ会も兼ねてますもの。'
	DB	"Seia:  We should combine the Christmas Party with Ruri's"
	DB	CR
	DB	"farewell party."
	DB	PAUSE
;	DB	'盛大にやって差し上げなくては・・・・・・'
	DB	" It'll be the biggest party we've ever had."
	DB	NEXT
;	DB	'思わず、静まり返る俺達。'
	DB	"Suddenly, the room got very quiet."
	DB	NEXT
;	DB	'そう・・・・・・'
	DB	"Oh, that's right. I almost forgot."
	DB	NEXT
;	DB	'白水さんは、母親の元に帰るのだという。'
	DB	"Ruri was going to go live with her mother soon."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'思わず、視線を向けた先には・・・転校当初と変わらない、外をつまらなそうに眺める白水さんの姿がある。'
	DB	"I looked at her, and to my surprise she was looking out the"
	DB	CR
	DB	"window with a bored expression on her face, just like she"
	DB	CR
	DB	"did when she first transferred to our school."
	DB	NEXT
;	DB	'だけど。'
	DB	".............But that's not right."
	DB	NEXT
;	DB	'【%001】：・・・おーい、白水さ～ん！'
	DB	"%001:  Ruri!"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT05","W",0,0,5
;	DB	'【瑠璃】：・・・・・・なに？'
	DB	"Ruri:  .........Yes?"
	DB	NEXT
;	DB	'【%001】：クリスマスパーティーだけど・・・なんか要望ある？'
	DB	"%001:  Do you have any requests for the Christmas Party?"
	DB	PAUSE,CR
	DB	"We're going to combine your farewell party with it."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・別に無いわ。'
	DB	"Ruri:  ......No."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  Oh."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・じゃ。'
	DB	"Ruri:  .........Well, bye."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT08","W",0,25,8
;	DB	'【恵依美】：・・・相っ変わらず、無愛想ね～。'
	DB	"Meimi:  She's just the same as always."
	DB	NEXT
;	DB	'【%001】：・・・・・・だけどさ。話をしてくれるようになったじゃないか。'
	DB	"%001:  But she's come a long way. She talks to me a lot,"
	DB	CR
	DB	"now."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ............"
	DB	PAUSE
;	DB	'そうだね。'
	DB	"I guess."
	DB	NEXT
;	DB	'【清美】：・・・では星愛さん、あちらで作業いたしましょう。'
	DB	"Kiyomi:  Seia, let's go over there and talk this over, shall"
	DB	CR
	DB	"we?"
	DB	NEXT
;	DB	'【星愛】：そうですわね。'
	DB	"Seia:  Okay."
;	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	TU_CG "CT01","W",0,30,1
	T_CG 'CT03','W',0,0,3
	DB	ANI,A_ON,1
	DB	FLG,F_COPYI,4,3
	DW	0000H

M11:		;相談する４
;	DB	'【誠】：新藤と吉田に任せておけば大丈夫だろ？'
	DB	"Makoto:  You should let Kiyomi and Seia handle the party."
	DB	NEXT
;	DB	'【%001】：・・・ああ、そうだな。'
	DB	"%001:  .......Hmm, I guess."
	DB	C_BLD,C_V_OFF,1			;「話す」　出す
	DB	C_BLD,C_N_OFF,1,1		;「話す　鈴子」　出す
	DB	C_BLD,C_N_OFF,1,2		;「話す　美緒」　出す
	DB	C_BLD,C_N_ON,1,3		;「話す　事情」　消す
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,100,1
	DB	FLG,F_MAND,3,100,101,102
	DB	FLG,F_EXIT,100
	DB	NEXT
	DB BUF,B_COPY01
	TU_CG "CT02","W",0,5,2
	T_CG "CT07","W",0,30,7
	DB ANI,A_ON,2
;	DB	'【清美】：・・・%001さん！'
	DB	"Kiyomi:  %001!"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'【星愛】：取り敢えず、草案がまとまりましたわ。'
	DB	"Seia:  We've got some ideas we'd like you to look at."
	DB	PAUSE
;	DB	'見て頂けます？'
	DB	" Are you"
	DB	CR
	DB	"busy right now?"
	DB	NEXT
;	DB	'【%001】：え、もう出来たの！？'
	DB	"%001:  You girls work fast!"
	DB	PAUSE
;	DB	'どれどれ・・・'
	DB	" Show me..."
	DB	NEXT
	B_O B_SUDA
	E_CG B_GURU3,'T_09'
	DB	NEXT
	DB	SINARIO,'CS902.OVL',0
	DW	0000H


end
