;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６１５＿Ｇ
;		浜辺の星愛

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'正直に言う',0
VV3:	DB	3,	"TELL THE TRUTH",0
;VV4:	DB	4,	'とぼける',0
VV4:	DB	4,	"PLAY DUMB",0

;NN1:	DB	1,	'星愛',0
NN1:	DB	1,	"SEIA",0
;NN2:	DB	2,	'海',0
NN2:	DB	2,	"OCEAN",0
;NN3:	DB	3,	'月',0
NN3:	DB	3,	"MOON",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　星愛
S2:		DW	VV1, NN2,  2, M3, M4		;見る　海２
S3:		DW	VV1, NN3,  3, M5		;見る　月１
S4:		DW	VV2, NN1,  4, M6, M7, M8, M9, M10, M11, M13, M14, M15, M16, M17, M18, M19, M20, M21, M22, M23, M24		;話す　星愛１８	
S5:		DW	VV3, -1,  5, M12		;正直に言う				☆正解コース
S6:		DW	VV4, -1,  6, M25		;トボける				☆失敗コース


;イニシャルメッセージ
M1:
	DB	BGM,9
	BAK_INIT "AB_17_3"
	DB	BUF,B_COPY01
	T_CG "CT07","F",0,15,1
;	DB	'【%001】：・・・よ、何やってんだい？'
	DB	"%001:  Yo, what are you up to?"
	DB	NEXT
;	DB	'【星愛】：きゃうっ！？'
	DB	"Seia:  Kyaa!!"
	DB	PAUSE
;	DB	'・・・・・・%001君？'
	DB	" .....%001?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yeah."
	DB	NEXT
;	DB	'【星愛】：・・・もう、おどかさないで下さい。'
	DB	"Seia:  Please don't do that again!"
	DB	NEXT
;	DB	'【%001】：わりわり。'
	DB	"%001:  Sorry, sorry."
	DB G_FLG,G_COPYI,174,1
	DB G_FLG,G_COPYF,170,170
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DW	0000H

M2:		;見る　星愛
;	DB	'いつも落ち着き払っているけど、月明かりの下で見ると・・・'
	DB	"She always projects serenity, but when I look at her under"
	DB	CR
	DB	"the moonlight..."
	DB	NEXT
;	DB	'・・・何だか、すごく大人びて見える。童顔なのに。'
	DB	"She looks really grown-up. Even with that baby face."
	DW	0000H

M3:		;見る　海１
;	DB	'夜の海は・・・引き込まれそうな感じがして物凄く恐い。'
	DB	"The ocean at night...so cold and scary. It looks like"
	DB	CR
	DB	"it could suck me in."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".........................."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;見る　海２
;	DB	'泳げない俺にとっては、恐怖以外の何者でもない。'
	DB	"Well, since I can't swim, it only makes sense that I'm"
	DB	CR
	DB	"afraid."
	DB	FLG,F_COPYI,2,0
	DW	0000H

M5:		;見る　月１
;	DB	'煌々と、あくまで美しく辺りを照らしている。'
	DB	"The beach was brilliant, beautiful in the soft light."
	DB	NEXT
;	DB	'やっぱり、海より月だよな。'
	DB	"Yeah, the moon sure beats the ocean."
	DW	0000H

M6:		;話す　星愛１
;	DB	'【%001】：で？何やってんだ１人で？'
	DB	"%001:  What are you doing there all by yourself?"
	DB	NEXT
;	DB	'【星愛】：わたくしは・・・'
	DB	"Seia:  I..."
	DB	PAUSE
;	DB	'少し、夜風に当たりたくなりまして。'
	DB	" I just wanted to feel the evening air."
	DB	NEXT
;	DB	'%001君は？'
	DB	"Seia:  And you, %001?"
	DB	NEXT
;	DB	'【%001】：俺？'
	DB	"%001:  Me?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  I was just restless."
	DB	NEXT
;	DB	'【%001】：さあ？'
;	DB	"%001:  Oh, nothing."
;	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  .........."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M7:		;話す　星愛２
;	DB	'【%001】：・・・あぁそ～だそ～だ。俺、吉田に聞きたい事があったんだ。'
	DB	"%001:  By the way, I wanted to ask you something."
	DB	NEXT
;	DB	'【星愛】：・・・わたくしに？'
	DB	"Seia:  Me?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yeah."
	DB	PAUSE
;	DB	'・・・吉田さ、昼間鈴子さんに泳ぎ教わってただろ？'
	DB	" Reiko taught you how to swim today, right?"
	DB	NEXT
;	DB	'【星愛】：ええ。'
	DB	"Seia:  Yes."
	DB	PAUSE
