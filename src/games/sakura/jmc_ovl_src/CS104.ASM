;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　１０４
;		
	
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,-1
CM2:	DW	VV2,	NN5,-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"聞く",0
VV2:	DB	2,	"LISTEN",0

;NN1:	DB	1,	"誠",0
NN1:	DB	1,	"MAKOTO",0
;NN2:	DB	2,	"清美",0
NN2:	DB	2,	"KIYOMI",0
;NN3:	DB	3,	"星愛",0
NN3:	DB	3,	"SEIA",0
;NN4:	DB	4,	"恵依美",0
NN4:	DB	4,	"MEIMI",0
;NN5:	DB	5,	"今日子",0
NN5:	DB	5,	"KYOKO",0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　誠
S2:		DW	VV1, NN2,  2, M3		;見る　清美
S3:		DW	VV1, NN3,  3, M4		;見る　星愛
S4:		DW	VV1, NN4,  4, M5		;見る　恵依美
S5:		DW	VV1, NN5,  5, M6, M7, M8		;見る　今日子先生
S6:		DW	VV2, NN5,  6, M9, M10, M11, M12, M13, M14, M15, M16		;聞く　今日子の話


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT "AB_36_3"
	B_P1 B_SUDA
;	DB	"・・・長い長い入学式が終わって、俺達は教室に足を踏み入れた。"
	DB	"After the long entrance ceremony, we at last set foot in "
	DB	CR
	DB	"the classroom."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02","W",0,12,1		;ＣＧ　清美 
;	DB	"【清美】：山神さん。"
	DB	"Kiyomi:  %001?"
	DB	NEXT
;	DB	"取り合えず自分の席を見つけてカバンを置いた俺の所に、さっきの",CR,"新藤　清美さんがやって来た。"
	DB	"After finding her own seat and putting down her bag, Kiyomi"
	DB	CR
	DB	"Shinfuji comes over to me."
	DB	NEXT
;	DB	"【%001】：ああ、新藤さん。"
	DB	"%001:  Hi, Kiyomi."
	DB	NEXT
;	DB	"【清美】：はあ・・・どうして入学時の座席は出席番号順と決まっているのでしょう。"
	DB	"Kiyomi:  Why is it that when the year starts, seating is" 
	DB	CR
	DB	"decided by student number?"
	DB	NEXT
;	DB	"【清美】：わたくし、山神さんの隣か前か後か斜めの席を所望しておりましたのに。"
	DB	"Kiyomi:  I was hoping I could sit next to you. Or at least" 
	DB	CR
	DB	"behind you..."
	DB	NEXT
;	DB	"【清美】：早く席替えになりませんかしらね。"
	DB	"Kiyomi:  I wonder how long it will be before the professor"
	DB	CR
	DB	"changes our seats?"
	DB	NEXT
;	DB	"【%001】：まあ、大体２週間の辛抱じゃねえかな。"
	DB	"%001:  Hmm. Probably about two weeks or so."
	DB	NEXT
;	DB	"（・・・生徒の方で席順決められるかどうかは分からんが。）"
	DB	"I found myself wondering what kind of professor we'd get."
	DB	NEXT
;	DB	"「は～いみんな席ついて～。」"
	DB	"???:  Okay, everyone. Take your seats."
	DB	NEXT
;	DB	"【清美】：あら、先生がいらっしゃいましたね。"
	DB	"Kiyomi:  Ah, the professor is here."
	DB	NEXT
;	DB	"新藤さんは自分の席に戻っていった。"
	DB	"Kiyomi went back to her own seat."
	DB	NEXT
	E_CG B_NORM,"AE_024"
;	DB	"【今日子】：え～皆さん、入学おめでとう。"
	DB	"Kyoko:  Congratulations on entering this school."
	DB	NEXT
;	DB	"【今日子】：じ～っと座らされたまま年寄りの長話を聞かされるのは、さぞかし退屈だったでしょう。お疲れサマ。"
	DB	"Kyoko:  It must have been boring for you to sit and listen"
	DB	CR
	DB	"to all those adults making boring speeches."
	DB	NEXT
