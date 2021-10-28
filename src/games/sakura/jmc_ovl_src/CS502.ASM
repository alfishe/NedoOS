;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０２
;		林間学校　到着～テント張り

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,NN2,NN3,-1
CM3:	DW	VV3,	NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	'MAKOTO',0
;NN2:	DB	2,	'亜希',0
NN2:	DB	2,	'AKI',0
;NN3:	DB	3,	'美緒',0
NN3:	DB	3,	'MIO',0
;NN4:	DB	4,	'仕事',0
NN4:	DB	4,	'WORK',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　誠１
S2:		DW	VV1, NN2,  2, M3		;見る　亜希１
S3:		DW	VV1, NN3,  3, M4		;見る　美緒１
S4:		DW	VV2, NN1,  4, M5, M6, M7		;話す　誠３
S5:		DW	VV2, NN2,  5, M8, M9		;話す　亜希２
S6:		DW	VV2, NN3,  6, M10, M11, M12, M13, M14		;話す　美緒５
S7:		DW	VV3, NN4,  7, M15, M16		;考える　仕事２


;イニシャルメッセージ
M1:
	DB	BGM,21
	E_CG B_WIPE,'AE_016' 
;	DB	'【%001】：・・・・・・よし、出来たぞ。'
	DB	"%001:  Okay, that takes care of that."
	DB	NEXT
;	DB	'・・・とゆ～訳で俺達は、スキー・・じゃない、林間学校に来ていた。'
	DB	"Well, we're all up here in Hokkaido, the northernmost"
	DB	CR
	DB	"Japanese island."
	DB	NEXT
;	DB	'【%001】：・・・・・・おーい、まこ・・・・・・'
	DB	"%001:  Hey, Makoto!"
	DB	NEXT
;	DB	'【誠】：ひぇ～～～～～～っ！お助けぇ～～～～～～～～っ！！'
	DB	"Makoto:  ....HELP ME!"
	DB	NEXT
;	DB	'【亜希】：くぉら待ちなさいっ！'
	DB	"Aki:  Makoto!  You come back here!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............"
	DB	PAUSE
;	DB	'何やってんだ、あいつら？'
	DB	"What the hell?"
	DW	0000H

M2:		;見る　誠１
;	DB	'何だか知らないが、逃げ回っているようだ。'
	DB	"I don't know what's going on, but he's being chased by Aki."
	DW	0000H

M3:		;見る　亜希１
;	DB	'何だか知らないが、追い回しているようだ。'
	DB	"I don't know what's going on, but she's running all over"
	DB	CR
	DB	"the place."
	DW	0000H

M4:		;見る　美緒１
;	DB	'１人で一生懸命、晩飯の仕度をしている。'
	DB	"She's busy cooking. No one's helping her."
	DB	NEXT
;	DB	'（・・・まったくあの２人は・・・）'
	DB	"Aki and Makoto should be ashamed of themselves, not"
	DB	CR
	DB	"helping like that."
	DW	0000H

M5:		;話す　誠１
;	DB	'【%001】：おーい誠ぉ。何遊んでんだお前？'
	DB	"%001:  Hey, Makoto, quit playing around."
	DB	NEXT
;	DB	'【誠】：ばっ・・・ばっかやろぉっ！これが遊んでるよ～に見えるかぁっ！？'
	DB	"Makoto:  Does it look like I'm playing??"
	DB	NEXT
;	DB	'【%001】：仕事してるよーには見えんぞ、少なくとも。'
	DB	"%001:  You're certainly not helping out."
	DB	NEXT
;	DB	'【誠】：・・・そっ、そんな事は亜希に言えっ！'
	DB	"Makoto:  Ask Aki about that!"
	DB	FLG,F_COPYI,4,1
	DW	0000H

M6:		;話す　誠２
;	DB	'【%001】：誠ぉ・・・何で追い掛け回されてんだお前？'
	DB	"%001:  Makoto, why is she chasing you around like that?"
	DB	NEXT
;	DB	'【誠】：しるかぁっ！！'
	DB	"Makoto:  How the hell should I know?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ....................."
	EF_SET 101
	DW	0000H

M7:		;話す　誠３
;	DB	'【%001】：おーい、誠ぉ。'
	DB	"%001:  Hey, Makoto."
	DB	NEXT
;	DB	'【誠】：・・・えーい！取り込み中だってのが分からんのか！？'
	DB	"Makoto:  Sorry, I'm busy right now. Can't you see that?"
	DB	NEXT
;	DB	'やる事ね～んだったら薪でも拾ってこいっ！！'
	DB	"Makoto:  If you're just going to stand there, why don't you"
	DB	CR
	DB	"get some firewood or something?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..........."
	DB	PAUSE
;	DB	'分かった。'
	DB	"Okay."
	DB	NEXT
	DB	FLG,F_JR
	DW	M_EX
	DW	0000H

M8:		;話す　亜希１
;	DB	'【%001】：おーい亜希ちゃ～ん。何やってんだ一体？'
	DB	"%001:  Aki, what are you doing?"
	DB	NEXT
;	DB	'【亜希】：見てわかんないのっ！？'
	DB	"Aki:  Can't you tell?!"
	DB	NEXT
;	DB	'【%001】：・・・そらま～、分からん事もないが・・・'
	DB	"%001:  ...Well, I'm not stupid."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M9:		;話す　亜希２
;	DB	'【%001】：おーい亜希ちゃん。'
	DB	"%001:  Hey, Aki!"
	DB	NEXT
