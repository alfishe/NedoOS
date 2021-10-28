;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　９０３
;		お開きの後は

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,NN2,NN3,NN4,NN5,NN6,NN7,-1

;VV1:	DB	1,	'行く',0
VV1:	DB	1,	'GO',0

;NN1:	DB	1,	'鈴子のところ',0
NN1:	DB	1,	"REIKO'S HOUSE",0
;NN2:	DB	2,	"清美のところ",0
NN2:	DB	2,	"KIYOMI'S HOUSE",0
;NN3:	DB	3,	"美緒のところ",0
NN3:	DB	3,	"MIO'S HOUSE",0
;NN4:	DB	4,	"瑠璃のところ",0
NN4:	DB	4,	"RURI'S HOUSE",0
;NN5:	DB	5,	"亜希のところ",0
NN5:	DB	5,	"AKI'S HOUSE",0
;NN6:	DB	6,	"星愛のところ",0
NN6:	DB	6,	"SEIA'S HOUSE",0
;NN7:	DB	7,	"恵依美のところ",0
NN7:	DB	7,	"MEIMI'S HOUSE",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;行く　鈴子のところ２	☆ＮＧパターン
S2:		DW	VV1, NN2,  2, M4		;行く　清美のところ２	☆ＮＧパターン
S3:		DW	VV1, NN3,  3, M6		;行く　美緒のところ２	☆ＮＧパターン
S4:		DW	VV1, NN4,  4, M8		;行く　瑠璃のところ２	☆ＮＧパターン
S5:		DW	VV1, NN5,  5, M10		;行く　亜希のところ２	☆ＮＧパターン
S6:		DW	VV1, NN6,  6, M12		;行く　星愛のところ２	☆ＮＧパターン
S7:		DW	VV1, NN7,  7, M14		;行く　恵依美のところ２	☆ＮＧパターン



;イニシャルメッセージ
M1:
	DB	BGM,12
	BAK_INIT 'AB_36_1'
	DB	BUF,B_COPY01
	B_P1 B_FADE
;	DB	'・・・・・・そして、宴の後。'
	DB	".....After the party."
	DB	NEXT
;	DB	'クラスの連中はパラパラと帰り始め、今は半分くらいになっている。'
	DB	"About half of the students go home."
	DB	NEXT
;	DB	'（・・・さてと・・・プレゼント渡さなくっちゃな。）'
	DB	"Now it's time to give the present... "
	DB	NEXT
;	DB	'そう。'
	DB	"Yes..."
	DB	NEXT
;	DB	'俺はクリスマスプレゼントを、感謝を込めて手渡ししようと思っていた。'
	DB	"I brought a Christmas present."
	DB	NEXT
;	DB	'（・・・さあ、あの娘のところにいかなくちゃ・・・）'
	DB	"........The only problem is, who should I give this to?"
	DB G_FLG,G_COPYF,110,110
	DB G_FLG,G_COPYF,120,120
	DB G_FLG,G_COPYF,130,130
	DB G_FLG,G_COPYF,150,150
	DB G_FLG,G_COPYF,160,160
	DB G_FLG,G_COPYF,170,170
	DB G_FLG,G_COPYF,180,180
	DB G_FLG,G_COPYF,159,159
	DW	0000H

M2:		;行く　鈴子のところ１		☆ＯＫパターン
	DB	BUF,B_COPY01
	T_CG 'CT01','W',0,0,1
;	DB	'【%001】：鈴子さん、ちょっといい？'
	DB	"%001:  Reiko...?"
	DB	NEXT
;	DB	'【鈴子】：なあに？'
	DB	"Reiko:  What is it?"
	DB	NEXT
;	DB	'【%001】：・・・あのさ・・・今日、鈴子さんのところに行っていい？'
	DB	"%001:  Um, can I go by your house tonight?"
	DB	PAUSE
;	DB	'渡したいものがあるんだ。'
	DB	" There's something"
	DB	CR
	DB	"I want to give you."
	DB	NEXT
;	DB	'【鈴子】：・・・えっ・・・！'
	DB	"Reiko:  .....What?"
	DB	NEXT
;	DB	'【%001】：・・・ダメかい？'
	DB	"%001:  If you're busy, I'll understand."
	DB	NEXT
	DB	FLG,F_COMPI,255,110,50
	DB	FLG,F_JLW,255
	DW	REIKOX
;	DB	'【鈴子】：・・・う、ううん！全然大丈夫よ！'
	DB	"Reiko:  No, I'm not busy. Please, come by."
	DB	NEXT
