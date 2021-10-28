;	 さくらの季節
;		 シーン　Ｅ＿Ａ＿４
;	 鈴子さんとＨ３　後ろから・・・

	INCLUDE SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE "V_NAME00.INC"		  ; 0=NoCommand , 1-49=NormalCommand
	INCLUDE "N_NAME00.INC"		  ; 50-99=HsceneCommand

;	 　　　 動詞　　名詞群
CM1:   DW	VV1,	-1
CM2:	DW	VV2,	-1
CM3:	DW	VV4,	-1
CM4:	DW	VV3,	-1


;VV1:   DB	1,	'キス',0
VV1:   	DB	1,	'KISS',0
;VV2:	DB	2,	'ムネを愛撫',0
VV2:	DB	2,	'PET BREASTS',0
;VV3:	DB	3,	'腰を動かす',0
VV3:	DB	3,	'MOVE BODY',0
;VV4:	DB	4,	'秘処を愛撫',0
VV4:	DB	4,	'CARESS PUSSY',0

;	 　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3, M4		;キス３
S2:		DW	VV2, -1,  2, M5, M6		;胸をもむ２
S3:		DW	VV3, -1,  3, M7, M8		;腰を使う３
S4:		DW	VV4, -1,  4, M10, M11		;秘処を愛撫２


;イニシャルメッセージ
M1:
	DB	BGM,13
	E_CG B_SUDA,'AE_134'
;	DB	'【%001】：鈴子さん・・・いくよ！'
	DB	"%001:  Reiko, I'm coming in!"
	DB NEXT
;	DB	'【鈴子】：あぅっ！'
	DB	"Reiko:  Oh!"
	DB  NEXT
;	DB	'俺は鈴子さんを背後から抱きしめて、挿入した。'
	DB	"I hugged Reiko close to me as I pushed inside her dripping"
	DB	CR
	DB	"pussy."
	DB  NEXT
;	DB	'【鈴子】：くぅ・・・！'
	DB	"Reiko:  ...Oh my God!"
	DB  NEXT
;	DB	'鈴子さんは苦痛と快感が入り交じった叫びを上げる。'
	DB	"Reiko let out a cry of pain and pleasure, and then I was"
	DB	CR
	DB	"inside her."
	DB  NEXT
;	DB	'【%001】：鈴子さん・・・鈴子さん！'
	DB	"%001:  Reiko!  Reiko!"
	DB NEXT
;	DB	'【鈴子】：%001くん・・・！'
	DB	"Reiko:  %001!"
	DW 0000H


M2:	;キス１
;	DB	'鈴子さんの首の後ろにキス。'
	DB	"I kissed Reiko on the nape of her neck."
	DB  NEXT
;	DB	'【鈴子】：んっ！'
	DB	"Reiko:  ...........!!"
	DB  NEXT
;	DB	'鈴子さんの体がぴくんと跳ねた。'
	DB	"Reiko's body jumped with pleasure at that."
	DB	FLG,F_COPYI,1,1
	DW 0000H

M3:	;キス２
;	DB	'鈴子さんの耳を軽く噛む。'
	DB	"I softly bit her ear."
	DB  NEXT
;	DB	'【鈴子】：あっ・・・'
	DB	"Reiko:  Ah....!!"
	DB  NEXT
;	DB	'鈴子さんが切なげなため息を漏らす。'
	DB	"Reiko lets out a long sigh of pleasure."
	DB	FLG,F_COPYI,1,2
	DW 0000H

M4:	;キス３
;	DB	'鈴子さんの肩越しにキス。'
	DB	"I kissed down her neck to her shoulder."
	DB  NEXT
;	DB	'【鈴子】：・・・んんっ・・・'
	DB	"Reiko:  Mmmm...."
	DB  NEXT
;	DB	'俺は貪るように鈴子さんの舌に舌を絡めた。'
	DB	"Reiko and I intertwine our tongues, starving for each"
	DB	CR
	DB	"other."
	DB	FLG,F_COPYI,1,0		;ループ
	DW 0000H


