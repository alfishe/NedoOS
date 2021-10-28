;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０９＿Ｅ
;		林間学校　二日目夜　消えた瑠璃

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
	DB	BGM,21
	B_O	B_FADE
;	DB	'【%001】：・・・ロン！純チャン三色イーペーコー！'
	DB	"It was time to go back."
	DB	NEXT
	BAK_INIT 'AB_16_2'
	DB BUF,B_COPY01
	T_CG 'CT12','T','I',30,1
;	DB	'【今日子】：・・・あ、%001君。瑠璃ちゃん知らない？'
	DB	"Kyoko:  %001, do you know where Ruri is?"
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  Hmm?"
	DB	NEXT
;	DB	'【今日子】：帰って来てないのよ、あの娘・・・'
	DB	"Kyoko:  She isn't around anywhere."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ...................................."
	DB	NEXT
;	DB	'（・・・まさか！？）'
	DB	"....Oh no!"
	DB	BGM,20
	DB	NEXT
	K_CG 'CT12','D',30,2
;	DB	'【今日子】：ちょっと待ちなさい%001君！'
	DB	"Kyoko:  Wait a minute, %001!"
	DB	PAUSE
;	DB	'・・・心当たりがあるのね？'
	DB	" Do you know where she might be?"
	DB	NEXT
;	DB	'【%001】：・・・ああ。'
	DB	"%001:  Yes!"
	DB	NEXT
;	DB	'【今日子】：じゃあ、案内してちょうだい。'
	DB	"Kyoko:  Well, take me there."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"..............................................."
	DB	NEXT
	E_CG B_FADE,'AB_10_2'
;	DB	'【%001】：俺が見た時は、ここにいたんだ。'
	DB	"%001:  She was here when I found her."
	DB	NEXT
;	DB	'【今日子】：・・・・・・いないわね。'
	DB	"Kyoko:  She's not here now."
	DB	NEXT
;	DB	'【%001】：・・・白水さん・・・'
	DB	"%001:  Ruri..."
	DB	NEXT
;	DB	'【今日子】：・・・とにかく、一旦戻りましょう。'
	DB	"Kyoko:  Let's go back to where the others are."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"................................................"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT12','T','I',30,1
;	DB	'【今日子】：・・・・・・と言う訳なの。みんな、悪いけど'
	DB	"Kyoko:  .....And so, that's what happened. I need all of ",CR,"you to help look for her, alright?"
	DB	NEXT
;	DB	'ただし、必ず２人一組で行動する事。'
	DB	"Kyoko:  Make sure you pair up."
	DB	PAUSE
;	DB	'いいわね？'
	DB	" Do you understand?"
	DB	NEXT
;	DB	'【%001】：・・・よし、行くぞ誠！'
	DB	"%001:  Let's go, Makoto!"
	DB	NEXT
	T_CG1 'CT14','F',0,0,3
	DB ANI,A_ON,1
;	DB	'【誠】：ほい来た！'
	DB	"Makoto:  Okay!"
	DB	NEXT
;	DB	'【%001】：とりあえず昼間俺達のいた場所からだ！'
	DB	"%001:  Let's start looking from where we were at lunchtime."
	DB	NEXT
;	DB	'【誠】：根拠は？'
	DB	"Makoto:  Why do you think she'd be there?"
	DB	NEXT
;	DB	'【%001】：ない！'
	DB	"%001:  I don't know!"
	DB	NEXT
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DB	SINARIO,'CS510_01.OVL',0
	DW	0000H


end
