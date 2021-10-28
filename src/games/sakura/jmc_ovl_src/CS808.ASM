;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０８
;		体育祭１日前　鈴子とディナー

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'店内',0
NN2:	DB	2,	'RESTAURANT',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　鈴子
S2:		DW	VV1, NN2,  2, M5, M6		;見る　店内
S3:		DW	VV2, NN1,  3, M7, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18		;話す　鈴子１２


;イニシャルメッセージ
M1:
	DB	BGM,29
	BAK_INIT "AB_35"
	DB BUF,B_COPY01
	T_CG "CT01","C",0,0,1
;	DB	'【鈴子】：・・・ここでいい？'
	DB	"Reiko:  Is this place okay?"
	DB	NEXT
;	DB	'【%001】：驕ってくれるんだから、鈴子さんの好きなところでいいよ。'
	DB	"%001:  Since you're treating me, you choose where we'll eat."
	DB	NEXT
;	DB	'【鈴子】：・・・じゃあ、ここにするわね。'
	DB	"Reiko:  Okay, let's go in here."
	DB	PAUSE
;	DB	'・・・すみません、バーガーセットＡにコーラ。'
	DB	" Excuse me, I'd like to order"
	DB	CR
	DB	"burger set A."
	DB	PAUSE
;	DB	'%001君は？'
	DB	" What about you, %001?"
	DB	NEXT
;	DB	'【%001】：同じでいいよ。'
	DB	"%001:  I'll have the same."
	DB	NEXT
;	DB	'【鈴子】：じゃあ、それを二つ。'
	DB	"Reiko:  We'll take two."
	DB	NEXT
;	DB	'【店員】：かしこまりました、バーガーセットＡにコーラをお二つづつですね。少々お待ちください。'
	DB	"Girl:  Thank you very much. That's two orders of burger"
	DB	CR
	DB	"set A. Please wait a moment."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".................."
	DB	NEXT
;	DB	'程なくしてやって来たセットを受け取った俺達は、入口のすぐ近くに陣取った。'
	DB	"Reiko and I took our food and sat down."
	DW	0000H

M2:		;見る　鈴子
;	DB	'なんか、楽しそうだ。'
	DB	"She seems happy tonight."
	DB	NEXT
;	DB	'いいことあったのかな？'
	DB	"I wonder if anything good happened to her."
;	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　鈴子
;	DB	'？なんか、不機嫌そうに見える。'
	DB	"She seems upset about something."
	DB	NEXT
;	DB	'なんか気に障ること言ったかな？'
	DB	"Did I say something wrong?"
;	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　鈴子
;	DB	'黙り込んでしまった。'
	DB	"She got quiet all of the sudden."
	DB	NEXT
;	DB	'・・・ゲームしない人にはつまんない話だよな。'
	DB	"I guess she doesn't care about video games."
	DB	NEXT
	DB	FLG,F_COPYI,101,1
	DW	0000H

M5:		;見る　店内
;	DB	'食事時だけあって、さすがに込み合っている。'
	DB	"It's near dinnertime, so the restaurant's pretty crowded."
	DB	NEXT
;	DB	'立ち席でも開いていただけラッキーだろう。'
	DB	"We're lucky to even have a place to stand up and eat."
;	DB	NEXT
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;見る　店内
;	DB	'『スマイル　￥０』'
	DB	"It says on the menu, 'Smile free.'"
	DB	NEXT
;	DB	'注文してみようか？'
	DB	"Shall I order one?"
	DB	NEXT
;	DB	'・・・鈴子さんの前でそれはやめとこう。'
	DB	"I'd better not in front of Reiko."
	DB	FLG,F_COPYI,102,1
	DW	0000H

M7:		;話す　鈴子１
;	DB	'【鈴子】：ごめんね、立ち席しかなくって。'
	DB	"Reiko:  The restaurant's really crowded. I didn't mean for"
	DB	CR
	DB	"us to have to stand up like this."
	DB	NEXT
;	DB	'【%001】：俺は構わないけど。'
	DB	"%001:  I don't mind."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;話す　鈴子２
;	DB	'【%001】：それにしても、鈴子さんがゲーセンに来るとは思わなかったな。'
	DB	"%001:  I was kind of surprised to see you in the game"
	DB	CR
	DB	"center today."
	DB	NEXT
;	DB	'【鈴子】：そう？'
	DB	"Reiko:  Really?"
	DB	NEXT
;	DB	'【%001】：・・・でもまぁ、さっきの見たら認識変わったよ。'
	DB	"%001:  You really had blood lust in your eyes back there."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・意地悪。'
	DB	"Reiko:  .............Let's drop it, shall we?"
	DB	FLG,F_COPYI,3,2
	DW	0000H

M9:		;話す　鈴子３
;	DB	'【%001】：でも真面目な話、鈴子さんってゲーセンで遊んだりするの？'
	DB	"%001:  Do you like going to game centers?"
	DB	NEXT
