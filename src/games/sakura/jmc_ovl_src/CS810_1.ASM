
;	DB	';	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１０＿１
;		体育祭一日目

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5, CM6
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1
CM6:	DW	VV6,	-1

;VV1:	DB	1,	'バレーボール',0
VV1:	DB	1,	'VOLLEYBALL',0
;VV2:	DB	2,	'野球',0
VV2:	DB	2,	'BASEBALL',0
;VV3:	DB	3,	'サッカー',0
VV3:	DB	3,	'SOCCER',0
;VV4:	DB	4,	'借り物競走',0
VV4:	DB	4,	'TREASURE HUNT',0
;VV5:	DB	5,	'男子４００ｍ',0
VV5:	DB	5,	"MENS' 400 M",0
;VV6:	DB	6,	'障害物競走',0
VV6:	DB	6,	'SURVIVAL CONTEST',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3		;バレーボール
S2:		DW	VV2, -1,  2, M4		;野球
S3:		DW	VV3, -1,  3, M5		;サッカー
S4:		DW	VV4, -1,  4, M6		;借り物競走
S5:		DW	VV5, -1,  5, M7		;男子４００ｍ
S6:		DW	VV6, -1,  6, M8		;障害物競走


;イニシャルメッセージ
M1:
	DB	BGM,14
	BAK_INIT "AB_28"
	DB	BUF,B_COPY01
	T_CG "CT08","T",0,30,8
;	DB	'【恵依美】：よーし、はりきっていこーかぁ、%001！'
	DB	"Meimi:  Let's go, %001!"
	DB	NEXT
;	DB	'【%001】：え？なんだよ、中野？'
	DB	"%001:  Um, okay. Let's go."
	DB	NEXT
	T_CG "CT07","T",0,0,7
	DB ANI,A_ON,1
;	DB	'【星愛】：今日は、わたくしと清美さんと恵依美ちゃんとで、可能な限り%001さんのサポートをいたしますわ。'
	DB	"Seia:  Kiyomi, Meimi and I will be cheering for you all "
	DB	CR
	DB	"the way today, %001."
	DB	NEXT
	T_CG "CT02","T",0,15,2
	DB ANI,A_ON,2
	DB ANI,A_ON,1
;	DB	'【清美】：ご用の際は、何なりとお申し付け下さい。'
	DB	"Kiyomi:  If you need anything, please let us know."
	DB	NEXT
;	DB	'【%001】：・・・新藤さん・・・中野・・・吉田・・・'
	DB	"%001:  Thanks, all of you."
	DB	NEXT
;	DB	'【恵依美】：なあに？まったく、ボケてるヒマなんかないわよ！'
	DB	"Meimi:  Why are you standing there thanking us? We have"
	DB	CR
	DB	"to get moving!"
	DB	NEXT
;	DB	'【%001】：・・・は！言ってくれるぜ！俺より先にダウンすんじゃねーぞ！'
	DB	"%001:  Okay!"
	DB	NEXT
;	DB	'【恵依美】：のーぞむところよ！さ、行くわよ！'
	DB	"Meimi:  Remember what I told you about spiking too early!"
	DB	NEXT
;	DB	'【星愛】：まずはバレーボールですわ。'
	DB	"Seia:  Volleyball is the first event."
	B_O B_FADE
	DB	C_BLD,C_V_ON,2
	DB	C_BLD,C_V_ON,3
	DB	C_BLD,C_V_ON,4
	DB	C_BLD,C_V_ON,5
	DB	C_BLD,C_V_ON,6
	DW	0000H

M2:		;バレーボール
	E_CG B_SUDA,'AB_28'
;	DB	'【%001】：ほおうりゃあ！必殺、百八式Ａクイック！'
	DB	"%001:  Got it!"
	DB	NEXT
;	DB	'ばしぃ！'
	DB	"*BASH*"
	DB	NEXT
;	DB	'白いボールがすごい勢いで敵陣に飛び込む。その瞬間、俺達バレーボールＡチームの勝利が確定した。'
	DB	"The white volleyball sails with incredible speed at our"
	DB	CR
	DB	"opponent's side. Our team smells victory."
	DB	NEXT
;	DB	'【%001】：・・・やべ、手加減すんの忘れた。'
	DB	"%001:  We should have gone easier on them."
	DB	NEXT
	T_CG1 "CT08","T",0,30,8
;	DB	'【恵依美】：いい、いい！さ、次は野球よ！'
	DB	"Meimi:  Great! Okay, next is baseball."
;	DB	NEXT
;	DB	'【%001】：へいへい。'
	DB	C_BLD,C_V_ON,1
	DB	C_BLD,C_V_OFF,2
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;バレーボール
	E_CG B_SUDA,'AB_28'
