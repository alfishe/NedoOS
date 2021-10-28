;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０９＿２
;		対決・テニス部

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,NN2,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"話す",0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	"知らない",0
VV3:	DB	3,	"I DON'T KNOW",0
;VV4:	DB	4,	"知ってる",0
VV4:	DB	4,	"I KNOW",0
;VV5:	DB	5,	"勝負",0
VV5:	DB	5,	"CHALLENGE",0

;NN1:	DB	1,	"美緒",0
NN1:	DB	1,	"MIO",0
;NN2:	DB	2,	"今日子",0
NN2:	DB	2,	"KYOKO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M2_B		;見る　美緒
S2:		DW	VV1, NN2,  2, M3		;見る　今日子
S3:		DW	VV2, NN1,  3, M4, M5		;話す　美緒
S4:		DW	VV2, NN2,  4, M6		;話す　今日子
S5:		DW	VV3, -1,  5, M7		;知らない
S6:		DW	VV4, -1,  6, M8		;知ってる
S7:		DW	VV5, -1,  7, M9		;勝負


;イニシャルメッセージ
M1:
	DB	BGM,22
	BAK_INIT "AB_12_1"
	DB	BUF,B_COPY01
	TU_CG "CT03","T","K",0,2
	T_CG "CT12","T",0,30,1
	DB	ANI,A_ON,2
;	DB	"テニスコートに来た。"
	DB	"I arrived at the tennis courts."
	DB	NEXT
;	DB	"【%001】：それで・・・どんな勝負をするわけ？"
	DB	"%001:  Well, what kind of challenge do you have waiting"
	DB	CR
	DB	"for me?"
	DB	NEXT
;	DB	"【美緒】：あたしと、３セットマッチで勝負だ！"
	DB	"Mio:  You have to go three matches with me!"
	DB	NEXT
;	DB	"【今日子】：%001君、テニスのルールは知ってる？"
	DB	"Kyoko:  %001, do you know the rules?"
	DB	G_FLG,G_COPYI,102,1
	DB C_BLD,C_V_ON,1		;見る　消す
	DB C_BLD,C_V_ON,2		;話す　消す
	DB C_BLD,C_V_ON,5		;勝負　消す
	DW	0000H

M2:		;見る　美緒
;	DB	"真剣な表情で俺を見つめている。"
	DB	"She's smiling, but I can tell she's thinking about winning."
	DW	0000H

M2_B:		;見る　美緒
;	DB	"テニスコートに大の字にひっくり返ってる。"
	DB	"She's fallen down flat on the court."
	DW	0000H

M3:		;見る　今日子
;	DB	"審判席に腰掛けて、俺達を見下ろしている。"
	DB	"She's up in the judges chair."
	DW	0000H

M4:		;話す　美緒
;	DB	"【美緒】：先輩・・・あたしが勝ったら、テニス部に入ってもらうから。"
	DB	"Mio:  If I win, you have to join the tennis club."
	DW	0000H

M5:		;話す　美緒
;	DB	"【美緒】：はぁ、はぁ、はぁ、・・・"
	DB	"Mio:  ....*pant*....pant*...."
	DB	NEXT
;	DB	"美緒ちゃんは仰向けに転がって、苦しそうにあえいでいる。"
	DB	"Mio's breathing hard."
	DB	NEXT
;	DB	"【%001】：な。体力的に無理だって言っただろ・・・。"
	DB	"%001:  Hey, I told you you weren't strong enough for it."
	DB	NEXT
;	DB	"【今日子】：%001君・・・美緒ちゃんは、選手権で優勝したほどの腕なのよ。"
	DB	"Kiyomi:  %001, Mio is a top-class player, you know."
	DB	NEXT
;	DB	"【%001】：・・・美緒ちゃんが？"
	DB	"%001:  She is?"
	DB	NEXT
;	DB	"【今日子】：中等部で相手になる子がいないから、高等部に混じって練習してるのよ、彼女。"
	DB	"Kyoko:  Yes. You didn't beat her with stamina. You're"
	DB	CR
	DB	"either an experienced player or a born natural."
	DB	NEXT