;	DB	'沢村先輩、とっても教え方が上手ですのよ。'
	DB	" Reiko is a really good teacher."
	DB	NEXT
;	DB	'【%001】：・・・て事は、やっぱし・・・？'
	DB	"%001:  ...So, did you learn how to swim?"
	DB	NEXT
;	DB	'【星愛】：ええ、何とか・・・・・・'
	DB	"Seia:  Well, yes...."
	DB	PAUSE
;	DB	'流石に何メートルもは、無理ですけど。'
	DB	" But I can still only go so far."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................"
	DB	PAUSE
;	DB	'あ、そ。'
	DB	"Oh, I see."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M8:		;話す　星愛３
;	DB	'【%001】：・・・ああ、み～んな泳げるようになって行く・・・'
	DB	"%001:  I feel left out. Everyone can swim but me."
	DB	NEXT
;	DB	'【星愛】：・・・はいはい、泣かない泣かない。'
	DB	"Seia:  There, there, don't cry."
	DB	NEXT
;	DB	'【%001】：・・・・・・もしかして、すっげ～バカにしてない？'
	DB	"%001:  You're not making fun of me, are you?"
	DB	NEXT
;	DB	'【星愛】：そんな事はありませんわ。'
	DB	"Seia:  No, of course not."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M9:		;話す　星愛４
;	DB	'【星愛】：・・・・・・'
	DB	"Seia:  ............"
	DB	PAUSE
;	DB	'あの・・・・・・%001君。'
	DB	"%001?"
	DB	NEXT
;	DB	'【%001】：なに？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【星愛】：・・・・・・（きょろきょろ）'
	DB	"Seia:  .....(Looking around)"
	DB	NEXT
;	DB	'【%001】：？　どったの、いきなりあちこち見まわしたりして？'
	DB	"%001:  What's up? Why are you looking around like that?"
	DB	NEXT
;	DB	'【星愛】：・・・・・・'
	DB	"Seia:  ................"
	DB	PAUSE
;	DB	'あの・・・・・・'
	DB	"Um..."
	DB	PAUSE,CR
;	DB	'大変聞きにくいのですが・・・・・・'
	DB	"It's kind of difficult to ask you this, but..."
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  Yes?"
	DB	FLG,F_COPYI,4,4
	DW	0000H

M10:		;話す　星愛５
;	DB	'【%001】：何だ吉田？何か聞きたいのか？'
	DB	"%001:  What, Seia? What are you trying to ask me?"
	DB	NEXT
;	DB	'【星愛】：ええ・・・・・・'
	DB	"Seia:  .............."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  Do you remember the flower-viewing party we all"
	DB	CR
	DB	"had back in April?"
	DB	NEXT
;	DB	'【%001】：・・・花見・・・？'
	DB	"%001:  Flower-viewing party...?"
	DB	NEXT
;	DB	'【%001】：ああ、ひょっとしてあれか？吉田が酔っ払って桜と正面衝突した奴？'
	DB	"%001:  Oh, you mean when you got drunk and ran head-on"
	DB	CR
	DB	"into that cherry tree?"
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・はい・・・・・・・・・'
	DB	"Seia:  Yes..."
	DB	FLG,F_COPYI,4,5
	DW	0000H

M11:		;話す　星愛６
;	DB	'【星愛】：実はわたくし、その辺の記憶がなくって・・・・・・'
	DB	"Seia:  To tell the truth, I don't remember it at all."
	DB	PAUSE
;	DB	'その事は、後で恵依美ちゃんに聞いたのですが・・・・・・'
	DB	" I"
	DB	CR
	DB	"actually heard about what I'd done later from Meimi."
	DB	NEXT
;	DB	'【星愛】：それで・・・・・・'
	DB	"Seia:  Anyway... " 
	DB	NEXT
;	DB	'朝、目が覚めましたら・・・・・・'
	DB	"Seia:  When I woke up in the morning..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................"
	DB	NEXT
;	DB	'（・・・何が言いたいか、やっとわかった。）'
	DB	"...I think I already know what she wants to tell me."
	DB	NEXT
;	DB	'（・・・・・・・・・）'
	DB	"..............."
	DB	NEXT
;	DB	'（・・・わかったのはい～んだけど・・・なんて言えばいいんだ？'
	DB	"...Knowing is fine, but what should I say?"
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_OFF,3
	DB C_BLD,C_V_OFF,4
	DB	FLG,F_COPYI,4,6
	DW	0000H

M12:		;正直に言う					☆正解コース
;	DB	'【%001】：・・・えっと・・・'
	DB	"%001:  Well..."
	DB	NEXT
