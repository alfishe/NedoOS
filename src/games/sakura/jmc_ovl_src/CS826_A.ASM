;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　
;		鈴子と踊る

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'踊る',0
VV4:	DB	4,	'DANCE',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'まわり',0
NN2:	DB	2,	'AROUND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子
S2:		DW	VV1, NN2,  2, M4		;見る　まわり
S3:		DW	VV2, NN1,  3, M5, M6		;話す　鈴子
S4:		DW	VV3, -1,  4, M7		;考える
S5:		DW	VV4, -1,  5, M8, M9, M10, M11		;踊る


;イニシャルメッセージ
M1:
	DB	BGM,24
	BAK_INIT 'AB_27_2'
	DB BUF,B_COPY01
	T_CG "CT01","C",0,10,1
;	DB	'【%001】：あ・・・鈴子さん。'
	DB	"%001:  Um, Reiko?"
	DB	NEXT
;	DB	'【鈴子】：は・・・な、なあに？'
	DB	"Reiko:  Yes?"
	DB	NEXT
;	DB	'【%001】：え～と、その・・・'
	DB	"%001:  Um....well..."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・？'
	DB	"Reiko:  .......I'm waiting."
	DB	NEXT
;	DB	'【%001】：俺に、ダンスを教えて欲しいんだけど・・・いいかな？'
	DB	"%001:  Would you teach me how to dance?"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ..............."
	DB	NEXT
;	DB	'【%001】：・・・だ、ダメかな・・・？'
	DB	"%001:  ...........Well, nevermind."
	DB	NEXT
;	DB	'【鈴子】：いっ、いいえ、もちろんＯ.Ｋ.よ！'
	DB	"Reiko:  No! No, I don't mind!"
	DB	NEXT
;	DB	'【%001】：ホ、ホントに？'
	DB	"%001:  Really?"
	DB	NEXT
;	DB	'【鈴子】：ええ！さ、行くわよ！'
	DB	"Reiko:  Sure, let's go!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"......................................."
	DB	NEXT
	DB	BGM,8
	E_CG B_FADE,'AE_036' 
;	DB	'俺は、鈴子さんにダンスを教わっている。'
	DB	"Reiko's teaching me how to dance."
	DB	NEXT
;	DB	'正直な話、俺はダンスができない。'
	DB	"When I told her I didn't know how to dance, I was telling"
	DB	CR
	DB	"the truth."
	DB	NEXT
;	DB	'・・・単に経験がなかったせいだったりする。'
	DB	"I just never had the chance to learn."
	DB	NEXT
;	DB	'いざ踊ってしまえばどうにかなる、とか思ったのは甘かったらしい。'
	DB	"I always thought it was something you could pick up without"
	DB	CR
	DB	"any special lessons, but I was wrong."
	DB	NEXT
;	DB	'お世辞にも讃められたモンじゃない俺の足どりに、鈴子さんは辛抱強く付き合ってくれている。'
	DB	"Reiko's a patient teacher."
	DB	NEXT
;	DB	'踊れないのにこんな事をしているのは恥ずかしいけど、鈴子さんの方がもっと恥ずかしいだろう。'
	DB	"It's kind of embarrassing... I don't know how to dance,"
	DB	CR
	DB	"but I'm doing it anyway."
	DB	NEXT
;	DB	'・・・あ、でも、少しづつ分かってきた気がするぞ・・・。'
	DB	"But I think I'm getting the hang of this."
	DW	0000H

M2:		;見る　鈴子
;	DB	'さっきから俺にダンスを教えてくれている。'
	DB	"She's teaching me how to dance."
	DB	NEXT
;	DB	'【鈴子】：ほら、ぼーっとしないの！'
	DB	"Reiko:  Hey! Pay attention!"
	DB	NEXT
;	DB	'【%001】：は、はい！'
	DB	"%001:  Sorry!"
	DB	NEXT
;	DB	'・・・怒られてしまった・・・'
	DB	"She's a strict teacher."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　鈴子
;	DB	'よーく見てないとわかんないけど・・・'
	DB	"I'd better not stare at her."
	DW	0000H

M4:		;見る　まわり
;	DB	'今の俺に、そんな余裕はない・・・'
	DB	"I can't look around. I've got to concentrate on dancing."
	DW	0000H

M5:		;話す　鈴子
;	DB	'【%001】：ごめんな、鈴子さん・・・'
	DB	"%001:  I'm sorry, Reiko."
	DB	NEXT
;	DB	'【鈴子】：なに言ってるの。これくらい、大したことじゃないわよ。'
	DB	"Reiko:  What are you talking about? I don't care that you"
	DB	CR
	DB	"were staring at me."
	DB	NEXT
