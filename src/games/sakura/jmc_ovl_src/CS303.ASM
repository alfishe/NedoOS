;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　３０３
;		修司の過去
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
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'まわり',0
NN1:	DB	1,	"AROUND",0
;NN2:	DB	2,	'誠',0
NN2:	DB	2,	"MAKOTO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　まわり
S2:		DW	VV1, NN2,  2, M3		;見る　誠
S3:		DW	VV2, -1,  3, M4, M5		;話す


;イニシャルメッセージ
M1:
	DB	BGM,32
	BAK_INIT "AB_07_2"
	DB	BUF,B_COPY01
	T_CG "CT12","C",0,26,1
;	DB	'【今日子】：ところで%001君。'
	DB	"Kyoko:  Say, %001..."
	DB	NEXT
;	DB	'【%001】：はい？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【今日子】：結局どこのクラブにも入らなかったのね。'
	DB	"Kyoko:  You didn't join any of the clubs, did you?"
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ....................."
	DB	NEXT
;	DB	'【今日子】：どうして？'
	DB	"Kyoko:  Why not?"
	DW	0000H

M2:		;見る　まわり
	DB	BUF,B_COPY01
	TU_CG "CT01","C",0,35,2
	TU_CG "CT03","C",0,10,4
	T_CG "CT02","C",0,0,3
	DB	ANI,A_ON,4
	DB	ANI,A_ON,2
;	DB	'鈴子さん、新藤さん、美緒ちゃん・・・みんなが静かに俺の方を見つめている。'
	DB	"Reiko, Kiyomi, and Mio are all looking at me in silence."
	DW	0000H

M3:		;見る　誠
;	DB	'誠は相変らず酔いつぶれて寝ている。'
	DB	"Makoto is passed out drunk."
	DB	NEXT
;	DB	'・・・もしかしたら、寝てるふりをして聞き耳立ててるのかも知れない。'
	DB	"Of course he might just be pretending to sleep so he can"
	DB	CR
	DB	"eavesdrop."
	DW	0000H

M4:		;話す
;	DB	'【%001】：・・・つまんないから。'
	DB	"%001:  ......I'm just not interested in any of them."
	DB	NEXT
;	DB	'【今日子】：何でも出来るから？'
	DB	"Kyoko:  That's because you're so good at sports. They"
	DB	CR
	DB	"aren't challenging."
	DB	NEXT
;	DB	'【%001】：そんなとこだな。'
	DB	"%001:  It's not that."
	DB	NEXT
;	DB	'【%001】：・・・俺、生まれてこのかた努力なんかしたことねえんだ。'
	DB	"%001:  I..... I haven't tried hard for anything for a long"
	DB	CR
	DB	"time now."
	DB	NEXT
;	DB	'【%001】：なのに、何をやってもそこそこ出来ちまう。',CR,'ラケット握って二日目で、美緒ちゃんにだって勝てた。'
	DB	"%001:  I do seem to do well at whatever I do, though. I"
	DB	CR
	DB	"mean, I even beat Mio on my second day holding a racket."
	DB	NEXT
;	DB	'【%001】：昔は好き放題やってたさ。球技大会とか運動会とかじゃ、クラスのヒーローだったよ。'
	DB	"%001:  Before, to show off my skills. I wanted to be the"
	DB	CR
	DB	"class hero in everything."
	DB	NEXT
;	DB	'【%001】：でも、ある日気付いちまったのさ。自分がクラスから孤立してることに。'
	DB	"%001:  Then one day I realized that I was isolated from"
	DB	CR
	DB	"the rest of the class by doing things like that. I was an"
	DB	CR
	DB	"outsider."
	DB	NEXT
;	DB	'【%001】：そりゃそーだよな。必死になって練習してるみんなより、ぶっつけ本番の俺の方が何でも上手く出来たんだ。'
	DB	"%001:  Everyone else practiced hard to get good at"
	DB	CR
	DB	"whatever sport they were into. But for me, it just seemed"
	DB	CR
	DB	"to come naturally."
	DB	NEXT
;	DB	'【%001】：みんな俺を応援してくれるけど、どこか冷めてるんだよ。'
	DB	"%001:  They all cheered for me when it was my turn to"
	DB	CR
	DB	"play. But there was something cold about it all."
	DB	NEXT
;	DB	'【%001】：それがわかったら、もう学校には行けなくなった。親父に頼み込んで転校させてもらったんだ。'
	DB	"%001:  After that, I just couldn't go to school anymore."
	DB	CR
	DB	"I got my Dad to transfer me to a different school."
	DB	NEXT
;	DB	'【%001】：その後・・・決めたんだ。俺よりすごいやつが現れるまで、何もしないって。'
	DB	"%001:  It was then that I decided...until I meet someone"
	DB	CR
	DB	"better than me, a realy incredible person, I wouldn't get "

	DB	CR

	DB	"into any sports."
	DB	NEXT
;	DB	'・・・誰も何も言わなかった。みんな、驚いたような、気遣うような目で俺を見つめてた。'
	DB	"There was complete silence from everyone."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す
;	DB	'【%001】：・・・なーんちゃって、ホントはただメンドくさいだけ。'
	DB	"%001:  I...I'm just kidding! The real reason I didn't want"
	DB	CR
	DB	"to join a club is, I don't like sports..."
	DB	NEXT
;	DB	'【今日子】：ぶっ！'
	DB	"Kyoko:  Haha...!"
	DB	NEXT
	B_P1 B_TATE
;	DB	'あまりのオチに緊張の糸がぷっつり切れて、みんなはビニールシートにがっくりと突っ伏した。'
	DB	"That lifted the air of tension."
	DB	NEXT
;	DB	'【%001】：ノリやすいな、みんな。'
	DB	"%001:  You mean, you actually believed my first story?"
	DB	NEXT
;	DB	'【鈴子】：ノリやすいのはどっちよ！'
	DB	"Reiko:  Who's the gullible one?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT14","C","I",15,5
;	DB	'【誠】：%001～・・・！'
	DB	"Makoto:  %001...!!"
	DB	NEXT
;	DB	'【%001】：おわっ！'
	DB	"%001:  ?!"
	DB	NEXT
;	DB	'ゾンビのよーに甦った誠が、俺にコブラツイストをかける。'
	DB	"Makoto, resurrected like a zombie, got me in another headlock."
	DB	NEXT
;	DB	'【誠】：俺達親友じゃなかったのか？自分だけうまいもの食べやがってぇ！'
	DB	"Makoto:  I thought we were best friends. Why didn't you"
	DB	CR
	DB	"wake me up when the food got here?"
	DB	NEXT
;	DB	'【%001】：あわわ、ギブ！ギブ！'
	DB	"%001:  Get off me!!"
	DB	NEXT
;	DB	'【誠】：食い物の恨みの恐ろしさ、思い知れぇ！'
	DB	"Makoto:  I'll get you back...someday...!"
	DB	NEXT
;	DB	'【%001】：あだだだだ！'
	DB	"%001:  Aaaaah!"
	DB	NEXT
;	DB	'・・・こうして花見前夜の夜は騒がしく更けていった。'
	DB	"And that's more or less how our night of sakura viewing"
	DB	CR
	DB	"ended..."
	DB	NEXT
	B_O B_FADE
	DB SINARIO,'CS304.OVL',0
	DW	0000H


end
