;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　９０４＿Ｆ
;		二人だけの夜　亜希編

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

;NN1:	DB	1,	'亜希',0
NN1:	DB	1,	'AKI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　亜希４
S2:		DW	VV2, NN1,  2, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18		;話す　亜希１３


;イニシャルメッセージ
M1:
        DB	BGM,7
        BAK_INIT "AB_04_3"
        DB	BUF,B_COPY01
        ;	DB	'【%001】：・・・お～、さみさみ。'
        DB	"%001:  Wow, it's cold."
        DB	NEXT
        ;	DB	'１２月なだけあって、外に出ると流石に肌寒い。'
        DB	"It's December, the beginning of winter."
        DB	NEXT
        T_CG "CT06","W",0,0,0
        ;	DB	'【亜希】：・・・あ、先輩。'
        DB	"Aki:  Ah, %001."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・あれ？亜希ちゃん？'
        DB	"%001:  Aki?"
        DB	PAUSE
        ;	DB	'ど～したんだ？後で行くって・・・・・・'
        DB	" What's wrong? I told you I'd be at your house"
        DB	CR
        DB	"tonight."
        DB	NEXT
        ;	DB	'【亜希】：それなんだけど・・・・・・'
        DB	"Aki:  But we forgot one thing..."
        DB	PAUSE
        ;	DB	'先輩、あたしの家知ってるの？'
        DB	" Do you even know where I"
        DB	CR
        DB	"live?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  .........."
        DB	PAUSE
        ;	DB	'そ～言えば・・・・・・'
        DB	" No."
        DB	NEXT
        ;	DB	'【亜希】：・・・やっぱりねぇ・・・'
        DB	"Aki:  I thought so."
        DB	NEXT
        ;	DB	'ため息混じりに、亜希ちゃんが苦笑する。'
        DB	"Aki half-sighed, half smiled."
        DB	NEXT
        ;	DB	'【亜希】：そんな事だろうと思って、待ってたのよ。'
        DB	"%001:  That's why I waited for you."
        DB	PAUSE
        ;	DB	'・・・一緒に行きましょ？'
        DB	" Shall we go?"
        DB	NEXT
        ;	DB	'俺の返事も待たず、亜希ちゃんは腕を取ってグイグイ引っ張って行く。'
        DB	"Without waiting for my reply, Aki took my arm and started"
        DB	CR
        DB	"walking."
        DB	NEXT
        ;	DB	'【%001】：・・・ちょ・・・分かったから引っ張るなって！'
        DB	"%001:  ...Wait, Aki! Don't pull my arm like that!"
        DW	0000H
        
M2:		;見る　亜希１
        ;	DB	'いつも通りの、元気全開な亜希ちゃんだ。'
        DB	"It's Aki, as full of energy as ever."
        DB	NEXT
        ;	DB	'（・・・この前まで、元気全潰状態だったけど・・・ど～やら、立ち直ったみたいだな。）'
        DB	"I'm glad she got over what happened at the Sports Festival."
        DW	0000H
        
M3:		;見る　亜希２
        ;	DB	'ちらつき始めた雪を、うっとりと見上げている。'
        DB	"She's looking up at the lightly falling snow."
        DB	NEXT
        ;	DB	'（・・・こういう表情すると、可愛く思えるんだけどな・・・）'
        DB	"She's looks really cute."
        DW	0000H
        
M4:		;見る　亜希３
        ;	DB	'・・・な、な、な、な、な、・・・'
        DB	"She just looked this way."
        DB	FLG,F_COPYI,1,3
        DW	0000H
        
M5:		;見る　亜希４
        ;	DB	'気のせいか、顔が赤い。'
        DB	"Her face looks red for some reason."
        DB	NEXT
        ;	DB	'・・・ついでに俺も、多分顔が赤い・・・'
        DB	"I'll bet mine is, too."
        DW	0000H
        
