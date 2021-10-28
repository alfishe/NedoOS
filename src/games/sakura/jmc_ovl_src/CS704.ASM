;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　７０４
;		鈴子の誕生前日　保健室

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2
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
CM1:	DW	VV1,	NN1,NN2,-1

VV1:	DB	1,	'TALK',0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	"KIYOMI",0
;NN2:	DB	2,	'恵依美',0
NN2:	DB	2,	"MEIMI",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;話す　清美２
S2:		DW	VV1, NN2,  2, M4, M5, M6, M7, M8		;話す　恵依美５


;イニシャルメッセージ
M1:
	DB	BGM,6
	B_O B_SUDA
	E_CG B_SUDA,'AE_024'
;	DB	'【今日子】：・・・・・・と、まぁこーゆー反応式になる訳やね。'
	DB	"Kyoko:  .....So you see, A is always inversely related"
	DB	CR
	DB	"to B.",PAUSE
;	DB	'わかったぁ？'
	DB	" Understand?"
	DB	NEXT
;	DB	'【今日子】：んじゃ次のこの式をぉ・・・%001君、ちょっちやって見てくんない？'
	DB	"Kyoko:  And now the next equation..... %001, come and try"
	DB	CR
	DB	"this one, will you?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'【清美】：・・・%001さん！%001さん！先生が呼んでらっしゃいますわよ！'
	DB	"Kiyomi:  %001! The professor's calling on you!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........................."
	DB	PAUSE
;	DB	'ん？なに？'
	DB	"Huh? What?"
	DB	NEXT
;	DB	'【清美】：先生が、黒板の問題を解いて下さい、っておっしゃってますわ！'
	DB	"Kiyomi:  Sensei says she wants you to solve the problem"
	DB	CR
	DB	"on the blackboard!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..................."
	DB	PAUSE
;	DB	'あ、そう。'
	DB	"Oh, right."
	DB	NEXT
	DB	GATA,1
;	DB	'（・・・あ、あれ？）'
	DB	".....Eh?"
	DB	NEXT
;	DB	'（・・・目が・・・）'
	DB	"My eyes..."
	DB	NEXT
	DB	GATA,2
	B_O B_NORM
	DB	"*CRASH*"
	DB	NEXT
;	DB	'【清美】：%001さん！！'
	DB	"Kiyomi:  %001!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"............"
	DB	NEXT
;	DB	'【今日子】：・・・んじゃ清美ちゃん恵依美ちゃん、悪いけど頼んだわね。'
	DB	"Kyoko:  Sorry, Kiyomi, Meimi, but would you take me to"
	DB	CR
	DB	"the nurse's office?"
	DB	NEXT
;	DB	'【清美】：はい、分かりました。'
	DB	"Kiyomi:  Of course."
	DB	NEXT
;	DB	'【恵依美】：ホントにもう、しょーがないんだからぁ・・・・・・'
	DB	"Meimi:  You should have gone there two hours ago!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	"......................"
	DB	NEXT
;	DB	'【保険医】：・・・それじゃ、これを飲ませておいてね。'
	DB	"School nurse:  ...Okay, here, give him this. I have some",CR,"other things to take care of."
	DB	NEXT
;	DB	'【清美】：はい、分かりました。・・・ありがとうございます。'
	DB	"Kiyomi:  We understand. Thank you."
	DB	NEXT
;	DB	'【保健医】：ふふ・・・じゃ、お大事にね。'
	DB	"School nurse:  No problem. Well, take care."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・'
	DB	"Meimi:  ....................."
	DB	NEXT
;	DB	'【恵依美】：それを飲ませればいいの？'
	DB	"Meimi:  You think it's okay if we give it to him?"
	DB	NEXT
;	DB	'【清美】：ええ、お昼済ませたばかりですし。'
	DB	"Kiyomi:  Yes, it says to take it after lunch."
	DB	NEXT
;	DB	'【恵依美】：わかったわ。・・・ほら、%001起きて。薬よ。'
	DB	"Meimi:  Okay. Hey, wake up, %001. It's time for your"
	DB	CR
	DB	"medicine."
	DB	NEXT
	BAK_INIT 'AB_42'
	DB	BUF,B_COPY01
	TU_CG 'CT08','S',0,0,1
	TU_CG 'CT02','S',0,30,2
	B_P0 B_FADE
	DB	ANI,A_ON,1
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............"
	DB	NEXT
;	DB	'【%001】：・・・くす・・・り・・・？'
	DB	"%001:  Medicine?"
	DB	NEXT
;	DB	'【恵依美】：そう。これを飲めば、す～ぐ治っちゃうんだから！'
	DB	"Meimi:  Right. If you take this, you'll get better in no time!"
	DB	NEXT
