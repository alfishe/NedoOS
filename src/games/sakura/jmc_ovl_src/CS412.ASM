;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４１２
;		河原の恵依美

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN1,-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'帰る',0
VV4:	DB	4,	'GO HOME',0
;VV5:	DB	5,	'立ち去る',0
VV5:	DB	5,	'LEAVE',0

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	'MEIMI',0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　恵依美３
S2:		DW	VV2, NN1,  2, M6, M7, M8, M9, M10, M11, M12		;話す　恵依美７
S3:		DW	VV3, NN1,  3, M13, M14, M15, M16		;考える　恵依美３
S4:		DW	VV4, -1,  4, M17		;帰る
S5:		DW	VV5, -1,  5, M18		;立ち去る１


;イニシャルメッセージ
M1:
	DB	BGM,16
	BAK_INIT 'AB_06_3'
	B_P1 B_SUDA
;	DB	'俺は昨日の土手までやって来た。'
	DB	"I'm back at the river where we were yesterday."
	DB	NEXT
;	DB	'【%001】：ん？誰かいるな・・・'
	DB	"%001:  Mm? Somebody's here."
	DB	NEXT
;	DB	'【%001】：・・・あれは・・・'
	DB	"%001:  ........It's....."
	DB	NEXT
	E_CG B_SUDA,'AE_014'
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ..........................."
	DB	NEXT
;	DB	'【%001】：中野じゃないか？・・・・・何やってんだ？あんなとこで。'
	DB	"It's Meimi! What's she doing down here?"
	DB C_BLD,C_V_ON,2
	DB	C_BLD,C_V_ON,4
	DW	0000H

M2:		;見る　恵依美１
;	DB	'（間違いない、ありゃあ中野だ。）'
	DB	"It's Meimi."
	DB	NEXT
;	DB	'（・・・・・・一体、何やってんだ？）'
	DB	"What's she doing down here?"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　恵依美２
;	DB	'（川なんかじっと見詰めちゃって・・・・・・白水さんの真似でもしてるのか？）'
	DB	"She's staring out at the water...Is she doing an immitation"
	DB	CR
	DB	"of Ruri or something?"
	DB	NEXT
;	DB	'（・・・・・・・・・）'
	DB	".........................."
	DB	NEXT
;	DB	'（誰もいないところで物真似やるバカはいないか。大体、中野に白水さんの真似なんか出来る訳がない。）'
	DB	"No one would do immitations of people with no one else"
	DB	CR
	DB	"around. That can't be it."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　恵依美３
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ........................"
	DB	NEXT
;	DB	'ひゅっ。',CR
	DB	"*SKIP*"
	DB	PAUSE
;	DB	'ぽちゃん。'
	DB	" *KERSPLASH*"
	DB	NEXT
;	DB	'【%001】：・・・なんだなんだおい、川に石なんて投げ始めたぞ。'
	DB	".....What? Now she's throwing rocks into the river."
	DB	FLG,F_COPYI,1,3
	DB C_BLD,C_V_OFF,2
	DW	0000H

M5:		;見る　恵依美4
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"%001:  .............."
	DB	NEXT
;	DB	'ひゅっ。',CR
	DB	"*SKIP*"
	DB	PAUSE
;	DB	'ぽちゃん。'
	DB	" *KERSPLASH*"
	DB	NEXT
;	DB	'【%001】：・・・・・・なんか、本格的に落ち込んでるみたいだな。'
	DB	"......She really seems depressed about something."
	DW	0000H

M5_B:		;見る　恵依美５
;	DB	'【%001】：中野は、もういないぞ。'
	DB	"She's not here anymore."
	DW	0000H

M6:		;話す　恵依美１
;	DB	'【%001】：・・・そうだな。ちょっと元気付けてやるか。'
	DB	"I guess I should go try to cheer her up or something."
	DB	NEXT
;	DB	'俺は足元の石を拾い、中野の背後に忍び寄った。'
	DB	"I pick up a rock lying by my feet and sneak over to her."
	DB	NEXT
;	DB	'【%001】：・・・よっ！'
	DB	"%001:  .........*THROW*"
	DB	NEXT