M6:		;話す　亜希１
        ;	DB	'【亜希】：・・・ね、先輩・・・'
        DB	"Aki:  %001?"
        DB	PAUSE
        ;	DB	'もしかして、初めてじゃない？'
        DB	" This is the first time for us, isn't it?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ..............."
        DB	PAUSE
        ;	DB	'何が？'
        DB	" What?"
        DB	NEXT
        ;	DB	'【亜希】：こ～やって、２人っきりで話すのって。'
        DB	"Aki:  The first time we've been alone like this."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・そか？前にもあったよ～な気がするぞ。'
        DB	"%001:  Really? I seem to remember one other time..."
        DB	PAUSE,CR
        ;	DB	'文化祭の時とか・・・・・・'
        DB	"During the culture festival perhaps?" 
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・も～、恥ずかしい事思い出させないでよね。'
        DB	"Aki:  Don't remind me of things I'd rather forget."
        DB	NEXT
        ;	DB	'【%001】：・・・あ、悪ィ悪ィ。'
        DB	"%001:  I'm sorry."
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M7:		;話す　亜希２
        ;	DB	'【亜希】：・・・大体そ～じゃなくて！こんな風に一緒に帰るのが初めてじゃないかって話！'
        DB	"Aki:  What I meant was, this is the first time we've"
        DB	CR
        DB	"walked together, like this."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・なるほど。'
        DB	"%001:  ...........Oh. You're right."
        DB	NEXT
        ;	DB	'【亜希】：ホントにもう、ボケてんだから。'
        DB	"Aki:  .........Men!"
        DB	NEXT
        ;	DB	'【%001】：へいへい。'
        DB	"%001:  Hey, hey! "
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M8:		;話す　亜希３
        ;	DB	'【%001】：ところで亜希ちゃん、家どの辺にあるんだ？'
        DB	"%001:  So tell me, where do you live?"
        DB	NEXT
        ;	DB	'【亜希】：・・・えっと、○×町の３丁目だから・・・'
        DB	"Aki:  I live in Hashie-cho."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・それってもしかして、スゲー遠くない？'
        DB	"%001:  Isn't that like, really far away?"
        DB	NEXT
        ;	DB	'【亜希】：まあね。'
        DB	"Aki:  A little."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ......................."
        DB	NEXT
        ;	DB	'（・・・困ったな、こりゃ・・・）'
        DB	"What have I gotten myself in for?"
        DB	FLG,F_COPYI,2,3
        DW	0000H
        
M9:		;話す　亜希４
        ;	DB	'【%001】：・・・なあ亜希ちゃん・・・ここじゃダメか？'
        DB	"%001:  Aki, do you mind if I don't walk you home today?"
        DB	NEXT
        ;	DB	'【亜希】：えっ・・・・・・！'
        DB	"Aki:  What?"
        DB	NEXT
        ;	DB	'【%001】：ちょっと風情ないけどさ・・・亜希ちゃん家行ったら、'
        ;	DB	'俺帰れなくなっちまうよ。'
        DB	"%001:  The mood is a little different, out here in the"
        DB	CR
        DB	"street. But if I go to your house today, it'll take me hours"
        DB	CR
        DB	"to get back."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・そ、そう・・・・・・'
        DB	"Aki:  Oh..."
        DB	FLG,F_COPYI,2,4
        DW	0000H
        
M10:		;話す　亜希５
        ;	DB	'【%001】：じゃあ、はい。'
        DB	"%001:  Here you go."
        DB	NEXT
        ;	DB	'【亜希】：・・・これ・・・？'
        DB	"Aki:  What is this?"
        DB	NEXT
        ;	DB	'【%001】：クリスマスプレゼント。手渡しの方がいいと思って。'
        DB	"%001:  It's your Christmas present. I wanted to give it to"
        DB	CR
        DB	"you in person."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・・・・'
        DB	"Aki:  ............................."
        DB	NEXT
        ;	DB	'【%001】：・・・亜希ちゃん？'
        DB	"%001:  ......Aki?"
        DB	NEXT
        ;	DB	'【亜希】：・・・あ、うん・・・ありがとう。'
        DB	"Aki:  ....Oh, thank you."
        DB	FLG,F_COPYI,2,5
        DW	0000H
        
M11:		;話す　亜希６
        ;	DB	'【%001】：じゃ、俺帰るわ。'
        DB	"%001:  Well, I'm going to head back, then."
        DB	PAUSE
        ;	DB	'気ィ付けてな。'
        DB	" Be careful,"
        DB	CR
        DB	"alright?"
        DB	NEXT
        ;	DB	'【亜希】：・・・あ！先輩！！'
        DB	"Aki:  .........%001!"
        DB	NEXT
        ;	DB	'【%001】：ん？'
        DB	"%001:  Yes?"
        DB	NEXT
        ;	DB	'【亜希】：・・・あの・・・その・・・'
        DB	"Aki:  .......I........I..."
        DB	NEXT
        ;	DB	'【%001】：？'
        DB	"%001:  ???"
        DB	FLG,F_COPYI,2,6
        DW	0000H
        
