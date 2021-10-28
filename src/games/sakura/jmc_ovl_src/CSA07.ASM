;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０７
;		旅館

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7, S8
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
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,NN6,NN7,NN8,-1

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
;NN6:	DB	6,	'瑠璃',0
NN6:	DB	6,	'RURI',0
;NN7:	DB	7,	'亜希',0
NN7:	DB	7,	'AKI',0
;NN8:	DB	8,	'今日子',0
NN8:	DB	8,	'KYOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　みんな２
S2:		DW	VV2, NN2,  2, M4		;話す　誠
S3:		DW	VV2, NN3,  3, M5		;話す　鈴子
S4:		DW	VV2, NN4,  4, M6		;話す　清美
S5:		DW	VV2, NN5,  5, M7		;話す　美緒
S6:		DW	VV2, NN6,  6, M8, M9		;話す　瑠璃２
S7:		DW	VV2, NN7,  7, M10, M11		;話す　亜希２
S8:		DW	VV2, NN8,  8, M12, M13		;話す　今日子２


;イニシャルメッセージ
M1:
        DB	BGM,21
        ;山道
        BAK_INIT 'AB_08_1'
        ;	DB	'・・・Ｍ県県庁所在地のＳ市まで新幹線で２時間、そこから鈍行に乗り換えて１時間。さらに山道を登ること３０分・・・'
        DB	"It was two hours by Shinkansen to M Prefecture, just"
        DB	CR
        DB	"north of Tokyo, where our destination lie. Then a half"
        DB	CR
        DB	"hour up into the mountains."
        DB	NEXT
        ;	DB	'【今日子】：ちょ・・・・・・ちょっと休まない？'
        DB	"Kyoko:  Wow, I'm tired. Can we rest a bit?"
        DB	NEXT
        ;	DB	'【%001】：またですか、先生。'
        DB	"%001:  Again, Sensei?"
        DB	NEXT
        ;	DB	'【鈴子】：私も・・・ちょっと休憩・・・。'
        DB	"%001:  Me too...I can't catch my breath..."
        DB	NEXT
        ;	DB	'【清美】：わたくしもですわ・・・'
        DB	"Kiyomi:  I'm tired, too!"
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG 'CT06','C',0,30,1
        ;	DB	'【亜希】：何よ、みんなだらしないなぁ。'
        DB	"Aki:  What are you all doing, resting here? We still have"
        DB	CR
        DB	"a ways to go!"
        DB	NEXT
        T_CG 'CT03','C',0,0,2
        DB	ANI,A_ON,1
        ;	DB	'【美緒】：仕方ないよ、みんなは山道に慣れてないんだから。'
        DB	"Mio:  They're tired. You can't blame them."
        DW	0000H
        
        
M2:		;見る　みんな１
        ;	DB	'今日子先生に鈴子さん、新藤さんがへたり込んでる。'
        DB	"Kyoko-sensei, Reiko and Kiyomi are all resting."
        DB	NEXT
        ;	DB	'・・・さっきから何度目の休憩だろう。'
        DB	".........This is the sixth time in thirty minutes!"
        DB	NEXT
        ;	DB	'確かに、この道は結構勾配がきついけど。'
        DB	"Well, I can't blame them. This is a pretty steep climb."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
        
M3:		;見る　みんな２
        ;	DB	'俺、美緒ちゃん、亜希ちゃん、白水さんはまだまだ元気だ。'
        DB	"Mio, Aki, Ruri and me are all doing fine."
        DB	NEXT
        ;	DB	'・・・白水さんが元気なのはけっこー意外だったが。'
        DB	"It's surprising to see Ruri being so happy."
        DB	NEXT
        ;	DB	'誠に至っては、「斥候に行ってくる」とか言って先に行ってしまった。'
        DB	"Makoto's up ahead of us, doing reconnaissance."
        DB	FLG,F_COPYI,1,0
        EF_SET 101
        DW	0000H
        
