;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ｅ＿４
;		瑠璃の部屋
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
	DB	BGM,31
	BAK_INIT 'AB_20_2'
	DB BUF,B_COPY01
	T_CG 'CT05','C',0,15,1
;	DB	'【%001】：いてて・・・'
	DB	"%001:  Ouch!"
	DB	NEXT
;	DB	'【瑠璃】：じっとしてて・・・'
	DB	"Ruri:  Hold still, I'm almost finished."
	DB	NEXT
;	DB	'【瑠璃】：終わったわ。安心して、たいした怪我じゃなかったから。'
	DB	"Ruri:  There, it's clean. You'll be fine now."
	DB	NEXT
;	DB	'【%001】：さっきの石の方が重傷かな？'
	DB	"%001:  I'm sure the rock was hurt more than I was."
	DB	NEXT
	K_CG 'CT05','I',15,2
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .............."
	DB	NEXT
;	DB	'【%001】：悪ィ、気にしないでくれ。',CR,'あれは俺が悪い、１２０％俺の自業自得なんだからさ！'
	DB	"%001:  Don't worry about it. It was my fault anyway, for"
	DB	CR
	DB	"hurrying here like that."
	DB	NEXT
;	DB	'【瑠璃】：%001君・・・すごい汗。'
	DB	"Ruri:  %001, you're really sweaty."
	DB	NEXT
;	DB	'【%001】：へっ？'
	DB	"%001:  I am?"
	DB	NEXT
;	DB	'【瑠璃】：シャツまでびしょびしょ・・・'
	DB	"Ruri:  Your shirt's soaked through."
	DB	NEXT
;	DB	'【%001】：ああ、マラソンした後自転車で飛ばしたからな。',CR,'トライアスロンしたようなもんだ。'
	DB	"%001:  Oh, I ran to catch the train, then borrowed a"
	DB	CR
	DB	"bicycle to come here with. It was like a triathalon..."
	DB	NEXT
	K_CG 'CT05','K',15,3
;	DB	'【瑠璃】：・・・%001君、泳げないでしょう？'
	DB	"Ruri:  ...%001, you can't swim, right?"
	DB	NEXT
;	DB	'【%001】：うっ・・・・・・・・・'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【%001】：・・・知ってたのか。俺がカナヅチだってこと、',CR,'そこまで有名なわけ？'
	DB	"%001:  So you know. I had no idea that my athletic failings"
	DB	CR
	DB	"were so famous in the school."
	DB	NEXT
;	DB	'【瑠璃】：ずっと見てたもの。'
	DB	"Ruri:  No... I know because I used to watch you, all the"
	DB	CR
	DB	"time."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ........................"
	DB	NEXT
;	DB	'【瑠璃】：ずっと貴方を見ていたのよ。あの時は、どうしてなのか分からなかったけど・・・'
	DB	"Ruri:  I watched you...but I was never sure why."
	DB	NEXT
;	DB	'【瑠璃】：今の私には分かる。素直な気持ちで言えるわ。'
	DB	"Ruri:  But now I know why. And I can tell you, without"
	DB	CR
	DB	"hiding anymore."
	DB	PAUSE
;	DB	'あなたが・・・すき。'
	DB	" I love you, %001."
	DB	NEXT
;	DB	'【%001】：白水さん・・・！'
	DB	"%001:  Ruri...!"
	DB	NEXT
;	DB	'俺は再び、彼女の細い体を抱き締めた。'
	DB	"I took her frail body into my arms a second time."
	DB	NEXT
	E_CG B_FADE,"AE_183"
;	DB	'【瑠璃】：%001君・・・服・・・脱がして・・・'
	DB	"Ruri:  %001.... My clothes...take them off..."
	DB	NEXT
;	DB	'【%001】：・・・いいの？'
	DB	"%001:  Are you sure?"
	DB	NEXT
;	DB	'【瑠璃】：もっともっと貴方を知りたいの・・・'
	DB	"Ruri:  I want to be closer to you. I want to know"
	DB	CR
	DB	"everything about you."
	DB	NEXT
;	DB	'【%001】：俺も・・・もっと白水さんのことを知りたい。'
	DB	"%001:  I know... I know how you feel. I want to know"
	DB	CR
	DB	"about you, too, Ruri."
	DB	NEXT
	DB	SINARIO,'CSE_E_5.OVL',0
	DW	0000H


end
