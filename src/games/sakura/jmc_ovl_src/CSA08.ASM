;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０８
;		旅館の部屋

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7, S8
MSGTBL:
        DW	M1
COMTBL:
        DW	CM1, CM2, CM3, CM4, CM5, CM6, CM7, CM8
VNTBL:
        DW	V_FNAME,N_FNAME
ENDTBL:

        INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
        INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN1,-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1
CM6:	DW	VV6,	-1
CM7:	DW	VV7,	-1
CM8:	DW	VV8,	-1

;VV1:	DB	1,	'くつろぐ',0
VV1:	DB	1,	'RELAX',0
;VV2:	DB	2,	'見る',0
VV2:	DB	2,	'LOOK',0
;VV3:	DB	3,	'話す',0
VV3:	DB	3,	'TALK',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO FOR IT',0
;VV6:	DB	6,	'行かない',0
VV6:	DB	6,	"DON'T GO",0
;VV7:	DB	7,	'止める',0
VV7:	DB	7,	'STOP HIM',0
;VV8:	DB	8,	'止めない',0
VV8:	DB	8,	"DON'T STOP HIM",0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	'MAKOTO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1,  -1,  1, M2					;くつろぐ
S2:		DW	VV2, NN1,  2, M3					;見る　誠
S3:		DW	VV3, NN1,  3, M4, M5, M6, M7		;話す　誠
S4:		DW	VV4,  -1,  4, M8, M9, M10			;考える
S5:		DW	VV5,  -1,  5, M11					;行く
S6:		DW	VV6,  -1,  6, M12, M13				;行かない
S7:		DW	VV7,  -1,  7, M14					;止める
S8:		DW	VV8,  -1,  8, M15				;止めない


;イニシャルメッセージ
M1:
        DB	BGM,26
        BAK_INIT 'AB_39'
        DB	BUF,B_COPY01
        B_P1 B_SUDA
        ;	DB	'俺達は旅館「はたご」に到着した後、宿帳に記入を済ませて、それぞれの部屋割りを決めた。'
        DB	"After arriving at the inn, we checked in then went off"
        DB	CR
        DB	"to our rooms."
        DB	NEXT
        ;	DB	'晩メシも食い終わって、俺は一人で部屋でくつろいでるところだ。'
        DB	"After dinner, I relaxed in my room."
        DB C_BLD,C_V_ON,2	;
        DB C_BLD,C_V_ON,3	;話す
        DB C_BLD,C_V_ON,5	;
        DB C_BLD,C_V_ON,6	;
        DB C_BLD,C_V_ON,7	;
        DB C_BLD,C_V_ON,8	;
        DW	0000H
        
M2:		;くつろぐ
        ;	DB	'【%001】：ふぃ～～～っ・・・'
        DB	"%001:  *yawn*"
        DB	NEXT
        ;	DB	'【%001】：静かだねぇ・・・'
        DB	"%001:  It's really quiet..."
        DW	0000H
        
M3:		;見る　誠
        ;	DB	'全身をわななかせて、何やら力説してる。'
        DB	"He's jumping around, trying to tell me something."
        DW	0000H
        