;	DB	"（・・・またやっちまった・・・）"
	DB	"I did it again."
	DB	NEXT
	T_CG "CT03","T","I",0,4
	DB ANI,A_ON,1
;	DB	"【美緒】：%001先輩・・・"
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	"【%001】：・・・"
	DB	"%001:  Uh..."
	DB	NEXT
;	DB	"【%001】：とにかく、俺の勝ちだから。"
	DB	"%001:  Anyway, I won."
	DB	NEXT
;	DB	"俺は逃げるようにその場を去った。"
	DB	"I made my escape from that place."
	DB	G_FLG,G_COPYF,50,101		;野球部にいったか？
	DB	FLG,F_JEQ,50
	DW	J0
	DB	FLG,F_JR
	DW	J1
	DW	0000H
	;フラグジャンプ

M6:		;話す　今日子
;	DB	"【%001】：でも、いくら俺がトーシロだからって、中等部でしかも女子の美緒ちゃんが相手じゃ、勝負にならねーと思うぞ、体力的に。"
	DB	"%001:  This isn't fair. Mio may be good, but she's got no"
	DB	CR
	DB	"chance against me. I'll beat her with stamina, because she's"
	DB	CR
	DB	"female."
	DB	NEXT
;	DB	"【今日子】：あら・・・ずいぶん自身ありげなのね。"
	DB	"Kyoko:  You seem pretty self-confident."
	DB	NEXT
;	DB	"【今日子】：いいわ美緒ちゃん、本気でやりなさい。"
	DB	"Kyoko:  Why don't you show him how much stamina you've"
	DB	CR
	DB	"got, Mio?"
	DW	0000H

M7:		;知らない
;	DB	"【%001】：俺、今日でラケット握るの二回目なんだぜ。"
	DB	"%001:  This is only the second time I picked up a"
	DB	CR
	DB	"racket."
	DB	NEXT
;	DB	"【今日子】：じゃ、簡単に説明するわね。"
	DB	"Kyoko:  Then I will give you a short explanation."
	DB	NEXT
;	DB	"【今日子】：相手が自分のコート内にボールを打ち返せなかったら１ポイント。先に４ポイント取った方が１ゲーム取ったことになるの。"
	DB	"Kyoko:  Hit the ball into the opponent's court. If you get"
	DB	CR
	DB	"four points against you and you loose that match."
	DB	NEXT
;	DB	"【今日子】：で、先に６ゲーム取った方がそのセットを取ったことになるの。"
	DB	"Kyoko:  Whoever takes six games wins the set."
	DB	NEXT
;	DB	"【今日子】：３セットマッチだから、先に２セット取った方が勝ちよ。"
	DB	"Kyoko:  It's a three-set match. So whoever gets two sets first"
	DB	CR
	DB	"is the winner."
	DB	NEXT
;	DB	"【%001】：・・・とにかく、相手のコート内にボールを打ち返し続けてりゃ勝ちなんだな。"
	DB	"%001:  So if you just keep hitting the ball in the"
	DB	CR
	DB	"opponent's court, you win, right?"
	DB	NEXT
;	DB	"【今日子】：まあそういうこと。"
	DB	"Kyoko:  That's one way to put it."
	DB	BUF,B_COPY01
	T_CG "CT03","T",0,15,3
	DB C_BLD,C_V_OFF,1
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DB C_BLD,C_V_OFF,5
	DW	0000H

M8:		;知ってる
;	DB	"【%001】：マンガとかで見た事あるから一応。"
	DB	"%001:  I've seen it in comic books."
	DB	NEXT
;	DB	"【今日子】：マンガねえ・・・ま、いいわ。"
	DB	"Kyoko:  In comics?"
	DB	NEXT
;	DB	"【%001】：とにかく、相手のコート内にボールを打ち返し続けてりゃ勝ちなんだろ？"
	DB	"%001:  So if you just keep hitting the ball in the"
	DB	CR
	DB	"opponent's court, you win, right?"
	DB	NEXT
