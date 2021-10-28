;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　７０７
;		鈴子の誕生パーティー

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,NN8,-1

;VV1:	DB	1,	'話す',0
VV1:	DB	1,	"TALK",0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	"MAKOTO",0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	"REIKO",0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	"KIYOMI",0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	"MIO",0
;NN5:	DB	5,	'星愛',0
NN5:	DB	5,	"SEIA",0
;NN6:	DB	6,	'恵依美',0
NN6:	DB	6,	"MEIMI",0
;NN7:	DB	7,	'亜希',0
NN7:	DB	7,	"AKI",0
;NN8:	DB	8,	'今日子',0
NN8:	DB	8,	"KYOKO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;話す　誠２
S2:		DW	VV1, NN2,  2, M4, M5, M6, M7, M8		;話す　鈴子５
S3:		DW	VV1, NN3,  3, M9, M10		;話す　清美２
S4:		DW	VV1, NN4,  4, M11, M12		;話す　美緒２
S5:		DW	VV1, NN5,  5, M13, M14		;話す　星愛２
S6:		DW	VV1, NN6,  6, M15, M16		;話す　恵依美２
S7:		DW	VV1, NN7,  7, M17, M18		;話す　亜希２
S8:		DW	VV1, NN8,  8, M19, M20, M21		;話す　今日子３


;イニシャルメッセージ
M1:
	DB	BGM,4
	BAK_INIT 'AB_38_1'
	DB	BUF,B_COPY01
	DB	ANI,A_INIT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	".............................."

	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT14','F',0,0,1
;	DB	'【誠】：・・・おーっす、%001！生きてるかぁ？'
	DB	"Makoto:  .....Hey, %001! You're alive!"
	DB	NEXT
	DB	BUF,B_COPY01
	DB	ANI,A_OFF
	TU_CG 'CT03','F','I',10,2
	TU_CG 'CT02','F','I',0,3
	T_CG 'CT01','F','I',35,4
	DB	ANI,A_ON,3
	DB	ANI,A_ON,2
;	DB	'【鈴子】：・・・%001君！？'
	DB	"Reiko:  %001!"
	DB	NEXT
;	DB	'【清美】：%001さん！しっかりなさって！'
	DB	"Kiyomi:  %001! Pull yourself together!"
	DB	NEXT
;	DB	'【美緒】：%001先輩！%001先輩！・・・死んじゃやだーーーーーー！！'
	DB	"Mio:  %001! %001! Don't die on us!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............."
	DB	NEXT
;	DB	'【%001】：誰が死んだって？'
	DB	"%001:  Who died?"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ............."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ............."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  ............."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT14','F','D',0,5
;	DB	'【誠】：・・・・・・・・・・'
	DB	"Makoto:  ............."
	DB	NEXT,FLASH,3
;	DB	'ぱっかーん！'
	DB	"*BASH*"
	DB	NEXT
;	DB	'【%001】：いてぇ！'
	DB	"%001:  Ow!!"
	DB	PAUSE
;	DB	'何しやがんだよ誠！'
	DB	" What the hell, Makoto!"
	DB	NEXT
;	DB	'【誠】：やかましい。紛らわしい真似しやがって・・・天誅だ天誅。'
	DB	"Makoto:  Oh, shut up. You're just pretending to be sick,",CR,"anyway."
	DB	NEXT
	T_CG 'CT08','F','D',35,6
;	DB	'【恵依美】：・・・床でのびてるのに、何の事情があるって言うのよ？'
	DB	"Meimi:  You look better...a little."
	DB	NEXT
;	DB	'【%001】：・・・話せば長くなるんだがな・・・'
	DB	"%001:  I feel better."
	DB	NEXT
	T_CG1 'CT14','F',0,0,1
;	DB	'【誠】：・・・まぁい～や。取り合えず下に行こうぜ。'
	DB	"Makoto:  Well, whatever. Why don't we go downstairs."
	DB	CR
;	DB	";	DB	'鈴子さんの誕生パーティーやるから。'
	DB	"We're going to have Reiko's birthday party."
	DB	NEXT
;	DB	'【%001】：・・・・・・へ？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【誠】：だからぁ、鈴子さんの誕生パーティーやるの。ここで。'
	DB	"Makoto:  We're having Reiko's birthday party, remember?"
	DB	CR
	DB	"Right here, in your house."
	DB	NEXT
