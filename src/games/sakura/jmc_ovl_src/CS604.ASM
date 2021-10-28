;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０４
;		ＳＥＴＢＡＣＫ

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'考える',0
VV1:	DB	1,	"THINK",0
;VV2:	DB	2,	'暴れる',0
VV2:	DB	2,	"THRASH AROUND",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;考える
S2:		DW	VV2, -1,  2, M3, M4		;暴れる


;イニシャルメッセージ
M1:
	DB	BGM,2
;	DB	'【鈴子】：きゃあ！'
	DB	"Reiko:  %001!"
	DB	NEXT
;	DB	'【%001】：だずげべ！'
	DB	"%001:  Help me!"
	DB	NEXT
;	DB	'【鈴子】：ちょ、ちょっと%001君！'
	DB	"Reiko:  Hey, hey %001!"
	DW	0000H

M2:		;考える
;	DB	'お　ぼ　れ　る　！！！'
	DB	"I'm drowning!!!"
	DW	0000H


M3:		;暴れる
;	DB	'【%001】：おぼ・・・ゴホッ！ガハッ！'
	DB	"%001:  I'm... *GULP*"
	DB	NEXT
;	DB	'【鈴子】：いやぁ！放して！'
	DB	"Reiko:  Hey! Let me go!"
	DB	NEXT
;	DB	'【%001】：ごぼごぼごぼごぼ！'
	DB	"%001:  *GURGLE*"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;暴れる
;	DB	'【%001】：でいござん！・・・！'
	DB	"%001:  Reiko, help me!"
	DB	NEXT
;	DB	'【鈴子】：%001君・・・'
	DB	"Reiko:  %001..."
	DB	NEXT
;	DB	'突然俺は、あったかくてやわらかいものに包まれた。'
	DB	"Suddenly, I was wrapped in something soft and warm. I felt"
	DB	CR
	DB	"like I was a baby, being held in my mother's strong arms."
	DB	NEXT
;	DB	'【%001】：たすけ・・・て・・・'
	DB	"%001:  Help...me..."
	DB	NEXT
;	DB	'【鈴子】：大丈夫・・・大丈夫よ。'
	DB	"Reiko:  It's alright... It's alright, %001."
	DB	NEXT
;	DB	'（あ・・・心臓の音？）'
	DB	"(Oh...a heartbeat?)"
	DB	NEXT
;	DB	'俺の頬に、鼓動が伝わってくる。'
	DB	"I felt her warm, bare skin, and her heartbeat on my cheek."
	DB	NEXT
;	DB	'【鈴子】：ほら・・・足、立つでしょ？'
	DB	"Reiko:  There, you can stand, right?"
	DB	NEXT
;	DB	'気が付くと、俺は膝立ちになって、鈴子さんにしがみついていた。'
	DB	"When I knew where I was, I was on my knees and clinging ",CR,"to Reiko."
	DB	NEXT
;	DB	'そして、鈴子さんは俺を胸に抱きしめていた。'
	DB	"Reiko was holding me close to her chest, lovingly."
	DB	NEXT
;	DB	'【%001】：れいこさん・・・あったかい・・・'
	DB	"%001:  Reiko, you're so warm..."
	DB	NEXT
;	DB	'【鈴子】：もう大丈夫よ、%001君・・・'
	DB	"Reiko:  It's all right, %001."
	E_CG B_SUDA,'AE_026'
	DB	NEXT
;	DB	'【%001】：・・・あ・・・'
	DB	"%001:  ...Oh..."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・あっ！'
	DB	"Reiko:  ...Oh!..."
	DB	NEXT
;	DB	'【%001】：うっわぁあぁぁあ！？'
	DB	"%001:  Aaaaaa!"
	DB	NEXT
;	DB	'【鈴子】：きゃああああああ！！'
	DB	"Reiko:  KYAAAAAA!"
	DB	NEXT
;	DB	'俺が水着をつかんで暴れたせいで、鈴子さんのムネはむき出しになっていた。'
	DB	"I had pulled Reiko's bathing suit top off completely!"
	DB	NEXT
	DB	FLASH,2
	B_O B_YOKO
;	DB	'ぱっしぃ～～ん'
	DB	"*SMACK*"
	DB	NEXT
;	DB	'・・・という小気味いい音を立てて、俺の頬に季節外れの紅葉が張り付いた。'
	DB	".....An unseasonably fresh breeze stepped up, and suddenly"
	DB	CR
	DB	"an autumn leaf came and stuck to my cheek. It was in the"
	DB	CR
	DB	"shape of Reiko's hand."
	DB	NEXT
	DB SINARIO,'CS605.OVL',0
	DW	0000H


end