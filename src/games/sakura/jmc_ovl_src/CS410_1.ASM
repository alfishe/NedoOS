;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４１０＿１
;		駅前

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11
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
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,NN6,NN7,-1
CM3:	DW	VV3,	NN4,NN5,NN6,NN7,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0
;VV3:	DB	3,	'行く',0
VV3:	DB	3,	'GO',0

;NN1:	DB	1,	'街並',0
NN1:	DB	1,	'DOWNTOWN',0
;NN2:	DB	2,	'連休',0
NN2:	DB	2,	'GOLDEN WEEK',0
;NN3:	DB	3,	'行き先',0
NN3:	DB	3,	'DESTINATION',0
;NN4:	DB	4,	'Ｍバーガー',0
NN4:	DB	4,	'M-BURGER',0
;NN5:	DB	5,	'市民公園',0
NN5:	DB	5,	'PARK',0
;NN6:	DB	6,	'デパート',0
NN6:	DB	6,	'STORE',0
;NN7:	DB	7,	'バベル',0
NN7:	DB	7,	'BABEL',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　街並
S2:		DW	VV2, NN2,  2, M3		;考える　連休
S3:		DW	VV2, NN3,  3, M4		;考える　行き先
S4:		DW	VV2, NN4,  4, M5		;考える　Ｍバーガー
S5:		DW	VV2, NN5,  5, M6		;考える　市民公園
S6:		DW	VV2, NN6,  6, M7		;考える　デパート
S7:		DW	VV2, NN7,  7, M8		;考える　バベル
S8:		DW	VV3, NN4,  8, M9, M10		;行く　Ｍバーガー
S9:		DW	VV3, NN5,  9, M11, M12		;行く　市民公園
S10:	DW	VV3, NN6,  10, M13, M14		;行く　デパート
S11:	DW	VV3, NN7,  11, M15, M16		;行く　バベル


;イニシャルメッセージ
M1:
	DB	BGM,17
	B_O B_SUDA
	BAK_INIT 'AB_43_1'
	B_P1 B_SUDA
;	DB	'駅前に来た。'
	DB	"I'm in front of the station."
	DB G_FLG,G_COPYF,101,101
	DB G_FLG,G_COPYF,8,101
	DB G_FLG,G_COPYF,102,102
	DB G_FLG,G_COPYF,9,102
	DB G_FLG,G_COPYF,103,103
	DB G_FLG,G_COPYF,10,103
	DB G_FLG,G_COPYF,104,104
	DB G_FLG,G_COPYF,11,104
	DB C_BLD,C_N_ON,2,3		;考える　Ｍバーガー
	DB C_BLD,C_N_ON,2,4		;考える　市民公園
	DB C_BLD,C_N_ON,2,5		;考える　デパート
	DB C_BLD,C_N_ON,2,6		;考える　バベル
	DB	FLG,F_MAND,4,101,102,103,104
	DB	FLG,F_EXIT,101
	DB	NEXT
	DB SINARIO,'CS411.OVL',0
	DW	0000H

M2:		;見る　街並
;	DB	'ゴールデンウィーク中だけあって、さすがに人通りも多い。'
	DB	"It's Golden Week, so there are a lot of people out."
	DW	0000H

M3:		;考える　連休
;	DB	'（ゴールデンウィークの連休って言ったら、どっか旅行に行ったりするもんだけどな。）'
	DB	"Lots of people travel during Golden Week, of course."
	DB	NEXT
;	DB	'（まあ、ゴールデンウィーク中はどこの旅館も高くなるらしいし、ウチでごろごろするのも悪くはないさ。）'
	DB	"On the other hand, all the hotels get expensive this time"
	DB	CR
	DB	"of year. I wouldn't spend the money, personally."
	DB	NEXT
;	DB	'（みんなはどうしてるんだろ？）'
	DB	"I wonder what everyone is doing?"
	DW	0000H