;	DB	'【%001】：じゃあ、７時ごろ行くよ。'
	DB	"%001:  I'll be there about seven o'clock."
	DB	NEXT
;	DB	'【鈴子】：うん、分かった。'
	DB	"Reiko:  Okay."
	DB	PAUSE
;	DB	'・・・待ってるから。'
	DB	" I'll see you tonight."
	DB	NEXT
	DB	SINARIO,'CS904_A.OVL',0
	DW	0000H

M4:		;行く　清美のところ１		☆ＯＫパターン
	DB	BUF,B_COPY01
	T_CG 'CT02','W',0,0,1
;	DB	'【%001】：新藤さん、ちょっといい？'
	DB	"%001:  Um, Kiyomi?"
	DB	NEXT
;	DB	'【清美】：はい、なんでしょう？'
	DB	"Kiyomi:  Yes?"
	DB	NEXT
;	DB	'【%001】：・・・あのさ・・・今日、新藤さんのところに行っていい？'
	DB	"%001:  Can I go by your house tonight?"
	DB	PAUSE
;	DB	'渡したいものがあるんだ。'
	DB	" I've got a present..."
	DB	NEXT
;	DB	'【清美】：・・・えっ・・・！'
	DB	"Kiyomi:  You do?"
	DB	NEXT
;	DB	'【%001】：・・・ダメかい？'
	DB	"%001:  Are you busy?"
	DB	NEXT
	DB	FLG,F_COMPI,255,120,50
	DB	FLG,F_JLW,255
	DW	KIYOMIX
;	DB	'【清美】：・・・いえ、大丈夫ですわ。'
	DB	"Kiyomi:  No, not at all."
	DB	NEXT
;	DB	'【%001】：じゃあ、７時ごろ行くよ。'
	DB	"%001:  Okay, I'll see you at seven o'clock."
	DB	NEXT
;	DB	'【清美】：はい、分かりました。'
	DB	"Kiyomi:  Okay."
	DB	PAUSE
;	DB	'・・・お待ちしております。'
	DB	" I'll see you tonight."
	DB	NEXT
	DB	SINARIO,'CS904_B.OVL',0
	DW	0000H

M6:		;行く　美緒のところ１		☆ＯＫパターン
	DB	BUF,B_COPY01
	T_CG 'CT03','W',0,0,1
;	DB	'【%001】：美緒ちゃん、ちょっといい？'
	DB	"%001:  Um, Mio?"
	DB	NEXT
;	DB	'【美緒】：なに？'
	DB	"Mio: Yes?"
	DB	NEXT
;	DB	'【%001】：・・・あのさ・・・今日、美緒ちゃんのところに行っていい？'
	DB	"%001:  I was wondering if I could go by your house tonight?"
	DB	NEXT
;	DB	'渡したいものがあるんだ。'
	DB	"%001:  I've got a present..."
	DB	NEXT
;	DB	'【美緒】：・・・えっ・・・！'
	DB	"Mio:  You do?"
	DB	NEXT
;	DB	'【%001】：・・・ダメかい？'
	DB	"%001:  Are you busy?"
	DB	NEXT
	DB	FLG,F_COMPI,255,130,50
	DB	FLG,F_JLW,255
	DW	MIOX
;	DB	'【美緒】：・・・ううん、そんな事無い。'
	DB	"Mio:  No, you can come over."
	DB	NEXT
;	DB	'【%001】：じゃあ、７時ごろ行くよ。'
	DB	"%001:  Okay, I'll see you at seven o'clock."
	DB	NEXT
;	DB	'【美緒】：うん。'
	DB	"Mio:  Okay."
	DB	PAUSE
;	DB	'・・・先輩、待ってるから。'
	DB	" I'll be waiting."
	DB	NEXT
	DB	SINARIO,'CS904_C.OVL',0
	DW	0000H

M8:		;行く　瑠璃のところ１		☆ＯＫパターン
	DB	BUF,B_COPY01
	T_CG 'CT05','W',0,0,1
;	DB	'【%001】：白水さん、ちょっといい？'
	DB	"%001:  Ruri?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・なに？'
	DB	"Ruri:  .....What?"
	DB	NEXT
;	DB	'【%001】：・・・あのさ・・・今日、白水さんのところに行っていい？'
	DB	"%001:  I was wondering, can I come over to your house"
	DB	CR
	DB	"tonight?"
	DB	NEXT