;	DB	'まず最初に言っておきたいんだけど、俺はお前を部屋に運んで布団を掛けた以外の事は何もしていない。'
	DB	"%001:  I just wanted to make sure you knew that all I did "
	DB	CR
	DB	"was carry you into the room and put a blanket over you."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ............."
	DB	NEXT
;	DB	'【%001】：・・・ホントだってば。突然起き出してパンツ一丁になるから、'
	DB	"%001:  It's true. But you got up suddenly, wearing nothing"
	DB	CR
	DB	"but a pair of underpants..."
	DB	NEXT
	K_CG "CT07","D",15,2
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  You saw, didn't you?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........"
	DB	PAUSE
;	DB	'いっ、いや！確かに、その、あの、だけど、あ、あれはだな・・・！'
	DB	"Uh, no! Well, actually, what I mean is...!"
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ................"
	DB	PAUSE
;	DB	'%001君って、見掛けによらないんですのね。'
	DB	"Well I'm sure you didn't try to see."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・あう・・・・・・・・・'
	DB	"%001:  That's right."
	DB	FLG,F_CALI,170,15
	DB G_FLG,G_COPYG,170,170
	DB C_BLD,C_V_OFF,1
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DW	0000H

M13:		;話す　星愛７					☆正解コース
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................."
	DB	NEXT
	K_CG "CT07","K",15,3
;	DB	'【星愛】：・・・・・・・・・くすっ。'
	DB	"Seia:  Well."
	DB	NEXT
;	DB	'【%001】：・・・吉田・・・？'
	DB	"%001:  Seia?"
	DB	FLG,F_COPYI,4,7
	DW	0000H

M14:		;話す　星愛８					☆正解コース
;	DB	'【星愛】：冗談ですわ。%001君が、そんな人でない事くらい知っております。'
	DB	"Seia:  It's alright. I know you're not the kind of person"
	DB	CR
	DB	"who would take advantage of a situation like that."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・はあ。'
	DB	"%001:  Yeah."
	DB	NEXT
;	DB	'【星愛】：わたくしは、本当の事が知りたかっただけですの。'
	DB	"Seia:  I just wanted to know the truth."
	DB	PAUSE
;	DB	'よく言って下さいましたわ。主も、きっとお許しになります。'
	DB	" You spoke well. I'm",CR,"sure God will forgive you too."
	DB	NEXT
;	DB	'【%001】：・・・・・・はあ。'
	DB	"%001:  Yeah."
	DB	FLG,F_COPYI,4,8
	DW	0000H

M15:		;話す　星愛９					☆正解コース
;	DB	'【%001】：・・・な～んか、噂に聞く「懺悔室」みたいだったな。'
	DB	"%001:  I feel like I'm in a confessional or something."
	DB	NEXT
	T_CG "CT07","F",0,15,1
;	DB	'【星愛】：本当の懺悔室は、すこし違いますわ。'
	DB	"Seia:  The real confessional is a little different."
	DB	NEXT
;	DB	'あくまでも、自発的に罪を告白して過ちを悔いる場所ですの。'
	DB	"Seia:  It's a place where you voluntarily confess your"
	DB	CR
	DB	"mistakes and repent your sins."
	DB	NEXT
;	DB	'【星愛】：人は誰しも、過ちを犯すものです。'
	DB	"Seia:  And everyone makes mistakes sometimes. "
	DB	PAUSE
;	DB	'大切なのは罪を恥じ、同じ過ちを繰り返さない事です。'
	DB	"The important"
	DB	CR
	DB	"thing is to feel sorry for your sins, and try not to make"
	DB	CR
	DB	"the same mistakes again."
	DB	NEXT
;	DB	'その為に、主に告白するのです・・・人は、中々自分への約束を守れないものですから・・・'
	DB	"Seia:  That's why I confess to God. Because humans, in the"
	DB	CR
	DB	"end, can't really keep promises to themselves."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'【星愛】：・・・どうなさったのですか？面白い顔をされて・・・'
	DB	"Seia:  What's wrong? You have a strange expression on your"
	DB	CR
	DB	"face..."
	DB	NEXT
;	DB	'【%001】：・・・あ、いや。そーいや吉田は、シスター志望なんだったな。'
	DB	"%001:  No, nothing. So you want to be a nun someday, Seia?"
	DB	FLG,F_COPYI,4,9
	DW	0000H

M16:		;話す　星愛１０					☆正解コース
;	DB	'【星愛】：ええ。大学を出てからにしようと思っておりますが・・・・・・'
	DB	"Seia:  Yes. I thought I would take the vows after graduating"
	DB	CR
	DB	"from college."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  Really."
	DB	PAUSE
