;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２６＿Ｇ
;		Ｄａｎｃｅ　ｗｉｔｈ　星愛

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

;NN1:	DB	1,	'星愛',0
NN1:	DB	1,	'SEIA',0
;NN2:	DB	2,	'まわり',0
NN2:	DB	2,	'AROUND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　星愛１
S2:		DW	VV1, NN2,  2, M3		;見る　まわり
S3:		DW	VV2, NN1,  3, M4, M5		;話す　星愛２
S4:		DW	VV3, -1,  4, M6		;考える
S5:		DW	VV4, -1,  5, M7, M8, M9		;踊る３


;イニシャルメッセージ
M1:
        DB	BGM,24
        BAK_INIT 'AB_27_2'
        DB BUF,B_COPY01
        T_CG "CT07","C",0,10,1
        ;	DB	'【%001】：お～い、吉田～。'
        DB	"%001:  Hey, Seia!"
        DB	NEXT
        ;	DB	'【星愛】：はい、なんでしょうか？'
        DB	"Seia:  Yes, what is it?"
        DB	NEXT
        ;	DB	'【%001】：あのさ、ダンスできるか？'
        DB	"%001:  I was wondering, can you dance?"
        DB	NEXT
        ;	DB	'【星愛】：いいえ。それがなにか？'
        DB	"Seia:  No, not really. Why?"
        DB	NEXT
        ;	DB	'【%001】：いや・・・ダンス、教えて欲しかったんだけど・・・'
        DB	"%001:  Oh, I wanted someone to teach me how to dance."
        DB	NEXT
        ;	DB	'【星愛】：では、参りましょう。'
        DB	"Seia:  Well, shall we go?"
        DB	NEXT
        ;	DB	'【%001】：え！？だって、今、できないって・・・'
        DB	"%001:  But you just said you couldn't dance!"
        DB	NEXT
        ;	DB	'【星愛】：『為せば成る』と、主もおっしゃっておりますわ。'
        DB	"Seia:  I'm sure the Lord will provide for us, somehow."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・そーだっけ？'
        DB	"%001:  ....Um, okay."
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・・・・・・・'
        DB	"...................................."
        DB	BGM,8
        E_CG B_FADE,'AE_040'
        DB	NEXT
        ;	DB	'俺は、吉田にダンスを教わっている。'
        DB	"Seia's teaching me how to dance."
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
        DB	"I always thought it was something you could pick up"
        DB	CR
        DB	"without any special lessons, but I was wrong."
        DB	NEXT
        ;	DB	'・・・で、吉田のダンスの腕前は、というと・・・'
        DB	"I'm a little worried about her, though."
        DB	NEXT
        ;	DB	'【星愛】：・・・きゃっ！？'
        DB	"Seia:  .........Whoops!"
        DB	NEXT,GATA,1
        ;	DB	'ずっで～ん！'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'・・・俺の方がマシと違うか？'
        DB	"...She doesn't seem to know much more than me about dancing."
        DW	0000H
        
M2:		;見る　星愛１
        ;	DB	'俺にダンスを教わっている。'
        DB	"I'm teaching her how to dance."
        DB	NEXT
        ;	DB	'・・・もとい、俺にダンスを教えている。'
        DB	".....I mean, she's teaching me."
        DB	NEXT
        ;	DB	'【星愛】：・・・えぇっと、ここでは・・・'
        DB	"Seia:  Um, let's see, I think this is right..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ........................"
        DB	NEXT
        ;	DB	'人選誤ったかも知んない・・・・・・'
        DB	"I think I chose the wrong partner for this."
        DW	0000H
        
M3:		;見る　まわり
        ;	DB	'・・・恥ずかしいからヤだ・・・'
        DB	"......I'm too embarrassed to look."
        DW	0000H
        
