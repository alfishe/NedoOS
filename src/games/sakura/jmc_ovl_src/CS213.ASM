 ;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２１３
;		体育倉庫

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
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
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	"話す",0
VV1:	DB	1,	"TALK",0
;VV2:	DB	2,	"助けを求める",0
VV2:	DB	2,	"BEG FOR HELP",0
;VV3:	DB	3,	"自力で脱出",0
VV3:	DB	3,	"RUN AWAY",0

;NN1:	DB	1,	"祥子",0
NN1:	DB	1,	"SHOKO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;話す　祥子
S2:		DW	VV2, -1,  2, M3, M4, M5		;助けを求める
S3:		DW	VV3, -1,  3, M6, M7		;自力で脱出２


;イニシャルメッセージ
M1:
	DB	BGM,30
	BAK_INIT "AB_26"
	DB	BUF,B_COPY01
	TU_CG "CT01","W","D",35,2
	TU_CG "CT03","W","D",8,1
	T_CG "CT02","W","D",0,3
	DB	ANI,A_ON,1
	DB	ANI,A_ON,2
;	DB	"【鈴子】：あ～～～～～～っ！何してるのよ%001君！"
	DB	"Reiko:  What are you doing, %001!?"
	DB	NEXT
;	DB	"【清美】：いけませんわ%001さん、学校内でその様な行為をすることは禁止されておりますわよ！"
	DB	"Kiyomi:  Stop that right now. That sort of activity is"
	DB	CR
	DB	"forbidden at school!"
	DB	NEXT
;	DB	"【美緒】：・・・エッチ・・・"
	DB	"Kiyomi:  ...How perverted..."
	DB	NEXT
;	DB	"【%001】：ちっがぁーう！襲われてるのは俺の方なんだよっ！"
	DB	"%001:  No, wait! I'm not doing anything!"
	DB	NEXT
;	DB	"【？】：ひっどぉぉ～い！「君が好きだ、君の全てが欲しい！」って",CR,"言ったくせにぃ。"
	DB	"???:  How awful! Didn't you just tell me you love me, and want"
	DB	CR
	DB	"to make love to me?"
	DB	NEXT
;	DB	"【%001】：言ってねぇ！"
	DB	"%001:  I did not!"
	DB	NEXT
;	DB	"【？】：うそうそぉ、昨日あたしの夢枕に立ったくせにぃ。"
;	DB	"???:  Tell the truth! You stood at my bedside in a dream last"
;	DB	CR
;	DB	"night!"
;	DB	NEXT
;	DB	"【%001】：俺は死人かいっ！"
;	DB	"%001:  What am I? A ghost?"
	DW	0000H

M2:		;話す　祥子
;	DB	"【祥子】：さ、あんなのほっといて、エッチしよっ！"
	DB	"Shoko:  Just forget them and let's get on with it!"
	DB	NEXT
;	DB	"【%001】：できるかっ！"
	DB	"%001:  With them watching?"
	EF_SET 101
	DW	0000H

M3:		;助けを求める
;	DB	"【%001】：助けて鈴子さぁん！新藤さん、美緒ちゃん！"
	DB	"%001:  Help me, Reiko! Kiyomi! Mio!"
	DB	NEXT
;	DB	"【鈴子】：こんな非常識なことするのは一人しかいないと思ったら、やっぱりあなただったわね、祥子！"
	DB	"Reiko:  I only know one person who is crazy enough to pull"
	DB	CR
	DB	"a stunt like this!  I knew it was you, Shoko."
	DB	NEXT
;	DB	"【%001】：・・・知ってるの？"
	DB	"%001:  ...You know her?"
	DB	NEXT
;	DB	"【鈴子】：否が応にもね。あたしと同じクラスなのよ。"
	DB	"Reiko:  If anyone does. She is in my class."
	DB	NEXT
