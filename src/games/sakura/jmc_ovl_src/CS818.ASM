;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１８
;		自室　人生の開眼

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5
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
CM2:	DW	VV2,	NN2,NN3,NN4,-1
CM3:	DW	VV3,	NN5,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0
;VV3:	DB	3,	'行く',0
VV3:	DB	3,	'GO',0

;NN1:	DB	1,	'時計',0
NN1:	DB	1,	'CLOCK',0 
;NN2:	DB	2,	'昨日の事',0
NN2:	DB	2,	'YESTERDAY',0
;NN3:	DB	3,	'体育祭',0
NN3:	DB	3,	'SPORTS FESTIVAL',0
;NN4:	DB	4,	'文化祭',0
NN4:	DB	4,	'CULTURE FESTIVAL',0
;NN5:	DB	5,	'学校',0
NN5:	DB	5,	'SCHOOL',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　時計２
S2:		DW	VV2, NN2,  2, M4, M5, M6		;考える　昨日の事３
S3:		DW	VV2, NN3,  3, M7, M8		;考える　体育祭２
S4:		DW	VV2, NN4,  4, M9, M10		;考える　文化祭２
S5:		DW	VV3, NN5,  5, M11		;行く　学校１


;イニシャルメッセージ
M1:
        DB	BGM,4
        BAK_INIT "AB_38_1"
        DB	BUF,B_COPY01
        ;	DB	'【%001】：・・・・・・うーん・・・・・・'
        	DB	"%001:  ....Mmmm."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・うーん・・・・・・'
        DB	"%001:  .............Mmmm."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・うーん・・・・・・'
        DB	"%001:  ..............Mmmmmmm."
        DB	PAUSE
        ;	DB	'せんせ～、もう勘弁してぇ・・・・・・'
        DB	" Sensei...no more, please."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・・・・・・・・'
        DB	"%001:  ........................."
        DB	NEXT
        ;	DB	'がばっ！！'
        DB	"Then I slowly opened my eyes to the morning."
        B_P1 B_SUDA
        DB	NEXT
        ;	DB	'【%001】：・・・・・・今、何時だ？'
        DB	"%001:  ...........Huh? What time is it?"
        DB	C_BLD,C_V_ON,3		;「行く　学校」　消す
        DW	0000H
        
M2:		;見る　時計１
        ;	DB	'【%001】：・・・１０時か。'
        DB	"%001:  Hmm, 10:00 am."
        DW	0000H
        
M3:		;見る　時計２
        ;	DB	'【%001】：・・・もう１２時前か。みんなもそろそろ昼飯食ってるな。'
        DB	"%001:  It's almost noon. Everyone must be almost ready"
        DB	CR
        DB	"to eat lunch."
        DW	0000H
        
M4:		;考える　昨日の事１
        ;	DB	'お日様が顔を出した辺りで何とか及第点を頂いた俺は、先生の車で送ってもらった。'
        DB	"By the time the sun came up, I was still trying to get a"
        DB	CR
        DB	"passing grade from Sensei. She drove me home."
        DB	NEXT
        ;	DB	'・・・・・・'
        DB	"....................."
        DB	NEXT
        ;	DB	'考えてみれば、最初からそ～してもらえば良かったんだよな。'
        DB	"Now that I think about it, I could have had her drive me"
        DB	CR
        DB	"home when she told me that the trains had already stopped"
        DB	CR
        DB	"for the night."
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M5:		;考える　昨日の事２
        ;	DB	'・・・・・・でも更に良く考えてみると、今日子先生は最初からあの話がしたくて俺を残したんだから・・・・・・うんて言うはずがないよな。'
        DB	"I'm sure that Sensei had planned the whole evening from"
        DB	CR
        DB	"the start."
        DB	NEXT
        ;	DB	'・・・・・・・・・'
        DB	"................................"
        DB	NEXT
        ;	DB	'車の中で、先生こんな事言ってたな。'
        DB	"In the car, she said something interesting to me."
        DB	NEXT
        ;	DB	'「私は、あなたに『女』を教えたわ。だけど忘れないで。'
        ;	DB	'これだけが、女の・・・人間の全てじゃないわ。相手に受け取る気持ちが'
        ;	DB	'あって、君が正しく伝えてこそ愛する事は気持ちよくなるわ。'
        ;	DB	'今教えた事は、ほんの一部なのよ・・・・・・」'
        DB	"Kyoko:  I wanted to teach you what a woman really was."
        DB	CR
        DB	"But there's something that you have to remember."
        DB	NEXT
        DB	"Kyoko:  There's a lot more to women than what you saw last"
        DB	CR
        DB	"night. What I taught you is just a small part of it all."
        DB	NEXT
        ;	DB	'・・・・・・・・・'
        DB	"................................."
        DB	NEXT
        ;	DB	'正直言って、今の俺には良く分からない。'
        DB	"To tell the truth, I'm not sure what she meant."
        DB	NEXT
        ;	DB	'だけど・・・・・・'
        DB	"However..."
        DB	PAUSE
        ;	DB	'何時か、分かりたい。'
        DB	"I really want to know."
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M6:		;考える　昨日の事３
        ;	DB	'・・・先生は、俺にすごく大事な事を教えてくれた。'
        DB	"Sensei taught me something very important last night."
        DB	NEXT
        DB	"Thank you, Kyoko-sensei."
        DW	0000H
        
