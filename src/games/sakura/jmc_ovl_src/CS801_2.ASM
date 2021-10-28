	;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０１＿２
;		体育祭前　練習の日々１

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
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'清美',0
NN2:	DB	2,	'KIYOMI',0
;NN3:	DB	3,	'美緒',0
NN3:	DB	3,	'MIO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子
S2:		DW	VV1, NN2,  2, M3		;見る　清美
S3:		DW	VV1, NN3,  3, M4		;見る　美緒
S4:		DW	VV2, NN1,  4, M5, M6		;話す　鈴子２
S5:		DW	VV2, NN2,  5, M7, M8		;話す　清美２
S6:		DW	VV2, NN3,  6, M9, M10		;話す　美緒２
S7:		DW	VV3, -1,  7, M11, M12		;考える


;イニシャルメッセージ
M1:
	DB	BGM,6
	B_O B_SUDA
	E_CG B_YOKO,"AB_27_2"
;	DB	'・・・てなもんで、練習初日。'
	DB	"My first day of practice."
	DB	NEXT
;	DB	'【バレー】：行くぜ山神！クイックＡだ！'
	DB	"Volleyball player:  Okay, Yamagami! Try the spike!"
	DB	NEXT
;	DB	'ばしっ！'
	DB	"*SMACK*"
	DB	NEXT
;	DB	'【%001】：よっしゃあ！'
	DB	"%001:  I've got it!"
	DB	NEXT
;	DB	'どがぁっ！'
	DB	"*HIT*"
	DB	NEXT
;	DB	'【バレー】：よっし！流石だな山神！'
	DB	"Volleyball player:  Good, you're doing great!"
	DB	NEXT
;	DB	'【野球】：おーい山神ぃ！お前の番だぞ～！'
	DB	"Baseball player:  Yamagami, you're up!"
	DB	NEXT
;	DB	'【%001】：お～、今行く～！'
	DB	"%001:  Okay, I'll do my best!"
	DB	NEXT
;	DB	'だだだだだ・・・'
	DB	"................................"
	DB	NEXT
	E_CG B_YOKO,"AB_11_2"
;	DB	'【野球】：・・・お、来たな。早速行くぞ弾丸ライナー！'
	DB	"Baseball player:  Okay, try this!"
	DB	NEXT
;	DB	'かっきーん！'
	DB	"*THROW*"
	DB	NEXT
;	DB	'【%001】：わっ！'
	DB	"%001:  Wah!"
	DB	NEXT
;	DB	'げしっ！'
	DB	"*SMACK*"
	DB	NEXT
;	DB	'【野球】：こぉら山神！足で受けるな足で！'
	DB	"Baseball player:  Hey, Yamagami! Don't stop the ball with",CR,"your feet!"
	DB	NEXT
;	DB	'【%001】：やかましい！グローブも無しで硬球が受けられるかっ！'
	DB	"%001:  How the hell else am I supposed to stop the ball?"
	DB	CR
	DB	"I don't even have a glove!"
	DB	NEXT
	E_CG B_YOKO,"AB_14_2"
;	DB	'【サッカー】：山神く～ん、君の番よ～。'
	DB	"Soccer player:  Okay, come here, Yamagami!"
	DB	NEXT
;	DB	'【%001】：おう！'
	DB	"%001:  Yes, sir!"
	DB	NEXT
;	DB	'だだだだだ・・・'
	DB	"..............................................."
	DB	NEXT
;	DB	'【サッカー】：・・・よし、１・２リターンだ！'
	DB	"Soccer player:  Okay, try this!"
	DB	PAUSE
;	DB	'ほれっ！'
	DB	" Go!"
	DB	NEXT
;	DB	'ばしっ！'
	DB	"*KICK*"
	DB	NEXT
;	DB	'【%001】：おう！'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'どがぁっ！'
	DB	"*SMACK*"
	DB	NEXT
;	DB	'【サッカー】：うわっち！'
	DB	"Soccer player:  Whoops!"
	DB	PAUSE
;	DB	'・・・こら山神！俺に恨みでもあるのか？'
	DB	"...Hey, Yamagami. Do you hate me or"
	DB	CR
	DB	"something?"
	DB	NEXT
;	DB	'【%001】：別にないが。'
	DB	"%001:  No. Why?"
	DB	NEXT
;	DB	'【サッカー】：だったら、取れるタマ寄越せ！'
	DB	"Soccer player:  In that case, keep the ball on the ground."
	DB	PAUSE,CR
;	DB	'あーゆーのは、シュートの時にしろ！'
	DB	"Save those big kicks for the other side."
	DB	NEXT
;	DB	'【%001】：わかった。'
	DB	"%001:  Okay, sorry."
	DB	NEXT
