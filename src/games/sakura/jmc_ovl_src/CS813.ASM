;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１３
;		祝勝会

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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,NN6,NN7,NN8,NN9,NN10,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'みんな',0
NN1:	DB	1,	'EVERYONE',0
;NN2:	DB	2,	'誠',0
NN2:	DB	2,	'MAKOTO',0
;NN3:	DB	3,	'鈴子',0
NN3:	DB	3,	'REIKO',0
;NN4:	DB	4,	'清美',0
NN4:	DB	4,	'KIYOMI',0
;NN5:	DB	5,	'美緒',0
NN5:	DB	5,	'MIO',0
;NN6:	DB	6,	'星愛',0
NN6:	DB	6,	'SEIA',0
;NN7:	DB	7,	'恵依美',0
NN7:	DB	7,	'MEIMI',0
;NN8:	DB	8,	'亜希',0
NN8:	DB	8,	'AKI',0
;NN9:	DB	9,	'今日子',0
NN9:	DB	9,	'KYOKO',0
;NN10:	DB	10,	'慎治',0
NN10:	DB	10,	'SHINJI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　みんな
S2:		DW	VV2, NN2,  2, M3, M4, M5		;話す　誠３
S3:		DW	VV2, NN3,  3, M6, M7, M8		;話す　鈴子３
S4:		DW	VV2, NN4,  4, M10, M11, M12, M13, M14, M15, M16		;話す　清美７
S5:		DW	VV2, NN5,  5, M17, M18, M19, M20, M21, M22, M23		;話す　美緒７
S6:		DW	VV2, NN6,  6, M24, M25		;話す　星愛２
S7:		DW	VV2, NN7,  7, M26, M27, M28, M29		;話す　恵依美４
S8:		DW	VV2, NN8,  8, M30, M31, M32		;話す　亜希３
S9:		DW	VV2, NN9,  9, M33, M34, M35, M36		;話す　今日子４
S10:		DW	VV2, NN10,  10, M37, M38, M39, M40, M41		;話す　慎治５


;イニシャルメッセージ
M1:
	DB	BGM,3
	BAK_INIT "AB_02_2"
	DB	BUF,B_COPY01
	T_CG "CT14","C",0,30,1
;	DB	'【誠】：え～、それでは乾杯の前に、本日の主役・山神%001君から一言いただきましょうか！'
	DB	"Makoto:  ...And before the first toast, we'd like to"
	DB	CR
	DB	"have tonight's guest of honor, %001, say something to"
	DB	CR
	DB	"everyone."
	DB	NEXT
;	DB	'【%001】：へ？俺？'
	DB	"%001:  Huh? Me?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT12","C",0,10,2
;	DB	'【今日子】：ほら、早く早く！'
	DB	"Kyoko:  Get up there!"
	DB	NEXT
;	DB	'俺はみんなの拍手に促されて立ち上がった。'
	DB	"I stood up to the applause of everyone."
	DB	NEXT
;	DB	'やっぱ、照れくさいな・・・だけど、決していやじゃない。っていうより・・・うれしい。'
	DB	"It was really embarrassing. Kind of nice, but also"
	DB	CR
	DB	"embarrassing."
	DB	NEXT
;	DB	'【%001】：・・・ん～と、なんつ～か、気がついたら優勝してたって感じなんだけど・・'
	DB	"%001:  Um, well, I looked up one day, and suddenly I had"
	DB	CR
	DB	"won the M.V.P. award at the sports festival."
	DB	NEXT
;	DB	'【%001】：それに、あれだけ沢山出てりゃあ個人点もたまって当然って気がするんだけど・・・'
	DB	"%001:  I guess anyone who was in that many events would win"
	DB	CR
	DB	"it."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","C",0,0,3
;	DB	'【清美】：そんなことはありませんわ。出場した全ての種目で上位をキープしていたからこそ、１０５７点も取れたのですわ。'
	DB	"Kiyomi:  That's not true. You got it because you were the"
	DB	CR
	DB	"best."
	DB	NEXT
;	DB	BUF,B_COPY01
	T_CG "CT08","C",0,35,4
	DB ANI,A_ON,3
;	DB	'【恵依美】：あたしも個人点だけなら%001と同じ位取ったんだけどな。'
	DB	"Meimi:  I got almost the same number of points in the "
	DB	CR
	DB	"individual events..."
	DB	NEXT
;	DB	'【誠】：中野は団体種目は向いてねーもんな、協調性ねーから。'
	DB	"Makoto:  But you're not good at the team sports, because"
	DB	CR
	DB	"you've got a terrible personality. You don't know how to"
	DB	CR
	DB	"cooperate with others."
	DB	NEXT,FLASH,2
;	DB	'ズビシ！'
	DB	"*SMACK*"
	DB	NEXT
;	DB	'【誠】：う、裏手刀・・・'
	DB	"Makoto:  ...That stings!"
	DB	NEXT
