;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　亜希２
;		
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:
	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	NN3,-1
CM4:	DW	VV4,	NN4,-1

;VV1:	DB	1,	'話す',0
VV1:	DB	1,	'TALK',0
;VV2:	DB	2,	'揉む',0
VV2:	DB	2,	'MASSAGE',0
;VV3:	DB	3,	'触る',0
VV3:	DB	3,	'TOUCH',0
;VV4:	DB	4,	'キスする',0
VV4:	DB	4,	'KISS',0

;NN1:	DB	1,	'亜希',0
NN1:	DB	1,	'AKI',0
;NN2:	DB	2,	'胸',0
NN2:	DB	2,	'BREASTS',0
;NN3:	DB	3,	'触る',0
NN3:	DB	3,	'PUSSY',0
;NN4:	DB	4,	'首筋',0
NN4:	DB	4,	'NECK',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;話す　亜希１
S2:		DW	VV2, NN2,  2, M3, M4, M5, M6, M7		;揉む　胸５
S3:		DW	VV3, NN3,  3, M8, M9, M10, M11		;触る　○○○○４
S4:		DW	VV4, NN4,  4, M12, M13		;キスする　首筋２


;イニシャルメッセージ
M1:
	DB	BGM,13
	E_CG B_SUDA,'AE_113'
;	DB	'【亜希】：・・・・・・あっ・・・・・・'
	DB	"%001:  .......Ahh....."
	DB	NEXT
;	DB	'【%001】：・・・亜希ちゃん・・・可愛いよ。'
	DB	"%001:  .....Aki.... You're really pretty."
	DB	NEXT
;	DB	'【亜希】：・・・・・・先輩・・・・・・'
	DB	"Aki:  %001..."
	DB	PAUSE
;	DB	'あぁんっ・・・・・・'
	DB	".......Ahhhn!"
	DW	0000H

M2:		;話す　亜希１
;	DB	'【亜希】：・・・あぁっ・・・先輩・・・'
	DB	"Aki:  Ahhhn.....Oh, %001...."
	EF_SET 101
	DW	0000H

M3:		;揉む　胸１
;	DB	'西野さんより３つも年下とは思えないほどたわわに実った胸を、'
;	DB	'鷲づかみにして揉みしだく。'
	DB	"I massage her breasts, making large circular movements."
	DB	CR
	DB	"I couldn't believe that Shoko and Aki weren't the same age."
	DB	NEXT
;	DB	'【亜希】：あんっ・・・・・・'
	DB	"Aki:  Ahhhn......."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;揉む　胸２
;	DB	'乳首を指の腹で、コロコロと転がすように弄ぶ。'
	DB	"I play with her nipples, making them stand erect."
	DB	NEXT
;	DB	'【亜希】：・・・ん・・・ぁっ・・・'
	DB	"Aki:  ..........%001...."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;揉む　胸３
;	DB	'朱鷺色の突起を、少しつまみ上げて見る。'
	DB	"Her nipples take on a bright red color as I play with them."
	DB	NEXT
;	DB	'【亜希】：・・・あっ・・・くっ・・・'
	DB	"Aki:  .......Ah.....ahhn..."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;揉む　胸４
;	DB	'再び掌全体で掴み、下から押し上げるように揉み上げる。'
	DB	"I take her entire breast into my hand again, massaging it"
	DB	CR
	DB	"softly."
	DB	NEXT
;	DB	'【亜希】：・・・あぁっ・・・いい・・・'
	DB	"Aki:  ......Ah...... I like that..."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;揉む　胸５
;	DB	'柔らかいゴム鞠のように形を変える乳房を追うように、手の位置を様々に変えて見る。'
	DB	"My hands continue to probe her breasts..."
	DB	NEXT
;	DB	'【亜希】：・・・あ・・・ふ・・・'
	DB	"Aki:  Ahhhn......!"
	EF_SET 102
	DB	FLG,F_COPYI,2,1
	DW	0000H

M8:		;触る　○○○○１
;	DB	'中指を秘裂になぞらえ、上下に動かす。'
	DB	"I move up and down her slit with my finger."
	DB	NEXT
;	DB	'【亜希】：・・・あ・・・くぅん・・・'
	DB	"Aki:  ..........Ahhhhh!"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M9:		;触る　○○○○２
;	DB	'蝶番のような突起を指の腹で押え、細かく左右に振って見る。'
	DB	"I find her clitoris, and play with it, lightly at first,"
	DB	CR
	DB	"then harder."
	DB	NEXT
;	DB	'【亜希】：・・・ひっ！・・・あぁぁんっ！'
	DB	"Aki:  ...........Ahhhhn!!"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M10:		;触る　○○○○３
;	DB	'中指を秘裂に沈め、ゆっくりと出し入れを開始する。'
	DB	"Opening her like a butterfly, I put my finger in."
	DB	NEXT
;	DB	'【亜希】：・・・んくっ！・・・あんっ！'
	DB	"Aki: Ahhn! %001!"
	DB	FLG,F_COPYI,3,3
	DW	0000H

M11:		;触る　○○○○４
;	DB	'指のピッチを早め、亜希ちゃんの中をかき回す。'
	DB	"I move my finger in and out of her, faster and faster."
	DB	NEXT
;	DB	'【亜希】：・・・んぁっ！んぁぁっ！'
	DB	"Aki:  ........Ahhhnnn! That's too good!"
	DB	NEXT
;	DB	'既に俺の指も亜希ちゃんのあそこも、溢れる密でびっしょりと濡れ・・・'
;	DB	'粘っこい音を辺りに響かせていた。'
	DB	"Her pussy was dripping and ready. My finger makes a sucking"
	DB	CR
	DB	"noise as it plunges into her."
	EF_SET 103
	DW	0000H

M12:		;キスする　首筋１
;	DB	'ほんのり桜色に染まった、亜希ちゃんのうなじに唇を寄せる。'
	DB	"I kiss her neck, reaching around to find her lips."
	DB	NEXT
;	DB	'【亜希】：・・・あ・・・'
	DB	"Aki:  .....Mmmmmm......"
	DB	FLG,F_COPYI,4,1
	DW	0000H

M13:		;キスする　首筋２
;	DB	'耳の下から鎖骨の辺りにかけて、キスの雨を降らせる。'
	DB	"I kiss the soft skin under her ear, moving to her chest."
	DB	NEXT
;	DB	'【亜希】：・・・あ・・・あ・・・'
	DB	"Aki: ......Ahhn.........."
	EF_SET 104
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,5,255,101,102,103,104
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'【%001】：・・・亜希ちゃん・・・'
	DB	"%001:  .....Aki..."
	DB	PAUSE
;	DB	'いい？'
	DB	" Are you ready?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・うん。来て・・・・・・'
	DB	"Aki:  ..........Yes. I am."
	DB	NEXT
	DB	SINARIO,'CSE_F_3.OVL',0
	DW	0000H


end
