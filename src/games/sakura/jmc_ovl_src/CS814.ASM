;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１４
;		今日子の特別授業１

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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN1,NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'今日子',0
NN1:	DB	1,	'KYOKO',0
;NN2:	DB	2,	'誰が好きか',0
NN2:	DB	2,	'MY TRUE LOVE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　今日子
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18		;話す　今日子１５
S3:		DW	VV3, NN1,  3, M19, M20		;考える　今日子
S4:		DW	VV3, NN2,  4, M21		;考える　誰が好きか


;イニシャルメッセージ
M1:
	DB	BGM,32
	BAK_INIT "AB_02_2"
	DB	BUF,B_COPY01
;	DB	'【%001】：・・・・・・ふう。やっと片付いた。'
	DB	"%001:  Well, everything is finally cleaned up."
	DB	NEXT
	T_CG "CT12","C",0,0,1
;	DB	'【今日子】：はいはいゴクローサン。'
	DB	"Kyoko:  Thanks, everyone."
	DB	NEXT
;	DB	'【%001】：・・・誰のせいだと思ってんですか。こんなに散らかったの。'
	DB	"%001:  But you're the one who made most of the mess, Sensei!"
	DB	PAUSE,CR
;	DB	'大体自分の部屋でしょう？少しは片付けたっていいと思いますけどね？'
	DB	"This is your house right? You should be more careful."
	DB	NEXT
;	DB	'【今日子】：・・・いや～、私『おばさん』だから、そーゆー重労働はきつくってね～。'
	DB	"Kyoko:  Oh, I thought I was an old lady? I shouldn't be"
	DB	CR
	DB	"doing hard work like that."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ....................."
	DB	NEXT
;	DB	'あの後・・・・・・'
	DB	"After that..."
	DB	NEXT
;	DB	'危ういところで今日子先生と吉田を取り押さえた俺達は、取り合えずお開きにする事にした。'
	DB	"Kyoko-sensei and Meimi ganged up on the rest of us and made"
	DB	CR
	DB	"us help clean up Kyoko's house."
	DB	NEXT
;	DB	'何となく気がそがれた、って事もあるが・・・何よりもう時間も遅かった。'
	DB	"It was late, and everyone needed to get home."
	DB	NEXT
;	DB	'・・・と言う訳で、鈴子さん達は帰って行った。'
	DB	"Anyway, after that, all the women left."
	DB	PAUSE
;	DB	'俺だけ残して。'
	DB	" Leaving me alone."
	DB	NEXT
;	DB	'・・・・・・正確には、今日子先生に残らされた。'
	DB	".........Well, what I mean is, leaving me and Kyoko-"
	DB	CR
	DB	"sensei...",PAUSE,"alone."
;	DB	PAUSE
;	DB	'理由は・・・言わなくても分かるだろう。'
;	DB	"I knew what her reason was."
	DB	C_BLD,C_N_ON,3,2		;「考える　誰が好きか」　消す
	DW	0000H

M2:		;見る　今日子
;	DB	'ソファに座って俺が片付ける様子を見ている。'
	DB	"She's sitting on the sofa, watching me clean up."
	DB	NEXT
;	DB	'・・・見てないで少しは手伝って欲しい・・・'
	DB	".................I wish she'd help me."
	DW	0000H

M3:		;見る　今日子
;	DB	'今日子先生・・・いつになく真剣だ・・・'
	DB	"She looks very serious all of the sudden."
	DW	0000H

M4:		;話す　今日子１
;	DB	'【%001】：・・・さてと。俺もそろそろ帰ります。'
	DB	"%001:  Okay, well, I guess I'll be going on home now, too."
	DB	NEXT
;	DB	'【今日子】：あら、帰るの？'
	DB	"Kyoko:  You're going home?"
	DB	NEXT
;	DB	'【%001】：ええ。別に、用無いでしょ？'
	DB	"%001:  Yes. Is that alright?"
	DB	NEXT
