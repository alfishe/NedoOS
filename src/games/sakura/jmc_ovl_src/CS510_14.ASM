;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１０＿１４
;		川　瑠璃の捜索（瑠璃の強制イベント）

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	NN3,-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'登る',0
VV3:	DB	3,	"CLIMB",0
;VV4:	DB	4,	'考える',0
VV4:	DB	4,	"THINK",0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	"RURI",0
;NN2:	DB	2,	'下',0
NN2:	DB	2,	"DOWN",0
;NN3:	DB	3,	'崖',0
NN3:	DB	3,	"CLIFF",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　瑠璃１
S2:		DW	VV1, NN2,  2, M3, M6		;見る　下１
S3:		DW	VV2, NN1,  3, M4, M5		;話す　瑠璃２
S4:		DW	VV1, NN3,  4, M7, M8, M9		;見る　崖３
S5:		DW	VV3, NN3,  5, M10, M11, M12		;登る　崖３
S6:		DW	VV4, -1,  6, M13, M14, M15, M16		;考える４


;イニシャルメッセージ
M1:
	DB	BGM,25
	BAK_INIT 'AB_10_2'
;	DB	'【%001】：・・・よっ！・・・とっ！・・・はっ！・・・やっ！'
	DB	"%001:  Yow!.....Ouch!....Whoa"
	DB	NEXT
;	DB	'すたっ。'
	DB	"I landed on the ledge where Ruri was."
	DB	NEXT
	E_CG B_YOKO,'AE_022'
;	DB	'【%001】：・・・白水さん！！'
	DB	"%001:  ...Ruri!"
	DW	0000H

M2:		;見る　瑠璃１
;	DB	'落ちた時にぶつけたんだろう。額から血が出ている。'
	DB	"She must have hit against the rock when she fell. Her"
	DB	CR
	DB	"forehead is bleeding."
	DB	NEXT
;	DB	'（・・・まずいな・・・頭を打ってる。）'
	DB	"That's bad."
	DW	0000H

M3:		;見る　下１
;	DB	'俺が来たせいで、崩れるスピードが速くなって来ている。'
	DB	"Now that I'm here, the rock is starting to crumble even"
	DB	CR
	DB	"faster."
	DB	NEXT
;	DB	'（・・・急いで離れないと・・・！）'
	DB	"We've got to get off this ledge!"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;見る　下２
;	DB	'すぐ下は川だ・・・・・・'
	DB	"The river is right below."
	DB	NEXT
;	DB	'（・・・この状態で落ちたら、２人とも助からねぇ・・・）'
	DB	"If we fell, we'd both be.....dead."
	DB	FLG,F_COPYI,2,0
	EF_SET 201
	DW	0000H

M4:		;話す　瑠璃１
;	DB	'【%001】：白水さん・・・'
	DB	"%001:  Ruri..." 
	DB	PAUSE
;	DB	'白水さんっ！！'
	DB	" Ruri!!"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ...................."
	DB	PAUSE
;	DB	'う・・・・・・・・・'
	DB	"Uh....."
	DB	NEXT
;	DB	'（・・・大丈夫だ、まだ息がある。）'
	DB	"She's still breathing. That's good."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す　瑠璃２
;	DB	'【%001】：白水さん！しっかり！！'
	DB	"%001:  Ruri! Wake up!"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・う・・・・・・・・・'
	DB	"Ruri:  ......Ooh......."
	EF_SET 202
	DW	0000H

M7:		;見る　崖１
;	DB	'ここから見上げると・・・予想以上に切り立っている。'
	DB	"Looking up, I see that the cliff face is much steeper"
	DB	CR
	DB	"than I imagined."
	DB	NEXT
;	DB	'（・・・登れるか・・・？白水さんを抱えたままで・・・）'
	DB	".....I wonder if I can climb it while holding on to Ruri as",CR,"well."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:		;見る　崖２
;	DB	'風化してるのか、かなり脆くなっているようだ。'
	DB	"I guess it's eroding. It seems to have become pretty"
	DB	CR
	DB	"unstable."
	DB	NEXT
;	DB	'（・・・くそっ・・・！）'
	DB	"Shit!"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M9:		;見る　崖３
