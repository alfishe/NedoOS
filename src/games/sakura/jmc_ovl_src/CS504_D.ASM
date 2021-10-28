;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０４＿Ｄ
;		祥子と雨宿り

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'祥子',0
NN1:	DB	1,	'SHOKO',0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	'SKY',0
;NN3:	DB	3,	'洞窟',0
NN3:	DB	3,	'CAVE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　祥子２
S2:		DW	VV1, NN2,  2, M4, M5		;見る　空２
S3:		DW	VV1, NN3,  3, M6		;見る　洞窟
S4:		DW	VV2, NN1,  4, M7, M8, M9, M10, M11, M12, M13, M14, M15		;話す　祥子９


;イニシャルメッセージ
M1:
	DB	BGM,30
;	DB	'【祥子】：・・・うわ～、こってり濡れ濡れ～。'
	DB	"Shoko:  Oh, I'm so wet!"
	DB	NEXT
;	DB	'【%001】：待ってて、今火を起こすから。'
	DB	"%001:  Hang on, I'll start a fire."
	DB	NEXT
;	DB	'俺はライターで小枝に火を付けて、小さな火を起こした。'
	DB	"I took the firewood and lit it with my lighter."
	E_CG B_WIPE,'AE_019'
	DW	0000H

M2:		;見る　祥子１
;	DB	'雨に濡れて、体操着が透けてる・・・'
	DB	"She's dripping wet. I can see through her P.E. uniform."
	DB	NEXT
;	DB	'【祥子】：ん？しゅ～君どうかしたぁ？'
	DB	"Shoko:  What's wrong? Why are you staring at me?"
	DB	NEXT
;	DB	'【%001】：・・・あ、いや、その、別に・・・'
	DB	"%001:  Hm? Oh, nevermind."
	DB	NEXT
;	DB	'【祥子】：・・・・・・あ、な～んだぁ。'
	DB	"Shoko:  Hmm."
	DB	NEXT
;	DB	'【%001】：ぎく。'
	DB	"%001:  *sideways glance!*"
	DB	NEXT
;	DB	'【祥子】：も～しゅ～君たらぁ・・・見たいんだったらぁ、直接見せてあげるのにぃ～。'
	DB	"Shoko:  Shu-kun, don't be so silly. If you want to look,"
	DB	CR
	DB	"just ask. I'll be happy to show you."
	DB	NEXT
;	DB	'【%001】：うわわわわわっ！ち、ち、違う！'
	DB	"%001:  No! I wasn't looking!"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　祥子２
;	DB	'・・・止めよう。ライター持ってガソリンタンク覗くよーなもんだ。'
	DB	"Let's not bother. Playing with fire's not for me."
	DW	0000H

M4:		;見る　空１
;	DB	'【%001】：こりゃしばらく止みそうにないな。'
	DB	"%001:  The rain's not going to stop for a while."
	DB	NEXT
;	DB	'【祥子】：・・・んふ。'
	DB	"Shoko:  ............Good."
	DB	NEXT
;	DB	'【%001】：（ぞわわわわっ！）な、なに？'
	DB	"%001:  What did you say?"
	DB	NEXT
;	DB	'【祥子】：こんなに降ってたらぁ、だぁれもこないって感じ～。'
	DB	"Shoko:  You know, with it raining like this, no one's"
	DB	CR
	DB	"likely to come by and bother us. You know what I mean?"
	DB	NEXT
;	DB	'【%001】：（ぎくぎくぎくっ！）そ、そ、そんなことはないとおもうけどなあ。'
	DB	"%001:  R- really? I wouldn't say that..."
	DB	NEXT
;	DB	'【祥子】：・・・しゅ～君なんだかぁ、棒読みって感じ～。'
	DB	"Shoko:  Don't you feel like touching me, %001?"
	DB	NEXT
;	DB	'【%001】：や、やだなあ。そんなことはないよハハハ。'
	DB	"%001:  Haha! You say such funny things, Shoko."
	DW	0000H

M5:		;見る　空２
;	DB	'（・・・ラッキー晴れてる！）'
	DB	"......Hey, it's started to clear up. I'm saved!"
	DB	NEXT
;	DB	'【%001】：ほ、ほ、ほら西野さん！雨上がってるよ！'
	DB	"%001:  Look, the rain's stopped. We can go back to camp now."
	DB	NEXT
;	DB	'【祥子】：・・・あっれ～？あんなに降ってたのに～？'
	DB	"Shoko:  What? That's not fair..."
	DB	NEXT
;	DB	'【%001】：じ、じゃあみんなのところに戻ろう！俺、先行ってるから！！'
	DB	"%001:  Well, let's get moving. You can catch up with me."
	DB	CR
	DB	"Bye!"
	DB	NEXT
;	DB	'【祥子】：あん！しゅ～君待って待ってぇ！'
	DB	"Shoko:  Hey, wait up!"
	DB	NEXT
;	DB	'俺は薪を引っ掴むと、全速力でキャンプへと逃げ戻った。'
	DB	"I picked up the firewood and headed back to camp."
	DB	NEXT
	DB	SINARIO,'CS505.OVL',0
	DW	0000H

M6:		;見る　洞窟
;	DB	'俺達は入り口のすぐ近くにいるが、まだまだ奥に行けそうだ。'
	DB	"We're near the entrance, but the cave goes on for quite"
	DB	CR
	DB	"a ways."
	DW	0000H

M7:		;話す　祥子１
;	DB	'【%001】：ふ～っ・・・全くエライ目にあった・・・'
	DB	"%001:  Who would have thought something like this would"
	DB	CR
	DB	"happen?"
	DB	NEXT
