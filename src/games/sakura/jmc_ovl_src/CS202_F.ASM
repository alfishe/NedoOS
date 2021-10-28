;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０２
;		美緒登場

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
CM2:	DW	VV2,	-1

VV1:	DB	1,	'見る',0
VV2:	DB	2,	'昼寝する',0

NN1:	DB	1,	'桜',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　桜
S2:		DW	VV2, -1,  2, M3		;昼寝する


;イニシャルメッセージ
M1:
	DB	BGM,23
	E_CG B_SUDA,"AE_004G"
	DB	'【%001】：ふぅ・・・'
	DB	NEXT
	DB	'ようやく勧誘の魔の手を逃れて、俺は裏庭に生えている桜の木の下に寝そべった。'
	DB	NEXT
	DB	'【%001】：ん～・・・'
	DB	NEXT
	DB	'４月の暖かな風が、芝と土の匂いを運んで来る。'
	DB	NEXT
	DB	'校舎の向こうの喧騒も、ここではひどく遠くに聞こえ、俺の安息を妨げはしない。'
	DB	NEXT
	DB	'木漏れ日の中を桜の花びらが、俺の胸に舞い降りて来る。'
	DB	NEXT
	DB	'ここはとても暖かくて静かだ・・・大地の腕（かいな）に抱かれていると、時間さえも止まっているようなゆったりした気分になる。'
	DB	NEXT
	DB	'・・・なんつって、俺って詩人だね。'
	DW	0000H

M2:		;見る　桜
	DB	'・・・綺麗だな・・・'
	DB	NEXT
	DB	'桜の花びらが舞い降りてくる様は、なかなか幻想的なものだ。'
	DB	NEXT
	DB	'いつしか天地が逆になって、桜の花びらが舞い踊る空を、桜の木に向かって落下し続けているような・・・'
	DB	NEXT
	DB	'そんな気分になったりもする。'
	DW	0000H

M3:		;昼寝する
	DB	'【%001】：ふぁ・・・'
	DB	NEXT
	DB	'俺は一つ大きなあくびをすると、そっと目を閉じた。'
	DB	NEXT
	B_O B_TATE;ブラックアウト
	DB	'こうしてると・・・今まで聞こえなかったものが聞こえてくる。'
	DB	NEXT
	DB	'小鳥のさえずりとか・・・風で木の葉がすれる音・・・'
	DB	NEXT
	DB	'・・・・・・・・・'
	DB	NEXT
	DB	'ウトウトしていた俺は、頬に当たっていた日の光が何かに遮られたのを感じた。'
	DB	NEXT
	DB	'【%001】：誰・・・？'
	DB	NEXT
	DB SINARIO,'CS203.OVL',0
	DW	0000H


end