;	DB	'【%001】：協調性ね・・・俺の場合、チームのみんなに合わしてもらってたけどな。'
	DB	"%001:  Cooperation, huh? In my case, everyone else on the"
	DB	CR
	DB	"other teams was keeping up with my pace, not the other way"
	DB	CR
	DB	"around."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT07","C",0,0,5
;;	DB	'【星愛】：いいえ、%001さんは必死に練習していらっしゃいましたもの。主は自らを助ける者を助け給うのですわ。'
	DB	"Seia:  I don't think that's right. I think it's because you"
	DB	CR
	DB	"practiced so much with the others. The Lord helps those"
	DB	CR
	DB	"who help themselves."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT01","C",0,30,6
;	DB	'【鈴子】：そういえば、美緒ちゃんとのダブルスでも優勝してたわよね。'
	DB	"Reiko:  You did win the tennis doubles match with Mio."
	DB	CR,PAUSE
;	DB	'でも練習するヒマなかったんじゃない？'
	DB	"But you didn't have time to practice with her."
	DB	NEXT
;	DB	'【%001】：あのくらいの相手なら美緒ちゃん一人で勝てるって。俺は突っ立ってただけだよ。な、美緒ちゃん。'
	DB	"%001:  Mio was so good, she could have won by herself."
	DB	CR
	DB	"Isn't that right, Mio?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT03","C",0,10,7
;	DB	'【美緒】：ううん、先輩だってすごかった！'
	DB	"Mio:  No, it's not. You were a teriffic partner."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT12","C",0,0,2
;	DB	'【今日子】：ま、とにかく１０００点以上取って優勝したのは、我が校創立以来二人目だって、校長先生が言ってたわ。'
	DB	"Kyoko:  Well, because he scored over 1000 points, the"
	DB	CR
	DB	"dean said that %001's name will go down in the history"
	DB	CR
	DB	"of this school."
	DB	NEXT
;	DB	'【今日子】：校長先生もずいぶん君がお気に入りみたいよ。君に「オーバー・ザ・サウザンド」の称号を譲るって。'
	DB	"Kyoko:  I think you really caught his eye. He nicknamed"
	DB	CR
	DB	"you 'Over The Thousand %001.'"
	DB	NEXT
;	DB	'【%001】：え？「譲る」って事は・・・'
	DB	"%001:  ...........Is that a good thing?"
	DB	NEXT
;	DB	'【今日子】：ま、前置きはこの辺にしといて、%001君の最優秀個人賞獲得を祝してぇ・・・'
	DB	"Kyoko:  Anyway, let's get back to what we were doing. Here's"
	DB	CR
	DB	"to %001!"
	DB	PAUSE
;	DB	'かんぱーい！'
	DB	" KAMPAI!"
	DB	NEXT,FLASH,1
;	DB	'【一同】：かんぱーい！'
	DB	"All:  KAMPAI!"
	DB	NEXT
	DB	"We all touched our glasses together. The party had begun."
	DW	0000H

M2:		;見る　みんな
;	DB	'みんないい感じで酔っている。'
	DB	"Everyone's pretty drunk."
	DB	NEXT
;	DB	'一次会（今日子先生曰く『Ａ組準優勝おめでとう＆最大の功労者%001君を賛える会』だそーだ）でも結構飲んでたし・・・'
	DB	"They all drank quite a bit at the first party."
	DB	NEXT
;	DB	'・・・冷静に考えると、とんでもない高校生だな・・・'
	DB	".............Of course, we're all college students so we're"
	DB	CR
	DB	"supposed to be on good behaivoir."
	DB	NEXT
;	DB	'・・・しかも教師が生徒に酒飲ましとるぞ。'
	DB	"Especially drinking with our professor."
	DB	NEXT
;	DB	'・・・今さらながら・・・フツーじゃねーよなー・・・'
	DB	"Oh well. This is Japan."
	DW	0000H

M3:		;話す　誠１
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT14","C",0,30,1
;	DB	'【誠】：よ、おめっとさん。'
	DB	"Makoto:  Congratulations, %001."
	DB	NEXT
;	DB	'【%001】：さんきゅ、誠。'
	DB	"%001:  Thanks, Makoto."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　誠２
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT14","C",0,30,1
;	DB	'【誠】：しっかし惜しかったよなぁ・・・も～ちょっとで、Ａ組連合の逆転優勝だったのによ。'
	DB	"Makoto:  I wish our class could have won first place,"
	DB	CR
	DB	"though."
	DB	NEXT
	T_CG 'CT06','C','D',0,5
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ..................."
	DB	NEXT
;	DB	'【誠】：うわっ！？'
	DB	"Makoto:  Wah! Aki!"
	DB	PAUSE
;	DB	'な、なんだよ・・・やる気か！？'
	DB	" Are you looking for a fight again?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ............."
								;亜希消し
	DB	BUF,B_COPY01
	T_CG "CT14","C",0,30,1
	DB	NEXT
