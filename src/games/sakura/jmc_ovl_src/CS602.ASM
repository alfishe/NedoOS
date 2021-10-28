;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０２
;		海　初日

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	"REIKO",0
;NN2:	DB	2,	'海',0
NN2:	DB	2,	"OCEAN",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　鈴子
S2:		DW	VV1, NN2,  2, M5		;見る　海
S3:		DW	VV2, NN1,  3, M6, M7, M8		;話す　鈴子


;イニシャルメッセージ
M1:
	DB	BGM,2
	BAK_INIT 'AB_17_1'
	B_P1 B_WIPE
	DB BUF,B_COPY01
;	DB	'・・・そしてあっという間に、臨海学校当日。'
	DB	".......Before I even knew it, it was the first day of"
	DB	CR
	DB	"seaside camp."
	DB	NEXT
;	DB	'【%001】：ああ・・・空が青いなぁ・・・'
	DB	"%001:  Wow...the sky is so blue..."
	DB	NEXT
;	DB	'【%001】：・・・はぁ・・・'
	DB	"%001:  Ahhhh..."
	DB	NEXT
	T_CG 'CT01','M',0,15,1
;	DB	'【鈴子】：どうしたの、しんきくさい声出して。'
	DB	"Reiko:  What's up, you sound bored."
	DB	NEXT
;	DB	'【%001】：だって・・・'
	DB	"%001:  Umm..."
	DB	NEXT
;	DB	'【鈴子】：安心しなさい、すぐ泳げるようにして上げるから。'
	DB	"Reiko:  Don't worry. I'll teach you to swim in no time."
	DW	0000H

M2:		;見る　鈴子
;	DB	'いつもの競泳用の水着だけど、海辺で見ると何となく雰囲気が違うよーな気がする。'
	DB	"It's the same swimsuit she always uses for swimming"
	DB	CR
	DB	"competitions, but it looks better on her out here."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　鈴子
;	DB	'・・・鈴子さん、はりきってるな・・・俺のために。'
	DB	"Reiko sure is being friendly."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　鈴子
;	DB	'・・・「泳げるようにしてあげる」とか言ってるけど・・・'
	DB	"She says she's going to teach me to swim."
	DB	NEXT
;	DB	'・・・・・・逃げたい・・・・・・'
	DB	"I want to escape."
	DW	0000H

M5:		;見る　海
;	DB	'青い空、白い雲。そして、穏やかな海。'
	DB	"Blue sky, white clouds, and a calm sea."
	DB	NEXT
;	DB	'観賞用としては一級品だよな。'
	DB	"It certainly is a change from the city."
	DW	0000H

M6:		;話す　鈴子
;	DB	'【鈴子】：それじゃさっそく行くわよ！'
	DB	"Reiko:  Okay, let's go!"
	DB	NEXT
;	DB	'鈴子さんは俺の手をつかんで海の方に連れて行こうとする。'
	DB	"Reiko took my hand and started pulling me towards the ocean."
	DB	NEXT
;	DB	'【%001】：れ、鈴子さん！俺準備体操しなきゃ！'
	DB	"%001:  R- Reiko! I have to do some warm-up exercises first,",CR,"don't I?"
	DB	NEXT
;	DB	'【鈴子】：３０分もやれば十分でしょ、もう。'
	DB	"Reiko:  Trust me, you'll be fine."
	DB	NEXT
;	DB	'【%001】：まままだ心の準備がぁ・・・'
	DB	"%001:  B- But my heart isn't ready yet..."
	DB	NEXT
;	DB	'【鈴子】：まだそんな事言ってるの？'
	DB	"Reiko:  Are you really that worried?"
	DB	NEXT
;	DB	'【鈴子】：未来のオリンピック候補が教えるんだから、大船に乗ったつもりでいなさいよ。'
	DB	"Reiko:  A candidate for the next Olympics is teaching you,"
	DB	CR
	DB	"so just pretend you're going on a big boat."
	DB	FLG,F_COPYI,3,1
	DW	0000H


M7:		;話す　鈴子
;	DB	'【%001】：俺、やっぱり・・・'
	DB	"%001:  Actually, I don't think I'm ready for this..."
	DB	NEXT
	K_CG 'CT01','I',15,2
;	DB	'【鈴子】：%001君、私のこと信じてくれないの？'
	DB	"Reiko:  %001, don't you trust me?"
	DB	NEXT
;	DB	'鈴子さんが真摯な瞳で俺を見つめる・・・。'
	DB	"%001:  ................"
	DB	FLG,F_COPYI,3,2
	DW	0000H


M8:		;話す　鈴子
;	DB	'【%001】：わかったよぉ・・・'
	DB	"%001:  Alright, let's go."
	DB	NEXT
	K_CG 'CT01','K',15,3
;	DB	'【鈴子】：よし！'
	DB	"Reiko:  All right!"
	DB	NEXT
	B_O B_SUDA
	DB SINARIO,'CS603.OVL',0
	DW	0000H


end
