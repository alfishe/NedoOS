;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０２
;		忘年会

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,NN2,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'乾杯！',0
VV3:	DB	3,	'KAMPAI!',0
;VV4:	DB	4,	'誠に振る',0
VV4:	DB	4,	'ASK MAKOTO',0
;VV5:	DB	5,	'一言語る',0
VV5:	DB	5,	'GIVE SPEECH',0

;NN1:	DB	1,	'亜希',0
NN1:	DB	1,	'AKI',0
;NN2:	DB	2,	'今日子',0
NN2:	DB	2,	'KYOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　亜希
S2:		DW	VV1, NN2,  2, M3		;見る　今日子
S3:		DW	VV2, NN1,  3, M4		;話す　亜希
S4:		DW	VV2, NN2,  4, M5, M6		;話す　今日子先生
S5:		DW	VV3, -1,  5, M7		;乾杯！
S6:		DW	VV4, -1,  6, M8, M9		;誠に振る２
S7:		DW	VV5, -1,  7, M10		;一言語る


;イニシャルメッセージ
M1:
	DB	BGM,3
	B_O B_WIPE
	BAK_INIT 'AB_01_1'
	DB	BUF,B_COPY01
	T_CG 'CT10',0,0,0,1
;	DB	'【英美】：みなさぁん、お茶が入りましたよ～。'
	DB	"Hidemi:  Here's some tea for you all..."
	DB	NEXT
;	DB	'大掃除が終わって、俺達は居間でテーブルを囲んでいた。'
	DB	"We were finally finished with the end-of-year housecleaning."
	DB	CR
	DB	"We all sat around the living room."
	DB	NEXT
	T_CG1 'CT09',0,0,12,2
	DB	ANI,A_ON,1
;	DB	'【伸幸】：みんな、今日はご苦労様。'
	DB	"Nobuyuki:  You all worked very hard today. Thank you."
	DB	CR
;	DB	'せっかくだから、今日はウチで年を越していかんかね？'
	DB	"Since you're already here, won't you greet the new year"
	DB	CR
	DB	"with us?"
	DB	NEXT
;	DB	'【清美】：よろしいのですか？'
	DB	"Hidemi:  Is that okay with you?"
	DB	NEXT
;	DB	'【伸幸】：もちろんだとも、みんなよく働いてくれたからね。'
	DB	"Nobuyuki:  Of course."
	DB	NEXT
;	DB	'【英美】：それじゃあ、お酒とおかずの買い出しに行かないといけないわねぇ。'
	DB	"Hidemi:  In that case, I'll go out and pick up a few things"
	DB	CR
	DB	"at the store."
	DB	NEXT
;	DB	'【鈴子】：あ、私達も手伝います。'
	DB	"Reiko:  Oh, I'll go too."
	DB	NEXT
;	DB	'「こ～んばんわぁ」'
	DB	"???:  Hello?"
	DB	NEXT
;	DB	'【%001】：ん？お客さんだ。'
	DB	"%001:  Mm? Someone's at the door?"
	DB	NEXT
;	DB	'「おっじゃましま～す！」'
;	DB	"???:  Excuse me?"
;	DB	NEXT
;	DB	'【美緒】：あれ、この声・・・'
	DB	"Mio:  That voice, it's..."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT12','C','K',10,3
;	DB	'【今日子】：どぉーもぉ、家庭訪問に来ました～。'
	DB	"Kyoko:  Hello! I just dropped by for a visit..."
	DB	NEXT
;	DB	'【%001】：先生！？'
	DB	"%001:  Sensei!"
	DB	NEXT
	T_CG1 'CT06','C','K',25,4
	DB	ANI,A_ON,3
;	DB	'【亜希】：%001せんぱ～い！'
	DB	"Aki:  Hello, %001."
	DB	NEXT
;	DB	'【誠】：げっ・・・亜希！'
	DB	"Makoto:  It's Aki!"
	DB	NEXT
	T_CG1 'CT06','C','D',25,4
	DB	ANI,A_ON,3
