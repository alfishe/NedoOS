;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０１
;		勧誘合戦

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5, CM6
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:


	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1
CM6:	DW	VV6,	-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"考える",0
VV2:	DB	2,	"THINK",0
;VV3:	DB	3,	"歩く",0
VV3:	DB	3,	"WALK",0
;VV4:	DB	4,	"関東風",0
VV4:	DB	4,	"THIN KIND",0
;VV5:	DB	5,	"関西風",0
VV5:	DB	5,	"FAT KIND",0
;VV6:	DB	6,	"スパゲッティ",0
VV6:	DB	6,	"SPAGHETTI",0

;NN1:	DB	1,	"まわり",0
NN1:	DB	1,	"AROUND",0
;NN2:	DB	2,	"クラブ",0
NN2:	DB	2,	"CLUBS",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　まわり
S2:		DW	VV2, NN2,  2, M3, M4, M5		;考える　クラブ
S3:		DW	VV3, -1,  3, M6, M7, M8, M9		;歩く
S4:		DW	VV4, -1,  4, M10		;関東風
S5:		DW	VV5, -1,  5, M11		;関西風
S6:		DW	VV6, -1,  6, M12		;スパゲッティ


;イニシャルメッセージ
M1:
	DB	BGM,22
	E_CG B_TATE,"T_02"
	DB	NEXT
	BAK_INIT "AB_27_1"
	B_P1 B_SUDA
;	DB	"それから一週間が過ぎた。"
	DB	"One week passed."
	DB	NEXT
;	DB	"今日は数時間におよぶ部活動の説明会があり、それが終わって体育館を出て来たところだ。"
	DB	"In Japanese schools, clubs are very important. Everyone"
	DB	CR
	DB	"is supposed to join a club, and the clubs try hard to "
	DB	CR
	DB	"recruit new members."
	DB	NEXT
	DB	"Some of them get a little carried away."
	DB	CR
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DB	C_BLD,C_V_ON,4		;関東風
	DB	C_BLD,C_V_ON,5		;関西風
	DB	C_BLD,C_V_ON,6		;スパゲッティ
	DW	0000H

M2:		;見る　まわり
;	DB	"今日の部活動説明会を境に、勧誘活動が解禁される。"
	DB	"The clubs are out trying to recruit as many new members as"
	DB	CR
	DB	"they can."
	DB	NEXT
;	DB	"そういうわけで、俺達新入生は川を上る鮭のように勧誘の魔の手にさらされるのだった。"
	DB	"The recruiters are really persistant."
	DW	0000H

M3:		;考える　クラブ
;	DB	"この葉隠高校には、大小合わせて３００ものクラブ・愛好会がある。
	DB	"There are more than three hundred clubs and teams of various"
	DB	CR
	DB	"types here at Kotobuki Junior College."
	DB	NEXT
;	DB	"野球部やサッカー部には専用のグラウンドがあるし、スケートやアイスホッケーのための室内リンクまであるらしい。"
	DB	"The baseball and soccer teams have their own fields."
	DB	CR
	DB	"There's even an indoor rink for ice skating and hockey."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;考える　クラブ
;	DB	"３００もある中には、とーぜん妙なのもある。"
	DB	"With more than three hundred clubs on campus, there are some"
	DB	CR
	DB	"pretty strange ones."
	DB	NEXT
;	DB	"部員全員が某男優にそっくりな（と自称する）ケビン部。"
	DB	"One club claims that every member looks like a certain movie"
	DB	CR
	DB	"star."
	DB	NEXT
;	DB	"校長のファンクラブ。・・・ま、確かにあの校長はカッコいいけどさ。"
	DB	"The dean even has a fan club...I guess he is a pretty"
	DB	CR
	DB	"cool guy, but a fan club?"
	DB	NEXT
;	DB	"忍者部なんてのもあるらしい。普段は怪しまれないように、",CR,"虚無僧とか山伏とかの格好をしてるって話だ。"
	DB	"There is a ninja club. But they dress like buddhist priests"
	DB	CR
	DB	"since real ninjas have to disguise themselves."
	DB	NEXT
