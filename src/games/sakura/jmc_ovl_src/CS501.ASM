;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０１
;		林間学校　１－Ａ大決戦！鈴子ｖｓ祥子

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	NN1,NN2,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0


;NN1:	DB	1,	'鈴子',0
NN1:	DB	1,	'REIKO',0
;NN2:	DB	2,	'祥子',0
NN2:	DB	2,	'SHOKO',0


;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV2, NN1,  2, M2, M3, M4		;話す　鈴子３
S2:		DW	VV2, NN2,  3, M5, M6, M7		;話す　祥子３
S3:		DW	VV1, -1,  1, M8, M9		;見る


;イニシャルメッセージ
M1:
	DB	BGM,6
	BAK_INIT 'AB_36_4'
;	DB	'・・・梅雨もあけた６月下旬。'
	DB	"It's late June. The month-long Japanese rainy season has"
	DB	CR
	DB	"just started."
	DB	NEXT
	DB	"I hate this time of year. That's why I'm happy the entire"
	DB	CR
	DB	"school is off to Hokkaido for our school camp, because"
	DB	CR
	DB	"Hokkaido is far enough north to not have rainy season."
	DB	NEXT
;	DB	'【%001】：・・・・・・うーん・・・・・・'
	DB	"%001:  Hmmm..."
	DB	NEXT
;	DB	'俺は、真っ白い紙の前で唸り声を上げていた。'
	DB	"I was struggling over a blank sheet of paper, trying to"
	DB	CR
	DB	"figure out what to write."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT14','S',0,37,2
	TU_CG 'CT08','S',0,0,3
	T_CG 'CT07','S',0,23,4
	DB	ANI,A_ON,3
	DB	ANI,A_ON,2
;	DB	'【恵依美】：・・・どう？決まった？'
	DB	"Meimi:  Well? Did you decide?"
	DB	NEXT
;	DB	'【%001】：いんや、まだ。'
	DB	"%001:  No, not yet."
	DB	NEXT
;	DB	'【星愛】：明日の朝までに提出ですから、早めに書いて下さいね。'
	DB	"Seia:  You have to turn your paper in by tomorrow morning,"
	DB	CR
	DB	"so you'd better hurry."
	DB	NEXT
;	DB	'【%001】：分かってるって。'
	DB	"%001:  I know that."
	DB	NEXT
;	DB	'【誠】：そんなもん、ぱっぱっと書いちまえって。'
	DB	"Makoto:  Why are you taking so long?"
	DB	NEXT
;	DB	'たかだか、林間学校の班決めだろ～が。'
	DB	"Makoto:  Just decide the people you want to be in the same "
	DB	CR
	DB	"group with at camp and write it on the form."
	DB	NEXT
;	DB	'・・・大体、希望通りになるとは限らね～んだ。とっとと决めちまえ。'
	DB	"Makoto:  You don't even know if you'll get to be with them,"
	DB	CR
	DB	"anyway."
	DB	NEXT
;	DB	'【%001】：そらま～そ～だが・・・・・・'
	DB	"%001:  You're right..."
	DB	NEXT
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	TU_CG 'CT03','S','K',10,2
	T_CG 'CT01','S','K',35,4
	DB	ANI,A_ON,2
;	DB	'【鈴子】：%001く～ん！',CR
	DB	"Reiko:  %001!"
	DB	PAUSE
	DB	CR
;	DB	'【美緒】：%001先輩！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'【鈴子・美緒】：お昼一緒に食べよっ！'
	DB	"Mio & Reiko:  Let's eat lunch together!"
	DB	NEXT
	T_CG1 'CT02','S','K',0,3
	DB	ANI,A_ON,4
	DB	ANI,A_ON,2
;	DB	'【清美】：・・・あら、鈴子さん美緒さん、こんにちは。'
	DB	"Kiyomi:  Hello, Reiko and Mio. How are you?"
	DB C_BLD,C_N_ON,2,2
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DW	0000H

