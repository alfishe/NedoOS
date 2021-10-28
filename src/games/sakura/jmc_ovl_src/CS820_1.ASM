;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２０＿１
;		イベントの嵐

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0
;VV3:	DB	3,	'釣り',0
VV3:	DB	3,	'TRY YOUR LUCK',0

;NN1:	DB	1,	'まわり',0
NN1:	DB	1,	'AROUND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　まわり
S2:		DW	VV2, -1,  2, M6, M7, M8		;考える
S3:		DW	VV3, -1,  3, M9, M10		;釣り


;イニシャルメッセージ
M1:
	DB	BGM,24
	BAK_INIT "AB_24"
;	DB	'【%001】：・・・はぁ～、俺、も～ヤだぞ、いい加減。'
	DB	"%001:  ........I want you to know, I hate being paraded"
	DB	CR
	DB	"around for everyone like this."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','W',0,20,2
	TU_CG 'CT02','W',0,0,3
	T_CG 'CT01','W',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【鈴子】：ぼやかない、ぼやかない。%001君はこの学校のヒーローなんだから。'
	DB	"Reiko:  There's nothing that can be done about it. You're a"
	DB	CR
	DB	"hero!"
	DB	NEXT
;	DB	'【%001】：・・・その割に、扱いひどくない？'
	DB	"%001:  ........If I'm a hero, then why am I being forced to"
	DB	CR
	DB	"go through with all of this?"
	DB	NEXT
;	DB	'【鈴子】：イベント数が多いから、どんどんひどくなってくわよ。ね、清美ちゃん、次はなあに？'
	DB	"Reiko:  What's the next event, Kiyomi?"
	DB	NEXT
;	DB	'【%001】：・・・ねぇ、逃げていい？'
	DB	"%001:  Do you guys mind if I run away ?"
	DB	NEXT
;	DB	'【清美】：いいえ、いけませんわ。'
	DB	"Kiyomi:  No! You have to stick to the schedule!"
	DB	NEXT
;	DB	'【清美】：・・・ところで、次は『学園祭恒例大イベント！君は勝てるか！？学校一の運動神経と釣り勝負！！』・・・ですわ。
	DB	"Kiyomi:  Next is a fishing contest where students challenge"
	DB	CR
	DB	"the number one athlete in the school...%001."
	DB	NEXT
;	DB	'【%001】：・・・な・・・なんてアホなネーミングなんだ・・・'
	DB	"%001:  Me? I don't want any part of that!"
	DB	PAUSE
;	DB	'第一、俺、あんまり釣りって得意じゃないぞ。'
	DB	" And what do I know"
	DB	CR
	DB	"about fishing, anyway?"
	DB	NEXT
;	DB	'【美緒】：大丈夫だよ！%001先輩なら。'
	DB	"Mio:  You'll be fine!"
	DB	NEXT
;	DB	'【鈴子】：さ、行きましょ、%001君。'
	DB	"Reiko:  Well, let's go, %001."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	DB	PAUSE
;	DB	'・・・・・・逃げたい・・・・・・'
	DB	"I want to run away!"
	DW	0000H

M2:		;見る　まわり
;	DB	'鈴子さん、新藤さん、美緒ちゃんが、俺のフォロー役をしてくれている。'
	DB	"Reiko, Kiyomi, and Mio are keeping an eye on me today."
	DB	NEXT
;	DB	'・・・きっと、自分たちが見たいものもあるはずなのに、俺のために・・・'
	DB	"I'm sure they'd rather be walking around the culture festival"
	DB	CR
	DB	"instead."
	DB	NEXT
;	DB	'今までの俺なら、きっと「俺のことはいいから」と言っているはずだ。'
	DB	"I'm sure that before, I would have said, 'Nevermind about"
	DB	CR
	DB	"what I want to see...' and just gone along with everyone."
	DB	NEXT
;	DB	'だけど今は、それが必ずしも相手を思いやることにはならない、と言うことを知っている。'
	DB	"But now I know that doing what others want isn't always the"
	DB	CR
	DB	"kindest thing for them, thanks to Kyoko-sensei."
	DB	NEXT
;	DB	'だから、申し訳ないと思いつつ、この３人に甘えさせてもらっている。'
	DB	"So I can't just do what these women tell me to do all the"
	DB	CR
	DB	"time."
	DB	NEXT
;	DB	'・・・こんな風に考えられるようになったのも、今日子先生のおかげだな。'
	DB	"I'm sure glad Kyoko-sensei set me straight."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　まわり
;	DB	'鈴子さん、新藤さん、美緒ちゃんが、俺のフォロー役をしてくれている。'
	DB	"Reiko, Kiyomi, and Mio are here."
	DB	NEXT
;	DB	'・・・すごく、ありがたい・・・'
	DB	"They're such nice people..."
	DW	0000H

M4:		;見る　まわり
;	DB	'・・・お、釣り上げた奴がいる・・・'
	DB	"Ah, someone caught a fish."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT13","F",0,15,4
;	DB	'【校長】：はっはっは、まだまだ若いモンには敗けんぞ、%001君！'
	DB	"Dean:  Ha ha ha! You young people can't beat a seasoned"
	DB	CR
	DB	"fisherman like me!"
	DB	NEXT
;	DB	'・・・校長先生だった・・・'
	DB	".......It was the dean."
	DB	NEXT
;	DB	'・・・・・・'
	DB	"............................."
	DB	NEXT
;	DB	'・・・あ、また・・・'
	DB	"............................."
	DB	NEXT