M5:	;胸をもむ１
;	DB	'鈴子さんの脇から手を回し、下から持ち上げるように胸をもむ。'
	DB	"I reached around to massage her tits with both hands."
	DB  NEXT
;	DB	'【鈴子】：%001君っ・・・'
	DB	"Reiko:  %001..."
	DB  NEXT
;	DB	'（やわらかい・・・）'
	DB	"They're so soft..."
	DB	FLG,F_COPYI,2,1
	DW 0000H

M6:	;胸をもむ２
;	DB	'手のひらを使ってムネ全体をもみながら、指先で先端を刺激する。'
	DB	"Continuing to rub her breasts with my palms, I lightly"
	DB	CR
	DB	"pinched her nipples with my fingers."
	DB  NEXT
;	DB	'【%001】：鈴子さん・・・気持ちいい？'
	DB	"%001:  .....Reiko, does this feel good?"
	DB NEXT
;	DB	'【鈴子】：・・・そんなこと・・・聞かないで・・・！'
	DB	"Reiko:  Don't ask me things like that...!"
	DB  NEXT
;	DB	'鈴子さんの乳首がだんだん固く尖ってく・・・。'
	DB	"He nipples were hard and blood-engorged."
	EF_SET 101
	DW 0000H


M7:	;腰を使う１
;	DB	'【鈴子】：あくぅっ・・・'
	DB	"Reiko:  Ahh...!!"
	DB  NEXT
;	DB	'【%001】：鈴子さん・・・'
	DB	"%001:  Reiko....."
	DB NEXT
	DB	"Biting back her pain, Reiko whispered to me."
	DB	NEXT
;	DB	'【鈴子】：いいの・・・大丈夫だから・・・'
	DB	"Reiko:  It's alright. It doesn't hurt that much."
	DB	NEXT
	DB	"Reiko:  .....I'm with you...so it's okay."
	DB FLG,F_COPYI,3,1
	DW 0000H


M8:	;腰を使う２
;	DB	'鈴子さんの中は狭く、俺自身をきつく圧迫する。'
	DB	"Reiko was all around me, holding my cock tightly inside her."
	DB  NEXT
;	DB	'【%001】：鈴子さん・・・力、抜いて・・・'
	DB	"%001:  Reiko, try to relax your muscles if you can."
	DB NEXT
;	DB	'俺は奥へ、奥へと鈴子さんを貫いて行く。'
	DB	"I pushed deeper, deeper into her."
	DB NEXT
;	DB	 '【鈴子】：ん、んん～～・・・！'
	DB	"Reiko:  Ooooo!  ............"
	DB NEXT
;	DB 	'鈴子さんはぎゅっと目をつぶって痛みに耐えている。'
	DB	"Reiko was gritting her teeth, trying to bear the pain."
	DB  NEXT
;	DB	'【%001】：・・・鈴子さん・・・鈴子さんの中・・・天国みたいだ・・'
	DB	"%001:  I'm inside you... I'm inside you, Reiko. It's like"
	DB	CR
	DB	"heaven."
	DB	NEXT
	EF_SET 102
	DW 0000H

M10:	;秘処を愛撫１
;	DB	'鈴子さんの秘処を指を使って愛撫する。'
	DB	"I gentely caress her pussy with my fingers."
	DB  NEXT
;	DB	'【鈴子】：ひっ・・・'
	DB	"Reiko:  Mmm..."
	DB  NEXT
;	DB	'鈴子さんが小さく鳴いた。'
	DB	"Reiko moaned with pleasure."
	DB	FLG,F_COPYI,4,1
	DW 0000H

M11:	;秘処を愛撫２
;	DB	'鈴子さんの一番敏感な部分をきゅっとつねる。'
	DB	"I find her clitoris and move my finger over it."
	DB  NEXT
;	DB	'【鈴子】：あ、ああ～・・・！'
	DB	"Reiko:  Ah...!  Ahhh!"
	DB  NEXT
;	DB	'鈴子さんの悲鳴に、甘いものが混じる。'
	DB	"Reiko's voice gets deeper, more desperate."
	DW 0000H


