;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　９０２
;		クリスマス耐久大宴会

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10
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
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'隠し芸',0
VV2:	DB	2,	'PERFORM',0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	'MAKOTO',0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	'REIKO',0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'KIYOMI',0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	'MIO',0
;NN5:	DB	5,	'瑠璃',0
NN5:	DB	5,	'RURI',0
;NN6:	DB	6,	'亜希',0
NN6:	DB	6,	'AKI',0
;NN7:	DB	7,	'星愛',0
NN7:	DB	7,	'SEIA',0
;NN8:	DB	8,	'恵依美',0
NN8:	DB	8,	'MEIMI',0
;NN9:	DB	9,	'今日子',0
NN9:	DB	9,	'KYOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　誠３
S2:		DW	VV1, NN2,  2, M5, M6, M7		;見る　鈴子３
S3:		DW	VV1, NN3,  3, M8, M9, M10		;見る　清美３
S4:		DW	VV1, NN4,  4, M11, M12, M13		;見る　美緒３
S5:		DW	VV1, NN5,  5, M26, M27, M28		;見る　瑠璃３
S6:		DW	VV1, NN6,  6, M23, M24, M25		;見る　亜希３
S7:		DW	VV1, NN7,  7, M14, M15, M16		;見る　星愛３
S8:		DW	VV1, NN8,  8, M17, M18, M19		;見る　恵依美３
S9:		DW	VV1, NN9,  9, M20, M21, M22		;見る　今日子３
S10:	DW	VV2, -1,  10, M29, M30, M31, M32		;隠し芸４


;イニシャルメッセージ
M1:
	DB	BGM,12
;	DB	'【今日子】：・・・４１番、小林今日子！「熊殺し」バケツ飲みしま～す！'
	DB	"Kyoko:  Kyoko Kobayashi, bottle number forty-one!"
	DB	NEXT
;	DB	'【今日子】：・・・・・・んぐんぐんぐんぐんぐんぐ・・・・・・'
	DB	"Kyoko:  .........*GLUG GLUG*"
	DB	NEXT
;	DB	'【今日子】：・・・・・・っぷぁ～～～～～～っ！'
	DB	"Kyoko:  .............Ah! Delicious!"
	DB	NEXT
;	DB	'【一同】：おお～～～～～～っ。'
	DB	"All:  Oh my god!"
	DB	NEXT
;	DB	'ヤンヤの喝采の中、今日子先生は満足げに座り込み・・・'
	DB	"To the shock of everyone, Kyoko continues to drink."
	DB	NEXT
;	DB	'早速新しい瓶の封を切り、手酌で茶碗に注ぎ始めた。'
	DB	"A new bottle instantly in front of her, she goes to open it."
	E_CG B_SUDA,'AE_044'
	DB	NEXT
;	DB	'（・・・・・・この人、どーゆー肝臓してるんだ？）'
	DB	"She's incredible. You'd think she's have liver problems"
	DB	CR
	DB	"or something..."
	DB	NEXT
;	DB	'・・・・・・待ちに待った１２月２４日、クリスマスイヴ。'
	DB	"It's December 24th, Christmas Eve. The day we all waited"
	DB	CR
	DB	"so long for."
	DB	NEXT
;	DB	'俺達は誰もいない学校に集まり、かれこれ７時間は宴会を続けている。'
	DB	"The Christmas Party has been going on in the empty school"
	DB	CR
	DB	"for seven hours so far."
;	DB C_BLD,C_V_ON,2			;隠し芸　消し
	DW	0000H

M2:		;見る　誠１
;	DB	'又もや、リアルファイトをやっている。'
	DB	"He's fighting with Aki again."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　誠２
;	DB	'あいつは今回、某アニメの物真似やってたな。'
	DB	"This time he's wearing some costume from an anime show."
	DB	NEXT
