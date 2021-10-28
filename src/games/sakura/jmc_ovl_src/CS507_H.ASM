;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０７＿Ｈ
;		川　釣りでの冷やかし（恵依美）

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
;NN3:	DB	3,	'恵依美',0
NN3:	DB	3,	'MEIMI',0
;NN4:	DB	4,	'釣り場Ａ',0
NN4:	DB	4,	'FISHING SPOT A',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　川
S2:		DW	VV1, NN2,  2, M6		;見る　空
S3:		DW	VV2, NN3,  3, M7, M9, M10, M10B		;話す　恵依美
S4:		DW	VV3, NN4,  4, M11		;行く　釣り場Ａ


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_09_3'
	DB	BUF,B_COPY01
	T_CG 'CT08','T',0,0,1
;	DB	'中野のいる釣り場Ｃだ。'
	DB	"I'm at the fishing spot where Meimi is."
	DB	NEXT
;	DB	'【恵依美】：あ、%001、釣れてる？'
	DB	"Meimi:  Hi, %001. Did you catch anything?"
	DB G_FLG,G_COPYI,108,1
	DW	0000H

M2:		;見る　川
;	DB	'【%001】：魚がたくさんいるきれいな川だ。'
	DB	"It's a river overflowing with fish."
	DB	PAUSE
;	DB	'・・・多分。'
	DB	".....I think."
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
	DB	"%001:  Pike and mackeral?"
	DB	NEXT
;	DB	'【恵依美】：それって海の魚でしょ？'
	DB	"Meimi:  Those are salt-water fish!"
	DB	NEXT
;	DB	'【%001】：へー、中野でも知ってるんだ。'
	DB	"%001:  Really? You're really smart."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ............................."
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

M7:		;話す　恵依美
;	DB	'【%001】：そっちは釣れてる？'
	DB	"%001:  So are you catching anything?"
	DB	NEXT
;	DB	'【恵依美】：ちっとも。場所が悪いのかな。'
	DB	"Meimi:  Nothing. This spot isn't very good."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M9:		;話す　恵依美
;	DB	'【恵依美】：%001の方はどうなの？'
	DB	"Meimi:  How about you?"
	DB	NEXT
;	DB	'【%001】：誠が頑張ってる。釣れないけど。'
	DB	"%001:  Makoto is doing his best. Nothing so far, though."
	DB	NEXT
;	DB	'【恵依美】：どっかいいポイントないかな？'
	DB	"Meimi:  I wonder if there's a good place to get some"
	DB	CR
	DB	"fish?"
	DB	NEXT
;	DB	'【%001】：見つけたら教えてやるよ。'
	DB	"%001:  If you find one, let us know."
	DB	NEXT
;	DB	'【恵依美】：約束よ！'
	DB	"Meimi:  I promise!"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M10:		;話す　恵依美
;	DB	'【恵依美】：魚が泳いでるのが見えるのに、何で釣れないのかな。'
	DB	"Meimi:  I can see fish down there, but they won't take"
	DB	CR
	DB	"the bait. Why not?"
	DB	NEXT
;	DB	'【%001】：魚の方からも見えてるからじゃねーの？'
	DB	"%001:  They must be able to see us, too."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M10B:		;話す　恵依美
;	DB	'【恵依美】：いっそこの岩で川底をガツーンと・・・'
	DB	"Meimi:  Let's skip rocks at the fish."
	DB	NEXT
;	DB	'【%001】：・・・・・・それは禁じ手だぞ、確か。'
	DB	"%001:  Hmmm...I don't think that'll work, somehow."
	DW	0000H

M11:	;行く　釣り場Ａ
;	DB	'俺は誠のいる釣り場Ａに戻った。'
	DB	"I go back to the fishing spot where Makoto is."
	DB	NEXT
	DB SINARIO,'CS507_1.OVL',0
	DW	0000H

end
