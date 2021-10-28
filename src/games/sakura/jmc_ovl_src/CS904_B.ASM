;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　
;		清美の家

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7
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
CM3:	DW	VV3,	NN1,NN2,NN3,-1
CM4:	DW	VV4,	NN1,-1
CM5:	DW	VV5,	-1

;VV1:	DB	1,	'呼び鈴を押す',0
VV1:	DB	1,	'RING BELL',0
;VV2:	DB	2,	'待つ',0
VV2:	DB	2,	'WAIT',0
;VV3:	DB	3,	'見る',0
VV3:	DB	3,	'LOOK',0
;VV4:	DB	4,	'話す',0
VV4:	DB	4,	'TALK',0
;VV5:	DB	5,	'考える',0
VV5:	DB	5,	'THINK',0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	'KIYOMI',0
;NN2:	DB	2,	'部屋',0
NN2:	DB	2,	'ROOM',0
;NN3:	DB	3,	'テレビ',0
NN3:	DB	3,	'TELEVISION',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1,  -1,  1, M2		;呼び鈴を押す
S2:		DW	VV2,  -1,  2, M3		;待つ
S3:		DW	VV3, NN1,  3, M4, M5		;見る　清美
S4:		DW	VV3, NN2,  4, M6		;見る　部屋
S5:		DW	VV3, NN3,  5, M7, M8		;見る　テレビ
S6:		DW	VV4, NN1,  6, M9, M10, M11, M12		;話す　清美
S7:		DW	VV5,  -1,  7, M13		;考える


;イニシャルメッセージ
M1:
    DB	BGM,18
    BAK_INIT "AB_04_3"
    B_P1 B_SUDA
    ;	DB	'この角を曲がって・・・あ、ここか。'
    DB	"Turn left... Oh, here it is."
    DB	NEXT
    ;	DB	'え～と、確かに表札には『新藤』とある。'
    DB	"It says 'Shinfuji' right on the mailbox."
    DB	NEXT
    ;	DB	'・・・いかん、いざここに来たら緊張してきた。'
    DB	"Damn, I'm getting nervous."
    DB	NEXT
    ;	DB	'ええい、いつも学校で話している新藤さんじゃないか、いまさらなんで緊張するんだよ！'
    DB	"But it's just Kiyomi, the girl you see every day at school."
    DB	CR
    DB	"There's no reason to be nervous."
    DB	NEXT
    ;	DB	'・・・とにかく、いつまでもここにいてもらちがあかない。とりあえず、呼び鈴を・・・'
    DB	"Well, I can't stand out here all night. I'll better ring"
    DB	CR
    DB	"the bell."
    DB	NEXT
    ;	DB	'ピンポーーン'
    DB	"*DING DONG*"
    DB	NEXT
    ;	DB	'後は、新藤さんが出てきて、いつも通りに・・・'
    DB	"Kiyomi will come out, and it'll be just like we were in"
    DB	CR
    DB	"school..."
    DB	NEXT
    ;	DB	'・・・'
    DB	"........"
    DB	NEXT
    ;	DB	'・・・・・・'
    DB	"..."
    DB	NEXT
    ;	DB	'・・・・・・・・・'
    DB	".............."
    DB	NEXT
    ;	DB	'・・・・・・・・・・・・'
    DB	"........................................"
    DB	CR
    ;	DB	'・・・出てこないな・・・'
    DB	"She's not coming out."
    DB	NEXT
    ;	DB	'・・・聞こえてないのかな？いや、そんなはずはねーと思うけど。'
    DB	"Maybe she didn't hear? No, that doesn't seem possible."
    DB	NEXT
    ;	DB	'・・・もしかしたら、拒絶の意志表示とか？'
    DB	"Maybe she changed her mind about me coming over."
    DB	NEXT
    ;	DB	'・・・ま・・・まさか、な？'
    DB	"No, that's not possible, either."
    DB	NEXT
    ;	DB	'・・・も、一回押してみるか？でも、それってけっこー失礼なんじゃないか？'
    DB	"Hmm, should I ring the bell again?"
    DB	NEXT
    ;	DB	'・・・どうしよう？'
    DB	"What should I do?"
    DB	C_BLD,C_V_ON,3		;見る
    DB	C_BLD,C_V_ON,4		;話す
    DB	C_BLD,C_V_ON,5		;考える
    DW	0000H
    