;	DB	'お前が動けないよ～だから、わざわざ来てやったんだ。感謝しろよ。'
	DB	"Makoto:  Because you can't move, we came to you. Be ",CR,"grateful."
	DB	NEXT
;	DB	'【%001】：・・・・・・はぁ。'
	DB	"%001:  Oh."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT01','F','I',35,4
;	DB	'【鈴子】：・・・ごめんね%001君。やっぱり迷惑・・・よね？'
	DB	"Reiko:  Sorry, %001. We're bothering you, aren't we?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'【%001】：いんや、全然。'
	DB	"%001:  No, not at all."
	DB	NEXT
;	DB	'【鈴子】：ホントに？'
	DB	"Reiko:  Really?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yeah."
	DB	NEXT
	T_CG1 'CT01','F',0,35,7
;	DB	'【鈴子】：・・・ありがとう。'
	DB	"Reiko:  Thanks."
	DB	NEXT
;	DB	'【%001】：礼を言うのは、こっちの方さ。'
	DB	"%001:  I'm the one who should be thanking you."
	DB	PAUSE
;	DB	'・・・じゃあ、いこっか？'
	DB	" Well, shall"
	DB	CR
	DB	"we go downstairs?"
	DB	NEXT,GATA,1
;	DB	'くらっ'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'【鈴子】：%001君！'
	DB	"Reiko:  %001!"
	DB	CR
;	DB	'【清美】：%001さん！'
	DB	"Kiyomi:  %001!"
	DB	CR
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【%001】：・・・あ、ああ大丈夫だ。'
	DB	"%001:  Oh, I'm okay. I just fell down."
	DB	NEXT
;	DB	'【鈴子】：無理しないの。・・・このまま下まで運んでいくわね。'
	DB	"Reiko:  Don't strain yourself. We'll carry you downstairs."
	DB	NEXT
;	DB	'【%001】：・・・悪りィ・・・'
	DB	"%001:  .......Sorry...."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".........................."
	DB	NEXT
	DB ANI,A_INIT
	BAK_INIT 'AB_01_1'
	DB BUF,B_COPY01
	T_CG 'CT12','F','K',10,1
;	DB	'【今日子】：・・・あ～ら、%001君。調子はどう？'
	DB	"Kyoko:  .....Oh %001. How are you doing?"
	DB	NEXT
;	DB	'【%001】：・・・・・・何で先生が居るんですか？'
	DB	"%001:  Why are you here, Sensei?"
	DB	NEXT
;	DB	'【今日子】：お見舞いよ、お見舞い。'
	DB	"Kyoko:  I'm here to visit the patient, of course."
	DB	NEXT
;	DB	'【%001】：・・・その手に持ってるのは、一体何です？'
	DB	"%001:  What do you have there in your hand?"
	DB	NEXT
;	DB	'【今日子】：お酒に決まってるじゃない。'
	DB	"Kyoko:  I brought some sake, of course."
	DB	NEXT
;	DB	'昔から言うでしょ？『酒は百薬の長』って。'
	DB	"Kyoko:  I've said it before, haven't I? 'Sake is the best"
	DB	CR
	DB	"medicine'."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................................"
	DB	NEXT
	T_CG1 'CT06','F','K',30,2
	DB ANI,A_ON,1
;	DB	'【亜希】：せーんぱい！'
	DB	"Aki:  %001!"
	DB	NEXT
;	DB	'【%001】：・・・亜希ちゃんも来てたの？'
	DB	"%001:  Aki, you came too?"
	DB	NEXT
	K_CG 'CT06','D',30,3
;	DB	'【亜希】：来てちゃ悪い！？'
	DB	"Aki:  Why not?!"
	DB	NEXT
;	DB	'【%001】：・・・・・・いや、別に。'
	DB	"%001:  Oh, no reason."
	DB	NEXT
;	DB	'【今日子】：さぁて、んじゃ早速乾杯よ！'
	DB	"Kyoko:  Well, come on, let's have a drink!"
	DB	NEXT
;	DB	'【%001】：・・・・・・結局飲ませるんだからなぁ、もう・・・・・・'
	DB	"%001:  So I guess you're going to make me drink."
	DB	BGM,27
	E_CG B_SUDA,'AE_030'
	DW	0000H

M2:		;話す　誠１
;	DB	'【%001】：・・・誠は・・・？'
	DB	"%001:  Where's Makoto?"
	DB	NEXT