;	DB	"【今日子】：だから私のあいさつは手短にしとくわね。"
	DB	"Kyoko:  So I'll keep my greetings short."
	DB	NEXT
;	DB	"【今日子】：私があなたたち１－Ａの担任、小林　今日子です。"
	DB	"Kyoko:  I am your homeroom professor, Kyoko Kobayashi. I'm"
	DB	CR
;	DB	"仲良くしてネ☆"
	DB	"really happy to meet you all!"
	DB	NEXT
	E_CG B_NORM,"AE_003"
;	DB	"先生は時間割やら連絡網やらのプリントを配った。"
	DB	"The professor passed out our schedule and phone contact list."
	DB	C_BLD,C_N_ON,1,1		;見る　誠
	DB	C_BLD,C_N_ON,1,3		;見る　星愛
	DB	C_BLD,C_N_ON,1,4		;見る　恵依美
	DW	0000H

M2:		;見る　誠
;	DB	"何となく、お祭り好きそうなやつだ。"
	DB	"This is an odd-looking guy."
	DB	NEXT
;	DB	"どこのクラスにも一人はいる、お調子者タイプってところか。"
	DB	"Every class seems to have someone like him."
	DW	0000H

M3:		;見る　清美
;	DB	"先生の話を熱心に聞きながら、メモまで取っている。"
	DB	"She's listening to the professor and taking notes."
	DB	NEXT
;	DB	"几帳面なんだな、新藤さん。"
	DB	"Kiyomi looks like she studies a lot."
	DW	0000H

M4:		;見る　星愛
;	DB	"割とおっとりした感じに見えるが、言うことは言うタイプらしい。"
	DB	"Looks like a quiet type. But I bet she's not always like that."
	DB	NEXT
;	DB	"首から十字架をぶら下げてるが、クリスチャンなんだろうか？"
	DB	"There is a cross hanging from her neck. She must be a"
	DB	CR
	DB	"Christian."
	DW	0000H

M5:		;見る　恵依美
;	DB	"けっこー、いやかなり気が強そうな女子だ。"
	DB	"Hmm, looks like an outspoken person."
	DW	0000H

M6:		;見る　今日子先生
;	DB	"（結構若く見えるけど、あの手慣れた感じからすると新任ってわけじゃなさそうだ。）"
	DB	"She looks pretty young. But she handles herself with"
	DB	CR
	DB	"confidence, so I doubt if she's a new professor."
	DB	NEXT
;	DB	"（一体何才なんだ？）"
	DB	"I wonder how old she is...."
	DB	FLG,F_COPYI,5,1
	DW	0000H


M7:		;見る　今日子先生
;	DB	"（よかった、明るい先生で。）"
	DB	"I'm glad we got a friendly one."
	DB	NEXT
;	DB	"（暴力教師とかに当たったら一年間悲惨だもんな。）"
	DB	"Some professors are really violent... That would suck."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M8:		;見る　今日子先生
;	DB	"（まあ、美人の範疇に入るんじゃないの？よくわかんねーけど。）"
	DB	"I guess you would call her beautiful. Can't really tell yet."
	DB	FLG,F_COPYI,5,0
	DW	0000H

M9:		;聞く　今日子の話
;	DB	"【今日子】：え～、日直は男子と女子一人ずつ、出席番号順にやってもらうわね。"
	DB	"Kyoko:  The daily cleaning will be done by two students, one"
	DB	CR
	DB	"man and one woman."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M10:		;聞く　今日子の話
;	DB	"【今日子】：で、みんなには５人一組の生活班ってのに分かれてもらうわ。掃除の当番とかはこの班単位でローテーションを組むから。"
	DB	"Kyoko:  We will make five-person work groups. Those groups "
	DB	CR
	DB	"will do the cleaning in rotation."
	DB	NEXT
;	DB	"【今日子】：ここからここまでが１班。そこからそこまでが２班ね・・・"
	DB	"Group one is from here to here. Group two from here to here..."
	DB	NEXT
;	DB	"先生が適当に班分けした結果、俺は３班になった。"
	DB	"I ended up in group three after the professor was done."
	DB	NEXT
