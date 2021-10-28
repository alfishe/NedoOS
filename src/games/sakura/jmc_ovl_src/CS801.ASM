	;	;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０１
;		体育祭前　地獄の始まり

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,NN8,NN9,NN10,-1
CM2:	DW	VV2,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,NN8,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	'MAKOTO',0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	'REIKO',0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'KIYOMI',0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	'MIO',0
;NN5:	DB	5,	'星愛',0
NN5:	DB	5,	'SEIA',0
;NN6:	DB	6,	'恵依美',0
NN6:	DB	6,	'MEIMI',0
;NN7:	DB	7,	'亜希',0
NN7:	DB	7,	'AKI',0
;NN8:	DB	8,	'祥子',0
NN8:	DB	8,	'SHOKO',0
;NN9:	DB	9,	'まわり',0
NN9:	DB	9,	'EVERYONE',0
;NN10:	DB	10,	'女の戦い',0
NN10:	DB	10,	"THE GIRLS",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　誠
S2:		DW	VV1, NN2,  2, M3, M4		;見る　鈴子２
S3:		DW	VV1, NN3,  3, M5		;見る　清美
S4:		DW	VV1, NN4,  4, M6		;見る　美緒
S5:		DW	VV1, NN5,  5, M7		;見る　星愛
S6:		DW	VV1, NN6,  6, M8		;見る　恵依美
S7:		DW	VV1, NN7,  7, M9		;見る　亜希
S8:		DW	VV1, NN8,  8, M10		;見る　祥子
S9:		DW	VV1, NN9,  9, M11		;見る　まわり
S10:		DW	VV1, NN10,  10, M12, M13		;見る　女の戦い
S11:		DW	VV2, NN1,  11, M14, M15		;話す　誠２
S12:		DW	VV2, NN2,  12, M16, M17, M18, M19, M20		;話す　鈴子５
S13:		DW	VV2, NN3,  13, M21		;話す　清美
S14:		DW	VV2, NN4,  14, M22		;話す　美緒
S15:		DW	VV2, NN5,  15, M23		;話す　星愛
S16:		DW	VV2, NN6,  16, M24		;話す　恵依美
S17:		DW	VV2, NN7,  17, M25		;話す　亜希
S18:		DW	VV2, NN8,  18, M26		;話す　祥子
S19:		DW	VV3, -1,  19, M27		;考える


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT "AB_36_3"
;	DB	'・・・・・・秋空が美しい１０月。'
	DB	"......It's October."
	DB	NEXT
;	DB	'今日子先生はのっけから、こうのたまった。'
	DB	"Kyoko-sensei had an announcement for us all."
	DB	NEXT
	E_CG B_SUDA,'AE_003'
;	DB	'【今日子】：喜べ皆の衆！我が校最大のイベント、体育文化祭の日程が決まったわよ！'
	DB	"Kyoko:  Rejoice, everyone! The biggest annual event of"
	DB	CR
	DB	"our school, the sports festival festival, is approaching!"
	DB	NEXT
;	DB	'【一同】：おお～～～～～～～～～～～～～～～～っ！！'
	DB	"Everyone:  Wow...!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................................"
	DB	NEXT
;	DB	'【%001】：何だ？その「体育文化祭」っつー怪しげなシロモノは？'
	DB	"%001:  Sports culture festival? I don't like the sound of"
	DB	CR
	DB	"that."
	DB	NEXT
;	DB	'【今日子】：・・・ふふん、それを今から説明するのよん。'
	DB	"Kyoko:  ...Please be patient, and I'll explain everything."
	DB	NEXT
;	DB	'まずは、これから配るプリントを見てね。'
	DB	"Kyoko:  First, please take a look at the handout I'm giving"
	DB	CR
	DB	"you all."
	DB	NEXT
	B_O B_SUDA
;	DB	'・・・・・・・・・'
	DB	".................................................."
	DB	NEXT