;	DB	"・・・そっちの方が百倍怪しい。"
	DB	"....It makes them stand out all that much more."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;考える　クラブ
;	DB	"・・・これといって、入りたいクラブはなかった・・・。"
	DB	"Even with all the selection, there isn't a single club I "
	DB	CR
	DB	"want to join."
	DW	0000H

M6:		;歩く
;	DB	"「そこのキミ！」"
	DB	"???:  HEY YOU!"
	DB	NEXT
;	DB	"柔道着を来た男が俺の肩をつかむ。"
	DB	"A member of the judo club grabs me by the shoulder."
	DB	NEXT
;	DB	"「我々と共に身心を鍛え、熱い血潮を燃やしてみないか？」"
	DB	"???:  Want to join  our club? We'll get you in shape in no"
	DB	CR
	DB	"time!"
	DB	NEXT
;	DB	"【%001】：間に合ってます。"
	DB	"%001:  Thanks, I have other plans."
	DB	NEXT
;	DB	"俺はするりと抜け出して、そのまま立ち去った。"
	DB	"I get out of there as fast as I can."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M7:		;歩く
;	DB	"「君は新入生でごわすね？」"
	DB	"???:  Are you new at this school?"
	DB	NEXT
;	DB	"まげを結って着物を来た、太った男が現われた。"
	DB	"A fat guy in a kimono appeared."
	DB	NEXT
;	DB	"【%001】：相撲には興味ないんで・・・"
	DB	"%001:  I'm not interested in sumo wrestling."
	DB	NEXT
;	DB	"「我々は相撲部ではないでごわす！あんな野蛮人の集まりと一緒にしないで欲しいでごわす！」"
	DB	"???:  We are not the sumo club. Please don't associate us"
	DB	CR
	DB	"with them."
	DB	NEXT
;	DB	"【%001】：じゃ、じゃあ何部なんです？"
	DB	"%001:  Then what club are you?"
	DB	NEXT
;	DB	"「我々はちょんまげ研究会でごわす！」"
	DB	"???:  We are the samurai hair club! We like to wear our hair"
	DB	CR
	DB	"like samurai and sumo wrestlers!"
	DB	NEXT
;	DB	"【%001】：さいならぁ～っ！"
	DB	"%001:  Goodbye!!"
	DB	NEXT
;	DB	"俺は小走りにその場を去った。"
	DB	"This is too silly."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M8:		;歩く
;	DB	"「君、引き締まったいい筋肉してるねぇ。」"
	DB	"???:  You have a good body. Slim but muscular."
	DB	NEXT
;	DB	"誰かが俺の肩をぽんと叩いた。"
	DB	"Somebody grabbed me by the shoulder."
	DB	NEXT
;	DB	"（またかよ・・・）"
	DB	"Not again!"
	DB	NEXT
;	DB	"「Ｊ隊入らない？」"
	DB	"???:  How about joining the school liberation front?"
	DB	NEXT
;	DB	"振り返ると、日本の特別公務員であるところのＪ隊の制服を着たおじさんがいた。"
	DB	"I look back and a man wearing a military uniform is standing"
	DB	CR
	DB	"there."
	DB	NEXT
;	DB	"【%001】：え・・・遠慮しときますッ！"
	DB	"%001:  Uh, thanks, I'll pass!"
	DB	NEXT
;	DB	"俺は全速力で逃げ出した。"
	DB	"I get the hell out of there."
	DB	NEXT
;	DB	"（何なんだ今の・・・）"
	DB	"What was that?" 
	DB	FLG,F_COPYI,3,3
	DW	0000H

M9:		;歩く
;	DB	"「キミ新入生？」"
	DB	"???:  You a freshman?"
	DB	NEXT
;	DB	"【%001】：そうだけど。"
	DB	"%001:  Yeah, that's right. What do you want?"
	DB	NEXT
;	DB	"俺の前に立ちはだかった二人組の男は、突然こんな事を言い出した。"
	DB	"Two large guys were standing in my way."
	DB	NEXT
