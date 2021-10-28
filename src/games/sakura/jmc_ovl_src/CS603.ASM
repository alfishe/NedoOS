;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０３
;		泳ぎを教わる

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'特訓',0
VV2:	DB	2,	"SWIM",0

;NN1:	DB	1,	'浜辺',0
NN1:	DB	1,	"BEACH",0
;NN2:	DB	2,	'まわり',0
NN2:	DB	2,	"AROUND",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　浜辺
S2:		DW	VV1, NN2,  2, M3, M4, M5		;見る　まわり
S3:		DW	VV2, -1,  3, M6, M7, M8		;泳ぐ練習


;イニシャルメッセージ
M1:
	DB	BGM,2
	BAK_INIT 'AB_40'
	DB	BUF,B_COPY01
	T_CG 'CT01','M',0,10,1
;	DB	'【%001】：鈴子さん・・・手、放さないでよ！'
	DB	"%001:  Reiko, don't let go of my hand!"
	DB	NEXT
;	DB	'【鈴子】：まだこんなに浅いじゃない。'
	DB	"Reiko:  It's shallow here. You can stand up, look."
	DB	NEXT
;	DB	'【%001】：だけど突然大波が来たら・・・'
	DB	"%001:  But what if a huge wave suddenly comes?"
	DB	NEXT
;	DB	'【鈴子】：その時はちゃんと助けてあげるわよ。'
	DB	"Reiko:  If that happens, I'll save you."
	DW	0000H

M2:		;見る　浜辺
;	DB	'浜辺では、美緒ちゃんに中野に吉田たちがボール遊びしてる。'
	DB	"Mio, Meimi and Seia are playing volleyball on the beach."
	DB	NEXT
;	DB	'【%001】：鈴子さん、俺達もボール遊びに入らない？'
	DB	"%001:  Reiko, don't you want to go play volleyball?"
	DB	NEXT
;	DB	'【鈴子】：ホンット、往生際悪いわね～。'
	DB	"Reiko:  Don't be such a baby!"
	DW	0000H


M3:		;見る　まわり
	T_CG1 'CT14','M',0,35,2
	DB	ANI,A_ON,1
;	DB	'【誠】：よぉ、%001。'
	DB	"Makoto:  Yo, %001."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Hm?"
	DB	NEXT
;	DB	'【誠】：少しは泳げるようになったか？'
	DB	"Makoto:  Have you learned to swim at all yet?"
	DB	NEXT
;	DB	'【鈴子】：これから始めるところなの。%001君ったら、逃げてばっかりなんだもの。'
	DB	"Reiko:  We still haven't started. %001 just keeps trying"
	DB	CR
	DB	"to get out of it."
	DB	NEXT
;	DB	'【誠】：へぇ・・・ゼータクな奴。'
	DB	"Makoto:  Don't let him run away, Reiko."
	DB	NEXT
;	DB	'【誠】：ま、がんばれよ。'
	DB	"Makoto:  Good luck, %001."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT01','M',0,10,1
;	DB	'誠は浜辺の方に去っていった。'
	DB	"Makoto went off towards the beach."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;見る　まわり
	T_CG1 'CT04','M','K',35,3
	DB	ANI,A_ON,1
;	DB	'【祥子】：やっほ～っ、%001君！'
	DB	"Shoko:  Hi, %001!"
	DB	NEXT
	T_CG1 'CT01','M','D',10,4
	DB	ANI,A_ON,3
;	DB	'【%001】：わっ！'
	DB	"%001:  Aack!"
	DB	NEXT
;	DB	'いきなり西野さんが水飛沫を上げて現れると、ガバッと抱き付いてきた！'
	DB	"Suddenly Shoko appeared in a splash of water, and grabbed"
	DB	CR
	DB	"me in a hug!" 
	DB	NEXT
;	DB	'【祥子】：ねぇねぇ、二人でぇ、サンオイルの塗りっこしよ、%001君！'
	DB	"Shoko:  Hey, %001, let's go rub suntan lotion on each other!"
	DB	NEXT
;	DB	'【%001】：に、西野さん！みんな見てるよ！'
	DB	"%001:  Um, Shoko, everybody's looking!"
	DB	NEXT
