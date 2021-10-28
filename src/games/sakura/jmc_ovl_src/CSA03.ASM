;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０３
;		忘年会本番

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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,NN8,NN9,-1
CM2:	DW	VV2,	NN6,NN8,NN10,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	'MAKOTO',0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	'REIKO',0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'KIYOMI',0
;NN4:	DB	4,	'鈴子と清美',0
NN4:	DB	4,	'REIKO/KIYOMI',0
;NN5:	DB	5,	'美緒と亜希',0
NN5:	DB	5,	'MIO/AKI',0
;NN6:	DB	6,	'今日子',0
NN6:	DB	6,	'KYOKO',0
;NN7:	DB	7,	'英美',0
NN7:	DB	7,	'HIDEMI',0
;NN8:	DB	8,	'伸幸',0
NN8:	DB	8,	'NOBUYUKI',0
;NN9:	DB	9,	'誠と伸幸',0
NN9:	DB	9,	'MAKOTO/NOBUYUKI',0
;NN10:	DB	10,	'亜希',0
NN10:	DB	10,	'AKI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　誠
S2:		DW	VV1, NN2,  2, M3		;見る　鈴子
S3:		DW	VV1, NN3,  3, M4		;見る　清美
S4:		DW	VV1, NN4,  4, M5, M6, M7		;見る　鈴子と清美３
S5:		DW	VV1, NN5,  5, M8, M9, M10, M11, M12, M13		;見る　美緒と亜希６
S6:		DW	VV1, NN6,  6, M14		;見る　今日子
S7:		DW	VV1, NN7,  7, M15		;見る　英美
S8:		DW	VV1, NN8,  8, M16		;見る　伸幸
S9:		DW	VV1, NN9,  9, M17, M18, M19		;見る　誠と伸幸３
S10:		DW	VV2, NN10,  10, M20		;話す　亜希
S11:		DW	VV2, NN6,  11, M21, M22		;話す　今日子
S12:		DW	VV2, NN8,  12, M23, M24		;話す　伸幸


;イニシャルメッセージ
M1:
	DB	BGM,3
	BAK_INIT 'AB_01_2'
	DB BUF,B_COPY01
	T_CG 'CT12','C','K',10,1
;	DB	'【今日子】：それで、結局%001君は誰が好きなのかなぁ？'
	DB	"Kyoko:  So? Are you going to tell us which woman you're in"
	DB	CR
	DB	"love with, or what?"
	DB	NEXT
;	DB	'【%001】：・・・まだそんなのわかんねーよ・・・'
	DB	"%001:  .....That again?"
	DB	NEXT
;	DB	'【今日子】：んっふっふ、照～れちゃってまぁ。'
	DB	"Kyoko:  You're so cute when you get shy like that!"
	DB	NEXT
	T_CG1 'CT03','C','K',20,2
	DB ANI,A_ON,1
;	DB	'【美緒】：何、話してるの？'
	DB	"Mio:  What are you talking about?"
	DB	NEXT
;	DB	'【%001】：いやっこっちのことだよハハハ。'
	DB	"%001:  Oh, nothing. "
	DB	NEXT
;	DB	'【亜希】：美緒！こっち来なさい！'
	DB	"Aki:  Mio, come here a minute."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT12','C','K',10,1
;	DB	'美緒ちゃんは亜希ちゃんに連れてかれてしまった。'
	DB	"Aki took Mio away."
	DB C_BLD,C_N_ON,1,4
	DB C_BLD,C_N_ON,1,9
	DB C_BLD,C_N_ON,2,2
	DB C_BLD,C_N_ON,2,3
	DW	0000H

M2:		;見る　誠
;	DB	'父さんと２人で、何やら話し込んでいる。'
	DB	"He's talking with my father about something."
	DB	NEXT
	DB	"I'll bet they're talking about me."
	DB C_BLD,C_N_ON,1,1
	DB C_BLD,C_N_ON,1,8
	DB C_BLD,C_N_OFF,1,9
	DW	0000H

