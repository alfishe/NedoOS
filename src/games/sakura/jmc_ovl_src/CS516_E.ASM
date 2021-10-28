;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５１６＿Ｅ
;		林間学校　最終日　瑠璃の弱点

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
	DB	BGM,21
	BAK_INIT 'AB_16_1'
	DB BUF,B_COPY01
	B_O B_FADE
;	DB	'・・・翌朝。'
	DB	"The next morning."
	DB	NEXT
	B_P1 B_FADE
;	DB	'【%001】：・・・う～・・・頭いてぇ・・・'
	DB	"%001:  ....Ooh...my head hurts..."
	DB	NEXT
	T_CG 'CT03','F',0,0,1
;	DB	'【美緒】：先輩・・・大丈夫？'
	DB	"Mio:  %001, are you alright?"
	DB	NEXT
;	DB	'【%001】：・・・・・・あんまり・・・・・・'
	DB	"%001:  Not really..."
	DB	NEXT
	T_CG1 'CT05','F',0,33,2
;	DB	'【瑠璃】：・・・・・・・・・%001君。'
	DB	"Ruri:  ....%001."
	DB	NEXT
;	DB	'【%001】：・・・ああ、白水さん。おはよう。'
	DB	"%001:  Oh, Ruri. Hi."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・昨晩、先生戻って来た？'
	DB	"Ruri:  Did Kyoko-sensei come back last night?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ............................."
	DB	PAUSE
;	DB	'へ？'
	DB	"Huh?"
	DB	NEXT
;	DB	'【瑠璃】：校長先生に、聞かれたの。'
	DB	"Ruri:  The dean asked me."
	DB	NEXT
;	DB	'【%001】：・・・・・・白水さん、あの時いたじゃないか。'
	DB	"%001:  .....Ruri, you were there, remember?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  ........................."
	DB	PAUSE
;	DB	'覚えてないの。'
	DB	"I don't remember."
	DB	NEXT
;	DB	'【%001】：・・・・・・はい？'
	DB	"%001:  .....You don't?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・'
	DB	"Ruri:  .................."
	DB	NEXT
;	DB	'（・・・もしかして・・・飲むと記憶が飛ぶって奴？）'
	DB	"Maybe drinking the sake affected her memory?"
	DB	NEXT
;	DB	'【%001】：・・・・・・今日子先生は、確かに一回戻って来たよ。'
	DB	"%001:  Kyoko-sensei came back last night."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・そう。'
	DB	"Ruri:  ......Oh."
	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT03','F',0,0,1
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  ................."
	DB	NEXT
;	DB	'【%001】：意外だ。'
	DB	"%001:  Wow."
	DB	NEXT
	BAK_INIT 'AB_08_1'
	B_P1 B_SUDA
;	DB	'・・・かくして、色々ありまくった林間学校は終わった。'
	DB	"And so, our very eventful camping trip came to an end..."

	DB	NEXT

	DB	"We'll come back next year and do the same thing again."
	DB	NEXT
;	DB	'（・・・・・・みんなと・・・白水さんと・・・・・・）'
	DB	"........I wonder what Ruri will be doing by then?"
	DB	NEXT
	DB BUF,B_COPY01
	TU_CG 'CT14','F','D',0,3
	T_CG 'CT03','F','K',30,4
	DB ANI,A_ON,3
;	DB	'【美緒】：・・・せんぱーい！'
	DB	"Mio:  ...%001!"
	DB	NEXT
;	DB	'【誠】：こら%001！ぼけっとしてね～で早く！'
	DB	"Makoto:  Hey %001! Hurry up! Come on!"
	DB	NEXT
;	DB	'【%001】：・・・・・・おう、今行く！'
	DB	"%001:  ....Uh, coming!"
	DB	NEXT
;	DB	'俺は頭を一つ振り、バッグと想い出を抱えてみんなのところへ駆けて行った。'
	DB	"I gave my head a shake, grabbed my bag and my memories and",CR,"went to join everyone else."
	DB	NEXT
;	DB	'来年も、想い出が作れるように願いながら・・・・・・'
	DB	"Hoping that next year would be interesting too..."
	DB	NEXT
	B_O B_WIPE
	DB	SINARIO,'CS601.OVL',0
	DW	0000H


end