;	DB	'そ～言えば吉田、前から聞きたかったんだけどよ・・・何でシスターになろうって思ったんだ？'
	DB	".....So, why do you want to become a nun?"
	DB	NEXT
;	DB	'【星愛】：動機ですか？'
	DB	"Seia:  Are you asking my motive?"
	DB	NEXT
;	DB	'・・・そうですわね・・・強いて言うならば、近くに教会があったからでしょうか。'
	DB	"Seia:  Well, if I had to say, probably because of the church"
	DB	CR
	DB	"near where I lived."
	DB	NEXT
;	DB	'【%001】：・・・ふ～ん。'
	DB	"%001:  Oh."
	DB	FLG,F_COPYI,4,10
	DW	0000H

M17:		;話す　星愛１１					☆正解コース
;	DB	'【星愛】：わたくしの家は、代々カトリックでして・・・わたくしも小さい頃から、毎週必ず教会に行っておりましたわ。'
	DB	"Seia:  My family has been Catholic for years. Ever since"
	DB	CR
	DB	"I was little, we all went to church every Sunday."
	DB	NEXT
;	DB	'【%001】：・・・へえ・・・熱心なんだな。'
	DB	"%001:  That's very dedicated of you."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ........................"
	DB	NEXT
;	DB	'【星愛】：実は、ここだけの話ですが・・・わたくし、最初の頃はあんまり熱心にお祈りしていませんでしたの。'
	DB	"Seia:  This is just between you and me, but at the"
	DB	CR
	DB	"beginning I didn't really mean it when I prayed."
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  Eh?"
	DB	NEXT
;	DB	'【星愛】：そこのシスターが、とっても素晴らしい方で・・・わたくし、'
	DB	"Seia:  A great sister there told me stories about how fun"
	DB	CR
	DB	"it was just to talk with the other nuns."
	DB	NEXT
;	DB	'【%001】：・・・へ～・・・'
	DB	"%001:  Really?"
	DB	FLG,F_COPYI,4,11
	DW	0000H

M18:		;話す　星愛１２					☆正解コース
;	DB	'【星愛】：本当に、素晴らしい方でした・・・マリア様のお使いのような、'
	DB	"Seia:  She was really a wonderful person, almost like"
	DB	CR
	DB	"a messenger sent by Mary, filled with love and insight into"
	DB	CR
	DB	"my spirtuality."
	DB	NEXT
;	DB	'【%001】：・・・憧れ、だったんだな。'
	DB	"%001:  You wanted to be like her, then."
	DB	NEXT
;	DB	'【星愛】：ええ・・・今はイギリスの方へ行かれてしまいましたが・・・'
	DB	"Seia:  Yes, she's gone back to England now, but I still"
	DB	CR
	DB	"remember her very well."
	DB	FLG,F_COPYI,4,12
	DW	0000H

M19:		;話す　星愛１３					☆正解コース
;	DB	'【%001】：・・・頑張れよ、吉田。俺はその人の事は知らないけど、'
	DB	"%001:  Well, hang in there, Seia. I don't know anything"
	DB	CR
	DB	"about your friend, but knowing what you really want is"
	DB	CR
	DB	"half the battle."
	DB	NEXT
;	DB	'【星愛】：はい、ありがとうございます。'
	DB	"Seia:  Yes, I think so too."
	DB	NEXT
;	DB	'・・・ところで%001君。前からお聞きしたかった事があるのですが。'
	DB	"Seia:  But %001. There's something I've been wanting to"
	DB	CR
	DB	"ask you, too."
	DB	NEXT
;	DB	'【%001】：・・・・・・なに？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【星愛】：どうしてそれほどの能力を、何にも使わないのですか？'
	DB	"Seia:  Why do you never put all those abilities of yours"
	DB	CR
	DB	"to some use?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................................"
	DB	FLG,F_COPYI,4,13
	DW	0000H

M20:		;話す　星愛１４					☆正解コース
;	DB	'【%001】：・・・使い道がないから、かな？'
	DB	"%001:  Maybe because I don't know what to do with them."
	DB	NEXT
;	DB	'【星愛】：・・・・・・と、おっしゃいますと？'
	DB	"Seia:  What do you mean by that?"
	DB	NEXT
;	DB	'【%001】：・・・やりたい事が見あたんね～んだよ。'
	DB	"%001:  I guess I haven't found anything I want to use them"
	DB	CR
	DB	"for."
	DB	NEXT
;	DB	'【星愛】：・・・少し、分かる気がしますわ。'
	DB	"Seia:  I think I know what you mean."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .........................."
	DB	PAUSE