M3:		;見る　鈴子
;	DB	'新藤さんと母さんと３人で、何やら話し込んでる。'
	DB	"She's talking with Kiyomi and Mom."
	DB	NEXT
;	DB	'・・・時々こっちを振り返るところを見ると、俺の話でもしてんだろう。'
	DB	"I'll bet they're talking about me."
	DB C_BLD,C_N_ON,1,2
	DB C_BLD,C_N_ON,1,3
	DB C_BLD,C_N_OFF,1,4
	DW	0000H

M4:		;見る　清美
;	DB	'鈴子さんと母さんと３人で、何やら話し込んでる。'
	DB	"She's talking with Reiko and Mom."
	DB	NEXT
;	DB	'・・・時々こっちを振り返るところを見ると、俺の話でもしてんだろう。'
	DB	"I'll bet they're talking about me."
	DB C_BLD,C_N_ON,1,2
	DB C_BLD,C_N_ON,1,3
	DB C_BLD,C_N_OFF,1,4
	DW	0000H

M5:		;見る　鈴子と清美１
;	DB	'【清美】：・・・本当ですの、おばさま？'
	DB	"Kiyomi:  Really? Is that true?"
	DB	NEXT
;	DB	'【英美】：そ～なのぉ。英美、困っちゃった～。'
	DB	"Hidemi:  Yes! I didn't know what to do!"
	DB	NEXT
;	DB	'【鈴子】：あの%001君が・・・人は見掛けによらないものね。'
	DB	"Reiko:  %001 did that...and no one saw him...?"
	DB	NEXT
;	DB	'（何を話してんだかーちゃん！）'
	DB	"What the hell are they talking about?"
	DB	FLG,F_COPYI,4,1
	DW	0000H

M6:		;見る　鈴子と清美２
;	DB	'【英美】：実は、しゅ～ちゃんったらね・・・'
	DB	"Hidemi:  That's not all... (whisper whisper)"
	DB	NEXT
;	DB	'【鈴子】：え～っ！'
	DB	"Reiko:  Really?"
	DB	NEXT
;	DB	'【清美】：信じられませんわ・・・'
	DB	"Kiyomi:  I can't believe it!"
	DB	NEXT
;	DB	'二人は盗み見るように俺の方を見て、俺と目が合うと真っ赤になって向こうを向いてしまった。'
	DB	"They're looking over here at me, like I'm some kind of"
	DB	CR
	DB	"strange creature from outer space."
	DB	NEXT
;	DB	'（ちょっと・・・かーちゃん・・・）'
	DB	"....Cut it out, Mom!"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M7:		;見る　鈴子と清美３
;	DB	'【英美】：それでね、しゅ～ちゃんったら・・・'
	DB	"Hidemi: And then!  (whisper whisper)"
	DB	NEXT
;	DB	'【鈴子】：！'
	DB	"Reiko:  !!"
	DB	NEXT
;	DB	'【清美】：まぁ・・・'
	DB	"Kiyomi:  Wow..."
	DB	NEXT
;	DB	'（・・・かーちゃん・・・俺の恥ずかしい話を・・・？）'
	DB	"Mom, don't you know when to quit?"
	EF_SET 103
	DW	0000H

M8:		;見る　美緒と亜希
;	DB	'（２人で膝を突き合わせて何やら話してる。）'
	DB	"They've talking about something."
	DB	NEXT
;	DB	'【亜希】：美緒！あんたも飲みなさい！'
	DB	"Aki:  Mio! Shut up and drink!"
	DB	NEXT
;	DB	'【美緒】：え・・・あたし、お酒なんか飲めないよ。'
	DB	"Mio:  But I can't drink!"
	DB	NEXT
