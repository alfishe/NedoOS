;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　７０３
;		鈴子の誕生前日　教室

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,-1

VV1:	DB	1,	"TALK",0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	"REIKO",0
;NN2:	DB	2,	'清美',0
NN2:	DB	2,	"KIYOMI",0
;NN3:	DB	3,	'美緒',0
NN3:	DB	3,	"MIO",0
;NN4:	DB	4,	'恵依美',0
NN4:	DB	4,	"MEIMI",0
;NN5:	DB	5,	'星愛',0
NN5:	DB	5,	"SEIA",0
;NN6:	DB	6,	'誠',0
NN6:	DB	6,	"MAKOTO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;話す　鈴子３
S2:		DW	VV1, NN2,  2, M5		;話す　清美１
S3:		DW	VV1, NN3,  3, M6		;話す　美緒１
S4:		DW	VV1, NN4,  4, M7, M8		;話す　恵依美２
S5:		DW	VV1, NN5,  5, M9		;話す　星愛１
S6:		DW	VV1, NN6,  6, M10, M11		;話す　誠２


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT 'AB_36_4'
	B_O B_SUDA
	DB	BUF,B_COPY01
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
;	DB	'【清美】：・・・%001さん。'
	DB	"Kiyomi:  .....%001."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【清美】：%001さん。'
	DB	"Kiyomi:  .....%001."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【清美】：%001さん！'
	DB	"Kiyomi:  %001!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【清美】：しゅ・う・じ・さん！！'
	DB	"Kiyomi:  Shuuuuu - ji!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・ふに？'
	DB	"%001:  .........Wha?"
	DB	NEXT
	T_CG 'CT02','S','I',0,2
;	DB	'【清美】：もう、授業終わりましたわ。'
	DB	"Kiyomi:  Class is over."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【%001】：そか・・・・・・ふう、良く寝た。'
	DB	"%001:  .....Oh....Man, I slept really well."
	DB	NEXT
;	DB	'【清美】：%001さん・・・・・・お顔の色がすぐれませんわ。'
	DB	"Kiyomi:  Your face is really flushed."
	DB	NEXT
;	DB	'【%001】：・・・・・・ん～・・・・・・'
	DB	"%001:  ....Mm......"
	DB	NEXT
;	DB	'【清美】：せめて、お薬くらい飲まれた方が・・・・・・'
	DB	"Kiyomi:  Really, you should take some medicine...."
	DB	NEXT
;	DB	'【%001】：・・・・・・ん～・・・・・・'
	DB	"%001:  ....Mm......"
	DB	NEXT
;	DB	'【清美】：・・・%001さん・・・'
	DB	"Kiyomi:  .....%001...."
	DB	NEXT
	TU_CG 'CT03','S',0,12,3
	T_CG 'CT01','S','I',35,5
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【鈴子】：・・・%001君、どう？'
	DB	"Reiko:  How are you doing, %001?"
	DB	NEXT
;	DB	'【美緒】：・・・%001先輩・・・'
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..................."
	DW	0000H

M2:		;話す　鈴子１
	DB	BUF,B_COPY01
	T_CG 'CT01','S','I',35,5
;	DB	'【鈴子】：・・・%001君。'
	DB	"Reiko:  %001..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	PAUSE
;	DB	'ん？'
	DB	"Hm?"
	DB	NEXT
;	DB	'【%001】：・・・あ。'
	DB	"%001:  Ah."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  .............."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DB	NEXT
;	DB	'【鈴子】：ちょっと！？凄い熱じゃない！'
	DB	"Reiko:  What's this? You're in a cold sweat!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................."
	DB	PAUSE
;	DB	'そう？'
	DB	"Really?"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;話す　鈴子２
	DB	BUF,B_COPY01
	T_CG 'CT01','S','D',35,1
;	DB	'【鈴子】：『そう？』じゃないでしょ！？保健室行かなきゃ！'
	DB	"Reiko:  What do you mean, 'really?' Off to the nurse's"
	DB	CR
	DB	"office with you!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................."
	DB	PAUSE
;	DB	'やだ。'
	DB	"I don't want to go."
	DB	NEXT
;	DB	'【鈴子】：『やだ。』でもないの！！'
	DB	"Reiko:  What do you mean, 'you don't want to go'?!"
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;話す　鈴子３
	DB	BUF,B_COPY01
	T_CG 'CT01','S','D',35,1
;	DB	'【鈴子】：ほら、行くわよ！立って！'
	DB	"Reiko:  All right, let's go! Get up!"
	DB	NEXT
;	DB	'【%001】：・・・・・・やだ。'
	DB	"%001:  No."
	DB	NEXT
;	DB	'【鈴子】：・・・どうしてよ？'
	DB	"Reiko:  Why not?"
	DB	NEXT
;	DB	'【%001】：・・・嫌いだから。'
	DB	"%001:  'Cuz I don't want to."
	EF_SET 101
	DW	0000H

M5:		;話す　清美１
	DB	BUF,B_COPY01
	T_CG 'CT02','S','I',0,2
;	DB	'【清美】：・・・%001さん・・・お薬、貰って来ましょうか？。'
	DB	"Kiyomi:  Just go get some medicine!"
	DB	NEXT
;	DB	'【%001】：・・・・・・要らない。'
	DB	"%001:  I don't need it."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ........................"
	EF_SET 102
	DW	0000H

M6:		;話す　美緒１
	DB	BUF,B_COPY01
	T_CG 'CT03','S',0,12,3
;	DB	'【美緒】：・・・%001先輩・・・'
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・大丈夫だよ、美緒ちゃん。'
	DB	"%001:  I'm fine, Mio."
	DB	NEXT
;	DB	'【美緒】：でも・・・辛そう・・・'
	DB	"Mio:  But you seem so..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	EF_SET 103
	DW	0000H