M12:		;話す　亜希７
        ;	DB	'【%001】：何か用かい、亜希ちゃん？'
        DB	"%001:  Is there anything else, Aki?"
        DB	NEXT
        ;	DB	'【亜希】：・・・う、うん・・・'
        DB	"Aki:  .............Yes."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ................."
        DB	PAUSE
        ;	DB	'おや？'
        DB	"What is it?"
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・雪？'
        DB	"Aki:  ........The snow."
        DB	FLG,F_COPYI,2,7
        DW	0000H
        
M13:		;話す　亜希８
        ;	DB	'【亜希】：・・・・・・綺麗・・・・・・'
        DB	"Aki:  ............The snow is so pretty."
        DB	NEXT
        ;	DB	'【%001】：・・・ホワイトクリスマスだな・・・'
        DB	"%001:  That's right. It's going to be a White Christmas"
        DB	CR
        DB	"tomorrow."
        DB	FLG,F_COPYI,2,8
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M14:		;話す　亜希９
        ;	DB	'【亜希】：・・・・・・ねえ、先輩。'
        DB	"Aki:  ...............%001?"
        DB	NEXT
        ;	DB	'【%001】：ん？'
        DB	"%001:  Mm?"
        DB	NEXT
        ;	DB	'【亜希】：キス、した事ある？'
        DB	"Aki:  Have you ever...kissed?"
        DB	NEXT
        ;	DB	'【%001】：え゛？'
        DB	"%001:  What?"
        DB	PAUSE
        ;	DB	'・・・・・・な、何でまたそんな事を・・・・・・'
        DB	" Why are you asking me?"
        DB	NEXT
        ;	DB	'【亜希】：・・・あるの？'
        DB	"Aki:  .....Have you?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  .............."
        DB	NEXT
        ;	DB	'【%001】：まあ・・・一応。'
        DB	"%001:  Well, yes I have."
        DB	FLG,F_COPYI,2,9
        DW	0000H
        
M15:		;話す　亜希１０
        ;	DB	'【亜希】：・・・そっかあ・・・最初じゃないのかぁ・・・'
        DB	"Aki:  .......Oh. So it wouldn't be your first."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・な、何が？'
        DB	"%001:  What wouldn't?"
        DB	NEXT
        ;	DB	'【亜希】：・・・これが。'
        DB	"Aki:  ...............This."
        E_CG B_FADE,'AE_111'
        DB	NEXT
        ;	DB	'【%001】：！？'
        DB	"%001:  !?"
        DB	FLG,F_COPYI,2,10
        DB	FLG,F_COPYI,1,2
        DW	0000H
        
M16:		;話す　亜希１１
        ;	DB	'【亜希】：・・・ん・・・'
        DB	"Aki:  ......Mm."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・'
        DB	"%001:  ..............."
        DB	FLG,F_COPYI,2,11
        DW	0000H
        
M17:		;話す　亜希１２
        ;	DB	'【%001】：・・・あ、亜希ちゃん！？'"
        DB	"%001:  .....Aki..."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・プレゼントの、お返し。'
        DB	"Aki:  That was my Christmas present to you."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ............."
        DB	NEXT
        ;	DB	'【亜希】：・・・先輩・・・いや？'
        DB	"Aki:  Didn't you like it?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・'
        DB	"%001:  ..........."
        DB	PAUSE
        ;	DB	'そんな事はないよ。'
        DB	"I liked it."
        DB	FLG,F_COPYI,2,12
        DW	0000H
        
M18:		;話す　亜希１３
        ;	DB	'【亜希】：・・・・・・良かった・・・・・・'
        DB	"Aki:  I'm glad."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  .................."
        DB	NEXT
        ;	DB	'【亜希】：・・・・・・'
        DB	"Aki:  .............."
        DB	PAUSE
        ;	DB	'じ、じゃあ先輩！またね！'
        DB	"Well, goodnight!"
        DB	NEXT
        ;	DB	'【%001】：・・・あ、ああ・・・'
        DB	"%001:  Yeah, goodnight."
        DB	NEXT
        DB G_FLG,G_COPYF,160,160
        DB	FLG,F_CALI,160,30
        DB G_FLG,G_COPYG,160,160
        DB G_FLG,G_COPYI,167,1
        B_O B_WIPE
        DB	SINARIO,'CSA01.OVL',0
        DW	0000H


end
