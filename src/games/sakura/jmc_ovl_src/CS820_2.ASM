;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２０＿２
;		イベントの嵐・おかわり！

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'連れ去られる',0
VV4:	DB	4,	'GO WITH THEM',0

;NN1:	DB	1,	'３人',0
NN1:	DB	1,	'THE WOMEN',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　３人
S2:		DW	VV2, -1,  2, M4, M5, M6, M7, M8, M9		;話す
S3:		DW	VV3, -1,  3, M10, M11		;考える
S4:		DW	VV4, -1,  4, M12		;連れ去られる


;イニシャルメッセージ
M1:
	DB	BGM,24
	BAK_INIT "AB_29"
;	DB	'・・・体育祭で最優秀個人賞とやらを受賞した俺は・・・'
	DB	"As punishment for wining the M.V.P. award at the sports"
	DB	CR
	DB	"festival..."
	DB	NEXT
;	DB	'『スペシャルゲスト』と称する晒し者にされてしまい、様々なイベントに「無理矢理」参加させられている。'
	DB	"I'm forced to go around to various events as a special"
	DB	CR
	DB	"guest."
	DB	NEXT
;	DB	'・・・誰か・・・代わって・・・'
	DB	"I don't want to waste my time here!"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','W',0,20,2
	TU_CG 'CT02','W',0,0,3
	T_CG 'CT01','W',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【清美】：さぁ、次のイベントは『超銃戦隊ガンスターズに強力な助っ人登場！新たな仲間と、君も握手だ！』・・・ですわ。'
	DB	"Oh well................."
	DB	NEXT
	DB	"Kiyomi:  The next event is a 'hero show'... You're a"
	DB	CR
	DB	"gun-slinging hero in a stunt group called the Gunstars."
	DB	NEXT
;	DB	'【%001】：・・・・・・なぁ、新藤さん、冗談だろ？'
	DB	"%001:  Kiyomi, you're kidding, right?"
	DB	NEXT
;	DB	'【清美】：いいえ、ここに明記してありますわよ・・・ほら。'
	DB	"Kiyomi:  No, it's written right here. See?"
	DB	NEXT
;	DB	'【%001】：・・・ホントだ・・・'
	DB	"%001:  You're right."
	DB	C_BLD,C_V_ON,4
	DW	0000H

M2:		;見る　３人
;	DB	'さんざん引っ張りまわされたせいか、随分疲れているようだ・・・'
	DB	"They seem tired from all this activity, too."
	DW	0000H

M3:		;見る　３人
;	DB	'ちょっとびっくりしたように、俺を見ている。'
	DB	"They're looking at me with a surprised expression."
	DB	NEXT
;	DB	'・・・そらまぁ、呆れるわなぁ・・・'
	DB	"I wonder why..."
	DW	0000H

M4:		;話す
;	DB	'【美緒】：『新たな仲間』って・・・'
	DB	"Mio:  Their new comrade? I wonder who that is?"
	DB	NEXT
;	DB	'【鈴子】：・・・%001君の事ね。'
	DB	"Reiko:  Maybe %001?"
	DB	NEXT
;	DB	'【%001】：・・・ヤだ・・・それだけは・・・嫌だ・・・'
	DB	"%001:  No, I don't want to go..."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す
;	DB	'【鈴子】：・・・私も、その気持ち、わかるわ・・・'
	DB	"Reiko:  I understand how you feel, %001."
	DB	PAUSE
;	DB	'・・・でも、どうあがいても逃げられないと思うわよ？'
	DB	" But you can't"
	DB	CR
	DB	"run away from your responsibilities."
	DB	NEXT
;	DB	'【%001】：それ・・・どう言うこと・・・？'
	DB	"%001:  .........Why not?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT13","F",0,12,4
;	DB	'【校長】：わはははは、こう言うことだよ、%001君！'
	DB	"Dean:  Ha ha ha, well, how did you like the fishing"
	DB	CR
	DB	"event, %001?"
	DB	NEXT
