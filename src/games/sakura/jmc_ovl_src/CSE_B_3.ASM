;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ｂ＿３
;		清美Ｈ２

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

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'なめる',0
VV2:	DB	2,	'LICK',0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3		;見る
S2:		DW	VV2, -1,  2, M4, M5		;舐める


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'【清美】：ああっ！'
	DB	"Kiyomi:  Ah...!"
	E_CG B_FADE,'AE_154'
	DB	NEXT
;	DB	'【清美】：こ・・・・・・こんなはしたない格好・・・！'
	DB	"Kiyomi:  .......This is going to be hard for me..."
	DB	NEXT
;	DB	'【%001】：清美の計画にはなかったって？'
	DB	"%001:  But it was all written down on your schedule..."
	DB	NEXT
;	DB	'【清美】：恥ずかしい・・・！'
	DB	"Kiyomi:  Don't remind me! I'm so embarrassed!"
	DB	NEXT
;	DB	'【%001】：清美・・・もうこんなに濡らしてたんだね・・・'
	DB	"%001:  Kiyomi...you're already so wet..."
	DB	NEXT
;	DB	'【清美】：そんな事、言わないで・・・！'
	DB	"Kiyomi:  I don't know about things like that..."
	DW	0000H

M2:		;見る
;	DB	'俺の目の前には、清美の・・・がある。'
	DB	"Kiyomi is before me, waiting...willing."
	DB	NEXT
;	DB	'ひぁ～・・・こうなってるんだ・・・'
	DB	"The time is finally here."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る
;	DB	'清美の・・・からは汁がこんこんとわき出してる。'
	DB	"Kiyomi's leaking a stream of honey."
	DB	NEXT
;	DB	'ひぁ～・・・すげえ・・・'
	DB	"Incredible...there's so much..."
	DW	0000H

M4:		;愛撫する
;	DB	'清美の谷間から溢れ出る蜜を、舌で舐め取る。'
	DB	"I move my head down and lick her burning pussy."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・！'
	DB	"Kiyomi:  ................!"
	DB	NEXT
;	DB	'声にならない叫びを上げて、清美が身悶える。'
	DB	"Kiyomi lets out a shriek of pleasure, her body quivering."
	DB	NEXT
;	DB	'【%001】：スゴイや・・・舐めても舐めても出てくるよ・・・',CR,'ほら、見えるだろ？'
	DB	"%001:  Incredible, I can't believe you're so wet. Can"
	DB	CR
	DB	"you see?"
	DB	NEXT
;	DB	'【清美】：恥ずかしくて・・・死んでしまいそう・・・！'
;	DB	"Kiyomi:  I'm going to die of embarrassment!"
;	DB	NEXT
;	DB	'清美は両手で顔を覆って、いやいやをするように首を振った。'
	DB	"Kiyomi covered her eyes with her hands."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;愛撫する
;	DB	'俺は無心に清美の蜜を吸う。'
	DB	"I continued to stimulate her pussy with my mouth."
	DB	NEXT
;	DB	'【清美】：%001さん・・・もうやめて・・・！'
	DB	"Kiyomi:  %001, please stop!"
	DB	NEXT
;	DB	'【%001】：どうして？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【清美】：わたくし・・・こんないやらしい女では・・・！'
	DB	"Kiyomi:  I'm not a perverted woman...!"
	DB	NEXT
;	DB	'【%001】：じゃあ、俺も脱ごう。'
	DB	"%001:  Okay, I'll take my clothes off, too."
	DB	NEXT
;	DB	'俺は服を脱ぎ出した。'
	DB	"I started to get undressed."
	DB	NEXT
;	DB	'【%001】：清美は俺をいやらしい男と思う？'
	DB	"%001:  Kiyomi, do you think I'm a perverted man?"
	DB	NEXT
;	DB	'【清美】：・・・・・・いいえ・・・・・・'
	DB	"Kiyomi:  No...."
	DB	NEXT
;	DB	'【%001】：俺も清美をはしたないなんて・・・よっ・・・このっ・・・'
	DB	"%001:  There isn't any part of you that's evil, or dirty,"
	DB	CR
	DB	"or wrong... It's all very natural."
	DB	NEXT
;	DB	'焦ってるせいで、腕が袖から抜けない。'
	DB	"In a hurry to discard my clothes, I couldn't get the"
	DB	CR
	DB	"sleeve button undone."
	DB	NEXT
;	DB	'【%001】：むしろ、嬉しいんだ。清美が普段は見せない表情を、俺に見せてくれることが。'
	DB	"%001:  It makes me happy...seeing a side to you that you"
	DB	CR
	DB	"can't show me at school."
	DB	NEXT
;	DB	'【%001】：だから・・・もっと正直になってごらん。'
	DB	"%001:  ........It's okay, Kiyomi. Tell me honestly if it"
	DB	CR
	DB	"feels good."
	DB	NEXT
;	DB	'清美のもっとも敏感な場所をきつく吸う。'
	DB	"I continued to kiss and suckle her clitoris, harder this"
	DB	CR
	DB	"time."
	DB	NEXT
;	DB	'【清美】：ひぃっ・・・！'
	DB	"Kiyomi:  Ah....!"
	DB	NEXT
;	DB	'【%001】：・・・・・・気持ちいい？'
	DB	"%001:  .......Do you like it?"
	DB	NEXT
;	DB	'【清美】：・・・・・・はい・・・気持ちいい、です・・・'
	DB	"Kiyomi:  .........Yes.....it's good....."
	DB	NEXT
;	DB	'【%001】：清美。俺は清美の中に入りたい。'
	DB	"%001:  Kiyomi, I'm want to go inside you now."
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  .........................."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・はい。'
	DB	"Kiyomi:  ........Alright."
	DB	NEXT
	DB	SINARIO,'CSE_B_4.OVL',0
	DW	0000H


end
