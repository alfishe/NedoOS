;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　９０４＿Ｅ
;		クリスマス：瑠璃

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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	NN2,NN3,NN4,-1
CM4:	DW	VV4,	NN5,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0 
;VV4:	DB	4,	'渡す',0
VV4:	DB	4,	'GIVE',0

;NN1:	DB	1,	'部屋',0
NN1:	DB	1,	'ROOM',0
;NN2:	DB	2,	'瑠璃',0
NN2:	DB	2,	'RURI',0
;NN3:	DB	3,	'友達',0
NN3:	DB	3,	'FRIEND',0
;NN4:	DB	4,	'母親',0
NN4:	DB	4,	'MOTHER',0
;NN5:	DB	5,	'プレゼント',0
NN5:	DB	5,	'PRESENT',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　部屋
S2:		DW	VV2, NN2,  2, M3, M4, M5, M6, M7, M8, M9		;話す　瑠璃
S3:		DW	VV3, NN2,  3, M10		;聞く　瑠璃
S4:		DW	VV3, NN3,  4, M11		;聞く　友達
S5:		DW	VV3, NN4,  5, M12		;聞く　母親
S6:		DW	VV4, NN5,  6, M13		;渡す　プレゼント

;イニシャルメッセージ
M1:
	DB	BGM,31
	BAK_INIT "AB_06_2"
	B_P1 B_SUDA
;	DB	'【%001】：・・・けっこう遠いんだな。'
	DB	"%001:  You live pretty far away..."
	DB	NEXT
;	DB	'【瑠璃】：そう？'
	DB	"Ruri:  You think so?"
	DB	NEXT
;	DB	'俺達は川沿いの道を二人で歩いてた。道を知らない俺は自然と彼女の後ろを歩くことになる。'
	DB	"We were walking along a river. I had no idea where I was,"
	DB	CR
	DB	"so I just followed her."
	DB	NEXT
;	DB	'【%001】：・・・寒いね。'
	DB	"%001:  It's cold."
	DB	NEXT
;	DB	'【瑠璃】：そうね。'
	DB	"Ruri:  Yes, it is."
	DB	NEXT
;	DB	'・・・会話が続かない。'
	DB	"....It's really hard to have a conversation with her."
	DB	NEXT
;	DB	'街の方から聞こえてくるクリスマスソングに耳を傾けながら、彼女の後ろ姿を追いかける。'
	DB	"Bending my ear to hear the Christmas music flowing from"
	DB	CR
	DB	"a nearby department store, I followed Ruri."
	DB	NEXT
	T_CG1 "CT05","C",0,15,1		;瑠璃立ちポーズ
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ........................."
	DB	NEXT
;	DB	'唐突に白水さんが立ち止まった。'
	DB	"Suddenly she stopped."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DW	0000H

M2:		;見る　部屋
;	DB	'白水さんの住むワンルームマンションだ。'
	DB	"This is the one room apartment where Ruri lives."
	DB	NEXT
;	DB	'・・・きれいに片付いてるな。'
	DB	"It's very clean."
	DW	0000H

M3:		;話す　瑠璃
;	DB	'【%001】：・・・どうしたの？'
	DB	"%001:  What's wrong?"
	DB	NEXT
;	DB	'【瑠璃】：・・・どうしてウチに来るの？'
	DB	"Ruri:  ............Why do you want to come to my house?"
	DB	NEXT
;	DB	'【%001】：いや、だからプレゼントを渡そうと思って。'
	DB	"%001:  ..............Well, I wanted to give you a present."
	DB	NEXT
;	DB	'【瑠璃】：どうして？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【%001】：クリスマスだからさ。'
	DB	"%001:  Because it's Christmas tomorrow."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・そう。'
	DB	"Ruri:  .......Oh."
	DB	NEXT
;	DB	'再び歩き出す白水さん。'
	DB	"She started walking again."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・%001君。'
	DB	"Ruri:  ...........%001."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・・・・・・・',PAUSE,'クリスマスって、なに？'
	DB	"Ruri:  .........",PAUSE,"What is Christmas, anyway?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・え゛？'
	DB	"%001:  ...............What?"
	DB	NEXT
;	DB	'【瑠璃】：なにかのお祭りなの？'
	DB	"Ruri:  Is it some kind of festival, like the Tanabata Star"
	DB	CR
	DB	"Festival in August?"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　瑠璃
;	DB	'【%001】：・・・・・・白水さん・・・・・・本気で知らないの？'
	DB	"%001:  .......You really don't know?"
	DB	NEXT
;	DB	'【瑠璃】：ごめんなさい・・・'
	DB	"Ruri:  I'm sorry."
	DB	NEXT