;	DB	'え？'
	DB	"You do?"
	DB	FLG,F_COPYI,4,14
	DW	0000H

M21:		;話す　星愛１５					☆正解コース
;	DB	'【%001】：分かる気がするって・・・・・・本当？'
	DB	"%001:  Do you really understand, you're not just saying"
	DB	CR
	DB	"that?"
	DB	NEXT
;	DB	'【星愛】：ええ。'
	DB	"Seia:  Yes."
	DB	PAUSE
;	DB	'・・・昔、シスターからこんな話を聞いた事がありますわ。'
	DB	" A long time ago, I heard this story from a nun."
	DB	NEXT
;	DB	'【星愛】：昔、山のように大きな男がいたそうです。'
	DB	"Seia:  Once upon a time, there was a kind man as big as"
	DB	CR
	DB	"a mountain."
	DB	PAUSE
;	DB	'とても優しい性格をしていたのですが、近くの村人からは魔物のように恐れられていたそうです。'
	DB	" He was a very kind man, but the people in the ",CR,"village nearby feared and hated him."
	DB	NEXT
;	DB	'【%001】：・・・何で？そいつ、優しいんだろ？'
	DB	"%001:  Why? He was kind, right?"
	DB	NEXT
;	DB	'【星愛】：余りにも大きかったせいで、間違って家を踏みつぶしてしまったからだそうです。'
	DB	"Seia:  Well, because he was so big, he stepped on a house"
	DB	CR
	DB	"by mistake and crushed it."
	DB	NEXT
;	DB	'【%001】：・・・あらま。'
	DB	"%001:  Oh."
	DB	NEXT
;	DB	'【星愛】：村人に迷惑をかけたくないと思ったその男は、近くの山にこもってひっそりと暮らしていました。'
	DB	"Seia:  Because he didn't want to trouble the village"
	DB	CR
	DB	"folk, he went and lived quietly all by himself on a"
	DB	CR
	DB	"mountain nearby."
	DB	NEXT
;	DB	'【星愛】：そんなある日・・・物凄い嵐がやって来て、川が氾濫。'
	DB	"Seia:  Then one day came a terrible storm, and the river"
	DB	CR
	DB	"flooded."
	DB	PAUSE
;	DB	'村人達は、水に飲み込まれてしまいました。'
	DB	" The village folk were nearly swallowed up by the",CR,"water."
	DB	NEXT
;	DB	'【%001】：ふんふん。'
	DB	"%001:  Mmmm."
	DB	NEXT
;	DB	'【星愛】：その様子を見ていた男は、木を丸ごと引き抜いて川をせき止め、'
	DB	"Seia:  When he saw this, he ripped up trees and used"
	DB	CR
	DB	"them to dam up the river. And saved all the village folk."
	DB	NEXT
;	DB	'【星愛】：心を入れ代えた村人達は男に村に住むように言いましたが、'
	DB	"Seia:  The people, who had changed their minds about the"
	DB	CR
	DB	"man, invited him to come live in the village."

	DB	NEXT

	DB	"Seia:  But the man declined with a smile, and started heading",CR,"back toward the mountain."
	DB	NEXT
;	DB	'【星愛】：その時、小さな子供が進み出て男に言いました。'
	DB	"Seia:  Right then, a little child came forward and spoke"
	DB	CR
	DB	"to the man."
	DB	NEXT
;	DB	'『おじさん、かわをなおしてよ。』'
	DB	"Seia:  'Sir, won't you fix the river?' she said."
	DB	NEXT
;	DB	'【星愛】：男はその願いを聞き、村人達は喜んで彼を雇いました。'
	DB	"Seia:  The man agreed to do it, and the village people"
	DB	CR
	DB	"were overjoyed that he would work for them."
	DB	NEXT
;	DB	'【星愛】：・・・こうして男は村の住人として一生を終え、彼の子孫はそれを家業としました。'
	DB	"Seia:  So the man lived the rest of his life as a"
	DB	CR
	DB	"member of the village, and his children carried on the"
	DB	CR
	DB	"family trade."
	DB	NEXT
;	DB	'【星愛】：その一族の一部が、後にその技術を生かしてバイキングになったそうですが、これはちょっと後からの創作でしょうね。'
	DB	"Seia:  Apparently a part of that family perfected the "
	DB	CR
	DB	"trade and eventually became the Vikings, according to"
	DB	CR
	DB	"legend."
	DB	NEXT
;	DB	'【%001】：・・・・・・全部創作じゃないの？'
	DB	"%001:  But isn't the whole story a legend?"
	DB	FLG,F_COPYI,4,15
	DW	0000H

