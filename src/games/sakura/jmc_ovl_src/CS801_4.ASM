	;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０１＿４
;		体育祭前　練習の日々３


        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	NN4,-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'LISTEN',0 
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'清美',0
NN2:	DB	2,	'KIYOMI',0
;NN3:	DB	3,	'美緒',0
NN3:	DB	3,	'MIO',0
;NN4:	DB	4,	'みんなの話',0
NN4:	DB	4,	'EVERYONE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子
S2:		DW	VV1, NN2,  2, M3		;見る　清美
S3:		DW	VV1, NN3,  3, M4		;見る　美緒
S4:		DW	VV2, -1,  4, M5, M6		;話す２
S5:		DW	VV3, NN4,  5, M7, M8, M9, M10		;聞く　みんなの話４
S6:		DW	VV4, -1,  6, M11		;考える


;イニシャルメッセージ
M1:
        DB	BGM,6
        B_O B_SUDA
        E_CG B_YOKO,"AB_27_2"
        ;	DB	'・・・２週間後。'
        DB	"Two weeks later."
        DB	NEXT
        ;	DB	'【バレー】：行くぜ山神！クイックＡだ！'
        DB	"Volleyball player:  Let's go, Yamagami!"
        DB	NEXT
        ;	DB	'ばしっ！'
        DB	"*HIT*"
        DB	NEXT
        ;	DB	'【%001】：・・・おう！'
        DB	"%001:  Got it!"
        DB	NEXT
        ;	DB	'どがぁっ！'
        DB	"*BASH*"
        DB	NEXT
        ;	DB	'【バレー】：よっし！完璧だな山神！'
        DB	"Volleyball player:  Okay! Perfect!"
        DB	NEXT
        ;	DB	'【野球】：おーい山神ぃ！お前の番だぞ～！'
        DB	"Baseball player:  Hey, Yamagami. It's your turn!"
        DB	NEXT
        ;	DB	'【%001】：・・・お～、今行く～！'
        DB	"%001:  Okay!"
        DB	NEXT
        ;	DB	'だだだだだ・・・'
        DB	"............................................"
        DB	NEXT
        E_CG B_YOKO,"AB_11_2"
        ;	DB	'【野球】：・・・お、来たな。'
        DB	"Baseball player:  Here you are again."
        DB	PAUSE
        ;	DB	'それ、グローブだ！'
        DB	" You've got a glove"
        DB	CR
        DB	"this time, I see."
        DB	NEXT
        ;	DB	'【%001】：・・・おう！'
        DB	"%001:  ...Come on!"
        DB	NEXT
        ;	DB	'【野球】：すかさず弾丸ライナー！'
        DB	"Baseball player:  Try this!"
        DB	NEXT
        ;	DB	'かっきーん！'
        DB	"*THROW*"
        DB	NEXT
        ;	DB	'【%001】：・・・よっ！'
        DB	"%001:  Oh!"
        DB	NEXT
        ;	DB	'ばしぃっ！'
        DB	"*CATCH*"
        DB	NEXT
        ;	DB	'【野球】：・・・ＯＫ！ゲッツー取れるぜ！'
        DB	"Baseball player:  Okay! That wasn't bad!"
        DB	NEXT
        ;	DB	'【サッカー】：山神く～ん、君の番よ～。'
        DB	"Soccer player:  Yamagami, let's go!"
        DB	NEXT
        ;	DB	'【%001】：・・・おお。'
        DB	"%001:  Okay!"
        DB	NEXT
        ;	DB	'だだだだだ・・・'
        DB	"............................................"
        DB	NEXT
        E_CG B_YOKO,"AB_14_2"
        ;	DB	'【サッカー】：・・・よし、１・２リターンだ！'
        DB	"Soccer player:  Okay, try this!"
        DB	PAUSE
        ;	DB	'ほれっ！'
        DB	" Hah!"
        DB	NEXT
        ;	DB	'ばしっ！'
        DB	"*KICK*"
        DB	NEXT
        ;	DB	'【%001】：・・・とっ！'
        DB	"%001:  ...Mine!"
        DB	NEXT
        ;	DB	'びしっ！'
        DB	"*KICK*"
        DB	NEXT
        ;	DB	'【サッカー】：・・・ナイスだ山神！コンビネーションはほぼ完璧だな！'
        DB	"Soccer player:  Nice, Yamagami. You've really gotten better."
        DB	NEXT
        ;	DB	'【%001】：ああ、そ～だな。'
        DB	"%001:  Thanks."
        DB	NEXT
        ;	DB	'【サッカー】：他のみんなともタイミング取れて来たし、今回の優勝は頂きだな！'
        DB	"Soccer player:  Your timing is good, and you work well with"
        DB	CR
        DB	"the others."
        DB	NEXT
        ;	DB	'【%001】：・・・ま、そのつもりでやろうぜ。'
        DB	"%001:  Let's do our best at the sports festival!"
        DB	NEXT
        ;	DB	'【生徒】：おーい、山神く～ん。出番だよ～。'
        DB	"Student:  Hey, Yamagami!"
        DB	NEXT
        ;	DB	'【%001】：・・・あ～、今行く！'
        DB	"%001:  I'll be right there!"
        DB	NEXT
        BAK_INIT "AB_27_2"
        B_P1 B_YOKO
        ;	DB	'だだだだだ・・・'
        DB	"....................................."
        DB	NEXT
        ;	DB	'【%001】：・・・ぜ～は～ぜ～は～ぜ～は～ぜ～は～・・・'
        DB	"%001:  *pant pant*"
        DB	NEXT
        ;	DB	'（・・・し、死にそう・・・）'
        DB	"...............I think I'm going to die..."
        DB	NEXT
        DB BUF,B_COPY01
        TU_CG "CT01","W",'I',35,1
        TU_CG "CT03","W",'I',12,3
        T_CG "CT02","W",'I',0,2
        DB ANI,A_ON,1
        DB ANI,A_ON,3
        ;	DB	'【鈴子】：・・・・・・%001君。'
        DB	"Reiko:  ........%001."
        DW	0000H
        