M2:		;呼び鈴を押す
    ;	DB	'・・・やっぱ、呼び鈴を押してみよう。'
    DB	"I guess I'll ring the bell again."
    DB	NEXT
    ;	DB	'聞こえてなかったのかも知れないし、宴会で疲れて寝てんのかも知れない。'
    DB	"She might not have heard it. Or she might even be sleeping,"
    DB	CR
    DB	"tired out from the party."
    DB	NEXT
    ;	DB	'とにかく、も、一回・・・'
    DB	"Let's try it again..."
    DB	NEXT
    ;	DB	'がちゃっ'
    DB	"*kacha*"
    DB	NEXT
    DB	BUF,B_COPY01
    T_CG "CT02","C","R",15,1
    ;	DB	'【清美】：%001さん！？'
    DB	"Kiyomi:  %001?"
    DB	NEXT
    ;	DB	'呼び鈴を押そうとしたとき、勢いよくドアが開き新藤さんが姿を現した。'
    DB	"When I moved to ring the bell again, the door suddenly"
    DB	CR
    DB	"opened, and Kiyomi was standing there."
    DB	NEXT
    ;	DB	'【%001】：し、新藤さん！（いけね、びっくりして声がひっくり返ってしまった）'
    DB	"%001:  Kiyomi!"
    DB	NEXT
    ;	DB	'【清美】：も、申し訳ございません、さあ、%001さん、中へどうぞ・・・'
    DB	"Kiyomi:  I'm sorry for frightening you. Please come in."
    DB	NEXT
    ;	DB	'【%001】：あ、ああ、おじゃまします。'
    DB	"%001:  Okay, thanks."
    DB	NEXT
    ;	DB	'・・・・・・なんか、すごい汗だね？どうしたの？'
    DB	"%001:  You're awfully sweaty. What's wrong?"
    DB	NEXT
    ;	DB	'【清美】：え？あ、あの、なんでもございませんわ。ほほほほほ・・・'
    DB	"Kiyomi:  Mm? Oh, it's nothing. Hohohoho!"
    DB	NEXT
    ;	DB	'【%001】：あ・・・そう？・・・・・・ま、いっか。'
    DB	"%001:  Oh, okay."
    BAK_INIT 'AB_34_2'
    DB BUF,B_COPY01
    T_CG "CT02","C",0,15,2
    DB	C_BLD,C_V_ON,1	;呼び鈴を押す
    DB	C_BLD,C_V_ON,2	;待つ
    DB	C_BLD,C_V_OFF,3		;見る
    DB	C_BLD,C_V_OFF,4		;話す
    DB	C_BLD,C_V_OFF,5		;考える
    DB C_BLD,C_N_ON,3,3
    DW	0000H
    
M3:		;待つ
    ;	DB	'・・・やっぱり、待とう。'
    DB	"I guess I'll wait."
    DB	NEXT
    ;	DB	'ちゃんと聞こえているはずだ、きっと。'
    DB	"She must have heard me the first time."
    DB	NEXT
    ;	DB	'・・・'
    DB	".........."
    DB	NEXT
    ;	DB	'・・・・・・'
    DB	"........................."
    DB	NEXT
    ;	DB	'・・・不安になってきた・・・'
    DB	"What's happening?"
    DB	NEXT
    ;	DB	'がちゃっ！'
    DB	"*kacha*"
    DB	NEXT
    DB	BUF,B_COPY01
    T_CG "CT02","C","R",15,1
    ;	DB	'【清美】：しっ、%001さん！？'
    DB	"Kiyomi:  %001?"
    DB	NEXT
    ;	DB	'【%001】：や、やあ、新藤さん。'
    DB	"%001:  Oh, hi, Kiyomi."
    DB	NEXT
    ;	DB	'・・・・・・どーしたの？肩で息して？'
    DB	"%001:  What's wrong? Why are you out of breath?"
    DB	NEXT
    ;	DB	'【清美】：え？あ、いえ、別になんでもないですわ、ほほほほほ！'
    DB	"Kiyomi:  Oh, it's nothing. Hohohoho!"
    DB	NEXT
    ;	DB	'【%001】：そう？・・・ま、いっか。'
    DB	"%001:  Okay."
    DB	NEXT
    ;	DB	'【清美】：さ、%001さん、どうぞお上がり下さい。'
    DB	"Kiyomi:  Please come in."
    DB	NEXT
    ;	DB	'【%001】：あ、お、おじゃましま～す。'
    DB	"%001:  Oh, thanks."
    BAK_INIT 'AB_34_2'
    DB BUF,B_COPY01
    T_CG "CT02","C",0,15,2
    DB	C_BLD,C_V_ON,1	;呼び鈴を押す
    DB	C_BLD,C_V_ON,2	;待つ
    DB	C_BLD,C_V_OFF,3		;見る
    DB	C_BLD,C_V_OFF,4		;話す
    DB	C_BLD,C_V_OFF,5		;考える
    DB C_BLD,C_N_ON,3,3
    DW	0000H
    