;	DB	'・・・なんか、イカサマしてるのと違うか？'
	DB	"I think I there's something fishing about all this."
	DB	FLG,F_COPYI,3,1
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;見る　まわり
;	DB	'あ、校長先生また釣ったぞ。'
	DB	"The dean managed to get a fish."
	DB	NEXT
;	DB	'・・・ひょっとして、校長先生は俺より遥かに「すごい」人なんじゃないか？'
	DB	".......I wonder if I can do this."
	DB	NEXT
;	DB	'【校長】：はっはっは、どうしたね、%001君。少しは本気を出したまえ。'
	DB	"Dean:  Ha ha ha, what's wrong, %001? A little worried?"
	DB	NEXT
;	DB	'【%001】：・・・俺がいくら本気だしても、魚はかかっちゃくれねえですよ。'
	DB	"%001:  Now matter how hard I try, if the fish won't bite,"
	DB	CR
	DB	"it's not going to do any good."
	DB	NEXT
;	DB	'・・・とか言ってる間に、また釣り上げてるし・・・'
	DB	"....Opps, he got another one."
	DW	0000H

M6:		;考える
;	DB	'誰だ？こんなイベント考えた奴は・・・'
	DB	"Who the hell thought up this event anyway?"
	DB	NEXT
;	DB	'・・・校長しかいねえか・・・'
	DB	"..............Maybe the dean himself."
	DW	0000H

M7:		;考える
;	DB	'ええい、逃げられた！'
	DB	"I want to run away...!"
;	DB	NEXT
;	DB	'・・・はっ、いかん、ハマッてる？'
;	DB	"This isn't good..."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M8:		;考える
;	DB	'これはこれで・・・結構・・・'
	DB	"Guess there's nothing I can do about it."
	DW	0000H

M9:		;釣り
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ................"
	DB	NEXT
;	DB	'【美緒】：先輩、どう・・・？'
	DB	"Mio:  Are you having any luck, %001?"
	DB	NEXT
;	DB	'【%001】：・・・こんなに澄んだ水だよ？泳いでる魚にもこっちが見えるんだ、そうそう釣れないと思うけどな。'
	DB	"%001:  I can see fish swimming around in there, but they're"
	DB	CR
	DB	"not biting."
	DB	NEXT
;	DB	'【美緒】：でも、向こうでたくさん釣ってるよ・・・？'
	DB	"Mio:  But the dean is catching a lot."
	DB	NEXT
;	DB	'【%001】：え・・・？あ、ホントだ。'
	DB	"%001:  You're right."
	DB	FLG,F_COPYI,1,2
	DB	FLG,F_COPYI,2,1
;	DB	FLG,F_COPYI,3,1
	DW	0000H

M10:		;釣り
;	DB	'お、かかった！'
	DB	"Ah, I got one!"
	DB	NEXT
;	DB	'【%001】：ほうりゃあぁ！'
	DB	"%001:  Come on, fish!"
	DB	NEXT
;	DB	'【美緒】：わぁ、%001先輩、すごいすごーい！'
	DB	"Mio:  Oh %001, that's great!"
	DB	NEXT
;	DB	'【%001】：へへ・・・釣れたろ？'
	DB	"%001:  ......I got one, didn't I? I told you I could do it."
	DB	NEXT
;	DB	'【鈴子】：へぇ、結構やるわね・・・'
	DB	"Reiko:  That's great."
	DB	NEXT
;	DB	'【清美】：お上手ですわ！%001さん！'
	DB	"Kiyomi:  You're wonderful, %001!"
	DB	NEXT
;	DB	'【%001】：うんうん、大体コツは掴んだぞ。以外と簡単なモンだったんだな。'
	DB	"%001:  I think I've got the hang of this now. I should be"
	DB	CR
	DB	"able to beat the dean now."
	DB	NEXT
;	DB	'【校長】：わはははは、それでこそ私の好敵手と言うものだ！'
	DB	"Dean:  Ha ha ha! You think you can beat me with just"
	DB	CR
	DB	"one fish?"
	DB	NEXT
;	DB	'【%001】：・・・誰がいつ校長先生のライバルになったんです？'
	DB	"%001:  We're not rivals, sir."
	DB	NEXT
;	DB	'【校長】：わはははは、さあ、勝負はこれからだ！'
	DB	"Dean:  Yes we are! Let's see what you can do!"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..................."
	DB	NEXT
	B_O B_SUDA
;	DB	'・・・・・・・・・'
	DB	"...................................................."
	DB	NEXT
;	DB	'その後、俺は怒涛の追い上げを見せたが、結局優勝は校長先生だった。'
	DB	"I did the best I could, but in the end, the dean won"
	DB	CR
	DB	"the contest."
	DB	NEXT
;	DB	'１時間、という時間制限がなければ・・・やっぱり校長先生だったんだろうな。'
	DB	"At the end of the hour time limit, he had the most fish."
	DB	NEXT
;	DB	'しかし、時間は俺に勝負の余韻に浸るヒマを与えてはくれなかった。'
	DB	"But after the event, I was able to relax a little."
	DB	NEXT
;	DB	'【清美】：さ、次のイベントへ参りましょう！'
	DB	"Kiyomi:  Okay, let's get moving for the next event."
	DB	NEXT
;	DB	'【%001】：・・・も、どうにでもして・・・'
	DB	"%001:  ......I don't want to go..."
	DB	NEXT
;	DB	'【美緒】：そんな、投げやりな・・・'
	DB	"Kiyomi:  There's nothing you can do about that, I'm afraid..."
	DB	NEXT
	DB	SINARIO,'CS820_2.OVL',0
	DW	0000H


end
