;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４１１
;		慎治

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM2:	DW	VV2,	NN1,NN2,-1
CM3:	DW	VV3,	NN1,NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'男の子',0
NN1:	DB	1,	'BOY',0
;NN2:	DB	2,	'慎治',0
NN2:	DB	2,	'SHINJI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　男の子
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7		;話す　男の子
S3:		DW	VV2, NN2,  3, M8		;話す　慎治
S4:		DW	VV3, NN1,  4, M9, M10, M11		;考える　男の子
S5:		DW	VV3, NN2,  5, M12		;考える　慎治


;イニシャルメッセージ
M1:
	DB	BGM,17
	BAK_INIT 'AB_43_1'
;	DB	'「あの・・・」'
	DB	"???:  Um, excuse me...?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT11','F',0,30,1
;	DB	'振り返ると、小学校高学年くらいの男の子が俺を見ていた。'
	DB	"I turned around, and there was a young boy in front of me."
	DB	NEXT
;	DB	'【%001】：どしたい、ボーズ。'
	DB	"%001:  Who are you?"
	DB	NEXT
;	DB	'【男の子】：えっと・・・その・・・'
	DB	"Boy:  I'm, um... Er..."
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  Yes?"
	DB C_BLD,C_N_ON,2,2		;話す　慎治
	DB C_BLD,C_N_ON,3,2		;考える　慎治
	DW	0000H

M2:		;見る　男の子
;	DB	'（何か俺に言おうとしてるみたいだが・・・）'
	DB	"He seems to be trying to tell me something."
	DB	NEXT
;	DB	'（・・・どこかで会ったか？）'
	DB	"Have I seen him before? I can't remember."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　男の子
;	DB	'（妙におどおどしている。）'
	DB	"He's really nervous, for some reason."
	DW	0000H

M4:		;話す　男の子
;	DB	'【男の子】：あの・・・僕・・・'
	DB	"Boy:  I.... I, um....."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Yes, what is it?"
	DB	NEXT
;	DB	'【男の子】：・・・・・・'
	DB	"Boy:  ................................"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　男の子
;	DB	'【男の子】：あっあの！・・・今日は、何してるんですか？'
	DB	"Boy:  Um, may I ask... May I ask what you're doing today?"
	DB	NEXT
;	DB	'【%001】：・・・ヒマだからぶらぶらしてるだけだけど？'
	DB	"%001:  Nothing much. I had some free time, so I thought"
	DB	CR
	DB	"I'd hang around downtown."
	DB	NEXT
;	DB	'【男の子】：そ、そうですか！僕も、ヒマだから街に出ようかな、なんて・・・'
	DB	"Boy:  R- Really? Well, me, too."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　男の子
;	DB	'【%001】：俺に何か用？'
	DB	"%001:  Is there something you need me for?"
	DB	NEXT
;	DB	'【男の子】：はい！その、お、お礼を言いたくて・・・'
	DB	"Boy:  Yes! Er, that is, I wanted to thank you..."
	DB	NEXT
;	DB	'【%001】：お礼？'
	DB	"%001:  Thank me?"
	DB	FLG,F_COPYI,4,2
	DB	FLG,F_COPYI,2,3
	DW	0000H

M7:		;話す　男の子
;	DB	'【%001】：なあボーズ、俺には何がなんだかさっぱり意味不明なんだけどよ。'
	DB	"%001:  I have to tell you right out, I have no idea what"
	DB	CR
	DB	"you're talking about."
	DB	NEXT
;	DB	'【男の子】：え・・・？'
	DB	"Boy:  What?"
	DB	NEXT
;	DB	'【%001】：前にどっかで会ったか、俺達？'
	DB	"%001:  Have I met you before?"
	DB	NEXT
	K_CG 'CT11','I',30,2
;	DB	'【男の子】：僕のこと・・・覚えてないの？'
	DB	"Boy:  You don't....you don't remember me?"
	DB	NEXT
;	DB	'男の子は涙目になってうつむいてしまう・・・'
	DB	"Tears started to well up in the boy's eyes."
	DB	NEXT
;	DB	'【%001】：わ、悪ィ！俺、記憶力悪くてな。'
	DB	"%001:  No, don't cry! I'm sorry for forgetting! I just"
	DB	CR
	DB	"have a bad memory, that's all!"
	DB	NEXT
;	DB	'【%001】：なぁ、良かったら詳しく話してくれねーか？多分、思い出せると思うんだ・・・。'
	DB	"%001:  Will you tell me where we met before? I'm sure"
	DB	CR
	DB	"it'll all come back to me."
	DB	NEXT
;	DB	'【%001】：まず、ボーズの名前は？'
	DB	"%001:  Um, what's your name?"
	DB	NEXT
;	DB	'【男の子】：僕・・・新藤　慎治っていいます。'
	DB	"Boy:  Shinji Shinfuji."
	DB	NEXT
;	DB	'【%001】：新藤？'
	DB	"%001:  Did you say Shinfuji?"
	DB	NEXT
;	DB	'【%001】：ひょっとして、新藤　清美さんの弟かなにか？'
	DB	"%001:  You must be Kiyomi's little brother!"
	DB	NEXT
