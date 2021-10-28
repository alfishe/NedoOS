;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　７０１
;		鈴子の誕生３日前

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12
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
CM1:	DW	VV1,	NN2,NN3,NN4,NN5,NN6,NN1,-1
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,NN6,NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	"MAKOTO",0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	"REIKO",0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	"KIYOMI",0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	"MIO",0
;NN5:	DB	5,	'恵依美',0
NN5:	DB	5,	"MEIMI",0
;NN6:	DB	6,	'星愛',0
NN6:	DB	6,	"SEIA",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M2B		;見る　誠１
S2:		DW	VV1, NN2,  2, M3		;見る　鈴子１
S3:		DW	VV1, NN3,  3, M4		;見る　清美１
S4:		DW	VV1, NN4,  4, M5		;見る　美緒１
S5:		DW	VV1, NN5,  5, M6		;見る　恵依美１
S6:		DW	VV1, NN6,  6, M7		;見る　星愛１
S7:		DW	VV2, NN1,  7, M20, M21		;話す　誠２
S8:		DW	VV2, NN2,  8, M8, M9, M10		;話す　鈴子４
S9:		DW	VV2, NN3,  9, M12, M13		;話す　清美２
S10:	DW	VV2, NN4,  10, M14, M15		;話す　美緒２
S11:	DW	VV2, NN5,  11, M16, M17		;話す　恵依美２
S12:	DW	VV2, NN6,  12, M18, M19		;話す　星愛２


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT 'AB_36_1'					;背景ロード
;	DB	'【%001】：・・・ふぁ、ふぁ、ふぁ、・・・'
	DB	"%001:  ....*sniff*....*sniff*...."
	DB	NEXT
;	DB	'【%001】：ふぇーーーーーーっくしょん！！'
	DB	"%001:  *ACHOO!!*"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','S',0,0,2
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ................"
	DB	NEXT
;	DB	'【%001】：・・・ぐずっ・・・う゛～～～～～～・・・'
;	DB	"%001:  .....ugh.....agh...."
;	DB	NEXT
;	DB	'・・・まだまだ暑い９月。'
	DB	"It's September."
	DB	NEXT
;	DB	'臨海学校も終わり、ついでに始業式も済んで・・・',NEXT,'俺達の学校にも、'
	DB	"Seaside camp was over, and school had started again."
	DB	NEXT
	DB	"...But."
	DB	NEXT
;	DB	'【%001】：・・・へ～～～～～～っくしょい！'
	DB	"%001:  *ACHOO!!*"
	DB	NEXT
;	DB	'【清美】：・・・%001さん・・・大丈夫ですか？'
	DB	"Kiyomi:  %001, are you alright?"
	DB	NEXT
;	DB	'・・・そう。'
	DB	"Just like last year..."
	DB	NEXT
;	DB	'俺はど～やら、夏風邪もらって来ちまったらしい。'
	DB	"I always seem to catch a summer cold about now."
	DB	NEXT
;	DB	'【清美】：・・・はい、ティッシュですわ。'
	DB	"Kiyomi:  Here's a tissue."
	DB	NEXT
;	DB	'【%001】：・・・あ゛あ゛、ざん゛ぎゅ。'
	DB	"%001:  ...Ugh, ugh, thangks."
	DB	NEXT
	DB	ANI,A_OFF
	TU_CG 'CT03','S',0,12,3
	T_CG 'CT01','S',0,35,1
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【美緒】：%001先輩！こんにちは！'
	DB	"Mio:  %001! Hi!"
	DB	NEXT
;	DB	'【鈴子】：ハイ、%001君・・・元気？'
	DB	"Reiko:  Hi, %001, how are you?"
	DB	NEXT
;	DB	'【%001】：やあ、鈴子さんに美緒ちゃ・・・'
	DB	"%001:  Oh, Reiko, Mio..."
	DB	PAUSE
;	DB	'ぶぇっくしょい！'
	DB	" *KATCHOO*"
	DB	NEXT
;	DB	'【鈴子】：・・・じゃないみたいね、なんか。'
	DB	"Reiko:  .....Not too well, I take it."
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・大丈夫？'
	DB	"Mio:  %001, are you okay?"
	DB	NEXT
;	DB	'【%001】：あ゛、あ゛あ゛・・・'
	DB	"%001:  Ah, ah, ah..."
	DB	NEXT
;	DB	'ち～～～～～～ん！'
	DB	"CHOO!"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ..............................."
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DW	0000H

M2:		;見る　誠１
;	DB	'・・・親友の俺がお風邪を召してるってのに、ヘラヘラ笑ってる。'
	DB	"His best friend has a terrible cold, and he's just"
	DB	CR
	DB	"smirking about it."
	DB	NEXT
;	DB	'・・・友達甲斐の無いやつだ。'
	DB	"Some friend!"
	DW	0000H