;	DB	'ばしっ！どきゃ！'
	DB	"*HIT* *SPIKE*"
	DB	NEXT
;	DB	'【%001】：うーし、終わった終わったァ！'
	DB	"%001:  Okay, that's overwith."
	DB	NEXT
	T_CG1 "CT08","T",0,30,8
;	DB	'【恵依美】：%001！つぎ、男子４００ｍよ！'
	DB	"Meimi:  %001! Now you have to run the mens's 400 meter!"
	DB	NEXT
;	DB	'【%001】：よっしゃ！'
	DB	"%001:  Okay!"
	DB	C_BLD,C_V_ON,1
	DB	C_BLD,C_V_OFF,5
	DW	0000H

M4:		;野球
	E_CG B_SUDA,'AB_11_1'
;	DB	'【%001】：・・・干さんの球より、更に遅い！'
	DB	"%001:  Come on, pitcher. See if you can get it over the"
	DB	CR
	DB	"plate."
	DB	NEXT
;	DB	'かっきーーーん！'
	DB	"*SMACK*"
	DB	NEXT
;	DB	'白い打球が青い空とお友達になり、場外へとランデブーを敢行する。'
	DB	"The white ball is lost in the blue sky, until it finally"
	DB	CR
	DB	"touches down outside of the baseball stadium."
	DB	NEXT
;	DB	'その瞬間・・・いや、すでにこの回に入った時点で、俺達野球Ａチームの勝利は確定していた。'
	DB	"It was then that our team knew that victory was ours."
	DB	NEXT
;	DB	'【%001】：やばいな・・・目立ちすぎると敬遠されねえか？'
	DB	"%001:  I didn't know I had it in me..."
	DB	NEXT
	T_CG1 "CT02","T",0,15,2
;	DB	'【清美】：それは困りますわねえ。さ、%001さん、次はサッカーですわ。'
	DB	"Kiyomi:  Okay, %001. The next event is soccer."
	DB	NEXT
;	DB	'【%001】：よっしゃ、行こうか！'
	DB	"%001:  Okay!"
	DB	C_BLD,C_V_ON,2
	DB	C_BLD,C_V_OFF,3
	DW	0000H

M5:		;サッカー
	E_CG B_SUDA,'AB_14_1'
;	DB	'よし、絶妙のパスがきた！流石は御々空唾差先輩！'
	DB	"I had the ball! Just a little further!"
	DB	NEXT
;	DB	'【%001】：喰らえぇ！'
	DB	"%001:  Eat this!"
	DB	NEXT
;	DB	'俺の本気のシュートに、キーパーは一歩も動けない。'
	DB	"I shoot the ball with all my power. The goalie just"
	DB	CR
	DB	"watches the ball go by."
	DB	NEXT
;	DB	'そして、試合終了のホイッスルが鳴った。'
	DB	"Then the final whistle blew."
	DB	NEXT
;	DB	'俺達サッカーＡチームは余裕の勝利を収めた。'
	DB	"Our side had won."
	DB	NEXT
	T_CG1 "CT07","T",0,0,7
;	DB	'【星愛】：まあ、すごいですわね！ところで、そろそろ『凄絶！校内探索借り物競走！』が始まりますわよ。'
	DB	"Seia:  You're great, %001! Now it's time for the treasure"
	DB	CR
	DB	"hunt."
	DB	NEXT
;	DB	'【%001】：よし、行くぞっ！'
	DB	"%001:  Okay!"
	DB	C_BLD,C_V_ON,3
	DB	C_BLD,C_V_OFF,4
	DW	0000H

M6:		;借り物競走
	E_CG B_SUDA,'AB_28'
	T_CG1 "CT03","T",0,0,3
;	DB	'【美緒】：すごーい、%001先輩、１等だ～！'
	DB	"Mio:  That's great, %001. You got first place!"
	DB	NEXT
;	DB	'【%001】：はぁ、はぁ、はぁ・・・まあね。しっかし、なんだって借り物競走に『ベレッタ９２Ｆ』とかあるんだ？'
	DB	"%001:  *pant pant*"
	DB	PAUSE
	DB	" But why would they have included a"
	DB	CR
	DB	"Beretta 92F in the list?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","T",0,15,2
;	DB	'【清美】：まあ、大変ですわね。ところで、そろそろバレーボールの２回戦が始まりますわよ？'
	DB	"Kiyomi:  Well, it's time for the second round of volleyball."
	DB	CR
	DB	"Are you ready?"
	DB	NEXT
;	DB	'【%001】：よしっ、行こーか。'
	DB	"%001:  Okay!"
	DB	C_BLD,C_V_ON,4
	DB	C_BLD,C_V_OFF,1
	DW	0000H