M4:		;話す　誠
        ;	DB	'【誠】：ここの温泉は・・・ここの温泉はよぉ・・・'
        DB	"Makoto:  %001, the hot springs here are..."
        DB	NEXT
        ;	DB	'【%001】：猿でも出るのか？'
        DB	"%001:  What? Full of monkeys?"
        DB	NEXT
        ;	DB	'【誠】：そう！妙に人間臭い顔した猿がこう肩までつかって、'
        DB	"Makoto:  Yes! Full of beautiful monkeys that look like"
        DB	CR
        DB	"women!"
        DB	PAUSE
        ;	DB	'・・・ってそうじゃねえって！'
        DB	" No! That's not what I mean!"
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M5:		;話す　誠
        ;	DB	'【誠】：ここの温泉はよぉ・・・'
        DB	"Makoto:  The hot springs here have..."
        DB	PAUSE
        ;	DB	'・・・・・・混浴じゃないんだよ！！'
        DB	"........separate areas for"
        DB	CR
        DB	"men and women!"
        DB	NEXT
        ;	DB	'【%001】：そか。'
        DB	"%001:  Really?"
        DB	NEXT
        ;	DB	'【誠】：そか・・・って、お前悔しくないのか！？'
        DB	"Makoto:  'Really?' That's all you can say? Did you hear"
        DB	CR
        DB	"what I said?"
        DB	NEXT
        DB	"Makoto:  We can't get naked with the women in the hot"
        DB	CR
        DB	"springs tonight! "
        DB	NEXT
        ;	DB	'【%001】：今時あんまり聞かねーからな・・・最初っから期待してなかったし。'
        DB	"%001:  I'm not surprised. Most places have stopped"
        DB	CR
        DB	"letting men and women bathe together these days. I didn't"
        DB	CR
        DB	"expect this place to be any different."
        DB	NEXT
        ;	DB	'【誠】：温泉旅行ってのはよぉ、ハダカとハダカのおつきあいでより親密になろうってのが最大の目的だろぉ！？'
        DB	"Makoto:  But this is Japan! Men and women are supposed"
        DB	CR
        DB	"to bathe together! It's our national heritage!"
        DB	NEXT
        ;	DB	'【誠】：%001、お前オレとハダカとハダカのおつきあいでより親密になって楽しいか！？'
        DB	"Makoto:  ...Are you happy to be naked with me?"
        DB	NEXT
        ;	DB	'【%001】：・・・あんまり考えたくねーな・・・'
        DB	"%001:  Not really."
        DB	NEXT
        ;	DB	'【誠】：そーだろ？やっぱり鈴子さんとか、今日子先生とかと親密になりたいよな！'
        DB	"Makoto:  See?  You'd rather be naked with Reiko or Kyoko-"
        DB	CR
        DB	"sensei, wouldn't you?"
        DB	NEXT
        ;	DB	'【%001】：まぁな・・・'
        DB	"%001:  Well..."
        DB	NEXT
        ;	DB	'（今日子先生とは・・・これ以上ないほど親密になったけど・・・）'
        DB	"(Actually, I've seen Kyoko-sensei, more than he'll ever"
        DB	CR
        DB	"know...)"
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M6:		;話す　誠
        K_CG 'CT14','I',20,2
        ;	DB	'【誠】：ちくしょう！俺は何のためにこんな山の中まで！'
        DB	"Makoto:  Why did we come all this way?"
        DB	NEXT
        ;	DB	'【誠】：うおおおおおおおおおおおおおおおおおおん！'
        DB	"Makoto:  Oh, the humanity!"
        DB	NEXT
        ;	DB	'誠は畳に突っ伏すと、男泣きに泣き出した。'
        DB	"Makoto lays down and starts crying."
        DB	NEXT
        ;	DB	'【%001】：誠・・・お前、そこまで混浴に命賭けてたのか・・'
        DB	"%001:  Makoto, I can see how much it means to you."
        DB	FLG,F_COPYI,3,3
        DW	0000H
        
M7:		;話す　誠
        ;	DB	'【%001】：誠・・・お前の気持ち、分かるような気がするぜ。'
        DB	"%001:  Believe me, I understand how you feel..."
        DB	NEXT
        ;	DB	'【誠】：ホントか%001！？'
        DB	"Makoto:  You do?"
        DB	NEXT
        ;	DB	'【%001】：俺だって・・・男だからな。'
        DB	"%001:  Sure. I'm a man, just like you are."
        DB	NEXT
        ;	DB	'【誠】：%001・・・'
        DB	"Makoto:  %001..."
        DB	NEXT
        T_CG 'CT14','C',0,20,3
        ;	DB	'【誠】：なら話は早い。行くぞ、%001。'
        DB	"Makoto:  Then there's still way! Let's go!"
        DB	NEXT
        ;	DB	'【%001】：どこに？'
        DB	"%001:  Go where?"
        DB	NEXT
        ;	DB	'【誠】：決まってんだろ、のぞきだよ、の・ぞ・き！'
        DB	"Makoto:  Where else? We're going to peek at those women!"
        DB	NEXT
        ;	DB	'【%001】：おまっ・・・それはっ・・・！'
        DB	"%001:  What? Wait!"
        DB	NEXT
        K_CG 'CT14','K',20,4
        ;	DB	'【誠】：お前だって見たいだろ？'
        DB	"Makoto:  You want to see them naked, too, don't you?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・でも・・・'
        DB	"%001:  ..........Yes, but..."
        DB	NEXT
        ;	DB	'【誠】：今、６人揃って露天風呂の方に行ったのを見掛けたんだよ。これは千載一遇のチャンスだぜ！'
        DB	"Makoto:  %001, there are six beautiful women just waiting "
        DB	CR
        DB	"for us to go look at them. You're never going to get "
        DB	CR
        DB	"this chance again!"
        DB C_BLD,C_V_ON,2
        DB C_BLD,C_V_ON,3
        DB C_BLD,C_V_OFF,5
        DB C_BLD,C_V_OFF,6
        DW	0000H
        
