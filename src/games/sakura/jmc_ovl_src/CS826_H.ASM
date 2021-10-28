;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２６＿Ｈ
;		Ｄａｎｃｅ　ｗｉｔｈ　恵依美

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

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	'MEIMI',0
;NN2:	DB	2,	'まわり',0
NN2:	DB	2,	'AROUND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　恵依美１
S2:		DW	VV1, NN2,  2, M3		;見る　まわり
S3:		DW	VV2, NN1,  3, M4, M5, M6		;話す　恵依美３
S4:		DW	VV3, -1,  4, M7		;考える
S5:		DW	VV4, -1,  5, M8, M9, M10		;踊る３


;イニシャルメッセージ
M1:
        DB	BGM,24
        BAK_INIT 'AB_27_2'
        DB BUF,B_COPY01
        T_CG "CT08","C",0,10,1
        ;	DB	'【%001】：あ、いたいた。お～い、中野ぉ。'
        DB	"%001:  Oh, there she is. Hey, Meimi!"
        DB	NEXT
        ;	DB	'【恵依美】：え？な、何よ何よ何よ、なんなのよ？'
        DB	"Meimi:  Huh? What do you want?!"
        DB	NEXT
        ;	DB	'【%001】：おぉ？どーしたんだよ？'
        DB	"%001:  Nothing! What's the matter with you?"
        DB	NEXT
        ;	DB	'【恵依美】：べっ、べっつに～！んで、あんたは一体なんの用なの？'
        DB	"Meimi:  Oh, nothing. What do you want?"
        DB	NEXT
        ;	DB	'【%001】：ああ・・・あのさ、中野、ダンスできる？'
        DB	"%001:  Can you dance?"
        DB	NEXT
        K_CG 'CT08','D',10,2
        ;	DB	'【恵依美】：・・・%001、あんたあたしをバカにしてるでしょ？'
        DB	"Meimi:  %001, are you making fun or me or something?"
        DB	NEXT
        ;	DB	'【%001】：ちょ、まて、それは誤解だ！'
        DB	"%001:  Wait! Don't get the wrong idea!"
        DB	NEXT
        ;	DB	'【恵依美】：じゃあ、なんなのよ？'
        DB	"Meimi:  Then why did you ask me if I could dance?"
        DB	NEXT
        ;	DB	'【%001】：ん～、あのな・・・俺にダンスを教えて欲しいんだけど・・・'
        DB	"%001:  I just want someone to teach me how to dance."
        DB	NEXT
        ;	DB	'【恵依美】：・・・何よ、それ。ま～さかあんた、泳げない上にダンスもできない、なんて言うんじゃないでしょうね？'
        DB	"Meimi:  Are you trying to tell me that you can't dance"
        DB	CR
        DB	"either?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ..........................."
        DB	NEXT
        K_CG 'CT08','C',10,3
        ;	DB	'【恵依美】：・・・え？ホ、ホントなの？'
        DB	"Meimi:  .......You're serious, aren't you?"
        DB	NEXT
        ;	DB	'【%001】：・・・まあな。'
        DB	"%001:  .........Yes."
        DB	NEXT
        ;	DB	'【恵依美】：・・・はぁ～、しょーがないなあ・・・よし、あたしが一肌脱いであげるか！'
        DB	"Meimi:  Well why didn't you say so? I'll teach you."
        DB	NEXT
        DB	BGM,8
        E_CG B_FADE,'AE_039'
        ;	DB	'・・・・・・・・・・・・・・・・・・・・・'
        DB	"..............................................."
        DB	NEXT
        ;	DB	'俺は、中野にダンスを教わっている。'
        DB	"Meimi's teaching me how to dance."
        DB	NEXT
        ;	DB	'正直な話、俺はダンスができない。'
        DB	"When I told her I didn't know how to dance, I was"
        DB	CR
        DB	"telling the truth."
        DB	NEXT
        ;	DB	'・・・単に経験がなかったせいだったりする。'
        DB	"I just never had the chance to learn."
        DB	NEXT
        ;	DB	'いざ踊ってしまえばどうにかなる、とか思ったのは甘かったらしい。'
        DB	"I always thought it was something you could pick up"
        DB	CR
        DB	"without any special lessons, but I was wrong."
        DB	NEXT
        ;	DB	'【恵依美】：ほら、%001！ぼけっとしないで！'
        DB	"Meimi:  %001, you have to pay attention!"
        DB	NEXT
        ;	DB	'【%001】：は、はい！'
        DB	"%001:  Okay, sorry."
        DW	0000H
        
