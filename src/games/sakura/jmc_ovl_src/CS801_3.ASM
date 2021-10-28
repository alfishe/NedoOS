;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０１＿３
;		体育祭前　練習の日々２

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7, S8
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
CM2:	DW	VV2,	NN1,NN2,NN3,NN4,-1
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
;NN4:	DB	4,	'減らさない訳',0
NN4:	DB	4,	'MY REASON',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子
S2:		DW	VV1, NN2,  2, M4		;見る　清美
S3:		DW	VV1, NN3,  3, M5, M6		;見る　美緒
S4:		DW	VV2, NN1,  4, M7, M8		;話す　鈴子２
S5:		DW	VV2, NN2,  5, M9, M10, M11, M12		;話す　清美４
S6:		DW	VV2, NN3,  6, M13		;話す　美緒１
S7:		DW	VV2, NN4,  7, M14		;話す　減らさない訳１
S8:		DW	VV3, -1,  8, M15		;考える


;イニシャルメッセージ
M1:
        DB	BGM,6
        ;	DB	'・・・翌日。'
        DB	"The next day..."
        DB	NEXT
        BAK_INIT "AB_36_3"
        B_P1 B_SUDA
        ;	DB	'【%001】：・・・う～っす。'
        DB	"%001:  .....Good morning."
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT14","W",0,0,4
        ;	DB	'【誠】：おう、%001。'
        DB	"Makoto:  Hey, %001."
        DB	NEXT
        ;	DB	'【%001】：よ、まこ・・・'
        DB	"%001:  Hey, Mako--"
        DB	PAUSE
        ;	DB	'ふぁ～～～～～～ぁ。'
        DB	" OH! That hurts!"
        DB	NEXT
        ;	DB	'【誠】：・・・何だおい、朝っぱらから。'
        DB	"Makoto:  What's the matter with you?"
        DB	NEXT
        ;	DB	'【%001】：いやぁ、久し振りに身体動かしたからよ・・・'
        DB	"%001:  Oh, my body hurts a little, from all that exer--"
        DB	PAUSE,CR
        ;	DB	'ふぁあぁぁぁ・・・っ・・・'
        DB	"OUCH OUCH OUCH!!"
        DB	NEXT
        T_CG1 "CT02","W",0,33,2
        DB ANI,A_ON,4
        ;	DB	'【清美】：%001さん、おはようございます。'
        DB	"Kiyomi:  %001, good morning."
        DB	NEXT
        ;	DB	'【%001】：よ、新藤さん。'
        DB	"%001:  Good morning, Kiyomi."
        DB	PAUSE
        ;	DB	'・・・ふぁ～～～～～～ぁ。'
        DB	" OUCH OUCH OUCH!!"
        DB	NEXT
        ;	DB	'【清美】：・・・・・・'
        DB	"Kiyomi:  ......"
        DB	PAUSE
        K_CG 'CT02','I',33,2
        DB ANI,A_ON,4
        ;	DB	'大丈夫ですか？お疲れのようですけど・・・'
        DB	"Are you alright? You look tired..."
        DB	NEXT
        ;	DB	'【%001】：・・・ああ、ちょっとな。'
        DB	"%001:  ...I am, a little."
        DB	NEXT
        ;	DB	'【清美】：%001さん・・・'
        DB	"Kiyomi:  %001..."
        DB	NEXT
        ;	DB	'【%001】：な～に。こんな疲れ、ちょっと寝ればすぐ取れるって。'
        DB	"%001:  What is it? Don't worry, a good night's sleep will"
        DB	CR
        DB	"fix me."
        DB	NEXT
        ;	DB	'【清美】：ですが・・・'
        DB	"Kiyomi:  Yes, but..."
        DB	NEXT
        ;	DB	'きーんこーんかーんこーん'
        DB	"*DING DONG DING DONG*"
        DB	NEXT
        ;	DB	'【%001】：お、チャイムだ。'
        DB	"%001:  Ah, it's time to go."
        DB	NEXT
        ;	DB	'【清美】：・・・・・・・・・'
        DB	"Kiyomi:  ........................."
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'・・・昼休み。'
        DB	".......Lunchtime."
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT02","W",'I',0,2
        ;	DB	'【清美】：・・・%001さん。お話があります。'
        DB	"Kiyomi:  %001, there's something we'd like to talk to you"
        DB	CR
        DB	"about."
        DB	C_BLD,C_N_ON,1,1		;「見る　鈴子」　消す
        DB	C_BLD,C_N_ON,1,3		;「見る　美緒」　消す
        DB	C_BLD,C_N_ON,2,1		;「話す　鈴子」　消す
        DB	C_BLD,C_N_ON,2,3		;「話す　美緒」　消す
        DB	C_BLD,C_N_ON,2,4		;「話す　減らさない訳」　消す
        DW	0000H

