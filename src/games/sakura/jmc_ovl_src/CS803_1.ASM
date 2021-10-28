;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０３＿１
;		体育祭３日前　恵依美＆星愛、大食い大会

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

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'聞く',0
VV2:	DB	2,	'LISTEN',0 
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'星愛と恵依美',0
NN1:	DB	1,	'SEIA AND MEIMI',0
;NN2:	DB	2,	'話',0
NN2:	DB	2,	'REQUEST',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　星愛と恵依美
S2:		DW	VV2, NN2,  2, M5, M6, M7, M8, M9		;聞く　話５
S3:		DW	VV3, -1,  3, M10, M11		;考える


;イニシャルメッセージ
M1:
	DB	BGM,17
	B_O B_SUDA
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................................"
	DB	NEXT
	BAK_INIT "AB_35"
	DB BUF,B_COPY01
	TU_CG "CT08","W",0,8,1
	T_CG 'CT07','W',0,32,2
	DB ANI,A_ON,1
;	DB	'【恵依美】：あ、星愛。そこのケチャップ取って。'
	DB	"Meimi:  Seia, will you hand me the ketchup?"
	DB	NEXT
;	DB	'【星愛】：・・・はい、恵依美ちゃん。'
	DB	"Seia:  Here."
	DB	NEXT
;	DB	'【恵依美】：さんきゅ、星愛。'
	DB	"Meimi:  Thanks, Seia."
	DB	NEXT
;	DB	'【星愛】：代わりと言ってはなんですが、そこのマスタード取って頂けません？'
	DB	"Seia:  Will you hand me the mustard?"
	DB	NEXT
;	DB	'【恵依美】：いいわよ・・・はい。'
	DB	"Meimi:  Sure...here."
	DB	NEXT
;	DB	'【星愛】：ありがとう、恵依美ちゃん。'
	DB	"Seia:  Thanks."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................................"
	DB	NEXT
;	DB	'【恵依美】：・・・あれ？%001、食べないの？'
	DB	"Meimi:  %001, aren't you going to eat?"
	DB	NEXT
;	DB	'【%001】：・・・あ、いや・・・食ってるぜ。'
	DB	"%001:  Oh, I'm eating."
	DB	NEXT
;	DB	'【恵依美】：そう？ならい～んだけど。'
	DB	"Meimi:  Really? Okay, then."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................................"
	DB	NEXT
;	DB	'宴会の時は気が付かなかったが・・・・・・'
	DB	"I didn't notice it before, but..."
	DB	PAUSE
;	DB	'こいつら、スゲー大食いでやんの。'
	DB	" These two really eat a"
	DB	CR
	DB	"lot."
	DB	NEXT
;	DB	'・・・・・・一体、どこに入るんだ？'
	DB	"Where do they put it all?"
	DB	NEXT
;	DB	'【星愛】：？　どうかしまして？'
	DB	"Seia:  What's wrong?"
	DB	NEXT
;	DB	'【%001】：・・・いや、別に・・・'
	DB	"%001:  ...Nothing, nothing at all."
	DW	0000H

M2:		;見る　星愛と恵依美
;	DB	'しっかし、こいつら食うわ食うわ・・・'
	DB	"They just eat and eat..."
	DB	NEXT
;	DB	'こいつら、胃袋が４次元ポケットかなんかじゃねえのか？'
	DB	"Their stomachs must be fourth dimensional doorways or"
	DB	CR
	DB	"something."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　星愛と恵依美
;	DB	'この２人を見てると、こんな言葉が頭をよぎる。'
	DB	"I'm amazed, watching these two eat."
	DB	NEXT
;	DB	'・・・ホントに、こいつらの胃袋って裏表の概念がないんじゃないか？'
	DB	"How was it I never noticed this before?"
;	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　星愛と恵依美
;	DB	'なんで、こいつらが俺の心配してくれてんだろ？'
	DB	"Why are they so worried about me, anyway?"
	DB	NEXT
;	DB	'・・・まあ、ありがたいっちゃあありがたいけど・・・'
	DB	"Well, it's nice of them and all."
	DB	NEXT
;	DB	'・・・別に減らさなくても、やると言ったことはやってみせるさ'
	DB	"I'm just trying to do what I started out to do, that's all."
	DB	FLG,F_COPYI,101,1
	DW	0000H

M5:		;聞く　話１
;	DB	'【%001】：・・・で？話ってなんだ？'
	DB	"%001:  So, what did you want to talk to me about?"
	DB	NEXT
;	DB	'【恵依美】：あ、うん・・・'
	DB	"Meimi:  Um, okay..."
	DB	NEXT
;	DB	'【恵依美】：・・・あのさ%001、体育祭のことなんだけど・・・'
	DB	"Meimi:  %001, this is about the sports festival."
	DB	NEXT
;	DB	'【%001】：体育祭？'
	DB	"%001:  And?"
	DB	NEXT
;	DB	'【星愛】：ええ。・・・%001さん、練習の方はいかがですか？'
	DB	"Seia:  Well, how is your practice going?"
	DB	NEXT
;	DB	'【%001】：・・・まぁそれなりだな。'
	DB	"%001:  I could be better, but it's going pretty well."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;聞く　話２
;	DB	'【星愛】：・・・率直に言います。%001さん、貴方はオーバーワークですわ。'
	DB	"Seia:  To be blunt, we think you're overworking yourself."
	DB	NEXT
;	DB	'【%001】：・・・そうか？'
	DB	"%001:  ...Really?"
	DB	NEXT
;	DB	'【星愛】：ええ。ですから、少し種目を減らすべきだと思いますの。'
	DB	"Seia:  Yes. We think you should reduce the number of events"
	DB	CR
	DB	"you participate in at the sports festival."
	DB	NEXT
