;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２４＿２
;		学園祭２日目　

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8
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
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,-1
CM2:	DW	VV2,	NN5,-1
CM3:	DW	VV3,	NN6,-1
CM4:	DW	VV4,	NN5,NN7,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'買う',0
VV3:	DB	3,	'BUY',0
;VV4:	DB	4,	'撃つ',0
VV4:	DB	4,	'SHOOT',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'清美',0
NN2:	DB	2,	'KIYOMI',0
;NN3:	DB	3,	'美緒',0
NN3:	DB	3,	'MIO',0
;NN4:	DB	4,	'射的場',0
NN4:	DB	4,	'SHOOTING RANGE',0
;NN5:	DB	5,	'誠',0
NN5:	DB	5,	'MAKOTO',0
;NN6:	DB	6,	'弾',0
NN6:	DB	6,	'BULLETS',0
;NN7:	DB	7,	'的',0
NN7:	DB	7,	'TARGET',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　鈴子
S2:		DW	VV1, NN2,  2, M4, M5		;見る　清美
S3:		DW	VV1, NN3,  3, M6, M7		;見る　美緒
S4:		DW	VV1, NN4,  4, M8		;見る　射的場
S5:		DW	VV2, NN5,  5, M9, M10		;話す　誠
S6:		DW	VV3, NN6,  6, M11		;買う　弾
S7:		DW	VV4, NN5,  7, M12		;撃つ　誠
S8:		DW	VV4, NN7,  8, M13, M14		;撃つ　的


;イニシャルメッセージ
M1:
	DB	BGM,24
	BAK_INIT "AB_29"
	B_P1 B_SUDA
;	DB	'【？】：わはははは！'
	DB	"???:  Wah ha ha ha!"
	DB	NEXT
;	DB	'恐る恐る声のした方を見ると、そこではあの悪夢のヒーローショーが行われていた。'
	DB	"I turned suddenly to see the weird hero show I was in"
	DB	CR
	DB	"yesterday."
	DB	NEXT
;	DB	'昨日俺がやった「デザートイーグル」の姿も見える。'
	DB	"I could see the new 'Desert Eagle,' too."
	DB	NEXT
;	DB	'うまいこと代役が見つかったらしいが・・・'
	DB	"That guy's not as good as I was yesterday."
	DB	NEXT
;	DB	'・・・てんでなっちゃいない。違う、腕はもっとまっすぐ伸ばせ！'
	DB	"Where did they get this guy? He's only five feet tall!"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','C',0,20,2
	TU_CG 'CT02','C',0,0,3
	T_CG 'CT01','C',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【清美】：あの・・・どうなさいました？'
	DB	"Kiyomi:  Um, is anything wrong?"
	DB	NEXT
;	DB	'【%001】：いっ、いやっ、別にっ、なんでもないよっ。'
	DB	"%001:  Huh? Oh, no, everything's fine."
	DB	NEXT
;	DB	'【鈴子】：・・・？まあ、いいじゃない。それより、清美ちゃん、どこ行くの？'
	DB	"Reiko:  Okay, what's next on the schedule, Kiyomi?"
	DB	NEXT
;	DB	'【清美】：ええ、あれですわ。'
	DB	"Kiyomi:  It's right over there."
	DB	NEXT
;	DB	'そう言って新藤さんが指さしたのは、グラウンドの一角に設置された射的コーナーだった。'
	DB	"Kiyomi pointed to a shooting target placed in one corner"
	DB	CR
	DB	"of the schoolyard."
	DB	C_BLD,C_N_ON,1,1
	DB	C_BLD,C_N_ON,1,2
	DB	C_BLD,C_N_ON,1,3
	DB	C_BLD,C_V_ON,2
	DB	C_BLD,C_V_ON,3
	DB	C_BLD,C_V_ON,4
	DW	0000H

M2:		;見る　鈴子
;	DB	'すでに弾を買っている。'
	DB	"She's already buying bullets."
	DB	NEXT
;	DB	'・・・素早い。'
	DB	"........That woman is fast."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　鈴子
;	DB	'何狙ってるんだろ？'
	DB	"I wonder what she wants to win?"
	DB	NEXT
;	DB	'『ウラヌス』・・・まさかな・・・'
	DB	"Could she be trying for the Uranus game system?"
	DB	NEXT
;	DB	'きっとぬいぐるみだろう。'
	DB	"I'll bet some kind of stuffed animal. She's such a silly"
	DB	CR
	DB	"woman."
	DW	0000H

M4:		;見る　清美
;	DB	'新藤さんもやるみたいだ。'
	DB	"Kiyomi wants to try, too."
	DB	NEXT
;	DB	'・・・げ、ここ、コルク鉄砲じゃないんだ？'
	DB	"Wait a minute. You mean this isn't one of those games"
	DB	CR
	DB	"where you shoot a cork at a prize?"
	DB	NEXT
