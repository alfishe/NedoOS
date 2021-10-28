;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０６
;		体育祭１日前　決戦！ゲーセンマスター！！

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'ゲームスタート',0
VV2:	DB	2,	'GAME START',0
;VV3:	DB	3,	'戦う',0
VV3:	DB	3,	'FIGHT',0

;NN1:	DB	1,	'バベル内',0
NN1:	DB	1,	'BABEL',0
;NN2:	DB	2,	'女の子',0
NN2:	DB	2,	'WOMAN',0 ; GIRLS?

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　バベル内
S2:		DW	VV1, NN2,  2, M3		;見る　女の子
S3:		DW	VV2, -1,  3, M4		;ゲームスタート
S4:		DW	VV3, -1,  4, M5, M6, M7, M8		;戦う


;イニシャルメッセージ
M1:
        DB	BGM,17
        BAK_INIT "AB_25"
        B_P1 B_SUDA
        ;	DB	'ゲームセンター「バベル」。俺の、いわばホームグラウンドだ。'
        DB	"I'm in the game center 'Babel.' This place is like a"
        DB	CR
        DB	"second home to me."
        DB	NEXT
        ;	DB	'さあて、今日もいっちょ、「バーチャル忍者・弍」でもやるかぁ！'
        DB	"I guess I'll play Virtual Ninja two again."
        DB	NEXT
        ;	DB	'こないだ女の子にコテンパンにのされてから、これしかやってない。'
        DB	"I haven't been back since that woman kicked my ass at the"
        DB	CR
        DB	"game last time."
        DB	NEXT
        ;	DB	'その甲斐あってか、今では「バベルサイゾウ」と言う通り名で呼ばれるようになった。'
        DB	"People have started calling me Babel Saizo because I"
        DB	CR
        DB	"always play with the same character."
        DB	NEXT
        ;	DB	'・・・しかぁし、その程度で驕ってはいけない。来るべき再戦の日に向けて、特訓あるのみ！'
        DB	"But it doesn't mean anything if I can't beat that woman"
        DB	CR
        DB	"next time I see her."
        DB	NEXT
        ;	DB	'・・・再戦の日なんてくるのかな・・・'
        DB	"I wonder if I'll ever play her again..."
        DB	C_BLD,C_V_ON,2		;「ゲームスタート」　消す
        DB	C_BLD,C_V_ON,3		;「戦う」　消す
        DB	C_BLD,C_N_ON,1,2	;「見る　女の子」　消す
        DW	0000H
        
M2:		;見る　バベル内
        ;	DB	'「バーチャル忍者・弍」の対戦台がある。'
        DB	"There's a Virtual Ninja II game here."
        DB	NEXT
        ;	DB	'俺もちょっとは有名になったせいか、対戦相手が前より増えた。'
        DB	"I must be making a name for myself, too. A lot of people"
        DB	CR
        DB	"want to play against me."
        DB	NEXT
        ;	DB	'その方が、上達も早いってモンだ。'
        DB	"It's a better way to get good at the game than playing"
        DB	CR
        DB	"against the computer."
        DB	NEXT
        ;	DB	'俺は小銭を掴むと、対戦台の方へ向かった。'
        DB	"I head for the Virtual Ninja game machine."
        DB	C_BLD,C_N_ON,1,1	;「見る　バベル内」　消す
        DB	C_BLD,C_V_ON,1		;「見る」　消す
        DB	C_BLD,C_V_OFF,2		;「ゲームスタート」　出す
        DW	0000H
        
M3:		;見る　女の子
        ;	DB	'「マスターホンダラ」と呼ばれている凄腕の女の子だ。'
        DB	"It's the woman they call Master Hondala. She's really good"
        DB	CR
        DB	"at this game."
        DB	NEXT
        ;	DB	'・・・考えて見たら、俺、彼女の名前、聞いてねえ。'
        DB	"........I'm not sure what her name is."
        DB	NEXT
        ;	DB	'・・・ま、いっか。'
        DB	"Oh well. I can ask her later."
        DW	0000H
        
