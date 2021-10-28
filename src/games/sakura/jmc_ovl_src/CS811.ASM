	;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１１
;		体育祭２日目　瞬間、心重ねて

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2
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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'このまま',0
VV1:	DB	1,	'CONTINUE',0
;VV2:	DB	2,	'加速する',0
VV2:	DB	2,	'GO FASTER',0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;このまま
S2:		DW	VV2, -1,  2, M3		;加速する


;イニシャルメッセージ
M1:
        DB	BGM,14
        BAK_INIT "AB_28"
        DB	BUF,B_COPY01
        ;	DB	'・・・そして、体育祭最終種目「二人三脚障害物競争」がやってきた。'
        DB	"........................"
        DB	NEXT
        DB	"The next day."
        DB	NEXT
        DB	"It was finally time for the last event of the Sports Festival,"
        DB	CR
        DB	"the three legged race."
        DB	NEXT
        T_CG "CT14","T",0,0,3
        ;	DB	'【誠】：・・・どーだ%001、調子の方は？'
        DB	"Makoto:  How do you feel for the last event?"
        DB	NEXT
        ;	DB	'【%001】：ぼちぼちだな。'
        DB	"%001:  Just great."
        DB	NEXT
        ;	DB	'【誠】：行けそうか？'
        DB	"Makoto:  Think you can win?"
        DB	NEXT
        ;	DB	'【%001】：身体の調子は悪くねぇ。'
        DB	"%001:  Maybe."
        DB	PAUSE
        ;	DB	'・・・ま、何とかなんだろ。'
        DB	" I feel okay, if that's what you're asking."
        DB	NEXT
        ;	DB	'【誠】：・・・別にお前の調子は心配してねえ。'
        DB	"Makoto:  It's not you I'm worried about."
        DB	PAUSE
        ;	DB	'亜希だよ、亜希。問題なのは。'
        DB	" It's Aki."
        DB	NEXT
        ;	DB	'逆転優勝がかかってんだぜぇ？大丈夫かよあいつと一緒で。'
        DB	"Makoto:  If you don't win this one, our class loses the"
        DB	CR
        DB	"championship!"
        DB	NEXT
        T_CG "CT06","T",'D',30,2
        DB	ANI,A_ON,3
        ;	DB	'【亜希】：あたしがどうかしたって？'
        DB	"Aki:  What were you saying about me?"
        DB	NEXT
        ;	DB	'【誠】：・・・わっ！どっから出て来たっ！？'
        DB	"Makoto:  Wah! Where did you come from?"
        DB	NEXT
        ;	DB	'【亜希】：アンタ馬鹿？向こうからに決まってるでしょ。'
        DB	"Aki:  Are you stupid or something? I was right over there."
        DB	PAUSE,CR
        ;	DB	'そんな事より！あたしがなんだって！？'
        DB	"What were you saying about me?!"
        DB	NEXT
        ;	DB	'【誠】：・・・'
        DB	"Makoto:  I was just worried about whether you could"
        DB	CR
        DB	"keep up or not."
        DB	PAUSE
        ;	DB	'お前がコケるんじゃないかって話だよ！'
        DB	" If you fall, it's all over."
        DB	NEXT
        ;	DB	'【亜希】：・・・なあんですってぇえぇぇ！？'
        DB	"Aki:  What?!?!"
        DB	NEXT,FLASH,2
        ;	DB	'どげっ！'
        DB	"*SMACK*"
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT06","T",'D',30,2
        ;	DB	'【誠】：ぐぎゃっ！？'
        DB	"Makoto:  Ungh...."
        DB	NEXT
        ;	DB	'【亜希】：・・・フン。'
        DB	"Aki:  Geek."
        DB	PAUSE
        ;	DB	'誰に向かって物言ってると思ってんのよ。'
        DB	" Who do you think you're talking to, anyway?"
        DB	NEXT
        ;	DB	'【%001】：・・・あのな・・・'
        DB	"%001:  Excuse me...?"
        DB	NEXT
        ;	DB	'【亜希】：そんな事より、もうすぐ出番よ！こんなところで油売ってないで、さっさと来てちょうだい！'
        DB	"Aki:  Sorry, we don't have time to continue this"
        DB	CR
        DB	"discussion. It's almost time for the race. Let's go."
        DB	NEXT
        ;	DB	'【%001】：へいへい。'
        DB	"%001:  ...Whatever."
        DB	NEXT
        								;ブラックアウト
        B_O B_FADE
        ;	DB	'【スターター】：位置について～'
        DB	"Starter:  On your marks..."
        DB	PAUSE
        ;	DB	'よ～い・・・'
        DB	"Set..."
        DB	NEXT,FLASH,1
        ;	DB	'どぉん！'
        DB	"GO!!"
        DB	NEXT
        							;イベントＣＧ
        E_CG B_WIPE,'AE_032'
        ;	DB	'【%001】：・・・わっせ、わっせ・・・',CR
        ;	DB	'【亜希】：・・・はぁっ、はぁっ・・・'
        DB	"%001:  *pant pant*",CR
        DB	"Aki:  *pant pant*"
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん！もっとスピード上げても大丈夫だ！'
        DB	"%001:  Aki! I'm going to increase my speed! Are you okay?"
        DB	NEXT
        ;	DB	'【亜希】：わかった！'
        DB	"Aki:  Okay!"
        DB	NEXT
        ;	DB	'【%001】：・・・わっせわっせ・・・',CR
        ;	DB	'【亜希】：・・・はぁっはぁっ・・・'
        DB	"%001:  *pant pant*",CR
        DB	"Aki:  *pant pant*"
        DB	NEXT
        ;	DB	'【男子Ｕ】：えっほ、えっほ・・・',CR
        ;	DB	'【女子Ｃ】：っしょ、っしょ・・・'
        DB	"Man:  *pant pant*",CR
        DB	"Woman:  *pant pant*"
        DB	NEXT
        ;	DB	'（・・・誰か追い上げて来てやがる！？）'
        DB	"That other team is ahead of us!"
        DB	NEXT
        ;	DB	'【%001】：・・・亜希ちゃん、１００ｍ何秒で走れる！？'
        DB	"%001:  Aki, how long does it take you to run the 100 meter?"
        DB	NEXT
        ;	DB	'【亜希】：・・・な',PAUSE,'・・・何よっ',PAUSE,'・・・こんな時に',PAUSE,'・・・っ・・・'
        DB	"Aki:  Wha- ",PAUSE,"......What are you- ",PAUSE,"...at a time like this...?"
        DB	NEXT
        ;	DB	'【%001】：いいから！俺は１００ｍ１１秒２で走れる！亜希ちゃんは！？'
        DB	"%001:  Just answer my question! I can do the 100 meter in"
        DB	CR
        DB	"11.2 seconds. How about you?"
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・',PAUSE,'１７秒・・・',PAUSE,'７・・・・・・'
        DB	"Aki:  ............",PAUSE,"17 seconds.......",PAUSE,".............."
        DB	NEXT
        ;	DB	'【%001】：よし！じゃあ亜希ちゃん全速力で走れっ！'
        DB	"%001:  Okay! Run as fast as you can!"
        DB	PAUSE
        ;	DB	'俺が合わせる！１人で走ってるつもりで走るんだ！'
        DB	" I'll match your speed."
        DB	CR
        DB	"Just run normally!"
        DB	NEXT
        ;	DB	'【亜希】：・・・わかった！'
        DB	"Aki:  Okay!"
        DB	NEXT
        ;	DB	'【亜希】：・・・はっはっはっはっ・・・',CR
        ;	DB	'【%001】：・・・ふっふっふっふっ・・・'
        DB	"Aki:  *pant pant pant*",CR
        DB	"%001:  *pant pant pant*"
        DB	NEXT
        ;	DB	'【男子Ｕ】：えっほ、えっほ、えっほ・・・',CR
        ;	DB	'【女子Ｃ】：っしょ、っしょ、っしょ・・・'
        DB	"Man:  *pant pant pant*",CR
        DB	"Woman:  *pant pant pant*"
        DB	NEXT
        ;	DB	'（・・・ち、ちくしょう！差がさらにつまって来やがった！）'
        DB	"Damn! It's not working!"
        DB	NEXT
        ;	DB	'【%001】：・・・亜希ちゃん！'
        DB	"%001:  Aki!"
        DB	NEXT
        ;	DB	'【亜希】：・・・はぁっ・・・はぁっ・・・はぁっ・・・はぁっ・・・'
        DB	"Aki:  *pant pant pant pant*"
        DB	NEXT
        ;	DB	'（・・・ダメだ、亜希ちゃんは目一杯だ。）'
        DB	"No good. She's concentrating on running and can't talk to me."
        DB	NEXT
        ;	DB	'（・・・・・・どうする！？）'
        DB	"What should I do?"
        DW	0000H
        
