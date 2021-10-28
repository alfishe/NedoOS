;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２４＿１
;		学園祭２日目　３人娘と俺

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7, S8, S9
MSGTBL:
        DW	M1
COMTBL:
        DW	CM1, CM2, CM3, CM4
VNTBL:
        DW	V_FNAME,N_FNAME
ENDTBL:

        INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
        INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,-1
CM2:	DW	VV2,	NN1,NN2,NN3,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'釣る',0
VV4:	DB	4,	'TRY YOUR LUCK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'清美',0
NN2:	DB	2,	'KIYOMI',0
;NN3:	DB	3,	'美緒',0
NN3:	DB	3,	'MIO',0
;NN4:	DB	4,	'釣り堀',0
NN4:	DB	4,	'FISH POND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子
S2:		DW	VV1, NN2,  2, M3		;見る　清美
S3:		DW	VV1, NN3,  3, M4		;見る　美緒
S4:		DW	VV1, NN4,  4, M5		;見る　釣り堀
S5:		DW	VV2, NN1,  5, M6		;話す　鈴子
S6:		DW	VV2, NN2,  6, M7		;話す　清美
S7:		DW	VV2, NN3,  7, M8		;話す　美緒
S8:		DW	VV3, -1,  8, M9		;考える
S9:		DW	VV4, -1,  9, M10		;釣る


;イニシャルメッセージ
M1:
        DB	BGM,24
        B_O B_SUDA
        BAK_INIT "AB_24"
        ;	DB	'いろいろな出し物を見て回ってきたけど、その度に新藤さんの手際の良さに感心していた。'
        DB	"I went around with Kiyomi, looking at the various events"
        DB	CR
        DB	"the other classes put on."
        DB	NEXT
        ;	DB	'なにしろ、どうやって計算したのか知らないけど、それぞれの出し物での最良のポジションを確実に押さえているのだから。'
        DB	"Each time, Kiyomi managed to escort me to each event"
        DB	CR
        DB	"at the best possible time."
        DB	NEXT
        ;	DB	'ウチのクラスの喫茶店が繁盛しているのも、新藤さんの緻密な計算の賜物だろう。'
        DB	"The coffee shop that our class put on was great, too."
        DB	NEXT
        ;	DB	'・・・んで、今どこにいるかというと、釣り堀だったりする。
        DB	"And now we were at the fishing pond again."
        DB	BUF,B_COPY01
        TU_CG 'CT03','C',0,20,2
        TU_CG 'CT02','C',0,0,3
        T_CG 'CT01','C','D',12,4
        DB	ANI,A_ON,2
        DB	ANI,A_ON,3
        DB	C_BLD,C_V_ON,4
        DW	0000H
        
M2:		;見る　鈴子
        ;	DB	'少し、不機嫌に見える。'
        DB	"She looks a little upset."
        DB	NEXT
        ;	DB	'・・・プールが釣り堀にされているのが気に入らないようだ。'
        DB	"It's understandable. Her pool was turned into a fishpond."
        DW	0000H
        
M3:		;見る　清美
        ;	DB	'どういう訳か、熱心に釣りをしている。'
        DB	"She's trying to catch a fish."
        DB	NEXT
        ;	DB	'・・・割と真剣だ。'
        DB	"I've never seen her serious about anything."
        DW	0000H
        
M4:		;見る　美緒
        ;	DB	'俺が釣った魚を覗き込んでは観察したり、数えたりを繰り返している。'
        DB	"She's looking at the fish I've caught."
        DB	NEXT
        ;	DB	'・・・なんにせよ、楽しそうだからいいか。'
        DB	"She seems to be having fun, so I guess it's okay."
        DW	0000H
        
M5:		;見る　釣り堀
        ;	DB	'そこそこ、繁盛してはいるようだ。'
        DB	"This isn't that difficult."
        DB	NEXT
        ;	DB	'・・・釣りをする、と言うより、待ち合わせ場所に利用している人間の方が多いような気もする。'
        DB	"There's not much more to fishing then meeting the fish"
        DB	CR
        DB	"with your hook at a certain time and place."
        DW	0000H
        
M6:		;話す　鈴子
        ;	DB	'【%001】：あれ？鈴子さん、釣らないの？'
        DB	"%001:  Reiko, aren't you going to try to get any fish?"
        DB	NEXT
        ;	DB	'【鈴子】：・・・私は、プールでは泳ぐことに決めてるの。'
        DB	"Reiko:  ......I want to go swimming."
        DB	NEXT
        ;	DB	'【%001】：はぁ・・・さいですか。'
        DB	"%001:  .......Oh."
        EF_SET 101
        DW	0000H
        
M7:		;話す　清美
        ;	DB	'【%001】：新藤さん、どう？釣れてる？'
        DB	"%001:  Kiyomi, how is it going? Are you catching a lot"
        DB	CR
        DB	"of fish?"
        DB	NEXT
        ;	DB	'【清美】：・・・・・・'
        DB	"Kiyomi:  .............................."
        DB	NEXT
        ;	DB	'【%001】：・・・新藤さん？'
        DB	"%001:  Kiyomi?"
        DB	NEXT
        ;	DB	'・・・ダメだ完全にハマってるらしい。回復は時間に任せるしかない。'
        DB	"It's no use. She's so intent on the fish that she can't"
        DB	CR
        DB	"even hear me."
        EF_SET 102
        DW	0000H
        
M8:		;話す　美緒
        ;	DB	'【%001】：釣らないの？美緒ちゃん。'
        DB	"%001:  Aren't you going to try for any fish?"
        DB	NEXT
        ;	DB	'【美緒】：うん・・・魚がかわいそうだから・・・'
        DB	"Mio:  ..............I just feel sorry for the fish."
        DB	NEXT
        ;	DB	'【%001】：そか・・・優しいんだな、美緒ちゃん。'
        DB	"%001:  Oh, well, that's awfully nice of you, Mio."
        DB	NEXT
        ;	DB	'【美緒】：え・・・？そ、そうかな？'
        DB	"Mio:  Really? I don't think so."
        EF_SET 103
        DW	0000H
        