;	DB	'【誠】：・・・'
	DB	"Makoto:  ..........."
	DB	PAUSE
;	DB	'な、なんだぁ？'
	DB	"What are you looking at?"
	DB	NEXT
;	DB	'【%001】：・・・亜希ちゃん・・・'
	DB	"%001:  ..........Aki."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　誠３
;	DB	'【誠】：・・・ど～したんだあいつ？'
	DB	"Makoto:  What's wrong with her?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DW	0000H

M6:		;話す　鈴子１
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT01","C",0,30,6
;	DB	'【鈴子】：%001君、おめでとう。'
	DB	"Reiko:  %001, congratulations."
	DB	NEXT
;	DB	'【%001】：さんきゅ、鈴子さん。'
	DB	"%001:  Thanks, Reiko."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M7:		;話す　鈴子２
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT01","C",0,30,6
;	DB	'【鈴子】：%001君が本気出したとこ初めて見たけど・・・'
;	DB	'やっぱり凄いのね。'
	DB	"Reiko:  I'd never seen you put so much energy into"
	DB	CR
	DB	"anything before. It was great to watch."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............."
	DB	PAUSE
;	DB	'そんな事はないよ。'
	DB	"Oh, it wasn't anything, really."
	DB	NEXT
;	DB	'【鈴子】：そう？私は凄いと思うけどな。'
	DB	"Reiko:  Really? I thought it was."
	DB	NEXT
;	DB	'【%001】：・・・・・・そお？'
	DB	"%001:  .....You did?"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M8:		;話す　鈴子３
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT01","C",0,30,6
;	DB	'【鈴子】：ところで%001君、これ食べない？'
	DB	"Reiko:  Do you want to eat this?"
	DB	PAUSE
;	DB	'おいしいわよ。'
	DB	"It's good."
	DB	NEXT
;	DB	'【%001】：・・・どれどれ。'
	DB	"%001:  What? Where?"
	DB	NEXT
;	DB	'ぱく。'
	DB	"*gulp*"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................"
	DB	PAUSE
;	DB	'うん、美味い！'
	DB	" Mmm, it's good!"
	DB	NEXT
;	DB	'【鈴子】：でしょ？'
	DB	"Reiko:  I told you."
	DW	0000H

M10:		;話す　清美１
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT02","C",0,0,3
;	DB	'【清美】：%001さん、おめでとうございます。'
	DB	"Kiyomi:  %001, congratulations on winning the M.V.P. award."
	DB	NEXT
;	DB	'【%001】：さんきゅ、新藤さん。'
	DB	"%001:  Thanks, Kiyomi."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M11:		;話す　清美２
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT02","C",0,0,3
;	DB	'【清美】：流石は%001さんでしたわ・・・わたくし、感動してしまいました。'
	DB	"Kiyomi:  I knew you'd win it. I'm so happy."
	DB	NEXT
;	DB	'【%001】：またまた。'
	DB	"%001:  Oh, come on."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M12:		;話す　清美３
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT02","C",0,0,3
;	DB	'【清美】：%001さん、これ、いかがです？'
	DB	"Kiyomi:  Would you like some of this?"
	DB	NEXT
;	DB	'【%001】：・・・どれどれ。'
	DB	"%001:  What? Where?"
	DB	NEXT
;	DB	'ぱく。'
	DB	"*gulp*"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................."
	DB	PAUSE
;	DB	'うん、美味い！'
	DB	"Mmm, it's good!"
	DB	NEXT
;	DB	'【清美】：お口に合って、何よりですわ・・・'
	DB	"Kiyomi:  I'm glad you liked it."
	DB	PAUSE
;	DB	'実はこれ、わたくしが作りましたの。'
	DB	" I made this for you."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M13:		;話す　清美４
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT02","C",0,0,3
;	DB	'【%001】：・・・新藤さんが？'
	DB	"%001:  You did?"
	DB	NEXT
;	DB	'【清美】：はい。いつまでも慎治ばかりに苦労を掛けてはいられませんもの。'
	DB	"Kiyomi:  Yes. I can't go on relying on Shinji forever,"
	DB	CR
	DB	"you know."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  I see."
	DB	FLG,F_COPYI,4,4
	DW	0000H

M14:		;話す　清美５
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT02","C",0,0,3
;	DB	'【%001】：・・・あ、これイケる。'
	DB	"%001:  This one is really good, too."
	DB	PAUSE
;	DB	'これも新藤さんが作ったの？'
	DB	" Did you make this, too?"
	DB	NEXT
;	DB	'【清美】：・・・いえ・・・それは慎治が。'
	DB	"Kiyomi:  Oh.....Shinji made that."
	DB	NEXT
;	DB	'【%001】：・・・・・・あ、そう。'
	DB	"%001:  ......Oh."
	DB	NEXT
