;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０８＿Ｆ
;		亜希とボート

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'亜希',0
NN1:	DB	1,	"AKI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV2, NN1,  1, M2, M3, M4, M5		;話す　亜希
S2:		DW	VV1, NN1,  2, M6, M7, M8		;話す　亜希


;イニシャルメッセージ
M1:
	DB	BGM,2
	BAK_INIT 'AB_41'
	DB	BUF,B_COPY01
	T_CG 'CT06','M','K',0,1
;	DB	'【亜希】：%001せんぱ～い！'
	DB	"Aki:  %001!"
	DB	NEXT
;	DB	'【%001】：えっ・・・？'
	DB	"%001:  Eh....?"
	DB	NEXT
;	DB	'【亜希】：これ、%001先輩のボートでしょ？'
	DB	"Aki:  This is your boat, isn't it, %001?"
	DB	NEXT
;	DB	'亜希ちゃんは、俺達の乗って来たボートのロープを掴んでいた。'
	DB	"Aki was holding the our boat's rope in her hand."
	DB	NEXT
;	DB	'【亜希】：波にさらわれてたのを、あたしが拾ってあげたのよ。'
	DB	"Aki:  It was swept away by a wave, and I picked it up"
	DB	CR
	DB	"for you."
	DB	NEXT
;	DB	'【%001】：サ、サンキュ、助かったよ！'
	DB	"%001:  Thanks!"
	DW	0000H

M2:		;話す　亜希
;	DB	'【%001】：・・・・・・それはそれとして、亜希ちゃんは何してんだ？'
	DB	"%001:  What are you doing here, anyway?"
	DB	NEXT
;	DB	'【亜希】：あ、あたし？！'
	DB	"Aki:  M- Me?"
	DB	NEXT
;	DB	'【清美】：確か、先程は用事があるとおっしゃってませんでしたか？'
	DB	"Kiyomi:  That's right, didn't you say that you had"
	DB	CR
	DB	"something to do a little while ago?"
	DB	NEXT
;	DB	'【亜希】：えっと・・・・・・・・・',CR,PAUSE,'そう！夏休みの自由研究のために、ザリガニの生態を調査しようかな、なんて・・・。'
	DB	"Aki:  Um...",CR,PAUSE
	DB	"That's right! For extra credit, I'm doing a behavioral"
	DB	CR
	DB	"study on crawfish, yeah..."
	DB	NEXT
;	DB	'【清美】：ザリガニがいるのは渓流や沼や田んぼですわよ。',CR,'海にザリガニはいませんわ。'
	DB	"Kiyomi:  Crawfish are found in streams, swamps, and rice"
	DB	CR
	DB	"fields. They don't live in the ocean."
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ........."
	DB	NEXT
;	DB	'【今日子】：亜希ちゃ～ん！'
	DB	"Kyoko:  Aki!"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT06','M',0,0,2
	T_CG 'CT12','M',0,40,3
	DB	ANI,A_ON,2
;	DB	'今日子先生が、ボートをひいてやって来た。'
	DB	"Kyoko-sensei came up, pulling their own boat."
	DB	NEXT
;	DB	'【亜希】：げ！'
	DB	"Aki:  Ack!"
	DB	NEXT
;	DB	'【今日子】：あら、あなた達も来てたの？'
	DB	"Kyoko:  Oh, you two are here, too?"
	DB	NEXT
;	DB	'【清美】：今日子先生もいらっしゃったのですか？'
	DB	"Kiyomi:  Kyoko-sensei, you're here?"
	DB	NEXT
;	DB	'【今日子】：そうよ～、この子に頼まれて・・・'
	DB	"Kyoko:  Yes, Aki asked me to come along."
	DB	NEXT
;	DB	'【亜希】：あ～、ストップストォップ！！'
	DB	"Aki:  No, Sensei! Stop!"
	DB	NEXT
;	DB	'亜希ちゃんは、今日子先生の口を手で押さえつけた。'
	DB	"Aki put her hand over Kyoko-sensei's mouth."
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,1
	DW	0000H


M3:		;話す　亜希
;	DB	'【清美】：・・・何か隠していらっしゃいますわね。'
	DB	"Kiyomi:  You're hiding something."
	DB	NEXT
;	DB	'【亜希】：べっ・・・・・・別にぃ。'
	DB	"Aki:  N- No, I'm not."
	DB	NEXT
;	DB	'【清美】：ズバリ・・・あなた、カナヅチですわね！？'
	DB	"Kiyomi:  Admit it! You can't swim, can you?"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT06','M','D',0,4
	T_CG 'CT12','M',0,40,3
	DB	ANI,A_ON,4
;	DB	'【亜希】：ばっばっばっ、馬鹿言わないでよ！このスポーツ万能のあたしが、泳げないだなんて、そんなのあるわけないじゃない！'
	DB	"Aki:  W- What are you talking about? What does this"
	DB	CR
	DB	"have to do with me not being able to swim?"
	DB	NEXT
