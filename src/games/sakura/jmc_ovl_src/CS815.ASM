;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１５
;		今日子の特別授業２

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
CM3:	DW	VV3,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'受ける',0
VV2:	DB	2,	'ACCEPT',0
;VV3:	DB	3,	'話す',0
VV3:	DB	3,	'TALK',0

;NN1:	DB	1,	'今日子',0
NN1:	DB	1,	'KYOKO',0
;NN2:	DB	2,	'特別授業',0
NN2:	DB	2,	'SPECIAL LESSON',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　今日子２
S2:		DW	VV2, NN2,  2, M4, M5, M6		;受ける　特別授業３
S3:		DW	VV3, NN1,  3, M7		;話す　今日子１


;イニシャルメッセージ
M1:
	DB	BGM,32
	E_CG B_SUDA,"AE_121"
;	DB	'【%001】：・・・ち、',PAUSE,'ちょっと先生！？'
	DB	"%001:  .......But Sensei! I could never..."
	DB	NEXT
;	DB	'【今日子】：い・い・か・ら。'
	DB	"Kyoko:  It's okay."
	DB	PAUSE
;	DB	'おねーさんに全てまかせなさい。'
	DB	" Just leave everything to me."
	DW	0000H

M2:		;見る　今日子１
;	DB	'・・・何と言うか、恐いほど艶っぽい表情だ。'
	DB	"She's scaring me. She's looking at me, but she seems to"
	DB	CR
	DB	"be looking through me."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　今日子２
;	DB	'・・・先生が狼に見える・・・'
	DB	"Her expression.... She looks like a wolf."
	DW	0000H

M4:		;受ける　特別授業１
;	DB	'【今日子】：まずは、これからね。'
	DB	"Kyoko:  The first part of our curriculum is..."
	DB	NEXT
;	DB	'ちゅっ。'
	DB	"Kyoko:  Kissing."
	DB	NEXT
;	DB	'【%001】：・・・あ・・・'
	DB	"%001:  .........Kissing?"
	DB	NEXT
;	DB	'唇を触れ合わせるだけの、軽いキス。'
	DB	"She leaned over the kissed me lightly on my mouth."
	DB	NEXT
;	DB	'それでも俺の身体は、感電したかのように硬直した。'
	DB	"Even so, I felt an electric shock go through my body."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;受ける　特別授業２
;	DB	'【今日子】：・・・キスも、初めて？'
	DB	"Kyoko:  Was that your first?"
	DB	NEXT
;	DB	'【%001】：・・・（こくっ）'
	DB	"%001:  .....*gulp*"
	DB	NEXT
;	DB	'【今日子】：・・・じゃあ、こんなのも初めてね？'
	DB	"Kyoko:  Then what about this?"
	DB	NEXT
;	DB	'言うなり、先生は再び唇をあわせる。'
	DB	"She put her lips against mine again."
	DB	NEXT
;	DB	'【%001】：・・・！！'
	DB	"%001:  .....!!"
	DB	NEXT
;	DB	'突然、俺の口に何かが入って来る。'
	DB	"But this time, something warm and wet entered my mouth."
	DB	NEXT
;	DB	'【今日子】：・・・ん・・・'
	DB	"Kyoko:  ..........Mmmm..."
	DB	NEXT
;	DB	'その何かは俺の口の中を散々に暴れまわり・・・俺はただ、'
;	DB	'目を白黒させるだけだった。'
	DB	"As her tongue moved around inside my mouth, my vision"
	DB	CR
	DB	"went blurry."
	DB	NEXT
;	DB	'【今日子】：・・・・・・はぁっ・・・・・・'
	DB	"Kyoko:  ...........%001..."
	DB	NEXT
;	DB	'ようやく今日子先生が離れた頃・・・俺はもう、何がなんだか分らなくなっていた。'
	DB	"By the time she moved her mouth away from mine, I didn't"
	DB	CR
	DB	"know what was happening to my world."
	DB	NEXT
;	DB	'【今日子】：・・・今のが、大人のキスよ。凄いでしょう？'
	DB	"Kyoko:  That was a grown-up's kiss. Did you like it?"
	DB	NEXT
;	DB	'俺は、惚けたようにただ頷いた。'
	DB	"I just nodded."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;受ける　特別授業３
;	DB	'【今日子】：さ・・・次行くわよ。'
	DB	"Kyoko:  Let's move on with the lesson."
	DB	NEXT
	DB	SINARIO,'CS816.OVL',0
	DW	0000H

M7:		;話す　今日子１
;	DB	'【%001】：・・・せ、先生・・・'
	DB	"%001:  S- Sensei..."
	DB	NEXT
;	DB	'【今日子】：大丈夫。力を抜いて・・・'
	DB	"Kyoko:  It's okay, %001. I'll teach you..."
	DW	0000H


end