M2:		;見る　鈴子
        ;	DB	'昼食時間に来るのはいつものことだ。'
        DB	"She always comes around during lunchtime."
        DB	FLG,F_COPYI,1,1
        DW	0000H

M3:		;見る　鈴子
        ;	DB	'なんだか心配そうに俺を見ている。'
        DB	"She looks worried about me."
        DB	NEXT
        ;	DB	'・・・俺、なんかしたか？'
        DB	".....Do I look that bad?"
        DW	0000H

M4:		;見る　清美
        ;	DB	'なんだか様子が・・・いつもと違う。'
        DB	"She seems different somehow."
        DB	NEXT
        ;	DB	'俺、なんかしたかな？'
        DB	".....Do I look that bad?"
        DW	0000H

M5:		;見る　美緒
        ;	DB	'いつも昼飯時には元気一杯でやってくる。'
        DB	"She's always happy when she comes around during"
        DB	CR
        DB	"lunchtime."
        DB	FLG,F_COPYI,3,1
        DW	0000H

M6:		;見る　美緒
        ;	DB	'ちょっと元気がなくなったみたいだ。'
        DB	"She doesn't seem very energetic today."
        DB	NEXT
        ;	DB	'俺のせいかな・・・？'
        DB	"Is that because of me?"
        DW	0000H

M7:		;話す　鈴子１
        K_CG 'CT01','V',35,8
        DB ANI,A_ON,6
        DB ANI,A_ON,5
        ;	DB	'【鈴子】：・・・ごっめ～ん！'
        DB	"Reiko:  ...I'm sorry!"
        DB	NEXT
        ;	DB	'【%001】：・・・いや・・・別にいいんだけど。'
        DB	"%001:  ...No, it's nothing."
        DB	FLG,F_COPYI,4,1
        DW	0000H

M8:		;話す　鈴子２
        T_CG "CT01","W",0,35,7
        DB	ANI,A_ON,6
        DB	ANI,A_ON,5
        ;	DB	'【鈴子】：・・・それで？何の話してたの？'
        DB	"Reiko:  What were you two talking about?"
        DB	NEXT
        ;	DB	'【清美】：実は・・・かくかくしかじか。'
        DB	"Kiyomi:  ..... (explain explain)"
        DB	NEXT
        ;	DB	'【鈴子】：・・・なるほどね。'
        DB	"Reiko:  ...I see."
        DB	PAUSE
        ;	DB	'で？%001君は何て言おうとしてたの？'
        DB	" And what did %001 say about this?"
        DB	NEXT
        ;	DB	'【%001】：・・・えっと・・・'
        DB	"%001:  ...Um, excuse me..."
        DB	C_BLD,C_N_ON,2,1		;「話す　鈴子」　消す
        DB	C_BLD,C_N_ON,2,3		;「話す　美緒」　消す
        DB	C_BLD,C_N_OFF,2,4		;「話す　減らさない訳」　出す
        DW	0000H
        
M9:		;話す　清美１
        ;	DB	'【%001】：・・・どったの新藤さん？いきなり改まって・・・'
        DB	"%001:  What's wrong, Kiyomi?"
        DB	NEXT
        ;	DB	'【清美】：%001さん・・・単刀直入に申し上げます。'
        DB	"Kiyomi:  %001, I'm going to blunt."
        DB	PAUSE
        ;	DB	'もう少し、参加種目を減らされるべきですわ。'
        DB	" I really think you should"
        DB	CR
        DB	"reconsider participating in so many events."
        DB	FLG,F_COPYI,5,1
        DW	0000H

