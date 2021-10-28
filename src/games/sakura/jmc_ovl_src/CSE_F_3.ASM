;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		Ｈシーン　亜希３
;		
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1
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
CM1:

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:

;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'俺は亜希ちゃんを四つんばいにし、さっきから痛いほどに怒張しているブツを入り口に押し当てた。'
	DB	"I set Aki up on all fours and positioned myself behind"
	DB	CR
	DB	"her round, white ass."
	DB	NEXT
;	DB	'【%001】：・・・・・・いくよ・・・・・・！'
	DB	"%001:  .......I'm going in!"
	DB	NEXT
;	DB	'【亜希】：・・・あ・・・あっ・・・あぅぅっ・・・！'
	DB	"Aki:  Ah...!  Ahhhhh!"
	E_CG B_SUDA,'AE_114'
	DB	NEXT
;	DB	'ずるずると音を立てて、俺が亜希ちゃんの中へ押し入っていく。'
	DB	"Making a wet, warm noise, my cock disappears into Aki."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・ふう。'
	DB	"%001:  .........Oh!"
	DB	NEXT
;	DB	'【%001】：・・・動くよ・・・'
	DB	"%001:  .....Are you alright?"
	DB	NEXT
;	DB	'亜希ちゃんが頷くのを見て、俺はゆっくりと腰を引き、出す。'
	DB	"Aki nodded. I started moving my body in and out of her,"
	DB	CR
	DB	"slowly."
	DB	NEXT
;	DB	'十分な潤滑油に満たされた亜希ちゃんの中は、狭いながらも'
;	DB	'物凄く気持ちがいい。'
	DB	"Aki's walls closed around me, bringing me incredible"
	DB	CR
	DB	"tactile pleasure as I moved in and out of her."
	DB	NEXT
;	DB	'【亜希】：・・・あっ・・・あっ・・・先輩・・・！'
	DB	"Aki:  .....Ahh.......ah........ahhn......%001!"
	DB	NEXT
;	DB	'亜希ちゃんの喘ぎが、悲鳴に近くなっていく。'
	DB	"Aki's cries were getting more and more desperate."
	DB	NEXT
;	DB	'俺の方もあまりの気持ちよさに、はや限界に達しようとしていた。'
	DB	"The closeness of Aki's pussy was pushing me to my limit"
	DB	CR
	DB	"faster than I wanted to go."
	DB	NEXT
;	DB	'【%001】：・・・あ・・・亜希ちゃん・・・で、出るっ・・・！'
	DB	"%001:  ......Aki.......I'm coming.....!"
	DB	NEXT
;	DB	'【亜希】：・・・いいっ・・・あぁっ・・・あぁぁっ・・・'
	DB	"Aki:  That's good! That's good!....."
	DB	PAUSE
;	DB	'あぁあぁぁぁぁぁ～～～～～～～～～～～～～～～～っ！！！'
	DB	" Ahhhhhhhh!!!"
	B_O B_SUDA
	DB	NEXT
;	DB	'亜希ちゃんの躰が跳ね上がると同時に、俺の中から熱い物が迸り、亜希ちゃんの中に放たれる。'
	DB	"Just as her body moved with the energy of her orgasm, a flood"
	DB	CR
	DB	"of hot semen spurted from me, inside her."
	DB	NEXT
;	DB	'【%001】：・・・はぁっ・・・はぁっ・・・'
	DB	"%001:  ......*pant*......*pant*......"
	DB	NEXT
;	DB	'【亜希】：・・・は・・・っ・・・は・・・っ・・・'
	DB	"Aki:  ......*pant*.....*pant*.....*pant*...."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・'
	DB	".................."
	DB	NEXT
;	DB	'【亜希】：・・・先輩・・・ありがとう・・・'
	DB	"Aki:  %001.... Thank you."
	DB	NEXT
	DB	BGM,33
	DB	ENDING,6
	DW	0000H


end
