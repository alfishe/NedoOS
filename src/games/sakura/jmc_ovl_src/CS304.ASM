;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　３０４
;		花見本編

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,-1
CM2:	DW	VV2,	NN5,NN6,-1
CM3:	DW	VV3,	NN8,NN9,-1
CM4:	DW	VV4,	NN9,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0
;VV4:	DB	4,	'やる',0
VV4:	DB	4,	"DO",0

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
;NN7:	DB	7,	'今日子',0
NN7:	DB	7,	"KYOKO",0
;NN8:	DB	8,	'現状',0
NN8:	DB	8,	"PARTY",0
;NN9:	DB	9,	'隠し芸',0
NN9:	DB	9,	'PERFORMANCE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4					;見る　誠３
S2:		DW	VV1, NN2,  2, M5, M6, M7					;見る　鈴子３
S3:		DW	VV1, NN3,  3, M8, M9, M10					;見る　清美３
S4:		DW	VV1, NN4,  4, M11, M12, M13					;見る　美緒３
S5:		DW	VV1, NN5,  5, M14, M15, M16					;見る　星愛３
S6:		DW	VV1, NN6,  6, M17, M18, M19, M20			;見る　恵依美４
S7:		DW	VV1, NN7,  7, M21, M22, M23, M24			;見る　今日子４
S8:		DW	VV2, NN5,  8, M25							;話す　星愛１
S9:		DW	VV2, NN6,  9, M26							;話す　恵依美１
S10:	DW	VV3, NN8,  10, M27, M28, M29, M30, M31, M32, M33	;考える　現状７
S11:	DW	VV3, NN9,  11, M34, M35, M36, M37, M38		;考える　隠し芸５
S12:	DW	VV4, NN9,  12, M39							;やる　隠し芸１


;イニシャルメッセージ
M1:
	DB	BGM,3
	E_CG B_GURU,"AE_006"
	DB	"The next day was the day for our group's cherry blossom-"
	DB	CR
	DB	"viewing party. Everyone showed up."
	DB	NEXT
;	DB	'【今日子】：・・・２１番、小林今日子！焼酎一瓶、一気飲みしま～す！'
	DB	"Kyoko:  ...Number 21, Kyoko Kobayashi! One bottle of gin,"
	DB	CR
	DB	"down the hatch!"
	DB	NEXT
;	DB	'【今日子】：・・・・・・んぐんぐんぐんぐんぐんぐ・・・・・・'
	DB	"Kyoko:  *GLUG GLUG GLUG*"
	DB	NEXT
;	DB	'【今日子】：・・・・・・っぷぁ～～～～～～っ！'
	DB	"Kyoko:  Ahhhhh...."
	DB	NEXT
;	DB	'【一同】：おお～～～～～～っ。'
	DB	"All:  Incredible."
	DB	NEXT
;	DB	'ヤンヤの喝采の中、今日子先生は満足げに座り込み・・・'
	DB	"Happy with the attention she was getting, Kyoko-sensei"
	DB	CR
	DB	"sat down again."
	DB	NEXT
;	DB	'早速新しい瓶の封を切り、手酌で茶碗に注ぎ始めた。'
	DB	"She opened a new bottle and started filling a 'chawan,' a "
	DB	CR
	DB	"traditional Japanese sake cup."
	DB	NEXT
;	DB	'【%001】：（・・・一体何本目なんだ？）'
	DB	"%001:  How can she drink so much?"
	DB	NEXT
;	DB	'【今日子】：・・・さぁて次は、誰が何やってくれるのかなぁ？'
	DB	"Kyoko:  Okay, who wants to get up and perform for everyone?"
	DB	CR
	DB	"At cherry blossom-viewing parties, everyone must"
	DB	CR
	DB	"perform something. "
	DB	NEXT
;	DB	'【恵依美】：・・・しゅ～～～～～～じィ？あんた、まだよねぇ？'
	DB	"Meimi:  Hey, %001, what are you going to perform?"
	DB	NEXT
;	DB	'【%001】：・・・中野・・・まだ酔ってるだろお前？'
	DB	"%001:  You're drunk, too!"
	DB	NEXT
