;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０１
;		瑠璃登場

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,NN2,NN3,NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	"RURI",0
;NN2:	DB	2,	'誠',0
NN2:	DB	2,	"MAKOTO",0
;NN3:	DB	3,	'星愛',0
NN3:	DB	3,	"SEIA",0
;NN4:	DB	4,	'恵依美',0
NN4:	DB	4,	"MEIMI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　瑠璃
S2:		DW	VV2, NN2,  2, M4, M5, M6		;話す　誠
S3:		DW	VV2, NN1,  3, M7		;話す　瑠璃
S4:		DW	VV2, NN3,  4, M8, M9		;話す　星愛
S5:		DW	VV2, NN4,  5, M10, M11		;話す　恵依美


;イニシャルメッセージ
M1:
	DB	BGM,6
	SUDA_CLS
	E_CG B_YOKO,'T_04'
	BAK_INIT 'AB_36_3'
;	DB	'４月も終わりに近づき、俺達１－Ａがお互いの顔と名前を覚えた頃、',CR,'「彼女」はやって来た。'
	DB	".......She came to our class near the end of April."
	DB	NEXT
	E_CG B_SUDA,'AE_011'
;	DB	'【今日子】：今日は転入生を紹介するわね。入って。'
	DB	"Kyoko:  We have a new student in our class as of today."
	DB	CR
	DB	"Come in and introduce yourself."
	DB	NEXT
;	DB	'【瑠璃】：白水　瑠璃（しろず　るり）です。'
	DB	"Ruri:  I'm Ruri Shiromizu."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ..........................."
	DB	NEXT
;	DB	'【今日子】：・・・'
	DB	"Kyoko:  ..........................."
	DB	NEXT
;	DB	'【今日子】：・・・それで終わり？'
	DB	"Kyoko:  That's all you want to say?"
	DB	NEXT
;	DB	'【瑠璃】：はい。'
	DB	"Ruri:  Yes."
	DB	NEXT
;	DB	'【今日子】：そう・・・'
	DB	"Kyoko:  I see...."
	DB	NEXT
;	DB	'【今日子】：そ、そうだ、みんな瑠璃さんに質問・・・'
	DB	"Kyoko:  Okay, does anyone have any questions for Ruri?"
	DB	NEXT
;	DB	'【瑠璃】：先生。'
	DB	"Ruri:  Sensei?"
	DB	NEXT
;	DB	'【今日子】：な、何？'
	DB	"Kyoko:  Um, yes?"
	DB	NEXT
;	DB	'【瑠璃】：私の席、どこですか。'
	DB	"Ruri:  .......Where's my seat?"
	DB	NEXT
;	DB	'【今日子】：あっ・・・・・・そうね。'
	DB	"Kyoko:  Oh, yes."
	DB	NEXT
;	DB	'【今日子】：じゃあ、あそこの窓側の空いてる席、使ってくれる？'
	DB	"Kyoko:  How about that empty seat over there by the window?"
	DB	NEXT
;	DB	'【瑠璃】：はい。'
	DB	"Ruri:  ........................."
	DB	NEXT
;	DB	'【今日子】：じゃあ・・・みんな、瑠璃さんと仲良くしてネ。'
	DB	"Kyoko:  Well, welcome to our class, Ruri.  Everyone, be"
	DB	CR
	DB	"nice to her, okay?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ..........................."
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DB C_BLD,C_V_ON,2
	B_P1 B_SUDA
	DW	0000H

M2:		;見る　瑠璃
;	DB	'彼女の回りには、たちまちの内に黒山の人だかり（主に男）が出来た。'
	DB	"A whole bunch of people (mostly guys) gathered around her"
	DB	CR
	DB	"right away."
	DB	NEXT
;	DB	'「オレ、島崎　誠！よろしく！」'
	DB	"'Hi, I'm Makoto Shimazaki!'"
	DB	NEXT
;	DB	'「白水さんて、どこから来たの？」'
	DB	"'Ruri, where are you from?'"
	DB	NEXT
