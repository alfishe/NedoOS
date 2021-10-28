;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０３
;		ＧＷ初日　街で買物

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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	NN3,NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0

;NN1:	DB	1,	'荷物',0
NN1:	DB	1,	"BAGS",0
;NN2:	DB	2,	'街',0
NN2:	DB	2,	"CITY",0
;NN3:	DB	3,	'女の子',0
NN3:	DB	3,	"WOMEN",0
;NN4:	DB	4,	'連休',0
NN4:	DB	4,	"HOLIDAYS",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　荷物
S2:		DW	VV1, NN2,  2, M3		;見る　街
S3:		DW	VV2, -1,  3, M4, M5		;話す
S4:		DW	VV3, NN3,  4, M6		;考える　女の子
S5:		DW	VV3, NN4,  5, M7		;考える　連休


;イニシャルメッセージ
M1:
	DB	BGM,17
	BAK_INIT 'AB_43_1'
	B_P1 B_SUDA
;	DB	'・・・そして、ＧＷ初日。'
	DB	"Today is the first day of Golden Week."
	DB	NEXT
;	DB	'俺と鈴子さん、新藤さん、美緒ちゃんは駅前にショッピングに来ていた。'
	DB	"Reiko, Kiyomi, Mio and I met in front of the station to"
	DB	CR
	DB	"go shopping."
	DW	0000H

M2:		;見る　荷物
;	DB	'俺は特に買いたい物もないから、３人の荷物持ちだ。'
	DB	"There wasn't anything I really wanted to buy, so I ended"
	DB	CR
	DB	"up carrying all of their bags."
	DB	NEXT
;	DB	'・・・しかし、ずいぶんいろいろ買ったなみんな。'
	DB	"They were heavy!"
	EF_SET 101
	DW	0000H

M3:		;見る　街
;	DB	'休み中だけあって、人でごった返している。'
	DB	"Since it was a holiday today, everyone was out shopping."
	DW	0000H

M4:		;話す
	DB	BUF,B_COPY01
	T_CG "CT01",'F',0,35,1		;ＣＧ 
;	DB	'【鈴子】：ごめんね%001君、荷物持ってもらっちゃって・・・'
	DB	"Reiko:  Sorry about making you carry the bags, %001."
	DB	NEXT
;	DB	'【%001】：いーからいーから。'
	DB	"%001:  Oh, it's no problem."
	DB	NEXT
	T_CG "CT03",'F',0,10,2		;ＣＧ 
	DB	ANI,A_ON,1
;	DB	'【美緒】：鈴子先輩、これからどうするの？'
	DB	"Mio:  Reiko, what should we do now?"
	DB	NEXT
;	DB	'【鈴子】：そうねぇ・・・'
	DB	"Reiko:  Let me see...."
	DB	NEXT
	T_CG "CT02",'F','K',0,3		;ＣＧ　清美 
	DB	ANI,A_ON,2
	DB	ANI,A_ON,1
;	DB	'【清美】：確か今日、あそこのデパートでバザールをやっているはずですわ。'
	DB	"Kiyomi:  Well, that department store over there is having"
	DB	CR
	DB	"a great sale today."
	DB	NEXT
;	DB	'【鈴子】：ゼロワンデパートで？'
	DB	"Reiko:  Zero One?"
	DB	NEXT
;	DB	'【清美】：わたくしたちも参りませんか？'
	DB	"Kiyomi:  Shall we go there next?"
	DB	FLG,F_COPYI,3,1
	EF_SET 102
	DW	0000H

M5:		;話す
;	DB	'【清美】：ゼロワンデパートに参りましょう。'
	DB	"Kiyomi:  Well, let's go there, then."
	DW	0000H


M6:		;考える　女の子
;	DB	'女の子たちって、どうしてこう買い物が好きなんだろうな？'
	DB	"I wonder why women like shopping so much?"
	EF_SET 103
	DW	0000H

M7:		;考える　連休
;	DB	'今年のゴールデンウィークは４連休だ。'
	DB	"Golden Week is a week of holidays in Japan."
	DB	NEXT
	DB	"By accident, several Japanese holidays, such as Children's"
	DB	CR
	DB	"Day, National Foundation Day and Emperor Hirohito's"
	DB	CR
	DB	"birthday took place in the same week."
	DB	NEXT
	DB	"The travel industry added the name Golden Week as a means"
	DB	CR
	DB	"of getting people to travel more."
	DB	NEXT
;	DB	'どうせやることもなかったし、今日は３人に付き合おう。'
	DB	"Well, I don't have any money for that, so I might as well"
	DB	CR
	DB	"hang out with these three."
	EF_SET 104
	DW	0000H


M_EXIT:
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,5,255,101,102,103,104
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'【鈴子】：それじゃ、ゼロワンデパートも覗いてみましょうか。'
	DB	"Reiko:  Well, let's check out Zero One, then."
	DB	NEXT
;	DB	'【美緒】：さんせーい！'
	DB	"Mio:  Sure!"
	DB	NEXT
;	DB	'俺は３人の荷物を抱えて、ゼロワンデパートについていった。'
	DB	"We all went inside."
	DB	NEXT
	DB SINARIO,'CS404.OVL',0
	DW	0000H


end