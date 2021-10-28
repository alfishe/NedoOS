;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　７０５
;		鈴子の誕生前日　自宅への道

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,NN8,-1

;VV1:	DB	1,	'話す',0
VV1:	DB	1,	"TALK",0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	"MAKOTO",0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	"REIKO",0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	"KIYOMI",0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	"MIO",0
;NN5:	DB	5,	'星愛',0
NN5:	DB	5,	"SEIA",0
;NN6:	DB	6,	'恵依美',0
NN6:	DB	6,	"MEIMI",0
;NN7:	DB	7,	'伸幸',0
NN7:	DB	7,	"NOBUYUKI",0
;NN8:	DB	8,	'英美',0
NN8:	DB	8,	"HIDEMI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;話す　誠１
S2:		DW	VV1, NN2,  2, M3		;話す　鈴子１
S3:		DW	VV1, NN3,  3, M4		;話す　清美１
S4:		DW	VV1, NN4,  4, M5		;話す　美緒１
S5:		DW	VV1, NN5,  5, M6		;話す　星愛１
S6:		DW	VV1, NN6,  6, M7		;話す　恵依美１
S7:		DW	VV1, NN7,  7, M8, M9		;話す　伸幸２
S8:		DW	VV1, NN8,  8, M10, M11		;話す　英美２


;イニシャルメッセージ
M1:
	DB	BGM,6
;	DB	'・・・・・・'
	DB	"....."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"............."
	DB	NEXT
;	DB	'・・・・・・・・・・・・'
	DB	"................."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"..........................."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・'
	DB	"............................................"
;	DB	'・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・'
	DB	"............................................"
;	DB	'・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・'
	DB	"............................................"
	DB	NEXT
	E_CG B_FADE,'AB_42'
;	DB	'【%001】：・・・・・・うーん・・・・・・'
	DB	"%001:  .......Hmmm..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......."
	DB	NEXT
;	DB	'【%001】：今、何時だ？'
	DB	"%001:  What time is it?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......."
	DB	NEXT
;	DB	'【%001】：げ、もう下校時間じゃね～か。'
	DB	"%001:  What? Is it already time for school to let out?" 
	DB	NEXT
;	DB	'【%001】：・・・帰らなきゃ。'
	DB	"%001:  .....I better go back."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"......................."
	DB	NEXT
	BAK_INIT 'AB_36_1'
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,37,4
;	DB	'【誠】：・・・よう、%001。もういいのか？'
	DB	"Makoto:  Hey, %001. How's it going?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、だいぶマシになった。'
	DB	"%001:  Good, I feel much better."
	DB	NEXT
;	DB	'【誠】：・・・そうかぁ？'
	DB	"Makoto:  Really?"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','S','I',10,3
	TU_CG 'CT02','S','I',0,2
	T_CG 'CT01','S','I',35,1
	DB	ANI,A_ON,3
	DB	ANI,A_ON,2
;	DB	'【鈴子】：・・・%001君！？',CR
	DB	"Reiko:  %001?!",CR 
;	DB	'【美緒】：・・・%001先輩！？'
	DB	"Mio:  %001?!"
	DB	NEXT
;	DB	'【%001】：・・・よ。'
	DB	"%001:  Hi."
	DB	NEXT
;	DB	'【鈴子】：『よ。』じゃないでしょ！？授業中に倒れたんですって！？'
	DB	"Reiko:  What do you mean, 'Hi'? I heard you collapsed in"
	DB	CR
	DB	"the middle of class!"
	DB	NEXT
;	DB	'【美緒】：それであたし達、保健室に行ったんだけど・・・誰もいなくて、'
	DB	"Mio:  So then we went over to the nurse's office, but"
	DB	CR
	DB	"there was nobody there, so we rushed over here to see"
	DB	CR
	DB	"what was going on."
	DB	NEXT
;	DB	'【%001】：・・・そか。きっと行き違いになったんだな。'
	DB	"%001:  Oh. We must have just missed each other."
	DB	NEXT
;	DB	'【鈴子】：そんな事より！大丈夫なの身体！？'
	DB	"Reiko:  So what?! What's more important is how you're"
	DB	CR
	DB	"feeling!"
	DB	NEXT
;	DB	'【%001】：・・・ああ、思いっきり寝たからな。'
	DB	"%001:  I'm feeling better. I slept a really long time."
	DB	NEXT