;	DB	'今日子先生が自分の授業時間まで潰して行なった説明は、まとめると次のような事だった。'
	DB	"What she explained to us was this."
	DB	NEXT
;	DB	'まず、クラス対抗で体育祭を行なう。中等部まで含めた縦割だから、'
	DB	"First, the sports festival would be held, with classes"
	DB	CR
	DB	"competing with each other as teams."
	DB	NEXT
;	DB	'鈴子さんや美緒ちゃんとも一緒のチームって訳だ。'
	DB	"Guess I'm competing against Reiko and Mio..."
	DB	NEXT
;	DB	'で、優勝すりゃあ後半の文化祭で色々おいしい、って事らしい。'
	DB	"The culture festival is after the sports festival. We"
	DB	CR
	DB	"can all relax and look at the cute women."
	DB	NEXT
;	DB	'期間は、合せて丸まる１週間。行事のやたら多い学校だとは思っていたが、'
;	DB	'ここまで徹底されると尊敬に値すると俺は思う。'
	DB	"The two festivals will take place over the course of a"
	DB	CR
	DB	"week."
	DB	NEXT
;	DB	'・・・・・・・・・だけど。'
	DB	"However..."
	DB	NEXT
;	DB	'文化祭の方はまぁいいとして・・・・・・問題は体育祭なんだよな。'
	DB	"I'm not really worried about the culture festival. It's"
	DB	CR
	DB	"the sports festival that has me concerned."
	DB	NEXT
;	DB	'・・・ああ・・・ゆ～うつだ・・・'
	DB	"........I mean..."
	DB	NEXT
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
	B_P1 B_SUDA
;	DB	'・・・てな事言ってる内に、昼休み。'
	DB	".........Huh? Oh, it's lunchtime."
	DB	NEXT,GATA,3
;	DB	'どどどどどどどどどどどどどど'
	DB	"What's that sound I hear?"
	DB	NEXT
;	DB	'【%001】：・・・ん？何だ？'
	DB	"Like footsteps, rushing towards me?"
	DB	NEXT,GATA,5
;	DB	'どどどどどどどどどどどどどど'
	DB	"..................................."
	DB	PAUSE
;	DB	'がたんっ！'
	DB	"*CRASH*"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	TU_CG 'CT03','W',0,30,3
	T_CG 'CT06','W','D',5,6
	DB ANI,A_ON,3
;	DB	'【美緒・亜希】：%001先輩っ！！'
	DB	"Mio/Aki:  %001!"
	DB	NEXT
;	DB	'【%001】：・・・や、やあ・・・'
	DB	"%001:  Yes? "
	DB	PAUSE
;	DB	'なに？'
	DB	"What's up, girls?"
	DB	NEXT
;	DB	'【美緒・亜希】：体育祭、あたしと組んで！'
	DB	"Mio/Aki:  Please be my partner during the sports festival!"
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【亜希】：ちょっと美緒！真似しないでよ！'
	DB	"Aki:  Get out of here, Mio! Stop following me around!"
	DB	NEXT
;	DB	'【美緒】：ま、真似だなんて・・・'
	DB	"Mio:  Who's following who?"
	DB	PAUSE
;	DB	'あたしはただ、%001先輩とダブルスが組みたくって・・・'
	DB	" I'm just here to ask %001 if"
	DB	CR
	DB	"he'll be my partner for doubles..."
	DB	NEXT
;	DB	'【亜希】：それが真似だって言ってんのよ！%001先輩と組むのはこのあたし！あんたは引っ込んでなさいよ！'
	DB	"Aki:  I was here first! He wants me, not you! You get"
	DB	CR
	DB	"out of here!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT02','W','D',10,2
;	DB	'【清美】：何をおっしゃっているのですか、２人とも。'
;	DB	'%001さんは、野球で怒濤の快進撃をする事になっていますのよ。'
	DB	"Kiyomi:  What are you two carrying on about now? %001's"
	DB	CR
	DB	"going to play baseball!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	TU_CG 'CT08','W','D',33,8
	T_CG 'CT07','W',0,10,7
	DB ANI,A_ON,8