;	DB	'俺はそのチャンネル普段見てないから良く分からなかったが、'
;	DB	'言われてみりゃあ似てるなあいつ。'
	DB	"I don't watch that show, so I'm not really sure, but he"
	DB	CR
	DB	"looks pretty good to me."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　誠３
;	DB	'・・・しっかし、いつ見てもやられてるなあいつ。'
	DB	"Every time I look at him he's getting his ass kicked by Aki."
	DW	0000H

M5:		;見る　鈴子１
;	DB	'ビール瓶を片手に、手酌でかぱかぱ飲んでいる。'
	DB	"She's pouring herself some beer."
	DB	NEXT
;	DB	'・・・鈴子さんも、酒強くなったなあ。'
	DB	"She's really learned to hold her liquor in the past year."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;見る　鈴子２
;	DB	'鈴子さんは今回、メドレーで思うさま熱唱していた。'
	DB	"Now she's singing."
;	DB	NEXT
;	DB	'往年の名曲から、最新ヒットにいたるまで・・・俺が知ってるだけでも、'
;	DB	'２０曲は唄ったな。'
;	DB	"***"
;	DB	NEXT
;	DB	'・・・・・・いやー、お陰で随分時間的に助かった。'
;	DB	"***"
;	DB	PAUSE
;	DB	'なんたって、８時間もやるんだからなこの宴会。'
;	DB	"***"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M7:		;見る　鈴子３
;	DB	'たぱたぱたぱ'
	DB	"*guzzle guzzle*"
	DB	NEXT
;	DB	'ぐいっ！'
	DB	"*hic*"
	DB	NEXT
;	DB	'大丈夫なのか？あんなに飲んで・・・・・・'
	DB	"Hey, don't drink so much, Reiko!"
	DW	0000H

M8:		;見る　清美１
;	DB	'今日子先生の方を、心配そうに眺めている。'
	DB	"She's looking at Kyoko-sensei with worry on her face."
	DB	NEXT
;	DB	'・・・はっきり言って、先生人間じゃないから心配無用だと思うぞ。'
	DB	"She doesn't need to worry, though. Kyoko-sensei's fine."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M9:		;見る　清美２
;	DB	'新藤さんは今回、結構大規模な手品をやった。'
	DB	"Kiyomi's doing some card tricks now."
;	DB	NEXT
;	DB	'人間切断とか消失とかだったんだけど、あの機材をどっから持って来たのかは謎だ。'
;	DB	"**"
;	DB	NEXT
;	DB	'・・・・・・'
;	DB	".........................................."
;	DB	PAUSE
;	DB	'やっぱり新藤さんは、あなどれん人だ。'
;	DB	"***"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M10:		;見る　清美３
;	DB	'・・・・・・もしかして、見てるの俺か？'
	DB	"Is she looking at me?"
	DW	0000H

M11:		;見る　美緒１
;	DB	'誠達を楽しそ～に見ている。'
	DB	"She's looking at Makoto now."
	DB	NEXT
;	DB	'・・・どっちを応援してるんだ？'
	DB	"I wonder if she's rooting for him?"
	DB	FLG,F_COPYI,4,1
	DW	0000H

M12:		;見る　美緒２
;	DB	'美緒ちゃんは今回、ピンポン玉ドリブルをやった。'
	DB	"Mio's trying to dribble a ping pong ball now."
	DB	NEXT
;	DB	'なんと記録は２１５回！'
	DB	"Her record is 215 times."
	DB	PAUSE
;	DB	'いや～、盛り上がったなぁ。'
	DB	" She looks like she's having fun."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M13:		;見る　美緒３
;	DB	'やっぱり、大した娘だ。'
	DB	"She's good at things like that."
	DW	0000H

M26:		;見る　瑠璃１
;	DB	'隅っこで、中野＋吉田と何やら話している。'
	DB	"She's in the corner, talking to Seia and Meimi."
	DB	NEXT
;	DB	'・・・もう、お別れなのか・・・'
	DB	"So Ruri's really leaving...?"
	DB	FLG,F_COPYI,5,1
	DW	0000H

