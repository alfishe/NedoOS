;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０５
;		みんなに電話

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,-1

;VV1:	DB	1,	'電話する',0
VV1:	DB	1,	'CALL',0

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
;NN7:	DB	7,	'今日子',0
NN7:	DB	7,	'KYOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;電話する　誠
S2:		DW	VV1, NN2,  2, M3		;電話する　鈴子
S3:		DW	VV1, NN3,  3, M4		;電話する　清美
S4:		DW	VV1, NN4,  4, M5		;電話する　美緒
S5:		DW	VV1, NN5,  5, M6		;電話する　瑠璃
S6:		DW	VV1, NN6,  6, M7		;電話する　亜希
S7:		DW	VV1, NN7,  7, M8		;電話する　今日子


;イニシャルメッセージ
M1:
	DB	BGM,4
	E_CG B_SUDA,"AB_38_2"	;自分の部屋
;	DB	'さて、誰から電話しようか。'
	DB	"So, who should I call first?"
	DB C_BLD,C_N_ON,1,5	;電話する　瑠璃
	DW	0000H

M2:		;電話する　誠
;	DB	'プルルルル・・・　プルルルル・・・'
	DB	"RING  RING"
	DB	NEXT
;	DB	'「はい、島崎です。」'
	DB	"Makoto:  Hello, Shimazaki residence."
	DB	NEXT
;	DB	'【%001】：誠、３日と４日空いてるか？'
	DB	"%001:  Makoto, are you free the third and fourth?"
	DB	NEXT
;	DB	'「３日と４日？ちょっと待った・・・」'
	DB	"Makoto:  Hang on, I'll check..."
	DB	NEXT
;	DB	'「ああ、空いてるぜ。」'
	DB	"Makoto:  Yeah, I'm free. Why?"
	DB	NEXT
;	DB	'【%001】：実はな・・・'
	DB	"%001:  Well......"
	DB	NEXT
;	DB	'【%001】：・・・・・・というわけなんだが、お前どうする？'
	DB	"%001:  ......So can you go?"
	DB	NEXT
;	DB	'「電車賃だけでいいんだろ？なら行くよ。」'
	DB	"Makoto:  We only have to pay for the train, right? Okay,"
	DB	CR
	DB	"I'll go."
	DB	NEXT
;	DB	'【%001】：それじゃ、３日の午前十時に、駅で待ち合わせな。'
	DB	"%001:  Okay, I'll see you at ten a.m. at the station."
	DB	NEXT
;	DB	'「ＯＫ！」'
	DB	"Makoto:  Okay!"
	DB	NEXT
;	DB	'（・・・誠はＯＫ、と・・・）'
	DB	"Makoto is on... That's good."
	DB C_BLD,C_N_ON,1,1	;電話する　誠
	EF_SET 105
	DW	0000H

M3:		;電話する　鈴子
;	DB	'プルルルル・・・　プルルルル・・・'
	DB	"RING  RING"
	DB	NEXT
;	DB	'「ハイ、沢村です」'
	DB	"Reiko:  Sawamura residence."
	DB	NEXT
;	DB	'【%001】：もしもし、鈴子さんですか？'
	DB	"%001:  Is this Reiko?"
	DB	NEXT
;	DB	'「あら、%001君？」'
	DB	"Reiko:  %001?"
	DB	NEXT
;	DB	'【%001】：えっと、鈴子さんは３日と４日空いてます？'
	DB	"%001:  Reiko, are you free on the third and fourth?"
	DB	NEXT
;	DB	'「空いてるわよ。」'
	DB	"Reiko:  Yes. Why?"
	DB	NEXT
;	DB	'【%001】：実はね・・・'
	DB	"%001:  Well...."
	DB	NEXT
;	DB	'【%001】：・・・・・・・というわけなんだけど、鈴子さんはどうかな、って思って。'
	DB	"%001:  ......So can you go?"
	DB	NEXT
;	DB	'「もちろん、ＯＫよ！」'
	DB	"Reiko:  I wouldn't miss it!"
	DB	NEXT
;	DB	'【%001】：それじゃ、３日の午前十時に、駅で待ち合わせね。'
	DB	"%001:  Okay, I'll see you at ten a.m. on the third."
	DB	NEXT
;	DB	'「３日の午前十時に駅ね、わかったわ。」'
	DB	"Reiko:  Okay, I'll be there!"
	DB	NEXT
