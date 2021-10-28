;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０７
;		ＧＷ２日目

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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,NN3,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	"MAKOTO",0
;NN2:	DB	2,	'英美',0
NN2:	DB	2,	"HIDEMI",0
;NN3:	DB	3,	'伸幸',0
NN3:	DB	3,	"NOBUYUKI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　誠
S2:		DW	VV1, NN2,  2, M3		;見る　英美
S3:		DW	VV1, NN3,  3, M4		;見る　伸幸
S4:		DW	VV2, NN1,  4, M5, M6, M7, M8		;話す　誠
S5:		DW	VV2, NN3,  5, M9, M10		;話す　伸幸


;イニシャルメッセージ
M1:
	DB	BGM,4
	BAK_INIT 'AB_38_1'
	B_P1 B_SUDA
;	DB	'・・・・・・ＧＷ２日目・・・・・・'
	DB	"The second day of Golden Week..."
	DB	NEXT
;	DB	'【%001】：ぶっっっ・・・ああふ。'
	DB	"%001:  *YAWN*"
	DB	NEXT
;	DB	'アゴがはずれそうなほど大きなあくびをした後、俺は読んでたマンガを閉じてベッドに横になった。'
	DB	"After a great stretch, I put down the comic book I was"
	DB	CR
	DB	"reading and lay down on the bed."
	DB	NEXT
;	DB	'【%001】：たまには何もしねぇでぼ～っとするのもいいねぇ。'
	DB	"%001:  Boy, doing nothing is great, too."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT10',0,0,30,1
;	DB	'【英美】：しゅ～うちゃん。'
	DB	"Hidemi:  Shu-chan!"
	DB	NEXT
;	DB	'【%001】：なんだよかーちゃん。'
	DB	"%001:  What's up, Mom?"
	DB	NEXT
;	DB	'【英美】：お友達が見えたわよ。'
	DB	"Hidemi:  One of your friends is here."
	DB	NEXT
;	DB	'【%001】：え？誰？'
	DB	"%001:  Eh? Who?"
	DB	NEXT
;	DB	'がらっ！'
	DB	"*KACHA*"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT14','F','D',0,2
;	DB	'【誠】：%001ーッ！'
	DB	"Makoto:  %001!"
	DB	NEXT
;	DB	'いきなり窓が開いて、誠が入って来た！'
	DB	"Suddenly the window opened, and Makoto climbed in."
	DB	NEXT
	DB	"BAM! ",FLASH,1,"BAM! ",FLASH,1,"BAM! ",FLASH,1,"BAM! ",FLASH,1,"BAM! ",FLASH,1,"BAM! ",FLASH,1,"BAM! ",FLASH,1,"BAM! ",FLASH,1
	DB	NEXT
;	DB	'振り返った瞬間、俺は全身につぶてのようなものを食らった。'
	DB	"As I turned around, I felt something like tiny pebbles hit"
	DB	CR
	DB	"my body."
	DB	NEXT
;	DB	'【%001】：な、なんだぁ？'
	DB	"%001:  What the hell...?"
	DB	NEXT
;	DB	'【誠】：「トラ　トラ　トラ！我奇襲ニ成功セリぃ！！」'
	DB	"Makoto:  Yes! That was a full hit!"
	DB	NEXT
;	DB	'それは誠のエアーガンから発射された弾だった。'
	DB	"Makoto had shot me with his air gun."
	DB C_BLD,C_N_ON,1,3
	DB C_BLD,C_N_ON,2,2
	DW	0000H

M2:		;見る　誠
;	DB	'軍服っぽい迷彩の服を着て、エアーガンを構えている。'
	DB	"He's wearing a military getup, and was holding his stupid"
	DB	CR
	DB	"air gun."
	DW	0000H

M3:		;見る　英美
;	DB	'いつもどーり緊張感のない顔で笑ってる。'
	DB	"She's her usual relaxed self."
	DW	0000H

M4:		;見る　伸幸
;	DB	'誠の入って来た窓の外でふんぞり返っている。'
	DB	"Dad's standing haughtily outside the window Makoto"
	DB	CR
	DB	"came in."
	DW	0000H

M5:		;話す　誠
;	DB	'【%001】：い・・・いきなりなにすんだよっ！'
	DB	"%001:  What the hell are you doing?"
	DB	NEXT
;	DB	'【誠】：これは天罰だ。'
	DB	"Makoto:  This is your punishment."
	DB	NEXT
;	DB	'【%001】：なに？！'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【誠】：昨日は可愛い女の子を３人も独り占め出来て、さぞかしご満悦だったろ%001。'
	DB	"Makoto:  For going out all alone yesterday with those three"
	DB	CR
	DB	"women."
	DB	NEXT
