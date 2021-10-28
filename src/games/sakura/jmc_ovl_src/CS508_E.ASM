;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０８＿Ｅ
;		瑠璃のいる風景

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN3,NN4,-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0
;VV4:	DB	4,	'戻る',0
VV4:	DB	4,	'GO BACK',0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	'RURI',0
;NN2:	DB	2,	'川',0
NN2:	DB	2,	' RIVER',0
;NN3:	DB	3,	'神様',0
NN3:	DB	3,	'GOD',0
;NN4:	DB	4,	'家族',0
NN4:	DB	4,	'FAMILY',0
;NN5:	DB	5,	'戻る',0
NN5:	DB	5,	'GO BACK',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　瑠璃
S2:		DW	VV1, NN2,  2, M4, M5, M6		;見る　川
S3:		DW	VV2, NN1,  3, M7, M8, M9, M10, M11, M12, M13, M14, M15		;話す　瑠璃９(152=1)
S4:		DW	VV3, NN3,  4, M16, M17, M18		;聞く　神様
S5:		DW	VV3, NN4,  5, M19, M20, M21, M22		;聞く　家族
S6:		DW	VV4, -1,  6, M23, M24		;戻る２


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_10_1'
	DB	BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'【%001】：こっちの方にいるって聞いたけど・・・'
	DB	"%001:  She's supposed to be over here..."
	DB	NEXT
;	DB	'【%001】：・・・・・・いた！'
	DB	"%001:  .....There she is!"
	DB	NEXT
	T_CG 'CT05','T',0,10,1
;	DB	'彼女は、いつか見掛けた時と同様、身じろぎもしないで崖を見下ろしていた。'
	DB	"She looking down the cliff, looking at the water. Just"
	DB	CR
	DB	"like that day by the river."
	DB G_FLG,G_COPYF,159,159
	DB C_BLD,C_V_ON,3	;聞く
	DW	0000H

M2:		;見る　瑠璃
;	DB	'立入禁止の柵にひじをついて、ぼんやりと向こうを眺めてる。'
	DB	"She's leaning up against the fence, staring at the water."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　瑠璃
;	DB	'・・・・・・・・・'
	DB	"................................."
	DB	NEXT
;	DB	'時間が止まってるみたいだ・・・'
	DB	"It's like time has stopped for her..."
	DB	FLG,F_COPYI,1,0
	DW	0000H

M4:		;見る　川
;	DB	'白水さんの隣に立つと、崖の向こうに川が見えた。'
	DB	"Standing next to Ruri, I can see the river on the other"
	DB	CR
	DB	"side of the cliff."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;見る　川
;	DB	'・・・これといって何の変哲もない川だ。昨日の大雨で増水してる。'
	DB	"It your usual, average river. It's full of water"
	DB	CR
	DB	"from the rain yesterday."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;見る　川
;	DB	'（飽きた・・・）'
	DB	"I'm tired of looking at the river."
	DB	NEXT
;	DB	'（・・・白水さん、よく何時間も見てられるな・・・）'
	DB	"How can she just stare at it for hours and hours?"
	DW	0000

M7:		;話す　瑠璃１
;	DB	'【%001】：やぁ、白水さん。'
	DB	"%001:  Hey, Ruri."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............................"
	DB	NEXT
;	DB	'【%001】：何してるの、こんな所で。'
	DB	"%001:  What are you doing?"
	DB	NEXT
;	DB	'【瑠璃】：・・・川を見てるの。'
	DB	"Ruri:  .....Staring at the river."
	DB FLG,F_COPYI,3,1	;
	DW	0000H


M8:		;話す　瑠璃２
;	DB	'【%001】：川が好きなの？'
	DB	"%001:  Do you like rivers?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・見てると、落ち着くの。'
	DB	"Ruri:  It's peaceful. Looking at it puts me at ease."
	DB	NEXT
;	DB	'【%001】：・・・ふぅん・・・'
	DB	"%001:  I see."
	DB FLG,F_COPYI,3,2	;話す　瑠璃３
	DB FLG,F_EXIT,159	;
	DB FLG,F_COPYI,3,7	;話す　瑠璃８

M9:		;話す　瑠璃３
;	DB	'【%001】：・・・・・・・・・・・・'
	DB	"%001:  ..................................."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ..................................."
	DB	NEXT
;	DB	'（・・・何か話題はないか、話題は？）'
	DB	"Isn't there anything I can talk about with her?"
	DB	FLG,F_COPYI,3,3
	DW	0000H

M10:		;話す　瑠璃４
;	DB	'（う～ん・・・話題、話題、話題・・・）'
	DB	"Hmm. What can we talk about? "
	DB	NEXT