;	DB	'いつの間に現れたのか、校長先生が背後からがっしりと俺の肩を掴んだ。'
	DB	"The dean put his hand on my shoulder and squeezed."
	DB	NEXT
;	DB	'【%001】：げっ、校長！'
	DB	"%001:  It's the dean!"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す
;	DB	'【校長】：%001君、いや、「デザートイーグル」、私のことは「校長」ではなく「司令」と呼びたまえ。'
	DB	"Dean:  Your code-name is now 'Desert Eagle.' I'm not"
	DB	CR
	DB	"your dean anymore. I'm your commander."
	DB	NEXT
;	DB	'【%001】：・・・な、何を言ってるんで・・・？'
	DB	"%001:  .......What are you talking about, sir?"
	DB	NEXT
;	DB	'【司令】：さ、つべこべ言わずに、来るんだ、「デザートイーグル」！'
	DB	"Commander:  You'll find out. Let's go, Desert Eagle."
	DB	NEXT
;	DB	'【鈴子】：あ、ちょっと！'
	DB	"Reiko:  Wait!"
	DB	NEXT
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【清美】：私たちも行きますわ！'
	DB	"Kiyomi:  We're coming along, too!"
	B_O B_SUDA
	DB	C_BLD,C_V_ON,1		;「見る」　消す
	DB	C_BLD,C_V_ON,2		;「話す」　消す
	DB	C_BLD,C_V_ON,3		;「考える」　消す
	DB	C_BLD,C_V_OFF,4		;「連れ去られる」　出す
	DW	0000H

M7:		;話す
	DB	BUF,B_COPY01
	TU_CG 'CT03','W',0,20,2
	TU_CG 'CT02','W',0,0,3
	T_CG 'CT01','W',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【美緒】：%001先輩、お疲れさま～。はい、ジュース。'
	DB	"Mio:  %001, here you are. Some juice."
	DB	NEXT
;	DB	'【%001】：・・・あ、さんきゅ・・・'
	DB	"%001:  Thanks."
	DB	NEXT
;	DB	'んぐんぐんぐ・・・'
	DB	"*guzzle guzzle*"
	DB	NEXT
;	DB	'【美緒】：先輩って、演技上手いんだね・・・知らなかった。'
	DB	"Mio:  You were really good. I didn't know you had acting"
	DB	CR
	DB	"ability, too."
	DB	NEXT
;	DB	'【%001】：・・・出来れば一生、知りたくなかった・・・'
	DB	"%001:  Me neither. I wish I never found out."
	DB	NEXT
;	DB	'【校長】：うむ、見せてもらったぞ、%001君。'
	DB	"Dean:  You were great, %001."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M8:		;話す
;	DB	'【%001】：・・・校長先生、一つ聞いていいですか？'
	DB	"%001:  Sir, can I ask you something?"
	DB	NEXT
;	DB	'【校長】：ふむ、なにかね？'
	DB	"Dean:  Sure, what?"
	DB	NEXT
;	DB	'【%001】：今日の各イベントのネーミングは、全て校長先生の手によるものですね？'
	DB	"%001:  Did you think up all of these events yourself?"
	DB	NEXT
;	DB	'【校長】：ふむ、君はなかなかいい目を持っているな。'
	DB	"Dean:  ........You're sharp!"
	DB	PAUSE
;	DB	'その通り！どうだね、全てナイスなネーミングだろう？'
	DB	" Yes, they're all my ideas."
	DB	CR
	DB	"Do you like them?"
	DB	NEXT
;	DB	'【%001】：・・・呆れてものが言えねーです。'
	DB	"%001:  I can't put it into words, sir."
	DB	NEXT
;	DB	'【校長】：はっはっは、照れることはないぞ！'
	DB	"Dean:  Ha ha ha! Thanks, son."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M9:		;話す