;	DB	'（同じ容れ物に入ってるから、そうだと思ったんだけど・・・）'
	DB	"(I should have known that.)"
	DB	FLG,F_COPYI,4,5
	DW	0000H

M15:		;話す　清美６
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT02","C",0,0,3
;	DB	'【%001】：・・・じゃあ、こっちのは？'
	DB	"%001:  What about this?"
	DB	NEXT
;	DB	'【清美】：・・・それも慎治が・・・'
	DB	"Kiyomi:  Shinji made that, too."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか。'
	DB	"%001:  ...........Oh."
	DB	NEXT
;	DB	'（もしかして・・・新藤さんが作ったのって、さっきの奴だけと違うか？）'
	DB	"(I guess the only one Kiyomi made was the first one I"
	DB	CR
	DB	"ate.)"
	DB	FLG,F_COPYI,4,6
	DW	0000H

M16:		;話す　清美７
;	DB	'・・・止めよう。新藤さんが可哀想だ。'
	DB	"I'll stop asking her about the food. I feel sorry for"
	DB	CR
	DB	"her."
	DW	0000H

M17:		;話す　美緒１
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT03","C",0,10,7
;	DB	'【美緒】：%001先輩！受賞おめでとう！！'
	DB	"Mio:  Congratulations, %001!"
	DB	NEXT
;	DB	'【%001】：さんきゅ、美緒ちゃん。'
	DB	"%001:  Thanks, Mio."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M18:		;話す　美緒２
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT03","C",0,10,7
;	DB	'【美緒】：やっぱり、%001先輩はすごい人だ！'
	DB	"Mio:  I knew you'd be great out there."
	DB	PAUSE
;	DB	'あたし、今まで一番楽しかった！'
	DB	" I really had fun"
	DB	CR
	DB	"playing tennis with you."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  Me, too."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M19:		;話す　美緒３
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT03","C",0,10,7
;	DB	'【美緒】：ねえねえ先輩！これ食べてよ！'
	DB	"Mio:  Try some of this, will you?"
	DB	NEXT
;	DB	'【%001】：・・・どれどれ。'
	DB	"%001:  What? Where?"
	DB	NEXT
;	DB	'ぱく。'
	DB	"*gulp*"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................."
	DB	PAUSE
;	DB	'うん、美味い！'
	DB	"Delicious!"
	DB	NEXT
;	DB	'【美緒】：ホントに！？'
	DB	"Mio:  Really?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【美緒】：良かったぁ・・・'
	DB	"Mio:  That makes me happy."
	DB	FLG,F_COPYI,5,3
	DW	0000H

M20:		;話す　美緒４
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT03","C",0,10,7
;	DB	'【%001】：・・・そ～言えば、これは初めて食ったな・・・'
	DB	"%001:  This is new, isn't it?"
	DB	PAUSE
;	DB	'レパートリーが増えたの？'
	DB	" Is this the first time you've"
	DB	CR
	DB	"made this?"
	DB	NEXT
;	DB	'【美緒】：うん。この前お料理の本買って来たんだ。'
	DB	"Mio:  Yes. I bought a cookbook and tried some new things."
	DB	NEXT
;	DB	'【美緒】：先輩の口に合うかどうか不安だったんだけど・・・'
	DB	"Mio:  I wasn't sure if you'd like it."
	DB	NEXT
;	DB	'【%001】：・・・・・・そっか。'
	DB	"%001:  .........I like it."
	DB	FLG,F_COPYI,5,4
	DW	0000H

M21:		;話す　美緒５
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT03","C",0,10,7
;	DB	'【美緒】：・・・先輩、覚えてくれてたんだ。'
	DB	"Mio:  You actually remembered what I made before?"
	DB	NEXT
;	DB	'【%001】：そりゃあ覚えるさ。'
	DB	"%001:  Sure."
	DB	PAUSE
;	DB	'俺達が宴会やる時は、必ず何か作って来てくれるもんな。'
	DB	" Whenever we have a party, you always bring"
	DB	CR
	DB	"something."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  ........................."
	DB	NEXT
;	DB	'【%001】：ホント、いつも悪いよな。'
	DB	"%001:  Thanks for making it all the time."
	DB	FLG,F_COPYI,5,5
	DW	0000H

M22:		;話す　美緒６
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT03","C",0,10,7
;	DB	'【美緒】：・・・ううん。そんな事無い。'
	DB	"Mio:  No, I like to cook."
	DB	NEXT
;	DB	'【美緒】：みんな、あたしのお料理美味しそうに食べてくれるし・・・'
	DB	"Mio:  Especially for you. You always eat what I bring."
	DB	NEXT
;	DB	'【%001】：当然。美緒ちゃんの料理は美味いし、量もあるし。'
	DB	"%001:  Well, of course. It's really good."
	DB	NEXT