M4:		;見る　清美
    ;	DB	'肩で息してるぞ。'
    DB	"She seems out of breath."
    DB	NEXT
    ;	DB	'・・・一体なにしてたんだろう。'
    DB	"What's going on?"
    DB	FLG,F_COPYI,3,1
    DW	0000H
    
M5:		;見る　清美
    ;	DB	'心なし、落ち着かないように見えるのは・・・'
    DB	"She seems nervous."
    DB	NEXT
    ;	DB	'・・・俺が落ち着かないからだろうな。'
    DB	"Maybe it's because I'm nervous?"
    DW	0000H
    
M6:		;見る　部屋
    ;	DB	'清美さんの部屋だ。'
    DB	"This is Kiyomi's room."
    DB	NEXT
    ;	DB	'全体にシンプルで、機能的にまとまっているあたりがいかにも新藤さんらしい。'
    DB	"The design is very simple and functional, just like"
    DB	CR
    DB	"Kiyomi herself."
    DB	NEXT
    ;	DB	'でも、本棚の上にぬいぐるみが乗っていたりして、そこいら辺に愛嬌というか・・・女の子らしさがある。'
    DB	"But there are stuffed animals and other cute things, too."
    DB	CR
    DB	"It's all very cute."
    DB	NEXT
    ;	DB	'・・・その代わり・・・と言ったらなんだけど、本棚に収まっている本はいかにも難しそうな物ばかりだ。'
    DB	"The books all seem to be really difficult."
    DB	NEXT
    ;	DB	'さすがはクラスで成績１・２を争うだけはある・・・あ、恋愛小説みっけ。'
    DB	"Well, that's to be expected. Kiyomi is one of the top"
    DB	CR
    DB	"students in my class."
    DB	NEXT
    DB	"Oh, there's a romance novel."
    DB	NEXT
    ;	DB	'【清美】：・・・ど、どうなさいました？%001さん。'
    DB	"Kiyomi:  What's the matter?"
    DB	NEXT
    ;	DB	'【%001】：あ・・・ごめん。'
    DB	"%001:  Oh, nothing."
    DW	0000H
    
M7:		;見る　テレビ
    T_CG "CT02","C",0,15,2
    ;	DB	'新藤さんの作ってくれた料理をあらかた片づけ、俺たちは並んでテレビを眺めている。'
    DB	"Kiyomi had taken away the dishes, and now we were watching"
    DB	CR
    DB	"television together."
    DB	NEXT
    ;	DB	'・・・ブラウン管の中で繰り広げられているのは、力一杯恋愛物だ。'
    DB	"It was a mushy love story."
    DB	NEXT
    ;	DB	'正直言って、俺はこの手のドラマは苦手だ。'
    DB	"To tell you the truth, I don't like dramas like this."
    DB	NEXT
    ;	DB	'けどまあ、新藤さんは黙ってみている訳だし、人ン家に来てだだこねる程、分別がない訳じゃない。'
    DB	"But Kiyomi seems to be interested in it, and it is her"
    DB	CR
    DB	"house."
    DB	NEXT
    ;	DB	'【清美】：このお話・・・すてきですわね・・・'
    DB	"Kiyomi:  I love this story."
    DB	NEXT
    ;	DB	'【%001】：・・・ああ、そーだね。'
    DB	"%001:  Ah, me too."
    DB	NEXT
    ;	DB	'いかん、これではどう聞いても『気のない返事』だ'
    DB	"Opps! Now I'm a liar!"
    DB	NEXT
    ;	DB	'【清美】：・・・・・・'
    DB	"Kiyomi:  .........."
    DB	NEXT
    ;	DB	'どうやら、新藤さんはテレビに夢中で俺の返事など気にしてはいないらしい'
    DB	"She's so interested in the TV show she didn't even hear"
    DB	CR
    DB	"what I said."
    DB	NEXT
    ;	DB	'・・・・・・・・・・・・'
    DB	"................................."
    DB	FLG,F_COPYI,5,1
    DW	0000H
    
