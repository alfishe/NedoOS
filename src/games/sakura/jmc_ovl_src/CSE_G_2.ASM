;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　星愛２
;		
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
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	NN3,-1

;VV1:	DB	1,	'話す',0
VV1:	DB	1,	'TALK',0
;VV2:	DB	2,	'揉む',0
VV2:	DB	2,	'MASSAGE',0
;VV3:	DB	3,	'舐める',0
VV3:	DB	3,	'LICK',0


;NN1:	DB	1,	'星愛',0
NN1:	DB	1,	'SEIA',0
;NN2:	DB	2,	'胸',0
NN2:	DB	2,	'BREASTS',0
;NN3:	DB	3,	'舐める',0
NN3:	DB	3,	'PUSSY',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;話す　星愛１
S2:		DW	VV2, NN2,  2, M3, M4, M5, M6		;揉む　胸４
S3:		DW	VV3, NN3,  3, M7, M8, M9, M10, M11, M12, M13, M14		;舐める　○○○○８


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'【星愛】：・・・な、何を・・・あぅっ！'
	DB	"Seia:  What are you....?"
	E_CG B_SUDA,'AE_163'
	DB	NEXT
;	DB	'衣服を剥ぎ取るように脱がせると、俺は吉田にむしゃぶりついた。'
	DB	"I started all but ripping Seia's clothes off of her."
	DB	NEXT
;	DB	'【星愛】：・・・あ・・・あっ・・・ダメ・・・'
	DB	"Seia:  No....No, stop!"
	DW	0000H

M2:		;話す　星愛１
;	DB	'【星愛】：・・・あぁっ・・・いけません・・・'
	DB	"Seia:  We can't do this...!"
	DW	0000H

M3:		;揉む　胸１
;	DB	'吉田の豊満な胸を横から掴み、ぐにぐにと揉みしだく。'
	DB	"I found her full breasts, and began massaging them vigorously."
	DB	NEXT
;	DB	'【星愛】：・・・あ・・・'
	DB	"Seia:  ....Ah...."
	DB	NEXT
;	DB	'吉田の胸は水をたっぷり含んだスポンジのように柔らかく、暖めたミルクのように熱かった。'
	DB	"Seia's breasts were soft and milky white."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;揉む　胸２
;	DB	'そのまま少しずつ手の位置を変え、形を変えつつある突起を指に挾みこむ。'
	DB	"Bringing my hands around, I began to massage her nipples"
	DB	CR
	DB	"softly."
	DB	NEXT
;	DB	'【星愛】：・・・あんっ・・・'
	DB	"Seia:  ...Ahhhn....."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;揉む　胸３
;	DB	'挾みこんだ乳首をこりこりと弄び、同時に乳房をぎゅぎゅっと握り締める。'
	DB	"Her nipples were hard as I continued to stimulate them"
	DB	CR
	DB	"with my fingers."
	DB	NEXT
;	DB	'【星愛】：・・・あ、はぅっ・・・'
	DB	"Seia:  ....Ahh.......ahhhn......"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;揉む　胸４
;	DB	'再び横から乳房を掴み、ぐにぐにと揉みしだく。'
	DB	"I reach from the side again to rub her breasts some more."
	DB	NEXT
;	DB	'【星愛】：・・・んんっ・・・'
	DB	"Seia:  ........Mmmm....."
	DB	FLG,F_COPYI,2,1
	EF_SET 102
	DW	0000H

M7:		;舐める　○○○○１
;	DB	'露になった脚の付け根に、むしゃぶりつくように口をつける。'
	DB	"I put my mouth against her moist pussy."
	DB	NEXT
;	DB	'【星愛】：・・・そ、そこはダ・・・ひぅっ！'
	DB	"Seia:  ....No, not there! .....Ahhhn!"
	DB	NEXT
;	DB	'口をつけた瞬間、吉田の身体が大きくのけぞる。'
	DB	"I kissed her softly, and her body shivered."
	DB	NEXT
