;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２２
;		物陰の亜希

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7
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
CM2:	DW	VV2,	NN2,NN3,NN4,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	NN5,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'席を外す',0
VV4:	DB	4,	'GO TO BATHROOM',0
;VV5:	DB	5,	'行く',0
VV5:	DB	5,	'GO',0

;NN1:	DB	1,	'周り',0
NN1:	DB	1,	'AROUND',0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	'REIKO',0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'KIYOMI',0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	'MIO',0
;NN5:	DB	5,	'文化祭',0
NN5:	DB	5,	'CULTURE FESTIVAL',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　周り４
S2:		DW	VV3,  -1,  2, M6, M7, M8, M9		;考える４
S3:		DW	VV2, NN2,  3, M10, M11, M12		;話す　鈴子３
S4:		DW	VV2, NN3,  4, M13, M14		;話す　清美２
S5:		DW	VV2, NN4,  5, M15, M16		;話す　美緒２
S6:		DW	VV4,  -1,  6, M17		;席を外す１
S7:		DW	VV5, NN5,  7, M18		;行く　文化祭１


;イニシャルメッセージ
M1:
        DB	BGM,24
        BAK_INIT "AB_36_1"
        ;	DB	'【%001】：・・・ふ～っ、やっとこ昼か・・・'
        DB	"%001:  It's finally lunchtime."
        DB	NEXT
        DB	BUF,B_COPY01										;背景コピー
        T_CG 'CT01','F',0,0,1
        ;	DB	'【鈴子】：流石に、疲れたわね～。'
        DB	"Reiko:  I'm tired!"
        DB	NEXT
        ;	DB	BUF,B_COPY01										;背景コピー
        T_CG 'CT03','F',0,30,3
        ;	DB	'【美緒】：はい、先輩達！'
        DB	"Mio:  Here you go!"
        DB	NEXT
        ;	DB	'美緒ちゃんが、全員分の弁当を手渡す。'
        DB	"Mio hands us all bento lunches."
        DB	NEXT
        ;	DB	'【%001】：・・・おほっ、美味そう・・・'
        DB	"%001:  ......Oh, thanks."
        DB	NEXT
        ;	DB	BUF,B_COPY01										;背景コピー
        T_CG 'CT02','F',0,20,2
        DB	ANI,A_ON,1
        DB	ANI,A_ON,3
        ;	DB	'【清美】：・・・さ、早速頂きましょう。食後３０分ほどは'
        ;	DB	'あまり動かない方が宜しいですから、早めに食べてしまいましょう。'
        DB	"Kiyomi:  Let's relax while we eat. It's not good for the"
        DB	CR
        DB	"body to move around too soon after eating."
        DB	NEXT
        ;	DB	'【%001】：・・・いっただきま～す！'
        DB	"%001:  ....It's looks delicious!"
        DB	C_BLD,C_V_ON,4		;席を外す　消す
        DB	C_BLD,C_V_ON,5		;行く　消す
        DW	0000H
        
M2:		;見る　周り１
        ;	DB	'ここは、鈴子さんの教室だ。俺達以外は誰もいない。'
        DB	"This is Reiko's class. There's no one else here besides"
        DB	CR
        DB	"us."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　周り２
        ;	DB	'・・・ん？'
        DB	".....Mm?"
        DB	NEXT
        ;	DB	'（ささっ）'
        DB	"*swish swish*"
        DB	NEXT
        ;	DB	'・・・・・・今、誰かいたような？'
        DB	"Is someone there?"
        DB	FLG,F_COPYI,1,2
        DW	0000H
        
M4:		;見る　周り３
        ;	DB	'（さささっ）'
        DB	"*swish swish*"
        DB	NEXT
        ;	DB	'・・・・・・・・・'
        DB	"........................................"
        DB	NEXT
        ;	DB	'あの髪の毛は・・・亜希ちゃん？'
        DB	"That red hair... It must be Aki!"
        DB	FLG,F_COPYI,1,3
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M5:		;見る　周り４
        ;	DB	'・・・気が付かないフリしてた方がいいな。'
        DB	"I shouldn't let her know that I've seen her."
        DB	FLG,F_COPYI,101,1
        DW	0000H
        
M6:		;考える１
        ;	DB	'・・・いや～鈴子さん達がいてくれて、ホントに助かったな。'
        DB	"I'm really glad that everyone is here for me."
        ;	DB	FLG,F_COPYI,2,1
        DW	0000H
        