;	DB	'【美緒】：・・・・・・（ぽっ）'
	DB	"Mio:  .................Thank you."
	DB	FLG,F_COPYI,5,6
	DW	0000H

M23:		;話す　美緒７
;	DB	'【美緒】：・・・先輩！もっと食べてよ！'
	DB	"Mio:  Here, have some more!"
	DB	NEXT
;	DB	'【%001】：ああ、食ってるぜ。'
	DB	"%001:  Okay, thanks."
	DW	0000H

M24:		;話す　星愛１
	DB ANI,A_INIT
;	DB	'【%001】：・・・あれ？吉田は？'
	DB	"%001:  Huh? Where's Seia?"
	DB	NEXT
;	DB	BUF,B_COPY01
;	T_CG "CT08","C",0,35,4
;	DB	'【恵依美】：奥にいるわよ。先生になんか頼まれてたみたいだけど・・・'
	DB	"Meimi:  She's in the other room. Sensei wanted her to do"
	DB	CR
	DB	"some something for her."
	DB	PAUSE
;	DB	'呼んでこようか？'
	DB	" Shall I call her?"
	DB	NEXT
;	DB	'【%001】：・・・いや、別にいい。'
	DB	"%001:  .......No, that's fine."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M25:		;話す　星愛２
;	DB	'吉田は奥にいる。呼びに行くほどの用も無い。'
	DB	"Seia's not here. There's no reason to call her, either."
	DW	0000H

M26:		;話す　恵依美１
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT08","C",0,35,4
;	DB	'【恵依美】：%001、おめでと！'
	DB	"Meimi:  %001, congratulations!"
	DB	NEXT
;	DB	'【%001】：さんきゅ、中野。'
	DB	"%001:  Thanks, Meimi."
	DB	FLG,F_COPYI,7,1
	DW	0000H

M27:		;話す　恵依美２
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT08","C",0,35,4
;	DB	'【恵依美】：・・・しっかしまぁ、あんなムチャクチャなスケジュール良くこなしたわよねぇ。'
	DB	"Meimi:  You really were incredible, enduring a hard schedule"
	DB	CR
	DB	"like that."
	DB	NEXT
;	DB	'【%001】：・・・ま～な。'
	DB	"%001:  ........It wasn't that hard."
	DB	FLG,F_COPYI,7,2
	DW	0000H

M28:		;話す　恵依美３
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT08","C",0,35,4
;	DB	'【恵依美】：・・・ねえ%001・・・'
	DB	"Meimi:  %001..."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'【星愛】：・・・恵依美ちゃ～ん！ちょっと手伝って欲しいんですけどー！'
	DB	"Seia:  Meimi? Will you help me for a minute?"
	DB	NEXT
;	DB	'【恵依美】：・・・'
	DB	"Meimi:  ...................."
	DB	PAUSE
;	DB	'じゃ、また後でね！'
	DB	"Um, I'll be back!"
	DB	NEXT
;	DB	'【%001】：おう。'
	DB	"%001:  Okay."
	B_P1 B_SUDA
	DB	FLG,F_COPYI,7,3
	DW	0000H

M29:		;話す　恵依美４
;	DB	'中野は、さっき吉田に呼ばれて奥に行った。'
	DB	"Meimi went to help Seia."
	DB	NEXT
;	DB	'・・・・・・'
	DB	"................"
	DB	NEXT
;	DB	'しかし中野の奴、さっき何を言いかけたんだ？'
	DB	"What was she about to say to me a moment ago?"
	DW	0000H

M30:		;話す　亜希１
;	DB	'【%001】：・・・亜希ちゃんは・・・？'
	DB	"%001:  Where's Aki?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ..................."
	DB	NEXT
;	DB	'【%001】：・・・あんな隅っこで・・・'
	DB	"%001:  Why is she in the corner like that?"
	DB	FLG,F_COPYI,8,1
	DW	0000H

M31:		;話す　亜希２
;	DB	'【%001】：・・・よっ、亜希ちゃ・・・'
	DB	"%001:  .........Hey, Aki."
	DB	NEXT
;	DB	'【亜希】：・・・・・・（ささっ）'
	DB	"Aki:  ......................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  What's wrong with her? I've never seen her like"
	DB	CR
	DB	"this."
	DB	FLG,F_COPYI,8,2
	DW	0000H

M32:		;話す　亜希３
;	DB	'話そうとすると逃げちまう。無理に追い掛けてもいい事はないだろう。'
	DB	"If I talk to her, she'll just run away. There's no need"
	DB	CR
	DB	"to force it."
	DW	0000H

M33:		;話す　今日子１
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG "CT12","C",0,0,2
;	DB	'【今日子】：や～や～や～、めでたい！'
	DB	"Kyoko:  Congratulations!"
	DB	PAUSE
