;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ｃ＿４
;		美緒フィニッシュ

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5, CM6
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	-1
CM6:	DW	VV6,	-1

;VV1:	DB	1,	'あやまる',0
VV1:	DB	1,	'APOLOGIZE',0
;VV2:	DB	2,	'見る',0
VV2:	DB	2,	'LOOK',0
;VV3:	DB	3,	'優しい言葉',0
VV3:	DB	3,	'BE NICE TO HER',0
;VV4:	DB	4,	'キス',0
VV4:	DB	4,	'KISS',0
;VV5:	DB	5,	'揉む',0
VV5:	DB	5,	'MASSAGE',0
;VV6:	DB	6,	'入れる',0
VV6:	DB	6,	'ENTER',0

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	'MIO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3, M4		;あやまる
S2:		DW	VV2, NN1,  2, M5, M6		;見る　美緒
S3:		DW	VV3, -1,  3, M7, M8		;優しい言葉
S4:		DW	VV4, -1,  4, M9, M10, M11, M12, M13		;キス
S5:		DW	VV5, -1,  5, M14, M15, M16		;揉む
S6:		DW	VV6, -1,  6, M17, M18		;挿入する


;イニシャルメッセージ
M1:
	DB	BGM,13
	E_CG B_FADE,'AE_144'
;	DB	'【美緒】：い゛っ・・・'
	DB	"Mio:  ....Th-......Ah!"
	DB	NEXT
;	DB	'【美緒】：いやああああああああああ！'
	DB	"Mio:  YAAAAAAAAAA!!!!!"
	DB	NEXT
;	DB	'【%001】：・・・！'
	DB	"%001:  ......!!"
	DB	NEXT
;	DB	'【美緒】：・・・こんなの・・・こんなのってひどい・・・'
	DB	"Mio:  .....I can't...... I can't believe you did that..."
	DB	NEXT
;	DB	'美緒ちゃんがぽろぽろと涙をこぼして泣いてるのを見て、やっと俺は自分が何を仕出かしたのかが分かった。'
	DB	"Seeing Mio's tears flow freely, I finally realized what I"
	DB	CR
	DB	"had done."
	DB	NEXT
;	DB	'【%001】：・・・お・・・俺は・・・'
	DB	"%001:  .......Mio, I...."
	DB	NEXT
;	DB	'俺と美緒ちゃんの繋がってる場所から、真っ赤な液体が一条こぼれ落ち、シーツに真っ赤な染みを作る。'
	DB	"Blood was flowing from Mio's pussy, creating a large stain"
	DB	CR
	DB	"on the sheets beneath her."
	DB	NEXT
;	DB	'俺は自分の欲に溺れて、美緒ちゃんを踏みにじったんだ・・・！'
	DB	"Drowning in my own selfish passion, I had hurt Mio terribly."
	DB	NEXT
;	DB	'【%001】：・・・ごめん！'
	DB	"%001:  .....Mio, I'm sorry!"
	DB	NEXT
;	DB	'【%001】：俺って奴は・・・最悪の馬鹿だ・・・'
	DB	"%001:  I'm....I'm such a stupid fool!"
	DB	NEXT
;	DB	'【美緒】：・・・ひっく・・・ひっく・・・'
	DB	"Mio:  ....*sob*....."
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DB C_BLD,C_V_ON,5
	DB C_BLD,C_V_ON,6
	DW	0000H


M2:		;あやまる
;	DB	'【%001】：ごめん・・・痛かったよな・・・'
	DB	"%001:  I'm sorry. It really hurt, didn't it?"
	DB	NEXT
;	DB	'【美緒】：・・・・・・やだ・・・'
	DB	"Mio:  Yes..."
	DB	FLG,F_COPYI,1,1
	DW	0000H


M3:		;あやまる
;	DB	'【%001】：ごめん・・・本当に・・・'
	DB	"%001:  I'm sorry...really..."
	DB	NEXT
;	DB	'【美緒】：・・・優しくしてくれなきゃやだ・・・'
	DB	"Mio:  ......I don't want to do this if you're not going"
	DB	CR
	DB	"to be gentle with me."
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ........................."
	DB	NEXT
;	DB	'【美緒】：・・・・・・先輩・・・今度は、優しくして・・・'
	DB	"Mio:  Next time...be gentle, okay?"
	DB	NEXT
;	DB	'【%001】：・・・ああ。'
	DB	"%001:  ....Alright."
	DB	FLG,F_COPYI,1,2
	DW	0000H


M4:		;あやまる
;	DB	'【%001】：本当にごめん、美緒ちゃん。'
	DB	"%001:  I'm sorry, Mio."
	DB	NEXT
