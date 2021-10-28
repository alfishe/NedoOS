;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　７０２
;		鈴子の誕生２日前

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

;VV1:	DB	1,	'話す',0
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
S1:		DW	VV1, NN1,  1, M2, M3		;話す　鈴子４
S2:		DW	VV1, NN2,  2, M6		;話す　清美１
S3:		DW	VV1, NN3,  3, M7		;話す　美緒１
S4:		DW	VV1, NN4,  4, M8		;話す　恵依美１
S5:		DW	VV1, NN5,  5, M9, M10, M11		;話す　星愛３
S6:		DW	VV1, NN6,  6, M12, M13		;話す　誠２


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT 'AB_36_4'
	B_O B_SUDA
;	DB	'【清美】：・・・%001さん。'
	DB	"Kiyomi:  %001?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	NEXT
;	DB	'【清美】：%001さん。'
	DB	"Kiyomi:  ........%001?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	NEXT
;	DB	'【清美】：%001さん！'
	DB	"Kiyomi:  %001!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	NEXT
;	DB	'【清美】：しゅ・う・じ・さん！！'
	DB	"Kiyomi:  %001!"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','S','I',0,2
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	NEXT
;	DB	'【%001】：わっ！？びっくりしたっ！'
	DB	"%001:  Wahh! You scared me!"
	DB	NEXT
;	DB	'【清美】：大丈夫ですか？'
	DB	"Kiyomi:  Are you okay?"
	DB	NEXT
;	DB	'【%001】：・・・何が？'
	DB	"%001:  What do you mean?"
	DB	NEXT
;	DB	'【清美】：もうすぐ先生がいらっしゃいますわ。教科書など出しておかなくて、よろしいのですか？'
	DB	"Kiyomi:  The professor is coming in a minute. Don't you"
	DB	CR
	DB	"want to take your textbooks out or something?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............."
	DB	NEXT
;	DB	'【%001】：ああ、そか。さんきゅ。'
	DB	"%001:  Oh, right. Thanks."
	DB	NEXT
;	DB	'【清美】：・・・あの・・・保健室に行かなくてよろしいのですか？'
	DB	"Kiyomi:  Don't you want to go to the nurse's office? Your"
	DB	CR
	DB	"face is really red."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..................."
	DB	NEXT
;	DB	'【%001】：気のせいだよ。'
	DB	"%001:  It's nothing."
	DB	NEXT
;	DB	'【清美】：・・・そうでしょうか？お声もなんだか、変ですわ。'
	DB	"Kiyomi:  Are you sure? Your voice sounds strange too."
	DB	NEXT
;	DB	'【%001】：・・・気のせいだってば。'
	DB	"%001:  I told you, I'm fine."
	DB	NEXT
;	DB	'【清美】：でも、一応は行った方がよろしいと思いますわ。'
	DB	"Kiyomi:  But I still think it would be better if you went."
	DB	NEXT
;	DB	'【%001】：大丈夫だって。・・・それにもうすぐ、先生来るんだろ？'
	DB	"%001:  I'm fine, okay? Besides, the professor will be"
	DB	CR
	DB	"here any minute."
	DB	NEXT
;	DB	'【清美】：・・・はあ・・・'
	DB	"Kiyomi:  .......Alright."
	DB	NEXT
	DB	ANI,A_OFF
	B_P1 B_SUDA
;	DB	'・・・・・・・・・・・・・・・・'
	DB	".............................."
	DB	NEXT
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','S',0,12,3
	T_CG 'CT01','S',0,35,5
	DB	ANI,A_ON,3
;	DB	'【鈴子】：%001く～ん。'
	DB	"Reiko:  %001."
	DB	NEXT
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【鈴子・美緒】：お昼食べましょっ！'
	DB	"Reiko/Mio:  Let's have lunch!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........................."
	DB	NEXT
;	DB	'【鈴子】：・・・%001君？',CR
	DB	"Reiko:  %001?",CR
	DB	"Mio:  %001?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【%001】：ああ、鈴子さんに美緒ちゃん。'
	DB	"%001:  Oh, hi, Reiko, Mio."
	DB	NEXT
;	DB	'【鈴子・美緒】：・・・・・・・・・'
	DB	"Reiko/Mio:  ......................."
	DW	0000H

M2:		;話す　鈴子１
	DB	BUF,B_COPY01
	T_CG 'CT01','S','I',35,1
;	DB	'【鈴子】：・・・大丈夫？何だかボーッとしてるみたいだけど。'
	DB	"Reiko:  Are you okay? You look kind of spaced out."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................."
	DB	NEXT
	T_CG1 'CT14','S',0,0,4
	DB ANI,A_ON,1
;	DB	'【誠】：だいじょーぶですよ。こいつがボーッとしてるの、今に始まった事じゃないから。'
	DB	"Makoto:  Oh, that's okay. This wouldn't be the first"
	DB	CR
	DB	"time that's happened."
	DB	NEXT