;	DB	'・・・と言っても、%001さんは「うん」とは言って下さらないでしょうね。'
	DB	"Seia:  You'll agree, won't you?"
	DB	NEXT
;	DB	'【%001】：ああ。なんてったって、１度は引き受けた事だからな。'
	DB	"%001:  You don't understand. I started this, so I've got to"
	DB	CR
	DB	"finish it."
	DB	FLG,F_COPYI,2,2
	DB	FLG,F_COPYI,3,1
	DB	FLG,F_COPYI,1,2
	DW	0000H

M7:		;聞く　話３
;	DB	'【星愛】：そこで、です。比較的個人技に近いものは、もう練習しなくても宜しいのではありませんか？'
	DB	"Seia:  Isn't it okay for you to stop practicing for some"
	DB	CR
	DB	"of the sports?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................................."
	DB	NEXT
;	DB	'【恵依美】：それにさ、%001の出番多すぎて、出番少なくなっちゃってる人もいるし・・・'
	DB	"Meimi:  I mean, you're in so many sports, and some of the"
	DB	CR
	DB	"other students in our class aren't participating enough."
	DB	NEXT
;	DB	'ね？讓ってあげてよ。参加する事が、まず大事なんだからさ。'
	DB	"Seia:  You see? If you reduce the number of sports you're"
	DB	CR
	DB	"going to be in, some others will participate more."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................................"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M8:		;聞く　話４
;	DB	'【%001】：・・・じゃあ聞くけどさ、俺のせいで出番少ないやつって、'
;	DB	'どのくらいいるの？'
	DB	"%001:  Just how many people are not bothering to partipate"
	DB	CR
	DB	"because of me?"
	DB	NEXT
;	DB	'【星愛】：・・・正確には資料を見なければいけませんが、確か７、８人'
;	DB	'だったと思いますわ。'
	DB	"Seia: I'd have to check the data, but I'm sure there are"
	DB	CR
	DB	"seven or eight students."
	DB	NEXT
;	DB	'【%001】：そいつら、全然出番無いの？'
	DB	"%001:  And they're not going out for any events at all?"
	DB	NEXT
;	DB	'【星愛】：・・・それは・・・'
	DB	"Seia:  Well..."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M9:		;聞く　話５
;	DB	'【%001】：ついでに聞くけど・・・俺が幾つか讓ったとして、'
;	DB	'そいつらの出番、いくつ増えるの？'
	DB	"%001:  So how many of them will participate more if I"
	DB	CR
	DB	"reduce the number of events I'm in?"
	DB	NEXT
;	DB	'【星愛】：・・・・・・・・・'
	DB	"Seia:  ......................................."
	DB	NEXT
;	DB	'【%001】：・・・な？'
	DB	"%001:  .......You can't know that, right? I didn't think so."
	DB	NEXT
	TU_CG "CT08","W",'I',8,3
	T_CG 'CT07','W',0,32,2
	DB ANI,A_ON,3
;	DB	'【恵依美】：・・・でも！'
	DB	"Meimi:  Yes, but!"
	DB	NEXT
;	DB	'【%001】：だ～いじょ～ぶ。この程度でくたばるほどヤワじゃないって。'
	DB	"%001:  I'll be just fine. Please don't worry about me."
	DB	NEXT
;	DB	'【星愛】：・・・・・・これ以上お止めしても、ムダでしょうか？'
	DB	"Seia:  ....Is there anything we can do to change your mind?"
	DB	NEXT
;	DB	'【%001】：ああ・・・気持ちだけ、貰っとくよ。ありがとな。'
	DB	"%001:  Nothing. I appreciate your concern, though. Thanks."
	DB	NEXT
;	DB	'【星愛】：分かりました・・・もう、お止めは效しません。'
	DB	"Seia:  I see. Well, we'll give up, then."
	DB	NEXT
;	DB	'【恵依美】：・・・星愛！'
	DB	"Meimi:  Seia!"
	DB	NEXT
;	DB	'【星愛】：・・・ですが、これだけは覚えておいて下さい。'
	DB	"Seia:  But please remember this."
	DB	NEXT
;	DB	'【星愛】：わたくし達・・・いいえ、貴方を知る人全てが、'
;	DB	'貴方の事を心配しています。'
	DB	"Seia:  Everyone who knows you is really worried about you."
	DB	NEXT
;	DB	'【星愛】：どうかそれだけは、忘れないで下さい。'
	DB	"Seia:  Please don't forget that."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................................"
	DB	NEXT
;	DB	'【%001】：ありがとな、吉田。ムチャはしないよ。'
	DB	"%001:  Thanks, both of you. I'll be careful."
	DB	NEXT
;	DB	'【星愛】：・・・はい！'
	DB	"Seia:  Okay."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ......................................."
	DB	NEXT
;	DB	'【%001】：・・・おっと、もうこんな時間か・・・そろそろ出ようぜ。'
	DB	"%001:  It's late. Let's get out of here."
	DB	NEXT
;	DB	'俺達は大量のゴミ（生産者は主に吉田と中野）を始末すると、外に出た。'
	DB	"We go outside."
	DB	NEXT
	DB	SINARIO,'CS803_2.OVL',0
	DW	0000H

M10:		;考える
;	DB	'こいつら、俺に隠し芸を見せたいのか？'
	DB	"Incredible. Simply incredible."
;	DB	FLG,F_COPYI,3,1
	DW	0000H

M11:		;考える
;	DB	'まったく、どいつもこいつも心配性なんだからなあ'
	DB	"Everyone's so worried about me. I wish they'd all just relax."
	DB	NEXT
;	DB	'・・・無責任に応援されてるより、そっちの方がありがたいけど。'
	DB	"I'll be okay."
	DB	FLG,F_COPYI,103,1
	DW	0000H


end