;	DB	'【%001】：いや、謝らなくてもいいけど・・・'
	DB	"%001:  You don't have to apologize or anything."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　瑠璃
;	DB	'【%001】：え～っと、クリスマスってのはイエス・キリストの誕生日なんだ。'
	DB	"%001:  Well, Christmas is the birth of Jesus Christ."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・%001君の知り合い？'
	DB	"Ruri:  ......Do you know this person?"
	DB	NEXT
;	DB	'【%001】：・・・昔の人だよ。'
	DB	"%001:  ........He lived a long time ago."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;話す　瑠璃
;	DB	'【%001】：・・・・・・あれ？白水さん、神様を信じてるんじゃなかったっけ？'
	DB	"%001:  I thought you said you believed in God."
	DB	NEXT
;	DB	'【瑠璃】：お母様が「いる」って言うから私も信じることにしてるの。でも本当は分からない。'
	DB	"Ruri:  My mother says God exists, so I try to believe."
	DB	CR
	DB	"But I don't know..."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  ...........I see."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;話す　瑠璃
;	DB	'【%001】：ま、それはそれとして、日本じゃ親しいもの同士で集まってパーティしたりする、神様には関係ないイベントだよ。'
	DB	"%001:  In Japan, Christmas is a time when friends get"
	DB	CR
	DB	"together and have a party. Christmas really has very little"
	DB	CR
	DB	"to do with God in Japan."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・パーティなら、今したわ。他に何かするの？'
	DB	"Ruri:  ....We just had the party. What else is there?"
	DB	FLG,F_COPYI,2,5
	DW	0000H

M8:		;話す　瑠璃
;	DB	'【%001】：そうだな・・・ん～・・・'
	DB	"%001:  ..........I'm not really sure myself."
	DB	NEXT
;	DB	'白水さん・・・俺のことどう思ってるんだろ。',CR,PAUSE,'クラスメイト？',PAUSE,'友達？',PAUSE,'・・・タダのおせっかい焼き？',CR,PAUSE,'それとも・・・'
	DB	"How do I ask her what I want to ask her?"
	DB	NEXT
	DB	"Ruri, what am I to you? Your friend? ",PAUSE,"Your classmate?"
	DB	CR
	DB	PAUSE,"Just some guy who likes to lecture you?"
	DB	NEXT
	DB	"Or am I more...?"
	DB	NEXT
;	DB	'うかつなことは言えないな・・・'
	DB	"I can't say that...!"
	DB	FLG,F_COPYI,2,6
	DW	0000H


M9:		;話す　瑠璃
;	DB	'【瑠璃】：着いたわ。'
	DB	"Ruri:  We're here."
	DB	NEXT
;	DB	'・・・俺が答えに詰まってるうちに、白水さんの家に着いたらしい。'
	DB	"As I was still wrestling with what I wanted to say to"
	DB	CR
	DB	"her, we arrived at her house."
	DB	NEXT
;	DB	'【瑠璃】：入って。'
	DB	"Ruri:  Go on in."
	DB	NEXT
;	DB	'【%001】：おじゃまします。'
	DB	"%001:  Thanks."
	BAK_INIT "AB_20_2"
	DB	BUF,B_COPY01
	T_CG "CT05","C",0,15,1		;瑠璃立ちポーズ
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_OFF,1
	DB C_BLD,C_V_OFF,4
	DW	0000H

M10:		;聞く　瑠璃
;	DB	'【%001】：白水さんさ・・・なんか、変わったよな。'
	DB	"%001:  You've...changed in this past year."
	DB	NEXT
;	DB	'【瑠璃】：そう？・・・わからないわ。'
	DB	"Ruri:  Really? In what way?"
	DB	NEXT
;	DB	'【%001】：転校して来た頃は、誰ともしゃべろうとしなかっただろ？'
	DB	"%001:  When you first came to out school, you hardly spoke"
	DB	CR
	DB	"with anyone. Remember?"
	DB	NEXT
;	DB	'今は、話し掛ければちゃんと答えてくれるようになった。'
	DB	"%001:  Now you're much more friendly."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'【%001】：白水さん、学校は楽しい？'
	DB	"%001:  Ruri, do you like school?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・・・・・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'【%001】：悪ィ、転校するんだったな。'
	DB	"%001:  Oh, I'm sorry..... I forgot you were going to change"
	DB	CR
	DB	"schools again."
	DB C_BLD,C_N_ON,3,1
	EF_SET 101
	DW	0000H


M11:		;聞く　友達
;	DB	'【%001】：さっき、吉田と中野と何しゃべってたんだ？'
	DB	"%001:  What were you talking about with Meimi and Seia"
	DB	CR
	DB	"before?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・聞きたいの？'
	DB	"%001:  .....Do you want to know?"
	DB	NEXT
