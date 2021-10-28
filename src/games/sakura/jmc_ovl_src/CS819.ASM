;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１９
;		学園祭前夜　変わる世界

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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	NN4,-1

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
;NN4:	DB	4,	'自分',0
NN4:	DB	4,	'MYSELF',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　鈴子３
S2:		DW	VV1, NN2,  2, M5, M6, M7		;見る　清美３
S3:		DW	VV1, NN3,  3, M8, M9, M10		;見る　美緒３
S4:		DW	VV2, -1,  4, M11, M12, M13, M14, M15, M16, M17		;話す７
S5:		DW	VV3, NN4,  5, M18		;考える　自分


;イニシャルメッセージ
M1:
        DB	BGM,6
        BAK_INIT "AB_36_1"
        DB	BUF,B_COPY01
        TU_CG 'CT03','W',0,20,2
        TU_CG 'CT02','W',0,0,3
        T_CG 'CT01','W',0,12,4
        DB	ANI,A_ON,2
        DB	ANI,A_ON,3
        ;	DB	'【鈴子】：・・・あら？%001君？'
        DB	"Reiko:  %001?"
        DB	NEXT
        ;	DB	'【%001】：や。'
        DB	"%001:  Hey."
        DB	NEXT
        ;	DB	'俺が教室に入ると・・・ちょうど鈴子さん達が昼飯を食べていた。'
        DB	"I walked into the classroom to find everyone eating lunch."
        DW	0000H
        
M2:		;見る　鈴子１
        ;	DB	'・・・今まで気が付かなかったけど、確かにスゲー美人だ。'
        DB	"I never thought about it much before, but she's really"
        DB	CR
        DB	"beautiful."
        DB	NEXT
        ;	DB	'誠が媚売る気持ちが、ようやくわかった。'
        DB	"I can understand why Makoto fawns over her like he does."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　鈴子２
        ;	DB	'・・・こんな人が、俺の事好きだなんて・・・'
        DB	"..........And Reiko is in love with me?"
        DB	NEXT
        ;	DB	'【鈴子】：？　%001君、どうかした？'
        DB	"Reiko:  %001, what's wrong?"
        DB	NEXT
        ;	DB	'【%001】：あ！いやなんでもない。'
        DB	"%001:  Huh? Nothing...nevermind."
        DB	NEXT
        ;	DB	'【鈴子】：？？'
        DB	"Reiko:  ???"
        DB	FLG,F_COPYI,1,2
        DW	0000H
        
M4:		;見る　鈴子３
        ;	DB	'・・・あんまり見詰めないようにしよう。'
        DB	"I shouldn't stare at her."
        DW	0000H
        
M5:		;見る　清美１
        ;	DB	'・・・よくよく見ると、確かに美人だ。いわゆる眼鏡美人って奴だな。'
        DB	"If you look close, she's really a pretty woman. Kind of a"
        DB	CR
        DB	"sleeping beauty type..."
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M6:		;見る　清美２
        ;	DB	'思い出してみれば、勧誘合戦の時に「愛」がどうこう言い出したの、'
        ;	DB	'新藤さんだったよな。'
        DB	"Back during recruitment week, Kiyomi had been talking"
        DB	CR
        DB	"about love a lot."
        DB	NEXT
        ;	DB	'・・・それに１年も、俺を捜していた・・・'
        DB	"And she did spend a year looking for me..."
        DB	NEXT
        ;	DB	'【清美】：？　%001さん、どうかなさいましたか？'
        DB	"Kiyomi:  %001? Is there anything wrong?"
        DB	NEXT
        ;	DB	'【%001】：あ！いやなんでもない。'
        DB	"%001:  Oh, nothing."
        DB	NEXT
        ;	DB	'【清美】：？？'
        DB	"Kiyomi:  ???"
        DB	FLG,F_COPYI,2,2
        DW	0000H
        
M7:		;見る　清美３
        ;	DB	'・・・あんまり見詰めないようにしよう。'
        DB	"I shouldn't stare. It's rude."
        DW	0000H
        
