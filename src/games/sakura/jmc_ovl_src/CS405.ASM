;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０５
;		亜希、襲来

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

;NN1:	DB	1,	'女の子',0
NN1:	DB	1,	"WOMAN",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　女の子
S2:		DW	VV2, NN1,  2, M4, M5, M6		;話す　女の子


;イニシャルメッセージ
M1:
	DB	BGM,7
	E_CG B_YOKO,'AE_015'
;	DB	'振り返ると、階段の上でふんぞり返って俺を睨みつけている変な女がいた。'
	DB	"I turned around, and saw a pretty young woman above me on"
	DB	CR
	DB	"the steps, glaring at me haughtily." 
	DB	NEXT
;	DB	'【？】：あなたが山神　%001ね。'
	DB	"???:  You're %001 Yamagami, aren't you?"
	DB	NEXT
;	DB	'【%001】：そうだけど・・・'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【？】：ふ～ん・・・あなたがねえ。'
	DB	"???:  I see. So it's you."
	DB	NEXT
;	DB	'彼女は俺を値踏みするかのようにじろじろと見た。'
	DB	"She seemed to be appraising me as she looked at me."
	DW	0000H

M2:		;見る　女の子
;	DB	'・・・見覚えはない。'
	DB	"Who is she? I don't think I know her."
	DB	NEXT
;	DB	'彼女も新藤さんみたいに俺を一方的に知ってるクチか？'
	DB	"I guess she knows me from somewhere, like Kiyomi."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　女の子
;	DB	'あ・・・パンツ見えてる・・・'
	DB	"Oh, I can see her panties..."
	DW	0000H

M4:		;話す　女の子
;	DB	'【%001】：えっと・・・君は？'
	DB	"%001:  Um, who are you...?"
	DB	NEXT
;	DB	'【？】：あなた、このあたしを知らないっての！？'
	DB	"???:  What, you don't know who I am?"
	DB	NEXT
;	DB	'【%001】：わ、悪ィ。'
	DB	"%001:  Uh, sorry."
	DB	NEXT
;	DB	'眉間にしわを寄せて怒る彼女の剣幕に、俺は思わず謝ってしまった。'
	DB	"She frowned and gave me an angry look."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　女の子
;	DB	'【？】：あなた、ウチの高等部の一年でしょ。なのにあたしのこと知らないの？'
	DB	"???:  Are you serious? You really don't know who I am?"
	DB	NEXT
;	DB	'【%001】：あ・・・、うん。'
	DB	"%001:  Um, that's right."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　女の子
;	DB	'【？】：高校テニス界の超新星と呼ばれるあたしを知らないなんて、あなた、モグリね。'
	DB	"???:  You're pretty clueless if you don't know that I'm"
	DB	CR
	DB	"the newest star on the horizon of the tennis world."
	DB	NEXT
;	DB	'【%001】：ってことは、君はテニス部なんだ。'
	DB	"%001:  So you're in the tennis club...?"
	DB	NEXT
;	DB	'・・・ってことは、美緒ちゃんの友達かな？'
	DB	"(Maybe she's a friend of Mio's...?)"
	DB	NEXT
;	DB	'【？】：あったりまえじゃない！どこの世界に',CR,'「高校テニス界の超新星」って呼ばれる茶道部員がいるのよ！'
	DB	"???:  Well, isn't that obvious?! Why in the world would"
	DB	CR
	DB	"a member of the tea ceremony club call herself a 'star of"
	DB	CR
	DB	"the tennis world'?"
	DB	NEXT
;	DB	'【%001】：わからんぞ。世界ってのは、意外と広いんだぜ。'
	DB	"%001:  What do I know? The world is pretty big, isn't it?"
	DB	NEXT
;	DB	'【？】：あなた・・・あたしをおちょくってるわね！'
	DB	"???:  You...you're mocking me!"
	DB	NEXT
;	DB	'【%001】：そんなつもりはないが。'
	DB	"%001:  Well, I didn't mean to."
	DB	NEXT
	DB SINARIO,'CS406.OVL',0
	DW	0000H


end