M4:		;ゲームスタート
        ;	DB	'俺の持ちキャラは通り名が示すように「サイゾウ」だ。'
        DB	"I choose the character named 'Saizo.'"
        DB	NEXT
        ;	DB	'スピード不足は確かに感じる。俺も、初めてプレイしたときは、「おいおい、こいつ忍者かよ？」とか思った記憶がある。'
        DB	"He's not very fast. The first time I played with him, I"
        DB	CR
        DB	"said to myself, is this the way a Ninja moves?"
        DB	NEXT
        ;	DB	'しかし、こいつの魅力はなんといってもそのパワーだ。その上、ボタン連打で勝ててしまったりする。'
        DB	"But he's powerful, and that's what made him my favorite"
        DB	CR
        DB	"character."
        DB	NEXT
        ;	DB	'初心者も扱いやすいキャラとなっているあたり、なかなか侮れない。'
        DB	"He's actually a good character for beginners because some"
        DB	CR
        DB	"of his attacks are very straightforward."
        DB	NEXT
        ;	DB	'説明終わり！ほい、最初の相手は・・・ホンダラか・・・。'
        DB	"Okay, well, time to get on with the game. My first opponent"
        DB	CR
        DB	"is...Hondala."
        DB	NEXT
        ;	DB	'そう言えば、あの子もホンダラ使いで、「マスターホンダラ」って呼ばれてた。'
        DB	"They call that woman Master Hondala got her nickname from"
        DB	CR
        DB	"her expert use of this character."
        DB	NEXT
        ;	DB	'しかし、コンピュータ・ホンダラなんぞ、俺の敵じゃあない。'
        DB	"But this time it's the computer controlling Hondala, so"
        DB	CR
        DB	"it's no challenge for me"
        DB	NEXT
        ;	DB	'・・・秒殺してやる・・・！'
        DB	"I'll crush her!"
        DB	C_BLD,C_V_ON,2		;「ゲームスタート」　消す
        DB	C_BLD,C_V_OFF,3		;「戦う」　出す
        DW	0000H
        
M5:		;戦う
        ;	DB	'「勝負！」'
        DB	"The battle's on!"
        DB	NEXT
        ;	DB	'ピシッ、ゴン、ゴン、ゴン、バキッ！'
        DB	"*BASH BASH BASH*"
        DB	NEXT
        ;	DB	'「せいやァッ」'
        DB	"Back!"
        DB	NEXT,FLASH,4
        ;	DB	'どすん。「一本」'
        DB	"Got you!"
        DB	NEXT
        ;	DB	'・・・ふっ・・・他愛もない・・・'
        DB	"How do you like that, fool?"
        DB	NEXT
        ;	DB	'とか格好つけていたら、画面に『.挑戦者有り！』の文字が踊る。'
        DB	"....But suddenly a message appeared on the screen."
        DB	NEXT
        DB	"A CHALLENGER HAS APPEARED"
        DB	NEXT
        ;	DB	'・・・誰が出るかな、誰が出るかな・・・げ。'
        DB	"Someone wants to fight me. I wonder who it is."
        DB	NEXT
        DB	"I can't see who it is because they're on the other side"
        DB	CR
        DB	"of the game machine, hidden from me."
        DB	NEXT
        ;	DB	'画面に現れたのは「バショウ」と言うキャラクター。'
        DB	"The character my opponent chooses is...'Basho.'"
        DB	NEXT
        ;	DB	'こいつがまた強い。のどかな名前とは裏腹に、もう腹が立つほど強い。'
        DB	"He's strong. He's got a silly name, but he's really powerful."
        DB	NEXT
        ;	DB	'コンピュータ最高レベルのオ○ガル○ール並・・・いや、ひょっとしたらそれより強いかも知れない。'
        DB	"He might even be slightly stronger than the boss at the"
        DB	CR
        DB	"end of the game."
        DB	NEXT
        ;	DB	'初心者でも、たぶんノーミスクリアが可能なくらい強い。'
        DB	"He's a character so strong that even beginners can win with"
        DB	CR
        DB	"him."
        DB	NEXT
        ;	DB	'・・・こいつは、存在が知れた時点で即「禁じ手」扱いされている。'
        DB	"People who play in tournaments are forbidden to use this"
        DB	CR
        DB	"character."
        DB	NEXT
        ;	DB	'そいつを俺の前で使うとは・・・ナイスな度胸だ。'
        DB	".............And now someone is challenging me with this"
        DB	CR
        DB	"character."
        DB	NEXT
        ;	DB	'・・・秒殺してやる・・・！'
        DB	"I'll crush them!"
        DB	FLG,F_COPYI,4,1
        DW	0000H
        
M6:		;戦う
        ;	DB	'「勝負！」'
        DB	"The battle's on!"
        DB	NEXT
        ;	DB	'「獣閃崩壊拳！」'
        DB	"Lightning Destruction Fist!"
        DB	NEXT,FLASH,4
        ;	DB	'ゴガガガガンッ！'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'「せいやァッ！」'
        DB	"Back!"
        DB	NEXT
        ;	DB	'どすん。'
        DB	"*FOOM!*"
        DB	NEXT
        ;	DB	'「獣閃壊襲拳！」'
        DB	"Lightning Destruction Fist!"
        DB	NEXT,FLASH,4
        ;	DB	'ゴスッ！「一本！」'
        DB	"*THOCK!*"
        DB	NEXT
        ;	DB	'ふん・・・他愛もない・・・'
        DB	"No mercy."
        DB	NEXT
        ;	DB	'・・・結局、俺は謎のバショウ使いに２本ストレートで勝った。'
        DB	".......I was able to beat my opponent in no time"
        DB	FLG,F_COPYI,4,2
        DW	0000H
        