M8:		;見る　美緒１
        ;	DB	'・・・改めて見ると、スゲー可愛い。'
        DB	"She's really cute, if you look at her in the right way."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M9:		;見る　美緒２
        ;	DB	'俺はこの娘に「兄貴」として慕われてると思っていた。'
        DB	"I thought I was like an older brother..."
        DB	NEXT
        ;	DB	'・・・だけど、違ったんだな・・・'
        DB	"But I was wrong."
        DB	NEXT
        ;	DB	'【美緒】：？　%001先輩、どうかした？'
        DB	"Mio:  %001, is anything wrong?"
        DB	NEXT
        ;	DB	'【%001】：あ！いやなんでもない。'
        DB	"%001:  No, nothing. Sorry..."
        DB	NEXT
        ;	DB	'【美緒】：？？'
        DB	"Mio:  ???"
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M10:		;見る　美緒３
        ;	DB	'・・・あんまり見詰めないようにしよう。'
        DB	"I shouldn't stare. It's rude."
        DW	0000H
        
M11:		;話す１
        ;	DB	'【清美】：・・・どうなされたのですか？今日はお休みのはずでは？'
        DB	"Kiyomi:  Why are you here? You don't have to help out today."
        DB	NEXT
        ;	DB	'【%001】：・・・ああ、なんかジッとしてられなくて。'
        DB	"%001:  Oh, I didn't want to stay at home by myself..."
        DB	PAUSE
        ;	DB	'なんか手伝える事、無い？'
        DB	" Is"
        DB	CR
        DB	"there anything I can do?"
        DB	FLG,F_COPYI,4,1
        DW	0000H
        
M12:		;話す２
        ;	DB	'【清美】：・・・そうですわね・・・'
        DB	"Kiyomi:  Well..."
        DB	NEXT
        ;	DB	'【恵依美】：・・・じゃあさ%001、テーブル配置してよ。'
        DB	"Meimi:  Will you help rearrange the tables?"
        DB	PAUSE
        ;	DB	'位置とかは、あたしが教えるからさ。'
        DB	" I'll tell you"
        DB	CR
        DB	"where everything should go."
        DB	NEXT
        ;	DB	'【星愛】：あら、それは恵依美ちゃんのお仕事でしょう？'
        DB	"Seia:  Isn't that your job, Meimi?"
        DB	NEXT
        ;	DB	'【恵依美】：・・・・・・い～じゃないのよ。あたしだってやるんだから・・・・・・'
        DB	"Meimi:  .........It's okay. I'll help too."
        DB	NEXT
        ;	DB	'【%001】：ははは・・・いいぜ、やるよ。'
        DB	"%001:  Okay, let's get started!"
        DB	NEXT
        ;	DB	'【恵依美】：ありがと！じゃ、配置図持ってくるわね！'
        DB	"Meimi:  Thanks! I'll get the diagram that shows where"
        DB	CR
        DB	"everything is supposed to go."
        DB	NEXT
        ;	DB	'【%001】：おう。'
        DB	"%001:  Okay."
        DB	FLG,F_COPYI,4,2
        DW	0000H
        
M13:		;話す３
        ;	DB	'【%001】：・・・そーいやぁ、誠の奴はどこ行った？'
        DB	"%001:  So where's Makoto?"
        DB	NEXT
        ;	DB	'【美緒】：誠先輩なら、サバ研の準備があるからって行っちゃったよ。'
        DB	"Mio:  He said he had to practice his survival activities"
        DB	CR
        DB	"and left."
        DB	NEXT
        ;	DB	'【%001】：・・・あ、そう。'
        DB	"%001:  Oh."
        DB	FLG,F_COPYI,4,3
        DW	0000H
        
M14:		;話す４
        ;	DB	'【%001】：鈴子さんのクラスは、何をやるの？'
        DB	"%001:  So what is your class going to do, Reiko?"
        DB	NEXT
        ;	DB	'【鈴子】：なんか演劇やるみたいよ、体育館で。'
        DB	"Reiko:  Some kind of play, put on in the gym."
        DB	NEXT
        ;	DB	'【%001】：へ～・・・鈴子さんは、何の役やるの？'
        DB	"%001:  That's interesting. What role are you playing?"
        DB	NEXT
        ;	DB	'【鈴子】：私は、小道具だから出ないわよ。'
        DB	"Reiko:  I'm just one of the set builders. I won't be in"
        DB	CR
        DB	"the play itself."
        DB	NEXT
        ;	DB	'【%001】：・・・そりゃ残念。お姫様とかやれば似合いそうなのに。'
        DB	"%001:  That's a shame. I wanted to see you play a princess"
        DB	CR
        DB	"or something."
        DB	NEXT
        ;	DB	'【鈴子】：・・・え・・・？'
        DB	"Reiko:  .......Huh?"
        DB	FLG,F_COPYI,4,4
        DW	0000H
        