;	DB	'【恵依美】：きゃ～～～～～～っはっはっは！'
	DB	"Meimi:  Ahhahahaha!"
	DB	NEXT
;	DB	'【%001】：・・・・・・聞けよ少しは。'
	DB	"%001:  .........................."
	DB	NEXT
;	DB	'【今日子】：そ～言えばそうねぇ・・・ンじゃ%001君、１発やっちゃってちょーだい！'
	DB	"Kyoko:  That's right. %001, perform something."
	DB	NEXT
;	DB	'【%001】：げ・・・・・・'
	DB	"%001:  Oh shit..."
	DB	C_BLD,C_N_ON,2,1		;話す　せいあ
	DB	C_BLD,C_N_ON,3,2		;考える
	DB	C_BLD,C_V_ON,2		;話す
	DB	C_BLD,C_V_ON,4		;やる
	DW	0000H

M2:		;見る　誠１
;	DB	'何故か、リアルストリートファイトをやっている。'
	DB	"He's doing his imitation of a character from that game,"
	DB	CR
	DB	"Street of Fire II."
	DW	0000H

M3:		;見る　誠２
;	DB	'・・・あいつは、確か物真似やってたな。'
	DB	"Now he's doing something else."
	DB	NEXT
;	DB	'俺は元ネタわかんなかったんだけど、何でも昔の有名な映画らしい。'
	DB	"I think it was a scene from an old movie. I'm not quite"
	DB	CR
	DB	"sure."
	DB	NEXT
;	DB	'・・・俺、アニメとＳＦしか見ね～からなぁ。'
	DB	"After all, I only watch anime and science fiction."
	DB	FLG,F_COPYI,1,2
	EF_SET 101
	DW	0000H

M4:		;見る　誠３
;	DB	'・・・まぁ、宜しくやってるよ～だからほっとこう。'
	DB	"He seems to be having fun, so I'll leave him alone."
	DW	0000H

M5:		;見る　鈴子１
;	DB	'桜の幹にもたれて、ボーッとしている。'
	DB	"She is standing against the tree, looking at the cherry"
	DB	CR
	DB	"blossoms."
	DB	NEXT
;	DB	'・・・鈴子さん、あんまり酒強くないんだな。'
	DB	"She doesn't seem to be a strong drinker."
	DW	0000H

M6:		;見る　鈴子２
;	DB	'ちなみに鈴子さんは、歌を唄った。'
	DB	"She's singing a song for everyone."
	DB	NEXT
;	DB	'ＣＭなんかで良く流れてる曲だった・・・フルコーラス聞いたのは初めてだ'
	DB	"It's some song that has been running on TV commercials"
	DB	CR
	DB	"lately."
	DB	NEXT
;	DB	'鈴子さんは、楽々唄ってたけど・・・・・・俺には無理だな。'
	DB	"Reiko sure sings well.. I certainly couldn't do it."
	DB	FLG,F_COPYI,2,2
	EF_SET 102
	DW	0000H

M7:		;見る　鈴子３
;	DB	'【鈴子】：・・・・・・ぼ～っ。'
	DB	"Reiko:  ....................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........."
	DB	NEXT
;	DB	'俺は事情を知ってるからい～けど、知らない人が見たら廃人だと思われちゃうぞ。'
	DB	"I know that she's drunk. But someone who didn't know that"
	DB	CR
	DB	"might mistake her for a retarded person."
	DW	0000H

M8:		;見る　清美１
;	DB	'今日子先生の方を、心配そうに眺めている。'
	DB	"She is looking at the professor with a worried look on her"
	DB	CR
	DB	"face."
	DB	NEXT
;	DB	'・・・まぁ確かに、あれだけ飲んでりゃ心配にもなるわな。'
	DB	"....I can't blame her."
	DW	0000H

M9:		;見る　清美２
;	DB	'新藤さんは、手品をやった。'
	DB	"Kiyomi was doing some magic tricks."
	DB	NEXT
;	DB	'トランプとか繩抜けとか、まぁ良くあるタイプの奴だ。'
	DB	"A simple trick using playing cards."
	DB	NEXT
;	DB	'・・・・・・よく考えたら、何でそんなもん持ってたんだ？'
	DB	"....Come to think of it, why did she bring cards with"
	DB	CR
	DB	"her tonight?",NEXT