;	DB	'【鈴子】：ええ、たま～に行くわよ。大抵は、見てるだけだけど。'
	DB	"Reiko:  Sometimes. I usually just watch, though."
	DB	NEXT
;	DB	'【%001】：でも、すこしはやるんだ？'
	DB	"%001:  But you play them sometimes?"
	DB	NEXT
;	DB	'【鈴子】：ええ・・・スロットマシンとか、コイン落して取る奴とか・・・'
	DB	"Reiko:  Yes. I especially like slot machines, or games like"
	DB	CR
	DB	"that."
	DB	NEXT
;	DB	'【%001】：・・・なるほど。そっちの方面ね。'
	DB	"%001:  I see. So you like gambling."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M10:		;話す　鈴子４
;	DB	'【鈴子】：そう言う%001君は、何をやるの？やっぱりスポーツもの？'
	DB	"Reiko:  How about you, %001? What games do you play? Sports"
	DB	CR
	DB	"games?"
	DB	NEXT
;	DB	'【%001】：ゲーセンにあるものなら、大抵はやってるな。'
	DB	"%001:  Oh, I play them all."
	DB	FLG,F_COPYI,3,4
	DW	0000H

M11:		;話す　鈴子５
;	DB	'【%001】：対戦挌闘ゲーム、略して格ゲー。'
	DB	"%001:  I really like fighting games, though."
	DB	PAUSE
;	DB	'いま一番種類が出ているゲームだよ。'
	DB	" There are"
	DB	CR
	DB	"dozens of fighting games out right now."
	DB	NEXT
;	DB	'【鈴子】：・・・ふ～ん・・・'
	DB	"Reiko:  ..........I didn't know that."
	DB	NEXT
;	DB	'【%001】：簡単に説明すると、画面の中のキャラをレバーとボタンで操作して、殴り合いをさせるんだ。'
	DB	"%001:  In a nutshell, you control the character with the"
	DB	CR
	DB	"buttons and levers, and fight against opponents, each with"
	DB	CR
	DB	"various special attacks."
	DB	NEXT
;	DB	'【鈴子】：・・・よ～するに、喧嘩なの？'
	DB	"Reiko:  I see."
	DB	NEXT
;	DB	'【%001】：まぁそーだね。どっちかって言うと、空手とかボクシングとかの試合に近いけど。'
	DB	"%001:  The action in the games is similar to a karate"
	DB	CR
	DB	"match."
	DB	NEXT
;	DB	'【鈴子】：・・・ふ～ん・・・'
	DB	"Reiko:  ....Oh."
	DB	FLG,F_COPYI,3,5
	DW	0000H

M12:		;話す　鈴子６
;	DB	'【%001】：で、相手はコンピュータが操作してる事もあるし、人間が'
;	DB	'操ってる事もある。'
	DB	"%001:  You can play against the computer or against other"
	DB	CR
	DB	"players."
	DB	NEXT
;	DB	'【鈴子】：・・・あ、それ見た事ある！'
	DB	"Reiko:  I think I've seen machines like that."
	DB	NEXT
;	DB	'【%001】：だろうね。今このタイプのゲーム置いてない店ないから。'
	DB	"%001:  You can see them everywhere these days."
	DB	NEXT
;	DB	'【鈴子】：・・・ふ～ん・・・で、%001君はそれに凝ってるのね？'
	DB	"Reiko:  So you love these fighting games?"
	DB	NEXT
;	DB	'【%001】：そーゆー事。'
	DB	"%001:  Yeah, I guess."
	DB	FLG,F_COPYI,3,6
	DW	0000H

M13:		;話す　鈴子７
;	DB	'【鈴子】：ねえ、面白い？その『掻く毛』って奴。'
	DB	"Reiko:  So what's so great about these games?"
	DB	NEXT
;	DB	'【%001】：ああ、面白いよ。特に、人間とやってる時が１番さ。'
	DB	"%001:  The best is when you play against another human"
	DB	CR
	DB	"opponent."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・私にも、出来るかな？それ。'
	DB	"Reiko:  Would I be able to do that?"
	DB	NEXT
;	DB	'【%001】：ああ、出来ると思うよ。要は、慣れの問題さ・・・'
;	DB	'女の子だって、やたらと強いのいるし。'
	DB	"%001:  Sure. It's just a matter of getting used to the"
	DB	CR
	DB	"controls. Some girls are really good at these games."
	DB	NEXT
;	DB	'【鈴子】：・・・知ってるの？その娘・・・'
	DB	"Reiko:  ..........Do you know any of these girls?"
	DB	NEXT