;	DB	'【清美】：・・・いくらなんでも、すぐには治らないのでは・・・？'
	DB	"Kiyomi:  Well, we don't really know if he'll get better"
	DB	CR
	DB	"right away."
	DB	NEXT
;	DB	'【恵依美】：・・・い～じゃないの、そんな細かい事！さ、%001・・・
	DB	"Meimi:  ...Oh, details! Okay, %001..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..................."
	DB	NEXT
;	DB	'【%001】：・・・それ、もしかして薬か？'
	DB	"%001:  ...I guess that's medicine?"
	DB	NEXT
	K_CG 'CT02','K',30,3
	DB	ANI,A_ON,1
;	DB	'【清美】：ええ、粉薬と錠剤がありますわ。食後３０分以内に飲めば'
	DB	"Kiyomi:  There's some powder, and a pill."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .................."
	DB	NEXT
	DB	'%001:  N',T_WAIT,3,'O',T_WAIT,3,'!!!!!!!!!'
	DB	NEXT
	K_CG 'CT08','D',0,4
	K_CG 'CT02','I',30,5
	DB	ANI,A_ON,4
;	DB	'【恵依美】：ち、ちょっと%001！？'
	DB	"Meimi:  Hey, %001?!"
	DB	CR
;	DB	'【清美】：%001さん！？'
	DB	"Kiyomi:  %001?"
	DB	NEXT
;	DB	'【%001】：嫌だ～！帰る～！'
	DB	"%001:  I hate medicine! I'm leaving!"
	DB	NEXT
	E_CG B_FADE,'AE_029'	;イベントＣＧ
;	DB	'【恵依美】：こら！まちなさい！'
	DB	"Meimi:  Hey, wait!"
	DB	NEXT
;	DB	'【清美】：%001さん！一体どうなされたんですか！？'
	DB	"Kiyomi:  %001! What do you think you're doing?!"
	DW	0000H

M2:		;話す　清美１
;	DB	'【清美】：%001さん！落ち着いて下さい！'
	DB	"Kiyomi:  %001! Calm down!"
	DB	NEXT
;	DB	'【%001】：嫌だ～！薬は嫌だ～！'
	DB	"%001:  I hate this! I hate medicine!"
	DW	0000H

M3:		;話す　清美２
;	DB	'【清美】：%001さん・・・御気分はいかがですか？'
	DB	"Kiyomi:  %001, How are you feeling?"
	DB	NEXT
;	DB	'【%001】：・・・・・・最低。'
	DB	"%001:  Horrible."
	DW	0000H

M4:		;話す　恵依美１
;	DB	'【恵依美】：こら！暴れるなっ！'
	DB	"Meimi:  Come on! Stop making a fuss!"
	DB	NEXT
;	DB	'【%001】：嫌だ～！薬は嫌だ～！苦いのは嫌いだ～！'
	DB	"%001:  I hate it! I hate medicine! It's bitter!"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　恵依美２
;	DB	'【恵依美】：な～に子供みたいな事言ってんのよ！大人しくしなさい！'
	DB	"Meimi:  Stop being such a child! Grow up, will you?"
	DB	NEXT
;	DB	'【%001】：嫌だ～！飲みたくない～！'
	DB	"%001:  I hate it! I won't take it!"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　恵依美３
;	DB	'【恵依美】：飲まないと治らないわよ！'
	DB	"Meimi:  If you don't take it, you won't get better!"
	DB	NEXT
;	DB	'【%001】：治らなくてもいい～！'
	DB	"%001:  I don't care!"
	DB	NEXT
;	DB	'【恵依美】：ワガママ言うなっ！！'
	DB	"Meimi:  Don't be stupid!"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M7:		;話す　恵依美４
;	DB	'【恵依美】：・・・も～ラチあかないわっ！清美！そっち抑えて！'
	DB	"Meimi:  Okay, we're not getting anywhere! Kiyomi! Hold"
	DB	CR
	DB	"him down!"
	DB	NEXT
;	DB	'【清美】：は、はい！'
	DB	"Kiyomi:  O- Okay!"
	DB	NEXT
;	DB	'【%001】：こら～！はなひぇ～！'
	DB	"%001:  Hey! Let go!"
	DB	NEXT
;	DB	'【恵依美】：清美！薬っ！'
	DB	"Meimi:  Kiyomi! Medicine!"
	DB	NEXT
;	DB	'【清美】：は、はい！'
	DB	"Kiyomi:  O- Okay!"
	DB	NEXT
;	DB	'【恵依美】：それっ！'
	DB	"Meimi:  There!"
	DB	NEXT
	DB	'GLUG ',T_WAIT,1,'GLUG ',T_WAIT,1,'GLUG ',T_WAIT,1,'GLUG ',T_WAIT,1,'GLUG ',T_WAIT,1,'GLUG '
	DB	NEXT
;	DB	'【%001】：・・・！！！'
	DB	"%001:  !!!!"
	DB	NEXT