M9:		;考える
        ;	DB	'・・・でもまあ、息抜きにはちょうどいいよな。'
        DB	"The fishing pond is a nice place to sit down and relax."
        DB	NEXT
        ;	DB	'きっと新藤さん、その辺まで計算したんだろうな。'
        DB	"I'm sure Kiyomi had thought of that when she led me here."
        DB	NEXT
        ;	DB	'【清美】：まあ、逃げられてしまいましたわ。'
        DB	"Kiyomi:  I lost him!"
        DB	NEXT
        ;	DB	'・・・でも、自分がハマる事は計算外だったと思うぞ？'
        DB	"I'm sure she didn't plan on getting hooked on fishing herself."
        DW	0000H
        
M10:		;釣る
        ;	DB	'【%001】：よーし・・・ほいっ、と。'
        DB	"%001:  Got another one."
        DB	NEXT
        K_CG 'CT03','K',20,5
        DB	ANI,A_ON,4
        DB	ANI,A_ON,3
        ;	DB	'【美緒】：わー、%001先輩、上手！'
        DB	"Mio:  %001, you're great!"
        DB	NEXT
        ;	DB	'【%001】：・・・まあ、昨日さんざんやったからなあ。'
        DB	"%001:  I got a lot of practice going up against the"
        DB	CR
        DB	"dean yesterday."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・'
        DB	"Reiko:  ......................."
        DB	NEXT
        ;	DB	'【%001】：どしたの？鈴子さん、機嫌悪そうだけど？'
        DB	"%001:  What's wrong, Reiko? You look upset."
        DB	NEXT
        ;	DB	'【鈴子】：だって・・・毎年どこかのクラスが釣り堀やるんだけど、その後掃除が終わるまでプールがつかえなくなるんだもの。'
        DB	"Reiko:  Every year some class uses the pool for a fish"
        DB	CR
        DB	"pond. It keeps me from be swimming when I want to."
        DB	NEXT
        TU_CG 'CT03','C',0,20,2
        TU_CG 'CT02','C',0,0,3
        T_CG 'CT01','C','D',12,4
        DB	ANI,A_ON,4
        DB	ANI,A_ON,3
        ;	DB	'【美緒】：あ・・・ごめんなさい・・・'
        DB	"Mio:  .....I'm sorry."
        DB	NEXT
        K_CG 'CT01','V',12,6
        DB	ANI,A_ON,2
        DB	ANI,A_ON,3
        ;	DB	'【鈴子】：あ・・・その、美緒ちゃんを怒ってるわけじゃなくてね・・・'
        DB	"Reiko:  No, I'm not angry with you."
        DB	NEXT
        ;	DB	'【%001】：美緒ちゃん、鈴子さんは毎年プールが事えなくなることに腹を立ててるだけで、今年はどのクラスがやったか、なんて気にしちゃいないよ。'
        DB	"%001:  Reiko's upset that the pool is always used for a"
        DB	CR
        DB	"fish pond, but she's not angry with your class specifically."
        DB	NEXT
        ;	DB	'【鈴子】：そ、そうそう！'
        DB	"Reiko:  That's right!"
        DB	NEXT
        ;	DB	'【%001】：何たって根が単純だから・・・'
        DB	"%001:  She always talks too much."
        DB	NEXT
        K_CG 'CT01','D',12,4
        DB	ANI,A_ON,2
        DB	ANI,A_ON,3
        ;	DB	'【鈴子】：そうそう・・・なんですって！？'
        DB	"Reiko:  That's right...Wait, I what?!"
        DB	NEXT
        ;	DB	'【%001】：あ～～、鈴子さん、大きい声出さないで、魚が逃げる、逃げる！'
        DB	"%001:  Reiko, don't raise your voice like that. You're"
        DB	CR
        DB	"scaring the fish away."
        DB	NEXT
        ;	DB	'【鈴子】：ごまかされないわよ！もう、%001君・・・'
        DB	"Reiko:  Don't try to change the subject..."
        DB	NEXT
        ;	DB	'【清美】：まあ、見て下さいみなさん、わたくし、お魚さんを釣り上げましたわ！'
        DB	"Kiyomi:  Look, everyone! I caught a fish!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ..............................."
        DB	NEXT
        ;;	DB	'【美緒】：・・・・・・'
        DB	"Mio:  ..............................."
        DB	NEXT
        ;	DB	'【鈴子】：・・・清美ちゃん・・・あなた、ホントにマイペースよねぇ・・・'
        DB	"Reiko:  That's, um, nice Kiyomi."
        DB	NEXT
        ;	DB	'【清美】：まあ、困りましたわ。わたくし、これからどうすれば良いのでしょうか？'
        DB	"Kiyomi:  What should I do with the fish now?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ..............................."
        DB	NEXT
        ;	DB	'内心はともかく、外見と声はちっとも困ってなさそうな新藤さんの持つ竿には、'
        ;	DB	'鯉が一匹迷惑そうにぶら下がっていた・・・'
        DB	"In Kiyomi's unsure hands was a fish, flopping around"
        DB	CR
        DB	"trying to escape."
        DB	NEXT
        DB	SINARIO,'CS824_2.OVL',0
        DW	0000H
        
M_EXIT:	
        DB	FLG,F_COPYI,100,1
        DB	FLG,F_MAND,4,100,101,102,103
        DB	FLG,F_EXIT,100
        DB	C_BLD,C_V_OFF,4
        DW	0000H


end
