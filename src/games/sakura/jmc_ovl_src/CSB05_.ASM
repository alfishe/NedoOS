	;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｂ０５＿
;		義理チョコ
        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13
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
CM1:	DW	VV1,	NN9,NN2,NN7,NN8,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,NN8,-1

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
;NN4:	DB	4,	'祥子',0
NN4:	DB	4,	'SHOKO',0
;NN5:	DB	5,	'瑠璃',0
NN5:	DB	5,	'RURI',0
;NN6:	DB	6,	'亜希',0
NN6:	DB	6,	'AKI',0
;NN7:	DB	7,	'星愛',0
NN7:	DB	7,	'SEIA',0
;NN8:	DB	8,	'恵依美',0
NN8:	DB	8,	'MEIMI',0
;NN9:	DB	9,	'誠',0
NN9:	DB	9,	'MAKOTO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN9,  1, M2		;見る　誠
S2:		DW	VV1, NN2,  2, M3		;見る　清美
S3:		DW	VV1, NN7,  3, M4, M5		;見る　星愛
S4:		DW	VV1, NN8,  4, M6, M7		;見る　恵依美
S5:		DW	VV2,  -1,  5, M8		;話す
S6:		DW	VV3, NN1,  6, M9		;考える　鈴子
S7:		DW	VV3, NN2,  7, M10		;考える　清美
S8:		DW	VV3, NN3,  8, M11		;考える　美緒
S9:		DW	VV3, NN4,  9, M12		;考える　祥子
S10:	DW	VV3, NN5, 10, M13, M14		;考える　瑠璃２（G159=1)
S11:	DW	VV3, NN6, 11, M15		;考える　亜希
S12:	DW	VV3, NN7, 12, M16		;考える　星愛
S13:	DW	VV3, NN8, 13, M17		;考える　恵依美


;イニシャルメッセージ
M1:
        DB	BGM,5
        BAK_INIT "AB_36_1"
        B_P1 B_SUDA
        ;	DB	'そして、バレンタイン当日・・・放課後。'
        DB	"And then it was Valentine's Day."
        DB	NEXT
        DB	BUF,B_COPY01
        TU_CG "CT07","W",0,0,1
        T_CG "CT08","W",0,35,2
        DB	ANI,A_ON,1
        ;	DB	'【恵依美】：男子、注目！'
        DB	"Meimi:  All guys, we'd like your attention."
        DB	NEXT
        ;	DB	'教卓の前で中野と吉田が風呂敷包みを拡げている。'
        DB	"Meimi and Seia stood at the front of the class, holding a bag."
        DB	NEXT
        ;	DB	'【星愛】：恵まれない男子の皆さんに、恵依美ちゃんから愛のチョコレートの配給ですわよ～。'
        DB	"Seia:  For all the guys of the class, we offer Meimi's"
        DB	CR
        DB	"'chocolate of love.'"
        DB	NEXT
        ;	DB	'【恵依美】：ちょっと星愛、あたしたち二人から、でしょ！'
        DB	"Meimi:  Seia, this chocolate is from both of us!"
        DB	NEXT
        ;	DB	'【星愛】：わたくしの愛は、主に捧げておりますもの。'
        DB	"Seia:  I only give my love to the Lord."
        DB	NEXT
        ;	DB	'たちまちの内に教卓に殺到する男ども。'
        DB	"All the guys in the class made a bee-line for Seia and Meimi."
        DB	NEXT
        ;	DB	'【恵依美】：おっ押さないでよ！あわてなくてもちゃんとみんなの分あるんだから！'
        DB	"Meimi:  Don't push! There's enough for everyone!"
        DB	NEXT
        T_CG "CT14","W",0,15,2
        ;	DB	'【誠】：この際中野でも構わないからくれ！'
        DB	"Makoto:  Chocolate! I want my chocolate!"
        DB	NEXT
        ;	DB	'【恵依美】：あんたには絶っっっっっっっっっっっっっ対にあげないって言ったでしょ！'
        DB	"Meimi:  I told you, you don't get any!"
        DB	NEXT
        ;	DB	'【誠】：・・・本当にないの？'
        DB	"Makoto:  .....Are you serious?"
        DB	NEXT
        ;	DB	'【恵依美】：ないわ。'
        DB	"Meimi:  Of course."
        DB	NEXT
        ;	DB	'【誠】：本っっっっっっっっっっっ当に？'
        DB	"Makoto:  Really?"
        DB	NEXT
        ;	DB	'【星愛】：わたくしはかわいそうだと申し上げたのですが・・・'
        DB	"Seia: I asked her to reconsider, but..."
        DB	NEXT
        ;	DB	'・・・誠は真っ白な灰になった。'
        DB	"Makoto's face melted before our eyes."
        DB	BUF,B_COPY01
        TU_CG "CT07","W",0,0,1
        T_CG "CT08","W",0,35,2
        DB	ANI,A_ON,1
        DB	PAUSE
        B_P1 B_SUDA
        DB	G_FLG,G_COPYF,10,159	;考える　瑠璃
        DW	0000H
        
