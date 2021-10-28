;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　
;		美緒の家

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	'MIO',0
;NN2:	DB	2,	'部屋',0
NN2:	DB	2,	'ROOM',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　美緒
S2:		DW	VV1, NN2,  2, M3		;見る　部屋
S3:		DW	VV2, NN1,  3, M4, M5, M6, M7, M8, M9		;話す　美緒
S4:		DW	VV3,  -1,  4, M10		;考える


;イニシャルメッセージ
M1:
        DB	BGM,19
        BAK_INIT "AB_04_3"
        B_P1 B_SUDA
        ;	DB	'・・・着いた。'
        DB	"I'm here."
        DB	NEXT
        ;	DB	'一応美緒ちゃんに地図を描いてもらったんだけど、目標になるようなモンがないからえらく苦労してしまった。'
        DB	"Mio drew me a map to her house, but she didn't put any"
        DB	CR
        DB	"landmarks on it, so it was hard to figure it out."
        DB	NEXT
        ;	DB	'しかしまあ、一度来たらもう忘れないくらい、単純な道順ではあったが・・・'
        DB	"Now that I've been here once, it'll be easy to find"
        DB	CR
        DB	"again."
        DB	NEXT
        ;	DB	'さて、美緒ちゃん待ってるかな？'
        DB	"Is she waiting for me?"
        DB	NEXT
        ;	DB	'ピンポーン'
        DB	"*DING DONG*"
        DB	NEXT
        ;	DB	'・・・後は、美緒ちゃんが出てくるのを待つだけ。'
        DB	".....Now Mio will come out, and..."
        DB	NEXT
        ;	DB	'がちゃっ。'
        DB	"*kacha*"
        DB	NEXT
        T_CG1 "CT03","C",0,12,1
        ;	DB	'【美緒】：・・・%001先輩？'
        DB	"Mio:  %001?"
        DB	NEXT
        ;	DB	'【%001】：よ。'
        DB	"%001:  Yo."
        DB	NEXT
        ;	DB	'【美緒】：あ・・・ど、どうぞ、上がって下さい！'
        DB	"Kiyomi:  Oh, come in! Please come in!"
        DB	NEXT
        ;	DB	'【%001】：？ああ、んじゃ、遠慮なく。'
        DB	"%001:  Okay, thanks."
        BAK_INIT "AB_32"
        DB BUF,B_COPY01
        T_CG "CT03","C","R",12,2
        DW	0000H
        
M2:		;見る　美緒
        ;	DB	'・・・どーしたんだろ、真っ赤になってる。'
        DB	"What's wrong? Her face is red."
        DB	NEXT
        ;	DB	'・・・なんか、悪い事したかな、おれ？'
        DB	"Am I intruding by coming over like this?"
        DW	0000H
        
M3:		;見る　部屋
        ;	DB	'美緒ちゃんの部屋・・・'
        DB	"This is Mio's room..."
        DB	NEXT
        ;	DB	'すごくシンプルで、飾り気のない美緒ちゃんらしい。'
        DB	"The design is very simple, without much in the way of"
        DB	CR
        DB	"decoration."
        DB	NEXT
        ;;	DB	'きちんと掃除をしている証拠だ。'
        DB	"It's really clean."
        DW	0000H
        