M7:		;話す　恵依美１
	DB	BUF,B_COPY01
	T_CG 'CT08','S',0,30,8
;	DB	'【恵依美】：%001。'
	DB	"Meimi:  %001."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........."
	DB	PAUSE
;	DB	'ん？'
	DB	"Hm?"
	DB	NEXT
;	DB	'【恵依美】：世の中、気合いだけじゃど～にもならない事もあるわよ。'
	DB	"Meimi:  You know, there are some things that you just"
	DB	CR
	DB	"can't fight all by yourself."
	DB	NEXT
;	DB	'【%001】：・・・・・・ん～・・・・・・'
	DB	"%001:  Mmmm....."
	DB	NEXT
;	DB	'【恵依美】：・・・ちょっと、聞いてる？'
	DB	"Meimi:  ...Hey, are you listening?"
	DB	NEXT
;	DB	'【%001】：・・・・・・ん～・・・・・・'
	DB	"%001:  Mmmmm....."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ......."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:		;話す　恵依美２
	DB	BUF,B_COPY01
	T_CG 'CT08','S',0,30,8
;	DB	'【恵依美】：・・・今日はもう、帰ったら？'
	DB	"Meimi:  Why don't you go home?"
	DB	NEXT
;	DB	'【%001】：・・・・・・ん～・・・・・・'
	DB	"%001:  Mmmmm..."
	DB	NEXT
;	DB	'【恵依美】：・・・ちょっとは聞きなさいよ、人の話を。'
	DB	"Meimi:  Hey, listen to me. I'm talking to you."
	DB	NEXT
;	DB	'【%001】：・・・・・・ん～・・・・・・'
	DB	"%001:  Mmmmm..."
	EF_SET 104
	DW	0000H

M9:		;話す　星愛１
	DB	BUF,B_COPY01
	T_CG 'CT07','S',0,10,7
;	DB	'【星愛】：ちゃんと暖かくして寝てますか？'
	DB	"Seia:  Why don't you take a nap?"
	DB	NEXT
;	DB	'【%001】：・・・・・・ん～・・・・・・'
	DB	"%001:  Mmmmm..."
	EF_SET 105
	DW	0000H

M10:		;話す　誠１
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,0,4
;	DB	'【誠】：おい、%001。'
	DB	"Makoto:  Hey, %001."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ...................."
	DB	PAUSE
;	DB	'ん～？'
	DB	"Hm?"
	DB	NEXT
;	DB	'【誠】：お前、わざとやってないか？'
	DB	"Makoto:  Say, are you faking all this?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・何を？'
	DB	"%001:  No!"
;	DB	NEXT
;	DB	'【誠】：・・・・・・'
;	DB	NEXT
;	DB	'【誠】：いや、なんでもない。そんな事する必要ないもんな、お前。'
;	DB	"Makoto:  Oh, nothing. You wouldn't have to bother with"
;	DB	CR
;	DB	"that, anyway."
;	DB	NEXT
;	DB	'【%001】：？'
;	DB	"%001:  ???"
	DB	FLG,F_COPYI,6,1
	DW	0000H

M11:		;話す　誠２
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,0,4
;	DB	'【誠】：とにかく、保健室でも病院でも行って、とっとと治してもらえ。'
	DB	"Makoto:  Will you get some medical attention already?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・つめて～奴。'
	DB	"%001:  Oh, piss off."
	DB	NEXT
;	DB	'【誠】：こうでも言わんと、行かないだろ～が。'
	DB	"Makoto:  Well, someone's got to say it, otherwise you"
	DB	CR
	DB	"just won't go, will you."
	EF_SET 106
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,7,255,101,102,103,104,105,106
	DB FLG,F_EXIT,255
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT01','S','D',35,1
;	DB	'【鈴子】：・・・あーもー！子供みたいな事言ってないで！'
	DB	"Reiko:  ...Oh, come on! Don't be such a baby!"
;	DB	'とにかく・・・'
	DB	NEXT
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ........."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・ベル、鳴ってるけど。'
	DB	"%001:  ......There's the bell."
	DB	NEXT
;	DB	'【鈴子】：わかってるわよ！！'
	DB	"Reiko:  I heard it!"
	DB	NEXT
;	DB	'【鈴子】：清美ちゃん、%001君の事お願いね！'
	DB	"Reiko:  Take care of %001, Kiyomi!"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','S','I',0,2
;	DB	'【清美】：・・・は、はい、分かりました。'
	DB	"Kiyomi:  Y- Yes, right."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'【%001】：心配症だなぁ、鈴子さん。'
	DB	"%001:  Reiko's such a worry wart."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ......................................"
	DB	NEXT
;	DB	'【%001】：・・・あ。'
	DB	"%001:  .....Ah."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ......."
	DB	PAUSE
;	DB	'%001さん。'
	DB	"%001?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................."
	DB	PAUSE
;	DB	'ん？呼んだ？'
	DB	"Hm? Are you calling me?"
	DB	NEXT
;	DB	'【清美】：わたくしと一緒に、保健室に参りましょう。'
	DB	"Kiyomi:  Why don't we go to the nurse's office."
	DB	NEXT
;	DB	'【%001】：・・・・・・やだ。'
	DB	"%001:  I don't want to go."
	DB	NEXT
;	DB	'【清美】：そんなワガママをおっしゃっている場合ではないと思うのですが・・・・・・'
	DB	"Kiyomi:  I don't think this is the right time for you to"
	DB	CR
	DB	"be so stubborn."
	DB	NEXT
;	DB	'【%001】：・・・ほら、先生来たぜ。'
	DB	"%001:  Here comes Sensei."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ..............................."
	DB	NEXT
	DB	SINARIO,'CS704.OVL',0
	DW	0000H


end
