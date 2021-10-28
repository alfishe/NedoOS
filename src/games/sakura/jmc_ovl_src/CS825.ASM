;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２５
;		学園祭最終日　光と影のＷｉｎｄｉｎｇＲｏａｄ

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8
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
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,NN6,NN7,NN8,-1

;VV1:	DB	1,	'考える',0
VV1:	DB	1,	'THINK',0
;VV2:	DB	2,	'選ぶ',0
VV2:	DB	2,	'CHOOSE',0

;NN1:	DB	1,	'フォークダンス',0
NN1:	DB	1,	'DANCE',0
;NN2:	DB	2,	'鈴子',0
NN2:	DB	2,	'REIKO',0
;NN3:	DB	3,	'清美',0
NN3:	DB	3,	'KIYOMI',0
;NN4:	DB	4,	'美緒',0
NN4:	DB	4,	'MIO',0
;NN5:	DB	5,	'瑠璃',0
NN5:	DB	5,	'RURI',0
;NN6:	DB	6,	'亜希',0
NN6:	DB	6,	'AKI',0
;NN7:	DB	7,	'星愛',0
NN7:	DB	7,	'SEIA',0
;NN8:	DB	8,	'恵依美',0
NN8:	DB	8,	'MEIMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;考える　フォークダンス２
S2:		DW	VV2, NN2,  2, M4		;選ぶ　鈴子１
S3:		DW	VV2, NN3,  3, M5		;選ぶ　清美１
S4:		DW	VV2, NN4,  4, M6		;選ぶ　美緒１
S5:		DW	VV2, NN5,  5, M7		;選ぶ　瑠璃１
S6:		DW	VV2, NN6,  6, M8		;選ぶ　亜希１
S7:		DW	VV2, NN7,  7, M9		;選ぶ　星愛１
S8:		DW	VV2, NN8,  8, M10		;選ぶ　恵依美１


;イニシャルメッセージ
M1:
	DB	BGM,24
	E_CG B_SUDA,"AB_36_1"
;	DB	'「文化祭にお集まりの皆さんにお知らせします。６時から、グラウンドにて'
;	DB	'フォークダンスを行ないます。皆様の参加をお待ちしています。繰り返します・・・」'
        DB	"Suddenly an announcement came over the speakers."
        DB	NEXT
        DB	"Announcer:  Attention... The school dance will commence"
        DB	CR
        DB	"at 6:00 on the sports field."
        DB	NEXT
        ;	DB	'【%001】：・・・分ってるっての。そんなに何度も言わなくたって。'
        DB	"%001:  Hmmm..."
        DB G_FLG,G_COPYF,159,159
        DW	0000H
        
M2:		;考える　フォークダンス１
        ;	DB	'・・・・・・・・・'
        DB	"....................."
        DB	NEXT
        ;	DB	'やっぱ、出ない訳にはいかね～よなぁ。'
        DB	"I guess I should go. It'll probably be fun."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;考える　フォークダンス２
        ;	DB	'・・・問題は、誰をパートナーにするかだな。'
        DB	"But the problem is...which woman will be my dance partner?"
        DB	FLG,F_COPYI,1,0
        DW	0000H
        
M4:		;選ぶ　鈴子１
        ;	DB	'【%001】：・・・そうだな、鈴子さんならダンスも上手そうだ。'
        DB	"%001:  That's a good choice. Reiko is probably a good dancer,"
        DB	CR
        DB	"too."
        DB	NEXT
        DB	SINARIO,'CS826_A.OVL',0
        DW	0000H
        
M5:		;選ぶ　清美１
        ;	DB	'【%001】：・・・新藤さんなら、ダンスにも詳しそうだ。'
        DB	"%001:  Kiyomi probably knows a lot about dancing."
        DB	NEXT
        DB	SINARIO,'CS826_B.OVL',0
        DW	0000H
        
