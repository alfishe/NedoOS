;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０４＿Ａ
;		鈴子と雨宿り

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

;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	'SKY',0
;NN3:	DB	3,	'洞窟',0
NN3:	DB	3,	'CAVE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　鈴子
S2:		DW	VV1, NN2,  2, M3, M4		;見る　空
S3:		DW	VV1, NN3,  3, M5		;見る　洞窟
S4:		DW	VV2, NN1,  4, M6, M7, M8, M9, M10, M11, M12		;話す　鈴子


;イニシャルメッセージ
M1:
	DB	BGM,29
;	DB	'【鈴子】：あ～あ、びしょびしょ・・・'
	DB	"Reiko:  Ah, we're soaked..."
	DB	NEXT
;	DB	'【%001】：待ってて、今火を起こすから。'
	DB	"%001:  Hang on. I'll make a fire."
	DB	NEXT
;	DB	'俺はライターで小枝に火を付けて、小さな火を起こした。'
	DB	"I took out my lighter and got a small fire going."
	E_CG B_FADE,'AE_017'
	DW	0000H

M2:		;見る　鈴子
;	DB	'雨に濡れて、体操着が透けてる・・・'
	DB	"She's soaked. I can see her bra through her shirt."
	DB	NEXT
;	DB	'【鈴子】：やだ・・・あんまり見ないで。'
	DB	"Reiko:  Hey! Don't look at me...!"
	DB	NEXT
;	DB	'【%001】：ご、ごめん！'
	DB	"%001:  I'm sorry!"
	DW	0000H

M3:		;見る　空
;	DB	'【%001】：こりゃしばらく止みそうにないな。'
	DB	"%001:  It doesn't look like it's going to stop for a while."
	DB	NEXT
;	DB	'【鈴子】：参ったわね・・・いきなり降るんだもの。'
	DB	"Reiko:  What are we going to do?"
	DB	NEXT
;	DB	'【%001】：やむ時もいきなりやむよ。'
	DB	"%001:  We'll just have to wait it out."
	DB	NEXT
;	DB	'【鈴子】：そうね。'
	DB	"Reiko:  You're right."
	DW	0000H

M4:		;見る　空
;	DB	'ふと見ると、いつのまにか青空がひろがっていた。'
	DB	"Suddenly, the sky above us was clearing."
	DW	0000H

M5:		;見る　洞窟
;	DB	'俺達は入り口のすぐ近くにいるが、まだまだ奥に行けそうだ。'
	DB	"We're near the entrance, but the cave seems to go on for"
	DB	CR
	DB	"quite a ways."
	DW	0000H

M6:		;話す　鈴子
;	DB	'【鈴子】：この洞窟、どこまで続いてるのかしら。'
	DB	"Reiko:  I wonder how far this cave goes on for."
	DB	NEXT
;	DB	'【%001】：けっこー、熊の巣穴だったりして。'
	DB	"%001:  Maybe there's a bear back there, waiting to eat us."
	DB	NEXT
;	DB	'【鈴子】：だったら足跡くらい付いてると思うけど。'
	DB	"Reiko:  If so, I'm sure we'd see some tracks on the ground."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M7:		;話す　鈴子
;	DB	'【%001】：奥まで行ってみよーか？'
	DB	"%001:  Do you want to explore the cave?"
	DB	NEXT
;	DB	'【鈴子】：どうせ何もないわよ。'
	DB	"Reiko:  No. I'm sure there's nothing back there."
	DB	NEXT
;	DB	'【%001】：わかんねーよ？白骨死体が放置されてたり・・・'
	DB	"%001:  I don't know. Maybe we can find some bones or something."
	DB	NEXT
;	DB	'【鈴子】：・・・そんなことあるわけないでしょ！'
	DB	"Reiko:  ......Stop that!"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M8:		;話す　鈴子
;	DB	'【鈴子】：みんな、心配してるわね、きっと。'
	DB	"Reiko:  I'll bet everyone's worried about us."
	DB	NEXT
;	DB	'【%001】：雨がやむのを待つしかないよ。'
	DB	"%001:  We'll go back when the rain lets up."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M9:		;話す　鈴子
;	DB	'【鈴子】：そうだ、%001君に聞きたい事があったのよ。'
	DB	"Reiko:  %001, there was something I've wanted to ask you..."
	DB	NEXT
;	DB	'【%001】：・・・悪ィけど、俺水泳だけはどーしてもダメなんだ・・・。'
	DB	"%001:  I'm sorry, I really don't want to join the swimming"

	DB	CR

	DB	"club..."
	DB	NEXT
;	DB	'【鈴子】：違う違う、そーいう話じゃなくって。'
	DB	"Reiko:  No, that's not what I was going to ask..."
	DB	NEXT
;	DB	'【鈴子】：ほら、４月にお花見したじゃない。'
	DB	"Reiko:  Do you remember the cherry blossom viewing party"
	DB	CR
	DB	"back in April?"
	DB	NEXT
;	DB	'【%001】：あれは災難だったよね・・・'
	DB	"%001:  Sure. How could I forget?"
	DB	NEXT