;	DB	'渡したいものがあるんだ。'
	DB	"%001:  There's something I want to give you."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'【%001】：・・・やっぱ、ダメ？'
	DB	"%001:  I guess you're busy or something."
	DB	NEXT
	DB	FLG,F_JGR,159
	DW	REIX
	DB	FLG,F_COMPI,255,150,50
	DB	FLG,F_JLW,255
	DW	REIX
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  .................."
	DB	PAUSE
;	DB	'いいわ。'
	DB	"No, I'm not busy."
	DB	NEXT
;	DB	'【%001】：・・・・・・ホントに？'
	DB	"%001:  Really?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・別に構わないわ。'
	DB	"Ruri:  .....I don't care if you come over."
	DB	NEXT
;	DB	'【%001】：じゃあ、７時ごろ行くよ。'
	DB	"%001:  Okay, I'll see you at seven o'clock."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・%001君、私の家知ってるの？'
	DB	"Ruri:  Do you know where I live?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ......................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................."
	DB	PAUSE
;	DB	'あは、あは、あはははははは・・・・・・・・'
	DB	"Hahaha! No, I don't!"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・いいわ。付いてきて。'
	DB	"Ruri:  You can walk home with me."
	DB	NEXT
;	DB	'【%001】：・・・・・・ま、待ってよ白水さん！'
	DB	"%001:  Okay. Um, wait up, Ruri!"
	DB	NEXT
	DB	SINARIO,'CS904_E.OVL',0
	DW	0000H

M10:		;行く　亜希のところ１		☆ＯＫパターン
	DB	BUF,B_COPY01
	T_CG 'CT06','W',0,0,1
;	DB	'【%001】：亜希ちゃん、ちょっといい？'
	DB	"%001:  Aki?"
	DB	NEXT
;	DB	'【亜希】：なに？'
	DB	"Aki:  What?"
	DB	NEXT
;	DB	'【%001】：・・・あのさ・・・今日、亜希ちゃんのところに行っていい？'
	DB	"%001:  I was wondering, can I go over to your house tonight?"
	DB	NEXT
;	DB	'渡したいものがあるんだ。'
	DB	"%001:  I've got something to give you."
	DB	NEXT
;	DB	'【亜希】：・・・えっ・・・！'
	DB	"Aki:  You do?"
	DB	NEXT
;	DB	'【%001】：・・・ダメかい？'
	DB	"%001:  Are you busy?"
	DB	NEXT
	DB	FLG,F_COMPI,255,160,50
	DB	FLG,F_JLW,255
	DW	AKIX
;	DB	'【亜希】：・・・いいわよ。'
	DB	"Aki:  ....No, you can come over."
	DB	NEXT
;	DB	'【%001】：じゃあ、７時ごろ行くよ。'
	DB	"%001:  Okay, I'll be there at seven o'clock."
	DB	NEXT
;	DB	'【亜希】：うん。'
	DB	"Aki:  Okay."
	DB	PAUSE
;	DB	'・・・じゃ。'
	DB	"...Bye."
	DB	NEXT
	DB	SINARIO,'CS904_F.OVL',0
	DW	0000H

M12:		;行く　星愛のところ１		☆ＯＫパターン
	DB	BUF,B_COPY01
	T_CG 'CT07','W',0,0,1
;	DB	'【%001】：吉田、ちょっといいか？'
	DB	"%001:  Seia?"
	DB	NEXT
	DB	FLG,F_COMPI,255,170,50
	DB	FLG,F_JLW,255
	DW	SEIAX
;	DB	'【星愛】：・・・まあ、ちょうど良かったわ。'
	DB	"Seia:  Ah, %001. I was just looking for you."
	DB	NEXT
;	DB	'【%001】：・・・ちょうどいい？'
	DB	"%001:  You were?"
	DB	NEXT
;	DB	'【星愛】：実はわたくし、これから教会に行かなくてはなりませんの。'
	DB	"Seia:  Yes, I have to go to church after this."
	DB	NEXT
;	DB	'【%001】：・・・教会に？'
	DB	"%001:  Church?"
	DB	NEXT
;	DB	'【星愛】：ええ、ちょっと用がありまして。'
	DB	"Seia:  Yes, you know."
	DB	PAUSE
;	DB	'%001君、お手伝いをお願い出来ませんか？'
	DB	" %001, I was wondering if you would"
	DB	CR
	DB	"come and help me."
	DB	NEXT
;	DB	'【%001】：・・・いいよ、俺も話があったし。'
	DB	"%001:  Okay. There's something I want to talk to you"
	DB	CR
	DB	"about, too."
	DB	NEXT
