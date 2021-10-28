;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１０
;		体育祭当日

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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0

;NN1:	DB	1,	'みんな',0
NN1:	DB	1,	'EVERYONE',0
;NN2:	DB	2,	'誠',0
NN2:	DB	2,	'MAKOTO',0
;NN3:	DB	3,	'鈴子',0
NN3:	DB	3,	'REIKO',0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	'MIO',0
;NN5:	DB	5,	'清美',0
NN5:	DB	5,	'KIYOMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　みんな
S2:		DW	VV2, NN2,  2, M5		;話す　誠
S3:		DW	VV2, NN3,  3, M6		;話す　鈴子
S4:		DW	VV2, NN4,  4, M7, M8		;話す　美緒
S5:		DW	VV2, NN5,  5, M9		;話す　清美
S6:		DW	VV3, -1,  6, M10		;考える


;イニシャルメッセージ
M1:
	DB	BGM,14
;	DB	'・・・そして、遂に体育祭の日がやって来た。'
	DB	"Finally, the day of the Sports Festival was here."
	DB	NEXT
	BAK_INIT "AB_28"
	DB BUF,B_COPY01
	B_P1 B_SUDA
;	DB	'永かった・・・何度練習の合間に何度「向こう側の世界」を覗いたことか。'
	DB	"It's been a long few weeks. During it all I was never"
	DB	CR
	DB	"able to believe that this day would actually come."
	DB	NEXT
;	DB	'しかし、その苦労もあとは今日と明日の２日間のみ。'
	DB	"All that work, just for these two days."
	DB	NEXT
;	DB	'・・・よし、いくぜッ！！'
	DB	"Well, I'll do my best!"
	DW	0000H

M2:		;見る　みんな
;	DB	'それぞれ、準備は万全のようだ。'
	DB	"Everyone else looks in shape and ready for a good match."
	DB	NEXT
;	DB	'・・・俺も負けちゃいられない。'
	DB	"................But I won't let them beat me."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　みんな
;	DB	'きょろきょろきょろ。'
	DB	"Hmmm...."
	DB	NEXT
	T_CG "CT14","T",0,20,4
;	DB	'【誠】：なんだ、落ち着きのねー奴だな。'
	DB	"Makoto:  Why don't you sit down and relax?"
	DB	NEXT
;	DB	'【%001】：悪かったな、誠。'
	DB	"%001:  You're right."
	DB	NEXT
;	DB	'【誠】：まったく、そんなんで本番大丈夫なのか？'
	DB	"Makoto:  You sure you're ready for this? That's a lot of"
	DB	CR
	DB	"pressure for one person."
	DB	NEXT
;	DB	'【%001】：あったりまえだ、そのために練習したんだからな。'
	DB	"%001:  Of course I'm ready. What was that all that practice"
	DB	CR
	DB	"for?"
	DB	NEXT
;	DB	'【誠】：ああ、そーだな・・・んじゃ、とりあえずは応援してやるぜ。'
	DB	"Makoto:  I guess you're right. I'll be cheering for you"
	DB	CR
	DB	"today."
	DB	NEXT
;	DB	'【%001】：・・・さんきゅ、誠。'
	DB	"%001:  Thanks, Makoto."
	DB	NEXT
;	DB	'【誠】：オレが応援してやるんだ、コケたりしやがったら次のサバ研の演習で標的にしてやるからな。'
	DB	"Makoto:  And if you fuck up and make our class look bad,"
	DB	CR
	DB	"I'll get you back at the next survival club meeting."
	DB	NEXT
;	DB	'【%001】：・・・誠・・・応援するか脅すか・・・どっちかにしようぜ？'
	DB	"%001:  Either support me or threaten me. Make up your"
	DB	CR
	DB	"mind."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　みんな
;	DB	'きょろきょろきょろ。'
	DB	"Hmmm..............."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT02","T",0,0,2
;	DB	'【清美】：どうなさいましたの？%001さん'
	DB	"Kiyomi:  Is anything wrong, %001?"
	DB	NEXT
;	DB	'【%001】：いや・・・なんか落ち着かなくて・・・'
	DB	"%001:  No, I just can't seem to relax. I guess I'm nervous."
	DB	NEXT
	T_CG "CT08","T",0,18,8
	DB ANI,A_ON,2
;	DB	'【恵依美】：もーっ、なっさけないわね！あ・ん・た・は、あんだけ練習したのよ！？もう少し大きく構えて、少しじっとしてなさい！'
	DB	"Meimi:  Why not? What was all that training for? You'll be"
	DB	CR
	DB	"fine."
	DB	NEXT