;	DB	'【亜希】：今取り込み中なのっ！後にしてっ！！'
	DB	"Aki:  I'm busy! Talk to me later."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	EF_SET 102
	DW	0000H

M10:		;話す　美緒１
;	DB	'【%001】：やあ、美緒ちゃん。'
	DB	"%001:  Hey, Mio."
	DB	NEXT
;	DB	'【美緒】：あ！%001先輩。'
	DB	"Mio:  Ah, %001. Hello."
	DB	PAUSE
;	DB	'テントの方は、もういいの？'
	DB	" Did you get the tents up?"
	DB	NEXT
;	DB	'【%001】：ああ、全部張り終わったよ。'
	DB	"%001:  Yes, they're done."
	DB	NEXT
;	DB	'【美緒】：・・・やっぱ、早いなあ。'
	DB	"Mio:  You must be good at things like that."
	DB	NEXT
;	DB	'【%001】：そか？'
	DB	"%001:  Who, me?"
	DB	FLG,F_COPYI,6,1
	DW	0000H

M11:		;話す　美緒２
;	DB	'【%001】：・・・ところで、一体何やってんだ？あの２人。'
	DB	"%001:  What the hell are they doing?"
	DB	NEXT
;	DB	'【美緒】：・・・・・・良くわかんない。'
	DB	"Mio:  I'm not sure. She seems to want to kill him."
	DB	NEXT
;	DB	'【%001】：・・・・・・あ、そう。'
	DB	"%001:  ....Oh."
	DB	FLG,F_COPYI,6,2
	DW	0000H

M12:		;話す　美緒３
;	DB	'【%001】：・・・まったくしょーがねぇ奴等だな。'
	DB	"%001:  They're still fighting. They're supposed to be helping"
	DB	CR
	DB	"you make dinner."
	DB	NEXT
;	DB	'【美緒】：・・・ううん、いいんだ。'
	DB	"Mio:  Oh, I don't mind."
	DB	PAUSE
;	DB	'あたし、お料理好きだし。'
	DB	" I like to cook, you know."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか。'
	DB	"%001:  Really?"
	DB	FLG,F_COPYI,6,3
	DW	0000H

M13:		;話す　美緒４
;	DB	'【美緒】：ねえ、%001先輩・・・ラッキョウ嫌い？'
	DB	"Mio:  Hey, %001.... Do you like your curry spicy?"
	DB	NEXT
;	DB	'【%001】：いや・・・別に嫌いって事はないけど？'
	DB	"%001:  Hmm, yes, pretty spicy."
	DB	NEXT
;	DB	'【美緒】：良かったぁ。'
	DB	"Mio:  Okay, good."
	DB	FLG,F_COPYI,6,4
	DW	0000H

M14:		;話す　美緒５
;	DB	'【%001】：・・・なあ美緒ちゃん。なんか手伝える事、ないか？'
	DB	"%001:  Hey, Mio. Is there anything I can do to help?"
	DB	NEXT
;	DB	'【美緒】：・・・え？'
	DB	"Mio:  Mm?"
	DB	PAUSE
;	DB	'・・・・・・・・・'
	DB	" ......... "
	DB	PAUSE
;	DB	'ううん、今のところ無いよ。'
	DB	"No, nothing right now."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか。'
	DB	"%001:  ...Oh."
	EF_SET 103
	DW	0000H

M15:		;考える　仕事１
;	DB	'俺の仕事は、みんなの分のテント張り。'
	DB	"I'm supposed to be putting up the tents."
	DB	NEXT
;	DB	'誠と美緒ちゃんと亜希ちゃんは、晩飯の用意。'
	DB	"Makoto and Mio and Aki are going to cook."
	DB	NEXT
;	DB	'他の面子は、薪を拾いに行った。'
	DB	"The others are getting some firewood."
	DB	FLG,F_COPYI,7,1
	DW	0000H

M16:		;考える　仕事２
;	DB	'俺の分担は、さっき終わった。'
	DB	"I just finished with what I had to do."
	DB	NEXT
;	DB	'（・・・暇だ・・・）'
	DB	".....I'm bored."
	EF_SET 104
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,100,1
	DB	FLG,F_MAND,5,100,101,102,103,104
	DB	FLG,F_EXIT,100
	DB	FLG,F_COPYI,4,2
	DW	0000H

M_EX:		;
	DB	G_FLG,G_COPYF,255,255
	DB	FLG,F_CALLS,255
	DW	M_NG,M_A,M_B,M_NG,M_D,M_E,M_NG,M_G,M_H,M_NG,M_NG,M_NG,M_NG
	DW	-1										;ＯＮ　ＧＯＳＵＢ
M_A:		;鈴子
	DB	SINARIO,'CS503_A.OVL',0
	DW	0000H
M_B:		;清美
	DB	SINARIO,'CS503_B.OVL',0
	DW	0000H
M_D:		;祥子
	DB	SINARIO,'CS503_D.OVL',0
	DW	0000H
M_E:		;瑠璃
	DB	SINARIO,'CS503_E.OVL',0
	DW	0000H
M_G:		;星愛（でも鈴子）
	DB	SINARIO,'CS503_A.OVL',0			;ヒロイン筆頭優遇措置
	DW	0000H
M_H:		;恵依美（でも鈴子）
	DB	SINARIO,'CS503_A.OVL',0			;ヒロイン筆頭優遇措置
	DW	0000H
M_NG:
;	DB	'【亜希】：あんたバカぁ？'
	DB	"Aki:  Are you stupid or something?"
	DB	EXIT
	DW	0000H



end