M7:		;男子４００ｍ
;	DB	'どだだだだ・・・'
	DB	"............."
	DB	NEXT
;	DB	'【%001】：ぜぇ、ぜぇ、ぜぇ・・・次なんだっ！'
	DB	"%001:  *pant pant*  What's next?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT07","T",0,0,7
;	DB	'【星愛】：『風雲障害物競走・サバイバル編』ですわ！'
	DB	"Seia:  The survival contest."
	DB	NEXT
;	DB	'【%001】：なんだそりゃ！？'
	DB	"%001:  What the hell is that?"
	DB	NEXT
;	DB	'【星愛】：さあ？たぶん、普通の障害物競走だと思うのですが・・・'
	DB	"Seia:  Just like it sounds. I guess you have to be the"
	DB	CR
	DB	"last one on your team to survive."
	DB	NEXT
;	DB	'【%001】：いや、きっと何かある！'
	DB	"%001:  I don't like the sound of that!"
	DB	C_BLD,C_V_ON,5
	DB	C_BLD,C_V_OFF,6
	DW	0000H

M8:		;障害物競走
;	DB	'身体のあちこちがひりひりと痛む。'
	DB	"..........................."
	DB	NEXT
	DB	"My body really hurts."
	DB	NEXT
;	DB	'競技の最中、どこに隱れていたのかサバ研の連中がエアガンを乱射してきたからだ。'
	DB	"Who would have thought that the survival club would attack"
	DB	CR
	DB	"everyone with their air guns."
	DB	NEXT
;	DB	'・・・サバイバルってのは、こーゆーことか。'
	DB	"So that's what a survival contest is."
	DB	NEXT
;	DB	'【%001】：いてててて・・・まさか撃たれるとは思わなかった。'
	DB	"%001:  This sucks. Who would have thought I'd be shot"
	DB	CR
	DB	"today?"
	DB	PAUSE
;	DB	'・・・誠の奴、姿が見えねぇと思ったら、あんな事してたのか。'
	DB	" Makoto's such a geek."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","T",0,15,2
;	DB	'【清美】：大丈夫ですか？'
	DB	"Kiyomi:  Are you alright?"
	DB	NEXT
;	DB	'【%001】：ああ、まあね。んで、次は何？'
	DB	"%001:  I'm fine. What event is next?"
	DB	NEXT
;	DB	'【清美】：次は、『弱肉強食！パン食い競走！』ですわ。'
	DB	"Kiyomi:  The next is the doughnut eating contest."
	DB	NEXT
;	DB	'【%001】：ええい、タイトルから縁起でもねえ。'
	DB	"%001:  Ugh, that doesn't sound like something I want to"
	DB	CR
	DB	"be doing right now..."
	DB	NEXT
;	DB	'【清美】：・・・お気をつけて・・・！'
	DB	"Kiyomi:  Enjoy yourself!"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".................................."
	DB	NEXT
;	DB	'【%001】：次！'
	DB	"%001:  What's next?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT08","T",0,30,8
;	DB	'【恵依美】：野球の２回戦よ！'
	DB	"Meimi:  Field hockey!"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".................................."
	DB	NEXT
;	DB	'【%001】：ほい、次！'
	DB	"%001:  Okay, next!"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT07","T",0,0,7
;	DB	'【星愛】：サッカーですわね。'
	DB	"Seia:  Pole vaulting!"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".................................."
	DB	NEXT
;	DB	'【%001】：で？'
	DB	"%001:  Next?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","T",0,15,2
;	DB	'【清美】：次は『激走！どじょうすくい競走！』ですわ。'
	DB	"Kiyomi:  The next one is the greased fish competition."
	DB	NEXT
;	DB	'【%001】：・・・なんじゃそりゃあ！？'
	DB	"%001:  More weird events..."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"..................................."
	DB	NEXT
	B_O B_SUDA
;	DB	'こうして、気がつくと一日目の競技は全て終了し、俺は無惨な屍を晒していた。'
	DB	"......Finally, the first day of the sports festival was"
	DB	CR
	DB	"over. I was still alive."
	DB	NEXT
;	DB	'・・・俺が出場する競技の大部分は今日に集中していたからこんな事になってしまったが、まあ、そのぶん明日は若干楽だと思っておこう。'
	DB	"Most of the sports I agreed to be in were today. Tomorrow"
	DB	CR
	DB	"should be easier."
	DB	NEXT
;	DB	'・・・早く家に帰って眠りたい・・・'
	DB	"...I want to get home and sleep."
	DB	NEXT
	DB	SINARIO,'CS811.OVL',0
	DW	0000H


end
