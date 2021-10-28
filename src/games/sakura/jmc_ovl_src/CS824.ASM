;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２４
;		学園祭２日目

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'清美',0
NN2:	DB	2,	'KIYOMI',0
;NN3:	DB	3,	'美緒',0
NN3:	DB	3,	'MIO',0
;NN4:	DB	4,	'バンド',0
NN4:	DB	4,	'BAND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子
S2:		DW	VV1, NN2,  2, M3		;見る　清美
S3:		DW	VV1, NN3,  3, M4		;見る　美緒
S4:		DW	VV1, NN4,  4, M5		;見る　バンド
S5:		DW	VV2, -1,  5, M6		;話す
S6:		DW	VV3, -1,  6, M7		;考える


;イニシャルメッセージ
M1:
	DB	BGM,24
	B_O B_SUDA
;	DB	'悪夢のようなイベント地獄が嘘だったかのようにさわやかな朝。'
	DB	"The next morning... "
	DB	NEXT
;	DB	'・・・だけど、俺は忘れない。'
	DB	"I wasn't sure if the stupid events I had been forced to"
	DB	CR
	DB	"particpate in the day before had been a nightmare or real."
	DB	NEXT
	BAK_INIT "AB_22"
;	DB	'・・・とまあ、そんなことを言っても、今日もしっかりと学園祭だったりするんだ、コレが。'
	DB	"The culture festival continues today."
	DB	NEXT
;	DB	'こんなに気分が違うのはどうしてだろう。'
	DB	"Despite how busy I've been, I'm enjoying it quite a bit."
	DB	NEXT
;	DB	'何より、あの３人が俺を気遣ってくれることが、何よりもうれしい。'
	DB	"I guess I like the attention Reiko, Kiyomi and Mio are"
	DB	CR
	DB	"giving me."
	DB	NEXT
;	DB	'おっと、そろそろ学校いかねえと、新藤さん達を待たせることになるぞ。'
	DB	"Oops, I'd better get off to school. Don't want to keep"
	DB	CR
	DB	"them waiting."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"........................................................"
	DB	NEXT
;	DB	'【%001】：よーっす。'
	DB	"%001:  Here I am."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','C',0,20,2
	TU_CG 'CT02','C',0,0,3
	T_CG 'CT01','C',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
	DB BUF,B_COPY10
;	DB	'【鈴子】：あ、きたわね。ちょっと遅刻よ？'
	DB	"Reiko:  You're late, %001."
	DB	NEXT
;	DB	'【清美】：あ、おはようございます、%001さん。'
	DB	"Kiyomi:  Good morning, %001."
	DB	NEXT
;	DB	'【美緒】：おはよーございまーす、%001先輩！'
	DB	"Mio:  Morning, %001!"
	DB	NEXT
;	DB	'【%001】：悪りィ悪りィ。ちょっと、起きるのがつらくって・・・'
	DB	"%001:  Sorry for being late. I overslept..."
	DB	NEXT
;	DB	'【清美】：%001さん、それでは参りましょうか？'
	DB	"Kiyomi:  Lets go, shall we?"
	DB	NEXT
;	DB	'【%001】：ああ。えと、最初はどこ行くの？'
	DB	"%001:  Sure. What's first?"
	DB	NEXT
;	DB	'【清美】：体育館でバンドの演奏がありますので、まずはそこに参りましょう。'
	DB	"Kiyomi:  There's a band playing in the gym. Shall we go"
	DB	CR
	DB	"see that?"
	DB	C_BLD,C_V_ON,2
;	DB	C_BLD,C_V_ON,1
;	DB	C_BLD,C_V_ON,2
;	DB	C_BLD,C_V_ON,3
;	DB	C_BLD,C_V_ON,5
	DW	0000H

M2:		;見る　鈴子
	
;	DB	'サラスヴァティの歌声に聞き惚れている。'
	DB	"She's listening to the band play."
	DB	NEXT
;	DB	'【鈴子】：・・・綺麗な声ね・・・'
	DB	"Reiko:  They have a good sound. I like them."
	DB	NEXT
;	DB	'【%001】：ああ、そーだね。俺もあのくらい歌えれば、昨日も恥かかんで済んだのになあ。'
	DB	"%001:  They're pretty good. I wish I could have sung"
	DB	CR
	DB	"this well yesterday."
	DB	NEXT
