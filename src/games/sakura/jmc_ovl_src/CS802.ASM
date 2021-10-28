;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０２
;		体育祭前　祥子、最後の賭け

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'断る',0
VV4:	DB	4,	'REFUSE',0
;VV5:	DB	5,	'ＯＫする',0
VV5:	DB	5,	'AGREE',0

;NN1:	DB	1,	'祥子',0
NN1:	DB	1,	'SHOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　祥子２
S2:		DW	VV2, NN1,  2, M4, M5, M6, M7, M8, M9		;話す　祥子５
S3:		DW	VV4,  -1,  3, M10		;断る１
S4:		DW	VV5,  -1,  4, M11		;ＯＫする１
S5:		DW	VV3,  -1,  5, M12, M13, M14, M15, M16, M17, M18		;考える７


;イニシャルメッセージ
M1:
	DB	BGM,4
;	DB	'【%001】：・・・・・・ふう。流石に身体が重いぞ。'
	DB	"%001:  My body hurts."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................................."
	DB	NEXT
;	DB	'【%001】：こんなんで、最後まで持つかな？鈴子さん達にはタンカ切っちゃったけど・・・・・'
	DB	"%001:  I wonder if I can really make it to the end of this?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・ま、行けるとこまでは行くさ。'
	DB	"%001:  ...Well, I'll just do my best."
	DB	NEXT
	BAK_INIT "AB_01_2"
	DB	BUF,B_COPY01										;背景コピー
	T_CG 'CT09',0,0,0,1
;	DB	'【%001】：・・・ただいま～。'
	DB	"%001:  I'm home..."
	DB	NEXT
;	DB	'【伸幸】：お、遅かったな%001。さっきからお前の友達が待ってるぞ。'
	DB	"Nobuyuki:  Ah, you're late. A friend of yours is waiting"
	DB	CR
	DB	"for you."
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  Really?"
	DB	NEXT
;	DB	'【伸幸】：・・・それからな、父さんは母さんとちょっと出てくるからな。'
	DB	"Nobuyuki:  Your mother and I are going out for a bit."
	DB	PAUSE
;	DB	'・・・しっかりやれよ。'
	DB	"...Do"
	DB	CR
	DB	"your best."
	DB	NEXT
;	DB	'【%001】：？　あ、ああ・・・・・・'
	DB	"%001:  Um, okay."
	DB	NEXT
	BAK_INIT "AB_38_2"
	DB	BUF,B_COPY01										;背景コピー
	B_O B_YOKO
;	DB	'・・・そして、俺の部屋で待っていたのは。'
	DB	"...I go up to my room to see who was here."
	DB	NEXT
	T_CG 'CT04','F',0,20,1
;	DB	'【祥子】：・・・あ、しゅ～君。お帰りなさい。'
	DB	"Shoko:  Ah, Shu-kun! Welcome home!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  Shoko! Why are you here?"
	DB	C_BLD,C_V_ON,4		;断る　消す
	DB	C_BLD,C_V_ON,5		;ＯＫする　消す
	DW	0000H

M2:		;見る　祥子１
;	DB	'・・・なんか、みょ～に大人しいな・・・'
	DB	"She seems really quiet for some reason."
	DB	NEXT
;	DB	'・・・・・・不気味だ。'
	DB	"I wonder what's wrong with her."
	DW	0000H

M3:		;見る　祥子２
;	DB	'・・・・・・泣いている・・・・・・'
	DB	"She's...crying."
	DB	NEXT
;	DB	'あの西野さんが、俺の為に・・・・・・'
	DB	"Why?"
	DW	0000H

M4:		;話す　祥子１
;	DB	'【%001】：・・・どっ、どうしてここがっ！？'
	DB	"%001:  Um, what are you doing here?"
	DB	NEXT
;	DB	'【祥子】：・・・うん。しゅ～君とお話したい事があって・・・'
	DB	"Shoko:  I wanted to talk to you."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	DB	PAUSE