;	DB	'【%001】：お・・・おう。'
	DB	"%001:  ..........Okay."
	DB	NEXT
	T_CG "CT07","T",0,40,7
	DB ANI,A_ON,8
	DB ANI,A_ON,2
;	DB	'【星愛】：%001さんは限界を超えて人事を尽くしたのですから、自ずと勝利はやってくるはずです。何も心配することはございませんわ。'
	DB	"Seia:  %001 trained so hard, pushing himself to the very"
	DB	CR
	DB	"edge. He'll be fine, now."
	DB	NEXT
;	DB	'【%001】：ああ、さんきゅな、吉田。'
	DB	"%001:  Thanks, Seia."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT03","T",0,0,3
;	DB	'【美緒】：そうだよ、%001先輩頑張ったんだもの！'
	DB	"Mio:  That's right, %001 really trained hard."
	DB	NEXT
	T_CG "CT01","T",0,28,1
	DB ANI,A_ON,3
;	DB	'【鈴子】：そうそう。大丈夫、努力は報われるように出来ているのよ。'
	DB	"Reiko:  Yes. Nothing worth doing comes easy, and this has"
	DB	CR
	DB	"been very difficult for %001 so far."
	DB	NEXT
;	DB	'【%001】：・・・ありがと、美緒ちゃん、鈴子さん。'
	DB	"%001:  Thanks, both of you."
	DB	NEXT
;	DB	'・・・みんな、それぞれに応援してくれている。'
	DB	"......Everyone's hoping I do well at the Sports Festival."
	DB	NEXT
;	DB	'・・・よし、やるぞッッ！！'
	DB	"I can't let them down."
	DW	0000H

M5:		;話す　誠
	DB BUF,B_COPY01
	T_CG "CT14","T",0,20,4
;	DB	'【誠】：・・・おっす、%001。'
	DB	"Makoto:  Yo, %001."
	DB	PAUSE
;	DB	'どうだ？調子の方は。'
	DB	" How do you feel?"
	DB	NEXT
;	DB	'【%001】：おう、誠。'
	DB	"%001:  I'm fine."
	DB	NEXT
;	DB	'【誠】：そうか。'
	DB	"Makoto:  That's good."
	DB	PAUSE
;	DB	'・・・ま、お互い頑張ろうぜ。'
	DB	" Let's both do our best."
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Yeah."
	DW	0000H

M6:		;話す　鈴子
	DB BUF,B_COPY01
	T_CG "CT01","T",0,28,1
;	DB	'【鈴子】：おはよう、%001君。'
	DB	"Reiko:  Good morning, %001."
	DB	NEXT
;	DB	'【%001】：おはよう、鈴子さん。'
	DB	"%001:  Good morning, Reiko."
	DB	NEXT
;	DB	'【鈴子】：・・・どう？身体の調子は？'
	DB	"Reiko:  How are you today? Think you'll be in top"
	DB	CR
	DB	"condition today?"
	DB	NEXT
;	DB	'【%001】：絶好調！'
	DB	"%001:  Of course!"
	DB	NEXT
;	DB	'【鈴子】：そう。じゃあ期待出来そうね。'
	DB	"Reiko:  I'm expecting you to win a lot."
	DB	PAUSE
;	DB	'・・・じゃ、頑張ってね！'
	DB	" Good luck."
	DB	NEXT
;	DB	'【%001】：鈴子さんもね。'
	DB	"%001:  Thanks. You, too."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............................................."
	DB	NEXT
;	DB	'（・・・いつもと同じ鈴子さんだったな。）'
	DB	"She seems the same as always."
	DB	NEXT
;	DB	'（・・・昨日のアレは、一体何だったんだ？）'
	DB	"I wonder what was up with her yesterday."
	DW	0000H

M7:		;話す　美緒
	DB BUF,B_COPY01
	T_CG "CT03","T",0,0,3
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【%001】：やあ、美緒ちゃん。'
	DB	"%001:  Hi, Mio."
	DB	NEXT
;	DB	'【美緒】：ダブルス、頑張ろうね！'
	DB	"Mio:  I'm looking forward to our doubles match."
	DB	NEXT
;	DB	'【%001】：ああ、期待してるぜ。'
	DB	"%001:  Yeah, me too."
	DB	NEXT
	T_CG "CT06","T",0,30,6
;	DB	'【亜希】：・・・あ～ら美緒、随分とご機嫌ね。'
	DB	"Aki:  Hello there, Mio. You seem quite happy this morning."
	DB	NEXT
;	DB	'【美緒】：あ、亜希ちゃん・・・・・・'
	DB	"Mio:  Ah, Aki..."
	DB	NEXT
;	DB	'【亜希】：ど～せあたしは、テニスでは%001先輩と組めませんでしたから。'
	DB	"Aki:  You must be happy to have %001 as your partner."
	DB	NEXT
