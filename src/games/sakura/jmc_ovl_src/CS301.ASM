;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　３０１
;		花見の場所取り

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,-1
CM2:	DW	VV2,	NN2,NN3,-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"話す",0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	"桜",0
NN1:	DB	1,	"SAKURA",0
;NN2:	DB	2,	"誠",0
NN2:	DB	2,	"MAKOTO",0
;NN3:	DB	3,	"今日子",0
NN3:	DB	3,	"KYOKO",0
;NN4:	DB	4,	"酒",0
NN4:	DB	4,	"SAKE",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　桜
S2:		DW	VV1, NN2,  2, M3		;見る　誠
S3:		DW	VV1, NN3,  3, M4		;見る　今日子
S4:		DW	VV1, NN4,  4, M5, M6		;見る　酒
S5:		DW	VV2, NN2,  5, M7, M8, M9, M10		;話す　誠
S6:		DW	VV2, NN3,  6, M11, M12		;話す　今日子


;イニシャルメッセージ
M1:
	DB	BGM,32
	BAK_INIT "AB_07_2"
	E_CG B_GURU,"T_03"
	DB	BUF,B_COPY01
	TU_CG "CT14","C","K",30,1
	T_CG "CT12","C","K",5,2
	DB	ANI,A_ON,1
;	DB	"それからさらに一週間が過ぎた。"
	DB	"...One week passed."
	DB	NEXT
;	DB	"宴会委員に任命された俺と誠、そして今日子先生は、明日のお花見の場所取りに来ている。"
	DB	"Makoto and I, along with Kyoko-sensei, have come looking"
	DB	CR
	DB	"for a place to have our cherry blossom-viewing party tomorrow."
	DB	NEXT
;	DB	"【誠】：４月でも、さすがに夜は冷えるなぁ・・・"
	DB	"Makoto:  April nights sure are cold."
	DB	NEXT
;	DB	"【今日子】：どう？一杯。あったまるわよ。"
	DB	"Kyoko:  How about a drink? It'll really warm you up."
	DB	NEXT
;	DB	"【%001】：先生、今から飲んでどーすんです。"
	DB	"%001:  Are you really going to start drinking now?"
	DB	NEXT
;	DB	"今日子先生は夜桜を眺めながらさっそく飲み始めてる。"
	DB	"Yes, she was."
	DB	NEXT
;	DB	"【誠】：あ、オレいただきます。"
	DB	"Makoto:  I'll have a drink."
	DB	NEXT
;	DB	"今日子先生が誠の紙コップに酒を注ぐ。"
	DB	"Kyoko poured sake into Makoto's paper cup."
	DB	NEXT
;	DB	"ぐいっ・・・"
	DB	"*GULP*"
	DB	NEXT
;	DB	"【誠】：う～ん！何かこう、肝臓にキュ～ッとくるなあ！"
	DB	"Makoto:  Whoah! That's strong!"
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DW	0000H

M2:		;見る　桜
;	DB	"夜見る桜は、何か無気味な美しさがある。"
	DB	"The evening cherry blossoms are hauntingly beautiful."
	DB	NEXT
;	DB	"植物も生き物だって実感するのは、こんな時だ。"
	DB	"It makes you feel like the trees really are living,"
	DB	CR
	DB	"sentient creatures."
	DB	NEXT
	DB	"In Japan, it's a tradition to come out to where the cherry"
	DB	CR
	DB	"blossoms are and have a party. It's called 'hanami' in "
	DB	CR
	DB	"Japanese."
	DB	NEXT
	DB	"Japanese sometimes bring portible karaoke machines with"
	DB	CR
	DB	"them and fill the air with singing while they get drunk."
	DW	0000H

M3:		;見る　誠
;	DB	"酒が入って、すっかり上機嫌になっている。"
	DB	"He's had a little sake and seems to be feeling good."
	DW	0000H

M4:		;見る　今日子
;	DB	"一升瓶を抱えて、にこにこ微笑んでる。"
	DB	"She's holding the sake bottle to herself like a baby,"
	DB	CR
	DB	"smiling."
	DW	0000H

M5:		;見る　酒
;	DB	"先生の後ろに、燃えないゴミと化した瓶が、すでに５～６本転がっている。"
	DB	"Behind Kyoko are five or six empty bottles."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M6:		;見る　酒
;	DB	"【%001】：それ全部酒なんですか？"
	DB	"%001:  Is all of that sake?"
	DB	NEXT