;	DB	'【亜希】：「げっ」とはなによ、島崎！'
	DB	"Aki:  Get back, Shimazaki!"
	DB	NEXT
	T_CG1 'CT06','C',0,25,4
	DB	ANI,A_ON,3
;	DB	'今日子先生と亜希ちゃんがやって来た。'
	DB	"Kyoko-sensei and Aki were here."
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DB C_BLD,C_V_ON,5
	DW	0000H

M2:		;見る　亜希
;	DB	'両手にコンビニの袋をぶら下げてる。'
	DB	"She's holding two bags from a convenience store."
	DB	NEXT
;	DB	'多分、酒のツマミばっかりだろう。'
	DB	"Beer and sake, I'll bet."
	DW	0000H

M3:		;見る　今日子
;	DB	'両脇に酒瓶を抱えてる。'
	DB	"She's holding one large bottle of sake in each hand."
	DW	0000H

M4:		;話す　亜希
;	DB	'【亜希】：あたし、先輩の家で忘年会があるって今日子先生に聞いたんだけど。'
	DB	"Aki:  I heard about the Year End Party from Sensei..."
	DB	NEXT
;	DB	'【%001】：・・・ま、いいけどさ。'
	DB	"%001:  ......I see."
	EF_SET 102
	DW	0000H

M5:		;話す　今日子先生
;	DB	'【%001】：先生・・・どこの世界に酒持参で家庭訪問に来る教師がいるんですか。'
	DB	"%001:  Sensei, I've never heard of a professor who"
	DB	CR
	DB	"brings sake when visiting her student's house!"
	DB	NEXT
;	DB	'【今日子】：まぁまぁ、堅いことは言いっこなし！'
	DB	"Kyoko:  Don't be like that!"
	DB	NEXT
;	DB	'【伸幸】：そうだぞぉ%001、もっと柔軟な頭を持たんとロクな大人になれないぞぉ。'
	DB	"Nobuyuki:  She's right, %001! You have to be flexible in"
	DB	CR
	DB	"life!"
	DB	NEXT
;	DB	'【%001】：ほほぉ・・・'
	DB	"%001:  ................................."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M6:		;話す　今日子先生
;	DB	'【今日子】：さ、今日は一年間の反省を込めて、ぱ～っとやりましょ、ぱ～っと！'
	DB	"Kyoko:  Let's reflect on the year we've just finished,"
	DB	CR
	DB	"and enjoy ourselves!"
	EF_SET 101
	DW	0000H

M7:		;乾杯！
;	DB	'【%001】：とりあえず、乾杯！'
	DB	"%001:  Well, everyone, kampai!"
	DB	NEXT
;	DB	'【誠】：おい、去年の反省はどーしたんだよ。'
	DB	"Makoto:  Wait a minute! What about reflecting on the past"
	DB	CR
	DB	"year?"
	DB	NEXT
;	DB	'【亜希】：やりなおしよ、先輩！'
	DB	"Aki:  Opps, he forgot."
	DW	0000H

M8:		;誠に振る１
;	DB	'【%001】：悪ィ、誠、頼む！'
	DB	"%001:  I'm sorry. Makoto, will you do the kampai for me?"
	DB	NEXT
;	DB	'【誠】：何言ってんだよ、先生はお前をご指名なんだぞ。'
	DB	"Makoto:  Sensei told you to do it!"
	DB	FLG,F_COPYI,6,1
	DW	0000H

M9:		;誠に振る２
;	DB	'【%001】：俺、こーゆーの苦手なんだよ。お前の方が慣れてるだろ？'
	DB	"%001:  I'm not very good at talking in front of everyone"
	DB	CR
	DB	"like this. You should do it."
	DB	NEXT
;	DB	'【誠】：・・・ったく、しょーがねぇな。'
	DB	"Makoto:  ..........Okay."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT14','F','K',0,1
;	DB	'誠は紙コップを持って立ち上がった。'
	DB	"I gave him a paper cup full of sake."
	DB	NEXT