;	DB	'%001君、主役なんだからもっと飲まなきゃダメよ～。'
	DB	" %001, you're the guest of honor, so"
	DB	CR
	DB	"you have to drink more!"
	DB	NEXT
;	DB	'【%001】：飲んでますって。'
	DB	"%001:  I'm drinking!"
	DB	FLG,F_COPYI,9,1
	DW	0000H

M34:		;話す　今日子２
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG "CT12","C",0,0,2
;	DB	'【今日子】：ほらほらぁ、もっと飲んで飲んでぇ！'
	DB	"Kyoko:  You have to drink more!"
	DB	NEXT
;	DB	'言うが早いか、俺のコップになみなみと黒い酒を注ぐ。'
	DB	"Before I can say anything, Sensei has filled my glass with"
	DB	CR
	DB	"some kind of black alcohol."
	DB	NEXT
;	DB	'【%001】：あの・・・これにビール入ってたんですけど。'
	DB	"%001:  Um, there was beer in this glass..."
	DB	NEXT
;	DB	'【今日子】：だ～いじょ～ぶ。今注いだの、黒ビールだから。'
	DB	"Kyoko:  It's okay. What I just poured was black beer."
	DB	NEXT
;	DB	'【%001】：・・・そーゆー問題なのか・・・？'
	DB	"%001:  .............But you can't mix beers like that!"
	DB	FLG,F_COPYI,9,2
	DW	0000H

M35:		;話す　今日子３
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG "CT12","C",0,0,2
;	DB	'【今日子】：おやぁ？あんまり減ってないわね%001く～ん。'
	DB	"Kyoko:  You haven't drunk much of your beer, %001."
	DB	NEXT
;	DB	'【%001】：ええ、誰かさんがひっきりなしに注いでくれるもんですから。'
	DB	"%001:  Yes, whenever I drink some a certain person just"
	DB	CR
	DB	"fills it up again."
	DB	NEXT
;	DB	'【今日子】：じゃあしょーが無いわね。気持ちだけ注がせてね。'
	DB	"Kyoko:  Who would do a think like that?"
	DB	NEXT
;	DB	'ちょろろっ。'
	DB	"She fills my glass again."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【%001】：・・・・・・随分あっさりしてたな。めずらしい。'
	DB	"%001:  She's not forcing me to drink like she usually"
	DB	CR
	DB	"does..."
	DB	NEXT
;	DB	'【清美】：・・・宜しいのですか？'
	DB	"Kiyomi:  Did you see what she just poured into your"
	DB	CR
	DB	"glass?"
	DB	NEXT
;	DB	'【%001】：何が？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【清美】：今、先生が注いで行ったの・・・・・・'
	DB	"Kiyomi:  It was 'roshu'."
	DB	PAUSE
;	DB	'老酒ですわよ。'
	DB	" It's supposed to make men"
	DB	CR
	DB	"sexually virile."
	DB	NEXT
;	DB	'【%001】：・・・・・・マジ？'
	DB	"%001:  ......Are you serious?"
	DB	NEXT
;	DB	'【清美】：・・・・・・はい。'	
	DB	"Kiyomi:  Yes."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ....................."
	DB	FLG,F_COPYI,9,3
	DW	0000H

M36:		;話す　今日子４
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG "CT12","C",0,0,2
;	DB	'【今日子】：はいはい～、飲んで飲んで～。'
	DB	"Kyoko:  Drink! Drink!"
	DB	NEXT
;	DB	'【%001】：・・・飲んでますってば。'
	DB	"%001:  ........I am!"
	DW	0000H

M37:		;話す　慎治１
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG "CT11","C",0,30,8
;	DB	'【慎治】：・・・・・・あの・・・・・・'
	DB	"Shinji:  ......Excuse me?"
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ................."
	DB	PAUSE
;	DB	'ん？'
	DB	"Yes?"
	DB	PAUSE
;	DB	'・・・慎治君か？'
	DB	"Oh, it's Shinji."
	DB	NEXT
;	DB	'【慎治】：・・・・・・はい。あの・・・・・・'
	DB	"Shinji:  Um, %001? I'd like to, um, say....."
	DB	PAUSE
;	DB	'おめでとうございます。'
	DB	" Congratulations."
	DB	NEXT
;	DB	'【%001】：・・・ああ。さんきゅ、慎治君。'
	DB	"%001:  Ah, thanks."
	DB	FLG,F_COPYI,10,1
	DW	0000H

M38:		;話す　慎治２
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG "CT11","C",0,30,8
;	DB	'【%001】：・・・しっかし、慎治君が来てくれるとは思わなかったな。'
	DB	"%001:  I'm glad you're here tonight."
	DB	NEXT
;	DB	'【慎治】：・・・・・・え・・・・・・'
	DB	"Shinji:  ......Why?"
	DB	NEXT
;	DB	'【%001】：・・・ほら、いつも新藤さんが持って来てたからさ。'
	DB	"%001:  Kiyomi always brings food for us, but you're the"
	DB	CR
	DB	"one making it."
	DB	PAUSE