M27:		;見る　瑠璃２
;	DB	'・・・何と、白水さんも芸をやった。'
	DB	"Ruri even performed something for the class."
	DB	NEXT
;	DB	'といっても、歌を１曲唄っただけだが・・・'
	DB	"Well, she sang one karaoke song."
	DB	PAUSE
;	DB	'何と言うかこう、すごく切ないながらも決して希望を失わない、'
;	DB	'そんな感じの唄だった。'
	DB	" She was pretty good. I'd"
	DB	CR
	DB	"never heard the song before, and it made quite an impression"
	DB	CR
	DB	"on me."
	DB	NEXT
;	DB	'きっとこれから、白水さんの事を思い出す度に、この歌が頭の中で流れ出すだろう。'
	DB	"I'm sure I'll remember the song whenever I think of her"
	DB	CR
	DB	"in the future."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"..............................................."
	DB	NEXT
;	DB	'何時か、想い出になっちまうんだな・・・・・・'
	DB	".....................I can't believe she's leaving."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M28:		;見る　瑠璃３
;	DB	'・・・しかし、中野とああやって話をするなんて・・・'
;	DB	'転校当初は、想像も出来なかったな。'
	DB	"When she first came to this school, she never used to"
	DB	CR
	DB	"talk to the other students like she does now."
	DW	0000H

M23:		;見る　亜希１
;	DB	'相変わらず、誠を格闘技の練習台にしている。'
	DB	"She's using Makoto as a punching bag again, as usual."
	DB	NEXT
;	DB	'・・・気が付くと、あの２人いっつもこ～だな・・・'
	DB	"They're always fighting."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M24:		;見る　亜希２
;	DB	'亜希ちゃんは今回、美緒ちゃんと同じ事をやった。'
	DB	"This time Aki's trying to dribble a ping pong ball better"
	DB	CR
	DB	"than Mio did."
;	DB	NEXT
;	DB	'結構惜しいところまで行ったんだが・・・やっぱり敵わなかった。'
;	DB	"***"
;	DB	NEXT
;	DB	'・・・しっかし、何でもかんでも対抗したがるんだなぁホントに。'
;	DB	"***"
;	DB	NEXT
;;	DB	'やっぱり、いいコンビなんじゃないか？あの２人。'
;	DB	"***"
	DB	FLG,F_COPYI,6,2
	DW	0000H

M25:		;見る　亜希３
;	DB	'・・・毎度毎度、よ～やるわ・・・'
	DB	"She's a tough one."
	DW	0000H

M14:		;見る　星愛１
;	DB	'又もや隅っこで、中野＋白水さんと何やら話している。'
	DB	"She's talking with Meimi and Ruri in the corner."
	DB	NEXT
;	DB	'・・・暴走してくれるなよ・・・'
	DB	"I'm hope she doesn't start drinking."
	DB	FLG,F_COPYI,7,1
	DW	0000H

M15:		;見る　星愛２
;	DB	'吉田は今回一番手で、歌を唄った。'
	DB	"Seia was the first one to get up and sing karaoke tonight."
	DB	NEXT
;	DB	'賛美歌だ、って事だったが・・・声スゲー綺麗なのな。'
	DB	"She was a hymn, and her voice was really beautiful."
;	DB	NEXT
;	DB	'・・・ちなみに、何で一番手かと言うとだ。'
;	DB	"***"
;	DB	PAUSE
;	DB	'もちろん、暴走するきっかけを無くす為だ。'
;	DB	"***"
	DB	FLG,F_COPYI,7,2
	DW	0000H

M16:		;見る　星愛３
;	DB	'・・・このメンツの中で、１番酒癖悪いんじゃね～か？'
	DB	"She's the worst when it comes to drinking."
	DW	0000H

