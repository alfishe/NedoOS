;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０９
;		

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	"話す",0
VV1:	DB	1,	"TALK",0
;VV2:	DB	2,	"テニス部",0
VV2:	DB	2,	"TENNIS CLUB",0
;VV3:	DB	3,	"野球部",0
VV3:	DB	3,	"BASEBALL TEAM",0
;VV4:	DB	4,	"水泳部",0
VV4:	DB	4,	"SWIM TEAM",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3, M4		;話す
S2:		DW	VV2, -1,  2, M5		;テニス部
S3:		DW	VV3, -1,  3, M6		;野球部
S4:		DW	VV4, -1,  4, M7		;水泳部


;イニシャルメッセージ
M1:
	DB	BGM,22
	BAK_INIT "AB_36_2"
	B_P1 B_SUDA
;	DB	"【%001】：さ、約束どーり一通り見て回ったし。"
	DB	"%001:  There, I made the rounds like I promised."
	DB	NEXT
;	DB	"【%001】：早く帰ろう。"
	DB	"%001:  It's time to go home."
	DB	NEXT
;	DB	"がらっ"
;	DB	"*kacha*"
;	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","W",0,0,1
;	DB	"【清美】：%001さん。"
	DB	"Kiyomi:  %001..."
	DB	NEXT
;	DB	"・・・教室を出ようとしたところで、俺は新藤さんと鉢合わせてしまった。"
	DB	".....Just as I was about to leave the classroom Kiyomi"
	DB	CR
	DB	"came the classroom."
	DB	NEXT
	T_CG "CT03","W",0,30,2
	DB	ANI,A_ON,1
;	DB	"【美緒】：%001先輩。"
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	"新藤さんの後から美緒ちゃんがひょこっと顔を出す。"
	DB	"Mio popped her head out from behind Kiyomi."
	DB	C_BLD,C_V_ON,2		;テニス部
	DB	C_BLD,C_V_ON,3		;野球部
	DB	C_BLD,C_V_ON,4		;水泳部
	DW	0000H

M2:		;話す
;	DB	"【清美】：それで、どの部に入るか決めていただけましたか？"
	DB	"Kiyomi:  So, have you decided which club you want to join?"
	DB	NEXT
;	DB	"【美緒】：テニス部だよね、%001先輩！"
	DB	"Mio:  Tennis, right %001?"
	DB	NEXT
;	DB	"【%001】：いや・・・"
	DB	"%001:  No..."
	DB	NEXT
;	DB	"【清美】：それでは、野球部でしょうか？"
	DB	"Kiyomi:  Baseball, then?"
	DB	NEXT
;	DB	"【%001】：いや、俺は・・・"
	DB	"%001:  No, I..."
	DB	NEXT
;	DB	"だだだだ・・・！"
	DB	"Huh? I hear footsteps...!"
	DB	NEXT
	T_CG "CT01","W","D",17,3
	DB	ANI,A_ON,1
	DB	ANI,A_ON,2
;	DB	"【鈴子】：%001く～ん、黙っていなくなるなんて、ひどいじゃない。"
	DB	"Reiko:  %001, that wasn't very nice running off like that."
	DB	NEXT
;	DB	"思いっきり走って来たらしく、肩で息をしながら鈴子さんが現われた。"
	DB	"Reiko appeared, looking like she had run the whole way."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;話す
;	DB	"【%001】：俺は・・・どこにも入らねえ。帰宅部が一番あってるんだ。"
	DB	"%001:  I'm......not joining any club. I have decided that"
	DB	CR
	DB	"going home is best for me."
	DB	NEXT
;	DB	"【美緒】：先輩・・・どうして？"
	DB	"Mio:  Why not?"
	DB	NEXT
;	DB	"【清美】：何かわけでもあるのですか？"
	DB	"Kiyomi:  Is there some reason why you don't want to join a"
	DB	CR
	DB	"a club?"
	DB	FLG,F_COPYI,1,2
	DW	0000H


M4:		;話す
;	DB	"【%001】：別に・・・ただ、飽きそうでな。"
	DB	"%001:  I just don't want to get tired of it all later."
	DB	NEXT
;	DB	"【鈴子】：飽きる？"
	DB	"Reiko:  Get tired of it?"
	DB	NEXT
;	DB	"【%001】：昔っから、習い事とかが３日以上続いたためしがねーんだ、俺。"
	DB	"%001:  I've never seemed to be able to keep anything up"
	DB	CR
	DB	"for more than three days."
	DB	NEXT
