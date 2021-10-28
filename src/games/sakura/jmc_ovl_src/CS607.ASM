;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０７
;		島

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
CM3:	DW	VV3,	NN3,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'捜す',0
VV3:	DB	3,	"LOOK FOR",0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	"KIYOMI",0
;NN2:	DB	2,	'生き物',0
NN2:	DB	2,	"CREATURES",0
;NN3:	DB	3,	'ボート',0
NN3:	DB	3,	"BOAT",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　清美
S2:		DW	VV1, NN2,  2, M3, M4, M5, M6, M7, M8		;見る　生き物
S3:		DW	VV2, NN1,  3, M9, M10, M11, M12, M13, M14, M15		;話す　清美
S4:		DW	VV3, NN3,  4, M16		;捜す　ボート


;イニシャルメッセージ
M1:
	DB	BGM,2
	BAK_INIT 'AB_41'
	DB	BUF,B_COPY01
	T_CG 'CT02','M','K',40,1
;	DB	'大体２０分も漕いだ後、俺達は小島に到着した。'
	DB	"After rowing for about twenty minutes, we arrived at the"
	DB	CR
	DB	"island."
	DB	NEXT
;	DB	'【清美】：%001さん、早く早く！'
	DB	"Kiyomi:  %001, hurry, hurry!"
	DB	NEXT
;	DB	'【%001】：ちょっと待った・・・'
	DB	"%001:  Hold on..."
	DB	NEXT
;	DB	'俺はボートのロープを適当な岩に結わえ付けた。'
	DB	"I tied the boat up to a rock nearby."
	DB	NEXT
;	DB	'【%001】：よし、これでい～だろ。'
	DB	"%001:  That should do it."
	DB	NEXT
;	DB	'【清美】：%001さん、こちらにいらして下さい！'
	DB	"Kiyomi:  %001, please come over here!"
	DB	NEXT
;	DB	'【%001】：何かあった？'
	DB	"%001:  What's there?"
	DB	NEXT
;	DB	'【清美】：見て下さい。色々な生き物がおりますわ。'
	DB	"Kiyomi:  Here, look. There are all kinds of creatures here."
	DB C_BLD,C_V_ON,3
	DW	0000H

M2:		;見る　清美
;	DB	'いつもおとなしめの新藤さんが、今日はとても元気なような気がする。'
	DB	"Kiyomi, always so reserved, seems to be in really high"
	DB	CR
	DB	"spirits today."
	DB	NEXT
;	DB	'よっぽど海が好きなんだろう。'
	DB	"She must really like the ocean."
	DW	0000H

M3:		;見る　生き物
;	DB	'水の中の岩場に、けばけばしい色の、ごつごつしたナメクジみたいなのがいた。'
	DB	"On the rocks along the shore, there were all these brightly"
	DB	CR
	DB	"colored, slimy-looking slug things." 
	DB	NEXT
;	DB	'【%001】：気持ちわり～・・・'
	DB	"%001:  Ugh, gross..."
	DB	NEXT
;	DB	'【清美】：アメフラシ、ですわね。つついて見ると面白いですわよ。'
	DB	"Kiyomi:  Those are salt worms. They're interesting to look"
	DB	CR
	DB	"at if you poke at them."
	DB	NEXT
;	DB	'【%001】：気持ち悪いからやだ。'
	DB	"%001:  They're gross!"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;見る　生き物
;	DB	'【%001】：その辺を走り回ってる変な虫はゴキブリの仲間？'
	DB	"%001:  Those weird bugs running around over there, are"
	DB	CR
	DB	"they related to cockroaches?"
	DB	NEXT
;	DB	'【清美】：フナムシは昆虫類ではありませんのよ。ダンゴムシ等のお仲間ですわ。'
	DB	"Kiyomi:  Salt worms aren't insects. They're related to"
	DB	CR
	DB	"taenia echinococcus."
	DB	NEXT
	DB	"%001:  .............I see."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;見る　生き物
;	DB	'【%001】：お、カニだ。'
	DB	"%001:  Oh, there goes a crab."
	DB	NEXT
;	DB	'【清美】：まあ・・・見て下さい%001さん。'
	DB	"Kiyomi:  Look at this, %001."
	DB	NEXT
;	DB	'【%001】：・・・うわ・・・なんかおなかのところが変だぞ。それ、タマゴ？'
	DB	"%001:  ...Whoa...the tummy part looks strange. Those bumps"
	DB	CR
	DB	"protruding from the shell, are they eggs?"
	DB	NEXT
