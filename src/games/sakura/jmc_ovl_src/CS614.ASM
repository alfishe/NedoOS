;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６１４
;		３日目夜

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN6,NN7,NN8,NN12,NN13,-1
CM3:	DW	VV3,	NN4,NN5,NN6,NN7,NN8,NN9,NN10,NN11,NN12,NN13,NN14,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0

;NN1:	DB	1,	'海',0
NN1:	DB	1,	"OCEAN",0
;NN2:	DB	2,	'月',0
NN2:	DB	2,	"MOON",0
;NN3:	DB	3,	'浜辺',0
NN3:	DB	3,	"BEACH",0
;NN4:	DB	4,	'自分',0
NN4:	DB	4,	"MYSELF",0
;NN5:	DB	5,	'誠',0
NN5:	DB	5,	"MAKOTO",0
;NN6:	DB	6,	'鈴子',0
NN6:	DB	6,	"REIKO",0
;NN7:	DB	7,	'清美',0
NN7:	DB	7,	"KIYOMI",0
;NN8:	DB	8,	'美緒',0
NN8:	DB	8,	"MIO",0
;NN9:	DB	9,	'祥子',0
NN9:	DB	9,	"SHOKO",0
;NN10:	DB	10,	'瑠璃',0
NN10:	DB	10,	"RURI",0
;NN11:	DB	11,	'亜希',0
NN11:	DB	11,	"AKI",0
;NN12:	DB	12,	'星愛',0
NN12:	DB	12,	"SEIA",0
;NN13:	DB	13,	'恵依美',0
NN13:	DB	13,	"MEIMI",0
;NN14:	DB	14,	'校長',0
NN14:	DB	14,	"DEAN",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　海
S2:		DW	VV1, NN2,  2, M3		;見る　月
S3:		DW	VV1, NN3,  3, M4, M5, M6, M7, M8, M9		;見る　浜辺６
S4:		DW	VV3, NN4,  4, M10		;考える　自分
S5:		DW	VV3, NN5,  5, M11		;考える　誠
S6:		DW	VV3, NN6,  6, M12		;考える　鈴子
S7:		DW	VV3, NN7,  7, M13		;考える　清美
S8:		DW	VV3, NN8,  8, M14		;考える　美緒
S9:		DW	VV3, NN9,  9, M15		;考える　祥子
S10:	DW	VV3, NN10,  10, M16, M17		;考える　瑠璃２（二日目に亜希）
S11:	DW	VV3, NN11,  11, M18, M19		;考える　亜希２（二日目に亜希）
S12:	DW	VV3, NN12,  12, M20		;考える　星愛
S13:	DW	VV3, NN13,  13, M21		;考える　恵依美
S14:	DW	VV3, NN14,  14, M22		;考える　校長
S15:	DW	VV2, NN6,  15, M23		;話す　鈴子
S16:	DW	VV2, NN7,  16, M24		;話す　清美
S17:	DW	VV2, NN8,  17, M25		;話す　美緒
S18:	DW	VV2, NN12,  18, M26		;話す　星愛
S19:	DW	VV2, NN13,  19, M27		;話す　恵依美


;イニシャルメッセージ
M1:
	DB	BGM,9
	BAK_INIT 'AB_17_3'
	B_P1 B_FADE
	DB BUF,B_COPY01
;	DB	'晩飯を食って人心地ついた後、俺は何となく浜辺に出てみた。'
	DB	"After dinner, I went out to the beach."
	DB	NEXT
;	DB	'明日の朝にはこことはおさらばだ。そう思うと何となく切なくなって',CR,'来た。'
	DB	"We were leaving the next morning. I felt sad that we had to go."
	DB C_BLD,C_V_ON,2	;話す
	DB G_FLG,G_COPYF,10,159
	DB G_FLG,G_COPYF,11,159
	DW	0000H

M2:		;見る　海
;	DB	'夜の海は暗くておっかない。あんまり近づきたくねーぞ。'
	DB	"The ocean at night looks dark and threatening. I don't"
	DB	CR
	DB	"want to get too close."
	DW	0000H