;	DB	'【鈴子】：あら、割と上手かったわよ？'
	DB	"Reiko:  You were fine."
	DB	NEXT
;	DB	'【%001】：あ、ありがと、鈴子さん。'
	DB	"%001:  Thanks..."
	EF_SET 101
	DW	0000H

M3:		;見る　清美
;	DB	'サラスヴァティの歌声をじっと聴いている。'
	DB	"She's listening to the music."
	DB	NEXT
;	DB	'【清美】：・・・お上手ですわね・・・'
	DB	"Kiyomi:  They're really good."
	DB	NEXT
;	DB	'【%001】：ああ・・・よっぽど練習したんだな、きっと。'
	DB	"%001:  I bet they practiced a lot for the culture festival."
	EF_SET 102
	DW	0000H

M4:		;見る　美緒
;	DB	'サラスヴァティの歌声に耳を傾けている。'
	DB	"She's listening to the music."
	DB	NEXT
;	DB	'【美緒】：上手だよね・・・'
	DB	"Mio:  They're not bad."
	DB	NEXT
;	DB	'【%001】：ああ・・・とても、同じ高校生とは思えんな。'
	DB	"%001:  Yes. It's hard to believe they're students like us."
	DB	NEXT
;	DB	'【美緒】：・・・どうすれば、あんなに上手に歌えるんだろう？'
	DB	"Mio:  I wonder how you get this good at something."
	DB	NEXT
;	DB	'【%001】：・・・やっぱ、歌いまくるしかないんじゃない？'
	DB	"%001:  Practice, I guess."
	EF_SET 103
	DW	0000H

M5:		;見る　バンド
	E_CG B_SUDA,"AB_22"
;	DB	'【%001】：・・・へえぇ、結構上手いねえ。'
	DB	"%001:  They're pretty good."
	DB	NEXT
;	DB	'【清美】：サラスヴァティと言うバンドですわ。女性ヴォーカルと言うことで、この名を選んだそうですわ。'
	DB	"Kiyomi:  They call themselves Melty Chocolate." 
	DB	NEXT
;	DB	'【%001】：へぇ・・・ところで、サラスヴァティってなんて意味？'
	DB	"%001:  Melty Chocolate, huh?"
	B_P1 B_SUDA
	DB	C_BLD,C_V_OFF,2
;	DB	C_BLD,C_V_OFF,1
;	DB	C_BLD,C_V_OFF,2
;	DB	C_BLD,C_V_OFF,3
	DW	0000H

M6:		;話す
;	DB	'【%001】：ああ、良いものを聴いた・・・'
	DB	"%001:  I like them."
	DB	NEXT
;	DB	'【清美】：さ、%001さん、次に参りましょう。'
	DB	"Kiyomi:  Well, let's go to the next place."
	DB	NEXT
;	DB	'【%001】：え？もう？'
	DB	"%001:  Already? I want to hear more."
	DB	NEXT
;	DB	'【清美】：はい。あ、入り口でサラスヴァティのデモテープを配ってましたよ。もらっていきますか？'
	DB	"Kiyomi:  They're selling demo tapes of this band by the"
	DB	CR
	DB	"door."
	DB	NEXT
;	DB	'【%001】：え？あ、もちろん！'
	DB	"%001:  Great!"
	DB	NEXT
;	DB	'【清美】：では、参りましょう。'
	DB	"Kiyomi:  Let's go."
	DB	NEXT
	DB	SINARIO,'CS824_1.OVL',0
	DW	0000H

M7:		;考える
;	DB	'う～ん、すごいなあ。ホントに、同じ高校生とは思えない。'
	DB	"I can't believe they're college students."
	DB	NEXT
;	DB	'・・・これをチェックしていてくれた新藤さんに、感謝しなきゃ。'
	DB	"I'm glad Kiyomi brought me to see them."
	DW	0000H

M_EXIT:	
	DB	FLG,F_COPYI,100,1
	DB	FLG,F_MAND,4,100,101,102,103
	DB	FLG,F_EXIT,100
	DB	NEXT
	DB	C_BLD,C_V_OFF,2
	DW	0000H


end