;	DB	'【星愛】：・・・ああ・・・'
	DB	"Seia:  ...Aaaaan..."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;舐める　○○○○２
;	DB	'割れ目に沿って、犬か何かのように舌を動かす。'
	DB	"I move along her slit, lapping at her like a dog."
	DB	NEXT
;	DB	'【星愛】：・・・あぁっ・・・ダメ・・・'
	DB	"Seia:  Ahhh......No, not that...."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M9:		;舐める　○○○○３
;	DB	'口を押しあて、舌全体を擦り付ける。'
	DB	"Pushing my mouth against her pussy, I find her clitoris"
	DB	CR
	DB	"and suckle it."
	DB	NEXT
;	DB	'【星愛】：・・・ぅあぅっ！'
	DB	"Seia:  Ahhh!"
	DB	FLG,F_COPYI,3,3
	DW	0000H

M10:		;舐める　○○○○４
;	DB	'すこし開いて来たピンク色の秘裂に、舌を差し込む。'
	DB	"Opening her pink center, I slide my tongue inside her."
	DB	NEXT
;	DB	'【星愛】：・・・ひぃっ！'
	DB	"Seia: ......Ahh!"
	DB	NEXT
;	DB	'又も、吉田の背中が大きく反り返る。'
	DB	"Seia's back arched upwards."
	DB	FLG,F_COPYI,3,4
	DW	0000H

M11:		;舐める　○○○○５
;	DB	'そのまま根元までねじ込み、こじ開けるように左右に振る。'
	DB	"My tongue still inside her, I move it left and right."
	DB	NEXT
;	DB	'【星愛】：・・・あっ・・・！・・・あぅん・・・！'
	DB	"Seia:  Ahhhh! Ahhhhhhn!"
	DB	FLG,F_COPYI,3,5
	DW	0000H

M12:		;舐める　○○○○６
;	DB	'更に捻り込むように奥へと舌を伸ばす。'
	DB	"I push my tongue deeper, deeper into her center."
	DB	NEXT
;	DB	'【星愛】：・・・あぁっ・・・！'
	DB	"Seia:  ......Ahhh!"
	DB	FLG,F_COPYI,3,6
	DW	0000H

M13:		;舐める　○○○○７
;	DB	'一端舌を抜き、花びらの周りを嘗回す。'
	DB	"I take my tongue out and stimulate the area around her pussy."
	DB	NEXT
;	DB	'【星愛】：・・・あ・・・は・・・'
	DB	"Seia:  ....Ah.....Ahh..."
	DB	FLG,F_COPYI,3,7
	DW	0000H

M14:		;舐める　○○○○８
;	DB	'ほぼ花を咲かせた秘裂に、再び舌を差し込む。'
	DB	"I look at her pussy, lying before me like a flower in"
	DB	CR
	DB	"bloom. Then I plunge my tongue in again."
	DB	NEXT
;	DB	'【星愛】：・・・んあっ・・・！'
	DB	"Seia:  Ahhn!"
	DB	FLG,F_COPYI,3,4
	EF_SET 103
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,3,255,102,103
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'（・・・もう我慢出来ないっ！）'
	DB	"....I can't stand it any longer!"
	DB	NEXT
;	DB	'【星愛】：・・・あっ・・・！'
	DB	"Seia:  ......Ahnnn.....!"
	DB	NEXT
;	DB	'俺は吉田を四つんばいにさせると、爆発寸前の物を取り出し・・・'
;	DB	'一気に突き入れた。'
	DB	"I pull her up on her hands and knees, as her panting body"
	DB	CR
	DB	"glistens with sweet sweat.  Her head goes down as I"
	DB	CR
	DB	"run her clit roughly with my fingers."
	DB	NEXT
	DB	"I then push my cock head through her tight lips, which"
	DB	CR
	DB	"required me to push harder into her, holding her hips"
	DB	CR
	DB	"tighter so as to not lose my balance."
	DB	NEXT
	DB	SINARIO,'CSE_G_3.OVL',0
	DW	0000H


end