;	DB	'【亜希】：はっ！はっ！はっ！はっ！はい～～～～～～っ！！'
	DB	"Aki:  Stay put, you! Take this!"
	DB	NEXT
;	DB	'【誠】：げふっ！'
	DB	"Makoto:  Help!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................"
	DB	NEXT
;	DB	'あいつ、格闘マニアでもあったのか・・・・・・'
	DB	"What, are they fighting again or something?"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;話す　誠２
;	DB	'・・・・・・宜しくやってるみたいだから、ほっとこう。'
	DB	"Let's just leave them alone."
	EF_SET 101
	DW	0000H

M4:		;話す　鈴子１
;	DB	'【鈴子】：%001君、どう？気分悪くない？'
	DB	"Reiko:  %001, are you feeling okay?"
	DB	NEXT
;	DB	'【%001】：全然平気。'
	DB	"%001:  I'm just fine."
	DB	NEXT
;	DB	'【鈴子】：寒くない？毛布持って来てあげよっか？'
	DB	"Reiko:  Aren't you cold? Should I get you a blanket?"
	DB	NEXT
;	DB	'【%001】：大丈夫。'
	DB	"%001:  No, I don't need one."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　鈴子２
;	DB	'【鈴子】：ほら、%001君。これおいしいわよ。柔らかいし。'
	DB	"Reiko:  Here, %001. This is really delicious."
	DB	NEXT
;	DB	'【%001】：あ、さんきゅ。'
	DB	"%001:  Oh, thanks."
	DB	NEXT
;	DB	'【鈴子】：・・・%001君、これもいけるわ。どう？'
	DB	"Reiko:  ....%001, this is good too. How are you doing?"
	DB	NEXT
;	DB	'【%001】：・・・ありがと。'
	DB	"%001:  Thanks."
	DB	NEXT
;	DB	'【清美】：鈴子さん・・・主役なのですから、座ってらしたらいかがでしょう？'
	DB	"Kiyomi:  You're the birthday girl here, Reiko. Why don't"
	DB	CR
	DB	"you sit down and relax?"
	DB	NEXT
;	DB	'【鈴子】：ん？私？楽しんでるわよ。'
	DB	"Reiko:  Hm? I'm enjoying myself."
	DB	NEXT
;	DB	'【清美】：・・・いえ、ですから・・・'
	DB	"Kiyomi:  Oh, I just thought..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　鈴子３
;	DB	'【鈴子】：%001君、はいオレンジジュース。'
	DB	"Reiko:  %001, here's some orange juice."
	DB	NEXT
;	DB	'【%001】：ああ・・・ありがと。'
	DB	"%001:  Oh, thanks."
	DB	NEXT
;	DB	'【鈴子】：汗が出て来たみたいね・・・タオル持って来るわ。'
	DB	"Reiko:  Looks like you're sweating a bit.....I'll go get"
	DB	CR
	DB	"a towel."
	DB	NEXT
;	DB	'【%001】：・・・いや、大丈夫。'
	DB	"%001:  That's okay."
	DB	NEXT
;	DB	'【鈴子】：そう？結構出てるわよ・・・今使わなくても、その内使うと思うから持って来るわね。'
	DB	"Reiko:  Really? I'll go get it anyway. Even if you don't"
	DB	CR
	DB	"use it now, you can use it later."
	DB	NEXT
;	DB	'【美緒】：鈴子先輩、あたしが持って来るよ。先輩は座ってて。'
	DB	"Mio:  Reiko, I'll go get it. You take a seat."
	DB	NEXT
;	DB	'【鈴子】：悪いわね、美緒ちゃん。'
	DB	"Reiko:  Thanks, Mio."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M7:		;話す　鈴子４
;	DB	'【鈴子】：・・・つまみ切れちゃたわね、取って来るわ。'
	DB	"Reiko:  I'll go get you some more food."
	DB	NEXT
;	DB	'【%001】：・・・鈴子さん、ちょっと待って。'
	DB	"%001:  Reiko, wait a minute."
	DB	NEXT
;	DB	'【鈴子】：なに？'
	DB	"Reiko:  What?"
	DB	NEXT
;	DB	'【%001】：・・・・・・あのさ・・・・・・今日は鈴子さんの誕生日だよな？'
	DB	"%001:  Well, today is your birthday, right?"
	DB	NEXT
;	DB	'【鈴子】：ええ、そうよ。'
	DB	"Reiko:  Yes, of course."
	DB	NEXT