;	DB	'ひゅっ。',CR
	DB	"*SKIP*"
	DB	PAUSE
;	DB	'ぱしゃっぱしゃっぱしゃっぱしゃっ・・・・・・'
	DB	" *SKIP* *SKIP* *SKIP* *SKIP* *KERSPLASH*"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT08','C','D',10,1	
;	DB	'【恵依美】：・・・！'
	DB	"Meimi:  ...........!"
	DB	NEXT
;	DB	'【%001】：・・・よ。'
	DB	"%001:  ..........Hi, Meimi."
	DB	FLG,F_COPYI,2,1
	DB C_BLD,C_V_ON,5
	DW	0000H

M7:		;話す　恵依美２
;	DB	'【%001】：・・・どしたい、こんなところで？'
	DB	"%001:  What's the matter? Why are you out here all alone?"
	DB	NEXT
;	DB	'【恵依美】：・・・べっつにー！！'
	DB	"Meimi:  Oh, no reason!"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..................."
	DB	NEXT
;	DB	'【%001】：中野・・・なんか怒ってないか？'
	DB	"%001:  Meimi? Are you angry about something?"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M8:		;話す　恵依美３
;	DB	'【%001】：なあ・・・・・・なんかあったのか？'
	DB	"%001:  Did anything happen?"
	DB	NEXT
;	DB	'【恵依美】：%001には、カンケー無いでしょ！フンだっ！！'
	DB	"Meimi:  It has nothing to do with you. Why don't you go"
	DB	CR
	DB	"away?"
	DB	NEXT
;	DB	'びゅっ！',CR
	DB	"*SKIP*"
	DB	PAUSE
;	DB	'ぱしゃぱしゃぱしゃぱしゃ・・・・・・'
	DB	" *SKIP* *SKIP* *SKIP* *SKIP* ......"
	DB	NEXT
;	DB	'【%001】：・・・へ～、結構やるじゃんか。'
	DB	"%001:  That was a good throw."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・（ムカッ）'
	DB	"Meimi:  ..............................."
	DB	NEXT
;	DB	'びゅっ！',CR
	DB	"*SKIP*"
	DB	PAUSE
;	DB	'ぱしゃぱしゃぱしゃぱしゃ・・・・・・'
	DB	" *SKIP* *SKIP* *SKIP*...."
	DB	NEXT
;	DB	'【%001】：・・・お、惜しい。'
	DB	"%001:  .....Oh, that one wasn't that good."
	DB	NEXT
;	DB	'あと５つくらいで、俺のと並ぶぜ。'
	DB	"%001:  You'll need to skip the stone about five more times"
	DB	CR
	DB	"to tie my record."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・（ムカムカッ）'
	DB	"Meimi:  ......................!!"
	DB	NEXT
;	DB	'びゅっ！',CR
	DB	"*SKIP*"
	DB	PAUSE
;	DB	'ぱしゃぱしゃぱしゃぱしゃ・・・・・・'
	DB	" *SKIP* *SKIP* *SKIP* *SKIP* ......"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"......................................."
	DB	NEXT
;	DB	'【恵依美】：・・・ぜーっぜーっぜーっぜーっ・・・'
	DB	"Meimi:  *pant*.....*pant*.....*pant*.....*pant*.....*pant*....."
	DB	NEXT
;	DB	'【%001】：・・・大丈夫か？'
	DB	"%001:  ........Are you alright?"
	DB	NEXT
	K_CG 'CT08','I',10,2
;	DB	'【恵依美】：・・・う゛～～～～～～～～～っ・・・'
	DB	"Meimi:  ..........*sob*!!"
	DB	NEXT
;	DB	'【%001】：・・・そんな事で半泣きにならなくても・・・'
	DB	"%001:  Are you going to cry now? I wish you'd tell me"
	DB	CR
	DB	"what was wrong."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M9:		;話す　恵依美４
;	DB	'【%001】：・・・ふう。いいか、まずは石を良く見るんだ。'
;	DB	'なるべく平らな奴がいい。・・・そうだな、これなんか大きさも丁度いいな。ほれ。'
	DB	"%001:  Okay, first, you have to look at the rock, and find"
	DB	CR
	DB	"the flat part. That's right."
	DB	NEXT
