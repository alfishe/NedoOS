;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０７＿Ｄ
;		川　釣りでの冷やかし（祥子）

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
NN3:	DB	3,	'SHOKO',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M7, M8, M9		;話す　祥子
S4:		DW	VV3, NN4,  4, M11		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_1'
	DB	BUF,B_COPY01
	T_CG 'CT04','T',0,10,1
;	DB	'西野さんのいる浅瀬Ｃだ。'
	DB	"I'm in the shallows where Shoko is."
	DB	NEXT
;	DB	'【祥子】：あ！しゅ～君だぁ！'
	DB	"Shoko:  Oh, %001!"
	DB G_FLG,G_COPYI,105,1
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
;	DB	'【%001】：・・・・・・マグロとかカジキとかいればなぁ・・・。'
	DB	"%001:  Tuna and swordfish?"
	DB	NEXT
;	DB	'【祥子】：しゅ～君、サバ味噌好き？'
	DB	"Shoko:  Oh, %001, you're so silly!"
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

M7:		;話す　祥子
;	DB	'【%001】：・・・どう？釣れてる？'
	DB	"%001:  Catch anything?"
	DB	NEXT
;	DB	'【祥子】：しゅ～君が釣れたぁ、みたいな～。'
	DB	"Shoko:  I caught you!"
	DB	NEXT
;	DB	'【%001】：・・・おいおい・・・'
	DB	"%001:  Hey, cut it out!"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;話す　祥子
;	DB	'【祥子】：・・・えいっ！'
	DB	"Shoko:  Ha!"
	DB	NEXT
;	DB	'【%001】：うわっ・・・！'
	DB	"%001:  Woah!"
	DB	NEXT
	DB	GATA,5
;	DB	'俺は西野さんに突き飛ばされて、危うく川に落っこちそうになった。'
	DB	"Suddenly Shoko pushed me, and I almost fell into the"
	DB	CR
	DB	"river."
	DB	NEXT
;	DB	'【%001】：こっこっこっこ・・・！'
	DB	"%001:  Don't do that! I'm scared of water!"
	DB	NEXT
;	DB	'【祥子】：ニワトリのまね？'
	DB	"Shoko:  Don't be such a chicken."
	DB	NEXT
;	DB	'【%001】：こっ殺す気かァーーーーッ！'
	DB	"%001:  Are you trying to kill me or something?"
	DB	NEXT
	DB	ANI,A_OFF
	K_CG 'CT04','I',10,1
;	DB	'【祥子】：そんな・・・怒鳴らなくたって・・・'
	DB	"Shoko:  Well, you don't have to shout at me!"
	DB	NEXT
;	DB	'【%001】：・・・泣きたいのはこっちなんだけど・・・'
	DB	"%001:  You're such a bimbo!"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M9:		;話す　祥子
;	DB	'【祥子】：せっかくびしょ濡れになったしゅー君を、肌であっためたげよーと思ったのにぃ～・・・'
	DB	"Shoko:  I just wanted to warm you up..."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ..................."
	DB	NEXT
;	DB	'（とっととここから消えた方が良さそうだ。）'
	DB	"Maybe it's time to get out of here."
	DW	0000H


M11:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I'm back at the fishing spot where Makoto is."
	DB	NEXT
	DB SINARIO,'CS507_1.OVL',0
	DW	0000H


end