;	DB	'【今日子】：でも、電車もう無いわよ。'
	DB	"Kyoko:  The trains have all stopped for the night, %001."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........................."
	DB	PAUSE
;	DB	'マジ？'
	DB	"Are you kidding?"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　今日子２
;	DB	'【今日子】：・・・え～っと、２分ほど前に終わったわね。最終。'
	DB	"Kyoko:  Yes, the last one departed a few minutes ago."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..................."
	DB	PAUSE
;	DB	'な、何で教えてくれなかったんですかっ！？'
	DB	"Why didn't you tell me?"
	DB	NEXT
;	DB	'【今日子】：あら～、%001君片付けしないで帰るつもりだったの？'
	DB	"Kyoko:  I didn't want you to leave without helping clean"
	DB	CR
	DB	"up."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................................."
	DB	NEXT
;	DB	'【今日子】：・・・ま、そーゆー訳だから。今日は泊まって行きなさい。'
	DB	"Kyoko:  You'd better stay here tonight."
	DB	PAUSE
;	DB	'お家の方には、さっき電話しといたから。'
	DB	" I just got off the"
	DB	CR
	DB	"phone with your parents. I told them where you'd be tonight."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　今日子３
;	DB	'【今日子】：さ',PAUSE,'・て',PAUSE,'・と。'
	DB	"Kyoko:  We're going to drink all the way until morning,"
	DB	CR
	DB	"%001!"
	DB	NEXT
;	DB	'【%001】：・・・・・・あうぅうぅぅぅ・・・・・・'
	DB	"%001:  ......................."
	DB	PAUSE
;	DB	'やっぱりそーなんの？'
	DB	"We are? "
	DB	NEXT
;	DB	'【今日子】：・・・'
	DB	"Kyoko:  ..................."
	DB	PAUSE
;	DB	'と、言いたいとこだけどぉ・・・'
	DB	"No, we're not."
	DB	NEXT
;	DB	'【%001】：・・・え？'
	DB	"%001:  ......Huh?"
	DB	NEXT
;	DB	'【今日子】：今回はちょ～っち、お酒抜きで話したい事があんのよね。'
	DB	"Kyoko:  .....Instead, there's something I want to ask you"
	DB	CR
	DB	"tonight. It has nothing to do with drinking."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・'
	DB	"%001:  ..............................."
	DB	NEXT
;	DB	'【%001】：せ、先生！？大丈夫ですかっ！？'
	DB	"%001:  Sensei, are you okay?!"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M7:		;話す　今日子４
;	DB	'【今日子】：・・・あ～に～よ～？そのリアクションわぁ～？'
	DB	"Kyoko:  Why do you ask?"
	DB	NEXT
;	DB	'【%001】：・・・だ、だって・・・先生が『お酒抜き』だなんて・・・'
	DB	"%001:  I mean, you said 'that has nothing to do with"
	DB	CR
	DB	"drinking.' That's not like you."
	DB	NEXT
;	DB	'【今日子】：私だって、年がら年中酒飲んでる訳じゃないわよ。'
	DB	"Kyoko:  I don't drink that much, you know!"
	DB	NEXT
;	DB	'【%001】：・・・ほ、ホントですかっ！？'
	DB	"%001:  .............Really?"
	DB	NEXT
;	DB	'【今日子】：・・・・・・・・・'
	DB	"Kyoko:  .................................."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M8:		;話す　今日子５
;	DB	'【今日子】：・・・とにかく！話が進まないからこの話は置いとくわよ！'
	DB	"Kyoko:  Let's change the subject."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........Yes ma'am."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M9:		;話す　今日子６
;	DB	'【%001】：それで・・・・・・話って、何です？'
	DB	"%001:  So, what did you want to talk with me about?"
	DB	NEXT