;	DB	'いつも悪いな。俺達の為に余分に料理作らされちゃって。'
	DB	" Thanks for making such great food for us all"
	DB	CR
	DB	"the time."
	DB	NEXT
;	DB	'【慎治】：・・・・・・そんな・・・・・・悪いだなんて・・・・・・'
	DB	"Shinji:  .......It's nothing, really."
	DB	FLG,F_COPYI,10,2
	DW	0000H

M39:		;話す　慎治３
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG "CT11","C",'K',30,8
;	DB	'【慎治】：・・・・・・僕、料理とか結構好きだし・・・・・・'
	DB	"Shinji:  I really like to cook, and..."
	DB	PAUSE
;	DB	'それに！',PAUSE,'・・・その・・・みんなが喜んでくれたら・・・'
	DB	" And, well...",PAUSE," I'm"
	DB	CR
	DB	"really glad you like it."
	DB	NEXT
;	DB	'【%001】：・・・・・・ああ、分かるぜその気持ち。'
	DB	"%001:  We all do."
	DB	NEXT
;	DB	'【慎治】：・・・ホントですか！？'
	DB	"Shinji:  You do?!"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yes."
	DB	PAUSE
;	DB	'慎治君みたいに料理で、って訳じゃないけどな。'
	DB	" None of us can cook like you can."
	DB	PAUSE
;	DB	'気持ちは分かるぜ・・・きっと、同じ気持ちだと思うから。'
	DB	" So it means a"
	DB	CR
	DB	"lot to us that you care so much."
	DB	NEXT
;	DB	'【慎治】：・・・・・・そうですか・・・・・・！'
	DB	"Shinji:  .......Really?"
	DB	FLG,F_COPYI,10,3
	DW	0000H

M40:		;話す　慎治４
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG "CT11","C",0,30,8
;	DB	'【慎治】：・・・僕、来て良かったです。%001・・・兄ちゃんのお話が聞けて。'
	DB	"Shinji:  I'm glad I came. Thanks, %001..."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか？'
	DB	"%001:  I'm glad you came, too."
	DB	NEXT
;	DB	'【慎治】：はい！'
	DB	"Shinji:  Thanks!"
	DB	NEXT
	T_CG "CT12","C",0,0,2
	DB ANI,A_ON,8
;	DB	'【今日子】：・・・・・・'
	DB	"Kyoko:  ............"
	DB	PAUSE
;	DB	'あ～ら、この子が清美ちゃんの弟さん？'
	DB	"Is this Kiyomi's little brother?"
	DB	NEXT
;	DB	'【慎治】：・・・・・・は、はい。'
	DB	"Shinji:  ..........Y- Yes."
	DB	NEXT
;	DB	'【今日子】：私がぁ、清美ちゃんの担任の小林今日子よん☆'
	DB	"Kyoko:  Well, boy, I'm your sister's homeroom professor."
	DB	NEXT
;	DB	'【慎治】：・・・・・・・・・は、はい。宜しくお願いします・・・・・・・・・'
	DB	"Shinji:  ...........It- it's nice to meet you!"
	DB	NEXT
;	DB	'【今日子】：あら～☆話に聞いてた以上にかわいいのね～。'
	DB	"Kyoko:  You're so cute!"
	DB	PAUSE
;	DB	'料理も上手だしィ～、将来いいお嫁さんになれるわよぉ？'
	DB	" And you're such a good cook. You'll"
	DB	CR
	DB	"make someone a fine wife someday!"
	DB	NEXT
	DB ANI,A_OFF
	T_CG "CT11","C",'D',30,7
	DB ANI,A_ON,2
;	DB	'【慎治】：・・・・・・・・・あの、僕、男ですけど。'
	DB	"Shinji:  I'm a boy!"
	DB	FLG,F_COPYI,10,4
	DW	0000H

M41:		;話す　慎治５
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG "CT11","C",0,30,8
;	DB	'【%001】：慎治君、気にすんなって。'
	DB	"%001:  Don't worry about her, Shinji."
	DB	PAUSE
;	DB	'このおばさん、ただの酔っぱらいだから。'
	DB	" This old lady's just"
	DB	CR
	DB	"angry because she can't get married."
	DB	NEXT
	T_CG "CT12","C",0,0,2
	DB ANI,A_ON,8
;	DB	'【今日子】：・・・・・・・・・'
	DB	"Kyoko:  ............"
	DB	PAUSE
;	DB	'%001くぅ～ん。な・に・かぁ聞こえたんだけどぉ～？'
	DB	"%001-kuun, did you just say something?"
	DB	NEXT
;	DB	'【%001】：・・・う・・・'
	DB	"%001:  ........Me?"
	DB	PAUSE
;	DB	'い、いや。何にも言ってねぇです。'
	DB	" No, I didn't say anything."
	DB	NEXT