;	DB	"【祥子】：３年Ａ組、西野　祥子でぇ～～す！",CR,"よろしくぅ、しゅ～君！"
	DB	"Shoko:  Senior, A class, Shoko Nishino. Pleased to make"
	DB	CR
	DB	"your acquaintance, Shu-kun."
	DB	NEXT
;	DB	"【%001】：・・・って、早くどいてくれよ！"
	DB	"%001:  Just get off me!"
	DB	FLG,F_COPYI,3,1		;自力で脱出２
	DB C_BLD,C_V_OFF,1		;話す　祥子
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;助けを求める
;	DB	"【美緒】：どうして%001先輩にそんな事するのっ！？"
	DB	"Mio:  Why would you do such a thing to %001?!"
	DB	NEXT
;	DB	"【祥子】：んふふぅ、当てて見ればぁ？"
	DB	"Shoko:  Why do you think?"
	DB	NEXT
;	DB	"【鈴子】：当てろも何も、どうせサッカー部の勧誘でしょ！"
	DB	"Reiko:  No need to guess. She's trying to get you to join the"
	DB	CR
	DB	"soccer team."
	DB	NEXT
;	DB	"【清美】：あの方は、サッカー部の方なのですか？"
	DB	"Kiyomi:  That person is from the soccer team?"
	DB	NEXT
;	DB	"【鈴子】：そうよ！強引な勧誘の手口のせいで、ちょっとした有名人なのよ。"
	DB	"Reiko:  That's right. And she is famous for pulling stunts"
	DB	CR
	DB	"like this."
	DB	NEXT
;	DB	"【鈴子】：それにしても・・・色仕掛けだなんて、そこまで堕ちたのあなた！"
	DB	"Reiko:  I'd heard the rumors, but I didn't know she was this"
	DB	CR
	DB	"much of a slut."
	DB	NEXT
;	DB	"【祥子】：ブッブーッ！残念でしたぁ！"
	DB	"Shoko:  Hahaha! Too bad for you!"
	DB	NEXT
;	DB	"【祥子】：もちろん、サッカー部にも入ってもらうけどぉ、"
	DB	"Shoko:  I will have him on the soccer team!"
	DB	NEXT
;	DB	"【祥子】：これはぁ、「愛のこ・く・は・く」でぇ～～す！"
	DB	"Shoko:  The reason is... I love him!"
	DB	NEXT
;	DB	"【鈴子】：なっ！？"
	DB	"Reiko:  What?!"
	DB	NEXT
;	DB	"【美緒】：うそ・・・"
	DB	"Mio:  Oh my god!"
	DB	NEXT
;	DB	"【清美】：驚きですわ・・・。"
	DB	"Kiyomi:  This is shocking..."
	DB	NEXT
;	DB	"【%001】：俺達、初対面だろ？いきなりこんな事するか普通！"
	DB	"%001:  But we just met!"
	DB	NEXT
;	DB	"【祥子】：愛に時間なんてぇ、カンケーないない！"
	DB	"Shoko:  Time is of no matter in love!"
	DB	NEXT
;	DB	"【祥子】：初めてしゅ～君を見た時にぃ、心臓が「どっきん！」ってなってぇ、「きゅーん」って感じになったのぉ～。"
	DB	"Shoko:  When I first say my Shu-kun, my heart leapt. I had"
	DB	CR
	DB	"had this strange feeling."
	DB	NEXT
;	DB	"【祥子】：しゅ～君もぉ、心臓が「どきどき！」ってなってるでしょ～？"
	DB	"Shoko:  Shu-kun, your heart is racing, isn't it?"
	DB	NEXT
;	DB	"【%001】：・・・なってるけど・・・"
	DB	"%001:  Yeah, but..."
	DB	NEXT
;	DB	"【祥子】：だからぁ、あたしたちはぁ、相性バッチシパーフェクトなのぉ～！"
	DB	"Shoko:  That's right. We match perfectly!"
	DB	NEXT
