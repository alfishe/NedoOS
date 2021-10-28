;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１６
;		今日子の特別授業３

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1
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
CM1:	DW	VV1,	NN1,-1

;VV1:	DB	1,	'受ける',0
VV1:	DB	1,	'ACCEPT',0

;NN1:	DB	1,	'特別授業',0
NN1:	DB	1,	'SPECIAL LESSON',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5, M6, M7		;受ける　特別授業６


;イニシャルメッセージ
M1:
        DB	BGM,32
        E_CG B_FADE,"AE_122"
        ;	DB	'するするっ。'
        DB	"She started to unbutton her shirt."
        DB	NEXT
        ;	DB	'【%001】：・・・せ、先生！？'
        DB	"%001:  Sensei!"
        DB	NEXT
        ;	DB	'【今日子】：・・・さ、%001君・・・'
        DB	"Kyoko:  Come here, %001."
        DB	NEXT
        ;	DB	'（・・・や、柔らかい・・・）'
        DB	"Her hands are soft."
        DW	0000H
        
M2:		;受ける　特別授業１
        ;	DB	'【今日子】：さあ・・・手を動かして・・・'
        DB	"Kyoko:  Give me your hand."
        DB	NEXT
        ;	DB	'【%001】：・・・え？'
        DB	"%001:  What?"
        DB	NEXT
        ;	DB	'【今日子】：あなたの手で、私を悦ばせて・・・'
        DB	"Kyoko:  I want you to take my clothes off for me."
        DB	NEXT
        ;	DB	'【%001】：・・・は、はい・・・'
        DB	"%001:  .............Okay."
        DB	NEXT
        ;	DB	'ぎゅっ。'
        DB	"*PINCH*"
        DB	NEXT
        ;	DB	'【今日子】：・・・痛っ！'
        DB	"Kyoko:  Ouch!"
        DB	NEXT
        ;	DB	'【%001】：あわわっ！す、すいません！'
        DB	"%001:  I'm sorry! What did I do?"
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;受ける　特別授業２
        ;	DB	'【今日子】：ダメよ・・・もっと、優しく。'
        DB	"Kyoko:  That's wrong. You have to be more gentle."
        DB	NEXT
        ;	DB	'【%001】：は・・・はい・・・'
        DB	"%001:  ........Yes ma'am."
        DB	NEXT
        ;	DB	'ふにふに'
        DB	"This time I went more slowly."
        DB	NEXT
        ;	DB	'【今日子】：ん・・・力加減は、そのくらいでいいわ。'
        DB	"Kyoko:  Mmm...that's good."
        DB	FLG,F_COPYI,1,2
        DW	0000H
        
M4:		;受ける　特別授業３
        ;	DB	'【今日子】：次は、揉み方よ。もっと、全体をまんべんなく揉むの・・・'
        ;	DB	'こんな風に。'
        DB	"Kyoko:  Now you need to touch me all over my body. Softly,"
        DB	CR
        DB	"like this."
        DB	NEXT
        ;	DB	'先生の手が、俺の手を一層胸に押しつける。'
        DB	"Sensei took my hand and put it on her breast."
        DB	NEXT
        ;	DB	'それは複雑な動きで俺の手を操り、豊かな弾力を伝えて来た。'
        DB	"My fingers closed slowly, feeling the soft springiness"
        DB	CR
        DB	"I felt there."
        DB	NEXT
        ;	DB	'【今日子】：・・・んっ・・・はぁっ・・・'
        DB	"Kyoko:  .............Mmm.......Yes...."
        DB	FLG,F_COPYI,1,3
        DW	0000H
        
M5:		;受ける　特別授業４
        ;	DB	'【今日子】：・・・%001君・・・ここも触って・・・'
        DB	"Kyoko:  %001...touch me here..."
        DB	NEXT
        ;	DB	'先生の手が俺の左手に伸び、すらりと伸びた脚の付け根へと導く。'
        DB	"She took my left hand and took it to her slit."
        DB	NEXT
        ;	DB	'くちゃっ。'
        DB	"*splooch*"
        DB	NEXT
        ;	DB	'【%001】：な、何だぁ！？'
        DB	"%001:  What the hell?"
        DB	NEXT
        ;	DB	'そこ・・・男だったら蹴られたくない場所は、ぬるぬるした液体で覆われていた。'
        DB	"In her crotch...the place that guys don't want to be"
        DB	CR
        DB	"kicked..."
        DB	PAUSE
        DB	"...there was a warm, slippery wetness."
        DB	NEXT
        ;	DB	'【今日子】：女はね・・・気持ちいいと、こうなるの。'
        DB	"Kyoko:  When women feel good...they get this way."
        DB	NEXT
        ;	DB	'【%001】：・・・気持ちいい・・・？'
        DB	"%001:  Do you feel good right now?"
        DB	NEXT
        ;	DB	'【今日子】：そう。大切な人を迎え入れるための準備・・・'
        DB	"Kyoko:  Yes, I do. It means I'm ready to make love to"
        DB	CR
        DB	"someone I care about."
        DB	FLG,F_COPYI,1,4
        DW	0000H
        
M6:		;受ける　特別授業５
        ;	DB	'【今日子】：逆に、もしこうなってなかったら・・・'
        ;	DB	'それは君の愛し方が足りないの。'
        DB	"Kyoko:  If a woman doesn't get wet like this...it means"
        DB	CR
        DB	"you're not loving her the right way."
        DB	NEXT
        ;	DB	'【%001】：・・・愛・・・し方・・・'
        DB	"%001:  ...The right way?"
        DB	NEXT
        ;	DB	'【今日子】：そう。例えどんなに心に愛があっても、相手に伝わらなくてはダメ。'
        DB	"Kyoko:  Of course. Even if you love someone with all your"
        DB	CR
        DB	"heart, you have to show them."
        DB	NEXT
        ;	DB	'【今日子】：あるがままの気持ちをぶつける事も大切よ。だけど、受け取る側の事も考えなくちゃ・・・それはただのワガママになってしまうわ。'
        DB	"Kyoko:  Your feelings are important, of course. But you"
        DB	CR
        DB	"have to think of the other person, too."
        DB	NEXT
        ;	DB	'【%001】：・・・うん・・・'
        DB	"%001:  ............Okay."
        DB	NEXT
        ;	DB	'【今日子】：だから、どんなに時間が掛かっても・・・相手に伝わるまで、'
        ;	DB	'辛抱強く愛してあげて。'
        DB	"Kyoko:  Even if it takes a long time for her to get this"
        DB	CR
        DB	"way, you have to take the time, to show her you love her."
        DB	NEXT
        ;	DB	'【今日子】：ただでさえあなたは、待たせているんだから・・・'
        DB	"Kyoko:  It always takes a little time."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・うん。'
        DB	"%001:  ................Okay."
        DB	FLG,F_COPYI,1,5
        DW	0000H
        
M7:		;受ける　特別授業６
        ;	DB	'【今日子】：・・・さ、いよいよ大詰めよ。'
        DB	"Kyoko:  %001, are you ready?"
        DB	NEXT
        DB	SINARIO,'CS817.OVL',0
        DW	0000H


end
