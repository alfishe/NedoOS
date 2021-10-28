;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｂ０３
;		さらば師匠！マスターホンダラ暁に散る
        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5
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
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	NN2,NN3,NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'対戦',0
VV2:	DB	2,	'CHALLENGE',0
;VV3:	DB	3,	'攻撃',0
VV3:	DB	3,	'ATTACK',0

;NN1:	DB	1,	'人だかり',0
NN1:	DB	1,	'CROWD',0
;NN2:	DB	2,	'通常技',0
NN2:	DB	2,	'NORMAL ATTACK',0
;NN3:	DB	3,	'必殺技',0
NN3:	DB	3,	'SPECIAL ATTACK',0
;NN4:	DB	4,	'１０連コンボ',0
NN4:	DB	4,	'10X COMBO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　人だかり
S2:		DW	VV2, -1,  2, M4		;対戦
S3:		DW	VV3, NN2,  3, M5		;攻撃　通常技
S4:		DW	VV3, NN3,  4, M6		;攻撃　必殺技
S5:		DW	VV3, NN4,  5, M7		;攻撃　１０連コンボ


;イニシャルメッセージ
M1:
        DB	BGM,4
        BAK_INIT "AB_25"
        B_P1 B_SUDA
        ;	DB	'俺はふらっと「バベル」に立ち寄った。'
        DB	"I'm in the the game center Babel."
        DB	NEXT
        ;	DB	'かーちゃんに買い物を頼まれたんだけど、後回しでも構わないだろう。'
        DB	"Mom wants me to pick up some things for her at the store,"
        DB	CR
        DB	"but I'll do that later."
        DB	NEXT
        ;	DB	'「バベル」に足を踏み入れた俺は、妙に人が集まっている場所があることに気付いた。'
        DB	"The moment I step into the place, I notice people gathered"
        DB	CR
        DB	"in one corner of the game center."
        DB	NEXT
        ;	DB	'あの辺は・・・確か、『バーチャル忍者・弍』が置いてある辺りだ。'
        DB	"That's where Virtual Fighter II is."
        DB	NEXT
        ;	DB	'まさか、またこの間の子が来てるのかな。'
        DB	"I wonder if that woman is back."
        DB	C_BLD,C_V_ON,2		;対戦　消す
        DB	C_BLD,C_V_ON,3		;攻撃　消す
        DW	0000H
        
M2:		;見る　人だかり
        ;	DB	'誰かのプレイを見ているようだ。'
        DB	"I guess I'll go see who's over there."
        DB	NEXT
        ;	DB	'ときどき、感嘆の声が漏れる。'
        DB	"The crowd is really loud."
        DB	NEXT
        ;	DB	'・・・相当の腕のプレーヤーらしい。'
        DB	"Whoever's playing must be really good."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　人だかり
        ;	DB	'ここにいても誰がプレイしているのか分からないな。'
        DB	"I can't see who's playing from here."
        DB	NEXT
        ;	DB	'好奇心に駆られた俺は人だかりに近づいていった。そんな俺の耳に、ゲーマー達の感嘆の声が届いた。'
        DB	"I move closer."
        DB	NEXT
        ;	DB	'【ゲーマーＡ】うおおっ、また１００人抜きだ。'
        DB	"Gamer A:  Wow, she's cleared one hundred opponents again."
        DB	NEXT
        ;	DB	'【ゲーマーＢ】やっぱりオレ達じゃ、日本一には勝てないか・・・'
        DB	"Gamer B:  She's great. We didn't stand a chance against"
        DB	CR
        DB	"the best player in all Japan."
        DB	NEXT
        ;	DB	'１００人抜き？日本一？'
        DB	"One hundred? The best in Japan?"
        DB	NEXT
        ;	DB	'・・・あの子だ！'
        DB	"It must be that woman!"
        DB	NEXT
        ;	DB	'・・・ふっふっふ、２回もあの子に破れ、人知れず修行を重ねて幾星霜・・・'
        DB	"She beat me twice before, but this time I'm ready for her."
        DB	NEXT
        ;	DB	'こんなに早く３度目のリベンジの機会が巡ってくるとは！'
        DB	"The third time pays for all!"
        DB	C_BLD,C_V_OFF,2		;対戦　出し
        DB	C_BLD,C_V_ON,1		;見る　消し
        DW	0000H
        