M3:		;見る　月
;	DB	'今夜は満月だ。'
	DB	"The moon is full."
	DB	NEXT
;	DB	'潮の満ち引きは月と関係があるって、理科で習ったっけ。'
	DB	"That's right, we learned in science that the movement"
	DB	CR
	DB	"of the tide is related to the moon."
	DW	0000H

M4:		;見る　浜辺１
;	DB	'俺以外にも、何人かが出歩いてる。'
	DB	"I certainly wasn't the only one who had come out for a"
	DB	CR
	DB	"walk."
	DB	NEXT
;	DB	'ホントは夜の外出は禁止されてるけどな。'
	DB	"(Even though we weren't really supposed to go outside at"
	DB	CR
	DB	"night.)"
	DW	0000H

M5:		;見る　浜辺２
;	DB	'（ん？あそこにいるの、鈴子さんだ。）'
	DB	"Hm? That looks like Reiko over there."
	DB C_BLD,C_V_OFF,2	;話す
	DB C_BLD,C_N_OFF,2,1	;話す　鈴子
	DB C_BLD,C_N_ON,2,2	;話す　清美
	DB C_BLD,C_N_ON,2,3	;話す　美緒
	DB C_BLD,C_N_ON,2,4	;話す　恵依美
	DB C_BLD,C_N_ON,2,5	;話す　星愛
	DW	0000H

M6:		;見る　浜辺３
;	DB	'（あ！新藤さんがいる・・・。）'
	DB	"Oh! Kiyomi's out here too."
	DB C_BLD,C_V_OFF,2	;話す
	DB C_BLD,C_N_ON,2,1	;話す　鈴子
	DB C_BLD,C_N_OFF,2,2	;話す　清美
	DB C_BLD,C_N_ON,2,3	;話す　美緒
	DB C_BLD,C_N_ON,2,4	;話す　恵依美
	DB C_BLD,C_N_ON,2,5	;話す　星愛
	DW	0000H

M7:		;見る　浜辺４
;	DB	'（あれ・・・美緒ちゃんだ。）'
	DB	"Oh, there's Mio."
	DB C_BLD,C_V_OFF,2	;話す
	DB C_BLD,C_N_ON,2,1	;話す　鈴子
	DB C_BLD,C_N_ON,2,2	;話す　清美
	DB C_BLD,C_N_OFF,2,3	;話す　美緒
	DB C_BLD,C_N_ON,2,4	;話す　恵依美
	DB C_BLD,C_N_ON,2,5	;話す　星愛
	DW	0000H

M8:		;見る　浜辺５
;	DB	'（あれ・・・あそこにいるの、吉田じゃないか？）'
	DB	"Oh, isn't that Seia over there?"
	DB C_BLD,C_V_OFF,2	;話す
	DB C_BLD,C_N_ON,2,1	;話す　鈴子
	DB C_BLD,C_N_ON,2,2	;話す　清美
	DB C_BLD,C_N_ON,2,3	;話す　美緒
	DB C_BLD,C_N_OFF,2,4	;話す　恵依美
	DB C_BLD,C_N_ON,2,5	;話す　星愛
	DW	0000H

M9:		;見る　浜辺６
;	DB	'（あれ、中野だ・・・何してんだ？）'
	DB	"Oh, it's Meimi, I wonder what she's doing?"
	DB C_BLD,C_V_OFF,2	;話す
	DB C_BLD,C_N_ON,2,1	;話す　鈴子
	DB C_BLD,C_N_ON,2,2	;話す　清美
	DB C_BLD,C_N_ON,2,3	;話す　美緒
	DB C_BLD,C_N_ON,2,4	;話す　恵依美
	DB C_BLD,C_N_OFF,2,5	;話す　星愛
	DW	0000H


M10:		;考える　自分
;	DB	'（・・・結局、泳げるようにはならなかったな。）'
	DB	"Well, I didn't learn to swim after all."
	DW	0000H