;	DB	'【鈴子】：そうよ、おかげで皆勤を逃しちゃったわ。'
	DB	"Reiko:  I had perfect attendance up to that day, too..."
	DB	NEXT
;	DB	'【鈴子】：いや、そーいう話でもなくて。',CR,'その前の夜に、昔の話をしてくれたじゃない。'
	DB	"Reiko:  Anyway, the night before the party, you said"
	DB	CR
	DB	"something that stuck in my mind."
	DB	NEXT
;	DB	'【鈴子】：あれ、本当の話なんでしょ？',CR,'自分よりすごい奴が現れるまで、何もしないって話。'
	DB	"Reiko:  You said you won't get into any sport or anything"
	DB	CR
	DB	"until you meet someone better than you."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・うん。'
	DB	"%001:  ......I remember."
	DB	FLG,F_COPYI,4,4
	DW	0000H

M10:		;話す　鈴子
;	DB	'【鈴子】：%001君、それって違うと思うわ。'
	DB	"Reiko:  I think that's wrong."
	DB	NEXT
;	DB	'鈴子さんは少し怒ったような顔をした。'
;	DB	"Reiko's wearing a scolding expression on her face."
;	DB	NEXT
;	DB	'【鈴子】：私は水泳を始めてから、沢山「すごい人」に会って来たわ。'
	DB	"Reiko:  I've met a lot of really incredible people, especially ",CR,"since I started swimming."
	DB	NEXT
;	DB	'【鈴子】：地区大会でも、地方大会でも、全国大会でも。',CR,'でもそれは、水泳をやってたから出会えた人ばかりよ。'"
	DB	"Reiko:  If I hadn't gotten involved with swimming, I would"
	DB	CR
	DB	"never have met them."
	DB	NEXT
;;	DB	'【鈴子】：ただ待ってたって、「すごい人」は向こうから来ないわ。'
	DB	"Reiko:  If you just sit around, you won't find anyone who"
	DB	CR
	DB	"impresses you."
	DB	FLG,F_COPYI,4,5
	DW	0000H


M11:		;話す　鈴子
;	DB	'【鈴子】：%001君、野球でもテニスでもいいわ、何か始めるべきよ。世の中には、%001君よりすごい人がいっぱいいるはずよ。'
	DB	"Reiko:  I don't care if it's tennis or baseball, or"
	DB	CR
	DB	"whatever. I think you should get involved with something."
	DB	NEXT
;	DB	'【鈴子】：その中に、君の宿命のライバルもいると思うわ。'
	DB	"Reiko:  If you do, you'll encounter a lot of people who"
	DB	CR
	DB	"really challenge you."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・だけどさ・・・・・・、',CR,'もしそいつがめちゃくちゃヤな奴だったら？'
	DB	"%001:  ...But what if the person I meet is ten times"
	DB	CR
	DB	"better at that sport than I am?"
	DB	NEXT
;	DB	'【鈴子】：そいつより努力して、叩きのめせばいいのよ。',CR,'完膚なきまでにね。'
	DB	"Reiko:  Then you have to work hard and get better than"
	DB	CR
	DB	"they are."
	DB	NEXT
;	DB	'【%001】：・・・それって、空しいよ・・・。'
	DB	"%001:  ...I'm not convinced,though."
	DB	NEXT
;	DB	'【鈴子】：どうして？！'
	DB	"Reiko:  Why not?"
	DB	NEXT
;	DB	'【%001】：・・・誰も喜ばないと思うから。'
	DB	"%001:  I don't know."
	DB	NEXT
;	DB	'そうだよ・・・小学校の時みたいに・・・'
	DB	"%001:  I'm just afraid that everyone will end up hating"
	DB	CR
	DB	"me because I'm better than them... Just like before."
	DB	NEXT
;	DB	'もう、あんな思いは・・・したくない・・・・・・'
	DB	"%001:  I don't want to go through that again..."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ........................"
	DB FLG,F_COPYI,2,1	;見る　空
	DB FLG,F_COPYI,4,6	;見る　空
	DW	0000H

M12:		;話す　鈴子
;	DB	'【%001】：あ。雨、上がってら。'
	DB	"%001:  The rain's letting up."
	DB	NEXT
;	DB	'【鈴子】：え？'
	DB	"Reiko:  It is?"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・っくしゃん！'
	DB	"Reiko:  *ACHOO*!"
	DB	NEXT
;	DB	'【%001】：早く戻って、着替えた方がいいな。'
	DB	"%001:  We'd better get back and change before we catch"
	DB	CR
	DB	"colds."
	DB	NEXT
;	DB	'【鈴子】：ホント、風邪ひいちゃうわね。行きましょ%001君！'
	DB	"Reiko:  Okay. Let's go."
	DB	NEXT
;	DB	'俺達は薪を抱えて、早足でキャンプに戻った。'
	DB	"We picked up the firewood and headed back to camp."
	DB	NEXT
	DB SINARIO,'CS505.OVL',0
	DW	0000H


end