M7:		;考える２
        ;	DB	'・・・今の、亜希ちゃんだよな・・・'
        DB	"That was Aki a minute ago..."
        DB	NEXT
        ;	DB	'何か、用でもあるのかな？'
        DB	"I wonder what she wants?"
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M8:		;考える３
       ;	DB	'・・・・・・'
        DB	".................................."
        DB	NEXT
        ;	DB	'やっぱり、あれかな？体育祭の時の・・・・・・'
        DB	"She must still be worried about what happened after the"
        DB	CR
        DB	"sports festival."
        DB	NEXT
        ;	DB	'・・・・・・・・・'
        DB	".................................."
        DB	NEXT
        ;	DB	'何にしても、よっぽど言いにくい事なんだろう。'
        DB	"She seems to have something difficult to say to me."
        DB	FLG,F_COPYI,2,3
        DW	0000H
        
M9:		;考える４
        ;	DB	'・・・・・・１人になってやった方が、言いやすいかな？'
        DB	"I should get away from these girls if I'm going to talk"
        DB	CR
        DB	"to her."
        DB	FLG,F_COPYI,102,1
        DB	C_BLD,C_V_OFF,4		;席を外す　出す
        DW	0000H
        
M10:		;話す　鈴子１
        ;	DB	'【%001】：ねえ鈴子さん・・・何で鈴子さんの教室、誰もいないの？'
        DB	"%001:  Hey, Reiko, why isn't there anyone else in your "
        DB	CR
        DB	"classroom?"
        DB	NEXT
        ;	DB	'【鈴子】：・・・ああ、今体育館の方で出し物の準備してると思うわ。'
        DB	"Reiko:  Everyone's walking around the culture festival."
        DB	NEXT
        ;	DB	'【%001】：あ、なるほど。'
        DB	"%001:  Oh."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M11:		;話す　鈴子２
        ;	DB	'【%001】：そ～言えば鈴子さん、小道具だって言ってたよね？'
        ;	DB	'何作ったの？'
        DB	"%001:  By the way, weren't you supposed to be helping"
        DB	CR
        DB	"out with the set building for that play?"
        DB	NEXT
        ;	DB	'【鈴子】：・・・え～っと・・・'
        DB	"Reiko:  .......Oh, yeah..."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・・・・'
        DB	"Reiko:  ....................................."
        DB	NEXT
        ;	DB	'【%001】：・・・もしかして、作った奴全部ボツったとか？'
        DB	"%001:  You didn't make everyone else in your class do the"
        DB	CR
        DB	"work instead, did you?"
        DB	NEXT
        ;	DB	'【鈴子】：・・・う・・・'
        DB	"Reiko:  ....Huh?"
        DB	PAUSE
        ;	DB	'や、や～ね。そんな事無いわよぉ。'
        DB	" N- No, of course not!"
        DB	NEXT
        ;	DB	'（・・・図星らしい・・・）'
        DB	"I seem to have guessed right..."
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M12:		;話す　鈴子３
        ;	DB	'【%001】：・・・とにかく、後で見に行こうぜ。'
        DB	"%001:  Well, I want to go see the play, later."
        DB	NEXT
        ;	DB	'【鈴子】：ええ。'
        DB	"Reiko:  Alright."
        DB	FLG,F_COPYI,103,1
        DW	0000H
        