;	DB	'【%001】：・・・・・・こら誠、誰がボーッとしてるって？'
	DB	"%001:  What, Makoto, who are you saying is spaced out?"
	DB	NEXT
;	DB	'【誠】：何だ、ちゃんと聞こえてるじゃないか。'
	DB	"Makoto:  Man, he can't even hear properly."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .............................."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;話す　鈴子２
	DB	BUF,B_COPY01
	T_CG 'CT01','S','I',35,1
;	DB	'【鈴子】：・・・%001君、顔赤くない？'
	DB	"Reiko:  %001, your face is so red."
	DB	NEXT
;	DB	'【%001】：・・・・・・そんな事はないよ。'
	DB	"%001:  No. I'm fine."
	DB	NEXT
;	DB	'【鈴子】：声も何だか、変よ？'
	DB	"Reiko:  Your voice is funny, too."
	DB	NEXT
;	DB	'【%001】：・・・気のせい。'
	DB	"%001:  It's nothing."
	EF_SET 101
	DW	0000H

M6:		;話す　清美１
	DB	BUF,B_COPY01
	T_CG 'CT02','S','I',0,2
;	DB	'【清美】：%001さん・・・・・・本当に、大丈夫なのですか？'
	DB	"Kiyomi:  %001, are you really okay?"
	DB	NEXT
;	DB	'【%001】：ああ、全然平気。'
	DB	"%001:  I'm totally fine."
	DB	NEXT
;	DB	'【清美】：でしたら、よろしいのですが・・・・・・'
	DB	"Kiyomi:  If you say so..."
	EF_SET 102
	DW	0000H

M7:		;話す　美緒１
	DB	BUF,B_COPY01
	T_CG 'CT03','S',0,12,3
;	DB	'【美緒】：%001先輩・・・・・・'
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	'【%001】：・・・あ～、大丈夫大丈夫。'
	DB	"%001:  Oh, I'm fine, I'm fine."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・'
	DB	"Mio:  ......................"
	EF_SET 103
	DW	0000H

M8:		;話す　恵依美１
	DB	BUF,B_COPY01
	T_CG 'CT08','S',0,30,8
;	DB	'【恵依美】：・・・%001、あんたホントに大丈夫なの？'
	DB	"Meimi:  %001, are you sure you're okay?"
	DB	NEXT
;	DB	'【%001】：ああ、ぴんぴんしてるぜ。見りゃ分かるだろ？'
	DB	"%001:  I'm just fine and dandy. Isn't that obvious?"
	DB	NEXT
;	DB	'【恵依美】：・・・そ～見えないから、聞いてるんだけど。'
	DB	"Meimi:  Well, it doesn't look like it, but whatever you"
	DB	CR
	DB	"say."
	EF_SET 104
	DW	0000H

M9:		;話す　星愛１
	DB	BUF,B_COPY01
	T_CG 'CT07','S',0,10,7
;	DB	'【星愛】：くしゃみの方は、治まったみたいですわね。'
	DB	"Seia:  It looks like you've stopped sneezing."
	DB	NEXT
;	DB	'【%001】：だろ？'
	DB	"%001:  Yup."
	DB	NEXT
;	DB	'【星愛】：ですが、声がおかしいようですわ。'
	DB	"Seia:  But now your voice sounds odd."
	DB	NEXT
;	DB	'【星愛】：くしゃみや咳と言うのは、異物を排除する為の身体の防衛行動ですのよ。'
	DB	"Seia:  Coughing and sneezing are defense mechanisms your"
	DB	CR
	DB	"body uses to expel contaminants."
	DB	NEXT
;	DB	'【星愛】：そして声がおかしいと言う事は、恐らく喉の辺りが腫れて、'
	DB	"Seia:  And your voice is strange because your throat is"
	DB	CR
	DB	"probably swollen, and the air flow of your breathing has"
	DB	CR
	DB	"completely changed."
	DB	NEXT
;	DB	'【星愛】：つまり、異常があるのに防衛機能が働いていないのですね。'
	DB	"Seia:  So even though your body is acting strangely, it"
	DB	CR
	DB	"doesn't mean it's not working to defend itself."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......................"
	DB	NEXT
;	DB	'【%001】：よ～するに「悪化してる」って言いたいのか？'
	DB	"%001:  So what you're saying is I'm getting worse?"
	DB	NEXT
;	DB	'【星愛】：はい、良く出来ました。'
	DB	"Seia:  Good guess."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M10:		;話す　星愛２
	DB	BUF,B_COPY01
	T_CG 'CT07','S',0,10,7
;	DB	'【星愛】：・・・ここまで来たら、病院に行った方が良いですわ。'
	DB	"Seia:  ...At this point, I think it would be better if"
	DB	CR
	DB	"you went to the hospital."
	DB	NEXT
;	DB	'【%001】：・・・び、病院？'
	DB	"%001:  ...H- Hospital?"
	DB	NEXT