;	DB	'【今日子】：・・・・・・・・・'
	DB	"Kyoko:  ................................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................................."
	DB	NEXT
;	DB	'【今日子】：・・・・・・・・・'
	DB	"Kyoko:  ................................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................................."
	DB	NEXT
;	DB	'【今日子】：・・・・・・・・・'
	DB	"Kyoko:  ................................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	DB	PAUSE
;	DB	'あの・・・先生？'
	DB	"Um, Sensei?"
	DB	NEXT
;	DB	'【今日子】：君は・・・・・・'
	DB	"Kyoko:  I want to ask you..."
	DB	PAUSE
;	DB	'誰が好きなのかな？'
	DB	"which of those women you're in"
	DB	CR
	DB	"love with."
	DB	FLG,F_COPYI,2,6
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,3,1
	DW	0000H

M10:		;話す　今日子７
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............."
	DB	PAUSE
;	DB	'はい？'
	DB	"Mm?"
	DB	NEXT
;	DB	'【今日子】：ダメよ、トボけちゃ。'
	DB	"Kyoko:  Don't play dumb with me."
	DB	NEXT
;	DB	'【今日子】：鈴子ちゃん、清美ちゃん、美緒ちゃん。'
	DB	"Kyoko:  Is it Reiko? Kiyomi? Mio?"
	DB	NEXT
;	DB	'【今日子】：みんな、とってもいい娘よ。'
	DB	"Kyoko:  They're all wonderful women."
	DB	NEXT
;	DB	'【今日子】：・・・そして・・・'
	DB	"Kyoko:  And they all love you, %001."
	DB	NEXT
;	DB	'【%001】：・・・！'
	DB	"%001:  ..........!!"
	DB	NEXT
;	DB	'【今日子】：全然気が付かなかった、とは言わせないわよ。'
	DB	"Kyoko:  Don't pretend that you haven't noticed."
	DB	PAUSE
;	DB	'いくらなんでも、少しくらいは分かってたんでしょ？'
	DB	" You know"
	DB	CR
	DB	"it, don't you? Deep down inside you."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..........................."
	DB	PAUSE
;	DB	'うん・・・・・・'
	DB	"Yeah, I guess."
	DB	FLG,F_COPYI,2,7
	DW	0000H

M11:		;話す　今日子８
;	DB	'【%001】：確かに・・・誠とかとは接し方が違うな、ってのは分かってた。'
	DB	"%001:  I knew that they treat me differently from Makoto,"
	DB	CR
	DB	"certainly."
	DB	NEXT
;	DB	'【%001】：・・・だけど・・・「好きだ」なんて・・・'
	DB	"%001:  But love? I don't know..."
	DB	NEXT
;	DB	'【今日子】：考えた事も無かった？'
	DB	"Kyoko:  Didn't you ever consider the possibility?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .................."
	DB	PAUSE
;	DB	'うん。'
	DB	"Sometimes."
	DB	FLG,F_COPYI,2,8
	DW	0000H

M12:		;話す　今日子９
;	DB	'【%001】：・・・でも、どうして俺なんか・・・？'
	DB	"%001:  But why me?"
	DB	NEXT
;	DB	'【今日子】：さあ・・・こればっかりは、あの娘達に聞いてみないとね。'
	DB	"Kyoko:  I'm not sure. You'd have to ask them to know for"
	DB	CR
	DB	"sure."
	DB	PAUSE
;	DB	'聞いてみる？'
	DB	" Do you want to ask them?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................................."
	DB	FLG,F_COPYI,2,9
	DW	0000H

M13:		;話す　今日子１０
;	DB	'【今日子】：ねえ、%001君・・・君は素直で優しい、とってもいい子だわ。'
	DB	"Kyoko:  %001, you're a very good man, very kind and"
	DB	CR
	DB	"honest."
	DB	PAUSE
;	DB	'でもね・・・優しさの使い方を間違っちゃダメ。'
	DB	" But you have to know how to use that kindness."
	DB	NEXT