;	DB	'【%001】：・・・だったらさ・・・その・・・も～ちょっと座ってれば？'
	DB	"%001:  So, why don't you just sit down, next to me?",PAUSE
	DB	" Because"
	DB	CR
	DB	"I'm just fine here."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  .................."
	EF_SET 102
	DW	0000H

M8:		;話す　鈴子５
;	DB	'【鈴子】：・・・・・・ねえ、%001君。私、つまんなそうに見える？'
	DB	"Reiko:  Hey, %001. Do I look like I'm not having fun?"
	DB	NEXT
;	DB	'【%001】：・・・え？'
	DB	"%001:  Eh?"
	DB	NEXT
;	DB	'【鈴子】：私、楽しんでるわよ。こんなに人が来てくれたんですもの、それだけでとっても嬉しいわ。'
	DB	"Reiko:  I'm enjoying this. I'm just happy that so many"
	DB	CR
	DB	"of you are here."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............."
	DB	NEXT
;	DB	'【鈴子】：・・・それにね・・・'
	DB	"Reiko:  And besides..."
	DB	NEXT
;	DB	'不意に、鈴子さんが俺の瞳を覗き込む。真っ直ぐ、俺の心まで届かんばかりに。'
	DB	"Suddenly, Reiko looked deep into my eyes. And straight"
	DB	CR
	DB	"into my heart."
	DB	NEXT
;	DB	'【鈴子】：・・・%001君・・・私・・・'
	DB	"Reiko:  I mean, %001.........I......."
	DB	NEXT
;	DB	'【%001】：・・・鈴子さん・・・？'
	DB	"%001:  Reiko........"
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ................."
	DB	CR
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  .................."
	DB	NEXT
;	DB	'【%001】：・・・・・・ん？'
	DB	"%001:  .......Hm?"
	DB	NEXT
;	DB	'ふと気が付くと、新藤さんと美緒ちゃんがこっちを睨んでいた。'
	DB	"Suddenly I noticed that Kiyomi and Mio were glaring at"
	DB	CR
	DB	"us."
	DB	NEXT
;	DB	'【鈴子】：・・・と、とにかく・・・私は楽しいわよ。%001君も、'
	DB	"Reiko:  ......A- Anyway, I'm having fun. Are you having"
	DB	CR
	DB	"fun too, %001?"
	DB	NEXT
;	DB	'【%001】：・・・あ・・・ああ・・・'
	DB	"%001:  ......Ah, of course."
	DB	NEXT
;	DB	'（・・・何だったんだ、一体・・・？）'
	DB	".....Geez, what was that about?"
	DB	NEXT
;	DB	'【英美】：ただいま～☆ケーキ買って来たわよ～！'
	DB	"Hidemi:  Hello! I'm back with a birthday cake!"
	DB	NEXT
;	DB	'【伸幸】：・・・お～、やっと来たか。'
	DB	"Nobuyuki:  Oh, everyone's here."
	DB	NEXT
;	DB	'【美緒】：・・・さ、鈴子先輩！'
	DB	"Mio:  Oh, Reiko!"
	DB	NEXT
;	DB	'【清美】：こちらへどうぞ。今、火を付けますわ。'
	DB	"Kiyomi:  Why don't you put it here? I'll light the"
	DB	CR
	DB	"candles."
	DB	NEXT
;	DB	'【鈴子】：ハーイ。・・・じゃ、行って来るね%001君！'
	DB	"Reiko:  Great, I'll be right back, %001!"
	DB	NEXT
;	DB	'【%001】：・・・あ、ああ。'
	DB	"%001:  Oh, yeah."
	DB	NEXT
;	DB	'（・・・いつも通りの三人だ・・・）'
	DB	"Always the same, those three."
	DB	NEXT
;	DB	'（・・・・・・さっきのは、俺の気のせいか？）'
	DB	"Was I just imagining what just happened?"
	DB	NEXT
;	DB	'この後・・・・・・'
	DB	"Later........"
	DB	NEXT
;	DB	'俺達全員の「はっぴぃばーすでい」大合唱の中、鈴子さんは'
	DB	"Everybody sang 'Happy birthday' at the top of their"
	DB	CR
	DB	"lungs, and Reiko blew out all the candles in one breath."
	DB	NEXT