;	DB	"【今日子】：各班で一人、班長を決めといてね。"
	DB	"Kyoko:  Everyone decide on one group leader each."
	DB	FLG,F_COPYI,6,2
	DW	0000H


M11:		;聞く　今日子の話
;	DB	"【今日子】：さて、後はクラス委員とか決めなきゃいけないんだけど、まだ先生も君達も、お互いの事をよく知らないわよね。"
	DB	"Kyoko:  Afterward, we have to decide a representative to"
	DB	CR
	DB	"the student council. But since we don't know each other"
	DB	CR
	DB	"that well yet, we'll do it later."
	DB	NEXT
;	DB	"【今日子】：だから細かいことは後回しにして、とりあえず・・・"
	DB	"Kyoko:  But for now, lets have a party!"
	DB	NEXT
;	DB	"・・・教室の時間が止まった。"
	DB	"Silence fell over the classroom."
	DB	NEXT
;	DB	"（・・・冗談だよな？本気じゃないよな？）"
	DB	"Is she serious? No, she can't be...."
	DB	NEXT
;	DB	"【今日子】：さ、みんな机を後ろにやって！ほらほら！"
	DB	"Kyoko:  Everyone push your desks to the back of the room."
	DB	NEXT
;	DB	"そう言って先生は日本酒の瓶と、ツマミで一杯の袋を取り出した・・・。"
	DB	"Saying that, the professor pulled out a bottle of sake and"
	DB	CR
	DB	"some chips."
	DB	NEXT
;	DB	"（・・・本気か、あの先生・・・？！）"
	DB	"She's serious!"
	DB	FLG,F_COPYI,6,3
	DW	0000H


M12:		;聞く　今日子の話
	DB	BUF,B_COPY01
	T_CG "CT07","W","D",12,2		;ＣＧ　星愛
;	DB	"【？】：あの、先生、自己紹介ではないのでしょうか？"
	DB	"???:  Um, Sensei, don't we have to do self introductions"
	DB	CR
	DB	"or something? You know, like Japanese always do?"
	DB	NEXT
;	DB	"教室中が呆気に取られてざわついている中、一人の女の子が静かに立ち上がって質問した。"
	DB	"In the midst of confusion, one woman got up and questioned"
	DB	CR
	DB	"the professor."
	DB	NEXT
;	DB	"【今日子】：ええ、自己紹介も兼ねてるわよ。え～と、あなたは・・・"
	DB	"Kyoko:  Okay, then, let's do self-introductions. What's"
	DB	CR
	DB	"your name?"
	DB	NEXT
;	DB	"【星愛】：出席番号３６番、吉田　星愛（せいあ）と申します。"
	DB	"Seia:  My name is Seia Yoshida, student number 36."
	DB	NEXT
;	DB	"【星愛】：もし先生が本気でこの教室で宴会をしようとおっしゃってるなら、わたくし先生の正気を疑ってしまいますわ。"
	DB	"Seia:  If you really intend to have a party in the classroom,"
	DB	CR
	DB	"I'll have no choice but to question your sanity."
	DB	NEXT
;	DB	"【星愛】：学校にお酒を持ち込むなんて、聖職者にあるまじき行為ですわよ。免職もありえますわね。"
	DB	"Seia:  Bringing alchohol to school is a violaton of the"
	DB	CR
	DB	"trust placed in you as an educator. It could mean your"
	DB	CR
	DB	"license."
	DB	NEXT
;	DB	"その女の子はのんびりした口調で結構キツイ事を言った。"
	DB	"......Wow, she's spunky."
	DB	FLG,F_COPYI,6,4
	DB	C_BLD,C_N_OFF,1,3		;見る　星愛
	DW	0000H

M13:		;聞く　今日子の話
	DB	BUF,B_COPY01
	T_CG "CT14","W",0,12,3		;ＣＧ　誠
;	DB	"【？】：でもさあ・・・ふつーに自己紹介とかするよりも、みんなでパーッと騒ぐ方が親睦が深まるんじゃないか？"
	DB	"???:  Yes, but rather than just getting up and introducing"
	DB	CR
	DB	"ourselves like everyone always does, a party is a better way"
	DB	CR
	DB	"to get to know each other."
	DB	NEXT
