;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　C03_B
;		清美に告白

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN5,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'飲む',0
VV3:	DB	3,	'DRINK',0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	'KIYOMI',0
;NN2:	DB	2,	'部屋',0
NN2:	DB	2,	'ROOM',0
;NN3:	DB	3,	'紙切れ',0
NN3:	DB	3,	'PAPER',0
;NN4:	DB	4,	'ルーズリーフ',0
NN4:	DB	4,	'BINDER',0
;NN5:	DB	5,	'烏龍茶',0
NN5:	DB	5,	'OOLONG TEA',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　清美
S2:		DW	VV1, NN2,  2, M3, M4		;見る　部屋
S3:		DW	VV1, NN3,  3, M5		;見る　紙切れ
S4:		DW	VV1, NN4,  4, M6, M7, M8, M9, M10		;見る　ルーズリーフ
S5:		DW	VV2, NN1,  5, M11, M12, M13, M14, M15, M16		;話す　清美
S6:		DW	VV3, NN5,  6, M17		;飲む　烏龍茶


;イニシャルメッセージ
M1:
        DB	BGM,18
        BAK_INIT "AB_04_1"
        DB	BUF,B_COPY01
        T_CG "CT02","W","K",15,3
        ;	DB	'【清美】：すみませんが、少々お待ち下さい。'
        DB	"Kiyomi:  Please wait here a moment, okay?"
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'【%001】：うん。'
        DB	"%001:  Okay."
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・'
        DB	"................................."
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT02","W",0,15,1
        ;	DB	'【清美】：どうぞ、%001さん。'
        DB	"Kiyomi:  Come on inside, %001."
        DB	NEXT
        ;	DB	'【%001】：おじゃまします。'
        DB	"%001:  Thanks."
        DB	NEXT
        ;	DB	'俺は新藤さんの家に入った。'
        DB	"I went into Kiyomi's house."
        BAK_INIT "AB_34_1"
        DB	BUF,B_COPY01
        T_CG "CT02","W",0,15,1
        DB	C_BLD,C_N_ON,1,4		;見る　ルーズリーフ　消す
        DB	C_BLD,C_N_ON,1,3		;見る　紙切れ　消す
        DB	C_BLD,C_V_ON,3		;のむ　消す
        DW	0000H
        
M2:		;見る　清美
        ;	DB	'妙にそわそわしてる・・・'
        DB	"She seems nervous."
        DB	NEXT
        ;	DB	'でも俺よりは落ち着いてると思うぞ。'
        DB	"But I'm even worse than she is."
        DW	0000H
        
M3:		;見る　部屋
        ;	DB	'やっぱり、女の子と密室に二人っきりって、緊張するな。'
        DB	"Being in a girl's room alone with her would make"
        DB	CR
        DB	"anyone nervous."
        DW	0000H
        
M4:		;見る　部屋
        ;	DB	'【%001】：ん？'
        DB	"%001:  Mm?"
        DB	NEXT
        ;	DB	'新藤さんの座ってたクッションのそばに、折り畳まれた紙切れが落ちていた。'
        DB	"Next to where Kiyomi was sitting, there was a folded up"
        DB	CR
        DB	"piece of paper."
        DB	C_BLD,C_N_OFF,1,3		;見る　紙切れ　出し
        DW	0000H
        
M5:		;見る　紙切れ
        ;	DB	'それは四つ折りにされたルーズリーフだった。'
        DB	"It's the kind of paper you put in a binder."
        DB	NEXT
        ;	DB	'（なんだろ・・・春休みの注意事項かな？）'
        DB	"I wonder what this is?"
        DB	C_BLD,C_N_ON,1,3		;見る　紙切れ　消し
        DB	C_BLD,C_N_OFF,1,4		;見る　ルーズリーフ　出し
        DW	0000H
        
M6:		;見る　ルーズリーフ
        ;	DB	'俺は何気なく、ルーズリーフに書き込まれた字に目を走らせた。'
        DB	"Hmmm....."
        DB	NEXT
        ;	DB	'（野球部の練習メニューかな・・・）'
        DB	"Maybe it's the training schedule for the baseball team..."
        DB	NEXT
        ;	DB	'（・・・んっ？）'
        DB	"What?"
        DB	FLG,F_COPYI,4,1
        DW	0000H
        
M7:		;見る　ルーズリーフ
        ;	DB	'どうやらその紙には、所々に俺の名前が書かれているようだ。'
        DB	"I can see my own name written here and there in the pages."
        DB	NEXT
        ;	DB	'だが、どうやら野球部のメモではないよーだ。'
        DB	"It doesn't seem to have anything to do with the baseball"
        DB	CR
        DB	"team."
        DB	FLG,F_COPYI,4,2
        DW	0000H
        