M4:		;話す　美緒
        ;	DB	'【美緒】：そっ、それじゃあ、あたしお茶入れるね。'
        DB	"Mio:  H- hang on, I'll get us some tea."
        DB	NEXT
        ;	DB	'【%001】：あ、ああ。'
        DB	"%001:  Okay, thanks."
        DB	NEXT
        ;	DB	'なんか、手元が危ういな・・・。'
        	DB	"Her hands are shaking."
        	DB	NEXT
        ;	DB	'・・・大丈夫かいな・・・'
        DB	"I wonder if she's alright."
        DB	NEXT
        ;	DB	'【美緒】：わっ！'
        DB	"Mio:  Oh no!"
        DB	NEXT
        ;	DB	'【美緒】：・・・お茶の葉・・・出しすぎちゃった・・・'
        DB	"Mio:  I put too much tea in the pot. It'll be too strong."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・まあ、失敗は誰にでもあるさ。'
        DB	"%001:  It's alright. Everyone makes mistakes."
        DB	NEXT
        ;	DB	'【美緒】：ごめんなさい、もう大丈夫。'
        DB	"Mio:  There, now it's okay."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M5:		;話す　美緒
        ;	DB	'【%001】：ああ・・・ホントに大丈夫か？'
        DB	"%001:  Are you sure I'm not interrupting anything by coming"
        DB	CR
        DB	"over like this?"
        DB	NEXT
        ;	DB	'【美緒】：うん、大丈夫！'
        DB	"Mio:  No, it's fine!"
        DB	NEXT
        ;	DB	'・・・・・・俺はとりあえず美緒ちゃんの言葉を信じよう。'
        DB	"I guess there's nothing to do but believe her. I'm still"
        DB	CR
        DB	"not convinced, though."
        DB	NEXT
        ;	DB	'【%001】：・・・ホント、大丈夫だろうな・・・？'
        DB	"%001:  Well, in that case..."
        DB	NEXT
        ;	DB	'【美緒】：わあっ！'
        DB	"Mio:  Wah!!"
        DB	NEXT,FLASH,1
        ;	DB	'がっしゃーん！'
        DB	"*CRACK*"
        DB	NEXT
        ;	DB	'【%001】：・・・おいおいおいおいっ！'
        DB	"%001:  Woah!"
        DB	NEXT
        K_CG "CT03","I",12,3
        ;	DB	'【%001】：美緒ちゃん！？'
        DB	"%001:  Mio, are you okay?"
        DB	NEXT
        ;	DB	'【美緒】：湯呑み割っちゃった・・・'
        DB	"Mio:  Darn, I broke the cup."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・ま、誰にでも失敗はあるさ・・・さ、とりあえず片づけよう。'
        DB	"%001:  That's okay, even monkeys fall out of trees..."
        DB	CR
        DB	"You know, everyone makes mistakes."
        DB	NEXT
        DB	"%001:  Let's clean it up, though."
        DB	NEXT
        ;	DB	'【美緒】：うん・・・'
        DB	"Mio:  Okay."
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M6:		;話す　美緒
        ;	DB	'【%001】：ホンットに大丈夫かい？手伝おうか？'
        DB	"%001:  Are you sure I can't help you with anything?"
        DB	NEXT
        ;	DB	'【美緒】：ううん、平気だから、%001先輩はお客さんなんだから。'
        DB	"Mio:  It's fine. You're a guest, so just sit down and"
        DB	CR
        DB	"relax."
        DB	NEXT
        ;	DB	'【%001】：ホントに～？'
        DB	"%001:  Really?"
        DB	NEXT
        K_CG "CT03","K",12,4
        ;	DB	'【美緒】：うん、平気平気！'
        DB	"Mio:  Really!"
        DB	NEXT
        ;	DB	'【%001】：んじゃあ・・・'
        DB	"%001:  Okay..."
        DB	NEXT
        ;	DB	'・・・まあ、３度目の正直って言葉もあるし・・・'
        DB	"When someone says something three times, they mean it."
        DB	NEXT
        ;	DB	'・・・・・・まさか。考えすぎ・・・・・・'
        ;	DB	'やっぱり心配になった俺は、美緒ちゃんから目を離さないことに决めた。'
        DB	"But still, I decided to not take my eyes off of Mio."
        DB	NEXT
        ;	DB	'・・・・・・どうにか、落ち着いてお茶を入れている。'
        DB	"She's pouring the tea now."
        DB	NEXT
        ;	DB	'・・・最初から見てりゃよかったんだよな・・・'
        DB	"I should have been watching last time, to save her from"
        DB	CR
        DB	"breaking the cup."
        DB	FLG,F_COPYI,3,3
        DW	0000H
        