;	DB	'【%001】：・・・まあね。'
	DB	"%001:  Well, sure."
	DB	NEXT
;	DB	'【瑠璃】：冬休みに、一緒にスキー合宿に行かないかって・・・'
	DB	"Ruri:  They asked me if I wanted to go skiing with them."
	DB	NEXT
;	DB	'【瑠璃】：・・・でも、断わったわ。'
	DB	"Ruri:  I said no."
	DB	NEXT
;	DB	'【%001】：どうして？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・引っ越しの日と重なるから・・・'
	DB	"Ruri:  .............I'm moving the day they're going."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・そか。'
	DB	"%001:  ................Oh."
	DB C_BLD,C_N_ON,3,2
	EF_SET 102
	DW	0000H

M12:		;聞く　母親
;	DB	'【%001】：あのさ・・・白水さんのお母さんって、どんな人？',CR,'もし良かったら、話して欲しいんだけど・・・'
	DB	"%001:  What kind of person is your mother like? I'd like"
	DB	CR
	DB	"to meet her."
	DB	NEXT
	T_CG1 "CT05","C",0,15,1		;瑠璃立ちポーズ
;	DB	'【瑠璃】：どうして？'
	DB	"Ruri:  Why?"
	DB	NEXT
;	DB	'【%001】：・・・・・・こう言っちゃ何だけどさ、白水さんってお母さんに縛られ過ぎてない？'
	DB	"%001:  .....I was just wondering if she was one of those"
	DB	CR
	DB	"overprotective mothers."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .........."
	DB	NEXT
;	DB	'【%001】：うちのかーちゃんもさ、いい年して俺にベッタリで正直うっとおしいんだけど・・・'
	DB	"%001:  My mother treats me like a child sometimes, always"
	DB	CR
	DB	"trying to baby me whenever I'll let her..."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ....................."
	DB	NEXT
;	DB	'【%001】：だけど、かーちゃんは俺の自由意志は尊重してくれてる・・・と思う。'
	DB	"%001:  But my mother respects my right to choose my own"
	DB	CR
	DB	"path in life. That's a good thing."
	DB	NEXT
;	DB	'【%001】：白水さんは、本当にお母さんのところに帰りたいの？'
	DB	"%001:  Do you really want to go live with your mother?"
	DB	NEXT
;	DB	'【瑠璃】：そうよ。'
	DB	"Ruri:  Yes, I do."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・そか。'
	DB	"%001:  ...........I see."
	DB C_BLD,C_N_ON,3,3
	EF_SET 103
	DW	0000H

M13:		;渡す　プレゼント
;	DB	'【%001】：さっそくだけど・・・これ、受け取ってくれるかな。'
	DB	"%001:  Oh, here's the present. I hope you like it."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・これは・・・？'
	DB	"Ruri:  ..............What is it?"
	DB	NEXT
;	DB	'【%001】：開けてみてよ・・・結構、自信作なんだ。'
	DB	"%001:  Go ahead and open it. I have to admit, I like the"
	DB	CR
	DB	"way it came out."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・このブローチ、%001君が作ったの？'
	DB	"Ruri:  .........Did you make this brooch yourself?"
	DB	NEXT
;	DB	'【%001】：そ。・・・気に入ってくれたかな。'
	DB	"%001:  Yes. Do you like it?"
	DB	NEXT
	K_CG 'CT05','I',15,2
	;瑠璃泣き顔
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ..................."
	DB	NEXT
;	DB	'【%001】：あ・・・いや、気に入らなかったならごめん・・・'
	DB	"%001:  I'm sorry if you don't like it."
	DB	NEXT
;	DB	'白水さんは無言で首を振る。'
	DB	"Ruri just shakes her head silently."
	DB	NEXT
;	DB	'【瑠璃】：私・・・%001君にあげられる物が無いわ。'
	DB	"Ruri:  I........I don't have anything to give you in"
	DB	CR
	DB	"return."
	DB	NEXT
;	DB	'【瑠璃】：・・・だから・・・'
	DB	"Ruri:  So please...take this back."
	DB	NEXT
;	DB	'俺にブローチを返そうとする白水さんの手を、俺はそっと押し返した。'
	DB	"She moved to hand the brooch back to me, but I gently"
	DB	CR
	DB	"pushed her hand towards her."
	DB	NEXT
;	DB	'【%001】：別にお返しなんかいらねぇって。俺はただ、白水さんの喜ぶ顔が見たかっただけだから。'
	DB	"%001:  I don't need anything in return. I just want to"
	DB	CR
	DB	"see you happy."
	DB	NEXT