M2:		;見る　恵依美１
        ;	DB	'俺にダンスを教えてくれている。'
        DB	"She's teaching me how to dance."
        DB	NEXT
        ;	DB	'【中野】：ほら、真面目にやんなさい！'
        DB	"Meimi:  Are you going to pay attention to this or what?"
        DB	NEXT
        ;	DB	'【%001】：は、はい！'
        DB	"%001:  .........Sorry!"
        DW	0000H
        
M3:		;見る　まわり
        ;	DB	'中野が教えてくれてるんだ、まわりを参考にすることはないよな。'
        DB	"Meimi's teaching me. There's no need to see what other"
        DB	CR
        DB	"people are doing."
        DW	0000H
        
M4:		;話す　恵依美１
        ;	DB	'【%001】：悪りィな、中野・・・'
        DB	"%001:  I'm sorry, Meimi..."
        DB	NEXT
        ;	DB	'【恵依美】：今更な～に言ってんの！'
        DB	"Meimi:  It's too late for that now! I'm already out here."
        DB	PAUSE,CR
        ;	DB	'・・・ほら、集中して！'
        DB	"Now concentrate!"
        DB	NEXT
        ;	DB	'【%001】：・・・あ、ああ・・・'
        DB	"%001:  ........Okay."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M5:		;話す　恵依美２
        ;	DB	'【%001】：しっかし、さすが体操部だよな。'
        DB	"%001:  You're good at this."
        DB	PAUSE
        ;	DB	'上手いもんだ。'
        DB	" It must come from being in the"
        DB	CR
        DB	"gymnastics club."
        DB	NEXT
        ;	DB	'【恵依美】：・・・ま～ね！'
        DB	"Meimi:  Maybe."
        DB	PAUSE
        ;	DB	'っとほら！集中集中！'
        DB	" What did I say about concentrating?"
        DB	NEXT
        ;	DB	'【%001】：お、おう。'
        DB	"%001:  ....Yes ma'am."
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M6:		;話す　恵依美３
        ;	DB	'【%001】：ありがとな、中野。'
        DB	"%001:  Thanks, Meimi."
        DB	NEXT
        ;	DB	'【恵依美】：・・・な、なによ急に・・・'
        DB	"Meimi:  Why thank me?"
        DB	PAUSE
        ;	DB	'それに、未だ早いわよ。'
        DB	" I'm not even done teaching you yet."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  .................................."
        DB	NEXT
        ;	DB	'【%001】：そうだな。'
        DB	"%001:  You're right."
        DW	0000H
        
M7:		;考える
        ;	DB	'・・・しかし、意外なモンだ。中野って、ダンス上手かったのか。'
        DB	"I'm surprised. Meimi's really good at this."
        DB	NEXT
        ;	DB	'・・・本人に面と向かって言わない方がいいな。'
        DB	"........I shouldn't tell her that to her face, of course."
        DW	0000H
        
M8:		;踊る１
        ;	DB	'【恵依美】：１、２、１、２、はいまわって！'
        DB	"Meimi:  One, two, one, two, and spin!"
        DB	NEXT
        ;	DB	'【%001】：お、おう！'
        DB	"%001:  Like this?"
        DB	NEXT
        ;	DB	'ずるっ。',CR,GATA,1,'ずっで～ん！'
        DB	"*SLIP*",CR,GATA,1,"*CRASH*"
        DB	NEXT
        ;	DB	'【%001】：・・・あ゛い゛ででででで・・・'
        DB	"%001:  ...Ouch!"
        DB	NEXT
        ;	DB	'【恵依美】：慌てて回るからよ。'
        DB	"Meimi:  You spun too fast."
        DB	PAUSE
        ;	DB	'%001は初心者なんだから、周りに合わせようとしなくていいのよ。'
        DB	" You're a beginner, so you have to"
        DB	CR
        DB	"take it a little easy."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ............."
        DB	PAUSE
        ;	DB	'分かった。'
        DB	"Okay."
        DB	FLG,F_COPYI,5,1
        DW	0000H
        
