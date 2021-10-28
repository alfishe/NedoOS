;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｂ０２
;		バレンタイン前の日曜　自宅
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


;イニシャルメッセージ
M1:
        DB	BGM,4
        BAK_INIT "AB_38_1"
        B_P1 B_SUDA
        ;	DB	'そして、バレンタイン間近となった日曜日。'
        DB	"And then it was the Sunday before Valentine's Day."
        DB	NEXT
        DB	BUF,B_COPY01
        T_CG "CT10",0,0,17,1
        ;	DB	'【英美】：しゅーちゃん、もうすぐバレンタインデーね。'
        DB	"Hidemi:  Shu-chan, it's almost Valentine's Day!"
        DB	NEXT
        ;	DB	'【%001】：かーちゃんのチョコはいらねー。'
        DB	"%001:  I don't want any chocolate from you."
        DB	NEXT
        ;	DB	'【英美】：えーどうしてぇ？しゅーちゃん、昔は喜んでくれたのにぃ。'
        DB	"Hidemi:  Why? You used to love to get chocolate from me?"
        DB	NEXT
        ;	DB	'【%001】：バレンタインに母親にチョコもらって喜ぶ高校生がいるか！'
        DB	"%001:  That was a long time ago. I'm grown up now."
        DB	NEXT
        ;	DB	'【英美】：ふぇ～ん、ひどいわしゅーちゃん！'
        DB	"Hidemi:  What? You're such a cruel man!"
        DB	NEXT
        ;	DB	'【英美】：英美のチョコよりも、そこらの名もない女子こーせーのチョコがいーのね！？'
        DB	"Hidemi:  You want to get chocolate from other girls more than"
        DB	CR
        DB	"from your own mother?"
        DB	NEXT
        ;	DB	'【%001】：・・・誰でもいいってわけじゃねーよ。'
        DB	"%001:  ......Well, not just anyone."
        DB	NEXT
        ;	DB	'【英美】：じゃ、誰にもらったら嬉しいの？'
        DB	"Hidemi:  Who do you want to get chocolate from?"
        DB	NEXT
        ;	DB	'【%001】：え、ええっ！？'
        DB	"%001:  What?"
        DB	NEXT
        ;	DB	'【英美】：鈴子ちゃん？清美ちゃん？それとも美緒ちゃん？'
        DB	"Hidemi:  Reiko? Kiyomi? Or that cute Mio person?"
        DB	NEXT
        ;	DB	'【%001】：お、俺突然人と会う約束が出来たから、出掛けてくる！'
        DB	"%001:  Oh! I just realized I have to meet someone! Bye!"
        DB	NEXT
        ;	DB	'【英美】：あ、しゅーちゃん、お駄賃上げるから帰りにお買い物してきてくれる？'
        DB	"Hidemi:  Oh, Shu-chan, I have some things I'd like you to"
        DB	CR
        DB	"pick up at the store. Will you get them for me?"
        DB	NEXT
        ;	DB	'【%001】：・・・いいけどさ。'
        DB	"%001:  Alright."
        DB	NEXT
        ;	DB	'【英美】：はい、これがお買い物メモ。'
        DB	"Hidemi:  Here's the shopping list."
        DB	NEXT
        ;	DB	'俺はかーちゃんからメモを受け取った。'
        DB	"I took the list from Mom."
        DB	NEXT
        ;	DB	'【%001】：じゃ、行ってくる。'
        DB	"%001:  Okay, I'll be back later."
        DB	NEXT
        ;	DB	'【英美】：待ってぇしゅーちゃん、行ってきますのキス・・・'
        DB	"Hidemi:  Wait, Shu-chan! I didn't give you your goodbye kiss!"
        DB	NEXT
        ;	DB	'俺はかーちゃんのキス攻撃をかいくぐって、家を飛び出した。'
        DB	"I dodge my mother's kissing attack and run out of the house."
        DB	NEXT
        ;	DB	'【%001】：・・・ふ～っ・・・ゲーセンでも行くか。'
        DB	"%001:  I guess I'll go to the game center."
        DB	NEXT
        ;	DB	'俺はゲームセンター「バベル」に行くことにした。'
        DB	"I head for the game center Babel."
        DB	NEXT
        DB	SINARIO,'CSB03.OVL',0
        DW	0000H


end