M2B:		;見る　誠１
;	DB	'・・・こいつ・・・俺を一体なんだと思ってんだ？'
	DB	"What does he think I am, anyway?"
	DW	0000H

M3:		;見る　鈴子１
;	DB	'いつも通りの鈴子さんだ。'
	DB	"Reiko's the same as usual."
	DW	0000H

M4:		;見る　清美１
;	DB	'少し、心配そうな顔をしている。'
	DB	"She looks a little worried."
	DB	NEXT
;	DB	'・・・優しいんだな。'
	DB	"She's always so nice to me."
	DW	0000H

M5:		;見る　美緒１
;	DB	'いつも通り、元気いっぱいだ。'
	DB	"As always, full of energy."
	DW	0000H

M6:		;見る　恵依美１
;	DB	'・・・あいっ変わらず、小憎らしい奴だ。'
	DB	"Always a little bit spiteful."
	DW	0000H

M7:		;見る　星愛１
;	DB	'・・・まったく、この２人組は・・・'
	DB	"She's studying."

	DW	0000H

M20:		;話す　誠１
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,20,4
;	DB	'【誠】：しっかし、お前が風邪とはねぇ・・・'
	DB	"Makoto:  Do you really have a cold?"
	DB	NEXT
;	DB	'【%001】：・・・あのな、俺だって人間だぞ。たまには風邪くらいひくさ。'
	DB	"%001:  Well, yes, I'm only human. Even I catch cold every"
	DB	CR
	DB	"now and then."
	DB	NEXT
;	DB	'【誠】：ま、実際ひいてるところ見せられると信じざるをえないな。'
	DB	"Makoto:  Well, since you're showing all the symptoms, I"
	DB	CR
	DB	"guess I have to believe you."
	DB	PAUSE
;	DB	'意外だけど。'
	DB	" Even though it seems impossible."
	DB	NEXT
;	DB	'【%001】：・・・お前、俺を一体なんだと思ってたんだ？'
	DB	"%001:  What do you think I am anyway?"
	DB	NEXT
;	DB	'【誠】：聞きたいか？'
	DB	"Makoto:  You really want to know?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【%001】：いや、いい。'
	DB	"%001:  No, it's okay."
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,7,1
	DW	0000H

M21:		;話す　誠２
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,20,4
;	DB	'【誠】：どーでもい～けど、オレにだけは移すなよな。'
	DB	"Makoto:  No offense, but don't give that cold to me, okay?"
	DB	CR
	DB	"It looks bad."
	DB	NEXT
;	DB	'【%001】：・・・どーゆー意味だ、それは。'
	DB	"%001:  What's that supposed to mean?"
	DB	NEXT
;	DB	'【誠】：聞きたいか？'
	DB	"Makoto:  You really want to know?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................"
	DB	NEXT
;	DB	'【%001】：ど～せロクでもない事だろ～から、いい。'
	DB	"%001:  Since it's probably stupid anyway, never mind."
	DB	NEXT
;	DB	'【誠】：何だ、分ってるじゃないか。'
	DB	"Makoto:  What, don't you get it?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・
	DB	"%001:  ................................"
	EF_SET 101
	DW	0000H

M8:		;話す　鈴子１
	DB	BUF,B_COPY01
	T_CG 'CT01','S',0,35,1
;	DB	'【鈴子】：・・・もしかして、風邪なの？%001君。'
	DB	"Reiko:  Do you have a cold, %001?"
	DB	NEXT
;	DB	'【%001】：結核とかじゃあないとは思うけど。'
	DB	"%001:  Well, it's not tuberculosis."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  .........................."
	DB	FLG,F_COPYI,8,1
	DW	0000H

M9:		;話す　鈴子２
	DB	BUF,B_COPY01
	T_CG 'CT01','S',0,35,1
;	DB	'【鈴子】：・・・それはともかく。%001君、明々後日、ヒマ？'
	DB	"Reiko:  I suppose not."
	DB	NEXT
	DB	"Reiko:  By the way, %001, are you free three days from now?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、別に用はないけど？'
	DB	"%001:  Sure, I think so. Why?"
	DB	NEXT
;	DB	'【鈴子】：じゃあさ、私の家に来ない？・・・実は私、誕生日なんだ。'
	DB	"Reiko:  Would you come to my house? It's for my birthday",CR,"party."
	DB	NEXT
;	DB	'【%001】：へ～、そーなんだ。'
	DB	"%001:  Oh, really?"
	DB	NEXT
;	DB	'【鈴子】：いい？'
	DB	"Reiko:  Can you make it?"
	DB	NEXT
;	DB	'【%001】：もちろん、ＯＫだ。'
	DB	"%001:  Sure, that would be great."
	DB	NEXT
	K_CG 'CT01','K',35,5