M4:		;対戦
        ;	DB	'俺は、ポケットの中の小銭を握りしめた。'
        DB	"I took a coin out of my pocket."
        DB	NEXT
        ;	DB	'人の群をかき分けて前に出ると、コンピュータ相手に派手な必殺技を决めている、見覚えのある顔を見つけた。'
        DB	"I make my way through the crowd, until she comes into"
        DB	CR
        DB	"view."
        E_CG B_SUDA,"AE_045"
        DB	NEXT
        ;	DB	'やっぱりあの子だ。よぅし、修行の成果、見せてやる。'
        DB	"I knew it was her. It was time to put my months of"
        DB	CR
        DB	"training to the test."
        DB	NEXT
        ;	DB	'・・・な～んて、修行って言っても、ただゲームしてただけなんだけどね。'
        DB	"Well, all I really did was play the game like I always"
        DB	CR
        DB	"do."
        DB	NEXT
        ;	DB	'コインを入れ、スタートボタンを押すと、画面にでかでかと『挑戦者有り！』の文字が踊った。そして、キャラ選択画面に移る。'
        DB	"I put the coin in, and press the start button."
        DB	NEXT
        DB	"A CHALLENGER HAS APPEARED displayed on the screen."
        DB	NEXT
        ;	DB	'俺はもちろんサイゾウ、そして相手はホンダラだ。'
        DB	"I choose Saizo. She chooses Hondala."
        DB	NEXT
        ;	DB	'ホンダラの恐さは、そのスピードと技の隙の少なさ、そして攻撃のバリエーションの広さにある。'
        DB	"Hondala has relatively low speed, but many different"
        DB	CR
        DB	"attack variations."
        DB	NEXT
        ;	DB	'だが、その分、パワーは若干落ちる。'
        DB	"But his power is not as good as it could be."
        DB	NEXT
        ;	DB	'となれば、取るべき戦法は一つ。ガードを堅めつつ小技で牽制し、隙を突いて必殺技を叩き込む。'
        DB	"There's one way for me to win. Keep my guard up and wait"
        DB	CR
        DB	"for the right time to use my special attacks."
        DB	NEXT
        ;	DB	'・・・言うのは簡単だけど、実際やるとなると・・・あ、いけね。'
        DB	".....It's easy to say that, but somehow more difficult"
        DB	CR
        DB	"to put it into action..... Uh-oh!"
        DB	NEXT
        ;	DB	'ガッ、ゴン、ビシッ、ビシッ、・・・ピシッ！「一本！」。'
        DB	"*BAT* *PUNCH* *KICK* *CRASH*"
        DB	NEXT
        ;	DB	'・・・俺のサイゾウは宙に浮いたまま１０連コンボをきっちりいただき、体力切れでＫ．Ｏ．になった上、なおかつ場外へと消えていった・・・'
        DB	"She got the first point already!"
        DB	NEXT
        ;	DB	'ええい、まだ一本取られただけだ。今度こそは・・・'
        DB	"There's still one more to go, though...."
        DB	NEXT
        ;	DB	'ゴッ、ゴン、ゴン、ガキッ。'
        DB	"*THOCK* *THOCK* *ZEEK*"
        DB	NEXT
        ;	DB	'ようし、いい調子だ。'
        DB	"Good, very good..."
        DB	NEXT
        ;	DB	'今だ、１０連・・・'
        DB	"And now! 10X attack!"
        DB	NEXT
        ;	DB	'すかっ。'
        DB	"*THOCK*"
        DB	NEXT
        ;	DB	'だあぁ、きっかけをはずしてしまった！'
        DB	"My timing was off!"
        DB	NEXT
        ;	DB	'ガッ、ゴン、ビシッ、ベキッ、・・・ピシッ'
        DB	"*BIT* *BAT* *PUNCH*"
        DB	NEXT
        ;	DB	'・・・あああ、為す術もなく叩きのめされていく俺のサイゾウ・・・'
        DB	"....My attack having failed, I took damage from Hondala's"
        DB	CR
        DB	"punches. Then..."
        DB	NEXT
        ;	DB	'「死斗襲雷！」'
        DB	"Dragon Death Strike!"
        DB	NEXT
        ;	DB	'ゴゴゴガガンッッ！「勝負有り！ホンダラ！」。'
        DB	"*FOOM* 'Hondala is victorious!'"
        DB	NEXT
        ;	DB	'・・・挙げ句に、必殺技までいただいちゃったよ・・・'
        DB	".....She ate me for breakfast."
        DB	NEXT
        ;	DB	'・・・ええい、もう一度だ。'
        DB	"I won't give up, though! I'll get her this time!"
        DB	NEXT
        ;	DB	'俺は懲りずに小銭を取り出した。'
        DB	"I put another into the machine."
        DB	NEXT
        ;	DB	'ゴッ、ゴン、ゴン、ガキッ。'
        DB	"*THOCK* *THOCK* *ZEEK*"
        DB	NEXT
        ;	DB	'ようし、いい調子だ。'
        DB	"Good, good..."
        DB	NEXT
        ;	DB	'ガッ、バキッ。'
        DB	"*ZEEK* *PUNCH*"
        DB	NEXT
        ;	DB	'よし、隙みっけ。'
        DB	"Now's my chance!"
        DB	C_BLD,C_V_ON,2		;対戦　消す
        DB	C_BLD,C_V_OFF,3		;攻撃　出し
        DW	0000H
        
