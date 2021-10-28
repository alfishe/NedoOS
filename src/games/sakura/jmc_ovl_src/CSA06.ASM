;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０６
;		駅前

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	NN1,NN2,-1

;VV1:	DB	1,	'待つ',0
VV1:	DB	1,	'WAIT',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'亜希と誠',0
NN1:	DB	1,	'AKI & MAKOTO',0
;NN2:	DB	2,	'今日子',0
NN2:	DB	2,	'KYOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1,  -1,  1, M2, M3, M4			;待つ３
S2:		DW	VV2, NN1,  2, M5, M6, M7, M8		;話す　亜紀と誠４
S3:		DW	VV2, NN2,  3, M9					;話す　今日子


;イニシャルメッセージ
M1:
	DB	BGM,17
	;駅前
	BAK_INIT 'AB_43_1'
;	DB	'・・・そして、旅行当日。'
	DB	".........Finally, the day for the hot springs trip arrived."
	DB	NEXT
;	DB	'【%001】：やっべーな、寝過ごした・・・'
	DB	"%001:  Oh no! I overslept!"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','C',0,20,3
	TU_CG 'CT02','C',0,0,2
	T_CG 'CT01','C',0,12,1
	DB	ANI,A_ON,3
	DB	ANI,A_ON,2
;	DB	'【美緒】：%001せんぱ～い！こっちこっち！'
	DB	"Mio:  %001, hurry up!"
	DB	NEXT
;	DB	'（あ、美緒ちゃんに鈴子さんに新藤さんだ。）'
	DB	"There's Mio and Kiyomi and Reiko."
	DB	NEXT
;	DB	'【鈴子】：%001君、１０分遅刻よ。'
	DB	"Reiko:  You're ten minutes late."
	DB	NEXT
;	DB	'【%001】：悪ィ悪ィ。'
	DB	"%001:  I'm sorry."
	DB	NEXT
;	DB	'【清美】：わたくしたちの他にはどなたがいらっしゃるのですか？'
	DB	"Kiyomi:  Is anyone else going besides us?"
	DB	NEXT
;	DB	'【%001】：誠と今日子先生、それに亜希ちゃん。'
	DB	"%001:  Makoto and Kyoko-sensei. Aki's coming, too."
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_N_ON,2,1
	DB C_BLD,C_N_ON,2,2
	DW	0000H

M2:		;待つ１
;	DB	'【美緒】：あ、亜希ちゃんと誠先輩だ！お～い！'
	DB	"Mio:  Look, it's Aki and Makoto!"
	DB	NEXT
;	DB	'美緒ちゃんが手を振った方を見ると、手ぶらの亜希ちゃんと大荷物を抱えた誠が歩いて来た。'
	DB	"Mio waved to Makoto and Aki. Aki waved back, but Makoto"
	DB	CR
	DB	"was carrying too much stuff to wave."
	DB	FLG,F_COPYI,1,1
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_N_OFF,2,1
	DW	0000H

M3:		;待つ２
;	DB	'【清美】：・・・今日子先生、遅いですわね・・・。'
	DB	"Kiyomi:  Kyoko-sensei's late..."
	DB	NEXT
;	DB	'【鈴子】：また、お酒でも買い込んでるんでしょ。'
	DB	"Reiko:  She must be buying sake again."
	DB	NEXT
;	DB	'【美緒】：う～・・・お酒はもう勘弁して・・・'
	DB	"Mio:  No! I don't ever want to drink again!"
	DB	NEXT
;	DB	'【亜希】：そんなの無理に決まってんじゃない。',CR,'相手はあの今日子先生よ。'
	DB	"Aki:  You'd better not. You'll just lose to me again."
	DB	NEXT
;	DB	'【美緒】：・・・ふぇ～ん。'
	DB	"Mio:  ....I'll get you."
	DW	0000H

M4:		;待つ３
;	DB	'【誠】：どれ・・・'
	DB	"Makoto:  Hmmm..."
	B_P1 B_SUDA
	DB	NEXT
;	DB	'誠は双眼鏡を取り出すと、ガードレールの上に立ってその辺を見回した。'
	DB	"Makoto had his binoculars out, and was standing on the"
	DB	CR
	DB	"guardrail, looking around."
	DB	NEXT
;	DB	'【鈴子】：危ないわよ、誠君！'
	DB	"Reiko:  You shouldn't stand up there, Makoto. It's"
	DB	CR
	DB	"dangerous!"
	DB	NEXT
;	DB	'【誠】：平気平気、斥候任務はお手の物なんだから。'
	DB	"Makoto:  I'm fine. I'm scouting for enemy units."
	DB	NEXT
