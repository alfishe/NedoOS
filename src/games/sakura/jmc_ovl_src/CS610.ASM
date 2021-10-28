;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６１０
;		３日め朝

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3		;見る
S2:		DW	VV2, -1,  2, M4, M5, M6		;話す


;イニシャルメッセージ
M1:
	DB	BGM,2
	BAK_INIT 'AB_17_1'
;	DB	'・・・そして夜が明けて、急遽決定された遠泳大会当日。'
	DB	".....So the day of the hastily-arranged swim competition"
	DB	CR
	DB	"dawned."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT01','M',0,20,2
	TU_CG 'CT14','M','D',40,1
	T_CG 'CT08','M',0,0,3
	DB	ANI,A_ON,2
	DB	ANI,A_ON,1
;	DB	'【誠】：まぁーったく、お前はろくなことしねぇなあ！'
	DB	"Makoto:  I can't believe you suggested something like a"
	DB	CR
	DB	"swimming competition to the dean!"
	DB	NEXT
;	DB	'【%001】：俺だってこんな事になるとは思わなかったっての！'
	DB	"%001:  Do you really think I wanted this to happen?"
	DB	NEXT
;	DB	'【鈴子】：まあいいじゃない。なんて言っても賞品は夏休みの一週間延長なのよ！'
	DB	"Reiko:  Well, yeah. But nevertheless the prize is an"
	DB	CR
	DB	"extra week of summer vacation!"
	DB	NEXT
	DB	ANI,A_OFF
	T_CG1 'CT14','M',0,40,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【誠】：そりゃ、鈴子さんは間違い無く１位だろうけど・・・'
	DB	"Makoto:  Well, sure, since you'll come in first anyway."
	DB	NEXT
;	DB	'【恵依美】：上位２０名かぁ・・・狭き門よね。'
	DB	"Meimi:  The first twenty, that's pretty tight."
	DB	NEXT
;	DB	'【%001】：罰ゲームってどんなんだろ。'
	DB	"%001:  I wonder what the punishment is."
	DB	NEXT
;	DB	'【誠】：校長の熱～いキッスとか・・・'
	DB	"Makoto:  Maybe a kiss from the dean..."
	DB	NEXT
	DB	ANI,A_OFF
	K_CG 'CT08','I',0,5
	DB	ANI,A_ON,2
	DB	ANI,A_ON,4
;	DB	'【恵依美】：うっわぁ～・・・'
	DB	"Meimi:  Yecccchhh..."
	DB	NEXT
;	DB	'【%001】：・・・死んだ方がマシだな。'
	DB	"%001:  Probably be easier just to lay down and die."
	DB	NEXT
	DB	ANI,A_OFF
	K_CG 'CT01','D',20,6
	DB	ANI,A_ON,4
	DB	ANI,A_ON,5
;	DB	'【鈴子】：ダメよ%001君！命を粗末にしちゃ！'
	DB	"Reiko:  No, %001! Life must be a struggle!"
	DB	NEXT
;	DB	'（？　鈴子さん、目がマジだ・・・）'
	DB	".......What's up with Reiko...?"
	DB C_BLD,C_V_ON,2
	DW	0000H

M2:		;見る
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG 'CT12','M',0,25,1
;	DB	'【今日子】：は～い、皆さん注目～！'
	DB	"Kyoko:  Okay, attention, everybody!"
	DB	NEXT
;	DB	'【%001】：いよいよか・・・'
	DB	"%001:  I guess this is it..."
	DB	NEXT
;	DB	'【今日子】：え～、昨日突然決まった遠泳大会は、突然中止になりました。'
	DB	"Kyoko:  The swimming competition announced yesterday"
	DB	CR
	DB	"will be cancelled."
	DB	NEXT
;	DB	'【鈴子】：どうしてですか！？'
	DB	"Reiko:  Why?!"
	DB	NEXT
;	DB	'【今日子】：言い出しっぺの校長先生が、べろんべろんに酔っ払ったまま夜の海に行って、そのまま帰って来てないからです。'
	DB	"Kyoko:  Well, that silly dean got really drunk last"
	DB	CR
	DB	"night and went for a swim, but he never came back."
	DB	NEXT
;	DB	'【%001】：それって・・・大事件じゃねーの！？'
	DB	"%001:  But......that's terrible!"
	DB	NEXT
	K_CG 'CT12','K',25,2