M11:		;考える　誠
;	DB	'（あいつは遊び疲れてとっとと爆睡しやがった。）'
	DB	"He was so tired from playing volleyball that he went to"
	DB	CR
	DB	"bed early."
	DB	NEXT
;	DB	'（従ってとてもヒマだ。だから俺は外に出てきた。）'
	DB	"So I have plenty of time. That's why I came out here."
	DW	0000H

M12:		;考える　鈴子
;	DB	'（鈴子さんは俺に泳ぎを教えてくれたけど・・・）'
	DB	"Reiko tried to teach me to swim, but..."
	DB	NEXT
;	DB	'（ああ、思い出しただけで恥ずかしい！）'
	DB	"Ugh, just remembering the experience is embarrassing!"
	DB	NEXT
;	DB	'（・・・一番恥ずかしかったのは鈴子さんだな。',CR,'今度もう一度謝っとこう。）'
	DB	"Though I guess the one most embarrassed was Reiko. I'll"
	DB	CR
	DB	"have to apologize to her again."
	DB FLG,F_COPYI,3,1	;見る　浜辺2
	DW	0000H


M13:		;考える　清美
;	DB	'（そう言えば、今日は一度も見掛けなかったな・・・',CR,'どうしたんだろ？）'
	DB	"Come to think of it, I haven't seen her at all today... "
	DB	CR
	DB	"I wonder why?"
	DB	NEXT
;	DB	'（いつもお淑やかな新藤さんが、昨日はずいぶんはしゃいでた・・・',CR,'よっぽど海が好きなんだな。）'
	DB	"Kiyomi is usually so serious, but yesterday she was"
	DB	CR
	DB	"really happy. She seems to like the ocean a lot."
	DB	NEXT
;	DB	'（ずいぶん海の生き物に詳しかったっけ。）'
	DB	"She sure knew a lot about those disgusting sea creatures."
	DB FLG,F_COPYI,3,2	;見る　浜辺３
	DW	0000H

M14:		;考える　美緒
;	DB	'（そーいや、美緒ちゃんもカナヅチだったんだ。でも鈴子さんの',CR,'レクチャーであっとゆー間に泳げるようになったんだな。）'
	DB	"Mio couldn't swim at all either. But after Reiko helped"
	DB	CR
	DB	"her, it seems like she learned in a snap."
	DB	NEXT
;	DB	'（同じカナヅチでも俺と美緒ちゃんじゃ道路工事用のハンマーと',CR,'ピコピコハンマーほどの差があったんだろう。）'
	DB	"Seems that even though we both couldn't swim, the"
	DB	CR
	DB	"difference between us was like night and day."
	DB	NEXT
;	DB	'（ハマグリの塩焼き、美味かったな。',CR,Pause,'シジミの味噌汁も美味かった。）'
	DB	"The clams were really tasty. They were boiled in a miso"
	DB	CR
	DB	"broth that Mio learned how to make from Shinji."
	DB	NEXT
;	DB	'（そーか・・・慎治君を助けたあの時に、美緒ちゃんもいたんだ・・）'
	DB	"I never realized she was there the time I saved Shinji..."
	DB FLG,F_COPYI,3,3	;見る　浜辺４
	DW	0000H

M15:		;考える　祥子
;	DB	'（・・・初日に見掛けたきりだったな。）'
	DB	"I haven't seen her since the first day..."
	DB	NEXT
;	DB	'（・・・次はいつ襲ってくるんだ？）'
	DB	"I wonder when she'll strike next?"
	DB	NEXT
;	DB	'俺は突然背筋が寒くなって、きょろきょろと辺りを見回した。'
	DB	"I felt a chill down my spine, and looked around me furtively."
	DB	NEXT
;	DB	'（すっげー不安・・・）'
	DB	"Man, she makes me nervous..."
	
	DW	0000H

