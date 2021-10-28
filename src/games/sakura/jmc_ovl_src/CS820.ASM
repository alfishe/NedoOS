;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２０
;		学園祭当日

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
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'３人',0
NN1:	DB	1,	'THE GIRLS',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　３人
S2:		DW	VV2, -1,  2, M4, M5		;話す
S3:		DW	VV3, -1,  3, M6, M7		;考える


;イニシャルメッセージ
M1:
	DB	BGM,24
	BAK_INIT "AB_22"
;	DB	'学園祭・・・'
	DB	"The culture festival..."
	DB	NEXT
;	DB	'いや～、前ふりの体育祭で死ぬ思いをしただけに、なんだかしみじみと学園祭という言葉を噛み締めてしまった。'
	DB	"After nearly dying during the sports festival, this seems"
	DB	CR
	DB	"really tame by comparison."
	DB	NEXT
;	DB	'さあって、今日はゆっくりと・・・'
	DB	"Well, guess I'll take it easy today..."
	DB	NEXT
;	DB	'・・・・・・待てよ・・・俺、なんか忘れてねえか？'
	DB	"......Wait a minute. I get the feeling I'm forgetting"
	DB	CR
	DB	"something."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','W',0,20,2
	TU_CG 'CT02','W',0,0,3
	T_CG 'CT01','W',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【鈴子】：%001君～！'
	DB	"Reiko:  %001!"
	DB	NEXT
;	DB	'【清美】：%001さ～ん！'
	DB	"Kiyomi:  %001!"
	DB	NEXT
;	DB	'【美緒】：%001せんぱ～い！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【%001】：なんだぁ！？ど、ど～したの？'
	DB	"%001:  Hi, girls. Why were you waiting for me?"
	DB	NEXT
;	DB	'【鈴子】：どうしたのって・・・'
	DB	"Reiko:  Why?"
	DB	PAUSE
;	DB	'まさか、忘れてるんじゃないでしょうね？'
	DB	" You didn't forget, did you?"
	DB	NEXT
;	DB	'【%001】：・・・？俺、一緒に回る約束したっけ？'
	DB	"%001:  I promised to go around to all the classrooms with"
	DB	CR
	DB	"you? When did I do that?"
	DB	NEXT
;	DB	'【鈴子】：・・・本気で、言ってるわけ？'
	DB	"Reiko:  I knew you'd forget."
	DW	0000H

M2:		;見る　３人
;	DB	'・・・どうしたんだろ？'
	DB	"What's up with them today?"
	DW	0000H

M3:		;見る　３人
;	DB	'どうやら、俺のフォロー役をしてくれるらしい。'
	DB	"Oh well, I guess I'll go along with them."
	DW	0000H

M4:		;話す
;	DB	'【清美】：%001さん、あなたは体育祭の最優秀個人賞を受賞しましたわ。'
	DB	"Kiyomi:  %001, you won the M.V.P. award for the sports"
	DB	CR
	DB	"festival."
	DB	NEXT
;	DB	'【%001】：あ、ああ。'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【美緒】：だから、%001先輩は、今日予定されているいろんなイベントにゲストとして顔をださなきゃいけないんだって。'
	DB	"Mio:  So you're scheduled to go to different events"
	DB	CR
	DB	"today as a special guest."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............"
	DB	PAUSE
;	DB	'なにいいぃぃぃぃぃぃぃぃぃぃ！！？'
	DB	"...WHAT?"
	DB	NEXT
;	DB	'【%001】：き、聞いてねーぞ！？そんなの！'
	DB	"%001:  I never agreed to that!"
	DB	NEXT
;	DB	'【鈴子】：・・・体育祭の前からさんざん言ってたわよ？それに、体育祭の表彰式が終わった後の校長先生のお話でも言ってたし・・・'
	DB	"Reiko:  The dean said it at the awards ceremony. Weren't"
	DB	CR
	DB	"you listening?"
	DB	NEXT
;	DB	'【%001】：う、うそ？'
	DB	"%001:  You're kidding, right? I've got places I want to"
	DB	CR
	DB	"go today."
	DB	NEXT
;	DB	'【清美】：本当ですわよ。聞いていらっしゃらなかったのですか。'
	DB	"Kiyomi:  We're serious."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ........................"
	DB	NEXT
;	DB	'【美緒】：・・・で、でも、%001先輩、今日は私たちが先輩のマネージャーしてあげるから！'
	DB	"Mio:  But we'll set everything up for you, make sure the"
	DB	CR
	DB	"schedule's not too hard."
	DB	NEXT
;	DB	'【鈴子】：そうよ、さ、細かいことは気にしないで、いきましょう！'
	DB	"Reiko:  That's right. Leave it all to us, alright?"
	DB	NEXT
;	DB	'【清美】：そうですね、さ、参りましょう、%001さん。'
	DB	"Kiyomi: Yes. Well, shall we be going, %001?"
	DB	NEXT
;	DB	'【%001】：あ、あう・・・'
	DB	"%001:  Yeah, I guess..."
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,1
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す
;	DB	'【鈴子】：ね、清美ちゃん、最初のイベントってなんだっけ？'
	DB	"Reiko:  Kiyomi, what's the first event %001 is scheduled"
	DB	CR
	DB	"to appear in?"
	DB	NEXT
;	DB	'【清美】：えぇと（ごそごそ）、『学園祭恒例！体育祭優勝者＆学校長ごあいさつ代わりのトークショー！』・・・ですわ。'
	DB	"Kiyomi:  Let's see, It's a talk show starring him and the"
	DB	CR
	DB	"dean, put on by one of the other classes."
	DB	NEXT
;	DB	'【%001】：なっ、なんだよそれ！？'
	DB	"%001:  A talk show?"
	DB	NEXT
;	DB	'【鈴子】：・・・ウチの学校で、そんなことにいちいち驚いてたら、身体持たないわよ？%001君。'
	DB	"Reiko:  It's nothing unusual at this school, %001."
	DB	NEXT
	B_O B_SUDA
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"........................................"
;	DB	NEXT
;	DB	'・・・最優秀個人賞受賞者・・・このそこはかとなく舌を噛みそうな肩書きは・・・'
;	DB	"....The Most Valuable Player of the sports festival... "
;	DB	PAUSE
;	DB	'きっと、『君は晒し者だよ』という意味に違いない・・・'
;	DB	PAUSE
;	DB	'・・・・・・断言するぞ、俺は！！'
	DB	NEXT
	DB	SINARIO,'CS820_1.OVL',0
	DW	0000H

M6:		;考える
;	DB	'なんか、あったっけ？'
	DB	"Did anything happen?"
	DW	0000H

M7:		;考える
;	DB	'・・・体育祭で優秀な成績を収めると漏れなく学園祭で身動きがとれなくなるとは、なんて性悪な学校だ。'
	DB	"I feel I've been punished for doing well at the Sports Festival."
	DB	NEXT
;	DB	'しかし、可哀相なのは鈴子さん、新藤さん、美緒ちゃんの３人だ。'
	DB	"But I feel sorry for them, too."
	DW	0000H


end