;	DB	'【恵依美】：・・・%001？'
	DB	"Meimi:  .....%001?"
	DB	NEXT
;	DB	'【%001】：い～からい～から。・・・あと投げ方だけど、完全な'
;	DB	'サイドスローより少しアンダー気味に投げるといい。腕は真っ直ぐ'
;	DB	'伸ばして、腰の回転で投げるんだ。'
	DB	"%001:  Just do what I tell you. A side throw is not what"
	DB	CR
	DB	"you want to accomplish here. Try throwing it slightly"
	DB	CR
	DB	"underhanded, like this. Remember to keep your arm straight."
	DB	NEXT
;	DB	'【恵依美】：・・・う、うん。'
	DB	"Meimi:  ....Alright."
	DB	NEXT
;	DB	'【%001】：肝心なのは、力まない事さ。必要な力を、必要なところに'
;	DB	'ムダ無く伝えるだけでいい。・・・不必要な力ってのは、ロクな事しない'
;	DB	'からな・・・・・・'
	DB	"%001:  Remember not to put too much power into your throw."
	DB	CR
	DB	"Just enough, that's the secret. Power that you don't need"
	DB	CR
	DB	"is useless."
	DB	NEXT
;	DB	'・・・・・・'
	DB	"........................."
	DB	NEXT
;	DB	'そう、俺には必要無いんだ。'
	DB	"That's right. Useless...."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・%001？'
	DB	"Meimi:  ........%001?"
	DB	NEXT
;	DB	'【%001】：・・・え？'
	DB	"%001:  .....Huh?"
	DB	PAUSE
;	DB	'何だよ中野、そんな顔して・・・'
	DB	"Why are you looking at me like that?"
	DB	NEXT
	T_CG 'CT08','C',0,10,3
;	DB	'【恵依美】：・・・え？あ、ううん・・・何でもないの。'
	DB	"Meimi:  Eh? No, it's nothing. Nevermind!"
	DB	NEXT
;	DB	'【%001】：？'
	DB	"%001:  ???"
	DB	FLG,F_COPYI,2,4
	DW	0000H

M10:		;話す　恵依美５
;	DB	'【%001】：・・・ま、いいや。やってみそ。'
	DB	"%001:  Okay, why don't you try it?"
	DB	NEXT
;	DB	'【恵依美】：・・・う、うん。'
	DB	"Meimi:  Alright."
	DB	NEXT
;	DB	'ひゅっ。',CR
	DB	"*SKIP*"
	DB	PAUSE
;	DB	'ぱしゃっぱしゃっぱしゃっぱしゃっ・・・・・・'
	DB	" *SKIP* *SKIP* *SKIP* *SKIP* *SKIP* *SKIP* *SKIP* ....."
	DB	NEXT
;	DB	'【%001】：お～、凄いじゃね～か。'
	DB	"%001:  Wow, that was great!"
	DB	NEXT
	K_CG 'CT08','K',10,4
;	DB	'【恵依美】：やったぁ！'
	DB	"Meimi:  I did it!"
	DB	NEXT
;	DB	'【%001】：・・・え～っと、俺より２つ先かぁ・・・参ったねこりゃ。'
	DB	"%001:  You beat me by two skips. You're the winner."
	DB	NEXT
;	DB	'【恵依美】：・・・えっへっへっへっへっ・・・'
	DB	"Meimi:  Hahahahaha! I won!"
	DB	FLG,F_COPYI,2,5
	DB	FLG,F_COPYI,3,1
	DW	0000H

M11:		;話す　恵依美６
;	DB	'【恵依美】：・・・あれ？'
	DB	"Meimi:  Wow."
	DB	NEXT
;	DB	'【%001】：何だ？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【恵依美】：もうこんなに暗くなっちゃってるの！？'
	DB	"Meimi:  Look how dark it's gotten!"
	DB	NEXT
;	DB	'【%001】：・・・何を言ってるんだ今更。'
	DB	"%001:  Well, of course. The sun's going down."
	DB	NEXT