;	DB	'【清美】：では、何を今日子先生に頼んだのですか？'
	DB	"Kiyomi:  Well, what did you ask Kyoko-sensei to come ",CR,"here, for?"
	DB	NEXT
;	DB	'【亜希】：そっ・・・それは・・・'
	DB	"Aki:  Oh, well...."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;話す　亜希
;	DB	'【亜希】：・・・そうよ、あたしはカナヅチよ！悪かったわね！'
	DB	"Aki:  Fine, okay? So I can't swim!"
	DB	NEXT
;	DB	'【清美】：別に悪いとは申しておりませんわよ。%001さんもカナヅチでいらっしゃいますもの。'
	DB	"Kiyomi:  I didn't say it was a bad thing. %001 can't"
	DB	CR
	DB	"swim either."
	DB	NEXT
;	DB	'【%001】：そか・・・亜希ちゃんも、俺と同じカナヅチだったんだ。'
	DB	"%001:  Oh yeah, you and I, Aki, we both can't swim."
	DB	NEXT
;	DB	'【亜希】：%001先輩よりはマシよ。５メートルなら泳げるもん。'
	DB	"Aki:  I'm not as bad as you. I could swim about 5 meters"
	DB	CR
	DB	"if I had to."
	DB	NEXT
;	DB	'【%001】：あ・・・そ。'
	DB	"%001:  Oh, I see."
	DB	NEXT
;	DB	'【今日子】：ま、そーゆーわけであたしがコーチ役をやらされてるってわけ。'
	DB	"Kyoko:  Right, so...she made me be her coach."
	DB	FLG,F_COPYI,1,3
	DB	FLG,F_COPYI,2,2
	DW	0000H


M5:		;話す　亜希
;	DB	'【%001】：用事ってのはこのことだったんだな。'
	DB	"%001:  So that's what you were talking about before."
	DB	NEXT
;	DB	'【亜希】：そうよ、絶っっっっ対に今日中に泳げるようになってやるんだから。'
	DB	"Aki:  Yes. I absolutely have to learn how to swim today."
	DB	NEXT
;	DB	'【清美】：今日中、ですか？'
	DB	"Kiyomi:  It has to be today, did it?"
	DB	NEXT
;	DB	'【亜希】：これは勝負なのよ！美緒とあたし、どっちが先に泳げるようになるか！'
	DB	"Aki:  It's a bet! Mio and I are going to see who can"
	DB	CR
	DB	"learn to swim first!"
	DB	NEXT
;	DB	'【%001】：勝負・・・って、美緒ちゃんはその勝負、受けて立ったのか？'
;	DB	"%001:  So, have you agreed with Mio about this bet?"
;	DB	NEXT
;	DB	'【亜希】：・・・とにかく、美緒には負けないんだから！'
	DB	"Aki:  I won't lose to Mio!"
	DB	NEXT
;	DB	'【亜希】：さ、特訓の続きよ先生！'
	DB	"Aki:  Okay, Sensei, let's get back to training!"
	DB	NEXT
;	DB	'【今日子】：はいはい。'
	DB	"Kyoko:  Whatever you say."
	DB	NEXT
;	DB	'【%001】：特訓の邪魔しちゃ悪いから帰ろう、新藤さん。'
	DB	"%001:  Well, let's go back so we don't interfere with"
	DB	CR
	DB	"the training."
	DB	NEXT
;	DB	'【清美】：・・・そうですわね。'
	DB	"Kiyomi:  I suppose so."
	DB	NEXT
;	DB	'【%001】：・・・どした？元気ねーな。'
	DB	"%001:  What's up? You alright?"
	DB	NEXT
;	DB	'【清美】：何でもありません。少し疲れただけですわ。'
	DB	"Kiyomi:  It's nothing. I'm just a bit tired."
	DB	NEXT
;	DB	'【%001】：そか。'
	DB	"%001:  Oh."
	DB	NEXT
	B_O B_SUDA
;	DB	'俺達は浜に戻った。'
	DB	"We returned to the beach."
	DB	NEXT
	DB SINARIO,'CS609.OVL',0
	DW	0000H

M6:		;見る　亜希
;	DB	'よかった、亜希ちゃんのおかげで助かった。'
	DB	"What a relief that Aki saved us."
	DW	0000H

M7:		;見る　亜希
;	DB	'何を慌ててるんだ？'
	DB	"What was she talking about?"
	DW	0000H

M8:		;見る　亜希
;	DB	'そーか・・・亜紀ちゃんもカナヅチだったんだ。'
	DB	"So....Aki can't swim at all either."
	DB	NEXT
;	DB	'・・・なんとなく親近感。'
	DB	"....I feel a sort of kinship there."
	DW	0000H


end