;	DB	'「趣味は？」'
	DB	"'What are your hobbies?'"
	DB	NEXT
;	DB	'「どの辺に住んでるの？」'
	DB	"'Where do you live?'"
	DB	NEXT
;	DB	'「校内を案内してあげるよ」'
	DB	"'Would you like a tour of the school?'"
	DB	NEXT
;	DB	'「てめ～、抜け駆けは許さんぞ！」'
	DB	"'Hey, who says she wants a tour from you?!'"
	DB	NEXT
;	DB	'「うっせぇ、早いモン勝ちだよっ！」'
	DB	"'I asked her first!'"
	DB	NEXT
;	DB	'「ＵＦＯの存在を信じるかい？」'
	DB	"'Do you believe in UFO's?'"
	DB	NEXT
;	DB	'「神の存在を信じますか？」'
	DB	"'Do you believe in God?'"
	DB	NEXT
;	DB	'「おいそこ、席に着け。」'
	DB	"Kyoko:  Okay, you guys, let's get on with class now."
	DB	NEXT
;	DB	'「また後でね、白水さん」'
	DB	"'Opps, gotta go. Catch you later, Ruri, okay?'"
	DB	NEXT
;	DB	'・・・・・・１限終了・・・・・・'
	DB	"Then all the guys sat down for class."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT02",'W',0,0,1		;ＣＧ　清美 
;	DB	'【清美】：%001さんはあの方のこと、気にならないのですか？'
	DB	"Kiyomi:  Aren't you going to go over and talk to her,"
	DB	CR
	DB	"%001?"
	DB	NEXT
;	DB	'この前の席替えで、隣になった新藤さんが話し掛けて来た。'
	DB	"Kiyomi, who had been sitting next to me since the last"
	DB	CR
	DB	"seating switch, came over to my seat."
	DB	NEXT
;	DB	'【%001】：まあ気にはなるけど、焦ることねーだろ。今日明日にいなくなるわけじゃなし。'
	DB	"%001:  I'll get around to it. There's no reason for me to"
	DB	CR
	DB	"hurry, is there?"
	DB	NEXT
	T_CG1 "CT14",'W',0,30,2		;ＣＧ　誠
	DB	ANI,A_ON,1 
;	DB	'【誠】：甘いッ！だからお前はお子様なのだ、%001！'
	DB	"Makoto:  That's what you think! I'll have her eating out"
	DB	CR
	DB	"of my hand before you get around to talking to her!"
	DB	NEXT
;	DB	'突然誠が現われた。'
	DB	"Makoto suddenly popped out of nowhere."
	DB	NEXT
;	DB	'【%001】：・・・何だよ薮から棒に。'
	DB	"%001:  How do you do that, anyway?"
	DB	NEXT
;	DB	'【誠】：見ろよあの子を。'
	DB	"Makoto:  Look at the new girl."
	DB	NEXT
;	DB	'【%001】：男どものバリケードで見えねぇ。'
	DB	"%001:  I can't see her. There are too many guys around"
	DB	CR
	DB	"her, trying to talk to her."
	DB	NEXT
;	DB	'【誠】：確かに・・・'
	DB	"Makoto:  Yeah...."
	DB	NEXT
;	DB	'【誠】：でも最初に見た時、触れようとしただけで消えてしまうような儚さを感じたぜ、オレ。':  
	DB	"Makoto:  But when she first stood up there next to Kyoko-"
	DB	CR
	DB	"sensei, I got the feeling that if you tried to touch her,"
	DB	CR
	DB	"she'd disappear."
	DB	NEXT
;	DB	'【清美】：そうですわね・・・まるで春になると解けてしまう、雪の彫像のような・・・'
	DB	"Kiyomi:  You're right. Like a snow sculpture that melts"
	DB	CR
	DB	"in the spring."
	DB	NEXT
;	DB	'【%001】：・・・今、春だろ。'
	DB	"%001:  It's spring, now."
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_N_ON,2,3
	DB C_BLD,C_N_ON,2,4
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　瑠璃
;	DB	'相変わらず人垣の向こうで、こっちからじゃ見えない。'
	DB	"There are too many guys standing around her. I can't see"
	DB	CR
	DB	"her at all."
	DB	NEXT
