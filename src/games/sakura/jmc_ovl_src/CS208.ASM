;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０８
;		プール

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"話す",0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	"鈴子",0
NN1:	DB	1,	"REIKO",0
;NN2:	DB	2,	"プール",0
NN2:	DB	2,	"POOL",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子
S2:		DW	VV1, NN2,  2, M3		;見る　プール
S3:		DW	VV2, NN1,  3, M4, M5, M6		;話す　鈴子


;イニシャルメッセージ
M1:
	DB	BGM,29
	BAK_INIT "AB_23"
	B_P1 B_SUDA
;	DB	"（一応・・・ここにも来てみたが。）"
	DB	"I'm at the pool."
	DB	NEXT
;	DB	"ざばっ"
	DB	"*SPLASH*"
	DB	BUF,B_COPY01
	T_CG "CT01","M",0,12,1
	DB	NEXT
;	DB	"【鈴子】：ハイ、%001君。待ちくたびれちゃったわ。"
	DB	"Reiko:  Hi, %001. I was waiting for you."
	DB	NEXT
;	DB	"水も滴るいい女の鈴子さんが現われた。"
	DB	"A dripping wet Reiko came over."
	DW	0000H

M2:		;見る　鈴子
;	DB	"今まで泳いでいたので、水が滴っている。"
	DB	"She's been been swimming and is all wet."
	DB	NEXT
;	DB	"競泳用の水着が体の線をくっきりと露にしていて、目のやり場に困る。"
	DB	"Her bathing suit accentuates her natural curves. I don't"
	DB	CR
	DB	"know where I should look."
	DW	0000H

M3:		;見る　プール
;	DB	"４月でも泳げる、室内温水プールだ。"
	DB	"The pool is indoors, so you can swim even in April."
	DW	0000H

M4:		;話す　鈴子１
;	DB	"【鈴子】：水泳部へようこそ、%001君。"
	DB	"Reiko:  Welcome to the swim team, %001."
	DB	NEXT
;	DB	"【鈴子】：この全天候型室内温水プールが私達の活動場所よ。"
	DB	"Reiko:  This pool is where we practice."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す　鈴子
;	DB	"【鈴子】：ウチの水泳部は男子部と女子部に分かれてるわ。"
	DB	"Reiko:  The swim team is separated into women' and mens'"
	DB	CR
	DB	"teams."
	DB	NEXT
;	DB	"【鈴子】：第７コースからこっち側が女子部、向こうが男子部って分かれて練習するのよ。"
	DB	"Reiko:  From here to the seventh lane is the womens' course."
	DB	CR
	DB	"Over there is where the men practice."
	DB	NEXT
;	DB	"鈴子さんの指し示した、男子部の方を見ると・・・"
	DB	"I look over to the men's team to see what they're doing..."
	DB	NEXT
;	DB	"【%001】：・・・シンクロ？"
	DB	"%001:  .......Synchronized swimming?"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M6:		;話す　鈴子
;	DB	"【%001】：あれ・・・溺れてるよーに見えるのは、俺の気のせいかな？"
	DB	"%001:  Is it just me or do they seem to be drowning?"
	DB	NEXT
	K_CG "CT01","V",12,2
;	DB	"【鈴子】：あはははは・・・"
	DB	"Reiko:  Ahahaha..."
	DB	NEXT
;	DB	"【%001】：・・・あそこでビート板使ってるのは？"
	DB	"%001:  ....What are those guys doing with the kick boards?"
	DB	NEXT
;	DB	"【鈴子】：あはははは・・・"
	DB	"Reiko:  Ahahaha..."
	DB	NEXT
;	DB	"【%001】：・・・浮き輪で泳いでない？"
	DB	"%001:  ...Someone over there, swimming with a life ring?"
	DB	NEXT
;	DB	"【鈴子】：あはははは・・・"
	DB	"Reiko:  Ahahaha..."
	DB	NEXT
;	DB	"【%001】：ついでに、プールサイドでスイカ割りしてねえか？"
	DB	"%001:  Someone's smashing watermelons on the poolside!"
	DB	NEXT
	DB BUF,B_COPY10
	E_CG B_NORM,"AB_23"
;	DB	"たったったった・・・"
	DB	"Reiko:  What?!"
	DB	NEXT
;	DB	"鈴子さんは猛然と走って行くと、スイカ割りの一団をプールに蹴落とした。"
	DB	"Reiko runs over to where the guys were smashing watermelons"
	DB	CR
	DB	"and pushes them in the pool."
	DB	NEXT
;	DB	"【%001】：この隙にトンズラするか。"
	DB	"This is such a strange school."
	DB	NEXT
;	DB	"・・・・・・・・・・・・"
	DB	"..........................................."
	DB	NEXT
	B_P1 B_TATE
;	DB	"【鈴子】：と、ゆーわけでぇ！"
	DB	"Reiko:  That's why I want you!"
	DB	NEXT
;	DB	"【鈴子】：水泳部には運動神経抜群の君が必要なの！"
	DB	"Reiko:  We need a man like you who's athletic!"
	DB	NEXT
;	DB	"【鈴子】：あら？"
	DB	"Reiko:  Hey."
	DB	NEXT
;	DB	"【鈴子】：%001く～ん・・・どこ行っちゃったのかなぁ？"
	DB	"Reiko:  %001? Where did he go?"
	DB	NEXT
;	DB	"【鈴子】：はぁ・・・あきれて帰っちゃったのかしら・・・。"
	DB	"Reiko:  Ahh! He was so disgusted that he went home."
	DB	NEXT
	DB SINARIO,"CS209.OVL",0
	DW	0000H


end