;	DB	'（・・・鈴子さんはＯＫ、と・・・）'
	DB	"Reiko's on... That's good."
	DB C_BLD,C_N_ON,1,2	;電話する　鈴子
	EF_SET 101
	DW	0000H

M4:		;電話する　清美
;	DB	'プルルルル・・・　プルルルル・・・'
	DB	"RING  RING"
	DB	NEXT
;	DB	'「はい、新藤ですが」'
	DB	"Kiyomi:  Hello, Shinfuji residence."
	DB	NEXT
;	DB	'【%001】：もしもし、%001だけど。'
	DB	"%001:  Hi, it's %001."
	DB	NEXT
;	DB	'「あら、%001さん？何か御用ですの？」'
	DB	"Kiyomi:  %001? Hello."
	DB	NEXT
;	DB	'【%001】：えっと、新藤さんは３日と４日空いてる？'
	DB	"%001:  Are you free on the third and fourth?"
	DB	NEXT
;	DB	'「空いてますわ。」'
	DB	"Kiyomi:  Yes. Why?"
	DB	NEXT
;	DB	'【%001】：実はね・・・'
	DB	"%001:  Well...."
	DB	NEXT
;	DB	'【%001】：・・・・・・・というわけなんだけど、新藤さんはどうかな、って思って。'
	DB	"%001:  ........So can you go?"
	DB	NEXT
;	DB	'「是非とも、ご一緒させていただきますわ！」'
	DB	"Kiyomi:  I'd be happy to go!"
	DB	NEXT
;	DB	'【%001】：慎治君もどうかな。'
	DB	"%001:  How about Shinji?"
	DB	NEXT
;	DB	'「あの子は父と一緒に里帰りしてますわ。」'
	DB	"Kiyomi:  He's going to visit our grandparents with Father."
	DB	NEXT
;	DB	'【%001】：・・・じゃあ、今新藤さん一人なの？'
	DB	"%001:  Okay, so you'll come alone?"
	DB	NEXT
;	DB	'「はい・・・。」'
	DB	"Kiyomi:  Yes..."
	DB	NEXT
;	DB	'【%001】：ふ～ん・・・じゃ、３日の午前十時に、駅で待ち合わせね。'
	DB	"%001:  Good. Meet us at the station on the third, at ten"
	DB	CR
	DB	"a.m."
	DB	NEXT
;	DB	'「３日の午前十時に駅ですね、わかりました。」'
	DB	"Kiyomi:  Okay, I'll be there."
	DB	NEXT
;	DB	'（・・・新藤さんはＯＫ、と・・・）'
	DB	"Kiyomi's on..."
	DB	NEXT
;	DB	'（・・・何で一人で留守番してるんだろ？・・・）'
	DB	"I wonder why she didn't go to her grandparents' house,"
	DB	CR
	DB	"too."
	DB	NEXT
;	DB	'（・・・もしかして・・・俺のため？）'
	DB	"Could she have been waiting for me to call?"
	DB C_BLD,C_N_ON,1,3	;電話する　清美
	EF_SET 102
	DW	0000H

M5:		;電話する　美緒
;	DB	'プルルルル・・・　プルルルル・・・'
	DB	"RING  RING"
	DB	NEXT
;	DB	'「はい、鈴木です」'
	DB	"Mio:  Hello, Suzuki residence."
	DB	NEXT
;	DB	'【%001】：もしもし、%001だけど。'
	DB	"%001:  Hi, it's me, %001."
	DB	NEXT
;	DB	'「あっ、%001先輩。」'
	DB	"Mio:  Oh, hi!"
	DB	NEXT
;	DB	'【%001】：・・・調子どう？'
	DB	"%001:  How do you feel?"
	DB	NEXT
;	DB	'「もう大丈夫。寝てたら治ったから。」'
	DB	"Mio:  I'm fine. I woke up with an awful headache, though."
	DB	NEXT
;	DB	'【%001】：よかった。えっと、美緒ちゃんは３日と４日空いてる？'
	DB	"%001:  I'm glad you're okay. Are you free on the third"
	DB	CR
	DB	"and fourth?"
	DB	NEXT
;	DB	'「うん、空いてる。」'
	DB	"Mio:  Sure!"
	DB	NEXT
;	DB	'【%001】：実はね・・・'
	DB	"%001:  Well..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・というわけなんだけど、美緒ちゃんはどうかな、って思って。'
	DB	"%001:  ................So can you go?"
	DB	NEXT