;	DB	'【恵依美】：いつそんな事決まったのよ！？%001は体操でポイントを稼ぐんだから！'
	DB	"Meimi:  When was that decided? %001's going to do gymnastics," 
	DB	CR
	DB	"instead."
	DB	NEXT
;	DB	'【星愛】：・・・そうですわね。わたくしの予想では、体操は獲得ポイントが高そうですし・・・'
	DB	"Seia:  That's right. He should be good at gymnastics..."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT06','W','D',0,6
;	DB	'【亜希】：先輩達こそ、勝手な事言わないでよ！'
	DB	"Aki:  Would you all please stop deciding %001's life for"
	DB	CR
	DB	"him and just leave?"
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT08','W','D',33,8
;	T_CG 'CT07','W',0,10,7
	DB ANI,A_ON,6
;	DB	'【恵依美】：・・・亜希ちゃんの口から、そーゆーセリフが出てくるとは思わなかったわ。'
	DB	"Meimi:  I could say the same about you, Aki."
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT06','W','D',5,6
;	DB	'【亜希】：どーゆー意味よ！'
;	DB	"Aki:  What do you mean?"
;	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT04','W',0,20,4
;	DB	'【祥子】：そんな事よりぃ、サッカーであたしと「せ・い・しゅ・ん」'
;	DB	'しなぁい？'
	DB	"Shoko:  Don't worry about them. Why don't you play soccer"
	DB	CR
	DB	"with me instead? I'll let you get as many goals as you"
	DB	CR
	DB	"want."
	DB ANI,A_ON,6
	DB ANI,A_ON,8
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT06','W','D',5,6
;	DB	'【亜希】：わっ！？どっから出て来たのよこの人！！'
	DB	"Aki:  Wah!! Where did she come from?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............................."
	DB	NEXT
;	DB	'【%001】：やっぱりこ～なったか。'
	DB	"%001:  I knew this would happen."
	DB	C_BLD,C_N_ON,1,2		;「見る　鈴子」　消す
	DW	0000H

M2:		;見る　誠
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT14','W',0,0,5
;	DB	'俺のまわりで突然巻き起こった狂騒劇を、無責任に眺めている。'
	DB	"He's watching the drama unfolding around me without concern."
	DB	NEXT
;	DB	'見てないで助けてくれ～。'
	DB	"Save me, Makoto!"
	DB	FLG,F_COPYI,101,1
	DW	0000H

M3:		;見る　鈴子１
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT01','W','V',30,1
;	DB	'いつの間に来たのか、少し離れたところに立っている。'
	DB	"She's standing a little apart from me."
	DB	NEXT
;	DB	'・・・鈴子さんも勧誘かな？'
	DB	"I wonder if Reiko wants me to play some sport, too."
	DB	NEXT
;	DB	'でも、ちょっと様子が違う。'
	DB	"............I don't think so."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;見る　鈴子２
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT01','W','V',30,1
;	DB	'今回は勧誘は無いようだ。'
	DB	"She doesn't seem especially interested in me today."
	DB	NEXT
;	DB	'呆れたように、６人を見てる。'
	DB	"She's looking at the others, with a sick expression on"
	DB	CR
	DB	"her face."
	DB	NEXT
;	DB	'・・・見てないで助けてくれ～。'
	DB	"Save me, Reiko!"
	DB	FLG,F_COPYI,102,1
	DW	0000H

M5:		;見る　清美
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT02','W','D',10,2
;	DB	'・・・なんか、熱心に俺が野球をやる理由を語っている・・・'
	DB	"She's telling everyone else why I should play baseball"
	DB	CR
	DB	"with her."
	DB	NEXT
;	DB	'・・・俺は一言も言ってねえぞ？'
	DB	"Why doesn't she ask me what I want to do?"
	DB	FLG,F_COPYI,103,1
	DW	0000H