;	DB	'【今日子】：大丈夫、な～んにも心配無いわ。'
	DB	"Kyoko:  Oh, it's nothing to worry about."
	DB	NEXT
;	DB	'【今日子】：ただし、今日はあの小島に近づいてはダメよ。'
	DB	"Kyoko:  However, don't try to go near the little island"
	DB	CR
	DB	"today."
	DB	NEXT
;	DB	'【誠】：どーしてですか？'
	DB	"Makoto:  Why not?"
	DB	NEXT
;	DB	'【今日子】：どーしてもです。'
	DB	"Kyoko:  Because."
	DB	NEXT
;	DB	'【誠】：・・・よーするに、あの島にいるんだな校長先生が。'
	DB	"Makoto:  So, you're saying that the dean is over"
	DB	CR
	DB	"there."
	DB	NEXT
;	DB	'【恵依美】：べろんべろんに酔い潰した後、あの島に捨てて来たのね。'
	DB	"Meimi:  You got him drunk, brought him to the island and "
	DB	CR
	DB	"left him there."
	DB	NEXT
;	DB	'【%001】：教職員も全員参加ってのがいやだったんだろーな。'
	DB	"%001:  The professors didn't want to participate in the"
	DB	CR
	DB	"competition, huh?"
	DB	NEXT
;	DB	'【鈴子】：先生達も、もう若くないものね・・・'
	DB	"Reiko:  I guess you professors are kind of old for that..."
	DB	NEXT
;	DB	'【今日子】：・・・そこ、静かにしなさいね。'
	DB	"Kyoko:  Be quiet, over there!"
	DB	NEXT
;	DB	'【%001】：へ～い。'
	DB	"%001:  All right."
	DB	NEXT
;	DB	'【今日子】：とにかく、遠泳大会は中止。',CR,'そーゆー事で、今日も節度を守って自由に行動して下さい。'
	DB	"Kyoko:  Anyway, there's no swim competition. So, as you"
	DB	CR
	DB	"were, do as you please today."
	DB	NEXT
;	DB	'【%001】：助かった・・・。'
	DB	"%001:  That's good news."
	DB C_BLD,C_V_OFF,2	;話す
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る
;	DB	'見たところ、遠泳大会が中止になって喜んでる奴の方が多数派らしい。'
	DB	"Everyone was relieved to have the swimming competition"
	DB	CR
	DB	"cancelled."
	DB	NEXT
;	DB	'俺ももちろん喜んでる。'
	DB	"Of course I was happy about it."
	DW	0000H

M4:		;話す
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	TU_CG 'CT01','M',0,20,2
	TU_CG 'CT14','M',0,40,1
	T_CG 'CT08','M','K',0,3
	DB	ANI,A_ON,2
	DB	ANI,A_ON,1
;	DB	'【恵依美】：んじゃ、あたしは泳いでくるね。'
	DB	"Meimi:  Well, I'm going swimming."
	DB	NEXT
;	DB	'【誠】：そーいえば・・・片割れはどうした？'
	DB	"Makoto:  Hey, what happened to your other half?"
	DB	NEXT
;	DB	'【恵依美】：・・・星愛のこと？'
	DB	"Meimi:  ...You mean Seia?"
	DB	NEXT
;	DB	'【誠】：他にいねぇだろ。'
	DB	"Makoto:  Who else?"
	DB	NEXT
	K_CG 'CT14','D',40,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
	DB	"Meimi:  She's just like %001. Seia can't swim."
	DB	NEXT
;	DB	'【%001】：へぇ・・・吉田もカナヅチなんだ。'
	DB	"%001:  So, Seia can't swim either?"
	DB	NEXT
;	DB	'【恵依美】：いろいろ特訓したんだけど、全然泳げるようにならなくて。'
	DB	"Meimi:  She's taken all kinds of classes, but she just can't"
	DB	CR
	DB	"get the hang of it."
	DB	NEXT
	K_CG 'CT14','K',40,5
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【誠】：教え方が悪いんじゃない？中野は乱暴だからな～'
	DB	"Makoto:  Well, some people just aren't cut out for sports."
	DB	NEXT
	K_CG 'CT08','D',0,6
	DB	ANI,A_ON,2
	DB	ANI,A_ON,5
;	DB	'【恵依美】：なんですってーっ！'
	DB	"Meimi:  What did you say...?"
	DB	NEXT