M5:		;攻撃　通常技
        ;	DB	'バキッ。'
        DB	"*KICK*"
        DB	NEXT
        ;	DB	'よ～し、ダウンしたな・・・喰らえッ！大ダウン攻撃ッ！'
        DB	"Good, now to take it up. Eat this!"
        DB	NEXT
        ;	DB	'天高くジャンプするサイゾウ。勝利は近い。'
        DB	"Saizo jumps into the air. I can feel victory near."
        DB	NEXT
        ;	DB	'ドンッ。'
        DB	"*KICK*"
        DB	NEXT
        ;	DB	'あれ・・・？はずした？'
        DB	"What? Oh no!"
        DB	NEXT
        ;	DB	'「死斗襲雷！」。'
        DB	"Dragon Death Strike!"
        DB	NEXT
        ;	DB	'ゴゴゴガガンッ！「一本！」。'
        DB	"*FOOM* 'Hondala is victorious!'"
        DB	NEXT
        ;	DB	'【女の子】：ダメだよ、あそこで「大ダウン」やっちゃあ。'
        DB	"Woman:  That was the wrong move! You should have done a"
        DB	CR
        DB	"leg sweep there."
        DB	NEXT
        ;	DB	'・・・・・・'
        DB	".........................................................."
        DB	NEXT
        ;	DB	'その後何回か彼女と対戦したが、結局戦績はこの間と大して変わることはなかった・・・'
        DB	"I continued the battle, but in the end, I didn't do much"
        DB	CR
        DB	"better than last time."
        DB	NEXT
        ;	DB	'【%001】：はあ、もういいや。さっさと用事済ませよーっと。'
        DB	"%001:  I give up. I guess I'll get that shopping for"
        DB	CR
        DB	"Mom done now."
        DB	NEXT
        DB	FLG,F_JR
        DW	M_EXIT
        DW	0000H
        
M6:		;攻撃　必殺技
        ;	DB	'「獣閃崩壊拳！」'
        DB	"Lightning Destruction Fist!"
        DB	NEXT
        ;	DB	'ゴガガガガンッ！「一本！」。'
        DB	"*FOOM* 'Saizo is victorious!'"
        DB	NEXT
        ;	DB	'よっしゃあっ、一本取ったぞ。'
        DB	"Yes! I got one point!"
        DB	NEXT
        ;	DB	'【女の子】：へぇ、なかなかやるね。んじゃ、本気出そうかな。'
        DB	"Woman:  Not bad at all. I guess I'd better start playing"
        DB	CR
        DB	"for real."
        DB	NEXT
        ;	DB	'え゛っ！？'
        DB	"What?!"
        DB	NEXT
        ;	DB	'・・・結局、俺は本気の彼女の前に手も足もなく、トータルでの勝ち数はこの一本だけだった・・・'
        DB	".....In the end, I only won the one match against her."
        DB	NEXT
        ;	DB	'【%001】：はあ、もういいや。さっさと用事済ませよーっと。'
        DB	"%001:  I give up. I guess I'll get that shopping for"
        DB	CR
        DB	"Mom done now."
        DB	NEXT
        DB	FLG,F_JR
        DW	M_EXIT
        DW	0000H
        
        