M6:		;見る　美緒
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT03','W',0,30,3
;	DB	'・・・この子の口振りだと、すでに俺はテニスをすることが決まっているらしい。'
	DB	"The way Mio tells it, I'm already signed up to play tennis"
	DB	CR
	DB	"with her."
	DB	NEXT
;	DB	'・・・俺の自由意志はどこ？'
	DB	".......What about my opinion?"
	DB	FLG,F_COPYI,104,1
	DW	0000H

M7:		;見る　星愛
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT07','W',0,10,7
;	DB	'・・・中野と２人して俺が体操競技に出ることの意義を語っている。'
	DB	"She's talking with Meimi about why I should do gymnastics"
	DB	CR
	DB	"during the sports festival."
	DB	NEXT
;	DB	'【星愛】：・・・ですから、%001君が体操に出場するのは、主の御意志なのです。'
	DB	"Seia:  ...And that's why the Lord wants %001 to do"
	DB	CR
	DB	"gymnastics..."
	DB	NEXT
;	DB	'・・・おいおいおいおいっ！'
	DB	".........Hey!"
	DB	FLG,F_COPYI,105,1
	DW	0000H

M8:		;見る　恵依美
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT08','W','D',33,8
;	DB	'・・・吉田と２"人して俺が体操競技に出ることの意義を語っている。'
	DB	"She's talking with Seia about why I should do gymnastics"
	DB	CR
	DB	"at the sports festival."
	DB	NEXT
;;	DB	'・・・だから、俺に選択の自由はねーのか！？'
	DB	"..........Don't I get a choice?"
	DB	FLG,F_COPYI,106,1
	DW	0000H

M9:		;見る　亜希
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT06','W','D',5,6
;	DB	'・・・なんか、この子の口振りだと、俺はテニスに出場して優勝することになっているらしい。'
	DB	".....The way Aki tells it, I'm already signed up to play"
	DB	CR
	DB	"tennis with her."
	DB	NEXT
;	DB	'【亜希】：高校テニス界の超新星と運動神経抜群の%001先輩が組むんだから、当然よね！'
	DB	"Aki:  With %001 as my doubles partner, we'll be the"
	DB	CR
	DB	"brightest stars in the tennis world!"
	DB	NEXT
;	DB	'・・・だ～か～ら～、俺はなんも言ってねーっての！'
	DB	"..........Let me choose what I want to do!"
	DB	FLG,F_COPYI,107,1
	DW	0000H

M10:		;見る　祥子
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT04','W',0,20,4
;	DB	'・・・なんか、サッカーに出ろ、って事らしいけど・・・'
	DB	"She wants me to play soccer."
	DB	NEXT
;	DB	'祥子さんの場合、なにか邪なものを感じる・・・'
	DB	"I wonder what she's planning?"
	DB	FLG,F_COPYI,108,1
	DW	0000H

M11:		;見る　まわり
;	DB	'な・・・なんだかえらいことになってる。'
	DB	"What's going on around here?"
	DB	NEXT
;	DB	'これは、４月の部活勧誘合戦を彷彿とさせるものがあるぞ！？'
	DB	"This is worse than the club recruitment back in April!"
	DB	FLG,F_COPYI,109,1
	DW	0000H

M12:		;見る　女の戦い
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT03','W',0,30,3
;	DB	'【美緒】：先輩は、ずっと前にも、テニスが楽しいって、言ってくれたよ！'
	DB	"Mio:  %001 told me that he's loved tennis for a long time."
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT02','W','D',10,2
	DB	ANI,A_ON,3
;	DB	'【清美】：ですが、%001さんの能力は野球でこそ発揮されるべきなのですわ！'
	DB	"Kiyomi:  Yes, but baseball is where he really belongs!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT08','W','D',33,8