;	DB	'【清美】：あの・・・%001さん、よろしいでしょうか？'
	DB	"Kiyomi:  Um, can we go on to the next event now?"
	DB	NEXT
;	DB	'【%001】：・・・なぁに？'
	DB	"%001:  What is it?"
	DB	NEXT
;	DB	'【清美】：次の『学園祭恒例爆裂ライブ！俺の歌を聴け！！』がもう間もなく始まりますが・・・？'
	DB	"Kiyomi:  It's a live concert... "
	DB	NEXT
;	DB	'【%001】：・・・なに、それ？'
	DB	"%001:  A concert?"
	DB	NEXT
;	DB	'【清美】：%001さんがゲストヴォーカル、と言うことらしいですわね。'
	DB	"Kiyomi:  Yes, and you're the guest lead vocal."
	DB	NEXT
;	DB	'【%001】：・・・なにいッ！？'
	DB	"%001:  What?!?!"
	DB	NEXT
;	DB	'【校長】：おっと、それには、私も出るんだったな。では、先に行ってるぞ、%001君。遅れずにきたまえ。'
	DB	"Dean:  I'll be on stage, too, %001. I'll see you in"
	DB	CR
	DB	"the concert hall in a few minutes."
	DB	NEXT
	B_O B_SUDA
;	DB	'・・・・・・・・・'
	DB	"..............................................."
	DB	NEXT
;	DB	'その後、俺はとんでもないイベントに幾つも参加し、全てが終わったときには、学園祭一日目だと言うのにぐったりとしていた。'
	DB	"After that, I was in a few more ridiculous events, then"
	DB	CR
	DB	"the first day of the culture festival was over."
	DB	NEXT
;	DB	'体育祭より疲れる学園祭、ってのはウチの学校くらいのモンだろう・・・'
	DB	"Who would have thought I would be more tired after the"
	DB	CR
	DB	"culture festival than the sports festival?"
;	DB	NEXT
;	DB	'・・・ああ、疲れてるのは俺達だけか・・・'
;	DB	"I just want to sleep..."
	DB	NEXT
	BAK_INIT "AB_27_2"
	DB	BUF,B_COPY01
	TU_CG 'CT03','W',0,20,2
	TU_CG 'CT02','W',0,0,3
	T_CG 'CT01','W',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【鈴子】：終わったわね・・・'
	DB	"Reiko:  Well, that's finished."
	DB	NEXT
;	DB	'【清美】：ええ、そうですわね・・・'
	DB	"Kiyomi:  Yes. Thanks, %001."
	DB	NEXT
;	DB	'【美緒】：%001先輩、お疲れさま～。'
	DB	"Mio:  You must be tired."
	DB	NEXT
;	DB	'【%001】：おお～・・・'
	DB	"%001:  I am."
	DB	NEXT
;	DB	'【%001】：・・・そだ、みんな、腹減ってねえ？'
	DB	"%001:  Hey, are you guys hungry?"
	DB	NEXT
;	DB	'【鈴子】：・・・実は、ものすご～く。'
	DB	"Reiko:  I sure am."
	DB	NEXT
;	DB	'【清美】：わたくしも、おなかがペコペコですわ。'
	DB	"Kiyomi:  Me, too. My stomach's growling terribly."
	DB	NEXT
;	DB	'【美緒】：あたしも！'
	DB	"Mio:  Me, too!"
	DB	NEXT
;	DB	'【%001】：・・・だな。うし、ラーメンでも食いに行くか？もちろん、俺の驕りで。'
	DB	"%001:  Let's go get some ramen. I'll treat you all."
	DB	NEXT
;	DB	'【美緒】：え！？'
	DB	"Mio:  You will?"
	DB	NEXT
;	DB	'【鈴子】：ホントに？'
	DB	"Reiko:  Really?"
	DB	NEXT
;	DB	'【%001】：嘘ついてどーすんの。'
	DB	"%001:  Would I lie to you?"
	DB	NEXT