;	DB	'【星愛】：では、参りましょう。'
	DB	"Seia:  Well, shall we go?"
	DB	NEXT
	DB	SINARIO,'CS904_G.OVL',0
	DW	0000H

M14:		;行く　恵依美のところ１		☆ＯＫパターン
	DB	BUF,B_COPY01
	T_CG 'CT08','W',0,0,1
;	DB	'【%001】：中野、ちょっといいか？'
	DB	"%001:  Meimi?"
	DB	NEXT
	DB	FLG,F_COMPI,255,180,50
	DB	FLG,F_JLW,255
	DW	MEIMIX
;	DB	'【恵依美】：・・・あ、%001。ちょうど良かったわ。'
	DB	"Meimi:  Ah, %001. I was looking for you."
	DB	NEXT
;	DB	'【%001】：・・・ちょうどいい？'
	DB	"%001:  For me?"
	DB	NEXT
;	DB	'【恵依美】：クリスマスプレゼント、家に置いて来ちゃった。'
	DB	"Meimi:  I left the Christmas present I got for you at"
	DB	CR
	DB	"my house."
	DB	NEXT
;	DB	'あげるからさ、家まで一緒に来てくれない？'
	DB	"Meimi:  Will you come home with me tonight?"
	DB	NEXT
;	DB	'【%001】：・・・ああ、いいよ。'
	DB	"%001:  Okay."
	DB	NEXT
;	DB	'【恵依美】：じゃあ、行こ！'
	DB	"Meimi:  Well, let's go!"
	DB	NEXT
;	DB	'【%001】：・・・おい、引っ張るなって！'
	DB	"%001:  Don't pull my arm like that!"
	DB	NEXT
	DB	SINARIO,'CS904_H.OVL',0
	DW	0000H

REIKOX:
;	DB	'【鈴子】：・・・ごめんなさい。'
	DB	"Reiko:  ....I'm sorry, you can't."
	DB	PAUSE
;	DB	'今日はちょっと、立て込んでるの。'
	DB	" I'm really busy today."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか。'
	DB	"%001:  .....I see."
	DB	NEXT
;	DB	'【鈴子】：ホントにごめんね。'
	DB	"Reiko:  I wish I weren't busy, but I am."
	DB	NEXT
;	DB	'【%001】：・・・いや、いいんだ。気にしないで。'
	DB	"%001:  Okay, well, nevermind."
	DB C_BLD,C_N_ON,1,1					;「行く　鈴子のところ」消し
	B_P1 B_FADE
	EF_SET 101
	DW	0000H

KIYOMIX:
;	DB	'【清美】：・・・申し訳ありません。'
	DB	"Kiyomi:  ......I'm sorry."
	DB	PAUSE
;	DB	'今日は、家族のものとパーティーがありますので。'
	DB	" We've got a family Christmas Party"
	DB	CR
	DB	"tonight."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか。'
	DB	"%001:  ...........I see."
	DB	NEXT
;	DB	'【清美】：本当に申し訳ありません。'
	DB	"Kiyomi:  I'm really sorry."
	DB	NEXT
;	DB	'【%001】：・・・いや、いいんだ。気にしないで。'
	DB	"%001:  Oh, it's okay. Nevermind."
						;「行く　清美のところ」消し
	DB C_BLD,C_N_ON,1,2
	B_P1 B_FADE
	EF_SET 102
	DW	0000H

MIOX:
;	DB	'【美緒】：・・・ごめんなさい。'
	DB	"Mio:  I'm sorry."
	DB	PAUSE
;	DB	'今日は親戚みんなで、パーティーするんだ。'
	DB	" I've got a party at my grandmother's house."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか。'
	DB	"%001:  .....I see."
	DB	NEXT
;	DB	'【美緒】：ホントにごめんなさい。'
	DB	"Mio:  I'm really sorry."
	DB	NEXT
;	DB	'【%001】：・・・いや、いいんだ。気にしないで。'
	DB	"%001:  Oh, it's okay. Nevermind."
	DB C_BLD,C_N_ON,1,3					;「行く　美緒のところ」消し
	B_P1 B_FADE
	EF_SET 103
	DW	0000H

REIX:
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ..................."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・そか。ごめんな、変な事言って。'
	DB	"%001:  I guess you're busy. Well, nevermind."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ..................."
	DB C_BLD,C_N_ON,1,4				;「行く　瑠璃のところ」消し
	B_P1 B_FADE
	EF_SET 104
	DW	0000H

