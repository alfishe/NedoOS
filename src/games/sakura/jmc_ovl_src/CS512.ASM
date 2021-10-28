;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１２
;		林間学校　瑠璃の過去

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
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'今日子',0
NN1:	DB	1,	"KYOKO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　今日子１
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14		;話す　今日子１２


;イニシャルメッセージ
M1:
	DB	BGM,21
	B_O B_FADE
	BAK_INIT 'AB_16_1'
	DB BUF,B_COPY01
	T_CG 'CT12','T',0,0,1
;	DB	'【%001】：・・・あ、いたいた・・・'
	DB	"%001:  ...Oh, there she is."
	DB	PAUSE
;	DB	'今日子先生～！'
	DB	" Good morning, Sensei."
	DB	NEXT
;	DB	'【今日子】：・・・お、起きたわね%001君。'
	DB	"Kyoko:  Oh, %001. You're up."
	DW	0000H

M2:		;見る　今日子１
;	DB	'いつも通りの先生だ。別にどこも変わっていない。'
	DB	"Sensei was the same as ever. It was like nothing had",CR,"happened last night."
	DB	NEXT
;	DB	'めずらしくシラフだっていう見方もあるけど。'
	DB	"I guess she was looking at me a little more seriously than",CR,"usual, though."
	DW	0000H

M3:		;話す　今日子１
;	DB	'【今日子】：・・・どう？よく眠れた？'
	DB	"Kyoko:  So? Did you sleep well?"
	DB	NEXT
;	DB	'【%001】：ええ。'
	DB	"%001:  Yes."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　今日子２
;	DB	'【今日子】：・・・しっかし%001君もムチャするわね～。'
	DB	"Kyoko:  I'm angry with you for disregarding what I said."
	DB	NEXT
;	DB	'【%001】：いやははははは・・・・・・'
	DB	"%001:  Oh, that."
	DB	NEXT
;	DB	'【今日子】：まったく、無事だったから良かったけど・・・'
	DB	"Kyoko:  I mean, it was okay because nothing happened, but ",CR,"don't let it happen again."
	DB	NEXT
;	DB	'【%001】：俺だって、もう御免ですよ・・・'
	DB	"%001:  It's not like I want to risk my life that that again!"
	DB	PAUSE,CR
;	DB	"I actually really thought I was gonna die.",CR
	DB	"We both could have died out there!"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　今日子３
;	DB	'【今日子】：・・・・・・'
	DB	"Kyoko:  ............"
	DB	PAUSE
;	DB	'ねえ、%001君。どうしてあんな事したの？'
	DB	"So, %001. Why did you go out there?"
	DB	NEXT
;	DB	'【%001】：待ってたら間に合わないからと思ったから。'
	DB	"%001:  I knew there wouldn't be enough time otherwise."
	DB	NEXT
;	DB	'【今日子】：・・・それだけ？'
	DB	"Kyoko:  Is that the only reason?"
	DB	NEXT
;	DB	'【%001】：それだけ。'
	DB	"%001:  Sure."
	DB	NEXT
;	DB	'【今日子】：・・・・・・'
	DB	"Kyoko:  ........."
	DB	PAUSE
;	DB	'ま、いっか。そーゆー事にしときましょ。'
	DB	"Well, Okay. I don't believe you, though."
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  ???"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;話す　今日子４
;	DB	'【今日子】：ところで%001君。'
	DB	"Kyoko:  By the way, %001..."
	DB	PAUSE
	DB	" Do you know why Ruri"
	DB	CR
	DB	"transferred to our school?"
	DB	NEXT
;	DB	'【%001】：・・・家の都合だ、って聞いてるけど・・・'
	DB	"%001:  Well, I just heard it had something to do with her",CR,"family."
	DB	NEXT
;	DB	'【今日子】：実はね・・・・・・あの娘のお母さんのせいなのよ。'
	DB	"Kyoko:  Well, actually, it's because of her mother."
	DB	NEXT
;	DB	'【%001】：・・・え？'
	DB	"%001:  .....Her mother?"
	DB	BGM,31
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;話す　今日子５
;	DB	'【今日子】：あの娘の家って、元々は華族だったそうよ。'
	DB	"Kyoko:  Her family is quite wealthy, you know."
	DB	NEXT
;	DB	'【%001】：・・・ああ、それは聞いた事がある。'
	DB	"%001:  Yeah, I had heard that."
	DB	NEXT
