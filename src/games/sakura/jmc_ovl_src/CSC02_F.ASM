;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　ＣＳＣ０２＿Ｆ
;		亜希に会う

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2
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
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0

;NN1:	DB	1,	'亜希',0
NN1:	DB	1,	'AKI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　亜希１
S2:		DW	VV2, NN1,  2, M3, M4, M5		;話す　亜希３


;イニシャルメッセージ
M1:
        DB	BGM,7
        BAK_INIT "AB_44"
        DB	BUF,B_COPY01
        DB G_FLG,G_COPYF,169,169
        DB FLG,F_JGR,169
        DW	AKITE
        ;	DB	'・・・そして俺は、屋上にやって来た。'
        DB	"I'm on the roof."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・'
        DB	"Aki:  ................"
        T_CG "CT06","W",0,15,1
        DB	PAUSE
        ;	DB	'先輩・・・・・・・・・'
        DB	"...%001!"
        DW	0000H
        
M2:		;見る　亜希１
        ;	DB	'表面上は、いつもの亜希ちゃんに見える。'
        DB	"It's just Aki, standing there, looking like she always"
        DB	CR
        DB	"looks."
        DB	NEXT
        ;	DB	'だがよく見ると、小刻みに震えているのが分かる。'
        DB	"But I can see her shaking with fear."
        DW	0000H
        
M3:		;話す　亜希１
        ;	DB	'【亜希】：・・・・・・先輩・・・・・・'
        DB	"Aki:  ....%001..."
        DB	NEXT
        ;	DB	'そう呼び掛ける亜希ちゃんの声は・・・震えていた。'
        DB	"Aki's voice was...shaking."
        DB	NEXT
        ;	DB	'俺は呼吸を整えると、ゆっくりと話し始めた。'
        DB	"I took a deep breath and started."
        DB	NEXT
        ;	DB	'【%001】：・・・なあ、亜希ちゃん・・・'
        DB	"%001:  Say, Aki..."
        DB	PAUSE
        ;	DB	'人間って、不思議だよな。'
        DB	" People are odd, wouldn't you say?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・正直言って、俺・・・・・・'
        DB	"%001:  .........I mean, to tell the truth..."
        DB	NEXT
        ;	DB	'【%001】：最初は亜希ちゃんの事、あんまり良く思ってなかった。'
        DB	"%001:  When I first met you, I didn't think much of your"
        DB	CR
        DB	"personality..."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・'
        DB	"Aki:  ............................"
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M4:		;話す　亜希２
        ;	DB	'【%001】：・・・でも聞いて欲しい。確かに最初はそうだった。'
        DB	"%001:  Please listen to what I have to say. That was then."
        DB	PAUSE,CR
        ;	DB	'だけど・・・俺は分ったんだ。'
        DB	"But now... Now I know."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・'
        DB	"Aki:  ............................"
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん・・・君は強い娘だ。'
        DB	"%001:  You're a very strong woman."
        DB	NEXT
        ;	DB	'【%001】：君はどんな時でも、誰が相手でも・・・必ず真正面からぶつかって行ったよな。'
        DB	"%001:  No matter what opponent you're up against....you"
        DB	CR
        DB	"always play hard and fair."
        DB	NEXT
        ;	DB	'【%001】：・・・だけど俺は・・・逃げてばかりいた。'
        DB	"%001:  I, on the other hand, just run away from my problems."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・'
        DB	"Aki:  ............................"
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M5:		;話す　亜希３
        ;	DB	'【%001】：亜希ちゃん。俺は君がうらやましいと思う。'
        DB	"%001:  Aki...I think I was jealous of you at times."
        DB	PAUSE
        ;	DB	'でも、うらやましがってるだけじゃダメなんだよな。'
        DB	" But I"
        DB	CR
        DB	"knew I had to do something...to be more like you."
        DB	NEXT
        ;	DB	'君のように、挑戦して、ぶつかっていかなきゃ、何も変わらないんだよな。'
        DB	"%001:  The way you take on challenges, attack problems"
        DB	CR
        DB	"head-on...I respect that in you."
        DB	NEXT
        ;	DB	'【%001】：・・・君は俺に、勇気をくれた。もし良かったらこれからも、'
        ;	DB	'俺に勇気をくれないか・・・俺の傍で。'
        DB	"%001:  You gave me strength. I'd like you to keep on giving"
        DB	CR
        DB	"me strength, at my side."
        DB	NEXT
        ;	DB	'【亜希】：・・・せんぱい・・・じゃあ・・・じゃあ・・・'
        DB	"Aki:  %001, I.....I..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・ああ。'
        DB	"%001:  Aki..."
        DB	PAUSE
        ;	DB	'亜希ちゃん、好きだ。'
        DB	" I love you."
        DB	NEXT
        B_O B_FADE
        ;	DB	'【亜希】：・・・・・・あ・・・・・・'
        DB	"Aki:  .............*sniff*...."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・ああ・・・・・・'
        DB	"Aki:  ......%001!"
        DB	NEXT
        ;	DB	'亜希ちゃんの両目から、ポロポロと涙がこぼれ出る。'
        DB	"Tears flowed freely from Aki's eyes."
        DB	NEXT
        ;	DB	'俺は亜希ちゃんを抱きしめ・・・・・・',PAUSE,'口付けを交わした。'
        DB	"I took her into my arms and kissed her."
        DB	NEXT
        DB	SINARIO,'CSE_F_1.OVL',0
        DW	0000H
        
AKITE:
        DB SINARIO,'CSE_FBAD.OVL',0
        DW	0000H
end
