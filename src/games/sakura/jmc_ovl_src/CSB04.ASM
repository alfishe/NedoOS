;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　B04
;		デパート
        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5
MSGTBL:
        DW	M1
COMTBL:
        DW	CM1, CM2, CM3, CM4, CM5
VNTBL:
        DW	V_FNAME,N_FNAME
ENDTBL:
        INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
        INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'LISTEN',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'出る',0
VV5:	DB	5,	'EXIT',0

;NN1:	DB	1,	'デパート',0
NN1:	DB	1,	'STORE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;見る
S2:		DW	VV2, -1,  2, M3		;話す
S3:		DW	VV3, -1,  3, M4, M5, M6, M7		;聞く
S4:		DW	VV4, -1,  4, M8		;考える
S5:		DW	VV5, NN1,  5, M9		;出る　デパート


;イニシャルメッセージ
M1:
        DB	BGM,17
        BAK_INIT "AB_37"
        B_P1 B_SUDA
        ;	DB	'【%001】：・・・あとは、食料品だな・・・'
        DB	"%001:  I've got everything but the food..."
        DB	NEXT
        ;	DB	'俺は雑貨を一通り買った後、地下の食料品売り場に移動した。'
        DB	"After I'd gotten the things she asked for, I went to the"
        DB	CR
        DB	"basement, which contained a full supermarket."
        DB	NEXT
        ;	DB	'【%001】：あっ・・・・・・！'
        DB	"%001:  Ah...!"
        DB	NEXT
        E_CG B_NORM,"AE_043"
        ;	DB	'（鈴子さん、新藤さん、美緒ちゃん・・・）'
        DB	"Reiko, Kiyomi and Mio...!"
        DB	NEXT
        ;	DB	'食料品売り場の一角、バレンタインコーナーに、間違えようもない三人を見付けた俺は、とっさに身を隠した。'
        DB	"They were looking in the 'Valentine's Day Corner.' I hid"
        DB	CR
        DB	"myself and watched them."
        DB	C_BLD,C_V_ON,5		;出る　消す
        DW	0000H
        
M2:		;見る
        ;	DB	'・・・間違いない。チョコを買ってるんだ。'
        DB	".....There's no mistake. They're buying chocolate."
        DB	NEXT
        ;	DB	'（誰にあげるんだろ？）'
        DB	"I wonder who they're going to give it to?"
        DB	NEXT
        ;	DB	'（俺にも・・・くれるのかな。）'
        DB	"....To me?"
        DW	0000H
        
M3:		;話す
        ;	DB	'（・・・いや・・・今は声をかけるべきじゃない。）'
        DB	"No, I don't think that's a good idea."
        DW	0000H
        
M4:		;聞く
        ;	DB	'【鈴子】：ごめんね美緒ちゃん、本当はこんなこと頼めた義理じゃないんだけど。'
        DB	"Reiko:  I'm sorry for asking something like this of you,"
        DB	CR
        DB	"Mio."
        DB	NEXT
        ;	DB	'【清美】：申し訳ありません・・・こればかりは慎治に教えてもらうわけには参りませんので・・・'
        DB	"Kiyomi:  Me, too. I can't really ask Shinji to help me with"
        DB	CR
        DB	"this."
        DB	NEXT
        ;	DB	'【美緒】：ううん、いいよ。先輩たちにはいつもお世話になってるから、今日はその恩返し。'
        DB	"Mio:  it's alright. Both of you always do so much for me..."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
        
M5:		;聞く
        ;	DB	'【美緒】：それで、どんなチョコを作るの？'
        DB	"Mio:  What are you going to make?"
        DB	NEXT
        ;	DB	'【鈴子】：私は難しいのは作れそうにないから・・・型抜きのハートチョコかな。'
        DB	"Reiko:  I can't make anything too difficult. I was going "
        DB	CR
        DB	"to make a molded heart made of chocolate."
        DB	NEXT
        ;	DB	'【清美】：わたくしも・・・'
        DB	"Kiyomi:  Me, too..."
        DB	NEXT
        ;	DB	'【美緒】：それなら、板チョコを湯煎して型に流して冷やすだけだけど。'
        DB	"Mio:  In that case, buy this block of chocolate and melt"
        DB	CR
        DB	"it so it fits into the mold."
        DB	NEXT
        ;	DB	'【清美】：以外と、簡単そうですわね。'
        DB	"Kiyomi:  It seems really easy."
        DB	NEXT
        ;	DB	'【美緒】：でも、チョコが焦げないように気を付けてね。'
        DB	"Mio:  But you have to be careful not to burn the chocolate."
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M6:		;聞く
        ;	DB	'【清美】：それで、美緒さんはどのようなチョコを作るのですか？'
        DB	"Kiyomi:  What kind of chocolate are you going to make?"
        DB	NEXT
        ;	DB	'【美緒】：・・・ひみつ。'
        DB	"Mio:  It's a secret."
        DB	NEXT
        ;	DB	'【鈴子】：教えてくれてもいいじゃない、どうせ私たちには真似出来ないんだから。'
        DB	"Reiko:  You can tell us. It's not like we know how to "
        DB	CR
        DB	"cook well enough to copy you."
        DB	NEXT
        ;	DB	'【美緒】：でも、秘密って言ったら秘密なの。'
        DB	"Mio:  A secret is a secret."
        DB	NEXT
        ;	DB	'【清美】：秘密と言われると、知りたくなるのが人情ですわよ。'
        DB	"Kiyomi:  If you tell us it's a secret, we want to know all the"
        DB	CR
        DB	"more."
        DB	NEXT
        ;	DB	'【鈴子】：ね、お願い！'
        DB	"Reiko:  Please, tell us!"
        DB	NEXT
        ;	DB	'【美緒】：・・・うん・・・'
        DB	"Mio:  ............Um..."
        DB	NEXT
        ;	DB	'（・・・美緒ちゃん、しゃべっちゃいそうだな・・・。）'
        DB	"Mio looks like she's about to tell her secret."
        DB	FLG,F_COPYI,3,3
        DW	0000H
        
M7:		;聞く
        ;	DB	'（これ以上聞くと、当日の楽しみが・・・）'
        DB	"If I hear anymore, it won't be any fun to wait for"
        DB	CR
        DB	"Valentine's Day to arrive."
        DW	0000H
        
M8:		;考える
        ;	DB	'（バレンタインの準備してるところを見られたって知ったら、どう思うだろ・・・）'
        DB	"What would they say if they knew I was standing here?"
        DB	NEXT
        ;	DB	'（・・・見つからない内に出た方がいいな。）'
        DB	"I should go now, before they see me."
        DB	C_BLD,C_V_OFF,5		;出る　出し
        DW	0000H
        
M9:		;出る　デパート
        ;	DB	'（見つからない内に出よう・・・）'
        DB	"It's best this way."
        DB	NEXT
        ;	DB	'俺は３人に見つからないように、デパートを後にした。'
        DB	"I leave the department store."
        DB	NEXT
        DB	SINARIO,'CSB05_.OVL',0
        DW	0000H
        

end