;	DB	'いつも持ち歩いてるのか？'
	DB	"I wonder if she always carries them."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".................."
	DB	NEXT
;	DB	'予想してたのか？こ～なるって・・・・・・'
	DB	"I wonder if she planned to do the tricks...."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"..................."
	DB	NEXT
;	DB	'けっこ～、侮れないかもしれんな。'
	DB	"She certainly makes it look easy."
	DB	FLG,F_COPYI,3,2
	EF_SET 103
	DW	0000H

M10:		;見る　清美３
;	DB	'しかし新藤さんも心配症だな。今日子先生だっていい大人なんだから、自分の限界くらい知ってるだろうに。'
	DB	"Kiyomi sure worries a lot. Kyoko-sensei is an adult. I'm"
	DB	CR
	DB	"sure she knows her limit."
	DW	0000H

M11:		;見る　美緒１
;	DB	'誠達を、楽しそ～に見ている。'
	DB	"She's watching Makoto's performance, laughing."
	DB	NEXT
;	DB	'・・・けっこ～あの娘も、いい性格してるのかもしれない。'
	DB	".......She certainly has a good attitude."
	DW	0000H

M12:		;見る　美緒２
;	DB	'美緒ちゃんは・・・・・・歌を唄った・・・・・・んだよな？多分。'
	DB	"Mio's singing some song."
	DB	NEXT
;	DB	'とゆ～より、今日子先生に無理矢理やらされた、ってのが正しいな。'
	DB	"Kyoko-sensei made her get up and sing."
	DB	NEXT
;	DB	'よせばい～のに、鈴子さんまで「唄うくらいなら、できるでしょ？」'
	DB	"They should leave her alone. The poor girl."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	".............................."
	DB	FLG,F_COPYI,4,2
	EF_SET 104
	DW	0000H

M13:		;見る　美緒３
;	DB	'・・・声自体には、問題ね～んだけどなぁ・・・'
	DB	"She's got a nice voice."
	DW	0000H

M14:		;見る　星愛１
;	DB	'端っこの方で、正座して何やら飲んでいる。'
	DB	"She was sitting off on the side. It looks like she's been"
	DB	CR
	DB	"drinking."
	DB	NEXT
;	DB	'・・・気のせいか、顔がまっかっかだ。大丈夫かいな？'
	DB	"Maybe it's just me, but her face seems awfully red. She"
	DB	CR
	DB	"must have drunk a lot."
	DW	0000H

M15:		;見る　星愛２
;	DB	'・・・・・・・・・そ～言えば、吉田は未だ何にもやってないな。'
	DB	"........Come to think of it, Seia hasn't performed anything"
	DB	CR
	DB	"for us yet."
	DB	NEXT
;	DB	'だからっつって、順番押しつける気はないけど。'
	DB	"I wouldn't want to force her to do anything she didn't"
	DB	CR
	DB	"want to do."
	DB	NEXT
;	DB	'俺はそんなせこい事はやりたくないし、何より中野の奴が黙ってないだろう。'
	DB	"I don't want to do anything, myself. I understand how she"
	DB	CR
	DB	"must feel."
	DB	FLG,F_COPYI,5,2
	EF_SET 107
	DW	0000H

M16:		;見る　星愛３
;	DB	'・・・うーむ、なんか不気味だ・・・'
	DB	"....There is something mysterious about her."
	DW	0000H

M17:		;見る　恵依美１
;	DB	'【恵依美】：・・・くぉらしゅ～じ！あたしの顔になんか用かぁ！'
	DB	"Meimi:  ....%001! Why are you staring at me like that?!"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"................................."
	DB	NEXT
;	DB	'今更解説するまでもないな、こいつは。'
	DB	"Nevermind."
	DW	0000H

M18:		;見る　恵依美２
;	DB	'こいつの隠し芸は・・・・・・確か片手で桜の花びら捕まえてたっけ。'
	DB	"Her performance was..... What was it?"
	DB	NEXT
;	DB	'５枚くらいだったかな？結構簡単そうだったけど、割とウケてたな。'
	DB	"Catching five flower petals in one hand went over really"
	DB	CR
	DB	"well with everyone."
	DB	NEXT