;	DB	'【%001】：もう二度と美緒ちゃんが怖がることはしない。約束するよ。'
	DB	"%001:  I'll never do anything like that again. I promise."
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・。'
	DB	"Mio:  %001...."
	DB	NEXT
;	DB	'美緒ちゃんは俺にしがみついてきた。'
	DB	"Mio embraced me, her naked body pressing against mine."
	DB	NEXT
;	DB	'【美緒】：好き・・・大好き！'
	DB	"Mio:  I love you, %001!  I love you!"
	DB C_BLD,C_V_ON,1
	;「あやまる」消し
	;それ以外出し
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_V_OFF,3
	DB C_BLD,C_V_OFF,4
	DB C_BLD,C_V_OFF,5
	DB C_BLD,C_V_OFF,6
	DW	0000H

M5:		;見る　美緒
;	DB	'まだガチガチだ・・・。'
	DB	"She's still sobbing."
	DB	NEXT
;	DB	'もっと優しくしてあげないと。
	DB	"I'd better be gentle with her."
	DW	0000H

M6:		;見る　美緒
;	DB	'美緒ちゃんの体から力が抜けてきた。'
	DB	"My cock has slipped out of Mio."
	DB	NEXT
;	DB	'・・・今度は大丈夫そうだ。'
	DB	"She'll probably be okay the second time."
	DW	0000H


M7:		;優しい言葉
;	DB	'（・・・俺って口下手だし・・・ボキャブラリーねぇし・・・）'
	DB	".....I'm not very good with words...I don't want to fuck"
	DB	CR
	DB	"it up."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M8:		;優しい言葉
;	DB	'【%001】：・・・好きだ。ずっと俺の側にいてくれ、美緒ちゃん。'
	DB	"%001:  .....I love you, Mio. I want to be with you forever."
	DB	NEXT
;	DB	'【美緒】：・・・あたしも・・・好き・・・'
	DB	"Mio:  I do too, %001."
	EF_SET 101
	DW	0000H

M9:		;キス
;	DB	'白くて柔らかい美緒ちゃんのほっぺたを、涙が一筋伝っていた。'
	DB	"A tear was running slowly down her soft cheek."
	DB	NEXT
;	DB	'【%001】：ごめん、痛かったよね・・・'
	DB	"%001:  I'm sorry. That hurt a lot, I'll bet."
	DB	NEXT
;	DB	'【美緒】：・・・。'
	DB	"Mio:  ..................."
	DB	NEXT
;	DB	'俺は、涙の筋に沿って舌を這わせた。'
	DB	"I kissed her tear away."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M10:		;キス
;	DB	'唇にキス。'
	DB	"I kissed her lips softly."
	DB	NEXT
;	DB	'【美緒】：・・・先輩のキスって、優しい・・・。'
	DB	"Mio:  .......I like your kisses. They're gentle."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M11:		;キス
;	DB	'美緒ちゃんの耳たぶにキスする。'
	DB	"I kissed her ear, putting my tongue in."
	DB	NEXT
;	DB	'【美緒】：はぁっ・・・'
	DB	"Mio:  Ahhhhh...."
	DB	NEXT
;	DB	'美緒ちゃんは肩を震わせて、熱い吐息をはいた。'
	DB	"Her shoulders trembling, Mio moaned, her breath hot"
	DB	CR
	DB	"against my body."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M12:		;キス
;	DB	'首筋から鎖骨へとキスマークの列を付けていく。'
	DB	"I kissed her on the neck, leaving a mark."
	DB	NEXT
;	DB	'【美緒】：はぁ、はぁ、はぁ・・・'
	DB	"Mio:  Oh, %001..."
	DB	NEXT
;	DB	'美緒ちゃんの呼吸が激しくなっている。'
	DB	"Mio's breath increased in speed and shallowness."
	DB	FLG,F_COPYI,4,4
	DW	0000H

M13:		;キス
;	DB	'俺の唇は美緒ちゃんのムネの先端に達する。'
	DB	"My kisses move down, stopping at her breasts."
	DB	NEXT
;	DB	'【美緒】：先輩・・・気持ちいい・・・'
	DB	"Mio:  %001, that's so good..."
	DB	NEXT
;	DB	'俺は赤ん坊みたいに美緒ちゃんの乳首を吸った。'
	DB	"Like a baby, I suckle her."
	EF_SET 102
	DW	0000H

M14:		;揉む
;	DB	'【%001】：・・・ムネってもむと大きくなるんだっけ？'
	DB	"%001:  .....So breasts are supposed to ge bigger if"
	DB	CR
	DB	"someone rubs them?"
	DB	NEXT
;	DB	'【美緒】：わかんない・・・'
	DB	"Mio:  I don't know..."
	DB	NEXT
