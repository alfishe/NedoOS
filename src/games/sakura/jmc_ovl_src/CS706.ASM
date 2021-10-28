;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　７０６
;		鈴子の誕生日　自室

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'話す',0
VV1:	DB	1,	"TALK",0
;VV2:	DB	2,	'思い出す',0
VV2:	DB	2,	"REMEMBER",0
;VV3:	DB	3,	'着替える',0
VV3:	DB	3,	"GET DRESSED",0

;NN1:	DB	1,	'英美',0
NN1:	DB	1,	"HIDEMI",0
;NN2:	DB	2,	'過去の恐怖',0
NN2:	DB	2,	"PAST FEARS",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5, M6, M7		;話す　英美６
S2:		DW	VV2, NN2,  2, M8, M9, M10, M11, M12, M13		;思い出す　過去の恐怖６
S3:		DW	VV3, -1,  3, M14, M15, M16		;着替える３

M1:
	DB	BGM,4
	BAK_INIT 'AB_38_1'
	DB BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DB	NEXT
;	DB	'【%001】：・・・・・・今、何時だ・・・・・・？'
	DB	"%001:  What time is it...?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..................."
	DB	NEXT
;	DB	'【%001】：じゅっ、じゅうにじぃ！？'
	DB	"%001:  Twelve o'clock?!"
	DB	NEXT
;	DB	'【%001】：・・・なんてこった、早く学校に行かないと・・・！'
	DB	"%001:  Man, what the hell? I better get to school fast!"
	DB	NEXT
	T_CG 'CT10',0,0,15,0
;	DB	'【英美】：あらしゅ～うちゃん、起きたの？'
	DB	"Hidemi:  Oh Shu-chan, are you awake?"
	DB	NEXT
;	DB	'【%001】：・・・か、かーちゃん・・・！'
	DB	"%001:  M- Mom...!"
	DB	NEXT
;	DB	'・・・や・・・やばいぃぃ・・・'
	DB	"...Oh shit..."
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_ON,3
	DW	0000H

M2:		;話す　英美１
;	DB	'【英美】：しゅうちゃん、気分はどう？'
	DB	"Hidemi:  Shu-chan, how do you feel?"
	DB	NEXT
;	DB	'【%001】：・・・も～すっげー元気！快適！パーフェクト！！'
	DB	"%001:  Marvelous! Great! Fantastic!"
	DB	NEXT
;	DB	'【英美】：・・・そぅお？何だかぁ、まだ顔が赤いわよぉ？'
	DB	"Hidemi:  Really? Then why is your face still all red?"
	DB	NEXT
;	DB	'【%001】：そんな事はない！絶対ない！！'
	DB	"%001:  It isn't! It can't be!!"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;話す　英美２
;	DB	'【%001】：・・・とにかく！俺は着替えなきゃなんないんだから出て行ってよ！'
	DB	"%001:  Anyway, I have to put on some clothes and go out!"
	DB	NEXT
;	DB	'【英美】：あらぁ、どこ行くのぉ？'
	DB	"Hidemi:  Oh, and where are you going?"
	DB	NEXT
;	DB	'【%001】：学校に決まってるだろ。'
	DB	"%001:  School, obviously."
	DB	NEXT
;	DB	'【英美】：・・・でもぉ、学校には「しゅうちゃん風邪だからお休み」って、英美言っちゃったんだけどぉ。'
	DB	"Hidemi:  But I already called the school and told them you"
	DB	CR
	DB	"were home sick with a cold today."
	DB	NEXT
;	DB	'【%001】：・・・別にいいだろ、行ったって。'
	DB	"%001:  But I'd rather go to school."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;話す　英美３
;	DB	'【英美】：・・・でもでもぉ、しゅうちゃん風邪なのにぃ。'
	DB	"Hidemi:  But my little Shu-chan has a cold."
	DB	NEXT
;	DB	'【%001】：・・・だからぁ、もう治ったってば。'
	DB	"%001:  I'm completely well again."
	DB	NEXT
;	DB	'【英美】：・・・ホントにぃ？'
	DB	"Hidemi:  Really?"
	DB	NEXT
;	DB	'【%001】：もちろん。'
	DB	"%001:  Of course."
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;話す　英美４
;	DB	'【英美】：・・・じゃあじゃあ、英美がお熱計ってあげる。'
	DB	"Hidemi:  Well, here, let me take your temperature. If you"
	DB	CR
	DB	"don't have a fever, then you can go to school."
	DB	NEXT
;	DB	'【%001】：・・・大丈夫だよ。熱なんかねぇって。'
	DB	"%001:  I'm fine. I don't have a fever, okay?"
	DB	NEXT
;	DB	'【英美】：だからぁ、英美が計ってあげるってばぁ。'
	DB	"Hidemi:  Well, just let me check for you."
	DB	NEXT
;	DB	'【%001】：・・・いいっての！'
	DB	"%001:  No!"
	DB	NEXT
;	DB	'【英美】：じゃあ学校行かせてあげない。'
	DB	"Hidemi:  Well, then you can't go to school."
	DB	NEXT