;	DB	"【%001】：・・・そっ・・・そうなのか・・・"
	DB	"%001:  I doubt that, somehow."
	DB	NEXT
;	DB	"【美緒】：%001先輩、だまされちゃダメ！"
	DB	"Mio:  %001, don't be fooled!"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;助けを求める
;	DB	"【祥子】：しゅー君、女の子にぃ、恥かかせる気なのぉ？"
	DB	"Shoko:  Shu-kun, are you trying to make fun of me?"
	DB	NEXT
;	DB	"【%001】：うわわわわ！"
	DB	"%001:  Whaaa!"
	DW	0000H

M6:		;自力で脱出
;	DB	"【%001】：た、頼むからどいて！"
	DB	"%001:  Hey, really, lay off!"
	DB	NEXT
;	DB	"俺は彼女を押しのけようとした。"
	DB	"I try to push her off."
	DB	NEXT
;	DB	"ふにゅっ"
	DB	"*SQUISH*"
	DB	NEXT
;	DB	"【？】：あん☆　しゅ～君てば・・・"
	DB	"???:  Ooh! Shu-kun!"
	DB	NEXT
;	DB	"【鈴子】：%001君のエッチ！"
	DB	"Reiko:  %001, you pervert!"
	DB	NEXT
;	DB	"【%001】：ち、違う！今のは事故だぁ！"
	DB	"%001:  Wait! That was an accident!"
	EF_SET 102
	DW	0000H

M7:		;自力で脱出２
;	DB	"【%001】：西野さん、いいかげんにしてよ！"
	DB	"%001:  Shoko, this is enough!"
	DB	NEXT
;	DB	"俺は西野さんを押しのけようとした。"
	DB	"I tried to push her off."
	DB	NEXT
;	DB	"ふにゅっ"
	DB	"*SQUISH*"
	DB	NEXT
;	DB	"【？】：しゅ～君てば、ダ・イ・タ・ン☆"
	DB	"???:  Shuuu. That's wonderful!"
	DB	NEXT
;	DB	"【清美】：ふ、不潔ですわ%001さん！"
	DB	"Kiyomi:  I can't believe you, %001!"
	DB	NEXT
;	DB	"【%001】：わざとじゃないよぉ！"
	DB	"%001:  I didn't do it on purpose!"
	EF_SET 102
	DW	0000H

M_EXIT:	
	DB	FLG,F_COPYI,100,1
	DB	FLG,F_MAND,3,100,101,102
	DB	FLG,F_EXIT,100
	DB	NEXT
;	DB	"【祥子】：ねー鈴子ちゃん、あたし達「めいく・らぶっ！」したいからぁ、早く出てってくれないかなぁ、みたいなぁ。"
	DB	"Shoko:  Reiko, we want to make love. Would you please"
	DB	CR
	DB	"leave?"
	DB	NEXT
;	DB	"【鈴子】：馬鹿言ってるんじゃないわよ！"
	DB	"Reiko:  You're such a slut!"
	DB	NEXT
;	DB	"【祥子】：も～、鈴子ちゃんのえっちぃ。"
	DB	"Shoko:  Or would you rather watch? "
	DB	NEXT
;	DB	"【祥子】：しゅ～君しゅ～君、こっちに来てぇ。"
	DB	"Shoko:  Shu-kun, come here."
	DB	NEXT
	B_O B_NORM
;	DB	"ぐいっ"
;	DB	"Gwaa"
;	DB	NEXT
;	DB	"【%001】：あ～れ～・・・"
	DB	"%001:  Huh, what's..."
	DB	NEXT
;	DB	"俺はマットの山の中に引っ張り込まれてしまった。"
	DB	"I was pulled down under the mats."
	DB	NEXT
;	DB	"【祥子】：うっふっふ、しゅ～く～ん。"
	DB	"Shoko:  Ooohh, Shu-kun!"
	DB	NEXT