;	DB	'・・・なんか、フルオートライフル渡されてるぞ・・・'
	DB	"They're handing out full automatic rifles!"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;見る　清美
;	DB	'何狙ってんだろ？'
	DB	"What's she trying for?"
	DB	NEXT
;	DB	'・・・ぬいぐるみかな？'
	DB	"A teddy bear or something?"
	DW	0000H

M6:		;見る　美緒
;	DB	'美緒ちゃんもやるんだ。'
	DB	"Mio's going to try."
	DB	NEXT
;	DB	'しかし、美緒ちゃんにフルオートライフル・・・'
	DB	"But Mio, with a full automatic rifle?"
	DB	NEXT
;	DB	'・・・似合わん・・・'
	DB	"I can't see it, for some reason."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M7:		;見る　美緒
;	DB	'何狙ってんだろ？'
	DB	"What's she trying for?"
	DB	NEXT
;	DB	'・・・その前に、ライフルの反動が邪魔して狙いが付けにくいようだ。'
	DB	"......The recoil from the weapon is interfering with her"
	DB	CR
	DB	"aim."
	DB	NEXT
;	DB	'・・・なんか、見てて微笑ましいぞ。'
	DB	"What's happening to everyone?"
	DW	0000H

M8:		;見る　射的場
;	DB	'まあ、どこにでもありそうな普通の射的だよな。'
	DB	"It's just a normal target range like you'd expect to"
	DB	CR
	DB	"find anywhere."
	DB	NEXT
;	DB	'景品もいたって普通・・・ぬいぐるみ、お菓子、それに、次世代ゲーム機『ウラヌス』。'
	DB	"The prizes are all normal,too. Stuffed animals, candy,"
	DB	CR
	DB	"a Zega Uranus game system."
	DB	NEXT
;	DB	'まあ、どこにでもありそうなモンだ。'
	DB	"All perfectly normal."
	DB	NEXT
;	DB	'・・・・・・なにっ！？『ウラヌス』！？'
	DB	"Wait a minute! A Uranus game system?!"
	DB	NEXT
;	DB	'あの、自社ハードも販売している有名ゲームメーカーが通算７台目のハードとして開発した、６４ビット級の化け物だ。'
	DB	"It's the newest game system on the market, with 64 bits"
	DB	CR
	DB	"of power."
	DB	NEXT
;	DB	'そんなものがなぜ学園祭の射的場に景品として置かれているんだ！？'
	DB	"Why is something like that a prize at our school's culture"
	DB	CR
	DB	"festival?"
	DB	NEXT
;	DB	'よっしゃあ、『ウラヌス』、もらったぜ！'
	DB	"Okay, I know what I'm going to try for!"
	DB	C_BLD,C_N_OFF,1,1
	DB	C_BLD,C_N_OFF,1,2
	DB	C_BLD,C_N_OFF,1,3
	DB	C_BLD,C_V_OFF,3
	DB	C_BLD,C_N_ON,1,4
	DW	0000H

M9:		;話す　誠
;	DB	'【%001】：・・・ここ、サバ研の店か？'
	DB	"%001:  Is this shooting range put on by the survival club?"
	DB	NEXT
;	DB	'【誠】：ああ、そうだぜ。'
	DB	"Makoto:  That's right."
	DB	NEXT
;	DB	'【%001】：・・・なんで、『ウラヌス』なんてとんでもないモンが置いてあるんだ？'
	DB	"%001:  Why is there a Uranus game system up there?"
	DB	NEXT
;	DB	'【誠】：とられる心配がないから。見てみ、ほれ。'
	DB	"Makoto:  We're not worried that anyone's going to get"
	DB	CR
	DB	"it. Take a look..."
	DB	NEXT
;	DB	'・・・鈴子さん、新藤さん、美緒ちゃんが銃の反動に翻弄されている。'
	DB	"All three women were having trouble shooting straight"
	DB	CR
	DB	"because of the recoil from their weapons."
	DB	NEXT
;	DB	'オートライフルは暴れ馬のように跳ねまわり、一向に安定しようとしない。'
	DB	"An automatic rifle is a difficult thing to aim."
	DB	NEXT
;	DB	'【%001】：でも、まぐれで当たることもあるんじゃねえのか？'
	DB	"%001:  What if they hit the target accidentally?"
	DB	NEXT
;	DB	'【誠】：当たっても、倒れなきゃいいんだ。わかるか、この意味？'
	DB	"Makoto:  They have to knock over the prize they want to"
	DB	CR
	DB	"win, but that won't be so easy with these prizes. Do you"
	DB	CR
	DB	"get my meaning?"
	DB	NEXT