;	DB	'【恵依美】：えいっ！'
	DB	"Meimi:  And there!"
	DB	NEXT
	DB	'GLUG ',T_WAIT,1,'GLUG ',T_WAIT,1,'GLUG ',T_WAIT,1,'GLUG ',T_WAIT,1,'GLUG ',T_WAIT,1,'GLUG '
	DB	NEXT
;	DB	'【%001】：＆＠＃＄％△☆◆！！'
	DB	"%001:  &@#$*!!"
	DB	NEXT
;	DB	'【恵依美】：仕上っ！'
	DB	"Meimi:  Now you'll take the last one like a good boy!"
	DB	NEXT
	DB	FLASH,1
;	DB	'ばくん！',CR
	DB	"*SLAP*",CR 
	DB	PAUSE
;	DB	'ごっくん。'
	DB	"*GULP*"
	DB	NEXT
;	DB	'【恵依美】：・・・はい、一丁上がり！'
	DB	"Meimi:  .....There we go!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............."
	DB	NEXT
;	DB	'【清美】：・・・%001さん・・・大丈夫ですか？'
	DB	"Kiyomi:  %001, are you all right?"
	DB	NEXT
;	DB	'【%001】：・・・だい゛じょう゛ぶじゃね゛え゛や゛い゛・・・'
	DB	"%001:  .......I.. don't......think....so...."
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,4
	DW	0000H

M8:		;話す　恵依美５
;	DB	'【%001】：・・・中野・・・お前な～～～～～～・・・'
	DB	"%001:  ...Meimi...You..."
	DB	NEXT
;	DB	'【恵依美】：なによぉ。%001がワガママだからいけないんでしょ。'
	DB	"Meimi:  Oh, what? You gave me no choice."
	DB	NEXT
;	DB	'【%001】：それにしたってお前、も～ちょっとやりようが・・・・・・'
	DB	"%001:  You could have killed me...!"
	DB	NEXT
;	DB	'【恵依美】：・・・うるさいわね。病人は黙って寝てなさい！'
	DB	"Meimi:  Oh, shush. The patient must sleep!"
	DB	NEXT
	DB	FLASH,1
	B_O B_NORM
;	DB	'いきなり俺はひんやりしたもの（多分タオル）を顔に喰らい、'
	DB	"Suddenly something cool and pleasant smothered my face,",CR
;	DB	'そのまま枕に押しつけられてしまった。'
	DB	"and pushed me down on the pillow."
	DB	NEXT
;	DB	'ふわっ。'
;	DB	"Aaaah."
;	DB	NEXT
;	DB	'【清美】：そうですわ。お薬も飲んだ事ですし、ちゃんと寝ていればすぐに良くなりますわ。'
	DB	"Kiyomi:  That's good. Now that you took the medicine,"
	DB	CR
	DB	"you'll be able to fall asleep and get well."
	DB	NEXT
;	DB	'あったかいもの（恐らく掛け布団）が身体に掛けられる感触。'
	DB	"I felt something warm (probably a blanket) cover my body."
	DB	NEXT
;	DB	'多分、新藤さんが掛けてくれたんだろう。'
	DB	"That was probably Kiyomi."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........................."
	DB	NEXT
;	DB	'【%001】：わかったよ、新藤さん。大人しく寝てる。'
	DB	"%001:  I'll behave, Kiyomi. I'll take a nap."
	DB	NEXT
;	DB	'【清美】：はい。それが１番ですわ。'
	DB	"Kiyomi:  Good. That's the best thing."
	DB	NEXT
;	DB	'【清美】：では、私達は教室に戻らせて頂きますわ。お大事になさって下さいね。'
	DB	"Kiyomi:  All right then, we'll be going back to class."
	DB	CR
	DB	"Take care."
	DB	NEXT
;	DB	'【恵依美】：ちゃんと寝てるのよ。'
	DB	"Meimi:  Have a good rest."
	DB	NEXT
;	DB	'【%001】：・・・・・・へ～い。'
	DB	"%001:  Alright."
	DB	NEXT
;	DB	'がちゃり。'
;	DB	"Creak."
;	DB	NEXT
;	DB	'たったったったったっ・・・・・・・'
	DB	"Patterpatterpatter..."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	"......."
	DB	NEXT
;	DB	'【%001】：・・・新藤さん達は、行っちまったみたいだな。'
	DB	"%001:  Well, I guess they left."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	DB	NEXT
;	DB	'【%001】：なんだかんだ言って、中野の奴も心配してくれてるんだろうな。'
	DB	"%001:  No matter what she says, even Meimi's worrying"
	DB	CR
	DB	"about me a bit too."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ...................."
	DB	PAUSE
;	DB	'寝よ。'
	DB	"Time to sleep."
	DB	NEXT
	DB	SINARIO,'CS705.OVL',0
	DW	0000H


end