;	DB	'【祥子】：い～じゃない、あたし達ってばぁ、もう他人じゃないわけだしぃ～、せっかく海に来たんだしぃ～、もっとドバーッと開放的になった方がいいかなぁ～、みたいなぁ。'
	DB	"Shoko:  Isn't that okay? I mean, it's not like I'm a"
	DB	CR
	DB	"stranger or anything, you know."
	DB	NEXT
;	DB	'【鈴子】：ちょっと、馬鹿言ってないで離れなさいよ！'
	DB	"Reiko:  Would you stop being an idiot and just leave?"
	DB	NEXT
;	DB	'【祥子】：あんた誰？'
	DB	"Shoko:  Who are you, anyway?"
	DB	NEXT
;	DB	'【鈴子】：・・・'
	DB	"Reiko:  .........?"
	DB	NEXT
;	DB	'【祥子】：な～んちゃって！本気にしたぁ？'
	DB	"Shoko:  I'm just kidding! Don't be so serious all the time!"
	DB	NEXT
;	DB	'【鈴子】：あなたのコンパクトな脳味噌だったらあり得ると思ったわよ。'
	DB	"Reiko:  Can't you see that no one wants you around here?"
	DB	NEXT
	K_CG 'CT04','D',35,5
	DB	ANI,A_ON,1
;	DB	'【祥子】：むっかぁ～！'
	DB	"Shoko:  Well!"
	DB	NEXT
	T_CG1 'CT04','M',0,35,6
	DB	ANI,A_ON,1
;	DB	'【祥子】：そーそー、鈴子ちゃんってばぁ～、泳ぐの超速いのよねぇ～。それってぇ、水の抵抗が少ないからじゃないのぉ～？'
	DB	"Shoko:  Oh, right, Reiko, you're a super-fast swimmer,"
	DB	CR
	DB	"right? Must be because there's so little resistance in"
	DB	CR
	DB	"the water, right?"
	DB	NEXT
;	DB	'【祥子】：つまりぃ、ペ・チャ・パ・イって感じぃ～？'
	DB	"Shoko:  You know, because your chest is so flat?"
	DB	NEXT
;	DB	'【鈴子】：な・・・なんですってぇ！？'
	DB	"Reiko:  What did you say...!?"
	DB	NEXT
;	DB	'【%001】：あわわわ・・・'
	DB	"%001:  Oh man..."
	DB	NEXT
	T_CG1 'CT01','M',0,10,1
	DB	ANI,A_ON,3
;	DB	'【鈴子】：・・・祥子。パッドがずれてるわよ。'
	DB	"Reiko:  Shoko, your padding is slipping."
	DB	NEXT
;	DB	'【祥子】：うっそぉっ！？'
	DB	"Shoko:  No way!?"
	DB	NEXT
;	DB	'あわててムネに手をやる西野さん。'
	DB	"Shoko is really pissed now."
	DB	NEXT
;	DB	'【鈴子】：嘘よ。'
	DB	"Reiko:  Just kidding."
	DB	NEXT
	T_CG1 'CT04','M','D',35,7
	DB	ANI,A_ON,1
;	DB	'【祥子】：・・・あ～っ！騙したわねぇ鈴子ちゃん！'
	DB	"Shoko:  You're so mean, Reiko!"
	DB	NEXT
;	DB	'【鈴子】：あなたのやりそうなことくらいお見通しよ！'
	DB	"Reiko:  I just did the sort of thing you would do!"
	DB	NEXT
;	DB	'【祥子】：ふ、ふ～んだ、今日のところは負けを認めてあげるわ！'
	DB	"Shoko:  Well, I'll let you win today!"
	DB	NEXT
;	DB	'【祥子】：でもでも、あいる・びー・ばっくぅ！って感じぃ～・・・'
	DB	"Shoko:  But I'll get you back......"
	DB	NEXT
;	DB	'西野さんはざぶざぶと海に潜っていった。'
	DB	"Shoko went slinking back towards the sea."
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG 'CT01','M',0,10,1
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;見る　まわり
;	DB	'ふと見ると、白水さんが泳いでるのが見えた。'
	DB	"Suddenly I notice Ruri taking a swim."
	DB	NEXT
