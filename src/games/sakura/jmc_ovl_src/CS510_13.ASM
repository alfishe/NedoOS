;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１０＿１
;		川　瑠璃の捜索（釣り場Ａ）

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
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'待つ',0
VV2:	DB	2,	"WAIT",0
;VV3:	DB	3,	'助ける',0
VV3:	DB	3,	"SAVE",0

NN1:	DB	1,	'RURI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　瑠璃１
S2:		DW	VV2, -1,  2, M3		;待つ１
S3:		DW	VV3, NN1,  3, M4		;助ける１


;イニシャルメッセージ
M1:
	DB	BGM,25
	BAK_INIT 'AB_10_2'
	B_P1 B_SUDA
;	DB	'【%001】：・・・みんな！崖の下を捜してくれ！'
	DB	"%001:  Everybody! Let's look below the cliff!"
	DB	NEXT
;	DB	'【誠】：崖の下？'
	DB	"Makoto:  Below the cliff?"
	DB	NEXT
;	DB	'【%001】：ああ。',PAUSE,'・・・もしかすると・・・'
	DB	"%001:  Yes.",PAUSE," She might be..."
	DB	NEXT
;	DB	'【美緒】：先輩！あそこ！！'
	DB	"Mio:  %001! Look!"
	DB	NEXT
	E_CG B_TATE,'AE_021'
;	DB	'その場にいた全員が, 思わず息を呑む。'
	DB	"Everyone gasped."
	DB	NEXT
;	DB	'白水さんは・・・崖のちょっとした出っ張りに引っ掛かっていた。'
	DB	"Ruri was sprawled out a little ways below the cliff."
	DB	NEXT
;	DB	'【%001】：白水さん！！',PAUSE,'白水さん！！！'
	DB	"%001:  Ruri!! ",PAUSE,"Can you hear us, Ruri?!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..........."
	DB	PAUSE
;	DB	'ダメだ・・・気絶してるみたいだ。'
	DB	"It's no use. She seems to be unconscious."
	DB	NEXT
;	DB	'【美緒】：先輩！早く助けなきゃ！！'
	DB	"Mio:  %001! We have to save her!"
	DB	NEXT
;	DB	'【%001】：わかってる！'
	DB	"%001:  I know!"
	DB	NEXT
	B_O	B_TATE
	DB BUF,B_COPY01
	T_CG 'CT12','T','D',25,1
;	DB	'【今日子】：待ちなさい！君達だけじゃ危険よ！'
	DB	"Kyoko:  Hold on! It's too dangerous!"
	DB	NEXT
;	DB	'【%001】：だけど！'
	DB	"%001:  Yes, but...!"
	DB	NEXT
;	DB	'【今日子】：とにかく, 他の先生達呼んで来るわ。'
	DB	"Kyoko:  I'm going to get the other teachers. Don't try "
	DB	CR
	DB	"anything while I'm gone!"
	DB	PAUSE
;	DB	'いいわね？'
	DB	" Do you understand?"
	DB	NEXT
;	DB	'【%001】：・・・でも！'
	DB	"%001:  Yes, but...!"
	DB	NEXT
;	DB	'【今日子】：これは, 担任としての命令よ。'
	DB	"Kyoko:  As the person in charge here, that's an order."
	DB	NEXT
;	DB	'【%001】：・・・・・・わかりました・・・・・・'
	DB	"%001:  ...Alright."
	DB	NEXT
;	DB	'【今日子】：すぐ戻って来るわ。'
	DB	"Kyoko:  I'll be right back."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ......................"
	DB	NEXT
;	DB	'【誠】：・・・おい, やべぇぞ！'
	DB	"Makoto:  Hey, look at that!"
	DB	NEXT
	E_CG B_TATE,'AE_021'
;	DB	'見れば, 白水さんを支えている岩が崩れ始めている。'
	DB	"The rock which was holding up Ruri was apparently"
	DB	CR
	DB	"starting to crumble."
	DB	NEXT
;	DB	'（・・・・・・どうする！？）'
	DB	"What do I do?"
	DW	0000H

M2:		;見る　瑠璃１
;	DB	'白水さん自身はぴくりとも動かないのに, 土台はどんどん崩れて行く。'
	DB	"Even though Ruri wasn't moving at all, the earth under"
	DB	CR
	DB	"her kept crumbling away."
	DB	NEXT
;	DB	'（・・・くそ, 時間がねぇ！）'
	DB	"Damn, there's no time!"
	DW	0000H

M3:		;待つ１
;	DB	'【%001】：・・・とにかく, 先生を待とう。'
	DB	"%001:  Should probably wait for the teacher."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ..................................."
	DB	NEXT
;	DB	'【%001】：くそっ！まだこね～のかっ！？'
	DB	"%001:  Shit! She still isn't back?!"
	DW	0000H

M4:		;助ける１
;	DB	'【%001】：・・・・・・'

	DB	"%001:  ........"
	DB	PAUSE
;	DB	'こりゃあ, 待ってられね～な。'
	DB	"All right, well, this just won't wait."
	DB	NEXT
;	DB	'【誠】：%001！？'
	DB	"Makoto:  %001?"
	DB	NEXT
;	DB	'【%001】：ああ・・・行って来る。'
	DB	"%001:  I'll be back."
	DB	NEXT
;	DB	'【美緒】：先輩！命綱は！？'
	DB	"Mio:  %001! What about what the teacher said?!"
	DB	NEXT
;	DB	'【%001】：・・・ないもんねだりしてもしょーがねぇ。このまま行くさ。'
	DB	"%001:  Yeah, well, I know what she said, but it can't be"
	DB	CR
	DB	"helped. See you in a few."
	DB	NEXT
;	DB	'【美緒】：でもっ！！'
	DB	"Mio:  Yes, but!"
	DB	NEXT
;	DB	'【%001】：・・・心配すんなって。'
	DB	"%001:  Hey, don't worry, okay?"
	DB	NEXT
;	DB	'俺は美緒ちゃんの頭を軽く叩くと・・・崖から身を躍らせた。'
	DB	"I gave Mio a light pat on the head and leaped off the cliff."
	DB	NEXT
;	DB"	'【美緒】：%001先輩っ！！'
	DB	"Mio:  %001!!"
	DB	NEXT
	B_O B_YOKO
	DB	SINARIO,'CS510_14.OVL',0
	DW	0000H

end