;	DB	'・・・・・・俺はきっと、この時の鈴子さんの笑顔を忘れないだろう。'
	DB	"I don't think I'll ever forget Reiko's smiling face in"
	DB	CR
	DB	"that moment."
	DB	NEXT
;	DB	'本当に、透き通るような笑顔だったから・・・・・・'
	DB	"She was really just glowing with happiness...."
	DB	NEXT
;	DB	'「・・・・・・何か、してあげたい。」'
	DB	"....I knew it then. I wanted to do something for her."
	DB	NEXT
;	DB	'色々してもらったから、って事もある。'
;	DB	"She's done all sort of things for me."
;	DB	NEXT
;	DB	'だけど俺は・・・鈴子さんだから、鈴子さんの誕生日だから、'
;	DB	"But...since it's Reiko, and it's her birthday I want to"
;	DB	CR
;	DB	"do something for her."
;	DB	NEXT
;	DB	'その為に・・・'
	DB	"In order to do that... "
	DB	PAUSE
;	DB	'一刻も早く、この風邪を治そう。'
	DB	"I had to get over this cold fast."
	DB	NEXT
;	DB	'少しくらい苦くても、薬を飲もう。'
	DB	"Even though I don't like it, I'll take that medicine."
	DB	NEXT
;	DB	'俺は心底、そう思った・・・・・・'
	DB	"That's really what I thought, from the bottom of my"
	DB	CR
	DB	"heart...."
	DB	NEXT
	B_O B_SUDA
	DB	SINARIO,'CS708.OVL',0
	DW	0000H

M9:		;話す　清美１
;	DB	'【清美】：%001さん、クッションをお持ちしましたわ。'
	DB	"Kiyomi:  %001, I brought you a cushion."
	DB	NEXT
;	DB	'【%001】：・・・ああ、ありがと。'
	DB	"%001:  Oh, thanks."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M10:		;話す　清美２
;	DB	'【清美】：%001さん・・・何か食べたいものはありますか？'
	DB	"Kiyomi:  %001, is there something you'd like to eat?"
	DB	NEXT
;	DB	'【%001】：・・・ん～、取り敢えずはいいや。鈴子さんが持って来てくれたのが残ってるし。'
	DB	"%001:  Nah, you don't have to get me anything. There's"
	DB	CR
	DB	"still stuff left that Reiko brought me."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ......"
	EF_SET 103
	DW	0000H

M11:		;話す　美緒１
;	DB	'【美緒】：%001先輩、これ食べてよ！'
	DB	"Mio:  %001, have some of this!"
	DB	NEXT
;	DB	'【%001】：・・・ああ、ありがと。・・・これ、美緒ちゃんが？'
	DB	"%001:  .....Oh, thanks. ....Did you make this, Mio?"
	DB	NEXT
;	DB	'【美緒】：うん！%001先輩病気だから、いつもより柔らかめにして見たんだ。'
	DB	"Mio:  Yes! I thought since you were sick, you'd like"
	DB	CR
	DB	"something soft."
	DB	PAUSE
;	DB	'・・・どう？'
	DB	" How is it?"
	DB	NEXT
;	DB	'【%001】：・・・うん、美味いよ。'
	DB	"%001:  .....Mmm, it's delicious."
	DB	NEXT
;	DB	'【美緒】：・・・よかった・・・'
	DB	"Mio:  Oh, good..."
	DB	NEXT
;	DB	'（・・・ホントは舌がバカになってて、良くわかんね～んだけど・・・）'
	DB	"(...Actually, I can't taste much of anything right"
	DB	CR
	DB	"now...)"
	DB	FLG,F_COPYI,4,1
	DW	0000H

M12:		;話す　美緒２
;	DB	'【美緒】：%001先輩・・・後で卵酒作ってあげるね。'
	DB	"Mio:  %001, I'll make you some sake with a raw egg in"
	DB	CR
	DB	"it later, okay?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、ありがとな。'
	DB	"%001:  Oh, thanks."
	EF_SET 104
	DW	0000H

M13:		;話す　星愛１
;	DB	'【%001】：・・・吉田は・・・？'
	DB	"%001:  Seia?"
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ......"
	DB	NEXT
;	DB	'・・・又あんな隅っこで・・・'
	DB	"She's sitting in a corner again..."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M14:		;話す　星愛２
;	DB	'・・・・・・・・・'
	DB	"....................."
	DB	NEXT
;	DB	'刺激しない方がいいな、きっと。'
	DB	"I probably shouldn't bother her."
	EF_SET 105
	DW	0000H