;	DB	'【%001】：じゃあ・・・揉んであげるよ。'
	DB	"%001:  I'll massage them for you."
	DB	NEXT
;	DB	'俺は両手でそっとほぐすように胸を揉んだ。'
	DB	"With both hands, I started to rub Mio's breasts."
	DB	NEXT
;	DB	'【美緒】：あ・・・ん'
	DB	"Mio:  Ahhhh.....!"
	DB	FLG,F_COPYI,5,1
	DW	0000H

M15:		;揉む
;	DB	'【美緒】：先輩・・・ムネの大きい人が好きなの？'
	DB	"Mio:  %001, do you like women with large breasts?"
	DB	NEXT
;	DB	'【%001】：・・・・・・美緒ちゃんだって、大きくなるさ。'
	DB	"%001:  Yours will get bigger, trust me."
	DB	NEXT
;	DB	'【美緒】：・・・やっぱり、あたしってペチャパイなんだ・・・'
	DB	"Mio:  So you do think they're small?"
	DB	NEXT
;	DB	'【%001】：で・・・でもほら、ベーゴマだってペチャの方が強いし！'
	DB	"%001:  No, I... But what about tennis? If your breasts"
	DB	CR
	DB	"were too big, you couldn't play well."
	DB	NEXT
;	DB	'【美緒】：・・・ベーゴマってなに？'
	DB	"Mio:  ....Yes, but..."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M16:		;揉む
;	DB	'【%001】：大きさなんてカンケーないって。俺は美緒ちゃんのおっぱいだから好きなんだ。'
	DB	"%001:  Size isn't important at all. I like these because"
	DB	CR
	DB	"they're yours."
	DB	NEXT
;	DB	'俺は手のひらで胸全体を揉みながら、親指と人差し指で乳首をつまみあげた。'
	DB	"While massaging her breasts with my hands, I played"
	DB	CR
	DB	"with her nipples."
	DB	NEXT
;	DB	'【美緒】：・・・あっ・・・'
	DB	"Mio:  Ahh...."
	DB	NEXT
;	DB	'美緒ちゃんがぴくんと身震いする。'
	DB	"Mio's abdomen arched up towards me."
	EF_SET 103
	DW	0000H

M17:		;挿入する
;	DB	'美緒ちゃんの準備がまだだ。'
	DB	"Mio's not ready yet."
	DB	NEXT
;	DB	'美緒ちゃんを傷つけるようなことはしたくない。'
	DB	"I don't want to hurt her again."
	DW	0000H

M18:		;挿入する
;	DB	'【%001】：美緒ちゃん・・・今度はなるべく痛くしないようにするから・・・。'
	DB	"%001:  Mio, this time I'm going to be careful not to hurt"
	DB	CR
	DB	"you, alright?"
	DB	NEXT
;	DB	'【美緒】：うん・・・'
	DB	"Mio:  Okay."
	DB	NEXT
;	DB	'美緒ちゃんは、目をきゅっとつぶる。'
	DB	"Mio closes her eyes tightly."
	DB	NEXT
;	DB	'【%001】：それじゃ・・・行くよ・・・'
	DB	"%001:  I'm coming in now..."
	DB	NEXT
;	DB	'【美緒】：・・・あっ！'
	DB	"Mio:  ...Ah!"
	DB	NEXT
;	DB	'血塗れの俺自身が、再びゆっくりと美緒ちゃんの中に入っていく。'
	DB	"My blood-stained cock slid into Mio once again."
	DB	NEXT
;	DB	'【美緒】：い・・・いたた'
	DB	"Mio:  .......That hurts...!"
	DB	NEXT
;	DB	'美緒ちゃんのあそこは、俺自身の侵入を拒もうとする。'
	DB	"As I pushed in, Mio's pussy tried to refuse me entry."
	DB	NEXT
;	DB	'【%001】：美緒ちゃん・・・力を抜いて・・・'
	DB	"%001:  Mio, try to relax your muscles..."
	DB	NEXT
;	DB	'【美緒】：・・・はっ・・・うっ・・・'
	DB	"Mio:  .....It...It hurts....."
	DB	NEXT
;	DB	'美緒ちゃんの体から力が抜けたと同時に、俺はじわじわと力を込めて、美緒ちゃんの中に入っていった。'
	DB	"She loosened the tenseness in her muscles, allowing my"
	DB	CR
	DB	"crimson cock to push all the way into her center."
	DB	NEXT
;	DB	'【%001】：・・・入ったよ、美緒ちゃん。よく頑張ったね。'
	DB	"%001:  It's done, Mio. The hard part is finished."
	DB	NEXT