;	DB	'【誠】：え～、口下手の%001に変わって、同じく宴会委員であるワタクシが音頭を取らせていただきます。'
	DB	"Makoto:  Since %001 is such a wimp, I have been asked to"
	DB	CR
	DB	"lead the kampai in his place."
	DB	NEXT
;	DB	'【誠】：それにつけても、我が１－Ａの、いや我が校のヒーローである%001君の活躍は目覚ましいものでありました。'
	DB	"Makoto:  I'd like to say thank you to %001 for being our"
	DB	CR
	DB	"class-- no, our whole school's hero this past year."
	DB	NEXT
;	DB	'【%001】：ま、誠・・・'
	DB	"%001:  M- Makoto..."
	DB	NEXT
;	DB	'【誠】：人命救助や体育祭の個人総合優勝などもさることながら、「英雄色を好む」とでも申しましょうか、数多の美少女達を虜にしたニクいヤツです。'
	DB	"Makoto:  Not just saving lives and doing well at sports..."
	DB	CR
	DB	"%001 has also excelled at making all the women in"
	DB	CR
	DB	"our school fall in love with him."
	DB	NEXT
;	DB	'【%001】：おいおいおい！'
	DB	"%001:  Hey!"
	DB	NEXT
;	DB	'【誠】：本日この席にお集まりの皆様も、きっと聞いてみたいことでしょう。%001さん、どの娘が一番好きなんですか？'
	DB	"Makoto:  And so, for everyone's benefit, I will ask you"
	DB	CR
	DB	"now. %001, which of these lovely ladies are you in love "
	DB	CR
	DB	"with?"
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ................."
	DB	NEXT
;	DB	'オレをジッと見つめる視線、視線、視線。'
	DB	"Suddenly everyone was looking at me."
	DB	NEXT
;	DB	'【誠】：さ、答えて下さい%001さん。どの子なんですか？'
	DB	"Makoto:  Please answer the question, %001. Which is it?"
	DB	NEXT
;	DB	'【伸幸】：うむ、一年間の締めだ、はっきり言いなさい%001。'
	DB	"Nobuyuki:  It's the end of the year, a good time for"
	DB	CR
	DB	"setting things straight. Tell us, %001."
	DB	NEXT
;	DB	'【今日子】：この場にいない娘かなぁ？それとも・・・',PAUSE,'ここにいる娘？'
	DB	"Kyoko:  One of these women? Or...someone not here today?"
	DB	NEXT
;	DB	'【鈴子】：・・・。'
	DB	"Reiko:  ................."
	DB	NEXT
;	DB	'【清美】：・・・。'
	DB	"Kiyomi:  ................."
	DB	NEXT
;	DB	'【美緒】：・・・。'
	DB	"Mio:  ................."
	DB	NEXT
;	DB	'【亜希】：・・・。'
	DB	"Aki:  ................."
	DB	NEXT
;	DB	'【%001】：おっ・・・俺は・・・'
	DB	"%001:  ..............I..."
	DB	NEXT
;	DB	'（・・・急にそんな事言われたって・・・）'
	DB	"What do I say?"
	DB	NEXT
;	DB	'【鈴子】：・・・。'
	DB	"Reiko:  ................."
	DB	NEXT
;	DB	'【清美】：・・・。'
	DB	"Kiyomi:  ................."
	DB	NEXT
;	DB	'【美緒】：・・・。'
	DB	"Mio:  ................."
	DB	NEXT
;	DB	'【亜希】：・・・。'
	DB	"Aki:  ................."
	DB	NEXT
;	DB	'【今日子】：さあ・・・誰なの？'
	DB	"Kyoko:  Who is it?"
	DB	NEXT
;	DB	'【%001】：おっ・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'（！）'
	DB	"!!"
	DB	NEXT
;	DB	'俺はテーブルの上のブランデーに目を止めた。'
	DB	"I looked at the bottle of brandy on the table."
	DB	NEXT
;	DB	'（これしかない！）'
	DB	".....This is the only way!"
	DB	NEXT