;	DB	'俺に？'
	DB	"To me?"
	DB	NEXT
;	DB	'【祥子】：うん・・・'
	DB	"Shoko:  Yes."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M5:		;話す　祥子２
;	DB	'【%001】：・・・それで、話っていうのは？'
	DB	"%001:  ...What did you want to talk about?"
	DB	NEXT
;	DB	'【祥子】：あのね、しゅ～君・・・'
	DB	"Shoko:  Well..."
	DB	PAUSE
;	DB	'サッカーの練習、もうしなくてもいいよ。'
	DB	"I want you to know that you don't have to go"
	DB	CR
	DB	"to soccer practice anymore."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M6:		;話す　祥子２
;	DB	'【%001】：・・・・・・なんで？'
	DB	"%001:  Why not?"
	DB	NEXT
;	DB	'【祥子】：今日、チームのキャプテンさんに聞いたらぁ、'
	DB	"Shoko:  I talked to the soccer captain today."
	DB	PAUSE
;	DB	'「もう練習しなくても大丈夫」って・・・'
	DB	" He said you"
	DB	CR
	DB	"would be fine even without any more practice."
	DB	NEXT
;	DB	'【%001】：・・・・・・確かに「基礎はしなくていい」とは、前から言われてるけど・・・・・・'
	DB	"%001:  ...Really?"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M7:		;話す　祥子３
;	DB	'【祥子】：・・・ね？しゅ～君運動神経いいからぁ、もう練習しなくても大丈夫だよ。'
	DB	"Shoko:  Okay? So you don't have to go back to the soccer"
	DB	CR
	DB	"practice anymore."
	DB	NEXT
;	DB	'【%001】：・・・そ～は言ってもなあ・・・'
	DB	"%001:  ...It's not as easy as that."
	DB	NEXT
;	DB	'【祥子】：・・・・・・'
	DB	"Shoko:  ....."
	DB	PAUSE
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,5,1
	K_CG 'CT04','I',20,2
;	DB	'しゅ～君、こわれちゃう・・・・・・'
	DB	"Shu-kun, I'm worried about you!"
	DB	NEXT
;	DB	'【%001】：え？'
	DB	"%001:  You are?"
	DB	FLG,F_COPYI,2,4
	DW	0000H

M8:		;話す　祥子４
;	DB	'【祥子】：・・・だってしゅ～君、サッカー部の人達の何倍も練習してる！'
	DB	"Shoko:  You're practicing ten times as hard as the others"
	DB	CR
	DB	"on the soccer team."
	DB	PAUSE
;	DB	'練習のし過ぎで身体壊しちゃった人、何人もいる！'
	DB	" You're going to hurt yourself!"
	DB	NEXT
;	DB	'【%001】：・・・・・・西野さん・・・・・・'
	DB	"%001:  Shoko..."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M9:		;話す　祥子５
;	DB	'【祥子】：・・・だから・・・',PAUSE,'ね？'
	DB	"Shoko:  So...",PAUSE,"don't go back, okay?"
	DB	NEXT
;	DB	'【%001】：・・・・・・でも・・・・・・'
	DB	"%001:  But I..."
	DB	NEXT
;	DB	'【祥子】：・・・やだやだ！しゅ～君壊れちゃうなんて、やだ！'
	DB	"Shoko:  But nothing! You're going to really hurt yourself!"
	DB	NEXT
;	DB	'【%001】：西野さん・・・・・・'
	DB	"%001:  Shoko..."
	DB	NEXT
;	DB	'（・・・・・・どうする！？）'
	DB	"What should I say to her?"
	DB	FLG,F_COPYI,5,2
	DB	C_BLD,C_V_ON,2		;話す　消す
	DB	C_BLD,C_V_OFF,4		;断る　出す
	DB	C_BLD,C_V_OFF,5		;ＯＫする　出す
	DW	0000H

M10:		;断る１
;	DB	'【%001】：・・・・・・ごめん、西野さん。'
	DB	"%001:  ......I'm sorry, Shoko."
	DB	NEXT