;	DB	'【伸幸】：おおっ！本当か%001！'
	DB	"Nobuyuki:  Wow! Is that right, %001?"
	DB	NEXT
	TU_CG 'CT09',0,0,20,3
	T_CG 'CT14','F','D',0,2
	DB	ANI,A_ON,3
;	DB	'誠の後ろから、親父が入って来た。'
	DB	"My father came climbing in behind Makoto."
	DB	NEXT
	T_CG1 'CT14',"F",0,0,4
	DB	ANI,A_ON,3
;	DB	'【誠】：小隊長殿！奇襲作戦は大成功でありますッ！'
	DB	"Makoto:  Captain! My mission was successful!"
	DB	NEXT
;	DB	'誠が親父にビシッと敬礼する。'
	DB	"Makoto saluted my father."
	DB	NEXT
;	DB	'（・・・小隊長・・・？）'
	DB	"(...Captain...?)"
	DB C_BLD,C_N_OFF,1,2
	DB C_BLD,C_N_OFF,2,2
	DB	FLG,F_COPYI,4,1
	DW	0000H


M6:		;話す　誠
;	DB	'【%001】：誠、エアーガンは人に向けて撃っちゃあいけないんだぞ！'
	DB	"%001:  Makoto, what are you thinking, shooting me like"
	DB	CR
	DB	"that?"
	DB	NEXT
;	DB	'【誠】：いや、お前なら避けられるんじゃないかって期待してたんだけど。'
	DB	"Makoto:  Well, I thought you would get out of the way in"
	DB	CR
	DB	"time."
	DB	NEXT
;	DB	'【%001】：いくら俺だって不意討ちされたらよけらんねぇよ！'
	DB	"%001:  How could I when I didn't even know you were"
	DB	CR
	DB	"there?!"
	DB	NEXT
;	DB	'【誠】：ま、サバゲー用のゴム弾だから痛くなかっただろ？'
	DB	"Makoto:  Well, they were rubber bullets, so they didn't"
	DB	CR
	DB	"hurt, right?"
	DB	NEXT
;	DB	'【%001】：・・・けっこう痛かったぞ。'
	DB	"%001:  They hurt plenty!"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M7:		;話す　誠
;	DB	'【誠】：と、いうわけでサバイバルゲームやろうぜ！'
	DB	"Makoto:  Let's play a survival game, %001!"
	DB	NEXT
;	DB	'【%001】：何が「と、いうわけ」なんだよ。'
	DB	"%001:  Not interested, thanks."
	DB	NEXT
;	DB	'【誠】：ほぉ・・・女の子の買い物には一日付き合えても、',CR,'男のオレのささやかな趣味には付き合う気はないと。'
	DB	"Makoto:  So, you spent all day yesterday shopping with"
	DB	CR
	DB	"some women, and now, you don't want to play one little"
	DB	CR
	DB	"game of survival with me?"
	DB	NEXT
;	DB	'【誠】：ひでぇやつだなお前って。それでも友達かよぉ。'
	DB	"Makoto:  Is that how you treat your best friend?"
	DB	NEXT
;	DB	'【英美】：しゅうちゃん、お友達は大事にしなきゃダメよ。'
	DB	"Hidemi:  Shu-chan, you should be nice to your friends."
	DB	NEXT
;	DB	'【%001】：わ、わかった、付き合うよ。'
	DB	"%001:  Okay, I give up!"
	DB	NEXT
;	DB	'【誠】：よぉし、それでこそ男だ。'
	DB	"Makoto:  All right! Good man."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M8:		;話す　誠
;	DB	'【誠】：オレがいつも使ってる河原があるんだ。'
	DB	"Makoto:  We can go to the riverbed I always use."
	DB	NEXT
;	DB	'【誠】：行こうぜ%001。'
	DB	"Makoto:  Let's go, %001."
	EF_SET 101
	DW	0000H

M9:		;話す　伸幸
;	DB	'【%001】：なんだよ小隊長って。'
	DB	"%001:  Why are you saluting my father?"
	DB	NEXT
;	DB	'【誠】：いやぁ、奇襲作戦の立案は%001のお父さんなんだ。'
	DB	"Makoto:  The ambush was your father's idea."
	DB	NEXT
;	DB	'【伸幸】：母さんに注意を引き付けさせておいて背後から奇襲をかけるとゆう、素晴らしい作戦だ！恐れ入ったか%001！'
	DB	"Nobuyuki:  We got your mother to distract you so we could"
	DB	CR
	DB	"attack you from behind! Pretty good, eh? Are you mad, %001?"
	DB	NEXT