;	DB	'【恵依美】：ちょっとちょっと、勝手に决めないでよね！'
	DB	"Meimi:  Hold on, don't just decide like that!"
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT07','W',0,10,7
	DB	ANI,A_ON,8
;	DB	'【星愛】：やはりここは、主のお導きに従って、体操に出場するべきかと・・・'
	DB	"Seia:  He should follow the Lord's will, and do gymnastics."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT06','W','D',5,6
;	DB	'【亜希】：なんでそうなるのよ！？先輩は、あたしと組んでテニスに出るのよ！'
	DB	"Aki:  Why is it the Lord's will? Besides, he wants to"
	DB	CR
	DB	"play tennis with me!"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..................."
	DB	FLG,F_COPYI,10,1
	DW	0000H

M13:		;見る　女の戦い
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT04','W',0,0,4
;	DB	'【祥子】：ねえねえ、しゅ～君、あたしのためにぃ、サッカーしようよぉ！'
	DB	"Shoko:  Hey, Shu-chan, play soccer, okay? It'd make me so"
	DB	CR
	DB	"happy."
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT08','W','D',33,8
;	DB	'【恵依美】：ちょっ、ひっこんでてよ！%001は体操でポイント稼ぐんだから！'
	DB	"Meimi:  Get back, you! %001's going to do gymnastics!"
	DB	ANI,A_ON,4
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT04','W',0,0,4
;	DB	ANI,A_ON,8
;	DB	'【祥子】：ふるふる、違うも～ん、しゅ～君は、しゅ～君はあたしのために、あたしの胸が「ドキドキッ☆」とかなっちゃうシュートを決めてくれるんだモン！それでねぇ、大会が終わったあとぉ、私とぉ、しゅ～君はぁ・・・'
	DB	"Shoko:  No, Shu-chan's going to play soccer for me. When"
	DB	CR
	DB	"I think of him out there on the field I get all hot! And"
	DB	CR
	DB	"when the game's over..."
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT06','W','D',15,6
;	DB	'【亜希】：なんの話よ、なんの！しゃしゃり出て来ないでよね！'
	DB	"Aki:  What are you talking about? Get out of here, you!"
	DB	ANI,A_ON,4
	DB	ANI,A_ON,8
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT04','W',0,20,4
;	DB	'【祥子】：なによぉ、ちゅ～がくせ～のくせに、なまいきぃ、ってカンジ～。'
	DB	"Shoko:  I don't need to take that from you!"
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT06','W','D',5,6
;	DB	'【亜希】：（厶カッ）・・・なによ、おばさん。'
	DB	"Aki:  Why, you... At least I'm not an old lady like you."
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT04','W',0,20,4
;	DB	'【祥子】：（ぴきっ）・・・なにか言ったぁ？発達遅そうなお嬢さん？'
	DB	"Shoko:  What did you say, little tramp?"
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT06','W','D',5,6
;	DB	'【亜希】：・・・なんですってえ！？'
	DB	"Aki:  Tramp? Who is?"
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT04','W',0,20,4
;	DB	'【祥子】：・・・なによぉ！？'
	DB	"Shoko:  You are!"
	DB	NEXT
;	DB	'【%001】：なあ、喧嘩はやめようぜ。みんな仲良く・・・'
	DB	"%001:  Stop fighting! Let's all get along, alright?"
	DB	NEXT
;	DB	BUF,B_COPY01										;背景コピー
;	T_CG 'CT04','W',0,20,4
;	T_CG 'CT06','W','D',5,6
;	DB	'【亜希・祥子】：ちょっと黙ってて！'
	DB	"Aki/Shoko:  Shut up, you!"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................................."
	DB	FLG,F_COPYI,110,1
	DB	FLG,F_COPYI,10,0
	DW	0000H

M14:		;話す　誠１
	DB	ANI,A_INIT
;	DB	'【%001】：・・・おーい誠ぉ・・・'
	DB	"%001:  Hey, Makoto! Help me!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT14','W',0,0,5