;	DB	'【星愛】：ええ。お薬貰うなりお注射してもらうなり、しかるべき処置をするべきですわ。'
	DB	"Seia:  Yes. You should get some medicine and have yourself"
	DB	CR
	DB	"looked at. You definitely need to have this treated."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【誠】：お？何だ%001、引きつった顔しちゃって。'
	DB	"Makoto:  Oho? %001, you look like you're at a loss for"
	DB	CR
	DB	"words."
	DB	NEXT
;	DB	'【%001】：・・・・・・何でもねぇよ。'
	DB	"%001:  It's nothing."
	DB	NEXT
	T_CG1 'CT08','S',0,30,8
	DB ANI,A_ON,7
;	DB	'【恵依美】：・・・もしかして%001、注射が怖いの？'
	DB	"Meimi:  So %001, are you afraid of the doctor?"
	DB	NEXT
;	DB	'【誠】：・・・ほほぅ。%001、お前そこまでお子様だったのか。'
	DB	"Makoto:  Hohoho. %001, are you that much of a baby?"
	DB	NEXT
;	DB	'【%001】：ばっ、バカ言え！'
	DB	"%001:  Shut up, will you?"
	DB	FLG,F_COPYI,5,2
	DW	0000H

M11:		;話す　星愛３
	DB	BUF,B_COPY01
	T_CG 'CT07','S',0,10,7
;	DB	'【星愛】：とにかく、１度お医者様に見てもらうべきですわ。'
	DB	"Seia:  Well, you should at least go see the doctor once."
	DB	NEXT
;	DB	'【%001】：・・・その内な。'
	DB	"%001:  Yeah, yeah."
	EF_SET 105
	DW	0000H

M12:		;話す　誠１
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,0,4
;	DB	'【誠】：・・・%001。相変わらず贅沢な奴だな、お前。'
	DB	"Makoto:  %001, always the center of attention, aren't you?"
	DB	NEXT
;	DB	'【%001】：・・・・・・何が？'
	DB	"%001:  ...Huh?"
	DB	NEXT
;	DB	'【誠】：こーんなにみんなに心配されてよ・・・あーあ、オレも風邪ひきたくなって来たな。'
	DB	"Makoto:  Everyone's all worried about you. It makes me want"
	DB	CR
	DB	"to catch a cold too."
	DB	NEXT
;	DB	'【%001】：やろうか？'
	DB	"%001:  Here, you want it?"
	DB	NEXT
;	DB	'【誠】：お前のは要らん。'
	DB	"Makoto:  I can't use yours. It's already used. I need a new",CR,"one."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M13:		;話す　誠２
	DB	BUF,B_COPY01
	T_CG 'CT14','S',0,0,4
;	DB	'【誠】：お前の風邪は要らん。'
	DB	"Makoto:  I don't want your cold."
	DB	NEXT
;	DB	'【%001】：そう言うな、誠。お前だって、俺に早く治って欲しいだろ？'
	DB	"%001:  So, Makoto, you're saying you want me to get better"
	DB	CR
	DB	"fast?"
	DB	NEXT
;	DB	'【誠】：ああ、オレに移す前にな。'
	DB	"Makoto:  Yeah, before I catch it, that is."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	EF_SET 106
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,7,255,101,102,103,104,105,106
	DB FLG,F_EXIT,255
	DB	BUF,B_COPY01
	T_CG 'CT01','S','I',35,1
	DB	NEXT
;	DB	'【鈴子】：・・・ちょっと見せてごらんなさい。'
	DB	"Reiko:  Here, let me see."
	DB	NEXT
;	DB	'さっ。'
	DB	"Uh..."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・何で逃げるのよ？'
	DB	"Reiko:  What are you afraid of?"
	DB	NEXT
;	DB	'【%001】：・・・・・・何とも無いから。'
	DB	"%001:  I'm not."
	DB	NEXT
;	DB	'【鈴子】：何とも無いんだったら、いいじゃない。'
	DB	"Reiko:  If you're not, then let me look."
	DB	NEXT
;	DB	'【%001】：・・・・・・ダメ。'
	DB	"%001:  No."
	DB	NEXT
;	DB	'【鈴子】：どーしてよ？'
	DB	"Reiko:  Why not?"
	DB	NEXT
;	DB	'【%001】：・・・それは・・・'
	DB	"%001:  That's..."
	DB	NEXT
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
;	DB	'【%001】：ほ、ほら予鈴だよ鈴子さん。'
	DB	"%001:  Oh, Reiko, wasn't that the bell?"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ............"
	DB	NEXT
;	DB	'【鈴子】：明日、また来るから。'
	DB	"Reiko:  I'll come back later."
	DB	NEXT
	B_P1 0
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'（ほっ）'
;	DB	"(***)"
;	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','S','I',0,2
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  ............."
	DB	NEXT
	DB	SINARIO,'CS703.OVL',0
	DW	0000H


end
