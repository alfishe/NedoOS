;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　恵依美２
;		
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN2,NN4,-1
CM4:	DW	VV4,	 -1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'触る',0
VV3:	DB	3,	'TOUCH',0
;VV4:	DB	4,	'キスする',0
VV4:	DB	4,	'KISS',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	'MEIMI',0
;NN2:	DB	2,	'胸',0
NN2:	DB	2,	'BREASTS',0
;NN3:	DB	3,	'太股',0
NN3:	DB	3,	'THIGHS',0
;NN4:	DB	4,	'○○○○',0
NN4:	DB	4,	'PUSSY',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　恵依美１
S2:		DW	VV1, NN2,  2, M3		;見る　胸１
S3:		DW	VV1, NN3,  3, M4		;見る　太股１
S4:		DW	VV2, NN1,  4, M5, M15		;話す　恵依美２
S5:		DW	VV3, NN2,  5, M6, M7, M8, M9		;触る　胸４
S6:		DW	VV3, NN4,  6, M10, M11		;触る　○○○○２
S7:		DW	VV4,  -1,  7, M12, M13, M14		;キスする３


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'【%001】：・・・・・・綺麗だよ、中野・・・・・・'
	DB	"%001:  You're so pretty, Meimi...."
	E_CG B_SUDA,'AE_103'
	DB	NEXT
;	DB	'【恵依美】：・・・%001・・・あたし、恥ずかしい・・・'
	DB	"Meimi:  .....I am?"
	DW	0000H

M2:		;見る　恵依美１
;	DB	'初めて見る中野の身体は本当に綺麗で・・・俺はしばし、見とれていた・・・'
	DB	"Meimi's body was truly beautiful. I couldn't take my eyes"
	DB	CR
	DB	"off her."
	DB	NEXT
;	DB	'【恵依美】：・・・あんまり見ないで・・・'
	DB	"Meimi:  Don't stare at me....."
	DW	0000H

M3:		;見る　胸１
;	DB	'西野さんや今日子先生に比べると小ぶりだが、形の良い胸だと思う。'
	DB	"Her breasts were slightly smaller than Shoko's, but really"
	DB	CR
	DB	"well formed."
	DB	NEXT
;	DB	'【恵依美】：・・・胸、ちっちゃいでしょ・・・？'
	DB	"Meimi:  My breasts are small, aren't they...?"
	DW	0000H

M4:		;見る　太股１
;	DB	'さすが体操で鍛えているだけあって、引き締まった脚をしている。'
	DB	"Her legs were strong and muscular. She was a gymnast,"
	DB	CR
	DB	"after all."
	DB	NEXT
;	DB	'【恵依美】：・・・あたしの脚・・・太い？'
	DB	"Meimi:  My legs are fat."
	DW	0000H

M5:		;話す　恵依美１
;	DB	'【%001】：・・・触ってもいい・・・？'
	DB	"%001:  Can I touch you?"
	DB	NEXT
;	DB	'【恵依美】：・・・うん、いいよ・・・%001なら。'
	DB	"Meimi:  It's alright. I've wanted you touch me like this"
	DB	CR
	DB	"for a long time."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M6:		;触る　胸１
;	DB	'【恵依美】：・・・あっ・・・'
	DB	"Meimi:  ................Ahh....."
	DB	NEXT
;	DB	'呼吸に合わせて上下する、ふくらみの先端にそっと触れる。'
	DB	"I put my hand on her breast, feeling its springy softness."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M7:		;触る　胸２
;	DB	'掌全体で乳房を包み込み、ゆっくり揉んでいく。'
	DB	"I wrap my hand around her breast, and massage it slowly."
	DB	NEXT
;	DB	'【恵依美】：・・・ン・・・なんか変・・・'
	DB	"Meimi:  ........That feels strange."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M8:		;触る　胸３
;	DB	'中野のふくらみは、俺の手にあつらえたようにすっぽりはまる。'
	DB	"I continued massaging her breasts."
	DB	NEXT
;	DB	'だから、乳首のみならず乳房全体が固くしこって来る様子が、'
;	DB	'文字通り手に取るように判る。'
	DB	"First her nipples, then the breasts themselves began to"
	DB	CR
	DB	"get hard in my hand."
	DB	NEXT
;	DB	'【恵依美】：・・・あ・・・はん・・・'
	DB	"Meimi:  ....Ahhhn...."
	DB	FLG,F_COPYI,5,3
	DW	0000H

