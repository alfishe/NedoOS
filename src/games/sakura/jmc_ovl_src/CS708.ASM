;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　７０８
;		鈴子の誕生日２日後　ＨａｐｐｙＢｉｒｔｈｄａｙｆｏｒ・・・Ｙｏｕ

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	-1
MSGTBL:
	DW	M1
COMTBL:
	DW	-1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT 'AB_36_4'
	DB BUF,B_COPY01
	B_P1 B_YOKO
;	DB	'【%001】：・・・・・・うーっす！'
	DB	"%001:  Good morning!"
	DB	NEXT
	T_CG 'CT14','S',0,35,1
;	DB	'【誠】：おう、%001。'
	DB	"Makoto:  Hey, %001."
	DB	PAUSE
;	DB	'・・・ど～やらすっかり、治ったらしいな。'
	DB	" Hey, you look a lot better now."
	DB	NEXT
;	DB	'【%001】：ああ、絶好調だぜ！'
	DB	"%001:  Yeah, I feel great!"
	DB	NEXT
	T_CG1 'CT02','S',0,0,2
	DB ANI,A_ON,1
;	DB	'【清美】：おはようございます・・・もうお宜しいのですか？'
	DB	"Kiyomi:  Good morning. Are you feeling better?"
	DB	NEXT
;	DB	'【%001】：おう、完璧！'
	DB	"%001:  Yeah, fantastic!"
	DB	NEXT
	T_CG1 'CT08','S','K',20,3
	DB ANI,A_ON,2
	DB ANI,A_ON,1
;	DB	'【恵依美】：おっはよ～%001！すっかり元気みたいね。'
	DB	"Meimi:  Hi there, %001! You're looking peppy."
	DB	NEXT
;	DB	'【%001】：おお、完全復活だぜ！'
	DB	"%001:  Yeah, I feel like a new man!"
	DB	NEXT
;	DB	'【恵依美】：・・・ほ～んと、この前まで死に掛かってたとは思えないわね～。'
	DB	"Meimi:  Yeah, you were really looking close to death for"
	DB	CR
	DB	"a while there."
	DB	NEXT
;	DB	'【%001】：・・・ほっとけ。'
	DB	"%001:  Yeah, well."
	DB	NEXT
;	DB	'きーんこーんかーんこーん。'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
;	DB	'【誠】：お、チャイムだ。'
	DB	"Makoto:  Oh, the bell."
	DB	NEXT
;	DB	'【%001】：・・・んじゃ準備すっか。'
	DB	"%001:  Well, better get ready for class then."
	DB	NEXT
;	DB	'【清美】：・・・%001さん・・・それは・・・？'
	DB	"Kiyomi:  ....%001, what's that...?"
	DB	NEXT
;	DB	'【%001】：あ、これ？鈴子さんへの誕生日プレゼント。'
	DB	"%001:  Oh, this? This is Reiko's birthday present."
	DB	NEXT
;	DB	'【清美】：・・・・・・・・・'
	DB	"Kiyomi:  .................."
	DB	NEXT
	T_CG1 'CT08','S',0,20,4
	DB ANI,A_ON,2
	DB ANI,A_ON,1
;	DB	'【恵依美】：・・・ふ～ん・・・ちょっと見せてよ。'
	DB	"Meimi:  Really, can I see it?"
	DB	NEXT
;	DB	'【%001】：・・・なんで？'
	DB	"%001:  Why?"
	DB	NEXT
;	DB	'【恵依美】：・・・い～じゃないのよ、ちょっとくらい。'
	DB	"Meimi:  I just want to see it, that's all."
	DB	NEXT
;	DB	'【%001】：だから、何でお前が見たいんだ？お前にやるんじゃね～んだぞ。'
	DB	"%001:  But why do you want to see it? I didn't make it"
	DB	CR
	DB	"for you, you know."
	DB	NEXT
	K_CG 'CT08','D',20,5
	DB ANI,A_ON,2
	DB ANI,A_ON,1
;	DB	'【恵依美】：・・・なによ、減るもんでもないでしょ？'
	DB	"Meimi:  What, is it private or something?"
	DB	NEXT
;	DB	'【%001】：そらま～そーだが。'
	DB	"%001:  None of your business."
	DB	NEXT
