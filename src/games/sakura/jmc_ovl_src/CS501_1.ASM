;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０１＿１
;		林間学校　班編成

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8
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
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	NN3,NN4,NN5,NN6,NN7,NN8,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0
;VV3:	DB	3,	'書く',0
VV3:	DB	3,	'WRITE',0

;NN1:	DB	1,	'まわり',0
NN1:	DB	1,	'AROUND',0
;NN2:	DB	2,	'林間学校',0
NN2:	DB	2,	'SCHOOL TRIP',0
;NN3:	DB	3,	'鈴子',0
NN3:	DB	3,	'REIKO',0
;NN4:	DB	4,	'祥子',0
NN4:	DB	4,	'SHOKO',0
;NN5:	DB	5,	'清美',0
NN5:	DB	5,	'KIYOMI',0
;NN6:	DB	6,	'瑠璃',0
NN6:	DB	6,	'RURI',0
;NN7:	DB	7,	'星愛',0
NN7:	DB	7,	'SEIA',0
;NN8:	DB	8,	'恵依美',0
NN8:	DB	8,	'MEIMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　周り２
S2:		DW	VV2, NN2,  2, M4, M5, M6		;考える　林間学校３
S3:		DW	VV3, NN3,  3, M7		;書く　鈴子１
S4:		DW	VV3, NN4,  4, M8		;書く　祥子１
S5:		DW	VV3, NN5,  5, M9		;書く　清美１
S6:		DW	VV3, NN6,  6, M10		;書く　瑠璃１
S7:		DW	VV3, NN8,  7, M11		;書く　恵依美１
S8:		DW	VV3, NN7,  8, M12		;書く　星愛１


;イニシャルメッセージ
M1:
	DB	BGM,6
	E_CG B_SUDA,'AB_36_4'
;	DB	'【%001】：・・・・・・さてと。とっとと决めね～とな。'
	DB	"%001:  Well, I guess I'd better choose who I want."
	DB G_FLG,G_COPYF,110,110
	DB G_FLG,G_COPYF,120,120
	DB G_FLG,G_COPYF,140,140
	DB G_FLG,G_COPYF,150,150
	DB G_FLG,G_COPYF,170,170
	DB G_FLG,G_COPYF,180,180
	DB FLG,F_COPYI,200,0
	DB FLG,F_COPYI,202,0
	DB C_BLD,C_V_ON,3
	DW	0000H

M2:		;見る　周り１
;	DB	'授業中だけあって、流石にみんな静かだ。'
	DB	"Class is going on right now, so it's quiet."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　周り２
;	DB	'・・・授業中なんだから、あんまりキョロキョロしね～方がいいぜ。'
	DB	"Class is going on now, so you shouldn't look around too"
	DB	CR
	DB	"much."
	DB	FLG,F_COPYI,1,0
	DW	0000H

M4:		;考える　林間学校１
;	DB	'全校生徒で行く、３泊４日の北海道への旅だ。'
	DB	"All the students in the school are taking the school trip"
	DB	CR
	DB	"to Hokkaido for four days and three nights."
	DB	NEXT
;	DB	'・・・何で全校生徒かと言うと・・・'
	DB	"It was supposedly the dean's idea to require us all"
	DB	CR
	DB	"to go."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;考える　林間学校２
;	DB	'・・・で、当然行った先では班単位で行動する訳だが・・・'
	DB	"The dean wants us to be organized in groups, and each"
	DB	CR
	DB	"group has to have students from each graduating class in"
	DB	CR
	DB	"it."
	DB	NEXT
;	DB	'だから俺の場合は中等部から何人かと、二年か三年から何人かを選ばなきゃならん訳だ。'
	DB	"So I've got to pick some students to be in my group."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;考える　林間学校３
;	DB	'・・・んで、俺の目の前にある紙には６つ、名前を書く欄がある。'
	DB	"There are six spaces on the paper in front of me, room for"
	DB	CR
	DB	"six names."
	DB	NEXT
;	DB	'その内３つは、既に埋まっている。'
	DB	"Three of the names are already filled in."
	DB	NEXT
;	DB	'１．誠（まぁいちお～友達だから）',CR
	DB	"1. Makoko"
	DB	NEXT
;	DB	'２．美緒ちゃん（中等部の知り合いってこの娘くらいしかいないから）',CR
	DB	"2. Mio"
	DB	NEXT
;	DB	'３．亜希ちゃん（美緒ちゃん書いてこの娘書かないと、後で恐そうだから）'
	DB	"3. Aki"
	DB	NEXT
;	DB	'・・・・・・'
	DB	"..............................."
	DB	NEXT
;	DB	'問題は、残りの３人だな。'
	DB	"There are three spaces left. Who should I write?"
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_OFF,3
	DW	0000H

M7:		;書く　鈴子１
;	DB	'・・・そうだな、鈴子さんにしよう。'
	DB	"Reiko's a good choice."
	DB	NEXT
;	DB	'かきかき'
	DB	"*write write*"
	DB	NEXT
;	DB	'・・・・・・'
	DB	"..............................."
	DB	NEXT
