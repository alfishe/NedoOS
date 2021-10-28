;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１７
;		今日子の特別授業４

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2
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
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'考える',0
VV1:	DB	1,	'THINK',0
;VV2:	DB	2,	'受ける',0
VV2:	DB	2,	'ACCEPT',0

;NN1:	DB	1,	'特別授業',0
NN1:	DB	1,	'SPECIAL LESSON',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;考える
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7, M8		;受ける　特別授業６


;イニシャルメッセージ
M1:
	DB	BGM,32
	E_CG B_SUDA,"AE_123"
;	DB	'【今日子】：・・・んっ・・・！'
	DB	"Kyoko:  .........Mm!"
	DB	NEXT
;	DB	'【%001】：・・・うわっ・・・！'
	DB	"%001:  .............Mmmmm..."
	DB	NEXT
;	DB	'ずぷぷぷっ'
	DB	"*splooch*"
	DB	NEXT
;	DB	'音さえ立てて、俺の一部が先生の中に沈みこんで行く。'
	DB	"With a smooth, wet sound, my cock disappeared into her."
	DB	NEXT
;	DB	'途端に淒まじい感覚が俺の背筋を駆け抜け、脳天を突き抜けてどこかへと消えて行く。'
	DB	"As I moved into her, a wonderfully sharp sensation coursed"
	DB	CR
	DB	"through my body, energizing my body with pleasure."
	DB	NEXT
;	DB	'【%001】：・・・こ・・・'
	DB	"%001:  Is..."
	DB	NEXT
;	DB	'【%001】：これが『女性』・・・？'
	DB	"%001:  Is this.....woman?"
	DB	NEXT
;	DB	'【今日子】：そうよ・・・'
	DB	"Kyoko:  Yes..."
	DW	0000H

M2:		;考える
;	DB	'あ・・・頭の中が真っ白だ・・・'
	DB	"I can't think of anything... There's nothing but pure"
	DB	CR
	DB	"white..."
	DB	NEXT
;	DB	'こ・・・これが・・・女の人・・・'
	DB	"This is.....woman!"
	DW	0000H

M3:		;受ける　特別授業１
;	DB	'【今日子】：どう・・・？気持ちいい？'
	DB	"Kyoko:  Does it feel good?"
	DB	NEXT
;	DB	'【%001】：・・・き・・・気持ちいいと言うか何と言うか・・・'
	DB	"%001:  ..... Feel good? I don't really know how to explain"
	DB	CR
	DB	"it..."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;受ける　特別授業２
;	DB	'【今日子】：いい？動くわよ・・・'
	DB	"Kyoko:  I'm going to move a little..."
	DB	NEXT
;	DB	'ずるっ'
	DB	"*splurch*"
	DB	NEXT
;	DB	'【%001】：・・・うあっ・・・！'
	DB	"%001:  ..........Wah!"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;受ける　特別授業３
;	DB	'【今日子】：・・・ん・・・んんっ・・・'
	DB	"Kyoko:  Mmmm...mmm..."
	DB	NEXT
;	DB	'【%001】：・・・うっ・・・くっ・・・'
	DB	"%001:  ...........It's good..."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;受ける　特別授業４
;	DB	'【%001】：せ・・・先生！で、出そう・・・！'
	DB	"%001:  Sensei! I'm coming...!!"
	DB	NEXT
;	DB	'【今日子】：ダメよ！まだダメ！'
	DB	"Kyoko:  No! You have to wait!"
	DB	NEXT
;	DB	'【%001】：そ・・・そんな事言ったって・・・'
	DB	"%001:  .....I don't think there's anything I can do about"
	DB	CR
	DB	"it..."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M7:		;受ける　特別授業５
;	DB	'【%001】：・・・うぅ・・・出るっ・・・'
	DB	"%001:  .......I'm coming!!"
	DB	NEXT
;	DB	'【今日子】：ダメよ！・・・もう少し！'
	DB	"Kyoko:  No.... Just a little more...!!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・だめだぁっ！！'
	DB	"%001:  ........I can't hold it!!"
	B_O B_FADE
	DB	NEXT
;	DB	'どくっどくっどくっどくっ'
	DB	"..............!!"
	DB	NEXT
;	DB	'瞬間、身体の中心から何かが尖端に向かって迸る。'
	DB	"In the next moment, I felt like my center was being pulled"
	DB	CR
	DB	"wonderfully out of me..."
	DB	NEXT
;	DB	'【今日子】：・・・あ！・・・んっ・・・'
	DB	"Kyoko:  ...........Ah! Ah!"
	DB	FLG,F_COPYI,2,5
	DW	0000H

M8:		;受ける　特別授業６
;	DB	'【今日子】：・・・もう・・・'
	DB	"Kyoko:  .........You came too early."
	DB	NEXT
;	DB	'【%001】：・・・す・・・すんません・・・'
	DB	"%001:  I'm sorry..."
	DB	NEXT
;	DB	'【今日子】：・・・・・・ま、初めてだからしゃーないか。'
	DB	"Kyoko:  It's okay. It was your first time."
	DB	PAUSE
;	DB	'いい？男は出したら終わりだけど、女は違うの。'
	DB	" When a man comes,"
	DB	CR
	DB	"it's all over for him. But women aren't like that."
	DB	NEXT
;	DB	'【%001】：・・・はい。'
	DB	"%001:  Okay."
	DB	NEXT
;	DB	'【今日子】：ちゃんと、気持ち良くしてあげなきゃダメよ。'
	DB	"Kyoko:  You have to make the woman feel good, too."
	DB	PAUSE
;	DB	'わかった？'
	DB	" Is that"
	DB	CR
	DB	"understood?"
	DB	NEXT
;	DB	'【%001】：はい。'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【今日子】：宜しい。'
	DB	"Kyoko:  Fine."
	DB	PAUSE
;	DB	'・・・じゃあ第二ラウンド、行ってみましょ～か。'
	DB	" Shall we go to the second round?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ....................."
	DB	PAUSE
;	DB	'はい？'
	DB	"What?"
	DB	NEXT
;	DB	'【今日子】：今の君じゃあ、合格点あげられないもの。'
	DB	"Kyoko:  I can't give you a passing grade with that"
	DB	CR
	DB	"performance."
	DB	PAUSE
;	DB	'ちゃんと満足させる事を覚えるまでは、とことん教えてあげるわ。'
	DB	" I've got to keep teaching you until you learn"
	DB	CR
	DB	"how to satisfy a woman."
	DB	NEXT
;	DB	'【%001】：・・・・・・あう・・・・・・'
	DB	"%001:  ..........Okay."
	DB	NEXT
;	DB	'・・・・・・そして、今日子先生の授業は朝まで続けられた・・・・・・'
	DB	"In the end, Sensei's special lesson went on until"
	DB	CR
	DB	"morning."
	DB	NEXT
	DB	SINARIO,'CS818.OVL',0
	DW	0000H


end