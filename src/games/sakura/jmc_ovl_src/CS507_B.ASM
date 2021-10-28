;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０７＿Ｂ
;		川　釣りでの冷やかし（清美）

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
NN3:	DB	3,	'KIYOMI',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M7, M9, M10		;話す　清美
S4:		DW	VV3, NN4,  4, M11		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_1'
	DB	BUF,B_COPY01
	T_CG 'CT02','T','K',30,1
;	DB	'新藤さんのいる浅瀬Ｂだ。'
	DB	"I'm in the shallows where Kiyomi is."
	DB	NEXT
;	DB	'【清美】：あら、%001さん。'
	DB	"Kiyomi:  Hello, %001."
	DB G_FLG,G_COPYI,103,1
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
	DB	"%001:  I wonder what kind of fish are in the river?"
	DB	NEXT
;	DB	'【%001】：・・・・・・マグロとかカジキとかいればなぁ・・・。'
	DB	"%001:  Swordfish and flatfish?"
	DB	NEXT
;	DB	'【清美】：%001さん、それは海の魚ですわよ。'
	DB	"Kiyomi:  %001, those are salt-water fish."
	DB	NEXT
;	DB	'【%001】：冗談だって。'
	DB	"%001:  I was kidding."
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

M7:		;話す　清美
;	DB	'【%001】：釣れてる？'
	DB	"%001:  Did you catch anything?"
	DB	NEXT
;	DB	'【清美】：それがその・・・。'
	DB	"Kiyomi:  Nothing."
	DB	NEXT
;	DB	'新藤さんの足元には、もつれにもつれた釣り糸の玉があった。'
	DB	"A massive tangle of fishing line was lying at Kiyomi's"
	DB	CR
	DB	"feet."
	DB	NEXT
;	DB	'【清美】：わたくし、釣りをするのは生まれて初めてのことで・・・。'
	DB	"Kiyomi:  I've never done anything like this before."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  ...I noticed."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M9:		;話す　清美
;	DB	'【清美】：%001さんの方はいかがですか？'
	DB	"Kiyomi:  %001, how about you? Did you catch anything?"
	DB	NEXT
;	DB	'【%001】：誠が頑張ってる。'
	DB	"%001:  Makoto is doing his best."
	DB	NEXT
;	DB	'【清美】：誠さんは、このような野外活動はお手の物でしたわね。'
	DB	"Kiyomi:  Makoto is a very outdoors type of person. He"
	DB	CR
	DB	"should be good at this."
	DB	NEXT
;	DB	'【%001】：うん、でも釣りは好きじゃないみたいだったな。'
	DB	"%001:  Yes, but he doesn't like to fish."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M10:		;話す　清美
;	DB	'【清美】：・・・お魚を捕まえるのはこんなに大変なことだったのですね・・・・・・'
	DB	"Kiyomi:  I never knew that it was so hard to catch a fish."
	DW	0000H

M11:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I head back for the fishing spot where Makoto is."
	DB	NEXT
	DB SINARIO,'CS507_1.OVL',0
	DW	0000H

end