M9:		;踊る２
        ;	DB	'【恵依美】：１、２、１、２、はいまわって！'
        DB	"Meimi:  One, two, one, two, and spin!"
        DB	NEXT
        ;	DB	'【%001】：・・・よっ！'
        DB	"%001:  ...........Okay!"
        DB	NEXT
        ;	DB	'【恵依美】：いいわ、その調子よ！'
        DB	"Meimi:  Good, that's much better."
        DB	NEXT
        ;	DB	'【恵依美】：１、２、１、２、はいもう一度！'
        DB	"Meimi:  One more time. One, two, one, two, and spin!"
        DB	NEXT
        ;	DB	'【%001】：・・・とっ！'
        DB	"%001:  ...Whoops!"
        DB	PAUSE
        ;	DB	'・・・ととっっ！？'
        DB	" Oh no!"
        DB	NEXT
        ;	DB	'【恵依美】：危ない！'
        DB	"Meimi:  Be careful!"
        DB	NEXT,GATA,1
        ;	DB	'どっし～ん！'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'【%001】：あたたたたた・・・大丈夫か中野？'
        DB	"%001:  Ouch! Are you okay, Meimi?"
        DB	NEXT
        ;	DB	'【恵依美】：う、うん。'
        DB	"Meimi:  I'm fine."
        DB	FLG,F_COPYI,5,2
        DW	0000H
        
M10:		;踊る３
        ;	DB	'【恵依美】：・・・さあ！もう一度よ！'
        DB	"Meimi:  Okay, one more time!"
        DB	NEXT
        ;	DB	'【%001】：あ、ああ。'
        DB	"Meimi:  Ah, okay."
        DB	NEXT
        ;	DB	'【恵依美】：１、２、１、２、はいまわって！'
        DB	"Meimi:  One more time. One, two, one, two, and spin!"
        DB	NEXT
        ;	DB	'【%001】：・・・よっ！'
        DB	"%001:  ...Got it!"
        DB	NEXT
        ;	DB	'【恵依美】：いいわ、その調子よ！'
        DB	"Meimi:  That's good!"
        DB	NEXT
        ;	DB	'【恵依美】：１、２、１、２、はいもう一度！'
        DB	"Meimi:  One, two, one, two, and spin!"
        DB	NEXT
        ;	DB	'【%001】：・・・とっ！'
        DB	"Meimi:  Okay!"
        DB	NEXT
        ;	DB	'【恵依美】：そうそう！'
        DB	"Meimi:  Good, good!"
        DB	NEXT
        DB	".........................................."
        DB	NEXT
        ;	DB	'【恵依美】：・・・・・・ふう。ま、大体こんな感じかな？'
        DB	"Meimi:  ...........Okay, well, that's pretty much how it's"
        DB	CR
        DB	"done."
        DB	NEXT
        ;	DB	'【%001】：ありがとう、中野。'
        DB	"Meimi:  Thanks, Meimi."
        DB	NEXT
        ;	DB	'【恵依美】：・・・あ・・・（ぽっ）'
        DB	"Meimi:  ........Oh, it was nothing."
        DB	PAUSE,CR
        ;	DB	'・・・ね、ねえ%001。もう一回、おさらいしよ？'
        DB	"......Do you want to try it some more?"
        DB	NEXT
        ;	DB	'【%001】：ああ、そうだな。'
        DB	"%001:  Sure, that'd be nice."
        DB	NEXT
        ;	DB	'【恵依美】：・・・・・・うん。'
        DB	"Meimi:  Let's go."
        DB	NEXT
        ;	DB	'・・・月明かりの下、俺と中野は心ゆくまで踊った。'
        DB	"I danced and danced with Meimi under the silvery light"
        DB	CR
        DB	"of the moon."
        DB	NEXT
        ;	DB	'今夜の月を、俺はずっと忘れないだろう。'
        DB	"I'll never forget that night."
        DB	NEXT
        DB	"................................"
        DB	NEXT
        DB G_FLG,G_COPYI,184,1
        DB G_FLG,G_COPYF,180,180
        DB	FLG,F_CALI,180,20
        DB G_FLG,G_COPYG,180,180
        B_O B_FADE
        DB	SINARIO,'CS901.OVL',0
        DW	0000H


end
