;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　祥子１
;		

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

;VV1:	DB	1,	'受け入れる',0
VV1:	DB	1,	'ACCEPT',0
;VV2:	DB	2,	'断る',0
VV2:	DB	2,	'REFUSE',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1,  -1,  1, M2		;受け入れる１
S2:		DW	VV2,  -1,  2, M3		;断る１


;イニシャルメッセージ
M1:
	DB	BGM,13
	B_O B_SUDA
	BAK_INIT "AE_171"
	DB	"I lay down on the bed as I was told."
	DB	NEXT
;	DB	'【%001】：・・・こう？'
	DB	"%001:  Like this?"
	DB	NEXT
;	DB	'【祥子】：・・・・・・'
	DB	"Shoko:  ............."
	DB	NEXT
;	DB	'【%001】：？　西野さ・・・'
	DB	"%001:  Shoko?"
	DB	PAUSE
	B_P1 B_SUDA
;	DB	'わぁあっ！？'
	DB	" Wah"
	DB	NEXT
;	DB	'【祥子】：・・・・・・さ、しゅ～君・・・・・・'
	DB	"Shoko:  ......It's time, Shu-kun..."
	DB	NEXT
;	DB	'【%001】：・・・ち、ちょっと！？'
	DB	"%001:  Wait a minute!"
	DB	NEXT
;	DB	'【祥子】：・・・・・・しゅ～君・・・・・・'
	DB	"Shoko:  Shu-kun...."
	DB	PAUSE
;	DB	'あたしの事、嫌い？'
	DB	" Do you hate me?"
	DB	NEXT
;	DB	'そういう西野さんの目は・・・・・・今までに無く優しく、真剣だった。'
	DB	"I had never seen such honesty, such sadness, in those eyes"
	DB	CR
	DB	"of hers before."
	DB	NEXT
;	DB	'【%001】：・・・・・・い、いや。嫌いと言う事は・・・・・・'
	DB	"%001:  No. I don't hate you..."
	DB	NEXT
;	DB	'【祥子】：・・・だったら・・・ね？いいでしょ？'
	DB	"Shoko:  Then let's fuck!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................"
	DB	NEXT
;	DB	'【祥子】：お願い・・・しゅ～君・・・あたしを、安心させて？'
	DB	"Shoko:  Please, Shu-kun... I really want to..."
	DB	NEXT
;	DB	'（・・・・・・どーする？）'
	DB	"(What do I do?)"
	DW	0000H

M2:		;受け入れる１
;	DB	'【%001】：・・・分かったよ、西野さん。'
	DB	"%001:  ....Alright, Shoko."
	DB	NEXT
;	DB	'【祥子】：・・・ホント！？うれしいっ！！'
	DB	"Shoko:  Really? I'm so happy!"
	DB	NEXT
;	DB	'【%001】：わわっ！？'
	DB	"%001:  Wah!?"
	DB	NEXT
	DB	SINARIO,'CSE_D_2.OVL',0
	DW	0000H

M3:		;断る１
;	DB	'【%001】：・・・西野さん・・・ごめん。'
	DB	"%001:  Shoko....I'm sorry."
	DB	PAUSE
;	DB	'やっぱりこーゆーのは・・・'
	DB	" I just can't go through with this."
	DB	NEXT
;	DB	'【祥子】：・・・やっぱり・・・'
	DB	"Shoko:  I knew it..."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  .........."
	DB	PAUSE
;	DB	'西野さん？'
	DB	"What?"
	DB	NEXT
;	DB	'【祥子】：・・・やっぱり、鈴子ちゃんの方がいいんだ。'
	DB	"Shoko:  You love Reiko more than me!"
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【祥子】：・・・しゅ～君の・・・しゅ～君の・・・'
	DB	"Shoko:  Shu-kun.......Shu-kun no"
	DB	NEXT
;	DB	'【祥子】：ばかぁあぁぁぁぁっっっ！！！'
	DB	"Shoko:  BAKA!!!!!"
	B_O B_WIPE
	DB	NEXT
;	DB	'【%001】：に、西野さん！？'
	DB	"%001:  Shoko?"
	DB	NEXT
;	DB	'【%001】：・・・・・・行っちゃった。'
	DB	"%001:  She's gone."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........................."
	DB	NEXT
;	DB	'【%001】：何だか、悪い事しちゃったな。'
	DB	"%001:  I feel that I've hurt her somehow."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	DB	NEXT
;	DB	'【%001】：寝よ。'
	DB	"%001:  Guess I'll go to sleep."
	DB	NEXT
	DB	SINARIO,'CS803.OVL',0
	DW	0000H


end
