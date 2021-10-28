; Note: only a little bit of this file is done. 
;	さくらの季節
;		シーン　４１０＿５
;		バベル　女の子対戦中

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
;VV2:	DB	2,	'コインを入れる',0
VV2:	DB	2,	'INSERT COIN',0
;VV3:	DB	3,	'ゲームスタート',0
VV3:	DB	3,	'START GAME',0

;NN1:	DB	1,	'バベル内',0
NN1:	DB	1,	'GAME CENTER',0
;NN2:	DB	2,	'Ｖ忍者・弍',0
NN2:	DB	2,	'V-NINJA II',0
;NN3:	DB	3,	'対戦台',0
NN3:	DB	3,	'CROWD',0
;NN4:	DB	4,	'女の子',0
NN4:	DB	4,	'WOMAN',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　バベル内
S2:		DW	VV1, NN2,  2, M4, M5		;見る　Ｖ忍者・弐
S3:		DW	VV1, NN3,  3, M6, M7		;見る　対戦台
S4:		DW	VV1, NN4,  4, M8		;見る　女の子
S5:		DW	VV2, -1,  5, M9		;コインを入れる
S6:		DW	VV3, -1,  6, M10		;ゲームスタート


;イニシャルメッセージ
M1:
	DB	BGM,17
	BAK_INIT 'AB_25'
	B_P1 B_SUDA
;	DB	'ゲームセンター「バベル」に来た。'
	DB	"I'm in the game center Babel."
	DB G_FLG,G_COPYI,104,1
	DB	C_BLD,C_N_ON,1,4
	DB	C_BLD,C_V_ON,2
	DB	C_BLD,C_V_ON,3
	DW	0000H

M2:		;見る　バベル内
;	DB	'【%001】：ん？・・・何か人が集まってるな。'
	DB	"%001:  Mm? There's a lot of people gathered over there."
	DB	NEXT
;	DB	'『バーチャル忍者・弐』の対戦台の回りに、人だかりが出来ていた。'
	DB	"They're gathered around the Virtual Ninja II game."
	DB	NEXT
;	DB	'「おい、とうとう１００人抜きしたぞ、あの子！」'
	DB	"Gamer:  Oh, that's more than one hundred opponents defeated!"
	DB	NEXT
;	DB	'（１００人抜き？！）'
	DB	"One hundred...?"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　バベル内
;	DB	'『バーチャル忍者・弐』の対戦台に人が集まってる。'
	DB	"People are gathered around the Virtual Ninja II machine."
	DB	NEXT
;	DB	'どうやら１００人抜きの強者がいるらしいが・・・'
	DB	"Apparently the person playing must be pretty good..."
	DW	0000H


M4:		;見る　Ｖ忍者・弐
;	DB	'（『バーチャル忍者・弐』は、３Ｄ対戦格闘ゲームだ。）'
	DB	"Virtual Ninja II is a 3-D fighting game."
	DB	NEXT
;	DB	'（登場キャラクターは全員忍者。作り手の、忍者にかける情熱がうかがえる。）'
	DB	"All the characters you can fight with are ninjas."
	DB	NEXT
;	DB	'（ただし、格好といい技といい、どのキャラクターも本物の忍者が見たら卒倒しそうなほどド派手だ。）'
	DB	"Some of them don't look like what you'd expect a ninja"
	DB	CR
	DB	"to look like, of course."
	DB	FLG,F_COPYI,2,1
	DW	 0000H

M5:		;見る　Ｖ忍者・弐
;	DB	'（前作『バーチャル忍者』よりさらに派手になっている。）'
	DB	"It's a much better game than the last one, Virtual Ninja."
	DB	NEXT
;	DB	'（それと、前作でコンピューターが強かったのが不評だったらしく、今回のコンピューターはかなり弱く設定されている。）'
	DB	"On the other hand,  the computer players were fairly"
	DB	CR
	DB	"challenging in the last game, but in this version the"
	DB	CR
	DB	"computer's easy to beat."
	DB	NEXT
;	DB	'（俺はあのくらいでちょうどいいと思ったが。）'
	DB	"I liked it better before."
	DW	 0000H

M6:		;見る　対戦台
;	DB	'（１００人抜きか・・・どんな奴だ？）'
	DB	"I want to see this person who's managed to clear one"
	DB	CR
	DB	"hundred other opponents."
	DB	NEXT
;	DB	'【%001】：えっ！？'
	DB	"%001:  What?"
	DB	NEXT
	E_CG B_SUDA,'AE_045'
;	DB	'【%001】：女の子が・・・？'
	DB	"%001:  It's a woman..."
	DB	NEXT
;	DB	'【ゲーマーＡ】：あの子、この前の全国大会で優勝したホンダラ使いだよ。しかも、予選から決勝まで一本も落とさずに勝ち抜いたって。'
	DB	"Gamer:  She won the national championship last month with"
	DB	CR
	DB	"her use of the character Hondala."
	DB	NEXT