M2:		;このまま
        ;	DB	'（・・・仕方ない、ここは亜希ちゃんの底力に期待しよう。）'
        DB	"There's nothing else I can do..."
        DB	NEXT
        ;	DB	'【男子Ｕ】：えっほ、えっほ、えっほ、えっほ・・・',CR
        ;	DB	'【女子Ｃ】：っしょ、っしょ、っしょ、っしょ・・・'
        DB	"Man:  *pant pant pant*",CR
        DB	"Woman:  *pant pant pant*"
        DB	NEXT
        ;	DB	'【%001】：うわっ！もう並ばれた！？'
        DB	"%001:  We're almost there!"
        DB	NEXT
        ;	DB	'【男子Ｕ】：・・・えっほ、えっほ、えっほ・・・',CR
        ;	DB	'【女子Ｃ】：・・・っしょ、っしょ、っしょ・・・'
        DB	"Man:  *pant pant pant*",CR
        DB	"Woman:  *pant pant pant*"
        DB	NEXT
        ;	DB	'【%001】：ちくしょう抜かれた！',PAUSE,'くそっ！頑張れ亜希ちゃん！'
        DB	"%001:  Damn, they're ahead of us again! ",PAUSE,"Come on, Aki!"
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・はぁっ・・・・・・はぁっ・・・・・・'
        DB	"Aki:  .......*pant*........*pant*............"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・ダメか！？'
        DB	"%001:  .....Damn!"
        DB	NEXT
        ;	DB	'「・・・ゴーーーーーール！」'
        DB	"Goal!"
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・は・・・・・・っ・・・・・・は・・・・・・っ・・・・・・'
        DB	"Aki:  .....*pant*.................*pant*........"
        DB	NEXT
        ;	DB	'【%001】：・・・１位との差は７ｍってとこだったか・・・'
        DB	"%001:  We were seven meters behind the other team."
        EF_SET 101
        DW	0000H
        