M2:		;見る　誠
        ;	DB	'真っ白な灰になってる。'
        DB	"His face is all melted."
        DB	NEXT
        ;	DB	'今日の昼休みに鈴子さんが来なかった上に、中野にとどめを刺されたせいだ。'
        DB	"Reiko didn't give him anything, and now this. I feel sorry"
        DB	CR
        DB	"for him."
        EF_SET 201
        DW	0000H
        
        
M3:		;見る　清美
        ;	DB	'新藤さんは、終業のベルと同時に教室を出ていった。'
        DB	"Kiyomi left the classroom as soon as the bell rang."
        DB	NEXT
        ;	DB	'なぜなら・・・'
        DB	"I know why..."
        EF_SET 202
        DW	0000H
        
M4:		;見る　星愛
        ;	DB	'あれ・・・こっちに歩いてくる。'
        DB	"She's walking this way."
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT07","W",0,15,1
        ;	DB	'吉田は小さな包みを俺に差し出した。'
        DB	"She hands me a small package."
        DB	NEXT
        ;	DB	'【星愛】：これは、わたくしから%001さんに・・・感謝の気持ちですわ。'
        DB	"Seia:  These are my feelings of...thanks."
        DB	NEXT
        ;	DB	'【%001】：感謝だなんて・・・俺は別に、何もしちゃいないぜ？'
        DB	"%001:  Thanks? What do you have to thank me for?"
        DB	NEXT
        ;	DB	'【星愛】：いいえ、%001さんは宴会委員として、１年間わたくしたちを楽しませて下さいました。'
        DB	"Seia:  You helped me as a member of the class council this"
        DB	CR
        DB	"past year."
        DB	NEXT
        ;	DB	'【%001】：そか？誠の方がよっぽど活躍してたと思うがな。'
        DB	"%001:  Oh. But Makoto did more than me."
        DB	NEXT
        ;	DB	'【星愛】：クス・・・痴話げんかは傍から見ているとこの上なくおかしいですわよ。'
        DB	"Seia:  He was just fighting with Aki most of the time."
        DB	NEXT
        ;	DB	'【%001】：・・・はあ。'
        DB	"%001:  Maybe you're right."
        DB	NEXT
        ;	DB	'【星愛】：・・・ですが、もうすぐ卒業なさってしまいますわね、鈴子さんは。'
        DB	"Seia:  .....Well, Reiko will be graduating soon, won't she?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ...................................."
        DB	NEXT
        ;	DB	'【星愛】：あら、ごめんなさい、変なことばかり言ってしまって。'
        DB	"Seia:  Oh! I'm sorry! I didn't mean to say anything...."
        DB	NEXT
        ;	DB	'【%001】：いや・・・別に。'
        DB	"%001:  No, it's alright."
        DB	NEXT
        ;	DB	'【%001】：あ、チョコありがとうな。'
        DB	"%001:  Thanks for the chocolate."
        DB	NEXT
        ;	DB	'【星愛】：ホワイトデー、期待しておりますわよ。'
        DB	"Seia:  I'll look forward to White Day."
        DB	NEXT
        ;	DB	'【%001】：へぇへぇ。'
        DB	"%001:  Okay."
        DB	NEXT
        ;	DB	'・・・吉田は中野のところに戻っていった。'
        DB	"Seia goes back to where Meimi is."
        B_P1 B_SUDA
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M5:		;見る　星愛
        ;	DB	'中野と一緒に、チョコをばらまいてる。'
        DB	"She's throwing chocolate to the other guys with Meimi."
        EF_SET 204
        DW	0000H
        