M_EXIT:
	DB FLG,F_AND,255,101,102
	DB FLG,F_EXIT,255
;	DB	'【%001】：れ、鈴子さん・・・俺、もうイキそうだ・・・！'
	DB	"%001:  Reiko....Reiko, I'm going to come!"
	DB  NEXT
;	DB	'【鈴子】：・・・わ、私も・・・・・・！'
	DB	"Reiko:  ....Me, too...!"
	DB  NEXT
;	DB	'【鈴子】：%001君・・・い、一緒に・・・・・・！'
	DB	"Reiko:  %001... Let's come...together...!"
	DB  NEXT
;	DB	'【鈴子】：・・・あ・・・・・・ああああああっ！？'
	DB	"Reiko:  ........Ah....Ahhhhhh!!"
	DB  NEXT
;	DB	'【%001】：あぁ・・・！'
	DB	"%001:  Ahh...",PAUSE,"............!!"
	DB  NEXT
;	DB	'俺は鈴子さんの中に熱い奔流を放った。'
	DB	"I pump hot semen inside Reiko."
	DB  NEXT
;	DB	'【鈴子】：・・・・・・%001君・・・大好き・・・'
	DB	"Reiko:  ....%001, I love you..."
	DB  NEXT
;	DB	'【%001】：・・・鈴子さん・・・愛してます・・・'
	DB	"%001:  I love you, too....Reiko."
	DB  NEXT
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	"............................"
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・'
	DB	"%001:  Reiko..."
	DB	NEXT
;	DB	'【%001】：・・・・・・俺は、どんなに離れても鈴子さんのことを愛し続ける・・・。'
	DB	"%001:  No how far you may go away from me, I'll always"
	DB	CR
	DB	"keep on loving you."
	DB	NEXT
;	DB	'【鈴子】：%001君・・・私・・・'
	DB	"Reiko:  %001...I..."
	DB	NEXT
;	DB	'【%001】：鈴子さん。金メダルの夢、叶えてよ。'
	DB	"%001:  I want you to get that gold medal."
	DB	NEXT
;	DB	'【鈴子】：%001君・・・君はそれでいいの？'
	DB	"Reiko:  You don't want me to....give up my dream?"
	DB	NEXT
;	DB	'【%001】：もし鈴子さんが俺のために金メダルの夢を諦めたりしたら、俺はきっと後悔すると思う。'
	DB	"%001:  If you can hold onto your dream for my sake, then"
	DB	CR
	DB	"that's alright with me."
	DB	NEXT
;	DB	'【%001】：鈴子さんが金メダルを取るのは、俺の夢でもあるんだ。',CR,'だから・・・夢を諦めないで・・・'
	DB	"%001:  It's not just your dream to go to the olympics."
	DB	CR
	DB	"It's mine, too, because I love you. So don't throw your"
	DB	CR
	DB	"dream away."
	DB	NEXT
;	DB	'そう、例え鈴子さんが遠くに行ったって、会おうと思えばいつだって',CR,'会える。'
	DB	"....That's right. Even if she goes away to college, I can"
	DB	CR
	DB	"still see her a lot."
	DB	NEXT
;	DB	'なのに・・・涙が止まらない・・・。'
	DB	"That's true, but..... for some reason, I can't stop crying."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・。俺、鈴子さんと同じ大学に行くよ。'
	DB	"%001:  Reiko...I'm going to go to the same university as you."
	DB	NEXT
;	DB	'【%001】：だから・・・待ってて。'
	DB	"%001:  .....So I want you to wait for me."
	DB	NEXT
;	DB	'【鈴子】：%001君・・・。'
	DB	"Reiko:  %001..."
	DB	NEXT
;	DB	'【鈴子】：ありがとう・・・%001君・・・大好きよ。'
	DB	"Reiko:  Thank you. Thank you, %001."
	DB	NEXT
	B_O B_WIPE
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	".........................................................."
	DB	NEXT
;	DB	'そして・・・卒業式。'
	DB	"Then it was time for Reiko's graduation ceremony."
	DB	NEXT
	DB	BGM,33
	DB  ENDING,1
	DW 0000H

end