;	DB	'【恵依美】：・・・ごめん、もう帰らなくっちゃ。'
	DB	"Meimi:  I'm sorry. I've got to get home."
	DB	NEXT
;	DB	'【%001】：そか。気ィ付けてな。'
	DB	"%001:  Oh. Well, take care."
	DB	NEXT
;	DB	'【恵依美】：・・・うん。じゃね～%001！'
	DB	"Meimi:  ...Thanks. I'll see you later, %001!"
	DB	NEXT
	B_P1 B_SUDA				;恵依美消し
;	DB	'【%001】：おう。'
	DB	"%001:  Sure."
	DB	PAUSE
;	DB	'・・・って、もういやしない。'
	DB	".......Bye."
	DB	FLG,F_COPYI,1,3
	DB	FLG,F_COPYI,2,6
	DB	FLG,F_COPYI,3,2
	DB G_FLG,G_COPYF,180,180
	DB	FLG,F_CALI,180,10
	DB G_FLG,G_COPYG,180,180
	DB	C_BLD,C_V_ON,1
	DB	C_BLD,C_V_OFF,4
	DW	0000H

M12:		;話す　恵依美７
;	DB	'【%001】：中野は、もういないぞ。'
	DB	"%001:  She's not here anymore."
	DW	0000H

M13:		;考える　恵依美１
;	DB	'・・・なんか、みょ～にたそがれてるな・・・らしくもねぇ。'
	DB	"She seems really depressed. I wonder what's wrong."
	DW	0000H

M14:		;考える　恵依美２
;	DB	'・・・ふう。何とか、いつもの中野になったみたいだな。'
	DB	".....She seems a little odd today."
	DW	0000H

M15:		;考える　恵依美３
;	DB	'それにしても、一体あいつ何を悩んでたんだ？'
	DB	"I wonder what's bothering her?"
	DB	NEXT
;	DB	'途中から水切りの話になっちまったから、結局わかんなかったぞ。'
	DB	"We started skipping these stones, so I guess I'll never know..."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"................................."
	DB	NEXT
;	DB	'よく考えたら、俺のせいだな。話がそれたの。'
	DB	"Now that I think about it, I'm the one who started talking"
	DB	CR
	DB	"about skipping stones."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M16:		;考える　恵依美４
;	DB	'・・・・・・まぁいいか。あのくらいで忘れられるんなら、大した話でも'
;	DB	'なかったんだろう。'
	DB	"Oh well. She seems alright now. It must not have"
	DB	CR
	DB	"been important."
	DW	0000H

M17:		;帰る
;	DB	'【%001】：・・・さて、俺もそろそろ帰るか。'
	DB	"%001:  Well, I guess I'll head home."
	DB	PAUSE,CR
;	DB	'・・・よっ！'
	DB	"*THROW*"
	DB	NEXT
;	DB	'ひゅっ。',CR
	DB	"*SKIP*"
	DB	PAUSE
;	DB	'ぱしゃっぱしゃっぱしゃっぱしゃっ・・・・・・'
	DB	" *SKIP* *SKIP* *SKIP* *SKIP* *SKIP* *SKIP* *SKIP* "
	DB	CR
	DB	"*SKIP* ...."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【%001】：中野の更に３つ先、か・・・・・・'
	DB	"%001:  Three more skips than what Meimi threw..."
	DB	NEXT
;	DB	'【%001】：・・・・・・フルパワーで投げなくて良かったな、やっぱ。'
	DB	"%001:  I'm glad I held back the first time."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..................."
	DB	NEXT
;	DB	'【%001】：さ、帰ろ。'
	DB	"%001:  Well, let's go home."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS501.OVL',0
	DW	0000H

M18:		;立ち去る１
;	DB	'【%001】：・・・そうだな、邪魔しちゃ悪いか。'
;	DB	'誰だって、１人になりたい時はあるさ。'
	DB	"Yes, I guess she doesn't want to be disturbed right now. "
	DB	NEXT
;	DB	'俺は、河原を後にした。'
	DB	"I leave the river."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS501.OVL',0
	DW	0000H

end
