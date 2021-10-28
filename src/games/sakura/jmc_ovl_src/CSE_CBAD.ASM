;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　ＣＳＥ＿ＣＢＡＤ
;		美緒バッドエンド

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

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	'MIO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　美緒
S2:		DW	VV2, NN1,  2, M3, M4, M5	;話す　美緒２


;イニシャルメッセージ
M1:
	DB	BGM,19
	BAK_INIT 'AB_12_2'
	DB BUF,B_COPY01
	T_CG 'CT03','W',0,15,1
;	DB	'【美緒】：%001先輩・・・？'
	DB	"Mio:  %001...."
	DW	0000H

M2:		;見る　美緒
;	DB	'美緒ちゃんは目をぱちくりさせて俺を見ている。'
	DB	"She's looking at me with doubt in her eyes."
	DW	0000H

M3:		;話す　美緒１
;	DB	'【%001】：美緒ちゃん・・・俺・・・'
	DB	"%001:  Mio.....I....."
	DB	NEXT
;	DB	'【美緒】：・・・なに・・・？'
	DB	"Mio:  ...Yes?"
	DB FLG,F_COPYI,2,1
	DB FLG,F_EXIT,167
	DB FLG,F_COPYI,2,3
	DW	0000H

M4:		;話す　美緒２
;	DB	'【%001】：・・・俺、美緒ちゃんに大事な話があるんだ！'
	DB	"%001:  ...I've got something to talk to you about!"
	DB	NEXT
;	DB	'【%001】：ちょっと付き合ってくれないかな？'
	DB	"%001:  Will you come with me?"
	DB	NEXT
;	DB	'【美緒】：それって、ここじゃ出来ないような話なの？'
	DB	"Mio:  What could you want to talk to be about that can't"
	DB	CR
	DB	"be taken care of right here?"
	DB	NEXT
;	DB	'【%001】：その・・・バレンタインの・・・'
	DB	"%001:  Um...you know...Valentine's Day..."
	DB	NEXT
;	DB	'【美緒】：・・・・・・'
	DB	"Mio:  ......................"
	DB	NEXT
;	DB	'【美緒】：・・・亜希ちゃんならここにはいないよ。'
	DB	"Mio:  ......Aki's not here. Look somewhere else."
	DB	NEXT
;	DB	'【%001】：へっ？！'
	DB	"%001:  What?!"
	DB	NEXT
;	DB	'【美緒】：亜希ちゃんからみんな聞いた。クリスマスのこととか・・・'
	DB	"Mio:  I heard all about it from Aki... What happened on"
	DB	CR
	DB	"Christmas Eve and everything..."
	DB	NEXT
;	DB	'【%001】：！！！'
	DB	"%001:  !!"
	DB	NEXT
	K_CG 'CT03','K',15,2
;	DB	'【美緒】：悔しいけど・・・、亜希ちゃんと仲良くね。'
	DB	"Mio:  I'm sorry it had to end up this way. Please give"
	DB	CR
	DB	"my best to Aki."
	DB	NEXT
	B_P1 B_TATE
;	DB	'美緒ちゃんはにっこり微笑んで、走っていってしまった。'
	DB	"Mio smiled one last time, then ran off."
	DB	NEXT
	DB	FLG,F_JR
	DW	M_ENDE
	DW	0000H


M5:		;話す　美緒３
;	DB	'【%001】：・・・俺、美緒ちゃんに大事な話があるんだ！'
	DB	"%001:  ...I've got something to talk to you about!"
	DB	NEXT
;	DB	'【%001】：ちょっと付き合ってくれないかな？'
	DB	"%001:  Will you come with me?"
	DB	NEXT
;	DB	'【美緒】：それって、ここじゃ出来ないような話なの？'
	DB	"Mio:  What could you want to talk to be about that can't"
	DB	CR
	DB	"be taken care of right here?"
	DB	NEXT
;	DB	'【%001】：その・・・バレンタインの・・・'
	DB	"%001:  Um...you know...Valentine's Day..."
	DB	NEXT
;	DB	'【美緒】：・・・・・・'
	DB	"Mio:  ......................"
	DB	NEXT
;	DB	'【美緒】：・・・言わなくてもいい・・・分ってる。'
	DB	"Mio:  You don't have to break the bad news to me. I already"
	DB	CR
	DB	"know."
	DB	NEXT
;	DB	'【%001】：美緒ちゃん・・・！'
	DB	"%001:  Mio...?"
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・ムネが大きい人が好きなんでしょ？'
	DB	"Mio:  You like women with large breasts, after all..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・は？'
	DB	"%001:  What?"
	DB	NEXT
	K_CG 'CT03','I',15,3
;	DB	'【美緒】：・・・先輩・・・あの人・・・と・・・',CR,'幸せになってね・・・！'
	DB	"Mio:  ........I know there's someone you love more than me."
	DB	NEXT
	DB	"Mio:  I hope you're..... I hope you're happy with her."
	DB	NEXT
	B_P1 B_TATE
;	DB	'美緒ちゃんはぼろぼろ泣きながら、走っていってしまった。'
	DB	"Tears welling up in her eyes, Mio ran off."
	DB	NEXT
	DB	FLG,F_JR
	DW	M_ENDE
	DW	0000H


M_ENDE:
;	DB	'【%001】：み、美緒ちゃん・・・！？'
	DB	"%001:  Mio, come back...!!"
	DB	NEXT
;	DB	'追いかけようとした俺は、後から肩を叩かれた。'
	DB	"I started to chase her, but a hand stopped me."
	DB	NEXT
	DB	BGM,28
	DB BUF,B_COPY01
	T_CG 'CT12','T',0,20,8
;	DB	'【今日子】：%001君、残念だったわね。'
	DB	"Kyoko:  I'm sorry it had to end this way, %001."
	DB	NEXT
;	DB	'【%001】：きょ、今日子先生・・・'
	DB	"%001:  K- Kyoko-sensei!"
	DB	NEXT
	K_CG 'CT12','K',20,7
;	DB	'【今日子】：・・・ま、今夜は%001君のフラレ記念で、朝まで飲みましょーか！'
	DB	"Kyoko:  But don't worry. I've decided to have a 'Broken"
	DB	CR
	DB	"Heart Party.' We're going to drink all night!"
	DB	NEXT
;	DB	'【%001】：げげげっ！'
	DB	"%001:  No! Anything but that!"
	DB	NEXT
	B_O B_SUDA
;	DB	'こうして俺は、今日子先生に一晩中振り回された挙げ句、急性アルコール中毒で入院した。'
	DB	"After a night of drowning my sorrows with Kyoko-sensei,"
	DB	CR
	DB	"I was admitted to a hospital for treatment for acute"
	DB	CR
	DB	"alcoholism."
	DB	NEXT
;	DB	'【今日子】：ま、それも青春じゃない？'
	DB	"Kyoko:  Well, that's youth for you..."
	DB	NEXT
;	DB	'【%001】：・・・こんな青春は認めねーッ！'
	DB	"%001:  ......This isn't what I wanted!"
	DB	NEXT
	DB	GAMEOVER
	DW	0000H

end
