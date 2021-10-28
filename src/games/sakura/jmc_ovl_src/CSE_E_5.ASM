;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ｅ＿５
;		瑠璃Ｈ１
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	-1
MSGTBL:
	DW	M1
COMTBL:
	DW	-1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:
	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ


;イニシャルメッセージ
M1:
	DB	BGM,13
	E_CG B_SUDA,'AE_184'
;	DB	'俺は白水さんの服を一枚一枚脱がせていった。'
	DB	"I started taking off Ruri's clothes slowly, piece by piece."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ..........................."
	DB	NEXT
;	DB	'【瑠璃】：どうしたの。'
	DB	"Ruri:  What's wrong?"
	DB	NEXT
;	DB	'【%001】：いや・・・これ、どうやって外すのか分からなくて・・・'
	DB	"%001:  I'm trying to figure out how to get your bra off."
	DB	NEXT
;	DB	'俺は白水さんのブラを外そうと躍起になってた。'
	DB	"We both tried to undo the clip in the back, but couldn't."
	DB	CR
	DB	"Suddenly we had gone from lovers to actors in a comedy movie."
	DB	NEXT
;	DB	'【瑠璃】：・・・自分で脱ぐわ。'
	DB	"Ruri:  I'll take it off."
	DB	NEXT
;	DB	'【%001】：悪ィ・・・'
	DB	"%001:  Sorry."
	DB	NEXT
;	DB	'【瑠璃】：なぜあやまるの？'
	DB	"Ruri:  Why apologize?"
	DB	NEXT
;	DB	'【%001】：・・・いや・・・何となく悪いよーな気がして・・・'
	DB	"%001:  I don't know."
	DB	NEXT
;	DB	'【瑠璃】：あなたも脱いで・・・'
	DB	"Ruri:  Get naked, %001..."
	DB	NEXT
;	DB	'【%001】：ああ・・・'
	DB	"%001:  Alright."
	DB	NEXT
	DB	SINARIO,'CSE_E_6.OVL',0
	DW	0000H


end