M8:		;見る　テレビ
    K_CG "CT02","R",15,1
    ;	DB	'・・・・・・・・・・・・'
    DB	"................................."
    DB	NEXT
    ;	DB	'俺達が見ている目の前でそりゃあそうだ、ドラマは見ている俺達のほうが恥ずかしくなるようなハッピーエンドを迎えた。'
    DB	"The show we're watching is drawing to a romantic happy"
    DB	CR
    DB	"ending."
    DB	NEXT
    ;	DB	'なんだかんだ言っても結構見入っていた俺は、今、新藤さんと２人きりだと言うことに思いが巡り、１人赤面していた。'
    DB	"It's making me think of Kiyomi in ways that are more than"
    DB	CR
    DB	"a little dangerous..."
    DB	NEXT
    ;	DB	'ちらりと視線を横に泳がすと、新藤さんも真っ赤な顔をして、しかし、こちらを向いていた。'
    DB	"I look and see that Kiyomi's face is as red as mine."
    DB	NEXT
    DB	"Kiyomi slowly turns to face me."
    DB	NEXT
    ;	DB	'【清美】：・・・%001さん・・・'
    DB	"Kiyomi:  ........%001."
    DB	NEXT
    ;	DB	'【%001】：しっ、新藤さん・・・'
    DB	"%001:  ...........Kiyomi."
    DB	NEXT
    ;	DB	'・・・・・・・・・・・・'
    DB	".........................................."
    DB	NEXT
    ;	DB	'俺たちは・・・どちらが先に、と言うこともなく身体を寄せあっていた。'
    DB	"We both slowly move towards each other."
    DB	NEXT
    ;	DB	'そうっと、新藤さんの肩に手をかける。新藤さんはますます顔を赤くして・・・そして、顔を俺の方に向けたまま、ゆっくりと瞳を閉じた。'
    DB	"I put my hands on her shoulders."
    DB	NEXT
    ;	DB	'緊張している俺の腕に伝わってくる震えは、俺のものか、それとも新藤さんのものか。'
    DB	"I wonder if she can feel my hands shaking."
    DB	NEXT
    ;	DB	'・・・ごくり、と、唾を一つ飲み込むと、俺はゆっくりと新藤さんを抱き寄せた。'
    DB	"Slowly, I bring Kiyomi near me."
    DB	NEXT
    ;	DB	'そして、俺たちは、いま・・・'
    DB	"And then......."
    DB	NEXT
    ;	DB	'【慎治】：清美お姉ちゃん、ただいま～・・・'
    DB	"Shinji:  Kiyomi! I'm home!"
    DB	NEXT
    ;	DB	'【清美】：！？'
    DB	"Kiyomi:  !!"
    DB	NEXT
    ;	DB	'【%001】：！？'
    DB	"%001:  !!"
    DB	NEXT
    ;	DB	'なんだ？なんだなんだなんだァ？'
    DB	"What the hell??"
    DB	NEXT
    ;	DB	'俺と新藤さんはなにがなんだかよく解んないうちにお互いに素晴らしい速度で飛び離れた。'
    DB	"With incredible speed, Kiyomi and I move away from each"
    DB	CR
    DB	"other just as Shinji enters the room."
    DB	NEXT
    TU_CG "CT11","C","K",35,8
    T_CG "CT02","C",0,15,2
    DB ANI,A_ON,8
    ;	DB	'【慎治】：ただいま、清美お姉ちゃ・・・あ、%001お兄ちゃん'
    DB	"Shinji:  Hi, Kiyomi. Oh, hello, %001."
    DB	NEXT
    ;	DB	'【%001】：よ、よお、慎治君。'
    DB	"%001:  Hi, Shinji."
    DB	NEXT
    ;	DB	'【清美】：は、早かったですわね、慎治・・・'
    DB	"Kiyomi:  Y- You're home early."
    DB	NEXT
    ;	DB	'【慎治】：うん。'
    DB	"Shinji:  Yeah."
    DB	NEXT
    ;	DB	'【%001】：あ、そだ。慎治君、これ、クリスマスプレゼント。'
    DB	"%001:  Oh, Shinji, I forgot. This is a Christmas present"
    DB	CR
    DB	"for you."
    DB	NEXT
    ;	DB	'【慎治】：・・・僕に・・・？・・・ありがとう、%001お兄ちゃん！'
    DB	"Shinji:  For me? Gee, thanks!"
    DB	NEXT
    ;	DB	'【清美】：まあ、慎治の分までご用意していたのですか？'
    DB	"Kiyomi:  You're so nice, %001, to bring something for him."
    DB	NEXT
    ;	DB	'【%001】：まあね。良かったよ、直接渡せて。'
    DB	"%001:  Oh, it's nothing. I'm glad I was able to give it"
    DB	CR
    DB	"to him myself."
    DB	NEXT
    ;	DB	'【慎治】：ありがとう、僕、これ、宝物にするよ！'
    DB	"Shinji:  Thanks. I'll keep it forever."
    DB	NEXT
    ;	DB	'【清美】：まあ、慎治ったら。'
    DB	"Kiyomi:  You silly boy."
    DB	NEXT
    ;	DB	'【%001】：んじゃあ、そろそろ遅いし、俺、帰るわ。'
    DB	"%001:  Well, I guess I should be going."
    DB	NEXT
    ;	DB	'【慎治】：え・・・もう・・・？・・・もっと早く帰ってくれば良かったな・・・。'
    DB	"Shinji:  Already? I wish I'd come home earlier."
    DB	NEXT
    ;	DB	'【%001】：ははは、じゃ、今度キャッチボールでもするか？'
    DB	"%001:  Well, we'll play catch later."
    DB	NEXT
    ;	DB	'【慎治】：え・・・？う、うん！約束だよ、%001お兄ちゃん'
    DB	"Shinji:  Okay, thanks!"
    DB	NEXT
    ;	DB	'【%001】：ああ、構わないよ。じゃあな、慎治君。'
    DB	"%001:  Well, I'll see you later, Shinji."
    DB	NEXT
    ;	DB	'【慎治】：うん、さよなら、%001お兄ちゃん'
    DB	"Shinji:  Thanks, %001."
    DB	NEXT
    ;	DB	'【清美】：では、わたくしは、そこまでお送りいたしますわ。'
    DB	"Kiyomi:  I'll walk you out."
    DB	NEXT
    ;	DB	'【%001】：い、いいよ、新藤さん。もう遅いから。'
    DB	"%001:  No, it's okay. It's late."
    DB	NEXT
    ;	DB	'【清美】：ですが・・・'
    DB	"Kiyomi:  Yes, but..."
    DB	NEXT
    ;	DB	'【%001】：だ～いじょうぶだって。気持ちだけもらっとくよ。'
    DB	"%001:  I'm fine by myself."
    DB	NEXT
    ;	DB	'【%001】：じゃ！'
    DB	"%001:  Well, bye!"
    DB	NEXT
    BAK_INIT "AB_04_3"
    B_P1 B_SUDA
    ;	DB	'・・・・・・・・・・・・'
    DB	"..............................."
    DB	NEXT
    ;	DB	'こうして、照れ隠しにプレゼントを渡すことで急場をしのぐと、自分の家への道をトボトボと歩いた。'
    DB	"Sweating from my embarrassment, I left Kiyomi's house and"
    DB	CR
    DB	"headed for home."
    	DB	NEXT
    ;	DB	'・・・・・・はあぁぁぁ。安心したような、惜しかったような・・・'
    	DB	"That wasn't good."
    DB	NEXT
    DB G_FLG,G_COPYF,120,120
    DB	FLG,F_CALI,120,20
    DB G_FLG,G_COPYG,120,120
    DB G_FLG,G_COPYI,127,1
    B_O B_WIPE
    DB	SINARIO,'CSA01.OVL',0
    DW	0000H
    
