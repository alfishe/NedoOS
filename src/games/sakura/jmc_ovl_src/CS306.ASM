;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　３０６
;		星愛の着替え

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'星愛',0
NN1:	DB	1,	"SEIA",0
;NN2:	DB	2,	'胸',0
NN2:	DB	2,	"BREASTS",0
;NN3:	DB	3,	'パンティ',0
NN3:	DB	3,	"PANTIES",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　星愛３
S2:		DW	VV1, NN2,  2, M5		;見る　胸１
S3:		DW	VV1, NN3,  3, M6		;見る　パンティ１
S4:		DW	VV2, NN1,  4, M7		;話す　星愛１


;イニシャルメッセージ
M1:
	DB	BGM,1
	E_CG B_NORM,"AE_008"
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ......................."
	DB	NEXT
;	DB	'【%001】：・・・お、お、おい！？いったい何をっ！？'
	DB	"%001:  H- Hey! What are you...!?"
	DW	0000H

M2:		;見る　星愛１
;	DB	'上衣も何も全部脱いで、今はパンツ一丁だ。'
	DB	"She has taken off her shirt and is now topless. All she"
	DB	CR
	DB	"has on are her panties."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".............................."
	DB	NEXT
;	DB	'この場合、パンティ一丁か？'
	DB	"What the hell is happening?"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"............................"
	DB	NEXT
;	DB	'ちっがーう！んな事考えてる場合じゃない！'
	DB	"What the hell am I thinking?!"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　星愛２
;	DB	'【%001】：・・・もしかして・・・寝惚けてんのか、こいつ？'
	DB	"%001:  Is she sleepwalking?"
	DB	NEXT
;	DB	'そう思って良く見ると、目の焦点が合っていない。'
	DB	"Her eyes don't seem to be focusing on anything."
	DB	NEXT
;	DB	'【%001】：・・・まったく、とんでもなく酒癖悪いんだな。中野と'
	DB	"I think she should avoid drinking in the future. Meimi,"
	DB	CR
	DB	"too."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　星愛３
;	DB	'【星愛】：・・・む～・・・'
	DB	"Seia:  ........Mmmmm........"
	DB	NEXT
;	DB	'ごそごそごそごそ'
	DB	"*SHUFFLE SHUFFLE*"
	DB	NEXT
;	DB	'俺が見守る中、吉田はパンティ一丁の格好のままあちこち歩き回った。'
	DB	"As I watch, Seia walks back and forth in just her panties."
	DB	NEXT
;	DB	'【%001】：・・・なんか捜してるのか？'
	DB	"%001:  .....Is she looking for something?"
	DB	NEXT
;	DB	'ややしばらく、吉田はその辺をうろつき回っていたが・・・結局、捜し物は'
	DB	"She walks around for a while, searching for something..."
	DB	NEXT
	DB	"But she doesn't find it, whatever it is. She stumbles over"
	DB	CR
	DB	"to the bed, and falls into it."
	DB	NEXT
	E_CG B_NORM,"AE_007"
;	DB	'【星愛】：・・・く～・・・すぴ～・・・'
	DB	"Seia:  ......Gooo.....Supi...."
	DB	NEXT
;	DB	'【%001】：・・・何だったんだ？一体・・・'
	DB	"%001:  ......What in the world is she saying?"
	DB	NEXT
	DB	"If I left her like that she'd catch a cold for sure. So"
	DB	CR
	DB	"I cover her with a blanket and leave the room."
	DB	NEXT
	DB	SINARIO,'CS307.OVL',0
	DW	0000H

M5:		;見る　胸１
;	DB	'・・・しかし吉田って、結構胸あるんだな。服着てるときはわかんなかったけど。'
	DB	".....She sure has some great tits. I never noticed when"
	DB	CR
	DB	"she had clothes on."
	DB	NEXT
;	DB	'これが世に言う「着痩せするタイプ」って奴か？西野さんくらいはあるぞ、'
	DB	"She just looks slim in clothes. But she has to be at"
	DB	CR
	DB	"least as big as Shoko."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".............................."
	DB	NEXT
;	DB	'んなとこ見てるよりも、迅速に解決しなければならない問題があるよ～な気がするぞ。すっごく。'
	DB	"Looking at her is giving me a raging hard-on."
	DW	0000H

M6:		;見る　パンティ１
;	DB	'ピンクのパンティだ。いかにもすべすべしてそ～な光沢がある。'
	DB	"Pink panties. They look smooth and soft to the touch."
	DB	NEXT
;	DB	'シルクかなんかか？アレって高いらしいけど・・・・・・'
	DB	"Are they silk? I hear that stuff is expensive........."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"..............................."
	DB	NEXT
;	DB	'なんだかんだ言って、観察してるのかな・・・俺。'
	DB	"No matter how you look at it, I am just leering at this"
	DB	CR
	DB	"woman."
	DW	0000H

M7:		;話す　星愛１
;	DB	'【%001】：・・・お、おい吉田っ！？'
	DB	"%001:  .....Uh, Seia!?"
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ........................."
	DW	0000H


end