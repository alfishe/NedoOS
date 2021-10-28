;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　亜希１
;		
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'聞く',0
VV3:	DB	3,	'ASK',0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	'THINK',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0

;NN1:	DB	1,	'周り',0
NN1:	DB	1,	'AROUND',0
;NN2:	DB	2,	'亜希',0
NN2:	DB	2,	'AKI',0
;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M9		;見る　周り１
S2:		DW	VV1, NN2,  2, M10, M11, M12		;見る　亜希３
S3:		DW	VV2, NN2,  3, M2, M3, M4, M5, M6, M7, M8		;話す　亜希７


;イニシャルメッセージ
M1:
	DB	BGM,7
	BAK_INIT "AB_26"
	B_P1 B_SUDA
;	DB	'【%001】：・・・っと、これで全部かい？'
	DB	"%001:  Well, is that all?"
	DB	NEXT
	T_CG "CT06","W",0,10,1
;	DB	'【亜希】：うん。ありがと、先輩。'
	DB	"Aki:  Yes. Thank you, %001."
	DB	NEXT
;	DB	'・・・春休みも、残すところあと一日となった今日。'
	DB	"It was one month later, the last day before Spring vacation"
	DB	CR
	DB	"ended and the new school year started in Japan."
	DB	NEXT
;	DB	'俺と亜希ちゃんは、体育用具室の大整理を敢行していた。'
	DB	"I was in the gym storage room with Aki, helping clean."
	DW	0000H

M2:		;話す　亜希１
;	DB	'【%001】：・・・でも、亜希ちゃん偉いよなあ。自発的にこういう事って、'
;	DB	'中々出来る事じゃないぜ。'
	DB	"%001:  You're really great, Aki, volunteering to clean"
	DB	CR
	DB	"up in here. I would never have done that by myself."
	DB	NEXT
;	DB	'【亜希】：・・・・・・ま、まあ休み中の特訓で、随分と散らかしちゃったから・・・・・・'
	DB	"Aki:  ......W- Well, it got so messy in here over the"
	DB	CR
	DB	"past year and all..."
	DB	NEXT
;	DB	'・・・そう。'
	DB	"%001:  Yeah."
	DB	NEXT
;	DB	'亜希ちゃんは休み返上で、俺相手にテニスの特訓をしていた。'
	DB	"Aki and I spent our vacation playing tennis."
	DB	NEXT
;	DB	'ひいき目かもしれないが、亜希ちゃんはこの数日で随分進歩したと思う。'
	DB	"She's gotten really good. She can almost beat me."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M3:		;話す　亜希２
;	DB	'【%001】：・・・だけど、特訓の成果は確実に出てると思うぜ。'
	DB	"%001:  Practice is really the way to get good at something."
	DB	NEXT
;	DB	'【%001】：今なら美緒ちゃんだって、簡単には勝てないんじゃないかな？'
	DB	"%001:  I'll bet you could easily beat Mio now."
	DB	NEXT
;	DB	'【亜希】：・・・そうね、苦戦はさせられると思うわ。'
	DB	"Aki:  .....I might be able to get close..."
	DB	NEXT
;	DB	'【亜希】：でも、まだ勝てない・・・・・・'
	DB	"Aki:  But I can't beat her yet."
	DB	PAUSE
;	DB	'あたし、もっともっと強くならなきゃ。'
	DB	" I've got to become stronger,"
	DB	CR
	DB	"stronger!"
	DB	NEXT
;	DB	'【%001】：・・・亜希ちゃん・・・'
	DB	"%001:  ........Aki....."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M4:		;話す　亜希３
;	DB	'【%001】：・・・しっかし、亜希ちゃんも明日から俺達と同じ学校か・・・'
;	DB	'時の流れるのは、早いもんだなぁ。'
	DB	"%001:  ....I can't believe a year's passed already..."
	DB	NEXT