;	DB	'【今日子】：・・・でまぁ、なんつーか・・・'
	DB	"Kyoko:  .....Apparently, her mother is a real snob."
	DB	PAUSE
;	DB	'学校とかに、ムチャクチャな事言って来るらしいのよね。'

	DB	NEXT
	DB	"Kyoko:  It seems that she makes all sorts of unreasonable ",CR,"demands of schools that her daughter attends."
	DB	NEXT
;	DB	'【%001】：・・・と言うと？'
	DB	"%001:  Like?"
	DB	NEXT
;	DB	'【今日子】：聞いた話だけど・・・'
	DB	"Kyoko:  Well, this is just what I heard, but..."
	DB	NEXT
;	DB	'【今日子】：クラスの友達全部入れ変えろとか、'
	DB	"Kyoko:  For example, they were supposed to remove any"
	DB	CR
	DB	"classmates her mother didn't approve of..."
	DB	NEXT
;	DB	'【今日子】：教科書和紙にしろとか、'
	DB	"Kyoko:  And use fancy Japanese paper to cover her textbooks."
	DB	NEXT
;	DB	'【今日子】：送り迎えの為の車と駐車場用意しろとか・・・'
	DB	"Kyoko:  She even demanded that a chauffeur and a parking spot ",CR,"be provided for her daughter."
	DB	NEXT
	DB	"Kyoko:  If the school refuses to give in to her, she takes"
	DB	CR
	DB	"Ruri out of that school and puts her into another one."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..................."
	DB	PAUSE
;	DB	'確かに、ムチャだな。'
	DB	"Wow, incredible."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M8:		;話す　今日子６
;	DB	'【今日子】：・・・まぁ万事こんな調子だから、トラブル断えなかったみたいでね。小学校時代から通算すると、１００回以上転校してるのよ。'
	DB	"Kyoko:  Because of her mother's stupidity, there's been nothing"

	DB	CR

	DB	"but trouble. Ruri has transferred schools over one hundred ",CR,"times since she was in elementary school." 
	DB	NEXT
;	DB	'【%001】：・・・ひ、ひゃっかい！？'
	DB	"%001:  One hundred times?!"
	DB	NEXT
;	DB	'【今日子】：・・・だからあの娘は、誰にも心を開かなくなった・・・'
	DB	"Kyoko:  ....So that's why the girl has never opened her ",CR,"heart to anyone."
	DB	NEXT
;	DB	'傷つきすぎて、心が死んでしまった・・・'
	DB	"Kyoko:  She's been hurt too much, and her heart has died."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............."
	DB	FLG,F_COPYI,2,6
	DW	0000H

M9:		;話す　今日子７
;	DB	'【%001】：・・・じゃあ、ウチの学校にもそーゆー要求が・・・？'
	DB	"%001:  So, have those demands been made of our school?"
	DB	NEXT
;	DB	'【今日子】：ううん、今のところは大丈夫よ。'
	DB	"Kyoko:  No, it seems to be okay right now."
	DB	PAUSE
;	DB	'あの娘のお母さん、ウチの学校知らないから。'
	DB	" The reason for"
	DB	CR
	DB	"that is, her mother doesn't know that she's at this school."
	DB	NEXT
;	DB	'【%001】：・・・・・・へ？'
	DB	"%001:  ...What?"
	DB	FLG,F_COPYI,2,7
	DW	0000H

M10:		;話す　今日子８
;	DB	'【今日子】：父方の親戚が、見兼ねたらしくてね。'
	DB	"Kyoko:  It seems her father's relatives couldn't stand it ",CR,"anymore."
	DB	NEXT
;	DB	'あの娘をお母さんから引き離して、ウチに転入させたのよ。'
	DB	"Kyoko:  They separated the girl from her mother and took her ",CR,"in. They're supposedly friends of the dean's or something."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................"
	DB	NEXT
;	DB	'【今日子】：当然、お母さんの方は大騒ぎしてるんだけど・・・'
	DB	"Kyoko:  Of course, her mother is making a big fuss about it.",CR
;	DB	'親戚の方も譲る気はないみたいね。裁判沙汰にしてでも瑠璃ちゃんを'
;	DB	'守って見せる、って息巻いてたわ。'
	DB	"The relatives show no sign of giving up either. They're ",CR,"furious and are prepared to fight a custody battle over Ruri."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  Wow."
	DB	FLG,F_COPYI,2,8
	DW	0000H

M11:		;話す　今日子９
;	DB	'【%001】：・・・・・・一体、ど～なるんですか・・・・・・？'
	DB	"%001:  So what's going to happen?"
	DB	NEXT