M17:		;見る　恵依美１
;	DB	'今日は大人しく、吉田＋白水さんと何やら話している。'
	DB	"She's talking in the corner with Seia and Ruri."
	DB	NEXT
;	DB	'・・・そ～言えばあいつ、花見の時以来悪酔いしてね～な。'
	DB	"She hasn't gotten drunk since the day we went flower"
	DB	CR
	DB	"viewing."
	DB	FLG,F_COPYI,8,1
	DW	0000H

M18:		;見る　恵依美２
;	DB	'中野は今回、楽器演奏をやった。'
	DB	"Now she's playing koto for everyone."
	DB	NEXT
;	DB	'某正月番組で必ず誰かがやる、台所用品を楽器に見立ててやるアレだ。'
	DB	"I never knew she could play. Such a classical Japanese "
	DB	CR
	DB	"instrument doesn't fit her character all that much."
;	DB	NEXT
;	DB	'・・・ちょっと危なっかしいところもあったが、それなりにこなしてたな。'
;	DB	"***"
;	DB	NEXT
;	DB	'花びら掴む奴は、もうやらね～のかな？'
;	DB	"***"
;	DB	NEXT
;	DB	'・・・・・・・・・'
;	DB	"................................................................"
;	DB	NEXT
;	DB	'良く考えたら、今は冬でここは教室か。'
;	DB	"***"
	DB	FLG,F_COPYI,8,2
	DW	0000H

M19:		;見る　恵依美３
;	DB	'・・・頼むぞ～。吉田が暴走したら、抑えてくれよ～・・・'
	DB	"....if Seia starts drinking, I hope Meimi'll be there to"
	DB	CR
	DB	"calm her down."
	DW	0000H

M20:		;見る　今日子１
;	DB	'実に美味そうに、茶碗をあおっている。'
	DB	"She's drinking sake out of a rice bowl."
	DB	NEXT
;	DB	'・・・なんか最近、こっちの姿のほ～が教壇に立ってる時よりもしっくりくる気がする・・・'
	DB	"I think I've seen that pose more than I've seen her"
	DB	CR
	DB	"teach, this past year."
	DB	FLG,F_COPYI,9,1
	DW	0000H

M21:		;見る　今日子２
;	DB	'さっき芸をやったばかりだ・・・'
	DB	"She just performed for us."
	DB	PAUSE
;	DB	'人間業とは思えない奴を。'
	DB	" It wasn't exactly what you could"
	DB	CR
	DB	"call a performance, however."
	DB	FLG,F_COPYI,9,2
	DW	0000H

M22:		;見る　今日子３
;	DB	'今日子先生と酒。'
	DB	"She loves her sake."
;	DB	NEXT
;	DB	'因数分解したら、カッコで括れるなきっと。'
;	DB	""
	DW	0000H

M29:		;やる　隠し芸１
;	DB	'【%001】：・・・んじゃまぁ、１発やらせて頂きますか。'
	DB	"%001:  Well, guess I'll try my hand..."
	DB	NEXT
;	DB	'【一同】：・・・ひゅ～ひゅ～！'
	DB	"All:  Yay!"
	DB	NEXT
;	DB	'【%001】：・・・さて。取り出したるは、種も仕掛けもない一組のトランプ。'
	DB	"%001:  First, I will use an everyday ordinary deck of cards."
	DB	PAUSE,CR
;	DB	'・・・と、大根。'
	DB	"...And a large daicon radish."
	DB	FLG,F_COPYI,10,1
	DW	0000H

M30:		;やる　隠し芸２
;	DB	'【%001】：まずは、この大根をここに置きます。'
	DB	"%001:  I put the radish here."
	DB	NEXT
;	DB	'【%001】：・・・そして、１歩、２歩、３歩・・・'
	DB	"%001:  Then I walk away, one, two, three..."
	DB	PAUSE
;	DB	'１０歩。'
	DB	" Ten steps away."
	DB	NEXT