;	DB	'【生徒】：おーい、山神く～ん。出番だよ～。'
	DB	"Student:  Yamagami, it's your turn."
	DB	NEXT
;	DB	'【%001】：・・・今行く！'
	DB	"%001:  ......Okay."
	DB	NEXT
	BAK_INIT "AB_27_2"
	B_P1 B_YOKO
;	DB	'だだだだだ・・・'
	DB	".............................................."
	DB	NEXT
;	DB	'【%001】：・・・ぜいぜいぜいぜいぜいぜい・・・'
	DB	"%001:  .............*pant pant*"
	DB	NEXT
;	DB	'（・・・さ、流石にコレは・・・）'
	DB	"This is harder than I thought it'd be."
	DB	NEXT
	DB BUF,B_COPY01
	TU_CG "CT01","W",'I',35,1
	TU_CG "CT03","W",'I',12,3
	T_CG "CT02","W",'I',0,2
	DB ANI,A_ON,1
	DB ANI,A_ON,3
;	DB	'【鈴子】：・・・・・・%001君。'
	DB	"Reiko:  %001."
	DW	0000H

M2:		;見る　鈴子
;	DB	'どーしたんだろ、すげぇ心配そうだ。'
	DB	"She really looks worried about me."
	DB	NEXT
;	DB	'ひょっとして、俺、そんなにつらそうなのかな？'
	DB	"Do I look that bad?"
	DB	NEXT
;	DB	'・・・ちゃんと「大丈夫」って言わないと。'
	DB	"I'd better show her that I'm really alright."
	EF_SET 101
	DW	0000H

M3:		;見る　清美
;	DB	'なんか、心配そうだな。'
	DB	"She looks worried."
	DB	NEXT
;	DB	'ひょっとして、新藤さんのくれた予定表通りに進んでないからかな？'
	DB	"Maybe because I'm not following the book she gave me?"
	DB	NEXT
;	DB	'・・・いや、ちゃんと予定通りのはずだけどな？'
	DB	"But I'm doing my best."
	DB	NEXT
;	DB	'・・・ちゃんと「大丈夫」って言わないと。'
	DB	"I'd better show her that I'm really alright."
	EF_SET 102
	DW	0000H

M4:		;見る　美緒
;	DB	'・・・ありゃ？心配してる？'"
	DB	"She looks worried."
	DB	NEXT
;	DB	'いかんなァ、ちいと情けないところを見せちゃったな。'
	DB	"I can't show her how hard this practice is."
	DB	NEXT
;	DB	'・・・ちゃんと「大丈夫」って言わないと。'
	DB	"I'd better show her that I'm really alright."
	EF_SET 103
	DW	0000H

M5:		;話す　鈴子１
;	DB	'【%001】：・・・あれ？ど～したの鈴子さん？・・・ぜいぜい・・・'
	DB	"%001:  What's the matter, Reiko? *pant pant*"
	DB	NEXT
;	DB	'【鈴子】：ちょっと気になったから来てみたのよ。'
	DB	"Reiko:  I was a little worried about you, so I came."
	DB	PAUSE
;	DB	'大丈夫なの？%001君・・・'
	DB	" Are you"
	DB	CR
	DB	"alright, %001?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、別にこのくらい・・・ぜいぜい・・・'
	DB	"%001:  ...Sure, this is nothing. Not really..."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ............................................"
	DB	FLG,F_COPYI,4,1
	DW	0000H

M6:		;話す　鈴子２
;	DB	'【鈴子】：%001君、ちょっとこれは人間のやるもんじゃないわよ。'
	DB	"Reiko:  %001, this is really too hard for you."
	DB	NEXT
;	DB	'【%001】：・・・そう？いちお～、効率のいいやり方してるはずなんだけど。'
	DB	"%001:  Really? I'm practicing as hard as I can..."
	DB	NEXT
;	DB	'【清美】：・・・%001さん・・・'
	DB	"Kiyomi:  %001..."
	DB	NEXT
;	DB	'【鈴子】：・・・だからそーゆー問題じゃなくて・・・'
	DB	"Reiko:  I'm not worried about whether you're practicing or"
	DB	CR
	DB	"not!"
	EF_SET 104
	DW	0000H

M7:		;話す　清美１
;	DB	'【清美】：%001さん・・・大丈夫なのですか？'
	DB	"Kiyomi:  %001, are you alright?"
	DB	NEXT
;	DB	'【%001】：ああ、別にど～って事・・・ぜいぜい・・・'
	DB	"%001:  I'll be fine, don't worry."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ............................................"
	DB	FLG,F_COPYI,5,1
	DW	0000H

M8:		;話す　清美２
;	DB	'【清美】：ですが%001さん・・・こんなに大変では・・・'
	DB	"Kiyomi:  But you look like you're having a hard time"
	DB	CR
	DB	"of it..."
	DB	NEXT