;	DB	'（今日も・・・一人なんだ・・・）'
	DB	"Ruri's alone, again."
	DB	NEXT
;	DB	'【鈴子】：ほらほら、よそ見しない。'
	DB	"Reiko:  Hey, are you going to try this, or not?"
	DW	0000H


M6:		;泳ぐ練習
;	DB	'【鈴子】：じゃあ、最初は水に慣れることから始めるわよ。'
	DB	"Reiko:  Okay, first, let's get used to the water."
	DB	NEXT
;	DB	'【鈴子】：息を止めて、水に顔をつけて１０数えて。'
	DB	"Reiko:  Take a breath, put your face in the water and"
	DB	CR
	DB	"count to ten."
	DB	NEXT
;	DB	'【%001】：すぅ～～～～っ'
	DB	"%001:  ....Breathe..."
	DB	NEXT
; 	DB	'俺は目一杯息を吸い込んで、海に顔をつけた。'
	DB	"I took in as much air as I could, and put my face in the"
	DB	CR
	DB	"water."
	DB	NEXT
;	DB	'（１・・・'
	DB	"(1..."
	DB	PAUSE
;	DB	'  ２・・・'
	DB	"2..."
	DB	PAUSE
;	DB	'  ３・・・'
	DB	"3..."
	DB	PAUSE
;	DB	'４５６７８９じゅう！）'
	DB	"456789 Phew!)"
	DB	NEXT
;	DB	'【%001】：ぷぁっ！'
	DB	"%001:  *GASP*"
	DB	NEXT
;	DB	'【鈴子】：ちゃんと１０数えなきゃダメよ。'
	DB	"Reiko:  You really have to count to ten."
	DB	NEXT
;	DB	'【%001】：数えたよ・・・。'
	DB	"%001:  I did."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M7:		;泳ぐ練習
;	DB	'【鈴子】：次は、水の中で息を吐く練習よ。'
	DB	"Reiko:  Next, we practice breathing out underwater."
	DB	NEXT
;	DB	'【鈴子】：水に顔をつけて、静かに息を吐くの。'
	DB	"Reiko:  Put your face in the water, and breathe out gently."
	DB	NEXT
;	DB	'【%001】：すぅ～～～～っ'
	DB	"%001:  ...Breathe..."
	DB	NEXT
;	DB	'俺は目一杯息を吸い込んで、海に顔をつけた。'
	DB	"I took in as much air as I could, and put my face in the"
	DB	CR
	DB	"water."
	DB	NEXT
;	DB	'・・・ぶく・・・ぶくぶくぶく・・・'
	DB	"...Blub...blublublub..."
	DB	NEXT
;	DB	'【%001】：ぷぁっ！'
	DB	"%001:  *BLUB*"
	DB	NEXT
;	DB	'【鈴子】：よく出来ました。'
	DB	"Reiko:  Good job."
	DB	FLG,F_COPYI,3,2
	DW	0000H


M8:		;泳ぐ練習
;	DB	'【鈴子】：さて、いよいよ浮く練習よ。'
	DB	"Reiko:  Okay, now we practice floating."
	DB	NEXT
;	DB	'【%001】：いきなりそんな高度なことすんの！？'
	DB	"%001:  Something so advanced already?!"
	DB	NEXT
	K_CG 'CT01','V',10,2
;	DB	'【鈴子】：・・・まだ初歩の初歩よ。'
	DB	"Reiko:  Trust me, you'll be fine."
	DB	NEXT
	T_CG 'CT01','M',0,10,1
;	DB	'【鈴子】：いい？人の体は浮くように出来てるのよ。小学校で習ったでしょ。'
	DB	"Reiko:  See? the human body can float. I'm sure you"
	DB	CR
	DB	"learned how in elementary school."
	DB	NEXT
;	DB	'【%001】：そーかなぁ・・・'
	DB	"%001:  I guess..."
	DB	NEXT