M6:		;見る　恵依美
        ;	DB	'あれ・・・こっちに歩いてくる。'
        DB	"She's coming this way."
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT08","W",0,15,2
        ;	DB	'【恵依美】：%001、これあげる！'
        DB	"Meimi:  %001, this is for you!"
        DB	NEXT
        ;	DB	'中野は手のひらに乗る程度の、小さな包みを取り出した。'
        DB	"She hands me a small package."
        DB	PAUSE
        ;	DB	'・・・それは今時１０円で買える、チ□ルチョコ（コーヒー味）だった。'
        DB	" It was filled with little"
        DB	CR
        DB	"chocolates you could buy anywhere for ten yen each."
        DB	NEXT
        ;	DB	'【恵依美】：全員に配んないと不公平だから、%001にもあげる。'
        DB	"Meimi:  It'd be unfair if I gave you something special,"
        DB	CR
        DB	"when I'm giving the same thing to all the other guys, don't"
        DB	CR
        DB	"you agree?"
        DB	NEXT
        ;	DB	'【恵依美】：どうせ%001はこれから誰かさんたちにもらうでしょうけど、それなら邪魔にならないでしょ？'
        DB	"Meimi:  I'm sure you'll get plenty of hand-made chocolate"
        DB	CR
        DB	"from the other girls."
        DB	NEXT
        ;	DB	'【恵依美】：別にお返しなんか期待してないから、安心して。'
        DB	"Meimi:  You don't have to get me anything on White Day."
        DB	NEXT
        ;	DB	'【%001】：・・・あ、ありがとよ。'
        DB	"%001:  ......Thanks."
        DB	NEXT
        ;	DB	'【%001】：・・・で、誠の分は本当にないのか？'
        DB	"%001:  ....Are you really not going to give any to Makoto?"
        DB	NEXT
        ;	DB	'【恵依美】：ま、帰り際にでも渡してあげるわよ。'
        DB	"Meimi:  I'll give him his on my way home."
        DB	NEXT
        ;	DB	'【恵依美】：・・・ところで、%001はこんなとこでぼーっとしてていいの？誰かが待ってるんじゃない？'
        DB	"Meimi:  ...What are you still doing here? Shouldn't you"
        DB	CR
        DB	"start going home? You never know who might be waiting for"
        DB	CR
        DB	"you on the way..."
        DB	NEXT
        ;	DB	'【%001】：・・・まだ・・・心の準備が・・・'
        DB	"%001:  I need some more time to get myself ready for it."
        DB	NEXT
        ;	DB	'【恵依美】：・・・さっさと行ってあげなさいよね！'
        DB	"Meimi:  Go to them! They're waiting!"
        DB	NEXT
        ;	DB	'【%001】：分かってるよ・・・。何で中野が怒るんだよ。'
        DB	"%001:  Okay. Why are you upset, though?"
        DB	NEXT
        ;	DB	'【恵依美】：少しは待たされる方の気持ち、考えたら？'
        DB	"Meimi:  How do you think it feels for them to stand outside,"
        DB	CR
        DB	"waiting for you like that?"
        DB	NEXT
        ;	DB	'・・・中野は教卓に戻っていった。'
        DB	"Meimi went back to where Seia was."
        DB	NEXT
        ;	DB	'【%001】：待たされる方の気持ち・・・か。'
        DB	"%001:  .....I guess I am keeping them waiting."
        B_P1 B_SUDA
        DB	FLG,F_COPYI,4,1
        DW	0000H
        
M7:		;見る　恵依美
        ;	DB	'群がる男にチョコをばらまいてる。'
        DB	"She's handing out chocolate to the other guys."
        EF_SET 203
        DW	0000H
        
        