;	DB	'【美緒】：でも%001先輩・・・・・・まだ顔色悪いみたい・・・・・・'
	DB	"Mio:  But %001, you're still kind of flushed."
	DB	NEXT
;	DB	'【%001】：気のせいだよ。'
	DB	"%001:  Ah, it's nothing."
	DB	NEXT
;	DB	'【美緒】：・・・でも・・・'
	DB	"Mio:  But...."
	DB	NEXT
;	DB	'【%001】：・・・大丈夫だって・・・それより、もう下校時間だぜ？'
	DB	"%001:  I said I'm fine... Is school over?"
	DB	NEXT
;	DB	'【清美】：それはそうなのですが・・・・・・大丈夫なのですか？'
	DB	"Kiyomi:  That's right, but, are you all right?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、平気さ。'
	DB	"%001:  Hey, I'm fine."
	DB	PAUSE
;	DB	'・・・鞄は・・・'
	DB	" Where's my bag?"
	DB	NEXT
;	DB	'【清美】：はい。これですわ。'
	DB	"Kiyomi:  Here. There you go."
	DB	NEXT
;	DB	'【%001】：・・・ああ、さんきゅ。'
	DB	"%001:  Oh, thanks."
	DB	PAUSE
;	DB	'・・・んじゃな。又明日・・・'
	DB	" Well, see you tomorrow..."
	DB	NEXT
	DB	GATA,1
	DB	" *CRASH*"
	DB	NEXT
;	DB	'【%001】：・・・っと。'
	DB	"%001:  .......Ugh."
	DB	NEXT
;	DB	'【鈴子】：%001君！！'
	DB	"Reiko:  %001!!"
	DB	CR
;	DB	'【清美】：%001さん！！'
	DB	"Kiyomi:  %001!!"
	DB	CR
;	DB	'【美緒】：%001先輩！！'
	DB	"Mio:  %001!!"
	DB	NEXT
;	DB	'【%001】：・・・・・・あれ？'
	DB	"%001:  .........Huh?"
	DB	NEXT
;	DB	'【鈴子】：『あれ？』じゃないわよホントにもう！！'
	DB	"Reiko:  Okay, this is getting ridiculous!"
	DB	NEXT
;	DB	'【清美】：%001さん、しっかりなさって！'
	DB	"Kiyomi:  %001, pull yourself together!"
	DB	NEXT
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【%001】：・・・・・・大丈夫。ちょっとつまずいただけさ。'
	DB	"%001:  It's okay. I just tripped, that's all."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ...................."
	DB	NEXT
;	DB	'【鈴子】：清美ちゃん、%001君の家知ってる？'
	DB	"Reiko:  Kiyomi, do you know where %001's house is?"
	DB	NEXT
;	DB	'【清美】：いえ、存じませんが・・・・・・'
	DB	"Kiyomi:  No, I don't....."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT14','S',0,37,4
	TU_CG 'CT08','S',0,0,8
	T_CG 'CT07','S',0,23,7
	DB	ANI,A_ON,8
	DB	ANI,A_ON,4
;	DB	'【誠】：%001の家なら、知ってるけどオレ。'
	DB	"Makoto:  I know where his house is."
	DB	NEXT
;	DB	'【鈴子】：そう。じゃあ悪いんだけど、案内してくれる？'
	DB	"Reiko:  Would you show us? I don't think he'll make it"
	DB	CR
	DB	"home alone in his condition."
	DB	NEXT
;	DB	'【恵依美】：・・・家どころか、校門辺りで倒れちゃうんじゃない？'
	DB	"Meimi:  I don't think he'll make it out of the school,"
	DB	CR
	DB	"much less to his house."
	DB	NEXT
;	DB	'【誠】：わっかりました。ご案内いたしましょう。'
	DB	"Makoto:  Understood. We will escort you home, sir."
	DB	NEXT
;	DB	'【%001】：・・・お、おい・・・'
	DB	"%001:  H- Hey....."
	DB	NEXT
;	DB	'【一同】：病人は、大人しくしてなさい！！'
	DB	"All:  You're sick. Behave yourself!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・はい・・・・・・・・・'
	DB	"%001:  Okay..."
	DB	NEXT
	B_O B_FADE
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"........................"
	DB	NEXT
	DB	BGM,17
	BAK_INIT 'AB_15'
	B_P1 B_WIPE