;	DB	"【今日子】：あら、あったり前じゃない。日本の花見には、日本酒を用意するのが日本人の心意気ってモンよ。"
	DB	"Kyoko:  Of course it is. For traditional cherry blossom-"
	DB	CR
	DB	"viewing, you need traditional drinks."
	DB	NEXT
;	DB	"【%001】：・・・はぁ、さいですか・・・"
	DB	"%001:  I didn't know that."
	DW	0000H

M7:		;話す　誠
;	DB	"【誠】：それにしても、お前モテモテだよな、%001。"
	DB	"Makoto:  By the way, I'm really surprised to see what a "
	DB	CR
	DB	"ladies' man you turned out to be, %001."
	DB	NEXT
;	DB	"【誠】：で、誰が本命なんだ？"
	DB	"Makoto:  Which of them are you going for?"
	DB	NEXT
;	DB	"【%001】：本命も何も、あの人達は俺をクラブに勧誘してるだけだろ。"
	DB	"%001:  It's nothing like that. They're just trying to get"
	DB	CR
	DB	"me to join their clubs."
	DB	NEXT
;	DB	"【今日子】：本気でそう思ってるの？%001君。"
	DB	"Kyoko:  You really think that's all there is to it?"
	DB	NEXT
;	DB	"【誠】：ホント、%001ってお子様だよなあ。"
	DB	"Makoto:  You really are a fool, %001."
	DB	NEXT
;	DB	"【%001】：？"
	DB	"%001:  ..........................."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M8:		;話す　誠
;	DB	"【誠】：%001、鈴子さんってい～よなぁ。落ち着きがあって、気品に満ちてて、それでいて変に飾ったとこが無くてさ。"
	DB	"Makoto:  Now Reiko's the one I'd pick. She has it all"
	DB	CR
	DB	"together -- she's outgoing, and she isn't a real show-off."
	DB	NEXT
;	DB	"【%001】：そうかぁ？けっこうそそっかしんだぜ、あの人。"
	DB	"%001:  ........................................"
	DB	NEXT
;	DB	"【今日子】：あら、誠君、年上の人が好きなの？"
	DB	"Kyoko:  So you like older women, Makoto?:"
	DB	NEXT
;	DB	"【誠】：オレの年で年下が好きなんて奴はただのロリコンですよ。"
	DB	"Makoto:  Not always. It depends on the person."
	DB	NEXT
;	DB	"【誠】：先生はいい人いないんですか？"
	DB	"Makoto:  Do you have somebody special, Sensei?"
	DB	NEXT
;	DB	"【今日子】：ど～ゆ～わけか、縁が無くてね。"
	DB	"Kyoko:  For some reason, I just don't seem to find any decent"

	DB	CR

	DB	"men."
	DB	NEXT
;	DB	"【誠】：先生、俺なんかどーですか？"
	DB	"Makoto:  What about me?"
	DB	NEXT
;	DB	"【今日子】：ありがと、考えとくわ。"
	DB	"Kyoko:  Thanks, I'll think about it."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M9:		;話す　誠
;	DB	"【誠】：それで実際のところ、あの３人の中で誰が一番いいんだ？"
	DB	"Makoto:  Tell the truth, %001. Which of those three is"
	DB	CR
	DB	"the best?"
	DB	NEXT
;	DB	"【%001】：一番いいって、何が。"
	DB	"%001:  What do you mean, 'the best'?"
	DB	NEXT
;	DB	"【誠】：こいつぅ、親友のオレにくらい教えてくれてもい～だろ？"
	DB	"Makoto:  You know. Which one are you in love with?"
	DB	NEXT
	DB	"Makoto:  Hey, you can tell me. We're best friends, aren't we?"
	DB	NEXT
;	DB	"（・・・だいぶ酔ってやがるな。）"
	DB	"He's pretty drunk."
	EF_SET 102
	DW	0000H

M10:		;話す　誠
;	DB	"【誠】：%001・・・"
	DB	"Makoto:  %001......."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG "CT12","C","K",5,2
	B_P0 B_NORM
	DB	ANI,A_ON,2
;	DB	"【%001】：ん？"
	DB	"%001:  Hmm?"
	DB	NEXT
;	DB	"誠はやおら立ち上がると、背後から俺にスリーパーホールドをかけた。"
	DB	"Makoto got up and put me in a headlock."
	DB	NEXT
;	DB	"【%001】：ぐぉ・・・！？"
	DB	"%001:  Gyaa!"
	DB	NEXT
