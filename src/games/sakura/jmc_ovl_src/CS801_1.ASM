;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０１＿１
;		体育祭前　後悔、先に立たず

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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,-1
CM2:	DW	VV2,	NN1,NN2,NN3,NN4,NN5,NN6,-1
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
;NN6:	DB	6,	'星愛',0
NN6:	DB	6,	'SEIA',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　誠
S2:		DW	VV1, NN2,  2, M3		;見る　鈴子
S3:		DW	VV1, NN3,  3, M4		;見る　清美
S4:		DW	VV1, NN4,  4, M5		;見る　美緒
S5:		DW	VV2, NN1,  5, M6, M7, M8, M9, M10, M11		;話す　誠６
S6:		DW	VV2, NN2,  6, M12, M13		;話す　鈴子２
S7:		DW	VV2, NN3,  7, M14		;話す　清美１
S8:		DW	VV2, NN4,  8, M15, M16		;話す　美緒２
S9:		DW	VV2, NN5,  9, M17, M18		;話す　恵依美２
S10:		DW	VV2, NN6,  10, M19, M20		;話す　星愛２
S11:		DW	VV3, -1,  11, M21		;考える


;イニシャルメッセージ
M1:
	DB	BGM,6
	B_O B_SUDA
	BAK_INIT "AB_36_3"
;	DB	'・・・・・・・・・３日後、出場種目第一提出日。'
	DB	"..............Three days later. We have to sign up for the"
	DB	CR
	DB	"sport that we chose."
	DB	NEXT
	E_CG B_SUDA,'AE_003'
;	DB	'【今日子】：・・・・・・はい、これで全部ね？'
	DB	"Kyoko:  ........Is this everyone?"
	DB	NEXT
;	DB	'【今日子】：え～っと、どれどれ・・・・・・'
	DB	"Kyoko:  Um, let's see..."
	DB	PAUSE
;	DB	'あら？'
	DB	" Huh?"
	DB	NEXT
;	DB	'【今日子】：気のせいかぁ、%001君の出番やたら多くない？'
	DB	"Kyoko:  %001, aren't you overdoing it, participating in"
	DB	CR
	DB	"this many events?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................................"
	DB	NEXT
;	DB	'【%001】：あ、ホントだ。'
	DB	"%001:  Probably."
	DB	NEXT
;	DB	'【今日子】：・・・『ホントだ』って、大丈夫なの？%001君。'
	DB	"Kyoko:  Is that alright with you, %001?"
	DB	NEXT
;	DB	'【%001】：・・・・・・まぁ、何とかなるでしょ。'
	DB	"%001:  .......It'll be okay somehow."
	DB	NEXT
;	DB	'【今日子】：・・・ひいふうみい・・・全種目の９割に出る事になってるけどぉ？'
	DB	"Kyoko:  You've volunteered to be in almost all the events,"
	DB	CR
	DB	"you know."
	DB	NEXT
;	DB	'【%001】：・・・・・・まぁ、大丈夫でしょう。'
	DB	"%001:  ..........I'll be okay."
	DB	NEXT
;	DB	'【今日子】：ホントに？'
	DB	"Kyoko:  Really?"
	DB	NEXT
;	DB	'【%001】：ええ、多分。'
	DB	"%001:  Yes, I think."
	DB	NEXT
;	DB	'【今日子】：・・・ま、本人がそう言うんならいっか。'
	DB	"Kyoko:  ..........Well, if you say so..."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT02","W",'I',30,2
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  .................................."
	DB	NEXT
;	DB	'【清美】：あの、%001さん。'
	DB	"Kiyomi:  Excuse me, %001?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Yes?"
	DB	NEXT
;	DB	'【清美】：わたくしがこんな事を言うのもなんですけど・・・'
	DB	"Kiyomi:  Is this really alright?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、何とかなるだろ。'
	DB	"%001:  ...I'll be okay."
	DB	NEXT
;	DB	'【清美】：・・・・・・なら良いのですが・・・・・・'
	DB	"Kiyomi:  ..............................."
	DB	NEXT
	BAK_INIT "AB_36_3"
	B_P1 B_SUDA