M22:		;話す　星愛１６					☆正解コース
;	DB	'【星愛】：そうかもしれませんわね。'
	DB	"Seia:  Probably."
	DB	PAUSE
;	DB	'・・・でも、こういうお話は事実ではなくて教訓を伝えるものだと思いますわ。'
	DB	" But I think there's a lesson to the story, ",CR,"even if it isn't true."
	DB	NEXT
;	DB	'【%001】：・・・そ～だな。'
	DB	"%001:  I guess so."
	DB	NEXT
;	DB	'【星愛】：わたくしがこのお話を思い出したのは・・・%001君が'
	DB	"Seia:  It was you who made me remember the story. You're"
	DB	CR
	DB	"a little bit like that giant."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................................"
	DB	NEXT
;	DB	'【星愛】：このお話の男も、仕事を見つけるまではただひっそりと暮らしていましたわ・・・人を傷つけたくなくて。'
	DB	"Seia:  The man in the story also just kept to himself,"
	DB	CR
	DB	"not to hurt anyone, until he finally found a job that"
	DB	CR
	DB	"he could do."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・
	DB	"%001:  ..........................."
	DB	NEXT
;	DB	'【星愛】：もし、嵐がやってこなかったら・・・この男は、どうしたんでしょうね？'
	DB	"Seia:  If that storm hadn't come, what would that man"
	DB	CR
	DB	"have done then?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................."
	DB	FLG,F_COPYI,4,16
	DW	0000H

M23:		;話す　星愛１７					☆正解コース
;	DB	'【星愛】：・・・%001君は、とても正直な方ですわ。'
	DB	"Seia:  You're a very honest person, %001."
	DB	PAUSE
;	DB	'そして、とても優しい方。'
	DB	" And a very kind"
	DB	CR
	DB	"one, too."
	DB	NEXT
;	DB	'【%001】：・・・俺は・・・'
	DB	"%001:  Me? No, I'm not, I..."
	DB	NEXT
;	DB	'【星愛】：ですが、優しくても人は傷つきます。例え、そのつもりはなくとも。'
	DB	"Seia:  But no matter how good you are, you can always hurt"
	DB	CR
	DB	"someone, even without meaning to."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................."
	DB	NEXT
;	DB	'【星愛】：傷つけずに、傷つかずに生きて行く事など出来ません。'
	DB	"Seia:  You can't possibly live without hurting and being",CR,"hurt. That's why people need to look for salvation."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................................."
	DB	FLG,F_COPYI,4,17
	DW	0000H

M24:		;話す　星愛１８					☆正解コース
;	DB	'【星愛】：・・・わたくしは、微々たる力しかありません。'
	DB	"Seia:  I don't have the power to read minds. But I'm"
	DB	CR
	DB	"pretty good at listening to others."
	DB	PAUSE
;	DB	'・・・今のように。'
	DB	" Like right now."
	DB	NEXT
;	DB	'【%001】：・・・・・・吉田・・・・・・'
	DB	"%001:  Seia..."
	DB	NEXT
;	DB	'【星愛】：もし・・・'
	DB	"Seia:  If..."
	DB	PAUSE
;	DB	'もし、%001君がよければ・・・'
	DB	"If you would like to talk to me, %001, it's",CR,"alright with me."
	DB	NEXT
;	DB	'【%001】：・・・ありがとう、吉田。'
	DB	"%001:  Thanks, Seia."
	DB	NEXT
;	DB	'【星愛】：・・・・・・いえ。'
	DB	"Seia:  Sure."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ............................"
	DB	NEXT
;	DB	'【%001】：なんか、随分話し込んじゃったな。'
	DB	"%001:  But I'm pretty talked out."
	DB	PAUSE
;	DB	'そろそろ寝よっか？'
	DB	" We should probably get"
	DB	CR
	DB	"some sleep."
	DB	NEXT
;	DB	'【星愛】：そうですわね。'
	DB	"Seia:  Alright."
	DB	NEXT
;	DB	'・・・そして俺達は、ゆっくりと宿舎へともど・・・'
	DB	"We started heading back to the lodge."
	DB	BUF,B_COPY01
	T_CG "CT13","F",0,15,3 	;校長
;;	DB	'ざばざば'
	DB	NEXT
	DB	"*SLURP*"
	DB	NEXT
	DB	"Seia:  Look!"
	DB	NEXT
;	DB	'【校長】：・・・やっと・・・帰って来られた・・・'
	DB	"Dean:  ...Finally...got back..."
	DB	NEXT
;	DB	'【鈴子】：え！？'
	DB	"Seia:  Eh?!"
	DB	NEXT
;	DB	'【%001】：こっ、校長先生！？'
	DB	"%001:  It's the dean!"
	DB	NEXT
