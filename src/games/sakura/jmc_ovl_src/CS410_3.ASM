;	さくらの季節 
;		シーン　４１０＿３
;		公園

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HsceneCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	 NN1,NN2,NN3,-1
CM2:	DW	VV2,	 NN1,-1
CM3:	DW	VV3,	 NN4,-1
CM4:	DW	VV4,	 -1
CM5:	DW	VV5,	 NN5,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0
;VV3:	DB	3,	'買う',0
VV3:	DB	3,	'BUY',0
;VV4:	DB	4,	'ひなたぼっこ',0
VV4:	DB	4,	'RELAX',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0

;NN1:	DB	1,	'公園',0
NN1:	DB	1,	'PARK',0
;NN2:	DB	2,	'噴水',0
NN2:	DB	2,	'FOUNTAIN',0
;NN3:	DB	3,	'ハト',0
NN3:	DB	3,	'PIGEONS',0
;NN4:	DB	4,	'ハトの餌',0
NN4:	DB	4,	'PIGEON FOOD',0
;NN5:	DB	5,	'外',0
NN5:	DB	5,	'OUTSIDE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　公園
S2:		DW	VV1, NN2,  2, M4		;見る　噴水
S3:		DW	VV1, NN3,  3, M5, M6		;見る　ハト
S4:		DW	VV2, NN1,  4, M7		;考える　公園
S5:		DW	VV3, NN4,  5, M8, M9		;買う　ハトの餌
S6:		DW	VV4, -1,  6, M10		;ひなたぼっこ
S7:		DW	VV5, NN5,  7, M11		;行く　外


;イニシャルメッセージ
M1:
	DB	BGM,17
	BAK_INIT 'AB_45'
	B_P1 B_SUDA
;	DB	'公園にやってきた。'
	DB	"I'm in the park."
	DB G_FLG,G_COPYI,102,1
	DW	 0000H

M2:		;見る　公園
;	DB	'市民公園だ。'
	DB	"This is Citizen's Park."
	DB  NEXT
;	DB	'日差しがポカポカ暖かい。ひなたぼっこをするのにちょうどいい場所だ。'
	DB	"It's a nice warm day. Guess I'll just hang out for a while."
	DB FLG,F_COPYI,1,1
	DW	 0000H

M3:		;見る　公園
;	DB	'「クルックー、クルックー」'
;	DB	'この公園はハトのたまり場になってる。'
	DB	"Pigeons love to gather in the park."
	DB  NEXT
;	DB	'ついでに、ハトのエサ売り場もある。'
	DB	"So of course there are a lot of people selling food for"
	DB	CR
	DB	"the pigeons."
	DB FLG,F_COPYI,1,0
	DW	0000H


M4:		;見る　噴水
;	DB	'恋人同士がよく待ち合わせ場所に使ったりする噴水だ。'
	DB	"Couples meet at the fountain a lot. There are a lot of"
	DB	CR
	DB	"them around."
	DW	0000H

M5:		;見る　ハト
;	DB	'物欲しそうにその辺をつつきながら歩きまわってる。'
	DB	"They're wandering around this way and that, looking hungry."
	DB  NEXT
;	DB	'・・・エサでもやるか。'
	DB	"Guess I'll give them something."
	DW	0000H

M6:		;見る　ハト
;	DB	'俺のやったエサに群がってる。'
	DB	"Several pigeons gather around where I dropped some food."
	DW	0000H


M7:		;考える　公園
;	DB	'【%001】：都会のド真ん中にこんな広い公園があるなんて、今時珍しいんじゃねーか？'
	DB	"It's kind of strange to have a big spread-out park like"
	DB	CR
	DB	"this in the middle of the downtown area."
	DB  NEXT
;	DB	'【%001】：だがここを買収してビルを建てようって話もある。'
	DB	"There's some talk that they're going to close the park"
	DB	CR
	DB	"down, sell the land, and put more buildings here."
	DB  NEXT
;	DB	'【%001】：そしたらここのハトは困るだろうな。'
	DB	"I don't think the pigeons would like that much."
	DW	0000H

M8:		;買う　ハトの餌
;	DB	'俺は売り場のおばあさんに１００円渡してエサを一袋買った。'
	DB	"I buy some pigeon food."
	DB  NEXT
;	DB	'たちまち、俺は無数のハトに囲まれる。'
	DB	"Suddenly there are a million pigeons around me."
	DB  NEXT
;	DB	'【%001】：そう急かすなよ。'
	DB	"%001:  Don't be in such a rush."
	DB  NEXT
;	DB	'【%001】：そらっ！'
	DB	"%001:  There's plenty for everyone."
	DB	FLG,F_COPYI,3,1
	DB	FLG,F_COPYI,5,1
	DW	0000H

M9:		;買う　ハトの餌
;	DB	'（今やったばかりだし、もういいだろ。）'
	DB	"I just fed the pigeons. I'm sure they've had enough."
	DW	0000H

M10:		;ひなたぼっこ
;	DB	'俺は日当たりのいいベンチに腰掛けた。'
	DB	"I sit down on a bench."
	DB  NEXT
;	DB	'５月の太陽が優しく俺を包み込む。'
	DB	"The sun shines on me, warming me."
	DB  NEXT
;	DB	'【%001】：あ～・・・極楽極楽。'
	DB	"%001:  Ah, this is great."
	DW	0000H


M11:		;行く　外
;	DB	'（・・・そろそろ行くか。）'
	DB	"Well, guess I'll go somewhere else."
	DB  NEXT
;	DB	'俺は公園を後にした。'
	DB	"I leave the park."
	DB NEXT
	DB SINARIO,'CS410_1.OVL',0
	DW	0000H

end