;	DB	'・・・とか言ってる内に昼休み。'
	DB	"Then it was lunch time again."
	DB	NEXT
	DB	FLG,F_JR
	DW	M6
	DW	0000H

M2:		;見る　誠
;	DB BUF,B_COPY01
;	T_CG "CT14","W",0,0,1
;	DB	'こいつはこいつで、心配してくれているらしい。'
	DB	"Makoto seems worried about me."
	DB	NEXT
;	DB	'らしくねえな・・・それに、そう思うんなら初めから止めろ。'
	DB	"That's not like him. But if he was really worried about"
	DB	CR
	DB	"me, he should have stopped me three days ago."
	DW	0000H

M3:		;見る　鈴子
;	DB BUF,B_COPY01
;	T_CG "CT01","W",0,0,1
;	DB	'鈴子さん・・・なんか心配そうだな。'
	DB	"Reiko looks worried about me."
;	DB	NEXT
;	DB	'・・・きっと、止められなかったことを悔やんでいるんだな・・・'
;	DB	"She's probably sorry she wasn't able to stop me."
	DW	0000H

M4:		;見る　清美
;	DB BUF,B_COPY01
;	T_CG "CT02","W",'I',30,2
;	DB	'新藤さん・・・心配してくれているようだ。'
	DB	"Kiyomi looks worried about me."
	DB	NEXT
;	DB	'・・・責任感じてるのかな？'
	DB	"Maybe she feels responsible just a little?"
	DB	NEXT
;	DB	'引き受けたのは俺だから、全部の責任は俺にあるはずなのに。'
	DB	"Although I'm really responsible for my own actions, not"
	DB	CR
	DB	"her."
	DW	0000H

M5:		;見る　美緒
;	DB BUF,B_COPY01
;	T_CG "CT03","W",0,0,3
;	DB	'美緒ちゃん・・・そんなに心配しなくていいよ。'
	DB	"Mio looks worried."
	DB	NEXT
;	DB	'・・・責任感じてるのかな？'
	DB	"Maybe she's feeling responsible?"
	DB	NEXT
;	DB	'俺の優柔不断が蒔いた種なのに。'
	DB	"Although it's my own fault, for not choosing decisively."
	DW	0000H

M6:		;話す　誠１
	DB BUF,B_COPY01
	T_CG "CT14","W",0,0,1
;	DB	'【誠】：しっかし、本当にいいのか？'
	DB	"Makoto:  Are you sure you can go through with this?"
	DB	NEXT
;	DB	'【%001】：何が？'
	DB	"%001:  With what?"
	DB	NEXT
;	DB	'【誠】：個人技だけならともかくよ・・・団体競技は、１人じゃ勝てないぜ？'
	DB	"Makoto:  You might be able to do okay in the individual"
	DB	CR
	DB	"sports. But the team sports, no way."
	DB	NEXT
;	DB	'【%001】：そりゃまぁそーだが。'
	DB	"%001:  ...Well, I guess."
	DB	NEXT
;	DB	'【誠】：特にサッカーとかは、チームとしての動きが重要だからなぁ・・・'
;	DB	'その辺くらい、合わせておいた方がいいんじゃないか？'
	DB	"Makoto:  Especially soccer. Teamwork is really important."
	DB	CR
	DB	"You need to train with the team."
	DB	NEXT
;	DB	'【%001】：まぁそ～だろーなぁ・・・で、ど～すればいいんだ？'
	DB	"%001:  ...Um, I guess. So what should I do?"
	DB	NEXT
;	DB	'【誠】：そりゃお前・・・練習あるのみじゃないか？'
	DB	"Makoto:  Train!"
	DB	NEXT
