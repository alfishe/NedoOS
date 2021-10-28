;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　３０２
;		３人娘
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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,NN6,-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"話す",0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	"桜",0
NN1:	DB	1,	"SAKURA",0
;NN2:	DB	2,	"誠",0
NN2:	DB	2,	"MAKOTO",0
;NN3:	DB	3,	"鈴子",0
NN3:	DB	3,	"REIKO",0
;NN4:	DB	4,	"清美",0
NN4:	DB	4,	"KIYOMI",0
;NN5:	DB	5,	"美緒",0
NN5:	DB	5,	"MIO",0
;NN6:	DB	6,	"今日子",0
NN6:	DB	6,	"KYOKO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　桜
S2:		DW	VV2, NN2,  2, M5, M6		;話す　誠
S3:		DW	VV2, NN3,  3, M7, M8		;話す　鈴子
S4:		DW	VV2, NN4,  4, M9, M10		;話す　清美
S5:		DW	VV2, NN5,  5, M11, M12, M13		;話す　美緒
S6:		DW	VV2, NN6,  6, M14, M15		;話す　今日子


;イニシャルメッセージ
M1:
	DB	BGM,32
	BAK_INIT "AB_07_2"
	DB	BUF,B_COPY01
	TU_CG "CT01","C",0,35,2
	TU_CG "CT03","C",0,10,1
	T_CG "CT02","C",0,0,3
	DB	ANI,A_ON,1
	DB	ANI,A_ON,2
;	DB	"【%001】：あ、新藤さん？"
	DB	"%001:  Wow, what are you all doing here?"
	DB	NEXT
;	DB	"【清美】：寒い中、ご苦労様ですわ。"
	DB	"Kiyomi:  You must be cold out here."
	DB	NEXT
;	DB	"【鈴子】：こんばんわぁ。"
	DB	"Reiko:  Hi."
	DB	NEXT
;	DB	"【美緒】：差し入れ持って来たよ！"
	DB	"Mio:  We brought some more food!"
	DB	NEXT
;	DB	"【%001】：あれ？・・・新藤さんはともかく、何で鈴子さんと美緒ちゃんが？"
	DB	"%001:  Huh? I understand why Kiyomi is here, since she "
	DB	CR
	DB	"volunteered to help us find a spot, but Reiko and Mio too?"
	DB	NEXT
;	DB	"【鈴子】：清美ちゃんに誘ってもらったんだけど・・・やっぱり迷惑だったかしら・・・？"
	DB	"Reiko:  We had Kiyomi bring us along. Are we in the"
	DB	CR
	DB	"way?"
	DB	NEXT
;	DB	"【今日子】：そんなことぜ～んぜんないわ、宴会は人が多い方が楽しいでしょ！二人とも楽しんでってね。"
	DB	"Kyoko:  Not, of course not. Sit down."
	DB	NEXT
;	DB	"【%001】：それもそーか。"
	DB	"%001:  Kyoko-sensei even brought some sake..."
	DB	NEXT
;	DB	"【今日子】：それじゃ早速いただきますか。"
	DB	"Kyoko:  Let's see what you brought."
	DB	NEXT
;	DB	"鈴子さん達の持参して来た重箱を開ける今日子先生。"
	DB	"Kyoko opened the box that the girls brought."
	DB	NEXT
;	DB	"【今日子】：わぉ☆"
	DB	"Kyoko:  Wow!"
	DB	NEXT
;	DB	"中には鳥の唐揚げ、玉子焼き、ソーセージ、肉じゃが、ちくわの磯辺揚げ、ナスのベーコン挟み焼き、ポテトサラダ、そしておにぎりなど、けっこー豪勢な御馳走が詰まっていた。"
	DB	"There was a veritable feast in the box with fried chicken,"
	DB	CR
	DB	"eggs, sausage, potatoes, fish sticks, eggplant with bacon,"
	DB	CR
	DB	"potato salad, and onigiri rice triangles." 
	DW	0000H

M2:		;見る　桜
;	DB	"夜見る桜は、何か無気味な美しさがある。"
	DB	"The evening sakura are hauntingly beautiful."
	DB	NEXT
;	DB	"植物も生き物だって実感するのは、こんな時だ。"
	DB	"It makes you feel like plants really are living beings,"
	DB	CR
	DB	"capable of thought."
	DB	NEXT
	K_CG "CT02","V",0,5
	DB	ANI,A_ON,1
	DB	ANI,A_ON,2
;	DB	"【清美】：桜の木の下には・・・死体が埋まっていますのよ。"
	DB	"Kiyomi:  You know what? I heard that, under this cherry"
	DB	CR
	DB	"tree, there's a dead body buried."
	DB	NEXT
;	DB	"【清美】：死体の養分を吸って、桜は妖しく美しく花開くのですわ・・・。"
	DB	"Kiyomi:  The tree sucks up the essence of the body. That's"
	DB	CR
	DB	"why the flowers bloom so beautifully." 
	DB	NEXT
	K_CG "CT01","I",35,4
	DB	ANI,A_ON,1
	DB	ANI,A_ON,5