M4:		;考える　行き先
;	DB	'（あ～、これからどうすっかな。）'
	DB	"Hmm, where should I go now?"
	DB C_BLD,C_N_OFF,2,3	;考える　Ｍバーガー
	DB C_BLD,C_N_OFF,2,4	;考える　市民公園
	DB C_BLD,C_N_OFF,2,5	;考える　デパート
	DB C_BLD,C_N_OFF,2,6	;考える　バベル
	DW	0000H

M5:		;考える　Ｍバーガー
;	DB	'（ファーストフードと言えばこの店、ってくらい有名な大手のハンバーガーショップだ。）'
	DB	"When you think fast food, you think of M-Burger. It's a"
	DB	CR
	DB	"famous chain of restaurants."
	DB	NEXT
;	DB	'（最近大幅に値下げしたんで、俺達も学校の帰りによく寄って行く。）'
	DB	"They recently lowered their prices, so students like me"
	DB	CR
	DB	"who don't have much money go there all the time now."
	DB	NEXT
;	DB	'（味の方は・・・まあ、人それぞれ好みがあるからな。）'
	DB	"It doesn't taste all that good, but at least it's cheap."
	DW	0000H

M6:		;考える　市民公園
;	DB	'（市民の憩いの広場、市民公園は、ひなたぼっこするにはいい場所だ。）'
	DB	"Citizens' Park is a good place to relax."
	DW	0000H

M7:		;考える　デパート
;	DB	'（駅前のデパート、○｜×｜。通称ゼロワンデパート。一昨日鈴子さん達に付き合って入ったところだ。）'
	DB	"It's a big department store, Maru-One. We call it 'Zero"
	DB	CR
	DB	"One' sometimes. I went there with Reiko and everyone"
	DB	CR
	DB	"yesterday."
	DW	0000H

M8:		;考える　バベル
;	DB	'（ゲームセンター「バベル」。最新ゲームの入りがいいので、俺もよく遊んで行く。）'
	DB	"It's a game center, called Babel. They always have the"
	DB	CR
	DB	"newest games there."
	DW	0000H

M9:		;行く　Ｍバーガー
;	DB	'（そう言えば、ちょっと腹が減ったかな。）'
	DB	"I am a little hungry."
	DB	NEXT
;	DB	'（Ｍバーガーで何か食ってくか。）'
	DB	"I guess I'll get something to eat at M-Burger."
	DB	NEXT
	DB SINARIO,'CS410_2.OVL',0
	DW	0000H

M10:		;行く　Ｍバーガー
;	DB	'（今行って来たところだ・・・腹も減ってない。）'
	DB	"I just went there. I'm not hungry right now."
	DW	0000H

M11:		;行く　市民公園
;	DB	'（ハトに餌でもやって行こう。）'
	DB	"I guess I'll feed the pigeons or something."
	DB	NEXT
	DB SINARIO,'CS410_3.OVL',0
	DW	0000H

M12:		;行く　市民公園
;	DB	'（・・・ひなたぼっこも飽きた。）'
	DB	"I'm tired of the park."
	DW	0000H


M13:		;行く　デパート
;	DB	'（一昨日は鈴子さん達に付き合ってたから、自分の買い物はしなかったんだよな。）'
	DB	"I was with Reiko and the others yesterday, so I didn't"
	DB	CR
	DB	"get to buy anything I wanted. Guess I'll do that now."
;	DB	NEXT
;	DB	'（ちょっと覗いて見るか。）'
	DB	NEXT
	DB SINARIO,'CS410_4.OVL',0
	DW	0000H

M14:		;行く　デパート
;	DB	'（買物はいいや。荷物が多いとうざったい。）'
	DB	"I don't want to go again. I'll just have to carry"
	DB	CR
	DB	"everything around with me."
	DW	0000H

M15:		;行く　バベル
;	DB	'（暇な時はゲーセンに限るな・・・。）'
	DB	"There's nothing like spending time at a game center when"
	DB	CR
	DB	"you've got free time."
	DB	NEXT
	DB SINARIO,'CS410_5.OVL',0
	DW	0000H

M16:		;行く　バベル
;	DB	'（今日はもういいや・・・目が疲れた。）'
	DB	"I already went there."
	DW	0000H


end