;	DB	'【%001】：練習、ねぇ・・・・・・'
	DB	"%001:  Yeah, I guess..."
	DB	NEXT
	T_CG "CT02","W",'I',33,2
	DB	ANI,A_ON,1
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ........................................."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M7:		;話す　誠２
;	DB BUF,B_COPY01
;	T_CG "CT14","W",0,0,1
;	DB	'【誠】：幾らお前でも、ぶっつけ本番で味方の動きは読めないだろ？'
	DB	"Makoto:  You're not going to be able to read your"
	DB	CR
	DB	"opponent's moves when the real thing starts, right?"
	DB	NEXT
;	DB	'【%001】：そりゃ、な。'
	DB	"%001:  ........I guess not."
	DB	NEXT
;	DB	'【誠】：だったら、練習中に見て覚えるしかないんじゃないか？'
	DB	"Makoto:  So you've got to study up on them now, while"
	DB	CR
	DB	"practicing!"
	DB	NEXT
;	DB	'【%001】：・・・確かにな。'
	DB	"%001:  Sounds good to me."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M8:		;話す　誠３
;	DB BUF,B_COPY01
;	T_CG "CT14","W",0,0,1
;	DB	'【誠】：まぁオレも、勝ち負けだけにこだわりたくはないけどよ・・・'
;	DB	'やる事やんないで、負けるのは嫌だしな。'
	DB	"Makoto:  I know you can't just think about winning. But"
	DB	CR
	DB	"you have to try..."
	DB	NEXT
;	DB	'【%001】：・・・そうだな。その通りだ。'
	DB	"%001:  That's right."
	DB	FLG,F_COPYI,5,3
	DW	0000H

M9:		;話す　誠４
;	DB BUF,B_COPY01
;	T_CG "CT14","W",0,0,1
;	DB	'【誠】：・・・で、だ。それだけ掛け持ちやってて・・・練習時間取れるのか？'
	DB	"Makoto:  Do you have time to practice?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................................."
	DB	NEXT
;	DB	'【%001】：考えてなかった・・・・・・'
	DB	"%001:  I wasn't thinking about that."
	DB	FLG,F_COPYI,5,4
	DW	0000H

M10:		;話す　誠５
;	DB BUF,B_COPY01
;	T_CG "CT14","W",0,0,1
;	DB	'【誠】：ど～すんだよお前。'
	DB	"Makoto:  So what are you going to do?"
	DB	NEXT
;	DB	'【%001】：ど～するって・・・ど～にかするしかねぇだろ。'
	DB	"%001:  I don't know. I'll be okay."
	DB	NEXT
;	DB	'【誠】：・・・出来るのかぁ？'
	DB	"Makoto:  Really?"
	DB	NEXT
;	DB	'【%001】：ああ・・・俺の番が終わったらすぐ次に行けば何とか・・・'
	DB	"%001:  I'll practice with different groups after school"
	DB	NEXT
;	DB	'【誠】：んな事やって、身体が持つのか？'
	DB	"Makoto:  Are you going to be able to keep up that kind"
	DB	CR
	DB	"of pace? Playing so many sports like that?"
	DB	NEXT
;	DB	'【%001】：ああ、その辺は大丈夫だ。'
	DB	"%001:  Sure, I'll be alright."
	DB	NEXT
;	DB	'【誠】：・・・ならい～んだけどよ・・・'
	DB	"Makoto:  Okay, then."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ....................................."
	DB	FLG,F_COPYI,5,5
	DW	0000H

M11:		;話す　誠６
	DB BUF,B_COPY01
	T_CG "CT14","W",0,0,1
;	DB	'【誠】：・・・ホントに大丈夫かぁ？'
	DB	"Makoto:  You're sure you're okay?"
	DB	NEXT
;	DB	'【%001】：ああ・・・何とかするさ。'
	DB	"%001:  Yep, just fine."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ....................................."
	DB	FLG,F_COPYI,105,1
	EF_SET 105
	DW	0000H

M12:		;話す　鈴子１
;	DB BUF,B_COPY01
;	T_CG "CT01","W",0,0,1
;	DB	'【鈴子】：・・・どう？%001君、何に出るか决めた？'
	DB	"Reiko:  So did you decide which sport you're going to"
	DB	CR
	DB	"enter?"
	DB	NEXT