;	DB	'【%001】：優しさの・・・使い方？'
	DB	"%001:  How to use it?"
	DB	NEXT
;	DB	'【今日子】：・・・そう。'
	DB	"Kyoko:  ........Yes."
	DB	FLG,F_COPYI,2,10
	DW	0000H

M14:		;話す　今日子１１
;	DB	'【今日子】：自分の好きな事をするだけが、幸せじゃないわ。'
	DB	"Kyoko:  Happiness is more than being able to do what you"
	DB	CR
	DB	"want all the time."
	DB	NEXT
;	DB	'【今日子】：だから他人に好きな事をさせようとする事も、本当の優しさじゃないの。'
	DB	"Kyoko:  So when you do what others want, you're not"
	DB	CR
	DB	"really being nice to them."
	DB	PAUSE
;	DB	'わかる？'
	DB	" Do you understand what I'm saying?" ; this kind of sucks
	DB	NEXT
;	DB	'【%001】：・・・良くわかんない。'
	DB	"%001:  .........Not really."
	DB	FLG,F_COPYI,2,11
	DW	0000H

M15:		;話す　今日子１２
;	DB	'【今日子】：例えば・・・そうね、鈴子ちゃんの誕生パーティーの事を例に取りましょうか。'
	DB	"Kyoko:  For example, remember Reiko's birthday party?"
	DB	NEXT
;	DB	'【今日子】：あの娘、随分甲斐甲斐しく働いてたわよね。主役なのに。'
	DB	"Kyoko:  She worked really hard to make it fun for everyone,"
	DB	CR
	DB	"right? Even though it was her own party."
	DB	NEXT
;	DB	'【%001】：うん・・・・・・'
	DB	"%001:  .......Yes."
	DB	NEXT
;	DB	'【今日子】：鈴子ちゃんだって人間よ。'
	DB	"Kyoko:  But she's human, just like anyone else."
	DB	PAUSE
;	DB	'もっとみんなから、祝って欲しかったはず・・・'
	DB	" I'm sure she"
	DB	CR
	DB	"wanted everyone else to care more."
	DB	NEXT
;	DB	'【今日子】：でもあの娘は、自分から働いてたわ。あなたの為に・・・'
	DB	"Kyoko:  But instead, she organized everything herself. All"
	DB	CR
	DB	"for you."
	DB	PAUSE
;	DB	'どうしてだと思う？'
	DB	" Why do you think that was?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'【今日子】：あなたが好きだから・・・あなたが元気に、笑っていて欲しいから。'
	DB	"Kyoko:  Because she loves you. Because she wanted to see"
	DB	CR
	DB	"you happy at the party."
	DB	NEXT
;	DB	'【今日子】：あなたが喜ぶ事が、自分の事のように嬉しいから。'
	DB	"Kyoko:  Your happiness was more important to her than her"
	DB	CR
	DB	"own."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........................................."
	DB	NEXT
;	DB	'【今日子】：人を好きになるって・・・・・・そう言う事なのよ。'
	DB	"Kyoko:  That's what it is to be in love with someone."
	DB	FLG,F_COPYI,2,12
	DW	0000H

M16:		;話す　今日子１３
;	DB	'【%001】：・・・今日子先生・・・俺・・・'
	DB	"%001:  But Kyoko-sensei...I..."
	DB	NEXT
;	DB	'【今日子】：・・・ま、%001君が言いたい事も分かるわ。'
	DB	"Kyoko:  ...I think I know what you want to say to me."
	DB	PAUSE
;	DB	'・・・でもね。いつまでもこのままではいられないわ。分かるでしょう？'
	DB	" But it"
	DB	CR
	DB	"can't go on like this indefinitely. It's not the way the"
	DB	CR
	DB	"world works."
	DB	NEXT
	DB	"Kyoko:  The balance can't be maintained forever."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .................."
	DB	PAUSE