;	DB	'【誠】：自分で何とかしろ。'
	DB	"Makoto:  You're a man, you can take care of yourself."
	DB	NEXT
;	DB	'【%001】：・・・・・・相変わらずつめて～奴。'
	DB	"%001:  You're no help."
	DB	FLG,F_COPYI,11,1
	DW	0000H

M15:		;話す　誠２
	DB	ANI,A_INIT
;	DB	'【%001】：・・・誠～。'
	DB	"%001:  .........Makoto!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT14','W',0,0,5
;	DB	'【誠】：知らん知らん。'
	DB	"Makoto:  I'm not going to get involved, thanks."
	DB	NEXT
;	DB	'【%001】：・・・はくじょ～もの～！'
	DB	"%001:  ......Coward!"
	DB	FLG,F_COPYI,111,1
	DW	0000H

M16:		;話す　鈴子１
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT01','W','V',30,1
;	DB	'【鈴子】：・・・あーあ、また派手にやってるわね～。'
	DB	"Shoko:  ...They're at it again."
	DB	NEXT
;	DB	'【%001】：・・・まったく・・・'
	DB	"%001:  Yeah, disgusting, isn't it?"
	DB	PAUSE
;	DB	'って鈴子さん、いつ来たの？'
	DB	" When did you show up,"
	DB	CR
	DB	"anyway?"
	DB	NEXT
;	DB	'【鈴子】：ついさっきよ。'
	DB	"Reiko:  Just a minute ago."
	DB	FLG,F_COPYI,12,1
	DB	C_BLD,C_N_OFF,1,2		;「見る　鈴子」　出す
	DW	0000H

M17:		;話す　鈴子２
	DB	ANI,A_INIT
;	DB	'【%001】：・・・あのさ・・・鈴子さんもやっぱり・・・その・・・'
	DB	"%001:  Are you here to get me to pair up with you, too?"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT01','W',0,30,1
;	DB	'【鈴子】：私？別に君を勧誘しに来た訳じゃないわよ。'
	DB	"Reiko:  Me? Oh, not at all."
	DB	NEXT
;	DB	'【鈴子】：そもそも、体育祭の種目に水泳無いもの。'
	DB	"Reiko:  I mean, there're no swimming events at the sports"
	DB	CR
	DB	"festival anyway."
	DB	NEXT
;	DB	'【%001】：・・・そうなの？'
	DB	"%001:  There aren't?"
	DB	NEXT
;	DB	'【鈴子】：ええ。'
	DB	"Reiko:  No."
	DB	NEXT
;	DB	'【%001】：・・・ほっ。'
	DB	"%001:  I see..."
	DB	FLG,F_COPYI,12,2
	DW	0000H

M18:		;話す　鈴子３
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT01','W',0,30,1
;	DB	'【鈴子】：・・・しっかし、端で見てると物凄いわね～。'
	DB	"Reiko:  They're really going at it."
	DB	NEXT
;	DB	'【%001】：・・・そう思うんだったら、何とかしてよぉ鈴子さ～ん。'
	DB	"%001:  Isn't there anything you can do to help?"
	DB	NEXT
;	DB	'【鈴子】：それは無理よ。'
	DB	"Reiko:  Nothing, sorry."
	DB	NEXT
;	DB	'【%001】：・・・そんなあっさりと・・・'
	DB	"%001:  ........You're not very helpful."
	DB	NEXT
;	DB	'【鈴子】：だって、私じゃ止められないもの。'
	DB	"Reiko:  But there's nothing I can do to stop them, anyway."
	DB	FLG,F_COPYI,12,3
	DW	0000H

M19:		;話す　鈴子４
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT01','W',0,30,1
;	DB	'【%001】：そこを何とか・・・・・・'
	DB	"%001:  Please..."
	DB	NEXT
;	DB	'【鈴子】：だぁめ。私が出て行ったら、余計酷くなるもの。'
	DB	"Reiko:  No, sir! If I got involved in the fight, it'd"
	DB	CR
	DB	"only get worse."
	DB	NEXT
