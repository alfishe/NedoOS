;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　星愛１
;		
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:
	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:

;イニシャルメッセージ
M1:
	DB	BGM,13
	E_CG B_FADE,'AE_162'
;	DB	'【星愛】：・・・・・・・・・！'
	DB	"Seia:  ........!!"
	DB	NEXT
;	DB	'吉田の目が、大きく見開かれる。'
	DB	"Seia's eyes fly open."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ..............................."
	DB	NEXT
;	DB	'しばらく吉田は、そのまま硬直していたが・・・'
	DB	"We stayed like that a long time."
	DB	NEXT
;	DB	'【星愛】：・・・ん、んん～っ！'
	DB	"Seia:  ...........Mmmmm!"
	DB	NEXT
;	DB	'どうやら事態を把握したらしく、もがき始めた。'
	DB	"Then she started moving, trying to get away from me."
	DB	NEXT
;	DB	'だが、俺は離さなかった。より強く、吉田の唇を吸う。'
	DB	"But I refused to let her go. I held her lips against mine."
	DB	NEXT
;	DB	'【星愛】：・・・・・・ん・・・・・・'
	DB	"Seia:  ..................Mmmm....."
	DB	NEXT
;	DB	'やがて、吉田は抵抗を止め・・・おずおずと俺の背中に手を回して来た。'
	DB	"Soon, she stopped resisting, and moved to embrace me."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ............................"
	DB	PAUSE
;	DB	'はぁっ・・・・・・・・・'
	DB	"Ah....."
	DB	NEXT
;	DB	'俺がようやく離れると・・・吉田は艶っぽく、熱い吐息を洩らした。'
	DB	"When I finally released her, Seia was blushing, panting"
	DB	CR
	DB	"with hot breath."
	DB	NEXT
;	DB	'【%001】：・・・・・・あ。'
	DB	"%001:  .............Um..."
	DB	NEXT
;	DB	'ようやくぶち切れた理性が繋がった俺は、思わず間抜けな声を洩らしていた。'
	DB	"Having finally recovered my wits, I was surprised at"
	DB	CR
	DB	"hearing my own voice."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ................................"
	DB	NEXT
;	DB	'【%001】：・・・よ、吉田・・・'
	DB	"%001:  ...S- Seia...."
	DB	PAUSE
;	DB	'あの・・・',PAUSE,'その・・・',PAUSE,'えっと・・・'
	DB	"I, um...",PAUSE," I don't know what to say..."
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ............................"
	DB	PAUSE
;	DB	'%001君。'
	DB	"%001."
	DB	NEXT
;	DB	'【%001】：・・・は、はいぃっ！ごめんなさぁいっ！！'
	DB	"%001:  I'm sorry! Please forgive me!"
	DB	NEXT
;	DB	'【星愛】：・・・くす・・・'
	DB	"Seia just smiled."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............."
	DB	PAUSE
;	DB	'え？'
	DB	"What?"
	DB	NEXT
;	DB	'【星愛】：せっかちなんですのね、%001君は・・・'
	DB	"Seia:  You certainly are an impatient person, %001."
	DB	PAUSE
;	DB	'帰り際にして差し上げよう、と思ってましたのに。'
	DB	" I had"
	DB	CR
	DB	"planned to kiss you on our way home, but you couldn't wait."
	DB	NEXT
;	DB	'【%001】：・・・え・・・'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【星愛】：・・・好きです、%001君。'
	DB	"Seia:  .......I love you, %001."
	DB	NEXT
;	DB	'突然といえば突然の告白に、俺は頭の中が真っ白になった。'
	DB	"I had never had anyone tell me something like this before."
;	DB	CR
;	DB	"My face turned white."
	DB	NEXT
;	DB	'【%001】：・・・よ・・・'
	DB	"%001:  ................................"
	DB	NEXT
;	DB	'【%001】：よしだぁあぁぁっ！'
	DB	"%001:  Seia!"
	DB	NEXT
;	DB	'【星愛】：きゃっ！？'
	DB	"Seia:  Wha...?!"
	DB	NEXT
	DB	SINARIO,'CSE_G_2.OVL',0
	DW	0000H


end