;	DB	'【鈴子】：そんなことよりほら、次はこうよ。'
	DB	"Reiko:  Let's go on to the next step."
	DB	NEXT
;	DB	'【%001】：え？あ、こう？'
	DB	"%001:  Is this right?"
	DB	NEXT
;	DB	'【鈴子】：そう、その調子！'
	DB	"Reiko:  Yes, that's good!"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M6:		;話す　鈴子
;	DB	'【%001】：ありがと、鈴子さん・・・'
	DB	"%001:  Thanks, Reiko..."
	DB	NEXT
;	DB	'【鈴子】：お礼を言うのは、まだ早いわよ？'
	DB	"Reiko:  Isn't it a little early to be thanking me? I'm"
	DB	CR
	DB	"not finished teaching you yet."
	DB	NEXT
;	DB	'【%001】：ああ・・・そうだね。'
	DB	"%001:  Oh, you're right."
	DW	0000H

M7:		;考える
;	DB	'そ、そんな余裕はないぞ・・・'
	DB	"I don't have time to think!"
	DB	NEXT
;	DB	'・・・っと。'
	DB	"If I don't concentrate on what I'm doing, I'll fall."
	DW	0000H

M8:		;踊る
;	DB	'【鈴子】：ううん、違う。こうよ、こう。ほら、１・２！'
	DB	"Reiko:  No, that's wrong. Keep your feet apart. Okay,"
	DB	CR
	DB	"one, two..."
	DB	NEXT
;	DB	'【%001】：こ・・・こう？'
	DB	"%001:  Is this right?"
	DB	NEXT
;	DB	'【鈴子】：そうそう。その調子・・・って、ちょっと！'
	DB	"Reiko:  Yes, that's good. Oh, wait a minute!"
	DB	NEXT
;	DB	'【%001】：え？なんか違って・・・あ、そか。右足、こう・・・と。'
	DB	"%001:  Oh, my right foot should be like this."
	DB	NEXT
;	DB	'【鈴子】：もー、なんでさっき出来たコトがもう出来なくなってる訳？'
	DB	"Reiko:  Why did you say you couldn't dance a minute ago?"
	DB	NEXT
;	DB	'【%001】：わりわり。'
	DB	"%001:  I couldn't!"
	DB	NEXT
;	DB	'【鈴子】：しょーがないなあ、もう。'
	DB	"Reiko:  .....I don't believe you."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M9:		;踊る
;	DB	'【鈴子】：そう、そう、その調子。'
	DB	"Reiko:  That's good. You're really not bad, you know."
	DB	NEXT
;	DB	'【%001】：ホ、ホントに？'
	DB	"%001:  Really?"
	DB	NEXT
;	DB	'【鈴子】：うん、ホントホント。'
	DB	"Reiko:  Yes."
	DB	NEXT
;	DB	'【%001】：そ、そっか・・・'
	DB	"%001:  Thanks..."
	DB	NEXT
;	DB	'【鈴子】：そう、その調子で・・・・・・きゃ！？'
	DB	"Reiko:  That's right... ",PAUSE," Whoops!"
	DB	NEXT,GATA,1
;	DB	'ずで～ん。'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'【%001】：いてててて・・・'
	DB	"%001:  Ouch!"
	DB	NEXT
;	DB	'【鈴子】：だ・・・大丈夫？'
	DB	"Reiko:  Are you alright?"
	DB	NEXT
;	DB	'【%001】：ん・・・大丈夫大丈夫。'
	DB	"%001:  I'm fine."
	DB	NEXT
;	DB	'【鈴子】：そう・・・だけど・・・'
	DB	"Reiko:  That's good. But why...?"
	DB	NEXT
;	DB	'【%001】：？なに？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【鈴子】：・・・なんで、あんな所で転べるの？'
	DB	"Reiko:  I was just wondering why you fell."
	DB	NEXT
;	DB	'【%001】：・・・・・・さあ？'
	DB	"%001:  I'm not sure myself."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M10:		;踊る
;	DB	'【鈴子】：うん、だんだん上手になってきたわ。'
	DB	"Reiko:  You've gotten a lot better."
	DB	NEXT
;	DB	'【%001】：そっ、そうかな。'
	DB	"%001:  Really? I don't know..."
	DB	NEXT
;	DB	'【鈴子】：・・・まだちょっと危なっかしいけど、さっきよりは随分と・・・'
	DB	"Reiko:  You're fine. You've improved a lot..."
	DB	NEXT,GATA,1
;	DB	'ずで～ん。'
	DB	"*SMASH*"
	DB	NEXT