M8:		;見る
;	DB	'・・・こーゆーのって、人に見られてると書けねーよな・・・'
	DB	"I can't decide who I want to be grouped with at camp"
	DB	CR
	DB	"right now. There're too many people around."
	DW	0000H

M9:		;見る２
;	DB	'なんか・・・空気がプラズマ化してねぇか？'
	DB	"The air's getting hot, wouldn't you say?"
	DW	0000H

M2:		;話す　鈴子１
;	DB	'【鈴子】：ねえ%001君・・・林間学校の希望、書いた？'
	DB	"Reiko:  %001, did you decide who you wanted to be with at camp?"
	DB	NEXT
;	DB	'【%001】：いんや、まだ。'
	DB	"%001:  No, not yet."
	DB	NEXT
;	DB	'【鈴子】：だったら',CR
	DB	"Reiko:  In that case......."
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG 'CT04','S','K',10,1
;	DB	'【祥子】：あたしの名前書いてぇ！'
	DB	CR
	DB	"Shoko:  Choose me, okay?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................................."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  .................................."
	DB	NEXT
;	DB	'【祥子】：あららぁ？どしたのぉみんな、固まったりなんかしてぇ～？'
	DB	"Shoko:  Huh? What did I say? Everyone got so serious all"
	DB	CR
	DB	"of the sudden."
	DB	NEXT
	DB	ANI,A_OFF
	T_CG1 'CT01','S','D',35,2
	DB	ANI,A_ON,1
;	DB	'【鈴子】：し、祥子！あんたどっから湧いて来たのよっ！？'
	DB	"Reiko:  Shoko! What are you doing here?!"
	DB	NEXT
	K_CG 'CT04','D',10,3
	DB	ANI,A_ON,2
;	DB	'【祥子】：あ、鈴子ちゃんひっど～い。あたしぃ、ぼーふらじゃないもん！'
	DB	"Shoko:  If you're allowed to be here, I am too!"
	DB	NEXT
;	DB	'【鈴子】：ボーフラの方がマシよっ！あんたみたいにところ構わず出てこないからっ！'
	DB	"Reiko:  No, you aren't! Now off with you!"
	DB	NEXT
	K_CG 'CT04','I',10,4
	DB	ANI,A_ON,2
;	DB	'【祥子】：・・・鈴子ちゃん、ひどい・・・あたし、泣いちゃうぅ。'
	DB	"Shoko:  You're so mean, Reiko! I... I'm going to cry!"
	DB	NEXT
;	DB	'【鈴子】：嘘泣きしないでっっ！'
	DB	"Reiko:  I said leave!"
	DB	FLG,F_COPYI,1,1
	DB	FLG,F_COPYI,2,1
	DB C_BLD,C_N_OFF,2,2
	DW	0000H

M3:		;話す　鈴子２
;	DB	'【鈴子】：%001君！こんなの入れたらロクな事にならないわよ！'
	DB	"Reiko:  %001, never mind Reiko, okay? She's not worth talking"

	DB	CR

	DB	"to."
	DB	NEXT
	K_CG 'CT04','D',10,5
	DB	ANI,A_ON,2
;	DB	'【祥子】：あ～！それってぇ「びぼうちょーしゅー」って言うのよぉ？'
	DB	"Shoko:  Ah! I can't believe you said that! That's *slender*!"
	DB	NEXT
;	DB	'【清美】：・・・あの・・・それを言うなら「誹謗中傷」では・・・'
	DB	"Kiyomi:  Excuse me, I think the word you're looking for"
	DB	CR
	DB	"is *slander*."
	DB	NEXT
;	DB	'【祥子】：とにかくう！ちょっとひどいって感じぃ～！'
	DB	"Shoko:  Whatever. She's so mean. I hate her!"
	DB	NEXT
;	DB	'【鈴子】：そーゆー事は、自分の悪行を振り返ってから言いなさい！'
	DB	"Reiko:  As if you're perfect."
	DB	NEXT
	K_CG 'CT04','K',10,6
	DB	ANI,A_ON,2
;	DB	'【祥子】：ふるふる。あたしぃ、悪いことなんてしてないも～ん。'
	DB	"Shoko:  I'm not perfect, but I'm not mean like you."
	DB	NEXT