;	DB	'【祥子】：あ～ん、ぐしょぐしょで気持ち悪い～。'
	DB	"Shoko:  Yeah. I feel terrible."
	DB	NEXT
;	DB	'【%001】：もっと火の側寄ったら？'
	DB	"%001:  Why don't you come closer to the fire?"
	DB	NEXT
;	DB	'【祥子】：・・・うん、そ～するぅ。'
	DB	"Shoko:  I think I'll do that."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M8:		;話す　祥子２
;	DB	'【%001】：・・・この洞窟、どこまで続いてるのかな？'
	DB	"%001:  I wonder how far this cave goes on?"
	DB	NEXT
;	DB	'【祥子】：あたしわかんな～い。'
	DB	"Shoko:  I don't know."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M9:		;話す　祥子３
;	DB	'【%001】：ちょっと奥まで行って見ようか？'
	DB	"%001:  You want to check it out?"
	DB	NEXT
;	DB	'【祥子】：・・・・・・・・・'
	DB	"Shoko:  .........."
	DB	NEXT
;	DB	'【%001】：・・・な、なに？急に黙っちゃって・・・'
	DB	"%001:  What's the matter? Are you scared or something?"
	DB	NEXT
;	DB	'【祥子】：・・・も～しゅ～君たらぁ、暗い方がいいのぉ？'
	DB	"Shoko:  %001, you want to be alone with me in a dark place?"
	DB	NEXT
;	DB	'【%001】：え゛？'
	DB	"%001:  Huh?"
	DB	FLG,F_COPYI,4,3
	DW	0000H

M10:		;話す　祥子４
;	DB	'【祥子】：じゃあ行こ行こ！'
	DB	"Shoko:  Okay, let's go!"
	DB	NEXT
;	DB	'ぐいっ。'
	DB	"Huh??"
	DB	NEXT
;	DB	'【%001】：ち、ちょっと！？行くってどこにっ！？'
	DB	"%001:  Wait, where are you going?"
	DB	NEXT
;	DB	'【祥子】：うぅんも～、さっきしゅ～君が言ってたじゃなぁい。'
	DB	"Shoko:  Where you just said. Someplace nice and dark."
	DB	NEXT

;	DB	'【%001】：・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【%001】：ちっがーう！誤解だ～～～～～～っ！！'
	DB	"%001:  You're wrong! No, wait!"
	DB	FLG,F_COPYI,4,4
	DW	0000H

M11:		;話す　祥子５
;	DB	'【祥子】：も～しゅ～君たらぁ、照れなくても大丈夫ぅ。'
	DB	"Shoko:  Don't worry, it's all very natural and everything."
	DB	NEXT
;	DB	'【祥子】：だってぇ、今あたし達ってばぁ'
	DB	"Shoko:  After all, we are here all alone."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	NEXT
;	DB	'【%001】：わーっ！ちょっと待って～～～～～～っ！！'
	DB	"%001:  Now wait a minute!"
	DB	NEXT
;	DB	'【祥子】：だぁめ。'
	DB	"Shoko:  Don't bother trying to resist."
	DB	NEXT
;	DB	'【%001】：ひーーーーーーっ！？'
	DB	"%001:  But I..."
	DB	FLG,F_COPYI,4,5
	DW	0000H

M12:		;話す　祥子６
;	DB	'【%001】：に、に、西野さんっ！何で俺なんかに固執するんだよっ！？'
	DB	"%001:  Shoko, why are you so hung up on me?"
	DB	NEXT
;	DB	'【祥子】：だってぇ、『しびびぃ～～～～～～っ！』って感じちゃったしぃ～。'
	DB	"Shoko:  That's simple. You're so cute!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................."
	DB	PAUSE
;	DB	'はい？'
	DB	"I am?"
	DB	FLG,F_COPYI,4,6
	DW	0000H

M13:		;話す　祥子７
;	DB	'【祥子】：だからぁ、しゅ～君見たら『しびびぃ～～～～～～っ！』って'
	DB	"Shoko:  It's hard to explain. I get all tingly when I think"
	DB	CR
	DB	"about you."
	DB	NEXT
;	DB	'【祥子】：これってやっぱりぃ、',CR
	DB	"Shoko:  We were meant to be together."
	DB	PAUSE
;	DB	'「運命ので・あ・い☆」',CR
	DB	" Don't you agree?"
	DB	NEXT
;	DB	'【%001】：・・・・・・そう？'
	DB	"%001:  ..........."
	DB	FLG,F_COPYI,4,7
	DW	0000H

M14:		;話す　祥子８
;	DB	'【祥子】：・・・それじゃあお互い納得したところでぇ、',CR
	DB	"Shoko:  Well, now that we're both in agreement, I guess"
	DB	CR
	DB	"it's time to make love...!!"
	DB	NEXT
;	DB	'【%001】：・・・まて～い！俺は納得してね～ぞっ！'
	DB	"%001:  Wait a minute! I never agreed to anything!"
	DB	FLG,F_COPYI,4,8
	DW	0000H

M15:		;話す　祥子９
;	DB	'【祥子】：しゅ～く～ん、逃げちゃい・や☆'
	DB	"Shoko:  Give up! You can't get away from me again."
	DB	NEXT
;	DB	'【%001】：逃げるわいっ！'
	DB	"%001:  I can try!"
	DB	NEXT
;	DB	'【祥子】：も～、誰も見てないのにぃ。'
	DB	"Shoko:  But we're alone and everything..."
	DB	NEXT
;	DB	'【%001】：そーゆー問題じゃね～っ！！'
	DB	"%001:  That's not the problem!"
	DB	FLG,F_COPYI,2,1
	DW	0000H


end