;	DB	'【%001】：・・・それ、詐欺じゃねえか！？'
	DB	"%001:  .........Are you trying to cheat people?"
	DB	NEXT
;	DB	'【誠】：詐欺もなんも、ウチは別に「当たれば必ず倒れる」とは言ってねえぜ？'
	DB	"Makoto:  I didn't say we were cheating. All I mean is,"
	DB	CR
	DB	"just because you hit your target, doesn't mean it will"
	DB	CR
	DB	"fall over."
	DB	NEXT
;	DB	'【%001】：・・・悪魔か、お前は！？'
	DB	"%001:  You're terrible!"
	DB	C_BLD,C_V_OFF,4
	DW	0000H

M10:		;話す　誠
;	DB	'【%001】：さ、倒れたぜ。約束通り、もらってこうか！'
	DB	"%001:  That'll be one Uranus game system, thank you!"
	DB	NEXT
;	DB	'【誠】：くっ、やるな・・・ちきしょう、覚えてやがれ！'
	DB	"Makoto:  Y- You'll be sorry! We won't forget this!"
	DB	NEXT
;	DB	'【%001】：捨てぜりふはいいから、ほれ、『ウラヌス』よこせ。'
	DB	"%001:  Yes, yes. Hurry up with the game system."
	DB	NEXT
;	DB	'【誠】：・・・これから毎日、お前のウチに入り浸ってやる。'
	DB	"Makoto:  I'm going to sneak into your house and wait for"
	DB	CR
	DB	"you when you least expect it. You'll see!"
	DB	NEXT
;	DB	'【%001】：遠慮しとくよ。じゃーな。'
	DB	"%001:  I don't look forward to that. I'll see you later."
	DB	NEXT
;	DB	'【鈴子】：%001君、ほら見て！すごいでしょ！'
	DB	"Reiko:  %001, look what I got!"
	DB	NEXT
;	DB	'【%001】：へぇ・・・よく、あの銃で捕れたねえ・・・'
	DB	"%001:  That's great."
	DB	NEXT
;	DB	'【清美】：わたくしも、取りましたのよ！'
	DB	"Kiyomi:  I got a prize, too!"
	DB	NEXT
;	DB	'【%001】：新藤さんも？'
	DB	"%001:  You did? Great!"
	DB	NEXT
;	DB	'【美緒】：%001先輩、あたしも！'
	DB	"Mio:  And me, too!"
	DB	NEXT
;	DB	'【%001】：うわ、３人とも俺より取ってるな。俺はこんだけ。'
	DB	"%001:  Wow, you all won something! I just got this game"
	DB	CR
	DB	"system here."
	DB	NEXT
;	DB	'【美緒】：ううん！あたし、ただ撃ってただけだもん！'
	DB	"Mio:  I just fired all my rounds at once."
	DB	NEXT
;	DB	'【鈴子】：そーそー。実はこれ、３人とも誰がどれを取ったかわかんなくなったから・・・'
	DB	"Reiko:  Me, too. I wasn't sure what I would hit."
	DB	NEXT
;	DB	'【清美】：とりあえず、倒れた景品を３人で山分けいたしましたの。'
	DB	"Kiyomi:  We just divided up the prizes between the three"
	DB	CR
	DB	"of us."
	DB	NEXT
;	DB	'【美緒】：それより先輩、お昼にしようよ！'
	DB	"Mio:  Well, shall we have lunch?"
	DB	NEXT
;	DB	'【%001】：ああ、そーだな。'
	DB	"%001:  Ah, good idea."
	DB	NEXT
;	DB	'こうして、とりあえず戦利品をえた俺は、流れ弾の犠牲となったぬいぐるみやお菓子（『ウラヌス』以外には特に仕掛けはなかったらしい）を抱えた鈴子さん達とともに、その場を後にした。'
	DB	"With that, the four of us took our spoils of war and"
	DB	CR
	DB	"went off."
	DB	NEXT
	DB	SINARIO,'CS822.OVL',0
	DW	0000H

M11:		;買う　弾
;	DB	'【%001】：一回分くれ。'
	DB	"%001:  I'd like one clip."
	DB	NEXT
;	DB	'【誠】：ハイよ！弾は二百発、反動大きいから気を付けて！'
	DB	"Makoto:  Here you go. One clip holds two hundred rounds."
	DB	CR
	DB	"The recoil is really strong, so be careful."
	DB	NEXT
;	DB	'【%001】：おう・・・って、誠ぉ！？'
	DB	"%001:  Are you sure this is safe, Makoto?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT14","C",0,0,4
;	DB	'【誠】：ん？おお、%001じゃねーか。気付かなんだ。'
	DB	"Makoto:  Reasonably safe. Be careful with that gun. "
	DB	CR
	DB	"We've modified it quite a bit."
	DB	NEXT
