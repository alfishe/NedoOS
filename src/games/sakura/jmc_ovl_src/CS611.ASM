;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６１１
;		破れ傘刀舟　潮干狩り

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
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'掘る',0
VV3:	DB	3,	"DIG",0

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	"MIO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　美緒
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7, M8, M9, M10		;話す　美緒
S3:		DW	VV3, -1,  3, M11		;掘る


;イニシャルメッセージ
M1:
	DB	BGM,19
	BAK_INIT "AB_17_1"
	DB BUF,B_COPY01
	T_CG "CT03","M",0,15,1
;	DB	'俺達は河口の近くの干潟に来た。'
	DB	"We came to the flat area by the mouth of the river."
	DB FLG,F_COPYI,100,0
	DW	0000H

M2:		;見る　美緒
;	DB	'きれいな貝殻を見つけて集めてるようだ。'
	DB	"Looks like we could find lots of pretty shells here."
	DW	0000H

M3:		;話す　美緒
;	DB	'【%001】：なあ、アワビとかサザエってどのくらい掘れば出てくるんだ？'
	DB	"%001:  Can we find some abalone and conch?"
	DB	NEXT
;	DB	'【美緒】：あーゆー貝は、砂にはもぐらないんじゃないかなぁ・・・。'
	DB	"Mio:  I don't think they burrow in the sand..."
	DB	NEXT
;	DB	'【%001】：そか・・・残念。'
	DB	"%001:  Really? That's too bad."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　美緒
;	DB	'【%001】：・・・カキとかホタテは？'
	DB	"%001:  What about oysters and scallops?"
	DB	NEXT
;	DB	'【美緒】：海に潜らないと、見つからないよ。'
	DB	"Mio:  We won't find them unless we wade in the water."
	DB	NEXT
;	DB	'【%001】：・・・・・・ちぇ。'
	DB	"%001:  ....Damn."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　美緒
;	DB	'【美緒】：先輩、これなんていう貝の殻？'
	DB	"Mio:  %001, what do you call this shell?"
	DB	NEXT
;	DB	'【%001】：さぁ。新藤さんなら知ってるんじゃねーか？'
	DB	"%001:  Hmm, Kiyomi would probably know."
	DB	NEXT
;	DB	'【美緒】：・・・清美先輩？'
	DB	"Mio:  Kiyomi?"
	DB	NEXT
;	DB	'【%001】：昨日二人で島に行った時、いろいろ教えられたからな。'
	DB	"%001:  When we went to the island yesterday, she taught"
	DB	CR
	DB	"me a lot of about the ocean."
	DB	NEXT
;	DB	'【美緒】：・・・ふぅん。'
	DB	"Mio:  Oh."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;話す　美緒
;	DB	'【%001】：そーいや、今日は見掛けねーな、新藤さん。',CR,'美緒ちゃん、知らねーか？'
	DB	"%001:  I haven't seen Kiyomi today. Have you, Mio?"
	DB	NEXT
;	DB	'【美緒】：・・・わかんない。'
	DB	"Mio:  I don't know."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;話す　美緒
;	DB	'【美緒】：あ！先輩、ほら、桜貝！'
	DB	"Mio:  Oh! %001, look, a cherry shell."
	DB	NEXT
;	DB	'【%001】：それって食えるのか？'
	DB	"%001:  Can you eat it?"
	DB	NEXT
;	DB	'【美緒】：・・・殻だけだから食べられないよ。'
	DB	"Mio:  It's just the shell, so you can't eat it."
	DB	NEXT
;	DB	'【%001】：へぇ・・・キレイだな、その貝。',CR,'美緒ちゃんの指の爪みたいな色だ。'
	DB	"%001:  Wow...it's pretty, isn't it. It looks the same"
	DB	CR
	DB	"color as your fingernails."
	DB	NEXT
;	DB	'【美緒】：え・・・'
	DB	"Mio:  Oh."
	DB	NEXT
	K_CG "CT03","R",15,2
;	DB	'こころなし、美緒ちゃんの顔が赤くなったような気がする。'
	DB	"I noticed that Mio had turned as red as a beet."
	DB	NEXT
;	DB	'（日やけかな？）'
	DB	"She must be sunburned."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M8:		;話す　美緒
;	DB	'【美緒】：あれ・・・こんな所にビンがある。'
	DB	"Mio:  That's odd. There's a bottle here."
	DB	NEXT
;	DB	'【%001】：海にゴミを捨てちゃいけねーよな。'
	DB	"%001:  People shouldn't throw garbage in the ocean."
	DB	NEXT
;	DB	'【美緒】：ううん、中に手紙が入ってる。'
	DB	"Mio:  Yes, but there's a letter in it."
	DB	NEXT