M9:		;話す　清美
    ;	DB	'【清美】：あ、%001さん、少々お待ち下さいね。お茶をお持ちしますから。'
    DB	"Kiyomi:  Wait a moment, and I'll pour us some tea."
    DB	NEXT
    B_P1 B_YOKO
    ;	DB	'【%001】：あ、いいよ、気ぃ使わなくても・・・'
    DB	"%001:  Oh, you don't have to..."
    DB	NEXT
    ;	DB	'・・・・・・もういねぇし・・・・・・'
    DB	"Too late. She's gone."
    DB	NEXT
    ;	DB	'・・・そんな、お客さんって訳じゃないんだから・・・'
    DB	"I mean, I'm her friend, not a guest..."
    DB	NEXT
    ;	DB	'・・・って、俺、今はお客さんか・・・'
    DB	"........Hmm, I guess I am a guest."
    DB	NEXT
    ;	DB	'・・・・・・・・・'
    DB	"..........................."
    DB	NEXT
    T_CG 'CT02','C','K',15,3
    ;	DB	'【清美】：お待たせしました～。'
    DB	"Kiyomi:  Here you are."
    DB	NEXT
    ;	DB	'【%001】：あ、ありがと、新藤さん。'
    DB	"%001:  Thanks."
    DB	NEXT
    ;	DB	'【清美】：こちら、お口に合いますかどうか・・・'
    DB	"Kiyomi:  I hope you like it..."
    DB	NEXT
    ;	DB	'そう言って差し出されたのはちょうど良い大きさにスライスされた羊羹。'
    DB	"She handed me a cup of green tea and a slice of castella"
    DB	CR
    DB	"cake."
    DB	NEXT
    ;	DB	'お茶には羊羹・・・日本の心だよなつっこみ無用。'
    DB	"Green tea and castella. This is very traditional, even"
    DB	CR
    DB	"though castella originally comes from Holland."
    DB	NEXT
    ;	DB	'【%001】：じゃ、いただくよ。'
    DB	"%001:  It looks good."
    DB	NEXT
    ;	DB	'ずずっ。'
    DB	"*sip sip*"
    DB	NEXT
    ;	DB	'【%001】：あっ・・・！'
    DB	"%001:  Mmm...!"
    DB	NEXT
    ;	DB	'【清美】：ど、どうなさいました？'
    DB	"Kiyomi:  Is anything wrong?"
    DB	NEXT
    ;	DB	'【%001】：これ、新藤さんが入れたんだよね？'
    DB	"%001:  Did you make this tea?"
    DB	NEXT
    ;	DB	'【清美】：え、ええ・・・慎治は出かけていますし・・・'
    DB	"Kiyomi:  Yes. Shinji is out right now, and..."
    DB	NEXT
    ;	DB	'【%001】：・・・いや、ウチのかーちゃんの入れるお茶より何倍もうまかったから・・・'
    DB	"%001:  It's really good. I mean that."
    DB	NEXT
    ;	DB	'【清美】：え？・・・ほ、本当ですか？'
    DB	"Kiyomi:  Really?"
    DB	NEXT
    ;	DB	'【%001】：・・・ウチのかーちゃんと比べちゃ失礼だな。'
    DB	"%001:  Yes. Better than what my mother makes, even."
    DB	NEXT
    ;	DB	'【清美】：あ、ありがとうございます・・・わたくし、良いお嫁さんになれますでしょうか？'
    DB	"Kiyomi:  Thank you! I wonder if I'll be a good wife"
    DB	CR
    DB	"someday..."
    DB	NEXT
    ;	DB	'【%001】：なれるなれる。日本一のお嫁さんになれるよ。'
    DB	"%001:  I guarantee it. You'll be the best wife in all"
    DB	CR
    DB	"of Japan."
    DB	NEXT
    ;	DB	'【清美】：まあ・・・！ぽっ'
    DB	"Kiyomi:  Thank you... *blush*"
    DB	FLG,F_COPYI,6,1
    DW	0000H
    