;	DB	'【亜希】：あたしの酒が飲めないィ？'
	DB	"Aki:  You can't drink my sake?...*hic*"
	DB	NEXT
;	DB	'（・・・亜希ちゃん、完全に酔っ払ってるな・・・）'
	DB	"Aki's drunk..."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M9:		;見る　美緒と亜希２
;	DB	'（亜希ちゃんが美緒ちゃんにお酒を飲ませようとしてる。）'
	DB	"Aki's trying to get Mio to drink."
	DB	NEXT
;	DB	'【美緒】：それじゃ・・・ちょっとだけ・・・'
	DB	"Mio:  Okay, just a little."
	DB	NEXT
;	DB	'【亜希】：そ～よ、それでこそあたしのライバルよ。'
	DB	"Aki:  You have to drink! You're my rival!"
	DB	NEXT
;	DB	'とくっとくっとくっ'
	DB	"*swallow*"
	DB	NEXT
;	DB	'亜希ちゃんは美緒ちゃんのコップになみなみと琥珀色の液体を注いだ。'
	DB	"Aki refills Mio's glass."
	DB	NEXT
;	DB	'（・・・あれ、ブランデーじゃねぇか？）'
	DB	"Isn't that brandy?"
	DB	NEXT
;	DB	'（・・・ストレートで飲ませる気か？亜希ちゃん）'
	DB	"She's drinking straight brandy? That's dangerous."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M10:		;見る　美緒と亜希３
;	DB	'【美緒】：あ！こんなに飲めないよ！'
	DB	"Mio:  Ah! I can't drink this much!"
	DB	NEXT
;	DB	'【亜希】：そんなの、やってみなきゃわっかんないでしょ！'
	DB	"Aki:  Sure you can! Go ahead!"
	DB	NEXT
;	DB	'【美緒】：ん・・・ゲホッゲホッ！'
	DB	"Mio:  .....I'll try."
	DB	NEXT
;	DB	'美緒ちゃんは、ほんの少し口を付けただけでむせ返った。'
	DB	"Making a face, Mio downed the brandy in one gulp."
	DB	NEXT
;	DB	'（・・・止めた方がいいな。）'
	DB	"I really should stop them."
	DB	NEXT
;	DB	'ぐいっ'
	DB	"Kyoko:  %001..."
	DB	NEXT
;	DB	'【%001】：うわっ！？'
	DB	"%001:  Wah!!"
	DB	NEXT
;	DB	'俺は今日子先生に引きずり戻された。'
	DB	"Suddenly Kyoko-sensei pulled me back."
	DB	NEXT
;	DB	'【今日子】：楽しく飲んでるんだから、邪魔しちゃダメよん☆'
	DB	"Kyoko:  They're fine. Don't bother them."
	DB	NEXT
;	DB	'【%001】：あれが楽しそうに見えるんですか、あれが！'
	DB	"%001:  I think Mio's going to hurt herself."
	DB	FLG,F_COPYI,5,3
	DW	0000H


M11:		;見る　美緒と亜希４
;	DB	'【美緒】：なっさけないわね～！貸しなさい！'
	DB	"Mio:  Give me that cup back!"
	DB	NEXT
;	DB	'亜希ちゃんは美緒ちゃんのコップをひったくり一口あおった。'
	DB	"Aki had taken her cup back and was drinking from it."
	DB	PAUSE,CR
;	DB	'・・・と思ったら、やおら美緒ちゃんのあごをくいっと持ち上げて、口移しに酒を流し込んだ。'
	DB	"....I was wrong. She kissed Mio, pushing the brandy from"
	DB	CR
	DB	"her mouth into Mio's."
	DB	NEXT
;	DB	'【美緒】：ん！・・・んん～・・・！'
	DB	"Mio:  ..........Gross!"
	DB	NEXT
;	DB	'【%001】：・・・あっらー・・・'
	DB	"%001:  .......Oh my god!"
	DB	NEXT