;	DB	"【%001】：それに、俺って運動神経いいからすぐになんでも出来ちまうし・・・何か、「張り合い」ってモンが無くてな。"
	DB	"%001:  And since I'm naturally athletic, I soon master"
	DB	CR
	DB	"whatever I do. There's just no challenge to it."
	DB	NEXT
;	DB	"【%001】：それじゃ、そーゆーことで。"
	DB	"%001:  That's all. Well, bye."
	DB	NEXT
;	DB	"【清美】：待って下さい、%001さん！"
	DB	"Kiyomi:  Wait!"
	DB	NEXT
;	DB	"【清美】：わたくしと、一つ賭けを致しましょう。"
	DB	"Kiyomi:  Why don't you make a bet with me?"
	DB	NEXT
;	DB	"【%001】：賭け？"
	DB	"%001:  A bet?"
	DB	NEXT
;	DB	"【清美】：わたくしども野球部と、勝負していただきますわ。"
	DB	"Kiyomi:  Why don't you take on the baseball team?"
	DB	NEXT
;	DB	"【清美】：それでわたくしどもが勝ったら、%001さんには野球部に入部していただきます。"
	DB	"Kiyomi:  If we win, you have to join the baseball team."
	DB	NEXT
;	DB	"【%001】：・・・俺が勝ったら？"
	DB	"%001:  If I win?"
	DB	NEXT
;	DB	"【清美】：%001さんの野球部への入部を諦めますわ。"
	DB	"Kiyomi:  I'll stop trying to get you to join."
	DB	NEXT
;	DB	"【鈴子】：あら、面白いじゃない。%001君、私も勝負を申し込むわ。"
	DB	"Reiko:  That sound's interesting. I'll challenge you, too."
	DB	NEXT
;	DB	"【美緒】：あたしも・・・！"
	DB	"Mio:  Me too."
	DB	NEXT
;	DB	"【清美】：%001さん、受けて下さいますわね？"
	DB	"Kiyomi:  Do you accept?"
	DB	NEXT
;	DB	"【%001】：・・・俺が勝ったら諦めてくれるんだな？"
	DB	"%001:  If I win, you will really stop?"
	DB	NEXT
;	DB	"【清美】：ええ、勝てれば、の話ですけど。"
	DB	"Kiyomi:  Yes. If you win."
	DB	NEXT
;	DB	"【%001】：・・・わかった、やるよ。ただし順番はこっちで決めさせてもらう。"
	DB	"%001:  Ok, I accept."
	DB	NEXT
;	DB	"【清美】：それでは、明日野球部のグラウンドで待っておりますから。"
	DB	"Kiyomi:  I'll be waiting for you at the baseball field"
	DB	CR
	DB	"tomorrow."
	DB	NEXT
;	DB	"【美緒】：%001先輩、あたしのところに一番に来てね。"
;	DB	"Mio:  Come to me first, %001."
;	DB	NEXT
;	DB	"【鈴子】：明日が楽しみね、%001君。"
	DB	"Reiko:  I'll see you tomorrow."
	DB	NEXT
	SUDA_CLS
;	DB	"・・・ようやく解放された俺は家に帰り、明日の勝負に備えてさっさと寝た。"
	DB	"...At last I made it home so I could rest up for tomorrow."
	DB	NEXT
;	DB	"そして翌日。"
	DB	"The next day."
	B_P1 B_SUDA
	DB	NEXT
;	DB	"（さて・・・どこからまわろうかな。）"
	DB	"Okay, where should I go first?"
	DB	C_BLD,C_V_ON,1		;話す
	DB	C_BLD,C_V_OFF,2		;テニス部
	DB	C_BLD,C_V_OFF,3		;野球部
	DB	C_BLD,C_V_OFF,4		;水泳部
	DW	0000H

M5:		;テニス部
;	DB	"（最初は美緒ちゃんのテニス部にしよう。）"
	DB	"Guess I'll go to the tennis club first."
	DB	NEXT
;	DB	"俺はテニスコートに向かった。"
	DB	"I made my way to the tennis courts."
	DB	NEXT
	DB SINARIO,"CS209_2.OVL",0


M6:		;野球部
;	DB	"（最初は新藤さんの野球部にしよう。）"
	DB	"Guess I'll go to the baseball team first."
	DB	NEXT
;	DB	"俺は野球部のグラウンドに向かった。"
	DB	"I made my way to the baseball field."
	DB	NEXT
	DB SINARIO,"CS209_1.OVL",0

M7:		;水泳部
;	DB	"（・・・水泳部か・・・）"
	DB	"Hmm, I'm not ready for that yet..."
	DB	NEXT
;	DB	"（鈴子さんには悪いけど、あそこは後回しだ。）"
	DB	"I feel bad for Reiko, but I will put that off for last."
	DW	0000H


end