;	DB	'・・・・・・結局「宴会芸」って、何でもい～からやりゃい～のか？'
	DB	"These party performances can be anything, it looks"
	DB	CR
	DB	"like. Maybe I should get it overwith."
	DB	FLG,F_COPYI,6,2
	EF_SET 105
	DW	0000H

M19:		;見る　恵依美３
;	DB	'【恵依美】：・・・おい、しゅ～じ。それが芸かぁ？'
	DB	"Meimi:  Hey %001, is that your performance? Staring"
	DB	CR
	DB	"at people?"
	DB	NEXT
;	DB	'【%001】：・・・あん？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【%001】：・・・誰が芸人だ、誰が。'
	DB	"%001:  Who said I wanted to perform for everyone,"
	DB	CR
	DB	"anyway?"
	DB	FLG,F_COPYI,6,3
	DW	0000H

M20:		;見る　恵依美４
;	DB	'・・・止めよう。何言われるかわかったもんじゃない。'
	DB	"I better stop talking to her. I think she's mad."
	DW	0000H

M21:		;見る　今日子１
;	DB	'実に美味そうに、茶碗をあおっている。'
	DB	"She's holding the sake cup, lovingly."
	DB	NEXT
;	DB	'・・・多少顔が赤いよ～な気もするが、はっきり言って酔ってるよ～には見えない。'
	DB	"She's a little red in the face. But to tell the truth,"
	DB	CR
	DB	"she doesn't seem that drunk."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".................................."
	DB	NEXT
;	DB	'まぁこの人の場合、普段から言動怪しいから・・・ホントは酔ってても、'
	DB	"It's hard to tell with her."
	DW	0000H

M22:		;見る　今日子２
;	DB	'さっき芸をやったばかりだ・・・焼酎一瓶、丸々一気飲み。'
	DB	"She just did her performance......drinking a whole bottle"
	DB	CR
	DB	"of gin."
	DB	NEXT
;	DB	'・・・俺は良くわかんね～んだけど、みんなの反応を見てると結構凄い事らしいな。'
	DB	"...Everyone loved it."
	DB	FLG,F_COPYI,7,2
	EF_SET 106
	DW	0000H

M23:		;見る　今日子３
;	DB	'【今日子】：・・・ん？な～に%001君。さっきから見詰めちゃって。'
	DB	"Kyoko:  ...What is it, %001? You've been staring at me all"
	DB	CR
	DB	"night."
	DB	NEXT
;	DB	'【%001】：何でもねえです。'
	DB	"%001:  Oh, nothing."
	DB	NEXT
;	DB	'【今日子】：ダメよ～、待ってたら次行くかも？とか思っちゃあ。'
	DB	"Kyoko:  Oh no. You were going to ask if you could perform"
	DB	CR
	DB	"for everyone next, right?"
	DB	NEXT
;	DB	'【%001】：・・・いや、別にそんな事は思ってないけど。'
	DB	"%001:  No. I wasn't thinking anything like that."
	DB	NEXT
;	DB	'【今日子】：それじゃあ、ちゃっちゃっとやっちゃってよ。先生、けっこ～期待してるんだからぁ。'
	DB	"Kyoko:  Go right ahead. I expect something big from you."
	DB	NEXT
;	DB	'【%001】：・・・はあ。'
	DB	"%001:  ...Uh, yeah. Whatever..."
	DB	FLG,F_COPYI,7,3
	DW	0000H

M24:		;見る　今日子４
;	DB	'・・・止めよう。ろくでもない事言われそ～な気がする・・・'
	DB	"Better stop. She'll probably make me get up in front"
	DB	CR
	DB	"of everyone."
	DW	0000H

M25:		;話す　星愛１
;	DB	'【%001】：・・・お、おい吉田？'
	DB	"%001:  ...Seia?"
	DB	NEXT
;	DB	'【星愛】：・・・・・・ふっふっふっふっふ。大丈夫よ恵依美ちゃん。'
	DB	"Seia:  It's okay, Meimi.",PAUSE,"It's my turn, now...!"
	DB	NEXT
