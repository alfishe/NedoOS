;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０３＿Ａ
;		山道　鈴子と会う

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
CM2:	DW	VV2,	NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'森の中',0
NN1:	DB	1,	'FOREST',0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	'REIKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　森の中
S2:		DW	VV2, NN2,  2, M3, M4		;話す　鈴子


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_08_1'
	B_P1 B_SUDA
;	DB	'【%001】：薪拾いっつっても、手頃な枝はみんな拾われた後だしな・・・'
	DB	"The hard part of gathering firewood is after you find it."
	DB	NEXT
;	DB	'【%001】：そこに落ちてる丸太拾って帰っても仕方ねえか。'
	DB	"You have to carry it all back to camp."
	DB	NEXT
;	DB	'【%001】：もっと森の奥に入らないとダメか？'
	DB	"I guess I'll have to go a little bit deeper into the forest."
	DB C_BLD,C_V_ON,2
	DB G_FLG,G_COPYF,110,110
	DB	FLG,F_CALI,110,10
	DB G_FLG,G_COPYG,110,110
	DB G_FLG,G_COPYI,159,1
	DW	0000H

M2:		;見る　森の中
	DB	BUF,B_COPY01
	T_CG 'CT01','T',0,10,1
;	DB	'【鈴子】：あれ、%001君？'
	DB	"Reiko:  Oh, it's you, %001."
	DB	NEXT
;	DB	'【%001】：鈴子さん。'
	DB	"%001:  Reiko."
	DB	NEXT
;	DB	'両手一杯に枯れ枝を抱えて、鈴子さんが現われた。'
	DB	"Reiko appears, holding an armfull of firewood."
	DB	NEXT
;	DB	'【鈴子】：どうしたの、君テント係でしょ？'
	DB	"Reiko:  What are you doing here? You were supposed to put"
	DB	CR
	DB	"up the tents."
	DB	NEXT
;	DB	'【%001】：もう張り終わったんだけど、「やることないなら薪でも拾って来い！」って言われてさ。'
	DB	"%001:  I finished early and was told to go find some"
	DB	CR
	DB	"firewood."
	DB	NEXT
;	DB	'【鈴子】：ふ～ん。'
	DB	"Reiko:  I see."
	DB	NEXT
;	DB	'【鈴子】：じゃあ、私の半分あげるから、ちょっとその辺歩かない？'
	DB	"Reiko:  You can have mine. Want to walk a bit?"
	DB	NEXT
;	DB	'【%001】：うん。'
	DB	"%001:  Okay."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_OFF,2
	DW	0000H

M3:		;話す　鈴子
;	DB	'【%001】：この辺、薪になるような枝落ちてませんね。'
	DB	"%001:  It doesn't look like there's any good wood around"
	DB	CR
	DB	"here."
	DB	NEXT
;	DB	'【鈴子】：そうね・・・みんな拾って行っちゃったのかしら？'
	DB	"Reiko:  Maybe the others took it all away already."
	DB	NEXT
;	DB	'【%001】：やれやれ、こりゃ奥のほう行かないと、まともなのはないかも・・・'
	DB	"%001:  We have to go deeper into the forest to find"
	DB	CR
	DB	"anything worth bringing back."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　鈴子
;	DB	'ゴロゴロゴロ・・・'
	DB	"*BOOM*"
	DB	NEXT
	DB	ANI,A_OFF
	K_CG 'CT01','I',10,2
;	DB	'【鈴子】：え、なに？'
	DB	"Reiko:  Huh?"
	DB	NEXT
;	DB	'急に風が強くなったかと思うと、今の今まで青かった空が真っ黒な雲に覆われた。'
	DB	"Suddenly the wind started to pick up, and the sky grew dark."
	DB	NEXT
;	DB	'【%001】：こりゃ、一雨くるな。'
	DB	"%001:  Wow, looks like rain."
	DB	NEXT
;	DB	'・・・と、言ったか言わないかのうちに叩きつけるような雨が降って来た。'
	DB	"The moment I spoke, my prediction came true:  rain started"
	DB	CR
	DB	"splattering down."
	DB	NEXT
;	DB	'【鈴子】：きゃー、どこか雨宿り出来るところないの！？'
	DB	"Reiko:  Oh no! Is there any place to go, to wait for the"
	DB	CR
	DB	"rain to stop?"
	DB	NEXT
;	DB	'【%001】：えっと・・・'
	DB	"%001:  Um..."
	DB	NEXT
;	DB	'【%001】：あそこの洞窟なんかどう？'
	DB	"%001:  There's a cave over that way."
	DB	NEXT
;	DB	'【鈴子】：この際何でもいいわ！'
	DB	"Reiko:  I don't care, let's go!"
	DB	NEXT
;	DB	'俺達は手近な洞窟に駆け込んだ。'
	DB	"We ran into the cave."
	DB	NEXT
	B_O B_SUDA
	DB SINARIO,'CS504_A.OVL',0
	DW	0000H


end