;	DB	'【%001】：いてててて・・・'
	DB	"%001:  Ouch!"
	DB	NEXT
;	DB	'【鈴子】：・・・ねえ、すごく簡単なパートで転ぶの、もうよそうよ。'
	DB	"Reiko:  You fell again. What's wrong?"
	DB	NEXT
;	DB	'【%001】：・・・わざとじゃないんだよう。'
	DB	"%001:  I didn't fall on purpose."
	DB	FLG,F_COPYI,5,3
	DW	0000H

M11:		;踊る
;	DB	'【鈴子】：・・・すごいわね、もうほとんど完璧じゃない。'
	DB	"Reiko:  You're great. Almost perfect."
	DB	NEXT
;	DB	'【%001】：・・・鈴子さんのおかげだよ。'
	DB	"%001:  ........That's all thanks to you, Reiko."
	DB	NEXT
;	DB	'【鈴子】：え・・・・・・？'
	DB	"Reiko:  Eh.....??"
	DB	NEXT
;	DB	'【%001】：ありがと、鈴子さん。'
	DB	"%001:  Thank you, Reiko, for teaching me."
	DB	NEXT
;	DB	'【鈴子】：やだ、もう。改まっちゃって。'
	DB	"Reiko:  Oh, well, you're welcome."
	DB	NEXT
;	DB	'【%001】：・・・鈴子さ・・・・・・おわっ！？'
	DB	"%001:  ..............Reiko.........",PAUSE," Whoops!"
	DB	NEXT
;	DB	'【鈴子】：え！？'
;	DB	"Reiko:  Eh?!"
	DB	GATA,1
;	DB	'ずで～ん。'
	DB	"*BASH*"
	DB	NEXT
;	DB	'【鈴子】：・・・新手のギャグ？'
	DB	"Reiko:  Are you sure you're not doing that on purpose?"
	DB	NEXT
;	DB	'【%001】：・・・だから、わざとじゃないんだって。'
	DB	"%001:  I'm not, I swear!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"......................................"
	DB	NEXT
;	DB	'鈴子さんのリードのおかげで、俺は何とか人並み程度に踊れるようになった。'
	DB	"Thanks to Reiko leading me, I was able to dance with"
	DB	CR
	DB	"everyone else."
	DB	NEXT
;	DB	'鈴子さんは俺を優しく見守ってくれてる。その笑顔が、不意に寂しそうな表情へと代わる。'
	DB	"Reiko is gentle as she guides me through the steps."
	DB	NEXT
;	DB	'【%001】：・・・鈴子さん？'
	DB	"%001:  Reiko?"
	DB	NEXT
;	DB	'【鈴子】：・・・楽しい時間って、すぐに過ぎちゃうのね・・・'
	DB	"Reiko:  ............Good times like this end so quickly,"
	DB	CR
	DB	"don't they?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【鈴子】：あっ・・・ごめんね%001君、暗いこと言って・・・'
	DB	"Reiko:  Oh...I'm sorry, %001. I didn't mean to sound"
	DB	CR
	DB	"depressed."
	DB	NEXT
;	DB	'【%001】：・・・踊ろうよ、鈴子さん。まだ１２時の鐘は鳴ってないんだ。'
	DB	"%001:  Let's dance some more, Reiko. The bell hasn't"
	DB	CR
	DB	"struck midnight yet."
	DB	NEXT
;	DB	'【鈴子】：えっ・・・？'
	DB	"Reiko:  ......What?"
	DB	NEXT
;	DB	'【%001】：・・・美しい方、わたくしと踊っていただけますか？'
	DB	"%001:  Beautiful lady, will you give me the pleasure of"
	DB	CR
	DB	"dancing with me?"
	DB	NEXT
;	DB	'【鈴子】：・・・はい、王子さま・・・喜んで。'
	DB	"Reiko:  ......Yes, yes I would, Prince %001."
	DB	NEXT
;	DB	'月の光に照り映えて、鈴子さんの髪がきらきら輝く。',CR,'まるで、光の糸で紡がれた魔法のドレスのように・・・'
	DB	"In the moonlight, we danced. Reiko's hair looked like"
	DB	CR
	DB	"silver threads in the night sky."
	DB	NEXT
;	DB	'今夜の月を、俺はずっと忘れないだろう。'
	DB	"I'll never forget that moment..."
	DB	NEXT
	DB	"...................................................."
	DB	NEXT
	DB G_FLG,G_COPYI,116,1
	DB G_FLG,G_COPYF,110,110
	DB	FLG,F_CALI,110,20
	DB G_FLG,G_COPYG,110,110
	B_O B_FADE
	DB	SINARIO,'CS901.OVL',0
	DW	0000H


end