M10:		;話す　清美
    ;	DB	'【清美】：あ・・・！そうでしたわ！'
    DB	"Kiyomi:  Oh, I almost forgot!"
    DB	NEXT
    ;	DB	'【%001】：え？なに？'
    DB	"%001:  What?"
    DB	NEXT
    ;	DB	'【清美】：%001さん、これはわたくしからのクリスマスプレゼントです。'
    DB	"Kiyomi:  This is my Christmas present to you. Will you"
    DB	CR
    ;	DB	'受け取っていただけますか？'
    DB	"accept it?"
    DB	NEXT
    ;	DB	'【%001】：あ、もちろん。なんだろ・・・あ！マフラーだ！'
    DB	"%001:  Of course. Let's see what it is. Oh, it's a scarf!"
    DB	CR
    ;	DB	'もしかして、手編みとか？'
    DB	"Did you knit it yourself?"
    DB	NEXT
    ;	DB	'【清美】：はい・・・。'
    DB	"Kiyomi:  Yes..."
    DB	NEXT
    ;	DB	'【%001】：ほええぇ～。ありがたく使わせてもらうよ。'
    DB	"%001:  Wow. This is really great. Thanks."
    DB	NEXT
    ;	DB	'【%001】：・・・で、これは俺からのクリスマスプレゼント。'
    DB	"%001:  This is something I made for you."
    DB	NEXT
    ;	DB	'【清美】：まあ！開けてみてもよろしいでしょうか？'
    DB	"Kiyomi:  Oh, can I open it?"
    DB	NEXT
    ;	DB	'【%001】：どうぞどうぞ。'
    DB	"%001:  Sure."
    DB	NEXT
    ;	DB	'【清美】：・・・まあ！これは・・・'
    DB	"Kiyomi:  Let's see..."
    DB	NEXT
    ;	DB	'【%001】：ど、どう？気に入ってもらえたかな？'
    DB	"%001:  Do you like it?"
    DB	NEXT
    ;	DB	'【清美】：はいっ！わたくし、これを一生の宝にしますわ！'
    DB	"Kiyomi:  Yes! I like it very much! I'll treasure it"
    DB	CR
    DB	"always!"
    DB	NEXT
    ;	DB	'新藤さんは俺の手作りのブローチを両手で包むように抱きしめた。'
    DB	"Kiyomi held the broch I made for her to her heart."
    DB	NEXT
    ;	DB	'【%001】：そう？そんなに喜んでもらえると、なんだかこっちまでうれしくなってくるよ。ありがと。'
    DB	"%001:  I'm glad you like it. That makes me happy."
    DB	FLG,F_COPYI,6,2
    DW	0000H
    
