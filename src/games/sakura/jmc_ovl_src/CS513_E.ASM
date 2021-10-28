;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１３＿Ｅ
;		キャンプファイヤー　準備

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1
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
CM1:	DW	VV1,	-1

;VV1:	DB	1,	'準備する',0
VV1:	DB	1,	"BUILD CAMPFIRE",0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3, M4, M5	;準備する


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_16_2'
	B_P1 B_FADE
;	DB	'・・・そして夕方。'
	DB	"Later that evening..."
	DB	NEXT
;	DB	'すこし早めに晩飯を平らげた俺達は、キャンプに付き物のキャンプファイヤーの準備をしていた。'
	DB	"We finished eating dinner a little early, and started building",CR,"the campfire."
	DB	NEXT
;	DB	'【%001】：・・・こっちの丸太はここに・・・っと・・・'
	DB	"%001:  Put this log over here...!"
	DW	0000H

M2:		;準備する
	DB BUF,B_COPY01
	T_CG 'CT01','F','K',20,1
;	DB	'【鈴子】：ハイ、%001君。'
	DB	"Reiko:  Hey, %001."
	DB	NEXT
;	DB	'【%001】：やあ、鈴子さん。'
	DB	"%001:  Reiko."
	DB	PAUSE
;	DB	'・・・あらよっと！'
	DB	" Watch it!"
	DB	NEXT
;	DB	'【鈴子】：精が出るわね。'
	DB	"Reiko:  That's pretty hard work."
	DB	NEXT
;	DB	'【%001】：ま～ね・・・'
	DB	"%001:  Yes, it is."
	DB	PAUSE
;	DB	'っとこらせっ！'
	DB	" Hey! Careful with that!"
	DB	NEXT
;	DB	'【鈴子】：・・・ねえ%001君、キャンプファイヤーのフォークダンスなんだけど・・・'
	DB	"Reiko:  %001, why don't we have a campfire dance tonight?"
	DB	NEXT
;	DB	'【%001】：あらどっこい！'
	DB	"%001:  Put that one down there!"
	DB	PAUSE
;	DB	'・・・ん？なんか言った？'
	DB	" What? Did you say something?"
	DB	NEXT
;	DB	'【鈴子】：・・・だから、ダンスの事なんだけど・・・'
	DB	"Reiko:  Um, yeah, I was thinking...."
	DB	NEXT
;	DB	'【%001】：てぃやっ！'
	DB	"%001:  Okay, good!"
	DB	PAUSE
;	DB	'・・・え？なんだって？'
	DB	" ....Huh? What?"
	DB	NEXT
	K_CG 'CT01','V',20,2
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  .............."
	DB	PAUSE
;	DB	'忙しいみたいだから、後でね。'
	DB	"You look busy. I'll talk to you later."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【%001】：？'
	DB	"%001:  ???"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;準備する
	DB BUF,B_COPY01
	T_CG 'CT02','F','K',35,3
;	DB	'【清美】：・・・%001さん。'
	DB	"Kiyomi:  .....%001?"
	DB	NEXT
;	DB	'【%001】：あれ、新藤さん。'
	DB	"%001:  Oh, Kiyomi."
	DB	NEXT
;	DB	'【清美】：・・・お話しがあるのですが、少し宜しいでしょうか？'
	DB	"Kiyomi:  I have to talk to you. Do you have a minute?"
	DB	NEXT
;	DB	'【%001】：ふんっ！'
	DB	"%001:  Careful!"
	DB	PAUSE
;	DB	'・・・え？何？'
	DB	" ...Huh? What?"
	DB	NEXT
;	DB	'【清美】：・・・・・・ですから、お話が・・・・・・'
	DB	"Kiyomi:  I said, I have to talk...."
	DB	NEXT
;	DB	'【%001】：うりゃあっ！'
	DB	"%001:  Okay, now this."
	DB	PAUSE
;	DB	'・・・え？なんだって？'
	DB	" ...Eh? What did you say?"
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  .................."
	DB	PAUSE
;	DB	'出直してまいります。'
	DB	"I'll come back later."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【%001】：？'
	DB	"%001:  ???"
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;準備する
	DB BUF,B_COPY01
	T_CG 'CT03','F','K',0,4
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【%001】：やあ、美緒ちゃん。'
	DB	"%001:  Hi, Mio."
	DB	NEXT
;	DB	'【美緒】：・・・あのね、先輩・・・'
	DB	"Mio:  Um, %001?"
	DB	NEXT
;	DB	'【%001】：よいしょっ！'
	DB	"%001:  Okay, bring those over here!"
	DB	PAUSE
;	DB	'・・・ん？なに？'
	DB	" ...Hm? What is it?"
	DB	NEXT
	DB ANI,A_OFF
	T_CG1 'CT03','F',0,0,5
;	DB	'【美緒】：・・・あの・・・'
	DB	"Mio:  .....Um..."
	DB	NEXT
