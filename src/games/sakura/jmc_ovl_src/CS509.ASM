;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０９
;		林間学校　二日目夜

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
	BAK_INIT 'AB_16_2'
	DB	BUF,B_COPY01
	T_CG 'CT14','T',0,25,1
;	DB	'【%001】：・・・やれやれ、結局全然釣れなかったな。'
	DB	"%001:  So you didn't catch any fish after all."
	DB	NEXT
;	DB	'【誠】：こ～なったら、他の連中に期待だな。'
	DB	"Makoto:  I hope someone else caught something."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT05','T',0,10,2
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ........................."
	DB	NEXT
;	DB	'【%001】：あ、白水さん。'
	DB	"%001:  Ah, Ruri."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  .........................."
	DB	PAUSE
;	DB	'なに？'
	DB	"What?"
	DB	NEXT
;	DB	'【%001】：どう？釣れた？'
	DB	"%001:  Did you catch anything?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ..........................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........................."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ..........................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・そか。'
	DB	"%001:  ......I see."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・もう、行っていい？'
	DB	"Ruri:  .........Can I go now?"
	DB	NEXT
;	DB	'【%001】：・・・あ、ああ。'
	DB	"%001:  .........I guess."
	DB	NEXT
;	DB	'【瑠璃】：さよなら。'
	DB	"Ruri:  Sayonara."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................................"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT03','T','K',20,3
;	DB	'【美緒】：・・・せんぱーい！見て見て！いっぱい釣れたよ！！'
	DB	"Mio:  %001, look at all the fish I caught!"
	DB	NEXT
;	DB	'【%001】：・・・お、ホントだ。'
	DB	"%001:  Wow, that's great."
	DB	PAUSE
;	DB	'こりゃ、晩飯が楽しみだ。'
	DB	" Now we can all eat tonight."
	DB	NEXT
;	DB	'【美緒】：あたし、捌いて来るね！！'
	DB	"Mio:  I'll go clean them."
	DB	NEXT
;	DB	'【%001】：・・・いや、丸焼きにしようぜ。'
	DB	"%001:  No, let's put them on stakes and cook them that"
	DB	CR
	DB	"way."
	DB	PAUSE
;	DB	'やっぱり野外だったら、コレだよな。'
	DB	" I mean, we are out in the wilderness and everything."
	DB	NEXT
;	DB	'【美緒】：うん、そうだね。'
	DB	"Mio:  That's a good idea."
	DB	NEXT
;	DB	'・・・・・・こうして俺達は、腹一杯川の幸を詰め込む事ができた。'
	DB	"......In this way, we were all able to enjoy the "
	DB	CR
	DB	"bounty of the river."
	DB	NEXT
;	DB	'まったくもって美緒ちゃんは、俺達の胃袋の守り神だ。'
	DB	"Mio was the savior of our stomachs."
	DB	NEXT
;	DB	'（何時か、お返ししなくちゃな。）'
	DB	"I'd better give her something to say thanks later."
	DB	NEXT
;	DB	'俺は、そう思った。'
	DB	"....Yes, that's a good idea."
	DB	NEXT
	B_O B_FADE
	DB	SINARIO,'CS511_C.OVL',0
	DW	0000H


end
