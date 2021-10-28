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

CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1

VV1:	DB	1,	"LOOK",0
VV2:	DB	2,	"TALK",0

NN1:	DB	1,	"FEMALE STUDENT",0

S1:		DW	VV1, NN1,  1, M2, M3		; VV1=Look, submeny=Reiko,nummerering, Last inn M2 og M3
S2:		DW	VV2, NN1,  2, M4, M5		; VV2=Talk, submeny=reyko,nummerering, last inn M4 og M3

M1:
	DB	BGM,4
	BAK_INIT "AB_04_1"
	B_P1 B_SUDA
	DB	"I run like the wind for school. I'll be in trouble if I'm"
	DB	CR
	DB	"late on the first day."
	DB	NEXT
	DB	"It's a good thing the school is less than a mile from my"
	DB	CR
	DB	"house."
	DB	NEXT
	DB	"Actually, that's the reason I chose this place."
	DB	NEXT
	DB	"I'm a pretty good runner if I say so myself. I've done"
	DB	CR
	DB	"the hundred meter in 11.2 seconds. I'll probably make it"
	DB	CR
	DB	"on time."
	DB	NEXT
	DB	"I can see the school now..."
	DB	NEXT
	DB	"Turn at the corner and..."
	DB	NEXT
	DB	"What?!!"
	DB	NEXT
	DB	"???:  Yaaa!"
	DB	NEXT
	DB	"I'm going to crash...!!"
	DB	NEXT
	DB	"I went into a roll just before running into the woman."
	DB	NEXT
	DB	"I touch the ground with one hand and push back, spinning"
	DB	CR
	DB	"around and landing on my feet."
	DB	NEXT
	DB	"Safe!"
	DB	NEXT
	E_CG B_NORM,"AE_001"		; les inn reiko
	DB	"%001:  I'm sorry! Are you okay?"
	DB	NEXT
	DB	"???:  Uh, yeah, I think..."
	DW	0000H



M2:		;見る　女生徒
;	DB	"直接ぶつかったわけじゃないが、彼女はバランスを失ってペタンと尻餅をついている。"
	DB	"I didn't hit her full on. But she lost her balance and"
	DB	CR
	DB	"fell on her butt."
	DB	NEXT
;	DB	"【%001】：その・・・立てる？"
	DB	"%001:  Uh, can you stand up?"
	DB	NEXT
;	DB	"【鈴子】：うん、何ともないわ。"
	DB	"Woman:  Yeah, it was nothing."
	DB	NEXT
;	DB	"彼女は何事もなかったように立ち上がって、スカートに付いたホコリを手で払った。"
	DB	"She stood up like nothing happened and brushed the dust"
	DB	CR
	DB	"from her skirt."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　女生徒
;	DB	"よかった、特に怒った風でもない。"
	DB	"She doesn't seem mad."
	DB	NEXT
;	DB	"俺に向かって微笑んでくれている。"
	DB	"She turns and smiles at me."
	DB	NEXT
;	DB	"・・・結構美人だな。"
	DB	".....Pretty cute."
	DW	0000H


M4:		;話す　女生徒
;	DB	"【%001】：スカート汚しちゃったな、本当に悪ィ。"
	DB	"%001:  Your skirt is all dirty. I'm really sorry."
	DB	NEXT
;	DB	"【鈴子】：ううん、大した事ないから。"
	DB	"Reiko:  It's no big deal, really."
	DB	NEXT
;	DB	"【鈴子】：・・・それにしてもすごい軽業ね。"
	DB	"Reiko:  That was a pretty impresive dodge."
	DB	NEXT
;	DB	"【%001】：そう？"
	DB	"%001:  Really?"
	DB	NEXT
;	DB	"【鈴子】：キミ、体操部なの？"
	DB	"Reiko:  Are you on the gymnastics team or anything?"
	DB	NEXT
;	DB	"【%001】：今んとこその予定はないよ。俺、新入生だから。"
	DB	"%001:  I really don't have any plans for a club or"
	DB	CR
	DB	"anything. I'm a freshman."
	DB	NEXT
;	DB	"【鈴子】：あら、そうだったの？"
	DB	"Reiko:  Is that so?"
	DB	FLG,F_COPYI,2,1
	DW	0000H


M5:		;話す　女生徒
	DB	BUF,B_COPY01
	T_CG "CT01","W",0,15,1
;	DB	"【鈴子】：挨拶がまだだったわね。私は沢村　鈴子（れいこ）、"
	DB	"Reiko:  I haven't introduced myself yet have I? I'm Reiko"
	DB	CR
	DB	"Sawamura. Senior, A class."
	DB	NEXT
;	DB	"【%001】：俺は山神　%001、１年でクラスはまだ分からないんだ。"
	DB	"%001:  I'm %001 Yamagami, a new freshman. I don't know"
	DB	CR
	DB	"what class I'm in yet."
	DB	NEXT
;	DB	"【鈴子】：そう言えば・・・入学式、８時半からでしょ？急がなきゃ！"
	DB	"Reiko:  Come to think of it, the entrance ceremony is at"
	DB	CR
	DB	"8:30, isn't it? You'd better hurry."
	DB	NEXT
;	DB	"【%001】：あっそうだったヤバイ！"
	DB	"%001:  That's right. Shit!"
	DB	NEXT
;	DB	"【鈴子】：講堂はそこの向かって一番左の建物よ。"
	DB	"Reiko:  The lecture hall is over there, the building on"
	DB	CR
	DB	"the far right."
	DB	NEXT
;	DB	"【%001】：サンキュ、先輩！"
	DB	"%001:  Thanks!"
	DB	NEXT
;	DB	"俺は彼女の指し示した建物目掛けて再び全力疾走した。"
	DB	"I set my sights on the building that Reiko pointed out"
	DB	CR
	DB	"and run like mad."
	DB	NEXT
;	DB	"・・・・・・・・・・・・"
	DB	"Reiko:  Hmmmmm."
	DB	NEXT
;	DB	"【鈴子】：山神　%001君か・・・ホント、元気な子ね。"
	DB	"Reiko:  %001 Yamazaki, huh. He sure is full of energy."
	DB	NEXT
;	DB	"【鈴子】：ふふっ、なんか少女漫画みたいな出会いだったわ。"
	DB	"Reiko:  Hahaha. A meeting, just like in a romance novel."
	DB	NEXT
;	DB	"【鈴子】：・・・もしかして、本当に運命の出会い・・・？"
	DB	"Reiko:  Could it be? You never know about these things..."
	DB	NEXT
;	DB	"【鈴子】：な～んて、そんなわけないか☆"
	DB	"Reiko:  Well, maybe not. Things just aren't like that in"
	DB	CR
	DB	"real life."
	DB	NEXT
	DB SINARIO,"CS103.OVL",0
	DW	0000H


end