;	DB	'【恵依美】：・・・ち、ちょっと星愛・・・！？'
	DB	"Meimi:  Seia? W- Wait...!"
	DB	NEXT
;	DB	'【%001】：吉田・・・目が座ってるぞ。'
	DB	"%001:  Seia, your eyes are spinning."
	DB	NEXT
;	DB	'【星愛】：・・・・・・２３番！星愛ちゃん、%001君より多く取りま～す！'
	DB	"Seia:  .....My name is Seia Yoshida, and I will catch more"

	DB	CR

	DB	"sakura petals than %001!"
	DB	NEXT
;	DB	'【恵依美】：ち・・・ちょっとってばぁ！'
	DB	"Meimi:  No, Seia!"
	DB	NEXT
;	DB	'【今日子】：お～、やんややんやぁ！'
	DB	"Kyoko:  Ooh, yeah!"
	DB	NEXT
;	DB	'【一同】：・・・ひゅーひゅー！'
	DB	"All:  Go! Go!"
	DB	NEXT
;	DB	'吉田は俺達の見守るなか、危なっかしい足取りでさくらの木の下まで進んで行き・・・・・・'
	DB	"While we all watched, Seia proceeded toward the cherry tree"
	DB	CR
	DB	"at a dangerous gait. I wasn't sure what was happening."
	DB	NEXT
;	DB	'【星愛】：・・・・・・ふっふっふ・・・・・・さぁ！'
	DB	"Seia:  ....Oooooh...... Ah!"
	DB	NEXT
;	DB	'ずるっ。',CR
	DB	"*SLIP*"
	DB	PAUSE
	DB	FLASH,1,GATA,3
;	DB	'ごっち～～～～～～～～～～～～～～～～ん！！'
	DB	" *CRASH*"
	DB	NEXT
;	DB	'・・・勢い良く振り向こうとして足を滑らせ、幹目掛けてムーンサルトプランチャーを敢行した。'
	DB	"She hit the tree her head. It made a terrible sound, like"

	DB	CR

	DB	"chopping a large piece of onion."
	DB	NEXT
;	DB	'【恵依美】：・・・あっちゃ～～～～～～っ・・・',CR
	DB	"Meimi:  Ooooh....",PAUSE,CR
;	DB	'【一同】：・・・お～～～～～～～～～っ。'
	DB	"All:  Aaaaah."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'俺は吉田の側に駆け寄ると、傷の具合いを確かめた。'
	DB	"I rushed to Seia's side to see if she was alright."
	DB	NEXT
;	DB	'【恵依美】：・・・どう？'
	DB	"Meimi:  How is she?"
	DB	NEXT
;	DB	'【%001】：・・・・・・別に、大した事ねェみたいだな。こぶが出来た'
	DB	"%001:  Doesn't seem that bad. She'll have a bump though."
	DB	NEXT
;	DB	'【恵依美】：・・・良かった・・・'
	DB	"Meimi:  I'm glad it's not that bad."
	DB	NEXT
;	DB	'【%001】：・・・大事な友達なんだな。'
	DB	"%001:  You two are really close."
	DB	NEXT
;	DB	'【恵依美】：・・・えっ！？そ、そりゃあまぁ、小学校時代からの友達だし・・・'
	DB	"Meimi:  Huh? Well, yeah, we've been friends since elementary"
	DB	CR
	DB	"school."
	DB	NEXT
;	DB	'【%001】：そか・・・そーだよな。'
	DB	"%001:  Is that so?"
	DB	NEXT
;	DB	'（昔からの親友・・・か。うらやましいぜ。）'
	DB	"I've never had a friend like that. I'm envious."
	DB	NEXT
;	DB	'【恵依美】：・・・%001？どうかした？'
	DB	"Meimi:  ...What's wrong, %001?"
	DB	NEXT
;	DB	'【%001】：あ、いや・・・何でもねぇ。それより、吉田ど～する？'
	DB	"%001:  Uh, nothing. What are we going to do with her?"
	DB	CR
	DB	"We should get her in bed."
	DB	NEXT
;	DB	'【恵依美】：あ、うん・・・そうだね。'
	DB	"Meimi:  That's a good idea."
	DB	NEXT