;	DB	'【ゲーマーＡ】：「マスター・ホンダラ」って呼ばれてるんだ、彼女。'
	DB	"Gamer:  So they call her Master Hondala..."
	DB	C_BLD,C_N_OFF,1,4
	DB	FLG,F_COPYI,3,1
	DW	0000H

M7:		;見る　対戦台
;	DB	'【%001】：女の子は、次々に入ってくる挑戦者達を片っ端からやっつけてる。'
	DB	"%001:  She keeps destroying the people who try to challenge"
	DB	CR
	DB	"her."
	DB	NEXT
;	DB	'【%001】：・・・強いな、彼女・・・。'
	DB	"%001:  She's really good."
	DW 0000H

M8:		;見る　女の子
;	DB	'【%001】：次の獲物が来るのを待ってるみたいだ。'
	DB	"%001:  She must be waiting for her next victim."
	DB	NEXT
;	DB	'【%001】：よし、俺もお手合わせ願おうじゃねーか。'
	DB	"%001:  I guess I'll take her on."
	DB  C_BLD,C_V_OFF,2
	DW 0000H

M9:		;コインを入れる
;	DB	'俺は女の子の向かいの台に座った。'
	DB	"I sit down at the game console across from her."
	DB	NEXT
;	DB	'ちゃりーん'
	DB	"My coin makes a metallic sound as it entered the machine."
	DB  C_BLD,C_V_ON,1
	DB  C_BLD,C_V_ON,2
	DB  C_BLD,C_V_OFF,3
	DW 0000H

M10:		;ゲームスタート
;	DB	'（さて、お手並拝見と行こうか。）'
	DB	"Well, let's see how good this game is."
	DB	NEXT
;	DB	'俺は使いなれてる主人公キャラ、「サイゾウ」を選んだ。'
	DB	"I choose the character I'm best at, Saizo."
	DB	NEXT,CR
;	DB	'                  　ホンダラ　ＶＳ　サイゾウ'
	DB	"                   Hondala vs. Saizo"
	DB	NEXT
	DB	CR
;	DB	'                            　勝負！'
	DB	"                    The fight is on!"
	DB	NEXT
;	DB	'ガッ　ゴカッ　ピシ　ドカッ・・・「一本！」'
	DB	"*PUNCH* *KICK* *DEFEND* ........"
	DB	NEXT
;	DB	'【%001】：つ、強い！'
	DB	"%001:  She won the first round already! She's good..."
	DB	NEXT
	DB	CR
;	DB	NEXT
;	DB	'ズシャッ！　ゴッ　ドカッ・・・！'
	DB	"*CRASH* *SMASH* ......!"
	DB	NEXT
;	DB	'（今だ・・・！）'
	DB	"Now!!"
	DB	NEXT
;	DB	'「獣閃崩壊拳！」'
	DB	"Lightning Destruction Fist!"
	DB	NEXT
;	DB	'（・・・は、外した・・・）'
	DB	"......Oh no!!"
	DB	NEXT
;	DB	'「ハィヤァーッ！」'
	DB	"Double Thunder Kick!"
	DB	NEXT
;	DB	'ドッガァーン！「勝負あり！ホンダラ！」'
	DB	CR
	DB	"                      Hondala is victorious!"
	DB	NEXT
;	DB	'【%001】：さすが日本一・・・。動体視力と反射神経だけじゃ太刀打ち出来ないか・・・。'
	DB	"%001:  Well, I can see why she's the best in all Japan."
	DB	CR
	DB	"Such reflexes, such movements, I never had a chance."
	DB	NEXT
;	DB	'【女の子】：中々やるね、キミ！ボク相手に１分以上戦えた相手って久しぶりだよ！'
	DB	"Woman:  You're pretty good. It's been a while since someone"
	DB	CR
	DB	"lasted a whole minute against me."
	DB	NEXT
;	DB	'【%001】：今度は俺が勝つ！'
	DB	"%001:  I'll beat you next time!"
	DB	NEXT
;	DB	'【女の子】：望むところだ！'
	DB	"Woman:  If you say so..."
	DB	NEXT
;	DB	'その後彼女と何回か対戦し、結局勝率３割くらいで終わった。'
	DB	"I played a few more games with her, but in the end I only "
	DB	CR
	DB	"managed to win thirty percent of the fights."
	DB	NEXT
;	DB	'まあ、日本一の彼女が相手なんだから、上出来の戦績という事にしとこう。彼女もそう言って誉めてくれたし。'
	DB	"Well, she is really something. I'm glad I had the chance"
	DB	CR
	DB	"to go against her."
	DB	NEXT
;	DB	'【%001】：ふぅ、久々の熱い対戦だった・・・。'
	DB	"%001:  I haven't gotten that into a video game in a"
	DB	CR
	DB	"while."
	DB	NEXT
;	DB	'俺は「バベル」を出た。'
	DB	"I leave the game center."
	DB	NEXT
	DB SINARIO,'CS410_1.OVL',0
	DW 0000H


end