;	DB	'【清美】：フクロムシ、という寄生虫の一種ですわ。'
	DB	"Kiyomi:  That's a barnacle, a type of shellfish parasite"
	DB	CR
	DB	"that attaches itself to a crab."
	DB	NEXT
;	DB	'【%001】：げっ・・・'
	DB	"%001:  Ugh..."
	DB	NEXT
;	DB	'【清美】：でも、貝に寄生するカニもいらっしゃいますから、おあいこかも知れませんわね。'
	DB	"Kiyomi:  But there are also crabs who are parasites on"
	DB	CR
	DB	"shellfish, so I guess it's fair."
	DB	NEXT
;	DB	'【%001】：・・・そういうもんか？'
	DB	"%001:  I've often thought that."
	DB	FLG,F_COPYI,2,3
	DW	0000H


M6:		;見る　生き物
;	DB	'【%001】：このぶよぶよした変なのは？'
	DB	"%001:  What's this strange soft thing?"
	DB	NEXT
;	DB	'【清美】：閉じた状態のイソギンチャクですわね。潮が満ちると、ここも海面下になるという証拠ですわ。'
	DB	"Kiyomi:  That's a 'sazae.' You know, like the famous anime"
	DB	CR
	DB	"show we watched when we were kids."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;見る　生き物
;	DB	'【%001】：こっちの方にも何かいるかな？'
	DB	"%001:  There's probably something over here too..."
	DB	NEXT
	T_CG 'CT02','M','D',40,2
;	DB	'【清美】：%001さん！'
	DB	"Kiyomi:  %001!"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Yes?"
	DB	NEXT
;	DB	'【清美】：ビーチサンダルを履いていない時に岩場を歩く時はお気を付けになって下さい。'
	DB	"Kiyomi:  Be very careful walking over the rocky places"
	DB	CR
	DB	"without shoes on."
	DB	NEXT
;	DB	'【%001】：なんで？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【清美】：ある方が岩場で遊んでいた時に、転んで膝に怪我をしたそうです。'
	DB	"Kiyomi:  Supposedly, there was a person playing on the"
	DB	CR
	DB	"rocks one day. He fell down and hurt his knees."
	DB	NEXT
;	DB	'【清美】：その方が家に帰ってしばらくして、歩くと膝に痛みが走るようになったそうですわ。'
	DB	"Kiyomi:  After returning home, he noticed that his knees"
	DB	CR
	DB	"really hurt when he walked."
	DB	NEXT
;	DB	'【清美】：その痛みは日増しに強くなって、とうとう歩けないほどになった時、その方は救急車を呼んだそうです。'
	DB	"Kiyomi:  It hurt more and more each day, and when he"
	DB	CR
	DB	"couldn't walk anymore, he finally called the ambulance."
	DB	NEXT
;	DB	'【清美】：早速手術をすることになり、そして執刀したお医者さんが見たものは・・・'
	DB	"Kiyomi:  They operated on him right away, and what the"
	DB	CR
	DB	"surgeon saw was..."
	DB	NEXT
;	DB	'【%001】：（ごくっ）'
	DB	"%001:  *GULP*"
	DB	NEXT
;	DB	'【清美】：膝の皿の裏側に、フジツボがびっっっっっしりと！'
	DB	"Kiyomi:  Behind his kneecap, it was crawling with salt worms!"
	DB	NEXT
;	DB	'【%001】：ふ・・・フジツボって・・・あの貝みたいな奴？'
	DB	"%001:  Oh, how gross!"
	DB	NEXT
;	DB	'【清美】：はい・・・実際はエビ等の仲間なのですけど。'
;	DB	"Kiyomi:  Yes, even though they're actually related"
;	DB	CR
;	DB	"to eels."
;	DB	NEXT
;	DB	'【清美】：ですから、裸足で岩場を歩いている時に、貝殻で足の裏を切ったりすると・・・'
	DB	"Kiyomi:  So, when you're walking barefoot on the rocks,"
	DB	CR
	DB	"and you cut your foot on a shell....."
	DB	NEXT
;	DB	'【%001】：そ、それ以上は言わんでいいって！'
	DB	"%001:  Ugh! Don't tell me any more!"
	DB	NEXT
	T_CG 'CT02','M','V',40,3
;	DB	'【清美】：%001さんのかかとやくるぶしの骨に無数のフジツボがプツプツ・・・プツプツ・・・プツプツ・・・'
	DB	"Kiyomi:  There'll be thousands of them, gnawing on your"
	DB	CR
	DB	"bones, sucking your blood, and...!!"
	DB	NEXT
