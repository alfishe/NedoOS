;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０９＿１
;		野球部（清美）と対決

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	0
MSGTBL:
	DW	M1
COMTBL:
	DW	0
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ


;イニシャルメッセージ
M1:
	DB	BGM,22
	DB	G_FLG,G_COPYI,101,1
	BAK_INIT "AB_11_1"
	B_P1 B_SUDA
;	DB	"野球部のグラウンドに来た。"
	DB	"I arrived at the baseball field."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","W",0,15,1
;	DB	"【清美】：お待ちしておりましたわ。"
	DB	"Kiyomi:  I've been waiting for you."
	DB	NEXT
;	DB	"【%001】：それで、勝負の内容は？"
	DB	"%001:  So, what kind of challenge do you have for me?"
	DB	NEXT
;	DB	"【清美】：葉隠野球部のエースピッチャー、干さんと対決していただきますわ。"
	DB	"Kiyomi:  You are going to go up aginst the ace pitcher, Hoshi."
	DB	NEXT
;	DB	"【%001】：わかった。"
	DB	"%001:  Okay."
	DB	NEXT
	B_P1 B_SUDA
;	DB	"俺はバットをつかんで、バッターボックスに立った。"
	DB	"I grip the bat and walked up to the plate."
	DB	NEXT
;	DB	"【干】：君がマネージャーの言ってた期待の新人か。"
	DB	"Hoshi:  Are you the new guy the manager thinks is so good?"
	DB	NEXT
;	DB	"【%001】：いや、入部するつもりはねぇんだけど。"
	DB	"%001:  Yes, but I don't intend to join the club."
	DB	NEXT
;	DB	"【干】：ようこそ葉隠野球部へ。これからビシビシ鍛えてやるからそのつもりでな。"
	DB	"Hoshi:  Well, I'll try to go easy on you."
	DB	NEXT
;	DB	"（・・・最初っから勝ったつもりでいるな。）"
	DB	"Oh, I don't know about that."
	DB	NEXT
;	DB	"【干】：じゃ、まずは軽～くウォーミングアップといこうか。"
	DB	"Hoshi:  Let's just warm up slowly."
	DB	NEXT
;	DB	"ひゅっ"
	DB	"*SWING*"
	DB	NEXT
	E_CG B_NORM,"AE_041"
	DB	FLASH,2
;	DB	"キィーン！！"
	DB	"*CHING*"
	DB	NEXT
;	DB	"ボールはセンターのはるか頭上を越えていった。"
	DB	"The ball went way over the center fielder's head."
	DB	NEXT
	B_P1 B_NORM
;	DB	"【干】：ふ～ん、やるねぇ。君は経験者なのか？"
	DB	"Hoshi:  Hey, you're pretty good. Ever play before?"
	DB	NEXT
;	DB	"【%001】：小学校の時、三角ベースをちびっとかじったくらいだけど。"
	DB	"%001:  Just a little T-ball in elementary school."
	DB	NEXT
;	DB	"【干】：・・・なるほど。"
	DB	"Hoshi:  Is that so?"
	DB	NEXT
;	DB	"ピッチャーは振りかぶって第二球を投げた。"
	DB	"The pitcher went into the windup and made his second"
	DB	CR
	DB	"throw."
	DB	NEXT
	E_CG B_NORM,"AE_041"
	DB	FLASH,2
;	DB	"グワーン！"
	DB	"*CHING*"
	DB	NEXT
;	DB	"ボールはライトの頭上を越えていった。"
	DB	"The ball went over the right fielder's head."
	DB	NEXT
;	DB	"【干】：・・・やるね。"
	DB	"Hoshi:  You're good."
	DB	NEXT
;	DB	"ピッチャーは振りかぶって・・・"
	DB	"He went into the windup..."
	DB	NEXT
	DB	FLASH,2
;	DB	"キィーン！！"
	DB	"*CHING*"
	DB	FLASH,2
;	DB	"グワーン！"
	DB	" *CHING*"
	DB	FLASH,2
