;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　CSE_C_3
;		美緒Ｈ２
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'愛撫',0
VV1:	DB	1,	'CARESS',0
;VV2:	DB	2,	'入れる',0
VV2:	DB	2,	'ENTER',0

;NN1:	DB	1,	'ムネ',0
NN1:	DB	1,	'BREASTS',0
;NN2:	DB	2,	'秘密の花園',0
NN2:	DB	2,	'SECRET GARDEN',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;愛撫　ムネ
S2:		DW	VV1, NN2,  2, M5, M6		;愛撫　秘密の花園
S3:		DW	VV2, -1,  3, M7		;入れる


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'【美緒】：きゃん！'
	DB	"Mio:  What are you...?"
	E_CG B_WIPE,'AE_143'
	DB	NEXT
;	DB	'俺は美緒ちゃんのパジャマを剥ぎ取るように脱がし、押し倒した。'
	DB	"Nearly ripping her pajamas off, I laid Mio back."
	DW	0000H

M2:		;愛撫　ムネ
;	DB	'【%001】：美緒ちゃん・・・！'
	DB	"%001:  Mio...!"
	DB	NEXT
;	DB	'まだ堅さの残る青い果実を、もみほぐす様にして愛撫する。'
	DB	"I gently pet her breasts, which were still hard to the touch."
	DB	NEXT
;	DB	'【美緒】：いっ・・・いたいよ・・・！'
	DB	"Mio:  Th- That hurts...!"
	DB	FLG,F_COPYI,1,1
	DW	0000H


M3:		;愛撫　ムネ
;	DB	'桜色をしたムネの突起を、指でつまむ様に刺激する。'
	DB	"I gently pinched her sakura-colored nipples."
	DB	NEXT
;	DB	'【美緒】：・・・あっ・・・？'
	DB	"Mio:  Ah....ahhh..."
	DB	NEXT
;	DB	'俺の指が動く度、そこは段々堅さを帯びてきた。'
	DB	"With each movement of my finger, her nipples grew harder."
	DB	FLG,F_COPYI,1,2
	DW	0000H


M4:		;愛撫　ムネ
;	DB	'ツンと上を向いた可愛らしい乳首を口に含み、舌でこねくる様に愛撫する。'
	DB	"I put her fully errect nipple in my mouth and stimulated"
	DB	CR
	DB	"it with my tongue."
	DB	NEXT
;	DB	'【美緒】：あっ！何か・・・変な感じ・・・！'
	DB	"Mio:  Ahhh!  That feels so strange...!"
	DW	0000H


M5:		;愛撫　秘密の花園
;	DB	'美緒ちゃんの足をつかんで、むりやり開かせる。'
	DB	"I took hold of Mio's legs and forced them open."
	DB	NEXT
;	DB	'【美緒】：いや・・・！'
	DB	"Mio:  No, wait...!"
	DB	NEXT
;	DB	'（う～ん・・・今日子先生のと、全然違うような気がする・・・。）'
	DB	"Wow, her pussy is a lot different from Kyoko-sensei's..."
	DB	NEXT
;	DB	'【美緒】：いや・・・みないでぇ！'
	DB	"Mio:  No, don't look at me!"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;愛撫　秘密の花園
;	DB	'美緒ちゃんの未開発な谷間に、ねじ込むように舌を入れる。'
	DB	"I thrust my tongue into her slit, tasting her juices."
	DB	NEXT
;	DB	'【美緒】：いやぁ・・・そんなとこ、汚いよぉ！'
	DB	"Mio:  No, don't! That's....dirty!"
	DB	NEXT
;	DB	'【%001】：美緒ちゃんの体に、汚いところなんかないよ。'
	DB	"%001:  There isn't a dirty place on your body, Mio."
	DW	0000H

M7:		;入れる
;	DB	'（も・・・もうガマン出来ない！）'
	DB	"I...I can't hold it anymore!"
	DB	NEXT
;	DB	'俺は熱くたぎる自分自信を握ると、固く閉じた美緒ちゃんの裂け目に突き入れた。'
	DB	"Taking my hot, pulsing cock in my hand, I thrust it into"
	DB	CR
	DB	"the close folds of Mio's pussy."
	DB	NEXT
	DB	SINARIO,'CSE_C_4.OVL',0
	DW	0000H


end
