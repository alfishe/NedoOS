;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ｂ＿２
;		清美Ｈ１

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2
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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,-1	

;VV1:	DB	1,	'計画続行',0
VV1:	DB	1,	'CONTINUE PLAN',0
;VV2:	DB	2,	'計画中止',0
VV2:	DB	2,	'FORGET PLAN',0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3, M4		;計画続行
S2:		DW	VV2, -1,  2, M5		;計画中止


;イニシャルメッセージ
M1:
	DB	BGM,13
	E_CG B_SUDA,'AE_152'
;	DB	'【清美】：あの・・・%001さん、やはりわたくし達にはまだ早いのではないのでしょうか。'
	DB	"Kiyomi:  %001?  Um, I think it might be a little too"
	DB	CR
	DB	"early for us..."
	DB	NEXT
;	DB	'【%001】：そう？俺はいい計画だと思うけどな、コレ。'
	DB	"%001:  You think so? But this is such a good plan you"
	DB	CR
	DB	"made up."
	DB	NEXT
;	DB	'そう言っておれはさっきのルーズリーフをチラつかせる。'
	DB	"Kiyomi:  .................................."
;	DB	NEXT
;	DB	'【清美】：まあ、いつのまに！'
;	DB	"Kiyomi:  When did you...?"
;	DB	NEXT
;	DB	'【%001】：さっきのキスの時に・・・ね。'
;	DB	"%001:  When we were kissing just now."
	DW	0000H

M2:		;計画続行
;	DB	'【%001】：え～っと、何々・・・',CR,'「新藤さん・・・いや、清美って呼んでもいいだろう？」'
	DB	"%001:  Let's see here... Next, I'm supposed to call"
	DB	CR
	DB	"you 'darling...'"
	DB	NEXT
;	DB	'【%001】：「俺は君のためなら、片手でゾウだって持ち上げて見せる」'
	DB	"%001:  '....For you, I could lift up an elephant with only"
	DB	CR
	DB	"one arm.'"
	DB	NEXT
;	DB	'【%001】：・・・悪ィ。これはちょっと俺には無理だ・・・'
	DB	"%001:  I don't think I'm that strong."
	DB	NEXT
;	DB	'【清美】：%001さん・・・ですから、その計画書は・・・'
	DB	"Kiyomi:  %001....I told you, that plan was just..."
	DB	FLG,F_COPYI,1,1
	DW	0000H


M3:		;計画続行
;	DB	'【%001】：で、俺が懐から一輪の・・・・・・',PAUSE,CR,'ゴメン新藤さん、この字なんて読むの？'
	DB	"%001:  'I would part the seas for you, bring...",PAUSE,"Um, I can't"
	DB	CR
	DB	"read your writing here."
	DB	NEXT
;	DB	'【清美】：それは薔薇（バラ）という字ですわ。'
	DB	"Kiyomi:  '...bring you roses and silk.'"
	DB	NEXT
;	DB	'【%001】：・・・悪ィ、バラの花は用意してねーや。'
	DB	"%001:  I don't have any of those with me."
	DB	NEXT
;	DB	'【清美】：ですから・・・それはわたくしの妄想で・・・'
	DB	"Kiyomi:  I told you, this plan is just..."
	DB	FLG,F_COPYI,1,2
	DW	0000H


M4:		;計画続行
;	DB	'【%001】：・・・で、１８時２０分に、ベッドに座ってる新藤さんのパンティがチラッと見えて、興奮する、と。'
	DB	"%001:  ....At 6:20 I'm supposed to accidentally see your"
	DB	CR
	DB	"panties and get excited..."
	DB	NEXT
;	DB	'【%001】：・・・新藤さん、本当に見えてるけど・・・'
	DB	"%001:  I can see them already, though..."
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  ................................"
	DB	NEXT
	E_CG B_SUDA,'AE_153'
;	DB	'【%001】：あ゛・・・'
	DB	"%001:  .........................................."
	DB	NEXT
;	DB	'【清美】：・・・・・・',PAUSE,'どうでしょうか・・・'
	DB	"Kiyomi:  ................Do you like this?"
	DB	NEXT
;	DB	'その大胆な行動は、学校にいる時の彼女と同一人物とは思えなかった。'
	DB	"I never suspected that Kiyomi could be capable of making"
	DB	CR
	DB	"so bold a gesture."
	DB	NEXT
;	DB	'俺は思わずつばを飲み込んだ。'
	DB	"I looked at her a long time, as my heart beat in my ears."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・興奮する。'
	DB	"%001:  ...................It's working."
	DB	NEXT
;	DB	'【%001】：新藤さん、・・・・・・いいの？'
	DB	"%001:  Kiyomi, are you sure?"
	DB	NEXT
;	DB	'【清美】：%001さん・・・・・・今日と言う日を、忘れられない日にして下さい。'
	DB	"Kiyomi:  If you really love me...if you promise to remember"
	DB	CR
	DB	"this day as long as you live...then I'm sure."
	DB	NEXT
;	DB	'【清美】：わたくし・・・覚悟は出来ておりますわ。'
	DB	"Kiyomi:  I'm ready...for what I have to do."
	DB	NEXT
;	DB	'【%001】：清美・・・！'
	DB	"%001:  Kiyomi....!"
	DB	NEXT
;	DB	'俺は清美をベッドに押し倒した。'
	DB	"I laid her down on the bed."
	DB	NEXT
	DB	SINARIO,'CSE_B_3.OVL',0
	DW	0000H

M5:		;計画中止
;	DB	'【%001】：・・・新藤さんがそ～ゆうなら、やめにしようか。'
	DB	"%001:  Well, if that's the way you feel...let's stop."
	DB	NEXT
;	DB	'【清美】：・・・・・・おやめになってしまうのですか？'
	DB	"Kiyomi:  ....You're going to stop?"
	DB	NEXT
;	DB	'【%001】：・・・やめない。'
	DB	"%001:  ...............No."
	DW	0000H


end
