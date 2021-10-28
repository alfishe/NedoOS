;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ａ＿１
;		鈴子キス

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
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ............"
	E_CG B_FADE,'AE_131'
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・'
	DB	"Reiko:  .........................."
	DB	NEXT
;	DB	'【%001】：・・・・・・っ・・・'
	DB	"%001:  ............................Mmm..."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・・・・'
	DB	"Reiko:  .............Mmm...."
	DB	NEXT
;	DB	'【%001】：・・・っ・・・！'
	DB	"%001:  ...................!!"
	DB	NEXT
;	DB	'【鈴子】：・・・・・・・・・・・・・・・'
	DB	"Reiko:  ..................................."
	DB	NEXT
;	DB	'【%001】：・・・・・・む・・・！んん・・・！'
	DB	"%001:  ...................Mmmm!!"
	DB	NEXT
;	DB	'【%001】：ぶはっ！'
	DB	"%001:  *gasp*!!"
	DB	NEXT
;	DB	'【%001】：ぜはーっぜはーっぜはーっぜはーっぜはーっぜはーっ・・・'
	DB	"%001:  ....*pant*.....*pant*......"
	DB	NEXT
;	DB	'【鈴子】：%001君・・・どうしたの？'
	DB	"Reiko:  %001, what's the matter?"
	DB	NEXT
;	DB	'【%001】：さ・・・さすが鈴子さん・・・水泳やってるだけあって・・・すごい肺活量・・・'
	DB	"%001:  I can see why you're on the swim team! You can"
	DB	CR
	DB	"really hold your breath a long time!"
	DB	NEXT
;	DB	'【鈴子】：もう・・・ムードが壊れちゃったわ。'
	DB	"Reiko:  .......You broke the mood."
	DB	NEXT
;	DB	'【%001】：悪ィ・・・'
	DB	"%001:  Sorry."
	DB	NEXT
;	DB	'そう言いながら、俺はもう一度鈴子さんと唇を重ねて、今度は舌を侵入させる。'
	DB	"I kissed her again, this time invading her mouth with my"
	DB	CR
	DB	"tongue."
	DB	NEXT
;	DB	'【鈴子】：・・・っ・・・？'
	DB	"Reiko:  ........??"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・'
	DB	"%001:  ..................................."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・む・・・！ンン・・・！'
	DB	"Reiko:  ..................Mmm!"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・'
	DB	"%001:  ............................."
	DB	NEXT
;	DB	'【鈴子】：・・・っはあ・・・！'
	DB	"Reiko:  ......................!."
	DB	NEXT
;	DB	'【鈴子】：・・・%001君・・・こんなキス、どこで覚えたの・・・？'
	DB	"Reiko:  %001, where did you learn to kiss like that?"
	DB	NEXT
;	DB	'（・・・やなこと聞くなあ・・・）'
	DB	"Don't ask me, I don't want to think about that right now!"
	DB	NEXT
;	DB	'【%001】：俺、キスするの始めてなんだぜ。'
	DB	"%001:  This is the first time I've kissed someone."
	DB	NEXT
;	DB	'（「する」のはね・・・さんざん今日子先生に「された」けど・・・）'
	DB	".....Of course, I didn't really kiss Kyoko-sensei... More"
	DB	CR
	DB	"like, I was being kissed by her."
	DB	NEXT
;	DB	'【鈴子】：本当？'
	DB	"Reiko:  Really?"
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ....................."
	DB	NEXT
;	DB	'俺は服の上から鈴子さんの豊かなムネに手を伸ばした。'
	DB	"I began to rub Reiko's abundant chest through her clothes."
	DB	NEXT
;	DB	'【鈴子】：ちょ、ちょっと・・・まだ早くない？私達、高校生よ？'
	DB	"Reiko:  W- Wait a minute... Don't you think it's too"
	DB	CR
	DB	"early for that?"
	DB	NEXT
;	DB	'【%001】：鈴子さんがホントに嫌ならやめる。'
	DB	"%001:  If you want me to stop, I will."
	DB	NEXT
;	DB	'【鈴子】：・・・・・・'
	DB	"Reiko:  ........................."
	DB	NEXT
;	DB	'【%001】：俺、鈴子さんが好きだから・・・鈴子さんが嫌がることはしないよ。'
	DB	"%001:  I love you, Reiko... So I'd never do anything that"
	DB	CR
	DB	"you didn't like."
	DB	NEXT
	DB	"%001:  Let me know what you want to do. I'll leave it"
	DB	CR
	DB	"up to you."
	DB	NEXT
;	DB	'【鈴子】：ずるい・・・'
	DB	"Reiko:  You're cheating."
	DB	NEXT
;	DB	'【鈴子】：%001君・・・女の子に決めさせるなんてずるいわ。'
	DB	"Reiko:  It's not right....to make the girl choose like this."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ..............."
	DB	NEXT
;	DB	'【鈴子】：言えるわけないじゃない・・・'
	DB	"Reiko:  ........I can't say it! I'm too embarrassed!"
	DB	NEXT
;	DB	'【%001】：・・・いいんだね、鈴子さん・・・'
	DB	"%001:  ......Don't worry, Reiko..."
	DB	NEXT
;	DB	'【鈴子】：・・・'
	DB	"Reiko:  ........"
	DB	NEXT
;	DB	'鈴子さんは恥ずかしそうにこくんとうなずいた。'
	DB	"Reiko nodded, her face red with embarrassment."
	DB	NEXT
	DB	SINARIO,'CSE_A_2.OVL',0
	DW	0000H


end