;	DB	'（・・・何処か、手掛かりになるようなところは・・・！）'
	DB	"There must be somewhere where I can get a handhold!"
	DB	NEXT
;	DB	'（・・・・・・・・・）'
	DB	"......................"
	DB	NEXT
;	DB	'（ダメだ、暗くて良くわからねぇ！！）'
	DB	"Damm, it's too dark to see!"
	EF_SET 203
	DW	0000H

M10:		;登る　崖１
;	DB	'【%001】：・・・とにかく、とっととここから離れないと・・・！'
	DB	"%001:  Anyway, we have to get out of here right away...!"
	DB	NEXT
;	DB	'俺は白水さんを小脇に抱え、登り始めるべく壁に手を掛けた。'
	DB	"I held Ruri under my arm, and grabbed the rock face that I",CR,"had to climb up."
	DB	NEXT
;	DB	'が。'
	DB	'Uh.....'
	DB	NEXT
;	DB	'ぼろっ'
	DB	"*CRUMBLE*"
	DB	NEXT
;	DB	'【%001】：・・・よっ！'
	DB	"%001:  Damn!"
	DB	NEXT
;	DB	'ぼろっ'
	DB	"*CRUMBLE*"
	DB	NEXT
;	DB	'【%001】：・・・この！'
	DB	"%001:  Shit!"
	DB	NEXT
;	DB	'ぼろっ'
	DB	"*CRUMBLE*"
	DB	NEXT
;	DB	'【%001】：・・・こっちはどうだ！？'
	DB	"%001:  Crap! The cliff face keeps crumbling in my hands."
	DB	NEXT
;	DB	'ぼろぼろっ'
	DB	"*CRUMBLE CRUMBLE*"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  .................."
	DB	PAUSE
;	DB	'登れねぇ！？'
	DB	"I can't climb up!"
	DB	FLG,F_COPYI,5,1
	DW	0000H

M11:		;登る　崖２
;	DB	'【%001】：・・・片手じゃダメか！？'
	DB	"%001:  I can't do it with one hand!"
	DB	NEXT
;	DB	'俺は上着を脱いで引き裂き、簡易ロープを作って白水さんを背中に結わえた。'
	DB	"I took off my shirt, fashioned a rope out of it and tied Ruri",CR,"to my back."
	DB	NEXT
;	DB	'ぼろぼろっ'
	DB	"*CRUMBLE*"
	DB	NEXT
;	DB	'【%001】：・・・くそっ・・・そーゆー問題じゃねぇか・・・'
	DB	"%001:  ...Damn....still isn't working..."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M12:		;登る　崖３
;	DB	'【%001】：こなくそっ！！'
	DB	"%001:  This is terrible!"
	DB	NEXT
;	DB	'ぼろぼろぼろっ'
	DB	"*CRUMBLE CRUMBLE*"
	DB	NEXT
;	DB	'【%001】：・・・・・・ちくしょう・・・・・・'
	DB	"%001:  Dammit..."
	DB	PAUSE
;	DB	'ど～すりゃいいんだ！？'
	DB	" What am I going to do?!"
	EF_SET 204
	DW	0000H

M13:		;考える１
;	DB	'（落ち着け！よく考えろ%001！）'
	DB	"Be calm and think, %001!"
	DB	NEXT
;	DB	'（・・・何かあるはずだ、手を考えるんだ！）'
	DB	"There has to be something I can do..."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M14:		;考える２
;	DB	'（・・・こっから一気にジャンプして・・・）'
	DB	"If I try to jump back up to the top of the cliff..."
	DB	NEXT
;	DB	'（・・・・・・）'
	DB	"......................................"
	DB	NEXT
;	DB	'（ダメだ！ここから上まで、８ｍはある！いくら何でも届かねぇ！！）'
	DB	"Can't do it! It's eight meters to the top. I'll never make it!"
	DB	FLG,F_COPYI,6,2
	DW	0000H

M15:		;考える３
;	DB	'（こ～なったら、誰かにロープを取りに行ってもらって・・・）'
	DB	"Well, in that case, if someone could throw me down a rope..."
	DB	NEXT
;	DB	'（・・・・・・）'
	DB	"........................................."
	DB	NEXT