M7:		;話す　美緒
        ;	DB	'【美緒】：先輩、おまたせ～。'
        DB	"Mio:  Here you are, %001."
        DB	NEXT
        ;	DB	'【%001】：さんきゅ、美緒ちゃん'
        DB	"%001:  Thanks, Mio."
        DB	NEXT
        ;	DB	'【美緒】：ううん・・・いつも、迷惑かけてばっかりだから。これくらい・・・'
        DB	"Mio:  It's nothing, really. I'm usually imposing on you"
        DB	CR
        DB	"at school, so I'm glad you're here, where I can do"
        DB	CR
        DB	"something for you for a change."
        DB	NEXT
        ;	DB	'【%001】：なぁに言ってんの。逆だろ？'
        DB	"%001:  Huh? I think it's the other way around. I'm the "
        DB	CR
        DB	"one always imposing on you."
        DB	NEXT
        ;	DB	'【美緒】：ううん、そんなことないよ！'
        DB	"Mio:  No, definitely not!"
        DB	NEXT
        ;	DB	'【%001】：ありがと、美緒ちゃんは優しいな。'
        DB	"%001:  ........Thanks. You're a nice person, Mio."
        DB	NEXT
        ;	DB	'【美緒】：そ・・・そんなことないよ・・・'
        DB	"Mio:  Thanks."
        DB	FLG,F_COPYI,3,4
        DW	0000H
        
M8:		;話す　美緒
        ;	DB	'ずずっ。'
        DB	"*sip sip*"
        DB	NEXT
        ;	DB	'【%001】：はぁ、熱いお茶がうまい。'
        DB	"%001:  This is good."
        DB	NEXT
        ;	DB	'【%001】：あ、そーだ。はい、美緒ちゃん。'
        DB	"%001:  Oh, I almost forgot. Here you go."
        DB	NEXT
        ;	DB	'【美緒】：え？これ・・・'
        DB	"Mio:  What's this?"
        DB	NEXT
        ;	DB	'【%001】：そ、一応、手作りだから・・・気に入ってもらえればいいけど。'
        DB	"%001:  I made it myself. I hope you like it."
        DB	NEXT
        ;	DB	'【美緒】：あ・・・すごい、綺麗なブローチ・・・ありがとう！%001先輩！'
        DB	"Mio:  It's a pretty brooch! Thank you, %001!"
        DB	NEXT
        ;	DB	'【%001】：いやなになに。大したモンじゃないよ。'
        DB	"%001:  It's nothing, really."
        DB	NEXT
        ;	DB	'【美緒】：ううん！あたし、これ、一生大事にするね！'
        DB	"Mio:  It's beautiful! I'll treasure it all my life!"
        DB	FLG,F_COPYI,3,5
        DW	0000H
        