;	DB	'【今日子】：仲いいじゃない、あの子達。'
	DB	"Kyoko:  They're such good friends."
	DB	NEXT
;	DB	'美緒ちゃんは目を白黒させた後、ゴクンとのどを鳴らした。'
	DB	"Mio swallowed what Aki had given her, but her eyes"
	DB	CR
	DB	"weren't happy."
	DB	NEXT
;	DB	'美緒ちゃんの顔一面が薔薇色に染まり、目が潤む。'
	DB	"Mio's face was pink with drunkeness."
	DB	NEXT
;	DB	'そのまま美緒ちゃんは仰向けにひっくり返った。'
	DB	"Then she just fell backwards."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・・・・・・・・・・きゅう。'
	DB	"Mio:  ............ *whump*"
	DB	FLG,F_COPYI,5,4
	DW	0000H

M12:		;見る　美緒と亜希５
;	DB	'亜希ちゃんの濃厚なキス（？）で、美緒ちゃんはひっくり返ってしまった。'
	DB	"Mio has collapsed from Aki's kiss."
	DB	NEXT
;	DB	'【亜希】：あはは、あたしの勝ち・・・ね・・・'
	DB	"Aki:  I win!"
	DB	NEXT
;	DB	'一瞬、亜希ちゃんの動きが止まったかと思うと、亜希ちゃんはそのまま前のめりに倒れ込んだ。'
	DB	"Then Aki slowly went to sleep."
	DB	NEXT
;	DB	'【今日子】：いいの、%001君？亜希ちゃんに美緒ちゃんとられちゃうわよ？'
	DB	"Kyoko:  I think you're going to lose Mio to Aki..."
	DB	NEXT
;	DB	'【%001】：・・・何言ってんですか・・・'
	DB	"%001:  .......What are you talking about?"
	DB	FLG,F_COPYI,5,5
	DW	0000H

M13:		;見る　美緒と亜希６
;	DB	'【美緒】：・・・ふみゃ・・・'
	DB	"Mio:  ..................................."
	DB	NEXT
;	DB	'【亜希】：美緒・・・あたし・・・・・・勝ち・・・'
	DB	"Aki:  ........I win....."
	DB	NEXT
;	DB	'二人とも酔いつぶれて、折り重なるようにぶっ倒れている。'
	DB	"They're out cold."
	DB	NEXT
;	DB	'傍目に見ると、亜希ちゃんが美緒ちゃんを押し倒してるよーにも見える。ひじょーに危険な構図だ。'
	DB	"Mio passed out with her face in Aki's crotch. They look"
	DB	CR
	DB	"like lesbians."
	DB	NEXT
;	DB	'【伸幸】：・・・'
	DB	"Nobuyuki:  ...................."
	DB	NEXT
;	DB	'【%001】：親父！ビデオに録るなっての！'
	DB	"%001:  Dad! Put the video camera away!"
	EF_SET 102
	DW	0000H

M14:		;見る　今日子
;	DB	'俺を肴に、日本酒もビールも焼酎もチャンポンでがばがば飲んでる。'
	DB	"She's alternating between pouring beer and pouring sake"
	DB	CR
	DB	"into my glass."
	DB	NEXT
;	DB	'・・・この人につきあって飲んでたら、身がもたねーぞ。'
	DB	"She's a dangerous person."
	DW	0000H

M15:		;見る　英美
;	DB	'鈴子さんと新藤さんと３人で、何やら話し込んでる。'
	DB	"She's talking with Reiko and Kiyomi about something."
	DB	NEXT
;	DB	'【英美】：それでね、しゅうちゃんったらねぇ・・・'
	DB	"Hidemi:  And then he.... (whisper whisper)"
	DB	NEXT
;	DB	'・・・どうやら俺の話で盛り上がってるらしい。'
	DB	"She's really getting into it."
	DW	0000H