;	DB	'【瑠璃】：・・・水の流れは、人のうつろい・・・'
	DB	"Ruri:  A river...is like a person."
	DB	NEXT
;	DB	'（え？）'
	DB	".........Huh?"
	DB	NEXT
;	DB	'【瑠璃】：人の運命は川面の泡沫（うたかた）に等しいもの。',CR,'流れるままに、流れてゆく・・・'
	DB	"Ruri:  A person's life is like the foam on a river's"
	DB	CR
	DB	"surface. It flows, ever onward."
	DB	NEXT
;	DB	'（・・・独り言？それとも俺に話し掛けてるのか？）'
	DB	"Is she talking to herself? Or to me?"
	DB	NEXT
;	DB	'（・・・・・・）'
	DB	"................................"
	DB	NEXT
;	DB	'（今のって、ひょっとして転校ばっかりしてる自分のことを',CR,'言ってたのか？）'
	DB	"Maybe she's talking about herself. She's changed schools"
	DB	CR
	DB	"so many times, she must feel like foam on a river?"
	DB C_BLD,C_V_OFF,3	;聞く
	DB	FLG,F_COPYI,3,4
	DW	0000H

M11:		;話す　瑠璃５
;	DB	'【%001】：・・・どんな川も、海につながってる。'
	DB	"%001:  All rivers are connected to the sea."
	DB	NEXT
;	DB	'白水さんにも落ち着ける場所があるさ。'
	DB	"%001:  It's a place where you can be at peace...where you ",CR,"can rest."
	DB	NEXT
;	DB	'【瑠璃】：・・・それなら、知ってる。'
	DB	"Ruri:  Yes, I know."
	DB	NEXT
;	DB	'【%001】：・・・え？'
;	DB	"%001:  Huh?"
;	DB	NEXT
;	DB	'【瑠璃】：私が最後に落ち着ける場所。'
	DB	"Ruri:  A place where I can rest.....forever."
	DB	NEXT
;	DB	'【瑠璃】：・・・神様のいるところよ。'
	DB	"Ruri:  Where God is."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ...................................."
	DB	FLG,F_COPYI,3,5
	DW	0000H


M12:		;話す　瑠璃６
;	DB	'【%001】：・・・・・・・・・白水さん・・・早まるな！'
	DB	"%001:  Wait, Ruri! Don't do it!"
	DB	NEXT
;	DB	'【瑠璃】：・・・何を？'
	DB	"Ruri:  Don't do what?"
	DB	NEXT
;	DB	'（・・・どうやら取り越し苦労だったらしい。）'
	DB	"Oh. For a moment, I thought she was going to jump."
	DB	FLG,F_COPYI,3,6
	DW	0000H

M13:		;話す　瑠璃７
;	DB	'【%001】：・・・・・・・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'（・・・話の出来る雰囲気じゃないな。）'
	DB	"I feel weird talking to her now."
	DB	NEXT
;	DB	'（・・・）'
	DB	"..................."
	DB	NEXT
;	DB	'（・・・いつもそうか。）'
	DB	"That's normal for her, though."
	DW	0000H



M14:		;話す　瑠璃８(159=1)
;	DB	'【瑠璃】：何か用？'
	DB	"Ruri:  Did you want me for anything?"
	DB	NEXT
;	DB	'【%001】：・・・いや・・・別に。'
	DB	"%001:  No, not really."
	DB	NEXT
;	DB	'【瑠璃】：・・・用が無いのに、なぜここにいるの？'
	DB	"Ruri:  Then why did you come up here?"
	DB	NEXT
;	DB	'【%001】：・・・理由がないと、ここにいちゃいけないのか？'
	DB	"%001:  There was no particular reason. Do you want me to leave?"
	DB	NEXT
;	DB	'【瑠璃】：・・・あなたには、他に行ける場所があるでしょう。'
	DB	"Ruri:  .....You have other places to go."
	DB	FLG,F_COPYI,3,8
	DW	0000H

M15:		;話す　瑠璃９(159=1)
;	DB	'【%001】：・・・・・・・・・いい天気だね。'
	DB	"%001:  It's really nice out."
	DB	NEXT
;	DB	'【瑠璃】：・・・そう。'
	DB	"Ruri:  Yes."
	DW	0000H


M16:		;聞く　神様
;	DB	'【%001】：・・・白水さんは、神様を信じてるんだって？'
	DB	"%001:  Ruri, do you believe in God?"
	DB	NEXT