;	DB	'【祥子】：！'
	DB	"Shoko:  Why?"
	DB	NEXT
;	DB	'【%001】：俺・・・やっぱり約束は破れないよ。'
	DB	"%001:  I started this. And now I don't want to break my"
	DB	CR
	DB	"promise."
	DB	NEXT
;	DB	'【祥子】：・・・しゅ～君・・・'
	DB	"Shoko:  Shu-kun..."
	DB	NEXT
;	DB	'【%001】：・・・それにさ、俺って結構頑丈なんだぜ？'
	DB	"%001:  Also...you know how stubborn I am, right?"
	DB	PAUSE
;	DB	'・・・だいじょーぶ。壊れたりなんかしないって。'
	DB	" ...I'll be"
	DB	CR
	DB	"okay. Nothing's going to happen."
	DB	NEXT
;	DB	'【祥子】：・・・やっぱり・・・'
	DB	"Shoko:  ......I knew it."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ............."
	DB	PAUSE
;	DB	'西野さん？'
	DB	"What?"
	DB	NEXT
;	DB	'【祥子】：・・・やっぱり、鈴子ちゃんの方がいいんだ。'
	DB	"Shoko:  You like Reiko more than me, don't you?"
	DB	NEXT
;	DB	'【%001】：へ？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【祥子】：・・・しゅ～君の・・・しゅ～君の・・・'
	DB	"Shoko:  .....Shu-kun...I..."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【祥子】：ばかぁあぁぁぁぁっっっ！！！'
	DB	"Shoko:  I hate you!!"
	DB	NEXT
;	DB	'【%001】：に、西野さん！？'
	DB	"%001:  Shoko!?"
	DB	NEXT
;	DB	'【%001】：・・・・・・行っちゃった。'
	DB	"%001:  ..............She's gone."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	".................................."
	DB	NEXT
;	DB	'【%001】：何だか、悪い事しちゃったな。'
	DB	"%001:  What was that all about?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"........................................"
	DB	NEXT
;	DB	'【%001】：寝よ。'
	DB	"%001:  Guess I'll go to bed."
	DB	NEXT
	DB	SINARIO,'CS803.OVL',0
	DW	0000H

M11:		;ＯＫする１
;	DB	'【%001】：・・・・・・分かったよ、西野さん。'
	DB	"%001:  .......Okay, Shoko."
	DB	NEXT
;	DB	'【祥子】：・・・ホントに！？'
	DB	"Shoko:  Really?"
	DB	NEXT
;	DB	'【%001】：ああ・・・正直言って、ちょっとキツかったしな。'
	DB	"%001:  Yes. To be honest, it was pretty hard."
	DB	NEXT
	K_CG 'CT04','K',20,3
;	DB	'【祥子】：良かったぁ・・・ありがと、しゅ～君。'
	DB	"Shoko:  Thank you, Shu-kun."
	DB	NEXT
;	DB	'【%001】：さて・・・時間も遅いし、送ってくよ。'
	DB	"%001:  Okay, well... I'll take you home now."
	DB	PAUSE
;	DB	'よっ・・・'
	DB	" Huh?"
	DB	PAUSE,GATA,2
;	DB	'ととっ・・・？'
	DB	"What?"
	DB	NEXT
	K_CG 'CT04','I',20,2
;	DB	'【祥子】：しゅ～君！？'
	DB	"Shoko:  Shu-kun?"
	DB	NEXT
;	DB	'【%001】：・・・あ、ああ大丈夫。'
	DB	"%001:  I'll be alright."
	DB	PAUSE
;	DB	'・・・ちょっと、緊張の糸が切れたかな？ははは・・・'
	DB	" My muscles just tightened up, that's"
	DB	CR
	DB	"all. I shouldn't have relaxed like that."
	DB	NEXT
;	DB	'【祥子】：・・・・・・・・・'
	DB	"Shoko:  ........................"
	DB	NEXT
	K_CG 'CT04','K',20,3