;	DB	'【鈴子】：ありがとう。嬉しいわ。'
	DB	"Reiko:  Thanks. I'm glad."
	DB	NEXT
	T_CG1 'CT02','S',0,0,2
;	DB	'【清美】：・・・そうですか。３日後は鈴子さんのお誕生日なのですね・・・それでは、わたくしもお祝いさせて頂きますわ。'
	DB	"Kiyomi:  Is that right? It's your birthday in three"
	DB	CR
	DB	"days? I was wondering if I may attend as well."
	DB	NEXT
	T_CG1 'CT03','S',0,12,3
;	DB	'【美緒】：あたしも！・・・ねえねえ鈴子先輩、あたしも行っていいよね！？'
	DB	"Mio:  Me too! Please, Reiko? Can I come too?"
	DB	NEXT
;	DB	'【鈴子】：・・・もちろんよ。言うと思ってたから。'
	DB	"Reiko:  Of course. I was going to invite you, too."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT08','S',0,30,8
	T_CG 'CT07','S',0,10,7
	DB	ANI,A_ON,8
;	DB	'【恵依美】：じゃああたしも、行っていい？'
	DB	"Meimi:  May I come too?"
	DB	NEXT
;	DB	'【星愛】：もし良ければわたくしも、お祝いさせて頂きたいのですが。'
	DB	"Seia:  If it's all right with you, I would like to come"
	DB	CR
	DB	"as well."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,20,4
;	DB	'【誠】：鈴子さん・・・オレだけのけ者って事は、無いですよね？'
	DB	"Makoto:  Reiko, you're not going to leave me out, are "
	DB	CR
	DB	"you?"
	DB	NEXT
;	DB	'【鈴子】：・・・はいはい、みんなＯＫよ。沢山来てくれた方が'
;	DB	'嬉しいし。・・・ありがとね、みんな。'
	DB	"Reiko:  ...Of course, everyone's invited. You are too,"
	DB	CR
	DB	"Makoto. Thanks, everybody. I'm glad you can come."
	DB	NEXT
;	DB	'【誠】：いやいや、当然ですよ。ナハハハハ・・・・・・'
	DB	"Makoto:  Oh, think nothing of it. Hahahaha..."
	DB	FLG,F_COPYI,8,2
	DW	0000H

M10:		;話す　鈴子３
	DB	BUF,B_COPY01
	T_CG 'CT01','S',0,35,1
;	DB	'【鈴子】：%001君、大丈夫？'
	DB	"Reiko:  Are you okay, %001?"
	DB	NEXT
;	DB	'【%001】：ああ、別にど～って事・・・'
	DB	"%001:  Sure, why do you ask?"
	DB	PAUSE
;	DB	'ぶぇっくしょい！'
	DB	" *ATCHOO*"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ......................"
	EF_SET 102
	DW	0000H


M12:		;話す　清美１
	DB	BUF,B_COPY01
	T_CG 'CT02','S',0,0,2
;	DB	'【清美】：%001さん・・・大丈夫なのですか？'
	DB	"Kiyomi:  %001, are you all right?"
	DB	NEXT
;	DB	'【%001】：ああ、別にど～って事は・・・'
	DB	"%001:  Sure, why do you ask?"
	DB	PAUSE
;	DB	'へっくしょい！'
	DB	" *HATCHOO*"
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ........................."
	DB	FLG,F_COPYI,9,1
	DW	0000H

M13:		;話す　清美２
	DB	BUF,B_COPY01
	T_CG 'CT02','S',0,0,2
;	DB	'【清美】：%001さん・・・風邪は早めが肝心ですよ。'
	DB	"Kiyomi:  %001, did you catch a cold?"
	DB	NEXT
;	DB	'【%001】：ああ、そ～らしいな。'
	DB	"%001:  Yeah, looks like it."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ........................"

	EF_SET 103
	DW	0000H

M14:		;話す　美緒１
	DB	BUF,B_COPY01
	T_CG 'CT03','S',0,12,3
;	DB	'【美緒】：%001先輩・・・大丈夫？'
	DB	"Mio:  %001, are you all right?"
	DB	NEXT
;	DB	'【%001】：ああ、別にど～って事は・・・'
	DB	"%001:  Sure, why do you ask?"
	DB	PAUSE
;	DB	'へっくしょい！'
	DB	" *HATCHOO!*"
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  ......."
	DB	FLG,F_COPYI,10,1
	DW	0000H

M15:		;話す　美緒２
	DB	BUF,B_COPY01
	T_CG 'CT03','S',0,12,3
;	DB	'【美緒】：%001先輩・・・ホントに大丈夫？'
	DB	"Mio:  %001, are you really okay?"
	DB	NEXT
;	DB	'【%001】：ああ・・・別に死にゃせんだろ。'
	DB	"%001:  Yeah, I'm not going to die or anything."
	DB	NEXT
