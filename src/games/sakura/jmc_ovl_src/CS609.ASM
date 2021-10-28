;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０９
;		二日目夜　浜辺

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
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'浜辺',0
NN1:	DB	1,	"BEACH",0
;NN2:	DB	2,	'校長',0
NN2:	DB	2,	"DEAN",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　浜辺
S2:		DW	VV1, NN2,  2, M4		;見る　校長
S3:		DW	VV2, -1,  3, M5, M6, M7		;話す


;イニシャルメッセージ
M1:
	DB	BGM,2
	BAK_INIT "AB_17_2"
	DB	BUF,B_COPY01
	T_CG "CT02","M",0,40,1
;	DB	'【%001】：腹減った、メシメシ～。'
	DB	"%001:  I'm starving."
	DB	NEXT
;	DB	'【清美】：わたくしもおなかペコペコですわ。'
	DB	"Kiyomi:  I'm really hungry too."
	DB C_BLD,C_V_ON,2		;話す
	DB	C_BLD,C_N_ON,1,2	;見る　校長
	DW	0000H

M2:		;見る　浜辺
;	DB	'【清美】：%001さん、あちらに鈴子さんと美緒さんがいらっしゃいますわ。'
	DB	"Kiyomi:  Look, %001, there are Reiko and Mio."
	DB	NEXT
;	DB	'【美緒】：せんぱ～い！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'美緒ちゃんがぶんぶんと手を振っている。'
	DB	"Mio waved at us frantically."
	DB	NEXT
;	DB	'俺達は鈴子さんと美緒ちゃんのいる場所に向かった。'
	DB	"We turned to face where Mio and Reiko were."
	TU_CG "CT03","M",0,13,3		;美緒
	T_CG "CT01","M",0,0,2		;鈴子
	DB	BUF,B_COPY10
	DB	ANI,A_ON,1
	DB	ANI,A_ON,3
	DB C_BLD,C_V_OFF,2		;話す
	DB	FLG,F_COPYI,1,1
	DW	0000H


M3:		;見る　浜辺
;	DB	'みんなぞろぞろと宿に引き返して行く。'
	DB	"Everybody was flocking back to the lodge."
	DW	0000H

M4:		;見る　校長
;	DB	'俺の背後にいたのは、他でもない校長先生だった。'
	DB	"Right behind me was none other than the dean himself."
	DB	NEXT
;	DB	'神出鬼没だな、この人。'
	DB	"He always just pops out of nowhere."
	DW	0000H

M5:		;話す
;	DB	'【美緒】：二人とも、どこに行ってたの？'
	DB	"Mio:  So where did you two go?"
	DB	NEXT
;	DB	'【%001】：そこの小島まで行って遊んでたんだ。'
	DB	"%001:  We went over to that little island."
	DB	NEXT
;	DB	'【清美】：お二人の方はどうでしたか？'
	DB	"Kiyomi:  How did the swimming lessons go?"
	DB	NEXT
;	DB	'【鈴子】：それが、息継ぎの仕方を教えたらもうスイスイよ。'
	DB	"Reiko:  Well, she's mastered her breathing."
	DB	NEXT
;	DB	'【美緒】：あたし今まで息継ぎの度に水飲んでたから・・・',CR,'でも、鈴子先輩に教えてもらったから泳げるようになったの！'
	DB	"Mio:  I'd always just swallow water before, but thanks"
	DB	CR
	DB	"to Reiko, I can swim properly now!"
	DB	NEXT
;	DB	'【鈴子】：%001君とは天と地の開きがあるわね～。',CR,'美緒ちゃん、水泳部に入る気ない？'
	DB	"Reiko:  There's definitely a big difference between %001"
	DB	CR
	DB	"and Mio. Mio, want to try out for the swim team?"
	DB	NEXT
;	DB	'【美緒】：あたしはテニス一筋だから・・・'
	DB	"Mio:  Well, I'm kind of married to tennis..."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M6:		;話す
;	DB	'【清美】：しかし、この前の林間学校といい、今回の臨海学校といい自由時間ばっかりですわよね。'
	DB	"Kiyomi:  It seems really strange that on our camping"
	DB	CR
	DB	"trip, and now this one, we've had nothing but free time."
	DB	NEXT
;	DB	'【%001】：そーだな。臨海学校って言えば、全員参加の遠泳とかありそうなもんだが。'
	DB	"%001:  Yeah, you'd think that there would be a swimming"
	DB	CR
	DB	"meet that everybody had to be in or something."
	DB	NEXT
	E_CG B_NORM,"AB_17_2"
	T_CG1 "CT13","F",0,15,5
;	DB	'【校長】：よし、やろう。'
	DB	"Dean:  What a fine idea!"
	DB	NEXT
;	DB	'【美緒】：わっ！校長先生！'
	DB	"Mio:  Ack! The dean!"
	DB	NEXT