M15:		;話す　恵依美１
;	DB	'【%001】：・・・中野は・・・？'
	DB	"%001:  Meimi...?"
	DB	NEXT
;	DB	'【伸幸】：・・・ふむふむ、なるほどねぇ。'
	DB	"Meimi:  ...Blah blah, you don't say?"
	DB	NEXT
	DB	"Uh-oh. She's talking to my parents."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M16:		;話す　恵依美２
;	DB	'・・・暴発してくれるなよ・・・頼むから・・・'
	DB	"I wonder what they're talking about over there?"
	EF_SET 106
	DW	0000H

M17:		;話す　亜希１
;	DB	'【%001】：・・・亜希ちゃんは・・・？'
	DB	"%001:  Aki...?"
	DB	NEXT
;	DB	'【亜希】：ほぉらのめのめぇ！'
	DB	"Aki:  Come back here, Makoto!"
	DB	NEXT
;	DB	'【誠】：・・・うぐうぐうぐ・・・'
	DB	"Makoto:  .......No, wait!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'あいつら・・・仲いいのか？悪いのか？'
	DB	"I can't tell if those two like each other or hate each other."
	DB	FLG,F_COPYI,7,1
	DW	0000H

M18:		;話す　亜希２
;	DB	'・・・・・・宜しくやってるみたいだから、ほっとこう。'
	DB	"Well, she seems to be pretty relaxed today, though."
	EF_SET 107
	DW	0000H

M19:		;話す　今日子１
;	DB	'【今日子】：・・・%001く～ん、飲んでるぅ？'
	DB	"Kyoko:  %001, are you drinking?"
	DB	NEXT
;	DB	'【%001】：・・・まぁ一応。'
	DB	"%001:  A little."
	DB	NEXT
;	DB	'【今日子】：ダメよぉ、君は病人なんだから・・・ちゃんと飲まなきゃ。'
	DB	"Kyoko:  Well, that's not enough. You have to apply yourself."
	DB	NEXT
;	DB	'【%001】：・・・・・・何を？'
	DB	"%001:  ....To what?"
	DB	NEXT
;	DB	'【今日子】：『百薬の長』よん。'
	DB	"Kyoko:  'The mother of all medicine..'"
	DB	NEXT
;	DB	'だぱだぱだぱだぱ'
;	DB	"*GLUG GLUG GLUG*"
;	DB	NEXT
;	DB	'とか何とか言いつつ、先生はしっかりと俺のコップに焼酎を注ぐ。'
	DB	"As she was talking, Sensei poured some sake in my cup."
	DB	NEXT
;	DB	'【%001】：・・・あの・・・これにビール入ってたんですけど・・・'
	DB	"%001:  Um, there was some beer in there before."
	DB	NEXT
;	DB	'【今日子】：まぁまぁ、気にしない気にしない。'
	DB	"Kyoko:  Oh. Well, it'll taste good, too."
	DB	FLG,F_COPYI,8,1
	DW	0000H

M20:		;話す　今日子２
;	DB	'【今日子】：・・・をやぁ？%001君、何持ってるのぉ？'
	DB	"Kyoko:  Well? What do you have there, %001?"
	DB	NEXT
;	DB	'【%001】：・・・オレンジジュースですけど。'
	DB	"%001:  Well, some orange juice, actually."
	DB	NEXT
;	DB	'【今日子】：しょーがないわねぇ。'
	DB	"Kyoko:  Oh well."
	DB	NEXT
;	DB	'ざぶざぶざぶざぶ'
	DB	"*GLUG GLUG GLUG*"
	DB	NEXT
;	DB	'言うが早いか、先生は俺のコップにウォッカを注いだ。'
	DB	"Before I knew it, she was pouring some Vodka into my cup."
	DB	NEXT
;	DB	'【今日子】：はい、スクリュードライヴァー完成～。'
	DB	"Kyoko:  There, now you have a screwdriver."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	FLG,F_COPYI,8,2
	DW	0000H

M21:		;話す　今日子３
;	DB	'・・・・・・止めよう。自分の首を絞めるだけだ・・・・・・'
	DB	"I better stop. I feel like I'm strangling myself..."
	EF_SET 108
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,9,255,101,102,103,104,105,106,107,108
	DB FLG,F_EXIT,255
	DB	FLG,F_COPYI,2,4
	DW	0000H
	

end