;	DB	"【%001】：や、やめて～！"
	DB	"%001:  S- Stop that!"
	DB	NEXT
;	DB	"俺はズボンを脱がそうとする魔の手から必死に逃げようともがいた。"
	DB	"I tried to get away from the hands taking off my pants."
	DB	NEXT
;	DB	"【鈴子】：祥子！恥を知りなさい恥を！"
	DB	"Reiko:  Shoko! Think of what you're doing!"
	DB	NEXT
;	DB	"【清美】：いけませんわ～、不潔ですわ～！"
	DB	"Kiyomi:  This is wrong!"
	DB	NEXT
;	DB	"【美緒】：%001先輩を離して！"
	DB	"Mio:  Let %001 go!"
	DB	NEXT
;	DB	"【%001】：うひ～っ！"
	DB	"%001:  Help!"
	DB	NEXT
	B_P1 B_YOKO
;	DB	"俺は何とかマットの山から抜け出した。"
	DB	"I managed to get out of the mats."
	DB	NEXT
;	DB	"【祥子】：うっそぉ！しゅ～君って・・・てくにしゃん☆"
	DB	"Shoko:  Oh Shu-kun, you're such a technician."
	DB	NEXT
;	DB	"【鈴子】：ちょっと誰、私のスカートに頭突っ込んでるの！？"
	DB	"Reiko:  Hey, who's got their head in my skirt?!"
	DB	NEXT
;	DB	"【清美】：いけませんわ～！おやめになって下さい！"
	DB	"Kiyomi:  Stop now, please!"
	DB	NEXT
;	DB	"【美緒】：いたたたた、髪の毛が・・・"
	DB	"Mio:  Ow, ow, ow, ow. My hair..."
	DB	NEXT
;	DB	"（あっらぁ～・・・）"
;	DB	"Ohoh"
;	DB	NEXT
;	DB	"どうやらマットの下では、凄いことになってるらしい。"
	DB	"There's a real tangle under those mats."
	DB	NEXT
;	DB	"【鈴子】：いや～っ！離してぇ～！"
	DB	"Reiko:  Let me go!"
	DB	NEXT
;	DB	"【清美】：いけませんわ～！わたくしたち、高校生ですのよ！"
	DB	"Kiyomi:  This is wrong!"
	DB	NEXT
;	DB	"【美緒】：ふぎゃっ！くるひぃよ・・・"
	DB	"Mio:  Whaa! Whoa!"
	DB	NEXT
;	DB	"【祥子】：あ・・・ん☆"
	DB	"Shoko:  Ooooh."
	DB	NEXT
;	DB	"（・・・・・・・・・・・・・・・）"
	DB	"..................."
	DB	NEXT
;	DB	"（・・・逃げよう！）"
	DB	"I'm out of here!"
	DB	NEXT
;	DB	"俺は足音を忍ばせて、そっと体育準備室を抜け出した。"
	DB	"I silently made my way out of the gymnastics room."
	DB	NEXT
;	DB	"・・・・・・・・・・・・・・・・・・・・・"
	DB	".................................."
	DB	NEXT
;	DB	"【祥子】：あ・・・あれれ？しゅ～くぅ～ん・・・"
	DB	"Shoko:  What? Where's Shu-kun?"
	DB	NEXT
	DB ANI,A_INIT	
	DB	BUF,B_COPY01
	TU_CG "CT01","W","D",35,1
	TU_CG "CT03","W","I",8,3
	T_CG "CT02","W","R",0,2
	DB ANI,A_ON,1
	DB ANI,A_ON,3
;	DB	"【鈴子】：こっ・・・この変態女ぁ！"
	DB	"Reiko:  Slut!"
	DB	NEXT
;	DB	"【清美】：いけませんわ～！いけませんわ～！"
	DB	"Kiyomi:  Stop! Stop!"
	DB	NEXT