;	DB	"【今日子】：そうそう！え～と・・・島崎　誠君ね、君の言う通りよ！"
	DB	"Kyoko:  That's right! Uh, Makoto Shimazaki, it's just"
	DB	CR
	DB	"like you say!"
	DB	NEXT
;	DB	"俺の二つ右の席に座っていた男子が賛成すると、先生はもっともらしい理屈をつけ始めた。"
	DB	"Then she went on..."
	DB	NEXT
;	DB	"【今日子】：君達、今まで１分ずつの自己紹介とかしてたでしょうけど、その内何人くらい覚えられたかしら？"
	DB	"Kyoko:  In the past, you have done the standard one-minute"
	DB	CR
	DB	"self-introduction speech. But how much of that do you"
	DB	CR
	DB	"remember?"
	DB	NEXT
;	DB	"（確かに、一度に４０人近く覚えようなんて無理な話だよな。"
	DB	"She's right. It's really hard to remember forty people's names"
	DB	CR
	DB	"all at once."
	DB	NEXT
;	DB	"少なくとも俺には出来ねーぞ。）"
	DB	".......At least I can't do it."
	DB	FLG,F_COPYI,6,5
	DB	C_BLD,C_N_OFF,1,1		;見る　誠
	DW	0000H

M14:		;聞く　今日子の話
	DB	BUF,B_COPY01
	T_CG "CT07","W","D",12,2		;ＣＧ　星愛
;	DB	"【星愛】：例えそうだとしても、やはり神聖な学び舎で飲酒するというのは世間一般の常識から大きく外れていると思いますわ。"
	DB	"Seia:  I'm sorry, but drinking in the sacred halls of"
	DB	CR
	DB	"learning is far from common sense."
	DB	NEXT
	T_CG1 "CT08","W","D",30,4		;ＣＧ　恵依美 
	DB	ANI,A_ON,2
;	DB	"【？】：星愛の言う通りよ！生徒にお酒飲ます先生なんて聞いた事ないわ！"
	DB	"???:  Yeah, its like Seia says. I have never heard of a"
	DB	CR
	DB	"professor who lets her students drink."
	DB	NEXT
;	DB	"【今日子】：そう？この学校じゃそんなに珍しくないのよ。え～と・・"
	DB	"Kyoko:  Really? It isn't that unusual in this school. Um,"
	DB	CR
	DB	"what's your name?"
	DB	NEXT
;	DB	"【恵依美】：中野　恵依美（めいみ）！それはこの学校が変なのよ！"
	DB	"Meimi:  Meimi Nakano. This school is really weird."
	DB	NEXT
;	DB	"【今日子】：ウチはほら、校長先生があ～ゆ～人だから。"
	DB	"Kyoko:  It's because our pricipal is weird."
	DB	NEXT
;	DB	"・・・そうこうしている内に、教室はまっ二つに割れてしまった。"
	DB	".....Over the course of a few minutes, the class divided"
	DB	CR
	DB	"into two groups."
	DB	NEXT
;	DB	"今日子先生、島崎　誠を始めとする宴会賛成派と、吉田　星愛と中野　恵依美を筆頭とする反対派。"
	DB	"The professor and Makoto Shimazaki lead those for having"
	DB	CR
	DB	"the party. Seia Yoshida and Meimi Nakano were on the"
	DB	CR
	DB	"opposing side."
	DB	NEXT
;	DB	"気が付いたら、態度を保留してるのは俺だけになっていた。"
	DB	"Before I knew it, I was the only one who was yet to choose"
	DB	CR
	DB	"sides."
;	DB	NEXT
	DB	FLG,F_COPYI,6,6
	E_CG B_NORM,"AE_003"
	DB	C_BLD,C_N_OFF,1,4		;見る　恵依美
	DW	0000H

M15:		;聞く　今日子の話
;	DB	"【今日子】：君はどうなの？山神　%001君。"
	DB	"Kyoko:  What side are you on, %100 Yamagami?"
	DB	NEXT