;	DB	'【%001】：まぁ大体、５ｍと言ったところですな。'
	DB	"%001:  I'm now about five meters away from the radish."
	DB	FLG,F_COPYI,10,2
	DW	0000H

M31:		;やる　隠し芸３
;	DB	'【%001】：そして、このトランプ。'
	DB	"%001:  I take the cards..."
	DB	PAUSE
;	DB	'・・・このよ～に、よっくシャッフルします。'
	DB	" And shuffle them like this."
	DB	NEXT
;	DB	'【%001】：・・・と。これで準備万端ととのいました。'
	DB	"%001:  I'm now ready to show you my trick."
	DB	FLG,F_COPYI,10,3
	DW	0000H

M32:		;やる　隠し芸４
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	DB	PAUSE
;	DB	'それっ！'
	DB	"Here it is!"
	DB	NEXT
;	DB	'俺はトランプを天井目掛けて放り投げた。'
	DB	"I suddenly threw the cards into the air."
	DB	NEXT
;	DB	'色とりどりのトランプが、花びらのように空に舞う。'
	DB	"The cards fly through the air like sakura petals."
	DB	NEXT
;	DB	'【%001】：・・・はぁ～～～～～～っ・・・'
	DB	"%001:  ........*pant pant*....."
	DB	PAUSE
;	DB	'だだだだだだだだだだだだだだだだだだだだだだだだだだだだだだあっ！'
	DB	" As they fall, I race to get"
	DB	CR
	DB	"the daicon radish, then return."
	DB	NEXT
;	DB	'ずばばばばばばっ！！'	DB	
	DB	"*THUNK!* *THUNK!* *THUNK!*"
	DB	PAUSE,CR
	DB	"*THUNK!* *THUNK!* *THUNK!* *THUNK!* *THUNK!*"
	DB	NEXT
;	DB	'【一同】：・・・・・・・・・・・・・・・'
	DB	"All:  ......................."
	DB	NEXT
;	DB	'【%001】：・・・ふしゅ～～～～～～っ・・・'
	DB	"As everyone gazed in amazement, I swung the daicon around in"
	DB	CR
	DB	"the air, impaling the cards in the surface of the soft"
	DB	CR
	DB	"radish."
	DB	NEXT
	DB	"%001:  .........Well?"
	DB	NEXT
;	DB	'【鈴子】：・・・す',CR
	DB	"Reiko:  .......W",CR
	DB	PAUSE
;	DB	'【清美】：・・・ご',CR
	DB	"Kiyomi:  ......O",CR
	DB	PAUSE
;	DB	'【美緒】：・・・い！！',CR
	DB	"Mio:  .........W!"
	DB	NEXT
;	DB	'【一同】：うぉおぉぉぉぉぉっ！！'
	DB	"All:  Yaaaay!!"
	DB	NEXT
;	DB	'【今日子】：・・・は～・・・見事に刺さってるわね～。'
	DB	"Kyoko:  ....Wow, you caught all the cards in mid-air, before"
	DB	CR
	DB	"they fell!"
	DB	NEXT
;	DB	'【誠】：それだけじゃないっすよセンセー。'
;	DB	'左から順に、きれいに昇順になってます。'
	DB	"Makoto:  That's not all, Sensei! The cards are all arranged"
	DB	CR
	DB	"in order along the daicon."
	DB	PAUSE
;	DB	'・・・流石は我が親友！'
	DB	" That's why he's my best friend!"
	DB	NEXT
;	DB	'【%001】：・・・いやー、受けた受けた。'
	DB	"%001:  Well, I'm glad you liked it."
	DB	NEXT
;	DB	'・・・・・・かくして・・・・・・'
	DB	"And so..."
	DB	NEXT
;	DB	'今年最後の、クラス挙げての大宴会は盛況の内に終わった。'
	DB	"The last party of the year for our class came to an end."
	DB	NEXT
	DB	SINARIO,'CS903.OVL',0
	DW	0000H


end