;	DB	'【%001】：ああ・・・これ。'
	DB	"%001:  Yes. All of these..."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ....................................."
	DB	NEXT
;	K_CG 'CT01','I',0,1
;	DB	'【鈴子】：ちょっと・・・こんなに出るの？'
	DB	"Reiko:  Wait a minute. You're going to be in this many events?"
	DB	NEXT
;	DB	'【%001】：そうらしいな。'
	DB	"%001:  Apparently."
	DB	NEXT
;	DB	'【鈴子】：『らしいな』じゃないでしょ？自分の事なのよ？'
	DB	"Reiko:  Not 'apparently.' You're really going to do this?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  I guess so."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ....................................."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M13:		;話す　鈴子２
;	DB BUF,B_COPY01
;	T_CG "CT01","W",'I',0,1
;	DB	'【鈴子】：大丈夫なの？ホントに・・・・・・'
	DB	"Reiko:  You're sure you'll be okay?"
	DB	NEXT
;	DB	'【%001】：多分。'
	DB	"%001:  I think so."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ....................................."
	DB	FLG,F_COPYI,106,1
	EF_SET 106
	DW	0000H

M14:		;話す　清美１
;	DB BUF,B_COPY01
;	T_CG "CT02","W",'I',30,2
;	DB	'【清美】：・・・%001さん・・・'
	DB	"Kiyomi:  %001..."
	DB	NEXT
;	DB	'【%001】：大丈夫大丈夫。'
	DB	"%001:  I'm fine, don't worry about a thing."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ....................................."
	DB	FLG,F_COPYI,107,1
	EF_SET 107
	DW	0000H

M15:		;話す　美緒１
;	DB BUF,B_COPY01
;	T_CG "CT03","W",0,0,3
;	DB	'【美緒】：%001先輩、何に出るの？'
	DB	"Mio:  So what sport are you going to be in?"
	DB	NEXT
;	DB	'【%001】：ほれ。'
	DB	"%001:  Right here."
	DB	NEXT
;	DB	'【美緒】：・・・あ！テニス出てくれるんだ。'
	DB	"Mio:  Oh! You're going to play tennis!"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yep."
	DB	NEXT
;	DB	'【美緒】：やったあ！'
	DB	"Mio:  That's great. "
	DB	PAUSE
;	DB	'・・・でも、他にもこんなにいっぱい・・・'
	DB	"But what about all these others?"
	DB	NEXT
;	DB	'【%001】：ま、何とかなるだろ。'
	DB	"%001:  I'll do my best."
	DB	NEXT
;	DB	'【美緒】：・・・%001先輩・・・'
	DB	"Mio:  ........%001..."
	DB	FLG,F_COPYI,8,1
	DW	0000H

M16:		;話す　美緒２
;	DB BUF,B_COPY01
;	T_CG "CT03","W",0,0,3
;	DB	'【美緒】：・・・%001先輩・・・'
	DB	"Mio:  ......%001."
	DB	NEXT
;	DB	'【%001】：大丈夫大丈夫。'
	DB	"%001:  I'll be okay, don't worry about me."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  ..........................................."
	DB	FLG,F_COPYI,108,1
	EF_SET 108
	DW	0000H

M17:		;話す　恵依美１
;	DB	'【%001】：・・・中野は？'
	DB	"%001:  ......Where's Meimi?"
	DB	NEXT
;	DB BUF,B_COPY01
;	T_CG "CT14","W",0,0,1
;	DB	'【誠】：あいつなら、さっき吉田と一緒にどっか行ったぜ。'
	DB	"Makoto:  She just disappeared with Seia."
	DB	NEXT
;	DB	'【%001】：そか。'
	DB	"%001:  I see."
	DB	FLG,F_COPYI,9,1
	DW	0000H

M18:		;話す　恵依美２
;	DB	'中野はいない。ついでに用も無い。'
	DB	"She's not here. There's no particular reason to talk to"
	DB	CR
	DB	"her, anyway."
	EF_SET 109
	DW	0000H