;	DB	"【%001】：俺は、別にどっちでもいい。"
	DB	"%001:  I don't care. Either one is fine with me."
	DB	NEXT
;	DB	"【恵依美】：あんた、それって無責任じゃないの！"
	DB	"Meimi:  You have to make up your mind!"
	DB	NEXT
;	DB	"【%001】：む、無責任たってな・・・。"
	DB	"%001:  ....Why?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT14","W",0,12,3		;ＣＧ　誠
;	DB	"【誠】：お前もクラスの一員なんだから、ちゃんと考えろよ。"
	DB	"Makoto:  You're a member of this class. Think about it."
	DB	NEXT
;	DB	"【誠】：オレ達のどっちにも味方しないなら、何か代案を出せよな。"
	DB	"Makoto:  If you don't want to take sides, why don't you"
	DB	CR
	DB	"come up with an alternative?"
	DB	NEXT
;	DB	"【%001】：代案？"
	DB	"%001:  An alternative?"
	DB	NEXT
;	DB	"【誠】：例えばさ、やっぱり高校生の飲酒は良くないからお酒はナシ、とかさ。"
	DB	"Makoto:  For example: college students shouldn't drink,"
	DB	CR
	DB	"so let's have a party without alchohol."
	DB	NEXT
;	DB	"【今日子】：え～・・・"
	DB	"Kyoko:  Hey! that's no fun..."
	DB	NEXT
;	DB	"【恵依美】：先生！"
	DB	"Meimi:  Sensei!"
	DB	NEXT
;	DB	"いつのまにか、決定権は俺の手に委ねられたらしい。クラスのみんなが俺の方を見ている。"
	DB	"Before I knew it the decision was in my hands. The entire"
	DB	CR
	DB	"class was looking to me." 
	DB	NEXT
;	DB	"（このままどっちかに味方したら、残り半分の恨みを買うかもな。）"
	DB	"I can't take sides now. If I do, half the class will never"
	DB	CR
	DB	"forgive me."
	DB	NEXT
;	DB	"（う～む・・・どうしたもんか。）"
	DB	"...........What the hell should I do?"
	DB	NEXT
;	DB	"そんな時、窓の外の満開の桜が目に入った。"
	DB	"Just then, a sight from out the window caught my eye."
	DB	CR
	DB	"The cherry blossoms were in full bloom."
	DB	NEXT
;	DB	"【%001】：じゃあ・・・"
	DB	"%001:  Well..."
	DB	NEXT
;	DB	"【%001】：学校内で騒ぐのもなんだから、どっかでお花見するってのはどうだ？社会勉強にもなると思うし。"
	DB	"%001:  We can't go making a lot of noise in school. Why"
	DB	CR
	DB	"don't we plan a cherry blossom-viewing party? It would "
	DB	CR
	DB	"be a good study of Japanese culture."
	DB	NEXT
;	DB	"【誠】：なるほど、それならいいんじゃない？"
	DB	"Makoto:  Hey, that's a great idea!"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG "CT07","W",0,12,6		;ＣＧ　星愛
	T_CG "CT08","W",0,30,5		;ＣＧ　恵依美 
	DB ANI,A_ON,6	
;	DB	"【星愛】：学校外でするのでしたらわたくしは何も申しませんわ。"
	DB	"Seia:  I don't mind that."
	DB	NEXT
;	DB	"【今日子】：花見で一杯か、それって日本人の義務よね。"
	DB	"Kyoko:  Yes...cherry blossoms. It's our duty as Japanese"
	DB	CR
	DB	"to do it! We'll plan it for next weekend!"
	DB	NEXT
;	DB	"【恵依美】：お酒飲むのは先生だけですよ！"
	DB	"Meimi:  The only one drinking will be you, Sensei!"
	DB	NEXT
;	DB	"（・・・どうやら一応みんな納得してくれたらしい。）"
	DB	"It looks like everyone is in agreement."
	DB	FLG,F_COPYI,6,7
	DW	0000H

M16:		;聞く　今日子の話
;	DB	"【今日子】：わかったわ。それじゃ今日は簡単な自己紹介にしておきましょう。その前に・・・"
	DB	"Kyoko:  Okay, that's settled. And now..."
	DB	NEXT
