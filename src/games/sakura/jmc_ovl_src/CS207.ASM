;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０７
;		野球部

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"話す",0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	"清美",0
NN1:	DB	1,	"KIYOMI",0
;NN2:	DB	2,	"グラウンド",0
NN2:	DB	2,	"FIELD",0
;NN3:	DB	3,	"野球部",0
NN3:	DB	3,	"BASEBALL TEAM",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　清美
S2:		DW	VV1, NN2,  2, M3		;見る　グラウンド
S3:		DW	VV1, NN3,  3, M4, M5, M6, M7, M8		;見る　野球部
S4:		DW	VV2, NN1,  4, M9, M10, M11, M12		;話す　清美


;イニシャルメッセージ
M1:
	DB	BGM,18
	BAK_INIT "AB_11_1"
	B_P1 B_SUDA
;	DB	"さて、野球部のグラウンドに来てみたが。"
	DB	"I'm at the baseball field."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","W",0,30,1
;	DB	"俺を見つけて、新藤さんが小走りでこっちに来た。"
	DB	"Kiyomi saw me and came running over."
	DB	NEXT
;	DB	"【清美】：お待ちしておりましたわ。"
	DB	"Kiyomi:  I've been waiting for you."
	DW	0000H

M2:		;見る　清美
;	DB	"（中学でソフトボールをやってたって話だけど・・・）"
	DB	"She said that she played softball in junior high."
	DB	NEXT
;	DB	"（あんまり運動が得意そうには見えない。だからマネージャーになったのかな。）"
	DB	"She doesn't look the athletic type. That must be why she"
	DB	CR
	DB	"became manager."
	DW	0000H

M3:		;見る　グラウンド
;	DB	"野球部専用のグラウンドだ。"
	DB	"There's a baseball diamond here."
	DB	NEXT
;	DB	"野球部員が練習してる。"
	DB	"The team members are practicing."
	DW	0000H

M4:		;見る　野球部
;	DB	"監督らしき人が、ノックをしてる。"
	DB	"Someone who seems to be the coach is yelling at the players."
	DB	NEXT
;	DB	"「行くぞ、ファースト！」"
	DB	"*CHING*!"
	DB	NEXT
;	DB	"「何だそのへっぴり腰は！」"
	DB	"'What kind of playing is that?'"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;見る　野球部
;	DB	"監督らしき人が、ノックをしてる。"
	DB	"Someone who seems to be the coach is yelling at the players."
	DB	NEXT
	DB	"'Get in front of the ball. Don't reach for it!'"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M6:		;見る　野球部
;	DB	"監督らしき人が、ノックをしてる。"
	DB	"Someone who seems to be the coach is yelling at the players."
	DB	NEXT
;	DB	"「次、ショート！」"
	DB	"'Next, shortstop!'"
	DB	NEXT
;	DB	"「と言いつつサード！」"
	DB	" 'No, third, you take it!'"
	DB	NEXT
;	DB	"「えっ！？」"
	DB	"'Heh!?'"
	DB	NEXT
;	DB	"キン！"
	DB	"*CHING*!"
	DB	NEXT
;	DB	"「ボーッとしてるんじゃない！いつも本番の試合だと思え！」"
	DB	"'Wake up out there. Think of this as a real game!'"
	DB	FLG,F_COPYI,3,3
	DW	0000H

M7:		;見る　野球部
;	DB	"監督らしき人が、ノックをしてる。"
	DB	"Someone who seems to be the coach is yelling at the players."
	DB	NEXT
;	DB	"「いいかぁ、最後までボールから目ぇ離すなよ！」"
	DB	"'Don't take your eyes off the ball!'"
	DB	NEXT
;	DB	"キン！"
	DB	"*CHING*"
	DB	NEXT
;	DB	"「取ったら即一塁に投げる！」"
	DB	"'Throw to first as soon as you catch the ball!'"
	DB	FLG,F_COPYI,3,4
	DW	0000H

M8:		;見る　野球部
;	DB	"監督らしき人が、ノックをしてる。"
	DB	"Someone who seems to be the coach is yelling at the players."
	DB	NEXT
;	DB	"「レギュラーだからって安心するんじゃねぇぞ！」"
	DB	"'Don't think I won't cut you just because you're a regular.'"
	DB	NEXT
;	DB	"「新入生に抜かれたら即レギュラー落ちだからな！」"
	DB	"'If a new guy does better than you, you're benched!'"
	DW	0000H

M9:		;話す　清美
;	DB	"【清美】：ようこそ、野球部へ！"
	DB	"Kiyomi:  Welcome to the baseball team!"
	DB	NEXT
;	DB	"【清美】：葉隠学園高等部は、去年の夏甲子園まで行ったんですのよ。２回戦で敗退いたしましたけど・・・"
	DB	"Kiyomi:  Our school almost made it to the championships last"
	DB	CR
	DB	"summer. We almost went all the way..."
	DB	NEXT
;	DB	"【%001】：へえ・・・強いんだ。"
	DB	"%001:  They must be pretty good."
	DB	NEXT
