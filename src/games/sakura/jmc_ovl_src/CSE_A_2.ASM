;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ａ＿２
;		鈴子Ｈ１

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
	DB	BGM,13
	E_CG B_FADE,'AE_132'
;	DB	'俺は鈴子さんの服を脱がして、ベッドに押し倒した。'
	DB	"I took off her clothes and laid her down on the bed."
	DB	NEXT
;	DB	'【鈴子】：やだっ、こんな格好・・・！'
	DB	"Reiko:  I don't know if I can do this..."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・下着が濡れてるね・・・'
	DB	"%001:  Reiko.....your panties are wet."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・ばか！'
	DB	"Reiko:  Asshole!"
	DB	NEXT
;	DB	'俺はパンティの隙間から、直に鈴子さんの秘密の場所に触れる。'
	DB	"I reached under her panties and touched her pussy."
	DB	NEXT
;	DB	'【%001】：す・・・すごい・・・・・・！'
	DB	"%001:  ...........Wow!"
	DB	NEXT
;	DB	'間近に見る、鈴子さんのあそこ。'
	DB	"I moved my head down to look at it up close."
	DB	NEXT
;	DB	'【鈴子】：・・・あんまり見ないで・・・恥ずかしい・・・'
	DB	"Reiko:  Don't look at me down there... Oh, God..."
	DB	NEXT
;	DB	'【%001】：・・・そういえば、鈴子さん、ムネが大きくなったんじゃない？'
	DB	"%001:  ....Say, haven't your breasts gotten bigger?"
	DB	NEXT
;	DB	'【鈴子】：・・・'
	DB	"Reiko:  .........................."
	DB	NEXT
;	DB	'【%001】：・・・・・・どれ・・・'
	DB	"%001:  Let me see..."
	DB	NEXT
;	DB	'ぴと'
	DB	"*SQUISH*"
	DB	NEXT
;	DB	'【鈴子】：な、なに？'
	DB	"Reiko:  What?"
	DB	NEXT
;	DB	'俺は鈴子さんのムネの間に顔をうずめてみた。'
	DB	"I buried my face in Reiko's breasts."
	DB	NEXT
;	DB	'【%001】：うん・・・夏より大きくなってるよーな気がする・・・。'
	DB	"%001:  Yes, they're much bigger than they were in the"
	DB	CR
	DB	"summer."
	DB	NEXT
;	DB	'【鈴子】：知らなかった・・・%001君がこんなにＨだったなんて・・・'
	DB	"Reiko:  I had no idea you were such a pervert..."
	DB	NEXT
;	DB	'【%001】：だって・・・鈴子さんの体ってすごいんだもの・・・'
	DB	"%001:  I can't help it. Your body is...so beautiful..."
	DB	NEXT
;	DB	'【鈴子】：・・・悪い子ね。'
	DB	"Reiko:  ......You're a bad boy."
	DB	NEXT
;	DB	'【%001】：鈴子さん・・・！'
	DB	"%001:  Reiko!"
	DB	NEXT
;	DB	'【鈴子】：え！？'
;	DB	"Reiko:  Eh?"
;	DB	NEXT
;	DB	'【鈴子】：きゃ・・・！'
	DB	"Reiko:  No, wait....!"
	DB	NEXT
;	DB	'俺は鈴子さんのブラとパンティをむしりとった。'
	DB	"I pulled her bra and panties off forcefully."
	DB	NEXT
	DB	SINARIO,'CSE_A_3.OVL',0
	DW	0000H


end
