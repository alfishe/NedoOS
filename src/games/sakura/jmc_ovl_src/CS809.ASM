;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０９
;		体育祭１日前　河原の鈴子

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN1,-1

;
;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子１
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7, M8		;話す　鈴子６
S3:		DW	VV3, NN1,  3, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20		;考える　鈴子１２


;イニシャルメッセージ
M1:
        DB	BGM,29
        BAK_INIT "AB_06_2"
        DB BUF,B_COPY01
        T_CG "CT01","C",'I',20,1
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"Reiko:  .............."
        DB	NEXT
        ;	DB	'【%001】：・・・鈴子さん？'
        DB	"%001:  Reiko?"
        DB	NEXT
        ;	DB	'・・・鈴子さんとの帰り道、月が川面に映える土手で。'
        DB	"I was walking with Reiko along the river bank. The moon"
        DB	CR
        DB	"was above us."
        DB	NEXT
        ;	DB	'突然、鈴子さんは立ち止まった。'
        DB	"Suddenly Reiko stopped."
        DW	0000H
        
M2:		;見る　鈴子１
        ;	DB	'・・・何だか、元気が無いみたいだ。'
        DB	"Something seems wrong with her."
        DW	0000H
        
M3:		;話す　鈴子１
        ;	DB	'【%001】：鈴子さん・・・どうかした？'
        DB	"%001:  Reiko, what's wrong?"
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"Reiko:  ........................"
        DB	NEXT
        ;	DB	'【鈴子】：こうしていられるのも・・・・・・あと少しなのよね。'
        DB	"Reiko:  We'll only be able to be like this.......for a"
        DB	CR
        DB	"little while longer."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ........................"
        DB	NEXT
        ;	DB	'【%001】：そうだなぁ・・・・・・'
        DB	"%001:  Yeah, that's right."
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M4:		;話す　鈴子２
        ;	DB	'【%001】：・・・鈴子さん・・・'
        DB	"%001:  Reiko..."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"Reiko:  ........................"
        ;	DB	FLG,F_COPYI,2,2
        DW	0000H
        
M5:		;話す　鈴子３
        ;	DB	'【鈴子】：ねえ、%001君・・・・・・'
        DB	"Reiko:  %001..."
        DB	NEXT
        ;	DB	'地元の大学からじゃあ、金メダルは狙えないのかな？'
        DB	"Reiko:  I wonder if I went to a university around here..."
        DB	PAUSE,CR
        DB	"Would I still have a chance at that gold medal?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ........................"
        DB	PAUSE
        ;	DB	'へ？'
        DB	"What?"
        DB	FLG,F_COPYI,2,3
        DB	FLG,F_COPYI,3,9
        DW	0000H
        
M6:		;話す　鈴子４
        ;	DB	'【鈴子】：ね、どう思う・・・・・・？'
        DB	"Reiko:  What do you think?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ........................"
        DB	NEXT
        ;	DB	'【%001】：うーん、そうだなぁ・・・・・・'
        DB	"%001:  Hmmm, I'm not sure."
        ;	DB	FLG,F_COPYI,2,4
        DW	0000H
        
M7:		;話す　鈴子５
        ;	DB	'【%001】：・・・うーん、やっぱり設備とかがいい方がいいんじゃない？'
        DB	"%001:  If you're serious about the olympics, you have to"
        DB	CR
        DB	"choose a school with good training facilities."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"Reiko:  ........................"
        DB	NEXT
        ;	DB	'【%001】：そりゃあ絶対、とは言わないけどさ・・・ど～せだったら、'
        ;	DB	'少しでも目標に近付けるよーなところが・・・'
        DB	"%001:  You can never be sure, of course. But you have to"
        DB	CR
        DB	"do everything you can to stack the odds in your favor."
        DB	NEXT
        ;	DB	'って、鈴子さん？'
        DB	"%001:  Isn't that right, Reiko?"
        DB	PAUSE
        ;	DB	'聞いてる？'
        DB	" Are you listening to me?"
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"Reiko:  ............"
        DB	PAUSE
        ;	DB	'そう・・・・・・・・・'
        DB	"Yes."
        DB	FLG,F_COPYI,2,5
        DW	0000H
        
M8:		;話す　鈴子６
        ;	DB	'【%001】：あの・・・・・・鈴子さん？'
        DB	"%001:  Um, Reiko?"
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"%001:  ........"
        DB	PAUSE
        K_CG "CT01","K",20,1
        ;	DB	'%001君、ありがと。ここまででいいわ。'
        DB	"%001, thank you for walking me home. This"
        DB	CR
        DB	"is far enough, though."
        DB	NEXT
        ;	DB	'【%001】：え？'
        DB	"%001:  Huh?"
        DB	NEXT
        ;	DB	'【鈴子】：じゃ、又明日ね！'
        DB	"Reiko:  I'll see you tomorrow!"
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'【%001】：あの・・・ちょっと！？'
        DB	"%001:  Yes, but...wait...!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ...................."
        DB	NEXT
        ;	DB	'【%001】：何だったんだ？一体・・・・・・'
        DB	"%001:  What the heck is going on?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ...................."
        DB	NEXT
        ;	DB	'【%001】：帰ろ。'
        DB	"Guess I'll go home, too."
        DB	NEXT
        B_O B_SUDA
        DB	SINARIO,'CS810.OVL',0
        DW	0000H
        
