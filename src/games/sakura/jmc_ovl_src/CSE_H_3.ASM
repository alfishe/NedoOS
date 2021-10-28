;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　恵依美３
;		
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
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	NN3,-1

;VV1:	DB	1,	'話す',0
VV1:	DB	1,	'TALK',0
;VV2:	DB	2,	'舐める',0
VV2:	DB	2,	'LICK',0
;VV3:	DB	3,	'撫でる',0
VV3:	DB	3,	'CARESS',0

;NN1:	DB	1,	'恵依美',0
NN1:	DB	1,	'MEIMI',0
;NN2:	DB	2,	'○○○○',0
NN2:	DB	2,	'PUSSY',0
;NN3:	DB	3,	'髪',0
NN3:	DB	3,	'MUFF',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M9		;話す　恵依美１
S2:		DW	VV2, NN2,  2, M2, M3, M4, M5, M6		;舐める　○○○○５
S3:		DW	VV3, NN3,  3, M7, M8		;撫でる　髪２


;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'・・・俺は中野をひっくり返し、お尻を目の前に持って来た。'
	DB	"...I flipped Meimi over, so that her ass was up in the"
	DB	CR
	DB	"air. Her asshole was inches from my face."
	E_CG B_SUDA,'AE_104'
;	DB	NEXT
;	DB	'【恵依美】：・・・・・・%001・・・・・・恥ずかしいよう・・・・・・'
;	DB	"Meimi:  .....%001..... This is so embarrassing..."
	DW	0000H

M2:		;舐める　○○○○１
;	DB	'開きかけ、密を滴らせ始めている花弁に口を付ける。'
	DB	"I put my mouth against her pussy, which moist to my touch."
	DB	NEXT
;	DB	'【恵依美】：・・・あふっ！'
	DB	"Meimi:  .......Ahh!"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M3:		;舐める　○○○○２
;	DB	'花びらを押しのけるように、秘裂に舌を這わせる。'
	DB	"I open her pussy, like peeling the petals of a beautiful"
	DB	CR
	DB	"flower back."
	DB	NEXT
;	DB	'【恵依美】：・・・あ・・・っ・・・あんっ・・・'
	DB	"Meimi:  ....Ahhn......"
	DB	FLG,F_COPYI,2,2
	DW	0000H

M4:		;舐める　○○○○３
;	DB	'開いて来た花芯に舌を差し入れ、溢れて来る蜜を舐め取るようにする。'
	DB	"I slide my tongue inside her pussy, tasting her honey."
	DB	NEXT
;	DB	'【恵依美】：・・・きゃぅっ・・・！'
	DB	"Meimi:  ........No!"
	DB	NEXT
;	DB	'そのまま奥まで舌をねじ込み、中をかき回す。'
	DB	"Deeper my tongue slid, moving all the way into her."
	DB	NEXT
;	DB	'【恵依美】：・・・あ・・・あぁ・・・あぁぁ・・・っ・・・！'
	DB	"Meimi:  Ahhhh....! Ahhhn!"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M5:		;舐める　○○○○４
;	DB	'俺は中野の中を丹念に舐め回す。'
	DB	"I moved my tongue in and out of her pussy, moving it up"
	DB	CR
	DB	"and down."
	DB	NEXT
;	DB	'【恵依美】：・・・んぁ・・・あふっ・・・くぁっ・・・！'
	DB	"Meimi:  Mmmm.... Ahhhhn!"
	DB	NEXT
;	DB	'俺の舌が動くたびに、中野の身体がいやいやをするようにうごめく。'
	DB	"With each movement of my tongue, Meimi's body moves of its"
	DB	CR
	DB	"own accord."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M6:		;舐める　○○○○５
;	DB	'俺は舌だけでなく、口全体を使って中野の秘所にむしゃぶりつく。'
	DB	"Not content to use only my tongue, I stimulate Meimi's"
	DB	CR
	DB	"folds with my entire mouth."
	DB	NEXT
;	DB	'【恵依美】：はっ・・・あっ・・・！んっ・・・くぅっ・・・！'
	DB	"Meimi:  Ah.....ahhhn.....! Mmm....Ku!"
	DB	NEXT
;	DB	'中野の動きが、徐々に自ら押し付けるような動きに変わってゆく。'
	DB	"Meimi's movements slowly grow more desperate."
	EF_SET 102
	DW	0000H

M7:		;撫でる　髪１
;	DB	'中野の、先が少し巻き毛になっている髪に手を伸ばす。'
	DB	"I reach out to touch her muff, which is soft and curly."
	DB	NEXT
;	DB	'【恵依美】：・・・あ・・・'
	DB	"Meimi:  ....Ahhh....."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;撫でる　髪２
;	DB	'中野の髪は驚くほどサラサラで、俺の指はほとんど何の抵抗も無く抜けてゆく。'
	DB	"Her pussy hair is surprisingly silky and pleasant."
	DB	NEXT
;	DB	'【恵依美】：・・・ん・・・気持ちいい・・・'
	DB	"Meimi:  ......That feels good."
	EF_SET 103
	DW	0000H

M9:		;話す　恵依美１
;	DB	'【%001】：・・・中野・・・'
	DB	"%001:  .......Meimi......"
	DB	NEXT
;	DB	'【恵依美】：・・・%001・・・'
	DB	"Meimi:  ......%001......."
	DW	0000H

M_EXIT:		;
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,3,255,103,102
	DB	FLG,F_EXIT,255
	DB	NEXT
;	DB	'【%001】：・・・中野・・・行くよ・・・'
	DB	"%001:  .......Meimi, I'm coming in now."
	DB	NEXT
