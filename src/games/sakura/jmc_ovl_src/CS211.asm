;くらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２１１
;		

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"話す",0
VV2:	DB	2,	"TALK ",0

;NN1:	DB	1,	"教室",0
NN1:	DB	1,	"CLASSROOM",0
;NN2:	DB	2,	"誠",0
NN2:	DB	2,	"MAKOTO",0
;NN3:	DB	3,	"鈴子",0
NN3:	DB	3,	"REIKO",0
;NN4:	DB	4,	"清美",0
NN4:	DB	4,	"KIYOMI",0
;NN5:	DB	5,	"美緒",0
NN5:	DB	5,	"MIO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　教室
S2:		DW	VV2, NN2,  2, M3		;話す　誠
S3:		DW	VV2, NN3,  3, M4, M5		;話す　鈴子
S4:		DW	VV2, NN4,  4, M6, M7		;話す　清美
S5:		DW	VV2, NN5,  5, M8, M9		;話す　美緒


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT "AB_36_2"
	DB	BUF,B_COPY01
	T_CG "CT01","W","I",0,1
;	DB	"保健室で目覚めた俺は、鈴子さんに付き添われて教室に戻って来た。"
	DB	"I woke up in the nurse's office. Reiko followed me all the"
	DB	CR
	DB	"way back to the classroom."
	DB	NEXT
;	DB	"【鈴子】：本当にごめんなさい・・・。"
	DB	"Reiko:  %001, I'm really sorry."
	DB	NEXT
;	DB	"【%001】：だからも～いいって。もう何ともねーからさ。"
	DB	"%001:  I said it was okay. It was just an accident."
	DB	NEXT
;	DB	"【鈴子】：でも・・・"
	DB	"Reiko:  But..."
	DB	NEXT
;	DB	"鈴子さんはしきりに、俺の口の辺りを見てる。"
	DB	"Reiko was staring at my mouth."
	DB	NEXT
;	DB	"【%001】：？　なんか付いてる？"
	DB	"%001:  Is there something on my face?"
	DB	NEXT
	K_CG "CT01","V",0,2
;	DB	"【鈴子】：ううん、なんでもないの・・・"
	DB	"Reiko:  Oh. It's nothing."
	DB	NEXT
;	DB	"鈴子さんは顔を赤らめている。"
	DB	"Reiko blushed bright red."
	DB	NEXT
;	DB	"（？？？）"
	DB	"???"
	DB	NEXT
;	DB	"（あ、ひょっとして、俺に人工呼吸してくれたとか？）"
	DB	"Could it be? Reiko gave me mouth-to-mouth?"
	DB	NEXT
;	DB	"（うわ・・・恥ずかしいな・・・）"
	DB	"Wow, how cool..."
	DB	NEXT
;	DB	"【鈴子】：とにかく、今回のことは私が悪かったわ。"
	DB	"Reiko:  Anyway, it was my fault that you almost died."
	DB	NEXT
;	DB	"【%001】：だからもういいって。"
	DB	"%001:  And I said it was okay."
	DB	NEXT
	K_CG "CT01","K",0,3
;	DB	"【鈴子】：お詫びに、私が%001君を泳げるようにしてあげる。"
	DB	"Reiko:  To make it up to you, I'll teach you how to swim."
	DB	NEXT
;	DB	"【%001】：へっ？"
	DB	"%001:  Huh?"
	DB	C_BLD,C_N_ON,2,3		;話す　清美　消す
	DB	C_BLD,C_N_ON,2,4		;話す　美緒　消す
	DB	C_BLD,C_V_ON,1		;見る　消す
	DB	C_BLD,C_N_ON,2,1		;話す　誠　消す
	DW	0000H

M2:		;見る　教室
;	DB	"誠たちがにやにやして俺の方を見ている。"
	DB	"Makoto and everyone was looking at me with strange smiles"
	DB	CR
	DB	"on their faces."
	DB	NEXT
;	DB	"【誠】：%001、モテモテだな。"
	DB	"Makoto:  %001, you are such a ladies' man."

	DB	NEXT
;	DB	"【%001】：ひ、人事だと思って・・・！"
	DB	"%001:  That's nobody's business!"
	DB	NEXT
;	DB	"【誠】：だって人事じゃん。"
	DB	"Makoto:  Just call me nobody."
	DW	0000H

M3:		;話す　誠
;	DB	"【%001】：誠、何とか言ってやってくれよ！"
	DB	"%001:  Makoto, say something to them for me!"
	DB	NEXT
;	DB	"【誠】：何とか。"
	DB	"Makoto:  Something."
	DB	NEXT