;	DB	'俺はやおらブランデーの瓶をひっつかみ封を開けると、一気にあおった。'
	DB	"I took the glass and opened the lid. I started to drink..."
	DB	NEXT
;	DB	'ごっくんごっくんごっくんごっくんごっくんごっくんごっくん'
	DB	"*glug glug glug glug glug glug*"
	DB	NEXT
;	DB	'【%001】：ぶはっ・・・'
	DB	"%001:  Ah...."
	DB	NEXT
	B_O B_GURU3
;	DB	'ばたーん'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'俺はぶっ倒れた。'
	DB	"I fell backwards, unconscious."
	DB	NEXT
;	DB	'・・・・・・・・・・・・'
	DB	"..............................."
	DB	NEXT
;	DB	'【鈴子】：%001君！'
	DB	"Reiko:  %001!"
	DB	NEXT
;	DB	'【清美】：%001さん！'
	DB	"Kiyomi:  %001!!"
	DB	NEXT
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  Oh my god! %001!"
	DB	NEXT
;	DB	'【亜希】：いやぁ、死なないで！'
	DB	"Aki:  No, don't die!"
	DB	NEXT
;	DB	'【今日子】：ちっ・・・逃げたか。'
	DB	"Kyoko:  Damn! He got out of that one."
	DB	NEXT
;	DB	'【誠】：ちょっとやり過ぎたかな？'
	DB	"Makoto: Is he dead?"
	DB	NEXT
;	DB	'【伸幸】：な～に、すぐ復活するって。さぁ、気を取り直して乾杯しよう。'
	DB	"Nobuyuki:  He'll be fine. Just give him  a little while."
	DB	CR
	DB	"Well, shall we do that kampai now?"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	"....................................."
	DB	NEXT
;	DB	'【%001】：う・・・う～ん・・・'
	DB	"%001:  ........Ummmm."
	DB	NEXT
;	DB	'【今日子】：あっ、起きたわね。ハイ、お目覚めの一杯。'
	DB	"Kyoko:  He's awake. Let's do the kampai!"
	DB	NEXT
;	DB	'俺が目を覚ました時には、既に宴たけなわだった。'
	DB	"By the time I woke up, they were all well into the party."
	DB	NEXT
	DB SINARIO,'CSA03.OVL',0
	DW	0000H

M10:		;一言語る
;	DB	'【%001】：それじゃ・・・一言だけ。'
	DB	"%001:  Well..."
	DB	NEXT
;	DB	'【%001】：今年も色々物騒な事件があったけど、俺達や周りの人達が巻き込まれなくて良かったと思う。'
	DB	"%001:  A lot happened to us all this year, and I made a lot"
	DB	CR
	DB	"of good friends."
	DB	NEXT
;	DB	'【%001】：来年もまたこのメンバーで集まれたらいいなって、'
	DB	"%001:  I hope we can all be doing this at the same time next"
	DB	CR
	DB	"year."
	DB	NEXT
;	DB	'【鈴子】：・・・。'
	DB	"Reiko:  ............................"
	DB	NEXT
;	DB	'（あ、そっか、鈴子さんは卒業したら、本鮪大学に・・・）'
	DB	"Oh, I forgot...Reiko's graduating, and going off to college..."
	DB	NEXT
;	DB	'【%001】：あ、鈴子さんもお正月くらいはこっちに帰ってこれるよね？'
	DB	"%001:  Reiko, you come, too. You can, can't you?"
	DB	NEXT
;	DB	'【鈴子】：ええ・・・きっと。'
	DB	"Reiko:  Yes.....I can."
	DB	NEXT
;	DB	'【%001】：うんうん、だから来年も・・・そう言えば、今日は中野と吉田がいねえな。'
	DB	"%001:  So anyway, next year...  Wait a minute, Meimi and Seia"
	DB	CR
	DB	"aren't here today."
	DB	NEXT
;	DB	'【清美】：恵依美さんと星愛さんでしたら、スキー合宿に行くとおっしゃってましたわ。'
	DB	"Kiyomi:  They went skiing, remember?"
	DB	NEXT