;	DB	'【亜希】：・・・・・・そうね・・・・・・'
	DB	"Aki:  Me, too. "
	DB	FLG,F_COPYI,3,3
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　亜希４
;	DB	'【亜希】：・・・・・・%001先輩。ちょっと、目をつぶっててくんない？'
	DB	"Aki:  ....%001, will you close your eyes for a second?"
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【亜希】：いいから、はやくしてよ！あたしがいいって言うまで、'
;	DB	'絶対開けちゃダメよ！！'
	DB	"Aki:  Just close them! And don't open them until I say"
	DB	CR
	DB	"it's alright!"
	DB	NEXT
	B_O B_SUDA
;	DB	'【%001】：・・・へいへい。'
	DB	"%001:  ............"
	DB	NEXT
;	DB	'何だってんだ、いきなり・・・・・・？'
	DB	" What's she planning...?"
	DB	NEXT
;	DB	'ごそごそ'
	DB	"*rustle rustle*"
	DB	NEXT
;	DB	'【%001】：・・・おい、亜希ちゃん？'
	DB	"%001:  Aki?"
	DB	NEXT
;	DB	'【亜希】：・・・・・・まだダメ！'
	DB	"Aki:  Don't open your eyes yet!"
	DB	NEXT
;	DB	'ごそごそ'
	DB	"*rustle rustle*"
	DB	NEXT
;	DB	'【%001】：・・・・・・おい、一体何やって・・・・・・'
	DB	"%001:  ...What are you doing?"
	DB	PAUSE
	E_CG B_SUDA,'AE_112'
;	DB	'てぇえぇぇぇぇっ！？'
	DB	" WHAT?!?!"
	DB	NEXT
;	DB	'【亜希】：・・・ばか・・・まだいいって言ってないのに・・・'
	DB	"Aki:  ......I didn't say you could open your eyes, yet..."
	DB	FLG,F_COPYI,3,4
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　亜希５
;	DB	'【%001】：・・・あ、あ、あ、亜希ちゃん・・・？'
	DB	"%001:  .....A- A- Aki!"
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  .........................."
	DB	PAUSE
;	DB	'あたし、魅力ない・・・・・・・・・？'
	DB	"Am I pretty, %001?"
	DB	NEXT
;	DB	'【%001】：え゛？'
	DB	"%001:  Eh?!"
	DB	NEXT
;	DB	'【亜希】：・・・だって・・・'
	DB	"Aki:  I couldn't help it..."
	DB	PAUSE
;	DB	'だってあの日以来、キスもしてくれないじゃない！！'
	DB	" Ever since that day, you wouldn't"
	DB	CR
	DB	"kiss me or anything...!"
	DB	NEXT
;	DB	'【%001】：・・・あ、亜希ちゃん・・・'
	DB	"%001:  ......A- Aki...."
	DB	NEXT
;	DB	'【亜希】：・・・・・・どうせあたしなんか、がさつで、可愛くなくて、'
;	DB	'人より秀でたところなんか何にも無い、ただの嫌な女よ！'
	DB	"Aki:  You don't really like me, do you? I'm not pretty..."
	DB	NEXT
;	DB	'【亜希】：先輩が好きだって言ったのだって、ただ可哀想だったからなんでしょ！'
	DB	"Aki:  You must have told me that you loved me only"
	DB	CR
	DB	"because you were sorry for me..."
	DB	NEXT
;	DB	'【%001】：・・・亜希ちゃん・・・'
	DB	"%001:  ....Aki......"
	DB	NEXT
;	DB	'【亜希】：同情なんか、もう沢山だわ！！'
	DB	"Aki:  I'm tired of sympathy!"
	DB	NEXT
;	DB	'【%001】：亜希ちゃん！！'
	DB	"%001:  Aki!"
	DB	NEXT
;	DB	'がしっ'
	DB	"*SLAP*"
	DB	NEXT
;	DB	'【亜希】：！'
	DB	"Aki:  !?"
	DB	FLG,F_COPYI,3,5
	DW	0000H