M15:		;話す５
        ;	DB	'【%001】：美緒ちゃん達は、何をやるの？'
        DB	"%001:  What is your class going to do, Mio?"
        DB	NEXT
        ;	DB	'【美緒】：プール改造して釣堀。'
        DB	"Mio:  We're turning the pool into a fish pond."
        DB	NEXT
        ;	DB	'【%001】：ふ～ん・・・何がいるんだい？'
        DB	"%001:  Interesting. What are you doing, exactly?"
        DB	NEXT
        ;	DB	'【美緒】：うーん・・・あたし当番じゃないからわかんない。'
        DB	"Mio:  I'm not sure. I'm not the one organizing it."
        DB	NEXT
        ;	DB	'【%001】：・・・そか。ま、行ってみりゃ分かるか・・・'
        DB	"%001:  Oh. I'll go see it tomorrow."
        DB	PAUSE
        ;	DB	'美緒ちゃん、一緒に行くかい？'
        DB	" Want to go together?"
        DB	NEXT
        ;	DB	'【美緒】：いいの！？'
        DB	"Mio:  Really?"
        DB	NEXT
        ;	DB	'【%001】：ああ、もちろん。'
        DB	"%001:  Sure. It'll be fun."
        DB	FLG,F_COPYI,4,5
        DW	0000H
        
M16:		;話す６
        ;	DB	'【%001】：ところで新藤さん・・・我等が喫茶店はどうだい？'
        DB	"%001:  So, Kiyomi, how is our coffee shop coming along?"
        DB	NEXT
        ;	DB	'【清美】：・・・どう、とおっしゃいますと？'
        DB	"Kiyomi:  What do you mean, how is it coming along?"
        DB	NEXT
        ;	DB	'【%001】：繁盛しそうかな、って事。'
        DB	"%001:  Will a lot of people come by to have coffee?"
        DB	NEXT
        ;	DB	'【清美】：・・・そうですわね・・・'
        DB	"Kiyomi:  ....Yes, I think so."
        DB	NEXT
        ;	DB	'【恵依美】：繁盛するに決まってるでしょ！？あたしがウェイトレスやるのよ！'
        DB	"Meimi:  Of course they will!  I'm the waitress!"
        DB	NEXT
        ;	DB	'【%001】：・・・ははは・・・そうだな、新藤さんが企画して中野がウェイトレスやるんだ。繁盛するだろうな。'
        DB	"%001:  That's right. If Kiyomi organizes it and Meimi is"
        DB	CR
        DB	"the waitress, we'll make a lot of money."
        DB	NEXT
        ;	DB	'【清美】：・・・%001さん・・・？'
        DB	"Kiyomi:  ......%001?"
        DB	NEXT
        ;	DB	'【恵依美】：・・・%001？'
        DB	"Meimi......%001?"
        DB	FLG,F_COPYI,4,6
        DW	0000H
        