;	DB	'【%001】：やぁぁめぇぇてぇぇぇーっ！'
	DB	"%001:  Yeeeeeeeagh!!!"
	DB	NEXT
	T_CG 'CT02','M','K',40,1
;	DB	'【清美】：ですから、岩場を歩く時は十分お気をつけになって下さいね。'
	DB	"Kiyomi:  So, be careful when you're walking on the rocks,"
	DB	CR
	DB	"okay?"
	DB	NEXT
;	DB	'【%001】：はい・・・'
	DB	"%001:  Okay, I will...."
	DB	FLG,F_COPYI,2,5
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;見る　生き物
;	DB	'【%001】：しかし新藤さん、詳しいんだな。'
	DB	"%001:  You sure know a lot about this stuff, Kiyomi."
	DB	NEXT
;	DB	'【清美】：そうでしょうか？このくらいは、小学校の理科の時間に習いませんでしたか？'
	DB	"Kiyomi:  Really? We learned all that in elementary school"
	DB	CR
	DB	"science class. Didn't you?"
	DB	NEXT
;	DB	'【%001】：う～ん・・・覚えてないな。'
	DB	"%001:  Hmmm, I don't remember."
	DW	0000H

M9:		;話す　清美
;	DB	'【清美】：海は生命の源泉・・・生き物の宝庫ですわね。'
	DB	"Kiyomi:  The ocean is the origin of life, a treasure"
	DB	CR
	DB	"chest of living things."
	DW	0000H

M10:		;話す　清美
;	DB	'【清美】：%001さん。'
	DB	"Kiyomi:  %001?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Hm?"
	DB	NEXT
	DB	FLASH,2
;	DB	'ぱしゃっ'
	DB	"*SPLASH*"
	DB	NEXT
;	DB	'【%001】：うぷっ！'
;	DB	"%001:  Bleah!"
;	DB	NEXT
;	DB	'いきなり顔に水を引っ掛けられて、俺の口の中に塩辛さが拡がる。'
	DB	"Suddenly my face was all wet. I could taste salt water"
	DB	CR
	DB	"in my mouth."
	DB	NEXT
;	DB	'【%001】：な、何すんだいきなり！？'
	DB	"%001:  Hey, what was that for?"
	DB	NEXT
	E_CG B_SUDA,'AE_025'
;	DB	'【清美】：ほほほ・・・捕まえられるものなら捕まえてごらんなさい！'
	DB	"Kiyomi:  Hohoho... Catch me if you can!"
	DB	NEXT
;	DB	'（何か・・・妙に浮かれてないか？新藤さん。）'
	DB	"Kiyomi sure is being unusually jolly."
	DB	NEXT
;	DB	'【%001】：よぉし、つかまえてやるぞぉ！'
	DB	"%001:  All right, I'll get you!"
	DB	NEXT
;	DB	'【清美】：ほほほほ・・・'
	DB	"Kiyomi:  Hohoho...."
	DB	NEXT
;	DB	'本気で走ればあっと言う間に捕まえられるんだが、俺は新藤さんに付き合うことにした。もちろん、新藤さんも本気で逃げてない。'
	DB	"If I really ran, I could have caught her in a second, but I"
	DB	CR
	DB	"played along. Of course, Kiyomi wasn't really trying"
	DB	CR
	DB	"to escape anyway."
	DB	NEXT
;	DB	'俺達は水飛沫をあげながら、波打ち際を走り回った。'
	DB	"Splashing each other, we ran around by the water."
	DB	FLG,F_COPYI,3,2
	DW	0000H


M11:		;話す　清美
	DB	BUF,B_COPY01
	T_CG 'CT02','M',0,10,4
;	DB	'【清美】：はぁ・・・はぁ・・・'
	DB	"Kiyomi:  *pant*....*pant*...."
	DB	NEXT
;	DB	'走り疲れたのか、新藤さんは立ち止まった。'
	DB	"Kiyomi stopped running. Maybe she was tired."
	DB	NEXT
;	DB	'【%001】：つぅーかまえたっ！'
	DB	"%001:  Gotcha!"
	DB	NEXT
;	DB	'俺はそっと新藤さんの肩に触れた。'
	DB	"I gently touched her shoulder."
	DB	NEXT
;	DB	'【%001】：新藤さん・・・今日は何かハイになってねぇか？'
	DB	"%001:  Kiyomi......you're really cheerful today..."
	DB	NEXT