M4:		;話す　星愛１
        ;	DB	'【星愛】：ごめんなさい、%001君・・・'
        DB	"Seia:  I'm sorry, %001..."
        DB	NEXT
        ;	DB	'【%001】：・・・いやまあ・・・'
        DB	"%001:  No, it's okay."
        DB	NEXT
        ;	DB	'【星愛】：わたくし、知識としては知っておりましたのに・・・'
        DB	"Seia:  I studied dancing when I was younger. But that was"
        DB	CR
        DB	"a while ago."
        DB	NEXT
        ;	DB	'【%001】：・・・ま、しょーが無いさ。'
        DB	"%001:  .......It'll be okay."
        DB	PAUSE
        ;	DB	'この際だから、若葉マーク同士頑張ろう。'
        DB	" We'll just be two people who"
        DB	CR
        DB	"don't know how to dance."
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・はい！'
        DB	"Seia:  ...Okay."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M5:		;話す　星愛２
        ;	DB	'【星愛】：・・・右、左、右、・・・'
        DB	"Seia:  .....Right, left, right..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ......"
        DB	NEXT
        ;	DB	'よそう。話し掛けたらまたコケそ～だ。'
        DB	"If I talk to her, she'll probably fall down again."
        DW	0000H
        
M6:		;考える
        ;	DB	'俺の方が上手いのと違うか？'
        DB	"I might actually be better than her."
        DB	NEXT
        ;	DB	'・・・ま、大差ねーけど・・・'
        DB	"Oh well, it's no big deal."
        DW	0000H
        
M7:		;踊る１
        ;	DB	'【星愛】：・・・右、左、右・・・',CR
        ;	DB	'【%001】：・・・右、左、右・・・'
        DB	"Seia:  ........Right, left, right......",CR
        DB	"%001:  ......Right, left, right......"
        DB	NEXT
        ;	DB	'【星愛】：・・・右、右、右・・・',CR
        ;	DB	'【%001】：・・・右、左、右・・・'
        DB	"Seia:  ........Right, right, right......",CR
        DB	"%001:  ......Right, left, right......"
        DB	NEXT,GATA,1
        ;	DB	'ずっでーん！'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'【%001】：・・・ててて・・・大丈夫か吉田？'
        DB	"%001:  Ouch! Are you okay, Seia?"
        DB	NEXT
        ;	DB	'【星愛】：え、ええ。'
        DB	"Seia:  I'm fine."
        DB	FLG,F_COPYI,5,1
        DW	0000H
        
M8:		;踊る２
        ;	DB	'【星愛】：ではもう一度。'
        DB	"Seia:  Let's try it again."
        DB	NEXT
        ;	DB	'【星愛】：・・・右、左、右・・・',CR
        ;	DB	'【%001】：・・・右、左、右・・・'
        DB	"Seia:  ........Right, left, right......",CR
        DB	"%001:  ......Right, left, right......"
        DB	NEXT
        ;	DB	'【星愛】：・・・右、右、右・・・',CR
        ;	DB	'【%001】：・・・右、左、右・・・'
        DB	"Seia:  ........Right, right, right......",CR
        DB	"%001:  ......Right, left, right......"
        DB	NEXT,GATA,1
        ;	DB	'ずっでーん！'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'【%001】：・・・ててて・・・大丈夫か吉田？'
        DB	"%001:  It happened again. Are you okay?"
        DB	NEXT
        ;	DB	'【星愛】：え、ええ。'
        DB	"Seia:  I'm alright."
        DB	FLG,F_COPYI,5,2
        DW	0000H
        