;	DB	"【鈴子】：ちょ、ちょっと、春先から怪談なんてやめてよね。"
	DB	"Reiko:  H- Hey, stop that! I hate ghost stories!"
	DB	NEXT
;	DB	"【清美】：ほら・・・鈴子さんの後の桜の幹に、人の顔のような模様が・・・"
	DB	"Kiyomi:  Look! There is a face on the tree behind Reiko."
	DB	NEXT
;	DB	"【鈴子】：ひっ！"
	DB	"Reiko:  !!"
	DB	NEXT
;	DB	"【美緒】：に゛ゃっ！？"
	DB	"Mio:  What?!"
	DB	NEXT
;	DB	"鈴子さんが隣にいた美緒ちゃんにしがみつく。"
	DB	"Reiko clung to Mio, sitting beside her."
	DB	NEXT
	TU_CG "CT01","C",0,35,2
	TU_CG "CT03","C",0,10,1
	T_CG "CT02","C",0,0,3
	DB ANI,A_ON,1
	DB ANI,A_ON,2
;	DB	"【清美】：もちろん、迷信ですのよ。鈴子さんって、恐がり屋さんですのね。"
	DB	"Kiyomi:  Of course that is only superstition. You certainly"
	DB	CR
	DB	"scare easily." 
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　桜
;	DB	"【今日子】：桜の木の下には死体が埋まっている、か・・・。"
	DB	"Kyoko:  A body under the cherry tree..."
	DB	NEXT
	K_CG "CT02","V",0,5
	DB	ANI,A_ON,1
	DB	ANI,A_ON,2
;	DB	"【清美】：そう・・・死体の養分を吸って、桜は妖しく美しく花開くのですわ・・・。"
	DB	"Kiyomi:  The tree sucks up the essence of the body. That's"
	DB	CR
	DB	"why the flowers bloom like that." 
	DB	NEXT
;	DB	"【今日子】：・・・とりあえず誠君でも埋めとこっか、来年もきれいな花が咲くよーに。"
	DB	"Kyoko:  Let's bury Makoto. Then they'll be pretty next year,"
	DB	CR
	DB	"too."
	DB	NEXT
;	DB	"【%001】：おいおいおいおい！"
	DB	"%001:  Hey! Cut it out."
;	DB	NEXT
	TU_CG "CT01","C",0,35,2
	TU_CG "CT03","C",0,10,1
	T_CG "CT02","C",0,0,3
	DB ANI,A_ON,1
	DB ANI,A_ON,2
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　桜
;	DB	"【鈴子】：もう・・・どうして素直に「きれい」って言えないのかしら。ね、美緒ちゃん。"
	DB	"Reiko:  Oh, why don't you just come out and say it straight,"
	DB	CR
	DB	"that the flowers are pretty? What do you think, Mio?"
	DB	NEXT
;	DB	"【美緒】：ふにゃっ？"
	DB	"Mio:  Urum?"
	DB	NEXT
;	DB	"美緒ちゃんは口一杯におにぎりを頬張っていた。"
	DB	"Mio had her mouth full of rice."
	EF_SET 101
	DW	0000H

M5:		;見る　誠
;	DB	"【清美】：先生、誠さんが倒れてらっしゃるようですけど。"
	DB	"Kiyomi:  Makoto looks like he has passed out, Sensei."
	DB	NEXT
;	DB	"【今日子】：ああ、邪魔ならその辺によけといて。"
	DB	"Kiyomi:  Yes. If he's in your way, just move him."
	DB	NEXT
;	DB	"【清美】：そうですわね・・・"
	DB	"Kiyomi:  Oh, okay..."
	DB	NEXT
;	DB	"誠はごろごろ転がされてその辺によけられてしまった。"
	DB	"She uncerimoniously pushes Makoto out of the way."
	DB	NEXT
;	DB	"（誠・・・哀れなやつ。）"
	DB	"Poor Makoto."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;話す　誠
;	DB	"【誠】：んが・・・もう飲めましぇ～ん。"
	DB	"Makoto:  ......Drink some more....."
	DB	NEXT
;	DB	"（・・・幸せそうだな、誠。）"
	DB	"He looks content."
	DB	NEXT
;	DB	"起こすのも悪いような気がして、俺は話し掛けるのをやめた。"
	DB	"It would be bad to wake him up. I should stop trying to"
	DB	CR
	DB	"talk to him."
	DW	0000H

M7:		;話す　鈴子
;	DB	"【%001】：鈴子さんが作ったのってどれ？"
	DB	"%001:  Did you make this, Reiko?"
	DB	NEXT
;	DB	"【鈴子】：あはは、私はお料理出来ないから、味見だけ。"
	DB	"Reiko:  I can't really cook. I just spiced it a little."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;話す　鈴子
;	DB	"【鈴子】：美緒ちゃんってお料理上手よね。"
	DB	"Reiko:  Mio, you really cook well."
	DB	NEXT
;	DB	"【美緒】：あたしより、清美先輩の弟の慎治君の方が上手だよ。"
	DB	"Mio:  Kiyomi's little brother Shinji is a better cook than"
	DB	CR
	DB	"I am."
	DB	NEXT