;	DB	"カーン！！"
	DB	" *CHING*"
;	DB	"・・・・・・・・・２０分後・・・・・・・・・"
	DB	"............20 minutes later."
	DB	NEXT
;	DB	"俺は５６本目のホームランを打ったところだ。"
	DB	"I just hit my 56th home run."
	DB	NEXT
	B_P1 B_NORM
;	DB	"【干】：はぁ、はぁ、ぜぇ、ぜぇ・・・"
	DB	"Hoshi:  ...*pant*......*pant*...."
	DB	NEXT
;	DB	"【%001】：お～い。ウォーミングアップはその辺にしといてくれねえかな？"
	DB	"%001:  That's enough for now."
	DB	NEXT
;	DB	"【%001】：俺、他に行くところがあるから急いでるんだけど。"
	DB	"%001:  I have other places to go. I'm in a bit of a hurry."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","W",0,15,1
;	DB	"【清美】：%001さん、すごいですわ！"
	DB	"Kiyomi:  %001, that was amazing."
	DB	NEXT
;	DB	"【%001】：そーか？"
	DB	"%001:  Really?"
	DB	NEXT
;	DB	"【干】：俺は関東大会の優勝ピッチャーだぞ・・・こんな素人相手に・・・"
	DB	"Hoshi:  I'm the best pitcher in the Japanese Eastern"
	DB	CR
	DB	"League! You can't do that!"
	DB	NEXT
;	DB	"【清美】：干さんの剛速球を全てホームランにしてしまうなんて、やはり%001さんは野球をするために生まれて来たのですわ！"
	DB	"Kiyomi:  See? You were born to play baseball!"
	DB	NEXT
;	DB	"【清美】：%001さん、わたくしたちと甲子園を目指しましょう！"
	DB	"Kiyomi:  %001, let's go for the championship together!"
	DB	CR
	DB	"Please!"
	DB	NEXT
;	DB	"【%001】：・・・俺が勝ったら諦めるって約束だっただろ？"
	DB	"%001:  Didn't you promise to stop that if I won?"
	DB	NEXT
;	DB	"俺はバットをおいて、野球部員の視線から逃げるようにその場を去った。"
	DB	"I drop the bat and leave."
	DB	G_FLG,G_COPYF,50,102		;テニス部にいったか？
	DB	FLG,F_JEQ,50
	DW	J0
	DB	FLG,F_JR
	DW	J1
	DW	0000H

J0:	;フラグジャンプ
;テニス部に行ってない
	DB	NEXT
;	DB	"（あと、テニス部と水泳部か・・・）"
	DB	"Tennis and swimming..."
	DB	NEXT
;	DB	"（・・・テニス部を先にしよう。）"
	DB	"...I'll do tennis first."
	DB	NEXT
;	DB	"俺はテニスコートに向かった。"
	DB	"I headed for the tennis courts."
	DB	NEXT
;	DB	"・・・・・・・・・"
	DB	"....................."
	DB	NEXT
;	DB	"【清美】：%001さん・・・"
	DB	"Kiyomi:  %001..."
	DB	NEXT
;	DB	"【清美】：わたくし、諦めませんわよ。"
	DB	"Kiyomi:  I'll never give up."
	DB	NEXT
	DB SINARIO,"CS209_2.OVL",0
	DW	0000H

J1:	;テニス部に行った
	DB	NEXT
;	DB	"（・・・約束した手前、水泳部にも行かないとな・・・。）"
	DB	"....I better not keep Reiko waiting anymore."
	DB	NEXT
;	DB	"俺はプールに向かった。"
	DB	"I head for the pool."
	DB	NEXT
;	DB	"・・・・・・・・・"
	DB	"................................................"
	DB	NEXT
;	DB	"【清美】：%001さん・・・"
	DB	"Kiyomi:  %001..."
	DB	NEXT
;	DB	"【清美】：わたくし、諦めませんわよ。"
	DB	"Kiyomi:  I'll never give up."
	DB	NEXT
	DB SINARIO,"CS210.OVL",0
	DW	0000H

end
