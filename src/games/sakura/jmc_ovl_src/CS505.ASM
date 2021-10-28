;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０５
;		林間学校　初日夜

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,NN8,NN9,-1
CM2:	DW	VV2,	NN10,NN11,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'聞く',0
VV2:	DB	2,	'LISTEN',0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	'MAKOTO',0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	'REIKO',0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'KIYOMI',0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	'MIO',0
;NN5:	DB	5,	'祥子',0
NN5:	DB	5,	'SHOKO',0
;NN6:	DB	6,	'瑠璃',0
NN6:	DB	6,	'RURI',0
;NN7:	DB	7,	'亜希',0
NN7:	DB	7,	'AKI',0
;NN8:	DB	8,	'恵依美',0
NN8:	DB	8,	'MEIMI',0
;NN9:	DB	9,	'星愛',0
NN9:	DB	9,	'SEIA',0
;NN10:	DB	10,	'今日の予定',0
NN10:	DB	10,	"OTHERS",0
;NN11:	DB	11,	'誠の唄',0
NN11:	DB	11,	"MAKOTO'S SONG",0

;この上の事項は ' がありますけど、これで大丈夫ですか？

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2			;見る　誠１
S2:		DW	VV1, NN2,  2, M3			;見る　鈴子１
S3:		DW	VV1, NN3,  3, M4			;見る　清美１
S4:		DW	VV1, NN4,  4, M5			;見る　美緒１
S5:		DW	VV1, NN5,  5, M6			;見る　祥子１
S6:		DW	VV1, NN6,  6, M7			;見る　瑠璃１
S7:		DW	VV1, NN7,  7, M8			;見る　亜希１
S8:		DW	VV1, NN8,  8, M9			;見る　恵依美１
S9:		DW	VV1, NN9,  9, M10			;見る　星愛１
S10:	DW	VV2, NN10,10, M11, M12, M13, M14		;聞く　明日の予定４
S11:	DW	VV2, NN11,11, M15, M16		;聞く　誠の唄２


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT "AB_16_2"
	DB BUF,B_COPY01
	T_CG "CT14","F","I",35,1
;	DB	'【誠】：・・・と～お～い～流れ星にィ～・・・'
;	DB	"Makoto:  Look! A shooting star!"
;	DB	NEXT
;	DB	'・・・その夜。'
	DB	"Later that night....."
	DB	NEXT
;	DB	'美緒ちゃん謹製のカレーをおいしく頂いた俺達は、焚き火を囲んで'
	DB	"We all ate Mio's curry and now sat around the fire,"
	DB	CR
	DB	"relaxing after the long day."
	DB	NEXT
;	DB	'【%001】：・・・ああ・・・星空が綺麗だな・・・'
	DB	"%001:  ......Look at all those stars."
	DW	0000H

M2:		;見る　誠１
;	DB	'ギターなんぞ抱えて、何やら唄っている。'
	DB	"He's stumming his guitar, singing."
	DB	NEXT
;	DB	'（・・・まぁ、ヘタじゃあないな。）'
	DB	"I wonder what the name of the song is. I haven't heard it"

	DB	CR

	DB	"before."
	DW	0000H

M3:		;見る　鈴子１
;	DB	'ジッと、歌を聞いている。'
	DB	"She's listening to Makoto singing."
	DB	NEXT
;	DB	'（・・・歌が好きなのかな？）'
	DB	"Does she like to sing?"
	DB	NEXT
;	DB	'（・・・・・・そ～言えば、花見の時も唄ってたし。好きなんだな、きっと。）'
	DB	"Now that I think about it, she was singing in the park"
	DB	CR
	DB	"when we had flower viewing. I guess she likes music"
	DB	CR
	DB	"after all."
	DW	0000H

M4:		;見る　清美１
;	DB	'何やら、本を読んでいる。'
	DB	"She's reading a book."
	DB	NEXT
;	DB	'（・・・こんな暗いところで読んでたら、眼が悪くなっちゃうぞ。）'
	DB	"She's going to hurt her eyes, reading in the dark like"
	DB	CR
	DB	"this."
	DB	NEXT
