;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０５
;		初日夜

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
	DB	BGM,2
	BAK_INIT 'AB_17_2'
	DB	BUF,B_COPY01
	TU_CG 'CT02','F',0,25,1
	T_CG 'CT01','F',0,0,2
	DB	ANI,A_ON,1
;	DB	'【清美】：・・・それで、成果はありましたの？'
	DB	"Kiyomi:  ...So, how did it go?"
	DB	NEXT
	T_CG1 'CT01','F','V',0,3
	DB	ANI,A_ON,1
;	DB	'【鈴子】：あははは・・・少し水に慣れたってとこかしら。'
	DB	"Reiko:  Ahem...well, I think he's gotten used to the water."
	DB	NEXT
;	DB	'【%001】：やっぱ才能ねーんだ、俺・・・'
	DB	"%001:  I definitely have no talent for swimming whatsoever."
	DB	NEXT
;	DB	'【清美】：そんなにがっかりなさることありませんわ。'
	DB	"Kiyomi:  You shouldn't be so disappointed."
	DB	NEXT
;	DB	'【清美】：この世界には、泳げないお魚さんだっていらっしゃいますもの。ましてや人間の%001さんが泳げなくても、おかしいことはありませんわ。'
	DB	"Kiyomi:  They say that there is a fish that cannot swim."
	DB	CR
	DB	"So if a human like %001 can't swim, then that isn't odd at"
	DB	CR
	DB	"all."
	DB	NEXT
;	DB	'【%001】：それって・・・俺はムツゴロウとかと同類だってこと？'
	DB	"%001:  That doesn't make me feel any better."
	DB	NEXT
	T_CG1 'CT01','F',0,0,2
	DB	ANI,A_ON,1
;	DB	'【鈴子】：確かにね・・・人間って本能で泳ぎを知ってるって言うけど、%001君って泳ぐ本能が退化してるのかも。'
	DB	"Reiko:  Yes, they say that humans instinctually know"
	DB	CR
	DB	"how to swim, but %001 seems to have lost that instinct."
	DB	NEXT
;	DB	'【%001】：・・・俺って一体何？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【清美】：その代わり、他のスポーツは何でもこなせるのですから、差し引きでは得をなさっているのではないでしょうか。'
	DB	"Kiyomi:  Well, %001 does all other sports well, so maybe"
	DB	CR
	DB	"that's why his ability to swim was taken away."
	DB	NEXT
	T_CG1 'CT14','F',0,40,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,1
;	DB	'【誠】：%001～。ちょっとこっち来てくれよ。'
	DB	"Makoto:  %001:  Come over here a minute."
	DB	NEXT
;	DB	'誠が俺を手招きしてる。'
	DB	"Makoto was waving me over."
	DB	NEXT
;	DB	'【%001】：何だ？'
	DB	"%001:  What is it?"
	DB	NEXT
;	DB	'誠は俺の背中を押して、物陰に連れ込んだ。'
	DB	"Makoto pulled me to one side."
	DB	NEXT
	B_O B_YOKO
	DB	BUF,B_COPY01
	T_CG 'CT14','F','K',0,5
;	DB	'【誠】：%001。男子生徒一同を代表して、お前にお礼を言いたい。ありがとう！'
	DB	"Makoto:  %001. As representative of all the guys, I'd like"
	DB	CR
	DB	"to thank you."
	DB	NEXT
;	DB	'【%001】：はぁ？'
	DB	"%001:  Eh?"
	DB	NEXT
;	DB	'【誠】：お前のカナヅチも、役に立つんだなあ。'
	DB	"Makoto:  Your little prank sure worked great."
	DB	NEXT
;	DB	'【誠】：どうだった？間近で鈴子さんのムネを見た感想は！'
	DB	"Makoto:  How was it to see Reiko's tits up close?"
	DB	NEXT
;	DB	'【%001】：おっ・・・・・・・・・お前、見てたの？'
	DB	"%001:  Oh, you were watching?"
	DB	NEXT
;	DB	'【誠】：あれだけ騒いで何言ってんだよ。注目の的だったんだぞ、お前ら。'
	DB	"Makoto:  You were making such a racket that it was hard"
	DB	CR
	DB	"not to notice you guys."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・'
	DB	"%001:  ..............................."
	DB	NEXT
;	DB	'（ご・・・・・・ごめん鈴子さん！）'
	DB	"(Oops......sorry, Reiko!)"
	DB	NEXT
;	DB	'【誠】：しかもどさくさにまぎれて鈴子さんに「ぱふぱふ」してもらいやがって、うらやましい奴ぅ。'
	DB	"Makoto:  Yeah, and the way you took advantage of the"
	DB	CR
	DB	"confusion to pull her bathing suit top down! You're a"
	DB	CR
	DB	"genius!"
	DB	NEXT
;	DB	'【%001】：お、俺はそんなつもりじゃ・・・！'
	DB	"%001:  No, I didn't do it on purpose!"
	DB	NEXT
	B_P1 B_SUDA
	E_CG B_FADE,'AB_17_3'
;	DB	'・・・こうして誠たちの質問攻めにあいながら、臨海学校初日の夜は',CR,'ふけていったのだった。'
	DB	"So late into the night on the first day of seaside camp,"
	DB	CR
	DB	"there I was, fielding questions from Makoto and the"
	DB	CR
	DB	"other guys."
	DB	NEXT
	B_O B_FADE
	DB	SINARIO,'CS606.OVL',0
	DW	0000H


end