;	DB	'【誠】：ヤヤ！左舷九時方向に目標発見・・・'
	DB	"Makoto:  There they are! The enemy division is closing"
	DB	CR
	DB	"on vector four-"
	DB	PAUSE
;	DB	'なにィィィィィィィッッッ！'
	DB	" FIVE!!"
	DB	NEXT
;	DB	'【誠】：おわっ！！'
	DB	"Makoto:  I'm losing my balance!!"
	DB	NEXT
;	DB	'【鈴子】：きゃっ・・・！'
	DB	"Reiko:  Oh my God!"
	DB	NEXT
;	DB	'【%001】：あぶねぇっ！'
	DB	"%001:  Makoto!"
	DB	NEXT
;	DB	'俺はとっさに手を伸ばした。'
	DB	"I reached out my hand to catch Makoto, but missed him."
	DB	NEXT,GATA,1,FLASH,1
;	DB	'ごっつん'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'アスファルトの歩道に後頭部から着地して、誠は声にならない悲鳴を上げながらのたうち回った。'
	DB	"He fell off the guardrail, hitting his head against the"
	DB	CR
	DB	"asphalt. He stood up, rubbing his forehead."
	DB	NEXT
;	DB	'【%001】：誠～、双眼鏡は無事だぞ。'
	DB	"%001:  Here, Makoto, at least your binoculars didn't get"
	DB	CR
	DB	"damaged."
	DB	NEXT
;	DB	'【誠】：さ・・・サンキュ、%001。'
	DB	"Makoto:  ....Thanks, %001."
	DB	NEXT
;	DB	'【鈴子】：・・・だから言わんこっちゃ無いのに・・・'
	DB	"Reiko:  I told you not to play up there! How old are you,"
	DB	CR
	DB	"anyway?"
	DB	NEXT
;	DB	'【清美】：誠さん、頭を打ったようですけど、大丈夫ですか？'
	DB	"Kiyomi:  Makoto, you hit your head pretty hard. Are you"
	DB	CR
	DB	"alright?"
	DB	NEXT
;	DB	'【誠】：ああ、このくらい、亜希の蹴りに比べりゃどーってことないって。'
	DB	"Makoto:  Oh, I'm fine. The asphault is much softer than"
	DB	CR
	DB	"Aki's head-kicks."
	DB	NEXT
;	DB	'【亜希】：よかったじゃない。あたしに感謝しなさいよ。'
	DB	"Aki:  I'm so happy you feel that way!"
	DB	NEXT
;	DB	'【誠】：・・・殴るぞ、しまいにゃ・・・'
	DB	"Makoto:  Back, devil-woman!"
	DB	NEXT
;	DB	'【美緒】：あ・・・今日子先生だ。'
	DB	"Mio:  Look, it's Kyoko-sensei."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT12','C',0,8,1
;	DB	'【今日子】：ごっめ～ん、ちょっち寄り道して来ちゃってさ。'
	DB	"Kyoko:  I'm sorry I'm late!"
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_N_OFF,2,2
	DW	0000H

M5:		;話す　亜紀と誠１
	DB	BUF,B_COPY01
	TU_CG 'CT14','C','D',23,4
	T_CG 'CT06','C',0,0,6
	DB	ANI,A_ON,4
;	DB	'【亜希】：ごっめ～ん、島崎がノロマだから遅れちゃった。'
	DB	"Aki:  We're sorry we're late. It's all Makoto's fault."
	DB	NEXT
;	DB	'【誠】：ふっ、ふざっ、ふざけんなよ！俺に無理矢理荷物全部持たせたくせに！'
	DB	"Makoto:  Sow! That's only because you made me carry all"
	DB	CR
	DB	"your luggage!"
	DB	NEXT
;	DB	'【亜希】：何よ、レディの荷物を持つのは男の最低限の礼儀じゃない。そんな事も知らないの？'
	DB	"Aki:  But it's a man's responsibility to carry a lady's"
	DB	CR
	DB	"baggage, don't you know that?"
	DB	NEXT
;	DB	'【誠】：ここは日本！そんな風習はねーよ！',CR,'だいたい、お前のどこがレディなんだよ！'
	DB	"Makoto:  This is Japan! We don't do things that way here!",PAUSE,CR,"And anyway, what's ladylike about you?"
	DB	NEXT
	K_CG 'CT06','D',0,7
	DB	ANI,A_ON,4
;	DB	'【亜希】：なんですってぇ～！'
	DB	"Aki:  What did you say to me?"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;話す　亜紀と誠２