;	DB	'【%001】：だからさ・・・笑ってくれよ。'
	DB	"%001:  Smile for me. That's all I want."
	DB	NEXT
	K_CG 'CT05','K',15,3
	;瑠璃笑顔
;	DB	'【瑠璃】：・・・・・・・・・ありがとう・・・・・・'
	DB	"Ruri:  .....................Thank you, %001."
	DB	NEXT
;	DB	'【%001】：どう致しまして。'
	DB	"%001:  You're welcome, Ruri."
	DB C_BLD,C_V_OFF,3
	DB C_BLD,C_V_ON,4
	DW	0000H


M_EXIT:
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,4,255,101,102,103
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【%001】：白水さんは本当にそれでいいのか？'
	DB	"%001:  Is that really want you want?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .............."
	DB	NEXT
;	DB	'【%001】：そりゃ、たった一人のお母さんだから大事にするべきだけど・・・'
	DB	"%001:  I'm sure you love your mother and all, but..."
	DB	NEXT
;	DB	'【%001】：このままお母さんの言う通りに生きてて、それで満足なの？'
	DB	"%001:  Will you be happy, living life the way your mother"
	DB	CR
	DB	"tells you?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・私はあなたとは違うわ。'
	DB	"Ruri:  ......You and I are different."
	DB	NEXT
;	DB	'【瑠璃】：・・・私には、お母様と家以外、何も無いもの。'
	DB	"Ruri:  .....I don't have anything except for my mother"
	DB	CR
	DB	"and the family name."
	DB	NEXT
;	DB	'【%001】：・・・・・・そうかな・・・。'
	DB	"%001:  I wonder if that's really true."
	DB	NEXT
;	DB	'【%001】：白水さん、林間学校のことは覚えてるよな。'
	DB	"%001:  Do you remember what happened at camp?"
	DB	NEXT
;	DB	'【%001】：あの時、俺や誠、鈴子さんに新藤さんに美緒ちゃん、吉田に中野に亜希ちゃんに今日子先生、みんなが白水さんを必死になって捜したんだ。'
	DB	"%001:  When you disappeared, we looked everywhere for you."
	DB	CR
	DB	"All of us, Reiko, Kiyomi, Seia, Meimi, Aki, and of course"
	DB	CR
	DB	"Kyoko-sensei."
	DB	NEXT
;	DB	'【%001】：何でだと思う？'
	DB	"%001:  Why do you think we looked so hard to find you?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'【%001】：みんな白水さんが心配だったからだ。'
	DB	"%001:  Because we all were worried about you."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'【%001】：実の母親に比べれば取るに足らないかもしれないけどさ、',CR,'「他に何も無い」なんて言わないでくれよ。'
	DB	"%001:  I'm sure the worry we felt is nothing compared"
	DB	CR
	DB	"what your mother feels for you. Anyway, please don't"
	DB	CR
	DB	"pretend we don't exist."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'【%001】：・・・・・・悪ィな、外野が無責任なこと言って。'
	DB	"%001:  I'm sorry for lecturing you again..."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'【%001】：ただ・・・忘れないで欲しいんだ、俺達みんなが瑠璃さんの友達だってことを。'
	DB	"%001:  I just don't want you to forget...that we're all"
	DB	CR
	DB	"your friends."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'【%001】：・・・押し付けがましいかな。'
	DB	"%001:  Sorry for being so pushy."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............"
	DB	NEXT
;	DB	'【%001】：・・・・・・じゃ、帰るわ。'
	DB	"%001:  ..........Well, I'll go home now."
	DB	NEXT
;	DB	'【瑠璃】：・・・さよなら。'
	DB	"Ruri:  ........Sayonara."
	DB	NEXT
;	DB	'・・・部外者が何を言ったところで、白水さんを困らせるだけだ・・・'
	DB	"......I was stupid to say that. I'm just an outsider."
	DB	NEXT
;	DB	'俺は後ろ髪引かれる思いで、白水さんの家を後にした。'
	DB	"I started to walk away from her apartment."
	DB	NEXT
	B_O B_WIPE
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	".................................."
	DB	NEXT
;	DB	'【瑠璃】：・・・さよなら・・・'
	DB	"Ruri:  .......Sayonara."
	DB	NEXT
;	DB	'【瑠璃】：・・・ありがとう・・・%001君。'
	DB	"Ruri:  .........And thank you, %001."
	DB	NEXT
	DB G_FLG,G_COPYF,150,150
	DB	FLG,F_CALI,150,20
	DB G_FLG,G_COPYG,150,150
	DB G_FLG,G_COPYI,157,1
	DB	SINARIO,'CSA01.OVL',0
	DW	0000H


end