;	DB	'【%001】：・・・どーして？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  .........................."
	DB	NEXT
;	DB	'【鈴子】：どーしても。'
	DB	"Reiko:  It just would."
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  Huh?"
	DB	FLG,F_COPYI,12,4
	DW	0000H

M20:		;話す　鈴子５
	DB	ANI,A_INIT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT01','W',0,30,1
;	DB	'【鈴子】：じゃあ、私はそろそろ戻るわ・・・頑張ってね%001君。'
	DB	"Reiko:  I guess I'll be getting back now. Good luck,"
	DB	CR
	DB	"%001."
	DB	NEXT
;	DB	'【%001】：あ゛あ゛っ！ちょっと待って！'
	DB	"%001:  Wait, come back!"
	DB	NEXT
;	DB	'【%001】：・・・・・・行っちゃった。'
	DB	"%001:  ......She's gone."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT02','W','D',10,2
;	DB	'【清美】：・・・・・・・・・・・・・・・・'
	DB	"Kiyomi:  ..............................."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT03','W',0,30,3
;	DB	'【美緒】：・・・・・・・・・・・・・・・・'
	DB	"Mio:  ..............................."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT04','W',0,20,4
;	DB	'【祥子】：・・・・・・・・・・・・・・・・'
	DB	"Shoko:  ..............................."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT08','W','D',33,8
;	DB	'【恵依美】：・・・・・・・・・・・・・・・・'
	DB	"Meimi:  ..............................."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT07','W',0,10,7
;	DB	'【星愛】：・・・・・・・・・・・・・・・・'
	DB	"Seia:  ..............................."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT06','W','D',5,6
;	DB	'【亜希】：・・・・・・・・・・・・・・・・'
	DB	"Aki:  ..............................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・'
	DB	"%001:  ..............................."
	DB	PAUSE
;	DB	'な、なに？'
	DB	"What's wrong?"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT08','W','D',33,8
;	DB	'【恵依美】：%001！決めてちょうだい！'
	DB	"Meimi:  %001! Please make up your mind!"
	DB	NEXT
;	DB	'【%001】：な・・・何を？'
	DB	"%001:  About what?"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT06','W','D',5,6
;	DB	'【亜希】：先輩の出る種目に決まってるでしょ！！'
	DB	"Aki:  Which sport you're going to participate in!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT03','W',0,30,3
;	DB	'【美緒】：%001先輩！あたしとダブルスしようよ！'
	DB	"Mio:  %001, please play doubles with me!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT02','W','D',10,2
;	DB	'【清美】：野球に、出て下さいますわよね？'
	DB	"Kiyomi:  No, baseball!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT04','W',0,20,4
;	DB	'【祥子】：ふるふる、しゅ～君はサッカーするのぉ！'
	DB	"Shoko:  Shu-chan's going to play soccer!"
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT07','W',0,10,7
;	DB	'【星愛】：あと、陸上８種目と球技６種目に出て頂きたいのですが。'
	DB	"Seia:  I'd also like you to join the track and field"
	DB	CR
	DB	"team, and..."
	DB	NEXT
;	DB	'【%001】：・・・え゛、あ゛、い゛、う゛・・・'
	DB	"%001:  ...........Huh?"
	DB	NEXT
	B_O B_SUDA
;	DB	'・・・・・・結局。'
	DB	"In the end..."
	DB	NEXT
;	DB	'彼女達の迫力に負けた俺は、ほとんど反射的に頷きまくっていた。'
	DB	"Unable to resist the combined force of all the women, I"
	DB	CR
	DB	"just nodded my head to all of them."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"....................................."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT14','W',0,0,5
;	DB	'【誠】：・・・おい、いいのか%001？'
	DB	"Makoto:  Is that really alright, %001?"
	DB	NEXT