;	DB	'【今日子】：んじゃさ%001君。悪いんだけど、吉田さん家まで送って行ってくんない？地図描くから。'
	DB	"Kyoko:  %001, could you take Seia home? I'll draw you a"
	DB	CR
	DB	"map so you know how to get there."
	DB	NEXT
;	DB	'【%001】：わっかりました。'
	DB	"%001:  Okay."
	DB	NEXT
;	DB	'【恵依美】：じゃ、あたしも行く！'
	DB	"Meimi:  I'll go too!"
	DB	NEXT
;	DB	'【%001】：俺１人でも、別に大丈夫だぜ。吉田、軽いし。'
	DB	"%001:  I can manage myself. She's not very heavy."
	DB	NEXT
;	DB	'【今日子】：・・・そ～よね～、特別中野さんが付いていく必要はないわよね。じゃあ%001君、今地図描くわ。ちょっち待ってね。'
	DB	"Kyoko:  That's right. You really don't have to go along,"
	DB	CR
	DB	"Meimi. Hold on while I draw the map."
	DB	NEXT
;	DB	'さらさらさらさらさら'
	DB	"..................................."
	DB	NEXT
;	DB	'【今日子】：な～にゆってんのよ。教師たるもの、このくらい出来てあったりまえよん。・・・と、はい一丁上がり！'
	DB	"Kyoko:  Here you go, one map."
	DB	NEXT
;	DB	'【今日子】：じゃ、よろしくねん。'
	DB	"Kyoko:  Okay, get going."
	DB	NEXT
;	DB	'【%001】：・・・はーい・・・よいしょっ。'
	DB	"%001:  I'll be back in a bit."
	DB	NEXT
;	DB	'俺は目を回している吉田をしょって、公園を後にした。'
	DB	"I picked up Seia, whose eyes were still spinning, and left"
	DB	CR
	DB	"the park."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・'
	DB	"................................"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ..................."
	DB	NEXT
;	DB	'【今日子】：・・・吉田さんの事、心配？'
	DB	"Kyoko:  Are you worried about Seia?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ...................."
	DB	NEXT
;	DB	'【今日子】：大丈夫よ・・・何も心配する事無いわ。'
	DB	"Kyoko:  It's okay. There's nothing to worry about."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・はい。'
	DB	"Meimi:  ......................"
	DB	NEXT
;	DB	'【今日子】：・・・だからぁ、も～１０杯ほどいきましょ？恵依美ちゃん、
	DB	"Kyoko:  Let's have another drink or ten, Meimi. It looks"
	DB	CR
	DB	"like you haven't had enough to drink."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・え゛？'
	DB	"Meimi:  ........What?"
	DB	NEXT
;	DB	'【今日子】：さ、ぐ～～～～～～っと行きましょ！ぐ～～～～～～っとね！'
	DB	"Kyoko:  Come on! Let's go!"
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS305.OVL',0
	DW	0000H

M26:		;話す　恵依美１
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ..........."
	DB	NEXT
;	DB	'【%001】：・・・ん？どした中野、呆けた顔でこっち見たりして。'
	DB	"%001:  Why are you looking at me like that?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・え？'
;	DB	"Meimi:  ..........What?"
;	DB	NEXT
;	DB	'【%001】：・・・あ、お前の芸真似しちまったから怒ってるのか？'
	DB	"%001:  .....Are you mad that I copied your performance?"
	DB	NEXT
	DB	"%001:  I'm sorry. It was all I could think of..."
	DB	NEXT
;	DB	'【恵依美】：・・・あ、ううん、いいの。'
	DB	"Meimi:  Uh, yeah, it's okay."
	DB	NEXT
;	DB	'【%001】：・・・そか？'
	DB	"%001:  If you're sure."
	DB	NEXT
;	DB	'【星愛】：・・・・・・ふっふっふっふっふっ・・・・・・'
	DB	"Seia:  .....Hehehehe!"
	DB	NEXT
;	DB	'【%001】：・・・な、何だ？'
	DB	"%001:  .....What's wrong with her?"
	DB	NEXT
;	DB	'【恵依美】：せ、星愛・・・？'
	DB	"Meimi:  S- Seia?"
	DB	C_BLD,C_N_ON,2,2		;話す　せいあ
	DB	C_BLD,C_N_OFF,2,1		;話す　せいあ
	DW	0000H