;	DB	'【%001】：大丈夫大丈夫。'
	DB	"%001:  I'm fine, don't worry."
	DB	NEXT
;	DB	'【清美】：・・・本当ですか？'
	DB	"Kiyomi:  .......Really?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Sure."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ............................................"
	EF_SET 105
	DW	0000H

M9:		;話す　美緒１
;	DB	'【美緒】：%001先輩・・・大丈夫？'
	DB	"Mio:  %001, are you okay?"
	DB	NEXT
;	DB	'【%001】：ああ・・・ぜいぜい・・・'
	DB	"%001:  Sure, no problem."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M10:		;話す　美緒２
;	DB	'【美緒】：でも%001先輩・・・辛そう・・・'
	DB	"Mio:  But it looks really hard, practicing like you're doing."
	DB	NEXT
;	DB	'【%001】：・・・い、いやホントに大した事ないんだって。'
	DB	"%001:  It's really nothing, trust me."
	DB	PAUSE
;	DB	'ここんとこあんまり身体動かしてなかったから、息切れしただけさ。'
	DB	" I'm just out of breath"
	DB	CR
	DB	"because I haven't been exercising all that much these days."
	DB	NEXT
;	DB	'【美緒】：・・・先輩・・・'
	DB	"Mio:  %001..."
	EF_SET 106
	DW	0000H

M11:		;考える
;	DB	'・・・さすがにこんだけハードだと・・・'
	DB	"This practice is really hard..."
	DB	NEXT
;	DB	'・・・嫌になってくるから、考えるのやめよう。'
	DB	"But if I think that way, I won't want to continue. So"
	DB	CR
	DB	"let's stop thinking."
	DB	FLG,F_COPYI,7,1
	DW	0000H

M12:		;考える
;	DB	'・・・３人とも心配そうだ。'
	DB	"They're all worried about me."
	EF_SET 107
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,8,255,101,102,103,104,105,106,107
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'【%001】：・・・それはそれとして。そっちの方は練習もう終わったの？'
	DB	"%001:  Anyway, how about your tennis practice? Are you"
	DB	CR
	DB	"doing alright?"
	DB	NEXT
;	DB	'【清美】：ええ、わたくし達の方は一応。'
	DB	"Kiyomi:  Yes, I'm fine..."
	DB	NEXT
;	DB	'【%001】：そか。俺はまだまだかかるから、先に帰ってなよ。'
	DB	"%001:  That's good. I'll be here a while yet, so you go"
	DB	CR
	DB	"on home without me."
	DB	NEXT
;	DB	'【美緒】：でも・・・'
	DB	"Mio:  Yes, but..."
	DB	NEXT
;	DB	'【%001】：い～からい～から。'
	DB	"%001:  Don't worry, I'll be fine."
	DB	PAUSE
;	DB	'退屈だろ？人の見てるだけって言うのは。'
	DB	" It's not very exciting"
	DB	CR
	DB	"to watch someone else exercise, after all."
	DB	NEXT
;	DB	'【鈴子】：・・・まあ・・・楽しいって訳じゃないけど・・・'
	DB	"Reiko:  Well, it's not fun, that's true..."
	DB	NEXT
;	DB	'【%001】：んじゃ、そーゆー事で。'
	DB	"%001:  See? So go on home without me."
	DB	PAUSE
	B_O B_SUDA
;	DB	'じゃな！また明日！'
	DB	" See you tomorrow!"
	DB	NEXT
;	DB	'【鈴子】：ちょっと%001君！'
	DB	"Reiko:  Wait a moment, %001."
	DB	PAUSE
;	DB	'・・・行っちゃった。'
	DB	" Opps, too late."
	DB	NEXT
;	DB	'【美緒】：・・・どうしよう？'
	DB	"Mio:  What can we do?"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ................................."
	DB	NEXT
;	DB	'【鈴子】：今日のところは、取り敢えず帰りましょう。'
	DB	"Reiko:  Let's go home."
	DB	PAUSE
;	DB	'・・・清美ちゃん。明日の%001君の様子、見ておいてくれない？'
	DB	" Kiyomi, will you check up on him"
	DB	CR
	DB	"tomorrow?"
	DB	NEXT
;	DB	'【清美】：・・・ええ。わたくしもそのつもりでしたし。'
	DB	"Kiyomi:  Sure. I want to make sure he's alright."
	DB	NEXT
;	DB	'【鈴子】：お願いね。'
	DB	"Reiko:  Thanks."
	DB	PAUSE
;	DB	'・・・ホンット、%001君の「大丈夫」はあてにならないから・・・'
	DB	" We can't be sure he's as okay as he sounds."
	DB	NEXT
	B_O B_SUDA
	DB	SINARIO,'CS801_3.OVL',0
	DW	0000H


end