;	DB	'【祥子】：しゅ～君。あたし、マッサージしてあげる。'
	DB	"Shoko:  I'll massage you!"
	DB	NEXT
;	DB	'【%001】：・・・え？'
	DB	"%001:  ...You will?"
	DB	NEXT
;	DB	'【祥子】：あたし、これでもマネージャー！みたいな～。'
	DB	"Shoko:  Yes. I am the manager of the soccer team, you"
	DB	CR
	DB	"know! I have to massage the players' muscles sometimes."
	DB	NEXT
;	DB	'【%001】：・・・そか。じゃあせっかくだから頼もうかな。'
	DB	"%001:  ...That's right. Okay, thanks."
	DB	NEXT
;	DB	'【祥子】：うん！じゃ、そこに横になってなってぇ～！'
	DB	"Shoko:  Okay, lie down here."
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Okay."
	DB	NEXT
	DB	SINARIO,'CSE_D_1.OVL',0
	DW	0000H

M12:		;考える１
;	DB	'・・・今度は、一体なんだ！？',PAUSE,'何を企んでいる！？'
	DB	"What's she planning now?"
	DB	NEXT
	DB	"..................."
	DB	NEXT
;	DB	'いつもと、雰囲気違うせいか？'
	DB	"She seems different, somehow."
	DW	0000H

M13:		;考える２
;	DB	'・・・西野さんが、そんなに俺のこと心配してたなんて・・・'
	DB	"Shoko is really worried about me."
	DW	0000H

M14:		;考える３
;	DB	'ここで西野さんの言う通りにすれば、俺は約束を破る事になる。'
	DB	"If I do as she asks, I'll have broken my promise."
	DB	NEXT
;	DB	'・・・・・・'
	DB	"......................"
	DB	NEXT
;	DB	'だけど・・・今のままで身体が保つかどうかは、正直自信が無い。'
	DB	"But I'm not sure if I can go any farther with this. I"
	DB	CR
	DB	"might really hurt myself after all."
	DB	FLG,F_COPYI,5,3
	DW	0000H

M15:		;考える４
;	DB	'もし俺が身体壊しちまって、体育祭に出られなくなったら・・・'
	DB	"If I do hurt myself practicing, I won't be able to"
	DB	CR
	DB	"participate in the sports festival at all."
	DB	NEXT
;	DB	'俺はみんなに、とんでもない迷惑をかける事になっちまう。'
	DB	"That would really hurt everyone in my class."
	DB	NEXT
;	DB	'そんな事になるくらいなら、いっそ頭下げて減らしてもらった方が・・・・・・'
	DB	"I guess it wouldn't hurt to reduce the number of sports"
	DB	CR
	DB	"I was going to participate in."
	DB	FLG,F_COPYI,5,4
	DW	0000H

M16:		;考える５
;	DB	'・・・だけど、俺が必ず身体を壊すとは限らない。'
	DB	"But I will probably be fine."
	DB	NEXT
;	DB	'今ほどじゃないが、結構近いムチャをした事もある。'
	DB	"I'm actually used to pushing myself too far."
	DB	FLG,F_COPYI,5,5
	DW	0000H

M17:		;考える６
;	DB	'・・・しかし、西野さんの気持ちを無にするのもなんだしなあ・・・'
	DB	"I can't ignore Shoko's feelings, though."
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".........................."
	DB	NEXT
;	DB	'困った。'
	DB	"What should I do?"
	DB	FLG,F_COPYI,5,6
	DW	0000H

M18:		;考える７
;	DB	'・・・なんかいいアイディアは・・・'
	DB	"Is there anything I can do?"
	DB	NEXT
;	DB	'・・・・・・'
	DB	"....."
	DB	NEXT
;	DB	'・・・・・・・・・・・・'
	DB	"................."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・・・・'
	DB	"...................................................."
	DB	NEXT
;	DB	'思い付かん。'
	DB	"Hmm, I can't think of anything."
	DW	0000H


end