M27:		;考える　現状１
;	DB	'・・・・・・そう、アレは今から２時間くらい前の事だ。'
	DB	"This has been going on for two hours."
	DB	FLG,F_COPYI,10,1
	DW	0000H

M28:		;考える　現状２
;	DB	'なんだかんだ言って全員集まった俺達１－Ａは、早速今日子先生の',CR
	DB	"Everyone in class 1-A had gotten together for our professor's"
	DB	CR
	DB	"'Drink as much as you want' challenge."
	DB	FLG,F_COPYI,10,2
	DW	0000H

M29:		;考える　現状３
	DB	"I understand her giving sake to Makoto, but she even had"
	DB	CR
	DB	"Meimi going."
	DB	NEXT
;	DB	'・・・・・・やはりあの先生、あなどれん。'
	DB	"Man, our professor is really awful."
	DB	FLG,F_COPYI,10,3
	DW	0000H

M30:		;考える　現状４
;	DB	'まぁそこまでは良かったんだけど・・・・・・'
;	DB	"Things were going fine up til that point."
;	DB	NEXT
;	DB	'【恵依美】：・・・くぉら、しゅ～じ！さっさとやれぇ！'
	DB	"Meimi:  .....Hey, %001! It's your turn to perform for us!"
	DB	CR
	DB	"Hurry up!"
	DB	NEXT
;	DB	'・・・・・・・・・'
;	DB	"..........................."
;	DB	NEXT
;	DB	'そう、中野って実は酒癖悪かったんだ。'
	DB	"Meimi gets really bad when she's drunk."
	DB	FLG,F_COPYI,10,4
	DW	0000H

M31:		;考える　現状５
;	DB	'まったく・・・・・・いきなり立ち上がって何をするかと思えば、'
	DB	"Her performance had been interesting, though."
	DB	NEXT
	DB	"She stood up and said, Hello, everyone, my name is Meimi"
	DB	CR
	DB	"Nakano!' I will do my special performance."
	DB	NEXT
;	DB	'と来たもんだ。'
	DB	"Then she caught cherry blossom petals in her hands."
	DB	FLG,F_COPYI,10,5
	DW	0000H

M32:		;考える　現状６
;	DB	'それからもぉ、後は済し崩し・・・・・・って奴。'
	DB	"It all went down the drain after that."
	DB	NEXT
;	DB	'・・・・・・まぁ、宴会といえば芸は付き物らしいし、それはそれで'
	DB	"Sure, performances are part of a party. I have no"
	DB	CR
	DB	"problem with that........"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"........................."
	DB	NEXT
;	DB	'俺、何にも考えてないんだよな。'
	DB	"I just had no idea what to do."
	DB	FLG,F_COPYI,10,6
	DB	C_BLD,C_N_OFF,3,2		;考える
	DW	0000H

M33:		;考える　現状７
;	DB	'【恵依美】：・・・おい、しゅ～じィ！は・や・くぅ～～～～～～！'
	DB	"Meimi:  ......Hey, %001. Hurry up!!!"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"............................"
	DB	NEXT
;	DB	'うーむ・・・困った。'
	DB	"Oh shit."
	DW	0000H

M34:		;考える　隠し芸１
;	DB	'うーん、何をしようか？'
	DB	"What should I do?"
	DB	FLG,F_COPYI,11,1
	DW	0000H

M35:		;考える　隠し芸２
;	DB	'・・・'
	DB	"............."
	DB	NEXT
;	DB	'・・・・・・'
	DB	"..................."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"............................"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"......................................."
	DB	NEXT
;	DB	'思い付かん。'
	DB	"I can't think of anything."
	DB	FLG,F_COPYI,11,2
	DW	0000H

M36:		;考える　隠し芸３
;	DB	'・・・そーだ。誰かの真似しよう。'
	DB	".......I know. I'll just copy someone else."
	DB	NEXT