M17:		;話す７
        ;	DB	'【%001】：・・・でさ・・・'
        DB	"%001:  And then..."
        DB	NEXT
        ;	DB	'ぐきゅるるる～～～～～～っ'
        DB	"*grrrrrrowl*"
        DB	NEXT
        ;	DB	'【%001】：・・・あ。'
        DB	"%001:  Huh?"
        DB	PAUSE
        ;	DB	'そうだ、朝から何にも食ってないんだった。'
        DB	" Oh, I forgot to eat breakfast this morning."
        DB	NEXT
        ;	DB	'【鈴子】：・・・もう、そそっかしいわね。'
        DB	"Reiko:  You're disorganized, as usual."
        DB	NEXT
        ;	DB	'【美緒】：先輩・・・あたしのお弁当、半分あげよっか？'
        DB	"Kiyomi:  %001, do you want some of my lunch?"
        DB	NEXT
        ;	DB	'【%001】：・・・ああ、ありがとう美緒ちゃん。遠慮無く頂くよ。'
        DB	"%001:  Thanks, Mio. That'd be nice of you."
        DB	NEXT
        ;	DB	'【美緒】：・・・・・・？'
        DB	"Mio:  ........"
        DB	PAUSE
        ;	DB	'はい。'
        DB	"Um, okay."
        DB	NEXT
        ;	DB	'【%001】：・・・さんきゅ。いっただきま～す。'
        DB	"%001:  Thanks."
        DB	NEXT
        ;	DB	'【清美】：・・・・・・あの、%001さん。宜しかったら、わたくしのもいかがですか？'
        DB	"Kiyomi:  Um, %001, would you like half of mine, too?"
        DB	NEXT
        ;	DB	'【%001】：・・・ありがとう、新藤さん。'
        DB	"%001:  Thanks, Kiyomi."
        DB	PAUSE
        ;	DB	'そこ、置いといてくれる？'
        DB	" Would you put it over there?"
        DB	NEXT
        ;	DB	'【清美】：・・・はい、どうぞ。'
        DB	"Kiyomi:  Here you go."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・%001君、このパン食べない？'
        DB	"Reiko:  Would you like this bread, %001?"
        DB	NEXT
        ;	DB	'【%001】：ありがとう。頂くよ。'
        DB	"%001:  Thanks, if you don't mind."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・？'
        DB	"Reiko:  .....Um, okay."
        DB	NEXT
        ;	DB	'【恵依美】：・・・%001！そろそろ始めるわよ！'
        DB	"Meimi:  %001, let's move the tables now."
        DB	NEXT
        ;	DB	'【%001】：・・・悪ィ！ちょっと待っててくれ！'
        DB	"%001:  Sorry, can you wait a minute? I'm eating now."
        DB	NEXT
        ;	DB	'【恵依美】：・・・・・・も～、しょーが無いわねぇ。'
        DB	"Meimi:  .....You men!"
        DB	NEXT
        ;	DB	'【%001】：そう言うなって。喰い終わったら３人前働くからさ。'
        DB	"%001:  When I'm done eating, I'll do the work of three"
        DB	CR
        DB	"men. Just wait a few minutes."
        DB	NEXT
        ;	DB	'【恵依美】：・・・はいはい。'
        DB	"Meimi:  .....Okay."
        DB	NEXT
        B_O B_SUDA
        ;	DB	'・・・・・・・・・・・・・・・・'
        DB	"................................"
        DB	NEXT
        DB	BUF,B_COPY01
        DB	BUF,B_COPY01
        TU_CG 'CT03','W',0,20,2
        TU_CG 'CT02','W',0,0,3
        T_CG 'CT01','W',0,12,4
        DB	ANI,A_ON,2
        DB	ANI,A_ON,3
        ;	DB	'【恵依美】：・・・もう終わっちゃった・・・'
        DB	"Meimi:  We sure got that done in a hurry."
        DB	NEXT
        ;	DB	'【清美】：流石は%001さんですわ。'
        DB	"Kiyomi:  That's because %001 was doing all the work."
        DB	NEXT
        ;	DB	'【%001】：な～に、どって事ねぇって。'
        DB	"%001:  Who me? I didn't do anything."
        DB	PAUSE
        ;	DB	'じゃ、また明日な！'
        DB	" Well, see you all"
        DB	CR
        DB	"tomorrow!"
        DB	NEXT
        ;	DB	'【清美】：あ、はい。'
        DB	"Kiyomi:  Goodbye."
        DB	NEXT
        ;	DB	'【恵依美】：・・・う、うん。'
        DB	"Meimi:  See you tomorrow."
        DB	NEXT
        B_O B_SUDA
        ;	DB	'・・・・・・・・・'
        DB	"................."
        DB	NEXT
        ;	DB	'【恵依美】：・・・一体、ど～しちゃったのかしら%001？'
        DB	"Meimi:  What was up with %001?"
        DB	NEXT
        ;	DB	'【星愛】：・・・全ては、主の御心のままに・・・'
        DB	"Seia:  It's all the Lord's will..."
        DB	NEXT
        ;	DB	'【恵依美】：・・・星愛って、気楽でいいわよね。'
        DB	"Meimi:  That's what you always say, Seia."
        DB	NEXT
        DB	SINARIO,'CS820.OVL',0
        DW	0000H
        
M18:		;考える　自分
        ;	DB	'変わっている・・・'
        DB	"Something's different with me today..."
        DB	NEXT
        ;	DB	'確かに、俺の視点は変わっている。'
        DB	"I'm seeing everyone in a different way than ever before."
        DB	NEXT
        ;	DB	'今日子先生のおかげだ・・・感謝しなきゃ。'
        DB	"That's all because of Kyoko-sensei. I have to thank her"
        DB	CR
        DB	"later..."
        	DB	NEXT
        DW	0000H


end