M2:		;見る　鈴子
        ;	DB	'相変らず、心配そーな顔だ。'
        DB	"She still looks worried."
        DB	NEXT
        ;	DB	'大丈夫だ、って言っても信じないだろうな、もう。'
        DB	"She won't believe me if I tell her I'm really fine."
        DW	0000H
        
M3:		;見る　清美
        ;	DB	'相変らず、心配そーな顔だ。'
        DB	"She still looks worried."
        DB	NEXT
        ;	DB	'・・・この期に及んで「やめる」とか言うつもりはないんだけどな。'
        DB	"I hope she isn't going to try to get me to quit again."
        DW	0000H
        
M4:		;見る　美緒
        ;	DB	'相変らず、心配そーな顔だ'
        DB	"She still looks worried."
        DB	NEXT
        ;	DB	'・・・美緒ちゃんのほうは、練習終わったのかな？'
        DB	"Is she done with her own practice, I wonder?"
        DW	0000H
        
M5:		;話す１
        ;	DB	'【%001】：・・・ぜ～っぜ～っぜ～っぜ～っぜ～っ・・・'
        DB	"%001:  *pant pant*"
        DB	NEXT
        ;	DB	'（・・・す、すこし休まないと・・・声が・・・）'
        DB	".....I've got to rest a little."
        ;	DB	FLG,F_COPYI,4,1
        DW	0000H
        
M6:		;話す２
        ;	DB	'【%001】：・・・みんなの気持ちは有り難いんだけどさ、せっかくここまでやったんだし・・・'
        DB	"%001:  I know how you feel, but as long as I've come this"
        DB	CR
        DB	"far, I want to go all the way."
        DB	NEXT
        ;	DB	'【清美】：・・・ですが・・・'
        DB	"Kiyomi:  Yes, but..."
        DB	NEXT
        ;	DB	'【%001】：大丈夫。ぶっ倒れたりはしないから。'
        DB	"%001:  I'm okay. I won't die, don't worry."
        DB	PAUSE
        B_O B_SUDA
        ;	DB	'・・・じゃな！暗くなんない内に帰った方がいいぜ！'
        DB	" Well, see you"
        DB	CR
        DB	"tomorrow. You should get home before it gets dark."
        DB	NEXT
        ;	DB	'【鈴子】：%001君っ！'
        DB	"Reiko:  %001!"
        DB	NEXT
        ;	DB	'【美緒】：・・・先輩・・・'
        DB	"Mio:  %001..."
        DB	NEXT
        DB	SINARIO,'CS802.OVL',0
        DW	0000H
        