;	DB	'鈴子さんと西野さん、スゲー相性悪いみたいだからな。鈴子さんを入れたから、西野さんは書かない方がいいな。'
	DB	"Reiko really doesn't get along with Shoko. Since I've"
	DB	CR
	DB	"written Reiko's name down, I'd better not write Shoko."
	DB C_BLD,C_N_ON,3,1
	DB C_BLD,C_N_ON,3,2
	DB	FLG,F_CALI,110,5
	DB	FLG,F_COPYI,111,1
	DB	FLG,F_COPYI,201,1
	DB	FLG,F_CALLS,200
	DW	M_SUB1,M_SUB2
	DW	-1										;ＯＮ　ＧＯＳＵＢ
	DW	0000H

M8:		;書く　祥子１
;	DB	'・・・・・・'
	DB	"..............................."
	DB	PAUSE
;	DB	'いいのか？'
	DB	"Is that really okay?"
	DB	NEXT
;	DB	'かきかき'
	DB	"*write write*"
	DB	NEXT
;	DB	'・・・・・・'
	DB	"..............................."
	DB	NEXT
;	DB	'鈴子さんと西野さん、スゲー相性悪いみたいだからな。西野さんを入れたから、鈴子さんは書かない方がいいな。'
	DB	"Reiko really doesn't get along with Shoko. Since I've"
	DB	CR
	DB	"written Shoko's name down, I'd better not write Reiko."
	DB C_BLD,C_N_ON,3,1
	DB C_BLD,C_N_ON,3,2
	DB	FLG,F_CALI,140,5
	DB	FLG,F_COPYI,141,1
	DB	FLG,F_COPYI,201,4
	DB	FLG,F_CALLS,200
	DW	M_SUB1,M_SUB2
	DW	-1										;ＯＮ　ＧＯＳＵＢ
	DW	0000H

M9:		;書く　清美１
;	DB	'・・・そうだな、新藤さんにしよう。'
	DB	"Yes, Kiyomi's a good person to write."
	DB	NEXT
;	DB	'かきかき'
	DB	"*write write*"
	DB C_BLD,C_N_ON,3,3
	DB	FLG,F_CALI,120,5
	DB	FLG,F_COPYI,121,1
	DB	FLG,F_COPYI,201,2
	DB	FLG,F_CALLS,200
	DW	M_SUB1,M_SUB2
	DW	-1										;ＯＮ　ＧＯＳＵＢ
	DW	0000H

M10:		;書く　瑠璃１
;	DB	'・・・白水さん、か・・・'
	DB	".......Okay, Ruri it is..."
	DB	NEXT
;	DB	'かきかき'
	DB	"*write write*"
	DB C_BLD,C_N_ON,3,4
	DB	FLG,F_CALI,150,5
	DB	FLG,F_COPYI,151,1
	DB	FLG,F_COPYI,201,5
	DB	FLG,F_CALLS,200
	DW	M_SUB1,M_SUB2
	DW	-1										;ＯＮ　ＧＯＳＵＢ
	DW	0000H

M11:		;書く　恵依美１
;	DB	'・・・中野か。'
	DB	"......Okay, I'll write Meimi's name."
	DB	NEXT
;	DB	'かきかき'
	DB	"*write write*"
	DB C_BLD,C_N_ON,3,6
	DB	FLG,F_CALI,180,5
	DB	FLG,F_COPYI,181,1
	DB	FLG,F_COPYI,201,8
	DB	FLG,F_CALLS,200
	DW	M_SUB1,M_SUB2
	DW	-1										;ＯＮ　ＧＯＳＵＢ
	DW	0000H

M12:		;書く　星愛１
;	DB	'・・・吉田ね。'
	DB	".....Seia's a good one to write."
	DB	NEXT
;	DB	'かきかき'
	DB	"*write write*"
	DB C_BLD,C_N_ON,3,5
	DB	FLG,F_CALI,170,5
	DB	FLG,F_COPYI,171,1
	DB	FLG,F_COPYI,201,7
	DB	FLG,F_CALLS,200
	DW	M_SUB1,M_SUB2
	DW	-1										;ＯＮ　ＧＯＳＵＢ
	DW	0000H

EXIT:		;
	DB	NEXT
;	DB	'・・・よし、全部埋めたぞ。'
	DB	"Okay, that's finished."
	DB	NEXT
;	DB	'・・・・・・さ～て、ど～なるか楽しみだ・・・・・・'
	DB	".....I wonder what'll happen up in Hokkaido."
	DB	NEXT
;	DB	'【教師】：次の問題を・・・',PAUSE,'山神、答えてみろ。'
	DB	"Teacher:  And the answer is...",PAUSE," Yamagami, why don't you tell us?"
	DB	NEXT
;	DB	'【%001】：はっはい！？'
	DB	"%001:  Huh??"
	DB	NEXT
	E_CG B_NORM,'T_05'
	DB	NEXT
	DB G_FLG,G_COPYG,110,110
	DB G_FLG,G_COPYG,120,120
	DB G_FLG,G_COPYG,140,140
	DB G_FLG,G_COPYG,150,150
	DB G_FLG,G_COPYG,170,170
	DB G_FLG,G_COPYG,180,180
	DB	SINARIO,'CS502.OVL',0
	DW	0000H

M_SUB1:		;一番目をＧフラグへ
	DB	FLG,F_COPYI,200,1				;ジャンプ先を M_SUB2 へ
	DB	G_FLG,G_COPYG,255,201			;Ｇフラグ転送
	DB	FLG,F_CALI,202,1
	DW	0000H

M_SUB2:
	DB	FLG,F_CALI,202,1
	DB	FLG,F_COMPI,255,202,2
	DB	FLG,F_JGR,255					;３人選んだか？
	DW	EXIT
	DW	0000H



end
