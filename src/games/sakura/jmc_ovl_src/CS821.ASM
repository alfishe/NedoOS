;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２１
;		いっぱいのラーメン

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'清美',0
NN2:	DB	2,	'KIYOMI',0
;NN3:	DB	3,	'美緒',0
NN3:	DB	3,	'MIO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子２
S2:		DW	VV1, NN2,  2, M4, M5		;見る　清美２
S3:		DW	VV1, NN3,  3, M6, M7		;見る　美緒２
S4:		DW	VV2, -1,  4, M8, M9, M10		;話す３


;イニシャルメッセージ
M1:
        DB	BGM,17
        ;	DB	'・・・その晩。'
        DB	"That night..."
        DB	NEXT
        ;	DB	'俺は３人に、ラーメンを驕っていた。'
        DB	"I took the three of them out for ramen."
        DB	NEXT
        E_CG B_FADE,"AE_033"
        ;	DB	'【%001】：・・・どう？'
        DB	"%001:  How is it?"
        DB	NEXT
        ;	DB	'【鈴子】：すごくおいしい！'
        DB	"It's delicious!"
        DB	NEXT
        ;	DB	'【清美】：わたくし、こういうところは初めてなのですが・・・'
        ;	DB	'こんなにおいしいのですね。'
        DB	"Kiyomi:  I've never been to a place like this. It's"
        DB	CR
        DB	"wonderful."
        DB	NEXT
        ;	DB	'【美緒】：・・・（はふはふ）うん、すほふおいひいよ（はふはふ）'
        DB	"Mio:  This is the best ramen I've had in a long time!"
        DB	NEXT
        ;	DB	'【%001】：・・・良かった。'
        DB	"%001:  Well, good."
        DW	0000H
        
M2:		;見る　鈴子１
        ;	DB	'鈴子さんは、チャーシューメンを食べている。'
        DB	"Reiko's eating chashew ramen, with slices of pork in it."
        DW	0000H
        
M3:		;見る　鈴子２
        ;	DB	'食べる手を休めて、こっちを見ている。'
        DB	"She's looking this way now."
        DW	0000H
        
M4:		;見る　清美１
        ;	DB	'新藤さんは、ワンタンメンを食べているぞ。'
        DB	"Kiyomi's having ramen with wan-ton in it."
        DW	0000H
        
M5:		;見る　清美２
        ;	DB	'食べる手を休めて、こっちを見ている。'
        DB	"She's looking this way now."
        DW	0000H
        
M6:		;見る　美緒１
        ;	DB	'美緒ちゃんは、鱶ヒレチャーシューの大盛りだ。'
        DB	"Mio's eating a large bowl of miso ramen with corn on top."
        DB	CR
        DB	"It looks good."
        DW	0000H
        
M7:		;見る　美緒２
        ;	DB	'・・・食べながらではあるが、こっちを見ているぞ。'
        DB	"She's looking this way."
        DW	0000H
        