;	DB	"【清美】：部員は%001さんを入れて現在６３名ですわ。"
	DB	"Kiyomi:  There are sixty-three players including you, %001."
	DB	NEXT
;	DB	"【%001】：６２人ね。"
	DB	"%001:  Sixty-two, then."
	DB	NEXT
;	DB	"【清美】：６３名ですわよ。"
	DB	"Kiyomi:  It'll be sixty-three."
	DB	NEXT
;	DB	"（新藤さんって、結構強引なんだな・・・）"
	DB	"Kiyomi sure is forceful."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M10:		;話す　清美
;	DB	"【清美】：あちらで投球練習をなさっているのが、エースピッチャーの干さんですわ。"
	DB	"Kiyomi:  That guy practicing over there is the ace pitcher,"
	DB	CR
	DB	"Hoshi."
	DB	NEXT
;	DB	"【%001】：あの、ほっペたに変なヒゲが生えてる人？"
	DB	"%001:  The guy with the beard?"
	DB	NEXT
;	DB	"【清美】：ええ、生まれつきだとか・・・。ですが%001さん、よくここから見えますわね。"
	DB	"Kiyomi:  Yes, he says he has had it since birth. You"
	DB	CR
	DB	"certainly have good eyes, being able to see from here."
	DB	NEXT
;	DB	"【%001】：視力は両方とも２．０だから。"
	DB	"%001:  I have 20-20 vision."
	DB	NEXT
;	DB	"【清美】：まあ！健康な目はよい野球選手の第一条件ですのよ！"
	DB	"Kiyomi:  Wow! Good sight is the first reqirement of a"
	DB	CR
	DB	"baseball player."
	DB	NEXT
;	DB	"【清美】：わたくし、中等部でソフトボール部にいた時分は苦労致しましたわ。"
	DB	"Kiyomi:  I had a hard time when I was in the softball team"
	DB	CR
	DB	"in junior high."
	DB	NEXT
;	DB	"【清美】：何しろ、裸眼で０．０１、眼鏡をかけましても０．７にしかなりませんもの。"
	DB	"Kiyomi:  I can barely see at all without glasses. And even"
	DB	CR
	DB	"with them, my vision isn't very good."
	DB	NEXT
;	DB	"【清美】：バッターボックスに立っても三振ばかり。守備についてもエラーばかり・・・。あ、わたくしライトを守っておりましたのよ。"
	DB	"Kiyomi:  When I was at the plate, I always struck out. In"
	DB	CR
	DB	"the field, I was always making errors."
	DB	NEXT
;	DB	"きっと%001さんは野球をするために生まれて来たのですわ。"
	DB	"Kiyomi:  But you... You were born to play baseball."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M11:		;話す　清美
;	DB	"【清美】：%001さん、見ているだけでは始まりませんわ。"
	DB	"Kiyomi:  You won't ever get started just standing and"
	DB	CR
	DB	"watching. Why don't you play?"
	DB	NEXT
;	DB	"【%001】：でも、制服のままじゃ・・・"
	DB	"%001:  I can't play in my school uniform..."
	DB	NEXT
;	DB	"【清美】：ちゃんと%001さんのユニフォームも、用意してありますのよ。"
	DB	"Kiyomi:  That's no problem. There is a baseball uniform"
	DB	CR
	DB	"ready for you."
	DB	NEXT
;	DB	"【%001】：ええっ？"
	DB	"%001:  What??"
	DB	NEXT
;	DB	"そう言って新藤さんは、俺の名前の入ったユニフォームをそっと差し出した。"
	DB	"Kiyomi produced a uniform with my name on it."
	DB	NEXT
;	DB	"（これを着たら、もう後にはひけなくなるよな・・・）"
	DB	"If I put that on, there is no turning back..."
	DB	FLG,F_COPYI,4,3
	DW	0000H


M12:		;話す　清美
;	DB	"【%001】：まだ他の場所にも行かなきゃならんから、そろそろ行くよ。"
	DB	"%001:  I'd better go now..."
	DB	NEXT
	K_CG "CT02","I",30,2
;	DB	"【清美】：そうですか・・・"
	DB	"Kiyomi:  You're leaving?"
	DB	NEXT
;	DB	"（さて・・・約束した手前、行かないとな・・・。）"
	DB	"I'd better go before I make a promise I can't keep."
	DB	NEXT
;	DB	"俺はプールに向かった。"
	DB	"I head for the pool."
	DB	NEXT
;	DB	"・・・・・・・・・・・・・・・"
	DB	"........................................................."
	DB	NEXT
;	DB	"【清美】：%001さん、野球がお嫌いなのでしょうか・・・？"
	DB	"Kiyomi:  %001, don't you like baseball?"
	DB	NEXT
;	DB	"【清美】：せっかく急いで用意致しましたのに・・・"
	DB	"Kiyomi:  After I went to the trouble to make this for you..."
	DB	NEXT
	DB SINARIO,"CS208.OVL",0
	DW	0000H


end