;	DB	"【今日子】：%001君に誠君、君達二人を「宴会委員」に任命します。"
	DB	"Kyoko:  %001 and Makoto. You two are nominated to be the"
	DB	CR
	DB	"party committee."
	DB	NEXT
;	DB	"【%001】：えっ宴会委員！？"
	DB	"%001:  Huh? Party committee!?"
	DB	NEXT
;	DB	"【誠】：それって、要は花見の幹事ですね？"
	DB	"Makoto:  In other words, we're in charge of the cherry"
	DB	CR
	DB	"blossom-viewing party?"
	DB	NEXT
;	DB	"【今日子】：そゆこと。ま、言い出しっぺってことでネ。"
	DB	"Kyoko:  That's right. That is if there are no objections?"
	DB	NEXT
;	DB	"【今日子】：それと、星愛さんと恵依美さんにはクラス委員をお願いするわ。"
	DB	"Kyoko:  Seia and Meimi are the student council representatives."
	DB	NEXT
;	DB	"【恵依美】：うそっ！？あたし？！"
	DB	"Meimi:  No way! Me?!"
	DB	NEXT
;	DB	"【星愛】：わたくしでよろしければ、やらせていただきます。"
	DB	"Seia:  If it is agreeable to everyone, I accept the duty."
	DB	NEXT
;	DB	"・・・その後、吉田と中野がＨＲを仕切って、美化委員やら図書委員やらが速やかに決定されていったのだった。"
	DB	"...Those two got right on with their jobs. They decided"
	DB	CR
	DB	"who would be in charge of keeping the class clean, who"
	DB	CR
	DB	"would get library duty and so on."
	DB	NEXT
;	DB	"・・・・・・・・・ＨＲ終了・・・・・・・・・"
	DB	"Then, school was over."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT14","W","K",12,7		;ＣＧ　誠
;	DB	"【誠】：山神、ヒマだったら帰りに花見の下見に行かないか？"
	DB	"Makoto:  %001, shall we scout a good spot for the cherry"
	DB	CR
	DB	"blossom viewing later?"
	DB	NEXT
;	DB	"【%001】：いいよ、別に用事ねーし。"
	DB	"%001:  Sure, let's go."
	DB	NEXT
;	DB	"【誠】：改めてよろしくな。オレ、島崎　誠。"
	DB	"Makoto:  By the way, I'm Makoto Shimazaki."
	DB	NEXT
;	DB	"【%001】：俺は山神　%001。"
	DB	"%001:  I'm %001 Yamagami."
	DB	NEXT
;	DB	"【誠】：とりあえず川沿いのとこから見て行こうぜ。"
	DB	"Makoto:  Let's try down by the river first."
	DB	NEXT
;	DB	"俺は島崎　誠と一緒に学校を後にした。"
	DB	"I leave the school with Makoto Shiazaki."
	DB	NEXT
;	DB	"そんなこんなで、俺の高校生活第一日目は過ぎて行った。"
	DB	"And that is how I ended the first day of shool."
	DB	NEXT
	B_P1 B_SUDA
;	DB	"・・・・・・・・・・・・・・・"
	DB	"................................................"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT02","W",0,12,1		;ＣＧ　清美 
;	DB	"【清美】：山神さん、よろしければ帰り御一緒・・・"
	DB	"Kiyomi:  %001, is it okay if we walk home together?"
	DB	NEXT
	K_CG "CT02","I",12,8		;ＣＧ　清美 
;	DB	"【清美】：あら・・・"
	DB	"Kiyomi:  Huh........"
	DB	NEXT
;	DB	"【清美】：もうお帰りになってしまわれたみたいですわね。"
	DB	"Kiyomi:  Looks like he's alredy left."
	DB	NEXT
;	DB	"【清美】：残念ですわ・・・せっかく先程のお話の続きが出来ると思いましたのに・・・。"
	DB	"Kiyomi:  That's too bad. And I was going to finish the"
	DB	CR
	DB	"rest of the story......."
	DB	NEXT
	DB SINARIO,"CS201.OVL",0
	DW	0000H
	end
