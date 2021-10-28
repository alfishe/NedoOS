;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０７＿Ｃ
;		川　釣りでの冷やかし（美緒）

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
CM2:	DW	VV2,	NN3,-1
CM3:	DW	VV3,	NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'戻る',0
VV3:	DB	3,	'GO BACK',0

;NN1:	DB	1,	'川',0
NN1:	DB	1,	'RIVER',0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	'SKY',0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'MIO',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M7, M9, M10		;話す　美緒
S4:		DW	VV3, NN4,  4, M11		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_3'
	DB	BUF,B_COPY01
	T_CG 'CT03','T',0,0,1
;	DB	'美緒ちゃんのいる釣り場Ｂだ。'
	DB	"I'm at the other fishing spot where Mio is."
	DB	NEXT
;	DB	'【美緒】：あっ、%001先輩！'
	DB	"Mio:  Hello, %001."
	DB G_FLG,G_COPYI,104,1
	DW	0000H

M2:		;見る　川
;	DB	'【%001】：魚がたくさんいるきれいな川だ。'
	DB	"It's a river overflowing with fish."
	DB	PAUSE
;	DB	'・・・多分。'
	DB	"......I think."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　川
;	DB	'昨日の雨で増水してるみたいだ。'
	DB	"The rain yesterday has filled the river up with water."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　川
;	DB	'【%001】：どれどれ、どんな魚がいるのかな・・・・・おっ、よく見るとイワメやニジマスがいるな。'
	DB	"%001:  I wonder what kind of fish are in this river?"
	DB	NEXT
;	DB	'【%001】：・・・・・・サンマとかアジとかいるかな？'
	DB	"%001:  Tuna and mackerel?"
	DB	NEXT
;	DB	'【美緒】：それって海の魚でしょ？'
	DB	"Mio:  Those are sea fish, %001."
	DB	NEXT
;	DB	'【%001】：川をはるばるさかのぼって・・・'
	DB	"%001:  Maybe they swam up the river here, and..."
	DB	NEXT
;	DB	'【美緒】：シャケじゃないんだから・・・。'
	DB	"Mio:  They're not Salmon!"
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;見る　川
;	DB	'できればあまり近づきたくないな。'
	DB	"I don't want to get too close to it."
	DB	NEXT
;	DB	'なぜって・・・・・・泳げねーから。'
	DB	"The reason for that is...I can't swim."
	DW	0000H

M6:		;見る　空
;	DB	'天気もいいし、見渡すかぎり青い空だ。'
	DB	"The weather's fine, and the sky is blue."
	DW	0000H

M7:		;話す　美緒
;	DB	'【%001】：釣れてる？'
	DB	"%001:  Catch anything?"
	DB	NEXT
;	DB	'【美緒】：うん、まあまあかな。'
	DB	"Mio:  A few. Want to see?"
	DB	NEXT
;	DB	'美緒ちゃんのそばのバケツには数匹の魚が泳いでいた。'
	DB	"In Mio's bucket swam a few fish."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M9:		;話す　美緒
;	DB	'【美緒】：%001先輩の方は？'
	DB	"Mio:  How about you, %001?"
	DB	NEXT
;	DB	'【%001】：誠が頑張ってる。'
	DB	"%001:  Makoto is trying hard."
	DB	NEXT
;	DB	'【美緒】：誠先輩、エアーガンで魚取ってるの？'
	DB	"Mio:  Is he shooting the fish with his air gun?"
	DB	NEXT
;	DB	'【%001】：・・・その手があったか・・・'
	DB	"%001:  Hey, that's not a bad idea..."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M10:		;話す　美緒
;	DB	'【美緒】：お魚、後で先輩にも分けてあげるね。'
	DB	"Mio:  I'll share my fish with you later."
	DB	NEXT
;	DB	'【%001】：ありがとう、美緒ちゃん。'
	DB	"%001:  Thanks, Mio."
	DW	0000H

M11:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I head back for the fishing spot where Makoto is."
	DB	NEXT
	DB SINARIO,'CS507_1.OVL',0
	DW	0000H

end
