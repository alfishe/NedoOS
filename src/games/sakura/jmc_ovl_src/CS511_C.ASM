;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１１＿Ｃ
;		林間学校　ＧｏｏｄＭｏｒｎｉｎｇ，美緒

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	-1
MSGTBL:
	DW	M1
COMTBL:
	DW	-1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ


;イニシャルメッセージ
M1:
	DB	BGM,21
	B_O B_FADE
	BAK_INIT 'AB_16_1'
	DB BUF,B_COPY01
;	DB	'【%001】：・・・・・・・・・ぐ～・・・・・・・・・'
	DB	"%001:  .....Zzzzz...."
	DB	NEXT
;	DB	'【美緒】：・・・・・・先輩・・・・・・'
	DB	"Mio:  .....%001...."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・ぴ～・・・・・・・・・'
	DB	"%001:  .....Snore......."
	DB	NEXT
;	DB	'【美緒】：・・・・・・先輩ってば・・・・・・'
	DB	"Mio:  ....Um, %001....."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・か～・・・・・・・・・'
	DB	"%001:  .....Unhnh......"
	DB	NEXT
;	DB	'【美緒】：起きてよ、%001先輩！'
	DB	"Mio:  Wake up, %001!"
	DB	NEXT
	T_CG 'CT03','T',0,0,1
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ........"
	DB	PAUSE
;	DB	'ふぁ～～～～～～あ、良く寝た。'
	DB	"*YAWN* I slept really well."
	DB	PAUSE
;	DB	'おはよ、美緒ちゃん。'
	DB	" Oh, hi, Mio."
	DB	NEXT
;	DB	'【美緒】：もう昼だよ。'
	DB	"Mio:  It's already noon."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............"
	DB	PAUSE
;	DB	'あ、そう。'
	DB	"Oh, yeah."
	DB	NEXT
;	DB	'【美緒】：・・・先輩、今日は山菜取りだよ！早く行こ？'
	DB	"Mio:  %001, today we're supposed to go gather mushrooms!",CR,"Let's go, quickly?"
	DB	NEXT
;	DB	'【%001】：・・・・・・ああ、そうだな。'
	DB	"%001:  ...Yeah, let's go."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'【%001】：なあ、美緒ちゃん。'
	DB	"%001:  By the way, Mio..."
	DB	PAUSE
;	DB	'美緒ちゃんは、どんな山菜が好きなんだ？'
	DB	"which mushrooms do you like best?"
	DB	NEXT
;	DB	'【美緒】：・・・え？'
	DB	"Mio:  ...Huh?"
	DB	PAUSE
;	DB	'あたし、何でも好きだよ。'
	DB	" Mushrooms? Oh, anything will be fine."
	DB	NEXT
;	DB	'【%001】：・・・そか。今日は、美緒ちゃんの好きなものいっぱい取ってやりたかったんだけどな。'
	DB	"%001:  Oh. I wanted to go out today and find lots of the kind ",CR,"you like."
	DB	NEXT
;	DB	'【美緒】：・・・えっ・・・（ぽっ）'
	DB	"Mio:  ....Eh... *blush*"
	DB	NEXT
;	DB	'【%001】：昨日は魚をいっぱい御馳走してもらったからさ。'
	DB	"%001:  Well, you know, I wanted to thank you for the fish",CR,"yesterday."
	DB	NEXT
;	DB	'よーし、たくさん取るぞ！行こうぜ！'
	DB	"%001:  All right! Let's go and find a whole bunch!"
	DB	NEXT
;	DB	'【美緒】：・・・う、うん！'
	DB	"Mio:  Okay, let's go!"
	DB	NEXT
	B_O B_FADE
	BAK_INIT 'AB_08_1'
	DB BUF,B_COPY01
	T_CG 'CT03','T','K',15,2
;	DB	'・・・そして俺と美緒ちゃんは、一緒に山中を駆け回った。'
	DB	"......So Mio and I walked around in the mountains together."
	DB	NEXT
;	DB	'調子に乗ってちと取りすぎたりもしたが、それは朝食用と言う事になった。'
	DB	"We probably gathered more than we needed, but they were"
	DB	CR
	DB	"delicious."
	DB	NEXT
;	DB	'（・・・ホント、美緒ちゃんはいい奥さんになるな。）'
	DB	"...You know, Mio will make a really good wife for someone",CR,"someday."
	DB	NEXT
	DB G_FLG,G_COPYF,130,130
	DB FLG,F_CALI,130,15
	DB G_FLG,G_COPYG,130,130
	DB	SINARIO,'CS513.OVL',0
	DW	0000H


end