;	DB	'【%001】：ああ、さっき対戦して来たばっかりさ。凄い腕前なんだぜ、'
;	DB	'なんてったって全国大会優勝者だからな。'
	DB	"%001:  Sure. One just cleaned the floor with me at"
	DB	CR
	DB	"Virtual Ninja 2, just before I saw you."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ......................."
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,3,7
	DW	0000H

M14:		;話す　鈴子８
;	DB	'【%001】：彼女、スゲーんだぜ・・・とにかく、技の正確さと間合いの取り方が並じゃない！'
	DB	"%001:  She's incredible. Her attacks and defenses are all"
	DB	CR
	DB	"perfect."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ..............................."
	DB	NEXT
;	DB	'【%001】：ありゃあきっと、ドット単位で見切ってるな・・・しかも、'
;	DB	'行動が全く型にハマってないんだ。'
	DB	"%001:  There was nothing I could do against her. Her moves"
	DB	CR
	DB	"were just beautiful."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ..............................."
	DB	FLG,F_COPYI,3,8
	DW	0000H

M15:		;話す　鈴子９
;	DB	'【%001】：それに何と言っても、対戦に対する姿勢が最高！'
	DB	"%001:  It was a great fight, even though she creamed me."
	DB	NEXT
;	DB	'【%001】：絶対にハメたりしないし、ある程度は相手のレベルに合わせて戦ってくれる。'
	DB	"%001:  I can't tell you what it was like to fight her. "
	DB	CR
	DB	"Simply breathtaking."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ..............................."
	DB	NEXT
;	DB	'【%001】：彼女は、大したゲーマーだよ・・・そこらに転がっているクソ野郎に、爪の垢でも煎じて飲ませたいね。'
	DB	"%001:  She's a serious gamer. Not like the worthless dreck"
	DB	CR
	DB	"you find hanging out in game centers most of the time."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ..............................."
	DB	FLG,F_COPYI,1,2
	DB	FLG,F_COPYI,3,9
	DW	0000H

M16:		;話す　鈴子１０
;	DB	'【鈴子】：%001君・・・その娘、かわいい？'
	DB	"Reiko:  Is this person...cute?"
	DB	NEXT
;	DB	'【%001】：・・・へ？'
	DB	"%001:  .............Hm?"
	DB	NEXT
;	DB	'【鈴子】：あ！'
	DB	"Reiko:  Ah!"
	DB	PAUSE
;	DB	'・・・ううん、何でもない。'
	DB	".......Um, nevermind."
	DB	NEXT
;	DB	'【%001】：・・・・・・？'
	DB	"%001:  ...................."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ....."
	DB	PAUSE
;	DB	'ご、ごめんなさいね、話の腰折っちゃって・・・'
	DB	"I'm sorry, I interrupted what you were saying."
	DB	PAUSE,CR
;	DB	'それで？'
	DB	"Please continue."
	DB	NEXT
;	DB	'【%001】：・・・・・・え～っと、どこまで話したっけ？'
	DB	"%001:  .....Um, what was I talking about?"
	DB	NEXT
;	DB	'【鈴子】：・・・え～っと・・・'
	DB	"Reiko:  ..............................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..............................."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  ..............................."
	DB	FLG,F_COPYI,3,10
	DW	0000H

M17:		;話す　鈴子１１
;	DB	'【%001】：ごめん・・・知らない人には、つまんない話だったね。'
	DB	"%001:  I'm sorry. I really get into my hobbies."
	DB	NEXT
;	DB	'【鈴子】：あ、ううん、そんな事無いわよ。'
	DB	"Reiko:  No, that's alright."
	DB	PAUSE
;	DB	'・・・ね、%001君。私も、その娘みたいになれるかな？'
	DB	" Hey, could I learn to play video"
	DB	CR
	DB	"games like that person?"
	DB	NEXT
;	DB	'【%001】：・・・うーん、実際にゲームしてるところ見てみないと・・・'
	DB	"%001:  ....Hmm, I'd have to see you playing the game to"
	DB	CR
	DB	"tell for sure..."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・それはそうよね。'
	DB	"Reiko:  Oh, of course."
	DB	FLG,F_COPYI,3,11
	DW	0000H

M18:		;話す　鈴子１２
;	DB	'【鈴子】：・・・%001君、そろそろ出よっか？'
	DB	"Reiko:  %001, let's leave."
	DB	NEXT
;	DB	'【%001】：そうだな。'
	DB	"%001:  Okay."
	DB	NEXT
;	DB	'俺達は紙屑をゴミ箱に放り込み、店を後にした。'
	DB	"We threw our trash away and left the restaurant."
	DB	NEXT
;	DB	'【鈴子】：・・・ね、途中まで一緒に帰りましょうよ。'
	DB	"Reiko:  I'll walk you partway home."
	DB	NEXT
;	DB	'【%001】：ああ、いいよ。'
	DB	"%001:  Okay, thanks."
	DB	NEXT
	DB	SINARIO,'CS809.OVL',0
	DW	0000H


end
