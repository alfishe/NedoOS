;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０９
;		

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
CM2:	DW	VV2,	NN1,NN2,-1
CM3:	DW	VV3,	NN3,-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0
;VV4:	DB	4,	'立ち去る',0
VV4:	DB	4,	"LEAVE",0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	"MAKOTO",0
;NN2:	DB	2,	'瑠璃',0
NN2:	DB	2,	"RURI",0
;NN3:	DB	3,	'話題',0
NN3:	DB	3,	"CONVERSATION",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　誠
S2:		DW	VV1, NN2,  2, M3		;見る　瑠璃
S3:		DW	VV2, NN1,  3, M4, M5		;話す　誠
S4:		DW	VV2, NN2,  4, M6, M7, M8, M9, M10		;話す　瑠璃
S5:		DW	VV3, NN3,  5, M11, M12, M13		;考える　話題
S6:		DW	VV4, -1,  6, M14		;立ち去る


;イニシャルメッセージ
M1:
	DB	BGM,31
	BAK_INIT 'AB_06_3'
	E_CG B_NORM,'AE_013'
;	DB	'【%001】：白水さん・・・だよね。'
	DB	"%001:  Um, Ruri?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .............."
	DB	NEXT
;	DB	'【%001】：俺、山神　%001。白水さんと同じクラスだけど。'
	DB	"%001:  Hi, I'm %001 Yamagami. I'm in your class."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  .............."
	DB	NEXT
;	DB	'彼女は俺の声が聞こえないかのように、何の反応も示さなかった。'
	DB	".....Maybe she didn't hear me."
	DB G_FLG,G_COPYI,159,1	;瑠璃攻略不可
	DW	0000H

M2:		;見る　誠
;	DB	'何かを期待してるような目で俺を見ている。'
	DB	"He's looking at me."
	DW	0000H

M3:		;見る　瑠璃
;	DB	'大理石の彫像みたいに、ぴくりとも動かずに川を見ている。'
	DB	"She's sitting there looking at the river like she had been"
	DB	CR
	DB	"carved in stone."
	DB	NEXT
;	DB	'誠や中野が「人形みたい」って言ったのもうなずける・・・。'
	DB	"I can see now why Makoto and Meimi thought she looked"
	DB	CR
	DB	"like a doll."
	DW	0000H

M4:		;話す　誠
;	DB	'【誠】：%001、モテモテマンのお前なら彼女の心を開けるかもしれないぜ。'
	DB	"Makoto:  Since you're so popular, maybe you can open her"
	DB	CR
	DB	"heart..."
	DB	NEXT
;	DB	'【%001】：そのモテモテマンってのはやめてくれ。'
	DB	"%001:  Would you shut up already?"
	DW	0000H

M5:		;話す　誠
;	DB	'【%001】：誠、やっぱダメみたいだ。'
	DB	"%001:  I don't think she'll answer me."
	DB	NEXT
;	DB	'【誠】：%001でもダメか・・・。'
	DB	"Makoto:  Hmmm...."
	DW	0000H

M6:		;話す　瑠璃
;	DB	'【%001】：一人？'
	DB	"%001:  Um, are you alone?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............."
	DB	NEXT
;	DB	'【%001】：見ればわかるな、ははは・・・'
	DB	"%001:  Looks like it, I guess, hahaha."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M7:		;話す　瑠璃
;	DB	'【%001】：何してるの？'
	DB	"%001:  What are you doing here?"
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ............."
	DB	NEXT
;	DB	'【%001】：川を見てるんだね・・・。'
	DB	"%001:  I guess you're just watching the water."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M8:		;話す　瑠璃
;	DB	'【%001】：俺達サバイバルゲームやりに来たんだけどさ・・・'
	DB	"%001:  Well, we came to play a survival game...."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・邪魔なら消えるわ・・・'
	DB	"Ruri:  ....If I'm in the way, I'll leave."
	DB	NEXT
;	DB	'【%001】：いや、いいんだ！白水さんが先にいたんだから！'
	DB	"%001:  No, that's not what I meant!"
	DB	FLG,F_COPYI,3,1
	DB	FLG,F_COPYI,4,3
	DW	0000H


M9:		;話す　瑠璃
;	DB	'【%001】：・・・その、もしヒマだったらさ・・・',CR,'俺達と何かして遊ばないか？'
	DB	"%001:  Well, if you have time, do you want to hang out"
	DB	CR
	DB	"with us?"
	DB	NEXT
;	DB	'【瑠璃】：・・・どうして？'
	DB	"Ruri:  .....Why?"
	DB	NEXT
;	DB	'【%001】：俺達、クラスメイトだろ。'
	DB	"%001:  Well, you're our classmate."
	DB	NEXT
;	DB	'【瑠璃】：・・・やめておくわ・・・'
	DB	"Ruri:  .....No thanks."
	DB	NEXT