;	DB	'【誠】：おっと、やべぇ！'
	DB	"Makoto:  Oh....OUCH!"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT01','M',0,20,2
;	DB	'二人は海の方に走っていって、そのままどんどん沖の方に泳いで行ってしまった。'
	DB	"The two of them went running towards the ocean and"
	DB	CR
	DB	"plunged into the water."
	DB	NEXT
;	DB	'【%001】：・・・元気だなあいつら。'
	DB	"%001:  .....Well, they're full of energy."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す
;	DB	'【鈴子】：%001君、今日こそ泳ぎを・・・。'
	DB	"Reiko:  %001, we should probably try some swimming today."
	DB	NEXT
	T_CG1 'CT07','M','I',0,7
	DB	ANI,A_ON,2
;	DB	'【星愛】：鈴子先輩！'
	DB	"Seia:  Reiko!"
	DB	NEXT
;	DB	'唐突に、吉田が現われた。'
	DB	"Seia suddenly appeared."
	DB	NEXT
;	DB	'【鈴子】：な、なにかしら？'
	DB	"Reiko:  W- What's up?"
	DB	NEXT
;	DB	'【星愛】：わたくしに、泳ぎを教えて下さい！'
	DB	"Seia:  Please teach me how to swim!"
	DB	NEXT
;	DB	'【鈴子】：え・・・'
	DB	"Reiko:  But I..."
	DB	NEXT
;	DB	'【%001】：そーいや、吉田も泳げねーんだったな。'
	DB	"%001:  So you can't swim either, Seia?"
	DB	NEXT
;	DB	'【星愛】：はい・・・'
	DB	"Seia:  That's right."
	DB	NEXT
;	DB	'【星愛】：せっかく恵依美ちゃんが教えてくれるのに、少しも進歩が無くて・・・。このままでは恵依美ちゃんに申し訳ないのです。'
	DB	"Seia:  Meimi's been teaching me, but I haven't gotten"
	DB	CR
	DB	"any better. I don't want to keep bothering Meimi."
	DB	NEXT
;	DB	'【%001】：そか・・・鈴子さん、吉田に泳ぎを教えてやって。',CR,'きっと俺よりは素質あると思うし。'
	DB	"%001:  Well, Reiko, why don't you teach Seia? I'm sure"
	DB	CR
	DB	"she has more talent than I do."
	DB	NEXT
;	DB	'【星愛】：よろしくお願い致しますわ。'
	DB	"Seia:  Please, won't you teach me?"
	DB	NEXT
;	DB	'【鈴子】：・・・ええ、もちろんいいわよ。'
	DB	"Reiko:  ......Okay, okay."
	DB	NEXT
;	DB	'【%001】：じゃ、俺はその辺で背中でも焼くわ。'
	DB	"%001:  Well, I'm going to go get some sunbathing in over"
	DB	CR
	DB	"there."
	DB	NEXT
	B_O B_SUDA
;	DB	'俺は鈴子さん達に手を振って、海沿いに歩いていった。'
	DB	"I waved to them and walked along the water."
	DB	NEXT
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG 'CT03','M',0,12,1
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【%001】：あ、美緒ちゃん。'
	DB	"%001:  Oh, Mio."
	DB	NEXT
;	DB	'しばらく歩いたところで、美緒ちゃんと会った。'
	DB	"After a bit, I ran into Mio."
	DB	FLG,F_COPYI,2,2
	DW	0000H


M6:		;話す
;	DB	'【美緒】：%001先輩・・・一緒に潮干狩り、しない？'
	DB	"Mio:  %001....do you want to go looking for clams?"
	DB	NEXT
;	DB	'【%001】：いーよ。ちょうどヒマだったし。'
	DB	"%001:  Sure. I happen to have some free time right now."
	DB	NEXT
	K_CG 'CT03','K',12,2
;	DB	'【美緒】：あはっ、やった！'
	DB	"Mio:  Great!"
	DB	NEXT
;	DB	'【美緒】：行こっ、先輩！'
	DB	"Mio:  Let's go!"
	DB	NEXT
;	DB	'美緒ちゃんは俺の腕をぐいぐい引っ張っていった。'
	DB	"Mio grabbed my arm and dragged me with her."
	DB	NEXT
	B_O B_WIPE
	DB SINARIO,'CS611.OVL',0
	DW	0000H


end