;	DB	'【鈴子】：いつのまに・・・'
	DB	"Reiko:  When did he...?"
	DB	NEXT
;	DB	'【校長】：まさか泳げない君からそんな台詞が聞けるとは思ってなかったぞ、%001君。'
	DB	"Dean:  Well, I certainly didn't expect a non-swimmer"
	DB	CR
	DB	"like you to suggest something like that, %001."
	DB	NEXT
;	DB	'【%001】：俺も校長先生がこんな所にいるとは思ってませんでした。'
	DB	"%001:  Well, I also didn't think you were anywhere close"
	DB	CR
	DB	"by!"
	DB	NEXT
;	DB	'【%001】：・・・何で校長先生まで俺がカナヅチだって知ってるんですか？'
	DB	"%001:  How is it that you know I can't swim?"
	DB	NEXT
;	DB	'【校長】：おや？何でも何も、私は・・・'
	DB	"Dean:  Me? Oh, I have my ways..."
	DB	NEXT
;	DB	'【鈴子】：あーっこっ校長先生、今日もダンディですわね！'
	DB	"Reiko:  Wow, you sure look sharp again today, sir!"
	DB	NEXT
	K_CG "CT13","K",15,6
;	DB	'【校長】：うむ、この臨海学校のためにスーツを新調したからね。'
	DB	"Dean:  Well, yes, I had this suit specially made for"
	DB	CR
	DB	"this trip."
	DB	NEXT
;	DB	'【%001】：・・・何しに海に来てるんです？'
	DB	"%001:  ...Why are you wearing it here?"
	DB	FLG,F_COPYI,3,2
	DB	C_BLD,C_N_OFF,1,2	;見る　校長
	DW	0000H


M7:		;話す
;	DB	'【校長】：諸君も知っての通り、生徒の自主性を大事にするのが我が校のモットーだからね。'
	DB	"Dean:  Well, as you all know, at this university we value"
	DB	CR
	DB	"the independence of our students."
	DB	NEXT
;	DB	'校長先生はにわかに立ち上がって、まわりにいる全員に聞こえるように話し始めた。'
	DB	"The dean stood up and began addressing all the"
	DB	CR
	DB	"students around us."
	DB	NEXT
;	DB	'【校長】：それでは、明日は遠泳大会を行うことにする。',CR,'泳げないものは浮き輪を使っても構わないから、とにかく',CR,'教職員も含めて全員参加だ。'
	DB	"Dean:  All right. Tomorrow there will be a distance"
	DB	CR
	DB	"competition. Those who can't swim can use lifesavers,"
	DB	CR
	DB	"and the faculty will also participate."
	DB	NEXT
;	DB	'【校長】：距離はこの浜からあの小島までの往復。'
	DB	"Dean:  The distance will be from the beach to the"
	DB	CR
	DB	"island and back."
	DB	NEXT
;	DB	'【校長】：上位２０名は、特別に夏休みを一週間延長しよう！'
	DB	"Dean:  The first twenty back will get an extra week of"
	DB	CR
	DB	"summer vacation!"
	DB	NEXT
;	DB	'「おおおおーっ！」'
	DB	"All:  Oooooh!"
	DB	NEXT
;	DB	'【校長】：ただし！完泳出来なかった者には秘密の罰ゲームが待っているぞぉ！'
	DB	"Dean:  However! There will be a secret punishment"
	DB	CR
	DB	"awaiting those who can't finish!"
	DB	NEXT
;	DB	'【校長】：それでは、諸君の健闘を祈る！'
	DB	"Dean:  May the best swimmer win!"
	DB	NEXT
	DB	ANI,A_OFF
	BN_P1 B_SUDA
	DB	ANI,A_ON,1
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'校長先生は颯爽と宿に入っていった。'
	DB	"The dean walked impressively into the lodge."
	DB	NEXT
;	DB	'・・・そーゆーわけで、臨海学校三日目は大遠泳大会となってしまったのだった。'
	DB	"So it looked like we would all have to be in the"
	DB	CR
	DB	"swimming competition on the third day of seaside camp."
	DB	NEXT
;	DB	'【%001】：・・・でも、何で校長先生は俺がカナヅチだって知ってるんだ？'
	DB	"%001:  But I really wonder how he knew I can't swim."
	DB	NEXT
	DB	BUF,B_COPY01
	K_CG "CT01","V",0,4		;鈴子
	DB	ANI,A_ON,1
	DB	ANI,A_ON,3
;	DB	'【鈴子】：あははは・・・'
	DB	"Reiko:  Ohohoho..."
	DB	NEXT
;	DB	'【%001】：？？？'
	DB	"%001:  ???"
	DB	NEXT
	E_CG B_FADE,"AB_17_3"
	DB	NEXT
	DB SINARIO,'CS610.OVL',0
	DW	0000H


end
