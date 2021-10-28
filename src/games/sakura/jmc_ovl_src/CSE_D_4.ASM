;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　祥子４
;		

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1

;VV1:	DB	1,	'動かす',0
VV1:	DB	1,	'MOVE',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0

;NN1:	DB	1,	'腰',0
NN1:	DB	1,	'BODY',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;動かす　腰４


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'【%001】：・・・行くよ・・・！'
	DB	"%001:  ...I'm going in...!"
	DB	NEXT
;	DB	'ずぶぶぶっ'
	DB	"*SQUEESH*"
	E_CG B_SUDA,'AE_174'
	DB	NEXT
;	DB	'【祥子】：・・・あぁっ・・・'
	DB	"Shoko:  ...Ahhh!"
	DB	PAUSE
;	DB	'しゅ～君が・・・'
	DB	" Shu-kun's....."
	DB	PAUSE
;	DB	'しゅ～君が入ってくるぅ・・・'
	DB	" Shu-kun's inside me...."
	DW	0000H
	
M2:		;動かす　腰１
;	DB	'俺はゆっくりと腰を前後させ始める。'
	DB	"I slowly move my body in and out of her hot pussy."
	DB	NEXT
;	DB	'【祥子】：・・・ん・・・あ・・・は・・・あ・・・'
	DB	"Shoko:  Ahhn...ahhhn...."
	DB	NEXT
;	DB	'既に充分に塗れそぼっていた秘裂は、滑らかにブツを出し入れする。'
	DB	"Shoko's slit, more than ready for me, leaked wetness down"
	DB	CR
	DB	"her legs."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;動かす　腰２
;	DB	'自然と早くなる回転とともに、快感も次第に強くなってくる。'
	DB	"As my body's movements got faster and faster, the"
	DB	CR
	DB	"stimulation being transmitted through my body increases."
	DB	NEXT
;	DB	'【祥子】：・・・あっ・・・いいっ・・・'
	DB	"Shoko:  .....Ahhhn....It's good...."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;動かす　腰３
;	DB	'ぱんっぱんっぱんっぱんっ'
	DB	"*SPAP* *SPAP* *SPAP*"
	DB	NEXT
;	DB	'腰の速度はどんどん速くなり、肉と肉がぶつかり合う音が響き始める。'
	DB	"My movement were fast now, causing our my flesh to contact"
	DB	CR
	DB	"with hers."
	DB	NEXT
;	DB	'【祥子】：・・・あっ、あっ、あっ、ああっ・・・'
	DB	"Shoko:  Ah.....ahhhhhhh!"
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;動かす　腰４
;	DB	'ぱんぱんぱんぱんぱんぱんぱん'
	DB	"*SPAPSPAPSPAPSPAP!!*"
	DB	NEXT
;	DB	'【祥子】：あっ、はっ、ああんっ、あふぅっ・・・'
	DB	"Shoko:  Ahhh..... It's good, too good...!!"
	DB	NEXT
;	DB	'西野さんの声が切迫した響きを帯び、俺の頭にも『限界』の文字がチラつき始める。'
	DB	"Shoko's voice mingled with my own, and I knew that we"
	DB	CR
	DB	"were almost there."
	DB	NEXT
	DB	"...................................."
	DB	NEXT
;	DB	'【祥子】：・・・あっあっあっ・・・あぁ～～～～～～～～～っ！！'
	DB	"Shoko:  Ahhhhhhhhhhhhhhhn!!!"
	B_O B_SUDA
	DB	NEXT
;	DB	'どくどくどくどくどくっ'
	DB	"%001:  ..........!!"
	DB	NEXT
;	DB	'西野さんの叫びとほぼ同時に、俺は迸る何かを彼女の中にぶちまけた。'
	DB	"Shoko came, forcing her muscles which held my cock to "
	DB	CR
	DB	"tense. This sensation put me over the edge, and I pumped"
	DB	CR
	DB	"my boiling spank inside her."
	DB	NEXT
;	DB	'【祥子】：・・・ああ・・・あったかい・・・'
	DB	"Shoko:  ...It's so warm!"
	DB	NEXT
;	DB	'【%001】：西野さん・・・・・・'
	DB	"%001:  Shoko......."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"..................."
	DB	NEXT
;	DB	'【祥子】：・・・ねえ、しゅ～君・・・'
	DB	"Shoko:  Shu-kun?"
	DB	NEXT
;	DB	'【%001】：なに？'
	DB	"%001:  Yes?"
	DB	NEXT
;	DB	'【祥子】：あたし・・・しゅ～君の事、応援していいかな？'
	DB	"Shoko:  Do you mind....if I cheer for you?"
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【祥子】：あたし、しゅ～君の為だったら何でもしちゃいたいの。'
;	DB	'しゅ～君の事、好きだから・・・・・・'
	DB	"Shoko:  I feel...that I want to do something for you."
	DB	CR
	DB	"Because I love you."
	DB	NEXT
;	DB	'【%001】：・・・西野さん・・・'
	DB	"%001:  ......Shoko...."
	DB	NEXT
;	DB	'【祥子】：・・・・・・ダメ？'
	DB	"Shoko:  Do you mind?"
	DB	NEXT
;	DB	'【%001】：・・・・・・いや・・・・・・そんな事ないよ。'
	DB	"%001:  ........No, I don't."
	DB	NEXT
;	DB	'【祥子】：ホントに？'
	DB	"Shoko:  Really?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Really."
	DB	PAUSE
;	DB	'・・・だけどその前に、何をするか決めなくっちゃな。'
	DB	" But before that, I've got to decide what I'm"
	DB	CR
	DB	"going to do."
	DB	NEXT
;	DB	'【祥子】：・・・うん・・・そうだね。'
	DB	"Shoko:  ......Yes, that's right."
	DB	NEXT
;	DB	'【%001】：・・・見つけるよ、必ず・・・'
	DB	"%001:  ..................."
	DB	NEXT
	DB	BGM,33
	DB	ENDING,4
	DW	0000H


end
