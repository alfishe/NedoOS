;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　ＣＳＥ＿Ｃ＿２
;		ＭＩＯＨ

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


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'【美緒】：・・・いいよ先輩・・・見て・・・'
	DB	"Mio:  .....I'll show you, if that's what you want."
	E_CG B_FADE,'AE_142'
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・・・・・・'
	DB	"%001:  .................................................."
	DB	NEXT
;	DB	'羞恥で全身をピンク色に染めながら、美緒ちゃんはパジャマの裾をたくし上げた。'
	DB	"Her entire body blushing pink from embarrassment, Mio"
	DB	CR
	DB	"lifted her pajama top up. "
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・・・・・・'
	DB	"%001:  .................................................."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・は・・・しぃ・・・'
	DB	"Mio:  .............Do you like it?"
	DB	NEXT
;	DB	'俺の頭に響くドックンドックンって音は、俺の鼓動か、それとも・・・'
	DB	"Blood was thundering in my ears as I looked at the"
	DB	CR
	DB	"willing Mio."
	DB	NEXT
;	DB	'【美緒】：・・・先輩・・・何か言ってよ・・・'
	DB	"Mio:  .....%001. Please say something."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・・・・・・'
	DB	"%001: .................................................."
	DB	NEXT
;	DB	'【美緒】：・・・あたしのムネ、ペチャパイだから・・・つまらないの・・・？'
	DB	"Mio:  .....Do you mind that my breasts are small?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・・・・・・み'
	DB	"%001:  ..................................................M-"
	DB	NEXT
;	DB	'【%001】：美緒ちゃん！'
	DB	"%001:  Mio!"
	DB	NEXT
;	DB	'【美緒】：あっ・・・%001せんぱい・・・'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'俺は本能の赴くまま、美緒ちゃんを求めた。'
	DB	"Driven by some new force, welling up within me, I reached"
	DB	CR
	DB	"for Mio."
	DB	NEXT
	DB	SINARIO,'CSE_C_3.OVL',0
	DW	0000H


end
