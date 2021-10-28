;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０５
;		清美乱入

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
S1:		DW	VV1, -1,  1, M2, M3		;話す
S2:		DW	VV2, -1,  2, M4		;テニス部
S3:		DW	VV3, -1,  3, M5		;野球部
S4:		DW	VV4, -1,  4, M6		;水泳部


;イニシャルメッセージ
M1:
	DB	BGM,22
	BAK_INIT "AB_46"
	DB	BUF,B_COPY01
	TU_CG "CT01","W","D",35,2
	TU_CG "CT03","W","D",10,1
	T_CG "CT02","W",0,0,3
	DB ANI,A_ON,1
	DB ANI,A_ON,2
;	DB	"走って来たらしく、新藤さんは息を切らしている。"
	DB	"It looked like Kiyomi ran all the way here. She was out"
	DB	CR
	DB	"of breath."
	DB	NEXT
;	DB	"【%001】：新藤さん・・・そんなに慌ててどうしたんだ？"
	DB	"%001:  Kiyomi? What's wrong?"
	DB	NEXT
;	DB	"【清美】：わたくし・・・%001さんを捜しておりましたの。"
	DB	"Kiyomi:  I... I was looking all over for you."
	DB	NEXT
;	DB	"【清美】：%001さん、入るクラブはお決まりになりましたか？"
	DB	"Kiyomi:  %001, have you decided what club you're joining?"
	DB	NEXT
;	DB	"【美緒】：テニス部！"
	DB	"Mio:  The tennis club!"
	DB	NEXT
;	DB	"【鈴子】：水泳部よ！"
	DB	"Reiko:  No, the swim team!" 
	DB	NEXT
;	DB	"【%001】：まだ決めてない。"
	DB	"%001:  ....I haven't decided."
	DB	NEXT
;	DB	"【清美】：そうですか・・・でしたら、野球部など如何でしょうか？"
	DB	"Kiyomi:  Oh. Then, how about joining the baseball team?"
	DB	NEXT
;	DB	"【%001】：野球部？"
	DB	"%001:  The baseball team?"
	DB	NEXT
;	DB	"【清美】：わたくし、中学ではソフトボール部に入っておりましたのよ。"
	DB	"Kiyomi:  I was in the softball team in junior high."
	DB	NEXT
;	DB	"【%001】：そういえば、ウチには女子野球部もあったっけ。"
	DB	"%001:  Really? Is there a women's baseball team here?"
	DB	NEXT
;	DB	"【清美】：ええ・・・ですが、わたくしは男子野球部のマネージャーになりましたのよ。"
	DB	"Kiyomi:  There is. But I've become manager of the mens'"
	DB	CR
	DB	"baseball team instead."
	DB	NEXT
	DB	"(She doesn't mean that she's really the manager of the team....)"
	DB	NEXT
	DB	"(In Japan, women become 'managers' of mens' sports teams,"
	DB	CR
	DB	"which means they help out washing uniforms and things"
	DB	CR
	DB	"like that.)"
	DB	NEXT
;	DB	"【清美】：わたくし、%001さんに甲子園に連れて行っていただくのが夢ですの。"
	DB	"Kiyomi:  It is my dream to go the the national championships"
	DB	CR
	DB	"with you."
	DB	NEXT
;	DB	"【清美】：そして%001さんは、わたくしのために甲子園でホームランを打って下さるのですわ。"
	DB	"Kiyomi:  It'll be just like that manga we all used"
	DB	CR
	DB	"to read!"
	DB	NEXT
;	DB	"【美緒】：違うよ！%001先輩はあたしとインターハイを目指すんだ！"
	DB	"Mio:  No! %001 is going to the inter-high tennis tounament"
	DB	CR
	DB	"with me!"
	DB	NEXT
;	DB	"【鈴子】：いいえ、私と金メダルを目指すのよ。"
	DB	"Reiko:  No, he is going for a gold medal with me!"
	DB	NEXT