;	DB	'【%001】：へぇ～。'
	DB	"%001:  Oh."
	DB	NEXT
;	DB	'【%001】：・・・とにかく、健康に気を付けたらいいと思う。',PAUSE,'・・・先生、来年は少しお酒控えた方がいいよ。'
	DB	"%001:  Anyway, as we start the new year, I hope you will"
	DB	CR
	DB	"all watch your health. ",PAUSE,"And sensei, please try to drink"
	DB	CR
	DB	"a little less next year."
	DB	NEXT
;	DB	'【今日子】：へいへい。'
	DB	"Kyoko:  Hey!"
	DB	NEXT
;	DB	'【%001】：それじゃ、今日もほどほどに・・・乾杯！'
	DB	"%001:  That's all I have to say, so... Kampai!"
	DB	NEXT
;	DB	'「かんぱ～い！」'
	DB	"All:  KAMPAI!!"
	DB	NEXT
	DB	"We all touched our glasses together."
	DB	NEXT
	DB SINARIO,'CSA03.OVL',0
	DW	0000H

M_EXIT:
	DB	NEXT
;	DB	'【今日子】：さ、取り合えず始めましょ。みんな、コップ持って。'
	DB	"Kyoko:  Let's drink. Everyone hold your cups out."
	DB	NEXT
;	DB	'ジュースかビールの入った紙コップが全員に行き渡ると、',CR,'先生はすっくと立ち上がった。'
	DB	"Cups were filled with juice or beer. Then Kyoko-sensei"
	DB	CR
	DB	"stood up."
	DB	NEXT
;	DB	'【今日子】：え～、今年もまぁいろいろありましたねぇ。',CR,'みんなにとっても、忘れられない一年になったんじゃないかしら。'
	DB	"Kyoko:  Well, a lot happened this year. I'm sure you will"
	DB	CR
	DB	"all never forgot any of it."
	DB	NEXT
;	DB	'【鈴子】：そうね・・・。'
	DB	"Reiko:  That's right."
	DB	NEXT
;	DB	'【清美】：そうですわね・・・。'
	DB	"Kiyomi:  Yes, indeed."
	DB	NEXT
;	DB	'【美緒】：うん・・・。'
	DB	"Mio:  Uh-huh."
	DB	NEXT
;	DB	'【亜希】：あたしは、とうとう美緒に勝てなかったのが心残りかな。'
	DB	"Aki:  I'm just sorry I couldn't beat Mio at tennis!"
	DB	NEXT
;	DB	'【亜希】：でも、高校生になるまでの残り３ヶ月の内に、',CR,'必ずあんたを負かしてやるから！'
	DB	"Aki:  But I won't give up!"
	DB	NEXT
;	DB	'【美緒】：亜希ちゃん・・・あたし、負けないよ！'
	DB	"Mio:  We'll see!"
	DB	NEXT
;	DB	'【今日子】：ハイハイそこエキサイトしないよーに。'
	DB	"Kyoko:  Don't get started, now..."
	DB	NEXT
;	DB	'【今日子】：それじゃ、宴会委員の%001君に、今年を振り返って一言言ってもらいましょうか。'
	DB	"Kyoko:  Anyway, I'd like to ask %001 to talk about the"
	DB	CR
	DB	"past year for us."
	DB	NEXT
;	DB	'【%001】：え、俺？'
	DB	"%001:  Me?"
	DB	NEXT
;	DB	'【伸幸】：%001～、しっかりやれよぉ！'
	DB	"Nobuyuki:  Do a good job, son!"
	DB	NEXT
;	DB	'【%001】：こんなのまで一々ビデオに録るなよ・・・。'
	DB	"%001:  ...........Dad! Don't get out the video camera!"
	DB	NEXT
;	DB	'【%001】：それじゃ・・・'
	DB	"%001:  Anyway..."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_OFF,3
	DB C_BLD,C_V_OFF,4
	DB C_BLD,C_V_OFF,5
	DW	0000H


end