M16:		;考える　瑠璃１（二日目に瑠璃）
;	DB	'（いつ見ても、一人だったな・・・）'
	DB	"Whenever I see her, she's always alone..."

	DB	NEXT
;	DB	'（でも、昨日はたまたま俺達のボートを見つけてくれて、',CR,'持って来てくれたっけ。）'
	DB	"But she rescued the boat for us yesterday, and brought"
	DB	CR
	DB	"it back to us."
	DB	NEXT
;	DB	'（本当は親切で優しい人なんだ、彼女は。そ～に違いねぇ。）'
	DB	"I think she's definitely a kind and good person at heart."
	DW	0000H

M17:		;考える　瑠璃２（二日目に亜希）
;	DB	'（いつ見ても、一人だったな・・・）'
	DB	"Always alone..."
	DB	NEXT
;	DB	'（同じクラスなのに、彼女のことはわからねぇ・・・）'
	DB	"Even though we're in the same class, I don't know"
	DB	CR
	DB	"anything about her."
	
	DW	0000H

M18:		;考える　亜希１（二日目に瑠璃）
;	DB	'（昨日、見掛けたな。何か用事があるとか言ってたが。）'
	DB	"I saw her yesterday. I think she said she had something"
	DB	CR
	DB	"to ask me."
	DB	NEXT
;	DB	'（美緒ちゃんがカナヅチだって聞いて、悪巧みでも考えたのか？）'
	DB	"I wonder what happened with her swimming lessons."
	DW	0000H

M19:		;考える　亜希２（二日目に亜希）
;	DB	'（あの子もカナヅチだったとはな・・・）'
	DB	"So she couldn't swim either..."
	DB	NEXT
;	DB	'（何か俺のまわりって、カナヅチ人口多くねーか？）'
	DB	"Do I attract people who can't swim or something?"
	
	DW	0000H

M20:		;考える　星愛
;	DB	'（吉田もカナヅチだったな。',CR,'今日、鈴子さんに泳ぎを教わったはずだが・・・）'
	DB	"Seia couldn't swim either. I think Reiko was teaching"
	DB	CR
	DB	"her yesterday, though."
	DB	NEXT
;	DB	'（あいつも俺を取り残して泳げる人になったんだろーか？',CR,'スゲー気になる・・・）'
	DB	"I wonder if she's learned too and has left me as the"
	DB	CR
	DB	"only one who can't swim? That would be bad."
	DB FLG,F_COPYI,3,4	;見る　浜辺6
	DW	0000H

M21:		;考える　恵依美
;	DB	'（そういや、さっき何だか怒ってたが・・・）'
	DB	"She was mad about something earlier, wasn't she...?"
	DB	NEXT
;	DB	'（あれって・・・メシの時間になっても俺達が帰ってこなかったからだったのか？）'
	DB	"Hmmm, maybe because we were late for dinner?"
	DB	NEXT
;	DB	'（なんか違うよーな気がして来た。・・・何かあったのか？）'
	DB	"I don't think that was it. I wonder what it was?"
	DB FLG,F_COPYI,3,5	;見る　浜辺5
	DW	0000H

M22:		;考える　校長
;	DB	'（余計な提案したばっかりに沖の小島に捨てられた校長先生・・・）'
	DB	"The poor dean, getting dumped on that island because"
	DB	CR
	DB	"of the teachers."
	DB	NEXT
;	DB	'（・・・晩メシんときには見なかったな・・・）'
	DB	"I didn't see him at dinner."
	DB	NEXT
	DB	".....I hope he got back okay."
	DW	0000H

M23:		;話す　鈴子
	DB SINARIO,'CS615_A.OVL',0

M24:		;話す　清美
	DB SINARIO,'CS615_B.OVL',0

M25:		;話す　美緒
	DB SINARIO,'CS615_C.OVL',0

M26:		;話す　星愛
	DB SINARIO,'CS615_G.OVL',0

M27:		;話す　恵依美
	DB SINARIO,'CS615_H.OVL',0
	DW	0000H


end