M8:		;話す
        ;	DB	'誠はすでに死んでいる。'
        DB	"Makoto's dead."
        DB	NEXT
        ;	DB	'新藤さんはこの場にいない。'
        DB	"Kiyomi's not here."
        DB	NEXT
        ;	DB	'中野と吉田はチョコをばらまくのに忙しい。'
        DB	"Meimi and Seia are busy handing out chocolate to the other"
        DB	CR
        DB	"guys."
        DB	NEXT
        ;	DB	'・・・よーするに、話相手はいない。'
        DB	"So there's no one to talk to."
        EF_SET 205
        DW	0000H
        
M9:		;考える　鈴子
        ;	DB	'今朝、俺の下駄箱に入ってた、鈴子さんからの手紙・・・'
        DB	"When I got to school, I found a letter from Reiko in my"
        DB	CR
        DB	"shoes locker."
        DB	NEXT
        ;	DB	'「放課後、プールで待ってます。'
        DB	"'I'll be waiting by the pool."
        DB	CR
        ;	DB	'　　　　　　　　　　　　　　　　　　　　　　　鈴子」'
        DB	"                                                     Reiko'"
        DB	NEXT
        ;	DB	'鈴子さんはもうすぐ卒業・・・もう、今までみたいには会えなくなる・・・'
        DB	"She'll be graduating next month. Then she'll go off to"
        DB	CR
        DB	"college."
        DB	NEXT
        ;	DB	'だから・・・俺は、結論を出さなきゃならない。'
        DB	"That's why I have to make up my mind now."
        DB	NEXT
        ;	DB	'俺に素晴らしい思い出をくれた鈴子さんのためにも、そして俺自信のためにも。'
        DB	"For Reiko, who made so many nice memories for me, as well"
        DB	CR
        DB	"as for myself."
        EF_SET 206
        DW	0000H
        
M10:		;考える　清美
        ;	DB	'今朝、俺の下駄箱に入ってた、新藤さんからの手紙・・・'
        DB	"When I got to school, I found a letter from Kiyomi in my"
        DB	CR
        DB	"shoes locker."
        DB	NEXT
        ;	DB	'「今日の放課後、野球部グラウンドでお待ち致します。'
        DB	"'I'll be waiting at the baseball field."
        DB	CR
        ;	DB	'　　　　　　　　　　　　　　　　　　　　　　　新藤　清美」'
        DB	"                                                     Kiyomi'"
        DB	NEXT
        ;	DB	'俺と新藤さんは、この一年間クラスメイト同士だった。'
        DB	"Kiyomi and I have been classmates for the past year."
        DB	NEXT
        ;	DB	'きっとこれから先も、一緒にいる時間は多いだろう。'
        DB	"I'm sure we'll see a lot of each other in the future as well."
        DB	CR
        ;	DB	'だからこそ、俺はちゃんと答えを出さなきゃいけない。'
        DB	"For that reason, I have to make up my mind soon."
        DB	NEXT
        ;	DB	'いつまでも、新藤さんの好意に甘えてばかりじゃだめだ。'
        DB	"That's what it is to be really kind to someone."
        EF_SET 207
        DW	0000H
        
M11:		;考える　美緒
        ;	DB	'今朝、俺の下駄箱に入ってた、新藤さんからの手紙・・・'
        DB	"When I got to school, I found a letter from Mio in my"
        DB	CR
        DB	"shoes locker."
        DB	NEXT
        ;	DB	'「今日の放課後、野球部グラウンドでお待ち致します。'
        DB	"'I'll be waiting at the tennis courts."
        DB	CR
        ;	DB	'　　　　　　　　　　　　　　　　　　　　　　　新藤　清美」'
        DB	"                                                     Mio'"
        DB	NEXT
        ;	DB	'美緒ちゃんは今年、高等部を受験する。まあ、美緒ちゃんなら大丈夫だろう。'
        DB	"Mio's going to be around for a while."
        DB	NEXT
        ;	DB	'きっとこれから先も、美緒ちゃんと一緒にいる時間は多いと思う。'
        DB	"I'm sure I'll spend a lot of time with her in the future."
        DB	CR
        ;	DB	'だからこそ、俺はちゃんと答えを出さなきゃいけない。'
        DB	"For that reason, I have to make up my mind soon."
        DB	NEXT
        ;	DB	'それが、俺を慕ってくれた美緒ちゃんへのけじめだ。'
        DB	"It's the least I can do for her."
        EF_SET 208
        DW	0000H
        