;	DB	'【誠】：・・・ここがそうですぜ、鈴子さん。'
	DB	"Makoto:  This is it, Reiko."
	DB	NEXT
;	DB	'【鈴子】：へ～、電気屋さんなのね。'
	DB	"Reiko:  Oh, it's an electronics store."
	DB	NEXT
;	DB	'【美緒】：・・・ごめんくださーい！'
	DB	"Mio:  Hello!"
	DB	NEXT
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG 'CT09',0,0,0,5
;	DB	'【伸幸】：はい、いらっしゃい。'
	DB	"Nobuyuki:  Hello, come in."
	DB	PAUSE
;	DB	'・・・ん？%001？一体何をやっとるんだ？'
	DB	" %001? What the heck are you",CR,"doing?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	NEXT
;	DB	'【清美】：実は・・・かくかくしかじか。'
	DB	"Kiyomi:  Actually..... (explain explain)"
	DB	NEXT
;	DB	'【伸幸】：・・・ふむふむ・・・なるほど良くわかった。'
	DB	"Nobuyuki:  ....Oh, now I understand."
	DB	NEXT
;	DB	'【伸幸】：つまり%001は、お嬢さん達を一辺に相手しようとして、'
	DB	"Nobuyuki:  So basically %001, in trying to get all you"
	DB	CR
	DB	"women to fall in love with him, has used up all his"
	DB	CR
	DB	"strength."
	DB	NEXT
;	DB	'【清美】：・・・あの・・・少々違うのですが・・・'
	DB	"Kiyomi:  Well, not really."
	DB	NEXT
;	DB	'【%001】：・・・・・・お～や～じ～・・・・・・'
	DB	"%001:  Dad....."
	DB	NEXT
;	DB	'【伸幸】：%001・・・お前は確かに若いが、ムチャはいかんぞ。'
	DB	"Nobuyuki:  %001, I know you're inexperienced, but you"
	DB	CR
	DB	"still  shouldn't be so reckless."
	DB	NEXT
;	DB	'【伸幸】：まぁ過ぎた事を言ってても仕方がないからな・・・・・・'
	DB	"Nobuyuki:  Well, I know you probably won't listen to me"
	DB	CR
	DB	"anyway, but... Next time make sure you call me."
	DB	NEXT
;	DB	'【伸幸】：ちゃ～んと、手取り足取りレクチャーしてやるからな。'
	DB	"Nobuyuki:  I'll show you how to go about it the right"
	DB	CR
	DB	"way."
	DB	NEXT
;	DB	'【%001】：・・・・・・親父・・・・・・頼むから止めてくれ・・・・・・'
	DB	"%001:  Dad, will you please stop it...?"
	DB	NEXT
	T_CG1 'CT10',0,0,40,6
	DB ANI,A_ON,5
;	DB	'【英美】：・・・あら！？'
	DB	"Meimi:  What's this?!"
	DB	NEXT
;	DB	'【英美】：あらあらあらあらあらあらあらあらあらあらあらあらあら！'
	DB	"Hidemi:  What.....is.......this!"
	DB	NEXT
;	DB	'【英美】：しゅ～ちゃん！誰なのその娘達！？'
	DB	"Hidemi:  Shu-chan! Who are all these women?"
	DB	NEXT
;	DB	'【伸幸】：%001のステディだそうだ。'
	DB	"Nobuyuki:  Apparently these are all his girlfriends."
	DB	NEXT
;	DB	'【英美】：・・・・・・'
	DB	"Hidemi:  ............................"
	DB	NEXT
;	DB	'【英美】：んまーーーーーーーーーーーーーーーーっ！！'
	DB	"Hidemi:  Waaaaah!!"
	DB	NEXT
;	DB	'【英美】：ひどいわしゅうちゃん、英美、とってもとってもかなし～。'
	DB	"Hidemi:  How mean of you, Shu-chan, you've made Mommy very"
	DB	CR
	DB	"sad."
	DB	NEXT
;	DB	'【伸幸】：まあまあ母さん、%001だって成長してるんだ。'
	DB	"Nobuyuki:  Well now, dear, %001 is growing up. It's very"
	DB	CR
	DB	"promising that he can get all these women to go out with"
	DB	CR
	DB	"him at once."
	DB	NEXT
