;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　９０４＿Ｈ
;		二人だけの夜　恵依美編

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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	'MEIMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5, M6		;見る　恵依美５
S2:		DW	VV2, NN1,  2, M7, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20		;話す　恵依美１３


;イニシャルメッセージ
M1:
	DB	BGM,13
	BAK_INIT "AB_04_3"
	DB	BUF,B_COPY01
;	DB	'【%001】：・・・ふ～、流石に寒いな。'
	DB	"%001:  Wow, it's really cold."
	DB	NEXT
	T_CG "CT08","W",0,0,1
;	DB	'【恵依美】：そりゃあそ～よ。だってクリスマスなんだし。'
	DB	"Meimi:  Of course. It is Christmas Eve."
	DB	NEXT
;	DB	'【%001】：・・・ごもっとも。'
	DB	"%001:  You're right."
	DW	0000H

M2:		;見る　恵依美１
;	DB	'いつもと同じ中野だ。'
	DB	"It's just Meimi, the same Meimi who I see at school every"
	DB	CR
	DB	"day."
	DB	PAUSE
;	DB	'・・・と思う。'
	DB	"............I think."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　恵依美２
;	DB	'いつもと同じはずなんだが・・・何だろう？この違和感は・・・'
	DB	"She seems normal. But something's strange about her."
;	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　恵依美３
;	DB	'子供みたいにはしゃいでる。'
	DB	"She's waving her arms in the air as she walks."
	DB	NEXT
;	DB	'（・・・やっぱり、中野はこんな笑顔が良く似合うな。）'
	DB	"She's really cute when she smiles."
;	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;見る　恵依美４
;	DB	'俺にぴったり寄り添っている。'
	DB	"She's pressing herself up against me as she walks."
	DB	NEXT
;	DB	'・・・ど～したんだ一体？）'
	DB	"What's up with her?"
;	DB	FLG,F_COPYI,1,4
	DW	0000H

M6:		;見る　恵依美５
;	DB	'・・・・・・泣いている・・・・・・あの中野が・・・・・・'
	DB	"Meimi is...........crying!"
	DB	NEXT
;	DB	'（・・・お前・・・そんなに俺の事を・・・）'
	DB	"(Meimi...... I didn't know you felt that way.)"
	DW	0000H

M7:		;話す　恵依美１
;	DB	'【恵依美】：・・・なんか、久し振りだね。'
	DB	"Meimi:  It's been a long time, hasn't it?"
	DB	NEXT
;	DB	'【%001】：・・・何が？'
	DB	"%001:  What has?"
	DB	NEXT
;	DB	'【恵依美】：こうやって、%001と２人で歩くのって。'
	DB	"Meimi:  ....Since we walked together like this."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか？'
	DB	"%001:  .................Really?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ..............."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M8:		;話す　恵依美２
;	DB	'【恵依美】：・・・ね、ねえ%001。覚えてる？臨海学校であたしと散歩した時の事・・・'
	DB	"Meimi:  D- Do you remember the seaside school?"
	DB	NEXT
;	DB	'【%001】：・・・・・・ああ、覚えてるぜ。'
	DB	"%001:  Yeah, I remember it."
	DB	NEXT
;	DB	'【恵依美】：あの時も・・・こうやって２人で歩いたよね。'
	DB	"Meimi:  We were alone, then, too."
	DB	NEXT
;	DB	'【%001】：・・・ああ、そうだな。'
	DB	"%001:  That's right."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ..................."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M9:		;話す　恵依美３
;	DB	'【恵依美】：・・・あ、それからさ%001！'
	DB	"Meimi:  ....Also, back when you were practicing for the"
	DB	CR
	DB	"sports festival, you used to walk me home sometimes."
	DB	PAUSE
;	DB	'体育祭の練習の時、あたしを送ってくれたよね？'
	DB	" Remember?"
	DB	NEXT
;	DB	'【%001】：・・・・・・ああ、そうだったな。'
	DB	"%001:  ........Yes, I do."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ........................."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M10:		;話す　恵依美４
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ........................"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................."
	DB	NEXT
;	DB	'（・・・なんか・・・気まずいなあ。）'
	DB	"(One of us has to say something!)"
	DB	NEXT
;	DB	'【恵依美】：・・・あ！'
	DB	"Meimi:  Look!"
	DB	NEXT
;	DB	'【%001】：・・・・・・雪か？'
	DB	"%001:  It's snowing."
	DB	FLG,F_COPYI,2,4
	DB	FLG,F_COPYI,1,2
	DW	0000H

M11:		;話す　恵依美５
	K_CG 'CT08','K',0,1
