;	さくらの季節
;		シーン　４１０＿４
;		デパート内

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:


	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HsceneCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'出る',0
VV2:	DB	2,	'EXIT',0

;NN1:	DB	1,	'売場',0
NN1:	DB	1,	'STORE',0
;NN2:	DB	2,	'客',0
NN2:	DB	2,	'CUSTOMERS',0
;NN3:	DB	3,	'売り物',0
NN3:	DB	3,	'GOODS',0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　売場
S2:		DW	VV1, NN2,  2, M4		;見る　客
S3:		DW	VV1, NN3,  3, M5, M6		;見る　売り物
S4:		DW	VV2, -1,  4, M7		;出る


;イニシャルメッセージ
M1:
	DB BGM,17
	BAK_INIT 'AB_37'
	B_P1 B_YOKO
;	DB	'ゼロワンデパートに来た。'
	DB	"I'm in the Zero One Department Store."
	DB G_FLG,G_COPYI,103,1
	DW	0000H


M2:		;見る　売場
;	DB	'この階は紳士服・婦人服の売り場が並んでる。'
	DB	"On this floor is men & ladies' wear."
	DB FLG,F_COPYI,1,1
	DW	0000H


M3:		;見る　売場
;	DB	'「冬物大処分！」という垂れ幕が下がってる。'
	DB	"There's a banner advertising 'Winter Sales Clearance.'"
	DB	NEXT
;	DB	'もうしばらくすると夏物が現れるだろう。'
	DB	"Guess they'll have the new summer clothes out soon."
	DW	0000H


M4:		;見る　客
;	DB	'ゴールデンウィーク中なので、客の出足は多い。'
	DB	"It's Golden Week, so a lot of people are out shopping."
	DB	NEXT
;	DB	'私服だから分からんが俺くらいの年の客はウチの生徒だろう。'
	DB	"There're a lot of college students here, too. They're not"
	DB	CR
	DB	"wearing their uniforms, so it's hard to tell, though."
	DB	NEXT
;	DB	'しかし・・・女の子って買物するの好きなんだな。'
	DB	"Girls do love to shop, though."
	DW	0000H

M5:		;見る　売り物
;	DB	'おとといは自分の物を買うヒマなかったしな。'
	DB	"I didn't have time to buy what I wanted when I came here"
	DB	CR
	DB	"before."
	DB	NEXT
;	DB	'どれ・・・'
	DB	"What should I buy?"
	DB	NEXT
;	DB	'・・・・・・・・・・・・'
	DB	"........................................."
	DB	NEXT
;	DB	'「残り物に服はなし」、か。新藤さんもうまいこと言うなぁ。'
	DB	"Hmmm. There's nothing I really need, now that I think"
	DB	CR
	DB	"of it."
	DB FLG,F_COPYI,3,1
	DW	0000H

M6:		;見る　売り物
;	DB	'どうせかーちゃんが俺の服をごっそり買い込んでるだろ。'
	DB	"Mom buys all my clothes for me."
	DB	NEXT
;	DB	'自分の小遣いで買うまでもねーや。'
	DB	"I don't need to buy clothes with my own allowance."
	DB C_BLD,C_V_OFF,2	;出る　出し
	DW	0000H


M7:		;出る
;	DB	'（そろそろ出るか・・・）'
	DB	"Guess I'll go back outside."
	DB	NEXT
;	DB	'俺は駅前通りに戻ることにした。'
	DB	"I go back out into the street in front of the station."
	DB NEXT
	DB SINARIO,'CS410_1.OVL',0
	DW	0000H

end