M7:		;戦う
        ;	DB	'コンピュータ３人目、「ザン」を軽くひねったところで、再び『挑戦者有り！』の文字が舞う。'
        DB	"Suddenly another message:  A CHALLENGER HAS APPEARED"
        DB	NEXT
        ;	DB	'・・・今度はどいつだ・・・？'
        DB	"............Who's challenging me now?"
        DB	NEXT
        ;	DB	'そう思っていると、筺体の横からいつぞやの強敵が顔を出した。'
        DB	"Suddenly I see a face I recognize peer at me from around"
        DB	CR
        DB	"the game machine."
        DB	NEXT
        E_CG B_SUDA,'AE_045'
        ;	DB	'【女の子】：や、久しぶり！'
        DB	"Woman:  Hi, it's been a while, hasn't it?"
        DB	NEXT
        ;	DB	'【%001】：へ・・・？あ！？'
        DB	"%001:  .............It's you!"
        DB	NEXT
        ;	DB	'【女の子】：さっきから見てたけど、すごいね、前よりずっと強くなってる。'
        DB	"Woman:  I was watching you. You've gotten a lot better than"
        DB	CR
        DB	"before."
        DB	NEXT
        ;	DB	'【%001】：そ・・・そう？'
        DB	"%001:  Really?"
        DB	NEXT
        ;	DB	'【女の子】：うん！'
        DB	"Woman:  Sure!"
        DB	NEXT
        ;	DB	'そんなことを言いながら、彼女は椅子に座りなおすと、キャラクターの選択を済ませた。'
        DB	"She sat back down in her chair and selected her character."
        DB	NEXT
        ;	DB	'・・・もちろん、ホンダラだ。'
        DB	".....Of course she choses Hondala."
        DB	NEXT
        ;	DB	'・・・思わぬ時に再戦の機会が訪れ、一瞬呆けた俺だが、いつまでもぽけぇっとしてはいない。'
        DB	"I had been looking forward to a re-match with her, but now"
        DB	CR
        DB	"I was filled with fear. There was nothing to do though..."
        DB	NEXT
        ;	DB	'・・・やってやる・・・！'
        DB	"I'll crush her!"
        DB	FLG,F_COPYI,4,3
        DB	C_BLD,C_V_OFF,1		;「見る」　出す
        DB	C_BLD,C_N_OFF,1,2	;「見る　女の子」　出す
        DW	0000H
        
M8:		;戦う
        ;	DB	'「勝負！」'
        DB	"The battle's on!"
        DB	NEXT
        ;	DB	'ゴンッ！'
        DB	"*THOCK!*"
        DB	NEXT
        ;	DB	'ピシッ！'
        DB	"*SMACK!*"
        DB	NEXT
        ;	DB	'ガシィ！'
        DB	"*SOCK!*"
        DB	NEXT
        ;	DB	'「獣閃崩壊・・・！」'
        DB	"Lightning Destr-"
        DB	NEXT
        ;	DB	'「死斗襲雷！」'
        DB	"Dragon Death Strike!"
        DB	NEXT
        ;	DB	'【%001】：しまった！！'
        DB	"%001:  Oh no!"
        DB	NEXT,FLASH,4
        ;	DB	'ゴゴゴガガンッ！「一本」！'
        DB	"*FOOM!*"
        DB	NEXT
        ;	DB	'【%001】：く～・・・！'
        DB	"%001:  ............Damn."
        DB	NEXT
        ;	DB	'【女の子】：すごいね、もうちょっとでボクが敗けるとこだった。'
        DB	"Woman:  You're good. You almost had me there."
        DB	NEXT
        ;	DB	'【%001】：次は・・・勝つ！'
        DB	"%001:  I'll get you next time!"
        DB	NEXT
        ;	DB	'【女の子】：ボクだって、敗けないぞ！'
        DB	"Woman:  Only if I let you!"
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・・・・・・・'
        DB	"................................."
        E_CG B_SUDA,"AB_25"
        DB	NEXT
        ;	DB	'結局、終わってみれば、勝率は前より若干良くなった程度で・・・つまり、今回も俺の敗けだった。'
        DB	"In the end, I did slightly better than last time...but"
        DB	CR
        DB	"I still lost."
        DB	NEXT
        ;	DB	'それでも、彼女は俺を讃めてくれた。そして、再戦を約束してくれた。'
        DB	"She did her best to cheer me up. We promised to have a"
        DB	CR
        DB	"re-match later."
        DB	NEXT
        ;	DB	'【%001】：良い戦いだった・・・'
        DB	"%001:  I had fun..."
        DB	NEXT
        DB	SINARIO,'CS807.OVL',0
        DW	0000H
        

end