M16:		;見る　伸幸
;	DB	'誠と２人で、何やら話し込んでいる。'
	DB	"He's talking with Makoto about something."
	DB	NEXT
;	DB	'・・・また悪巧みでもしてんだろう。そ～に決まってる。'
	DB	"I'm sure they're planning some mischief."
	DB C_BLD,C_N_ON,1,1
	DB C_BLD,C_N_ON,1,8
	DB C_BLD,C_N_OFF,1,9
	DW	0000H

M17:		;見る　誠と伸幸
;	DB	'【伸幸】：・・・以上がＯ（オー）計画の概要だ。',CR,'何か質問はあるかね？'
	DB	"Nobuyuki: And this is the plan I have..."
	DB	NEXT
;	DB	'【誠】：はい、・・・・・・の場合はどーするんですか？'
	DB	"Makoto:  It looks good. What about getting him to.......?"
	DB	NEXT
;	DB	'【伸幸】：その時はだね・・・'
	DB	"Nobuyuki:  Well, I was planning to..."
	DB	NEXT
;	DB	'（今度は何するつもりだ！？）'
	DB	"What are they talking about?!"
	DB	FLG,F_COPYI,9,1
	DW	0000H

M18:		;見る　誠と伸幸２
;	DB	'【伸幸】：ところで、誠君のお父さんは何してる人だっけ？'
	DB	"Nobuyuki:  What does your father do, anyway, Makoto?"
	DB	NEXT
;	DB	'【誠】：ウチの親父ですか？パソコン会社のしがないセールスマンですよ。'
	DB	"Makoto:  He sells computers."
	DB	NEXT
;	DB	'【伸幸】：ほぉ・・・パソコンかね。'
	DB	"Nobuyuki:  Computer, huh?"
	DB	NEXT
;	DB	'【誠】：ただ・・・共産圏への出張が妙に多いのが気になるんですけどね・・・'
	DB	"Makoto:  He often goes on business trips to communist"
	DB	CR
	DB	"countries, though. I never know what he's doing there."
	DB	FLG,F_COPYI,9,2
	DW	0000H

M19:		;見る　誠と伸幸３
	DB BUF,B_COPY01
	TU_CG 'CT09',0,0,0,3
	T_CG 'CT14','C','D',25,4
	DB ANI,A_ON,3
;	DB	'【誠】：%001、先生を独り占めなんてずるいぞ！'
	DB	"Makoto:  %001, stop hogging Sensei all to yourself!"
	DB	NEXT
;	DB	'【伸幸】：そーだそーだ！'
	DB	"Nobuyuki:  He's right, son!"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT12','C','K',10,1
;	DB	'【今日子】：ごめんなさいね、%001君と大事なお話してるの。'
	DB	"Kyoko:  I'm sorry. I'm talking about something important"
	DB	CR
	DB	"with %001."
	DB	NEXT
;	DB	'そう言って、先生は俺の盃になみなみと酒を注いだ。'
	DB	"With that, she poured me another round of sake."
	DB	NEXT
;	DB	'【%001】：先生・・・もう勘弁して・・・'
	DB	"%001:  Sensei, I don't want to drink anymore..."
	DB	NEXT
;	DB	'【今日子】：山神さん、%001君はですねぇ・・・'
	DB	"Kyoko:  Mr. Yamagami, let me tell you a few things about"
	DB	CR
	DB	"your son..."
	DB	NEXT
	DB	"No! Anything but that!"
	DB	NEXT
;	DB	'ごっくんごっくんごっくん'
	DB	"'guzzle guzzle'"
	DB	NEXT
;	DB	'【%001】：ああ、お酒がおいしいなあ！'
	DB	"%001:  Mm, this sake is delicious!"
	DB	NEXT
;	DB	'【伸幸】：%001がどうかしましたか、先生。'
	DB	"Nobuyuki:  Yes? What about my son?"
	DB	NEXT