M3:		;加速する
        ;	DB	'（・・・こ～なったら、アレしかねぇ！）'
        DB	"We've got to put on more speed!"
        DB	NEXT
        ;;	DB	'俺は、シンクロしている亜希ちゃんの左足をコントロールする事にした。'
        DB	"Slowly, I moved my legs faster and faster."
        DB	NEXT
        ;	DB	'【男子Ｕ】：えっほ、えっほ、えっほ・・・',CR
        ;	DB	'【女子Ｃ】：っしょ、っしょ、っしょ・・・'
        DB	"Man:  *pant pant pant*",CR
        DB	"Woman:  *pant pant pant*"
        DB	NEXT
        ;	DB	'（・・・よし、このまま逃げ切れば・・・！）'
        DB	"........Just a little more..."
        DB	NEXT
        ;	DB	'【亜希】：・・・はぁ・・・っ・・・はぁ・・・っ・・・'
        DB	"Aki:  .......*pant*..........*pant*.........."
        DB	PAUSE
        ;	DB	'も・・・もうだめ・・・！'
        DB	".......I can't...!"
        DB	NEXT
        ;	DB	'【%001】：しっかりしろ亜希ちゃん！'
        DB	"%001:  Come on, Aki!"
        DB	PAUSE
        ;	DB	'もう少しだ！'
        DB	" Just a little more!"
        DB	NEXT
        ;	DB	'【亜希】：・・・っ・・・は・・・っ・・・！'
        DB	"Aki:  .............*pant*..................*pant*......"
        DB	NEXT
        ;	DB	'（・・・まずい・・・亜希ちゃんの膝が笑い始めた！）'
        DB	"Aki's at her limit!"
        DB	NEXT
        ;	DB	'【男子Ｕ】：えっほ、えっほ、えっほ、えっほ・・・',CR
        ;	DB	'【女子Ｃ】：っしょ、っしょ、っしょ、っしょ・・・'
        DB	"Man:  *pant pant pant*",CR
        DB	"Woman:  *pant pant pant*"
        DB	NEXT
        ;	DB	'【%001】：うわっ！もう来やがった！？'
        DB	"%001:  Damn! Just a little bit more!"
        DB	NEXT
        ;	DB	'【亜希】：・・・っ・・・っ・・・'
        DB	"Aki:  ..................*pant*.............."
        DB	NEXT
        ;	DB	'【%001】：くっ・・・！'
        DB	"%001:  .........................No!"
        DB	NEXT
        ;	DB	'（・・・ダメだ。これ以上スピードを上げたら亜希ちゃんが倒れちまう・・・）'
        DB	"It's no use. If I go any faster, Aki's going to collapse."
        DB	NEXT
        ;	DB	'「・・・ゴーーーーーール！」'
        DB	"Goal!"
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・は・・・・・・っ・・・・・・は・・・・・・っ・・・・・・'
        DB	"Aki:  ..................*pant*........"
        DB	CR
        DB	"...................*pant*....."
        DB	NEXT
        ;	DB	'【%001】：・・・１位との差は３０ｃｍってとこだったか・・・'
        DB	"%001:  .....We were just a few inches behind the other"
        DB	CR
        DB	"team."
        DB	PAUSE
        ;	DB	'惜しかったな。'
        DB	" Damn."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・・・・・・・・'
        DB	"Aki:  ................"
        EF_SET 102
        DW	0000H
        