;	DB	'夜の海から現れたのは、他でもない校長先生だった。'
	DB	"What appeared out of the dark sea was none other than"
	DB	CR
	DB	"the school dean."
	DB	NEXT
;	DB	'【校長】：ん？やあ、%001君じゃあないか。'
	DB	"Dean:  Oh, it's you, %001."
	DB	NEXT
;	DB	'【%001】：いっ、一体何をしてるんですかっ！？'
	DB	"%001:  W- What are you doing out here?!"
	DB	NEXT
;	DB	'【校長】：う～む、それがよく分からないのだよ。'
	DB	"Dean:  You know, I don't really know."
	DB	NEXT
;	DB	'【%001】：は？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【校長】：私ももう年だろーか、前後不覚になるほど酔ってしまうとは。'
	DB	"Dean:  I passed out..."
	DB	NEXT
;	DB	'【校長】：しかも、酔いが覚めてみたら知らない島にいるし・・・'
	DB	"Dean:  And then when I woke up and looked around,"
	DB	CR
	DB	"I was on this island that I've never seen."
	DB	NEXT
;	DB	'【%001】：そっ、それはまたお気の毒に・・・'
	DB	"%001:  Wow, that's really too bad..."
	DB	NEXT
;	DB	'ほ・・・本当のことを知ってるだけに・・・つらい'
	DB	"Whew... knowing the truth sure is tough..."
	DB	NEXT
;	DB	'【校長】：小林先生とお酒を飲むのはもうやめよう・・・'
	DB	"Dean:  I don't think I'll be drinking with Kyoko-"
	DB	CR
	DB	"sensei anymore..."
	DB	NEXT
;	DB	'【%001】：ぜひ、そうするべきですっ！'
	DB	"%001:  Yes, that's definitely a good idea!"
	DB	NEXT
;	DB	'【校長】：・・・？どーしたのかね、%001君。'
	DB	"Dean:  Hm? What do you mean?"
	DB	NEXT
;	DB	'【%001】：え？・・・あ～・・・その～・・・'
	DB	"%001:  Eh? Oh, ah..."
	DB	NEXT
;	DB	'いかん、ついつい本音を吐いてしまった'
	DB	"Oh no...looks like I let the cat slip out of the bag..."
	DB	NEXT
;	DB	'【校長】：・・・そうか・・・そう言うことか・・・'
	DB	"Dean:  ...I see."
	DB	NEXT
;	DB	'げっ、校長先生、今日子先生の企みに気付いた！？'
	DB	"Has the dean figured out Kyoko-sensei's plot?!"
	DB	NEXT
;	DB	'バカバカ俺のバカ！今日子先生が校長先生に怒られるのは構わないけど、その後に真っ先にとばっちりを食うのは俺じゃないか！'
	DB	"I am such an idiot! I mean, it doesn't matter if the"
	DB	CR
	DB	"dean gets mad at Kyoko-sensei, but I'm sure I'll be"
	DB	CR
	DB	"the one who will really have to pay!"
	DB	NEXT
;	DB	'【校長】：%001君は、１－Ａだったね。'
	DB	"Dean:  %001, you're in 1-A, right?"
	DB	NEXT
;	DB	'【%001】：は、はい。'
	DB	"%001:  Y-Yes."
	DB	NEXT
;	DB	'【校長】：・・・君は、今日子先生の「恐ろしさ」が、骨身に染みて分かっているんだねえ。'
	DB	"Dean:  So I'm sure you're very familiar with how scary"
	DB	CR
	DB	"Kyoko-sensei can be."
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【校長】：いやいや、隠す必要はない。'
	DB	"Dean:  It's okay, you don't need to hide it."
	DB	NEXT
;	DB	'【校長】：どうだね、同じ苦しみを味わった者同士だ。%001君も、私が直接指揮を取る『ヒーローアクション部』に入部してみないかね？'
	DB	"Dean:  It's all right, I'm sure you have suffered at"
	DB	CR
	DB	"her hands too. %001, why don't you join the 'Action Hero"
	DB	CR
	DB	"Club'? I'm in charge of the club, you know."
	DB	NEXT
;	DB	'【%001】：え？あの・・・'
	DB	"%001:  Huh? But I..."
	DB	NEXT
;	DB	'【校長】：いや、返事は急がんでよろしい。そろそろ夜も遅いし、ここらで帰るとしようか。'
	DB	"Dean:  You don't have to answer right away. It's"
	DB	CR
	DB	"getting late. I guess I'll head on back."
	DB	NEXT
;	DB	'【%001】：はあ・・・'
	DB	"%001:  Okay."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Seia:  ............................."
	DB	NEXT
