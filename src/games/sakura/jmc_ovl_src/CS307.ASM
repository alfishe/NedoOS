
;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　３０７
;		死屍累々
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'今日子',0
NN1:	DB	1,	"KYOKO",0
;NN2:	DB	2,	'まわり',0
NN2:	DB	2,	"EVERYONE",0
;NN3:	DB	3,	'桜',0
NN3:	DB	3,	"SAKURA",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　今日子
S2:		DW	VV1, NN2,  2, M4		;見る　まわり
S3:		DW	VV1, NN3,  3, M5		;見る　桜
S4:		DW	VV2, NN1,  4, M6, M7		;話す　今日子


;イニシャルメッセージ
M1:
	DB	BGM,3
	B_O B_SUDA
	E_CG B_NORM,"AE_009"
;	DB	'俺は花見会場に帰って来た。'
	DB	"I'm back at the park."
	DB	NEXT
;	DB	'【%001】：あっら～・・・'
	DB	"%001:  Whoah......"
	DB	NEXT
;	DB	'・・・そこはまるで築地の魚市場みたいになっていた。'
	DB	".....It looked just like a fish market."
	DB	NEXT
;	DB	'その中で一人、今日子先生だけが平然と一升瓶を傾けていた。'
	DB	"In the middle of it all, our professor was still holding onto "

	DB	CR

	DB	"her bottle."
	DW	0000H

M2:		;見る　今日子
;	DB	'夜中からぶっ通しで飲んでるはずなのに、平然としている。'
	DB	"She's been drinking since last night, but she looks just fine."
	DB	NEXT
;	DB	'うわばみ・・・'
	DB	"Must have a liver of steel..."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　今日子
;	DB	'・・・しかし、いったい酒を何本用意してたんだ？この先生。'
	DB	"How many bottles of sake did she bring, anyway?"
	DW	0000H

M4:		;見る　まわり
;	DB	'今日子先生を除いて、見事に全滅している。'
	DB	"Everyone except for Kyoko-sensei was out cold. They must"
	DB	CR
	DB	"have drank like fish."
	DB	NEXT
;	DB	'・・・どーすんだ、これ・・・？'
	DB	"What does she intend to do about this?"
	DB	NEXT
;	DB	'ひょっとして、俺がみんなの家まで送ってくわけ？'
	DB	"I hope I don't have to take everyone home."
	DW	0000H

M5:		;見る　桜
;	DB	'すでに花見とは違うものになっている下界を見おろして、ただ静かに風に揺られている。'
	DB	"This party has gotten out of hand."
	DB	NEXT
;	DB	'・・・少なくとも、ウチのクラス（＋α）で生き残っている奴で、桜を見ているのはいない。'
	DB	"They've gone beyond enjoying the simple beauty of the falling"

	DB	CR

	DB	"sakura."
	DB	NEXT
;	DB	'・・・それ以前に、生き残ってるのは俺と今日子先生だけか・・・'
	DB	"Only the professor and I are even conscious."
	DW	0000H

M6:		;話す　今日子
;	DB	'【今日子】：おかえりぃ、おそかったわねぇ。'
	DB	"Kyoko:  Welcome back. You took long enough."
	DB	NEXT
;	DB	'【今日子】：星愛ちゃん、ちゃんと送ってあげた？'
	DB	"Kyoko:  Did you get Seia home alright?"
	DB	NEXT
;	DB	'【%001】：ちゃんと送っときました。'
	DB	"%001:  I got her home."
	DB	NEXT
;	DB	'【今日子】：星愛ちゃんに変な事してないでしょうねぇ～？'
	DB	"Kyoko:  You didn't do anything to her, did you?"
	DB	NEXT
;	DB	'【%001】：な・・・なんにもしてないです。'
	DB	"%001:  I.....I didn't do anything!"
	DB	NEXT
;	DB	'【今日子】：お？今なんか言いよどまなかった%001く～ん？'
	DB	"Kyoko:  Oh? Your voice seems to be a bit shaky, %001."
	DB	NEXT
;	DB	'【%001】：ホントになんにもしてねぇってば。'
	DB	"%001:  I really didn't do anything."
	DB	NEXT
;	DB	'【今日子】：どうかしらねぇ～？'
	DB	"Kyoko:  Hmmm....."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M7:		;話す　今日子
;	DB	'【今日子】：まあそれは二人の問題だからいいとして、とりあえず駆けつけ３杯よ。'
	DB	"Kyoko:  Anyway, that's something between the two of you."
	DB	CR
	DB	"Now for some power drinking!"
	DB	NEXT
;	DB	'【%001】：そうやってみんなを酔い潰したんですか？'
	DB	"%001:  Is that how you got everyone so drunk?"
	DB	NEXT
;	DB	'【今日子】：こーゆーのは若いウチから鍛えた方がい～の。成人の日にいきなり飲んでぽっくり逝くのはヤでしょ？'
	DB	"Kyoko:  You have to build up a tolerance now. It's the"
	DB	CR
	DB	"only way!"
	DB	NEXT
;	DB	'【%001】：今日ぽっくり逝くよりはその方がいいな。'
	DB	"%001:  That's better than loosing it today."
	DB	NEXT
;	DB	'【%001】：先生、みんなマグロになってるしお開きにしようよ。'
	DB	"%001:  Everyone is out cold. We might as well call it a"
	DB	CR
	DB	"day."
	DB	NEXT
;	DB	'【今日子】：ほら起きて恵依美ちゃん、%001君ったら星愛さんをねぇ・・・'
 	DB	"Kyoko:  Hey, wake up Meimi. Do you know what? %001 did"
 	DB	CR
 	DB	"something to Seia...!"
	DB	NEXT
;	DB	'【%001】：え～い、飲むから嘘吹き込むのはやめてください！'
 	DB	"%001:  Hey! Cut that out!"
	DB	NEXT
;	DB	'【今日子】：さあ、ぐぅ～っと空けて、ぐぅ～っと！'
	DB	"Kyoko:  Then you'd better drink this..."
	DB	NEXT
;	DB	'ごっくんごっくんごっくん・・・'
	DB	"I had no choice. I drained the bottle she handed me."
	DB	NEXT
;	DB	'【今日子】：ん、いい飲みッぷり！'
	DB	"Kyoko:  See, you can drink."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ............."
	DB	NEXT
	B_O B_NORM;ブラックアウト
;	DB	'ぱたっ'
;	DB	"(Bleah)"
;	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・'
	DB	"..............................................."
	DB	NEXT
;	DB	'【今日子】：%001君？'
 	DB	"Kyoko:  %001?"
	DB	NEXT
;	DB	'【今日子】：だめねぇ、宴会委員がそんな事じゃ。'
	DB	"Kyoko:  Hey, you're on the party committee. You have to"
	DB	CR
	DB	"set an example for the other students."
	DB	NEXT
;	DB	'【今日子】：すわぁ～て。車持って来るか。'
	DB	"Kyoko:  Okay, I'll bring my car around so we can take"
	DB	CR
	DB	"everyone home."
	DB	NEXT
	DB SINARIO,'CS308.OVL',0
	DW	0000H


end