;	DB	"「うどんは関東風と関西風、どっちが好き？」"
	DB	"???:  What type of udon noodles do you like? The thin"
	DB	CR
	DB	"kind or the fat kind?"
	DB	NEXT
;	DB	"【%001】：は？"
	DB	"%001:  Huh?"
	DB	C_BLD,C_V_ON,1		;見る
	DB	C_BLD,C_V_ON,2		;考える
	DB	C_BLD,C_V_ON,3		;歩く
	DB	C_BLD,C_V_OFF,4		;関東風
	DB	C_BLD,C_V_OFF,5		;関西風
	DB	C_BLD,C_V_OFF,6		;スパゲッティ
	DW	0000H

M10:		;関東風
;	DB	"【%001】：やっぱ関東風かな。"
	DB	"%001:  The thin kind, I guess."
	DB	NEXT
;	DB	"「おお同志よ！我々『黒つゆの会』は君を歓迎するぞ！」"
	DB	"???:  A comrade! We are the Black Soup Club. We welcome"
	DB	CR
	DB	"you to our club."
	DB	NEXT
;	DB	"【%001】：ヤなこった。"
	DB	"%001:  Sorry, not interested."
	DB	NEXT
;	DB	"俺は二人を残して立ち去った。"
	DB	"I run away again."
	DB	NEXT
	DB SINARIO,"CS202.OVL",0
	DW	0000H

M11:		;関西風
;	DB	"【%001】：俺は関西風の白いつゆの方が好きだな。"
	DB	"%001:  I like the fat kind."
	DB	NEXT
;	DB	"「・・・」"
	DB	"???:  ...................."
	DB	NEXT
;	DB	"「同士ウィルヘルム、彼は将来我々『黒つゆの会』に破滅をもたらす凶星かも知れません。今この場でその芽をつんでおくべきかと。」"
	DB	"???:  Comrade Willhelm, this person could be an infdel"
	DB	CR
	DB	"who will someday call destruction down on our Black Soup"
	DB	CR
	DB	"Club. We must deal with him now."
	DB	NEXT
;	DB	"「落ち着け同士シュルツ。彼が『白つゆ向上委員会』に入るとは限るまい。」"
	DB	"???:  Calm down comrade Shultz. There is no reason to believe"
	DB	CR
	DB	"that he will enter the Committee for the Promotion of White"
	DB	CR
	DB	"Soup."
	DB	NEXT
;	DB	"「しかし同士ウィルヘルム！」"
	DB	"???:  But commrade Willhelm!"
	DB	NEXT
;	DB	"・・・俺は突然漫才を始めた二人を残して立ち去った。"
	DB	"I run away again."
	DB	NEXT
	DB SINARIO,"CS202.OVL",0
	DW	0000H

M12:		;スパゲッティ
;	DB	"【%001】：俺はスパゲッティが好きだな。"
	DB	"%001:  Actually, I prefer spaghetti."
	DB	NEXT
;	DB	"「・・・」"
	DB	"???:  Huh?"
	DB	NEXT
;	DB	"「同士ウィルヘルム、彼は将来我々『黒つゆの会』に破滅をもたらす凶星かも知れません。今この場でその芽をつんでおくべきかと。」"
	DB	"???:  Comrade Willhelm, this person could be an infdel who"
	DB	CR
	DB	"will someday call destruction down on our Black Soup"
	DB	CR
	DB	"Club. We must deal with him."
	DB	NEXT
;	DB	"「落ち着け同士シュルツ。彼が『パスタ・パッショーネ』に入るとは限るまい。」"
	DB	"???:  Calm down, Comrade Shultz. There is no reason to believe"
	DB	CR
	DB	"that he will enter the Friends of Pasta Society."
	DB	NEXT
;	DB	"「しかし同士ウィルヘルム！」"
	DB	"???:  But commrade Willhelm!"
	DB	NEXT
;	DB	"・・・俺は突然漫才を始めた二人を残して立ち去った。"
	DB	"I run away again."
	DB	NEXT
	DB SINARIO,"CS202.OVL",0
	DW	0000H


end