;	DB	"（・・・俺は何も言ってねーぞ。）"
	DB	"What's going on?!"
	DB	C_BLD,C_V_ON,2		;テニス部
	DB	C_BLD,C_V_ON,3		;野球部
	DB	C_BLD,C_V_ON,4		;水泳部
	DW	0000H

M2:		;話す
;	DB	"【清美】：まあ・・・今気が付きましたけれども・・・"
	DB	"Kiyomi:  Oh, hello."
	DB	NEXT
;	DB	"【清美】：あなたはテニス部の鈴木　美緒さんですわね？"
	DB	"Kiyomi:  You're Mio Suzuki from the tennis club, right?"
	DB	NEXT
;	DB	"お噂はかねがね伺っておりますわ。"
	DB	"I've heard a lot about you."
	DB	NEXT
;	DB	"【清美】：初めまして、わたくし１－Ａの新藤　清美と申します。今後ともよろしくお願い致します。"
	DB	"Kiyomi:  I'm Kiyomi Shinfuji, freshman, A class. It's a"
	DB	CR
	DB	"pleasure to meet you."
	DB	NEXT
	DB BUF,B_COPY01
	TU_CG "CT01","W","D",35,2
	TU_CG "CT03","W",0,10,4
	T_CG "CT02","W",0,0,3
	DB ANI,A_ON,2
	DB ANI,A_ON,4
;	DB	"【美緒】：あっ・・・はい、あたし鈴木　美緒です。"
	DB	"Mio:  I'm Mio Suzuki."
	DB	NEXT
;	DB	"丁寧にあいさつした新藤さんにつられて、美緒ちゃんはぴょこんとお辞儀した。"
	DB	"Mio bowed politely to Kiyomi."
	DB	NEXT
;	DB	"【清美】：で、こちらは未来の金メダリストと名高い、",CR,"３年生の沢村　鈴子さんですわね。"
	DB	"Kiyomi:  And you must be Reiko Sawamura, the future gold"
	DB	CR
	DB	"medalist."
	DB	NEXT
;	DB	"【清美】：初めまして。今後ともよろしくお願い致しますわ。"
	DB	"Kiyomi:  It is a pleasure to meet you."
	DB	NEXT
	T_CG1 "CT01","W",0,35,5
	DB ANI,A_ON,3
	DB ANI,A_ON,4
;	DB	"【鈴子】：え、ええこちらこそ。"
	DB	"Reiko:  Uh, same here."
;	DB	NEXT
;	DB	"【%001】：・・・（←なんとなく疎外感）"
;	DB	"........What about me?"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;話す
;	DB	"【清美】：ところで、そのお二人がなぜ%001さんと一緒にいらっしゃるのですか？"
	DB	"Kiyomi:  And why are these two with you, %001?"
	DB	NEXT
;	DB	"【美緒】：%001先輩にテニス部に入ってもらうんだ。"
	DB	"Mio:  %001 is going to join the tennis club."
	DB	NEXT
;	DB	"【鈴子】：違うわ、%001君は水泳部に入るのよ！"
	DB	"Reiko:  No he isn't. He is joining the swim team!"
	DB	NEXT
;	DB	"【清美】：・・・まあ！"
	DB	"Mio:  Well!"
	DB	NEXT
;	DB	"新藤さんはようやく理解した、とばかりにぽんと手を打った。"
	DB	"It looked like Kiyomi finally figured out what was going on, "
	DB	CR
	DB	"and decided to get in the fight."
	DB	NEXT
	K_CG "CT02","K",0,6
	DB ANI,A_ON,4
	DB ANI,A_ON,5
;	DB	"【清美】：それでは、わたくしたちは「ライバル」同士ということになりますわね。"
	DB	"Kiyomi:  Then I guess that makes us all rivals then."
	DB	NEXT
;	DB	"【鈴子】：・・・そうなの？"
	DB	"Reiko:  Is that so?"
	DB	NEXT
;	DB	"【美緒】：新藤先輩、あたし負けないから！"
	DB	"Mio:  Kiyomi, I warn you, I don't like to lose a fight!"
	DB	NEXT