M8:		;見る　ルーズリーフ
        ;	DB	'（！！）'
        DB	"What?"
        DB	NEXT
        ;	DB	'これは、新藤さんの秘密計画書らしい。'
        DB	"This must be Kiyomi's secret plan!"
        DB	NEXT
        ;	DB	'そこには、今日、３月１４日に慎治君たちを出掛けさせることや、俺にお茶を出すことなどが、秒刻みで記されていた。'
        DB	"Everything's recorded in these pages, from her chasing"
        DB	CR
        DB	"Shinji out of the house to her getting me tea..."
        DB	FLG,F_COPYI,4,3
        DW	0000H
        
M9:		;見る　ルーズリーフ
        ;	DB	'「１８：００　%001さんに告白される」'
        DB	"'6:00    Tell my feelings to %001.'"
        DB	NEXT
        ;	DB	'「１８：０３　%001さんに唇を奪われる」'
        DB	"'6:03    %001 kisses me'"
        DB	NEXT
        ;	DB	'「１８：２０　%001さんに・・・'
        DB	"'6:20    %001 takes me to the bed...'"
        DB	NEXT
        ;	DB	'（す・・・・・・すごいことが書いてあるぞ・・・）'
        DB	"..........Incredible."
        DB	NEXT
        ;	DB	'（・・・間違いなく、新藤さんの筆跡だよな。）'
        DB	"It's her handwriting, there's no mistake."
        DB	FLG,F_COPYI,4,4
        DW	0000H
        
M10:		;見る　ルーズリーフ
        ;	DB	'（こっ・・・・・・こんなことまで・・・）'
        DB	"....She's written an incredible detailed plan!"
        DB	NEXT
        T_CG "CT02","W",0,15,1
        ;	DB	'【清美】：お待たせ致しま・・・'
        DB	"Kiyomi:  Sorry to keep you waiting."
        DB	NEXT
        ;	DB	'【%001】：うわっ！？'
        DB	"%001:  Wah!!"
        DB	NEXT
        ;	DB	'【清美】：！！'
        DB	"Kiyomi:  !!"
        DB	C_BLD,C_V_OFF,2		;話す　出し
        DB	C_BLD,C_N_ON,1,4		;見る　ルーズリーフ　消す
        DB	FLG,F_COPYI,1,0
        DB	C_BLD,C_V_OFF,3		;のむ　出し
        DW	0000H
        
M11:		;話す　清美
        ;	DB	'【清美】：%001さん。楽になさって下さい。'
        DB	"Kiyomi:  %001, please relax and enjoy yourself."
        DB	NEXT
        ;	DB	'【%001】：あ、ああ。'
        DB	"%001:  Ah, thanks."
        DB	FLG,F_COPYI,5,1
        DW	0000H
        
M12:		;話す　清美
        ;	DB	'【%001】：えっと・・・慎治君は？'
        DB	"%001:  So where's Shinji?"
        DB	NEXT
        ;	DB	'【清美】：慎治でしたら、父と二人で伯父の家に遊びに行ってますわ。'
        DB	"Kiyomi:  He went to his uncle's house with Father."
        DB	NEXT
        ;	DB	'【%001】：そ、そうなんだ。'
        DB	"%001:  I see."
        DB	NEXT
        ;	DB	'（・・・つまり、この家に二人っきりってことだ。）'
        DB	"......We're all alone here."
        DB	FLG,F_COPYI,5,2
        DW	0000H
        
M13:		;話す　清美
        ;	DB	'【清美】：あらいけない、わたくしとしたことが、お客様にお茶の一つも出さないで。'
        DB	"Kiyomi:  How forgetful of me! I forgot to get us some tea!"
        DB	NEXT
        ;	DB	'【%001】：あ、えっと、おかまいなく。'
        DB	"%001:  Don't bother yourself....."
        DB	NEXT
        ;	DB	'・・・新藤さんは風のように部屋を出ていった。'
        DB	".......Too late."
        DB	FLG,F_COPYI,2,1
        DB	FLG,F_COPYI,5,3
        DB	C_BLD,C_V_ON,2		;話す　消す
        B_P1 B_NORM
        DW	0000H
        
        
        
M14:		;話す　清美
        K_CG "CT02","R",15,2
        ;	DB	'【清美】：%001さん・・・それは・・・！'
        DB	"Kiyomi:  %001! What are you doing...?!"
        DB	NEXT
        ;	DB	'【%001】：ご、ごめん！勝手に読んだりして！'
        DB	"%001:  I'm sorry! I didn't mean to read it!"
        DB	NEXT
        ;	DB	'【清美】：・・・'
        DB	"Kiyomi:  .................."
        DB	NEXT
        ;	DB	'・・・新藤さんはトマトみたいに真っ赤になってしまった。'
        DB	".............Kiyomi turned as red as a tomato."
        DB	FLG,F_COPYI,5,4
        DW	0000H
        