;	DB	'【今日子】：・・・後で覚えてなさいよ（ぼそっ）'
	DB	"Kyoko:  .......I think you did."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・あう・・・・・・・・・'
	DB	"%001:  Uh-oh."
	DB	NEXT
;	DB	'【今日子】：・・・・・・'
	DB	"Kyoko:  ..................."
	DB	PAUSE
;	DB	'ねぇ慎治君。お近づきのしるしに、い・い・も・のあげる☆'
	DB	"Shinji, can I give you a present?"
	DB	NEXT
;	DB	'【慎治】：・・・・・・は、はい？'
	DB	"Shinji:  .....Yes?"
	DB	NEXT
;	DB	'【今日子】：・・・星愛ちゃ～ん！'
	DB	"Kyoko: Oh, Seia? Bring it in!"
	DB	NEXT
;	DB	'【星愛】：・・・・・・',PAUSE,'はーい！'
	DB	"Seia:  ....................",PAUSE,"Coming!"
	DB	NEXT
;	DB	'奥から現れた吉田が、手に持っていたものを広げた瞬間・・・'
;	DB	'俺達は凍り付いた。'
	DB	"The moment Seia brought it out and spread it on the"
	DB	CR
	DB	"table, I froze."
	DB	NEXT
;	DB	'【%001】：・・・・・・それってもしかして・・・・・・'
	DB	"%001:  Is that, is that...?"
	DB	PAUSE
;	DB	'せぇらぁふく！？'
	DB	" Your high school uniform?"
	DB	NEXT
;	DB	'【今日子】：ぴんぽーん！私のお古だけどぉ、慎治君にはピッタリだと思うのよね～。'
	DB	"Kyoko:  Good guess! It's a little old, but I thought it'd"
	DB	CR
	DB	"look wonderful on Shinji."
	DB	NEXT
	T_CG "CT11","C",'I',30,7
	DB ANI,A_ON,2
;	DB	'【慎治】：・・・・・・・・・'
	DB	"Shinji:  ................................."
	DB	NEXT
;	DB	'【星愛】：・・・ふっふっふ、わたくしもそう思いましてよ。'
	DB	"Seia:  I thought so, too."
	DB	PAUSE
;	DB	'ね、恵依美ちゃん？'
	DB	" Isn't that right, Meimi?"
	DB	NEXT
;	DB	'【恵依美】：・・・あは、あは、あはははは・・・'
	DB	"Meimi:  Yeah, hahaha..."
	DB	NEXT
;	DB	'【%001】：・・・吉田。酔ってるだろお前。'
	DB	"%001:  ....Seia, you're drunk again, aren't you?"
	DB	NEXT
;	DB	'【星愛】：・・・ふっふっふっふっふ。さぁ、せっかく仕立て直したのですから着て頂かないと・・・'
	DB	"Seia:  Well, we've brought it out. We have to have him"
	DB	CR
	DB	"try it on, now!"
	DB	NEXT
;	DB	'【慎治】：・・・・・・・・・・・・・・・・'
	DB	"Shinji:  ........................."
	DB	PAUSE
	B_O B_SUDA
;	DB	'（だだだだだっ！）'
	DB	"He's gone!"
	DB	NEXT
;	DB	'【今日子】：あっ！逃げちゃダメよ！'
	DB	"*pater pater pater*"
	DB	NEXT
;	DB	'【星愛】：逃がしませんことよ～。'
	DB	"Seia:  Don't let him get away!"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  Hey, stop that! What are you idiots doing?"
	DB	PAUSE
;	DB	'中野っ！吉田を止めろっ！'
	DB	" Meimi!"
	DB	CR
	DB	"Stop Seia!"
	DB	NEXT
;	DB	'【恵依美】：う、うん！'
	DB	"Meimi:  Alright!"
	DB	PAUSE
;	DB	'ちょっと星愛ぁ！やっぱり止めようよっ！'
	DB	" Come on, Seia! You're going to scar him for"
	DB	CR
	DB	"life!"
	DB	NEXT
;	DB	'【鈴子】：ちょっと先生！悪ノリし過ぎですよ！'
	DB	"Reiko:  Sensei, you've got to stop that!"
	DB	NEXT
;	DB	'【清美】：まあ、どうしましょう。'
	DB	"Kiyomi:  What shall we do?"
	DB	NEXT
;	DB	'【美緒】：慎治君！こっちこっち！'
	DB	"Mio:  Shinji, come this way! We'll protect you!"
	DB	NEXT
;	DB	'どたばたどたばたどた'
	DB	"*pater pater pater*"
	DB	NEXT
;	DB	'【%001】：・・・あ～あ～なんだかなぁもぉ・・・'
	DB	"%001:  Well, things haven't changed much around here."
	DB	NEXT
	DB	SINARIO,'CS814.OVL',0
	DW	0000H


end
