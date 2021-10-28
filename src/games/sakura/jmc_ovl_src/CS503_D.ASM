;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０３＿Ｄ
;		山道　祥子と会う

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
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'祥子',0
NN1:	DB	1,	'SHOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　祥子
S2:		DW	VV2, NN1,  2, M3, M4, M5		;話す　祥子


;イニシャルメッセージ
M1:
	DB	BGM,21
	BAK_INIT 'AB_08_1'
	B_P1 B_SUDA
;	DB	'【%001】：薪拾いっつっても、手頃な枝はみんな拾われた後だしな・・・'
	DB	"The hard part of gathering firewood is after you find it."
	DB	NEXT
;	DB	'【%001】：そこに落ちてる丸太拾って帰っても仕方ねえか。'
	DB	"You have to carry it all back to camp."
	DB	NEXT
;	DB	'【%001】：もっと森の奥に入らないとダメか？'
	DB	"I guess I'll have to go a little bit deeper into the forest."
	DB	NEXT
;	DB	'【？】：あ～！しゅ～君だぁ！'
	DB	"???:  Huh? %001!"
	DB	NEXT
;	DB	'【%001】：え゛？'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'（・・・この喋り方は・・・）'
	DB	"That voice! Why, it must be..."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT04','T','K',10,1
;	DB	'【祥子】：わ～い、しゅ～君だしゅ～君だぁ！'
	DB	"Shoko:  I'm so happy to see you, %001!"
	DB	NEXT
;	DB	'【%001】：・・・げげ・・・'
	DB	"%001:  ......Um, yeah."
	DB G_FLG,G_COPYF,140,140
	DB	FLG,F_CALI,140,10
	DB G_FLG,G_COPYG,140,140
	DB G_FLG,G_COPYI,159,1
	DW	0000H

M2:		;見る　祥子
;	DB	'なんか、小枝を抱えている。'
	DB	"She's holding some small twigs."
	DB	NEXT
;	DB	'・・・まさか、これで薪を集めた、って言う気じゃないだろうな・・・'
	DB	"I hope she doesn't think that's going to count as firewood."
	DW	0000H

M3:		;話す　祥子
;	DB	'【祥子】：こんなところで会うなんてぇ・・・やっぱあたし達ぃ、'
	DB	"Shoko:  I can't believe we ran into each other like this out"
	DB	CR
	DB	"here. It must be destiny!"
	DB	NEXT
;	DB	'【%001】：ち、ち、ち、違うっ！'
	DB	"%001:  You're wrong!"
	DB	PAUSE
;	DB	'俺は単に、薪を拾いに来ただけだっ！'
	DB	" I was just trying to find some firewood!"
	DB	NEXT
;	DB	'【祥子】：も～～～～～～っ！またまた照れちゃってぇ！'
	DB	"Shoko:  Oh! You're just being shy with me again."
	DB	NEXT
;	DB	'【%001】：違うっっ！'
	DB	"%001:  No, I'm serious!"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　祥子
;	DB	'【%001】：そんな事よりっ！西野さん、薪はっ！？'
	DB	"%001:  Nevermind that now. Did you get some firewood?"
	DB	NEXT
;	DB	'【祥子】：大丈夫ぅ、ちゃ～んと拾ってあるも～ん。'
	DB	"Shoko:  Yep, I got a whole bunch."
	DB	PAUSE
;	DB	'ほらほらぁ。'
	DB	" See?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ...................."
	DB	PAUSE
;	DB	'こんだけ？'
	DB	"That's all?"
;	DB	NEXT
;	DB	'【祥子】：だってぇ、木の枝だって重いしぃ～。'
;	DB	"Shoko:  Well, those branches can be pretty heavy..."
;	DB	NEXT
;	DB	'【%001】：・・・「箸より重いもの持ったこと無い」とか言いたいの？'
;	DB	"%001:  You mean you've never lifted anything heavier than"
;	DB	CR
;	DB	"firewood?"
;	DB	NEXT
;	DB	'【祥子】：まっさかぁ～、丼くらい持ったことあるしぃ～。'
;	DB	"Shoko:  Of course I have! I've lifted a big ramen bowl, for"
;	DB	CR
;	DB	"example..."
;	DB	NEXT
;	DB	'【%001】：・・・・・・'
;	DB	"%001:  ................."
;	DB	NEXT
;	DB	'【%001】：そらまぁ、箸よりは重いだろーな。'
;	DB	"%001:  Well, that is heavier than firewood."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　祥子
;	DB	'ゴロゴロゴロ・・・'
	DB	"*BOOM*"
	DB	NEXT
;	DB	'【祥子】：え、なになに？'
	DB	"Shoko:  What's that?"
	DB	NEXT
;	DB	'急に風が強くなったかと思うと、今の今まで青かった空が真っ黒な雲に覆われた。'
	DB	"Suddenly the wind picked up, and the sky got darker."
	DB	NEXT
;	DB	'【%001】：こりゃ、一雨くるな。'
	DB	"%001:  Looks like rain."
	DB	NEXT
;	DB	'・・・と、言ったか言わないかのうちに叩きつけるような雨が降って来た。'
	DB	"The moment I spoke, it started:  first in little droplets,"
	DB	CR
	DB	"then more."
	DB	NEXT
	T_CG 'CT04','T',0,10,2
;	DB	'【祥子】：うわ～、ちょっとずぶ濡れ～、みたいな～。'
	DB	"Shoko:  What'll we do? We're going to get soaked!"
	DB	NEXT
;	DB	'【%001】：・・・えっと・・・どこか・・・'
	DB	"%001:  Well..."
	DB	NEXT
;	DB	'【%001】：・・・あ、あそこに洞窟がある。'
	DB	"%001:  How about that cave over there?"
	DB	NEXT
;	DB	'【祥子】：じゃあじゃあ、そこ行く～。'
	DB	"Shoko:  Okay, let's hurry!"
	DB	NEXT
;	DB	'俺達は手近な洞窟に駆け込んだ。'
	DB	"We ran for the cave."
	DB	NEXT
	B_O B_SUDA
	DB	SINARIO,'CS504_D.OVL',0
	DW	0000H


end