;	DB	'【鈴子】：嘘おっしゃいっっ！！'
	DB	"Reiko:  Liar!"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M4:		;話す　鈴子３
;	DB	'【鈴子】：%001君・・・説明会の時のこと、忘れてないわよね？'
	DB	"Reiko:  %001, you haven't forgotten about what happened"
	DB	CR
	DB	"the first week, have you?"
	DB	NEXT
;	DB	'【%001】：・・・う、うん。'
	DB	"%001:  ......No."
	EF_SET 101
	DW	0000H

M5:		;話す　祥子１
	K_CG 'CT04','K',10,6
	DB	ANI,A_ON,2
;	DB	'【祥子】：ねぇねぇしゅ～君・・・あたしの作ったカレー、食べたくなぁい？'
	DB	"Shoko:  %001, I want to make curry for you. Would that"
	DB	CR
	DB	"make you happy?"
	DB	NEXT
;	DB	'【鈴子】：%001君、止めておいた方がいいわよ。'
	DB	"Reiko:  I wouldn't if I were you, %001."
	DB	PAUSE
;	DB	'祥子の料理、劇薬だから。'
	DB	" Shoko's cooking is"
	DB	CR
	DB	"horrible."
	DB	NEXT
	K_CG 'CT04','D',10,5
	DB	ANI,A_ON,2
;	DB	'【祥子】：ぶ～、何にも作れないよりマシだも～ん。'
	DB	"Shoko:  At least I can cook! What can you do?"
	DB	NEXT
;	DB	'【鈴子】：なんですってえ！'
	DB	"Reiko:  What did you say to me?"
	DB	NEXT
;	DB	'【%001】：・・・・・・マシなのか？'
	DB	"%001:  Did she say 'at least'....?"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M6:		;話す　祥子２
	K_CG 'CT04','K',10,6
	DB	ANI,A_ON,2
;	DB	'【祥子】：ねぇねぇしゅ～君。あたしとぉ、夜の海岸でぇ'
	DB	"Shoko:  %001, %001, do you want to take a romantic walk"
	DB	CR
	DB	"on the beach tonight?"
	DB	NEXT
;	DB	'【鈴子】：あんたの場合は『エロチック』でしょ？'
	DB	"Reiko:  Don't you mean *erotic* walk?"
	DB	NEXT
;	DB	'【祥子】：・・・も～、鈴子ちゃんったら・・・えっち。'
	DB	"Shoko:  Oh, Reiko. You're such a bad woman."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・あなたにだけは言われたくないわね、'
	DB	"Reiko:  Keep your observations to yourself, thanks."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................"
	DB	NEXT
;	DB	'（・・・なんか、火薬庫にいるよーな気がして来た・・・）'
	DB	".............They're really going at it."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M7:		;話す　祥子３
;	DB	'【祥子】：・・・とにかくぅ、あたしと「せいしゅん」しましょ？'
	DB	"Shoko:  Shuji...I've got the ice cubes."
	DB	NEXT
;	DB	'【%001】：・・・・・・考えとく・・・・・・'
	DB	"%001:  ........Great."
	EF_SET 102
	DW	0000H

M_EXIT:		;
	DB	FLG,F_AND,255,101,102
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'きーんこーんかーんこーん'
	DB	"*DING DONG DING DONG*"
	DB	NEXT
;	DB	'【%001】：・・・あ、ベルだ。'
	DB	"%001:  Ah, it's the bell."
	DB	NEXT
;	DB	'【祥子】：・・・それじゃしゅ～君、またねん☆'
	DB	"Shoko:  Okay, well, I'll see you later."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・とにかく、祥子の名前だけは書いちゃダメよ！'
	DB	"Reiko:  Whatever you do, don't write Shoko's name on that"

	DB	CR

	DB	"paper!"
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	PAUSE
;	DB	'ふう。'
	DB	"Hmmmm."
	DB	NEXT
	DB	SINARIO,'CS501_1.OVL',0
	DW	0000H


end