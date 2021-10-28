;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１０＿１２
;		川　瑠璃の捜索（キャンプに戻る）

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	-1
MSGTBL:
	DW	M1
COMTBL:
	DW	-1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ


;イニシャルメッセージ
M1:
	DB	BGM,20
	B_O B_SUDA
	BAK_INIT 'AB_16_2'
	DB BUF,B_COPY01
	TU_CG 'CT14','F','D',0,2
	TU_CG 'CT03','F','D',30,3
	T_CG 'CT12','T','I',20,1
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【今日子】：・・・どう！？'
	DB	"Kyoko:  Well?"
	DB	NEXT
;	DB	'【%001】：・・・ダメだ、いない！'
	DB	"%001:  Nope, she's not there!"
	DB	NEXT
;	DB	'【誠】：・・・一体, どこ行っちまったんだ・・・？'
	DB	"Makoto:  Where the hell did she go?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .................."
	DB	NEXT
;	DB	'【%001】：もしかしたら！'
	DB	"%001:  Hmm. I wonder!"
	DB	NEXT
;	DB	'【今日子】：%001君！？どこ行く
	DB	"Kyoko:  %001! Where are you going?"
	DB	NEXT
;	DB	'【美緒】：待ってよ先輩！！'
	DB	"Mio:  Hey, wait up!"
	DB	NEXT
	DB	SINARIO,'CS510_13.OVL',0
	DW	0000H

end