M15:		;話す　清美
        ;	DB	'【%001】：本当にごめん・・・'
        DB	"%001:  .......I'm really sorry..."
        DB	NEXT
        ;	DB	'【清美】：・・・・・・・・・'
        DB	"Kiyomi:  .................."
        DW	0000H
        
        
        
M16:		;話す　清美
        ;	DB	'【%001】：・・・俺、新藤さんには、いつも世話かけてるな。'
        DB	"%001:  You've...always done so much for me."
        DB	NEXT
        ;	DB	'【清美】：・・・前にも言いましたわね。わたくしは、%001さんのお世話をしたいのです。'
        DB	"Kiyomi:  ....I told you before. I like doing things for"
        DB	CR
        DB	"you, taking care of you..."
        DB	NEXT
        ;	DB	'【清美】：わたくしがしたくてしていることですから、%001さんがお気になさることはありませんのよ。'
        DB	"Kiyomi:  I do things for you because I want to."
        DB	NEXT
        ;	DB	'【%001】：・・・。'
        DB	"%001:  ..............................."
        DB	NEXT
        ;	DB	'【%001】：新藤さん。俺は新藤さんが好きだ。'
        DB	"%001:  .....I love you, Kiyomi."
        DB	NEXT
        ;	DB	'【清美】：・・・！'
        DB	"Kiyomi:  !!"
        DB	NEXT
        ;	DB	'【%001】：俺も新藤さんに、何かをして上げたいんだ・・・されるだけじゃなく。'
        DB	"%001:  I want to do something for you...instead of just"
        DB	CR
        DB	"having you do things for me."
        DB	NEXT
        ;	DB	'【%001】：今も・・・これからも、ずっと新藤さんと支えあって、共に歩いて行きたいんだ。'
        DB	"%001:  I want to be with you. You're the one I want."
        DB	NEXT
        ;	DB	'【清美】：%001さん・・・！'
        DB	"Kiyomi:  %001....!!"
        DB	NEXT
        ;	DB	'【%001】：新藤さん。今、俺に何か出来ること、ないかな・・・'
        DB	"%001:  Kiyomi... Is there anything I can do for you?"
        DB	NEXT
        ;	DB	'【清美】：・・・'
        DB	"Kiyomi:  ..................."
        DB	NEXT
        ;	DB	'【%001】：・・・例えば・・・１８時０３分に、新藤さんの唇を奪うとか・・・'
        DB	"%001:  .......Like the kiss at 6:03..."
        DB	NEXT
        ;	DB	'【清美】：・・・どうぞ・・・いらして・・・'
        DB	"Kiyomi:  .....Yes. Please."
        DB	NEXT
        DB	SINARIO,'CSE_B_1.OVL',0
        DW	0000H
        
M17:		;飲む　烏龍茶
        ;	DB	'【%001】：あ・・・お茶、もらうね。'
        DB	"%001:  Thanks for the tea."
        DB	NEXT
        ;	DB	'【清美】：どうぞ・・・'
        DB	"Kiyomi:  It's nothing..."
        DB	NEXT
        ;	DB	'俺はコップに手を伸ばした・・・'
        DB	"I reached out my hand for the cup, but..."
        DB	NEXT
        ;	DB	'つるっ'
        DB	"*SLIP*"
        DB	NEXT
        ;	DB	'ガチャ'
        DB	"*SPLASH*"
        DB	NEXT
        ;	DB	'【%001】：つめてっ！'
        DB	"%001:  Damn!"
        DB	NEXT
        ;	DB	'注意力散漫だった俺は手を滑らせて、思いっきり脚に烏龍茶を飲ませてしまった。'
        DB	"I stupidly spilled oolong tea all over my pants."
        DB	NEXT
        T_CG "CT02","W",0,15,1
        ;	DB	'【清美】：まあ、大変！'
        DB	"Kiyomi:  Hold still!"
        DB	NEXT
        ;	DB	'清美さんは、ハンカチで俺のズボンを拭いてくれた。'
        DB	"Kiyomi took out a handkerchief and started drying my"
        DB	CR
        DB	"pants."
        DB	NEXT
        ;	DB	'【%001】：あ、ありがとう・・・'
        DB	"%001:  Thanks, Kiyomi."
        DB	FLG,F_COPYI,5,5
        DB	C_BLD,C_V_ON,3		;のむ　消し
        DW	0000H


end
