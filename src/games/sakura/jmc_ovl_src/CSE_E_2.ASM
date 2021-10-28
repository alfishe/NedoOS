;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　E_E_2
;		瑠璃エンディング２
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:
	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'告白する',0
VV3:	DB	3,	'TELL FEELINGS',0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	'RURI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　瑠璃
S2:		DW	VV2, NN1,  2, M4, M5, M6		;話す　瑠璃
S3:		DW	VV3, -1,  3, M7		;告白する


;イニシャルメッセージ
M1:
	DB	BGM,25
	E_CG B_SUDA,"AB_04_3"
;	DB	'俺は駅のそばに放置されてた自転車を無断で借用して、白水さんのアパートに急いだ。'
	DB	"I borrowed a bicycle that had been left in front of the"
	DB	CR
	DB	"station and went to Ruri's apartment."
	DB	NEXT
;	DB	'「おい、そこの自転車！」'
	DB	"Police:  You on that bicycle!"
	DB	NEXT
;	DB	'【%001】：げ・・・パトカー？'
	DB	"%001:  What? The police?"
	DB	NEXT
;	DB	'「制限速度２０キロオーバーだ！止まりなさい！」'
	DB	"Police:  You, stop immediately!"
	DB	NEXT
;	DB	'【%001】：悪ィけど・・・今の俺は誰にも止められない！'
	DB	"%001:  I'm sorry, but no one can stop me!"
	DB	NEXT
;	DB	'【%001】：ぬぅおおおおおおおおおおおりゃあああああああ！'
	DB	"%001:  Out of my way!!!"
	DB	NEXT
;	DB	'「おっ、おい君！」'
	DB	"Police:  Hey! S- Stop!"
	DB	NEXT
;	DB	'俺はパトカーをぶっちぎった。'
	DB	"I cut the police car off and rode down a narrow street."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・'
	DB	"..................................."
	DB	NEXT
	B_O B_WIPE
;	DB	'がちゃ・・・'
	DB	"*kacha*"
	DB	NEXT
	E_CG B_YOKO,"AE_181"
	DB	BGM,31
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ..................................."
	DB	NEXT
;	DB	'【%001】：よっ。'
	DB	"%001:  .......Hi."
	DB	NEXT
;	DB	'【瑠璃】：・・・！'
	DB	"Ruri:  .......................!!"
	DB C_BLD,C_V_ON,3
	DW	0000H

M2:		;見る　瑠璃
;	DB	'旅行カバンを片手に、たった今家を出ようとしたところだ。'
	DB	"She was carrying a shoulder bag with her. She must have"
	DB	CR
	DB	"been just about to leave."
	DB	NEXT
;	DB	'・・・俺は、間に合った。'
	DB	"I made it in time."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　瑠璃
;	DB	'驚いてる・・・無理もないか。'
	DB	"She's surprised to see me."
	DW	0000H

M4:		;話す　瑠璃
;	DB	'【%001】：こんな時間に、どこに行くつもり？'
	DB	"%001:  Where are you off to so late at night like this?"
	DB	NEXT
;	DB	'【瑠璃】：%001君・・・血が出てる・・・'
	DB	"Ruri:  %001...you're bleeding."
	DB	NEXT
;	DB	'【%001】：ああ、ちょっと自転車でコケたんだ。'
	DB	"%001:  Oh, that. I sort of fell off the bicycle."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　瑠璃
;	DB	'【瑠璃】：入って・・・傷の手当てしないと。'
	DB	"Ruri:  Come in. I'll put a bandage on that for you."
	DB	NEXT
;	DB	'【%001】：いや・・・俺のことはどーだっていい。'
	DB	"%001:  No....don't worry about me."
	DB	NEXT
;	DB	'【%001】：何で俺達を残して一人で帰ったんだ？'
	DB	"%001:  Why did you leave us and come home by yourself?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .........................."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　瑠璃
;	DB	'【瑠璃】：どうして・・・？'
	DB	"Ruri:  Why...?"
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ................................."
	DB	NEXT
;	DB	'【瑠璃】：どうして・・・私のこと放っておいてくれないの！'
	DB	"Ruri:  Why..... Why can't you leave me alone, and let me"
	DB	CR
	DB	"worry about my own problems?"
	DB C_BLD,C_V_OFF,3
	DW	0000H

M7:		;告白する
;	DB	'【%001】：君が・・・好きだから。'
	DB	"%001:  Because I love you."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .................................."
	DB	NEXT
;	DB	'【瑠璃】：・・・私を・・・？'
	DB	"Ruri:  ...Me?"
	DB	NEXT
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・・・・同情なら、要らないわ。'
	DB	"Ruri:  I don't need your sympathy."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ...................................."
	DB	NEXT
;	DB	'【瑠璃】：%001君が本当に好きなのは、あの子でしょう。',CR,'いつも一緒にいる、明るい性格の・・・'
	DB	"Ruri:  The one you really love is...that girl you're"
	DB	CR
	DB	"always hanging around with..."
	DB	NEXT
;	DB	'【%001】：誠は男だぞ。'
	DB	"%001:  Makoto looks like a girl, but he's a guy."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ..................................."
	DB	NEXT
;	DB	'【%001】：鈴子さんも新藤さんも美緒ちゃんも亜希ちゃんも、俺の大事な友達だ。'
	DB	"%001:  Reiko, and Kiyomi, and Mio, and Aki... They're all"
	DB	CR
	DB	"friends, and important to me."
	DB	NEXT
;	DB	'【%001】：だけど・・・俺が好きな女の子は、君なんだ・・・白水さん。'
	DB	"%001:  But you're the one I love. It's you, Ruri."
	DB	NEXT
;	DB	'【%001】：・・・これだけは、言っておきたかったんだ。'
	DB	"%001:  I just wanted you to know it, before it was too"
	DB	CR
	DB	"late."
	DB	NEXT
	DB SINARIO,'CSE_E_3.OVL',0
	DW	0000H


end