M9:		;考える　鈴子１
        ;	DB	'（・・・そうだよなぁ・・・）'
        DB	"Hmmm..."
        DB	NEXT
        ;	DB	'（鈴子さんは将来の目標も、卒業後の進路も決まってるんだ。）'
        DB	"I had forgotten that Reiko had her life all planned out"
        DB	CR
        DB	"after graduating from our school."
        DB	NEXT
        ;	DB	'（・・・・・・・・・）'
        DB	"..............................."
        DB	NEXT
        ;	DB	'（鈴子さんがいなくなった後、か・・・・・・）'
        DB	"When she graduates, she'll be gone forever."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M10:		;考える　鈴子２
        ;	DB	'（鈴子さんがいなくなったら、新藤さんや美緒ちゃん、さびしがるだろうなあ。）'
        DB	"When Reiko graduates, Kiyomi and Mio are going to be"
        DB	CR
        DB	"really sad."
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M11:		;考える　鈴子３
        ;	DB	'（中野にしても亜希ちゃんにしても、鈴子さんにだけは敬意を払っていたみたいだし・・・）'
        DB	"Meimi and Aki also look up to Reiko a lot, too..."
        DB	FLG,F_COPYI,3,3
        DW	0000H
        
M12:		;考える　鈴子４
        ;	DB	'（誠なんぞ、やたらと媚売ってたしな・・・）'
        DB	"Even Makoto, in his own way."
        DB	FLG,F_COPYI,3,4
        DW	0000H
        
M13:		;考える　鈴子５
        ;	DB	'（俺は・・・・・・）'
        DB	"I............."
        DB	NEXT
        ;	DB	'（・・・・・・・・・）'
        DB	"................................."
        DB	NEXT
        ;	DB	'（俺は、鈴子さんの事をどう思っているんだろう？）'
        DB	"What are my own feelings towards Reiko?"
        DB	FLG,F_COPYI,3,5
        DW	0000H
        
M14:		;考える　鈴子６
        ;	DB	'（・・・・・・姉さん・・・・・・みたいなもんか？）'
        DB	"Is she like an older sister to me?"
        DB	NEXT
        ;	DB	'（・・・・・・・・・）'
        DB	"................................"
        DB	NEXT
        ;	DB	'（少なくとも、妹じゃないよな。）'
        DB	"No, that's not right."
        DB	FLG,F_COPYI,3,6
        DW	0000H
        
M15:		;考える　鈴子７
        ;	DB	'（鈴子さんがいなくなったら・・・・・・）'
        DB	"When she leaves..."
        DB	NEXT
        ;	DB	'（・・・・・・きっと俺の生活は、変わっちまうんだろうな。）'
        DB	"My life is going to change."
        DB	FLG,F_COPYI,3,7
        DW	0000H
        
M16:		;考える　鈴子８
        ;	DB	'（・・・・・・やめた。今からこんな辛気臭い事考えててど～する。）'
        DB	"Nevermind. I'm not going to waste anymore time thinking"
        DB	CR
        DB	"about this. It's not getting me anywhere."
        DB	NEXT
        ;	DB	'【鈴子】：・・・ねえ、%001君。'
        DB	"Reiko:  %001."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ..........................."
        DB	PAUSE
        ;	DB	'はい？'
        DB	"Yes?"
        DB	FLG,F_COPYI,3,8
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M17:		;考える　鈴子９
        ;	DB	'（鈴子さん、何か話しがあるみたいだぞ？）'
        DB	"Reiko seems to want to talk to me about something."
        ;	DB	FLG,F_COPYI,3,9
        DW	0000H
        
M18:		;考える　鈴子１０
        ;	DB	'（・・・なんだなんだ、突然。）'
        DB	"What's going on...?"
        DB	FLG,F_COPYI,3,10
        DW	0000H
        
M19:		;考える　鈴子１１
        ;	DB	'（・・・・・・・・・）'
        DB	"........................................."
        DB	NEXT
        ;	DB	'（もしかして、鈴子さんも寂しいのかな？新藤さんや美緒ちゃんと別れるのが・・・・・・）'
        DB	"Maybe Reiko's feeling sad because she's not going to be"
        DB	CR
        DB	"able to see Kiyomi and Mio anymore?"
        DB	FLG,F_COPYI,3,11
        DW	0000H
        
M20:		;考える　鈴子１２
        ;	DB	'（・・・だけど、直接会えなくたって電話とかあるんだし・・・）'
        DB	"Still, she can talk to them on the phone and everything..."
        DB	NEXT
        ;	DB	'（・・・・・・やっぱり、夢に少しでも近いところに行った方がいいよな。）'
        DB	"I guess it's best that she do what would really make her"
        DB	CR
        DB	"happy."
        DB	FLG,F_COPYI,2,4
        DB C_BLD,C_V_ON,3
        DW	0000H


end