;	DB	'【誠】：いいか、レディってのはここにいる鈴子さんみたいに気品漂う、それでいて優しい人の事を言うんだよ。'
	DB	"Makoto:  If you want to see a lady, look at Reiko here."
	DB	CR
	DB	"She's more gentle and ladylike than you could ever be."
	DB	NEXT
;	DB	'【鈴子】：あら、ありがと。'
	DB	"Reiko:  Thank you, Makoto."
	DB	NEXT
;	DB	'【亜希】：うっ・・・'
	DB	"Aki:  Why you..."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M7:		;話す　亜紀と誠３
;	DB	'【誠】：ぶあ～っ、重かった！'
	DB	"Makoto:  Wow, that was heavy!"
	DB	NEXT
;	DB	'誠は荷物を投げ出して、へたり込んだ。'
	DB	"Makoto put the suitcases down hard."
	DB	NEXT
;	DB	'【亜希】：ちょっと島崎！乱暴に扱わないでよ！壊れたらどー責任取ってくれんのよ！'
	DB	"Aki:  Hey, watch it, Shimazaki! If anything's broken in"
	DB	CR
	DB	"there, you're going to be responsible!"
	DB	NEXT
;	DB	'【誠】：そんなに大事なら自分で持ってりゃいいだろ！'
	DB	"Makoto:  If they're that important, why don't you carry"
	DB	CR
	DB	"them yourself?"
	DB	NEXT
;	DB	'【清美】：まあ、お二人とも、仲よしさんですわね。'
;	DB	"Kiyomi:  They're so cute!"
;	DB	NEXT
;	DB	'【清美】：まるで恋人同士みたいですわ。'
	DB	"Kiyomi:  They make a really nice couple, don't you think?"
	DB	NEXT
;	DB	'【誠】：・・・おっそろしいこと言うなよ新藤！'
	DB	"Makoto:  Bleah! Don't make me imagine it!"
	DB	NEXT
;	DB	'【亜希】：そーよ、島崎とはちょっとそこで会っただけよ！'
	DB	"Aki:  That's right! I ran into him by accident on the way"
	DB	CR
	DB	"here!"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M8:		;話す　亜紀と誠４
;	DB	'【誠】：で、他に誰が来てないんだ？'
	DB	"Makoto:  So, who else is coming?"
	DB	NEXT
;	DB	'【美緒】：まだ、今日子先生が来てないの。'
	DB	"Mio:  We're still waiting for Kyoko-sensei."
	DB	NEXT
;	DB	'【亜希】：あの今日子先生が、「温泉で一杯」を逃すはずないわよね。'
	DB	"Aki:  I'll bet she's going to drink a lot again."
	DB C_BLD,C_V_ON,2	;話す
	DB C_BLD,C_N_ON,2,1
	DB	FLG,F_COPYI,1,2
	DW	0000H

M9:		;話す　今日子
;	DB	'【%001】：みんな待ってたんですよ、いったいどこに・・・'
	DB	"%001:  Everyone was waiting for you. Why are you so late?"
	DB	NEXT
;	DB	'【今日子】：この子を連れて来たのよ。'
	DB	"Kyoko:  I had to go get someone..."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT12','C',0,8,8
	T_CG 'CT05','C',0,30,5
	DB	ANI,A_ON,8
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'【%001】：し・・・白水さん？'
	DB	"%001:  Ruri? You came?"
	DB	NEXT
;	DB	'【今日子】：旅館一軒貸し切りなんだから、一人くらい増えても大丈夫よね、%001君。'
	DB	"Kyoko:  The ryokan is paid for, so one more won't be a problem,"
	DB	CR
	DB	"will it?"
	DB	NEXT
;	DB	'【%001】：平気平気、後１０人増えたって平気。'
	DB	"%001:  Not at all. We can get ten more people if we want."
	DB	NEXT
;	DB	'【清美】：%001さん、そろそろ新幹線の発車時刻ですわよ。'
	DB	"Kiyomi:  Well, shall we go to the Shinkansen tracks? The"
	DB	CR
	DB	"train's about to leave without us."
	DB	NEXT
;	DB	'【%001】：え・・・'
	DB	"%001:  You're right!"
	DB	NEXT
;	DB	'【%001】：あと２分しかない！みんな、走れーっ！'
	DB	"%001:  We only have two minutes! Everyone run!"
	DB	NEXT
;	DB	'俺達は大慌てで切符を買って、新幹線に駆け込んだ。'
	DB	"We all ran as fast as we could for the Shinkansen tracks."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CSA07.OVL',0
	DW	0000H


end