;	DB	"【美緒】：清美先輩、苦しいよぉ・・・"
	DB	"Mio:  Kiyomi, that hurts!"
	DB	NEXT
;	DB	"【清美】：・・・まぁ！"
	DB	"Kiyomi:  ...Ah!"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT04","W","D",25,4
;	DB	"【祥子】：もぉ、鈴子ちゃん達がぁ、じゃまするからよぉ！"
	DB	"Shoko:  Oh! Reiko, how could you be so mean?"
	DB	NEXT
;	DB	"【鈴子】：%001君はあなたにだけは渡さないわ！"
	DB	"Reiko:  I'll never let you have %001!"
	DB	NEXT
;	DB	"【祥子】：ふ～んだ！しゅ～君はぁ、あたしの「すてでぃ」になるんだからぁ！"
	DB	"Shoko:  Oh, really? Shu-kun's going to be my steady,"
	DB	CR
	DB	"you wait."
	DB	NEXT
;	DB	"【祥子】：誰もあたしたちのぉ、「ラブラブ☆」は止められないんだからぁ！"
	DB	"Shoko:  Nobody will get in the way of our love."
	DB	NEXT
	DB ANI,A_OFF
	B_P1 B_SUDA
;	DB	"・・・・・・・・・・・・・・・・・・"
	DB	"........................."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG "CT01","W","D",35,1
	TU_CG "CT03","W",0,8,5
	T_CG "CT02","W",0,0,6
	DB ANI,A_ON,1
	DB ANI,A_ON,5
;	DB	"【美緒】：行っちゃった・・・"
	DB	"Mio:  She's gone..."
	DB	NEXT
;	DB	"【鈴子】：ホンット、しょーもないヤツ！"
	DB	"Reiko:  Looks that way. What a bitch!"
	DB	NEXT
;	DB	"【清美】：%001さんも、いなくなってしまわれましたね・・・"
	DB	"Kiyomi:  %001 is gone too..."
	DB	NEXT
;	DB	"【美緒】：・・・でも、%001先輩が無事でよかった・・・"
	DB	"Mio:  At least we got here in time..."
	DB	NEXT
	K_CG "CT01","K",35,7
	DB ANI,A_ON,5
	DB ANI,A_ON,6
;	DB	"【鈴子】：ふふっ・・・"
	DB	"Reiko:  Hmm..."
	DB	NEXT
;	DB	"【清美】：では、わたくしたちも帰りましょうか。"
	DB	"Kiyomi:  Then let's go home too."
	DB	NEXT
;	DB	"【鈴子】：ねぇ、帰りにアイスクリーム食べてかない？"
	DB	"Reiko:  Hey, want to get some ice cream on the way home?"
	DB	CR
;	DB	"もち、私のおごりよ。"
	DB	"My treat."
	DB	NEXT
	K_CG "CT03","K",8,8
	DB ANI,A_ON,6
	DB ANI,A_ON,7
;	DB	"【美緒】：ほんとっ！"
	DB	"Mio:  Really!"
	DB	NEXT
;	DB	"【清美】：よろしいのですか？"
	DB	"Kiyomi:  You're sure?"
	DB	NEXT
;	DB	"【鈴子】：%001君が無事だったお祝いってことでね。"
	DB	"Reiko:  To celebrate %001's getting away from Shoko."
	DB	NEXT
;	DB	"【美緒】：わ～い☆　早く行こ、早く早く！"
	DB	"Mio:  Alright! Let's go!"
	DB	NEXT
;	DB	"【清美】：そんなに急がなくても、アイスクリームは逃げませんわよ。"
	DB	"Kiyomi:  No need to hurry. The ice cream isn't going"
	DB	CR
	DB	"anywhere."
	DB	NEXT
;	DB	"・・・・・・・・・・・・・・・・・・・・・・・・"
	DB	"..................................................."
	DB	NEXT
	B_O B_SUDA
	DB SINARIO,"CS301.OVL",0
	DW	0000H


end