M7:		;考える　体育祭１
        ;	DB	'・・・今思い返してみると、物凄く充実してたな。'
        DB	"Looking back, I'm really happy with how it all turned out."
        DB	NEXT
        ;	DB	'悔いがない訳じゃないけど・・・楽しかった。'
        DB	"I'm a little sorry our class didn't win first place..."
        DB	CR
        DB	"But it was still a lot of fun."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M8:		;考える　体育祭２
        ;	DB	'大嫌いだった体育祭だったけど・・・今は好きだ。'
        DB	"I used to hate the sports festival. But now I like it."
        DB	NEXT
        ;	DB	'・・・みんながいてくれるから・・・'
        DB	"I think it's because everyone was so nice to me..."
        DW	0000H
        
M9:		;考える　文化祭１
        ;	DB	'文化祭は、明日からだったな。'
        DB	"The culture festival starts tomorrow."
        DB	NEXT
        ;	DB	'今頃みんなは、準備で大忙しだな。'
        DB	"I'm sure everyone's busy setting up for it right now."
        DB	NEXT
        ;	DB	'俺は体育祭で優勝したから、準備はしなくていい事になっている。'
        DB	"Because I won the M.V.P. award at the sports festival, I"
        DB	CR
        DB	"don't have to help with the preparations."
        DB	FLG,F_COPYI,4,1
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M10:		;考える　文化祭２
        ;	DB	'・・・・・・だけど・・・・・・'
        DB	"Still..."
        DB	NEXT
        ;	DB	'俺が優勝出来たのは、みんなのお陰だ。俺一人の力じゃない。'
        DB	"I wouldn't have been able to win without everyone's support."
        DB	NEXT
        ;	DB	'・・・・・・'
        DB	"....................................."
        DB	NEXT
        ;	DB	'决めた。みんなのところに行こう。'
        DB	"I guess I'll go help out today, too."
        DB	C_BLD,C_V_OFF,3		;「行く　学校」　出す
        DW	0000H
        
M11:		;行く　学校１
        ;	DB	'【%001】：・・・よし！いくぜ！'
        DB	"%001:  Okay, let's go!"
        DB	NEXT
        ;	DB	'俺は超スピードで着替えると、学校目指して走り出した。'
        DB	"I changed my clothes and ran out the door, heading for the"
        DB	CR
        DB	"school."
        DB	NEXT
        ;	DB	'・・・・・・・・・'
        DB	"............................."
        B_O B_SUDA
        DB	NEXT
        ;	T_CG "CT10",0,0,0,1
        ;	DB	'【伸幸】：・・・今、%001が通り過ぎて行ったような気がしたんだが・・・'
        DB	"Nobuyuki:  I thought I just saw %001 go by..."
        DB	PAUSE
        ;	DB	'気のせいかな？'
        DB	" Could it have"
        DB	CR
        DB	"been my imagination?"
        DB	NEXT
        DB	SINARIO,'CS819.OVL',0
        DW	0000H


end