AKIX:
;	DB	'【亜希】：・・・ちょっと今日は、空いてないわね。'
	DB	"Aki:  I'm sorry, I'm busy tonight."
	DB	NEXT
;	DB	'【%001】：・・・・・・そか。'
	DB	"%001:  ...........I see."
	DB	NEXT
;	DB	'【亜希】：また今度にしてくれる？'
	DB	"Aki:  Ask me again later, okay?"
	DB	NEXT
;	DB	'【%001】：・・・いや、いいんだ。気にしないで。'
	DB	"%001:  No, it's nothing, really. Don't worry about it."
	DB C_BLD,C_N_ON,1,5					;「行く　亜希のところ」消し
	B_P1 B_FADE
	EF_SET 105
	DW	0000H

SEIAX:
;	DB	'【星愛】：なんでしょう？'
	DB	"Seia:  What is it?"
	DB	NEXT
;	DB	'【%001】：・・・あのさ・・・今日、吉田のところに行っていいか？'
	DB	"%001:  I was wondering, can I go to your house tonight?"
	DB	PAUSE,CR
;	DB	'渡したいものがあるんだ。'
	DB	"I want to give you something."
	DB	NEXT
;	DB	'【星愛】：・・・えっ・・・！'
	DB	"Seia:  To me?"
	DB	NEXT
;	DB	'【%001】：・・・ダメか？'
	DB	"%001:  .........What's wrong?"
	DB	NEXT
;	DB	'【星愛】：・・・すみません。'
	DB	"Seia:  I'm sorry..."
	DB	PAUSE
;	DB	'今日は、教会のお手伝いをしなくてはなりませんの。'
	DB	" I've got to help out at the Church tonight."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  .......I see."
	DB	NEXT
;	DB	'【星愛】：ごめんなさいね。'
	DB	"Seia:  I'm sorry."
	DB	NEXT
;	DB	'【%001】：・・・いや、いいんだ。気にしないでくれ。'
	DB	"%001:  Oh, it's okay. Don't worry about it."
	DB C_BLD,C_N_ON,1,6					;「行く　星愛のところ」消し
	B_P1 B_FADE
	EF_SET 106
	DW	0000H

MEIMIX:
;	DB	'【恵依美】：なに？'
	DB	"Meimi:  Yes?"
	DB	NEXT
;	DB	'【%001】：・・・あのさ・・・今日、中野のところに行っていいか？'
	DB	"%001:  I was wondering, can I go to your house tonight?"
	DB	PAUSE
;	DB	'渡したいものがあるんだ。'
	DB	" I've"
	DB	CR
	DB	"got something I want to give you."
	DB	NEXT
;	DB	'【恵依美】：・・・えっ・・・！'
	DB	"Meimi:  ....Eh?"
	DB	NEXT
;	DB	'【%001】：・・・ダメか？'
	DB	"%001:  Are you busy tonight?"
	DB	NEXT
;	DB	'【恵依美】：・・・ごっめーん！'
	DB	"Meimi:  I'm sorry!"
	DB	PAUSE
;	DB	'今日はパパが帰って来て、久しぶりに家族がそろう日なの。'
	DB	" My father's coming home tonight, and"
	DB	CR
	DB	"we're going to spend the evening as a family."
	DB	NEXT
;	DB	'【%001】：・・・そか。'
	DB	"%001:  ........I see."
	DB	NEXT
;	DB	'【恵依美】：ごめんね～。'
	DB	"Meimi:  I'm sorry."
	DB	NEXT
;	DB	'【%001】：・・・いや、いいんだ。気にしないでくれ。'
	DB	"%001:  No, it's okay. Don't worry about it."
	DB C_BLD,C_N_ON,1,7					;「行く　恵依美のところ」消し
	B_P1 B_FADE
	EF_SET 107
	DW	0000H

M_EXIT:		;ＯＫが誰もいない場合
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,8,255,101,102,103,104,105,106,107
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'【%001】：・・・結局みんな、今夜は予定がいっぱいか・・・'
	DB	"%001:  .......Everyone's doing something tonight."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'【%001】：しょーがない。家でささやかにやるか。'
	DB	"%001:  Hmm. I guess I'll just go home."
	DB	NEXT
;	DB	'【%001】：去年と同じように・・・・・・'
	DB	"%001:  Crap..."
	DB	NEXT
	B_O B_SUDA
	DB	SINARIO,'CSA01.OVL',0
	DW	0000H


end
