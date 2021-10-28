;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　E_E_3
;		瑠璃エンディング３
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

;VV1:	DB	1,	'抱きしめる',0
VV1:	DB	1,	'HOLD HER',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;抱きしめる


;イニシャルメッセージ
M1:
	DB	BGM,31
;	DB	'【瑠璃】：そんな言葉・・・聞きたくなかったわ。'
	DB	"Ruri:  ............................",NEXT
	DB	"Ruri:  I didn't want to hear those words from you."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・・・そか。'
	DB	"%001:  .......I see."
	DB	NEXT
	E_CG B_FADE,"AE_182"
;	DB	'【瑠璃】：やっと決心したのに・・・お母様のところに帰れなくなるじゃない・・・！'
	DB	"Ruri:  I'd finally... I'd finally made up my mind to go"
	DB	CR
	DB	"back to Mother... Now how can I go?"
	DB	NEXT
;	DB	'【%001】：・・・え・・・っ・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'【瑠璃】：帰って！今すぐに！'
	DB	"Ruri:  Please leave! Right now!"
	DB	NEXT
;	DB	'【瑠璃】：私はお母様のところに帰るの！',PAUSE,CR,'でも、%001君と離れるのは嫌！'
	DB	"Ruri:  I've got to go home to Mother!",PAUSE
	DB	" But I don't want to"
	DB	CR
	DB	"leave you!"
	DB	NEXT
;	DB	'【瑠璃】：あなたが好きなの・・・でも、お母様のところに帰らなきゃいけないの！'
	DB	"Ruri:  I love you, %001... But I've got to go home to"
	DB	CR
	DB	"Mother!"
	DB	NEXT
	E_CG B_FADE,"AE_183"
;	DB	'【瑠璃】：だから・・・帰って。'
	DB	"Ruri:  So....I want you to leave..."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  .................."
	DW	0000H

M2:		;抱きしめる
;	DB	'俺は問答無用で白水さんを抱きしめた。',CR,'白水さんは抵抗しなかった。'
	DB	"Without saying anything, I take Ruri into my arms. She"
	DB	CR
	DB	"doesn't resist."
	DB	NEXT
;	DB	'【%001】：・・・白水さん。'
	DB	"%001:  ...........Ruri..."
	DB	NEXT
;	DB	'【瑠璃】：・・・放して・・・'
	DB	"Ruri:  Let go of me..."
	DB	NEXT
;	DB	'【%001】：どうして？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【瑠璃】：私はあなたを傷つけてしまう・・・'
	DB	"Ruri:  I don't want to hurt you..."
	DB	NEXT
;	DB	'【%001】：白水さん・・・'
	DB	"%001:  Ruri...."
	DB	NEXT
;	DB	'【%001】：・・・俺を傷つけたくないんだったら、俺から逃げないでくれ。'
	DB	"%001:  .....If you don't want to hurt me, then don't run"
	DB	CR
	DB	"away from me like this."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .............."
	DB	NEXT
;	DB	'【%001】：俺はどこまでだって君を追いかける。'
	DB	"%001:  I don't care how far away you run. I'll always find"
	DB	CR
	DB	"you again... Because I love you."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ........."
	DB	NEXT
;	DB	'【%001】：体の傷なんかどーってことはねぇ。病院に行けば、治るしな。'
	DB	"%001:  Being hurt isn't anything to be afraid of."
	DB	NEXT
;	DB	'【%001】：君がそばにいないことの方が、俺には苦痛なんだ。'
	DB	"%001:  But losing you forever... That's something I could"
	DB	CR
	DB	"never bear."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ................"
	DB	NEXT
;	DB	'【%001】：だから・・・白水さんが俺のことを好きなら、',CR,'俺から逃げないでくれ！'
	DB	"%001:  If you really do love me...then don't run away"
	DB	CR
	DB	"from me anymore!"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ................."
	DB	NEXT
;	DB	'【瑠璃】：ずっと・・・そばにいてくれる・・・の？'
	DB	"Ruri:  Can I.....Can I believe what you're saying?"
	DB	NEXT
	DB	"Ruri:  Will you really stay with me forever?"
	DB	NEXT
;	DB	'【%001】：白水さんが望むなら。'
	DB	"%001:  If that's what you want."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ............................"
	DB	NEXT
;	DB	'【瑠璃】：入って、%001君。・・・傷の手当てをしないと。'
	DB	"Ruri:  Come in, %001. I'll take care of that blood."
	DB	NEXT
	DB SINARIO,'CSE_E_4.OVL',0
	DW	0000H


end