;	DB	'【今日子】：こればっかりは、分からないわ。'
	DB	"Kyoko:  I'm not sure."
	DB	PAUSE
;	DB	'ただ、裁判では瑠璃ちゃん当人の意志が尊重されるのは確かよ。'
	DB	" I only know that they will respect"
	DB	CR
	DB	"Ruri's own wishes in court."
	DB	NEXT
;	DB	'【%001】：・・・白水さんの、意志・・・'
	DB	"%001:  Her own wishes?"
	DB	NEXT
;	DB	'【今日子】：そう・・・そして瑠璃ちゃんは、お母さんのところに'
;	DB	'帰りたがっているわ。'
	DB	"Kyoko:  Yes. And she wants to go back to live with her mother."
	DB	FLG,F_COPYI,2,9
	DW	0000H

M12:		;話す　今日子１０
;	DB	'【%001】：・・・・・・どうして・・・・・・'
	DB	"%001:  ...Why?"
	DB	NEXT
;	DB	'【%001】：どうして、そんな母親のところに帰りたがるんだ！？'
	DB	"%001:  Why go back to a mother like that?"
	DB	NEXT
;	DB	'【%001】：白水さんが辛い目に合っているのは、か～ちゃんのせいじゃないか！'
	DB	"%001:  What a terrible mother!"
	DB	NEXT
;	DB	'【今日子】：・・・・・・・・・'
	DB	"Kyoko:  ......................."
	DB	NEXT
;	DB	'【今日子】：そうね。だけど、あの娘は「帰りたい」って言ったわ。'
	DB	"Kyoko:  That's true. But she's said she wants to go back." 
	DB	FLG,F_COPYI,2,10
	DW	0000H

M13:		;話す　今日子１１
;	DB	'【%001】：・・・・・・何で・・・・・・何でなんだよ・・・・・・？'
	DB	"%001:  I can't understand that."
	DB	NEXT
;	DB	'【今日子】：・・・本当のところは、瑠璃ちゃんにしか分からない。'
	DB	"Kyoko:  Well, it's between Ruri and her mother."
	DB	PAUSE
;	DB	'でもね、あの娘・・・こうも言ったわ。'
	DB	" But you"
	DB	CR
	DB	"know what she said to me once?"
	DB	NEXT
;	DB	'【今日子】：「お母様は、私を愛してくれるもの」'
	DB	"Kyoko:  'My mother is the only one who loves me.'"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DB	FLG,F_COPYI,2,11
	DW	0000H

M14:		;話す　今日子１２
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .............."
	DB	PAUSE
;	DB	'先生、どうしてこんな話を俺に？'
	DB	"Sensei, why are you telling me this?"
	DB	NEXT
;	DB	'【今日子】：女の勘。'
	DB	"Kyoko:  ....I'm not sure. Just a feeling that I should. "
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・'
	DB	"%001:  ........................"
	DB	PAUSE
;	DB	'はい？'
	DB	"Really?"
	DB	NEXT
;	DB	'【今日子】：あなたには、話しておきたかったのよ。'
	DB	"Kyoko:  I just wanted to let you know."
	DB	NEXT
;	DB	'あの娘を誰よりも真剣に捜してくれた、あなたには。'
	DB	"Kyoko:  I wanted to tell you, because you've done more for her ",CR,"than anyone else."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........................."
	DB	NEXT
	DB	BGM,31
	K_CG 'CT12','K',0,1
;	DB	'【今日子】：・・・さ、みんなのところに戻って。今日は、山菜取りよ。'
	DB	"Kyoko:  Alright, let's go back. We're supposed to gather ",CR,"mushrooms today."
	DB	NEXT
	B_O B_FADE
;	DB	'・・・・・・白水さん・・・・・・'
	DB	".......Ruri."
	DB	NEXT
;	DB	'君はまた、行ってしまうのか・・・・・・？'
	DB	"Are you going to run off again?"
	DB	NEXT
;	DB	'俺達は、君の海にはなれないのか・・・・・・？'
	DB	"Can't you ever accept us as your friends.......?"
	DB	NEXT
;	DB	'みんなと山菜を取っている間も、俺はこの思いから自由にはなれなかった・・・・・'
	DB	"Even while I was picking mushrooms with everybody, I couldn't"
	DB	CR
	DB	"stop thinking about her for some reason."
	DB	NEXT
	DB	SINARIO,'CS513_E.OVL',0
	DW	0000H


end