;	DB	'【今日子】：私、何か言いましたっけ？'
	DB	"Kyoko:  ......What was I talking about? I forgot!"
	DB	NEXT
;	DB	'（・・・鬼・・・悪魔・・・）'
	DB	".....Evil witch!"
	EF_SET 104
	DW	0000H

M20:		;話す　亜希
;	DB	'【%001】：そか・・・それじゃ大掃除の代わりに、美緒ちゃんを家まで送ってってくれねーか？'
	DB	"%001:  Aki, will you walk Mio home tonight?"
	DB	NEXT
;	DB	'【亜希】：美緒を～？'
	DB	"Aki:  Mio...?"
	DB	NEXT
;	DB	'【美緒】：ふに～・・・'
	DB	"Mio:  ...................*zonk*"
	DB	NEXT
;	DB	'昨日のアレがよっぽどショックだったのか、はたまた酒が抜けないだけか、美緒ちゃんはふらふらで、とても一人で歩けそうになかった。'
	DB	"Mio couldn't possibly walk home by herself."
	DB	NEXT
;	DB	'【今日子】：そうね、亜希ちゃんが一番家近いし、お年玉もらえるんだからいいでしょ？'
	DB	"Kyoko:  That's a good idea. You live close to her, too."
	DB	NEXT
;	DB	'【伸幸】：頼まれてくれるね？'
	DB	"Nobuyuki:  Will you do it?"
	DB	NEXT
;	DB	'【亜希】：わかった、やるわ。'
	DB	"Aki:  .....Okay, I'll do it."
	DB	NEXT
;	DB	'【亜希】：ほら、行くわよ美緒！'
	DB	"Aki:  Let's go, Mio!"
	DB	NEXT
;	DB	'【美緒】：ふに・・・ごめんね、亜希ちゃん・・・'
	DB	"Mio:  ............I'm sorry for imposing, Aki..."
	DB	NEXT
;	DB	'【亜希】：別にあんたのためじゃないわよ。お年玉もらえるからやるに決まってんじゃない。'
	DB	"Aki:  I'm not doing it for you. They asked me to do it!"
	DB	NEXT
;	DB	'【亜希】：（元はって言えば、あたしのせいだし・・・）'
	DB	"Aki:  Besides, I'm the one who made you like this. Sorry..."
	DB	NEXT
;	DB	'【美緒】：なに、亜希ちゃん・・・？'
	DB	"Mio:  ..........What did you say?"
	DB	NEXT
;	DB	'【亜希】：なんでもない！'
	DB	"Aki:  Nothing! Nevermind!"
	DB	NEXT
;	DB	'・・・亜希ちゃんと美緒ちゃんはぴったり寄り添って歩いていった。'
	DB	"Listing thirty degrees to starboard, Aki and Mio stumble"
	DB	CR
	DB	"off into the night."
	DB	NEXT
;	DB	'【今日子】：それじゃ、あたし達もおいとましますか。'
	DB	"Kyoko:  Well, I guess we should be leaving, now, too."
	DB	NEXT
;	DB	'【清美】：そうですわね・・・'
	DB	"Kiyomi:  Yes, that's true..."
	DB	NEXT
;	DB	'【英美】：また遊びに来てね～！'
	DB	"Hidemi:  Please come back again soon!"
	DB	NEXT
;	DB	'【鈴子】：%001君・・・またね。'
	DB	"Reiko:  %001, we'll see you later."
	DB	NEXT
;	DB	'【%001】：うん・・・また今度。'
	DB	"%001:  Yeah. Thanks."
	DB	NEXT
;	DB	'【誠】：俺もそろそろ帰るよ。'
	DB	"Makoto:  I guess I'll go home, too."
	DB	NEXT
;	DB	'【%001】：あー、またな。'
	DB	"%001:  Thanks for helping out today."
	DB	NEXT
;	DB	'・・・・・・・・・・・・'
	DB	"..................................."
	DB	NEXT