;	DB	'【恵依美】：%001！見て見て、雪だよ！'
	DB	"Meimi:  %001, look! Snow!"
	DB	NEXT
;	DB	'【%001】：・・・・・・ホワイトクリスマスか・・・・・・'
	DB	"%001:  We'll have a white Christmas tomorrow."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M12:		;話す　恵依美６
;	DB	'【恵依美】：・・・あ。'
	DB	"Meimi:  Oh no!"
	DB	NEXT
;	DB	'【%001】：・・・・・・やんじまったな。'
	DB	"%001:  ........It stopped snowing already."
	DB	NEXT
	K_CG 'CT08','I',0,1
;	DB	'【恵依美】：・・・うん・・・'
	DB	"Meimi:  .........Darn."
	DB	FLG,F_COPYI,2,6
	DW	0000H

M13:		;話す　恵依美７
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ......................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'（・・・うーむ・・・再び気まずいぞ。）'
	DB	"(It got quiet again.)"
	DB	NEXT
;	DB	'【恵依美】：・・・ねえ、%001。'
	DB	"Meimi:  %001?"
	DB	FLG,F_COPYI,2,7
	DW	0000H

M14:		;話す　恵依美８
;	DB	'【%001】：・・・ん？'
	DB	"%001:  .............Mm?"
	DB	NEXT
;	DB	'ぴとっ。'
	DB	"Meimi:  *sob*"
	DB	NEXT
;	DB	'【%001】：・・・お、おい中野！？'
	DB	"%001:  Meimi? What's the matter?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ......................."
	DB	FLG,F_COPYI,2,8
	DB	FLG,F_COPYI,1,3
	DW	0000H

M15:		;話す　恵依美９
;	DB	'【%001】：・・・一体ど～したんだ？どっか痛いのか？'
	DB	"%001:  What's wrong. Did you hurt yourself?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・こんな風に・・・・・・'
	DB	"Meimi:  ........I just wanted..."
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  "
	DB	PAUSE
;	DB	'雪が降っている内に、こんな風にしてくれる女の子の方が・・・・・・・・・'
	DB	" It would have been so romantic, with the snow falling"
	DB	CR
	DB	"all around us..."
	DB	NEXT
;	DB	'【%001】：・・・中・・・野・・・？'
	DB	"%001:  .........Meimi?"
	DB	FLG,F_COPYI,2,9
	DW	0000H

M16:		;話す　恵依美１０
;	DB	'【%001】：・・・中野・・・一体ど～したっていうんだ？'
	DB	"%001:  Meimi, what's wrong?"
	DB	PAUSE
;	DB	'今日のお前・・・'
	DB	" You've been acting strangely"
	DB	CR
	DB	"all day."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ...................."
	DB	PAUSE
	K_CG 'CT08','K',0,1
;	DB	'な～んちゃって！'
	DB	"Just kidding!"
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【恵依美】：冗談よ、冗談・・・'
	DB	"Meimi:  I was teasing you."
	DB	PAUSE
;	DB	'だって%001・・・'
	DB	" I mean, come on, %001. You've"
	DB	CR
	DB	"got..."
	DB	NEXT
;	DB	'%001・・・'
	DB	"Meimi:  You've got..."
	DB	PAUSE
;	DB	'好きな娘・・・いるんでしょ？'
	DB	"someone else, right? Some other person"
	DB	CR
	DB	"besides me?"
	DB	FLG,F_COPYI,2,10
	DW	0000H

M17:		;話す　恵依美１１
;	DB	'【%001】：・・・い゛？'
	DB	"%001:  ......"
	DB	PAUSE
;	DB	'中野、お前何言って・・・'
	DB	"Meimi, what are you...?"
	DB	NEXT
;	DB	'【恵依美】：でも・・・'
	DB	"Meimi:  I just..."
	DB	PAUSE
	K_CG 'CT08','I',0,1
;	DB	'でも・・・っ・・・！'
	DB	" I just..."
	DB	NEXT
;	DB	'【恵依美】：あたし、もう・・・'
	DB	"Meimi:  I can't do it anymore. I can't!"
	DB	PAUSE
;	DB	'嘘つけないよ。我慢出来ないよ！'
	DB	" I can't go on like"
	DB	CR
	DB	"this!"
	DB	NEXT
;	DB	'%001・・・・・・'
	DB	"Meimi:  %001..........."
	DB	PAUSE
;	DB	'好きなの！'
	DB	"I love you!"
	DB	PAUSE
;	DB	'好きなのっ！！'
	DB	" I love you!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・な・・・・・・・・・'
	DB	"%001:  ............."
	DB	FLG,F_COPYI,2,11
	DB	FLG,F_COPYI,1,4
	DW	0000H