M7:		;攻撃　１０連コンボ
        ;	DB	'ゴン、ガッ、ガッ、ガッ、ピシッ、・・・バキッ！『一本！』。'
        DB	"Ten Times Strike! *FOOM* 'Saizo is victorious!'"
        DB	NEXT
        ;	DB	'よっしゃあっ、一本取ったぞ。'
        DB	"Good, I got one point!"
        DB	NEXT
        ;	DB	'【女の子】：あちゃあ、やられちゃったよ。次は負けないぞ！'
        DB	"Woman:  Oh, that was a good one. But I won't lose to you again."
        DB	NEXT
        ;	DB	'【%001】：こっちこそ、敗ける気はないぞ。'
        DB	"%001:  I won't, either!"
        DB	NEXT
        ;	DB	'・・・その後も何回か好勝負を繰り返したが、結局、わずかな差で今回も彼女の勝ちに終わった。'
        DB	"....We continued playing, and in the end, she had only "
        DB	CR
        DB	"a slight lead on me. "
        DB	NEXT
        ;	DB	'【女の子】：すごいね、ボクと互角に戦えるなんて。'
        DB	"Woman:  You were great. I've never met anyone as good as"
        DB	CR
        DB	"you."
        DB	NEXT
        ;	DB	'【%001】：そ、そう？いや～、運が良かっただけさ。'
        DB	"%001:  No, I was just lucky..."
        DB	NEXT
        ;	DB	'とかいいながら、周りのゲーマー共の羨ましそうな視線を浴びて、俺はすっかり浮かれていた。'
        DB	"That's what I said, but I was aware of the gazes of all"
        DB	CR
        DB	"the gamers all around me, and loving it."
        DB	NEXT
        ;	DB	'【女の子】：ううん、あれは間違いなくキミの実力だよ。どう？もう一勝負？'
        DB	"Woman:  No, that was your true still. Do you want to try one"
        DB	CR
        DB	"more challenge?"
        DB	NEXT
        ;	DB	'【%001】：え？ああ、いいよ・・・'
        DB	"%001:  Huh?  Yeah, I guess."
        DB	NEXT
        ;	DB	'う～ん、『バーチャル忍者・弍』日本一にほめてもらえるなんて、やっぱり俺は淒いのかも・・・ところで、今何時だろ？'
        DB	"It's no small thing to receive praise from the number "
        DB	CR
        DB	"one Virtual Ninja II player in Japan."
        DB	NEXT
        ;	DB	'げっ、やばい、家を出てからもう２時間以上も経ってる！'
        DB	"Opps! Look at the time. It's over two hours since I left"
        DB	CR
        DB	"home."
        DB	NEXT
        ;	DB	'・・・早く家に帰らんと、「悪い子、メッ、のキス」とかワケのわからんことされそうだ・・・'
        DB	"If I don't get home soon, my mother will try to kiss me..."
        DB	CR
        DB	"Don't ask me why."
        DB	NEXT
        ;	DB	'【%001】：あ・・・悪ィ。俺、用事があったんだ。'
        DB	"%001:  I'm sorry, I sort of have to get home."
        DB	NEXT
        ;	DB	'【女の子】：そうか・・・じゃ、また今度、ボクと戦おう！'
        DB	"Woman:  Oh. Well, we'll play again next time."
        DB	NEXT
        ;	DB	'【%001】：ああ、今度は勝つぜ。'
        DB	"%001:  Okay. I'll beat you next time for sure!"
        DB	NEXT
        ;	DB	'俺は軽く手を振ると、「バベル」を後にした。'
        DB	"I waved goodbye to her and left Babel."
        DB	NEXT
        DB	FLG,F_JR
        DW	M_EXIT
        DW	0000H
        
M_EXIT:
        ;	DB	'（あ・・・そーいえばかーちゃんに買い物頼まれてたっけ。）'
        DB	"Oh, I just remembered, Mom wanted"
        DB	CR
        DB	"me to get some things for her from the store."
        DB	NEXT
        ;	DB	'俺はメモを取り出した。'
        DB	"I took out the shopping list."
        DB	NEXT
        ;	DB	'（何なに・・・豚ロース２００ｇ、ネギ、ピーマン・・・は売り切れって事にして、人参、牛乳・・・洗剤に画鋲にセロハンテープにポリバケツ？）'
        DB	"Let's see... Pork chops, onions, green peppers, milk,"
        DB	CR
        DB	"all the usual things."
        DB	NEXT
        ;	DB	'（・・・ゼロワンデパートにでも行くか・・・）'
        DB	"I go into the Zero One department store."
        DB	NEXT
        DB	SINARIO,'CSB04.OVL',0
        DW	0000H


end