M8:		;考える
        ;	DB	'外観はパッとしない旅館だったが、部屋はなかなかきれいだ。'
        DB	"This place doesn't look like anything special from the"
        DB	CR
        DB	"outside, but the rooms are quite nice."
        DB	NEXT
        ;	DB	'俺と誠で一部屋。鈴子さんと新藤さんと美緒ちゃんの三人組、',CR,'亜希ちゃんと先生と白水さんの三人でそれぞれ一部屋ずつ。',CR,'・・・という部屋割になってる。'
        DB	"Makoto and I are in one room. Reiko, Kiyomi and Mio are"
        DB	CR
        DB	"in another room. Aki is going to share a room with"
        DB	CR
        DB	"Kyoko-sensei."
        DB	FLG,F_COPYI,4,1
        DW	0000H
        
M9:		;考える
        ;	DB	'晩飯はカニ鍋と、ほろ苦い風味の山菜おこわ。まあ、それなりに満足出来た。'
        DB	"Dinner was really delicious: boiled crab."
        DB	FLG,F_COPYI,4,2
        DW	0000H
        
        
M10:		;考える
        ;	DB	'さて！後は肝心の温泉だが・・・'
        DB	"Well, I guess it's time to go check out the hot"
        DB	CR
        DB	"springs..."
        DB	NEXT
        ;	DB	'がらっ！'
        DB	"*kacha*"
        T_CG 'CT14','C','D',20,1
        DB	NEXT
        ;	DB	'【誠】：%001ーッ！'
        DB	"Makoto:  %001...!!"
        DB	NEXT
        ;	DB	'【%001】：なんだよ誠、血相変えて。'
        DB	"%001:  What's the matter, Makoto?"
        DB C_BLD,C_V_ON,1	;
        DB C_BLD,C_V_OFF,2	;
        DB C_BLD,C_V_OFF,3	;話す
        DB C_BLD,C_V_ON,4	;
        DW	0000H
        
M11:		;行く
        ;	DB	'【%001】：・・・男のロマンだよな。'
        DB	"%001:  ......This is part of being a man, I guess."
        DB	NEXT
        ;	DB	'【誠】：そうだ、これこそ男道、すなわち漢の道だぞ%001！'
        DB	"Makoto:  Yes! This is a path that all men must take,"
        DB	CR
        DB	"peeking at women while they bathe!"
        DB	NEXT
        ;	DB	'【%001】：漢の道か・・・'
        DB	"%001:  I suppose..."
        DB	NEXT
        ;	DB	'【誠】：よし、それじゃ作戦を説明する。'
        DB	"Makoto:  Okay, here's the plan."
        DB	NEXT
        ;	DB	'誠はポケットから四つ折の紙を取り出し、ちゃぶ台の上に拡げた。'
        DB	"He unfolded a piece of paper, laying it out on the table."
        DB	NEXT
        ;	DB	'【誠】：これは俺が調査した、露天風呂の見取り図だ。'
        DB	"Makoto:  This is a diagram of the inn that I drew up."
        DB	NEXT
        ;	DB	'【%001】：・・・いつのまにこんなもん作ったんだ？'
        DB	"%001:  When did you have time to do this?"
        DB	NEXT
        ;	DB	'【誠】：気にするな。で、もっとものぞきに適した位置は、',CR,'ずばり・・・ここだ！'
        DB	"Makoto:  The best point for looking at the women is...here!"
        DB	NEXT
        ;	DB	'誠は地図の、赤い丸が書かれてる一点を指差した。'
        DB	"Makoto pointed to a red mark on the map."
        DB	NEXT
        ;	DB	'【%001】：・・・根拠はわかんねーが、とにかくそうか。'
        DB	"%001:  ....Okay."
        DB	NEXT
        ;	DB	'【誠】：それじゃ、時計を合わせるぞ。'
        DB	"Makoto:  Let's synchonize our watches."
        DB	NEXT
        ;	DB	'【%001】：・・・何か意味あるのか？'
        DB	"%001:  .........Does that really matter?"
        DB	NEXT
        ;	DB	'【誠】：あるんだ。３、２、１、０。'
        DB	"Makoto:  Just trust me."
        DB	NEXT
        ;	DB	'【誠】：よし、行くぜ！'
        DB	"Makoto:  Okay, let's go!"
        DB	NEXT
        B_O B_SUDA
        ;	DB	'・・・俺と誠は露天風呂に忍び寄った。'
        DB	"Makoto and I snuk down to the outdoor bath."
        DB	NEXT
        ;	DB	'【誠】：ここからは単独行動だ。無事を祈る！'
        DB	"Makoto:  We split up from here. I wish you well!"
        DB	NEXT
        ;	DB	'【%001】：おっ、おい・・・'
        DB	"%001:  Hey!"
        DB	NEXT
        ;	DB	'俺が呼び止めようとした時、すでに誠の姿はなかった。'
        DB	"But he was already gone."
        DB	NEXT
        ;	DB	'【%001】：さすが、サバゲーやってるだけのことはあるな・・・。'
        DB	"%001:  He plays his survival games too much..."
        DB	NEXT
        ;	DB	'「・・・くぁーっ！これこそ温泉の醍醐味ってやつよね！」'
        DB	"'Oh! The water is just lovely!'"
        DB	NEXT
        ;	DB	'「鈴子先輩って、肌すべすべだね・・・」'
        DB	"'Reiko, your skin is really soft and supple...'"
        DB	NEXT
        ;	DB	'「こっこら、くすぐったいでしょ、もう！」'
        DB	"'Hey, that tickles!'"
        DB	NEXT
        ;	DB	'【%001】：ごくり・・・'
        DB	"%001:  ......*gulp*"
        DB	NEXT
        DB SINARIO,'CSA09.OVL',0
        DW	0000H
        