M4:		;話す　誠
        ;	DB	'（斥候に行ってしまって、ここにはいない。）'
        DB	"He's on reconnaissance. He's not here."
        DB	NEXT
        ;	DB	'（しかし、こんなとこまでエアーガン持って来んでも・・・）'
        DB	"Why did he bring his air gun with him up here, I wonder?"
        DW	0000H
        
        
M5:		;話す　鈴子
        ;	DB	'【鈴子】：ふぅ・・・山道は歩き慣れてないのよ。'
        DB	"Reiko:  I'm not used to walking up in the mountains like"
        DB	CR
        DB	"this."
        DB	NEXT
        ;	DB	'【%001】：鈴子さんの場合、川を登ってった方が速かったりしてね。'
        DB	"%001:  You'd be more at home just swimming up a river..."
        DB	NEXT
        ;	DB	'【鈴子】：鮭じゃないんだから・・・'
        DB	"Reiko:  I'm not a salmon!"
        EF_SET 103
        DW	0000H
        
M6:		;話す　清美
        ;	DB	'【清美】：早く温泉につかりたいですわ・・・'
        DB	"Kiyomi:  I want to get to the ryokan and get into the"
        DB	CR
        DB	"hot springs!"
        DB	NEXT
        ;	DB	'【%001】：歩かないと、いつまでたってもつかねぇぞ。'
        DB	"%001:  If you don't start walking, you'll never get "
        DB	CR
        DB	"there."
        EF_SET 104
        DW	0000H
        
        
M7:		;話す　美緒
        ;	DB	'【%001】：美緒ちゃんは元気だね。'
        DB	"%001:  You're don't seem tired at all."
        DB	NEXT
        ;	DB	'【美緒】：うん、山、好きだから。'
        DB	"Mio:  No, I like it up here."
        EF_SET 105
        DW	0000H
        
M8:		;話す　瑠璃１
        ;	DB	'【瑠璃】：・・・ここを越えると、梅の林があるわ・・・'
        DB	"Ruri:  ...........There's a patch of plum trees just up ahead."
        DB	NEXT
        ;	DB	'【%001】：え？白水さん、ここに来たことあるのか？'
        DB	"%001:  Ruri, have you been here before?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・ないわ。'
        DB	"Ruri:  ......No."
        DB	NEXT
        ;	DB	'【清美】：まあ・・・ほほほほ・・・'
        DB	"Kiyomi:  Haha...Hohohoho!"
        DB	NEXT
        ;	DB	'白水さんの言葉を聞いて、新藤さんだけが楽しそうに笑い出した。'
        DB	"Kiyomi hear what Ruri said and started laughing."
        DB	NEXT
        ;	DB	'【鈴子】：・・・今の、どこかギャグになってたの？'
        DB	"Reiko:  .......What was funny about what Ruri said?"
        DB	NEXT
        ;	DB	'【美緒】：わ・・・わかんない・・・'
        DB	"Mio:  I don't know."
        DB	NEXT
        DB	"%001:  .............................."
        DB	FLG,F_COPYI,6,1
        DW	0000H
        
M9:		;話す　瑠璃２
        ;	DB	'【%001】：白水さん、さっきのどーゆー意味？'
        DB	"%001:  Ruri, what did you mean just now?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・。'
        DB	"Ruri:  ............................"
        DB	NEXT
        ;	DB	'（こころなしか、少し恥ずかしそうにしてる・・・？）'
        DB	"Sometimes I wonder about that girl. She seems to have"
        DB	CR
        DB	"some kind of super powers."
        EF_SET 107
        DW	0000H
        
M10:		;話す　亜希１
        ;	DB	'【亜希】：先輩、この人達は置いといて先に行こうよ。'
        DB	"Aki:  %001, why don't we go on without the others?"
        DB	NEXT
        ;	DB	'【%001】：そうもいかないだろ。'
        DB	"%001:  We can't do that, Aki."
        DB	NEXT
        ;	DB	'【亜希】：今日子先生がいるから大丈夫よ。'
        DB	"Aki:  Kyoko-sensei's here. They'll be fine."
        DB	NEXT
        ;	DB	'【%001】：先生がいるから不安なんだよ。'
        DB	"%001:  It's because she's here that I'm worried."
        DB	NEXT
        ;	DB	'【亜希】：あ、そうか。'
        DB	"Aki:  Oh."
        DB	NEXT
        ;	DB	'【今日子】：そこそこ、納得しないよーに。'
        DB	"Kyoko:  Hey, don't listen to him!"
        DB	FLG,F_COPYI,7,1
        EF_SET 106
        DW	0000H
        