;	DB	"【%001】：ま～こ～と～・・・"
	DB	"%001:  Makoto!!"
	DB	NEXT
;	DB	"【誠】：悪いな%001、オレ痛い目にあいたくないんだ。"
	DB	"Makoto:  Sorry, %001. I don't want to get mixed up in this."
	DW	0000H

M4:		;話す　鈴子
;	DB	"【鈴子】：%001君は水泳部に入るのよ。だって、私の不戦勝だもの。"
	DB	"Reiko:  %001 is going to join the swim team. After all, he"
	DB	CR
	DB	"didn't beat me."
	DB	NEXT
;	DB	"【%001】：そ、そんな・・・"
	DB	"%001:  You can't...!"
	DB	NEXT
;	DB	"【清美】：そうは参りませんわ！"
	DB	"Kiyomi:  That's not fair!"
	DB	NEXT
;	DB	"【%001】：あ、新藤さん。"
	DB	"%001:  Kiyomi."
	DB	C_BLD,C_N_OFF,2,3		;話す　清美　出し
	T_CG "CT02","W",0,18,4
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す　鈴子
;	DB	"【鈴子】：不戦勝でも勝ちは勝ちよ。"
	DB	"Reiko:  If he doesn't beat me, I win. We had an agreement."
	DB	NEXT
;	DB	"【鈴子】：私がばっちり泳げるようにして上げる。"
	DB	"Reiko:  I'll make him into a fine swimmer."
	DB	NEXT
;	DB	"【%001】：そ、そんな・・・"
	DB	"%001:  I don't want to be a fine swimmer!"
	DW	0000H


M6:		;話す　清美
;	DB	"【清美】：%001さん、まだわたくしたち野球部の攻撃が終わっておりませんのよ。"
	DB	"Kiyomi:  %001, the baseball team's challenge is not over"
	DB	CR
	DB	"yet."
	DB	NEXT
;	DB	"【%001】：え？"
	DB	"%001:  What?"
	DB	NEXT
;	DB	"【清美】：ですから、%001さんは５６点取りましたから、わたくしたちが５７点以上取れば野球部の勝ち、という事になりますのよ。"
	DB	"Kiyomi:  You make 56 runs, %001. If the baseball team"
	DB	CR
	DB	"makes 57 runs against you, we win."
	DB	NEXT
;	DB	"【%001】：な～に～！？"
	DB	"%001:  What!?"
	DB	NEXT
	DB	BGM,22
;	DB	"【美緒】：%001先輩・・・"
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	"【%001】：・・・美緒ちゃん。"
	DB	"%001:  It's Mio."
	DB	C_BLD,C_N_OFF,2,4		;話す　美緒　出し
	T_CG "CT03","W",0,30,5
	DB	FLG,F_COPYI,4,1
	DB	C_BLD,C_V_OFF,1		;見る　出し
	DB	C_BLD,C_N_OFF,2,1		;話す　誠　出し
	DW	0000H

M7:		;話す　清美
;	DB	"【清美】：%001さん、これから野球部の攻撃ですわ。"
	DB	"Kiyomi:  %001, the baseball team is up now."
	DB	NEXT
;	DB	"【清美】：さあ、グラウンドに参りましょう。"
	DB	"Kiyomi:  Let's go to the field."
	DW	0000H


M8:		;話す　美緒
;	DB	"【%001】：君もまだ負けてないとか言うの？"
	DB	"%001:  Are you going to pretend that I didn't beat you, too?"
	DB	NEXT
;	DB	"【美緒】：ううん。あたしの完敗だった。"
	DB	"Mio:  No. You beat me."
	DB	NEXT
;	DB	"【美緒】：でも、先輩・・・テニス、楽しくなかった？"
	DB	"Mio:  But, %001, wasn't it fun?"
	DB	NEXT
;	DB	"【%001】：・・・"
	DB	"%001:  ......................"
	DB	NEXT
;	DB	"【%001】：そうだな・・・楽しかった。"
	DB	"%001:  Yes....it was."
	DB	NEXT
;	DB	"（・・・少なくとも今日の３本勝負の中じゃ、美緒ちゃんとのテニスが一番楽しかった。）"
	DB	"Of all the challenges today, Mio's tennis was the most fun."
	DB	NEXT
;	DB	"（確かに俺の圧勝だったけど・・・それは美緒ちゃんが俺に全力を出させたからだ。）"
	DB	"I won. But it was only because Mio made me give it my all."
	DB	NEXT