;	DB	'（・・・・・・既に悪いか・・・・・・）'
	DB	".......Well, she'll ruin them more than they already are."
	DW	0000H

M5:		;見る　美緒１
;	DB	'ぼんやり、薪の炎を見詰めている。'
	DB	"She's stacking firewood."
	DB	NEXT
;	DB	'（・・・なんか、妙に大人びて見えるな・・・）'
	DB	"Something about her seems strangely grown-up. I wonder"
	DB	CR
	DB	"what it is."
	DW	0000H

M6:		;見る　祥子１
;	DB	'俺の横に、さっきからぴったりくっついている。'
	DB	"She's sitting next to me, pushing her body up against"
	DB	CR
	DB	"mine."
	DB	NEXT
;	DB	'（・・・まさか『寝る時もこのまま』とか言わないだろうな？）'
	DB	"She's not going to sleep next to me too, is she?"
	DW	0000H

M7:		;見る　瑠璃１
;	DB	'じ～っと、月を見上げている。'
	DB	"She's looking up at the sky."
	DW	0000H

M8:		;見る　亜希１
;	DB	'地面に大の字になって、星空を見ている。'
	DB	"She's writing letters in the sand, and looking up at"
	DB	CR
	DB	"the stars."
	DB	NEXT
;	DB	'（・・・この娘でも、黙ってる時があるんだな。）'
	DB	"I've never seen her quiet like this."
	DB	NEXT
;	DB	'（・・・・・・これ言ったら、スゲー怒るんだろうな。）'
	DB	"I wonder what she's thinking."
	DW	0000H

M9:		;見る　恵依美１
;	DB	'袋菓子だの果物だのを、食い散らかしまくっている。'
	DB	"She's eating again."
	DB	NEXT
;	DB	'（・・・一体どれだけ持って来たんだ？）'
	DB	"Where did she get dried squid, anyway?"
	DW	0000H

M10:		;見る　星愛１
;	DB	'ぼんやりと、薪の炎を見ている。'
	DB	"She's staring at the campfire."
	DB	NEXT
;	DB	'（・・・案外、誠の歌を聞いているのかもな。）'
	DB	"She's probably listening to Makoto's song at the same"
	DB	CR
	DB	"time."
	DW	0000H

M11:		;聞く　明日の予定１
;	DB	'【%001】：・・・ところで、明日は何をするんだ？'
	DB	"Some of the others are talking about tomorrow's schedule."
	DB	NEXT
	DB	"Reiko:  So what's the schedule for tomorrow, anyway?"
	DB	NEXT
	T_CG "CT03","F",0,0,2
	DB	ANI,A_ON,1
;	DB	'【美緒】：みんなで釣りだって。'
	DB	"Mio:  We're all going fishing."
	DB	NEXT
;	DB	'【%001】：・・・ふ～ん。'
	DB	"%001:  Fishing?"
	DB	PAUSE
;	DB	'晩飯にでもするのかな？'
	DB	" Are we going to cook the fish for dinner?"
	DB	NEXT
;	DB	'【美緒】：うん、そ～だって。'
	DB	"Mio:  Yes."
	DB	PAUSE
;	DB	'だから明日の分のおかず、持って来てないんだって。'
	DB	" And there's no food for tomorrow. We have to"
	DB	CR
	DB	"catch our own dinners."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ........"
	DB	PAUSE
;	DB	'マジ？'
	DB	"Are you serious?"
	DB	NEXT
;	DB	'【美緒】：うん。'
	DB	"Mio:  Yes."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	".................."
	DB	NEXT
;	DB	'（・・・ど～せ、校長先生の方針なんだろーな・・・）'
	DB	"This has to be the dean's idea."
	DB	FLG,F_COPYI,10,1
	DW	0000H

M12:		;聞く　明日の予定２
;	DB	'【%001】：・・・他には？'
	DB	"%001:  What else are we doing tomorrow?"
	DB	NEXT