;	DB	'【%001】：せぃやっ！'
	DB	"%001:  Okay, pick it up!"
	DB	PAUSE
;	DB	'・・・ん？'
	DB	" ...Yes, Mio?"
	DB	NEXT
;	DB	'【美緒】：・・・・・・'
	DB	"Mio:  ............"
	DB	PAUSE
;	DB	'先輩！',CR
	DB	"%001!",CR
	T_CG1 'CT06','F','D',27,6
	DB ANI,A_ON,5
;	DB	'【亜希】：ちょっと美緒！'
	DB	"Aki:  Excuse me, Mio."
	DB	NEXT
;	DB	'【美緒】：・・・あ、亜希ちゃん・・・'
	DB	"Mio:  Oh, Aki..."
	DB	NEXT
;	DB	'【亜希】：なぁあぁにこんなとこで油売ってんのよ！？',CR,'さっさと来なさい！'
	DB	"Aki:  Why are you just standing here? You have to help, too!"
	DB	NEXT
;	DB	'【美緒】：ふみゃっ！？'
	DB	"Mio:  Huh?"
	DB	NEXT
	B_P1 B_SUDA
;	DB	'・・・・・・美緒ちゃんは、亜希ちゃんに衿首捕まれて行ってしまった。'
	DB	"...Aki grabbed Mio's sleeve and pulled her away."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .........."
	DB	PAUSE
;	DB	'何だったんだ？一体・・・・・・'
	DB	"I wonder what she wanted?"
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;準備する
;	DB	'【%001】：・・・・・・ま、いいや。こいつを積めば、完成だ。'
	DB	"%001:  All right. When we put this one on top, it'll be done."
	DB	NEXT
	DB ANI,A_INIT
	DB BUF,B_COPY01
	T_CG 'CT04','F','K',37,1
;	DB	'【祥子】：しゅ～く～ん！'
	DB	"Shoko:  Shu-kun!"
	DB	NEXT
;	DB	'【%001】：・・・げげ・・・'
	DB	"%001:  (Uh-oh!)"
	DB	NEXT
;	DB	'【祥子】：ねえねえしゅ～く～ん、あたしとフォークダンスしよ！'
	DB	"Shoko:  Do you want to dance, Shu-kun?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............"
	DB	PAUSE
;	DB	'あ、よいしょっと！'
	DB	"Okay, move that one!"
	DB	NEXT
;	DB	'【祥子】：も～、またまた照れちゃってぇ！'
	DB	"Shoko:  C'mon, don't be shy!"
	DB	NEXT
;	DB	'【%001】：・・・・・・ちょ、ちょっと！'
	DB	"%001:  .....W...Wait!"
	DB	NEXT
;	DB	'【祥子】：ほらぁ、ダンスダンスぅ！'
	DB	"Shoko:  Let's dance!"
	DB	NEXT
;	DB	'【%001】：ちょっとって！仕事出来ないよ！'
	DB	"%001:  Wait! I have stuff to do here!"
	DB	NEXT
;	DB	'【祥子】：そんなのぉ、すぽ～んっとほっといてぇ・・・あたしとダンスしよ！'
	DB	"Shoko:  Oh, come on. You can dance with me!"
	DB	NEXT
;	DB	'【%001】：だあああっ！'
	DB	"%001:  Aaaaaagh! Get her off me!"
	DB	NEXT
	T_CG1 'CT08','F','D',0,2
	DB ANI,A_ON,1
;	DB	'【恵依美】：・・・ちょっと%001！何やってんのよ！'
	DB	"Meimi:  Hi, %001! I was wondering..."
	DB	NEXT
;	DB	'【%001】：な、中野・・・助けてくれ！'
	DB	"%001:  Oh, Meimi! Help me!"
	DB	NEXT
;	DB	'【祥子】：なになに～、あんたなに～？'
	DB	"Shoko:  What? What are you...."
	DB	PAUSE
;	DB	'あたしとしゅ～君はぁ',CR,'「すてでぃ」なんだからぁ、邪魔しないでくれるぅ～？みたいなぁ～。'
	DB	" Shu-kun and I are going"
	DB	CR
	DB	"steady, so butt out, please."
	DB	NEXT
;	DB	'【恵依美】：・・・なっっ・・・'
	DB	"Meimi:  .....Wha..."
	DB	NEXT
;	DB	'【%001】：こら！いつ誰がそ～なったっ！'
	DB	"%001:  We're going steady? Since when?"
	DB	NEXT
;	DB	'【恵依美】：・・・とにかく！%001の邪魔しないでよ！'
	DB	"Meimi:  Hey, you! Stop bothering %001!"
	DB	NEXT
;	DB	'【祥子】：ふ～んだ、誰も邪魔だなんて言ってないも～ん。'
	DB	"Shoko:  Oh? Who said anything about bothering anybody?"
	DB	NEXT