;	DB	"【今日子】：まあそういうこと。"
	DB	"Kyoko:  That's one way to put it."
	DB	BUF,B_COPY01
	T_CG "CT03","T",0,15,3
	DB C_BLD,C_V_OFF,1
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DB C_BLD,C_V_OFF,5
	DW	0000H

M9:		;勝負
;	DB	"【今日子】：じゃあ、サーブ権は%001君からね。"
	DB	"Kyoko:  You serve first, %001."
	DB	NEXT
;	DB	"【%001】：俺？"
	DB	"%001:  Me?"
	DB	NEXT
;	DB	"【%001】：じゃあ・・・"
	DB	"%001:  Okay..."
	DB	NEXT
;	DB	"俺は見よう見まねでサーブを打ってみた。"
	DB	"I serve without really looking at the ball."
	DB	NEXT
;	DB	"バシッ！"
	DB	"*HIT*"
	DB	NEXT
;	DB	"ひゅーん・・・"
	DB	"Zoom...."
	DB	NEXT
;	DB	"【%001】：やった、ホームランだ！"
	DB	"%001:  Alright! A home run."
	DB	NEXT
;	DB	"【今日子】：フォールト！相手コートに打たなきゃダメって言ったでしょ。"
	DB	"Kyoko:  Fault! Didn't I say to hit it in your opponent's"
	DB	CR
	DB	"court?"
	DB	NEXT
;	DB	"【今日子】：さ、もう一回サーブして！"
	DB	"Kyoko:  Serve again."
	DB	NEXT
;	DB	"【%001】：それじゃ・・・今度は優しく・・・"
	DB	"%001:  Okay. This time I'll hit it gently."
	DB	NEXT
;	DB	"ぽくっ"
	DB	"*HIT*"
	DB	PAUSE
;	DB	"・・・ぱさっ"
	DB	" *smack*"
	DB	NEXT
;	DB	"今度は、ボールがネットに引っ掛かってしまった。"
	DB	"This time the ball got stuck in the net."
	DB	NEXT
;	DB	"【今日子】：ダブルフォールト。０－１５。"
	DB	"Kyoko:  Double fault. 0-15."
	DB	NEXT
;	DB	"（・・・タイミングが難しいな・・・）"
	DB	".....This is pretty hard."
	DB	NEXT
;	DB	"【%001】：・・・はっ！"
	DB	"%001:  .....*swing*"
	DB	NEXT
;	DB	"パカッ"
	DB	"*HIT*"
	DB	NEXT
;	DB	"今度はきっちり相手コート目掛けて飛んでいった。"
	DB	"This time the ball flew straight into the other court."
	DB	NEXT
;	DB	"パシッ！"
	DB	"*WHACK*"
	DB	NEXT
;	DB	"すかさず美緒ちゃんが打ち返し、ボールは低い放物線を描いて俺の目の前でワンバウンドする。"
	DB	"Mio effortly hit the ball back. It drew a low arc over the"
	DB	CR
	DB	"net and bounced in front of me."
	DB	NEXT
;	DB	"【%001】：りゃっ！"
	DB	"%001:  What the...?"
	DB	NEXT
	E_CG B_NORM,"AE_042"
;	DB	"バシッ"
	DB	"*BAT*"
	DB	NEXT
;	DB	"狙い通り、ボールは美緒ちゃん側のコートの隅に突き刺さった。"
	DB	"The ball flew just as I aimed and landed in the corner of"
	DB	CR
	DB	"Mio's court."
	DB	NEXT
;	DB	"【今日子】：アウト！"
	DB	"Kyoko:  Out!"
	DB	NEXT
;	DB	"【%001】：先生、今のはちゃんと入ってたぜ。"
	DB	"%001:  Come on! That was in!"
	DB	NEXT
;	DB	"【今日子】：そっか、%001君は知らないのね。"
	DB	"Kyoko:  Didn't you know?"
	DB	NEXT
;	DB	"【今日子】：シングルスの時は、その内側の線がコートの境界線なのよ。"
	DB	"Kyoko:  In singles, the boundry is the inner line, not the"
	DB	CR
	DB	"outer one."
	DB	PAUSE