;	DB	"【誠】：全く、あんな可愛い子達を独り占めしやがって、許さねえぞ%001！"
	DB	"Makoto:  I can't believe you, running away from those"
	DB	CR
	DB	"pretty women. Are you a man?"
	DB	NEXT
;	DB	"【%001】：ぐぇ・・・誠、お前酔ってるな！？"
	DB	"%001:  Gwaa..... Makoto, you're drunk!"
	DB	NEXT
;	DB	"【誠】：俺にも一人分けろ、このこの！"
	DB	"Makoto:  Bartender! Another!"
	DB	NEXT
;	DB	"【今日子】：いいぞぉ、やれやれ～い。"
	DB	"Kyoko:  Yes, sir!"
	DB	NEXT
;	DB	"【%001】：み・・・見てないで止めてよセンセ～！"
	DB	"%001:  Don't just sit there, get him off me!"
	DB	NEXT
;	DB	"するっ"
	DB	"Makoto:  Uhh..........................."
	DB	NEXT
;	DB	"【%001】：おおっ？"
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	"ぱたっ"
	DB	"*KLUNK*"
	DB	NEXT
;	DB	"【誠】：ぐかぁ～っ・・・"
	DB	"Makoto:  Uuugh....."
	DB	NEXT
;	DB	"酔いがまわったのか、誠は大の字にのびて高イビキで眠ってしまった。"
	DB	"The sake must have gotten to him. Makoto passed out and"
	DB	CR
	DB	"started snoring."
	DB	NEXT
;	DB	"【%001】：・・・言わんこっちゃない。ど～すんですか先生。"
	DB	"%001:  I've never seen anyone pass out so well."
	DB	NEXT
;	DB	"【今日子】：だ～いじょうぶ、その程度ならすぐ目ぇ覚ますって。"
	DB	"Kyoko:  He's okay. He didn't drink that much. He'll be up"
	DB	CR
	DB	"in no time."
	DB	NEXT
;	DB	"【今日子】：それより%001君、サシで飲みましょうよ。"
	DB	"Kyoko:  Now, %001, let's drink up."
	DB	NEXT
;	DB	"【%001】：先生・・・全然反省してませんね・・・。"
	DB	"%001:  You're incredible, Sensei."
	DB	NEXT
;	DB	"「こんばんは、%001さん、先生。」"
	DB	"???:  Good evening...."
	DB	NEXT
	DB SINARIO,"CS302.OVL",0
	DW	0000H

M11:		;話す　今日子
;	DB	"【%001】：・・・先生、未成年者の飲酒は法律で禁止されてんですよ。"
	DB	"%001:  ...You're not supposed to be giving alcohol to"
	DB	CR
	DB	"us!"
	DB	NEXT
;	DB	"【今日子】：いいのよ、保護者同伴だから。"
	DB	"Kyoko:  It's okay. You're with a responsible adult."
	DB	NEXT
;	DB	"【%001】：・・・そうだっけ？"
	DB	"%001:  Where?"
	DB	NEXT
;	DB	"【今日子】：誠君、いい飲みッぷりね。けっこーいけるクチ？"
	DB	"Kyoko:  You're a good drinker, Makoto. You'll go far in life."
	DB	NEXT
;	DB	"【誠】：親父の晩酌に付き合わされてますから。"
	DB	"Makoto:  I drink with my father sometimes."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M12:		;話す　今日子
;	DB	"【今日子】：%001君もどう？"
	DB	"Kyoko:  Want some, %001?"
	DB	NEXT
;	DB	"【%001】：俺はいいです。"
	DB	"%001:  I'm fine."
	DB	NEXT
;	DB	"【誠】：センセ、酒の味のわかんない奴に飲ませちゃもったいないって！"
	DB	"Makoto:  It's just a waste to give sake to someone who"
	DB	CR
	DB	"can't appreciate the flavor."
	DB	NEXT
;	DB	"【今日子】：ふふっ、そうかもね。"
	DB	"Kyoko:  Haha. I guess you're right."
	DB	NEXT
;	DB	"【誠】：全く、%001はお子様だからなぁ。"
	DB	"Makoto:  %001, what a wimp!"
	DB	NEXT
;	DB	"【%001】：酒が飲めりゃ大人ってわけでもねーだろ。"
	DB	"%001:  You don't get to be an adult just because you drink."
	EF_SET 101
	DW	0000H

M_EXIT:
	DB FLG,F_AND,255,101,102
	DB	FLG,F_EXIT,255
	DB	FLG,F_COPYI,5,3
	DW	0000H

end