;	DB	'【瑠璃】：・・・そうよ。・・・あなたは信じてないの？'
	DB	"Ruri:  I do. What about you?"
	DB	NEXT
;	DB	'【%001】：ちょっと・・・宗教にはうといんで・・・'
	DB	"%001:  I'm not sure. I'm not into religion."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M17:		;聞く　神様
;	DB	'【%001】：あ、それだったらさ、吉田と話があうんじゃないかな。ほら、あいつ見習いシスターだし。'
	DB	"%001:  Maybe you should talk with Seia."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ........................"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M18:		;聞く　神様
;	DB	'【%001】：白水さんは、何で神様を信じてるんだ？'
	DB	"%001:  .....Why do you believe in God?"
	DB	NEXT
;	DB	'【瑠璃】：・・・あなたはなぜ信じないの？'
	DB	"Ruri:  Why don't you?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................................"
	DW	0000H

M19:		;聞く　家族
;	DB	'【%001】：白水さんのご家族ってさ、何してる人なの？'
	DB	"%001:  What does your family do, anyway?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ................................"
	DB	NEXT
;	DB	'【%001】：ちなみに俺んち、電器屋やってるんだ。'
	DB	"%001:  My family runs an electronics store."
	DB	NEXT
;	DB	'【%001】：・・・なんて、どうだっていいよなハハハ。'
	DB	"%001:  It's really nothing, of course."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M20:		;聞く　家族
;	DB	'【瑠璃】：・・・何もしてないわ。'
	DB	"Ruri:  We don't do anything."
	DB	NEXT
;	DB	'【%001】：・・・それって・・・働いてないってこと？'
	DB	"%001:  Do you mean, your father doesn't work?"
	DB	NEXT
;	DB	'【瑠璃】：そうよ。'
	DB	"Ruri:  That's right."
	DB	NEXT
;	DB	'【%001】：・・・へぇぇ・・・すごい。'
	DB	"%001:  ....Really? That's interesting."
	DB	NEXT
;	DB	'【瑠璃】：そう？'
	DB	"Ruri:  You think so?"
	DB	FLG,F_COPYI,5,2
	DW	0000H

M21:		;聞く　家族
;	DB	'【%001】：それで・・・どうして転校を？'
	DB	"%001:  So why did you transfer to our school?"
	DB	NEXT
;	DB	'【%001】：いやその・・・家の都合で転校して来たって聞いたから、ちょっと気になっただけ。'
	DB	"%001:  I mean, I heard you came to our school for 'family'"
	DB	CR
	DB	"reasons, but I never knew what that meant..."
	DB	NEXT
	K_CG 'CT05','D',10,2
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ..........................."
	DB	NEXT
;	DB	'【%001】：・・・白水さん？'
	DB	"%001:  Ruri?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .........................."
	DB	NEXT
;	DB	'（・・・しまった、いらんこと聞いちまったかな・・・）'
	DB	"I guess I asked something too private."
	DB FLG,F_COPYI,6,1	;戻る２
	DB	FLG,F_COPYI,5,3
	DW	0000H

M22:		;聞く　家族
;	DB	'（・・・まずったな・・・怒らせたかもしれない。）'
	DB	"I wonder if she's mad at me now."
	DB	NEXT
;	DB	'（いくらなんでも、無神経すぎたな・・・）'
	DB	"I shouldn't have been so inconsiderate."
	DW	0000H

M23:		;戻る１
;	DB	'（・・・これ以上邪魔しちゃ、悪いかな。）'
	DB	"I guess I shouldn't bother her anymore."
	DB	NEXT
;	DB	'俺は誠のところに戻ることにした。'
	DB	"I get up to leave."
	DB	NEXT
;	DB	'【%001】：それじゃ、俺行くから。'
	DB	"%001:  Well, guess I'll head back."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ................................."
	DB	NEXT
	DB G_FLG,G_COPYI,159,1
	DB SINARIO,'CS509.OVL',0

M24:		;戻る２
;	DB	'（・・・悪いこと聞いちまったかな・・・）'
	DB	".....I shouldn't have asked her such a private question."
	DB	NEXT
;	DB	'俺は誠のところに戻ることにした。'
	DB	"I get ready to go back."
	DB	NEXT
;	DB	'【%001】：ごめん・・・。'
	DB	"%001:  ....I'm sorry."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .............................."
	DB	NEXT
;	DB	'【%001】：・・・悪ィな、邪魔して。俺、もう行くから。'
	DB	"%001:  I mean, sorry for bothering you. I'll go back now."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .............................."
	DB	NEXT
	B_O B_SUDA
	DB SINARIO,'CS509_E.OVL',0
	DW	0000H


end
