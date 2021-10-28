;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０４
;		

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
	DB	BGM,22
	BAK_INIT "AB_46"
	DB	BUF,B_COPY01
	TU_CG "CT03","W",0,10,1
	T_CG "CT01","W",0,35,2
	DB ANI,A_ON,1
;	DB	"聞き覚えのある声に振り返ると、入学式の日に危うくぶつかりそうになった、鈴子さんがいた。"
	DB	"I'd heard that voice before. I turned around to see Reiko,"
	DB	CR
	DB	"the woman I almost ran over on the first day of school."
	DB	NEXT
;	DB	"【鈴子】：久しぶりね%001君。学校には慣れた？"
	DB	"Reiko:  Long time no see, %001. Have you gotten used to"
	DB	CR
	DB	"the school yet?"
	DB	NEXT
;	DB	"【%001】：ま～ね。"
	DB	"%001:  I guess."
	DB	NEXT
;	DB	"【鈴子】：それで、どこのクラブに入るつもり？やっぱり体操部？"
	DB	"Reiko:  So what club have you decided to join? Gymnastics,"
	DB	CR
	DB	"I'll bet?"
	DB	NEXT
;	DB	"【%001】：特に考えてない。"
	DB	"%001:  I really haven't given it much thought."
	DB	NEXT
;	DB	"【美緒】：先輩・・・"
	DB	"Mio:  Well..."
	DB	NEXT
;	DB	"【鈴子】：だったら、水泳部なんかどう？"
	DB	"Reiko:  How about the swim team?"
	DB	NEXT
;	DB	"【%001】：すっ・・・すいえいぃ！？"
	DB	"%001:  The swim team?"
	DB	NEXT
;	DB	"【%001】：あっ、鈴子さんって、水泳部だったんだ。"
	DB	"%001:  So you're on the swim team."
	DB	NEXT
;	DB	"【美緒】：先輩ってば・・・。"
	DB	"Mio:  Excuse me?"
	DB	NEXT
;	DB	"美緒ちゃんが拗ねたような顔で俺の腕を引っ張った。"
	DB	"Mio looks angry as she pulls on my arm."
	DB	NEXT
;	DB	"【%001】：あっ、ごめん。"
	DB	"%001:  Ah, sorry."
	DB	NEXT
;	DB	"【鈴子】：？　誰、その子。中等部？"
	DB	"Reiko:  Who's this?"
	DB	NEXT
;	DB	"【%001】：うん、テニス部の・・・"
	DB	"%001:  She's in the tennis club..."
	DB	NEXT
;	DB	"【美緒】：鈴木　美緒。"
	DB	"Mio:  I'm Mio Suzuki."
	DB	NEXT
;	DB	"【美緒】：先輩、%001先輩はテニス部に入るの。"
	DB	"Mio:  %001 is going to join the tennis club."
	DB	NEXT
;	DB	"【鈴子】：%001君は「特に考えてない」って言ってるけど？"
	DB	"Reiko:  I think %001 said 'I really haven't given it much"
	DB	CR
	DB	"thought.'"
	DB	NEXT
;	DB	"鈴子さんと美緒ちゃんの間に、一瞬火花が散った、ような気がした。"
	DB	"It looked like fireworks were going off between those"
	DB	CR
	DB	"two for a moment."
	DB	NEXT
;	DB	"（な・・・なんでだ？）"
	DB	"What next?"
	DB	NEXT
;	DB	"「さ・・・捜しましたわ・・・」"
	DB	"%001:  Ah! There you are!"
	DB	NEXT
;	DB	"うろたえてる俺の背中に声をかけたのは、言わずと知れた新藤さんだった。"
	DB	"I didn't have to guess who's voice that was coming up"
	DB	CR
	DB	"behind me. It was Kiyomi Shinfuji."
	DB	NEXT
	DB SINARIO,"CS205.OVL",0
	DW	0000H


end