;	DB	'うん。'
	DB	"You're right."
	DB	FLG,F_COPYI,2,13
	DW	0000H

M17:		;話す　今日子１４
;	DB	'【今日子】：だから・・・今すぐとは言わないわ。だけど、出来るだけ'
;	DB	'早く答えを出しなさい。それが、本当の優しさ。本当の思いやり・・・'
	DB	"Kyoko:  You don't have to resolve it immediately. But it"
	DB	CR
	DB	"should be done as quickly as possible. That's what it is to"
	DB	CR
	DB	"be really kind to someone."
	DB	NEXT
;	DB	'【%001】：・・・今日子先生・・・'
	DB	"%001:  .....................Kyoko-sensei."
	DB	NEXT
;	DB	'【今日子】：でも、忘れないで。あなたに選ばれなかった娘は確かに傷つくけど、その傷の深さはあなた次第だと言う事を。'
	DB	"Kyoko:  The ones you don't choose will be hurt, of course."
	DB	CR
	DB	"But the depth of their pain is all up to you."
	DB	NEXT
;	DB	'【今日子】：あなたが真剣に考えて决めた事なら、あの娘達は立ち直る事が出来るわ。それだけは、忘れないでね。'
	DB	"Kyoko:  If you are truly kind, you'll look into your"
	DB	CR
	DB	"heart and choose the one you really love, then firmly"
	DB	CR
	DB	"deal with the others."
	DB	NEXT
;	DB	'【%001】：・・・・・・はい。'
	DB	"%001:  ........You're right."
	DB	FLG,F_COPYI,2,14
	DW	0000H

M18:		;話す　今日子１５
;	DB	'【%001】：でも俺・・・・・・どうしたらいいんだろう。'
	DB	"%001:  But I...I don't know how to do it."
	DB	PAUSE
;	DB	'理屈ではわかったよーな気がするけど・・・自信無いよ俺。'
	DB	" Logically, I think"
	DB	CR
	DB	"I know. But I'm not sure of myself."
	DB	NEXT
;	DB	'【今日子】：・・・・・・・・・'
	DB	"Kyoko:  ..........................................."
	DB	NEXT
;	DB	'【今日子】：そう・・・じゃあ教えてあげる。'
	DB	"Kyoko:  I see. Then I'll teach you."
	DB	PAUSE
;	DB	'喜ばれる事の歓びを・・・'
	DB	" I'll teach you about"
	DB	CR
	DB	"pleasure..."
	DB	PAUSE
;	DB	'そして、オンナの事を。'
	DB	"and about women."
	DB	NEXT
	DB	SINARIO,'CS815.OVL',0
	DW	0000H

M19:		;考える　今日子
;	DB	'・・・それにしても、自分の生徒に酒飲まして、挙げ句に部屋の掃除までさせるなんて・・・'
	DB	"I've never heard of a professor who gave beer to her"
	DB	CR
	DB	"students, then forced them to clean their room."
	DB	NEXT
;	DB	'・・・まあ、とんでもねーのは昨日今日に始まったことじゃねーか・・・'
	DB	"Oh, it's not like it's anything new."
	DB	C_BLD,C_N_ON,3,1		;「考える　今日子」　消す
	DB	C_BLD,C_N_OFF,3,2		;「考える　誰が好きか」　出す
	DW	0000H

M20:		;考える　今日子
;	DB	'今日子先生・・・いつになく真剣だ・・・'
	DB	"Kyoko-sensei is so serious all of the sudden."
	DW	0000H

M21:		;考える　誰が好きか
;	DB	'そんな・・・どの子が好きか・・・って・・・'
	DB	"She wants me to tell her who I'm in love with?"
	DB	NEXT
;	DB	'・・・考えたこともなかったのに・・・答えようがねーよ。'
	DB	"How could I do that when I don't even know myself."
	DW	0000H


end