;	DB	'【英美】：でもでもぉ、英美のしゅうちゃん他の子に取られたくな～い。'
	DB	"Hidemi:  But, I don't want anyone else to take my little"
	DB	CR
	DB	"Shu-chan away."
	DB	NEXT
;	DB	'【伸幸】：気持ちは分かるがな母さん・・・・・・'
	DB	"Nobuyuki:  I understand how you feel, but...."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・頼む・・・・・・・・・・'
	DB	"%001:  Please...."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・誰でもいい・・・・・・・・'
	DB	"%001:  Somebody...."
	DB	NEXT
;	DB	'【%001】：・・・俺をこっから、救い出してくれぇ・・・'
	DB	"%001:  Get me out of here..."
	DB	NEXT
	DB	GATA,2
	B_O B_NORM
;	DB	'がくっ。'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'【鈴子】：きゃあ%001君！？'
	DB	"Reiko:  %001, careful!"
	DB	NEXT
;	DB	'【清美】：と、とにかく早くベッドへ！'
	DB	"Kiyomi:  ....Anyway, straight to bed!"
	DB	NEXT
;	DB	'【誠】：こっちだ！'
	DB	"Makoto:  His room's upstairs!"
	DB	NEXT
;	DB	'どたばたどたばた'
;	DB	NEXT
;	DB	'【伸幸】：母さん・・・男の子なんてものはな、何時かは巣立って行ってしまうんだよ。'
	DB	"Nobuyuki:  Dear, all boys will have to leave the nest"
	DB	CR
	DB	"someday...."
	DB	NEXT
;	DB	'【英美】：でもでもぉ・・・・・・'
	DB	"Hidemi:  But, but...."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"..............................."
	DB	NEXT
	BAK_INIT 'AB_38_1'
	DB	BUF,B_COPY01
	TU_CG 'CT03','S',0,10,3
	TU_CG 'CT02','S',0,0,2
	T_CG 'CT01','S',0,35,1
	DB	ANI,A_ON,3
	DB	ANI,A_ON,2
;	DB	'【鈴子】：・・・ふう。これでよし、と。'
	DB	"Reiko:  Phew. That's it, I guess."
	DB	NEXT
;	DB	'【清美】：何とか、落ち着きましたわね。'
	DB	"Kiyomi:  Yes, he seems to have calmed down."
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・大丈夫？'
	DB	"Mio:  %001....are you alright?"
	DB	NEXT
;	DB	'【%001】：・・・ああ・・・何とか。'
	DB	"%001:  Yeah, pretty much."
	DW	0000H

M2:		;話す　誠１
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,0,4
;	DB	'【%001】：・・・誠・・・悪りィ。'
	DB	"%001:  Makoto...thanks for helping me out."
	DB	NEXT
;	DB	'【誠】：ま～ったく、いい迷惑だぜ。'
	DB	"Makoto:  Yeah, you're a pain in the butt."
	DB	NEXT
	T_CG 'CT01','S',0,35,1
	DB	ANI,A_ON,4
;	DB	'【鈴子】：ごめんなさいね。付き合わせちゃって・・・'
	DB	"Reiko:  Sorry for making you help us."
	DB	NEXT
;	DB	'【誠】：・・・い～んですよぉ鈴子さん。このくらい、お安い御用なんですから！'
	DB	"Makoto:  No problem, Reiko. In fact, it was rather a"
	DB	CR
	DB	"pleasure!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........................."
	EF_SET 101
	DW	0000H

M3:		;話す　鈴子１
	DB	BUF,B_COPY01
	T_CG 'CT01','S',0,35,1
;	DB	'【%001】：・・・鈴子さん・・・悪りィ。'
	DB	"%001:  Reiko, thanks for taking me home."
	DB	NEXT
;	DB	'【鈴子】：な～に言ってんの。このくらい、どうって事ないわ。'
	DB	"Reiko:  Oh, hush. It was no nothing at all."
	EF_SET 102
	DW	0000H

M4:		;話す　清美１
	DB	BUF,B_COPY01
	T_CG 'CT02','S',0,0,2
;	DB	'【%001】：・・・新藤さん・・・悪りィ。'
	DB	"%001:  Kiyomi, thanks for helping me."
	DB	NEXT