M7:		;聞く　みんなの話１
        ;	DB	'【鈴子】：%001君・・・'
        DB	"Reiko:  %001..."
        DB	PAUSE
        ;	DB	'生きてる？'
        DB	" Are you alive?"
        DB	NEXT
        ;	DB	'【%001】：・・・ぜ～ぜ～ぜ～ぜ～ぜ～ぜ～・・・'
        DB	"%001:  *pant pant*"
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"Reiko:  ..............................."
        DB	FLG,F_COPYI,5,1
        DW	0000H
        
M8:		;聞く　みんなの話２
        ;	DB	'【清美】：・・・%001さん。もう限界ですわ・・・'
        DB	"Kiyomi:  %001, you're at your limit!"
        DB	NEXT
        ;	DB	'【%001】：・・・は～は～は～は～は～は～・・・'
        DB	"%001:  ....*pant pant pant*"
        DB	NEXT
        ;	DB	'【清美】：・・・・・・・・・'
        DB	"Kiyomi:  ................................."
        DB	FLG,F_COPYI,5,2
        DW	0000H
        
M9:		;聞く　みんなの話３
        ;	DB	'【美緒】：・・・%001先輩・・・もう充分だよ・・・'
        DB	"Mio:  %001, you're trying hard enough already. Stop!"
        DB	NEXT
        ;	DB	'【%001】：・・・ふ～ふ～ふ～ふ～ふ～ふ～・・・'
        DB	"%001:  *pant pant pant pant*"
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・・・・'
        DB	"Mio:  ........................."
        DB	FLG,F_COPYI,5,3
        DW	0000H
        
M10:		;聞く　みんなの話４
        ;	DB	'【鈴子】：%001君。もう約束がどうだとか、カッコ付けてる場合じゃないと思うわ。'
        DB	"Reiko:  %001, I know you said you promised, but I don't"
        DB	CR
        DB	"think it's good for you to be tough or cool."
        DB	NEXT
        ;	DB	'身体壊しちゃったら、何にもならないのよ？'
        DB	"Reiko:  If you hurt yourself..."
        DB	NEXT
        ;	DB	'【清美】：そうですわ。もう２週間たちましたし・・・%001さんを悪く言う方は、何方もおられないと思いますわ。'
        DB	"Kiyomi:  She's right. You've kept up the practice for two"
        DB	CR
        DB	"weeks, and no one would say anything about you if you quit."
        DB	NEXT
        ;	DB	'【美緒】：そうだよ！%001先輩が一生懸命やってる事、みんな知ってるよ！'
        DB	"Mio:  That's right! Everyone knows how hard you're trying!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ......................"
        DB	NEXT
        ;	DB	'【%001】：さて、息も整ったし、そろそろ行くかな。'
        DB	"%001:  I've rested. I guess I'll get back."
        DB	NEXT
        ;	DB	'【鈴子】：%001君！',CR
        ;	DB	'【清美】：%001さん！',CR
        ;	DB	'【美緒】：%001先輩！'
        DB	"Reiko:  %001!"
        DB	CR
        DB	"Kiyomi:  %001!"
        DB	CR
        DB	"Mio:  %001!"
        DB	FLG,F_COPYI,4,1
        DB	C_BLD,C_V_ON,3		;「聞く」　消す
        DW	0000H
        
M11:		;考える
        ;	DB	'・・・ホントに、心配してくれてるんだな・・・'
        DB	"They're really worried about me."
        DB	NEXT
        ;	DB	'・・・だからこそ、途中で投げ出すわけには行かない・・・！'
        DB	"But I can't stop in the middle. I can't!"
        DW	0000H


end
