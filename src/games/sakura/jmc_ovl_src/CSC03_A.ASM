;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　C03_A
;		鈴子に告白

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

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7, M8, M9, M10, M11		;話す　鈴子


;イニシャルメッセージ
M1:
        DB	BGM,29
        BAK_INIT "AB_04_1"
        DB	BUF,B_COPY01
        T_CG "CT01","W","R",15,1
        ;	DB	'【鈴子】：ちょっと待ってて、部屋片付けるから。'
        DB	"Reiko:  Hang on, I'll change and be right back."
        DB	NEXT
        ;	DB	'【%001】：うん。'
        DB	"%001:  Okay."
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'・・・・・・'
        DB	".................."
        DB	NEXT
        T_CG "CT01","C","R",15,1
        ;	DB	'【鈴子】：いいわ、入って。'
        DB	"Reiko:  Okay, come on in."
        DB	NEXT
        ;	DB	'【%001】：おじゃまします。'
        DB	"%001:  Thanks."
        DB	NEXT
        ;	DB	'俺は鈴子さんの家に入った。'
        DB	"I went into Reiko's house."
        BAK_INIT "AB_31"
        DB	BUF,B_COPY01
        T_CG "CT01","C",0,15,1
        DW	0000H
        
M2:		;見る　鈴子
        ;	DB	'妙にそわそわしてる・・・'
        DB	"She seems nervous."
        DB	NEXT
        ;	DB	'でも俺よりは落ち着いてると思うぞ。'
        DB	"But I feel worse than her."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　鈴子
        ;	DB	'【%001】：あっ・・・。'
        DB	"%001:  ....Ah..."
        DB	NEXT
        ;	DB	'ふっと鈴子さんから視線をそらした時、鈴子さんの耳に輝くある物が目に止まった。'
        DB	"I turned to look and met eyes with her."
        DW	0000H
        
M4:		;話す　鈴子
        ;	DB	'【鈴子】：何か飲み物持ってくるわね。'
        DB	"Reiko:  I'll get something for us to drink..."
        DB	NEXT
        ;	DB	'【%001】：う、うん。'
        DB	"%001:  ......Okay, thanks."
        DB	NEXT
        ;	DB	'・・・・・・２分経過・・・・・・'
        DB	".....Two minutes later."
        DB	NEXT
        ;	DB	'【鈴子】：コーラでいいわね？'
        DB	"Reiko:  Is cola fine?"
        DB	NEXT
        ;	DB	'【%001】：う、うん。'
        DB	"%001:  Y- Yes, sure."
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M5:		;話す　鈴子
        ;	DB	'【鈴子】：ど、どうしたの%001君。な、なんか硬直してない？'
        DB	"Reiko:  What's the matter, %001? You seem really nervous."
        DB	NEXT
        ;	DB	'【%001】：れ、鈴子さんこそ・・・'
        DB	"%001:  R- Reiko..."
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M6:		;話す　鈴子
        ;	DB	'【%001】：あの・・・'
        DB	"%001:  I....."
        DB	CR
        ;	DB	'【鈴子】：それで・・・'
        DB	"Reiko:  What do you...?"
        DB	NEXT
        ;	DB	'【鈴子】：！　あ、%001君からどうぞ。'
        DB	"Reiko:  You go first, please."
        DB	NEXT
        ;	DB	'【%001】：う、うん。'
        DB	"%001:  Okay."
        DB	NEXT
        ;	DB	'【%001】：えっと・・・静かだね。'
        DB	"%001:  It's really quiet now."
        DB	NEXT
        ;	DB	'【鈴子】：うん、今日うちのパパとママいないから。'
        DB	"Reiko:  Yes, my parents are out for the evening."
        DB	NEXT
        ;	DB	'【%001】：そ、そうなんだ。'
        DB	"%001:  O- Oh, really?"
        DB	FLG,F_COPYI,2,3
        DW	0000H
        
        
M7:		;話す　鈴子
        ;	DB	'【鈴子】：な、何か音楽でもかけよっか？'
        DB	"Reiko:  Shall we listen to some music or something?"
        DB	NEXT
        ;	DB	'【%001】：う、うん。'
        DB	"%001:  Okay, that's a good idea."
        DB	NEXT
        ;	DB	'（落ち着け・・・落ち着け・・・）'
        DB	"(Relax.......relax....)"
        DB	NEXT
        ;	DB	'【鈴子】：あ、あれ？ＣＤのリモコンがないわ・・・'
        DB	"Reiko:  Where's the remote control for the CD player?"
        DB	CR
        DB	"I can't find it anywhere."
        DB	NEXT
        ;	DB	'【%001】：そ、そうなんだ。'
        DB	"%001:  Oh really?"
        DB	NEXT
        ;	DB	'（・・・何を言ってるんだ俺は！？）'
        DB	"(What am I wasting time like this for?)"
        DB	FLG,F_COPYI,2,4
        DW	0000H
        