;	DB	'【清美】：いいえ、当然の事をしただけですわ。'
	DB	"Kiyomi:  Don't be silly, it was the obvious thing to do."	
	EF_SET 103
	DW	0000H

M5:		;話す　美緒１
	DB	BUF,B_COPY01
	T_CG 'CT03','S',0,10,3
;	DB	'【%001】：・・・美緒ちゃん・・・悪りィ。'
	DB	"%001:  Mio, thanks for helping me out."
	DB	NEXT
;	DB	'【美緒】：ううん・・・%001先輩、大丈夫？'
	DB	"Mio:  Mmhm.....%001, are you sure you're okay?"
	DB	NEXT
;	DB	'【%001】：・・・ああ・・・'
	DB	"%001:  Sure."
	EF_SET 104
	DW	0000H

M6:		;話す　星愛１
	DB	BUF,B_COPY01
	T_CG 'CT07','S',0,23,7
;	DB	'【%001】：・・・吉田・・・悪りィ。'
	DB	"%001:  Seia, thanks."
	DB	NEXT
;	DB	'【星愛】：いいえ、困っている人をお助けする事は、主のご意志に'
	DB	"Seia:  It is God's will that we should help people in need."
	EF_SET 105
	DW	0000H

M7:		;話す　恵依美１
	DB	BUF,B_COPY01
	T_CG 'CT08','S',0,30,8
;	DB	'【%001】：・・・中野・・・悪りィ。'
	DB	"%001:  Thanks for helping me get back, Meimi."
	DB	NEXT
;	DB	'【恵依美】：まったく・・・だ～から言わんこっちゃないのよ。'
	DB	"Meimi:  Well, don't worry about it, okay?"
;	DB	NEXT
;	DB	'【%001】：・・・悪り・・・'
;	DB	"%001:  Sorry."
	EF_SET 106
	DW	0000H

M8:		;話す　伸幸１
;	DB	'【%001】：・・・親父は・・・？'
	DB	"%001:  Where's my father?"
	DB	NEXT
;	DB	'【誠】：下だと思うぜ？呼んでこようか？'
	DB	"Makoto:  I think he's downstairs. You want me to get him?"
	DB	NEXT
;	DB	'【%001】：いや・・・それだけは止めてくれ・・・'
	DB	"%001:  No, anything but that...."
	DB	NEXT
;	DB	'【鈴子】：初めて会ったけど・・・%001君のお父様って・・・'
	DB	"Reiko:  I've never met your Dad before, but he's kind"
	DB	CR
	DB	"of..."
	DB	NEXT
;	DB	'【%001】：・・・鈴子さん・・・お願いだからその先は言わないで・・・'
	DB	"%001:  Please, Reiko, don't finish that sentence."
	DB	NEXT
;	DB	'【鈴子】：・・・うん。わかったわ。'
	DB	"Reiko:  Sure, okay."
	DB	FLG,F_COPYI,7,1
	EF_SET 107
	DW	0000H

M9:		;話す　伸幸２
;	DB	'・・・・・・'
	DB	"......................."
	DB	NEXT
;	DB	'嫌だ。これ以上、恥をさらしたくない・・・・・・'
	DB	"Nevermind. I don't want to expose myself to any more"
	DB	CR
	DB	"embarrassment."
	DW	0000H

M10:		;話す　英美１
;	DB	'【%001】：・・・かーちゃんは・・・？'
	DB	"%001:  Where's my mother?"
	DB	NEXT
;	DB	'【誠】：下だと思うぜ？呼んでこようか？'
	DB	"Makoto:  I think she's downstairs. You want me to get"
	DB	CR
	DB	"her?"
	DB	NEXT
;	DB	'【%001】：いや・・・それだけは止めてくれ・・・'
	DB	"%001:  No, please!"
	DB	NEXT
;	DB	'【鈴子】：初めて会ったけど・・・%001君のお母様って・・・'
	DB	"Reiko:  I've never met your Mom before...but..."
	DB	NEXT
;	DB	'【清美】：とっても楽しそうな方ですね。'
	DB	"Kiyomi:  I thought she was really nice."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ................"
	DB	NEXT
;	DB	'【恵依美】：・・・清美・・・あんたのセンスって一体・・・？'
	DB	"Meimi:  Kiyomi, I really wonder about you sometimes...."
	DB	FLG,F_COPYI,8,1
	EF_SET 108
	DW	0000H