;	DB	'「行く！」'
	DB	"Mio:  Sure, I'll go!"
	DB	NEXT
;	DB	'【%001】：それじゃ、３日の午前十時に、駅で待ち合わせね。'
	DB	"%001:  Okay, then, meet us at the station at ten a.m.,"
	DB	CR
	DB	"on the third."
	DB	NEXT
;	DB	'「うん、わかった。」'
	DB	"Mio:  I'll be there!"
	DB	NEXT
;	DB	'（・・・美緒ちゃんはＯＫ、と・・・）'
	DB	"Mio's on..."
	DB C_BLD,C_N_ON,1,4	;電話する　美緒
	EF_SET 103
	DW	0000H

M6:		;電話する　瑠璃
;	DB	'プルルルル・・・　プルルルル・・・'
	DB	"RING  "
	DB	NEXT
;	DB	'プルルルル・・・　プルルルル・・・'
	DB	"RING  RING"
	DB	NEXT
;	DB	'プルルルル・・・　プルルルル・・・'
	DB	"RING  RING  RING"
	DB	NEXT
;	DB	'（・・・いないのかな・・・）'
	DB	".......I guess she's not home."
	DB	NEXT
;	DB	'「・・・はい。」'
	DB	"Ruri:  Hello?"
	DB	NEXT
;	DB	'【%001】：もしもし、白水さん？俺・・・山神だけど。'
	DB	"%001:  Hello, Ruri? It's me, %001."
	DB	NEXT
;	DB	'「・・・なに？」'
	DB	"Ruri:  ......What?"
	DB	NEXT
;	DB	'【%001】：うん・・・実は・・・'
	DB	"%001:  Well......."
	DB	NEXT
;	DB	'【%001】：・・・・・というわけなんだけど、白水さん・・・一緒に行かない？'
	DB	"%001:  .........So do you think you can go with us?"
	DB	NEXT
;	DB	'「・・・温泉・・・？」'
	DB	"Ruri:  .......Hot springs?"
	DB	NEXT
;	DB	'【%001】：誠とか新藤さんとか、今日子先生とかも来るんだ。'
	DB	"%001:  Makoto, Kiyomi, and Kyoko are all going to be there."
	DB	NEXT
;	DB	'【%001】：・・・どう？'
	DB	"%001:  Can you go?"
	DB	NEXT
;	DB	'「・・・私、行かない。」'
	DB	"Ruri:  No, I don't want to go."
	DB	NEXT
;	DB	'プツッ'
	DB	"*CLICK*"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ...................."
	DB	NEXT
;	DB	'【%001】：ダメか・・・・・・'
	DB	"%001:  Oh well..."
	DB	NEXT
;	DB	'【%001】：・・・・・・転校する前に、楽しい思い出も作ってあげたかったんだけどな・・・。'
	DB	"I guess she doesn't want to have fun with everyone right"
	DB	CR
	DB	"before changing schools again..."
	DB	NEXT
	B_O B_WIPE
	DB SINARIO,'CSA06.OVL',0
	DW	0000H

M7:		;電話する　亜希
;	DB	'プルルルル・・・　プルルルル・・・'
	DB	"RING  RING"
	DB	NEXT
;	DB	'「はい、雛菊ですけどぉ。」'
	DB	"Aki:  Hello? "
	DB	NEXT
;	DB	'【%001】：えっと・・・亜希ちゃんかな？'
	DB	"%001:  Is this Aki?"
	DB	NEXT
;	DB	'「あっ、%001先輩！何か用？」'
	DB	"Aki:  %001, hello! "
	DB	NEXT
;	DB	'【%001】：えっと、亜希ちゃんは３日と４日空いてる？'
	DB	"%001:  I was wondering, are you free on the third and"
	DB	CR
	DB	"fourth?"
	DB	NEXT
;	DB	'「ま、空いてるけど。」'
	DB	"Aki:  Sure. Why?"
	DB	NEXT
;	DB	'【%001】：実はね・・・'
	DB	"%001:  Well...."
	DB	NEXT
;	DB	'【%001】：・・・・・・・というわけなんだけど、亜希ちゃんはどうかな、って思って。'
	DB	"..............So can you go?"
	DB	NEXT
;	DB	'「・・・%001先輩って、オヤジくさ～い。」'
	DB	"Aki:  Don't you think hot springs are for old people?"
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ....................."
	DB	NEXT