;	DB	'（ダメだ！今日子先生だってまだ来てね～のに、間に合う訳がねえ！！）'
	DB	"It won't work! If Kyoko-sensei isn't back yet, there won't be",CR,"enough time for anyone to get one!"
	DB	FLG,F_COPYI,6,3
	DW	0000H

M16:		;考える４
;	DB	'（・・・くそ！打つ手無しか！？）'
	DB	"Shit! Isn't there anything I can do?"
	DB	NEXT
;	DB	'（・・・・・・諦めるな%001！何か、何かあるはずなんだ・・・・・・！）'
	DB	".....There's got to be a way!!"
	EF_SET 205
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,6,255,201,202,203,204,205
	DB	FLG,F_EXIT,255
	DB	NEXT
	DB	GATA,2
;	DB	'がらららっ'
	DB	"*CRUMBLE*"
	DB	NEXT
;	DB	'【%001】：！？'
	DB	"%001:  ?!"
	DB	NEXT
	DB	GATA,2
;	DB	'俺の身体が、唐突に沈みこむ。'
	DB	"Suddenly, my body was sliding downwards."
	DB	NEXT
;	DB	'（崩れた・・・！？）'
	DB	"The cliff was finally giving way!"
	DB	NEXT
	DB	GATA,2
;	DB	'【%001】：くっそぉおぉぉおぉぉぉぉぉっっ！！！'
	DB	"%001:  Nooooo!"
	DB	NEXT
	DB	GATA,2
	DB	FLASH,3
;	DB	'どがぁっ！！'
	DB	"*SPACK*"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	PAUSE
;	DB	'止まった・・・・・・・・・？'
	DB	"We're not falling...?"
	DB	NEXT
;	DB	'ふと見ると、俺の左腕は深々と壁に付き刺さっていた。'
	DB	"When I looked, my left arm was thrust deeply into the wall."
	DB	NEXT
;	DB	'【%001】：・・・・・・なるほど、ここまで脆かった訳ね。'
	DB	"Wow, I guess the cliff face was really soft. As we were going "

	DB	CR

	DB	"down, I had punched out, lodging my whole arm into the cliff."
	DB	NEXT
;	DB	'方法が分かれば、後は簡単だ。'
	DB	"Once I knew how to get up the cliff, the rest was easy."
	DB	NEXT
	B_O B_SUDA
;	DB	'【%001】：おりゃっ！'
	DB	"%001:  Up!"
	DB	NEXT
;	DB	FLASH,3
;	DB	'どがぁっ！！'
	DB	"*CLIMB*"
	DB	NEXT
;	DB	'【%001】：とりゃっ！'
	DB	"%001:  Hup!"
	DB	NEXT
;	DB	FLASH,3
;	DB	'どがぁっ！！'
	DB	"*CLIMB*"
	DB	NEXT
;	DB	'俺は両腕をハーケン代わりに使いながら、崖をよじ登って行った。'
	DB	"Using both of my arms as climbing hooks, I scrambled up",CR,"the cliff."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT03','F','I',0,1
;	DB	'【美緒】：・・・・・・%001先輩っ！！'
	DB	"Mio:  %001!!"
	DB	NEXT
;	DB	'【%001】：・・・よ、ただ今。'
	DB	"%001:  ...Yo. I'm back."
	DB	NEXT
;	DB	'【美緒】：・・・良かった・・・ホントに良かった・・・'
	DB	"Mio:  .....Oh, I'm so glad!!"
	DB	NEXT
;	DB	'【%001】：・・・泣くなって。俺は大丈夫だから。'
	DB	"%001:  Stop crying. I told you not to worry."
	DB	NEXT
	T_CG1 'CT14','F',0,30,2
	DB	ANI,A_ON,1
;	DB	'【誠】：・・・まったく大した野郎だぜ、お前。'
	DB	"Makoto:  You did it, %001."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'さ、みんな帰ろうぜ。白水さんの手当もしないと。'
	DB	"%001:  Well, everybody, let's go back. We have to have ",CR,"Kyoko-sensei look at Ruri's head."
	DB	NEXT
;	DB	'・・・こうして俺達は朝靄の中、無事みんなの元に帰る事が出来たのだった。'
	DB	"We all headed back."
	DB	NEXT
	DB	SINARIO,'CS511_E.OVL',0
	DW	0000H

end