;	DB	'【恵依美】：・・・うん。'
	DB	"Meimi:  ....Alright."
	DB	NEXT
;	DB	'俺はさっきから爆発寸前の物を入り口に押し当て、進入を開始する。'
	DB	"I bring the hard head of my cock and push it against her"
	DB	CR
	DB	"pink innards, teasing as I lubricate myself. She moans."
	DB	NEXT
	DB	"Then I slowly sink inside Meimi."
	DB	NEXT
;	DB	'【恵依美】：・・・んっ。'
	DB	"Meimi:  ......Mmm!"
	DB	NEXT
;	DB	'中野の中は十二分に濡れそぼっており、俺のブツはスムーズに入っていく。'
	DB	"The fit is tight, but her well-lubricated pussy allows"
	DB	CR
	DB	"my cock to enter her smoothly."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・はぁっ・・・・・・'
	DB	"Meimi:  .....Oh...!"
	DB	NEXT
;	DB	'【%001】：・・・中野・・・全部入ったよ・・・'
	DB	"%001:  .....Meimi, I'm inside you....."
	DB	NEXT
;	DB	'【恵依美】：・・・・・%001・・・・・・動いても、いいよ・・・・・・'
	DB	"Meimi:  ....%001.....Oh, %001..."
	DB	NEXT
;	DB	'中野のその言葉を受けた俺は、ゆっくりと注送を開始する。'
	DB	"Slowly I begin to move my body in and out of her."
	DB	NEXT
;	DB	'【恵依美】：・・・んっ・・・んっ・・・'
	DB	"Meimi:  .....Mmmm......Mmm....."
	DB	NEXT
;	DB	'自然、少しずつ速くなるピッチに合わせるように、中野の声が逼迫して来る。'
	DB	"My movements increase in speed, and Meimi begins to move"
	DB	CR
	DB	"her body in concert with mine."
	DB	NEXT
;	DB	'【恵依美】：・・・あっ！・・・あっ！・・・あくっ！・・・あはぁっ！'
	DB	"Meimi:  Ahh!  Ahhhn!  Ahhhhn!"
	DB	NEXT
;	DB	'そして、俺にも限界が近づいていた。'
	DB	"Then it was there, welling up within my legs."
	DB	NEXT
;	DB	'【%001】：・・・・・・な、中野・・・・・・！で、出るっ・・・・・・'
	DB	"%001:  Meimi....! I can't hold it anymore...!"
	DB	NEXT
;	DB	'【恵依美】：あっ・・・！だ、ダメ・・・！そ、外に・・・！'
	DB	"Meimi:  No! .....Don't come in me! Pull out....!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .........."
	DB	PAUSE
;	DB	'で・・・・・・'
	DB	"I'm...."
	DB	PAUSE
;	DB	'でるっ・・・・・・・・・！'
	DB	" I'm coming.....!"
	DB	NEXT
;	DB	'どぴゅっ'
	DB	"*SPLAT*"
	T_CG1 'AE_104G',0,0,0,0
	DB	NEXT
;	DB	'【恵依美】：・・・・・・あ・・・・・・'
	DB	"Meimi:  ......Ahhhh...."
	DB	NEXT
;	DB	'間一髪、ブツを引き抜いた俺は・・・中野の背中に白濁した樹液を吐き出していた。'
	DB	"At the last second, I pulled my cock out of her, and"
	DB	CR
	DB	"came on her ass."
	DB	NEXT
;	DB	'【%001】：・・・はぁっ・・・はぁっ・・・'
	DB	"%001:  ....*pant*.......*pant*...."
	DB	NEXT
;	DB	'【恵依美】：・・・・・ん・・・・・・'
	DB	"Meimi:  Mmmmm......"
	DB	NEXT
;	DB	'・・・・・・・・・'
	DB	".............."
	DB	NEXT
;	DB	'【恵依美】：・・・ねえ、%001。'
	DB	"Meimi:  %001?"
	DB	NEXT
;	DB	'【%001】：・・・ん？'
	DB	"%001:  .....Mm?"
	DB	NEXT
;	DB	'【恵依美】：夢・・・・・・見つかりそう？'
	DB	"Meimi:  Do you think you'll find your dream? I mean, what you"
	DB	CR
	DB	"want to do with your life?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ..........."
	DB	NEXT
;	DB	'【%001】：ああ。取り合えず一つ見つけたし。'
	DB	"%001:  Sure. I've found it today..."
	DB	NEXT
;	DB	'【恵依美】：どんな夢？'
	DB	"Meimi:  You did?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ........."
	DB	NEXT
;	DB	'【%001】：中野・・・・・・お前を恋人にする事さ。'
	DB	"%001:  Sure. You're my girlfriend now. That was my dream."
	DB	NEXT
;	DB	'【恵依美】：・・・くす・・・'
	DB	"Meimi:  ......I love you, %001."
	DB	PAUSE
;	DB	'な～んだ。じゃあもう叶っているじゃない。'
	DB	" But if your dream has come"
	DB	CR
	DB	"true already, won't your life be boring?"
	DB	NEXT
;	DB	'【%001】：・・・だけど・・・'
	DB	"%001:  I don't think so."
	DB	PAUSE
;	DB	'簡単じゃあ、なかっただろ？'
	DB	" We'll find something to keep us"
	DB	CR
	DB	"going."
	DB	NEXT
;	DB	'【恵依美】：・・・・・・・・・'
	DB	"Meimi:  ..............."
	DB	NEXT
;	DB	'【恵依美】：うふふ・・・・・・そうだね。'
	DB	"Meimi:  I'm sure we will."
	DB	NEXT
	DB	BGM,33
	DB	ENDING,8
	DW	0000H


end