M9:		;触る　胸４
;	DB	'俺は弾力を増して来るふくらみを、思うままに堪能した。'
	DB	"As I held her hardening breasts in my hands, I felt myself"
	DB	CR
	DB	"get excited."
	DB	NEXT
;	DB	'【恵依美】：・・・あん・・・あんっ・・・'
	DB	"Meimi:  .......Ahhhhn.....ahhhn...."
	EF_SET 105
	DW	0000H

M10:		;触る　○○○○１
;	DB	'【恵依美】：・・・そこは・・・！'
	DB	"Meimi:  .....No, not there!"
	DB	NEXT
;	DB	'俺は、中野の一番大切な部分に手を伸ばそうとした。'
	DB	"I reached my hand out for her most secret place."
	DB	NEXT
;	DB	'だが中野は、がっちりと手でガードして触らせてくれない。'
	DB	"But Meimi's hand blocked mine, holding it back, firmly."
	DB	NEXT
;	DB	'【恵依美】：・・・お願い・・・まだ恐いの・・・'
	DB	"Meimi:  Please..... I'm still afraid."
;	DB	FLG,F_COPYI,6,1
	DW	0000H

M11:		;触る　○○○○２
;	DB	'くちゃっ。'
;	DB	"*GRAB*"
;	DB	NEXT
;	DB	'【恵依美】：ひぅっ！！'
	DB	"Meimi:  Kya!!"
	DB	NEXT
;	DB	'感じ始めて手の力が抜けて来た隙を突き、俺は中野の指の間から'
;	DB	'指を入れる。'
	DB	"Locking my fingers with hers, I pulled her hand away."
	DB	CR
	DB	"I touched her pussy lips through her underpants."
	DB	NEXT
;	DB	'・・・其処は既に、男性を迎え入れる準備を整えつつあった。'
	DB	"She was already wet, and almost ready for my entry."
	DB	NEXT
;	DB	'【%001】：・・・さ、中野・・・'
	DB	"%001:  It's alright, Meimi."
	DB	NEXT
;	DB	'【恵依美】：・・・え・・・？'
	DB	"Meimi:  .............Yes, but....."
	DB	NEXT
	DB	SINARIO,'CSE_H_3.OVL',0
	DW	0000H

M12:		;キスする１
;	DB	'【恵依美】：・・・ん・・・'
	DB	"Meimi:  Mmm.....mmmmmm......."
	DB	NEXT
;	DB	'舌と舌を絡ませる、大人のキス。'
	DB	"It was a grown-up's kiss, our tongues reaching for each other."
	DB	NEXT
;	DB	'俺と中野の心を表すように、おずおずと出会い、抱き合う。'
	DB	"Meimi and I rolled on the bed, reaching for each other."
	DB	FLG,F_COPYI,7,1
	DW	0000H

M13:		;キスする２
;	DB	'【恵依美】：・・・ん・・・んっ・・・'
	DB	"Meimi:  ......Mmmmm......."
	DB	NEXT
;	DB	'時にはぶつかりあい・・・時には寄り添う。'
	DB	"We kissed clumsily, our teeth clashing together."
	DB	NEXT
;	DB	'動きは不器用そのものだけど、相手を想う気持ちに偽りはない。'
	DB	"It might have been funny to watch, but we weren't thinking"
	DB	CR
	DB	"of anything but ourselves."
	DB	FLG,F_COPYI,7,2
	DW	0000H

M14:		;キスする３
;	DB	'【恵依美】：・・・はぁっ・・・'
	DB	"Meimi:  .....Ahhhnn....."
	DB	NEXT
;	DB	'互いの気持ちを確かめあった俺達は、一端離れ・・・'
;	DB	'再度求め合う。'
	DB	"We were two lovers, trying to find what was in the other's"
	DB	CR
	DB	"hearts."
	DB	NEXT
;	DB	'【恵依美】：・・・%001・・・んっ・・・'
	DB	"Meimi:  ......%001.....Mmmm....."
	EF_SET 107
	DW	0000H

M15:		;話す　恵依美２
;	DB	'【%001】：・・・中野・・・'
	DB	"%001:  .....Meimi....."
	DB	NEXT
;	DB	'【恵依美】：・・・%001・・・'
	DB	"Meimi:  ......%001....."
	EF_SET 104
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,4,255,104,107,105
	DB	FLG,F_EXIT,255
	DB	FLG,F_COPYI,6,1
	DW	0000H


end
