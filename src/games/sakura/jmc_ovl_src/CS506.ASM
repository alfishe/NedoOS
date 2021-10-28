;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０６
;		林間学校　大自然の大きな釣り堀

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	'MAKOTO',0
;NN2:	DB	2,	'川',0
NN2:	DB	2,	'RIVER',0
;NN3:	DB	3,	'釣竿',0
NN3:	DB	3,	'FISHING ROD',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　誠１
S2:		DW	VV1, NN2,  2, M3		;見る　川１
S3:		DW	VV1, NN3,  3, M4		;見る　釣竿１
S4:		DW	VV2, NN1,  4, M5, M6		;話す　誠２
S5:		DW	VV3,  -1,  5, M7, M8, M9, M10, M11, M12, M13, M14, M15		;考える

;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT "AB_09_3"
	DB BUF,B_COPY01
	T_CG "CT14","T",0,25,1
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ....."
	DB	PAUSE
;	DB	'ふぁ～あ・・・・・・'
	DB	"Wahh!"
	DB	NEXT
;	DB	'【誠】：・・・おい。人のすぐ横で、でけぇあくびするなよな。'
	DB	"Makoto:  Hey, don't be so loud! You scared me."
;	DB	PAUSE,CR
;	DB	'ふぁ～～～～～～ぁ・・・'
;	DB	"Wahh!!"
	DW	0000H

M2:		;見る　誠１
;	DB	'昨日遅くまで騷いでたせいで、眠そうだ。'
	DB	"He looks sleepy. He was up late last night."
	DB	NEXT
;	DB	'（俺も眠いぞ・・・とばっちりで。）'
	DB	"I'm pretty sleepy too."
	DW	0000H

M3:		;見る　川１
;	DB	'川幅の割には、かなり流れが速い。'
	DB	"The water's moving surprisingly fast in this river."
	DB	NEXT
;	DB	'（・・・昨日の雨のせいか？）'
	DB	"Maybe that's because of the rain yesterday."
	DW	0000H

M4:		;見る　釣竿１
;	DB	'さっきから、ピクリとも動かない。'
	DB	"No fish are biting."
	DB	NEXT
;	DB	'（・・・ホントに魚いるのか？この川・・・）'
	DB	"Are there even any fish in this river?"
	DW	0000H

M5:		;話す　誠１
;	DB	'【%001】：・・・おーい誠ぉ・・・釣れたかぁ？'
	DB	"%001:  Catch anything?"
	DB	NEXT
;	DB	'【誠】：・・・まだだぁ・・・'
	DB	"Makoto:  Not yet."
	DW	0000H

M6:		;話す　誠２
;	DB	'【%001】：・・・誠、ここ頼む。'
	DB	"%001:  Makoto, will you watch my rod for a minute?"
	DB	NEXT
;	DB	'【誠】：・・・あん？'
	DB	"Makoto:  Why?"
	DB	NEXT
;	DB	'【%001】：ちょっと、他の連中見て来る・・・ここは、場所が悪いのかも知れねぇ。'
	DB	"%001:  I'm going to go see how the others are doing."
	DB	CR
	DB	"Maybe this is a bad spot or something."
	DB	NEXT
;	DB	'【誠】：・・・分かった。'
	DB	"Makoto:  Okay."
	DB	NEXT
	DB	SINARIO,'CS507_1.OVL',0
	DW	0000H

M7:		;考える１
;	DB	'（・・・・・・・・・）'
	DB	"....................."
	DB	NEXT
;	DB	'（・・・・・・暇だ・・・・・・）'
	DB	"............This is boring."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M8:		;考える２
;	DB	'（・・・・・・・・・）'
	DB	"....................."
	DB	NEXT
;	DB	'（・・・・・・眠い・・・・・・）'
	DB	"............I'm sleepy."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M9:		;考える３
;	DB	'（・・・・・・・・・）'
	DB	"....................."
	DB	NEXT
;	DB	'（・・・・・・釣れん・・・・・・）'
	DB	".............We're not going to catch anything out here."
	DB	FLG,F_COPYI,5,3
	DW	0000H

M10:		;考える４
;	DB	'（・・・・・・・・・）'
	DB	"....................."
	DB	NEXT
;	DB	'（・・・・・・暇だ・・・・・・）'
	DB	"...................I'm still bored."
	DB	FLG,F_COPYI,5,4
	DW	0000H

M11:		;考える５
;	DB	'（・・・・・・・・・）'
	DB	"........................."
	DB	NEXT
;	DB	'（・・・・・・眠い・・・・・・）'
	DB	".....................I'm still sleepy."
	DB	FLG,F_COPYI,5,5
	DW	0000H

M12:		;考える６
;	DB	'（・・・・・・・・・）'
	DB	"....................."
	DB	NEXT
;	DB	'（・・・・・・釣れん・・・・・・）'
	DB	"...............I'm still not catching anything."
	DB	FLG,F_COPYI,5,6
	DW	0000H

M13:		;考える７
;	DB	'（・・・・・・・・・何で、釣れないんだ？）'
	DB	"Why can't I catch any fish?"
	DB	FLG,F_COPYI,5,7
	DW	0000H

M14:		;考える８
;	DB	'（・・・やっぱ、場所が悪いのか？）'
	DB	"Maybe this is a bad location after all."
	DB	NEXT
;	DB	'（・・・・・・・・・）'
	DB	"............................."
	DB	NEXT
;	DB	'（他の連中、釣れてんのかな？）'
	DB	"I wonder how the others are doing?"
	DB	FLG,F_COPYI,5,8
	DW	0000H

M15:		;考える９
;	DB	'（ちょいと、冷やかしてみるか。）'
	DB	"Guess I'll take a break."
	DB	FLG,F_COPYI,4,1
	DW	0000H


end