;	DB	'【清美】：そう・・・思いますか？'
	DB	"Kiyomi:  You think so...?"
	DB	NEXT
;	DB	'【%001】：ああ。いつもはもっとこう、のんびりしてるだろ？'
	DB	"%001:  Yeah. You're usually much more, well, serious."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M12:		;話す　清美
;	DB	'【清美】：わたくしだって、思い切り体を動かしたくなることもありますのよ。'
	DB	"Kiyomi:  Well, sometimes I want to run around a lot, too."
	DB	NEXT
;	DB	'【%001】：そか。よっぽど好きなんだな、海が。'
	DB	"%001:  Oh. Well, you really seem to like the ocean a lot."
	DB	NEXT
;	DB	'【清美】：・・・そうかもしれませんわね。'
	DB	"Kiyomi:  I guess so."
	DB	FLG,F_COPYI,3,4
	DW	0000H

M13:		;話す　清美
;	DB	'【%001】：俺・・・小さい頃にさ。'
	DB	"%001:  When I was little..."
	DB	NEXT
;	DB	'【清美】：はい・・・'
	DB	"Kiyomi:  Yes...."
	DB	NEXT
;	DB	'【%001】：家族で、海に来た事があったんだ。'
	DB	"%001:  I went to the ocean with my family once."
	DB	NEXT
;	DB	'【%001】：確か、もう泳ぐシーズンは過ぎてた。どこかに行った帰りに寄ったんだと思う。'
	DB	"%001:  The season for swimming was already past. We stopped"
	DB	CR
	DB	"there on the way back from somewhere."
	DB	NEXT
;	DB	'【%001】：それで、こんな風に、波打ち際で砂の城なんか造ってた。そしたら・・・'
	DB	"%001:  We were on the beach, just like this, making a"
	DB	CR
	DB	"sand castle, and then....."
	DB	NEXT
	B_O B_TATE
;	DB	'ざっぷーん！'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'【%001】：！？'
	DB	"%001:  ?!"
	DB	NEXT
;	DB	'ごぼごぼごぼ・・・'
	DB	"*GURGLE*....."
	DB	NEXT
;	DB	'【清美】：%001さん！'
	DB	"Kiyomi:  %001!"
	DB	NEXT
;	DB	'がしっ'
	DB	"*GULP*"
	DB	NEXT
;	DB	'【%001】：たったすけて！おぼれる！'
	DB	"%001:  Help! I'm drowning!"
	DB	NEXT
;	DB	'【清美】：%001さん、落ち着いて下さい。'
	DB	"Kiyomi:  %001, calm down."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','M',0,10,4
;	DB	'【%001】：・・・あれ？'
	DB	"%001:  ....Eh?"
	DB	NEXT
;	DB	'落ち着いて見ると、俺は砂の上でジタバタもがいてた。'
	DB	"When I calmed down, I was thrashing around on the sand."
	DB	NEXT
;	DB	'新藤さんがとっさに俺の足を掴んでくれたおかげで、波にさらわれずにすんだらしい。'
	DB	"Because Kiyomi had grabbed my leg, I didn't get swept away"
	DB	CR
	DB	"by the wave."
	DB	NEXT
;	DB	'【清美】：こんな風に、波にさらわれたのですね。'
	DB	"Kiyomi:  A wave came up at you when you were young?"
	DB	NEXT
;	DB	'【%001】：あー。で、あん時は誰も足を掴んでくれなかったから、そのまま海に引きずり込まれてな・・・'
	DB	"%001:  Yes. But that time, there was no one holding my"
	DB	CR
	DB	"leg, and I was whisked out into the ocean..."
	DB	NEXT
;	DB	'【%001】：それで、泳ぐのが怖くなったのかも知れねぇ。',CR,'ホントのとこは俺にも分からんがな。'
	DB	"%001:  That's probably when I got scared of swimming."
	DB	CR
	DB	"But not even I really know why."
	DB	NEXT
;	DB	'【清美】：もしわたくしがその場におりましたら、きっと今みたいに%001さんをお助け致しましたのに・・・。'
	DB	"Kiyomi:  Well, if I had been there, I certainly would"
	DB	CR
	DB	"have saved you like I did just now."
	DB	FLG,F_COPYI,3,5
	DW	0000H


M14:		;話す　清美
;	DB	'【清美】：・・・静かですわね・・・'
	DB	"Kiyomi:  It's so quiet here."
	DB	NEXT
;	DB	'【%001】：俺達以外、誰もいねーのかな。'
	DB	"%001:  There's no one here but us."
	DB	NEXT