;	DB	"（よく考えたら俺に全力を出させた相手って、スゲー久しぶりなんじゃないか・・・？）"
	DB	"Come to think about it, it's been a real long time since"
	DB	CR
	DB	"anyone had me use all my strength."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M9:		;話す　美緒
	DB ANI,A_INIT
	DB	BUF,B_COPY01
	TU_CG "CT01","W","D",0,1
	TU_CG "CT03","W","D",30,2
	T_CG "CT02","W","D",18,3
	DB	ANI,A_ON,2
	DB	ANI,A_ON,1
;	DB	"【鈴子】：でも、勝ったのは私よ！"
	DB	"Reiko:  But I won!"
	DB	NEXT
;	DB	"【清美】：野球部との勝負は終わっていませんわ！"
	DB	"Kiyomi:  The baseball team's challenge is not over!"
	DB	NEXT
;	DB	"【美緒】：先輩はテニスが楽しいって言ってるよ！"
	DB	"Mio:  %001 said that tennis was fun!"
	DB	NEXT
;	DB	"【%001】：あ、あの・・・"
	DB	"%001:  Excuse me?"
	DB	NEXT
;	DB	"【鈴子・清美・美緒】：黙ってて！"
	DB	"All:  Be quiet, %001!"
	DB	NEXT
;	DB	"【%001】：はい！"
	DB	"%001:  Excuse me!"
	DB	NEXT
;	DB	"（・・・参ったなあ・・・）"
	DB	"Oh brother..."
	DB	NEXT
;	DB	"ちょんちょん"
	DB	"Poke, poke."
	DB	NEXT
;	DB	"【%001】：ん？"
	DB	"%001:  Hmm?"
	DB	NEXT
;	DB	"肩をつつかれて、俺は振り返った。"
	DB	"Somebody was poking me in the back, so I turned around."
	DB	NEXT
	DB	BUF,B_COPY10
	E_CG B_SUDA,"AB_36_2"
	T_CG "CT04","W",0,0,5		;祥子
;	DB	"【？】：%001君、今がチャンスよぉ！"
	DB	"???:  Now is your chance, %001!"
	DB	NEXT
;	DB	"【%001】：何が？"
	DB	"%001:  Who are you?"
	DB	NEXT
;	DB	"【？】：説明してる暇はないのぉ。早くこっち来てぇ～！"
	DB	"???:  No time to explain. Come with me!"
	DB	NEXT
;	DB	"【%001】：う・・・うん。"
	DB	"%001:  Uh, okay."
	DB	NEXT
;	DB	"（この子・・・誰？）"
	DB	"Who is this?"
	DB	NEXT
;	DB	"俺は彼女に促されるまま、３人を残して教室から抜け出した。"
	DB	"I follow the woman, leaving the other three behind."
	DB	NEXT
;	DB	"・・・・・・・・・・・・・・・"
	DB	"....................."
	DB	NEXT
	B_P1 B_SUDA
;	DB	"【鈴子】：そうでしょ、%001君！"
	DB	"Reiko:  Isn't that right, %001!"
	DB	PAUSE
;	DB	"・・・・・・%001君？"
	DB	"........%001?"
	DB	NEXT
;	DB	"【清美】：%001さん？"
	DB	"Kiyomi:  %001?"
	DB	NEXT
;	DB	"【美緒】：先輩？"
	DB	"Mio:  %001?"
	DB	NEXT
;	DB	"【清美】：誠さん、%001さんがどちらにいらっしゃったかご存じありませんか？"
	DB	"Kiyomi:  Makoto, do you know where %001 has gone off to?"
	DB	NEXT
;	DB	"【誠】：%001なら、３年の女子に連れてかれたよ。"
	DB	"Makoto:  Some senior woman took him off somewhere."
	DB	NEXT
;	DB	"【鈴子】：な・・・なんで黙ってるのよ！"
	DB	"Reiko:  Why didn't you say something?!"
	DB	NEXT
;	DB	"【誠】：聞かれなかったから。"
	DB	"Makoto:  You three were yelling so loud, you wouldn't"
	DB	CR
	DB	"have heard me anyway."
	DB	NEXT
;	DB	"【美緒】：嫌な予感がする・・・%001先輩を捜さなきゃ！"
	DB	"Mio:  I have a bad feeling about this. We better find him!"
	DB	NEXT
;	DB	"【清美】：ここは一時休戦して、協力して%001さんを捜すべきではないでしょうか？"
	DB	"Kiyomi:  So we call it a truce for now and cooperate to"
	DB	CR
	DB	"find %001?"
	DB	NEXT
;	DB	"【鈴子】：異議なし！行くわよ二人とも！"
	DB	"Reiko:  No objections here. Let's go you two!"
	DB	NEXT
	DB SINARIO,"CS212.OVL",0
	DW	0000H


end
;	さ