M8:		;話す１
        ;	DB	'【%001】：・・・今日は、ホントにお疲れ様。助かったよ。'
        DB	"%001:  Thanks for helping me today, girls."
        DB	NEXT
        ;	DB	'【鈴子】：いいのよ・・・これくらい。'
        DB	"Reiko:  It was nothing."
        DB	NEXT
        ;	DB	'【清美】：そうですわ。お気になさらないで下さい。'
        DB	"Kiyomi:  That's right. Don't worry about it."
        DB	NEXT
        ;	DB	'【美緒】：・・・そほらよ（もぐもぐ）あはひ（もぐもぐ）ふっほふ'
        ;	DB	'（もぐもぐ）はのひはっはろ（もぐもぐ）'
        DB	"Mio:  Sure... *slurp slurp*"
        DB	NEXT
        ;	DB	'【%001】：・・・ありがとう、みんな。'
        DB	"%001:  Thanks, everyone."
        DB	FLG,F_COPYI,4,1
        DB	FLG,F_COPYI,1,1
        DB	FLG,F_COPYI,2,1
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M9:		;話す２
        ;	DB	'【美緒】：そほほへ、へんはひ！（むぐむぐ）'
        ;	DB	'ほほ、よふふるんへふは？（むぐむぐ）'
        DB	"Mio:  *slurp slurp*  So, shupi *slurp slurp* hoyow hom"
        DB	CR
        DB	"arot?"
        DB	NEXT
        ;	DB	'【%001】：・・・美緒ちゃん・・・食べるかしゃべるか、どっちかにしたら？'
        DB	"%001:  Mio, it's bad manners to talk with your mouth"
        DB	CR
        DB	"full like that."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・（むぐむぐむぐむぐ、ごっくん）'
        ;	DB	'【美緒】：ご、ごめんなさい・・・・・・'
        DB	"Mio:  *slurp slurp*"
        DB	PAUSE
        DB	" I'm sorry."
        DB	NEXT
        ;	DB	'【%001】：・・・いいよいいよ、そんなに気にしなくて・・・'
        DB	"%001:  It's okay, we just can't understand you."
        DB	PAUSE
        ;	DB	'で？さっきは何て言ってたの？'
        DB	" What did you"
        DB	CR
        DB	"just say?"
        DB	NEXT
        ;	DB	'【清美】：・・・「ところで先輩、ここ良く来るんですか？」っておっしゃってたんですよね？'
        DB	"Kiyomi:  I think she said, 'So do you come here a lot,"
        DB	CR
        DB	"%001?'"
        DB	NEXT
        ;	DB	'【美緒】：・・・う、うん。'
        DB	"Mio:  That's right."
        DB	NEXT
        ;	DB	'【%001】：・・・（良く分かるな）・・・'
        DB	"............How did Kiyomi translate that?"
        DB	NEXT
        ;	DB	'え～っと、そんなにちょくちょく来るって訳でもないけど、'
        ;	DB	'前に親父に連れられてさ。'
        DB	"%001:  Well, I come here sometimes on my way home. Or"
        DB	CR
        DB	"sometimes my father brings us all here for dinner."
        DB	NEXT
        ;	DB	'【鈴子】：・・・へ～、そうなんだ。'
        DB	"Reiko:  That's great."
        DB	FLG,F_COPYI,4,2
        DW	0000H
        
M10:		;話す３
        ;	DB	'【%001】：・・・・・・ところでさ。'
        DB	"%001:  I sort of wanted to ask you a question."
        DB	NEXT
        ;	DB	'どうしてみんな、俺なんかに色々してくれるんだ？'
        DB	"%001:  Why do you three always do so much for me?"
        DB	NEXT
        ;	DB	'【鈴子】：さあ・・・どうしてかしらね？'
        DB	"Reiko:  Hmm, I wonder."
        DB	NEXT
        ;	DB	'【清美】：してあげたい、と思ったからですわ。'
        DB	"Kiyomi:  Because we want to do things for you."
        DB	NEXT
        ;	DB	'【美緒】：・・・（ぽっ）'
        DB	"Mio:  .....*slurp*"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・みんな・・・・・・'
        DB	"%001:  ..................................."
        DB	NEXT
        ;	DB	'【%001】：・・・'
        DB	"%001:  ......"
        DB	PAUSE
        ;	DB	'こ、ここのラーメン、ホントに美味いよなぁ！冷めない内に食っちまおうぜ！'
        DB	"Y- You know, this ramen is really good. "
        DB	CR
        DB	"I'd better eat it before it gets cold."
        DB	NEXT
        ;	DB	'何だか俺は気恥ずかしくなって、ラーメンに専念するふりをした。'
        DB	"I bury my face in the ramen bowl."
        DB	NEXT
        ;	DB	'こんな事じゃいけない・・・・・・それは分ってる。'
        DB	"I know I can't let it go on like this. I've got to make"
        DB	CR
        DB	"up my mind what to do."
        DB	NEXT
        ;	DB	'・・・・・・そう。俺は結論を出さなくちゃいけないんだ。'
        ;	DB	'少なくとも、鈴子さんが卒業してしまう前に。'
        DB	"I've got to choose... And my deadline is next March, when"
        DB	CR
        DB	"Reiko graduates."
        DB	NEXT
        ;	DB	'それが、本当の優しさなんだ。'
        DB	"That's what kindness really is."
        DB	NEXT
        ;	DB	'ラーメンを食いながら、俺はそんな事ばかり考えていた・・・・・・'
        DB	"I continued to eat my ramen."
        DB	NEXT
        DB	SINARIO,'CS824.OVL',0
        DW	0000H


end