;	DB	'【%001】：・・・・・・何が？'
	DB	"%001:  ...........Is what alright?"
	DB	NEXT
;	DB	'【誠】：体育祭の種目、あんなに掛け持ちしちゃってよ。'
	DB	"Makoto:  For you to try to participate in that many different"
	DB	CR
	DB	"events?"
	DB	NEXT
;	DB	'【%001】：・・・まあ、何とかなるんじゃね～の？'
	DB	"%001:  I'm sure it'll be okay, somehow."
	DB	NEXT
;	DB	'【誠】：・・・そうか。お前がそう言うんなら、いいんだけどよ・・・'
	DB	"Makoto:  If you say so."
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  ............................................"
	DB	NEXT
	B_O B_SUDA
	E_CG B_SUDA,'T_08'
	DB	NEXT
	DB	SINARIO,'CS801_1.OVL',0
	DW	0000H

M21:		;話す　清美
	DB	ANI,A_INIT
;	DB	'【%001】：・・・あの～。'
	DB	"%001:  Um..."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT02','W','D',10,2
;	DB	'【清美】：少しお黙りになって下さい！'
	DB	"Kiyomi:  Please don't talk to me right now."
	DB	NEXT
;	DB	'【%001】：・・・怒られた・・・'
	DB	"She's mad."
	DW	0000H

M22:		;話す　美緒
	DB	ANI,A_INIT
;	DB	'【%001】：・・・あの～。'
	DB	"%001:  Um..."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT03','W','D',30,3
;	DB	'【美緒】：ちょっと黙ってて！'
	DB	"Mio:  I don't want to talk to you right now!"
	DB	NEXT
;	DB	'【%001】：・・・怒られた・・・'
	DB	"She's mad."
	DW	0000H

M23:		;話す　星愛
	DB	ANI,A_INIT
;	DB	'【%001】：・・・あの～。'
	DB	"%001:  Um..."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT07','W',0,10,7
;	DB	'【星愛】：ですから、%001君が体操に出場するのは、主の・・・'
	DB	"Seia:  So you see, it's really the Lord's will that %001..."
	DB	NEXT
;	DB	'【%001】：・・・聞いてくれない・・・'
	DB	"She's not listening."
	DW	0000H

M24:		;話す　恵依美
	DB	ANI,A_INIT
;	DB	'【%001】：・・・あの～。'
	DB	"%001:  Um..."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT08','W','D',33,8
;	DB	'【恵依美】：ちょっと黙っててよ！'
	DB	"Meimi:  Shhhh!"
	DB	NEXT
;	DB	'【%001】：・・・怒られた・・・'
	DB	"She's mad."
	DW	0000H

M25:		;話す　亜希
	DB	ANI,A_INIT
;	DB	'【%001】：・・・あの～。'
	DB	"%001:  Um..."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT06','W','D',5,6
;	DB	'【亜希】：少し黙ってなさいよ！'
	DB	"Aki:  Leave me alone!"
	DB	NEXT
;	DB	'【%001】：・・・怒られた・・・'
	DB	"She's mad."
	DW	0000H

M26:		;話す　祥子
	DB	ANI,A_INIT
;	DB	'【%001】：・・・あの～。'
	DB	"%001:  Um..."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT04','W',0,20,4
;	DB	'【祥子】：ふるふる、しゅ～君は、しゅ～君はねぇ・・・'
	DB	"Shoko:  Oh, Shu-chan..."
	DB	NEXT
;	DB	'【%001】：・・・聞いちゃいねえ・・・'
	DB	"She's not listening."
	DW	0000H

M27:		;考える
;	DB	'え～～と・・・'
	DB	"Hmmmmmm..."
	DB	NEXT
;	DB	'俺に選択の自由はないのかな？'
	DB	"Don't I have a choice in all this?"
	DB	NEXT
;	DB	'・・・なんか、だんだん人事に思えてきた・・・'
	DB	"I guess not."
	DW	0000H


end