;	DB	"今のはノーカウントにしておくわ。"
	DB	" We won't count that one."
	DB	NEXT
;	DB	"・・・・・・・・・・・・・・・"
	DB	"................................................"
	DB	NEXT
;	DB	"【美緒】：えいっ！"
	DB	"Mio:  Eh!"
	DB	NEXT
;	DB	"【%001】：はっ！"
	DB	"%001:  *swing*"
	DB	NEXT
;	DB	"ズパッ"
	DB	"*HIT*"
	DB	NEXT
;	DB	"【今日子】：１５－１５。"
	DB	"Kyoko:  15-15."
	DB	NEXT
;	DB	"・・・・・・・・・・・・"
	DB	"............................................"
	DB	NEXT
;	DB	"【%001】：はっ！"
	DB	"%001:  *swing*"
	DB	NEXT
;	DB	"バコッ"
	DB	"*SPOCK*"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT12","T",0,30,1
;	DB	"【今日子】：・・・ゲームセット。%001君の勝ちよ。"
	DB	"Kyoko:  Game set. %001 wins."
	DB	NEXT
;	DB	"最初はいまいちラケットの感覚がつかめなくて苦戦したが、終わってみれば俺の圧勝だった。"
	DB	".....It took some getting used to. But in the end, I won."
	DB	FLG,F_COPYI,4,1
	DB C_BLD,C_V_ON,5
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,3,1
	DB	C_BLD,C_N_ON,1,2		;見る　今日子　消す
	DB	C_BLD,C_N_ON,2,2		;話す　今日子　消す
	DW	0000H

J0:		;野球部に行ってない
	DB	NEXT
;	DB	"（あと、野球部と水泳部か・・・）"
	DB	"Baseball or swimming next..."
	DB	NEXT
;	DB	"（・・・野球部を先にしよう。）"
	DB	"I'll go try baseball first."
	DB	NEXT
;	DB	"俺は野球部のグラウンドに向かった。"
	DB	"I set off towards the baseball field."
	DB	NEXT
;	DB	"・・・・・・・・・"
	DB	"..........................................."
	DB	NEXT
;	DB	"【今日子】：%001君に、あんな才能があったとはね～。"
	DB	"Kyoko:  I didn't know that %001 had such talent."
	DB	NEXT
;	DB	"【今日子】：美緒ちゃん、諦めちゃダメよ。%001君にはぜひともテニス部に入ってもらわなくちゃ。"
	DB	"Kyoko:  Mio, don't give up. We have to get %001 to join"
	DB	CR
	DB	"the team."
	DB	NEXT
;	DB	"【美緒】：%001先輩・・・。"
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	"【美緒】：テニス、楽しくなかったの・・・？"
	DB	"Mio:  Didn't you like tennis?"
	DB	NEXT
	DB SINARIO,"CS209_1.OVL",0
	DW	0000H

J1:		;野球部に行った
	DB	NEXT
;	DB	"（・・・約束した手前、水泳部にも行かないとな・・・。）"
	DB	"I better not keep Reiko waiting anymore."
	DB	NEXT
;	DB	"俺はプールに向かった。"
	DB	"I head for the pool."
	DB	NEXT
;	DB	"・・・・・・・・・"
	DB	"........................................"
	DB	NEXT
;	DB	"【今日子】：%001君に、あんな才能があったとはね～。"
	DB	"Kyoko:  I didn't know that %001 had such talent."
	DB	NEXT
;	DB	"【今日子】：美緒ちゃん、諦めちゃダメよ。%001君にはぜひともテニス部に入ってもらわなくちゃ。"
	DB	"Kyoko:  Mio, don't give up. We have to get %001 to join"
	DB	CR
	DB	"the team."
	DB	NEXT
;	DB	"【美緒】：%001先輩・・・。"
	DB	"Mio:  %001...."
	DB	NEXT
;	DB	"【美緒】：テニス、楽しくなかったの・・・？"
	DB	"Mio:  Didn't you like tennis?"
	DB	NEXT
	DB SINARIO,"CS210.OVL",0
	DW	0000H

	end