;	DB	'【校長】：では、%001君、そして鈴子君ごきげんよう！'
	DB	"Dean:  Well, %001, Seia, take care!"
	DB	PAUSE
;	DB	'%001君、いい返事を期待しているぞ！わははははははははははははは！'
	DB	" %001, I'll be"
	DB	CR
	DB	"expecting your answer! Hahahahaha!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"........................................."
	DB	NEXT
;	DB	'・・・こ・・・こうして・・・'
	DB	"Well, uh..."
	DB	NEXT
;	DB	'最後の最後で淒すぎるインパクトを俺の脳裏に焼き付けて、臨海学校は終わった・・・・・・'
	DB	"And so seaside camp ended, with this truly bizarre encounter"
	DB	CR
	DB	"forever imprinted on my mind."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS701.OVL',0
	DW	0000H

M25:		;トボける					☆失敗コース
;	DB	'【%001】：もしかしてさ・・・俺が戻った後、なんかあったの？'
	DB	"%001:  Did...did something happen after I went back to"
	DB	CR
	DB	"the others?"
	DB	NEXT
;	DB	'【星愛】：・・・え？'
	DB	"Seia:  Huh?"
	DB	NEXT
;	DB	'【%001】：俺、吉田をベッドに寝かせた後、すぐに会場に戻ったからさ。'
	DB	"%001:  Well, after I put you down on the bed, I went"
	DB	CR
	DB	"back to where the party was."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  .............."
	DB	PAUSE
;	DB	'そうですか・・・・・・・・・'
	DB	"I see."
	DB	NEXT
;	DB	'【%001】：なあ、何かあったん？'
	DB	"%001:  Did anything happen?"
	DB	NEXT
;	DB	'【星愛】：あ！'
	DB	"Seia:  Oh!"
	DB	PAUSE
;	DB	'い、いえ・・・・・・なんでもありませんわ。'
	DB	" N-No, nothing. Nevermind."
	DB	NEXT
;	DB	'【%001】：そか。'
	DB	"%001:  Oh."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  .................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	DB	NEXT
;	DB	'【星愛】：あの・・・わたくし、そろそろお休みさせて頂きたいのですが。'
	DB	"Seia:  Well, I suppose I'll be getting off to bed then."
	DB	NEXT
;	DB	'【%001】：そか。'
	DB	"%001:  Okay."
	DB	PAUSE
;	DB	'じゃあ俺も寝るかな。'
	DB	" I guess I will too."
	DB	NEXT
;	DB	'【星愛】：・・・では、おやすみなさい。'
	DB	"Seia:  Well, good night."
	DB	NEXT
;	DB	'【%001】：ああ、お休み。'
	DB	"%001:  Yeah, good night."
	B_O B_SUDA			;ブラックアウト
;	DB	'・・・・・・・・・'
	DB	".........................."
	DB	NEXT
;	DB	'そんなこんなで、俺の高校生活最初の夏は終わった。'
	DB	"And that was the end of summer."
	DB	NEXT
;	DB	'様々な想い出を残して・・・・・・'
	DB	"All kinds of memories..."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"............................"
	DB	NEXT
	DB	BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'ざばざば'
	DB	"*SQUELCH*"
	DB	NEXT
;	DB	'【？】：・・・'
	DB	"???:  ........................."
	DB	NEXT
;	DB	'ざばざば'
	DB	"*SQUELCH*"
	DB	NEXT
;	DB	'【？】：・・・'
	DB	"???:  ......................"
	DB	NEXT
;	DB	'ばしゃばしゃ・・・'
	DB	"*SPLASH*"
	DB	NEXT
	T_CG "CT13","F",0,15,3 	;校長
;	DB	'【校長】：・・・・・・・・・'
	DB	"Dean:  ................"
	DB	NEXT
;	DB	'【校長】：・・・やっと・・・帰って来られた・・・'
	DB	"Dean:  ...Finally...got back..."
	DB	NEXT
;	DB	'【校長】：私ももう年だろーか、前後不覚になるほど酔ってしまうとは。'
	DB	"Dean:  The last thing I remember, I was drinking..."
	DB	NEXT
;	DB	'【校長】：しかも、酔いが覚めてみたら知らない島にいるし・・・'
	DB	"Dean:  And then when I woke up and looked around,"
	DB	CR
	DB	"I was on this island."
	DB	NEXT
;	DB	'【校長】：小林先生とお酒を飲むのはもう止めよう・・・'
	DB	"Dean:  I don't think I'll be drinking with Kyoko-"
	DB	CR
	DB	"sensei anymore..."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS701.OVL',0
	DW	0000H


end