;	DB	"【清美】：毎日やっていれば上達するのも当然ですわ。"
	DB	"Kiyomi:  If you practice every day, you naturally get"
	DB	CR
	DB	"better. He gets a lot of practice."
	DB	NEXT
;	DB	"【%001】：毎日？"
	DB	"%001:  He does?"
	DB	NEXT
;	DB	"【清美】：ええ、３年前に母が亡くなって以来・・・。"
	DB	"Kiyomi:  Yes. My mother died three years ago..."
	DB	NEXT
;	DB	"【%001】：・・・悪ィ。"
	DB	"%001:  ......I'm sorry."
	DB	NEXT
;	DB	"【清美】：別に気にしていませんのよ、%001さん。",CR,"せっかく夜桜を見に来たのですから、楽しまなければいけませんわ。"
	DB	"Kiyomi:  It's alright. We're here to see the cherry blossoms,"
	DB	CR
	DB	"though. Let's have fun."
	EF_SET 103
	DW	0000H

M9:		;話す　清美
;	DB	"【%001】：新藤さんもお料理出来るの？"
	DB	"%001:  Can you cook too?"
	DB	NEXT
;	DB	"【清美】：いえ・・・我が家の料理番は弟の慎治ですのよ。"
	DB	"Kiyomi:  No.... My brother Shinji is the cook in the"
	DB	CR
	DB	"family."
	DB	NEXT
;	DB	"【清美】：わたくしはお手伝いだけですわ。"
	DB	"Kiyomi:  I just help out."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M10:		;話す　清美
;	DB	"【%001】：このポテトサラダは、わたくしがすり潰しましたのよ。"
	DB	"Kiyomi:  I mashed the potatoes for the potato salad." 
	EF_SET 104
	DW	0000H

M11:		;話す　美緒
;	DB	"【美緒】：誠先輩、起こさなくていいの？"
	DB	"Mio:  Should we wake up Makoto?"
	DB	NEXT
;	DB	"【%001】：そうだな・・・起こしてやるか。"
	DB	"%001:  I guess so. We don't want him to drown in his own"
	DB	CR
	DB	"vomit."
	DB	NEXT
;	DB	"【%001】：お～い、起きろ誠～。"
	DB	"%001:  Hey, wake up. Makoto!"
	DB	NEXT
;	DB	"【誠】：むが・・・"
	DB	"Makoto:  Mmmmm....."
	DB	NEXT
;	DB	"【%001】：御馳走があるぞ～。"
	DB	"%001:  There's some food here."
	DB	NEXT
;	DB	"【誠】：んが・・・まんじゅう怖い・・・"
	DB	"Makoto:  Mmmmmmm..... Food...."
	DB	NEXT
;	DB	"【%001】：・・・やっぱり寝かしとこう。"
	DB	"%001:  ...We better let him sleep it off."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M12:		;話す　美緒
;	DB	"【美緒】：この唐揚げ、私が作ったの。"
	DB	"Mio:  I made this fried chicken."
	DB	NEXT
;	DB	"【%001】：へえ・・・"
	DB	"%001:  Really?"
	DB	NEXT
;	DB	"【%001】：うん、うまい。"
	DB	"%001:  It's really great."
	DB	NEXT
;	DB	"【美緒】：でしょ？"
	DB	"Mio:  Really?"
	DB	FLG,F_COPYI,5,2
	DW	0000H

M13:		;話す　美緒
;	DB	"【美緒】：桜がきれい・・・。"
	DB	"Mio:  The sakura are beautiful, aren't they?"
	EF_SET 105
	DW	0000H

M14:		;話す　今日子
;	DB	"【今日子】：あら、この肉じゃがおいしい！いいお嫁さんになれるわよ。"
	DB	"Kyoko:  Hey, this potato dish is great. Whoever made it"
	DB	CR
	DB	"is going to be a great wife someday."
	DB	NEXT
;	DB	"【清美】：まあ・・・困りましたわね。"
	DB	"Kiyomi:  Haha... That's going to be a problem."
	DB	NEXT
;	DB	"【清美】：その肉じゃがはわたくしの弟の慎治が作ったものですのよ。慎治がお嫁さんになってしまったら大変ですわ。"
	DB	"Kiyomi:  My little brother Shinji made that. I'd hate to"
	DB	CR
	DB	"see him become a bride."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M15:		;話す　今日子
;	DB	"【今日子】：今時の男の子は、お料理くらい出来ないとダメよね～。"
	DB	"Kyoko:  A good man has to be able to cook, nowadays."
	DB	NEXT
;	DB	"【鈴子】：先生はどうなんですか？"
	DB	"Reiko:  How about you, Sensei?"
	DB	NEXT
;	DB	"【今日子】：・・・この玉子焼き、おいしいわね。"
	DB	"Kyoko:  Don't change the subject."
	EF_SET 102
	DW	0000H

M_EXIT:
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,6,255,101,102,103,104,105
	DB	FLG,F_EXIT,255
	DB	NEXT
	DB SINARIO,"CS303.OVL",0
	DW	0000H


end