;	DB	'【美緒】：取り敢えずは、それだけ・・・'
	DB	"Mio:  That's all that's planned..."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT06","F",'D',15,3
;	DB	'【亜希】：ある訳ないじゃん！'
	DB	"Aki:  You can't be serious!"
	DB	NEXT
;	DB	'全校生徒分のおかず、釣らなきゃなんないのよ？'
	DB	"Aki:  Everyone has to catch something tomorrow if"
	DB	CR
	DB	"they want to eat?"
	DB	NEXT
;	DB	'【%001】：・・・まぁ確かに、皆が自分の食い扶持釣れるとは限らんわな。'
	DB	"%001:  It'll be hard, but we'll get enough fish somehow."
;	DB	NEXT
;	DB	'【亜希】：そ～よ。'
;	DB	"Aki:  Okay.
;	DB	PAUSE
;	DB	'先輩もそんなにバカじゃないんだから、少しは考えてからしゃべってよね。'
;	DB	"But please be careful of what you say in the future."
;	DB	NEXT
;	DB	'【%001】：・・・・・・へいへい。'
;	DB	"%001:  Hey!"
	DB	FLG,F_COPYI,10,2
	DW	0000H

M13:		;聞く　明日の予定３
;	DB	'【%001】：・・・明日は釣りか・・・'
	DB	"%001:  Fishing..."
	DB	NEXT
;	DB	'【亜希】：先輩の場合、手掴みの方がいいんじゃないの？'
	DB	"Aki:  You might be better off catching fish with your bare"
	DB	CR
	DB	"hands, %001."
	DB	NEXT
;	DB	'【%001】：・・・そんな事、出来る訳ないだろ？'
	DB	"%001:  I could never do that."
	DB	NEXT
;	DB	'【亜希】：なんでよ？'
	DB	"Aki:  Why not?"
	DB	NEXT
;	DB	'【%001】：水に入らなきゃなんないじゃないか。'
	DB	"%001:  I'd have to get into the water."
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ........"
	DB	PAUSE
;	DB	'先輩、そんなに水が怖いの？'
	DB	"Are you afraid of water or something?"
	DB	NEXT
;	DB	'【%001】：当たり前だ。'
	DB	"%001:  .....Yes."
	DB	NEXT
;	DB	'【亜希】：・・・そんな事でいばらないでよね。'
	DB	"Aki:  Poor fool."
	DB	FLG,F_COPYI,10,3
	DB	FLG,F_COPYI,11,1
	DW	0000H

M14:		;聞く　明日の予定４
;	DB	'・・・とにかく、明日は釣りだ。'
	DB	"Anyway, we're going fishing tomorrow."
	DW	0000H

M15:		;聞く　誠の唄１
;	DB	'【誠】：・・・か～ずしれ～ぬ・・・'
	DB	"Makoto's still singing."
	DW	0000H

M16:		;聞く　誠の唄２
	DB BUF,B_COPY01
	T_CG "CT14","F","I",35,1
;	DB	'【誠】：・・・てほ～しい～・・・'
	DB	"He's still singing."
	DB	NEXT
;	DB	'【誠】：・・・と。'
	DB	"Makoto:  Thank you."
	DB	NEXT
;	DB	'どうやら、歌い終わったらしい。'
	DB	"I guess he's finished."
	DB	NEXT
;	DB	'みんなの拍手の中、誠は満足そうにギターを外し・・・'
	DB	"Everyone is clapping. Suddenly he hands the guitar to me."
	DB	NEXT
	T_CG "CT14","F",0,35,4
;	DB	'【誠】：・・・ほれ。'
	DB	"Makoto:  Here, %001."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【誠】：お前も、１曲やれよ。'
	DB	"Makoto:  You play something."
	DB	NEXT
;	DB	'【%001】：・・・・・・俺ぇ！？'
	DB	"%001:  I can't play the guitar!"
	DB	NEXT
;	DB	'【誠】：トボけたってムダだぞ。'
	DB	"Makoto:  Don't try to lie."
;	DB	CR
	DB	PAUSE