M_EXIT:		;
        B_O B_FADE
        BAK_INIT "AB_28"
        DB	BUF,B_COPY01
        T_CG "CT14","T","D",0,1
        DB	NEXT
        ;	DB	'【誠】：・・・・・・・・・・・・・・・・'
        DB	"Makoto:  ...................."
        DB	NEXT
        ;	DB	'【%001】：おう、誠。'
        DB	"%001:  Hey, Makoto. "
        DB	PAUSE
        ;	DB	'っておい？'
        DB	"How did we look?"
        DB	NEXT
        ;	DB	'【誠】：・・・・・・・・・'
        DB	"Makoto:  .................."
        DB	NEXT
        ;	DB	'見れば、みんなが怒りの視線を注いでいる。'
        DB	"I could see that everyone was really angry with us."
        DB	PAUSE
        ;	DB	'俺にではなく、横で大の字になっている亜希ちゃんに向かって。'
        DB	" Or rather,"
        DB	CR
        DB	"they were angry with Aki, who had collapsed in the grass."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ............................"
        DB	PAUSE
        ;	DB	'みんな、すまん。'
        DB	"I'm sorry, everyone."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・！'
        DB	"Aki:  ...........................!!"
        DB	NEXT
        T_CG1 "CT14","T",0,0,3
        ;	DB	'【誠】：・・・おい、%001？'
        DB	"Makoto:  %001?"
        DB	NEXT
        ;	DB	'【%001】：やっぱ、掛け持ちは良くねぇよな。俺が亜希ちゃんと練習出来てれば、優勝出来たはずだったのに・・・'
        DB	"%001:  It was stupid of me to try to be in so many events."
        DB	CR
        DB	"If I had had time to practice with Aki..."
        DB	PAUSE
        ;	DB	'すまねぇ、勘弁してくれ。この通りだ。'
        DB	"I'm sorry. Please"
        DB	CR
        DB	"forgive me, everyone."
        DB	NEXT
        ;	DB	'俺が頭を下げると、何故かみんなは困ったような顔になった。'
        DB	"I bowed my head in apology."
        DB	NEXT
        ;	DB	'【誠】：・・・まぁ・・・お前がそう言うんじゃあしょーがねぇな。'
        DB	"Makoto:  ........I guess you're right."
        DB	PAUSE
        ;	DB	'ま、優勝したって文化祭の準備がタダになるってだけだしな。'
        DB	" If we had won, we"
        DB	CR
        DB	"wouldn't have to prepare for the culture festival."
        DB	NEXT
        ;	DB	'【%001】：・・・誠・・・'
        DB	"%001:  Makoto..."
        DB	NEXT
        DB ANI,A_INIT
        DB	BUF,B_COPY01
        T_CG "CT01","T",0,35,3
        ;	DB	'【鈴子】：そうね。それに２位だって立派な成績よ。'
        DB	"Reiko:  It's okay. Second place is really good."
        DB	NEXT
        ;	DB	'【%001】：・・・鈴子さん・・・'
        DB	"%001:  ........Reiko..."
        DB	NEXT
        T_CG "CT02","T",0,0,4
        DB ANI,A_ON,3
        ;	DB	'【清美】：そうですわ。それに２位にも、優遇措置はそれなりにありますのよ。'
        DB	"Kiyomi:  Reiko's right. Second place is nothing to be"
        DB	CR
        DB	"ashamed of."
        DB	NEXT
        ;	DB	'【%001】：・・・新藤さん・・・'
        DB	"%001:  Kiyomi.........."
        DB	NEXT
        T_CG "CT03","T",0,9,5
        DB ANI,A_ON,4
        DB ANI,A_ON,3
        ;	DB	'【美緒】：そうだよ！%001先輩も亜希ちゃんも一生懸命やったんだ！'
        DB	"Mio:  That's right! %001 and Aki ran as hard as they"
        DB	CR
        DB	"could."
        DB	NEXT
        ;	DB	'【%001】：・・・美緒ちゃん・・・'
        DB	"%001:  Mio...."
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT07","T",0,0,6
        ;	DB	'【星愛】：・・・さ、これで体育祭の種目は全て終了しましたわ。'
        DB	"Seia:  Well, the Sports Festival is now officially over!"
        DB	PAUSE,CR
        ;	DB	'・・・良い戦いだったと思います。'
        DB	"...........It was a long battle, but a good one."
        DB	NEXT
        ;	DB	'【%001】：・・・吉田・・・'
        DB	"%001:  .....Seia..."
        DB	NEXT
        T_CG "CT08","T",0,30,7
        DB ANI,A_ON,6
        ;	DB	'【恵依美】：そうそう。',PAUSE,'・・・後はさ、パーッとみんなで祝勝会しましょ！'
        DB	"Meimi:  That's right........",PAUSE," Let's have a big party later."
        DB	NEXT
        ;	DB	'【%001】：・・・中野・・・'
        DB	"%001:  Meimi..."
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT12","T",0,20,8
        ;	DB	'【今日子】：そうね。みんな良くやったわ。'
        DB	"Kyoko:  That's right. Everyone was great!"
        DB	NEXT
        ;	DB	'【%001】：先生！？',PAUSE,'いつの間に来たんですか！？'
        DB	"%001:  Seisei? When did you show up?"
        DB	NEXT
        ;	DB	'【今日子】：さっきからいたわよ。'
        DB	"Kyoko:  I've been here a while."
        DB	NEXT
        ;	DB	'【今日子】：今日はこれで解散よ。みんな疲れたでしょうから、'
        ;	DB	'ゆっくり休んでね。'
        DB	"Kyoko:  Everyone can go home now. I'm sure you're all"
        DB	CR
        DB	"tired. Go home and get some sleep."
        DB	NEXT
        ;	DB	'【誠】：祝勝会はやらないんですか？'
        DB	"Makoto:  Aren't we going to have a party?"
        DB	NEXT
        ;	DB	'【今日子】：やるわよぉ、もちろん。'
        DB	"Kyoko:  Of course we will."
        DB	PAUSE
        ;	DB	'明日は表彰式だけでおしまいだから、午後からはたっぷり時間があるわ。'
        DB	" The only thing scheduled for"
        DB	CR
        DB	"tomorrow is the award ceremony, so there's plenty of time"
        DB	CR
        DB	"in the afternoon for a party."
        DB	NEXT
        ;	DB	'【今日子】：ま、そーゆー事だから。詳しい事は明日决めましょ？'
        DB	"Kyoko:  Okay? Are there any questions?"
        DB	PAUSE
        ;	DB	'じゃあ解散！'
        DB	" No? Then I'll see you"
        DB	CR
        DB	"all tomorrow."
        DB	NEXT
        ;	DB	'【一同】：は～い。'
        DB	"All:  Goodbye, Sensei."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・さ～て、とっとと帰って寝るか。'
        DB	"%001:  Well, guess I'll go home and sleep."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・'
        DB	"Aki:  ..............................."
        DB	NEXT
        ;	DB	'【%001】：ん？亜希ちゃん何か用？'
        DB	"%001:  Mm? Is anything wrong, Aki?"
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・（黙って首を振る）'
        DB	"She just shook her head silently."
        DB	NEXT
        ;	DB	'【%001】：そか。'
        DB	"%001:  Okay."
        DB	NEXT
        ;	DB	'【誠】：おーい%001！帰るぞ！！'
        DB	"Makoto:  Hey, %001! Let's go home!"
        DB	NEXT
        ;	DB	'【%001】：おう、今行く！'
        DB	"%001:  Okay, I'll be right there."
        DB	PAUSE
        ;	DB	'じゃ、また明日な！'
        DB	" Well, see you tomorrow,"
        DB	CR
        DB	"Aki."
        DB	NEXT
        ;	DB	'【亜希】：・・・あ・・・'
        DB	"Aki:  Yeah."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・'
        DB	"Aki:  ..............................."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・%001・・・・・・先輩・・・・・・'
        DB	"Aki:  %001..."
        DB	NEXT
        DB	SINARIO,'CS812.OVL',0
        DW	0000H


end