;	DB	'【%001】：・・・なあ、それって犯罪じゃねーか？'
	DB	"%001:  Isn't that illegal?"
	DB	NEXT
;	DB	'【誠】：あのなあ、%001。男がこだわりもっていいのはガンだけだぜ？その他の小さいことなんか、気にすんな。'
	DB	"Makoto:  There's nothing closer to a man's heart than"
	DB	CR
	DB	"his weapons, %001. I'm sure you'll never understand."
	DB	C_BLD,C_V_OFF,2
	DB	C_BLD,C_V_ON,3
	DW	0000H

M12:		;撃つ　誠
;	DB	'・・・撃ちたいのは山々だけど・・・'
	DB	"I want to shoot him. I won't deny it."
	DB	NEXT
;	DB	'たぶん、しゃれになんないからやめとこう。'
	DB	"It wouldn't be nice, though."
	DW	0000H

M13:		;撃つ　的
	B_O B_SUDA
;	DB	'・・・とりあえず、しっかり狙って・・・'
	DB	"Take careful aim..."
	DB	NEXT
;	DB	'引き金を・・・引く！'
	DB	"And squeeze the trigger!"
	DB	NEXT,FLASH,5
;	DB	'だららら！'
	DB	"*BAM BAM BAM BAM*"
	DB	NEXT
;	DB	'【%001】：おわっ！？'
	DB	"%001:  Wow!"
	DB	NEXT
;	DB	'ものすごい反動だ。最初の一発以外は全てあらぬ方向へととんでいってしまった。'
	DB	"You're right, the recoil is incredibly strong."
	DB	NEXT
;	DB	'【%001】：・・・つ、次こそ・・・！'
	DB	"%001:  I'll get it this time..."
	DB	NEXT
;	DB	'【誠】：無理無理。'
	DB	"Makoto:  Impossible."
	DB	NEXT
;	DB	'【%001】：・・・こんなんで撃って、『ウラヌス』は大丈夫なのか？'
	DB	"%001:  Is it really okay to shoot the Uranus game system?"
	DB	CR
	DB	"Won't it get damaged?"
	DB	NEXT
;	DB	'【誠】：心配ご無用、あの箱の内側に、鉄板しこんであるから。'
	DB	"Makoto:  We've encased the contents of the box with"
	DB	CR
	DB	"steel plates."
	DB	NEXT
;	DB	'【%001】：・・・あ、そ。それなら・・・いいのか？'
	DB	"%001:  Oh."
	DB	FLG,F_COPYI,8,1
	DW	0000H

M14:		;撃つ　的
;	DB	'【%001】：いっけえぇ！！'
	DB	"%001:  Fire!"
	DB	NEXT,FLASH,10
;	DB	'どらだだだだだだだだだだだだだだだだだだだだだだ・・・！！'
	DB	"*BABABABABABABABABABA*"
	DB	NEXT
;	DB	'一度、どれくらい暴れるかを身体で体験したのは良かったらしい。'
	DB	"Automatic rounds fill the air in front of me."
	DB	PAUSE
;	DB	'全身でしっかりと押さえ込まれたカスタムライフル（撃ってる感覚はガトリングガン）は『ウラヌス』に向けて火線（？）を集中させる。'
	DB	" I directed the"
	DB	CR
	DB	"spew of flame at the Uranus game system."
	DB	NEXT
;	DB	'【誠】：・・・おいおいおい、ホントかよ！'
	DB	"Makoto:  I don't believe it!"
	DB	NEXT
;	DB	'なんか誠が言ってるけど、銃の作動音がうるさくて全然聞こえない。'
	DB	"Makoto is saying something, but I can't hear him over"
	DB	CR
	DB	"the roar of my weapon."
	DB	NEXT
;	DB	'【誠】：なにっ！？'
	DB	"Makoto:  What?"
	DB	NEXT
;	DB	'どうやら、客が扱えきれないほどに強化したライフルが仇になったようだ。'
	DB	"It appeared that I had been given an rifle many times"
	DB	CR
	DB	"stronger than the ones the others were using."
	DB	NEXT
;	DB	'つっかえ棒が折れた『ウラヌス』は、マシンガンが最後の弾丸を撃ち終わる前に、向こう側へと倒れていった。'
	DB	"The last bullet from my clip managed to knock the Uranus"
	DB	CR
	DB	"box off of its pedestal."
	DB	NEXT
;	DB	'【誠】：そんな・・・俺のなけなしの小遣いが・・・'
	DB	"Makoto:  No! I wanted it for myself!"
	DB	NEXT
;	DB	'誠ががっくりと膝を落とす。'
	DB	"Makoto dropped to his knees in shock."
	DB	FLG,F_COPYI,5,1
	DB	C_BLD,C_V_ON,4
	DW	0000H


end