M12:		;考える　祥子
        ;	DB	'・・・そう言えば、体育祭からこっち、見てないな。'
        DB	"Now that I think about it, I haven't seen her since the"
        DB	CR
        DB	"sports festival."
        DB	NEXT
        ;	DB	'きっと、俺よりも胸が「きゅーん」ってなる誰かを見付けたんだろう。'
        DB	"She probably found someone that makes her heart soar"
        DB	CR
        DB	"more than me."
        DB	NEXT
        ;	DB	'・・・・・・・・・惜しかったかな・・・'
        DB	"...........I guess I'm a little disappointed."
        EF_SET 209
        DW	0000H
        
M13:		;考える　瑠璃１（G159=0)
        ;	DB	'俺は白水さんのために、何もしてあげることが出来なかった。'
        DB	"In the end, I couldn't do anything for her."
        DB	NEXT
        ;	DB	'俺が何もしなくても、時は流れ、過ぎ去っていく。'
        DB	"It's too late. Time will continue to pass for both of us."
        DB	NEXT
        ;	DB	'このまま答えを出さないで、鈴子さんが卒業して・・・それっきりなんて事にはしちゃあいけない。'
        DB	"For Reiko's sake, I've got to choose before she graduates"
        DB	CR
        DB	"in March."
        EF_SET 210
        DW	0000H
        
        
M14:		;考える　瑠璃２（G159=1)
        ;	DB	'彼女は、もうここにはいない。'
        DB	"Ruri's not here."
        DB	NEXT
        ;	DB	'最後の最後で、俺たちはクラスメイトになれた・・・そんな気がする。'
        DB	"I know deep down that she will be one of us...a member of"
        DB	CR
        DB	"this class...to the very end."
        EF_SET 210
        DW	0000H
        
M15:		;考える　亜希
        ;	DB	'・・・そう言えば、亜希ちゃんからは手紙をもらってねーな。'
        DB	"I didn't get a letter from Aki."
        DB	NEXT
        ;	DB	'・・・チョコ、くれるのかな・・・'
        DB	"I wonder if she's going to give me anything?"
        EF_SET 211
        DW	0000H
        
M16:		;考える　星愛
        ;	DB	'・・・吉田は誰か好きな人いるのかな。'
        DB	"I wonder if she has a boyfriend or anything..."
        EF_SET 212
        DW	0000H
        
M17:		;考える　恵依美
        ;	DB	'・・・中野には悪いが、あいつに「恋」なんて似合わねーぞ。'
        DB	"This isn't very nice to her, but I just can't think of"
        DB	CR
        DB	"love and Meimi in the same sentence."
        DB	NEXT
        ;	DB	'もうちょいお淑やかだったら、きっともてるだろうな・・・'
        DB	"I'm sure she'd give me a karate chop if I said that to"
        DB	CR
        DB	"her face."
        EF_SET 213
        DW	0000H
        
M_EXIT:
        DB	FLG,F_COPYI,255,1
        DB	FLG,F_MAND,14,255,201,202,203,204,205,206,207,208,209,210,211,212,213
        DB	FLG,F_EXIT,255
        DB	NEXT
        ;	DB	'どたどたどたどた・・・・・・！'
        DB	"....I hear footsteps coming this way."
        DB	NEXT
        ;	DB	'ガラッ！'
        DB	"*KACHA*"
        DB	BUF,B_COPY01
        DB	ANI,A_OFF
        T_CG "CT06","W",0,15,3
        DB	NEXT
        ;	DB	'【亜希】：%001先輩！'
        DB	"Aki:  %001?"
        DB	NEXT
        ;	DB	'【%001】：亜希ちゃん・・・？'
        DB	"%001:  Aki?"
        DB	NEXT
        ;	DB	'【亜希】：ちょっと来て！'
        DB	"Aki:  Come here a minute, would you?"
        DB	NEXT
        ;	DB	'【%001】：わわわわ・・・'
        DB	"%001:  Okay, I'm going, I'm going!"
        DB	NEXT
        ;	DB	'俺は亜希ちゃんに引っ張られて、教室を出た。'
        DB	"Aki pulls me out of the room."
        DB	NEXT
        DB	SINARIO,'CSB05_F.OVL',0
        DW	0000H
        

end