;	DB	"美緒ちゃんは炎を背負っていた。"
	DB	"Mio was getting really worked up."
	DB	NEXT
;	DB	"【清美】：受けて立ちますわ。%001さんはあなたがたにはお渡し致しませんわよ。"
	DB	"Kiyomi:  I accept your challenge. But I won't give %001"
	DB	CR
	DB	"up easily."
	DB	NEXT
;	DB	"【清美】：何しろわたくしは%001さんと一緒にいる時間が長いですから、「愛」が芽生えるのも時間の問題ですわね。"
	DB	"Kiyomi:  Any way you look at it, I spend the most time"
	DB	CR
	DB	"with %001 since he's in my class. It is only a matter of"
	DB	CR
	DB	"time before love sprouts."
	DB	NEXT
;	DB	"【%001】：ちょ、ちょっと待った！"
	DB	"%001:  Now wait a minute!"
	DB	NEXT
;	DB	"なんか話が怪しい方向に流れ出したので、俺は慌てて割って入った。"
	DB	"This converation was getting out of hand."
	DB	NEXT
;	DB	"【%001】：なんかみんなすっかりお話し合いの態勢だけど、",CR,"俺に選択権はねーのか？"
	DB	"%001:  I think I have a say in this!"
	DB	NEXT
;	DB	"【清美】：それもそうですわね。では、%001さんが決めて下さい。野球部ですわよね？"
	DB	"Kiyomi:  That's right. So decide, %001. Baseball, right?"
	DB	NEXT
;	DB	"【美緒】：テニス部だよね、先輩。"
	DB	"Mio:  The tennis club, right %001?"
	DB	NEXT
;	DB	"【鈴子】：%001君には水泳部が一番あってると思うわ。"
	DB	"Reiko:  I think that swimming is best for you, %001."
	DB	NEXT
;	DB	"【%001】：う・・・"
	DB	"%001:  Ummmm..."
	DB C_BLD,C_V_ON,1
	DB	C_BLD,C_V_OFF,2		;テニス部
	DB	C_BLD,C_V_OFF,3		;野球部
	DB	C_BLD,C_V_OFF,4		;水泳部
	DW	0000H


M4:		;テニス部
M5:		;野球部
M6:		;水泳部
;	DB	"（どれを選んでも、他の二人を傷つけるんじゃねーか？）"
	DB	"No matter which one I choose, the other two women will be"
	DB	CR
	DB	"let down."
	DB	NEXT
;	DB	"（う～む・・・）"
	DB	"What can I do?"
	DB	NEXT
;	DB	"【%001】：じゃ、じゃあこうしよう。"
	DB	"%001:  I have an idea."
	DB	NEXT
;	DB	"【%001】：すぐには決められねーから、みんなの部を一通り見てから決める、って事じゃダメか？"
	DB	"%001:  I can't make such a sudden decision. So why don't"
	DB	CR
	DB	"I try out each club first?"
	DB	NEXT
;	DB	"【鈴子】：・・・いいわ。"
	DB	"Reiko:  That's fine with me."
	DB	NEXT
;	DB	"【清美】：わかりました。"
	DB	"Kiyomi:  Okay!"
	DB	NEXT
;	DB	"【美緒】：%001先輩、待ってるから。"
	DB	"Mio:  I'll be waiting for you."
	DB	NEXT
	B_P1 B_SUDA
;	DB	"３人は思い思いの方向に去っていった。"
	DB	"All three of them seemed to be satisfied for the moment."
	DB	NEXT
;	DB	"【%001】：・・・つ・・・疲れた・・・。"
	DB	"%001:  *whew*"
	DB	NEXT
;	DB	"俺は思わずその場にへたり込んでしまった。"
	DB	"I succcombed to exhaustion."
	DB	NEXT
;	DB	"春風が、心持ち冷たかった。"
	DB	"The spring breeze was refreshingly cool."
	DB	NEXT
	DB	SINARIO,"CS206.OVL",0
	DW	0000H


end