M13:		;話す　清美１
        ;	DB	'【%001】：ねえ新藤さん。この後の予定って、ど～なってるの？'
        DB	"%001:  Kiyomi, is there anything scheduled for the"
        DB	CR
        DB	"afternoon?"
        DB	NEXT
        ;	DB	'【清美】：・・・あ、はい。'
        DB	"Kiyomi:  Let's see...."
        DB	NEXT
        ;	DB	'【清美】：１２：５５　クイズでドボン！'
        DB	"Kiyomi:  At 12:55, another quiz show."
        DB	NEXT
        ;	DB	'【清美】：１３：５５　ＤＸマジックショー'
        DB	"Kiyomi:  At 1:55, a magic show."
        DB	NEXT
        ;	DB	'【清美】：１４：２５　にしりん・ｉｎＬｏｖｅ'
        DB	"Kiyomi:  At 2:25, a karaoke contest."
        DB	NEXT
        ;	DB	'【清美】：１４：４２　仮想大笑'
        DB	"Kiyomi:  At 2:42, stand-up comedy."
        DB	NEXT
        ;	DB	'【清美】：１５：２７　スナップに挑戦！'
        DB	"Kiyomi:  At 3:27, a finger-snapping competition."
        DB	NEXT
        DB	"Kiyomi:  At 3:43, Susana Hoffs impersonations."
        DB	NEXT
        ;	DB	'【清美】：１６：０１　おん・ざ・りみっと'
        DB	"Kiyomi:  At 4:01, a palm-reading."
        DB	NEXT
        ;	DB	'【清美】：１６：１１　袋詰め王座決定戦！'
        DB	"Kiyomi:  At 4:11, a pinesalad eating contest."
        DB	NEXT
        ;	DB	'【清美】：１６：２８　銀河警察ブレイブマン'
        DB	"Kiyomi:  At 4:28, Galaxy Police Braveman."
        DB	NEXT
        ;	DB	'【清美】：１７：０５　学園ワイドショー'
        DB	"Kiyomi:  At 5:05, the school movie festival."
        DB	NEXT
        ;	DB	'【清美】：１７：４５　わたくしとディナー'
        DB	"Kiyomi:  At 5:45, dinner with me...."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ........................"
        DB	PAUSE
        ;	DB	'も、もういいよ。ありがとう。'
        DB	"Okay, thanks."
        DB	FLG,F_COPYI,4,1
        DW	0000H
        
M14:		;話す　清美２
        ;	DB	'【%001】：・・・しっかし、流石は新藤さんだな。'
        DB	"%001:  You sure are organized."
        DB	NEXT
        ;	DB	'【清美】：そうですか？'
        DB	"Kiyomi:  I am?"
        DB	NEXT
        ;	DB	'【%001】：いやホント。'
        DB	"%001:  Yes. I'm in awe of you."
        DB	NEXT
        ;	DB	'【清美】：お役に立てて嬉しいですわ。'
        DB	"Kiyomi:  I hope I'm of use to you."
        DB	FLG,F_COPYI,104,1
        DB	C_BLD,C_V_OFF,5		;行く　出す
        DW	0000H
        
M15:		;話す　美緒１
        ;	DB	'【%001】：・・・うん、この空揚げ美味い！'
        DB	"%001:  This bento is really good!"
        DB	NEXT
        ;	DB	'【美緒】：ホント？'
        DB	"Mio:  Really?"
        DB	NEXT
        ;	DB	'【%001】：ああ。'
        DB	"%001:  Yes."
        DB	NEXT
        ;	DB	'【美緒】：それ、ちょっと自信あったんだ。'
        DB	"Mio:  Thanks. I thought you might like it."
        DB	FLG,F_COPYI,5,1
        DW	0000H
        
M16:		;話す　美緒２
        ;	DB	'【%001】：・・・美緒ちゃんの弁当は、いつも美味いな。'
        DB	"%001:  Everything you make is so good, Mio."
        DB	NEXT
        ;	DB	'【美緒】：ううん・・・本の通りにやってるだけだよ。'
        DB	"Mio:  Thanks. I just did what the book said to do."
        DB	FLG,F_COPYI,105,1
        DW	0000H
        
M17:		;席を外す１
        ;	DB	'【%001】：・・・俺、ちょっとトイレ。'
        DB	"%001:  I'm going to go to the bathroom."
        DB	NEXT
        ;	DB	'そう言って俺は、教室を出た。'
        DB	"I leave the classroom."
        DB	NEXT
        ;	DB	'・・・校舎裏通って行こう。あそこなら人気がないから、'
        ;	DB	'亜希ちゃんも話しやすいだろう。'
        DB	"I should go behind the school building. I can talk to"
        DB	CR
        DB	"Aki there."
        DB	NEXT
        DB	SINARIO,'CS823.OVL',0
        DW	0000H
        
M18:		;行く　文化祭１
        ;	DB	'【%001】：・・・んじゃ、そろそろいこっか？'
        DB	"%001:  Well, shall we go?"
        DB	NEXT
        ;	DB	'弁当を食い終えた俺達は、再びあのクソ忙しい中に身を投じた。'
        DB	"Having finished our lunches, we started our schedule again."
        DB	NEXT
        ;	DB	'（・・・ま、その内言ってくるだろ。）'
        DB	"Whatever it is she wants to tell me, I'm sure she'll"
        DB	CR
        DB	"get around to it eventually.."
        DB	NEXT
        DB G_FLG,G_COPYI,169,1
        DB	SINARIO,'CS825.OVL',0
        DW	0000H


end