;	DB	'【美緒】：でも・・・・・・'
	DB	"Mio:  But..."
	DB	NEXT
;	DB	'【%001】：だ～いじょ～ぶだって。'
	DB	"%001:  I'm fine."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  ........................."
	EF_SET 104
	DW	0000H

M16:		;話す　恵依美１
	DB	BUF,B_COPY01
	T_CG 'CT08','S',0,30,8
;	DB	'【恵依美】：・・・へ～、%001でも風邪ひくんだぁ。'
	DB	"Meimi:  So, even the mighty %001 catches a cold sometimes."
	DB	NEXT
;	DB	'【%001】：・・・どーゆー意味だそりゃ。'
	DB	"%001:  What do you mean by that?"
	DB	NEXT
;	DB	'【恵依美】：言ったまんまの意味よ。'
	DB	"Meimi:  Just what I said."
	DB	NEXT
;	DB	'【%001】：・・・お前にだけは言われたくないぞ。'
	DB	"%001:  Well, I don't want to hear it from you, all right?."
	DB	NEXT
	K_CG 'CT08','D',30,6
;	DB	'【恵依美】：なぁんですってぇ！'
	DB	"Meimi:  Hey!"
	DB	FLG,F_COPYI,11,1
	DW	0000H

M17:		;話す　恵依美２
	DB	BUF,B_COPY01
	T_CG 'CT08','S','D',30,6
;	DB	'【恵依美】：・・・%001と一緒にしないでよね、失礼しちゃうわ。'
	DB	"Meimi:  Just watch it, Yamagami."
	DB	NEXT
;	DB	'【誠】：失礼、ねぇ・・・・・・'
	DB	"Makoto:  What a rude person."
	DB	NEXT
;	DB	'【恵依美】：・・・なんか言った？'
	DB	"Meimi:  Did you say something?"
	DB	NEXT
;	DB	'【誠】：いや、別に。'
	DB	"Makoto:  Who me? Nothing, nothing at all."
	EF_SET 105
	DW	0000H

M18:		;話す　星愛１
	DB	BUF,B_COPY01
	T_CG 'CT07','S',0,10,7
;	DB	'【星愛】：お風邪ですか？'
	DB	"Seia:  Are you sick?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、多分な。'
	DB	"%001:  Yeah, I guess so."
	DB	NEXT
;	DB	'【星愛】：まあ・・・何と言う事でしょう。'
	DB	"Seia:  Lord, please help this sick sheep."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .................................."
	DB	NEXT
;	DB	'【%001】：なんか、そこはかとなくバカにされてるよ～な気がするんだが。'
	DB	"%001:  Why is it that I feel like you're making fun of me?"
	DB	NEXT
;	DB	'【星愛】：そんな事はありませんわ。'
	DB	"Seia:  I am most certainly not."
	DB	FLG,F_COPYI,12,1
	DW	0000H

M19:		;話す　星愛２
	DB	BUF,B_COPY01
	T_CG 'CT07','S',0,10,7
;	DB	'【星愛】：とにかく、早く直して下さいね。学級閉鎖になったら大変ですから。'
	DB	"Seia:  Anyway, get well soon. It would be bad if they had"
	DB	CR
	DB	"to quarantine our class."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............................."
	DB	NEXT
;	DB	'【%001】：二日酔いで学級閉鎖になるより１００倍マトモだと思うんだが。'
	DB	"%001:  I think it's a hundred times more likely that the"
	DB	CR
	DB	"class gets quarantined for having a hangover."
	DB	NEXT
;	DB	'【星愛】：信じてもらえないかも知れませんわよ。'
	DB	"Seia:  You don't seem to believe me."
	DB	NEXT
;	DB	'【%001】：・・・・・・ごもっとも。'
	DB	"%001:  Not in the least."
	EF_SET 106
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,7,255,101,102,103,104,105,106
	DB FLG,F_EXIT,255
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','S',0,12,3
	T_CG 'CT01','S',0,35,1
	DB	ANI,A_ON,3
;	DB	'【鈴子】：あのね、%001君・・・'
	DB	"Reiko:  Oh, %001..."
	DB	NEXT
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*!"
	DB	NEXT
;	DB	'【%001】：・・・あ、予鈴だ。'
	DB	"%001:  Oh, there's the bell."
	DB	NEXT
;	DB	'【鈴子】：・・・じゃあ%001君、またね！'
	DB	"Reiko:  Well, see you later, %001!"
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・又明日、来るから。'
	DB	"Mio:  %001, I'll see you again tomorrow, okay?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Okay."
	DB	PAUSE
;	DB	'へっくしょい！'
	DB	" *KATCHOO*"
	DB	NEXT
	B_O B_NORM
	E_CG B_YOKO,'T_07'
	DB	NEXT
	DB	SINARIO,'CS702.OVL',0
	DW	0000H

end
