;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０８
;		河原の瑠璃

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'移動する',0
VV3:	DB	3,	"MOVE",0
;VV4:	DB	4,	'サバゲーに誘う',0
VV4:	DB	4,	"INVITE TO PLAY",0

NN1:	DB	1,	'RURI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　瑠璃
S2:		DW	VV2, NN1,  2, M3		;話す　瑠璃
S3:		DW	VV3, -1,  3, M4, M5, M6		;移動する
S4:		DW	VV4, -1,  4, M7, M8, M9		;サバゲーに誘う


;イニシャルメッセージ
M1:
	DB	BGM,31
	E_CG B_NORM,'AE_013'
;	DB	'【%001】：・・・あれは・・・'
	DB	"%001:  Hey, that's..."
	DB	NEXT
;	DB	'【誠】：白水さんじゃないか・・・。'
	DB	"Makoto:  Isn't that Ruri?"
	DB	NEXT
;	DB	'転校生、白水　瑠璃は土手に座り込んで、川の流れを眺めていた。'
	DB	"Ruri, the transfer student, was sitting on the riverbank"
	DB	CR
	DB	"and watching the water rush by."
	DB	NEXT
;	DB	'まるで放棄されたオブジェのように、身動き一つせず。'
	DB	"She was so still that she could have been carved of stone."
	DB	CR
;	DB	'瞬きさえ、忘れてしまったかのように。'
	DB	"It seemed like she had even forgotten to blink."
	DW	0000H

M2:	;見る　瑠璃
;	DB	'俺達が見てるのに気付いてるんだかいないんだか、ジッと川を眺めている。'
	DB	"She's staring at the river. She doesn't seem to notice"
	DB	CR
	DB	"us."
	DB	NEXT
;	DB	'邪魔しちゃ悪いか・・・。'
	DB	"Maybe we should leave her alone."
	DW	0000H

M3:	;話す　瑠璃
;	DB	'退屈そうだし・・・声かけてみよう。'
	DB	"She seems bored. We should talk to her."
	DB	NEXT
	DB SINARIO,'CS409.OVL',0
	DW	0000H

M4:	;移動する
;	DB	'【%001】：しゃあない。他の場所に移動するか。'
	DB	"%001:  Maybe we should go somewhere else."
	DB	NEXT
;	DB	'【誠】：ああ。だけど・・・気になるな、彼女。'
	DB	"Makoto:  I don't know. Something about the way she's"
	DB	CR
	DB	"looking at the water scares me."
	DB	NEXT
;	DB	'【%001】：何が？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【誠】：何か、自殺でもしそうな顔してるぜ・・・。'
	DB	"Makoto:  She might be contemplating suicide, for all we"
	DB	CR
	DB	"know."
	DB	NEXT
;	DB	'【%001】：・・・考え過ぎだろ。'
	DB	"%001:  ...I doubt that."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:	;移動する
;	DB	'【誠】：お前、彼女を放って行けるのか？'
	DB	"Makoto:  Do you want to ask her to leave?"
	DB	NEXT
;	DB	'【%001】：そんなに気になるんなら、声かけて見ろよ。'
	DB	"%001:  If it bothers you, ask her yourself."
	DB	NEXT
;	DB	'【誠】：それはお前に任せる。'
	DB	"Makoto:  I'll leave that to you."
	DB	NEXT
;	DB	'【%001】：はぁ？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【誠】：俺は彼女の転校初日にさんざん話し掛けたけど、お前はまだ彼女と話した事ないだろ？'
	DB	"Makoto:  I kept trying to talk to her on the first day"
	DB	CR
	DB	"she came to school, but you haven't talked to her at"
	DB	CR
	DB	"all, right?"
	DB	NEXT
;	DB	'【誠】：モテモテマンのお前にだったら、彼女も返事してくれるかもしれないぜ。'
	DB	"Makoto:  Well, she might talk to you, since you're so"
	DB	CR
	DB	"popular and everything."
	DB	NEXT
;	DB	'【%001】：誰がモテモテマンだ、誰が。'
	DB	"%001:  I'm not popular!"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M6:	;移動する
;	DB	'【誠】：な、彼女と話してみろよ。'
	DB	"Makoto:  Come on, go talk to her."
	DW	0000H

M7:	;サバゲーに誘う
;	DB	'【%001】：せっかくだから彼女も誘わないか？'
	DB	"%001:  Well, why don't we invite her to play with us...?"
	DB	NEXT
;	DB	'【誠】：%001・・・少しは考えて行動した方がいいぞ。'
	DB	"Makoto:  %001, we better think about this."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:	;サバゲーに誘う
;	DB	'【%001】：人数が多い方が面白いんじゃねーか？'
	DB	"%001:  Well, it'll be fun with more people, right?"
	DB	NEXT
;	DB	'【誠】：あの白水さんが付き合ってくれるわけないだろ？'
	DB	"Makoto:  Do you really think she'll hang out with us?"
	DB	NEXT
;	DB	'【誠】：お嬢様だぞ、お嬢様。'
	DB	"Makoto:  She's a rich girl, remember?"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M9:	;サバゲーに誘う
;	DB	'【%001】：転校して来てすぐ休みに入ったから、白水さん、友達いなくて退屈してるんだろ。'
	DB	"%001:  Ruri didn't have any time to make friends before"
	DB	CR
	DB	"the holidays. I'm sure she's lonely." 
	DB	NEXT
;	DB	'【誠】：そりゃそ～だけどさ、彼女を誘うんだったら他の遊びにしとこうぜ。'
	DB	"Makoto:  Well, maybe if we do invite to hang out with us, we"
	DB	CR
	DB	"should do something else."
	DW	0000H


end
