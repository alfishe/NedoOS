;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ａ＿３
;		鈴子Ｈ２

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
	E_CG B_FADE,'AE_133'
;	DB	'【%001】：れ、鈴子さん・・・指入れていい？'
	DB	"%001:  Reiko, can I put my finger inside you?"
	DB	NEXT
;	DB	'【鈴子】：だから、そーゆー事を女の子に聞かないで！'
	DB	"Reiko:  I told you, you're not supposed to ask permission for"
	DB	CR
	DB	"things like that!"
	DB	NEXT
;	DB	'【%001】：それじゃ・・・'
	DB	"%001:  Okay, then...."
	DB	NEXT
;	DB	'ツププ・・・'
	DB	"*SLOOSH*"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・ひっ！？'
	DB	"Reiko:  .................!"
	DB	NEXT
;	DB	'俺は人差し指を鈴子さんの大事な場所に入れた。びちょびちょに濡れてるそこは俺の指を飲み込んで行き、圧迫する。'
	DB	"I put my finger inside Reiko's pussy, watching as her"
	DB	CR
	DB	"folds swallowed it."
	DB	NEXT
;	DB	'【鈴子】：・・・つっ・・・'
	DB	"Reiko:  .......Ow!"
	DB	NEXT
;	DB	'【%001】：あ、悪ィ痛かった！？'
	DB	"%001:  I'm sorry! Did that hurt?"
	DB	NEXT
;	DB	'【鈴子】：もう・・・私初めてなんだから、もっと優しくしてね。'
	DB	"Reiko:  This is my first time, too, so you have to be"
	DB	CR
	DB	"careful."
	DB	NEXT
;	DB	'俺はさらに心を込めて、鈴子さんのあそこに指を出し入れする。'
	DB	"More carefully this time, I put my finger inside her again."
	DB	NEXT
;	DB	'【鈴子】：んっ・・・あっ・・・あんっ・・・'
	DB	"Reiko:  .......Mmm........Oh...."
	DB	NEXT
;	DB	'鈴子さんの呼吸が荒くなり、腰ががくがくと動く。'
	DB	"Reiko's breath became shallow, faster."
	DB	NEXT
;	DB	'【鈴子】：%001君・・・もっとして・・・気持ち、いいの・・・！'
	DB	"Reiko:  %001, do that some more, would you? It feels good."
	DB	NEXT
;	DB	'ぷちゅぷちゅと音を立てる鈴子さんのあそこ、艶めかしく動く鈴子さんのおしり、そしてプルンプルンと揺れる鈴子さんのムネ。'
	DB	"My finger went in and out of her, making a warm, wet"
	DB	CR
	DB	"sound as it moved. Reiko's ass began to move in response"
	DB	CR
	DB	"to my stimulation."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・俺・・・鈴子さんの中に入りたい・・・！'
	DB	"%001:  Reiko....I...I want to go inside you...!"
	DB	NEXT
;	DB	'ズボンを突き破らんばかりに、俺のあれが反応してる。'
	DB	"My cock was hard in my pants and yearning for her."
	DB	NEXT
;	DB	'【鈴子】：・・・いいわ・・・'
	DB	"Reiko:  Okay. I'll let you."
	DB	NEXT
;	DB	'【鈴子】：・・・%001君に、私のバージンをあげる。'
	DB	"Reiko:  I'll give my virgintity to you, %001."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・！'
	DB	"%001:  Reiko.....!!"
	DB	NEXT
	DB	SINARIO,'CSE_A_4.OVL',0
	DW	0000H


END