;	DB	'【鈴子】：沈むのは、余計な力が入ってるからよ。'
	DB	"Reiko:  It's harder to sink than it is to float, you know."
	DB	NEXT
;	DB	'【鈴子】：全身の力を抜いて、手足を伸ばすの。息は止めたままでいいわ。'
	DB	"Reiko:  Relax all your muscles and stretch out your arms"
	DB	CR
	DB	"and legs. You can hold your breath if you like."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・手、放さないで。'
	DB	"%001:  Reiko, don't let go of my hand."
	DB	NEXT
;	DB	'【鈴子】：ダメダメ。「人間は浮く」ってことを体で覚えるのよ。'
	DB	"Reiko:  No, I have to. Don't worry, your body will"
	DB	CR
	DB	"remember to float."
	DB	NEXT
;	DB	'【鈴子】：それに、ここ腰までしか深さないんだから、いくら%001君でも溺れたりしないわよ。'
	DB	"Reiko:  The water only comes up to our waists here, so"
	DB	CR
	DB	"you couldn't drown if you tried."
	DB	NEXT
;	DB	'【鈴子】：さあ！'
	DB	"Reiko:  All right!"
	DB	NEXT
;	DB	'（人間は浮く・・・人間は浮く・・・）'
	DB	"(I will float... I will float...)"
	DB	NEXT
;	DB	'俺は自分に言い聞かせながら、全身を水の中に入れた。'
	DB	"I kept repeating this to myself as I put my whole body in"
	DB	CR
	DB	"the water."
	DB	NEXT
;	DB	'（人間は浮く・・・人間は浮く・・・）'
	DB	"(I will float... I will float...)"
	DB	NEXT
;	DB	'ぎゅっと目をつぶったまま、静かに手足を伸ばす。'
	DB	"With my eyes closed tight, I stretch out my arms and legs."
	DB	NEXT
;	DB	'（浮いてる・・・）'
	DB	"(I'm floating...)"
	DB	NEXT
;	DB	'波に合わせて、自分の体が上下してるのが分かる。'
	DB	"I felt a wave move my body up and down."
	DB	NEXT
;	DB	'【%001】：ぷぁっ'
	DB	"%001:  ...........!!"
	DB	NEXT
;	DB	'ざぶん'
	DB	"*ROAR*"
	DB	NEXT
;	DB	'【%001】：！'
	DB	"%001:  !!"
	DB	NEXT
;	DB	'息をしようと顔を上げた瞬間。ちょうど波が寄せて来て、俺は塩辛い水を飲んでしまった。'
	DB	"Just as I go to take a breath, a wave comes over and I"
	DB	CR
	DB	"swallow a load of salt water."
	DB	NEXT
;	DB	'のどと舌がぴりぴりする！水が器官の方に入ってくる！',CR,'息が出来ない！'
	DB	"....I can't breathe!"
	DB	NEXT
;	DB	'【%001】：ごばっ！げふっ！ごぼごぼごぼ！'
	DB	"%001:  Gulp! Hack! Glug!"
	DB	NEXT
	K_CG 'CT01','I',10,3
;	DB	'【鈴子】：落ち着いて%001君！ここは浅いのよ！'
	DB	"Reiko:  Relax, %001! It's shallow here!"
	DB	NEXT
;	DB	'鈴子さんが何か言ってるけど、パニクッた俺には分からない！'
	DB	"Reiko was saying something, but in my panic I didn't"
	DB	CR
	DB	"understand!"
	DB	NEXT
;	DB	'【%001】：だずげべ！おぼでう！おぼでう！'
	DB	"%001:  Help! I'm drowning! I'm drowning!"
	DB	NEXT
;	DB	'俺は無我夢中でもがきまくった。'
	DB	".....Then I really lost it."
	DB	NEXT
;	DB	'そして、手が触れたものにすがりつこうとして、思いっきり引っ張った。'
	DB	"Then, I started pulling, with all my strength, whatever"
	DB	CR
	DB	"was closest to my hand."
	DB	NEXT
;	DB	'ぐいっ！'
	DB	"*Gag!*"
	DB	NEXT
	DB SINARIO,'CS604.OVL',0
	DW	0000H


end