;	DB	'【%001】：・・・さっきから言ってるって・・・'
	DB	"%001:  Well, just before you said..."
	DB	NEXT
;	DB	'【恵依美】：とにかく！%001から離れて！'
	DB	"Meimi:  Just leave him alone!"
	DB	NEXT
;	DB	'【%001】：おととっ・・・'
	DB	"%001:  Oh boy...."
	DB	NEXT
	K_CG 'CT04','D',37,3
	DB ANI,A_ON,2
;	DB	'【祥子】：なに～？なになに～！？'
	DB	"Shoko:  What did you say to me?!"
	DB	PAUSE
;	DB	'あたしとしゅ～君の中をびりびりしちゃおうって言うのぉ～？'
	DB	" Are you trying to break"
	DB	CR
	DB	"us up or something?"
	DB	NEXT
;	DB	'【恵依美】：何訳わかんない事言ってるのよ！'
	DB	"Meimi:  I don't know what you're talking about!"
	DB	NEXT
	T_CG1 'CT07','F',0,22,4
	DB ANI,A_ON,3
	DB ANI,A_ON,2
;	DB	'【星愛】：・・・どうかしたのですか？恵依美ちゃん。'
	DB	"Seia:  What's wrong, Meimi?"
	DB	NEXT
;	DB	'【恵依美】：あ、星愛！聞いてよ、この人ったらね・・・'
	DB	"Meimi:  Oh, Seia! Listen to what that Shoko bitch just"
	DB	CR
	DB	"said..."
	DB	NEXT
	K_CG 'CT04','K',37,1
	DB ANI,A_ON,2
	DB ANI,A_ON,4
;	DB	'【祥子】：ふるふる。あたし悪い事してないも～ん。'
	DB	"Shoko:  I haven't done anything."
	DB	NEXT
;	DB	'【恵依美】：%001の邪魔してたでしょっ！？'
	DB	"Meimi:  You were bugging %001, weren't you?!"
	DB	NEXT
;	DB	'【%001】：今の内に、トンズラこいた方が良さそ～だな。'
	DB	"Suddenly, I had had enough."
	DB	NEXT
;	DB	'俺は最後の丸太を積み上げると、そそくさとその場を離れた。'
	DB	"I put the last log on and got the hell out of there."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	".............................................."
	DB	NEXT
;	DB	'【祥子】：・・・・・・そんな事無いよね～しゅ～君・・・・・・'
	DB	"Shoko:  That's not what happened! Is it, Shu-kun?"
	DB	PAUSE
;	DB	'あれ？'
	DB	" Huh?"
	DB	NEXT
;	DB	'【恵依美】：%001？'
	DB	"Meimi:  %001?"
	DB	NEXT
;	DB	'【星愛】：・・・どうやら、いないようですわね。'
	DB	"Seia:  Where did he go?"
	DB	NEXT
	K_CG 'CT04','D',37,3
	DB ANI,A_ON,2
	DB ANI,A_ON,4
;	DB	'【祥子】：・・・も～、あんた達のせいでしゅ～君いなくなっちゃったじゃないのぉ！みたいな～。'
	DB	"Shoko:  ......Well, it sure looks like you two managed to",CR,"scare him off!"
	DB	NEXT
;	DB	'【恵依美】：なぁあんですってぇぇぇっ！？'
	DB	"Meimi:  What did you say?"
	DB	NEXT
	K_CG 'CT07','V',22,5
	DB ANI,A_ON,3
	DB ANI,A_ON,2
;	DB	'【星愛】：恵依美ちゃん、落ち着いて・・・・・・'
	DB	"Seia:  Meimi, calm down...."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT05','F',0,20,6
;	DB	'【瑠璃】：・・・・・・・・'
	DB	"Ruri:  .................."
	DB	NEXT
;	DB	'【祥子】：ぎょぎょっ！？'
	DB	"Shoko:  Eh? Huh?"
	DB	NEXT
;	DB	'【恵依美】：・・・し、白水さん・・・'
	DB	"Meimi:  Uh, Ruri..."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......."
	DB	PAUSE
;	DB	'%001君、知らない？'
	DB	"Where's %001?"
	DB	NEXT
;	DB	'【星愛】：先程までは、ここにいたのですが・・・・・・'
	DB	"Seia:  He was here just a minute ago, but..."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ..............."
	DB	PAUSE
;	DB	'そう。'
	DB	"I see."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【祥子】：・・・・・・・・・'
	DB	"Shoko:  .............."
	DB	PAUSE
;	DB	'今の、いったい何？みたいな。'
	DB	"Who was she?"
	DB	NEXT
;	DB	'【恵依美】：・・・・・・さあ・・・・・・？'
	DB	"Meimi:  .....Nevermind."
	DB	NEXT
	DB	SINARIO,'CS514_E.OVL',0
	DW	0000H

end