;	DB	'【%001】：・・・そう。'
	DB	"%001:  I see."
	DB G_FLG,G_COPYF,150,150	
	DB FLG,F_CALI,150,10	
	DB G_FLG,G_COPYG,150,150	
	DB G_FLG,G_COPYI,159,0	;瑠璃攻略可
	DB	FLG,F_COPYI,4,4
	DW	0000H

M10:		;話す　瑠璃
	DB	BUF,B_COPY01
	T_CG 'CT05','S',0,10,1
;	DB	'【瑠璃】：・・・あなたたち、ここを使いたいんでしょう。',CR,'私、帰るわ。'
	DB	"Ruri:  Well, you guys want to play here, right? I'll go"
	DB	CR
	DB	"home."
	DB	NEXT
;	DB	'【%001】：いや・・・俺達が帰るよ。'
	DB	"%001:  No, we'll leave."
	DB	NEXT
;	DB	'【%001】：ごめんな、邪魔しちゃって。'
	DB	"%001:  We're sorry we bothered you."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ............."
	DB	NEXT
;	DB	'【%001】：誠、他の場所に行くか。'
	DB	"%001:  Makoto, why don't we go somewhere else?"
	DB	NEXT
;	DB	'【誠】：ああ・・・仕方ないな。'
	DB	"Makoto:  Yeah, I guess we should."
	DB	NEXT
;	DB	'俺達は後ろ髪引かれる思いで立ち去った。'
	DB	"It was really hard to leave her there like that."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・'
	DB	"............................................"
	DB	NEXT
;	DB	'【瑠璃】：・・・どうして・・・？'
	DB	"Ruri:  .....Why?"
	DB	NEXT
;	DB	'【瑠璃】：・・・どうして、みんな私に構うの？'
	DB	"Ruri:  ......Why are they all so worried about me?"
	DB	NEXT
;	DB	'【瑠璃】：きずつくだけなのに・・・。'
	DB	"Ruri:  When all they do is hurt me......."
	DB	NEXT
	DB	BGM,0
	B_O B_WIPE
	DB	BGM,17
;	DB	'その翌日。'
	DB	"The next day."
	DB	NEXT
;	DB	'いよいよすることのなくなった俺は、街に出ることにした。'
	DB	"I couldn't think of anything to do, so I went into town."
	DB	NEXT
	DB SINARIO,'CS410_1.OVL',0
	DW	0000H

M11:		;考える　話題
;	DB	'【%001】：誠、何か話題ないか話題？'
	DB	"%001:  Makoto, isn't there something we can talk to her"
	DB	CR
	DB	"about?"
	DB	NEXT
;	DB	'【誠】：初日に使い切っちゃったよ。'
	DB	"Makoto:  I tried everything I could on the first day."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M12:		;考える　話題
;	DB	'【%001】：ん？'
	DB	"%001:  Hey, I've got an idea!"
	DB	NEXT
;	DB	'【誠】：なんだ%001？'
	DB	"Makoto:  What?"
	DB	NEXT
;	DB	'【%001】：・・・確か、吉田は彼女のこと「いい人」って言ってたよな。'
	DB	"%001:  Remember, Seia said that she was a good person."
	DB	NEXT
;	DB	'【誠】：ああ、「神を信じるか」って聞いたら、「もちろんいる」って答えたからだろ。'
	DB	"Makoto:  Right, Seia said she could see in Ruri's eyes that"
	DB	CR
	DB	"Ruri believed in God ."
	DB	NEXT
;	DB	'【%001】：・・・お前、神様の話なんか出来る？'
	DB	"%001:  Could you have a conversation about God?"
	DB	NEXT
;	DB	'【誠】：ドリフのコントくらいならね。'
	DB	"Makoto:  Hmmm, I don't think so."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M13:		;考える　話題
;	DB	'（う～ん・・・どんな話すれば答えてくれるんだ？）'
	DB	"What could we say that would get her to talk?"
	DW	0000H


M14:		;立ち去る
;	DB	'【%001】：誠、他の場所に行くか。'
	DB	"%001:  Makoto, why don't we go somewhere else?"
	DB	NEXT
;	DB	'【誠】：ああ・・・仕方ないな。'
	DB	"Makoto:  Yeah, I guess we should."
	DB	NEXT
;	DB	'俺達は後ろ髪引かれる思いで立ち去った。'
	DB	"It was really hard to leave her there like that."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・'
	DB	"........................"
	DB	NEXT
	B_O B_SUDA
;	DB	'その翌日。'
	DB	"The next day."
	DB	NEXT
;	DB	'いよいよすることのなくなった俺は、街に出ることにした。'
	DB	"I couldn't think of anything to do, so I went into town."
	DB	NEXT
	DB SINARIO,'CS410_1.OVL',0
	DW	0000H



end
