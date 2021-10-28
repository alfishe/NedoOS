;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　ＣＳＥ＿Ｅ＿１
;		瑠璃エンディング
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
CM1:	DW	VV1,	-1

;VV1:	DB	1,	'走る',0
VV1:	DB	1,	'RUN',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3, M4, M5		;走る


;イニシャルメッセージ
M1:
	DB	BGM,25
	E_CG B_FADE,"AB_08_3"
;	DB	'月明かりを頼りに、俺は山道を走りに走った。'
	DB	"By the light of the moon, I ran along the mountain trail."
	DB	NEXT
;	DB	'【%001】：うわ！'
	DB	"%001:  Wahh!!"
	DB	NEXT
;	DB	'【%001】：つつ・・・'
	DB	"%001:  Ouch...."
	DB	NEXT
;	DB	'視界は最悪。俺は何度もつまずいて転んだ。'
	DB	"I couldn't see anything. I fell again and again."
	DB	NEXT
;	DB	'【%001】：白水さん・・・！'
	DB	"%001:  Ruri...!!"
	DB	NEXT
;	DB	'それでも俺は全力で走った。'
	DB	"But I didn't care. I kept on running."
	DW	0000H

M2:		;走る
	E_CG B_FADE,"AB_08_2"
;	DB	'どれだけ走れば駅にたどり着くんだ？'
	DB	"How long can it take to get to the stupid train station?"
	DB	NEXT
;	DB	'いくら走っても、街の明かりは見えてこない。'
	DB	"No matter how long I ran, the lights from the city seemed"
	DB	CR
	DB	"far off."
	DB	NEXT
;	DB	'足の速さには自身あったんだが、今の俺は自分ののろさがもどかしくてしょうがなかった。'
	DB	"I had thought I was a pretty good runner, but it made no"
	DB	CR
	DB	"difference now."
	DB	FLG,F_COPYI,1,1
	DW	0000H


M3:		;走る
	E_CG B_FADE,"AB_08_3"
;	DB	'走っても走っても、駅は見えてこない。'
	DB	"I still can't see the train station."
	DB	NEXT
;	DB	'・・・道を間違えた？'
	DB	".....Could I have taken the wrong turn?"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"........................................"
	DB	NEXT
;	DB	'とにかく、下れば麓に着くはずだ！'
	DB	"I don't think so. As long as I'm running down the mountain,"
	DB	CR
	DB	"I'll get into the town eventually."
	DB	FLG,F_COPYI,1,2
	DW	0000H


M4:		;走る
;	DB	'！　明かりだ！'
	DB	"Oh! I can see some lights!"
	DB	NEXT
;	DB	'眼下に街の明かりが見えて来た。'
	DB	"As I ran, the lights of the city finally began to appear."
	DB	NEXT
;	DB	'白水さん・・・絶対絶対、君に追い付く！'
	DB	"Ruri! I'm going to catch up with you! I will!"
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;走る
	B_O B_SUDA
;	DB	'俺は駅に駆け込んだ。'
	DB	"I ran into the station."
	DB	NEXT
;	DB	'【%001】：ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、ぜはーっ、・・・'
	DB	"%001:  *pant*.....*pant*.....*pant*.....*pant*.....*pant*..."
	DB	NEXT
;	DB	'【%001】：・・・・・・駅員さん！○○駅まで超特急でやってくれ！'
	DB	"%001:  ........Excuse me! I need a ticket for Tokyo!"
	DB	NEXT
;	DB	'【駅員】：あぁ、君のことは電話で聞いてるよ。ほら、切符と特急券。２番ホームだ。'
	DB	"Station man:  Yes, I heard you'd be coming this way.  You"
	DB	CR
	DB	"need to wait on platform number two."
	DB	NEXT
;	DB	'俺は切符を買って、電車に駆け込んだ。'
	DB	"I bought a ticket and ran into the train."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	"................................................."
	DB	NEXT
	DB SINARIO,'CSE_E_2.OVL',0
	DW	0000H


end