;	DB	'【%001】：行っちゃったな・・・'
	DB	"%001:  They're gone."
	DB	NEXT
;	DB	'【伸幸】：すがすがしい朝だな・・・。'
	DB	"Nobuyuki:  What a fresh, clean morning."
	DB	NEXT
;	DB	'【伸幸】：「一年の計は元旦にあり」か。'
	DB	"Nobuyuki:  Let's go to bed."
	DB	NEXT
;	DB	'【英美】：そうだわ、しゅうちゃ～ん☆'
	DB	"Hidemi:  Oh, Shu-chan?"
	DB	NEXT
;	DB	'【%001】：な、何だよ正月から！'
	DB	"%001:  What is it now, Mom?"
	DB	NEXT
;	DB	'【英美】：だからぁ、「あけましておめでとう」のキスよ☆'
	DB	"Hidemi:  I forgot to give you your 'Happy New Year' kiss!"
	DB	PAUSE,CR
;	DB	'ん～・・・'
	DB	"Mmmmmmm..."
	DB	NEXT
;	DB	'【%001】：もうっ！やめてくれよ！'
	DB	"%001:  Leave me alone! "
	DB	NEXT
;	DB	'【%001】：そういや、昨日鈴子さん達に何を話したんだ？'
	DB	"%001:  By the way, what were you talking about with Reiko"
	DB	CR
	DB	"and Kiyomi?"
	DB	NEXT
;	DB	'【英美】：あの子達がしゅうちゃんのこと聞きたいって言うからぁ、いろんなお話したのよぉ。'
	DB	"Hidemi:  They said they wanted me to tell them about you."
	DB	CR
	DB	"I told them a lot of different stories."
	DB	NEXT
;	DB	'【英美】：しゅうちゃんが小学校二年までおねしょしてたこととかぁ、中学校一年生まで英美とお風呂に入ってたこととかぁ・・・'
	DB	"Hidemi:  Like how you used to wet your bed when you were"
	DB	CR
	DB	"twelve...or how you use to take a bath with me until"
	DB	CR
	DB	"last year..."
	DB	NEXT
;	DB	'【%001】：かーちゃんのバカ～！'
	DB	"%001:  I hate you!"
	DB	NEXT
	B_O B_SUDA
	DB SINARIO,'CSA04.OVL',0
	DW	0000H

M21:		;話す　今日子
;	DB	'【今日子】：早く決めないと、かわいそうよ、あの子達。'
	DB	"Kyoko:  You've got to hurry up and decide. You're only"
	DB	CR
	DB	"hurting them by doing this."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ...................................."
	DB	NEXT
;	DB	'【今日子】：君が一番エッチしたいって思う娘は誰なの？'
	DB	"Kyoko:  .......Which woman do you want to have sex with"
	DB	CR
	DB	"the most?"
	DB	NEXT
;	DB	'【%001】：なっ・・・！'
	DB	"%001:  What...?!"
	DB	NEXT
;	DB	'【今日子】：ほらほら、照れてないでおねーさんにだけ教えてごらん？'
	DB	"Kyoko:  Don't be shy. Everyone likes sex, %001. We're"
	DB	CR
	DB	"all human."
	DB	NEXT
;	DB	'（全く・・・なんて酒グセ悪いんだ！）'
	DB	"I can't believe her sometimes!"
	DB	FLG,F_COPYI,11,1
	DW	0000H

M22:		;話す　今日子
;	DB	'【今日子】：教えてくれなきゃ、あの夜のことみんなに言いふらすわよ。'
	DB	"Kyoko:  If you don't tell me who, I'll tell them all about"
	DB	CR
	DB	"the night we spent together."
	DB	NEXT
;	DB	'【%001】：・・・あんた・・・鬼だ・・・'
	DB	"%001:  .......You're such a bitch!"
	DB	NEXT