M11:		;話す　清美
    ;	DB	'【清美】：お礼、と申し上げてはなんですが、%001さん、これからわたくしとクリスマスパーティーの２次会をいたしませんか？'
    DB	"Kiyomi:  In return for this present, do you want to have"
    DB	CR
    DB	"a private Christmas party here, right here with me?"
    DB	NEXT
    ;	DB	'【%001】：２次会？'
    DB	"%001:  A private party?"
    DB	NEXT
    ;	DB	'【清美】：はい。・・・お嫌でしたら、結構ですが・・・'
    DB	"Kiyomi:  If you don't want to, it's okay..."
    DB	NEXT
    ;	DB	'【%001】：いや、俺は構わないけど？'
    DB	"%001:  No, let's have a party."
    DB	NEXT
    ;	DB	'【清美】：そうですか！では、こちらへおいで下さい！'
    DB	"Kiyomi:  Okay! Please come over here."
    DB	NEXT
    ;	DB	'【%001】：え？な、なんで？'
    DB	"%001:  Why?"
    DB	NEXT
    ;	DB	'【清美】：実は、用意はほとんどできていて・・・ああ、もし断られたらどうしましょうかと思っていましたわ。'
    DB	"Kiyomi:  I've been getting ready for the party for a"
    DB	CR
    DB	"while. I was worried you'd be busy."
    DB	NEXT
    ;	DB	'・・・・・・・・・・・・・・・・・・'
    DB	".............................."
    DB	NEXT
    ;	DB	'【%001】：・・・うん、これうまいなぁ。'
    DB	"%001:  .....This is really delicious."
    DB	NEXT
    ;	DB	'【清美】：まあ！本当ですか！？'
    DB	"Kiyomi:  Really? Thank you!"
    DB	NEXT
    ;	DB	'【%001】：ホントホント、さすが慎治君のお姉さんだ。'
    DB	"%001:  It's good. You are Shinji's older sister, after all."
    DB	NEXT
    ;	DB	'【清美】：ああ、良かった・・・特訓の甲斐があったというものですわ'
    DB	"Kiyomi:  I'm just glad I could do something for myself"
    DB	CR
    DB	"without relying on him all the time."
    DB	NEXT
    ;	DB	'【%001】：え？なに？'
    	DB	"%001:  Huh? What?"
    	DB	NEXT
    ;	DB	'【清美】：い、いえ、こちらの事ですわ。'
    	DB	"Kiyomi:  Oh, nothing."
    	DB	NEXT
    ;	DB	'【清美】：こ、こちらなど、いかがですか？'
    DB	"Kiyomi:  How do you like this one?"
    DB	NEXT
    ;	DB	'【%001】：ん～、どれどれ・・・うん、うまい。'
    DB	"%001:  Let's see. Mm, it's good, too."
    DB	NEXT
    ;	DB	'【清美】：どんどん召し上がって下さいね。'
    DB	"Kiyomi:  Please eat as much as you like."
    DB	NEXT
    ;	DB	'・・・こうして、俺と新藤さんの２次会は、楽しいままに時間だけが過ぎ去っていった。'
    DB	"In this way, Kiyomi and I enjoyed our private Christmas"
    DB	CR
    DB	"Party together..."
    DB	FLG,F_COPYI,6,3
    DW	0000H
    