M6:		;選ぶ　美緒１
        ;	DB	'【%001】：・・・美緒ちゃんか・・・大丈夫かな？'
        DB	"%001:  Hmmm.... I wonder if Mio knows anything about"
        DB	CR
        DB	"dancing."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・いや、意外と上手かもしれん。'
        DB	"%001:  Well, let's give it a try. She might be really"
        DB	CR
        DB	"good."
        DB	NEXT
        DB	SINARIO,'CS826_C.OVL',0
        DW	0000H
        
M7:		;選ぶ　瑠璃１
        ;	DB	'【%001】：・・・白水さんか・・・受けてくれるかな？'
        DB	"%001:  Will Ruri dance with me if I ask her?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・ま、ダメ元だ。行ってみっか。'
        DB	"%001:  Guess I'll ask her and see."
        DB	NEXT
        DB	FLG,F_JGR,159
        DW	REI
        DB	SINARIO,'CS826_E.OVL',0
        DW	0000H
        
M8:		;選ぶ　亜希１
        ;	DB	'【%001】：・・・亜希ちゃんか。知ってるよ～には思えんのだが・・・'
        DB	"%001:  Hmm, I don't know if she'd be good at dancing..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・いやいや、先入観は良くない。'
        DB	"%001:  Oh well, I'll ask her and find out."
        DB	NEXT
        DB	SINARIO,'CS826_F.OVL',0
        DW	0000H
        
M9:		;選ぶ　星愛１
        ;	DB	'【%001】：・・・吉田か。確かにあいつなら知ってそうだ。'
        DB	"%001:  Seia seems like a good choice."
        DB	NEXT
        DB	SINARIO,'CS826_G.OVL',0
        DW	0000H
        
M10:		;選ぶ　恵依美１
        ;	DB	'【%001】：・・・中野ぉ？'
        DB	"%001:  Meimi?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・でも、あいつ体操部だしな。'
        ;	DB	'ダンスの一つや二つ、知ってるかもしれん。'
        DB	"%001:  Well, she is very athletic, so maybe she's a good"
        DB	CR
        DB	"dancer."
        DB	NEXT
        DB	SINARIO,'CS826_H.OVL',0
        DW	0000H
        
REI:
        BAK_INIT 'AB_27_2'
        B_P1 B_SUDA
        ;	DB	'えっと・・・白水さんは・・・・・・・・・・・・',PAUSE,'いた。'
        DB	"Let's see, where is Ruri...",PAUSE," Oh, there she is."
        DB	NEXT
        ;	DB	'【%001】：お～い、白水さ～ん。'
        DB	"%001:  Hey, Ruri!"
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT05","C",0,10,1
        ;	DB	'【瑠璃】：・・・・・・'
        DB	"Ruri:  ....................."
        DB	PAUSE
        ;	DB	'・・・・・・なに？'
        DB	"..........Yes?"
        DB	NEXT
        ;	DB	'【%001】：あ、あのさ、俺、ダンスなんて全然わかんないから、教えて欲しいんだけど・・・・・・ダンス、できる？'
        DB	"%001:  I don't know how to dance, so I was wondering,"
        DB	CR
        DB	"could you teach me? Do you know anything about it?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・できないわ。'
        DB	"Ruri:  .......No."
        DB	NEXT
        ;	DB	'【%001】：そ、そう。'
        DB	"%001:  Oh, I see."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・じゃ、さよなら。'
        DB	"Ruri:  Sayonara."
        DB	NEXT
        B_P1 B_SUDA
        ;	DB	'【%001】：あ・・・'
        DB	"%001:  Wait a minute..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・白水さん、足早いなあ。'
        DB	"%001:  That girl's fast."
        DB	NEXT
        ;	DB	'【%001】：・・・ふぅ。俺と踊ってくれる人、いるかな・・・'
        DB	"%001:  Hmm. I wonder if one of the others will dance"
        DB	CR
        DB	"with me."
        DB C_BLD,C_N_ON,2,4	;瑠璃
        DW	0000H

end