M11:		;話す　英美２
;	DB	'・・・・・・'
	DB	".........................................."
	DB	NEXT
;	DB	'嫌だ。これ以上、恥をさらしたくない・・・・・・'
	DB	"Nevermind. She's not here."
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,9,255,101,102,103,104,105,106,107,108
	DB	FLG,F_EXIT,255
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','S',0,10,3
	TU_CG 'CT02','S',0,0,2
	T_CG 'CT01','S',0,35,1
	DB	ANI,A_ON,3
	DB	ANI,A_ON,2
;	DB	'【鈴子】：・・・じゃあ%001君。私達はそろそろ帰るけど・・・'
	DB	"Reiko:  .....Well, %001. We better get going. Make sure"
	DB	CR
	DB	"you get enough sleep."
	DB	NEXT
;	DB	'【清美】：先生から貰ったお薬、ここに置いておきます。'
	DB	"Kiyomi:  I'll put the medicine we got from the nurse"
	DB	CR
	DB	"right here. Don't forget to take it."
	DB	NEXT
;	DB	'【美緒】：先輩・・・お大事に。'
	DB	"Mio:  Take care, %001."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT14','S',0,37,4
	TU_CG 'CT08','S',0,0,8
	T_CG 'CT07','S',0,23,7
	DB	ANI,A_ON,8
	DB	ANI,A_ON,4
;	DB	'【恵依美】：ちゃんと薬飲むのよ！'
	DB	"Meimi:  Make sure you take that medicine!"
	DB	NEXT
;	DB	'【星愛】：大丈夫ですわ恵依美ちゃん。ちゃんと、御両親に言付けしておきますもの。'
	DB	"Seia:  Don't worry, Meimi. I'll tell his parents to take"
	DB	CR
	DB	"care of it."
	DB	NEXT
;	DB	'【誠】：じゃあな！%001！'
	DB	"Makoto:  See ya, %001!"
	DB	NEXT
;	DB	'【%001】：・・・・・・ああ。ありがとな、みんな・・・・・・'
	DB	"%001:  Yeah. Thanks, everybody....."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"........................................"
	DB	NEXT
	B_O B_SUDA
;	DB	'【鈴子】：・・・あ～あ・・・明日、私の誕生日なんだけどな・・・'
	DB	"Reiko:  ...Oh, it's my birthday tomorrow, you know. I'm"
	DB	CR
	DB	"going to be twenty-three."
	DB	NEXT
;	DB	'【清美】：・・・この際ですから・・・修司さんの家でやるというのはどうでしょう？'
	DB	"Kiyomi:  ......Well, how would it be if we had the party"
	DB	CR
	DB	"at %001's house?"
	DB	NEXT
;	DB	'【恵依美】：あ、それいい！'
	DB	"Meimi:  Sounds good!"
	DB	NEXT
;	DB	'【美緒】：賛成！'
	DB	"Mio:  Great!"
	DB	NEXT
;	DB	'【誠】：異議なし！'
	DB	"Makoto:  Sure!"
	DB	NEXT
;	DB	'【鈴子】：・・・でも、迷惑なんじゃない？'
	DB	"Reiko:  ...Are you sure it's okay?"
	DB	NEXT
;	DB	'【誠】：だいじょ～ぶ。あいつン家、みんなお祭り好きだから'
	DB	"Makoto:  Sure. His family loves parties."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・そう？ならいいんだけど・・・・・・'
	DB	"Reiko:  Really? Well, if you think so...."
	DB	NEXT
;	DB	'【星愛】：では、決まりですわね。では、段取りを决めましょう。'
	DB	"Seia:  Okay, let's do that. Why don't we start organizing?"
	DB	NEXT
;	DB	'【清美】：準備は、わたくしの家でした方が良いと思いますわ。'
	DB	"Kiyomi:  Why don't we prepare at my house? Shinji will"
	DB	CR
	DB	"be there too, and the kitchen is pretty big."
	DB	NEXT
;	DB	'【美緒】：じゃあ、あたしは・・・・・・'
	DB	"Mio:  Well, I....."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"..................................."
	DB	NEXT
	DB	SINARIO,'CS706.OVL',0
	DW	0000H


end