;	DB	'【清美】：まあ、うれしいですわ！'
	DB	"Kiyomi:  I'm so happy!"
	DB	NEXT
;	DB	'【%001】：・・・たかがラーメンだぜ？'
	DB	"%001:  It's just ramen. It's no big deal."
	DB	NEXT
;	DB	'【美緒】：わ～い！%001先輩、行こ行こ！'
	DB	"Mio:  Let's go!"
	DB	NEXT
;	DB	'【%001】：・・・先に言っとくけど、過剰な期待はしないようにな・・・'
	DB	"%001:  Okay."
	DB	NEXT
	DB	SINARIO,'CS821.OVL',0
	DW	0000H

M10:		;考える
;	DB	'えーと、今日は朝から校長先生と対談して・・・'
	DB	"I'm just glad to be finally away from the dean."
	DW	0000H

M11:		;考える
;	DB	'まさか、俺はヒーローショーが楽しかったとか思っているのか？'
	DB	"Though, I have to admit, it was kind of fun to get up"
	DB	CR
	DB	"in front of everyone as their hero."
	DW	0000H

M12:		;連れ去られる
	E_CG B_SUDA,"AB_29"
;	DB	'無理矢理衣装を着せられた俺はあれよあれよと言う間に舞台に上がり、'
;	DB	'気がつけばアドリブで演技していた・・・'
	DB	"Before I knew what was happening, I was dressed in"
	DB	CR
	DB	"outrageous clothes and forced to lip-sync a silly show"
	DB	CR
	DB	"on stage."
	DB	NEXT
;	DB	'【敵将】：わはは、今日こそガンスターズの最後だ！やってしまえ！'
	DB	"Black Snake:  Today I will kill the Gunstars!"
	DB	NEXT
;	DB	'【戦闘員】：ヒョーッ！'
	DB	"Salamander:  Yeah!"
	DB	NEXT
;	DB	'【？】：そこまでだ！'
	DB	"???:  That's far enough!"
	DB	NEXT
;	DB	'【敵将】：な、何奴！'
	DB	"Black Snake:  Who are you?"
	DB	NEXT
;	DB	'【？】：問われて名乗るもおこがましいが・・・'
	DB	"???:  They call me..."
	DB	PAUSE
;	DB	'【デザートイーグル】（以下デザ）：俺の名は、デザートイーグル！'
	DB	"....The Desert Eagle."
	DB	NEXT
;	DB	'【デザ】：ガンスターズ６人目の戦士、只今参上！'
	DB	"Desert Eagle:  I'm the sixth Gunstar."
	DB	NEXT
;	DB	'【敵将】：うぬう、ちょこざいな！返り討ちにしてしまえ！'
	DB	"Black Snake:  Then you'll die with your friends!"
	DB	NEXT
;	DB	'【戦闘員】：ヒョーッ！'
	DB	"Salamandar:  Yeah!"
	DB	NEXT
;	DB	'【デザ】：行くぞっ！バレルオプション・４４アタック！！'
	DB	"Desert Eagle:  Let's go, team! We've got a battle to win!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・'
	DB	"........................................................"
	DB	NEXT
;	DB	'気がつくと、俺は小学校低学年くらいの子供に囲まれ、握手をせがまれて・・・'
	DB	"Suddenly, there were twenty children around me, trying"
	DB	CR
	DB	"to get my autograph."
	DB	NEXT
;	DB	'ようやく解放された頃には、肉体的にはともかく精神的なダメージがかなり蓄積していた。'
	DB	"...Then it was over."
	DB	C_BLD,C_V_OFF,1		;「見る」　出す
	DB	C_BLD,C_V_OFF,2		;「話す」　出す
	DB	C_BLD,C_V_OFF,3		;「考える」　出す
	DB	C_BLD,C_V_ON,4		;「連れ去られる」　消す
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,3
	DB	FLG,F_COPYI,3,1
	DW	0000H


end