;	DB	'【今日子】：おはようしょくん～！'
	DB	"Kyoko:  Hi there, everybody!"
	DB	NEXT
;	DB	'【%001】：あ、先生だ。'
	DB	"%001:  Oh, it's Sensei."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【星愛】：・・・きりーつ！礼！ちゃくせーき！'
	DB	"Seia:  .... Stand! ... Bow! ... Be seated!"
	DB	NEXT
	DB	"(Japanese students do this every day when the teacher"
	DB	CR
	DB	"comes into the classroom.)"
	DB	NEXT
;	DB	'【今日子】：はいはいごくろーさん。んじゃあ、出席ちゃっちゃと取っちゃいましょ～か・・・・・・'
	DB	"Kyoko:  Right, thanks. Now, why don't we take roll..."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"................"
	DB	NEXT
	B_O B_YOKO
	BAK_INIT 'AB_36_1'
;	DB	'【%001】：え～っと、３－Ａ・・・３－Ａ・・・'
	DB	"%001:  .....Hmmmm, 3-A....3-A...."
	DB	PAUSE
;	DB	'あ、ここだ。'
	DB	"Oh, here it is."
	DB	NEXT
	B_P1 B_YOKO
;	DB	'【%001】：・・・鈴子さんは・・・っと。'
	DB	"%001:  Reiko......"
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT01','S',0,20,6
;	DB	'【鈴子】：・・・あら、%001君？どうしたの一体？'
	DB	"Reiko:  ....%001? What are you doing here?"
	DB	NEXT
;	DB	'【%001】：うん、実はね・・・・・・'
	DB	"%001:  ....Um, well..."
	DB	NEXT
;	DB	'ごそごそごそごそ'
	DB	"*RUSTLE RUSTLE*"
	DB	NEXT
;	DB	'【%001】：はい、これ。'
	DB	"%001:  This is for you."
	DB	NEXT
;	DB	'【鈴子】：・・・これは・・・？'
	DB	"Reiko:  What is it?"
	DB	NEXT
;	DB	'【%001】：ちょっと遅れたけど、誕生プレゼント。'
	DB	"%001:  It's a bit late, but it's your birthday present."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・え・・・・・・'
	DB	"Reiko:  ....My what?"
	DB	NEXT
;	DB	'【%001】：いやあ・・・ほら、一昨日何にもあげられなかっただろ？'
	DB	"%001:  Well, I didn't give you anything at your party,"
	DB	CR
	DB	"right?"
	DB	NEXT
;	DB	'【%001】：今更、って気もしたんだけどさ・・・・・・'
	DB	"%001:  So I'm giving it to you now...."
	DB	PAUSE
;	DB	'やっぱり、なんかあげたくて。'
	DB	" I just wanted to give",CR,"you something."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ........."
	DB	NEXT
;	DB	'【%001】：受け取ってもらえる・・・？二日遅れだけど。'
	DB	"%001:  Will you accept it? Even though it's two days late."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ........."
	DB	NEXT
	T_CG1 'CT01','S','K',20,7
;	DB	'【鈴子】：ありがとう、本当に。'
	DB	"Reiko:  Thanks, really."
	DB	NEXT
;	DB	'【鈴子】：嬉しいわ・・・・・・今までで、１番。'
	DB	"Reiko:  I love it. Thank you."
	DB	NEXT
;	DB	'【%001】：そう？'
	DB	"%001:  Really?"
	DB	NEXT
;	DB	'【鈴子】：ええ・・・・・・ありがとう、%001君。'
	DB	"Reiko:  Yes. Thanks, %001."
	DB	NEXT
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
;	DB	'【%001】：・・・っと、チャイムだ。じゃね！'
	DB	"%001:  Well, there's the bell. See ya!"
	DB	NEXT
;	DB	'【鈴子】：うん・・・ありがとう。'
	DB	"Reiko:  Yeah, thanks."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"............"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ........"
	DB	NEXT
;	DB	'【鈴子】：・・・ありがとう、%001君・・・'
	DB	"Reiko:  Thank you, %001...."
	DB	NEXT
;	DB	'【鈴子】：だから・・・だから私・・・'
	DB	"Reiko:  I......I...."

	DB	NEXT

	DB	"..................................."

	DB	NEXT
	B_O B_FADE
	DB	SINARIO,'CS801.OVL',0
	DW	0000H


end