;	DB	'【清美】：その様ですわね。'
	DB	"Kiyomi:  Yes."
	DB	FLG,F_COPYI,3,6
	DW	0000H

M15:		;話す　清美
;	DB	'【%001】：・・・そろそろ、戻らねぇか？'
	DB	"%001:  .....Shall we go back?"
	DB	NEXT
;	DB	'【清美】：え・・・まだよろしいじゃありませんか。'
	DB	"Kiyomi:  Can we stay just a little longer?"
	DB	NEXT
;	DB	'【%001】：でも、俺と二人だけじゃ退屈だろ？'
	DB	"%001:  Aren't you bored being here with just me?"
	DB	NEXT
	T_CG 'CT02','M','I',10,5
;	DB	'【清美】：%001さんは・・・退屈なさっているのですか？'
	DB	"Kiyomi:  Are you bored, %001?"
	DB	NEXT
;	DB	'【%001】：そうじゃねぇけど・・・どうせなら、みんなで来た方がよかったかな、って。'
	DB	"%001:  No, no...but it would have been better if everyone"
	DB	CR
	DB	"had come."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ......................."
	DB	NEXT
;	DB	'【清美】：では、戻りましょう。'
	DB	"Kiyomi:  Well, let's go back then."
	DB	NEXT
;	DB	'新藤さんはすっくと立ち上がると、そのままどんどん先に歩いていった。'
	DB	"Kiyomi got up abruptly, and stomped off ahead of me."
	DB	NEXT
;	DB	'俺も急いで後を追った。'
	DB	"I had to hurry to catch up."
	DB	NEXT
	B_O B_TATE
	DB	BUF,B_COPY01
	T_CG 'CT02','M',0,40,4
;	DB	'【清美】：・・・%001さん。ボートはどちらでしょうか？'
	DB	"Kiyomi:  %001, where's the boat?"
	DB	NEXT
;	DB	'【%001】：え？そこの岩場に・・・'
	DB	"%001:  Huh? I tied it to that rock over there..."
	DB	NEXT
;	DB	'【%001】：・・・ない・・・'
	DB	"%001:  It's not there..."
	DB	NEXT
;	DB	'血の気がひいて行くのが自分でもわかった。'
	DB	"Even I could tell that the blood was rising to my face."
	DB C_BLD,C_V_OFF,3	;捜す　出し
	DB C_BLD,C_V_ON,1	;その他　消し
	DB C_BLD,C_V_ON,2	;その他　消し
	DW	0000H

M16:		;捜す　ボート
;	DB	'【%001】：どこだ・・・どこに行ったんだ？！'
	DB	"%001:  Where did it go?"
	DB	NEXT
;	DB	'俺はその辺を走り回ったが、ボートの姿は影も形もなかった。'
	DB	"I went running around, but saw no sign of the boat."
	DB	NEXT
;	DB	'【%001】：ど・・・どうしよう・・・'
	DB	"%001:  W- What'll we do?"
	DB	NEXT
;	DB	'【清美】：困りましたわね。'
	DB	"Kiyomi:  Looks like we're in trouble."
	DB	NEXT
;	DB	'【%001】：・・・新藤さん、泳げたっけ？'
	DB	"%001:  Kiyomi, you can swim, right?"
	DB	NEXT
;	DB	'【清美】：はい、このくらいの距離でしたら・・・'
	DB	"Kiyomi:  Yes, I can probably make it that far..."
	DB	NEXT
;	DB	'【%001】：頼む！誰か呼んで来てくれ！'
	DB	"%001:  Please! Won't you go and get some help?"
	DB	NEXT
;	DB	'【清美】：・・・ですが、%001さんを一人で残して行くわけにも参りませんわ。'
	DB	"Kiyomi:  But I won't go if I have to leave you here alone."
	DB	NEXT
;	DB	'【清美】：このまま二人で待っていましょう。その内、どなたかいらっしゃると思いますわ。'
	DB	"Kiyomi:  Let's just wait here. Someone is sure to come by."
	DB	NEXT
;	DB	'【%001】：そんなに都合よく行くかな・・・'
	DB	"%001:  I guess someone will see us here..."
	DB	NEXT
	DB G_FLG,G_COPYF,159,159	;瑠璃攻略可能
	DB	FLG,F_JEQ,159
	DW	REI
	DB SINARIO,'CS608_F.OVL',0
	DW	0000H

REI:
	DB SINARIO,'CS608_E.OVL',0
	DW	0000H


end