;	DB	'【%001】：・・・又そーゆー小学生みたいな事を・・・'
	DB	"%001:  You'd think I was still a little kid."
	DB	FLG,F_COPYI,1,4
	DW	0000H

M6:		;話す　英美５
;	DB	'【英美】：しゅうちゃんこそぉ、ど～してお熱計らせてくれないのぉ？'
	DB	"Hidemi:  Shu-chan, why won't you let me take your temperature?"
	DB	PAUSE,CR
;	DB	'・・・やっぱり治ってないんでしょ？'
	DB	"Probably because you know you're not well yet?"
	DB	NEXT
;	DB	'【%001】：・・・そ、そんな事はない。'
	DB	"%001:  N- No, that's not it."
	DB	NEXT
;	DB	'【英美】：じゃあ計らせて。'
	DB	"Hidemi:  Then let me check it."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................."
	DB	NEXT
;	DB	'・・・こ、こいつは参ったぞ・・・'
	DB	"...Oh no, I'm doomed..."
	DB	NEXT
;	DB	'どうしよう・・・・・・'
	DB	"What to do..."
	DB	NEXT
;	DB	'【英美】：スキありっ！おでここっつんこ☆'
	DB	"She reached out for me and put me in a headlock, feeling"
	DB	CR
	DB	"my forehead."
	DB	FLG,F_COPYI,1,5
	DW	0000H

M7:		;話す　英美６
;	DB	'【英美】：・・・んもうしゅうちゃんたらぁ、やっぱりお熱あるんじゃな～い。'
	DB	"Hidemi:  Hmmm, Shu-chan, you sure do have a fever, don't"
	DB	CR
	DB	"you?"
	DB	NEXT
;	DB	'【英美】：・・・しゅ～うちゃあぁぁぁん。'
	DB	"Hidemi:  Shu-ooooo."
	DB	NEXT
;	DB	'【%001】：か、かーちゃん・・・まさか・・・！'
	DB	"%001:  M-Mom, really...!"
	DB	NEXT
;	DB	'【英美】：・・・英美、うれしいっ☆'
	DB	"Hidemi:  Hidemi's so happy!"
	DB	NEXT
	B_P1 B_NORM
;	DB	'ぱたぱたぱたぱたぱた'
	DB	"Pitterpatterpatter"
	DB	NEXT
;	DB	'【%001】：・・・わーっ！かーちゃん待ってくれ～っ！！'
	DB	"%001:  Hey! Mom, wait!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【%001】：行って・・・しまった・・・'
	DB	"%001:  She's gone."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_OFF,2
	DW	0000H

M8:		;思い出す　過去の恐怖１
;	DB	'・・・・・・そう、アレは確か・・・・・・小１の夏の出来事だった。'
	DB	"It happened last summer..."
	DB	NEXT
;	DB	'俺は、一寸した夏風邪をひいた。そう、本当に大した事のない、'
	DB	"I had caught a bit of a summer cold. It was no big deal,"
	DB	CR
	DB	"the kind of thing that you could sleep off in two days"
	DB	CR
	DB	"or so."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M9:		;思い出す　過去の恐怖２
;	DB	'それでも、風邪であるからには熱くらいは出る。それに、俺はこれが'
	DB	"But since it was a cold, I also got a fever."
	DB	NEXT
;	DB	'・・・・・・しかし、だからと言って氷風呂に入れるか？'
	DB	"So she put me into an ice-cold bath."
	DB	NEXT
;	DB	'その結果どうなったかというと・・・ま、御想像の通りって奴だ。'
	DB	"As for what happened as a result of that... Well, I'll"
	DB	CR
	DB	"leave it to your imagination."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M10:		;思い出す　過去の恐怖３
;	DB	'それで終わってりゃあ、未だ可愛かった。'
	DB	"Then, that night..."
	DB	NEXT
;	DB	'冷やすのがダメだったからって、布団五枚重ねの上にストーブまで焚きやがって。我慢大会じゃね～んだぞ。'
	DB	"I wasn't supposed to get cold, so Mom piled five blankets"
	DB	CR
	DB	"on top of me and turned the furnace up."

;	DB	NEXT

;	DB	"I didn't think it was supposed to be a test of how much I could"
;	DB	CR
;	DB	"stand."
	DB	NEXT
;	DB	'御陰様で、部屋の中で熱射病になるところだった。'
	DB	"Thanks to that, I actually got heatstroke."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M11:		;思い出す　過去の恐怖４
;	DB	'おまけに、ほとんど始終付きっきりでほこほこ食い物詰め込みやがるもんだから、腹も壊しちまった。'
	DB	"And what's more, she kept stuffing morsels of food into"
	DB	CR
	DB	"me, so my stomach got upset too."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".............................."
	DB	NEXT
;	DB	'こ～して改めて思い出してみると、良く生きてるよな俺。'
	DB	"When I think back on that, it's amazing I'm still alive."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M12:		;思い出す　過去の恐怖５