;	DB	'「・・・ま、たまには温泉なんかもいいかもね。',CR,'いいわよ、付き合ってあげる。」'
	DB	"Aki:  Oh well. I guess it's okay every once in a while."
	DB	CR
	DB	"I'll go."
	DB	NEXT
;	DB	'【%001】：それじゃ、３日の午前十時に、駅で待ち合わせね。'
	DB	"%001:  Okay, wait at the station on the third at ten a.m."
	DB	NEXT
;	DB	'「うん、わかったわ。」'
	DB	"Aki:  Okay!"
	DB	NEXT
;	DB	'（・・・亜希ちゃんはＯＫ、と・・・）'
	DB	"Aki's on..."
	DB C_BLD,C_N_ON,1,6	;電話する　亜希
	EF_SET 104
	DW	0000H

M8:		;電話する　今日子
;	DB	'俺が電話をかけようとすると・・・'
	DB	"I moved to pick up the phone, when..."
	DB	NEXT
;	DB	'プルルルル・・・'
	DB	"RING!!"
	DB	NEXT
;	DB	'【%001】：あれ・・・どこからだろ？'
	DB	"%001:  Who could be calling me now?"
	DB	NEXT
;	DB	'【%001】：・・・はい、山神です。'
	DB	"%001:  Hello, Yamagami residence."
	DB	NEXT
;	DB	'「もしもし%001君？」'
	DB	"Kyoko:  Hello, %001?"
	DB	NEXT
;	DB	'【%001】：・・・今日子先生？'
	DB	"%001:  Kyoko-sensei?"
	DB	NEXT
;	DB	'「あたしも温泉、行っていいでしょ？」'
	DB	"Kyoko:  Can I go to the hot springs, too?"
	DB	NEXT
;	DB	'【%001】：えっ？'
	DB	"%001:  .......How did you hear...?"
	DB	NEXT
;	DB	'「それじゃ、３日の午前十時に、駅で待ち合わせね。」'
	DB	"Kyoko:  Well, I'll see you at the station at ten a.m. on"
	DB	CR
	DB	"the third."
	DB	NEXT
;	DB	'【%001】：は、はい、待ってます。'
	DB	"%001:  Okay, I'll see you there."
	DB	NEXT
;	DB	'「温泉でキューッと一杯・・・ウフフ、楽しみ楽しみ！」'
	DB	"Kyoko:  Hot springs and cold sake... I can't wait!"
	DB	NEXT
;	DB	'ガチャ'
	DB	"*CLICK*"
	DB	NEXT
;	DB	'（・・・・・・・・・・・・）'
	DB	"....................."
	DB	NEXT
;	DB	'（・・・今日子先生はＯＫ、と・・・）'
	DB	"Well, she's on..."
	DB C_BLD,C_N_ON,1,7	;電話する　今日子
	EF_SET 106
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,7,255,101,102,103,104,105,106
	DB FLG,F_EXIT,255
	DB	NEXT
;	DB	'（・・・これで昨日のメンバーには全員伝えたけど・・・）'
	DB	"Everyone who was here yesterday is going to the hot"
	DB	CR
	DB	"springs."
	DB	NEXT
;	DB	'（旅館一軒貸切なんだから、もっと呼ぶか。）'
	DB	"Since the hotel's already paid for, I should invite some"
	DB	CR
	DB	"more people..."
	DB	NEXT
;	DB	'（えっと、吉田・・・と中野はスキー合宿か。）'
	DB	"But Seia and Meimi are skiing..."
	DB	NEXT
;	DB	'（古橋と曽我は登山しに行くとか言ってたし・・・）'
;	DB	"***"
;	DB	NEXT
;	DB	'（・・・・・・・・・・・・）'
;	DB	"............................."
;	DB	NEXT
;	DB	'（みんな正月は里帰りしたり旅行したりしてるよな。）'
	DB	"Everyone else is going somewhere for the holidays..."
	DB	NEXT
;	DB	'（・・・白水さんはどうしてるんだろ・・・）'
	DB	"I wonder what Ruri's doing?"
	DB	NEXT
;	DB	'（・・・・・・・・・・・・）'
	DB	"................................"
	DB	NEXT
;	DB	'（・・・・・・・・・）'
	DB	"........................"
	DB	NEXT
;	DB	'（・・・電話・・・してみよう。）'
	DB	"I guess I'll call her."
;	DB	NEXT
	DB C_BLD,C_N_OFF,1,5	;電話する　瑠璃
	DW	0000H


end