M12:		;行かない
        ;	DB	'【%001】：誠・・・それは犯罪だぞ、犯罪！'
        DB	"%001:  Makoto, that's illegal, you know!"
        DB	NEXT
        ;	DB	'【誠】：%001。のぞきはバレなきゃ犯罪にはならないんだよ。'
        DB	"Makoto:  %001. Peeking at women isn't illegal unless you"
        DB	CR
        DB	"get caught."
        DB	NEXT
        ;	DB	'【誠】：それに、女の子にとってのぞかれるってことは、自分が魅力的だって認められたことになるんだぜ。'
        DB	"Makoto:  And besides, when you look at women like that,"
        DB	CR
        DB	"you're just affirming that they're beautiful."
        DB	NEXT
        ;	DB	'【誠】：向こうものぞかれるのを期待してるかもよ。'
        DB	"Makoto:  They expect us to look at them, %001!"
        DB	NEXT
        ;	DB	'【%001】：・・・なんかウソっぽいな・・・'
        DB	"%001:  I think you're full of shit..."
        DB	FLG,F_COPYI,6,1
        DW	0000H
        
M13:		;行かない
        ;	DB	'【%001】：・・・とにかく俺は行かねーからな！'
        DB	"%001:  Well, I'm not going."
        DB	NEXT
        T_CG 'CT14','C','D',20,1
        ;	DB	'【誠】：・・・%001。お前には、失望した。'
        DB	"Makoto:  %001, I'm disappointed in you."
        DB	NEXT
        ;	DB	'【誠】：お前が来ないなら、俺一人で行く。じゃーな。'
        DB	"Makoto:  If you won't come, I'll go by myself. Goodbye!"
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'誠は風のように部屋を去っていった。'
        DB	"Like the wind, Makoto leaves the room."
        DB C_BLD,C_V_ON,5
        DB C_BLD,C_V_ON,6
        DB C_BLD,C_V_OFF,7
        DB C_BLD,C_V_OFF,8
        DW	0000H
        
M14:		;止める
        ;	DB	'【%001】：誠を止めなきゃ！'
        DB	"%001:  I've got to stop him!"
        DB	NEXT
        B_O B_SUDA
        ;	DB	'・・・俺は誠を追いかけて露天風呂まで来た。'
        DB	"I ran after him, going down to the outdoor bath."
        DB	NEXT
        ;	DB	'だが、どうやって隠れたのか、誠は見つからない。'
        DB	"But he was gone. Or else...hiding somewhere."
        DB	NEXT
        ;	DB	'【%001】：さすが、サバゲーやってるだけのことはあるな・・・。'
        DB	"Him and his survival training."
        DB	NEXT
        ;	DB	'「・・・くぁーっ！これこそ温泉の醍醐味ってやつよね！」'
        DB	"'Oh! The water is just lovely!'"
        DB	NEXT
        ;	DB	'【%001】：えっ・・・'
        DB	"%001:  Huh?"
        DB	NEXT
        ;	DB	'「鈴子先輩って、肌すべすべだね・・・」'
        DB	"'Reiko, your skin is really soft and supple...'"
        DB	NEXT
        DB	"'Hey, that tickles!'"
        DB	NEXT
        ;	DB	'【%001】：このむこうに・・・みんなが・・・'
        DB	"They're all on the other side of the fence..."
        DB	NEXT
        ;	DB	'【%001】：ごくり・・・'
        DB	"*gulp*"
        DB	NEXT
        DB SINARIO,'CSA09.OVL',0
        DW	0000H
        
M15:		;止めない
        ;	DB	'【%001】：ま、いいか。・・・ほっとこう。'
        DB	"%001:  Well, he'll be fine on his own, I guess."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ..................."
        DB	NEXT
        ;	DB	'【%001】：・・・ってわけにもいかねーか。'
        DB	"%001:  ....What am I saying?"
        DW	0000H


end