;	DB	'・・・さっきの休み時間よりは減ってるよーだが。'
	DB	"Although it seemed to be fewer than the last break."
	DW	0000H


M4:		;話す　誠
;	DB	'【%001】：・・・で？'
	DB	"%001:  Well?"
	DB	NEXT
;	DB	'【誠】：なんだ？'
	DB	"Makoto:  Well, what?"
	DB	NEXT
;	DB	'【%001】：教えろよ、あの子のこと。色々聞き出したんだろ？'
	DB	"%001:  Well, tell us about her. Didn't you find out anything?"
	DB	NEXT
;	DB	'【誠】：ほほぉ。なんだかんだ言って、お前も彼女のこと気になるんだな、このヤロ。'
	DB	"Makoto:  Aha. So you're interested in her, after all."
	DB	NEXT
;	DB	'【%001】：当たり前だろ。俺達１－Ａの仲間になるんだし。'
	DB	"%001:  Well obviously. She's our new classmate."
	DB	NEXT
;	DB	'【清美】：そうですわ、変なことをおっしゃらないで下さい。'
	DB	"Kiyomi:  That's right. You don't have to be crude, Makoto."
	DB	NEXT
;	DB	'【誠】：まあ、そういうことにしといてやるよ。'
	DB	"Makoto:  Okay, I'll go ask around..."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　誠
;	DB	'【誠】：で、オレの調査によるとだな。'
	DB	"Makoto:  Well, according to my survey..."
	DB	NEXT
;	DB	'【誠】：実はまだな～んにもわからないんだ。'
	DB	"Makoto:  We know nothing at all."
	DB	NEXT
;	DB	'【%001】：・・・何だよ、期待させといて。'
	DB	"%001:  That's all you can tell us?"
	DB	NEXT
;	DB	'【誠】：しょうがないだろ、彼女一っ言もしゃべらないんだから。'
	DB	"Makoto:  I can't help it......she just doesn't talk at all."
	DB	NEXT
;	DB	'【清美】：・・・一言も、ですか？'
	DB	"Kiyomi:  Not even a word?"
	DB	NEXT
;	DB	'【誠】：そう、一言もさ。オレ、一瞬彼女がよくできた人形なんじゃねぇかって思ったもん。'
	DB	"Makoto:  Nothing. For a second, I really thought she was"
	DB	CR
	DB	"just a well-made doll."
	DB	NEXT
;	DB	'【%001】：今まで外国で生活してて、日本語が分からねえとか・・・'
	DB	"%001:  Well, maybe she lived overseas or something, and"
	DB	CR
	DB	"can't understand Japanese."
	DB	NEXT
;	DB	'【誠】：朝、ちゃんと日本語で話してただろ、先生と。'
	DB	"Makoto:  She was talking with Sensei this morning, wasn't"
	DB	CR
	DB	"she?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT08",'W','D',20,3		;ＣＧ　 
;	DB	'【恵依美】：・・・人形じゃないの？'
	DB	"Meimi:  She's not a doll?"
	DB	NEXT
;	DB	'【誠】：おい・・・聞こえるぜ、中野。'
	DB	"Makoto:  Shut up, Meimi! She'll hear you!"
	DB	NEXT
;	DB	'【恵依美】：いいわよ別に。あたし、ホントの事言ってるだけだもん。'
	DB	"Meimi:  Well, she looks like a doll."
	DB C_BLD,C_N_OFF,2,4	;話す　恵依美
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　誠
;	DB	'【誠】：本人に聞いてダメなら先生から聞き出すしかないな。'
	DB	"Makoto:  Well, if she won't talk us, then we'll just have"
	DB	CR
	DB	"to ask Kyoko-sensei."
	DW	0000H

M7:		;話す　瑠璃
;	DB	'・・・あの人垣がなくなってからにしよう。'
	DB	"Once all the guys around her leave..."
	DW	0000H