;	DB	'【%001】：・・・へぇへぇ。'
	DB	"%001:  Is it legal for kids to divorce their family in"
	DB	CR
	DB	"Japan?"
	DB	FLG,F_COPYI,5,1
	DW	0000H

M10:		;話す　伸幸
;	DB	'【伸幸】：しかしいきなり４Ｐとは、やるなぁ%001。'
	DB	"Nobuyuki:  I'm surprised you were doing '4P' already!"
	DB	NEXT
;	DB	'【%001】：そんなんじゃねぇよ！'
	DB	"%001:  That's not what Makoto meant!"
	EF_SET 102
	DW	0000H

M_EXIT:
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,3,255,101,102
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'【伸幸】：それで、相手はどんな子なんだ？'
	DB	"Nobuyuki:  So tell me more about these women."
	DB	NEXT
;	DB	'【誠】：一人は年上のお姉さまタイプで・・・'
	DB	"Makoto:  Well, first there's one called Reiko..."
	DB	NEXT
;	DB	'【%001】：誠！行くぞ！'
	DB	"%001:  Makoto! Let's go!"
	DB	NEXT
;	DB	'俺は誠の襟首をつかんで部屋を出た。'
	DB	"I grabbed him by the collar and ran out of the room."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・'
	DB	".........................................................."
	DB	NEXT
	B_O B_WIPE
;	DB	'【伸幸】：しかしアレだね、%001もいつのまにか大人になってたんだなぁ。'
	DB	"Nobuyuki:  Well, %001 has suddenly turned into quite an"
	DB	CR
	DB	"adult."
	DB	NEXT
;	DB	'【英美】：しゅうちゃんが他の女の子にとられるなんて、',CR,'英美、悲しー。'
	DB	"Hidemi:  If another woman steals my little Shu-chan away,"
	DB	CR
	DB	"Hidemi will be really sad."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・'
	DB	".........................."
	DB	NEXT
	BAK_INIT 'AB_06_3'
	B_P1 B_WIPE
;	DB	'【誠】：・・・ところで、%001の親父もサバゲーやってんの？'
	DB	"Makoto:  ...So, is your Dad into survival training like me?"
	DB	CR
	DB	"too?"
	DB	NEXT
;	DB	'【%001】：・・・なんでそう思った？'
	DB	"%001:  Why do you ask?"
	DB	NEXT
;	DB	'【誠】：あの足運びとか作戦の立案とかが、素人離れしてたからな。'
	DB	"Makoto:  Well, he seemed to know what he was doing."
	DB	NEXT
;	DB	'【誠】：あの年じゃ参戦経験あるわけないし・・・'
	DB	"Makoto:  But he couldn't have fought in any wars. He's"
	DB	CR
	DB	"too young."
	DB	NEXT
;	DB	'（覗きで鍛えてるなんて言えねーよ・・・）'
	DB	"I won't tell him the truth, that my father's a peeping tom..."
	DB	NEXT
;	DB	'【%001】：それよりさ！俺にも銃貸してくれよ。'
	DB	"%001:  Well, let's get moving! Will you lend me a gun?"
	DB	NEXT
;	DB	'【誠】：おう、Ｍ１６Ａ２とＡＫ７４とどっちがいい？'
	DB	"Makoto:  Which do you want, an M16A or an AK74?"
	DB	NEXT
;	DB	'【%001】：・・・なんだって？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【誠】：それともハンドガンがいいか？９ｍｍベレッタと',CR,'３５７口径デザートイーグルとあるけど。'
	DB	"Makoto:  Or how about a handgun? A 9 mm Beretta or a 357-"
	DB	CR
	DB	"caliber Desert Eagle?"
	DB	NEXT
;	DB	'【%001】：・・・お前に任せた。'
	DB	"%001:  ....I'll leave it up to you."
	DB	NEXT
;	DB	'【誠】：ほら、あそこの河原なんだ。あそこなら人様に迷惑かけないし金もかからないだろ。'
	DB	"See, there's the riverbed. There we won't bother anybody....."
	DB	CR
	DB	"plus, it's free."
	DB	NEXT
;	DB	'【%001】：・・・でも、誰かいるみたいだぞ？'
	DB	"%001:  But it looks like there's someone there!"
	DB	NEXT
;	DB	'【誠】：うそっ！ここはオレの秘密の場所なのに！一体誰だ？'
	DB	"Makoto:  No way! This is my secret spot! Who could it be?"
	DB	NEXT
	DB SINARIO,'CS408.OVL',0
	DW	0000H


end