;	DB	'【美緒】：で・・・でも・・・'
	DB	"Mio:  I won fair and square!"
	DB	PAUSE
;	DB	'「勝った方が%001先輩と組むのよ！」って言ったの亜希ちゃん・・・'
	DB	" We agreed that whoever won"
	DB	CR
	DB	"our match would be %001's partner at doubles."
	DB	NEXT
;	DB	'【亜希】：う、うっさいわね！あんたに言われる筋合いはないわよ！'
	DB	"Aki:  Don't remind me!"
	DB	NEXT
;	DB	'【美緒】：ご、ごめんなさい・・・'
	DB	"Mio:  You're a poor sport."
	DB	NEXT
;	DB	'【%001】：・・・まぁ何だ、亜希ちゃんとは二人三脚では組むんだし・・・'
	DB	"%001:  It'll be okay. I'm paired up with Aki for the three-"
	DB	CR
	DB	"legged race, so it's fair to everyone."
	DB	PAUSE
;	DB	'亜希ちゃん、脚には自信あんだろ？'
	DB	" Can you run fast, Aki?"
	DB	NEXT
;	DB	'【亜希】：もっちろんよ！テニスさえやってなれば、陸上界から引く手あまた！'
	DB	"Aki:  Of course! Anyone who plays tennis has to be fast"
	DB	CR
	DB	"on their feet."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  Okay, well, I guess everything is fine, then."
	DB	NEXT
;	DB	'（・・・でも亜希ちゃんとは、練習してね～んだよな・・・）'
	DB	".........I didn't get in any practice with Aki, now that"
	DB	CR
	DB	"I think of it."
	DB	NEXT
;	DB	'（・・・・・・大丈夫かいな？）'
	DB	"I wonder if we'll be okay."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:		;話す　美緒
	DB BUF,B_COPY01
	T_CG "CT03","T",0,0,3
;	DB	'【美緒】：・・・%001先輩・・・ごめんなさい。'
	DB	"Mio:  %001, don't overdo it today, alright?"
	DB	NEXT
;	DB	'【%001】：ん？なにが？'
	DB	"%001:  I'll be fine. Don't worry."
	DB	NEXT
;	DB	'【美緒】：だって・・・亜希ちゃんが。'
	DB	"Mio:  Okay..."
	DB	NEXT
;	DB	'【%001】：別に美緒ちゃんが謝る事でもないだろ？'
	DB	"%001:  .........Everyone worries so much around here."
	DW	0000H

M9:		;話す　清美
	DB BUF,B_COPY01
	T_CG "CT02","T",0,0,2
;	DB	'【清美】：%001さん、おはようございます。'
	DB	"Kiyomi:  Good morning, %001."
	DB	NEXT
;	DB	'【%001】：・・・よ。'
	DB	"%001:  Morning."
	DB	NEXT
	TU_CG "CT08","T",0,18,8
	T_CG "CT07","T",0,40,7
	DB ANI,A_ON,2
	DB ANI,A_ON,8
;	DB	'【恵依美】：おっはよ～%001！',CR
;	DB	'【星愛】：おはようございます。'
	DB	"Meimi:  Good morning, %001!",CR
	DB	"Seia:  Morning, %001!"
	DB	NEXT
;	DB	'【%001】：おす。'
	DB	"%001:  Hi."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG "CT12","T",0,30,5
;	DB	'【今日子】：おっはよ～皆の衆！今日も元気そうで結構結構！'
	DB	"Kyoko:  Good morning, everyone! You all look so eager this"
	DB	CR
	DB	"morning!"
	DB	PAUSE
;	DB	'そろそろ開会式やるからぁ、ちゃっちゃっと並んじゃってちょ～だい！'
	DB	" Okay, everyone line up, please!"
	DB	NEXT
;	DB	'・・・かくして、体育祭の幕は切って落された。'
	DB	"The Sports Festival had begun."
	DB	NEXT
	DB	SINARIO,'CS810_1.OVL',0

M10:		;考える
;	DB	'が、がらにもなく緊張している。'
	DB	"I'm still feeling a little nervous..."
	DB	NEXT
;	DB	'それは、みんなが俺に期待しているからじゃない。'
	DB	"I mean, everyone's really rooting for me, hoping I'll"
	DB	CR
	DB	"do well."
	DB	NEXT
;	DB	'・・・だから、緊張してはいるけれど・・・'
	DB	"I keep thinking about it, and it's keeping me from"
	DB	CR
	DB	"relaxing."
	DB	NEXT
;	DB	'・・・俺は、実力を１００％発揮することができると思う。'
	DB	"I've got to do my best!"
	DW	0000H


end