;	DB	'お前の部屋にあったギター、見逃すとでも思ったか？'
	DB	" I saw the guitar in your room."
	DB	NEXT
	T_CG "CT03","F",0,0,2
	DB	ANI,A_ON,4
;	DB	'【美緒】：%001先輩、ギター弾けるの！？'
	DB	"Mio:  %001, can you really play the guitar?"
	DB	PAUSE
;	DB	'聞きたい聞きたい！！'
	DB	" Oh, please"
	DB	CR
	DB	"play for us!"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .............."
	DB	PAUSE
;	DB	'しょーが無いな、１曲だけだぞ。'
	DB	"Okay, but just one song."
	DB	NEXT
;	DB	'【一同】：ぱちぱちぱちぱち・・・'
	DB	"Everyone:  Yay!"
	DB	NEXT
;	DB	'・・・ぽろろん。'
	DB	"Hmmm...."
	DB	NEXT
;	DB	'俺はチューニングを確認し・・・おもむろに弾き始めた。'
	DB	"I take a moment to tune the instrument, and then start"
	DB	CR
	DB	"to play."
	DB	NEXT
;	DB	'俺が弾ける、唯一の曲を。'
	DB	"I can only play one song, anyway."
	DB	NEXT
;	DB	'【%001】：流れうつろう時の中を　'
	DB	"%001:  I look up, into the sky."
	DB	PAUSE
	DB	CR
;	DB	'さくらがはかなげに舞うよ　'
	DB	"Cherry blossoms are falling like snow."
	DB	PAUSE
	DB	CR
;	DB	'咲いて散ってゆくのは何故？　'
	DB	"Why do they bloom, then die so soon?"
	DB	NEXT
;	DB	'それが生きる事だと人は言う、だけどそれでいいの？　'
	DB	"%001:  Some people say that's what life is all about."
	DB	NEXT
;	DB	'【%001】：さくらの季節は終わらない　'
	DB	"%001:  But the season of the sakura never ends..."
	DB	PAUSE
	DB	CR
;	DB	'愛しくて熱い想いがこの胸にある限り・・・・・・'
	DB	"As long as there is love in the world."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..............."
	DB	PAUSE
;	DB	'ふう。'
	DB	"Well?"
	DB	NEXT
;	DB	'【一同】：・・・・・・'
	DB	"Everyone:  ..............."
	DB	PAUSE
;	DB	'ひゅーひゅひゅー！'
	DB	"YAY!"
	DB	NEXT
;	DB	'【誠】：・・・へ～、やるじゃんか。'
	DB	"Makoto:  You're pretty good!"
	DB	NEXT
;	DB	'【%001】：・・・・・・ま、俺これしか知らないしな。'
	DB	"%001:  Well, it's the only song I know."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT06","F",0,15,5
;	DB	'【亜希】：・・・・・・島崎、ちょっとそれ貸して。'
	DB	"Aki:  Makoto, can I play something?"
	DB	NEXT
;	DB	'【誠】：やだ。'
	DB	"Makoto:  Nope."
	DB	NEXT
;	DB	'【亜希】：どーしてよ？'
	DB	"Aki:  Why not?"
	DB	NEXT
;	DB	'【誠】：壊されたくないから。'
	DB	"Makoto:  I don't want you to break my guitar."
	DB	NEXT
	K_CG "CT06",'D',15,3
;	DB	'【亜希】：・・・なぁあんですってえぇ！？'
	DB	"Aki:  What did you say?"
	DB	NEXT
;	DB	'【美緒】：ち、ちょっと亜希ちゃん！'
	DB	"Mio:  Aki, calm down!"
	DB	NEXT
;	DB	'【%001】：・・・あ～あ～、また始まったよ・・・'
	DB	"%001:  They're going at it again."
	DB	NEXT
;	DB	'・・・・・・こうして、騒がしく夜はふけてゆく・・・・・・'
	DB	"And that was how our night ended."
	DB	NEXT
	B_O B_FADE
	DB	SINARIO,'CS506.OVL',0
	DW	0000H


end