;	DB	'【今日子】：んっふっふ、さぁどーするぅ？'
	DB	"Kyoko:  Heeheehee. Well, what are you going to do?"
	EF_SET 101
	DW	0000H

M23:		;話す　伸幸
;	DB	'【%001】：親父、お年玉は？'
	DB	"%001:  Dad, what about paying the women for helping"
	DB	CR
	DB	"today?"
	DB	NEXT
;	DB	'【伸幸】：そうだった、みんなに昨日のバイト代を上げよう。'
	DB	"Nobuyuki:  That's right. I almost forgot."
	DB	NEXT
;	DB	'【鈴子】：・・・やっぱり、受け取れません。気持ちだけ、いただいておきます。'
	DB	"Reiko:  No, I can't take the money. Thanks anyway, though."
	DB	NEXT
;	DB	'【伸幸】：お正月に遠慮なんかしちゃいかんよ。',CR,'これはおじさんからみんなへのお年玉だ。'
	DB	"Nobuyuki:  It's the new year, when young people get money"
	DB	CR
	DB	"from old people. Go ahead and take it."
	DB	NEXT
;	DB	'「お年玉」と聞くと、みんなは納得したらしい。'
	DB	"Grudgingly, they all accept the money."
	DB	FLG,F_COPYI,12,1
	DW	0000H

M24:		;話す　伸幸
;	DB	'【%001】：・・・ちょっと待て！ってことは・・・'
	DB	"%001:  Wait? What about me?"
	DB	NEXT
;	DB	'【伸幸】：お前にもちゃんとやるぞ、ほら、お年玉。'
	DB	"Nobuyuki:  Here you go, son."
	DB	NEXT
;	DB	'【伸幸】：お嬢ちゃん、君にもあげよう。ハイ、お年玉。'
	DB	"Nobuyuki:  Here, miss, you can have some too."
	DB	NEXT
;	DB	'【亜希】：あたし・・・もらえないわ。大掃除手伝ってないもの。'
	DB	"Aki:  I can't. I didn't help out with the cleaning today."
	DB C_BLD,C_N_ON,2,2
	DB C_BLD,C_N_OFF,2,3
	DW	0000H

M_EXIT:		;
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,5,255,101,102,103,104
	DB FLG,F_EXIT,255
	DB	NEXT
	B_O B_FADE
;	DB	'・・・そんなこんなで大晦日の夜は過ぎて行った。'
	DB	"This is how New Year's Eve passed for all of us."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	"...................................."
	DB	NEXT
;	DB	'そして・・・１月１日。'
	DB	"Then it was January first."
	DB	NEXT
	BAK_INIT 'AB_01_1'
	B_P1 B_SUDA
	DB BUF,B_COPY01
	TU_CG 'CT09',0,0,0,3
	T_CG 'CT10',0,0,30,5
	DB ANI,A_ON,3
;	DB	'【鈴子】：色々と、ご迷惑をおかけしました。'
	DB	"Reiko:  Thanks for having us over, Mrs. Yamagami."
	DB	NEXT
;	DB	'【英美】：い～えぇ、大掃除も手伝ってもらっちゃったし、助かっちゃったわぁ。'
	DB	"Hidemi:  No, thank you for coming. And thanks for helping with"
	DB	CR
	DB	"the cleaning like you did."
	DB	NEXT
;	DB	'【今日子】：やっぱお正月は大勢でお祝いしないとネ！'
	DB	"Kyoko:  New Year's is more fun when you spend it with a"
	DB	CR
	DB	"lot of people!"
	DB	NEXT
;	DB	'【清美】：そうですわね、こんなに楽しいお正月は初めてのような気がしますわ。'
	DB	"Kiyomi:  That's true. I haven't enjoyed New Year's this"
	DB	CR
	DB	"much in a long time."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_N_ON,2,1
	DB C_BLD,C_N_OFF,2,2
	DW	0000H


end