M12:		;話す　清美
    ;	DB	'【%001】：げっ、もう９時だ。俺、そろそろお暇するよ。'
    DB	"%001:  It's nine o'clock! I guess I should get on home."
    DB	NEXT
    K_CG 'CT02','I',15,4
    ;	DB	'【清美】：え・・・？でも、まだ少し早いのでは・・・？'
    DB	"Kiyomi:  Don't you think it's still too early to go home?"
    DB	NEXT
    ;	DB	'【%001】：・・・たぶん・・・あんまり早くないと思うぞ？'
    DB	"%001:  .....Mmm, it's late. I should be getting back."
    DB	NEXT
    ;	DB	'【清美】：・・・ですが・・・'
    DB	"Kiyomi:  But I wanted you to stay until my father came home."
    DB	CR
    DB	"So I could introduce them to you."
    DB	NEXT
    ;	DB	'【%001】：え・・・？でも・・・'
    DB	"%001:  Hmm..."
    DB	NEXT
    ;	DB	'【清美】：・・・ダメでしょうか？'
    DB	"Kiyomi:  ......Please?"
    DB	NEXT
    ;	DB	'【%001】・・・・・・・・・'
    DB	"%001:  ..........",PAUSE,"Okay. I'll stay a while longer."
    DB	NEXT
    K_CG "CT02","K",15,3
    ;	DB	'【清美】：あ、ありがとうございます！'
    DB	"Kiyomi:  Oh, thank you!"
    DB C_BLD,C_N_ON,3,1
    DB C_BLD,C_N_ON,3,2
    DB C_BLD,C_N_OFF,3,3
    DB C_BLD,C_V_ON,4
    DW	0000H
    
M13:		;考える
    ;	DB	'なんだ、妙に落ち着かないな。'
    DB	"I'm having trouble relaxing here for some reason."
    DB	NEXT
    ;	DB	'いつもの新藤さんだろ？なにを緊張してるんだ？俺。'
    DB	"This is just Kiyomi. There's no reason to be nervous, right?"
    DW	0000H


end