;	DB	'俺は別に、コレで暮らし立ててる訳じゃないし・・・何でもい～からやれば、'
	DB	"I mean, it isn't a matter of life or death. Anything"
	DB	CR
	DB	"will do. At least they'll leave me alone after that."
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,1
	DB	FLG,F_COPYI,3,1
	DB	FLG,F_COPYI,4,1
	DB	FLG,F_COPYI,5,1
	DB	FLG,F_COPYI,6,1
	DB	FLG,F_COPYI,7,1
	DB	FLG,F_COPYI,11,3
	DW	0000H

M37:		;考える　隠し芸４
;	DB	'・・・さて、誰の真似しようかな？'
	DB	"I should copy someone's performance..."
	DW	0000H

M38:		;考える　隠し芸５
;	DB	'・・・决めた。'
	DB	"I know."
	DB	NEXT
;	DB	'よく考えたら、中野の真似くらいしか出来ないじゃないか。'
	DB	"Hmm, Meimi is the only person whose performance I could"
	DB	CR
	DB	"copy well enough."
;	DB	NEXT
	DB	C_BLD,C_V_OFF,4		;やる
	DW	0000H

M39:		;やる　隠し芸１
;	DB	'【%001】：・・・んじゃあ、やります。'
	DB	"%001:  Okay, here I go."
	DB	NEXT
;	DB	'【今日子】：お、待ってましたぁ！'
	DB	"Kyoko:  You kept us waiting long enough."
	DB	NEXT
;	DB	'【恵依美】：・・・待ちくたびれたぞ～！早くやれ～い！'
	DB	"Meimi:  Hurry up, %001!"
	DB	NEXT
;	DB	'俺は立ち上がり、近くの桜の木の下まで進んだ。'
	DB	"I stood up and walked over to the cherry tree."
	DB	NEXT
;	DB	'【%001】：・・・えっと、２２番・・・でいいのかな？山神%001、'
	DB	"%001:  ......Uh, hello, my name is %001 Yamagami. I'll"
	DB	CR
	DB	"catch the flying flower petals."
	DB	NEXT
;	DB	'びゅ',FLASH,1,'ば',FLASH,1,'ば',FLASH,1,'ば',FLASH,1,'ば',FLASH,1,'ば',FLASH,1,'ば',FLASH,1,'ばっ！'
	DB	"Shoosh ",FLASH,1,"swoosh ",FLASH,1,"swoosh ",FLASH,1,"swoosh ",FLASH,1,"swoosh ",FLASH,1,"swoosh ",FLASH,1,"swoosh ",FLASH,1,"swoooosh!"
	DB	NEXT
;	DB	'【一同】：・・・・・・・・・'
	DB	"All:  ................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	NEXT
;	DB	'あれ？'
	DB	"Huh?"
	DB	NEXT
;	DB	'・・・・・・やっぱ、二番煎じじゃダメだったのかな？'
	DB	"......I guess the second time around isn't as impressive."
	DB	NEXT
;	DB	'【鈴子】：・・・す',CR
	DB	"Reiko:  ......W",CR
	DB	PAUSE
;	DB	'【清美】：・・・ご',CR
	DB	"Kiyomi:  .....O",CR
	DB	PAUSE
;	DB	'【美緒】：・・・い！'
	DB	"Mio:  ........W!"
	DB	NEXT
;	DB	'【一同】：うぉおぉぉぉぉぉっ！！'
	DB	"All:  Great!!"
	DB	NEXT
;	DB	'【今日子】：・・・ひいふうみい・・・へ～、片手に７枚ずつかぁ。'
	DB	"Kyoko:  Way to go, seven petals in each hand! Amazing,"
	DB	CR
	DB	"%001. Fourteen petals in one catch!"
	DB	NEXT
;	DB	'【誠】：それだけじゃないっすよセンセー。指の間にはさみこんでる。'
	DB	"Makoto:  Not only that, he has them caught between his"
	DB	CR
	DB	"fingertips too. I knew there was a reason I hung out"
	DB	CR
	DB	"with you, %001."
	DB	NEXT
;	DB	'良かった・・・・・・ウケたみたいだ。'
	DB	"I'm glad that went over well."
	DB	NEXT
;	DB	'・・・ほっ。'
	DB	"......Ah."
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,8,255,101,102,103,104,105,106,107
	DB	FLG,F_EXIT,255
	DB	FLG,F_COPYI,11,4
	DW	0000H
end