M9:		;踊る３
        ;	DB	'【星愛】：・・・今度は大丈夫ですわ。失敗したところが分かりましたから。'
        DB	"Seia:  It'll be okay this time, %001. I know what I was"
        DB	CR
        DB	"doing wrong."
        DB	NEXT
        ;	DB	'【%001】：そか。',PAUSE,'じゃあもう一回！'
        DB	"%001:  Okay. ",PAUSE,"Well, let's try it again."
        DB	NEXT
        ;	DB	'【星愛】：・・・右、左、右・・・',CR
        ;	DB	'【%001】：・・・右、左、右・・・'
        DB	"Seia:  ........Right, right, right......",CR
        DB	"%001:  ......Right, left, right......"
        DB	NEXT
        ;	DB	'【星愛】：・・・右、左、右・・・',CR
        ;	DB	'【%001】：・・・右、左、右・・・'
        DB	"Seia:  ........Right, right, right......",CR
        DB	"%001:  ......Right, left, right......"
        DB	NEXT
        ;	DB	'【星愛】：・・・左、左、右・・・',CR
        ;	DB	'【%001】：・・・右、左、左・・・'
        DB	"Seia:  ........Left, right, right......",CR
        DB	"%001:  ......Right, left, left......"
        DB	NEXT,GATA,1
        ;	DB	'ずっでーん！'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'【%001】：・・・ててて・・・大丈夫か吉田？'
        DB	"%001:  Ouch! Are you alright?"
        DB	NEXT
        ;	DB	'【星愛】：え、ええ。'
        DB	"Seia:  Yes."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・でも、確かにさっきよりは進んだよな？'
        DB	"%001:  .....We got farther that time!"
        DB	NEXT
        ;	DB	'【星愛】：はい。'
        DB	"Seia:  Yes, we did."
        DB	NEXT
        ;	DB	'【%001】：・・・よ～っし、この調子で行こうぜ！'
        DB	"%001:  Let's try it again!"
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・はい！'
        DB	"Seia:  Okay!"
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・'
        DB	".................................."
        DB	NEXT
        ;	DB	'【星愛】：・・・やりましたわ！これで１パターンです！'
        DB	"Seia:  We did it!"
        DB	NEXT
        ;	DB	'【%001】：・・・おっし！'
        DB	"%001:  That's great."
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・・・・'
        DB	"Seia:  ..........."
        DB	PAUSE
        ;	DB	'ぷっ。'
        DB	"Hahaha..."
        DB	NEXT
        ;	DB	'【%001】：・・・何だよ吉田。'
        DB	"%001:  What's so funny?"
        DB	NEXT
        ;	DB	'【星愛】：・・・だって・・・その顔・・・'
        DB	"Seia:  Your face... It's so dirty from falling in the mud."
        DB	NEXT
        ;	DB	'【%001】：何言ってやがる。吉田だって、泥だらけだぜ？'
        DB	"%001:  You should see yourself!"
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・・・・'
        DB	"Seia:  ..........."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ..........."
        DB	PAUSE
        ;	DB	'ぷぷっ。'
        DB	"Hahaha!"
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・笑わないで下さい・・・・・・'
        DB	"Seia:  Don't laugh..."
        DB	PAUSE
        ;	DB	'注目されてしまいますわ・・・・・・'
        DB	"Everyone's looking at us..."
        DB	PAUSE
        ;	DB	'ぷぷぷっ。'
        DB	"......Hahaha!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・吉田こそ・・・・・・'
        DB	"%001:  .......I can't help it..."
        DB	PAUSE
        ;	DB	'ぷぷぷぷぷっ。'
        DB	"Hahahahahahahaha!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ......................"
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・・・・'
        DB	"Seia:  ........................"
        DB	NEXT
        ;	DB	'不意に、吉田の瞳が真正面から飛び込んで来る。'
        ;	DB	'月が映りこんだその瞳は、吸い込まれそうな気すらする。'
        DB	"Just then, the silver moonlight reflected in Seia's eyes."
        DB	CR
        DB	"I had never seen such pure eyes."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・吉田・・・・・・'
        DB	"%001:  .......Seia."
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・はい・・・・・・'
        DB	"Seia:  .........Yes?"
        DB	NEXT
        ;	DB	'【%001】：踊ろう。'
        DB	"%001:  Let's dance."
        DB	NEXT
        ;	DB	'【星愛】：はい。'
        DB	"Seia:  Okay."
        DB	NEXT
        ;	DB	'・・・言葉に出来なかった想いを込め、俺は踊った。'
        DB	"Putting aside what I couldn't put into words just yet, I"
        DB	CR
        DB	"continued dancing."
        DB	NEXT
        ;	DB	'まだつたないけれど・・・届いて欲しい。'
        DB	"....I thought I was falling in love with Seia."
        DB	NEXT
        ;	DB	'今夜の月を・・・吉田の瞳を、俺はずっと忘れないだろう。'
        DB	"I'll never forget Seia's solemn, solemn eyes that shone"
        DB	CR
        DB	"in the light of the moon."
        DB	NEXT
        DB	"...................................................."
        DB	NEXT
        DB G_FLG,G_COPYI,174,1
        DB G_FLG,G_COPYF,170,170
        DB	FLG,F_CALI,170,20
        DB G_FLG,G_COPYG,170,170
        B_O B_FADE
        DB	SINARIO,'CS901.OVL',0
        DW	0000H


end