M9:		;話す　美緒
        ;	DB	'俺と美緒ちゃんはしばらく話し込んでいた。'
        DB	"Mio and I relaxed, then, talking about school."
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT03","C",0,12,1
        ;	DB	'【美緒】：・・・でね、亜希ちゃんたらね、「次は敗けないからっ！」って言ってね・・・'
        DB	"Mio:  ....And then Aki said, 'I'll beat you next time,'"
        DB	CR
        DB	"like she was so tough..."
        DB	NEXT
        ;	DB	'【%001】：ふん、ふん？'
        DB	"%001:  Uh-huh."
        DB	NEXT
        ;	DB	'【美緒】：でね、そのまま後ろ向いて歩きだそうとして、ボール踏んで転んじゃったの。'
        DB	"Mio:  And then she turned around and started to walk"
        DB	CR
        DB	"away...but she stepped on a tennis ball and fell!"
        DB	NEXT
        ;	DB	'【%001】：・・・最後が締まんねー辺り、亜希ちゃんらしいよな。'
        DB	"%001:  That's just like her."
        DB	NEXT
        ;	DB	'【美緒】：でもね、亜希ちゃん、この頃すごく上手くなってきたんだ！'
        DB	"Mio:  On the other hand, her game really has improved in"
        DB	CR
        DB	"the past few months."
        DB	NEXT
        ;	DB	'【%001】：へえ、すごいじゃないか。美緒ちゃんにそこまで言わせるなんて。'
        DB	"%001:  Really? That's good. I'll have to watch her next"
        DB	CR
        DB	"time."
        DB	NEXT
        ;	DB	'【美緒】：うん！この頃、亜希ちゃんとテニスするのがとても楽しいの！'
        DB	"Mio:  Yes, I even enjoy playing with her these days. She's"
        DB	CR
        DB	"a good rival..."
        DB	NEXT
        ;	DB	'【%001】：そっか。よかったよな。いよいよライバルだな。'
        DB	"%001:  That's good. Everyone needs a rival."
        DB	NEXT
        ;	DB	'【美緒】：うん・・・'
        DB	"Mio:  Yeah..."
        DB	NEXT
        ;	DB	'【美緒】：・・・%001先輩・・・楽しいこと・・・見つけたの？'
        DB	"Mio:  %001...did you find something that was...fun for"
        DB	CR
        DB	"you, like tennis is for me?"
        DB	NEXT
        ;	DB	'【%001】：？・・・・・・は？'
        DB	"%001:  What?"
        DB	NEXT
        ;	DB	'【美緒】：だって、%001先輩が体育祭の練習をあんなに頑張れたのって、なにか打ち込めるようなこと、見つけたからなんじゃないかな、と思って。'
        DB	"Mio:  During the sports festival, you were in so many"
        DB	CR
        DB	"different sporting events. I was just wondering if you"
        DB	CR
        DB	"found one that you liked."
        DB	NEXT
        ;	DB	'【%001】：ん～、そうだな・・・そうかも知れない。楽しいこと・・・'
        DB	"%001:  Hmm. I think so."
        DB	NEXT
        ;	DB	'・・・俺が頑張れば美緒ちゃん達がが心から拍手をしてくれることかな。だから、我ながら無茶だと思った練習もこなせたんだろう・・・'
        DB	"%001:  Trying hard and having you all cheer me on was"
        DB	CR
        DB	"fun. I enjoyed that."
        DB	NEXT
        ;	DB	'【美緒】：え？・・・%001先輩・・・'
        DB	"Mio:  ..........%001..."
        DB	NEXT
        ;	DB	"【%001】：だから、その・・・やるべきことを見つけた、とか大げさなことじゃなくて・・・"
        DB	"%001:  It's not like I'm dedicating myself to one thing"
        DB	CR
        DB	"like you are to tennis. It's more vague than that."
        DB	NEXT
        ;	DB	"【%001】：俺を本気で心配して応援してくれる人達がいるってわかっただけなんだ。"
        DB	"%001:  I just want to do my best for my friends."
        DB	NEXT
        DB	"............................................"
        DB	NEXT
        ;	DB	"そしてしばらく、俺は美緒ちゃんと楽しくお話をした。'
        DB	"I talked with Mio for a while longer."
        DB	NEXT
        ;	DB	'もっぱら俺が話題の中心で、俺の小さな頃のことを聞きたがる美緒ちゃんをはぐらかしたり、俺の失敗談で美緒ちゃんが楽しげに笑ったりしているうちに、時間は随分と遅くなってしまった。'
        DB	"We talked about my youth, and about the school year."
        DB	CR
        DB	"I made her laugh with tales of various failures I've"
        DB	CR
        DB	"had in my life."
        DB	NEXT
        ;	DB	'【%001】：お、もうこんな時間か・・・俺、そろそろ帰らんと。'
        DB	"%001:  Oh, it's late."
        DB	NEXT
        ;	DB	'【美緒】：え～～・・・もう、帰っちゃうの？'
        DB	"Mio:  .......Are you going home already?"
        DB	NEXT
        ;	DB	'【%001】：おー、俺は寝る時間にはこだわりがあるんだ。'
        DB	"%001:  Yeah, I always like to go to bed early."
        DB	NEXT
        ;	DB	'【美緒】：・・・起きる時間には？'
        DB	"Mio:  So you can wake up on time?"
        DB	NEXT
        ;	DB	'【%001】：全然こだわんない。'
        DB	"%001:  No, I don't care about that."
        DB	NEXT
        ;	DB	'【美緒】：・・・くすっ、だから、入学式初日から遅刻したりしたんだ？'
        DB	"Mio:  .....Haha. That's why you were late to the opening"
        DB	CR
        DB	"ceremony in April?"
        DB	NEXT
        ;	DB	'【%001】：そーそー・・・って、なんで美緒ちゃんが知ってるの？'
        DB	"%001:  That's right. Hey, how do you know about that?"
        DB	NEXT
        ;	DB	'【美緒】：みんなに聞いたの。'
        DB	"Mio:  I heard from everyone."
        DB	NEXT
        ;	DB	'【美緒】：あはは、じゃ、%001先輩、途中まで送ってくね。'
        DB	"Mio:  I'll walk you part of the way home."
        DB	NEXT
        ;	DB	'【%001】：いや、いいよ。もう、随分遅いしさ。'
        DB	"%001:  No, it's okay. It's late for you, too."
        DB	NEXT
        ;	DB	'【美緒】：%001先輩・・・'
        DB	"Mio:  %001...."
        DB	NEXT
        ;	DB	'【%001】：気持ちだけもらっとくよ。'
        DB	"%001:  Thanks anyway, though."
        DB	NEXT
        ;	DB	'【美緒】：じゃあ、せめて玄関まで・・・'
        DB	"Mio:  Well, I'll see you to the door at least."
        DB	NEXT
        BAK_INIT "AB_04_3"
        B_P1 B_SUDA
        ;	DB	'・・・・・・・・・・・・'
        DB	"....................."
        DB	NEXT
        ;	DB	'【美緒】：あ・・・雪・・・'
        DB	"Mio:  It's snowing!"
        DB	NEXT
        ;	DB	'【%001】：お、ホントだ。'
        DB	"%001:  You're right."
        DB	NEXT
        ;	DB	'【美緒】：・・・綺麗・・・'
        DB	"Mio:  It's pretty..."
        DB	NEXT
        ;	DB	'【%001】：ああ・・・ロマンチックだよな。'
        DB	"%001:  Yes. Very romantic."
        DB	NEXT
        ;	DB	'【美緒】：うん・・・%001先輩？'
        DB	"Mio:  .....%001?"
        DB	NEXT
        ;	DB	'【%001】：・・・なに？'
        DB	"%001:  Yes?"
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・その・・・今日は、ありがとう。'
        DB	"Mio:  Um, th- thank you for coming over today."
        DB	NEXT
        ;	DB	'【%001】：なに言ってんのさ、それは俺が言うセリフだぜ？'
        DB	"%001:  Shouldn't I say that to you?"
        DB	NEXT
        ;	DB	'【美緒】：%001先輩・・・'
        DB	"Mio:  %001...."
        DB	NEXT
        ;	DB	'【%001】：美緒ちゃん、サンキュな。'
        DB	"%001:  Take care. Don't catch a cold in this snow."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・行っちゃった。'
        DB	"Mio:  He's gone."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・今日は・・・今は、まだ・・・いいよね？'
        DB	"Mio:  ......Please, %001, please..."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・でも、いつか・・・先輩・・・'
        DB	"Mio:  .....Please choose me."
        DB	NEXT
        B_O B_WIPE
        DB G_FLG,G_COPYF,130,130
        DB	FLG,F_CALI,130,20
        DB G_FLG,G_COPYG,130,130
        DB G_FLG,G_COPYI,137,1
        DB	SINARIO,'CSA01.OVL',0
        DW	0000H
        
M10:		;考える
        ;	DB	'なんだか、今日の美緒ちゃんって・・・落ち着きないなあ。'
        DB	"She seems nervous today."
        DB	NEXT
        ;	DB	'・・・いつも元気だ、とは思ったけど・・・'
        DB	"I wonder why that is?"
        DW	0000H


end