M8:		;話す　鈴子
        ;	DB	'【鈴子】：それで・・・・・・・・・大事な話って、何？'
        DB	"Reiko:  So. What did you want to talk about?"
        DB	NEXT
        ;	DB	'（来たぁ！）'
        DB	"(It's time!)"
        DB	FLG,F_COPYI,2,5
        DW	0000H
        
        
M9:		;話す　鈴子
        ;	DB	'【%001】：鈴子さん！'
        DB	"%001:  Reiko!"
        DB	NEXT
        ;	DB	'【鈴子】：はいっ！'
        DB	"Reiko:  Yes?"
        DB	NEXT
        ;	DB	'【%001】：あ・・・その、ですね・・・'
        DB	"%001:  I.....um, well..."
        DB	FLG,F_COPYI,2,6
        DW	0000H
        
        
M10:		;話す　鈴子
        ;	DB	'【%001】：鈴子さん、そのイヤリング・・・'
        DB	"%001:  Reiko...your earrings..."
        DB	NEXT
        ;	DB	'【鈴子】：あ、これ？そうよ、誕生プレゼントで%001君にもらったヤツ。'
        DB	"Reiko:  Oh, these? They're the ones you gave me for my"
        DB	CR
        DB	"birthday."
        DB	NEXT
        ;	DB	'【鈴子】：学校にしてくわけには行かないから、家でしか付けてなかったけど。'
        DB	"Reiko:  I can't wear them in school, so I wear them"
        DB	CR
        DB	"while I'm at home."
        DB	NEXT
        ;	DB	'【%001】：ありがとう・・・付けてくれてたんだ・・・。'
        DB	"%001:  Thanks. It makes me happy to see you wearing them."
        DB	NEXT
        ;	DB	'【鈴子】：当然よ、%001君にもらった物だもの。'
        DB	"Reiko:  Of course! You gave them to me, after all."
        DB	NEXT
        ;	DB	'【鈴子】：私の大切な、宝物よ・・・'
        DB	"Reiko:  I...treasure them."
        DB	FLG,F_COPYI,2,7
        DW	0000H
        
        
M11:		;話す　鈴子
        ;	DB	'【%001】：あの頃からかな・・・俺が鈴子さんを一人の女性として、意識するようになったのは。'
        DB	"%001:  I think that your birthday party was when I first"
        DB	CR
        DB	"started thinking of you as a woman, and not just a friend..."
        DB	NEXT
        ;	DB	'【鈴子】：！'
        DB	"Reiko:  !!"
        DB	NEXT
        ;	DB	'【%001】：鈴子さん。俺は鈴子さんが好きだ。'
        DB	"%001:  I love you, Reiko."
        DB	NEXT
        ;	DB	'【鈴子】：%001君・・・！'
        DB	"Reiko:  %001....!!"
        DB	NEXT
        ;	DB	'【%001】：・・・例え遠く離れても、俺は鈴子さんを愛し続けます・・・'
        DB	"%001:  Even if we're separated, I'll still love you..."
        DB	NEXT
        ;	DB	'【鈴子】：・・・'
        DB	"Reiko:  ............"
        DB	NEXT
        ;	DB	'【%001】：・・・これからも、迷惑かけると思うけど・・・鈴子さんを、好きでいさせて欲しいんだ。'
        DB	"%001:  .....I hope that's alright with you."
        DB	PAUSE
        ;	DB	'ダメかな・・・？'
        DB	" Is it?"
        DB	NEXT
        ;	DB	'【鈴子】：馬鹿ね、いいに決まってるじゃない！'
        DB	"Reiko:  Don't be stupid! Of course it is!"
        DB	NEXT
        ;	DB	'鈴子さんの腕が、ふわっと俺を包みこむ。柔らかい抱擁。'
        DB	"Reiko's arms opened to envelop me, then closed softly"
        DB	CR
        DB	"around me."
        DB	NEXT
        ;	DB	'【%001】：鈴子さん・・・。'
        DB	"%001:  Reiko....."
        DB	NEXT
        ;	DB	'鈴子さんのピンク色の唇が俺に近付いてくる。'
        DB	"Reiko's pink lips moved towards me."
        DB	NEXT
        ;	DB	'俺は迷わず、唇を重ねた・・・'
        DB	"I kissed her."
        DB	NEXT
        DB	SINARIO,'CSE_A_1.OVL',0
        DW	0000H


end