M11:		;話す　亜希２
        ;	DB	'【亜希】：だらしないわよ、みんな。'
        DB	"Aki:  They're so lazy. Why aren't they walking?"
        DW	0000H
        
M12:		;話す　今日子
        ;	DB	'【%001】：せんせー、しっかりしてよ。引率者だろ？'
        DB	"%001:  Sensei, let's go! You're our leader, aren't you?"
        DB	NEXT
        ;	DB	'【今日子】：後１０分、休ませて・・・'
        DB	"Kyoko:  Let me rest a little longer..."
        DB	NEXT
        ;	DB	'【%001】：先生、お酒を減らして運動しないと太るよ。'
        DB	"%001:  Sensei, if you'd left some of that sake behind"
        DB	CR
        DB	"you'd be better off now."
        DB	FLG,F_COPYI,8,1
        DW	0000H
        
M13:		;話す　今日子２
        ;	DB	'【%001】：せんせー、ほら、立って！'
        DB	"%001:  Come on, Sensei, let's go!"
        DB	NEXT
        ;	DB	'【今日子】：後５分・・・'
        DB	"Kyoko:  Just five more minutes..."
        DB	NEXT
        ;	DB	'【%001】：先生、お酒を減らして運動しないと早く老けるよ。'
        DB	"%001:  You should cut down on the amount you drink. You'd"
        DB	CR
        DB	"be in better shape."
        DB	NEXT
        ;	DB	'【今日子】：うっさいわね～・・・'
        DB	"Kyoko:  Shut up!"
        EF_SET 102
        DW	0000H
        
M_EXIT:		
        DB FLG,F_COPYI,255,1
        DB FLG,F_MAND,8,255,101,102,103,104,105,106,107
        DB FLG,F_EXIT,255
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG 'CT14','C',0,10,3
        ;	DB	'【誠】：隊長どのぉ！'
        DB	"Makoto:  Colonel! I've scouted the area and returned!"
        DB	NEXT
        ;	DB	'【%001】：うわっ！？'
        DB	"%001:  Wah!!"
        DB	NEXT
        ;	DB	'突然、茂みの中から誠が飛び出して来た。'
        DB	"Suddenly Makoto returns from the undergrowth."
        DB	NEXT
        ;	DB	'【%001】：・・・何でこんなとこから出てくるんだよ！'
        DB	"%001:  Don't surprise me like that!"
        DB	NEXT
        ;	DB	'【誠】：敵兵に見つからないためでありますッ！'
        DB	"Makoto:  I spotted the enemy, sir!"
        DB	NEXT
        ;	DB	'【%001】：・・・で、旅館は見つかったのか？'
        DB	"%001:  ...You found the ryokan?"
        DB	NEXT
        ;	DB	'【誠】：あぁ、１０分も歩けば着くよ。'
        DB	"Makoto:  .....Yes, ten minutes up the trail."
        DB	NEXT
        ;	DB	'【%001】：みんな、後１０分だってさ！'
        DB	"%001:  Everyone, let's go! Just ten minutes more!"
        DB	NEXT
        ;	DB	'【今日子】：もうすぐ、「温泉で一杯」が出来るのね！？'
        DB	"Kyoko:  We'll be there soon? I can have my drink in the"
        DB	CR
        DB	"hot springs?"
        DB	NEXT
        ;	DB	'【今日子】：みんな、休憩は終わり、出発するわよ！'
        DB	"Kyoko:  Okay, let's go!"
        DB	NEXT
        DB SINARIO,'CSA08.OVL',0
        DW	0000H


end