;	DB	'まったく、アレで昔看護学校行ってたってんだから信じられん。'
	DB	"I just can't believe it when she says she went to nursing"
	DB	CR
	DB	"school."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"...................................."
	DB	NEXT
;	DB	'そ～か、だから卒業出来なかったんだな。'
	DB	"Oh right, but they didn't let her graduate."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M13:		;思い出す　過去の恐怖６
;	DB	'・・・しかし実際のところ、諦めてね～んだよな、未だに・・・'
	DB	"...But she still hasn't really given up on it..."
	DB	NEXT
;	DB	'「白衣の天使」に憧れるのは勝手だけど、犠牲者を出さないで欲しいぞ。'
	DB	"I don't mind her dreaming about being an angel in white,"
	DB	CR
	DB	"just as long as I'm not her victim."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"............................."
	DB	NEXT
;	DB	'なんて呑気に思い出してる場合か！今度あんな目に合ったら命がね～ぞ！'
	DB	"What am I doing here, daydreaming, when I'm about to be"
	DB	CR
	DB	"sacrificed by my mother!"
	DB C_BLD,C_V_OFF,3
	DB C_BLD,C_V_ON,2
	DW	0000H

M14:		;着替える１
;	DB	'【%001】：・・・と、とにかく早く逃げないと・・・！'
	DB	"%001:  Okay, I have to get out of here fast!"
	DB	NEXT
;	DB	'俺は全速力で着替えようとした。'
	DB	"I started to get dressed at top speed."
	DB	NEXT
;	DB	'が。'
;	DB	"Eh."
;	DB	NEXT
;	DB	'【%001】：・・・あ・・・ら・・・？'
	DB	"%001:  .....What?"
	DB	NEXT
	DB	"*CREAK*",GATA,1," *CREAK*",GATA,1," *CREAK*",GATA,1
	DB	NEXT
;	DB	'【%001】：・・・・・・くそぉ、言う事聞きやがれ！俺の身体！！'
	DB	"%001:  Shit! C'mon, body, listen to me!"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M15:		;着替える２
;	DB	'【%001】：・・・ふ・・・服を・・・！'
	DB	"%001:  Must...get...dressed!"
	DB	NEXT
	DB	'*CREAK*',GATA,1,' *CREAK*',GATA,1,' *CREAK*',GATA,1
	DB	NEXT
;	DB	'【%001】：・・・・・・ち、ちくしょう・・・・・・何でこんなにタンスが遠いんだ！？'
	DB	"%001:  Dammit... Why does the closet have to be so far",CR,"away?!"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M16:		;着替える３
;	DB	'【%001】：・・・く、くそっ！動け！動きやがれ！'
	DB	"%001:  Move, body!"
	DB	NEXT
;	DB	'くら,GATA,1,くら,GATA,1,くら,GATA,1,くらっ'
	DB	"*CREAK* ",GATA,1,"*CREAK* ",GATA,1,"*CREAK* ",GATA,1
	DB	NEXT
;	DB	'【%001】：・・・・・・ううっ・・・・・・'
	DB	"%001:  Ooooooh..."
	DB	NEXT
	T_CG 'CT10',0,0,15,1
;	DB	'【英美】：・・・しゅうちゃん。'
	DB	"Hidemi:  ...Shu-chan!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'【%001】：か・・・かーちゃん・・・'
	DB	"%001:  M- Mom......."
	DB	NEXT
;	DB	'・・・・・・万事休す・・・・・・'
	DB	".....It's all over...."
	DB	NEXT
;	DB	'・・・親父・・・かーちゃん・・・先立つ不孝を許してくれ・・・'
	DB	"Dad.....Mom.....Forgive me for dying before you...."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".........."
	DB	NEXT
;	DB	'親父はともかく、かーちゃんには許してもらう必要はないな。'
	DB	"Well Dad, at least, I don't have to ask forgiveness from"
	DB	CR
	DB	"Mom."
	DB	NEXT
;	DB	'【英美】：・・・しゅうちゃん、ごめんねぇ。英美、伸ちゃんの頼みでぇ'
	DB	"Hidemi:  Sorry, Shu-chan. Your father has asked me to do"
	DB	CR
	DB	"something for him, so I have to leave for a while."
	DB	NEXT
;	DB	'【%001】：・・・・・・へ？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【英美】：だからぁ、大人しく寝ててねぇ。英美のお・ね・が・い☆'
	DB	"Hidemi:  So be good and go to sleep. Please?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .............."
	DB	NEXT
;	DB	'【%001】：た・・・助かった・・・'
	DB	"%001:  I've been saved!"
	DB	NEXT
;	DB	'【英美】：じゃあねん☆'
	DB	"Hidemi:  Bye!"
	DB	NEXT,GATA,1
;	DB	'俺は一気に気が抜け・・・タコか何かのよ～に床に広がった。'
	DB	"I stopped holding my breath, and lay spreadeagled on"
	DB	CR
	DB	"the floor."
	DB	NEXT
	DB	SINARIO,'CS707.OVL',0
	DW	0000H


end