M10:		;話す　清美２
        ;	DB	'【%001】：・・・なんで？'
        DB	"%001:  Why?"
        DB	NEXT
        ;	DB	'【清美】：%001さんのスケジュールを作っていた時にも気にはなっていたのですが、昨日の練習を見てはっきりとわかりました。'
        DB	"Kiyomi:  Seeing how hard you were practicing yesterday"
        DB	CR
        DB	"convinced me."
        DB	NEXT
        ;	DB	'【清美】：いくら%001さんでも、あれでは身体を壊してしまいます。'
        DB	"Kiyomi:  You're going to seriously hurt yourself if"
        DB	CR
        DB	"you try to do all those events."
        DB	NEXT
        ;	DB	'【%001】：・・・そ～か～？'
        DB	"%001:  You think so?"
        DB	NEXT
        ;	DB	'【清美】：はい。'
        DB	"Kiyomi:  Yes, I do."
        DB	FLG,F_COPYI,5,2
        DW	0000H

M11:		;話す　清美３
        ;	DB	'【%001】：・・・・・・でもなぁ、もう参加するって言っちゃってるしなあ・・・・・・'
        DB	"%001:  ...But I already said I'd do it."
        DB	NEXT
        ;	DB	'【清美】：それでしたら、御心配には及びませんわ。'
        DB	"Kiyomi:  You don't need to worry about that."
        DB	PAUSE
        ;	DB	'今からでしたら、届け出れば変更が効きますから。'
        DB	" It's not too late"
        DB	CR
        DB	"to change the roster."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ..............."
        DB	NEXT
        ;	DB	'【%001】：いや、そーゆー事じゃね～んだ。'
        DB	"%001:  But that's not right..."
        DB	NEXT
        ;	DB	'【清美】：・・・と、おっしゃいますと？'
        DB	"Kiyomi:  What do you mean?"
        DB	FLG,F_COPYI,5,3
        DW	0000H

M12:		;話す　清美４
        ;	DB	'【%001】：・・・それは・・・'
        DB	"%001:  That would be..."
        DB	NEXT
        ;	DB	'【清美】：それは？'
        DB	"Kiyomi:  Yes?"
        DB	NEXT
        DB BUF,B_COPY01
        TU_CG 'CT03','W','K',12,3
        TU_CG "CT02","W",'I',0,5
        T_CG "CT01","W",'K',35,1
        ;	DB	'【鈴子】：%001く～ん！',CR
        DB	"Reiko:  %001!"
        DB	CR
        ;	DB	'【美緒】：%001先輩！'
        DB	"Mio:  %001!"
        DB	NEXT
        ;	DB	'【鈴子・美緒】：お昼一緒に食べ・・・'
        DB	"Reiko/Mio:  Let's eat lunch together!"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ............................"
        DB	NEXT
        ;	DB	'【清美】：・・・・・・・・・'
        DB	"Kiyomi:  ............................"
        DB	NEXT
        DB BUF,B_COPY01
        TU_CG 'CT03','W',0,12,6
        TU_CG "CT02","W",'I',0,5
        T_CG "CT01","W",0,35,7
        DB ANI,A_ON,6
        DB ANI,A_ON,5
        ;	DB	'【美緒】：・・・あれ？'
        DB	"Mio:  ............................"
        DB	NEXT
        ;	DB	'【鈴子】：・・・もしかして・・・話の腰折っちゃった？'
        DB	"Reiko:  Um, are we interrupting anything here?"
        DB	NEXT
        ;	DB	'【%001】：・・・いや・・・まあ・・・'
        DB	"%001:  No, not really..."
        DB	FLG,F_COPYI,1,1
        DB	FLG,F_COPYI,3,1
        DB	C_BLD,C_N_OFF,1,1		;「見る　鈴子」　出す
        DB	C_BLD,C_N_OFF,1,3		;「見る　美緒」　出す
        DB	C_BLD,C_N_OFF,2,1		;「話す　鈴子」　出す
        DB	C_BLD,C_N_OFF,2,3		;「話す　美緒」　出す
        DB	C_BLD,C_N_ON,2,2		;「話す　清美」　消す
        DW	0000H