;	DB	'【%001】：ホント？どれどれ・・・'
	DB	"%001:  Really? Let me see it."
	DB	NEXT
;	DB	'【美緒】：えっと・・・',CR,'これ、ロシア語かな？何か、島の地図みたいな絵が描いてあるよ・・・。'
	DB	"Mio:  Hmm, is this Russian maybe? It looks like someone"
	DB	CR
	DB	"drew a map of an island..."
	DB	NEXT
;	DB	'【%001】：・・・なーんとなくヤバそうだな・・・'
	DB	"%001:  I don't know, it's pretty strange..."
	DB	NEXT
;	DB	'【美緒】：見なかった事にした方がいいのかな・・・？'
	DB	"Mio:  Maybe we should pretend we never found it...?"
	DB	NEXT
;	DB	'【%001】：そうしよう。'
	DB	"%001:  Good idea."
	DB	NEXT
;	DB	'俺は手紙をばらばらに千切って、砂に埋めた。'
	DB	"I ripped up the letter and buried it in the sand."
	DB	FLG,F_COPYI,2,6
	DW	0000H

M9:		;話す　美緒
;	DB	'【美緒】：先輩、後でその貝お料理に使ってもいい？'
	DB	"Mio:  %001, should I cook the shellfish later?"
	DB	NEXT
;	DB	'【%001】：お～、頼むよ。'
	DB	"%001:  Oh, good idea."
	DB	NEXT
;	DB	'【美緒】：この間慎治君に、おいしいお味噌汁の作り方教えてもらったんだ。'
	DB	"I learned this really good miso soup recipe from Shinji"
	DB	CR
	DB	"recently."
	DB	NEXT
;	DB	'【%001】：そりゃ楽しみだな。',CR,'んじゃ、みんなの分も貝取ってかねーと。'
	DB	"%001:  Sounds wonderful. But, shouldn't we get enough"
	DB	CR
	DB	"for the others too?"
	DB	FLG,F_COPYI,2,7
	DW	0000H

M10:		;話す　美緒
;	DB	'【美緒】：先輩！ほら、アンモナイト！'
	DB	"Mio:  %001! Look, an ammonite!"
	DB	NEXT
;	DB	'【%001】：そんな馬鹿な・・・'
	DB	"%001:  What? Where? What's that?"
	EF_SET 201
	DW	0000H

M11:		;掘る
	DB FLG,F_CALI,100,1
	DB FLG,F_COMPI,101,100,10
	DB FLG,F_JGR,101
	DW M_S4
;	DB	'俺は熊手で砂を掘った。'
	DB	"I started digging in the sand with both hands."
	DB	NEXT
;	DB	'ざっくざっくざっく・・・'
	DB	"*DIG* *DIG*"
	DB FLG,F_COPYI,255,0
	DB FLG,F_RAND,255,4
	DB FLG,F_JEQ,255
	DW M_S0
	DB FLG,F_CALI,255,-1
	DB FLG,F_JEQ,255
	DW M_S1
	DB FLG,F_CALI,255,-1
	DB FLG,F_JEQ,255
	DW M_S2
	DB FLG,F_CALI,255,-1
	DB FLG,F_JEQ,255
	DW M_S3
	DW	0000H

M_S0:
	DB	NEXT
;	DB	'【%001】：・・・何も見つかんねー。'
	DB	"%001:  I'm not finding anything."
	DW	0000H

M_S1:
	DB	NEXT
;	DB	'【%001】：お、ハマグリ発見！'
	DB	"%001:  Oh, I found a clam!"
	DW	0000H

M_S2:
	DB	NEXT
;	DB	'【%001】：お、アサリ発見！'
	DB	"%001:  Oh, I found a goose-neck clam!"
	DW	0000H

M_S3:
	DB	NEXT
;	DB	'【%001】：お、シジミ発見！'
	DB	"%001:  Oh, I found a 'sazae'!"
	DW	0000H

M_S4:
	EF_SET 202
	DW	0000H

M_EXIT:
	DB	NEXT
;	DB	'【%001】：さて、この辺一帯は掘りつくしたし、場所変えようか。'
	DB	"%001:  Well, it looks like we've really dug up this place."
	DB	CR
	DB	"We should probably move to another spot."
	DB	NEXT
;	DB	'【美緒】：先輩、掘った穴は元に戻していかなきゃ危ないよ。'
	DB	"Mio:  First we have to fill the holes in again, though."
	DB	NEXT
;	DB	'【%001】：ん、そだな。'
	DB	"%001:  Yeah, I guess so."
	DB	NEXT
;	DB	'・・・こうして俺達は夕方まで潮干狩りを続けた。'
	DB	"We kept looking for clams until evening came."
	DB	NEXT
	DB SINARIO,'CS612.OVL',0
	DW	0000H


end