M7:		;話す　亜希６
;	DB	'【%001】：・・・亜希ちゃん。もう自分を卑下するのは止せよ。'
	DB	"%001:  Aki, stop this."
	DB	NEXT
;	DB	'【%001】：亜希ちゃんは、強い女の子だ。それは、俺が一番よく知っている・・・・・・'
	DB	"%001:  You're a strong woman. I know that more than anyone"
	DB	CR
	DB	"else..."
	DB	NEXT
;	DB	'【亜希】：・・・・・・・・・'
	DB	"Aki:  ..............................."
	DB	NEXT
;	DB	'【%001】：亜希ちゃんは、ちゃんと努力してる。俺は、そんな前だけを見てる亜希ちゃんが大好きだ。'
	DB	"%001:  You give your all, no matter what you're doing. I"
	DB	CR
	DB	"really love that about you..."
	DB	NEXT
;	DB	'【亜希】：・・・・・・先輩・・・・・・'
	DB	"Aki:  %001......."
	DB	NEXT
;	DB	'【%001】：自信、持ちなよ。'
	DB	"%001:  Don't doubt yourself like that, okay?"
	DB	FLG,F_COPYI,3,6
	DW	0000H

M8:		;話す　亜希７
;	DB	'【亜希】：・・・先輩・・・'
	DB	"Aki:  %001......"
	DB	PAUSE
;	DB	'ホントにあたしの事、好き？'
	DB	"Do you really love me?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yes, I do."
	DB	NEXT
;	DB	'【亜希】：・・・じゃあ・・・あたしを抱いて！'
	DB	"Aki:  Then make love to me!"
	DB	NEXT
;	DB	'【%001】：・・・亜希ちゃん！？'
	DB	"%001:  .........?!"
	DB	NEXT
;	DB	'【亜希】：・・・あたし、恐いの・・・'
	DB	"Aki:  I'm scared, %001."
	DB	PAUSE
;	DB	'先輩があたしの事嫌いになっちゃう事が・・・'
	DB	" I'm scared I'll wake up someday"
	DB	CR
	DB	"and you won't love me anymore!"
	DB	NEXT
;	DB	'【%001】：・・・そんな事・・・'
	DB	"%001:  Aki, that'll never...."
	DB	NEXT
;	DB	'【亜希】：だからお願い！あたしを安心させて！'
	DB	"Aki:  That's why I want you to make love to me! Make me"
	DB	CR
	DB	"know that you love me!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	DB	NEXT
;	DB	'【%001】：分かったよ、亜希ちゃん。'
	DB	"%001:  Alright, Aki."
	DB	NEXT
	DB	SINARIO,'CSE_F_2.OVL',0
	DW	0000H

M9:		;見る　周り１
;	DB	'色々な体育用具が、整然と積まれている。'
	DB	"We're surrounded by gymnastics equipment."
	DB	NEXT
;	DB	'・・・もちろん、俺達が苦労して整然とさせたからだ。'
	DB	"We're totally alone in here."
	DW	0000H

M10:		;見る　亜希１
;	DB	'ここ数日御馴染みの、熱血亜希ちゃんだ。'
	DB	"It's Aki, the tomboy of the school."
	DB	NEXT
;	DB	'・・・俺は、結構好きだけど。'
	DB	"She's pretty to me, though..."
;	DB	FLG,F_COPYI,2,1
	DW	0000H

M11:		;見る　亜希２
;	DB	'・・・ん？一寸元気が無いみたいだな。'
	DB	".....Mm? She seems a little down about something."
;	DB	FLG,F_COPYI,2,2
	DW	0000H

M12:		;見る　亜希３
;	DB	'柄物のパンティとソックスと上履以外何もつけていない、'
;	DB	'限りなく全裸に近い状態だ。'
	DB	"She's wearing nothing but striped panties and socks."
	DB	NEXT
;	DB	'・・・あ、亜希ちゃん！？突然何をっ！？'
	DB	"What is she doing?!"
	DW	0000H


end