;	DB	'【慎治】：はい・・・'
	DB	"Shinji:  That's right..."
	DB C_BLD,C_N_ON,2,1
	DB C_BLD,C_N_ON,3,1
	DB C_BLD,C_N_OFF,2,2
	DB C_BLD,C_N_OFF,3,2
	DW	0000H

M8:		;話す　慎治
;	DB	'【%001】：・・・それで、「お礼」ってのは一体？'
	DB	"%001:  And? What do you have to thank me for?"
	DB	NEXT
;	DB	'【慎治】：・・・僕・・・トラックにはねられそうになったのを、お兄ちゃんに助けてもらったんです。'
	DB	"Shinji:  I was almost hit by a truck. You saved my life."
	DB	NEXT
;	DB	'【%001】：俺に？'
	DB	"%001:  I did?"
	DB	NEXT
;	DB	'【慎治】：あの日は雨が降ってて・・・僕、お姉ちゃんに傘を届けに、中学校に行ったんです。'
	DB	"Shinji:  It was raining that day. I had gone to bring an"
	DB	CR
	DB	"extra umbrella to my sister."
	DB	NEXT
;	DB	'・・・あ。ひょっとして、あれか？'
	DB	"Wait, I think I remember what he's talking about."
	DB	NEXT
;	DB	'確か一年くらい前・・・'
	DB	"It was about a year ago."
	DB	NEXT
;	DB	'そうだ、思い出した。道に飛び出した男の子がいて、トラックにはねられるところを助けたような覚えが・・・'
	DB	"That's right. He ran out into the street, and I pushed"
	DB	CR
	DB	"him out of the way at the last minute."
	DB	NEXT
;	DB	'【%001】：そういやぁそんな事もあったなぁ。'
	DB	"%001:  I do remember that, now."
	DB	NEXT
;	DB	'【%001】：そっか、あの時の・・・'
	DB	"%001:  So you're that boy..."
	DB	NEXT
	T_CG 'CT11','F',0,30,3
;	DB	'【慎治】：あの時は驚いててお礼言えなかったから・・・'
	DB	"Shinji:  I was so shocked, I didn't get a chance to thank"
	DB	CR
	DB	"you then..."
	DB	NEXT
;	DB	'今度会ったらちゃんと言おうと思って・・・'
	DB	"Shinji:  So I promised myself I'd thank you the next time I "
	DB	CR
	DB	"saw you."
	DB	NEXT
;	DB	'そっか・・・新藤さんが言ってたのもこの事だったのか。'
	DB	"Ah, this must be what Kiyomi was talking about the first"
	DB	CR
	DB	"day I met her."
	DB	NEXT
;	DB	'【慎治】：本当に、ありがとうございました。'
	DB	"Shinji:  Thank you very much for saving my life."
	DB	NEXT
;	DB	'【%001】：あ・・・ああ。'
	DB	"%001:  Huh? Oh, it was nothing."
	DB	NEXT
;	DB	'【慎治】：それじゃ・・・また・・・'
	DB	"Shinji:  Well, I'll see you later..."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'慎治君は行ってしまった。'
	DB	"Shinji departs."
	DB	NEXT
;	DB	'俺のこと、ずっと捜してたみたいだな。なのに、肝心の俺が度忘れしてたとゆー・・・なんか、悪い事したような気がするな。'
	DB	"Both he and his sister were looking for me for the past"
	DB	CR
	DB	"year. I feel kind of bad, like I've imposed on them or"
	DB	CR
	DB	"something."
	DB	NEXT
;	DB	'・・・・・・'
	DB	"......................................."
	DB	NEXT
;	DB	'そろそろ帰ろうかな・・・'
	DB	"Well, guess I'll head home..."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".........................................."
	DB	NEXT
;	DB	'そういえば・・・'
	DB	"Hmmm..."
	DB	NEXT
;	DB	'白水さんは今日も一人で川見てるんだろーか・・・？'
	DB	"I just had a thought. I wonder if Ruri is staring at the"
	DB	CR
	DB	"river again today."
	DB	NEXT
;	DB	'・・・ちょっと行ってみるかな・・・'
	DB	"Maybe I'll stop by and see on my way home."
	DB	NEXT
	B_O B_SUDA
	DB	SINARIO,'CS412.OVL',0
	DW	0000H

M9:		;考える　男の子
;	DB	'どうも俺に何か用事があるみたいなんだが・・・'
	DB	"He seems to want to say something to me."
	DB	NEXT
;	DB	'じれったいな・・・'
	DB	"I wish I could remember if I've met him before or not."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M10:		;考える　男の子
;	DB	'ものすごくあがってる・・・対人恐怖症かこの子？'
	DB	"He's really nervous."
	DW	0000H

M11:		;考える　男の子
;	DB	'お礼・・・ってなんだ？'
	DB	"He wants to thank...me?"
	DB	NEXT
;	DB	'俺この子に何かしたのか？'
	DB	"Did I ever do anything for this kid?"
	DB	NEXT
;	DB	'大体、誰なんだこの子は？'
	DB	"I don't even remember meeting him before."
	DW	0000H

M12:		;考える　慎治
;	DB	'彼は新藤さんの弟だ。'
	DB	"He's Kiyomi's little brother."
	DW	0000H


end
