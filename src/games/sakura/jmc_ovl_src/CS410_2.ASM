;	さくらの季節 
;		シーン　４１０＿２
;	ファーストフード・Ｍバーガー

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
	
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HsceneCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	 NN1,NN2,-1
CM2:	DW	VV2,	 NN3,-1
CM3:	DW	VV3,	 -1
CM4:	DW	VV4,	 -1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0
;VV3:	DB	3,	'食べる',0
VV3:	DB	3,	'EAT',0
;VV4:	DB	4,	'出る',0
VV4:	DB	4,	'EXIT',0

;NN1:	DB	1,	'店内',0
NN1:	DB	1,	'RESTAURANT',0
;NN2:	DB	2,	'客',0
NN2:	DB	2,	'CUSTOMERS',0
;NN3:	DB	3,	'Ｍバーガー',0
NN3:	DB	3,	'M-BURGER',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　店内
S2:		DW	VV1, NN2,  2, M4, M5, M6		;見る　客
S3:		DW	VV2, NN3,  3, M7		;考える　Ｍバーガー
S4:		DW	VV3, -1,  4, M8		;食べる
S5:		DW	VV4, -1,  5, M9		;出る


;イニシャルメッセージ
M1:
	DB	BGM,17
	BAK_INIT 'AB_35'
	B_P1 B_SUDA
;	DB	'俺たち葉隠高校の生徒御用達の店、Ｍバーガーに来た。'
	DB	"This is M-Burger. It's filled with high school students"
	DB	CR
	DB	"right now."
	DB  NEXT
;	DB	'【店員】：いらっしゃいませ！新発売の砂肝バーガーはいかがですか？'
	DB	"Girl:  Welcome to M-Burger! Would you like to try our new"
	DB	CR
	DB	"Liver Burger today?"
	DB  NEXT
;	DB	'【店員】：こちらはお得なセットメニューとなっております。'
;	DB	"Girl:  You can see the value set here."
;	DB  NEXT
;	DB	'【%001】：照り焼きチキンバーガーのセット。'
	DB	"%001:  I'd like a Teriyaki Chicken Burger, please."
	DB  NEXT
;	DB	'【店員】：ありがとうございます、こちらでお召し上がりですか？'
	DB	"Girl:  Thank you. Will that be for here or to go?"
	DB  NEXT
;	DB	'【%001】：うん。'
	DB	"%001:  Here."
	DB  NEXT
;	DB	'【店員】：かしこまりました、少々お待ち下さい。'
	DB	"Girl:  Okay. Please wait a moment."
	DB  NEXT
;	DB	'・',T_WAIT,2,'・',T_WAIT,2,'・'
	DB	'.',T_WAIT,2,'.',T_WAIT,2,'.',T_WAIT,2,'.',T_WAIT,2,'.',T_WAIT,2,'.',T_WAIT,2,'.'
	DB  NEXT
;	DB	'【店員】：お待たせ致しました、照り焼きチキンバーガーセットです。お会計、４１２円になります。'
	DB	"Girl:  Here you are. One Teriyaki Chicken Burger set. That"
	DB	CR
	DB	"will be 412 yen."
	DB  NEXT
;	DB	'【店員】：ちょうどお預りいたします、ありがとうございました。ごゆっくりどうぞ。'
	DB	"Girl:  Thank you very much. Have a nice day."
	DB  NEXT
;	DB	'俺は手近な席に陣取った。'
	DB	"I sit down at a nearby seat."
	DB G_FLG,G_COPYI,101,1
	DB  C_BLD,C_V_ON,4	;出る
	DW 0000H


M2:		;見る　店内
;	DB	'昼飯時は過ぎてるが、けっこー客が入ってる。'
	DB	"The lunch rush is over, but it's still pretty crowded in"
	DB	CR
	DB	"here."
	DB FLG,F_COPYI,1,1
	DW 0000H

M3:		;見る　店内
;	DB	'（「スマイル　￥０」。実際に注文したことはねーけど。）'
	DB	"It says 'smile 0 yen' on the menu. I've never ordered one,"
	DB	CR
	DB	"though."
	DB  NEXT
;	DB	'（「持ち帰り」で注文するやつがいたりしてな。）'
	DB	"I wonder if anyone orders a smile 'to go.'"
	DB FLG,F_COPYI,1,0
	DW 0000H


M4:		;見る　客
;	DB	'（連休中だって言うのに、スーツを着込んでる中年がいる。）'
	DB	"It's Golden Week, but some people are in here wearing"
	DB	CR
	DB	"suits."
	DB  NEXT
;	DB	'（・・・こんな日まで働かされてるのか？）'
	DB	"Guess they must be working."
	DB FLG,F_COPYI,2,1
	DW 0000H

M5:		;見る　客
;	DB	'（角の席に、向かい合ってるカップルがいる。）'
	DB	"There's a couple over there."
	DB  NEXT
;	DB	'【♂】：はい、あ～んして。'
	DB	"Man:  Open your mouth and say 'ah...'"
	DB  NEXT
;	DB	'【♀】：あ～ん。'
	DB	"Woman:  Ahhh..."
	DB  NEXT
;	DB	'（・・・そーゆー事は人気のない公園でやれって。）'
	DB	"..............Silly."
	DB FLG,F_COPYI,2,2
	DW 0000H

M6:		;見る　客
;	DB	'（俺と同年代の客もけっこーいるけど、知った顔はない。）'
	DB	"There are quite a few high school students here. All"
	DB	CR
	DB	"wearing their uniforms. It makes me remember those days."
	DB FLG,F_COPYI,2,0
	DW 0000H

M7:		;考える　Ｍバーガー
;	DB	'（最近値下げしたんで、俺も学校帰りによく寄って行く。）'
	DB	"They lowered their prices recently, so students like me"
	DB	CR
	DB	"come here a lot."
	DB	NEXT
	DB	"They import their food from America. When the yen got"
	DB	CR
	DB	"stronger, their prices started to come down."
	DB  NEXT
;	DB	'（他の店もつられて値下げしてくれるとありがたい。）'
	DB	"I wish other restaurants would lower their prices."
	DW 0000H

M8:		;食べる
;	DB	'「ぱくっ」'
	DB	"*gobble*"
	DB  NEXT
;	DB	'「むしゃむしゃむしゃ・・・」'
	DB	"*chew chew*"
	DB  NEXT
;	DB	'俺は照り焼きチキンセットを平らげた。'
	DB	"I finish my food."
	DB  C_BLD,C_V_ON,3	;
	DB  C_BLD,C_V_OFF,4	;出る　出し
	DW 0000H


M9:		;出る
;	DB	'【%001】：そろそろ出るか。'
	DB	"Guess I'll leave now."
	DB  NEXT
;	DB	'俺はＭバーガーを出た。'
	DB	"I leave M-Burger."
	DB  NEXT
;	DB	'【店員】：ありがとうございましたぁ。'
	DB	"Woman:  Thank you very much."
	DB  NEXT
	DB	SINARIO,'CS410_1.OVL',0
	DW	0000H

end