M8:		;話す　星愛
;	DB	'【星愛】：あの方は心の清い、いい方ですわ。'
	DB	"Seia:  She's a pure, good person."
	DB	NEXT
;	DB	'【恵依美】：どこが！？'
	DB	"Meimi:  How can you tell?!"
	DB	NEXT
;	DB	'【星愛】：わたくしが「神を信じますか？」とお聞きしたら、「もちろんいる」とお答えになりましたもの。'
	DB	"Seia:  When I asked her if she believed in God, I could"
	DB	CR
	DB	"see in her eyes that she did."
	DB	NEXT
;	DB	'【恵依美】：・・・'
	DB	"Meimi:  ......................."
	DB	NEXT
;	DB	'【星愛】：神を信じる人は、心の清い人ですのよ。'
	DB	"Seia:  Those who believe in God have pure hearts."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M9:		;話す　星愛
	K_CG "CT07",'K',0,5		;ＣＧ　
	DB	ANI,A_ON,3 
;	DB	'【星愛】：恵依美ちゃんは、あの子とお友達になれなかったのが悲しいのですね。'
	DB	"Seia:  I'm sorry you can't have more compassion, Meimi."
	DB	NEXT
	K_CG "CT08",'I',20,6		;ＣＧ　
	DB	ANI,A_ON,5 
;	DB	'【恵依美】：・・・う～・・・'
	DB	"Meimi:  Er....."
	DB	NEXT
;	DB	'【清美】：あ、先生がいらっしゃいましたわ。'
	DB	"Kiyomi:  Oh, here comes Sensei."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'・・・・・・そして、昼休み・・・・・・'
	DB	"Lunchtime..."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT01','W','K',0,7 
	TU_CG 'CT03','W','K',30,8 
	B_P0 B_SUDA
	DB ANI,A_ON,7
	DB ANI,A_ON,8
;	DB	'【鈴子】：%001く～ん！'
	DB	"Reiko:  %001!"
	DB	NEXT
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【鈴子・美緒】：お昼一緒に食べよっ！'
	DB	"Reiko/Mio:  Let's have lunch together!"
	DB	NEXT
	DB SINARIO,'CS402.OVL',0
	DW	0000H

M10:		;話す　恵依美
;	DB	'【清美】：どうかいたしましたの？'
	DB	"Kiyomi:  Did you try to talk to her?"
	DB	NEXT
;	DB	'【恵依美】：あの子、あたし達が話し掛けても一っ言もしゃべらないのよ！'
	DB	"Meimi:  I tried, but she wouldn't say a word!"
	DB	NEXT
;	DB	'【%001】：大勢に取り囲まれて、怯えてたんじゃねーの？'
	DB	"%001:  Maybe she was a bit overwhelmed, being surrounded"
	DB	CR
	DB	"like that?"
	DB	NEXT
;	DB	'【恵依美】：そんなんじゃないもん！',PAUSE
	DB	"Meimi:  No, that's not it!",PAUSE
;	DB	'・・・何か、人を見下したような、冷たい目だったわ。'
	DB	" She's cold, unfriendly. What"
	DB	CR
	DB	"a strange person."
	DB	NEXT
	T_CG1 "CT07",'W',0,0,4		;ＣＧ　
	DB	ANI,A_ON,3 
;	DB	'【星愛】：そんな事はありませんわ。'
	DB	"Seia:  That's not true."
	DB	NEXT
;	DB	'【恵依美】：何よ星愛、あの子の味方するつもり！？'
	DB	"Meimi:  What are you trying to defend her for, Seia?!"
	DB C_BLD,C_N_OFF,2,3	;話す　星愛
	DB	FLG,F_COPYI,5,1
	DW	0000H

M11:		;話す　恵依美
;	DB	'【恵依美】：・・・あの子、すっごく冷たい目してる。気味が悪い・・・'
	DB	"Meimi:  She seems really cold to me. It gives me the"
	DB	CR
	DB	"creeps..."
	DW	0000H


end