M19:		;話す　星愛１
;	DB	'【%001】：・・・吉田は？'
	DB	"%001:  Where's Seia?"
	DB	NEXT
;	DB BUF,B_COPY01
;	T_CG "CT14","W",0,0,1
;	DB	'【誠】：あいつなら、さっき中野と一緒にどっか行ったぜ。'
	DB	"Makoto:  She just disappeared with Meimi."
	DB	NEXT
;	DB	'【%001】：そか。'
	DB	"%001:  I see."
	DB	FLG,F_COPYI,10,1
	DW	0000H

M20:		;話す　星愛２
;	DB	'吉田はいない。ついでに用も無い。'
	DB	"She's not here. There's no particular reason to talk to"
	DB	CR
	DB	"her, anyway."
	DB	FLG,F_COPYI,110,1
	EF_SET 110
	DW	0000H

M21:		;考える
;	DB	'う～む、全種目の約９０％か・・・割ときついかもしんない。'
	DB	"I'm going to be in ninety percent of the events. That's harsh."
	DB	NEXT
;	DB	'ま、ど～にかなるだろ。'
	DB	"Well, I guess it'll be okay, somehow."
	DB	FLG,F_COPYI,111,1
	EF_SET 111
	DW	0000H

M_EXIT:
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,8,255,105,106,107,108,109,110,111
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
;	DB	'・・・・・・そんなこんなで、放課後。'
	DB	"School's over."
	B_P1 B_SUDA
	DB	NEXT
;	DB	'【%001】：・・・さ～て、帰って寝るか。'
	DB	"%001:  Guess I'll go home and get some sleep."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT02","W",'I',30,2
;	DB	'【清美】：あの・・・%001さん・・・'
	DB	"Kiyomi:  Um, %001?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Yes?"
	DB	NEXT
;	DB	'【清美】：宜しかったら・・・これ、見てもらえますか？'
	DB	"Kiyomi:  Would you mind looking at this?"
	DB	NEXT
;	DB	'【%001】：？　何々・・・'
	DB	"%001:  Let's see..."
	DB	NEXT
;	DB	'【%001】：『クイックコンビネーション（バレー）→守備練習（野球）→１・２コンビネーション（サッカー）→・・・』',CR
	DB	"She hands me a thick book. '1001 Training Methods' is"
	DB	CR
	DB	"written on the cover."
	DB	NEXT
;	DB	'・・・これは？'
	DB	"%001:  What's this?"
	DB	NEXT
;	DB	'【清美】：%001さんの練習メニューですわ。時間が無くて、完璧なものは作れませんでしたが、何かの参考になればと思いまして・・・・・・'
	DB	"Kiyomi:  It's your training schedule. You can use it for"
	DB	CR
	DB	"a crash course in all the events you're participating in."
	DB	NEXT
;	DB	'【%001】：・・・そか。ありがたく貰っておくよ。悪りィな新藤さん。'
	DB	"%001:  Ah, thanks. That's really nice of you, Kiyomi."
	DB	NEXT
;	DB	'【清美】：いえ、お役に立てれば嬉しいですわ。'
	DB	"Kiyomi:  No, it's nothing, really."
	DB	NEXT
;	T_CG1 "CT14","W",0,0,1
;	DB ANI,A_ON,2
;	DB	'【誠】：・・・おーい%001、帰ろうぜ！'
	DB	"Makoto:  Let's go home, %001!"
	DB	NEXT
;	DB	'【%001】：ああ・・・じゃな、新藤さん！'
	DB	"%001:  Okay. See you later, Kiyomi!"
	B_O B_SUDA
	DB	NEXT
;	DB BUF,B_COPY01
;	T_CG "CT02","W",'I',30,2
;	DB	'【清美】：・・・あ・・・'
	DB	"Kiyomi:  ....Goodbye."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ............................"
	DB	NEXT
;	DB	'【清美】：・・・%001さん・・・'
	DB	"Kiyomi:  ........%001."
	DB	NEXT
	DB	SINARIO,'CS801_2.OVL',0
	DW	0000H


end