M13:		;話す　美緒１
        ;	DB	'【美緒】：・・・ごめんなさい。お話の邪魔して・・・'
        DB	"Mio:  We're sorry for interrupting."
        DB	NEXT
        ;	DB	'【%001】：いや・・・そんな深刻になるよーな事じゃ・・・'
        DB	"%001:  No, it's nothing like that..."
        DW	0000H
        
M14:		;話す　減らさない訳１
        ;	DB	'【%001】：・・・俺さ、約束だけは今まで破った事ないんだ。'
        DB	"%001:  I've never broken a promise in my life, you see."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・そうよね、泳げなくても私のところに来てくれたし。'
        DB	"Reiko:  ...That's true."
        DB	NEXT
        ;	DB	'【%001】：だからさ・・・俺は出るって約束しちまったんだ。'
        DB	"%001:  And so, because I said I'd be in the events..."
        DB	PAUSE
        ;	DB	'・・・約束したからには、何があってもやり遂げて見せるさ。'
        DB	"...I"
        DB	CR
        DB	"don't want to change my mind now."
        DB	NEXT
        ;	DB	'【清美】：ですが・・・！'
        DB	"Kiyomi:  Yes, but...!"
        DB	NEXT
        ;	DB	'【%001】：・・・それにさ、練習始めて二日目だぜ？たった１日で音を上げたとあっちゃあ、みんなに笑われちまうよ。'
        DB	"%001:  And I've only started practicing. I can't give up"
        DB	CR
        DB	"on the second day. Everyone would laugh at me."
        DB	NEXT
        ;	DB	'【美緒】：そんな事無いよ！'
        DB	"Mio:  That's not true!"
        DB	NEXT
        ;	DB	'【%001】：・・・ま、とにかくそーゆー事だから。'
        DB	"%001:  Anyway, that's my decision."
        DB	NEXT
        ;	DB	'【鈴子】：『そーゆー事』じゃないでしょ！？'
        DB	"Reiko:  You can't decide something like that all by"
        DB	CR
        DB	"yourself!"
        DB	NEXT
        ;	DB	'きーんこーんかーんこーん'
        DB	"*DING DONG DING DONG*"
        DB	NEXT
        ;	DB	'【%001】：・・・お、ベルだ。'
        DB	"%001:  Ah, lunchtime's over."
        DB	NEXT
        ;	DB	'【鈴子】：・・・・・・'
        DB	"Reiko:  ............................"
        DB	NEXT
        ;	DB	'【鈴子】：とにかく、絶対無理しちゃダメよ！'
        DB	"Reiko:  Anyway, be careful! "
        DB	PAUSE
        ;	DB	'わかった！？'
        DB	"Do you understand?"
        DB	NEXT
        ;	DB	'【%001】：はいはい。'
        DB	"%001:  Yes, ma'am."
        DB	NEXT
        ;	DB	'【美緒】：%001先輩！放課後、また来るから・・・！'
        DB	"Mio:  %001, we'll see you after school again."
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT02","W",'I',0,5
        ;	DB	'【%001】：来なくてもいいぞ。'
        DB	"%001:  You don't have to do that..."
        DB	PAUSE
        ;	DB	'・・・って、もういない。'
        DB	" They're gone."
        DB	NEXT
        ;	DB	'【清美】：・・・%001さん・・・'
        DB	"Kiyomi:  %001..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001: ............"
        DB	PAUSE
        ;	DB	'だ～いじょ～ぶだって。新藤さんも心配症だな。'
        DB	"I'll be okay. You worry too much."
        DB	NEXT
        ;	DB	'【清美】：・・・・・・・・・'
        DB	"Kiyomi:  ............................"
        DB	NEXT
        DB	SINARIO,'CS801_4.OVL',0
        DW	0000H

M15:		;考える
        ;	DB	'やっぱり心配かけてんだなあ。'
        DB	"I guess I'm worrying them too much."
        DB	NEXT
        ;	DB	'・・・まあ、あの練習量じゃ、やってる本人が心配になるけどな。'
        DB	"I could see me being worried, being the one who's doing the"
        DB	CR
        DB	"actual practice."
        DB	NEXT
        ;	DB	'だからって、今さらやめる気はねーけど。'
        DB	"But why are they so worried?"
        DW	0000H
        

end