;	DB	'【美緒】：%001せんぱい・・・'
	DB	"Mio:  %001....."
	DB	NEXT
;	DB	'美緒ちゃんが、涙をポロポロこぼしながら俺にしがみつく。'
	DB	"Mio was crying, again..."
	DB	NEXT
;	DB	'【%001】：・・・美緒・・・愛してるよ・・・'
	DB	"%001:  Mio....I love you..."
	DB	NEXT
;	DB	'【美緒】：・・・あたし・・・%001先輩と、一つになれたんだ・・・'
	DB	"Mio:  I've done it. I've joined with %001... We're one, now."
	DB	NEXT
;	DB	'【美緒】：・・・・・・・・・先輩・・・あたし、我慢するから・・・先輩の好きなようにして・・・'
	DB	"Mio:  ......I'll be alright. Please do what you want now."
	DB	NEXT
;	DB	'【%001】：だけど・・・'
	DB	"%001:  But..."
	DB	NEXT
;	DB	'【美緒】：・・・お願い・・・あたし、先輩に気持ちよくなって欲しい・・・'
	DB	"Mio:  Please, I want to make you feel good."
	DB	NEXT
;	DB	'【%001】：わかった。ありがとう、美緒。'
	DB	"%001:  Alright. Thank you, Mio."
	DB	NEXT
;	DB	'俺はゆっくりと腰を動かし始める。始めは小さく、段々に大きく。'
	DB	"I begin moving my body slowly at first, then start thrusting"
	DB	CR
	DB	"in and out of her slit."
	DB	NEXT
;	DB	'【美緒】：・・・あっ・・・・・・あんっ・・・'
	DB	"Mio:  ......Ahn....ahnnnn!"
	DB	NEXT
;	DB	'美緒の悲鳴に、甘いものが混ざり始める。それがますます俺を興奮させ、美緒に熱中させる。'
	DB	"There is pain in Mio's cries, but something sweeter, too."
	DB	CR
	DB	"Seeing her under me, all around me, made me more and"
	DB	CR
	DB	"more excited."
	DB	NEXT
;	DB	'【%001】：美緒・・・美緒！'
	DB	"%001:  Mio!  .....Mio!"
	DB	NEXT
;	DB	'【美緒】：先輩・・・あたし・・・変に・・・変に！'
	DB	"Mio:  %001.....I.....I feel so strange!"
	DB	NEXT
;	DB	'【美緒】：ふぁ・・・'
	DB	"Mio:  Ahhhhn......Ahhhhhhhn!"
	DB	NEXT
;	DB	'【美緒】：・・・・・・あ・・・ああああああああっ！'
	DB	"Mio:  ..............Oh my God!"
	DB	NEXT
;	DB	'【%001】：くぅっ！'
	DB	"%001:  ...Kku!!"
	DB	NEXT
;	DB	'美緒は一際高く悲鳴を上げると、唐突に動かなくなった。'
	DB	"Mio cried out once more, than was silent."
	DB	NEXT
;	DB	'【%001】：美緒？'
	DB	"%001:  Mio?"
	DB	NEXT
;	DB	'【%001】：お、おい！どうしたんだ！？'
	DB	"%001:  Mio! Are you alright? What happened?"
	DB	NEXT
;	DB	'【美緒】：・・・せんぱい・・・スキ・・・'
	DB	"Mio:  ....%001..........I love you......"
	DB	NEXT
;	DB	'【%001】：そ、そうか・・・これが「イク」ってことなんだ・・・'
	DB	"%001:  So this is what happens when a woman comes."
	DB	NEXT
;	DB	'美緒ちゃんが俺を愛し、感じてくれた。俺はそれがこの上なく嬉しかった。'
	DB	"Mio loved me, and felt good to be with me. This love had"
	DB	CR
	DB	"boiled up inside her."
	DB	NEXT
;	DB	'俺は安らかな笑顔で寝息を立てる美緒をそっと抱き締めて、目を閉じた。'
	DB	"Mio drifted off to sleep, a satisfied expression on her"
	DB	CR
	DB	"face. I hugged her to me and closed my eyes myself."
	DB	NEXT
;	DB	'腕の中で息ずく美緒の鼓動を感じながら、俺も夢の淵へと落ちていった・・・'
	DB	"With Mio's small body in my arms, I went to sleep"
	DB	CR
	DB	"myself..."
	DB	NEXT
	DB	BGM,33
	DB	ENDING,3
	DW	0000H

M_EXIT:
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,4,255,101,102,103
	DB	FLG,F_EXIT,255
	DB	FLG,F_COPYI,2,1		;
	DB	FLG,F_COPYI,6,1		;挿入する２
	DW	0000H


end