M18:		;話す　恵依美１１
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  .........."
	DB	PAUSE
;	DB	'ごめん！！'
	DB	"I'm sorry!!"
	B_P1 B_SUDA
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ....................."
	DB	PAUSE
;	DB	'あ、おい待てよ！！'
	DB	"Hey, wait!"
	DB	NEXT
;	DB	'【%001】：・・・捕まえた！'
	DB	"%001:  ........I got you!"
	DB	NEXT
	T_CG "CT08","W",'I',0,0
;	DB	'【恵依美】：・・・う・・・ううっ・・・'
	DB	"Meimi:  *sob*"
	DB	NEXT
;	DB	'【%001】：・・・中野・・・お前・・・'
	DB	"%001:  ..........Meimi, I..."
	DB	FLG,F_COPYI,2,12
	DW	0000H

M19:		;話す　恵依美１２
;	DB	'【%001】：・・・中野・・・'
	DB	"%001:  Meimi, listen to me."
	DB	NEXT
;	DB	'【恵依美】：・・・うぅっ・・・ひっく・・・'
	DB	"Meimi:  *sob*"
	DB	NEXT
;	DB	'【%001】：ごめんな、中野・・・'
	DB	"%001:  Forgive me..."
	DB	NEXT
;	DB	'【%001】：・・・お前が俺の事、そんな風に思ってくれていたなんて、'
;	DB	'全然気が付かなかった・・・'
	DB	"%001:  I had no idea you felt that way about me."
	DB	NEXT
;	DB	'【恵依美】：・・・ぐすっ・・・'
	DB	"Meimi:  .......*sob*..... You didn't?"
	DB	NEXT
;	DB	'【%001】：・・・・・・中野。考えてみれば・・・・・・'
;	DB	'お前はいつでも、俺を応援してくれたよな。'
	DB	"%001:  Now that I think about it, you were always there"
	DB	CR
	DB	"for me, always supporting me."
	DB	NEXT
;	DB	'【%001】：・・・・・・だから今度は・・・・・・'
	DB	"%001:  And I..."
	DB	NEXT
;	DB	'【%001】：中野、お前の事を応援させてくれないか・・・お前の側で。'
;	DB	'もう二度と、辛い思いはさせないから・・・・・・'
	DB	"%001:  Meimi, I want you keep on being there for me, at my"
	DB	CR
	DB	"side. I love you, too, Meimi."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・！'
	DB	"Meimi:  ........!!"
	DB	FLG,F_COPYI,2,13
	DW	0000H

M20:		;話す　恵依美１３
;	DB	'【恵依美】：・・・いいの？%001、あたしなんかで・・・'
	DB	"Meimi:  Do you want...me?"
	DB	NEXT
;	DB	'【%001】：・・・・・・ああ。お前でなくちゃダメなんだ。'
	DB	"%001:  .....Yes. You're the only one I want."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・%001・・・・・・！'
	DB	"Meimi:  ...........%001!"
	E_CG B_FADE,'AE_101'
	DB	NEXT
;	DB	'俺を見詰める中野の瞳が、そっと閉じられる。'
	DB	"Meimi's eyes, still full of tears, slowly close."
	DB	NEXT
;	DB	'俺はゆっくりと顔を近付け・・・・・・'
	DB	"I move my face towards hers."
	DB	NEXT
;	DB	'桜色の唇に、そっと口付けをした。'
	DB	"I press my mouth against her sakura-colored lips."
	DB	NEXT
;	DB	'【恵依美】：%001・・・大好き・・・！'
	DB	"Meimi:  %001......I'm so happy!"
	DB	NEXT
;	DB	'【%001】：・・・中野・・・俺もだよ・・・'
	DB	"%001:  ..........Meimi, so am I."
	DB	NEXT
;	DB	'【恵依美】：%001・・・・・・もう一度、して・・・・・・'
	DB	"Meimi:  %001, please, kiss me again."
	DB	PAUSE
;	DB	'夢じゃないって、信じられるまで・・・・・・'
	DB	" I want to make"
	DB	CR
	DB	"sure I'm not dreaming this."
	DB	NEXT
;	DB	'【%001】：ああ・・・・・・いいとも。'
	DB	"%001:  Alright."
	DB	NEXT
;	DB	'俺は中野を抱きしめ、再び熱い口付けを交わした。'
	DB	"I take Meimi into my arms and kiss her softly again."
	DB	NEXT
	DB	SINARIO,'CSE_H_1.OVL',0
	DW	0000H


end
